--------------------------------------------------------
--  DDL for Package Body HRRC21E4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E4" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    b_index_numappl     := hcm_util.get_string_t(json_obj,'p_numappl');
  end; -- end initial_value
  --
  procedure gen_employee_reference(json_str_output out clob) is
    obj_data      json_object_t;
    v_reason      tapploth.reason%type;
    v_flgstrwk    tapploth.flgstrwk%type;
    v_dtewkst     tapploth.dtewkst%type;
    v_qtydayst    tapploth.qtydayst%type;
    v_jobdesc     tapploth.jobdesc%type;
    v_codlocat    tapploth.codlocat%type;
    v_flgprov     tapploth.flgprov%type;
    v_flgoversea  tapploth.flgoversea%type;
    v_statappl    tapplinf.statappl%type; -- softberry || 17/02/2023 || #8807
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    begin
      select reason,flgstrwk,jobdesc,codlocat,flgprov,flgoversea,
             dtewkst,qtydayst
        into v_reason,v_flgstrwk,v_jobdesc,v_codlocat,v_flgprov,v_flgoversea,
             v_dtewkst,v_qtydayst
        from tapploth
       where numappl      = b_index_numappl;
    exception when no_data_found then null;
    end;
    --<< softberry || 17/02/2023 || #8807
    begin
        select statappl into v_statappl
        from tapplinf
        where numappl      = b_index_numappl;
    exception when no_data_found then null;
    end;
    -->> softberry || 176/02/2023 || #8807    
    
    obj_data.put('reason',v_reason);
    obj_data.put('flgstrwk',nvl(v_flgstrwk,'N'));
    obj_data.put('dtewkst',to_char(v_dtewkst,'dd/mm/yyyy'));
    obj_data.put('qtydayst',v_qtydayst);
    obj_data.put('jobdesc',v_jobdesc);
    obj_data.put('codlocat',v_codlocat);
    obj_data.put('flgprov',nvl(v_flgprov,'N'));
    obj_data.put('flgoversea',nvl(v_flgoversea,'N'));
    obj_data.put('statappl',v_statappl); -- softberry || 176/02/2023 || #8807  
    
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_employee_reference (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_employee_reference(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_employee_reference(json_str_input in clob, json_str_output out clob) is
    json_input    json_object_t;
    v_reason      tapploth.reason%type;
    v_flgstrwk    tapploth.flgstrwk%type;
    v_dtewkst     tapploth.dtewkst%type;
    v_qtydayst    tapploth.qtydayst%type;
    v_jobdesc     tapploth.jobdesc%type;
    v_codlocat    tapploth.codlocat%type;
    v_flgprov     tapploth.flgprov%type;
    v_flgoversea  tapploth.flgoversea%type;
  begin
    initial_value(json_str_input);
    json_input    := json_object_t(json_str_input);
    v_reason      := hcm_util.get_string_t(json_input,'p_reason');
    v_flgstrwk    := hcm_util.get_string_t(json_input,'p_flgstrwk');
    v_dtewkst     := to_date(hcm_util.get_string_t(json_input,'p_dtewkst'),'dd/mm/yyyy');
    v_qtydayst    := hcm_util.get_string_t(json_input,'p_qtydayst');
    v_jobdesc     := hcm_util.get_string_t(json_input,'p_jobdesc');
    v_codlocat    := hcm_util.get_string_t(json_input,'p_codlocat');
    v_flgprov     := hcm_util.get_string_t(json_input,'p_flgprov');
    v_flgoversea  := hcm_util.get_string_t(json_input,'p_flgoversea');
    begin
      insert into tapploth (numappl,reason,flgstrwk,jobdesc,codlocat,flgprov,flgoversea,codcreate,coduser)
      values (b_index_numappl,v_reason,v_flgstrwk,v_jobdesc,v_codlocat,v_flgprov,v_flgoversea,global_v_lang,global_v_lang);
    exception when dup_val_on_index then
      update tapploth
         set reason     = v_reason,
             flgstrwk   = v_flgstrwk,
             dtewkst    = v_dtewkst,
             qtydayst   = v_qtydayst,
             jobdesc    = v_jobdesc,
             codlocat   = v_codlocat,
             flgprov    = v_flgprov,
             flgoversea = v_flgoversea,
             coduser    = global_v_coduser
       where numappl    = b_index_numappl;
    end;
    
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
