--------------------------------------------------------
--  DDL for Package Body HRPY5QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5QX" as
  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    p_numperiod  := to_number(hcm_util.get_string_t(obj_detail,'p_numperiod'));
    p_month      := to_number(hcm_util.get_string_t(obj_detail,'p_month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'p_year'));
    p_codcomp_tmp  := hcm_util.get_string_t(obj_detail,'p_codcomp');
    p_codcomp    := hcm_util.get_string_t(obj_detail,'p_codcomp');
    if p_codcomp is not null then
      p_codcomp := hcm_util.get_codcomp_level(p_codcomp, 1);
    end if;
    p_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid_query');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'p_typpayroll');
    p_codpay     := hcm_util.get_string_t(obj_detail,'p_codpay');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
    v_codempid     temploy1.codempid%type;
  begin
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_numlvlsalst,global_v_numlvlsalen, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
      p_codcomp := '';
      p_typpayroll := '';
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    p_codpay := '';
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
        insert_temp;
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    v_exist         varchar2(1 char) := '1';
    v_numperiod     tdtepay.numperiod%type;
    v_dtemthpay     tdtepay.dtemthpay%type;
    v_dteyrepay     tdtepay.dteyrepay%type;
    v_codincom1     tcontpms.codincom1%type;
    v_amtprovc      ttaxcur.amtprovc%type;
    v_old_amtprovc  ttaxcur.amtprovc%type;
    v_amtprove      ttaxcur.amtprove%type;
    v_old_amtprove  ttaxcur.amtprove%type;
    v_amtsoca       ttaxcur.amtsoca%type;
    v_old_amtsoca   ttaxcur.amtsoca%type;
    v_amttaxe       ttaxcur.amttaxe%type;
    v_old_amttaxe   ttaxcur.amttaxe%type;
    v_amttax        ttaxcur.amttax%type;
    v_old_amttax    ttaxcur.amttax%type;
    v_amtnet        ttaxcur.amtnet%type;
    v_old_amtnet    ttaxcur.amtnet%type;
    v_current_summary  number;
    v_previous_summary number;
    v_diff_summary     number;
    v_qty_summary      number;
    -- v_flg_exist     boolean := false;
    -- v_flg_permis    boolean := false;
    obj_json        json_object_t := json_object_t();
    obj_row         json_object_t := json_object_t();
    obj_row1        json_object_t := json_object_t();
    obj_row2        json_object_t := json_object_t();
    obj_row3        json_object_t := json_object_t();
    obj_row4        json_object_t := json_object_t();
    obj_row5        json_object_t := json_object_t();
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_count         number;
    v_codcompy      tcenter.codcompy%type;
    v_typpayroll    tdtepay.typpayroll%type;

    cursor c_tdtepay is
      select numperiod, dtemthpay, dteyrepay
        from tdtepay
       where codcompy   = v_codcompy ----nvl(p_codcomp,codcompy)
         and typpayroll = v_typpayroll ----nvl(p_typpayroll,typpayroll)
         and lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0)
           < lpad(p_year   ,4,0) || lpad(p_month  ,2,0) || lpad(p_numperiod,2,0)
    order by lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0) desc;

    cursor c1 is
      select codempmt,count(codempid) as qty,sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select a.codempmt,a.codempid,stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and a.codpay     = v_codincom1
                 and a.flgslip    = '1'
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and a.codcomp like c.codcomp||'%'))) -- and b.codcomp like c.codcomp||'%')))  || IPO-SS2101 4449#880
               union all
              select d.codempmt,d.codempid,null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and d.codpay     = v_codincom1
                 and d.flgslip    = '1'
                 and d.codempid   = e.codempid
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and d.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and d.codcomp like f.codcomp||'%')))) -- and e.codcomp like f.codcomp||'%')))) || IPO-SS2101 4449#880
    group by codempmt
    order by codempmt;

    cursor c2 is
      select codpay,sum(a_amtnet) as a_amtnet,sum(b_amtnet) as b_amtnet
        from (select codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and typincexp in ('1','2','3')
                 and codpay <> nvl(v_codincom1,'11111')
                 and flgslip = '1'
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and a.codcomp like c.codcomp||'%'))) -- and b.codcomp like c.codcomp||'%'))) || IPO-SS2101 4449#880
               union all
              select codpay, null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = e.codempid
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and typincexp in ('1','2','3')
                 and codpay <> nvl(v_codincom1,'11111')
                 and flgslip = '1'
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and d.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and d.codcomp like f.codcomp||'%')))) -- and e.codcomp like f.codcomp||'%')))) || IPO-SS2101 4449#880
    group by codpay
    order by codpay;

    cursor c3 is
      select codpay,sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and typincexp in ('4','5','6')
                 and codpay not in (nvl(p_codpaypy2,'11111'),nvl(p_codpaypy3,'11111'))
                 and flgslip = '1'
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and a.codcomp like c.codcomp||'%'))) -- and b.codcomp like c.codcomp||'%'))) || IPO-SS2101 4449#880
               union all
              select codpay, null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = e.codempid
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and typincexp in ('4','5','6')
                 and codpay not in (nvl(p_codpaypy2,'11111'),nvl(p_codpaypy3,'11111'))
                 and d.codempid = e.codempid
                 and ((v_exist = '1')
--                  or ( v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
                  or ( v_exist = '2' and d.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and d.codcomp like f.codcomp||'%')))) -- and e.codcomp like f.codcomp||'%')))) || IPO-SS2101 4449#880
    group by codpay
    order by codpay;
  begin
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1),typpayroll
          into v_codcompy,v_typpayroll ----p_codcomp
          from temploy1
         where codempid = p_codempid;
      end;
    else ----
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);----
      v_typpayroll := p_typpayroll;----
    end if;
    for r_tdtepay in c_tdtepay loop
      v_numperiod := r_tdtepay.numperiod;
      v_dtemthpay := r_tdtepay.dtemthpay;
      v_dteyrepay := r_tdtepay.dteyrepay;
      exit;
    end loop;
    begin
      select codincom1
        into v_codincom1
        from tcontpms
       where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontpms');
    end;
    begin
      select codpaypy1,codpaypy2,codpaypy3
        into p_codpaypy1,p_codpaypy2,p_codpaypy3
        from tcontrpy
       where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontrpy');
    end;
    -- v_flg_exist := false;
    -- for r1 in c1 loop
    --   v_flg_exist := true;
    --   exit;
    -- end loop;
    -- if not v_flg_exist then
    --   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    -- v_flg_exist := false;
    -- for r2 in c2 loop
    --   v_flg_exist := true;
    --   exit;
    -- end loop;
    -- if not v_flg_exist then
    --   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    -- v_flg_exist := false;
    -- for r3 in c3 loop
    --   v_flg_exist := true;
    --   exit;
    -- end loop;
    -- if not v_flg_exist then
    --   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    v_exist := '2';
    -- v_flg_permis := false;
    v_count := 0;
    v_current_summary  := 0;
    v_previous_summary := 0;
    v_diff_summary     := 0;
    v_qty_summary      := 0;
    for r1 in c1 loop -- table 1
      -- v_flg_permis := true;
      obj_data := json_object_t();
      obj_data.put('codempmt',r1.codempmt || ' - ' || get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang));
      obj_data.put('qty',to_char(nvl(r1.qty,0)));
      obj_data.put('current_numperiod' ,to_char(nvl(r1.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(r1.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(r1.a_amtnet,0) - nvl(r1.b_amtnet,0),'fm999999999990.00'));
      v_current_summary  := v_current_summary  + nvl(r1.a_amtnet,0);
      v_previous_summary := v_previous_summary + nvl(r1.b_amtnet,0);
      v_diff_summary     := v_diff_summary     + nvl(r1.a_amtnet,0) - nvl(r1.b_amtnet,0);
      v_qty_summary      := v_qty_summary      + nvl(r1.qty,0);
      obj_row1.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    obj_row := json_object_t();
    obj_row.put('rows',obj_row1);
    obj_data := json_object_t();
    obj_data.put('codempmt',get_label_name('HRPY5QX2',global_v_lang,'70'));
    obj_data.put('qty'               ,to_char(nvl(v_qty_summary     ,0)));
    obj_data.put('current_numperiod' ,to_char(nvl(v_current_summary ,0),'fm999999999990.00'));
    obj_data.put('previous_numperiod',to_char(nvl(v_previous_summary,0),'fm999999999990.00'));
    obj_data.put('diff_numperiod'    ,to_char(nvl(v_diff_summary    ,0),'fm999999999990.00'));
    obj_row1 := json_object_t();
    obj_row1.put(to_char(0),obj_data);
    obj_row.put('summary',obj_row1);
    obj_json.put('table1',obj_row);
    -- if not v_flg_permis then
    --   param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    -- v_flg_permis := false;
    v_count := 0;
    v_current_summary  := 0;
    v_previous_summary := 0;
    v_diff_summary     := 0;
    for r2 in c2 loop -- table 2
      -- v_flg_permis := true;
      obj_data := json_object_t();
      obj_data.put('codpay',r2.codpay || ' - ' || get_tinexinf_name(r2.codpay,global_v_lang));
      obj_data.put('current_numperiod' ,to_char(nvl(r2.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(r2.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(r2.a_amtnet,0) - nvl(r2.b_amtnet,0),'fm999999999990.00'));
      v_current_summary  := v_current_summary  + nvl(r2.a_amtnet,0);
      v_previous_summary := v_previous_summary + nvl(r2.b_amtnet,0);
      v_diff_summary     := v_diff_summary     + nvl(r2.a_amtnet,0) - nvl(r2.b_amtnet,0);
      obj_row2.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    obj_row := json_object_t();
    obj_row.put('rows',obj_row2);
    obj_data := json_object_t();
    obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'70'));
    obj_data.put('current_numperiod' ,to_char(nvl(v_current_summary ,0),'fm999999999990.00'));
    obj_data.put('previous_numperiod',to_char(nvl(v_previous_summary,0),'fm999999999990.00'));
    obj_data.put('diff_numperiod'    ,to_char(nvl(v_diff_summary    ,0),'fm999999999990.00'));
    obj_row2 := json_object_t();
    obj_row2.put(to_char(0),obj_data);
    obj_row.put('summary',obj_row2);
    obj_json.put('table2',obj_row);
    -- if not v_flg_permis then
    --   param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    -- v_flg_permis := false;
    v_count := 0;
    v_current_summary  := 0;
    v_previous_summary := 0;
    v_diff_summary     := 0;
    for r3 in c3 loop -- table 3
      -- v_flg_permis := true;
      obj_data := json_object_t();
      obj_data.put('codpay',r3.codpay || ' - ' || get_tinexinf_name(r3.codpay,global_v_lang));
      obj_data.put('current_numperiod' ,to_char(nvl(r3.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(r3.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(r3.a_amtnet,0) - nvl(r3.b_amtnet,0),'fm999999999990.00'));
      v_current_summary  := v_current_summary  + nvl(r3.a_amtnet,0);
      v_previous_summary := v_previous_summary + nvl(r3.b_amtnet,0);
      v_diff_summary     := v_diff_summary     + nvl(r3.a_amtnet,0) - nvl(r3.b_amtnet,0);
      obj_row3.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    obj_row := json_object_t();
    obj_row.put('rows',obj_row3);
    obj_data := json_object_t();
    obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'70'));
    obj_data.put('current_numperiod' ,to_char(nvl(v_current_summary ,0),'fm999999999990.00'));
    obj_data.put('previous_numperiod',to_char(nvl(v_previous_summary,0),'fm999999999990.00'));
    obj_data.put('diff_numperiod'    ,to_char(nvl(v_diff_summary    ,0),'fm999999999990.00'));
    obj_row3 := json_object_t();
    obj_row3.put(to_char(0),obj_data);
    obj_row.put('summary',obj_row3);
    obj_json.put('table3',obj_row);
    -- if not v_flg_permis then
    --   param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end if;
    -- begin
    --   select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
    --          sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
    --          sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken))
    --     into v_amtprovc, v_amtprove,
    --          v_amtsoca , v_amttaxe ,
    --          v_amttax  , v_amtnet
    --     from ttaxcur a, temploy1 b
    --    where a.codempid  = b.codempid
    --      and a.codempid  = nvl(p_codempid, a.codempid)
    --      and b.codcomp   = nvl(p_codcomp || '%' ,b.codcomp)
    --      and a.numperiod = p_numperiod
    --      and a.dtemthpay = p_month
    --      and a.dteyrepay = p_year
    --      and a.typpayroll = nvl(p_typpayroll,a.typpayroll);
    --   select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
    --          sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
    --          sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken))
    --     into v_amtprovc, v_amtprove,
    --          v_amtsoca , v_amttaxe ,
    --          v_amttax  , v_amtnet
    --     from ttaxcur a, temploy1 b
    --    where a.codempid  = b.codempid
    --      and a.codempid  = nvl(p_codempid, a.codempid)
    --      and b.codcomp   = nvl(p_codcomp || '%' ,b.codcomp)
    --      and a.numperiod = v_numperiod
    --      and a.dtemthpay = v_dtemthpay
    --      and a.dteyrepay = v_dteyrepay
    --      and a.typpayroll = nvl(p_typpayroll,a.typpayroll);
    -- exception when no_data_found then
    --   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
    --   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --   return;
    -- end;
    v_current_summary  := 0;
    v_previous_summary := 0;
    v_diff_summary     := 0;
    begin -- table 4
      select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
             sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
             sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken))
        into v_amtprovc, v_amtprove,
             v_amtsoca , v_amttaxe ,
             v_amttax  , v_amtnet
        from ttaxcur a, temploy1 b
       where a.codempid  = b.codempid
         and a.codempid  = nvl(p_codempid, a.codempid)
--         and b.codcomp   like nvl(p_codcomp || '%' ,b.codcomp) || IPO-SS2101 4449#880
         and a.codcomp   like nvl(p_codcomp || '%' ,a.codcomp)
         and a.numperiod = p_numperiod
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
--         and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
         and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
--                        and b.codcomp like c.codcomp || '%'); || IPO-SS2101 4449#880
                        and a.codcomp like c.codcomp || '%');
      select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
             sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
             sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken))
        into v_old_amtprovc, v_old_amtprove,
             v_old_amtsoca , v_old_amttaxe ,
             v_old_amttax  , v_old_amtnet
        from ttaxcur a, temploy1 b
       where a.codempid  = b.codempid
         and a.codempid  = nvl(p_codempid, a.codempid)
--         and b.codcomp   like nvl(p_codcomp || '%' ,b.codcomp) || IPO-SS2101 4449#880
         and a.codcomp   like nvl(p_codcomp || '%' ,a.codcomp)
         and a.numperiod = v_numperiod
         and a.dtemthpay = v_dtemthpay
         and a.dteyrepay = v_dteyrepay
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
--         and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen || IPO-SS2101 4449#880
         and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
--                        and b.codcomp like c.codcomp || '%'); || IPO-SS2101 4449#880
                        and a.codcomp like c.codcomp || '%');
      obj_data := json_object_t();
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'10'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amtprovc,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amtprovc,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amtprovc,0) - nvl(v_old_amtprovc,0),'fm999999999990.00'));
      obj_row4.put(to_char(0),obj_data);
      obj_data := json_object_t();
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'20'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amtprove,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amtprove,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amtprove,0) - nvl(v_old_amtprove,0),'fm999999999990.00'));
      obj_row4.put(to_char(1),obj_data);
      obj_data := json_object_t();
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'30'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amtsoca,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amtsoca,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amtsoca,0) - nvl(v_old_amtsoca,0),'fm999999999990.00'));
      obj_row4.put(to_char(2),obj_data);
      obj_data := json_object_t();
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'40'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amttaxe,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amttaxe,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amttaxe,0) - nvl(v_old_amttaxe,0),'fm999999999990.00'));
      obj_row4.put(to_char(3),obj_data);
      obj_data := json_object_t();
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'50'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amttax,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amttax,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amttax,0) - nvl(v_old_amttax,0),'fm999999999990.00'));
      obj_row4.put(to_char(4),obj_data);
      v_current_summary  := nvl(v_amtprovc,0) + nvl(v_amtprove,0) + nvl(v_amtsoca,0) + nvl(v_amttaxe,0) + nvl(v_amttax,0);
      v_previous_summary := nvl(v_old_amtprovc,0) + nvl(v_old_amtprove,0) + nvl(v_old_amtsoca,0) + nvl(v_old_amttaxe,0) + nvl(v_old_amttax,0);
      v_diff_summary     := v_current_summary - v_previous_summary;
      obj_data := json_object_t(); -- table 5
      obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'60'));
      obj_data.put('current_numperiod' ,to_char(nvl(v_amtnet,0),'fm999999999990.00'));
      obj_data.put('previous_numperiod',to_char(nvl(v_old_amtnet,0),'fm999999999990.00'));
      obj_data.put('diff_numperiod'    ,to_char(nvl(v_amtnet,0) - nvl(v_old_amtnet,0),'fm999999999990.00'));
      obj_row5.put(to_char(0),obj_data);
    exception when no_data_found then
      null;
      -- param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      -- json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      -- return;
    end;
    obj_row := json_object_t();
    obj_row.put('rows',obj_row4);
    obj_data := json_object_t();
    obj_data.put('codpay',get_label_name('HRPY5QX2',global_v_lang,'70'));
    obj_data.put('current_numperiod' ,to_char(nvl(v_current_summary ,0),'fm999999999990.00'));
    obj_data.put('previous_numperiod',to_char(nvl(v_previous_summary,0),'fm999999999990.00'));
    obj_data.put('diff_numperiod'    ,to_char(nvl(v_diff_summary    ,0),'fm999999999990.00'));
    obj_row4 := json_object_t();
    obj_row4.put(to_char(0),obj_data);
    obj_row.put('summary',obj_row4);
    obj_json.put('table4',obj_row);
    obj_row := json_object_t();
    obj_row.put('rows',json_object_t());
    obj_row.put('summary',obj_row5);
    obj_json.put('table5',obj_row);
    obj_json.put('coderror','200');
    if(nvl(v_amtnet,0) = 0 AND nvl(v_old_amtnet,0) = 0) then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTAXCUR');
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    else
        json_str_output := obj_json.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure check_detail1 as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codempid is null and p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp , codempid');
      return;
    end if;
    if p_codempid is not null then
      p_codcomp := '';
      p_typpayroll := '';
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_detail1;

  procedure get_detail1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail1;
    if param_msg_error is null then
        gen_detail1(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail1;

  procedure gen_detail1(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t := json_object_t();
    v_count         number := 0;
    v_flg_data_found boolean := false;
    v_flg_permission boolean := false;
    v_flg_secure     boolean := false;
    v_numperiod     tdtepay.numperiod%type; -- old
    v_dtemthpay     tdtepay.dtemthpay%type; -- old
    v_dteyrepay     tdtepay.dteyrepay%type; -- old
    v_codcompy      tcenter.codcompy%type;
    v_typpayroll    tdtepay.typpayroll%type; ----

    cursor c_tdtepay is
      select numperiod, dtemthpay, dteyrepay
        from tdtepay
       where codcompy   = v_codcompy ----codcompy   = nvl(p_codcomp,codcompy)
         and typpayroll = v_typpayroll ----nvl(p_typpayroll,typpayroll)
         and lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0)
           < lpad(p_year   ,4,0) || lpad(p_month  ,2,0) || lpad(p_numperiod,2,0)
    order by lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0) desc;

    cursor c_tsincexp is
      select codempid,codpay,a_amtnet,b_amtnet,numlvl
        from (select c.codempid, c.codpay, sum(nvl(c.a_amtnet,0)) a_amtnet, sum(nvl(c.b_amtnet,0)) b_amtnet, d.numlvl
                from (select codpay, codempid, stddec(amtpay,a.codempid,global_v_chken) as a_amtnet, null as b_amtnet
                        from tsincexp a
                       where numperiod  = p_numperiod
                         and dtemthpay  = p_month
                         and dteyrepay  = p_year
                         and codcomp    like nvl(p_codcomp||'%',codcomp)
                         and codempid   = nvl(p_codempid,codempid)
                         and typpayroll = nvl(p_typpayroll,typpayroll)
                         and codpay     = nvl(p_codpay,codpay)
                         and flgslip = '1'
                       union all -- user4 || 30/03/2023 || union 
                      select codpay, codempid, null as a_amtnet, stddec(amtpay,b.codempid,global_v_chken) as b_amtnet
                        from tsincexp b
                       where numperiod  = v_numperiod
                         and dtemthpay  = v_dtemthpay
                         and dteyrepay  = v_dteyrepay
                         and codcomp    like nvl(p_codcomp||'%',codcomp)
                         and codempid   = nvl(p_codempid,codempid)
                         and typpayroll = nvl(p_typpayroll,typpayroll)
                         and codpay     = nvl(p_codpay,codpay)
                         and flgslip = '1') c, temploy1 d
               where c.codempid =  d.codempid
            group by c.codempid,c.codpay,d.numlvl)
       where a_amtnet <> b_amtnet
    order by codempid,codpay,numlvl;
  begin
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1),typpayroll----
          into v_codcompy,v_typpayroll----
          from temploy1
         where codempid = p_codempid;
      end;
    else ----
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);----
      v_typpayroll := p_typpayroll;----
    end if;
    for r_tdtepay in c_tdtepay loop
      v_numperiod := r_tdtepay.numperiod;
      v_dtemthpay := r_tdtepay.dtemthpay;
      v_dteyrepay := r_tdtepay.dteyrepay;
      exit;
    end loop;
    for r_tsincexp in c_tsincexp loop
      v_flg_data_found := true;
      exit;
    end loop;
    if not v_flg_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r_tsincexp in c_tsincexp loop
      v_flg_secure := secur_main.secur2(r_tsincexp.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('image'          ,get_emp_img(r_tsincexp.codempid));
        obj_data.put('codempid'       ,r_tsincexp.codempid);
        obj_data.put('desc_codempid'  ,get_temploy_name(r_tsincexp.codempid,global_v_lang));
        obj_data.put('codpay'         ,r_tsincexp.codpay);
        obj_data.put('desc_codpay'    ,get_tinexinf_name(r_tsincexp.codpay,global_v_lang));
        if r_tsincexp.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          obj_data.put('current_amtnet' ,to_char(r_tsincexp.a_amtnet                      ,'fm999999999990.00'));
          obj_data.put('previous_amtnet',to_char(r_tsincexp.b_amtnet                      ,'fm999999999990.00'));
          obj_data.put('diff_amtnet'    ,to_char(r_tsincexp.a_amtnet - r_tsincexp.b_amtnet,'fm999999999990.00'));
        end if;
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail1;

  procedure check_detail2 as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codempid is null and p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp , codempid');
      return;
    end if;
    if p_codempid is not null then
      p_codcomp := '';
      p_typpayroll := '';
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_detail2;

  procedure get_detail2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail2;
    if param_msg_error is null then
        gen_detail2(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail2;

  procedure gen_detail2(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t := json_object_t();
    v_count         number := 0;
    v_flg_data_found boolean := false;
    v_flg_permission boolean := false;
    v_flg_secure     boolean := false;
    v_numperiod     tdtepay.numperiod%type; -- old
    v_dtemthpay     tdtepay.dtemthpay%type; -- old
    v_dteyrepay     tdtepay.dteyrepay%type; -- old
    v_codcompy      tcenter.codcompy%type;
    v_typpayroll    tdtepay.typpayroll%type;

    cursor c_tdtepay is
      select numperiod, dtemthpay, dteyrepay
        from tdtepay
       where codcompy   = v_codcompy ----nvl(p_codcomp,codcompy)
         and typpayroll = v_typpayroll ----nvl(p_typpayroll,typpayroll)
         and lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0)
           < lpad(p_year   ,4,0) || lpad(p_month  ,2,0) || lpad(p_numperiod,2,0)
    order by lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0) desc;

    cursor c_tsincexp is
      select c.codempid, c.codpay, sum(stddec(c.a_amtnet,c.codempid,global_v_chken)) a_amtnet, sum(stddec(c.b_amtnet,c.codempid,global_v_chken)) b_amtnet, d.numlvl
        from (select codpay, codempid, amtpay as a_amtnet, null as b_amtnet
                from tsincexp a
               where numperiod  = p_numperiod
                 and dtemthpay  = p_month
                 and dteyrepay  = p_year
                 and codcomp    like nvl(p_codcomp||'%',codcomp)
                 and codempid   = nvl(p_codempid,codempid)
                 and typpayroll = nvl(p_typpayroll,typpayroll)
                 and codpay     = nvl(p_codpay,codpay)
                 and flgslip = '1'
               union all -- user4 || 30/03/2023 || union
              select codpay, codempid, null as a_amtnet, amtpay as b_amtnet
                from tsincexp b
               where numperiod  = v_numperiod
                 and dtemthpay  = v_dtemthpay
                 and dteyrepay  = v_dteyrepay
                 and codcomp    like nvl(p_codcomp||'%',codcomp)
                 and codempid   = nvl(p_codempid,codempid)
                 and typpayroll = nvl(p_typpayroll,typpayroll)
                 and codpay     = nvl(p_codpay,codpay)
                 and flgslip = '1') c, temploy1 d
       where c.codempid =  d.codempid
    group by c.codempid,c.codpay,d.numlvl
    order by c.codempid,c.codpay,d.numlvl;
  begin
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1),typpayroll----
          into v_codcompy,v_typpayroll----
          from temploy1
         where codempid = p_codempid;
      end;
    else ----
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);----
      v_typpayroll := p_typpayroll;----
    end if;
    for r_tdtepay in c_tdtepay loop
      v_numperiod := r_tdtepay.numperiod;
      v_dtemthpay := r_tdtepay.dtemthpay;
      v_dteyrepay := r_tdtepay.dteyrepay;
      exit;
    end loop;
    for r_tsincexp in c_tsincexp loop
      v_flg_data_found := true;
      exit;
    end loop;
    if not v_flg_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r_tsincexp in c_tsincexp loop
      v_flg_secure := secur_main.secur2(r_tsincexp.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('image'          ,get_emp_img(r_tsincexp.codempid));
        obj_data.put('codempid'       ,r_tsincexp.codempid);
        obj_data.put('desc_codempid'  ,get_temploy_name(r_tsincexp.codempid,global_v_lang));
        obj_data.put('codpay'         ,r_tsincexp.codpay);
        obj_data.put('desc_codpay'    ,get_tinexinf_name(r_tsincexp.codpay,global_v_lang));
        if r_tsincexp.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          obj_data.put('current_amtnet' ,to_char(r_tsincexp.a_amtnet                      ,'fm999999999990.00'));
          obj_data.put('previous_amtnet',to_char(r_tsincexp.b_amtnet                      ,'fm999999999990.00'));
          obj_data.put('diff_amtnet'    ,to_char(r_tsincexp.a_amtnet - r_tsincexp.b_amtnet,'fm999999999990.00'));
        end if;
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail2;

  procedure insert_temp is
    f_labdate       varchar2(4000 char);
    f_labpage       varchar2(4000 char);
    v_footer1       varchar2(4000 char);
    v_footer2       varchar2(4000 char);
    v_footer3       varchar2(4000 char);

    f_repname       varchar2(4000 char);
    v_codcompyrp    varchar2(4000 char);
    v_namcompny     varchar2(4000 char);
    v_num           number := 0 ;
    v_num2          number := 0 ;
    v_report        varchar2(4000 char);
    v_month         varchar2(4000 char);
    v_status        varchar2(4000 char);
    v_label1        varchar2(4000 char):= null;
    --
    v_codpay		    tsincexp.codpay%type;
    v_numperiod	    tdtepay.numperiod%type;
    v_dtemthpay	    tdtepay.dtemthpay%type;
    v_dteyrepay	    tdtepay.dteyrepay%type;
    v_lastamt		    number;
    v_lastemp		    number;
    v_emp				    number;
    v_salary		    number;
    v_sumsalt		    number:=0;
    v_sumsall		    number:=0;
    v_summan		    number:=0;
    v_summan_b	    number:=0;
    v_sumsal		    number:=0;
    v_sumdedt		    number:=0;
    v_sumdedl		    number:=0;
    v_sumded		    number:=0;
    v_suminct		    number:=0;
    v_sumincl		    number:=0;
    v_suminc		    number:=0;
    v_data			    varchar2(1):='N';
    v_amtproc		    number;
    v_amtprocl	    number;
    v_amtprove	    number;
    v_amtprovel	    number;
    v_amtsoca		    number;
    v_amtsocal	    number;
    v_amtsoccl	    number;    
    v_amtsocc		    number;
    v_amtnet		    number;
    v_amtnetl		    number;
    v_amttaxe		    number;
    v_amttaxel	    number;
    v_amttax		    number;
    v_amttaxl		    number;
    v_amtprocs	    number;
    v_amtproves	    number;
    v_amtsocas	    number;
    v_amtsoccs	    number;
    v_amtnets		    number;
    v_amttaxes	    number;
    v_amttaxs		    number;
    v_sumsoc		    number;
    v_sumsocl		    number;
    v_sumsocs		    number;
    v_taxincom      number;
    v_taxincoml     number;
    v_amtpay		    number;
    v_codcompy      tcenter.codcompy%type;
    v_typpayroll    tdtepay.typpayroll%type;
    --
--    v_codpaypy2     varchar2(4000 char);
--    v_codpaypy3     varchar2(4000 char);

    cursor c1 is
      select codempmt,
             ----count(codempid) as qty,
             count(a_codempid) as qty,
             count(b_codempid) as b_qty,
             sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select a.codempmt,a.codempid,stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                    ,a.codempid as a_codempid,null as b_codempid ----
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and a.codpay     = v_codpay
                 and a.flgslip    = '1'
                 and a.codempid   = b.codempid
                 and ( b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%'))
               union all -- user4 || 30/03/2023 || union
              select d.codempmt,d.codempid,null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                    ,null as a_codempid,d.codempid as b_codempid ----
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and d.codpay     = v_codpay
                 and d.flgslip    = '1'
                 and d.codempid   = e.codempid
                 and ( e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))
    group by codempmt
    order by codempmt;


    cursor c_pay_d is
      select codpay,sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and typincexp in ('4','5','6')
                 and codpay not in (nvl(p_codpaypy2,'11111'),nvl(p_codpaypy3,'11111'))
                 and flgslip = '1'
                 and a.codempid   = b.codempid
                 and (b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%'))
               union all
              select codpay, null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and typincexp in ('4','5','6')
                 and codpay not in (nvl(p_codpaypy2,'11111'),nvl(p_codpaypy3,'11111'))
                 and d.codempid = e.codempid
                 and (e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))
    group by codpay
    order by codpay;

    cursor c_pay_s is
      select codpay,sum(a_amtnet) as a_amtnet,sum(b_amtnet) as b_amtnet
        from (select codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtnet,null as b_amtnet
                from tsincexp a,temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.codempid   = nvl(p_codempid       ,a.codempid)
                 and a.typpayroll = nvl(p_typpayroll     ,a.typpayroll)
                 and typincexp in ('1','2','3')
                 and codpay <> nvl(v_codpay,'11111')
                 and flgslip = '1'
                 and a.codempid   = b.codempid
                 and (b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%'))
               union all
              select codpay, null as a_amtnet,stddec(d.amtpay,d.codempid,global_v_chken) as b_amtnet
                from tsincexp d,temploy1 e
               where d.numperiod  = v_numperiod
                 and d.dtemthpay  = v_dtemthpay
                 and d.dteyrepay  = v_dteyrepay
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and typincexp in ('1','2','3')
                 and codpay <> nvl(v_codpay,'11111')
                 and flgslip = '1'
                 and d.codempid   = e.codempid
                 and (e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))
    group by codpay
    order by codpay;


    cursor c_tdtepay is
      select numperiod, dtemthpay, dteyrepay
        from tdtepay
       where codcompy   = nvl(v_codcompy,codcompy)--nvl(p_codcomp,codcompy)
         and typpayroll = nvl(v_typpayroll,typpayroll)--nvl(p_typpayroll,typpayroll)
         and lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0)
           < lpad(p_year   ,4,0) || lpad(p_month  ,2,0) || lpad(p_numperiod,2,0)
    order by lpad(dteyrepay,4,0) || lpad(dtemthpay,2,0) || lpad(numperiod  ,2,0) desc;

  begin
    del_temp('HRPY5QX' ,global_v_codempid);
    del_temp('HRPY5QX1',global_v_codempid);
    del_temp('HRPY5QX2',global_v_codempid);
    del_temp('HRPY5QX3',global_v_codempid);
    del_temp('HRPY5QX4',global_v_codempid);
    --
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1),typpayroll----
          into v_codcompy,v_typpayroll----
          from temploy1
         where codempid = p_codempid;
      end;
    else ----
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);----
      v_typpayroll := p_typpayroll;----
    end if;

    begin
      select codincom1
        into v_codpay
        from tcontpms
       where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = v_codcompy ----hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontpms');
      return;
    end;
    --

    for i in c_tdtepay loop  --last period
      v_numperiod	:= i.numperiod;
      v_dtemthpay	:= i.dtemthpay;
      v_dteyrepay	:= i.dteyrepay;
      exit;
    end loop;
    -- Salary --
    v_num := 0;
    for i in c1 loop
      v_data := 'Y';
      v_num := v_num + 1;

      v_salary	:= nvl(i.a_amtnet,0) - nvl(i.b_amtnet,0);
      v_sumsalt	:= nvl(i.a_amtnet,0) + nvl(v_sumsalt,0);
      v_sumsall	:= nvl(i.b_amtnet,0) + nvl(v_sumsall,0);
      v_summan	:= nvl(v_summan,0) + i.qty; ----nvl(v_emp,0) + nvl(v_summan,0);
      v_summan_b	:= nvl(v_summan_b,0) + i.b_qty; ----
      v_sumsal	:= nvl(v_salary,0) + nvl(v_sumsal,0);
      insert into ttemprpt(codempid,codapp,numseq,
                           item1,item2,item3,item4,item5
                           ,item6) ----
                    values(global_v_codempid,'HRPY5QX1',v_num,
                           get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang),conv_fmt(nvl(i.b_amtnet,0),'N'),conv_fmt(nvl(i.a_amtnet,0),'N'),to_char(i.qty,'fm999,990'),conv_fmt(v_salary,'N')
                          ,to_char(i.b_qty,'fm999,990')); ----
    end loop;
    -->> insert summary <<--
    begin
      v_num := v_num + 1;
      insert into ttemprpt(codempid,codapp,numseq,
                             item1,item2,item3,item4,item5
                            ,item6) ----
                      values(global_v_codempid,'HRPY5QX1',v_num,
                             get_label_name('HRPY5QX2',global_v_lang,'70'),conv_fmt(nvl(v_sumsall,0),'N'),conv_fmt(nvl(v_sumsalt,0),'N'),to_char(v_summan,'fm999,990'),conv_fmt(v_sumsal,'N')
                            ,to_char(v_summan_b,'fm999,990')); ----
    end;
    --
    -- Other Deductions --
    v_num := 0;
    for i in c_pay_d loop
      v_data := 'Y';
      v_num := v_num + 1;

      v_salary	:= nvl(i.a_amtnet,0) - nvl(i.b_amtnet,0);
      v_sumdedt	:= nvl(i.a_amtnet,0) + nvl(v_sumdedt,0);
      v_sumdedl	:= nvl(i.b_amtnet,0) + nvl(v_sumdedl,0);
      v_sumded	:= nvl(v_salary,0) + nvl(v_sumded,0);

      insert into ttemprpt(codempid,codapp,numseq,
                           item1,item2,
                           item3,item4,
                           item5)
                    values(global_v_codempid,'HRPY5QX2',v_num,
                           i.codpay,i.codpay||' - '||get_tinexinf_name(i.codpay,global_v_lang),
                           conv_fmt(nvl(i.b_amtnet,0),'Y'),conv_fmt(nvl(i.a_amtnet,0),'Y'),
                           conv_fmt(v_salary,'N'));
    end loop;
    -->> insert summary <<--
    begin
      v_num := v_num + 1;
      insert into ttemprpt(codempid,codapp,numseq,
                       item1,item2,
                       item3,item4,
                       item5)
                values(global_v_codempid,'HRPY5QX2',v_num,
                       null,get_label_name('HRPY5QX2',global_v_lang,'70'),
                       conv_fmt(nvl(v_sumdedl,0),'Y'),conv_fmt(nvl(v_sumdedt,0),'Y'),
                       conv_fmt(v_sumded,'N'));
    end;
    --
    -- Other Income --
    v_num := 0;

    for i in c_pay_s loop
      v_data := 'Y';
      v_num := v_num + 1;
       -- Diff
      v_salary	:= nvl(i.a_amtnet,0) - nvl(i.b_amtnet,0);

      v_suminct	:= nvl(i.a_amtnet,0) + nvl(v_suminct,0);
      v_sumincl	:= nvl(i.b_amtnet,0) + nvl(v_sumincl,0);
      v_suminc	:= nvl(v_salary,0) + nvl(v_suminc,0);

      insert into ttemprpt(codempid,codapp,numseq,
                           item1,item2,item3,item4,item5)
                    values(global_v_codempid,'HRPY5QX3',v_num,
                           i.codpay,i.codpay||' - '||get_tinexinf_name(i.codpay,global_v_lang),conv_fmt(nvl(i.b_amtnet,0),'N'),conv_fmt(nvl(i.a_amtnet,0),'N'),conv_fmt(v_salary,'N'));
    end loop;
    -->> insert summary <<--
    begin
      v_num := v_num + 1;
       insert into ttemprpt(codempid,codapp,numseq,
                           item1,item2,item3,
                           item4,item5)
                    values(global_v_codempid,'HRPY5QX3',v_num,
                           null,get_label_name('HRPY5QX2',global_v_lang,'70'),conv_fmt(nvl(v_sumincl,0),'N'),
                           conv_fmt(nvl(v_suminct,0),'N'),conv_fmt(v_suminc,'N'));
    end;
    --
    -- Social Security / Cumulative / Tax --
    -->> Current Period <<--
    begin
      select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
             sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
             sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken)),
              sum(stddec(a.amtsocc ,a.codempid,global_v_chken))
        into v_amtproc, v_amtprove,
             v_amtsoca , v_amttaxe ,
             v_amttax  , v_amtnet,
             v_amtsocc
        from ttaxcur a, temploy1 b
       where a.codempid  = b.codempid
         and a.codempid  = nvl(p_codempid, a.codempid)
         and b.codcomp   like nvl(p_codcomp || '%' ,b.codcomp)
         and a.numperiod = p_numperiod
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and b.codcomp like c.codcomp || '%');
     exception when no_data_found then
      v_amtproc		:= 0;
      v_amtprove	:= 0;
      v_amtsoca		:= 0;
      v_amtnet		:= 0;
      v_amttaxe		:= 0;
      v_amttax		:= 0;
      v_amtsocc    := 0;
    end;
    --
--    begin
--      select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
--        into v_taxincom
--        from tsincexp
--       where dteyrepay = p_year
--         and dtemthpay = p_month
--         and numperiod = p_numperiod
--         and codcomp like p_codcomp_tmp
--         and flgslip = 1
--         and typpayroll = nvl(p_typpayroll,typpayroll)
--         and codpay = p_codpay;
--    exception when no_data_found then
--      v_taxincom := 0;
--    end;
    --??????????? - ?????????
--    v_amttaxe  := v_amttaxe - nvl(v_taxincom,0);
--    v_amttax   := nvl(v_taxincom,0);

    -->> Current Period <<--
    --
    -->> Previous Period <<--
    begin
      select sum(stddec(a.amtprovc,a.codempid,global_v_chken)), sum(stddec(a.amtprove,a.codempid,global_v_chken)),
             sum(stddec(a.amtsoca ,a.codempid,global_v_chken)), sum(stddec(a.amttaxe ,a.codempid,global_v_chken)),
             sum(stddec(a.amttax  ,a.codempid,global_v_chken)), sum(stddec(a.amtnet  ,a.codempid,global_v_chken)),
             sum(stddec(a.amtsocc ,a.codempid,global_v_chken))
        into v_amtprocl, v_amtprovel,
             v_amtsocal , v_amttaxel ,
             v_amttaxl  , v_amtnetl,
             v_amtsoccl
        from ttaxcur a, temploy1 b
       where a.codempid  = b.codempid
         and a.codempid  = nvl(p_codempid, a.codempid)
         and b.codcomp   like nvl(p_codcomp || '%' ,b.codcomp)
         and a.numperiod = v_numperiod
         and a.dtemthpay = v_dtemthpay
         and a.dteyrepay = v_dteyrepay
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and b.codcomp like c.codcomp || '%');
    exception when no_data_found then
      v_amtprocl	:= 0;
      v_amtprovel	:= 0;
      v_amtsocal	:= 0;
      v_amtnetl		:= 0;
      v_amttaxel	:= 0;
      v_amttaxl		:= 0;
      v_amtsoccl   := 0;
    end;
    --
		begin
			select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
				into v_taxincoml
				from tsincexp
		 	 where dteyrepay = v_dteyrepay
	     	 and dtemthpay = v_dtemthpay
	     	 and numperiod = v_numperiod
            and typpayroll = nvl(v_typpayroll,typpayroll)
             and codcomp like v_codcompy||'%'
	     	 and flgslip = 1	
--           and codcomp like p_codcomp_tmp
--	     	 and typpayroll = nvl(p_typpayroll,typpayroll)
	     	 and codpay = p_codpaypy1 ;
		exception when no_data_found then
			v_taxincoml := 0;
		end;
------------------------------------------------------------------------------
		begin
			select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
             into v_amttaxel
             from tsincexp
		 	 where dteyrepay = v_dteyrepay
	     	 and dtemthpay = v_dtemthpay
	     	 and numperiod = v_numperiod
             and typpayroll = nvl(v_typpayroll,typpayroll)
             and codcomp like v_codcompy||'%'
	     	 and flgslip = 1	
	     	 and codpay <>  p_codpaypy1
             and typincexp = '6';
		exception when no_data_found then
			v_taxincoml := 0;
		end;
		--??????????? - ?????????
      --v_amttaxel := v_amttaxel - nvl(v_taxincoml,0);
		v_amttaxl  := nvl(v_taxincoml,0);


    -->> Previous Period <<--
    --
    v_amtprocs	    := nvl(v_amtproc,0) - nvl(v_amtprocl,0);
    v_amtproves	    := nvl(v_amtprove,0) - nvl(v_amtprovel,0);
    v_amtsocas	    := nvl(v_amtsoca,0) - nvl(v_amtsocal,0);
    v_amtsoccs      := nvl(v_amtsocc,0) - nvl(v_amtsoccl,0);
    v_amtnets		:= nvl(v_amtnet,0) - nvl(v_amtnetl,0);
    v_amttaxes	    := nvl(v_amttaxe,0) - nvl(v_amttaxel,0);
    v_amttaxs		:= nvl(v_amttax,0) - nvl(v_amttaxl,0);
    --
    v_sumsoc		:= nvl(v_amtproc,0) + nvl(v_amtprove,0)+nvl(v_amtsoca,0)+nvl(v_amtsocc,0)+nvl(v_amttaxe,0)+nvl(v_amttax,0);
    v_sumsocl		:= nvl(v_amtprocl,0) + nvl(v_amtprovel,0)+nvl(v_amtsocal,0)+nvl(v_amtsoccl,0)+nvl(v_amttaxel,0)+nvl(v_amttaxl,0);
    v_sumsocs		:= nvl(v_amtprocs,0)+nvl(v_amtproves,0)+nvl(v_amtsocas,0)+nvl(v_amtsoccs,0)+nvl(v_amttaxes,0)+nvl(v_amttaxs,0);
    --
    begin
      select decode(global_v_lang,101,desrepe
                                 ,102,desrept
                                 ,103,desrep3
                                 ,104,desrep4
                                 ,105,desrep5,desrepe)
        into f_repname
        from tappprof
       where codapp  = 'HRPY5QX';
    exception when others then
      f_repname := null;
    end;
    f_labdate  := get_date_label(1,global_v_lang);
    f_labpage  := get_date_label(2,global_v_lang);
    --
    begin
      insert into  ttempprm
                  (codempid,codapp,codcomp,namcomp,
                   namcentt,namrep,
                   pdate,ppage,pfooter1,pfooter2,pfooter3,
                   label1,label2,label3,
                   label4,label5,label6,
  --                 label7,label8,label9,
  --                 label10,label11,label12,
  --                 label13,label14,label15,
                   label16,label17,label18,
                   label19,label20,label21,

                   label22,label23,label24,
                   label25,label26,label27,

                   label28,label29,label30,
                   label31,label32,label33,
                   label34,label35,label36,
                   label37,label38,label39,
                   label40,label41,label42,
                   --??????????????????
                   label43,label44,label45,
                   label46,label47,label48,
                   --???
                   label49,label50,label51,

                   label52,label53,label54,
                   label55,label56,label57,label58-- socc
                   )
           values (global_v_codempid,'HRPY5QX',v_codcompyrp,v_namcompny,
                   get_tcenter_name(p_codcomp,global_v_lang),f_repname,
                   f_labdate,f_labpage,v_footer1,v_footer2 ,v_footer3,
                   get_tcenter_name(p_codcomp_tmp,global_v_lang) ,get_tlistval_name('NAMMTHFUL',p_month,global_v_lang),p_year + hcm_appsettings.get_additional_year,
                   p_numperiod,get_tcodec_name('TCODTYPY',p_typpayroll,global_v_lang) ,null,
  --                 :ctrl_label.di_v200,:ctrl_label.di_v210,:ctrl_label.di_v220,
  --                 :ctrl_label.di_v230,:ctrl_label.di_v240,:ctrl_label.di_v250,
  --                 :ctrl_label.di_v260,:ctrl_label.di_v270,:ctrl_label.di_v280,
                   null,get_label_name('HRPY5QX2',global_v_lang,'10'),get_label_name('HRPY5QX2',global_v_lang,'20'),
                   get_label_name('HRPY5QX2',global_v_lang,'30'),get_label_name('HRPY5QX2',global_v_lang,'40'),get_label_name('HRPY5QX2',global_v_lang,'50'),
  --
                   get_label_name('HRPY5QX2',global_v_lang,'60'),get_label_name('HRPY5QX2',global_v_lang,'70'),conv_fmt(nvl(v_sumsall,0),'N'),
                   conv_fmt(nvl(v_sumsalt,0),'N'),to_char(nvl(v_summan,0),'fm999,990'),conv_fmt(nvl(v_sumsal,0),'N'),

                   conv_fmt(nvl(v_sumdedl,0),'Y'),conv_fmt(nvl(v_sumdedt,0),'Y'),conv_fmt(nvl(v_sumded,0),'N'),
                   conv_fmt(nvl(v_sumincl,0),'N'),conv_fmt(nvl(v_suminct,0),'N'),conv_fmt(nvl(v_suminc,0),'N'),
                   conv_fmt(nvl(v_amtprocl,0),'N'),conv_fmt(nvl(v_amtproc,0),'N'),conv_fmt(nvl(v_amtprocs,0),'N'),
                   conv_fmt(nvl(v_amtprovel,0),'Y'),conv_fmt(nvl(v_amtprove,0),'Y'),conv_fmt(nvl(v_amtproves,0),'N'),
                   conv_fmt(nvl(v_amtsocal,0),'Y'),conv_fmt(nvl(v_amtsoca,0),'Y'),conv_fmt(nvl(v_amtsocas,0),'N'),
                   --??????????????????
                   conv_fmt(nvl(v_amttaxel,0),'Y'),conv_fmt(nvl(v_amttaxe,0),'Y'),conv_fmt(nvl(v_amttaxes,0),'N'),  --label43,label44,label45,
                   conv_fmt(nvl(v_amttaxl,0),'Y'),conv_fmt(nvl(v_amttax,0),'Y'),conv_fmt(nvl(v_amttaxs,0),'N'),
                   --???
                   conv_fmt(nvl(v_sumsocl,0),'Y'),conv_fmt(nvl(v_sumsoc,0),'Y'),conv_fmt(nvl(v_sumsocs,0),'N'),     --label49,label50,label51,

                   conv_fmt(nvl(v_amtnetl,0),'N'),conv_fmt(nvl(v_amtnet,0),'N'),conv_fmt(nvl(v_amtnets,0),'N'),

                   conv_fmt(nvl(v_amtsoccl,0),'Y'),conv_fmt(nvl(v_amtsocc,0),'Y'),conv_fmt(nvl(v_amtsoccs,0),'N'),--label55,label56,label57,label58
                   get_label_name('HRPY5QX2',global_v_lang,'80')

                   );
    end;
    commit;
  end insert_temp;

  function get_date_label (v_numseq number,v_lang varchar2)return varchar2 is
		get_labdate   varchar2(20);
	begin
    select desc_label	into get_labdate
   	from trptlbl
   	where codrept  = 'HEADRPT' and
          numseq    =  v_numseq   and
          codlang   =  v_lang;
		return get_labdate;
	exception
		when others then
	 	if v_numseq = 1 then return('Date/Time');
	 	else return('Page');
	 	end if;
	end;

  function conv_fmt( p_value number,p_type varchar2) return varchar2 is
    v_convert varchar2(20);
  begin
  v_convert := to_char(p_value,'fm999,999,999,990.90');
--    if p_type = 'Y' then
--      if p_value = 0 then
--        v_convert := to_char(p_value,'fm999,999,999,990.90');
--      else
--        v_convert := '('||to_char(p_value,'fm999,999,999,990.90')||')';
--      end if;
--    else
--      v_convert := trim(replace(replace(to_char(p_value,'fm999,999,999,990.90PR'), '>', ')'), '<', '('));
--    end if;
    return v_convert;
  end;

  procedure del_temp (v_codapp varchar2,v_coduser varchar2) is
	begin
		delete ttemprpt where
		codapp   = upper(v_codapp) and
		codempid = upper(v_coduser) ;
		delete ttempprm where
		codapp   = upper(v_codapp) and
		codempid = upper(v_coduser) ;
		commit;
	end;
end hrpy5qx;

/
