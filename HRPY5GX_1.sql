--------------------------------------------------------
--  DDL for Package Body HRPY5GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5GX" as

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
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_flgess            := hcm_util.get_string_t(json_obj, 'p_flgess') = 'true';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll tcodtypy.codcodec%type;
  begin
    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dteyrepay');
      return;
    end if;
    --
    if p_codempid is not null and not p_flgess then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    --
    if p_codempid is null and p_flgess then -- check secur for call from hres84x
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_exist_inc        boolean := TRUE;
    v_flg_secure       boolean := false;
    v_flg_permission   boolean := false;
    v_codapp           varchar2(4000 char) := 'HRPY5GX';
    v_codempid         varchar2(4000 char);
    v_typpayroll       varchar2(4000 char);
    v_text             varchar2(4000 char);
    v_codpaypy1        varchar2(4000 char);
    v_comp             varchar2(4000 char);
    v_codcompy         tcenter.codcompy%type;
    v_comp1            varchar2(4000 char) := '@@@';
    v_first            boolean := TRUE;
    v_amtpay_sum       number := 0;
    v_suminc1          number := 0;
    v_suminc2          number := 0;
    v_suminc3          number := 0;
    v_suminc4          number := 0;
    v_suminc5          number := 0;
    v_suminc6          number := 0;
    v_suminc7          number := 0;
    v_suminc8          number := 0;
    v_suminc9          number := 0;
    v_suminc10         number := 0;
    v_suminc11         number := 0;
    v_suminc12         number := 0;
    v_sumded1          number := 0;
    v_sumded2          number := 0;
    v_sumded3          number := 0;
    v_sumded4          number := 0;
    v_sumded5          number := 0;
    v_sumded6          number := 0;
    v_sumded7          number := 0;
    v_sumded8          number := 0;
    v_sumded9          number := 0;
    v_sumded10         number := 0;
    v_sumded11         number := 0;
    v_sumded12         number := 0;
    v_sumtax1          number := 0;
    v_sumtax2          number := 0;
    v_sumtax3          number := 0;
    v_sumtax4          number := 0;
    v_sumtax5          number := 0;
    v_sumtax6          number := 0;
    v_sumtax7          number := 0;
    v_sumtax8          number := 0;
    v_sumtax9          number := 0;
    v_sumtax10         number := 0;
    v_sumtax11         number := 0;
    v_sumtax12         number := 0;
    v_temp01           number := 0;
    v_temp02           number := 0;
    v_temp03           number := 0;
    v_temp04           number := 0;
    v_temp05           number := 0;
    v_temp06           number := 0;
    v_temp07           number := 0;
    v_temp08           number := 0;
    v_temp09           number := 0;
    v_temp10           number := 0;
    v_temp11           number := 0;
    v_temp12           number := 0;
    v_temp13           number := 0;
    v_total            number := 0;
    v_amtinc           number := 0;
    v_amtded           number := 0;
    v_amttax           number := 0;
    v_incnet           number := 0;
    v_dednet           number := 0;
    v_taxnet           number := 0;
    --<<User37 #3562 4.ES.MS Module 28/04/2021
    type amtarray is table of number index by binary_integer;
        v_amtpay		amtarray;
    -->>User37 #3562 4.ES.MS Module 28/04/2021

    v_data             varchar2(1 char) := 'N';
    v_flgpass			     boolean := true;
    v_secur            varchar2(1 char) := 'N';

    cursor c1 is
      select codempid,codcomp,numlvl,typpayroll,rowid
        from temploy1 a
       where codempid = nvl(p_codempid,codempid)
         and codcomp like p_codcomp||'%'
         and typpayroll =	nvl(p_typpayroll,typpayroll)
         and exists (select codempid
                       from tytdinc b
                      where	dteyrepay  = p_dteyrepay
                        and b.codempid = a.codempid
                        and	typpay <> '7')
      order by codcomp,codempid;

    cursor c_inc is
      select codcomp,codempid,codpay,typpay,typpayroll,
             nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
             nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
             nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
             nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
             nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
             nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
             nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
             nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
             nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
             nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
             nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
             nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12,
             codcompy,dteyrepay
       from tytdinc
      where	dteyrepay	=	p_dteyrepay
        and codempid  = v_codempid
        and typpay in	('1','2','3')
        and codpay <> v_codpaypy1
      order by codcomp, codpay;

    cursor c_ded is
      select codcomp,codempid,codpay,typpay,typpayroll,
             nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
             nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
             nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
             nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
             nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
             nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
             nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
             nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
             nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
             nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
             nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
             nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12,
             codcompy,dteyrepay
       from tytdinc
      where	dteyrepay	=	p_dteyrepay - global_v_zyear
        and codempid = v_codempid
        and typpay in	('4','5')
        and codpay <> v_codpaypy1
      order by codcomp, codpay;

    cursor c_tax is
      select codcompy,codcomp,codempid,codpay,typpay,typpayroll,
             nvl(stddec(amtpay1,codempid,v_chken),0) amtpay1,
             nvl(stddec(amtpay2,codempid,v_chken),0) amtpay2,
             nvl(stddec(amtpay3,codempid,v_chken),0) amtpay3,
             nvl(stddec(amtpay4,codempid,v_chken),0) amtpay4,
             nvl(stddec(amtpay5,codempid,v_chken),0) amtpay5,
             nvl(stddec(amtpay6,codempid,v_chken),0) amtpay6,
             nvl(stddec(amtpay7,codempid,v_chken),0) amtpay7,
             nvl(stddec(amtpay8,codempid,v_chken),0) amtpay8,
             nvl(stddec(amtpay9,codempid,v_chken),0) amtpay9,
             nvl(stddec(amtpay10,codempid,v_chken),0) amtpay10,
             nvl(stddec(amtpay11,codempid,v_chken),0) amtpay11,
             nvl(stddec(amtpay12,codempid,v_chken),0) amtpay12,
             dteyrepay
        from tytdinc
       where dteyrepay =	p_dteyrepay - global_v_zyear
         and codempid = v_codempid
       order by codcompy,codpay;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TYTDINC');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    --<<User37 #3562 4.ES.MS Module 28/04/2021
    if p_flgess then
        p_flgess := true;
    else
        p_flgess := false;
    end if;
    for i in 1..12 loop
        v_amtpay(i) := null;
    end loop;
    -->>User37 #3562 4.ES.MS Module 28/04/2021
   v_codcompy := hcm_util.get_codcompy(p_codcomp);
    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure or p_flgess then
        v_exist_inc      := FALSE;
        v_flg_permission := true;
        v_codempid       := r1.codempid;
        v_typpayroll     := r1.typpayroll;
        v_comp := r1.codcomp;
--        v_codcompy := hcm_util.get_codcompy(r1.codcomp);
        if v_comp1 <> r1.codcomp then
          v_comp1 := r1.codcomp;
          begin
             select codpaypy1
               into v_codpaypy1
               from tcontrpy
              where codcompy = get_comp_split(v_comp1,1)
                and dteeffec = (select max(dteeffec)
                                  from tcontrpy
                                 where codcompy = get_comp_split(v_comp1,1)
                                   and dteeffec <= trunc(sysdate));
          exception when no_data_found then
            v_codpaypy1 := null;
          end;
        end if;
        -- check amount inc & ded & tax
        begin
          select sum(nvl(stddec(amtpay1,codempid,v_chken),0) +
                     nvl(stddec(amtpay2,codempid,v_chken),0) +
                     nvl(stddec(amtpay3,codempid,v_chken),0) +
                     nvl(stddec(amtpay4,codempid,v_chken),0) +
                     nvl(stddec(amtpay5,codempid,v_chken),0) +
                     nvl(stddec(amtpay6,codempid,v_chken),0) +
                     nvl(stddec(amtpay7,codempid,v_chken),0) +
                     nvl(stddec(amtpay8,codempid,v_chken),0) +
                     nvl(stddec(amtpay9,codempid,v_chken),0) +
                     nvl(stddec(amtpay10,codempid,v_chken),0)+
                     nvl(stddec(amtpay11,codempid,v_chken),0)+
                     nvl(stddec(amtpay12,codempid,v_chken),0))
           into	 v_amtinc
           from  tytdinc
          where	 dteyrepay	=	p_dteyrepay - global_v_zyear
            and  codempid = v_codempid
            and  typpay in	('1','2','3')
            and  codpay <> v_codpaypy1;
        exception when no_data_found then
          v_amtinc := 0;
        end;
        --
        begin
          select sum(nvl(stddec(amtpay1,codempid,v_chken),0) +
                     nvl(stddec(amtpay2,codempid,v_chken),0) +
                     nvl(stddec(amtpay3,codempid,v_chken),0) +
                     nvl(stddec(amtpay4,codempid,v_chken),0) +
                     nvl(stddec(amtpay5,codempid,v_chken),0) +
                     nvl(stddec(amtpay6,codempid,v_chken),0) +
                     nvl(stddec(amtpay7,codempid,v_chken),0) +
                     nvl(stddec(amtpay8,codempid,v_chken),0) +
                     nvl(stddec(amtpay9,codempid,v_chken),0) +
                     nvl(stddec(amtpay10,codempid,v_chken),0)+
                     nvl(stddec(amtpay11,codempid,v_chken),0)+
                     nvl(stddec(amtpay12,codempid,v_chken),0))
              into	v_amtded
              from  tytdinc
              where dteyrepay	=	p_dteyrepay - global_v_zyear
                and codempid = v_codempid
                and typpay in ('4','5')
                and codpay <> v_codpaypy1;
        exception when no_data_found then
          v_amtded := 0;
        end;
        --
        begin
          select sum(nvl(stddec(amtpay1,codempid,v_chken),0) +
                     nvl(stddec(amtpay2,codempid,v_chken),0) +
                     nvl(stddec(amtpay3,codempid,v_chken),0) +
                     nvl(stddec(amtpay4,codempid,v_chken),0) +
                     nvl(stddec(amtpay5,codempid,v_chken),0) +
                     nvl(stddec(amtpay6,codempid,v_chken),0) +
                     nvl(stddec(amtpay7,codempid,v_chken),0) +
                     nvl(stddec(amtpay8,codempid,v_chken),0) +
                     nvl(stddec(amtpay9,codempid,v_chken),0) +
                     nvl(stddec(amtpay10,codempid,v_chken),0)+
                     nvl(stddec(amtpay11,codempid,v_chken),0)+
                     nvl(stddec(amtpay12,codempid,v_chken),0))
          into   v_amttax
          from   tytdinc
          where  dteyrepay =	p_dteyrepay - global_v_zyear
            and	 codempid  = v_codempid;
        exception when no_data_found then
          v_amttax := 0;
        end;
        --
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        if nvl(v_amtinc,0) > 0 then
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpay', get_label_name(v_codapp,global_v_lang,'230'));
          v_exist_inc := TRUE;
        end if;
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
        --
        if v_exist_inc then
          for r2 in c_inc loop
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codpay', r2.codpay);
            obj_data.put('codcompy', r2.codcompy);
            obj_data.put('dteyrepay', r2.dteyrepay);
            obj_data.put('image', get_emp_img(r2.codempid));
            obj_data.put('codempid', r2.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r2.codempid, global_v_lang));
            obj_data.put('desc_codpay', get_tinexinf_name(r2.codpay,global_v_lang));
            --<<User37 #3562 4.ES.MS Module 28/04/2021
            for i in 1..12 loop
                if chk_dtewatch (v_codcompy,r1.typpayroll,null, i, p_dteyrepay - global_v_zyear) = true or p_flgess = false then
                    if i = 1 then
                        v_amtpay(i) := nvl(r2.amtpay1,0);
                        v_suminc1  := nvl(v_suminc1,0) + nvl(v_amtpay(i),0);
                    elsif i = 2 then
                        v_amtpay(i) := nvl(r2.amtpay2,0);
                        v_suminc2  := nvl(v_suminc2,0) + nvl(v_amtpay(i),0);
                    elsif i = 3 then
                        v_amtpay(i) := nvl(r2.amtpay3,0);
                        v_suminc3  := nvl(v_suminc3,0) + nvl(v_amtpay(i),0);
                    elsif i = 4 then
                        v_amtpay(i) := nvl(r2.amtpay4,0);
                        v_suminc4  := nvl(v_suminc4,0) + nvl(v_amtpay(i),0);
                    elsif i = 5 then
                        v_amtpay(i) := nvl(r2.amtpay5,0);
                        v_suminc5  := nvl(v_suminc5,0) + nvl(v_amtpay(i),0);
                    elsif i = 6 then
                        v_amtpay(i) := nvl(r2.amtpay6,0);
                        v_suminc6  := nvl(v_suminc6,0) + nvl(v_amtpay(i),0);
                    elsif i = 7 then
                        v_amtpay(i) := nvl(r2.amtpay7,0);
                        v_suminc7  := nvl(v_suminc7,0) + nvl(v_amtpay(i),0);
                    elsif i = 8 then
                        v_amtpay(i) := nvl(r2.amtpay8,0);
                        v_suminc8  := nvl(v_suminc8,0) + nvl(v_amtpay(i),0);
                    elsif i = 9 then
                        v_amtpay(i) := nvl(r2.amtpay9,0);
                        v_suminc9  := nvl(v_suminc9,0) + nvl(v_amtpay(i),0);
                    elsif i = 10 then
                        v_amtpay(i) := nvl(r2.amtpay10,0);
                        v_suminc10  := nvl(v_suminc10,0) + nvl(v_amtpay(i),0);
                    elsif i = 11 then
                        v_amtpay(i) := nvl(r2.amtpay11,0);
                        v_suminc11  := nvl(v_suminc11,0) + nvl(v_amtpay(i),0);
                    elsif i = 12 then
                        v_amtpay(i) := nvl(r2.amtpay12,0);
                        v_suminc12  := nvl(v_suminc12,0) + nvl(v_amtpay(i),0);
                    end if;
                else
                    v_amtpay(i) := null;
                    if i = 1 then
                        v_suminc1  := null;
                    elsif i = 2 then
                        v_suminc2  := null;
                    elsif i = 3 then
                        v_suminc3  := null;
                    elsif i = 4 then
                        v_suminc4  := null;
                    elsif i = 5 then
                        v_suminc5  := null;
                    elsif i = 6 then
                        v_suminc6  := null;
                    elsif i = 7 then
                        v_suminc7  := null;
                    elsif i = 8 then
                        v_suminc8  := null;
                    elsif i = 9 then
                        v_suminc9  := null;
                    elsif i = 10 then
                        v_suminc10  := null;
                    elsif i = 11 then
                        v_suminc11  := null;
                    elsif i = 12 then
                        v_suminc12  := null;
                    end if;
                end if;
            end loop;
            v_amtpay_sum := 0;
            for i in 1..12 loop
                obj_data.put('amtpay'||i, to_char(v_amtpay(i),'fm999,999,990.00'));
                v_amtpay_sum := nvl(v_amtpay_sum,0) + nvl(v_amtpay(i),0);
            end loop;
            if v_amtpay(1) is null then
                obj_data.put('total', '');
                v_total := null;
            else
                obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));
                v_total := nvl(v_total,0) + nvl(v_amtpay(1),0)  + nvl(v_amtpay(2),0)  + nvl(v_amtpay(3),0) +
                                  nvl(v_amtpay(4),0)  + nvl(v_amtpay(5),0)  + nvl(v_amtpay(6),0) +
                                  nvl(v_amtpay(7),0)  + nvl(v_amtpay(8),0)  + nvl(v_amtpay(9),0) +
                                  nvl(v_amtpay(10),0) + nvl(v_amtpay(11),0) + nvl(v_amtpay(12),0);
                obj_row.put(to_char(v_rcnt), obj_data);
            end if;
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
            /*obj_data.put('amtpay1', to_char(nvl(r2.amtpay1,0),'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(nvl(r2.amtpay2,0),'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(nvl(r2.amtpay3,0),'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(nvl(r2.amtpay4,0),'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(nvl(r2.amtpay5,0),'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(nvl(r2.amtpay6,0),'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(nvl(r2.amtpay7,0),'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(nvl(r2.amtpay8,0),'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(nvl(r2.amtpay9,0),'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(nvl(r2.amtpay10,0),'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(nvl(r2.amtpay11,0),'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(nvl(r2.amtpay12,0),'fm999,999,990.00'));
            v_amtpay_sum := nvl(r2.amtpay1,0)  + nvl(r2.amtpay2,0)  + nvl(r2.amtpay3,0) +
                            nvl(r2.amtpay4,0)  + nvl(r2.amtpay5,0)  + nvl(r2.amtpay6,0) +
                            nvl(r2.amtpay7,0)  + nvl(r2.amtpay8,0)  + nvl(r2.amtpay9,0) +
                            nvl(r2.amtpay10,0) + nvl(r2.amtpay11,0) + nvl(r2.amtpay12,0);
            obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
            v_suminc1  := v_suminc1 + r2.amtpay1;
            v_suminc2  := v_suminc2 + r2.amtpay2;
            v_suminc3  := v_suminc3 + r2.amtpay3;
            v_suminc4  := v_suminc4 + r2.amtpay4;
            v_suminc5  := v_suminc5 + r2.amtpay5;
            v_suminc6  := v_suminc6 + r2.amtpay6;
            v_suminc7  := v_suminc7 + r2.amtpay7;
            v_suminc8  := v_suminc8 + r2.amtpay8;
            v_suminc9  := v_suminc9 + r2.amtpay9;
            v_suminc10 := v_suminc10 + r2.amtpay10;
            v_suminc11 := v_suminc11 + r2.amtpay11;
            v_suminc12 := v_suminc12 + r2.amtpay12;
            v_total := v_total + (nvl(r2.amtpay1,0)  + nvl(r2.amtpay2,0)  + nvl(r2.amtpay3,0) +
                                  nvl(r2.amtpay4,0)  + nvl(r2.amtpay5,0)  + nvl(r2.amtpay6,0) +
                                  nvl(r2.amtpay7,0)  + nvl(r2.amtpay8,0)  + nvl(r2.amtpay9,0) +
                                  nvl(r2.amtpay10,0) + nvl(r2.amtpay11,0) + nvl(r2.amtpay12,0));*/
            -->>User37 #3562 4.ES.MS Module 28/04/2021
          end loop;
          --
          if (nvl(v_suminc1,0) <> 0) or (nvl(v_suminc2,0) <> 0) or (nvl(v_suminc3,0) <> 0) or
             (nvl(v_suminc4,0) <> 0) or (nvl(v_suminc5,0) <> 0) or (nvl(v_suminc6,0) <> 0) or
             (nvl(v_suminc7,0) <> 0) or (nvl(v_suminc8,0) <> 0) or (nvl(v_suminc9,0) <> 0) or
             (nvl(v_suminc10,0) <> 0) or (nvl(v_suminc11,0) <> 0) or (nvl(v_suminc12,0) <> 0) then

            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('desc_codpay', get_label_name(v_codapp,global_v_lang,'290'));

            --<<User37 #3562 4.ES.MS Module 28/04/2021
            obj_data.put('amtpay1', to_char(v_suminc1,'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(v_suminc2,'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(v_suminc3,'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(v_suminc4,'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(v_suminc5,'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(v_suminc6,'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(v_suminc7,'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(v_suminc8,'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(v_suminc9,'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(v_suminc10,'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(v_suminc11,'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(v_suminc12,'fm999,999,990.00'));
            obj_data.put('total', to_char(v_total,'fm999,999,990.00'));
            /*obj_data.put('amtpay1', to_char(nvl(v_suminc1,0),'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(nvl(v_suminc2,0),'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(nvl(v_suminc3,0),'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(nvl(v_suminc4,0),'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(nvl(v_suminc5,0),'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(nvl(v_suminc6,0),'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(nvl(v_suminc7,0),'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(nvl(v_suminc8,0),'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(nvl(v_suminc9,0),'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(nvl(v_suminc10,0),'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(nvl(v_suminc11,0),'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(nvl(v_suminc12,0),'fm999,999,990.00'));
            obj_data.put('total', to_char(nvl(v_total,0),'fm999,999,990.00'));*/
            -->>User37 #3562 4.ES.MS Module 28/04/2021

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
          end if;
          v_incnet:= v_total;
          v_total := 0;
        end if;
        --
        if nvl(v_amtded,0) > 0 then
          obj_data         := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpay', get_label_name(v_codapp,global_v_lang,'240'));
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt  := v_rcnt + 1;
          for r3 in c_ded loop
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codpay', r3.codpay);
            obj_data.put('codcompy', r3.codcompy);
            obj_data.put('dteyrepay', r3.dteyrepay);
            obj_data.put('image', get_emp_img(r3.codempid));
            obj_data.put('codempid', r3.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r3.codempid, global_v_lang));
            obj_data.put('desc_codpay', get_tinexinf_name(r3.codpay,global_v_lang));

            --<<User37 #3562 4.ES.MS Module 28/04/2021
            for i in 1..12 loop
                if chk_dtewatch (v_codcompy,r1.typpayroll,null, i, p_dteyrepay - global_v_zyear) = true or p_flgess = false then
                    if i = 1 then
                        v_amtpay(i) := nvl(r3.amtpay1,0);
                        v_sumded1  := nvl(v_sumded1,0) + nvl(v_amtpay(i),0);
                    elsif i = 2 then
                        v_amtpay(i) := nvl(r3.amtpay2,0);
                        v_sumded2  := nvl(v_sumded2,0) + nvl(v_amtpay(i),0);
                    elsif i = 3 then
                        v_amtpay(i) := nvl(r3.amtpay3,0);
                        v_sumded3  := nvl(v_sumded3,0) + nvl(v_amtpay(i),0);
                    elsif i = 4 then
                        v_amtpay(i) := nvl(r3.amtpay4,0);
                        v_sumded4  := nvl(v_sumded4,0) + nvl(v_amtpay(i),0);
                    elsif i = 5 then
                        v_amtpay(i) := nvl(r3.amtpay5,0);
                        v_sumded5  := nvl(v_sumded5,0) + nvl(v_amtpay(i),0);
                    elsif i = 6 then
                        v_amtpay(i) := nvl(r3.amtpay6,0);
                        v_sumded6  := nvl(v_sumded6,0) + nvl(v_amtpay(i),0);
                    elsif i = 7 then
                        v_amtpay(i) := nvl(r3.amtpay7,0);
                        v_sumded7  := nvl(v_sumded7,0) + nvl(v_amtpay(i),0);
                    elsif i = 8 then
                        v_amtpay(i) := nvl(r3.amtpay8,0);
                        v_sumded8  := nvl(v_sumded8,0) + nvl(v_amtpay(i),0);
                    elsif i = 9 then
                        v_amtpay(i) := nvl(r3.amtpay9,0);
                        v_sumded9  := nvl(v_sumded9,0) + nvl(v_amtpay(i),0);
                    elsif i = 10 then
                        v_amtpay(i) := nvl(r3.amtpay10,0);
                        v_sumded10  := nvl(v_sumded10,0) + nvl(v_amtpay(i),0);
                    elsif i = 11 then
                        v_amtpay(i) := nvl(r3.amtpay11,0);
                        v_sumded11  := nvl(v_sumded11,0) + nvl(v_amtpay(i),0);
                    elsif i = 12 then
                        v_amtpay(i) := nvl(r3.amtpay12,0);
                        v_sumded12  := nvl(v_sumded12,0) + nvl(v_amtpay(i),0);
                    end if;
                else
                    v_amtpay(i) := null;
                    if i = 1 then
                        v_sumded1  := null;
                    elsif i = 2 then
                        v_sumded2  := null;
                    elsif i = 3 then
                        v_sumded3  := null;
                    elsif i = 4 then
                        v_sumded4  := null;
                    elsif i = 5 then
                        v_sumded5  := null;
                    elsif i = 6 then
                        v_sumded6  := null;
                    elsif i = 7 then
                        v_sumded7  := null;
                    elsif i = 8 then
                        v_sumded8  := null;
                    elsif i = 9 then
                        v_sumded9  := null;
                    elsif i = 10 then
                        v_sumded10  := null;
                    elsif i = 11 then
                        v_sumded11  := null;
                    elsif i = 12 then
                        v_sumded12  := null;
                    end if;
                end if;
            end loop;
            v_amtpay_sum :=0; --12/05/2021
            for i in 1..12 loop
                obj_data.put('amtpay'||i, to_char(v_amtpay(i),'fm999,999,990.00'));
                v_amtpay_sum := nvl(v_amtpay_sum,0) + nvl(v_amtpay(i),0);
            end loop;
            if v_amtpay(1) is null then
                obj_data.put('total', '');
                v_total := null;
            else
                obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));--12/05/2021
                v_total := nvl(v_total,0) + nvl(v_amtpay(1),0)  + nvl(v_amtpay(2),0)  + nvl(v_amtpay(3),0) +
                                  nvl(v_amtpay(4),0)  + nvl(v_amtpay(5),0)  + nvl(v_amtpay(6),0) +
                                  nvl(v_amtpay(7),0)  + nvl(v_amtpay(8),0)  + nvl(v_amtpay(9),0) +
                                  nvl(v_amtpay(10),0) + nvl(v_amtpay(11),0) + nvl(v_amtpay(12),0);
                obj_row.put(to_char(v_rcnt), obj_data);
            end if;
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;

            /*obj_data.put('amtpay1', to_char(nvl(r3.amtpay1,0),'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(nvl(r3.amtpay2,0),'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(nvl(r3.amtpay3,0),'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(nvl(r3.amtpay4,0),'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(nvl(r3.amtpay5,0),'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(nvl(r3.amtpay6,0),'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(nvl(r3.amtpay7,0),'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(nvl(r3.amtpay8,0),'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(nvl(r3.amtpay9,0),'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(nvl(r3.amtpay10,0),'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(nvl(r3.amtpay11,0),'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(nvl(r3.amtpay12,0),'fm999,999,990.00'));
            v_amtpay_sum := nvl(r3.amtpay1,0)  + nvl(r3.amtpay2,0)  + nvl(r3.amtpay3,0) +
                            nvl(r3.amtpay4,0)  + nvl(r3.amtpay5,0)  + nvl(r3.amtpay6,0) +
                            nvl(r3.amtpay7,0)  + nvl(r3.amtpay8,0)  + nvl(r3.amtpay9,0) +
                            nvl(r3.amtpay10,0) + nvl(r3.amtpay11,0) + nvl(r3.amtpay12,0);
            obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;

            v_sumded1  := v_sumded1 + r3.amtpay1;
            v_sumded2  := v_sumded2 + r3.amtpay2;
            v_sumded3  := v_sumded3 + r3.amtpay3;
            v_sumded4  := v_sumded4 + r3.amtpay4;
            v_sumded5  := v_sumded5 + r3.amtpay5;
            v_sumded6  := v_sumded6 + r3.amtpay6;
            v_sumded7  := v_sumded7 + r3.amtpay7;
            v_sumded8  := v_sumded8 + r3.amtpay8;
            v_sumded9  := v_sumded9 + r3.amtpay9;
            v_sumded10 := v_sumded10 + r3.amtpay10;
            v_sumded11 := v_sumded11 + r3.amtpay11;
            v_sumded12 := v_sumded12 + r3.amtpay12;
            v_total := v_total + (nvl(r3.amtpay1,0)  + nvl(r3.amtpay2,0)  + nvl(r3.amtpay3,0) +
                                  nvl(r3.amtpay4,0)  + nvl(r3.amtpay5,0)  + nvl(r3.amtpay6,0) +
                                  nvl(r3.amtpay7,0)  + nvl(r3.amtpay8,0)  + nvl(r3.amtpay9,0) +
                                  nvl(r3.amtpay10,0) + nvl(r3.amtpay11,0) + nvl(r3.amtpay12,0));*/
            -->>User37 #3562 4.ES.MS Module 28/04/2021
          end loop;
          --
          if (nvl(v_sumded1,0) <> 0) or (nvl(v_sumded2,0) <> 0) or (nvl(v_sumded3,0) <> 0) or
             (nvl(v_sumded4,0) <> 0) or (nvl(v_sumded5,0) <> 0) or (nvl(v_sumded6,0) <> 0) or
             (nvl(v_sumded7,0) <> 0) or (nvl(v_sumded8,0) <> 0) or (nvl(v_sumded9,0) <> 0) or
             (nvl(v_sumded10,0) <> 0) or (nvl(v_sumded11,0) <> 0) or (nvl(v_sumded12,0) <> 0) then
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('desc_codpay', get_label_name(v_codapp,global_v_lang,'290'));

            --<<User37 #3562 4.ES.MS Module 28/04/2021
            obj_data.put('amtpay1', to_char(v_sumded1,'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(v_sumded2,'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(v_sumded3,'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(v_sumded4,'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(v_sumded5,'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(v_sumded6,'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(v_sumded7,'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(v_sumded8,'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(v_sumded9,'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(v_sumded10,'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(v_sumded11,'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(v_sumded12,'fm999,999,990.00'));
            obj_data.put('total', to_char(v_total,'fm999,999,990.00'));--12/05/2021
            /*obj_data.put('amtpay1', to_char(nvl(v_sumded1,0),'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(nvl(v_sumded2,0),'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(nvl(v_sumded3,0),'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(nvl(v_sumded4,0),'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(nvl(v_sumded5,0),'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(nvl(v_sumded6,0),'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(nvl(v_sumded7,0),'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(nvl(v_sumded8,0),'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(nvl(v_sumded9,0),'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(nvl(v_sumded10,0),'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(nvl(v_sumded11,0),'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(nvl(v_sumded12,0),'fm999,999,990.00'));
            obj_data.put('total', to_char(nvl(v_total,0),'fm999,999,990.00'));*/
            -->>User37 #3562 4.ES.MS Module 28/04/2021

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
          end if;
          v_dednet:= v_total;
          v_total := 0;
        end if;
        --
        if nvl(v_amttax,0) > 0 then
          v_first := TRUE;--User37 Final Test Phase 1 V11 #2274 25/11/2020
          for r4 in c_tax loop
            if r4.codcomp <> v_comp then
              v_comp := r4.codcompy;
              begin
                select codpaypy1
                into v_codpaypy1
                from tcontrpy
                where codcompy = v_comp
                  and dteeffec = (select max(dteeffec)
                                  from tcontrpy
                                  where codcompy = r4.codcompy
                                    and dteeffec < trunc(sysdate));
              exception when no_data_found then
                v_codpaypy1 := null;
              end;
            end if;
             --
            if (r4.typpay = 6) or nvl(v_codpaypy1,'%$') = r4.codpay then
              if v_first then
                obj_data         := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('image', get_emp_img(r1.codempid));
                obj_data.put('codempid', r1.codempid);
                obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
                obj_data.put('codpay', get_label_name(v_codapp,global_v_lang,'250'));
                obj_row.put(to_char(v_rcnt), obj_data);
                v_rcnt  := v_rcnt + 1;
                v_first := FALSE;
              end if;
              --
              obj_data         := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('codpay', r4.codpay);
              obj_data.put('codcompy', r4.codcompy);
              obj_data.put('dteyrepay', r4.dteyrepay);
              obj_data.put('image', get_emp_img(r4.codempid));
              obj_data.put('codempid', r4.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r4.codempid, global_v_lang));
              obj_data.put('desc_codpay', get_tinexinf_name(r4.codpay,global_v_lang));
              --<<User37 #3562 4.ES.MS Module 28/04/2021
              for i in 1..12 loop
                  if chk_dtewatch (v_codcompy,r1.typpayroll,null, i, p_dteyrepay - global_v_zyear) = true or p_flgess = false then
                      if i = 1 then
                          v_amtpay(i) := nvl(r4.amtpay1,0);
                          v_sumtax1  := nvl(v_sumtax1,0) + nvl(v_amtpay(i),0);
                      elsif i = 2 then
                          v_amtpay(i) := nvl(r4.amtpay2,0);
                          v_sumtax2  := nvl(v_sumtax2,0) + nvl(v_amtpay(i),0);
                      elsif i = 3 then
                          v_amtpay(i) := nvl(r4.amtpay3,0);
                          v_sumtax3  := nvl(v_sumtax3,0) + nvl(v_amtpay(i),0);
                      elsif i = 4 then
                          v_amtpay(i) := nvl(r4.amtpay4,0);
                          v_sumtax4  := nvl(v_sumtax4,0) + nvl(v_amtpay(i),0);
                      elsif i = 5 then
                          v_amtpay(i) := nvl(r4.amtpay5,0);
                          v_sumtax5  := nvl(v_sumtax5,0) + nvl(v_amtpay(i),0);
                      elsif i = 6 then
                          v_amtpay(i) := nvl(r4.amtpay6,0);
                          v_sumtax6  := nvl(v_sumtax6,0) + nvl(v_amtpay(i),0);
                      elsif i = 7 then
                          v_amtpay(i) := nvl(r4.amtpay7,0);
                          v_sumtax7  := nvl(v_sumtax7,0) + nvl(v_amtpay(i),0);
                      elsif i = 8 then
                          v_amtpay(i) := nvl(r4.amtpay8,0);
                          v_sumtax8  := nvl(v_sumtax8,0) + nvl(v_amtpay(i),0);
                      elsif i = 9 then
                          v_amtpay(i) := nvl(r4.amtpay9,0);
                          v_sumtax9  := nvl(v_sumtax9,0) + nvl(v_amtpay(i),0);
                      elsif i = 10 then
                          v_amtpay(i) := nvl(r4.amtpay10,0);
                          v_sumtax10  := nvl(v_sumtax10,0) + nvl(v_amtpay(i),0);
                      elsif i = 11 then
                          v_amtpay(i) := nvl(r4.amtpay11,0);
                          v_sumtax11  := nvl(v_sumtax11,0) + nvl(v_amtpay(i),0);
                      elsif i = 12 then
                          v_amtpay(i) := nvl(r4.amtpay12,0);
                          v_sumtax12  := nvl(v_sumtax12,0) + nvl(v_amtpay(i),0);
                      end if;
                  else
                      v_amtpay(i) := null;
                      if i = 1 then
                          v_sumtax1  := null;
                      elsif i = 2 then
                          v_sumtax2  := null;
                      elsif i = 3 then
                          v_sumtax3  := null;
                      elsif i = 4 then
                          v_sumtax4  := null;
                      elsif i = 5 then
                          v_sumtax5  := null;
                      elsif i = 6 then
                          v_sumtax6  := null;
                      elsif i = 7 then
                          v_sumtax7  := null;
                      elsif i = 8 then
                          v_sumtax8  := null;
                      elsif i = 9 then
                          v_sumtax9  := null;
                      elsif i = 10 then
                          v_sumtax10  := null;
                      elsif i = 11 then
                          v_sumtax11  := null;
                      elsif i = 12 then
                          v_sumtax12  := null;
                      end if;
                  end if;
              end loop;
              v_amtpay_sum :=0;--12/05/2021
              for i in 1..12 loop
                  obj_data.put('amtpay'||i, to_char(v_amtpay(i),'fm999,999,990.00'));
                  v_amtpay_sum := nvl(v_amtpay_sum,0) + nvl(v_amtpay(i),0);
              end loop;

              if v_amtpay(1) is null then
                  obj_data.put('total', '');
                  v_total := null;
              else
                  obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));--12/05/2021
                  v_total := nvl(v_total,0) + nvl(v_amtpay(1),0)  + nvl(v_amtpay(2),0)  + nvl(v_amtpay(3),0) +
                                    nvl(v_amtpay(4),0)  + nvl(v_amtpay(5),0)  + nvl(v_amtpay(6),0) +
                                    nvl(v_amtpay(7),0)  + nvl(v_amtpay(8),0)  + nvl(v_amtpay(9),0) +
                                    nvl(v_amtpay(10),0) + nvl(v_amtpay(11),0) + nvl(v_amtpay(12),0);
                 obj_row.put(to_char(v_rcnt), obj_data);
              end if;
              obj_row.put(to_char(v_rcnt), obj_data);
              v_rcnt           := v_rcnt + 1;
              /*obj_data.put('amtpay1', to_char(nvl(r4.amtpay1,0),'fm999,999,990.00'));
              obj_data.put('amtpay2', to_char(nvl(r4.amtpay2,0),'fm999,999,990.00'));
              obj_data.put('amtpay3', to_char(nvl(r4.amtpay3,0),'fm999,999,990.00'));
              obj_data.put('amtpay4', to_char(nvl(r4.amtpay4,0),'fm999,999,990.00'));
              obj_data.put('amtpay5', to_char(nvl(r4.amtpay5,0),'fm999,999,990.00'));
              obj_data.put('amtpay6', to_char(nvl(r4.amtpay6,0),'fm999,999,990.00'));
              obj_data.put('amtpay7', to_char(nvl(r4.amtpay7,0),'fm999,999,990.00'));
              obj_data.put('amtpay8', to_char(nvl(r4.amtpay8,0),'fm999,999,990.00'));
              obj_data.put('amtpay9', to_char(nvl(r4.amtpay9,0),'fm999,999,990.00'));
              obj_data.put('amtpay10', to_char(nvl(r4.amtpay10,0),'fm999,999,990.00'));
              obj_data.put('amtpay11', to_char(nvl(r4.amtpay11,0),'fm999,999,990.00'));
              obj_data.put('amtpay12', to_char(nvl(r4.amtpay12,0),'fm999,999,990.00'));
              v_amtpay_sum := nvl(r4.amtpay1,0)  + nvl(r4.amtpay2,0)  + nvl(r4.amtpay3,0) +
                              nvl(r4.amtpay4,0)  + nvl(r4.amtpay5,0)  + nvl(r4.amtpay6,0) +
                              nvl(r4.amtpay7,0)  + nvl(r4.amtpay8,0)  + nvl(r4.amtpay9,0) +
                              nvl(r4.amtpay10,0) + nvl(r4.amtpay11,0) + nvl(r4.amtpay12,0);
              obj_data.put('total', to_char(nvl(v_amtpay_sum,0),'fm999,999,990.00'));

              obj_row.put(to_char(v_rcnt), obj_data);
              v_rcnt           := v_rcnt + 1;
              --
              v_sumtax1  := v_sumtax1 + r4.amtpay1;
              v_sumtax2  := v_sumtax2 + r4.amtpay2;
              v_sumtax3  := v_sumtax3 + r4.amtpay3;
              v_sumtax4  := v_sumtax4 + r4.amtpay4;
              v_sumtax5  := v_sumtax5 + r4.amtpay5;
              v_sumtax6  := v_sumtax6 + r4.amtpay6;
              v_sumtax7  := v_sumtax7 + r4.amtpay7;
              v_sumtax8  := v_sumtax8 + r4.amtpay8;
              v_sumtax9  := v_sumtax9 + r4.amtpay9;
              v_sumtax10 := v_sumtax10 + r4.amtpay10;
              v_sumtax11 := v_sumtax11 + r4.amtpay11;
              v_sumtax12 := v_sumtax12 + r4.amtpay12;
              v_total := v_total + (nvl(r4.amtpay1,0)  + nvl(r4.amtpay2,0)  + nvl(r4.amtpay3,0) +
                                    nvl(r4.amtpay4,0)  + nvl(r4.amtpay5,0)  + nvl(r4.amtpay6,0) +
                                    nvl(r4.amtpay7,0)  + nvl(r4.amtpay8,0)  + nvl(r4.amtpay9,0) +
                                    nvl(r4.amtpay10,0) + nvl(r4.amtpay11,0) + nvl(r4.amtpay12,0));*/
              -->>User37 #3562 4.ES.MS Module 28/04/2021
            end if;
          end loop;
          if (nvl(v_sumtax1,0) <> 0) or (nvl(v_sumtax2,0) <> 0) or (nvl(v_sumtax3,0) <> 0) or
             (nvl(v_sumtax4,0) <> 0) or (nvl(v_sumtax5,0) <> 0) or (nvl(v_sumtax6,0) <> 0) or
             (nvl(v_sumtax7,0) <> 0) or (nvl(v_sumtax8,0) <> 0) or (nvl(v_sumtax9,0) <> 0) or
             (nvl(v_sumtax10,0) <> 0) or (nvl(v_sumtax11,0) <> 0) or (nvl(v_sumtax12,0) <> 0) then

            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('desc_codpay', get_label_name(v_codapp,global_v_lang,'290'));

            --<<User37 #3562 4.ES.MS Module 28/04/2021
            obj_data.put('amtpay1', to_char(v_sumtax1,'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(v_sumtax2,'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(v_sumtax3,'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(v_sumtax4,'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(v_sumtax5,'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(v_sumtax6,'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(v_sumtax7,'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(v_sumtax8,'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(v_sumtax9,'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(v_sumtax10,'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(v_sumtax11,'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(v_sumtax12,'fm999,999,990.00'));
            obj_data.put('total', to_char(v_total,'fm999,999,990.00'));--12/05/2021
            /*obj_data.put('amtpay1', to_char(nvl(v_sumtax1,0),'fm999,999,990.00'));
            obj_data.put('amtpay2', to_char(nvl(v_sumtax2,0),'fm999,999,990.00'));
            obj_data.put('amtpay3', to_char(nvl(v_sumtax3,0),'fm999,999,990.00'));
            obj_data.put('amtpay4', to_char(nvl(v_sumtax4,0),'fm999,999,990.00'));
            obj_data.put('amtpay5', to_char(nvl(v_sumtax5,0),'fm999,999,990.00'));
            obj_data.put('amtpay6', to_char(nvl(v_sumtax6,0),'fm999,999,990.00'));
            obj_data.put('amtpay7', to_char(nvl(v_sumtax7,0),'fm999,999,990.00'));
            obj_data.put('amtpay8', to_char(nvl(v_sumtax8,0),'fm999,999,990.00'));
            obj_data.put('amtpay9', to_char(nvl(v_sumtax9,0),'fm999,999,990.00'));
            obj_data.put('amtpay10', to_char(nvl(v_sumtax10,0),'fm999,999,990.00'));
            obj_data.put('amtpay11', to_char(nvl(v_sumtax11,0),'fm999,999,990.00'));
            obj_data.put('amtpay12', to_char(nvl(v_sumtax12,0),'fm999,999,990.00'));
            obj_data.put('total', to_char(nvl(v_total,0),'fm999,999,990.00'));*/
            -->>User37 #3562 4.ES.MS Module 28/04/2021

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
          end if;
          v_taxnet:= v_total;
          v_total := 0;
        end if;
        -- sum total --
        --<<User37 #3562 4.ES.MS Module 28/04/2021
        if v_suminc1 is null then
            v_temp01  := null;
        else
            v_temp01  := nvl(v_suminc1,0)  - (nvl(v_sumded1,0)  + nvl(v_sumtax1,0));
        end if;
        if v_suminc2 is null then
            v_temp02  := null;
        else
            v_temp02  := nvl(v_suminc2,0)  - (nvl(v_sumded2,0)  + nvl(v_sumtax2,0));
        end if;
        if v_suminc3 is null then
            v_temp03  := null;
        else
            v_temp03  := nvl(v_suminc3,0)  - (nvl(v_sumded3,0)  + nvl(v_sumtax3,0));
        end if;
        if v_suminc4 is null then
            v_temp04  := null;
        else
            v_temp04  := nvl(v_suminc4,0)  - (nvl(v_sumded4,0)  + nvl(v_sumtax4,0));
        end if;
        if v_suminc5 is null then
            v_temp05  := null;
        else
            v_temp05  := nvl(v_suminc5,0)  - (nvl(v_sumded5,0)  + nvl(v_sumtax5,0));
        end if;
        if v_suminc6 is null then
            v_temp06  := null;
        else
            v_temp06  := nvl(v_suminc6,0)  - (nvl(v_sumded6,0)  + nvl(v_sumtax6,0));
        end if;
        if v_suminc7 is null then
            v_temp07  := null;
        else
            v_temp07  := nvl(v_suminc7,0)  - (nvl(v_sumded7,0)  + nvl(v_sumtax7,0));
        end if;
        if v_suminc8 is null then
            v_temp08  := null;
        else
            v_temp08  := nvl(v_suminc8,0)  - (nvl(v_sumded8,0)  + nvl(v_sumtax8,0));
        end if;
        if v_suminc9 is null then
            v_temp09  := null;
        else
            v_temp09  := nvl(v_suminc9,0)  - (nvl(v_sumded9,0)  + nvl(v_sumtax9,0));
        end if;
        if v_suminc10 is null then
            v_temp10  := null;
        else
            v_temp10  := nvl(v_suminc10,0) - (nvl(v_sumded10,0) + nvl(v_sumtax10,0));
        end if;
        if v_suminc11 is null then
            v_temp11  := null;
        else
            v_temp11  := nvl(v_suminc11,0) - (nvl(v_sumded11,0) + nvl(v_sumtax11,0));
        end if;
        if v_suminc12 is null then
            v_temp12  := null;
        else
            v_temp12  := nvl(v_suminc12,0) - (nvl(v_sumded12,0) + nvl(v_sumtax12,0));
        end if;
        --
        if v_temp01 is null then
            v_temp13  := null;
        else
            v_temp13  := nvl(v_temp01,0) + nvl(v_temp02,0) + nvl(v_temp03,0) + nvl(v_temp04,0) +
                         nvl(v_temp05,0) + nvl(v_temp06,0) + nvl(v_temp07,0) + nvl(v_temp08,0) +
                         nvl(v_temp09,0) + nvl(v_temp10,0) + nvl(v_temp11,0) + nvl(v_temp12,0);
        end if;
        /*v_temp01  := nvl(v_suminc1,0)  - (nvl(v_sumded1,0)  + nvl(v_sumtax1,0));
        v_temp02  := nvl(v_suminc2,0)  - (nvl(v_sumded2,0)  + nvl(v_sumtax2,0));
        v_temp03  := nvl(v_suminc3,0)  - (nvl(v_sumded3,0)  + nvl(v_sumtax3,0));
        v_temp04  := nvl(v_suminc4,0)  - (nvl(v_sumded4,0)  + nvl(v_sumtax4,0));
        v_temp05  := nvl(v_suminc5,0)  - (nvl(v_sumded5,0)  + nvl(v_sumtax5,0));
        v_temp06  := nvl(v_suminc6,0)  - (nvl(v_sumded6,0)  + nvl(v_sumtax6,0));
        v_temp07  := nvl(v_suminc7,0)  - (nvl(v_sumded7,0)  + nvl(v_sumtax7,0));
        v_temp08  := nvl(v_suminc8,0)  - (nvl(v_sumded8,0)  + nvl(v_sumtax8,0));
        v_temp09  := nvl(v_suminc9,0)  - (nvl(v_sumded9,0)  + nvl(v_sumtax9,0));
        v_temp10  := nvl(v_suminc10,0) - (nvl(v_sumded10,0) + nvl(v_sumtax10,0));
        v_temp11  := nvl(v_suminc11,0) - (nvl(v_sumded11,0) + nvl(v_sumtax11,0));
        v_temp12  := nvl(v_suminc12,0) - (nvl(v_sumded12,0) + nvl(v_sumtax12,0));
        --
        v_temp13  := v_temp01 + v_temp02 + v_temp03 + v_temp04 +
                     v_temp05 + v_temp06 + v_temp07 + v_temp08 +
                     v_temp09 + v_temp10 + v_temp11 + v_temp12;
        --*/
        -->>User37 #3562 4.ES.MS Module 28/04/2021
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codpay', get_label_name(v_codapp,global_v_lang,'260'));

        obj_data.put('amtpay1', to_char(v_temp01,'fm999,999,990.00'));
        obj_data.put('amtpay2', to_char(v_temp02,'fm999,999,990.00'));
        obj_data.put('amtpay3', to_char(v_temp03,'fm999,999,990.00'));
        obj_data.put('amtpay4', to_char(v_temp04,'fm999,999,990.00'));
        obj_data.put('amtpay5', to_char(v_temp05,'fm999,999,990.00'));
        obj_data.put('amtpay6', to_char(v_temp06,'fm999,999,990.00'));
        obj_data.put('amtpay7', to_char(v_temp07,'fm999,999,990.00'));
        obj_data.put('amtpay8', to_char(v_temp08,'fm999,999,990.00'));
        obj_data.put('amtpay9', to_char(v_temp09,'fm999,999,990.00'));
        obj_data.put('amtpay10', to_char(v_temp10,'fm999,999,990.00'));
        obj_data.put('amtpay11', to_char(v_temp11,'fm999,999,990.00'));
        obj_data.put('amtpay12', to_char(v_temp12,'fm999,999,990.00'));
        obj_data.put('total', to_char(v_temp13,'fm999,999,990.00'));--12/05/2021

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
        --
        v_suminc1   := 0;
        v_suminc2		:= 0;
        v_suminc3		:= 0;
        v_suminc4		:= 0;
        v_suminc5		:= 0;
        v_suminc6		:= 0;
        v_suminc7		:= 0;
        v_suminc8		:= 0;
        v_suminc9		:= 0;
        v_suminc10	:= 0;
        v_suminc11	:= 0;
        v_suminc12	:= 0;
        --
        v_sumded1   := 0;
        v_sumded2   := 0;
        v_sumded3   := 0;
        v_sumded4   := 0;
        v_sumded5   := 0;
        v_sumded6	  := 0;
        v_sumded7   := 0;
        v_sumded8   := 0;
        v_sumded9   := 0;
        v_sumded10  := 0;
        v_sumded11  := 0;
        v_sumded12  := 0;
        ----
        v_sumtax1   := 0;
        v_sumtax2   := 0;
        v_sumtax3   := 0;
        v_sumtax4   := 0;
        v_sumtax5   := 0;
        v_sumtax6   := 0;
        v_sumtax7   := 0;
        v_sumtax8   := 0;
        v_sumtax9   := 0;
        v_sumtax10  := 0;
        v_sumtax11  := 0;
        v_sumtax12  := 0;

        v_total     :=0;
      end if;
    end loop;
    --
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;
end HRPY5GX;

/
