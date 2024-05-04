--------------------------------------------------------
--  DDL for Package Body HRBF3YU_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3YU_BATCH" is
  procedure start_process(p_codcomp    	varchar2,
                          p_numisr    	varchar2,
                          p_month	 	    number,
                          p_year        number,
                          p_coduser     varchar2,
                          p_lang         varchar2,
                          o_numrec1			out number,
                          o_numrec2			out number,
                          o_numrec3			out number) is
    v_codempid		temploy1.codempid%type;

  begin
    global_v_lang := p_lang;
    hcm_secur.get_global_secur(p_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
    para_codapp    := 'HRBF3YU';
    para_codcomp   := p_codcomp;
    para_numisr    := p_numisr;
    para_month     := p_month;
    para_year      := p_year;
    para_coduser   := p_coduser;
		para_numrec    := 0;
    --
    gen_group_emp;     -- create tprocemp
	  gen_group;         -- create tprocount
	  gen_job;           -- create Job & Process

  	begin
  		select sum(nvl(qtyproc,0)),sum(nvl(qtyproc2,0)),sum(nvl(qtyproc3,0))
        into o_numrec1,o_numrec2,o_numrec3
  		  from tprocount
	     where codapp 	= para_codapp
	       and coduser 	= para_coduser;
  	end;
    for i in 1..para_numproc loop
			begin
	  		select codempid into v_codempid
	  		  from tprocount
		     where codapp 	= para_codapp
		       and coduser 	= para_coduser
		       and numproc  = i
		       and flgproc  = 'E';
			exception when no_data_found then null;
	  		/*delete tprocount
		     where codapp 	= para_codapp
		       and coduser 	= para_coduser
		       and numproc  = i;
	  		delete tprocemp
		     where codapp 	= para_codapp
		       and coduser 	= para_coduser
		       and numproc  = i;*/
	  	end;
    end loop;
    commit;
  end;
-----------------------------------------
  procedure gen_group_emp is -- create tprocemp
  	v_numproc		number := 99;
  	v_zupdsal		varchar2(50);
  	v_flgsecu		boolean;
  	v_cnt				number;
  	v_rownumst	number;
  	v_rownumen	number;

    cursor c1_ttpminf is
      select codempid from(
        select codempid
          from ttpminf
         where codcomp         like para_codcomp||'%'
           and nvl(flgbf,'N')  = 'N'
           and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
           and codtrn in (select codcodec
										        from tcodmove
											 	   where typmove in ('1','2'))
           and not exists (select codempid
                             from tinsrer
                            where codempid = ttpminf.codempid)
      union
        select codempid
          from ttpminf
         where codcomp         like para_codcomp||'%'
           and nvl(flgbf,'N')  = 'N'
           and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
           and codtrn in (select codcodec
										        from tcodmove
											 	   where typmove in ('6'))
           and exists (select codempid
                         from tinsrer
                        where codempid = ttpminf.codempid
                          and numisr   = para_numisr)
      union
        select codempid
          from ttpminf
         where codcomp         like para_codcomp||'%'
           and nvl(flgbf,'N')  = 'N'
           and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
           and codtrn in (select codcodec
										        from tcodmove
											 	   where typmove in ('M')))
      order by codempid;

  begin
  	delete tprocemp
  	 where codapp  = para_codapp
  	   and coduser = para_coduser;
  	commit;
  	--
    for r_emp in c1_ttpminf loop
      v_flgsecu := secur_main.secur2(r_emp.codempid,para_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        begin
          insert into tprocemp(codapp,coduser,numproc,codempid)
                        values(para_codapp,para_coduser,v_numproc,r_emp.codempid);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;
		commit;

		-- change numproc
  	begin
  		select count(*) into v_cnt
  		  from tprocemp
  		 where codapp  = para_codapp
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
	   		 where codapp  = para_codapp
	  		   and coduser = para_coduser
	  		   and numproc = v_numproc
	  		   and rownum  between v_rownumst and v_rownumen;
	  	end loop;
	  end if;
	  commit;
  end;
-----------------------------------------
  procedure gen_group is     -- create tprocount
  v_cnt		number := 0;
  begin
  	begin
  		select count(distinct(numproc)) into v_cnt
  		  from tprocemp
  		 where codapp  = para_codapp
  		   and coduser = para_coduser;
  	end;

  	delete tprocount
  	 where codapp  = para_codapp
  	   and coduser = para_coduser; commit;
    for i in 1..v_cnt loop
			insert into tprocount(codapp,coduser,numproc,
														qtyproc,qtyproc2,qtyproc3,remark,codpay,flgproc,codempid,dtework,dtestrt,dteend,qtyerr)
	                   values(para_codapp,para_coduser,i,
	                          0,0,0,null,null,'N',null,null,null,null,null);
    end loop;
    commit;
  end;
-----------------------------------------
  procedure gen_job is       -- create Job & Process
		v_stmt			varchar2(1000);
		v_interval	varchar2(50);
		v_finish		varchar2(1);

		type a_number is table of number index by binary_integer;
  		 a_jobno	a_number;
  begin
		for i in 1..para_numproc loop
      v_stmt := 'hrbf3yu_batch.cal_start('''||para_codcomp||''','''||
                                              para_numisr||''','||
                                              para_month||','||
                                              para_year||','''||
                                              para_coduser||''','||
                                              i||');';
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
-----------------------------------------
  procedure cal_start(p_codcomp    	varchar2,
                      p_numisr    	varchar2,
                      p_month	 	    number,
                      p_year        number,
                      p_coduser     varchar2,
                      p_numproc     number) is
	begin
    global_v_codempid   := get_codempid(p_coduser);
    global_v_coduser    := p_coduser;
    hcm_secur.get_global_secur(p_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
    para_codapp    := 'HRBF3YU';
    para_numproc	 := p_numproc;
    para_codcomp   := p_codcomp;
    para_numisr    := p_numisr;
    para_month     := p_month;
    para_year      := p_year;
    para_coduser   := p_coduser;
		para_numrec    := 0;
		--
    gen_new_insurance(para_codapp,para_coduser,para_numproc);
    gen_resign_insurance(para_codapp,para_coduser,para_numproc);
    gen_movement_insurance(para_codapp,para_coduser,para_numproc);
	end;
-----------------------------------------
  procedure gen_new_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number) is
    v_flgfound    boolean;
    v_desc        tisrpinf.condisrp%type;
    v_stmt        varchar2(4000);
    v_flgisr      tisrinf.flgisr%type;
    v_codisrp     tisrpinf.codisrp%type;
    v_amtisrp     tisrpinf.amtisrp%type;
    v_dtehlpst    date;
    v_dtehlpen    date;
    v_zupdsal     varchar2(20 char);
    v_agework     number;
    v_dtemovemt   date;
    v_codempid		temploy1.codempid%type;
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
		v_amthour		 	number;
		v_amtday			number;
		v_amtmth			number;
    v_amtpmiummt  tisrpre.amtpmiummt%type;
    v_amtpmiumyr  tisrpre.amtpmiumyr%type;
    v_pctpmium    tisrpre.pctpmium%type;
    v_amtpmiumme	tinsrer.amtpmiumme%type;
    v_amtpmiumye	tinsrer.amtpmiumye%type;
    v_amtpmiummc	tinsrer.amtpmiummc%type;
    v_amtpmiumyc	tinsrer.amtpmiumyc%type;
    v_codecov     tisrpinf.codecov%type;
    v_codfcov     tisrpinf.codfcov%type;
    v_numrec      number := 0;

    cursor c1_temploy1 is
      select b.codempid,b.codcomp,b.codpos,b.typemp,b.numlvl,b.jobgrade,b.dteempmt,b.codempmt,b.staemp,b.dteoccup,b.typpayroll,a.rowid
        from ttpminf a, temploy1 b, tprocemp z
       where a.codempid = b.codempid
         and z.codempid = b.codempid
	   		 and z.codapp   = p_codapp
	  		 and z.coduser  = p_coduser
	  		 and z.numproc  = p_numproc
         and a.codcomp  like para_codcomp||'%'
         and nvl(flgbf,'N')  = 'N'
         and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
         and codtrn in (select codcodec
                          from tcodmove
                         where typmove in ('1','2'))
         and not exists(select codempid
                          from tinsrer
                         where codempid = a.codempid)
    order by b.codempid;

    cursor c2_tisrpinf is
      select codisrp,amtisrp,codecov,codfcov,condisrp
        from tisrpinf
       where numisr   = para_numisr
    order by codisrp;

  begin
    for r1 in c1_temploy1 loop
      if secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_flgfound := false;
        v_codisrp  := null;
        v_amtisrp  := null;
        v_codecov  := null;
        v_codfcov  := null;
        v_codempid := r1.codempid;
        for r2 in c2_tisrpinf loop
          v_flgfound := true;
          if r2.condisrp is not null then
            v_agework := trunc(months_between(sysdate,r1.dteempmt));
            std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                              v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                              v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                              v_amthour,v_amtday,v_amtmth);
            --
            v_desc := r2.condisrp;
            v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||r1.codcomp||'''');
            v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r1.typemp||'''');
            v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||r1.codpos||'''');
            v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
            v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||r1.jobgrade||'''');
            v_desc := replace(v_desc,'TEMPLOY1.QTYWKDAY',v_agework);
            v_desc := replace(v_desc,'TEMPLOY1.AMTINCOM1',v_amtmth);
            v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||r1.codempmt||'''');
            v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||r1.staemp||'''');
            v_stmt := 'select count(*) from dual where '||v_desc;
            v_flgfound := execute_stmt(v_stmt);
          end if;
          if v_flgfound then
            v_codisrp := r2.codisrp;
            v_amtisrp := r2.amtisrp;
            v_codecov := r2.codecov;
            v_codfcov := r2.codfcov;
            exit;
          end if;
        end loop;
        if v_codisrp is not null then null;
          begin
            select flgisr,dtehlpst,dtehlpen
              into v_flgisr,v_dtehlpst,v_dtehlpen
              from tisrinf
             where numisr = para_numisr;
          exception when others then v_flgisr := null; v_dtehlpst := null; v_dtehlpen := null;
          end;
          begin
            select amtpmiummt,amtpmiumyr,pctpmium
              into v_amtpmiummt,v_amtpmiumyr,v_pctpmium
              from tisrpre
             where numisr    = para_numisr
               and codisrp   = v_codisrp
               and coddepen  = 'E';
          exception when others then v_amtpmiummt := null; v_amtpmiumyr := null; v_pctpmium := null;
          end;
          --
          v_amtpmiumme := 0; v_amtpmiumye := 0; v_amtpmiummc := 0; v_amtpmiumyc := 0;
          if v_flgisr = '1' then
            v_amtpmiumme := v_amtpmiummt * (v_pctpmium / 100);
            v_amtpmiummc := v_amtpmiummt - v_amtpmiumme;
          elsif v_flgisr = '4' then
            v_amtpmiumye := v_amtpmiumyr * (v_pctpmium / 100);
            v_amtpmiumyc := v_amtpmiumyr - v_amtpmiumye;
          end if;
          --
          if r1.staemp = '1' then
            v_dtehlpst := greatest(r1.dteempmt,v_dtehlpst);
          elsif r1.staemp = '3' then
            v_dtehlpst := greatest(r1.dteoccup,v_dtehlpst);
          end if;
          begin
            v_numrec := nvl(v_numrec,0) + 1;
            insert into tinsrer(codempid,numisr,
                                codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,
                                flgemp,codcomp,typpayroll,dtecreate,codcreate,dteupd,coduser)
                         values(r1.codempid,para_numisr,
                                v_codisrp,v_flgisr,v_dtehlpst,v_dtehlpen,v_amtisrp,v_codecov,v_codfcov,v_amtpmiumme,v_amtpmiumye,v_amtpmiummc,v_amtpmiumyc,
                                '1',r1.codcomp,r1.typpayroll,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
          --
          update ttpminf
             set flgbf = 'Y'
           where rowid = r1.rowid;
        end if; -- v_codisrp is not null
      end if; -- secur_main
    end loop; --c1_temploy1 loop
    --
    update tprocount
       set qtyproc  = v_numrec,
           flgproc  = 'Y'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    v_numrec := 0;
    update tprocount
       set qtyproc  = v_numrec,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
-----------------------------------------
  procedure gen_resign_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number) is
    v_numrec        number := 0;
    v_zupdsal       varchar2(20 char);
    v_codempid      tinsrer.codempid%type;
    v_numisr        tisrinf.numisr%type;
    v_flgisr        tisrinf.flgisr%type;
    v_dtehlpst      date;
    v_dtehlpen      date;
    v_label         tapplscr.desclabelt%type := get_label_name('HRBF3YU1',global_v_lang,100);--J- Jaturong plasae chaeck 02/09/2020
    v_approvno      number;
    v_error         varchar2(2000);
    v_rowid         rowid;

    cursor c1_temploy1 is
      select b.codempid,b.codcomp,b.codpos,b.typemp,b.numlvl,b.jobgrade,b.dteempmt,b.codempmt,b.staemp,b.dteoccup,b.typpayroll,a.rowid,a.dteeffec
        from ttpminf a, temploy1 b, tprocemp z
       where a.codempid = b.codempid
         and z.codempid = b.codempid
	   		 and z.codapp   = p_codapp
	  		 and z.coduser  = p_coduser
	  		 and z.numproc  = p_numproc
         and a.codcomp  like para_codcomp||'%'
         and nvl(flgbf,'N')  = 'N'
         and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
         and codtrn in (select codcodec
                          from tcodmove
                         where typmove in ('6'))
         and exists (select codempid
                       from tinsrer
                      where codempid = a.codempid
                        and numisr   = para_numisr)
    order by b.codempid;

    cursor c2_tinsrer is
      select a.codempid,numisr,codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,
             codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,flgemp,
             b.codcomp,b.typpayroll
        from tinsrer a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid = v_codempid
         and a.flgemp   = '1'
    order by a.numisr;

    cursor c3_tinsrdp is
      select codempid,numisr,numseq,nameinsr,typrelate,dteempdb,codsex
        from tinsrdp
       where codempid = v_codempid
         and numisr   = v_numisr
    order by numseq;

    cursor c4_tbficinf is
      select codempid,numisr,numseq,nambfisr,typrelate,ratebf
        from tbficinf
       where codempid = v_codempid
         and numisr   = v_numisr
    order by numseq;

  begin
    for r1 in c1_temploy1 loop
      v_codempid := r1.codempid;
      if secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        for r2 in c2_tinsrer loop
          v_numisr := r2.numisr;
          begin
            insert into tchgins1 (codempid,numisr,dtechng,
                                  dteeffec,flgchng,numisro,codisrp,codisrpo,flgisr,flgisro,dtehlpst,dtehlpsto,dtehlpen,dtehlpeno,
                                  amtisrp,amtisrpo,codecov,codecovo,codfcov,codfcovo,
                                  amtpmiumme,amtpmiummeo,amtpmiumye,amtpmiumyeo,amtpmiummc,amtpmiummco,amtpmiumyc,amtpmiumyco,
                                  remark,codedit,dteedit,approvno,codappr,
                                  dteappr,staappr,remarkap,dtecreate,codcreate,dteupd,coduser)
                           values(r2.codempid,r2.numisr,trunc(sysdate),
                                  trunc(sysdate),'2',r2.numisr,null,r2.codisrp,null,r2.flgisr,null,r2.dtehlpst,(r1.dteeffec - 1) /*null*/,r2.dtehlpen,
                                  null,r2.amtisrp,null,r2.codecov,null,r2.codfcov,
                                  null,r2.amtpmiumme,null,r2.amtpmiumye,null,r2.amtpmiummc,null,r2.amtpmiumyc,
                                  v_label||' '||to_char(r1.dteeffec,'dd/mm/yyyy'),null,null,null,null,
                                  null,'P',null,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
          --
          for r3 in c3_tinsrdp loop
            begin
              insert into tchgins2(codempid,numisr,dtechng,numseq,
                                   flgchng,nameinsr,typrelate,dteempdb,codsex,dtecreate,codcreate,dteupd,coduser)
                            values(r3.codempid,r2.numisr,trunc(sysdate),r3.numseq,
                                   '2',r3.nameinsr,r3.typrelate,r3.dteempdb,r3.codsex,sysdate,p_coduser,sysdate,p_coduser);
            exception when dup_val_on_index then null;
            end;
          end loop;  -- c3_tinsrdp
          --
          for r4 in c4_tbficinf loop
            begin
              insert into tchgins3(codempid,numisr,dtechng,numseq,
                                   nambfisr,typrelate,ratebf,flgchng,dtecreate,codcreate,dteupd,coduser)
                            values(r4.codempid,r2.numisr,trunc(sysdate),r4.numseq,
                                   r4.nambfisr,r4.typrelate,r4.ratebf,'2',sysdate,p_coduser,sysdate,p_coduser);
            exception when dup_val_on_index then null;
            end;
          end loop;  -- c4_tbficinf
          v_numrec := nvl(v_numrec,0) + 1;
          --
          update ttpminf
             set flgbf = 'Y'
           where rowid = r1.rowid;

            begin
              select rowid, nvl(approvno,0) + 1 as approvno
                into v_rowid,v_approvno
                from tchgins1
               where codempid = r2.codempid
                 and numisr = r2.numisr
                 and trunc(dtechng) = trunc(sysdate);
            exception when no_data_found then
                v_approvno := 1;
            end;
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRBF36E', r2.codempid, global_v_codempid, global_v_coduser, null, 'HRBF3YU1', 130, 'E', 'P', v_approvno, null, null,'TCHGINS1',v_rowid, '1', null);
            exception when others then
                null;
            end;
        end loop;  -- c2_tinsrer
      end if; -- secur_main
    end loop; --c1_temploy1 loop
    --
    update tprocount
       set qtyproc2 = v_numrec,
           flgproc  = 'Y'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    v_numrec := 0;
    update tprocount
       set qtyproc2 = v_numrec,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
-----------------------------------------
  procedure gen_movement_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number) is
    v_numrec      number := 0;
    v_flgfound    boolean;
    v_desc        tisrpinf.condisrp%type;
    v_stmt        varchar2(4000);
    v_flgisr      tisrinf.flgisr%type;
    v_codisrp     tisrpinf.codisrp%type;
    v_amtisrp     tisrpinf.amtisrp%type;
    v_dtehlpst    date;
    v_dtehlpen    date;
    v_zupdsal     varchar2(20 char);
    v_agework     number;
    v_dtemovemt   date;
    v_codempid		temploy1.codempid%type;
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
    v_amthour		 	number;
    v_amtday			number;
    v_amtmth			number;

    v_amtpmiummt  tisrpre.amtpmiummt%type;
    v_amtpmiumyr  tisrpre.amtpmiumyr%type;
    v_pctpmium    tisrpre.pctpmium%type;
    f_amtpmiummt  tisrpre.amtpmiummt%type;
    f_amtpmiumyr  tisrpre.amtpmiumyr%type;
    f_pctpmium    tisrpre.pctpmium%type;

    v_amtpmiumme	tinsrer.amtpmiumme%type;
    v_amtpmiumye	tinsrer.amtpmiumye%type;
    v_amtpmiummc	tinsrer.amtpmiummc%type;
    v_amtpmiumyc	tinsrer.amtpmiumyc%type;
    f_amtpmiumme	tinsrer.amtpmiumme%type;
    f_amtpmiumye	tinsrer.amtpmiumye%type;
    f_amtpmiummc	tinsrer.amtpmiummc%type;
    f_amtpmiumyc	tinsrer.amtpmiumyc%type;

    v_codecov     tisrpinf.codecov%type;
    v_codfcov     tisrpinf.codfcov%type;
    v_tinsrdp     number;
    v_label1      tapplscr.desclabelt%type := get_label_name('HRBF3YU1',global_v_lang,110);--J- Jaturong plasae chaeck 02/09/2020‘พนักงาน  ’|| get_tcodec_name(‘TCODMOVE’,cursor1codtrn,v_lang)||‘ ในวันที่  ’|| cursor.dteeffec
    v_label2      tapplscr.desclabelt%type := get_label_name('HRBF3YU1',global_v_lang,120);--J- Jaturong plasae chaeck 02/09/2020‘พนักงาน  ’|| get_tcodec_name(‘TCODMOVE’,cursor1codtrn,v_lang)||‘ ในวันที่  ’|| cursor.dteeffec

    v_approvno      number;
    v_error         varchar2(2000);
    v_rowid         rowid;

    cursor c1_temploy1 is
      --select b.codempid,b.codcomp,b.codpos,b.typemp,b.numlvl,b.jobgrade,b.dteempmt,b.codempmt,b.staemp,b.dteoccup,b.typpayroll,a.rowid,a.dteeffec,a.codtrn
      select a.codempid,a.codcomp,a.codpos,a.typemp,a.numlvl,a.jobgrade,b.dteempmt,a.codempmt,b.staemp,b.dteoccup,a.typpayroll,a.rowid,a.dteeffec,a.codtrn
        from ttpminf a, temploy1 b, tprocemp z
       where a.codempid = b.codempid
         and z.codempid = b.codempid
	   		 and z.codapp   = p_codapp
	  		 and z.coduser  = p_coduser
	  		 and z.numproc  = p_numproc
         and a.codcomp  like para_codcomp||'%'
         and nvl(flgbf,'N')  = 'N'
         and to_char(dteeffec,'yyyymm') = para_year||lpad(para_month,2,'0')
         and codtrn in (select codcodec
                          from tcodmove
                         where typmove in ('M'))
    order by b.codempid;

    cursor c2_tinsrer is
      select a.codempid,numisr,codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,
             codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,flgemp,
             b.codcomp,b.typpayroll
        from tinsrer a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid = v_codempid
         and a.numisr   = para_numisr
         and a.flgemp   = '1'
    order by a.numisr;

    cursor c3_tisrpinf is
      select codisrp,amtisrp,codecov,codfcov,condisrp
        from tisrpinf
       where numisr   = para_numisr
    order by codisrp;

  begin
    for r1 in c1_temploy1 loop
      if secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_codempid := r1.codempid;
        v_flgfound := false;
        v_codisrp  := null;
        v_amtisrp  := null;
        v_codecov  := null;
        v_codfcov  := null;
        for r2 in c2_tinsrer loop
          for r3 in c3_tisrpinf loop
            v_flgfound := true;
            if r3.condisrp is not null then
              v_agework := trunc(months_between(sysdate,r1.dteempmt));
              v_dtemovemt := r1.dteeffec;
              std_al.get_movemt(v_codempid,v_dtemovemt,'C','U',
                                v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                v_amthour,v_amtday,v_amtmth);
              --
              v_desc := r3.condisrp;
              v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||r1.codcomp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r1.typemp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||r1.codpos||'''');
              v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
              v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||r1.jobgrade||'''');
              v_desc := replace(v_desc,'TEMPLOY1.QTYWKDAY',v_agework);
              v_desc := replace(v_desc,'TEMPLOY1.AMTINCOM1',v_amtmth);
              v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||r1.codempmt||'''');
              v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||r1.staemp||'''');
              v_stmt := 'select count(*) from dual where '||v_desc;
              v_flgfound := execute_stmt(v_stmt);
            end if;
            if v_flgfound then
              v_codisrp := r3.codisrp;
              v_amtisrp := r3.amtisrp;
              v_codecov := r3.codecov;
              v_codfcov := r3.codfcov;
              exit;
            end if;
          end loop;
          if v_codisrp is not null and r2.codisrp <> v_codisrp then null;
            begin
              select flgisr,dtehlpst,dtehlpen
                into v_flgisr,v_dtehlpst,v_dtehlpen
                from tisrinf
               where numisr = para_numisr;
            exception when others then v_flgisr := null; v_dtehlpst := null; v_dtehlpen := null;
            end;
            begin
              select amtpmiummt,amtpmiumyr,pctpmium
                into v_amtpmiummt,v_amtpmiumyr,v_pctpmium
                from tisrpre
               where numisr    = para_numisr
                 and codisrp   = v_codisrp
                 and coddepen  = 'E';
            exception when others then v_amtpmiummt := null; v_amtpmiumyr := null; v_pctpmium := null;
            end;
            --
            v_amtpmiumme := 0; v_amtpmiumye := 0; v_amtpmiummc := 0; v_amtpmiumyc := 0;
            if v_flgisr = '1' then
              v_amtpmiumme := v_amtpmiummt * (v_pctpmium / 100);
              v_amtpmiummc := v_amtpmiummt - v_amtpmiumme;
            elsif v_flgisr = '4' then
              v_amtpmiumye := v_amtpmiumyr * (v_pctpmium / 100);
              v_amtpmiumyc := v_amtpmiumyr - v_amtpmiumye;
            end if;
            /*if r1.staemp = '1' then
              v_dtehlpst := greatest(r1.dteempmt,v_dtehlpst);
            elsif r1.staemp = '3' then
              v_dtehlpst := greatest(r1.dteoccup,v_dtehlpst);
            end if;*/
            -- family
            select count(codempid)
              into v_tinsrdp
              from tinsrdp
             where codempid = v_codempid
               and numisr   = para_numisr;

            if v_tinsrdp > 0 then -- family
              begin
                select amtpmiummt,amtpmiumyr,pctpmium
                  into f_amtpmiummt,f_amtpmiumyr,f_pctpmium
                  from tisrpre
                 where numisr    = para_numisr
                   and codisrp   = v_codisrp
                   and coddepen  = 'F';
              exception when no_data_found then f_amtpmiummt := null; f_amtpmiumyr := null; f_pctpmium := null;
              end;

              if f_pctpmium is not null then
                f_amtpmiumme := 0; f_amtpmiumye := 0; f_amtpmiummc := 0; f_amtpmiumyc := 0;
                if v_flgisr = '1' then
                  f_amtpmiumme := f_amtpmiummt * (f_pctpmium / 100);
                  f_amtpmiummc := f_amtpmiummt - f_amtpmiumme;
                elsif v_flgisr = '4' then
                  f_amtpmiumye := f_amtpmiumyr * (f_pctpmium / 100);
                  f_amtpmiumyc := f_amtpmiumyr - f_amtpmiumye;
                end if;
                --
                v_amtpmiumme := nvl(v_amtpmiumme,0) + (nvl(f_amtpmiumme,0) * v_tinsrdp);
                v_amtpmiummc := nvl(v_amtpmiummc,0) + (nvl(f_amtpmiummc,0) * v_tinsrdp);
                v_amtpmiumye := nvl(v_amtpmiumye,0) + (nvl(f_amtpmiumye,0) * v_tinsrdp);
                v_amtpmiumyc := nvl(v_amtpmiumyc,0) + (nvl(f_amtpmiumyc,0) * v_tinsrdp);
              end if;  --f_pctpmium is not null
            end if;  --v_tinsrdp > 0
            --
            begin
              insert into tchgins1 (codempid,numisr,dtechng,
                                    dteeffec,flgchng,numisro,codisrp,codisrpo,flgisr,flgisro,dtehlpst,dtehlpsto,dtehlpen,dtehlpeno,
                                    amtisrp,amtisrpo,codecov,codecovo,codfcov,codfcovo,
                                    amtpmiumme,amtpmiummeo,amtpmiumye,amtpmiumyeo,amtpmiummc,amtpmiummco,amtpmiumyc,amtpmiumyco,
                                    remark,codedit,dteedit,approvno,codappr,
                                    dteappr,staappr,remarkap,dtecreate,codcreate,dteupd,coduser)
                             values(r2.codempid,r2.numisr,trunc(sysdate),
                                    trunc(sysdate),'3',r2.numisr,v_codisrp,r2.codisrp,v_flgisr,r2.flgisr,v_dtehlpst,r2.dtehlpst,v_dtehlpen,r2.dtehlpen,
                                    v_amtisrp,r2.amtisrp,v_codecov,r2.codecov,v_codfcov,r2.codfcov,
                                    v_amtpmiumme,r2.amtpmiumme,v_amtpmiumye,r2.amtpmiumye,v_amtpmiummc,r2.amtpmiummc,v_amtpmiumyc,r2.amtpmiumyc,
                                    v_label1||' '||get_tcodec_name('TCODMOVE',r1.codtrn,'102')||' '||v_label2||' '||to_char(r1.dteeffec,'dd/mm/yyyy'),null,null,null,null,
                                    null,'P',null,sysdate,p_coduser,sysdate,p_coduser);
            exception when dup_val_on_index then null;
            end;
            v_numrec := nvl(v_numrec,0) + 1;
            --
            update ttpminf
               set flgbf = 'Y'
             where rowid = r1.rowid;

            begin
              select rowid, nvl(approvno,0) + 1 as approvno
                into v_rowid,v_approvno
                from tchgins1
               where codempid = r2.codempid
                 and numisr = r2.numisr
                 and trunc(dtechng) = trunc(sysdate);
            exception when no_data_found then
                v_approvno := 1;
            end;
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRBF36E', r2.codempid, global_v_codempid, global_v_coduser, null, 'HRBF3YU1', 130, 'E', 'P', v_approvno, null, null,'TCHGINS1',v_rowid, '1', null);
            exception when others then
                null;
            end;

          end if; -- v_codisrp is not null
        end loop; --c2_tinsrer loop
      end if; -- secur_mainsa
    end loop; --c1_temploy1 loop
    --
    update tprocount
       set qtyproc3 = v_numrec,
           flgproc  = 'Y'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    v_numrec := 0;
    update tprocount
       set qtyproc3 = v_numrec,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
end;

/
