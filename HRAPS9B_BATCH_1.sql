--------------------------------------------------------
--  DDL for Package Body HRAPS9B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPS9B_BATCH" as

  procedure start_process (p_codapp  in varchar2,
                           p_coduser in varchar2,
                           p_lang in varchar2,
                           p_numproc in number,
                           p_process in varchar2,
                           p_dteyreap in number,
                           p_numtime in number,
                           p_codcomp in varchar2,
                           p_codbon in varchar2 )  as

  begin
      b_index_dteyreap    := p_dteyreap;
      b_index_numtime     := p_numtime;
      b_index_codcomp     := p_codcomp;
      b_index_codbon      := p_codbon;
      para_numproc        := p_numproc;
      v_process           := p_process;
      v_coduser           := p_coduser;
      v_lang              := p_lang;
      para_numproc := p_numproc;
      para_codapp  := p_codapp;
      para_coduser := p_coduser;

      -- create tprocount
      gen_group;

      -- create Job
      gen_job(p_codapp, p_coduser, p_numproc, p_process, p_dteyreap, p_numtime, p_codcomp, p_codbon);
  end;


  procedure gen_group is
  begin
    delete tprocount where codapp = para_codapp and coduser = para_coduser; commit;
    for i in 1..para_numproc loop
      insert into tprocount(codapp,coduser,numproc,
                                   qtyproc,flgproc,qtyerr)
                       values(para_codapp,para_coduser,i,
                                  0,'N',0);
    end loop;
    commit;
  end;
  procedure gen_job(p_codapp  in varchar2,
                     p_coduser in varchar2,
                     p_numproc in number,
                     p_process in varchar2,
                     p_dteyreap in number,
                     p_numtime in number,
                     p_codcomp in varchar2,
                     p_codbon in varchar2)  is
    v_stmt			clob;
    v_interval	varchar2(50 char);
    v_finish		varchar2(1 char);

    type a_number is table of number index by binary_integer;
       a_jobno	a_number;

  begin
    for i in 1..para_numproc loop

      v_stmt :=' hraps9b_batch.cal_process('''||p_codapp||''','''
                                             ||p_coduser||''','''
                                             ||v_lang||''','''
                                             ||i||''','''
                                             ||p_process||''','''
                                             ||p_dteyreap||''','''
                                             ||p_numtime||''','''
                                             ||p_codcomp||''','''
                                             ||p_codbon||''');' ;

      dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
    end loop;  --for i in 1..para_numproc loop
    --
    v_finish := 'U';
    if para_numproc > 0 then
      loop
        for i in 1..para_numproc loop
          dbms_lock.sleep(10);
          begin
            select 'U' into v_finish
              from user_jobs
             where job = a_jobno(i);
            exit;
          exception when no_data_found then
            v_finish := 'Y';
          end;
        end loop;

        if v_finish = 'Y' then
          exit;
        end if;
      end loop;
    end if;
  end gen_job;

  procedure cal_process (p_codapp  in varchar2,
                         p_coduser in varchar2,
                         p_lang in varchar2,
                         p_numproc in number,
                         p_process in varchar2,
                         p_dteyreap in number,
                         p_numtime in number,
                         p_codcomp in varchar2,
                         p_codbon in varchar2 )  as

      v_flgsecu	          boolean;
      v_zupdsal           varchar2(1  char);
      v_flgfound          number := 0;
      v_codempid          varchar2(40 char);
      v_codcomp           varchar2(40 char);
      v_dtestr            date;
      v_dteend            date;
      v_typbon            varchar2(1 char);
      v_boncond           varchar2(1000 char);
      v_bonconds          varchar2(1000 char);
      v_salcond           varchar2(1000 char);
      v_salcondt          varchar2(1000 char);
      v_dteeffsal         date;
      v_formula           varchar2(1000 char);
      v_formulat          varchar2(1000 char);
      v_stment            varchar2(1000 char);
      v_ratecond          varchar2(1000 char);
      v_ratecondt         varchar2(1000 char);
      v_typsal            varchar2(1 char);
      v_grdyear           number;
      v_grdnumtime        number;
      v_daycalcu          number;
      v_grdap             varchar2(2  char);
      v_pctdbon           number;
      v_flgbonus          varchar2(1  char);
      v_flgprorate        varchar2(1  char);

      v_ratebon           number;
      v_qtybon            number;
      v_qtynbon           number;
      v_amttbon           number;
      v_amtbon            number;
      v_amtdedbon         number;
      v_codcurr           varchar2(40 char);
      v_ratechge          number;
      v_amtincom          number;
      v_poseq             number;

      v_length		    number;
      v_codpay            varchar2(40 char);
      v_amtsalcal         number;
      v_amtsalstr         number;
      v_year              number;
      v_month             number;
      v_day               number;
      v_desnote           varchar2(500 char);

      v_sqlerrm           varchar2(1000 char) ;
      v_numcond           number;
      v_qtytotnet         number;

    type arr_codincom is table of varchar2(20 char) index by binary_integer;
      v_codincom	  arr_codincom;
      v_amtincome   arr_codincom;

      cursor c_temploy is
          select a.codempid,dteempmt,codcomp,codpos,b.codcurr,
                 codempmt,typpayroll,typemp,jobgrade,numlvl,
                 stddec(amtincom1,a.codempid,v_chken) amtincom1,
                 stddec(amtincom2,a.codempid,v_chken) amtincom2,
                 stddec(amtincom3,a.codempid,v_chken) amtincom3,
                 stddec(amtincom4,a.codempid,v_chken) amtincom4,
                 stddec(amtincom5,a.codempid,v_chken) amtincom5,
                 stddec(amtincom6,a.codempid,v_chken) amtincom6,
                 stddec(amtincom7,a.codempid,v_chken) amtincom7,
                 stddec(amtincom8,a.codempid,v_chken) amtincom8,
                 stddec(amtincom9,a.codempid,v_chken) amtincom9,
                 stddec(amtincom10,a.codempid,v_chken) amtincom10
            from temploy1 a,temploy3 b,tprocemp c
           where a.codcomp  like b_index_codcomp||'%'
             and a.codempid = b.codempid
             and a.staemp   in('1','3')
             and a.codempid  = c.codempid
             and c.codapp    = p_codapp
             and c.coduser   = p_coduser
             and c.numproc   = p_numproc
          order by a.codempid;


    cursor c_thismove is
      select codcurr,
                 stddec(amtincom1,codempid,v_chken) amtincom1,
                 stddec(amtincom2,codempid,v_chken) amtincom2,
                 stddec(amtincom3,codempid,v_chken) amtincom3,
                 stddec(amtincom4,codempid,v_chken) amtincom4,
                 stddec(amtincom5,codempid,v_chken) amtincom5,
                 stddec(amtincom6,codempid,v_chken) amtincom6,
                 stddec(amtincom7,codempid,v_chken) amtincom7,
                 stddec(amtincom8,codempid,v_chken) amtincom8,
                 stddec(amtincom9,codempid,v_chken) amtincom9,
                 stddec(amtincom10,codempid,v_chken) amtincom10
        from thismove
       where codempid = v_codempid
         and dteeffec <= v_dteeffsal
         and flgadjin = 'Y'
      order by dteeffec desc,numseq desc;

      cursor c_ttbonparc is
          select ratecond,ratebon,amttbon,numseq numcond--User37 #4485 12/10/2021 ratecond,ratebon,amttbon,ratebonc,amttbonc,numseq numcond
            from ttbonparc--User37 #4485 12/10/2021 tbonparc--ttbonparc
           where codcomp  = v_codcomp
             and codbon   = b_index_codbon
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
           order by numseq;

      cursor c_tbonparc is
          select ratecond,ratebon,amttbon,ratebonc,amttbonc,numseq numcond
            from tbonparc
           where codcomp  = v_codcomp
             and codbon   = b_index_codbon
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
           order by numseq;

  begin
      b_index_dteyreap    := p_dteyreap;
      b_index_numtime     := p_numtime;
      b_index_codcomp     := p_codcomp;
      b_index_codbon      := p_codbon;
      v_process           := p_process;
      v_coduser           := p_coduser;
      v_lang              := p_lang;
      if v_process = 'HRAPS9B' then
          delete ttemprpt where codapp like 'HRAPS9MSG%' ;
          delete from ttbonus
           where dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and codbon   = b_index_codbon
             and codcomp  like b_index_codcomp||'%';
      else
          delete ttemprpt where codapp like 'HRAP54MSG%' ;
          delete from tbonus
           where dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and codbon   = b_index_codbon
             and codcomp  like b_index_codcomp||'%';

      end if;
      commit;

      b_index_sumrec := 0;
      b_index_sumerr := 0;

      begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,
                 codincom6,codincom7,codincom8,codincom9,codincom10
            into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
                 v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
            from tcontpms
           where dteeffec = (select max(dteeffec) from tcontpms);
      exception when no_data_found then
          v_codincom(1):= null; v_codincom(2) := null;
          v_codincom(3):= null; v_codincom(4) := null;
          v_codincom(5):= null; v_codincom(6) := null;
          v_codincom(7):= null; v_codincom(8) := null;
          v_codincom(9):= null; v_codincom(10):= null;
      end;
      hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,v_numlvlsalst,v_numlvlsalen);
      for r_temploy in c_temploy loop
          v_flgsecu := secur_main.secur2(r_temploy.codempid,v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,v_numlvlsalst,v_numlvlsalen);
          v_flgsecu := true;
          v_codempid := r_temploy.codempid;
          if v_flgsecu then
              if v_process = 'HRAPS9B' then
                  begin
                      select codcomp,dtestr,dteend,typbon,boncond,salcond,
                             dteeffsal,formula,typsal,grdyear,grdnumtime,
                             flgprorate
                        into v_codcomp,v_dtestr,v_dteend,v_typbon,v_boncond,v_salcond,
                             v_dteeffsal,v_formula,v_typsal,v_grdyear,v_grdnumtime,
                             v_flgprorate
                        from ttbonparh
                       where codbon   = b_index_codbon
                         and dteyreap = b_index_dteyreap
                         and numtime  = b_index_numtime
                         and r_temploy.codcomp like codcomp||'%'
                         and codcomp = (select max(codcomp) --–เช็คตรงนี้เพื่อหาหน่วยงานที่ใกล้ตัวพนักงานที่สุดเพียง 1 เงื่อนไขการจ่ายโบนัส
                                          from ttbonparh
                                         where codbon   = b_index_codbon
                                           and dteyreap = b_index_dteyreap
                                           and numtime  = b_index_numtime
                                           and r_temploy.codcomp	like codcomp||'%')
                         and rownum <= 1;
                  exception when no_data_found then
                      v_codcomp := null;
                  end;
              else

                  begin
                      select codcomp,dtestr,dteend,typbon,boncond,salcond,
                             dteeffsal,formula,typsal,grdyear,grdnumtime,
                             flgprorate
                        into v_codcomp,v_dtestr,v_dteend,v_typbon,v_boncond,v_salcond,
                             v_dteeffsal,v_formula,v_typsal,v_grdyear,v_grdnumtime,
                             v_flgprorate
                        from tbonparh
                       where codbon   = b_index_codbon
                         and dteyreap = b_index_dteyreap
                         and numtime  = b_index_numtime
                         and r_temploy.codcomp like codcomp||'%'
                         and codcomp = (select max(codcomp) --–เช็คตรงนี้เพื่อหาหน่วยงานที่ใกล้ตัวพนักงานที่สุดเพียง 1 เงื่อนไขการจ่ายโบนัส
                                          from tbonparh
                                         where codbon   = b_index_codbon
                                           and dteyreap = b_index_dteyreap
                                           and numtime  = b_index_numtime
                                           and r_temploy.codcomp	like codcomp||'%')
                         and rownum <= 1;
                  exception when no_data_found then
                      v_codcomp := null;
                  end;
              end if;

              if v_flgprorate = '1' then
                  get_service_year(r_temploy.dteempmt,v_dteend,'Y',v_year,v_month,v_day) ;
                  if v_year < 1 then
                      if r_temploy.dteempmt <= v_dtestr then --day of cal bonus
                          v_daycalcu := (v_dteend - v_dtestr) + 1;
                      else
                          v_daycalcu := (v_dteend - r_temploy.dteempmt) + 1;
                      end if;
                  end if;
              else
                  v_daycalcu := (v_dteend - v_dtestr) + 1;
              end if;

              b_var_codcompy   := hcm_util.get_codcomp_level(b_index_codcomp,1);
              v_flgfound := 0;
              if v_boncond is not null then
                  v_bonconds := v_boncond;
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.CODCOMP',''''||r_temploy.codcomp||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.AGE_POS',( months_between(sysdate,r_temploy.dteempmt)));
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.TYPEMP',''''||r_temploy.typemp||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.TYPPAYROLL',''''||r_temploy.typpayroll||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.CODPOS',''''||r_temploy.codpos||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.JOBGRADE',''''||r_temploy.jobgrade||'''');
                  v_bonconds := replace(v_bonconds,'V_HRAP51.DTEEMPMT',''''||r_temploy.dteempmt||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.DTEEMPMT',''''||r_temploy.dteempmt||'''');
                  v_bonconds := replace(v_bonconds,'V_TEMPLOY.CODEMPMT',''''||r_temploy.codempmt||'''');--User37 #4442 07/10/2021
                  v_bonconds := 'select count(*) from V_TEMPLOY where '||v_bonconds||' and codempid ='''||r_temploy.codempid||'''' ;
                  v_flgfound  := execute_qty(v_bonconds) ;
              end if;

              if v_flgfound <> 0 then
                  if r_temploy.dteempmt < v_dteend then
                      v_amtincom := r_temploy.amtincom1;
                      v_codcurr  := r_temploy.codcurr;
                      v_amtincome(1)  := r_temploy.amtincom1;
                      v_amtincome(2)  := r_temploy.amtincom2;
                      v_amtincome(3)  := r_temploy.amtincom3;
                      v_amtincome(4)  := r_temploy.amtincom4;
                      v_amtincome(5)  := r_temploy.amtincom5;
                      v_amtincome(6)  := r_temploy.amtincom6;
                      v_amtincome(7)  := r_temploy.amtincom7;
                      v_amtincome(8)  := r_temploy.amtincom8;
                      v_amtincome(9)  := r_temploy.amtincom9;
                      v_amtincome(10) := r_temploy.amtincom10;

                      begin
                          select codcurr into ptcontpm_codcurr
                           from tcontrpy
                          where codcompy = b_var_codcompy
                            and dteeffec = (select max(dteeffec)
                                              from tcontrpy
                                             where codcompy = b_var_codcompy
                                               and dteeffec <= trunc(sysdate));
                      exception when no_data_found then
                          null;
                      end;

                      for r_thismove in c_thismove loop
                          v_amtincom := r_thismove.amtincom1;
                          v_codcurr  := r_thismove.codcurr;
                          v_amtincome(1)  := r_thismove.amtincom1;
                          v_amtincome(2)  := r_thismove.amtincom2;
                          v_amtincome(3)  := r_thismove.amtincom3;
                          v_amtincome(4)  := r_thismove.amtincom4;
                          v_amtincome(5)  := r_thismove.amtincom5;
                          v_amtincome(6)  := r_thismove.amtincom6;
                          v_amtincome(7)  := r_thismove.amtincom7;
                          v_amtincome(8)  := r_thismove.amtincom8;
                          v_amtincome(9)  := r_thismove.amtincom9;
                          v_amtincome(10) := r_thismove.amtincom10;
                        exit;
                      end loop;

                      v_ratechge := 1;
                      if  v_codcurr <> nvl(ptcontpm_codcurr,'#@$') then
                          v_ratechge := get_exchange_rate(b_index_dteyreap,to_number(to_char(sysdate,'mm')),v_coduser,v_codcurr);
                      end if;
                      v_amtincom := v_amtincom * v_ratechge;

                      v_amtsalstr := 0;--user37 #4482 08/10/2021
                      if ((v_dteend - v_dtestr) + 1) <> 0 then
                          if v_salcond is not null then
                              v_length   := length(v_salcond);
                              v_salcondt := v_salcond;
                              for i in 1..v_length loop
                                  if substr(v_salcond,i,2) = '{&' then
                                      v_codpay := substr(v_salcond,i + 2,instr(substr(v_salcond,i + 2) ,'}') -1) ;
                                      for j in 1..10 loop
                                          if v_codpay = v_codincom(j) then
                                              v_amtsalcal := v_amtincome(j);
                                          end if;
                                      end loop;
                                      --v_salcondt := replace(v_salcondt,substr(v_salcondt,instr(v_salcondt,'{&'),instr( substr(v_salcondt,instr(v_salcondt,'{&')), '}') ),v_amtsalcal);
                                      v_salcondt := replace(v_salcondt,'{&'||v_codpay||'}',v_amtsalcal);
                                      --v_salcondt := replace(v_salcondt,substr(v_salcondt,instr(v_salcondt,'{'),instr( substr(v_salcondt,instr(v_salcondt,'{')), '}') ),v_amtsalcal);
                                  end if;
                              end loop;
                              v_amtsalstr := execute_sql('select '||v_salcondt||' from dual') * v_ratechge;

                        end if;
                      end if;
                      v_flgbonus := 'Y' ;
                      v_ratebon := 0;
                      v_amttbon := 0;
                      v_desnote := null;
                      if v_typbon = '1' then
                          begin
                              select grdap,pctdbon,flgbonus,qtytotnet into v_grdap,v_pctdbon,v_flgbonus,v_qtytotnet
                                from tappemp
                               where codempid = r_temploy.codempid
                                 and dteyreap = v_grdyear
                                 and numtime  = v_grdnumtime;
                          exception when no_data_found then
                              v_grdap   := null;
                              v_desnote := get_error_msg_php('HR1620',v_lang);
                          end;
                          if v_flgbonus = 'N' then
                              v_desnote := get_error_msg_php('HR1613',v_lang)||' or '||get_error_msg_php('HR1614',v_lang)||' or '||get_error_msg_php('HR1615',v_lang);
                          end if;
                          if v_process = 'HRAPS9B' then
                              begin
                                  select ratebon,amttbon into v_ratebon,v_amttbon
                                    from ttbonpard
                                   where r_temploy.codcomp like codcomp||'%'
                                     and codbon   = b_index_codbon
                                     and dteyreap = b_index_dteyreap
                                     and numtime  = b_index_numtime
                                     and grade    = v_grdap;
                              exception when no_data_found then
                                  v_ratebon := 0;
                                  v_amttbon := 0;
                              end;
                          else
                              begin
                                  select ratebonc,amttbonc into v_ratebon,v_amttbon
                                    from tbonpard
                                   where r_temploy.codcomp like codcomp||'%'
                                     and codbon   = b_index_codbon
                                     and dteyreap = b_index_dteyreap
                                     and numtime  = b_index_numtime
                                     and grade    = v_grdap;
                              exception when no_data_found then
                                  v_desnote := get_error_msg_php('HR1619',v_lang);
                                  v_ratebon := 0;
                                  v_amttbon := 0;
                              end;
                          end if;
                      else
                          v_flgfound := 0;
                          if v_process = 'HRAPS9B' then
                              for r_ttbonparc in c_ttbonparc loop
                                  if r_ttbonparc.ratecond is not null then
                                      v_ratecondt :=  r_ttbonparc.ratecond;
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.NUMLVL', r_temploy.numlvl );
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.CODPOS',''''||r_temploy.codpos||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.JOBGRADE',''''||r_temploy.jobgrade||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.GRADE',''''||v_grdap||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.SCORE', v_qtytotnet );
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.AGEPOS',( months_between(sysdate,r_temploy.dteempmt)));
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.AGE_POS',( months_between(sysdate,r_temploy.dteempmt)));--User37 #4442 07/10/2021
                                      v_ratecondt := 'select count(*) from temploy1 where '||v_ratecondt||' and codempid ='''||r_temploy.codempid||'''' ;
                                      v_flgfound  := execute_qty(v_ratecondt) ;--User37 #4485 12/10/2021 v_flgfound  := execute_qty(v_bonconds) ;
                                  end if;
                                  if v_flgfound <> 0 then
                                      --<<User37 #4485 12/10/2021 
                                      v_ratebon := r_ttbonparc.ratebon;
                                      v_amttbon := r_ttbonparc.amttbon;
                                      --v_ratebon := r_ttbonparc.ratebonc;
                                      --v_amttbon := r_ttbonparc.amttbonc;
                                      -->>User37 #4485 12/10/2021 
                                      v_numcond := r_ttbonparc.numcond;
                                      exit;
                                  end if;

                              end loop;
                          else
                              for r_tbonparc in c_tbonparc loop
                                  if r_tbonparc.ratecond is not null then
                                      v_ratecondt :=  r_tbonparc.ratecond;
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.NUMLVL', r_temploy.numlvl );
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.CODPOS',''''||r_temploy.codpos||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.JOBGRADE',''''||r_temploy.jobgrade||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.GRADE',''''||v_grdap||'''');
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.SCORE', v_qtytotnet );
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.AGEPOS',( months_between(sysdate,r_temploy.dteempmt)));
                                      v_ratecondt := replace(v_ratecondt,'V_HRAP51.AGE_POS',( months_between(sysdate,r_temploy.dteempmt)));--User37 #4442 07/10/2021
                                      v_ratecondt := 'select count(*) from temploy1 where '||v_ratecondt||' and codempid ='''||r_temploy.codempid||'''' ;
                                      v_flgfound  := execute_qty(v_ratecondt) ;--User37 #4485 12/10/2021 v_flgfound  := execute_qty(v_bonconds) ;
                                  end if;
                                  if v_flgfound <> 0 then
                                      v_ratebon := r_tbonparc.ratebon;
                                      v_amttbon := r_tbonparc.amttbon;
                                      v_numcond := r_tbonparc.numcond;
                                      exit;
                                  end if;
                              end loop;

                          end if;
                      end if;

                      v_amtbon := 0;--user37 #4482 08/10/2021
                      if v_flgbonus = 'Y' then
                          if v_amtsalstr <> 0 then
                              v_formulat := v_formula;
                              v_stment   := null;
                              if nvl(v_ratebon,0) > 0 or nvl(v_amttbon,0) > 0 then
                                  v_formulat := replace(v_formulat,'{[AMTSAL]}',v_amtsalstr);
                                  v_formulat := replace(v_formulat,'{[RATE]}',(v_ratebon));
                                  v_formulat := replace(v_formulat,'{[AMOUNT]}',v_amttbon);
                                  v_stment   := 'select '||v_formulat||' from dual ';
                                  v_amtbon   := execute_qty(v_stment);
                                  v_amtbon   := v_amtbon * (v_daycalcu / ((v_dteend - v_dtestr) + 1));
                                  v_qtybon   := v_ratebon;
                              end if;

                              v_amtdedbon := 0;
                              if v_typbon = '1' and nvl(v_pctdbon,0) <> 0 then---% หักโบนัส
                                  v_amtdedbon := v_amtbon * (v_pctdbon/100) ;
                                  v_amtbon    := v_amtbon - v_amtdedbon;
                              end if;
                          end if;
                      else
                          v_amtbon := 0;
                          v_qtybon := 0;
                      end if;

                      if v_amtbon < 0 then
                         v_amtbon := 0;
                      end if;
                      v_amtbon := nvl(round(v_amtbon,2),0);
                      if v_amtincom <> 0 then
                        v_qtynbon := nvl(v_amtbon,0) / (v_amtincom);
                        v_qtynbon := round(v_qtynbon,2);
                      else
                        v_qtynbon := nvl(v_qtybon,0);
                      end if;
                      --Insert data
                      if v_process = 'HRAPS9B' then
                          insert into ttbonus (dteyreap,numtime,codbon,
                                               codempid,codcomp,typpayroll,
                                               dteempmt,qtydaybon,grade,
                                               amtsal,amtsalc,qtybon,numcond,
                                               amtbon,pctdedbo,codcreate,
                                               codpos ,jobgrade,
                                               coduser)
                                  values      (b_index_dteyreap,b_index_numtime,b_index_codbon,
                                               r_temploy.codempid,r_temploy.codcomp,r_temploy.typpayroll,
                                               r_temploy.dteempmt,v_daycalcu,v_grdap,
                                               stdenc(v_amtincom,r_temploy.codempid,v_chken) ,stdenc(v_amtsalstr,r_temploy.codempid,v_chken) ,v_qtynbon,v_numcond,
                                               stdenc(v_amtbon,r_temploy.codempid,v_chken) ,v_pctdbon,v_coduser,
                                               r_temploy.codpos,r_temploy.jobgrade,
                                               v_coduser);
                      else
                          insert into tbonus  (dteyreap,numtime,codbon,
                                               codempid,codcomp,typpayroll,
                                               dteempmt,qtydaybon,grade,
                                               amtsal,amtsalc,qtybon,
                                               amtbon,flgbonus,pctdedbo,
                                               amtnbon,desnote,codcombn,
                                               codreq,flgtrnpy,staappr,
                                               codpos ,jobgrade,
                                               codcreate,coduser)
                                  values      (b_index_dteyreap,b_index_numtime,b_index_codbon,
                                               r_temploy.codempid,r_temploy.codcomp,r_temploy.typpayroll,
                                               r_temploy.dteempmt,v_daycalcu,v_grdap,
                                               stdenc(v_amtincom,r_temploy.codempid,v_chken) ,stdenc(v_amtsalstr,r_temploy.codempid,v_chken) ,v_qtynbon,
                                               stdenc(v_amtbon,r_temploy.codempid,v_chken) ,v_flgbonus,v_pctdbon,
                                               stdenc(v_amtbon,r_temploy.codempid,v_chken) ,v_desnote,v_codcomp,
                                               b_index_codreq,'N','P',
                                               r_temploy.codpos,r_temploy.jobgrade,
                                               v_coduser,v_coduser);
                      end if;
                      b_index_sumrec := b_index_sumrec + 1;
                  end if;
              end if;

          end if;
      end loop;
      if v_process = 'HRAPS9B' then
          update ttbonparh set flgcal = 'Y'
           where codbon   = b_index_codbon
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and codcomp  = b_index_codcomp;
      else
          update tbonparh set flgcal = 'Y'
           where codbon   = b_index_codbon
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and codcomp  = b_index_codcomp;
      end if;
      update tprocount
       set qtyproc  = b_index_sumrec,
           qtyerr   = b_index_sumerr,
           flgproc  = 'Y'
      where codapp  = p_codapp
        and coduser = p_coduser
        and numproc = p_numproc ;
      commit;
  exception when others then
      v_sqlerrm := sqlerrm ;
    update tprocount
       set qtyproc  = b_index_sumrec,
           qtyerr   = b_index_sumerr,
           codempid = v_codempid,
           dteupd   = sysdate,
           Flgproc  = 'E',
           remark   = substr('Error Step :'||v_sqlerrm,1,500)
     where codapp  = p_codapp
       and coduser = p_coduser
       and numproc = p_numproc ;
    commit;

    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
end HRAPS9B_BATCH;

/
