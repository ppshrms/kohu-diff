--------------------------------------------------------
--  DDL for Package Body HRPY44B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY44B" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;

    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    -- index params
    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_newflag           := hcm_util.get_string_t(json_obj,'p_newflag');
    p_flgretro          := hcm_util.get_string_t(json_obj,'p_flgretro');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_codcompy		tcontrpy.codcompy%type;
    v_lastperd		varchar2(10);
    v_currperd		varchar2(10);
    v_nextperd		varchar2(10);
    v_perd			varchar2(10);
    v_temp			number;
    v_date			date;
    v_zupdsal       varchar2(1);

    cursor c_tdtepay_last is
      select dteyrepay,dtemthpay,numperiod
      from  tdtepay
      where codcompy   = b_var_codcompy
        and typpayroll = b_var_typpayroll
        and flgcal     = 'Y'
      order by dteyrepay desc,dtemthpay desc,numperiod desc;

 cursor c_tdtepay_next is
    select dteyrepay   ,dtemthpay,numperiod
	  from   tdtepay
	  where  codcompy  = b_var_codcompy
	    and  typpayroll = b_var_typpayroll
	order by dteyrepay desc,dtemthpay desc,numperiod desc;


  begin
    if p_codempid is not null then
      p_codcomp := null;
    else
      b_var_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
      b_var_typpayroll := p_typpayroll;
    end if;

    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numperiod');
      return;
    end if;
    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
      return;
    end if;
    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
      return;
    end if;
    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if (p_typpayroll is null) and (p_codcomp is not null) then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codempid is not null then
      begin
        select codcomp,typpayroll,numlvl
        into p_codcomp,b_var_typpayroll,v_numlvl
        from temploy1
        where codempid = p_codempid;
        b_var_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
--        v_flgsecu      := secur_main.secur1(p_codcomp,v_numlvl,global_v_coduser,
--                                            global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        v_flgsecu      := secur_main.secur2(p_codempid,global_v_coduser,
                                            global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        return;
      end;
    else
      begin
        select	codcodec into b_var_typpayroll
        from	tcodtypy
        where  codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODTYPY');
        return;
      end;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      if length(p_codcomp) < 21 then
        p_codcomp := p_codcomp||'%';
      end if;
    end if;
    -- Check Period For Calculate

	begin
      select dtestrt,dteend
      into   b_var_dtebeg,b_var_dteend
      from   tdtepay
      where  codcompy   = b_var_codcompy
      and    typpayroll = b_var_typpayroll
      and  	 dteyrepay  = p_dteyrepay
      and  	 dtemthpay  = p_dtemthpay
      and  	 numperiod  = p_numperiod;
      param_msg_error := get_error_msg_php('PY0020', global_v_lang,'TDTEPAY');
      return;
	exception when no_data_found then
		null;
	end;

	/*begin
	  select dtestrt into v_date
		from   tdtepay
		where  codcompy = b_var_codcompy
		and    typpayroll = b_var_typpayroll
		and  dteyrepay = p_dteyrepay
		and	rownum = 1;
	exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TDTEPAY');
      return;
	end;

    /*begin
      select dtestrt,dteend
      into   b_var_dtebeg,b_var_dteend
      from   tdtepay
      where  codcompy   = b_var_codcompy
      and    typpayroll = b_var_typpayroll
      and  	 dteyrepay  = p_dteyrepay
      and  	 dtemthpay  = p_dtemthpay
      and  	 numperiod  = p_numperiod;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TDTEPAY');
      return;
    end;*/

    b_index_lastperd := null;

    v_currperd :=   lpad((p_dteyrepay),4,'0')||
                    lpad((p_dtemthpay),2,'0')||p_numperiod;

    v_lastperd := v_currperd;
    for r_tdtepay_last in c_tdtepay_last loop
      v_lastperd := lpad(to_char(r_tdtepay_last.dteyrepay),4,'0')||
                    lpad(to_char(r_tdtepay_last.dtemthpay),2,'0')||r_tdtepay_last.numperiod;
      b_index_lastperd := r_tdtepay_last.numperiod;
      b_index_lstmnt   := r_tdtepay_last.dtemthpay;
      b_index_lstyear  := r_tdtepay_last.dteyrepay;
      exit;
    end loop;

    --chai
    if v_currperd <> v_lastperd then
        if v_currperd < v_lastperd then
           param_msg_error := get_error_msg_php('HR7517', global_v_lang)  ;
           return;
        end if;
        for r_tdtepay_next in c_tdtepay_next loop
            v_perd := lpad(to_char(r_tdtepay_next.dteyrepay),4,'0')||
                                lpad(to_char(r_tdtepay_next.dtemthpay),2,'0')||
                                to_char(r_tdtepay_next.numperiod);
            if v_perd = v_lastperd then
                exit;
            else
                v_nextperd := lpad(to_char(r_tdtepay_next.dteyrepay),4,'0')||
                                            lpad(to_char(r_tdtepay_next.dtemthpay),2,'0')||
                                            to_char(r_tdtepay_next.numperiod);
            end if;
        end loop;
  end if;

	-- Find Control Data from PM Module about local currency, qty.hour
	begin
    select codcurr
		into ptcontpm_codcurr
		from tcontrpy
		where codcompy = b_var_codcompy
		  and dteeffec = (select max(dteeffec)
											from tcontrpy
											where	codcompy = b_var_codcompy
											  and	dteeffec <= trunc(sysdate));
	exception when no_data_found then
	  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCONTPM');
    return;
	end;
	-- Check Data Control For Calculate Income
	begin
    select codpaypy1,codpaypy2,codpaypy3,
    			 codpaypy4,codpaypy5,codpaypy6,
    			 codpaypy7,amtminsoc,amtmaxsoc,
    			 qtyage,flgfml,flgfmlsc,
    			 codpaypy8,null
		into ptcontrpy_codpaypy1,ptcontrpy_codpaypy2,ptcontrpy_codpaypy3,
				 ptcontrpy_codpaypy4,ptcontrpy_codpaypy5,ptcontrpy_codpaypy6,
				 ptcontrpy_codpaypy7,ptcontrpy_amtminsoc,ptcontrpy_amtmaxsoc,
				 ptcontrpy_qtyage,ptcontrpy_flgfml,ptcontrpy_flgfmlsc,
				 ptcontrpy_codpaypy8,ptcontrpy_codtax
		from tcontrpy
		where codcompy = b_var_codcompy
		  and dteeffec = (select max(dteeffec)
											from tcontrpy
											where	codcompy = b_var_codcompy
											  and dteeffec <= trunc(sysdate));
	exception when no_data_found then
	   param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCONTRPY');
     return;
	end;
	if ptcontrpy_codpaypy8 is not null then
		begin
			select codtax	into ptcontrpy_codtax
			from 	 ttaxtab
			where  codpay = ptcontrpy_codpaypy8;
		exception when no_data_found then
			null;
		end;
  end if;
	-- Check ข้อมูลตารางการคิดภาษี ว่ามีการกำหนดข้อมูลไว้หรือไม่ --
	begin
		select dteyreff
		into  pb_var_dteyreff
		from ttaxinf
		where typincom ='1'
		  and dteyreff = (select max(dteyreff)
											from ttaxinf
			    						where typincom ='1'
			    						  and dteyreff <= p_dteyrepay)
		  and rownum = 1;
	exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TTAXINF');
    return;
	end;
	-- Check ข้อมูลสูตรการคำนวณภาษี ว่ามีการกำหนดข้อมูลไว้หรือไม่ --
	begin
		select dteyreff
		into v_temp
		from tproctax
		where dteyreff <= p_dteyrepay
		  and rownum = 1;
	exception when no_data_found then
	  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPROCTAX');
    return;

	end;

	-- Find Fix Income Code
	begin
    select codincom1,codincom2,codincom3,codincom4,codincom5,
  				 codincom6,codincom7,codincom8,codincom9,codincom10,
  				 codretro1,codretro2,codretro3,codretro4,codretro5,
  				 codretro6,codretro7,codretro8,codretro9,codretro10
		into ptcontpms_codincom1,ptcontpms_codincom2,ptcontpms_codincom3,ptcontpms_codincom4,ptcontpms_codincom5,
				 ptcontpms_codincom6,ptcontpms_codincom7,ptcontpms_codincom8,ptcontpms_codincom9,ptcontpms_codincom10,
				 ptcontpms_codretro1,ptcontpms_codretro2,ptcontpms_codretro3,ptcontpms_codretro4,ptcontpms_codretro5,
				 ptcontpms_codretro6,ptcontpms_codretro7,ptcontpms_codretro8,ptcontpms_codretro9,ptcontpms_codretro10
		from tcontpms
	   where dteeffec = (select max(dteeffec)
                           from tcontpms
                          where	dteeffec <= trunc(sysdate)
                            and codcompy = b_var_codcompy)
         and codcompy = b_var_codcompy;
	exception when no_data_found then
	  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCONTPMS');
    return;
	end;
	begin
	  select to_char(dteeffec,'dd/mm/yyyy')
	  into ptpfhinf_dteeffec
		from tpfhinf
		where codcompy = b_var_codcompy
		  and dteeffec = (select max(dteeffec)
											from tpfhinf
											where	codcompy = b_var_codcompy
											  and dteeffec <= trunc(sysdate));
	exception when no_data_found then
	  ptpfhinf_dteeffec:= null;
	end;

  end check_index;

procedure get_process (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_oracode   => param_msg_error
    );
  exception when others then ---comment for test
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end get_process;

  procedure  insert_data_parallel (p_codapp  in varchar2,
                                   p_coduser in varchar2,
                                   p_proc    in out number) is

	v_num      number ;
	v_proc     number := p_proc ;
	v_numproc  number ;
	v_rec      number ;
	v_flgsecu  boolean := false;
	v_secur    boolean := false;
	v_flgfound boolean := false;
	v_zupdsal  varchar2(1);

			cursor c_temploy1 is
			  select codempid,codcomp,numlvl
			  from temploy1
			  where (p_codempid is not null and codempid = p_codempid)
			     or (p_codempid is null and codcomp like p_codcomp and typpayroll = p_typpayroll and
							 (staemp in ('1','3') or
							 (staemp = '9' and dteeffex > b_var_dtebeg) or
							 (staemp = '9' and
							 (exists (select codempid
                                        from totsum
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from tothinc
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from tothpay
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from ttpminf
                                        where codempid  =	temploy1.codempid
                                        and dteeffec >= temploy1.dteeffex
                                        and codtrn    = '0002') or
                              exists (select codempid
                                        from ttaxcur
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod )

							 )
							 )
							 )
							 )
			  order by codempid;


begin
      delete tprocemp where codapp = p_codapp and coduser = p_coduser  ; commit;

      commit ;
      begin
			  select count(codempid) into   v_rec
			  from temploy1
			  where (p_codempid is not null and codempid = p_codempid)
			     or (p_codempid is null and codcomp like p_codcomp and typpayroll = p_typpayroll and
							 (staemp in ('1','3') or
							 (staemp = '9' and dteeffex > b_var_dtebeg) or
							 (staemp = '9' and
							 (exists (select codempid
                                        from totsum
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from tothinc
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from tothpay
                                        where codempid = temploy1.codempid
                                        and dteyrepay = p_dteyrepay
                                        and dtemthpay = p_dtemthpay
                                        and numperiod = p_numperiod) or
							  exists (select codempid
                                        from ttpminf
                                        where codempid  =	temploy1.codempid
                                        and dteeffec >= temploy1.dteeffex
                                        and codtrn    = '0002') or
                              exists (select codempid
                                            from ttaxcur
                                            where codempid = temploy1.codempid
                                            and dteyrepay  = p_dteyrepay
                                            and dtemthpay  = p_dtemthpay
                                            and numperiod  = p_numperiod )
							 )
							 )
							 )
							 );
			end;

			v_num    := greatest(trunc(v_rec/v_proc),1);
			v_rec    := 0;
			if p_codempid is  null then
                for i in  c_temploy1 loop
                    v_flgfound := true;
                    v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
                    if v_flgsecu then
                        v_secur   := true;
                        v_rec     := v_rec + 1 ;
                        v_numproc := trunc(v_rec / v_num) + 1 ;
                        if v_numproc > v_proc then
                           v_numproc  := v_proc ;
                        end if;

                        insert into  tprocemp (codapp,  coduser,   numproc,   codempid)
                                       values (p_codapp,p_coduser, v_numproc, i.codempid);
                    end if;
                end loop;
			else
                v_secur   := true;
                v_rec     := v_rec + 1 ;
                v_numproc := 1;
                v_flgfound := true ;
                insert into  tprocemp (codapp ,coduser,numproc ,codempid )
                               values (p_codapp ,p_coduser,v_numproc ,p_codempid ) ;
			end if;

			if not v_flgfound then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
			end if;

			if not v_secur then
               param_msg_error := get_error_msg_php('HR3007',global_v_lang);
			end if;

			p_proc := v_numproc;
			commit;
  end;

  procedure process_data(json_str_output out clob) is
    obj_row         json_object_t := json_object_t();
    obj_row2        json_object_t := json_object_t();
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_flgpass		    boolean := true;
    v_row           number := 0;
    o_numrec        number;
    o_numerr        number;
    o_time          varchar2(100 char);
    o_error         varchar2(1000 char);
    o_exist         varchar2(100 char);
    o_secur         varchar2(100 char);
    v_response      varchar2(4000 char);
    v_empid         varchar2(100 char);
    v_codapp        varchar2(100 char) := 'HRPY44B';
    v_numproc       number := nvl(get_tsetup_value('QTYPARALLEL'),2);
    v_qtyproc       number := 0;
    v_qtyerr        number := 0;
    v_timest        date;
    v_timediff      varchar2(100 char);
 	v_exist			boolean := false;
	v_secur		    boolean := false;

    cursor c_error is
        select  coduser,codapp,numseq,
                tableadj,wheresql,flgbrk,
                item01,item02,item03,
                temp01,item11,temp11
         from ttemfilt
        where codapp  like v_codapp||'%'
          and coduser = global_v_coduser
          and item11  = v_codapp
        order by codapp,temp11,item01;

  begin

    v_timest := systimestamp;
    for i in 1..v_numproc loop --old process use loop for parallel run
      delete from ttemfilt where codapp = v_codapp||i;
    end loop;
    insert_data_parallel (v_codapp,global_v_coduser,v_numproc)  ;

    std_tax.get_parameter( b_var_codempid      ,
                           b_var_codcompy      ,
                           b_var_typpayroll    ,
                           to_char(b_var_dtebeg,'dd/mm/yyyy')        ,
                           to_char(b_var_dteend,'dd/mm/yyyy')        ,
                           pb_var_ratechge      ,
                           pb_var_mqtypay       ,
                           pb_var_balperd       ,
                           pb_var_perdpay       ,
                           pb_var_stacal        ,
                           pb_var_amtcal        ,
                           pb_var_dteyreff      ,
                           pb_var_socfix        ,
                           pb_var_profix        ,
                           pb_var_tempinc       ,
                           pb_var_flglast       ,
                           p_numperiod   ,
                           p_dtemthpay   ,
                           p_dteyrepay   ,
                           p_codempid    ,
                           p_codcomp     ,
                           p_newflag     ,
                           p_flag        ,
                           p_flgretro    ,
                           ptcontpm_codcurr     ,
                           ptcontrpy_flgfmlsc   ,
                           ptcontrpy_flgfml     ,
                           ptcontrpy_codpaypy1  ,
                           ptcontrpy_codpaypy2  ,
                           ptcontrpy_codpaypy3  ,
                           ptcontrpy_codpaypy4  ,
                           ptcontrpy_codpaypy5  ,
                           ptcontrpy_codpaypy6  ,
                           ptcontrpy_codpaypy7  ,
                           ptcontrpy_codpaypy8  ,
                           ptcontrpy_codtax     ,
                           ptcontrpy_amtminsoc  ,
                           ptcontrpy_amtmaxsoc  ,
                           ptcontrpy_qtyage     ,
                           ptcontpms_codincom1  ,
                           ptcontpms_codincom2  ,
                           ptcontpms_codincom3  ,
                           ptcontpms_codincom4  ,
                           ptcontpms_codincom5  ,
                           ptcontpms_codincom6  ,
                           ptcontpms_codincom7  ,
                           ptcontpms_codincom8  ,
                           ptcontpms_codincom9  ,
                           ptcontpms_codincom10 ,
                           ptcontpms_codretro1  ,
                           ptcontpms_codretro2  ,
                           ptcontpms_codretro3  ,
                           ptcontpms_codretro4  ,
                           ptcontpms_codretro5  ,
                           ptcontpms_codretro6  ,
                           ptcontpms_codretro7  ,
                           ptcontpms_codretro8  ,
                           ptcontpms_codretro9  ,
                           ptcontpms_codretro10 ,
                           ptpfhinf_dteeffec    ,
                           ptssrate_pctsoc      ,
                           global_v_coduser     ,
                           global_v_lang        );



    std_tax.process_ ('HRPY44B',global_v_coduser,
                      p_numperiod ,p_dtemthpay,p_dteyrepay,
                      p_codcomp ,p_typpayroll,p_codempid,
                      p_newflag,p_flag,p_flgretro,global_v_lang );


    begin
      select to_char(trunc(extract( hour   from timediff )),'FM00')||':'||
             to_char(trunc(extract( minute from timediff )),'FM00')||':'||
             to_char(trunc(extract( second from timediff )),'FM00')
        into v_timediff
        from (select systimestamp - v_timest timediff from dual);
    exception when others then null;
    end;

    --display_error
    o_numrec  := 0;
    o_numerr  := 0;

    for j in 1..v_numproc loop
        begin
            select qtyproc,qtyerr
              into v_qtyproc,v_qtyerr
              from tprocount
             where codapp  = v_codapp
               and coduser = global_v_coduser
               and flgproc in ('Y','E' )
               and numproc = j;
        exception when no_data_found then
            v_qtyproc  := 0;
            v_qtyerr   := 0;
        end;
        o_numrec  := nvl(o_numrec,0) + nvl(v_qtyproc,0);
        o_numerr  := nvl(o_numerr,0) + nvl(v_qtyerr,0);
    end loop;--for j in 1..v_numproc loop

    if o_numerr > 0 then
        for i in c_error loop
            v_row   := v_row + 1;
            v_empid := i.item01;
            obj_data2 := json_object_t();
            obj_data2.put('coderror','200');
            obj_data2.put('codempid', v_empid);
            obj_data2.put('desc_codempid', get_temploy_name(v_empid, global_v_lang));
            obj_data2.put('result', i.item03);
            obj_row2.put(to_char(v_row - 1), obj_data2);

            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => v_empid,
              p_item02  => get_temploy_name(v_empid, global_v_lang),
              p_item03  => i.item03
            );
        end loop;
    end if;

   if nvl(o_numrec,0) > 0 or nvl(o_numerr,0) > 0 then
   	  v_exist := true;
   	  v_secur := true;
   end if;

    if not v_exist then
        param_msg_error := get_error_msg_php('HR2715', global_v_lang);

        -- set complete batch process
        global_v_batch_flgproc := 'Y';
    elsif not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    else
        param_msg_error := get_error_msg_php('HR2715', global_v_lang);

        -- set complete batch process
        global_v_batch_flgproc := 'Y';
    end if;

    -->> Output
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('lastperd', b_index_lastperd);
    obj_data.put('lstmnt', b_index_lstmnt);
    obj_data.put('lstyear', b_index_lstyear);
    obj_data.put('numrec', nvl(o_numrec,0));
    obj_data.put('numerr', nvl(o_numerr,0));
    obj_data.put('time', nvl(v_timediff,0));

    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response      := get_response_message(null,param_msg_error,global_v_lang);
    obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    obj_data.put('table', obj_row2);
    json_str_output := obj_data.to_clob;

    -- set complete batch process
    global_v_batch_qtyproc := nvl(o_numrec,0);
    global_v_batch_qtyerror:= nvl(o_numerr,0);
 exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );

  end process_data;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;

end HRPY44B;

/
