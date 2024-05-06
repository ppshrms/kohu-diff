--------------------------------------------------------
--  DDL for Package Body HRRC21E2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E2" is
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
  procedure gen_applinf_step(json_str_output out clob) is
    obj_data      json_object_t;
    cursor c_appfoll is
      select numappl,dtefoll,statappl,codrej
        from tappfoll
       where numappl    = b_index_numappl
         and dtefoll    = (select max(dtefoll)
                             from tappfoll
                            where numappl    = b_index_numappl);

    cursor c_applinf is
      select stasign,codappr,dteempmt,numreqc,codcompl,
             codposl,codempmt,flgblkls,remark,numreql,
             statappl,dteappr,codcomp,codposc
        from tapplinf
       where numappl    = b_index_numappl;
  begin
    obj_data    := json_object_t();
    for r_applinf in c_applinf loop
      obj_data.put('coderror','200');
      obj_data.put('stasign',r_applinf.stasign);
      obj_data.put('desc_stasign',get_tlistval_name('STASIGN', r_applinf.stasign, global_v_lang));
      obj_data.put('codappr',r_applinf.codappr);
      obj_data.put('desc_codappr',get_temploy_name(r_applinf.codappr,global_v_lang));
      obj_data.put('dteempmt',to_char(r_applinf.dteempmt,'dd/mm/yyyy'));
      obj_data.put('dteappr',to_char(r_applinf.dteappr,'dd/mm/yyyy'));
      obj_data.put('numreqc',r_applinf.numreqc);
      obj_data.put('codcomp',r_applinf.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(r_applinf.codcomp,global_v_lang));
      obj_data.put('codcompl',r_applinf.codcompl);
      obj_data.put('desc_codcompl',get_tcenter_name(r_applinf.codcompl,global_v_lang));
      obj_data.put('codposl',r_applinf.codposl);
      obj_data.put('desc_codposl',get_tpostn_name(r_applinf.codposl,global_v_lang));
      obj_data.put('codposc',r_applinf.codposc);
      obj_data.put('desc_codposc',get_tpostn_name(r_applinf.codposc,global_v_lang));
      obj_data.put('codempmt',r_applinf.codempmt);
      obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',r_applinf.codempmt,global_v_lang));
      obj_data.put('flgblkls',r_applinf.flgblkls);
      obj_data.put('desc_flgblkls',get_tlistval_name('FLGBLKLS',r_applinf.flgblkls,global_v_lang));
      obj_data.put('remark',r_applinf.remark);
      obj_data.put('numreql',r_applinf.numreql);
      obj_data.put('statappl',r_applinf.statappl);
      obj_data.put('desc_statappl',get_tlistval_name('STATAPPL',r_applinf.statappl,global_v_lang));
--      if r_applinf.statappl in ('42','65') then
        for r_appfoll in c_appfoll loop
          obj_data.put('numappl',r_appfoll.numappl);
          obj_data.put('dtefoll',to_char(r_appfoll.dtefoll,'dd/mm/yyyy'));
          obj_data.put('statappl',r_appfoll.statappl);
          obj_data.put('desc_statappl',get_tlistval_name('STATAPPL',r_appfoll.statappl,global_v_lang));
          obj_data.put('codrej',r_appfoll.codrej);
        end loop;
--      end if;
    end loop;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_applinf_step (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_applinf_step(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_applinf_history(json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_numoffid    tapplinf.numoffid%type;
    v_qtyscoresum tapphinv.qtyscoresum%type;
    v_stasign     tapphinv.stasign%type;

    v_rcnt        number  := 0;
    cursor c_applinf is
      select dteappl,codpos1,codpos2,numappl,statappl,
             numreql,codposl,dtefoll
        from tapplinf
       where numappl    <> b_index_numappl
         and numoffid   = v_numoffid;
  begin
    begin
      select numoffid
        into v_numoffid
        from tapplinf
       where numappl    = b_index_numappl;
    exception when no_data_found then
      v_numoffid    := null;
    end;

    obj_row   := json_object_t();
    for i in c_applinf loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteappl',to_char(i.dteappl,'dd/mm/yyyy'));
      obj_data.put('codpos1',i.codpos1);
      obj_data.put('desc_codpos1',get_tpostn_name(i.codpos1,global_v_lang));
      obj_data.put('codpos2',i.codpos2);
      obj_data.put('desc_codpos2',get_tpostn_name(i.codpos2,global_v_lang));
      obj_data.put('numappl',i.numappl);
      obj_data.put('statappl',i.statappl);
      obj_data.put('desc_statappl',get_tlistval_name('STATAPPL',i.statappl,global_v_lang));
      obj_data.put('numreql',i.numreql);
      obj_data.put('codposl',i.codposl);
      obj_data.put('desc_codposl',get_tpostn_name(i.codposl,global_v_lang));
      obj_data.put('dtefoll',to_char(i.dtefoll,'dd/mm/yyyy'));
      begin
        select qtyscoresum,stasign
          into v_qtyscoresum,v_stasign
          from tapphinv
         where numappl    = b_index_numappl
           and numreqrq   = i.numreql
           and codposrq   = i.codposl;
      exception when no_data_found then
        v_qtyscoresum   := null;
        v_stasign       := null;
      end;
      obj_data.put('qtyscoresum',to_char(v_qtyscoresum,'fm999,900.00'));
      obj_data.put('stasign',v_stasign);
      obj_data.put('desc_stasign',get_tlistval_name('STASIGN', v_stasign, global_v_lang));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt    := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_applinf_history (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_applinf_history(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_applinf_step(json_str_input in clob, json_str_output out clob) is
    json_input    json_object_t;
    v_dtefoll     date;
    v_codrej      tappfoll.codrej%type;
    v_statappl    tappfoll.statappl%type;
  begin
    initial_value(json_str_input);
    json_input    := json_object_t(json_str_input);
    v_dtefoll     := to_date(hcm_util.get_string_t(json_input,'p_dtefoll'),'dd/mm/yyyy');
    v_codrej      := hcm_util.get_string_t(json_input,'p_codrej');
    v_statappl    := hcm_util.get_string_t(json_input,'p_statappl');

    if v_statappl in ('42','62') then
      begin
        insert into tappfoll(numappl,dtefoll,statappl,codrej,codcreate,coduser)
        values (b_index_numappl,v_dtefoll,v_statappl,v_codrej,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tappfoll
           set codrej     = v_codrej
         where numappl    = b_index_numappl;
      end;
    end if;

    update tapplinf
       set dtefoll    = v_dtefoll,
           statappl   = v_statappl,
           codrej     = v_codrej,
           coduser    = global_v_coduser
     where numappl    = b_index_numappl;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
