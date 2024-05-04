--------------------------------------------------------
--  DDL for Package Body HRAL85B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL85B_BATCH" is

procedure start_process is
	v_coduser     temploy1.coduser%type := 'AUTOBATCH';
	v_msgerror    varchar2(1000 char) := null;
  v_descerr     varchar2(1000 char) := null;
	v_status      varchar2(1 char) := 'C';
	v_numrec      number;
  v_error       varchar2(10 char);
  v_err_table	  varchar2(50 char);
  v_numrec2     number;
  v_error2      varchar2(10 char);
  v_err_table2	varchar2(50 char);
  v_sysdate     date := sysdate;
  v_dtestrt	    date := (sysdate-1);--to_date('01/01/2018','dd/mm/yyyy');--
  v_dteend      date := sysdate;--to_date('31/01/2018','dd/mm/yyyy');--

  cursor c_tcontrot is
    select codcompy
      from tcontrot
  group by codcompy
  order by codcompy;

	begin
		begin
			for r_tcontrot in c_tcontrot loop
        cal_process(null,r_tcontrot.codcompy||'%',null,null,v_dtestrt,v_dteend,v_coduser,v_numrec,v_error,v_err_table);
        gen_compensate(null,r_tcontrot.codcompy||'%',null,null,v_dtestrt,v_coduser,v_numrec2,v_error2,v_err_table2);
        commit;
      end loop;
		exception when others then
		  rollback;
		  v_status := 'E';
		  v_descerr := substr( dbms_utility.format_error_backtrace() /*sqlerrm*/,1,200);
		end;
		--
		if v_status = 'C' and v_error is null then
			v_msgerror := 'Complete: '||v_numrec;
		elsif v_error is not null then
      v_msgerror := 'Error(1): '||v_error||' '||get_errorm_name(v_error,'102')||' '||v_err_table;
    else
			v_msgerror := substr('Error(2): '||v_numrec||' '||v_descerr,1,200);
		end if;
	  --
	  begin
	  	delete tautolog where codapp = 'HRAL85B' and dtecall = v_sysdate;
		  insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
		                values('HRAL85B',v_sysdate,v_sysdate,sysdate,'C',v_numrec,v_coduser);
	  end;
	  commit;
	end; -- start_process
	--

  procedure cal_process(p_codempid	  in  varchar2,
                        p_codcomp	    in  varchar2,
                        p_codcalen	  in  varchar2,
                        p_typpayroll  in  varchar2,
                        p_dtestrt	    in  date,
                        p_dteend 	    in  date,
                        p_coduser	    in  varchar2,
                        p_numrec	    out number,
                        p_error       out varchar2,
                        p_err_table   out varchar2) is
    v_secur			  boolean;
    v_dteeffec		date;
    v_condot		  tcontrot.condot%type;
    v_condextr		tcontrot.condextr%type;
    v_numotreq		totreqd.numotreq%type;

    v_typwork_auto  tattence.typwork%type;
    v_dtestr		  date;
    v_dteend		  date;
    v_codempid		temploy1.codempid%type;
    v_codcomp 		temploy1.codcomp%type;
    v_codcomp2		temploy1.codcomp%type;
    v_codcompy   	tcompny.codcompy%type;
    v_codcalen		temploy1.codcalen%type;
    v_typpayroll	temploy1.typpayroll%type;
    v_strtw			  date;
    v_endw			  date;
    v_date			  date;
    v_dtestrtw		date;
    v_timstrtw		tattence.timstrtw%type;
    v_dteendw		  date;
    v_timendw		  tattence.timendw%type;

    v_flgworkth 	varchar2(10 char);
    v_codcalen2	 	tattence.codcalen%type;
    v_typwork   	tattence.typwork%type;

    v_chkcal		  boolean;
    v_dtein     	tattence.dtein%type;
    v_timin			  tattence.timin%type;
    v_dteout    	tattence.dteout%type;
    v_timout		  tattence.timout%type;

    r_tovrtime    tovrtime%rowtype;
    a_qtyminot    hral85b_batch.a_qtyminot;
    a_rteotpay    hral85b_batch.a_rteotpay;

    v_typot		  	varchar2(1 char);
    v_qtywkfull		tshiftcd.qtywkfull%type;
    v_timstotb		tshiftcd.timstotb%type;
    v_timenotb		tshiftcd.timenotb%type;
    v_timstotd		tshiftcd.timstotd%type;
    v_timenotd		tshiftcd.timenotd%type;
    v_timstota		tshiftcd.timstota%type;
    v_timenota		tshiftcd.timenota%type;
    v_dtestot		  date;
    v_timstot		  tattence.timstrtw%type;
    v_dteenot		  date;
    v_timenot		  tattence.timendw%type;
    v_codshift		tattence.codshift%type;
    e_codshift		tattence.codshift%type;

    v_numrec      number;
    v_error       number := 0;
    v_status      varchar2(1 char);
    v_msgerror    varchar2(1000 char) := null;
    v_sysdate     date := trunc(sysdate);
    v_qty         number := 0 ;

    cursor c_totauto is --12/02/2021
      select rowid,numotreq,codempid,codcomp,codcompw,codcalen,typwork,codshift,codappr,dteappr,dayeupd,
	           dtestrt,dteend,dtecancl,
             timstrtb,timendb,timstrtd,timendd,timstrta,timenda,qtyminb,qtymind,qtymina,
             codrem,flgchglv,codcreate,coduser
        from totreqst
       where typotreq   = '2' -- 1-by Codempid , 2-Auto
--<< user22 : ST11 : 02/11/2021 ||
	       and((p_coduser   = 'AUTOBATCH' and dtecreate  between (v_sysdate - 1) and v_sysdate)
	        or (p_coduser  <> 'AUTOBATCH' and(dtestrt    between p_dtestrt and p_dteend
                                         or nvl(dtecancl,dteend) between p_dtestrt and p_dteend
                                         or p_dtestrt  between dtestrt and nvl(dtecancl,dteend)
                                         or p_dteend   between dtestrt and nvl(dtecancl,dteend))))
          /*and(dtestrt    between p_dtestrt and p_dteend
          or nvl(dtecancl,dteend) between p_dtestrt and p_dteend
          or p_dtestrt  between dtestrt and nvl(dtecancl,dteend)
          or p_dteend   between dtestrt and nvl(dtecancl,dteend))*/
-->> user22 : ST11 : 02/11/2021 ||
         and((p_codempid is not null
         and p_codempid = (select codempid
                            from temploy1
                           where codempid    = p_codempid
                             and codcomp     like totreqst.codcomp||'%'
                             and codcalen    = nvl(totreqst.codcalen,codcalen)))
          or(p_codempid is null
         and (codcomp||'%' like p_codcomp||'%' or p_codcomp||'%' like codcomp||'%')
         and nvl(codcalen,'!@#') = nvl(p_codcalen,nvl(codcalen,'!@#'))))
      order by numotreq;


--<< user22 : ST11 : 16/08/2021 || delete tovrtime, totpaydt
    cursor c_del is
	    select codempid,dtework,typot
	      from tovrtime
       where numotreq  = v_numotreq
         and codempid  = nvl(v_codempid,codempid)
	       and codcomp   like v_codcomp||'%'
         and dtework  between v_dtestr and v_dteend
         and flgotcal  = 'N'
			   and flgadj    = 'N';
-->> user22 : ST11 : 16/08/2021 || delete tovrtime, totpaydt

    cursor c_emp is --12/02/2021
	    select codempid,dtework,codcomp--,numlvl
	      from tattence
       where codempid = nvl(v_codempid,codempid)
	       and codcomp  like v_codcomp||'%'
	       and codcalen = nvl(v_codcalen,codcalen)
         and codshift = nvl(e_codshift,codshift)
         and dtework  between v_dtestr and v_dteend
         and ----typwork  = v_typwork_auto
            ((typwork = v_typwork_auto and v_typwork_auto <> 'A')
                                       or  v_typwork_auto = 'A' or typwork = 'L') --28/02/2021
      order by codempid,dtework;

	  cursor c_totreqd is
	    select a.numotreq,a.codrem,a.codappr,a.dteappr,
	           b.rowid,b.codempid,b.dtewkreq,b.typot,b.dtestrt,b.timstrt,b.dteend,b.timend,b.qtyminr,b.codcomp,b.codcompw
	      from totreqst a, totreqd b, temploy1 c
	     where a.numotreq   = b.numotreq
	       and b.codempid   = c.codempid
	       and a.typotreq   = '1' -- 1-by Codempid , 2-Auto
	       and c.codempid   = nvl(p_codempid,c.codempid)
	       and c.codcomp    like p_codcomp||'%'
	       and c.codcalen   = nvl(p_codcalen,c.codcalen)
	       and c.typpayroll = nvl(p_typpayroll,c.typpayroll)
	       and((p_coduser   = 'AUTOBATCH' and b.dayeupd   is null
	                                      and b.dtewkreq  <= v_sysdate)--user22 : ST11 : 17/01/2022 ||  and b.dtecreate between (v_sysdate - 1) and v_sysdate)--user22 : ST11 : 02/11/2021 || and b.dtewkreq  <= v_sysdate - 1)
	        or (p_coduser  <> 'AUTOBATCH' and b.dtewkreq  between p_dtestrt and p_dteend))
	  order by a.numotreq,b.codempid,b.dtewkreq;

	begin
	  para_coduser := p_coduser;
	  p_numrec := 0;
	  if p_codempid is not null then
	    begin
	      select hcm_util.get_codcomp_level(codcomp,1)
	        into v_codcompy
	        from temploy1
	       where codempid = p_codempid;
	    exception when no_data_found then null;
	    end;
	  else
	  	v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
	  end if;

    begin
      select dteeffec,condot,condextr
        into v_dteeffec,v_condot,v_condextr
        from tcontrot
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrot
                          where codcompy = v_codcompy
                            and dteeffec <= sysdate)
         and rownum <= 1;
    exception when no_data_found then
      p_error := 'HR2010';
      p_err_table := 'TCONTROT';
      return;
    end;
    if p_coduser <> 'AUTOBATCH' then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst, get_numdec(numlvlen,p_coduser) numlvlen
          into para_zminlvl,para_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;
    --
    /*12/02/2021 cancel
    delete totpaydt a
     where exists ( select codempid
                      from tovrtime b
                     where a.codempid = b.codempid
                       and a.dtework  = b.dtework
                       and a.typot    = b.typot
                       and b.codempid in ( select codempid
                                             from temploy1
                                            where codempid   = nvl(p_codempid,codempid)
                                              and codcomp    like p_codcomp||'%'
                                              and codcalen   = nvl(p_codcalen,codcalen)
                                              and typpayroll = nvl(p_typpayroll,typpayroll))
                       and b.dtework  between p_dtestrt and p_dteend
                       and b.numotreq in (select numotreq from totreqst where typotreq = '2')
                       and b.flgotcal = 'N'
                       and b.flgadj   = 'N');
    --
    delete tovrtime
     where codempid in ( select codempid
                           from temploy1
                          where codempid   = nvl(p_codempid,codempid)
                            and codcomp    like p_codcomp||'%'
                            and codcalen   = nvl(p_codcalen,codcalen)
                            and typpayroll = nvl(p_typpayroll,typpayroll))
       and dtework  between p_dtestrt and p_dteend
       and numotreq in (select numotreq from totreqst where typotreq = '2')
       and flgotcal = 'N'
       and flgadj   = 'N';
    commit;*/
	  -- OT Auto
		for r1 in c_totauto loop
      v_numotreq := r1.numotreq; -- user22 : ST11 : 16/08/2021 || delete tovrtime, totpaydt
      v_dtestr := greatest(nvl(r1.dtestrt,p_dtestrt),p_dtestrt);
			v_dteend := least(nvl(r1.dteend,p_dteend),p_dteend);

			if v_dtestr <= v_dteend then
				v_codempid   := nvl(p_codempid,r1.codempid);
				v_codcalen   := r1.codcalen;
        e_codshift   := r1.codshift;
				if length(r1.codcomp) > length(p_codcomp) then
					v_codcomp := r1.codcomp||'%';
				else
					v_codcomp := p_codcomp||'%';
				end if;
        v_typwork_auto := r1.typwork; --12/02/2021

--<< user22 : ST11 : 16/08/2021 || delete tovrtime, totpaydt
        for r_del in c_del loop
		      v_secur := secur_main.secur2(r_del.codempid,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
		      if v_secur or p_coduser = 'AUTOBATCH' then
            delete totpaydt
             where codempid = r_del.codempid
               and dtework  = r_del.dtework
               and typot    = r_del.typot;
            --
            delete tovrtime
             where codempid = r_del.codempid
               and dtework  = r_del.dtework
               and typot    = r_del.typot;
          end if;
        end loop; -- c_del loop
-->> user22 : ST11 : 16/08/2021 || delete tovrtime, totpaydt

				for r_emp in c_emp loop
		      v_secur := secur_main.secur2(r_emp.codempid,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal); --12/02/2021 ||secur_main.secur1(r_emp.codcomp,r_emp.numlvl,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
		      if v_secur or p_coduser = 'AUTOBATCH' then
            v_codcompy := hcm_util.get_codcomp_level(r_emp.codcomp,1);
            v_date := r_emp.dtework; --12/02/2021
            /*--12/02/2021
            v_date     := v_dtestr;
	          loop*/

	            begin
	              select dtestrtw,timstrtw,dteendw,timendw,typwork,codcalen,dtein,timin,dteout,timout,codshift,codcomp
	                into v_dtestrtw,v_timstrtw,v_dteendw,v_timendw,v_typwork,v_codcalen2,v_dtein,v_timin,v_dteout,v_timout,v_codshift,v_codcomp2
	                from tattence
	               where codempid = r_emp.codempid
	                 and dtework  = v_date
	                 /*--12/02/2021 cancel
                   and codshift = nvl(r1.codshift,codshift)
	                 and((nvl(r1.typwork,'@#$') <> 'A' and typwork = r1.typwork)
	                  or (r1.typwork = 'A'))*/
                    ;

	              v_strtw := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||v_timstrtw,'dd/mm/yyyyhh24mi');
	              v_endw  := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');

	              begin
	                select timstotb,timenotb,timstotd,timenotd,timstota,timenota,qtywkfull
	                  into v_timstotb,v_timenotb,v_timstotd,v_timenotd,v_timstota,v_timenota,v_qtywkfull
	                  from tshiftcd
	                 where codshift = v_codshift;
	              exception when no_data_found then
	                v_timstotb := null; v_timenotb := null;
	                v_timstotd := null; v_timenotd := null;
	                v_timstota := null; v_timenota := null; v_qtywkfull := null;
	              end;
	              if r1.timstrtd is not null or r1.qtymind > 0 then
	                v_typot   := 'D';
	                if r1.qtymind > 0 then
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := null;
		                v_timenot := null;
	                else
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := nvl(r1.timstrtd,v_timstotd);
		                v_timenot := nvl(r1.timendd,v_timenotd);

		                v_dtestot := v_date;
		                if v_timstot >= v_timenot then
                      v_dteenot := v_dtestot + 1;
		                else
                      v_dteenot := v_dtestot;
		                end if;
                    --
                    v_dtestot := to_date(to_char(v_dtestot,'dd/mm/yyyy')||v_timstot,'dd/mm/yyyyhh24mi');
                    v_dteenot := to_date(to_char(v_dteenot,'dd/mm/yyyy')||v_timenot,'dd/mm/yyyyhh24mi');
                    if v_strtw between v_dtestot and v_dteenot
                    or v_endw  between v_dtestot and v_dteenot
                    or v_dtestot between v_strtw and v_endw
                    or v_dteenot between v_strtw and v_endw then
                      null;
                    else
                      v_dtestot := v_dtestot - 1;
                      v_dteenot := v_dteenot - 1;

                      if v_strtw between v_dtestot and v_dteenot
                      or v_endw between v_dtestot and v_dteenot
                      or v_dtestot between v_strtw and v_endw
                      or v_dteenot between v_strtw and v_endw then
                        null;
                      else
                        v_dtestot := v_dtestot + 2;
                        v_dteenot := v_dteenot + 2;

                        if v_strtw between v_dtestot and v_dteenot
                        or v_endw between v_dtestot and v_dteenot
                        or v_dtestot between v_strtw and v_endw
                        or v_dteenot between v_strtw and v_endw then
                          null;
                        end if;
                      end if;
                    end if;
                  end if;	-- r1.qtymind > 0
                  --
                  /*12/02/2021 cancel
                  begin
                    insert into totreqd(numotreq,dtewkreq,codempid,typot,codcomp,codcompw,codcalen,codshift,dtestrt,timstrt,dteend,timend,flgchglv,qtyminr,dayeupd,dtecreate,codcreate,dteupd,coduser)
                                 values(r1.numotreq,v_date,r_emp.codempid,v_typot,v_codcomp2,r1.codcompw,v_codcalen2,v_codshift,
                                        v_dtestot,v_timstot,v_dteenot,v_timenot,r1.flgchglv,r1.qtymind,null,sysdate,r1.codcreate,sysdate,r1.coduser);
                  end;*/
                  --
	                v_chkcal := check_ot(r_emp.codempid,v_date,v_typot);
	                if v_chkcal then
	                  InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'D',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                  --
	                  cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                r1.numotreq,r_emp.codempid,v_date,v_typot,
                                null,v_dtein,v_timin,v_dteout,v_timout,
                                v_dtestot,v_timstot,v_dteenot,v_timenot,r1.qtymind,
                                r1.codrem,r1.codappr,r1.dteappr,para_coduser,'Y',
                                r_tovrtime,a_rteotpay,a_qtyminot);
	                  --
	                  InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'A',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                end if;
	              end if;	-- r1.flgotd = 'Y'

	              if r1.timstrtb is not null or r1.qtyminb > 0 then
	                v_typot   := 'B';
	                if r1.qtyminb > 0 then
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := null;
		                v_timenot := null;
	                else
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := nvl(r1.timstrtb,v_timstotb);
		                v_timenot := nvl(r1.timendb,v_timenotb);
                    if v_timstot is not null then
                      if v_timstot > v_timstrtw then
                        v_dtestot := v_dtestrtw - 1;
                      else
                        v_dtestot := v_dtestrtw;
                      end if;
                    end if;
                    if v_timenot is not null then
                      if v_timstot >= v_timenot then
                        v_dteenot := v_dtestot + 1;
                      else
                        v_dteenot := v_dtestot;
                      end if;
                    end if;
                  end if; -- r1.qtyminb > 0
                  --
                  /*12/02/2021 cancel
                  begin
                    insert into totreqd(numotreq,dtewkreq,codempid,typot,codcomp,codcompw,codcalen,codshift,dtestrt,timstrt,dteend,timend,flgchglv,qtyminr,dayeupd,dtecreate,codcreate,dteupd,coduser)
                                 values(r1.numotreq,v_date,r_emp.codempid,v_typot,v_codcomp2,r1.codcompw,v_codcalen2,v_codshift,
                                        v_dtestot,v_timstot,v_dteenot,v_timenot,r1.flgchglv,r1.qtyminb,null,sysdate,r1.codcreate,sysdate,r1.coduser);
                  end;*/
                  --
	                v_chkcal := check_ot(r_emp.codempid,v_date,v_typot);
	                if v_chkcal then
	                  InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'D',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                  --
	                  cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                r1.numotreq,r_emp.codempid,v_date,v_typot,
                                null,v_dtein,v_timin,v_dteout,v_timout,
                                v_dtestot,v_timstot,v_dteenot,v_timenot,r1.qtyminb,
                                r1.codrem,r1.codappr,r1.dteappr,para_coduser,'Y',
                                r_tovrtime,a_rteotpay,a_qtyminot);
	                  --
	                  InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'A',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                end if;
	              end if;	-- r1.flgotb = 'Y'

	              if r1.timstrta is not null or r1.qtymina > 0 then
	                v_typot   := 'A';
	                if r1.qtyminb > 0 then
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := null;
		                v_timenot := null;
	                else
		                v_dtestot := null;
		                v_dteenot := null;
		                v_timstot := nvl(r1.timstrta,v_timstota);
		                v_timenot := nvl(r1.timenda,v_timenota);
		                if v_timstot is not null then
		                  if v_timstot <  v_timendw then
		                    v_dtestot := v_dteendw + 1;
		                  else
		                    v_dtestot := v_dteendw;
		                  end if;
                    end if;

                    if v_timenot is not null then
		                  if v_timstot >= v_timenot then
		                    v_dteenot := v_dtestot + 1;
		                  else
		                  	v_dteenot := v_dtestot;
		                  end if;
                    end if;
	                end if; -- r1.qtyminb > 0
                  --
                  /*12/02/2021 cancel
                  begin
                    insert into totreqd(numotreq,dtewkreq,codempid,typot,codcomp,codcompw,codcalen,codshift,dtestrt,timstrt,dteend,timend,flgchglv,qtyminr,dayeupd,dtecreate,codcreate,dteupd,coduser)
                                 values(r1.numotreq,v_date,r_emp.codempid,v_typot,v_codcomp2,r1.codcompw,v_codcalen2,v_codshift,
                                        v_dtestot,v_timstot,v_dteenot,v_timenot,r1.flgchglv,r1.qtymina,null,sysdate,r1.codcreate,sysdate,r1.coduser);
                  end;*/
                  --
	                v_chkcal := check_ot(r_emp.codempid,v_date,v_typot);
	                if v_chkcal then
	                  InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'D',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                  --
	                  cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                r1.numotreq,r_emp.codempid,v_date,v_typot,
                                null,v_dtein,v_timin,v_dteout,v_timout,
                                v_dtestot,v_timstot,v_dteenot,v_timenot,r1.qtymina,
                                r1.codrem,r1.codappr,r1.dteappr,para_coduser,'Y',
                                r_tovrtime,a_rteotpay,a_qtyminot);
	                  --
                    InsUpdDel_ot(r_emp.codempid,v_date,v_typot,'A',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	                end if;
	              end if;	-- r1.flgota = 'Y'
	            exception when no_data_found then
	              v_error := 2;
	            end; -- select tattence
	            /*--12/02/2021 cancel
              v_date := v_date + 1;
	            if v_date > v_dteend then
	              exit;
	            end if;
	          end loop;*/
       		end if; -- v_secur
        end loop; -- for c_emp

	      update totreqst
	         set dayeupd = v_sysdate,
	             coduser = para_coduser
	       where rowid = r1.rowid;
			end if;
		end loop; -- for c_totauto
	  commit;
		-- OT Request
		for r_totreqd in c_totreqd loop
      v_secur := secur_main.secur2(r_totreqd.codempid,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
      if v_secur or p_coduser = 'AUTOBATCH' then
				v_codcompy := hcm_util.get_codcomp_level(r_totreqd.codcomp,1);
	      v_dtein := null; v_timin := null; v_dteout := null; v_timout := null;
	      begin
	        select dtein,timin,dteout,timout
	          into v_dtein,v_timin,v_dteout,v_timout
	          from tattence
	         where codempid = r_totreqd.codempid
	           and dtework  = r_totreqd.dtewkreq;
	      exception when no_data_found then
	        v_error := 2;
	      end;
	      --
	      v_chkcal := check_ot(r_totreqd.codempid,r_totreqd.dtewkreq,r_totreqd.typot);
	      if v_chkcal then
	        InsUpdDel_ot(r_totreqd.codempid,r_totreqd.dtewkreq,r_totreqd.typot,'D',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
					--
	        cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                      r_totreqd.numotreq,r_totreqd.codempid,r_totreqd.dtewkreq,r_totreqd.typot,
                      null,v_dtein,v_timin,v_dteout,v_timout,
                      r_totreqd.dtestrt,r_totreqd.timstrt,r_totreqd.dteend,r_totreqd.timend,r_totreqd.qtyminr,
                      r_totreqd.codrem,r_totreqd.codappr,r_totreqd.dteappr,para_coduser,'Y',
                      r_tovrtime,a_rteotpay,a_qtyminot);
					--
	        InsUpdDel_ot(r_totreqd.codempid,r_totreqd.dtewkreq,r_totreqd.typot,'A',r_tovrtime,a_rteotpay,a_qtyminot,p_numrec);
	      end if;

	      update totreqd
	         set dayeupd = v_sysdate,
	             coduser = para_coduser
	       where rowid   = r_totreqd.rowid;

	      update totreqst
	         set dayeupd = v_sysdate,
	             coduser = para_coduser
	       where numotreq = r_totreqd.numotreq;
			end if; -- v_secur
		end loop; -- for c_totreqd
	  commit;
	end;
	--

	function check_ot(p_codempid varchar2,p_dtework date,p_typot varchar2) return boolean is
		v_codempid	temploy1.codempid%type;
	begin
		begin
			select codempid into v_codempid
			  from tovrtime
			 where codempid = p_codempid
			   and dtework  = p_dtework
			   and typot    = p_typot
			   and(flgotcal = 'Y'
			    or flgadj   = 'Y');
				return(false);
		exception when no_data_found then null;
		end;
		return(true);
	end;
	--

	procedure cal_time_ot( p_codcompy	  varchar2,
                         p_dteeffec		date,
                         p_condot		  varchar2,
                         p_condextr		varchar2,
                         --
                         p_numotreq		varchar2,
                         p_codempid		varchar2,
                         p_dtewkreq		date,
                         p_typot		  varchar2, --B,D,A
                         --
                         p_codshift		varchar2,
                         p_dtein		  date,			--tattence.dtein
                         p_timin		  varchar2, --tattence.timin
                         p_dteout		  date,     --tattence.dteout
                         p_timout		  varchar2, --tattence.timout
                         --
                         p_dtestrt		date,			--totreqd.dtestrt
                         p_timstrt		varchar2, --totreqd.timstrt
                         p_dteend		  date,     --totreqd.dteend
                         p_timend		  varchar2, --totreqd.timend
                         p_qtyminreq  number,
                         --
                         p_codrem		  varchar2,
                         p_codappr    varchar2,
                         p_dteappr		date,
                         p_coduser		varchar2,
                         p_chkwkfull  varchar2,-- N = For hral42u Only, Y = else other heal4ke,hral85b
                         --
                         p_tovrtime   out tovrtime%rowtype,
                         p_rteotpay   out a_rteotpay,
                         p_qtyminot   out a_qtyminot) is

	rt_tshiftcd 	tshiftcd%rowtype;
	v_cond			  tcontrot.condot%type;
  v_stmt      	varchar2(1000);
  v_flgfound  	boolean;
  v_flgot			  boolean;
  v_meal			  boolean;

  v_dtemovemt		date;
  v_staemp  		temploy1.staemp%type;
  v_codcomp			temploy1.codcomp%type;
  v_codpos			temploy1.codpos%type;
  v_numlvl			temploy1.numlvl%type;
  v_codjob			temploy1.codjob%type;
  v_codempmt		temploy1.codempmt%type;
  v_typemp			temploy1.typemp%type;
  v_typpayroll	temploy1.typpayroll%type;
  v_codbrlc	  	temploy1.codbrlc%type;
  v_codcalen		temploy1.codcalen%type;
  v_jobgrade		temploy1.jobgrade%type;
  v_codgrpgl		temploy1.codgrpgl%type;
  v_amtincom1   temploy3.amtincom1%type;
  --v_codcurr		  temploy3.codcurr%type;
  v_codshift  	tattence.codshift%type;
	v_typwork		  tattence.typwork%type;
	v_typworknxt	tattence.typwork%type;
	v_strtw			  date;
	v_endw  		  date;
 	v_dtestrtw		tattence.dtestrtw%type;
 	v_timstrtw		tattence.timstrtw%type;
 	v_dteendw		  tattence.dteendw%type;

 	v_timendw		  tattence.timendw%type;
	v_dtein     	tattence.dtein%type  := p_dtein;
	v_timin			  tattence.timin%type  := p_timin;
	v_dteout    	tattence.dteout%type := p_dteout;
	v_timout		  tattence.timout%type := p_timout;
	v_strtb			  date;
	v_endb  		  date;
	v_strtreq		  date;
	v_endreq		  date;
	v_stotb			  date;
	v_enotb			  date;
	v_stota			  date;
	v_enota			  date;

 	v_strtot		  date;
 	t_strtot		  date;
 	v_endot			  date;
 	t_endot			  date;
 	v_strtot2		  date;
 	v_endot2		  date;
 	v_qtyminall   number;
 	o_qtyminall   number;
 	t_qtyminall   number;
 	v_qtyminbk    totbreak2.qtyminbk%type;
 	t_qtyminbk    totbreak2.qtyminbk%type;
 	v_mindup	    number;
 	v_qtymin	    number;

 	v_min	    	  number;
 	i				      number;
 	ptr				    number;
 	v_typrate		  varchar2(4);
 	v_rate		    totpaydt.rteotpay%type;
 	v_flgmeal		  tovrtime.flgmeal%type;
 	v_amtmeal		  number;
 	v_ratechge		tratechg.ratechge%type;
	v_timbrk		  number := 0;
	v_zupdsal   	varchar2(4);
 	v_qtyminall2  number := 0;
 	v_qtydedbrk   number := 0;
 	v_numseq_brk  number;
 	v_numseq_rte  number;
 	v_numseq_meal number;
  v_numseq_tcontot1 number;
	v_typbreak		varchar2(1);
	v_qtyminded		number;
	v_typotreq    totreqst.typotreq%type;
	v_flgchglv    totreqst.flgchglv%type;
	v_datein	    date;
	v_dateout	    date;
	v_dedbrk	    number;
  v_qtymincal   number;
  v_qtywkfull   number;
  v_otcalflg    tcontrot.otcalflg%type;

 	type qtyminot is table of number index by binary_integer;
		v_qtyminot	qtyminot;
    v_amtincom	qtyminot;
	type rteotpay is table of number(3,2) index by binary_integer;
	  v_rteotpay  rteotpay;

	cursor c_totbreak is
		select numseq,syncond,typbreak
		  from totbreak
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
	order by numseq;

	cursor c_totratep is
		select numseq,syncond,typrate
		  from totratep
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
  order by numseq;

	cursor c_totratep2 is
		select qtyminst,qtyminen,timstrt,timend,rteotpay
		  from totratep2
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
		   and numseq   = v_numseq_rte
	order by numseq2;

	cursor c_totmeal is
		select numseq,syncond
		  from totmeal
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
	order by numseq;

	cursor c_totmeal2 is
		select amtmeal
		  from totmeal2
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
		   and numseq   = v_numseq_meal
		   and v_qtyminall between qtyminst and qtyminen
	order by numseq2;

	cursor c_tovrtime is
		select flgotcal,numotreq,flgadj,rowid
		  from tovrtime
		 where codempid = p_codempid
		   and dtework  = p_dtewkreq
		   and typot    = p_typot;

	cursor c_totpaydt is
		select rowid
		  from totpaydt
		 where codempid = p_codempid
		   and dtework  = p_dtewkreq
		   and typot    = p_typot
		   and rteotpay = v_rate;

	begin
		for i in 1..50 loop
			p_qtyminot(i) := null;
			p_rteotpay(i) := null;
			v_amtincom(i) := null;
		end loop;
		p_tovrtime := null;
		<<main_loop>>
		loop
			if v_dtein is null or v_dteout is null then
				exit main_loop;
			end if;

      v_dtemovemt := p_dtewkreq;
      std_al.get_movemt2(p_codempid,v_dtemovemt,'C','U',
                         v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                         v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                         v_amtincom1,v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
			--
			v_flgot := true;
			if p_condot is not null then
				v_cond := p_condot;
        v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
        v_cond := replace(v_cond,'V_HRAL92M1.CODJOB',''''||v_codjob||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.TYPPAYROLL',''''||v_typpayroll||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.CODBRLC',''''||v_codbrlc||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.CODCALEN',''''||v_codcalen||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.CODGRPGL',''''||v_codgrpgl||'''');
        v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);
				v_stmt := 'select count(*) from dual where '||v_cond;
				v_flgot := execute_stmt(v_stmt);
			end if;

			v_meal := true;
			if p_condextr is not null then
				v_cond := p_condextr;
        v_cond := replace(v_cond,'V_HRAL92M2.CODCOMP',''''||v_codcomp||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.CODPOS',''''||v_codpos||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.NUMLVL',v_numlvl);
        v_cond := replace(v_cond,'V_HRAL92M2.CODJOB',''''||v_codjob||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.CODEMPMT',''''||v_codempmt||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.TYPEMP',''''||v_typemp||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.TYPPAYROLL',''''||v_typpayroll||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.CODBRLC',''''||v_codbrlc||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.CODCALEN',''''||v_codcalen||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.JOBGRADE',''''||v_jobgrade||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.CODGRPGL',''''||v_codgrpgl||'''');
        v_cond := replace(v_cond,'V_HRAL92M2.AMTINCOM1',v_amtincom1);
				v_stmt := 'select count(*) from dual where '||v_cond;
				v_meal := execute_stmt(v_stmt);
			end if;
			if not v_flgot and not v_meal then
				exit main_loop;
			end if;
			--
			begin
				select codshift,typwork,codcalen,typpayroll,
							 dtestrtw,timstrtw,dteendw,timendw
				  into v_codshift,v_typwork,v_codcalen,v_typpayroll,
							 v_dtestrtw,v_timstrtw,v_dteendw,v_timendw
				  from tattence
				 where codempid = p_codempid
				   and dtework  = p_dtewkreq;
			exception when no_data_found then exit main_loop;
			end;
			if p_codshift is not null then
				v_codshift := p_codshift;
	      begin
	        select timstrtw,timendw
	          into v_timstrtw,v_timendw
	          from tshiftcd
	         where codshift = v_codshift;
	      exception when no_data_found then exit main_loop;
	      end;
	      v_dtestrtw := p_dtewkreq;
	      if v_timstrtw > v_timendw then
		      v_dteendw := p_dtewkreq + 1;
	      else
	        v_dteendw := p_dtewkreq;
	      end if;
			end if;

			if v_typwork = 'L' then
				v_typwork := 'W';
			end if;
			--
			v_timbrk := 0;
			begin
				select * into rt_tshiftcd
				  from tshiftcd
				 where codshift = v_codshift;
			exception when no_data_found then exit main_loop;
			end;
			-- v_strtb = Start Break , v_endb = End Break
			if v_typwork = 'W' then
				if rt_tshiftcd.timstrtb is not null and rt_tshiftcd.timendb is not null then
					if v_timstrtw < rt_tshiftcd.timstrtb then
						v_strtb := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||rt_tshiftcd.timstrtb,'dd/mm/yyyyhh24mi');
					else
						v_strtb := to_date(to_char(v_dtestrtw + 1,'dd/mm/yyyy')||rt_tshiftcd.timstrtb,'dd/mm/yyyyhh24mi');
					end if;
					if rt_tshiftcd.timstrtb <= rt_tshiftcd.timendb	then
						v_endb := to_date(to_char(v_strtb,'dd/mm/yyyy')||rt_tshiftcd.timendb,'dd/mm/yyyyhh24mi');
					else
						v_endb := to_date(to_char(v_strtb + 1,'dd/mm/yyyy')||rt_tshiftcd.timendb,'dd/mm/yyyyhh24mi');
					end if;
				else
					if p_typot = 'D' then
						exit main_loop;
					end if;
				end if;
			else
				if rt_tshiftcd.timstotdb is not null and rt_tshiftcd.timenotdb is not null then
					if rt_tshiftcd.timstotd < rt_tshiftcd.timstotdb then
						v_strtb := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||rt_tshiftcd.timstotdb,'dd/mm/yyyyhh24mi');
					else
						v_strtb := to_date(to_char(v_dtestrtw + 1,'dd/mm/yyyy')||rt_tshiftcd.timstotdb,'dd/mm/yyyyhh24mi');
					end if;
					if rt_tshiftcd.timstotdb <= rt_tshiftcd.timenotdb	then
						v_endb := to_date(to_char(v_strtb,'dd/mm/yyyy')||rt_tshiftcd.timenotdb,'dd/mm/yyyyhh24mi');
					else
						v_endb := to_date(to_char(v_strtb + 1,'dd/mm/yyyy')||rt_tshiftcd.timenotdb,'dd/mm/yyyyhh24mi');
					end if;
					v_timbrk := round((v_endb - v_strtb) * 1440,0);
				end if;
			end if;

			-- v_stotb = Start OT Before , v_enotb = End OT Before
			if v_timendw >= rt_tshiftcd.timenotb then
				v_enotb := to_date(to_char(v_dteendw,'dd/mm/yyyy')||rt_tshiftcd.timenotb,'dd/mm/yyyyhh24mi');
			else
				v_enotb := to_date(to_char(v_dteendw - 1,'dd/mm/yyyy')||rt_tshiftcd.timenotb,'dd/mm/yyyyhh24mi');
			end if;
			if rt_tshiftcd.timenotb >= rt_tshiftcd.timstotb then
				v_stotb := to_date(to_char(v_enotb,'dd/mm/yyyy')||rt_tshiftcd.timstotb,'dd/mm/yyyyhh24mi');
			else
				v_stotb := to_date(to_char(v_enotb - 1,'dd/mm/yyyy')||nvl(rt_tshiftcd.timstotb,v_timin),'dd/mm/yyyyhh24mi');
			end if;

			-- v_stota = Start OT After , v_enota = End OT After
			if v_timstrtw <= rt_tshiftcd.timstota then
		  	v_stota := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||rt_tshiftcd.timstota,'dd/mm/yyyyhh24mi');
			else
		  	v_stota := to_date(to_char(v_dtestrtw + 1,'dd/mm/yyyy')||rt_tshiftcd.timstota,'dd/mm/yyyyhh24mi');
			end if;
			if rt_tshiftcd.timstota <= rt_tshiftcd.timenota then
		  	v_enota := to_date(to_char(v_stota,'dd/mm/yyyy')||rt_tshiftcd.timenota,'dd/mm/yyyyhh24mi');
			else
		  	v_enota := to_date(to_char(v_stota + 1,'dd/mm/yyyy')||nvl(rt_tshiftcd.timenota,v_timout),'dd/mm/yyyyhh24mi');
			end if;

			-- v_strtw = Start OT During , v_endw= End OT During
		  if p_typot = 'D' then
		  	v_strtw := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||rt_tshiftcd.timstotd,'dd/mm/yyyyhh24mi');
		  	if rt_tshiftcd.timstotd > rt_tshiftcd.timenotd then
			  	v_endw := to_date(to_char(v_dtestrtw + 1,'dd/mm/yyyy')||rt_tshiftcd.timenotd,'dd/mm/yyyyhh24mi');
		  	else
			  	v_endw := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||rt_tshiftcd.timenotd,'dd/mm/yyyyhh24mi');
		  	end if;
		  else
		  	v_strtw := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||v_timstrtw,'dd/mm/yyyyhh24mi');
		  	v_endw  := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');
		  end if;

			-- v_strtot = Time In , v_endot = Time Out
			v_strtot  := to_date(to_char(v_dtein,'dd/mm/yyyy')||v_timin,'dd/mm/yyyyhh24mi');
			v_endot   := to_date(to_char(v_dteout,'dd/mm/yyyy')||v_timout,'dd/mm/yyyyhh24mi');
			if p_typot = 'B' then
				if v_strtot < v_strtw and v_strtot < v_enotb then
					if v_strtot < v_stotb then
						v_strtot := v_stotb;
					end if;
					if v_endot > v_enotb then
						v_endot := v_enotb;
					end if;
				else
					exit main_loop;
				end if;
			elsif p_typot = 'D' then
				if v_typwork in ('H','S','T') then
--<< user22 : 29/09/2021 :
          begin
            select otcalflg
              into v_otcalflg
              from tcontrot
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec;
          exception when no_data_found then null;
          end;
					if v_otcalflg = '1' then
-->> user22 : 29/09/2021 :
            if v_strtot > v_endw or v_endot < v_strtw then
              exit main_loop;
            end if;
            if v_strtot < v_strtw then
              v_strtot := v_strtw;
            end if;
            if v_endot > v_endw then
              v_endot := v_endw;
            end if;
					end if;
				else
					if v_strtot > v_endb or v_endot < v_strtb then
						exit main_loop;
					end if;
					if v_strtot < v_strtb then
						v_strtot := v_strtb;
					end if;
					if v_endot > v_endb then
						v_endot := v_endb;
					end if;
					v_timbrk := 0;
				end if;
			elsif p_typot = 'A' then
        -- Check Time Start After Case Late
        if nvl(p_chkwkfull,'Y') <> 'N' and rt_tshiftcd.qtywkfull > 0 then
          v_qtywkfull := rt_tshiftcd.qtywkfull;-- = 8

          /*if v_stota > v_endw then
            v_qtywkfull := v_qtywkfull + nvl(round((v_stota - v_endw) * 1440),0);-- = 8 + 0.15 (18.15 - 18.00)
          end if;*/
          --
          v_datein := to_date(to_char(v_dtein,'dd/mm/yyyy')||v_timin,'dd/mm/yyyyhh24mi');
          v_datein := greatest(v_datein,v_strtw);
          --
          v_dedbrk := 0;
          if v_datein < v_strtb then
            v_dedbrk := nvl(round((v_endb - v_strtb) * 1440,0),0);
          elsif v_datein between v_strtb and v_endb then
            v_dedbrk  := nvl(round((v_endb - v_datein) * 1440,0),0);
          end if;
          v_datein := v_datein + (v_dedbrk / 1440) + (v_qtywkfull / 1440);
          v_strtot := greatest(v_strtot,v_datein);
        end if;--  p_chkwkfull = 'Y' and rt_tshiftcd.qtywkfull > 0

				if v_endot > v_endw and v_endot > v_stota then
					if v_strtot < v_stota then
						v_strtot := v_stota;
					end if;
					if v_endot > v_enota then
						v_endot := v_enota;
					end if;
				else
					exit main_loop;
				end if;

				begin
					select typwork into v_typworknxt
					  from tattence
					 where codempid = p_codempid
					   and dtework  = p_dtewkreq + 1;

					if v_typwork = 'W' and v_typworknxt = 'T' then
						v_typwork := 'U';
					elsif v_typwork = 'T' and v_typworknxt = 'W' then
						v_typwork := 'V';
					elsif v_typwork = 'W' and v_typworknxt in ('H','S','T') then
						v_typwork := 'X';
					elsif v_typwork in ('H','S','T') and v_typworknxt = 'W' then
						v_typwork := 'Y';
					end if;
				exception when no_data_found then null;
				end;
			else
				exit main_loop;
			end if;
			--
			if p_typot = 'D' and v_typwork in ('H','S','T') then
				if v_strtot >= v_strtb then
					v_timbrk := 0;
					if v_strtot < v_endb then
						v_strtot := v_endb;
					end if;
				end if;
				if v_endot <= v_endb then
					v_timbrk := 0;
					if v_endot > v_strtb then
						v_endot := v_strtb;
					end if;
				end if;
			end if;
			-- Check Time Request
			if p_dtestrt is not null then
		  	v_strtreq   := to_date(to_char(p_dtestrt,'dd/mm/yyyy')||p_timstrt,'dd/mm/yyyyhh24mi');
				if v_strtot <= v_strtreq then
					v_strtot  := v_strtreq;
				end if;
			end if;
			if p_dteend is not null then
		  	v_endreq   := to_date(to_char(p_dteend,'dd/mm/yyyy')||p_timend,'dd/mm/yyyyhh24mi');
				if v_endot >= v_endreq then
					v_endot  := v_endreq;
				end if;
			end if;
      --
			v_qtyminall := round((v_endot - v_strtot) * 1440);

      if p_typot = 'D' then
				v_qtyminall := v_qtyminall - v_timbrk;
			end if;
			-- OT Breake, Round up to Minute, OT Rate
			if v_qtyminall > 0 then
				o_qtyminall  := v_qtyminall;
				v_qtyminall2 := 0;

				for i in 1..50 loop
					p_qtyminot(i) := null;
					p_rteotpay(i) := null;
				end loop;
	      if v_flgot then
	        << totratep_loop >>
	        for r_totratep in c_totratep loop
	          v_flgfound := true;
	          if r_totratep.syncond is not null then
	            v_cond := r_totratep.syncond;
	            v_cond := replace(v_cond,'V_HRAL92M5.CODCOMP',''''||v_codcomp||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODPOS',''''||v_codpos||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.NUMLVL',v_numlvl);
	            v_cond := replace(v_cond,'V_HRAL92M5.CODJOB',''''||v_codjob||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODEMPMT',''''||v_codempmt||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.TYPEMP',''''||v_typemp||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.TYPPAYROLL',''''||v_typpayroll||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODBRLC',''''||v_codbrlc||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODCALEN',''''||v_codcalen||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.JOBGRADE',''''||v_jobgrade||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODGRPGL',''''||v_codgrpgl||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.CODSHIFT',''''||v_codshift||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.TYPWORK',''''||v_typwork||'''');
	            v_cond := replace(v_cond,'V_HRAL92M5.TYPOT',''''||p_typot||'''');
	            v_stmt := 'select count(*) from dual where '||v_cond;
	            v_flgfound := execute_stmt(v_stmt);
	          end if;

	          if v_flgfound then
--insert into  a (a) values  ( ' r_totratep.numseq '|| r_totratep.numseq) ; commit;
              v_numseq_rte := r_totratep.numseq;
	            v_qtyminall  := o_qtyminall;

              if r_totratep.typrate = 'T' then
	              v_qtyminbk   := 0;
	              v_typbreak   := null;
	              v_numseq_brk := null;
	              << totbreak_loop >>
	              for r_totbreak in c_totbreak loop
	                v_flgfound := true;
	                if r_totbreak.syncond is not null then
	                  v_cond := r_totbreak.syncond;
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODCOMP',''''||v_codcomp||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODPOS',''''||v_codpos||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.NUMLVL',v_numlvl);
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODJOB',''''||v_codjob||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODEMPMT',''''||v_codempmt||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.TYPEMP',''''||v_typemp||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.TYPPAYROLL',''''||v_typpayroll||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODBRLC',''''||v_codbrlc||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODCALEN',''''||v_codcalen||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.JOBGRADE',''''||v_jobgrade||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODGRPGL',''''||v_codgrpgl||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.CODSHIFT',''''||v_codshift||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.TYPWORK',''''||v_typwork||'''');
	                  v_cond := replace(v_cond,'V_HRAL92M4.TYPOT',''''||p_typot||'''');
	                  v_stmt := 'select count(*) from dual where '||v_cond;
	                  v_flgfound := execute_stmt(v_stmt);
	                end if;
                  if v_flgfound then
                    v_numseq_brk := r_totbreak.numseq;
                    v_typbreak   := r_totbreak.typbreak;
                    exit totbreak_loop;
                  end if;
	              end loop; -- c_totbreak
	              --
	              if v_typbreak = 'T'	then

	                for r_totratep2 in c_totratep2 loop
	                  Find_period_time('1',p_dtewkreq,v_codshift,v_strtot,v_endot,r_totratep2.timstrt,r_totratep2.timend,v_strtot2,v_endot2,v_mindup);
	                  if v_mindup > 0 then
	                    v_qtyminall := v_mindup;
	                    -- OT Breake Shift
	                    v_qtyminbk := 0;
	                    if v_strtb is not null and p_typot = 'D' and v_typwork in ('H','S','T')  then
	                      Find_period_time('2',p_dtewkreq,v_codshift,v_strtot2,v_endot2,to_char(v_strtb,'hh24mi'),to_char(v_endb,'hh24mi'),t_strtot,t_endot,v_qtyminbk);
	                      v_qtyminall := v_qtyminall - nvl(v_qtyminbk,0);
	                    end if;

	                    -- OT Breake
	                    cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot2,v_endot2,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,v_codshift,v_typwork,p_typot);--cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot2,v_endot2,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

	                    -- Round up to Minute
	                    v_qtyminall := cal_round_ot(p_codcompy,p_dteeffec,v_qtyminall,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

	                    -- OT Rate
	                    if v_qtyminall > 0 then
	                      for i in 1..50 loop
	                        if p_rteotpay(i) is null or p_rteotpay(i) = r_totratep2.rteotpay then
	                          p_rteotpay(i) := r_totratep2.rteotpay;
	                          p_qtyminot(i) := nvl(p_qtyminot(i),0) + v_qtyminall;
	                          exit;
	                        end if;
	                      end loop;
	                    end if;
	                  end if;	--v_mindup
	                end loop; --c_totratep2
	              else --v_typbreak = 'H' or v_typbreak is null then
	                t_qtyminall  := 0;
	                v_qtyminall  := 0;
	                v_numseq_rte := r_totratep.numseq;

	                for r_totratep2 in c_totratep2 loop
	                  Find_period_time('1',p_dtewkreq,v_codshift,v_strtot,v_endot,r_totratep2.timstrt,r_totratep2.timend,v_strtot2,v_endot2,v_mindup);
	                  if v_mindup > 0 then
	                    -- OT Breake Shift
	                    t_qtyminbk := 0;
	                    if v_strtb is not null and p_typot = 'D' and v_typwork in ('H','S','T') then
	                      Find_period_time('2',p_dtewkreq,v_codshift,v_strtot2,v_endot2,to_char(v_strtb,'hh24mi'),to_char(v_endb,'hh24mi'),t_strtot,t_endot,t_qtyminbk);
	                    end if;
	                    v_qtyminall := v_qtyminall + (v_mindup - nvl(t_qtyminbk,0));
	                    --
	                    for i in 1..50 loop
	                      if p_rteotpay(i) is null or p_rteotpay(i) = r_totratep2.rteotpay then
	                        p_rteotpay(i) := r_totratep2.rteotpay;
	                        p_qtyminot(i) := nvl(p_qtyminot(i),0) + (v_mindup - nvl(t_qtyminbk,0));
	                        exit;
	                      end if;
	                    end loop;
	                  end if;
	                end loop; -- c_totratep2
	                t_qtyminall := v_qtyminall;
	                --
	                if v_qtyminall > 0 then
	                  -- OT Breake
	                  cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,v_codshift,v_typwork,p_typot);--cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

	                  -- Round up to Minute
	                  v_qtyminall := cal_round_ot(p_codcompy,p_dteeffec,v_qtyminall,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

	                  -- OT Rate
	                  if v_qtyminall > 0 then null;
	                    if t_qtyminall > v_qtyminall then
	                      t_qtyminall := t_qtyminall - v_qtyminall;
	                      v_qtyminded := t_qtyminall;
	                      for i in reverse 1..50 loop
	                        if p_qtyminot(i) > 0 and t_qtyminall > 0 then
	                          v_qtyminded   := least(t_qtyminall,p_qtyminot(i));
	                          p_qtyminot(i) := p_qtyminot(i) - v_qtyminded;
	                          t_qtyminall   := t_qtyminall - v_qtyminded;
	                          if p_qtyminot(i) = 0 then
	                            p_qtyminot(i) := null;
	                            p_rteotpay(i) := null;
	                          end if;
	                        end if;
	                    	end loop;
											elsif t_qtyminall < v_qtyminall then
	                      v_qtyminded := v_qtyminall - t_qtyminall;
	                      for i in reverse 1..50 loop
	                        if p_qtyminot(i) > 0 then
	                        	p_qtyminot(i) := p_qtyminot(i) + v_qtyminded;
                            exit;
	                        end if;
	                    	end loop;
	                    end if; -- t_qtyminall <> v_qtyminall
	                  else
	                    for i in 1..50 loop
	                      p_qtyminot(i) := null;
	                      p_rteotpay(i) := null;
	                    end loop;
	                  end if;-- v_qtyminall > 0
	                end if; --v_qtyminall > 0
	              end if; --v_typbreak = 'T'
	            else --r_totratep.typrate = 'H'
	              -- OT Breake


	              cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,v_codshift,v_typwork,p_typot);--cal_break_ot(p_codcompy,p_dteeffec,null,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

	              -- Round up to Minute
	              v_qtyminall := cal_round_ot(p_codcompy,p_dteeffec,v_qtyminall,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);
	              -- OT Rate
	              v_qtymin := trunc(v_qtyminall);
	              v_numseq_rte := r_totratep.numseq;
	              for r_totratep2 in c_totratep2 loop
	                if v_qtymin > 0 then
	                  for i in 1..50 loop
	                    if p_rteotpay(i) is null or p_rteotpay(i) = r_totratep2.rteotpay then
	                      p_rteotpay(i) := r_totratep2.rteotpay;
	                      p_qtyminot(i) := nvl(p_qtyminot(i),0) + least(v_qtymin,r_totratep2.qtyminen);

--insert into  a (a) values  ( ' r_totratep2 '|| p_rteotpay(i) ||' - '||p_qtyminot(i)) ; commit;

	                      exit;
	                    end if;
	                  end loop;
	                  v_qtymin := v_qtymin - least(v_qtymin,r_totratep2.qtyminen);
	                end if;
	              end loop; -- c_totratep2
	            end if;	--r_totratep.typrate := 'T'
	            if p_rteotpay(1) is not null then
	              exit totratep_loop;
	            end if;
	          end if;
	        end loop;	--c_totratep
					--
          for i in 1..50 loop
            if p_rteotpay(i) is not null then
            	v_qtyminall2 := v_qtyminall2 + nvl(p_qtyminot(i),0);
            end if;
          end loop;

          -- Check Min Req.
          if p_qtyminreq > 0 and v_qtyminall2 > p_qtyminreq then
            v_qtyminall2 := v_qtyminall2 - p_qtyminreq;
            v_qtyminded := v_qtyminall2;
            for i in reverse 1..50 loop
              if p_qtyminot(i) > 0 and v_qtyminall2 > 0 then
                v_qtyminded   := least(v_qtyminall2,p_qtyminot(i));
                p_qtyminot(i) := p_qtyminot(i) - v_qtyminded;
                v_qtyminall2   := v_qtyminall2 - v_qtyminded;
                if p_qtyminot(i) = 0 then
                  p_qtyminot(i) := null;
                  p_rteotpay(i) := null;
                end if;
              end if;
          	end loop;
            --
            v_qtyminall2 := p_qtyminreq;
          end if;
        end if; --if v_flgot

				-- Cal Meal
				if v_meal then
					v_qtyminall  := o_qtyminall;
					-- OT Breake
					cal_break_ot(p_codcompy,p_dteeffec,v_numseq_brk,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,v_codshift,v_typwork,p_typot);--cal_break_ot(p_codcompy,p_dteeffec,null,p_dtewkreq,v_strtot,v_endot,v_qtyminall,v_qtydedbrk,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);

					-- Round up to Minute
					v_qtyminall := cal_round_ot(p_codcompy,p_dteeffec,v_qtyminall,v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,v_codshift,v_typwork,p_typot,v_jobgrade,v_typpayroll);
					-- Check Min Req.
					v_qtyminall := least(v_qtyminall,nvl(p_qtyminreq,v_qtyminall));
					if v_qtyminall > 0 then
						<< totmeal_loop >>
						for r_totmeal in c_totmeal loop
							v_numseq_meal := r_totmeal.numseq;
							v_flgfound := true;
							if r_totmeal.syncond is not null then
								v_cond := r_totmeal.syncond;
                v_cond := replace(v_cond,'V_HRAL92M6.CODCOMP',''''||v_codcomp||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.CODPOS',''''||v_codpos||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'V_HRAL92M6.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.CODEMPMT',''''||v_codempmt||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.CODCALEN',''''||v_codcalen||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.JOBGRADE',''''||v_jobgrade||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.CODGRPGL',''''||v_codgrpgl||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.AMTINCOM1',v_amtincom1);
                v_cond := replace(v_cond,'V_HRAL92M6.CODSHIFT',''''||v_codshift||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.TYPWORK',''''||v_typwork||'''');
                v_cond := replace(v_cond,'V_HRAL92M6.TYPOT',''''||p_typot||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								for r_totmeal2 in c_totmeal2 loop
									v_flgmeal := 'Y';
									v_amtmeal := hral71b_batch.cal_formula(p_codempid,r_totmeal2.amtmeal,p_dtewkreq);
									v_qtyminall2 := v_qtyminall;
									exit totmeal_loop;
								end loop; -- c_totmeal2
							end if; -- v_flgfound
						end loop;
					end if; -- v_qtyminall > 0
				end if; --v_meal
        --
        v_qtyminall := v_qtyminall2;

        p_tovrtime.qtyminot := 0;
        --
        if nvl(v_qtyminall,0) > 0 then
          begin
            select qtymincal
              into v_qtymincal
              from tcontrot
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec;
          exception when no_data_found then
            v_qtymincal := null;
          end;
          begin
            select typotreq,codcompw,flgchglv--,qtymincal
              into v_typotreq,p_tovrtime.codcompw,v_flgchglv--,v_qtymincal ==> tcontrot
              from totreqst
             where numotreq = p_numotreq;
          exception when no_data_found then
            v_typotreq := '1';
            v_typotreq := null;
            p_tovrtime.codcompw := null;
            v_flgchglv := null;
          end;
          if v_typotreq = '1' then -- 1-by Codempid , 2-Auto
            begin
              select codcompw,flgchglv
                into p_tovrtime.codcompw,v_flgchglv
                from totreqd
               where numotreq = p_numotreq
                 and dtewkreq = p_dtewkreq
                 and codempid = p_codempid
                 and typot    = p_typot;
            exception when no_data_found then
              p_tovrtime.codcompw := null;
              v_flgchglv := null;
            end;
          end if;
          if not(nvl(v_typotreq,'X') = '2' and nvl(v_qtymincal,0) > 0 and nvl(v_qtymincal,0) > v_qtyminall) then--if not(nvl(v_qtymincal,0) > 0 and nvl(v_qtymincal,0) > v_qtyminall) then
            p_tovrtime.codempid   := p_codempid;
            p_tovrtime.dtework    := p_dtewkreq;
            p_tovrtime.typot      := p_typot;
            p_tovrtime.codcomp    := v_codcomp;
            p_tovrtime.codcompw   := nvl(p_tovrtime.codcompw, v_codcomp);
            p_tovrtime.typpayroll := v_typpayroll;
            p_tovrtime.codcalen   := v_codcalen;
            p_tovrtime.codshift   := rt_tshiftcd.codshift;
            p_tovrtime.typwork    := v_typwork;
            p_tovrtime.numotreq   := p_numotreq;
            p_tovrtime.dtestrt    := to_date(to_char(v_strtot,'dd/mm/yyyy'),'dd/mm/yyyy');
            p_tovrtime.timstrt    := to_char(v_strtot,'hh24mi');
            p_tovrtime.dteend     := to_date(to_char(v_endot,'dd/mm/yyyy'),'dd/mm/yyyy');
            p_tovrtime.timend     := to_char(v_endot,'hh24mi');
            p_tovrtime.qtyminot   := v_qtyminall;
            p_tovrtime.qtydedbrk  := v_qtydedbrk;
            p_tovrtime.flgmeal    := nvl(v_flgmeal,'N');
            p_tovrtime.amtmeal		:= stdenc(v_amtmeal,p_codempid,para_chken);
            p_tovrtime.codrem		  := p_codrem;
            p_tovrtime.codappr 	  := p_codappr;
            p_tovrtime.dteappr		:= p_dteappr;
            p_tovrtime.coduser		:= p_coduser;
--to_char(p_tovrtime.dteend,'dd/mm/yyyy'),p_tovrtime.timend,p_tovrtime.qtyminot,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));


            if v_flgchglv = 'Y' then -- Y = ??????? OT.???????????
              for i in 1..50 loop
                p_qtyminot(i) := null;
                p_rteotpay(i) := null;
              end loop;
              p_tovrtime.qtyleave := v_qtyminall;
              p_tovrtime.amtmeal		:= stdenc(0,p_codempid,para_chken);--nut
            else
              p_tovrtime.qtyleave := 0;
            end if;
          end if;--not(v_typotreq = '2' and v_qtymincal > 0 and v_qtymincal > v_qtyminall)



        end if;--nvl(v_qtyminall,0) > 0
      end if; -- v_qtyminall > 0
			exit main_loop;
		end loop;
	end;
	--

	procedure cal_break_ot(p_codcompy   in varchar2,
		                     p_dteeffec   in date,
		                     p_numseq     in number,
		                     p_dtework 		in date,
		                     p_strtot			in date,
		                     p_endot	  	in date,
		                     p_qtyminot   in out number,
		                     p_qtydedbrk  out number,
		                     p_codcomp    in varchar2,
		                     p_codpos     in varchar2,
		                     p_numlvl     in number,
		                     p_codjob     in varchar2,
		                     p_codempmt   in varchar2,
		                     p_typemp     in varchar2,
		                     p_typpayroll	in varchar2,
		                     p_codbrlc    in varchar2,
		                     p_codcalen   in varchar2,
		                     p_jobgrade		in varchar2,
		                     p_codgrpgl   in varchar2,
		                     p_codshift   in varchar2,
		                     p_typwork    in varchar2,
		                     p_typot      in varchar2) is

	v_cond			  tcontrot.condot%type;
 	v_stmt      	varchar2(4000);
 	v_flgfound  	boolean;
 	t_strtot		  date;
 	t_endot			  date;
	v_numseq_brk  number := p_numseq;
	v_typbreak		varchar2(5);
	v_qtyminall		number := p_qtyminot;
	v_qtyminbk		number := 0;
	v_mindup  		number;

	cursor c_totbreak is
		select numseq,syncond,typbreak
		  from totbreak
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
	order by numseq;

	cursor c_totbreak2 is
		select qtyminst,qtyminen,timstrt,timend,qtyminbk
		  from totbreak2
		 where codcompy = p_codcompy
		   and dteeffec = p_dteeffec
		   and numseq   = v_numseq_brk
	order by numseq2;

	begin
		if v_numseq_brk is null then
			<< totbreak_loop >>
			for r_totbreak in c_totbreak loop
				v_flgfound := true;
				if r_totbreak.syncond is not null then
          v_cond := r_totbreak.syncond;
          v_cond := replace(v_cond,'V_HRAL92M4.CODCOMP',''''||p_codcomp||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODPOS',''''||p_codpos||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.NUMLVL',p_numlvl);
          v_cond := replace(v_cond,'V_HRAL92M4.CODJOB',''''||p_codjob||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODEMPMT',''''||p_codempmt||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.TYPEMP',''''||p_typemp||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.TYPPAYROLL',''''||p_typpayroll||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODBRLC',''''||p_codbrlc||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODCALEN',''''||p_codcalen||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.JOBGRADE',''''||p_jobgrade||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODGRPGL',''''||p_codgrpgl||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.CODSHIFT',''''||p_codshift||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.TYPWORK',''''||p_typwork||'''');
          v_cond := replace(v_cond,'V_HRAL92M4.TYPOT',''''||p_typot||'''');
          v_stmt := 'select count(*) from dual where '||v_cond;
          v_flgfound := execute_stmt(v_stmt);
				end if;
				if v_flgfound then
					v_typbreak   := r_totbreak.typbreak;
					v_numseq_brk := r_totbreak.numseq;
					exit totbreak_loop;
				end if;
			end loop; --c_totbreak
		else
			begin
        select typbreak into v_typbreak
          from totbreak
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and numseq   = v_numseq_brk;
        exception when no_data_found then null;
			end;
    end if; -- v_numseq_brk is null
		--
		<< totbreak2_loop >>
		for r_totbreak2 in c_totbreak2 loop
			if v_typbreak = 'T' then
				Find_period_time('1',p_dtework,p_codshift,p_strtot,p_endot,r_totbreak2.timstrt,r_totbreak2.timend,t_strtot,t_endot,v_mindup);
				if v_mindup > 0 then
					v_qtyminbk := v_qtyminbk + least(v_mindup,r_totbreak2.qtyminbk);
				end if;
			else
				if v_qtyminall between r_totbreak2.qtyminst and r_totbreak2.qtyminen then
					v_qtyminbk := r_totbreak2.qtyminbk;
					exit totbreak2_loop;
				end if;
			end if;
		end loop;
		--
		p_qtydedbrk := nvl(v_qtyminbk,0);
		p_qtyminot  := v_qtyminall - nvl(v_qtyminbk,0);
	end;
	------------------------------------------------------------------
	function cal_round_ot(p_codcompy    varchar2,
	                      p_dteeffec    date,
	                      p_qtyminot    number,
	                      p_codcomp     varchar2,
	                      p_codpos      varchar2,
	                      p_numlvl      number,
	                      p_typemp      varchar2,

	                      p_codempmt    varchar2,
	                      p_codcalen    varchar2,
	                      p_codshift    varchar2,
	                      p_typwork     varchar2,
	                      p_typot       varchar2,
	                      p_jobgrade	  varchar2,
	                      p_typpayroll	varchar2) return number is

	v_qtyminall		number := p_qtyminot;
	v_min			    number;

	cursor c_tcontot1 is
	  select qtymacot
  	  from tcontot1
	   where codcompy = p_codcompy
	     and dteeffec = p_dteeffec
	     and v_min    between qtymstot and qtymenot;

	begin
		v_min := trunc(mod(v_qtyminall,60));
    <<tcontot1_loop>>
    for r_tcontot1 in c_tcontot1 loop
        v_qtyminall := (trunc(v_qtyminall / 60,0) * 60) + r_tcontot1.qtymacot;
        if v_qtyminall < 0 then
          v_qtyminall := 0;
        end if;
      return(v_qtyminall);
    end loop; -- c_tcontot1
    return(v_qtyminall);
	end;
	------------------------------------------------------------------
	procedure InsUpdDel_ot(p_codempid   varchar2,
	                       p_dtework    date,
	                       p_typot      varchar2,
	                       p_type       varchar2,   --D=Delete, A=Insert/Update
	                       p_tovrtime   tovrtime%rowtype,
	                       p_rteotpay   a_rteotpay,
	                       p_qtyminot   a_qtyminot,
	                       p_rec     in out number) is

	begin
		if p_type = 'D' then
			delete tovrtime
			 where codempid = p_codempid
				 and dtework  = p_dtework
				 and typot    = p_typot;
			--
			delete totpaydt
			 where codempid = p_codempid
				 and dtework  = p_dtework
				 and typot    = p_typot;
		else
		  if p_tovrtime.qtyminot > 0 then
 		    for i in 1..50 loop
		      if p_qtyminot(i) > 0 then
 		     		begin
						insert into totpaydt(codempid,dtework,typot,rteotpay,qtyminot,codcreate,coduser)
						              values(p_tovrtime.codempid,p_tovrtime.dtework,p_tovrtime.typot,p_rteotpay(i),p_qtyminot(i),p_tovrtime.coduser,p_tovrtime.coduser);
		     		exception when dup_val_on_index then
		          update totpaydt
		             set qtyminot = nvl(qtyminot,0) + p_qtyminot(i),
		                 coduser  = p_tovrtime.coduser
		           where codempid = p_tovrtime.codempid
		             and dtework  = p_tovrtime.dtework
		             and typot    = p_tovrtime.typot

		             and rteotpay = p_rteotpay(i);
		     		end;
		      end if;
		    end loop;
				--
     		begin
			    insert into tovrtime(codempid,dtework,typot,
                                     codcomp,codcompw,typpayroll,codcalen,codshift,typwork,numotreq,
                                     dtestrt,timstrt,dteend,timend,qtyminot,qtydedbrk,qtyleave,flgmeal,amtmeal,
                                     codrem,codappr,dteappr,flgotcal,flgadj,codcreate,coduser)
                              values(p_tovrtime.codempid,p_tovrtime.dtework,p_tovrtime.typot,
                                     p_tovrtime.codcomp,p_tovrtime.codcompw,p_tovrtime.typpayroll,p_tovrtime.codcalen,p_tovrtime.codshift,p_tovrtime.typwork,p_tovrtime.numotreq,
                                     p_tovrtime.dtestrt,p_tovrtime.timstrt,p_tovrtime.dteend,p_tovrtime.timend,p_tovrtime.qtyminot,p_tovrtime.qtydedbrk,p_tovrtime.qtyleave,p_tovrtime.flgmeal,p_tovrtime.amtmeal,
                                     p_tovrtime.codrem,p_tovrtime.codappr,p_tovrtime.dteappr,'N','N',p_tovrtime.coduser,p_tovrtime.coduser);
     		exception when dup_val_on_index then
			    update tovrtime
			       set codcomp    = p_tovrtime.codcomp,
			           codcompw   = p_tovrtime.codcompw,
			           typpayroll = p_tovrtime.typpayroll,
			           codcalen   = p_tovrtime.codcalen,
			           codshift   = p_tovrtime.codshift,
			           typwork    = p_tovrtime.typwork,
			           numotreq   = p_tovrtime.numotreq,
			           dtestrt    = p_tovrtime.dtestrt,
			           timstrt    = p_tovrtime.timstrt,
			           dteend     = p_tovrtime.dteend,
			           timend     = p_tovrtime.timend,
			           qtyminot   = p_tovrtime.qtyminot,
			           qtydedbrk  = p_tovrtime.qtydedbrk,
			           qtyleave   = p_tovrtime.qtyleave,
			           flgmeal	  = p_tovrtime.flgmeal,
			           amtmeal	  = p_tovrtime.amtmeal,
			           codrem	  = p_tovrtime.codrem,
			           codappr 	  = p_tovrtime.codappr,
			           dteappr	  = p_tovrtime.dteappr,
                 coduser    = p_tovrtime.coduser
           where codempid   = p_tovrtime.codempid
             and dtework    = p_tovrtime.dtework
             and typot      = p_tovrtime.typot;
     		end;
     		--
		  	p_rec := nvl(p_rec,0) + 1;
			end if;--p_tovrtime.qtyminot > 0
		end if;  --p_type = 'D'
	end;
	--
	procedure Find_period_time(p_type			  varchar2, --'1' = find period of Setup Time / OT Break , '2' = find period of Shift Break
                              p_dtework   date,
                              p_codshift  varchar2,
                              p_dtestrt 	date,
                              p_dteend 	  date,
                              p_timestrt  varchar2,
                              p_timeend   varchar2,
                              p_dtedupst  out date,
                              p_dtedupen  out date,
                              p_mindup 	  out number) is
		rt_tshiftcd   tshiftcd%rowtype;
		v_dtework		  date := p_dtework;
		v_dtestrw		  date;
		v_dteendw		  date;
		v_dteotst 	  date;
		v_dteoten 	  date;
		v_dtedupst1   date;
		v_dtedupen1   date;
		v_dtedupst2   date;
		v_dtedupen2   date;
		v_dtedupst3   date;
		v_dtedupen3   date;

		v_datest1		  date;
		v_datest2		  date;
		v_datest3		  date;
		v_dateen1		  date;
		v_dateen2		  date;
		v_dateen3		  date;
		--
		v_date   		  date := p_dtestrt;
		v_minute		  number := to_date(to_char(sysdate,'dd/mm/yyyy')||'0801','dd/mm/yyyyhh24mi') - to_date(to_char(sysdate,'dd/mm/yyyy')||'0800','dd/mm/yyyyhh24mi');--1 Minute
	begin
		p_mindup := 0;
		begin
		  select * into rt_tshiftcd
		    from tshiftcd
		   where codshift = p_codshift;
		exception when no_data_found then null;
		end;
		if p_type = '1' then --find period of Setup Time / OT Break
			v_datest2 := to_date(to_char(p_dtestrt,'dd/mm/yyyy')||p_timestrt,'dd/mm/yyyyhh24mi');
			v_dateen2 := to_date(to_char(v_datest2,'dd/mm/yyyy')||p_timeend,'dd/mm/yyyyhh24mi');
			if p_timestrt > p_timeend then
				v_dateen2 := v_dateen2 + 1;
			end if;
			v_datest1 := v_datest2 - 1;
			v_dateen1 := v_dateen2 - 1;

			v_datest3 := v_datest2 + 1;
			v_dateen3 := v_dateen2 + 1;
			--
			loop
				if v_date between v_datest1 and v_dateen1 then
					v_dtedupst1 := least(v_date,nvl(v_dtedupst1,v_date));
					v_dtedupen1 := greatest(v_date,nvl(v_dtedupen1,v_date));
				end if;
				v_date := v_date + v_minute;-- +1 Minute
				if v_date > p_dteend then
					p_mindup := round((v_dtedupen1 - v_dtedupst1) * 1440);
					exit;
				end if;
			end loop;
      --
      v_date  := p_dtestrt;
      loop
        if v_date between v_datest2 and v_dateen2 then
          v_dtedupst2 := least(v_date,nvl(v_dtedupst2,v_date));
          v_dtedupen2 := greatest(v_date,nvl(v_dtedupen2,v_date));
        end if;
        v_date := v_date + v_minute;-- +1 Minute
        if v_date > p_dteend then
          p_mindup := nvl(p_mindup,0) + nvl(round((v_dtedupen2 - v_dtedupst2) * 1440),0);
          exit;
        end if;
      end loop;
      --
      v_date  := p_dtestrt;
      loop
        if v_date between v_datest3 and v_dateen3 then
          v_dtedupst3 := least(v_date,nvl(v_dtedupst3,v_date));
          v_dtedupen3 := greatest(v_date,nvl(v_dtedupen3,v_date));
        end if;
        v_date := v_date + v_minute;-- +1 Minute
        if v_date > p_dteend then
          p_mindup := nvl(p_mindup,0) + nvl(round((v_dtedupen3 - v_dtedupst3) * 1440),0);
          exit;
        end if;
      end loop;
      if p_mindup > 0 then
	      p_dtedupst := least(least(nvl(v_dtedupst1,to_date('01/01/9999','dd/mm/yyyy')),nvl(v_dtedupst2,to_date('01/01/9999','dd/mm/yyyy'))),nvl(v_dtedupst3,to_date('01/01/9999','dd/mm/yyyy')));
	      p_dtedupen := greatest(greatest(nvl(v_dtedupen1,to_date('01/01/0001','dd/mm/yyyy')),nvl(v_dtedupen2,to_date('01/01/0001','dd/mm/yyyy'))),nvl(v_dtedupen3,to_date('01/01/0001','dd/mm/yyyy')));
      end if;
      --
		elsif p_type = '2' then --find period of Shift Break
			if rt_tshiftcd.timstotdb is not null and rt_tshiftcd.timenotdb is not null then
				if rt_tshiftcd.timstotd < rt_tshiftcd.timstotdb then
					v_dteotst := to_date(to_char(p_dtework,'dd/mm/yyyy')||rt_tshiftcd.timstotdb,'dd/mm/yyyyhh24mi');
				else
					v_dteotst := to_date(to_char(p_dtework + 1,'dd/mm/yyyy')||rt_tshiftcd.timstotdb,'dd/mm/yyyyhh24mi');
				end if;

				if rt_tshiftcd.timstotdb < rt_tshiftcd.timenotdb	then
					v_dteoten := to_date(to_char(v_dteotst,'dd/mm/yyyy')||rt_tshiftcd.timenotdb,'dd/mm/yyyyhh24mi');
				else
					v_dteoten := to_date(to_char(v_dteotst + 1,'dd/mm/yyyy')||rt_tshiftcd.timenotdb,'dd/mm/yyyyhh24mi');
				end if;
			else
				return;
			end if;
			--
			loop
				if v_date between v_dteotst and v_dteoten then
					p_dtedupst := least(v_date,nvl(p_dtedupst,v_date));
					p_dtedupen := greatest(v_date,nvl(p_dtedupen,v_date));
				end if;
				v_date := v_date + v_minute;-- +1 Minute
				if v_date > p_dteend then
					p_mindup := round((p_dtedupen - p_dtedupst) * 1440);
					return;
				end if;
			end loop;
		end if;
	end;
	--
	procedure gen_compensate(p_codempid	   in varchar2,
                           p_codcomp	   in varchar2,
                           p_codcalen	   in varchar2,
                           p_typpayroll  in varchar2,
                           p_dtestrt	   in date,
                           p_coduser	   in varchar2,
                           p_numrec	     out number,
                           p_error       out varchar2,
                           p_err_table   out varchar2) is
	v_secur		    boolean;
	v_flgfound    boolean;
	v_codempid    temploy1.codempid%type;
	v_codcompy    temploy1.codcomp%type;
	v_codleave	  tleavecd.codleave%type;
	v_year			  number(4);
  v_year2       number(4);
	v_qtydleot		number;
	v_qtypriot		number;
	v_dteeffec		date;
	v_stdate		  date;
	v_endate		  date;

	cursor c_tleavecd is
		select a.codleave,a.typleave,a.staleave
		  from tleavecd a,tleavcom b
		 where a.typleave = b.typleave
       and a.staleave = 'C'
       and b.codcompy = v_codcompy;

	cursor c_temploy1 is
		select codempid,codcomp,typpayroll,numlvl
			from temploy1
		 where codempid = nvl(p_codempid,codempid)
		   and codcomp  like p_codcomp||'%'
       and codcalen   = nvl(p_codcalen,codcalen)
       and typpayroll = nvl(p_typpayroll,typpayroll)
  order by codempid;

	cursor c_tleavsum is
		select codempid,dteyear,codleave,rowid
		  from tleavsum
		 where codempid = v_codempid
		   and dteyear  = v_year
		   and codleave = v_codleave
		   for update;

	begin
  	p_numrec := 0;
  	if p_coduser <> 'AUTOBATCH' then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst, get_numdec(numlvlen,p_coduser) numlvlen
          into para_zminlvl,para_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;
    v_codcompy := get_comp_split(p_codcomp,1);
    if p_codempid is not null then
      begin
        select get_comp_split(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when others then null;
      end;
    end if;
		for c1 in c_tleavecd loop
			v_codleave	:= c1.codleave;
			for c2 in c_temploy1 loop
				v_codempid := c2.codempid;
				<<main_loop>>
				loop
					v_secur := secur_main.secur1(c2.codcomp,c2.numlvl,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
					if v_secur or p_coduser = 'AUTOBATCH' then
						null;
					else
						exit main_loop;
					end if;
					std_al.entitlement(v_codempid,v_codleave,p_dtestrt,para_zyear,v_qtydleot,v_qtypriot,v_dteeffec);
					v_qtydleot := nvl(v_qtydleot,0);
					v_qtypriot := nvl(v_qtypriot,0);

          --First Year--
          std_al.cycle_leave(hcm_util.get_codcomp_level(c2.codcomp,1),v_codempid,v_codleave,p_dtestrt,v_year,v_stdate,v_endate);
					v_year  := (v_year - para_zyear);

					v_flgfound := false;
					for c3 in c_tleavsum loop
						v_flgfound := true;
						update tleavsum
							 set codcomp    = c2.codcomp,
								 typpayroll = c2.typpayroll,
								 typleave   = c1.typleave,
								 staleave   = c1.staleave,
								 qtypriot   = v_qtypriot,
								 qtydleot   = v_qtydleot,
								 coduser    = p_coduser
						where rowid = c3.rowid;
					end loop;
					if not v_flgfound then
						insert into tleavsum(codempid,dteyear,codleave,
                                 typleave,staleave,qtypriot,qtydleot,codcomp,typpayroll,codcreate,coduser)
                          values(v_codempid,v_year,v_codleave,
                                 c1.typleave,c1.staleave,v_qtypriot,v_qtydleot,c2.codcomp,c2.typpayroll,p_coduser,p_coduser);
					end if;

					p_numrec := p_numrec + 1;
					exit main_loop;
				end loop; -- main_loop
			end loop; -- c_temploy1 loop
		end loop; -- c_tleavecd loop
	end;
  --

end HRAL85B_BATCH;

/
