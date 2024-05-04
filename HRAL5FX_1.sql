--------------------------------------------------------
--  DDL for Package Body HRAL5FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5FX" as
-- last update: 04/04/2018 15:15:00
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_codcomp           TEMPLOY1.CODCOMP%TYPE;
    v_codempid          TEMPLOY1.CODEMPID%TYPE;
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_dtestle           date;
    v_dteenle           date;
    v_dtein             date;
    v_dteout            date;
    v_typwork           varchar2(10 char);
    v_timstrtw          varchar2(10 char);
    v_timendw           varchar2(10 char);
    v_timin             varchar2(10 char);
    v_timout            varchar2(10 char);
    v_desc_typwork      varchar2(1000 char);
    iotimnrml           varchar2(1000 char);
    iorealnrml          varchar2(1000 char);
    v_check_secur       boolean;

    cursor c1 is
      select a.codempid, a.codcomp, a.numlvl, a.staemp, a.dteeffex,
             b.numlereq, b.dtework, b.timstrt, b.timend, b.codleave
        from temploy1 a, tleavetr b
       where a.codcomp like p_codcomp || '%'
         and b.codempid = a.codempid
         and b.dtework between p_dtestrt and p_dteend
    order by a.codcomp, b.dtework asc, a.codempid;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop

      v_dtestle            := to_date(to_char(r1.dtework, 'dd/mm/yyyy') || r1.timstrt, 'dd/mm/yyyyhh24mi');
      v_dteenle            := to_date(to_char(r1.dtework, 'dd/mm/yyyy') || r1.timend, 'dd/mm/yyyyhh24mi');

      v_dtein              := null;
      v_dteout             := null;
      v_typwork            := null;
      v_timstrtw           := null;
      v_timendw            := null;
      v_timin              := null;
      v_timout             := null;
      v_desc_typwork       := null;

      begin
        select to_date(to_char(dtein, 'dd/mm/yyyy') || timin, 'dd/mm/yyyyhh24mi'),
               to_date(to_char(dteout, 'dd/mm/yyyy') || timout, 'dd/mm/yyyyhh24mi'),
               typwork, timstrtw, timendw, timin, timout
          into v_dtein, v_dteout, v_typwork, v_timstrtw, v_timendw, v_timin, v_timout
          from tattence
         where codempid = r1.codempid
           and dtework = r1.dtework;

        if (v_dtein is null and v_dteout is null)
        or (v_dtein is not null and v_dtein >= v_dteenle)
        or (v_dteout is not null and v_dteout <= v_dtestle) then
          continue;
        end if;

      exception when no_data_found then
        continue;
      when others then
        continue;
      end;

      v_flgdata            := 'Y';
      v_codempid           := r1.codempid;
      v_check_secur        := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur         := 'Y';

        v_desc_typwork     := '';
        iotimnrml          := substr(v_timstrtw, 1, 2) || ':' || substr(v_timstrtw, 3, 2) || ' - ' || substr(v_timendw, 1, 2) || ':' || substr(v_timendw, 3, 2);
        iorealnrml         := substr(v_timin, 1, 2) || ':' || substr(v_timin, 3, 2) || ' - ' || substr(v_timout, 1, 2) || ':' || substr(v_timout, 3, 2);

        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('date', to_char(r1.dtework, 'DD/MM/YYYY'));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('typday', get_tlistval_name('TYPWRKABB', v_typwork, global_v_lang)); --TYPWRKFUL
        obj_data.put('leaveno', r1.numlereq);
        obj_data.put('iotimnrml', iotimnrml);
        obj_data.put('iorealnrml', iorealnrml);
        obj_data.put('desc_codleave', r1.codleave || ' - ' || get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('codleave', r1.codleave);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tleavetr');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end gen_index;

end HRAL5FX;

/
