--------------------------------------------------------
--  DDL for Package Body HCM_LOV_ALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_ALL" is
/* Cust-Modify: KOHU-HR2301 */
-- last update: 07/08/2023 15:22

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
  function get_codec(p_table in varchar2, p_where in varchar2, p_code_name in varchar2 default 'codcodec', p_desc_name in varchar2 default 'descod') return clob is
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
    v_data7         varchar2(4000 char);
    v_length        number;
  begin
    obj_row := json_object_t();

    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if p_where is not null then
      v_where := v_where || ' and(' || p_where || ')';
    end if;

    v_stmt := 'select codcodec,descode,descodt,descod3,descod4,descod5,flgact
                 from '||p_table||v_where||
               ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper(p_table)
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
      obj_data.put(p_code_name,v_data1);
      obj_data.put(p_desc_name||'e',v_data2);
      obj_data.put(p_desc_name||'t',v_data3);
      obj_data.put(p_desc_name||'3',v_data4);
      obj_data.put(p_desc_name||'4',v_data5);
      obj_data.put(p_desc_name||'5',v_data6);
      obj_data.put('flgact',v_data7);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;


  /* ######### Example #########
    set serveroutput on
    declare
      v_in  clob := '{"p_coduser":"TJS00001", "p_lang":"101", "p_where":"rownum <= 2"}';
    begin
      dbms_output.put_line(hcm_lov_all.get_punishment(v_in));
    end;
  ############################## */

  --Punishment --
  function get_punishment(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodpunh', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  END;

  --Employee Resign --
  function get_resign(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodexem', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
--
--  --Emp Movement --
--  function get_emp_movement(json_str_input in clob) return clob is
--    obj_data        json_object_t;
--    json_str_output clob;
--  begin
--    initial_value(json_str_input);
--    return get_codec('tcodmove', param_where);
--  exception when others then
--    obj_data := json_object_t();
--    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
--    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
--    json_str_output := obj_data.to_clob;
--    return json_str_output;
--  end;

   --LOV for List of Emp Movement
  function get_emp_movement(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			varchar2(5000 char);
    v_data1			varchar2(5000 char);
    v_data2		    varchar2(5000 char);
    v_data3			varchar2(5000 char);
    v_data4			varchar2(5000 char);
    v_data5			varchar2(5000 char);
    v_data6			varchar2(5000 char);
    v_data7			varchar2(5000 char);
    v_data8			varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := 'select codcodec,descode,descodt,descod3,descod4,descod5,typmove,flgact
                 from tcodmove '||v_where||
               'order by codcodec';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodmove')
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

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codcodec',v_data1);
      obj_data.put('descode',v_data2);
      obj_data.put('descodt',v_data3);
      obj_data.put('descod3',v_data4);
      obj_data.put('descod4',v_data5);
      obj_data.put('descod5',v_data6);
      obj_data.put('typmove',v_data7);
      obj_data.put('flgact',v_data8);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- Position
  function get_position(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
		v_stmt			    varchar2(5000 char);
		v_data1			    varchar2(5000 char);
		v_data2			    varchar2(5000 char);
		v_data3			    varchar2(5000 char);
		v_data4			    varchar2(5000 char);
		v_data5			    varchar2(5000 char);
		v_data6			    varchar2(5000 char);
		v_data7			    varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codpos, nampose, nampost, nampos3, nampos4, nampos5
                from tpostn '||v_where||
              ' order by codpos';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tpostn')
           and  column_name = upper('codpos');
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
      obj_data.put('codpos',v_data1);
      obj_data.put('nampose',v_data2);
      obj_data.put('nampost',v_data3);
      obj_data.put('nampos3',v_data4);
      obj_data.put('nampos4',v_data5);
      obj_data.put('nampos5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Job Description --
  function get_job_description(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
		v_stmt			    varchar2(5000 char);
		v_data1			    varchar2(5000 char);
		v_data2			    varchar2(5000 char);
		v_data3			    varchar2(5000 char);
		v_data4			    varchar2(5000 char);
		v_data5			    varchar2(5000 char);
		v_data6			    varchar2(5000 char);
		v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codjob,namjobe,namjobt,namjob3,namjob4,namjob5
                from tjobcode '||v_where||
              ' order by codjob';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tjobcode')
           and  column_name = upper('codjob');
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
      obj_data.put('codjob',v_data1);
      obj_data.put('namjobe',v_data2);
      obj_data.put('namjobt',v_data3);
      obj_data.put('namjob3',v_data4);
      obj_data.put('namjob4',v_data5);
      obj_data.put('namjob5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Employment Type --
  function get_emp_type(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodempl', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Employee Category --
  function get_emp_category(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodcatg', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Emp typpayroll --
  function get_emp_typpayroll(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodtypy', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    RETURN json_str_output;
  end;

  --Branch Location --
  function get_branch_location(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodloca', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Working Group --
  function get_work_group(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodwork', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --Job Grade --
  function get_jobgrade(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodjobg', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --GL Group --
  function get_glgroup(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodgrpgl', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --currency--
  function get_currency(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodcurr', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --

  -- codcompy
  function get_codcompy(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;
    if param_flg_secur = 'Y' then
      v_where := nvl(v_where, 'where ') || ' 0 <> (select count(ts.codcomp)
                                         from tusrcom ts
                                        where ts.coduser = '''||global_v_coduser||'''
                                          and ts.codcomp like tcompny.codcompy || ''%''
                                          and rownum <= 1)';
    end if;

    v_stmt := ' select codcompy, namcome, namcomt, namcom3, namcom4, namcom5
                from tcompny '||v_where||
              ' order by codcompy';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcompny')
           and  column_name = upper('codcompy');
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
      obj_data.put('codcompy',v_data1);
      obj_data.put('namcome',v_data2);
      obj_data.put('namcomt',v_data3);
      obj_data.put('namcom3',v_data4);
      obj_data.put('namcom4',v_data5);
      obj_data.put('namcom5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;
  ------

   --Diligence Allowance --a??a?sa??a??a??a??a??a??a??
  function get_diligence_allowance(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodawrd', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --Reason of Change Time Stamp --a??a?<a??a??a??a?Ya??a??a?#a??a??a??a??a??a??a??a?Ya??a??a??a??a??-a?-a?-a??
  function get_change_time_stamp(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodtime', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --O.T Request Reason --a??a??a??a?<a??a??a??a??a?#a??a?-
  function get_ot_request_reason(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodotrq', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --Appraise Group --a??a?Ya??a??a?!a??a??a?#a??a?#a??a??a?!a?'a??
  function get_appraise_group(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodaplv', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --LOV for Asset --a??a?#a??a?za??a??a??a?'a??a??a?-a??a?sa?#a?'a??a??a??
  function get_asset(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codasset, desassee, desasset, desasse3, desasse4, desasse5, typasset
                  from tasetinf '||v_where||
                ' order by codasset';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tasetinf')
           and  column_name = upper('codasset');
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
      obj_data.put('typasset',get_tcodec_name('tcodasst' ,v_data7 ,global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for Province --a??a??a??a?<a??a??a??
  function get_province(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodprov', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --LOV for Educate Level --a?#a??a??a??a?sa??a??a??a?'a??a??a?#a??a??a??a??a??
  function get_educate_level(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodeduc', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --LOV for Institute Code --a??a??a??a?sa??a??
  function get_institute(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodinst', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;

  --LOV for Skill --a??a??a??a?!a??a??a?!a??a?#a??/a??a?#a??a??a?sa??a??a?#a??a??/a??a??a??a?!a?Sa??a??a??a??
--  function get_skill(json_str_input in clob) return clob is
--    obj_data        json_object_t;
--    json_str_output clob;
--  begin
--    initial_value(json_str_input);
--    return get_codec('tcodskil', param_where);
--  exception when others then
--    obj_data := json_object_t();
--    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
--    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
--    json_str_output := obj_data.to_clob;
--    return JSON_STR_OUTPUT;
--  END;
  function get_skill(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := 'select codcodec,descode,descodt,descod3,descod4,descod5,
                      codtency
                 from tcodskil, tcompskil
                where codcodec = codskill(+) '||v_where||
               'and nvl(tcodskil.flgact,''1'') = ''1''
                order by codcodec';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodskil')
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
      obj_data.put('max',to_char(v_length));
      obj_data.put('typtency',v_data7);
      if v_data7 is null then
        obj_data.put('desc_typtency','N/A');
      else
        obj_data.put('desc_typtency',get_tcomptnc_name(v_data7,global_v_lang));
      end if;
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  --LOV for Application Information ---a??a??a?-a?!a??a?Ya??a??a?#a??a?!a??a??a?#
  function get_application_information(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select numappl,
                       get_tapplinf_name(numappl,''101'') desce,
                       get_tapplinf_name(numappl,''102'') desct,
                       get_tapplinf_name(numappl,''103'') desc3,
                       get_tapplinf_name(numappl,''104'') desc4,
                       get_tapplinf_name(numappl,''105'') desc5 ,
                       statappl,
                       get_tlistval_name(''STATAPPL'', statappl, '||global_v_lang||') desc_statappl
                from tapplinf '||v_where||
              ' order by numappl';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tapplinf')
           and  column_name = upper('numappl');
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

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numappl',v_data1);
      obj_data.put('desapple',v_data2);
      obj_data.put('desapplt',v_data3);
      obj_data.put('desappl3',v_data4);
      obj_data.put('desappl4',v_data5);
      obj_data.put('desappl5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_data.put('desc_statappl',v_data8);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

  --Employee Master File (1)
  function get_emp_all(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
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
                where staemp like ''%'' '||v_where||
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
      obj_data.put('max',to_char(v_length));
      obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_data7,global_v_lang));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_type_emp_all(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
		v_stmt			    varchar2(5000 char);
		v_data1			    varchar2(5000 char);
		v_data2			    varchar2(5000 char);
		v_data3			    varchar2(5000 char);
		v_data4			    varchar2(5000 char);
		v_data5			    varchar2(5000 char);
		v_data6			    varchar2(5000 char);
		v_data7			    varchar2(5000 char);
		v_data8			    varchar2(5000 char);
		v_data9			    varchar2(5000 char);
		v_data10			  varchar2(5000 char);
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

    v_stmt := 'select       emp1.codempid,emp1.namempe,emp1.namempt,emp1.namemp3,emp1.namemp4,emp1.namemp5,emp1.staemp, emp2.numoffid, emp1.codcomp, emp1.codpos
                 from       temploy1 emp1
                 inner join temploy2 emp2
                            on emp1.codempid = emp2.codempid
                 where      emp1.staemp like ''%'' '||v_where||
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
                                  nvl(v_data9, ' '),
                                  nvl(get_tcenter_name(v_data9,global_v_lang), ' '),
                                  nvl(v_data10, ' '),
                                  nvl(get_tpostn_name(v_data10,global_v_lang), ' ')
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm||param_where,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;

  function get_evaluation_score(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
--    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select grdno, grditem, achieve, qtyscor
                  from tkpiites '||v_where||
              ' order by grdno';

--    begin
--        select  char_length
--          into  v_length
--          from  user_tab_columns
--         where  table_name  = upper('tkpiites')
--           and  column_name = upper('codcodec');
--    exception when others then
--        v_length := 0;
--    end;
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
      obj_data.put('grdscor',v_data1);
      obj_data.put('grditem',v_data2);
      obj_data.put('achieve',v_data3);
      obj_data.put('qtyscor',v_data4);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

  function get_function_type(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

  function get_menu_link_approve(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select codapp,desappe,desappt,desapp3,desapp4,desapp5
                from tappprof
                where codapp <> ''HRES3BE'' ' ||v_where||
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;

  --LOV for Provident Fund Compensation
  function get_provident_fund_compn(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodplcy', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for District
  function get_district(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select  coddist,namdiste,namdistt,namdist3,namdist4,namdist5,
                        codprov,codpost
                from    tcoddist
                where   ''1'' = ''1'' ' ||v_where||
              ' order by coddist';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcoddist')
           and  column_name = upper('coddist');
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

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coddist',v_data1);
      obj_data.put('namdiste',v_data2);
      obj_data.put('namdistt',v_data3);
      obj_data.put('namdist3',v_data4);
      obj_data.put('namdist4',v_data5);
      obj_data.put('namdist5',v_data6);
      obj_data.put('codprov',v_data7);
      obj_data.put('codpost',v_data8);
      obj_data.put('desc_codprov',get_tcodec_name('TCODPROV',v_data7,global_v_lang));
      obj_data.put('filter',v_data7);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Sub District
  function get_sub_district(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_data9			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select  codsubdist,namsubdiste,namsubdistt,namsubdist3,namsubdist4,namsubdist5,
                        coddist,codprov,codpost
                from    tsubdist
                where   ''1'' = ''1'' ' ||v_where||
              ' order by codsubdist';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsubdist')
           and  column_name = upper('codsubdist');
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
      obj_data.put('codsubdist',v_data1);
      obj_data.put('namsubdiste',v_data2);
      obj_data.put('namsubdistt',v_data3);
      obj_data.put('namsubdist3',v_data4);
      obj_data.put('namsubdist4',v_data5);
      obj_data.put('namsubdist5',v_data6);
      obj_data.put('coddist',v_data7);
      obj_data.put('desc_coddist',get_tcoddist_name(v_data7,global_v_lang));
      obj_data.put('codprov',v_data8);
      obj_data.put('desc_codprov',get_tcodec_name('TCODPROV',v_data8,global_v_lang));
      obj_data.put('codpost',v_data9);
      obj_data.put('filter',v_data7||v_data8);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  END;

  function get_type_sub_district(json_str_input in clob) return T_LOV is
    obj_row         T_LOV := T_LOV();

    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_data9			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select  codsubdist,namsubdiste,namsubdistt,namsubdist3,namsubdist4,namsubdist5,
                        coddist,codprov,codpost
                from    tsubdist
                where   ''1'' = ''1'' ' ||v_where||
              ' order by codsubdist';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsubdist')
           and  column_name = upper('codsubdist');
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

      obj_row.extend;
      obj_row(obj_row.last) := TYPE_LOV(
                                  '200', ' ',
                                  nvl(to_char(v_length), ' '),
                                  nvl(v_data1, ' '),
                                  nvl(v_data2, ' '),
                                  nvl(v_data3, ' '),
                                  nvl(v_data4, ' '),
                                  nvl(v_data5, ' '),
                                  nvl(v_data6, ' '),
                                  nvl(v_data7, ' '),
                                  nvl(get_tcoddist_name(v_data7,global_v_lang), ' '),
                                  nvl(v_data8, ' '),
                                  nvl(get_tcodec_name('TCODPROV',v_data8,global_v_lang), ' '),
                                  nvl(v_data7||v_data8, ' '),
                                  nvl(v_data9, ' ')
                               );
    end loop; -- end while

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',sqlerrm,
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ');
    return obj_row;
  END;

  --LOV for Country
  function get_country(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodcnty', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Disabled
  function get_disabled(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcoddisp', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Race
  function get_race(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodregn', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Religion
  function get_religion(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodreli', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Nationality
  function get_nationality(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodnatn', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Bank
  function get_bank(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodbank', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Degree
  function get_degree(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcoddgee', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Education Major
  function get_education_major(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodmajr', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Education minor
  function get_education_minor(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodsubj', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Occupation
  function get_occupation(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodoccu', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Collateral
  function get_collateral(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodcola', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Reward
  function get_reward(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodrewd', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Type Document
  function get_type_document(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodtydoc', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  -- LOV for Mail Alert Number
  function get_mail_alert_number(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select mailalno, subject
                from talalert '||v_where||
              ' order by mailalno';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('talalert')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for Bus No.
  function get_bus_no(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodbusno', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Bus Route.
  function get_bus_route(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodbusrt', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  --LOV for Type of Resignment
  function get_type_of_resignment(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodretm', param_where,'typretmt','destypretmt');
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  -- LOV Work Process
  function get_process(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codproc, desproce, desproct, desproc3, desproc4, desproc5
                from tprocess '||v_where||
              ' order by codproc';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tprocess')
           and  column_name = upper('codproc');
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
      obj_data.put('codproc',v_data1);
      obj_data.put('desproce',v_data2);
      obj_data.put('desproct',v_data3);
      obj_data.put('desproc3',v_data4);
      obj_data.put('desproc4',v_data5);
      obj_data.put('desproc5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
    -- LOV Company Group
  function get_company_group(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select codcodec, descode, descodt, descod3, descod4, descod5, flgact
                from tcompgrp '||v_where||
              ' order by codcodec';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcompgrp')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
-- LOV Report Names
  function get_report_names(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_length        number;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    v_where := ' where codrep <> ''TEMP'' ';
    if param_where is not null then
      v_where := v_where|| ' and ' || param_where;
    end if;

    v_stmt := ' select codrep, descode, descodt, descod3, descod4, descod5, codapp, typcode
                from tinitregh '||v_where||
              ' order by codrep';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tinitregh')
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

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codrep',v_data1);
      obj_data.put('descode',v_data2);
      obj_data.put('descodt',v_data3);
      obj_data.put('descod3',v_data4);
      obj_data.put('descod4',v_data5);
      obj_data.put('descod5',v_data6);
      obj_data.put('filter',v_data7);
      obj_data.put('typcode',v_data8);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  function get_revenue_report(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodrevn', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for Lang Ability.
  function get_lang(json_str_input in clob) return clob is
    obj_data        json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    return get_codec('tcodlang', param_where);
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  END;
  -- LOV for Mistake Code --
  function get_mistake(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodmist '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodmist')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for Movement Type --
  function get_movement_type(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    param_where := 'codcodec not in ('''||'0001'||''','''||'0002'||''','''||'0003'||''','''||'0004'||''','''||'0005'||''','''||'0006'||''','''||'0007'')';
    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodmove '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodmove')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for Investment Plan Codes --
  function get_investment_plan(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodpfpln '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodpfpln')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  -- LOV for List Table Name --
  function get_list_table_name(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    v_where := 'where codtable not like ''BIN%''';
    if param_where is not null then
      v_where := v_where||' and ('||param_where||')';
    end if;

    v_stmt := ' select  codtable, destabe, destabt, destab3, destab4, destab5
                  from ttabdesc '||v_where||
                ' order by codtable';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('ttabdesc')
           and  column_name = upper('codtable');
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
      obj_data.put('codtable',v_data1);
      obj_data.put('destabe',v_data2);
      obj_data.put('destabt',v_data3);
      obj_data.put('destab3',v_data4);
      obj_data.put('destab4',v_data5);
      obj_data.put('destab5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  -- LOV for Type of Certificate for Taxes --
  function get_certificate_taxes(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodcert '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodcert')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  -- LOV for List of Income/Deduct Code --
  function get_payslip(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodslip '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodslip')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  -- LOV for List of User Name --
  function get_list_user_name(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := 'select a.coduser, b.namempe, b.namempt, b.namemp3, b.namemp4, b.namemp5
                  from tusrprof a, temploy1 b
                 where a.codempid = b.codempid
                   and a.coduser is not null '
                   || v_where ||
              ' order by coduser';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tusrprof')
           and  column_name = upper('coduser');
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
      obj_data.put('coduser',v_data1);
      obj_data.put('namempe',v_data2);
      obj_data.put('namempt',v_data3);
      obj_data.put('namemp3',v_data4);
      obj_data.put('namemp4',v_data5);
      obj_data.put('namemp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
    -- LOV for List of Security Group --
  function get_security_group(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codsecu, namsecue, namsecut, namsecu3, namsecu4, namsecu5
                  from tsecurh '||v_where||
                ' order by codsecu';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsecurh')
           and  column_name = upper('codsecu');
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
      obj_data.put('codsecu',v_data1);
      obj_data.put('namsecue',v_data2);
      obj_data.put('namsecut',v_data3);
      obj_data.put('namsecu3',v_data4);
      obj_data.put('namsecu4',v_data5);
      obj_data.put('namsecu5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Application Name --
  function get_application_work_process(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codapp, desappe, desappt, desapp3, desapp4, desapp5
                  from tprocapp '||v_where||
                ' order by codapp';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tprocapp')
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
      obj_data.put('desappe',v_data2);
      obj_data.put('desappt',v_data3);
      obj_data.put('desapp3',v_data4);
      obj_data.put('desapp4',v_data5);
      obj_data.put('desapp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Type Code--
  function get_type_code(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  typcode, destype, destypt, destyp3, destyp4, destyp5
                  from ttypcode '||v_where||
                ' order by typcode';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('ttypcode')
           and  column_name = upper('typcode');
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
      obj_data.put('typcode',v_data1);
      obj_data.put('destype',v_data2);
      obj_data.put('destypt',v_data3);
      obj_data.put('destyp3',v_data4);
      obj_data.put('destyp4',v_data5);
      obj_data.put('destyp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Type Code m_hrpmz1e | apisit add 12/06/2023 --
  function get_type_code_m_hrpmz1e(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;
    v_stmt := ' select  typcode, destype, destypt, destyp3, destyp4, destyp5
                  from ttypecode '||v_where||
                ' order by typcode';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('ttypcode')
           and  column_name = upper('typcode');
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
      obj_data.put('ttypcode',v_data1);
      obj_data.put('destype',v_data2);
      obj_data.put('destypt',v_data3);
      obj_data.put('destyp3',v_data4);
      obj_data.put('destyp4',v_data5);
      obj_data.put('destyp5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

  -- LOV for List of Type of Competency--
  function get_type_competency(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  codtency, namtncye, namtncyt, namtncy3, namtncy4, namtncy5
                  from tcomptnc '||v_where||
                ' order by codtency';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcomptnc')
           and  column_name = upper('codtency');
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
      obj_data.put('codtency',v_data1);
      obj_data.put('namtncye',v_data2);
      obj_data.put('namtncyt',v_data3);
      obj_data.put('namtncy3',v_data4);
      obj_data.put('namtncy4',v_data5);
      obj_data.put('namtncy5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Table Name--
  function get_table_name(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			varchar2(5000 char);
    v_data1			varchar2(5000 char);
    v_data2			varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select table_name, comments
                  from user_tab_comments
                  where (table_type = ''TABLE''
                  or table_type = ''VIEW'')
                  and table_name like ''T%'' '
                  ||v_where||
                ' order by table_name';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('user_tab_comments')
           and  column_name = upper('table_name');
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
      obj_data.put('table_name',v_data1);
      obj_data.put('comments', get_ttabdesc_name(v_data1, global_v_lang));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Unit --
  function get_unit(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodunit '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodunit')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Size --
  function get_size(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
		v_stmt			    varchar2(5000 char);
		v_data1			    varchar2(5000 char);
		v_data2			    varchar2(5000 char);
		v_data3			    varchar2(5000 char);
		v_data4			    varchar2(5000 char);
		v_data5			    varchar2(5000 char);
		v_data6			    varchar2(5000 char);
		v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodsize '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodsize')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  -- LOV for List of Travel Cost --
  function get_travel_cost(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodexp '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodexp')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for List of Deduction Code
  function get_payslip_deduction(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from tcodslip '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodslip')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for List of Company Level
  function get_company_level(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select  to_char(numseq)
                  from tsetcomp '||v_where||
                ' order by numseq';
    /*begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tsetcomp')
           and  column_name = upper('numseq');
    exception when others then
        v_length := 0;
    end;*/
    v_length := 2;

    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_data1,1000);
    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('complvl',v_data1);
      if v_data1 = '1' then
        obj_data.put('desccomplvle',get_label_name('SCRLABEL','101',2250));
        obj_data.put('desccomplvlt',get_label_name('SCRLABEL','102',2250));
        obj_data.put('desccomplvl3',get_label_name('SCRLABEL','103',2250));
        obj_data.put('desccomplvl4',get_label_name('SCRLABEL','104',2250));
        obj_data.put('desccomplvl5',get_label_name('SCRLABEL','105',2250));
      else
        obj_data.put('desccomplvle',get_label_name('SCRLABEL','101',2490)||' '||v_data1);
        obj_data.put('desccomplvlt',get_label_name('SCRLABEL','102',2490)||' '||v_data1);
        obj_data.put('desccomplvl3',get_label_name('SCRLABEL','103',2490)||' '||v_data1);
        obj_data.put('desccomplvl4',get_label_name('SCRLABEL','104',2490)||' '||v_data1);
        obj_data.put('desccomplvl5',get_label_name('SCRLABEL','105',2490)||' '||v_data1);
      end if;
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
   --LOV for List of Code Skill
  function get_skill_code(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := 'select codcodec,descode,descodt,descod3,descod4,descod5,flgact
                 from tcodskil '||v_where||
               'order by codcodec';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodskil')
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

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
  --LOV for Menu link to approve
  function get_menu_link_approve_typ_form(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := ' select codapp,desappe,desappt,desapp3,desapp4,desapp5
                from tappprof
                where typform = ''U'' ' ||v_where||
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
      obj_data.put('codappt',v_data1);
      obj_data.put('descodappte',v_data2);
      obj_data.put('descodapptt',v_data3);
      obj_data.put('descodappt3',v_data4);
      obj_data.put('descodappt4',v_data5);
      obj_data.put('descodappt5',v_data6);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return JSON_STR_OUTPUT;
  end;
  --LOV for List of Securities Code
  function get_securities_code(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char) := ' where 1 = 1 ';
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := v_where||' and '||param_where;
    end if;

    v_stmt := 'select numcolla,descoll
                 from tcolltrl '||v_where||
               'order by numcolla';

    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcolltrl')
           and  column_name = upper('numcolla');
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
      obj_data.put('numcolla',v_data1);
      obj_data.put('descoll',v_data2);
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output   := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;
end;

/
