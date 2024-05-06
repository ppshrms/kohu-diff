--------------------------------------------------------
--  DDL for Package Body HCM_LOV_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_TR" is
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
      dbms_output.put_line(hcm_lov_tr.get_training_course(v_in));
    end;
  ############################## */

  function get_training_course(json_str_input in clob) return clob is
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

    v_stmt := ' select  codcours,namcourse,namcourst,namcours3,namcours4,namcours5
                  from tcourse '||v_where||
                ' order by codcours';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcourse')
           and  column_name = upper('codcours');
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
      obj_data.put('codcours',v_data1);
      obj_data.put('namcourse',v_data2);
      obj_data.put('namcourst',v_data3);
      obj_data.put('namcours3',v_data4);
      obj_data.put('namcours4',v_data5);
      obj_data.put('namcours5',v_data6);
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

  function get_memorandum(json_str_input in clob) return clob is
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
    v_data8         varchar2(5000 char);
    v_data9         varchar2(5000 char);
    v_data10        varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select a.nummemo,a.dteyear,a.dtemonth,a.numclseq,a.codcours,
                       b.namcourse,b.namcourst,b.namcours3,b.namcours4,b.namcours5
                  from tinhmemo a, tcourse b
                 where a.codcours = b.codcours '||v_where||
                ' order by dteyear desc, dtemonth desc';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tinhmemo')
           and  column_name = upper('nummemo');
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
    dbms_sql.define_column(v_cursor,10,v_data10,1000);

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
      dbms_sql.column_value(v_cursor,10,v_data10);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('nummemo',v_data1);
      obj_data.put('dteyear',v_data2);
      obj_data.put('dtemonth',v_data3);
      obj_data.put('numclseq',v_data4);
      obj_data.put('codcours',v_data5);
      obj_data.put('namcourse',v_data6);
      obj_data.put('namcourst',v_data7);
      obj_data.put('namcours3',v_data8);
      obj_data.put('namcours4',v_data9);
      obj_data.put('namcours5',v_data10);
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
  -- List of Hotel / Training of Place --
  function get_hotel_training(json_str_input in clob) return clob is
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

    v_stmt := ' select  codhotel, namhotee, namhotet, namhote3, namhote4, namhote5
                  from  thotelif '||v_where||
                ' order by codhotel';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('thotelif')
           and  column_name = upper('codhotel');
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
      obj_data.put('codhotel',v_data1);
      obj_data.put('namhotee',v_data2);
      obj_data.put('namhotet',v_data3);
      obj_data.put('namhote3',v_data4);
      obj_data.put('namhote4',v_data5);
      obj_data.put('namhote5',v_data6);
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
    -- List of Institute Code --
  function get_code_institute(json_str_input in clob) return clob is
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

    v_stmt := ' select  codinsts, naminste, naminstt, naminst3, naminst4, naminst5
                  from  tinstitu '||v_where||
                ' order by codinsts';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tinstitu')
           and  column_name = upper('codinsts');
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
      obj_data.put('codinsts',v_data1);
      obj_data.put('naminste',v_data2);
      obj_data.put('naminstt',v_data3);
      obj_data.put('naminst3',v_data4);
      obj_data.put('naminst4',v_data5);
      obj_data.put('naminst5',v_data6);
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
    -- List of Instructor Name --
  function get_instructor_name(json_str_input in clob) return clob is
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

    v_stmt := ' select  codinst, naminse, naminst, namins3, namins4, namins5
                  from  tinstruc '||v_where||
                ' order by codinst';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tinstruc')
           and  column_name = upper('codinst');
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
      obj_data.put('codinst',v_data1);
      obj_data.put('naminse',v_data2);
      obj_data.put('naminst',v_data3);
      obj_data.put('namins3',v_data4);
      obj_data.put('namins4',v_data5);
      obj_data.put('namins5',v_data6);
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
  -- List Cost of Training Code --
  function get_cost_training_code(json_str_input in clob) return clob is
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

    v_stmt := ' select  codexpn, descode, descodt, descod3, descod4, descod5
                  from  tcodexpn '||v_where||
                ' order by codexpn';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodexpn')
           and  column_name = upper('codexpn');
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
      obj_data.put('codexpn',v_data1);
      obj_data.put('descode',v_data2);
      obj_data.put('descodt',v_data3);
      obj_data.put('descod3',v_data4);
      obj_data.put('descod4',v_data5);
      obj_data.put('descod5',v_data6);
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
  -- List of Certificate Format Code --
  function get_certificate_format(json_str_input in clob) return clob is
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

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from  tbckgrnd '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tbckgrnd')
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
    -- List of Department --
  function get_department_jobposition(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt      varchar2(5000 char);
    v_data1     varchar2(5000 char);
    v_data2     varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codcomp, codpos
                  from  tjobpos '||v_where||
                ' order by codcomp';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tjobpos')
           and  column_name = upper('codcomp');
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
      obj_data.put('codcomp',v_data1);
      obj_data.put('desc_codcomp', get_tcenter_name(v_data1, global_v_lang));
      obj_data.put('codpos',v_data2);
      obj_data.put('desc_codpos', get_tpostn_name(v_data2, global_v_lang));
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
  --  List of Course --
  function get_course_category(json_str_input in clob) return clob is
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
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codcours,namcourse,namcourst,namcours3,namcours4,namcours5,codcate
                  from tcourse '||v_where||
                ' order by codcours';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcourse')
           and  column_name = upper('codcours');
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
    dbms_sql.define_column(v_cursor,7,v_data6,1000);

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
      obj_data.put('codcours',v_data1);
      obj_data.put('namcourse',v_data2);
      obj_data.put('namcourst',v_data3);
      obj_data.put('namcours3',v_data4);
      obj_data.put('namcours4',v_data5);
      obj_data.put('namcours5',v_data6);
      obj_data.put('codcate',v_data7);
      obj_data.put('desc_codcate', get_tcodec_name('TCODCATE',v_data7, global_v_lang));
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
  --  List of Service type --
  function get_service_type(json_str_input in clob) return clob is
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

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from  tcodserv '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodserv')
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
  function get_mail_alert_number_tr(json_str_input in clob) return clob is
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
                from ttralert '||v_where||
              ' order by mailalno';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('ttralert')
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
  -- List of Generation --
  function get_generation(json_str_input in clob) return clob is
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
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  numclseq, codcours, to_char(dtetrst, ''DD/MM/YYYY''), to_char(dtetren, ''DD/MM/YYYY''),dteyear
                  from  tyrtrsch '||v_where||
                ' order by codcours, numclseq';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tyrtrsch')
           and  column_name = upper('numclseq');
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
      obj_data.put('numclseq',v_data1);
      obj_data.put('codcours',v_data2);
      obj_data.put('desc_codcours',get_tcourse_name(v_data2,global_v_lang));
      obj_data.put('dtetrst',v_data3);
      obj_data.put('dtetren',v_data4);
      obj_data.put('dteyear',v_data5);
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
