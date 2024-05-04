--------------------------------------------------------
--  DDL for Package Body HRSC04E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC04E" as
-- last update: 14/11/2018 22:31
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

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codpos            := upper(hcm_util.get_string_t(json_obj, 'p_codpos'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_rcnt                  number;
    v_stapost2              tsecpos.stapost2%type;
    v_desc_stapost2         varchar2(4000 char);

    cursor c_tassignm is
      select codempid, codcomp, codpos, dtestrt, dteend, flgassign
        from tassignm
       where codempid = nvl(p_codempid, codempid)
         and codcomp  like p_codcomp || '%'
         and codpos   = nvl(p_codpos, codpos)
         and (
           dtestrt   between p_dtestrt and p_dteend or
           dteend    between p_dtestrt and p_dteend or
           p_dtestrt between dtestrt   and dteend
         )
      order by codempid, codcomp, codpos;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tassignm loop
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;

      v_stapost2 := 0;
      begin
        select stapost2
          into v_stapost2
          from tsecpos
         where codcomp = c1.codcomp
           and codpos = c1.codpos
         fetch first 1 rows only;
      exception when no_data_found then
        null;
      end;
      v_desc_stapost2 := get_tlistval_name('STAPOST2', v_stapost2, global_v_lang);

      obj_data.put('coderror', '200');
      obj_data.put('codempid', c1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(c1.codempid, global_v_lang));
      obj_data.put('codcomp', c1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(c1.codcomp, global_v_lang));
      obj_data.put('codpos', c1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(c1.codpos, global_v_lang));
      obj_data.put('stapost2', v_stapost2);
      obj_data.put('desc_stapost2', v_desc_stapost2);
      obj_data.put('dtestrt', to_char(c1.dtestrt, 'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(c1.dteend, 'dd/mm/yyyy'));
      obj_data.put('flgassign', c1.flgassign);
      obj_data.put('desc_flgassign', get_tlistval_name('HRSC04E2', c1.flgassign, global_v_lang));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
--    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
--    else
--      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'tsecpos');
--      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure check_detail is
    v_flgsecu1        boolean := false;
    v_flgsecu2        boolean := false;
    v_staemp          temploy1.staemp%type;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
          return;
      else
          v_flgsecu1 := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu1  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
      end if;
    end if;
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
        return;
      end if;
    end if;
  end check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_data               json_object_t;
    v_codempid             tassignm.codempid%type;
    v_codcomp              tassignm.codcomp%type;
    v_codpos               tassignm.codpos%type;
    v_dtestrt              tassignm.dtestrt%type;
    v_dteend               tassignm.dteend%type;
    v_flgassign            tassignm.flgassign%type;
    v_codempas             tassignm.codempas%type;
    v_codcomas             tassignm.codcomas%type;
    v_codposas             tassignm.codposas%type;

  begin
    begin
      select codempid, codcomp, codpos, dtestrt, dteend, flgassign, codempas, codcomas, codposas
        into v_codempid, v_codcomp, v_codpos, v_dtestrt, v_dteend, v_flgassign, v_codempas, v_codcomas, v_codposas
        from tassignm
      where codempid = p_codempid
        and codcomp  = p_codcomp
        and codpos   = p_codpos
        and dtestrt  = p_dtestrt;
    exception when no_data_found then
      null;
    end;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('codcomp', p_codcomp);
    obj_data.put('codpos', p_codpos);
    obj_data.put('dtestrt', to_char(p_dtestrt, 'dd/mm/yyyy'));
    obj_data.put('dteend', to_char(v_dteend, 'dd/mm/yyyy'));
    obj_data.put('flgassign', v_flgassign);
    obj_data.put('codempas', v_codempas);
    obj_data.put('codcomas', v_codcomas);
    obj_data.put('codposas', v_codposas);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row               json_object_t;
    v_flg                  varchar2(100 char);
    v_codempid             tassignm.codempid%type;
    v_codcomp              tassignm.codcomp%type;
    v_codpos               tassignm.codpos%type;
    v_dtestrt              tassignm.dtestrt%type;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codempid        := upper(hcm_util.get_string_t(json_row, 'codempid'));
        v_codcomp         := upper(hcm_util.get_string_t(json_row, 'codcomp'));
        v_codpos          := upper(hcm_util.get_string_t(json_row, 'codpos'));
        v_dtestrt         := to_date(hcm_util.get_string_t(json_row, 'dtestrt'), 'dd/mm/yyyy');
        if param_msg_error is not null then
          exit;
        end if;
        if v_flg = 'delete' then
          begin
            Delete
              From tassignm
             where codempid = v_codempid
               and codcomp  = v_codcomp
               and codpos   = v_codpos
               and dtestrt  = v_dtestrt;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      save_tassignm;
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
  end save_detail;

  procedure check_save is
    v_flgsecu1        boolean := false;
    v_flgsecu2        boolean := false;
    v_staemp          temploy1.staemp%type;
  begin
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
          return;
      else
          v_flgsecu1 := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu1  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
      end if;
    end if;
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
        return;
      end if;
    end if;
  end check_save;

  procedure save_tassignm is
    json_obj            json_object_t;
    v_flg               varchar2(100 char);
    v_codempid          tassignm.codempid%type;
    v_codcomp           tassignm.codcomp%type;
    v_codpos            tassignm.codpos%type;
    v_dtestrt           tassignm.dtestrt%type;
    v_dteend            tassignm.dteend%type;
    v_flgassign         tassignm.flgassign%type;
    v_codempas          tassignm.codempas%type;
    v_codcomas          tassignm.codcomas%type;
    v_codposas          tassignm.codposas%type;

  begin
    v_codempid          := upper(hcm_util.get_string_t(json_params, 'codempid'));
    v_codcomp           := upper(hcm_util.get_string_t(json_params, 'codcomp'));
    v_codpos            := upper(hcm_util.get_string_t(json_params, 'codpos'));
    v_dtestrt           := to_date(hcm_util.get_string_t(json_params, 'dtestrt'), 'dd/mm/yyyy');
    v_dteend            := to_date(hcm_util.get_string_t(json_params, 'dteend'), 'dd/mm/yyyy');
    v_flgassign         := hcm_util.get_string_t(json_params, 'flgassign');
    v_codempas          := upper(hcm_util.get_string_t(json_params, 'codempas'));
    v_codcomas          := upper(hcm_util.get_string_t(json_params, 'codcomas'));
    v_codposas          := upper(hcm_util.get_string_t(json_params, 'codposas'));
    if v_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codempid');
      return;
    end if;
    if v_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if v_codpos is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if v_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    p_codempid := v_codempas;
    p_codcomp  := v_codcomas;
    check_save;
    if param_msg_error is not null then
      return;
    end if;

    begin
      insert
        into tassignm
           (
             codempid, codcomp, codpos, dtestrt, dteend, flgassign,
             codempas, codcomas, codposas, codcreate, coduser, dtecreate, dteupd
           )
      values
           (
             v_codempid, v_codcomp, v_codpos, v_dtestrt, v_dteend, v_flgassign,
             v_codempas, v_codcomas, v_codposas, global_v_coduser, global_v_coduser, sysdate, sysdate
           );
    exception when dup_val_on_index then
      update tassignm
         set dteend    = v_dteend,
             flgassign = v_flgassign,
             codempas  = v_codempas,
             codcomas  = v_codcomas,
             codposas  = v_codposas,
             coduser   = global_v_coduser,
             dteupd    = sysdate
       where codempid = v_codempid
         and codcomp  = v_codcomp
         and codpos   = v_codpos
         and dtestrt  = v_dtestrt;
    end;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tassignm;

  procedure get_temploy_data (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_flgsecu           boolean := false;
  begin
    initial_value (json_str_input);
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if p_codempid is not null then
      v_codcomp := hcm_util.get_temploy_field(p_codempid, 'codcomp');
      if v_codcomp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      else
          v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          end if;
      end if;
    end if;
    if param_msg_error is null then
      v_codpos  := hcm_util.get_temploy_field(p_codempid, 'codpos');
      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', v_codcomp);
      obj_data.put('codpos', v_codpos);

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_temploy_data;
end HRSC04E;

/
