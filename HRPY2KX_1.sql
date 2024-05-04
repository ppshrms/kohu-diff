--------------------------------------------------------
--  DDL for Package Body HRPY2KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2KX" as

  procedure initial_value(json_str_input in clob) as
    json_obj 						json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_codlegald         := hcm_util.get_string_t(json_obj,'p_codlegald');
    p_codpay1           := hcm_util.get_string_t(json_obj,'p_codpay1');
    p_codpay2           := hcm_util.get_string_t(json_obj,'p_codpay2');
    p_codpay3           := hcm_util.get_string_t(json_obj,'p_codpay3');
    p_codpay4           := hcm_util.get_string_t(json_obj,'p_codpay4');
    p_codpay5           := hcm_util.get_string_t(json_obj,'p_codpay5');
    p_codpay6           := hcm_util.get_string_t(json_obj,'p_codpay6');
    p_codpay7           := hcm_util.get_string_t(json_obj,'p_codpay7');
    p_codpay8           := hcm_util.get_string_t(json_obj,'p_codpay8');
    p_codpay9           := hcm_util.get_string_t(json_obj,'p_codpay9');
    p_codpay10          := hcm_util.get_string_t(json_obj,'p_codpay10');
    p_codpay11          := hcm_util.get_string_t(json_obj,'p_codpay11');
    p_codpay12          := hcm_util.get_string_t(json_obj,'p_codpay12');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure get_report(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    gen_report(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_report;

  procedure check_index as
    v_codcomp   temploy1.codcomp%type;
    v_numlvl    temploy1.numlvl%type;
    v_chk       varchar2(1) := 'N';
  begin
    if p_codpay1 is null then
      begin
        select 'Y'
          into v_chk
          from tlegalprd t1, tlegalexe t2
         where t1.codempid = t2.codempid
           and t1.numcaselw = t2.numcaselw
           and t1.codcomp like p_codcomp||'%'
           and t1.codempid = nvl(p_codempid,t1.codempid)
           and t1.dteyrepay = p_dteyrepay
           and t1.dtemthpay = p_dtemthpay
           and t2.codlegald = nvl(p_codlegald,t2.codlegald)
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tlegalprd');
        return;
      end;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codempid is not null then
      begin
        select codempid,codcomp,numlvl
          into p_codempid,v_codcomp,v_numlvl
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
        return;
      end;
      if not secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure gen_report(json_str_output out clob) as
    v_chksecur  boolean;
    v_data      varchar2(1 char) := 'N';
    v_secure    varchar2(1 char) := 'N';
    v_numseq    number := 0;
    v_rec1      varchar2(500 char);
    v_rec2      varchar2(500 char);
    v_rec3      varchar2(500 char);
    v_rec4      varchar2(500 char);
    v_rec5      varchar2(500 char);
    v_rec6      varchar2(500 char);
    v_rec7      varchar2(500 char);
    v_amt1      number;
    v_amt2      number;
    v_amt3      number;
    v_amt4      number;
    v_amt5      number;
    v_amt6      number;
    v_amt7      number;
    v_chk1      varchar2(500 char);
    v_chk2      varchar2(500 char);
    v_chk3      varchar2(500 char);
    v_chk4      varchar2(500 char);
    v_chk5      varchar2(500 char);
    v_chk6      varchar2(500 char);
    v_chk7      varchar2(500 char);
    v_typpaymt  tlegalprd.typpaymt%type;
    v_numref    tlegalprd.numref%type;
    v_dtepay    varchar2(500 char);
    v_address   tcompny.adrcomt%type;
    v_numtele   tcompny.numtele%type;
    v_codempid  tlegalexp.codempid%type;
    v_numcaselw tlegalexp.numcaselw%type;
    v_codpay1   tlegalexp.codpay%type;
    v_codpay2   tlegalexp.codpay%type;
    v_compny    varchar2(500 char);
--<<user46 17/12/2021 NXP-HR2101
    v_sum_amtded      number := 0;
    v_sum_amtded_oth  number := 0;
    v_income1         varchar2(1);
    v_income1_desc    varchar2(255);
    v_income1_amtded  number;
    v_income1_deci    varchar2(100);
    v_addr_last       varchar2(4000);
    v_send_addr_label varchar2(500) := get_label_name('HRPY2KX',global_v_lang,810);
    v_company_label   varchar2(100) := get_label_name('HRPY2KX',global_v_lang,820);
    v_resource_label  varchar2(200) := get_label_name('HRPY2KX',global_v_lang,830);
    v_zipcode         tcompny.zipcode%type;
    v_banklaw         tlegalexp.banklaw%type;--<<user46 07/02/2022 NXP-HR2101
-->>user46 17/12/2021 NXP-HR2101
    v_amtded              number := 0;
    v_tcontrpy_codpay12   tcontrpy.codpaypy12%type;
    cursor c1 is
      select t1.codempid,t1.numcaselw,
             hcm_util.get_codcomp_level(t1.codcomp,1) as codcompy,
             t2.codlegald,t2.namplntiff,t2.civillaw,t2.namlegalb,sum(stddec(t1.amtded,t1.codempid,v_chken)) amtpay,
             t2.numbanklg, t2.numkeep --<< user46 NXP-HR2101 20/12/2021
        from tlegalprd t1, tlegalexe t2
       where t1.codempid = t2.codempid
         and t1.numcaselw = t2.numcaselw
         and t1.codcomp like p_codcomp||'%'
         and t1.codempid = nvl(p_codempid,t1.codempid)
         and t1.dteyrepay = p_dteyrepay
         and t1.dtemthpay = p_dtemthpay
         and t2.codlegald = nvl(p_codlegald,t2.codlegald)
    group by t1.codempid,t1.numcaselw,
             hcm_util.get_codcomp_level(t1.codcomp,1),
             t2.codlegald,t2.namplntiff,t2.civillaw,t2.namlegalb,t2.numbanklg, t2.numkeep
    order by codempid;

    cursor c_codpay is
      select codpay,sum(stddec(amtpay,codempid,v_chken)) amtpay--stdenc
        from tlegalexp
       where codempid = v_codempid
         and numcaselw = v_numcaselw
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and codpay in (v_codpay1,v_codpay2)
      group by codpay
      order by codpay;

    cursor c_codpayoth is
      select codpay,sum(stddec(amtpay,codempid,v_chken)) amtpay
        from tlegalexp
       where codempid = v_codempid
         and numcaselw = v_numcaselw
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and codpay not in (nvl(p_codpay1,'!@#$'),nvl(p_codpay2,'!@#$'),nvl(p_codpay3,'!@#$'),nvl(p_codpay4,'!@#$'),
                            nvl(p_codpay5,'!@#$'),nvl(p_codpay6,'!@#$'),nvl(p_codpay7,'!@#$'),nvl(p_codpay8,'!@#$'),
                            nvl(p_codpay9,'!@#$'),nvl(p_codpay10,'!@#$'),nvl(p_codpay11,'!@#$'),nvl(p_codpay12,'!@#$'))
      group by codpay
      order by codpay;
  begin
    delete ttemprpt where codempid = global_v_codempid and codapp = 'HRPY2KX';
    if p_codpay1 is not null then
      v_rec1      := get_tinexinf_name(p_codpay1,global_v_lang);
    end if;
    if p_codpay2 is not null then
      v_rec1      := v_rec1||','||get_tinexinf_name(p_codpay2,global_v_lang);
    end if;

    if p_codpay3 is not null then
      v_rec2      := get_tinexinf_name(p_codpay3,global_v_lang);
    end if;
    if p_codpay4 is not null then
      v_rec2      := v_rec2||','||get_tinexinf_name(p_codpay4,global_v_lang);
    end if;

    if p_codpay5 is not null then
      v_rec3      := get_tinexinf_name(p_codpay5,global_v_lang);
    end if;
    if p_codpay6 is not null then
      v_rec3      := v_rec3||','||get_tinexinf_name(p_codpay6,global_v_lang);
    end if;

    if p_codpay7 is not null then
      v_rec4      := get_tinexinf_name(p_codpay7,global_v_lang);
    end if;
    if p_codpay8 is not null then
      v_rec4      := v_rec4||','||get_tinexinf_name(p_codpay8,global_v_lang);
    end if;

    if p_codpay9 is not null then
      v_rec5      := get_tinexinf_name(p_codpay9,global_v_lang);
    end if;
    if p_codpay10 is not null then
      v_rec5      := v_rec5||','||get_tinexinf_name(p_codpay10,global_v_lang);
    end if;

    if p_codpay11 is not null then
      v_rec6      := get_tinexinf_name(p_codpay11,global_v_lang);
    end if;
    if p_codpay12 is not null then
      v_rec6      := v_rec6||','||get_tinexinf_name(p_codpay12,global_v_lang);
    end if;
    for i in c1 loop
      v_data := 'Y';
      v_chksecur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_chksecur then
        v_secure := 'Y';
        v_numseq := v_numseq+1;

        begin
          select decode(typpaymt,'CS','1','CH','2','BK','3'), numref, to_char(dtepay, 'dd MONTH yyyy', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')--วิธีการนำส่งเงินสำนักงานบังคับคดี  GetListItem (TYPPAYMT) (CS-เงินสด,CH-เช็ค ,BK-ธนาคาร)
            into v_typpaymt,v_numref,v_dtepay
            from tlegalprd
           where codempid = i.codempid
             and numcaselw = i.numcaselw
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
             and rownum = 1;
        exception when no_data_found then
          v_typpaymt := null;
          v_numref   := null;
          v_dtepay   := null;
        end;
        begin
          select get_tcompny_name(codcompy,global_v_lang)||' '||decode(global_v_lang,'101',adrcome
                                     , '102',adrcomt
                                     , '103',adrcom3
                                     , '104',adrcom4
                                     , '105',adrcom5, adrcomt) address,numtele,get_tcompny_name(codcompy,global_v_lang),
                 zipcode
            into v_address,v_numtele,v_compny,
                 v_zipcode
            from tcompny
           where codcompy = i.codcompy;
        exception when no_data_found then
          v_address := null;
          v_numtele := null;
          v_compny  := null;
        end;
--<<user46 28/12/2021 NXP--
        begin
          select codpaypy12
            into v_tcontrpy_codpay12
            from tcontrpy
           where codcompy   = i.codcompy
             and dteeffec   = (select max(dteeffec)
                                 from tcontrpy
                                where codcompy   = i.codcompy
                                  and dteeffec   <= trunc(sysdate));
        exception when no_data_found then
          v_tcontrpy_codpay12 := '';
        end;

        begin
          select sum(stddec(amtpay,codempid,v_chken))
            into v_amtded
            from tsincexp
           where codempid   = i.codempid
             and dteyrepay  = p_dteyrepay
             and dtemthpay  = p_dtemthpay
             and codpay     = v_tcontrpy_codpay12;
        end;
        v_amtded    := greatest(nvl(v_amtded,0),0);
-->>user46 28/12/2021 NXP--
        v_codempid  := i.codempid;
        v_numcaselw := i.numcaselw;

        v_amt1      := null; v_amt2      := null; v_amt3      := null; v_amt4      := null;
        v_amt5      := null; v_amt6      := null; v_amt7      := null;
        v_chk1      := 'N';  v_chk2      := 'N';  v_chk3      := 'N';  v_chk4      := 'N';
        v_chk5      := 'N';  v_chk6      := 'N';  v_chk7      := 'N';
        v_codpay1   := p_codpay1;v_codpay2   := p_codpay2;
        for r_codpay in c_codpay loop
          v_amt1 := nvl(v_amt1,0)+nvl(r_codpay.amtpay,0);
          v_chk1 := 'Y';
        end loop;
        v_codpay1   := p_codpay3; v_codpay2   := p_codpay4;
        for r_codpay in c_codpay loop
          v_amt2 := nvl(v_amt2,0)+nvl(r_codpay.amtpay,0);
          v_chk2 := 'Y';
        end loop;
        v_codpay1   := p_codpay5; v_codpay2   := p_codpay6;
        for r_codpay in c_codpay loop
          v_amt3 := nvl(v_amt3,0)+nvl(r_codpay.amtpay,0);
          v_chk3 := 'Y';
        end loop;
        v_codpay1   := p_codpay7; v_codpay2   := p_codpay8;
        for r_codpay in c_codpay loop
          v_amt4 := nvl(v_amt4,0)+nvl(r_codpay.amtpay,0);
          v_chk4 := 'Y';
        end loop;
        v_codpay1   := p_codpay9; v_codpay2   := p_codpay10;
        for r_codpay in c_codpay loop
          v_amt5 := nvl(v_amt5,0)+nvl(r_codpay.amtpay,0);
          v_chk5 := 'Y';
        end loop;
        v_codpay1   := p_codpay11; v_codpay2   := p_codpay12;
        for r_codpay in c_codpay loop
          v_amt6 := nvl(v_amt6,0)+nvl(r_codpay.amtpay,0);
          v_chk6 := 'Y';
        end loop;
        v_rec7 := null;
        for r_codpayoth in c_codpayoth loop
          v_rec7 := v_rec7||','||get_tinexinf_name(r_codpayoth.codpay,global_v_lang);
          v_amt7 := nvl(v_amt7,0)+nvl(r_codpayoth.amtpay,0);
          v_chk7 := 'Y';
        end loop;
        v_rec7      := substr(v_rec7,2,500);
--<<user46 17/12/2021 NXP-HR2101
--<<user46 07/02/2022 NXP-HR2101
        /*begin
          select sum(stddec(amtded,codempid,v_chken))
            into v_sum_amtded
            from tlegalprd
           where codempid = i.codempid
             and numcaselw = i.numcaselw
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay;
        end;*/
        v_sum_amtded  := i.amtpay;
-->>

        begin
          select banklaw, sum(nvl(stddec(amtpay,codempid,v_chken),0))
            into v_banklaw,v_sum_amtded_oth
            from tlegalexp
           where codempid = i.codempid
             and numcaselw = i.numcaselw
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
          group by banklaw;
        exception when no_data_found then
          v_banklaw := '';
          v_sum_amtded_oth := 0;
        end;
        v_income1_amtded  := nvl(v_sum_amtded,0) - nvl(v_sum_amtded_oth,0);
        v_income1_amtded  := greatest(v_income1_amtded,0);
        if v_income1_amtded > 0 then
          v_income1 := 'Y';
        else
          v_income1 := 'N';
        end if;
        v_income1_desc    := get_label_name('HRPY2KX',global_v_lang,840);
        v_income1_deci    := lpad(round(to_char(mod(v_income1_amtded,1)*100)),2,'0');
-->>user46 17/12/2021 NXP-HR2101
        v_address := v_address||' '||v_zipcode||' โทร '||v_numtele;
        v_addr_last := replace(v_address,v_compny,v_compny||' '||v_resource_label);
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,
                              item4,item5,item6,
                              item7,item8,item9,
                              item10,item11,item12,

                              item13,item14,item15,
                              item16,item17,item18,
                              item19,item20,item21,
                              item22,item23,item24,
                              item25,item26,item27,
                              item28,item29,item30,
                              item31,item32,item33,
                              item34,item35,item36,

                              item37,item38,item39,
                              item40,item41,item42,

                              item43,item44,item45,
                              item46,item47,item48,
                              item49,item50,item51,
                              item52,item53,
                              item54,item55,item56) --<< user46 NXP-HR2101 20/12/2021
                      values (global_v_codempid,'HRPY2KX',v_numseq,
                              'DETAIL',i.codempid,i.numcaselw,
                              v_company_label||' '||v_address,get_tcodec_name('TCODLEGALD',i.codlegald,'102'),get_temploy_name(i.codempid,global_v_lang),
                              i.civillaw,i.numcaselw,to_char(sysdate, 'dd MONTH yyyy', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI'),
                              i.namplntiff,get_temploy_name(i.codempid,global_v_lang),'',

                              '',v_rec1,v_rec2,
                              v_rec3,v_rec4,v_rec5,
                              v_rec6,v_rec7,to_char(trunc(v_amt1),'fm999,999,999'),
                              lpad(round(to_char(mod(v_amt1,1)*100)),2,'0'),to_char(trunc(v_amt2),'fm999,999,999'),lpad(round(to_char(mod(v_amt2,1)*100)),2,'0'),
                              to_char(trunc(v_amt3),'fm999,999,999'),lpad(round(to_char(mod(v_amt3,1)*100)),2,'0'),to_char(trunc(v_amt4),'fm999,999,999'),
                              lpad(round(to_char(mod(v_amt4,1)*100)),2,'0'),to_char(trunc(v_amt5),'fm999,999,999'),lpad(round(to_char(mod(v_amt5,1)*100)),2,'0'),
                              to_char(trunc(v_amt6),'fm999,999,999'),lpad(round(to_char(mod(v_amt6,1)*100)),2,'0'),to_char(trunc(v_amt7),'fm999,999,999'),
                              lpad(round(to_char(mod(v_amt7,1)*100)),2,'0'),v_typpaymt,get_tcodec_name('TCODBANK',v_banklaw,global_v_lang),

--                              v_numref,v_dtepay,to_char(i.amtpay + v_income1_amtded,'fm999,999,990.00'), --<< user46 28/12/2021 NXP..
                              v_numref,v_dtepay,to_char(v_amtded,'fm999,999,990.00'),
                              i.namlegalb,v_send_addr_label||' '||v_company_label||' '||v_addr_last,v_numtele,

                              v_chk1,v_chk2,v_chk3,
                              v_chk4,v_chk5,v_chk6,
                              v_chk7,v_income1,v_income1_desc,
                              to_char(v_income1_amtded,'fm999,999,999'),v_income1_deci,
                              i.numbanklg,i.numkeep,get_tcodec_name('TCODLEGALD',i.codlegald,'101')); --<< user46 NXP-HR2101 20/12/2021
      end if;
    end loop;
    commit;
    if v_data = 'N' then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexp');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    elsif v_secure = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure get_csv(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_csv(json_str_output);
  end get_csv;

  procedure gen_csv(json_str_output out clob) is
    v_codpay1        tlegalexp.codpay%type;
    v_codpay2        tlegalexp.codpay%type;
    v_codempid       tlegalexp.codempid%type;
    v_numcaselw      tlegalexp.numcaselw%type;
    v_data           varchar2(1 char) := 'N';
    v_secure         varchar2(1 char) := 'N';
    v_chksecur       boolean;
    v_numseq         number := 0;
    v_amt1           number;
    v_amt2           number;
    v_amt3           number;
    v_amt4           number;
    v_amt5           number;
    v_amt6           number;
    v_amt1_msg       varchar2(4000 char);
    v_amt2_msg       varchar2(4000 char);
    v_amt3_msg       varchar2(4000 char);
    v_amt4_msg       varchar2(4000 char);
    v_amt5_msg       varchar2(4000 char);
    v_amt6_msg       varchar2(4000 char);
    v_salary_msg     varchar2(4000 char);
    obj_main         json_object_t;
    v_response       varchar2(4000 char);
    v_sum_all        number;
    v_sum_amtded_oth number;

    p_filename       varchar2(4000 char);
    p_file_dir       varchar2(4000 char) := 'UTL_FILE_DIR';
    p_file_path      varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
    out_file   	     UTL_FILE.File_Type;

    p_head_row       varchar2(4000 char) := '';
    p_body_row       varchar2(4000 char) := '';

    cursor c1 is
      select 	t1.numkeep, t1.numcaselw, t1.civillaw, t1.codlegald,
        t4.numcotax, t1.namplntiff , t2.numoffid ,
        t3.codtitle, t3.namfirstt, t3.namlastt, t1.codempid
       from	tlegalexe t1, temploy2 t2, temploy1 t3, tcompny t4, tlegalprd t5
      where	t1.codempid = t2.codempid and t3.codempid = t2.codempid
        and t5.codempid = t1.codempid and t5.numcaselw = t1.numcaselw
        and t1.codempid = nvl(p_codempid, t1.codempid)
        and t1.codcomp like p_codcomp || '%'
        and t1.codlegald = nvl(p_codlegald, t1.codlegald)
        and t5.dtemthpay = p_dtemthpay
        and t5.dteyrepay = p_dteyrepay
        and hcm_util.get_codcomp_level(t1.codcomp, 1) = t4.codcompy
      order by codempid;

    cursor c_codpay is
      select codpay, sum(stddec(amtpay,codempid,v_chken)) amtpay
        from tlegalexp
       where codempid = v_codempid
         and numcaselw = v_numcaselw
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and codpay in (v_codpay1, v_codpay2)
      group by codpay
      order by codpay;

    cursor c_tapplscr is
      select decode(global_v_lang, 101, desclabele, 102, desclabelt, 103, desclabel3, 104, desclabel4, 105, desclabel5) label
        from tapplscr
       where codapp = 'HRPY2KXCSV'
       order by numseq;
  begin
    p_filename := hcm_batchtask.gen_filename(lower(p_dteyrepay||'_'||lpad(p_dtemthpay, 2, 0)),'csv',sysdate);
    std_deltemp.upd_ttempfile(p_filename,'A');
    out_file 	:= UTL_FILE.Fopen(p_file_dir,p_filename,'W');

    for r_tapplscr in c_tapplscr loop
      p_head_row := p_head_row || r_tapplscr.label || ',';
    end loop;
    p_head_row := substr(p_head_row, 0, length(p_head_row) - 1);
    UTL_FILE.put_line(out_file, p_head_row);

    obj_main := json_object_t();
    for r1 in c1 loop
      v_data := 'Y';
      v_chksecur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_chksecur then
        begin
          select sum(stddec(t1.amtded,t1.codempid,v_chken))
            into v_sum_all
            from TLEGALPRD t1
          where t1.codcomp like p_codcomp||'%'
            and t1.codempid = r1.codempid
          and dteyrepay = p_dteyrepay
          and dtemthpay = p_dtemthpay;
        exception when no_data_found then
          v_sum_all := 0;
        end;

        begin
          select sum(nvl(stddec(amtpay,codempid,v_chken),0))
            into v_sum_amtded_oth
            from tlegalexp
           where codempid = r1.codempid
             and numcaselw = r1.numcaselw
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
          group by banklaw;
        exception when no_data_found then
          v_sum_amtded_oth := 0;
        end;
        v_sum_all  := nvl(v_sum_all, 0) - nvl(v_sum_amtded_oth ,0);
        v_sum_all  := greatest(v_sum_all, 0);

        v_salary_msg := 'ไม่อายัด';
        if v_sum_all > 0 THEN
          v_salary_msg := 'อายัด';
        end if;

        v_secure    := 'Y';
        p_body_row  := r1.numkeep||','||
                       r1.numcaselw||','||
                       r1.civillaw||','||
                       get_tcodec_name('tcodlegald', r1.codlegald, '102')||','||
                       '@@@'||r1.numcotax||','||
                       r1.namplntiff ||','||
                       '@@@'||r1.numoffid ||','||
                       (get_tlistval_name('CODTITLE', r1.codtitle, '102'))||','||
                       r1.namfirstt||','||
                       r1.namlastt||','||
                       v_salary_msg||','||
                       v_sum_all||',';
        v_numseq    := v_numseq + 1;
        v_codempid  := r1.codempid;
        v_numcaselw := r1.numcaselw;
        v_codpay1   := p_codpay1; v_codpay2   := p_codpay2;
        for r_codpay in c_codpay loop
          v_amt1 := nvl(v_amt1,0)+nvl(r_codpay.amtpay,0);
        end loop;
        v_codpay1   := p_codpay3; v_codpay2   := p_codpay4;
        for r_codpay in c_codpay loop
          v_amt2 := nvl(v_amt2,0)+nvl(r_codpay.amtpay,0);
        end loop;
        v_codpay1   := p_codpay5; v_codpay2   := p_codpay6;
        for r_codpay in c_codpay loop
          v_amt3 := nvl(v_amt3,0)+nvl(r_codpay.amtpay,0);
        end loop;
        v_codpay1   := p_codpay7; v_codpay2   := p_codpay8;
        for r_codpay in c_codpay loop
          v_amt4 := nvl(v_amt4,0)+nvl(r_codpay.amtpay,0);
        end loop;
        v_codpay1   := p_codpay9; v_codpay2   := p_codpay10;
        for r_codpay in c_codpay loop
          v_amt5 := nvl(v_amt5,0)+nvl(r_codpay.amtpay,0);
        end loop;
        v_codpay1   := p_codpay11; v_codpay2   := p_codpay12;
        for r_codpay in c_codpay loop
          v_amt6 := nvl(v_amt6,0)+nvl(r_codpay.amtpay,0);
        end loop;

        v_amt1_msg := 'ไม่อายัด';
        v_amt2_msg := 'ไม่อายัด';
        v_amt3_msg := 'ไม่อายัด';
        v_amt4_msg := 'ไม่อายัด';
        v_amt5_msg := 'ไม่อายัด';
        v_amt6_msg := 'ไม่อายัด';

        if v_amt1 <> 0 then
          v_amt1_msg := 'อายัด';
        end if;
        if v_amt2 <> 0 then
          v_amt2_msg := 'อายัด';
        end if;
        if v_amt3 <> 0 then
          v_amt3_msg := 'อายัด';
        end if;
        if v_amt4 <> 0 then
          v_amt4_msg := 'อายัด';
        end if;
        if v_amt5 <> 0 then
          v_amt5_msg := 'อายัด';
        end if;
        if v_amt6 <> 0 then
          v_amt6_msg := 'อายัด';
        end if;
        p_body_row := p_body_row||v_amt1_msg||','||nvl(v_amt1, 0)||','||
                      v_amt2_msg||','||nvl(v_amt2, 0)||','||
                      v_amt3_msg||','||nvl(v_amt3, 0)||','||
                      v_amt4_msg||','||nvl(v_amt4, 0)||','||
                      v_amt5_msg||','||nvl(v_amt5, 0)||','||
                      v_amt6_msg||','||nvl(v_amt6, 0)||',';
        UTL_FILE.put_line(out_file, p_body_row);
      end if;
    end loop;
    UTL_FILE.FClose(out_file);
    param_msg_error   := get_error_msg_php('HR2715',global_v_lang);
    v_response        := get_response_message(null,param_msg_error,global_v_lang);
    obj_main.put('coderror', '200');
    obj_main.put('message', p_file_path || p_filename);
    obj_main.put('message', p_file_path || p_filename);
    obj_main.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexp');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    elsif v_secure = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    else
      json_str_output := obj_main.to_clob;
    end if;
  end gen_csv;

end HRPY2KX;

/
