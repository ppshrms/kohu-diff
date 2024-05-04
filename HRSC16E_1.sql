--------------------------------------------------------
--  DDL for Package Body HRSC16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC16E" is
-- last update: 12/11/2018 21:12
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    -- index
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'codcomp'));
    p_coduser           := upper(hcm_util.get_string_t(json_obj, 'coduser'));
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'codempid'));
    p_typeuser          := upper(hcm_util.get_string_t(json_obj, 'typeuser'));
    p_flgact            := upper(hcm_util.get_string_t(json_obj, 'flgact'));
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    null;
  end;

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

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_exist             boolean := false;
    v_flgsecu           boolean := false;

    cursor c_tusrprof is
      select a.coduser, a.codempid, a.typeuser, a.flgact, a.rcupdid, a.dteupd
        from tusrprof a, temploy1 b
       where a.codempid = b.codempid
         and b.codcomp like p_codcomp || '%'
         and a.coduser = nvl(p_coduser, a.coduser)
         and a.codempid = nvl(p_codempid, a.codempid)
         and a.typeuser like nvl(p_typeuser, a.typeuser)
         and a.flgact like nvl(p_flgact, a.flgact)
         and a.flgact in ('1', '3') --- Status User 1-ปัจจุบัน, 2-ลาออก,3-ระงับใช้
       order by a.coduser;

  begin
    obj_row            := json_object_t();
    for r1 in c_tusrprof loop
      v_exist   := true;
      v_flgsecu := false;
      v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        v_rcnt             := v_rcnt + 1;
        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('coduser', r1.coduser);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('typeuser', r1.typeuser);
        obj_data.put('desc_typeuser', get_tlistval_name('TYPEUSER', r1.typeuser, global_v_lang));
        obj_data.put('flgact', r1.flgact);
        obj_data.put('desc_flgact', get_tlistval_name('USRSTA', r1.flgact, global_v_lang));
        obj_data.put('rcupdid', r1.rcupdid);
        obj_data.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_exist then
      if obj_row.get_size > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error   := get_error_msg_php('HR3007', global_v_lang);
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'tusrprof');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    flgEdit             boolean := false;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        flgEdit           := hcm_util.get_boolean_t(json_row,'flgEdit');
        p_coduser         := hcm_util.get_string_t(json_row, 'coduser');
        p_flgact          := hcm_util.get_string_t(json_row, 'flgact');
        if flgEdit  then
          begin
            update tusrprof
               set flgact  = p_flgact,
                   dteupd  = sysdate,
                   rcupdid = global_v_coduser
             where coduser = p_coduser;
          exception when others then
              null;
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
end HRSC16E;

/
