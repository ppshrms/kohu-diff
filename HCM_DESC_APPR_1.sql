--------------------------------------------------------
--  DDL for Package Body HCM_DESC_APPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_DESC_APPR" IS
-- last update: 16/09/2019 15:30

  procedure initial_value (json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codapp            := hcm_util.get_string_t(json_obj, 'p_codapp');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'p_numseq');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin null;
--    if p_codempid is not null then
--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid, false);
--      if param_msg_error is not null then
--        return;
--      end if;
--    end if;
  end check_index;

  procedure get_movement_types (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    v_codtrn     varchar2(500 char);
  begin
    initial_value(json_str_input);
    --
    if p_codapp = 'HRPM4CE' then
      v_codtrn := '0007';
    elsif p_codapp = 'HRPM4GE' then
      v_codtrn := '0005';
    elsif p_codapp = 'HRPM4IE' then
      v_codtrn := '0006';
    elsif p_codapp = 'HRPM21E' then
      v_codtrn := '0002';
    elsif p_codapp = 'HRPM4DE' then
      begin
        select codtrn into v_codtrn
          from ttmovemt
         where codempid = p_codempid
           and dteeffec = p_dteeffec
           and numseq   = p_numseq;
      exception when no_data_found then
        v_codtrn := null;
      end;
    end if;
    --
    obj_data  := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('type', get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_movement_types;

  procedure get_desc_approver (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;
    cursor c1 is
      select approvno, codappr, dteappr,staappr, remark
        from tapmovmt
       where codapp   = p_codapp
         and codempid = p_codempid
         and dteeffec = p_dteeffec
         and numseq   = p_numseq
      order by approvno;
  begin
    obj_rows    := json_object_t();
    initial_value(json_str_input);
    for r1 in c1 loop
      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('approvno', r1.approvno);
      obj_data.put('codappr', r1.codappr);
      obj_data.put('remark', r1.remark);
      obj_data.put('staappr', GET_TLISTVAL_NAME('STAAPPR',r1.staappr,global_v_lang));
      obj_data.put('desc_codappr', get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));

      obj_rows.put(to_char(v_row), obj_data);
      v_row  := v_row + 1;
    end loop;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_desc_approver;

end HCM_DESC_APPR;

/
