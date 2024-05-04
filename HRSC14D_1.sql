--------------------------------------------------------
--  DDL for Package Body HRSC14D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC14D" is

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');
    -- index
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));
    -- index params
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');

-- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
----------------------------------------------------------------------------------------
  procedure check_index is
    v_codapp          tappprof.codapp%type;
  begin
    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from tappprof
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tappprof');
        return;
      end;
    end if;
  end;
----------------------------------------------------------------------------------------
  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------------
  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_flgcreate         varchar2(1 char);

    cursor c_tlogin is
              SELECT t1.lrunning ,
                     t1.luserid ,
                     get_temploy_name((SELECT st1.codempid FROM tusrprof st1 WHERE t1.luserid = st1.coduser), global_v_lang) AS username ,
                     t1.lcodrun AS function_code ,
                     get_tappprof_name(t1.lcodrun,1,global_v_lang) AS function_name ,
                     TO_CHAR(t1.ldtein,'DD/MM/YYYY HH24:MI:SS', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')AS ldtein,
                     TO_CHAR(t1.ldteacc,'DD/MM/YYYY HH24:MI:SS', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')AS ldteacc
              FROM   tlogin t1
              ORDER BY t1.ldtein ;

  begin
    obj_row            := json_object_t();
    for r1 in c_tlogin loop
      v_rcnt             := v_rcnt + 1;
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', p_codapp);
      obj_data.put('lrunning', r1.lrunning);
      obj_data.put('luserid', r1.luserid);
      obj_data.put('username', r1.username);
      obj_data.put('function_code', r1.function_code);
      if r1.function_name like '%'||'********'||'%' then
            obj_data.put('function_name', '');
      else
            obj_data.put('function_name', r1.function_name);
      end if;
    --  obj_data.put('function_name', r1.function_name);
      obj_data.put('ldtein', r1.ldtein);
      obj_data.put('ldteacc', r1.ldteacc);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_timstrt           varchar2(5 char);
    v_timend            varchar2(5 char);
    v_remark            tfunclock.remark%type;
    v_dtestrt           date;
    v_dteend            date;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        p_lrunning         := hcm_util.get_string_t(json_row, 'lrunning');
        if v_flg = 'delete' then
          begin
            delete from tlogin
            where lrunning = p_lrunning;
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

end HRSC14D;

/
