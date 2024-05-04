--------------------------------------------------------
--  DDL for Package Body HRAL4EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4EX" as
  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = nvl(v_codcompy,codcompy)
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

  procedure initial_value(json_str_input in clob) as
  json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');

    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');

    -- special
    v_text_key          := 'otrate';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
  begin
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    gen_index(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

--  procedure gen_index(json_str_output out clob) as
--    obj_data      json;
--    obj_rows      json := json();
--    obj_json      json := json();
--    v_count       number := 0;
--    v_count_rate  number;
--    v_codcompy    tcenter.codcompy%type;
--    v_rteotpay    totratep2.rteotpay%type;
--
--    v_qtyminot    number;
--    v_amtottot    number;
--    v_exist       varchar2(1 char) := '1';
--    v_found       boolean := false;
--
--    v_record_number number := 0;
--    v_amtottot_sum  number := 0;
--    type record_qtyminot is record (
--        qtyminot number
--    );
--    type table_qtyminot is table of record_qtyminot;
--    v_table_qtyminot table_qtyminot := table_qtyminot();
--    cursor c1 is
--      select distinct(rteotpay) v_rteotpay
--        from totratep2
--       where codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),codcompy)
--    order by rteotpay;
--    cursor c2 is
--      select codcompy
--        from tcenter
--       where codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),codcompy)
--    group by codcompy
--    order by codcompy;
--    cursor c3 is
--      select a.codcomp,a.codrem
--        from tovrtime a,totpaydt b,temploy1 c
--       where a.codempid = b.codempid
--         and a.dtework  = b.dtework
--         and a.typot    = b.typot
--         and a.codempid = c.codempid
--         and a.codcomp  like v_codcompy || '%'
--         and a.dtework between p_dtestr and p_dteend
--         and ((v_exist = '1') or
--             ((v_exist = '2') and
--              (0 <>(select count(e.codcomp)
--                      from tusrcom e
--                     where e.coduser = global_v_coduser
--                       and a.codcomp like e.codcomp || '%'
--                       and rownum <= 1))
--             and c.numlvl between global_v_zminlvl and global_v_zwrklvl))
--    group by a.codcomp,a.codrem
--    order by a.codcomp,a.codrem;
--  begin
--    v_record_number  := 0;
--    for r1 in c1 loop
--        v_record_number := v_record_number + 1;
--        v_table_qtyminot.extend;
--        v_table_qtyminot(v_record_number).qtyminot := 0;
--    end loop;
--
--    v_exist := '1';
--    for r2 in c2 loop
--      v_codcompy := r2.codcompy;
--      for r3 in c3 loop
--        v_found := true;
--        exit;
--      end loop;
--      if v_found then
--        exit;
--      end if;
--    end loop;
--    if not v_found then -- if not found -> error
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
--    v_exist := '2';
--    for r2 in c2 loop
--      if secur_main.secur7(r2.codcompy,global_v_coduser) then
--        v_codcompy := r2.codcompy;
--        for r3 in c3 loop
--          obj_data := json();
--          obj_data.put('index',to_char(v_count));
--          obj_data.put('codrem',r3.codrem);
--          obj_data.put('desc_codrem',get_tcodec_name('TCODOTRQ',r3.codrem,global_v_lang));
--          obj_data.put('codcomp',hcm_util.get_codcomp_level(r3.codcomp,null));
--          obj_data.put('desc_codcomp',get_tcenter_name(r3.codcomp,global_v_lang));
--          v_count_rate := 1;
--          for r1 in c1 loop
--            begin
--              select sum(nvl(b.qtyminot,0))
--                into v_qtyminot
--                from tovrtime a,totpaydt b,temploy1 c ,tcenter d
--               where a.codempid = b.codempid
--                 and a.dtework  = b.dtework
--                 and a.typot    = b.typot
--                 and a.codempid = c.codempid
--                 and a.codcomp  = d.codcomp
--                 and d.codcompy = v_codcompy
--                 and a.codcomp  = r3.codcomp
--                 and (a.codrem   = r3.codrem or (a.codrem is null and r3.codrem is null))
--                 and b.rteotpay = r1.v_rteotpay
--                 and a.dtework between p_dtestr and p_dteend
--                 and ((v_exist = '1') or
--                     ((v_exist = '2') and
--                      (0 <>(select count(e.codcomp)
--                              from tusrcom e
--                             where e.coduser = global_v_coduser
--                               and a.codcomp like e.codcomp || '%'
--                               and rownum <= 1))
--                     and c.numlvl between global_v_zminlvl and global_v_zwrklvl));
--            exception when no_data_found then
--              v_qtyminot := 0;
--            end;
--            obj_data.put('rteotpay'||to_char(v_count_rate),to_char(r1.v_rteotpay));
--            obj_data.put('qtyminot'||to_char(v_count_rate),hcm_util.convert_minute_to_hour(v_qtyminot));
--            v_table_qtyminot(v_count_rate).qtyminot := v_table_qtyminot(v_count_rate).qtyminot + nvl(v_qtyminot,0);
--            v_count_rate := v_count_rate + 1;
--          end loop;
--          obj_data.put('rteotnum',to_char(v_count_rate));
--          begin
--            select sum(nvl(stddec(a.amtottot,a.codempid,hcm_secur.get_v_chken),0))
--              into v_amtottot
--              from tovrtime a,totpaydt b,temploy1 c
--             where a.codempid = b.codempid
--               and a.dtework  = b.dtework
--               and a.typot    = b.typot
--               and a.codempid = c.codempid
--               and a.codcomp  = r3.codcomp
--               and (a.codrem   = r3.codrem or (a.codrem is null and r3.codrem is null))
--               and a.dtework between p_dtestr and p_dteend
--               and ((v_exist = '1') or
--                   ((v_exist = '2') and
--                    (0 <>(select count(e.codcomp)
--                            from tusrcom e
--                           where e.coduser = global_v_coduser
--                             and a.codcomp like e.codcomp || '%'
--                             and rownum <= 1))
--                   and c.numlvl between global_v_numlvlsalst and global_v_numlvlsalen));
--          exception when no_data_found then
--            v_amtottot := 0;
--          end;
--          obj_data.put('amtottot',to_char(v_amtottot,'fm999999999990.00'));
--          v_amtottot_sum := v_amtottot_sum + nvl(v_amtottot,0);
--          obj_rows.put(to_char(v_count),obj_data);
--          v_count := v_count + 1;
--        end loop;
--      end if;
--    end loop;
--    if v_count = 0 then  -- if not found -> error
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
--    obj_data := json();
--    obj_data.put('index','');
--    obj_data.put('desc_codcomp',get_label_name('HRAL4EX',global_v_lang,'80'));
--    v_count_rate := 1;
--    for r1 in c1 loop
--      obj_data.put('rteotpay'||to_char(v_count_rate),to_char(r1.v_rteotpay));
--      obj_data.put('qtyminot'||to_char(v_count_rate),hcm_util.convert_minute_to_hour(v_table_qtyminot(v_count_rate).qtyminot));
--      v_count_rate := v_count_rate + 1;
--    end loop;
--    obj_data.put('rteotnum',to_char(v_count_rate));
--    obj_data.put('amtottot',to_char(v_amtottot_sum,'fm999999999990.00'));
--    obj_rows.put(to_char(v_count),obj_data);
--    obj_json.put('param_json',obj_rows);
--    obj_json.put('coderror','200');
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_json.to_clob(json_str_output);
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end;
  procedure gen_index(json_str_output out clob) as
    obj_data         json_object_t;
    obj_rows         json_object_t := json_object_t();
    obj_json         json_object_t := json_object_t();
    v_count          number := 0;
    v_amtottot       number;
    v_amtottot_sum   number := 0;

    v_record_number  number := 0;
    v_sum_otrate     number := 0;

    v_rateot5           varchar2(100 char);
    v_rateot_min5       number;
    v_ot5_all           number := 0;

    r_amtottot       number; --User37 Final Test Phase 1 V11 #2724 15/10/2020

    v_codcomp        tovrtime.codcomp%type;
    v_codrem         tovrtime.codrem%type;
    v_exist          varchar2(1 char);
    v_flg_found      boolean := false;
    v_flg_secur      boolean := false;
    --<<User37 #1601 Final Test Phase 1 V11 11/02/2021
    v_chk            varchar2(1 char);
    v_amt5_all       number := 0;
    -->>User37 #1601 Final Test Phase 1 V11 11/02/2021
    type record_rate is record (
        qtyminot number,
        rteotpay number
    );
    type table_rate is table of record_rate;
    v_table_rate table_rate := table_rate();

    cursor c_totratep2 is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),codcompy)
    order by rteotpay;

    cursor c1 is
      select a.codcomp,a.codrem
        from tovrtime a,temploy1 b
       where a.codcomp  like p_codcomp || '%'
         and a.dtework between p_dtestr and p_dteend
         and a.codempid = b.codempid
         and exists(select 1
                      from totpaydt c
                     where a.codempid = c.codempid
                       and a.dtework  = c.dtework
                       and a.typot    = c.typot)
         and ((v_exist = '1') or
             ((v_exist = '2') and
              (0 <>(select count(c.codcomp)
                      from tusrcom c
                     where c.coduser = global_v_coduser
                       and b.codcomp like c.codcomp || '%'
                       and rownum <= 1))
             and b.numlvl between global_v_zminlvl     and global_v_zwrklvl))
             --User37 Final Test Phase 1 V11 #2724 15/10/2020 and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen))
    group by a.codcomp,a.codrem
    order by a.codcomp,a.codrem;

    cursor c2 is
      select b.rteotpay,sum(nvl(b.qtyminot,0)) qtyminot,sum(nvl(stddec(b.amtottot,b.codempid,global_v_chken),0)) amtottot
        from tovrtime a,totpaydt b,temploy1 c
       where a.codempid = b.codempid
         and a.dtework  = b.dtework
         and a.typot    = b.typot
         and a.dtework between p_dtestr and p_dteend
         and a.codcomp  = v_codcomp
         and a.codrem   = v_codrem
         and a.codempid = c.codempid
         and c.numlvl between global_v_zminlvl     and global_v_zwrklvl
         --User37 Final Test Phase 1 V11 #2724 15/10/2020 and c.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and 0 <>(select count(d.codcomp)
                    from tusrcom d
                   where d.coduser = global_v_coduser
                     and c.codcomp like d.codcomp || '%'
                     and rownum <= 1)
    group by b.rteotpay
    order by b.rteotpay;
  begin
    for r_totratep2 in c_totratep2 loop
        v_record_number := v_record_number + 1;
        v_table_rate.extend;
        v_table_rate(v_record_number).qtyminot := 0;
        v_table_rate(v_record_number).rteotpay := r_totratep2.rteotpay;
    end loop;
    v_exist := '1';
    for r1 in c1 loop
      v_flg_found := true;
      exit;
    end loop;
    if not v_flg_found then -- if not found -> error
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tovrtime');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    v_flg_found := false;
    v_exist := '2';

    for r1 in c1 loop
      v_flg_secur := true;
      v_amtottot := 0;
      obj_data   := json_object_t();
      obj_data.put('index',to_char(v_count));
      obj_data.put('codrem',r1.codrem);
      obj_data.put('desc_codrem',get_tcodec_name('TCODOTRQ',r1.codrem,global_v_lang));
      obj_data.put('codcomp',hcm_util.get_codcomp_level(r1.codcomp,null));
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      v_codcomp := r1.codcomp;
      v_codrem  := r1.codrem;
      v_rateot5 := null;
      v_rateot_min5 := 0;
      obj_data.put('otkey', v_text_key);
      obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.get_size
      v_sum_otrate := 0;
      for r2 in c2 loop
        for v_count_rate in 1..v_record_number loop
          if r2.rteotpay = v_table_rate(v_count_rate).rteotpay then
             if v_count_rate <= v_rateot_length then -- case < 5 rate

               obj_data.put('rteotpay'||to_char(v_count_rate),to_char(r2.rteotpay));
--               obj_data.put('qtyminot'||to_char(v_count_rate),hcm_util.convert_minute_to_hour(r2.qtyminot));
               --<<User37 Final Test Phase 1 V11 14/10/2020
               --obj_data.put(v_text_key||to_char(v_count_rate), hcm_util.convert_minute_to_hour(r2.qtyminot));
               obj_data.put(v_text_key||to_char(v_count_rate), hral4ex.convert_minute_to_hour(r2.qtyminot));
               -->>User37 Final Test Phase 1 V11 14/10/2020
               --<<User37 Final Test Phase 1 V11 #2724 15/10/2020
               begin
                 select sum(nvl(stddec(b.amtottot,b.codempid,global_v_chken),0)) amtottot
                   into r_amtottot
                   from tovrtime a,totpaydt b,temploy1 c
                  where a.codempid = b.codempid
                    and a.dtework  = b.dtework
                    and a.typot    = b.typot
                    and a.dtework between p_dtestr and p_dteend
                    and a.codcomp  = v_codcomp
                    and a.codrem   = v_codrem
                    and a.codempid = c.codempid
                    and b.rteotpay = r2.rteotpay
                    and c.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                    and 0 <>(select count(d.codcomp)
                               from tusrcom d
                              where d.coduser = global_v_coduser
                                and c.codcomp like d.codcomp || '%'
                                and rownum <= 1);
               exception when no_data_found then
                r_amtottot := 0;
               end;
               v_amtottot := v_amtottot + nvl(r_amtottot,0);
               --v_amtottot := v_amtottot + r2.amtottot;
               -->>User37 Final Test Phase 1 V11 #2724 15/10/2020
               -- summary
               v_sum_otrate := v_sum_otrate + r2.qtyminot;
               v_table_rate(v_count_rate).qtyminot := v_table_rate(v_count_rate).qtyminot + r2.qtyminot;
               v_amtottot_sum := v_amtottot_sum + nvl(r_amtottot,0);--User37 Final Test Phase 1 V11 #2724 15/10/2020 v_amtottot_sum := v_amtottot_sum + r2.amtottot;
             else -- case >= 5 rate
               v_sum_otrate := v_sum_otrate + r2.qtyminot;
               v_rateot_min5 := v_rateot_min5 + nvl(r2.qtyminot, 0);
               v_rateot5 := hral4ex.convert_minute_to_hour(v_rateot_min5);--User37 Final Test Phase 1 V11 14/10/2020 hcm_util.convert_minute_to_hour(v_rateot_min5);
               v_ot5_all := v_ot5_all + r2.qtyminot;
               v_table_rate(v_rateot_length+1).qtyminot := v_table_rate(v_rateot_length+1).qtyminot + r2.qtyminot;
             end if;
             exit;
          end if;
        end loop;
        --<<User37 #1601 Final Test Phase 1 V11 11/02/2021
        begin
            select 'Y'
              into v_chk
              from totratep2
             where codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),codcompy)
               and rteotpay = r2.rteotpay
               and rownum = 1;
        exception when no_data_found then
            v_chk := 'N';
        end;

        if v_chk = 'N' then
               v_sum_otrate := v_sum_otrate + nvl(r2.qtyminot,0);
               v_rateot_min5 := v_rateot_min5 + nvl(r2.qtyminot, 0);
               v_rateot5 := hral4ex.convert_minute_to_hour(v_rateot_min5);--User37 Final Test Phase 1 V11 14/10/2020 hcm_util.convert_minute_to_hour(v_rateot_min5);
               v_amtottot := v_amtottot + nvl(r_amtottot,0);
               v_ot5_all := v_ot5_all + nvl(r2.qtyminot,0);
               v_amt5_all := v_amt5_all + nvl(r_amtottot,0);
               --v_table_rate(v_rateot_length+1).qtyminot := v_table_rate(v_rateot_length+1).qtyminot + r2.qtyminot;
        end if;

        obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
        -->>User37 #1601 Final Test Phase 1 V11 11/02/2021
      end loop;



      obj_data.put('rteotnum',to_char(v_record_number + 1));
      obj_data.put('amtottot',to_char(v_amtottot,'fm999999999990.00'));
      --<<User37 Final Test Phase 1 V11 14/10/2020
      --obj_data.put('sum_otrate',to_char(hcm_util.convert_minute_to_hour(v_sum_otrate)));
      obj_data.put('sum_otrate',to_char(hral4ex.convert_minute_to_hour(v_sum_otrate)));
      -->>User37 Final Test Phase 1 V11 14/10/2020

      obj_rows.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    v_rateot5 := null;
    v_rateot_min5 := 0;
    --User37 #1601 Final Test Phase 1 V11 11/02/2021 v_ot5_all := 0;
    v_sum_otrate := 0;
    obj_data := json_object_t();
    obj_data.put('index','');
    obj_data.put('desc_codcomp',get_label_name('HRAL4EX',global_v_lang,'80'));
    for v_count_rate in 1..v_record_number loop
      if v_table_rate(v_count_rate).qtyminot <> 0 then
         obj_data.put('otkey', v_text_key);
         obj_data.put('otlen', v_rateot_length+1);
         if v_count_rate <= v_rateot_length then -- case < 5 rate

  --        obj_data.put('rteotpay'||to_char(v_count_rate),to_char(v_table_rate(v_count_rate).rteotpay));
  --        obj_data.put('rteotpay'||to_char(v_count_rate),to_char(v_table_rate(v_count_rate).rteotpay));
  --        obj_data.put('qtyminot'||to_char(v_count_rate), hcm_util.convert_minute_to_hour(v_table_rate(v_count_rate).qtyminot));
          --<<User37 Final Test Phase 1 V11 14/10/2020
          --obj_data.put(v_text_key||to_char(v_count_rate), hcm_util.convert_minute_to_hour(v_table_rate(v_count_rate).qtyminot));
          obj_data.put(v_text_key||to_char(v_count_rate), hral4ex.convert_minute_to_hour(v_table_rate(v_count_rate).qtyminot));
          -->>User37 Final Test Phase 1 V11 14/10/2020
          v_sum_otrate := v_sum_otrate + v_table_rate(v_count_rate).qtyminot;
         else
          v_rateot_min5 := v_rateot_min5 + nvl(v_table_rate(v_count_rate).qtyminot, 0);
          v_sum_otrate := v_sum_otrate + v_table_rate(v_count_rate).qtyminot;
         end if;
       end if;
    end loop;

    --<<User37 Final Test Phase 1 V11 14/10/2020
    --obj_data.put(v_text_key||to_char(v_rateot_length+1), hcm_util.convert_minute_to_hour(v_rateot_min5));
    --obj_data.put('sum_otrate',to_char(hcm_util.convert_minute_to_hour(v_sum_otrate)));
    --<<User37 #1601 Final Test Phase 1 V11 11/02/2021
    --obj_data.put(v_text_key||to_char(v_rateot_length+1), hral4ex.convert_minute_to_hour(v_rateot_min5));
    obj_data.put(v_text_key||to_char(v_rateot_length+1), hral4ex.convert_minute_to_hour(v_ot5_all));
    --obj_data.put('sum_otrate',to_char(hral4ex.convert_minute_to_hour(v_sum_otrate)));
    obj_data.put('sum_otrate',to_char(hral4ex.convert_minute_to_hour(v_sum_otrate+v_ot5_all)));
    -->>User37 Final Test Phase 1 V11 14/10/2020
    --obj_data.put('amtottot',to_char(v_amtottot_sum,'fm999999999990.00'));
    obj_data.put('amtottot',to_char(v_amtottot_sum+v_amt5_all,'fm999999999990.00'));
    -->>User37 #1601 Final Test Phase 1 V11 11/02/2021
    obj_data.put('rteotnum',to_char(v_record_number + 1));
    obj_rows.put(to_char(v_count),obj_data);

    obj_json.put('param_json',obj_rows);
    obj_json.put('coderror','200');

    if not v_flg_secur then--User37 Final Test Phase 1 V11 #2724 15/10/2020  not v_flg_found then -- if not found -> error
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
		json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_header as
  begin
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure get_header (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_header;
    if param_msg_error is null then
      gen_header(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_header;

  procedure gen_header (json_str_output out clob) is
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


    obj_row.put(0, obj_data);
		json_str_output := obj_row.to_clob;
  end gen_header;

  --<<User37 Final Test Phase 1 V11 14/10/2020
  function  convert_minute_to_hour(p_minute in number) return varchar2 is
    v_hour varchar2(10 char);
    v_min  varchar2(2 char);
  begin
    if p_minute is not null then
      v_hour := trunc(to_char(p_minute / 60));
      v_min := lpad(mod(p_minute , 60), 2, '0') ;
      return to_char(to_number(v_hour),'fm999,999,990') || ':' || v_min ;
   else
    return null;
   end if;
  end;
  -->>User37 Final Test Phase 1 V11 14/10/2020

end HRAL4EX;

/
