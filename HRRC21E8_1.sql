--------------------------------------------------------
--  DDL for Package Body HRRC21E8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E8" is
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
  procedure gen_other_data(json_str_output out clob) is
    obj_data      json_object_t;
    r_tapploth    tapploth%rowtype;
    v_statappl    tapplinf.statappl%type; -- softberry || 17/02/2023 || #8807
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    begin
      select *
        into r_tapploth
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

    obj_data.put('flgcivil',nvl(r_tapploth.flgcivil,'N'));
    obj_data.put('lastpost',r_tapploth.lastpost);
    obj_data.put('departmn',r_tapploth.departmn);
    obj_data.put('flgmilit',nvl(r_tapploth.flgmilit,'N'));
    obj_data.put('desexcem',r_tapploth.desexcem);
    obj_data.put('flgordan',nvl(r_tapploth.flgordan,'N'));
    obj_data.put('flgcase',nvl(r_tapploth.flgcase,'N'));
    obj_data.put('desdisea',r_tapploth.desdisea);
    obj_data.put('dessymp',r_tapploth.dessymp);
    obj_data.put('flgill',nvl(r_tapploth.flgill,'N'));
    obj_data.put('desill',r_tapploth.desill);
    obj_data.put('flgarres',nvl(r_tapploth.flgarres,'N'));
    obj_data.put('desarres',r_tapploth.desarres);
    obj_data.put('flgknow',nvl(r_tapploth.flgknow,'N'));
    obj_data.put('name',r_tapploth.name);
    obj_data.put('flgappl',nvl(r_tapploth.flgappl,'N'));
    obj_data.put('lastpos2',r_tapploth.lastpos2);
    obj_data.put('agewrkyr',r_tapploth.agewrkyr);
    obj_data.put('agewrkmth',r_tapploth.agewrkmth);
    obj_data.put('hobby',r_tapploth.hobby);
    --<< softberry || 17/02/2023 || #8807
    obj_data.put('statappl',v_statappl);
    if v_statappl in ('51','56') then
        obj_data.put('alert_msg',get_terrorm_name('RC0009',global_v_lang));
    else
        obj_data.put('alert_msg','');
    end if;
    -->> softberry || 17/02/2023 || #8807
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_other_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_other_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_other_data(json_str_input in clob, json_str_output out clob) is
    param_json    json_object_t;
    r_tapploth    tapploth%rowtype;
  begin
    initial_value(json_str_input);
    param_json    := json_object_t(json_str_input);
    r_tapploth.flgcivil       := hcm_util.get_string_t(param_json,'flgcivil');
    r_tapploth.lastpost       := hcm_util.get_string_t(param_json,'lastpost');
    r_tapploth.departmn       := hcm_util.get_string_t(param_json,'departmn');
    r_tapploth.flgmilit       := hcm_util.get_string_t(param_json,'flgmilit');
    r_tapploth.desexcem       := hcm_util.get_string_t(param_json,'desexcem');
    r_tapploth.flgordan       := hcm_util.get_string_t(param_json,'flgordan');
    r_tapploth.flgcase        := hcm_util.get_string_t(param_json,'flgcase');
    r_tapploth.desdisea       := hcm_util.get_string_t(param_json,'desdisea');
    r_tapploth.dessymp        := hcm_util.get_string_t(param_json,'dessymp');
    r_tapploth.flgill         := hcm_util.get_string_t(param_json,'flgill');
    r_tapploth.desill         := hcm_util.get_string_t(param_json,'desill');
    r_tapploth.flgarres       := hcm_util.get_string_t(param_json,'flgarres');
    r_tapploth.desarres       := hcm_util.get_string_t(param_json,'desarres');
    r_tapploth.flgknow        := hcm_util.get_string_t(param_json,'flgknow');
    r_tapploth.name           := hcm_util.get_string_t(param_json,'name');
    r_tapploth.flgappl        := hcm_util.get_string_t(param_json,'flgappl');
    r_tapploth.lastpos2       := hcm_util.get_string_t(param_json,'lastpos2');
    r_tapploth.agewrkyr       := hcm_util.get_string_t(param_json,'agewrkyr');
    r_tapploth.agewrkmth      := hcm_util.get_string_t(param_json,'agewrkmth');
    r_tapploth.hobby          := hcm_util.get_string_t(param_json,'hobby');
    begin
      insert into tapploth (numappl,flgcivil,lastpost,departmn,flgmilit,
                            desexcem,flgordan,flgcase,desdisea,dessymp,
                            flgill,desill,flgarres,desarres,flgknow,
                            name,flgappl,lastpos2,agewrkyr,agewrkmth,
                            hobby,codcreate,coduser)
      values (b_index_numappl,r_tapploth.flgcivil,r_tapploth.lastpost,r_tapploth.departmn,r_tapploth.flgmilit,
              r_tapploth.desexcem,r_tapploth.flgordan,r_tapploth.flgcase,r_tapploth.desdisea,r_tapploth.dessymp,
              r_tapploth.flgill,r_tapploth.desill,r_tapploth.flgarres,r_tapploth.desarres,r_tapploth.flgknow,
              r_tapploth.name,r_tapploth.flgappl,r_tapploth.lastpos2,r_tapploth.agewrkyr,r_tapploth.agewrkmth,
              r_tapploth.hobby,global_v_lang,global_v_lang);
    exception when dup_val_on_index then
      update tapploth
         set flgcivil     = r_tapploth.flgcivil,
             lastpost     = r_tapploth.lastpost,
             departmn     = r_tapploth.departmn,
             flgmilit     = r_tapploth.flgmilit,
             desexcem     = r_tapploth.desexcem,
             flgordan     = r_tapploth.flgordan,
             flgcase      = r_tapploth.flgcase,
             desdisea     = r_tapploth.desdisea,
             dessymp      = r_tapploth.dessymp,
             flgill       = r_tapploth.flgill,
             desill       = r_tapploth.desill,
             flgarres     = r_tapploth.flgarres,
             desarres     = r_tapploth.desarres,
             flgknow      = r_tapploth.flgknow,
             name         = r_tapploth.name,
             flgappl      = r_tapploth.flgappl,
             lastpos2     = r_tapploth.lastpos2,
             agewrkyr     = r_tapploth.agewrkyr,
             agewrkmth    = r_tapploth.agewrkmth,
             hobby        = r_tapploth.hobby,
             coduser      = global_v_coduser
       where numappl      = b_index_numappl;
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
