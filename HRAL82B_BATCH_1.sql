--------------------------------------------------------
--  DDL for Package Body HRAL82B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL82B_BATCH" is
	procedure start_process is
		v_coduser   varchar2(50 char) := 'AUTOBATCH';
		v_msgerror  varchar2(1000 char) := null;
    v_descerr   varchar2(1000 char) := null;
		v_status    varchar2(1 char) := 'C';
		v_numrec    number;
    v_error     varchar2(10 char);
    v_err_table	varchar2(50 char);
    p_dtecall   date := sysdate;

	  cursor c_tcontrlv is
	    select codcompy
	      from tcontrlv
	  group by codcompy
	  order by codcompy;

	begin
	  --
		begin
			for r_tcontrlv in c_tcontrlv loop
      	--cal_process(null,r_tcontrlv.codcompy,trunc(sysdate),v_coduser,v_numrec,v_error,v_err_table);
        gen_vacation(null,r_tcontrlv.codcompy,trunc(sysdate),v_coduser,v_numrec);
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
      v_msgerror := 'Error(1): '||v_error||' '||get_errorm_name(v_error,'102');
    else
			v_msgerror := substr('Error(2): '||v_numrec||' '||v_descerr,1,200);
		end if;
		--
    begin
      delete tautolog where codapp = 'HRAL82B' and dtecall = p_dtecall;
      insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
           values ('HRAL82B',p_dtecall,p_dtecall,sysdate,v_status,v_msgerror,v_coduser);
    end;
    commit;
	end;
	--
  procedure gen_vacation(p_codempid	in varchar2,
                         p_codcomp	in varchar2,
                         p_dtecal	  in date,
                         p_coduser	in varchar2,
                         p_numrec	 out number) is
    v_secur       boolean;
    v_zupdsal     varchar2(4 char);
		v_dtemovemt		date;
    v_codempid    temploy1.codempid%type;
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
    v_qtywkday		temploy1.qtywkday%type;
		v_dteempmt    temploy1.dteempmt%type;
    v_amthour		 	number := 0;
		v_amtday			number := 0;
		v_amtmth			number := 0;

    v_flgfound    boolean;
    v_codleave    tleavecd.codleave%type;
    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_yrecycle    tleavsum.dteyear%type;
    v_dtecycst    tleavsum.dtecycst%type;
    v_dtecycen    tleavsum.dtecycen%type;
    v_dtecycstM   tleavsum.dtecycst%type;
    v_dtecycenM   tleavsum.dtecycen%type;
    v_dteeffeclv  tleavsum.dteeffeclv%type;
    v_yrecycle2   number;
    v_dtecycst2   date;
    v_dtecycen2   date;

    v_dteeffec    tcontrlv.dteeffec%type;
    v_qtyday      tcontrlv.qtyday%type;
    v_flgcal		  tcontrlv.flgcal%type;
    v_typround		tcontrlv.typround%type;
    v_flgresign		tcontrlv.flgresign%type;
    v_flguse	   	tcontrlv.flguse%type;
    v_qtylimit   	tratevac2.qtylimit%type;
    v_mthprien   	tratevac2.mthprien%type;
    v_dteprien    date;
    v_svmth       number;
    v_svyre       number;
    v_svday       number;
    v_desc        tratevac.syncond%type;
    v_stmt        varchar2(4000);
    v_numseq      tratevac.numseq%type;
    v_qtypriyr_Temp tleavsum.qtypriyr%type;

    v_qtydayvacat tleavsum2.qtydayvacat%type;
    v_qtydayvacat_Temp  tleavsum2.qtydayvacat%type;
    v_qtypriyr    tleavsum.qtypriyr%type;
    v_qtyvacat    tleavsum.qtyvacat%type;
    v_qtypriyrM   tleavsum.qtypriyr%type;
    v_qtyvacatM   tleavsum.qtyvacat%type;
    v_qtyadjvac   tleavsum.qtyadjvac%type;
    v_qtydayle    tleavsum.qtydayle%type;
  	v_month       number;
    v_dteeffex    date;

    type number_ is table of number(13,0) index by binary_integer;
	     a_qtydayvacat  number_;

    cursor c_temploy1 is
      select codempid,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl,dteempmt,qtywkday,staemp,
             dteeffex,dtereemp--<< user22 : 19/03/2024 : ST11 || 
        from temploy1
       where codcomp  like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
         and staemp   <> '0'
    order by codcomp,codempid;

    cursor c_tratevac is
      select numseq,syncond
        from tratevac
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
    order by numseq;

    cursor c_tratevac2 is
      select qtylwkst,qtylwken,qtymin,qtymax,flgcal,qtylimit,qtywkbeg,mthprien
        from tratevac2
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
         and v_svmth between qtylwkst and qtylwken
    order by qtylwkst;

    cursor c_tleavsum2 is
      select monthno, nvl(qtydayvacat,0) as qtydayvacat
        from tleavsum2
       where codempid = v_codempid
         and dteyear  = v_yrecycle
         and codleave = v_codleave
    order by monthno;

  begin
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    for r1 in c_temploy1 loop
      if p_coduser <> 'AUTOBATCH' then
        v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          goto main_emp;
        end if;
      end if;
      v_dteempmt := r1.dteempmt - nvl(r1.qtywkday,0);
      v_codempid := r1.codempid;
      v_codcomp  := r1.codcomp;
--<< user22 : 19/03/2024 : ST11 || 
      v_dteeffex := r1.dteeffex;
      if v_dteeffex is null then
        begin
          select min(dteeffec) into v_dteeffex
            from ttexempt
           where codempid = r1.codempid
             and dteeffec > nvl(r1.dtereemp,r1.dteempmt)
             and staupd   in ('C','U');
        end;        
      end if;
      /*begin
        select min(dteeffec) into v_dteeffex
          from ttexempt
         where codempid = r1.codempid
           and dteeffec >= r1.dteempmt
           and staupd   in ('C','U');
      exception when no_data_found then
        v_dteeffex := null;
      end;*/
-->> user22 : 19/03/2024 : ST11 ||       
      begin
        select a.codleave,a.typleave,a.staleave
          into v_codleave,v_typleave,v_staleave
          from tleavecd a, tleavcom b
         where a.typleave = b.typleave
           and a.staleave = 'V'
           and b.codcompy = hcm_util.get_codcomp_level(r1.codcomp,1);
      exception when no_data_found then goto main_emp;
      end;

      std_al.cycle_leave(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_codleave,p_dtecal,v_yrecycle,v_dtecycst,v_dtecycen);
      if v_dteeffex <= v_dtecycst then
        delete tleavsum  where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
        delete tleavsum2 where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
        goto main_emp;
      end if;

      begin
        select dteeffec,nvl(qtyday,0),flgcal,typround,nvl(flgresign,'1'),nvl(flguse,'1')
          into v_dteeffec,v_qtyday,v_flgcal,v_typround,v_flgresign,v_flguse
          from tcontrlv
         where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrlv
                            where codcompy  = hcm_util.get_codcomp_level(r1.codcomp,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then goto main_emp;
      end;

      v_svmth := 0; v_svyre := 0; v_svmth := 0; v_svday := 0;
      v_qtydayvacat := 0; v_qtyvacat := 0;
      for i in 1..12 loop
        a_qtydayvacat(i) := 0;
      end loop;

      get_service_year(v_dteempmt,v_dtecycen,'Y',v_svyre,v_svmth,v_svday);
      v_svmth   := v_svmth + (v_svyre * 12);
      if v_qtyday > 0 and v_svday > v_qtyday then
        v_svmth := v_svmth + 1;
      end if;

      v_codcomp := r1.codcomp; v_codpos := r1.codpos; v_numlvl := r1.numlvl; v_codjob := r1.codjob; v_codempmt := r1.codempmt; v_typemp := r1.typemp; v_typpayroll := r1.typpayroll; v_codbrlc := r1.codbrlc;v_codcalen := r1.codcalen; v_jobgrade := r1.jobgrade; v_codgrpgl := r1.codgrpgl; v_dteempmt := r1.dteempmt;
      for r2 in c_tratevac loop
        v_flgfound  := true;
        if r2.syncond is not null then
          v_desc := r2.syncond;
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
          v_desc := replace(v_desc,'TEMPLOY1.DTEEMPMT','to_date('''||to_char(v_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
          v_stmt := 'select count(*) from dual where '||v_desc;
          v_flgfound := execute_stmt(v_stmt);
        end if;
        if v_flgfound then
          v_numseq    := r2.numseq;
          for r3 in c_tratevac2 loop
            v_qtylimit  := nvl(r3.qtylimit,0);
            v_mthprien  := nvl(r3.mthprien,0);
            v_dteeffeclv := add_months(r1.dteempmt,nvl(r3.qtywkbeg,0));
            if r3.flgcal = '1' then
              v_qtydayvacat := r3.qtymin +(((r3.qtymax - r3.qtymin) * (v_svmth - r3.qtylwkst)) / (r3.qtylwken - r3.qtylwkst));
            else
              v_qtydayvacat := r3.qtymax;
            end if;
            exit;
          end loop; -- c_tratevac2 loop
          exit;
        end if;
      end loop; -- c_tratevac loop
--<< user22 : 23/07/2021 || https://hrmsd.peopleplus.co.th:4448/redmine/issues/6500
      if v_dteeffex is not null and (v_dteeffex - 1) < v_dteeffeclv then
        delete tleavsum
         where codempid   = r1.codempid
           and dteyear    = v_yrecycle
           and codleave   = v_codleave;
        delete tleavsum2
         where codempid   = r1.codempid
           and dteyear    = v_yrecycle
           and codleave   = v_codleave;
        goto main_emp;
      end if;
-->> user22 : 23/07/2021 || https://hrmsd.peopleplus.co.th:4448/redmine/issues/6500
      v_qtyvacat := v_qtydayvacat;

      if v_flgcal = '1' then --Avg
        v_qtydayvacat_Temp := 0;
        for k in c_tleavsum2 loop
           a_qtydayvacat(k.monthno) := k.qtydayvacat;
           v_qtydayvacat_Temp       := greatest(k.qtydayvacat, v_qtydayvacat_Temp);
        end loop;
        if v_qtydayvacat_Temp > 0 then
          v_qtydayvacat_Temp := 0;
          for i in 1..12 loop
            if i = 1 then
              v_dtecycstM := v_dtecycst;
              v_dtecycenM := add_months(v_dtecycst,1) - 1;
            else
              v_dtecycstM := v_dtecycenM + 1;
              v_dtecycenM := add_months(v_dtecycstM,1) - 1;
            end if;
            if trunc(last_day(sysdate)) <= trunc(v_dtecycenM) then
              v_qtydayvacat_Temp := v_qtydayvacat_Temp + v_qtydayvacat;
            else
              v_qtydayvacat_Temp := v_qtydayvacat_Temp + a_qtydayvacat(i);
            end if;
          end loop;
          v_qtyvacat := (v_qtydayvacat_Temp / 12);
        end if;
      end if;

      -- Resign      
      if v_flgresign = '1' and v_dteeffex is not null and (v_dteeffex - 1) between v_dtecycst and v_dtecycen then
        v_qtyvacat := (v_qtyvacat * ((v_dteeffex - 1) - greatest(r1.dteempmt,v_dtecycst)+ 1)) / 365;
      end if;

      -- Adjust
      begin
        select nvl(qtyadjvac,0),nvl(qtypriyr,0)
          into v_qtyadjvac,v_qtypriyr_Temp
          from tleavsum
         where codempid = r1.codempid
           and dteyear  = v_yrecycle
           and codleave = v_codleave;
      exception when no_data_found then
        v_qtyadjvac := 0; v_qtypriyr_Temp := 0;
      end;
      v_qtyvacat := v_qtyvacat + v_qtyadjvac;

      -- Round
      v_qtyvacat := entitlement_round(v_qtyvacat,v_typround);
      --
      v_qtypriyr_Temp := 0;
      if v_qtylimit > 0 then
        --if last_day(sysdate) <= last_day(v_dtecycst) then --Cal Privacat Only First month
          begin
            select nvl(qtyvacat,0) - nvl(qtydayle,0) - nvl(qtylepay,0) into v_qtypriyr_Temp-- #5726 : select nvl(qtyvacat,0) - nvl(qtydayle,0) into v_qtypriyr_Temp
              from tleavsum
             where codempid = r1.codempid
               and dteyear  = (v_yrecycle - 1)
               and codleave = v_codleave;
          exception when no_data_found then null;
          end;
        --end if;
        if v_qtypriyr_Temp < 0 then
          v_qtypriyr := 0;
          v_qtypriyr_Temp := 0;-- user22 : 08/12/2021 : ST11 ||
        elsif v_qtypriyr_Temp > v_qtylimit then
          v_qtypriyr_Temp := v_qtylimit;
        end if;
      end if; -- v_qtylimit > 0

      if v_mthprien > 0 then
        v_dteprien   := to_date('1/'||v_mthprien||'/'||v_yrecycle,'dd/mm/yyyy');
        v_dteprien   := last_day(v_dteprien);
        if v_dteprien not between v_dtecycst and v_dtecycen then
          v_dteprien   := to_date('1/'||v_mthprien||'/'||(v_yrecycle+1),'dd/mm/yyyy');
          v_dteprien   := last_day(v_dteprien);
        end if;
      end if;

      -- insert TLEAVSUM
      v_qtypriyr := v_qtypriyr_Temp;
      if to_char(sysdate,'yyyymm') > to_char(v_dteprien,'yyyymm') then
        v_qtydayle := 0;
        begin
          select nvl(sum(qtyday),0) into v_qtydayle
            from tleavetr
           where codempid  = r1.codempid
             and dtework   between v_dtecycst and v_dteprien
             and codleave  = v_codleave;
        end;
        v_qtypriyr := least(v_qtypriyr_Temp,v_qtydayle);
      end if;

      if nvl(v_qtyvacat,0) + nvl(v_qtypriyr,0) > 0 then
        begin
          insert into tleavsum(codempid,dteyear,codleave,
                               typleave,staleave,qtypriyr,qtyvacat,dtecycst,dtecycen,dteeffeclv,typpayroll,codcomp,dtecreate,codcreate,dteupd,coduser)
                        values(r1.codempid,v_yrecycle,v_codleave,
                               v_typleave,v_staleave,nvl(v_qtypriyr,0),nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0),v_dtecycst,v_dtecycen,v_dteeffeclv,v_typpayroll,v_codcomp,sysdate,p_coduser,sysdate,p_coduser);
        exception when dup_val_on_index then
          update tleavsum
             set typleave    = v_typleave,
                 staleave    = v_staleave,
                 qtypriyr    = nvl(v_qtypriyr,0),
                 qtyvacat    = nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0),
                 dtecycst    = v_dtecycst,
                 dtecycen    = v_dtecycen,
                 dteeffeclv  = v_dteeffeclv,
                 typpayroll  = v_typpayroll,
                 codcomp     = v_codcomp,
                 dteupd      = sysdate,
                 coduser     = p_coduser
           where codempid    = r1.codempid
             and dteyear     = v_yrecycle
             and codleave    = v_codleave;
        end;
        p_numrec := nvl(p_numrec,0) + 1;
      else
        update tleavsum
           set qtypriyr    = 0,
               qtyvacat    = 0,
               dteupd      = sysdate,
               coduser     = p_coduser
         where codempid    = r1.codempid
           and dteyear     = v_yrecycle
           and codleave    = v_codleave;
      end if; -- nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0) > 0
      -- insert TLEAVSUM2
      v_month := 0;
      for i in 1..12 loop
        if i = 1 then
          v_dtecycstM := v_dtecycst;
          v_dtecycenM := add_months(v_dtecycst,1) - 1;
        else
          v_dtecycstM := v_dtecycenM + 1;
          v_dtecycenM := add_months(v_dtecycstM,1) - 1;
        end if;
        if r1.dteempmt <= v_dtecycenM and (v_dteeffex is null or v_dteeffex is not null and v_dteeffex > v_dtecycstM) and 
          (v_dteeffeclv between v_dtecycstM and v_dtecycenM or v_dtecycstM >= v_dteeffeclv) then
          v_month := v_month + 1;
          v_qtypriyrM := v_qtypriyr_Temp;
          if to_char(v_dtecycenM,'yyyymm') > to_char(v_dteprien,'yyyymm') then
            v_qtypriyrM := 0;
          end if;

          if v_flguse = '1' then -- Max
            v_qtyvacatM := nvl(v_qtyvacat,0);
          else -- Avg
           if v_flgresign = '1' and v_dteeffex is not null and (v_dteeffex - 1) between v_dtecycst and v_dtecycen then
              v_qtyvacatM := nvl(v_qtyvacat,0) * (v_dtecycenM - v_dtecycst) / (((v_dteeffex - 1) - v_dtecycst) + 1);
            else
              v_qtyvacatM := nvl(v_qtyvacat,0) * v_month / 12;
            end if;
          end if;
        else
          v_qtypriyrM := 0;
          v_qtyvacatM := 0;
        end if;

        if nvl(v_qtyvacatM,0) + nvl(v_qtypriyrM,0) > 0 then
          begin
            insert into tleavsum2(codempid,dteyear,monthno,codleave,
                                  dtemonth,dtecycst,dtecycen,qtydayvacat,qtypriyr,qtyvacat,codcomp,dtecreate,codcreate,dteupd,coduser)
                           values(r1.codempid,v_yrecycle,i,v_codleave,
                                  to_char(v_dtecycstM,'mm'),v_dtecycstM,v_dtecycenM,nvl(v_qtydayvacat,0),nvl(v_qtypriyrM,0),nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),v_codcomp,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            /*if trunc(v_dtecycenM) >= trunc(last_day(sysdate)) then  -- not update last month
              update tleavsum2
                 set dtemonth    = to_char(v_dtecycstM,'mm'),
                     dtecycst    = v_dtecycstM,
                     dtecycen    = v_dtecycenM,
                     qtydayvacat = nvl(v_qtydayvacat,0),
                     qtypriyr    = nvl(v_qtypriyrM,0),
                     qtyvacat    = nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),
                     codcomp     = v_codcomp,
                     dteupd      = sysdate,
                     coduser     = p_coduser
               where codempid    = r1.codempid
                 and dteyear     = v_yrecycle
                 and monthno     = i
                 and codleave    = v_codleave;
            end if;*/
            if trunc(last_day(sysdate)) <= trunc(v_dtecycenM) then
              update tleavsum2
                 set dtemonth    = to_char(v_dtecycstM,'mm'),
                     dtecycst    = v_dtecycstM,
                     dtecycen    = v_dtecycenM,
                     qtydayvacat = nvl(v_qtydayvacat,0),
                     qtypriyr    = nvl(v_qtypriyrM,0),
                     qtyvacat    = nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),
                     codcomp     = v_codcomp,
                     dteupd      = sysdate,
                     coduser     = p_coduser
               where codempid    = r1.codempid
                 and dteyear     = v_yrecycle
                 and monthno     = i
                 and codleave    = v_codleave;
            else
              update tleavsum2
                 set dtemonth    = to_char(v_dtecycstM,'mm'),
                     dtecycst    = v_dtecycstM,
                     dtecycen    = v_dtecycenM,
                     qtypriyr    = nvl(v_qtypriyrM,0),
                     qtyvacat    = nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),
                     codcomp     = v_codcomp,
                     dteupd      = sysdate,
                     coduser     = p_coduser
               where codempid    = r1.codempid
                 and dteyear     = v_yrecycle
                 and monthno     = i
                 and codleave    = v_codleave;
            end if;
          end;
        else
          update tleavsum2
             set qtydayvacat   = 0,
                 qtypriyr      = 0,
                 qtyvacat      = 0,
                 dteupd        = sysdate,
                 coduser       = p_coduser
           where codempid      = r1.codempid
             and dteyear       = v_yrecycle
             and monthno       = i
             and codleave      = v_codleave;
        end if; -- nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0) > 0
      end loop; -- 1..12

      --#5766 : Case Change Cycle Ex 2021 1/1/2021 - 31/12/2021 ==> 2020 11/11/2020	- 10/11/2021 TLEAVSUM,2 Have 2 Year 2021 and 2020
--<< user22 : 17/01/2023 : ST11 ||    
      std_al.cycle_leave(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_codleave,sysdate,v_yrecycle2,v_dtecycst2,v_dtecycen2);
      delete tleavsum
       where codempid   = r1.codempid
         and dteyear    > v_yrecycle2
         and codleave   = v_codleave;
      delete tleavsum2
       where codempid   = r1.codempid
         and dteyear    > v_yrecycle2
         and codleave   = v_codleave;
-->> user22 : 17/01/2023 : ST11 ||
      --
      <<main_emp>>
      null;
      begin
        insert into tmthend(codcomp,dayeupd,codcreate,coduser,dtecreate,dteupd)
                     values(r1.codcomp,p_dtecal,p_coduser,p_coduser,sysdate,sysdate);
      exception when dup_val_on_index then
        update tmthend
           set dayeupd   = p_dtecal,
               codcreate = p_coduser,
               coduser   = p_coduser,
               dteupd    = sysdate
         where codcomp   = r1.codcomp;
      end;
    end loop; -- c_temploy1 loop
    commit;
  end;
  --
  function entitlement_round(p_qtyvacat in number,p_typround in varchar2) return number is
    v_qtyvacat  number := p_qtyvacat;
  begin
    if v_qtyvacat is null then
      return null;
    end if;
    --
    if p_typround = '10' then --10 - ?????????
      v_qtyvacat := round(v_qtyvacat,10);
    elsif p_typround = '15' then --15 - ???????? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.25 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) < 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '20' then --20 - ???????? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.5 then
          v_qtyvacat := trunc(v_qtyvacat);
        else
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '25' then --25 - ???????? ???? 1 ???
      v_qtyvacat := trunc(v_qtyvacat);
    elsif p_typround = '30' then --30 - ?????????? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) <= 0.25 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) <= 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        elsif mod(v_qtyvacat,1) <= 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '35' then --35 - ?????????? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) <= 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '40' then --40 - ?????????? ???? 1 ???
      v_qtyvacat := ceil(v_qtyvacat);
    elsif p_typround = '45' then --45 - ??????????/?? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.125 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.375 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) < 0.625 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        elsif mod(v_qtyvacat,1) < 0.875 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '50' then --50 - ??????????/?? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.25 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '55' then --55 - ??????????/?? ???? 1 ???'
      v_qtyvacat := round(v_qtyvacat);
    end if;
    --
    return(v_qtyvacat);
  end;
end HRAL82B_BATCH;



--<< user22 01/01/2020 : V10.4
/*procedure cal_process(p_codempid	in	varchar2,
												p_codcomp		in	varchar2,
												p_dtecal		in	date,
												p_coduser		in	varchar2,
												p_numrec		out number,
										    p_error     out varchar2,
										    p_err_table out varchar2) is

    v_chkreg 			varchar2(100 char);
    v_codleave    tleavecd.codleave%type;
    v_qtyavgwk		tcontral.qtyavgwk%type;
    v_codcompy    tcompny.codcompy%type;
  begin
    if p_codcomp is not null then
      v_codcompy    := hcm_util.get_codcomp_level(p_codcomp,1);
    elsif p_codempid is not null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid   = p_codempid;
      exception when no_data_found then
        v_codcompy  := null;
      end;
    end if;
    --Check Data
    begin
      select codleave into v_codleave
        from tleavecd lcd, tleavcom lcm
       where staleave = 'V'
         and lcd.typleave   = lcm.typleave
         and lcm.codcompy   = v_codcompy
         and rownum  <= 1;
    exception when no_data_found then
      p_error := 'AL0038';
      return;
    end;
    --
    para_coduser := p_coduser;
    para_dtecal  := p_dtecal;
    --
    p_numrec := 0;
    index_codempid := p_codempid;
    index_codcomp  := p_codcomp;
    if para_coduser <> 'AUTOBATCH' then
      begin
        select get_numdec(numlvlst,para_coduser) numlvlst, get_numdec(numlvlen,para_coduser) numlvlen
          into para_zminlvl,para_zwrklvl
          from tusrprof
         where coduser = para_coduser;
      exception when others then null;
      end;
    end if;
    cal_privilage(p_numrec);
    p_numrec := 0; -- count only Vacation
    cal_vacation(p_numrec);
    commit;
	end;
	--

  procedure cal_privilage(p_numrec    in out number) is
    v_secur     boolean;
    v_year 			number(4);
    v_stdate 		date;
    v_endate 		date;
    v_year2			number(4);
    v_stdate2		date;
    v_endate2		date;
    v_codempid	temploy1.codempid%type;
    v_codcomp   temploy1.codcomp%type;
    v_codleave	tleavecd.codleave%type;
    v_typleave	tleavecd.typleave%type;
    v_staleave	tleavecd.staleave%type;
    v_qtypriot	tleavsum.qtypriot%type;
    v_qtydleot  tleavsum.qtydleot%type;
    v_qtyprimx	tleavsum.qtyprimx%type;
    v_qtydlemx  tleavsum.qtydlemx%type;

    cursor c_tmthend is
      select codcomp,dayeupd
        from tmthend
       where codcomp like v_codcomp||'%';

    cursor c_tleavecd is
      select codleave,typleave
        from tleavecd
       where staleave = v_staleave;

    cursor c_tlvsum is
      select *
        from tleavsum
       where dteyear  = v_year
         and codleave = v_codleave
         and codcomp  like index_codcomp||'%'
         and codempid = nvl(index_codempid,codempid)
    order by codempid;

  begin
    begin
      select codleave
        into v_codleave
        from tleavecd
       where staleave = 'C'
         and rownum <= 1;
    exception when no_data_found then
      return;
    end;
	  if index_codempid is not null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = index_codempid;
      exception when no_data_found then	null;
      end;
    else
      v_codcomp := index_codcomp;
    end if;
    --
    for r_tmthend in c_tmthend loop
      v_secur := secur_main.secur7(r_tmthend.codcomp,para_coduser);
      if v_secur or para_coduser = 'AUTOBATCH' then
        std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),null,v_codleave,r_tmthend.dayeupd,v_year,v_stdate,v_endate);
        v_year  := v_year - para_zyear;
        std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),null,v_codleave,para_dtecal,v_year2,v_stdate2,v_endate2);
        v_year2 := v_year2 - para_zyear;
        if v_year <> v_year2 then
          v_staleave := 'C';
          for r_tleavecd in c_tleavecd loop
            v_codleave := r_tleavecd.codleave;
            v_typleave := r_tleavecd.typleave;
            for r_tlvsum in c_tlvsum loop
              v_secur := secur_main.secur2(r_tlvsum.codempid,para_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
              if v_secur or para_coduser = 'AUTOBATCH' then
                v_codempid := r_tlvsum.codempid;
                if r_tlvsum.qtydayle < r_tlvsum.qtydleot then
                  v_qtypriot := r_tlvsum.qtydleot - r_tlvsum.qtydayle;
                  begin
                    insert into tleavsum(codempid,dteyear,codleave,
                                         typleave,staleave,qtypriot,qtydleot,codcomp,typpayroll,codcreate,coduser)
                                  values(v_codempid,v_year2,v_codleave,
                                         v_typleave,v_staleave,v_qtypriot,v_qtypriot,r_tlvsum.codcomp,r_tlvsum.typpayroll,para_coduser,para_coduser);
                  exception when dup_val_on_index then
                    update tleavsum
                       set qtypriot = v_qtypriot,
                           qtydleot = (nvl(qtydleot,0) - nvl(qtypriot,0)) + v_qtypriot,
                           coduser  = r_tlvsum.coduser
                     where codempid = v_codempid
                       and dteyear  = v_year2
                       and codleave = v_codleave;
                  end;
                  p_numrec := p_numrec + 1;
                end if;
              end if; -- secur
            end loop; -- for c_tlvsum
          end loop; -- for c_tleavecd
        end if; -- v_year <> v_year2 (year(dtecal) <> year(mthend))
      end if; -- v_secur or para_coduser = 'AUTOBATCH'
    end loop; -- for c_tmthend
  end;
  --

  procedure cal_vacation (p_numrec    in out number) is
    v_codempid 		temploy1.codempid%type;
    v_codcomp  		temploy1.codcomp%type;
    o_codcomp  		temploy1.codcomp%type;
    v_typpayroll	temploy1.typpayroll%type;
    v_codleave    tleavecd.codleave%type;
    v_typleave		tleavecd.typleave%type;
    v_staleave		tleavecd.staleave%type;
    v_mthend			tmthend.dayeupd%type;
    v_svyre  			number(4);
    v_flgfound    boolean;
    v_qtyvacat 		tleavsum.qtyvacat%type;
    v_qtypriyr 		tleavsum.qtypriyr%type;
    v_dteeffec		date;
    v_year 				number(4);
    v_stdate 			date;
    v_endate 			date;
    v_year2				number(4);
    v_stdate2			date;
    v_endate2			date;
    v_secur       boolean;

    cursor c_temploy1 is
      select codempid,codcomp,typpayroll,numlvl
        from temploy1
       where codcomp  like index_codcomp||'%'
         and codempid = nvl(index_codempid,codempid)
         and staemp   <> '0'
    order by codcomp,codempid;

    cursor c_tleavsum is
      select qtydayle,qtyvacat,rowid
        from tleavsum
       where codempid = v_codempid
         and dteyear  = v_svyre
         and codleave = v_codleave;

    cursor c_tmthend is
      select dayeupd,rowid
        from tmthend
       where codcomp = v_codcomp;

  begin
    begin
      select codleave,typleave,staleave
        into v_codleave,v_typleave,v_staleave
        from tleavecd
       where staleave = 'V'
         and rownum <= 1;
    exception when no_data_found then
      return;
    end;

    for r_temploy1 in c_temploy1 loop
      v_secur := secur_main.secur1(r_temploy1.codcomp,r_temploy1.numlvl,para_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
      if v_secur or para_coduser = 'AUTOBATCH' then
        v_codempid := r_temploy1.codempid;
        v_codcomp  := r_temploy1.codcomp;
        v_typpayroll := r_temploy1.typpayroll;
        --
        std_al.cycle_leave(hcm_util.get_codcomp_level(r_temploy1.codcomp,1),v_codempid,v_codleave,para_dtecal,v_year2,v_stdate2,v_endate2);
        v_year2 := v_year2 - para_zyear;
        --
        -- CAL THIS YEAR
        std_al.entitlement(v_codempid,v_codleave,para_dtecal,para_zyear,v_qtyvacat,v_qtypriyr,v_dteeffec);
        if v_qtyvacat > 0 then
          v_svyre := v_year2;
          v_flgfound := false;
          for r_tleavsum in c_tleavsum loop
            v_flgfound := true;
            update tleavsum
               set codcomp  = v_codcomp, 	typpayroll = v_typpayroll,
                   typleave = v_typleave,	staleave = v_staleave,
                   qtypriyr = v_qtypriyr, qtyvacat = v_qtyvacat,
                   coduser  = para_coduser
              where rowid = r_tleavsum.rowid;
          end loop;
          if not v_flgfound then
            insert into tleavsum(codempid,dteyear,codleave,
                                 typleave,staleave,qtypriyr,qtyvacat,codcomp,typpayroll,codcreate,coduser)
                          values(v_codempid,v_svyre,v_codleave,
                                 v_typleave,v_staleave,v_qtypriyr,v_qtyvacat,v_codcomp,v_typpayroll,para_coduser,para_coduser);
          end if;
          p_numrec := p_numrec + 1;
          --
          if v_codcomp <> nvl(o_codcomp,'!@#$%') then
            begin
              insert into tmthend(codcomp,dayeupd,codcreate,coduser,dtecreate,dteupd)
                           values(v_codcomp,para_dtecal,para_coduser,para_coduser,sysdate,sysdate);
            exception when dup_val_on_index then
              update tmthend
                 set dayeupd   = para_dtecal,
                     codcreate = para_coduser,
                     coduser   = para_coduser,
                     dteupd    = sysdate
               where codcomp   = v_codcomp;
            end;
            o_codcomp := v_codcomp;
          end if;
        else
          v_svyre := v_year2;
          for r_tleavsum in c_tleavsum loop
            update tleavsum
               set qtyvacat =  0,
                   coduser  = para_coduser
              where rowid = r_tleavsum.rowid;
          end loop;
        end if; -- v_qtyvacat > 0
      end if;
    end loop; -- for c_temploy1
  end;
  --

  procedure cal_payvac_yearly(p_codempid	in	varchar2,
                              p_codcomp		in	varchar2,
                              p_dtecal		in	date,
                              p_dteyrepay	in	number,
                              p_coduser		in	varchar2,
                              p_numrec		out number,
                              p_error       out varchar2,
                              p_err_table   out varchar2) is

		v_secur				boolean;
		v_flgreq			varchar2(1 char) := 'Y';
		v_codcompy			temploy1.codcomp%type;
		v_typpayroll		temploy1.typpayroll%type;
		v_codleave    	    tleavsum.codleave%type;
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
		v_qtylepay_req 	    tleavsum.qtydayle%type;
		v_amtlepay			number;
		v_amthour			number;
		v_amtday			number;
		v_amtmonth			number;
        v_found             varchar2(1) := 'Y';

    cursor c_temploy1 is
      select a.codempid,codcomp,numlvl,typpayroll
        from temploy1 a
       where a.codcomp  like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and chk_exempt(a.codempid) = 'N'
         and (exists (select b.codempid
                       from tleavsum b
                      where b.codempid = a.codempid
                        and b.dteyear  = (p_dteyrepay - para_zyear)
                        and b.codleave = v_codleave)
          or  exists (select c.codempid
                        from tpayvac c
                       where c.codempid = a.codempid
                         and c.dteyear  = (p_dteyrepay - para_zyear)
                         and c.flgreq   = v_flgreq
       									 and c.staappr  = 'P'))
    order by a.codempid;
	begin
    p_numrec := 0;
    --Check Data
		begin
			select codleave	into v_codleave
			  from tleavecd
			 where staleave = 'V'
			   and rownum   = 1;
		exception when no_data_found then
      p_error := 'AL0038';
      p_err_table := null;
      return;
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
        return;
      end;
    end if;
    --
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
    for r1 in c_temploy1 loop
      v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
      if v_secur or p_coduser = 'AUTOBATCH' then
				v_codcompy   := hcm_util.get_codcomp_level(r1.codcomp,1);
				v_typpayroll := r1.typpayroll;
				--
		    delete tpayvac
		     where codempid = r1.codempid
		       and dteyear  = (p_dteyrepay - para_zyear)
		       and flgreq   = v_flgreq
		       and staappr  = 'P';
				commit;
				--
				begin
					select nvl(qtypriyr,0),nvl(qtyvacat,0),nvl(qtydayle,0)
						into v_qtypriyr,v_qtyvacat,v_qtydayle
						from tleavsum
					 where codempid = r1.codempid
						 and dteyear  = (p_dteyrepay - para_zyear)
						 and codleave = v_codleave;
				exception when no_data_found then null;
				end;

				begin
					select nvl(sum(qtylepay),0) into v_qtylepay_req
						from tpayvac
					 where codempid	 = r1.codempid
						 and dteyear   = (p_dteyrepay - para_zyear)
						 and staappr	 = 'P';
				end;
				v_qtylepay := (v_qtyvacat - v_qtydayle) - v_qtylepay_req;
				if v_qtylepay > 0 then
					v_yrecycle := (p_dteyrepay - para_zyear);
					std_al.cycle_leave2(v_codcompy,r1.codempid,v_codleave,v_yrecycle,v_dtecycst,v_dtecycen);
						gen_income(r1.codempid,v_amthour,v_amtday,v_amtmonth);
						v_qtybalance := v_qtylepay;
						v_amtlepay   := v_qtylepay * v_amtday;
						begin
							insert into tpayvac(codempid,dteyear,dtereq,flgreq,
																	codcomp,typpayroll,
																	qtypriyr,qtyvacat,qtydayle,qtybalance,qtylepay,amtday,amtlepay,
																	dteyrepay,dtemthpay,numperiod,flgcalvac,dteappr,codappr,staappr,remarkap,codreq,
																	dtecreate,codcreate,dteupd,coduser)
													 values(r1.codempid,(p_dteyrepay - para_zyear),v_dtecycen,v_flgreq,
																	r1.codcomp,r1.typpayroll,
																	v_qtypriyr,v_qtyvacat,v_qtydayle,v_qtybalance,v_qtylepay,nvl(stdenc(round(v_amtday,2),r1.codempid,para_chken),0),nvl(stdenc(round(v_amtlepay,2),r1.codempid,para_chken),0),
																	null,null,null,'N',null,null,'P',null,get_codempid(p_coduser),
																	sysdate,p_coduser,sysdate,p_coduser);
            	p_numrec := p_numrec + 1;
            exception when dup_val_on_index then null;
						end;
					--end if; -- v_dteyrepay > 0
				end if; -- v_qtylepay > 0
			end if; -- v_secur or p_coduser = 'AUTOBATCH'
    end loop; -- c_temploy1
    commit;
  end;
  --

  procedure cal_payvac_resign(p_codempid	in	varchar2,
                              p_codcomp		in	varchar2,
                              p_dtecal		in	date,
                              p_dteyrepay	in	number,
                              p_dtemthpay	in	number,
                              p_numperiod	in	number,
                              p_coduser		in	varchar2,
                              p_numrec		out number,
                              p_error       out varchar2,
                              p_err_table   out varchar2) is

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
    cursor c_temploy1 is
      select a.codempid,codcomp,numlvl,typpayroll,dteeffex
        from temploy1 a
       where a.codcomp  like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and chk_exempt(a.codempid) = 'Y'
         and exists (select b.dteyrepay
                       from tpriodal b
                      where b.codcompy    = hcm_util.get_codcomp_level(a.codcomp,1)
                        and b.typpayroll  = a.typpayroll
                        and b.dteyrepay   =(p_dteyrepay - para_zyear)
                        and b.dtemthpay   = p_dtemthpay
                        and b.numperiod   = p_numperiod
                        and(a.dteeffex-1) between nvl(dtestrt,(a.dteeffex-1)) and dteend
                        and b.codpay      in(select c.codvacat
												                       from tcontal2 c
												                      where c.codcompy  = b.codcompy
												                        and dteeffec    = (select max(dteeffec)
												                                             from tcontal2
												                                            where codcompy  = b.codcompy
												                                              and dteeffec <= sysdate)))
         and (exists (select b.codempid
                       from tleavsum b
                      where b.codempid = a.codempid
                        and b.codleave = v_codleave)
          or  exists (select c.codempid
                        from tpayvac c
                       where c.codempid = a.codempid
                         and c.flgreq   = v_flgreq
       									 and c.staappr  = 'P'))
    order by a.codempid;

	begin
    p_numrec := 0;
    --Check Data
		begin
			select codleave	into v_codleave
			  from tleavecd
			 where staleave = 'V'
			   and rownum   = 1;
		exception when no_data_found then
      p_error := 'AL0038';
      p_err_table := null;
      return;
		end;
    --
    if p_codempid is not null then
      begin
        select  'Y'
        into    v_found
        from    temploy1
        where   codempid    = p_codempid
        and     chk_exempt(codempid) = 'Y';
      exception when no_data_found then
        p_error := 'HR2107';
        p_err_table := null;
        return;
      end;
    end if;
    --
		begin
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
		end;
    --
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
    for r1 in c_temploy1 loop
      v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,p_coduser,para_zminlvl,para_zwrklvl,para_zupdsal);
      if v_secur or p_coduser = 'AUTOBATCH' then
				v_codcompy   := hcm_util.get_codcomp_level(r1.codcomp,1);
				v_typpayroll := r1.typpayroll;
				v_dteeffex   := r1.dteeffex;
				--
				begin
					select dteyear,nvl(qtypriyr,0),nvl(qtyvacat,0),nvl(qtydayle,0)
						into v_dteyear,v_qtypriyr,v_qtyvacat,v_qtydayle
						from tleavsum
					 where codempid = r1.codempid
						 and codleave = v_codleave
						 and dteyear  = (select max(dteyear)
						                   from tleavsum
															where codempid = r1.codempid
															  and codleave = v_codleave);
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
				v_qtylepay := (v_qtyvacat - v_qtydayle) - v_qtylepay_req;
				if v_qtylepay > 0 then
				--
						gen_income(r1.codempid,v_amthour,v_amtday,v_amtmonth);
						v_qtybalance := v_qtylepay;
						v_amtlepay   := v_qtylepay * v_amtday;
						begin
							insert into tpayvac(codempid,dteyear,dtereq,flgreq,
																	codcomp,typpayroll,
																	qtypriyr,qtyvacat,qtydayle,qtybalance,qtylepay,amtday,amtlepay,
																	dteyrepay,dtemthpay,numperiod,flgcalvac,dteappr,codappr,staappr,remarkap,codreq,
																	dtecreate,codcreate,dteupd,coduser)
													 values(r1.codempid,v_dteyear,r1.dteeffex,v_flgreq,
																	r1.codcomp,r1.typpayroll,
																	v_qtypriyr,v_qtyvacat,v_qtydayle,v_qtybalance,v_qtylepay,nvl(stdenc(round(v_amtday,2),r1.codempid,para_chken),0),nvl(stdenc(round(v_amtlepay,2),r1.codempid,para_chken),0),
																	(p_dteyrepay - para_zyear),p_dtemthpay,p_numperiod,'N',null,null,'P',null,get_codempid(p_coduser),--v_dteyrepay,v_dtemthpay,v_numperiod,'N',sysdate,get_codempid(p_coduser),'P',null,get_codempid(p_coduser),
																	sysdate,p_coduser,sysdate,p_coduser);
              p_numrec := p_numrec + 1;
            exception when dup_val_on_index then null;
						end;
					--end if; -- v_dteyrepay > 0
				end if; -- v_qtylepay > 0
			end if; -- v_secur or p_coduser = 'AUTOBATCH'
    end loop; -- c_temploy1
    commit;
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
			select a.codcomp,codempmt,stddec(amtincom1,b.codempid,para_chken),stddec(amtincom2,b.codempid,para_chken),stddec(amtincom3,b.codempid,para_chken),stddec(amtincom4,b.codempid,para_chken),stddec(amtincom5,b.codempid,para_chken),stddec(amtincom6,b.codempid,para_chken),stddec(amtincom7,b.codempid,para_chken),stddec(amtincom8,b.codempid,para_chken),stddec(amtincom9,b.codempid,para_chken),stddec(amtincom10,b.codempid,para_chken)
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
    function chk_exempt(p_codempid varchar2) return varchar2 is
        v_exempt  varchar2(1) := 'N';
    begin
        begin
            select 'Y' into v_exempt
            from  temploy1 a,ttexempt b
            where a.codempid      = p_codempid
            and   a.codempid      = b.codempid
            and   (b.dteeffec-1) >= a.dteempmt
            and   b.staupd        in ('C','U')
            and   rownum          = 1;
        exception when no_data_found then null;
        end;
        return v_exempt;
    end;*/
-->> user22 01/01/2020 : V10.4

--<< user22 22/06/2021 : V10.11
/*
create or replace package body HRAL82B_BATCH is
	procedure start_process is
		v_coduser   varchar2(50 char) := 'AUTOBATCH';
		v_msgerror  varchar2(1000 char) := null;
    v_descerr   varchar2(1000 char) := null;
		v_status    varchar2(1 char) := 'C';
		v_numrec    number;
    v_error     varchar2(10 char);
    v_err_table	varchar2(50 char);
    p_dtecall   date := sysdate;

	  cursor c_tcontrlv is
	    select codcompy
	      from tcontrlv
	  group by codcompy
	  order by codcompy;

	begin
	  --
		begin
			for r_tcontrlv in c_tcontrlv loop
      	--cal_process(null,r_tcontrlv.codcompy,trunc(sysdate),v_coduser,v_numrec,v_error,v_err_table);
        gen_vacation(null,r_tcontrlv.codcompy,trunc(sysdate),v_coduser,v_numrec);
      end loop;
		exception when others then
		  rollback;
		  v_status := 'E';
      v_descerr := substr( dbms_utility.format_error_backtrace(),1,200);
		end;
		--
		if v_status = 'C' and v_error is null then
			v_msgerror := 'Complete: '||v_numrec;
		elsif v_error is not null then
      v_msgerror := 'Error(1): '||v_error||' '||get_errorm_name(v_error,'102');
    else
			v_msgerror := substr('Error(2): '||v_numrec||' '||v_descerr,1,200);
		end if;
		--
    begin
      delete tautolog where codapp = 'HRAL82B' and dtecall = p_dtecall;
      insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
           values ('HRAL82B',p_dtecall,p_dtecall,sysdate,v_status,v_msgerror,v_coduser);
    end;
    commit;
	end;
	--
  procedure gen_vacation(p_codempid	in varchar2,
                         p_codcomp	in varchar2,
                         p_dtecal	  in date,
                         p_coduser	in varchar2,
                         p_numrec	 out number) is
    v_secur       boolean;
    v_zupdsal     varchar2(4 char);
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
    v_qtywkday		temploy1.qtywkday%type;
		v_dteempmt    temploy1.dteempmt%type;
    v_amthour		 	number := 0;
		v_amtday			number := 0;
		v_amtmth			number := 0;

    v_flgfound    boolean;
    v_codleave    tleavecd.codleave%type;
    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_yrecycle    tleavsum.dteyear%type;
    v_dtecycst    tleavsum.dtecycst%type;
    v_dtecycen    tleavsum.dtecycen%type;
    v_dtecycstM   tleavsum.dtecycst%type;
    v_dtecycenM   tleavsum.dtecycen%type;
    v_dteeffeclv  tleavsum.dteeffeclv%type;

    v_dteeffec    tcontrlv.dteeffec%type;
    v_qtyday      tcontrlv.qtyday%type;
    v_flgcal		  tcontrlv.flgcal%type;
    v_typround		tcontrlv.typround%type;
    v_flgresign		tcontrlv.flgresign%type;
    v_flguse	   	tcontrlv.flguse%type;
    v_qtylimit   	tratevac2.qtylimit%type;
    v_mthprien   	tratevac2.mthprien%type;
    v_dteprien    date;
    v_svmth       number;
    v_svyre       number;
    v_svday       number;
    v_desc        tratevac.syncond%type;
    v_stmt        varchar2(4000);
    v_numseq      tratevac.numseq%type;
    v_qtyvacat_Temp tleavsum.qtyvacat%type;
    v_qtypriyr_Temp tleavsum.qtypriyr%type;
    v_qtypriyr    tleavsum.qtypriyr%type;
    v_qtyvacat    tleavsum.qtyvacat%type;
    v_qtypriyrM   tleavsum.qtypriyr%type;
    v_qtyvacatM   tleavsum.qtyvacat%type;
    v_qtyadjvac   tleavsum.qtyadjvac%type;
    v_qtylepay    tleavsum.qtylepay%type;
    v_qtydayle    tleavsum.qtydayle%type;
    v_month       number;

    cursor c_temploy1 is
      select codempid,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl,dteempmt,qtywkday,dteeffex,staemp
        from temploy1
       where codcomp  like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
         and staemp   <> '0'
    order by codcomp,codempid;

    cursor c_tratevac is
      select numseq,syncond
        from tratevac
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
    order by numseq;

    cursor c_tratevac2 is
      select qtylwkst,qtylwken,qtymin,qtymax,flgcal,qtylimit,qtywkbeg,mthprien
        from tratevac2
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
         and v_svmth between qtylwkst and qtylwken
    order by qtylwkst;
  begin
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    for r1 in c_temploy1 loop
      if p_coduser <> 'AUTOBATCH' then
        v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          goto main_emp;
        end if;
      end if;
      v_dteempmt := r1.dteempmt - nvl(r1.qtywkday,0);
      v_codcomp  := r1.codcomp;
      begin
        select a.codleave,a.typleave,a.staleave
          into v_codleave,v_typleave,v_staleave
          from tleavecd a, tleavcom b
         where a.typleave = b.typleave
           and a.staleave = 'V'
           and b.codcompy = hcm_util.get_codcomp_level(r1.codcomp,1);
      exception when no_data_found then goto main_emp;
      end;
      --
      std_al.cycle_leave(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_codleave,p_dtecal,v_yrecycle,v_dtecycst,v_dtecycen);
      if r1.dteeffex <= v_dtecycst then
        delete tleavsum  where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
        delete tleavsum2 where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
        goto main_emp;
      end if;
      -- ##5452
      --v_flgfound := hral56b_batch.check_condition_leave(r1.codempid,v_codleave,p_dtecal,'1');
      --if not v_flgfound then
      --  update tleavsum  set qtypriyr = 0, qtyvacat = 0 where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
      --  update tleavsum2 set qtypriyr = 0, qtyvacat = 0 where codempid = r1.codempid and dteyear = v_yrecycle and codleave = v_codleave;
      --  goto main_emp;
      --end if;
      begin
        select dteeffec,nvl(qtyday,0),flgcal,typround,nvl(flgresign,'1'),nvl(flguse,'1')
          into v_dteeffec,v_qtyday,v_flgcal,v_typround,v_flgresign,v_flguse
          from tcontrlv
         where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrlv
                            where codcompy  = hcm_util.get_codcomp_level(r1.codcomp,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then goto main_emp;
      end;
      v_svmth := 0; v_svyre := 0; v_svmth := 0; v_svday := 0;
      v_qtyvacat := 0; v_qtyvacat_Temp := 0;

      get_service_year(v_dteempmt,v_dtecycen,'Y',v_svyre,v_svmth,v_svday);
      v_svmth   := v_svmth + (v_svyre * 12);
      if v_qtyday > 0 and v_svday > v_qtyday then
        v_svmth := v_svmth + 1;
      end if;

      if v_flgcal = '2' then --not Avg
        --get_service_year(v_dteempmt,v_dtecycen,'Y',v_svyre,v_svmth,v_svday);
        --v_svmth   := v_svmth + (v_svyre * 12);
        --if v_qtyday > 0 and v_svday > v_qtyday then
        --  v_svmth := v_svmth + 1;
        --end if;
        v_codcomp := r1.codcomp; v_codpos := r1.codpos; v_numlvl := r1.numlvl; v_codjob := r1.codjob; v_codempmt := r1.codempmt; v_typemp := r1.typemp; v_typpayroll := r1.typpayroll; v_codbrlc := r1.codbrlc;v_codcalen := r1.codcalen; v_jobgrade := r1.jobgrade; v_codgrpgl := r1.codgrpgl; v_dteempmt := r1.dteempmt;
        for r2 in c_tratevac loop
          v_flgfound  := true;
          if r2.syncond is not null then
            v_desc := r2.syncond;
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
            v_desc := replace(v_desc,'TEMPLOY1.DTEEMPMT','to_date('''||to_char(v_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
            v_stmt := 'select count(*) from dual where '||v_desc;
            v_flgfound := execute_stmt(v_stmt);
          end if;
          if v_flgfound then
            v_numseq    := r2.numseq;
            for r3 in c_tratevac2 loop
              v_qtylimit  := nvl(r3.qtylimit,0);
              v_mthprien  := nvl(r3.mthprien,0);
              v_dteeffeclv := add_months(r1.dteempmt,nvl(r3.qtywkbeg,0));
              if r3.flgcal = '1' then
                v_qtyvacat := r3.qtymin +(((r3.qtymax - r3.qtymin) * (v_svmth - r3.qtylwkst)) / (r3.qtylwken - r3.qtylwkst));
              else
                v_qtyvacat := r3.qtymax;
              end if;
              exit;
            end loop; -- c_tratevac2 loop
            exit;
          end if;
        end loop; -- c_tratevac loop
      else --v_flgcal = '1' --Avg
        for i in 1..12 loop
          if i = 1 then
            v_dtecycstM := v_dtecycst;
            v_dtecycenM := add_months(v_dtecycst,1) - 1;
          else
            v_dtecycstM := v_dtecycenM + 1;
            v_dtecycenM := add_months(v_dtecycstM,1) - 1;
          end if;
          if sysdate >= v_dtecycstM and r1.dteempmt <= v_dtecycenM then
            v_dtemovemt := v_dtecycenM;
            std_al.get_movemt(r1.codempid,v_dtemovemt,'C','U',
                              v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                              v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                              v_amthour,v_amtday,v_amtmth);

            --v_svmth := 0; v_svyre := 0; v_svday := 0;
            --get_service_year(v_dteempmt,v_dtecycenM,'Y',v_svyre,v_svmth,v_svday);
            --v_svmth   := v_svmth + (v_svyre * 12);
            --if v_qtyday > 0 and v_svday > v_qtyday then
            --  v_svmth := v_svmth + 1;
            --end if;
            for r2 in c_tratevac loop
              v_flgfound  := true;
              if r2.syncond is not null then
                v_desc := r2.syncond;
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
                v_desc := replace(v_desc,'TEMPLOY1.DTEEMPMT','to_date('''||to_char(v_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
                v_stmt := 'select count(*) from dual where '||v_desc;
                v_flgfound := execute_stmt(v_stmt);
              end if;
              if v_flgfound then
                v_numseq    := r2.numseq;
                for r3 in c_tratevac2 loop
                  v_qtylimit  := nvl(r3.qtylimit,0);
                  v_mthprien  := nvl(r3.mthprien,0);
                  v_dteeffeclv := add_months(r1.dteempmt,nvl(r3.qtywkbeg,0));
                  if r3.flgcal = '1' then
                    v_qtyvacat_Temp := r3.qtymin +(((r3.qtymax - r3.qtymin) * (v_svmth - r3.qtylwkst)) / (r3.qtylwken - r3.qtylwkst));
                  else
                    v_qtyvacat_Temp := r3.qtymax;
                  end if;
                  exit;
                end loop; -- c_tratevac2 loop
                exit;
              end if;
            end loop; -- c_tratevac loop
          else
            null;--v_qtyvacat_Temp := v_qtyvacat_Temp;
          end if; -- sysdate >= v_dtecycstM and r1.dteempmt <= v_dtecycenM
          --v_qtyvacat := v_qtyvacat + (v_qtyvacat_Temp/12);
          v_qtyvacat := v_qtyvacat + nvl(v_qtyvacat_Temp,0);
        end loop; -- 1..12
        v_qtyvacat := v_qtyvacat /12;
      end if;
      if v_flgresign = '1' and r1.dteeffex is not null and (r1.dteeffex - 1) between v_dtecycst and v_dtecycen then
        v_qtyvacat := (v_qtyvacat * ((r1.dteeffex - 1) - greatest(r1.dteempmt,v_dtecycst)+ 1)) / 365;
      end if;

      begin
        select nvl(qtyadjvac,0),nvl(qtylepay,0)
          into v_qtyadjvac,v_qtylepay
          from tleavsum
         where codempid = r1.codempid
           and dteyear  = v_yrecycle
           and codleave = v_codleave;
      exception when no_data_found then v_qtyadjvac := 0; v_qtylepay := 0;
      end;
      v_qtyvacat := v_qtyvacat + v_qtyadjvac;-- #5726 : v_qtyvacat := v_qtyvacat + v_qtyadjvac - v_qtylepay;
      v_qtyvacat := entitlement_round(v_qtyvacat,v_typround);
      --
      v_qtypriyr_Temp := 0;
      if v_qtylimit > 0 then
        begin
          select nvl(qtyvacat,0) - nvl(qtydayle,0) - nvl(qtylepay,0) into v_qtypriyr_Temp-- #5726 : select nvl(qtyvacat,0) - nvl(qtydayle,0) into v_qtypriyr_Temp
            from tleavsum
           where codempid = r1.codempid
             and dteyear  = (v_yrecycle - 1)
             and codleave = v_codleave;
        exception when no_data_found then null;
        end;

        if v_qtypriyr_Temp < 0 then
          v_qtypriyr := 0;
        elsif v_qtypriyr_Temp > v_qtylimit then
          v_qtypriyr_Temp := v_qtylimit;
        end if;
      end if; -- v_qtylimit > 0

      if v_mthprien > 0 then
        v_dteprien   := to_date('1/'||v_mthprien||'/'||v_yrecycle,'dd/mm/yyyy');
        v_dteprien   := last_day(v_dteprien);
        if v_dteprien not between v_dtecycst and v_dtecycen then
          v_dteprien   := to_date('1/'||v_mthprien||'/'||(v_yrecycle+1),'dd/mm/yyyy');
          v_dteprien   := last_day(v_dteprien);
        end if;
      end if;

      -- insert TLEAVSUM
      v_qtypriyr := v_qtypriyr_Temp;
      if to_char(sysdate,'yyyymm') > to_char(v_dteprien,'yyyymm') then
        v_qtydayle := 0;
        begin
          select nvl(sum(qtyday),0) into v_qtydayle
            from tleavetr
           where codempid  = r1.codempid
             and dtework   between v_dtecycst and v_dteprien
             and codleave  = v_codleave;
        end;
        v_qtypriyr := least(v_qtypriyr_Temp,v_qtydayle);
      end if;

      if nvl(v_qtyvacat,0) + nvl(v_qtypriyr,0) > 0 then
        begin
          insert into tleavsum(codempid,dteyear,codleave,
                               typleave,staleave,qtypriyr,qtyvacat,dtecycst,dtecycen,dteeffeclv,typpayroll,codcomp,dtecreate,codcreate,dteupd,coduser)
                        values(r1.codempid,v_yrecycle,v_codleave,
                               v_typleave,v_staleave,nvl(v_qtypriyr,0),nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0),v_dtecycst,v_dtecycen,v_dteeffeclv,v_typpayroll,v_codcomp,sysdate,p_coduser,sysdate,p_coduser);
        exception when dup_val_on_index then
          update tleavsum
             set typleave   = v_typleave,
                 staleave   = v_staleave,
                 qtypriyr   = nvl(v_qtypriyr,0),
                 qtyvacat   = nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0),
                 dtecycst   = v_dtecycst,
                 dtecycen   = v_dtecycen,
                 dteeffeclv = v_dteeffeclv,
                 typpayroll = v_typpayroll,
                 codcomp    = v_codcomp,
                 dteupd     = sysdate,
                 coduser    = p_coduser
           where codempid   = r1.codempid
             and dteyear    = v_yrecycle
             and codleave   = v_codleave;
        end;
        p_numrec := nvl(p_numrec,0) + 1;
      else
        update tleavsum
           set qtypriyr   = 0,
               qtyvacat   = 0,
               dteupd     = sysdate,
               coduser    = p_coduser
         where codempid   = r1.codempid
           and dteyear    = v_yrecycle
           and codleave   = v_codleave;
      end if; -- nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0) > 0

      -- insert TLEAVSUM2
      v_month := 0;
      for i in 1..12 loop
        if i = 1 then
          v_dtecycstM := v_dtecycst;
          v_dtecycenM := add_months(v_dtecycst,1) - 1;
        else
          v_dtecycstM := v_dtecycenM + 1;
          v_dtecycenM := add_months(v_dtecycstM,1) - 1;
        end if;
        if r1.dteempmt <= v_dtecycenM and (r1.dteeffex is null or r1.dteeffex is not null and r1.dteeffex > v_dtecycstM) then
          v_month := v_month + 1;
          v_qtypriyrM := v_qtypriyr_Temp;
          if to_char(v_dtecycenM,'yyyymm') > to_char(v_dteprien,'yyyymm') then
            v_qtypriyrM := 0;
          end if;
          if v_flguse = '1' then -- Max
            v_qtyvacatM := nvl(v_qtyvacat,0);
          else -- Avg
            v_qtyvacatM := nvl(v_qtyvacat,0) * v_month / 12;
          end if;
        else
          v_qtypriyrM := 0;
          v_qtyvacatM := 0;
        end if;
        if nvl(v_qtyvacatM,0) + nvl(v_qtypriyrM,0) > 0 then
          begin
            insert into tleavsum2(codempid,dteyear,monthno,codleave,
                                  dtemonth,dtecycst,dtecycen,qtypriyr,qtyvacat,codcomp,dtecreate,codcreate,dteupd,coduser)
                           values(r1.codempid,v_yrecycle,i,v_codleave,
                                  to_char(v_dtecycstM,'mm'),v_dtecycstM,v_dtecycenM,nvl(v_qtypriyrM,0),nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),v_codcomp,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            update tleavsum2
               set dtemonth   = to_char(v_dtecycstM,'mm'),
                   dtecycst   = v_dtecycstM,
                   dtecycen   = v_dtecycenM,
                   qtypriyr   = nvl(v_qtypriyrM,0),
                   qtyvacat   = nvl(v_qtyvacatM,0)+ nvl(v_qtypriyrM,0),
                   codcomp    = v_codcomp,
                   dteupd     = sysdate,
                   coduser    = p_coduser
             where codempid   = r1.codempid
               and dteyear    = v_yrecycle
               and monthno    = i
               and codleave   = v_codleave;
          end;
        else
          update tleavsum2
             set qtypriyr   = 0,
                 qtyvacat   = 0,
                 dteupd     = sysdate,
                 coduser    = p_coduser
           where codempid   = r1.codempid
             and dteyear    = v_yrecycle
             and monthno    = i
             and codleave   = v_codleave;
        end if; -- nvl(v_qtyvacat,0)+ nvl(v_qtypriyr,0) > 0
      end loop; -- 1..12

      --#5766 : Case Change Cycle Ex 2021 1/1/2021 - 31/12/2021 ==> 2020 11/11/2020	- 10/11/2021 TLEAVSUM,2 Have 2 Year 2021 and 2020
      delete tleavsum
       where codempid   = r1.codempid
         and dteyear    > v_yrecycle
         and codleave   = v_codleave;
      delete tleavsum2
       where codempid   = r1.codempid
         and dteyear    > v_yrecycle
         and codleave   = v_codleave;
      --
      <<main_emp>>
      null;
      begin
        insert into tmthend(codcomp,dayeupd,codcreate,coduser,dtecreate,dteupd)
                     values(r1.codcomp,p_dtecal,p_coduser,p_coduser,sysdate,sysdate);
      exception when dup_val_on_index then
        update tmthend
           set dayeupd   = p_dtecal,
               codcreate = p_coduser,
               coduser   = p_coduser,
               dteupd    = sysdate
         where codcomp   = r1.codcomp;
      end;
    end loop; -- c_temploy1 loop
    commit;
  end;
  --
  function entitlement_round(p_qtyvacat in number,p_typround in varchar2) return number is
    v_qtyvacat  number := p_qtyvacat;
  begin
    if v_qtyvacat is null then
      return null;
    end if;
    --
    if p_typround = '10' then --10 - ?????????
      v_qtyvacat := round(v_qtyvacat,10);
    elsif p_typround = '15' then --15 - ???????? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.25 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) < 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '20' then --20 - ???????? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.5 then
          v_qtyvacat := trunc(v_qtyvacat);
        else
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '25' then --25 - ???????? ???? 1 ???
      v_qtyvacat := trunc(v_qtyvacat);
    elsif p_typround = '30' then --30 - ?????????? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) <= 0.25 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) <= 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        elsif mod(v_qtyvacat,1) <= 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '35' then --35 - ?????????? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) <= 0.5 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '40' then --40 - ?????????? ???? 1 ???
      v_qtyvacat := ceil(v_qtyvacat);
    elsif p_typround = '45' then --45 - ??????????/?? ???? 0.25 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.125 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.375 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.25;
        elsif mod(v_qtyvacat,1) < 0.625 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        elsif mod(v_qtyvacat,1) < 0.875 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.75;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '50' then --50 - ??????????/?? ???? 0.5 ???
      if mod(v_qtyvacat,1) > 0 then
        if mod(v_qtyvacat,1) < 0.25 then
          v_qtyvacat := trunc(v_qtyvacat);
        elsif mod(v_qtyvacat,1) < 0.75 then
          v_qtyvacat := trunc(v_qtyvacat) + 0.5;
        else
          v_qtyvacat := trunc(v_qtyvacat) + 1;
        end if;
      else
        v_qtyvacat := trunc(v_qtyvacat);
      end if;
    elsif p_typround = '55' then --55 - ??????????/?? ???? 1 ???'
      v_qtyvacat := round(v_qtyvacat);
    end if;
    --
    return(v_qtyvacat);
  end;
end HRAL82B_BATCH;
*/
-->> user22 22/06/2021 : V10.11

/
