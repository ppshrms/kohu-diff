--------------------------------------------------------
--  DDL for Package Body HRAL71B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL71B_BATCH" is
-- last update: 15/02/2021 11:00        --SWD-ST11-1701-AL-06-Rev2.0_07
  procedure start_process(p_codapp    	varchar2,
                          p_codempid  	varchar2,
                          p_codcomp	  	varchar2,
                          p_typpayroll 	varchar2,
                          p_typpayroll2	varchar2,
                          p_codpay    	varchar2,
                          p_dteyrepay 	number,
                          p_dtemthpay 	number,
                          p_numperiod 	number,
                          p_dtestr    	date,
                          p_dteend    	date,
                          p_flgretprd 	varchar2,
                          p_qtyretpriod	number,
						              p_v_dtestrt		date,
                          p_coduser   	varchar2,
                          p_codcurr   	varchar2,
                          o_codempid  	out varchar2,
                          o_dtework	  	out date,
                          o_remark    	out varchar2,
                          o_numrec		  out number,
                          o_timcal    	out varchar2) is
    v_remark		    varchar2(4000);
    v_cont			    varchar2(3);
    v_dtecalstr     date;
    v_dtecalend     date;


	begin
		para_codapp_wh  := p_codapp;
    para_codapp	    := substr(p_codapp,1,length(p_codapp)-16);
    para_coduser	 	:= p_coduser;
    indx_codempid   := p_codempid;
    indx_codcomp	  := p_codcomp;
    indx_typpayroll := p_typpayroll;
    --para_typpayroll	:= p_typpayroll2;
    para_codpay			:= p_codpay;
    para_dteyrepay  := p_dteyrepay;
    para_dtemthpay  := p_dtemthpay;
    para_numperiod  := p_numperiod;
    para_dtestr	    := p_dtestr;
    para_dteend  		:= p_dteend;
    para_flgretprd 	:= p_flgretprd;
    para_qtyretpriod:= p_qtyretpriod;
    para_v_dtestrt	:= p_v_dtestrt;
		para_codcurr	 	:= p_codcurr;
		--para_codcompy		:= hcm_util.get_codcomp_level(p_codcomp,1);
    --
--<< user22 : 10/71/2021 : ST11 ||
    if indx_codempid is not null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1), typpayroll
          into para_codcompy,para_typpayroll
          from temploy1
         where codempid  = indx_codempid;
      exception when no_data_found then null;
      end;
      indx_codcomp := null;
      indx_typpayroll := null;
    else
      para_codcompy    := hcm_util.get_codcomp_level(indx_codcomp,1);
      para_typpayroll  := indx_typpayroll;
    end if;
-->> user22 : 10/71/2021 : ST11 ||
		--
    begin
        select get_numdec(numlvlst,p_coduser) numlvlst,get_numdec(numlvlen,p_coduser) numlvlen
        into para_numlvlst,para_numlvlen
        from tusrprof
       where coduser = p_coduser;
    exception when others then null;
    end;
    --
	  gen_group_emp;     -- create tprocemp
	  gen_group;         -- create tprocount
	  gen_job;           -- create Job & Process
	  -- return record

  	begin
      select sum(nvl(qtyproc,0)),min(dtecalstr),max(dtecalend)
        into o_numrec,v_dtecalstr,v_dtecalend
        from tprocount
       where codapp 	= para_codapp_wh
         and coduser 	= p_coduser
         and qtyproc  > 0
      group by codapp,coduser;
    exception when no_data_found then null;
  	end;

    o_timcal := hcm_util.datediff_to_time(v_dtecalstr,v_dtecalend);
    for i in 1..para_numproc loop
			begin
	  		select codempid,dtework,remark into o_codempid,o_dtework,v_remark
	  		  from tprocount
		     where codapp 	= para_codapp_wh
		       and coduser 	= p_coduser
		       and numproc  = i
		       and flgproc  = 'E';
		  	o_remark := o_remark||v_cont||o_codempid||'-'||o_dtework||'-'||v_remark;
		  	v_cont := ', ';
			exception when no_data_found then null;
	  		delete tprocount
		     where codapp 	= para_codapp_wh
		       and coduser 	= p_coduser
		       and numproc  = i;
	  		delete tprocemp
		     where codapp 	= para_codapp_wh
		       and coduser 	= p_coduser
		       and numproc  = i;
	  	end;
    end loop;
    commit;
	end;


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure gen_group_emp is
  	v_numproc		number := 99;
  	v_zupdsal		varchar2(50);
  	v_flgsecu		boolean;
  	v_cnt				number;
  	v_rownumst	number;
  	v_rownumen	number;

		--'WAGE'
		cursor c_wage is
      select codempid
        from ( select codempid
                 from tattence a
                where a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	   = para_codapp
                                     and k.codpay	   = para_codpay
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')                                     
		group by codempid
    order by codempid;

		--'DED_LEAVE'
		cursor c_ded_leave is
      select codempid
        from ( select codempid
                 from tleavetr a
                where a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and exists (select d.typleave
                                from tleavety d
                               where d.typleave = a.typleave
                                 and d.flgtype  <> 'M')
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'DED_LEAVEM'
		cursor c_ded_leaveM is
      select codempid
        from ( select codempid
                 from tleavetr a
                where a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and exists (select d.typleave
                                from tleavety d
                               where d.typleave = a.typleave
                                 and d.flgtype  = 'M')
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

    --'DED_LATE'
		cursor c_ded_late is
      select codempid
        from ( select a.codempid
                 from tattence a, tlateabs b
                where a.codempid   = b.codempid
                  and a.dtework    = b.dtework
                  and a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and b.qtylate > 0
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

    --'ADJ_LATE'
		cursor c_adj_late is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_LATE'
         and a.flgtran    = 'Y'
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
	       and not exists (select codempid
	                         from tpaysum2
									        where codempid  = b.codempid
									          and codalw	  = para_codapp
									          and dtework	  = b.dtework
									          and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											          para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
		group by b.codempid
    order by b.codempid;

    --'DED_EAR'
		cursor c_ded_ear is
      select codempid
        from ( select a.codempid
                 from tattence a, tlateabs b
                where a.codempid   = b.codempid
                  and a.dtework    = b.dtework
                  and a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and b.qtyearly > 0
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'ADJ_EARLY'
		cursor c_adj_ear is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_EARLY'
         and a.flgtran    = 'Y'
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
	       and not exists (select codempid
	                         from tpaysum2
									        where codempid  = b.codempid
									          and codalw	  = para_codapp
									          and dtework	  = b.dtework
									          and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											          para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
		group by b.codempid
    order by b.codempid;

		--'DED_ABSENT'
		cursor c_ded_abs is
      select codempid
        from ( select a.codempid
                 from tattence a, tlateabs b
                where a.codempid   = b.codempid
                  and a.dtework    = b.dtework
                  and a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and b.qtyabsent  > 0
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'ADJ_ABSENT'
		cursor c_adj_abs is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_ABSENT'
         and a.flgtran    = 'Y'
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
	       and not exists (select codempid
	                         from tpaysum2
									        where codempid  = b.codempid
									          and codalw	  = para_codapp
									          and dtework	  = b.dtework
									          and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											          para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
		group by b.codempid
    order by b.codempid;

		--'OT','MEAL'
		cursor c_ot is
      select codempid
        from ( select codempid
                 from tovrtime a
                where a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and a.dtework    between para_dtestr and para_dteend
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	   in ('OT','MEAL')
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	  in ('OT','MEAL')
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'PAY_OTHER'
		cursor c_other is
      select codempid
        from( select codempid
                from tattence a
               where a.codempid   = nvl(indx_codempid,a.codempid)
                 and a.codcomp    like indx_codcomp||'%'
                 and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                 and a.dtework    between para_dtestr and para_dteend
                 and not exists (select k.codempid
                                   from tpaysum k
                                  where k.codempid   = a.codempid
                                    and k.dteyrepay  = para_dteyrepay
                                    and k.dtemthpay  = para_dtemthpay
                                    and k.numperiod  = para_numperiod
                                    and k.codalw	   = para_codapp
                                    and k.codpay	   = para_codpay
                                    and k.flgtran    = 'Y')
                 and not exists (select codempid
                                   from tpaysum2
                                  where codempid  = a.codempid
                                    and codalw	  = para_codapp
                                    and codpay    = para_codpay
                                    and dtework	  = a.dtework
                                    and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                                        para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'PAY_VACAT'
		cursor c_vacat is
      select codempid
        from( select codempid
                from tpayvac a
               where a.codempid   = nvl(indx_codempid,a.codempid)
                 and a.codcomp    like indx_codcomp||'%'
                 and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                 and a.dteyrepay  = para_dteyrepay
                 and a.dtemthpay  = para_dtemthpay
                 and a.numperiod  = para_numperiod
                 and a.staappr    = 'Y'
                 and not exists (select k.codempid
                                   from tpaysum k
                                  where k.codempid   = a.codempid
                                    and k.dteyrepay  = para_dteyrepay
                                    and k.dtemthpay  = para_dtemthpay
                                    and k.numperiod  = para_numperiod
                                    and k.codalw	   = para_codapp
                                    and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'AWARD','RET_AWARD'
		cursor c_award is
      select codempid
        from ( select codempid
                 from temploy1 a
                where a.codempid   = nvl(indx_codempid,a.codempid)
                  and a.codcomp    like indx_codcomp||'%'
                  and a.typpayroll = nvl(indx_typpayroll,a.typpayroll)
                  and(a.staemp     in ('1','3')
                   or(a.staemp     = '9' and a.dteeffex > para_dteend))
                  and not exists (select k.codempid
                                    from tpaysum k
                                   where k.codempid   = a.codempid
                                     and k.dteyrepay  = para_dteyrepay
                                     and k.dtemthpay  = para_dtemthpay
                                     and k.numperiod  = para_numperiod
                                     and k.codalw	    = para_codapp
                                     and k.codpay     = para_codpay
                                     and k.flgtran    = 'Y')
        union
               select codempid
                 from tpaysum c
                where c.codempid   = nvl(indx_codempid,c.codempid)
                  and c.codcomp    like indx_codcomp||'%'
                  and c.typpayroll = nvl(indx_typpayroll,c.typpayroll)
                  and c.dteyrepay  = para_dteyrepay
                  and c.dtemthpay  = para_dtemthpay
                  and c.numperiod  = para_numperiod
                  and c.codalw	   = para_codapp
                  and c.codpay     = para_codpay
                  and c.flgtran    = 'N')
		group by codempid
    order by codempid;

		--'RET_WAGE'
		cursor c_ret_wage is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'WAGE'
         and a.flgtran    = 'Y'
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.codpay	   = para_codpay
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_LEAVE'
		cursor c_ret_leave is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_LEAVE'
         and a.flgtran    = 'Y'
         and b.codshift  in (select codleave
                               from tleavecd e, tleavety f
                              where e.typleave =  f.typleave
                                and e.codleave =  b.codshift
                                and f.flgtype  <> 'M')
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_LEAVEM'
		cursor c_ret_leavem is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_LEAVEM'
         and a.flgtran    = 'Y'
         and b.codshift  in (select codleave
                               from tleavecd e, tleavety f
                              where e.typleave =  f.typleave
                                and e.codleave =  b.codshift
                                and f.flgtype  = 'M')
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_LATE'
		cursor c_ret_late is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_LATE'
         and a.flgtran    = 'Y'
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_EARLY'
		cursor c_ret_ear is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_EARLY'
         and a.flgtran    = 'Y'
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_ABSENT'
		cursor c_ret_abs is
	    select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'DED_ABSENT'
         and a.flgtran    = 'Y'
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

		--'RET_OT'
		cursor c_ret_ot is
      select b.codempid
				from tpaysum a,tpaysum2 b
       where a.dteyrepay  = b.dteyrepay
         and a.dtemthpay  = b.dtemthpay
         and a.numperiod  = b.numperiod
         and a.codempid   = b.codempid
         and a.codalw		  = b.codalw
         and a.codpay		  = b.codpay
         and b.codempid   = nvl(indx_codempid,b.codempid)
			   and b.codcomp    like indx_codcomp||'%'
			   and b.typpayroll = nvl(indx_typpayroll,b.typpayroll)
         and b.dtework    between para_dtestr and para_dteend
         and b.codalw	    = 'OT'
         and a.flgtran    = 'Y'
         and exists    (select codempid
                         from ttmovemt
                        where codempid   = b.codempid
                          and dteeffec  <= b.dtework
                          and dtecreate >= para_dtestr
                          and flgadjin   = 'Y'
                          and staupd    in ('C','U'))
         and not exists (select k.codempid
                           from tpaysum k
                          where k.codempid   = a.codempid
                            and k.dteyrepay  = para_dteyrepay
                            and k.dtemthpay  = para_dtemthpay
                            and k.numperiod  = para_numperiod
                            and k.codalw	   = para_codapp
                            and k.flgtran    = 'Y')
		group by b.codempid
    order by b.codempid;

	begin
  	delete tprocemp
  	 where codapp  = para_codapp_wh
  	   and coduser = para_coduser;
  	commit;


  	if para_codapp = 'WAGE' then
  		for r_emp in c_wage loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'OT' then
  		for r_emp in c_ot loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
			end loop;
  	--
  	elsif para_codapp = 'AWARD' then
  		for r_emp in c_award loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'PAY_VACAT' then
  		for r_emp in c_vacat loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'PAY_OTHER' then
  		for r_emp in c_other loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
        if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'DED_ABSENT' then
  		for r_emp in c_ded_abs loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'DED_EARLY' then
  		for r_emp in c_ded_ear loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'DED_LATE' then
  		for r_emp in c_ded_late loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'DED_LEAVE' then
  		for r_emp in c_ded_leave loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'DED_LEAVEM' then
  		for r_emp in c_ded_leavem loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'ADJ_ABSENT' then
  		for r_emp in c_adj_abs loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'ADJ_EARLY' then
  		for r_emp in c_adj_ear loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'ADJ_LATE' then
  		for r_emp in c_adj_late loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_WAGE' then
  		for r_emp in c_ret_wage loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_OT' then
  		for r_emp in c_ret_ot loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_ABSENT' then
  		for r_emp in c_ret_abs loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_EARLY' then
  		for r_emp in c_ret_ear loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_LATE' then
  		for r_emp in c_ret_late loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	--
  	elsif para_codapp = 'RET_LEAVE' then
  		for r_emp in c_ret_leave loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
    --
    elsif para_codapp = 'RET_LEAVEM' then
  		for r_emp in c_ret_leavem loop
        v_flgsecu := secur_main.secur2(r_emp.codempid, para_coduser, para_numlvlst, para_numlvlen, v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp_wh,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	end if;
		commit;

		-- change numproc
  	begin
  		select count(*) into v_cnt
  		  from tprocemp
  		 where codapp  = para_codapp_wh
  		   and coduser = para_coduser;
  	end;
  	if v_cnt > 0 then
  		v_rownumst := 1;
	  	for i in 1..para_numproc loop
	  		if v_cnt < para_numproc then
	  			v_rownumen := v_cnt;
	  		else
	  			v_rownumen := ceil(v_cnt/para_numproc);
  			end if;
	  		--
	  		update tprocemp
	  		   set numproc = i
	   		 where codapp  = para_codapp_wh
	  		   and coduser = para_coduser
	  		   and numproc = v_numproc
	  		   and rownum  between v_rownumst and v_rownumen;
	  	end loop;
	  end if;
	  commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure gen_group is
  v_cnt		number := 0;
  begin

  	begin
  		select count(distinct(numproc)) into v_cnt
  		  from tprocemp
  		 where codapp  = para_codapp_wh
  		   and coduser = para_coduser;
  	end;

  	delete tprocount
  	 where codapp  = para_codapp_wh
  	   and coduser = para_coduser; commit;
    for i in 1..v_cnt loop
			insert into tprocount(codapp,coduser,numproc,
								  qtyproc,remark,codpay,flgproc,codempid,dtework,dtestrt,dteend,qtyerr,dtecalstr,dtecalend)
	                   values(para_codapp_wh,para_coduser,i,
	                          0,null,para_codpay,'N',null,null,para_dtestr,para_dteend,null,sysdate,null);
    end loop;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure gen_job is
		v_stmt			varchar2(1000);
		v_interval	varchar2(50);
		v_finish		varchar2(1);
    p_dtestr    varchar2(20);
    p_dteend    varchar2(20);
    p_v_dtestrt varchar2(20);

		type a_number is table of number index by binary_integer;
  		 a_jobno	a_number;
	begin
--<< user22 : 26/01/2016 : STA3590197 || error case 29/04/2559
    -- Change Date To ??. ????? Database ???????? ?.?.
		if to_number(to_char(para_dtestr,'yyyy')) > 2500 then
		   p_dtestr     :=  to_char(para_dtestr,'dd/mm/')||(to_number(to_char(para_dtestr,'yyyy'))-543) ;
       p_dteend     :=  to_char(para_dteend,'dd/mm/')||(to_number(to_char(para_dteend,'yyyy'))-543) ;
       p_v_dtestrt  :=  to_char(para_v_dtestrt,'dd/mm/')||(to_number(to_char(para_v_dtestrt,'yyyy'))-543) ;
    else
		   p_dtestr     :=  to_char(para_dtestr,'dd/mm/yyyy');
       p_dteend     :=  to_char(para_dteend,'dd/mm/yyyy');
       p_v_dtestrt  :=  to_char(para_v_dtestrt,'dd/mm/yyyy');
    end if;
-->> user22 : 26/01/2016 : STA3590197 || error case 29/04/2559
		for i in 1..para_numproc loop
			v_stmt := 'hral71b_batch.cal_start('''||para_codapp_wh||''','''||para_codapp||''','''||para_coduser||''','||i||','''
			          ||para_codpay||''','
			          ||para_dteyrepay||','
			          ||para_dtemthpay||','
			          ||para_numperiod||','
			          ||'to_date('''||p_dtestr||''',''dd/mm/yyyy''),'
			          ||'to_date('''||p_dteend||''',''dd/mm/yyyy''),'''
			          ||nvl(para_flgretprd,'N')||''','
			          ||nvl(para_qtyretpriod,0)||','
			          ||'to_date('''||p_v_dtestrt||''',''dd/mm/yyyy''),'''
			          ||indx_codempid||''','''
			          ||indx_codcomp||''','''
			          ||indx_typpayroll||''','''
                ||para_codcompy||''','''-- user22 : 10/07/2021 : ST11 ||
			          ||para_typpayroll||''','''
			          ||para_codcurr||''');';
		  dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
		end loop;
		--
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
  end;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_start(p_codapp_wh  	varchar2,--user22 : 06/07/2016 : STA3590292 ||
                      p_codapp    	varchar2,
                      p_coduser   	varchar2,
                      p_numproc	  	number,
                      p_codpay    	varchar2,
                      p_dteyrepay 	number,
                      p_dtemthpay 	number,
                      p_numperiod 	number,
                      p_dtestr    	date,
                      p_dteend    	date,
                      p_flgretprd 	varchar2,
                      p_qtyretpriod	number,
                      p_v_dtestrt		date,
                      p_codempid  	varchar2,
                      p_codcomp	  	varchar2,
                      p_typpayroll 	varchar2,
                      p_codcompy  	varchar2,-- user22 : 10/07/2021 : ST11 ||
                      p_typpayroll2	varchar2,
                      p_codcurr   	varchar2) is

	begin
		para_codapp_wh  := p_codapp_wh;
		para_codapp	    := p_codapp;
		para_coduser	 	:= p_coduser;
		para_numproc		:= p_numproc;
		para_codpay			:= p_codpay;
		para_dteyrepay  := p_dteyrepay;
		para_dtemthpay  := p_dtemthpay;
		para_numperiod  := p_numperiod;
		para_dtestr			:= p_dtestr;
		para_dteend			:= p_dteend;
	  para_flgretprd 	:= p_flgretprd;
		para_qtyretpriod:= p_qtyretpriod;
		para_v_dtestrt	:= p_v_dtestrt;
		indx_codempid  	:= p_codempid;
		indx_codcomp  	:= p_codcomp;
		indx_typpayroll	:= p_typpayroll;
		para_typpayroll	:= p_typpayroll2;
		para_codcurr	 	:= p_codcurr;
		para_codcompy		:= p_codcompy;-- user22 : 10/07/2021 : ST11 ||
		para_numrec     := 0;
--<< user22 : 26/01/2016 : STA3590197 || error case 29/04/2559
	  -- Change Date To ??. ????? Database ???????? ?.?.
		/*if to_char(p_dtestr,'yyyy') > 2500 then
		   para_dtestr  :=  to_date(to_char(p_dtestr,'dd/mm/')||(to_char(p_dtestr,'yyyy')-543),'dd/mm/yyyy') ;
       para_dteend  :=  to_date(to_char(p_dteend,'dd/mm/')||(to_char(p_dteend,'yyyy')-543),'dd/mm/yyyy') ;
       para_v_dtestrt  :=  to_date(to_char(p_v_dtestrt,'dd/mm/')||(to_char(p_v_dtestrt,'yyyy')-543),'dd/mm/yyyy') ;
		end if;*/
-->> user22 : 26/01/2016 : STA3590197 || error case 29/04/2559
		--
  	if para_codapp = 'WAGE' then
  		cal_wage(para_codapp,para_coduser,para_numproc);
  	elsif para_codapp = 'OT' then
  		cal_pay_ot(para_codapp,para_coduser,para_numproc);
  	elsif para_codapp = 'AWARD' then
  		cal_pay_award(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'PAY_VACAT' then
  		cal_pay_vacat(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'PAY_OTHER' then
  		cal_pay_other(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'DED_ABSENT' then
  		cal_ded_abs(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'DED_EARLY' then
  		cal_ded_ear(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'DED_LATE' then
  		cal_ded_late(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp in ('DED_LEAVE','DED_LEAVEM') then
  		cal_ded_leave(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'ADJ_ABSENT' then
  		cal_adj_abs(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'ADJ_EARLY' then
  		cal_adj_ear(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'ADJ_LATE' then
  		cal_adj_late(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'RET_WAGE' then
  		cal_ret_wage(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'RET_OT' then
  		cal_ret_ot(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'RET_ABSENT' then
  		cal_ret_abs(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'RET_EARLY' then
  		cal_ret_ear(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp = 'RET_LATE' then
  		cal_ret_late(para_codapp,para_coduser,para_numproc);
   	elsif para_codapp in ('RET_LEAVE','RET_LEAVEM') then
  		cal_ret_leave(para_codapp,para_coduser,para_numproc);
  	end if;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_wage(p_codapp    varchar2,
                     p_coduser   varchar2,
                     p_numproc	 number) is

		v_flgtran   varchar2(1);
		cursor c_emp is
			select a.codempid,codcomp,codcalen,typpayroll,codempmt,staemp,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;
	begin
		para_numrec:= 0; indx_codempid2 := null; para_dtework	:= null;
		for r_emp in c_emp loop
			<< main_loop >> loop
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(r_emp.codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				del_tpaysum(r_emp.codempid,para_codapp,para_codpay);
				--
				upd_period(r_emp.codempid,para_codapp,para_codpay);
				--
			 	cal_pay_wage_tatt (r_emp.codempid,r_emp.codcomp,p_codapp,p_coduser,p_numproc);
			 	--
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure cal_pay_wage_tatt(p_codempid 	varchar2,
	 	                          p_codcomp		varchar2,
	 	                          p_codapp    varchar2,
					                    p_coduser   varchar2,
					                    p_numproc	  number) is

		v_first				boolean := true;
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

		v_codshift		tattence.codshift%type;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_amtwork			number := 0;

		type char1 is table of varchar2(30) index by binary_integer;
			v_codincom	char1;
			v_unitcal		char1;

		type num1 is table of number index by binary_integer;
			v_amtincom   num1;
			v_sumqtyday  num1;
			v_sumqtymin  num1;
			v_sumamtpay  num1;
			v_sumamtday  num1;
			v_sumamthour num1;

		cursor c_tattence is
			select rowid,dtework,codshift,codcalen,qtyhwork,typwork,timin,timout
	  		from tattence
			 where codempid = p_codempid
			   and dtework between nvl(para_dtestr,dtework) and para_dteend
			   and typwork <> 'H'
			   and nvl(flgcalwk,'N') = 'N'
		order by dtework;

		cursor c_tcontpmd is
			select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
	 		  from tcontpmd
			 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
			   and dteeffec <= sysdate
			   and codempmt = v_codempmt
		order by dteeffec desc;

	begin
		for a in 1..10 loop
			v_codincom(a)	:= null;
			v_amtincom(a)	:= null;
			v_sumqtyday(a) := 0;
			v_sumqtymin(a) := 0;
			v_sumamtpay(a) := 0;
			v_sumamtday(a) := 0;
			v_sumamthour(a):= 0;
		end loop;
		begin
			select codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10
			  into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
	 		  from tcontpms
			 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
               and dteeffec = (select max(dteeffec)
								 from tcontpms
								where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                  and dteeffec <= trunc(sysdate));
		exception when no_data_found then return;
		end;

		update tattence
		   set flgcalwk  = 'N',
		       amtwork 	 = stdenc(0,codempid,para_chken),
			 		 dteyrepay = 0, dtemthpay = 0,	numperiod = 0
		 where dteyrepay = para_dteyrepay
		   and dtemthpay = para_dtemthpay
		   and numperiod = para_numperiod
		   and codempid  = p_codempid;
		for r_tattence in c_tattence loop
			v_codshift	:= r_tattence.codshift;
			<< cal_loop >>
			loop
				indx_codempid2 := p_codempid;
				para_dtework   := r_tattence.dtework;
				if check_dteempmt(r_tattence.dtework) then
					v_qtyday := 0; v_qtymin := 0;	v_amtpay := 0;
					if v_first then
						v_first := false;
						v_dtemovemt := r_tattence.dtework;
						std_al.get_movemt2(p_codempid,v_dtemovemt,'C','C',
									             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
					else
						if r_tattence.dtework >= v_dtemovemt then
							v_dtemovemt := r_tattence.dtework;
							std_al.get_movemt2(p_codempid,v_dtemovemt,'C','U',
										             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
						end if;
					end if;
					--
					v_amtwork := 0;
					for r_tcontpmd in c_tcontpmd loop
						v_unitcal(1) := r_tcontpmd.unitcal1;
						v_unitcal(2) := r_tcontpmd.unitcal2;
						v_unitcal(3) := r_tcontpmd.unitcal3;
						v_unitcal(4) := r_tcontpmd.unitcal4;
						v_unitcal(5) := r_tcontpmd.unitcal5;
						v_unitcal(6) := r_tcontpmd.unitcal6;
						v_unitcal(7) := r_tcontpmd.unitcal7;
						v_unitcal(8) := r_tcontpmd.unitcal8;
						v_unitcal(9) := r_tcontpmd.unitcal9;
						v_unitcal(10) := r_tcontpmd.unitcal10;
						for i in 1..10 loop
						  if v_unitcal(i) in ('H','D') and v_amtincom(i) > 0 and para_codpay = v_codincom(i)  then
								v_qtyday := 1; v_amtpay := 0;
								begin
									select qtydaywk	into v_qtymin
									  from tshiftcd
									 where codshift = v_codshift;
								exception when no_data_found then
									v_qtymin := 0;
								end;

								if v_unitcal(i) = 'H' then
									v_amtpay := v_amtincom(i) * (v_qtymin / 60);
								elsif v_unitcal(i) = 'D' then
									v_amtpay := v_amtincom(i);
								end if;

								v_amtday  := v_amtpay;
								v_amthour := v_amtday / (v_qtymin / 60);
								v_amtwork := v_amtwork + v_amtpay;

								v_sumamtday(i) := v_amtpay;
								v_sumamthour(i):= v_amthour;
								v_sumqtyday(i) := v_sumqtyday(i) + v_qtyday;
								v_sumqtymin(i) := v_sumqtymin(i) + v_qtymin;
								v_sumamtpay(i) := v_sumamtpay(i) + v_amtpay;
								upd_tpaysum2(p_codempid,para_codapp,v_codincom(i),v_codcomp,v_codpos,v_typpayroll,
                                             r_tattence.dtework,v_codshift,r_tattence.timin,r_tattence.timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
				 				exit;
				 			end if;
						end loop; -- for i
						exit;
					end loop; -- for c_tcontpmd

					begin
						select nvl(sum(stddec(amtpay,codempid,para_chken)),0) into v_amtwork
	 					  from tpaysum2
						 where dteyrepay = para_dteyrepay
						   and dtemthpay = para_dtemthpay
						   and numperiod = para_numperiod
						   and codempid  = p_codempid
						   and codalw 	 = para_codapp
						   and dtework 	 = r_tattence.dtework;
					exception when no_data_found then null;
					end;

					update tattence
						 set qtydwork   = v_qtyday,
						     amtwork    = stdenc(round(v_amtwork,4),codempid,para_chken),
							 	 flgcalwk  	= 'Y',
								 dteyrepay	= para_dteyrepay,
							 	 dtemthpay	= para_dtemthpay,
								 numperiod	= para_numperiod,
								 coduser	= para_coduser
					 where rowid = r_tattence.rowid;
				end if; -- check_dteempmt

				exit cal_loop;
			end loop; -- cal_loop
		end loop; -- for c_tattence

		for i in 1..10 loop
			if v_sumqtyday(i) > 0 then
				upd_tpaysum(p_codempid,para_codapp,v_codincom(i),v_codcomp,v_codpos,v_typpayroll,
										v_sumamthour(i),v_sumamtday(i),v_sumqtyday(i),v_sumqtymin(i),v_sumamtpay(i));
			end if;
		end loop; -- for i
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_pay_ot(p_codapp    varchar2,
                       p_coduser   varchar2,
                       p_numproc	 number) is
		v_codotalw		varchar2(10);
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgtran 		tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
	  v_flgfound  	boolean;
		v_dtework			tovrtime.dtework%type;
		v_typot				tovrtime.typot%type;
	  v_amt					number := 0;
	  v_amtot				number := 0;
		i 						number;
		v_daysummeal	number := 0;
		v_minsummeal	number := 0;
		v_amtsummeal	number := 0;
		v_sumqtyday  	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_qtydaywk   	number := 0;
		v_zupdsal   	varchar2(4);

		type a_varchar is table of varchar2(200) index by binary_integer;
			v_codcompw   a_varchar;

		type a_number is table of number index by binary_integer;
			v_rteotpay	a_number;
			v_qtyminot  a_number;
			v_amtminot  a_number;

		cursor c_temploy1 is
			select a.codempid,codcomp,codcalen,typpayroll,codempmt,staemp,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tovrtime is
			select codempid,dtework,typot,codcomp,nvl(codcompw,codcomp) as codcompw,dtestrt,dteend,timstrt,timend,qtyminot,flgmeal,amtmeal,codshift,typwork,rowid
			  from tovrtime
			 where codempid  = v_codempid
		     and dtework between nvl(para_dtestr,dtework) and para_dteend
			   and nvl(dteyrepay,0) = 0
		order by dtework;

		cursor c_totpaydt is
			select rowid,rteotpay,qtyminot
		  	from totpaydt
		 	 where codempid = v_codempid
			   and dtework  = v_dtework
			   and typot    = v_typot;

	begin
		begin
			select codotalw	into v_codotalw
			  from tcontrot
			 where codcompy = para_codcompy
			   and dteeffec = (select max(dteeffec)
												  from   tcontrot
										  	  where  codcompy = para_codcompy
										  	  and    dteeffec <= sysdate);
		exception when no_data_found then	null;
		end;
	  for r_temploy1 in c_temploy1 loop
			<< main_loop >>
			loop
        v_codempid := r_temploy1.codempid;
				v_codcomp	 := r_temploy1.codcomp;
				v_numlvl   := r_temploy1.numlvl;
				para_dteempmt := r_temploy1.dteempmt;
				para_dteeffex := r_temploy1.dteeffex;

				v_sumqtyday := 0; v_sumqtymin := 0; v_sumamtpay := 0;
				v_daysummeal := 0; v_minsummeal := 0; v_amtsummeal := 0;
				v_amthour	 := 0; v_amtday	:= 0;	v_amtmth := 0;
				for i in 1..30 loop
					v_codcompw(i)  := null;
					v_rteotpay(i)  := null;
				  v_qtyminot(i)  := 0;
					v_amtminot(i)  := 0;
				end loop;

				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;

				del_tpaysum(v_codempid,para_codapp,null);
				del_tpaysum(v_codempid,'MEAL',null);

				delete tpaysumd
				 where dteyrepay = para_dteyrepay
				   and dtemthpay = para_dtemthpay
				   and numperiod = para_numperiod
					 and codempid  = v_codempid;
				--
				upd_period(v_codempid,para_codapp,null);
				upd_period(v_codempid,'MEAL',null);

			  update tovrtime
	  			 set flgotcal  = 'N',
						   amtottot  = stdenc(0,codempid,para_chken),
					  	 amtothr   = stdenc(0,codempid,para_chken),
						   dteyrepay = 0,dtemthpay = 0,numperiod = 0
				 where dteyrepay = para_dteyrepay
				   and dtemthpay = para_dtemthpay
				   and numperiod = para_numperiod
				   and codempid  = v_codempid;

				v_first := true;
				for r_tovrtime in c_tovrtime loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tovrtime.dtework;

					if check_dteempmt(r_tovrtime.dtework) then
						begin
							select qtydaywk into v_qtydaywk
								from tshiftcd
							 where codshift	= r_tovrtime.codshift;
						exception when no_data_found then v_qtydaywk := 0;
						end;
						v_amtot		:= 0;
						v_dtework := r_tovrtime.dtework;
						v_typot   := r_tovrtime.typot;
						if v_first then
							v_first := false;
							v_dtemovemt := r_tovrtime.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else -- v_first = true
							if r_tovrtime.dtework >= v_dtemovemt then
								v_dtemovemt := r_tovrtime.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;	-- v_first = false

						-- CAL OT PAYMENT
						for r_totpaydt in c_totpaydt loop
							for i in 1..1000 loop
								if v_rteotpay(i) is null or
									 (v_rteotpay(i) = r_totpaydt.rteotpay and v_codcompw(i) = r_tovrtime.codcompw) then
									v_codcompw(i) := r_tovrtime.codcompw;
				  				v_rteotpay(i) := r_totpaydt.rteotpay;
				  				v_qtyminot(i) := v_qtyminot(i) + r_totpaydt.qtyminot;
									v_amt 				:= round(((r_totpaydt.qtyminot / 60) * r_totpaydt.rteotpay * v_amthour),4);
									v_amtminot(i) := v_amtminot(i) + v_amt;
									v_amtot 	 		:= v_amtot + v_amt;
									v_sumqtyday		:= v_sumqtyday + (r_totpaydt.qtyminot / v_qtydaywk);
									v_sumqtymin		:= v_sumqtymin + r_totpaydt.qtyminot;
									v_sumamtpay		:= v_sumamtpay + v_amt;
									upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                 v_dtework,v_typot,r_tovrtime.timstrt,r_tovrtime.timend,r_totpaydt.qtyminot,v_amt,v_amthour,v_amtday);
									update totpaydt
										 set amtottot = stdenc(round(v_amt,4),codempid,para_chken),
												 coduser	= para_coduser
									 where rowid    = r_totpaydt.rowid;
									exit;
								end if;
							end loop;
						end loop; -- for r_totpaydt

						-- CAL MEAL --------------------------------------------------
						if r_tovrtime.flgmeal = 'Y' and v_codotalw is not null then
							v_amtsummeal := v_amtsummeal + nvl(stddec(r_tovrtime.amtmeal,v_codempid,para_chken),0);
							v_minsummeal := v_minsummeal + r_tovrtime.qtyminot;
					  	v_daysummeal := v_daysummeal + 1;

							upd_tpaysum2(v_codempid,'MEAL',v_codotalw,v_codcomp,v_codpos,v_typpayroll,v_dtework,v_typot,
                                         r_tovrtime.timstrt,r_tovrtime.timend,r_tovrtime.qtyminot,nvl(stddec(r_tovrtime.amtmeal,v_codempid,para_chken),0),null,null);
            end if;

						update tovrtime
							 set amtothr	  = stdenc(round(v_amthour,4),codempid,para_chken),
									 amtottot	  = stdenc(round(v_amtot,4),codempid,para_chken),
									 dteyrepay	= para_dteyrepay,
								 	 dtemthpay	= para_dtemthpay,
									 numperiod	= para_numperiod,
									 coduser	  = para_coduser
						 where rowid      = r_tovrtime.rowid;
					end if; -- check_dteempmt
				end loop; -- for c_tovrtime
				--------------------------------------------------------------
				-- OT
				if v_sumamtpay > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
					for i in 1..1000 loop
						if v_rteotpay(i) is null then
							exit;
						elsif v_qtyminot(i) > 0 then
							upd_tpaysumd(v_codempid,v_codcompw(i),v_rteotpay(i),v_qtyminot(i),v_amtminot(i));
						end if;
					end loop;
				end if;
				-- MEAL
				if v_amtsummeal > 0 and v_codotalw is not null then
					upd_tpaysum(v_codempid,'MEAL',v_codotalw,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_daysummeal,v_minsummeal,v_amtsummeal);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_temploy1
    --
    indx_codempid2		 := null;
    para_dtework		 := null;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_pay_award(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number) is
		v_codaward		tcontraw.codaward%type;
		v_dteeffec		date;
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
    o_codempid		temploy1.codempid%type;
		v_staemp			temploy1.staemp%type;
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

		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_numseq		 	number := 0;
		v_qtyoldacc  	number := 0;
		v_qtyaccaw   	number := 0;
		v_qtylate 		number := 0;
		v_qtyearly 		number := 0;
		v_qtyabsent 	number := 0;
		v_qtytlate 		number := 0;
		v_qtytearly 	number := 0;
		v_qtytabs 		number := 0;
		v_qtynostam 	number := 0;
		v_qtymin 			number := 0;
    v_timleave		number := 0;
		v_check				varchar2(1) := 'N';
		v_flgcal			boolean;
	--	v_flgcalR			boolean;
		v_flgcalC			boolean;
		v_first				boolean;
		v_zupdsal   	varchar2(4);

		v_dteyrepay		number;
		v_dtemthpay		number;
		v_numperiod		number;
		v_amtaw1   		number := 0;
		v_amtaw2   		number := 0;
		v_amtretaw		number := 0;
		v_num					number := 0;
		v_amtaw				number := 0;
    v_dtestrt     date;
    v_dteend      date;
    v_dtemovemt   date;
    v_amthour     number := 0;
    v_amtday      number := 0;
    v_amtmth      number := 0;
    v_flgcal_ret  varchar2(1);

	cursor c_emp is
		select a.codempid,staemp,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl,dteempmt,dteeffex,dtereemp
	 	  from tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
	order by a.codempid;

	cursor c_emp_retro is
		select v_table
	 	  from(
           select '1' as v_table
             from ttmovemt
            where codempid   = v_codempid
              and dteeffec  <= v_dteend
              and dtecreate >= v_dtestrt
               --or dteupd    >= v_dtestrt)
              and staupd    in ('C','U')
              and((codcomp   <> codcompt)   or (codpos   <> codposnow) or (numlvl   <> numlvlt)
               or(codjob     <> codjobt)    or (codempmt <> codempmtt) or (typemp   <> typempt)
               or(typpayroll <> typpayrolt) or (codbrlc  <> codbrlct)  or (codcalen <> codcalet)
               or(jobgrade   <> jobgradet)  or (codgrpgl <> codgrpglt))
      union
           select '2' as v_table
             from tlogtime
            where codempid   = v_codempid
              and dtework   between v_dtestrt and v_dteend
              and dtecreate >= v_dtestrt
               --or dteupd    >= v_dtestrt)
      union
           select '2' as v_table
             from tloglate
            where codempid   = v_codempid
              and dtework   between v_dtestrt and v_dteend
              and dtecreate >= v_dtestrt
               --or dteupd    >= v_dtestrt)
      union
           select '2' as v_table
             from tlogleav
            where codempid   = v_codempid
              and dtework   between v_dtestrt and v_dteend
              and dtecreate >= v_dtestrt
               --or dteupd    >= v_dtestrt)
      union
           select '2' as v_table
             from tlateabs
            where codempid   = v_codempid
              and dtework   between v_dtestrt and v_dteend
              and dtecreate >= v_dtestrt
               --or dteupd    >= v_dtestrt)
      union
           select '2' as v_table
             from tleavetr
            where codempid   = v_codempid
              and dtework   between v_dtestrt and v_dteend
              and dtecreate >= v_dtestrt)
               --or dteupd    >= v_dtestrt))
	group by v_table
  order by v_table;

	cursor c_tcontraw is
		select codcompy,codaward,dteeffec,syncond,codpay,qtylate,qtyearly,qtyabsent,qtyall,timlate,timearly,timabsent,timall,timnoatm,
           codrtawrd,numprdclr,dtemthclr
		  from tcontraw
		 where codcompy = para_codcompy
       and codpay		= para_codpay
		   and dteeffec = (select max(dteeffec)
                         from tcontraw
                        where codcompy  = para_codcompy
                          and codpay		= para_codpay)
                          and dteeffec <= trunc(sysdate);

	cursor c_tcontaw3 is
		select numseq,syncond
		  from tcontaw3
		 where codcompy = para_codcompy
		   and codaward = v_codaward
		   and dteeffec = v_dteeffec
	order by numseq;

	cursor c_tcontaw4 is
		select qtyaw,formula
		  from tcontaw4
		 where codcompy = para_codcompy
		   and codaward = v_codaward
		   and dteeffec = v_dteeffec
		   and numseq		= v_numseq
		   and qtyaw   <= v_qtyaccaw
	order by qtyaw desc;

	cursor c_tpriodal_find_numperiod is
		select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
		  from tpriodal
		 where codcompy   = para_codcompy
		   and typpayroll = para_typpayroll
		   and codpay	    = para_codpay
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') < para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0')
	 order by dteyrepay desc,dtemthpay desc,numperiod desc;

	cursor c_tpriodal is
		select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
		  from tpriodal
		 where codcompy   = para_codcompy
		   and typpayroll = para_typpayroll
		   and codpay	    = para_codpay
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') >= v_dteyrepay||lpad(v_dtemthpay,2,'0')||lpad(v_numperiod,2,'0')
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <=  para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0')
	order by dteyrepay,dtemthpay,numperiod;

	cursor c_tpriodal_Retro is
		select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
		  from tpriodal
		 where codcompy   = para_codcompy
		   and typpayroll = para_typpayroll
		   and codpay	    = para_codpay
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') >= v_dteyrepay||lpad(v_dtemthpay,2,'0')||lpad(v_numperiod,2,'0')
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <  para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0')
	order by dteyrepay,dtemthpay,numperiod;

	begin
		for r1 in c_tcontraw loop
			v_check := 'Y';
			exit;
		end loop;
		if v_check = 'N' then
			return;
		end if;
    v_dteyrepay	 := para_dteyrepay;
    v_dtemthpay	 := para_dtemthpay;
    v_numperiod	 := para_numperiod;
		if para_flgretprd = 'Y' and nvl(para_qtyretpriod,0) > 0 then
			for r_tpriodal in c_tpriodal_find_numperiod loop
				v_num := v_num + 1;
				v_dteyrepay	 := r_tpriodal.dteyrepay;
				v_dtemthpay	 := r_tpriodal.dtemthpay;
				v_numperiod	 := r_tpriodal.numperiod;
        v_dtestrt    := least(nvl(v_dtestrt,r_tpriodal.dtestrt),r_tpriodal.dtestrt);
        v_dteend     := greatest(nvl(v_dteend,r_tpriodal.dteend),r_tpriodal.dteend);
				if v_num >= para_qtyretpriod then
					exit;
				end if;
			end loop;
    end if;
    --
	  for r_emp in c_emp loop
      v_codempid   := r_emp.codempid;
      v_staemp     := r_emp.staemp;
      v_first      := true;
      v_flgcal_ret := 'N';
			<< main_loop >> loop
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
        for r_tcontraw in c_tcontraw loop
          v_codaward  := r_tcontraw.codaward;
          v_dteeffec  := r_tcontraw.dteeffec;
          --
          del_tpaysum(v_codempid,para_codapp,para_codpay);
          del_tpaysum(v_codempid,'RET_AWARD',r_tcontraw.codrtawrd);
          delete tawrdret
           where dteyrepay = para_dteyrepay
             and dtemthpay = para_dtemthpay
             and numperiod = para_numperiod
             and codempid  = v_codempid
             and codaward  = v_codaward;
          --
--<< user22 : 22/03/2024 : KOHU : #1805 || ไม่จำเป็นต้องเช็คก็ได้/เช็คแล้วทำให้คำนวณตกเบิกแบบระบุกลุ่มไม่ได้          
          /*if para_flgretprd = 'Y' and nvl(para_qtyretpriod,0) > 0 and r_tcontraw.codrtawrd is not null then
            for r2 in c_emp_retro loop
              if r2.v_table = '1' then
                for r_tpriodal in c_tpriodal_Retro loop
                  v_dtemovemt := r_tpriodal.dteend;
                  std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                    v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                    v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                    v_amthour,v_amtday,v_amtmth);
                  v_flgcal := true;
                  if r_tcontraw.syncond is not null then
                    v_cond := r_tcontraw.syncond;
                    v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                    v_stmt := 'select count(*) from dual where '||v_cond;
                    v_flgcal := execute_stmt(v_stmt);
                  end if;
                  if v_flgcal then
                    v_flgcal_ret := 'Y';
                    exit;
                  end if;
                end loop; -- c_tpriodal_Retro loop
                if v_flgcal_ret = 'N' then
                  delete tempawrd2
                   where codempid   = v_codempid
                     and codaward   = v_codaward
                     and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') >= v_dteyrepay||lpad(v_dtemthpay,2,'0')||lpad(v_numperiod,2,'0')
                     and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <  para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0');
                end if;
              else --  r2.v_table = '2'
                v_dtemovemt := sysdate;
                std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                  v_amthour,v_amtday,v_amtmth);
                v_flgcal := true;
                if r_tcontraw.syncond is not null then
                  v_cond := r_tcontraw.syncond;
                  v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                  v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                  v_stmt := 'select count(*) from dual where '||v_cond;
                  v_flgcal := execute_stmt(v_stmt);
                end if;
                if v_flgcal then
                  v_flgcal_ret := 'Y';
                end if;
              end if; -- r2.v_table = '1'
              exit; -- exit c_emp_retro
            end loop; -- c_emp_retro
          end if;-- if para_flgretprd = 'Y' and nvl(para_qtyretpriod,0) > 0 and r_tcontraw.codrtawrd is not null then
          --
          if v_flgcal_ret = 'N' then
            v_dteyrepay	 := para_dteyrepay;
            v_dtemthpay	 := para_dtemthpay;
            v_numperiod	 := para_numperiod;
          end if;*/
-->> user22 : 22/03/2024 : KOHU : #1805 || ไม่จำเป็นต้องเช็คก็ได้/เช็คแล้วทำให้คำนวณตกเบิกแบบระบุกลุ่มไม่ได้
          --
          for r_tpriodal in c_tpriodal loop
            <<next_priodal>> loop
              v_flgcalC := true;
              if not(nvl(r_emp.dtereemp,r_emp.dteempmt) <= r_tpriodal.dtestrt and (r_emp.dteeffex > r_tpriodal.dteend or r_emp.dteeffex is null)) then
                exit next_priodal;
              end if;
              --
              v_dtemovemt := r_tpriodal.dteend;
              std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
                                v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                v_amthour,v_amtday,v_amtmth);

              v_flgcal := true;
              if r_tcontraw.syncond is not null then
                v_cond := r_tcontraw.syncond;
                v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                v_stmt := 'select count(*) from dual where '||v_cond;
                v_flgcal := execute_stmt(v_stmt);
              end if;
              if not v_flgcal then
                exit next_priodal;
              end if;
              --
              if v_first then
                v_first := false;
                begin
                  select qtyaccaw into v_qtyoldacc
                    from tempawrd2
                   where codempid   = v_codempid
                     and codaward   = v_codaward
                     and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') =
                        --<< user22 : 16/12/2021 : ST11 ||
                        (select max(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'))
                           from tpriodal
                          where codcompy   = para_codcompy
                             and typpayroll    = para_typpayroll
                             and codpay       = para_codpay
                            and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') < r_tpriodal.dteyrepay||lpad(r_tpriodal.dtemthpay,2,'0')||lpad(r_tpriodal.numperiod,2,'0'));
                        /*(select max(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'))
                           from tempawrd2
                          where codempid   = v_codempid
                            and codaward   = v_codaward
                            and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') < r_tpriodal.dteyrepay||lpad(r_tpriodal.dtemthpay,2,'0')||lpad(r_tpriodal.numperiod,2,'0'));*/
                        -->> user22 : 16/12/2021 : ST11 ||
                exception when no_data_found then v_qtyoldacc := 0;
                end;
              else
                v_qtyoldacc := v_qtyaccaw;
              end if;
              v_qtyaccaw := v_qtyoldacc;
              if r_tcontraw.numprdclr is not null then
                if r_tpriodal.numperiod = r_tcontraw.numprdclr and
                   r_tpriodal.dtemthpay = r_tcontraw.dtemthclr then
                  v_qtyoldacc := 0;
                  v_qtyaccaw  := 0;
                end if;
              end if;
              --
              begin
                select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0),
                       nvl(sum(qtytlate),0),nvl(sum(qtytearly),0),nvl(sum(qtytabs),0)
                  into v_qtylate,v_qtyearly,v_qtyabsent,
                       v_qtytlate,v_qtytearly,v_qtytabs
                  from tlateabs
                 where codempid = v_codempid
                   and dtework between r_tpriodal.dtestrt and r_tpriodal.dteend;
              exception when no_data_found then null;
              end;
              if v_qtylate > r_tcontraw.qtylate or v_qtyearly > r_tcontraw.qtyearly or v_qtyabsent > r_tcontraw.qtyabsent or
                 v_qtytlate > r_tcontraw.timlate or v_qtytearly > r_tcontraw.timearly or v_qtytabs > r_tcontraw.timabsent or
                 (v_qtylate + v_qtyearly + v_qtyabsent) > r_tcontraw.qtyall or
                 (v_qtytlate + v_qtytearly + v_qtytabs) > r_tcontraw.timall then
                v_flgcalC  := false;
              end if;
              --
							if v_flgcalC then
								begin
									select nvl(sum(qtynostam),0) into v_qtynostam
									  from tattence
									 where codempid = v_codempid
									   and dtework  between r_tpriodal.dtestrt and r_tpriodal.dteend
                     and not exists(select codchng
                                      from tcontaw5
                                     where codcompy = para_codcompy
                                       and codaward = v_codaward
                                       and dteeffec = v_dteeffec
                                       and codchng  = tattence.codchng);
								exception when no_data_found then null;
								end;
								if v_qtynostam > r_tcontraw.timnoatm then
									v_flgcalC := false;
								end if;
							end if;
              --
							if v_flgcalC then
                v_qtymin := 0; v_timleave := 0;
                begin
                  select sum(greatest(a.v_min - decode(b.codleave,null,0,nvl(b.qtyminlv,999999999999999)),0)) as qtyminlv,
                         sum(greatest(a.v_time - decode(b.codleave,null,0,nvl(b.timleave,999999999999999)),0)) as timleave
                    into v_qtymin,v_timleave
                    from (select codleave,nvl(sum(qtymin),0) as v_min,nvl(count(distinct(numlereq)),0) as v_time
                            from tleavetr
                           where codempid = v_codempid
                             and dtework  between r_tpriodal.dtestrt and r_tpriodal.dteend
                        group by codleave) a, tcontaw2 b
                    where a.codleave = b.codleave(+)
                      and b.codcompy(+) = para_codcompy
                      and b.codaward(+) = v_codaward
                      and b.dteeffec(+) = v_dteeffec;
                exception when no_data_found then null;
                end;
                if v_qtymin > 0 or v_timleave > 0 then
                  v_flgcalC := false;
                end if;
							end if;
              --
              if not v_flgcalC then
                v_qtyaccaw := 0;
                delete tempawrd2
                 where codempid   = v_codempid
                   and codaward   = v_codaward
                   and dteyrepay  = r_tpriodal.dteyrepay
                   and dtemthpay  = r_tpriodal.dtemthpay
                   and numperiod  = r_tpriodal.numperiod;

								update tempawrd
								   set qtyaccaw 	= 0,
											 dtecalc  	= para_dteend,
											 coduser    = para_coduser
								 where codempid   = v_codempid
                   and codaward   = v_codaward;
                exit next_priodal;
              elsif v_flgcalC then
                v_qtyaccaw  := v_qtyaccaw + 1;
                v_amtaw     := 0;
								v_flgfound  := false;
                << tcontaw3_loop >>
								for r_tcontaw3 in c_tcontaw3 loop
									v_flgfound := true;
									v_numseq := r_tcontaw3.numseq;
									if r_tcontaw3.syncond is not null then
										v_cond := r_tcontaw3.syncond;
                    v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
										v_stmt := 'select count(*) from dual where '||v_cond;
										v_flgfound := execute_stmt(v_stmt);
									end if;
									if v_flgfound then
										for r_tcontaw4 in c_tcontaw4 loop
											v_flgcalC := true;
											v_amtaw   := cal_formula(v_codempid,r_tcontaw4.formula,para_dteend);
											exit tcontaw3_loop;
										end loop; -- for c_tcontaw4
									end if;
								end loop; -- for c_tcontaw3
                --
                if v_flgfound then
                  begin
                    insert into tempawrd(codempid,codaward,qtyoldacc,qtyaccaw,dtecalc,codcreate,coduser)
                                  values(v_codempid,v_codaward,v_qtyoldacc,v_qtyaccaw,para_dteend,para_coduser,para_coduser);
                  exception when dup_val_on_index then
                    update tempawrd
                       set qtyoldacc	= v_qtyoldacc,
                           qtyaccaw 	= v_qtyaccaw,
                           dtecalc  	= para_dteend,
                           coduser    = para_coduser
                     where codempid   = v_codempid
                       and codaward   = v_codaward;
                  end;

                  begin
                    insert into tempawrd2(dteyrepay,dtemthpay,numperiod,codempid,codaward,qtyaccaw,qtyoldacc,dtecalc,codcreate,coduser)
                                  values(r_tpriodal.dteyrepay,r_tpriodal.dtemthpay,r_tpriodal.numperiod,v_codempid,v_codaward,v_qtyaccaw,v_qtyoldacc,para_dteend,para_coduser,para_coduser);
                  exception when dup_val_on_index then
                    update tempawrd2
                       set qtyoldacc	= v_qtyoldacc,
                           qtyaccaw 	= v_qtyaccaw,
                           dtecalc  	= para_dteend,
                           coduser    = para_coduser
                     where codempid   = v_codempid
                       and codaward   = v_codaward
                       and dteyrepay  = r_tpriodal.dteyrepay
                       and dtemthpay  = r_tpriodal.dtemthpay
                       and numperiod  = r_tpriodal.numperiod;
                  end;
                end if; -- v_flgfound
                --
                if r_tpriodal.dteyrepay||lpad(r_tpriodal.dtemthpay,2,'0')||lpad(r_tpriodal.numperiod,2,'0') < para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0') then
                  v_flgcal_ret := 'Y';
                else
                  v_flgcal_ret := 'N';
                end if;
                if v_flgcal_ret = 'Y' then
                  if v_amtaw > 0 then
                    v_amtretaw := 0; v_amtaw1 := 0; v_amtaw2 := 0;
                    begin
                      select nvl(sum(stddec(amtpay,codempid,para_chken)),0) into v_amtaw1
                        from tpaysum
                       where dteyrepay = r_tpriodal.dteyrepay
                         and dtemthpay = r_tpriodal.dtemthpay
                         and numperiod = r_tpriodal.numperiod
                         and codempid  = v_codempid
                         and codalw		 = para_codapp
                         and codpay		 = para_codpay;
                    exception when no_data_found then v_amtaw1 := 0;
                    end;
                    begin
                      select nvl(sum(stddec(amtretaw,codempid,para_chken)),0) into v_amtaw2
                        from tawrdret
                       where yreretaw  = r_tpriodal.dteyrepay
                         and mthretaw  = r_tpriodal.dtemthpay
                         and prdretaw  = r_tpriodal.numperiod
                         and codempid  = v_codempid
                         and codaward  = v_codaward;
                    exception when no_data_found then v_amtaw2 := 0;
                    end;
                    v_amtretaw := v_amtaw - (v_amtaw1 + v_amtaw2);
                    if v_amtretaw > 0 then
                      begin
                        insert into tawrdret(dteyrepay,dtemthpay,numperiod,codempid,codaward,yreretaw,mthretaw,prdretaw,amtretaw,codcreate,coduser)
                                      values(para_dteyrepay,para_dtemthpay,para_numperiod,v_codempid,v_codaward,r_tpriodal.dteyrepay,r_tpriodal.dtemthpay,r_tpriodal.numperiod,stdenc(v_amtretaw,v_codempid,para_chken),para_coduser,para_coduser);
                      exception when dup_val_on_index then
                        update tawrdret
                           set amtretaw  = stdenc(v_amtretaw,v_codempid,para_chken),
                               coduser   = para_coduser
                         where dteyrepay = para_dteyrepay
                           and dtemthpay = para_dtemthpay
                           and numperiod = para_numperiod
                           and codempid  = v_codempid
                           and codaward  = v_codaward
                           and yreretaw  = r_tpriodal.dteyrepay
                           and mthretaw  = r_tpriodal.dtemthpay
                           and prdretaw  = r_tpriodal.numperiod;
                      end;
                      --
                      upd_tpaysum(v_codempid,'RET_AWARD',r_tcontraw.codrtawrd,v_codcomp,v_codpos,v_typpayroll,0,0,0,0,v_amtretaw);
                      para_numrec := nvl(para_numrec,0) + 1;
                    end if; -- v_amtretaw > 0
                  end if; -- v_amtaw > 0
                else
                  if v_amtaw > 0 then
                    upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,0,0,0,0,v_amtaw);
                    para_numrec := nvl(para_numrec,0) + 1;
                  end if; -- v_amtaw > 0
                end if; -- v_flgcal_ret = 'Y'
              end if; -- not v_flgcalC
              --
              exit next_priodal;
            end loop; -- next_priodal
          end loop; --c_tpriodal
        end loop; -- c_tcontraw999999999
        --
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2	 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
/*  --<< 29/06/2021
  procedure cal_pay_award(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number) is
		v_codaward		tcontraw.codaward%type;
		v_dteeffec		date;
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
    o_codempid		temploy1.codempid%type;
		v_staemp			temploy1.staemp%type;
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

		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_numseq		 	number := 0;
		v_qtyoldacc  	number := 0;
		v_qtyaccaw   	number := 0;
		v_qtylate 		number := 0;
		v_qtyearly 		number := 0;
		v_qtyabsent 	number := 0;
		v_qtytlate 		number := 0;
		v_qtytearly 	number := 0;
		v_qtytabs 		number := 0;
		v_qtynostam 	number := 0;
		v_qtymin 			number := 0;
    v_timleave		number := 0;
		v_check				varchar2(1) := 'N';
		v_flgcal			boolean;
		v_flgcalR			boolean;
		v_flgcalC			boolean;
		v_first				boolean;
		v_zupdsal   	varchar2(4);

		v_dteyrepay		number;
		v_dtemthpay		number;
		v_numperiod		number;
		v_amtaw1   		number := 0;
		v_amtaw2   		number := 0;
		v_amtretaw		number := 0;
		v_sumamtretaw	number := 0;
		v_num					number := 0;
		v_amtaw				number := 0;
    v_dtestrt     date;
    v_dteend      date;
    v_dteend_max  date;
    v_dtemovemt   date;
    v_amthour     number := 0;
    v_amtday      number := 0;
    v_amtmth      number := 0;

	cursor c_emp is
		select a.codempid,staemp,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl,dteempmt,dteeffex
	 	  from tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
	order by a.codempid;

	cursor c_emp_retro is
		select a_table.codempid,a_table.v_table,b.dteempmt,b.dteeffex
	 	  from(
           select codempid, '1' as v_table
             from ttmovemt
            where dteeffec  < v_dteend_max
              and(dtecreate > v_dteend
               or dteupd    > v_dteend)
              and staupd    in ('C','U')
              and((codcomp <> codcompt) or (codpos <> codposnow) or (numlvl <>numlvlt)
               or(codjob    <>codjobt) or (codempmt <> codempmtt) or (typemp <> typempt)
               or(typpayroll <> typpayrolt) or (codbrlc <> codbrlct) or (codcalen <> codcalet)
               or(jobgrade <> jobgradet) or (codgrpgl <> codgrpglt))
      union
           select codempid, '2' as v_table
             from tlogtime
            where dtework   between v_dtestrt and v_dteend_max
              and dteupd    > v_dteend
      union
           select codempid, '2' as v_table
             from tloglate
            where dtework   between v_dtestrt and v_dteend_max
              and dteupd    > v_dteend
      union
           select codempid, '2' as v_table
             from tlogleav
            where dtework   between v_dtestrt and v_dteend_max
              and dteupd    > v_dteend
      union
           select codempid, '2' as v_table
             from tlateabs
            where dtework   between v_dtestrt and v_dteend_max
              and(dtecreate > v_dteend
               or dteupd    > v_dteend)
      union
           select codempid, '2' as v_table
             from tleavetr
            where dtework   between v_dtestrt and v_dteend_max
              and(dtecreate > v_dteend
               or dteupd    > v_dteend)
              ) a_table, tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
       and a.codempid = a_table.codempid
	order by a_table.codempid,a_table.v_table;

	cursor c_tcontraw_codaward is
		select codaward,max(dteeffec) dteeffec
		  from tcontraw
		 where codcompy = para_codcompy
		   and dteeffec <= trunc(sysdate)
		   and codpay		= para_codpay
	group by codaward;

	cursor c_tcontraw is
		select codcompy,codaward,dteeffec,syncond,codpay,qtylate,qtyearly,qtyabsent,qtyall,timlate,timearly,timabsent,timall,timnoatm,codrtawrd,
           numprdclr,dtemthclr
		  from tcontraw
		 where codcompy = para_codcompy
		   and codaward = v_codaward
		   and dteeffec = v_dteeffec;

	cursor c_tempawrd is
		select qtyoldacc,qtyaccaw,dtecalc,rowid
		  from tempawrd
		 where codempid = v_codempid
		   and codaward = v_codaward;

	cursor c_tcontaw3 is
		select numseq,syncond
		  from tcontaw3
		 where codcompy = para_codcompy
		   and codaward = v_codaward
		   and dteeffec = v_dteeffec
	order by numseq;

	cursor c_tcontaw4 is
		select qtyaw,formula
		  from tcontaw4
		 where codcompy = para_codcompy
		   and codaward = v_codaward
		   and dteeffec = v_dteeffec
		   and numseq		= v_numseq
		   and qtyaw   <= v_qtyaccaw
	order by qtyaw desc;

	cursor c_tpriodal_1 is
		select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
		  from tpriodal
		 where codcompy   = para_codcompy
		   and typpayroll = para_typpayroll
		   and codpay	    = para_codpay
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') < para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0')
	 order by dteyrepay desc,dtemthpay desc,numperiod desc;

	cursor c_tpriodal_2 is
		select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
		  from tpriodal
		 where codcompy   = para_codcompy
		   and typpayroll = para_typpayroll
		   and codpay	    = para_codpay
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') >= v_dteyrepay||lpad(v_dtemthpay,2,'0')||lpad(v_numperiod,2,'0')
		   and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <  para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0')
	order by dteyrepay,dtemthpay,numperiod;

	begin

		for r1 in c_tcontraw_codaward loop
			v_check := 'Y';
			exit;
		end loop;
		if v_check = 'N' then
			return;
		end if;
		if para_flgretprd = 'Y' and nvl(para_qtyretpriod,0) > 0 then
			for r_tpriodal in c_tpriodal_1 loop
				v_num := v_num + 1;
				v_dteyrepay	 := r_tpriodal.dteyrepay;
				v_dtemthpay	 := r_tpriodal.dtemthpay;
				v_numperiod	 := r_tpriodal.numperiod;
        v_dtestrt    := least(nvl(v_dtestrt,r_tpriodal.dtestrt),r_tpriodal.dtestrt);
        v_dteend     := least(nvl(v_dteend,r_tpriodal.dteend),r_tpriodal.dteend);
        v_dteend_max := greatest(nvl(v_dteend_max,r_tpriodal.dteend),r_tpriodal.dteend);
				if v_num >= para_qtyretpriod then
					exit;
				end if;
			end loop;

      for r_emp in c_emp_retro loop
        << main_loop >> loop
          v_codempid := r_emp.codempid;
          begin
            select staemp into v_staemp
              from temploy1
             where codempid = v_codempid;
          exception when no_data_found then null;
          end;
          if nvl(o_codempid,'!@#$%^&^%$$#') = v_codempid then
            exit main_loop;
          end if;
          o_codempid := v_codempid;
          --
          for r1 in c_tcontraw_codaward loop
            v_codaward := r1.codaward;
            v_dteeffec := r1.dteeffec;
            for r_tcontraw in c_tcontraw loop
              if r_tcontraw.codrtawrd is not null then
                if r_emp.v_table = '1' then
                  for r_tpriodal in c_tpriodal_2 loop
                    v_dtemovemt := r_tpriodal.dteend;
                    std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                      v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                      v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                      v_amthour,v_amtday,v_amtmth);
                    v_flgcal := true;
                    if r_tcontraw.syncond is not null then
                      v_cond := r_tcontraw.syncond;
                      v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                      v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                      v_stmt := 'select count(*) from dual where '||v_cond;
                      v_flgcal := execute_stmt(v_stmt);
                    end if;
                    if v_flgcal then
                      exit;
                    end if;
                    --
                    update tempawrd2
                       set --qtyoldacc	= 0,
                           qtyaccaw 	= 0,
                           coduser    = para_coduser
                     where dteyrepay  = r_tpriodal.dteyrepay
                       and dtemthpay  = r_tpriodal.dtemthpay
                       and numperiod  = r_tpriodal.numperiod
                       and codempid   = v_codempid
                       and codaward   = v_codaward;

                    update tempawrd
                       set --qtyoldacc	= 0,
                           qtyaccaw 	= 0,
                           dtecalc  	= r_tpriodal.dteend,
                           coduser    = para_coduser
                     where codempid   = v_codempid
                       and codaward   = v_codaward;
                  end loop; -- c_tpriodal_2 loop
                  if not v_flgcal then
                    exit main_loop;
                  end if;
                else --  r_emp.v_table = '2'
                  v_dtemovemt := sysdate;
                  std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                    v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                    v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                    v_amthour,v_amtday,v_amtmth);
                  v_flgcal := true;
                  if r_tcontraw.syncond is not null then
                    v_cond := r_tcontraw.syncond;
                    v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                    v_stmt := 'select count(*) from dual where '||v_cond;
                    v_flgcal := execute_stmt(v_stmt);
                  end if;
                  if not v_flgcal then
                    exit main_loop;
                  end if;
                end if; -- r_emp.v_table = '1' then
                --
                v_flgtran := chk_tpaysum(v_codempid,'RET_AWARD',r_tcontraw.codrtawrd);
                if v_flgtran = 'Y' then
                  exit main_loop;
                end if;
                del_tpaysum(v_codempid,'RET_AWARD',r_tcontraw.codrtawrd);
                delete tawrdret
                 where dteyrepay = para_dteyrepay
                   and dtemthpay = para_dtemthpay
                   and numperiod = para_numperiod
                   and codempid  = v_codempid
                   and codaward  = v_codaward;
                --
                v_first := true;
                v_sumamtretaw := 0;
                for r_tpriodal in c_tpriodal_2 loop
                  <<next_priodal>> loop
                    if not(r_emp.dteempmt <= r_tpriodal.dtestrt and (r_emp.dteeffex > r_tpriodal.dteend or r_emp.dteeffex is null)) then
                      exit next_priodal;
                    end if;
                    --
                    v_dtemovemt := r_tpriodal.dteend;
                    std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
                                      v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                      v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                      v_amthour,v_amtday,v_amtmth);
                    v_flgcal := true;
                    if r_tcontraw.syncond is not null then
                      v_cond := r_tcontraw.syncond;
                      v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                      v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                      v_stmt := 'select count(*) from dual where '||v_cond;
                      v_flgcal := execute_stmt(v_stmt);
                    end if;
                    if not v_flgcal then
                      exit next_priodal;
                    end if;
                    --
                    v_flgcalR   := true;
                    if v_flgcalR then
                      begin
                        select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0),
                               nvl(sum(qtytlate),0),nvl(sum(qtytearly),0),nvl(sum(qtytabs),0)
                          into v_qtylate,v_qtyearly,v_qtyabsent,
                               v_qtytlate,v_qtytearly,v_qtytabs
                          from tlateabs
                         where codempid = v_codempid
                           and dtework between nvl(r_tpriodal.dtestrt,dtework) and r_tpriodal.dteend;
                      exception when no_data_found then null;
                      end;
                      if v_qtylate > r_tcontraw.qtylate or v_qtyearly > r_tcontraw.qtyearly or v_qtyabsent > r_tcontraw.qtyabsent or
                         v_qtytlate > r_tcontraw.timlate or v_qtytearly > r_tcontraw.timearly or v_qtytabs > r_tcontraw.timabsent or
                         (v_qtylate + v_qtyearly + v_qtyabsent) > r_tcontraw.qtyall or
                         (v_qtytlate + v_qtytearly + v_qtytabs) > r_tcontraw.timall then
                        v_flgcalR := false;
                      end if;
                    end if;

                    if v_flgcalR then
                      begin
                        select nvl(sum(qtynostam),0) into v_qtynostam
                          from tattence
                         where codempid = v_codempid
                           and dtework between nvl(r_tpriodal.dtestrt,dtework) and r_tpriodal.dteend
                           and not exists(select codchng
                                            from tcontaw5
                                           where codcompy = para_codcompy
                                             and codaward = v_codaward
                                             and dteeffec = v_dteeffec
                                             and codchng  = tattence.codchng);
                      exception when no_data_found then null;
                      end;
                      if v_qtynostam > r_tcontraw.timnoatm then
                        v_flgcalR := false;
                      end if;
                    end if;
                    if v_flgcalR then
                      v_qtymin := 0; v_timleave := 0;
                      begin
                        select sum(greatest(a.v_min - decode(b.codleave,null,0,nvl(b.qtyminlv,999999999999999)),0)) as qtyminlv,
                               sum(greatest(a.v_time - decode(b.codleave,null,0,nvl(b.timleave,999999999999999)),0)) as timleave
                          into v_qtymin,v_timleave
                          from (select codleave,nvl(sum(qtymin),0) as v_min,nvl(count(distinct(numlereq)),0) as v_time
                                  from tleavetr
                                 where codempid = v_codempid
                                   and dtework between nvl(r_tpriodal.dtestrt,dtework) and r_tpriodal.dteend
                              group by codleave) a, tcontaw2 b
                          where a.codleave = b.codleave(+)
                            and b.codcompy(+) = para_codcompy
                            and b.codaward(+) = v_codaward
                            and b.dteeffec(+) = v_dteeffec;
                      exception when no_data_found then null;
                      end;
                      if v_qtymin > 0 or v_timleave > 0 then
                        v_flgcalR := false;
                      end if;
                    end if;
                    --
                    if v_first then
                      v_first := false;
                      begin
                        select qtyoldacc into v_qtyoldacc
                          from tempawrd2
                         where dteyrepay  = r_tpriodal.dteyrepay
                           and dtemthpay  = r_tpriodal.dtemthpay
                           and numperiod  = r_tpriodal.numperiod
                           and codempid   = v_codempid
                           and codaward   = v_codaward;
                      exception when no_data_found then v_qtyoldacc := 0;
                      end;
                    else
                      v_qtyoldacc := v_qtyaccaw;
                    end if;
                    v_qtyaccaw := v_qtyoldacc;
                    if r_tcontraw.numprdclr is not null then
                      if r_tpriodal.numperiod = r_tcontraw.numprdclr and
                         r_tpriodal.dtemthpay = r_tcontraw.dtemthclr then
                        v_qtyoldacc := 0;
                        v_qtyaccaw  := 0;
                      end if;
                    end if;
                    --
                    if v_flgcalR then
                      v_qtyaccaw  := v_qtyaccaw + 1;
                      << tcontaw3_loop >>
                      for r_tcontaw3 in c_tcontaw3 loop
                        v_numseq   := r_tcontaw3.numseq;
                        v_flgfound := true;
                        if r_tcontaw3.syncond is not null then
                          v_cond := r_tcontaw3.syncond;
                          v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                          v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                          v_stmt := 'select count(*) from dual where '||v_cond;
                          v_flgfound := execute_stmt(v_stmt);
                        end if;
                        if v_flgfound then
                          for r_tcontaw4 in c_tcontaw4 loop
                            v_amtretaw := 0; v_amtaw1 := 0; v_amtaw2 := 0;
                            v_amtaw    := cal_formula(v_codempid,r_tcontaw4.formula,r_tpriodal.dteend);
                            begin
                              select nvl(sum(stddec(amtpay,codempid,para_chken)),0) into v_amtaw1
                                from tpaysum
                               where dteyrepay = r_tpriodal.dteyrepay
                                 and dtemthpay = r_tpriodal.dtemthpay
                                 and numperiod = r_tpriodal.numperiod
                                 and codempid  = v_codempid
                                 and codalw		 = para_codapp
                                 and codpay		 = para_codpay;
                            exception when no_data_found then v_amtaw1 := 0;
                            end;
                            begin
                              select nvl(sum(stddec(amtretaw,codempid,para_chken)),0) into v_amtaw2
                                from tawrdret
                               where yreretaw  = r_tpriodal.dteyrepay
                                 and mthretaw  = r_tpriodal.dtemthpay
                                 and prdretaw  = r_tpriodal.numperiod
                                 and codempid  = v_codempid
                                 and codaward  = v_codaward;
                            exception when no_data_found then v_amtaw2 := 0;
                            end;
                            v_amtretaw := v_amtaw - (v_amtaw1 + v_amtaw2);
                            if v_amtretaw > 0 then
                              v_sumamtretaw  := v_sumamtretaw + v_amtretaw;
                              begin
                                insert into tawrdret(dteyrepay,dtemthpay,numperiod,codempid,codaward,yreretaw,mthretaw,prdretaw,amtretaw,codcreate,coduser)
                                              values(para_dteyrepay,para_dtemthpay,para_numperiod,v_codempid,v_codaward,r_tpriodal.dteyrepay,r_tpriodal.dtemthpay,r_tpriodal.numperiod,stdenc(v_amtretaw,v_codempid,para_chken),para_coduser,para_coduser);
                              exception when dup_val_on_index then
                                update tawrdret
                                   set amtretaw  = stdenc(v_amtretaw,v_codempid,para_chken),
                                       coduser   = para_coduser
                                 where dteyrepay = para_dteyrepay
                                   and dtemthpay = para_dtemthpay
                                   and numperiod = para_numperiod
                                   and codempid  = v_codempid
                                   and codaward  = v_codaward
                                   and yreretaw  = r_tpriodal.dteyrepay
                                   and mthretaw  = r_tpriodal.dtemthpay
                                   and prdretaw  = r_tpriodal.numperiod;
                              end;
                            end if;
                            exit tcontaw3_loop;
                          end loop; -- for c_tcontaw4
                        end if; -- v_flgfound then
                      end loop; -- for c_tcontaw3
                    else
                      v_qtyaccaw	:= 0;
                    end if;

                    begin
                      insert into tempawrd2(dteyrepay,dtemthpay,numperiod,codempid,codaward,qtyaccaw,qtyoldacc,dtecalc,codcreate,coduser)
                                    values(r_tpriodal.dteyrepay,r_tpriodal.dtemthpay,r_tpriodal.numperiod,v_codempid,v_codaward,v_qtyaccaw,v_qtyoldacc,r_tpriodal.dteend,para_coduser,para_coduser);
                    exception when dup_val_on_index then
                      update tempawrd2
                         set qtyoldacc	= v_qtyoldacc,
                             qtyaccaw 	= v_qtyaccaw,
                             dtecalc  	= r_tpriodal.dteend,
                             coduser    = para_coduser
                       where dteyrepay  = r_tpriodal.dteyrepay
                         and dtemthpay  = r_tpriodal.dtemthpay
                         and numperiod  = r_tpriodal.numperiod
                         and codempid   = v_codempid
                         and codaward   = v_codaward;
                    end;

                    begin
                      insert into tempawrd(codempid,codaward,qtyoldacc,qtyaccaw,dtecalc,codcreate,coduser)
                                    values(v_codempid,v_codaward,v_qtyoldacc,v_qtyaccaw,r_tpriodal.dteend,para_coduser,para_coduser);
                    exception when dup_val_on_index then
                      update tempawrd
                         set qtyoldacc	= v_qtyoldacc,
                             qtyaccaw 	= v_qtyaccaw,
                             dtecalc  	= r_tpriodal.dteend,
                             coduser    = para_coduser
                       where codempid   = v_codempid
                         and codaward   = v_codaward;
                    end;
                    --
                    exit next_priodal; null;
                  end loop; -- next_priodal
                end loop; -- c_tpriodal_2 loop
                if v_sumamtretaw > 0 then
                  upd_tpaysum(v_codempid,'RET_AWARD',r_tcontraw.codrtawrd,v_codcomp,v_codpos,v_typpayroll,0,0,0,0,v_sumamtretaw);
                  para_numrec := nvl(para_numrec,0) + 1;
                end if;
              end if; -- r_tcontraw.codrtawrd is not null
            end loop; -- c_tcontraw loop
          end loop; -- c_tcontraw_codaward loop
          commit;
          exit main_loop; null;
        end loop; -- main_loop
      end loop; -- for r_emp
		end if; --para_flgretprd = 'Y' and nvl(para_qtyretpriod,0) > 0

-- Current Period
	  for r_emp in c_emp loop
			<< main_loop >> loop
				v_codempid   := r_emp.codempid;
				v_staemp		 := r_emp.staemp;
				v_codcomp	   := r_emp.codcomp;
        v_codpos  	 := r_emp.codpos;
				v_numlvl  	 := r_emp.numlvl;
        v_codjob     := r_emp.codjob;
				v_codempmt   := r_emp.codempmt;
        v_typemp		 := r_emp.typemp;
				v_typpayroll := r_emp.typpayroll;
				v_codbrlc    := r_emp.codbrlc;
        v_codcalen   := r_emp.codcalen;
				v_jobgrade	 := r_emp.jobgrade;
        v_codgrpgl	 := r_emp.codgrpgl;
        --
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				del_tpaysum(v_codempid,para_codapp,para_codpay);

				for r1 in c_tcontraw_codaward loop
					indx_codempid2 := v_codempid;
					v_codaward := r1.codaward;
					v_dteeffec := r1.dteeffec;
					for r_tcontraw in c_tcontraw loop
						v_flgcal      := true;
						v_first       := true;
						v_sumamtretaw := 0;
						if r_tcontraw.syncond is not null then
							v_cond := r_tcontraw.syncond;
              v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
              v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
              v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
              v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
              v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
              v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
              v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
							v_stmt := 'select count(*) from dual where '||v_cond;
							v_flgcal := execute_stmt(v_stmt);
						end if;
						if v_flgcal then
							v_flgcalC := true;
							if v_flgcalC then
								if r_emp.dteempmt > para_v_dtestrt or (r_emp.dteeffex <= para_dteend and r_emp.dteeffex is not null) then
									exit main_loop;
								end if;
								begin
									select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0),
												 nvl(sum(qtytlate),0),nvl(sum(qtytearly),0),nvl(sum(qtytabs),0)
						 			  into v_qtylate,v_qtyearly,v_qtyabsent,
						 						 v_qtytlate,v_qtytearly,v_qtytabs
									  from tlateabs
									 where codempid = v_codempid
									   and dtework between nvl(para_v_dtestrt,dtework) and para_dteend;

								exception when no_data_found then null;
								end;
								if v_qtylate > r_tcontraw.qtylate or v_qtyearly > r_tcontraw.qtyearly or v_qtyabsent > r_tcontraw.qtyabsent or
									 v_qtytlate > r_tcontraw.timlate or v_qtytearly > r_tcontraw.timearly or v_qtytabs > r_tcontraw.timabsent or
								   (v_qtylate + v_qtyearly + v_qtyabsent) > r_tcontraw.qtyall or
								   (v_qtytlate + v_qtytearly + v_qtytabs) > r_tcontraw.timall then
									v_flgcalC := false;
								end if;
							end if;

							if v_flgcalC then
								begin
									select nvl(sum(qtynostam),0) into v_qtynostam
									  from tattence
									 where codempid = v_codempid
									   and dtework between nvl(para_v_dtestrt,dtework) and para_dteend
                     and not exists(select codchng
                                      from tcontaw5
                                     where codcompy = para_codcompy
                                       and codaward = v_codaward
                                       and dteeffec = v_dteeffec
                                       and codchng  = tattence.codchng);
								exception when no_data_found then null;
								end;
								if v_qtynostam > r_tcontraw.timnoatm then
									v_flgcalC := false;
								end if;
							end if;

							if v_flgcalC then
                v_qtymin := 0; v_timleave := 0;
                begin
                  select sum(greatest(a.v_min - decode(b.codleave,null,0,nvl(b.qtyminlv,999999999999999)),0)) as qtyminlv,
                         sum(greatest(a.v_time - decode(b.codleave,null,0,nvl(b.timleave,999999999999999)),0)) as timleave
                    into v_qtymin,v_timleave
                    from (select codleave,nvl(sum(qtymin),0) as v_min,nvl(count(distinct(numlereq)),0) as v_time
                            from tleavetr
                           where codempid = v_codempid
                             and dtework between nvl(para_v_dtestrt,dtework) and para_dteend
                        group by codleave) a, tcontaw2 b
                    where a.codleave = b.codleave(+)
                      and b.codcompy(+) = para_codcompy
                      and b.codaward(+) = v_codaward
                      and b.dteeffec(+) = v_dteeffec;
                exception when no_data_found then null;
                end;
                if v_qtymin > 0 or v_timleave > 0 then
                  v_flgcalC := false;
                end if;
							end if;
              --
							v_qtyaccaw	:= 0;
              for r_tpriodal in c_tpriodal_1 loop
                begin
                  select qtyaccaw into v_qtyaccaw
                    from tempawrd2
                   where dteyrepay  = r_tpriodal.dteyrepay
                     and dtemthpay  = r_tpriodal.dtemthpay
                     and numperiod  = r_tpriodal.numperiod
                     and codempid   = v_codempid
                     and codaward   = v_codaward;
                exception when no_data_found then v_qtyaccaw := null;
                end;
                exit;
              end loop;

              if v_qtyaccaw is null then
                for r_tempawrd in c_tempawrd loop
                  if r_tempawrd.dtecalc = para_dteend then
                    v_qtyaccaw	:= nvl(r_tempawrd.qtyoldacc,0);
                  else
                    v_qtyaccaw	:= nvl(r_tempawrd.qtyaccaw,0);
                  end if;
                end loop;
              end if;
              v_qtyaccaw  := nvl(v_qtyaccaw,0);
							v_qtyoldacc := v_qtyaccaw;
              --
              if r_tcontraw.numprdclr is not null then
                if para_numperiod = r_tcontraw.numprdclr and
                   para_dtemthpay = r_tcontraw.dtemthclr then
                  v_qtyoldacc := 0;
                  v_qtyaccaw  := 0;
                end if;
              end if;
							if v_flgcalC then
								v_flgcalC := false;
								v_qtyaccaw  := v_qtyaccaw + 1;
								<< tcontaw3_loop >>
								for r_tcontaw3 in c_tcontaw3 loop
									v_flgfound := true;
									v_numseq := r_tcontaw3.numseq;
									if r_tcontaw3.syncond is not null then
										v_cond := r_tcontaw3.syncond;
                    v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
										v_stmt := 'select count(*) from dual where '||v_cond;
										v_flgfound := execute_stmt(v_stmt);
									end if;
									if v_flgfound then
										for r_tcontaw4 in c_tcontaw4 loop
											v_flgcalC := true;
											v_amtaw   := cal_formula(v_codempid,r_tcontaw4.formula,para_dteend);
											if v_amtaw > 0 then
												upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
																		0,0,0,0,v_amtaw);
												para_numrec := nvl(para_numrec,0) + 1;
											end if;
											exit tcontaw3_loop;
										end loop; -- for c_tcontaw4
									end if;
								end loop; -- for c_tcontaw3
							else
								v_qtyaccaw	:= 0;
							end if;

							begin
								insert into tempawrd(codempid,codaward,qtyoldacc,qtyaccaw,dtecalc,codcreate,coduser)
								              values(v_codempid,v_codaward,v_qtyoldacc,v_qtyaccaw,para_dteend,para_coduser,para_coduser);
						  exception when dup_val_on_index then
								update tempawrd
								   set qtyoldacc	= v_qtyoldacc,
											 qtyaccaw 	= v_qtyaccaw,
											 dtecalc  	= para_dteend,
											 coduser    = para_coduser
								 where codempid   = v_codempid
									 and codaward   = v_codaward;
							end;

							begin
								insert into tempawrd2(dteyrepay,dtemthpay,numperiod,codempid,codaward,qtyaccaw,qtyoldacc,dtecalc,codcreate,coduser)
								              values(para_dteyrepay,para_dtemthpay,para_numperiod,v_codempid,v_codaward,v_qtyaccaw,v_qtyoldacc,para_dteend,para_coduser,para_coduser);
						  exception when dup_val_on_index then
								update tempawrd2
								   set qtyoldacc	= v_qtyoldacc,
											 qtyaccaw 	= v_qtyaccaw,
                       dtecalc  	= para_dteend,
											 coduser    = para_coduser
								 where dteyrepay  = para_dteyrepay
								   and dtemthpay  = para_dtemthpay
									 and numperiod  = para_numperiod
									 and codempid   = v_codempid
									 and codaward   = v_codaward;
							end;
						end if; -- if v_flgcal then
					end loop; -- for c_tcontraw
				end loop; -- for c1
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2	 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
*/  -->> 29/06/2021
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_pay_vacat(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number) is

		v_flgsecu 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_codpos			temploy1.codpos%type;
		v_codcomp			temploy1.codcomp%type;
		v_typpayroll	temploy1.typpayroll%type;
		v_amtday	 		number := 0;
		v_amtlepay	 	number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin 	number := 0;
		v_sumamtpay  	number := 0;
		v_qtyavgwk   	number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_zupdsal   	varchar2(4);

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codpos,numlvl
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tpayvac is
			select rowid,dtereq,qtylepay,amtday,amtlepay
			  from tpayvac
			 where dteyrepay = para_dteyrepay
			   and dtemthpay = para_dtemthpay
			   and numperiod = para_numperiod
				 and codempid  = v_codempid
				 and staappr	 = 'Y'
				 and flgcalvac = 'N';
	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				begin
					select qtyavgwk into v_qtyavgwk
						from tcontral
					 where codcompy	= hcm_util.get_codcomp_level(r_emp.codcomp,1)
						 and dteeffec	= ( select max(dteeffec)
															  from tcontral
															 where codcompy	= hcm_util.get_codcomp_level(r_emp.codcomp,1)
															   and dteeffec <= sysdate);
				exception when no_data_found then v_qtyavgwk := 0;
				end;
				v_codempid := r_emp.codempid;
				v_codpos   := r_emp.codpos;
				v_codcomp	 := r_emp.codcomp;
				v_typpayroll := r_emp.typpayroll;

				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;

				update tpayvac
				   set flgcalvac = 'N'
				 where dteyrepay = para_dteyrepay
				   and dtemthpay = para_dtemthpay
				   and numperiod = para_numperiod
				   and codempid  = v_codempid;

				del_tpaysum(v_codempid,para_codapp,null);

				v_sumqtyday := 0;	v_sumqtymin := 0; v_sumamtpay := 0;
				for r_tpayvac in c_tpayvac loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tpayvac.dtereq;

					v_qtymin    := r_tpayvac.qtylepay * v_qtyavgwk;
					v_qtyday    := r_tpayvac.qtylepay;
					v_amtlepay  := nvl(stddec(r_tpayvac.amtlepay,v_codempid,para_chken),0);
	        v_amtday    := nvl(stddec(r_tpayvac.amtday,v_codempid,para_chken),0);

					v_sumqtyday := v_sumqtyday + v_qtyday;
					v_sumqtymin := v_sumqtymin + v_qtymin;
					v_sumamtpay := v_sumamtpay + v_amtlepay;
					upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                 r_tpayvac.dtereq,' ',null,null,v_qtymin,v_amtlepay,null,v_amtday);
					update tpayvac
						set flgcalvac = 'Y'
						where rowid = r_tpayvac.rowid;
				end loop; -- for c_tpayvac
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											0,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_pay_other(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number) is
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgworkth		varchar2(10);

		v_dteeffec		date;
		v_dtework 		date;
    z_dtework 		date;
		v_syncond1		tcontals.syncond%type;

		v_first				boolean := true;
		v_dtemovemt		date;

		v_codempid		temploy1.codempid%type;
    z_codempid		temploy1.codempid%type;
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

		v_amthour		 	number := 0;
		v_amtday			number := 0;
		v_amtmth			number := 0;

		v_flgtran   	tpaysum.flgtran%type;
		v_stmt				varchar2(4000);
		v_cond				varchar2(4000);
		v_amtpay      number;
		v_qtymin	 		number := 0;
		v_qtyminle	 	number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		o_codempid		temploy1.codempid%type;
		v_code				temploy1.codempid%type;

		v_codpay 			tinexinf.codpay%type;
		v_qtylate			number := 0;
		v_qtyearly		number := 0;
		v_zupdsal   	varchar2(4);
		v_flag		 		boolean;
		v_typot				varchar2(10);
		v_dtestrt  		date;
		v_dteend  		date;
		v_typworkot		tattence.typwork%type;
		v_flgpay      varchar2(1);
		v_typcal      varchar2(1);
    v_qtydaywk    number := 0; --user36 03/12/2020

		type number1 is table of number index by binary_integer;
				v_amtincom	 number1;

	cursor c_temploy1 is
		select a.codempid,codcomp,numlvl,staemp,dteempmt,dteeffex,codpos
	 	  from tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
	order by a.codempid;

	cursor c_tcontals is
		select dteeffec,typwork,typpayot,flgotb,flgotd,flgota,syncond
		  from tcontals
		 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
		   and codpay	  = para_codpay
		   and dteeffec = (select max(dteeffec)
											   from tcontals
 											  where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
												  and codpay	  = para_codpay
												  and dteeffec <= para_dtework);

	cursor c_tcontald is
		select syncond,qtyhrwks,qtyhrwke,timstrtw,timendw,formula
		  from tcontald
		 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
		   and codpay		= para_codpay
		   and dteeffec = v_dteeffec
	order by numseq;

	cursor c_tattence is
		select dtework,codshift,codcomp,codcalen,qtyhwork,typwork,dtein,timin,dteout,timout,dtestrtw,timstrtw,dteendw,timendw
		  from tattence
		 where codempid = v_codempid
		   and dtework between nvl(para_dtestr,dtework) and para_dteend
	     and not exists(select codempid
	                      from tpaysum2
									     where codempid = v_codempid
									       and codalw	  = para_codapp
									       and codpay	  = para_codpay
									       and dtework	= tattence.dtework
									       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
		order by dtework;

	cursor c_tovrtime is
		select dtework,codcomp,codshift,codcalen,qtyminot,dtestrt,timstrt,dteend,timend,typwork,typot,typpayroll
	 	  from tovrtime
		 where codempid = v_codempid
		   and dtework between nvl(para_dtestr,dtework) and para_dteend
		   and not exists(select codempid
		                    from tpaysum2
										   where codempid = v_codempid
										     and codalw	  = para_codapp
										     and codpay	  = para_codpay
										     and dtework  = tovrtime.dtework
									       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
		order by dtework;

	cursor c_tovrtime_sum is
		select dtework,sum(qtyminot) qtyminot,
		       min(to_date(to_char(dtestrt,'dd/mm/yyyy')||timstrt,'dd/mm/yyyyhh24mi')) dtestrtot,
		       max(to_date(to_char(dteend,'dd/mm/yyyy')||timend,'dd/mm/yyyyhh24mi')) dteendot
		  from tovrtime
		 where codempid = v_codempid
		   and dtework  = para_dtework
		   and v_typot  like '%'||typot||'%'
  group by dtework;

	cursor d_tpaysum is
		select rowid,dteyrepay,dtemthpay,numperiod,codempid,codalw,codpay
		  from tpaysum
		 where dteyrepay  = para_dteyrepay
		   and dtemthpay  = to_number(para_dtemthpay)
		   and numperiod  = para_numperiod
       and exists (select codempid
								 	   from tprocemp
									  where tprocemp.codempid = tpaysum.codempid
							   		  and codapp   = para_codapp_wh
							  		  and coduser  = p_coduser
							  		  and numproc  = p_numproc)
			 and codalw		  = para_codapp
			 and codpay		  = para_codpay
			 and flgtran	  = 'N';
	begin
		for r_tpaysum in d_tpaysum loop
			delete from tpaysum2
			 where dteyrepay = r_tpaysum.dteyrepay
				 and dtemthpay = r_tpaysum.dtemthpay
				 and numperiod = r_tpaysum.numperiod
				 and codempid  = r_tpaysum.codempid
				 and codalw		 = r_tpaysum.codalw
				 and codpay		 = r_tpaysum.codpay;
			delete from tpaysum where rowid = r_tpaysum.rowid;
		end loop;
		commit;
    --
    for r_emp in c_temploy1 loop
      << main_loop >> loop
        v_codempid    := r_emp.codempid;
        v_codcomp     := r_emp.codcomp;
        v_numlvl	  := r_emp.numlvl;
        v_staemp	  := r_emp.staemp;
        para_dteempmt := r_emp.dteempmt;
        para_dteeffex := r_emp.dteeffex;
        if v_staemp = '0' then
          exit main_loop;
        end if;
        for i in 1..10 loop
          v_amtincom(i) := null;
        end loop;

        --------------------------------------------------------------
        v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
        if v_flgtran = 'Y' then
          exit main_loop;
        end if;
        --
        upd_period(v_codempid,para_codapp,para_codpay);
        --------------------------------------------------------------
        v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
        v_first   := true;
        v_typcal  := 'O';
        v_dtework := to_date('01/01/1111','dd/mm/yyyy');

        for r_tovrtime in c_tovrtime loop
          indx_codempid2 := v_codempid;

          para_dtework   := r_tovrtime.dtework;
          if v_first then
            v_first := false;
            v_dtemovemt := r_tovrtime.dtework;
            std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
                              v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                              v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                              v_amthour,v_amtday,v_amtmth);
            v_dtemovemt := r_tovrtime.dtework;
            std_al.get_movemt2(v_codempid,v_dtemovemt,'C','C',
                               v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                               v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                               v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
          else
            if r_tovrtime.dtework >= v_dtemovemt then
              v_dtemovemt := r_tovrtime.dtework;
              std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                v_amthour,v_amtday,v_amtmth);
              v_dtemovemt := r_tovrtime.dtework;
              std_al.get_movemt2(v_codempid,v_dtemovemt,'C','U',
                                 v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
            end if;
          end if;--v_first
          --
          if check_dteempmt(r_tovrtime.dtework) then
          	<< tcontals_loop >>
						for r_tcontals in c_tcontals loop
							v_dteeffec := r_tcontals.dteeffec;
							if r_tcontals.typwork in ('2','3') then
								v_dtework := r_tovrtime.dtework;

	              v_flag   := true;
	              if r_tcontals.syncond is not null then
	                v_cond := r_tcontals.syncond;
                  v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                  v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                  v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
	                v_stmt := 'select count(*) from dual where '||v_cond;
	                v_flag := execute_stmt(v_stmt);
	              end if;
	              --
                if v_flag and
                   (nvl(r_tcontals.typpayot,'1') = '1' or
                   (nvl(r_tcontals.typpayot,'1') = '2' and
                    (nvl(z_codempid,'!@#') <> v_codempid or nvl(z_dtework,to_date('01/01/1111','dd/mm/yyyy')) <> r_tovrtime.dtework))) then
                    z_codempid := v_codempid;
                    z_dtework  := r_tovrtime.dtework;

	                << tcontald_loop >>
	                for r_tcontald in c_tcontald loop
                    /*v_typworkot := r_tovrtime.typwork;
                  	if nvl(r_tcontals.typpayot,'1') = '1' then
											v_typworkot := r_tovrtime.typwork;
										else*/
											begin
												select typwork into v_typworkot
						         			from tattence
						         		 where codempid = v_codempid
						         		   and dtework  = r_tovrtime.dtework;
											exception when no_data_found then null;
											end;
	                	--end if;

	                  v_flgfound := true;
	                  if r_tcontald.syncond is not null then
	                    v_cond := r_tcontald.syncond;
                      v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                      v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                      v_cond := replace(v_cond,'TSHIFTCD.CODSHIFT',''''||r_tovrtime.codshift||'''');
	                    v_cond := replace(v_cond,'TATTENCE.TYPWORK',''''||v_typworkot||'''');
	                    v_cond := replace(v_cond,'TEMPLOY3.AMTINCOM1',v_amtincom(1));
	                    v_cond := replace(v_cond,'TOVRTIME.TYPOT',''''||r_tovrtime.typot||'''');
                      v_cond := replace(v_cond,'TEMPLOY1.TYPCAL',''''||v_typcal||'''');
	                    v_stmt := 'select count(*) from dual where '||v_cond;
	                    v_flgfound := execute_stmt(v_stmt);
	                  end if;
	                  if v_flgfound then
	                  	v_flgpay := 'N';
                      v_qtymin := r_tovrtime.qtyminot;
                      v_dtestrt  := to_date(to_char(r_tovrtime.dtestrt,'dd/mm/yyyy')||r_tovrtime.timstrt,'dd/mm/yyyyhh24mi');
                      v_dteend   := to_date(to_char(r_tovrtime.dteend,'dd/mm/yyyy')||r_tovrtime.timend,'dd/mm/yyyyhh24mi');
											if nvl(r_tcontals.typpayot,'1') = '1' then
												v_qtymin := r_tovrtime.qtyminot;
												v_dtestrt  := to_date(to_char(r_tovrtime.dtestrt,'dd/mm/yyyy')||r_tovrtime.timstrt,'dd/mm/yyyyhh24mi');
                        v_dteend   := to_date(to_char(r_tovrtime.dteend,'dd/mm/yyyy')||r_tovrtime.timend,'dd/mm/yyyyhh24mi');
											else
												v_typot := null;-- user22 : 22/11/2017 : STA3600484 ||
										    if r_tcontals.flgotb	= 'Y' then
										      v_typot := 'B';
										    end if;
										    if r_tcontals.flgotd	= 'Y' then
										      v_typot := v_typot||'D';
										    end if;
										    if r_tcontals.flgota	= 'Y' then
										      v_typot := v_typot||'A';
										    end if;
                        -- user19 29/11/2018
                        v_qtymin       := 0 ;
                        v_dtestrt      := null ;
                        v_dteend       := null ;
										    for s_tovrtime in c_tovrtime_sum loop
													v_qtymin   := s_tovrtime.qtyminot;
													v_dtestrt  := s_tovrtime.dtestrtot;
	                                    v_dteend   := s_tovrtime.dteendot;
												end loop;--c_tovrtime_sum
											end if;--nvl(r_tcontals.typpayot,'1') = '1'
	                    if r_tcontald.qtyhrwks is not null then
	                      if v_qtymin between r_tcontald.qtyhrwks and r_tcontald.qtyhrwke then
	                        v_flgpay := 'Y';
	                      end if;
	                    else
                        if check_period_time(v_dtestrt,v_dteend,r_tcontald.timstrtw,r_tcontald.timendw) then
                          v_flgpay := 'Y';
                        end if;
                      end if;
                      --
	                    if v_flgpay = 'Y' then
	                      v_sumqtyday := v_sumqtyday + 1;
                        --<<user36 03/12/2020
                        /*https://hrmsd.peopleplus.co.th:4448/redmine/issues/5310
                        begin
                          select qtydaywk into v_qtydaywk
                            from tshiftcd
                           where codshift = r_tovrtime.codshift;
                        exception when no_data_found then
                          v_qtydaywk := 0;
                        end;
                        v_qtymin := v_qtydaywk;*/
                        -->>user36 03/12/2020
	                      v_sumqtymin := v_sumqtymin + v_qtymin;
	                      v_amtpay    := cal_formula(v_codempid,r_tcontald.formula,r_tovrtime.dtework);
	                      v_sumamtpay := v_sumamtpay + v_amtpay;
	                      upd_tpaysum2(v_codempid,para_codapp,para_codpay,r_tovrtime.codcomp,r_emp.codpos,r_tovrtime.typpayroll,r_tovrtime.dtework,r_tovrtime.typot,--r_tovrtime.codshift,
                                     to_char(v_dtestrt,'hh24mi'),to_char(v_dteend,'hh24mi'),v_qtymin,v_amtpay,v_amthour,v_amtday);
	                      exit tcontald_loop;
	                    end if;-- v_flgpay = 'Y'
	                  end if; -- v_flgfound = true
	                end loop; -- for r_tcontald
	              end if;	--v_flag
							end if;--r_tcontals.typwork in ('2','3')
						end loop;--c_tcontals
          end if; -- check_dteempmt
        end loop; -- for c_tovrtime
        --------------------------------------------------------------
        v_first  := true;
        v_typcal := 'W';
        for r_tattence in c_tattence loop
          indx_codempid2 := v_codempid;
          para_dtework   := r_tattence.dtework;
         	if (r_tattence.typwork = 'W') then--or (r_tattence.typwork in ('S','T') and instr(v_flgworkth,r_tattence.typwork) > 0)) then
	          if v_first then
	            v_first := false;
	            v_dtemovemt := r_tattence.dtework;
	            std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
	                              v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
	                              v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
	                              v_amthour,v_amtday,v_amtmth);
	            v_dtemovemt := r_tattence.dtework;
	            std_al.get_movemt2(v_codempid,v_dtemovemt,'C','C',
	                               v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
	                               v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
	                               v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
	          else
	            if r_tattence.dtework >= v_dtemovemt then
	              v_dtemovemt := r_tattence.dtework;
	              std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
	                                v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
	                                v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
	                                v_amthour,v_amtday,v_amtmth);
	              v_dtemovemt := r_tattence.dtework;
	              std_al.get_movemt2(v_codempid,v_dtemovemt,'C','U',
	                                 v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
	                                 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
	                                 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
	            end if;
	          end if;--v_first
	          --

	          if check_dteempmt(r_tattence.dtework) then
							for r_tcontals in c_tcontals loop
								v_dteeffec := r_tcontals.dteeffec;

								if r_tcontals.typwork in ('1','3') then

		              v_flag   := true;
		              if r_tcontals.syncond is not null then
		                v_cond := r_tcontals.syncond;
                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
		                v_stmt := 'select count(*) from dual where '||v_cond;
		                v_flag := execute_stmt(v_stmt);
		              end if;
		              --
		              if v_flag then
		                << tcontald_loop >>
		                for r_tcontald in c_tcontald loop
		                  v_flgfound := true;
		                  if r_tcontald.syncond is not null then
		                    v_cond := r_tcontald.syncond;
                        v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                        v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                        v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                        v_cond := replace(v_cond,'TSHIFTCD.CODSHIFT',''''||r_tattence.codshift||'''');
	                      v_cond := replace(v_cond,'TATTENCE.TYPWORK',''''||r_tattence.typwork||'''');
	                      v_cond := replace(v_cond,'TEMPLOY3.AMTINCOM1',v_amtincom(1));
                        --v_cond := replace(v_cond,'TOVRTIME.TYPOT',''''||r_tovrtime.typot||'''');
	                      v_cond := replace(v_cond,'TEMPLOY1.TYPCAL',''''||v_typcal||'''');
	                      v_stmt := 'select count(*) from dual where '||v_cond;
		                    v_flgfound := execute_stmt(v_stmt);
		                  end if;
		                  if v_flgfound then
		                    v_flgpay := 'N';
		                    v_qtymin := r_tattence.qtyhwork;
	                      if r_tcontald.qtyhrwks is not null then
	                        select nvl(sum(qtymin),0) into v_qtyminle
	                          from tleavetr
	                         where codempid = v_codempid
	                           and dtework  = r_tattence.dtework;

	                        select nvl(sum(qtylate),0), nvl(sum(qtyearly),0)
	                          into v_qtylate, v_qtyearly
	                          from tlateabs
	                         where codempid = v_codempid
	                           and dtework  = r_tattence.dtework;
	                        v_qtymin := v_qtymin - (v_qtyminle + v_qtylate + v_qtyearly);
	                        if v_qtymin between r_tcontald.qtyhrwks and r_tcontald.qtyhrwke then
	                          v_flgpay := 'Y';
	                        end if;
	                      else
	                        if r_tattence.timin is null or r_tattence.timout is null then
	                          null;
	                        else
	                          v_dtestrt  := to_date(to_char(r_tattence.dtein,'dd/mm/yyyy')||r_tattence.timin,'dd/mm/yyyyhh24mi');
	                          v_dteend   := to_date(to_char(r_tattence.dteout,'dd/mm/yyyy')||r_tattence.timout,'dd/mm/yyyyhh24mi');
	                          if check_period_time(v_dtestrt,v_dteend,r_tcontald.timstrtw,r_tcontald.timendw) then
	                            v_flgpay := 'Y';
	                          end if;
	                        end if;
	                      end if;
	                      --
		                    if v_flgpay = 'Y' then
                          	v_sumqtyday := v_sumqtyday + 1;
								            --<<user36 03/12/2020
                            /*https://hrmsd.peopleplus.co.th:4448/redmine/issues/5310
                            begin
                              select qtydaywk into v_qtydaywk
                                from tshiftcd
                               where codshift = r_tattence.codshift;
                            exception when no_data_found then
                              v_qtydaywk := 0;
                            end;
                            v_qtymin := v_qtydaywk;*/
                            -->>user36 03/12/2020
                            v_sumqtymin := v_sumqtymin + v_qtymin;
                            v_amtpay    := cal_formula(v_codempid,r_tcontald.formula,r_tattence.dtework);
                            v_sumamtpay := v_sumamtpay + v_amtpay;

                            upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                         r_tattence.dtework,r_tattence.codshift,r_tattence.timin,r_tattence.timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
		                      exit tcontald_loop;
		                    end if; -- v_flgpay = 'Y'
		                  end if; -- v_flgfound = true
		                end loop; -- for r_tcontald
		              end if;	-- v_flag
								end if; -- r_tcontals.typwork in ('1','3')
							end loop; -- c_tcontals
	          end if; -- check_dteempmt
        	end if; --if (r_tattence.typwork = 'W' then
        end loop; -- for c_tattence
        --------------------------------------------------------------

        if v_sumqtyday > 0 then
            upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                        v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
        end if;
        exit main_loop;
      end loop; -- main_loop
    end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_abs(p_codapp    varchar2,
                     		p_coduser   varchar2,
                     		p_numproc	  number) is
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_syncond			varchar2(4000);
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_numseq			number;

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '3')
				 and typabs	   = '3'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '3'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtyabsent
			  from tlateabs
			 where codempid = v_codempid
			   and dtework  between nvl(para_dtestr,dtework) and para_dteend
			   and nvl(flgcalabs,'N') = 'N'
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) || 
		order by dtework;
	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set flgcalabs = 'N',
					     amtabsent = stdenc(0,codempid,para_chken),
							 dteyreabs = 0,	dtemthabs = 0,numprdabs = 0,
							 coduser	 = para_coduser
				 where dteyreabs = para_dteyrepay
					 and dtemthabs = para_dtemthpay
					 and numprdabs = para_numperiod
					 and codempid  = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							--
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if r_tlateabs.qtyabsent > 0 then
									get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
									begin
										select qtydaywk into v_qtydaywk
  										from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtyabsent;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                                        if r_tabsdedd.typecal = '1' then
                                          v_qtymin := r_tabsdedd.qtyded;
                                        end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;
									v_sumqtyday := v_sumqtyday + v_qtyday;
									v_sumqtymin := v_sumqtymin + v_qtymin;
									v_sumamtpay := v_sumamtpay + v_amtpay;
									upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                 r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
								end if;-- r_tlateabs.qtyabsent > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
						--
						update tlateabs
							 set amtabsent = stdenc(round(v_amtpay,4),codempid,para_chken),
								   flgcalabs = 'Y',
									 dteyreabs = para_dteyrepay,
									 dtemthabs = para_dtemthpay,
									 numprdabs = para_numperiod,
									 coduser   = para_coduser
						 where rowid     = r_tlateabs.rowid;
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_ear(p_codapp    varchar2,
                     		p_coduser   varchar2,
                     		p_numproc	  number) is
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_syncond			varchar2(4000);
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_numseq			number;

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '2')
				 and typabs	   = '2'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '2'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtyearly
			  from tlateabs
			 where codempid = v_codempid
			   and dtework  between nvl(para_dtestr,dtework) and para_dteend
			   and nvl(flgcalear,'N') = 'N'
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||          
		order by dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set flgcalear = 'N',
					     amtearly  = stdenc(0,codempid,para_chken),
							 dteyreear = 0, dtemthear = 0, numprdear = 0,
							 coduser	 = para_coduser
				 where dteyreear = para_dteyrepay
					 and dtemthear = para_dtemthpay
					 and numprdear = para_numperiod
					 and codempid  = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							--
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if r_tlateabs.qtyearly > 0 then
									get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
									begin
										select qtydaywk into v_qtydaywk
										  from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtyearly;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                                        if r_tabsdedd.typecal = '1' then
                                          v_qtymin := r_tabsdedd.qtyded;
                                        end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;
									v_sumqtyday := v_sumqtyday + v_qtyday;
									v_sumqtymin := v_sumqtymin + v_qtymin;
									v_sumamtpay := v_sumamtpay + v_amtpay;
									upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                 r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
								end if;-- r_tlateabs.qtyearly > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
						--
						update tlateabs
							 set amtearly  = stdenc(round(v_amtpay,4),codempid,para_chken),
									 flgcalear = 'Y',
									 dteyreear = para_dteyrepay,
									 dtemthear = para_dtemthpay,
									 numprdear = para_numperiod,
									 coduser   = para_coduser
						 where rowid     = r_tlateabs.rowid;
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_late(p_codapp    varchar2,
                     	 p_coduser   varchar2,
                     	 p_numproc	 number) is
		v_first			boolean := true;
		v_dtemovemt		date;
		v_codcomp		temploy1.codcomp%type;
		v_codpos		temploy1.codpos%type;
		v_numlvl		temploy1.numlvl%type;
		v_codjob		temploy1.codjob%type;
		v_codempmt		temploy1.codempmt%type;
		v_typemp		temploy1.typemp%type;
		v_typpayroll  temploy1.typpayroll%type;
		v_codbrlc		temploy1.codbrlc%type;
		v_codcalen		temploy1.codcalen%type;
		v_jobgrade		temploy1.jobgrade%type;
		v_codgrpgl		temploy1.codgrpgl%type;

		v_amthour		number := 0;
		v_amtday		number := 0;
		v_amtmth		number := 0;

		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin			tattence.timin%type;
		v_timout		tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond			varchar2(4000);
		v_stmt			varchar2(4000);
		v_syncond		varchar2(4000);
		v_qtyday		number := 0;
		v_qtymin		number := 0;
		v_amtpay		number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_numseq		number;

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '1')
				 and typabs	   = '1'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '1'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtylate
			  from tlateabs
			 where codempid = v_codempid
			   and dtework  between nvl(para_dtestr,dtework) and para_dteend
			   and nvl(flgcallate,'N') = 'N'
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||          
		order by dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set flgcallate = 'N',
					     amtlate    = stdenc(0,codempid,para_chken),
							 dteyrelate = 0, dtemthlate = 0,numprdlate = 0,
							 coduser	  = para_coduser
				 where dteyrelate = para_dteyrepay
					 and dtemthlate = para_dtemthpay
					 and numprdlate = para_numperiod
					 and codempid   = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if r_tlateabs.qtylate > 0 then
									get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
									begin
										select qtydaywk into v_qtydaywk
										  from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtylate;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                                        if r_tabsdedd.typecal = '1' then
                                          v_qtymin := r_tabsdedd.qtyded;
                                        end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;
									v_sumqtyday := v_sumqtyday + v_qtyday;
									v_sumqtymin := v_sumqtymin + v_qtymin;
									v_sumamtpay := v_sumamtpay + v_amtpay;
									upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                 r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
								end if;-- r_tlateabs.qtylate > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
						--
						update tlateabs
							 set amtlate    = stdenc(round(v_amtpay,4),codempid,para_chken),
									 flgcallate = 'Y',
									 dteyrelate = para_dteyrepay,
									 dtemthlate = para_dtemthpay,
									 numprdlate = para_numperiod,
									 coduser    = para_coduser
						 where rowid      = r_tlateabs.rowid;
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_leave(p_codapp   varchar2,
                          p_coduser  varchar2,
                          p_numproc	 number) is

  	v_codempid		temploy1.codempid%type;
    v_flgtran			tpaysum.flgtran%type;

  	cursor c_temploy1 is
			select a.codempid,codcomp,typpayroll,codempmt,dteempmt,qtywkday,numlvl,codpos,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
			order by a.codempid;

		cursor c_tleavety is
			select typleave
			  from tleavety
       where flgtype  <> 'M'
         and typleave in (select typleave
                            from tleavetr
                           where codempid   = v_codempid
                             and dtework    between nvl(para_dtestr,dtework) and para_dteend)
		order by typleave;

		cursor c_tleavetr is
      select distinct dteprgntst
        from tleavetr
       where codempid   = v_codempid
         and dtework    between nvl(para_dtestr,dtework) and para_dteend
         and dteprgntst is not null
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tleavetr.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tleavetr.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||          
    order by dteprgntst;
	begin
	  for r_temploy1 in c_temploy1 loop
			v_codempid := r_temploy1.codempid;
			para_dteempmt := r_temploy1.dteempmt;
			para_dteeffex := r_temploy1.dteeffex;
			<< main_loop >> loop
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,null);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
        if para_codapp = 'DED_LEAVE' then
          for r_tleavety in c_tleavety loop
            << cal_loop >>
            loop
              update tleavetr
                 set dteyrepay = 0,
                     dtemthpay = 0,
                     numperiod = 0,
                     amtlvded  = stdenc(0,codempid,para_chken),
                     qtylvded  = 0,
                     coduser   = para_coduser
               where dteyrepay = para_dteyrepay
                 and dtemthpay = para_dtemthpay
                 and numperiod = para_numperiod
                 and codempid  = v_codempid
                 and typleave  = r_tleavety.typleave;

              cal_ded_leave2(v_codempid,r_tleavety.typleave,p_codapp,p_coduser,p_numproc);
              exit cal_loop;
            end loop; -- cal_loop
          end loop; -- for c_tleavety
				elsif para_codapp = 'DED_LEAVEM' then
          for r_tleavetr in c_tleavetr loop
            << cal_loop >>
            loop
              update tleavetr
                 set dteyrepay  = 0,
                     dtemthpay  = 0,
                     numperiod  = 0,
                     amtlvded   = stdenc(0,codempid,para_chken),
                     qtylvded   = 0,
                     coduser    = para_coduser
               where dteyrepay  = para_dteyrepay
                 and dtemthpay  = para_dtemthpay
                 and numperiod  = para_numperiod
                 and codempid   = v_codempid
                 and dteprgntst = r_tleavetr.dteprgntst;

              cal_ded_leave3(v_codempid,r_tleavetr.dteprgntst,p_codapp,p_coduser,p_numproc);
              exit cal_loop;
            end loop; -- cal_loop
          end loop; -- for c_tleavety
        end if; -- para_codapp = 'DED_LEAVE'
        exit main_loop;
			end loop;
		end loop; -- for r_temploy1
		commit;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_leave2(p_codempid   varchar2,
                           p_typleave   varchar2,
	                         p_codapp     varchar2,
			                     p_coduser    varchar2,
			                     p_numproc	  number) is
		v_first				boolean := true;
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
		v_maxpay			number := 0;
		o_amtpay			number := 0;

	  v_codpay			tleavety.codpay%type;
	  v_flgdlemx		tleavety.flgdlemx%type;
		v_flgwkcal		tleavety.flgwkcal%type;
    v_dteeffec    tleavsum.dteeffeclv%type;
    v_qtypriyr    tleavsum.qtypriyr%type;
		v_qtydlepay		tleavety.qtydlepay%type;
	  v_qtydayle		tleavsum.qtydayle%type;
	  v_staleave		tleavecd.staleave%type;
	  v_deduct      tleavetr.qtyday%type;
		v_amtpay			number := 0;
		v_dteempmt		temploy1.dteempmt%type;
		v_qtywkday		temploy1.qtywkday%type;
		v_qtyminded		number := 0;
		v_qtydaywk		number := 0;
	  v_yrecycle		number;
	  v_dtecycst 		date;
	  v_dtecycen		date;
	  v_ageday			number;
		v_pctded			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
    v_qtydayleprgnt number := 0;
    v_flgtype     varchar2(4);

	 	type amtincom is table of number index by binary_integer;
			v_amtincom  amtincom;

		cursor c_tleavetr is
			select rowid,dtework,qtyday,codleave,qtymin,codcomp,typpayroll,timstrt,timend,numlereq,codshift,dteprgntst
			  from tleavetr
			 where nvl(dteyrepay,0) = 0
			   and codempid  = p_codempid
			   and dtework   between nvl(para_dtestr,dtework) and para_dteend
			   and typleave  = p_typleave
			   /*and not exists(select codempid
		                      from tpaysum2
										     where codempid = p_codempid
										       and codalw	  = para_codapp
										       and dtework	= tleavetr.dtework
										       and codshift = tleavetr.codleave
										       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
												       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))*/
		order by dtework,timstrt;

	begin
		for i in 1..10 loop
			v_amtincom(i) := 0;
		end loop ;
		<< main_loop >> loop
			begin
				select flgdlemx,flgwkcal,qtydlepay,codpay,pctded,flgtype
				  into v_flgdlemx,v_flgwkcal,v_qtydlepay,v_codpay,v_pctded,v_flgtype
				  from tleavety
				 where typleave = p_typleave;
			exception when no_data_found then
				exit main_loop;
			end;
			v_codpay := nvl(v_codpay,para_codpay);
      --
			begin
				select dteempmt,nvl(qtywkday,0)
				  into v_dteempmt,v_qtywkday
				  from temploy1
				 where codempid = p_codempid;
			exception when no_data_found then exit main_loop;
			end;
			--
			v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
			for r_tleavetr in c_tleavetr loop
				v_deduct  := 0;
        v_ageday  := (r_tleavetr.dtework - (v_dteempmt - v_qtywkday)+1);
				begin
					select staleave into v_staleave
					  from tleavecd
					 where codleave = r_tleavetr.codleave;
				exception when no_data_found then exit main_loop;
				end;
				std_al.cycle_leave(para_codcompy,p_codempid,r_tleavetr.codleave,r_tleavetr.dtework,v_yrecycle,v_dtecycst,v_dtecycen);
        std_al.entitlement(p_codempid,r_tleavetr.codleave,r_tleavetr.dtework,null,v_qtydlepay,v_qtypriyr,v_dteeffec);
				if v_staleave in ('V','C') then
          v_qtydlepay := v_qtydlepay;
				elsif v_flgwkcal = 'Y' and v_ageday < 365 then
					v_qtydlepay := (v_qtydlepay * v_ageday) / 365;
				end if;
				-----------------------------------------------------
				indx_codempid2 := p_codempid;
				para_dtework   := r_tleavetr.dtework;
				if check_dteempmt(r_tleavetr.dtework) then
					v_qtydayle := 0;
					if v_flgdlemx = 'Y' then -- Per Time
            begin
              select nvl(sum(qtyday),0) into v_qtydayle
                from tleavetr
               where codempid = p_codempid
                 and numlereq = r_tleavetr.numlereq
                 and dtework <= r_tleavetr.dtework;
            exception when no_data_found then v_qtydayle := 0;
            end;
					else -- Per Year
            begin
              select nvl(sum(qtyday),0) into v_qtydayle
                from tleavetr
               where codempid  = p_codempid
                 and typleave  = p_typleave
                 and dtework   <= r_tleavetr.dtework
                 and dtework   between v_dtecycst and v_dtecycen;
            exception when no_data_found then v_qtydayle := 0;
            end;
					end if;

					if v_qtydayle > v_qtydlepay then
            v_deduct := least(r_tleavetr.qtyday,(v_qtydayle - v_qtydlepay));
					end if;
					-----------------------------------------------------
					if v_deduct > 0 then
						if v_first then
							v_first := false;
							v_dtemovemt := r_tleavetr.dtework;
							std_al.get_movemt2(p_codempid,v_dtemovemt,'C','C',
										             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
						else
							if r_tleavetr.dtework >= v_dtemovemt then
								v_dtemovemt := r_tleavetr.dtework;
								std_al.get_movemt2(p_codempid,v_dtemovemt,'C','U',
											             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																	 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																	 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
							end if;
						end if;
						-----------------------------------------------------
						v_maxpay := 0; o_amtpay := 0;
						get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1),v_codempmt,
														v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
														v_amthour,v_amtday,v_amtmth);

						/*begin
							select nvl(sum(stddec(amtpay,codempid,para_chken)),0) into o_amtpay
								from tpaysum2
							 where dteyrepay = para_dteyrepay
								 and dtemthpay = para_dtemthpay
								 and numperiod = para_numperiod
								 and codempid  = p_codempid
								 and codalw		 = 'DED_LEAVE'
								 and dtework	 = r_tleavetr.dtework;
						exception when no_data_found then null;
						end;

						v_maxpay := greatest(nvl(v_amtday,0) - nvl(o_amtpay,0),0);*/
						-----------------------------------------------------
            v_amtday := (v_amtday * nvl(v_pctded,0) / 100);
						v_amtpay := v_amtday * v_deduct;
						--v_amtpay := least(v_amtpay,v_maxpay);
						-----------------------------------------------------
						begin
							select qtydaywk	into v_qtydaywk
							  from tshiftcd
							 where codshift	= r_tleavetr.codshift;
						exception when no_data_found then
							v_qtydaywk	:= 0;
						end;
						v_qtyminded		:= v_deduct * v_qtydaywk;
						if v_amtpay > 0 then
							upd_tpaysum2(p_codempid,para_codapp,v_codpay,v_codcomp,v_codpos,v_typpayroll,
                           r_tleavetr.dtework,r_tleavetr.codleave,r_tleavetr.timstrt,r_tleavetr.timend,v_qtyminded,v_amtpay,v_amthour,v_amtday);
							v_sumqtyday := v_sumqtyday + v_deduct;
							v_sumqtymin := v_sumqtymin + v_qtyminded;
							v_sumamtpay := v_sumamtpay + v_amtpay;
						end if;
						-----------------------------------------------------
						update tleavetr
							 set dteyrepay = para_dteyrepay,
									 dtemthpay = para_dtemthpay,
									 numperiod = para_numperiod,
									 amtlvded  = stdenc(round(v_amtpay,4),p_codempid,para_chken),
									 qtylvded  = v_deduct,
									 coduser	 = para_coduser
						 where rowid     = r_tleavetr.rowid;
					end if; -- v_deduct > 0
				end if; -- check_dteempmt
			end loop; -- for c_tleavetr
			if v_sumamtpay > 0 then
				upd_tpaysum(p_codempid,para_codapp,v_codpay,v_codcomp,v_codpos,v_typpayroll,
										v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
			end if;
			exit main_loop;
		end loop; -- main_loop
    --
    indx_codempid2	 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ded_leave3(p_codempid   varchar2,
                           p_dteprgntst date,
	                         p_codapp     varchar2,
			                     p_coduser    varchar2,
			                     p_numproc	  number) is
		v_first				boolean := true;
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
		v_maxpay			number := 0;
		o_amtpay			number := 0;

		v_codcurr			temploy3.codcurr%type;
		v_ratechge		tratechg.ratechge%type;
	  v_codpay			tleavety.codpay%type;
		v_flgwkcal		tleavety.flgwkcal%type;
		v_qtydlepay		tleavety.qtydlepay%type;
	  v_qtydayle		tleavsum.qtydayle%type;
	  v_deduct      tleavetr.qtyday%type;
		v_amtpay			number := 0;
		v_dteempmt		temploy1.dteempmt%type;
		v_qtywkday		temploy1.qtywkday%type;
		v_qtyminded		number := 0;
		v_qtydaywk		number := 0;
	  v_ageday			number;
		v_pctded			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
    v_flgtype     varchar2(4);

	 	type amtincom is table of number index by binary_integer;
			v_amtincom  amtincom;

		cursor c_tleavetr is
			select rowid,dtework,qtyday,codleave,qtymin,codcomp,typpayroll,timstrt,timend,numlereq,codshift,dteprgntst,typleave
			  from tleavetr
			 where nvl(dteyrepay,0) = 0
			   and codempid    = p_codempid
			   and dtework     between nvl(para_dtestr,dtework) and para_dteend
			   and dteprgntst  = p_dteprgntst
		order by dtework,timstrt;

	begin
		for i in 1..10 loop
			v_amtincom(i) := 0;
		end loop ;
		<< main_loop >> loop
			begin
				select dteempmt,nvl(qtywkday,0)
				  into v_dteempmt,v_qtywkday
				  from temploy1
				 where codempid = p_codempid;
			exception when no_data_found then exit main_loop;
			end;
			--
			v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
			for r_tleavetr in c_tleavetr loop
        begin
          select flgwkcal,codpay,pctded--,flgdlemx,qtydlepay,codpay,pctded,flgtype
            into v_flgwkcal,v_codpay,v_pctded--,v_flgdlemx,v_qtydlepay,,v_pctded,v_flgtype
            from tleavety
           where typleave = r_tleavetr.typleave;
        exception when no_data_found then
          exit main_loop;
        end;
        v_codpay  := nvl(v_codpay,para_codpay);
				v_deduct  := 0;
        v_ageday  := (r_tleavetr.dtework - (v_dteempmt - v_qtywkday)+1);
        begin
          select sum(qtydlepay)
            into v_qtydlepay
            from tleavety
           where flgtype  = 'M'
             and typleave in (select typleave
                                from tleavetr
                               where codempid    = p_codempid
                                 and dteprgntst  = p_dteprgntst);
        end;
        if v_flgwkcal = 'Y' and v_ageday < 365 then
					v_qtydlepay := (v_qtydlepay * v_ageday) / 365;
				end if;
        --
        begin
          select nvl(sum(qtyday),0) into v_qtydayle
            from tleavetr
           where codempid    = p_codempid
             and dteprgntst  = p_dteprgntst
             and dtework    <= r_tleavetr.dtework;
        end;
        --
				indx_codempid2 := p_codempid;
				para_dtework   := r_tleavetr.dtework;
				if check_dteempmt(r_tleavetr.dtework) then
					if v_qtydayle > v_qtydlepay then
            v_deduct := least(r_tleavetr.qtyday,(v_qtydayle - v_qtydlepay));
					end if;
					-----------------------------------------------------
					if v_deduct > 0 then
						if v_first then
							v_first := false;
							v_dtemovemt := r_tleavetr.dtework;
							std_al.get_movemt2(p_codempid,v_dtemovemt,'C','C',
										             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
						else
							if r_tleavetr.dtework >= v_dtemovemt then
								v_dtemovemt := r_tleavetr.dtework;
								std_al.get_movemt2(p_codempid,v_dtemovemt,'C','U',
											             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																	 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																	 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
							end if;
						end if;
						-----------------------------------------------------
						v_maxpay := 0; o_amtpay := 0;
						get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1),v_codempmt,
														v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
														v_amthour,v_amtday,v_amtmth);
						--
            v_amtday := (v_amtday * nvl(v_pctded,0) / 100);
						v_amtpay := v_amtday * v_deduct;
						--
						begin
							select qtydaywk	into v_qtydaywk
							  from tshiftcd
							 where codshift	= r_tleavetr.codshift;
						exception when no_data_found then
							v_qtydaywk	:= 0;
						end;
						v_qtyminded		:= v_deduct * v_qtydaywk;
						if v_amtpay > 0 then
							upd_tpaysum2(p_codempid,para_codapp,v_codpay,v_codcomp,v_codpos,v_typpayroll,
                           r_tleavetr.dtework,r_tleavetr.codleave,r_tleavetr.timstrt,r_tleavetr.timend,v_qtyminded,v_amtpay,v_amthour,v_amtday);
							v_sumqtyday := v_sumqtyday + v_deduct;
							v_sumqtymin := v_sumqtymin + v_qtyminded;
							v_sumamtpay := v_sumamtpay + v_amtpay;
						end if;
						-----------------------------------------------------
						update tleavetr
							 set dteyrepay = para_dteyrepay,
									 dtemthpay = para_dtemthpay,
									 numperiod = para_numperiod,
									 amtlvded  = stdenc(round(v_amtpay,4),p_codempid,para_chken),
									 qtylvded  = v_deduct,
									 coduser	 = para_coduser
						 where rowid     = r_tleavetr.rowid;
					end if; -- v_deduct > 0
				end if; -- check_dteempmt
			end loop; -- for c_tleavetr
			if v_sumamtpay > 0 then
				upd_tpaysum(p_codempid,para_codapp,v_codpay,v_codcomp,v_codpos,v_typpayroll,
										v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
			end if;
			exit main_loop;
		end loop; -- main_loop
    --
    indx_codempid2	 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure cal_adj_abs(p_codapp   varchar2,
                                    p_coduser  varchar2,
                                    p_numproc	 number) is


		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;

	cursor c_emp is
		select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
	 	  from tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
	order by a.codempid;



	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;

				del_tpaysum(v_codempid,para_codapp,null);
				upd_period(v_codempid,para_codapp,null);
				cal_adj_abs_gen_tpaysum(v_codempid,p_coduser,'W');
				/*
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				v_first := true;
				for r_tretabs in c_tretabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tretabs.dtework;
					v_amtabsent := stddec(r_tretabs.amtabsent,v_codempid,para_chken);
					if v_amtabsent > 0 and check_dteempmt(r_tretabs.dtework) then
						if v_first then
							v_first := false;
							v_dtemovemt := r_tretabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tretabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tretabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;

						get_time(v_codempid,r_tretabs.dtework,v_timin,v_timout);
						v_qtymin := r_tretabs.qtyabsent;
						v_qtyday := r_tretabs.dayabsent;
						v_amtpay := v_amtabsent;
						v_sumqtyday := v_sumqtyday + v_qtyday;
						v_sumqtymin := v_sumqtymin + v_qtymin;
						v_sumamtpay := v_sumamtpay + v_amtpay;

						upd_tpaysum2(v_codempid,para_codapp,para_codpay,r_tretabs.dtework,r_tretabs.codshift,
												 v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
					end if;
					update tretabs
						 set flgcalabs = 'Y',
								 dteyreabs = para_dteyrepay,
	 							 dtemthabs = para_dtemthpay,
								 numprdabs = para_numperiod,
								 coduser = para_coduser
					 where rowid = r_tretabs.rowid;
				end loop; -- for c_tretabs
				if v_sumamtpay > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;*/
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_adj_abs_gen_tpaysum(p_codempid   varchar2,
                                    p_coduser    varchar2,
																	  p_flgwork		 varchar2) is
		v_flgfound	boolean;
		v_first			boolean := true;
		v_dtemovemt	date;
		v_codcomp		temploy1.codcomp%type;
		v_codpos		temploy1.codpos%type;
		v_numlvl		temploy1.numlvl%type;
		v_codjob		temploy1.codjob%type;
		v_codempmt	temploy1.codempmt%type;
		v_typemp		temploy1.typemp%type;
		v_typpayroll temploy1.typpayroll%type;
		v_codbrlc		temploy1.codbrlc%type;
		v_codcalen	temploy1.codcalen%type;
		v_jobgrade	temploy1.jobgrade%type;
		v_codgrpgl	temploy1.codgrpgl%type;

		v_amthour	 	number := 0;
		v_amtday		number := 0;
		v_amtmth		number := 0;
		--
		v_flgcal    varchar2(1);
		v_codshift	tlateabs.codshift%type;
		v_flgatten	tlateabs.flgatten%type;
		v_qtydaywk	number;
		v_dteeffec  tabsdedh.dteeffec%type;
		v_typabs    tabsdedh.typabs%type;
		v_cond			varchar2(4000);
		v_stmt			varchar2(4000);
		v_syncond		varchar2(4000);
		v_qtyday		number;
		v_qtymin		number;
		v_qty  		  number;
		v_day			  number;
		v_amt   		number;
		v_amtpay		number;
		v_retpay		number;
		v_numseq		number;

		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;

		v_amtabsent	 	number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;

	cursor c_tpaysum2 is
		select  t1.codempid,t2.dtework,t2.codalw,nvl(t2.qtymin,0) qtymin,stddec(t2.amtpay,p_codempid,para_chken) amtpay
		  from tpaysum t1,tpaysum2 t2
		 where t1.dteyrepay = t2.dteyrepay
		   and t1.dtemthpay = t2.dtemthpay
		   and t1.numperiod = t2.numperiod
		   and t1.codempid  = t2.codempid
		   and t1.codalw    = t2.codalw
			 and t1.codpay    = t2.codpay
		 	 and t2.codempid  = p_codempid
			 and t2.dtework   between nvl(para_dtestr,dtework) and para_dteend
			 and t2.codalw    = 'DED_ABSENT'
			 and t1.flgtran   = 'Y'
       --<<user36 ST11 20/12/2021
       and not exists(select codempid
	                      from tpaysum2
									     where codempid = p_codempid
									       and codalw	  = para_codapp
									       and codpay	  = para_codpay
									       and dtework	= t2.dtework
									       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
       -->>user36 ST11 20/12/2021
	order by t2.dtework;

	cursor c_tabsdedh is
		select dteeffec,numseq,syncond
		  from tabsdedh
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = (select max(dteeffec)
												  from tabsdedh
												 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
												   and dteeffec <= sysdate
												   and typabs	   = v_typabs)
			 and typabs	   = v_typabs
	order by numseq;

	cursor c_tabsdedd is
		select typecal,qtyded
		  from tabsdedd
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = v_dteeffec
		   and typabs    = v_typabs
		   and numseq    = v_numseq
		   and v_qtymin between qtyabsst and qtyabsen;

	begin

        update tlateabs
                set yreadjabs = 0, mthadjabs = 0, prdadjabs = 0,
                     coduser	  = para_coduser
        where yreadjabs  = para_dteyrepay
            and mthadjabs  = para_dtemthpay
            and prdadjabs  = para_numperiod
            and codempid   = p_codempid;

		for r1 in c_tpaysum2 loop
			<<loop_tpaysum2>> loop
				v_qty := 0; v_amt := 0;

				begin
					select qtyabsent into v_qty
					  from tlateabs
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;
				if nvl(r1.qtymin,0) <= nvl(v_qty,0) then
					exit loop_tpaysum2;
				end if;
				--
				if v_first then
					v_first := false;
					v_dtemovemt := r1.dtework;
					std_al.get_movemt(p_codempid,v_dtemovemt,'C','C',
													  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
													  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
													  v_amthour,v_amtday,v_amtmth);
				else
					if r1.dtework >= v_dtemovemt then
						v_dtemovemt := r1.dtework;
						std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',
														  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
														  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
														  v_amthour,v_amtday,v_amtmth);
					end if;
				end if;

				begin
					select codshift,flgatten
					  into v_codshift,v_flgatten
					  from tattence
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;

				begin
					select qtydaywk into v_qtydaywk
	  				from tshiftcd
					 where codshift = v_codshift;
				exception when no_data_found then v_qtydaywk := 480;
				end;
				--
				if v_qty > 0 then
		      v_typabs := '3';
		      --
		      <<cal_loop>>
					for r_tabsdedh in c_tabsdedh loop
						v_dteeffec := r_tabsdedh.dteeffec;
						v_numseq   := r_tabsdedh.numseq;
						v_syncond  := r_tabsdedh.syncond;
						--
						v_flgfound := true;
						if v_syncond is not null then
                                    v_cond := v_syncond;
                                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                                    v_stmt := 'select count(*) from dual where '||v_cond;
                                    v_flgfound := execute_stmt(v_stmt);
						end if;
						if v_flgfound then
							v_qtymin := v_qty;
							for r_tabsdedd in c_tabsdedd loop
                                    if r_tabsdedd.typecal = '1' then
                                              v_qtymin := r_tabsdedd.qtyded;
                                    elsif   r_tabsdedd.typecal = '2' then
                                             v_qtymin := v_qty;
                                    end if;
							end loop;
							v_qtyday := v_qtymin / v_qtydaywk;
							v_amt    := round(v_amtday * v_qtyday,4);
							exit cal_loop;
						end if;
					end loop;	-- c_tabsdedh
				end if; -- v_qty > 0
				--
				begin
					select sum(stddec(amtpay,codempid,para_chken)) into v_retpay
	  				from tpaysum2
					 where codempid = p_codempid
					   and dtework  = r1.dtework
					   and codalw   = 'RET_ABSENT';
				end;
				v_amtpay := r1.amtpay + nvl(v_retpay,0);
				--
				if v_amtpay > v_amt then
					   v_qty := nvl(r1.qtymin,0) - nvl(v_qty,0);
                        v_day := v_qty / v_qtydaywk;
                        v_amt := v_amtpay - nvl(v_amt,0);

                        get_time(r1.codempid,r1.dtework,v_timin,v_timout);
                        v_sumqtyday := v_sumqtyday + v_day;
                        v_sumqtymin := v_sumqtymin + v_qty;
                        v_sumamtpay := v_sumamtpay + v_amt;
                        upd_tpaysum2(r1.codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                     r1.dtework,v_codshift ,v_timin,v_timout,v_qty,v_amt,v_amthour,v_amtday);

                        update tlateabs
                                set yreadjabs  = para_dteyrepay,
                                     mthadjabs  = para_dtemthpay,
                                     prdadjabs  = para_numperiod,
                                     coduser    = para_coduser
                         where codempid   = r1.codempid
                            and dtework    = r1.dtework;
				end if;
				--
				exit loop_tpaysum2;
			end loop;--<<loop_tpaysum2>>
		end loop;  --c_tpaysum2
        if v_sumamtpay > 0 then
					upd_tpaysum(p_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
        end if;

		commit;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_adj_ear(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number) is

      v_flgtran   	     tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;

	cursor c_emp is
		select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
	 	  from tprocemp a, temploy1 b
		 where a.codempid = b.codempid
   		 and a.codapp   = para_codapp_wh
  		 and a.coduser  = p_coduser
  		 and a.numproc  = p_numproc
	order by a.codempid;



	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;

				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				upd_period(v_codempid,para_codapp,null);
				cal_adj_ear_gen_tpaysum(v_codempid,p_coduser,'W');

            /*
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				v_first := true;
				for r_tretabs in c_tretabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tretabs.dtework;

					v_amtearly := stddec(r_tretabs.amtearly,v_codempid,para_chken);
					if v_amtearly > 0 and check_dteempmt(r_tretabs.dtework) then
						if v_first then
							v_first := false;
							v_dtemovemt := r_tretabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tretabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tretabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;

						get_time(v_codempid,r_tretabs.dtework,v_timin,v_timout);
						v_qtymin := r_tretabs.qtyearly;
						v_qtyday := r_tretabs.dayearly;
						v_amtpay := v_amtearly;
						v_sumqtyday := v_sumqtyday + v_qtyday;
						v_sumqtymin := v_sumqtymin + v_qtymin;
						v_sumamtpay := v_sumamtpay + v_amtpay;
						upd_tpaysum2(v_codempid,para_codapp,para_codpay,r_tretabs.dtework,r_tretabs.codshift,
												 v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
					end if;
					update tre tabs
						 set flgcalear = 'Y',
								 dteyreear = para_dteyrepay,
	 							 dtemthear = para_dtemthpay,
								 numprdear = para_numperiod,
								 coduser   = para_coduser
					 where rowid     = r_tretabs.rowid;

				end loop; -- for c_tretabs
				if v_sumamtpay > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				*/
            exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_adj_ear_gen_tpaysum(p_codempid   varchar2,
                                    p_coduser    varchar2,
                                    p_flgwork		 varchar2) is
		v_flgfound	boolean;
		v_first			boolean := true;
		v_dtemovemt	date;
		v_codcomp		temploy1.codcomp%type;
		v_codpos		temploy1.codpos%type;
		v_numlvl		temploy1.numlvl%type;
		v_codjob		temploy1.codjob%type;
		v_codempmt	temploy1.codempmt%type;
		v_typemp		temploy1.typemp%type;
		v_typpayroll temploy1.typpayroll%type;
		v_codbrlc		temploy1.codbrlc%type;
		v_codcalen	temploy1.codcalen%type;
		v_jobgrade	temploy1.jobgrade%type;
		v_codgrpgl	temploy1.codgrpgl%type;

		v_amthour	 	number := 0;
		v_amtday		number := 0;
		v_amtmth		number := 0;
		--
		v_flgcal    varchar2(1);
		v_codshift	tlateabs.codshift%type;
		v_flgatten	tlateabs.flgatten%type;
		v_qtydaywk	number;
		v_dteeffec  tabsdedh.dteeffec%type;
		v_typabs    tabsdedh.typabs%type;
		v_cond			varchar2(4000);
		v_stmt			varchar2(4000);
		v_syncond		varchar2(4000);
		v_qtyday		number;
		v_qtymin		number;
		v_qty  		  number;
		v_day			  number;
		v_amt   		number;
		v_amtpay		number;
		v_retpay		number;
		v_numseq		number;

      v_timin			  tattence.timin%type;
      v_timout			  tattence.timout%type;
      v_sumqtyday 	number := 0;
      v_sumqtymin  	number := 0;
      v_sumamtpay  	number := 0;

	cursor c_tpaysum2 is
		select t1.codempid,t2.dtework,t2.codalw,nvl(t2.qtymin,0) qtymin,stddec(t2.amtpay,p_codempid,para_chken) amtpay
		  from tpaysum t1,tpaysum2 t2
		 where t1.dteyrepay = t2.dteyrepay
		   and t1.dtemthpay = t2.dtemthpay
		   and t1.numperiod = t2.numperiod
		   and t1.codempid  = t2.codempid
		   and t1.codalw    = t2.codalw
			 and t1.codpay    = t2.codpay
		 	 and t2.codempid  = p_codempid
			 and t2.dtework   between nvl(para_dtestr,dtework) and para_dteend
			 and t2.codalw    = 'DED_EARLY'
			 and t1.flgtran   = 'Y'
       --<<user36 ST11 20/12/2021
       and not exists(select codempid
	                      from tpaysum2
									     where codempid = p_codempid
									       and codalw	  = para_codapp
									       and codpay	  = para_codpay
									       and dtework	= t2.dtework
									       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
       -->>user36 ST11 20/12/2021
	order by t2.dtework;

	cursor c_tabsdedh is
		select dteeffec,numseq,syncond
		  from tabsdedh
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = (select max(dteeffec)
												  from tabsdedh
												 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
												   and dteeffec <= sysdate
												   and typabs	   = v_typabs)
			 and typabs	   = v_typabs
	order by numseq;

	cursor c_tabsdedd is
		select typecal,qtyded
		  from tabsdedd
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = v_dteeffec
		   and typabs    = v_typabs
		   and numseq    = v_numseq
		   and v_qtymin between qtyabsst and qtyabsen;

   begin

      update tlateabs
           set yreadjear = 0, mthadjear = 0, prdadjear = 0,
                 coduser	  = para_coduser
       where yreadjear  = para_dteyrepay
           and mthadjear  = para_dtemthpay
           and prdadjear   = para_numperiod
           and codempid   = p_codempid;

		for r1 in c_tpaysum2 loop
			<<loop_tpaysum2>> loop
				v_qty := 0; v_amt := 0;

				begin
					select qtyearly into v_qty
					  from tlateabs
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;
				if nvl(r1.qtymin,0) <= nvl(v_qty,0) then
					exit loop_tpaysum2;
				end if;
				--
				if v_first then
					v_first := false;
					v_dtemovemt := r1.dtework;
					std_al.get_movemt(p_codempid,v_dtemovemt,'C','C',
													  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
													  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
													  v_amthour,v_amtday,v_amtmth);
				else
					if r1.dtework >= v_dtemovemt then
						v_dtemovemt := r1.dtework;
						std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',
														  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
														  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
														  v_amthour,v_amtday,v_amtmth);
					end if;
				end if;

				begin
					select codshift,flgatten
					  into v_codshift,v_flgatten
					  from tattence
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;

				begin
					select qtydaywk into v_qtydaywk
	  				from tshiftcd
					 where codshift = v_codshift;
				exception when no_data_found then v_qtydaywk := 480;
				end;
				--
				if v_qty > 0 then
		      v_typabs := '2';
		      --
		      <<cal_loop>>
					for r_tabsdedh in c_tabsdedh loop
						v_dteeffec := r_tabsdedh.dteeffec;
						v_numseq   := r_tabsdedh.numseq;
						v_syncond  := r_tabsdedh.syncond;
						--
						v_flgfound := true;
						if v_syncond is not null then
                          v_cond := v_syncond;
                          v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                          v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                          v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                          v_stmt := 'select count(*) from dual where '||v_cond;
                          v_flgfound := execute_stmt(v_stmt);
						end if;
						if v_flgfound then
							v_qtymin := v_qty;
							for r_tabsdedd in c_tabsdedd loop
                            if r_tabsdedd.typecal = '1' then
                              v_qtymin := r_tabsdedd.qtyded;
                            elsif   r_tabsdedd.typecal = '2' then
                              v_qtymin := v_qty;
                            end if;
							end loop;
							v_qtyday := v_qtymin / v_qtydaywk;
							v_amt    := round(v_amtday * v_qtyday,4);
							exit cal_loop;
						end if;
					end loop;	-- c_tabsdedh
				end if; -- v_qty > 0
				--
				begin
					select sum(stddec(amtpay,codempid,para_chken)) into v_retpay
	  				from tpaysum2
					 where codempid = p_codempid
					   and dtework  = r1.dtework
					   and codalw   = 'RET_EARLY';
				end;
				v_amtpay := r1.amtpay + nvl(v_retpay,0);
				--
				if v_amtpay > v_amt then
					v_qty := nvl(r1.qtymin,0) - nvl(v_qty,0);
					v_day := v_qty / v_qtydaywk;
					v_amt := v_amtpay - nvl(v_amt,0);

                       get_time(r1.codempid,r1.dtework,v_timin,v_timout);
                        v_sumqtyday := v_sumqtyday + v_day;
                        v_sumqtymin := v_sumqtymin + v_qty;
                        v_sumamtpay := v_sumamtpay + v_amt;
                        upd_tpaysum2(r1.codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                     r1.dtework,v_codshift ,v_timin,v_timout,v_qty,v_amt,v_amthour,v_amtday);

               update tlateabs
                    set yreadjear  = para_dteyrepay,
                          mthadjear  = para_dtemthpay,
                          prdadjear  = para_numperiod,
                          coduser    = para_coduser
               where codempid   = r1.codempid
                   and dtework     = r1.dtework;

				end if;
				--
				exit loop_tpaysum2;
			end loop;--<<loop_tpaysum2>>
		end loop;  --c_tpaysum2

       if v_sumamtpay > 0 then
					upd_tpaysum(p_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
       end if;

		commit;
	end;  --cal_adj_ear_gen_tpaysum
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_adj_late(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number) is


		v_flgtran   	     tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;

         cursor c_emp is
            select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
              from tprocemp a, temploy1 b
             where a.codempid = b.codempid
                and a.codapp   = para_codapp_wh
                and a.coduser  = p_coduser
                and a.numproc  = p_numproc
         order by a.codempid;

	begin

	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;

				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;

				del_tpaysum(v_codempid,para_codapp,null);
				upd_period(v_codempid,para_codapp,null);
				cal_adj_late_gen_tpaysum(v_codempid,p_coduser,'W');

            /*
            v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				v_first := true;
				for r_tretabs in c_tretabs loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tretabs.dtework;
					v_amtlate := stddec(r_tretabs.amtlate,v_codempid,para_chken);
					if v_amtlate > 0 and check_dteempmt(r_tretabs.dtework) then
						if v_first then
							v_first := false;
							v_dtemovemt := r_tretabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tretabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tretabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;

						get_time(v_codempid,r_tretabs.dtework,v_timin,v_timout);
						v_qtymin := r_tretabs.qtylate;
						v_qtyday := r_tretabs.daylate;
						v_amtpay := v_amtlate;
						v_sumqtyday := v_sumqtyday + v_qtyday;
						v_sumqtymin := v_sumqtymin + v_qtymin;
						v_sumamtpay := v_sumamtpay + v_amtpay;
						upd_tpaysum2(v_codempid,para_codapp,para_codpay,r_tretabs.dtework,r_tretabs.codshift,
												 v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
					end if;


               update tre tabs
						set flgcallate = 'Y',
								dteyrelate = para_dteyrepay,
								dtemthlate = para_dtemthpay,
								numprdlate = para_numperiod,
								coduser = para_coduser
						where rowid = r_tretabs.rowid;

				end loop; -- for c_tre tabs

            if v_sumamtpay > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
            */
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;  --procedure cal_adj_late
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_adj_late_gen_tpaysum(p_codempid   varchar2,
                                     p_coduser    varchar2,
                                     p_flgwork		varchar2) is
		v_flgfound	boolean;
		v_first			boolean := true;
		v_dtemovemt	date;
		v_codcomp		temploy1.codcomp%type;
		v_codpos		   temploy1.codpos%type;
		v_numlvl		      temploy1.numlvl%type;
		v_codjob		      temploy1.codjob%type;
		v_codempmt	   temploy1.codempmt%type;
		v_typemp		   temploy1.typemp%type;
		v_typpayroll     temploy1.typpayroll%type;
		v_codbrlc		  temploy1.codbrlc%type;
		v_codcalen	     temploy1.codcalen%type;
		v_jobgrade	     temploy1.jobgrade%type;
		v_codgrpgl	     temploy1.codgrpgl%type;

		v_amthour	 	number := 0;
		v_amtday		number := 0;
		v_amtmth		number := 0;
		--
		v_flgcal    varchar2(1);
		v_codshift	tlateabs.codshift%type;
		v_flgatten	tlateabs.flgatten%type;
		v_qtydaywk	number;
		v_dteeffec  tabsdedh.dteeffec%type;
		v_typabs    tabsdedh.typabs%type;
		v_cond			varchar2(4000);
		v_stmt			varchar2(4000);
		v_syncond		varchar2(4000);
		v_qtyday		number;
		v_qtymin		number;
		v_qty  		  number;
		v_day			  number;
		v_amt   		number;
		v_amtpay		number;
		v_retpay		number;
		v_numseq		number;

    v_timin				tattence.timin%type;
    v_timout			  tattence.timout%type;

    v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;


	cursor c_tpaysum2 is
		select t1.codempid,t2.dtework,t2.codalw,nvl(t2.qtymin,0) qtymin,stddec(t2.amtpay,p_codempid,para_chken) amtpay
		  from tpaysum t1,tpaysum2 t2
		 where t1.dteyrepay = t2.dteyrepay
		   and t1.dtemthpay = t2.dtemthpay
		   and t1.numperiod = t2.numperiod
		   and t1.codempid  = t2.codempid
		   and t1.codalw    = t2.codalw
			 and t1.codpay    = t2.codpay
		 	 and t2.codempid  = p_codempid
			 and t2.dtework   between nvl(para_dtestr,dtework) and para_dteend
			 and t2.codalw    = 'DED_LATE'
			 and t1.flgtran   = 'Y'
       --<<user36 ST11 20/12/2021
       and not exists(select codempid
	                      from tpaysum2
									     where codempid = p_codempid
									       and codalw	  = para_codapp
									       and codpay	  = para_codpay
									       and dtework	= t2.dtework
									       and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
											       para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
       -->>user36 ST11 20/12/2021
	order by t2.dtework;

	cursor c_tabsdedh is
		select dteeffec,numseq,syncond
		  from tabsdedh
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = (select max(dteeffec)
												  from tabsdedh
												 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
												   and dteeffec <= sysdate
												   and typabs	   = v_typabs)
			 and typabs	   = v_typabs
	order by numseq;

	cursor c_tabsdedd is
		select typecal,qtyded
		  from tabsdedd
		 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteeffec  = v_dteeffec
		   and typabs    = v_typabs
		   and numseq    = v_numseq
		   and v_qtymin between qtyabsst and qtyabsen;

	begin
      update tlateabs
           set yreadjlate = 0, mthadjlate = 0, prdadjlate = 0,
                 coduser	  = para_coduser
      where yreadjlate  = para_dteyrepay
         and mthadjlate  = para_dtemthpay
         and prdadjlate   = para_numperiod
         and codempid   = p_codempid;

		for r1 in c_tpaysum2 loop
			<<loop_tpaysum2>> loop
				v_qty := 0; v_amt := 0;

				begin
					select qtylate into v_qty
					  from tlateabs
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;
				if nvl(r1.qtymin,0) <= nvl(v_qty,0) then
					exit loop_tpaysum2;
				end if;
				--
				if v_first then
					v_first := false;
					v_dtemovemt := r1.dtework;
					std_al.get_movemt(p_codempid,v_dtemovemt,'C','C',
													  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
													  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
													  v_amthour,v_amtday,v_amtmth);
				else
					if r1.dtework >= v_dtemovemt then
						v_dtemovemt := r1.dtework;
						std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',
														  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
														  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
														  v_amthour,v_amtday,v_amtmth);
					end if;
				end if;

				begin
					select codshift,flgatten
					  into v_codshift,v_flgatten
					  from tattence
					 where codempid = p_codempid
					   and dtework  = r1.dtework;
				exception when no_data_found then null;
				end;

				begin
					select qtydaywk into v_qtydaywk
	  				from tshiftcd
					 where codshift = v_codshift;
				exception when no_data_found then v_qtydaywk := 480;
				end;
				--
				if v_qty > 0 then
		      v_typabs := '1';
		      --
		      <<cal_loop>>
					for r_tabsdedh in c_tabsdedh loop
						v_dteeffec := r_tabsdedh.dteeffec;
						v_numseq   := r_tabsdedh.numseq;
						v_syncond  := r_tabsdedh.syncond;
						--
						v_flgfound := true;
						if v_syncond is not null then
                                    v_cond := v_syncond;
                                    v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                                    v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                                    v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                                    v_stmt := 'select count(*) from dual where '||v_cond;
                                    v_flgfound := execute_stmt(v_stmt);
						end if;

                  if v_flgfound then
							v_qtymin := v_qty;
							for r_tabsdedd in c_tabsdedd loop
                                         if r_tabsdedd.typecal = '1' then
                                           v_qtymin := r_tabsdedd.qtyded;
                                         elsif   r_tabsdedd.typecal = '2' then
                                           v_qtymin := v_qty;
                                         end if;
							end loop;
							v_qtyday := v_qtymin / v_qtydaywk;
							v_amt    := round(v_amtday * v_qtyday,4);
							exit cal_loop;
						end if;
					end loop;	-- c_tabsdedh
				end if; -- v_qty > 0
				--
				begin
					select sum(stddec(amtpay,codempid,para_chken)) into v_retpay
	  				from tpaysum2
					 where codempid = p_codempid
					   and dtework  = r1.dtework
					   and codalw   = 'RET_LATE';
				end;
				v_amtpay := r1.amtpay + nvl(v_retpay,0);  --???????????????????????? = Cursor  TPAYSUM2.AMTPAY + ?????????????????(????)

				if v_amtpay > v_amt then
					v_qty := nvl(r1.qtymin,0) - nvl(v_qty,0);
					v_day := v_qty / v_qtydaywk;
					v_amt := v_amtpay - nvl(v_amt,0);

                      get_time(r1.codempid,r1.dtework,v_timin,v_timout);
                        v_sumqtyday := v_sumqtyday + v_day;
                        v_sumqtymin := v_sumqtymin + v_qty;
                        v_sumamtpay := v_sumamtpay + v_amt;
                        upd_tpaysum2(r1.codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                     r1.dtework,v_codshift ,v_timin,v_timout,v_qty,v_amt,v_amthour,v_amtday);

                  update tlateabs
                        set yreadjlate = para_dteyrepay,
                              mthadjlate = para_dtemthpay,
                              prdadjlate = para_numperiod,
                              coduser    = para_coduser
                  where codempid   = r1.codempid
                      and dtework    = r1.dtework;
				end if;
				--
				exit loop_tpaysum2;
			end loop;--<<loop_tpaysum2>>
		end loop;  --c_tpaysum2

       if v_sumamtpay > 0 then
					upd_tpaysum(p_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
       end if;

      commit;
	end;  --cal_adj_late_gen_tretabs
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_wage(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number) is
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_amtwork 		number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_sumamtday  	number := 0;
		v_sumamthour 	number := 0;
		v_zupdsal   	varchar2(4);

		type char1 is table of varchar2(30) index by binary_integer;
			v_unitcal		char1;
			v_codincom  char1;
			v_codretro  char1;

		type num1 is table of number index by binary_integer;
			v_amtincom	num1;

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tattence is
			select rowid,dtework,codshift,qtyhwork,qtydwork,amtwork,timin,timout
			  from tattence
			 where codempid  = v_codempid
			   and dtework   between nvl(para_dtestr,dtework) and para_dteend
			   and typwork  <> 'H'
			   and flgcalwk  = 'Y'
			   and dteyreret = 0
		order by dtework;

		cursor c_tcontpmd is
			select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
			  from tcontpmd
			 where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
			   and dteeffec <= sysdate
			   and codempmt  = v_codempmt
		order by dteeffec desc;
	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;

				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,para_codpay);
				--
				upd_period(v_codempid,para_codapp,para_codpay);
				--
				update tattence
					 set dteyreret = 0,dtemthret = 0,numprdret = 0
				 where codempid  = v_codempid
					 and dteyreret = para_dteyrepay
					 and dtemthret = para_dtemthpay
					 and numprdret = para_numperiod;
				--
        for a in 1..10 loop
          v_unitcal(a)	:= null;
          v_codincom(a)	:= null;
          v_codretro(a)	:= null;
          v_amtincom(a)	:= 0;
        end loop;
        begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10,
                 codretro1,codretro2,codretro3,codretro4,codretro5,codretro6,codretro7,codretro8,codretro9,codretro10
            into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10),
                 v_codretro(1),v_codretro(2),v_codretro(3),v_codretro(4),v_codretro(5),v_codretro(6),v_codretro(7),v_codretro(8),v_codretro(9),v_codretro(10)
            from tcontpms
           where codcompy = hcm_util.get_codcomp_level(r_emp.codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontpms
                              where codcompy = hcm_util.get_codcomp_level(r_emp.codcomp,1)
                                and dteeffec <= trunc(sysdate));
        exception when no_data_found then	return;
        end;
        --
				v_first := true;
				for r_tattence in c_tattence loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tattence.dtework;
					if check_dteempmt(r_tattence.dtework) then
						v_amtwork := 0;
						if v_first then
							v_first := false;
							v_dtemovemt := r_tattence.dtework;
							std_al.get_movemt2(v_codempid,v_dtemovemt,'C','C',
										             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
						else
							if r_tattence.dtework >= v_dtemovemt then
								v_dtemovemt := r_tattence.dtework;
								std_al.get_movemt2(v_codempid,v_dtemovemt,'C','U',
											             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																	 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																	 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
							end if;
						end if;
						--
						for r_tcontpmd in c_tcontpmd loop
							v_unitcal(1) := r_tcontpmd.unitcal1;
							v_unitcal(2) := r_tcontpmd.unitcal2;
							v_unitcal(3) := r_tcontpmd.unitcal3;
							v_unitcal(4) := r_tcontpmd.unitcal4;
							v_unitcal(5) := r_tcontpmd.unitcal5;
							v_unitcal(6) := r_tcontpmd.unitcal6;
							v_unitcal(7) := r_tcontpmd.unitcal7;
							v_unitcal(8) := r_tcontpmd.unitcal8;
							v_unitcal(9) := r_tcontpmd.unitcal9;
							v_unitcal(10):= r_tcontpmd.unitcal10;
							begin
								select qtydaywk	into v_qtymin
								  from tshiftcd
								 where codshift = r_tattence.codshift;
							exception when no_data_found then v_qtymin := 0;
							end;
							--
							v_amtpay := 0;	v_amtwork := 0;
							for i in 1..10 loop
								if v_unitcal(i) in ('H','D') and v_amtincom(i) > 0 and para_codpay = v_codretro(i) then
									if v_unitcal(i) = 'H' then
										v_amtpay := v_amtpay + (v_amtincom(i) * (v_qtymin / 60));
									elsif v_unitcal(i) = 'D' then
										v_amtpay := v_amtpay + v_amtincom(i);
									end if;

									begin
										select nvl(sum(stddec(t2.amtpay,t2.codempid,para_chken)),0)
										  into v_amtwork
										  from tpaysum t1,tpaysum2 t2
										 where t1.dteyrepay = t2.dteyrepay
										   and t1.dtemthpay = t2.dtemthpay
										   and t1.numperiod = t2.numperiod
										   and t1.codempid  = t2.codempid
										   and t1.codalw    = t2.codalw
											 and t1.codpay    = t2.codpay
										 	 and t2.codempid  = v_codempid
											 and t2.dtework   = r_tattence.dtework
											 and t2.codalw    = 'WAGE'
											 and t2.codpay		= v_codincom(i)
											 and t1.flgtran   = 'Y';
										exception when no_data_found then null;
									end;
									if round(v_amtpay,4) <> round(v_amtwork,4) and v_amtwork > 0 then
										v_sumamtday := v_amtpay;
										v_sumamthour:= v_amtpay / (v_qtymin / 60);

										v_amtpay    := v_amtpay    - v_amtwork;
										v_sumqtyday := v_sumqtyday + 1;
										v_sumqtymin := v_sumqtymin + v_qtymin;
										v_sumamtpay := v_sumamtpay + v_amtpay;
										upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                     r_tattence.dtework,r_tattence.codshift,r_tattence.timin,r_tattence.timout,v_qtymin,v_amtpay,v_sumamthour,v_sumamtday);
                    --
                    update tattence
                       set dteyreret	= para_dteyrepay,
                           dtemthret	= para_dtemthpay,
                           numprdret	= para_numperiod,
                           coduser		= para_coduser
                     where rowid = r_tattence.rowid;
                  end if;
									exit;
					 			end if;
							end loop; -- for i
							exit;
						end loop; -- for c_tcontpmd
					end if; -- check_dteempmt
				end loop; -- for c_tattence
				-------------------------------------------------------------
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_sumamthour,v_sumamtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_ot(p_codapp   varchar2,
                       p_coduser  varchar2,
                       p_numproc	number) is
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_dtework			tovrtime.dtework%type;
		v_typot				tovrtime.typot%type;
		v_amtottot	 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday  	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_qtydaywk   	number := 0;
		v_zupdsal   	varchar2(4);

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tovrtime is
			select rowid,dtework,typot,codshift,timstrt,timend,amtottot
	 		  from tovrtime
			 where codempid  = v_codempid
			   and dtework between nvl(para_dtestr,dtework) and para_dteend
			   and flgotcal  = 'Y'
			   and dteyreret = 0
		order by dtework;

		cursor c_totpaydt is
			select qtyminot,rteotpay
			  from totpaydt
			 where codempid = v_codempid
			   and dtework  = v_dtework
			   and typot    = v_typot
		order by codempid,dtework,typot,rteotpay;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tovrtime
					 set dteyreret = 0,dtemthret = 0,numprdret = 0
				 where codempid  = v_codempid
					 and dteyreret = para_dteyrepay
					 and dtemthret = para_dtemthpay
					 and numprdret = para_numperiod;
				--
				v_first := true;
				for r_tovrtime in c_tovrtime loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tovrtime.dtework;
					if check_dteempmt(r_tovrtime.dtework) then
						begin
							select qtydaywk into v_qtydaywk
								from tshiftcd
							 where codshift	= r_tovrtime.codshift;
						exception when no_data_found then
								v_qtydaywk := 0;
						end;
						v_dtework  := r_tovrtime.dtework;
						v_typot    := r_tovrtime.typot;
						v_amtottot := stddec(r_tovrtime.amtottot,v_codempid,para_chken);
						if v_first then
							v_first := false;
							v_dtemovemt := r_tovrtime.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tovrtime.dtework >= v_dtemovemt then
								v_dtemovemt := r_tovrtime.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;

						v_qtymin := 0;	v_amtpay := 0;
						for r_totpaydt in c_totpaydt loop
							v_qtymin := v_qtymin + r_totpaydt.qtyminot;
							v_amtpay := v_amtpay + ((r_totpaydt.qtyminot / 60) * r_totpaydt.rteotpay * v_amthour);
						end loop; -- for c_totpaydt

						if round(v_amtpay,4) <> round(v_amtottot,4) and v_amtottot > 0 then
							v_amtpay    := v_amtpay - v_amtottot;
							v_sumqtyday := v_sumqtyday + (v_qtymin / v_qtydaywk);
							v_sumqtymin := v_sumqtymin + v_qtymin;
							v_sumamtpay := v_sumamtpay + v_amtpay;
							upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                         r_tovrtime.dtework,v_typot,r_tovrtime.timstrt,r_tovrtime.timend,v_qtymin,v_amtpay,v_amthour,v_amtday);

							update tovrtime
							   set dteyreret	= para_dteyrepay,
									   dtemthret	= para_dtemthpay,
									   numprdret	= para_numperiod,
									   coduser		= para_coduser
							where rowid = r_tovrtime.rowid;
						end if;
					end if; -- check_dteempmt
				end loop; -- for c_tovrtime
				if v_sumamtpay > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_abs(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number) is
		v_first				boolean := true;
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

		v_codempid		temploy1.codempid%type;
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_syncond			varchar2(4000);
		v_amtabsent	 	number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_qtymin2		 	number := 0;
		v_numseq			number;

		cursor c_emp is
		  select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '3')
				 and typabs	   = '3'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '3'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtyabsent,amtabsent
			  from tlateabs
			 where codempid  = v_codempid
		     and dtework   between nvl(para_dtestr,dtework) and para_dteend
			   and flgcalabs = 'Y'
			   and yreretabs = 0
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||           
		order by dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set yreretabs = 0, mthretabs = 0, prdretabs = 0,
							 coduser	 = para_coduser
				 where yreretabs = para_dteyrepay
					 and mthretabs = para_dtemthpay
					 and prdretabs = para_numperiod
					 and codempid  = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework  := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						v_amtabsent := stddec(r_tlateabs.amtabsent,v_codempid,para_chken);
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							--
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if v_amtabsent > 0 then
									begin
										select qtydaywk into v_qtydaywk
										  from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtyabsent;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                    if r_tabsdedd.typecal = '1' then
                      v_qtymin := r_tabsdedd.qtyded;
                    end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;

									begin
										select qtymin into v_qtymin2
										  from tpaysum2
										 where codempid = v_codempid
										   and dtework  = r_tlateabs.dtework
										   and codalw   = 'DED_ABSENT'
										   and rownum   = 1;

										if v_qtymin2 >= v_qtymin then
											v_amtabsent := (v_amtabsent * v_qtymin)/v_qtymin2;
										end if;
									exception when no_data_found then v_qtymin2 := 0;
									end;
									if round(v_amtpay,4) <> round(v_amtabsent,4) then
										v_amtpay := v_amtpay - v_amtabsent;
										v_sumqtyday := v_sumqtyday + v_qtyday;
										v_sumqtymin := v_sumqtymin + v_qtymin;
										v_sumamtpay := v_sumamtpay + v_amtpay;
										get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
										upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                     r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);

										update tlateabs
										   set yreretabs = para_dteyrepay,
												   mthretabs = para_dtemthpay,
												   prdretabs = para_numperiod,
												   coduser   = para_coduser
										 where rowid = r_tlateabs.rowid;
									end if;-- round(v_amtpay,4) <> round(v_amtabsent,4)
								end if;-- v_amtabsent > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_ear(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number) is
		v_first				boolean := true;
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

		v_codempid		temploy1.codempid%type;
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_syncond			varchar2(4000);
		v_amtearly	 	number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_qtymin2		 	number := 0;
		v_numseq			number;

		cursor c_emp is
		  select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '2')
				 and typabs	   = '2'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '2'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtyearly,amtearly
			  from tlateabs
			 where codempid  = v_codempid
			   and dtework   between nvl(para_dtestr,dtework) and para_dteend
			   and flgcalear = 'Y'
			   and yreretear = 0
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||           
		order by dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set yreretear = 0, mthretear = 0, prdretear = 0,
							 coduser	 = para_coduser
				 where yreretear = para_dteyrepay
					 and mthretear = para_dtemthpay
					 and prdretear = para_numperiod
					 and codempid  = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework  := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						v_amtearly := stddec(r_tlateabs.amtearly,v_codempid,para_chken);
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							--
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if v_amtearly > 0 then
									begin
										select qtydaywk into v_qtydaywk
										  from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtyearly;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                    if r_tabsdedd.typecal = '1' then
                      v_qtymin := r_tabsdedd.qtyded;
                    end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;

									begin
										select qtymin into v_qtymin2
										  from tpaysum2
										 where codempid = v_codempid
										   and dtework  = r_tlateabs.dtework
										   and codalw   = 'DED_EARLY'
										   and rownum   = 1;

											if v_qtymin2 >= v_qtymin then
												v_amtearly := (v_amtearly * v_qtymin)/v_qtymin2;
											end if;
									exception when no_data_found then v_qtymin2 := 0;
									end;

									if round(v_amtpay,4) <> round(v_amtearly,4) then
										v_amtpay := v_amtpay - v_amtearly;
										v_sumqtyday := v_sumqtyday + v_qtyday;
										v_sumqtymin := v_sumqtymin + v_qtymin;
										v_sumamtpay := v_sumamtpay + v_amtpay;
										get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
										upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                     r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);

										update tlateabs
											 set yreretear = para_dteyrepay,
													 mthretear = para_dtemthpay,
													 prdretear = para_numperiod,
													 coduser   = para_coduser
									   where rowid     = r_tlateabs.rowid;
									end if;-- round(v_amtpay,4) <> round(v_amtearly,4)
								end if;-- v_amtearly > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_late(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number) is
		v_first				boolean := true;
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

		v_codempid		temploy1.codempid%type;
		v_flgsecu 		boolean;
		v_flgfound 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_dteeffec		tabsdedh.dteeffec%type;
		v_timin				tattence.timin%type;
		v_timout			tattence.timout%type;
		v_qtydaywk	 	number := 0;
		v_cond				varchar2(4000);
		v_stmt				varchar2(4000);
		v_syncond			varchar2(4000);
		v_amtlate		 	number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_zupdsal   	varchar2(4);
		v_qtymin2		 	number := 0;
		v_numseq			number;

		cursor c_emp is
			select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tabsdedh is
			select dteeffec,numseq,syncond
			  from tabsdedh
			 where codcompy  = para_codcompy
			   and dteeffec  = (select max(dteeffec)
													  from tabsdedh
													 where codcompy  = para_codcompy
													   and dteeffec <= sysdate
													   and typabs	   = '1')
				 and typabs	   = '1'
		order by numseq;

		cursor c_tabsdedd is
			select typecal,qtyded--user22 : 18/02/2020 || qtyded
			  from tabsdedd
			 where codcompy  = para_codcompy
			   and dteeffec  = v_dteeffec
			   and typabs    = '1'
			   and numseq    = v_numseq
			   and v_qtymin between qtyabsst and qtyabsen;

		cursor c_tlateabs is
			select rowid,dtework,codshift,qtylate,amtlate
			  from tlateabs
			 where codempid   = v_codempid
			   and dtework    between nvl(para_dtestr,dtework) and para_dteend
			   and flgcallate = 'Y'
			   and yreretlate = 0
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = tlateabs.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= tlateabs.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||           
		order by dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_flgtran := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tlateabs
					 set yreretlate = 0, mthretlate = 0, prdretlate = 0,
							 coduser	  = para_coduser
				 where yreretlate = para_dteyrepay
					 and mthretlate = para_dtemthpay
					 and prdretlate = para_numperiod
					 and codempid   = v_codempid;
				--
				v_first := true;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				for r_tlateabs in c_tlateabs loop
					indx_codempid2 := v_codempid;
					para_dtework  := r_tlateabs.dtework;
					if check_dteempmt(r_tlateabs.dtework) then
						v_amtpay := 0;
						v_amtlate := stddec(r_tlateabs.amtlate,v_codempid,para_chken);
						if v_first then
							v_first := false;
							v_dtemovemt := r_tlateabs.dtework;
							std_al.get_movemt(v_codempid,v_dtemovemt,'C','C',
															  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
															  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
															  v_amthour,v_amtday,v_amtmth);
						else
							if r_tlateabs.dtework >= v_dtemovemt then
								v_dtemovemt := r_tlateabs.dtework;
								std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
																  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																  v_amthour,v_amtday,v_amtmth);
							end if;
						end if;
						--
						<<cal_loop>>
						for r_tabsdedh in c_tabsdedh loop
							v_dteeffec := r_tabsdedh.dteeffec;
							v_numseq   := r_tabsdedh.numseq;
							v_syncond  := r_tabsdedh.syncond;
							--
							v_flgfound := true;
							if v_syncond is not null then
								v_cond := v_syncond;
								v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
								v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
								v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
								v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
								v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
								v_stmt := 'select count(*) from dual where '||v_cond;
								v_flgfound := execute_stmt(v_stmt);
							end if;
							if v_flgfound then
								if v_amtlate > 0 then
									begin
										select qtydaywk into v_qtydaywk
  										from tshiftcd
										 where codshift = r_tlateabs.codshift;
									exception when no_data_found then
										v_qtydaywk :=0;
									end;
									v_qtymin := r_tlateabs.qtylate;
									for r_tabsdedd in c_tabsdedd loop
--<< user22 : 18/02/2020 ||
                    if r_tabsdedd.typecal = '1' then
                      v_qtymin := r_tabsdedd.qtyded;
                    end if;
										--v_qtymin := r_tabsdedd.qtyded;
-->> user22 : 18/02/2020 ||
									end loop; --
									v_qtyday := v_qtymin / v_qtydaywk;
									if v_qtydaywk > 0 then
										v_amtpay := round(v_amtday * v_qtyday,4);
									else
										v_amtpay := v_amthour * v_qtymin / 60;
									end if;
									begin
										select qtymin into v_qtymin2
										  from tpaysum2
										 where codempid = v_codempid
										   and dtework  = r_tlateabs.dtework
										   and codalw   = 'DED_LATE'
										   and rownum   = 1;

											if v_qtymin2 >= v_qtymin then
												v_amtlate:= (v_amtlate * v_qtymin)/v_qtymin2;
											end if;
									exception when no_data_found then v_qtymin2 := 0;
									end;
									if round(v_amtpay,4) <> round(v_amtlate,4) then
										v_amtpay := v_amtpay - v_amtlate;
										v_sumqtyday := v_sumqtyday + v_qtyday;
										v_sumqtymin := v_sumqtymin + v_qtymin;
										v_sumamtpay := v_sumamtpay + v_amtpay;
										get_time(v_codempid,r_tlateabs.dtework,v_timin,v_timout);
										upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                                     r_tlateabs.dtework,r_tlateabs.codshift,v_timin,v_timout,v_qtymin,v_amtpay,v_amthour,v_amtday);
										update tlateabs
										   set yreretlate = para_dteyrepay,
												   mthretlate = para_dtemthpay,
												   prdretlate = para_numperiod,
												   coduser    = para_coduser
										 where rowid = r_tlateabs.rowid;
									end if;-- round(v_amtpay,4) <> round(v_amtlate,4)
								end if;-- v_amtlate > 0
								--
								exit cal_loop;
							end if; -- v_flgfound
						end loop;-- c_tabsdedh
					end if; -- check_dteempmt
				end loop; -- for c_tlateabs
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_ret_leave(p_codapp   varchar2,
                          p_coduser  varchar2,
                          p_numproc	 number) is
		v_first				boolean := true;
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

		v_flgsecu 		boolean;
		v_flgtran   	tpaysum.flgtran%type;
		v_codempid		temploy1.codempid%type;
		v_dtework			tleavetr.dtework%type;
		v_amtlvded	 	number := 0;
		v_qtyday		 	number := 0;
		v_qtymin		 	number := 0;
		v_amtpay			number := 0;
		v_sumqtyday 	number := 0;
		v_sumqtymin  	number := 0;
		v_sumamtpay  	number := 0;
		v_codcurr			temploy3.codcurr%type;
		v_ratechge		tratechg.ratechge%type;
		v_zupdsal   	varchar2(4);
		v_pctded			number := 0;

		type amtincom is table of number index by binary_integer;
			v_amtincom  amtincom;

		cursor c_emp is
		  select a.codempid,codcomp,typpayroll,codempmt,codpos,typemp,numlvl,dteempmt,dteeffex
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp_wh
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

		cursor c_tleavetr is
			select a.rowid,a.dtework,a.codleave,a.typleave,a.qtymin,a.qtylvded,a.amtlvded,a.timstrt,a.timend
	  		from tleavetr a
			 where a.codempid  = v_codempid
			   and a.dtework between nvl(para_dtestr,dtework) and para_dteend
			   and nvl(a.dteyreret,0) = 0
    	   and exists (select b.typleave
    	                 from tleavety b
    	                where b.typleave = a.typleave
    	                  and((para_codapp = 'RET_LEAVE'  and b.flgtype  <> 'M')
                         or (para_codapp = 'RET_LEAVEM' and b.flgtype  =  'M')))
--<< user22 : 22/03/2024 : ST11 (KOHU #1804) || 
         and not exists(select codempid
                          from tpaysum2
                         where codempid = a.codempid
                           and codalw	  = para_codapp
                           and codpay	  = para_codpay
                           and dtework	= a.dtework
                           and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <>
                               para_dteyrepay||lpad(para_dtemthpay,2,'0')||lpad(para_numperiod,2,'0'))
-->> user22 : 22/03/2024 : ST11 (KOHU #1804) ||  		
    order by a.dtework;

	begin
	  for r_emp in c_emp loop
			<< main_loop >>
			loop
				v_codempid := r_emp.codempid;
				para_dteempmt := r_emp.dteempmt;
				para_dteeffex := r_emp.dteeffex;
				v_sumqtyday := 0;	v_sumqtymin := 0;	v_sumamtpay := 0;
				v_flgtran   := chk_tpaysum(v_codempid,para_codapp,para_codpay);
				if v_flgtran = 'Y' then
					exit main_loop;
				end if;
				--
				del_tpaysum(v_codempid,para_codapp,null);
				--
				upd_period(v_codempid,para_codapp,null);
				--
				update tleavetr
					 set dteyreret = 0,
					     dtemthret = 0,
					     numprdret = 0
				 where codempid  = v_codempid
					 and dteyreret = para_dteyrepay
					 and dtemthret = para_dtemthpay
					 and numprdret = para_numperiod;
				--
				v_first     := true;
				for i in 1..10 loop
					v_amtincom(i) := 0;
				end loop;

				for r_tleavetr in c_tleavetr loop
					indx_codempid2 := v_codempid;
					para_dtework   := r_tleavetr.dtework;
					if check_dteempmt(r_tleavetr.dtework) then
						v_dtework := r_tleavetr.dtework;
						v_amtlvded := stddec(r_tleavetr.amtlvded,v_codempid,para_chken);
						if v_amtlvded > 0 then
							begin
								select pctded
								  into v_pctded
								  from tleavety
								 where typleave = r_tleavetr.typleave;
							exception when no_data_found then
								exit main_loop;
							end;

							if v_first then
								v_first := false;
								v_dtemovemt := r_tleavetr.dtework;
								std_al.get_movemt2(v_codempid,v_dtemovemt,'C','C',
											             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																	 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																	 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
							else
								if r_tleavetr.dtework >= v_dtemovemt then
									v_dtemovemt := r_tleavetr.dtework;
									std_al.get_movemt2(v_codempid,v_dtemovemt,'C','U',
												             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
																		 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
																		 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
								end if;
							end if;
							get_wage_income(para_codcompy,v_codempmt,
															 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
														 	 v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
														 	 v_amthour,v_amtday,v_amtmth);
							v_amtday := (v_amtday * nvl(v_pctded,0) / 100);

							v_qtymin := r_tleavetr.qtymin;
							v_qtyday := r_tleavetr.qtylvded;
							v_amtpay := v_amtday * r_tleavetr.qtylvded;

							if round(v_amtpay,4) <> round(v_amtlvded,4) then
								v_amtpay := v_amtpay - v_amtlvded;
								v_sumqtyday := v_sumqtyday + v_qtyday;
								v_sumqtymin := v_sumqtymin + v_qtymin;
								v_sumamtpay := v_sumamtpay + v_amtpay;
								upd_tpaysum2(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
                                             r_tleavetr.dtework,r_tleavetr.codleave,r_tleavetr.timstrt,r_tleavetr.timend,v_qtymin,v_amtpay,v_amthour,v_amtday);

								update tleavetr
								   set dteyreret	= para_dteyrepay,
										   dtemthret	= para_dtemthpay,
										   numprdret	= para_numperiod,
										   coduser		= para_coduser
								 where rowid = r_tleavetr.rowid;
							end if;
						end if;
					end if; -- check_dteempmt
				end loop; -- for c_tleavetr
				if v_sumqtyday > 0 then
					upd_tpaysum(v_codempid,para_codapp,para_codpay,v_codcomp,v_codpos,v_typpayroll,
											v_amthour,v_amtday,v_sumqtyday,v_sumqtymin,v_sumamtpay);
				end if;
				exit main_loop;
			end loop; -- main_loop
		end loop; -- for r_emp
    --
    indx_codempid2		 := null;
    para_dtework		 := null;

    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'Y',
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc    = p_numproc;
    commit;
  exception when others then
    rollback;
    p_sqlerrm   := sqlerrm;
    para_numrec := 0;
    update tprocount
       set qtyproc    = para_numrec,
           flgproc    = 'E',
           codempid   = indx_codempid2,
           dtework    = para_dtework,
           remark     = substr('Error : '||p_sqlerrm,1,500),
           dteupd     = sysdate,
           dtecalend  = sysdate
     where codapp 	  = para_codapp_wh
       and coduser    = p_coduser
       and numproc 	  = p_numproc;
    commit;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	function chk_tpaysum(p_codempid  varchar2,
											 p_codalw 	 varchar2,
											 p_codpay  	 varchar2) return varchar2 is
		v_flgtran  	varchar2(1);
	begin
    return('N'); -- cancel this function because at main query already check
		begin
			select flgtran into v_flgtran
			  from tpaysum
			 where dteyrepay = para_dteyrepay
			   and dtemthpay = para_dtemthpay
			   and numperiod = para_numperiod
			   and codempid  = p_codempid
			   and codalw		 = p_codalw
			   and codpay		 = nvl(p_codpay,codpay)
			   and flgtran   = 'Y'
			   and rownum    = 1;
		exception when no_data_found then	v_flgtran := 'N';
		end;
		return(v_flgtran);
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure upd_period(p_codempid   varchar2,
											 p_codalw 	  varchar2,
											 p_codpay    	varchar2) is
	cursor c_tpaysum is
		select a.dteyrepay,a.dtemthpay,a.numperiod,a.codempid,a.codpay,a.codalw
		  from tpaysum a,tpaysum2 b
		 where a.dteyrepay = b.dteyrepay
		   and a.dtemthpay = b.dtemthpay
		   and a.numperiod = b.numperiod
			 and a.codempid  = b.codempid
			 and a.codalw		 = b.codalw
 			 and a.codpay		 = b.codpay
 			 --
			 and a.codempid  = p_codempid
			 and a.codalw		 = p_codalw
 			 and a.codpay		 = nvl(p_codpay,a.codpay)
			 and a.flgtran	 = 'N'
			 and b.dtework   between nvl(para_dtestr,b.dtework) and para_dteend
	group by a.dteyrepay,a.dtemthpay,a.numperiod,a.codempid,a.codpay,a.codalw
	order by a.dteyrepay,a.dtemthpay,a.numperiod;

	begin
		if p_codalw in ('AWARD','PAY_VACAT') then
			return;
		end if;

		for r_tpaysum in c_tpaysum loop
			delete tpaysum
			 where dteyrepay = r_tpaysum.dteyrepay
			   and dtemthpay = r_tpaysum.dtemthpay
			   and numperiod = r_tpaysum.numperiod
				 and codempid  = r_tpaysum.codempid
				 and codalw		 = r_tpaysum.codalw
				 and codpay		 = r_tpaysum.codpay;
			--
			delete tpaysum2
			 where dteyrepay = r_tpaysum.dteyrepay
			   and dtemthpay = r_tpaysum.dtemthpay
			   and numperiod = r_tpaysum.numperiod
				 and codempid  = r_tpaysum.codempid
				 and codalw		 = r_tpaysum.codalw
				 and codpay		 = r_tpaysum.codpay;
			--
	  	if p_codalw = 'WAGE' then
				update tattence
				   set flgcalwk  = 'N',
				       amtwork 	 = stdenc(0,codempid,para_chken),
					 		 dteyrepay = 0, dtemthpay = 0,	numperiod = 0
				 where dteyrepay = r_tpaysum.dteyrepay
				   and dtemthpay = r_tpaysum.dtemthpay
				   and numperiod = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;

	  	elsif p_codalw = 'OT' then
				delete tpaysumd
				 where dteyrepay = r_tpaysum.dteyrepay
				   and dtemthpay = r_tpaysum.dtemthpay
				   and numperiod = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
				--
			  update tovrtime
	  			 set flgotcal  = 'N',
						   amtottot  = stdenc(0,codempid,para_chken),
					  	 amtothr   = stdenc(0,codempid,para_chken),
						   dteyrepay = 0,dtemthpay = 0,numperiod = 0
				 where dteyrepay = r_tpaysum.dteyrepay
				   and dtemthpay = r_tpaysum.dtemthpay
				   and numperiod = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	--elsif p_codalw = 'AWARD' then null;
	  	--elsif p_codalw = 'PAY_VACAT' then null;
	  	elsif p_codalw = 'PAY_OTHER' then null;--not mark flag at transaction
	  	elsif p_codalw = 'DED_ABSENT' then
				update tlateabs
					 set flgcalabs = 'N',
					     amtabsent = stdenc(0,codempid,para_chken),
							 dteyreabs = 0,	dtemthabs = 0,numprdabs = 0,
							 coduser	 = para_coduser
				 where dteyreabs = r_tpaysum.dteyrepay
				   and dtemthabs = r_tpaysum.dtemthpay
				   and numprdabs = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	elsif p_codalw = 'DED_EARLY' then
				update tlateabs
					 set flgcalear = 'N',
					     amtearly  = stdenc(0,codempid,para_chken),
							 dteyreear = 0, dtemthear = 0, numprdear = 0,
							 coduser	 = para_coduser
				 where dteyreear = r_tpaysum.dteyrepay
				   and dtemthear = r_tpaysum.dtemthpay
				   and numprdear = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	elsif p_codalw = 'DED_LATE' then
				update tlateabs
					 set flgcallate = 'N',
					     amtlate    = stdenc(0,codempid,para_chken),
							 dteyrelate = 0, dtemthlate = 0,numprdlate = 0,
							 coduser	  = para_coduser
				 where dteyrelate = r_tpaysum.dteyrepay
				   and dtemthlate = r_tpaysum.dtemthpay
				   and numprdlate = r_tpaysum.numperiod
					 and codempid   = r_tpaysum.codempid;
	  	elsif p_codalw = 'DED_LEAVE' then
				update tleavetr a
					 set dteyrepay = 0,
							 dtemthpay = 0,
							 numperiod = 0,
							 amtlvded  = stdenc(0,codempid,para_chken),
							 qtylvded  = 0,
							 coduser   = para_coduser
				 where dteyrepay = r_tpaysum.dteyrepay
				   and dtemthpay = r_tpaysum.dtemthpay
				   and numperiod = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid
           and exists (select typleave
					               from tleavety b
					              where a.typleave = b.typleave
					                and flgtype  <> 'M');
	  	elsif p_codalw = 'DED_LEAVEM' then
				update tleavetr a
					 set dteyrepay = 0,
							 dtemthpay = 0,
							 numperiod = 0,
							 amtlvded  = stdenc(0,codempid,para_chken),
							 qtylvded  = 0,
							 coduser   = para_coduser
				 where dteyrepay = r_tpaysum.dteyrepay
				   and dtemthpay = r_tpaysum.dtemthpay
				   and numperiod = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid
           and exists (select typleave
					               from tleavety b
					              where a.typleave = b.typleave
					                and flgtype  = 'M');
	  	elsif p_codalw = 'ADJ_ABSENT' then
				/*
            update tretabs
	 				 set flgcalabs = 'N',
							 dteyreabs = 0,
							 dtemthabs = 0,
							 numprdabs = 0,
               qtyabsent = 0,
               dayabsent = 0,
               amtabsent = stdenc(0,codempid,para_chken),
							 coduser	 = para_coduser
				 where dteyreabs = r_tpaysum.dteyrepay
				   and dtemthabs = r_tpaysum.dtemthpay
				   and numprdabs = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;*/ null;
	  	elsif p_codalw = 'ADJ_EARLY' then
				/*update tretabs
					 set flgcalear = 'N',
							 dteyreear = 0,
							 dtemthear = 0,
							 numprdear = 0,
               qtyearly  = 0,
               dayearly  = 0,
               amtearly  = stdenc(0,codempid,para_chken),
							 coduser	 = para_coduser
				 where dteyreear = r_tpaysum.dteyrepay
					 and dtemthear = r_tpaysum.dtemthpay
					 and numprdear = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;*/ null;
	  	elsif p_codalw = 'ADJ_LATE' then
      null;
                  /*
                  update tretabs
                  set flgcallate = 'N',
                  dteyrelate = 0,
                  dtemthlate = 0,
                  numprdlate = 0,
                  qtylate    = 0,
                  daylate    = 0,
                  amtlate    = stdenc(0,codempid,para_chken),
                  coduser	  = para_coduser
                  where dteyrelate = r_tpaysum.dteyrepay
                  and dtemthlate = r_tpaysum.dtemthpay
                  and numprdlate = r_tpaysum.numperiod
                  and codempid   = r_tpaysum.codempid;
                  */
	  	elsif p_codalw = 'RET_WAGE' then
				update tattence
					 set dteyreret = 0,dtemthret = 0,numprdret = 0
				 where dteyreret = r_tpaysum.dteyrepay
					 and dtemthret = r_tpaysum.dtemthpay
					 and numprdret = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;

	  	elsif p_codalw = 'RET_OT' then
				update tovrtime
					 set dteyreret = 0,dtemthret = 0,numprdret = 0
				 where dteyreret = r_tpaysum.dteyrepay
					 and dtemthret = r_tpaysum.dtemthpay
					 and numprdret = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	elsif p_codalw = 'RET_ABSENT' then
				update tlateabs
					 set yreretabs = 0, mthretabs = 0, prdretabs = 0,
							 coduser	 = para_coduser
				 where yreretabs = r_tpaysum.dteyrepay
					 and mthretabs = r_tpaysum.dtemthpay
					 and prdretabs = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	elsif p_codalw = 'RET_EARLY' then
				update tlateabs
					 set yreretear = 0, mthretear = 0, prdretear = 0,
							 coduser	 = para_coduser
				 where yreretear = r_tpaysum.dteyrepay
					 and mthretear = r_tpaysum.dtemthpay
					 and prdretear = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid;
	  	elsif p_codalw = 'RET_LATE' then
				update tlateabs
					 set yreretlate = 0, mthretlate = 0, prdretlate = 0,
							 coduser	  = para_coduser
				 where yreretlate = r_tpaysum.dteyrepay
					 and mthretlate = r_tpaysum.dtemthpay
					 and prdretlate = r_tpaysum.numperiod
					 and codempid   = r_tpaysum.codempid;
	  	elsif p_codalw = 'RET_LEAVE' then
				update tleavetr a
					 set dteyreret = 0,
					     dtemthret = 0,
					     numprdret = 0
				 where dteyreret = r_tpaysum.dteyrepay
					 and dtemthret = r_tpaysum.dtemthpay
					 and numprdret = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid
           and exists (select typleave
					               from tleavety b
					              where a.typleave = b.typleave
					                and flgtype  <> 'M');
	  	elsif p_codalw = 'RET_LEAVEM' then
				update tleavetr a
					 set dteyreret = 0,
					     dtemthret = 0,
					     numprdret = 0
				 where dteyreret = r_tpaysum.dteyrepay
					 and dtemthret = r_tpaysum.dtemthpay
					 and numprdret = r_tpaysum.numperiod
					 and codempid  = r_tpaysum.codempid
           and exists (select typleave
					               from tleavety b
					              where a.typleave = b.typleave
					                and flgtype  = 'M');
	  	end if;
	  end loop;
	 	commit;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure del_tpaysum(p_codempid  varchar2,
												p_codalw 	  varchar2,
											  p_codpay  	varchar2) is
	cursor c_tpaysum is
		select rowid,codpay
		  from tpaysum
		 where dteyrepay = para_dteyrepay
		   and dtemthpay = para_dtemthpay
		   and numperiod = para_numperiod
			 and codempid  = p_codempid
			 and codalw		 = p_codalw
 			 and codpay		 = nvl(p_codpay,codpay)
			 and flgtran	 = 'N';
	begin
		for r_tpaysum in c_tpaysum loop
			delete tpaysum2
			 where dteyrepay = para_dteyrepay
			   and dtemthpay = para_dtemthpay
			   and numperiod = para_numperiod
				 and codempid  = p_codempid
				 and codalw		 = p_codalw
				 and codpay		 = r_tpaysum.codpay;

			delete tpaysum
			 where rowid     = r_tpaysum.rowid;
		end loop;
		commit;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure upd_tpaysum(p_codempid  varchar2,
											  p_codalw 	  varchar2,
												p_codpay    varchar2,
												p_codcomp   varchar2,
												p_codpos	  varchar2,
												p_typpayroll varchar2,
												p_amtothr		number,
												p_amtday		number,
												p_qtyday 		number,
												p_qtymin 		number,
												p_amtpay 		number) is

		v_exist		boolean := false;
		v_amtpay	number := 0;

		cursor c_tpaysum is
			select rowid,codempid,amtpay
			  from tpaysum
			 where dteyrepay = para_dteyrepay
			   and dtemthpay = para_dtemthpay
			   and numperiod = para_numperiod
			   and codempid  = p_codempid
			   and codalw		 = p_codalw
			   and codpay		 = p_codpay;
	begin
		for r_tpaysum in c_tpaysum loop
			v_exist := true;
			v_amtpay := nvl(stddec(r_tpaysum.amtpay,r_tpaysum.codempid,para_chken),0) + p_amtpay;
			update tpaysum
				 set codcomp		 = p_codcomp,
						 codpos 		 = p_codpos,
						 typpayroll  = p_typpayroll,
						 amtothr		 = stdenc(round(p_amtothr,4),codempid,para_chken),
 						 amtday	 	   = stdenc(round(p_amtday,4),codempid,para_chken),
						 qtyday   	 = qtyday + p_qtyday,
						 qtymin   	 = qtymin + p_qtymin,
						 amtpay   	 = stdenc(round(v_amtpay,4),codempid,para_chken),
 						 coduser	   = para_coduser
			 where rowid = r_tpaysum.rowid;
		end loop;
		if not v_exist then
			insert into tpaysum(dteyrepay,dtemthpay,numperiod,codempid,codalw,codpay,
				 									codcomp,codpos,typpayroll,amtothr,amtday,qtyday,qtymin,amtpay,flgtran,codcreate,coduser)
								   values(para_dteyrepay,para_dtemthpay,para_numperiod,p_codempid,p_codalw,p_codpay,
			 	 									p_codcomp,p_codpos,p_typpayroll,stdenc(round(p_amtothr,4),p_codempid,para_chken),stdenc(round(p_amtday,4),p_codempid,para_chken),p_qtyday,p_qtymin,stdenc(round(p_amtpay,4),p_codempid,para_chken),'N',para_coduser,para_coduser);-- user22 : 15/02/2018 : STA4600006 || p_codcomp,p_codpos,p_typpayroll,stdenc(round(p_amtothr,2),p_codempid,para_chken),stdenc(round(p_amtday,2),p_codempid,para_chken),p_qtyday,p_qtymin,stdenc(round(p_amtpay,2),p_codempid,para_chken),'N',para_coduser);
		end if;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure upd_tpaysum2(p_codempid  	varchar2,
						   p_codalw 	  varchar2,
						   p_codpay    	varchar2,
						   p_codcomp   varchar2,
						   p_codpos	  varchar2,
						   p_typpayroll varchar2,
						   p_dtework 		date,
						   p_codshift 	varchar2,
						   p_timstrt 		varchar2,
						   p_timend 		varchar2,
						   p_qtymin 	  number,
						   p_amtpay 	  number,
						   p_amtothr	  number,
						   p_amtday		  number) is

		v_exist			boolean := false;
		v_amtpay		number;
		v_codcompw	tcenter.codcomp%type;

		cursor c_tpaysum2 is
			select rowid,codempid,amtpay
			  from tpaysum2
			 where dteyrepay = para_dteyrepay
			   and dtemthpay = para_dtemthpay
			   and numperiod = para_numperiod
			   and codempid  = p_codempid
			   and codalw	 = p_codalw
			   and codpay	 = p_codpay
			   and dtework	 = p_dtework
			   and codshift	 = p_codshift
--
			   and codcomp	 = p_codcomp
			   and typpayroll = p_typpayroll;

	begin
		if p_qtymin > 0 or p_codalw in ('PAY_OTHER') then
			if p_codalw in ('OT','RET_OT') then
				begin
					select nvl(codcompw,codcomp) into v_codcompw
					  from tovrtime
					 where codempid = p_codempid
				       and dtework  = p_dtework
					   and typot    = p_codshift;--Case OT p_codshift = typot
				exception when no_data_found then	null;
				end;
			else
				begin
					select nvl(codcompw,codcomp) into v_codcompw
					  from v_tattence_cc
					 where codempid = p_codempid
				     and dtework  = p_dtework;
				exception when no_data_found then	null;
				end;
			end if;
			for r_tpaysum2 in c_tpaysum2 loop
				v_exist  := true;
				v_amtpay := nvl(stddec(r_tpaysum2.amtpay,r_tpaysum2.codempid,para_chken),0) + p_amtpay;
				update tpaysum2
					 set timstrt  = p_timstrt,
						 timend	  = p_timend,
						 qtymin   = qtymin + p_qtymin,
						 amtpay   = stdenc(round(v_amtpay,4),codempid,para_chken),
						 amtothr  = stdenc(round(p_amtothr,4),codempid,para_chken),
						 amtday	  = stdenc(round(p_amtday,4),codempid,para_chken),
						 codcompw = v_codcompw,
						 coduser  = para_coduser,
                         codcomp  = p_codcomp,
                         codpos	  = p_codpos,
                         typpayroll = p_typpayroll
				 where rowid    = r_tpaysum2.rowid;
			end loop;
			if not v_exist then
				insert into tpaysum2(dteyrepay,dtemthpay,numperiod,codempid,codalw,codpay,
                                     dtework,codcompw,codshift,timstrt,timend,qtymin,amtpay,amtothr,amtday,codcreate,coduser,
                                     codcomp,codpos,typpayroll )
                              values(para_dteyrepay,para_dtemthpay,para_numperiod,p_codempid,p_codalw,p_codpay,
                                     p_dtework,v_codcompw,p_codshift,p_timstrt,p_timend,p_qtymin,stdenc(round(p_amtpay,4),p_codempid,para_chken),stdenc(round(p_amtothr,4),p_codempid,para_chken),stdenc(round(p_amtday,4),p_codempid,para_chken),para_coduser,para_coduser,
                                     p_codcomp,p_codpos,p_typpayroll );
			end if;
		 	para_numrec := nvl(para_numrec,0) + 1;
		end if;
	end;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure upd_tpaysumd(p_codempid  	varchar2,
												 p_codcompw		varchar2,
												 p_rtesmot  	number,
												 p_qtymot	  	number,
												 p_amtottot  	number) is

		v_exist			boolean := false;
		v_amtottot	number  := 0;

	cursor c_tpaysumd is
		select rowid,codempid,amtottot
		  from tpaysumd
		 where dteyrepay = para_dteyrepay
		   and dtemthpay = para_dtemthpay
		   and numperiod = para_numperiod
		   and codempid  = p_codempid
		   and rtesmot	 = p_rtesmot
		   and codcompw  = p_codcompw;
	begin
		for r_tpaysumd in c_tpaysumd loop
			v_exist := true;
			v_amtottot := nvl(stddec(r_tpaysumd.amtottot,r_tpaysumd.codempid,para_chken),0) + p_amtottot;
			update tpaysumd
				 set qtymot   = qtymot + p_qtymot,
				 		 amtottot = stdenc(round(v_amtottot,4),codempid,para_chken),
						 coduser  = para_coduser
			 where rowid    = r_tpaysumd.rowid;
		end loop;
		if not v_exist then
			insert into tpaysumd(dteyrepay,dtemthpay,numperiod,codempid,rtesmot,codcompw,
				 									 qtymot,amtottot,codcreate,coduser)
										values(para_dteyrepay,para_dtemthpay,para_numperiod,p_codempid,p_rtesmot,p_codcompw,
										       p_qtymot,stdenc(round(p_amtottot,4),p_codempid,para_chken),para_coduser,para_coduser);
		end if;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	function check_dteempmt(p_dtework 	date) return boolean is
	begin
	  if p_dtework < para_dteempmt then
	  	return(false);
	  elsif p_dtework >= para_dteeffex then
	  	return(false);
	  else
	  	return(true);
	  end if;
  end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	function check_period_time(p_dtestrt 	date,
	                           p_dteend 	date,
	                           p_timestrt varchar2,
	                           p_timeend  varchar2) return boolean is
		v_date   		date := p_dtestrt;
		v_datest1		date;
		v_datest2		date;
		v_datest3		date;
		v_dateen1		date;
		v_dateen2		date;
		v_dateen3		date;
		v_dtedupst	date;
		v_dtedupen	date;
		v_mindup1   number := 0;
		v_mindup2   number := 0;
		v_minute		number := to_date(to_char(sysdate,'dd/mm/yyyy')||'0801','dd/mm/yyyyhh24mi') - to_date(to_char(sysdate,'dd/mm/yyyy')||'0800','dd/mm/yyyyhh24mi');--1 Minute
		begin
      if p_dtestrt is null or p_dteend is null or p_timestrt is null or p_timeend is null then
        return(false);
      end if;
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
					v_dtedupst := least(v_date,nvl(v_dtedupst,v_date));
					v_dtedupen := greatest(v_date,nvl(v_dtedupen,v_date));
				end if;
				v_date := v_date + v_minute;-- +1 Minute

				if v_date > p_dteend then
          v_mindup1 := round((v_dtedupen - v_dtedupst) * 1440);
					exit;
				end if;
			end loop;
	    --
	    v_dtedupst := null;
	    v_dtedupen := null;
	    v_date  := p_dtestrt;
	    loop
				if v_date between v_datest2 and v_dateen2 then
					v_dtedupst := least(v_date,nvl(v_dtedupst,v_date));
					v_dtedupen := greatest(v_date,nvl(v_dtedupen,v_date));
				end if;
				v_date := v_date + v_minute;-- +1 Minute
				if v_date > p_dteend then
					v_mindup1 := nvl(v_mindup1,0) + nvl(round((v_dtedupen - v_dtedupst) * 1440),0);
					exit;
				end if;
			end loop;
	    --
	    v_dtedupst := null;
	    v_dtedupen := null;
	    v_date  := p_dtestrt;
	    loop
				if v_date between v_datest3 and v_dateen3 then
					v_dtedupst := least(v_date,nvl(v_dtedupst,v_date));
					v_dtedupen := greatest(v_date,nvl(v_dtedupen,v_date));
				end if;
				v_date := v_date + v_minute;-- +1 Minute
				if v_date > p_dteend then
					v_mindup1 := nvl(v_mindup1,0) + nvl(round((v_dtedupen - v_dtedupst) * 1440),0);
					exit;
				end if;
			end loop;
	    --

			v_mindup2 := round((v_dateen2 - v_datest2) * 1440);
			if v_mindup1 >= v_mindup2 then
				return(true);
			else
				return(false);
			end if;
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	function cal_formula(p_codempid 	varchar2,
	                     p_formula	  varchar2,
	                     p_dtework 	  date) return number is
		v_first				boolean := true;
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

		v_stmt			varchar2(1000);
		v_length		number;
    v_digitst   number;
    v_digiten   number;
		v_amtpay		number := 0;
		v_codpay		tinexinf.codpay%type;
		v_dtework   date := p_dtework;

		type char2 is table of tcontpms.codincom1%type index by binary_integer;
		  	v_codincom	char2;
		type number1 is table of number index by binary_integer;
				v_amtincom	 number1;

	begin
	  for i in 1..10 loop
	  	v_codincom(i) := null;
	  	v_amtincom(i) := null;
	  end loop;
    --
		std_al.get_movemt(p_codempid,v_dtework,'C','U',
										  v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
										  v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
										  v_amthour,v_amtday,v_amtmth);
		v_dtework := p_dtework;
		std_al.get_movemt2(p_codempid,v_dtework,'C','U',
					             v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
											 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
											 v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
		--
		begin
			select codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10
	   	      into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
	 		  from tcontpms
			 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and dteeffec = (select max(dteeffec)
                                 from tcontpms
						        where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                  and dteeffec <= trunc(sysdate));
		exception when no_data_found then	return(v_amtpay);
		end;
    --
		if p_formula is not null then
      v_length  := length(p_formula);
			v_stmt    := p_formula;
      for i in 1..v_length loop
				if substr(v_stmt,i,2) = '{&' then
          v_digitst := instr(v_stmt,'{&',1);
          v_digiten := instr(v_stmt,'}',v_digitst);
					v_codpay  := substr(v_stmt,v_digitst+2,v_digiten-v_digitst-2);
					v_amtpay  := 0;
					for j in 1..10 loop
					  if v_codpay = v_codincom(j) then
					  	 v_amtpay := v_amtincom(j) ;
					  	 exit ;
					  end if;
					end loop ;
					v_stmt   := replace(v_stmt,'{&'||v_codpay||'}',v_amtpay);
				end if;
			end loop;
			/*v_length  := length(p_formula);
			v_stmt    := p_formula;
			for i in 1..v_length loop
				if substr(v_stmt,i,1) = '&' then
					v_codpay := substr(v_stmt,i + 1,2);
					v_amtpay := 0 ;
					for j in 1..10 loop
					  if v_codpay = v_codincom(j) then
					  	 v_amtpay := v_amtincom(j) ;
					  	 exit ;
					  end if;
					end loop ;
					v_stmt   := replace(v_stmt,substr(v_stmt,instr(v_stmt,'&'),3),v_amtpay);
				end if;
			end loop;*/
			--
			if v_stmt like '%{[AMTHRS]}%' then
				v_stmt := replace(v_stmt,'{[AMTHRS]}',v_amthour);
			end if;
			if v_stmt like '%{[AMTDAY]}%' then
				v_stmt := replace(v_stmt,'{[AMTDAY]}',v_amtday);
			end if;
			if v_stmt like '%{[AMTMTH]}%' then
				v_stmt := replace(v_stmt,'{[AMTMTH]}',v_amtmth);
			end if;
		  v_amtpay := execute_sql('select '||v_stmt||' from dual');
		else
		  v_amtpay := 0;
		end if;--p_formula is not null
		return(v_amtpay);
	end;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	procedure get_time(p_codempid 	varchar2,
		 								 p_dtework		date,
										 p_timin	    out varchar2,
										 p_timout	    out varchar2) is
	begin
		p_timin := null; p_timout := null;
        begin
          select timin,timout into p_timin,p_timout
          from 	 tattence
          where  codempid = p_codempid
          and	 dtework  = p_dtework;
        exception when no_data_found then null;
        end;
	end;
end HRAL71B_BATCH;

/
