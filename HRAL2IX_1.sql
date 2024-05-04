--------------------------------------------------------
--  DDL for Package Body HRAL2IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL2IX" is
-- last update: 07/12/2017 11:23
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    --<<nut 
    p_secure boolean;
    v_chk    varchar2(1);
    -->>nut 
  begin
    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codcomp');
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      else
        p_codcomp := p_codcomp || '%';
      end if;
    end if;
    if p_codempid is not null then
      --<<User37 Final Test Phase 1 V11 #2665 15/10/2020 
      --param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid,false);
      begin
          select 'Y'
            into v_chk
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
        null;
      end; 
      if v_chk = 'N' then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      else
        p_secure := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not p_secure then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        end if;
      end if;
      -->>User37 Final Test Phase 1 V11 #2665 15/10/2020 
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR6625', global_v_lang);
    end if;
    if p_dteend - p_dtestrt > 30 then
      param_msg_error := get_error_msg_php('HR2098', global_v_lang);
    end if;
  end;

  procedure get_tleavecd (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    gen_tleavecd (json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tleavecd;

  procedure gen_tleavecd (json_str_output out clob) is
    obj_desc        json_object_t;
    obj_row         json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;
    v_row           number := 0;
    v_codcompy      tleavcom.codcompy%type;
    cursor c1 is
      select t1.codleave, t1.typleave, t1.namleavcde,
             t1.namleavcdt, t1.namleavcd3, t1.namleavcd4,
             t1.namleavcd5, t1.flgleave
        from tleavecd t1,tleavcom t2
       where t1.typleave = t2.typleave
         and t2.codcompy = v_codcompy
    order by codleave;

  begin
    if p_codempid is not null then
        select hcm_util.get_codcompy(codcomp)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
    else
        v_codcompy := hcm_util.get_codcompy(p_codcomp);
    end if;
    obj_row     := json_object_t();
    obj_lang1   := json_object_t();
    obj_lang2   := json_object_t();
    obj_lang3   := json_object_t();
    obj_lang4   := json_object_t();
    obj_lang5   := json_object_t();
    for r1 in c1 loop
      v_row := v_row + 1;
      obj_desc := json_object_t();
      obj_desc.put('key', r1.codleave);
      obj_desc.put('value', r1.namleavcde);
      obj_lang1.put(to_char(v_row - 1), obj_desc);

      obj_desc.put('value', r1.namleavcdt);
      obj_lang2.put(to_char(v_row - 1), obj_desc);

      obj_desc.put('value', r1.namleavcd3);
      obj_lang3.put(to_char(v_row - 1), obj_desc);

      obj_desc.put('value', r1.namleavcd4);
      obj_lang4.put(to_char(v_row - 1), obj_desc);

      obj_desc.put('value', r1.namleavcd5);
      obj_lang5.put(to_char(v_row - 1), obj_desc);

    end loop;
    obj_row.put('coderror', '200');
    obj_row.put('obj_lang1', obj_lang1);
    obj_row.put('obj_lang2', obj_lang2);
    obj_row.put('obj_lang3', obj_lang3);
    obj_row.put('obj_lang4', obj_lang4);
    obj_row.put('obj_lang5', obj_lang5);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_desc_month (v_date date) return varchar2 as
    v_label number;
    v_month number;
  begin
    v_month := extract(month from v_date);
    v_label := v_month*10 + 300;
    return get_label_name('HRAL2IX',global_v_lang,to_char(v_label));
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    json_obj        json_object_t := json_object_t();
    obj_tmp         json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_col         json_object_t;
    obj_col2        json_object_t;
    v_codempid      varchar2(4000 char);
    rcnt            number := 0;
    v_exist         varchar2(1 char);
    flg_data        varchar2(1 char) := 'N';
    v_index         number := 0;
    v_dtestr        date;
    cursor c1_tattence is
      select codempid, numlvl, codcomp, codpos, dtework,
             listagg(typwork, ',') within group (order by typwork) typwork,
             listagg(codshift, ',') within group (order by codshift) codshift,
             listagg(codleave, ',') within group (order by codleave) codleave,
             sum(lateabs) lateabs, sum(qtyminot) qtyminot, sum(qtymin) qtymin
        from (
              select t2.codempid,
                     t2.numlvl,
                     t2.codcomp,
                     t2.codpos,
                     t1.dtework,
                     t1.typwork,
                     t1.codshift,
                     null as codleave,
                     null as lateabs,
                     null as qtyminot,
                     null as qtymin
                from tattence t1, temploy1 t2
               where t1.codempid = t2.codempid
              union all
              select t2.codempid,
                     t2.numlvl,
                     t2.codcomp,
                     t2.codpos,
                     t3.dtework,
                     null as typwork,
                     null as codshift,
                     t3.codleave,
                     null as lateabs,
                     null as qtyminot,
                     t3.qtymin
                from temploy1 t2, tleavetr t3
               where t2.codempid = t3.codempid
              union all
              select t2.codempid,
                     t2.numlvl,
                     t2.codcomp,
                     t2.codpos,
                     t4.dtework,
                     null as typwork,
                     null as codshift,
                     null as codleave,
                     (t4.qtylate + t4.qtyearly + t4.qtyabsent) as lateabs,
                     null as qtyminot,
                     null as qtymin
                from temploy1 t2 , tlateabs t4
               where t2.codempid = t4.codempid
              union all
              select t2.codempid,
                     t2.numlvl,
                     t2.codcomp,
                     t2.codpos,
                     t5.dtework,
                     null as typwork,
                     null as codshift,
                     null as codleave,
                     null as lateabs,
                     t5.qtyminot,
                     null as qtymin
                from temploy1 t2, totpaydt t5
               where t2.codempid = t5.codempid
             )
      where codcomp  like nvl(p_codcomp, codcomp)
        and codempid = nvl(p_codempid, codempid)
        and dtework  between p_dtestrt and p_dteend
        and (
             (v_exist = '1') or
             (v_exist = '2'  and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, codempid) = 'Y')
            )
      group by codempid, numlvl, codcomp, codpos, dtework
      order by codempid, dtework;
  begin
    v_exist     := '1';
    for c1 in c1_tattence loop
      flg_data      := 'Y';
      exit;
    end loop;
    if flg_data = 'N' then
      param_msg_error     := get_error_msg_php('HR2055', global_v_lang, 'tattence');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    flg_data    := 'N';
    v_exist     := '2';
    obj_row     := json_object_t();
    obj_tmp     := json_object_t();
    for r1 in c1_tattence loop
        flg_data      := 'Y';
        if nvl(v_codempid,'$%#') <> r1.codempid then
          if obj_tmp.get_size > 0 then
            obj_row.put(to_char(rcnt), obj_tmp);
            rcnt := rcnt + 1;
          end if;
          v_index := 1;
          obj_tmp := json_object_t();
          v_dtestr := p_dtestrt;
          obj_tmp.put('codempid', r1.codempid);
          obj_tmp.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_tmp.put('codcomp', r1.codcomp);
          obj_tmp.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
          obj_tmp.put('codpos', r1.codpos);
          obj_tmp.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_tmp.put('dtestrt', to_char(p_dtestrt, 'DDMMYYYY'));
          obj_tmp.put('dteend' , to_char(p_dteend , 'DDMMYYYY'));
          v_codempid := r1.codempid;
        end if;
        obj_tmp.put('typwork-label', get_label_name('HRAL2IX', global_v_lang, 60));
        obj_tmp.put('codshift-label', get_label_name('HRAL2IX', global_v_lang, 110));
        obj_tmp.put('dteleave-label', get_label_name('HRAL2IX', global_v_lang, 200));
        obj_tmp.put('abnmatdn-label', get_label_name('HRAL2IX', global_v_lang, 180));
        obj_tmp.put('timeot-label', get_label_name('HRAL2IX', global_v_lang, 190));

        v_index := r1.dtework - v_dtestr + 1;
        obj_tmp.put('typwork-'  || to_char(v_index),r1.typwork);
        obj_tmp.put('codshift-' || to_char(v_index),r1.codshift);
        obj_tmp.put('dteleave-' || to_char(v_index),r1.codleave || ' ' || hcm_util.convert_minute_to_hour(r1.qtymin));
        obj_tmp.put('abnmatdn-' || to_char(v_index),calHour(r1.lateabs));
        obj_tmp.put('timeot-'   || to_char(v_index),calHour(r1.qtyminot));
    end loop;
    if obj_tmp.get_size > 0 then
      obj_row.put(to_char(rcnt), obj_tmp);
    end if;
    json_obj.put('rows',obj_row);
    obj_col := json_object_t();
    v_index := 1;
    for i in 0..(p_dteend - p_dtestrt) loop
      obj_col2 := json_object_t();
      obj_col2.put('desc_column', to_char((p_dtestrt+i), 'dd/mm/yyyy'));
      obj_col.put(to_char(v_index),obj_col2);
      v_index := v_index + 1;
    end loop;
    json_obj.put('columns',obj_col);
    json_obj.put('coderror', '200');
    if flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := json_obj.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_summary (json_str_input in clob, json_str_output out clob) as
    obj_result      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_normal        number := 0;
    v_amount        number := 0;
    v_ot            number := 0;
    v_late          number := 0;
    v_early         number := 0;
    v_tabs          number := 0;
    v_leave         number := 0;
    v_rcnt          number := 0;
    v_codcompy      TCENTER.CODCOMPY%TYPE;
    obj_ot_col      json_object_t;
    v_qtyminot      number;
    v_rteotpay      number(3, 2);

    cursor c_rteotpay is
      select rteotpay, sum(qtyminot) qtyminot
          into v_rteotpay, v_qtyminot
          from totpaydt t1, temploy1 t2
         where t1.codempid = t2.codempid(+)
           and t2.codcomp  like nvl(p_codcomp, t2.codcomp)
           and t1.codempid = nvl(p_codempid, t1.codempid)
           and t1.dtework  between p_dtestrt and p_dteend
           and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, t2.codempid) = 'Y'
        group by rteotpay
        order by rteotpay;
  begin
    initial_value (json_str_input);
    check_index;

    if p_codempid is not null then
      begin
        select hcm_util.get_codcompy(codcomp)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcompy    := '';
      end;
    else
      v_codcompy      := hcm_util.get_codcompy(p_codcomp);
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);

    begin
      select sum(nvl(t1.qtyhwork,0)),count(distinct(t1.codempid))
        into v_normal, v_amount
        from tattence t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp  like nvl(p_codcomp, t1.codcomp)
         and t1.codempid = nvl(p_codempid, t1.codempid)
         and t1.dtework  between p_dtestrt and p_dteend
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, t2.codempid) = 'Y';
    end;

    begin
--      select sum(nvl(qtylate,0) + nvl(qtyearly,0))-- + qtytabs)
      select sum(nvl(qtylate,0)), sum(nvl(qtyearly,0)), sum(nvl(qtytabs,0))
        into v_late, v_early, v_tabs
        from tlateabs t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp  like nvl(p_codcomp, t1.codcomp)
         and t1.codempid = nvl(p_codempid, t1.codempid)
         and t1.dtework  between p_dtestrt and p_dteend
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, t2.codempid) = 'Y';
    end;

    begin
      select sum(nvl(qtymin,0))
        into v_leave
        from tleavetr t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp  like nvl(p_codcomp, t1.codcomp)
         and t1.codempid = nvl(p_codempid, t1.codempid)
         and t1.dtework  between p_dtestrt and p_dteend
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, t2.codempid) = 'Y';
    end;

    v_ot          := 0;
    obj_row       := json_object_t();
    for i in c_rteotpay loop
      obj_data        := json_object_t();
      obj_data.put('coderror', 200);
      obj_data.put('label', get_label_name('HRAL2IX', global_v_lang, '240') || ' ' || to_char(i.rteotpay, 'fm0.0'));
      obj_data.put('qtyminot', hcm_util.convert_minute_to_hour(i.qtyminot));
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt    := v_rcnt + 1;
      v_ot      := v_ot + i.qtyminot;
    end loop;

    obj_result     := json_object_t();
    obj_result.put('coderror', '200');
--    obj_result.put('normal', calHour(nvl(v_normal - (v_late + v_leave), 0)));
--    obj_result.put('normal', hcm_util.convert_minute_to_hour(nvl(v_normal,0) - (nvl(v_late,0) + nvl(v_early,0)))); --+ nvl(v_leave,0)));
    obj_result.put('normal', hcm_util.convert_minute_to_hour(nvl(v_normal,0))); --+ nvl(v_leave,0)));
    obj_result.put('abnormal', hcm_util.convert_minute_to_hour(nvl(v_late,0) + nvl(v_early,0) + nvl(v_tabs,0)));
    obj_result.put('amount', nvl(v_amount,0));
    obj_result.put('leave', hcm_util.convert_minute_to_hour(nvl(v_leave,0)));
    obj_result.put('ot', hcm_util.convert_minute_to_hour(nvl(v_ot, 0)));
    obj_result.put('table', obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_summary;

  function calHour (p_min number) return varchar2 is
  begin
    if p_min is not null then
      return to_char(trunc(p_min/60), 'fm9,999,999')||':'||lpad(abs(mod(p_min,60)),2,'0');
    else
      return p_min;
    end if;
  end;

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
         and dteeffec = (select max(b.dteeffec)
                           from totratep2 b
                          where b.codcompy = v_codcompy
                            and b.dteeffec <= sysdate)
    order by rteotpay;
  begin
    obj_ot_col := json_object_t();
    for row_ot in max_ot_col loop
      v_max_ot_col := v_max_ot_col + 1;
      obj_ot_col.put(to_char(v_max_ot_col), row_ot.rteotpay);
    end loop;
    return obj_ot_col;
  exception
  when others then
    return json_object_t();
  end;
end HRAL2IX;

/
