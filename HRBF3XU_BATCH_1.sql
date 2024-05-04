--------------------------------------------------------
--  DDL for Package Body HRBF3XU_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3XU_BATCH" is
  procedure start_process(p_codcomp    	varchar2,
                          p_numisr    	varchar2,
                          p_numisro	  	varchar2,
                          p_type        varchar2,--1 new , 2 renew
                          p_coduser     varchar2,
                          p_codlang     varchar2,
                          o_numrec			out number) is
    v_codempid		temploy1.codempid%type;

  begin
    hcm_secur.get_global_secur(p_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
    para_codapp    := 'HRBF3XU';
    para_codcomp   := p_codcomp;
    para_numisr    := p_numisr;
    para_numisro   := p_numisro;
    para_type      := p_type;
    para_coduser   := p_coduser;
    para_codlang   := p_codlang;
    para_codempid  := get_codempid(para_coduser);
		para_numrec    := 0;
    gen_group_emp;     -- create tprocemp
	  gen_group;         -- create tprocount
	  gen_job;           -- create Job & Process
	  -- return record
	  o_numrec := para_numrec;
  	begin
  		select nvl(sum(nvl(qtyproc,0)),0) into o_numrec
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
	  		delete tprocount
		     where codapp 	= para_codapp
		       and coduser 	= para_coduser
		       and numproc  = i;
	  		delete tprocemp
		     where codapp 	= para_codapp
		       and coduser 	= para_coduser
		       and numproc  = i;
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

    --'New'
    cursor c1_temploy1 is
      select codempid,codcomp,numlvl
        from temploy1
       where codcomp like para_codcomp||'%'
         and staemp  in ('1','3')
         and not exists(select numisr
                          from tinsrer c
                         where c.codempid = temploy1.codempid
                           and c.numisr   = para_numisr)
    order by codempid;

    --'Renew'
    cursor c1_tinsrer is
      select b.codempid,b.codcomp,b.numlvl
        from tinsrer a, temploy1 b
       where a.codempid = b.codempid
         and b.codcomp  like para_codcomp||'%'
         and b.staemp   in ('1','3')
         and a.numisr   = para_numisro
         and a.flgemp   = '1'
         and not exists(select numisr
                          from tinsrer c
                         where a.codempid = c.codempid
                           and c.numisr   = para_numisr)
    order by a.codempid;

  begin
  	delete tprocemp
  	 where codapp  = para_codapp
  	   and coduser = para_coduser;
  	commit;
  	--
    if para_type = '1' then
  		for r_emp in c1_temploy1 loop
  			v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp,para_coduser,v_numproc,r_emp.codempid);
					exception when dup_val_on_index then null;
					end;
				end if;
  		end loop;
  	elsif para_type = '2' then
  		for r_emp in c1_tinsrer loop
  			v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
  			if v_flgsecu then
		    	begin
						insert into tprocemp(codapp,coduser,numproc,codempid)
				                  values(para_codapp,para_coduser,v_numproc,r_emp.codempid);
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
														qtyproc,remark,codpay,flgproc,codempid,dtework,dtestrt,dteend,qtyerr)
	                   values(para_codapp,para_coduser,i,
	                          0,null,null,'N',null,null,null,null,null);
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
      v_stmt := 'hrbf3xu_batch.cal_start('''||para_codcomp||''','''||
                                              para_numisr||''','''||
                                              para_numisro||''','''||
                                              para_type||''','''||
                                              para_coduser||''','||
                                              para_codlang||','||
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
                      p_numisro	  	varchar2,
                      p_type        varchar2,--1 new , 2 renew
                      p_coduser     varchar2,
                      p_codlang     varchar2,
                      p_numproc     number) is
	begin
    hcm_secur.get_global_secur(p_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
    para_codapp    := 'HRBF3XU';
    para_numproc	 := p_numproc;
    para_codcomp   := p_codcomp;
    para_numisr    := p_numisr;
    para_numisro   := p_numisro;
    para_type      := p_type;
    para_coduser   := p_coduser;
    para_codlang   := p_codlang;
    para_codempid  := get_codempid(para_coduser);
    para_numrec    := 0;
		--
    if para_type = '1' then
      gen_new_insurance(para_codapp,para_coduser,para_numproc);
    elsif para_type = '2' then
      gen_renew_insurance(para_codapp,para_coduser,para_numproc);
    end if;
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

    cursor c1_temploy1 is
      select b.codempid,codcomp,codpos,typemp,numlvl,jobgrade,dteempmt,codempmt,staemp,dteoccup,typpayroll
		 	  from tprocemp a, temploy1 b
			 where a.codempid = b.codempid
	   		 and a.codapp   = para_codapp
	  		 and a.coduser  = p_coduser
	  		 and a.numproc  = p_numproc
		order by a.codempid;

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
            para_numrec := nvl(para_numrec,0) + 1;
            insert into tinsrer(codempid,numisr,
                                codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,
                                flgemp,codcomp,typpayroll,dtecreate,codcreate,dteupd,coduser)
                         values(r1.codempid,para_numisr,
                                v_codisrp,v_flgisr,v_dtehlpst,v_dtehlpen,v_amtisrp,v_codecov,v_codfcov,v_amtpmiumme,v_amtpmiumye,v_amtpmiummc,v_amtpmiumyc,
                                '1',r1.codcomp,r1.typpayroll,sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
        end if; -- v_codisrp is not null
      end if; -- secur_main
    end loop; --c1_temploy1 loop
    --
    update tprocount
       set qtyproc  = para_numrec,
           flgproc  = 'Y'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    para_numrec := 0;
    update tprocount
       set qtyproc  = para_numrec,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
-----------------------------------------
  procedure gen_renew_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number) is
    v_zupdsal     varchar2(20 char);
    v_codempid    tinsrer.codempid%type;
    v_flgisr      tisrinf.flgisr%type;
    v_flgisro     tisrinf.flgisr%type;
    v_dtehlpst    date;
    v_dtehlpen    date;
    v_label       tapplscr.desclabelt%type := get_label_name('HRBF3XU1',para_codlang,60);

    cursor c1_tinsrer is
      select a.codempid,numisr,codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,
             codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,flgemp,
             b.codcomp,b.typpayroll
        from tinsrer a, temploy1 b, tprocemp z
       where a.codempid = b.codempid
         and a.codempid = z.codempid
	   	 and z.codapp   = para_codapp
	  	 and z.coduser  = p_coduser
	  	 and z.numproc  = p_numproc
         and a.numisr   = para_numisro
         and a.flgemp   = '1'
         and not exists(select numisr
                          from tinsrer c
                         where a.codempid = c.codempid
                           and c.numisr   = para_numisr)
    order by a.codempid;

    cursor c2_tinsrdp is
      select codempid,numisr,numseq,nameinsr,typrelate,dteempdb,codsex
        from tinsrdp
       where codempid = v_codempid
         and numisr   = para_numisro
    order by numseq;

    cursor c3_tbficinf is
      select codempid,numisr,numseq,nambfisr,typrelate,ratebf
        from tbficinf
       where codempid = v_codempid
         and numisr   = para_numisro
    order by numseq;

  begin
    for r1 in c1_tinsrer loop
      if secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_codempid := r1.codempid;
        --
        begin
          select flgisr,dtehlpst,dtehlpen
            into v_flgisr,v_dtehlpst,v_dtehlpen
            from tisrinf
           where numisr = para_numisr;
        exception when others then v_flgisr := null; v_dtehlpst := null; v_dtehlpen := null;
        end;
        begin
          select flgisr
            into v_flgisro
            from tisrinf
           where numisr = para_numisro;
        exception when others then v_flgisro := null;
        end;

        begin
          para_numrec := nvl(para_numrec,0) + 1; ----
          insert into tinsrer(codempid,numisr,
                              codisrp,flgisr,dtehlpst,dtehlpen,amtisrp,codecov,codfcov,amtpmiumme,amtpmiumye,amtpmiummc,amtpmiumyc,
                              flgemp,codcomp,typpayroll,dtecreate,codcreate,dteupd,coduser)
                       values(r1.codempid,para_numisr,
                              r1.codisrp,r1.flgisr,v_dtehlpst,v_dtehlpen,r1.amtisrp,r1.codecov,r1.codfcov,r1.amtpmiumme,r1.amtpmiumye,r1.amtpmiummc,r1.amtpmiumyc,
                              r1.flgemp,r1.codcomp,r1.typpayroll,sysdate,p_coduser,sysdate,p_coduser);
        exception when dup_val_on_index then null;
        end;
        --
        begin
          insert into tchgins1 (codempid,numisr,dtechng,
                                dteeffec,flgchng,numisro,codisrp,codisrpo,flgisr,flgisro,dtehlpst,dtehlpsto,dtehlpen,dtehlpeno,
                                amtisrp,amtisrpo,codecov,codecovo,codfcov,codfcovo,
                                amtpmiumme,amtpmiummeo,amtpmiumye,amtpmiumyeo,amtpmiummc,amtpmiummco,amtpmiumyc,amtpmiumyco,
                                remark,codedit,dteedit,approvno,codappr,
                                dteappr,staappr,remarkap,dtecreate,codcreate,dteupd,coduser)
                         values(r1.codempid,para_numisr,sysdate,
                                sysdate,'1',para_numisro,r1.codisrp,r1.codisrp,v_flgisr,v_flgisro,v_dtehlpst,r1.dtehlpst,v_dtehlpen,r1.dtehlpen,
                                r1.amtisrp,r1.amtisrp,r1.codecov,r1.codecov,r1.codfcov,r1.codfcov,
                                r1.amtpmiumme,r1.amtpmiumme,r1.amtpmiumye,r1.amtpmiumye,r1.amtpmiummc,r1.amtpmiummc,r1.amtpmiumyc,r1.amtpmiumyc,
                                v_label,para_codempid,sysdate,1,para_codempid,
                                sysdate,'Y',null,sysdate,p_coduser,sysdate,p_coduser);
        exception when dup_val_on_index then null;
        end;
        --
        for r2 in c2_tinsrdp loop
          begin ----
            insert into tinsrdp(codempid,numisr,numseq,nameinsr,typrelate,dteempdb,codsex,
                                dtecreate,codcreate,dteupd,coduser)
                           values(r2.codempid,para_numisr,r2.numseq,r2.nameinsr,r2.typrelate,r2.dteempdb,r2.codsex,
                                  sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;

          begin
            insert into tchgins2(codempid,numisr,dtechng,numseq,
                                 flgchng,nameinsr,typrelate,dteempdb,codsex,
                                 dtecreate,codcreate,dteupd,coduser)
                           values(r2.codempid,para_numisr,sysdate,r2.numseq,
                                  '1',r2.nameinsr,r2.typrelate,r2.dteempdb,r2.codsex,
                                  sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
        end loop;
        --
        for r3 in c3_tbficinf loop
          begin ----
            insert into tbficinf(codempid,numisr,numseq,nambfisr,typrelate,ratebf,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r3.codempid,para_numisr,r3.numseq,r3.nambfisr,r3.typrelate,r3.ratebf,
                                 sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;

          begin
            insert into tchgins3(codempid,numisr,dtechng,numseq,
                                 nambfisr,typrelate,ratebf,flgchng,dtecreate,codcreate,dteupd,coduser)
                          values(r3.codempid,para_numisr,sysdate,r3.numseq,
                                 r3.nambfisr,r3.typrelate,r3.ratebf,'1',sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
        end loop;
      end if; -- secur_main
    end loop; --c1_tinsrer loop
    ----
    update tprocount
         set qtyproc  = para_numrec,
             flgproc  = 'Y'
       where codapp 	= p_codapp
         and coduser 	= p_coduser
         and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    para_numrec := 0;
    update tprocount
       set qtyproc  = para_numrec,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
end;

/
