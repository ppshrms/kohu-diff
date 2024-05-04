--------------------------------------------------------
--  DDL for Package Body HRAL5OU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5OU" as
/* Cust-Modify: std */
-- last update: 19/01/2023 09:54
  function ddhrmi_to_dd(v_time varchar2,v_codempid varchar2) return number as
    v_qtyavgwk    number := hcm_util.get_qtyavgwk(null,v_codempid);
    v_hr          number;
    v_mi          number;
    v_day         number;
    v_token       number;
    l_input       varchar2(100 char) := replace(v_time, ':', ',');
    l_count binary_integer;
    l_array dbms_utility.lname_array;
  begin
    if v_time is null then
      return 0;
    else
      dbms_utility.comma_to_table
      ( list   => regexp_replace(l_input,'(^|,)','\1x')
      , tablen => l_count
      , tab    => l_array
      );
      v_day     := to_number(substr(l_array(1), 2));
      v_hr      := to_number(substr(l_array(2), 2));
      v_mi      := to_number(substr(l_array(3), 2));
      v_token   := 0;
      v_token   := v_token + (v_day * v_qtyavgwk);
      v_token   := v_token + (v_hr * 60);
      v_token   := v_token + v_mi;
      v_token   := v_token / v_qtyavgwk;
      return v_token;
    end if;
  exception when others then
    return 0;
  end;
  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_flgreq            := hcm_util.get_string_t(json_obj,'p_flgreq');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');

    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
    p_remarkApprove     := hcm_util.get_string_t(json_obj,'p_remarkApprove');
    p_remarkReject      := hcm_util.get_string_t(json_obj,'p_remarkReject');
    if hcm_util.get_string_t(json_obj,'param_json') is not null then
        param_json      := json_object_t(hcm_util.get_string_t(json_obj,'param_json'));
    end if;
    p_dteyear     := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    p_amtlepay    := to_number(nvl(hcm_util.get_string_t(json_obj,'p_amtlepay'),0));
    p_qtylepay    := hcm_util.get_string_t(json_obj, 'p_qtylepay');
    p_qtybalance  := hcm_util.get_string_t(json_obj, 'p_qtybalance');
    p_day         := hcm_util.get_string_t(json_obj, 'p_day');
    p_hour        := hcm_util.get_string_t(json_obj, 'p_hour');
    p_min         := hcm_util.get_string_t(json_obj, 'p_min');
    ----hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zminlvl,global_v_zwrklvl);
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;
  --
  function chk_exempt(p_codempid varchar2) return varchar2 is
    v_exempt  varchar2(1) := 'N';
  begin

    /*User37 #3039 Final Test Phase 1 V11 12/02/2021 cursor c_temploy1 is
      select a.codempid,codcomp,numlvl,typpayroll
        from temploy1 a
       where a.codcomp  like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and exists (select b.codempid
                       from tleavsum b
                      where b.codempid = a.codempid
                        and b.dteyear  = (p_dteyrepay - para_zyear)
                        and b.codleave = v_codleave)
         and exists (select b.codempid
                       from tleavsum c
                      where c.codempid = a.codempid
                        and c.dteyear  = (p_dteyrepay - para_zyear) + 1
                        and c.codleave = v_codleave)
          and not exists (select b.codempid
                            from ttexempt d
                           where d.codempid     = a.codempid
                             and (d.dteeffec-1) >= a.dteempmt
                             and d.staupd        in ('C','U'))
    order by a.codempid;*/

    begin
      select 'Y' into v_exempt
      from  temploy1 a,ttexempt b
      where a.codempid      = p_codempid
      and   a.codempid      = b.codempid
      and   (b.dteeffec-1) >= a.dteempmt
      and   b.staupd        in ('C','U')
      and   rownum          = 1;
    exception when no_data_found then
      v_exempt := 'N';
    end;
    return v_exempt;
  end;
  --
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
  end;
  --
  procedure check_index as
    v_flgsecu				boolean;
  begin
    if p_codempid is not null then
      p_codcomp := null;
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;

      v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        return;
      end if;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_flgreq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'flgreq');
        return;
    end if;
  end;
  --

  procedure gen_income(p_codempid varchar2,p_amthour out number,p_amtday out number,p_amtmonth out number) is
		v_codcomp		temploy1.codcomp%type;
		v_codempmt		temploy1.codempmt%type;
		v_codcurr		temploy3.codcurr%type;
		v_amtincom1		number;
		v_amtincom2		number;
		v_amtincom3		number;
		v_amtincom4		number;
		v_amtincom5		number;
		v_amtincom6		number;
		v_amtincom7		number;
		v_amtincom8		number;
		v_amtincom9		number;
		v_amtincom10	number;
	begin
		begin
			select a.codcomp,codempmt,stddec(amtincom1,b.codempid,global_v_chken),stddec(amtincom2,b.codempid,global_v_chken),stddec(amtincom3,b.codempid,global_v_chken),stddec(amtincom4,b.codempid,global_v_chken),stddec(amtincom5,b.codempid,global_v_chken),stddec(amtincom6,b.codempid,global_v_chken),stddec(amtincom7,b.codempid,global_v_chken),stddec(amtincom8,b.codempid,global_v_chken),stddec(amtincom9,b.codempid,global_v_chken),stddec(amtincom10,b.codempid,global_v_chken)
	 		  into v_codcomp,v_codempmt,v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
			  from temploy1 a,temploy3 b
			 where a.codempid = p_codempid
			   and a.codempid = b.codempid;
		exception when no_data_found then null;
		end;

		get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1),v_codempmt,nvl(v_amtincom1,0),nvl(v_amtincom2,0),nvl(v_amtincom3,0),nvl(v_amtincom4,0),nvl(v_amtincom5,0),nvl(v_amtincom6,0),nvl(v_amtincom7,0),nvl(v_amtincom8,0), nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                        p_amthour,p_amtday,p_amtmonth);
	end;
  --
  function cal_payvac_yearly(p_codempid	  in	varchar2,
                             p_codcomp		in	varchar2,
                             p_dtecal		  in	date,
                             p_dteyear	in	number,
                             p_coduser		in	varchar2,
                             p_numrec		  out number,
                             p_error      out varchar2,
                             p_err_table  out varchar2,
                             p_obj_rows   in json_object_t) return clob is

		v_secur				  boolean;
		v_flgreq			  varchar2(1 char) := 'Y';
		v_codcompy			temploy1.codcomp%type;
		v_typpayroll		temploy1.typpayroll%type;
		v_codleave    	tleavsum.codleave%type;
		v_dteyrepay			tpriodal.dteyrepay%type;
		v_dtemthpay			tpriodal.dtemthpay%type;
		v_numperiod			tpriodal.numperiod%type;
		v_yrecycle			number;
		v_dtecycst			date;
		v_dtecycen			date;
		v_qtypriyr			number;
		v_qtyvacat			number;
		v_qtydayle			number;
		v_qtybalance		number;
		v_qtylepay			number;
		v_qtylepay_req 	tleavsum.qtydayle%type;
    v_qtypriyr_ny   tleavsum.qtypriyr%type;
    v_numrec        number;
		v_amtlepay			number;
		v_amthour			  number;
		v_amtday			  number;
		v_amtmonth			number;
    v_qtyavgwk      number;
    v_found         varchar2(1) := 'Y';
    v_token1        number;
    v_token2        varchar2(4000 char);
    v_qtylepay_all  number;
    v_day           number;
    v_hour          number;
    v_min           number;
    v_qtylepay1     number; ----

    v_return        clob;
    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t;

    cursor c_temploy1 is
      select a.codempid,codcomp,numlvl,typpayroll,dteeffex
        from temploy1 a
       where a.codcomp  like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and chk_exempt(a.codempid) = 'N'
         and a.staemp   in ('1','3')
         and (exists (select b.codempid
                       from tleavsum b
                      where b.codempid = a.codempid
                        and b.dteyear  = (p_dteyear - para_zyear)
                        and b.codleave = v_codleave))
         /*and not exists (select c.codempid
                           from tpayvac c
                          where c.codempid = a.codempid
                            and c.dteyear  = (p_dteyear - para_zyear)
                            and c.flgreq   = v_flgreq
--                            and c.staappr  = 'P'
                            ))*/
    order by a.codempid;

    /*cursor c_tpriodal is
			select dteyrepay,dtemthpay,numperiod
				from tpriodal
			 where codcompy   = v_codcompy
				 and typpayroll = v_typpayroll
				 and codpay    in (select codvacat
				                     from tcontal2
				                    where codcompy  = v_codcompy
				                      and dteeffec  = (select max(dteeffec)
				                                         from tcontal2
				                                        where codcompy  = v_codcompy
				                                          and dteeffec <= sysdate))
				 and v_dtecycen between nvl(dtestrt,v_dtecycen) and dteend
    order by dteyrepay,dtemthpay,numperiod;*/
	begin
    p_numrec    := p_obj_rows.get_size + 1;
    obj_rows    := p_obj_rows;
    --Check Data
		begin
			select codleave	into v_codleave
			  from tleavecd
			 where staleave = 'V'
			   and rownum   = 1;
		exception when no_data_found then
      p_error := 'AL0038';
      p_err_table := null;
      param_msg_error := get_error_msg_php(p_error,global_v_lang,p_err_table);
      v_return        := get_response_message(null,param_msg_error,global_v_lang);
      return v_return;
		end;
    --
    if p_codempid is not null then
      begin
        select  'Y'
        into    v_found
        from    temploy1
        where   codempid    = p_codempid
        and     chk_exempt(codempid) = 'N';
      exception when no_data_found then
        p_error := 'HR2107';
        p_err_table := null;
        param_msg_error := get_error_msg_php(p_error,global_v_lang,p_err_table);
        v_return        := get_response_message(null,param_msg_error,global_v_lang);
        return v_return;
      end;
    end if;
    --
    v_qtyavgwk := hcm_util.get_qtyavgwk(p_codcomp,p_codempid);
    for r1 in c_temploy1 loop
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur or p_coduser = 'AUTOBATCH' then
				p_secur := true;
        v_codcompy   := hcm_util.get_codcomp_level(r1.codcomp,1);
				v_typpayroll := r1.typpayroll;
				--
		    delete tpayvac
		     where codempid = r1.codempid
		       and dteyear  = (p_dteyear - para_zyear)
		       and flgreq   = v_flgreq
		       and staappr  = 'P';
				commit;
				--
        hral82b_batch.gen_vacation(r1.codempid,r1.codcomp,sysdate,p_coduser,v_numrec);
        --
				begin
					select nvl(qtypriyr,0),nvl(qtyvacat,0),nvl(qtydayle,0)
                 ,nvl(qtylepay,0) ----
						into v_qtypriyr,v_qtyvacat,v_qtydayle
                 ,v_qtylepay1 ----
						from tleavsum
					 where codempid = r1.codempid
						 and dteyear  = (p_dteyear - para_zyear)
						 and codleave = v_codleave
             and trunc(sysdate) >= nvl(dteeffeclv,trunc(sysdate));-- user22 : 20/09/2021 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/12 ||
				exception when no_data_found then
          v_qtypriyr := 0;
          v_qtyvacat := 0;
          v_qtydayle := 0;
				end;
        --
        begin
         select nvl(qtypriyr,0) into v_qtypriyr_ny
           from tleavsum
          where codempid = r1.codempid
            and dteyear  = (p_dteyear - para_zyear) + 1
            and codleave = v_codleave;
        exception when no_data_found then
          v_qtypriyr_ny := 0;
        end;
        --
				begin
					select nvl(sum(qtylepay),0) into v_qtylepay_req
						from tpayvac
					 where codempid	 = r1.codempid
						 and dteyear   = (p_dteyear - para_zyear)
						 and staappr	 = 'P';
				end;
				v_qtylepay := (v_qtyvacat - v_qtydayle) - v_qtylepay_req - v_qtypriyr_ny
                      - v_qtylepay1 ----
                      ;
        if v_qtylepay > 0 then
					p_data := p_data + 1;
          v_yrecycle := (p_dteyear - para_zyear);
					std_al.cycle_leave2(v_codcompy,r1.codempid,v_codleave,v_yrecycle,v_dtecycst,v_dtecycen);
					/*v_dteyrepay := 0; v_dtemthpay := 0; v_numperiod := 0;
	    		for r_tpriodal in c_tpriodal loop
	    			v_dteyrepay := r_tpriodal.dteyrepay;
	    			v_dtemthpay := r_tpriodal.dtemthpay;
	    			v_numperiod := r_tpriodal.numperiod;
	    			exit;
	    		end loop;
					if v_dteyrepay > 0 then*/
						gen_income(r1.codempid,v_amthour,v_amtday,v_amtmonth);
						v_qtybalance := v_qtylepay;
						v_amtlepay   := v_qtylepay * v_amtday;
						begin
--              for r1 in c1 loop
              v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              if v_secur or p_coduser = 'AUTOBATCH' then              
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                if r1.dteeffex is not null then
                  obj_data.put('dteeffex',to_char(r1.dteeffex,'dd/mm/yyyy'));
                end if;
                obj_data.put('dteyear',p_dteyear - para_zyear);
                obj_data.put('dtereq',to_char(sysdate,'dd/mm/yyyy')); ----obj_data.put('dtereq',to_char(v_dtecycen,'dd/mm/yyyy'));
                obj_data.put('flgreq',v_flgreq);
--                if r1.numperiod is not null and r1.dtemthpay is not null and r1.dteyrepay is not null then
--                  obj_data.put('periodmthyre',to_char(r1.numperiod) || '/' ||
--                                            to_char(r1.dtemthpay) || '/' ||
--                                            to_char(r1.dteyrepay));
--                end if;
                obj_data.put('staappr','P');
                obj_data.put('desc_staappr',get_tlistval_name('ESSTAREQ','P',global_v_lang));
--                if r1.staappr = 'P' then
                /*begin
                  select codleave
                    into v_codleave
                    from tleavecd
                   where staleave = 'V'
                     and rownum = 1;
                exception when no_data_found then
                  v_codleave := null;
                end;
                begin
                  select qtyvacat,nvl(qtydayle,0)
                        ,nvl(qtylepay,0) ----
                    into v_qtyvacat,v_qtydayle
                        ,v_qtylepay1 ----
                    from tleavsum
                   where codempid = r1.codempid
                     and dteyear  = p_year
                     and codleave = v_codleave;
                exception when no_data_found then
                  v_qtyvacat := null;
                  v_qtydayle := null;
                  v_qtylepay1 := null;----
                end;*/
                hcm_util.cal_dhm_hm(v_qtyvacat,0,0,v_qtyavgwk,'1',
                                  v_token1,v_token1,v_token1,v_token2);
                obj_data.put('qtyleave',v_token2);
                /*begin
                  select nvl(sum(nvl(qtylepay,0)),0)
                    into v_qtylepay_all
                    from tpayvac
                   where codempid = r1.codempid
                     and dteyear  = (p_dteyear - para_zyear)
                     and dtereq   <> v_dtecycen
                     and staappr  = 'P';
                exception when no_data_found then
                  v_qtylepay_all := 0;
                end;*/
                hcm_util.cal_dhm_hm(v_qtylepay ----same data in above check
                /*v_qtyvacat - v_qtydayle - v_qtylepay_all
                                    - v_qtypriyr_ny ----
                                    - v_qtylepay1 ----*/
                                    ,0,0,v_qtyavgwk,'1',
                                    v_token1,v_token1,v_token1,v_token2);
                obj_data.put('qtybalance',v_token2);
--                elsif r1.staappr <> 'P' then
--                  hcm_util.cal_dhm_hm(r1.qtyvacat,0,0,v_qtyavgwk,'1',
--                                    v_token1,v_token1,v_token1,v_token2);
--                  obj_data.put('qtyleave',v_token2);
--                  hcm_util.cal_dhm_hm(r1.qtybalance,0,0,v_qtyavgwk,'1',
--                                    v_token1,v_token1,v_token1,v_token2);
--                  obj_data.put('qtybalance',v_token2);
--                end if;
                hcm_util.cal_dhm_hm(v_qtylepay,0,0,v_qtyavgwk,'1',
                                    v_day,v_hour,v_min,v_token2);
                obj_data.put('day' ,v_day);
                obj_data.put('hour',v_hour);
                obj_data.put('min' ,v_min);
                obj_data.put('qtylepay',v_token2);
                obj_data.put('amtlepay',to_char(v_amtlepay,'fm999999999990.00'));
                obj_data.put('amtday',v_amtday);
                obj_data.put('amthour',v_amthour);
                if v_zupdsal = 'Y' then                 
                  obj_data.put('desc_amtlepay',to_char(v_amtlepay,'fm999999999990.00'));
                  obj_data.put('flgdisplay','Y');
                else
                  obj_data.put('desc_amtlepay','');
                  obj_data.put('flgdisplay','N');
                end if;
                obj_data.put('coderror','200');
                obj_rows.put(to_char(p_numrec),obj_data);
                p_numrec := p_numrec + 1;
              end if;
--              end loop;
--							insert into tpayvac(codempid,dteyear,dtereq,flgreq,
--																	codcomp,typpayroll,
--																	qtypriyr,qtyvacat,qtydayle,qtybalance,qtylepay,amtday,amtlepay,
--																	dteyrepay,dtemthpay,numperiod,flgcalvac,dteappr,codappr,staappr,remarkap,codreq,
--																	dtecreate,codcreate,dteupd,coduser)
--													 values(r1.codempid,(p_dteyear - para_zyear),v_dtecycen,v_flgreq,
--																	r1.codcomp,r1.typpayroll,
--																	v_qtypriyr,v_qtyvacat,v_qtydayle,v_qtybalance,v_qtylepay,nvl(stdenc(round(v_amtday,2),r1.codempid,global_v_chken),0),nvl(stdenc(round(v_amtlepay,2),r1.codempid,global_v_chken),0),
--																	null,null,null,'N',null,null,'P',null,get_codempid(p_coduser),
--																	sysdate,p_coduser,sysdate,p_coduser);
--            	p_numrec := p_numrec + 1;
            exception when dup_val_on_index then null;
						end;
					--end if; -- v_dteyrepay > 0
				end if; -- v_qtylepay > 0
			end if; -- v_secur or p_coduser = 'AUTOBATCH'
    end loop; -- c_temploy1
    return obj_rows.to_clob;
--    commit;
  end;
  --
  function cal_payvac_resign(p_codempid	    in	varchar2,
                             p_codcomp		  in	varchar2,
                             p_dtecal		    in	date,
                             p_dtestrt	    in	date,
                             p_dteend	      in	date,
                             p_coduser		  in	varchar2,
                             p_numrec		    out number,
                             p_error        out varchar2,
                             p_err_table    out varchar2,
                             p_obj_rows     in json_object_t) return clob is

		v_secur					boolean;
		v_flgreq				varchar2(1 char) := 'R';
		v_codempid			temploy1.codempid%type;
		v_codcompy			temploy1.codcomp%type;
		v_typpayroll		temploy1.typpayroll%type;
		v_dteeffex			temploy1.dteeffex%type;
		v_codleave    	tleavsum.codleave%type;
		v_dteyear				tleavsum.dteyear%type;
		v_dteyrepay			tpriodal.dteyrepay%type;
		v_dtemthpay			tpriodal.dtemthpay%type;
		v_numperiod			tpriodal.numperiod%type;
		v_qtypriyr			number;
		v_qtyvacat			number;
		v_qtydayle			number;
		v_qtybalance		number;
		v_qtylepay			number;
		v_qtylepay_req 	tleavsum.qtydayle%type;
		v_amtlepay			number;
		v_amthour				number;
		v_amtday				number;
		v_amtmonth			number;
    v_found         varchar2(1) := 'Y';
    v_return        clob;
    v_qtyavgwk      number;
    v_token1        number;
    v_token2        varchar2(4000 char);
    v_qtylepay_all  number;
    v_day           number;
    v_hour          number;
    v_min           number;
    v_qtylepay1     number;

    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t;

    cursor c_temploy1 is
      select a.codempid,a.codcomp,a.numlvl,e.typpayroll,a.dteeffec as dteeffex
        from ttexempt a, temploy1 e
       where a.codempid   = e.codempid
         and a.dteeffec   between p_dtestrt and p_dteend
         and a.codempid   = nvl(p_codempid,a.codempid)
         and a.codcomp    like p_codcomp||'%'
         and a.staupd     in ('C','U')
         and (exists (select b.codempid
                       from tleavsum b
                      where b.codempid = a.codempid
                        and b.codleave = v_codleave))
         /*and  not exists (select c.codempid
                            from tpayvac c
                           where c.codempid = a.codempid
                             and c.flgreq   = v_flgreq
--                             and c.staappr  = 'P'
                          ))*/
    order by a.codempid;

    /*cursor c_tpriodal is
			select dteyrepay,dtemthpay,numperiod
				from tpriodal
			 where codcompy   = v_codcompy
				 and typpayroll = v_typpayroll
				 and codpay    in (select codvacat
				                     from tcontal2
				                    where codcompy  = v_codcompy
				                      and dteeffec  = (select max(dteeffec)
				                                         from tcontal2
				                                        where codcompy  = v_codcompy
				                                          and dteeffec <= sysdate))
				 and (v_dteeffex-1) between nvl(dtestrt,(v_dteeffex-1)) and dteend
    order by dteyrepay,dtemthpay,numperiod;*/
	begin
    p_numrec    := p_obj_rows.get_size + 1;
    obj_rows    := p_obj_rows;
    --Check Data
		begin
			select codleave	into v_codleave
			  from tleavecd
			 where staleave = 'V'
			   and rownum   = 1;
		exception when no_data_found then
      p_error := 'AL0038';
      p_err_table := null;
      param_msg_error := get_error_msg_php(p_error,global_v_lang,p_err_table);
      v_return        := get_response_message(null,param_msg_error,global_v_lang);
      return v_return;
		end;
    --
    if p_codempid is not null then
      begin
        select 'Y'
          into v_found
          from temploy1
         where codempid = p_codempid
           and (staemp  = '9'
            or chk_exempt(codempid) = 'Y');
      exception when no_data_found then
        p_error := 'HR2107';
        p_err_table := null;
        param_msg_error := get_error_msg_php(p_error,global_v_lang,p_err_table);
        v_return        := get_response_message(null,param_msg_error,global_v_lang);
        return v_return;
      end;
    end if;
    --
/*		begin
			select a.codempid	into v_codempid
			  from temploy1 a
       where a.codcomp  like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and chk_exempt(a.codempid) = 'Y'
         and exists (select b.dteyrepay
                       from tpriodal b
                      where b.codcompy   = hcm_util.get_codcomp_level(a.codcomp,1)
                        and b.typpayroll = a.typpayroll
                        and b.dteyrepay  =(p_dteyrepay - para_zyear)
                        and b.dtemthpay  = p_dtemthpay
                        and b.numperiod  = p_numperiod
                        and(a.dteeffex-1) between nvl(dtestrt,(a.dteeffex-1)) and dteend
                        and b.codpay    in (select c.codvacat
												                      from tcontal2 c
												                     where c.codcompy  = b.codcompy
												                       and dteeffec  = (select max(dteeffec)
												                                         from tcontal2
												                                        where codcompy  = b.codcompy
												                                          and dteeffec <= sysdate)))
			   and rownum   = 1;
		exception when no_data_found then
      p_error := 'HR2055';
      p_err_table := 'tpriodal';
      return;
		end;*/
    --
    v_qtyavgwk := hcm_util.get_qtyavgwk(p_codcomp,p_codempid);
    for r1 in c_temploy1 loop
      p_data := p_data + 1;    
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur or p_coduser = 'AUTOBATCH' then        
				p_secur := true;
        v_codcompy   := hcm_util.get_codcomp_level(r1.codcomp,1);
--				v_typpayroll := r1.typpayroll;
				v_dteeffex   := r1.dteeffex;
				--
				begin
					select dteyear,nvl(qtypriyr,0),nvl(qtyvacat,0),nvl(qtydayle,0)
                 ,nvl(qtylepay,0)
                 ,dteyear
						into v_dteyear,v_qtypriyr,v_qtyvacat,v_qtydayle
                 ,v_qtylepay1 ----
                 ,p_year--User37 #3039 Final Test Phase 1 V11 12/02/2021
						from tleavsum
					 where codempid = r1.codempid
						 and codleave = v_codleave
						 and dteyear  = (select max(dteyear)
						                   from tleavsum
															where codempid = r1.codempid
															  and codleave = v_codleave)
             and trunc(sysdate) >= nvl(dteeffeclv,trunc(sysdate));-- user22 : 20/09/2021 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/12 ||
				exception when no_data_found then null;
				end;
		    delete tpayvac
		     where codempid = r1.codempid
		       and dteyear  = v_dteyear
		       and flgreq   = v_flgreq
		       and staappr  = 'P';
				commit;
				--
				begin
					select nvl(sum(qtylepay),0) into v_qtylepay_req
						from tpayvac
					 where codempid	 = r1.codempid
						 and dteyear   = v_dteyear
						 and staappr	 = 'P';
				end;
				v_qtylepay := (v_qtyvacat - v_qtydayle) - v_qtylepay_req
                      - v_qtylepay1 ----
                      ;

				if v_qtylepay > 0 then
				--
					/*v_dteyrepay := 0; v_dtemthpay := 0; v_numperiod := 0;
	    		for r_tpriodal in c_tpriodal loop
	    			v_dteyrepay := r_tpriodal.dteyrepay;
	    			v_dtemthpay := r_tpriodal.dtemthpay;
	    			v_numperiod := r_tpriodal.numperiod;
	    			exit;
	    		end loop;
					if v_dteyrepay > 0 then*/
						gen_income(r1.codempid,v_amthour,v_amtday,v_amtmonth);
						v_qtybalance := v_qtylepay;
						v_amtlepay   := v_qtylepay * v_amtday;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('image',get_emp_img(r1.codempid));
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            if r1.dteeffex is not null then
              obj_data.put('dteeffex',to_char(r1.dteeffex,'dd/mm/yyyy'));
            end if;
            obj_data.put('dteyear',p_year);--User37 #3039 Final Test Phase 1 V11 12/02/2021 obj_data.put('dteyear',p_dteyrepay - para_zyear);
            obj_data.put('dtereq',to_char(sysdate,'dd/mm/yyyy')); ----obj_data.put('dtereq',to_char(r1.dteeffex,'dd/mm/yyyy'));
            obj_data.put('flgreq',v_flgreq);
--                if r1.numperiod is not null and r1.dtemthpay is not null and r1.dteyrepay is not null then
--                  obj_data.put('periodmthyre',to_char(r1.numperiod) || '/' ||
--                                            to_char(r1.dtemthpay) || '/' ||
--                                            to_char(r1.dteyrepay));
--                end if;
            obj_data.put('staappr','P');
            obj_data.put('desc_staappr',get_tlistval_name('ESSTAREQ','P',global_v_lang));
--                if r1.staappr = 'P' then
            /*begin
              select codleave
                into v_codleave
                from tleavecd
               where staleave = 'V'
                 and rownum = 1;
            exception when no_data_found then
              v_codleave := null;
            end;
            begin
              select qtyvacat,nvl(qtydayle,0)
                    ,nvl(qtylepay,0) ----
                into v_qtyvacat,v_qtydayle
                    ,v_qtylepay1 ----
                from tleavsum
               where codempid = r1.codempid
                 and dteyear  = p_year
                 and codleave = v_codleave;
            exception when no_data_found then
              v_qtyvacat := 0;
              v_qtydayle := 0;
              v_qtylepay1 := 0; ----
            end;*/
            hcm_util.cal_dhm_hm(v_qtyvacat,0,0,v_qtyavgwk,'1',
                              v_token1,v_token1,v_token1,v_token2);
            obj_data.put('qtyleave',v_token2);
            /*begin
              select nvl(sum(nvl(qtylepay,0)),0)
                into v_qtylepay_all
                from tpayvac
               where codempid = r1.codempid
                 and dteyear  = (p_dteyrepay - para_zyear)
                 and dtereq   <> r1.dteeffex
                 and staappr  = 'P';
            exception when no_data_found then
              v_qtylepay_all := 0;
            end;*/

            hcm_util.cal_dhm_hm(v_qtylepay ----same data in above check
            /*v_qtyvacat - v_qtydayle - v_qtylepay_all
                                - v_qtylepay1 ----*/
                                ,0,0,v_qtyavgwk,'1',
                                v_token1,v_token1,v_token1,v_token2);
            obj_data.put('qtybalance',v_token2);
--                elsif r1.staappr <> 'P' then
--                  hcm_util.cal_dhm_hm(r1.qtyvacat,0,0,v_qtyavgwk,'1',
--                                    v_token1,v_token1,v_token1,v_token2);
--                  obj_data.put('qtyleave',v_token2);
--                  hcm_util.cal_dhm_hm(r1.qtybalance,0,0,v_qtyavgwk,'1',
--                                    v_token1,v_token1,v_token1,v_token2);
--                  obj_data.put('qtybalance',v_token2);
--                end if;
            hcm_util.cal_dhm_hm(v_qtylepay,0,0,v_qtyavgwk,'1',
                                v_day,v_hour,v_min,v_token2);
            obj_data.put('day' ,v_day);
            obj_data.put('hour',v_hour);
            obj_data.put('min' ,v_min);
            obj_data.put('qtylepay',v_token2);
            obj_data.put('amtlepay',to_char(v_amtlepay,'fm999999999990.00'));
            obj_data.put('amtday',v_amtday);
            obj_data.put('amthour',v_amthour);
            if v_zupdsal = 'Y' then 
              obj_data.put('desc_amtlepay',to_char(v_amtlepay,'fm999999999990.00'));
              obj_data.put('flgdisplay','Y');
            else
              obj_data.put('desc_amtlepay','');
              obj_data.put('flgdisplay','N');
            end if;            
            
            obj_data.put('coderror','200');
            obj_rows.put(to_char(p_numrec),obj_data);
            p_numrec := p_numrec + 1;
--						begin
--							insert into tpayvac(codempid,dteyear,dtereq,flgreq,
--																	codcomp,typpayroll,
--																	qtypriyr,qtyvacat,qtydayle,qtybalance,qtylepay,amtday,amtlepay,
--																	dteyrepay,dtemthpay,numperiod,flgcalvac,dteappr,codappr,staappr,remarkap,codreq,
--																	dtecreate,codcreate,dteupd,coduser)
--													 values(r1.codempid,v_dteyear,r1.dteeffex,v_flgreq,
--																	r1.codcomp,r1.typpayroll,
--																	v_qtypriyr,v_qtyvacat,v_qtydayle,v_qtybalance,v_qtylepay,nvl(stdenc(round(v_amtday,2),r1.codempid,global_v_chken),0),nvl(stdenc(round(v_amtlepay,2),r1.codempid,global_v_chken),0),
--																	(p_dteyrepay - para_zyear),p_dtemthpay,p_numperiod,'N',null,null,'P',null,get_codempid(p_coduser),--v_dteyrepay,v_dtemthpay,v_numperiod,'N',sysdate,get_codempid(p_coduser),'P',null,get_codempid(p_coduser),
--																	sysdate,p_coduser,sysdate,p_coduser);
--              p_numrec := p_numrec + 1;
--            exception when dup_val_on_index then null;
--						end;
					--end if; -- v_dteyrepay > 0
				end if; -- v_qtylepay > 0
			end if; -- v_secur or p_coduser = 'AUTOBATCH'
    end loop; -- c_temploy1
    return obj_rows.to_clob;
--    commit;
	end;
  --
  procedure gen_index(json_str_output out clob) as
    obj_rows      json_object_t := json_object_t();
    obj_data      json_object_t;
    v_token1      number;
    v_token2      varchar2(4000 char);
    v_day         number;
    v_hour        number;
    v_min         number;
    v_count       number := 0;
    v_data        number := 0;
    flg_secur     boolean;
    v_secur       boolean := false;
    v_qtyavgwk    number;
    v_codcomp     tcenter.codcomp%type;
    v_codleave    tleavecd.codleave%type;
    v_qtyvacat    tleavsum.qtyvacat%type;
    v_qtydayle    tleavsum.qtydayle%type;
    v_qtylepay_all number;
    v_dtecal      date := trunc(sysdate);
    v_numrec      number := 0;
    v_error       varchar2(10 char);
    v_err_table	  varchar2(50 char);
    v_amthour			number;
		v_amtday			number;
		v_amtmonth		number;
    v_qtylepay1   number;
    v_qtypriyr_ny number;
    v_maxamtlepay number;

       v_qtybalance_day   number;
       v_qtybalance_hour  number;
       v_qtybalance_min   number;
    cursor c1 is
        select t2.codempid   ,t2.dteyear    ,t2.dtereq     ,t2.flgreq     ,
               t2.qtyvacat   ,t2.qtydayle   ,t2.qtylepay   ,t2.qtybalance ,
               t2.amtlepay   ,t2.dteyrepay  ,t2.dtemthpay  ,t2.numperiod  ,
               t2.staappr    ,t1.dteeffex
          from temploy1 t1 ,tpayvac t2
         where t1.codempid = nvl(p_codempid,t1.codempid)
           and t1.codcomp  like p_codcomp||'%'
           and t1.codempid = t2.codempid
           and t2.flgreq = 'E' and p_flgreq = 'E'
--           and (t2.flgreq  = p_flgreq
--           	or 'A' = p_flgreq)

--           and t2.staappr  = p_staappr
           and dtereq between nvl(p_dtestr,dtereq) and nvl(p_dteend,dtereq)
--           and to_char(dteyear) = nvl(p_year,to_char(dteyear))
      order by t1.codempid;
  begin
    v_qtyavgwk := hcm_util.get_qtyavgwk(p_codcomp,p_codempid);
    p_data := 0;
    for r1 in c1 loop
      v_data := v_data + 1;
      flg_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if flg_secur then ----and v_zupdsal = 'Y' then
        v_secur := true;
        gen_income(r1.codempid,v_amthour,v_amtday,v_amtmonth);
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('codempid',r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        if r1.dteeffex is not null then
          obj_data.put('dteeffex',to_char(r1.dteeffex,'dd/mm/yyyy'));
        end if;
        obj_data.put('dteyear',nvl(r1.dteyear,9999));
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('flgreq',r1.flgreq);
        if r1.numperiod is not null and r1.dtemthpay is not null and r1.dteyrepay is not null then
          obj_data.put('periodmthyre',to_char(r1.numperiod) || '/' ||
                                      to_char(r1.dtemthpay) || '/' ||
                                      to_char(r1.dteyrepay));
        end if;
        obj_data.put('staappr',r1.staappr);
        obj_data.put('desc_staappr',get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        if r1.staappr = 'P' then
          begin
            select codleave
              into v_codleave
              from tleavecd
             where staleave = 'V'
               and rownum = 1;
          exception when no_data_found then
            v_codleave := null;
          end;
          begin
            select qtyvacat,nvl(qtydayle,0),nvl(qtylepay,0) ----dteeffec
              into v_qtyvacat,v_qtydayle,v_qtylepay1 ----
              from tleavsum
             where codempid = r1.codempid
               and dteyear  = r1.dteyear
               and codleave = v_codleave
               and trunc(sysdate) >= nvl(dteeffeclv,trunc(sysdate));-- user22 : 20/09/2021 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/12 ||
          exception when no_data_found then
            v_qtyvacat := null;
            v_qtydayle := null;
          end;
          hcm_util.cal_dhm_hm(v_qtyvacat,0,0,v_qtyavgwk,'1',
                            v_token1,v_token1,v_token1,v_token2);
          obj_data.put('qtyleave',v_token2);
          --
          begin
           select nvl(qtypriyr,0) into v_qtypriyr_ny
             from tleavsum
            where codempid = r1.codempid
              and dteyear  = (r1.dteyear + 1)
              and codleave = v_codleave;
          exception when no_data_found then
            v_qtypriyr_ny := 0;
          end;
          --
          begin
            select nvl(sum(nvl(qtylepay,0)),0)
              into v_qtylepay_all
              from tpayvac
             where codempid = r1.codempid
               and dteyear  = r1.dteyear
               and dtereq   <> r1.dtereq
               and staappr  = 'P';
          exception when no_data_found then
            v_qtylepay_all := 0;
          end;
          hcm_util.cal_dhm_hm(v_qtyvacat - v_qtydayle - v_qtylepay_all
                              - v_qtypriyr_ny ----
                              - v_qtylepay1 ----
                              ,0,0,v_qtyavgwk,'1',
                              v_token1,v_token1,v_token1,v_token2);
          obj_data.put('qtybalance', v_token2);

       v_qtybalance_day   :=    to_number(substr(v_token2,1,instr(v_token2,':',1)-1));
       v_qtybalance_hour  :=    to_number(substr(v_token2,(instr(v_token2,':',1)+1),2));
       v_qtybalance_min   :=    to_number(substr(v_token2,instr(v_token2,':',1,2)+1));

        v_maxamtlepay := (v_amtday * v_qtybalance_day)+(v_amthour * v_qtybalance_hour)+((v_amthour / 60) * v_qtybalance_min);
        obj_data.put('maxamtlepay',round(v_maxamtlepay,2));
        elsif r1.staappr <> 'P' then
          hcm_util.cal_dhm_hm(r1.qtyvacat,0,0,v_qtyavgwk,'1',
                            v_token1,v_token1,v_token1,v_token2);
          obj_data.put('qtyleave',v_token2);
          obj_data.put('qtyleave',v_token2);
          hcm_util.cal_dhm_hm(r1.qtybalance,0,0,v_qtyavgwk,'1',
                            v_token1,v_token1,v_token1,v_token2);
          obj_data.put('qtybalance',v_token2);
        end if;
        hcm_util.cal_dhm_hm(r1.qtylepay,0,0,v_qtyavgwk,'1',
                            v_day,v_hour,v_min,v_token2);
        obj_data.put('day' ,v_day);
        obj_data.put('hour',v_hour);
        obj_data.put('min' ,v_min);
        obj_data.put('qtylepay',v_token2);
        obj_data.put('amtlepay',to_char(stddec(r1.amtlepay,r1.codempid,global_v_chken),'fm999999999990.00'));
        obj_data.put('amtday',v_amtday);
        obj_data.put('amthour',v_amthour);
        if v_zupdsal = 'Y' then 
          obj_data.put('desc_amtlepay',to_char(stddec(r1.amtlepay,r1.codempid,global_v_chken),'fm999999999990.00'));
          obj_data.put('flgdisplay','Y');
        else
          obj_data.put('desc_amtlepay','');
          obj_data.put('flgdisplay','N');
        end if;
                        
        obj_data.put('coderror','200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;

    end loop;
    
    p_data := v_data;
    if p_flgreq <> 'E' then
      if p_flgreq = 'Y' then
        json_str_output   := cal_payvac_yearly(p_codempid,
                                               p_codcomp,
                                               v_dtecal,
                                               p_year,
                                               global_v_coduser,
                                               v_numrec,
                                               v_error,
                                               v_err_table,
                                               obj_rows);
        if v_error is not null then
          param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
      elsif p_flgreq = 'R' then
        json_str_output   := cal_payvac_resign(p_codempid,
                                               p_codcomp,
                                               v_dtecal,/*p_dteyrepay,p_dtemthpay,p_numperiod,*/
                                               p_dtestr,
                                               p_dteend,
                                               global_v_coduser,
                                               v_numrec,
                                               v_error,
                                               v_err_table,
                                               obj_rows);
        if v_error is not null then
          param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
      end if;
      v_data := p_data;
      v_secur := p_secur;
    else
      json_str_output   := obj_rows.to_clob;
    end if;
    if v_data  = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TLEAVSUM');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--      else
--        json_str_output := obj_rows.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_edit(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_edit;
  if param_msg_error is null then
    gen_edit(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_edit as
    v_flgsecu				boolean;
  begin
    if p_codempid is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    else
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        return;
      end if;
    end if;
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dtereq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_flgreq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end;

  function get_employ_amtday (p_codempid varchar2, p_dteeffec varchar2) return number as
		v_dtemovemt		date;
		v_codcomp			temploy1.codcomp%type;
		v_codpos			temploy1.codpos%type;
		v_numlvl			temploy1.numlvl%type;
		v_codjob			temploy1.codjob%type;
		v_codempmt		temploy1.codempmt%type;
		v_typemp			temploy1.typemp%type;
		v_typpayroll  temploy1.typpayroll%type;
		v_codbrlc			temploy1.codbrlc%type;
		v_codcalen		temploy1.codcalen%type;
		v_jobgrade		temploy1.jobgrade%type;
		v_codgrpgl		temploy1.codgrpgl%type;
		v_amthour		 	number := 0;
		v_amtday			number := 0;
		v_amtmth			number := 0;
  begin
    v_dtemovemt := p_dteeffec;
    std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',
                      v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                      v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                      v_amthour,v_amtday,v_amtmth);
    return v_amtday;
  end;

  procedure gen_edit(json_str_output out clob) as
    obj_data       json_object_t := json_object_t();
    v_qtyavgwk     number;
    v_codcomp      temploy1.codcomp%type;
    v_codempmt     temploy1.codempmt%type;
    v_dteeffex     temploy1.dteeffex%type;
    v_staemp       temploy1.staemp%type;
    v_codleave     tleavecd.codleave%type;
    v_staappr      tpayvac.staappr%type;
    v_qtylepay     tpayvac.qtylepay%type;
    v_qtylepay_other tpayvac.qtylepay%type;
    v_amtlepay     number;
    v_qtyvacat     tleavsum.qtyvacat%type;
    v_qtydayle     tleavsum.qtydayle%type;
    v_qtylepay1    tleavsum.qtylepay%type; ----

    v_qtylepay_day  number;
    v_qtylepay_hour number;
    v_qtylepay_min  number;

    v_token1           number;
    v_token2           varchar2(4000 char);
    v_warning_message  varchar2(4000 char);
    v_warning_response varchar2(4000 char);

    v_dtecycst      date;
    v_dtecycen      date;
  begin
    obj_data.put('dtereq',to_char(p_dtereq,'dd/mm/yyyy'));
    obj_data.put('codempid',p_codempid);
    obj_data.put('dteyear',to_char(p_year));
    obj_data.put('flgreq',p_flgreq);
    begin
        select codcomp,dteeffex,staemp
          into v_codcomp,v_dteeffex,v_staemp
          from temploy1
         where codempid = p_codempid;
        obj_data.put('dteeffex',to_char(v_dteeffex,'dd/mm/yyyy'));
    exception when no_data_found then
      v_codcomp := null;
      v_dteeffex := null;
    end;
    v_qtyavgwk := hcm_util.get_qtyavgwk(v_codcomp,null);
    begin
      select codleave
        into v_codleave
        from tleavecd
       where staleave = 'V'
         and rownum = 1;
    exception when no_data_found then
      v_codleave := null;
    end;
    begin
      select staappr
        into v_staappr
        from tpayvac
       where codempid = p_codempid
         and dteyear  = p_year
         and dtereq   = p_dtereq
         and flgreq   = p_flgreq;
    exception when no_data_found then
      if v_staemp = '9' and p_flgreq = 'Y' then
        param_msg_error := get_error_msg_php('HR3025',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return ;
      end if;
      if v_staemp <> '9' and p_flgreq = 'R' then
        param_msg_error := get_error_msg_php('HR7595',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return ;
      end if;
      v_staappr := null;
    end;
    obj_data.put('staappr',v_staappr);
    if v_staappr = 'Y' then
      v_warning_message := get_error_msg_php('HR8014',global_v_lang);
      v_warning_response:= get_response_message(null,v_warning_message,global_v_lang);
      obj_data.put('warning_message', hcm_util.get_string_t(json_object_t(v_warning_response),'response'));
    elsif v_staappr = 'N'  then
      v_warning_message := get_error_msg_php('HR8014',global_v_lang);
      v_warning_response:= get_response_message(null,v_warning_message,global_v_lang);
      obj_data.put('warning_message', hcm_util.get_string_t(json_object_t(v_warning_response),'response'));
    else
      obj_data.put('warning_message', '');
    end if;
    begin
      select qtyvacat,nvl(qtydayle,0)
            ,nvl(qtylepay,0) ----
        into v_qtyvacat,v_qtydayle
            ,v_qtylepay1 ----
        from tleavsum
       where codempid = p_codempid
         and dteyear  = p_year
         and codleave = v_codleave
         and trunc(sysdate) >= nvl(dteeffeclv,trunc(sysdate));-- user22 : 20/09/2021 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/12 ||
    exception when no_data_found then
      v_qtyvacat := 0;
      v_qtydayle := 0;
      param_msg_error := get_error_msg_php('AL0039',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    begin
      select stddec(amtlepay,p_codempid,global_v_chken),qtylepay
        into v_amtlepay,v_qtylepay
        from tpayvac
       where codempid = p_codempid
         and dteyear  = p_year
         and dtereq   = p_dtereq
         and flgreq   = p_flgreq;
    exception when no_data_found then
      v_amtlepay := 0;
      v_qtylepay := 0;
    end;

    begin
      select nvl(sum(nvl(qtylepay,0)),0)
        into v_qtylepay_other
        from tpayvac
       where codempid = p_codempid
         and dteyear  = p_year
         and dtereq   <> p_dtereq
         and staappr  = 'P';
    exception when no_data_found then
      v_qtylepay_other := 0;
    end;
    hcm_util.cal_dhm_hm(v_qtyvacat,0,0,v_qtyavgwk,
                        '1',v_token1,v_token1,v_token1,v_token2);
    obj_data.put('qtyleave',v_token2);
    hcm_util.cal_dhm_hm(nvl(v_qtyvacat,0) - nvl(v_qtydayle,0) - v_qtylepay_other
                        - nvl(v_qtylepay1,0) ----
                        ,0,0,v_qtyavgwk,
                        '1',v_token1,v_token1,v_token1,v_token2);
    obj_data.put('qtybalance',v_token2);
    hcm_util.cal_dhm_hm(v_qtylepay,0,0,v_qtyavgwk,
                        '1',
                        v_qtylepay_day,
                        v_qtylepay_hour,
                        v_qtylepay_min,
                        v_token2);
    obj_data.put('qtylepay',v_token2);
    obj_data.put('day',to_char(v_qtylepay_day));
    obj_data.put('hour',to_char(v_qtylepay_hour));
    obj_data.put('min',to_char(v_qtylepay_min));
    obj_data.put('amtlepay',v_amtlepay);

    std_al.cycle_leave2(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_codleave,p_year,v_dtecycst,v_dtecycen);
    obj_data.put('amtday',to_char(get_employ_amtday(p_codempid,to_char(v_dtecycen)),'fm999999999990.00'));

    obj_data.put('flgamt','Y');
    obj_data.put('coderror','200');
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_save(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_save(json_str_output out clob) as
    json_obj          json_object_t := json_object_t();
    v_codempid        tusrprof.codempid%type;
  begin
    json_obj.put('numperiod','1');
    json_obj.put('month',to_char(to_number(to_char(sysdate,'mm'  ))));
    json_obj.put('year' ,to_char(to_number(to_char(sysdate,'yyyy'))));
    begin
      select  codempid
          into  v_codempid
          from  tusrprof
         where  coduser = global_v_coduser;
      json_obj.put('codappr',v_codempid);
    exception when others then null;
    end;
    json_obj.put('dteappr' ,to_char(sysdate,'dd/mm/yyyy'));
    json_obj.put('remarkApprove','');
    json_obj.put('remarkReject','');
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_data (v_codempid in varchar2,v_dteyear in number ,
                         v_dtereq in date      ,v_flgreq in varchar2) as
  begin
    begin
    delete  tpayvac
     where  dtereq   = v_dtereq
         and  dteyear  = v_dteyear
         and  codempid = v_codempid
         and  flgreq   = v_flgreq
         and  staappr  = 'P';
  exception when others then null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure approve_data (v_staappr    in varchar2 ,v_codempid  in varchar2,
                          v_codleave  in varchar2 ,v_dteyear   in number  ,
                          v_dtereq    in date     ,v_flgreq    in varchar2,
                          v_numperiod in number   ,v_dtemthpay in number  ,
                          v_dteyrepay in number   ,v_remarkap  in varchar2,
                          v_codappr   in varchar2 ,v_dteappr   in date    ,
                          v_row_id    in number) as
    v_qtyvacat    tleavsum.qtyvacat%type;
    v_qtydayle    tleavsum.qtydayle%type;
    v_qtypriyr    tleavsum.qtypriyr%type;
    v_qtylepay1   tleavsum.qtylepay%type;
    v_qtylepay2   tpayvac.qtylepay%type;
    v_qtylepay_all number;
    v_qtyleave    number;
    v_dteeffec    date;
    v_found       varchar2(1) := 'N';
    v_typpayroll  temploy1.typpayroll%type;
    v_codcomp     temploy1.codcomp%type;
    v_qtybalance	number;
    v_chken       varchar2(4000 char) := hcm_secur.get_v_chken;
    v_timlepay    varchar2(100 char);

    v_amtincom1     number;
    v_amtincom2     number;
    v_amtincom3     number;
    v_amtincom4     number;
    v_amtincom5     number;
    v_amtincom6     number;
    v_amtincom7     number;
    v_amtincom8     number;
    v_amtincom9     number;
    v_amtincom10    number;
    v_amthour       number := null;
    v_amtday        number := null;
    v_amtmonth      number := null;
  begin

    begin
      select nvl(qtyvacat,0),nvl(qtydayle,0),nvl(qtypriyr,0),nvl(qtylepay,0)
        into v_qtyvacat,v_qtydayle,v_qtypriyr,v_qtylepay1
        from tleavsum
       where codempid = v_codempid
         and codleave = v_codleave
         and dteyear  = v_dteyear;
    exception when no_data_found then
      v_qtyvacat := null;
      v_qtydayle := null;
      v_qtylepay1 := null;
    end;

    v_timlepay   := p_day||':'||lpad(p_hour, 2, '0')||':'||lpad(p_min, 2, '0');
    v_qtylepay2  := ddhrmi_to_dd(v_timlepay, v_codempid);

    begin
      select nvl(sum(nvl(qtylepay,0)),0)
        into v_qtylepay_all
        from tpayvac
       where codempid = v_codempid
         and dteyear  = v_dteyear
         and dtereq   <> v_dtereq
         and staappr  = 'P';
    exception when no_data_found then
      v_qtylepay_all := 0;
    end;

    begin
      select  codcomp,typpayroll
      into    v_codcomp,v_typpayroll
      from    temploy1
      where   codempid = v_codempid;
    exception when no_data_found then
      null;
    end;

    gen_income(v_codempid,v_amthour,v_amtday,v_amtmonth);

    if v_staappr = 'Y' then
      if v_qtyvacat - v_qtydayle - v_qtylepay_all
         - v_qtylepay1 ----
         >= v_qtylepay2 then --check
        begin
          update tleavsum
             set ----qtyvacat   = (nvl(v_qtyvacat,0) - nvl(v_qtylepay2,0)),
                 qtylepay   = (nvl(v_qtylepay1,0) + nvl(v_qtylepay2,0)),
                 coduser    = global_v_coduser
           where codempid   = v_codempid
             and codleave   = v_codleave
             and dteyear    = v_dteyear;
        exception when others then
          null;
        end;

        begin
          insert into tpayvac
              (dtereq,    codempid,   dteyear,    flgreq,
              staappr,    codcomp,    typpayroll, qtypriyr,
              qtyvacat,   qtydayle,   qtylepay,   amtday,
              amtlepay,   dteyrepay,  dtemthpay,  numperiod,
              flgcalvac,  dteappr,    codappr,    remarkap,
              codreq,     dtecreate,  codcreate,  dteupd,
              coduser,    qtybalance)
          values
              (v_dtereq,  v_codempid, v_dteyear,    v_flgreq,
              v_staappr,  v_codcomp,  v_typpayroll, v_qtypriyr,
              v_qtyvacat, v_qtydayle, v_qtylepay2,  stdenc(v_amtday  ,v_codempid,v_chken),
              stdenc(nvl(p_amtlepay,0),v_codempid,v_chken), v_dteyrepay, v_dtemthpay, v_numperiod,
              'Y',        v_dteappr,  v_codappr,    v_remarkap,
              get_codempid(global_v_coduser), sysdate,  global_v_coduser, sysdate,
              global_v_coduser, nvl(v_qtyvacat,0) - nvl(v_qtydayle,0) - v_qtylepay_all);
        exception when dup_val_on_index then
          begin
            update tpayvac
               set dteappr    = v_dteappr,
                   codappr    = v_codappr,
                   staappr    = v_staappr,
                   coduser    = global_v_coduser,
                   numperiod  = v_numperiod,
                   dtemthpay  = v_dtemthpay,
                   dteyrepay  = v_dteyrepay,
                   remarkap   = v_remarkap,
                   qtyvacat   = v_qtyvacat,
                   qtybalance = nvl(v_qtyvacat,0) - nvl(v_qtydayle,0) - v_qtylepay_all,
                   qtydayle   = v_qtydayle,
                   qtypriyr   = v_qtypriyr,
                   qtylepay   = v_qtylepay2,
                   amtlepay   = stdenc(nvl(p_amtlepay,0),v_codempid,v_chken)
             where dtereq     = v_dtereq
               and dteyear    = v_dteyear
               and codempid   = v_codempid
               and flgreq     = v_flgreq;
          exception when others then
            null;
          end;
        end;
      else
        param_msg_error := get_error_msg_php('AL0054',global_v_lang);
        rollback;
        return;
      end if;
    elsif v_staappr = 'N' then
      begin
        insert into tpayvac
            (dtereq,    codempid,   dteyear,    flgreq,
            staappr,    codcomp,    typpayroll, qtypriyr,
            qtyvacat,   qtydayle,   qtylepay,   amtday,
            amtlepay,   dteyrepay,  dtemthpay,  numperiod,
            flgcalvac,  dteappr,    codappr,    remarkap,
            codreq,     dtecreate,  codcreate,  dteupd,
            coduser,    qtybalance)
        values
            (v_dtereq,  v_codempid, v_dteyear,    v_flgreq,
            'N',  v_codcomp,  v_typpayroll, v_qtypriyr,
            v_qtyvacat, v_qtydayle, v_qtylepay2,  stdenc(v_amtday  ,v_codempid,v_chken),
            stdenc(nvl(p_amtlepay,0),v_codempid,v_chken), v_dteyrepay, v_dtemthpay, v_numperiod,
            'N',        v_dteappr,  v_codappr,    v_remarkap,
            get_codempid(global_v_coduser), sysdate,  global_v_coduser, sysdate,
            global_v_coduser, nvl(v_qtyvacat,0) - nvl(v_qtydayle,0) - v_qtylepay_all);
      exception when dup_val_on_index then
        update tpayvac
           set dteappr   = v_dteappr,
               codappr   = v_codappr,
               staappr   = 'N',
               remarkap  = v_remarkap,
               coduser   = global_v_coduser
         where dtereq    = v_dtereq
           and dteyear   = v_dteyear
           and codempid  = v_codempid
           and flgreq    = v_flgreq;
      end;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure send_approve(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_approve;
  if param_msg_error is null then
    approve_data(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_approve as
    json_obj        json_object_t;
    v_flg           varchar2(4000 char);
    v_staappr       varchar2(4000 char);
    v_codempid      varchar2(4000 char);
    v_dteyear       number;
    v_dtereq        date;
    v_flgreq        varchar2(4000 char);
  --  v_amtlepay      number;
 --   v_qtylepay      number;
    v_codleave      varchar2(4000 char);
    v_numperiod     number;
    v_dtemthpay     number;
    v_dteyrepay     number;
    v_remarkap      varchar2(4000 char);
    v_codappr       varchar2(4000 char);
    v_dteappr       date;
    v_codcompy      temploy1.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_flgsecu				boolean;

    v_amtday   number;
    v_amthour   number;
    v_amtlepay              number;
    v_qtyleave              varchar2(4000 char);
    v_qtylepay              varchar2(4000 char);
    v_qtybalance            varchar2(4000 char);
    v_day                   number :=0 ;
    v_hour                  number :=0 ;
    v_min                   number :=0 ;

    v_qtybalance_day        number :=0 ;
    v_qtybalance_hour       number :=0 ;
    v_qtybalance_min        number :=0 ;
    v_maxamtlepay           number :=0 ;
  begin
    begin
      select codleave
        into v_codleave
        from tleavecd
       where staleave = 'V'
         and rownum = 1;
    exception when no_data_found then
      v_codleave := null;
    end;
    if param_json is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'param_json');
        return;
    end if;

    if param_json is not null then
      for i in 0..param_json.get_size-1 loop
        json_obj      := hcm_util.get_json_t(param_json,to_char(i));
        v_flg         := hcm_util.get_string_t(json_obj,'flg');
        v_staappr     := hcm_util.get_string_t(json_obj,'flgStaappr');
        if v_flg is not null then
          if v_flg = 'delete' then
            v_codempid := hcm_util.get_string_t(json_obj,'codempid');
            v_dteyear  := to_number(hcm_util.get_string_t(json_obj,'dteyear'));
            v_dtereq   := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
            v_flgreq   := hcm_util.get_string_t(json_obj,'flgreq');
            if v_codempid is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_codempid');
              return;
            else
              begin
                  select codempid
                    into v_codempid
                    from temploy1
                   where codempid = v_codempid;
              exception when no_data_found then
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                  return;
              end;
              v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              if not v_flgsecu then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
                return;
              end if;
            end if;
            if v_dteyear is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dteyear');
              return;
            end if;
            if v_dtereq is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dtereq');
              return;
            end if;
            if v_flgreq is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_flgreq');
              return;
            end if;
          end if;
          if param_msg_error is not null then
            return;
          end if;
        else
          v_staappr   := hcm_util.get_string_t(json_obj,'flgStaappr');
          if v_staappr = 'A' then
            v_staappr   := 'Y';
            v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
            v_dteyear   := to_number(nvl(hcm_util.get_string_t(json_obj,'dteyear'),p_dteyrepay));
            v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
            v_flgreq    := hcm_util.get_string_t(json_obj,'flgreq');
            v_numperiod := p_numperiod;
            v_dtemthpay := p_dtemthpay;
            v_dteyrepay := p_dteyrepay;
            v_remarkap  := p_remarkApprove;
            v_codappr   := p_codappr;
            v_dteappr   := p_dteappr;
            v_codcompy   := null;
            v_typpayroll := null;
            v_amtday     := hcm_util.get_string_t(json_obj,'amtday');
            v_amthour    := hcm_util.get_string_t(json_obj,'amthour');
            v_amtlepay   := hcm_util.get_string_t(json_obj,'amtlepay');
            v_day        := hcm_util.get_string_t(json_obj,'day');
            v_hour       := hcm_util.get_string_t(json_obj,'hour');
            v_min        := hcm_util.get_string_t(json_obj,'min');
            v_qtybalance := hcm_util.get_string_t(json_obj,'qtybalance');
            v_qtyleave   := hcm_util.get_string_t(json_obj,'qtyleave');
            v_maxamtlepay := hcm_util.get_string_t(json_obj,'maxamtlepay');
            v_qtylepay   := hcm_util.get_string_t(json_obj,'qtylepay');

              if v_day = 0 and  v_hour = 0 and v_min = 0 then
                param_msg_error := get_error_msg_php('AL0077',global_v_lang,null);
                return;
              else
              -----
               v_qtybalance_day   :=    to_number(substr(v_qtybalance,1,instr(v_qtybalance,':',1)-1));
               v_qtybalance_hour  :=    to_number(substr(v_qtybalance,(instr(v_qtybalance,':',1)+1),2));
               v_qtybalance_min   :=    to_number(substr(v_qtybalance,instr(v_qtybalance,':',1,2)+1));

                  if v_day > v_qtybalance_day then
                    param_msg_error := get_error_msg_php('AL0064',global_v_lang,null);
                    return;
                 else
                     if  v_day = v_qtybalance_day then
                         if v_hour > v_qtybalance_hour  then
                            param_msg_error := get_error_msg_php('AL0064',global_v_lang,null);
                            return;
                         else
                            if  v_hour = v_qtybalance_hour then
                                if v_min > v_qtybalance_min  then
                                    param_msg_error := get_error_msg_php('AL0064',global_v_lang,null);
                                    return;
                                end if;
                            end if;
                         end if;
                     end if;
                 end if;

                 if v_amtlepay > v_maxamtlepay then
                     param_msg_error := get_error_msg_php('AL0078',global_v_lang,null);
                     return;
                 end if;
              end if;
      ----------------------------------------------------------------------
            begin
              select  hcm_util.get_codcomp_level(codcomp,1) ,typpayroll
                into  v_codcompy,v_typpayroll
                from  temploy1
               where  codempid = v_codempid;
            exception when no_data_found then
                      null;
            end;

             begin
              select  codcompy
                into  v_codcompy
                from  tpriodal
               where  codcompy   = v_codcompy
                 and  typpayroll = v_typpayroll
                 and  codpay     in (select  codvacat
                                       from  tcontal2
                                      where  codcompy = v_codcompy
                                        and  dteeffec = (select  max(dteeffec)
                                                           from  tcontal2
                                                          where  codcompy = v_codcompy
                                                            and  dteeffec <= sysdate))
                 and  dteyrepay  = v_dteyrepay
                 and  dtemthpay  = v_dtemthpay
                 and  numperiod  = v_numperiod
                 and  rownum <= 1;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpriodal');
              return;
            end;
            if v_codappr is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_codappr');
                return;
            end if;
            if v_dteappr is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dteappr');
                return;
            end if;
            if v_staappr is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_stappr');
                return;
            end if;
            if v_codempid is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_codempid');
                return;
            else
                begin
                    select codempid
                      into v_codempid
                      from temploy1
                     where codempid = v_codempid;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                    return;
                end;
                v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if not v_flgsecu then
                  param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
                  return;
                end if;
            end if;
            if v_dteyear is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dteyear');
                    return;
            end if;
            if v_dtereq is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dtereq');
                    return;
            end if;
            if v_flgreq is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_flgreq');
                    return;
            end if;
            if v_numperiod is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_numperiod');
                    return;
            end if;
            if v_dtemthpay is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dtemthpay');
                return;
            end if;
            if v_dteyrepay is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_dteyrepay');
                return;
            end if;
          elsif v_staappr = 'N' then
              v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
              v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
              v_flgreq    := hcm_util.get_string_t(json_obj,'flgreq');
              v_dteyear   := to_number(nvl(hcm_util.get_string_t(json_obj,'dteyear'),p_dteyrepay));
              v_remarkap  := p_remarkReject;
          end if;
          if param_msg_error is not null then
            return;
          end if;
        end if;
      end loop;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure approve_data (json_str_output out clob) as
    json_obj        json_object_t;
    json_obj1       json_object_t;
    v_flg           varchar2(4000 char);
    v_staappr       varchar2(4000 char);
    v_codempid      varchar2(4000 char);
    v_dteyear       number;
    v_dtereq        date;
    v_flgreq        varchar2(4000 char);
    v_row_id        number;
    v_qtybalance    number;
    v_amtlepay      number;
    v_qtylepay      number;
    v_codleave      varchar2(4000 char);
    v_numperiod     number;
    v_dtemthpay     number;
    v_dteyrepay     number;
    v_remarkap      varchar2(4000 char);
    v_codappr       varchar2(4000 char);
    v_dteappr       date;
  begin
    begin
      select codleave
        into v_codleave
        from tleavecd
       where staleave = 'V'
         and rownum = 1;
    exception when no_data_found then
      v_codleave := null;
    end;
    if param_json is not null then
      for i in 0..param_json.get_size-1 loop
        json_obj      := hcm_util.get_json_t(param_json,to_char(i));
        v_flg         := hcm_util.get_string_t(json_obj,'flg');
        v_staappr     := hcm_util.get_string_t(json_obj,'flgStaappr');

        p_codempid   := hcm_util.get_string_t(json_obj,'codempid');
        p_dteyear    := hcm_util.get_string_t(json_obj,'dteyear');
        p_dtereq     := hcm_util.get_string_t(json_obj,'dtereq');
        p_flgreq     := hcm_util.get_string_t(json_obj,'flgreq');
        p_amtlepay   := hcm_util.get_string_t(json_obj,'amtlepay');
        p_day        := hcm_util.get_string_t(json_obj,'day');
        p_hour       := hcm_util.get_string_t(json_obj,'hour');
        p_min        := hcm_util.get_string_t(json_obj,'min');
        p_qtybalance := hcm_util.get_string_t(json_obj,'qtybalance');

        if v_flg is not null then
          if v_flg = 'delete' then
            v_codempid := hcm_util.get_string_t(json_obj,'codempid');
            v_dteyear  := to_number(hcm_util.get_string_t(json_obj,'dteyear'));
            v_dtereq   := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
            v_flgreq   := hcm_util.get_string_t(json_obj,'flgreq');
            delete_data (v_codempid,v_dteyear,
                         v_dtereq  ,v_flgreq  );
          end if;
          if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end if;
        else
          v_row_id    := hcm_util.get_string_t(json_obj,'rowID');
          v_staappr   := hcm_util.get_string_t(json_obj,'flgStaappr');

          if v_staappr = 'A' then
            v_staappr   := 'Y';
            v_remarkap  := p_remarkApprove;
          elsif v_staappr = 'N' then
            v_remarkap  := p_remarkReject;
          end if;
          --
          v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
          v_dteyear   := to_number(hcm_util.get_string_t(json_obj,'dteyear'));
          v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
          v_flgreq    := hcm_util.get_string_t(json_obj,'flgreq');
          v_numperiod := p_numperiod;
          v_dtemthpay := p_dtemthpay;
          v_dteyrepay := p_dteyrepay;
          v_codappr   := p_codappr;
          v_dteappr   := p_dteappr;
          approve_data (v_staappr  ,v_codempid ,
                          v_codleave ,v_dteyear  ,
                          v_dtereq   ,v_flgreq   ,
                          v_numperiod,v_dtemthpay,
                          v_dteyrepay,v_remarkap ,
                          v_codappr  ,v_dteappr  ,
                          v_row_id);
          if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end if;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2200',global_v_lang);
    end if;
    json_str_output := get_response_message('200',param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    save_data(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_data(json_str_output out clob) as
    v_qtylepay   number;
    v_timlepay   varchar2(100 char);

    v_codempid   varchar2(10 char);
    v_dteyear    number;
    v_dtereq     date;
    v_flgreq     varchar2(1 char);
    v_amtlepay   number;
    v_qtybalance number;
    v_codleave   varchar2(10 char);
    v_numlvl     number;

    v_amtincom1     number;
    v_amtincom2     number;
    v_amtincom3     number;
    v_amtincom4     number;
    v_amtincom5     number;
    v_amtincom6     number;
    v_amtincom7     number;
    v_amtincom8     number;
    v_amtincom9     number;
    v_amtincom10    number;
    v_sumhur        number := null;
    v_sumday        number := null;
    v_summth        number := null;
    v_codcomp       temploy1.codcomp%type;
    v_codempmt      temploy1.codempmt%type;
    v_dteeffex      temploy1.dteeffex%type;
    v_chken         varchar2(4000 char) := hcm_secur.get_v_chken;
    v_typpayroll    tleavsum.typpayroll%type;
    v_qtyvacat      tleavsum.qtyvacat%type;
    v_qtydayle      tleavsum.qtydayle%type;
    v_qtypriyr      tleavsum.qtypriyr%type;
    v_dteeffec      date;
    v_qtylepay_all  number;
    v_numperiod     number;
    v_dtemthpay     number;
    v_dteyrepay     number;
    v_qtylepay1     number; ----
  begin
    v_codempid   := p_codempid;
    v_dteyear    := p_dteyear;
    v_dtereq     := p_dtereq;
    v_flgreq     := p_flgreq;
    v_amtlepay   := p_amtlepay;
    v_timlepay   := p_day||':'||lpad(p_hour, 2, '0')||':'||lpad(p_min, 2, '0');
    v_qtylepay   := ddhrmi_to_dd(v_timlepay, p_codempid);
    v_qtybalance := ddhrmi_to_dd(p_qtybalance, p_codempid);

    if v_flgreq = 'R' then
      v_numperiod  := p_numperiod;
      v_dtemthpay  := p_dtemthpay;
      v_dteyrepay  := p_dteyrepay;
    end if;
    --
    begin
      select codleave
        into v_codleave
        from tleavecd
       where staleave = 'V'
         and rownum = 1;
    exception when no_data_found then
      v_codleave := null;
    end;
    begin
      select  nvl(to_number(stddec(amtincom1,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom2,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom3,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom4,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom5,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom6,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom7,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom8,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom9,codempid,v_chken)),0),
              nvl(to_number(stddec(amtincom10,codempid,v_chken)),0)
      into    v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
              v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
      from    temploy3
      where   codempid = v_codempid;
    exception when no_data_found then
      null;
    end;

    begin
        select  codcomp,codempmt,dteeffex
        into    v_codcomp,v_codempmt,v_dteeffex
        from    temploy1
        where   codempid = v_codempid;
    exception when no_data_found then
      null;
    end;
    get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1)   ,v_codempmt  ,v_amtincom1 ,v_amtincom2  ,
                    v_amtincom3 ,v_amtincom4 ,v_amtincom5 ,v_amtincom6  ,
                    v_amtincom7 ,v_amtincom8 ,v_amtincom9 ,v_amtincom10 ,
                    v_sumhur    ,v_sumday    ,v_summth);

    begin
      select qtyvacat   ,qtydayle    ,
             qtypriyr   ,typpayroll
             ,qtylepay ----
        into v_qtyvacat ,v_qtydayle  ,
             v_qtypriyr ,v_typpayroll
             ,v_qtylepay1 ----
        from tleavsum
       where codempid = v_codempid
         and codleave = v_codleave
         and dteyear  = v_dteyear;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0054',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end;
    --
    begin
      select nvl(sum(nvl(qtylepay,0)),0)
        into v_qtylepay_all
        from tpayvac
       where codempid = v_codempid
         and dteyear  = v_dteyear
         and dtereq   <> v_dtereq
         and staappr  = 'P';
    exception when no_data_found then null;
    end;
    if v_qtyvacat - nvl(v_qtydayle,0) - v_qtylepay_all
      - nvl(v_qtylepay1,0) ----
      < v_qtylepay then
      param_msg_error := get_error_msg_php('AL0054',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    begin
      insert into tpayvac
          (dtereq,    codempid,   dteyear,    flgreq,
          staappr,    codcomp,    typpayroll, qtypriyr,
          qtyvacat,   qtydayle,   qtylepay,   amtday,
          amtlepay,   dteyrepay,  dtemthpay,  numperiod,
          flgcalvac,  dteappr,    codappr,    remarkap,
          codreq,     dtecreate,  codcreate,  dteupd,
          coduser,    qtybalance)
      values
          (v_dtereq,  v_codempid, v_dteyear,    v_flgreq,
          'P',        v_codcomp,  v_typpayroll, v_qtypriyr,
          v_qtyvacat, v_qtydayle, v_qtylepay,   stdenc(v_sumday  ,v_codempid,v_chken),
          stdenc(nvl(v_amtlepay,0),v_codempid,v_chken), v_dteyrepay, v_dtemthpay, v_numperiod,
          'N',        null,       null,         null,
          get_codempid(global_v_coduser), sysdate,  global_v_coduser, sysdate,
          global_v_coduser, nvl(v_qtybalance,0));
    exception when dup_val_on_index then
      begin
        select numlvl
          into v_numlvl
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;
      declare
        v_staappr_1 varchar2(4000 char);
      begin
        select staappr
          into v_staappr_1
          from tpayvac
         where dtereq     = v_dtereq
           and codempid   = v_codempid
           and dteyear    = v_dteyear
           and flgreq     = v_flgreq;
        if v_staappr_1 <> 'P' then
          null;
        end if;
      exception when others then
        null;
      end;
        update tpayvac
           set amtlepay   = stdenc(nvl(v_amtlepay,0),v_codempid,v_chken),
               coduser    = global_v_coduser,
               dteupd     = sysdate,
               qtylepay   = v_qtylepay
         where dtereq     = v_dtereq
           and codempid   = v_codempid
           and dteyear    = v_dteyear
           and flgreq     = v_flgreq
           and staappr    = 'P';
    end;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRAL5OU;

/
