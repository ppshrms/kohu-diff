--------------------------------------------------------
--  DDL for Package Body HRSC17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC17E" is
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
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_module            := upper(hcm_util.get_string_t(json_obj, 'p_module'));
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

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

    cursor c_tfunclock is
      select codapp, dtestrt, timstrt, dteend, timend, remark, dteupd, coduser
        from tfunclock
       where codapp = nvl(p_codapp, codapp)
         and ( substr(codapp, 3, 2) like p_module
               or p_module is null
             )
         and (
              dtestrt between p_dtestrt and p_dteend or
              dteend between p_dtestrt and p_dteend or
              p_dtestrt between dtestrt and dteend or
              p_dteend between dtestrt and dteend
              )
       order by codapp,dtestrt, timstrt, dteend, timend;

  begin
    obj_row            := json_object_t();
    for r1 in c_tfunclock loop
      v_rcnt             := v_rcnt + 1;
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_data.put('dtestrt', to_char(r1.dtestrt, 'dd/mm/yyyy') || ' ' || substr(r1.timstrt, 1, 2) || ':' || substr(r1.timstrt, 3, 2));
      obj_data.put('timstrt', r1.timstrt);
      obj_data.put('dteend', to_char(r1.dteend, 'dd/mm/yyyy') || ' ' || substr(r1.timend, 1, 2) || ':' || substr(r1.timend, 3, 2));
      obj_data.put('timend', r1.timend);
      obj_data.put('remark', r1.remark);
      obj_data.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser', get_temploy_name(get_codempid(r1.coduser), global_v_lang));

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
    v_codapp            tfunclock.codapp%type;
v_st date;
v_en date;


  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        p_codapp          := hcm_util.get_string_t(json_row, 'codapp');
        v_dtestrt         := to_date(hcm_util.get_string_t(json_row, 'dtestrt'), 'dd/mm/yyyy hh24:mi');
        p_dtestrt         := trunc(v_dtestrt);
        v_timstrt         := to_char(v_dtestrt, 'hh24mi');
        v_dteend          := to_date(hcm_util.get_string_t(json_row, 'dteend'), 'dd/mm/yyyy hh24:mi');
        p_dteend          := trunc(v_dteend);
        v_timend          := to_char(v_dteend, 'hh24mi');
        v_remark          := hcm_util.get_string_t(json_row, 'remark');
        if v_flg = 'delete' then
          begin
            delete from tfunclock
             where codapp           = p_codapp
               and trunc(dtestrt)   = p_dtestrt
               and timstrt          = v_timstrt;
          end;
        else
          if v_dtestrt > v_dteend then
            param_msg_error := get_error_msg_php('HR2021', global_v_lang);
            exit;
          end if;
          check_index;
          if param_msg_error is not null then
            exit;
          end if;

          begin
            select codapp,
            to_date(to_char(dtestrt, 'ddmmyyyy') || timstrt, 'dd/mm/yyyy hh24:mi'),
            to_date(to_char(dteend, 'ddmmyyyy') || timend, 'dd/mm/yyyy hh24:mi')
              into v_codapp,v_st,v_en
              from tfunclock
             where codapp  = p_codapp

                    and (
                        ( v_flg = 'add' and (    v_dtestrt   between to_date(to_char(dtestrt, 'ddmmyyyy') || timstrt, 'dd/mm/yyyy hh24:mi')  
                                                            and to_date(to_char(dteend, 'ddmmyyyy') || timend, 'dd/mm/yyyy hh24:mi')
                                            or v_dteend between to_date(to_char(dtestrt, 'ddmmyyyy') || timstrt, 'dd/mm/yyyy hh24:mi')  
                                                            and to_date(to_char(dteend, 'ddmmyyyy') || timend, 'dd/mm/yyyy hh24:mi')
                                        )
                        )
                  )
    ;
            param_msg_error := get_error_msg_php('HR2005', global_v_lang);
          exception when no_data_found then
            null;
          end;


          if param_msg_error is not null then
            exit;
          end if;
          begin
            insert into tfunclock
            (codapp, dtestrt, timstrt, dteend, timend, remark, codcreate, coduser)
            values
            (p_codapp, p_dtestrt, v_timstrt, p_dteend, v_timend, v_remark, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            update tfunclock
               set dteend  = p_dteend,
                   timend  = v_timend,
                   remark  = v_remark,
                   coduser = global_v_coduser
             where codapp  = p_codapp
               and dtestrt = p_dtestrt
               and timstrt = v_timstrt;
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
end HRSC17E;

/
