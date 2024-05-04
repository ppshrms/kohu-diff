--------------------------------------------------------
--  DDL for Package Body HRMS12X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS12X" as
--last update 05/09/2017
  procedure initial_value(json_str in clob) is
    json_obj      json_object_t;
  begin
    json_obj           := json_object_t(json_str);
    --global
    global_v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd   := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');
    p_page             := to_number(hcm_util.get_string_t(json_obj,'p_page'));
    p_limit            := to_number(hcm_util.get_string_t(json_obj,'p_limit'));
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_total_index(v_where in varchar2 ,v_total_out out number) is
    v_codempid    varchar2(100 char);
    v_cursor      number;
    v_stmt        varchar2(5000 char);
    v_dummy       integer;
    v_total       number := 0;
  begin
      v_stmt := 'select distinct a.codempid,a.codcomp,a.codpos,a.numlvl,a.email,a.dteempmt'||
                ' from temploy1 a,v_hrms11 b'||
                ' where a.staemp in (''1'',''3'') '||
                ' and '||v_where||
                ' order by a.codempid ';

      v_cursor  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
      v_dummy := dbms_sql.execute(v_cursor);

      while (dbms_sql.fetch_rows(v_cursor) > 0) loop
        v_total := v_total+1;
      end loop;
      v_total_out := v_total;
      dbms_sql.close_cursor(v_cursor);
  end;

  procedure get_path(json_str_input in clob, json_str_output out clob) is
    json_obj      json_object_t := json_object_t(json_str_input);
    v_path        varchar2(1000);
  begin
    initial_value(json_str_input);
    begin
      select  directory_path
      into    v_path
      from    all_directories
      where   directory_name = 'UTL_FILE_DIR';
    exception when no_data_found then
      v_path  := null;
    end;
--    v_path  := replace(replace(v_path,'/','\'),'\','\\');
    v_path  := replace(v_path,'/','\');
    obj_row  := json_object_t();
    begin
      obj_row.put('coderror', '200');
      obj_row.put('desc_coderror', ' ');
      obj_row.put('httpcode', '');
      obj_row.put('flg', '');
      obj_row.put('path',v_path);
    end;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) is
    json_obj      json_object_t := json_object_t(json_str_input);
    v_stmt        varchar2(5000 char);
    v_where       varchar2(4000 char);
    v_cursor      number;
    v_codempid    varchar2(100 char);
    v_codcomp     varchar2(100 char);
    v_codpos      varchar2(100 char);
    v_numlvl      varchar2(100 char);
    v_email       varchar2(200 char);
    v_dteempmt    varchar2(100 char);
    v_dummy       integer;
    v_total       number := 0;
    v_row         number := 0;
    v_flgpass	  boolean;
    v_count       number := 0;
    v_secure	  boolean := false;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();

    v_where  := hcm_util.get_string_t(json_obj, 'p_sql_statement');

    if v_where is not null then
      v_where := ' a.codempid = b.codempid and '||replace(v_where,'V_HRMS11','b');
    else
      v_where := ' a.codempid = b.codempid ';
    end if;

    if v_where like '%NAMFIRSTE%' then
       if  global_v_lang = '102' then
           v_where := replace(v_where,'NAMFIRSTE','NAMFIRSTT') ;
       elsif  global_v_lang = '103' then
           v_where := replace(v_where,'NAMFIRSTE','NAMFIRST3') ;
       elsif  global_v_lang = '104' then
           v_where := replace(v_where,'NAMFIRSTE','NAMFIRST4') ;
       elsif  global_v_lang = '105' then
           v_where := replace(v_where,'NAMFIRSTE','NAMFIRST5') ;
       end if;
    end if;
    if v_where like '%NAMLASTE%' then
       if  global_v_lang = '102' then
           v_where := replace(v_where,'NAMLASTE','NAMLASTT') ;
       elsif  global_v_lang = '103' then
           v_where := replace(v_where,'NAMLASTE','NAMLAST3') ;
       elsif  global_v_lang = '104' then
           v_where := replace(v_where,'NAMLASTE','NAMLAST4') ;
       elsif  global_v_lang = '105' then
           v_where := replace(v_where,'NAMLASTE','NAMLAST5') ;
       end if;
    end if;

    v_stmt := 'select distinct a.codempid,a.codcomp,a.codpos,a.numlvl,a.email,a.dteempmt'||
              ' from temploy1 a,v_hrms11 b'||
              ' where a.staemp in (''1'',''3'') '||
              ' and '||v_where||
              ' order by a.codempid ';
--                ' offset to_number(('||p_page||' - 1) * '||p_limit||') rows fetch next to_number('||p_limit||') rows only';
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    --define column
    dbms_sql.define_column(v_cursor,1,v_codempid,1000);
    dbms_sql.define_column(v_cursor,2,v_codcomp,1000);
    dbms_sql.define_column(v_cursor,3,v_codpos,1000);
    dbms_sql.define_column(v_cursor,4,v_numlvl,1000);
    dbms_sql.define_column(v_cursor,5,v_email,1000);
    dbms_sql.define_column(v_cursor,6,v_dteempmt,1000);

    v_dummy := dbms_sql.execute(v_cursor);
    check_total_index(v_where ,v_total);

    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_codempid);
      dbms_sql.column_value(v_cursor,2,v_codcomp);
      dbms_sql.column_value(v_cursor,3,v_codpos);
      dbms_sql.column_value(v_cursor,4,v_numlvl);
      dbms_sql.column_value(v_cursor,5,v_email);
      dbms_sql.column_value(v_cursor,6,v_dteempmt);
      --CODE HERE
      v_count := v_count +1;
      v_flgpass := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgpass = true then
        v_secure := true;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('rcnt', v_row);
        obj_data.put('codempid',v_codempid);
        obj_data.put('desc_codempid', get_temploy_name(v_codempid,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('numlvl', v_numlvl);
        obj_data.put('email', v_email);
        obj_data.put('dteempmt', v_dteempmt);

        obj_row.put(to_char(v_row-1),obj_data);
      end if;
      --
    end loop; -- end while

    dbms_sql.close_cursor(v_cursor);

    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif v_secure = false then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;


  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure send_email(json_str_input in clob, global_json_str in clob, json_str_output out clob) is
    global_json_obj json_object_t := json_object_t(global_json_str);
    json_obj        json_object_t := json_object_t(json_str_input);
    json_obj2       json_object_t;

    v_subject       varchar2(4000);
    v_msg           varchar2(4000);
    v_temp          varchar2(4000);
    v_sender        varchar2(4000);
    v_name          varchar2(4000);
    v_reciver       varchar2(4000);
    v_email         varchar2(4000);
    v_email_r       varchar2(4000);
    v_codempid_r    varchar2(4000);
    v_empname_r     varchar2(4000);
    v_attach        varchar2(4000);
    v_error         varchar2(4000) ;
    v_num           number := 0;
    v_row           number := 0;
    v_chk_nosend    varchar2(1) := 'N';
    v_flg_noemail   boolean := false;
  begin
    initial_value(global_json_str);
    v_subject := hcm_util.get_string_t(global_json_obj, 'p_subject');
    v_msg     := REPLACE(hcm_util.get_string_t(global_json_obj, 'p_msg'),'<br>');
    v_attach  := hcm_util.get_string_t(global_json_obj, 'p_filename');
    v_sender  := hcm_util.get_string_t(global_json_obj, 'p_codempid_sender');
    if v_sender is not null then
		  begin
				  select  email
				  into    v_email
				  from    temploy1
				  where   codempid = v_sender ;
          v_name  := get_temploy_name(v_sender,global_v_lang);
		  exception when others then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
		  end ;
    else
      v_sender  := hcm_util.get_string_t(global_json_obj, 'p_codcomp_sender');
      v_name    := get_tcenter_name(v_sender,global_v_lang);
      v_email   := null;
    end if ;


    if param_msg_error is null then
        if  v_email is null  then
            v_email := get_tsetup_value('MAILEMAIL');
        end if;
        if v_attach is not null then
--        v_temp := get_tsetup_value('PATHTEMP')||v_attach;
            v_temp := v_attach;
        else
            v_temp := '' ;
        end if ;
        obj_row  := json_object_t();
        for i in 0..json_obj.get_size-1 loop
            json_obj2     := hcm_util.get_json_t(json_obj,to_char(i));
            v_email_r     := hcm_util.get_string_t(json_obj2, 'email');
            v_codempid_r  := hcm_util.get_string_t(json_obj2, 'codempid');
            v_empname_r   := hcm_util.get_string_t(json_obj2, 'desc_codempid');
            v_num := v_num + 1 ;
            if v_email_r is not null then
                begin
                    v_error := sendmail_attachfile(v_email,v_email_r,v_subject,v_msg,v_temp,null,null,null,null) ;
                exception when others then
                    v_chk_nosend  := 'Y';
                    v_row := v_row+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('desc_coderror','HR7526'||' '||get_errorm_name('HR7526',global_v_lang));
                    obj_data.put('httpcode', '');
                    obj_data.put('flg', '');
                    obj_data.put('response', 'HR7526'||' '||get_errorm_name('HR7526',global_v_lang));
                    obj_data.put('total', 'v_total');
                    obj_data.put('rcnt', v_row);
                    obj_data.put('codempid',v_codempid_r);
                    obj_data.put('desc_codempid', v_empname_r);
                    obj_data.put('email', v_email_r);
                    obj_data.put('sender_id', v_sender);
                    obj_data.put('sender_name', v_name);
                    obj_data.put('sender_email', v_email);

                    obj_row.put(to_char(v_row-1),obj_data);
                end;
            else
                v_flg_noemail := true;
            end if;
        end loop;



--      if v_error is not null then
--        if v_error = '7521' then
--          v_error	:= 'HR2046';
--        end if;
--        param_msg_error := get_error_msg_php(v_error,global_v_lang);
--      end if;

        if v_num <= 0 then
            param_msg_error := get_error_msg_php('HR2030',global_v_lang);
        elsif v_num = 1 and v_flg_noemail then
            param_msg_error := get_error_msg_php('MS0001',global_v_lang);
        elsif v_error <> '7521' then
            if length(v_error) = 4 then
                param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
            else
                param_msg_error := get_error_msg_php('HR7522',global_v_lang);
            end if;
        elsif v_chk_nosend = 'N' then
            param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            json_str_output  := get_response_message(200,param_msg_error,global_v_lang);
            return;
        end if ;
    end if;

    if param_msg_error is not null then
      json_str_output  := get_response_message(400,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
      json_str_output := replace(json_str_output,'v_total',v_row);
    end if;
  exception when others then
    if sqlerrm like '%ORA-29279%' then
      param_msg_error := get_error_msg_php('HR7522',global_v_lang);
    else
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end if;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

END HRMS12X;

/
