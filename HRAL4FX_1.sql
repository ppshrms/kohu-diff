--------------------------------------------------------
--  DDL for Package Body HRAL4FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4FX" as
-- last update: 25/08/2021 18:00
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
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_period            := hcm_util.get_string_t(json_obj, 'p_period');
    p_year              := hcm_util.get_string_t(json_obj, 'p_year');
    p_month             := hcm_util.get_string_t(json_obj, 'p_month');
    p_maxperson         := hcm_util.get_string_t(json_obj, 'p_maxperson');
    p_sort              := hcm_util.get_string_t(json_obj, 'p_sort');

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

    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_maxperson is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_sort is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_index;

  procedure check_index_head is
  begin
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index_head;

  procedure check_popup_overtime is
  begin
    /*User37 Error #6434 25/02/2019
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;*/
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_sort is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_popup_overtime;

  function display_ot_hours (p_min number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_min, 0) > 0 then
      v_hou_display        := trunc(p_min / 60);
      v_min_display        := lpad(mod(p_min, 60), 2, '0');
      return v_hou_display || ':' || v_min_display;
    else
      if p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
  exception when others then
    return p_min;
  end;

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
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flgsecur         varchar2(1 char) := 'N';
    v_codincom1        varchar2(4 char);
    v_amtpay           number;
    v_codempid         varchar2(100 char);
    v_last_qtymot      number;
    v_last_amtottot    number;
    v_payot            number;
    v_perot            number;
    v_last_payot       number;
    v_last_perot       number;
    v_diff_minot       number;
    v_diff_payot       number;
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);
    v_check_secur      boolean;

    cursor c1 is
      select * from (
        select a.codempid, b.codcomp, b.codpos, nvl(sum(a.qtymin), 0) qtymot, nvl(sum(stddec(a.amtpay, a.codempid, v_chken)), 0) amtottot
          from tpaysum a, temploy1 b
         where a.codempid = b.codempid
           and a.codcomp like p_codcomp || '%'
           and a.dteyrepay  = (p_year - global_v_zyear)
           and a.dtemthpay  = p_month
           and a.numperiod  = nvl(p_period, a.numperiod)
           and a.codalw     = 'OT'
         --   and rownum <= to_number(p_maxperson)
      group by a.codempid, b.codcomp, b.codpos
        order by decode(p_sort,'1',qtymot,amtottot) desc
    )
--    where rownum <= to_number(p_maxperson)  --<< user20 Date: 01/09/2021  AL Module- #6206
    ;
   -- order by decode(p_sort,'1',qtymot,amtottot) desc;--User37 Error #6434 26/02/2019 order by amtottot desc;

    cursor c2 is
      select dteyrepay, dtemthpay, numperiod
        from tpaysum
       where codempid = v_codempid
         and dteyrepay || lpad(dtemthpay, 2, '0') || numperiod < to_char(p_year - global_v_zyear) || lpad(p_month, 2, '0') || to_char(nvl(p_period, numperiod))
    order by dteyrepay || lpad(dtemthpay, 2, '0') || numperiod desc
    fetch next 1
    rows only;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      v_flgdata            := 'Y';
      v_codincom1          := '';
      v_amtpay             := 0;
      v_last_qtymot        := 0;
      v_last_amtottot      := 0;
      obj_data             := json_object_t();

      v_codempid           := r1.codempid;
      v_payot              := 0;
      v_perot              := 0;
      v_last_payot         := 0;
      v_last_perot         := 0;
      v_diff_minot         := 0;
      v_diff_payot         := 0;

      v_check_secur     := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur        := 'Y';
        begin
          select codincom1
            into v_codincom1
            from tcontpms
           where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)--User37 Error #6434 25/02/2019
             and dteeffec = (select max(dteeffec)
                               from tcontpms
                               where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)--User37 Error #6434 25/02/2019
                                 and dteeffec <= trunc(sysdate));
        end;

        begin
          select sum(to_number(stddec(amtpay, codempid, v_chken)))
            into v_amtpay
            from tsincexp
           where codempid  = v_codempid
             and dteyrepay = (p_year - global_v_zyear)
             and dtemthpay = p_month
             and numperiod = nvl(p_period, numperiod)
             and codpay    = v_codincom1;
        end;

        if nvl(v_zupdsal, 'Y') = 'Y' then
          v_payot := nvl(r1.amtottot, 0);
        end if;

        if v_amtpay > 0 then
          if nvl(v_zupdsal, 'Y') = 'Y' then
            v_perot := nvl(ROUND(r1.amtottot * 100 / v_amtpay, 2), 0);
          end if;
        else
          v_perot := 0;
        end if;

        for r2 in c2 loop
          begin
            select sum(qtymin), nvl(sum(stddec(amtpay, codempid, v_chken)), 0)
              into v_last_qtymot, v_last_amtottot
              from tpaysum
             where codempid   = v_codempid
               and dteyrepay  = r2.dteyrepay
               and dtemthpay  = r2.dtemthpay
               and (numperiod = r2.numperiod or p_period is null)
               and codalw     = 'OT';
          end;

          if nvl(v_zupdsal, 'Y') = 'Y' then
            v_last_payot := nvl(v_last_amtottot, 0);
          end if;
          exit;
        end loop;

        if v_amtpay > 0 then
          if nvl(v_zupdsal, 'Y') = 'Y' then
            v_last_perot := nvl(ROUND(v_last_amtottot * 100 / v_amtpay, 2), 0);
          end if;
        else
          v_last_perot := 0;
        end if;

        v_diff_minot := abs(r1.qtymot - v_last_qtymot);
        v_diff_payot := abs(v_payot - v_last_payot);

        if (v_codcomp is null and r1.codcomp is not null) or not (v_codcomp like r1.codcomp) then
            cmp_codcomp(v_codcomp, r1.codcomp, v_lvlst, v_lvlen);
            for lvl in v_lvlst..v_lvlen loop
                get_center_name_lvl(r1.codcomp, lvl, global_v_lang, v_namcentlvl, v_namcent);
  --                obj_data := json();
  --                obj_data.put('coderror', '200');
  --                obj_data.put('codempid', v_namcentlvl);
  --                obj_data.put('desc_codempid', v_namcent);
  ----                obj_row.put(to_char(v_rcnt), obj_data);
  --                v_rcnt := v_rcnt + 1;
            end loop;
            v_codcomp := r1.codcomp;
        end if;

        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(v_codempid));
        obj_data.put('codempid', v_codempid);
        obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        if nvl(v_zupdsal, 'Y') = 'Y' then
          obj_data.put('v_amtpay', display_currency(v_amtpay));
          obj_data.put('amtottot', display_currency(v_payot));
          obj_data.put('v_last_payot', display_currency(v_last_payot));
          obj_data.put('v_diff_payot', display_currency(v_diff_payot));
        end if;
--        obj_data.put('qtymot', display_ot_hours(r1.qtymot));
        obj_data.put('qtymot', (r1.qtymot));
        obj_data.put('v_perot', v_perot);
--        obj_data.put('v_last_qtymot', display_ot_hours(v_last_qtymot));
        obj_data.put('v_last_qtymot', (v_last_qtymot));
        obj_data.put('v_last_perot', v_last_perot);
--        obj_data.put('v_diff_minot', display_ot_hours(v_diff_minot));
        obj_data.put('v_diff_minot', (v_diff_minot));
        obj_data.put('period', to_char(p_period));
        obj_data.put('year', to_char(p_year));
        obj_data.put('month', to_char(p_month));
        obj_data.put('sort', to_char(p_sort));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end if;
--<< user20 Date: 01/09/2021  AL Module- #6206
      if v_rcnt >= p_maxperson then
        exit;
      end if;
--<< user20 Date: 01/09/2021  AL Module- #6206
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tpaysum');
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

  procedure get_index_head (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index_head;
    if param_msg_error is null then
      gen_index_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index_head;

  procedure gen_index_head (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_exist            varchar2(1 char) := 'N';
    cursor c1 is
      select codempid, codcomp, codpos
        from temploy1
       where codempid = p_codempid
       fetch next 1
       rows only;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in c1 loop
      obj_data          := json_object_t();
      v_flgdata         := 'Y';
      v_rcnt            := v_rcnt + 1;

      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcompny_name(r1.codcomp, global_v_lang));
      obj_data.put('desc_codcomp_', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));

      if isInsertReport then
        insert_ttemprpt_head(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
--    else
--      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index_head;

  procedure get_popup_overtime (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_popup_overtime;
    if param_msg_error is null then
      gen_popup_overtime(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup_overtime;

  procedure gen_popup_overtime (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_exist             boolean := false;
    v_secur             boolean := false;
    v_permis            boolean := false;
    v_codincom1         varchar2(4 char);
    v_amtpay            number;
    v_codempid          varchar2(100 char);
    v_last_qtymot       number;
    v_last_amtottot     number;
    v_payot             number;
    v_perot             number;
    v_last_payot        number;
    v_last_perot        number;
    v_ot_rate           varchar2(100 char);
    v_check_secur       boolean;

    v_now_otamount      number;
    v_last_otamount     number;
    v_now_oth           varchar2(100 char);
    v_last_oth          varchar2(100 char);
    v_codpos            tpostn.codpos%type;
    v_codcomp           tcenter.codcomp%type;
    v_seq               number := 0;
    type a_number is table of number index by binary_integer;
         a_rtesmot      a_number;
         a_qtymot       a_number;
         a_amtottot     a_number;
    type a_varchar is table of varchar2(200) index by binary_integer;
         a_from         a_varchar;

  cursor c1 is
    select v_from, rtesmot, sum(qtymot) as qtymot, sum(amtottot) amtottot
     from(
        select 'A' as v_from, rtesmot, qtymot, nvl(stddec(amtottot, codempid, v_chken), 0) amtottot
          from tpaysumd
         where codempid  = p_codempid
           and dteyrepay = (p_year)
           and dtemthpay = p_month
           and numperiod = nvl(p_period, numperiod)
     union all
        select 'B' as v_from, rtesmot, qtymot, nvl(stddec(amtottot, codempid, v_chken), 0) amtottot
          from tpaysumd
         where codempid = p_codempid
           and ((dteyrepay||lpad(dtemthpay, 2, '0')||numperiod = (select max(dteyrepay||lpad(dtemthpay, 2, '0')||numperiod)
                                                                 from tpaysumd
                                                                where codempid = p_codempid
                                                                  and (dteyrepay||lpad(dtemthpay, 2, '0')||numperiod) < to_char(p_year)||lpad(p_month, 2, '0')||p_period)
                and p_period is not null
               )
            or
               (dteyrepay||lpad(dtemthpay, 2, '0') = (select max(dteyrepay||lpad(dtemthpay, 2, '0'))
                                                      from tpaysumd
                                                     where codempid = p_codempid
                                                       and (dteyrepay||lpad(dtemthpay,2,'0')) < to_char(p_year)||lpad(p_month, 2, '0'))
                and p_period is null
                ))
         )
    group by v_from, rtesmot
    order by rtesmot, v_from;

  begin
    v_check_secur     := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for r1 in c1 loop
      v_seq := v_seq + 1;
      a_from(v_seq)      := r1.v_from;
      a_rtesmot(v_seq)   := r1.rtesmot;
      a_qtymot(v_seq)    := r1.qtymot;
      a_amtottot(v_seq)  := r1.amtottot;
    end loop;

    for i in 1..v_seq loop
      v_ot_rate     := a_rtesmot(i);
      v_ot_rate     := to_char(v_ot_rate, 'fm990.0');
      if a_from(i) = 'A' then
--        prg_exchg(a_qtymot(i), v_now_oth);
        v_now_oth := hcm_util.convert_minute_to_hour(a_qtymot(i));
        if v_zupdsal = 'Y' then
          v_now_otamount := a_amtottot(i);
        end if;
      else
--        prg_exchg(a_qtymot(i), v_last_oth);
        v_last_oth := hcm_util.convert_minute_to_hour(a_qtymot(i));
        if v_zupdsal = 'Y' then
          v_last_otamount := a_amtottot(i);
        end if;
      end if;

      if a_rtesmot.exists(i + 1) then
        if a_rtesmot(i) <> a_rtesmot(i + 1) then
          obj_data        := json_object_t();
          v_rcnt          := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_data.put('codempid', p_codempid);
          obj_data.put('v_ot_rate', v_ot_rate);
          obj_data.put('qtymot', v_now_oth);
          --obj_data.put('amtottot', v_now_otamount); --#6207 || user39 ||25/08/2021
          obj_data.put('amtottot', to_char(v_now_otamount,'fm999,999,990.00')); --#6207 || user39 ||25/08/2021
          obj_data.put('v_last_qtymot', v_last_oth);
          --obj_data.put('v_last_payot', v_last_otamount); --#6207 || user39 || 01/09/2021 || ReOpen
          obj_data.put('v_last_payot', to_char(v_last_otamount,'fm999,999,990.00')); --#6207 || user39 || 01/09/2021 || ReOpen
          obj_data.put('year', p_year);
          obj_data.put('month', p_month);
          obj_data.put('period', p_period);
          obj_data.put('numseq', v_rcnt);
          if isInsertReport then
            insert_ttemprpt_table(obj_data);
          end if;

          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt          := v_rcnt + 1;
          v_now_oth       := null;
          v_now_otamount  := null;
          v_last_oth      := null;
          v_last_otamount := null;
          continue;
        end if;
      else
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('codempid', p_codempid);
        obj_data.put('v_ot_rate', v_ot_rate);
        obj_data.put('qtymot', v_now_oth);
        --obj_data.put('amtottot', v_now_otamount);  --#6207 || user39 ||25/08/2021
        obj_data.put('amtottot', to_char(v_now_otamount,'fm999,999,990.00'));  --#6207 || user39 ||25/08/2021
        obj_data.put('v_last_qtymot', v_last_oth);
        --obj_data.put('v_last_payot', v_last_otamount);  --#6207 || user39 ||01/09/2021 || ReOpen
        obj_data.put('v_last_payot', to_char(v_last_otamount,'fm999,999,990.00'));  --#6207 || user39 ||01/09/2021 || ReOpen
        obj_data.put('year', p_year);
        obj_data.put('month', p_month);
        obj_data.put('period', p_period);
        obj_data.put('numseq', v_rcnt);

        if isInsertReport then
          insert_ttemprpt_table(obj_data);
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
--        v_rcnt        := v_rcnt + 1;
      end if;
    end loop;

--    if v_exist then
      json_str_output := obj_row.to_clob;
--    else
--      param_msg_error      := get_error_msg_php('HR2055', global_v_lang);
--      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
--    end if;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_popup_overtime;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
    v_check_secur   boolean;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    v_check_secur       := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);

  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
--      clear_ttemprpt;
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codempid        := hcm_util.get_string_t(p_index_rows, 'codempid');
--        p_codcomp         := hcm_util.get_string_t(p_index_rows, 'codcomp');
        p_year            := hcm_util.get_string_t(p_index_rows, 'year');
        p_month           := hcm_util.get_string_t(p_index_rows, 'month');
        p_period          := hcm_util.get_string_t(p_index_rows, 'period');
        p_sort            := hcm_util.get_string_t(p_index_rows, 'sort');

        p_codapp := 'HRAL4FX';
        gen_index_head(json_output);
        p_codapp := 'HRAL4FX1';
        gen_popup_overtime(json_output);

      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_head(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_year_             varchar2(100 char);
    v_month             varchar2(100 char);
    v_period            number := 0;
    v_report            varchar2(100 char);
    v_numperiod         varchar2(100 char);

    v_date              date;
    v_dtework           varchar2(100 char) := '';

    v_codempid          varchar2(1000 char) := '';
    v_desc_codempid     varchar2(1000 char) := '';
    v_desc_codcomp_     varchar2(1000 char) := '';
    v_desc_codpos       varchar2(1000 char) := '';

  begin
    v_codempid            := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_desc_codempid       := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_desc_codcomp_       := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp_'), '');
    v_desc_codpos         := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4, item5
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
            'header',
            v_codempid,
            v_desc_codempid,
            v_desc_codcomp_,
            v_desc_codpos
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_head;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_year_             varchar2(100 char);
    v_month             varchar2(100 char);
    v_period            number := 0;
    v_report            varchar2(100 char);
    v_numperiod         varchar2(100 char);
    v_date              date;
    v_dtework           varchar2(100 char) := '';

    v_codempid          varchar2(1000 char) := '';
--    v_year              varchar2(1000 char) := '';
--    v_month             varchar2(1000 char) := '';
--    v_period            varchar2(1000 char) := '';
    v_ot_rate           varchar2(1000 char) := '';
    v_qtymot            varchar2(1000 char) := '';
    v_amtottot          varchar2(1000 char) := '';
    v_last_qtymot       varchar2(1000 char) := '';
    v_last_payot        varchar2(1000 char) := '';
    v_numseq_           varchar2(1000 char) := '';
    v_item3             varchar2(1000 char);
    v_item4             varchar2(1000 char);
    v_item5             varchar2(1000 char);

  begin
    v_codempid          := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_ot_rate           := nvl(hcm_util.get_string_t(obj_data, 'v_ot_rate'), '');
    v_qtymot            := nvl(hcm_util.get_string_t(obj_data, 'qtymot'), '');
    v_amtottot          := nvl(hcm_util.get_string_t(obj_data, 'amtottot'), '');
    v_last_qtymot       := nvl(hcm_util.get_string_t(obj_data, 'v_last_qtymot'), '');
    v_last_payot        := nvl(hcm_util.get_string_t(obj_data, 'v_last_payot'), '');
    v_numseq_           := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'year'), '');
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'month'), '');
    v_item5 := nvl(hcm_util.get_string_t(obj_data, 'period'), '');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'table',
              v_codempid,
              v_item3,
              v_item4,
              v_item5,
              v_ot_rate,
              v_qtymot,
              v_amtottot,
              v_last_qtymot,
              v_last_payot,
              v_numseq_
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_table;

/*  PROCEDURE prg_exchg(code in number,code2 out varchar2) IS
    num1 number;
    num2 number;
  BEGIN
    if code is not null then
      num1  := trunc(code/60);
      num2  := ABS(code mod 60) ;
      code2 := num1||':'||Lpad(num2,2,'0');
    else
      code2 := ' ';
    end if;
  end;*/
end hral4fx;

/
