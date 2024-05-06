--------------------------------------------------------
--  DDL for Package Body HRPY5YX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5YX" as
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
    v_codempid    temploy1.codempid%type;
  begin
    p_codpay := '';
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
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      p_codcomp    := '';
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
    obj_data               json_object_t;
    obj_row                json_object_t;
    obj_table              json_object_t;
    obj_json               json_object_t := json_object_t();
    v_exist                varchar2(1 char) := '1';
    v_flg_exist            boolean;
    v_flg_permission       boolean;
    v_amtnet1              number;
    v_amtnet2              number;
    v_count                number;
    v_sum1                 number;
    v_sum2                 number;
    v_sum3                 number;
    v_sum4                 number;
    v_sum5                 number;
    v_codcompy             tcenter.codcompy%type;
    v_codincom1            tcontpms.codincom1%type;
    v_codpaypy2            tcontrpy.codpaypy2%type;
    v_codpaypy3            tcontrpy.codpaypy3%type;
    v_codpaypy7            tcontrpy.codpaypy7%type;
    cursor c1 is
        select g.codempmt, count(g.codempid) as c_codempid,
               sum(nvl(g.a_amtnet,0)) as a_amtnet,
               sum(nvl(g.b_amtnet,0)) as b_amtnet,
               sum(g.a_codempid) as a_codempid,
               sum(g.b_codempid) as b_codempid
          from (select a.codempmt, a.codempid,
                       nvl(stddec(a.amtpay,a.codempid,global_v_chken),0) as a_amtnet,
                       null as b_amtnet,
                       1 as a_codempid,
                       0 as b_codempid
                  from tsincexp a, temploy1 b
                 where a.numperiod  = p_numperiod
                   and a.dtemthpay  = p_month
                   and a.dteyrepay  = p_year
                   and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                   and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                   and a.codempid   = nvl(p_codempid,a.codempid)
                   and a.codempid   = b.codempid
                   and ((v_exist = '1')
                    or  (v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                       and exists (select c.coduser
                                                     from tusrcom c
                                                    where c.coduser = global_v_coduser
                                                      and b.codcomp like c.codcomp||'%')))
                 union
                select d.codempmt, d.codempid,
                       null as a_amtnet,
                       nvl(stddec(d.amtpay,d.codempid,global_v_chken),0) as b_amtnet,
                       0 as a_codempid,
                       1 as b_codempid
                  from tsincexp2 d, temploy1 e
                 where d.numperiod  = p_numperiod
                   and d.dtemthpay  = p_month
                   and d.dteyrepay  = p_year
                   and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                   and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                   and d.codempid   = nvl(p_codempid,d.codempid)
                   and d.codempid   = e.codempid
                   and ((v_exist = '1')
                    or  (v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                       and exists (select f.coduser
                                                     from tusrcom f
                                                    where f.coduser = global_v_coduser
                                                      and e.codcomp like f.codcomp||'%')))) g
              group by g.codempmt
              order by g.codempmt;
    cursor c2 is
      select g.codpay, sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select a.codpay,
                     nvl(stddec(a.amtpay,a.codempid,global_v_chken),0) as a_amtnet,
                     null as b_amtnet,
                     1 as a_codempid,
                     0 as b_codempid
                from tsincexp a, temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                 and a.codempid   = nvl(p_codempid,a.codempid)
                 and a.typincexp in ('1','2','3')
                 and a.codpay <> v_codincom1
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%')))
               union
              select d.codpay,
                     null as a_amtnet,
                     nvl(stddec(d.amtpay,d.codempid,global_v_chken),0) as b_amtnet,
                     0 as a_codempid,
                     1 as b_codempid
                from tsincexp2 d, temploy1 e
               where d.numperiod  = p_numperiod
                 and d.dtemthpay  = p_month
                 and d.dteyrepay  = p_year
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typincexp in ('1','2','3')
                 and d.codpay <> v_codincom1
                 and d.codempid   = e.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))) g
    group by g.codpay
    order by g.codpay;
    cursor c3 is
      select g.codpay, sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select a.codpay,
                     nvl(stddec(a.amtpay,a.codempid,global_v_chken),0) as a_amtnet,
                     null as b_amtnet,
                     1 as a_codempid,
                     0 as b_codempid
                from tsincexp a, temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                 and a.codempid   = nvl(p_codempid,a.codempid)
                 and a.typincexp in ('4','5','6')
                 and a.codpay not in (p_codpaypy2,p_codpaypy3)
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%')))
               union
              select d.codpay,
                     null as a_amtnet,
                     nvl(stddec(d.amtpay,d.codempid,global_v_chken),0) as b_amtnet,
                     0 as a_codempid,
                     1 as b_codempid
                from tsincexp2 d, temploy1 e
               where d.numperiod  = p_numperiod
                 and d.dtemthpay  = p_month
                 and d.dteyrepay  = p_year
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.typincexp in ('4','5','6')
                 and d.codpay not in (p_codpaypy2,p_codpaypy3)
                 and d.codempid   = e.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))) g
    group by g.codpay
    order by g.codpay;
    cursor c4 (c_codpaypy varchar2) is
      select g.codpay, sum(nvl(a_amtnet,0)) as a_amtnet,sum(nvl(b_amtnet,0)) as b_amtnet
        from (select a.codpay,
                     nvl(stddec(a.amtpay,a.codempid,global_v_chken),0) as a_amtnet,
                     null as b_amtnet,
                     1 as a_codempid,
                     0 as b_codempid
                from tsincexp a, temploy1 b
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                 and a.codempid   = nvl(p_codempid,a.codempid)
                 and a.codpay     = c_codpaypy
                 and a.codempid   = b.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select c.coduser
                                                   from tusrcom c
                                                  where c.coduser = global_v_coduser
                                                    and b.codcomp like c.codcomp||'%')))
               union
              select d.codpay,
                     null as a_amtnet,
                     nvl(stddec(d.amtpay,d.codempid,global_v_chken),0) as b_amtnet,
                     0 as a_codempid,
                     1 as b_codempid
                from tsincexp2 d, temploy1 e
               where d.numperiod  = p_numperiod
                 and d.dtemthpay  = p_month
                 and d.dteyrepay  = p_year
                 and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
                 and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
                 and d.codempid   = nvl(p_codempid,d.codempid)
                 and d.codpay     = c_codpaypy
                 and d.codempid   = e.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select f.coduser
                                                   from tusrcom f
                                                  where f.coduser = global_v_coduser
                                                    and e.codcomp like f.codcomp||'%')))) g
    group by g.codpay
    order by g.codpay;
  begin
    -- initial
    if p_codempid is not null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      end;
    else
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    end if;
    begin
      select codincom1
        into v_codincom1
        from tcontpms
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = v_codcompy
                            and dteeffec < trunc(sysdate));
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontpms');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    begin
      select codpaypy2  , codpaypy3  , codpaypy7
        into p_codpaypy2, p_codpaypy3, p_codpaypy7
        from tcontrpy
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = v_codcompy
                            and dteeffec < trunc(sysdate));
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontrpy');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    -- check exists
    v_flg_exist := false;
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTAXCUR');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    begin
      select sum(nvl(stddec(amtnet,codempid,global_v_chken),0))
        into v_amtnet
        from ttaxcur
       where numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year
         and codempid  = nvl(p_codempid,codempid)
         and codcomp   like hcm_util.get_codcomp_level(p_codcomp,1) || '%';
    end;
    begin
      select sum(nvl(stddec(amtnet,codempid,global_v_chken),0))
        into v_amtnet
        from ttaxcur2
       where numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year
         and codempid  = nvl(p_codempid,codempid)
         and codcomp   like hcm_util.get_codcomp_level(p_codcomp,1) || '%';
    end;
    -- query
    v_exist := '2';
    v_flg_permission := false;
    obj_row := json_object_t();
    v_count := 0;
    v_sum1  := 0;
    v_sum2  := 0;
    v_sum3  := 0;
    v_sum4  := 0;
    v_sum5  := 0;
    for r1 in c1 loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codempmt'     , r1.codempmt);
      obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang));
      obj_data.put('new_amtnet'   , to_char(nvl(r1.a_amtnet  ,0),'fm999999999990.00'));
      obj_data.put('now_amtnet'   , to_char(nvl(r1.b_amtnet  ,0),'fm999999999990.00'));
      obj_data.put('new_codempid' , to_char(nvl(r1.a_codempid,0)));
      obj_data.put('now_codempid' , to_char(nvl(r1.b_codempid,0)));
      obj_data.put('dif_amtnet'   , to_char(nvl(r1.a_amtnet,0) - nvl(r1.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r1.a_amtnet;
      v_sum2 := v_sum2 + r1.b_amtnet;
      v_sum3 := v_sum3 + r1.a_codempid;
      v_sum4 := v_sum4 + r1.b_codempid;
      v_sum5 := v_sum5 + nvl(r1.a_amtnet,0) - nvl(r1.b_amtnet,0);

      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;

    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    obj_table := json_object_t();
    obj_table.put('table',obj_row);
    obj_data := json_object_t();
    obj_data.put('codempmt'     , '');
    obj_data.put('desc_codempmt', get_label_name('HRPY5YX2',global_v_lang,'10'));
    obj_data.put('new_amtnet'   , to_char(nvl(v_sum1,0),'fm999999999990.00'));
    obj_data.put('now_amtnet'   , to_char(nvl(v_sum2,0),'fm999999999990.00'));
    obj_data.put('new_codempid' , to_char(nvl(v_sum3,0)));
    obj_data.put('now_codempid' , to_char(nvl(v_sum4,0)));
    obj_data.put('dif_amtnet'   , to_char(nvl(v_sum5,0),'fm999999999990.00'));
    obj_row := json_object_t();
    obj_row.put('0',obj_data);
    obj_table.put('summary',obj_row);
    obj_json.put('table1',obj_table);

    v_flg_permission := false;
    obj_row := json_object_t();
    v_count := 0;
    v_sum1  := 0;
    v_sum2  := 0;
    v_sum3  := 0;
    for r2 in c2 loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codpay'     , r2.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r2.codpay,global_v_lang));
      obj_data.put('new_amtnet' , to_char(nvl(r2.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('now_amtnet' , to_char(nvl(r2.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('dif_amtnet' , to_char(nvl(r2.a_amtnet,0) - nvl(r2.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r2.a_amtnet;
      v_sum2 := v_sum2 + r2.b_amtnet;
      v_sum3 := v_sum3 + nvl(r2.a_amtnet,0) - nvl(r2.b_amtnet,0);
      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    obj_table := json_object_t();
    obj_table.put('table',obj_row);
    obj_data := json_object_t();
    obj_data.put('codpay'     , '');
    obj_data.put('desc_codpay', get_label_name('HRPY5YX2',global_v_lang,'10'));
    obj_data.put('new_amtnet' , to_char(nvl(v_sum1,0),'fm999999999990.00'));
    obj_data.put('now_amtnet' , to_char(nvl(v_sum2,0),'fm999999999990.00'));
    obj_data.put('dif_amtnet' , to_char(nvl(v_sum3,0),'fm999999999990.00'));
    obj_row := json_object_t();
    obj_row.put('0',obj_data);
    obj_table.put('summary',obj_row);
    obj_json.put('table2',obj_table);

    v_flg_permission := false;
    obj_row := json_object_t();
    v_count := 0;
    v_sum1  := 0;
    v_sum2  := 0;
    v_sum3  := 0;
    for r3 in c3 loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codpay'     , r3.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r3.codpay,global_v_lang));
      obj_data.put('new_amtnet' , to_char(nvl(r3.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('now_amtnet' , to_char(nvl(r3.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('dif_amtnet' , to_char(nvl(r3.a_amtnet,0) - nvl(r3.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r3.a_amtnet;
      v_sum2 := v_sum2 + r3.b_amtnet;
      v_sum3 := v_sum3 + nvl(r3.a_amtnet,0) - nvl(r3.b_amtnet,0);
      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    obj_table := json_object_t();
    obj_table.put('table',obj_row);
    obj_data := json_object_t();
    obj_data.put('codpay'     , '');
    obj_data.put('desc_codpay', get_label_name('HRPY5YX2',global_v_lang,'10'));
    obj_data.put('new_amtnet' , to_char(nvl(v_sum1,0),'fm999999999990.00'));
    obj_data.put('now_amtnet' , to_char(nvl(v_sum2,0),'fm999999999990.00'));
    obj_data.put('dif_amtnet' , to_char(nvl(v_sum3,0),'fm999999999990.00'));
    obj_row := json_object_t();
    obj_row.put('0',obj_data);
    obj_table.put('summary',obj_row);
    obj_json.put('table3',obj_table);


    v_flg_permission := false;
    obj_row := json_object_t();
    v_count := 0;
    v_sum1  := 0;
    v_sum2  := 0;
    v_sum3  := 0;
    for r4 in c4(p_codpaypy2) loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codpay'     , r4.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r4.codpay,global_v_lang));
      obj_data.put('new_amtnet' , to_char(nvl(r4.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('now_amtnet' , to_char(nvl(r4.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('dif_amtnet' , to_char(nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r4.a_amtnet;
      v_sum2 := v_sum2 + r4.b_amtnet;
      v_sum3 := v_sum3 + nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0);
      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    for r4 in c4(p_codpaypy3) loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codpay'     , r4.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r4.codpay,global_v_lang));
      obj_data.put('new_amtnet' , to_char(nvl(r4.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('now_amtnet' , to_char(nvl(r4.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('dif_amtnet' , to_char(nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r4.a_amtnet;
      v_sum2 := v_sum2 + r4.b_amtnet;
      v_sum3 := v_sum3 + nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0);
      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    v_flg_permission := false;
    for r4 in c4(p_codpaypy7) loop
      v_flg_permission := true;
      obj_data := json_object_t();
      obj_data.put('codpay'     , r4.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r4.codpay,global_v_lang));
      obj_data.put('new_amtnet' , to_char(nvl(r4.a_amtnet,0),'fm999999999990.00'));
      obj_data.put('now_amtnet' , to_char(nvl(r4.b_amtnet,0),'fm999999999990.00'));
      obj_data.put('dif_amtnet' , to_char(nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0),'fm999999999990.00'));
      v_sum1 := v_sum1 + r4.a_amtnet;
      v_sum2 := v_sum2 + r4.b_amtnet;
      v_sum3 := v_sum3 + nvl(r4.a_amtnet,0) - nvl(r4.b_amtnet,0);
      obj_row.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    obj_table := json_object_t();
    obj_table.put('table',obj_row);
    obj_data := json_object_t();
    obj_data.put('codpay'     , '');
    obj_data.put('desc_codpay', get_label_name('HRPY5YX2',global_v_lang,'10'));
    obj_data.put('new_amtnet' , to_char(nvl(v_sum1,0),'fm999999999990.00'));
    obj_data.put('now_amtnet' , to_char(nvl(v_sum2,0),'fm999999999990.00'));
    obj_data.put('dif_amtnet' , to_char(nvl(v_sum3,0),'fm999999999990.00'));
    obj_row := json_object_t();
    obj_row.put('0',obj_data);
    obj_table.put('summary',obj_row);
    obj_json.put('table4',obj_table);

    begin
      select sum(nvl(stddec(amtnet,codempid,global_v_chken),0))
        into v_amtnet1
        from ttaxcur
       where numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year
         and codempid  = nvl(p_codempid,codempid)
         and codcomp   like hcm_util.get_codcomp_level(p_codcomp,1) || '%';
    end;
    begin
      select sum(nvl(stddec(amtnet,codempid,global_v_chken),0))
        into v_amtnet2
        from ttaxcur2
       where numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year
         and codempid  = nvl(p_codempid,codempid)
         and codcomp   like hcm_util.get_codcomp_level(p_codcomp,1) || '%';
    end;

    obj_json.put('coderror','200');
    json_str_output := obj_json.to_clob;
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
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,p_codempid,false);
      if param_msg_error is not null then
        return;
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

  function get_detail1(json_str_input clob) return t_hrpy5yx_detail1 is
    obj_row          t_hrpy5yx_detail1 := t_hrpy5yx_detail1();
  begin
    initial_value(json_str_input);
    check_detail1;
    if param_msg_error is null then
      obj_row := gen_detail1();
    else
      obj_row                := t_hrpy5yx_detail1();
      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail1(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
    end if;
    return obj_row;
  exception when others then
    param_msg_error        := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    obj_row                := t_hrpy5yx_detail1();
    obj_row.extend;
    obj_row(obj_row.first) := r_hrpy5yx_detail1(
                                hcm_secur.get_coderror('400',param_msg_error),
                                hcm_secur.get_response('400',param_msg_error),
                                ' ',' ',' ',' ',
                                ' ',' ',' ',' '
                              );
    return obj_row;
  end get_detail1;

   function gen_detail1 return t_hrpy5yx_detail1 is
    obj_row          t_hrpy5yx_detail1 := t_hrpy5yx_detail1();
    v_flg_permission boolean := false;
    v_flg_exist      boolean := false;
    v_exist varchar2(1 char) := '1';
    cursor c1 is
      select f.codempid, f.codpay, f.a_amtpay, f.b_amtpay
        from (select c.codempid, c.codpay, sum(nvl(c.a_amtpay,0)) as a_amtpay, sum(nvl(c.b_amtpay,0)) as b_amtpay
                from (select a.codempid, a.codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtpay, null as b_amtpay
                        from tsincexp a
                       where a.numperiod  = p_numperiod
                         and a.dtemthpay  = p_month
                         and a.dteyrepay  = p_year
                         and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                         and a.codempid   = nvl(p_codempid,a.codempid)
                         and a.codpay     = nvl(p_codpay,a.codpay)
                       union
                      select b.codempid, b.codpay, null as a_amtpay, stddec(b.amtpay,b.codempid,global_v_chken) as b_amtpay
                        from tsincexp2 b
                       where b.numperiod  = p_numperiod
                         and b.dtemthpay  = p_month
                         and b.dteyrepay  = p_year
                         and b.codcomp    like nvl(p_codcomp||'%',b.codcomp)
                         and b.typpayroll = nvl(p_typpayroll,b.typpayroll)
                         and b.codempid   = nvl(p_codempid,b.codempid)
                         and b.codpay     = nvl(p_codpay,b.codpay)) c,
                     temploy1 d
               where c.codempid = d.codempid
                 and ((v_exist = '1')
                  or  (v_exist = '2' and d.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                     and exists (select e.coduser
                                                   from tusrcom e
                                                  where e.coduser = global_v_coduser
                                                    and d.codcomp like e.codcomp||'%')))
           group by c.codempid, c.codpay) f
       where f.a_amtpay <> f.b_amtpay
    order by f.codempid, f.codpay, f.a_amtpay, f.b_amtpay;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'tsincexp');

      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail1(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
      return obj_row;
    end if;
    v_exist := '2';
    obj_row           := t_hrpy5yx_detail1();
    for r1 in c1 loop
      v_flg_permission := true;
      obj_row.extend;
      obj_row(obj_row.last) := r_hrpy5yx_detail1(
                                  '200',' ',
                                  nvl(get_emp_img(r1.codempid), ' '),
                                  nvl(r1.codempid, ' '),
                                  nvl(get_temploy_name(r1.codempid,global_v_lang), ' '),
                                  nvl(r1.codpay, ' '),
                                  nvl(get_tinexinf_name(r1.codpay,global_v_lang), ' '),
                                  nvl(to_char(r1.a_amtpay), ' '),
                                  nvl(to_char(r1.b_amtpay), ' '),
                                  nvl(to_char(r1.a_amtpay - r1.b_amtpay), ' ')
                                );
    end loop;
    if not v_flg_permission then
      param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail1(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
      return obj_row;
    end if;
    return obj_row;
  exception when others then
    param_msg_error        := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    obj_row.extend;
    obj_row(obj_row.first) := r_hrpy5yx_detail1(
                                hcm_secur.get_coderror('400',param_msg_error),
                                hcm_secur.get_response('400',param_msg_error),
                                ' ',' ',' ',' ',
                                ' ',' ',' ',' '
                              );
    return obj_row;
  end gen_detail1;

  procedure check_detail2 as
    v_codempid    temploy1.codempid%type;
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
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      p_codcomp    := '';
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

  function get_detail2(json_str_input clob) return t_hrpy5yx_detail2 is
    obj_row          t_hrpy5yx_detail2 := t_hrpy5yx_detail2();
  begin
    initial_value(json_str_input);
    check_detail1;
    if param_msg_error is null then
      obj_row := gen_detail2();
    else
      obj_row                := t_hrpy5yx_detail2();
      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail2(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
    end if;
    return obj_row;
  exception when others then
    param_msg_error        := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    obj_row                := t_hrpy5yx_detail2();
    obj_row.extend;
    obj_row(obj_row.first) := r_hrpy5yx_detail2(
                                hcm_secur.get_coderror('400',param_msg_error),
                                hcm_secur.get_response('400',param_msg_error),
                                ' ',' ',' ',' ',
                                ' ',' ',' ',' '
                              );
    return obj_row;
  end get_detail2;

  function gen_detail2 return t_hrpy5yx_detail2 is
    obj_row          t_hrpy5yx_detail2  := t_hrpy5yx_detail2();
    v_flg_permission boolean := false;
    v_flg_exist      boolean := false;
    v_exist varchar2(1 char) := '1';
    cursor c1 is
      select c.codempid, c.codpay, sum(nvl(c.a_amtpay,0)) as a_amtpay, sum(nvl(c.b_amtpay,0)) as b_amtpay
        from (select a.codempid, a.codpay, stddec(a.amtpay,a.codempid,global_v_chken) as a_amtpay, null as b_amtpay
                from tsincexp a
               where a.numperiod  = p_numperiod
                 and a.dtemthpay  = p_month
                 and a.dteyrepay  = p_year
                 and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
                 and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                 and a.codempid   = nvl(p_codempid,a.codempid)
                 and a.codpay     = nvl(p_codpay,a.codpay)
               union
              select b.codempid, b.codpay, null as a_amtpay, stddec(b.amtpay,b.codempid,global_v_chken) as b_amtpay
                from tsincexp2 b
               where b.numperiod  = p_numperiod
                 and b.dtemthpay  = p_month
                 and b.dteyrepay  = p_year
                 and b.codcomp    like nvl(p_codcomp||'%',b.codcomp)
                 and b.typpayroll = nvl(p_typpayroll,b.typpayroll)
                 and b.codempid   = nvl(p_codempid,b.codempid)
                 and b.codpay     = nvl(p_codpay,b.codpay)) c,
             temploy1 d
       where c.codempid = d.codempid
         and ((v_exist = '1')
          or  (v_exist = '2' and d.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                             and exists (select e.coduser
                                           from tusrcom e
                                          where e.coduser = global_v_coduser
                                            and d.codcomp like e.codcomp||'%')))
    group by c.codempid, c.codpay
    order by c.codempid, c.codpay;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail2(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
      return obj_row;
    end if;
    v_exist := '2';
    obj_row           := t_hrpy5yx_detail2();
    for r1 in c1 loop
      v_flg_permission := true;
      obj_row.extend;
      obj_row(obj_row.last) := r_hrpy5yx_detail2(
                                  '200',' ',
                                  nvl(get_emp_img(r1.codempid), ' '),
                                  nvl(r1.codempid, ' '),
                                  nvl(get_temploy_name(r1.codempid,global_v_lang), ' '),
                                  nvl(r1.codpay, ' '),
                                  nvl(get_tinexinf_name(r1.codpay,global_v_lang), ' '),
                                  nvl(to_char(r1.a_amtpay), ' '),
                                  nvl(to_char(r1.b_amtpay), ' '),
                                  nvl(to_char(r1.a_amtpay - r1.b_amtpay), ' ')
                                );
    end loop;
    if not v_flg_permission then
      param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
      obj_row.extend;
      obj_row(obj_row.first) := r_hrpy5yx_detail2(
                                  hcm_secur.get_coderror('400',param_msg_error),
                                  hcm_secur.get_response('400',param_msg_error),
                                  ' ',' ',' ',' ',
                                  ' ',' ',' ',' '
                                );
      return obj_row;
    end if;
    return obj_row;
  exception when others then
    param_msg_error        := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    obj_row.extend;
    obj_row(obj_row.first) := r_hrpy5yx_detail2(
                                hcm_secur.get_coderror('400',param_msg_error),
                                hcm_secur.get_response('400',param_msg_error),
                                ' ',' ',' ',' ',
                                ' ',' ',' ',' '
                              );
    return obj_row;
  end gen_detail2;

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
    if p_type = 'Y' then
      if p_value = 0 then
        v_convert := to_char(p_value,'fm999,999,999,990.90');
      else
        v_convert := '('||to_char(p_value,'fm999,999,999,990.90')||')';
      end if;
    else
      v_convert := trim(replace(replace(to_char(p_value,'fm999,999,999,990.90PR'), '>', ')'), '<', '('));
    end if;
    return v_convert;
  end;

--  procedure gen_report(v_codapp varchar2, obj_data in json) is
--    v_numseq            number := 0;
--  begin
--    begin
--      select nvl(max(numseq), 0)
--        into v_numseq
--        from ttemprpt
--       where codempid = global_v_codempid
--         and codapp   = p_codapp;
--    exception when no_data_found then
--      null;
--    end;
--    v_numseq := v_numseq + 1;
--    begin
--      insert
--        into ttemprpt( codempid, codapp, numseq)
--      values( global_v_codempid, v_codapp, v_numseq);
--    exception when others then
--      null;
--    end;
--  end gen_report;
  procedure insert_temp is
    v_exist                varchar2(1 char) := '1';
    v_flg_exist            boolean;
    v_flg_permission       boolean;
    v_amtnet1              number;
    v_amtnet2              number;
    v_count                number;
    v_sum1                 number;
    v_sum2                 number;
    v_sum3                 number;
    v_sum4                 number;
    v_sum5                 number;
    v_codcompy             tcenter.codcompy%type;
    v_codincom1            tcontpms.codincom1%type;
    v_codpaypy2            tcontrpy.codpaypy2%type;
    v_codpaypy3            tcontrpy.codpaypy3%type;
    v_codpaypy7            tcontrpy.codpaypy7%type;
    --
    cursor c1 is
    select g.codempmt, count(g.codempid) as c_codempid,
           sum(nvl(g.a_amtnet,0)) as a_amtnet,
           sum(nvl(g.b_amtnet,0)) as b_amtnet,
           sum(g.a_codempid) as a_codempid,
           sum(g.b_codempid) as b_codempid
      from (select a.codempmt, a.codempid,
                   nvl(stddec(a.amtpay,a.codempid,global_v_chken),0) as a_amtnet,
                   null as b_amtnet,
                   1 as a_codempid,
                   0 as b_codempid
              from tsincexp a, temploy1 b
             where a.numperiod  = p_numperiod
               and a.dtemthpay  = p_month
               and a.dteyrepay  = p_year
               and a.codcomp    like nvl(p_codcomp||'%',a.codcomp)
               and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
               and a.codempid   = nvl(p_codempid,a.codempid)
               and a.codempid   = b.codempid
               and ((v_exist = '1')
                or  (v_exist = '2' and b.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                   and exists (select c.coduser
                                                 from tusrcom c
                                                where c.coduser = global_v_coduser
                                                  and b.codcomp like c.codcomp||'%')))
             union
            select d.codempmt, d.codempid,
                   null as a_amtnet,
                   nvl(stddec(d.amtpay,d.codempid,global_v_chken),0) as b_amtnet,
                   0 as a_codempid,
                   1 as b_codempid
              from tsincexp2 d, temploy1 e
             where d.numperiod  = p_numperiod
               and d.dtemthpay  = p_month
               and d.dteyrepay  = p_year
               and d.codcomp    like nvl(p_codcomp||'%',d.codcomp)
               and d.typpayroll = nvl(p_typpayroll,d.typpayroll)
               and d.codempid   = nvl(p_codempid,d.codempid)
               and d.codempid   = e.codempid
               and ((v_exist = '1')
                or  (v_exist = '2' and e.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                   and exists (select f.coduser
                                                 from tusrcom f
                                                where f.coduser = global_v_coduser
                                                  and e.codcomp like f.codcomp||'%')))) g
          group by g.codempmt
          order by g.codempmt;
  begin
    del_temp('HRPY5YX' ,global_v_codempid);
    del_temp('HRPY5YX1',global_v_codempid);
    del_temp('HRPY5YX2',global_v_codempid);
    del_temp('HRPY5YX3',global_v_codempid);
    del_temp('HRPY5YX4',global_v_codempid);
    v_exist := '2';
    --
--    begin
--      select codincom1
--        into v_codpay
--        from tcontpms
--       where dteeffec = (select max(dteeffec)
--                           from tcontpms
--                          where dteeffec <= sysdate);
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontpms');
--      return;
--    end;
--
--    --
--    for i in c_tdtepay loop  --last period
--      v_numperiod	:= i.numperiod;
--      v_dtemthpay	:= i.dtemthpay;
--      v_dteyrepay	:= i.dteyrepay;
--      exit;
--    end loop;
--    -- Salary --
--    v_num := 0;
--    for i in c1 loop
--      v_data := 'Y';
--      v_num := v_num + 1;
--      begin
--        select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
--          into v_lastamt
--          from tsincexp
--         where dteyrepay = v_dteyrepay
--           and dtemthpay = v_dtemthpay
--           and numperiod = v_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and codpay = v_codpay
--           and codempmt = i.codempmt;
--      exception when no_data_found then
--        v_lastamt := 0;
--      end;
--
--      begin
--        select count(codempid)
--          into v_emp
--          from tsincexp
--         where dteyrepay = p_year
--           and dtemthpay = p_month
--           and numperiod = p_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and codpay = v_codpay
--           and codempmt = i.codempmt;
--      exception when no_data_found then
--        v_emp := 0;
--      end;
--
--      v_salary	:= nvl(i.amtpay,0) - nvl(v_lastamt,0);
--      v_sumsalt	:= nvl(i.amtpay,0) + nvl(v_sumsalt,0);
--      v_sumsall	:= nvl(v_lastamt,0) + nvl(v_sumsall,0);
--      v_summan	:= nvl(v_emp,0) + nvl(v_summan,0);
--      v_sumsal	:= nvl(v_salary,0) + nvl(v_sumsal,0);
--
--      insert into ttemprpt(codempid,codapp,numseq,
--                           item1,item2,item3,item4,item5)
--                    values(global_v_codempid,'HRPY5YX1',v_num,
--                           get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang),
--                           conv_fmt(nvl(v_lastamt,0),'N'),
--                           conv_fmt(nvl(i.amtpay,0),'N'),
--                           to_char(v_emp,'fm999,990'),
--                           conv_fmt(v_salary,'N'));
--    end loop;
--    -->> insert summary <<--
--    begin
--      v_num := v_num + 1;
--      insert into ttemprpt(codempid,codapp,numseq,
--                           item1,item2,item3,item4,item5)
--                    values(global_v_codempid,'HRPY5YX1',v_num,
--                           get_label_name('HRPY5YX2',global_v_lang,'10'),
--                           conv_fmt(nvl(v_sumsall,0),'N'),
--                           conv_fmt(nvl(v_sumsalt,0),'N'),
--                           to_char(v_summan,'fm999,990'),
--                           conv_fmt(v_sumsal,'N'));
--    end;
--    --
--    -- Other Deductions --
--    v_num := 0;
--    for i in c_pay_d loop
--      v_data := 'Y';
--      v_num := v_num + 1;
--      --
--      begin
--        select sum(nvl(stddec(amtpay,codempid,global_v_chken),0)) amtpay
--          into v_amtpay
--          from tsincexp
--         where dteyrepay = p_year
--           and dtemthpay = p_month
--           and numperiod = p_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and typincexp in ('4','5')
--           and codpay = i.codpay;
--      end;
--
--      begin
--        select sum(nvl(stddec(amtpay,codempid,global_v_chken),0)) amtpay
--          into v_lastamt
--          from tsincexp
--         where dteyrepay = v_dteyrepay
--           and dtemthpay = v_dtemthpay
--           and numperiod = v_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and typincexp in ('4','5')
--           and codpay = i.codpay;
--      exception when no_data_found then
--        v_lastamt := 0;
--      end;
--
--      v_salary	:= nvl(v_amtpay,0) - nvl(v_lastamt,0);
--      v_sumdedt	:= nvl(v_amtpay,0) + nvl(v_sumdedt,0);
--      v_sumdedl	:= nvl(v_lastamt,0) + nvl(v_sumdedl,0);
--      v_sumded	:= nvl(v_salary,0) + nvl(v_sumded,0);
--
--      insert into ttemprpt(codempid,codapp,numseq,
--                           item1,item2,item3,item4,item5)
--                    values(global_v_codempid,'HRPY5YX2',v_num,
--                           i.codpay,
--                           i.codpay||' - '||get_tinexinf_name(i.codpay,global_v_lang),
--                           conv_fmt(nvl(v_lastamt,0),'Y'),
--                           conv_fmt(nvl(v_amtpay,0),'Y'),
--                           conv_fmt(v_salary,'N'));
--    end loop;
--    -->> insert summary <<--
--    begin
--      v_num := v_num + 1;
--      insert into ttemprpt(codempid,codapp,numseq,
--                       item1,item2,item3,item4,item5)
--                values(global_v_codempid,'HRPY5YX2',v_num,
--                       null,
--                       get_label_name('HRPY5YX2',global_v_lang,'10'),
--                       conv_fmt(nvl(v_sumdedl,0),'Y'),
--                       conv_fmt(nvl(v_sumdedt,0),'Y'),
--                       conv_fmt(v_sumded,'N'));
--    end;
--    --
--    -- Other Income --
--    v_num := 0;
--    for i in c_pay_s loop
--      v_data := 'Y';
--      v_num := v_num + 1;
--      begin
--        select sum(nvl(stddec(amtpay,codempid,global_v_chken),0)) amtpay
--          into v_lastamt
--          from tsincexp
--         where dteyrepay = v_dteyrepay
--           and dtemthpay = v_dtemthpay
--           and numperiod = v_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and typincexp in ('1','2','3')
--           and codpay = i.codpay;
--      exception when no_data_found then
--        v_lastamt := 0;
--      end;
--
--      begin
--        select sum(nvl(stddec(amtpay,codempid,global_v_chken),0)) amtpay
--          into v_amtpay
--          from tsincexp
--         where dteyrepay = p_year
--           and dtemthpay = p_month
--           and numperiod = p_numperiod
--           and codcomp like p_codcomp||'%'
--           and flgslip = 1
--           and typpayroll = nvl(p_typpayroll,typpayroll)
--           and typincexp in ('1','2','3')
--           and codpay = i.codpay;
--      end;
--
--      v_salary	:= nvl(v_amtpay,0) - nvl(v_lastamt,0);
--      v_suminct	:= nvl(v_amtpay,0) + nvl(v_suminct,0);
--      v_sumincl	:= nvl(v_lastamt,0) + nvl(v_sumincl,0);
--      v_suminc	:= nvl(v_salary,0) + nvl(v_suminc,0);
--
--      insert into ttemprpt(codempid,codapp,numseq,
--                           item1,item2,item3,item4,item5)
--                    values(global_v_codempid,'HRPY5YX3',v_num,
--                           i.codpay,
--                           i.codpay||' - '||get_tinexinf_name(i.codpay,global_v_lang),
--                           conv_fmt(nvl(v_lastamt,0),'N'),
--                           conv_fmt(nvl(v_amtpay,0),'N'),
--                           conv_fmt(v_salary,'N'));
--    end loop;
--    -->> insert summary <<--
--    begin
--      v_num := v_num + 1;
--       insert into ttemprpt(codempid,codapp,numseq,
--                           item1,item2,item3,item4,item5)
--                    values(global_v_codempid,'HRPY5YX3',v_num,
--                           null,
--                           get_label_name('HRPY5YX2',global_v_lang,'10'),
--                           conv_fmt(nvl(v_sumincl,0),'N'),
--                           conv_fmt(nvl(v_suminct,0),'N'),
--                           conv_fmt(v_suminc,'N'));
--    end;
--    -- Social Security / Cumulative / Tax --
--    -->> Current Period <<--
--    begin
--      select sum(nvl(stddec(amtprovc,codempid,global_v_chken),0)) amtprovc, --??????????????????
--             sum(nvl(stddec(amtprove,codempid,global_v_chken),0)) amtprove, --?????????????????????
--             sum(nvl(stddec(amtsoca,codempid,global_v_chken),0)) amtsoca, --????????????????????????
--             sum(nvl(stddec(amtnet,codempid,global_v_chken),0)) amtnet, --????????????
--             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttaxe, --??????????????????
--             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttax --???????????????
--        into v_amtproc,
--             v_amtprove,
--             v_amtsoca,
--             v_amtnet,
--             v_amttaxe,
--             v_amttax
--        from ttaxcur
--       where dteyrepay = p_year
--         and dtemthpay = p_month
--         and numperiod = p_numperiod
--         and codcomp like p_codcomp||'%'
--         and typpayroll = nvl(p_typpayroll,typpayroll);
--    exception when no_data_found then
--      v_amtproc		:= 0;
--      v_amtprove	:= 0;
--      v_amtsoca		:= 0;
--      v_amtnet		:= 0;
--      v_amttaxe		:= 0;
--      v_amttax		:= 0;
--    end;
--    --
--    begin
--      select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
--        into v_taxincom
--        from tsincexp
--       where dteyrepay = p_year
--         and dtemthpay = p_month
--         and numperiod = p_numperiod
--         and codcomp like p_codcomp||'%'
--         and flgslip = 1
--         and typpayroll = nvl(p_typpayroll,typpayroll)
--         and codpay = p_codpay;
--    exception when no_data_found then
--      v_taxincom := 0;
--    end;
--    --??????????? - ?????????
--    v_amttaxe  := v_amttaxe - nvl(v_taxincom,0);
--    v_amttax   := nvl(v_taxincom,0);
--    -->> Current Period <<--
--    --
--    -->> Previous Period <<--
--    begin
--      select sum(nvl(stddec(amtprovc,codempid,global_v_chken),0)) amtprovc,--??????????????????
--             sum(nvl(stddec(amtprove,codempid,global_v_chken),0)) amtprove,--?????????????????????
--             sum(nvl(stddec(amtsoca,codempid,global_v_chken),0)) amtsoca,--????????????????????????
--             sum(nvl(stddec(amtnet,codempid,global_v_chken),0)) amtnet,--????????????
--             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttaxe,--??????????????????
--             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttax--???????????????
--        into v_amtprocl,
--             v_amtprovel,
--             v_amtsocal,
--             v_amtnetl,
--             v_amttaxel,
--             v_amttaxl
--        from ttaxcur
--       where dteyrepay = v_dteyrepay
--         and dtemthpay = v_dtemthpay
--         and numperiod = v_numperiod
--         and codcomp like p_codcomp||'%'
--         and typpayroll = nvl(p_typpayroll,typpayroll);
--    exception when no_data_found then
--      v_amtprocl	:= 0;
--      v_amtprovel	:= 0;
--      v_amtsocal	:= 0;
--      v_amtnetl		:= 0;
--      v_amttaxel	:= 0;
--      v_amttaxl		:= 0;
--    end;
--    --
--		begin
--			select sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
--				into v_taxincoml
--				from tsincexp
--		 	 where dteyrepay = v_dteyrepay
--	     	 and dtemthpay = v_dtemthpay
--	     	 and numperiod = v_numperiod
--	     	 and codcomp like p_codcomp||'%'
--	     	 and flgslip = 1
--	     	 and typpayroll = nvl(p_typpayroll,typpayroll)
--	     	 and codpay = p_codpaypy2 ;
--		exception when no_data_found then
--			v_taxincoml := 0;
--		end;
--
--		--??????????? - ?????????
--		v_amttaxel := v_amttaxel - nvl(v_taxincoml,0);
--		v_amttaxl  := nvl(v_taxincoml,0);
--    -->> Previous Period <<--
--    --
--    v_amtprocs	:= nvl(v_amtproc,0) - nvl(v_amtprocl,0);
--    v_amtproves	:= nvl(v_amtprove,0) - nvl(v_amtprovel,0);
--    v_amtsocas	:= nvl(v_amtsoca,0) - nvl(v_amtsocal,0);
--    v_amtnets		:= nvl(v_amtnet,0) - nvl(v_amtnetl,0);
--    v_amttaxes	:= nvl(v_amttaxe,0) - nvl(v_amttaxel,0);
--    v_amttaxs		:= nvl(v_amttax,0) - nvl(v_amttaxl,0);
--    --
--    v_sumsoc		:= nvl(v_amtprove,0)+nvl(v_amtsoca,0)+nvl(v_amttaxe,0)+nvl(v_amttax,0);
--    v_sumsocl		:= nvl(v_amtprovel,0)+nvl(v_amtsocal,0)+nvl(v_amttaxel,0)+nvl(v_amttaxl,0);
--    v_sumsocs		:= nvl(v_amtproves,0)+nvl(v_amtsocas,0)+nvl(v_amttaxes,0)+nvl(v_amttaxs,0);
--    --
--    begin
--      select decode(global_v_lang,101,desrepe
--                                 ,102,desrept
--                                 ,103,desrep3
--                                 ,104,desrep4
--                                 ,105,desrep5,desrepe)
--        into f_repname
--        from tappprof
--       where codapp  = 'HRPY5YX';
--    exception when others then
--      f_repname := null;
--    end;
--    f_labdate  := get_date_label(1,global_v_lang);
--    f_labpage  := get_date_label(2,global_v_lang);
--    --
--    begin
--      insert into  ttempprm
--                  (codempid,codapp,codcomp,namcomp,
--                   namcentt,namrep,
--                   pdate,ppage,pfooter1,pfooter2,pfooter3,
--                   label1,label2,label3,
--                   label4,label5,label6,
--  --                 label7,label8,label9,
--  --                 label10,label11,label12,
--  --                 label13,label14,label15,
--                   label16,label17,label18,
--                   label19,label20,label21,
--
--                   label22,label23,label24,
--                   label25,label26,label27,
--
--                   label28,label29,label30,
--                   label31,label32,label33,
--                   label34,label35,label36,
--                   label37,label38,label39,
--                   label40,label41,label42,
--                   --??????????????????
--                   label43,label44,label45,
--                   label46,label47,label48,
--                   --???
--                   label49,label50,label51,
--
--                   label52,label53,label54)
--           values (global_v_codempid,'HRPY5YX',v_codcompy,v_namcompny,
--                   get_tcenter_name(p_codcomp,global_v_lang),f_repname,
--                   f_labdate,f_labpage,v_footer1,v_footer2 ,v_footer3,
--                   get_tcenter_name(p_codcomp_tmp,global_v_lang) ,get_tlistval_name('NAMMTHFUL',p_month,global_v_lang),p_year + hcm_appsettings.get_additional_year,
--                   p_numperiod,get_tcodec_name('TCODTYPY',p_typpayroll,global_v_lang) ,null,
--  --                 :ctrl_label.di_v200,:ctrl_label.di_v210,:ctrl_label.di_v220,
--  --                 :ctrl_label.di_v230,:ctrl_label.di_v240,:ctrl_label.di_v250,
--  --                 :ctrl_label.di_v260,:ctrl_label.di_v270,:ctrl_label.di_v280,
--                   null,get_label_name('HRPY5QX2',global_v_lang,'10'),get_label_name('HRPY5QX2',global_v_lang,'20'),
--                   get_label_name('HRPY5QX2',global_v_lang,'30'),get_label_name('HRPY5QX2',global_v_lang,'40'),get_label_name('HRPY5QX2',global_v_lang,'50'),
--  --
--                   get_label_name('HRPY5YX2',global_v_lang,'20'),get_label_name('HRPY5YX2',global_v_lang,'10'),conv_fmt(v_sumsall,'N'),
--                   conv_fmt(v_sumsalt,'N'),to_char(v_summan,'fm999,990'),conv_fmt(v_sumsal,'N'),
--
--                   conv_fmt(v_sumdedl,'Y'),conv_fmt(v_sumdedt,'Y'),conv_fmt(v_sumded,'N'),
--                   conv_fmt(v_sumincl,'N'),conv_fmt(v_suminct,'N'),conv_fmt(v_suminc,'N'),
--                   conv_fmt(v_amtprocl,'N'),conv_fmt(v_amtproc,'N'),conv_fmt(v_amtprocs,'N'),
--                   conv_fmt(v_amtprovel,'Y'),conv_fmt(v_amtprove,'Y'),conv_fmt(v_amtproves,'N'),
--                   conv_fmt(v_amtsocal,'Y'),conv_fmt(v_amtsoca,'Y'),conv_fmt(v_amtsocas,'N'),
--                   --??????????????????
--                   conv_fmt(v_amttaxel,'Y'),conv_fmt(v_amttaxe,'Y'),conv_fmt(v_amttaxes,'N'),  --label43,label44,label45,
--                   conv_fmt(v_amttaxl,'Y'),conv_fmt(v_amttax,'Y'),conv_fmt(v_amttaxs,'N'),
--                   --???
--                   conv_fmt(v_sumsocl,'Y'),conv_fmt(v_sumsoc,'Y'),conv_fmt(v_sumsocs,'N'),     --label49,label50,label51,
--
--                   conv_fmt(v_amtnetl,'N'),conv_fmt(v_amtnet,'N'),conv_fmt(v_amtnets,'N'));
--    end;
    commit;
  end insert_temp;

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

end hrpy5yx;

/
