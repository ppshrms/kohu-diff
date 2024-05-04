--------------------------------------------------------
--  DDL for Package Body HCM_LOV_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_PM" is
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

 /* ######### Example #########
    set serveroutput on
    declare
      v_in  clob := '{"p_coduser":"TJS00001", "p_lang":"101", "p_where":"rownum <= 2"}';
    begin
      dbms_output.put_line(hcm_lov_pm.get_emp_all(v_in));
    end;
  ############################## */
  --
  function get_emp_new(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  =  ''0'' '||v_where||
               'order by codempid';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_emp_probation(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  =  ''1'' '||v_where||
               'order by codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --
  function get_emp_current(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  =  ''3'' '||v_where||
               'order by codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --
  function get_emp_retire(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  =  ''9'' '||v_where||
               'order by codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while
    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_emp_pro_curr_retire(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  in (''1'',''3'',''9'')'||v_where||
               'order by codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --
  function get_emp_pro_curr(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and temploy1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select codempid,namempe,namempt,namemp3,namemp4,namemp5,staemp
                 from temploy1
                where staemp  in (''1'',''3'')'||v_where||
               'order by codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codempid',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_type_emp_new(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp  =  ''0'' '||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;

  function get_type_emp_probation(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp  =  ''1'' '||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;
  --
  function get_type_emp_current(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp in (''1'',''3'') '||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;
  --
  function get_type_emp_retire(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp  =  ''9'' '||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;

  function get_type_emp_pro_curr_retire(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp  in (''1'',''3'',''9'')'||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;
  --
  function get_type_emp_pro_curr(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_data3         varchar2(5000 char);
    v_data4         varchar2(5000 char);
    v_data5         varchar2(5000 char);
    v_data6         varchar2(5000 char);
    v_data7         varchar2(5000 char);
    v_data8         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    if param_flg_secur = 'Y' then
      v_where := v_where|| ' and emp1.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                           ' and 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and emp1.codcomp like ts.codcomp'||'||''%'''||'
                                          and rownum <= 1)';
    end if;

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                where       emp1.staemp  in (''1'',''3'')'||v_where||
               'order by    emp1.codempid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('temploy1')
           and  column_name = upper('codempid');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);
    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);
      dbms_sql.column_value(v_cursor,8,v_data8);

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200',' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(get_tlistval_name('NAMESTAT',v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  ' ',' ',' ',' '
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;

  function get_personal_req1(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := ' where '||param_where;
    end if;

    V_STMT := ' select numreqst,codcomp
                from treqest1'
                ||v_where||
              ' order by numreqst';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('treqest1')
           and  column_name = upper('numreqst');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,1,V_DATA1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    WHILE (DBMS_SQL.FETCH_ROWS(V_CURSOR) > 0) LOOP
      dbms_sql.column_value(v_cursor,1,v_data1);
      DBMS_SQL.column_value(V_CURSOR,2,V_DATA2);

      V_ROW := V_ROW+1;
      obj_data := json_object_t();
      OBJ_DATA.PUT('numreqst',V_DATA1);
      obj_data.put('codcomp',v_data2);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data2,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --

  function get_movement_req3(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select a.numreqst,a.codcomp, b.codpos
                from treqest1 a,treqest2 b
                where a.numreqst = b.numreqst '||v_where||
               'order by a.numreqst';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('treqest1')
           and  column_name = upper('numreqst');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,1,V_DATA1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,3,V_DATA3,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numreqst',v_data1);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data2,global_v_lang));
      obj_data.put('codpos',v_data3);
      obj_data.put('desc_position',get_tpostn_name(v_data3,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --

  function get_case_number(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := ' where '||param_where;
    end if;

    V_STMT := ' select numcaselw,codlegald
                from tlegalexe'
                ||v_where||
              ' order by numcaselw';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tlegalexe')
           and  column_name = upper('numcaselw');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,1,V_DATA1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    WHILE (DBMS_SQL.FETCH_ROWS(V_CURSOR) > 0) LOOP
      dbms_sql.column_value(v_cursor,1,v_data1);
      DBMS_SQL.column_value(V_CURSOR,2,V_DATA2);

      V_ROW := V_ROW+1;
      obj_data := json_object_t();
      OBJ_DATA.PUT('numcaselw',V_DATA1);
      obj_data.put('codlegald',v_data2);
      obj_data.put('descodlegald',get_tcodec_name('tcodlegald' ,v_data2 ,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --
  function get_law_enforcement_office(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
--      v_where := v_where|| ' and ' || param_where;
      v_where := ' where '|| param_where;
    end if;

    v_stmt := ' select  codcodec,descode,descodt,descod3,descod4,descod5,flgact
                  from tcodlegald '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodlegald')
           and  column_name = upper('codcodec');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codcodec',v_data1);
      obj_data.put('descode',v_data2);
      obj_data.put('descodt',v_data3);
      obj_data.put('descod3',v_data4);
      obj_data.put('descod4',v_data5);
      obj_data.put('descod5',v_data6);
      obj_data.put('flgact',v_data7);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --
  function get_company_asset_code(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact 
                  from tcodasst '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodasst')
           and  column_name = upper('codcodec');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('typasset',v_data1);
      obj_data.put('descode',v_data2);
      obj_data.put('descodt',v_data3);
      obj_data.put('descod3',v_data4);
      obj_data.put('descod4',v_data5);
      obj_data.put('descod5',v_data6);
      obj_data.put('flgact',v_data7);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_condition(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codrep, namrepe, namrept, namrep3, namrep4, namrep5
                  from trepdsph '||v_where||
                ' order by codrep';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('trepdsph')
           and  column_name = upper('codrep');
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
      obj_data.put('codrep',v_data1);
      obj_data.put('namrepe',v_data2);
      obj_data.put('namrept',v_data3);
      obj_data.put('namrep3',v_data4);
      obj_data.put('namrep4',v_data5);
      obj_data.put('namrep5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
    -- LOV for Mail Alert
  function get_memo_no(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select memono, subject
                from tmailalert '||v_where||
              ' order by memono';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tmailalert')
           and  column_name = upper('memono');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_data1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('memono',v_data1);
      obj_data.put('desc_memono',v_data2);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --- LOV for List of Condition Code
  function get_condition_code(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'and '||param_where;
    end if;

    v_stmt := ' select codfrm, namfrme, namfrmt, namfrm3, namfrm4, namfrm5
                  from tincpos t1
                 where dteeffec = (select max(t2.dteeffec) 
                                     from tincpos t2
                                    where t2.dteeffec   <= trunc(sysdate) 
                                      and t2.codfrm     = t1.codfrm '||v_where||' 
                 ) '||v_where||
                ' order by codfrm';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tincpos')
           and  column_name = upper('codfrm');
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
      obj_data.put('codfrm',v_data1);
      obj_data.put('namfrme',v_data2);
      obj_data.put('namfrmt',v_data3);
      obj_data.put('namfrm3',v_data4);
      obj_data.put('namfrm4',v_data5);
      obj_data.put('namfrm5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
--- LOV for List of Format Group Code Emp
  function get_group_id(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  groupid, namempide, namempidt, namempid3, namempid4, namempid5
                from tsempidh '||v_where||
              ' order by groupid';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsempidh')
           and  column_name = upper('groupid');
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
      obj_data.put('groupid',v_data1);
      obj_data.put('namempide',v_data2);
      obj_data.put('namempidt',v_data3);
      obj_data.put('namempid3',v_data4);
      obj_data.put('namempid4',v_data5);
      obj_data.put('namempid5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --- LOV for List of Form
  function get_list_form(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;
    v_stmt := ' select codform, namfme, namfmt, namfm3, namfm4, namfm5, typfm
                from tfmrefr '||v_where||
              ' order by codform';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tfmrefr')
           and  column_name = upper('codform');
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
    dbms_sql.define_column(v_cursor,7,v_data7,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
      dbms_sql.column_value(v_cursor,7,v_data7);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codform',v_data1);
      obj_data.put('namfme',v_data2);
      obj_data.put('namfmt',v_data3);
      obj_data.put('namfm3',v_data4);
      obj_data.put('namfm4',v_data5);
      obj_data.put('namfm5',v_data6);
      obj_data.put('typfm',v_data7);
      obj_data.put('desc_typfm',get_tlistval_name('TYPFM',v_data7,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for Mail Alert Number PM
  function get_mail_alert_number_pm(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt          varchar2(5000 char);
    v_data1         varchar2(5000 char);
    v_data2         varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select mailalno, subject
                from tpmalert '||v_where||
              ' order by mailalno';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tpmalert')
           and  column_name = upper('mailalno');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_data1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('mailalno',v_data1);
      obj_data.put('desc_mailalno',v_data2);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  ---
  
  function get_approval_request_number(json_str_input in clob) return clob is
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
    v_data7         varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select numreqst,codcomp, codpos
                from treqest2 
                where flgrecut in (''E'',''O'') '||v_where||
               'order by numreqst, codcomp, codpos';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('treqest2')
           and  column_name = upper('numreqst');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,1,V_DATA1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,3,V_DATA3,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numreqst',v_data1);
      obj_data.put('codcomp',v_data2);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data2,global_v_lang));
      obj_data.put('codpos',v_data3);
      obj_data.put('desc_codpos',get_tpostn_name(v_data3,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  ---
  function get_approval_request_number_io(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt        varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_data6     varchar2(5000 char);
    v_data7     varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select numreqst,codcomp, codpos
                from treqest2 
                where flgrecut in (''I'',''O'') '||v_where||
               'order by numreqst, codcomp, codpos';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('treqest2')
           and  column_name = upper('numreqst');
    exception when others then
        v_length := 0;
    end;
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,1,V_DATA1,1000);
    dbms_sql.define_column(v_cursor,2,v_data2,1000);
    DBMS_SQL.DEFINE_COLUMN(V_CURSOR,3,V_DATA3,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numreqst',v_data1);
      obj_data.put('codcomp',v_data2);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data2,global_v_lang));
      obj_data.put('codpos',v_data3);
      obj_data.put('desc_codpos',get_tpostn_name(v_data3,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    return obj_row.to_clob;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
end;

/
