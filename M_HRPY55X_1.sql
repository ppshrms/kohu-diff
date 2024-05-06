--------------------------------------------------------
--  DDL for Package Body M_HRPY55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPY55X" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 12/03/2024 15:30
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    param_msg_error     := null;
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_codempst          := upper(hcm_util.get_string_t(json_obj,'p_codempst'));
    p_codform           := upper(hcm_util.get_string_t(json_obj,'p_codform'));
    p_codslip           := upper(hcm_util.get_string_t(json_obj,'p_codslip'));
    p_desslip           := hcm_util.get_string_t(json_obj,'p_desslip');
    p_desslipe           := hcm_util.get_string_t(json_obj,'p_desslipe');
    p_desslipt           := hcm_util.get_string_t(json_obj,'p_desslipt');
    p_desslip3           := hcm_util.get_string_t(json_obj,'p_desslip3');
    p_desslip4           := hcm_util.get_string_t(json_obj,'p_desslip4');
    p_desslip5           := hcm_util.get_string_t(json_obj,'p_desslip5');

    p_flgaccinc          := hcm_util.get_string_t(json_obj,'p_flgaccinc');
    p_flgslip            := hcm_util.get_string_t(json_obj,'p_flgslip');
    p_dtepay             := to_date(hcm_util.get_string_t(json_obj,'p_dtepay'),'ddmmyyyy');
    p_dtepay_temp        := to_char(p_dtepay,'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  function check_lov_codinc (p_codinc varchar2) return varchar2 is
    v_codinc  varchar2(4 char);
  begin
--    begin
--      select codinc into v_codinc from tfrmslip2
--        where codcodec = p_codinc;
--
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodslip');
--    end;
    return '';
  end;

  function check_lov_codded (p_codded varchar2) return varchar2 is
    v_codinc  varchar2(4 char);
  begin
--     begin
--      select codcodec into v_codinc from tcodslip
--        where codcodec = p_codded;
--
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodslip');
--    end;
    return '';
  end;

  procedure check_lov_codpay (p_codcodec varchar2) is
    v_descod  varchar2(4 char);
  begin
    if p_codcodec is not null then
      begin
         select codcodec
            into v_descod
            from tcodslip
           where codcodec = p_codcodec;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
    end if;
  end;

 function save_flg_detail (p_flg varchar2) return varchar2 is
  begin
    if p_flg = 1 then
      return 'Y';
    else
      return 'N';
    end if;
  end;

 function save_flg_table (p_flg boolean) return varchar2 is
  begin
    if p_flg then
      return 'Y';
    else
      return 'N';
    end if;
  end;

  function get_flg (p_flg varchar2) return boolean is
  begin
    if p_flg = 'Y' then
      return true;
    else
      return false;
    end if;
  end;

  procedure check_index is
    flgsecu boolean := false;
  begin
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
--    if p_typpayroll is not null then
--      param_msg_error := hcm_secur.secur_typpayroll(global_v_coduser, global_v_lang, p_typpayroll);
--      if param_msg_error is not null then
--        return;
--      end if;
--    end if;
  end check_index;

  procedure check_detail is
    flgsecu boolean := false;
  begin
    if p_codslip is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codslip');
      return;
    end if;
  end;
--
  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like 'HRPY55X%';
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end clear_ttemprpt;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    clear_ttemprpt;
    check_index;

    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_dtepay(json_str_input in clob, json_str_output out clob) as
   obj_data        json_object_t;
   v_dtepaymt		   date;
   v_dtepaymt2		 date;
   v_typpayroll      temploy1.typpayroll%type;

    cursor c1 is
	  select dtepaymt
	    from tdtepay
	   where dteyrepay  = p_dteyrepay
	     and	dtemthpay = p_dtemthpay
	     and	typpayroll = nvl(v_typpayroll,typpayroll)
			and	numperiod = p_numperiod;

    cursor c2 is
	  select dtepaymt
	    from tdtepay2
	   where dteyrepay  = p_dteyrepay
	     and	dtemthpay = p_dtemthpay
       and	typpayroll = nvl(v_typpayroll,typpayroll)
			and	numperiod = p_numperiod;

  begin
    initial_value(json_str_input);

    if p_codempid is not null then
      begin
        select typpayroll
          into v_typpayroll
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        v_typpayroll := p_typpayroll;
      end;
    else
      if p_typpayroll is not null then
         v_typpayroll := p_typpayroll;
      end if;
    end if;
    for r1 in c1 loop
      v_dtepaymt := r1.dtepaymt;
    end loop;

    if v_dtepaymt is null then
      for r2 in c2 loop
        v_dtepaymt := r2.dtepaymt;
      end loop;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtepaymt',to_char(v_dtepaymt,'dd/mm/yyyy'));
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_data2        json_object_t;
    obj_data3        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_flgsecu       boolean;
    v_rcnt          number := 0;
    v_secur         varchar2(4000 char);
    v_permission    boolean := false;
    v_exist         boolean := false;

    v_codempid      varchar2(100 char);
    v_flgempst      boolean := true;
    v_codempst      varchar2(100 char);
    v_numbank       varchar2(100 char);
    v_nambank       varchar2(100 char);
    v_codbank       varchar2(100 char);
    v_dtepaymt		  date;
    v_qtyvacat      number := 0;
    v_dteend1			  varchar2(30);
    v_dteend			  date;
 	v_dtestrt			  date;
    v_year				  number;
    v_dtecycst		  date;
    v_dtecycen		  date;
    v_hour				  varchar2(100);
    v_numseq				number;
    v_codempmt		temploy1.codempmt%type;
    v_unitcal1		tcontpmd.unitcal1%type;
    v_codwage	  	varchar2(10);
    v_qtypayda		tothinc.qtypayda%type;
    v_qtypayhr		tothinc.qtypayhr%type;
    v_qtypaysc		tothinc.qtypaysc%type;
    v_qtywork			ttaxcur.qtywork%type;
    v_numx1       number := 0;
    v_codleave		tleavecd.codleave%type;

    	type desarray is table of varchar2(150) index by binary_integer;
        v_desinc		desarray;
        v_desded		desarray;
        t_desinc		desarray;
        t_desded		desarray;
        t_flgdesinc		desarray;
        t_flgdesded		desarray;
      type amtarray is table of number index by binary_integer;
        v_amtinc		amtarray;
        v_amtded		amtarray;
      type var is table of varchar2(60) index by binary_integer;
        v_amt       var;
      type var1 is table of varchar2(60) index by binary_integer;
        v_qtysmot   var1;
        v_rtesmot		var1;

    v_codslip    varchar2(4 char);
    v_desslip    varchar2(150 char);
    v_desslipe   varchar2(150 char);
    v_desslipt   varchar2(150 char);
    v_desslip3   varchar2(150 char);
    v_desslip4   varchar2(150 char);
    v_desslip5   varchar2(150 char);
    v_typscan    number(3,2);
    v_flgaccinc  varchar2(1 char);
    v_flgacctax  varchar2(1 char);
    v_flgaccpf   varchar2(1 char);
    v_flgaccsoc  varchar2(1 char);
    v_flgothpy   varchar2(1 char);
    v_flgqtywk   varchar2(1 char);
    v_flgvacat   varchar2(1 char);
    v_flgot      varchar2(1 char);
    v_flgotlb    varchar2(1 char);
    v_rteot1     number(3,2);
    v_rteot2     number(3,2);
    v_rteot3     number(3,2);
    v_rteot4     number(3,2);
    v_rteot5     number(3,2);
    v_dte_st		 date;
	  v_dte_en		 date;
    v_qtysmot1    varchar2(100 char);
    v_check    	 	number;
    v_work				varchar2(100);
    v_inc					number;
    v_ded					number;
    v_suminc			number;
    v_sumded			number;
    v_amtnet			number;
    v_amtnet_e		number;
    v_amtcalt			number;
    v_amttax			number;
    v_amtsoc			number;
    v_amtpay			number;
    v_amtpf 			number;
    v_max					number;
    v_amtothed		number := 0;
    v_amtothinc 	number := 0;

    v_numx2 	    number := 0;
    v_numx3 	    number := 0;
    v_numx4 	    number := 0;
    v_numx5 	    number := 0;

    v_codinc1  varchar2(4 char);
    v_codinc2  varchar2(4 char);
    v_codinc3  varchar2(4 char);
    v_codinc4  varchar2(4 char);
    v_codinc5  varchar2(4 char);
    v_codinc6  varchar2(4 char);
    v_codinc7  varchar2(4 char);
    v_codinc8  varchar2(4 char);
    v_codinc9  varchar2(4 char);
    v_codinc10  varchar2(4 char);
    v_codinc11  varchar2(4 char);
    v_codinc12  varchar2(4 char);
    v_codinc13  varchar2(4 char);
    v_codinc14  varchar2(4 char);
    v_codinc15  varchar2(4 char);
    v_codinc16  varchar2(4 char);

    v_codded1  varchar2(4 char);
    v_codded2  varchar2(4 char);
    v_codded3  varchar2(4 char);
    v_codded4  varchar2(4 char);
    v_codded5  varchar2(4 char);
    v_codded6  varchar2(4 char);
    v_codded7  varchar2(4 char);
    v_codded8  varchar2(4 char);
    v_codded9  varchar2(4 char);
    v_codded10  varchar2(4 char);
    v_codded11  varchar2(4 char);
    v_codded12  varchar2(4 char);
    v_codded13  varchar2(4 char);
    v_codded14  varchar2(4 char);
    v_codded15  varchar2(4 char);
    v_codded16  varchar2(4 char);

    v_flginclb1 varchar2(1 char);
    v_flginclb2 varchar2(1 char);
    v_flginclb3 varchar2(1 char);
    v_flginclb4 varchar2(1 char);
    v_flginclb5 varchar2(1 char);
    v_flginclb6 varchar2(1 char);
    v_flginclb7 varchar2(1 char);
    v_flginclb8 varchar2(1 char);
    v_flginclb9 varchar2(1 char);
    v_flginclb10 varchar2(1 char);
    v_flginclb11 varchar2(1 char);
    v_flginclb12 varchar2(1 char);
    v_flginclb13 varchar2(1 char);
    v_flginclb14 varchar2(1 char);
    v_flginclb15 varchar2(1 char);
    v_flginclb16 varchar2(1 char);

    v_flgdedlb1 varchar2(1 char);
    v_flgdedlb2 varchar2(1 char);
    v_flgdedlb3 varchar2(1 char);
    v_flgdedlb4 varchar2(1 char);
    v_flgdedlb5 varchar2(1 char);
    v_flgdedlb6 varchar2(1 char);
    v_flgdedlb7 varchar2(1 char);
    v_flgdedlb8 varchar2(1 char);
    v_flgdedlb9 varchar2(1 char);
    v_flgdedlb10 varchar2(1 char);
    v_flgdedlb11 varchar2(1 char);
    v_flgdedlb12 varchar2(1 char);
    v_flgdedlb13 varchar2(1 char);
    v_flgdedlb14 varchar2(1 char);
    v_flgdedlb15 varchar2(1 char);
    v_flgdedlb16 varchar2(1 char);
    v_desc1				varchar2(100);
 	  v_desc2				varchar2(100);
 	 -- v_desinc1			varchar2(100);
 	 -- v_desded1			varchar2(100);
 	  v_dtepay			varchar2(100);

    v_count       number := 0;
    v_codcompy    tcenter.codcompy%type;
    obj_ot_col    json_object_t;
    v_max_ot_col  number := 0;
    v_tmp_qtysmot varchar2(60);


   cursor c1 is
		 select sin.codempid,sin.codcomp,sin.numlvl,sin.codcurr,sin.codcurr_e,sin.typpayroll,sin.codempmt
	  	 from tsincexp sin,temploy3 em3
			where sin.dteyrepay   = p_dteyrepay
				and sin.dtemthpay   = p_dtemthpay
				and sin.numperiod   = p_numperiod
				and sin.codempid    = nvl(p_codempid,sin.codempid)
				and sin.codcomp     like nvl(p_codcomp,codcomp)||'%'
				and sin.typpayroll  = nvl(p_typpayroll,sin.typpayroll)
        and sin.codempid    = em3.codempid
		    and sin.flgslip     = '1'
        and ( p_flgslip is null or (p_flgslip is not null and em3.flgslip = p_flgslip ) )
   group by sin.codcomp,sin.codempid,sin.numlvl,sin.codcurr,sin.codcurr_e,sin.typpayroll,sin.codempmt
   order by sin.codcomp,sin.codempid;

   cursor c_tsincexp is
	  select typpayr,
				   nvl(sum(nvl(stddec(amtpay,codempid,v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay,
				   nvl(sum(nvl(stddec(amtpay_e,codempid,v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay_e
  	 from tsincexp
		where codempid = v_codempid
	    and	dteyrepay = p_dteyrepay
			and	dtemthpay = p_dtemthpay
			and	numperiod = p_numperiod
			and	flgslip = '1'
			and typpayr is not null
            and (typpayr in (select codinc from tfrmslip2 where codslip = p_codslip and typpay = 1)
                or typpayr in (select codinc from tfrmslip2 where codslip = p_codslip and typpay = 2))
--			and ( typpayr in (nvl(t_desinc(1),'12345'),nvl(t_desinc(2),'12345'),nvl(t_desinc(3),'12345'),nvl(t_desinc(4),'12345')
--                        ,nvl(t_desinc(5),'12345'),nvl(t_desinc(6),'12345'),nvl(t_desinc(7),'12345'),nvl(t_desinc(8),'12345')
--                        ,nvl(t_desinc(9),'12345'),nvl(t_desinc(10),'12345'),nvl(t_desinc(11),'12345'),nvl(t_desinc(12),'12345')
--                        ,nvl(t_desinc(13),'12345'),nvl(t_desinc(14),'12345'),nvl(t_desinc(15),'12345'),nvl(t_desinc(16),'12345'))
--                      or typpayr in (nvl(t_desded(1),'12345'),nvl(t_desded(2),'12345'),nvl(t_desded(3),'12345'),nvl(t_desded(4),'12345')
--                      ,nvl(t_desded(5),'12345'),nvl(t_desded(6),'12345'),nvl(t_desded(7),'12345'),nvl(t_desded(8),'12345')
--                      ,nvl(t_desded(9),'12345'),nvl(t_desded(10),'12345'),nvl(t_desded(11),'12345'),nvl(t_desded(12),'12345')
--                      ,nvl(t_desded(13),'12345'),nvl(t_desded(14),'12345'),nvl(t_desded(15),'12345'),nvl(t_desded(16),'12345'))
--                      )
	  group by typpayr
	  order by typpayr;

	cursor c_tsincexp1 is
	  select typpayr,
				   nvl(sum(nvl(stddec(amtpay,codempid,v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay,
				   nvl(sum(nvl(stddec(amtpay_e,codempid,v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay_e
  	 from tsincexp
		where codempid = v_codempid
	    and	dteyrepay = p_dteyrepay
			and	dtemthpay = p_dtemthpay
			and	numperiod = p_numperiod
			and	flgslip = '1'
			and typpayr is not null
            and typpayr not in (select codinc from tfrmslip2 where codslip = p_codslip)
--			and ( typpayr not in (nvl(t_desinc(1),'12345'),nvl(t_desinc(2),'12345'),nvl(t_desinc(3),'12345'),nvl(t_desinc(4),'12345')
--                        ,nvl(t_desinc(5),'12345'),nvl(t_desinc(6),'12345'),nvl(t_desinc(7),'12345'),nvl(t_desinc(8),'12345')
--                        ,nvl(t_desinc(9),'12345'),nvl(t_desinc(10),'12345'),nvl(t_desinc(11),'12345'),nvl(t_desinc(12),'12345')
--                        ,nvl(t_desinc(13),'12345'),nvl(t_desinc(14),'12345'),nvl(t_desinc(15),'12345'),nvl(t_desinc(16),'12345')))
--      and (typpayr not in (nvl(t_desded(1),'12345'),nvl(t_desded(2),'12345'),nvl(t_desded(3),'12345'),nvl(t_desded(4),'12345')
--                      ,nvl(t_desded(5),'12345'),nvl(t_desded(6),'12345'),nvl(t_desded(7),'12345'),nvl(t_desded(8),'12345')
--                      ,nvl(t_desded(9),'12345'),nvl(t_desded(10),'12345'),nvl(t_desded(11),'12345'),nvl(t_desded(12),'12345')
--                      ,nvl(t_desded(13),'12345'),nvl(t_desded(14),'12345'),nvl(t_desded(15),'12345'),nvl(t_desded(16),'12345')))


	  group by typpayr
	  order by typpayr;

  cursor c_totsumd is
	  select rtesmot,sum(qtysmot) qtysmot
	    from totsumd
	   where codempid  = v_codempid
	     and	dteyrepay = p_dteyrepay
			and	dtemthpay = p_dtemthpay
			and	numperiod = p_numperiod
      and rtesmot in (nvl(v_rteot1,'12345'),nvl(v_rteot2,'12345'),nvl(v_rteot3,'12345'),nvl(v_rteot4,'12345')
                      ,nvl(v_rteot5,'12345'))
	  group by rtesmot
    order by rtesmot;

    cursor c_tfrmslip is
	  select rtesmot , sum(qtysmot) qtysmot
	    from totsumd
	   where codempid  = v_codempid
	     and	dteyrepay = p_dteyrepay
			and	dtemthpay = p_dtemthpay
			and	numperiod = p_numperiod
      group by rtesmot
	  order by rtesmot;

    cursor c_tfrmslip2_1 is
	  select codinc,flglabel
	    from tfrmslip2
	   where codslip = p_codslip
	     and typpay = 1
    order by numseq;

    cursor c_tfrmslip2_2 is
	  select codinc,flglabel
	    from tfrmslip2
	   where codslip = p_codslip
	     and typpay = 2
    order by numseq;

    cursor c_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
         and dteeffec = (select max(b.dteeffec)
                           from totratep2 b
                          where b.codcompy = v_codcompy
                            and b.dteeffec <= sysdate)
    order by rteotpay;

    -- Adisak 23/05/2023 16:38
    v_sum_qtyvacat      number := 0;
    cursor c_tleavecd is
      select codleave
                  into v_codleave
                  from tleavecd
                 where staleave = 'V';
    -- Adisak 23/05/2023 16:38
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_data2 := json_object_t();
    obj_data3 := json_object_t();
    obj_result := json_object_t();

    if p_flgslip = 'A' then
      p_flgslip := null;
    end if;

    for r1 in c1 loop
      v_exist := true;
    end loop;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSINCEXP');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;

    if p_codcomp is null then
       begin
        select  hcm_util.get_codcomp_level(codcomp,1)
           into v_codcompy
           from temploy1
          where codempid = p_codempid;
       exception when no_data_found then
        v_codcompy := null;
       end;
    else
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    end if;

    begin
      select codslip, desslipe, desslipt, desslip3, desslip4,
              desslip5, typscan, flgaccinc, flgacctax, flgaccpf, flgaccsoc,
              flgothpy, flgqtywk, flgvacat, flgot, flgotlb, rteot1, rteot2,
              rteot3, rteot4, rteot5,
              codinc1,codinc2,codinc3,codinc4,codinc5,codinc6,codinc7,codinc8,
              codinc9,codinc10,codinc11,codinc12,codinc13,codinc14,codinc15,codinc16,
              codded1,codded2,codded3,codded4,codded5,codded6,codded7,codded8,
              codded9,codded10,codded11,codded12,codded13,codded14,codded15,codded16,
              flginclb1,flginclb2,flginclb3,flginclb4,flginclb5,flginclb6,flginclb7,flginclb8,
              flginclb9,flginclb10,flginclb11,flginclb12,flginclb13,flginclb14,flginclb15,flginclb16,
              flgdedlb1,flgdedlb2,flgdedlb3,flgdedlb4,flgdedlb5,flgdedlb6,flgdedlb7,flgdedlb8,
              flgdedlb9,flgdedlb10,flgdedlb11,flgdedlb12,flgdedlb13,flgdedlb14,flgdedlb15,flgdedlb16
        into v_codslip, v_desslipe, v_desslipt, v_desslip3, v_desslip4,
             v_desslip5, v_typscan, v_flgaccinc, v_flgacctax, v_flgaccpf, v_flgaccsoc,
             v_flgothpy, v_flgqtywk, v_flgvacat, v_flgot, v_flgotlb, v_rteot1, v_rteot2,
             v_rteot3, v_rteot4, v_rteot5,
             v_codinc1,v_codinc2,v_codinc3,v_codinc4,v_codinc5,v_codinc6,v_codinc7,v_codinc8,
             v_codinc9,v_codinc10,v_codinc11,v_codinc12,v_codinc13,v_codinc14,v_codinc15,v_codinc16,
             v_codded1,v_codded2,v_codded3,v_codded4,v_codded5,v_codded6,v_codded7,v_codded8,
             v_codded9,v_codded10,v_codded11,v_codded12,v_codded13,v_codded14,v_codded15,v_codded16,
             v_flginclb1,v_flginclb2,v_flginclb3,v_flginclb4,v_flginclb5,v_flginclb6,v_flginclb7,v_flginclb8,
             v_flginclb9,v_flginclb10,v_flginclb11,v_flginclb12,v_flginclb13,v_flginclb14,v_flginclb15,v_flginclb16,
             v_flgdedlb1,v_flgdedlb2,v_flgdedlb3,v_flgdedlb4,v_flgdedlb5,v_flgdedlb6,v_flgdedlb7,v_flgdedlb8,
             v_flgdedlb9,v_flgdedlb10,v_flgdedlb11,v_flgdedlb12,v_flgdedlb13,v_flgdedlb14,v_flgdedlb15,v_flgdedlb16
        from tfrmslip
       where codslip = p_codslip;

    exception when no_data_found then
          v_desslip  := null;
          v_desslipe := null;
          v_desslipt := null;
          v_desslip3 := null;
          v_desslip4 := null;
          v_desslip5 := null;
          v_typscan  := null;
          v_flgaccinc:= null;
          v_flgacctax:= null;
          v_flgaccpf := null;
          v_flgaccsoc:= null;
          v_flgothpy := null;
          v_flgqtywk := null;
          v_flgvacat := null;
          v_flgot    := null;
          v_flgotlb  := null;
          v_rteot1   := null;
          v_rteot2   := null;
          v_rteot3   := null;
          v_rteot4   := null;
          v_rteot5   := null;

    end;

    v_count := 0;
    for r1 in c_tfrmslip2_1 loop
        v_count                 := v_count + 1;
        t_desinc(v_count)       := r1.codinc;
        t_flgdesinc(v_count)    := r1.flglabel;
    end loop;

    v_count := 0;
    for r1 in c_tfrmslip2_2 loop
        v_count                 := v_count + 1;
        t_desded(v_count)       := r1.codinc;
        t_flgdesded(v_count)    := r1.flglabel;
    end loop;
--    t_desinc(1) := null;
--    t_desinc(2) := null;
--    t_desinc(3) := null;
--    t_desinc(4) := null;
--    t_desinc(5) := null;
--    t_desinc(6) := null;
--    t_desinc(7) := null;
--    t_desinc(8) := null;
--    t_desinc(9) := null;
--    t_desinc(10) := null;
--    t_desinc(11) := null;
--    t_desinc(12) := null;
--    t_desinc(13) := null;
--    t_desinc(14) := null;
--    t_desinc(15) := null;
--    t_desinc(16) := null;
--    t_desded(1) := null;
--    t_desded(2) := null;
--    t_desded(3) := null;
--    t_desded(4) := null;
--    t_desded(5) := null;
--    t_desded(6) := null;
--    t_desded(7) := null;
--    t_desded(8) := null;
--    t_desded(9) := null;
--    t_desded(10) := null;
--    t_desded(11) := null;
--    t_desded(12) := null;
--    t_desded(13) := null;
--    t_desded(14) := null;
--    t_desded(15) := null;
--    t_desded(16) := null;

--    if v_codinc1 is not null then
--       t_desinc(1)      := v_codinc1;
--       t_flgdesinc(1)   := v_flginclb1;
--    end if;
--    if v_codinc2 is not null then
--       t_desinc(2)      := v_codinc2;
--       t_flgdesinc(2)   := v_flginclb2;
--    end if;
--    if v_codinc3 is not null then
--       t_desinc(3)      := v_codinc3;
--       t_flgdesinc(3)   := v_flginclb3;
--    end if;
--    if v_codinc4 is not null then
--       t_desinc(4)      := v_codinc4;
--       t_flgdesinc(4)   := v_flginclb4;
--    end if;
--    if v_codinc5 is not null then
--       t_desinc(5)      := v_codinc5;
--       t_flgdesinc(5)   := v_flginclb5;
--    end if;
--    if v_codinc6 is not null then
--       t_desinc(6)      := v_codinc6;
--       t_flgdesinc(6)   := v_flginclb6;
--    end if;
--    if v_codinc7 is not null then
--       t_desinc(7)      := v_codinc7;
--       t_flgdesinc(7)   := v_flginclb7;
--    end if;
--    if v_codinc8 is not null then
--       t_desinc(8)      := v_codinc8;
--       t_flgdesinc(8)   := v_flginclb8;
--    end if;
--    if v_codinc9 is not null then
--       t_desinc(9)      := v_codinc9;
--       t_flgdesinc(9)   := v_flginclb9;
--    end if;
--    if v_codinc10 is not null then
--       t_desinc(10)      := v_codinc10;
--       t_flgdesinc(10)   := v_flginclb10;
--    end if;
--    if v_codinc11 is not null then
--       t_desinc(11)      := v_codinc11;
--       t_flgdesinc(11)   := v_flginclb11;
--    end if;
--    if v_codinc12 is not null then
--       t_desinc(12)      := v_codinc12;
--       t_flgdesinc(12)   := v_flginclb12;
--    end if;
--    if v_codinc13 is not null then
--       t_desinc(13)      := v_codinc13;
--       t_flgdesinc(13)   := v_flginclb13;
--    end if;
--    if v_codinc14 is not null then
--       t_desinc(14)      := v_codinc14;
--       t_flgdesinc(14)   := v_flginclb14;
--    end if;
--    if v_codinc15 is not null then
--       t_desinc(15)      := v_codinc15;
--       t_flgdesinc(15)   := v_flginclb15;
--    end if;
--    if v_codinc16 is not null then
--       t_desinc(16)      := v_codinc16;
--       t_flgdesinc(16)   := v_flginclb16;
--    end if;
--
--    if v_codded1 is not null then
--       t_desded(1)      := v_codded1;
--       t_flgdesded(1)   := v_flgdedlb1;
--    end if;
--    if v_codded2 is not null then
--       t_desded(2)      := v_codded2;
--       t_flgdesded(2)   := v_flgdedlb2;
--    end if;
--    if v_codded3 is not null then
--       t_desded(3)      := v_codded3;
--       t_flgdesded(3)   := v_flgdedlb3;
--    end if;
--    if v_codded4 is not null then
--       t_desded(4)      := v_codded4;
--       t_flgdesded(4)   := v_flgdedlb4;
--    end if;
--    if v_codded5 is not null then
--       t_desded(5)      := v_codded5;
--       t_flgdesded(5)   := v_flgdedlb5;
--    end if;
--    if v_codded6 is not null then
--       t_desded(6)      := v_codded6;
--       t_flgdesded(6)   := v_flgdedlb6;
--    end if;
--    if v_codded7 is not null then
--       t_desded(7)      := v_codded7;
--       t_flgdesded(7)   := v_flgdedlb7;
--    end if;
--    if v_codded8 is not null then
--       t_desded(8)      := v_codded8;
--       t_flgdesded(8)   := v_flgdedlb8;
--    end if;
--    if v_codded9 is not null then
--       t_desded(9)      := v_codded9;
--       t_flgdesded(9)   := v_flgdedlb9;
--    end if;
--    if v_codded10 is not null then
--       t_desded(10)      := v_codded10;
--       t_flgdesded(10)   := v_flgdedlb10;
--    end if;
--    if v_codded11 is not null then
--       t_desded(11)      := v_codded11;
--       t_flgdesded(11)   := v_flgdedlb11;
--    end if;
--    if v_codded12 is not null then
--       t_desded(12)      := v_codded12;
--       t_flgdesded(12)   := v_flgdedlb12;
--    end if;
--    if v_codded13 is not null then
--       t_desded(13)      := v_codded13;
--       t_flgdesded(13)   := v_flgdedlb13;
--    end if;
--    if v_codded14 is not null then
--       t_desded(14)      := v_codded14;
--       t_flgdesded(14)   := v_flgdedlb14;
--    end if;
--    if v_codded15 is not null then
--       t_desded(15)      := v_codded15;
--       t_flgdesded(15)   := v_flgdedlb15;
--    end if;
--    if v_codded16 is not null then
--       t_desded(16)      := v_codded16;
--       t_flgdesded(16)   := v_flgdedlb16;
--    end if;

    if p_codempst is not null then
		v_flgempst := false;
        v_codempst := p_codempst;
	else
		v_flgempst := true;
	end if;

    for r1 in c1 loop
--      v_secur := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,global_v_codempid);

      v_flgsecu := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

      if v_flgsecu then
        v_permission := true;

        v_codempid := r1.codempid;
        p_codempid_temp := r1.codempid;
        if v_codempst is not null then
          if v_codempid = v_codempst then
            v_flgempst := true;
            v_codempst := null;
          else
            v_flgempst := false;
          end if;
        end if;

        if v_flgempst then

          	begin
              select 	numbank,codbank
              into 		v_numbank,v_codbank
              from 	 	ttaxcur
              where  	codempid  = v_codempid
              and     dteyrepay = p_dteyrepay
              and     dtemthpay = p_dtemthpay
              and     numperiod = p_numperiod ;
            exception when no_data_found then
              v_numbank := null;
              v_codbank := null;
            end;
            v_nambank := get_tcodec_name('TCODBANK',v_codbank,global_v_lang);

            -- Query Data in 1-4
              begin
                select sum(nvl(stddec(amtcal,codempid,v_chken),0) +
                           nvl(stddec(amtincl,codempid,v_chken),0) +
                           nvl(stddec(amtincc,codempid,v_chken),0) +
                           nvl(stddec(amtgrstx,codempid,v_chken),0)-
                           nvl(stddec(amtexpl,codempid,v_chken),0) -
                           nvl(stddec(amtexpc,codempid,v_chken),0)),
                           --user19 23/09/2016 add + amttaxoth
                       sum(nvl(stddec(amttax,codempid,v_chken),0)+ nvl(stddec(amttaxoth,codempid,v_chken),0)),
                       sum(nvl(stddec(amtsoca,codempid,v_chken),0)),
                       sum(nvl(stddec(amtprove,codempid,v_chken),0))
                 into v_amtcalt,v_amttax,v_amtsoc,v_amtpf
                 from ttaxcur
                where codempid = v_codempid
                  and dteyrepay = p_dteyrepay
                  and lpad(to_char(dtemthpay),2,'0')||lpad(to_char(numperiod),2,'0') <=
                      lpad(to_char(p_dtemthpay),2,'0')||lpad(to_char(p_numperiod),2,'0');
              exception when no_data_found then
                v_amtcalt := 0;
                v_amttax  := 0;
                v_amtsoc  := 0;
                v_amtpf   := 0;
              end;

              begin
                select nvl(sum(decode(typpay,4,-1*nvl(stddec(a.amtpay,a.codempid,v_chken),0),
                                             5,-1*nvl(stddec(a.amtpay,a.codempid,v_chken),0),
                                             6,-1*nvl(stddec(a.amtpay,a.codempid,v_chken),0),
                                                1*nvl(stddec(a.amtpay,a.codempid,v_chken),0))),0) amtpay
                  into v_amtpay
                  from tothpay a,tinexinf b
                 where a.codpay = b.codpay
                   and a.codempid = v_codempid
                   and a.numperiod  = p_numperiod
                   and a.dtemthpay  = p_dtemthpay
                   and a.dteyrepay  = p_dteyrepay;
              exception when no_data_found then
                 v_amtpay := 0;
              end;

            begin
               select dtepaymt,dteend,dtestrt
                 into v_dtepaymt,v_dteend,v_dtestrt
                 from tdtepay
                where codcompy = hcm_util.get_codcomp_level(r1.codcomp,'1')
                  and typpayroll = r1.typpayroll
                  and     dteyrepay = p_dteyrepay
              and     dtemthpay = p_dtemthpay
              and     numperiod = p_numperiod;
              exception when no_data_found then
                v_dtepaymt  := null;
                v_dteend    := null;
                v_dtestrt   := null;
              end;

              if p_dtepay is not null then
--                 v_dtepay := hcm_util.get_date_buddhist_era(p_dtepay);  -- 736
                 v_dtepay := hcm_util.get_date_config(p_dtepay);
              else
--                 v_dtepay  := hcm_util.get_date_buddhist_era(v_dtepaymt);  -- 736
                 v_dtepay  := hcm_util.get_date_config(v_dtepaymt);
              end if;

              -- Adisak 23/05/2023 16:38
              for r_tleavecd in c_tleavecd loop
                std_al.cycle_leave(hcm_util.get_codcomp_level(r1.codcomp,'1'),v_codempid, r_tleavecd.codleave,v_dteend,v_year,v_dtecycst,v_dtecycen);
                begin
                  select (nvl(sum(qtyvacat),0) - nvl(sum(qtydayle),0)) sum_qtyvacat
                    into v_sum_qtyvacat -- v_qtyvacat
                    from tleavsum
                   where codempid = v_codempid
                     and dteyear  = v_year
                     and staleave = 'V';
                exception when no_data_found then
                  v_sum_qtyvacat := 0;
                end;
                v_qtyvacat := v_qtyvacat + v_sum_qtyvacat;
              end loop;
              -- Adisak 23/05/2023 16:38

              	begin
                  select qtyavgwk
                    into p_qtyavgwk
                    from tcontral
                   where codcompy = hcm_util.get_codcomp_level(r1.codcomp,'1')
                     and dteeffec = (select max(dteeffec)
                                       from tcontral
                                      where codcompy = hcm_util.get_codcomp_level(r1.codcomp,'1')
                                        and dteeffec <= trunc(sysdate));
                exception when no_data_found then
                  p_qtyavgwk := null;
                end;

              v_hour := cal_dhm_concat(v_qtyvacat);

              v_numseq := 0;
              	for i in c_totsumd loop
                  v_numseq := v_numseq + 1;
                  v_qtysmot(v_numseq) :=  null;
                  cal_hm_concat(i.qtysmot,v_qtysmot1);
                  v_qtysmot(v_numseq) := v_qtysmot1;
                  v_rtesmot(v_numseq) := to_char(i.rtesmot,'fm99.0');
                end loop;
                	v_check := (v_numseq mod 2) ;
                  if v_check = 1 then
                    v_qtysmot(v_numseq+1) := null;
                    v_rtesmot(v_numseq+1)	:= null;
                  end if;


--                	v_dte_st :=  v_dtestrt;
--                  v_dte_en :=  v_dteend;

                   begin
                    select  unitcal1
                    into    v_unitcal1
                    from    tcontpmd
                    where   codempmt = r1.codempmt
                    and     codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                    and     dteeffec = (select max(dteeffec)
                                        from   tcontpmd
                                        where  dteeffec <= sysdate
                                        and    codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                        and    codempmt = r1.codempmt);
                   exception when no_data_found then
                    v_unitcal1 := null;
                   end;
                   if v_unitcal1 in ('M','Y') then
                    begin
                      select qtywork
                      into   v_qtywork
                      from   ttaxcur
                      where  codempid  = v_codempid
                      and		 dteyrepay = p_dteyrepay
                      and		 dtemthpay = p_dtemthpay
                      and 	 numperiod = p_numperiod;
                    exception when no_data_found then
                      v_qtywork := 0;
                    end;
                    if v_qtywork > 0 then
                      v_work := v_qtywork;
                    else
                      v_work := null;
                    end if;
                   else--กรณีไม่ใช่พนักงานรายเดือน
                    begin
                      select codincom1 into v_codwage
                        from tcontpms
                       where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                         and dteeffec = (select max(dteeffec)
                                           from tcontpms
                                          where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                            and dteeffec <= sysdate);
                    exception when no_data_found then
                      v_codwage := null;
                    end;

                     -- หายอดเงิน
                     begin
                      select  qtypayda,qtypayhr,qtypaysc
                      into		v_qtypayda,v_qtypayhr,v_qtypaysc
                      from    tothinc
                      where   codempid  = v_codempid
                      and			dteyrepay = p_dteyrepay
                      and			dtemthpay = p_dtemthpay
                      and 		numperiod = p_numperiod
                      and     codpay    = v_codwage;
                     exception when no_data_found then
                        v_qtypayda := 0;
                        v_qtypayhr := 0;
                        v_qtypaysc := 0;
                     end;
                     v_work := v_qtypayda||':'||v_qtypayhr||':'||v_qtypaysc;
                   end if;

                   	v_inc := 0;
                    v_ded := 0;
                    v_suminc := 0;
                    v_sumded := 0;
                    v_amtnet := 0;
                    v_amtnet_e := 0;

                    for i in 1..30 loop
                        v_desinc(i) := null;
                        v_amtinc(i) := null;
                        v_desded(i) := null;
                        v_amtded(i) := null;
                    end loop;

                    for rt in c_tsincexp loop
                      if nvl(rt.amtpay,0) <> 0 then
                        if substr(rt.typpayr,4,1) = '1' then
                           for i in 1..t_desinc.count loop
                              if t_desinc(i)  = rt.typpayr then
                                v_inc := v_inc + 1;
                                v_amtinc(v_inc) := rt.amtpay;
                                v_suminc   := v_suminc + rt.amtpay;
                                v_amtnet_e := v_amtnet_e + rt.amtpay_e;
                                if t_flgdesinc(i) = 'Y' then
                                  v_desinc(v_inc) := get_tcodec_name('tcodslip',t_desinc(i),global_v_lang);
                                else
                                  v_desinc(v_inc) := null;
                                end if;
                              end if;
                           end loop;
                        end if;
                      end if;
                    end loop;


                    for rt in c_tsincexp1 loop
                      if nvl(rt.amtpay,0) <> 0 then
                        if substr(rt.typpayr,4,1) = '1' then
                            v_amtinc(v_inc+1) := rt.amtpay;
                            v_amtothinc := v_amtothinc + rt.amtpay;
                            v_suminc   := v_suminc + rt.amtpay;
                            v_amtnet_e := v_amtnet_e + rt.amtpay_e;
                        end if;
                      end if;
                    end loop;

                    for rt in c_tsincexp loop
                      if nvl(rt.amtpay,0) <> 0 then
                        if substr(rt.typpayr,4,1) = '3' then
                           for i in 1..t_desded.count loop
                              if t_desded(i)  = rt.typpayr then
                                v_ded := v_ded + 1;
                                v_amtded(v_ded) := (rt.amtpay * -1);
                                v_sumded   := v_sumded + (rt.amtpay * -1);
                                v_amtnet_e := v_amtnet_e - (rt.amtpay_e * -1);
                                if t_flgdesded(i) = 'Y' then
                                  v_desded(v_ded) := get_tcodec_name('tcodslip',t_desded(i),global_v_lang);
                                else
                                  v_desded(v_ded) := null;
                                end if;
                              end if;
                           end loop;
                        end if;
                      end if;
                    end loop;

                    for rt in c_tsincexp1 loop
                      if nvl(rt.amtpay,0) <> 0 then
                        if substr(rt.typpayr,4,1) = '3' then
                            v_amtothed  := v_amtothed + (rt.amtpay * -1);
                            v_sumded    := v_sumded + (rt.amtpay * -1);
                            v_amtnet_e  := v_amtnet_e - (rt.amtpay_e * -1);
                          end if;
                      end if;
                    end loop;

                    -- sum inc and ded
                    v_suminc := v_suminc;
                    v_sumded := v_sumded;
                    v_amtnet := v_amtnet + (v_suminc - v_sumded);
                    v_amtnet_e := v_amtnet * get_exchange_rate(p_dteyrepay,
                                             p_dtemthpay,r1.codcurr_e, r1.codcurr);


                    begin
                      select stddec(amtnet,codempid,v_chken)
                        into v_amtnet
                        from ttaxcur
                       where codempid  = v_codempid
                         and dteyrepay = p_dteyrepay
                         and dtemthpay = p_dtemthpay
                         and numperiod = p_numperiod;
                    exception when no_data_found then
                      v_amtnet := 0;
                    end;
                    v_amtnet_e := v_amtnet * get_exchange_rate(p_dteyrepay,
                                             p_dtemthpay,r1.codcurr_e, r1.codcurr);

                    if nvl(v_amtothinc,0) = 0 then
                       v_amtothinc := null;
                       v_desc1 :=null;
                    else
                       v_inc := v_inc + 1;
                       v_amtinc(v_inc) := v_amtothinc;
                       v_desinc(v_inc) := get_label_name('HRPY57X',global_v_lang,150);
                    end if;
                    if nvl(v_amtothed,0) = 0 then
                      v_amtothed :=null;
                      v_desc2 :=null;
                    else
                      v_ded := v_ded + 1;
                      v_amtded(v_ded) := v_amtothed;
                      v_desded(v_ded) := get_label_name('HRPY57X',global_v_lang,150);
                    end if;

                    for i in 1..v_amtinc.count loop
                      if v_amtinc(i) is not null then
                          v_numx2 := v_numx2 +1;
                          insert_ttemprpt_items(v_numx2,'HRPY55X2',v_desinc(i),to_char(to_number(v_amtinc(i)),'fm999,999,999,990.00'),'');
                      end if;
                    end loop;


                    for i in 1..v_amtded.count loop
                      if v_amtded(i) is not null then
                          v_numx3 := v_numx3 +1;
                          insert_ttemprpt_items(v_numx3,'HRPY55X3',v_desded(i),to_char(to_number(v_amtded(i)),'fm999,999,999,990.00'),'');
                      end if;
                    end loop;

                   --<< wanlapa issue:#734 16/02/2023
                    if v_flgvacat = 'Y' then
                       v_numx4 := v_numx4 +1;
                       insert_ttemprpt_items(v_numx4,'HRPY55X4',get_label_name('HRPY55XC3',global_v_lang,'150'),v_hour,get_label_name('HRPY55XC3',global_v_lang,'170'));  
                    end if;

                    if v_flgqtywk = 'Y' then
                       v_numx4 := v_numx4 +1;
                       insert_ttemprpt_items(v_numx4,'HRPY55X4',get_label_name('HRPY55XC3',global_v_lang,'160'),v_work,get_label_name('HRPY55XC3',global_v_lang,'170'));  
                    end if;  
                    -->> wanlapa issue:#734 16/02/2023

                    	-- OT
                    if v_flgotlb = 'Y' then
                      if v_typscan = 0  then
                          for k in 1..v_numseq loop
                            if v_qtysmot(k) is not null then
                              v_numx4 := v_numx4 +1;
                              insert_ttemprpt_items(v_numx4,'HRPY55X4','O.T. '||v_rtesmot(k),v_qtysmot(k),get_label_name('HRPY55XC3',global_v_lang,140));
                            end if;
                          end loop;
                      else
                          obj_ot_col := json_object_t();
                          for row_ot in c_ot_col loop
                          v_tmp_qtysmot := '';
                            v_max_ot_col := v_max_ot_col + 1;
                            for k in 1..v_numseq loop
                                if v_qtysmot(k) is not null and v_rtesmot(k) = row_ot.rteotpay then
                                  v_numx4 := v_numx4 +1;
                                  v_tmp_qtysmot := v_qtysmot(k);
                                  insert_ttemprpt_items(v_max_ot_col,'HRPY55X4','O.T. '||row_ot.rteotpay,v_numx4,get_label_name('HRPY55XC3',global_v_lang,140));
                                end if;
                            end loop;
                          end loop;
                      end if;
                    end if;


                    if v_flgaccinc = 'N' then
                       v_amtcalt := null;
                    else
                      v_numx5 := v_numx5 + 1;
                      insert_ttemprpt_items(v_numx5,'HRPY55X5',get_label_name('HRPY55XC3',global_v_lang,'190'),to_char(to_number(v_amtcalt),'fm999,999,999,990.00'),get_label_name('HRPY55XC3',global_v_lang,'110'));
                    end if;
                    if v_flgacctax = 'N' then
                       v_amttax := null;
                    else
                      v_numx5 := v_numx5 + 1;
                      insert_ttemprpt_items(v_numx5,'HRPY55X5',get_label_name('HRPY55XC3',global_v_lang,'200'),to_char(to_number(v_amttax),'fm999,999,999,990.00'),get_label_name('HRPY55XC3',global_v_lang,'110'));
                    end if;
                    if v_flgaccpf  = 'N' then
                       v_amtpf := null;
                    else
                      v_numx5 := v_numx5 + 1;
                      insert_ttemprpt_items(v_numx5,'HRPY55X5',get_label_name('HRPY55XC3',global_v_lang,'210'),to_char(to_number(v_amtpf),'fm999,999,999,990.00'),get_label_name('HRPY55XC3',global_v_lang,'110'));
                    end if;
                    if v_flgaccsoc = 'N' then
                       v_amtsoc := null;
                    else
                      v_numx5 := v_numx5 + 1;
                      insert_ttemprpt_items(v_numx5,'HRPY55X5',get_label_name('HRPY55XC3',global_v_lang,'220'),to_char(to_number(v_amtsoc),'fm999,999,999,990.00'),get_label_name('HRPY55XC3',global_v_lang,'110'));
                    end if;
                    if v_flgothpy = 'N' then
                       v_amtpay := null;
                    else
                      v_numx5 := v_numx5 + 1;
                      insert_ttemprpt_items(v_numx5,'HRPY55X5',get_label_name('HRPY55XC3',global_v_lang,'230'),to_char(to_number(v_amtpay),'fm999,999,999,990.00'),get_label_name('HRPY55XC3',global_v_lang,'110'));
                    end if;
                    if v_flgvacat = 'N' then
                       v_hour 		:= null;
                    end if;
                    if v_flgqtywk = 'N' then
                       v_work 		:= null;
                    end if;

          v_rcnt      := v_rcnt+1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_codempid', r1.codempid ||' - '||get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
--          obj_data.put('dteyrepay', to_char(to_number(p_dteyrepay) + hcm_appsettings.get_additional_year));  -- 736
          obj_data.put('dteyrepay', hcm_util.get_year_config(p_dteyrepay));
          obj_data.put('dtemthpay', p_dtemthpay);
          obj_data.put('numperiod', p_numperiod);
          obj_data.put('numbank', v_numbank);
          obj_data.put('nambank', v_nambank);
          obj_data.put('dtepay', v_dtepay );
          obj_data.put('qtyvacat', v_hour);
          obj_data.put('qtyavgwk', v_work);
          obj_data.put('amtcalt', to_char(to_number(v_amtcalt),'fm999,999,999,990.00'));
          obj_data.put('amttax', to_char(to_number(v_amttax),'fm999,999,999,990.00'));
          obj_data.put('amtsoc', to_char(to_number(v_amtsoc),'fm999,999,999,990.00'));
          obj_data.put('amtpf', to_char(to_number(v_amtpf),'fm999,999,999,990.00'));
          obj_data.put('amtpay', to_char(to_number(v_amtpay),'fm999,999,999,990.00'));
          obj_data.put('suminc', to_char(to_number(v_suminc),'fm999,999,999,990.00'));
          obj_data.put('sumded', to_char(to_number(v_sumded),'fm999,999,999,990.00'));
          obj_data.put('amtnet', to_char(to_number(v_amtnet),'fm999,999,999,990.00'));
          obj_data.put('amtnet_e', to_char(to_number(v_amtnet_e),'fm999,999,999,990.00'));
          obj_data.put('dtetimeprint', to_char((sysdate+ 7/24),'dd/mm/yyyy HH24:MI:SS'));
--          obj_data.put('dtestrt', hcm_util.get_date_buddhist_era(v_dtestrt) || ' - ' || hcm_util.get_date_buddhist_era(v_dteend));  -- 736
          obj_data.put('dtestrt', hcm_util.get_date_config(v_dtestrt) || ' - ' || hcm_util.get_date_config(v_dteend));

--          obj_data.put('codempid', r1.codempid);
          insert_ttemprpt((v_rcnt),'HRPY55X1',obj_data);

        end if;
      end if;
    end loop;
    if not v_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;
    if param_msg_error is null then
       param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure insert_ttemprpt_items(v_numseq in number,r_codapp in varchar2, v_cod in varchar2, v_des in varchar2, v_unt in varchar2) is

    v_item1             ttemprpt.item1%type;
    v_item2             ttemprpt.item2%type;
    v_item3             ttemprpt.item3%type;    v_item21            ttemprpt.item21%type;
    v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;   v_item24            ttemprpt.item24%type;
    v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;   v_item27            ttemprpt.item27%type;
    v_item28            ttemprpt.item28%type;   v_item29            ttemprpt.item29%type;   v_item30            ttemprpt.item30%type;

  begin

    v_item1  := v_cod;
--    v_item2  := to_char(to_number(v_des),'fm999999999990.00');
    v_item2  := v_des;
    v_item3  := v_unt;
    v_item21 := nvl(p_numperiod,0);
    v_item22 := nvl(p_dtemthpay,0);
    v_item23 := nvl(p_dteyrepay,0);
    v_item24 := nvl(p_codslip,' ');
    v_item25 := nvl(p_codcomp,' ');
    v_item26 := nvl(p_codempid_temp,' ');
    v_item27 := nvl(p_typpayroll,' ');
    v_item28 := nvl(p_dtepay_temp,' ');
    v_item29 := nvl(p_codempst,' ');



    begin

      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2 ,item3, item21, item22, item23, item24,
            item25, item26, item27, item28, item29
          )
      values
          (
            global_v_codempid, r_codapp, v_numseq,
            v_item1,  v_item2, v_item3, v_item21, v_item22, v_item23, v_item24,
            v_item25, v_item26, v_item27, v_item28, v_item29
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_items;

  procedure insert_ttemprpt(v_numseq in number,r_codapp in varchar2, obj_data in json_object_t) is

    v_item1             ttemprpt.item1%type;    v_item2             ttemprpt.item2%type;    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;    v_item5             ttemprpt.item5%type;    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;    v_item8             ttemprpt.item8%type;    v_item9             ttemprpt.item9%type;
    v_item10            ttemprpt.item10%type;   v_item11            ttemprpt.item11%type;   v_item12            ttemprpt.item12%type;
    v_item13            ttemprpt.item13%type;   v_item14            ttemprpt.item14%type;   v_item15            ttemprpt.item15%type;
    v_item16            ttemprpt.item16%type;   v_item17            ttemprpt.item17%type;   v_item18            ttemprpt.item18%type;
    v_item19            ttemprpt.item19%type;   v_item20            ttemprpt.item20%type;   v_item21            ttemprpt.item21%type;
    v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;   v_item24            ttemprpt.item24%type;
    v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;   v_item27            ttemprpt.item27%type;
    v_item28            ttemprpt.item28%type;   v_item29            ttemprpt.item29%type;   v_item30            ttemprpt.item30%type;
    v_item31            ttemprpt.item31%type;
    v_temp varchar(10 char) := '';

  begin

    v_item1  := hcm_util.get_string_t(obj_data, 'desc_codempid');
    v_item2  := hcm_util.get_string_t(obj_data, 'desc_codcomp');
    v_item3  := hcm_util.get_string_t(obj_data, 'numperiod');
    v_item4  := hcm_util.get_string_t(obj_data, 'dtemthpay');
    v_item5  := hcm_util.get_string_t(obj_data, 'dteyrepay');
    v_item6  := hcm_util.get_string_t(obj_data, 'numbank');
    v_item7  := hcm_util.get_string_t(obj_data, 'nambank');
    v_item8  := hcm_util.get_string_t(obj_data, 'dtepay');
    v_item9  := hcm_util.get_string_t(obj_data, 'qtyvacat');
    v_item10 := hcm_util.get_string_t(obj_data, 'qtyavgwk');
    v_item11 := hcm_util.get_string_t(obj_data, 'amtcalt');
    v_item12 := hcm_util.get_string_t(obj_data, 'amttax');
    v_item13 := hcm_util.get_string_t(obj_data, 'amtpf');
    v_item14 := hcm_util.get_string_t(obj_data, 'amtsoc');
    v_item15 := hcm_util.get_string_t(obj_data, 'amtpay');
    v_item16 := hcm_util.get_string_t(obj_data, 'suminc');
    v_item17 := hcm_util.get_string_t(obj_data, 'sumded');
    v_item18 := hcm_util.get_string_t(obj_data, 'amtnet');
    v_item19 := hcm_util.get_string_t(obj_data, 'amtnet_e');
    v_item20 := hcm_util.get_string_t(obj_data, 'dtetimeprint');
    v_item21 := nvl(p_numperiod,0);
    v_item22 := nvl(p_dtemthpay,0);
    v_item23 := nvl(p_dteyrepay,0);
    v_item24 := nvl(p_codslip,' ');
    v_item25 := nvl(p_codcomp,' ');
    v_item26 := nvl(p_codempid_temp,' ');
    v_item27 := nvl(p_typpayroll,' ');
    v_item28 := nvl(p_dtepay_temp,' ');
    v_item29 := nvl(p_codempst,' ');
    v_item30 := hcm_util.get_string_t(obj_data, 'dtestrt');

    begin

      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6,
            item7,  item8,  item9,  item10, item11, item12,
            item13, item14, item15, item16, item17, item18,
            item19, item20, item21, item22, item23, item24,
            item25, item26, item27, item28, item29, item30
          )
      values
          (
            global_v_codempid, r_codapp, v_numseq,
            v_item1,  v_item2,  v_item3,  get_nammthful(v_item4, global_v_lang),  v_item5,  v_item6,
            v_item7,  v_item8,  v_item9,  v_item10, v_item11, v_item12,
            v_item13, v_item14, v_item15, v_item16, v_item17, v_item18,
            v_item19, v_item20, v_item21, v_item22, v_item23, v_item24,
            v_item25, v_item26, v_item27, v_item28, v_item29, v_item30
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt;
--
  PROCEDURE CAL_HM_CONCAT
    (p_qtymin	in  number,
     p_hm			out varchar2)
  IS
    v_min 	number(2);
    v_hour  number(5);
  begin
    if p_qtymin is not null and p_qtymin > 0 then
      v_hour	:= trunc(p_qtymin / 60,0);
      v_min		:= mod(p_qtymin,60);
      p_hm   := to_char(v_hour)||':'||lpad(to_char(v_min),2,'0');
    else
      p_hm := null;
    end if;
  end;

  function cal_dhm_concat (p_qtyday		in  number) RETURN varchar2 IS
    v_min 	number(2);
    v_hour  number(2);
    v_day   number;
    v_num   number;
    v_dhm	varchar2(4000 char); --<< Apisit || 25/03/2024 || # 1816 || https://hrmsd.peopleplus.co.th:4449/redmine/attachments/4110
  begin
    if p_qtyday is not null and p_qtyday > 0 then
      v_day		:= trunc(p_qtyday / 1);
      v_num 	:= round(mod((p_qtyday * p_qtyavgwk),p_qtyavgwk),0);
      v_hour	:= trunc(v_num / 60);
      v_min		:= mod(v_num,60);
      v_dhm   := to_char(v_day)||':'||
                 lpad(to_char(v_hour),2,'0')||':'||
                 lpad(to_char(v_min),2,'0');
    else
      v_dhm := null;
    end if;
    return(v_dhm);
  end;
  procedure gen_detail(json_str_output out clob) as
    obj_row      json_object_t;
--    v_flg        varchar2(100 char);
    v_codslip    varchar2(4 char);
    v_desslip    varchar2(150 char);
    v_desslipe   varchar2(150 char);
    v_desslipt   varchar2(150 char);
    v_desslip3   varchar2(150 char);
    v_desslip4   varchar2(150 char);
    v_desslip5   varchar2(150 char);
    v_typscan    number(3,2);
    v_flgaccinc  varchar2(1 char);
    v_flgacctax  varchar2(1 char);
    v_flgaccpf   varchar2(1 char);
    v_flgaccsoc  varchar2(1 char);
    v_flgothpy   varchar2(1 char);
    v_flgqtywk   varchar2(1 char);
    v_flgvacat   varchar2(1 char);
    v_flgot      varchar2(1 char);
    v_flgotlb    varchar2(1 char);
    v_rteot1     number(3,2);
    v_rteot2     number(3,2);
    v_rteot3     number(3,2);
    v_rteot4     number(3,2);
    v_rteot5     number(3,2);
  begin
    begin
      select codslip, desslipe, desslipt, desslip3, desslip4,
              desslip5, typscan, flgaccinc, flgacctax, flgaccpf, flgaccsoc,
              flgothpy, flgqtywk, flgvacat, flgot, flgotlb, rteot1, rteot2,
              rteot3, rteot4, rteot5
        into v_codslip, v_desslipe, v_desslipt, v_desslip3, v_desslip4,
             v_desslip5, v_typscan, v_flgaccinc, v_flgacctax, v_flgaccpf, v_flgaccsoc,
             v_flgothpy, v_flgqtywk, v_flgvacat, v_flgot, v_flgotlb, v_rteot1, v_rteot2,
             v_rteot3, v_rteot4, v_rteot5
        from tfrmslip
       where codslip = p_codslip;

    exception when no_data_found then
          v_desslip  := null;
          v_desslipe := null;
          v_desslipt := null;
          v_desslip3 := null;
          v_desslip4 := null;
          v_desslip5 := null;
          v_typscan  := null;
          v_flgaccinc:= null;
          v_flgacctax:= null;
          v_flgaccpf := null;
          v_flgaccsoc:= null;
          v_flgothpy := null;
          v_flgqtywk := null;
          v_flgvacat := null;
          v_flgot    := null;
          v_flgotlb  := null;
          v_rteot1   := null;
          v_rteot2   := null;
          v_rteot3   := null;
          v_rteot4   := null;
          v_rteot5   := null;
    end;
--
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codslip',p_codslip);
    obj_row.put('desslip',get_tfrmslip_name(p_codslip,global_v_lang));
    obj_row.put('desslipe',get_tfrmslip_name(p_codslip,101));
    obj_row.put('desslipt',get_tfrmslip_name(p_codslip,102));
    obj_row.put('desslip3',get_tfrmslip_name(p_codslip,103));
    obj_row.put('desslip4',get_tfrmslip_name(p_codslip,104));
    obj_row.put('desslip5',get_tfrmslip_name(p_codslip,105));
    obj_row.put('typscan', v_typscan);
    obj_row.put('flgaccinc', get_flg(v_flgaccinc));
    obj_row.put('flgacctax', get_flg(v_flgacctax));
    obj_row.put('flgaccpf', get_flg(v_flgaccpf));
    obj_row.put('flgaccsoc', get_flg(v_flgaccsoc));
    obj_row.put('flgothpy', get_flg(v_flgothpy));
    obj_row.put('flgqtywk', get_flg(v_flgqtywk));
    obj_row.put('flgvacat', get_flg(v_flgvacat));
    obj_row.put('flgot', get_flg(v_flgot));
    obj_row.put('flgotlb', get_flg(v_flgotlb));
    obj_row.put('rteot1', v_rteot1);
    obj_row.put('rteot2', v_rteot2);
    obj_row.put('rteot3', v_rteot3);
    obj_row.put('rteot4', v_rteot4);
    obj_row.put('rteot5', v_rteot5);
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab1;

  procedure gen_detail_tab1(json_str_output out clob) as
    obj_row        json_object_t;
    obj_data       json_object_t;
    v_codinc1      varchar2(4 char);
    v_codinc2      varchar2(4 char);
    v_codinc3      varchar2(4 char);
    v_codinc4      varchar2(4 char);
    v_codinc5      varchar2(4 char);
    v_codinc6      varchar2(4 char);
    v_codinc7      varchar2(4 char);
    v_codinc8      varchar2(4 char);
    v_codinc9      varchar2(4 char);
    v_codinc10     varchar2(4 char);
    v_codinc11     varchar2(4 char);
    v_codinc12     varchar2(4 char);
    v_codinc13     varchar2(4 char);
    v_codinc14     varchar2(4 char);
    v_codinc15     varchar2(4 char);
    v_codinc16     varchar2(4 char);
    v_flginclb1    varchar2(1 char);
    v_flginclb2    varchar2(1 char);
    v_flginclb3    varchar2(1 char);
    v_flginclb4    varchar2(1 char);
    v_flginclb5    varchar2(1 char);
    v_flginclb6    varchar2(1 char);
    v_flginclb7    varchar2(1 char);
    v_flginclb8    varchar2(1 char);
    v_flginclb9    varchar2(1 char);
    v_flginclb10   varchar2(1 char);
    v_flginclb11   varchar2(1 char);
    v_flginclb12   varchar2(1 char);
    v_flginclb13   varchar2(1 char);
    v_flginclb14   varchar2(1 char);
    v_flginclb15   varchar2(1 char);
    v_flginclb16   varchar2(1 char);
    v_rcnt         number := 0;

    cursor c1 is
        select *
          from tfrmslip2
         where codslip = p_codslip
           and typpay = 1
      order by numseq ;
  begin
--    begin
--      select  codinc1, codinc2, codinc3, codinc4, codinc5, codinc6,
--              codinc7, codinc8, codinc9, codinc10, codinc11, codinc12,
--              codinc13, codinc14, codinc15, codinc16, flginclb1, flginclb2,
--              flginclb3, flginclb4, flginclb5, flginclb6, flginclb7, flginclb8,
--              flginclb9, flginclb10, flginclb11, flginclb12, flginclb13, flginclb14,
--              flginclb15, flginclb16
--        into  v_codinc1, v_codinc2, v_codinc3, v_codinc4, v_codinc5, v_codinc6, v_codinc7,
--              v_codinc8, v_codinc9, v_codinc10, v_codinc11, v_codinc12, v_codinc13, v_codinc14,
--              v_codinc15, v_codinc16, v_flginclb1, v_flginclb2, v_flginclb3, v_flginclb4,
--              v_flginclb5, v_flginclb6, v_flginclb7, v_flginclb8, v_flginclb9, v_flginclb10,
--              v_flginclb11, v_flginclb12, v_flginclb13, v_flginclb14, v_flginclb15, v_flginclb16
--        from tfrmslip
--       where codslip = p_codslip;
--    exception when no_data_found then
--            v_codinc1      := null;
--            v_codinc2      := null;
--            v_codinc3      := null;
--            v_codinc4      := null;
--            v_codinc5      := null;
--            v_codinc6      := null;
--            v_codinc7      := null;
--            v_codinc8      := null;
--            v_codinc9      := null;
--            v_codinc10     := null;
--            v_codinc11     := null;
--            v_codinc12     := null;
--            v_codinc13     := null;
--            v_codinc14     := null;
--            v_codinc15     := null;
--            v_codinc16     := null;
--            v_flginclb1    := null;
--            v_flginclb2    := null;
--            v_flginclb3    := null;
--            v_flginclb4    := null;
--            v_flginclb5    := null;
--            v_flginclb6    := null;
--            v_flginclb7    := null;
--            v_flginclb8    := null;
--            v_flginclb9    := null;
--            v_flginclb10   := null;
--            v_flginclb11   := null;
--            v_flginclb12   := null;
--            v_flginclb13   := null;
--            v_flginclb14   := null;
--            v_flginclb15   := null;
--            v_flginclb16   := null;
--    end;
--
        obj_row := json_object_t();

        for r1 in c1 loop
            v_rcnt := v_rcnt + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codinc', r1.codinc);
            obj_data.put('flginclb', get_flg(r1.flglabel));
            obj_data.put('flgEdit', true);
            obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;
--          if v_codinc1 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc1);
--            obj_data.put('flginclb', get_flg(v_flginclb1));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc2 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc2);
--            obj_data.put('flginclb', get_flg(v_flginclb2));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc3 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc3);
--            obj_data.put('flginclb', get_flg(v_flginclb3));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc4 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc4);
--            obj_data.put('flginclb', get_flg(v_flginclb4));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc5 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc5);
--            obj_data.put('flginclb', get_flg(v_flginclb5));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc6 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc6);
--            obj_data.put('flginclb', get_flg(v_flginclb6));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc7 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc7);
--            obj_data.put('flginclb', get_flg(v_flginclb7));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc8 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc8);
--            obj_data.put('flginclb', get_flg(v_flginclb8));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc9 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc9);
--            obj_data.put('flginclb', get_flg(v_flginclb9));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc10 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc10);
--            obj_data.put('flginclb', get_flg(v_flginclb10));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc11 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc11);
--            obj_data.put('flginclb', get_flg(v_flginclb11));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc12 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc12);
--            obj_data.put('flginclb', get_flg(v_flginclb12));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc13 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc13);
--            obj_data.put('flginclb', get_flg(v_flginclb13));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc14 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc14);
--            obj_data.put('flginclb', get_flg(v_flginclb14));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc15 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc15);
--            obj_data.put('flginclb', get_flg(v_flginclb15));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codinc16 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codinc', v_codinc16);
--            obj_data.put('flginclb', get_flg(v_flginclb16));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;


    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab2;

  procedure gen_detail_tab2(json_str_output out clob) as
    obj_row        json_object_t;
    obj_data       json_object_t;
    v_codded1      varchar2(4 char);
    v_codded2      varchar2(4 char);
    v_codded3      varchar2(4 char);
    v_codded4      varchar2(4 char);
    v_codded5      varchar2(4 char);
    v_codded6      varchar2(4 char);
    v_codded7      varchar2(4 char);
    v_codded8      varchar2(4 char);
    v_codded9      varchar2(4 char);
    v_codded10     varchar2(4 char);
    v_codded11     varchar2(4 char);
    v_codded12     varchar2(4 char);
    v_codded13     varchar2(4 char);
    v_codded14     varchar2(4 char);
    v_codded15     varchar2(4 char);
    v_codded16     varchar2(4 char);
    v_flgdedlb1    varchar2(1 char);
    v_flgdedlb2    varchar2(1 char);
    v_flgdedlb3    varchar2(1 char);
    v_flgdedlb4    varchar2(1 char);
    v_flgdedlb5    varchar2(1 char);
    v_flgdedlb6    varchar2(1 char);
    v_flgdedlb7    varchar2(1 char);
    v_flgdedlb8    varchar2(1 char);
    v_flgdedlb9    varchar2(1 char);
    v_flgdedlb10   varchar2(1 char);
    v_flgdedlb11   varchar2(1 char);
    v_flgdedlb12   varchar2(1 char);
    v_flgdedlb13   varchar2(1 char);
    v_flgdedlb14   varchar2(1 char);
    v_flgdedlb15   varchar2(1 char);
    v_flgdedlb16   varchar2(1 char);
    v_rcnt         number := 0;

    cursor c1 is
        select *
          from tfrmslip2
         where codslip = p_codslip
           and typpay = 2
      order by numseq ;
  begin
--    begin
--      select codded1, codded2, codded3, codded4, codded5, codded6,
--             codded7, codded8, codded9, codded10, codded11, codded12,
--             codded13, codded14, codded15, codded16, flgdedlb1,
--             flgdedlb2, flgdedlb3, flgdedlb4, flgdedlb5, flgdedlb6,
--             flgdedlb7, flgdedlb8, flgdedlb9, flgdedlb10, flgdedlb11,
--             flgdedlb12, flgdedlb13, flgdedlb14, flgdedlb15, flgdedlb16
--        into v_codded1, v_codded2, v_codded3, v_codded4, v_codded5, v_codded6,
--             v_codded7, v_codded8, v_codded9, v_codded10, v_codded11, v_codded12,
--             v_codded13, v_codded14, v_codded15, v_codded16, v_flgdedlb1, v_flgdedlb2,
--             v_flgdedlb3, v_flgdedlb4, v_flgdedlb5, v_flgdedlb6, v_flgdedlb7, v_flgdedlb8,
--             v_flgdedlb9, v_flgdedlb10, v_flgdedlb11, v_flgdedlb12, v_flgdedlb13,
--             v_flgdedlb14, v_flgdedlb15, v_flgdedlb16
--        from tfrmslip
--       where codslip = p_codslip;
--    exception when no_data_found then
--          v_codded1      := null;
--          v_codded2      := null;
--          v_codded3      := null;
--          v_codded4      := null;
--          v_codded5      := null;
--          v_codded6      := null;
--          v_codded7      := null;
--          v_codded8      := null;
--          v_codded9      := null;
--          v_codded10     := null;
--          v_codded11     := null;
--          v_codded12     := null;
--          v_codded13     := null;
--          v_codded14     := null;
--          v_codded15     := null;
--          v_codded16     := null;
--          v_flgdedlb1    := null;
--          v_flgdedlb2    := null;
--          v_flgdedlb3    := null;
--          v_flgdedlb4    := null;
--          v_flgdedlb5    := null;
--          v_flgdedlb6    := null;
--          v_flgdedlb7    := null;
--          v_flgdedlb8    := null;
--          v_flgdedlb9    := null;
--          v_flgdedlb10   := null;
--          v_flgdedlb11   := null;
--          v_flgdedlb12   := null;
--          v_flgdedlb13   := null;
--          v_flgdedlb14   := null;
--          v_flgdedlb15   := null;
--          v_flgdedlb16   := null;
--    end;

        obj_row := json_object_t();
        for r1 in c1 loop
            v_rcnt := v_rcnt + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codded', r1.codinc);
            obj_data.put('flgdedlb', get_flg(r1.flglabel));
            obj_data.put('flgEdit', true);
            obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;

--          if v_codded1 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded1);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb1));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded2 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded2);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb2));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded3 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded3);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb3));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded4 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded4);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb4));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded5 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded5);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb5));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded6 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded6);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb6));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded7 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded7);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb7));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded8 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded8);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb8));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded9 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded9);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb9));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded10 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded10);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb10));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded11 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded11);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb11));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded12 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded12);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb12));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded13 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded13);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb13));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded14 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded14);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb14));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded15 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded15);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb15));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;
--          if v_codded16 is not null then
--            v_rcnt := v_rcnt + 1;
--            obj_data := json_object_t();
--            obj_data.put('coderror', '200');
--            obj_data.put('codded', v_codded16);
--            obj_data.put('flgdedlb', get_flg(v_flgdedlb16));
--            obj_data.put('flgEdit', true);
--            obj_row.put(to_char(v_rcnt - 1), obj_data);
--          end if;


    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_dup_rteot(v_rteot1 in number, v_rteot2 in number, v_rteot3 in number, v_rteot4 in number, v_rteot5 in number) as
    type rteot IS TABLE OF number;
    orig rteot;
    tmp  rteot;
    begin
      orig := rteot(v_rteot1, v_rteot2, v_rteot3, v_rteot4, v_rteot5);
      tmp  := SET(orig);
      if (tmp.count <> orig.count) then
        param_msg_error := get_error_msg_php('HR1503',global_v_lang);
      end if;

  end;
--
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    countindex      number;
    v_flg           varchar2(1000);
    v_codinc        varchar2(4 char);
    v_codded        varchar2(4 char);
    v_flginclb      varchar2(1 char);
    v_flgdedlb      varchar2(1 char);
    v_codslip       varchar2(4 char);
    v_desslip       varchar2(150 char);
    v_desslipe      varchar2(150 char);
    v_desslipt      varchar2(150 char);
    v_desslip3      varchar2(150 char);
    v_desslip4      varchar2(150 char);
    v_desslip5      varchar2(150 char);
    v_flgotlb       varchar2(1 char);
    v_rteot1        number;
    v_rteot2        number;
    v_rteot3        number;
    v_rteot4        number;
    v_rteot5        number;
    v_typscan       number;
    v_flgothpy      varchar2(1 char);
    v_flgaccinc     varchar2(1 char);
    v_flgacctax     varchar2(1 char);
    v_flgaccpf      varchar2(1 char);
    v_flgaccsoc     varchar2(1 char);
    v_flgvacat      varchar2(1 char);
    v_flgot         varchar2(1 char);
    v_flgqtywk      varchar2(1 char);
    v_flgdefault    varchar2(1 char);
    v_codinco       tfrmslip2.codinc%type;
    v_coddedo       tfrmslip2.codinc%type;
    v_codinc1       varchar2(4 char);
    v_codinc2       varchar2(4 char);
    v_codinc3       varchar2(4 char);
    v_codinc4       varchar2(4 char);
    v_codinc5       varchar2(4 char);
    v_codinc6       varchar2(4 char);
    v_codinc7       varchar2(4 char);
    v_codinc8       varchar2(4 char);
    v_codinc9       varchar2(4 char);
    v_codinc10      varchar2(4 char);
    v_codinc11      varchar2(4 char);
    v_codinc12      varchar2(4 char);
    v_codinc13      varchar2(4 char);
    v_codinc14      varchar2(4 char);
    v_codinc15      varchar2(4 char);
    v_codinc16      varchar2(4 char);
    v_codded1       varchar2(4 char);
    v_codded2       varchar2(4 char);
    v_codded3       varchar2(4 char);
    v_codded4       varchar2(4 char);
    v_codded5       varchar2(4 char);
    v_codded6       varchar2(4 char);
    v_codded7       varchar2(4 char);
    v_codded8       varchar2(4 char);
    v_codded9       varchar2(4 char);
    v_codded10      varchar2(4 char);
    v_codded11      varchar2(4 char);
    v_codded12      varchar2(4 char);
    v_codded13      varchar2(4 char);
    v_codded14      varchar2(4 char);
    v_codded15      varchar2(4 char);
    v_codded16      varchar2(4 char);
    v_flginclb1     varchar2(1 char);
    v_flginclb2     varchar2(1 char);
    v_flginclb3     varchar2(1 char);
    v_flginclb4     varchar2(1 char);
    v_flginclb5     varchar2(1 char);
    v_flginclb6     varchar2(1 char);
    v_flginclb7     varchar2(1 char);
    v_flginclb8     varchar2(1 char);
    v_flginclb9     varchar2(1 char);
    v_flginclb10    varchar2(1 char);
    v_flginclb11    varchar2(1 char);
    v_flginclb12    varchar2(1 char);
    v_flginclb13    varchar2(1 char);
    v_flginclb14    varchar2(1 char);
    v_flginclb15    varchar2(1 char);
    v_flginclb16    varchar2(1 char);
    v_flgdedlb1     varchar2(1 char);
    v_flgdedlb2     varchar2(1 char);
    v_flgdedlb3     varchar2(1 char);
    v_flgdedlb4     varchar2(1 char);
    v_flgdedlb5     varchar2(1 char);
    v_flgdedlb6     varchar2(1 char);
    v_flgdedlb7     varchar2(1 char);
    v_flgdedlb8     varchar2(1 char);
    v_flgdedlb9     varchar2(1 char);
    v_flgdedlb10    varchar2(1 char);
    v_flgdedlb11    varchar2(1 char);
    v_flgdedlb12    varchar2(1 char);
    v_flgdedlb13    varchar2(1 char);
    v_flgdedlb14    varchar2(1 char);
    v_flgdedlb15    varchar2(1 char);
    v_flgdedlb16    varchar2(1 char);
    json_obj        json_object_t;

    v_numseq        number;
  begin

    initial_value(json_str_input);

    json_obj        := json_object_t(json_str_input);
    v_desslip       := hcm_util.get_string_t(json_obj,'p_desslip');
    v_desslipe      := hcm_util.get_string_t(json_obj,'p_desslipe');
    v_desslipt      := hcm_util.get_string_t(json_obj,'p_desslipt');
    v_desslip3      := hcm_util.get_string_t(json_obj,'p_desslip3');
    v_desslip4      := hcm_util.get_string_t(json_obj,'p_desslip4');
    v_desslip5      := hcm_util.get_string_t(json_obj,'p_desslip5');
    v_rteot1        :=  hcm_util.get_string_t(json_obj,'p_rteot1');
    v_rteot2        :=  hcm_util.get_string_t(json_obj,'p_rteot2');
    v_rteot3        :=  hcm_util.get_string_t(json_obj,'p_rteot3');
    v_rteot4        :=  hcm_util.get_string_t(json_obj,'p_rteot4');
    v_rteot5        :=  hcm_util.get_string_t(json_obj,'p_rteot5');
    v_typscan       :=  hcm_util.get_string_t(json_obj,'p_typscan');
    v_flgotlb       :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgotlb'));
    v_flgothpy      :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgothpy'));
    v_flgaccinc     :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgaccinc'));
    v_flgacctax     :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgacctax'));
    v_flgaccpf      :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgaccpf'));
    v_flgaccsoc     :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgaccsoc'));
    v_flgvacat      :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgvacat'));
    v_flgot         :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgot'));
    v_flgqtywk      :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgqtywk'));
    v_flgdefault    :=  save_flg_detail(hcm_util.get_string_t(json_obj,'p_flgdefault'));
    param_json      := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str'));
    p_tab1          := hcm_util.get_json_t(param_json, 'tab1');
    p_tab2          := hcm_util.get_json_t(param_json, 'tab2');
--    check_dup_rteot(v_rteot1, v_rteot2, v_rteot3, v_rteot4, v_rteot5);

    if param_msg_error is null then
    --tab1--
      countindex := 0;
      delete tfrmslip2
       where codslip = p_codslip
         and typpay = 1;
      for i in 0..p_tab1.get_size - 1 loop
        if hcm_util.get_json_t(p_tab1, to_char(i)).get_size > 0 then
          param_json_row:= json_object_t(hcm_util.get_json_t(p_tab1, to_char(i)));
          v_codinc      := hcm_util.get_string_t(param_json_row, 'codinc');
          v_codinco     := hcm_util.get_string_t(param_json_row, 'codincOld');
          v_flg         := hcm_util.get_string_t(param_json_row, 'flg');
          v_flginclb    := save_flg_table(hcm_util.get_boolean_t(param_json_row, 'flginclb'));

          check_lov_codpay(v_codinc);

          if v_flg in ('add' , 'edit') then
            begin
                begin
                    select nvl(max(numseq),0)
                      into v_numseq
                      from tfrmslip2
                     where codslip = p_codslip
                       and typpay = 1;
                exception when others then
                    v_numseq := 0;
                end;

                v_numseq := v_numseq + 1 ;

                insert into tfrmslip2 (codslip,typpay,numseq,codinc,flglabel,dteupd,coduser)
                values (p_codslip,1,v_numseq,v_codinc,v_flginclb,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tfrmslip2
                   set codinc = v_codinc,
                       flglabel = v_flginclb,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codslip = p_codslip
                   and typpay = 1
                   and codinc = v_codinco;
            end;
          else
            delete tfrmslip2
             where codslip = p_codslip
               and typpay = 1
               and codinc = v_codinco;
          end if;
        end if;
      end loop;
      --tab2--
      countindex := 0;


      delete tfrmslip2
       where codslip = p_codslip
         and typpay = 2;

      for i in 0..p_tab2.get_size - 1 loop
        if hcm_util.get_json_t(p_tab2, to_char(i)).get_size > 0 then
          param_json_row := json_object_t(hcm_util.get_json_t(p_tab2, to_char(i)));
          v_codded       := hcm_util.get_string_t(param_json_row, 'codded');
          v_coddedo       := hcm_util.get_string_t(param_json_row, 'coddedOld');
          v_flg          := hcm_util.get_string_t(param_json_row, 'flg');
          v_flgdedlb     := save_flg_table(hcm_util.get_boolean_t(param_json_row, 'flgdedlb'));
          check_lov_codpay(v_codded);
          if v_flg in ('add' , 'edit') then
            begin
                begin
                    select nvl(max(numseq),0)
                      into v_numseq
                      from tfrmslip2
                     where codslip = p_codslip
                       and typpay = 2;
                exception when others then
                    v_numseq := 0;
                end;

                v_numseq := v_numseq + 1 ;

                insert into tfrmslip2 (codslip,typpay,numseq,codinc,flglabel,dteupd,coduser)
                values (p_codslip,2,v_numseq,v_codded,v_flgdedlb,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tfrmslip2
                   set codinc = v_codded,
                       flglabel = v_flgdedlb,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codslip = p_codslip
                   and typpay = 2
                   and codinc = v_coddedo;
            end;
          else
            delete tfrmslip2
             where codslip = p_codslip
               and typpay = 2
               and codinc = v_coddedo;
          end if;
        end if;
      end loop;

--      for i in 0..15 loop
--        if hcm_util.get_json_t(p_tab2, to_char(i)).get_size > 0 then
--          param_json_row := json_object_t(hcm_util.get_json_t(p_tab2, to_char(i)));
--          v_codded       := hcm_util.get_string_t(param_json_row, 'codded');
--          v_flg          := hcm_util.get_string_t(param_json_row, 'flg');
--          v_flgdedlb     := save_flg_table(hcm_util.get_boolean_t(param_json_row, 'flgdedlb'));
--
--          check_lov_codpay(v_codded);
--          if v_flg in ('add' , 'edit') then
--            if countindex = 0 then
--              v_codded1   := v_codded;
--              v_flgdedlb1 := v_flgdedlb;
--            elsif countindex = 1 then
--              v_codded2   := v_codded;
--              v_flgdedlb2 := v_flgdedlb;
--            elsif countindex = 2 then
--              v_codded3   := v_codded;
--              v_flgdedlb3 := v_flgdedlb;
--            elsif countindex = 3 then
--              v_codded4   := v_codded;
--              v_flgdedlb4 := v_flgdedlb;
--            elsif countindex = 4 then
--              v_codded5   := v_codded;
--              v_flgdedlb5 := v_flgdedlb;
--            elsif countindex = 5 then
--              v_codded6   := v_codded;
--              v_flgdedlb6 := v_flgdedlb;
--            elsif countindex = 6 then
--              v_codded7   := v_codded;
--              v_flgdedlb7 := v_flgdedlb;
--            elsif countindex = 7 then
--              v_codded8   := v_codded;
--              v_flgdedlb8 := v_flgdedlb;
--            elsif countindex = 8 then
--              v_codded9   := v_codded;
--              v_flgdedlb9 := v_flgdedlb;
--            elsif countindex = 9 then
--              v_codded10   := v_codded;
--              v_flgdedlb10 := v_flgdedlb;
--            elsif countindex = 10 then
--              v_codded11   := v_codded;
--              v_flgdedlb11 := v_flgdedlb;
--            elsif countindex = 11 then
--              v_codded12   := v_codded;
--              v_flgdedlb12 := v_flgdedlb;
--            elsif countindex = 12 then
--              v_codded13   := v_codded;
--              v_flgdedlb13 := v_flgdedlb;
--            elsif countindex = 13 then
--              v_codded14   := v_codded;
--              v_flgdedlb14 := v_flgdedlb;
--            elsif countindex = 14 then
--              v_codded15   := v_codded;
--              v_flgdedlb15 := v_flgdedlb;
--             elsif countindex = 15 then
--              v_codded16   := v_codded;
--              v_flgdedlb16 := v_flgdedlb;
--            end if;
--            countindex := countindex + 1;
--          end if;
--        end if;
--      end loop;

      begin
        insert into tfrmslip (codslip, desslipe, desslipt, desslip3, desslip4, desslip5, codinc1,
                    codinc2, codinc3, codinc4, codinc5, codinc6, codinc7, codinc8,
                    codinc9, codinc10, codinc11, codinc12, codinc13, codinc14, codinc15,
                    codinc16, codded1, codded2, codded3, codded4, codded5, codded6, codded7,
                    codded8, codded9, codded10, codded11, codded12, codded13, codded14,
                    codded15, codded16, flgaccinc, flgacctax, flgaccpf, flgaccsoc, flgvacat,
                    flgot, flgqtywk, flgdefault, flginclb1, flginclb2, flginclb3, flginclb4,
                    flginclb5, flginclb6, flginclb7, flginclb8, flginclb9, flginclb10, flginclb11,
                    flginclb12, flginclb13, flginclb14, flginclb15, flginclb16, flgdedlb1,
                    flgdedlb2, flgdedlb3, flgdedlb4, flgdedlb5, flgdedlb6, flgdedlb7,
                    flgdedlb8, flgdedlb9, flgdedlb10, flgdedlb11, flgdedlb12, flgdedlb13,
                    flgdedlb14, flgdedlb15, flgdedlb16, flgotlb, rteot1, rteot2,
                    rteot3, rteot4, rteot5, typscan, flgothpy, dtecreate, codcreate, dteupd, coduser)

             values (p_codslip, v_desslipe, v_desslipt, v_desslip3, v_desslip4, v_desslip5, v_codinc1,
                    v_codinc2, v_codinc3, v_codinc4, v_codinc5, v_codinc6, v_codinc7,
                    v_codinc8, v_codinc9, v_codinc10, v_codinc11, v_codinc12, v_codinc13, v_codinc14,
                    v_codinc15, v_codinc16, v_codded1, v_codded2, v_codded3, v_codded4, v_codded5,
                    v_codded6, v_codded7, v_codded8, v_codded9, v_codded10, v_codded11, v_codded12,
                    v_codded13, v_codded14, v_codded15, v_codded16, v_flgaccinc, v_flgacctax,
                    v_flgaccpf, v_flgaccsoc, v_flgvacat, v_flgot, v_flgqtywk, v_flgdefault, v_flginclb1,
                    v_flginclb2, v_flginclb3, v_flginclb4, v_flginclb5, v_flginclb6, v_flginclb7,
                    v_flginclb8, v_flginclb9, v_flginclb10, v_flginclb11, v_flginclb12,
                    v_flginclb13, v_flginclb14, v_flginclb15, v_flginclb16, v_flgdedlb1, v_flgdedlb2,
                    v_flgdedlb3, v_flgdedlb4, v_flgdedlb5, v_flgdedlb6, v_flgdedlb7, v_flgdedlb8,
                    v_flgdedlb9, v_flgdedlb10, v_flgdedlb11, v_flgdedlb12, v_flgdedlb13, v_flgdedlb14,
                    v_flgdedlb15, v_flgdedlb16, v_flgotlb, v_rteot1, v_rteot2, v_rteot3,
                    v_rteot4, v_rteot5, v_typscan, v_flgothpy, sysdate, global_v_coduser, sysdate, global_v_coduser);

      exception when dup_val_on_index then
        update tfrmslip set desslipe  = v_desslipe,
                            desslipt  = v_desslipt,
                            desslip3  = v_desslip3,
                            desslip4  = v_desslip4,
                            desslip5  = v_desslip5,
                            typscan   = v_typscan,
                            codinc1   = v_codinc1,
                            codinc2   = v_codinc2,
                            codinc3   = v_codinc3,
                            codinc4   = v_codinc4,
                            codinc5   = v_codinc5,
                            codinc6   = v_codinc6,
                            codinc7   = v_codinc7,
                            codinc8   = v_codinc8,
                            codinc9   = v_codinc9,
                            codinc10   = v_codinc10,
                            codinc11   = v_codinc11,
                            codinc12   = v_codinc12,
                            codinc13   = v_codinc13,
                            codinc14   = v_codinc14,
                            codinc15   = v_codinc15,
                            codinc16   = v_codinc16,
                            codded1   = v_codded1,
                            codded2   = v_codded2,
                            codded3   = v_codded3,
                            codded4   = v_codded4,
                            codded5   = v_codded5,
                            codded6   = v_codded6,
                            codded7   = v_codded7,
                            codded8   = v_codded8,
                            codded9   = v_codded9,
                            codded10   = v_codded10,
                            codded11   = v_codded11,
                            codded12   = v_codded12,
                            codded13   = v_codded13,
                            codded14   = v_codded14,
                            codded15   = v_codded15,
                            codded16   = v_codded16,
                            flgaccinc   = v_flgaccinc,
                            flgacctax   = v_flgacctax,
                            flgaccpf   = v_flgaccpf,
                            flgaccsoc   = v_flgaccsoc,
                            flgvacat   = v_flgvacat,
                            flgot      = v_flgot,
                            flgqtywk   = v_flgqtywk,
                            flgdefault   = v_flgdefault,
                            flginclb1   = v_flginclb1,
                            flginclb2   = v_flginclb2,
                            flginclb3   = v_flginclb3,
                            flginclb4   = v_flginclb4,
                            flginclb5   = v_flginclb5,
                            flginclb6   = v_flginclb6,
                            flginclb7   = v_flginclb7,
                            flginclb8   = v_flginclb8,
                            flginclb9   = v_flginclb9,
                            flginclb10   = v_flginclb10,
                            flginclb11   = v_flginclb11,
                            flginclb12   = v_flginclb12,
                            flginclb13   = v_flginclb13,
                            flginclb14   = v_flginclb14,
                            flginclb15   = v_flginclb15,
                            flginclb16   = v_flginclb16,
                            flgdedlb1   = v_flgdedlb1,
                            flgdedlb2   = v_flgdedlb2,
                            flgdedlb3   = v_flgdedlb3,
                            flgdedlb4   = v_flgdedlb4,
                            flgdedlb5   = v_flgdedlb5,
                            flgdedlb6   = v_flgdedlb6,
                            flgdedlb7   = v_flgdedlb7,
                            flgdedlb8   = v_flgdedlb8,
                            flgdedlb9   = v_flgdedlb9,
                            flgdedlb10   = v_flgdedlb10,
                            flgdedlb11   = v_flgdedlb11,
                            flgdedlb12   = v_flgdedlb12,
                            flgdedlb13   = v_flgdedlb13,
                            flgdedlb14   = v_flgdedlb14,
                            flgdedlb15   = v_flgdedlb15,
                            flgdedlb16   = v_flgdedlb16,
                            flgotlb   = v_flgotlb,
                            rteot1   = v_rteot1,
                            rteot2   = v_rteot2,
                            rteot3   = v_rteot3,
                            rteot4   = v_rteot4,
                            rteot5   = v_rteot5,
                            flgothpy   = v_flgothpy,
                            dtecreate   = sysdate,
                            codcreate   = global_v_coduser,
                            dteupd   = sysdate,
                            coduser   = global_v_coduser
                      where codslip  = p_codslip;
      end;
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_formscan(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_typscan     varchar2(1000 char);
    v_typscan2     varchar2(1000 char);
    v_formimg     varchar2(1000 char);
    v_numseq      number := 0;
    v_codcomp     varchar2 (1000 char);
    v_total       number := 0;
  begin
    v_typscan := hcm_util.get_string_t(json_obj,'p_typscan');
    begin
      select formimg , a.numseq,b.typscan
        into v_formimg,v_numseq,v_typscan2
        from tformscan a, tfrmslip b
       where  a.codapp = 'HRPY55X'
         and b.codslip = v_typscan
         and b.typscan = a.numseq;
    exception when no_data_found then
      v_formimg := null;
      v_numseq  := null;
    end;
--
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('formimg', v_formimg);
    obj_row.put('desc_typscan', get_tformscan_name('HRPY55X',v_numseq,global_v_lang));
    obj_row.put('path_image',get_tfolderd('HRPY55X'));
    obj_row.put('typscan',v_typscan2);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

	procedure get_codincome_all(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			gen_codincome_all(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_codincome_all(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
        v_data			varchar2(1) := 'N';
        flgsecure       boolean;

		cursor c1 is
            select *
              from tcodslip
             where codcodec in (select codcodec from TCODSLIP where substr(codcodec,4,1) = '1')
          order by codcodec ;
	begin
		obj_row     := json_object_t();
		obj_data    := json_object_t();

        for r1 in c1 loop
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
            v_data      := 'Y';
            obj_data.put('coderror', '200');
            obj_data.put('codinc',  r1.codcodec);
            obj_data.put('desc_codinc', get_tcodec_name('TCODSLIP',r1.codcodec,global_v_lang));
            obj_data.put('flginclb', true);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;


	procedure get_coddeduct_all(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			gen_coddeduct_all(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_coddeduct_all(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
        v_data			varchar2(1) := 'N';
        flgsecure       boolean;

		cursor c1 is
            select *
              from tcodslip
             where codcodec in (select codcodec from TCODSLIP where substr(codcodec,4,1) = '3')
          order by codcodec ;
	begin
		obj_row     := json_object_t();
		obj_data    := json_object_t();
        for r1 in c1 loop
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
            v_data      := 'Y';
            obj_data.put('coderror', '200');
            obj_data.put('codded', r1.codcodec);
            obj_data.put('desc_codded', get_tcodec_name('TCODSLIP',r1.codcodec,global_v_lang));
            obj_data.put('flgdedlb', true);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
END M_HRPY55X;

/
