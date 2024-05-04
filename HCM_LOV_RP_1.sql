--------------------------------------------------------
--  DDL for Package Body HCM_LOV_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_RP" is
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
  --

  /* ######### Example #########
    set serveroutput on
    declare
      v_in  clob := '{"p_coduser":"TJS00001", "p_lang":"101", "p_where":"rownum <= 2"}';
    begin
      dbms_output.put_line(hcm_lov_rp.get_interview_form(v_in));
    end;
  ############################## */

  -- List of Group Position --
  function get_group_position(json_str_input in clob) return clob is
   obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_data6     varchar2(5000 char);
    v_data7     varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec,descode,descodt,descod3,descod4,descod5,flgact
                  from tcodgpos '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodgpos')
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
  -- List of Mail Alert Number  --
  function get_mail_alert_number_rp(json_str_input in clob) return clob is
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
                from trpalert '||v_where||
              ' order by mailalno';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('trpalert')
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
  -- Line of work --
  function get_line_of_work(json_str_input in clob) return clob is
   obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_data6     varchar2(5000 char);
    v_data7     varchar2(5000 char);
    v_data8     varchar2(5000 char);
    v_data9     varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codcompy,codlinef,
                       deslinefe,deslineft,deslinef3,deslinef4,deslinef5,
                       to_char(dteeffec,''dd/mm/yyyy'') as dteeffec,
                       case when flggroup = ''Y'' then ''Yes'' else ''No'' end as flggroup 
                  from torgprt '||v_where||
                ' order by codcompy,dteeffec desc,codlinef';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('torgprt')
           and  column_name = upper('codlinef');
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
    dbms_sql.define_column(v_cursor,9,v_data9,1000);

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
      dbms_sql.column_value(v_cursor,9,v_data9);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codcompy',v_data1);
      obj_data.put('codlinef',v_data2);
      obj_data.put('deslinefe',v_data3);
      obj_data.put('deslineft',v_data4);
      obj_data.put('deslinef3',v_data5);
      obj_data.put('deslinef4',v_data6);
      obj_data.put('deslinef5',v_data7);
      obj_data.put('dteeffec',v_data8);
      obj_data.put('flggroup',v_data9);
      
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
 --LOV List of Line code origin --
  function get_line_of_work_origin(json_str_input in clob) return clob is
   obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where || ' and a.codcompy = b.codcompy
            and a.codlinef = b.codlinef
            and a.dteeffec = b.dteeffec
            and a.staorg = ''A''';
    else
      v_where := 'where a.codcompy = b.codcompy
            and a.codlinef = b.codlinef
            and a.dteeffec = b.dteeffec
            and a.staorg = ''A''';
    end if;

    v_stmt := ' select a.codlinef,b.codcompp,b.codpospr,b.numlevel, a.codcompy
                  from thisorg a, thisorg2 b  '||v_where||
                ' order by a.codlinef';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodgpos')
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

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codlineforg',v_data1);
      obj_data.put('codlinef',v_data1);
      obj_data.put('desc_codlineforg',get_tfunclin_name(v_data5,v_data1,global_v_lang));
      obj_data.put('codcomp',v_data2);
      obj_data.put('desc_codcomp',get_tcenter_name(v_data2,global_v_lang));
      obj_data.put('codpos',v_data3);
      obj_data.put('desc_codpos',get_tpostn_name(v_data3,global_v_lang));
      obj_data.put('numlevel',v_data4);
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
  --LOV List of Line code 2 --
  function get_line_of_work2(json_str_input in clob) return clob is
   obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_stmt := ' select distinct codcompy,codlinef,to_char(dteeffec,''dd/mm/yyyy''),flggroup
                    from thisorg 
                   where '||param_where||' 
                     and staorg = ''A'' 
                  order by codlinef ';

      begin
          select  char_length
            into  v_length
            from  user_tab_columns
           where  table_name  = upper('thisorg')
             and  column_name = upper('codlinef');
      exception when others then
          v_length := 0;
      end;

      v_cursor  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
      dbms_sql.define_column(v_cursor,1,v_data1,1000);
      dbms_sql.define_column(v_cursor,2,v_data2,1000);
      dbms_sql.define_column(v_cursor,3,v_data3,1000);
      dbms_sql.define_column(v_cursor,4,v_data4,1000);

      v_dummy := dbms_sql.execute(v_cursor);
      while (dbms_sql.fetch_rows(v_cursor) > 0) loop
        dbms_sql.column_value(v_cursor,1,v_data1);
        dbms_sql.column_value(v_cursor,2,v_data2);
        dbms_sql.column_value(v_cursor,3,v_data3);
        dbms_sql.column_value(v_cursor,4,v_data4);

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcompy',v_data1);
        obj_data.put('codlinef2',v_data2);
        obj_data.put('desc_codlinef2',get_tfunclin_name(v_data1,v_data2,global_v_lang));
        obj_data.put('dteeffec',v_data3);
        if v_data4 = 'Y' then
          obj_data.put('flggroup',get_label_name('LOV_CODLINE2',global_v_lang,7));
        else
          obj_data.put('flggroup',get_label_name('LOV_CODLINE2',global_v_lang,8));
        end if;
        obj_data.put('max',to_char(v_length));
        obj_row.put(to_char(v_row-1),obj_data);
      end loop; -- end while
    end if;
    return obj_row.to_clob;

   exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
   return json_str_output;
  end;
    -- Lov List of Path No --
  function get_path_no(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_data6     varchar2(5000 char);
    v_data7       varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from  tcodnumpath '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodnumpath')
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
      -- Lov List of Path Number (tposplnh)--
  function get_num_path_no(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_data3     varchar2(5000 char);
    v_data4     varchar2(5000 char);
    v_data5     varchar2(5000 char);
    v_data6     varchar2(5000 char);
    v_data7       varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select distinct  numpath, despathe, despatht, despath3, despath4, despath5
                  from  tposplnh '||v_where||
                ' order by numpath';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tposplnh')
           and  column_name = upper('numpath');
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
      obj_data.put('numpath',v_data1);
      obj_data.put('despathe',v_data2);
      obj_data.put('despatht',v_data3);
      obj_data.put('despath3',v_data4);
      obj_data.put('despath4',v_data5);
      obj_data.put('despath5',v_data6);
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
