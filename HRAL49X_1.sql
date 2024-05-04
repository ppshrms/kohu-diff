--------------------------------------------------------
--  DDL for Package Body HRAL49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL49X" as
-- last update: 20/04/2018 10:30:00
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
    p_codcomp_index     := upper(hcm_util.get_string_t(json_obj, 'p_codcomp_index'));
    p_codcalen          := upper(hcm_util.get_string_t(json_obj, 'p_codcalen'));
    p_typerep           := upper(hcm_util.get_string_t(json_obj, 'p_typerep'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'ddmmyyyy');

    -- special
    v_text_key          := 'otrate';

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
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_ot_head;

  function display_ot_hours (p_min number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_min, 0) > 0 then
      v_hou_display        := trunc(p_min / 60);
      v_min_display        := lpad(mod(p_min, 60), 2, '0');
      return v_hou_display || ':' || v_min_display;
    else
      if not p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
  exception when others then
    return p_min;
  end;

  function display_work_hours (p_hour number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_hour, 0) > 0 then
      v_hou_display        := p_hour;
      return v_hou_display || ':' || v_min_display;
    else
      if p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
  exception when others then
    return p_hour;
  end;

  function display_currency (p_amtcur number) return varchar2 is
    v_amt_display        varchar2(20 char) := '';
  begin
    v_amt_display := to_char(p_amtcur, 'fm999,999,999,999,990.00');--User37 Final Test Phase 1 V11 #3280 03/11/2020 to_char(p_amtcur, 'fm999,999,990.00');
    return v_amt_display;
  exception when others then
    return p_amtcur;
  end;

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = nvl(v_codcompy, codcompy)
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

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_ot_head;
    if param_msg_error is null then
      gen_ot_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
    obj_data           json_object_t;
    obj_row            json_object_t;
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
    v_count             number;
    v_other             varchar2(100 char);
    v_rateot5           varchar2(100 char);
    v_ot_col            varchar2(100 char);
  begin
    obj_data           := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1);

    for i in 1..v_rateot_length loop
      v_ot_col := hcm_util.get_string_t(obj_ot_col, to_char(i));
      if v_ot_col is not null then
        obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
      else
        obj_data.put(v_text_key||i, ' ');
      end if;
    end loop;

    v_count  := obj_ot_col.get_size;
    v_other  := get_label_name('HRAL49X2', global_v_lang, '200');

    v_rateot5 := null;
    if v_count > v_rateot_length then
      if v_count = v_rateot_length + 1 then
        v_rateot5 := hcm_util.get_string_t(obj_ot_col, to_char(v_rateot_length + 1));
      else
        v_rateot5 := v_other;
        end if;
    end if;
    obj_data.put(v_text_key||to_char(v_rateot_length+1), nvl(v_rateot5, v_other));

    --report--
    if isInsertReport then
      insert_ttemprpt_head(obj_data);
    end if;
    --
    obj_row.put(0, obj_data);
		json_str_output := obj_row.to_clob;
  end gen_ot_head;

  --get index graph--
  procedure gen_graph(obj_row in json_object_t) as
    obj_data    json_object_t;

    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAL49X';
    v_numseq    ttemprpt.numseq%type := 0;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item12    ttemprpt.item12%type;
    v_item31    ttemprpt.item31%type;

    type a_string is table of varchar2(1000 char) index by binary_integer;
    v_arr_item1  	  a_string;
  begin
    v_arr_item1(0) := get_label_name('HRAL49X', global_v_lang, '40');
    v_arr_item1(1) := get_label_name('HRAL49X', global_v_lang, '50');
    v_item31       := get_label_name('HRAL49X', global_v_lang, '60');--header
    begin
      delete
        from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;
    for i in 0..1 loop -- loop item1
      for v_row in 1..obj_row.get_size loop
        obj_data := hcm_util.get_json_t(obj_row, to_char(v_row - 1));
        if hcm_util.get_string_t(obj_data, 'flgbreak') is null then
          v_numseq := v_numseq + 1;
          v_item1 := v_arr_item1(i);
          v_item2 := hcm_util.get_string_t(obj_data, 'desc_codcalen');
          v_item3 := '';
          v_item4 := hcm_util.get_string_t(obj_data, 'codcomp');
          v_item5 := hcm_util.get_string_t(obj_data, 'desc_codcomp');
          v_item6 := '';
          v_item7 := hcm_util.get_string_t(obj_data, 'desc_codcalen');
          v_item8 := hcm_util.get_string_t(obj_data, 'desc_codcalen');
          v_item12 := hcm_util.get_string_t(obj_data, 'codcalen');
          if i = 0 then -- ????? OT filter
            v_item9 := get_label_name('HRAL49X', global_v_lang, '40');
            v_item10:= replace(hcm_util.get_string_t(obj_data, 'wrknormal'), '%', '');
--            v_item10:= replace(hcm_util.get_string_t(obj_data, 'sum_otrate'), '%', '');
          elsif i = 1 then -- ????? ??. filter
            v_item9 := get_label_name('HRAL49X', global_v_lang, '50');
            v_item10:= replace(hcm_util.get_string_t(obj_data, 'salpercent'), '%', '');
--            v_item10:= hcm_util.convert_hour_to_minute(replace(hcm_util.get_string_t(obj_data, 'qtyhour'), '%', ''));
          end if;
          begin
            insert into ttemprpt
              (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item12, item31)
            values
              (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item12, v_item31);
          exception when others then
            rollback;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
            return;
          end;
        end if;
      end loop;
    end loop;
    commit;
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
    v_rcnt             number := 0;
    v_old_codcalen     temploy1.codcalen%type := '#';
    v_item01           varchar2(4000 char);
    v_item02           varchar2(4000 char);
    v_flgbrk           varchar2(4000 char);
    v_ot_count         number := 0;
    v_emp_count        number := 0;
    v_per_day          number := 0;
    v_c_qtyhwork       number := 0;
    v_c_emp_count      number := 0;
    v_c_per_day        number := 0;
    v_sum_qtyhwork     number := 0;
    v_sum_emp_count    number := 0;
    v_sum_qtyminot     number := 0;
    v_sum_ot_count     number := 0;
    v_sum_per_day      number := 0;
    v_amtmth_temp      number := 0;
    --
    v_secur            varchar2(4000 char);
    v_flgdata          varchar2(1 char) := 'N';
    v_exist            varchar2(1 char) := 'N';
    v_codcomp          varchar2(4000 char);
    v_codcompy         varchar2(4000 char);
    v_codcalen         varchar2(4000 char);
    v_text_each        varchar2(4000 char);
    v_text_total       varchar2(4000 char);
    --
    v_codcompw         varchar2(50 char);
    v_chk_row          number := 0;

    v_codcomp_se       varchar2(4000 char);
    --
--    cursor c_tovrtime_first is
--        select t1.codcalen, t1.codcomp,
--               count(distinct t1.codempid) emp_count,
--               sum(stddec(t1.amtottot, t1.codempid, v_chken)) amtottot_count
--          from tovrtime t1, temploy1 t3
--         where t1.codcomp like p_codcomp || '%'
--           and t1.codcalen = nvl(p_codcalen, t1.codcalen)
--           and t1.dtework between p_dtestrt and p_dteend
--           and t1.codempid = t3.codempid
--           and (
--                (v_exist = '1')
--                 or (v_exist = '2'
--                    and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
--                    and exists (select c.coduser
--                                  from tusrcom c
--                                 where c.coduser = global_v_coduser
--                                   and t3.codcomp like c.codcomp || '%')
--                     )
--               )
--           and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
--      group by t1.codcalen, t1.codcomp
--      order by t1.codcalen, t1.codcomp;

    cursor c_tovrtime_second is
        select t1.codcalen, decode(p_typerep,'1',t1.codcomp,'2',t1.codcompw) codcomp,
               count(distinct t1.codempid) emp_count,
               sum(stddec(t1.amtottot, t1.codempid, v_chken)) amtottot_count,
               row_number() over (partition by t1.codcalen, decode(p_typerep,'1',t1.codcomp,'2',t1.codcompw) order by t1.codcalen) rcnt
          from tovrtime t1, temploy1 t3
         where ((t1.codcomp like p_codcomp|| '%' and p_typerep = '1') or (t1.codcompw like p_codcomp|| '%' and p_typerep = '2'))--User37 #4929 Final Test Phase 1 V11 17/03/2021 t1.codcomp like p_codcomp || '%'
           and t1.codcalen = nvl(p_codcalen, t1.codcalen)
           and t1.dtework between p_dtestrt and p_dteend
           and t1.codempid = t3.codempid
           and (
                (v_exist = '1')
                 or (v_exist = '2'
                    and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                    and exists (select c.coduser
                                  from tusrcom c
                                 where c.coduser = global_v_coduser
                                   and t3.codcomp like c.codcomp || '%')
                     )
               )
           --User37 Final Test Phase 1 V11 #2720 19/10/2020 and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
      group by t1.codcalen,decode(p_typerep,'1',t1.codcomp,'2',t1.codcompw)
      order by t1.codcalen, codcomp;

    cursor c_tattence is
        select t2.codempid, nvl(sum(t2.qtyhwork), 0) qtyhwork
          from tattence t2
         where t2.codempid in (select t1.codempid
                                from tovrtime t1, temploy1 t3
                               where t1.codcomp   = v_codcomp
                                 and t1.codcalen  = v_codcalen
                                 and t1.dtework between p_dtestrt and p_dteend
                                 and t1.codempid  = t3.codempid
                                 and (
                                        t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                        and exists (select c.coduser
                                                      from tusrcom c
                                                     where c.coduser = global_v_coduser
                                                       and t3.codcomp like c.codcomp || '%')
                                     )
                                 and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                               )
           and t2.dtework between p_dtestrt and p_dteend
           and t2.typwork in ('L', 'W')
      group by t2.codempid
      order by t2.codempid;

    cursor c_totpaydt is
        select t2.rteotpay, sum(t2.qtyminot) qtyminot
          from tovrtime t1, totpaydt t2, temploy1 t3
         where t1.codempid = t2.codempid
           and t1.dtework  = t2.dtework
           and t1.typot    = t2.typot
           and t1.codempid = t3.codempid
           and ((t1.codcomp = v_codcomp and p_typerep = '1') or (t1.codcompw = v_codcomp and p_typerep = '2'))
         -- and t1.codcomp  = v_codcomp
         -- and nvl(t1.codcompw,t1.codcomp) = v_codcompw
           and t1.codcalen = v_codcalen
           and t1.dtework between p_dtestrt and p_dteend
           and 0 <> (select count(ts.codcomp)
                       from tusrcom ts
                      where ts.coduser = global_v_coduser
                        and t3.codcomp like ts.codcomp || '%'
                        and rownum <= 1)
           and t3.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
      group by t2.rteotpay
      order by t2.rteotpay;
      --
      v_dtemovemt        date;
      v_codempid         varchar2(4000 char);
      v_codpos           varchar2(4000 char);
      v_numlvl           number := 0;
      v_old_codcomp      varchar2(4000 char);
      v_old_codpos       varchar2(4000 char);
      v_codjob           varchar2(4000 char);
      v_codempmt         varchar2(4000 char);
      v_typemp           varchar2(4000 char);
      v_typpayroll       varchar2(4000 char);
      v_codbrlc          varchar2(4000 char);
      v_jobgrade         varchar2(4000 char);
      v_codgrpgl         varchar2(4000 char);
      v_amthour          varchar2(4000 char);
      v_amtday           varchar2(4000 char);
      v_amtmth           varchar2(4000 char);
      v_qtyhwork         number := 0;
      v_qtyhwork_temp    number := 0;
      v_check_codempid   varchar2(4000 char) := '!@#$';
      v_sum_amtmth       number := 0;
      v_qtyminot         number := 0;
      v_qtyminot_all     number := 0;
      v_qtyemp           number := 0;
      --
      v_ot_val           number := 0;
      v_sal_per          number := 0;
      v_ot_per_work      number := 0;
      v_c_ot_val         number := 0;
      v_c_sal_per        number := 0;
      v_c_ot_per_work    number := 0;
      v_c_sum_amtmth     number := 0;
      v_sum_ot_val       number := 0;
      v_sum_sal_per      number := 0;
      v_sum_ot_per_work  number := 0;
      v_sum_total_amtmth number := 0;
      -- value loop3
      obj_ot_col         json_object_t   := get_ot_col(v_codcompy);
      v_rateot           arr_1d;
      v_rateot_sum       arr_num;
      v_rateot_cal       arr_num;
      v_check_rteot      number := 0;
      v_count_rteot      number := 0;
      v_rateot5          varchar2(100 char);
      v_rateot_min5      number := 0;
      v_c_otrate5        number := 0;
      v_sum_otrate5      number := 0;
      v_sum_rows         number := 0;
      --
      v_flgsum           boolean := false;
      v_qtyminot_ovr_all number := 0;--User37 #4929 Final Test Phase 1 V11 17/03/2021
--      v_old_codempid     varchar2(1000 char);
--      v_old_codcompw     varchar2(1000 char);
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    -- Set Default Arrays Summary--
    for i_rateot in 1..v_rateot_length loop
      v_rateot_sum(i_rateot)  := 0;
    end loop;
    --
    for i_rateot in 1..v_rateot_length loop
      v_rateot_cal(i_rateot)  := 0;
    end loop;
    --
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    end if;
    --
    v_text_each            := get_label_name('HRAL49X', global_v_lang, '10'); -- Display Text '???'
    v_text_total           := get_label_name('HRAL49X', global_v_lang, '20'); -- Display Text '??????????'
    --
    v_flgdata              := 'N';
    v_exist                := '1';
    --
    for r1 in c_tovrtime_second loop
      v_flgdata            := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tovrtime');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    --
    v_flgdata              := 'N';
    v_exist                := '2';
    --

    for r_tovrtime in c_tovrtime_second loop
      v_flgdata            := 'Y';
      if v_old_codcalen <> r_tovrtime.codcalen then
         if v_old_codcalen = '#' then
            v_item01  := get_tcodec_name('TCODWORK',r_tovrtime.codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            --User37 #4929 Final Test Phase 1 V11 17/03/2021 v_old_codcalen    := r_tovrtime.codcalen;
            v_codcalen := r_tovrtime.codcalen;
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', v_codcalen);
            obj_data.put('codcomp', v_codcalen);
            obj_data.put('desc_codcomp', v_item01);
            --
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;

         else
            v_item01  := v_text_each||' '||get_tcodec_name('TCODWORK',v_old_codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', v_codcalen);
            obj_data.put('codcomp', v_codcalen);
            obj_data.put('desc_codcomp', v_item01);
            obj_data.put('qtyemp', to_char(v_c_emp_count,'fm99,999,990'));
            obj_data.put('saltotal', display_currency(v_c_sum_amtmth));
            obj_data.put('qtyhour', display_ot_hours(v_c_qtyhwork));
            --
            obj_data.put('wrknormal', replace(to_char(v_c_ot_per_work,'fm990.99'),' ')); --#6198||user39||25/08/2021
            obj_data.put('otval', display_currency(v_c_ot_val));
            obj_data.put('salpercent', replace(to_char(v_c_sal_per,'fm990.99'),' '));
            obj_data.put('otkey', v_text_key);
            obj_data.put('otlen', v_rateot_length+1);
            -- loop 1 to 4 --
            for i_rateot in 1..v_rateot_length loop
              obj_data.put(v_text_key||i_rateot, hcm_util.convert_minute_to_hour(v_rateot_cal(i_rateot)));
            end loop;
            -- other
            obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_c_otrate5));

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;
            --
            -- set default sum value --
            --
            for i_rateot in 1..v_rateot_length loop
              v_rateot_cal(i_rateot)  := 0;
            end loop;
            --
            v_c_otrate5      := 0;
            v_c_emp_count    := 0;
            v_c_sum_amtmth   := 0;
            v_c_qtyhwork     := 0;
            --
            v_c_ot_per_work  := 0;
            v_c_ot_val       := 0;
            v_c_sal_per      := 0;
            --
            v_item01  := get_tcodec_name('TCODWORK',r_tovrtime.codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', r_tovrtime.codcalen);
            obj_data.put('codcomp', r_tovrtime.codcalen);
            obj_data.put('desc_codcomp', v_item01);
            --
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;
            --User37 #4929 Final Test Phase 1 V11 17/03/2021 v_old_codcalen    := r_tovrtime.codcalen;
         end if;
        v_qtyminot_all    := 0;--User37 #4929 Final Test Phase 1 V11 17/03/2021
      end if;
      v_item01 := get_tcodec_name('TCODWORK',v_old_codcalen,global_v_lang);
      v_flgbrk := 'Y';
      --
      v_codcomp      := r_tovrtime.codcomp;
      v_codcomp_se   := r_tovrtime.codcomp;
--      v_codcompw     :=  nvl(r_tovrtime.codcompw,r_tovrtime.codcomp);
      v_qtyhwork     := 0;
      v_qtyhwork_temp     := 0;
      v_amtmth       := 0;
      v_amtmth_temp  := 0;
      v_sum_amtmth   := 0;

      v_codcalen := r_tovrtime.codcalen;--User37 #4929 Final Test Phase 1 V11 17/03/2021

      for r_tattence in c_tattence loop
        v_codempid             := r_tattence.codempid;
        v_qtyhwork             := v_qtyhwork + r_tattence.qtyhwork;
        v_qtyhwork_temp        := v_qtyhwork_temp + r_tattence.qtyhwork;
        v_dtemovemt            := p_dteend;

          begin
            select codcomp, codpos, numlvl, codjob, codempmt, typemp,
                   typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
              into v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
                   v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
              from temploy1
             where codempid = v_codempid;
          exception when no_data_found then
            v_codcomp           := null;
            v_codpos            := null;
            v_numlvl            := null;
            v_codjob            := null;
            v_codempmt          := null;
            v_typemp            := null;
            v_typpayroll        := null;
            v_codbrlc           := null;
            v_codcalen          := null;
            v_jobgrade          := null;
            v_codgrpgl          := null;
          end;
          --
          std_al.get_movemt (v_codempid, v_dtemovemt, 'C', 'U',
                             v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
                             v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                             v_amthour, v_amtday, v_amtmth);
        if v_check_codempid <> v_codempid then
          v_check_codempid     := v_codempid;
        end if;
       if r_tovrtime.rcnt = 1 then
          v_sum_amtmth    := v_sum_amtmth + v_amtmth;
       end if;
       v_chk_row := v_chk_row + 1;
        v_amtmth_temp    := v_amtmth;
      end loop;
      --
      v_qtyminot             := 0;
      v_emp_count            := 0;
      v_ot_val               := 0;
      v_flgsum               := false;
      --


      obj_data               := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcalen', r_tovrtime.codcalen);
      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r_tovrtime.codcalen, global_v_lang));
      obj_data.put('codcomp', v_codcomp_se);


--      obj_data.put('codcompw', nvl(r_tovrtime.codcompw,r_tovrtime.codcomp));
--      obj_data.put('desc_codcompw', get_tcenter_name(nvl(r_tovrtime.codcompw,r_tovrtime.codcomp),global_v_lang));
      obj_data.put('v_codcomp', hcm_util.get_codcomp_level(v_codcomp_se,null));
      --
      v_ot_val       := r_tovrtime.amtottot_count;
      if (nvl(v_old_codcomp,'#$%&#')) <> r_tovrtime.codcomp or (v_old_codcalen <> r_tovrtime.codcalen) then--User37 #4929 Final Test Phase 1 V11 17/03/2021 if nvl(v_old_codcomp,'#$%&#') <> r_tovrtime.codcomp then
        v_flgsum       := true;
        v_old_codcomp  := r_tovrtime.codcomp;
--        v_emp_count    := r_tovrtime.emp_count;
        begin
          select count(distinct(codempid)) into v_emp_count
            from tovrtime
           where codcomp  = r_tovrtime.codcomp
             and codcalen = r_tovrtime.codcalen
             and dtework between p_dtestrt and p_dteend;
        end;
        --
        obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp_se,global_v_lang));
        obj_data.put('qtyemp', v_emp_count);
        obj_data.put('saltotal', display_currency(v_sum_amtmth));
        obj_data.put('flgbreak', '');
        if v_qtyhwork <> 0 and v_qtyhwork is not null then
          obj_data.put('qtyhour', display_ot_hours(v_qtyhwork));
        end if;
      else
        v_qtyhwork := 0;
        obj_data.put('flgbreak', 'Y');
      end if;
      v_old_codcalen    := r_tovrtime.codcalen;--User37 #4929 Final Test Phase 1 V11 17/03/2021
      -- loop totpaydt --
      v_rateot5 := null;
      v_rateot_min5 := 0;
      v_count_rteot := 0;
      for r_totpaydt in c_totpaydt loop
        v_check_rteot := 0;
        begin
          select count(*)
            into v_check_rteot
            from totratep2
           where codcompy = nvl(v_codcompy, codcompy)
             and rteotpay = r_totpaydt.rteotpay;
        exception when others then
          v_check_rteot := 0;
        end;

        if v_check_rteot > 0 then
          for i in 1..obj_ot_col.get_size loop
            if r_totpaydt.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
              v_count_rteot := v_count_rteot + 1;
              if v_count_rteot < v_rateot_length + 1 then -- case < 5 rate
                obj_data.put(v_text_key||i, hcm_util.convert_minute_to_hour(r_totpaydt.qtyminot));
                obj_data.put(v_text_key||'_min'||i, r_totpaydt.qtyminot);
                v_qtyminot := v_qtyminot + r_totpaydt.qtyminot;
              else  -- case >= 5 rate (other)
                v_rateot_min5 := v_rateot_min5 + nvl(r_totpaydt.qtyminot, 0);
                v_rateot5 := hcm_util.convert_minute_to_hour(v_rateot_min5);
                v_qtyminot := v_qtyminot + r_totpaydt.qtyminot;
              end if;
            end if;
          end loop;
        else -- case rate other
          v_rateot_min5 := v_rateot_min5 + nvl(r_totpaydt.qtyminot, 0);
          v_rateot5 := hcm_util.convert_minute_to_hour(v_rateot_min5);
          v_qtyminot := v_qtyminot + r_totpaydt.qtyminot;
        end if;
      end loop;
      --
      v_sum_rows := 0;
      for i_rateot in 1..v_rateot_length+1 loop
        v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
        v_sum_rows         := nvl(v_sum_rows,0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
      end loop;
      --
      obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
      obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
      --
      v_sum_rows := v_sum_rows + v_rateot_min5;
      obj_data.put('sum_otrate', v_sum_rows);
      --
--      if v_qtyhwork > 0 then
--        v_ot_per_work        := round((v_qtyminot * 100) / v_qtyhwork, 2);
--      else
--        v_ot_per_work        := 0;
--      end if;
      if v_qtyhwork_temp > 0 then
        v_ot_per_work        := round((v_qtyminot * 100) / v_qtyhwork_temp, 2);
      else
        v_ot_per_work        := 0;
      end if;
      v_qtyminot_all := v_qtyminot_all + v_qtyminot;
      v_qtyminot_ovr_all := nvl(v_qtyminot_ovr_all,0) + nvl(v_qtyminot,0);--User37 #4929 Final Test Phase 1 V11 17/03/2021
      --
      if v_sum_amtmth > 0 then
        v_sal_per            := round((v_ot_val * 100) / v_sum_amtmth, 2);
      else
        v_sal_per            := 0;
      end if;

      --
      obj_data.put('wrknormal', replace(to_char(v_ot_per_work,'990.99'),' '));
      obj_data.put('otval', display_currency(v_ot_val));
      obj_data.put('salpercent', replace(to_char(v_sal_per,'990.99'),' '));
      obj_data.put('otkey', v_text_key);
      obj_data.put('otlen', v_rateot_length+1);
      --
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := nvl(v_rcnt,0) + 1;
      --
      --********** Total *********
      -- Summary Last Codcalen --
      v_c_qtyhwork        := nvl(v_c_qtyhwork,0)       + nvl(v_qtyhwork,0);
      v_c_emp_count       := nvl(v_c_emp_count,0)      + nvl(v_emp_count,0);
      v_c_sum_amtmth      := nvl(v_c_sum_amtmth,0)     + nvl(v_sum_amtmth,0);
      --
      v_c_ot_val          := nvl(v_c_ot_val,0)         + nvl(v_ot_val,0);
      v_c_sal_per         := nvl(v_c_sal_per,0)        + nvl(v_sal_per,0);
      v_c_ot_per_work     := nvl(v_c_ot_per_work,0)    + nvl(v_ot_per_work,0);
      --
      -- Summary Total All --
      v_sum_qtyhwork      := nvl(v_sum_qtyhwork,0)     + nvl(v_qtyhwork,0);
      v_sum_emp_count     := nvl(v_sum_emp_count,0)    + nvl(v_emp_count,0);
      v_sum_total_amtmth  := nvl(v_sum_total_amtmth,0) + nvl(v_sum_amtmth,0);
      --
      v_sum_ot_val        := nvl(v_sum_ot_val,0)       + nvl(v_ot_val,0);
      v_sum_sal_per       := nvl(v_sum_sal_per,0)      + nvl(v_sal_per,0);
      v_sum_ot_per_work   := nvl(v_sum_ot_per_work,0)  + nvl(v_ot_per_work,0);
      --
      -- Loop For Summary Rateot --
      for i_rateot in 1..v_rateot_length loop
        v_rateot_cal(i_rateot)  := nvl(v_rateot_cal(i_rateot),0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
        v_rateot_sum(i_rateot)  := nvl(v_rateot_sum(i_rateot),0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
      end loop;
      --
      v_c_otrate5         := nvl(v_c_otrate5,0)        + nvl(hcm_util.convert_hour_to_minute(v_rateot5),0);
      v_sum_otrate5       := nvl(v_sum_otrate5,0)      + nvl(hcm_util.convert_hour_to_minute(v_rateot5),0);
      --
      --***************
    end loop;

    /************* Total Last Codcalen *************/
    if v_c_sum_amtmth > 0 then
       v_c_sal_per            := round((v_c_ot_val * 100) / v_c_sum_amtmth, 2);
    else
       v_c_sal_per            := 0;
    end if;

    if v_c_qtyhwork > 0 then
        v_c_ot_per_work        := round((v_qtyminot_all * 100) / v_c_qtyhwork, 2);
    else
        v_c_ot_per_work        := 0;
    end if;

    v_item01  := v_text_each||' '||get_tcodec_name('TCODWORK',v_old_codcalen,global_v_lang);
    v_flgbrk  := 'Y';
    --
    obj_data             := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgbreak', v_flgbrk);
    obj_data.put('desc_codcomp', v_item01);
    obj_data.put('qtyemp', to_char(v_c_emp_count,'fm99,999,990'));
    obj_data.put('saltotal', display_currency(v_c_sum_amtmth));
    obj_data.put('qtyhour', display_ot_hours(v_c_qtyhwork));
    --
    obj_data.put('wrknormal', replace(to_char(v_c_ot_per_work,'fm9990.99'),' ')); --#6198||user39||25/08/2021
    obj_data.put('otval', display_currency(v_c_ot_val));
    obj_data.put('salpercent', replace(to_char(v_c_sal_per,'990.99'),' '));
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1);
    -- loop 1 to 4 --
    for i_rateot in 1..v_rateot_length loop
      obj_data.put(v_text_key||i_rateot, hcm_util.convert_minute_to_hour(v_rateot_cal(i_rateot)));
    end loop;
    -- other
    obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_c_otrate5));
    --
    obj_row.put(to_char(v_rcnt), obj_data);
    v_rcnt := nvl(v_rcnt,0) + 1;

    /********** Total All **********/
    if v_sum_total_amtmth > 0 then
       v_sum_sal_per            := round((v_sum_ot_val * 100) / v_sum_total_amtmth, 2);
    else
       v_sum_sal_per            := 0;
    end if;

    if v_sum_qtyhwork > 0 then
        v_sum_ot_per_work        := round((v_qtyminot_ovr_all * 100) / v_sum_qtyhwork, 2);--User37 #4929 Final Test Phase 1 V11 17/03/2021 round((v_qtyminot_all * 100) / v_sum_qtyhwork, 2);
    else
        v_sum_ot_per_work        := 0;
    end if;

    v_item01  := v_text_total;
    v_flgbrk  := 'Y';
    --
    obj_data             := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgbreak', v_flgbrk);
    obj_data.put('desc_codcomp', v_item01);
    obj_data.put('qtyemp', to_char(v_sum_emp_count,'fm99,999,990'));
    obj_data.put('saltotal', display_currency(v_sum_total_amtmth));
    obj_data.put('qtyhour', display_ot_hours(v_sum_qtyhwork));
    --
    obj_data.put('wrknormal', replace(to_char(v_sum_ot_per_work,'990.99'),' '));
    obj_data.put('otval', display_currency(v_sum_ot_val));
    obj_data.put('salpercent', replace(to_char(v_sum_sal_per,'990.99'),' '));
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1);
    -- loop 1 to 4 --
    for i_rateot in 1..v_rateot_length loop
      obj_data.put(v_text_key||i_rateot, hcm_util.convert_minute_to_hour(v_rateot_sum(i_rateot)));
    end loop;
    -- other
    obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_sum_otrate5));
    --
    obj_row.put(to_char(v_rcnt), obj_data);
    v_rcnt := nvl(v_rcnt,0) + 1;
    --
/*
    -- data for graph--
    for r_tovrtime in c_tovrtime_first loop
      v_flgdata            := 'Y';
      if v_old_codcalen <> r_tovrtime.codcalen then
         if v_old_codcalen = '#' then
            v_item01  := get_tcodec_name('TCODWORK',r_tovrtime.codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            v_old_codcalen    := r_tovrtime.codcalen;
            v_codcalen := r_tovrtime.codcalen;
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', v_codcalen);
            obj_data.put('codcomp', v_codcalen);
            obj_data.put('desc_codcomp', v_item01);
            --
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;
         else
            v_item01  := v_text_each||' '||get_tcodec_name('TCODWORK',v_old_codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', v_codcalen);
            obj_data.put('codcomp', v_codcalen);
            obj_data.put('desc_codcomp', v_item01);
            obj_data.put('qtyemp', to_char(v_c_emp_count,'fm99,999,990'));
            obj_data.put('saltotal', display_currency(v_c_sum_amtmth));
            obj_data.put('qtyhour', display_ot_hours(v_c_qtyhwork));
            --
            obj_data.put('wrknormal', replace(to_char(v_c_ot_per_work,'990.99'),' '));
            obj_data.put('otval', display_currency(v_c_ot_val));
            obj_data.put('salpercent', replace(to_char(v_c_sal_per,'990.99'),' '));
            obj_data.put('otkey', v_text_key);
            obj_data.put('otlen', v_rateot_length+1);
            -- loop 1 to 4 --
            for i_rateot in 1..v_rateot_length loop
              obj_data.put(v_text_key||i_rateot, hcm_util.convert_minute_to_hour(v_rateot_cal(i_rateot)));
            end loop;
            -- other
            obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_c_otrate5));

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;
            --
            -- set default sum value --
            --
            for i_rateot in 1..v_rateot_length loop
              v_rateot_cal(i_rateot)  := 0;
            end loop;
            --
            v_c_otrate5      := 0;
            v_c_emp_count    := 0;
            v_c_sum_amtmth   := 0;
            v_c_qtyhwork     := 0;
            --
            v_c_ot_per_work  := 0;
            v_c_ot_val       := 0;
            v_c_sal_per      := 0;
            --
            v_item01  := get_tcodec_name('TCODWORK',r_tovrtime.codcalen,global_v_lang);
            v_flgbrk  := 'Y';
            --
            obj_data             := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgbreak', v_flgbrk);
            obj_data.put('codcalen', r_tovrtime.codcalen);
            obj_data.put('codcomp', r_tovrtime.codcalen);
            obj_data.put('desc_codcomp', v_item01);
            --
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := nvl(v_rcnt,0) + 1;
            v_old_codcalen    := r_tovrtime.codcalen;
         end if;
      end if;
      v_item01 := get_tcodec_name('TCODWORK',v_old_codcalen,global_v_lang);
      v_flgbrk := 'Y';
      --
      v_codcomp      := r_tovrtime.codcomp;
      v_qtyhwork     := 0;
      v_amtmth       := 0;
      v_sum_amtmth   := 0;
      for r_tattence in c_tattence loop
        v_codempid             := r_tattence.codempid;
        v_qtyhwork             := v_qtyhwork + r_tattence.qtyhwork;
        v_dtemovemt            := p_dteend;
        if v_check_codempid <> v_codempid then
          v_check_codempid     := v_codempid;
          begin
            select codcomp, codpos, numlvl, codjob, codempmt, typemp,
                   typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
              into v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
                   v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
              from temploy1
             where codempid = v_codempid;
          exception when no_data_found then
            v_codcomp           := null;
            v_codpos            := null;
            v_numlvl            := null;
            v_codjob            := null;
            v_codempmt          := null;
            v_typemp            := null;
            v_typpayroll        := null;
            v_codbrlc           := null;
            v_codcalen          := null;
            v_jobgrade          := null;
            v_codgrpgl          := null;
          end;
          --
          std_al.get_movemt (v_codempid, v_dtemovemt, 'C', 'U',
                             v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
                             v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                             v_amthour, v_amtday, v_amtmth);
        end if;
        v_sum_amtmth    := v_sum_amtmth + v_amtmth;
      end loop;
      --
      v_qtyminot             := 0;
      v_emp_count            := r_tovrtime.emp_count;
      v_ot_val               := r_tovrtime.amtottot_count;
      --
      obj_data               := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcalen', r_tovrtime.codcalen);
      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r_tovrtime.codcalen, global_v_lang));
      obj_data.put('codcomp', r_tovrtime.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r_tovrtime.codcomp,global_v_lang));
      obj_data.put('v_codcomp', hcm_util.get_codcomp_level(r_tovrtime.codcomp,null));
      obj_data.put('qtyemp', v_emp_count);
      obj_data.put('saltotal', display_currency(v_sum_amtmth));
      obj_data.put('flgbreak', '');
      --
      if v_qtyhwork <> 0 and v_qtyhwork is not null then
        obj_data.put('qtyhour', display_ot_hours(v_qtyhwork));
      end if;
      -- loop totpaydt --
      v_rateot5 := null;
      v_rateot_min5 := 0;
      v_count_rteot := 0;
      for r_totpaydt in c_totpaydt loop
        v_check_rteot := 0;
        begin
          select count(*)
            into v_check_rteot
            from totratep2
           where codcompy = nvl(v_codcompy, codcompy)
             and rteotpay = r_totpaydt.rteotpay;
        exception when others then
          v_check_rteot := 0;
        end;

        if v_check_rteot > 0 then
          for i in 1..obj_ot_col.get_size loop
            if r_totpaydt.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
              v_count_rteot := v_count_rteot + 1;
              if v_count_rteot < v_rateot_length + 1 then -- case < 5 rate
                obj_data.put(v_text_key||i, hcm_util.convert_minute_to_hour(r_totpaydt.qtyminot));
                obj_data.put(v_text_key||'_min'||i, r_totpaydt.qtyminot);
              else  -- case >= 5 rate (other)
                v_rateot_min5 := v_rateot_min5 + nvl(r_totpaydt.qtyminot, 0);
                v_rateot5 := hcm_util.convert_minute_to_hour(v_rateot_min5);
              end if;
            end if;
          end loop;
        else -- case rate other
          v_rateot_min5 := v_rateot_min5 + nvl(r_totpaydt.qtyminot, 0);
          v_rateot5 := hcm_util.convert_minute_to_hour(v_rateot_min5);
        end if;
      end loop;
      --
      v_sum_rows := 0;
      for i_rateot in 1..v_rateot_length+1 loop
        v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
        v_sum_rows         := nvl(v_sum_rows,0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
      end loop;
      --
      obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
      obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
      --
      v_sum_rows := v_sum_rows + v_rateot_min5;
      obj_data.put('sum_otrate', v_sum_rows);
      --
      if v_qtyhwork > 0 then
        v_ot_per_work        := round((v_qtyminot * 100) / v_qtyhwork, 2);
      else
        v_ot_per_work        := 0;
      end if;
      --
      if v_amtmth > 0 then
        v_sal_per            := round((v_ot_val * 100) / v_amtmth, 2);
      else
        v_sal_per            := 0;
      end if;
      --
      obj_data.put('wrknormal', replace(to_char(v_ot_per_work,'990.99'),' '));
      obj_data.put('otval', display_currency(v_ot_val));
      obj_data.put('salpercent', replace(to_char(v_sal_per,'990.99'),' '));
      obj_data.put('otkey', v_text_key);
      obj_data.put('otlen', v_rateot_length+1);
      --
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := nvl(v_rcnt,0) + 1;
      --
      --********** Total *********
      -- Summary Last Codcalen --
      v_c_qtyhwork        := nvl(v_c_qtyhwork,0)       + nvl(v_qtyhwork,0);
      v_c_emp_count       := nvl(v_c_emp_count,0)      + nvl(v_emp_count,0);
      v_c_sum_amtmth      := nvl(v_c_sum_amtmth,0)     + nvl(v_sum_amtmth,0);
      --
      v_c_ot_val          := nvl(v_c_ot_val,0)         + nvl(v_ot_val,0);
      v_c_sal_per         := nvl(v_c_sal_per,0)        + nvl(v_sal_per,0);
      v_c_ot_per_work     := nvl(v_c_ot_per_work,0)    + nvl(v_ot_per_work,0);
      --
      -- Summary Total All --
      v_sum_qtyhwork      := nvl(v_sum_qtyhwork,0)     + nvl(v_qtyhwork,0);
      v_sum_emp_count     := nvl(v_sum_emp_count,0)    + nvl(v_emp_count,0);
      v_sum_total_amtmth  := nvl(v_sum_total_amtmth,0) + nvl(v_sum_amtmth,0);
      --
      v_sum_ot_val        := nvl(v_sum_ot_val,0)       + nvl(v_ot_val,0);
      v_sum_sal_per       := nvl(v_sum_sal_per,0)      + nvl(v_sal_per,0);
      v_sum_ot_per_work   := nvl(v_sum_ot_per_work,0)  + nvl(v_ot_per_work,0);
      --
      -- Loop For Summary Rateot --
      for i_rateot in 1..v_rateot_length loop
        v_rateot_cal(i_rateot)  := nvl(v_rateot_cal(i_rateot),0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
        v_rateot_sum(i_rateot)  := nvl(v_rateot_sum(i_rateot),0) + nvl(hcm_util.convert_hour_to_minute(v_rateot(i_rateot)),0);
      end loop;
      --
      v_c_otrate5         := nvl(v_c_otrate5,0)        + nvl(hcm_util.convert_hour_to_minute(v_rateot5),0);
      v_sum_otrate5       := nvl(v_sum_otrate5,0)      + nvl(hcm_util.convert_hour_to_minute(v_rateot5),0);
      --
      --***************
    end loop;
 */
    --
    if v_flgdata = 'Y' then
      gen_graph(obj_row);
      --
      if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
				json_str_output := obj_row.to_clob;
      end if;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

--  procedure gen_index (json_str_output out clob) is
--    obj_row            json_object_t;
--    obj_data           json_object_t;
--    v_rcnt             number := 0;
--    v_secur            varchar2(4000 char);
--    v_flgdata          varchar2(1 char) := 'N';
--    v_exist            varchar2(1 char) := 'N';
--    v_codcomp          varchar2(50 char);
--    v_codcompy         varchar2(50 char);
--    v_max_ot_col       number := 0;
--    obj_ot_col         json_object_t;
--    v_codcalen         varchar2(100 char);
--    v_codempid         varchar2(100 char);
--    v_check_codempid   varchar2(100 char) := '!@#$';
--    v_qtyhwork         number := 0;
--    v_dtemovemt        date;
--    v_text_each        varchar2(100 char);
--    v_text_total       varchar2(100 char);
--
----    v_codempid         varchar2(100 char);
--    v_dteeffec         date;
--    v_staupd1          varchar2(100 char);
--    v_staupd2          varchar2(100 char);
----    v_codcomp          varchar2(100 char);
--    v_codpos           varchar2(100 char);
--    v_numlvl           number;
--    v_codjob           varchar2(100 char);
--    v_codempmt         varchar2(100 char);
--    v_typemp           varchar2(100 char);
--    v_typpayroll       varchar2(100 char);
--    v_codbrlc          varchar2(100 char);
----    v_codcalen         varchar2(100 char);
--    v_jobgrade         varchar2(100 char);
--    v_codgrpgl         varchar2(100 char);
--    v_qtyemp           number := 0;
--    v_amthour          number := 0;
--    v_amtday           number := 0;
--    v_amtmth           number := 0;
--    v_sum_amtmth       number := 0;
--
--    v_qtyminot         number := 0;
--    v_ot_per_work      number := 0;
--    v_ot_val           number := 0;
--    v_sal_per          number := 0;
--    v_ot_pay           number := 0;
--    v_ot_per_sal       number := 0;
--
--    v_lvlst            number := 0;
--    v_lvlen            number := 0;
--    v_namcentlvl       varchar2(4000 char);
--    v_namcent          varchar2(4000 char);
--
--    obj_each_ot_rate   json_object_t;
--    v_each_emp_count   number := 0;
--    v_each_sal         number := 0;
--    v_each_qtyminot    number := 0;
--    v_each_qtyhwork    number := 0;
--    v_each_ot_per      number := 0;
--    v_each_ot_val      number := 0;
--    v_each_sal_per     number := 0;
--
--    obj_total_ot_rate  json_object_t;
--    v_total_emp_count  number := 0;
--    v_total_sal        number := 0;
--    v_total_qtyminot   number := 0;
--    v_total_qtyhwork   number := 0;
--    v_total_ot_val     number := 0;
--    v_total_ot_per     number := 0;
--    v_total_sal_per    number := 0;
--    v_rateot5          varchar2(100 char);
--    v_rateot_min5      number;
--    v_check_rteot      number;
--    v_count_rteot      number;
--
--    o_codcomp          varchar2(50 char);
--    o_codcalen         varchar2(100 char);
--    o_codpos           varchar2(100 char);
--
--    cursor c_tovrtime is
--      select t1.codcalen, t1.codcomp,
--             count(distinct t1.codempid) emp_count,
--             sum(stddec(t1.amtottot, t1.codempid, v_chken)) amtottot_count
--        from tovrtime t1, temploy1 t3
--       where t1.codcomp like p_codcomp || '%'
--         and t1.codcalen = nvl(p_codcalen, t1.codcalen)
--         and t1.dtework between p_dtestrt and p_dteend
--         and t1.codempid = t3.codempid
--         and (
--              (v_exist = '1')
--               or (v_exist = '2'
--                  and t3.numlvl between global_v_zminlvl and global_v_zwrklvl
--                  and exists (select c.coduser
--                                from tusrcom c
--                               where c.coduser = global_v_coduser
--                                 and t3.codcomp like c.codcomp || '%')
--                   )
--             )
--         and t3.numlvl between global_v_zminlvl and global_v_zwrklvl
--    group by t1.codcalen, t1.codcomp
--    order by t1.codcalen, t1.codcomp;
--
--    cursor c_tattence is
--      select t2.codempid, nvl(sum(t2.qtyhwork), 0) qtyhwork
--        from tattence t2
--       where t2.codempid in (select t1.codempid
--                              from tovrtime t1, temploy1 t3
--                             where t1.codcomp   = v_codcomp
--                               and t1.codcalen  = v_codcalen
--                               and t1.dtework between p_dtestrt and p_dteend
--                               and t1.codempid  = t3.codempid
--                               and (
--                                      t3.numlvl between global_v_zminlvl and global_v_zwrklvl
--                                      and exists (select c.coduser
--                                                    from tusrcom c
--                                                   where c.coduser = global_v_coduser
--                                                     and t3.codcomp like c.codcomp || '%')
--                                   )
--                               and t3.numlvl between global_v_zminlvl and global_v_zwrklvl
--                             )
--         and t2.dtework between p_dtestrt and p_dteend
--         and t2.typwork in ('L', 'W')
--    group by t2.codempid
--    order by t2.codempid;
--
--    cursor c_totpaydt is
--      select t2.rteotpay, sum(t2.qtyminot) qtyminot
--        from tovrtime t1, totpaydt t2, temploy1 t3
--       where t1.codempid = t2.codempid
--         and t1.dtework  = t2.dtework
--         and t1.typot    = t2.typot
--         and t1.codempid = t3.codempid
--         and t1.codcomp  = v_codcomp
--         and t1.codcalen = v_codcalen
--         and t1.dtework between p_dtestrt and p_dteend
--         and 0 <> (select count(ts.codcomp)
--                     from tusrcom ts
--                    where ts.coduser = global_v_coduser
--                      and t3.codcomp like ts.codcomp || '%'
--                      and rownum <= 1)
--         and t3.numlvl between global_v_zminlvl and global_v_zwrklvl
--    group by t2.rteotpay
--    order by t2.rteotpay;
--
--  begin
--
--    obj_row                := json_object_t();
--    v_rcnt                 := 0;
--    v_codcompy             := null;
--    if p_codcomp is not null then
--      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
--    end if;
--
--    obj_ot_col := get_ot_col(v_codcompy);
--
--    v_text_each            := get_label_name('HRAL49X', global_v_lang, '10');
--    v_text_total           := get_label_name('HRAL49X', global_v_lang, '20');
--
--    v_flgdata              := 'N';
--    v_exist                := '1';
--    for r1 in c_tovrtime loop
--      v_flgdata            := 'Y';
--      exit;
--    end loop;
--
--    if v_flgdata = 'N' then
--      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tovrtime');
--      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
--      return;
--    end if;
--
--    obj_each_ot_rate       := json_object_t();
--    v_each_emp_count       := 0;
--    v_each_sal             := 0;
--    v_each_qtyminot        := 0;
--    v_each_qtyhwork        := 0;
--    v_each_ot_per          := 0;
--    v_each_ot_val          := 0;
--    v_each_sal_per         := 0;
--
--    obj_total_ot_rate      := json_object_t();
--    v_total_emp_count      := 0;
--    v_total_sal            := 0;
--    v_total_qtyminot       := 0;
--    v_total_qtyhwork       := 0;
--    v_total_ot_val         := 0;
--    v_total_ot_per         := 0;
--    v_total_sal_per        := 0;
--
--    v_flgdata              := 'N';
--    v_exist                := '2';
--    for r1 in c_tovrtime loop
--      v_flgdata            := 'Y';
--      if (v_codcalen is null and r1.codcalen is not null) or not (v_codcalen like r1.codcalen) then
--        if v_rcnt > 0 then
--          obj_data             := json_object_t();
--          obj_data.put('coderror', '200');
--          obj_data.put('codcalen', v_codcalen);
--          obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', v_codcalen, global_v_lang));
--          obj_data.put('codcomp', v_codcalen);
--          obj_data.put('desc_codcomp', v_text_each||get_tcodec_name('TCODWORK', v_codcalen, global_v_lang));
--          obj_data.put('qtyemp', v_each_emp_count);
--          if v_each_sal <> 0 and v_each_sal is not null then
--            obj_data.put('saltotal', display_currency(v_each_sal));
--          end if;
--          if v_each_qtyhwork <> 0 and v_each_qtyhwork is not null then
--            obj_data.put('qtyhour', display_ot_hours(v_each_qtyhwork));
--          end if;
--          obj_data.put('flgbreak', 'Y');
--          obj_data.put('otkey', v_text_key);
----          obj_data.put('otlen', obj_ot_col.get_size);
--
--          obj_data.put('otlen', v_rateot_length+1);
--
--
--          if v_each_qtyhwork > 0 then
--            v_each_ot_per        := round((v_each_qtyminot * 100) / v_each_qtyhwork, 2);
--          else
--            v_each_ot_per        := 0;
--          end if;
--
--          if v_each_sal > 0 then
--            v_each_sal_per       := round((v_each_ot_val * 100) / v_each_sal, 2);
--          else
--            v_each_sal_per       := 0;
--          end if;
--          obj_data.put('wrknormal', replace(to_char(v_each_ot_per,'990.99'),' '));
--            if v_ot_val <> 0 and v_ot_val is not null then
--                obj_data.put('otval', display_currency(v_ot_val));
--            end if;
--          obj_data.put('salpercent', replace(to_char(v_each_sal_per,'990.99'),' '));
--
--          for i in 1..obj_ot_col.get_size loop
--            obj_data.put(v_text_key||i, display_ot_hours(hcm_util.get_string_t(obj_each_ot_rate, v_text_key||i)));
--          end loop;
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt               := v_rcnt + 1;
--
--          obj_each_ot_rate       := json_object_t();
--          v_each_emp_count       := 0;
--          v_each_sal             := 0;
--          v_each_qtyminot        := 0;
--          v_each_qtyhwork        := 0;
--          v_each_ot_per          := 0;
--          v_each_ot_val          := 0;
--          v_each_sal_per         := 0;
--        end if;
--        v_codcalen := r1.codcalen;
--        obj_data             := json_object_t();
--        obj_data.put('coderror', '200');
--        obj_data.put('codcalen', r1.codcalen);
--        obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
--        obj_data.put('codcomp', r1.codcalen);
--        obj_data.put('desc_codcomp', get_tcodec_name('TCODWORK', r1.codcalen, global_v_lang));
--        obj_data.put('flgbreak', 'Y');
--        obj_data.put('otkey', v_text_key);
--        obj_data.put('otlen', v_rateot_length+1);
----        obj_data.put('otlen', obj_ot_col.get_size);
--        obj_row.put(to_char(v_rcnt), obj_data);
--        v_rcnt               := v_rcnt + 1;
--      end if;
--
--      if (v_codcomp is null and r1.codcomp is not null) or not (v_codcomp like r1.codcomp) then
--          cmp_codcomp(v_codcomp, r1.codcomp, v_lvlst, v_lvlen);
--          for lvl in v_lvlst..v_lvlen loop
--              get_center_name_lvl(r1.codcomp, lvl, global_v_lang, v_namcentlvl, v_namcent);
----              obj_data := json_object_t();
----              obj_data.put('coderror', '200');
----              obj_data.put('codempid', v_namcentlvl);
----              obj_data.put('desc_codempid', v_namcent);
----              obj_row.put(to_char(v_rcnt), obj_data);
----              v_rcnt := v_rcnt + 1;
--          end loop;
--          v_codcomp := r1.codcomp;
--      end if;
--
--      v_qtyhwork     := 0;
--      v_amtmth       := 0;
--      v_sum_amtmth   := 0;
--      for r2 in c_tattence loop
--        v_codempid             := r2.codempid;
--        v_qtyhwork             := v_qtyhwork + r2.qtyhwork;
--
--        v_dtemovemt            := p_dteend;
--        if v_check_codempid <> v_codempid then
--          v_check_codempid      := v_codempid;
--          begin
--            select codcomp, codpos, numlvl, codjob, codempmt, typemp, typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
--              into v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
--              from temploy1
--             where codempid = v_codempid;
--             o_codcomp  := v_codcomp;
--             o_codpos   := v_codpos;
--             o_codcalen := v_codcalen;
--          exception when no_data_found then
--            v_codcomp           := null;
--            v_codpos            := null;
--            v_numlvl            := null;
--            v_codjob            := null;
--            v_codempmt          := null;
--            v_typemp            := null;
--            v_typpayroll        := null;
--            v_codbrlc           := null;
--            v_codcalen          := null;
--            v_jobgrade          := null;
--            v_codgrpgl          := null;
--          end;
--
--          std_al.get_movemt (v_codempid, v_dtemovemt, 'C', 'U',
--                             v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
--                             v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
--                             v_amthour, v_amtday, v_amtmth);
--          v_codcomp  := o_codcomp;
--          v_codpos   := o_codpos;
--          v_codcalen := o_codcalen;
--
--        end if;
--        v_sum_amtmth    := v_sum_amtmth + v_amtmth;
--      end loop;
--
--      v_qtyminot             := 0;
--      v_qtyemp               := r1.emp_count;
--
--      obj_data               := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('codcalen', r1.codcalen);
--      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
--      obj_data.put('codcomp', r1.codcomp);
--      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
--      obj_data.put('v_codcomp', hcm_util.get_codcomp_level(r1.codcomp,null));
--      obj_data.put('qtyemp', v_qtyemp);
--
----      if v_amtmth <> 0 and v_amtmth is not null then
----        obj_data.put('saltotal', display_currency(v_amtmth));
----      end if;
--      if v_sum_amtmth <> 0 and v_sum_amtmth is not null then
--        obj_data.put('saltotal', display_currency(v_sum_amtmth));
--      end if;
--      if v_qtyhwork <> 0 and v_qtyhwork is not null then
--        obj_data.put('qtyhour', display_ot_hours(v_qtyhwork));
--      end if;
--      obj_data.put('flgbreak', '');
--      obj_data.put('otkey', v_text_key);
--      obj_data.put('otlen', v_rateot_length+1);
--
--      --<< user4 || 05/04/2019
--      /*v_rateot5 := null;
--      v_rateot_min5 := 0;
--      for i in 1..obj_ot_col.get_size loop
--        if display_ot_hours(0) <> 0 and display_ot_hours(0) is not null then
--            obj_data.put(v_text_key||i, display_ot_hours(0));
--            obj_data.put(v_text_key||'_min'||i, 0);
--        end if;
--        for r3 in c_totpaydt loop
--          if r3.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
--            v_qtyminot              := v_qtyminot + r3.qtyminot;
--            if r3.qtyminot <> 0 and r3.qtyminot is not null then
--              if i < v_rateot_length + 1 then -- case < 5 rate
--                obj_data.put(v_text_key||i, display_ot_hours(r3.qtyminot));
--                obj_data.put(v_text_key||'_min'||i, r3.qtyminot);
--              else  -- case >= 5 rate
--                v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
--                v_rateot5 := display_ot_hours(v_rateot_min5);
--              end if;
--            end if;
--          end if;
--        end loop;
--      end loop;
--      obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
--      obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5); */
--
--      v_rateot5 := null;
--      v_rateot_min5 := 0;
--      v_count_rteot := 0;
--      for r3 in c_totpaydt loop
--        v_check_rteot := 0;
--        begin
--          select count(*)
--            into v_check_rteot
--            from totratep2
--           where codcompy = nvl(v_codcompy, codcompy)
--             and rteotpay = r3.rteotpay;
--        exception when others then
--          v_check_rteot := 0;
--        end;
--
--        if v_check_rteot > 0 then
--          for i in 1..obj_ot_col.get_size loop
--            if r3.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
--              v_count_rteot := v_count_rteot + 1;
--              if v_count_rteot < v_rateot_length + 1 then -- case < 5 rate
--                obj_data.put(v_text_key||i, display_ot_hours(r3.qtyminot));
--                obj_data.put(v_text_key||'_min'||i, r3.qtyminot);
--              else  -- case >= 5 rate (other)
--                v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
--                v_rateot5 := display_ot_hours(v_rateot_min5);
--              end if;
--            end if;
--          end loop;
--        else -- case rate other
--          v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
--          v_rateot5 := display_ot_hours(v_rateot_min5);
--        end if;
--      end loop;
--      obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
--      obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
--      -->> user4 || 05/04/2019
--
--      if v_qtyhwork > 0 then
--        v_ot_per_work        := round((v_qtyminot * 100) / v_qtyhwork, 2);
--      else
--        v_ot_per_work        := 0;
--      end if;
--      v_ot_val               := r1.amtottot_count;
--      if v_amtmth > 0 then
--        v_sal_per            := round((v_ot_val * 100) / v_amtmth, 2);
--      else
--        v_sal_per            := 0;
--      end if;
--      obj_data.put('wrknormal', replace(to_char(v_ot_per_work,'990.99'),' '));
--      if v_ot_val <> 0 and v_ot_val is not null then
--        obj_data.put('otval', display_currency(v_ot_val));
--      end if;
--      obj_data.put('salpercent', replace(to_char(v_sal_per,'990.99'),' '));
--
--      v_each_emp_count      := v_each_emp_count + v_qtyemp;
--      v_each_sal            := v_each_sal + v_amtmth;
--      v_each_qtyminot       := v_each_qtyminot + v_qtyminot;
--
--      v_each_qtyhwork       := v_each_qtyhwork + v_qtyhwork;
--      v_each_ot_val         := v_each_ot_val + r1.amtottot_count;
--
--      v_total_emp_count      := v_total_emp_count + v_qtyemp;
--      v_total_sal            := v_total_sal + v_amtmth;
--      v_total_qtyminot       := v_total_qtyminot + v_qtyminot;
--      v_total_qtyhwork       := v_total_qtyhwork + v_qtyhwork;
--      v_total_ot_val         := v_total_ot_val + r1.amtottot_count;
--
--      obj_row.put(to_char(v_rcnt), obj_data);
--      v_rcnt                 := v_rcnt + 1;
--    end loop;
--
--    obj_data             := json_object_t();
--    obj_data.put('coderror', '200');
--    obj_data.put('codcalen', v_codcalen);
--    obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', v_codcalen, global_v_lang));
--    obj_data.put('codcomp', v_codcalen);
--    obj_data.put('desc_codcomp', v_text_each||get_tcodec_name('TCODWORK', v_codcalen, global_v_lang));
--    obj_data.put('qtyemp', v_each_emp_count);
--    if v_each_sal <> 0 and v_each_sal is not null then
--        obj_data.put('saltotal', display_currency(v_each_sal));
--    end if;
--    if v_each_qtyhwork <> 0 and v_each_qtyhwork is not null then
--        obj_data.put('qtyhour', display_ot_hours(v_each_qtyhwork));
--    end if;
--    obj_data.put('flgbreak', 'Y');
--    obj_data.put('otkey', v_text_key);
--    obj_data.put('otlen', v_rateot_length+1);
----    obj_data.put('otlen', obj_ot_col.get_size);
--
--    if v_each_qtyhwork > 0 then
--      v_each_ot_per        := round((v_each_qtyminot * 100) / v_each_qtyhwork, 2);
--    else
--      v_each_ot_per        := 0;
--    end if;
--
--    if v_each_sal > 0 then
--      v_each_sal_per       := round((v_each_ot_val * 100) / v_each_sal, 2);
--    else
--      v_each_sal_per       := 0;
--    end if;
--    obj_data.put('wrknormal', replace(to_char(v_each_ot_per,'990.99'),' '));
--    if v_each_ot_val <> 0 and v_each_ot_val is not null then
--        obj_data.put('otval', display_currency(v_each_ot_val));
--    end if;
--    obj_data.put('salpercent', replace(to_char(v_each_sal_per,'990.99'),' '));
--
--    for i in 1..obj_ot_col.get_size loop
--      obj_data.put(v_text_key||i, display_ot_hours(hcm_util.get_string_t(obj_each_ot_rate, v_text_key||i)));
--    end loop;
--    obj_row.put(to_char(v_rcnt), obj_data);
--    v_rcnt               := v_rcnt + 1;
--
--    obj_data             := json_object_t();
--    obj_data.put('coderror', '200');
--    obj_data.put('codcalen', '');
--    obj_data.put('desc_codcalen', '');
--    obj_data.put('codcomp', '');
--    obj_data.put('desc_codcomp', v_text_total);
--    obj_data.put('qtyemp', v_total_emp_count);
--    if v_total_sal <> 0 and v_total_sal is not null then
--        obj_data.put('saltotal', display_currency(v_total_sal));
--    end if;
--    if v_total_qtyhwork <> 0 and v_total_qtyhwork is not null then
--        obj_data.put('qtyhour', display_ot_hours(v_total_qtyhwork));
--    end if;
--    obj_data.put('flgbreak', 'Y');
--    obj_data.put('otkey', v_text_key);
--    obj_data.put('otlen', v_rateot_length+1);
----    obj_data.put('otlen', obj_ot_col.get_size);
--
--    if v_total_qtyhwork > 0 then
--      v_total_ot_per        := round((v_total_qtyminot * 100) / v_total_qtyhwork, 2);
--    else
--      v_total_ot_per        := 0;
--    end if;
--
--    if v_total_sal > 0 then
--      v_total_sal_per       := round((v_total_ot_val * 100) / v_total_sal, 2);
--    else
--      v_total_sal_per       := 0;
--    end if;
--    obj_data.put('wrknormal', replace(to_char(v_total_ot_per,'990.99'),' '));
--    if v_total_ot_val <> 0 and v_total_ot_val is not null then
--        obj_data.put('otval', display_currency(v_total_ot_val));
--    end if;
--    obj_data.put('salpercent', replace(to_char(v_total_sal_per,'990.99'),' '));
--
--    for i in 1..obj_ot_col.get_size loop
--      obj_data.put(v_text_key||i, display_ot_hours(hcm_util.get_string_t(obj_total_ot_rate, v_text_key||i)));
--    end loop;
--    obj_row.put(to_char(v_rcnt), obj_data);
--    v_rcnt               := v_rcnt + 1;
--
--    if v_flgdata = 'Y' then
--      gen_graph(obj_row);
--
--      if param_msg_error is not null then
--        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--      else
--        json_str_output := obj_row.to_clob;
--      end if;
--    else
--      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
--  end gen_index;

  procedure check_detail is
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codcalen is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flgsecur         varchar2(1 char) := 'N';
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
    v_codcalen         varchar2(100 char);
    v_codempid         varchar2(100 char);
    v_check_codempid   varchar2(100 char) := '!@#$';
    v_qtyhwork         number;
    v_qtyhwork_temp    number := 0;
    v_dtemovemt        date;
    v_text_each        varchar2(100 char);
    v_text_total       varchar2(100 char);

--    v_codempid         varchar2(100 char);
    v_dteeffec         date;
    v_staupd1          varchar2(100 char);
    v_staupd2          varchar2(100 char);
--    v_codcomp          varchar2(100 char);
    v_codpos           varchar2(100 char);
    v_numlvl           number := 0;
    v_codjob           varchar2(100 char);
    v_codempmt         varchar2(100 char);
    v_typemp           varchar2(100 char);
    v_typpayroll       varchar2(100 char);
    v_codbrlc          varchar2(100 char);
--    v_codcalen         varchar2(100 char);
    v_jobgrade         varchar2(100 char);
    v_codgrpgl         varchar2(100 char);
    v_qtyemp           number := 0;
    v_amthour          number := 0;
    v_amtday           number := 0;
    v_amtmth           number := 0;

    v_qtyminot         number := 0;
    v_ot_per_work      number := 0;
    v_ot_val           number := 0;
    v_sal_per          number := 0;
    v_ot_pay           number := 0;
    v_ot_per_sal       number := 0;
    v_check_secur      boolean;
    v_rateot5          varchar2(100 char);
    v_rateot_min5      number;
    v_check_rteot      number;
    --
    v_sum_minot        number := 0;

    cursor c_emp is
      select b.codempid, b.codcomp, a.numlvl, a.codpos,
             nvl(sum(b.qtyminot), 0) qtyminot,
             sum(stddec(b.amtottot, b.codempid, v_chken)) amtottot_count
        from temploy1 a, tovrtime b
       where b.codcomp like p_codcomp_index || '%'
             and ((b.codcomp = p_codcomp and p_typerep = '1') or (b.codcompw = p_codcomp and p_typerep = '2'))
         and b.codcalen = p_codcalen
         and b.codempid = a.codempid
         and b.dtework between p_dtestrt and p_dteend
    group by b.codempid, b.codcomp, a.numlvl, a.codpos
    order by b.codcomp, b.codempid;

    cursor c_totpaydt is
      select t2.rteotpay, sum(t2.qtyminot) qtyminot
        from tovrtime t1, totpaydt t2, temploy1 t3
       where t1.codempid = t2.codempid
         and t1.dtework = t2.dtework
         and t1.typot = t2.typot
         and t1.codempid = t3.codempid
          and ((t1.codcomp = p_codcomp and p_typerep = '1') or (t1.codcompw = p_codcomp and p_typerep = '2'))
        -- and t1.codcomp = p_codcomp
         and t1.codcalen = p_codcalen
         and t1.codempid = v_codempid
         and t1.dtework between p_dtestrt and p_dteend
    group by t2.rteotpay
    order by t2.rteotpay;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_codcompy             := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    end if;

    obj_ot_col := get_ot_col(v_codcompy);

    v_text_each            := get_label_name('HRAL49X', global_v_lang, '10');
    v_text_total           := get_label_name('HRAL49X', global_v_lang, '20');

    for r1 in c_emp loop
      v_codempid           := r1.codempid;
      v_flgdata            := 'Y';
--      v_check_secur     := secur_main.secur1(v_codempid, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      v_check_secur     := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur      := 'Y';
        v_qtyminot := 0;
          begin
            select nvl(sum(qtyhwork), 0)
              into v_qtyhwork
              from tattence
             where codempid = v_codempid
               and dtework between p_dtestrt and p_dteend
               and typwork in ('L', 'W');
          end;

          v_dtemovemt             := p_dteend;
          if v_check_codempid <> v_codempid then
            v_check_codempid      := v_codempid;
            begin
              select codcomp, codpos, numlvl, codjob, codempmt, typemp, typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
                into v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
                from temploy1
               where codempid = v_codempid;
            exception when no_data_found then
              v_codcomp           := null;
              v_codpos            := null;
              v_numlvl            := null;
              v_codjob            := null;
              v_codempmt          := null;
              v_typemp            := null;
              v_typpayroll        := null;
              v_codbrlc           := null;
              v_codcalen          := null;
              v_jobgrade          := null;
              v_codgrpgl          := null;
            end;

            std_al.get_movemt (v_codempid, v_dtemovemt, 'C', 'U',
                               v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp,
                               v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                               v_amthour, v_amtday, v_amtmth);
          end if;

          obj_data             := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpos', r1.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('numlvl', r1.numlvl);
          obj_data.put('saltotal', v_amtmth);
          obj_data.put('otkey', v_text_key);
          obj_data.put('otlen', v_rateot_length+1);
          obj_data.put('codcalen', v_codcalen);

          --<< user4 || 05/04/2019
          /*v_rateot5 := null;
          v_rateot_min5 := 0;
          for i in 1..obj_ot_col.get_size loop
            if display_ot_hours(0) <> 0 and display_ot_hours(0) is not null then
                obj_data.put(v_text_key||i, display_ot_hours(0));
                obj_data.put(v_text_key||'_min'||i, 0);
            end if;
            for r3 in c_totpaydt loop
              if r3.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
                v_qtyminot              := v_qtyminot + r3.qtyminot;
                if r3.qtyminot <> 0 and r3.qtyminot is not null then
                  if i < v_rateot_length + 1 then -- case < 5 rate
                    obj_data.put(v_text_key||i, display_ot_hours(r3.qtyminot));
                    obj_data.put(v_text_key||'_min'||i, r3.qtyminot);
                  else  -- case >= 5 rate
                    v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
                    v_rateot5 := display_ot_hours(v_rateot_min5);
                  end if;
                end if;
              end if;
            end loop;
          end loop;
          obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
          obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);  */

          v_rateot5 := null;
          v_rateot_min5 := 0;
          for r3 in c_totpaydt loop
            v_check_rteot := 0;
            begin
              select count(*)
                into v_check_rteot
                from totratep2
               where codcompy = nvl(hcm_util.get_codcomp_level(v_codcomp,'1'), codcompy)
                 and dteeffec = (select max(b.dteeffec)
                                   from totratep2 b
                                  where b.codcompy = nvl(hcm_util.get_codcomp_level(v_codcomp,'1'), codcompy)
                                    and b.dteeffec <= sysdate)
                 and rteotpay = r3.rteotpay;
            exception when others then
              v_check_rteot := 0;
            end;

            if v_check_rteot > 0 then
              for i in 1..obj_ot_col.get_size loop
                if r3.rteotpay = hcm_util.get_string_t(obj_ot_col, to_char(i)) then
                  if i < v_rateot_length + 1 then -- case < 5 rate
                    obj_data.put(v_text_key||i, display_ot_hours(r3.qtyminot));
                    obj_data.put(v_text_key||'_min'||i, r3.qtyminot);
                    v_sum_minot := v_sum_minot + nvl(r3.qtyminot,0);
                    v_qtyminot := v_qtyminot + r3.qtyminot;
                  else  -- case >= 5 rate (other)
                    v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
                    v_rateot5 := display_ot_hours(v_rateot_min5);
                    v_sum_minot := v_sum_minot + nvl(r3.qtyminot,0);
                    v_qtyminot := v_qtyminot + r3.qtyminot;
                  end if;
                end if;
              end loop;
            else -- case rate other
              v_rateot_min5 := v_rateot_min5 + nvl(r3.qtyminot, 0);
              v_rateot5 := display_ot_hours(v_rateot_min5);
              v_sum_minot := v_sum_minot + nvl(r3.qtyminot,0);
              v_qtyminot := v_qtyminot + r3.qtyminot;
            end if;
          end loop;
          obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
          obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
          obj_data.put('sum_otrate',display_ot_hours(v_sum_minot));
          -->> user4 || 05/04/2019
--
          obj_data.put('qtyhour', display_ot_hours(v_qtyhwork));
          if v_qtyhwork > 0 then
            v_ot_per_work        := round((v_qtyminot * 100) / v_qtyhwork, 2);
          else
            v_ot_per_work        := 0;
          end if;
          v_ot_val               := r1.amtottot_count;
          if v_amtmth > 0 then
            v_sal_per            := round((v_ot_val * 100) / v_amtmth, 2);
          else
            v_sal_per            := 0;
          end if;
          obj_data.put('wrknormal', replace(to_char(v_ot_per_work,'990.99'),' '));
          if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
            if v_ot_val <> 0 and v_ot_val is not null then
                obj_data.put('otval', display_currency(v_ot_val));
            end if;
          end if;
          obj_data.put('salpercent', replace(to_char(v_sal_per,'990.99'),' '));

          --report--
            if isInsertReport then
              insert_ttemprpt_table(obj_data);
            end if;
          --
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt               := v_rcnt + 1;
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tovrtime');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end gen_detail;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codcomp_index     := upper(hcm_util.get_string_t(json_obj, 'p_codcomp_index'));
    b_index_codcalen    := hcm_util.get_string_t(json_obj, 'p_codcalen');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'dd/mm/yyyy');

    p_typerep           := upper(hcm_util.get_string_t(json_obj, 'p_typerep'));
    -- special
    v_text_key          := 'otrate';
--
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
    v_exists          boolean := false;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;

      p_codcomp_index := p_codcomp;

      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codcomp         := hcm_util.get_string_t(p_index_rows, 'codcomp');
        p_codcalen        := hcm_util.get_string_t(p_index_rows, 'codcalen');

        p_codapp := 'HRAL49X1';
        if not v_exists then
--          v_exists := true;
          gen_ot_head(json_output);
        end if;

        p_codapp := 'HRAL49X2';
        gen_detail(json_output);

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
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_head(obj_data in json_object_t) is
    obj_param           json_object_t;
    v_numseq            number := 0;
    v_year              number := 0;
    v_dtestrt           varchar2(100 char) := '';
    v_dteend            varchar2(100 char) := '';
    v_count             number;
    v_other             varchar2(100 char);
    v_rateot            arr_1d;
    v_tcodwork          varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dtestrt    := to_char(p_dtestrt, 'DD/MM/') || (to_number(to_char(p_dtestrt, 'YYYY')) + v_year);
    v_dteend     := to_char(p_dteend, 'DD/MM/') || (to_number(to_char(p_dteend, 'YYYY')) + v_year);
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_count  := hcm_util.get_string_t(obj_data, 'otlen');
    v_other  := get_label_name('HRAL49X2', global_v_lang, '200');

    v_tcodwork   := get_tcodec_name('tcodwork', b_index_codcalen, global_v_lang);

    for i_rateot in 1..v_rateot_length+1 loop
      v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
    end loop;

--    v_rateot(v_rateot_length+1) := null;
--    if v_count > v_rateot_length then
--      if v_count = v_rateot_length + 1 then
--        v_rateot(v_rateot_length+1) := hcm_util.get_string_t(obj_data, v_text_key||to_char(v_rateot_length+1));
--      else
--        v_rateot(v_rateot_length+1) := v_other;
--      end if;
--    end if;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3 ,item4 ,item5, item6, item7, item8, item9
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             get_tcenter_name(p_codcomp, global_v_lang),
             b_index_codcalen || ' - ' || v_tcodwork,
             v_dtestrt || ' - ' || v_dteend,
             v_rateot(1), v_rateot(2), v_rateot(3), v_rateot(4), v_rateot(5),
             p_codcomp
           );
    exception when others then
      null;
    end;

  end insert_ttemprpt_head;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_count             number;
    v_other             number := 0;
    v_rateot            arr_1d;
    v_codempid          varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_desc_codpos     	varchar2(1000 char) := '';
    v_numlvl     				varchar2(1000 char) := '';
    v_saltotal       		varchar2(1000 char) := '';
    v_qtyhour           varchar2(1000 char) := '';
    v_wrknormal         varchar2(1000 char) := '';
    v_otval        		  varchar2(1000 char) := '';
    v_salpercent        varchar2(1000 char) := '';

  begin
    v_count  := hcm_util.get_string_t(obj_data, 'otlen');
    v_codempid   			:= nvl(hcm_util.get_string_t(obj_data, 'codempid'), ' ');
    v_desc_codempid   := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), ' ');
    v_desc_codpos     := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), ' ');
    v_numlvl     			:= nvl(hcm_util.get_string_t(obj_data, 'numlvl'), ' ');
    v_saltotal        := nvl(hcm_util.get_string_t(obj_data, 'saltotal'), ' ');
    v_qtyhour         := nvl(hcm_util.get_string_t(obj_data, 'qtyhour'), ' ');
    v_wrknormal       := nvl(hcm_util.get_string_t(obj_data, 'wrknormal'), ' ');
    v_otval     			:= nvl(hcm_util.get_string_t(obj_data, 'otval'), ' ');
    v_salpercent     	:= nvl(hcm_util.get_string_t(obj_data, 'salpercent'), ' ');

    for i_rateot in 1..v_rateot_length+1 loop
      v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
    end loop;
--    v_rateot(v_rateot_length+1) := null;
--    if v_count > v_rateot_length then
--      for i in v_rateot_length+1 .. v_count loop
--       v_other := v_other + nvl(hcm_util.get_string_t(obj_data, v_text_key||'_min'||i),0);
--      end loop;
--      v_rateot(v_rateot_length+1) := display_ot_hours(v_other);
--    end if;

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;
      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7, item8, item9, item10, item11, item12,
               item13, item14, item15
             )
        values
             ( global_v_codempid, p_codapp, v_numseq,
              v_codempid,
              v_desc_codempid,
              v_desc_codpos,
              v_numlvl,
              v_saltotal,
              v_qtyhour,
              v_wrknormal,
              v_otval,
              v_salpercent,
              v_rateot(1), v_rateot(2), v_rateot(3), v_rateot(4), v_rateot(5),
              p_codcomp
        );
      exception when others then
        null;
      end;
  end insert_ttemprpt_table;

end HRAL49X;

/
