--------------------------------------------------------
--  DDL for Package Body HCM_LOV_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_AL" is
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
      dbms_output.put_line(hcm_lov_al.get_shift(v_in));
    end;
  ############################## */


function get_codec(p_table in varchar2, p_where in varchar2, p_code_name in varchar2 default 'codcodec', p_desc_name in varchar2 default 'descod') return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt       varchar2(5000 char);
    v_data1       varchar2(5000 char);
    v_data2       varchar2(5000 char);
    v_data3       varchar2(5000 char);
    v_data4       varchar2(5000 char);
    v_data5       varchar2(5000 char);
    v_data6       varchar2(5000 char);
    v_data7       varchar2(4000 char);

  begin
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if p_where is not null then
      v_where := ' where ' || p_where;
    end if;

    v_stmt := 'select codcodec,descode,descodt,descod3,descod4,descod5,flgact
                 from '||p_table||v_where||
               ' order by codcodec';

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

  -- codshift --
  function get_shift(json_str_input in clob) return clob is
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_row               number  := 0;
    v_where             varchar2(5000 char);
    v_stmt			    varchar2(5000 char);
    v_data1			    varchar2(5000 char);
    v_data2			    varchar2(5000 char);
    v_data3			    varchar2(5000 char);
    v_data4			    varchar2(5000 char);
    v_data5			    varchar2(5000 char);
    v_data6			    varchar2(5000 char);
    v_data7			    varchar2(5000 char);
    v_data8			    varchar2(5000 char);
    v_length            number := 0;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = 'TSHIFTCD'
           and  column_name = 'CODSHIFT';
    exception when others then
        v_length := 0;
    end;
    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codshift,desshifte,desshiftt,desshift3,desshift4,desshift5,timstrtw,timendw
                from tshiftcd '||v_where||
              ' order by codshift';

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
      obj_data.put('codshift',v_data1);
      obj_data.put('desshifte',v_data2);
      obj_data.put('desshiftt',v_data3);
      obj_data.put('desshift3',v_data4);
      obj_data.put('desshift4',v_data5);
      obj_data.put('desshift5',v_data6);
      obj_data.put('schedule',substr(v_data7,1,2)||':'||substr(v_data7,3,2)||'-'||substr(v_data8,1,2)||':'||substr(v_data8,3,2));
      obj_data.put('max',to_char(v_length));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while

    json_str_output := obj_row.to_clob;
    return json_str_output;

  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
    return json_str_output;
  end;

   -- codleave --
  function get_leave(json_str_input in clob) return clob is
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
--		v_data7			    varchar2(5000 char);
--    v_data8			    varchar2(5000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select codleave,namleavcde,namleavcdt,namleavcd3,namleavcd4,namleavcd5
                from tleavecd '||v_where||
              ' order by codleave, typleave';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tleavecd')
           and  column_name = upper('codleave');
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
--    dbms_sql.define_column(v_cursor,7,v_data7,1000);
--    dbms_sql.define_column(v_cursor,8,v_data8,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_data1);
      dbms_sql.column_value(v_cursor,2,v_data2);
      dbms_sql.column_value(v_cursor,3,v_data3);
      dbms_sql.column_value(v_cursor,4,v_data4);
      dbms_sql.column_value(v_cursor,5,v_data5);
      dbms_sql.column_value(v_cursor,6,v_data6);
--      dbms_sql.column_value(v_cursor,7,v_data7);
--      dbms_sql.column_value(v_cursor,8,v_data8);

      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('codleave',v_data1);
      obj_data.put('namleavcde',v_data2);
      obj_data.put('namleavcdt',v_data3);
      obj_data.put('namleavcd3',v_data4);
      obj_data.put('namleavcd4',v_data5);
      obj_data.put('namleavcd5',v_data6);
--      obj_data.put('schedule',substr(v_data7,1,2)||':'||substr(v_data7,3,2)||'-'||substr(v_data8,1,2)||':'||substr(v_data8,3,2));
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

  -- typeleave --
  function get_type_leave(json_str_input in clob) return clob is
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

    v_stmt := ' select typleave,namleavtye,namleavtyt,namleavty3,namleavty4,namleavty5
                from tleavety '||v_where||
              ' order by typleave';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tleavety')
           and  column_name = upper('typleave');
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
      obj_data.put('typleave',v_data1);
      obj_data.put('namleavtye',v_data2);
      obj_data.put('namleavtyt',v_data3);
      obj_data.put('namleavty3',v_data4);
      obj_data.put('namleavty4',v_data5);
      obj_data.put('namleavty5',v_data6);
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

 -- codroom --
 function get_meeting_room(json_str_input in clob) return clob is
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

    v_stmt := ' select roomno,roomname,roomnamt,roomnam3,roomnam4,roomnam5
                from tcodroom '||v_where||
              ' order by roomno';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodroom')
           and  column_name = upper('roomno');
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
      obj_data.put('roomno',v_data1);
      obj_data.put('roomname',v_data2);
      obj_data.put('roomnamt',v_data3);
      obj_data.put('roomnam3',v_data4);
      obj_data.put('roomnam4',v_data5);
      obj_data.put('roomnam5',v_data6);
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

 -- number ot request --
 function get_numotreq(json_str_input in clob) return clob is
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
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    else
      v_where := 'where DTEREQ between ''' || add_months(trunc(sysdate), -12) ||''' and ''' || (add_months(trunc (sysdate, 'YEAR'), 12) - 1) ||''' ';   
    end if;

    v_stmt := ' select numotreq,codempid,codcomp,codcalen
                from totreqst '||v_where||
              ' order by numotreq';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('totreqst')
           and  column_name = upper('numotreq');
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
      obj_data.put('numotreq',v_data1);
      obj_data.put('namemp', get_temploy_name(v_data2,global_v_lang));
      obj_data.put('namcent',get_tcenter_name(v_data3,global_v_lang));
      obj_data.put('namcalen',get_tcodec_name('TCODWORK',v_data4,global_v_lang));
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

   -- leave request --
  function get_leave_request(json_str_input in clob) return clob is
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
      v_where := ' where ' || param_where;
    else
      v_where := 'where DTEREQ between ''' || add_months(trunc(sysdate), -12) ||''' and ''' || (add_months(trunc (sysdate, 'YEAR'), 12) - 1) ||''' ';   
    end if;

    v_stmt := ' select  numlereq,codempid
                  from  tlereqst '||v_where||
                ' order by numlereq';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tlereqst')
           and  column_name = upper('numlereq');
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
      obj_data.put('numlereq',v_data1);
      obj_data.put('desc_codempid',get_temploy_name(v_data2,global_v_lang));
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
  -- leave request group --
  function get_leave_request_group(json_str_input in clob) return clob is
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
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    if param_where is not null then
      v_where := 'where '||param_where;
    end if;

    v_stmt := ' select numlereqg, codempid, codcomp, codcalen
                from tlereqg '||v_where||
              ' order by numlereqg';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tlereqg')
           and  column_name = upper('numlereqg');
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
      obj_data.put('numlereqg',v_data1);
      obj_data.put('desc_codempid',get_temploy_name(v_data1,global_v_lang));
      obj_data.put('desc_codcomp',get_tcenter_name(v_data3,global_v_lang));
      obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',v_data4,global_v_lang));
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
  -- List Shift of Flexible Group --
  function get_shift_flexible_group(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number  := 0;
    v_where         varchar2(5000 char);
    v_stmt			varchar2(5000 char);
    v_data1			varchar2(5000 char);
    v_data2			varchar2(5000 char);
    v_data3			varchar2(5000 char);
    v_data4			varchar2(5000 char);
    v_data5			varchar2(5000 char);
    v_data6			varchar2(5000 char);
    v_data7			varchar2(4000 char);
    v_length        number;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

--    v_where := ' where nvl(flgact,''1'') = ''1'' ';
    if param_where is not null then
      v_where := ' where ' || param_where;
    end if;

    v_stmt := ' select  codcodec, descode, descodt, descod3, descod4, descod5, flgact
                  from  tcodflex '||v_where||
                ' order by codcodec';
    begin
        select  char_length
          into  v_length
          from  user_tab_columns
         where  table_name  = upper('tcodflex')
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
end;

/
