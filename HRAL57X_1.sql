--------------------------------------------------------
--  DDL for Package Body HRAL57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL57X" is
-- last update: 27/03/2018 14:16
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    -- index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_dteyear           := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));

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
      begin
        select codempid
          into p_codempid
          from temploy1
        where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end check_index;

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
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_codcomp         tcenter.codcomp%type;
    v_flgdlemx        tleavety.flgdlemx%type;
    v_qtydlepay       tleavety.qtydlepay%type;
    v_staleave        tleavecd.staleave%type;
    v_qtyvacats       number;
    v_over            number;
    v_qtyavgwk        number;
    v_flg_found       boolean := false;
    v_count           number := 0;
    v_secur           boolean := false;
    v_secur_codempid  temploy1.codempid%type := null;
    cursor c1_tpaysum is
      select a.codcomp, a.codempid, b.typleave, b.dteyear, b.codleave, a.numlvl,
             avg(b.qtyvacat) as typeleav_V,
             avg(b.qtydleot) as typeleav_C,
            (sum(b.qtydlemx) + sum(b.qtyprimx)) as typeleav_T,
             sum(b.qtydayle) qtydayle,
             sum(b.qtylepay) qtylepay
        from temploy1 a ,tleavsum b
       where a.codempid =    b.codempid
         and a.codcomp  like p_codcomp || '%'
         and a.codempid =    nvl(p_codempid, a.codempid)
         and b.dteyear  =    p_dteyear
         and a.staemp   <>   0
    group by a.codcomp, a.codempid, a.numlvl, b.typleave, b.dteyear, b.codleave
    order by a.codcomp, a.codempid, a.numlvl, b.typleave, b.dteyear, b.codleave;
  begin
    for r1 in c1_tpaysum loop
      begin
        select flgdlemx, qtydlepay
          into v_flgdlemx, v_qtydlepay
          from tleavety
         where typleave = r1.typleave;
      exception when no_data_found then
        v_flgdlemx  := null;
        v_qtydlepay := 0;
      end;
      begin
        select staleave
          into v_staleave
          from tleavecd
         where typleave = r1.typleave
           and rownum = '1';
      exception when no_data_found then
        v_staleave := null;
      end;
      if v_flgdlemx = 'Y' then
        v_qtyvacats := nvl(v_qtydlepay, 0);--User37 #1737 Final Test Phase 1 V11 13/02/2021 v_qtyvacats := r1.typeleav_T;
      elsif v_staleave = 'V' then
        v_qtyvacats := r1.typeleav_V;
      elsif v_staleave = 'C' then
        v_qtyvacats := r1.typeleav_C;
      else
        v_qtyvacats := nvl(v_qtydlepay, 0);
      end if;
      v_over := nvl(v_qtyvacats,0) - nvl(r1.qtydayle,0);
      if v_over < 0 then
        v_flg_found := true;
        if v_secur_codempid <> r1.codempid or v_secur_codempid is null then
          v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          v_secur_codempid := r1.codempid;
        end if;
        if v_secur then
          v_qtyavgwk  := hcm_util.get_qtyavgwk(r1.codcomp,null);
          obj_data      := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('typleave', r1.typleave);
          obj_data.put('desc_typleave', get_tleavety_name(r1.typleave, global_v_lang));
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('qtyvacats', cal_dhm(v_qtyvacats,v_qtyavgwk));
          obj_data.put('qtydayle' , cal_dhm(r1.qtydayle,v_qtyavgwk));
          obj_data.put('qtylepay' , cal_dhm(r1.qtylepay,v_qtyavgwk));
          obj_data.put('ovrleave' , cal_dhm(abs(v_over),v_qtyavgwk));
          obj_data.put('codcomp'  , r1.codcomp);
          obj_data.put('dteyear'  , r1.dteyear);
          obj_data.put('codleave'  , r1.codleave);
          obj_row.put(to_char(v_count), obj_data);
          v_count := v_count + 1;
        end if;
      end if;
    end loop;

    if not v_flg_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tleavsum');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
				json_str_output := obj_row.to_clob;
      end if;
    end if;
  end;

  function cal_dhm(v_qtymin number,v_qtyavgwk number) return varchar2 as
    v_day  number := 0;
    v_hr   number := 0;
    v_min  number := 0;
    v_dhm  varchar2(4000 char) := '';
  begin
    hcm_util.cal_dhm_hm (v_qtymin,0,0,v_qtyavgwk,'1',v_day,v_hr,v_min,v_dhm);
    return v_dhm;
  end;

end HRAL57X;

/
