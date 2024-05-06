--------------------------------------------------------
--  DDL for Package Body HRAP62E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP62E" as
  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcompy              := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteyreap              := hcm_util.get_string_t(json_obj,'p_dteyreap');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_syncond         json_object_t;
    obj_result          json_object_t;
    v_dteyreap          tcontrap.dteyreap%type;
    v_flgDisabled       boolean;
    v_flgAdd            boolean := false;
    v_code              clob;

    --v_flggrade          tcontrap.flggrade%type;
    --v_formusal          tcontrap.formusal%type;
    v_codpay            tcontrap.codpay%type;
    v_syncond           tcontrap.syncond%type;
    v_statement         tcontrap.statement%type;
    v_flgntover         tcontrap.flgntover%type;
    v_flgpyntover       tcontrap.flgpyntover%type;
    v_formuntover       tcontrap.formuntover%type;
    v_flgover           tcontrap.flgover%type;
    v_flgpyover         tcontrap.flgpyover%type;
    v_formuover         tcontrap.formuover%type;
    obj_formuntover     json_object_t;
    obj_formuover       json_object_t;
    obj_formusal        json_object_t;
  begin
    obj_data        := json_object_t();
    obj_syncond     := json_object_t();
    obj_formuntover := json_object_t();
    obj_formuover   := json_object_t();
    obj_formusal    := json_object_t();

    begin
        select max(dteyreap)
          into v_dteyreap
          from tcontrap
         where codcompy = p_codcompy
           and dteyreap <= p_dteyreap;
    exception when others then
        v_dteyreap := null;
    end;

    if v_dteyreap is null then
        obj_data.put('flgDisabled', false);
        obj_data.put('msgerror', '');
        obj_data.put('flg', 'add');
        obj_data.put('syncond', obj_syncond);
        obj_data.put('flgntover', '');
        obj_data.put('flgpyntover', '');
        obj_data.put('formuntover', '');
        obj_data.put('flgover', '');
        obj_data.put('flgpyover', '');
        obj_data.put('formuover', '');
        obj_data.put('codpay', '');
        obj_data.put('flggrade', '');
        obj_data.put('formusal', '');
    else
        if v_dteyreap = p_dteyreap then
            if v_dteyreap < to_char(sysdate,'yyyy') then
                obj_data.put('flgDisabled', true);
                obj_data.put('flg', '');
                obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
            else
                obj_data.put('flgDisabled', false);
                obj_data.put('flg', 'edit');
            end if;
        else
            obj_data.put('flgDisabled', true);
            obj_data.put('flg', '');
            obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
        end if;

        begin
            select --flggrade,formusal,
                   codpay,syncond,statement,flgntover,
                   flgpyntover,formuntover,flgover,flgpyover,formuover
              into --v_flggrade,v_formusal,
                   v_codpay,v_syncond,v_statement,v_flgntover,
                   v_flgpyntover,v_formuntover,v_flgover,v_flgpyover,v_formuover
              from tcontrap
             where codcompy = p_codcompy
               and dteyreap = v_dteyreap;
        exception when  no_data_found then
            --v_flggrade      := '';
            --v_formusal      := '';
            v_codpay        := '';
            v_syncond       := '';
            v_statement     := '';
            v_flgntover     := '';
            v_flgpyntover   := '';
            v_formuntover   := '';
            v_flgover       := '';
            v_flgpyover     := '';
            v_formuover     := '';
        end;
        obj_syncond.put('code', v_syncond);
        --obj_syncond.put('description', get_logical_name('HRAP62E', v_syncond, global_v_lang));
        obj_syncond.put('description', get_logical_desc(v_statement));
        obj_syncond.put('statement', v_statement);
        obj_data.put('syncond', obj_syncond);
        obj_data.put('flgntover', v_flgntover);
        obj_data.put('flgpyntover', v_flgpyntover);
        obj_formuntover.put('code', v_formuntover);
        obj_formuntover.put('description', hcm_formula.get_description(v_formuntover, global_v_lang));
        obj_data.put('formuntover', obj_formuntover);
        obj_data.put('flgover', v_flgover);
        obj_data.put('flgpyover', v_flgpyover);
        obj_formuover.put('code', v_formuover);
        obj_formuover.put('description', hcm_formula.get_description(v_formuover, global_v_lang));
        obj_data.put('formuover', obj_formuover);
        obj_data.put('codpay', v_codpay);
        --obj_data.put('flggrade', v_flggrade);
        --obj_formusal.put('code', v_formusal);
        --obj_formusal.put('description', hcm_formula.get_description(v_formusal, global_v_lang));
        obj_data.put('formusal', obj_formusal);
    end if;

    begin
        select max(dteyreap)
          into v_dteyreap
          from tcontrap
         where codcompy = p_codcompy;
    exception when others then
        v_dteyreap := null;
    end;

    if v_dteyreap is null or p_dteyreap >= v_dteyreap then
        obj_data.put('flgDisabled', false);
        obj_data.put('msgerror', '');
        if p_dteyreap > v_dteyreap or v_dteyreap is null then
            obj_data.put('flg', 'add');
        else
            obj_data.put('flg', 'edit');
        end if;
    else
        obj_data.put('flgDisabled', true);
        obj_data.put('flg', '');
        obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
    end if;

    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP62E', global_v_lang, 230));
    obj_data.put('fieldname', 'PCTKPIEM');

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcompy     tcompny.codcompy%type;
     v_codaplvl     tcodaplv.codcodec%type;
  begin
    if p_codcompy is not null then
      begin
        select codcompy into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteyreap is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save(json_str_input in clob) is
     v_codcomp      tcenter.codcomp%type;
     param_json     json_object_t;
     obj_formula    json_object_t;
     obj_table      json_object_t;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    obj_formula   := hcm_util.get_json_t(param_json,'formula');
    obj_table     := hcm_util.get_json_t(param_json,'table');
  end;
  --
  procedure post_save (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    v_syncond           tcontrap.syncond%type;
    v_statement         tcontrap.statement%type;
    obj_syncond         json_object_t;
    obj_formuntover     json_object_t;
    obj_formuover       json_object_t;
    obj_formusal        json_object_t;

    v_flgntover         tcontrap.flgntover%type;
    v_flgpyntover       tcontrap.flgpyntover%type;
    v_formuntover       tcontrap.formuntover%type;
    v_flgover           tcontrap.flgover%type;
    v_flgpyover         tcontrap.flgpyover%type;
    v_formuover         tcontrap.formuover%type;
    v_codpay            tcontrap.codpay%type;
    --v_flggrade          tcontrap.flggrade%type;
    --v_formusal          tcontrap.formusal%type;
  begin
    initial_value(json_str_input);
--    check_save(json_str_input);
    param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    v_flgntover     := hcm_util.get_string_t(param_json,'flgntover');
    v_flgpyntover   := hcm_util.get_string_t(param_json,'flgpyntover');
    obj_formuntover := hcm_util.get_json_t(json_object_t(param_json),'formuntover');
    v_formuntover   := hcm_util.get_string_t(json_object_t(obj_formuntover),'code');
    v_flgover       := hcm_util.get_string_t(param_json,'flgover');
    v_flgpyover     := hcm_util.get_string_t(param_json,'flgpyover');
    obj_formuover   := hcm_util.get_json_t(json_object_t(param_json),'formuover');
    v_formuover     := hcm_util.get_string_t(json_object_t(obj_formuover),'code');
    v_codpay        := hcm_util.get_string_t(param_json,'codpay');
    --v_flggrade      := hcm_util.get_string_t(param_json,'flggrade');
    obj_formusal    := hcm_util.get_json_t(json_object_t(param_json),'formusal');
    --v_formusal      := hcm_util.get_string_t(json_object_t(obj_formusal),'code');

    obj_syncond     := hcm_util.get_json_t(json_object_t(param_json),'syncond');
    v_syncond       := hcm_util.get_string_t(json_object_t(obj_syncond),'code');
    v_statement     := hcm_util.get_string_t(json_object_t(obj_syncond),'statement');

    begin
        insert into tcontrap (codcompy,dteyreap,
                              --flggrade,formusal,
                              codpay,
                              syncond,statement,flgntover,flgpyntover,formuntover,
                              flgover,flgpyover,formuover,
                              dtecreate,codcreate,dteupd,coduser)
                    values (p_codcompy,p_dteyreap,
                            --v_flggrade,v_formusal,
                            v_codpay,
                            v_syncond,v_statement,v_flgntover,v_flgpyntover,v_formuntover,
                            v_flgover,v_flgpyover,v_formuover,
                            sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tcontrap
           set ---flggrade = v_flggrade,
               --formusal = v_formusal,
               codpay = v_codpay,
               syncond = v_syncond,
               statement = v_statement,
               flgntover = v_flgntover,
               flgpyntover = v_flgpyntover,
               formuntover = v_formuntover,
               flgover = v_flgover,
               flgpyover = v_flgpyover,
               formuover = v_formuover,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcompy = p_codcompy
           and dteyreap = p_dteyreap;
    end;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
end HRAP62E;

/
