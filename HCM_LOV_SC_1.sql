--------------------------------------------------------
--  DDL for Package Body HCM_LOV_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_SC" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    -- lov params
    param_flg_secur     := nvl(hcm_util.get_string_t(json_obj,'p_flg_secur'),'Y');
    param_where         := hcm_util.get_string_t(json_obj,'p_where');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    begin
      select codempid
        into global_v_codempid
        from tusrprof
       where coduser = global_v_coduser;
    exception when no_data_found then
      global_v_coduser := null;
    end;
  end;

  --LOV for List of Application Name
  function get_application_name(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select codapp,desappe,desappt,desapp3,desapp4,desapp5
                from tappprof
                where codapp in (select codapp from twkfunct) ' ||v_where||
              ' order by codapp';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tappprof')
           and  column_name = upper('codapp');
    exception when others then
        v_length := 0;
    end;

    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_data1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);
    dbms_sql.define_column(v_cursor,3,v_data3,1000);
    dbms_sql.define_column(v_cursor,4,v_data4,1000);
    dbms_sql.define_column(v_cursor,5,v_data5,1000);
    dbms_sql.define_column(v_cursor,6,v_data6,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codapp',v_data1);
      obj_data.put('namappe',v_data2);
      obj_data.put('namappt',v_data3);
      obj_data.put('namapp3',v_data4);
      obj_data.put('namapp4',v_data5);
      obj_data.put('namapp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

  --LOV for List of Department All by Employee
  function get_department_employee(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char) := 'WHERE 1=1 ';
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;
    v_stmt := 'select codcomp,codpos , stapost2, codempid
                from (
                   select codcomp,codpos ,''0'' stapost2,codempid
                   from  temploy1
                   union
                   select codcomp,codpos , stapost2,codempid
                   from   tsecpos
                   where dteeffec <= SYSDATE
                   and   (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                )
                '|| v_where ||'
                order by stapost2 ,codcomp,codpos ';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsecpos')
           and  column_name = upper('codcomp');
    exception when others then
        v_length := 0;
    end;

    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_data1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);
    dbms_sql.define_column(v_cursor,3,v_data3,1000);
    dbms_sql.define_column(v_cursor,4,v_data4,1000);
    -- dbms_sql.define_column(v_cursor,5,v_data5,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      -- dbms_sql.column_value(v_cursor,5,v_data5);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codcomp',v_data1);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data1,global_v_lang));
      obj_data.put('codpos',v_data2);
      obj_data.put('desc_codpos',get_tpostn_name(v_data2,global_v_lang));
      obj_data.put('stapos',get_tlistval_name('STAPOST2',v_data3,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

END HCM_LOV_SC;

/
