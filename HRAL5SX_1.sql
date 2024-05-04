--------------------------------------------------------
--  DDL for Package Body HRAL5SX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5SX" as
-- last update: 27/03/2018 14:00:00
  procedure initial_value (json_str in clob) is
    json_obj         json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            :=  json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dteyear           := hcm_util.get_string_t(json_obj, 'p_dteyear');
    p_staappr           := upper(hcm_util.get_string_t(json_obj, 'p_staappr'));

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

    if p_codempid is not null then
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_index;

  function display_currency (p_amtcur number) return varchar2 is
    v_amt_display        varchar2(20 char) := '';
  begin
    v_amt_display := to_char(p_amtcur, 'fm999,999,990.00');
    return v_amt_display;
  exception when others then
    return p_amtcur;
  end;

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
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_day               number;
    v_hour              number;
    v_min               number;
    v_cashday           varchar2(100 char);
    v_amonth            varchar2(100 char);
    v_amtlepay          number;
    v_qtyavgwk          number;
    v_check_secur       boolean;

    cursor c1 is
      select a.dtereq, a.codempid, a.qtylepay, a.amtlepay, a.staappr,
             a.codcomp, b.numlvl, a.flgcalvac, a.dteyear, a.flgreq
        from tpayvac a, temploy1 b
       where a.codempid = b.codempid
         and a.dteyear = p_dteyear - global_v_zyear
         and a.codempid = nvl(p_codempid, a.codempid)
         and a.codcomp like p_codcomp || '%'
         and (
              (a.staappr = p_staappr and p_staappr <> 'A')
               or (p_staappr = 'A')
             )
    order by a.dtereq, a.codempid;

  begin
    obj_row                 :=  json_object_t();
    v_rcnt                  := 0;
    for r1 in c1 loop
      v_flgdata             := 'Y';
      v_check_secur         := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur          := 'Y';
        v_day               := 0;
        v_hour              := 0;
        v_min               := 0;
        v_cashday           := '';
        v_amonth            := '';
        v_amtlepay          := 0;
        begin
          select qtyavgwk
           into v_qtyavgwk
           from tcontral
          where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
            and dteeffec = (select max(dteeffec)
                              from tcontral
                             where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
                               and dteeffec <= sysdate);
        exception when no_data_found then
          v_qtyavgwk := 0;
        end;

        hcm_util.cal_dhm_hm(r1.qtylepay,0,0,v_qtyavgwk,'1',v_day,v_hour,v_min,v_cashday);

        v_amtlepay := stddec(r1.amtlepay, r1.codempid, v_chken);
        if nvl(v_zupdsal, 'Y') = 'Y' then
          v_amonth := display_currency(v_amtlepay);
        end if;

        obj_data :=  json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('dtereq', to_char(r1.dtereq, 'DD/MM/YYYY'));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('cashday', v_cashday);
        obj_data.put('amonth', v_amonth);
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('flgreq', r1.flgreq);
--        if r1.flgcalvac = 'Y' then
--          obj_data.put('staappr', get_tlistval_name('TRANPY', r1.flgcalvac, global_v_lang));
--        else
        if r1.staappr = 'P' then
          obj_data.put('staappr', get_label_name('HRAL5SX', global_v_lang, '110'));
        elsif r1.staappr = 'Y' then
          obj_data.put('staappr', get_label_name('HRAL5SX', global_v_lang, '120'));
        elsif r1.staappr = 'N' then
          obj_data.put('staappr', get_label_name('HRAL5SX', global_v_lang, '130'));
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tpayvac');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRAL5SX;

/
