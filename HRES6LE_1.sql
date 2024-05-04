--------------------------------------------------------
--  DDL for Package Body HRES6LE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES6LE" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  PROCEDURE cal_dhm
    (p_qtyday		in  number,
     p_day			out number,
     p_hour			out number,
     p_min			out number)
  IS
    v_min 	number(2) := 0;
    v_hour  number(2) := 0;
    v_day   number := 0;
    v_num   number := 0;
  begin
    if nvl(p_qtyday,0) > 0 then
      v_day		:= trunc(p_qtyday / 1);
      v_num 	:= round(mod((p_qtyday * p_qtyavgwk),p_qtyavgwk),0);
      v_hour	:= trunc(v_num / 60);
      v_min		:= mod(v_num,60);
    end if;
    p_day := v_day; p_hour := v_hour; p_min := v_min;
  end;

  PROCEDURE gen_income(p_codempid varchar2) IS
    v_amthour		        number;

    v_amtmonth	        number;
    v_amtincom1         temploy3.amtincom1%type;
    v_amtincom2         temploy3.amtincom2%type;
    v_amtincom3         temploy3.amtincom3%type;
    v_amtincom4         temploy3.amtincom4%type;
    v_amtincom5         temploy3.amtincom5%type;
    v_amtincom6         temploy3.amtincom6%type;
    v_amtincom7         temploy3.amtincom7%type;
    v_amtincom8         temploy3.amtincom8%type;
    v_amtincom9         temploy3.amtincom9%type;
    v_amtincom10        temploy3.amtincom10%type;
    v_codcurr           temploy3.codcurr%type;
    v_codcomp           temploy1.codcomp%type;
    v_codempmt          temploy1.codempmt%type;
    v_typpayroll        temploy1.typpayroll%type;
  begin
    begin
      select codcurr,a.codcomp,codempmt,typpayroll,
             stddec(amtincom1,b.codempid,global_v_chken),
             stddec(amtincom2,b.codempid,global_v_chken),
             stddec(amtincom3,b.codempid,global_v_chken),
             stddec(amtincom4,b.codempid,global_v_chken),
             stddec(amtincom5,b.codempid,global_v_chken),
             stddec(amtincom6,b.codempid,global_v_chken),
             stddec(amtincom7,b.codempid,global_v_chken),
             stddec(amtincom8,b.codempid,global_v_chken),
             stddec(amtincom9,b.codempid,global_v_chken),
             stddec(amtincom10,b.codempid,global_v_chken)
        into v_codcurr,v_codcomp,v_codempmt,v_typpayroll,
             v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
             v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
        from temploy1 a,temploy3 b
       where a.codempid = p_codempid
         and a.codempid = b.codempid;
    exception when no_data_found then null;
    end;

    get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1),v_codempmt,
                    nvl(v_amtincom1,0),nvl(v_amtincom2,0),nvl(v_amtincom3,0),nvl(v_amtincom4,0),nvl(v_amtincom5,0),
                    nvl(v_amtincom6,0),nvl(v_amtincom7,0),nvl(v_amtincom8,0), nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                    v_amthour,v_amtday,v_amtmonth);

  END;
  --
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    varchar2(1);
    v_codcomp1  varchar2(4);
    v_secur			boolean;
  begin
    ------------------------------------------------------
    if p_codempid_query is null and global_v_codempid is null then--User37 #5522 Final Test Phase 1 V11 26/03/2021 if p_codempid_query is null then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
--    elsif p_dtereq is null then
--      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
--      return;
    end if;
    ------------------------------------------------------
    begin
      select staemp,hcm_util.get_codcomp_level(codcomp,1) into v_staemp,v_codcomp1
        from temploy1
       where codempid = nvl(p_codempid_query,global_v_codempid);--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
    end;

    if v_staemp = '0' then
      param_msg_error   := get_error_msg_php('HR2102',global_v_lang);
      return;
    end if;

/* --#7491 || 09/05/2022
    if p_codempid_query is not null and p_codempid_query <> global_v_codempid then
        v_secur := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
        if not v_secur then
          param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
          return;
        end if;
    end if;
*/

    ------------------------------------------------------
    begin
      select qtyavgwk into p_qtyavgwk
        from tcontral
       where codcompy	= v_codcomp1
         and dteeffec	= ( select max(dteeffec)
                            from tcontral
                           where codcompy	= v_codcomp1
                             and dteeffec <= sysdate);
    exception when no_data_found then
      p_qtyavgwk        := 0;
      param_msg_error   := get_error_msg_php('AL0012',global_v_lang,'TCONTRAL');
    end;
    gen_income(p_codempid_query);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;

  	v_codleave 			varchar2(10);
    v_dteeffec 			date;
    v_qtydayle_req  number;
    v_day		      	number;
    c_amtday        number;
    c_amtlepay      number;
    v_secur			    boolean;
    v_zupdsal       varchar2(4);
    v_qtylepay      number;

    t_tpayvac       tpayvac%rowtype;

    arr_day         t_arr_number;
    arr_hour        t_arr_number;
    arr_min         t_arr_number;

    v_emp_amtday    temploy3.amtday%type;
    v_codcomp       temploy1.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');

    for i in 1..8 loop
      arr_day(i)  := null;
      arr_hour(i) := null;
      arr_min(i)  := null;
    end loop;

    begin
      select *
        into t_tpayvac
        from tpayvac
       where codempid   = nvl(p_codempid_query,global_v_codempid)--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query
         and dteyear    = p_dteyear
         and dtereq     = p_dtereq
         and flgreq     = 'E';
    exception when no_data_found then
      t_tpayvac.codempid    := null;
    end;

    obj_data.put('codempid',nvl(p_codempid_query,global_v_codempid));--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query);
    obj_data.put('dteyear',p_dteyear);
    obj_data.put('dtereq',to_char(p_dtereq,'dd/mm/yyyy'));
    obj_data.put('flgreq',t_tpayvac.flgreq);
    obj_data.put('codcomp',t_tpayvac.codcomp);
    obj_data.put('typpayroll',t_tpayvac.typpayroll);
    obj_data.put('staappr',t_tpayvac.staappr);
    obj_data.put('flgcalvac',t_tpayvac.flgcalvac);
    obj_data.put('qtypriyr',t_tpayvac.qtypriyr);
    obj_data.put('qtyvacat',t_tpayvac.qtyvacat);
    obj_data.put('qtydayle',t_tpayvac.qtydayle);
    obj_data.put('qtylepay',t_tpayvac.qtylepay);
    obj_data.put('dteupd',to_char(t_tpayvac.dteupd,'dd/mm/yyyy hh24:mi:ss'));
    obj_data.put('desc_coduser',get_temploy_name(get_codempid(t_tpayvac.coduser),global_v_lang));

    c_amtday    := stddec(t_tpayvac.amtday,t_tpayvac.codempid,global_v_chken);
    c_amtlepay  := stddec(t_tpayvac.amtlepay,t_tpayvac.codempid,global_v_chken);
    v_secur     := secur_main.secur2(t_tpayvac.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

    if v_zupdsal = 'Y' then
      obj_data.put('v_amtday',v_amtday);
      obj_data.put('v_amtlepay',c_amtlepay);
    end if;

    obj_data.put('desc_codreq',get_temploy_name(t_tpayvac.codreq,global_v_lang));
    if (t_tpayvac.codempid is null) or (t_tpayvac.codempid is not null and t_tpayvac.staappr = 'P') then
      begin
        select codleave	into v_codleave
          from tleavecd
         where staleave = 'V'
           and rownum   = 1;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TLEAVECD');
        return;
      end;
      std_al.entitlement(p_codempid_query,v_codleave,sysdate,global_v_zyear,t_tpayvac.qtyvacat,t_tpayvac.qtypriyr,v_dteeffec);
      begin
        select nvl(qtydayle,0),
               nvl(qtyvacat,0),nvl(qtypriyr,0)--User37 #5522 Final Test Phase 1 V11 26/03/2021
          into t_tpayvac.qtydayle,
               t_tpayvac.qtyvacat,t_tpayvac.qtypriyr--User37 #5522 Final Test Phase 1 V11 26/03/2021
          from tleavsum
         where codempid = nvl(p_codempid_query,global_v_codempid)--User37 #5522 Final Test Phase 1 V11 26/03/2021 --p_codempid_query
           and dteyear  = (p_dteyear - global_v_zyear)
           and codleave = v_codleave
           and trunc(sysdate) >= nvl(dteeffeclv,trunc(sysdate));-- user22 : 20/09/2021 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/12 ||
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('AL0013',global_v_lang,'TLEAVSUM');
        return;
      end;
      obj_data.put('qtypriyr',t_tpayvac.qtypriyr);
      obj_data.put('qtydayle',t_tpayvac.qtydayle);
      obj_data.put('qtyvacat',t_tpayvac.qtyvacat);
    end if;
    begin
      select nvl(sum(qtylepay),0) into v_qtylepay
        from tpayvac
       where codempid	 = nvl(p_codempid_query,global_v_codempid)--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query
         and dteyear   = (p_dteyear - global_v_zyear)
         and dtereq    <> p_dtereq
         and staappr	 = 'Y';
    end;
    begin
      select nvl(sum(qtylepay),0) into v_qtydayle_req
        from tpayvac
       where codempid	 = nvl(p_codempid_query,global_v_codempid)--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query
         and dteyear   = (p_dteyear - global_v_zyear)
         and dtereq    <> p_dtereq
         and staappr	 = 'P';
    end;
    --
    cal_dhm(t_tpayvac.qtypriyr,arr_day(1),arr_hour(1),arr_min(1));
    if (t_tpayvac.codempid is null) or (t_tpayvac.codempid is not null and t_tpayvac.staappr = 'P') then--if :tpayvac.staappr = 'P' then
      v_day := (t_tpayvac.qtyvacat - t_tpayvac.qtypriyr) + v_qtylepay;
    else
      v_day := (t_tpayvac.qtyvacat - t_tpayvac.qtypriyr);
    end if;
    cal_dhm(v_day,arr_day(2),arr_hour(2),arr_min(2));
    cal_dhm((t_tpayvac.qtyvacat + v_qtylepay),arr_day(3),arr_hour(3),arr_min(3));
    cal_dhm(t_tpayvac.qtydayle,arr_day(4),arr_hour(4),arr_min(4));
    cal_dhm(v_qtylepay,arr_day(5),arr_hour(5),arr_min(5));
    cal_dhm(v_qtydayle_req,arr_day(8),arr_hour(8),arr_min(8));
    v_day := (t_tpayvac.qtyvacat - t_tpayvac.qtydayle) - v_qtydayle_req;
    cal_dhm(v_day,arr_day(6),arr_hour(6),arr_min(6));
    cal_dhm(t_tpayvac.qtylepay,arr_day(7),arr_hour(7),arr_min(7));
    --
    for i in 1..8 loop
      obj_data.put('day'||i,arr_day(i));
      obj_data.put('hour'||i,arr_hour(i));
      obj_data.put('min'||i,arr_min(i));
    end loop;
    --
    if (t_tpayvac.codempid is null) or (t_tpayvac.codempid is not null and t_tpayvac.staappr = 'P') then
      begin
        select em3.amtday,em1.codcomp,em1.typpayroll
          into v_emp_amtday,v_codcomp,v_typpayroll
          from temploy1 em1, temploy3 em3
         where em1.codempid   = em3.codempid
           and em3.codempid   = nvl(p_codempid_query,global_v_codempid);--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query;
      exception when no_data_found then
        null;
      end;
      --<<User37 #5522 Final Test Phase 1 V11 26/03/2021
      c_amtday	  := stddec(v_emp_amtday,nvl(p_codempid_query,global_v_codempid),global_v_chken);
      --c_amtday	  := stddec(v_emp_amtday,p_codempid_query,global_v_chken);
      -->>User37 #5522 Final Test Phase 1 V11 26/03/2021

      if global_v_zupdsal   = 'Y' then
        obj_data.put('v_amtday',v_amtday);
      end if;
      obj_data.put('codcomp',v_codcomp);
      obj_data.put('typpayroll',v_typpayroll);
    end if;
    --
    if t_tpayvac.staappr <> 'P' then
      param_msg_error   := get_error_msg_php('HR8014',global_v_lang);
      return;
    end if;

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(t_tpayvac  in out tpayvac%rowtype,
                       p_day      t_arr_number,
                       p_hour     t_arr_number,
                       p_min      t_arr_number,
--                       p_amtlepay number,
                       c_amtday   number,
                       c_amtlepay number) is
    v_ok 			  boolean;
    v_secur		  boolean;
    v_staemp	  varchar2(1);
    v_zupdsal   varchar2(4);
    v_minremain number;
    v_minlepay  number;
  begin
    --<<User37 #5522 Final Test Phase 1 V11 26/03/2021
    --gen_income(p_codempid_query);
    gen_income(nvl(p_codempid_query,global_v_codempid));
    -->>User37 #5522 Final Test Phase 1 V11 26/03/2021
    if nvl(p_qtyavgwk,0) > 0 then
      t_tpayvac.qtylepay := nvl(p_day(7),0) + (((nvl(p_hour(7),0) * 60) + nvl(p_min(7),0)) / p_qtyavgwk);
    end if;

    if nvl(c_amtlepay,0) = 0 then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    v_minremain   := (nvl(p_day(6),0) * p_qtyavgwk) + (nvl(p_hour(6),0) * 60) + nvl(p_min(6),0);
    v_minlepay    := (nvl(p_day(7),0) * p_qtyavgwk) + (nvl(p_hour(7),0) * 60) + nvl(p_min(7),0);

    if nvl(v_minremain,0) - nvl(v_minlepay,0) < 0 then
      param_msg_error   := get_error_msg_php('AL0054',global_v_lang);
      return;
    end if;

    if t_tpayvac.codreq is null then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    begin
      select staemp into v_staemp
        from temploy1
       where codempid = t_tpayvac.codreq;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;

    if v_staemp = '9' then
      param_msg_error   := get_error_msg_php('HR2101',global_v_lang);
      return;
    end if;

/* --#7491 || 09/05/2022
    v_secur   := secur_main.secur2(t_tpayvac.codreq,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if not v_secur then
      param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
*/    
  end;
  --
  procedure save_tpayvac(t_tpayvac tpayvac%rowtype) is
  begin
    begin
      insert into tpayvac(codempid,dteyear,dtereq,flgreq,codcomp,
                          typpayroll,qtypriyr,qtyvacat,qtydayle,qtylepay,
                          amtday,amtlepay,flgcalvac,staappr,remarkap,
                          codreq,codcreate,coduser)
                  values (t_tpayvac.codempid,t_tpayvac.dteyear,t_tpayvac.dtereq,t_tpayvac.flgreq,t_tpayvac.codcomp,
                          t_tpayvac.typpayroll,t_tpayvac.qtypriyr,t_tpayvac.qtyvacat,t_tpayvac.qtydayle,t_tpayvac.qtylepay,
                          t_tpayvac.amtday,t_tpayvac.amtlepay,t_tpayvac.flgcalvac,t_tpayvac.staappr,t_tpayvac.remarkap,
                          t_tpayvac.codreq,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tpayvac
         set codcomp    = t_tpayvac.codcomp,
             typpayroll = t_tpayvac.typpayroll,
             qtypriyr   = t_tpayvac.qtypriyr,
             qtyvacat   = t_tpayvac.qtyvacat,
             qtydayle   = t_tpayvac.qtydayle,
             qtylepay   = t_tpayvac.qtylepay,
             amtday     = t_tpayvac.amtday,
             amtlepay   = t_tpayvac.amtlepay,
             flgcalvac  = t_tpayvac.flgcalvac,
             staappr    = t_tpayvac.staappr,
             codreq     = t_tpayvac.codreq,
             coduser    = global_v_coduser
       where codempid   = t_tpayvac.codempid
         and dteyear    = t_tpayvac.dteyear
         and dtereq     = t_tpayvac.dtereq
         and codcomp    = t_tpayvac.codcomp;
    end;
  end;
  procedure save_detail(json_str_input in clob,json_str_output out clob) is
    v_json_input  json_object_t := json_object_t(json_str_input);
    t_tpayvac     tpayvac%rowtype;
    v_emp_amtday  temploy3.amtday%type;
    c_amtday      number;
    c_amtlepay    number;
    v_amtlepay    number;
    v_codcomp1    tcenter.codcompy%type;

    arr_day       t_arr_number;
    arr_hour      t_arr_number;
    arr_min       t_arr_number;
  begin
    initial_value(json_str_input);
    t_tpayvac.codempid		:= nvl(hcm_util.get_string_t(v_json_input,'p_codempid_query'),global_v_codempid);--User37 #5522 Final Test Phase 1 V11 26/03/2021 hcm_util.get_string_t(v_json_input,'p_codempid_query');
    t_tpayvac.dteyear		  := hcm_util.get_string_t(v_json_input,'dteyear');
    t_tpayvac.dtereq			:= to_date(hcm_util.get_string_t(v_json_input,'dtereq'),'dd/mm/yyyy');
    t_tpayvac.codreq      := global_v_codempid;
    t_tpayvac.flgreq			:= 'E';
    t_tpayvac.codcomp		  := hcm_util.get_string_t(v_json_input,'codcomp');
    t_tpayvac.typpayroll	:= hcm_util.get_string_t(v_json_input,'typpayroll');
    t_tpayvac.flgcalvac   := nvl(hcm_util.get_string_t(v_json_input,'flgcalvac'),'N');
    t_tpayvac.staappr     := nvl(hcm_util.get_string_t(v_json_input,'staappr'),'P');
    t_tpayvac.qtypriyr    := hcm_util.get_string_t(v_json_input,'qtypriyr');
    t_tpayvac.qtyvacat    := hcm_util.get_string_t(v_json_input,'qtyvacat');
    t_tpayvac.qtydayle    := hcm_util.get_string_t(v_json_input,'qtydayle');
    t_tpayvac.qtylepay    := hcm_util.get_string_t(v_json_input,'qtylepay');

    begin
      select hcm_util.get_codcomp_level(codcomp,1) into v_codcomp1
        from temploy1
       where codempid = nvl(p_codempid_query,global_v_codempid);--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
      --<<User37 #5522 Final Test Phase 1 V11 26/03/2021
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
      -->>User37 #5522 Final Test Phase 1 V11 26/03/2021
    end;
    --
    begin
      select qtyavgwk into p_qtyavgwk
        from tcontral
       where codcompy	= v_codcomp1
         and dteeffec	= ( select max(dteeffec)
                            from tcontral
                           where codcompy	= v_codcomp1
                             and dteeffec <= sysdate);
    exception when no_data_found then
      p_qtyavgwk        := null;--User37 #5522 Final Test Phase 1 V11 26/03/2021 0;
      param_msg_error   := get_error_msg_php('AL0012',global_v_lang,'TCONTRAL');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);--User37 #5522 Final Test Phase 1 V11 26/03/2021
      return;--User37 #5522 Final Test Phase 1 V11 26/03/2021
    end;
    --
    for i in 1..8 loop
      arr_day(i)    := hcm_util.get_string_t(v_json_input,'day'||i);
      arr_hour(i)   := hcm_util.get_string_t(v_json_input,'hour'||i);
      arr_min(i)    := hcm_util.get_string_t(v_json_input,'min'||i);
    end loop;

    begin
      select stddec(amtday,t_tpayvac.codempid,global_v_chken),
             stddec(amtlepay,t_tpayvac.codempid,global_v_chken)
        into c_amtday,c_amtlepay
        from tpayvac
       where codempid   = nvl(p_codempid_query,global_v_codempid)--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query;p_codempid_query
         and dteyear    = p_dteyear
         and dtereq     = p_dtereq
         and flgreq     = 'E';
    exception when no_data_found then null; end;

    if t_tpayvac.staappr = 'P' then
      begin
        select stddec(amtday,t_tpayvac.codempid,global_v_chken)
          into c_amtday
          from temploy3
         where codempid   = nvl(p_codempid_query,global_v_codempid);--User37 #5522 Final Test Phase 1 V11 26/03/2021 p_codempid_query;p_codempid_query;
      exception when no_data_found then null; end;
    end if;
    t_tpayvac.qtylepay   := nvl(arr_day(7),0) + (((nvl(arr_hour(7),0) * 60) + nvl(arr_min(7),0)) / p_qtyavgwk);
    cal_dhm(t_tpayvac.qtylepay,arr_day(7),arr_hour(7),arr_min(7));
    c_amtlepay := nvl(t_tpayvac.qtylepay,0) * nvl(c_amtday,0);

    check_save(t_tpayvac, arr_day, arr_hour, arr_min, c_amtday, c_amtlepay);
    if param_msg_error is null then
      t_tpayvac.amtday    := stdenc(round(c_amtday,2),t_tpayvac.codempid,global_v_chken);
      t_tpayvac.amtlepay  := stdenc(round(c_amtlepay,2),t_tpayvac.codempid,global_v_chken);
      save_tpayvac(t_tpayvac);
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
