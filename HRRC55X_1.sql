--------------------------------------------------------
--  DDL for Package Body HRRC55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC55X" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DDMMYYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DDMMYYYY');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_dteend < p_dtestrt then
      param_msg_error := get_error_msg_php('HR2029', global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
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

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;

    cursor c1 is
      select a.codempid, a.codcomp, b.numseq, b.codempgrt codempg, b.codtitle,
             decode(global_v_lang, '101', b.namguare
                                 , '102', b.namguart
                                 , '103', b.namguar3
                                 , '104', b.namguar4
                                 , '105', b.namguar5
                                 , b.namguare) namguar, b.dteguret
        from temploy1 a, tguarntr b
       where a.codempid = b.codempid
         and a.codcomp  like p_codcomp || '%'
         and a.staemp   in ('1', '3')
         and b.dteguret between p_dtestrt and p_dteend
       order by a.codempid, b.numseq;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_found             := true;
      if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('numseq', i.numseq);
        obj_data.put('codempg', i.codempg);
        if i.codempg is null then
          obj_data.put('desc_codempg', get_tlistval_name('CODTITLE', i.codtitle, global_v_lang) || i.namguar);
        else
          obj_data.put('desc_codempg', get_temploy_name(i.codempg, global_v_lang));
        end if;
        obj_data.put('dteguret', to_char(i.dteguret, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
      end if;
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;
end HRRC55X;


/
