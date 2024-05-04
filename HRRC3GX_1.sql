--------------------------------------------------------
--  DDL for Package Body HRRC3GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3GX" AS
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
    p_codemprc          := hcm_util.get_string_t(json_obj, 'p_codemprc');
    p_dtereqst          := to_date(hcm_util.get_string_t(json_obj, 'p_dtereqst'), 'DDMMYYYY');
    p_dtereqen          := to_date(hcm_util.get_string_t(json_obj, 'p_dtereqen'), 'DDMMYYYY');
    p_flgrecut          := hcm_util.get_string_t(json_obj, 'p_flgrecut');

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
    v_recutno           number := 0;
    v_found             boolean := false;
    v_numreqst          treqest2.numreqst%type;
    v_codpos            treqest2.codpos%type;
    v_amtincom1         tapplcfm.amtincom1%type;
    v_codrej            tapplcfm.codrej%type;
    v_dteempmt          tapplcfm.dteempmt%type;
    v_flgrecut          treqest2.flgrecut%type;

    cursor c1 is
      select a.numreqst, a.codemprc, b.codpos, b.qtyreq
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and a.codcomp  like p_codcomp || '%'
         and a.codemprc = nvl(p_codemprc, a.codemprc)
         and a.dtereq   between p_dtereqst and p_dtereqen
       order by a.numreqst, b.codpos;

    cursor c2 is
      select a.numappl, a.stasign, a.dteempmt, a.codempid, a.statappl
        from tapplinf a
       where a.numreql = v_numreqst
         and a.codposl = v_codpos
         and ((statappl in ('51', '56', '61') and p_flgrecut = 'Y') or
              (statappl in ('22', '32', '52', '53', '54', '55', '63') and p_flgrecut = 'N') or
              (statappl in ('22', '32', '51', '56', '61', '52', '53', '54', '55', '63')  and p_flgrecut = 'A'))
       order by a.numappl;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_numreqst          := i.numreqst;
      v_codpos            := i.codpos;
      v_recutno           := 0;
      for j in c2 loop
        v_found             := true;
        if secur_main.secur2(i.codemprc, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          v_rcnt              := v_rcnt + 1;
          v_recutno           := v_recutno + 1;
          obj_data            := json_object_t();
          v_flgrecut          := null;
          obj_data.put('coderror', '200');
          obj_data.put('numreqst', i.numreqst);
          obj_data.put('codpos', i.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
          obj_data.put('codemprc', i.codemprc);
          obj_data.put('desc_codemprc', get_temploy_name(i.codemprc, global_v_lang));
          obj_data.put('qtyreq', i.qtyreq);

          obj_data.put('recutno', v_recutno);
          obj_data.put('numappl', j.numappl);
          obj_data.put('desc_numappl', get_tapplinf_name(j.numappl, global_v_lang));
          if j.statappl in ('51', '56', '61') then
            v_flgrecut            := 'Y';
          elsif j.statappl in ('22', '32', '52', '53', '54', '55', '63') then
            v_flgrecut            := 'N';
          end if;
          obj_data.put('stasign', v_flgrecut);
          obj_data.put('desc_stasign', get_tlistval_name('STARC3GX', v_flgrecut, global_v_lang));
          obj_data.put('dteempmt', to_char(j.dteempmt, 'DD/MM/YYYY'));

          v_amtincom1        := null;
          v_codrej           := null;
          v_dteempmt         := null;
          begin
          select amtincom1, codrej, dteempmt
            into v_amtincom1, v_codrej, v_dteempmt
            from tapplcfm
           where numappl  = j.numappl
             and numreqrq = i.numreqst
             and codposrq = i.codpos;
          exception when no_data_found then
            null;
          end;
          obj_data.put('amtincom', stddec(v_amtincom1, j.codempid, v_chken));
          obj_data.put('codrej', v_codrej);
          obj_data.put('desc_codrej', get_tcodec_name('TCODREJE', v_codrej, global_v_lang));

          obj_rows.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
    end loop;

    if v_rcnt = 0 then
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest1');
      end if;
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;
end HRRC3GX;


/
