--------------------------------------------------------
--  DDL for Package Body STD_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_TAX" is
--Update date 07/02/2024 15:50
procedure process_ (p_codapp      in varchar2,
                    p_coduser     in varchar2,
                    p_numperiod   in number,
                    p_dtemthpay	  in number,
                    p_dteyrepay   in number,
                    p_codcomp     in varchar2,
                    p_typpayroll  in varchar2,
                    p_codempid    in varchar2,
                    p_newflag     in varchar2,
                    p_flag        in varchar2,
                    p_flgretro    in varchar2,
                    p_lang        in varchar2 ) Is

		v_stmt			varchar2(1000);
		v_interval	varchar2(50);
		v_finish		varchar2(1);
    p_dtestr    varchar2(20);
    p_dteend    varchar2(20);
    p_v_dtestrt varchar2(20);
		type a_number is table of number index by binary_integer;
  		 a_jobno	a_number;
begin
    if p_codempid is null then -- กรณีเลือกประมวลผลแบบหน่วยงาน
        for i in 1..para_numproc loop -- para_numproc จำนวน parallel ตาม tsetup QTYPARALLEL
          v_stmt := 'std_tax.start_process('''||p_codapp||''','''||p_coduser||''','
                             ||i||
                             ','''||p_codapp||''','''||
                             p_codcomp||''','''||
                             p_typpayroll||''','''||
                             p_codempid||''','''||
                             p_numperiod||''','''||
                             p_dtemthpay||''','''||
                             p_dteyrepay||''','''||
                             p_newflag||''','''||-- คำนวณตั้งแต่วันที่เข้างาน/เฉพาะงวด
                             p_flag||''','''||-- ประเมินถึงสิ้นปี/ประเมินถึงวันที่ลาออก
                             p_flgretro||''','''||-- คำนวณตกเบิก/ไม่คำนวณตกเบิก
                             p_lang||''');';
          dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
        end loop;
        v_finish := 'N';
        loop
          for i in 1..para_numproc loop
            dbms_lock.sleep(10);
            begin
              select 'N' into v_finish
                from user_jobs
               where job = a_jobno(i);
              exit;
            exception when no_data_found then v_finish := 'Y';
            end;
          end loop;
          if v_finish = 'Y' then
            exit;
          end if;
        end loop;
    else -- กรณีเลือกประมวลผลแบบเลือกพนักงาน
       std_tax.start_process(p_codapp,p_coduser,1,
                             p_codapp,
                             p_codcomp,
                             p_typpayroll,
                             p_codempid,
                             p_numperiod,
                             p_dtemthpay,
                             p_dteyrepay,
                             p_newflag,
                             p_flag,
                             p_flgretro,
                             p_lang);
    end if;
end ;

procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_codcompy	tcontrpy.codcompy%type;
    v_lastperd	varchar2(10);
    v_currperd	varchar2(10);
    v_nextperd	varchar2(10);
    v_perd			varchar2(10);
    v_temp			number;
    v_date			date;
    v_zupdsal   varchar2(1);

    cursor c_tdtepay_last is
      select dteyrepay,dtemthpay,numperiod
      from  tdtepay
      where codcompy   = b_var_codcompy
        and typpayroll = b_var_typpayroll
        and flgcal = 'Y'
      order by dteyrepay desc,dtemthpay desc,numperiod desc;

 cursor c_tdtepay_next is
    select dteyrepay   ,dtemthpay,numperiod
	  from   tdtepay
	  where  codcompy  = b_var_codcompy
	    and  typpayroll = b_var_typpayroll
	order by dteyrepay desc,dtemthpay desc,numperiod desc;

begin
    -- Check Period For Calculate
    begin
      select dtestrt,dteend
      into   b_var_dtebeg,b_var_dteend
      from   tdtepay
      where  codcompy   = b_var_codcompy
      and    typpayroll = b_var_typpayroll
      and  	 dteyrepay  = b_index_dteyrepay
      and  	 dtemthpay  = b_index_dtemthpay
      and  	 numperiod  = b_index_numperiod;
    exception when no_data_found then
      null ;
    end;
	-- Check Data Control For Calculate Income
	begin
    select codpaypy1,codpaypy2,codpaypy3,
    			 codpaypy4,codpaypy5,codpaypy6,
    			 codpaypy7,amtminsoc,amtmaxsoc,
    			 qtyage,flgfml,flgfmlsc,
    			 codpaypy8,null
		into tcontrpy_codpaypy1,tcontrpy_codpaypy2,tcontrpy_codpaypy3,
				 tcontrpy_codpaypy4,tcontrpy_codpaypy5,tcontrpy_codpaypy6,
				 tcontrpy_codpaypy7,tcontrpy_amtminsoc,tcontrpy_amtmaxsoc,
				 tcontrpy_qtyage,tcontrpy_flgfml,tcontrpy_flgfmlsc,
				 tcontrpy_codpaypy8,tcontrpy_codtax
		from tcontrpy
		where codcompy = b_var_codcompy
		  and dteeffec = (select max(dteeffec)
											from tcontrpy
											where	codcompy = b_var_codcompy
											  and dteeffec <= trunc(sysdate));
	exception when no_data_found then
	   null ;
	end;

	if tcontrpy_codpaypy8 is not null then
		begin
			select codtax	into tcontrpy_codtax
			from 	 ttaxtab
			where  codpay = tcontrpy_codpaypy8;
		exception when no_data_found then
			null;
		end;
  end if;

	-- Find Control Data from PM Module about local currency, qty.hour
  begin
    select codincom1,codincom2,codincom3,codincom4,codincom5,
  				 codincom6,codincom7,codincom8,codincom9,codincom10,
  				 codretro1,codretro2,codretro3,codretro4,codretro5,
  				 codretro6,codretro7,codretro8,codretro9,codretro10
		into tcontpms_codincom1,tcontpms_codincom2,tcontpms_codincom3,tcontpms_codincom4,tcontpms_codincom5,
				 tcontpms_codincom6,tcontpms_codincom7,tcontpms_codincom8,tcontpms_codincom9,tcontpms_codincom10,
				 tcontpms_codretro1,tcontpms_codretro2,tcontpms_codretro3,tcontpms_codretro4,tcontpms_codretro5,
				 tcontpms_codretro6,tcontpms_codretro7,tcontpms_codretro8,tcontpms_codretro9,tcontpms_codretro10
		from tcontpms
		where dteeffec = (select max(dteeffec)
                            from tcontpms
                           where codcompy = b_var_codcompy
                             and dteeffec <= trunc(sysdate))
          and codcompy = b_var_codcompy;
	exception when no_data_found then
	  null;
	end;
end check_index;

procedure start_process (p_codapp  in varchar2,
                         p_coduser in varchar2,
                         p_numproc in number,
                         p_process in varchar2 ,
                         --
                         p_codcomp    in varchar2 ,
                         p_typpayroll in varchar2 ,
                         p_codempid   in varchar2 ,
                         p_numperiod  in varchar2 ,
                         p_dtemthpay  in varchar2 ,
                         p_dteyrepay  in varchar2 ,
                         p_newflag     in varchar2 ,
                         p_flag        in varchar2 ,
                         p_flgretro    in varchar2 ,
                         p_lang        in varchar2  ) Is

    p_sumrec      number:=0;
    p_sumerr      number:=0;
    v_exist		    boolean;
    v_flgsecu	    boolean;
    v_count			  number;
    v_oldyear  		tdtepay.dteyrepay%type;
    v_oldmonth 		tdtepay.dtemthpay%type;
    v_oldperd  		tdtepay.numperiod%type;
    v_oldstrt  		date;
    v_oldend 	 	  date;
    v_codempid		temploy1.codempid%type;
    v_dteempmt		temploy1.dteempmt%type;
    v_dteeffex		temploy1.dteeffex%type;
    v_codtrn		  ttpminf.codtrn%type;
    v_stdate		  date;
    v_endate		  date;
    v_qtyday		  number;
    v_deduct		  number;
    v_oldmqtypay	number;
    v_zupdsal     varchar2(1);

    v_codapp	  	varchar2(100) := 'HRPY41B';
    v_code			  temploy1.codempid%type;
    v_nxtyear  		tdtepay.dteyrepay%type;
    v_nxtmonth 		tdtepay.dtemthpay%type;
    v_nxtperd  		tdtepay.numperiod%type;
    v_lastyear  	tdtepay.dteyrepay%type;
    v_lastmonth 	tdtepay.dtemthpay%type;
    v_lastperd  	tdtepay.numperiod%type;
    v_net_ded     number ;
    v_sqlerrm     varchar2(1000) ;

    cursor c_emp is
        select a.codempid,a.codcomp,  a.stamarry,  a.dteempdb, a.dteempmt, a.staemp,
               a.codbrlc, a.dteeffex, a.typpayroll,a.typemp,   a.codempmt, a.numlvl,
               a.codpos,  a.jobgrade, a.codgrpgl,  a.qtydatrq
        from temploy1 a,tprocemp b
       where a.codempid = b.codempid
         and b.codapp   = p_codapp
         and b.coduser  = p_coduser
         and b.numproc  = p_numproc;

    cursor c_ttpminf is
      select dteeffec
        from ttpminf
       where codempid  = v_codempid
         and dteeffec <= v_endate
         and codtrn    = v_codtrn
      order by dteeffec desc,numseq desc;

    cursor c_tdtepay is
      select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
        from tdtepay
       where codcompy   = b_var_codcompy
         and typpayroll = b_var_typpayroll
      order by dteyrepay desc,dtemthpay desc,numperiod desc;

    cursor c_tdtepay_next is
      select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
      from tdtepay
      where codcompy   = b_var_codcompy
        and typpayroll = b_var_typpayroll
      order by dteyrepay,dtemthpay,numperiod;

    cursor c_ttaxtab is
      select codpay,codtax
        from ttaxtab;

    cursor c_tcodeduct is
        select typdeduct,coddeduct
          from tcodeduct;

    cursor c_ttaxcur is
        select a.codempid,a.codcomp,a.numlvl
          from ttaxcur a,tprocemp b
         where a.codempid  = b.codempid
           and b.codapp    = p_codapp
           and b.coduser   = p_coduser
           and b.numproc   = p_numproc
           and a.dteyrepay = b_index_dteyrepay - v_zyear
           and a.dtemthpay = b_index_dtemthpay
           and a.numperiod = b_index_numperiod;

begin
    delete ttemprpt where codapp like 'HRPY41MSG%' ; -- delete debug program
    delete ttemprpt where codapp = '41B' ; -- delete debug program


    v_numproc  := p_numproc;
    delete tprocount where codapp = p_codapp and coduser = p_coduser and numproc = p_numproc ; commit; -- delete ข้อมูลการประมวล ตามเลข Paralell

    insert into tprocount (codapp,coduser,numproc, -- insert ข้อมูลการประมวลใหม่ ตามเลข Paralell
                           qtyproc,codpay,flgproc,dteupd)
     values               (p_codapp,p_coduser,p_numproc,
                           0,null,'N',sysdate);

    commit;
    -- ตัวแปรที่เป็น b_var_..... ถูก assign ซ้ำๆ ในหลายจุด อาจจะต้อง clean code อีกที
    if p_codempid is not null then
       begin
        select hcm_util.get_codcomp_level(codcomp,1),typpayroll
        into   b_var_codcompy , b_var_typpayroll
        from   temploy1
        where  codempid  = p_codempid ;
       exception when others then
         null ;
       end ;
    else
       b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);
       b_var_typpayroll := p_typpayroll ;
    end if;
    b_index_numperiod := p_numperiod ;
    b_index_dtemthpay := p_dtemthpay;
    b_index_dteyrepay := p_dteyrepay;
    b_index_codempid  := p_codempid;
    b_index_codcomp   := p_codcomp;
    b_index_newflag   := p_newflag; -- Option คำนวณตั้งแต่วันที่เข้างาน
    b_index_flag      := case when nvl(p_flag,'N') = '1' then 'Y' else 'N' end; -- ในหน้าส่งมาเป็น 1,2 ใน Process ใช้ Y,N
    b_index_flgretro  := p_flgretro; -- Option คำนวณตกเบิก
    v_lang            := p_lang;
    v_process         := p_process ;
    b_index_sumrec    := 0;
    b_index_sumerr    := 0;
    v_lastyear        := null;
    v_exist           := false;
    v_err_step        := 1 ;
    v_coduser         := p_coduser ;
    check_index ;

    if p_process = 'HRPY41B' then
        for r_tdtepay in c_tdtepay loop -- หางวดก่อนหน้า cursor เรียงข้อมูลจากมากไปน้อย
          if r_tdtepay.dteyrepay = (b_index_dteyrepay - v_zyear) and v_lastyear is null then
            v_lastyear  := r_tdtepay.dteyrepay;
            v_lastmonth := r_tdtepay.dtemthpay;
            v_lastperd  := r_tdtepay.numperiod;
          end if;
          if v_exist then
            v_oldyear  := r_tdtepay.dteyrepay;
            v_oldmonth := r_tdtepay.dtemthpay;
            v_oldperd  := r_tdtepay.numperiod;
            v_oldstrt  := r_tdtepay.dtestrt;
            v_oldend   := r_tdtepay.dteend;
            exit;
          elsif (r_tdtepay.dteyrepay = b_index_dteyrepay - v_zyear) and
                (r_tdtepay.dtemthpay = b_index_dtemthpay) and
                (r_tdtepay.numperiod = b_index_numperiod) then
            v_exist := true;
          end if;
        end loop;
        if (v_lastyear  =  b_index_dteyrepay - v_zyear) and
           (v_lastmonth =  b_index_dtemthpay) and
           (v_lastperd  =  b_index_numperiod) then
            b_var_flglast := 'Y'; -- ถ้างวดสุดท้ายของปี = งวดที่กำลังประมวลผล ให้ b_var_flglast = 'Y'
        else
            b_var_flglast := 'N';
        end if;
        v_err_step     := 2 ;
    -- Find numperiod pay in month จำนวณงวดในเดือนก่อนหน้า
        select count(codcompy)
        into v_oldmqtypay
        from tdtepay
        where codcompy   = b_var_codcompy
          and typpayroll = b_var_typpayroll
          and dteyrepay  = v_oldyear
          and dtemthpay  = v_oldmonth;
    end if;

    -- Find numperiod pay in month
    select count(codcompy)
     into b_var_mqtypay -- จำนวนงวดในเดือนที่กำลัง Process
     from tdtepay
    where codcompy   = b_var_codcompy
      and typpayroll = b_var_typpayroll
      and dteyrepay  = b_index_dteyrepay - v_zyear
      and dtemthpay  = b_index_dtemthpay;

    -- Find numperiod pay in year (not cal include current period)
    select count(codcompy)
     into b_var_balperd -- จำนวนงวดที่เหลือรวมงวดที่คำนวณ
     from tdtepay
    where codcompy   = b_var_codcompy
      and typpayroll = b_var_typpayroll
      and dteyrepay  = b_index_dteyrepay - v_zyear
      and (((dtemthpay = b_index_dtemthpay) and (numperiod >= b_index_numperiod))
            or
           (dtemthpay > b_index_dtemthpay));

	-- Find numperiod pay in month (not cal not include current period)
  if p_process = 'HRPY41B' then
    select count(*)
      into b_var_perdpay -- จำนวนงวดที่เหลือในเดือน
      from tdtepay
     where codcompy   =  b_var_codcompy
       and typpayroll =  b_var_typpayroll
       and dteyrepay  =  b_index_dteyrepay - v_zyear
       and dtemthpay  =  b_index_dtemthpay
       and	numperiod  >  b_index_numperiod;
  else
    select count(*)
      into b_var_perdpay -- จำนวนงวดที่เหลือในเดือน
      from tdtepay
     where codcompy   =  b_var_codcompy
       and typpayroll =  b_var_typpayroll
       and dteyrepay  =  b_index_dteyrepay - v_zyear
       and dtemthpay  =  b_index_dtemthpay
       and numperiod  <> b_index_numperiod
       and ((flgcal is null) or (flgcal = 'N'));
  end if;

  v_exist := false;
  for r_tdtepay_next in c_tdtepay_next loop -- Next Period
    if v_exist then
      v_nxtyear  := r_tdtepay_next.dteyrepay;
      v_nxtmonth := r_tdtepay_next.dtemthpay;
      v_nxtperd  := r_tdtepay_next.numperiod;
      exit;
    elsif (r_tdtepay_next.dteyrepay = b_index_dteyrepay - v_zyear) and
          (r_tdtepay_next.dtemthpay = b_index_dtemthpay) and
          (r_tdtepay_next.numperiod = b_index_numperiod) then
      v_exist := true;
    end if;
  end loop;

 	declare_var_v_max := 0;
  for r_ttaxtab in c_ttaxtab loop -- กำหนดคู่ภาษี
    declare_var_v_max := declare_var_v_max + 1;
    declare_var_v_tab_codpay(declare_var_v_max) := r_ttaxtab.codpay;
    declare_var_v_tab_codtax(declare_var_v_max) := r_ttaxtab.codtax;
  end loop;
    for r_tcodeduct in c_tcodeduct loop -- setup ค่าลดหย่อน เงินยกเว้นภาษี
        if r_tcodeduct.typdeduct = 'E' then -- ยกเว้น
            declare_var_evalue_code(substr(r_tcodeduct.coddeduct,2)) := 0;
        elsif r_tcodeduct.typdeduct = 'D' then -- ลดหย่อน
            declare_var_dvalue_code(substr(r_tcodeduct.coddeduct,2)) := 0;
        else -- อื่นๆ
            declare_var_ovalue_code(substr(r_tcodeduct.coddeduct,2)) := 0;
        end if;
    end loop;

    for r_ttaxcur in c_ttaxcur loop
        temploy1_codempid := r_ttaxcur.codempid;
        v_flgsecu := secur_main.secur1(r_ttaxcur.codcomp,r_ttaxcur.numlvl,v_coduser,v_numlvlsalst,v_numlvlsalen,v_zupdsal);
        if v_flgsecu then
            clear_olddata;
        end if;
    end loop;

    begin
        select nvl(typesitm,'1'),nvl(typededtax,'1'),codpaypy10,
               codpaypy11,codpaypy12,codpaypy13,codpaypy14,
               syncond,pctsoc,pctsocc
        into   tcontrpy_typesitm ,tcontrpy_typededtax,tcontrpy_codpaypy10,
               tcontrpy_codpaypy11,tcontrpy_codpaypy12,tcontrpy_codpaypy13,tcontrpy_codpaypy14,
               tcontrpy_syncond,tssrate_pctsoc,tssrate_pctsocc
        from  tcontrpy
        where codcompy = b_var_codcompy
        and   dteeffec = (select max(dteeffec)
                          from  tcontrpy
                          where codcompy  = b_var_codcompy
                      and   dteeffec <= sysdate );
    exception when others then
        null ;
    end ;
  for r_emp in c_emp loop
    v_flgsecu := TRUE;
    if v_flgsecu then
      v_codempid          := r_emp.codempid;
      b_var_codempid      := r_emp.codempid;
  		temploy1_codempid   := r_emp.codempid;
  		temploy1_codcomp    := r_emp.codcomp;
  		temploy1_stamarry   := r_emp.stamarry;
  		temploy1_dteempdb   := r_emp.dteempdb;
  		temploy1_dteempmt   := r_emp.dteempmt;
  		temploy1_staemp     := r_emp.staemp;
  		temploy1_codbrlc    := r_emp.codbrlc;
  		temploy1_codpos     := r_emp.codpos;
  		temploy1_dteeffex   := r_emp.dteeffex;
  		temploy1_typpayroll := r_emp.typpayroll;
  		temploy1_typemp     := r_emp.typemp;
  		temploy1_codempmt   := r_emp.codempmt;
  		temploy1_numlvl     := r_emp.numlvl;
  		temploy1_jobgrade   := r_emp.jobgrade;
  		temploy1_codgrpgl   := r_emp.codgrpgl;
  		temploy1_qtydatrq   := r_emp.qtydatrq;
  		temploy1_dtedatrq   := add_months(temploy1_dteempmt,r_emp.qtydatrq);
      parameter_emp_error := 'N';

      begin
          select codempid into v_code
          from ttaxcur
          where codempid = temploy1_codempid
          and	dteyrepay  = v_nxtyear
          and	dtemthpay  = v_nxtmonth
          and numperiod  = v_nxtperd;
        -- insert msg error ด้วย
        goto loop_next; -- ถ้ามีข้อมูลการคำนวณในงวดถัดไปแล้วให้ข้าม
      exception when no_data_found then
          null;
      end;

      exec_temploy3;
      clear_olddata; -- clear ข้อมูลของงวดที่กำลังนคำนวณ เผื่อกรณีคำนวณซ้ำ

      if r_emp.staemp = '0' then -- ข้ามพนักงานใหม่
        -- insert msg error ด้วย
        goto loop_next;
      end if;

      v_dteempmt := r_emp.dteempmt;
      v_codtrn := '0002'; -- Rehire
      v_endate := b_var_dteend;
      for r_ttpminf in c_ttpminf loop
      	v_dteempmt := r_ttpminf.dteeffec; -- กำหนดวันที่เริ่มงานตาม Movement
      	exit;
      end loop;

      v_dteeffex := r_emp.dteeffex;
      if r_emp.staemp in('1','3') then
	      v_codtrn := '0006'; -- Terminate
	      v_endate := b_var_dteend + 1;
	      for r_ttpminf in c_ttpminf loop
	      	v_dteeffex := r_ttpminf.dteeffec; -- กำหนดวันที่ลาออกตาม Movement
	      	exit;
	      end loop;
	      if v_dteeffex <= v_dteempmt then
		      if v_dteeffex = v_dteempmt then
			      v_dteempmt := r_emp.dteempmt;
			  end if;
			  v_dteeffex := r_emp.dteeffex;
		  end if;
      end if;

      temploy1_dteeffex	:= v_dteeffex;
      v_stdate := b_var_dtebeg;
      begin
        select min(dtestrt),max(dteend)
        into v_dteyrst,v_dteyren
        from tdtepay
        where codcompy   = b_var_codcompy
          and typpayroll = b_var_typpayroll
          and	dteyrepay  = (b_index_dteyrepay - v_zyear) ;
      end ;

      if p_process = 'HRPY41B' then
        v_endate := b_var_dteend;

        b_var_stacal := '1'; -- พนักงานปัจจุบัน
        --ถ้าวันพ้นสภาพ < วันเริ่มคำนวณ
        if v_dteeffex <= v_stdate then
           b_var_stacal := '4';
           v_endate := v_dteeffex - 1;
        -- ถ้าวันพ้นสภาพ > วันเริ่มคำนวณและ <= วันสิ้นสุดการคำนวณ
        elsif (v_dteeffex > v_stdate) and (v_dteeffex <= v_endate) then
           b_var_stacal := '2';
          -- ถ้าวันที่เข้างานอยู่ประหว่างวันที่คำนวณ
          if v_dteempmt between v_stdate and v_endate then
            v_stdate := v_dteempmt;
          end if;
          v_endate := v_dteeffex - 1;
        elsif v_dteempmt between v_stdate and v_endate then
           b_var_stacal := '0';
           v_stdate     := v_dteempmt;
         --ถ้าวันเข้างานมากกว่าวันสิ้นสุด
        elsif v_dteempmt > v_endate then
          v_stdate := v_dteempmt;
        end if;
        -- หาจำนวนวันในการคำนวณ
        if b_var_stacal = '4' then
           v_qtyday := 0;
        else
          if (v_stdate = b_var_dtebeg) and (v_endate = b_var_dteend) then
            v_qtyday := v_numday / b_var_mqtypay; -- 30 / จำนวนงวดในเดือน
          else
            v_qtyday := v_endate - v_stdate + 1;
          end if;
        end if;
       v_err_step     := 12 ;
        if b_index_newflag = 'Y' then -- คำนวนย้อนหลังตั้งแต่วันเข้างาน
          if v_dteempmt between v_oldstrt and v_oldend  then
            begin
              select codempid into v_codempid
              from ttaxcur
              where codempid  = v_codempid
                and	dteyrepay = v_oldyear
                and	dtemthpay = v_oldmonth
                and numperiod = v_oldperd;
            exception when no_data_found then
              if  b_var_stacal = '1' then
                  b_var_stacal := '0';
              end if;
              v_stdate := v_dteempmt;
              if (v_dteeffex > v_oldend) or (v_dteeffex is null) then
                if v_dteempmt = v_oldstrt then
                  v_qtyday := v_qtyday + (v_numday / v_oldmqtypay); -- จำนวนวันในงวดปัจจุบัน + (30 / จำนวนงวดในเดือนก่อนหน้า)
                else
                  v_qtyday := v_qtyday + (v_oldend - v_dteempmt) + 1; -- จำนวนวันในงวดปัจจุบัน + (วันที่สิ้นสุดรอบก่อนหน้า - วันที่เริ่มงาน)
                end if;
              else
                v_qtyday := v_qtyday + (v_dteeffex - v_dteempmt); -- จำนวนวันในงวดปัจจุบัน + (วันที่ลาออก - วันที่เริ่มงาน)
              end if;
            end;
          end if;
        end if;

      else -- p_process = 'HRPY41B'
        if temploy1_dteeffex is not null then
          b_var_dteend := temploy1_dteeffex - 1;
        end if;
        v_endate := b_var_dteend;
      end if; -- p_process = 'HRPY41B'

      -- b_var_staemp  สถานะพนักงานเข้า-ออกภายในปี
      -- 1 => ลาออกระหว่างงวด
      -- 2 => เข้างานภายในปี
      -- 3 => เข้างานระหว่างงวด
      -- 4 => เข้า-ออกระหว่างปี
      -- 5 => ลาออกงวดนี้
        b_var_staemp := 0 ;
        if (v_dteeffex > v_stdate) and (v_dteeffex <= v_endate) then
           b_var_staemp := '1'; --ลาออกระหว่างงวด
        elsif v_dteeffex =  v_endate + 1 then
           b_var_staemp := '5'; --ลาออกงวดนี้
        elsif v_dteempmt > v_stdate and v_dteempmt <= v_endate then
           b_var_staemp := '2'; --เข้างานระหว่างงวด
        elsif v_dteempmt > v_endate then
          v_stdate := v_dteempmt;
        end if;

        if (v_qtyday <= 0) or p_process = 'HRPY44B' then -- check data no cal
            v_count := 0;
            begin
                select count(codempid) into v_count
                     from totsum
                    where codempid  = temploy1_codempid
                      and dteyrepay = b_index_dteyrepay - v_zyear
                      and dtemthpay = b_index_dtemthpay
                      and numperiod = b_index_numperiod;

                if v_count = 0 then
                    select count(codempid) into v_count
                       from tothinc
                      where codempid  = temploy1_codempid
                        and	dteyrepay = b_index_dteyrepay - v_zyear
                        and	dtemthpay = b_index_dtemthpay
                        and	numperiod = b_index_numperiod;
                end if;

                if v_count = 0 then
                    select count(codempid) into v_count
                       from tothpay
                      where codempid  = temploy1_codempid
                        and dteyrepay = b_index_dteyrepay - v_zyear
                        and dtemthpay = b_index_dtemthpay
                        and numperiod = b_index_numperiod;
                end if;

                if  p_process = 'HRPY44B' then
                  v_stdate := null;
                  v_endate := null;
                  begin
                    select dtestrt,dteend
                    into b_var_dtebeg,b_var_dteend
                    from tdtepay
                    where codcompy   = b_var_codcompy
                      and typpayroll = b_var_typpayroll
                      and dteyrepay  = (b_index_dteyrepay - v_zyear)
                      and dtemthpay  = b_index_dtemthpay
                      and numperiod  = (select max(numperiod)
                                          from tdtepay
                                         where codcompy   = b_var_codcompy
                                           and typpayroll = b_var_typpayroll
                                           and dteyrepay  = (b_index_dteyrepay - v_zyear)
                                           and dtemthpay  = b_index_dtemthpay);
                  exception when no_data_found then
                    null;
                  end;
                  v_stdate := b_var_dtebeg;
                  v_endate := b_var_dteend;
                end if;

                if v_count = 0 then
                 select count(codempid)
                             into v_count
                   from tempinc
                  where codempid = temploy1_codempid
                    and dtestrt <= v_endate
                    and periodpay = to_char(b_index_numperiod)
                    and	(((dtecancl is not null) and (dtecancl > v_stdate)) or
                         ((dtecancl is null) and ((dteend is null) or
                                                  ((dteend is not null) and (dteend >= v_stdate)))));
                end if;

                if v_count = 0 then
                    goto loop_next;
                end if;
            end;
        end if;  -- stacal = '4'
        b_var_ratechge := 1;
        if temploy3_codcurr <> tcontpm_codcurr then -- check สกุลเงิน เพื่อเอาไว้แลกเปลี่ยนสกุลเงิน
            begin
                select ratechge
                  into b_var_ratechge
                  from tratechg
                 where dteyrepay = b_index_dteyrepay - v_zyear
                   and dtemthpay = b_index_dtemthpay
                   and codcurr   = tcontpm_codcurr
                   and codcurr_e = temploy3_codcurr;
            exception when no_data_found then
                insert_error(get_errorm_name('HR2010',v_lang)||' (TRATECHG)');
                goto loop_next;
            end;
        end if;

        if  p_process = 'HRPY44B' then
            v_stdate := null;
            v_endate := null;
            begin
              select dtestrt,dteend
              into b_var_dtebeg,b_var_dteend
              from tdtepay
              where codcompy   = b_var_codcompy
                and typpayroll = b_var_typpayroll
                and	dteyrepay  = (b_index_dteyrepay - v_zyear)
                and	dtemthpay  = b_index_dtemthpay
                and numperiod  = (select max(numperiod)
                                    from tdtepay
                                   where codcompy   = b_var_codcompy
                                     and typpayroll = b_var_typpayroll
                                     and dteyrepay  = (b_index_dteyrepay - v_zyear)
                                     and dtemthpay  = b_index_dtemthpay);
            exception when no_data_found then
              null;
            end;
            v_stdate := b_var_dtebeg;
            v_endate := b_var_dteend;
        end if;
        if v_qtyday > 0 or p_process = 'HRPY41B' then
            v_deduct := 0 ;
            cal_bassal(v_stdate,v_endate,v_qtyday,v_deduct,v_numday);
        else
            if p_process = 'HRPY44B' then
                cal_bassal_hrpy44b;
            end if;
        end if;
        b_var_amt_oth := 0 ;
        cal_oth_ot;
        -- declare_var_v_amtothfix := 0;
        if v_qtyday > 0 and p_process = 'HRPY41B' then
            cal_tempinc(v_stdate,v_endate);
        else
            if p_process = 'HRPY44B'  then
                cal_tempinc_hrpy44b(v_stdate,v_endate);
                cal_tempinc_estimate(v_stdate,v_endate);
            end if;
        end if;
        if parameter_emp_error = 'Y' then
            goto loop_next;
        end if;
        cal_studyded ; -- จ่ายเงิน กยศ. กรอ.
        cal_Legalded(v_net_ded)   ; -- หักกรมบังคับคดี
        cal_tax(v_stdate,v_endate,p_process);
        cal_tothpay;
        upd_ttaxmasl;
        if b_var_amtcal <> 0 or b_var_amt_oth <> 0  then
            b_index_sumrec	:= b_index_sumrec + 1;
        end if;
        <<loop_next>>
        null;
    end if; -- p_secur = true
  end loop; -- c_emp
    update tprocount
     set qtyproc  = b_index_sumrec,
         qtyerr   = b_index_sumerr,
         flgproc  = 'Y'
    where codapp  = p_codapp
      and coduser = p_coduser
      and numproc = p_numproc ;

    commit;
    p_sumrec :=	b_index_sumrec;
    p_sumerr := b_index_sumerr;

exception when others then
  v_sqlerrm := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace ;
 	update tprocount
     set qtyproc  = b_index_sumrec,
         qtyerr   = b_index_sumerr,
         codempid = temploy1_codempid ,
         dteupd   = sysdate,
         Flgproc  = 'E',
         remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,1500)
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc ;
  commit;

END; --PROCEDURE start_process

procedure clear_olddata is
  cursor c_ttaxcur is
    select codempid,amtnet,amtcal,amtincl,amtincc,amtincn,
           amtexpl,amtexpc,amtexpn,amttax,amtgrstx,
				   amtcprv,amtprove,amtprovc,amtproic,amtproie,
           amtsoc,amtsoca,amtsocc,qtywork,amtcalc,
           amtothe,amtothc,amtotho,amttaxoth,rowid
	   from ttaxcur
	  where codempid  = temploy1_codempid
	    and dteyrepay = b_index_dteyrepay - v_zyear
	    and dtemthpay = b_index_dtemthpay
	    and numperiod = b_index_numperiod;
cursor c_ttaxpf is
	select rowid,codpolicy,amtprove,amtprovc,dteeffec
	  FROM ttaxpf
	 where codempid  = temploy1_codempid
	   and dteyrepay = b_index_dteyrepay - v_zyear
	   and dtemthpay = b_index_dtemthpay
	   and numperiod = b_index_numperiod;
cursor c_tlegalprd is
	SELECT rowid,codempid ,numcaselw,numtime, stddec(amtded,codempid,v_chken) amtded
	  FROM tlegalprd
	 where codempid  = temploy1_codempid
	   and dteyrepay = b_index_dteyrepay - v_zyear
	   and dtemthpay = b_index_dtemthpay
     and numtime   = b_index_numperiod; --<< user46 14/12/2021 NXP-HR2101

BEGIN

 for i in c_tlegalprd loop
       update tlegalexe set amtded		= stdenc(stddec(amtded,codempid,v_chken) - i.amtded,codempid,v_chken)   ,
                            qtyperded	= nvl(qtyperded,0) - 1
       where codempid  = i.codempid
       and   numcaselw = i.numcaselw   ;

       delete  tlegalprd
--<< user46 14/12/2021 NXP-HR2101       
       where rowid = i.rowid ;
       /*codempid  = temploy1_codempid
       and   numcaselw = i.numcaselw
       and   numtime = i.numtime ;*/
       delete from tlegalexp -->> user46 04/05/2022
        where codempid    = temploy1_codempid
          and numcaselw   = i.numcaselw
          and dteyrepay   = b_index_dteyrepay - v_zyear
          and dtemthpay   = b_index_dtemthpay
          and numperiod   = b_index_numperiod;
-->> user46 14/12/2021 NXP-HR2101
  end loop ;

  delete tothded
  where codempid  = temploy1_codempid
  and dteyrepay	= b_index_dteyrepay - v_zyear
  and dtemthpay	= b_index_dtemthpay
  and numperiod	= b_index_numperiod ;

  update  tloanslf  set amtdedstu = null , amtdedstuf = null ,codremark = null
  where codempid  = temploy1_codempid
  and dteyrepay	= b_index_dteyrepay - v_zyear
  and dtemthpay	= b_index_dtemthpay
  ;


  delete from	tsincexp
	where codempid  = temploy1_codempid
	  and dteyrepay	= b_index_dteyrepay - v_zyear
	  and dtemthpay	= b_index_dtemthpay
	  and numperiod	= b_index_numperiod
	  and flgslip   = '1';

	delete from	tinctxpnd
	where codempid  = temploy1_codempid
	  and dteyrepay	= b_index_dteyrepay - v_zyear
	  and dtemthpay	= b_index_dtemthpay
	  and numperiod	= b_index_numperiod;

  update tfincadj	set staupd = 'T'
	 where codempid   = temploy1_codempid
	   and dteyrepay	= b_index_dteyrepay - v_zyear
	   and dtemthpay	= b_index_dtemthpay
	   and numperiod	= b_index_numperiod
	   and staupd     = 'U';

  for r_ttaxpf in c_ttaxpf loop
	  delete from	ttaxpf
	  where rowid = r_ttaxpf.rowid;
  end loop;

  for r_ttaxcur in c_ttaxcur loop
    update tssmemb
		   set accmemb	=	stdenc(stddec(accmemb,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtsoca,temploy1_codempid,v_chken),temploy1_codempid,v_chken)
		 where codempid = temploy1_codempid;

    update tpfmemb
	  set amtcaccu = stdenc(stddec(amtcaccu,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtprovc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
	      amteaccu = stdenc(stddec(amteaccu,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtprove,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
	      amtintaccu = stdenc(stddec(amtintaccu,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtproic,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
	      amtinteccu = stdenc(stddec(amtinteccu,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtproie,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken)
		where	codempid = temploy1_codempid;

		update ttaxmas
		set amtnett  =	stdenc(stddec(amtnett,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtnet,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtcalt	 =	stdenc(stddec(amtcalt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtcal,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtinclt = stdenc(stddec(amtinclt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtincl,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtincct = stdenc(stddec(amtincct,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtincc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtincnt = stdenc(stddec(amtincnt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtincn,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtexplt = stdenc(stddec(amtexplt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtexpl,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtexpct = stdenc(stddec(amtexpct,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtexpc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtexpnt = stdenc(stddec(amtexpnt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtexpn,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amttaxt  =	stdenc(stddec(amttaxt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amttax,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtsoct  =	stdenc(stddec(amtsoct,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtsoc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtsocat = stdenc(stddec(amtsocat,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtsoca,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtsocct = stdenc(stddec(amtsocct,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtsocc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtcprvt = stdenc(stddec(amtcprvt,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtcprv,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtprovte =	stdenc(stddec(amtprovte,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtprove,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				amtprovtc =	stdenc(stddec(amtprovtc,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtprovc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
        --
        amtcalct  =	stdenc(stddec(amtcalct,temploy1_codempid,v_chken) - stddec(r_ttaxcur.amtcalc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
        amtothe   =	stdenc(stddec(amtothe,temploy1_codempid,v_chken)  - stddec(r_ttaxcur.amtothe,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
        amtothc   =	stdenc(stddec(amtothc,temploy1_codempid,v_chken)  - stddec(r_ttaxcur.amtothc,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
        amtotho   =	stdenc(stddec(amtotho,temploy1_codempid,v_chken)  - stddec(r_ttaxcur.amtotho,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
        amttaxoth =	stdenc(stddec(amttaxoth,temploy1_codempid,v_chken)  - stddec(r_ttaxcur.amttaxoth,r_ttaxcur.codempid,v_chken),temploy1_codempid,v_chken),
				qtyworkt  = qtyworkt - r_ttaxcur.qtywork
    where	codempid  = temploy1_codempid
      and dteyrepay	= b_index_dteyrepay - v_zyear;

	  delete from	ttaxcur
	  where rowid = r_ttaxcur.rowid;

    delete 	ttaxmasl
    where codempid = temploy1_codempid
    and dteyrepay = b_index_dteyrepay - v_zyear
    and dtemthpay	= b_index_dtemthpay
	  and numperiod	= b_index_numperiod;

    delete 	ttaxmasf
    where codempid = temploy1_codempid
    and dteyrepay = b_index_dteyrepay - v_zyear
    and dtemthpay	= b_index_dtemthpay
	  and numperiod	= b_index_numperiod;

	  delete 	ttaxmasd
    where codempid = temploy1_codempid
    and dteyrepay = b_index_dteyrepay - v_zyear
    and dtemthpay	= b_index_dtemthpay
	  and numperiod	= b_index_numperiod;

  end loop; --c_ttaxcur
end;

PROCEDURE exec_temploy3 IS
    v_flgupd		boolean := false;
    v_flgupdsp	    boolean := false;
    v_exit          boolean := false;
    v_chk           varchar2(1 char) := 'N';

  cursor c_temploy3 is
	  select rowid,codempid,typtax,flgtax,codcurr,numsaid,typincom,
				   stddec(amtincom1,codempid,v_chken) amtincom1,
				   stddec(amtincom2,codempid,v_chken) amtincom2,
				   stddec(amtincom3,codempid,v_chken) amtincom3,
				   stddec(amtincom4,codempid,v_chken) amtincom4,
				   stddec(amtincom5,codempid,v_chken) amtincom5,
				   stddec(amtincom6,codempid,v_chken) amtincom6,
				   stddec(amtincom7,codempid,v_chken) amtincom7,
				   stddec(amtincom8,codempid,v_chken) amtincom8,
				   stddec(amtincom9,codempid,v_chken) amtincom9,
				   stddec(amtincom10,codempid,v_chken) amtincom10,
				   codbank,numbank,codbank2,numbank2,amtbank,dtebf,dtebfsp,
				   stddec(amtincbf,codempid,v_chken) amtincbf,
				   stddec(amttaxbf,codempid,v_chken) amttaxbf,
				   stddec(amtpf,codempid,v_chken) amtpf,
				   stddec(amtsaid,codempid,v_chken) amtsaid,
				   stddec(amtincsp,codempid,v_chken) amtincsp,
				   stddec(amttaxsp,codempid,v_chken) amttaxsp,
				   stddec(amtpfsp,codempid,v_chken) amtpfsp,
				   stddec(amtsasp,codempid,v_chken) amtsasp
	  from temploy3
	  where codempid = b_var_codempid;

  cursor c_tdeductd is
    select coddeduct,flgclear
      from tdeductd
    where codcompy = b_var_codcompy
      and dteyreff = (select max(dteyreff)
                        from tdeductd
                       where codcompy = b_var_codcompy
                         and dteyreff <= (b_index_dteyrepay - v_zyear))
      and flgclear = 'Y'
    order by coddeduct;

  cursor c_tempded is
    select coddeduct,amtdeduct,amtspded
      from tempded
     where codempid = b_var_codempid
     order by coddeduct;

BEGIN
  for r1 in c_temploy3 loop

    if to_number(to_char(r1.dtebf,'yyyy')) < (b_index_dteyrepay - v_zyear) then -- ถ้าปีที่คำนวณมากกว่าปียอดยกมาในระบบให้ clear ยอดยกมา เพราะว่าถือว่าคำนวณไปแล้วในปีก่อนหน้า
  	--if to_number(to_char(r1.dtebf,'yyyy')) < (b_index_dteyrepay) then
    	v_flgupd    := true;
  		r1.dtebf    := to_date('01/01/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
      r1.amtincbf	:= 0;
			r1.amttaxbf	:= 0;
			r1.amtpf    := 0;
			r1.amtsaid  := 0;
  	end if;

    if to_number(to_char(r1.dtebfsp,'yyyy')) < (b_index_dteyrepay - v_zyear) then -- ถ้าปีที่คำนวณมากกว่าปียอดยกมาในระบบให้ clear ยอดยกมา เพราะว่าถือว่าคำนวณไปแล้วในปีก่อนหน้า
  		v_flgupdsp  := true;
  		r1.dtebfsp  := to_date('01/01/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
			r1.amtincsp	:= 0;
			r1.amttaxsp	:= 0;
			r1.amtpfsp  := 0;
			r1.amtsasp  := 0;
  	end if;

  	if v_flgupd or v_flgupdsp then
      --- Process HRPY6KB ประมวลผลประจำปี---
      process_clearyear;

      update temploy3 set dtebf     = r1.dtebf,
                          amtincbf  = stdenc(nvl(r1.amtincbf,0),codempid,v_chken),
                          amttaxbf  = stdenc(nvl(r1.amttaxbf,0),codempid,v_chken),
                          amtpf     = stdenc(nvl(r1.amtpf,0),codempid,v_chken),
                          amtsaid   = stdenc(nvl(r1.amtsaid,0),codempid,v_chken),
                          dtebfsp   = r1.dtebfsp,
                          amtincsp  = stdenc(nvl(r1.amtincsp,0),codempid,v_chken),
                          amttaxsp  = stdenc(nvl(r1.amttaxsp,0),codempid,v_chken),
                          amtpfsp   = stdenc(nvl(r1.amtpfsp,0),codempid,v_chken),
                          amtsasp	  = stdenc(nvl(r1.amtsasp,0),codempid,v_chken)
      where rowid = r1.rowid;
      for r_tdeductd in c_tdeductd loop -- clear ข้อมูลลดหย่อน
        delete tempded where codempid = temploy1_codempid and coddeduct = r_tdeductd.coddeduct;
      end loop;
    end if;

		temploy3_codempid   := r1.codempid;
		temploy3_typtax     := r1.typtax;
		temploy3_flgtax     := r1.flgtax;
		temploy3_codcurr    := r1.codcurr;
    temploy3_typincom   := r1.typincom;
		temploy3_numsaid	  := r1.numsaid;
		temploy3_amtincom1  := nvl(r1.amtincom1,0);
		temploy3_amtincom2	:= nvl(r1.amtincom2,0);
		temploy3_amtincom3	:= nvl(r1.amtincom3,0);
		temploy3_amtincom4	:= nvl(r1.amtincom4,0);
		temploy3_amtincom5	:= nvl(r1.amtincom5,0);
		temploy3_amtincom6	:= nvl(r1.amtincom6,0);
		temploy3_amtincom7	:= nvl(r1.amtincom7,0);
		temploy3_amtincom8	:= nvl(r1.amtincom8,0);
		temploy3_amtincom9	:= nvl(r1.amtincom9,0);
		temploy3_amtincom10 := nvl(r1.amtincom10,0);
		temploy3_codbank    := r1.codbank;
		temploy3_numbank	  := r1.numbank;
		temploy3_codbank2   := r1.codbank2;
		temploy3_numbank2   := r1.numbank2;
		temploy3_amtbank	  := nvl(r1.amtbank,0);
		temploy3_amtincbf   := nvl(r1.amtincbf,0);
		temploy3_amttaxbf   := nvl(r1.amttaxbf,0);
		temploy3_amtpf      := nvl(r1.amtpf,0);
		temploy3_amtsaid    := nvl(r1.amtsaid,0);
		temploy3_amtincsp   := nvl(r1.amtincsp,0);
		temploy3_amttaxsp   := nvl(r1.amttaxsp,0);
		temploy3_amtpfsp    := nvl(r1.amtpfsp,0);
		temploy3_amtsasp    := nvl(r1.amtsasp,0);
  end loop;
END;

procedure insert_error (p_error in varchar2) is
  v_numseq    number;
  v_codapp    varchar2(30):= 'HRPY41B'||v_numproc;
begin

    b_index_sumerr	:= b_index_sumerr + 1;
    begin
      select max(numseq)
        into v_numseq
        from ttemfilt
       where codapp  = v_codapp
         and coduser = v_coduser;
    end;

    v_numseq  := nvl(v_numseq,0) + 1;
    parameter_emp_error := 'Y';
    insert into ttemfilt (coduser,codapp,numseq,
                          tableadj,wheresql,flgbrk,
                          item01,item02,item03,
                          temp01,item11,temp11)
                   values(v_coduser,v_codapp,v_numseq,
                          'v_temploy',' v_temploy.codempid = '''||temploy1_codempid||'''','N',
                          temploy1_codempid, get_temploy_name(temploy1_codempid,v_lang), p_error,
                          b_index_sumerr,'HRPY41B',v_numproc);
end;


procedure msg_err (p_error in varchar2) is
  v_numseq    number;
  v_codapp    varchar2(30):= 'HRPY41MSG'||v_numproc;
begin
 --if  v_flagbug = 'Y' and v_coduser ='PPSIMP'   then
   if  v_coduser ='PPSIMP'   then 
     begin
      select max(numseq)
        into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = temploy1_codempid;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq,item1)
                   values(temploy1_codempid,v_codapp,v_numseq,p_error);
 end if;
end;

PROCEDURE cal_bassal(  p_stdate in date,
	                   p_endate in date,
	                   p_qtyday in number,
	                   p_deduct in number,
	                   p_numday	in number) is

    v_stmonth		number;
    v_enmonth		number;
    v_month			number;
    v_amt1			number;
    v_amt2			number;
    v_amt3			number;
    v_codpay		tinexinf.codpay%type;
    v_flgcal		tinexinf.flgcal%type;
    v_flgsoc		tinexinf.flgsoc%type;
    v_flgpvdf		tinexinf.flgpvdf%type;
    v_formulam	    tcontpmd.formulam%type;
    v_length		number;
    v_stmtcal		varchar2(200);
    v_stmtsoc		varchar2(200);
    v_stmtpro		varchar2(200);
    v_amtcal		number;
    v_socfix		number;
    v_profix		number;
    v_codempmt	    temploy1.codempmt%type;
    v_dteeffec	    date;
    v_day			number;
    v_dteendo		date;
    v_dayretro      number := 0;
    v_amtpaylast    number := 0;
    v_amtpaynow     number := 0;
    v_dteyrepay     number := 0;
    v_dtemthpay     number := 0;
    v_numperiod     number := 0;
    v_amtpayinc     number := 0;
    v_amtpayrto     number := 0;
    v_run           number := 0;
    v_dteyrepayrt   number := 0;
    v_dtemthpayrt   number := 0;
    v_numperiodrt   number := 0;
    v_flgplus       varchar2(1) := 'N';

	type char1 is table of varchar2(1) index by binary_integer;
	  v_unitcal		char1;
	  v_unitcaln	char1;
	  v_unitcalo	char1;

	type char2 is table of tinexinf.codpay%type index by binary_integer;
	  v_codincom	char2;
	  v_codretro	char2;

	type number1 is table of number index by binary_integer;
		v_amtincom	number1;
		v_amtincn	number1;
		v_amtinco	number1;
		v_amtadj	number1;
		v_amtretro	number1;
		v_amt		number1;
		v_amtchg	number1;

    v_amtincpay number1;
    v_amtrtopay number1;
    v_amtrtonew number1;
    v_amtstprid number1;


  cursor c_tfincadj0 is
    select  codempmtt,stddec(amtincn1,codempid,v_chken) amtincn1,
            stddec(amtincn2,codempid,v_chken) amtincn2,
            stddec(amtincn3,codempid,v_chken) amtincn3,
            stddec(amtincn4,codempid,v_chken) amtincn4,
            stddec(amtincn5,codempid,v_chken) amtincn5,
            stddec(amtincn6,codempid,v_chken) amtincn6,
            stddec(amtincn7,codempid,v_chken) amtincn7,
            stddec(amtincn8,codempid,v_chken) amtincn8,
            stddec(amtincn9,codempid,v_chken) amtincn9,
            stddec(amtincn10,codempid,v_chken) amtincn10
	   from tfincadj t1
	  where codempid = temploy1_codempid
	    and dteeffec > p_endate
	    and staupd = 'T'
--<<Redmine#7881 user46 25/04/2022 Probat 0003 = ทดลองงาน, 0004 = ทดลองตำแหน่ง
      and (nvl(codadjin,'@#$%') not in ('0003','0004')
           or
           exists (select 1
                     from ttprobat
                    where codempid  = t1.codempid
                      and nvl(dteoccup,dteduepr) = t1.dteeffec
                      and staupd    = 'U'
                      and rownum    = 1)
           )
-->>Redmine#7881 user46 25/04/2022
	  order by dteeffec,numseq;

  cursor c_tfincadj1 is -- income adjust
    select  rowid,dteeffec,codempmt,codempmtt,
            stddec(amtincn1,codempid,v_chken) amtincn1,
            stddec(amtincn2,codempid,v_chken) amtincn2,
            stddec(amtincn3,codempid,v_chken) amtincn3,
            stddec(amtincn4,codempid,v_chken) amtincn4,
            stddec(amtincn5,codempid,v_chken) amtincn5,
            stddec(amtincn6,codempid,v_chken) amtincn6,
            stddec(amtincn7,codempid,v_chken) amtincn7,
            stddec(amtincn8,codempid,v_chken) amtincn8,
            stddec(amtincn9,codempid,v_chken) amtincn9,
            stddec(amtincn10,codempid,v_chken) amtincn10,
            stddec(amtinco1,codempid,v_chken) amtinco1,
            stddec(amtinco2,codempid,v_chken) amtinco2,
            stddec(amtinco3,codempid,v_chken) amtinco3,
            stddec(amtinco4,codempid,v_chken) amtinco4,
            stddec(amtinco5,codempid,v_chken) amtinco5,
            stddec(amtinco6,codempid,v_chken) amtinco6,
            stddec(amtinco7,codempid,v_chken) amtinco7,
            stddec(amtinco8,codempid,v_chken) amtinco8,
            stddec(amtinco9,codempid,v_chken) amtinco9,
            stddec(amtinco10,codempid,v_chken) amtinco10,
            codincom1,codincom2,codincom3,codincom4,codincom5,
            codincom6,codincom7,codincom8,codincom9,codincom10
	  from tfincadj
	  where codempid = temploy1_codempid
	    and dteeffec between p_stdate and p_endate
	    and staupd = 'T'
	  order by codempid,dteeffec,numseq;

  cursor c_tfincadj2 is -- retro
    select  rowid,dteeffec,codempmt,codempmtt,
            stddec(amtincn1,codempid,v_chken) amtincn1,
            stddec(amtincn2,codempid,v_chken) amtincn2,
            stddec(amtincn3,codempid,v_chken) amtincn3,
            stddec(amtincn4,codempid,v_chken) amtincn4,
            stddec(amtincn5,codempid,v_chken) amtincn5,
            stddec(amtincn6,codempid,v_chken) amtincn6,
            stddec(amtincn7,codempid,v_chken) amtincn7,
            stddec(amtincn8,codempid,v_chken) amtincn8,
            stddec(amtincn9,codempid,v_chken) amtincn9,
            stddec(amtincn10,codempid,v_chken) amtincn10,
            stddec(amtinco1,codempid,v_chken) amtinco1,
            stddec(amtinco2,codempid,v_chken) amtinco2,
            stddec(amtinco3,codempid,v_chken) amtinco3,
            stddec(amtinco4,codempid,v_chken) amtinco4,
            stddec(amtinco5,codempid,v_chken) amtinco5,
            stddec(amtinco6,codempid,v_chken) amtinco6,
            stddec(amtinco7,codempid,v_chken) amtinco7,
            stddec(amtinco8,codempid,v_chken) amtinco8,
            stddec(amtinco9,codempid,v_chken) amtinco9,
            stddec(amtinco10,codempid,v_chken) amtinco10,
            codincom1,codincom2,codincom3,codincom4,codincom5,
            codincom6,codincom7,codincom8,codincom9,codincom10,
            dteyrepay,dtemthpay,numperiod
	   from tfincadj
	  where codempid = temploy1_codempid
	    and dteeffec < p_stdate
	    and staupd = 'T'
	  order by codempid,dteeffec,numseq;

    cursor c_tdtepay is
      select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
        from tdtepay
       where codcompy   = b_var_codcompy
         and typpayroll = b_var_typpayroll
         and dteend between v_dteeffec and (b_var_dtebeg - 1) -- dteeffec ของ tfincadj2
      order by dteyrepay desc,dtemthpay desc,numperiod desc;

    cursor c_ttaxcur is
        select dteyrepay,dtemthpay,numperiod,hcm_util.get_codcomp_level(codcomp,1) codcompyo,typpayroll typpayrollo
          from ttaxcur
         where codempid = temploy1_codempid
      order by dteyrepay desc,dtemthpay desc,numperiod desc;

begin
    for i in 1..10 loop
        v_codincom(i) := null;
        v_codretro(i) := null;
        v_unitcal(i)  := null;
        v_unitcaln(i) := null;
        v_unitcalo(i) := null;
        v_amtincom(i) := 0;
        v_amtadj(i)   := 0;
        v_amtretro(i) := 0;
        v_amt(i)      := 0;
        v_amtincpay(i):= 0;
        v_amtrtopay(i):= 0;
        v_amtrtonew(i):= 0;
        v_amtstprid(i):= 0;
    end loop;
    -- หาฐานเงินเดือน ณ วันสิ้นรอบ
    v_codempmt := temploy1_codempmt;
    for r_tfincadj0 in c_tfincadj0 loop -- กรณีมีการปรับรายได้ที่ยังไม่ถึงรอบคำรนวณจะต้องหารายได้เดิมก่อนปรับ
        v_codempmt := r_tfincadj0.codempmtt;
        temploy3_amtincom1 := nvl(temploy3_amtincom1,0) - nvl(r_tfincadj0.amtincn1,0);
        temploy3_amtincom2 := nvl(temploy3_amtincom2,0) - nvl(r_tfincadj0.amtincn2,0);
        temploy3_amtincom3 := nvl(temploy3_amtincom3,0) - nvl(r_tfincadj0.amtincn3,0);
        temploy3_amtincom4 := nvl(temploy3_amtincom4,0) - nvl(r_tfincadj0.amtincn4,0);
        temploy3_amtincom5 := nvl(temploy3_amtincom5,0) - nvl(r_tfincadj0.amtincn5,0);
        temploy3_amtincom6 := nvl(temploy3_amtincom6,0) - nvl(r_tfincadj0.amtincn6,0);
        temploy3_amtincom7 := nvl(temploy3_amtincom7,0) - nvl(r_tfincadj0.amtincn7,0);
        temploy3_amtincom8 := nvl(temploy3_amtincom8,0) - nvl(r_tfincadj0.amtincn8,0);
        temploy3_amtincom9 := nvl(temploy3_amtincom9,0) - nvl(r_tfincadj0.amtincn9,0);
        temploy3_amtincom10 := nvl(temploy3_amtincom10,0) - nvl(r_tfincadj0.amtincn10,0);
    end loop;

    begin
        select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
               unitcal6,unitcal7,unitcal8,unitcal9,unitcal10,formulam
          into v_unitcal(1),v_unitcal(2),v_unitcal(3),v_unitcal(4),v_unitcal(5),
               v_unitcal(6),v_unitcal(7),v_unitcal(8),v_unitcal(9),v_unitcal(10),v_formulam
         from tcontpmd -- hrpmbde
        where codcompy = b_var_codcompy
          and codempmt = v_codempmt
          and dteeffec = (select max(dteeffec)
                            from tcontpmd
                           where codcompy = b_var_codcompy
                             and codempmt = v_codempmt
                             and dteeffec <= sysdate);
    exception when no_data_found then
        insert_error(get_errorm_name('HR2010',v_lang)||' (TCONTPMD)');
        return;
    end;

    b_var_amtcal := 0;
    b_var_socfix := 0;
    b_var_profix := 0;

    v_codincom(1) := tcontpms_codincom1;
    v_amtincom(1) := nvl(temploy3_amtincom1,0);
    v_amtchg(1)   := nvl(temploy3_amtincom1,0);

    v_codincom(2) := tcontpms_codincom2;
    v_amtincom(2) := nvl(temploy3_amtincom2,0);
    v_amtchg(2)   := nvl(temploy3_amtincom2,0);

    v_codincom(3) := tcontpms_codincom3;
    v_amtincom(3) := nvl(temploy3_amtincom3,0);
    v_amtchg(3)   := nvl(temploy3_amtincom3,0);

    v_codincom(4) := tcontpms_codincom4;
    v_amtincom(4) := nvl(temploy3_amtincom4,0);
    v_amtchg(4)   := nvl(temploy3_amtincom4,0);

    v_codincom(5) := tcontpms_codincom5;
    v_amtincom(5) := nvl(temploy3_amtincom5,0);
    v_amtchg(5)   := nvl(temploy3_amtincom5,0);

    v_codincom(6) := tcontpms_codincom6;
    v_amtincom(6) := nvl(temploy3_amtincom6,0);
    v_amtchg(6)   := nvl(temploy3_amtincom6,0);

    v_codincom(7) := tcontpms_codincom7;
    v_amtincom(7) := nvl(temploy3_amtincom7,0);
    v_amtchg(7)   := nvl(temploy3_amtincom7,0);

    v_codincom(8) := tcontpms_codincom8;
    v_amtincom(8) := nvl(temploy3_amtincom8,0);
    v_amtchg(8)   := nvl(temploy3_amtincom8,0);

    v_codincom(9) := tcontpms_codincom9;
    v_amtincom(9) := nvl(temploy3_amtincom9,0);
    v_amtchg(9)   := nvl(temploy3_amtincom9,0);

    v_codincom(10) := tcontpms_codincom10;
    v_amtincom(10) := nvl(temploy3_amtincom10,0);
    v_amtchg(10)   := nvl(temploy3_amtincom10,0);

	-- WAGE PER MONTH
	if v_formulam is not null then -- แทนค่าในสูตรและคำนวณหารายได้ต่อเดือน
		v_length := length(v_formulam);
		v_stmtcal := v_formulam;
		v_stmtsoc := v_formulam;
		v_stmtpro := v_formulam;
		for i in 1..v_length loop
			if substr(v_formulam,i,2) = '{&' then
				--v_codpay := substr(v_formulam, i+1, 2);
                v_codpay := substr(v_formulam,i + 2,instr(substr(v_formulam,i + 2) ,'}') -1) ;
				v_amtcal := 0;
				v_socfix := 0;
				v_profix := 0;
				for j in 1..10 loop
				  if v_codpay = v_codincom(j) then
						begin
							select flgcal,flgsoc,flgpvdf
							  into v_flgcal,v_flgsoc,v_flgpvdf
							  from tinexinf
							 where codpay = v_codpay;

							if v_flgcal = 'Y' then -- เช็คว่าเป็นรายได้ที่ต้องคำนวณภาษีหรือไม่
                                v_amtcal := v_amtincom(j);
							end if;
							if v_flgsoc = 'Y' then -- เช็คว่าเป็นรายได้ที่ต้องคำนวณประกันสังคมหรือไม่
								v_socfix := v_amtincom(j);
							end if;
							if v_flgpvdf = 'Y' then -- เช็คว่าเป็นรายได้ที่ต้องคำนวณกองทุนหรือไม่
								v_profix := v_amtincom(j);
							end if;
						exception when no_data_found then
							null;
						end;
				  	exit;
				  end if;
				end loop;
        v_stmtcal := replace(v_stmtcal,substr(v_stmtcal,instr(v_stmtcal,'{&'),instr( substr(v_stmtcal,instr(v_stmtcal,'{&')), '}') ),v_amtcal);
        v_stmtsoc := replace(v_stmtsoc,substr(v_stmtsoc,instr(v_stmtsoc,'{&'),instr( substr(v_stmtsoc,instr(v_stmtsoc,'{&')), '}') ),v_socfix);
        v_stmtpro := replace(v_stmtpro,substr(v_stmtpro,instr(v_stmtpro,'{&'),instr( substr(v_stmtpro,instr(v_stmtpro,'{&')), '}') ),v_profix);
			end if;
		end loop;
        b_var_amtcal := execute_sql('select '||v_stmtcal||' from dual') * b_var_ratechge;
		b_var_socfix := execute_sql('select '||v_stmtsoc||' from dual') * b_var_ratechge;
		b_var_profix := execute_sql('select '||v_stmtpro||' from dual') * b_var_ratechge;
	end if;

	-- INCOME ADJUST
  for r_tfincadj1 in c_tfincadj1 loop
  	v_amtincn(1) := r_tfincadj1.amtincn1; 		v_amtinco(1) := r_tfincadj1.amtinco1;
  	v_amtincn(2) := r_tfincadj1.amtincn2; 		v_amtinco(2) := r_tfincadj1.amtinco2;
  	v_amtincn(3) := r_tfincadj1.amtincn3; 		v_amtinco(3) := r_tfincadj1.amtinco3;
  	v_amtincn(4) := r_tfincadj1.amtincn4; 		v_amtinco(4) := r_tfincadj1.amtinco4;
  	v_amtincn(5) := r_tfincadj1.amtincn5; 		v_amtinco(5) := r_tfincadj1.amtinco5;
  	v_amtincn(6) := r_tfincadj1.amtincn6; 		v_amtinco(6) := r_tfincadj1.amtinco6;
  	v_amtincn(7) := r_tfincadj1.amtincn7; 		v_amtinco(7) := r_tfincadj1.amtinco7;
  	v_amtincn(8) := r_tfincadj1.amtincn8; 		v_amtinco(8) := r_tfincadj1.amtinco8;
  	v_amtincn(9) := r_tfincadj1.amtincn9; 		v_amtinco(9) := r_tfincadj1.amtinco9;
  	v_amtincn(10) := r_tfincadj1.amtincn10; 	v_amtinco(10) := r_tfincadj1.amtinco10;

    begin -- new codempmt
        select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
               unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
          into v_unitcaln(1),v_unitcaln(2),v_unitcaln(3),v_unitcaln(4),v_unitcaln(5),
               v_unitcaln(6),v_unitcaln(7),v_unitcaln(8),v_unitcaln(9),v_unitcaln(10)
        from tcontpmd
        where codcompy = b_var_codcompy
          and codempmt = r_tfincadj1.codempmt
          and dteeffec = (select max(dteeffec)
                            from tcontpmd
                           where codcompy = b_var_codcompy
                             and codempmt = r_tfincadj1.codempmt
                             and dteeffec <= sysdate);
    exception when no_data_found then
        null;
    end;

    begin -- old codempmt
        select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
               unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
          into v_unitcalo(1),v_unitcalo(2),v_unitcalo(3),v_unitcalo(4),v_unitcalo(5),
               v_unitcalo(6),v_unitcalo(7),v_unitcalo(8),v_unitcalo(9),v_unitcalo(10)
        from tcontpmd
        where codcompy = b_var_codcompy
          and codempmt = r_tfincadj1.codempmtt
          and dteeffec = (select max(dteeffec)
                            from tcontpmd
                           where codcompy = b_var_codcompy
                             and codempmt = r_tfincadj1.codempmtt
                             and dteeffec <= sysdate);
    exception when no_data_found then
        null;
    end;

    for i in 1..10 loop
        v_amtchg(i) := v_amtinco(i);
        if v_unitcaln(i) = 'M' then
            if v_unitcalo(i) = 'M' then
              v_amtincom(i) := v_amtincom(i) - v_amtincn(i); -- เงินเดือนปัจจุบัน - เงินที่ปรับ
              v_amt(i)      := v_amtincn(i);
            elsif v_unitcalo(i) <> ' ' then
              v_amtincom(i) := 0;
              v_amt(i) := v_amtincn(i) + v_amtinco(i); -- เงินที่ปรับ + จำนวนเงินเดิมก่อนปรับ
            end if;
            if r_tfincadj1.dteeffec > b_var_dtebeg then
                v_amt(i) := v_amt(i) * ((p_endate - r_tfincadj1.dteeffec + 1) / p_numday); -- จำนวนเงินที่ปรับ * ((วันสิ้นงวด - วันที่มีผล + 1) / 30)
            elsif (p_stdate > b_var_dtebeg) or (p_endate < b_var_dteend) then
                v_amt(i) := v_amt(i) * (p_qtyday / p_numday); -- จำนวนเงินที่ปรับ * (จำนวนวันทำงานในงวด / 30)
            else
              v_amt(i) := v_amt(i) / b_var_mqtypay; -- จำนวนเงินที่ปรับ / จำนวนงวดในเดือน
            end if;
            v_amtadj(i) := v_amtadj(i) + v_amt(i);
        end if;
    end loop;

    update tfincadj
		set staupd      = 'U',
    		dteyrepay	= b_index_dteyrepay - v_zyear,
    		dtemthpay	= b_index_dtemthpay,
    		numperiod	= b_index_numperiod,
    		coduser     = v_coduser
    where rowid = r_tfincadj1.rowid;

  end loop; -- for c_tfincadj1

    for i in 1..10 loop
        if v_unitcal(i) in ('M','A') then -- หน่วยการคำนวณเป็น เดือน, ปี
            v_amtincom(i) := greatest(v_amtincom(i),0);
            if b_var_stacal = '1' then -- พนักงานปัจจุบัน
              v_amtincom(i) := v_amtincom(i) / b_var_mqtypay; -- เงินเดือนปัจจุบัน / จำนวนงวดในเดือน
            else
              v_amtincom(i) := v_amtincom(i) * ((p_qtyday - nvl(p_deduct,0)) / p_numday); -- เงินเดือนปัจจุบัน * (จำนวนวันทำงาน - 0)) / 30)
            end if;
          v_amtincom(i) := v_amtincom(i) + v_amtadj(i);
            if (v_codincom(i) is not null) and (v_amtincom(i) <> 0) then
                upd_tsincexp(v_codincom(i),'1',false,v_amtincom(i));
            end if;
        end if;
    end loop;
	-- Daily to Monthly by Worapong / tjs3 06/06/2011
    for r_ttaxcur in c_ttaxcur loop -- เรียงข้อมูลจากมากไปน้อยจะได้งวดล่าสุดขึ้นก่อน
        if b_var_codcompy <> r_ttaxcur.codcompyo or b_var_typpayroll <> r_ttaxcur.typpayrollo then -- ถ้ามีข้อมูลไม่ตรงกับงวดก่อนหน้า
          begin
              select dteend into v_dteendo
                from tdtepay
                where codcompy   = r_ttaxcur.codcompyo
                  and typpayroll = r_ttaxcur.typpayrollo
                  and dteyrepay  = r_ttaxcur.dteyrepay
                  and dtemthpay  = r_ttaxcur.dtemthpay
                  and numperiod  = r_ttaxcur.numperiod;
          exception when no_data_found then
            v_dteendo := null;
          end;
          if v_dteendo is not null then
            if (b_var_dtebeg - v_dteendo) > 1 then -- ถ้าเกิดช่องว่างระหว่างงวด
              v_day := (b_var_dtebeg - v_dteendo) - 1;
              for i in 2..10 loop
                v_amt(i) := 0;
                if v_unitcalo(i) in ('M','A') then
                  v_amt(i) := v_amtchg(i) * (v_day / p_numday); -- เงินเดือนก่อนปรับ * (จำนวนวันในช่องว่าง / 30)
                  if (v_codincom(i) is not null) and (v_amt(i) <> 0) then
                    upd_tsincexp(v_codincom(i),'1',false,v_amt(i));
                  end if;
                end if;
              end loop;
            end if;
          end if;
        end if;
        exit;
      end loop;
	-- Daily to Monthly
	-- RETRO
  v_run := 0;
  for r_tfincadj2 in c_tfincadj2 loop
	  if b_index_flgretro = '1' then -- คำนวณตกเบิก
	  	v_dteeffec := r_tfincadj2.dteeffec;
	  	v_amtincn(1) := r_tfincadj2.amtincn1; 		v_amtinco(1) := r_tfincadj2.amtinco1;
	  	v_amtincn(2) := r_tfincadj2.amtincn2; 		v_amtinco(2) := r_tfincadj2.amtinco2;
	  	v_amtincn(3) := r_tfincadj2.amtincn3; 		v_amtinco(3) := r_tfincadj2.amtinco3;
	  	v_amtincn(4) := r_tfincadj2.amtincn4; 		v_amtinco(4) := r_tfincadj2.amtinco4;
	  	v_amtincn(5) := r_tfincadj2.amtincn5; 		v_amtinco(5) := r_tfincadj2.amtinco5;
	  	v_amtincn(6) := r_tfincadj2.amtincn6; 		v_amtinco(6) := r_tfincadj2.amtinco6;
	  	v_amtincn(7) := r_tfincadj2.amtincn7; 		v_amtinco(7) := r_tfincadj2.amtinco7;
	  	v_amtincn(8) := r_tfincadj2.amtincn8; 		v_amtinco(8) := r_tfincadj2.amtinco8;
	  	v_amtincn(9) := r_tfincadj2.amtincn9; 		v_amtinco(9) := r_tfincadj2.amtinco9;
	  	v_amtincn(10) := r_tfincadj2.amtincn10; 	v_amtinco(10) := r_tfincadj2.amtinco10;

        begin -- new codempmt
            select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
                   unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
              into v_unitcaln(1),v_unitcaln(2),v_unitcaln(3),v_unitcaln(4),v_unitcaln(5),
                   v_unitcaln(6),v_unitcaln(7),v_unitcaln(8),v_unitcaln(9),v_unitcaln(10)
            from tcontpmd
            where codcompy = b_var_codcompy
              and codempmt = r_tfincadj2.codempmt
              and dteeffec = (select max(dteeffec)
                                from tcontpmd
                               where codcompy = b_var_codcompy
                                 and codempmt = r_tfincadj2.codempmt
                                 and dteeffec <= sysdate);
        exception when no_data_found then
            null;
        end;

        begin -- old codempmt
            select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
                   unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
              into v_unitcalo(1),v_unitcalo(2),v_unitcalo(3),v_unitcalo(4),v_unitcalo(5),
                   v_unitcalo(6),v_unitcalo(7),v_unitcalo(8),v_unitcalo(9),v_unitcalo(10)
             from tcontpmd
            where codcompy = b_var_codcompy
              and codempmt = r_tfincadj2.codempmtt
              and dteeffec = (select max(dteeffec)
                                from tcontpmd
                               where codcompy = b_var_codcompy
                                 and codempmt = r_tfincadj2.codempmtt
                                 and dteeffec <= sysdate);
        exception when no_data_found then
            null;
        end;

        v_codretro(1) := tcontpms_codretro1;
        v_codretro(2) := tcontpms_codretro2;
        v_codretro(3) := tcontpms_codretro3;
        v_codretro(4) := tcontpms_codretro4;
        v_codretro(5) := tcontpms_codretro5;
        v_codretro(6) := tcontpms_codretro6;
        v_codretro(7) := tcontpms_codretro7;
        v_codretro(8) := tcontpms_codretro8;
        v_codretro(9) := tcontpms_codretro9;
        v_codretro(10) := tcontpms_codretro10;

      -- <<การคิดตกเบิกแบบใหม่ตามสูตร  ตรวจสอบ logic และ requirement เพิ่มเติม
      for i in 1..10 loop
        v_amt(i) := 0;
        if v_codretro(i) is not null then --เช็ค code การตกเบิกรายได้ว่ามีการกำหนดไว้หรือไม่
          for r_tdtepay in c_tdtepay loop -- งวดที่อยู่ในช่วง dteeffec กับวันที่เริ่มต้นของรอบที่กำลังคำนวณ
            --เช็ค ปี เดือน งวดเพื่อหาส่วนต่างการตกเบิกของจำนวนเงินที่จ่ายไปแล้วกับตกเบิกใหม่ในงวด
            v_flgplus := 'N';
            if v_dteyrepay <> r_tdtepay.dteyrepay  and v_dtemthpay <> r_tdtepay.dtemthpay and v_numperiod <> r_tdtepay.numperiod then
              v_run := v_run + 1;
              v_dteyrepay := r_tdtepay.dteyrepay;
              v_dtemthpay := r_tdtepay.dtemthpay;
              v_numperiod := r_tdtepay.numperiod;
              v_flgplus := 'Y';
              --หาจำนวนเงินที่จ่ายไปในงวดที่มีการตกเบิกตามรหัสรายได้
              v_amtpayinc := 0;
              begin
                select sum(stddec(amtpay,codempid,v_chken)) into v_amtpayinc
                  from tsincexp
                 where codempid  = temploy1_codempid
                   and dteyrepay = r_tdtepay.dteyrepay
                   and dtemthpay = r_tdtepay.dtemthpay
                   and numperiod = r_tdtepay.numperiod
                   and codpay    = v_codincom(i)
                   and flgslip   = '1';
              exception when no_data_found then
                 v_amtpayinc := 0;
              end;
              --หาจำนวนเงินตกเบิกในงวดที่มีการตกเบิกไปแล้วตามรหัสการตกเบิก
              v_amtpayrto := 0;
              begin
                select sum(stddec(amtpay,codempid,v_chken)) into v_amtpayrto
                  from tsincexp
                 where codempid  = temploy1_codempid
                   and dteyrepay = r_tdtepay.dteyrepay
                   and dtemthpay = r_tdtepay.dtemthpay
                   and numperiod = r_tdtepay.numperiod
                   and codpay    = v_codretro(i)
                   and flgslip   = '1';
              exception when no_data_found then
                 v_amtpayrto := 0;
              end;
              v_amtincpay(i) := v_amtincpay(i)  + nvl(v_amtpayinc,0) + nvl(v_amtpayrto,0); -- ยอดเงินที่จ่ายไปแล้วตั้งแต่วันที่มีผลบังคับใช้การปรับรายได้
            end if;
            -- หาเงินตกเบิกตามสูตร

            if v_dteeffec <= r_tdtepay.dtestrt  then-- กรณีจ่ายเต็มรอบ
              v_amt(i)  := (v_amtincn(i)/ b_var_mqtypay);
            else--เงินตกเบิก = (จำนวนเงินที่ปรับ/จำนวนงวดในเดือน) * (วันที่สิ้นสุดรอบ – วันที่มีผลบังคับใช้ + 1) / (30 / จำนวนงวดในเดือน)
              v_amt(i)  := (v_amtincn(i)/ b_var_mqtypay) * ((r_tdtepay.dteend - v_dteeffec + 1) / (p_numday / b_var_mqtypay)) ;
            end if;

            if v_flgplus = 'Y' then -- v_flgplus มีโอกาสเป็น N หรือไม่ กรณีใด
              v_amtrtonew(i) := v_amtrtonew(i) + ((v_amtinco(i)/ b_var_mqtypay) + v_amt(i)) ;
            else
              v_amtrtonew(i) := v_amtrtonew(i) + v_amt(i) ;
            end if;

          end loop;
        end if;
      end loop;

      -- >>การคิดตกเบิกแบบใหม่ตามสูตร

      --- Old back
      /*for i in 1..10 loop
				v_amt(i) := 0;
				if v_codretro(i) is not null then
					if v_unitcaln(i) = 'M' then
						if v_unitcalo(i) = 'M' then
						  v_amtincom(i) := v_amtincom(i) - v_amtincn(i);
						  v_amt(i)      := v_amtincn(i);
						elsif v_unitcalo(i) <> ' ' then
						  v_amtincom(i) := 0;
						  v_amt(i)      := v_amtincn(i) + v_amtinco(i);
						end if;
					end if;
					if v_amt(i) <> 0 then
						v_amt(i) := v_amt(i) / b_var_mqtypay;
						for r_tdtepay in c_tdtepay loop
							if r_tdtepay.dtestrt >= v_dteeffec then
								v_amtretro(i) := v_amtretro(i) + v_amt(i);
							else
								v_amtretro(i) := v_amtretro(i) + (v_amt(i) * (r_tdtepay.dteend - v_dteeffec + 1) / (p_numday / b_var_mqtypay));
							end if;
						end loop;
					end if;
				end if;
			end loop;	  */
	  end if; -- b_index_flgretro = '1'
    update tfincadj
		set staupd      = 'U',
    		dteyrepay	= b_index_dteyrepay -  v_zyear,
    		dtemthpay	= b_index_dtemthpay,
    		numperiod	= b_index_numperiod,
    		coduser     = v_coduser
    where rowid = r_tfincadj2.rowid;
  end loop; -- for c_tfincadj2

    if b_index_flgretro = '1' then -- คำนวณ
        for i in 1..10 loop
            v_amtretro(i) := v_amtrtonew(i) - v_amtincpay(i);
            if v_unitcal(i) in ('M','A') then
                if (v_codretro(i) is not null) and (v_amtretro(i) <> 0) then
                    upd_tsincexp(v_codretro(i),'1',false,v_amtretro(i));
                end if;
            end if;
        end loop;
    end if; -- b_index_flgretro = '1'
end;

procedure cal_bassal_hrpy44b is
    v_flgcal		tinexinf.flgcal%type;
    v_flgsoc		tinexinf.flgsoc%type;
    v_flgpvdf		tinexinf.flgpvdf%type;
    v_formulam	    tcontpmd.formulam%type;
    v_length		number;
    v_stmtcal		varchar2(200);
    v_stmtsoc		varchar2(200);
    v_stmtpro		varchar2(200);
    v_codpay		tinexinf.codpay%type;
    v_amtcal		number;
    v_socfix		number;
    v_profix		number;

    type char2 is table of tinexinf.codpay%type index by binary_integer;
        v_codincom	char2;

    type number1 is table of number index by binary_integer;
        v_amtincom	number1;
BEGIN
    for i in 1..10 loop
        v_codincom(i) := null;
        v_amtincom(i) := 0;
    end loop;
	begin
 		select formulam into v_formulam
 		 from tcontpmd
		where codcompy = b_var_codcompy
		  and codempmt = temploy1_codempmt
		  and dteeffec = (select max(dteeffec)
                            from tcontpmd
                           where codcompy = b_var_codcompy
                             and codempmt = temploy1_codempmt
                             and dteeffec <= sysdate);
	exception when no_data_found then
		insert_error(get_errorm_name('HR2010',v_lang)||' (TCONTPMD)');
		return;
	end;
    b_var_amtcal := 0;
    b_var_socfix := 0;
    b_var_profix := 0;

    v_codincom(1) := tcontpms_codincom1;
    v_amtincom(1) := nvl(temploy3_amtincom1,0);

    v_codincom(2) := tcontpms_codincom2;
    v_amtincom(2) := nvl(temploy3_amtincom2,0);

    v_codincom(3) := tcontpms_codincom3;
    v_amtincom(3) := nvl(temploy3_amtincom3,0);

    v_codincom(4) := tcontpms_codincom4;
    v_amtincom(4) := nvl(temploy3_amtincom4,0);

    v_codincom(5) := tcontpms_codincom5;
    v_amtincom(5) := nvl(temploy3_amtincom5,0);

    v_codincom(6) := tcontpms_codincom6;
    v_amtincom(6) := nvl(temploy3_amtincom6,0);

    v_codincom(7) := tcontpms_codincom7;
    v_amtincom(7) := nvl(temploy3_amtincom7,0);

    v_codincom(8) := tcontpms_codincom8;
    v_amtincom(8) := nvl(temploy3_amtincom8,0);

    v_codincom(9) := tcontpms_codincom9;
    v_amtincom(9) := nvl(temploy3_amtincom9,0);

    v_codincom(10) := tcontpms_codincom10;
    v_amtincom(10) := nvl(temploy3_amtincom10,0);

	-- WAGE PER MONTH
	if v_formulam is not null then
		v_length := length(v_formulam);
		v_stmtcal := v_formulam;
		v_stmtsoc := v_formulam;
		v_stmtpro := v_formulam;
		for i in 1..v_length loop
            if substr(v_formulam,i,2) = '{&' then
                --v_codpay := substr(v_formulam, i+1, 2);
                v_codpay := substr(v_formulam,i + 2,instr(substr(v_formulam,i + 2) ,'}') -1) ;
                v_amtcal := 0;
                v_socfix := 0;
                v_profix := 0;
                for j in 1..10 loop
                    if v_codpay = v_codincom(j) then
                        begin
                            select flgcal,flgsoc,flgpvdf
                              into v_flgcal,v_flgsoc,v_flgpvdf
                              from tinexinf
                             where codpay = v_codpay;

                            if v_flgcal = 'Y' then
                                v_amtcal := v_amtincom(j);
                            end if;
                            if v_flgsoc = 'Y' then
                                v_socfix := v_amtincom(j);
                            end if;
                            if v_flgpvdf = 'Y' then
                                v_profix := v_amtincom(j);
                            end if;
                        exception when no_data_found then
                            null;
                        end;
                        exit;
                    end if;
                end loop;
                v_stmtcal := replace(v_stmtcal,substr(v_stmtcal,instr(v_stmtcal,'{&'),instr( substr(v_stmtcal,instr(v_stmtcal,'{&')), '}') ),v_amtcal);
                v_stmtsoc := replace(v_stmtsoc,substr(v_stmtsoc,instr(v_stmtsoc,'{&'),instr( substr(v_stmtsoc,instr(v_stmtsoc,'{&')), '}') ),v_socfix);
                v_stmtpro := replace(v_stmtpro,substr(v_stmtpro,instr(v_stmtpro,'{&'),instr( substr(v_stmtpro,instr(v_stmtpro,'{&')), '}') ),v_profix);
			end if;
		end loop;
        b_var_amtcal := execute_sql('select '||v_stmtcal||' from dual') * b_var_ratechge;
		b_var_socfix := execute_sql('select '||v_stmtsoc||' from dual') * b_var_ratechge;
		b_var_profix := execute_sql('select '||v_stmtpro||' from dual') * b_var_ratechge;
	end if;
end;


PROCEDURE cal_oth_ot is
	v_amtpay		number;
	v_costcent	varchar2(10);
	v_formula		tformula.formula%type;
	v_flgform		tinexinf.flgform%type;

cursor c_tothinc is
	select codpay, stddec(amtpay,codempid,v_chken) amtpay, costcent
	  from tothinc
	 where codempid  = temploy1_codempid
	   and dteyrepay = b_index_dteyrepay - v_zyear
	   and dtemthpay = b_index_dtemthpay
	   and numperiod = b_index_numperiod;

BEGIN
	begin
	  select stddec(amtottot,codempid,v_chken), costcent
	    into v_amtpay, v_costcent
	    from totsum
	   where codempid  = temploy1_codempid
	     and dteyrepay = b_index_dteyrepay - v_zyear
	     and dtemthpay = b_index_dtemthpay
	     and numperiod = b_index_numperiod;
	    upd_tsincexp(tcontrpy_codpaypy5,'1',true,v_amtpay);
	exception when no_data_found then
	  null;
	end;
	for r_tothinc in c_tothinc loop
		begin
			select flgform into v_flgform
			from 	 tinexinf
			where  codpay = r_tothinc.codpay;
		exception when no_data_found then
		  v_flgform := null;
		end;
		v_amtpay := r_tothinc.amtpay;
		if v_flgform = 'Y' then -- เช็คว่ามีสูตรคำนวณหรือไม่
			v_amtpay := cal_Formula(r_tothinc.codpay,v_amtpay);
		end if;
        b_var_amt_oth := nvl(b_var_amt_oth,0) + v_amtpay ;
	    upd_tsincexp(r_tothinc.codpay,'1',true,v_amtpay);
	end loop;
END;

procedure cal_tempinc(p_stdate date,
                      p_endate date) is

    v_qtyday		number;
    v_stdate		date;
    v_endate		date;
    v_amtpay		number;
    v_amt			  number;
    v_cnt			  number;
    v_typpay		tinexinf.typpay%type;
    v_flgtax  	tinexinf.flgtax%type;
    v_flgcal		tinexinf.flgcal%type;
    v_flgsoc		tinexinf.flgsoc%type;
    v_flgpvdf		tinexinf.flgpvdf%type;
    v_flgfml		tinexinf.flgfml%type;
    v_flgform		tinexinf.flgform%type;
    v_flgprort  varchar2(1 char);
    v_codpay	  tinexinf.codpay%type;
    v_sumamtpay	number := 0;
    v_dteeffex  date ;

    cursor c_ttpminf is
        select dteeffec
          from ttpminf
         where codempid	=	temploy1_codempid
           and dteeffec	> b_var_dteend
           and dteeffec <= to_date('0101'||((b_index_dteyrepay - v_zyear) + 1),'ddmmyyyy') -- <= วันที่ 1 เดือน 1 ของปีถัดไป
           and codtrn   =	'0006' -- พ้นสภาพ
        order by dteeffec desc,numseq desc;

    cursor c_tempinc is -- รายได้ส่วนหักกำหนดระยะเวลาจ่ายในรอบการคำนวณ
      select codpay,dtestrt,dteend,dtecancl,flgprort,
             stddec(amtfix,codempid,v_chken) amt
      from tempinc
      where codempid = temploy1_codempid
        and dtestrt <= p_endate
        and	(((dtecancl is not null) and (dtecancl > p_stdate)) or
                 ((dtecancl is null) and ((dteend is null) or
                                          ((dteend is not null) and (dteend >= p_stdate)))))
        and ((periodpay = 'N') or (periodpay = to_char(b_index_numperiod))) -- N = ทุกงวด
      order by codpay,dtestrt;
    cursor c_tempinc2 is
      select codpay,periodpay,stddec(amtfix,codempid,v_chken) amt,dtestrt,dteend,dtecancl
      from tempinc
      where codempid = temploy1_codempid
        and dtestrt <= p_endate
        and	(((dtecancl is not null) and (dtecancl > p_endate)) or
                 ((dtecancl is null) and ((dteend is null) or
                                          ((dteend is not null) and (dteend >= p_stdate)))));
begin
    v_qtyday         := 0 ;
    v_dteeffex       := temploy1_dteeffex ;
    for r_ttpminf in c_ttpminf loop
        v_dteeffex := r_ttpminf.dteeffec;
        exit;
    end loop;

    for r_tempinc in c_tempinc loop
--<<redmine#1653 KOHU-HR2301 user14 06/02/2024 12:12
        if v_dteeffex is not null and v_dteeffex < b_var_dtebeg then
           exit;
        end if;
-->>redmine#1653 KOHU-HR2301 user14 06/02/2024 12:12
        if v_codpay is null then
            v_codpay := r_tempinc.codpay;
        elsif v_codpay <> r_tempinc.codpay then
            b_var_amt_oth := nvl(b_var_amt_oth,0) + v_sumamtpay ;
            upd_tsincexp(v_codpay,'1',true,v_sumamtpay);
            v_codpay := r_tempinc.codpay;
            v_amtpay := 0;
            v_sumamtpay	:= 0;
        end if;
        -- เริ่มคำนวณจำนวนวันของรายได้กำหนดระยะเวลาจ่าย
        if r_tempinc.dtestrt > p_stdate then
            v_stdate := r_tempinc.dtestrt;
        else
            v_stdate := p_stdate;
        end if;
        if r_tempinc.dtecancl is not null then
          v_endate := (r_tempinc.dtecancl - 1);
        elsif	r_tempinc.dteend is not null then
          v_endate := r_tempinc.dteend;
        else
          v_endate := p_endate;
        end if;
        if v_endate > p_endate then
          v_endate := p_endate;
        end if;
        if v_endate >= v_stdate then
            v_qtyday := v_endate - v_stdate + 1;
            begin
                select flgform into v_flgform
                  from tinexinf
                 where codpay = r_tempinc.codpay;
            exception when no_data_found then
                v_flgform  := null;
                v_flgprort := null;
            end;
            v_amtpay := r_tempinc.amt;
            if v_flgform = 'Y' then
                v_amtpay := cal_Formula(r_tempinc.codpay,v_amtpay);
            end if;
            if nvl(r_tempinc.flgprort,'Y') = 'Y' then -- flg prorate
                v_amtpay := v_amtpay * (v_qtyday / (b_var_dteend - b_var_dtebeg + 1)); -- เงินที่จ่าย * (จำนวนวันที่หาได้ / (วันสิ้นรอบ - วันเริ่มรอบ + 1))
            end if;
            v_sumamtpay := nvl(v_sumamtpay,0) + nvl(v_amtpay,0);
        end if;
	end loop;

  if 	v_sumamtpay <> 0 then 
      b_var_amt_oth := nvl(b_var_amt_oth,0) + v_sumamtpay ;
      upd_tsincexp(v_codpay,'1',true,v_sumamtpay);
  end if;
  -- ESTIMATE
  b_var_tempinc    := 0;
  declare_var_it4  := 0 ;
  declare_var_it5  := 0 ;
  declare_var_it6  := 0 ;
  declare_var_v_amtdedfix := 0 ;
  -- declare_var_v_amtothfix := 0 ;

	if (b_var_stacal = '4') or ((b_var_stacal = '2') and (b_index_flag = 'N')) or -- พ้นสภาพ หรือ (พ้นสภาพระหว่างงวดและคำนวณถึงวันที่พ้นสภาพ)
		 ((temploy1_dteeffex = b_var_dteend + 1) and (b_index_flag = 'N')) then -- หรือ วันที่พ้นสภาพสิ้นรอบพอดีและคำนวณถึงวันที่พ้นสภาพ
		null;
	else
		for r_tempinc2 in c_tempinc2 loop
            --<<redmine#1653 KOHU-HR2301 user14 06/02/2024 12:12
            if v_dteeffex is not null and v_dteeffex < b_var_dtebeg then
               exit;
            end if;
            -->>redmine#1653 KOHU-HR2301 user14 06/02/2024 12:12
			begin
				select typpay,flgcal,flgsoc,flgpvdf,flgfml,flgform,flgtax
				into 	 v_typpay,v_flgcal,v_flgsoc,v_flgpvdf,v_flgfml,v_flgform,v_flgtax
				from 	 tinexinf
				where  codpay = r_tempinc2.codpay;
			exception when no_data_found then
          v_typpay := null;
          v_flgtax := null;
			end;
			v_amtpay := r_tempinc2.amt;
			if v_flgform = 'Y' then
         v_amtpay := cal_Formula(r_tempinc2.codpay,v_amtpay);
			end if;
			if v_amtpay <> 0 then
				 v_amtpay := proc_round(v_flgfml,v_amtpay);
				if v_flgcal = 'Y' then
            v_amt := 0;
            if v_typpay in ('1','2') then
              v_amt := v_amtpay;
            elsif v_typpay = '4' then
              v_amt := v_amtpay * -1;
            end if;
            if r_tempinc2.periodpay = 'N' then -- หาจำนวนงวดที่ยังไม่ได้คำนวณที่อยู่ในช่วงของรายได้กำหนดระยะเวลาจ่าย
                  select count(codcompy) into v_cnt
                    from tdtepay
                  where codcompy   = b_var_codcompy
                    and typpayroll = b_var_typpayroll
                    and dteyrepay  = (b_index_dteyrepay - v_zyear)
                    and dtestrt > p_stdate
                    and (r_tempinc2.dteend is null or dteend <= r_tempinc2.dteend)
                    and (r_tempinc2.dtecancl is null or dteend < r_tempinc2.dtecancl)
                    and (flgcal = 'N' or flgcal is null)
                    and (v_dteeffex is null or dteend < v_dteeffex  ) ;
                    b_var_tempinc := nvl(b_var_tempinc,0) + (v_amt * v_cnt);
            else
                  select count(codcompy) into v_cnt
                    from tdtepay
                    where codcompy   = b_var_codcompy
                      and typpayroll = b_var_typpayroll
                      and dteyrepay  = (b_index_dteyrepay - v_zyear)
                      and numperiod  = r_tempinc2.periodpay
                      and dtestrt > p_stdate
                      and (r_tempinc2.dteend is null or dteend <= r_tempinc2.dteend)
                      and (r_tempinc2.dtecancl is null or dteend < r_tempinc2.dtecancl)
                      and (flgcal = 'N' or flgcal is null)
                      and (v_dteeffex is null or dteend < v_dteeffex  ) ;
                      b_var_tempinc := nvl(b_var_tempinc,0) + (v_amt * v_cnt);
            end if;

            if v_typpay in ('1','2') and temploy3_flgtax = v_flgtax then
                declare_var_forecast_othfix     := nvl(declare_var_forecast_othfix,0) + (v_amt *  v_cnt) ;
            else
                if v_flgtax = '1' and v_typpay in ('1','2') then -- หักภาษี ณ ที่จ่าย และ เป็นรายได้ประจำ หรือ รายได้อื่นๆ(ประจำ)
                    declare_var_it4                              := declare_var_it4 + 1 ;
                    declare_var_tempinc_codpay4(declare_var_it4) := r_tempinc2.codpay ;
                    declare_var_tempinc_amt4(declare_var_it4)    := v_amt * v_cnt ;
                    declare_var_forecast4                        := nvl(declare_var_forecast4,0) + (v_amt *  v_cnt) ;
                elsif v_flgtax = '2' and v_typpay in ('1','2') then -- ภาษีบริษัทออกให้ และ เป็นรายได้ประจำ หรือ รายได้อื่นๆ(ประจำ)
                    declare_var_it5                              := declare_var_it5 + 1 ;
                    declare_var_tempinc_codpay5(declare_var_it5) := r_tempinc2.codpay ;
                    declare_var_tempinc_amt5(declare_var_it5)    := v_amt * v_cnt ;
                    declare_var_forecast5                        := nvl(declare_var_forecast5,0) + (v_amt *  v_cnt) ;
                elsif v_flgtax = '3' and v_typpay in ('1','2') then -- ภาษีบริษัทออกให้ครั้งเดียว และ เป็นรายได้ประจำ หรือ รายได้อื่นๆ(ประจำ)
                  declare_var_it6                              := declare_var_it6 + 1 ;
                  declare_var_tempinc_codpay6(declare_var_it6) := r_tempinc2.codpay ;
                  declare_var_tempinc_amt6(declare_var_it6)    := v_amt * v_cnt ;
                  declare_var_forecast6                        := nvl(declare_var_forecast6,0) + (v_amt *  v_cnt) ;
                end if;
                if v_typpay = '4' then -- ส่วนหักประจำ
                    declare_var_v_amtdedfix := declare_var_v_amtdedfix + (v_amt * v_cnt);
                end if;
            end if;
        end if;

        if r_tempinc2.periodpay = 'N' then
            v_amtpay := v_amtpay * b_var_mqtypay; -- เงินที่จ่าย * จำนวนงวดในเดือน
        end if;
        if v_flgsoc = 'Y' then
            if v_typpay in ('1','2') then
                  b_var_socfix := nvl(b_var_socfix,0) + v_amtpay;
            elsif v_typpay = '4' then
                  b_var_socfix := nvl(b_var_socfix,0) - v_amtpay;
            end if;
        end if;
        if v_flgpvdf = 'Y' then
            if v_typpay in ('1','2') then
                  b_var_profix := nvl(b_var_profix,0) + v_amtpay;
            elsif v_typpay = '4' then
                  b_var_profix := nvl(b_var_profix,0) - v_amtpay;
            end if;
        end if;
			end if;
		end loop; -- for c_tempinc2
	end if;
end;

procedure cal_tempinc_hrpy44b (p_stdate date,p_endate date) is
    v_qtyday			number;
    v_stdate			date;
    v_endate			date;
    v_amtpay			number;
    v_amt				number;
    v_cnt				number;
    v_typpay			tinexinf.typpay%type;
    v_flgcal			tinexinf.flgcal%type;
    v_flgsoc			tinexinf.flgsoc%type;
    v_flgpvdf			tinexinf.flgpvdf%type;
    v_flgfml			tinexinf.flgfml%type;
    v_flgform			tinexinf.flgform%type;

  cursor c_tempinc2 is
    select codpay,periodpay,stddec(amtfix,codempid,v_chken) amt,dtestrt,dteend,dtecancl
    from tempinc
    where codempid = temploy1_codempid
      and dtestrt <= p_endate
      and periodpay = to_char(b_index_numperiod)
      and (((dtecancl is not null) and (dtecancl > p_stdate)) or
           ((dtecancl is null) and ((dteend is null) or
                                   ((dteend is not null) and (dteend >= p_stdate)))));
begin

    b_var_tempinc := 0;
    if (b_var_stacal = '4') or ((b_var_stacal = '2') and (b_index_flag = 'N')) or
        ((temploy1_dteeffex = b_var_dteend + 1) and (b_index_flag = 'N')) then
        null;
    else
        for r_tempinc2 in c_tempinc2 loop
            begin
                select typpay,flgcal,flgsoc,flgpvdf,flgfml,flgform
                  into v_typpay,v_flgcal,v_flgsoc,v_flgpvdf,v_flgfml,v_flgform
                  from tinexinf
                 where codpay = r_tempinc2.codpay;
            exception when no_data_found then
              v_typpay := null;
            end;

            v_amtpay := r_tempinc2.amt;
            if v_flgform = 'Y' then
                v_amtpay := cal_formula(r_tempinc2.codpay,v_amtpay);
            end if;
            upd_tsincexp(r_tempinc2.codpay,'1',true,v_amtpay);

            if v_amtpay <> 0 then
                v_amtpay := proc_round(v_flgfml,v_amtpay);
                if v_flgcal = 'Y' then
                    v_amt := 0;
                    if v_typpay in ('1','2') then
                        v_amt := v_amtpay;
                    elsif v_typpay = '4' then
                        v_amt := v_amtpay * -1;
                    end if;
                    if r_tempinc2.periodpay = 'N' then
                      select count(codcompy) into v_cnt
                        from   tdtepay
                        where  codcompy   = b_var_codcompy
                        and    typpayroll = b_var_typpayroll
                        and  	 dteyrepay  = (b_index_dteyrepay - v_zyear)
                        and		 dtestrt > p_stdate
                        and		(r_tempinc2.dteend is null or dteend <= r_tempinc2.dteend)
                        and		(r_tempinc2.dtecancl is null or dteend < r_tempinc2.dtecancl)
                        and		 (flgcal = 'N' or flgcal is null);
                        b_var_tempinc := nvl(b_var_tempinc,0) + (v_amt * v_cnt);
                    else
                      select count(codcompy) into v_cnt
                        from   tdtepay
                        where  codcompy   = b_var_codcompy
                        and    typpayroll = b_var_typpayroll
                        and  	 dteyrepay  = (b_index_dteyrepay - v_zyear)
                        and		 numperiod  = r_tempinc2.periodpay
                        and		 dtestrt > p_stdate
                        and		(r_tempinc2.dteend is null or dteend <= r_tempinc2.dteend)
                        and		(r_tempinc2.dtecancl is null or dteend < r_tempinc2.dtecancl)
                        and		 (flgcal = 'N' or flgcal is null);
                        b_var_tempinc := nvl(b_var_tempinc,0) + (v_amt * v_cnt);
                    end if;
                end if;
                if v_flgsoc = 'Y' then
                    if v_typpay in ('1','2') then
                        b_var_socfix := nvl(b_var_socfix,0) + v_amtpay;
                    elsif v_typpay = '4' then
                        b_var_socfix := nvl(b_var_socfix,0) - v_amtpay;
                    end if;
                end if;
                if v_flgpvdf = 'Y' then
                    if v_typpay in ('1','2') then
                        b_var_profix := nvl(b_var_profix,0) + v_amtpay;
                    elsif v_typpay = '4' then
                        b_var_profix := nvl(b_var_profix,0) - v_amtpay;
                    end if;
                end if;
            end if;
        end loop; -- for c_tempinc2
	end if;
end;

procedure cal_tempinc_estimate(p_stdate date,
                               p_endate date) is

    v_qtyday		number;
    v_stdate		date;
    v_endate		date;
    v_amtpay		number;
    v_amt			  number;
    v_cnt			  number;
    v_typpay		tinexinf.typpay%type;
    v_flgtax  	tinexinf.flgtax%type;
    v_flgcal		tinexinf.flgcal%type;
    v_flgsoc		tinexinf.flgsoc%type;
    v_flgpvdf		tinexinf.flgpvdf%type;
    v_flgfml		tinexinf.flgfml%type;
    v_flgform		tinexinf.flgform%type;
    v_flgprort  varchar2(1 char);
    v_codpay	  tinexinf.codpay%type;
    v_sumamtpay	    number := 0;
    v_chkcal        varchar2(1 char);
    v_dteeffex      date ;
    v_count         number := 0;

    cursor c_ttpminf is
        select dteeffec
          from ttpminf
         where codempid	=	temploy1_codempid
           and dteeffec	> b_var_dteend
           and dteeffec <= to_date('0101'||((b_index_dteyrepay - v_zyear) + 1),'ddmmyyyy')
           and codtrn   =	'0006'
        order by dteeffec desc,numseq desc;

    cursor c_tempinc is
      select codpay,periodpay,stddec(amtfix,codempid,v_chken) amt,dtestrt,dteend,dtecancl
       from  tempinc
      where codempid = temploy1_codempid
        and ((periodpay = 'N') or (periodpay <> to_char(b_index_numperiod)))
        and dtestrt <= v_dteyren
        and	(((dtecancl is not null) and (dtecancl > v_dteyrst)) or
                 ((dtecancl is null) and ((dteend is null) or
                                          ((dteend is not null) and (dteend >= v_dteyrst)))));

    cursor c_tdtepay is
        select *
          from tdtepay
         where codcompy   = b_var_codcompy
           and typpayroll = b_var_typpayroll
           and dteyrepay  = (b_index_dteyrepay - v_zyear)
        order by dtemthpay asc ,numperiod asc ;

begin
    v_qtyday         := 0 ;
    v_dteeffex       := temploy1_dteeffex ;
    for r_ttpminf in c_ttpminf loop
        v_dteeffex := r_ttpminf.dteeffec;
        exit;
    end loop;
    -- ESTIMATE
    b_var_tempinc    := 0;
    declare_var_it4  := 0 ;
    declare_var_it5  := 0 ;
    declare_var_it6  := 0 ;
    declare_var_forecast4    := 0;
    declare_var_forecast5    := 0;
    declare_var_forecast6    := 0;
    declare_var_v_amtdedfix  := 0;
    declare_var_v_amtdedoth  := 0;

	for r_tempinc in c_tempinc loop
        begin
            select typpay,flgcal,flgsoc,flgpvdf,flgfml,flgform,flgtax
              into v_typpay,v_flgcal,v_flgsoc,v_flgpvdf,v_flgfml,v_flgform,v_flgtax
              from tinexinf
             where codpay = r_tempinc.codpay;
        exception when no_data_found then
            v_typpay := null;
            v_flgtax := null;
        end;
        v_amtpay := r_tempinc.amt;
        if v_flgform = 'Y' then
            v_amtpay := cal_Formula(r_tempinc.codpay,v_amtpay);
        end if;
        if v_amtpay <> 0 then
            v_amtpay := proc_round(v_flgfml,v_amtpay);
            if v_flgcal = 'Y' then
                v_amt := 0;

                if v_typpay in ('1','2') then
                    v_amt := v_amtpay;
                elsif v_typpay = '4' then -- ส่วนหักประจำ
                    v_amt := v_amtpay * -1;
                end if;

                v_cnt :=  0 ;
                for  r_tdtepay  in c_tdtepay loop
                    if  r_tempinc.dtestrt <= r_tdtepay.dteend  and
                        (((r_tempinc.dtecancl is not null) and (r_tempinc.dtecancl > r_tdtepay.dtestrt)) or
                        ((r_tempinc.dtecancl is null) and ((r_tempinc.dteend is null) or
                        ((r_tempinc.dteend is not null) and (r_tempinc.dteend >= r_tdtepay.dtestrt)))))  then

                        if  v_dteeffex is not null and  v_dteeffex <= r_tdtepay.dtestrt  then
                            exit ;
                        end if;

                        begin
                            select 'Y' into v_chkcal
                             from ttaxcur
                            where codempid  = temploy1_codempid
                              and dteyrepay = r_tdtepay.dteyrepay
                              and dtemthpay = r_tdtepay.dtemthpay
                              and numperiod = r_tdtepay.numperiod ;
                        exception when others then
                            v_chkcal := 'N' ;
                        end ;

                        if v_chkcal = 'N' then
                            v_cnt := v_cnt + 1 ;
                        end if;
                        if ( r_tdtepay.dtemthpay > b_index_dtemthpay ) or ( r_tdtepay.dtemthpay = b_index_dtemthpay and r_tdtepay.numperiod  > b_index_numperiod ) then
                            v_count := v_count + 1 ;
                        end if;
                    end if;
                end loop;

                b_var_tempinc := nvl(b_var_tempinc,0) + (v_amt * v_cnt);
                if v_typpay = '4' then -- ส่วนหักประจำ
                    declare_var_v_amtdedfix := declare_var_v_amtdedfix + (v_amt * v_cnt);
                    msg_err('# Esitmate กำหนดระยะเวลาจ่ายหักประจำ  ('||r_tempinc.codpay||') '||v_cnt||' '||declare_var_v_amtdedfix);
                end if;

                if v_flgtax = '1' then
                    declare_var_it4                              := declare_var_it4 + 1 ;
                    declare_var_tempinc_codpay4(declare_var_it4) := r_tempinc.codpay ;
                    declare_var_tempinc_amt4(declare_var_it4)    := v_amt * v_cnt ;
                    declare_var_forecast4                        := v_amt *  v_count ;
                elsif v_flgtax = '2' then
                    declare_var_it5                              := declare_var_it5 + 1 ;
                    declare_var_tempinc_codpay5(declare_var_it5) := r_tempinc.codpay ;
                    declare_var_tempinc_amt5(declare_var_it5)    := v_amt * v_cnt ;
                    declare_var_forecast5                        := v_amt *  v_count ;
                elsif v_flgtax = '3' then
                    declare_var_it6                              := declare_var_it6 + 1 ;
                    declare_var_tempinc_codpay6(declare_var_it6) := r_tempinc.codpay ;
                    declare_var_tempinc_amt6(declare_var_it6)    := v_amt * v_cnt ;
                    declare_var_forecast6                        := v_amt *  v_count ;
                end if;
            end if;

            if r_tempinc.periodpay = 'N' then
                v_amtpay := v_amtpay * b_var_mqtypay;
            end if;
            if v_flgsoc = 'Y' then
                if v_typpay in ('1','2') then
                    b_var_socfix := nvl(b_var_socfix,0) + v_amtpay;
                elsif v_typpay = '4' then
                    b_var_socfix := nvl(b_var_socfix,0) - v_amtpay;
                end if;

            end if;
                if v_flgpvdf = 'Y' then
                    if v_typpay in ('1','2') then
                        b_var_profix := nvl(b_var_profix,0) + v_amtpay;
                    elsif v_typpay = '4' then
                        b_var_profix := nvl(b_var_profix,0) - v_amtpay;
                    end if;
                end if;
        end if;
	end loop; -- for c_tempinc2

end;

PROCEDURE cal_studyded is
	v_amtloanstu		number;
  v_amtloanstuf		number;

  cursor c_tloanstudy is
    select stddec(amtloanstu,codempid,v_chken) amtloanstu ,
           stddec(amtloanstuf,codempid,v_chken)amtloanstuf
      from tloanslf -- HRPY5AE บันทึกข้อมูลการจ่ายเงิน กยศ. กรอ.
     where codempid  = temploy1_codempid
       and status    = 'P'
       and dteyrepay = b_index_dteyrepay - v_zyear
       and dtemthpay = b_index_dtemthpay
       and (stddec(amtloanstu,codempid,v_chken)  - stddec(amtdedstu,codempid,v_chken) > 0
        or  stddec(amtloanstuf,codempid,v_chken) - stddec(amtdedstuf,codempid,v_chken)> 0);

BEGIN

	for r_tloanstudy in c_tloanstudy loop
        if r_tloanstudy.amtloanstu > 0 then -- จำนวนเงินที่ต้องชำระ กยศ
             upd_tsincexp(tcontrpy_codpaypy13,'1',true,r_tloanstudy.amtloanstu);
        end if;
        if r_tloanstudy.amtloanstuf > 0 then -- จำนวนเงินที่ต้องชำระ กรอ
             upd_tsincexp(tcontrpy_codpaypy14,'1',true,r_tloanstudy.amtloanstuf);
        end if;
        v_amtloanstu		:= r_tloanstudy.amtloanstu ;
        v_amtloanstuf		:= r_tloanstudy.amtloanstuf ;
         update tloanslf set  amtdedstu = stdenc(v_amtloanstu,codempid,v_chken)  , amtdedstuf = stdenc(v_amtloanstuf,codempid,v_chken)
         where  codempid  = temploy1_codempid
         and dteyrepay = b_index_dteyrepay - v_zyear
         and dtemthpay = b_index_dtemthpay ;

	end loop;
END;
--
  PROCEDURE cal_Legalded (p_amtnet 	in out number ) is --<< user46 update procedure cal_legalded ref. NXP-HR2101 15/12/2021
    v_numcaselw    varchar2(30 char ) ;
    v_amtpay   		 number := 0 ;
    v_amtpayded		 number := 0 ;

    v_amtded   		 number := 0 ;
    v_amtttded 		 number := 0 ;
    v_amtbal   		 number := 0 ;
    v_codpay       varchar2(30 char ) ;
    v_amtpay01 		 number := p_amtnet ;
    v_amtpayoth		 number := 0 ;
    cursor c_tlegalexe is
      select numcaselw,codlegald,namlegalb,namplntiff,dtestrt,dteend,
             qtyperd,
             stddec(amtfroze,codempid,v_chken) amtfroze,
             stddec(amtmin,codempid,v_chken) amtmin,
             stacaselw,
             qtyperded,
             stddec(amtded,codempid,v_chken) amtded,
             dteyrded,dtemthded,numprdded,pctded,banklaw
      from   tlegalexe
      where  codempid  = temploy1_codempid
       and   stacaselw = 'P'
       and   dtestrt <= b_var_dteend
       and   nvl(dteend,b_var_dtebeg)  >= b_var_dtebeg
      order by numcaselw ;

    cursor c_tlegalexd is
      select codpay,pctded,stddec(amtdmin,codempid,v_chken) amtdmin
      from   tlegalexd
      where  codempid  = temploy1_codempid
      and    numcaselw = v_numcaselw
      order by pctded desc ,codpay ;

    cursor c_tsincexp is 
      select  sum( stddec(amtpay,codempid,v_chken)) amtpay
      from  tsincexp
      where codempid  = temploy1_codempid
       and  dteyrepay = b_index_dteyrepay - v_zyear
       and  dtemthpay = b_index_dtemthpay
       and  numperiod = b_index_numperiod
       and  typincexp in ('1','2','3')
       and  codpay    not in ( select codpay 
                               from   tlegalexd
                               where  codempid  = temploy1_codempid
                               and    numcaselw = v_numcaselw )    ;
  begin
  v_amtpay01 := p_amtnet ;
	for r_tlegalexe in c_tlegalexe loop
        v_numcaselw := r_tlegalexe.numcaselw ;
    	  v_amtded    := 0  ;
      for r_tlegalexd in  c_tlegalexd loop -- กำหนดหักกรมบังคับคดีจากรายได้อื่นๆ
          v_codpay    := r_tlegalexd.codpay  ;
          v_amtpay    := 0 ;
          v_amtpayded := 0 ;
          begin
            select stddec(amtpay,codempid,v_chken)  into v_amtpay -- หารายได้อื่นๆ ตาม codpay ที่กำหนดที่จะหักตามกรมบังคับคดี
            from  tsincexp
            where codempid  = temploy1_codempid
             and  dteyrepay = b_index_dteyrepay - v_zyear
             and  dtemthpay = b_index_dtemthpay
             and  numperiod = b_index_numperiod
             and  codpay    = v_codpay    ;
          exception when others then
             v_amtpay := 0 ;
          end ;
          -- v_amtpayoth := v_amtpayoth + v_amtpay ;
          if v_amtpay > 0  then
            if r_tlegalexd.pctded is not null then
              v_amtpayded := round(v_amtpay * (r_tlegalexd.pctded/100)) ;
              if (v_amtpay - v_amtpayded)  <  r_tlegalexd.amtdmin then -- ถ้าหักแล้วเหลือน้อยกว่าจำนวนเงินขั้นต่ำที่กำหนดไว้  ให้หักตามจำนวนเงินขั้นต่ำ
                  v_amtpayded := v_amtpay - r_tlegalexd.amtdmin  ;
              end if;
            else -- ถ้าไม่ได้กำหนด % ก็ให้หักตามเงินขั้นต่ำ
              v_amtpayded := v_amtpay - r_tlegalexd.amtdmin  ;
            end if;
            v_amtpayded := greatest(v_amtpayded,0);
            insert into tlegalexp (codempid,numcaselw, -- เก็บข้อมูลหักกรมบังคับคดีของรายได้อื่นๆ
                                    dteyrepay,dtemthpay,numperiod,
                                    codpay,codcomp,banklaw,amtpay,pctded,
                                    codcreate,coduser )
                             values(temploy1_codempid,r_tlegalexe.numcaselw,
                                    b_index_dteyrepay - v_zyear,b_index_dtemthpay,b_index_numperiod,
                                    v_codpay , temploy1_codcomp,r_tlegalexe.banklaw,stdenc(v_amtpayded,temploy1_codempid,v_chken),r_tlegalexd.pctded ,
                                    v_coduser,v_coduser ) ;
          end if;
          v_amtpayded := greatest(v_amtpayded,0);
          v_amtded    := v_amtded + nvl(v_amtpayded,0) ;
      end loop;

      begin
        select sum( stddec(amtpay,codempid,v_chken)) into v_amtpay01 -- หารายได้ประจำ
          from tsincexp
         where codempid  = temploy1_codempid
           and dteyrepay = b_index_dteyrepay - v_zyear
           and dtemthpay = b_index_dtemthpay
           and numperiod = b_index_numperiod
           and  typincexp = '1';
      end ;
      if   v_amtpay01 > 0   then
        -- ถ้าคำนวณหักแบบ % แล้วได้น้อยกว่าจำนวนเงินที่กำหนดไว้  ให้เอารายได้ประจำ (v_amtpay01) ลบกับจำนวนเงินที่กำหนดไว้เป็นเงินหักเลย
        if r_tlegalexe.pctded is not null then
          v_amtpayded := round(v_amtpay01 * (r_tlegalexe.pctded/100)) ;
          if (v_amtpay01 - v_amtpayded)  <  r_tlegalexe.amtmin then
              v_amtpayded := v_amtpay01  - r_tlegalexe.amtmin  ;
          end if;
        else
          v_amtpayded := v_amtpay01 - r_tlegalexe.amtmin  ;
        end if;
        if v_amtpayded < 0 then
           v_amtpayded :=  0 ;
        end if;
        v_amtded := v_amtded + nvl(v_amtpayded,0) ;
      end if;
      if v_amtded > 0 then -- ถ้ามีการหักกรมบังคับคดี
        v_amtbal := r_tlegalexe.amtfroze - r_tlegalexe.amtded  ; -- หาจำนวนเงินที่เหลือที่จะต้องหักกรมบังคับคดี
        if v_amtded > v_amtbal and v_amtbal > 0 then
          v_amtded := v_amtbal  ; -- ถ้างวดนี้หักแล้วเกินจำนวนเงินที่เหลือ ก็ให้หักตามจำนวนเงินที่เหลือ
        end if;

        if v_amtbal < 0 then
          v_amtbal  := 0;
        else
          v_amtbal  := v_amtbal - v_amtded ; 
        end if;

        v_amtttded := v_amtttded + v_amtded ;
        begin
            insert into tlegalprd (codempid,numcaselw,numtime,dteyrepay,dtemthpay, -- เก็บยอดรวมจำนวนเงินที่หักกรมบังคับคดีในงวดนี้
                                   codcomp,amtded,amtbal,codcreate,coduser )
            values(temploy1_codempid,r_tlegalexe.numcaselw,b_index_numperiod /* user46 14/12/2021 v_numtime*/,b_index_dteyrepay - v_zyear,b_index_dtemthpay,
                   temploy1_codcomp,stdenc(v_amtded,temploy1_codempid,v_chken) ,stdenc(v_amtbal,temploy1_codempid,v_chken) ,v_coduser,v_coduser ) ;
        exception when dup_val_on_index then --<< user4 || 16/06/2022
            update tlegalprd
               set dteyrepay = b_index_dteyrepay - v_zyear,
                   dtemthpay = b_index_dtemthpay,
                   codcomp   = temploy1_codcomp,
                   amtded    = stdenc(v_amtded,temploy1_codempid,v_chken),
                   amtbal    = stdenc(v_amtbal,temploy1_codempid,v_chken),
                   coduser   = v_coduser
             where codempid  = temploy1_codempid
               and numcaselw = r_tlegalexe.numcaselw
               and numtime   = b_index_numperiod;
        end;-->> user4 || 16/06/2022

        update tlegalexe
           set dteyrded 	=	b_index_dteyrepay - v_zyear,
               dtemthded	=	b_index_dtemthpay,
               numprdded	=	b_index_numperiod,
               amtded	    =	stdenc(nvl(stddec(amtded,temploy1_codempid,v_chken),0) + v_amtded ,temploy1_codempid,v_chken)   ,
               qtyperded	= nvl(qtyperded,0) + 1
         where codempid   = temploy1_codempid
           and numcaselw  = r_tlegalexe.numcaselw ;
      end if;
  end loop;
  if v_amtttded > 0 then
	   upd_tsincexp(tcontrpy_codpaypy12,'1',true,v_amtttded);
  end if;
  --p_amtnet := p_amtnet - v_amtttded ;
END;
--
procedure cal_tax
	(p_stdate  in date,
	 p_endate  in date,
	 p_codapp  in varchar2) is

    v_exist			boolean;
    rt_ttaxmas		ttaxmas%rowtype;
    v_flgcal		tinexinf.flgcal%type;
    v_flgsoc		tinexinf.flgsoc%type;
    v_flgpvdf		tinexinf.flgpvdf%type;
    v_codpay		tsincexp.codpay%type;
    v_amtpay		number;
    v_codtax		ttaxtab.codtax%type;
    v_typpay		tinexinf.typpay%type;
    v_flgtax		tinexinf.flgtax%type;
    v_flgfml		tinexinf.flgfml%type;

    v_amtinc		number := 0;
    v_amtnet		number := 0;
    v_amttax		number := 0;
    v_taxprd		number := 0;
    v_net			  number :=	0;
    v_net1			number :=	0;
    v_net2			number :=	0;
    v_amount		number :=	0;
    v_chk 			number := 0;
    v_period		number := 0;
    v_amtcal		number := 0;
    v_othpay		number := 0;
    v_curprd		varchar2(10);
    v_amtproyr  number := 0;
    v_amtsocyr  number := 0;
    v_amttcprv  number := 0;
    v_amtsalyr  number := 0;
    v_amttaxyr  number := 0;
    v_stprd			varchar2(10);
    v_enprd			varchar2(10);
    v_amtgrstx	number := 0;
    v_taxfix		number := 0;
    --- For ttaxcur field ----
    c_amtnet  		number := 0;
    c_amtcal  		number := 0;  -- รายได้ประจำ
    c_amtincl 		number := 0;  -- รายได้อื่น ๆ กำหนดระยะเวลาจ่าย
    c_amtincc 		number := 0;  -- รายได้อื่น ๆ ชั่วคราวคำนวณภาษี
    c_amtincn		  number := 0;
    c_amtexpl 		number := 0;
    c_amtexpc 		number := 0;
    c_amtexpn 		number := 0;
    c_amttax      number := 0;

    c_amttaxoth    number := 0;
    c_amttaxothcal number := 0;

    chk_amttax    number := 0;
    c_amtgrstx 		number := 0;
    c_amtsoc  		number := 0;
    c_amtsoca     number := 0;
    c_amtsocc 		number := 0;
    c_amtcprv  		number := 0;
    c_amtprove 		number := 0;
    c_amtprovc 		number := 0;
    c_amtproie    number := 0;
    c_amtproic    number := 0;
    c_amtcalc     number := 0;

    c_codbank     ttaxcur.codbank%type;
    c_numbank     ttaxcur.numbank%type;
    c_bankfee 		number := 0;
    c_amtnet1 		number := 0;
    c_codbank2    ttaxcur.codbank2%type;
    c_numbank2    ttaxcur.numbank2%type;
    c_bankfee2 		number := 0;
    c_amtnet2 		number := 0;
    c_qtywork		  number := 0;
    c_typpaymt      ttaxcur.typpaymt%type;
    m_amtgrstxt		number := 0;
    m_amtgrstxt_1	number := 0;
    i4				number := 0;
    i5				number := 0;
    i6				number := 0;
    it4				number := 0;
    it5				number := 0;
    it6				number := 0;
    v_sumtax		number := 0;
    v_acctaxt		number := 0;
    v_amtesti		number := 0;
    v_taxtab		boolean;
    v_amtcal1		number := 0;
    v_amtcal2		number := 0;
    v_amtcal3		number := 0;
    v_tax1			number := 0;
    v_tax2			number := 0;
    v_tax3			number := 0;
    v_taxgrs2		number := 0;
    v_taxgrs3		number := 0;
    v_taxcmpstn		number := 0;
    v_device		number := 0;
    v_device_ex 	number := 0;
    v_othsalyr		number := 0;
    v_othsalnotcale number := 0;
    v_othsalnotcalc number := 0;
    v_othsalnotcalo number := 0;
    v_othsalcal	    number := 0;

    v_estimate	number := 0;
    v_taxa			number := 0;
    v_taxd			number := 0;
    v_tax			  number := 0;
    v_othinc		number := 0;
    v_othinc4	  number := 0;
    v_othinc5		number := 0;
    v_othinc6		number := 0;
    v_taxcurr		number := 0;
    v_flgesti		boolean;
    v_othtax		number := 0;
    v_cnt			  number := 0;
    v_cnt2			number := 0;
    v_dedtax		number := 0;
    v_taxemp		number := 0;
    v_sumcali4		number := 0;
    v_sumcali5		number := 0;
    v_taxcali5		number := 0;
    v_sumcali6		number := 0;
    v_taxcali6		number := 0;
    v_taxgrs5i		number := 0;
    v_taxsumcali5	number := 0;
    v_taxtotalcali5	number := 0;
    v_taxsumcali6	number := 0;
    v_taxi6			number := 0;
    s_amtgrstx		number := 0;
    v_amtgrsyr		number := 0;
    v_countsinc     number := 0;
    v_endate        date;
    v_amthour	 	number := 0;
    v_amtday		number := 0;
    v_amtmth		number := 0;
    v_taxa_sum  	number := 0;
    v_tax_bal   	number := 0;
    v_amtothe 	    number := 0;
    v_amtothc 	    number := 0;
    v_amtotho 	    number := 0;
    v_amtothfixe 	number := 0;
    v_amtothfixc 	number := 0;
    v_amtothfixo 	number := 0;
    v_sumtax4       number := 0;
    v_sumtax5       number := 0;
    v_sumtax6       number := 0;
    v_sum4          number := 0;
    v_sum5          number := 0;
    v_sum6          number := 0;
    v_baltax        number := 0;
    v_amtesti_fistmonth number := 0;
    v_mthexit       number  := 0;
    v_amtded        number  := 0;
    v_amtdedoth     number  := 0;
    v_amtdedfix     number  := 0;
    v_amtsumded     number  := 0;
    v_mthprorate 	number := 0;
    v_amtprorate 	number := 0;

    --<<user19 04/01/2018
    v_amttaxadj     number := 0;
    v_amtgrstxadj	number := 0;
    v_amttaxcbf     number := 0;
    v_sumtaxe       number := 0;
    v_sumtaxc       number := 0;
    v_sumtaxo       number := 0;

    -- user19 02/02/2019
    v_taxforcasti4		number := 0;
    v_taxforcasti5		number := 0;
    v_taxforcasti6		number := 0;

    v_taxyeari4  		number := 0;
    v_taxyeari5	  	number := 0;
    v_taxyeari6	  	number := 0;

    v_taxpayi4  		number := 0;
    v_taxpayi5	  	number := 0;
    v_taxpayi6	  	number := 0;
    v_taxsumfix  	  number := 0;
    --user19 16/12/2019
    v_net_ded       number := 0;
    v_ded           number := 0;
    v_taxothlast    number := 0;
    c_amtsoc_oth    number := 0; --<<user46 NXP-HR2101 09/12/2021
    v_amttaxadj_oth    number := 0; --<<user46 NXP-HR2101 09/12/2021

    type char1 is table of varchar2(4) index by binary_integer;
        v_codpay4		    char1;
        v_codpay5		    char1;
        v_codpay6		    char1;
        v_codpayinc4		char1;
        v_codpayinc5		char1;
        v_codpayinc6		char1;

    type num1 is table of number index by binary_integer;
        --รายได้อื่นๆชั่วคราว
        v_amtcal4		num1;
        v_amtcal5		num1;
        v_amtcal6		num1;
        v_tax4			num1;
        v_tax5			num1;
        v_tax6			num1;
        --รายได้อื่นๆกำหนดระยะเวลาจ่าย
        v_tempinc4	    num1;
        v_tempinc5	    num1;
        v_tempinc6	    num1;
        v_taxtinc4	    num1;
        v_taxtinc5	    num1;
        v_taxtinc6	    num1;
        v_taxgrs5		    num1;
        v_taxgrs6		    num1;
        v_taxtempgrs5	  num1;
        v_taxtempgrs6	  num1;

        v_flgamtcal     varchar2(1) ;
        v_syncondsc     varchar2(1000) ;
        v_flgfound	    number :=0;
        v_amtoth_fix    number :=0;

  type table_arr  is table of tdtepay%rowtype index by binary_integer;
      r_tdtepay   table_arr ;
      v_numprd    number ;

    cursor c_tsincexp is
        select codpay,stddec(amtpay,codempid,v_chken) amtpay,typincexp
          from tsincexp
         where codempid  = temploy1_codempid
           and dteyrepay = b_index_dteyrepay - v_zyear
           and dtemthpay = b_index_dtemthpay
           and numperiod = b_index_numperiod
           and flgslip	 = '1'; -- เงินได้ส่วนหักจ่ายผ่านระบบ

    cursor c_tothpay is
        select codpay,stddec(amtpay,codempid,v_chken) amtpay,flgpyctax
          from tothpay -- HRPY23E เงินได้จ่ายนอกระบบ
         where codempid  = temploy1_codempid
           and dteyrepay = b_index_dteyrepay - v_zyear
           and dtemthpay = b_index_dtemthpay
           and numperiod = b_index_numperiod;

    cursor c_ttaxtab is
        select codtax
          from ttaxtab
         where codtax = v_codpay
          and rownum = 1;

    cursor c_ttyppymt is
        select flgpaymt,dteyrepay_st,dtemthpay_st,numperiod_st,dteyrepay_en,dtemthpay_en,numperiod_en
          from ttyppymt
         where codempid	=	temploy1_codempid;

    cursor c_ttaxcur is
        select rowid
          from ttaxcur
         where codempid =  temploy1_codempid
           and dteyrepay = b_index_dteyrepay - v_zyear
           and dtemthpay = b_index_dtemthpay
           and numperiod = b_index_numperiod;

    cursor c_ttaxmas is
        select rowid
          from ttaxmas
         where codempid = temploy1_codempid
           and dteyrepay = b_index_dteyrepay - v_zyear;

    cursor c_tdtepay is
        select *
          from tdtepay
         where codcompy   = b_var_codcompy
           and typpayroll = b_var_typpayroll
           and dteyrepay  = (b_index_dteyrepay - v_zyear)
        order by dtemthpay asc ,numperiod asc ;

begin

  -- v_amtcal   รายได้ประจำ
  -- v_amtcal1  รายได้ที่ไม่มีคู่ภาษี -- หัก ณ ที่จ่าย
  -- v_amtcal2  รายได้ที่ไม่มีคู่ภาษี -- บ.ออกให้
  -- v_amtcal3  รายได้ที่ไม่มีคู่ภาษี -- บ.ออกให้ครั้งเดียว
  for i in 1..30 loop
      --รายได้อื่นๆชั่วคราว
      v_codpay4(i)	:= null;	v_codpay5(i)	:= null;	v_codpay6(i)  	:= null;
      v_amtcal4(i)	:= 0;		  v_amtcal5(i)	:= 0;		v_amtcal6(i)	:= 0;
      v_tax4(i)		  := 0;		  v_tax5(i)		  := 0;		v_tax6(i)		:= 0;
      --รายได้อื่นๆกำหนดระยะเวลาจ่าย
      v_codpayinc4(i)	 := null;	v_codpayinc5(i)	 := null;	v_codpayinc6(i)	:= null;
      v_tempinc4(i)    := 0;      v_tempinc5(i)    := 0;      v_tempinc6(i)   := 0;
      v_taxtinc4(i)    := 0;	    v_taxtinc5(i)	 := 0;		v_taxtinc6(i)	:= 0;
      v_taxtempgrs5(i) := 0 ;     v_taxtempgrs6(i) := 0 ;
  end loop;

  i4  := 0;   i5    := 0;  i6 := 0;
  it4 := 0;   it5   := 0; it6 := 0;
  declare_var_forecast_othfix := 0 ;
	for r_tsincexp in c_tsincexp loop
        v_codpay := r_tsincexp.codpay;
        v_amtpay := nvl(r_tsincexp.amtpay,0);
        if v_codpay = tcontrpy_codpaypy1 then --Tax ภาษีหัก ณ ที่จ่าย
            --c_amttax := nvl(c_amttax,0) + v_amtpay;
            v_amttaxadj := nvl(v_amttaxadj,0) + v_amtpay; -- v_amttaxadj เหมือนจะไม่ได้ใช้ทำอะไรต่อ 28/04/2022 By S      
        elsif v_codpay = tcontrpy_codpaypy2 then --Soc of Emp. เงินสมทบประกันสังคม
            c_amtsoca := nvl(c_amtsoca,0) + v_amtpay;
        elsif v_codpay = tcontrpy_codpaypy3 then --Pvdf. of Emp. เงินกองทุนสำรองเลี้ยงชีพ
            c_amtprove := nvl(c_amtprove,0) + v_amtpay;
        elsif v_codpay = tcontrpy_codpaypy4 then --ภาษีบริษัทออกให้ ภาษีบริษัทออกให้
            v_amtgrstxadj   := nvl(v_amtgrstxadj,0) + v_amtpay;
        elsif	v_codpay = tcontrpy_codpaypy6 then --Soc of Comp. เงินประกันสังคม (ส่วนบริษัท)
            c_amtsocc := nvl(c_amtsocc,0) + v_amtpay;
        elsif	v_codpay = tcontrpy_codpaypy7 then --Pvdf. of Comp. เงินสะสมกองทุนสำรองเลี้ยงชีพ (บริษัท)
            c_amtprovc := nvl(c_amtprovc,0) + v_amtpay;
        else
            -- หา codpay ที่ต้องนำมาคำนวณภาษี
            for r_ttaxtab in c_ttaxtab loop
              --<< เหมือนจะไม่ได้ใช้ Comment 28/04/2022 By S
                /*if v_codpay = tcontrpy_codtax then -- ภาษีเงินได้จ่ายครั้งเดียว
                    v_taxcmpstn := v_amtpay;
                else
                    --c_amttax := nvl(c_amttax,0) + v_amtpay;
                    v_amttaxadj := nvl(v_amttaxadj,0) + v_amtpay;
                end if;*/
                
              -->> 28/04/2022 By S
              v_amttaxadj_oth := nvl(v_amttaxadj_oth,0) + v_amtpay;
                goto loop_next; -- ถ้าเป็น code ภาษีให้ข้าม
            end loop;
            -- หาว่า codpay นี้ต้องคำนวณอะไรบ้าง
            begin
                select typpay,flgcal,flgsoc,flgpvdf,flgtax --ประเภทรหัส ,ภาษี , ssc , pf ,tax
                  into v_typpay,v_flgcal,v_flgsoc,v_flgpvdf,v_flgtax
                  from tinexinf
                 where codpay = v_codpay;
            exception when no_data_found then
              goto loop_next;
            end;

            if v_typpay = '6' then -- 6-รหัสภาษี
              -- c_amttax := nvl(c_amttax,0) + v_amtpay;
                v_amttaxadj_oth := nvl(v_amttaxadj_oth,0) + v_amtpay; -- v_amttaxadj เหมือนจะไม่ได้ใช้ทำอะไรต่อ 28/04/2022 By S              
                goto loop_next;
            elsif v_typpay = '7' then -- 7-สำหรับการลงบัญชี
                goto loop_next;
            end if;

            if v_flgpvdf = 'Y' then --ถ้าคำนวณ PF
                if r_tsincexp.typincexp in ('1','2','3') then --รายได้ประจำ , รายได้อื่น ๆ (ประจำ) , (ชั่วคราว)
                    c_amtcprv := nvl(c_amtcprv,0) + v_amtpay;
                else --ค่าใช้จ่าย(ประจำ) , (ชั่วคราว)
                    c_amtcprv := nvl(c_amtcprv,0) - v_amtpay;
                end if;
            end if;

            if v_flgsoc = 'Y' then --ถ้าคำนวณ ประกันสังคม
                if r_tsincexp.typincexp in ('1','2','3') then
                    c_amtsoc := nvl(c_amtsoc,0) + v_amtpay;
                    if r_tsincexp.typincexp in ('3') then -- รายได้อื่นๆ ชั่วคราว
                      c_amtsoc_oth := nvl(c_amtsoc_oth,0) + v_amtpay;
                    end if;
                else
                    c_amtsoc := nvl(c_amtsoc,0) - v_amtpay;
                end if;
            end if;

            if v_flgcal = 'Y' then -- ถ้าคำนวณภาษี
                if r_tsincexp.typincexp = '1' then
                    c_amtcal := nvl(c_amtcal,0) + v_amtpay;   --รายได้ประจำ
                elsif r_tsincexp.typincexp = '2' then
                    c_amtincl := nvl(c_amtincl,0) + v_amtpay; -- รายได้อื่น ๆ กำหนดระยะเวลาจ่าย
                elsif r_tsincexp.typincexp = '3' then
                    c_amtincc := nvl(c_amtincc,0) + v_amtpay; -- รายได้อื่น ๆ ชั่วคราวคำนวณภาษี
                elsif r_tsincexp.typincexp = '4' then
                    c_amtexpl := nvl(c_amtexpl,0) + v_amtpay; -- ส่วนหักประจำ
                elsif r_tsincexp.typincexp = '5' then
                    c_amtexpc := nvl(c_amtexpc,0) + v_amtpay; -- ส่วนหักอื่น ๆ คำนวณภาษี
                end if;
                v_taxtab := false;
                for j in 1..declare_var_v_max loop
                    if declare_var_v_tab_codpay(j) = v_codpay then -- เช็ครหัสรายได้ว่ามีกำหนดคู่ภาษีไว้หรือไม่
                        v_taxtab := true;
                    end if;
                end loop;
                -- 1. ถ้า codpay อยู่ใน รหัสรายได้ประจำ
                if v_codpay in (tcontpms_codincom1,tcontpms_codincom2,
                    tcontpms_codincom3,tcontpms_codincom4,
                    tcontpms_codincom5,tcontpms_codincom6,
                    tcontpms_codincom7,tcontpms_codincom8,
                    tcontpms_codincom9,tcontpms_codincom10) then
                    v_amtcal   := v_amtcal + v_amtpay; -- รายได้ประจำ
                -- 2. ถ้า codpay เป็นรายได้ประจำ หรือ ส่วนหักประจำ
                elsif  r_tsincexp.typincexp in ('1','4') then
                    if  r_tsincexp.typincexp in ('1') and temploy3_flgtax = v_flgtax then   -- รายได้ประจำ
                        v_amtcal := v_amtcal + v_amtpay;
                    elsif r_tsincexp.typincexp in ('4') then   -- ส่วนหักประจำ
                        v_amtcal := v_amtcal - v_amtpay;
                        v_amtded := v_amtded + v_amtpay ;
                    end if;
                    -- 3. ถ้า codpay ไม่ใช่รายได้ประจำและส่วนหักประจำ และไม่มีคู่ภาษี
                elsif not v_taxtab then  --- แบบไม่มีคู่ภาษี
                    if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                        if r_tsincexp.typincexp in ('1','2','3') then
                            --v_amtcal1 := v_amtcal1 + v_amtpay;
                            v_amtcal := v_amtcal + v_amtpay;
                        elsif r_tsincexp.typincexp in ('4') then -- case นี้จะไม่เกิด เพราะว่าเข้า case บนก่อน ให้ตรวจสอบและ update code
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedfix := v_amtdedfix + v_amtpay ;
                        elsif r_tsincexp.typincexp = '5' then
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedoth := v_amtdedoth + v_amtpay ;
                        end if;
                    elsif v_flgtax = '2' then -- บ.ออกให้
                        if r_tsincexp.typincexp in ('1','2','3') then
                            v_amtcal2 := v_amtcal2 + v_amtpay;
                        elsif r_tsincexp.typincexp in ('4') then -- case นี้จะไม่เกิด เพราะว่าเข้า case บนก่อน ให้ตรวจสอบและ update code
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedfix := v_amtdedfix + v_amtpay ;
                        elsif r_tsincexp.typincexp = '5' then
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedoth := v_amtdedoth + v_amtpay ;
                        end if;
                    else -- บ.ออกให้ครั้งเดียว
                        if  r_tsincexp.typincexp in ('1','2','3') then
                            v_amtcal3 := v_amtcal3 + v_amtpay;
                        elsif r_tsincexp.typincexp in ('4') then -- case นี้จะไม่เกิด เพราะว่าเข้า case บนก่อน ให้ตรวจสอบและ update code
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedfix := v_amtdedfix + v_amtpay ;
                        elsif r_tsincexp.typincexp = '5' then
                            v_amtcal    := v_amtcal - v_amtpay;
                            v_amtdedoth := v_amtdedoth + v_amtpay ;
                        end if;
                    end if;
                -- 3. ถ้า codpay ไม่ใช่รายได้ประจำแต่มีคู่ภาษีแบ่งเป็น 2 Case 1-รายได้อื่นๆกำหนดระยะเวลาจ่าย 2-รายได้อื่นๆชัวคราว
                else
                    if  v_typpay  = '2' then  -- รายได้อื่นๆกำหนดระยะเวลาจ่าย
                        if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                            it4 := it4 + 1;
                            v_codpayinc4(it4) := v_codpay;
                            if r_tsincexp.typincexp in ('2') then
                                v_tempinc4(it4) := v_amtpay;
                                v_amtothfixe    := v_amtothfixe + v_amtpay;
                            elsif r_tsincexp.typincexp in ('4') then
                                v_amtcal := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        elsif v_flgtax = '2' then -- บ.ออกให้
                            it5 := it5 + 1;
                            v_codpayinc5(it5) := v_codpay;
                            if r_tsincexp.typincexp in ('2') then
                                v_tempinc5(it5) := v_amtpay;
                                v_amtothfixc    := v_amtothfixc + v_amtpay;
                            elsif r_tsincexp.typincexp in ('4') then
                                v_amtcal := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        else -- บ.ออกให้ครั้งเดียว
                            it6 := it6 + 1;
                            v_codpayinc6(it6) := v_codpay;
                            if r_tsincexp.typincexp in ('2') then
                                v_tempinc6(it6) := v_amtpay;
                                v_amtothfixo       := v_amtothfixo + v_amtpay;
                            elsif r_tsincexp.typincexp in ('4' ) then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        end if;
                    elsif  v_typpay  = '3' then  -- รายได้อื่นๆชัวคราว
                        if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                            i4 := i4 + 1;
                            v_codpay4(i4) := v_codpay;
                            if r_tsincexp.typincexp in ('3') then
                                v_amtcal4(i4) := v_amtpay;
                            elsif r_tsincexp.typincexp in ('4') then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        elsif v_flgtax = '2' then -- บ.ออกให้
                            i5 := i5 + 1;
                            v_codpay5(i5) := v_codpay;
                            if r_tsincexp.typincexp in ('3') then
                                v_amtcal5(i5) := v_amtpay;
                            elsif r_tsincexp.typincexp in ('4') then
                                v_amtcal     := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        else -- บ.ออกให้ครั้งเดียว
                            i6 := i6 + 1;
                            v_codpay6(i6) := v_codpay;
                            if r_tsincexp.typincexp in ('3') then
                                v_amtcal6(i6) := v_amtpay;
                            elsif r_tsincexp.typincexp in ('4') then
                                v_amtcal := v_amtcal - v_amtpay;
                                v_amtdedfix := v_amtdedfix + v_amtpay ;
                            elsif r_tsincexp.typincexp = '5' then
                                v_amtcal    := v_amtcal - v_amtpay;
                                v_amtdedoth := v_amtdedoth + v_amtpay ;
                            end if;
                        end if;
                    end if;
                end if;
        else -- ถ้าไม่คำนวณภาษี
            if r_tsincexp.typincexp in ('1','2','3') then
                c_amtincn := nvl(c_amtincn,0) + v_amtpay; -- รายได้อื่นๆ ไม่คำนวณภาษี
            elsif r_tsincexp.typincexp in ('4','5') then
                c_amtexpn := nvl(c_amtexpn,0) + v_amtpay; -- ส่วนหักอื่น ๆ ไม่คำนวณภาษี
            end if;
        end if;
    end if;
    <<loop_next>>
    null;
	end loop; -- for c_tsincexp
  get_oth_ded ; --setup ลำดับการตัดชำระหนี้
  -- external payment
  for r_tothpay in c_tothpay loop -- เงินได้จ่ายนอกระบบ logic ใน loop เขียนคล้ายๆกับ loop c_tsincexp เลย อาจจะยุบได้
        v_codpay := r_tothpay.codpay;
        v_amtpay := nvl(r_tothpay.amtpay,0);
        begin
            select typpay,flgcal,flgsoc,flgpvdf,flgtax
              into v_typpay,v_flgcal,v_flgsoc,v_flgpvdf,v_flgtax
              from tinexinf
             where codpay = v_codpay;
             temploy3_flgsoc := v_flgsoc;
        exception when no_data_found then
            goto loop_next;
        end;
        if v_typpay in('1','2','3') then
            v_othpay := v_othpay + v_amtpay;
        elsif v_typpay in ('4','5') then
            v_othpay := v_othpay - v_amtpay;
        end if;
        if v_codpay = tcontrpy_codpaypy1 then --tax
            if r_tothpay.flgpyctax = 'Y' then  --ถ้าคำนวณภาษีโดย PY
                c_amttaxothcal := nvl(c_amttaxothcal,0) + v_amtpay;
            else
                c_amttaxoth := nvl(c_amttaxoth,0) + v_amtpay;
            end if;
        elsif v_codpay = tcontrpy_codpaypy2 then --Soc of Emp.
            c_amtsoca := nvl(c_amtsoca,0) + v_amtpay;
        elsif v_codpay = tcontrpy_codpaypy3 then --Pvdf. of Emp.
            c_amtprove := nvl(c_amtprove,0) + v_amtpay;
        elsif v_codpay = tcontrpy_codpaypy4 then --ภาษีบริษัทออกให้
            c_amtgrstx   := nvl(c_amtgrstx,0) + v_amtpay;
        elsif	v_codpay = tcontrpy_codpaypy6 then --Soc of Comp.
            c_amtsocc := nvl(c_amtsocc,0) + v_amtpay;
        elsif	v_codpay = tcontrpy_codpaypy7 then --Pvdf. of Comp.
            c_amtprovc := nvl(c_amtprovc,0) + v_amtpay;
        else
            for r_ttaxtab in c_ttaxtab loop
                if v_codpay = tcontrpy_codtax then
                    null;
                else
                    if r_tothpay.flgpyctax = 'Y' then  --ถ้าคำนวณภาษีโดย PY
                        c_amttaxothcal := nvl(c_amttaxothcal,0) + v_amtpay;
                    else
                        c_amttaxoth := nvl(c_amttaxoth,0) + v_amtpay;
                    end if;

                end if;
            goto loop_next;
            end loop;

            if v_typpay = '6' then
                if r_tothpay.flgpyctax = 'Y' then  --ถ้าคำนวณภาษีโดย PY
                    c_amttaxothcal := nvl(c_amttaxothcal,0) + v_amtpay;
                else
                    c_amttaxoth := nvl(c_amttaxoth,0) + v_amtpay;
                end if;
              goto loop_next;
            elsif v_typpay = '7' then
              goto loop_next;
            end if;

            if r_tothpay.flgpyctax = 'Y' then  --ถ้าคำนวณภาษีโดย PY
                if v_flgpvdf = 'Y' then -- ถ้าคำนวณ PF
                  if v_typpay in ('1','2','3') then
                    c_amtcprv := nvl(c_amtcprv,0) + v_amtpay;
                  else
                    c_amtcprv := nvl(c_amtcprv,0) - v_amtpay;
                  end if;
                end if; -- PF
                if v_flgsoc = 'Y' then -- ถ้าคำนวณประกันสังคม
                  if v_typpay in ('1','2','3') then
                    c_amtsoc := nvl(c_amtsoc,0) + v_amtpay;
                    if v_typpay in ('3') then
                      c_amtsoc_oth := nvl(c_amtsoc_oth,0) + v_amtpay;
                    end if;
                  else
                    c_amtsoc := nvl(c_amtsoc,0) - v_amtpay;
                  end if;
                end if; -- soc
            end if;	-- คำนวณภาษี

            if (v_flgcal = 'Y') then
                if v_typpay = '1' then
                    c_amtcal := nvl(c_amtcal,0) + v_amtpay;
                elsif v_typpay = '2' then
                    c_amtincl := nvl(c_amtincl,0) + v_amtpay;
                elsif v_typpay = '3' then
                    c_amtincc := nvl(c_amtincc,0) + v_amtpay;
                elsif v_typpay = '4' then
                    c_amtexpl := nvl(c_amtexpl,0) + v_amtpay;
                elsif v_typpay = '5' then
                    c_amtexpc := nvl(c_amtexpc,0) + v_amtpay;
                end if;
                if (r_tothpay.flgpyctax = 'Y') then --- รหัสภาษีใน set up ข้อมูลเริ่มต้นระบบ PY
                    v_taxtab := false;
                    for j in 1..declare_var_v_max loop
                        if declare_var_v_tab_codpay(j) = v_codpay then
                            v_taxtab := true;
                        end if;
                    end loop;
                    if v_codpay in (tcontpms_codincom1, tcontpms_codincom2,
                                      tcontpms_codincom3, tcontpms_codincom4,
                                      tcontpms_codincom5, tcontpms_codincom6,
                                      tcontpms_codincom7, tcontpms_codincom8,
                                      tcontpms_codincom9, tcontpms_codincom10)
                                      or v_typpay in ('1','2','4') then
                        if v_typpay in ('1','2','3') then
                            v_amtcal := v_amtcal + v_amtpay;
                        elsif v_typpay in ('4','5') then
                            v_amtcal := v_amtcal - v_amtpay;
                        end if;
                    elsif not v_taxtab then  -- รหัสรายได้/ส่วนหักที่ไม่มีคู่ภาษี
                        if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                            if v_typpay in ('1','2','3') then
                                v_amtcal := v_amtcal + v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        elsif v_flgtax = '2' then -- บ.ออกให้
                            if v_typpay in ('1','2','3') then
                                v_amtcal := v_amtcal + v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        else -- บ.ออกให้ครั้งเดียว
                            if v_typpay in ('1','2','3') then
                                v_amtcal := v_amtcal + v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        end if;
                    else --- รหัสรายได้/ส่วนหักอื่นๆ ที่มีคู่ภาษี
                        if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                            i4 := i4 + 1;
                            v_codpay4(i4) := v_codpay;
                            if v_typpay in ('1','2','3') then
                                v_amtcal4(i4) := v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        elsif v_flgtax = '2' then -- บ.ออกให้
                            i5 := i5 + 1;
                            v_codpay5(i5) := v_codpay;
                            if v_typpay in ('1','2','3') then
                                v_amtcal5(i5) := v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        else -- บ.ออกให้ครั้งเดียว
                            i6 := i6 + 1;
                            v_codpay6(i6) := v_codpay;
                            if v_typpay in ('1','2','3') then
                                v_amtcal6(i6) := v_amtpay;
                            elsif v_typpay in ('4','5') then
                                v_amtcal := v_amtcal - v_amtpay;
                            end if;
                        end if;
                    end if;
                else
                    if v_typpay in ('1','2','3') then
                          if v_flgtax = '1' then -- หัก ณ ที่จ่าย
                              v_othsalnotcale := v_othsalnotcale + v_amtpay;
                           elsif v_flgtax = '2' then -- บ.ออกให้
                              v_othsalnotcalc := v_othsalnotcalc + v_amtpay;
                           elsif v_flgtax = '3' then -- บ.ออกให้ครั้งเดียว
                              v_othsalnotcalo := v_othsalnotcalo + v_amtpay;
                           end if;
                    end if;
                end if; -- if (r_tothpay.flgpyctax = 'Y') then
          else -- ไม่คำนวณภาษี
            if v_typpay in ('1','2','3') then
                c_amtincn := nvl(c_amtincn,0) + v_amtpay;
            elsif v_typpay in ('4','5') then
                c_amtexpn := nvl(c_amtexpn,0) + v_amtpay;
            end if;
          end if; -- v_flgcal = 'Y'
        end if; -- end if v_codpay
    <<loop_next>>
    null;
	end loop; -- for c_tothpay

  -- หาจำนวนเงินภาษีบริษัทออกให้
	select nvl(sum(stddec(amtgrstx,temploy1_codempid,v_chken)),0), -- ภาษีบริษัทออกให้
	       nvl(sum(stddec(amtcalc,temploy1_codempid,v_chken)),0) -- จำนวนเงินบริษัทออกให้ ไม่ได้ใช้เอาไปทำอะไรต่อ
	  into v_amtgrstx,v_amtgrsyr
	  from ttaxcur
	 where codempid  = temploy1_codempid
     and dteyrepay   = b_index_dteyrepay - v_zyear;

  -- หาข้อมูลทุก field จากตาราง ttaxmas
	begin
		select * into rt_ttaxmas
		  from ttaxmas
		 where codempid  = temploy1_codempid
	     and dteyrepay   = b_index_dteyrepay - v_zyear;
	exception when no_data_found then
		rt_ttaxmas := null;
	end;

	-- Cal PF
	v_amtproyr := nvl(stddec(rt_ttaxmas.amtprovte,temploy1_codempid,v_chken),0); -- เงินกองทุนส่วนของพนักงานสะสม
	cal_prov(p_stdate,p_endate,c_amtcprv,c_amtprove,c_amtprovc,v_amtproyr); -- (วันที่คำนวณเริ่ม,วันที่คำนวณสิ้นสุด,รายได้ส่วนหักคำนวณ PF,PF ของพนักงาน,PF ของบริษัท,เงินกองทุนส่วนของพนักงานสะสม)

	  -- Cal Soc
    v_flgfound := 0;
    if tcontrpy_syncond is not null then -- เช็คเงื่อนไขสำหรับคนที่ต้องคำนวณประกันสังคม
        v_syncondsc := tcontrpy_syncond ;
        v_syncondsc := replace(v_syncondsc,'TEMPLOY1.CODEMPID',''''||temploy1_codempid||'''') ;
        v_syncondsc := replace(v_syncondsc,'TEMPLOY1.TYPPAYROLL',''''||temploy1_typpayroll||'''') ;
        v_syncondsc := replace(v_syncondsc,'TEMPLOY1.CODEMPMT',''''||temploy1_codempmt||'''') ;
        v_syncondsc := replace(v_syncondsc,'TEMPLOY1.TYPEMP',''''||temploy1_typemp||'''') ;
        v_syncondsc := 'select count(*) from temploy1 where '||v_syncondsc||' and codempid ='''||temploy1_codempid||'''' ;
        v_flgfound  := execute_qty(v_syncondsc) ;
    end if;

--    c_amtsoca := 0;
    temploy3_flgsoc  := 'N';
    if v_flgfound =  0 then
        temploy3_flgsoc  := 'Y'; -- user4 || 09/03/2020
        v_amtsocyr := nvl(stddec(rt_ttaxmas.amtsocat,temploy1_codempid,v_chken),0); -- เงินประกันสังคมสะสม
        cal_social(c_amtsoc,c_amtsoc_oth,c_amtsoca,c_amtsocc,v_amtsocyr); -- (เงินคำนวณประกันสังคมประจำ,เงินคำนวณประกันสังคมขั่วคราว,เงินสมทบประกันสังคม,เงินสมทบประกันสังคมส่วนของบริษัท,เงินประกันสังคมสะสม)
    end if;

	if (nvl(c_amtcal,0) + nvl(c_amtincc,0) + nvl(c_amtincn,0) + nvl(c_amtincl,0)) -
	   (nvl(c_amtexpc,0) + nvl(c_amtexpn,0) + nvl(c_amtexpl,0) +
	    nvl(c_amtprove,0) + nvl(c_amtsoca,0)) <= 0 then -- ถ้ารายได้ - ส่วนหัก < 0
	    insert_error(get_errorm_name('PY0023',v_lang)); -- เงินได้ก่อนหักภาษีน้อยกว่าหรือเท่ากับศูนย์
	end if;
	-- กำหนดค่าตัวคูณ / หาร ในการประเมิน ต่อปี / งวด  สำหรับ รายได้
--  msg_err (' tddec(rt_ttaxmas.amtcprvt,temploy1_codempid,v_chken) '||stddec(rt_ttaxmas.amtcprvt,temploy1_codempid,v_chken)) ;
--  msg_err (' c_amtcprv '||c_amtcprv) ;
--  msg_err (' b_var_balperd '||b_var_balperd) ;
	v_amttcprv := nvl(stddec(rt_ttaxmas.amtcprvt,temploy1_codempid,v_chken),0) -- เงินได้ที่นำมาคำนวณกองทุนสะสม -- ตรวจสอบ code จุดนี้อาจจะผิด
	              + (nvl(c_amtcprv,0) * b_var_balperd); -- เงินได้ที่นำมาคำนวณกองทุน
	declare_var_v_amtexp 	:= null;
	declare_var_v_maxexp 	:= null;
	declare_var_v_amtdiff := null;

	v_device := greatest(b_var_balperd,1);
  v_device     := 12; -- hard
  v_device_ex  := 12;

	cal_estimate(v_estimate,v_device); -- คำนวณรายได้จนถึงเดือนที่ลาออก
  --msg_err('เงินได้พึงประเมิน พนักงานพ้นสภาพ cal_estimate => v_estimate = '||v_estimate);
	--- หาเงินได้พึงประเมิณทั้งปี
	--- b_var_amtcal  = จำนวนเงินที่ได้จาสูตรรายได้ต่อเดือน/ต่อวัน
	--- b_var_mqtypay = จำนวนงวดในเดือน
	--- b_var_perdpay = จำนวนงวดที่เหลือในเดือน
  --if (b_var_stacal = '4') or ((b_var_stacal = '2') and (b_index_flag = 'N')) or
	--	 ((temploy1_dteeffex = b_var_dteend + 1) and (b_index_flag = 'N')) then
    v_mthexit := null ; -- หาเดือนที่ลาออก  จาก TDTEPAY เก็บใส่ตัวแปร  v_mthexit
    if   temploy1_dteeffex is not null then
        for prd in c_tdtepay loop -- งวดทั้งหมดในปีเรียงจากน้อยไปมาก
            if v_mthexit is not null then
                v_mthexit := prd.dtemthpay ;
                exit ;
            end if;
            if  temploy1_dteeffex between  prd.dtestrt+1  and  prd.dteend    then -- หาเดือนที่ลาออก
                v_mthexit := prd.dtemthpay ;
            elsif  temploy1_dteeffex =  prd.dtestrt    then
                v_mthexit := prd.dtemthpay ;
                exit ;
            end if;
        end loop;
    end if;

  if ((b_var_stacal = '2') and (b_index_flag = 'N')) then -- ลาออกระหว่างงวดและคำนวณถึงวันที่ลาออก
      v_amtesti := 0;
      v_device 	:= 1;
	--elsif b_var_staemp = '5' then -- ทำงานเดือนสุดท้าย (ลาออก)
  elsif ((temploy1_dteeffex = b_var_dteend + 1) and b_index_flag = 'N') then
         v_amtesti := 0;
  elsif ((temploy1_dteeffex > b_var_dteend + 1) and b_index_flag = 'N') then
         v_amtesti := v_estimate;
	elsif temploy1_qtydatrq > 0 then -- กำหนดการจ้างงาน(เดือน)
      select count(codcompy) into v_cnt
        from tdtepay
       where codcompy   = b_var_codcompy
         and typpayroll = b_var_typpayroll
         and dteyrepay  = (b_index_dteyrepay - v_zyear)
         and dtestrt    > b_var_dtebeg
         and dteend     <= temploy1_dtedatrq -- add_months(temploy1_dteempmt,r_emp.qtydatrq);
         and (flgcal     = 'N' or flgcal is null);
         v_amtesti := (b_var_amtcal / b_var_mqtypay) * v_cnt; -- รายได้ต่อเดือน * จำนวนงวดที่เหลือถึงวันครบสัญญาจ้าง / จำนวนงวดในเดือน
	else
      if b_var_flglast = 'Y' then -- เป็นงวดสุดท้ายของปี
       	 /* v_amtesti := ((b_var_amtcal * (12 - b_index_dtemthpay)) + -->> Comment 28/04/2022 By user46
								      ((b_var_amtcal / b_var_mqtypay) * b_var_perdpay));
            v_amtesti := ((30000 * (12 - 12)) + ((30000 / 1) * 0) */
        v_amtesti := 0; -->> 28/04/2022 By user46
      else
        v_numprd  := 0 ;
        for prd in c_tdtepay loop
           v_numprd := v_numprd + 1 ;
           begin
             select * into r_tdtepay(v_numprd) -- งวดทั้งหมดในปีใส่ array
             from  tdtepay
             where codcompy  = prd.codcompy
              and typpayroll = prd.typpayroll
              and dteyrepay = prd.dteyrepay
              and dtemthpay = prd.dtemthpay
              and numperiod =prd.numperiod ;
             exception when others then
                r_tdtepay(v_numprd) := null ;
             end ;
        end loop;

        if  nvl(tcontrpy_typesitm,'1') = '2' then--พิงประเมินแบบ x 12 เดือน
              v_amtesti := 0 ;
              v_cnt2    := 0 ;
              if  temploy1_dteeffex is null   then
              for prd in 1..v_numprd loop
                if  r_tdtepay(prd).dtemthpay||r_tdtepay(prd).numperiod  <>  b_index_dtemthpay||b_index_numperiod or  (b_var_stacal = '4') then -- b_var_stacal = 4 ==> พ้นสภาพ
                    if  temploy1_dteempmt between  (r_tdtepay(prd).dtestrt+1)  and r_tdtepay(prd).dteend    then
                        begin
                          select count(distinct(dtemthpay)) into v_cnt -- check data ว่ามีใน ttaxcur
                          from  ttaxcur
                          where codempid  = temploy1_codempid
                          and   dteyrepay = r_tdtepay(prd).dteyrepay
                          and   dtemthpay = r_tdtepay(prd).dtemthpay
                          and   numperiod = r_tdtepay(prd).numperiod ;
                        end ;
                        if prd < v_numprd then
                            begin
                              select count(distinct(dtemthpay)) into v_cnt2 -- check data ว่ามีใน ttaxcur ในงวดถัดไป
                              from  ttaxcur
                              where codempid  = temploy1_codempid
                              and   dteyrepay = r_tdtepay(prd+1).dteyrepay
                              and   dtemthpay = r_tdtepay(prd+1).dtemthpay
                              and   numperiod = r_tdtepay(prd+1).numperiod ;
                            end ;
                        end if;
                        if  nvl(v_cnt,0) > 0  or  (nvl(v_cnt,0) = 0  and nvl(v_cnt2,0) > 0 )   then
                            v_amtprorate := (((r_tdtepay(prd).dteend - temploy1_dteempmt )+ 1 )  *  (b_var_amtcal / v_numday)) ; -- prorate เงินเดือนในงวดที่เริ่มทำงาน
                            begin
                              select flgfml  into v_flgfml
                              from tinexinf
                              where	codpay = tcontpms_codincom1;
                            exception when no_data_found then
                              null  ;
                            end;
                            v_amtprorate  :=  proc_round(v_flgfml,v_amtprorate);
                            v_amtesti :=  v_amtesti +  v_amtprorate ;
                        end if;
                    elsif r_tdtepay(prd).dteend  > temploy1_dteempmt   then
                      -- เอาทุกงวดยกเว้นงวดปัจจุบัน
                        v_amtesti :=  v_amtesti + (b_var_amtcal / b_var_mqtypay) ; -- sum เงินเดือนงวดก่อนงวดที่จะคำนวณ v_amtesti + (รายได้ต่อเดือน / จำนวนงวดในเดือน)
                    end if;
                end if;
              end loop;
              else -- review code ส่วน else อีกรอบ code น่าจะผิดอยู่
                 for prd in 1..v_numprd loop
                     select count(codempid) into v_cnt  -- check data ว่ามีใน ttaxcur
                     from  ttaxcur
                     where codempid  = temploy1_codempid
                     and   dteyrepay = b_index_dteyrepay - v_zyear
                     and   dtemthpay = r_tdtepay(prd).dtemthpay
                     and   numperiod = r_tdtepay(prd).numperiod ;
                     if    temploy1_dteempmt <  r_tdtepay(prd).dteend then
                         if  v_cnt = 0  then
                           if  temploy1_dteeffex   between  r_tdtepay(prd).dtestrt+1   and  r_tdtepay(prd).dteend+1 then
                               null ;
                               if b_index_flag = 'N' then exit; end if; -- b_index_flag = 'N' ==> คำนวณถึงวันที่ลาออก
                           else -- temploy1_dteeffex is null then
                              v_amtesti :=  v_amtesti + (b_var_amtcal / b_var_mqtypay) ; -- estimate เฉพาะงวดที่เหลือจนถึงงวดที่ลาออก
                              v_device  :=  v_device  +  1 ;
                           end if;
                         end if;
                     end if;
                  end loop;
              end if;
              --หาจำนวนงวดที่จะนำมาหาร
              v_device := 0 ;
              for prd in c_tdtepay loop
                  if temploy1_dteempmt between  (prd.dtestrt+1)  and prd.dteend    then
                     select count(codempid) into v_cnt
                     from  ttaxcur
                     where codempid  = temploy1_codempid
                     and   dteyrepay = b_index_dteyrepay - v_zyear
                     and   dtemthpay = prd.dtemthpay
                     and   numperiod = prd.numperiod ;
                     if ( v_cnt > 0  and prd.dtemthpay||prd.numperiod  <>  b_index_dtemthpay||b_index_numperiod ) or -- ถ้ามีใน ttaxcur และ ไม่ใช่งวดที่กำลังคำนวณ
                          prd.dtemthpay||prd.numperiod  =  b_index_dtemthpay||b_index_numperiod  then -- หรือ เป็นงวดที่กำลังคำนวณ
                         v_device := v_device + 1 ;
                     end if;
                  elsif prd.dteend  > temploy1_dteempmt   then
                     v_device := v_device + 1 ;
                  end if;
              end loop;
       else --พิงประเมินแบบ + สะสม + เดือนที่เหลือ
              v_amtesti := 0 ;
              v_cnt2    := 0 ;
              v_device  := 1 ;
              if  temploy1_dteeffex is null   then
                  for prd in 1..v_numprd loop
                    if  r_tdtepay(prd).dtemthpay  >  b_index_dtemthpay  then
                        v_amtesti :=  v_amtesti + (b_var_amtcal / b_var_mqtypay) ;
                        v_device  := v_device  +  1 ;
                    elsif  r_tdtepay(prd).dtemthpay  =  b_index_dtemthpay and r_tdtepay(prd).numperiod > b_index_numperiod    then
                        v_amtesti :=  v_amtesti + (b_var_amtcal / b_var_mqtypay) ;
                        v_device  := v_device  +  1 ;
                    end if;
                  end loop;
              else
                   for prd in 1..v_numprd loop
                     select count(codempid) into v_cnt
                     from  ttaxcur
                     where codempid  = temploy1_codempid
                     and   dteyrepay = b_index_dteyrepay - v_zyear
                     and   dtemthpay = r_tdtepay(prd).dtemthpay
                     and   numperiod = r_tdtepay(prd).numperiod ;
                     if    temploy1_dteempmt <  r_tdtepay(prd).dteend then
                         if  v_cnt = 0  then
                           if  temploy1_dteeffex   between  r_tdtepay(prd).dtestrt+1   and  r_tdtepay(prd).dteend+1  or
                               temploy1_dteeffex  <=   r_tdtepay(prd).dtestrt then
                               null ;
                               if b_index_flag = 'N' then exit; end if;
                           else -- temploy1_dteeffex is null then
                              v_amtesti :=  v_amtesti + (b_var_amtcal / b_var_mqtypay) ;
                              v_device  :=  v_device  +  1 ;
                           end if;
                         end if;
                     end if;
                  end loop;

                  ---
              end if;
              v_device_ex := 0 ;
              for prd in c_tdtepay loop
                  if temploy1_dteempmt between  (prd.dtestrt+1)  and prd.dteend    then
                     select count(codempid) into v_cnt
                     from  ttaxcur
                     where codempid  = temploy1_codempid
                     and   dteyrepay = b_index_dteyrepay - v_zyear
                     and   dtemthpay = prd.dtemthpay
                     and   numperiod = prd.numperiod ;
                     if ( v_cnt > 0  and prd.dtemthpay||prd.numperiod  <>  b_index_dtemthpay||b_index_numperiod ) or
                          prd.dtemthpay||prd.numperiod  =  b_index_dtemthpay||b_index_numperiod  then
                         v_device_ex := v_device_ex + 1 ;
                     end if;
                  elsif prd.dteend  > temploy1_dteempmt   then
                     v_device_ex := v_device_ex + 1 ; -- นับจำนวนงวดที่ทำงานจริงในปี
                  end if;
              end loop;

        end if;
      end if;
  end if;
    v_flgamtcal := 'Y' ;
    if (c_amtcal + c_amtincl + c_amtincc) - (c_amtexpl + c_amtexpc ) <= 0 then -- (รายได้ประจำ + รายได้อื่นๆประจำ + รายได้อื่นๆคำนวณภาษี) - (ส่วนหักประจำ + ส่วนหักอื่นๆ)
        v_flgamtcal := 'N' ;
    end if;
	--- ภาษีสะสม
	v_acctaxt  := nvl(temploy3_amttaxbf,0) + nvl(stddec(rt_ttaxmas.amttaxt,temploy1_codempid,v_chken),0);
	if temploy3_typtax = '2' and temploy1_stamarry = 'M' then -- รวมยื่นและสมรส
		v_acctaxt := v_acctaxt + nvl(temploy3_amttaxsp,0); -- ภาษีสะสม + ภาษียกมาของคู่สมรส
	end if;
--msg_err('งวดสุดท้าย  =>  '||b_var_flglast);
--msg_err('ภาษีสะสม => v_acctaxt = '||v_acctaxt);
--msg_err('รายได้งวดนี้  => v_amtcal = '||v_amtcal);
--msg_err('รายได้ประจำพึงประเมิน => v_amtesti = '||v_amtesti);
--msg_err('rt_ttaxmas.amtexplt = '||nvl(stddec(rt_ttaxmas.amtexplt,temploy1_codempid,v_chken),0));
--msg_err('rt_ttaxmas.amtexpct = '||nvl(stddec(rt_ttaxmas.amtexpct,temploy1_codempid,v_chken),0));
--msg_err('declare_var_v_amtdedfix  = '||declare_var_v_amtdedfix);
--msg_err (' declare_var_forecast_othfix '||declare_var_forecast_othfix) ;
--msg_err (' v_amtesti '||v_amtesti) ;
-- ((ถ้าไม่ใช่งวดสุดท้ายของปี) หรือ codapp = 'HRPY44B') and ไม่ได้ลาออกงวดนี้
    if ((b_var_flglast = 'N') or  p_codapp = 'HRPY44B') and  b_var_staemp <>  '5'   then
        -- รายได้ประจำ
        if  nvl(tcontrpy_typesitm,'1') = '2' then--พิงประเมินแบบ x 12 เดือน
            v_amtinc := nvl(v_amtesti,0)
                        + (nvl(temploy3_amtincbf,0)  									                  -- เงินได้สะสมยกมา
                        + nvl(stddec(rt_ttaxmas.amtinclt,temploy1_codempid,v_chken),0)  -- รายได้อื่นประจำ
                        + declare_var_forecast_othfix                                   -- รายได้อื่นประจำพึงประเมิน
                        - nvl(stddec(rt_ttaxmas.amtexplt,temploy1_codempid,v_chken),0)  -- ส่วนหักประจำ
                        - nvl(stddec(rt_ttaxmas.amtexpct,temploy1_codempid,v_chken),0)  -- ส่วนหักอื่นๆคำนวณภาษี
                        - declare_var_v_amtdedfix                                       -- ส่วนหักประจำคำนวณภาษีกำหนดระยะเวลาจ่าย
                        + v_amtcal );               	                                  -- เงินได้ประจำงวดนี้

         else
             v_amtinc := nvl(v_amtesti,0)
                        + (nvl(temploy3_amtincbf,0)  									                    -- เงินได้สะสมยกมา
                        + nvl(stddec(rt_ttaxmas.amtcalt,temploy1_codempid,v_chken),0)     -- รายได้ประจำ
                        + nvl(stddec(rt_ttaxmas.amtinclt,temploy1_codempid,v_chken),0)    -- รายได้อื่นประจำสะสม
                        + declare_var_forecast_othfix                                     -- รายได้อื่นประจำพึงประเมิน
                        - nvl(stddec(rt_ttaxmas.amtexplt,temploy1_codempid,v_chken),0)    -- ส่วนหักประจำ
                        - nvl(stddec(rt_ttaxmas.amtexpct,temploy1_codempid,v_chken),0)    -- ส่วนหักอื่นๆคำนวณภาษี
                        + v_amtcal ); 		                                                -- เงินได้ประจำงวดนี้
         end if;
    else -- b_var_flglast = 'Y'  เดือนสุดท้าย
        -- รายได้ประจำ
        v_amtinc := nvl(v_amtesti,0) -- v_amtesti = 0
                    + (nvl(temploy3_amtincbf,0)  									                    -- เงินได้สะสมยกมา
                    + nvl(stddec(rt_ttaxmas.amtcalt,temploy1_codempid,v_chken),0)     -- รายได้ประจำ
                    + nvl(stddec(rt_ttaxmas.amtinclt,temploy1_codempid,v_chken),0)    -- รายได้อื่นประจำ
                    - nvl(stddec(rt_ttaxmas.amtexplt,temploy1_codempid,v_chken),0)    -- ส่วนหักประจำ
                    - nvl(stddec(rt_ttaxmas.amtexpct,temploy1_codempid,v_chken),0)    -- ส่วนหักอื่นๆคำนวณภาษี
                    + v_amtcal ); 		                                                -- เงินได้ประจำงวดนี้

    end if;
--msg_err('รายได้ประจำทั้งปี  v_amtinc = '||v_amtinc );
    if temploy3_typtax = '2' and temploy1_stamarry = 'M' then  -- รวมยื่นและสมรส
        v_amtinc := v_amtinc + nvl(temploy3_amtincsp,0);
    end if;
    v_amtinc   := greatest(v_amtinc,0);

    -- บวกรายได้อื่นๆชั่วคราวมีคู่ภาษี
    for i in 1..i4 loop
        v_othinc   := v_othinc +  v_amtcal4(i);
        v_amtothe  := v_amtothe + v_amtcal4(i); -- รายได้อื่นๆคำนวณภาษีหัก ณ ที่จ่าย
    end loop;
    for i in 1..i5 loop
        v_othinc   := v_othinc +  v_amtcal5(i);
        v_amtothc  := v_amtothc + v_amtcal5(i); -- รายได้อื่นๆคำนวณภาษีบริษัทออกให้
    end loop;
    for i in 1..i6 loop
        v_othinc   := v_othinc +  v_amtcal6(i);
        v_amtotho  := v_amtotho + v_amtcal6(i); -- รายได้อื่นๆคำนวณภาษีบริษัทออกให้ครั้งเดียว
    end loop;

    -- เงินได้อื่นๆทั้งปี
    for i in 1..declare_var_it4 loop
        v_othinc4 := v_othinc4 + declare_var_tempinc_amt4(i) ;
    end loop;
    for i in 1..declare_var_it5 loop
        v_othinc5 := v_othinc5 + declare_var_tempinc_amt5(i) ;
    end loop;
    for i in 1..declare_var_it6 loop
        v_othinc6 := v_othinc6 + declare_var_tempinc_amt6(i) ;
    end loop;

  -- รายได้อื่นๆทั้งปี

--msg_err('รายได้อื่นๆมีคู่ภาษี (งวดนี้) v_amtothe = '||v_amtothe||'# v_amtothc = '||v_amtothc||'# v_amtotho = '||v_amtotho );
--msg_err('รายได้อื่นๆกำหนดระยะเวลามีคู่ภาษี (งวดนี้) v_amtothfixe = '||v_amtothfixe||'# v_amtothfixc = '||v_amtothfixc||'# v_amtothfixo = '||v_amtothfixo );
--msg_err('รายได้อื่นๆกำหนดระยะเวลา * เดือนที่เหลือ  v_othinc4 = '||v_othinc4||'# v_othinc5 = '||v_othinc5||'# v_othinc6 = '||v_othinc6 );
--msg_err('เงินได้อื่นแบบหัก ณ ที่จ่าย สะสม  nvl(stddec(rt_ttaxmas.amtothe,temploy1_codempid,v_chken),0) = '||nvl(stddec(rt_ttaxmas.amtothe,temploy1_codempid,v_chken),0) );
--msg_err('เงินได้อื่นแบบ บ.ออกให้ สะสม   nvl(stddec(rt_ttaxmas.amtothc,temploy1_codempid,v_chken),0) = '||nvl(stddec(rt_ttaxmas.amtothc,temploy1_codempid,v_chken),0) );
--msg_err('เงินได้อื่นแบบ บ.ออกให้ครั้งเดียว สะสม  nvl(stddec(rt_ttaxmas.amtotho,temploy1_codempid,v_chken),0) = '||nvl(stddec(rt_ttaxmas.amtotho,temploy1_codempid,v_chken),0) );

    v_othinc := v_amtothe + v_amtothc + v_amtotho +                               -- รายได้อื่นๆมีคู่ภาษี (งวดนี้)
                v_othinc4 + v_othinc5 + v_othinc6 +                               -- รายได้อื่นๆกำหนดระยะเวลา * เดือนที่เหลือ
                v_amtcal1 + v_amtcal2 + v_amtcal3 +                               -- รายได้อื่นๆไม่มีคู่ภาษีงวดนี้
                v_amtothfixe + v_amtothfixc + v_amtothfixo +                      -- รายได้อื่นๆกำหนดระยะเวลามีคู่ภาษี (งวดนี้)
                nvl(stddec(rt_ttaxmas.amtothe,temploy1_codempid,v_chken),0)  +    -- เงินได้อื่นแบบหัก ณ ที่จ่าย สะสม
                nvl(stddec(rt_ttaxmas.amtothc,temploy1_codempid,v_chken),0)  +    -- เงินได้อื่นแบบ บ.ออกให้ สะสม
                nvl(stddec(rt_ttaxmas.amtotho,temploy1_codempid,v_chken),0)  ;    -- เงินได้อื่นแบบ บ.ออกให้ครั้งเดียว สะสม

  --v_amtsumded := nvl(v_amtded,0) + nvl(stddec(rt_ttaxmas.amtexpct,temploy1_codempid,v_chken),0) ;

    v_amtsalyr  := v_amtinc  +  v_othinc ;                         -- รายได้รวมทั้งปี = รายได้ประจำ + รายได้อื่นๆทั้งปี - ส่วนหัก

/*
msg_err('# รายได้ประจำพึงประเมินทั้งปี v_amtinc   => '|| v_amtinc);
msg_err('# เงินได้อื่นๆพึงประเมินทั้งปี v_othinc = '||v_othinc);
msg_err('# เงินได้พึงประเมินทั้งปี v_amtsalyr = '||v_amtsalyr);
*/
    -- v_round := 1;
    -- คำนวณภาษีรายได้ประจำครั้งที่ # 1
    if temploy3_typincom in ('3','4','5') then --กรณีประเภทเงินได้(3-แบบหักภาษี ณ ที่จ่าย 3%, 4-แบบหักภาษี ณ ที่จ่าย 5%5-แบบหักภาษี ณ ที่จ่าย 15%) ไม่ต้องคิดลดหย่อนต่างๆ
        --v_amtnet := v_amtinc;
        v_amtnet := v_amtcal ; --+ v_amtothe + v_amtothc + v_amtotho ;
    else
        cal_amtnet(v_amtinc,v_amtsalyr,v_amtproyr,v_amtsocyr,v_amtnet);
    end if;
    cal_amttax(v_amtnet,'1',0,0,v_taxa);
    --msg_err('### คำนวณภาษีรายได้ประจำครั้งที่ # 1 รายได้ประจำ = '||v_amtinc||' -> หักลดหย่อนเหลือ  = '||v_amtnet   ||' ภาษีรายได้ประจำ (v_taxa) = '||v_taxa);
    if temploy3_flgtax = '1' then -- หัก ณ. ที่จ่าย
        m_amtgrstxt := m_amtgrstxt + v_amtgrstx; -- v_amtgrstx ภาษีบริษัทออกให้
    elsif temploy3_flgtax = '2' then -- บ.ออกให้
        if nvl(temploy3_amtincbf,0) > 0 then
            v_amttaxcbf := ((temploy3_amtincbf/v_amtinc) * v_taxa ) ; -- prorate ภาษีรายได้ยกมา
            v_tax       := v_taxa - v_amttaxcbf ;
        else
            v_tax       := v_taxa;
        end if;
        cal_amttax(v_amtnet,'2',v_tax,0,v_taxa); --- สำหรับ บริษัทออกให้หาภาษีอีกครั้ง
		    v_amtsalyr 	:= v_amtsalyr + v_taxa ;
--msg_err('สำหรับ บริษัทออกให้ หาภาษีอีกครั้ง  v_amtnet  => '||v_amtnet||' v_taxa = '||v_tax ||' v_taxa(ครั้งที่ 2) = '||v_taxa);
--msg_err('v_amtsalyr = v_amtsalyr + v_taxa   => '||v_amtsalyr);
        m_amtgrstxt := v_taxa ;
	elsif temploy3_flgtax = '3' then -- บ.ออกให้ครั้งเดียว
        if nvl(temploy3_amtincbf,0) > 0 then
            v_amttaxcbf := ((temploy3_amtincbf/v_amtinc) * v_taxa ) ;
            v_tax       := v_taxa - v_amttaxcbf ;
        else
            v_tax       := v_taxa;
        end if;
        v_amtsalyr 	  := v_amtsalyr + v_tax; -- รายได้ทั้งปี + ภาษีบริษัทออกให้ครั้งเดียว
        v_amtnet      := v_amtnet + v_tax;
        m_amtgrstxt   := v_tax ;
        m_amtgrstxt_1 := (v_tax / v_device) ;
        cal_amttax(v_amtnet,'1',0,0,v_taxa);	--- หาภาษ๊อีกครั้ง
	end if;
    --<<หาภาษีรายได้อื่นๆสะสม งวดสุดท้าย   หรือ ลาออก
    --if b_var_flglast = 'Y'  or ( b_var_stacal = '2' )  or (temploy1_dteeffex = b_var_dteend + 1) then
    select nvl(sum(stddec(amtpay,codempid,v_chken)),0) into v_sumtaxe
      from tsincexp a
	   where codempid  = temploy1_codempid
       and dteyrepay = (b_index_dteyrepay - v_zyear )
       and (a.codpay in (select c.codtax
                           from tinexinf b,ttaxtab c
                          where b.typpay in ('2','3')
                            and b.flgtax = '1'
                            and b.flgcal = 'Y'
                            and b.codpay = c.codpay ) or (a.codpay = tcontrpy_codpaypy10)) ;

    select nvl(sum(stddec(amtpay,codempid,v_chken)),0) into v_sumtaxc
      from tsincexp a
     where codempid  = temploy1_codempid
       and dteyrepay = (b_index_dteyrepay - v_zyear )
       and a.codpay in (select c.codtax
                          from tinexinf b,ttaxtab c
                         where b.typpay in ('2','3')
                           and b.flgtax = '2'
                           and b.flgcal = 'Y'
                           and b.codpay = c.codpay ) ;

    select nvl(sum(stddec(amtpay,codempid,v_chken)),0) into v_sumtaxo
      from tsincexp a
     where codempid  = temploy1_codempid
       and dteyrepay = (b_index_dteyrepay - v_zyear )
       and a.codpay in (select c.codtax
                          from tinexinf b,ttaxtab c
                         where b.typpay in ('2','3')
                           and b.flgtax = '3'
                           and b.flgcal = 'Y'
                           and b.codpay = c.codpay ) ;
  --end if;
    -->>หาภาษีรายได้อื่นๆสะสม งวดสุดท้าย   หรือ ลาออก
    -- หาภาษีรายได้ทั้งปีครั้งที่ # 2
    if temploy3_typincom in ('3','4','5') then--กรณีประเภทเงินได้(3-แบบหักภาษี ณ ที่จ่าย 3%, 4-แบบหักภาษี ณ ที่จ่าย 5%,5-แบบหักภาษี ณ ที่จ่าย 15%) ไม่ต้องคิดลดหย่อนต่างๆ
        v_amtnet := v_amtcal + v_amtothe + v_amtothc + v_amtotho;
    else
        cal_amtnet(v_amtsalyr,v_amtsalyr,v_amtproyr,v_amtsocyr,v_amtnet);
    end if;

    cal_amttax(v_amtnet,'1',0,0,v_sumtax);

--msg_err('### คำนวณภาษีรายได้ทั้งปีครั้งที่ # 2  รายได้ทั้งปี v_amtsalyr = '||v_amtsalyr ||'  หักลดหย่อนเหลือ = '||v_amtnet||' ภาษีทั้งปี  (v_sumtax) = '||v_sumtax  );
    -- ภาษีหัก ณ. ที่จ่ายรายได้อื่นๆ ในงวดนี้
    v_amttaxyr := v_taxa + nvl(v_amttaxcbf,0) ;
    -- v_taxa = ภาษีรายได้ประจำ
    -- v_taxcurr = ภาษีรายได้อื่นๆ
    v_taxcurr  := (v_sumtax - nvl(v_taxa,0) - nvl(v_amttaxcbf,0));
    v_taxcurr  := greatest(v_taxcurr,0);
    if v_othinc = 0 then
        v_othinc := 1 ;
    end if;
--msg_err('### ภาษีรายได้อื่นๆ (v_taxcurr)  = ภาษีทั้งปี (v_sumtax)- ภาษีรายได้ประจำ (v_taxa) = '||v_taxcurr);
	-- หาสัดส่วนภาษีอื่นๆ ของแต่ละตัว
    if v_amtcal1 <> 0 then -- รายได้อื่นๆไม่มีคู่ภาษีแบบหัก ณ ที่จ่าย comment 28/04/2022 By S ไม่มีการคำนวณมาตั้งแต่แรก
        v_tax1 := v_amtcal1 * v_taxcurr / v_othinc;
        v_amttaxyr := v_amttaxyr + v_tax1;
    end if;
	-- ถ้าเป็นแบบ บริษัทออกให้ หาภาษีอีกครั้ง
	if v_amtcal2 <> 0 then -- รายได้อื่นๆไม่มีคู่ภาษีแบบบริษัทออกให้ ==> ไม่น่าจะถูกรายได้อื่นๆ ต้องมีคุ่ภาษีทุกตัว
		v_tax2 			:= v_amtcal2 * v_taxcurr / v_othinc;
		v_tax 			:= v_tax2;
		cal_amttax(v_amtnet,'2',v_tax,v_amttaxyr,v_tax2);
		v_taxgrs2 	:= v_tax2;
		v_amtsalyr 	:= v_amtsalyr + v_taxgrs2;
		v_amttaxyr  := v_amttaxyr + v_tax2;
	end if;
  -- ถ้าเป็นแบบบริษัทออกให้ครั้งเดียว หาภาษ๊อีกครั้ง
	if v_amtcal3 <> 0 then -- รายได้อื่นๆไม่มีคู่ภาษีแบบบริษัทออกให้ครั้งเดียว ==> ไม่น่าจะถูกรายได้อื่นๆ ต้องมีคุ่ภาษีทุกตัว
		v_tax 			:= v_amtcal3 * v_taxcurr / v_othinc;
		v_taxgrs3 	:= v_tax;
		v_amtsalyr 	:= v_amtsalyr + v_tax;
		v_amtnet 		:= v_amtnet + v_tax;
		cal_amttax(v_amtnet,'1',0,0,v_amttax);
		v_tax3 			:= v_amttax - v_amttaxyr;
		v_amttaxyr  := v_amttax;
	end if;

/*
  msg_err('# v_amttaxyr = '||v_amttaxyr);
  -- หาภาษีสำหรับรายได้ที่มีคู่ภาษี สำหรับแบบหัก ณ ที่จ่าย
  msg_err('#I4- v_amtothe ='||v_amtothe ); -- รายได้อื่นๆคำนวณภาษีหัก ณ ที่จ่าย
  msg_err('#I4- v_amtothfixe ='||v_amtothfixe );
  msg_err('รายได้อื่นๆกำหนดระยะเวลาจ่าย หัก ณ ที่จ่าย forecast ='||declare_var_forecast4 );
  msg_err('รายได้อื่นๆกำหนดระยะเวลาจ่าย บ.ออกให้ forecast ='||declare_var_forecast5 );
  msg_err('รายได้อื่นๆกำหนดระยะเวลาจ่าย บ.ออกให้ครั้งเดียว forecast ='||declare_var_forecast6 );  	*/
  v_taxyeari4    :=  ((v_amtothe + v_othinc4 + v_amtothfixe + nvl(stddec(rt_ttaxmas.amtothe,temploy1_codempid,v_chken),0)) / v_othinc) * v_taxcurr ;
  v_taxforcasti4 :=  (declare_var_forecast4/ v_othinc) * v_taxcurr ;
  if v_amtothe > 0 then
      for i in 1..i4 loop
        v_tax4(i) 	:= (v_amtcal4(i) / v_othinc )* v_taxcurr ;
        v_amttaxyr 	:= v_amttaxyr + v_tax4(i);
        v_sumcali4  := v_sumcali4 + nvl(v_amtcal4(i),0);
      end loop;
  end if;
  -- หาภาษีสำหรับรายได้กำหนดระยะเวลาจ่ายที่มีคู่ภาษี สำหรับแบบหัก ณ ที่จ่าย
  if v_amtothfixe > 0 then  -- รายได้อื่นกำหนดระยะเวลจ่าย แบบหัก ณ ที่จ่าย (เดือนนี้)
    for i in 1..it4 loop
      v_taxtinc4(i) 	:= v_tempinc4(i) * v_taxcurr / v_othinc;
      v_amttaxyr 	    := v_amttaxyr + v_taxtinc4(i);
      v_sumcali4      := v_sumcali4 + nvl(v_tempinc4(i),0);
    end loop;
  end if;

  if v_othinc > 0 then
     v_amttaxyr 	:= v_amttaxyr + (( nvl(stddec(rt_ttaxmas.amtothe,temploy1_codempid,v_chken),0) + v_othinc4) * v_taxcurr / v_othinc);
  end if;

  -- หารายได้สำหรับรายได้ที่มีคู่ภาษี สำหรับแบบ บริษัทออกให้ทั้งหมด
  for i in 1..i5 loop -- รายได้อื่นๆ มีคู่ภาษี
      v_sumcali5 := v_sumcali5 + nvl(v_amtcal5(i),0);
  end loop;
  for i in 1..it5 loop -- รายได้กำหนดระยะเวลาจ่าย
      v_sumcali5 := v_sumcali5 + nvl(v_tempinc5(i),0);
  end loop;

  -- หาภาษีสำหรับรายได้ที่มีคู่ภาษี สำหรับแบบ บริษัทออกให้
	-- if v_sumcali5 <> 0 then
  -- ภาษีเงินได้ทุกตัวบริษัทออกให้
  for i in 1..i5 loop
    v_tax5(i) 		:= v_amtcal5(i) * v_taxcurr / v_othinc;
    v_taxgrs5(i)  := v_tax5(i) ;
    v_taxsumcali5 := v_taxsumcali5 + v_tax5(i) ;
  end loop;
  for i in 1..it5 loop
    v_taxtinc5(i)    := v_tempinc5(i) * v_taxcurr / v_othinc;
    v_taxtempgrs5(i) := v_taxtinc5(i) ;
    v_taxsumcali5    := v_taxsumcali5 + v_taxtinc5(i) ;
  end loop;

  v_sumtax5     := v_taxsumcali5 + ((nvl(stddec(rt_ttaxmas.amtothc,temploy1_codempid,v_chken),0) + v_othinc5 ) *  v_taxcurr / v_othinc) ;
  -- v_sumtax5
  if v_sumtax5 > 0 then
    cal_amttax(v_amtnet,'2',v_sumtax5,v_amttaxyr,v_taxtotalcali5);
    --msg_err('คำนวณภาษีรายได้อื่นๆ บ. อออกให้ ยอด = '||v_sumtax5 || ' ภาษี  = '||v_taxtotalcali5);
    v_amttaxyr 		  := v_amttaxyr + v_taxtotalcali5;
		v_amtsalyr 		  := v_amtsalyr + v_taxtotalcali5;
    m_amtgrstxt     := m_amtgrstxt + v_taxtotalcali5;
    v_taxyeari5     := v_taxtotalcali5 ;
    --msg_err('#ภาษีทั้งปี => '||v_amttaxyr );
    --msg_err('#รายได้ทั้งปี + ภาษี บ.ออกให้ => '||v_amtsalyr );
    v_sum5          := v_sumcali5 + nvl(stddec(rt_ttaxmas.amtothc,temploy1_codempid,v_chken),0) + v_othinc5 ;
    if  b_var_flglast = 'Y' or (b_var_stacal = '2'   or (temploy1_dteeffex = b_var_dteend + 1))     then
        for i in 1..i5 loop
          v_tax5(i) 		:= v_amtcal5(i) * ((v_taxtotalcali5 - nvl(v_sumtaxc,0)) / v_sumcali5 ) ;
          v_taxgrs5(i)  := v_tax5(i) ;
          --msg_err('#I5 -ภาษีสำหรับรายได้อื่นๆ บริษัทออกให้ ('||v_codpay5(i)||') '||v_amtcal5(i)||' Tax = '||v_tax5(i) );
        end loop;

        for i in 1..it5 loop
          v_taxtinc5(i) := v_tempinc5(i) * ((v_taxtotalcali5 - nvl(v_sumtaxc,0)) / v_sumcali5 ) ;
          v_taxtempgrs5(i)  := v_taxtinc5(i) ;
          --msg_err('#IT5 -ภาษีสำหรับรายได้กำหนดระยะเวลาจ่ายที่มีคู่ภาษี สำหรับ บริษัทออกให้ ('||v_codpayinc5(i)||') '||v_tempinc5(i)||' Tax = '||v_taxtinc5(i) );
        end loop;
  	else
        for i in 1..i5 loop
          v_tax5(i) 		:= v_amtcal5(i) * v_taxtotalcali5 / v_sum5;
          v_taxgrs5(i)  := v_tax5(i) ;
          --msg_err('#I5 -ภาษีสำหรับรายได้อื่นๆ บริษัทออกให้ ('||v_codpay5(i)||') '||v_amtcal5(i)||' Tax = '||v_tax5(i) );
        end loop;
        v_taxforcasti5 := declare_var_forecast5 * v_taxtotalcali5 / v_sum5;
        for i in 1..it5 loop
          v_taxtinc5(i) := v_tempinc5(i) * v_taxtotalcali5 / v_sum5;
          v_taxtempgrs5(i)  := v_taxtinc5(i) ;
          --msg_err('#IT5  -หาภาษีสำหรับรายได้กำหนดระยะเวลาจ่ายที่มีคู่ภาษี สำหรับ บริษัทออกให้ ('||v_codpayinc5(i)||') '||v_tempinc5(i)||' Tax = '||v_taxtinc5(i) );
        end loop;
     end if;
     v_amtnet      := v_amtnet + v_taxtotalcali5  ;
  end if;
  ------------------------------------------------------------------------------
  --- I6 หาภาษีสำหรับรายได้ที่มีคู่ภาษี สำหรับแบบบริษัทออกให้ครั้งเดียว
  ------------------------------------------------------------------------------
    for i in 1..i6 loop
        v_sumcali6   := v_sumcali6 + nvl(v_amtcal6(i),0);
    end loop;
    for i in 1..it6 loop
        v_sumcali6 := v_sumcali6 + nvl(v_tempinc6(i),0);
    end loop;

	--if v_sumcali6 <> 0 then
    for i in 1..i6 loop
        v_tax6(i) 	  := v_amtcal6(i) * v_taxcurr / v_othinc;
        v_taxgrs6(i)  := v_tax6(i) ;
        v_taxsumcali6 := v_taxsumcali6 + v_tax6(i) ;
      --msg_err('#I6-หาภาษีสำหรับรายได้อื่นๆที่มีคู่ภาษีสำหรับ บริษัทออกให้ครั้งเดียว ('||v_codpay6(i)||') '||v_amtcal6(i)||' = '||v_tax6(i) );
    end loop;
    for i in 1..it6 loop
        v_taxtinc6(i)	 := v_tempinc6(i) * v_taxcurr / v_othinc;
        v_taxtempgrs6(i) := v_taxtinc6(i) ;
        v_taxsumcali6    := v_taxsumcali6 + v_taxtinc6(i) ;
    end loop;

    v_sumtax6     := v_taxsumcali6 +  ((nvl(stddec(rt_ttaxmas.amtotho,temploy1_codempid,v_chken),0)+ v_othinc6)  *  v_taxcurr / v_othinc) ;

  if  v_sumtax6 > 0   then
    v_amtnet      := v_amtnet + v_sumtax6  ;
    m_amtgrstxt   := m_amtgrstxt + v_sumtax6;
    cal_amttax(v_amtnet,'1',0,0,v_taxcali6);
    v_taxcali6    := v_taxcali6 - v_amttaxyr;
    v_amttaxyr 		:= v_amttaxyr + v_taxcali6 ;
    v_amtsalyr 		:= v_amtsalyr + v_sumtax6 ;
    v_sum6        := v_sumcali6 + nvl(stddec(rt_ttaxmas.amtotho,temploy1_codempid,v_chken),0) + v_othinc6 ;
    --msg_err('#ภาษีบ.ออกให้ครั้งเดียวรวมทั้งปี    =  '||v_taxcali6 );
    v_taxforcasti6 := declare_var_forecast6 * v_taxcali6 / v_sum6;
    v_taxyeari6    := v_taxcali6 ;
		for i in 1..i6 loop
			v_tax6(i) 		:= v_amtcal6(i) * v_taxcali6 / v_sum6;
		end loop;
        for i in 1..it6 loop
            v_taxtinc6(i) 		:= v_tempinc6(i) * v_taxcali6 / v_sum6;
          --msg_err('#I6-หาภาษีสำหรับรายได้กำหนดระยะเวลาจ่ายที่มีคู่ภาษี สำหรับ บริษัทออกให้ครั้งเดียว ('||v_codpayinc6(i)||') '||v_tempinc6(i)||' = '||v_taxtinc6(i) );
        end loop;
	end if;

  --end if;
  --msg_err('# ตรวจสอบถ้าภาษีทั้งปีที่คำนวณได้ มากกว่า ภาษีสะสม  if v_amttaxyr > v_acctaxt then  '||v_amttaxyr || '> '||v_acctaxt  );
  ------------------------------------------------------------------------------
  -- ตรวจสอบถ้าภาษีที่หาได้ > ภาษีสะสม หาภาษีเงินได้อื่นๆในงวดนี้,ภาษีเงินได้อื่นๆบริษัทออกให้ในงวดนี้
  -- c_amttax   = ภาษีเงินได้อื่นๆในงวดนี้
  -- c_amtgrstx = ภาษีเงินได้อื่นๆบริษัทออกให้ในงวดนี้
  ------------------------------------------------------------------------------
---msg_err('รายได้พึงประเมิรทั้งปี (+ภาษี บ.ออกให้แล้ว )  '||v_amtsalyr );
  chk_amttax :=  0 ;


--msg_err('# v_amttaxyr = '||v_amttaxyr);
--msg_err('# v_acctaxt = '||v_acctaxt);

  if v_amttaxyr > v_acctaxt or temploy3_typincom in ('3','4','5') then
    --<< Cal chk_amttax
    for i in 1..i6 loop
        v_tax     := v_tax6(i);
        v_sumtax6 := v_sumtax6 + v_tax ;
        round_up_amt(v_codpay6(i),v_tax) ;
        chk_amttax 		:= chk_amttax + v_tax;
    end loop;
    for i in 1..it6 loop
        v_tax     := v_taxtinc6(i);
        v_sumtax6 := v_sumtax6 + v_tax ;
        round_up_amt(v_codpayinc6(i),v_tax) ;
        chk_amttax 		:= chk_amttax + v_tax;
    end loop;
    for i in 1..i5 loop
        v_tax := v_tax5(i);
        v_sumtax5 := v_sumtax5 + v_tax ;
        round_up_amt(v_codpay5(i),v_tax) ;
        chk_amttax 		:= chk_amttax + v_tax;
    end loop;
    for i in 1..it5 loop
        v_tax     := v_taxtinc5(i);
        v_sumtax5 := v_sumtax5 + v_tax ;
        round_up_amt(v_codpayinc5(i),v_tax) ;
        chk_amttax 		:= chk_amttax + v_tax;
    end loop;
    for i in 1..i4 loop
        v_tax     := v_tax4(i);
        v_sumtax4 := v_sumtax4 + v_tax ;
        round_up_amt(v_codpay4(i),v_tax) ;
        chk_amttax := chk_amttax + v_tax;
    end loop;

    for i in 1..it4 loop
      v_tax := v_taxtinc4(i);
      v_sumtax4 := v_sumtax4 + v_tax ;
      round_up_amt(v_codpayinc4(i),v_tax) ;
      chk_amttax 		:= chk_amttax + v_tax;
    end loop;

    -->> Cal chk_amttax
    if (b_var_stacal = '4') or (b_var_stacal = '2') or (temploy1_dteeffex = b_var_dteend + 1) then
       --Prorate ลาออก
       if b_var_stacal = '2' then
          v_mthprorate  :=  (((b_var_dteend - temploy1_dteeffex )+ 1 ) / v_numday) ;
       end if;
       --v_baltax :=  v_amttaxyr - (( ((12-v_mthexit)+1+v_mthprorate) /12) * v_taxa) - v_acctaxt ;
       v_baltax   :=  v_amttaxyr - (( ((12-v_mthexit)+1+v_mthprorate) /v_device_ex) * v_taxa) - v_acctaxt ;
       v_amttaxyr :=  v_amttaxyr -   (( ((12-v_mthexit)+1+v_mthprorate) /v_device_ex) * v_taxa) ;
       --msg_err('# v_baltax = '||v_baltax );
    else
       v_baltax := v_amttaxyr - v_acctaxt ;
       --msg_err('ภาษีคงเหลือที่ต้องชำระ ='||v_baltax );
    end if;

    v_baltax := greatest(v_baltax,0);

     --msg_err('#ภาษีรายได้อื่นไเดือนนี้ chk_amttax = '||chk_amttax );
    --<<หาสัดส่วนใหม่กรณีที่ ภาษีเงินได้อื่นๆในงวด  > ภาษีที่ต้องจ่ายคงเหลือ
    --if  chk_amttax > 0 and chk_amttax > v_baltax then
    --if  ( chk_amttax > 0 and chk_amttax > v_baltax ) and b_var_flglast = 'Y'  then
    --if temploy3_typincom in ('3','4','5') then --กรณีประเภทเงินได้(3-แบบหักภาษี ณ ที่จ่าย 3%, 4-แบบหักภาษี ณ ที่จ่าย 5%5-แบบหักภาษี ณ ที่จ่าย 15%) ไม่ต้องคิดลดหย่อนต่างๆ
--msg_err('#  chk_amttax  = '||chk_amttax );
--msg_err('#  v_taxcurr  = '||v_taxcurr );
--msg_err('#  v_sumtaxe  = '||v_sumtaxe );

--<<user46 06/12/2021 ไม่ต้องหาสัดส่วนใหม่  ใช้ adjust ภาษีแทน
/*    if  chk_amttax > 0 and  (v_taxcurr - v_sumtaxe ) < chk_amttax  and temploy3_typincom not in ('3','4','5') then
        v_taxothlast := v_baltax ;
        if  (v_taxcurr - v_sumtaxe ) < chk_amttax then
            v_taxothlast := v_taxcurr - nvl(v_sumtaxe ,0) ;
        end if;
        if v_taxothlast < 0 then
            v_taxothlast := 0 ;
        end if;
        for i in 1..i6 loop
          v_tax6(i) := v_tax6(i) * (v_taxothlast/chk_amttax);
        end loop;
        for i in 1..it6 loop
          v_taxtinc6(i) := v_taxtinc6(i) * (v_taxothlast/chk_amttax);
        end loop;
        for i in 1..i5 loop
          v_tax5(i) := v_tax5(i) * (v_taxothlast/chk_amttax);
        end loop;
        for i in 1..it5 loop
          v_taxtinc5(i) := v_taxtinc5(i) * (v_taxothlast/chk_amttax);
        end loop;
        for i in 1..i4 loop
          v_tax4(i) := v_tax4(i) * (v_taxothlast/chk_amttax) ;
        end loop;
        for i in 1..it4 loop
          v_taxtinc4(i) := v_taxtinc4(i) * (v_taxothlast/chk_amttax) ;
        end loop;
    end if;*/
    -->>หาสัดส่วนใหม่กรณีที่ ภาษีเงินได้อื่นๆในงวด  > ภาษ๊ที่ต้องจ่ายคงเหลือ
--<<user46 06/12/2021

    for i in 1..i6 loop
        v_tax := v_tax6(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpay6(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true,v_tax);
                c_amttax 		:= c_amttax + v_tax;
                c_amtgrstx 	:= c_amtgrstx  + v_taxgrs6(i);
                m_amtgrstxt_1 := m_amtgrstxt_1 + v_taxgrs6(i);
                --m_amtgrstxt := m_amtgrstxt + v_taxgrs6(i);
                --c_amtcalc  := nvl(c_amtcalc,0) +  v_taxgrs6(i) ;
            end if;
        end loop;
    end loop;

    for i in 1..it6 loop
        v_tax := v_taxtinc6(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpayinc6(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true, v_taxtempgrs6(i));
                c_amttax 		  := c_amttax + v_tax;
                c_amtgrstx  	:= c_amtgrstx  + v_taxtempgrs6(i);
                m_amtgrstxt_1 := m_amtgrstxt_1 + v_taxtempgrs6(i);
            end if;
        end loop;
    end loop;

    for i in 1..i5 loop
        v_tax := v_tax5(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpay5(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true,v_tax);
                c_amttax 		:= c_amttax + v_tax;
                c_amtgrstx 	:= c_amtgrstx + v_tax;
                m_amtgrstxt_1 := m_amtgrstxt_1 + v_tax;
            end if;
        end loop;
    end loop;

    for i in 1..it5 loop
        v_tax := v_taxtinc5(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpayinc5(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true,v_tax);
                c_amttax 		:= c_amttax + v_tax;
                c_amtgrstx 	:= c_amtgrstx + v_tax;
                m_amtgrstxt_1 := m_amtgrstxt_1 + v_tax;
            end if;
        end loop;
    end loop;

    for i in 1..i4 loop
        v_tax := v_tax4(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpay4(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true,v_tax);
                c_amttax := c_amttax + v_tax;
            end if;
        end loop;
    end loop;
    for i in 1..it4 loop
        v_tax := v_taxtinc4(i);
        for j in 1..declare_var_v_max loop
            if declare_var_v_tab_codpay(j) = v_codpayinc4(i) then
                upd_tsincexp(declare_var_v_tab_codtax(j),'1',true,v_tax);
                c_amttax 		:= c_amttax + v_tax;
            end if;
        end loop;
    end loop;

		if p_codapp = 'HRPY41B' then
			--if v_othinc = 1 and (b_index_dtemthpay < 12 or v_amtesti <> 0 ) then
			--if b_index_dtemthpay < 12 or v_amtesti <> 0 ) then
       if  temploy3_typincom not in ('3','4','5') then
           begin
             select nvl(sum(stddec(amtpay,codempid,v_chken)),0) into v_taxsumfix
             from   tsincexp a
             where  codempid  = temploy1_codempid
             and    dteyrepay = (b_index_dteyrepay - v_zyear )
             and    dtemthpay|| numperiod <> b_index_dtemthpay||b_index_numperiod --- Readmine #1817 26/03/2024 Pratya
             and    codpay   =  tcontrpy_codpaypy1 ;
           exception when others then
             v_taxsumfix := 0 ;
           end ;
           v_taxsumfix :=   v_taxsumfix + nvl(temploy3_amttaxbf,0) ;
          if b_var_flglast = 'N' then --ไม่ใช่งวดสุดท้าย
             v_amttax := v_taxa ;         
             if  tcontrpy_typesitm = '1' then -- วิธีการพึงประเมิน 1 = แบบสะสม
                 v_amttax := v_amttax - nvl(v_taxsumfix,0) ; -- ภาษีรายได้ประจำ - ภาษีรายได้ประจำทั้งปี
             end if;
             if (b_var_stacal = '4') or (b_var_stacal = '2') or (temploy1_dteeffex = b_var_dteend + 1) then 
                 if  chk_amttax >  v_baltax then
                     v_amttax := 0 ;
                 else
                     v_amttax := v_baltax - chk_amttax ; 
                 end if;
             end if;

          else -- งวดสุดท้ายของปี 
            --v_amttax := v_amttaxyr - c_amttax - v_acctaxt;
            --v_amttax := v_amttaxyr - (c_amttax - v_amttaxadj) - v_acctaxt;
            v_amttax := v_amttaxyr - (c_amttax ) - v_acctaxt; -- ภาษีทั้งปี - (ภาษีรายได้อื่นๆ) - ภาษีสะสม 
          end if;
		  else
          v_amttax := v_taxa ;
      end if;
    else
      v_amttax := v_tax1 + v_tax2 + v_tax3;
    end if;

    if ( v_amttax > 0 or c_amttax  > 0 or v_amtesti <> 0 ) and v_flgamtcal = 'Y' then
      s_amtgrstx := c_amtgrstx;
			if p_codapp = 'HRPY41B' then
              if temploy3_typincom not in ('3','4','5') then
                if b_var_flglast = 'N' then

                   if (b_var_stacal = '4') or (b_var_stacal = '2') or (temploy1_dteeffex = b_var_dteend + 1) then --ลาออกกลางปี
                      v_taxprd   := v_amttax; -- ภาษีรายได้ประจำงวดนี้
                      if v_taxprd > ( v_taxa /  v_device_ex) then -- ภาษีรายได้ประจำงวดนี้ > (ภาษีรายได้ประจำ / จำนวนงวดทำงาน)
                         v_taxprd   := round(( v_taxa /  v_device_ex),2) ;
                         v_taxpayi4 := v_amttax - v_taxprd ;
                         if v_taxpayi4 > 0 then                                                 
                           --msg_err('# ภาษีรายได้อื่นๆค้างจ่ายเดือนนี้ =  '||v_taxpayi4);
                           upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
                           c_amttax := c_amttax + nvl(v_taxpayi4,0) ;  ---#1926 Pratya 23/04/2024
                         end if;
                      end if;
                   else -- ปกติ
                      v_taxprd   := (v_amttax / v_device);
                      if tcontrpy_typededtax in ('1','3') then -- วิธีการจ่ายสำหรับภาษีที่มีการปรับ 1 = เดือนปัจจุบัน, 3 = เฉลี่ยตามเดือน
                        v_taxpayi4  := nvl(v_taxyeari4,0) - nvl(v_taxforcasti4,0)  - nvl(v_sumtaxe,0) ;
                        v_taxpayi5  := nvl(v_taxyeari5,0) - nvl(v_taxforcasti5,0)  - nvl(v_sumtaxc,0) ;
                        v_taxpayi6  := nvl(v_taxyeari6,0) - nvl(v_taxforcasti6,0)  - nvl(v_sumtaxo,0);

                        if (v_taxpayi4 + v_taxpayi5 + v_taxpayi6) - c_amttax > 0 then -- ภาษีรายได้อื่นๆกำหนดระยะเวลาจ่าย > ภาษีรายได้อื่นๆที่ต้องจ่ายในงวดนี้
                           v_taxpayi4 :=  (v_taxpayi4 + v_taxpayi5 + v_taxpayi6) - c_amttax  ;
                          if v_taxpayi4 < 0 then
                             v_taxpayi4 := 0 ;
                          end if;
--<<user46 05/01/2022 Ref. NXP
--                           c_amttax := c_amttax + nvl(v_taxpayi4,0) ;
--                           upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
                          if tcontrpy_typededtax = '1' then -- ภาษีค้างจ่าย 1 = จ่ายเดือนนี้                         
--NMT-660032
                            if temploy3_flgtax = '1' then
                                upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
                            else
                                upd_tsincexp(tcontrpy_codpaypy11,'1',true,v_taxpayi4);
                            end if;
                            c_amttax    := c_amttax + nvl(v_taxpayi4,0) ;---#1926 Pratya 23/04/2024
--                            upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
--NMT-660032                          
                          elsif tcontrpy_typededtax = '3' then -- ภาษีค้างจ่าย 3 = เฉลี่ย
                            v_taxpayi4  := v_taxpayi4/b_var_balperd;                                                      
--NMT-660032
                            if temploy3_flgtax = '1' then
                                upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
                            else
                                upd_tsincexp(tcontrpy_codpaypy11,'1',true,v_taxpayi4);
                            end if;
                            c_amttax    := c_amttax + nvl(v_taxpayi4,0) ; ---#1926 Pratya 23/04/2024
--                            upd_tsincexp(tcontrpy_codpaypy10,'1',true,v_taxpayi4);
--NMT-660032                                     
                          end if;
-->>user46 05/01/2022 Ref. NXP

                           if v_taxpayi5 + v_taxpayi6 > 0  then
                              v_taxpayi5 := v_taxpayi5 + v_taxpayi6 - c_amttax;
                              if v_taxpayi5 < 0 then
                                 v_taxpayi5 := 0 ;
                              end if;                              
                              upd_tsincexp(tcontrpy_codpaypy4,'1',true,v_taxpayi5);
                              c_amttax := c_amttax + nvl(v_taxpayi5,0) ;---#1926 Pratya 23/04/2024
                           end if;
                        end if;
                       end if;
                       -->>user 02/02/2019
                   end if;
            else -- Last Period
               v_taxprd   := v_amttax ;
            end if;
        else
           v_taxprd   := v_taxa;
        end if;
        c_amtgrstx := c_amtgrstx + (v_taxgrs2 / v_device) + (v_taxgrs3 / v_device);
      else
            v_taxprd   := round(v_amttax,2);
            c_amtgrstx := c_amtgrstx + round(v_taxgrs2,2) + round(v_taxgrs3,2);
      end if;

        if v_taxprd > 0 then
            upd_tsincexp(tcontrpy_codpaypy1,'1',true,v_taxprd);
            c_amttax := c_amttax + v_taxprd;
            if temploy3_flgtax in ('2') then    -- ออกให้
                c_amtgrstx := c_amtgrstx + v_taxprd;
            elsif temploy3_flgtax in ('3') then -- ออกให้ครั้งเดียว
                c_amtgrstx := m_amtgrstxt_1 ;
            end if;
        end if;

    end if;

/*msg_err('### ภาษีที่หักทั้งหมดงวดนี้ ที่คำนวนได้ =  '||c_amttax);
msg_err('### ภาษีบริษัทออกให้  c_amtgrstx =  '||c_amtgrstx );
msg_err('### ภาษี Adjust รายได้ประจำ =  '||v_amttaxadj );
msg_err('### ภาษี Adjust รายได้อื่นๆ  =  '||v_amttaxadj_oth );*/

    if c_amtgrstx > 0 then
    	 upd_tsincexp(tcontrpy_codpaypy4,'1',true,c_amtgrstx);
		end if;
	end if; -- v_amttaxyr > v_acctaxt

  c_amtgrstx := c_amtgrstx + v_amtgrstxadj ;
  --v_amtsalyr := v_amtsalyr  + v_amtgrstxadj ; --19/02/2024
  c_amttax := greatest(c_amttax,0)  ;
--  v_net_ded := nvl(c_amtcal,0) + nvl(c_amtincc,0) + nvl(c_amtincl,0) + nvl(c_amtincn,0) ;
  c_amttax := c_amttax  + nvl(v_amttaxadj,0) + nvl(v_amttaxadj_oth,0) ; ---+ nvl(v_amttaxadj,0); 
  v_net_ded := nvl(c_amtcal,0) + nvl(c_amtincc,0) + nvl(c_amtincl,0) + nvl(c_amtincn,0) - (nvl(c_amtexpl,0) + nvl(c_amtexpc,0)) ; -->> user46 04/05/2022
--msg_err('### ภาษีที่หักทั้งหมดงวดนี้  =  '||c_amttax);
--insert into a(a) values(c_amttax); 
  if  v_maxded > 0  then
     for i in 1..v_maxded loop
        /*if std_tax.declare_var_dedinc(i) = tcontrpy_codpaypy12 then
           cal_Legalded(v_net_ded)   ;
        end if;*/

        if std_tax.declare_var_dedamt(i) > 0 then

            if v_net_ded - std_tax.declare_var_dedamt(i) < 0 then
            -- ถ้าเงินที่เหลือไม่พอให้หักก็ไม่ต้องหัก
              --if v_net_ded = 0 then
                 v_ded   := 0 ;
              --else
              --   v_ded   := v_net_ded ;
              --end if;
              if  v_ded < std_tax.declare_var_dedamt(i) then
                  insert into tothded (codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                       codcomp,typpayroll,amtpay,amtded,coduser )
                  values              (temploy1_codempid,b_index_dteyrepay - v_zyear,b_index_dtemthpay,b_index_numperiod,std_tax.declare_var_dedinc(i),
                                       temploy1_codcomp,temploy1_typpayroll,stdenc(std_tax.declare_var_dedamt(i),temploy1_codempid,v_chken) ,
                                       stdenc(v_ded,temploy1_codempid,v_chken) ,v_coduser ) ;
              end if;

              update tsincexp
              set amtpay      = stdenc(v_ded,codempid,v_chken),
                  amtpay_e    = stdenc(v_ded,codempid,v_chken)
              where codempid  = temploy1_codempid
              and	dteyrepay  = b_index_dteyrepay - v_zyear
              and	dtemthpay  = b_index_dtemthpay
              and	numperiod  = b_index_numperiod
              and	codpay     = std_tax.declare_var_dedinc(i)
              and flgslip    = '1';

              if  v_ded = 0 then
                  delete tsincexp
                  where codempid  = temploy1_codempid
                  and	dteyrepay  = b_index_dteyrepay - v_zyear
                  and	dtemthpay  = b_index_dtemthpay
                  and	numperiod  = b_index_numperiod
                  and	codpay     = std_tax.declare_var_dedinc(i)
                  and flgslip    = '1';
--<< user46 22/02/2022 nxp-hr2101 fix issue
                  if tcontrpy_codpaypy2 = v_codpay then
                      delete tsincexp
                       where codempid   = temploy1_codempid
                         and dteyrepay  = b_index_dteyrepay - v_zyear
                         and dtemthpay  = b_index_dtemthpay
                         and numperiod  = b_index_numperiod
                         and codpay     = tcontrpy_codpaypy6
                         and flgslip    = '1';
--<< user46 05/04/2022 nxp-hr2101
                    c_amtsoca   := 0;
                    c_amtsocc   := 0;
                    c_amtsoc    := 0;
-->> user46 05/04/2022 nxp-hr2101
                  end if;

                  if tcontrpy_codpaypy3 = v_codpay then
                      delete tsincexp
                       where codempid   = temploy1_codempid
                         and dteyrepay  = b_index_dteyrepay - v_zyear
                         and dtemthpay  = b_index_dtemthpay
                         and numperiod  = b_index_numperiod
                         and codpay     = tcontrpy_codpaypy7
                         and flgslip    = '1';
                  end if;
-->> user46 22/02/2022 nxp-hr2101 fix issue
              end if;
            end if;
            --v_net_ded := greatest(v_net_ded - std_tax.declare_var_dedamt(i),0) ;
            v_net_ded := greatest(v_net_ded - v_ded,0) ;
        end if;
     end loop;
    end if;

    v_net	:= nvl(c_amtcal,0)   + nvl(c_amtincc,0)  + nvl(c_amtincl,0) + nvl(c_amtincn,0) + nvl(c_amtgrstx,0) ;
             --- nvl(c_amtexpc,0)  - nvl(c_amtexpl,0) - nvl(c_amtexpn,0) -
             --nvl(c_amtsoca,0)  - nvl(c_amtprove,0) - nvl(c_amttax,0)  - nvl(v_amttaxadj,0)- v_othpay - v_taxcmpstn;
    begin
        select nvl(sum(stddec(amtpay,codempid,v_chken)),0)
        into v_amtsumded
        from tsincexp
        where codempid  = temploy1_codempid
			  and	dteyrepay = b_index_dteyrepay - v_zyear
			  and	dtemthpay = b_index_dtemthpay
			  and	numperiod = b_index_numperiod
              and    typincexp in ('4','5','6')
			  and    flgslip =	'1';
		exception when no_data_found then
			v_amtsumded := 0;
		end;
--<<redmine#1663 KOHU-HR2301 user14 07/02/2024 15:50 
    if  v_net < v_amtsumded  then
        insert_error(get_errorm_name('PY0018',v_lang));  
    end if;  
-->>redmine#1663 KOHU-HR2301 user14 07/02/2024 15:50 

       v_net	:= v_net	 - v_amtsumded ;

       c_typpaymt := 'BK';
	if (temploy3_codbank is null) or (temploy3_numbank is null) then
	  c_typpaymt := 'CS';
	else
		v_curprd :=	lpad(to_char(b_index_dteyrepay - v_zyear),4,'0')||
								lpad(b_index_dtemthpay,2,'0')||
								to_char(b_index_numperiod);
		for i in c_ttyppymt loop
			v_stprd := lpad(to_char(i.dteyrepay_st),4,'0')||
								 lpad(to_char(i.dtemthpay_st),2,'0')||
								 to_char(i.numperiod_st);
			v_enprd := lpad(to_char(i.dteyrepay_en),4,'0')||
								 lpad(to_char(i.dtemthpay_en),2,'0')||
								 to_char(i.numperiod_en);
			if v_stprd <= v_curprd and
				(v_enprd >= v_curprd or nvl(i.dteyrepay_en,0) = 0) then
				if i.flgpaymt = 'Y' then
					c_typpaymt := 'CS';
				else
				  c_typpaymt := 'CH';
				end if;
			end if;
		end loop; -- for c_ttyppymt
	end if;
	if c_typpaymt = 'BK' then
		c_codbank  := temploy3_codbank;
		c_codbank2 := temploy3_codbank2;
		c_numbank  := temploy3_numbank;
		c_numbank2 := temploy3_numbank2;
	else
	  c_codbank  := null;
	  c_codbank2 := null;
	  c_numbank  := null;
	  c_numbank2 := null;
	end if;
	if c_typpaymt = 'CS' then
		v_amount := v_net ; --proc_round('3',v_net);
		v_net1	:= v_amount;
		v_net2 := 0;
	else
		v_amount	:= v_net;
		if (temploy3_numbank2 is null) or (temploy3_codbank2 is null) then
		  v_net1 :=	v_net;
		  v_net2 :=	0;
		else
		  v_net1 :=	round((v_net * nvl(temploy3_amtbank,0)) / 100, 2);
		  v_net2 :=	v_net - v_net1;
		end if;
	end if;
  /*
	if v_amount <> v_net then
		begin
			select count(*)
			into v_chk
			from tsincexp
			where codempid  = temploy1_codempid
			  and	dteyrepay = b_index_dteyrepay - v_zyear
			  and	dtemthpay = b_index_dtemthpay
			  and	numperiod = b_index_numperiod
			  and	codpay = tcontrpy_codpaypy1
			  and flgslip =	'1';
		exception when no_data_found then
			v_chk := 0;
		end;
		if v_chk > 0 then
			v_chk := (v_amount * -1) + v_net;
			upd_tsincexp(tcontrpy_codpaypy1,'1',true,v_chk);
		else
		  v_amount := v_net;
		end if;

		c_amttax :=	c_amttax - v_amount + v_net;
		c_amtnet :=	v_amount;
		c_amtnet1 := v_net1;
		c_amtnet2 := v_net2;
	else */
		c_amtnet :=	v_net;
		c_amtnet1 := v_net1;
		c_amtnet2 := v_net2;
	--end if;
  -- Check การปัดเศษของเงินได้สุทธิ เพื่อส่วนต่างนำไปรวมเป็นภาษี ---
  c_amtnet  := proc_round(tcontrpy_flgfml,c_amtnet);
  c_amtnet1 := proc_round(tcontrpy_flgfml,c_amtnet1);
  c_amtnet2 := proc_round(tcontrpy_flgfml,c_amtnet2);
	if p_stdate <= p_endate and p_codapp = 'HRPY41B'  then
 		 c_qtywork := p_endate - p_stdate + 1;
	end if;
	v_amttaxyr := round(v_amttaxyr,2);
	v_amtsalyr := v_amtsalyr + v_othsalyr;
  v_countsinc := 0;
  --เช็คข้อมูลจากตาราง tsincexp ก่อนว่าในงวดนั้นๆมีข้อมูลหรือไม่ก่อนการ Insert Update ลงตาราง ttaxcur
  begin
    select count(*) into v_countsinc
      from tsincexp
			where codempid  = temploy1_codempid
			  and	dteyrepay = b_index_dteyrepay - v_zyear
			  and	dtemthpay = b_index_dtemthpay
			  and	numperiod = b_index_numperiod ;
  exception when no_data_found then
    v_countsinc := 0;
  end;
  if v_countsinc <> 0 then
    v_endate := p_endate;
    --หาข้อมูลการเคลื่อนไหว ณ งวด เดือน ปี โดย Call Package std_al.get_movemt
    std_al.get_movemt(temploy1_codempid,v_endate,'C',
                      'U',ttmovemt_codcomp,ttmovemt_codpos,
                      ttmovemt_numlvl,ttmovemt_codjob,ttmovemt_codempmt,
                      ttmovemt_typemp,ttmovemt_typpayroll,ttmovemt_codbrlc,
                      ttmovemt_codcalen,ttmovemt_jobgrade,ttmovemt_codgrpgl,
                      v_amthour,v_amtday,v_amtmth);

    v_amtothfixe := v_amtothfixe + v_amtothe + v_othsalnotcale;
    v_amtothfixc := v_amtothfixc + v_amtothc + v_othsalnotcalc;
    v_amtothfixo := v_amtothfixo + v_amtotho + v_othsalnotcalo;

    insert into ttaxcur (codempid,dteyrepay,dtemthpay,numperiod,
                         amtnet,amtcal,amtincl,amtincc,amtincn,
                         amtexpl,amtexpc,amtexpn,amttax,amtgrstx,
                         amtsoc,amtsoca,amtsocc,amtcprv,amtprove,
                         amtprovc,amtproie,amtproic,pctemppf,pctcompf,
                         codcomp,typpayroll,numlvl,typemp,codbrlc,
                         staemp,dteeffex,codgrpgl,codcurr,amtincom1,codbank,
                         numbank,bankfee,amtnet1,codbank2,numbank2,
                         bankfee2,amtnet2,qtywork,typpaymt,
                         dteupd,coduser,amtcalc,codpos,codempmt,
                         jobgrade,flgtax,
                         amtothe,
                         amtothc,
                         amtotho,
                         amtsalyr,amttaxyr,
                         amttaxoth,flgsoc,typincom,
                         codcreate ,codcompy
                         )
        values
      (temploy1_codempid,b_index_dteyrepay-v_zyear,b_index_dtemthpay,b_index_numperiod,
       stdenc(c_amtnet,temploy1_codempid,v_chken),
       stdenc(c_amtcal,temploy1_codempid,v_chken),
       stdenc(c_amtincl,temploy1_codempid,v_chken),
       stdenc(c_amtincc,temploy1_codempid,v_chken),
       stdenc(c_amtincn,temploy1_codempid,v_chken),
       stdenc(c_amtexpl,temploy1_codempid,v_chken),
       stdenc(c_amtexpc,temploy1_codempid,v_chken),
       stdenc(c_amtexpn,temploy1_codempid,v_chken),
       stdenc(c_amttax + c_amttaxothcal,temploy1_codempid,v_chken),
       stdenc(c_amtgrstx,temploy1_codempid,v_chken),
       stdenc(c_amtsoc,temploy1_codempid,v_chken),
       stdenc(c_amtsoca,temploy1_codempid,v_chken),
       stdenc(c_amtsocc,temploy1_codempid,v_chken),
       stdenc(c_amtcprv,temploy1_codempid,v_chken),
       stdenc(c_amtprove,temploy1_codempid,v_chken),
       stdenc(c_amtprovc,temploy1_codempid,v_chken),
       stdenc(c_amtproie,temploy1_codempid,v_chken),
       stdenc(c_amtproic,temploy1_codempid,v_chken),
       c_pctemppf,c_pctcompf,
       nvl(ttmovemt_codcomp,temploy1_codcomp),
       nvl(ttmovemt_typpayroll,temploy1_typpayroll),
       nvl(ttmovemt_numlvl,temploy1_numlvl),
       nvl(ttmovemt_typemp,temploy1_typemp),
       nvl(ttmovemt_codbrlc,temploy1_codbrlc),
       nvl(ttmovemt_staemp,temploy1_staemp),
       temploy1_dteeffex,
       nvl(ttmovemt_codgrpgl,temploy1_codgrpgl),
       tcontpm_codcurr,
       stdenc(temploy3_amtincom1,temploy1_codempid,v_chken),
       c_codbank,c_numbank,c_bankfee,
       stdenc(c_amtnet1,temploy1_codempid,v_chken),
       c_codbank2,c_numbank2,c_bankfee2,
       stdenc(c_amtnet2,temploy1_codempid,v_chken),
       c_qtywork,
       c_typpaymt,
       trunc(sysdate),v_coduser,
       stdenc(s_amtgrstx,temploy1_codempid,v_chken),
       nvl(ttmovemt_codpos,temploy1_codpos),
       nvl(ttmovemt_codempmt,temploy1_codempmt),
       nvl(ttmovemt_jobgrade,temploy1_jobgrade),
       temploy3_flgtax,
       stdenc(v_amtothfixe,temploy1_codempid,v_chken),
       stdenc(v_amtothfixc,temploy1_codempid,v_chken),
       stdenc(v_amtothfixo,temploy1_codempid,v_chken),
       stdenc(nvl(v_amtsalyr,0),temploy1_codempid,v_chken),
       stdenc(nvl(v_amttaxyr,0),temploy1_codempid,v_chken),
       stdenc(nvl(c_amttaxoth,0),temploy1_codempid,v_chken),
       temploy3_flgsoc,temploy3_typincom,
       v_coduser ,b_var_codcompy
       );

      update tsincexp set codcomp = nvl(ttmovemt_codcomp,temploy1_codcomp)
      where  codempid = temploy1_codempid
      and	   dteyrepay = b_index_dteyrepay - v_zyear
      and	   dtemthpay = b_index_dtemthpay
      and	   numperiod = b_index_numperiod ;

	v_exist := false;
	for r_ttaxmas in c_ttaxmas loop
		v_exist := true;
		update ttaxmas
		set codcomp = nvl(ttmovemt_codcomp,temploy1_codcomp) ,
			  amtnett	= stdenc(nvl(stddec(amtnett,temploy1_codempid,v_chken),0) + nvl(c_amtnet,0),temploy1_codempid,v_chken),
			  amtcalt	= stdenc(nvl(stddec(amtcalt,temploy1_codempid,v_chken),0) + nvl(c_amtcal,0),temploy1_codempid,v_chken),
			  amtinclt = stdenc(nvl(stddec(amtinclt,temploy1_codempid,v_chken),0) + nvl(c_amtincl,0),temploy1_codempid,v_chken),
			  amtincct = stdenc(nvl(stddec(amtincct,temploy1_codempid,v_chken),0) + nvl(c_amtincc,0),temploy1_codempid,v_chken),
			  amtincnt = stdenc(nvl(stddec(amtincnt,temploy1_codempid,v_chken),0) + nvl(c_amtincn,0),temploy1_codempid,v_chken),
			  amtexplt  = stdenc(nvl(stddec(amtexplt,temploy1_codempid,v_chken),0) + nvl(c_amtexpl,0),temploy1_codempid,v_chken),
			  amtexpct = stdenc(nvl(stddec(amtexpct,temploy1_codempid,v_chken),0) + nvl(c_amtexpc,0),temploy1_codempid,v_chken),
			  amtexpnt = stdenc(nvl(stddec(amtexpnt,temploy1_codempid,v_chken),0) + nvl(c_amtexpn,0),temploy1_codempid,v_chken),
			  --amttaxt	= stdenc(nvl(stddec(amttaxt,temploy1_codempid,v_chken),0) + nvl(c_amttax,0),temploy1_codempid,v_chken),
              amttaxt	= stdenc(nvl(stddec(amttaxt,temploy1_codempid,v_chken),0) + nvl(c_amttax,0)+ nvl(c_amttaxothcal,0),temploy1_codempid,v_chken),
			  amtgrstxt = stdenc(nvl(m_amtgrstxt,0),temploy1_codempid,v_chken),
			  amtsoct	= stdenc(nvl(stddec(amtsoct,temploy1_codempid,v_chken),0) + nvl(c_amtsoc,0),temploy1_codempid,v_chken),
			  amtsocat = stdenc(nvl(stddec(amtsocat,temploy1_codempid,v_chken),0) + nvl(c_amtsoca,0),temploy1_codempid,v_chken),
			  amtsocct = stdenc(nvl(stddec(amtsocct,temploy1_codempid,v_chken),0) + nvl(c_amtsocc,0),temploy1_codempid,v_chken),
			  amtcprvt = stdenc(nvl(stddec(amtcprvt,temploy1_codempid,v_chken),0) + nvl(c_amtcprv,0),temploy1_codempid,v_chken),
			  amtprovte = stdenc(nvl(stddec(amtprovte,temploy1_codempid,v_chken),0) + nvl(c_amtprove,0),temploy1_codempid,v_chken),
			  amtprovtc = stdenc(nvl(stddec(amtprovtc,temploy1_codempid,v_chken),0) + nvl(c_amtprovc,0),temploy1_codempid,v_chken),
			  amtsalyr = stdenc(nvl(v_amtsalyr,0),temploy1_codempid,v_chken),
			  amttaxyr = stdenc(nvl(v_amttaxyr,0),temploy1_codempid,v_chken),
			  amtsocyr = stdenc(nvl(v_amtsocyr,0),temploy1_codempid,v_chken),
			  amttcprv = stdenc(nvl(v_amttcprv,0),temploy1_codempid,v_chken),
			  amtproyr = stdenc(nvl(v_amtproyr,0),temploy1_codempid,v_chken),
			  qtyworkt = nvl(qtyworkt,0) + nvl(c_qtywork,0),
			  dteupd   = trunc(sysdate),
			  coduser  = v_coduser,
			  amtcalct = stdenc(nvl(stddec(amtcalct,temploy1_codempid,v_chken),0) + nvl(s_amtgrstx,0)  ,temploy1_codempid,v_chken),
        amtothe  = stdenc(nvl(stddec(amtothe,temploy1_codempid,v_chken),0)  + nvl(v_amtothfixe,0),temploy1_codempid,v_chken),
        amtothc  = stdenc(nvl(stddec(amtothc,temploy1_codempid,v_chken),0)  + nvl(v_amtothfixc,0),temploy1_codempid,v_chken),
        amtotho  = stdenc(nvl(stddec(amtotho,temploy1_codempid,v_chken),0)  + nvl(v_amtothfixo,0),temploy1_codempid,v_chken),
        amttaxoth= stdenc(nvl(stddec(amttaxoth,temploy1_codempid,v_chken),0) + nvl(c_amttaxoth,0),temploy1_codempid,v_chken)
		where rowid  = r_ttaxmas.rowid;
	end loop;
	if not v_exist then
		insert into ttaxmas
			(codempid,dteyrepay,codcomp,
			 amtnett,amtcalt,amtinclt,amtincct,amtincnt,
			 amtexplt,amtexpct,amtexpnt,amttaxt,amtgrstxt,
			 amtsoct,amtsocat,amtsocct,amtcprvt,amtprovte,
			 amtprovtc,amtsalyr,amttaxyr,amtsocyr,amttcprv,
			 amtproyr,qtyworkt,dteupd,coduser,
			 amtcalct,
       amtothe,amtothc,amtotho,amttaxoth)
		values
			(temploy1_codempid,b_index_dteyrepay-v_zyear,
			 temploy1_codcomp,
			 stdenc(c_amtnet,temploy1_codempid,v_chken),
			 stdenc(c_amtcal,temploy1_codempid,v_chken),
			 stdenc(c_amtincl,temploy1_codempid,v_chken),
			 stdenc(c_amtincc,temploy1_codempid,v_chken),
			 stdenc(c_amtincn,temploy1_codempid,v_chken),
			 stdenc(c_amtexpl,temploy1_codempid,v_chken),
			 stdenc(c_amtexpc,temploy1_codempid,v_chken),
			 stdenc(c_amtexpn,temploy1_codempid,v_chken),
			 stdenc(c_amttax,temploy1_codempid,v_chken),
			 stdenc(m_amtgrstxt,temploy1_codempid,v_chken),
			 stdenc(c_amtsoc,temploy1_codempid,v_chken),
			 stdenc(c_amtsoca,temploy1_codempid,v_chken),
			 stdenc(c_amtsocc,temploy1_codempid,v_chken),
			 stdenc(c_amtcprv,temploy1_codempid,v_chken),
			 stdenc(c_amtprove,temploy1_codempid,v_chken),
			 stdenc(c_amtprovc,temploy1_codempid,v_chken),
			 stdenc(nvl(v_amtsalyr,0),temploy1_codempid,v_chken),
			 stdenc(nvl(v_amttaxyr,0),temploy1_codempid,v_chken),
			 stdenc(nvl(v_amtsocyr,0),temploy1_codempid,v_chken),
			 stdenc(nvl(v_amttcprv,0),temploy1_codempid,v_chken),
			 stdenc(nvl(v_amtproyr,0),temploy1_codempid,v_chken),
			 c_qtywork,
			 trunc(sysdate),v_coduser,
			 stdenc(nvl(s_amtgrstx,0),temploy1_codempid,v_chken),
       stdenc(nvl(v_amtothfixe,0) ,temploy1_codempid,v_chken),
       stdenc(nvl(v_amtothfixc,0) ,temploy1_codempid,v_chken),
       stdenc(nvl(v_amtothfixo,0) ,temploy1_codempid,v_chken),
       stdenc(nvl(c_amttaxoth,0) ,temploy1_codempid,v_chken)
       );
	end if;
  end if;
end;

PROCEDURE cal_tothpay IS
    v_stdate		date;
    v_endate		date;
    v_amtpay   		number;

    cursor c_tothpay is
        select codpay,amtpay
        from	 tothpay
        where  codempid  = temploy1_codempid
        and		 dteyrepay = b_index_dteyrepay - v_zyear
        and 	 dtemthpay = b_index_dtemthpay
        and 	 numperiod = b_index_numperiod;

begin
    delete from	tsincexp
          where	codempid	=	temploy1_codempid
            and	dteyrepay = (b_index_dteyrepay - v_zyear)
            and dtemthpay = b_index_dtemthpay
            and numperiod = b_index_numperiod
            and	flgslip   = '2';
    for r_tothpay in c_tothpay loop
        v_amtpay := stddec(r_tothpay.amtpay,temploy1_codempid,v_chken);
        upd_tsincexp(r_tothpay.codpay,'2',true,v_amtpay);
    end loop;	-- for tothpay
end;

PROCEDURE upd_ttaxmasl IS
    v_exist		boolean := false;

    cursor c_ttaxmasl is
        select rowid
        from	 ttaxmasl
        where	 dteyrepay = (b_index_dteyrepay - v_zyear)
        and		 dtemthpay = b_index_dtemthpay
        and		 numperiod = b_index_numperiod
        and		 codempid	 = temploy1_codempid;
BEGIN
  for r_ttaxmasl in c_ttaxmasl loop
  	v_exist := true;
  	update ttaxmasl
  		set	 codcomp	    = temploy1_codcomp,
  				 typtax		= temploy3_typtax,
  				 flgtax		= temploy3_flgtax,
  				 stamarry	= temploy1_stamarry,
  				 amtincbf	= stdenc(temploy3_amtincbf,codempid,v_chken),
  				 amttaxbf	= stdenc(temploy3_amttaxbf,codempid,v_chken),
  				 amtsaid	= stdenc(temploy3_amtsaid,codempid,v_chken),
  				 amtpf		= stdenc(temploy3_amtpf,codempid,v_chken),
  				 amtincsp	= stdenc(temploy3_amtincsp,codempid,v_chken),
  				 amttaxsp	= stdenc(temploy3_amttaxsp,codempid,v_chken),
  				 amtsasp	= stdenc(temploy3_amtsasp,codempid,v_chken),
  				 amtpfsp	= stdenc(temploy3_amtpfsp,codempid,v_chken),
  				 coduser	= v_coduser
  		where rowid = r_ttaxmasl.rowid;
  end loop;
  if not v_exist then
  	insert into ttaxmasl
  		(dteyrepay,dtemthpay,numperiod,
  		 codempid,codcomp,
  		 typtax,flgtax,stamarry,
  		 amtincbf,amttaxbf,amtsaid,amtpf,
  		 amtincsp,amttaxsp,amtsasp,amtpfsp,
  		 coduser)
  	values
  		((b_index_dteyrepay - v_zyear),b_index_dtemthpay,b_index_numperiod,
  		 temploy1_codempid,temploy1_codcomp,
  		 temploy3_typtax,temploy3_flgtax,temploy1_stamarry,
			 stdenc(temploy3_amtincbf,temploy1_codempid,v_chken),
			 stdenc(temploy3_amttaxbf,temploy1_codempid,v_chken),
			 stdenc(temploy3_amtsaid,temploy1_codempid,v_chken),
			 stdenc(temploy3_amtpf,temploy1_codempid,v_chken),
			 stdenc(temploy3_amtincsp,temploy1_codempid,v_chken),
			 stdenc(temploy3_amttaxsp,temploy1_codempid,v_chken),
			 stdenc(temploy3_amtsasp,temploy1_codempid,v_chken),
			 stdenc(temploy3_amtpfsp,temploy1_codempid,v_chken),
  		 v_coduser);
  end if;
END;

PROCEDURE upd_tsincexp(p_codpay 	in tinexinf.codpay%type,
                       p_flgslip	in tsincexp.flgslip%type,
                       p_local		in boolean,
                       p_amtpay 	in out number) IS

    v_typpay			tinexinf.typpay%type;
    v_typinc			tinexinf.typinc%type;
    v_typpayr			tinexinf.typpayr%type;
    v_typpayt			tinexinf.typpayt%type;
    v_flgfml			tinexinf.flgfml%type;
    v_amtpay 			number;
    v_amtpay_e 		    number;
    v_exist				boolean;
    v_flgcal			tinexinf.flgcal%type;
    v_count				number;

  cursor c_tsincexp is
   select rowid
	   from tsincexp
	  where	codempid  = temploy1_codempid
	    and dteyrepay	=	b_index_dteyrepay - v_zyear
	    and dtemthpay	=	b_index_dtemthpay
	    and numperiod	=	b_index_numperiod
	    and codpay    = p_codpay
	    and flgslip   =	p_flgslip;

BEGIN
	if (p_codpay is not null) and (p_amtpay <> 0) then
		begin
			select typpay,typinc,typpayr,typpayt,flgcal,flgfml
			into v_typpay,v_typinc,v_typpayr,v_typpayt,v_flgcal,v_flgfml
			from tinexinf
			where	codpay = p_codpay;
		exception when no_data_found then
		  insert_error(get_errorm_name('HR2010',v_lang)||' (TINEXINF) : '||p_codpay);
		  p_amtpay := 0;
		  return;
		end;
		if p_local then
			v_amtpay   := p_amtpay;
			v_amtpay_e := p_amtpay / b_var_ratechge;
		else
			v_amtpay   := p_amtpay * b_var_ratechge;
			v_amtpay_e := p_amtpay;
		end if;
		if v_flgfml is not null then
		  v_amtpay	 := proc_round(v_flgfml,v_amtpay);
		  v_amtpay_e := proc_round(v_flgfml,v_amtpay_e);
		end if;
        
		if v_amtpay <> 0 then
			v_exist := false;
			for r_tsincexp in c_tsincexp loop
			  v_exist := true;
			  update tsincexp
			  set typincexp	  = v_typpay,
			      codcomp     = temploy1_codcomp,
			      typinc      = v_typinc,
			      typpayr     = v_typpayr,
			      typpayt     = v_typpayt,
			      typpayroll  = temploy1_typpayroll,
			      typemp      = temploy1_typemp,
			      numlvl      = temploy1_numlvl,
			      codcurr_e   = temploy3_codcurr,
			      amtpay      = stdenc(stddec(amtpay,codempid,v_chken) + v_amtpay,codempid,v_chken),
			      amtpay_e    = stdenc(stddec(amtpay_e,codempid,v_chken) + v_amtpay_e,codempid,v_chken),
			      codcurr     = tcontpm_codcurr,
			      codbrlc     = temploy1_codbrlc,
			      codempmt    = temploy1_codempmt,
			      dteupd      = trunc(sysdate),
			      coduser     = v_coduser,
                  codcreate   = v_coduser
			  where rowid = r_tsincexp.rowid;
			end loop; -- loop tsincexp
			if not v_exist then
			  insert into tsincexp
			    (codempid,dteyrepay,dtemthpay,
			     numperiod,codpay,flgslip,
			     typincexp,codcomp,typinc,
			     typpayr,typpayt,typpayroll,
			     amtpay,amtpay_e,numlvl,
			     typemp,codcurr_e,codcurr,
			     codbrlc,dteupd,coduser,codempmt,
                 codcreate)
			  values
			    (temploy1_codempid,b_index_dteyrepay - v_zyear,b_index_dtemthpay,
			     b_index_numperiod,p_codpay,p_flgslip,
			     v_typpay,temploy1_codcomp,v_typinc,
			     v_typpayr,v_typpayt,temploy1_typpayroll,
			     stdenc(v_amtpay,temploy1_codempid,v_chken),stdenc(v_amtpay_e,temploy1_codempid,v_chken),temploy1_numlvl,
			     temploy1_typemp,temploy3_codcurr,tcontpm_codcurr,
			     temploy1_codbrlc,trunc(sysdate),v_coduser,temploy1_codempmt,
                 v_coduser);
			end if;
		end if;
		if p_local then
			p_amtpay := v_amtpay;
		else
			p_amtpay := v_amtpay_e;
		end if;
	end if;
end;

function cal_formula (p_codpay in tinexinf.codpay%type,
                      p_amtpay in number) return number IS
	v_amtmin			number;
	v_amtmax			number;
	v_formula			varchar2(1000);
	v_stmt				varchar2(1000);
	v_length			number;
	i							number;
	v_codpay			tinexinf.codpay%type;
	v_amtpay			number;
	v_sum					number;
begin
	v_sum := p_amtpay;
	begin
		select amtmin,amtmax,formula
		into v_amtmin,v_amtmax,v_formula
		from tformula
		where codpay = p_codpay
		  and dteeffec	=	(select max(dteeffec)
		                   from tformula
										 	 where codpay = p_codpay
										 	   and dteeffec <= sysdate);
		if v_formula is not null then
			v_length := length(v_formula);
			v_stmt   := v_formula;
			for i in 1..v_length loop
				if substr(v_formula,i,2) = '{&' then
					v_codpay := substr(v_formula,i + 2,instr(substr(v_formula,i + 2) ,'}') -1) ;
					if v_codpay = p_codpay then
						v_amtpay := p_amtpay;
					else
						begin
						 select stddec(amtpay,temploy1_codempid,v_chken)
							 into v_amtpay
							 from tsincexp
							where codempid  = temploy1_codempid
							  and dteyrepay = b_index_dteyrepay - v_zyear
							  and dtemthpay = b_index_dtemthpay
							  and numperiod = b_index_numperiod
							  and codpay    = v_codpay;
						exception when no_data_found then
							v_amtpay := 0;
						end;
					end if;
           v_stmt := replace(v_stmt,substr(v_stmt,instr(v_stmt,'{&'),instr( substr(v_stmt,instr(v_stmt,'{&')), '}') ),v_amtpay);
				end if;
			end loop; -- for i
		  v_sum := execute_sql('select '||v_stmt||' from dual');
		end if;
		if nvl(v_amtmin,0) > 0 then
			v_sum := greatest(v_sum,nvl(v_amtmin,0));
		end if;
		if nvl(v_amtmax,0) > 0 then
			v_sum := least(v_sum,nvl(v_amtmax,0));
		end if;
	exception when no_data_found then
		null;
	end;
  return(v_sum);
end;

function proc_round (p_flgfml		varchar2,
	                   p_amount		number)  return number is

	v_decimal				number;
	v_remainder			number;
	v_amount				number := 0;
BEGIN
  v_amount :=	p_amount;
	if p_flgfml = '1' then    							-- ปัดทิ้ง
	  v_amount :=	trunc(p_amount,0);
	elsif p_flgfml = '2' then 							-- ปัดขึ้น/ลง เป็นบาท
	  v_amount :=	round(p_amount,0);
	elsif p_flgfml = '3' then 						  -- ปัดขึ้น/ลง เป็นสลึง
	  v_decimal := (p_amount - trunc(p_amount, 0));
	  v_remainder := trunc(v_decimal/0.25,0) * 0.25;
	  if v_decimal - v_remainder >= 0.25/2 then
		  v_remainder :=	v_remainder + 0.25;
	  end if;
	  v_amount :=	trunc(p_amount,0) + v_remainder;
	elsif p_flgfml = '4' then 					    -- ไม่ปัด -- ให้เก็บได้ 2 หลัก
	  v_amount :=	round(p_amount,2);
	elsif p_flgfml = '5' then 							-- ปัดขึ้นเป็นบาท
	  if (p_amount * 100) mod 100 <> 0 then
		  v_amount	:= trunc(p_amount,0) + 1;
	  end if;
	elsif p_flgfml = '6' then 							-- ปัดขึ้นเป็นสลึง
	  v_decimal	:= (p_amount - trunc(p_amount,0));
	  v_remainder	:= trunc(v_decimal/0.25,0) * 0.25;
	  if v_decimal - v_remainder > 0 then
		  v_remainder :=	v_remainder + 0.25;
	  end if;
	  v_amount := trunc(p_amount,0) + v_remainder;
	elsif p_flgfml = '7' then							-- ปัดลงเป็นสลึง
	  v_decimal := (p_amount - trunc(p_amount, 0));
	  v_remainder	:= trunc(v_decimal / 0.25, 0) * 0.25;
	  v_amount :=	trunc(p_amount,0) + v_remainder;
	elsif p_flgfml = '8' then 						  -- ปัดขึ้น/ลง เป็นห้าสิบ
	  v_decimal := (p_amount - trunc(p_amount, 0));
	  v_remainder := trunc(v_decimal/0.5,0) * 0.5;
	  if v_decimal - v_remainder >= 0.5/2 then
		  v_remainder :=	v_remainder + 0.5;
	  end if;
	  v_amount :=	trunc(p_amount,0) + v_remainder;
	elsif p_flgfml = '9' then 							-- ปัดขึ้นเป็นห้าสิบ
	  v_decimal	:= (p_amount - trunc(p_amount,0));
	  v_remainder	:= trunc(v_decimal/0.5,0) * 0.5;
	  if v_decimal - v_remainder > 0 then
			v_remainder :=	v_remainder + 0.5;
	  end if;
	  v_amount := trunc(p_amount,0) + v_remainder;
	elsif p_flgfml = '10' then							-- ปัดลงเป็นห้าสิบ
	  v_decimal := (p_amount - trunc(p_amount, 0));
	  v_remainder	:= trunc(v_decimal / 0.5, 0) * 0.5;
	  v_amount :=	trunc(p_amount,0) + v_remainder;
	end if;
	return v_amount;
end;

PROCEDURE cal_prov (p_stdate 	in date,
                    p_endate    in date,
                    p_amtcprv 	in number,
                    p_amtprove	in out number,
                    p_amtprovc 	in out number,
                    p_amtproyr	in out number) is

    v_year				number;
    v_month				number;
    v_day				  number;
    v_amtprove		number := 0;
    v_amtprovc		number := 0;
    v_amtprove_curr   number := 0;
    v_rateemp			number := 0;
    v_ratecomp		number := 0;
    v_amt				  number;
    v_amtproyr		number;
    v_typpay			tinexinf.typpay%type;
    v_codempid		temploy1.codempid%type;
    v_flgfml			tinexinf.flgfml%type;
    v_numseq			number;
    v_flgfound	  boolean;
    v_cond				varchar2(1000);
    v_stmt				varchar2(1000);
    v_qtywork			number;
    v_ages				number;
    v_dteeffec	  date;
    v_date				date;
    v_sume				number;
    v_sumc				number;
    v_qtycompst		number;

    cursor c_tpfmemb is
        select rowid,dteeffec,dtereti,codpfinf,
               stddec(amteaccu,codempid,v_chken) amteaccu, -- ยอดเงินสะสมของพนักงาน
               stddec(amtcaccu,codempid,v_chken) amtcaccu -- ยอดเงินสมทบจากบริษัท
          from tpfmemb -- hrpyb2e บันทึกรายชื่อสมาชิกกองทุนฯ
         where codempid = temploy1_codempid
           and dteeffec <= p_endate
           and (((dtereti is not null) and (dtereti > p_stdate)) or (dtereti is null));

    cursor c_tpfeinf is
        select numseq,syncond,flgconded,dteeffec
          from tpfeinf
         where codcompy = b_var_codcompy
           and dteeffec = tpfhinf_dteeffec
        order by numseq;
begin

    begin
        select codempid into v_codempid
          from tpfmemb
         where codempid = temploy1_codempid;
    exception when no_data_found then
        p_amtproyr := 0;
    end;
    c_pctemppf 		:= 0;
    c_pctcompf 		:= 0;
	if (tcontrpy_codpaypy3 is not null) and (tcontrpy_codpaypy7 is not null) then -- มีการกำหนดรหัสรายได้ส่วนหัก เงินกองทุนสำรองเลี้ยงชีพ และ เงินสะสมกองทุนสำรองเลี้ยงชีพ (บริษัท)
        if p_amtcprv > 0  or v_process = 'HRPY44B' then -- มีรายได้ส่วนหักที่คำนวณ PF > 0
          for r_tpfmemb in c_tpfmemb loop
            begin
              select dteeffec
                into tpfhinf_dteeffec
                from tpfhinf
               where codcompy = b_var_codcompy
                 and dteeffec = (select max(dteeffec)
                                   from tpfhinf
                                  where	codcompy = b_var_codcompy
                                    and dteeffec <= trunc(sysdate));
            exception when no_data_found then
              tpfhinf_dteeffec := null;
            end;
            for r1 in c_tpfeinf loop
              v_numseq   := r1.numseq;
              v_flgfound := true;

              if r1.syncond is not null then
                get_service_year(temploy1_dteempmt,(p_endate-1),'Y',v_year,v_month,v_day);
                v_qtywork := (v_year * 12) + v_month; -- อายุงาน
                get_service_year(temploy1_dteempdb,(p_endate-1),'Y',v_year,v_month,v_day);
                v_ages := v_year; -- อายุสมาชิก
                v_cond := r1.syncond;
                v_cond := replace(v_cond,'V_TEMPLOY.CODEMPID',''''||temploy1_codempid||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.CODCOMP',''''||temploy1_codcomp||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.CODPOS',''''||temploy1_codpos||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.TYPEMP',''''||temploy1_typemp||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.CODEMPMT',''''||temploy1_codempmt||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.TYPPAYROLL',''''||temploy1_typpayroll||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.STAEMP',''''||temploy1_staemp||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.DTEEMPMT'  ,'to_date('''||to_char(temploy1_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
                v_cond := replace(v_cond,'V_TEMPLOY.QTYWORK',v_qtywork);
                v_cond := replace(v_cond,'V_TEMPLOY.AGES',v_ages);
                v_cond := replace(v_cond,'V_TEMPLOY.NUMLVL',''''||temploy1_numlvl||'''');
                v_cond := replace(v_cond,'V_TEMPLOY.JOBGRADE',''''||temploy1_jobgrade||'''');
                v_cond := replace(v_cond,'TPFMEMB.CODPFINF',''''||r_tpfmemb.codpfinf||'''');
                v_stmt := 'select count(*) from dual where '||v_cond;
                v_flgfound := execute_stmt(v_stmt);
              end if;

              if v_flgfound then
                v_rateemp  := 0;
                v_ratecomp := 0;
                begin
                    select ratecret , ratecsbt  into v_rateemp , v_ratecomp
                      from tpfmemrt -- หา rate คำนวณ PF ที่ได้จาก syncond
                     where codempid = temploy1_codempid
                       and dteeffec = (select max(dteeffec)
                                       from tpfmemrt
                                        where codempid = temploy1_codempid
                                          and dteeffec <= p_endate);
                exception when no_data_found then
                    v_rateemp := 0;
                end;
                v_amtproyr := nvl(p_amtprove,0);

                if nvl(p_amtcprv,0) > 0 then -- รายได้ส่วนหักที่คำนวณ PF > 0
                  c_pctemppf 		:= v_rateemp ;
                  c_pctcompf 		:= v_ratecomp ;
                  v_amtprove := nvl(p_amtcprv,0) * nvl(v_rateemp,0) / 100;
                  v_amtprovc := nvl(p_amtcprv,0) * nvl(v_ratecomp,0) / 100;
                  upd_tsincexp(tcontrpy_codpaypy3,'1',true,v_amtprove);
                  upd_tsincexp(tcontrpy_codpaypy7,'1',true,v_amtprovc);
                end if;
                p_amtprove := nvl(p_amtprove,0) + v_amtprove;
                p_amtprovc := nvl(p_amtprovc,0) + v_amtprovc;
                begin
                  select nvl(sum(nvl(stddec(amtprove,codempid,v_chken),0)),0)	into v_amt -- หายอดสะสมส่วนของพนักงานจาก ttaxcur ในปีที่คำนวณ
                  from ttaxcur
                  where ((codempid = temploy1_codempid) or
                         (codempid = (select ocodempid
                                      from temploy1
                                      where codempid = temploy1_codempid)))
                    and dteyrepay = b_index_dteyrepay - v_zyear;
                exception when no_data_found then
                  v_amt := 0;
                end;
                v_amtproyr := v_amtproyr + v_amt; -- ยอดกองทุนสะสม
                if (b_var_stacal = '4') or ((b_var_stacal = '2') and (b_index_flag = 'N')) or -- (พ้นสภาพ)หรือ(พ้นสภาพระหว่างงวดและ Option คำนวณถึงวันที่พ้นสภาพ)
                   ((temploy1_dteeffex = b_var_dteend + 1)) then -- หรือวันที่ลาออกถึงวันสิ้นรอบ
                  p_amtproyr := v_amtproyr + v_amtprove; -- สะสม + ยอดเดือนปัจจุบัน
                else
                  begin
                    select typpay,flgfml	into v_typpay,v_flgfml
                    from 	 tinexinf
                    where  codpay = tcontrpy_codpaypy3;
                  exception when no_data_found then
                    v_typpay := null;
                  end;
                  v_amt := 0;

                  /*begin comment 28/04/2022 By S
                    select nvl(sum(nvl(stddec(amtprove,codempid,v_chken),0)),0)	into v_amtprove_curr
                    from  ttaxcur
                    where codempid  = temploy1_codempid
                    and   dteyrepay = b_index_dteyrepay - v_zyear
                    and   dtemthpay = b_index_dtemthpay ;
                  exception when no_data_found then
                    v_amtprove_curr := 0;
                  end;
                  v_amtprove_curr := nvl(v_amtprove_curr,0) ;*/

                  if nvl(b_var_profix,0) > 0 and v_typpay = '4' then -- รายได้ประจำที่คำนวณ PF
                    if b_var_perdpay > 0 then -- จำนวนงวดที่เหลือในเดือน > 0 กรณีในเดือนมีมากกว่า 1 งวด
                      v_amtproyr := v_amtproyr + (((b_var_profix / b_var_mqtypay) * b_var_perdpay)
                                               * nvl(v_rateemp,0) / 100);
                    end if;
                    v_amt := proc_round(v_flgfml,(b_var_profix * nvl(v_rateemp,0) / 100)); -- 
                    v_amt := v_amt * (12 - to_number(b_index_dtemthpay));
                  end if;
                  if v_process = 'HRPY44B' then
                     p_amtproyr := v_amtproyr + v_amt;
                  else
                     p_amtproyr := v_amtproyr + v_amtprove + v_amt; -- ยอดสะสม + เดือนปัจจุบัน + ยอดพึงประเมิน
                  end if;
                end if;
                if v_process = 'HRPY44B' then
                  return ;
                end if;
                update tpfmemb -- update ยอดเงินสะสม
                set amteaccu = stdenc(nvl(stddec(amteaccu,codempid,v_chken),0) + p_amtprove,codempid,v_chken),
                    amtcaccu = stdenc(nvl(stddec(amtcaccu,codempid,v_chken),0) + p_amtprovc,codempid,v_chken),
                    codcomp = temploy1_codcomp,
                    typpayroll = b_var_typpayroll
                where	rowid = r_tpfmemb.rowid;
                exit;
              end if; -- v_flgfound
            end loop; -- for c_tpteinf
          end loop; -- for c_tpfmemb
        end if;
        p_amtproyr := p_amtproyr + nvl(temploy3_amtpf,0); -- ยอดคำนวณทั้งปี + ยอดยกมา
	end if;
end;
--
PROCEDURE cal_social(p_amtsoc		  in number,
                     p_amtsoc_oth	in number,
                     p_amtsoca		in out number,
                     p_amtsocc		in out number,
                     p_amtsocyr		in out number) IS

v_year				number :=	0;
v_month				number :=	0;
v_day			    number := 0;
v_social			number :=	0;
v_amtmin			number :=	0;
v_amtminc     number :=	0;
v_amtmax			number :=	0;
v_amtmaxc			number :=	0;
v_amtsoc			number :=	0;
v_amtsoca			number :=	0;
--v_exist 			boolean;
v_amtsocyr		number :=	0;
v_socprev			number :=	0;
v_soccprev		number :=	0;
v_socnext			number :=	0;
v_soccurr			number :=	0;

v_soccnext		number :=	0;
v_socccurr		number :=	0;

v_count				number :=	0;
v_dteeffec		ttmovemt.dteeffec%type := null;
v_numbrlvl_old	    tcodsoc.numbrlvl%type;
v_numbrlvl_new	    tcodsoc.numbrlvl%type;
v_typpay			tinexinf.typpay%type;
v_period			number := 0;
v_oldempid    temploy1.codempid%type ;
v_pctsoc      number ;
v_pctsocc     number ;
v_socialc			number :=	0;
v_sqlerrm     varchar2(200) ;

v_amtsocc     number ;
v_tmp_amtsocc number ;
--<<user46 NXP-HR2101 09/12/2021
v_socfix_per    number ;
v_socfix_month  number ;
v_soc_amt			  number :=	0;
-->>
  type typ_emp is table of varchar2(100) index by binary_integer;
      v_ocodempid   typ_emp;
      v_tmp_amtsoc   number:=0;
      v_tmp_amtsoca  number:=0;
      v_tmp_socprev  number:=0;
      v_tmp_soccprev number:=0;
  cursor c_tssmemb is
    select rowid
	  from tssmemb
	  where codempid = temploy1_codempid
	  for  update;

  cursor c_ttmovemt is
	  select dteeffec,codbrlc,codbrlct,codcomp,codcompt
	  from   ttmovemt
	  where codempid = temploy1_codempid -- เช็ค requirement ว่าต้องการ case แบบไหน อาจจะ where ไม่ครบหรือไม่
	    and	dteeffec <= b_var_dteend
	    and	((codbrlct <> codbrlc) or (hcm_util.get_codcomp_level(codcompt,'1') <> hcm_util.get_codcomp_level(codcomp,'1')))
	  order by dteeffec desc,numseq desc;

BEGIN
    if (tcontrpy_codpaypy2 is not null) and (tcontrpy_codpaypy6 is not null) then -- เช็คว่ามีการกำหนดรหัสรายได้ส่วนหักของประกันสังคม
		if temploy1_dteempdb < temploy1_dteempmt then
      --<<Find old codempid case rehire
      v_count := 1;
      v_ocodempid(v_count) := temploy1_codempid;
      v_pctsoc  := tssrate_pctsoc ; -- rate คำนวณหักประกันสังคมของพนักงาน
      v_pctsocc := tssrate_pctsocc ; -- rate คำนวณหักประกันสังคมของบริษัท
      <<emp_loop>>
      loop -- หารหัสพนักงานเดิม
        begin
          select ocodempid into v_oldempid
          from temploy1
          where codempid = v_ocodempid(v_count-1);
          v_count := v_count + 1;
          v_ocodempid(v_count) := v_oldempid ;
        exception when no_data_found then
          exit emp_loop;
        end;
      end loop;
      -->>Find old codempid case rehire

      for r_ttmovemt in c_ttmovemt loop
				begin
					select numbrlvl -- ลำดับสาขาประกันสังคม
					into v_numbrlvl_old
					from tcodsoc
					where codcompy = b_var_codcompy
					  and codbrlc = r_ttmovemt.codbrlct;
				exception when no_data_found then
					v_numbrlvl_old := null;
				end;
				begin
					select numbrlvl
					into v_numbrlvl_new
					from tcodsoc
					where codcompy = b_var_codcompy
					  and codbrlc = r_ttmovemt.codbrlc;
				exception when no_data_found then
					v_numbrlvl_new := null;
				end;
				if (v_numbrlvl_old <> v_numbrlvl_new) or --
					 (hcm_util.get_codcomp_level(r_ttmovemt.codcompt,'1') <> hcm_util.get_codcomp_level(r_ttmovemt.codcomp,'1')) then
					v_dteeffec := r_ttmovemt.dteeffec;
				end if;
				exit;
			end loop;

      if v_dteeffec is not null then
				if (trunc(months_between(v_dteeffec,temploy1_dteempdb) / 12)) +
						(mod(months_between(v_dteeffec,temploy1_dteempdb),12) / 12) > tcontrpy_qtyage then -- เช็คอายุพนักงานต้องไม่เกินที่กำหนด
			  	return;
			  end if;
		  end if;
			if (trunc(months_between(temploy1_dteempmt,temploy1_dteempdb) / 12)) +
					(mod(months_between(temploy1_dteempmt,temploy1_dteempdb),12) / 12) <= tcontrpy_qtyage then -- เช็คอายุพนักงานต้องไม่เกินที่กำหนด
        v_amtsoc  := 0;
        v_amtsoca := 0;
        v_amtsocc := 0;

        for i in 1..v_count loop -- วนตามรหัสพนักงานเดิม
            begin
            select   nvl(sum(nvl(stddec(amtsoc,codempid,v_chken),0)),0), -- ฐานเงินคำนวณประกันสังคม
                     nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0), -- เงินประกันสังคมพนักงาน
                     nvl(sum(nvl(stddec(amtsocc,codempid,v_chken),0)),0) -- เงินประกันสังคมบริษัท
              into  v_tmp_amtsoc ,v_tmp_amtsoca , v_tmp_amtsocc
              from  ttaxcur
              where codempid  = v_ocodempid(i)
                and dteyrepay = b_index_dteyrepay - v_zyear
                and	dtemthpay = b_index_dtemthpay -- หาเงินหักประกันสังคมที่อยู่ในเดือนเดียวกันกรณีมีหลายงวด
                and hcm_util.get_codcomp_level(codcomp,'1') = hcm_util.get_codcomp_level(temploy1_codcomp,'1') ;  -- TMG-590056 user19 21/06/2016
            exception when no_data_found then
              v_tmp_amtsoc  := 0;
              v_tmp_amtsoca := 0;
              v_tmp_amtsocc := 0;
            end;
            v_amtsoc  := v_amtsoc + v_tmp_amtsoc;
            v_amtsoca := v_amtsoca + v_tmp_amtsoca ;
            v_amtsocc := v_amtsocc + v_tmp_amtsocc ;

        end loop;
        v_amtmin  := tcontrpy_amtminsoc * v_pctsoc  / 100; -- ค่าจ้างคำนวณเงิน สปส.ขั้นต่ำ * rate ของพนักงาน ที่กำหนด Min
        v_amtminc := tcontrpy_amtminsoc * v_pctsocc / 100; -- ค่าจ้างคำนวณเงิน สปส.ขั้นต่ำ * rate ของบริษัท ที่กำหนด Min
        v_amtmax  := tcontrpy_amtmaxsoc * v_pctsoc  / 100; -- ค่าจ้างคำนวณเงิน สปส.สูงสุด * rate ของพนักงาน ที่กำหนด Max
        v_amtmaxc := tcontrpy_amtmaxsoc * v_pctsocc / 100; -- ค่าจ้างคำนวณเงิน สปส.สูงสุด * rate ของบริษัท ที่กำหนด Max
        v_social  := (p_amtsoc + v_amtsoc) * tssrate_pctsoc / 100; -- (เงินคำนวณ + เงินคำนวณในเดือน(งวดอื่นๆ)) * rate พนักงาน
        v_socialc := (p_amtsoc + v_amtsoc) * v_pctsocc / 100;
        if v_social > 0 then -- ส่วนของพนักงาน
					v_social := least(v_social,v_amtmax); -- เทียบที่คำนวณ ถ้าเกิน Max ให้เอา Max
					v_social := greatest(v_social,v_amtmin); -- เทียบที่คำนวณ ถ้าน้อยกว่า Min ให้เอา Min
					if tcontrpy_flgfmlsc = '2' then -- เงื่อนไขการปัดเศษของเงินประกันสังคม
						v_social := round(round(v_social,3),2);
					end if;
--07/02/2024
				  --v_social := proc_round(tcontrpy_flgfmlsc,v_social);
				  v_social := round(round(round(v_social,3),2));
--07/02/2024
					v_social := v_social - v_amtsoca; -- เงินหักที่คำนวณได้ - เงินหักสะสมในเดือน
				end if;
        if v_socialc > 0 then -- ส่วนของบริษัท
					v_socialc := least(v_socialc,v_amtmaxc);
					v_socialc := greatest(v_socialc,v_amtmin);

          if tcontrpy_flgfmlsc = '2' then
						v_socialc := round(round(v_socialc,3),2);
					end if;
--07/02/2024
				 -- v_socialc := proc_round(tcontrpy_flgfmlsc,v_socialc);
				  v_socialc :=   round(round(round(v_socialc,3),2));
--07/02/2024
					v_socialc := v_socialc - v_amtsocc;
				end if;

        if v_process = 'HRPY41B' and ( v_social < 0 and  v_socialc < 0 ) then
					insert_error(get_errorm_name('PY0022',v_lang)); -- เงินประกันสังคมคำนวณได้น้อยกว่าศูนย์
				else
          if p_amtsoc > 0 then -- ถ้าเงินได้คำนวณประกันสังคม > 0
					   upd_tsincexp(tcontrpy_codpaypy2,'1',true,v_social);	--SS Emp.
					   upd_tsincexp(tcontrpy_codpaypy6,'1',true,v_socialc); --SS Company
          else
             v_social  := 0 ;
             v_socialc := 0 ;
          end if;
          if v_process = 'HRPY41B' then
              v_socprev  := 0 ;
              v_soccprev := 0 ;
              for i in 1..v_count loop
                  begin
                    select nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0),
                           nvl(sum(nvl(stddec(amtsoc,codempid,v_chken),0)),0)
                    into  v_tmp_socprev ,v_tmp_soccprev
                    from  ttaxcur
                    where codempid = v_ocodempid(i)
                      and	dteyrepay = b_index_dteyrepay - v_zyear
                      and ((dtemthpay < b_index_dtemthpay) or
                           ((dtemthpay = b_index_dtemthpay) and (numperiod < b_index_numperiod)));
                  exception when no_data_found then
                    v_tmp_socprev := 0;
                    v_tmp_soccprev:= 0;
                  end;
                  v_socprev  := v_socprev   + v_tmp_socprev ; -- เงินที่ต้องคำนวณประกันสังคมของพนักงานสะสม
                  v_soccprev := v_soccprev  + v_tmp_soccprev ; -- เงินที่ต้องคำนวณประกันสังคมของบริษัทสะสม
              end loop;
					else
              v_socprev  := 0 ;
              v_soccprev := 0 ;
              for i in 1..v_count loop
                  begin
                      select nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0),
                             nvl(sum(nvl(stddec(amtsoc,codempid,v_chken),0)),0)
                      into   v_tmp_socprev,v_tmp_soccprev
                      from   ttaxcur
                      where codempid = v_ocodempid(i)
                        and	dteyrepay = b_index_dteyrepay - v_zyear
                        and dtemthpay <= b_index_dtemthpay ;
                    exception when no_data_found then
                      v_tmp_socprev := 0;
                      v_tmp_soccprev := 0;
                    end;
                     v_socprev  := v_socprev  + v_tmp_socprev ;
                     v_soccprev := v_soccprev  + v_tmp_soccprev ;
                end loop;
          end if;
          v_soccurr  := v_social; -- เงินหักประกันสังคมงวดที่คำนวณ
          v_socnext  := 0;
          v_socccurr := v_socialc;
          v_soccnext := 0;
          if ((b_var_stacal = '2') and (b_index_flag = 'N')) or -- b_var_stacal = '2' ==> ลาออกระหว่างงวด
						 ((temploy1_dteeffex = b_var_dteend + 1) and (b_index_flag = 'N')) then -- b_index_flag = 'N' ==> คำนวณถึงวันที่พ้นสภาพ
						null;
					else
						begin
							select typpay	into v_typpay
							from   tinexinf
							where  codpay = tcontrpy_codpaypy2; -- รหัสเงินสมทบประกันสังคม
						exception when no_data_found then
						  v_typpay := null;
						end;
						if ( b_var_perdpay > 0 and nvl(b_var_socfix,0) > 0 and v_typpay = '4' ) and b_var_stacal <> '4'  then -- ถ้างวดที่เหลือในเดือน > 0 และเงินคำนวณประกันสังคน > 0
                            v_soccurr := v_soccurr + (((b_var_socfix / b_var_mqtypay) * b_var_perdpay)
																				* tssrate_pctsoc / 100); -- (((เงินคำนวณ ปกส / จำนวนงวดในเดือน) * จำนวนงวดที่เหลือในเดือน) * rate พนักงาน)
                            v_soccurr := least(v_soccurr,v_amtmax);
                            v_soccurr := greatest(v_soccurr,v_amtmin);
                            v_soccurr := round(round(v_soccurr,3),2);
                            v_soccurr := proc_round(tcontrpy_flgfmlsc,v_soccurr);
                            v_socccurr := v_socccurr + (((b_var_socfix / b_var_mqtypay) * b_var_perdpay)
																				* v_pctsocc / 100);
                            v_socccurr := least(v_socccurr,v_amtmaxc);
                            v_socccurr := greatest(v_socccurr,v_amtmin);
                            v_socccurr := round(round(v_socccurr,3),2);
                            v_socccurr := proc_round(tcontrpy_flgfmlsc,v_socccurr);   
						end if;
						if nvl(b_var_socfix,0) > 0 and v_typpay = '4' then
--<< user46 NXP-HR2101 08/12/2021
--				          v_period	:= (b_var_balperd - b_var_perdpay - 1) / b_var_mqtypay;
                begin
                  select count(*) -- จำนวนงวดทั้งหมดในปี
                    into v_period
                    from tdtepay
                   where codcompy         = b_var_codcompy
                     and typpayroll       = b_var_typpayroll
                     and dteyrepay        = b_index_dteyrepay - v_zyear;
                end;
-->> user46 NXP-HR2101 08/12/2021
                v_socnext := b_var_socfix * tssrate_pctsoc / 100;
                v_socnext := least(v_socnext,v_amtmax);
                v_socnext := greatest(v_socnext,v_amtmin);
                v_socnext := round(round(v_socnext,3),2);
                v_socnext := proc_round(tcontrpy_flgfmlsc,v_socnext);
--<<user46 NXP-HR2101 08/12/2021
                v_socnext := v_socnext * 12 / v_period; -- หาเงินหักประกันสังคม/งวด
                v_socfix_per := b_var_socfix * 12 / v_period; -- income cal social per period
                v_socfix_month := v_socfix_per*b_var_mqtypay; -- เงินคำนวณ ปกส.*จำนวนงวดในเดือน = เงินคำนวณ ปกส ในเดือน
                v_soc_amt := (v_socfix_month + p_amtsoc_oth) * tssrate_pctsoc / 100;
                v_soc_amt := least(v_soc_amt,v_amtmax);
                v_soc_amt := greatest(v_soc_amt,v_amtmin);
                v_soc_amt := round(round(v_soc_amt,3),2);
                v_soc_amt := proc_round(tcontrpy_flgfmlsc,v_soc_amt);
-->>user46 NXP-HR2101 08/12/2021
                v_soccnext := b_var_socfix * v_pctsocc / 100;
                v_soccnext := least(v_soccnext,v_amtmaxc);
                v_soccnext := greatest(v_soccnext,v_amtmin);
                v_soccnext := round(round(v_soccnext,3),2);
                v_soccnext := proc_round(tcontrpy_flgfmlsc,v_soccnext);
                v_soccnext := v_soccnext * 12 / v_period;--<<user46 NXP-HR2101 08/12/2021
              if v_process = 'HRPY41B' then

                 if b_var_stacal in ('4','2') then -- พ้นสภาพหรือพ้นสภาพระหว่างงวด
                    --v_socnext := v_socnext * ((12 - b_index_dtemthpay) + 1); -- ??€??”???????????—????????€????????????
                    v_socnext := 0 ;
                    v_soccnext := 0 ;
                 elsif b_var_staemp = '5' then -- ลาออกงวดนี้
                    v_socnext := 0 ;
                    v_soccnext := 0 ;
                 else
--<<user46 NXP-HR2101 09/12/2021
--                    v_socnext := v_socnext * greatest(b_var_balperd - 1,0);
                    v_socnext := v_soc_amt * (12 - b_index_dtemthpay);
-->>
                    -- v_soccnext := v_soccnext * greatest(v_period,0); comment 28/04/2022 By S
                 end if;
              else
                 if v_soccurr  > 0 then
                   v_socnext := v_socnext * (12 - b_index_dtemthpay);
                 else
                   v_socnext := v_socnext * ((12 - b_index_dtemthpay) + 1);
                 end if;
                 if v_socccurr  > 0 then
                   v_soccnext := v_soccnext * (12 - b_index_dtemthpay);
                 else
                   v_soccnext := v_soccnext * ((12 - b_index_dtemthpay) + 1);
                 end if;
              end if;
						end if;
					end if;
--<<user46 NXP-HR2101 08/12/2021
--          p_amtsocyr := v_socprev + v_soccurr + v_socnext + nvl(temploy3_amtsaid,0);
          p_amtsocyr := v_socprev + v_social + v_socnext;
-->>
          p_amtsoca := nvl(p_amtsoca,0) + v_social;
          p_amtsocc := nvl(p_amtsocc,0) + v_socialc;
					if p_amtsoca > 0 then
						for r_tssmemb in c_tssmemb loop
							update  tssmemb
							set     numsaid = temploy3_numsaid,
                      codcomp = temploy1_codcomp,
                      endmemb = b_var_dteend,
                      accmemb	= stdenc(nvl(stddec(accmemb,temploy1_codempid,v_chken),0) + nvl(p_amtsoca,0),temploy1_codempid,v_chken), -- update จำนวนเงินสมทบ
                      coduser = v_coduser
							where rowid = r_tssmemb.rowid;
					  end loop; --c_tssmemb
					end if; -- p_amtsoca > 0
				end if;
		  end if;
		else
            insert_error(get_errorm_name('PY0021',v_lang)); -- วันที่เข้างานจะต้องมีค่าน้อยกว่าวันเกิดพนักงาน
		end if;
	end if;

end;
/*
PROCEDURE cal_social(p_amtsoc		in number,
                     p_amtsoca		in out number,
                     p_amtsocc		in out number,
                     p_amtsocyr		in out number) IS

    v_year				number :=	0;
    v_month				number :=	0;
    v_day				number := 0;
    v_social			number :=	0; -- เงินประกันสังคมที่ต้องจ่าย
    v_amtmin			number :=	0;
    v_amtmax			number :=	0;
    v_amtsoc			number :=	0; -- ฐานเงินคำนวณ
    v_amtsoca			number :=	0; -- เงินประกันสังคม
    v_exist 			boolean;
    v_amtsocyr		    number :=	0;
    v_socprev			number :=	0; -- ประกันสังคมก่อนเดือนนี้
    v_socnext			number :=	0; -- ประกันสังคมเดือนที่เหลือ (ไม่รอมเดือนนี้)
    v_soccurr			number :=	0; -- ประกันสังคมเดือนนี้
    v_count				number :=	0;
    v_dteeffec		    ttmovemt.dteeffec%type := null;
    v_numbrlvl_old	    tcodsoc.numbrlvl%type;
    v_numbrlvl_new	    tcodsoc.numbrlvl%type;
    v_typpay			tinexinf.typpay%type;
    v_period			number := 0;
    v_oldempid          temploy1.codempid%type ;

  type typ_emp is table of varchar2(100) index by binary_integer;
      v_ocodempid   typ_emp;
      v_tmp_amtsoc  number:=0;
      v_tmp_amtsoca number:=0;
      v_tmp_socprev number:=0;


  cursor c_tssmemb is
    select rowid
	  from tssmemb
	  where codempid = temploy1_codempid
	  for update;

  cursor c_ttmovemt is
	  select dteeffec,codbrlc,codbrlct,codcomp,codcompt
	  from ttmovemt
	  where codempid = temploy1_codempid
	    and	dteeffec <= b_var_dteend
	    and	((codbrlct <> codbrlc) or (hcm_util.get_codcomp_level(codcompt,1) <> hcm_util.get_codcomp_level(codcomp,1)))
	  order by dteeffec desc,numseq desc;

BEGIN
	if (tcontrpy_codpaypy2 is not null) and (tcontrpy_codpaypy6 is not null) then
		if temploy1_dteempdb < temploy1_dteempmt then

      --<<Find old codempid case rehire
      v_count := 1;
      v_ocodempid(v_count) := temploy1_codempid;
      <<emp_loop>>
      loop
        begin
          select ocodempid into v_oldempid
          from temploy1
          where codempid = v_ocodempid(v_count-1);
          v_count := v_count + 1;
          v_ocodempid(v_count) := v_oldempid ;
        exception when no_data_found then
          exit emp_loop;
        end;
      end loop;
      -->>Find old codempid case rehire

      for r_ttmovemt in c_ttmovemt loop
				begin
					select numbrlvl
					into v_numbrlvl_old
					from tcodsoc
					where codcompy = b_var_codcompy
					  and codbrlc = r_ttmovemt.codbrlct;
				exception when no_data_found then
					v_numbrlvl_old := null;
				end;
				begin
					select numbrlvl
					into v_numbrlvl_new
					from tcodsoc
					where codcompy = b_var_codcompy
					  and codbrlc = r_ttmovemt.codbrlc;
				exception when no_data_found then
					v_numbrlvl_new := null;
				end;
				if (v_numbrlvl_old <> v_numbrlvl_new) or
					 (hcm_util.get_codcomp_level(r_ttmovemt.codcompt,'1') <> hcm_util.get_codcomp_level(r_ttmovemt.codcomp,'1')) then
					v_dteeffec := r_ttmovemt.dteeffec;
				end if;
				exit;
			end loop;
			if v_dteeffec is not null then
				if (trunc(months_between(v_dteeffec,temploy1_dteempdb) / 12)) +
						mod(months_between(v_dteeffec,temploy1_dteempdb),12) > tcontrpy_qtyage then
			  	return;
			  end if;
		  end if;
			if (trunc(months_between(temploy1_dteempmt,temploy1_dteempdb) / 12)) +
					mod(months_between(temploy1_dteempmt,temploy1_dteempdb),12) <= tcontrpy_qtyage then

                v_amtsoc := 0;
                v_amtsoca := 0;
                for i in 1..v_count loop
                    begin
                    select   nvl(sum(nvl(stddec(amtsoc,codempid,v_chken),0)),0),
                             nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0)
                      into  v_tmp_amtsoc ,v_tmp_amtsoca
                      from  ttaxcur
                      where codempid = v_ocodempid(i)
                        and dteyrepay = b_index_dteyrepay - v_zyear
                        and	dtemthpay = b_index_dtemthpay
                        and hcm_util.get_codcomp_level(codcomp,1) = hcm_util.get_codcomp_level(temploy1_codcomp,1) ;  -- TMG-590056 user19 21/06/2016
                        -- Case เปลี่ยนบริษัท งวดที่ 1 อยู่บริษัท  001   งวด 2 อยู่บริษัท 002  ให้หักเต็มจำนวนไม่ต้องเอาบริษัท  001 มารวม
                    exception when no_data_found then
                      v_tmp_amtsoc := 0;
                      v_tmp_amtsoca := 0;
                    end;
                    v_amtsoc  := v_amtsoc + v_tmp_amtsoc;
                    v_amtsoca := v_amtsoca + v_tmp_amtsoca ;
                end loop;

				v_amtmin := tcontrpy_amtminsoc * tssrate_pctsoc / 100;
				v_amtmax := tcontrpy_amtmaxsoc * tssrate_pctsoc / 100;
				v_social := (p_amtsoc + v_amtsoc) * tssrate_pctsoc / 100;
				if v_social > 0 then
					v_social := least(v_social,v_amtmax);
					v_social := greatest(v_social,v_amtmin);
					if tcontrpy_flgfmlsc = '2' then
						v_social := round(round(v_social,3),2);
					end if;
				  v_social := proc_round(tcontrpy_flgfmlsc,v_social);
					v_social := v_social - v_amtsoca;
				end if;
				if v_social < 0 then
					insert_error(get_errorm_name('PY0022',v_lang));
				else
					upd_tsincexp(tcontrpy_codpaypy2,'1',true,v_social);	--SS Emp.
					upd_tsincexp(tcontrpy_codpaypy6,'1',true,v_social); --SS Company
                  if v_process = 'HRPY41B' then
                      v_socprev := 0 ;
                      for i in 1..v_count loop
                          begin
                            select nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0)
                            into v_tmp_socprev
                            from ttaxcur
                            where codempid = v_ocodempid(i)
                              and	dteyrepay = b_index_dteyrepay - v_zyear
                              and ((dtemthpay < b_index_dtemthpay) or
                                   ((dtemthpay = b_index_dtemthpay) and (numperiod < b_index_numperiod)));
                          exception when no_data_found then
                            v_tmp_socprev := 0;
                          end;
                          v_socprev := v_socprev  + v_tmp_socprev ;
                      end loop;
                            else
                      v_socprev := 0 ;
                      for i in 1..v_count loop
                          begin
                              select nvl(sum(nvl(stddec(amtsoca,codempid,v_chken),0)),0)
                              into   v_tmp_socprev
                              from   ttaxcur
                              where codempid = v_ocodempid(i)
                                and	dteyrepay = b_index_dteyrepay - v_zyear
                                and dtemthpay <= b_index_dtemthpay ;
                            exception when no_data_found then
                              v_tmp_socprev := 0;
                            end;
                             v_socprev := v_socprev  + v_tmp_socprev ;
                        end loop;
                  end if;
                -->>user19 4/2/2016
                v_soccurr := v_social;
                v_socnext := 0;
                --<< user19 05/08/2016 comment พึงประเมินถึงสิ้นปี
					--if (b_var_stacal = '4') or ((b_var_stacal = '2') and (b_index_flag = 'N')) or
          if ((b_var_stacal = '2') and (b_index_flag = 'N')) or
						 ((temploy1_dteeffex = b_var_dteend + 1) and (b_index_flag = 'N')) then
						null;

					else
						begin
							select typpay	into v_typpay
							from 	 tinexinf
							where  codpay = tcontrpy_codpaypy2;
						exception when no_data_found then
						  v_typpay := null;
						end;
						if ( b_var_perdpay > 0 and nvl(b_var_socfix,0) > 0 and v_typpay = '4' ) and b_var_stacal <> '4'  then
							v_soccurr := v_soccurr + (((b_var_socfix / b_var_mqtypay) * b_var_perdpay)
																				* tssrate_pctsoc / 100);
							v_soccurr := least(v_soccurr,v_amtmax);
							v_soccurr := greatest(v_soccurr,v_amtmin);
						  v_soccurr := round(round(v_soccurr,3),2);
						  v_soccurr := proc_round(tcontrpy_flgfmlsc,v_soccurr);
						end if;
						if nvl(b_var_socfix,0) > 0 and v_typpay = '4' then --เงินสมทบกองทุนประกันสังคมแบบ estimate
							v_socnext := b_var_socfix * tssrate_pctsoc / 100;
							v_socnext := least(v_socnext,v_amtmax);
							v_socnext := greatest(v_socnext,v_amtmin);
							v_socnext := round(round(v_socnext,3),2);
						  v_socnext := proc_round(tcontrpy_flgfmlsc,v_socnext);
              if v_process = 'HRPY41B' then
					v_period	:= (b_var_balperd - b_var_perdpay - 1) / b_var_mqtypay;
                 if b_var_stacal in ('4','2') then -- ลาออกงวดก่อนหน้า
                    --v_socnext := v_socnext * ((12 - b_index_dtemthpay) + 1); -- เดือนที่เหลือ
                    v_socnext := 0 ;
                 elsif b_var_staemp = '5' then -- ทำงานเดือนสุดท้าย (ลาออก)
                    v_socnext := 0 ;
                 else
                    v_socnext := v_socnext * greatest(v_period,0);
                 end if;
              else
                 if v_soccurr  > 0 then
                   v_socnext := v_socnext * (12 - b_index_dtemthpay); -- เดือนที่เหลือ
                 else
                   v_socnext := v_socnext * ((12 - b_index_dtemthpay) + 1); -- เดือนที่เหลือ + เดือนปัจจุบัน
                 end if;

              end if;
						end if;
					end if;
                    p_amtsocyr := v_socprev + v_soccurr + v_socnext + nvl(temploy3_amtsaid,0);
					p_amtsoca := nvl(p_amtsoca,0) + v_social;
					p_amtsocc := nvl(p_amtsocc,0) + v_social;
					if p_amtsoca > 0 then
						v_exist := false;
						for r_tssmemb in c_tssmemb loop
							v_exist	:= true;
							update tssmemb
							set numsaid = temploy3_numsaid,
									codcomp = temploy1_codcomp,
								 	endmemb = b_var_dteend,
				  				accmemb	= stdenc(nvl(stddec(accmemb,temploy1_codempid,v_chken),0) + nvl(p_amtsoca,0),temploy1_codempid,v_chken),
								 	coduser = v_coduser
							where rowid = r_tssmemb.rowid;
					  end loop; --c_tssmemb
					end if; -- p_amtsoca > 0
				end if;
		  end if;
		else
      insert_error(get_errorm_name('PY0021',v_lang));
		end if;
	end if;
end;
*/
procedure cal_estimate (p_estimate out number,
	                      p_divice		in out number) is -- Review code ส่วนนี้อีกครั้งตาม Requirement

    v_dteeffex		date;
    v_dteyrepay		number;
    v_dtemthpay		number;
    v_numperiod		number;
    v_dtestrt		date;
    v_dteend		date;
    v_stperd		varchar2(30);
    v_enperd		varchar2(30);
    v_cntperd		number;

    cursor c_ttpminf is
        select dteeffec
          from ttpminf
         where codempid	=	temploy1_codempid
           and dteeffec	> b_var_dteend + 1
           and dteeffec <= to_date('0101'||((b_index_dteyrepay - v_zyear) + 1),'ddmmyyyy')
           and codtrn   =	'0006'
        order by dteeffec desc,numseq desc;

BEGIN
	---if b_index_flag = 'N' then
  if b_var_staemp = '5' then -- ลาออกงวดนี้
    for r_ttpminf in c_ttpminf loop
        v_dteeffex        := r_ttpminf.dteeffec;
        temploy1_dteeffex := v_dteeffex;
        exit;
    end loop;
		--if v_dteeffex is null then
    if temploy1_dteeffex is null then
        goto next_loop;
    end if;

    v_dteeffex := temploy1_dteeffex ;
    begin -- ขัดแย้งกับ b_var_staemp = 5
        select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
          into v_dteyrepay,v_dtemthpay,v_numperiod,v_dtestrt,v_dteend
          from tdtepay
         where codcompy	  = b_var_codcompy
           and typpayroll = b_var_typpayroll
           and dteyrepay  = b_index_dteyrepay - v_zyear
           and (v_dteeffex - 1) between dtestrt and dteend
           and rownum = 1  ;
    exception when no_data_found then
        goto next_loop;
    end;
    v_stperd := (b_index_dteyrepay - v_zyear)||lpad(b_index_dtemthpay,2,'0')||lpad(b_index_numperiod,2,'0'); -- ปีเดือนงวดที่คำนวณ
    v_enperd := v_dteyrepay||lpad(v_dtemthpay,2,'0')||lpad(v_numperiod,2,'0'); -- ปีเดือนงวดที่ลาออก
    select count(codcompy) into v_cntperd
      from tdtepay
     where codcompy	  = b_var_codcompy
       and typpayroll = b_var_typpayroll
       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') > v_stperd
       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') < v_enperd;

    p_estimate := ((b_var_amtcal / b_var_mqtypay) * v_cntperd) + -- cal งวดที่เหลือ
                                ((b_var_amtcal / b_var_mqtypay) * ((v_dteeffex - 1) - v_dtestrt ) / 30); -- cal งวดสุดท้าย
    -- คำนวณรายได้เดือนที่เหลือ  =  ((รายได้ประจำต่อเดือน / งวดการจ่ายต่อเดือน ) * งวดที่เหลือ ) + รายได้เดือนสุดท้าย (คำนวณ Prorate ตามจำนวน วันทำงาน )

  <<next_loop>>
  null;
	end if;
end;

PROCEDURE cal_amtnet (  p_amtincom  in number,
                        p_amtsalyr  in number,  -- เงินได้พึงประเมิน
                        p_amtproyr	in number,  -- เงินสะสมกองทุนทั้งปี (รวม Estimate)
                        p_amtsocyr  in number,  -- เงินประกันสังคมทั้งปี (รวม Estimate)
                        p_amtnet	out number) is

    v_formula 	varchar2(1000);
    v_fmlmax 		varchar2(1000);
    v_check 		varchar2(100);
    v_maxseq 		number(3);
    v_chknum		number(20);
    v_amt			  number;
    v_stmt		 	varchar2(2000);

  cursor c_proctax is
		select numseq,formula,fmlmax,fmlmaxtot,desproce,desproct,desproc3,desproc4,desproc5
		from tproctax -- HRPY19E บันทึกวิธีคำนวณเงินได้สุทธิ
		where codcompy = b_var_codcompy
          and dteyreff = (select max(dteyreff)
		                  from tproctax
		                  where codcompy = b_var_codcompy
                            and dteyreff <= b_index_dteyrepay - v_zyear)
		order by numseq;

BEGIN
	--if 1 = 2 then --- for test
    if nvl(declare_var_v_amtexp,1) = nvl(declare_var_v_maxexp,2) then
		p_amtnet := p_amtincom - declare_var_v_amtdiff;
    else
        p_amtnet := p_amtincom;
        for r_proctax in c_proctax loop
		  if r_proctax.numseq = 1 then  		------- 1. เงินได้พึงประเมินสำหรับคำนวณภาษี
              v_formula := to_char(p_amtincom);
		  else
		  	if r_proctax.formula is not null then
		  		v_formula := r_proctax.formula;
                v_amt     := 0;
                if instr(v_formula,'[') > 0 then
                    loop 	--- หาจำนวนเงิน ในกรณีที่ สูตรมาจากรหัสยกเว้น/ลดหย่อน
                        v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
                    exit when v_check is null;
                        if v_check in ('E001','D001') then --- เงินสะสมกองทุนสำรองเลี้ยงชีพ
                            v_amt := v_amt + gtempded(temploy1_codempid,v_check,'1',p_amtproyr,p_amtsalyr);
                        elsif v_check = 'D002' then --- เงินสะสมกองทุนประกันสังคม
                            v_amt := v_amt + gtempded(temploy1_codempid,v_check,'1',p_amtsocyr,p_amtsalyr);
                        else
                            v_amt := v_amt + gtempded(temploy1_codempid,v_check,'1',0,p_amtsalyr);
                            if temploy1_stamarry = 'M' and temploy3_typtax = '2' then
                                v_amt := v_amt + gtempded(temploy1_codempid,v_check,'2',0,p_amtsalyr);
                            end if;
                        end if;
                        v_formula := replace(v_formula,'{['||v_check||']}',v_amt);
                    end loop;
                    v_formula := to_char(v_amt);
                end if;
                if instr(v_formula,'}') > 1 then
                    loop --- หาจำนวนเงิน ในกรณีที่ สูตรมาจาก seq
                        v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
                    exit when v_check is null;
                        v_formula := replace(v_formula,'{item'||v_check||'}',declare_var_v_text(v_check));
                    end loop;
                end if;
                -- check จำนวนเงิน หรือสูตร สุงสุด
                if v_formula <> '0' then
                    if temploy3_typtax = '1' then -- กรณีแยกยื่น
                        v_fmlmax := r_proctax.fmlmax;
                    else
                        v_fmlmax := r_proctax.fmlmaxtot;
                    end if;
                    if v_fmlmax is not null then
                        v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                        begin
                            v_chknum := nvl(to_number(v_fmlmax),0);   --ถ้าเป็นจำนวนเงิน
                            if v_chknum > 0 then
                                v_formula := to_char(least(v_amt,v_chknum));
                            end if;
                        exception when others then  --- ถ้าเป็น formula
                            if instr(v_fmlmax,'[') > 0 then
                                loop --- หาจำนวนเงิน ในกรณีที่ สูตรมาจาก codededuct
                                    v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                                exit when v_check is null;
                                    if get_deduct(v_check) = 'E' then
                                        v_fmlmax := replace(v_fmlmax,'{['||v_check||']}',nvl(declare_var_evalue_code(substr(v_check,2)),0));
                                    elsif get_deduct(v_check) = 'D' then
                                        v_fmlmax := replace(v_fmlmax,'{['||v_check||']}',nvl(declare_var_dvalue_code(substr(v_check,2)),0));
                                    else
                                        v_fmlmax := replace(v_fmlmax,'{['||v_check||']}',nvl(declare_var_ovalue_code(substr(v_check,2)),0));
                                    end if;
                                end loop;
                            end if;

                            if instr(v_fmlmax,'{') > 0 then
                                loop --- หาจำนวนเงิน ในกรณีที่ สูตรมาจาก seq
                                    v_check := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                                exit when v_check is null;
                                    v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',declare_var_v_text(v_check));
                                end loop;
                            end if;
                            v_chknum := execute_sql('select '||v_fmlmax||' from dual');
                            v_formula := to_char(least(v_amt,v_chknum));
                            --   declare_var_v_dataseq(r_proctax.numseq) := greatest(least(declare_var_v_dataseq(r_proctax.numseq),v_chknum),0);
                        end;
                        if r_proctax.numseq = 4 then
                            declare_var_v_amtexp := to_number(v_formula);
                            declare_var_v_maxexp := v_chknum;
                        end if;
                    end if; --end if of check v_fmlmax is not null

                end if;
            end if;-----v_formula <> 0
	    end if; --- end if of 1. เงินได้พึงประเมินสำหรับคำนวณภาษี
        declare_var_v_text(r_proctax.numseq) := '('||v_formula||')';
        v_maxseq := r_proctax.numseq;
        v_amt    := execute_sql('select '||declare_var_v_text(r_proctax.numseq)||' from dual');
        end loop;
        if v_maxseq <> 0 then
            v_stmt := declare_var_v_text(v_maxseq);
            p_amtnet := execute_sql('select '||v_stmt||' from dual');
            declare_var_v_amtdiff := p_amtincom - p_amtnet;
        end if;
	end if;
END;

PROCEDURE cal_amttax (p_amtnet 	in number,
                      p_flgtax	in varchar2, --1 หัก ณ ที่จ่าย, 2 บ.ออกให้
                      p_sumtax  in number,
                      p_taxa  	in number,
                      p_amttax  out number) IS

	v_dteyreff 	number;
	v_amtcal 	number;
	v_numseq 	number;
	v_amt 		number;
	v_tax1 		number := 0;
	v_tax2 		number := 0;

  cursor c_ttaxinf is
    select numseq,amtsalst,amtsalen,pcttax,nvl(amtacccal,0) amtacccal
	  from ttaxinf -- HRPY11E บันทึกตารางภาษี
	  where codcompy = b_var_codcompy
        and typincom = temploy3_typincom -- '1'
	    and dteyreff = (select max(dteyreff)
	                      from ttaxinf
	                     where codcompy = b_var_codcompy
                           and typincom = temploy3_typincom--'1'
	                       and dteyreff <= b_index_dteyrepay - v_zyear)
	    and p_amtnet between amtsalst and amtsalen;

  cursor c_ttaxinf2 is
    select numseq,amtsalst,pcttax,nvl(amtacccal,0) amtacccal
	  from ttaxinf -- HRPY11E บันทึกตารางภาษี
	  where codcompy = b_var_codcompy
        and typincom  = temploy3_typincom -- '1'
	    and dteyreff = (select max(dteyreff)
	                      from ttaxinf
	                     where codcompy = b_var_codcompy
                           and typincom = temploy3_typincom--'1'
	                       and dteyreff <= b_index_dteyrepay - v_zyear)
	    and v_amt between amtsalst and amtsalen;
BEGIN
    p_amttax := 0;
    if p_amtnet > 0 then
        /*
        if temploy3_typincom in ('3','4','5') then ---Tax fix 3% 5 % 15%
            if temploy3_typincom = '3' then
               p_amttax :=	(p_amtnet * 0.03) ;
            elsif temploy3_typincom = '4' then
               p_amttax :=	(p_amtnet * 0.05) ;
            elsif temploy3_typincom = '5' then
               p_amttax :=	(p_amtnet * 0.15) ;
            end if;
        else
        */
            for r1 in c_ttaxinf loop
                v_numseq := r1.numseq;
                v_amtcal :=	p_amtnet - r1.amtsalst + 1;
                if p_flgtax = '1' then
                    p_amttax 	:= round(v_amtcal * r1.pcttax / 100,2) + r1.amtacccal;
                else
                    p_amttax 	:= (p_sumtax * r1.pcttax / 100) /	(1 - (r1.pcttax / 100));
                    p_amttax    := p_amttax + p_sumtax;
                    v_amt 		:= p_amtnet + p_amttax;
                    if v_amt not between r1.amtsalst and r1.amtsalen then
                        for r2 in c_ttaxinf2 loop
                            v_amtcal :=	p_amtnet - r2.amtsalst + 1;
                            v_tax1   := (v_amtcal * r2.pcttax / 100) + r2.amtacccal;
                            v_tax2   := v_tax1 - p_taxa;
                            p_amttax :=	(v_tax2 * r2.pcttax / 100) / (1 - (r2.pcttax / 100));
                            p_amttax := p_amttax + v_tax2;
                        end loop;
                    end if;
                end if;
            end loop;
        --end if;
    end if;
END;

FUNCTION gtempded ( v_empid     varchar2,
                    v_codeduct 	varchar2,
                    v_type 		  varchar2,
                    v_amtcode 	number,
                    p_amtsalyr 	number) return number IS

    v_amtdeduct 	number ;--(14,2);
    v_amtdemax		tdeductd.amtdemax%type;
    v_pctdemax		tdeductd.pctdemax%type;
    v_formula		  varchar2(1000);--tdeductd.formula%type;
    v_pctamt 		  number; --(14,2);
    v_check  		  varchar2(20);
    v_typeded  		varchar2(1);

begin
  v_amtdeduct := v_amtcode;
  if v_amtdeduct = 0 then  --- กรณีที่ จำนวนเงินไม่ได้คำนวณมาจากระบบ
	  begin
	  	select decode(v_type,'1',stddec(amtdeduct,codempid,v_chken),stddec(amtspded,codempid,v_chken))
	  	into v_amtdeduct
	  	from tempded
	  	where codempid = v_empid
          and coddeduct = v_codeduct;
	  exception when others then
	  	v_amtdeduct := 0;
	  end;
  end if;  --end if  v_amtdeduct = 0
  if v_amtdeduct > 0 then
		begin
	    select amtdemax, pctdemax, formula
	      into v_amtdemax, v_pctdemax, v_formula
	     from tdeductd
	    where codcompy = b_var_codcompy
          and dteyreff = (select max(dteyreff)
	                      from tdeductd
	                      where codcompy = b_var_codcompy
                            and dteyreff <= b_index_dteyrepay - v_zyear
	                        and coddeduct = v_codeduct)
	      and coddeduct = v_codeduct;
	  exception when others then
	    v_amtdemax := null;
	  	v_pctdemax := null;
	  	v_formula := null;
	  end;
	  --  Check amt max
		if (v_amtdemax > 0) then
			if v_codeduct = 'E001' then ---- เงินสะสมกองทุนสำรองเลี้ยงชีพ
			  if v_amtdeduct < 10000 then
			    v_amtdeduct := 0;
			  else
			    v_amtdeduct := v_amtdeduct - 10000;
			  	v_amtdeduct := least(v_amtdeduct,v_amtdemax);
			  end if;
			elsif v_codeduct = 'D001' then
			  v_amtdeduct := least(v_amtdeduct,10000);
			else
		 	  v_amtdeduct := least(v_amtdeduct,v_amtdemax);
		  end if;
		end if;
		--  Check amt %
		if v_pctdemax > 0 then
		  v_pctamt := p_amtsalyr * (v_pctdemax / 100);
		  v_amtdeduct := least(v_amtdeduct,v_pctamt);
		end if;
  	--  Check formula ------
  	if v_formula is not null then
 		  if instr(v_formula,'[') > 1 then
				loop --- หาจำนวนเงิน ในกรณีที่ สูตรมาจาก seq
				  v_check  := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
					exit when v_check is null;
					if get_deduct(v_check) = 'E' then
						v_formula := replace(v_formula,'{['||v_check||']}',nvl(declare_var_evalue_code(substr(v_check,2)),0));
					elsif get_deduct(v_check) = 'D' then
						v_formula := replace(v_formula,'{['||v_check||']}',nvl(declare_var_dvalue_code(substr(v_check,2)),0));
					else
					  v_formula := replace(v_formula,'{['||v_check||']}',nvl(declare_var_ovalue_code(substr(v_check,2)),0));
					end if;
				end loop;
				v_amtdeduct := least(v_amtdeduct,execute_sql('select '||v_formula||' from dual'));
 			end if;
		end if;
  end if;
  v_typeded := get_deduct(v_codeduct);
	if v_typeded = 'E' then
		declare_var_evalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
	elsif v_typeded = 'D' then
		declare_var_dvalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
	else
		declare_var_ovalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
	end if;
	upd_ttaxmasd(v_codeduct,v_type,v_amtdeduct);
	return 	nvl(v_amtdeduct,0);
END;

FUNCTION get_deduct(v_codeduct varchar2) RETURN char IS
   v_type varchar2(1);
BEGIN
   select typdeduct
   into v_type
   from tcodeduct
   where coddeduct = v_codeduct;
   return (v_type);
exception when others then
	 return ('D');
END;

PROCEDURE upd_ttaxmasd (p_coddeduct	in varchar2,
                         p_typdeduct	in varchar2,
                         p_amt				in number) IS

	v_exist			boolean := false;
	v_amtdeduct	ttaxmasd.amtdeduct%type;
	v_amtspded	ttaxmasd.amtspded%type;

cursor c_ttaxmasd is
	select rowid
	from	 ttaxmasd
	where	 dteyrepay = (b_index_dteyrepay - v_zyear)
	and		 dtemthpay = b_index_dtemthpay
	and		 numperiod = b_index_numperiod
	and		 codempid	 = temploy1_codempid
	and		 coddeduct = p_coddeduct;
BEGIN
	if p_typdeduct = '1' then
		v_amtdeduct := stdenc(p_amt,temploy1_codempid,v_chken);
		v_amtspded	:= null;
	else
		v_amtdeduct := null;
		v_amtspded	:= stdenc(p_amt,temploy1_codempid,v_chken);
	end if;
  for r_ttaxmasd in c_ttaxmasd loop
        v_exist := true;
        update ttaxmasd
            set	 amtdeduct = nvl(v_amtdeduct,amtdeduct),
                     amtspded  = nvl(v_amtspded,amtspded),
                     coduser	= v_coduser
            --where rowid = r_ttaxmasd.rowid;
        where	 dteyrepay = (b_index_dteyrepay - v_zyear)
        and		 dtemthpay = b_index_dtemthpay
        and		 numperiod = b_index_numperiod
        and		 codempid	 = temploy1_codempid
        and		 coddeduct = p_coddeduct;    
  end loop;
  if not v_exist then
  	insert into ttaxmasd
  		(dteyrepay,dtemthpay,numperiod,
  		 codempid,coddeduct,
  		 amtdeduct,amtspded,coduser)
  	values
  		((b_index_dteyrepay - v_zyear),b_index_dtemthpay,b_index_numperiod,
  		 temploy1_codempid,p_coddeduct,
  		 nvl(v_amtdeduct,stdenc(0,temploy1_codempid,v_chken)),
  		 nvl(v_amtspded,stdenc(0,temploy1_codempid,v_chken)),
  		 v_coduser);
  end if;
END;

procedure get_parameter (pb_var_codempid      in varchar2,
                         pb_var_codcompy      in varchar2,
                         pb_var_typpayroll    in varchar2,
                         pb_var_dtebeg        in varchar2,
                         pb_var_dteend        in varchar2,
                         pb_var_ratechge      in number,
                         pb_var_mqtypay       in number,
                         pb_var_balperd       in  number,
                         pb_var_perdpay       in number,
                         pb_var_stacal        in varchar2,
                         pb_var_amtcal        in number,
                         pb_var_dteyreff      in number,
                         pb_var_socfix        in number,
                         pb_var_profix        in number,
                         pb_var_tempinc       in number,
                         pb_var_flglast       in varchar2,
                         pb_index_numperiod   in number,
                         pb_index_dtemthpay   in number,
                         pb_index_dteyrepay   in number,
                         pb_index_codempid    in varchar2,
                         pb_index_codcomp     in varchar2,
                         pb_index_newflag     in varchar2,
                         pb_index_flag        in varchar2,
                         pb_index_flgretro    in varchar2,
                         ptcontpm_codcurr     in varchar2,
                         ptcontrpy_flgfmlsc   in varchar2,
                         ptcontrpy_flgfml     in varchar2,
                         ptcontrpy_codpaypy1  in varchar2,
                         ptcontrpy_codpaypy2  in varchar2,
                         ptcontrpy_codpaypy3  in varchar2,
                         ptcontrpy_codpaypy4  in varchar2,
                         ptcontrpy_codpaypy5  in varchar2,
                         ptcontrpy_codpaypy6  in varchar2,
                         ptcontrpy_codpaypy7  in varchar2,
                         ptcontrpy_codpaypy8  in varchar2,
                         ptcontrpy_codtax     in varchar2,
                         ptcontrpy_amtminsoc  in number,
                         ptcontrpy_amtmaxsoc  in number,
                         ptcontrpy_qtyage     in number,
                         ptcontpms_codincom1  in varchar2,
                         ptcontpms_codincom2  in varchar2,
                         ptcontpms_codincom3  in varchar2,
                         ptcontpms_codincom4  in varchar2,
                         ptcontpms_codincom5  in varchar2,
                         ptcontpms_codincom6  in varchar2,
                         ptcontpms_codincom7  in varchar2,
                         ptcontpms_codincom8  in varchar2,
                         ptcontpms_codincom9  in varchar2,
                         ptcontpms_codincom10 in varchar2,
                         ptcontpms_codretro1  in varchar2,
                         ptcontpms_codretro2  in varchar2,
                         ptcontpms_codretro3  in varchar2,
                         ptcontpms_codretro4  in varchar2,
                         ptcontpms_codretro5  in varchar2,
                         ptcontpms_codretro6  in varchar2,
                         ptcontpms_codretro7  in varchar2,
                         ptcontpms_codretro8  in varchar2,
                         ptcontpms_codretro9  in varchar2,
                         ptcontpms_codretro10 in varchar2,
                         ptpfhinf_dteeffec    in varchar2,
                         ptssrate_pctsoc      in number,
                         pv_coduser           in varchar2,
                         pv_lang              in varchar2) IS

begin

    b_var_codempid     := pb_var_codempid;
    b_var_codcompy     := pb_var_codcompy;
    b_var_typpayroll   := pb_var_typpayroll;

    b_var_dtebeg       := to_date(pb_var_dtebeg,'dd/mm/yyyy');
    b_var_dteend       := to_date(pb_var_dteend,'dd/mm/yyyy');
    b_var_ratechge     := pb_var_ratechge;
    b_var_mqtypay      := pb_var_mqtypay;
    b_var_balperd      := pb_var_balperd;
    b_var_perdpay      := pb_var_perdpay;
    b_var_stacal       := pb_var_stacal;
    b_var_amtcal       := pb_var_amtcal;
    b_var_dteyreff     := pb_var_dteyreff;
    b_var_socfix       := pb_var_socfix;
    b_var_profix       := pb_var_profix;
    b_var_tempinc      := pb_var_tempinc;
    b_var_flglast      := pb_var_flglast;

    b_index_numperiod  := pb_index_numperiod;
    b_index_dtemthpay  := pb_index_dtemthpay;
    b_index_dteyrepay  := pb_index_dteyrepay;
    b_index_codempid   := pb_index_codempid;
    b_index_codcomp    := pb_index_codcomp;
    b_index_newflag    := pb_index_newflag;
    b_index_flag       := pb_index_flag;
    b_index_flgretro   := pb_index_flgretro;
    tcontpm_codcurr    := ptcontpm_codcurr;
    tcontrpy_flgfmlsc  := ptcontrpy_flgfmlsc;
    tcontrpy_flgfml    := ptcontrpy_flgfml;
    tcontrpy_codpaypy1 := ptcontrpy_codpaypy1;
    tcontrpy_codpaypy2 := ptcontrpy_codpaypy2;
    tcontrpy_codpaypy3 := ptcontrpy_codpaypy3;
    tcontrpy_codpaypy4 := ptcontrpy_codpaypy4;
    tcontrpy_codpaypy5 := ptcontrpy_codpaypy5;
    tcontrpy_codpaypy6 := ptcontrpy_codpaypy6;
    tcontrpy_codpaypy7 := ptcontrpy_codpaypy7;
    tcontrpy_codpaypy8 := ptcontrpy_codpaypy8;
    tcontrpy_codtax    := ptcontrpy_codtax;
    tcontrpy_amtminsoc := ptcontrpy_amtminsoc;
    tcontrpy_amtmaxsoc := ptcontrpy_amtmaxsoc;
    tcontrpy_qtyage    := ptcontrpy_qtyage;
    tcontpms_codincom1  := ptcontpms_codincom1;
    tcontpms_codincom2  := ptcontpms_codincom2;
    tcontpms_codincom3  := ptcontpms_codincom3;
    tcontpms_codincom4  := ptcontpms_codincom4;
    tcontpms_codincom5  := ptcontpms_codincom5;
    tcontpms_codincom6  := ptcontpms_codincom6;
    tcontpms_codincom7  := ptcontpms_codincom7;
    tcontpms_codincom8  := ptcontpms_codincom8;
    tcontpms_codincom9  := ptcontpms_codincom9;
    tcontpms_codincom10 := ptcontpms_codincom10;
    tcontpms_codretro1  := ptcontpms_codretro1;
    tcontpms_codretro2  := ptcontpms_codretro2;
    tcontpms_codretro3  := ptcontpms_codretro3;
    tcontpms_codretro4  := ptcontpms_codretro4;
    tcontpms_codretro5  := ptcontpms_codretro5;
    tcontpms_codretro6  := ptcontpms_codretro6;
    tcontpms_codretro7  := ptcontpms_codretro7;
    tcontpms_codretro8  := ptcontpms_codretro8;
    tcontpms_codretro9  := ptcontpms_codretro9;
    tcontpms_codretro10 := ptcontpms_codretro10;
    tpfhinf_dteeffec    := to_date(ptpfhinf_dteeffec,'dd/mm/yyyy');
    tssrate_pctsoc      := ptssrate_pctsoc;
    v_coduser           := pv_coduser;
    v_lang              := pv_lang;

    if b_index_dteyrepay > 2500 then
       v_zyear  := 543;
    else
       v_zyear  := 0;
    end if;
    if v_coduser is not null then
        begin
         select get_numdec(numlvlsalst,v_coduser) numlvlst ,get_numdec(numlvlsalen,v_coduser) numlvlen
           into v_numlvlsalst,v_numlvlsalen
           from tusrprof
          where coduser = v_coduser ;
        exception when others then
           null;
        end ;
    end if;
end;

procedure process_clearyear is

  v_chk        	varchar2(1 char);

  cursor c_temploy1 is
    select a.codempid,codcomp,numlvl,typtax,flgtax,amtincbf,amttaxbf,amtpf,amtsaid,
           amtincsp,amttaxsp,amtsasp,amtpfsp,qtychedu,qtychned,stamarry,dtebf,dtebfsp
     from temploy1 a,temploy3 b
   	where a.codempid = b.codempid
   		and a.codempid = b_var_codempid;

  cursor c_tempded is
    select coddeduct,amtdeduct,amtspded
      from tempded
     where codempid = b_var_codempid
    order by coddeduct;

begin

  for i in c_temploy1 loop
    delete tlastempd
     where dteyrepay = (b_index_dteyrepay - v_zyear)-1
       and codempid  = b_var_codempid;

      for j in c_tempded loop
        insert into tlastempd (dteyrepay,codempid,coddeduct, -- เก็บข้อมูลลดหย่อนล่าสุด
                               codcomp,amtdeduct,amtspded,
                               dteupd,coduser)
               values         ((b_index_dteyrepay - v_zyear)-1,i.codempid,j.coddeduct,
                               i.codcomp,j.amtdeduct,j.amtspded,
                               trunc(sysdate),v_coduser);
      end loop ;

		    begin
				  select 'Y' into v_chk
			      from tlastded
			     where dteyrepay = (b_index_dteyrepay - v_zyear)-1
			       and codempid  = i.codempid;
		    exception when others then
          v_chk := 'N';
			  end;
        -- เก็บข้อมูลยอดยกมา
	      if v_chk = 'N'   then
	        insert into tlastded (dteyrepay,codempid,codcomp,
                                typtax,flgtax,amtincbf,
                                amttaxbf,amtpf,amtsaid,
                                amtincsp,amttaxsp,amtsasp,
                                amtpfsp,coduser,dteupd,
                                stamarry)
				         values        ((b_index_dteyrepay - v_zyear)-1,i.codempid,i.codcomp,
                                i.typtax,i.flgtax,i.amtincbf,
                                i.amttaxbf,i.amtpf,i.amtsaid,
                                i.amtincsp,i.amttaxsp,i.amtsasp,
                                i.amtpfsp,v_coduser,trunc(sysdate),
                                i.stamarry);
	      else
	        update tlastded set codcomp   = i.codcomp,
                              typtax    = i.typtax,
                              flgtax    = i.flgtax,
                              amtincbf  = i.amtincbf,
                              amttaxbf  = i.amttaxbf,
                              amtpf     = i.amtpf,
                              amtsaid   = i.amtsaid,
                              amtincsp  = i.amtincsp,
                              amttaxsp  = i.amttaxsp,
                              amtsasp   = i.amtsasp,
                              amtpfsp   = i.amtpfsp,
                              stamarry  = i.stamarry,
                              coduser   = v_coduser,
                              dteupd    = trunc(sysdate)
			    where dteyrepay = (b_index_dteyrepay - v_zyear) - 1
			      and codempid = i.codempid;
	      end if;
  end loop;
end;

procedure round_up_amt(p_codpay 	in tinexinf.codpay%type,
                       p_amtpay 	in out number) IS
	v_flgfml			tinexinf.flgfml%type;
	v_amtpay 			number;
	v_exist				boolean;

BEGIN
  if (p_codpay is not null) and (p_amtpay <> 0) then
		begin
			select flgfml
			into v_flgfml
			from tinexinf
			where	codpay = p_codpay;
		exception when no_data_found then
		  p_amtpay := 0;
		  return;
		end;
		v_amtpay := p_amtpay ;
		if v_flgfml is not null then
		  v_amtpay	 := proc_round(v_flgfml,v_amtpay);
    end if;
		p_amtpay := v_amtpay;
	end if;
end;

PROCEDURE get_oth_ded is
cursor c_tcondept is
   select c.numseq,c.codpay, nvl(stddec(amtpay,a.codempid,v_chken),0) amtpay
   from   tsincexp a,tcondept c -- HRPY17E - บันทึกเงื่อนไขการตัดชำระหนี้
   where  temploy1_codempid = a.codempid (+)
   and    b_index_dteyrepay - v_zyear = a.dteyrepay(+)
	 and    b_index_dtemthpay = a.dtemthpay (+)
	 and    b_index_numperiod = a.numperiod (+)
   and    c.codpay    = a.codpay(+)
   and    codcompy    = b_var_codcompy
   and    dteeffec = (select max(dteeffec)
                      from   tcondept
                      where  codcompy  = b_var_codcompy
                      and    dteeffec <= sysdate )
   order by c.numseq ;

BEGIN
    v_maxded := 0 ;
    for r_tempdept in c_tcondept loop
      v_maxded := v_maxded + 1 ;
      std_tax.declare_var_dedinc(v_maxded) := r_tempdept.codpay ; -- รหัสส่วนหัก
      std_tax.declare_var_dedamt(v_maxded) := nvl(r_tempdept.amtpay,0) ; -- เงินที่หัก
    end loop;

END;

end;

/
