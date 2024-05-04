--------------------------------------------------------
--  DDL for Package Body HRAL56B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL56B_BATCH" is
	procedure start_process is
		v_coduser   temploy1.coduser%type := 'AUTOBATCH';
		v_msgerror  varchar2(4000) := null;
		v_status    varchar2(1) := 'C';
		v_numrec    number;
		v_sysdate   date := sysdate;
	begin
	  insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
	                values('HRAL56B',v_sysdate,v_sysdate,null,null,null,'AUTOBATCH');
	  --
		begin
		  --cal_process (null,'%',null,sysdate,v_coduser,v_numrec);
      gen_leave_cancel(null,'%',sysdate,sysdate,v_coduser,v_numrec);
      gen_leave(null,'%',sysdate,sysdate,v_coduser,v_numrec);

		exception  when others then
		  rollback;
		  v_status   := 'E';
		end;
		--
		if v_status = 'C' then
			v_msgerror := 'Complete ';
		else
			v_msgerror := 'Error ';
		end if;
		--
	  update tautolog
	     set status   = v_status,
	         dteproen = sysdate,
	         remark   = v_msgerror
	   where codapp   = 'HRAL56B'

	     and dtecall  = v_sysdate;
	  commit;
	end;
  --
  procedure gen_leave_Cancel(p_codempid	in	varchar2,
                             p_codcomp	in	varchar2,
                             p_stdate		in	date,
                             p_endate		in	date,
                             p_coduser	in	varchar2,
                             p_numrec		out number) is
    v_secur       boolean;
    v_first		  	boolean;
    v_zupdsal     varchar2(4 char);
    v_count       number;
    t_numrec      number;
    v_flgcanc			tleavecc.flgcanc%type;
    v_numlereq    tleavetr.numlereq%type;
    v_codempid    tleavetr.codempid%type;
    v_codleave    tleavetr.codleave%type;
    v_yrecycle    tleavsum.dteyear%type;
    v_dtecycst    tleavsum.dtecycst%type;
    v_dtecycen    tleavsum.dtecycen%type;
    v_qtytleav    number;

    cursor c_tleavecc is
      select rowid,numlereq,codempid,codleave,dtestrt,dteend,desreq--,codcomp,dtestrt,dteend,numlereq
        from tleavecc
       where codempid = nvl(p_codempid,codempid)
         and codcomp  like p_codcomp||'%'
         and (p_coduser <> 'AUTOBATCH'
              and (dtestrt  between p_stdate and p_endate
                or dteend   between p_stdate and p_endate
                or p_stdate between dtestrt and dteend
                or p_endate between dtestrt and dteend)
           or p_coduser = 'AUTOBATCH')
         and staappr  = 'Y'
         and flgcanc  = 'N'
    order by numlereq;

		cursor c_tleavetr is
			select rowid,codempid,dtework,codleave,qtymin,qtyday,codcomp
 			  from tleavetr
			 where numlereq = v_numlereq
    order by dtework;

		cursor c_tleavsum is
			select rowid,codempid,dteyear,codleave
 			  from tleavsum
			 where codempid = v_codempid
			   and dteyear  = v_yrecycle
			   and codleave = v_codleave;
	begin
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    for r1 in c_tleavecc loop
      if p_coduser <> 'AUTOBATCH' then
        v_secur := secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          goto main_loop;
        end if;
      end if;
      --
      v_flgcanc  := 'Y';
      begin
        select count(codempid) into v_count
          from tleavetr
         where numlereq = r1.numlereq
           and qtylvded > 0;
      end;
      if v_count > 0 then
        v_flgcanc  := 'E';
        goto next_proc;
      end if;
      --
      v_numlereq := r1.numlereq;
      v_codempid := r1.codempid;
      v_codleave := r1.codleave;
      v_first	:= true;
      for r2 in c_tleavetr loop
        std_al.cycle_leave(hcm_util.get_codcomp_level(r2.codcomp,1),r2.codempid,r2.codleave,r2.dtework,v_yrecycle,v_dtecycst,v_dtecycen);
        v_qtytleav := 0;
        if v_first then
          v_first := false;
          v_qtytleav := 1;
        end if;
        for r_tleavsum in c_tleavsum loop
          update tleavsum
             set qtyshrle  = greatest(qtyshrle - (r2.qtymin / 60),0),
                 qtydayle  = greatest(qtydayle - r2.qtyday,0),
                 qtytleav  = greatest(qtytleav - v_qtytleav,0),
                 coduser   = p_coduser
           where rowid = r_tleavsum.rowid;
        end loop;
        --
        delete tleavetr where rowid = r2.rowid;
        --
        std_al.cal_tattence(r1.codempid,r2.dtework,r2.dtework,p_coduser,t_numrec);
      end loop; -- c_tleavetr loop

      delete tlereqd where numlereq = r1.numlereq;

      update tlereqst
         set stalereq = 'C',
             dtecancl = dtestrt,
             deslereq = r1.desreq
       where numlereq = r1.numlereq;
      upd_tleavsum(r1.codempid,r1.dteend,r1.codleave,p_coduser);
      --
      <<next_proc>> null;
      begin
        update tleavecc
           set flgcanc = v_flgcanc,
               coduser = p_coduser
         where rowid   = r1.rowid;
      end;
      p_numrec := nvl(p_numrec,0) + 1;
      <<main_loop>> null;
    end loop; -- c_tleavecc loop
    commit;
  end;
  --
  procedure gen_leave(p_codempid	in	varchar2,
                      p_codcomp		in	varchar2,
                      p_stdate		in	date,
                      p_endate		in	date,
                      p_coduser	  in	varchar2,
                      p_numrec		out number) is

    v_secur       boolean;
    v_zupdsal     varchar2(4 char);
    t_numrec      number;
    v_dtecal      date;
    v_dtecalstr   date;
    v_dtecalend   date;
    v_numlereq    tleavetr.numlereq%type;
    v_stacallv    tlereqd.stacallv%type;
    v_typleave		tleavecd.typleave%type;
    v_staleave		tleavecd.staleave%type;
    --v_flgdlemx		tleavety.flgdlemx%type;
    v_flgchol			tleavety.flgchol%type;
    v_count       number;
    rt_tattence   tattence%rowtype;
    v_numlvl      temploy1.numlvl%type;
    v_dtestrt     tlereqst.dtestrt%type;
    v_timstrt     tlereqst.timstrt%type;
    v_dteend      tlereqst.dteend%type;
    v_timend      tlereqst.timend%type;
		v_timstrtw		tlereqst.timend%type;
		v_timendw			tlereqst.timend%type;
		v_timstrtb		tlereqst.timend%type;
		v_timendb			tlereqst.timend%type;
		v_dtelest 		tlereqd.dtework%type;
		v_timlest 		tlereqd.timstrt%type;
		v_dteleen 		tlereqd.dtework%type;
		v_timleen 		tlereqd.timend%type;
    v_strtw 	  	tlereqd.dtework%type;
    v_endle   		tlereqd.dtework%type;
    v_qtydaywk    tshiftcd.qtydaywk%type;
    v_qtymin      tleavetr.qtymin%type;
    v_qtyday      tleavetr.qtyday%type;
    v_codempid    tleavetr.codempid%type;
    x_strtle      tleavetr.dtework%type;
    x_endle       tleavetr.dtework%type;
    x_strt        tleavetr.dtework%type;
    x_end         tleavetr.dtework%type;
    v_yrecycle		number;
    v_dtecycst		date;
    v_dtecycen		date;
    v_dtelastle   date;
    v_qtytleav    number;
    v_sysdate     date := trunc(sysdate);
    t_stdate   		date;
    t_endate  		date;
    t_count       number;
    v_codleave    varchar2(20 char);
    v_cnt     		number;
    v_dayeupd     date;

    cursor c_tlereqst is
			select rowid,numlereq,codempid,codleave,dteleave,dtestrt,timstrt,dteend,timend,dtecancl,flgleave,dteprgntst,deslereq
			  from tlereqst
       where codempid = nvl(p_codempid,codempid)
         and codcomp  like p_codcomp||'%'
--<< user22 : ST11 : 17/01/2022 ||
	       and((p_coduser   = 'AUTOBATCH' and exists (select tlereqd.numlereq
                                                      from tlereqd
                                                     where tlereqst.numlereq  = tlereqd.numlereq
                                                       and tlereqd.dayeupd   is null
                                                       and tlereqd.dtework   <= to_date('31/12/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy')))
	        or (p_coduser  <> 'AUTOBATCH' and(dtestrt    between p_stdate and p_endate
                                         or nvl(dtecancl,dteend) between p_stdate and p_endate
                                         or p_stdate   between dtestrt and nvl(dtecancl,dteend)
                                         or p_endate   between dtestrt and nvl(dtecancl,dteend))
                                         ))
-->> user22 : ST11 : 17/01/2022 ||
--<< user22 : ST11 : 02/11/2021 ||
	       /*and((p_coduser   = 'AUTOBATCH' and dtecreate  between (v_sysdate - 1) and v_sysdate)
	        or (p_coduser  <> 'AUTOBATCH' and(dtestrt    between p_stdate and p_endate
                                         or nvl(dtecancl,dteend) between p_stdate and p_endate
                                         or p_stdate   between dtestrt and nvl(dtecancl,dteend)
                                         or p_endate   between dtestrt and nvl(dtecancl,dteend))
                                         ))*/
-->> user22 : ST11 : 02/11/2021 ||
    order by numlereq;

		cursor c_tleavetr is
			select codempid,dtework,codleave,timstrt,timend,qtyday,qtymin,numlereq,rowid
			  from tleavetr
			 where codempid = v_codempid
			   and dtework  = v_dtecal;

		cursor c_tleavsum is
			select codempid,dteyear,codleave,rowid
			  from tleavsum
			 where codempid = v_codempid
			   and dteyear  = v_yrecycle
			   and codleave = v_codleave;
  begin
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    for r1 in c_tlereqst loop
      v_codempid := r1.codempid;
      if p_coduser <> 'AUTOBATCH' then
        v_secur := secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          goto main_loop;
        end if;
      end if;
      --
      begin
        select typleave,staleave
          into v_typleave,v_staleave
          from tleavecd
         where codleave = r1.codleave;
      exception when no_data_found then null;
      end;
      begin
        select flgchol
          into v_flgchol
          from tleavety
         where typleave = v_typleave;
      exception when no_data_found then null;
      end;
--<< user22 : ST11 : 17/01/2022 ||
      if p_coduser   = 'AUTOBATCH' then
        t_stdate := null; t_endate := null;
        begin
          select min(dtework),max(dtework)
            into t_stdate,t_endate
            from tlereqd
           where numlereq = r1.numlereq
             and dayeupd  is null
             and dtework  <= to_date('31/12/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
        end;
        if t_stdate is null then
          goto main_loop;
        end if;
        --
        v_dtecalstr := t_stdate;
        v_dtecalend := t_endate;
        if r1.dtecancl is not null then
          v_dtecalstr := least(t_stdate,(r1.dtecancl-1));
          v_dtecalend := least(t_endate,(r1.dtecancl-1));
        end if;
-->> user22 : ST11 : 17/01/2022 ||
      else
        v_dtecalstr := greatest(p_stdate,r1.dteleave);
        v_dtecalend := least(p_endate,nvl((r1.dtecancl-1),r1.dteend));
      end if;

      if v_dtecalstr > v_dtecalend then
        goto main_loop;
      end if;
      v_dtestrt := r1.dtestrt;
      v_timstrt := r1.timstrt;
      v_dteend  := r1.dteend;
      v_timend  := r1.timend;
      if r1.flgleave in ('M','E') then
        begin
          select timstrtw,timendw,timstrtb,timendb
            into v_timstrtw,v_timendw,v_timstrtb,v_timendb
            from tshiftcd
           where codshift = (select codshift
				                      from tattence
												     where codempid	=	r1.codempid
												       and dtework 	=	r1.dteleave);
        exception when no_data_found then null;
        end;
        if r1.flgleave = 'M' then
          v_timstrt := v_timstrtw;
          v_timend  := nvl(v_timstrtb,v_timendw);
        elsif r1.flgleave = 'E' then
          v_timstrt := nvl(v_timendb,v_timstrtw);
          v_timend  := v_timendw;
        end if;
        if v_timstrt < v_timstrtw then
          v_dtestrt	:=	r1.dteleave + 1;
          v_dteend	:=	r1.dteleave + 1;
        else
          v_dtestrt	:=	r1.dteleave;
          if v_timstrt > v_timend then
            v_dteend	:=	r1.dteleave + 1;
          else
            v_dteend	:=	r1.dteleave;
          end if;
        end if;
      end if;--r1.flgleave in ('M','E')
      --
      v_dtecal   := v_dtecalstr;
      <<cal_loop>> loop
        v_qtymin := 0; -- user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
        v_qtyday := 0; -- user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||

        v_stacallv := 'U';
--<< user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
        v_dayeupd := null;
        begin
          select dayeupd
            into v_dayeupd
            from tlereqd
           where numlereq = r1.numlereq
             and dtework  = v_dtecal;

          if p_coduser  = 'AUTOBATCH' and v_dayeupd is not null then
            goto next_proc2;
          end if;
        exception when no_data_found then
          goto next_proc2;
        end;
-->> user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
        begin
          select *
            into rt_tattence
            from tattence
           where codempid = r1.codempid
             and dtework  = v_dtecal;
        exception when no_data_found then null;
        end;
        v_numlereq := null;
        begin
          select numlereq into v_numlereq
            from tleavetr
           where codempid = r1.codempid
             and dtework  = v_dtecal
             and codleave = r1.codleave
             and qtylvded > 0
             and rownum   = 1;
        exception when no_data_found then null;
        end;
        if v_numlereq is not null then
          if v_numlereq <> r1.numlereq then
            v_stacallv  := 'E';
          end if;
          goto next_proc;
        end if;
        --
        del_tleavetr(r1.codempid,v_dtecal,r1.codleave,p_coduser);
        if v_flgchol = 'Y' and rt_tattence.typwork in ('H','S','T') then
          delete tlereqd where numlereq = r1.numlereq and dtework = v_dtecal;
          goto next_proc;
        end if;
        /*else
          begin
            select count(*) into v_count from tlereqd where numlereq = r1.numlereq and dtework = v_dtecal;
          end;
          if v_count = 0 then
            begin
              select numlvl into v_numlvl
                from temploy1
               where codempid = r1.codempid;
            exception when no_data_found then null;
            end;

            insert into tlereqd(numlereq,dtework,codleave,
                                codempid,codcomp,numlvl,stacallv,dtecreate,codcreate,dteupd,coduser)
                         values(r1.numlereq,v_dtecal,r1.codleave,
                                r1.codempid,rt_tattence.codcomp,v_numlvl,'P',sysdate,p_coduser,sysdate,p_coduser);
          end if;
        end if;*/

        --
        if v_dtecal = r1.dteleave and v_timstrt is not null then -- user22 : 14/09/2021 : #6900 || if v_dtecal = v_dtestrt and v_timstrt is not null then
          v_dtelest := v_dtestrt;
          v_timlest := v_timstrt;
        else
          v_dtelest := rt_tattence.dtestrtw;
          v_timlest := rt_tattence.timstrtw;
        end if;
        if v_timend is not null then
          v_strtw  := to_date(to_char(rt_tattence.dtestrtw,'dd/mm/yyyy')||rt_tattence.timstrtw,'dd/mm/yyyyhh24mi');
          v_endle  := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
          If v_strtw >= v_endle Then
            goto next_proc;-- go to ????
          end if;
        end if;
        if rt_tattence.dteendw >= v_dteend and v_timend is not null then
          v_dteleen := v_dteend;
          v_timleen := v_timend;
        else
          v_dteleen := rt_tattence.dteendw;
          v_timleen := rt_tattence.timendw;
        end if;

        begin
          select qtydaywk
            into v_qtydaywk
            from tshiftcd
           where codshift = rt_tattence.codshift;
        exception when no_data_found then null;
        end;
        --<< user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 || v_qtymin := 0;
        --<< user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 || v_qtyday := 0;

        cal_time_leave(v_flgchol,rt_tattence.codcomp,rt_tattence.codcalen,rt_tattence.typwork,rt_tattence.codshift,
                       rt_tattence.dtestrtw,rt_tattence.timstrtw,rt_tattence.dteendw,rt_tattence.timendw,
                       v_dtelest,v_timlest,v_dteleen,v_timleen,
                       v_qtymin,v_qtyday,v_qtydaywk,r1.flgleave);
        if nvl(v_qtyday,0) = 0 then
          v_stacallv  := 'E';
          goto next_proc;
        end if;
        --
        x_strtle := to_date(to_char(v_dtelest,'dd/mm/yyyy')||v_timlest,'dd/mm/yyyyhh24mi');
        if v_timlest < v_timleen then
          x_endle := to_date(to_char(v_dteleen,'dd/mm/yyyy')||v_timleen,'dd/mm/yyyyhh24mi');
        else
          x_endle := to_date(to_char(v_dteleen + 1,'dd/mm/yyyy')||v_timleen,'dd/mm/yyyyhh24mi');
        end if;
        --
        for r_dup in c_tleavetr loop
          x_strt := to_date(to_char(r_dup.dtework,'dd/mm/yyyy')||r_dup.timstrt,'dd/mm/yyyyhh24mi');
          if r_dup.timstrt < r_dup.timend then
            x_end := to_date(to_char(r_dup.dtework,'dd/mm/yyyy')||r_dup.timend,'dd/mm/yyyyhh24mi');
          else
            x_end := to_date(to_char(r_dup.dtework + 1,'dd/mm/yyyy')||r_dup.timend,'dd/mm/yyyyhh24mi');
          end if;

          if ((x_strt = x_strtle	and x_end  = x_endle) or
              (x_strt > x_strtle	and x_strt < x_endle) or
              (x_end  > x_strtle	and x_end  < x_endle) or
              (x_strtle > x_strt	and x_strtle < x_end) or
              (x_endle  > x_strt	and x_endle  < x_end)) then
--<< user22 : 20/01/2022 : ST11 ||
            begin
              select count(codempid) into v_cnt
                from tleavetr
               where codempid = r_dup.codempid
                 and numlereq = r_dup.numlereq
                 and dtework <> v_dtecal;
            end;
            if nvl(v_cnt,0) > 0 then
              v_qtytleav := 0;
            else
              v_qtytleav := 1;
            end if;
            std_al.cycle_leave(hcm_util.get_codcomp_level(rt_tattence.codcomp,1),r1.codempid,r1.codleave,v_dtecal,v_yrecycle,v_dtecycst,v_dtecycen);
            v_codleave := r_dup.codleave;-- user22 : 22/03/2024 : ST11 (KOHU #1802) || v_codleave := r1.codleave;
            for r_tleavsum in c_tleavsum loop
              update tleavsum
                 set qtyshrle  = greatest(qtyshrle - (r_dup.qtymin / 60),0),
                     qtydayle  = greatest(qtydayle - r_dup.qtyday,0),
                     qtytleav  = greatest(qtytleav - v_qtytleav,0)
               where rowid     = r_tleavsum.rowid;
            end loop;
            delete tleavetr where rowid = r_dup.rowid;
-->> user22 : 20/01/2022 : ST11 ||
          end if;
        end loop;
        --
        if v_qtyday > 0 then
          begin
            insert into tleavetr(codempid,dtework,codleave,
                                 typleave,staleave,codcomp,typpayroll,codshift,flgatten,timstrt,timend,qtymin,qtyday,numlereq,deslereq,dteprgntst,dtecreate,codcreate,dteupd,coduser)
                          values(r1.codempid,v_dtecal,r1.codleave,
                                 v_typleave,v_staleave,rt_tattence.codcomp,rt_tattence.typpayroll,rt_tattence.codshift,rt_tattence.flgatten,v_timlest,v_timleen,v_qtymin,v_qtyday,r1.numlereq,r1.deslereq,r1.dteprgntst,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            update tleavetr
               set typleave   = v_typleave,
                   staleave   = v_staleave,
                   codcomp    = rt_tattence.codcomp,
                   typpayroll = rt_tattence.typpayroll,
                   codshift   = rt_tattence.codshift,
                   flgatten   = rt_tattence.flgatten,
                   timstrt    = v_timlest,
                   timend     = v_timleen,
                   qtymin     = v_qtymin,
                   qtyday     = v_qtyday,
                   numlereq   = r1.numlereq,
                   deslereq   = r1.deslereq,
                   dteprgntst = r1.dteprgntst,
                   dteupd     = sysdate,
                   coduser    = p_coduser
             where codempid = r1.codempid
               and dtework  = v_dtecal
               and codleave = r1.codleave;
          end;
          --
          std_al.cycle_leave(hcm_util.get_codcomp_level(rt_tattence.codcomp,1),r1.codempid,r1.codleave,v_dtecal,v_yrecycle,v_dtecycst,v_dtecycen);
          begin
            select count(codempid) into v_count
              from tleavetr
             where codempid = r1.codempid
               and numlereq = r1.numlereq
               and dtework <> v_dtecal;
          end;
          if nvl(v_count,0) > 0 then
            v_qtytleav := 0;
          else
            v_qtytleav := 1;
          end if;
          v_dtelastle := null;
          begin
            select max(dtework) into v_dtelastle
              from tleavetr
             where codempid = r1.codempid
               and codleave = r1.codleave
               and dtework   between v_dtecycst and v_dtecycen;
          end;
          begin
            insert into tleavsum(codempid,dteyear,codleave,
                                 typleave,staleave,codcomp,typpayroll,qtyshrle,qtydayle,qtytleav,dtelastle,dtecycst,dtecycen,dtecreate,codcreate,dteupd,coduser)
                          values(r1.codempid,v_yrecycle,r1.codleave,
                                 v_typleave,v_staleave,rt_tattence.codcomp,rt_tattence.typpayroll,
                                 (v_qtymin / 60),nvl(v_qtyday,0),v_qtytleav,v_dtelastle,v_dtecycst,v_dtecycen,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            update tleavsum
               set qtyshrle   = nvl(qtyshrle,0) + (v_qtymin / 60),
                   qtydayle   = nvl(qtydayle,0) + nvl(v_qtyday,0),
                   qtytleav   = nvl(qtytleav,0) + v_qtytleav,-- user22 : 22/03/2024 : ST11 (KOHU #1802) || qtytleav   = v_qtytleav,
                   dtelastle  = v_dtelastle,
                   dtecycst   = v_dtecycst,
                   dtecycen   = v_dtecycen,
                   dteupd     = sysdate,
                   coduser    = p_coduser
             where codempid = r1.codempid
               and dteyear  = v_yrecycle
               and codleave = r1.codleave;
          end;
          p_numrec := nvl(p_numrec,0) + 1;
        end if;
        --
        <<next_proc>> null;
         if v_qtymin > 0 then -- user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
          update tlereqd
             set stacallv = v_stacallv,
                 timstrt  = nvl(v_timlest,timstrt),
                 timend   = nvl(v_timleen,timend),
                 qtymin   = nvl(v_qtymin,qtymin),
                 qtyday   = nvl(v_qtyday,qtyday),
                 dayeupd  = greatest(p_endate,trunc(sysdate)),
                 coduser  = p_coduser
           where numlereq = r1.numlereq
             and dtework  = v_dtecal
             and codleave = r1.codleave;
          std_al.cal_tattence(r1.codempid,v_dtecal,v_dtecal,p_coduser,t_numrec);
--<< user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
        else
          delete tlereqd
           where numlereq = r1.numlereq
             and dtework  = v_dtecal
             and codleave = r1.codleave;
        end if;
-->> user22 : 08/02/2023 : https://hrmsd.peopleplus.co.th:4449/redmine/issues/743 ||
        --
        <<next_proc2>> null;-- user22 : ST11 : 17/01/2022 ||
        v_dtecal := v_dtecal + 1;
        if (v_dtecal > v_dtecalend) then
          exit cal_loop;
        end if;
      end loop;	-- cal_loop
      --
      update tlereqst
         set dayeupd  = greatest(p_endate,trunc(sysdate)),
             coduser  = p_coduser
       where rowid    = r1.rowid;

      if r1.flgleave in ('M','E') then       
        update tlereqst
           set timstrt  = nvl(v_timlest,timstrt),
               timend   = nvl(v_timleen,timend)
         where rowid    = r1.rowid;      
      end if;

      upd_tleavsum(r1.codempid,v_dtecalend,r1.codleave,p_coduser);
      <<main_loop>> null;
    end loop; -- c_tlereqst loop
    commit;
  end;
  --
	procedure upd_tleavsum(p_codempid 	in varchar2,
                         p_dtework		in date,
                         p_codleave		in varchar2,
                         p_coduser		in varchar2) is

		v_codcomp   temploy1.codcomp%type;
		v_typleave	tleavecd.typleave%type;
		v_staleave	tleavecd.staleave%type;
		v_yrecycle	number := 0;
		v_dtecycst	tleavsum.dtecycst%type;
		v_dtecycen	tleavsum.dtecycen%type;

		v_dtemax    date;
		v_qtytleav  number := 0;
		v_qtymin    number := 0;
		v_qtyday    number := 0;

		v_flgdlemx	  tleavety.flgdlemx%type;
    v_flgchkprgnt tleavety.flgchkprgnt%type;
		v_qtydlepay number := 0;
		t_qtydlepay number := 0;
		v_qtydlemx  number := null;
		t_qtydlemx  number := 0;
		s_qtydaymx  number := 0;
		v_qtyprimx  number := 0;

		cursor c1_tleavetr is
			select dteprgntst,sum(qtyday) qtyday
			  from tleavetr
			 where codempid = p_codempid
			   and codleave = p_codleave
			   and dtework  between v_dtecycst and v_dtecycen
		group by dteprgntst;

		cursor c2_tleavetr is
			select numlereq,sum(qtyday) qtyday
			  from tleavetr
			 where codempid = p_codempid
			   and codleave = p_codleave
			   and dtework  between v_dtecycst and v_dtecycen
		group by numlereq;
	begin
	  begin
	  	select staleave,typleave
	      into v_staleave,v_typleave
	      from tleavecd
	     where codleave = p_codleave;
	  exception when no_data_found then null;
	  end;
		begin
			select flgdlemx,nvl(qtydlepay,0),flgchkprgnt
			  into v_flgdlemx,v_qtydlepay,v_flgchkprgnt
			  from tleavety
		   where typleave = v_typleave;
		exception when no_data_found then null;
		end;

    if v_flgdlemx = 'Y' or v_flgchkprgnt = 'Y' then
      begin
        select codcomp
          into v_codcomp
          from tattence
         where codempid = p_codempid
           and dtework  = p_dtework;
      exception when no_data_found then	null;
      end;
      std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,p_codleave,p_dtework,v_yrecycle,v_dtecycst,v_dtecycen);
      if v_flgchkprgnt = 'Y' then
        begin
          select max(dtework)
            into v_dtemax
            from tleavetr
           where codempid = p_codempid
             and codleave = p_codleave
             and dtework  between v_dtecycst and v_dtecycen;
        end;
        begin
          select count(distinct(a.numlereq))
            into v_qtytleav
            from tleavetr a
           where a.codempid = p_codempid
             and a.codleave = p_codleave
             and a.dtework  between v_dtecycst and v_dtecycen
             and not exists (select b.dtework
                               from tleavetr b
                              where a.codempid   = b.codempid
                                and a.codleave   = b.codleave
                                and a.dteprgntst = b.dteprgntst
                                and b.dtework <= (v_dtecycst - 1));
        end;

        for r1 in c1_tleavetr loop
          t_qtydlepay := v_qtydlepay;
          t_qtydlemx  := 0;
          s_qtydaymx  := 0;
          begin
            select sum(qtyday)
              into s_qtydaymx
              from tleavetr
             where codempid   = p_codempid
               and codleave   = p_codleave
               and dteprgntst = r1.dteprgntst
               and dtework <= (v_dtecycst - 1);
          end;
          t_qtydlepay := greatest(0,(t_qtydlepay - nvl(s_qtydaymx,0)));
          if r1.qtyday >= t_qtydlepay then
            t_qtydlemx := t_qtydlepay;
          else
            t_qtydlemx := r1.qtyday;
          end if;
          if s_qtydaymx > 0 then
            v_qtyprimx := t_qtydlemx;
          end if;
          v_qtydlemx := nvl(v_qtydlemx,0) + t_qtydlemx;
        end loop;
      elsif v_flgdlemx = 'Y' then
        begin
          select max(dtework)
            into v_dtemax
            from tleavetr
           where codempid = p_codempid
             and codleave = p_codleave
             and dtework  between v_dtecycst and v_dtecycen;
        end;
        begin
          select count(distinct(a.numlereq))
            into v_qtytleav
            from tleavetr a
           where a.codempid = p_codempid
             and a.codleave = p_codleave
             and a.dtework  between v_dtecycst and v_dtecycen
             and not exists (select b.dtework
                               from tleavetr b
                              where a.numlereq = b.numlereq
                                and b.dtework <= (v_dtecycst - 1));
        end;

        for r1 in c2_tleavetr loop
          t_qtydlepay := v_qtydlepay;
          t_qtydlemx  := 0;
          s_qtydaymx  := 0;
          begin
            select sum(qtyday)
              into s_qtydaymx
              from tleavetr
             where numlereq = r1.numlereq
               and dtework <= (v_dtecycst - 1);
          end;
          t_qtydlepay := greatest(0,(t_qtydlepay - nvl(s_qtydaymx,0)));
          if r1.qtyday >= t_qtydlepay then
            t_qtydlemx := t_qtydlepay;
          else
            t_qtydlemx := r1.qtyday;
          end if;
          if s_qtydaymx > 0 then
            v_qtyprimx := t_qtydlemx;
          end if;
          v_qtydlemx := nvl(v_qtydlemx,0) + t_qtydlemx;
        end loop;
      end if;--  v_flgchkprgnt = 'Y'
      --
      update tleavsum
        set qtytleav  = nvl(v_qtytleav,0),
            dtelastle = v_dtemax,
            qtyprimx  = v_qtyprimx,
            qtydlemx  = nvl(v_qtydlemx,qtydlemx),
            dtecycst  = v_dtecycst,
            dtecycen  = v_dtecycen,
            coduser   = p_coduser
      where codempid  = p_codempid
        and dteyear   = v_yrecycle
        and codleave  = p_codleave;
    end if; -- v_flgdlemx = 'Y' or v_flgchkprgnt = 'Y'
  end;
	--
	procedure del_tleavetr(p_codempid 	in varchar2,
                         p_dtework		in date,
                         p_codleave		in varchar2,
                         p_coduser		in varchar2) is

    v_yrecycle    tleavsum.dteyear%type;
    v_dtecycst    tleavsum.dtecycst%type;
    v_dtecycen    tleavsum.dtecycen%type;
    v_cnt         number;-- user22 : 22/03/2024 : ST11 (KOHU #1802) || 
    v_qtytleav    number;-- user22 : 22/03/2024 : ST11 (KOHU #1802) || 

		cursor c_tleavetr is
			select rowid,codempid,dtework,codleave,qtymin,qtyday,codcomp,
             numlereq-- user22 : 22/03/2024 : ST11 (KOHU #1802) || 
			  from tleavetr
			 where codempid = p_codempid
			   and dtework  = p_dtework
			   and codleave = p_codleave
			   --and numlereq = p_numlereq
			   and nvl(qtylvded,0) = 0;

		cursor c_tleavsum is
			select rowid,codempid,dteyear,codleave
			  from tleavsum
			 where codempid = p_codempid
			   and dteyear  = v_yrecycle
			   and codleave = p_codleave;
	begin
		for r1 in c_tleavetr loop
--<< user22 : 22/03/2024 : ST11 (KOHU #1802) ||   
      begin
        select count(codempid) into v_cnt
          from tleavetr
         where codempid = p_codempid
           and numlereq = r1.numlereq
           and dtework <> p_dtework;
      end;
      if nvl(v_cnt,0) > 0 then
        v_qtytleav := 0;
      else
        v_qtytleav := 1;
      end if;
-->> user22 : 22/03/2024 : ST11 (KOHU #1802) || 

      std_al.cycle_leave(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,r1.codleave,r1.dtework,v_yrecycle,v_dtecycst,v_dtecycen);
			for r_tleavsum in c_tleavsum loop
				update tleavsum
					 set qtyshrle  = greatest(qtyshrle - (r1.qtymin / 60),0),
						   qtydayle  = greatest(qtydayle - r1.qtyday,0),
               qtytleav  = greatest(qtytleav - v_qtytleav,0),-- user22 : 22/03/2024 : ST11 (KOHU #1802) || 
							 coduser   = p_coduser
				 where rowid     = r_tleavsum.rowid;
			end loop;
			--
			delete tleavetr where rowid = r1.rowid;
      upd_tleavsum(r1.codempid,r1.dtework,r1.codleave,p_coduser);
		end loop;
	end;
	--

  procedure cal_time_leave(p_flgchol    in tleavety.flgchol%type,
                           p_codcomp    in temploy1.codcomp%type,
                           p_codcalen   in tattence.codcalen%type,
                           p_typwork    in tattence.typwork%type,
                           p_codshift   in tattence.codshift%type,
                           p_dtestrtw   in tattence.dtestrtw%type,
                           p_timstrtw   in tattence.timstrtw%type,
                           p_dteendw    in tattence.dteendw%type,
                           p_timendw    in tattence.timendw%type,
                           p_dtestrtle  in tlereqst.dtestrt%type,
                           p_timstrtle  in out tlereqst.timstrt%type,
                           p_dteendle   in tlereqst.dtestrt%type,
                           p_timendle   in out tlereqst.timstrt%type,
                           p_qtymin     out tleavetr.qtymin%type,
                           p_qtyday     out tleavetr.qtyday%type,
                           p_qtyavgwk   in number,
                           p_flgleave   in varchar2)is --p_flgleave A = Full Shift, M = First Shift, E = Half Shift, H = Free Time
		v_strtw       date;
		v_endw        date;
		v_strtle      date;
		v_endle       date;
		v_strtb       date;
		v_endb        date;
		v_timstrtb    tshiftcd.timstrtb%type;
		v_timendb     tshiftcd.timendb%type;
		v_timbrk      number;
	begin
		<< cal_leave >> loop
			p_qtymin := 0; p_qtyday := 0;
			begin
				select timstrtb,timendb
				  into v_timstrtb,v_timendb
					from tshiftcd
				 where codshift = p_codshift;
			exception when no_data_found then exit cal_leave;
			end;

			if p_flgchol = 'N' or (p_flgchol = 'Y' and p_typwork not in ('H','S','T')) then
				v_strtw  := to_date(to_char(p_dtestrtw,'dd/mm/yyyy')||p_timstrtw,'dd/mm/yyyyhh24mi');
				v_endw   := to_date(to_char(p_dteendw,'dd/mm/yyyy')||p_timendw,'dd/mm/yyyyhh24mi');
				v_strtle := to_date(to_char(p_dtestrtle,'dd/mm/yyyy')||p_timstrtle,'dd/mm/yyyyhh24mi');
				v_endle  := to_date(to_char(p_dteendle,'dd/mm/yyyy')||p_timendle,'dd/mm/yyyyhh24mi');
				v_timbrk := 0;

				if v_timstrtb is not null and v_timendb is not null then
					if p_timstrtw < v_timstrtb then
						v_strtb := to_date(to_char(p_dtestrtw,'dd/mm/yyyy')||v_timstrtb,'dd/mm/yyyyhh24mi');
					else
						v_strtb := to_date(to_char(p_dtestrtw + 1,'dd/mm/yyyy')||v_timstrtb,'dd/mm/yyyyhh24mi');
					end if;
					if v_timstrtb <= v_timendb    then
						v_endb := to_date(to_char(v_strtb,'dd/mm/yyyy')||v_timendb,'dd/mm/yyyyhh24mi');
					else
						v_endb := to_date(to_char(v_strtb + 1,'dd/mm/yyyy')||v_timendb,'dd/mm/yyyyhh24mi');
					end if;
					v_timbrk := round((v_endb - v_strtb) * 1440,0);
				end if;

				if v_strtle < v_strtw then
					v_strtle := v_strtw;
				elsif v_strtle < v_strtb then
					v_strtle := v_strtle;
				elsif v_strtle < v_endb then
					v_strtle := v_endb;
					v_timbrk := 0;
				elsif v_strtle < v_endw then
					v_strtle := v_strtle;
					v_timbrk := 0;
				else
          exit cal_leave;
				end if;

				if v_endle > v_endw then
					v_endle  := v_endw;
				elsif v_endle > v_endb then
					v_endle  := v_endle;
				elsif v_endle > v_strtb then
					v_endle  := v_strtb;
					v_timbrk := 0;
				elsif v_endle > v_strtw then
					v_endle  := v_endle;
					v_timbrk := 0;
				else
					exit cal_leave;
				end if;

				p_timstrtle := to_char(v_strtle,'hh24mi');
				p_timendle  := to_char(v_endle,'hh24mi');
				if p_flgleave = 'A' then
					p_qtymin := p_qtyavgwk;
					p_qtyday := 1;
--<< user22 : 19/04/2024 : KOHU Red mine 1913 ||   
        else
          p_qtymin := round((abs(v_endle - v_strtle) * 1440) - v_timbrk,0);
          if p_qtymin > p_qtyavgwk then
              p_qtymin := p_qtyavgwk;
          end if;
          p_qtyday := p_qtymin / p_qtyavgwk;         
				/*elsif p_flgleave in ('M','E') then
					p_qtymin := p_qtyavgwk/2;
					p_qtyday := 0.5;
				else
          if v_strtle = v_strtw and v_endle = v_endw then
              p_qtymin := p_qtyavgwk;
              p_qtyday := 1;
          --<< user22 : 08/03/2023 : ST11 ||
          elsif (v_strtle = v_strtw and v_endle = v_strtb) or
              (v_strtle = v_endb  and v_endle = v_endw) then
              p_qtymin := p_qtyavgwk/2;
              p_qtyday := 0.5;
          -->> user22 : 08/03/2023 : ST11 ||
          else
              p_qtymin := round((abs(v_endle - v_strtle) * 1440) - v_timbrk,0);
              if p_qtymin > p_qtyavgwk then
                  p_qtymin := p_qtyavgwk;
              end if;
              p_qtyday := p_qtymin / p_qtyavgwk;
          end if;*/
-->> user22 : 19/04/2024 : KOHU Red mine 1913 ||        
				end if;
			end if; -- p_flgchol
			exit cal_leave;
		end loop; -- cal_leave loop
	end;
	--
	procedure gen_entitlement(p_codempid   in varchar2,
                            p_numlereq   in varchar2,
                            p_dayeupd    in date,
                            p_flgleave   in varchar2,
                            p_codleave   in varchar2,
                            p_dteleave   in date,
                            p_dtestrt    in date,
                            p_timstrt    in varchar2,
                            p_dteend     date,
                            p_timend     in varchar2,
                            p_dteprgntst in date,
                            p_v_zyear    in number,
                            p_coduser    in varchar2,
	                          p_coderr     out varchar2,
                            p_qtyday1    out number, -- day entitle
                            p_qtyday2    out number, -- day leave
                            p_qtyday3    out number, -- day leave req (AL + ESS)
                            p_qtyday4    out number, -- balance
                            p_qtyday5    out number, -- day leave pay
                            p_qtyday6    out number, -- day leave not pay
                            p_qtyday7    out number, -- time leave
                            p_qtyday8    out number, -- time leave req (AL + ESS)
                            p_qtyavgwk   out number) is

		v_code				varchar2(100);
		v_codcomp 		temploy1.codcomp%type;
		v_staleave		tleavecd.staleave%type;
		v_typleave		tleavety.typleave%type;
		v_flgchol			tleavety.flgchol%type;
		v_flgwkcal		tleavety.flgwkcal%type;
		v_flgdlemx    tleavety.flgdlemx%type;
	  v_qtydlepery	tleavety.qtydlepery%type;
	  v_flgtimle  	tleavety.flgtimle%type;
	  v_qtytimle  	tleavety.qtytimle%type;
	  v_qtyminle  	tleavety.qtytimle%type;
    v_flgchkprgnt tleavety.flgchkprgnt%type;
    v_flgleave    tleavecd.flgleave%type;
    v_qtyminunit	tleavecd.qtyminunit%type;

		v_yearst			number(4);
		v_yearen			number(4);
		v_qtypriyr    number;
	  v_dteeffec    date;
		v_yrecycle		number;
		v_dtecycst		date;
		v_dtecycen		date;
		v_dtework			tattence.dtework%type;
		v_sumday			number;
		v_summin			number;
		v_strtw 			date;
		v_endle 			date;
		v_sumlevmx    number;
    v_time        date;
    v_dtestrt2    date;
    v_dteend2     date;
    v_timstrt     varchar2(40);
    v_timend      varchar2(40);
    v_qtydayAL		number;
    v_qtydayES		number;
    v_qtytimAL		number;
    v_qtytimES		number;
    v_coderr      varchar2(100);
    v_flgfound    boolean;
	cursor c_tleaverq is
		select flgleave,codleave,dteleave,dtestrt,timstrt,dteend,timend
      from tleaverq
	   where codempid = p_codempid
		   and codleave in (select codleave
                          from tleavecd
                         where typleave = v_typleave)
       and ((v_flgtimle = 'Y' and(dteleave   between v_dtecycst and v_dtecycen
                               or dteend     between v_dtecycst and v_dtecycen
                               or v_dtecycst between dteleave   and dteend
                               or v_dtecycen between dteleave   and dteend))
				or v_flgtimle = 'A')
       and staappr  in ('P','A')
    order by dtereq,seqno;

	begin
		p_coderr	:= null;
		p_qtyday1 := 0;
		p_qtyday2 := 0;
		p_qtyday3 := 0;
		p_qtyday4 := 0;
		p_qtyday5 := 0;
		p_qtyday6 := 0;
    p_qtyday7 := 0;
    p_qtyday8 := 0;
		--

		<<main_loop>>
		loop
			if p_codempid is null or p_codleave is null then
				exit main_loop;
			end if;

			begin
				select codcomp into v_codcomp
				  from temploy1
				 where codempid = p_codempid;
			exception when no_data_found then exit main_loop;
			end;
			begin
        select to_date(to_char(dtestrtw,'dd/mm/yyyy')||' '||timstrtw,'dd/mm/yyyy hh24:mi'),
               to_date(to_char(dteendw,'dd/mm/yyyy')||' '||timendw,'dd/mm/yyyy hh24:mi')
          into v_dtestrt2,v_dteend2
				  from tattence
				 where codempid = p_codempid
				   and dtework  = p_dteleave;
			exception when no_data_found then
				p_coderr := 'AL0020';
				exit main_loop;
			end;


      if p_flgleave = 'H' and p_dtestrt is not null then
        v_time := to_date(to_char(p_dtestrt,'dd/mm/yyyy')||' '||substr(p_timstrt,1,2)||':'||substr(p_timstrt,3,2),'dd/mm/yyyy hh24:mi');
        if v_time not between v_dtestrt2 and v_dteend2 then
          p_coderr := 'AL0067';
          exit main_loop;
        end if;
      end if;

			begin
				select typleave,staleave,qtyminle,qtyminunit,flgleave
				  into v_typleave,v_staleave,v_qtyminle,v_qtyminunit,v_flgleave
				  from tleavecd
				 where codleave = p_codleave;
			exception when no_data_found then
				exit main_loop;
			end;

			begin
				select flgdlemx,flgchol,nvl(qtydlepery,0),qtytimle,flgtimle,flgchkprgnt
				  into v_flgdlemx,v_flgchol,v_qtydlepery,v_qtytimle,v_flgtimle,v_flgchkprgnt
				  from tleavety
				 where typleave = v_typleave;
			exception when no_data_found then
				exit main_loop;
			end;

      --
			std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,p_codleave,p_dteleave,v_yrecycle,v_dtecycst,v_dtecycen);
      if v_flgdlemx = 'N' and p_dteend not between v_dtecycst and v_dtecycen then
         p_coderr := 'AL0051';
        exit main_loop;
      end if;

      --
      v_flgfound := check_condition_leave(p_codempid,p_codleave,p_dteleave,'1');
      if not v_flgfound then
        p_coderr := 'AL0028';
        exit main_loop;
      end if;
			--

      std_al.entitlement(p_codempid,p_codleave,p_dteend,p_v_zyear,p_qtyday1,v_qtypriyr,v_dteeffec,p_coduser); -- user22 : 08/12/2021 : ST11 || std_al.entitlement(p_codempid,p_codleave,p_dteend,p_v_zyear,p_qtyday1,v_qtypriyr,v_dteeffec);--p_dteleave
      if v_staleave = 'V' and p_dteleave < v_dteeffec then
        p_coderr := 'AL0028';
        exit main_loop;
      end if;

      -- p_qtyday1 (day entitle)
	    p_qtyday1 := nvl(p_qtyday1,0) ;

      -- p_qtyday2 (day leave), p_qtyday7 (time leave)
      if v_flgchkprgnt = 'Y' then
				begin
          select nvl(sum(qtyday),0),nvl(count(distinct(numlereq)),0)
            into p_qtyday2, p_qtyday7
            from tleavetr
           where codempid    = p_codempid
             and dteprgntst  = p_dteprgntst
             and codleave    in (select codleave
                                   from tleavecd
                                  where typleave = v_typleave)
             and((p_numlereq is not null and nvl(numlereq,'!@#$%') <> p_numlereq)
             or  p_numlereq is null);
				exception when no_data_found then
					p_qtyday2 := 0;
          p_qtyday7 := 0;
				end;
      else -- v_flgchkprgnt <> 'Y'
        if v_flgdlemx = 'Y' then
          p_qtyday2 := 0;
        else
          begin
            select nvl(sum(qtyday),0)
              into p_qtyday2
              from tleavetr
             where codempid = p_codempid
               and dtework  between v_dtecycst and v_dtecycen
               and codleave in (select codleave
                                  from tleavecd
                                 where typleave = v_typleave)
               and((p_numlereq is not null and nvl(numlereq,'!@#$%') <> p_numlereq)
                or  p_numlereq is null);
          exception when no_data_found then
            p_qtyday2 := 0;
          end;
        end if;
        --
        begin
          select nvl(count(distinct(numlereq)),0)
            into p_qtyday7
            from tleavetr
           where codempid     = p_codempid
             and ((v_flgtimle = 'Y' and dtework between v_dtecycst and v_dtecycen) or v_flgtimle = 'A')
             and codleave    in (select codleave
                                   from tleavecd
                                  where typleave = v_typleave)
            and((p_numlereq is not null and nvl(numlereq,'!@#$%') <> p_numlereq)
             or  p_numlereq is null);
        exception when no_data_found then
          p_qtyday7 := 0;
        end;
      end if; -- v_flgchkprgnt = 'Y'


      -- p_qtyday3 (day leave req), p_qtyday8 (time leave req)
      v_qtydayAL := 0; v_qtydayES := 0;
      v_qtytimAL := 0; v_qtytimES := 0;

      if v_flgchkprgnt = 'Y' then
        -- AL
        begin
          select nvl(sum(b.qtyday),0),nvl(count(distinct(b.numlereq)),0)
            into v_qtydayAL, v_qtytimAL
            from tlereqst a, tlereqd b
           where a.numlereq   = b.numlereq
             and b.codempid   = p_codempid
             and a.dteprgntst = p_dteprgntst
             and b.codleave   in (select codleave
                                    from tleavecd
                                   where typleave = v_typleave)
             and((p_numlereq is not null and nvl(b.numlereq,'!@#$%') <> p_numlereq)
              or  p_numlereq is null)
             and b.dayeupd   is null
             --<<user36 ST11 17/12/2021
             and b.numlereq = (select max(numlereq) from tlereqd c
                                where c.codempid = b.codempid
                                  and c.dtework  = b.dtework
                                  and c.codleave = b.codleave)
             -->>user36 ST11 17/12/2021
             ;
        exception when no_data_found then
          v_qtydayAL := 0; v_qtytimAL := 0;
        end;

        -- ESS
        begin
          select nvl(sum(qtyday),0),nvl(count(codempid),0)
            into v_qtydayES, v_qtytimES
            from tleaverq a
           where codempid   = p_codempid
             and dteprgntst = p_dteprgntst
             and codleave   in (select codleave
                                  from tleavecd
                                 where typleave = v_typleave)
             and staappr in ('P','A')
             --<<user36 ST11 20/12/2021
             and not exists (select codempid from tleavecc b
                             where a.codempid = b.codempid
                             and a.dtereq = b.dtereqr
                             and a.seqno  = b.seqnor
                             and staappr in ('A','Y'))
             -->>user36 ST11 20/12/2021
             ;
        exception when no_data_found then
          v_qtydayES := 0; v_qtytimES := 0;
        end;
      else -- v_flgchkprgnt <> 'Y'
        -- v_qtydayAL, v_qtydayES
        if v_flgdlemx = 'Y' then
          v_qtydayAL := 0;
          v_qtydayES := 0;
        else
          -- AL
          begin
            select nvl(sum(b.qtyday),0)
              into v_qtydayAL
              from tlereqst a, tlereqd b
             where a.numlereq   = b.numlereq
               and b.codempid   = p_codempid
               and b.dtework    between v_dtecycst and v_dtecycen
               and b.codleave   in (select codleave
                                      from tleavecd
                                     where typleave = v_typleave)
               and((p_numlereq is not null and nvl(b.numlereq,'!@#$%') <> p_numlereq)
                or  p_numlereq is null)
               and b.dayeupd   is null
               --<<user36 ST11 17/12/2021
               and b.numlereq = (select max(numlereq) from tlereqd c
                                  where c.codempid = b.codempid
                                    and c.dtework  = b.dtework
                                    and c.codleave = b.codleave)
               -->>user36 ST11 17/12/2021
               ;
          exception when no_data_found then
            v_qtydayAL := 0;
          end;

          -- ESS
          begin
            select nvl(sum(qtyday),0)
              into v_qtydayES
              from tleaverq a
             where codempid   = p_codempid
               and dtestrt    between v_dtecycst and v_dtecycen
               and codleave   in (select codleave
                                    from tleavecd
                                   where typleave = v_typleave)
               and staappr in ('P','A')
               --<<user36 ST11 20/12/2021
               and not exists (select codempid from tleavecc b
                               where a.codempid = b.codempid
                               and a.dtereq = b.dtereqr
                               and a.seqno  = b.seqnor
                               and staappr in ('A','Y'))
               -->>user36 ST11 20/12/2021
               ;
          exception when no_data_found then
            v_qtydayES := 0;
          end;
        end if;
        -- v_qtytimAL, v_qtytimES
          -- AL
          begin
            select nvl(count(distinct(b.numlereq)),0)
              into v_qtytimAL
              from tlereqst a, tlereqd b
             where a.numlereq   = b.numlereq
               and b.codempid   = p_codempid
               and ((v_flgtimle = 'Y' and b.dtework between v_dtecycst and v_dtecycen) or v_flgtimle = 'A')
               and b.codleave   in (select codleave
                                      from tleavecd
                                     where typleave = v_typleave)
               and((p_numlereq is not null and nvl(b.numlereq,'!@#$%') <> p_numlereq)
                or  p_numlereq is null)
               and b.dayeupd   is null
               --<<user36 ST11 17/12/2021
               and b.numlereq = (select max(numlereq) from tlereqd c
                                  where c.codempid = b.codempid
                                    and c.dtework  = b.dtework
                                    and c.codleave = b.codleave)
               -->>user36 ST11 17/12/2021
               ;
          exception when no_data_found then
            v_qtytimAL := 0;
          end;


          -- ESS
          begin
            select nvl(count(codempid),0)
              into v_qtytimES
              from tleaverq a
             where codempid   = p_codempid
               and ((v_flgtimle = 'Y' and dtestrt between v_dtecycst and v_dtecycen) or v_flgtimle = 'A')
               and codleave   in (select codleave
                                    from tleavecd
                                   where typleave = v_typleave)
               and staappr in ('P','A')
               --<<user36 ST11 20/12/2021
               and not exists (select codempid from tleavecc b
                               where a.codempid = b.codempid
                               and a.dtereq = b.dtereqr
                               and a.seqno  = b.seqnor
                               and staappr in ('A','Y'))
               -->>user36 ST11 20/12/2021
               ;
          exception when no_data_found then
            v_qtytimES := 0;
          end;
      end if; -- v_flgchkprgnt = 'Y'
      p_qtyday3 := nvl(v_qtydayAL,0) + nvl(v_qtydayES,0);
      p_qtyday8 := nvl(v_qtytimAL,0) + nvl(v_qtytimES,0);
      -- p_qtyday4 (balance)
      p_qtyday4 := greatest(nvl(p_qtyday1,0) - (nvl(p_qtyday2,0) + nvl(p_qtyday3,0)),0);


      v_timstrt := p_timstrt;
      v_timend  := p_timend;
      v_coderr := null;
			gen_min_req(false,null,p_codempid,p_flgleave,p_codleave,p_dteleave,p_dtestrt,v_timstrt,p_dteend,v_timend,p_coduser,
	                v_summin,v_sumday,p_qtyavgwk,v_coderr);

			if v_coderr is not null then
	    	p_qtyday1 := 0;
	    	p_qtyday2 := 0;
	    	p_qtyday3 := 0;
	    	p_qtyday4 := 0;
	    	p_qtyday5 := 0;
	    	p_qtyday6 := 0;
        p_qtyday7 := 0;
        p_qtyday8 := 0;
				exit main_loop;
			end if;

      -- p_qtyday5 (day leave pay), p_qtyday6 (day leave not pay)
      p_qtyday5 := v_sumday;
			if v_sumday > p_qtyday4 then
				p_qtyday5 := p_qtyday4;
				p_qtyday6 := v_sumday - p_qtyday4;
			else
				p_qtyday5 := v_sumday;
				p_qtyday6 := 0;
			end if;
/*
	    --flgdlemx [Y = Per Time, N = Per Year]
			if v_flgdlemx = 'Y' then
	    	p_qtyday2 := 0;
	    	p_qtyday3 := 0;
			else
				begin
				 select nvl(sum(qtyday),0)
					 into p_qtyday2
					 from tleavetr
					where codempid = p_codempid
	 				  and dtework  between v_dtecycst and v_dtecycen
					  and codleave in (select codleave
					                     from tleavecd
					                    where typleave = v_typleave)
					  and((p_numlereq is not null and nvl(numlereq,'!@#$%') <> p_numlereq)
					   or  p_numlereq is null);
				exception when no_data_found then
					p_qtyday2 := 0;
				end;

				--AL
				begin
					select nvl(sum(qtyday),0)	into v_qtydayAL3
					  from tlereqd
					 where codempid = p_codempid
					   and dtework  between v_dtecycst and v_dtecycen
					   and codleave in (select codleave
					                      from tleavecd
					                     where typleave = v_typleave)
					   and ((p_numlereq is not null and numlereq <> p_numlereq)
					    or p_numlereq is null)
					   and dayeupd is null;
				exception when no_data_found then
					v_qtydayAL3 := 0;
				end;
			end if;

			--ESS
			v_qtydayES3 := 0;
			p_qtytimrq  := 0;
			for r1 in c_tleaverq loop
				para_dtestrt:= null;
	      v_timstrt   := r1.timstrt;
	      v_timend    := r1.timend;

				gen_min_req(false,null,p_codempid,r1.flgleave,r1.codleave,r1.dteleave,r1.dtestrt,v_timstrt,r1.dteend,v_timend,p_coduser,
		                v_summin,v_sumday,p_qtyavgwk,v_coderr);--v_coderr not use this process
		    --
		    if v_sumday > 0 then
		      if v_flgdlemx = 'N' and r1.dteleave between v_dtecycst and v_dtecycen then
		    		v_qtydayES3 := v_qtydayES3 + v_sumday;
		    	end if;
			    if ((v_flgtimle = 'Y' and para_dtestrt between v_dtecycst and v_dtecycen) or v_flgtimle = 'A') then
		    		p_qtytimrq  := p_qtytimrq + 1;
		    	end if;
				end if;--v_sumday > 0
		  end loop; -- c_tleaverq
			--
			p_qtyday3 := nvl(v_qtydayAL3,0) + nvl(v_qtydayES3,0);
			--
			p_qtyday4 := greatest(nvl(p_qtyday1,0) - (nvl(p_qtyday2,0) + nvl(p_qtyday3,0)),0);
      v_timstrt := p_timstrt;
      v_timend  := p_timend;

      v_coderr := null;
			gen_min_req(false,null,p_codempid,p_flgleave,p_codleave,p_dteleave,p_dtestrt,v_timstrt,p_dteend,v_timend,p_coduser,
	                v_summin,v_sumday,p_qtyavgwk,v_coderr);
			if v_coderr is not null then
	    	p_qtyday1 := 0;
	    	p_qtyday2 := 0;
	    	p_qtyday3 := 0;
	    	p_qtyday4 := 0;
	    	p_qtyday5 := 0;
	    	p_qtyday6 := 0;
				exit main_loop;
			end if;
			--
      p_qtyday5 := v_sumday;
			if v_sumday > p_qtyday4 then
				p_qtyday5 := p_qtyday4;
				p_qtyday6 := v_sumday - p_qtyday4;
			else
				p_qtyday5 := v_sumday;
				p_qtyday6 := 0;
			end if;

			--
			p_qtytimle:= 0;
			begin
			 select nvl(count(distinct(numlereq)),0)
				 into p_qtytimle
				 from tleavetr
				where codempid = p_codempid
				  and ((v_flgtimle = 'Y' and dtework between v_dtecycst and v_dtecycen)
				   or v_flgtimle = 'A')
  				and dtework  = (select min(dtework)
  				                  from tleavetr b
  				                 where tleavetr.numlereq = b.numlereq)
				  and codleave in (select codleave
				                     from tleavecd
				                    where typleave = v_typleave)
				  and((p_numlereq is not null and nvl(numlereq,'!@#$%') <> p_numlereq)
				   or  p_numlereq is null);
			exception when no_data_found then
				p_qtytimle := 0;
			end;
			--
			if nvl(p_qtytimle,0) + nvl(p_qtytimrq,0) >= v_qtytimle then
				p_coderr := 'AL0042';
				exit main_loop;
			end if;*/
			--
      if nvl(p_qtyday7,0) + nvl(p_qtyday8,0) >= v_qtytimle then
				p_coderr := 'AL0042';
				exit main_loop;
			end if;

			if (nvl(p_qtyday5,0) + nvl(p_qtyday6,0)) <= 0 then
				p_coderr := 'AL0037';
				exit main_loop;
			end if;
			if v_staleave in('V','C') then
				if (nvl(p_qtyday5,0) + nvl(p_qtyday6,0)) > p_qtyday4 then
					p_coderr := 'AL0030';
					exit main_loop;
				end if;
			else
				if (nvl(p_qtyday2,0) + nvl(p_qtyday3,0) + nvl(p_qtyday5,0) + nvl(p_qtyday6,0)) > nvl(v_qtydlepery,0) then
					p_coderr := 'AL0030';
					exit main_loop;
				end if;
			end if;
--<< user22 : 08/03/2023 : ST11 ||
			if v_flgleave = 'A' then
        if v_sumday < 1 then
          p_coderr := 'AL0050';
          exit main_loop;
        end if;
      elsif v_flgleave = 'F' then
        if v_sumday < 0.5 then
          p_coderr := 'AL0050';
          exit main_loop;
        end if;
      elsif v_flgleave = 'H' then
-->> user22 : 08/03/2023 : ST11 ||
        if v_qtyminle is not null and v_summin < v_qtyminle then
          p_coderr := 'AL0050';
          exit main_loop;
        end if;
      end if;

insert_temp2('XXX','XXX',999,v_qtyminunit,v_summin,mod(v_summin,v_qtyminunit),null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
			if v_qtyminunit is not null and mod(v_summin,v_qtyminunit) > 0 then
				p_coderr := 'AL0050';
				exit main_loop;
			end if;

      --
			if v_staleave = 'F' then
				begin
				 select codempid into v_code
					 from tleavetr
					where codempid = p_codempid
					  and codleave = p_codleave
					  and((p_numlereq is not null and nvl(numlereq,'!@#$') <> p_numlereq)
					   or  p_numlereq is null)
					  and rownum =1;

					p_coderr := 'AL0029';
					exit main_loop;
				exception when no_data_found then null;
				end;
			end if;
			--
			exit main_loop;
		end loop; -- main_loop
	end;--gen_entitlement
	--

	procedure gen_min_req(p_save         in boolean,
                        p_numlereq     in varchar2,
                        p_codempid     in varchar2,
                        p_flgleave     in varchar2,
                        p_codleave     in varchar2,
                        p_dteleave     in date,
                        p_dtestrt      in date,
                        p_timstrt      in out varchar2,
                        p_dteend       date,
                        p_timend       in out varchar2,
                        p_coduser      in varchar2,
	                      p_summin       out number,
                        p_sumday       out number,
                        p_qtyavgwk     out number,
                        p_coderr       out varchar2) is
		v_codcomp 		temploy1.codcomp%type;
		v_numlvl  		temploy1.numlvl%type;
		v_typleave		tleavety.typleave%type;
		v_flgchol			tleavety.flgchol%type;
		v_date    		date;
		v_dtework			tattence.dtework%type;
		v_dtelest 		tlereqd.dtework%type;
		v_timlest 		tlereqd.timstrt%type;
		v_dteleen 		tlereqd.dtework%type;
		v_timleen 		tlereqd.timend%type;
		v_qtymin			tlereqd.qtymin%type;
		v_qtyday			tlereqd.qtyday%type;
		v_strtw 			date;
		v_endle 			date;
		v_dtestrt			date := p_dtestrt;
		v_timstrt     varchar2(40) := p_timstrt;
		v_dteend      date := p_dteend;
		v_timend      varchar2(40) := p_timend;
		v_timstrtw		varchar2(10);
		v_timendw			varchar2(10);
		v_timstrtb		varchar2(10);
		v_timendb			varchar2(10);
    v_code        varchar2(10);

		cursor c_tattence is
			select codempid,dtework,typwork,codshift,codcomp,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw
			  from tattence
			 where codempid = p_codempid
			   and dtework  = v_dtework
		order by codempid,dtework;

	begin
		p_summin := 0;
		p_sumday := 0;
		if p_save then
			delete tlereqd where numlereq = p_numlereq;
		end if;
		--
		begin
			select codcomp,numlvl
			  into v_codcomp,v_numlvl
			  from temploy1
			 where codempid = p_codempid;
		exception when no_data_found then	null;
		end;

		begin
			select typleave
			  into v_typleave
			  from tleavecd
			 where codleave = p_codleave;
		exception when no_data_found then	null;
		end;
		begin
			select flgchol
			  into v_flgchol
			  from tleavety
			 where typleave = v_typleave;
		exception when no_data_found then	null;
		end;

		if p_flgleave in ('M','E') then
			begin
				select timstrtw,timendw,timstrtb,timendb
				  into v_timstrtw,v_timendw,v_timstrtb,v_timendb
				  from tshiftcd
				 where codshift =(select codshift
				                    from tattence
												   where codempid	=	p_codempid
												     and dtework 	=	p_dteleave);
			exception when no_data_found then null;
			end;
			if p_flgleave = 'M' then
				v_timstrt := v_timstrtw;
				v_timend  := nvl(v_timstrtb,v_timendw);
			elsif p_flgleave = 'E' then
				v_timstrt := nvl(v_timendb,v_timstrtw);
				v_timend  := v_timendw;
			end if;

			if v_timstrt < v_timstrtw then
				v_dtestrt	:=	p_dteleave + 1;
				v_dteend	:=	p_dteleave + 1;
			else
				v_dtestrt	:=	p_dteleave;
				if v_timstrt > v_timend then
					v_dteend	:=	p_dteleave + 1;
				else
					v_dteend	:=	p_dteleave;
				end if;
			end if;
		end if;--p_flgleave in ('M','E')
		--
		v_date := p_dteleave; -- user22 : 14/09/2021 : #6900 || v_date := v_dtestrt;
		if v_dtestrt <= v_dteend then
			<<cal_loop>>
			loop
				-- YESTERDAY (TATTENCE)
				/*if v_date = v_dtestrt and v_timstrt is not null then
					v_dtework := v_date - 1;
					for r_tattence in c_tattence loop
						v_dtelest := v_dtestrt;
						v_timlest := v_timstrt;
						v_dteleen := r_tattence.dteendw;

						if r_tattence.dteendw = v_dteend then
							v_timleen := nvl(v_timend,r_tattence.timendw);
						else
							v_timleen := r_tattence.timendw;
						end if;

						begin
							select qtydaywk
							  into p_qtyavgwk
							  from tshiftcd
							 where codshift = r_tattence.codshift;
						exception when no_data_found then null;
						end;

						hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
																			 	 r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw,
																			   v_dtelest,v_timlest,v_dteleen,v_timleen,
																			 	 v_qtymin,v_qtyday,p_qtyavgwk,p_flgleave);
						p_timstrt := v_timlest;
            p_timend  := v_timleen;
            if v_qtymin > 0 then
              begin
                select typleave
                  into v_code
                  from tleavcom
                 where codcompy = hcm_util.get_codcomp_level(r_tattence.codcomp,1)
                   and typleave = (select typleave from tleavecd where codleave = p_codleave);
              exception when no_data_found then
                p_coderr := 'AL0060';--AL0060 ?????????????????????????????????????
                return;
              end;
            	para_dtestrt := least(nvl(para_dtestrt,v_dtelest),v_dtelest);
							p_sumday := p_sumday + nvl(v_qtyday,0);
							p_summin := p_summin + nvl(v_qtymin,0);
							if p_save then
								begin
									insert into tlereqd(numlereq,dtework,codleave,codempid,codcomp,numlvl,timstrt,timend,qtymin,qtyday,dayeupd,stacallv,codcreate,coduser)
								               values(p_numlereq,v_dtework,p_codleave,p_codempid,v_codcomp,v_numlvl,v_timlest,v_timleen,nvl(v_qtymin,0),nvl(v_qtyday,0),null,'P',p_coduser,p_coduser);
								exception when dup_val_on_index then null;
								end;
							end if;
						end if;
					end loop; -- for r_tattence
				end if; -- v_date = v_dtestrt and v_timstrt is not null
*/
				-- TODAY (TATTENCE)
				v_dtework := v_date;
				for r_tattence in c_tattence loop

					if v_date = p_dteleave and v_timstrt is not null then-- user22 : 14/09/2021 : #6900 || if v_date = v_dtestrt and v_timstrt is not null then
						v_dtelest := v_dtestrt;
						v_timlest := v_timstrt;
					else
						v_dtelest := r_tattence.dtestrtw;
						v_timlest := r_tattence.timstrtw;
					end if;
			  	if v_timend is not null then
				  	v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
				  	v_endle  := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
		        If v_strtw >= v_endle Then
							exit cal_loop;
		        end if;
		      end if;
					if r_tattence.dteendw >= v_dteend and v_timend is not null then
						v_dteleen := v_dteend;
						v_timleen := v_timend;
					else
						v_dteleen := r_tattence.dteendw;
						v_timleen := r_tattence.timendw;
					end if;

					begin
						select qtydaywk
						  into p_qtyavgwk
						  from tshiftcd
						 where codshift = r_tattence.codshift;
					exception when no_data_found then null;
					end;
					hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
																			 r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw,
																		   v_dtelest,v_timlest,v_dteleen,v_timleen,
																			 v_qtymin,v_qtyday,p_qtyavgwk,p_flgleave);
					p_timstrt := v_timlest;
          p_timend  := v_timleen;
          if v_qtymin > 0 then
            /*begin
              select typleave
                into v_code
                from tleavcom
               where codcompy = hcm_util.get_codcomp_level(r_tattence.codcomp,1)
                 and typleave = (select typleave from tleavecd where codleave = p_codleave);
            exception when no_data_found then
              p_coderr := 'AL0060';
              return;
            end;*/
          	para_dtestrt := least(nvl(para_dtestrt,v_dtelest),v_dtelest);
						p_sumday := p_sumday + nvl(v_qtyday,0);
						p_summin := p_summin + nvl(v_qtymin,0);
						if p_save then
							begin
								insert into tlereqd(numlereq,dtework,codleave,codempid,codcomp,numlvl,timstrt,timend,qtymin,qtyday,dayeupd,stacallv,codcreate,coduser)
							               values(p_numlereq,v_dtework,p_codleave,p_codempid,v_codcomp,v_numlvl,v_timlest,v_timleen,nvl(v_qtymin,0),nvl(v_qtyday,0),null,'P',p_coduser,p_coduser);
							exception when dup_val_on_index then null;
							end;
						end if;
					end if;
				end loop; -- for r_tattence
				v_date := v_date + 1;
				if v_date > v_dteend then
					exit cal_loop;
				end if;
			end loop;	-- main_loop
		end if;-- v_dtestrt <= v_dteend
	end;-- gen_min_req
  --

  function check_condition_leave(p_codempid in varchar2,p_codleave in varchar2,p_dteeffec in date,p_flgmaster in varchar2) return boolean is--p_flgmaster = 1 = temploy1, 2 = movement
    v_dtemovemt		date;
    v_codempid		temploy1.codempid%type;
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
    v_codsex  		temploy1.codsex%type;
    v_codrelgn		temploy2.codrelgn%type;
    --
    v_dteempmt    temploy1.dteempmt%type;
    v_dteeffex    temploy1.dteeffex%type;
    v_qtywkday    temploy1.qtywkday%type;
    v_svmth       number;
    v_svyre       number;
    v_svday       number;
    v_qtyday      number;
    --
		v_amthour		 	number := 0;
		v_amtday			number := 0;
		v_amtmth			number := 0;
    --
    v_flgfound    boolean;
    v_staleave    tleavecd.staleave%type;
    v_descond     tleavecd.syncond%type;
    v_desc        tleavecd.syncond%type;
    v_stmt        varchar2(4000);
  begin
    begin
      select staleave,syncond
        into v_staleave,v_descond
        from tleavecd
       where codleave = p_codleave;
    exception when no_data_found then null;
    end;
    if v_descond is null then
      return(true);
    end if;
    --
    begin
      select a.staemp,a.codcomp,a.codpos,a.numlvl,a.codjob,a.codempmt,a.typemp,a.typpayroll,a.codbrlc,a.codcalen,a.jobgrade,a.codgrpgl,a.codsex,b.codrelgn,a.dteempmt,a.dteeffex,a.qtywkday
        into v_staemp,v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,v_codsex,v_codrelgn,v_dteempmt,v_dteeffex,v_qtywkday
        from temploy1 a, temploy2 b
       where a.codempid = b.codempid
         and a.codempid = p_codempid;
    exception when no_data_found then null;
    end;
    if p_flgmaster = '2' then
      v_dtemovemt := p_dteeffec;
      std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                        v_amthour,v_amtday,v_amtmth);
    end if;
    --
    v_dteempmt  := v_dteempmt + nvl(v_qtywkday,0);
    get_service_year(v_dteempmt,least(nvl((v_dteeffex - 1),p_dteeffec),p_dteeffec),'Y',v_svyre,v_svmth,v_svday);
    v_svmth     := v_svmth + (v_svyre * 12);
    if v_staleave = 'V' then
      begin
        select nvl(qtyday,0)
          into v_qtyday
          from tcontrlv
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrlv
                            where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= p_dteeffec);
      exception when no_data_found then v_qtyday := 0;
      end;
      if v_qtyday > 0 and v_svday > v_qtyday then
        v_svmth := v_svmth + 1;
      end if;
    end if;
    if v_descond is not null then
      v_desc := v_descond;
      v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
      v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
      v_desc := replace(v_desc,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
      v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
      v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
      v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
      v_desc := replace(v_desc,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
      v_desc := replace(v_desc,'TEMPLOY1.QTYWKDAY',v_svmth);
      v_desc := replace(v_desc,'TEMPLOY1.CODSEX',''''||v_codsex||'''');
      v_desc := replace(v_desc,'TEMPLOY2.CODRELGN',''''||v_codrelgn||'''');
      v_stmt := 'select count(*) from dual where '||v_desc;
      v_flgfound := execute_stmt(v_stmt);
      return(v_flgfound);
    end if;
    return(true);
  end;
  --
/*
	procedure cal_process
		(p_codempid		in	varchar2,
		 p_codcomp		in	varchar2,
		 p_stdate			in	date,
		 p_endate			in	date,
		 p_coduser		in	varchar2,
		 p_numrec			out number) is

		v_secur       boolean;
		v_flgsecu			boolean;
		rt_tcontral   tcontral%rowtype;
		v_codempid    temploy1.codempid%type;
		rt_tleavetr		tleavetr%rowtype;
		r_tlereqd			tlereqd%rowtype;
		v_dtework     tattence.dtework%type;
		v_qtydlepay   tleavety.qtydlepay%type;
		v_flgdlemx		tleavety.flgdlemx%type;
		v_qtydlemx		tleavety.qtydlepay%type;
		v_codleave		tleavecd.codleave%type;
		v_staleave		tleavecd.staleave%type;
		v_numlereq    tlereqst.numlereq%type;
		v_zupdsal  		varchar2(4);

		v_error				boolean;
		v_numrec			number := 0;
	  v_zminlvl  		number;
	  v_zwrklvl  		number;
		v_yrecycle		number;
		v_dtecycst		date;
		v_dtecycen		date;
		v_chkreg 			varchar2(100);
		v_zyear				number := 0;

		cursor c_tlereqd is
			select a.*
	 		  from tlereqd a, temploy1 b
			 where a.codempid = b.codempid
         and b.codempid = nvl(p_codempid,b.codempid)
			   and b.codcomp like p_codcomp||'%'
			   and ((p_coduser  = 'AUTO' and a.dtework between nvl(p_stdate,a.dtework) and nvl(p_endate,a.dtework) and a.dayeupd is null)
			    or  (p_coduser <> 'AUTO' and a.dtework between nvl(p_stdate,a.dtework) and nvl(p_endate,a.dtework)))
		order by a.numlereq,a.dtework,a.codleave;

		cursor c_tlereqst is
			select qtyday,dayeupd,rowid,qtydlemx,deslereq,dteprgntst,timprgnt
			  from tlereqst
			 where numlereq = v_numlereq;

	begin
		if p_coduser <> 'AUTO' then
			begin
	      select get_numdec(numlvlst,p_coduser) numlvlst, get_numdec(numlvlen,p_coduser) numlvlen
	        into v_zminlvl,v_zwrklvl
	        from tusrprof
				 where coduser = p_coduser;
			exception when others then null;
			end;
		end if;
		--
		begin
			select value
			  into v_chkreg
			  from v$nls_parameters
			 where parameter = 'NLS_CALENDAR';

			if v_chkreg = 'Thai Buddha' then
				v_zyear := 543;
			end if;
		exception when others then null;
		end;
		--
		gen_tlereqd(p_codempid,p_codcomp,p_stdate,p_endate,p_coduser);
		--
		p_numrec := 0;
		for r_tlereqd in c_tlereqd loop
			v_secur := secur_main.secur1(r_tlereqd.codcomp,r_tlereqd.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
			if v_secur or p_coduser = 'AUTO' then
				v_codempid := r_tlereqd.codempid;
				v_dtework  := r_tlereqd.dtework;
				v_codleave := r_tlereqd.codleave;
				v_numlereq := r_tlereqd.numlereq;
				--
			 	begin
					select *
					  into rt_tcontral
					  from tcontral
					 where codcompy = hcm_util.get_codcomp_level(r_tlereqd.codcomp,1)
					   and dteeffec = (select max(dteeffec)
														   from tcontral
												  	  where codcompy = hcm_util.get_codcomp_level(r_tlereqd.codcomp,1)
												  	    and dteeffec <= sysdate);
				exception when no_data_found then null;
				end;
				--
	      begin
	      	select staleave
	          into v_staleave
	          from tleavecd
	         where codleave = v_codleave;
	      exception when no_data_found then null;
	      end;
				std_al.cycle_leave(hcm_util.get_codcomp_level(r_tlereqd.codcomp,1),v_codempid,v_codleave,v_dtework,v_yrecycle,v_dtecycst,v_dtecycen);
				cal_leave(r_tlereqd,rt_tleavetr,v_error,p_coduser,v_zminlvl,v_zwrklvl,v_zyear,v_yrecycle,rt_tcontral.qtyavgwk);
				if v_error or nvl(rt_tleavetr.qtymin,0) = 0 then
					del_tleavetr(v_codempid,v_dtework,v_codleave,v_numlereq,v_zyear,(v_yrecycle - v_zyear),p_coduser);
				end if;
				--
				if not v_error then
					for r_tlereqst in c_tlereqst loop
						rt_tleavetr.deslereq   := r_tlereqst.deslereq;
            -- paternity leave --
            rt_tleavetr.dteprgntst := r_tlereqst.dteprgntst;
            rt_tleavetr.timprgnt   := r_tlereqst.timprgnt;
            --
						v_qtydlemx := r_tlereqst.qtydlemx;
						if r_tlereqst.dayeupd is null then
							begin
								select qtydlepay,flgdlemx
								  into v_qtydlepay,v_flgdlemx
								  from tleavety
								 where typleave = rt_tleavetr.typleave;
							exception when no_data_found then null;
							end;
							if v_flgdlemx = 'Y' then
								if r_tlereqst.qtyday > v_qtydlepay then
									v_qtydlemx := v_qtydlepay;
								else
									v_qtydlemx := r_tlereqst.qtyday;
								end if;
							end if;
						end if;
		 				--
		 				update tlereqst
		 				   set dayeupd  = greatest(p_endate,trunc(sysdate)),
		 					 		 qtydlemx = v_qtydlemx,
		 							 coduser  = p_coduser
		 				 where rowid    = r_tlereqst.rowid;
					end loop; -- for c_tlereqst
					--
					if rt_tleavetr.qtymin > 0 then
						upd_tleavetr(rt_tleavetr,p_coduser,v_zyear,v_yrecycle,p_numrec);
					end if;
					--
					update tlereqd
					   set dayeupd  = greatest(p_endate,trunc(sysdate)),
								 coduser  = p_coduser
					 where numlereq = r_tlereqd.numlereq
						 and dtework  = r_tlereqd.dtework
						 and codleave = r_tlereqd.codleave;
				end if; -- v_error = false

				std_al.cal_tattence(v_codempid,rt_tleavetr.dtework,rt_tleavetr.dtework,'N',rt_tcontral,false,p_coduser,v_numrec);
			end if; -- Secur
		end loop; -- for r_tlereqd
		commit;
	end;
  --

	procedure gen_tlereqd
		(p_codempid		in	varchar2,
		 p_codcomp		in	varchar2,
		 p_stdate			in	date,
		 p_endate			in	date,
		 p_coduser		in	varchar2) is
		v_secur       boolean;
	  v_zminlvl  		number;
	  v_zwrklvl  		number;
	  v_zupdsal   	varchar2(4);
		v_timstrt 		tlereqd.timstrt%type;
		v_timend	 		tlereqd.timend%type;
		v_timstrtw		varchar2(4);
		v_timendw			varchar2(4);
		v_timstrtb		varchar2(4);
		v_timendb			varchar2(4);
		v_date				date;
		v_codempid 		temploy1.codempid%type;
		v_dtework			tattence.dtework%type;

		v_flgwork			varchar2(1);
		v_codcomp 		temploy1.codcomp%type;
		v_numlvl 			temploy1.codcomp%type;
		v_numlereq		tlereqd.numlereq%type;
		o_numlereq    tlereqst.numlereq%type;
		v_dtestrt			date;
	  v_dteend			date;
		v_strtw 			date;
		v_endle 			date;
		v_dtelest 		tlereqd.dtework%type;
		v_timlest 		tlereqd.timstrt%type;
		v_dteleen 		tlereqd.dtework%type;
		v_timleen 		tlereqd.timend%type;

		v_qtymin			tlereqd.qtymin%type;
		v_qtyday			tlereqd.qtyday%type;

		v_typleave		tleavety.typleave%type;
		v_staleave		tleavecd.staleave%type;
		v_flgdlemx		tleavety.flgdlemx%type;
		v_flgchol			tleavety.flgchol%type;
		v_codleave		tleavetr.codleave%type;
		v_summin			number;
		v_sumday			number;
		v_yrecycle		number;
		v_dtecycst		date;
		v_dtecycen		date;

		v_qtyavgwk		number;
	  v_check1		  varchar2(4);
	  v_check2		  varchar2(4);
		v_chkreg 			varchar2(100);
		v_zyear				number := 0;

  cursor c_tlereqst is
			select rowid,numlereq,codempid,codleave,dtestrt,timstrt,dteend,timend,dtecancl,flgleave,dteleave
			  from tlereqst
			 where numlereq in (select numlereq
                            from tlereqd
                           where codempid = nvl(p_codempid,codempid)
			                       and codcomp like p_codcomp||'%'
                             and((p_coduser  = 'AUTO' and dtework between nvl(p_stdate,dtework) and nvl(p_endate,dtework) and dayeupd is null)
                              or (p_coduser <> 'AUTO' and dtework between nvl(p_stdate,dtework) and nvl(p_endate,dtework))))
		order by numlereq;

		cursor c_tattence is
			select codempid,dtework,typwork,codshift,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw
			  from tattence
			 where codempid = v_codempid
			   and dtework  = v_dtework
		order by codempid,dtework;

		cursor c_tleavetr is
		  select dtework,qtymin,qtyday,qtylvded,rowid
		    from tleavetr
		   where codempid = v_codempid
	       and dtework  = v_dtework
		     and codleave = v_codleave;

		cursor c_tlereqd is
		  select rowid,dayeupd,dtework
		    from tlereqd
		   where codempid = v_codempid
	       and dtework  = v_dtework
		     and codleave = v_codleave;
	begin
	  --
		if p_coduser <> 'AUTO' then
			begin
	      select get_numdec(numlvlst,p_coduser) numlvlst, get_numdec(numlvlen,p_coduser) numlvlen
	        into v_zminlvl,v_zwrklvl
	        from tusrprof
				 where coduser = p_coduser;
			exception when others then null;
			end;
		end if;

		begin
			select value
			  into v_chkreg
			  from v$nls_parameters
			 where parameter = 'NLS_CALENDAR';

			if v_chkreg = 'Thai Buddha' then
				v_zyear := 543;
			end if;
		exception when others then null;
		end;
		--
		for r_tlereqst in c_tlereqst loop
			v_secur := secur_main.secur2(r_tlereqst.codempid,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
			if v_secur or p_coduser = 'AUTO' then
				v_numlereq := r_tlereqst.numlereq;
				v_codempid := r_tlereqst.codempid;
				v_codleave := r_tlereqst.codleave;
				begin
					select codcomp,numlvl
					  into v_codcomp,v_numlvl
					  from temploy1
					 where codempid = r_tlereqst.codempid;
				exception when no_data_found then	null;
				end;

				begin
					select typleave,staleave
					  into v_typleave,v_staleave
					  from tleavecd
					 where codleave = r_tlereqst.codleave;
				exception when no_data_found then	null;
				end;

				begin
					select flgdlemx,flgchol
					  into v_flgdlemx,v_flgchol
					  from tleavety
					 where typleave = v_typleave;
				exception when no_data_found then	null;
				end;

				v_dtestrt  := null;
				v_timstrt  := null;
				v_dteend   := null;
				v_timend   := null;
				if r_tlereqst.flgleave in ('M','E') then
					begin
						select timstrtw,timendw,timstrtb,timendb
						  into v_timstrtw,v_timendw,v_timstrtb,v_timendb
						  from tshiftcd
						 where codshift	=	(select codshift
						                     from tattence
																where codempid	=	r_tlereqst.codempid
																  and	dtework		=	r_tlereqst.dteleave);
						exception when others then null;
					end;

					if r_tlereqst.flgleave = 'M' then
						v_timstrt := v_timstrtw;
						v_timend  := nvl(v_timstrtb,v_timendw);
					elsif r_tlereqst.flgleave = 'E' then
						v_timstrt := nvl(v_timendb,v_timstrtw);
						v_timend  := v_timendw;
					end if;

					if v_timstrt < v_timstrtw then
						v_dtestrt	:=	r_tlereqst.dteleave + 1;
						v_dteend	:=	r_tlereqst.dteleave + 1;
					else
						v_dtestrt	:=	r_tlereqst.dteleave;
						v_dteend	:=	r_tlereqst.dteleave;
						if v_timstrt > v_timend then
							v_dteend	:=	v_dteend + 1;
						end if;
					end if;
				elsif r_tlereqst.flgleave in ('A') then
					v_dtestrt  	:= r_tlereqst.dtestrt;
					v_dteend   	:= r_tlereqst.dteend;
					v_timstrt	  := null;
					v_timend  	:= null;
				elsif r_tlereqst.flgleave in ('H') then
					v_dtestrt  	:= r_tlereqst.dtestrt;
					v_dteend   	:= r_tlereqst.dteend;
					v_timstrt	  := r_tlereqst.timstrt;
					v_timend  	:= r_tlereqst.timend;
				end if;
				--
				std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),v_codempid,r_tlereqst.codleave,v_dtestrt,v_yrecycle,v_dtecycst,v_dtecycen);
				v_date   := v_dtestrt;
				if v_dtestrt <= v_dteend then
					<<cal_loop>> loop
						-- Yesterday (tattence)
						if v_date = v_dtestrt and v_timstrt is not null then
							v_dtework := v_date - 1;
							for r_tattence in c_tattence loop
								v_flgwork := 'W';
								--
								v_check1 := 'N';
								for r_tleavetr in c_tleavetr loop
									if nvl(r_tleavetr.qtylvded,0) > 0 then
							    	v_check1 := 'Y';
									end if;
								end loop;

								v_check2 := 'N';
								for r_tlereqd in c_tlereqd loop
									if (p_coduser  = 'AUTO' and r_tlereqd.dtework between nvl(p_stdate,r_tlereqd.dtework) and nvl(p_endate,r_tlereqd.dtework) and r_tlereqd.dayeupd is null)
	    					  or (p_coduser <> 'AUTO' and r_tlereqd.dtework between nvl(p_stdate,r_tlereqd.dtework) and nvl(p_endate,r_tlereqd.dtework)) then
	    					  	null;
									else
										v_check2 := 'Y';
									end if;
								end loop;
								--
								if v_check1 = 'N' and v_check2 = 'N' then
									if v_flgdlemx = 'N' and (not(v_dtework between v_dtecycst and v_dtecycen)) then null;
									else
										v_dtelest := v_dtestrt;
										v_timlest := v_timstrt;
										v_dteleen := r_tattence.dteendw;
										if r_tattence.dteendw = v_dteend then
											v_timleen := nvl(v_timend,r_tattence.timendw);
										else
											v_timleen := r_tattence.timendw;
										end if;
										--
										begin
											select qtydaywk
											  into v_qtyavgwk
											  from tshiftcd
											 where codshift = r_tattence.codshift;
										exception when no_data_found then null;
										end;

										cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
																	 r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw,
																	 v_dtelest,v_timlest,v_dteleen,v_timleen,
																	 v_qtymin,v_qtyday,v_qtyavgwk,r_tlereqst.flgleave);
										--
										delete tlereqd
										 where numlereq = v_numlereq
										   and dtework  = v_dtework
										   and codleave = v_codleave;
										if v_qtymin > 0 then
			                insert into tlereqd(numlereq,dtework,codleave,codempid,codcomp,numlvl,
			                                    timstrt,timend,qtymin,qtyday,codcreate,coduser)
								                   values(v_numlereq,v_dtework,v_codleave,v_codempid,v_codcomp,v_numlvl,
								                          v_timlest,v_timleen,v_qtymin,v_qtyday,p_coduser,p_coduser);
										else
											del_tleavetr(v_codempid,v_dtework,v_codleave,v_numlereq,v_zyear,(v_yrecycle - v_zyear),p_coduser);
										end if; -- v_qtymin > 0
									end if;--if v_flgdlemx = 'N' and (not(v_dtework between v_dtecycst and v_dtecycen)) then null;
								end if; --if v_check1 = 'N' then
							end loop; -- for r_tattence
						end if; -- v_date = r_tlereqst.dtestrt and v_timstrt is not null
						---------------------------------------------------------------------------
						-- Today (tattence)
						v_dtework := v_date;
						for r_tattence in c_tattence loop
							v_flgwork := 'W';
							--
							v_check1 := 'N';
							for r_tleavetr in c_tleavetr loop
								if nvl(r_tleavetr.qtylvded,0) > 0 then
						    	v_check1 := 'Y';
								end if;
							end loop;

							v_check2 := 'N';
							for r_tlereqd in c_tlereqd loop
								if (p_coduser  = 'AUTO' and r_tlereqd.dtework between nvl(p_stdate,r_tlereqd.dtework) and nvl(p_endate,r_tlereqd.dtework) and r_tlereqd.dayeupd is null)
    					  or (p_coduser <> 'AUTO' and r_tlereqd.dtework between nvl(p_stdate,r_tlereqd.dtework) and nvl(p_endate,r_tlereqd.dtework)) then
    					  	null;
								else
									v_check2 := 'Y';
								end if;
							end loop;
							--
							if v_check1 = 'N' and v_check2 = 'N' then
								if v_flgdlemx = 'N' and (not(v_dtework between v_dtecycst and v_dtecycen)) then null;
								else
									if v_date = v_dtestrt and v_timstrt is not null then
										v_dtelest := v_dtestrt;
										v_timlest := v_timstrt;
									else
										v_dtelest := r_tattence.dtestrtw;
										v_timlest := r_tattence.timstrtw;
									end if;
							  	if v_timend is not null then
								  	v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
								  	v_endle  := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
						        if v_strtw >= v_endle then
											exit cal_loop;
						        end if;
						      end if;
									if r_tattence.dteendw >= v_dteend and v_timend is not null then
										v_dteleen := v_dteend;
										v_timleen := v_timend;
									else
										v_dteleen := r_tattence.dteendw;
										v_timleen := r_tattence.timendw;
									end if;
									--
									begin
										select qtydaywk
										  into v_qtyavgwk
										  from tshiftcd
										 where codshift = r_tattence.codshift;
									exception when no_data_found then null;
									end;

									cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
																 r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw,
																 v_dtelest,v_timlest,v_dteleen,v_timleen,
																 v_qtymin,v_qtyday,v_qtyavgwk,r_tlereqst.flgleave);
									--
									delete tlereqd
									 where numlereq = v_numlereq
									   and dtework  = v_dtework
									   and codleave = v_codleave;

									if v_qtymin > 0 then
		                insert into tlereqd(numlereq,dtework,codleave,codempid,codcomp,numlvl,
		                                    timstrt,timend,qtymin,qtyday,codcreate,coduser)
							                   values(v_numlereq,v_dtework,v_codleave,v_codempid,v_codcomp,v_numlvl,
							                          v_timlest,v_timleen,v_qtymin,v_qtyday,p_coduser,p_coduser);
									else
										del_tleavetr(v_codempid,v_dtework,v_codleave,v_numlereq,v_zyear,(v_yrecycle - v_zyear),p_coduser);
									end if; -- v_qtymin > 0
								end if;--if v_flgdlemx = 'N' and (not(v_dtework between v_dtecycst and v_dtecycen)) then null;
							end if; --if v_check1 = 'N' then
						end loop; -- for r_tattence
						--
						v_date := v_date + 1;
						if (v_date > v_dteend) or (v_date >= r_tlereqst.dtecancl and r_tlereqst.dtecancl is not null) then
							exit cal_loop;
						end if;
					end loop;	-- cal_loop
				end if; -- v_dtestrt <= v_dteend
				--
				v_summin := 0; v_sumday := 0;
				begin
					select sum(qtymin),sum(qtyday)
					  into v_summin,v_sumday
					  from tlereqd
					 where numlereq = v_numlereq;
				exception when no_data_found then null;
				end;
				update tlereqst
					 set timstrt  = v_timstrt,
							 timend   = v_timend,
							 dtestrt  = v_dtestrt,
							 dteend   = v_dteend,
							 qtymin		= v_summin,
							 qtyday   = v_sumday
				 where rowid    = r_tlereqst.rowid;
				--
				commit;
			end if;--if v_secur or p_coduser = 'AUTO' then
		end loop;--for r1 in c_tlereqst loop
	end;
	--

	procedure cal_leave
		(p_tlereqd	in 	tlereqd%rowtype,
		 p_tleavetr out tleavetr%rowtype,
		 p_error    out boolean,
		 p_coduser	in	varchar2,
		 p_zminlvl	in	number,
		 p_zwrklvl	in	number,
		 p_zyear		in	number,
		 p_yrecycle	in	number,

		 p_qtyavgwk	in	number) is

		v_flgsecu			boolean;
		v_flgworkth		boolean;
	  v_flgfound  	boolean;
		v_codempid    temploy1.codempid%type;
		v_numlvl	    temploy1.numlvl%type;
		v_dtework     tattence.dtework%type;
		v_qtymin			tleavetr.qtymin%type;
		v_qtyday			tleavetr.qtyday%type;
		v_dtelest			tlereqst.dtestrt%type;
		v_dteleen			tlereqst.dteend%type;
		v_timlest			tleavetr.timstrt%type;

		v_timleen			tleavetr.timend%type;
		v_typleave    tleavety.typleave%type;
		v_qtydlepay   tleavety.qtydlepay%type;
		v_qtydlepery  tleavety.qtydlepery%type;
		v_flgchol			tleavety.flgchol%type;
		v_flgdlemx		tleavety.flgdlemx%type;
		v_qtydlemx		tleavety.qtydlepay%type;
		v_flgwkcal		tleavety.flgwkcal%type;
		v_flgtimle		tleavety.flgtimle%type;
		v_qtytimle		tleavety.qtytimle%type;
		v_codleave		tleavecd.codleave%type;
		v_staleave		tleavecd.staleave%type;
		v_yearst			number(4) := 0;

		v_yearen			number(4) := 0;
		v_sumlevmx    number;
		v_numlereq    tlereqst.numlereq%type;
		v_dayeupd     tlereqst.dayeupd%type;
		v_qtyavgwk    number;
		v_zupdsal   	varchar2(4);
		v_flgleave		varchar2(4);

		cursor c_tattence is
			select codempid,dtework,typwork,codshift,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw,codcomp
			  from tattence
			 where codempid = v_codempid
			   and dtework  = v_dtework
		order by codempid,dtework;

	begin
		v_numlereq := p_tlereqd.numlereq;
		v_dtework  := p_tlereqd.dtework;
		v_codempid := p_tlereqd.codempid;
		v_codleave := p_tlereqd.codleave;
		p_tleavetr.numlereq := p_tlereqd.numlereq;
		p_error := false;
		<<main_loop>>	loop
			begin
				select codleave,typleave,staleave
				  into p_tleavetr.codleave,p_tleavetr.typleave,p_tleavetr.staleave
				  from tleavecd
				 where codleave = v_codleave;
				begin
					select qtydlepay,flgchol,flgdlemx,flgwkcal,flgtimle,qtytimle
					  into v_qtydlepay,v_flgchol,v_flgdlemx,v_flgwkcal,v_flgtimle,v_qtytimle
					  from tleavety
					 where typleave = p_tleavetr.typleave;
				exception when no_data_found then p_error := true;
					exit main_loop;
				end;
			exception when no_data_found then p_error := true;
				exit main_loop;
			end;
			--
			begin
				select codempid,codcomp,typpayroll,numlvl
				  into p_tleavetr.codempid,p_tleavetr.codcomp,p_tleavetr.typpayroll,v_numlvl
				  from temploy1
				 where codempid = v_codempid;
				v_flgsecu := secur_main.secur1(p_tleavetr.codcomp,v_numlvl,p_coduser,p_zminlvl,p_zwrklvl,v_zupdsal);
				if not v_flgsecu and p_coduser <> 'AUTO' then
					p_error := true;
					exit main_loop;
				end if;
			exception when no_data_found then p_error := true;
				exit main_loop;
			end;
			--check quality time leave over limit
			v_sumlevmx := 0;
			begin
				select dayeupd,flgleave
				  into v_dayeupd,v_flgleave
				  from tlereqst
				 where numlereq = v_numlereq;
			exception when no_data_found then exit main_loop;
			end;
			if v_dayeupd is null and v_qtytimle > 0 then

				if v_flgtimle = 'Y' then
					v_yearst := p_yrecycle-p_zyear;
					v_yearen := v_yearst;
				elsif v_flgtimle = 'A' then
					v_yearen := 9999;
				end if;
				begin
					select sum(qtytleav)
					  into v_sumlevmx
					  from tleavsum
					 where codempid = v_codempid
					   and dteyear between v_yearst and v_yearen
					   and typleave = p_tleavetr.typleave;
					if v_sumlevmx >= v_qtytimle then p_error := true;
						exit main_loop;
					end if;
				exception when no_data_found then null;
				end;
        --ต??อ??รรภ??
			end if;
			--
			for r_tattence in c_tattence loop
				p_tleavetr.codcomp	:= r_tattence.codcomp;
				p_tleavetr.dtework  := p_tlereqd.dtework;
				p_tleavetr.codshift := r_tattence.codshift;
				p_tleavetr.flgatten := r_tattence.flgatten;

				v_timlest := p_tlereqd.timstrt;
				v_timleen := p_tlereqd.timend;
				if v_timlest < r_tattence.timstrtw then
					v_dtelest := p_tlereqd.dtework + 1;
				else
					v_dtelest := p_tlereqd.dtework;
				end if;
				if v_timlest < v_timleen then
					v_dteleen := v_dtelest;
				else
					v_dteleen := v_dtelest + 1;
				end if;

				begin
					select qtydaywk
					  into v_qtyavgwk
					  from tshiftcd
					 where codshift = r_tattence.codshift;
				exception when no_data_found then null;
				end;

				cal_time_leave(v_flgchol,p_tleavetr.codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
											 r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw,
											 v_dtelest,v_timlest,v_dteleen,v_timleen,
											 v_qtymin,v_qtyday,v_qtyavgwk,v_flgleave);

				if v_qtymin > 0 then
					p_tleavetr.timstrt  := v_timlest;
					p_tleavetr.timend   := v_timleen;
					p_tleavetr.qtymin   := v_qtymin;
					p_tleavetr.qtyday   := v_qtyday;
				end if;
			end loop; -- for r_tattence
			exit main_loop;
		end loop; -- main_loop
	end;
	--

	procedure upd_tleavetr
		(p_tleavetr in tleavetr%rowtype,
		 p_coduser	in varchar2,
		 p_zyear		in number,
		 p_yrecycle	in number,
		 p_numrec		in out number) is

		v_flgfound 	boolean;
		v_codleave  tleavetr.codleave%type;
		v_strt			date;
		v_end				date;
		v_strtle 		date;
		v_endle			date;

    v_yrecycle		number;
    v_dtecycst		date;
    v_dtecycen		date;
    v_dtelastle   date;
    v_cnt         number;
    v_qtytleav    number;

		cursor c_delleave is
			select codempid,dtework,codleave,timstrt,timend,qtymin,qtyday,qtylvded,rowid,codcomp,staleave
			  from tleavetr
			 where codempid = p_tleavetr.codempid
			   and dtework  = p_tleavetr.dtework
		order by dtework,codleave;

		cursor c_tleavetr is
			select codempid,dtework,codleave,qtymin,qtyday,qtylvded,rowid,codcomp,staleave
			  from tleavetr
			 where codempid = p_tleavetr.codempid
			   and dtework  = p_tleavetr.dtework
			   and codleave = p_tleavetr.codleave;

		cursor c_tleavsum is
			select codempid,dteyear,codleave,rowid
			  from tleavsum
			 where codempid = p_tleavetr.codempid
			   and dteyear  = (v_yrecycle - p_zyear)
			   and codleave = v_codleave;
	begin
		v_strtle := to_date(to_char(p_tleavetr.dtework,'dd/mm/yyyy')||p_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
		if p_tleavetr.timstrt < p_tleavetr.timend then
			v_endle := to_date(to_char(p_tleavetr.dtework,'dd/mm/yyyy')||p_tleavetr.timend,'dd/mm/yyyyhh24mi');
		else
			v_endle := to_date(to_char(p_tleavetr.dtework + 1,'dd/mm/yyyy')||p_tleavetr.timend,'dd/mm/yyyyhh24mi');
		end if;
		--
		for r_delleave in c_delleave loop
			v_strt := to_date(to_char(r_delleave.dtework,'dd/mm/yyyy')||r_delleave.timstrt,'dd/mm/yyyyhh24mi');
			if r_delleave.timstrt < r_delleave.timend then
				v_end := to_date(to_char(r_delleave.dtework,'dd/mm/yyyy')||r_delleave.timend,'dd/mm/yyyyhh24mi');
			else
				v_end := to_date(to_char(r_delleave.dtework + 1,'dd/mm/yyyy')||r_delleave.timend,'dd/mm/yyyyhh24mi');
			end if;
			if ((v_strt = v_strtle	and v_end  = v_endle) or
					(v_strt > v_strtle	and v_strt < v_endle) or
					(v_end  > v_strtle	and v_end  < v_endle) or
				  (v_strtle > v_strt	and v_strtle < v_end) or
				  (v_endle  > v_strt	and v_endle  < v_end)) then
				if r_delleave.qtylvded > 0 then
					return;
				end if;
				v_codleave := r_delleave.codleave;
        std_al.cycle_leave(hcm_util.get_codcomp_level(r_delleave.codcomp,1),r_delleave.codempid,r_delleave.codleave,r_delleave.dtework,v_yrecycle,v_dtecycst,v_dtecycen);
        begin
          select count(codempid) into v_cnt
          from  tleavetr
          where codempid = p_tleavetr.codempid
          and   numlereq = p_tleavetr.numlereq
          and   dtework <> r_delleave.dtework;
        end;
        if nvl(v_cnt,0) > 0 then
          v_qtytleav := 0;
        else
          v_qtytleav := 1;
        end if;
        v_dtelastle := null;
        begin
          select max(dtework) into v_dtelastle
          from  tleavetr
          where codempid = p_tleavetr.codempid
          and   codleave = p_tleavetr.codleave
          and   dtework   between v_dtecycst and v_dtecycen
          and   dtework <> r_delleave.dtework;
        end;

				for r_tleavsum in c_tleavsum loop
					update tleavsum
						 set qtyshrle  = greatest(qtyshrle - (r_delleave.qtymin / 60),0),
								 qtydayle  = greatest(qtydayle - r_delleave.qtyday,0),
                 qtytleav  = greatest(qtytleav - v_qtytleav,0),
                 dtelastle = v_dtelastle,
								 coduser   = p_coduser
					 where rowid     = r_tleavsum.rowid;
				end loop;

				delete tleavetr where rowid = r_delleave.rowid;
			end if;
		end loop;
		--
		v_flgfound := false;
		for r_tleavetr in c_tleavetr loop
			if r_tleavetr.qtylvded > 0 then
				return;
			end if;
			v_codleave := r_tleavetr.codleave;
      std_al.cycle_leave(hcm_util.get_codcomp_level(r_tleavetr.codcomp,1),r_tleavetr.codempid,r_tleavetr.codleave,r_tleavetr.dtework,v_yrecycle,v_dtecycst,v_dtecycen);
			begin
        select count(codempid) into v_cnt
        from  tleavetr
        where codempid = p_tleavetr.codempid
        and   numlereq = p_tleavetr.numlereq
        and   dtework <> r_tleavetr.dtework;
      end;
      if nvl(v_cnt,0) > 0 then
        v_qtytleav := 0;
      else
        v_qtytleav := 1;
      end if;
      v_dtelastle := null;
      begin
        select max(dtework) into v_dtelastle
        from  tleavetr
        where codempid = p_tleavetr.codempid
        and   codleave = p_tleavetr.codleave
        and   dtework   between v_dtecycst and v_dtecycen
        and   dtework <> r_tleavetr.dtework;
      end;

      v_flgfound := true;
			for r_tleavsum in c_tleavsum loop
				update tleavsum
					set qtyshrle  = greatest(qtyshrle - (r_tleavetr.qtymin / 60),0),
							qtydayle  = greatest(qtydayle - r_tleavetr.qtyday,0),
              qtytleav  = greatest(qtytleav - v_qtytleav,0),
              dtelastle = v_dtelastle,
							coduser   = p_coduser
				where rowid     = r_tleavsum.rowid;
			end loop;
			update tleavetr
				 set codcomp  = p_tleavetr.codcomp,	 codshift = p_tleavetr.codshift,
						 flgatten = p_tleavetr.flgatten, numlereq = p_tleavetr.numlereq,
						 typleave = p_tleavetr.typleave, staleave = p_tleavetr.staleave,
						 timstrt  = p_tleavetr.timstrt,	 timend   = p_tleavetr.timend,
	 					 qtymin   = p_tleavetr.qtymin,	 qtyday   = p_tleavetr.qtyday,
						 coduser  = p_coduser,	         typpayroll = p_tleavetr.typpayroll,
						 deslereq = p_tleavetr.deslereq,
             -- paternity leave --
             timprgnt = p_tleavetr.timprgnt, dteprgntst = p_tleavetr.dteprgntst
			 where rowid = r_tleavetr.rowid;
		end loop; -- for r_tleavetr
		--
		if not v_flgfound then
			insert into tleavetr(codempid,dtework,codleave,codcomp,codshift,flgatten,numlereq,typleave,staleave,
											     timstrt,timend,qtymin,qtyday,typpayroll,deslereq,
                           -- paternity leave --
                           timprgnt,dteprgntst,
                           --
                           codcreate,coduser)
										values(p_tleavetr.codempid,p_tleavetr.dtework,p_tleavetr.codleave,p_tleavetr.codcomp,p_tleavetr.codshift,p_tleavetr.flgatten,p_tleavetr.numlereq,p_tleavetr.typleave,p_tleavetr.staleave,
										       p_tleavetr.timstrt,p_tleavetr.timend,p_tleavetr.qtymin,p_tleavetr.qtyday,p_tleavetr.typpayroll,p_tleavetr.deslereq,
                           -- paternity leave --
                           p_tleavetr.timprgnt,p_tleavetr.dteprgntst,
                           --
                           p_coduser,p_coduser);
		end if;
		--
		v_flgfound := false;
		v_codleave := p_tleavetr.codleave;
    v_yrecycle := p_yrecycle;
		for r_tleavsum in c_tleavsum loop
			v_flgfound := true;

			update tleavsum
				set qtyshrle  = nvl(qtyshrle,0) + (p_tleavetr.qtymin / 60),
						qtydayle  = nvl(qtydayle,0) + nvl(p_tleavetr.qtyday,0),
						coduser   = p_coduser
			where rowid = r_tleavsum.rowid;
		end loop;
		if not v_flgfound then
			insert into tleavsum(codempid,dteyear,codleave,typleave,staleave,codcomp,typpayroll,
													 qtyshrle,qtydayle,codcreate,coduser)
										values(p_tleavetr.codempid,(p_yrecycle-p_zyear),p_tleavetr.codleave,p_tleavetr.typleave,
										       p_tleavetr.staleave,p_tleavetr.codcomp,p_tleavetr.typpayroll,
											   	 (p_tleavetr.qtymin / 60),p_tleavetr.qtyday,p_coduser,p_coduser);
		end if;

		p_numrec := nvl(p_numrec,0) + 1;
		--
		upd_tleavsum(p_tleavetr.codempid,p_tleavetr.dtework,p_tleavetr.codleave,p_zyear,p_coduser);
	end;
  --
*/
end HRAL56B_BATCH;

/
