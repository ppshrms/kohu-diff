--------------------------------------------------------
--  DDL for Package Body HRAP39B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP39B_BATCH" as

  procedure get_parameter (pb_var_codcomp      in varchar2,
                           pb_var_dteyreap     in varchar2,
                           pv_coduser          in varchar2,
                           pv_lang             in varchar2) is
  begin
      b_index_codcomp     := pb_var_codcomp;
      b_index_dteyreap    := pb_var_dteyreap;
      v_coduser           := pv_coduser;
      v_lang              := pv_lang;
  end;

  procedure start_process (p_codapp  in varchar2,
                           p_coduser in varchar2,
                           p_numproc in number,
                           p_process in varchar2 )  is

      p_sumrec            number:=0;
      p_sumerr            number:=0;

      v_syncond           tcontrap.syncond%type;
      v_syncondes         tcontrap.syncond%type;
      v_formusal          tapbudgt.formusal%type;
      v_formusalds        tapbudgt.formusal%type;
      v_flgntover         tcontrap.flgntover%type;
      v_flgpyntover       tcontrap.flgpyntover%type;
      v_formuntover       tcontrap.formuntover%type;
      v_formuntoverd      tcontrap.formuntover%type;
      v_flgover           tcontrap.flgover%type;
      v_flgpyover         tcontrap.flgpyover%type;
      v_formuover         tcontrap.formuover%type;
      v_formuoverd        tcontrap.formuover%type;

      v_grade             varchar2(2 char);
      v_sqlerrm           varchar2(1000 char) ;
      v_flgsecu	          boolean;
      v_zupdsal           varchar2(1  char);
      v_flgfound          number := 0;
      v_count             number := 0;
      v_pctsal            number := 0;

      v_amtminsa          number;
      v_amtmaxsa          number;
      v_midpoint          number;
      v_pctincrease       number;
      v_amtcal            number;
      v_amtcaln           number;
      v_amtdsal           number;
      v_amtsaln           number;
      v_amtover           number;
      v_amtpayover        number;
      v_qtywork           number;

      v_amtcalne            tappraism.amtmidsal%type;
      v_amtsalne            tappraism.amtmidsal%type;
      v_amtmaxsae           tappraism.amtmidsal%type;
      v_amtminsae           tappraism.amtmidsal%type;
      v_amtovere            tappraism.amtmidsal%type;
      v_amtpayovere         tappraism.amtmidsal%type;

      cursor c_tstdis  is
          select grade,pctwkstr,pctwkend,pctemp,pctpostr,pctpoend
            from tstdis
           where codcomp  = b_index_codcomp
             and dteyreap = b_index_dteyreap
          order by grade;

      cursor c_tappemp is
          select a.codempid,a.codcomp,a.codpos,a.numlvl,a.codaplvl,a.jobgrade,
                 a.flgsal,a.qtyta,a.qtypuns,a.grdap,d.typpayroll,
                 a.qtyadjtot,a.qtytotnet,a.pctdsal,stddec(amtincom1,a.codempid,v_chken) amtincom,
                 d.dteempmt,d.staemp,d.typemp,d.codempmt
            from tappemp a,tprocemp b, temploy3 c, temploy1 d
           where a.codempid = b.codempid
             and a.codempid = c.codempid
             and a.codempid = d.codempid
             and b.codapp   = p_codapp
             and b.coduser  = p_coduser
             and b.numproc  = p_numproc
             and a.numtime  = b_var_numtime
             and a.grdap    = v_grade
          order by codempid;

  begin
      v_numproc  := p_numproc;
      v_process  := p_process ;
      if v_process = 'HRAP3XE' then
          delete ttemprpt where codapp like 'HRAP3EMSG%' ;
      else
          delete ttemprpt where codapp like 'HRAP39MSG%' ;
      end if;
      delete tprocount where codapp = p_codapp and coduser = p_coduser  ; commit;
      insert into tprocount (codapp,coduser,numproc,
                             qtyproc,codpay,flgproc,dteupd)
       values               (p_codapp,p_coduser,p_numproc,
                             0,null,'N',sysdate);
      commit;

      b_index_sumrec := 0;
      b_index_sumerr := 0;

      begin
          select numtime into b_var_numtime
            from tstdisd
           where codcomp  = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and flgsal   = 'Y'
--#5552
             and exists(select codaplvl
                          from tempaplvl
                         where dteyreap = b_index_dteyreap
                           and numseq  = tstdisd.numtime
                           and codaplvl = tstdisd.codaplvl)
--#5552 
             and rownum   = 1;
      exception when no_data_found then
          b_var_numtime := 1;
      end;

      begin
          --select syncond,formusal,flgntover,flgpyntover,formuntover,flgover,flgpyover,formuover
          -- into v_syncond,v_formusal,v_flgntover,v_flgpyntover,v_formuntover,v_flgover,v_flgpyover,v_formuover
           select syncond,flgntover,flgpyntover,formuntover,flgover,flgpyover,formuover
            into v_syncond,v_flgntover,v_flgpyntover,v_formuntover,v_flgover,v_flgpyover,v_formuover
            from tcontrap
           where codcompy  = hcm_util.get_codcomp_level(b_index_codcomp,1)
             and dteyreap  = (select max(dteyreap)
                                from tcontrap
                               where codcompy   = hcm_util.get_codcomp_level(b_index_codcomp,1)
                                 and dteyreap   <= b_index_dteyreap);
      exception when no_data_found then
          null;
      end;
      -- ต้องแก้
      ---v_formusal ให้หาจาก TAPBUDGT
      v_formusal := 'MITPOINT * (PCTINCR/100)' ;
      -----------------------------------------
      for r_tstdis in c_tstdis loop
          v_grade := r_tstdis.grade;

          for i in c_tappemp loop
              v_flgsecu := secur_main.secur1(i.codcomp,i.numlvl,v_coduser,v_numlvlsalst,v_numlvlsalen,v_zupdsal);
              tappemp_codempid := i.codempid;
              if v_flgsecu then
                  v_qtywork := trunc(months_between(trunc(sysdate),i.dteempmt));
                  v_flgfound := 0;
                  if v_syncond is not null then
                      v_syncondes := v_syncond ;
                      v_syncondes := replace(v_syncondes,'TEMPLOY1.AGE_POS',''||v_qtywork||'') ;
                      v_syncondes := replace(v_syncondes,'TEMPLOY1.STAEMP',''''||i.staemp||'''') ;
                      v_syncondes := replace(v_syncondes,'TEMPLOY1.TYPEMP',''''||i.typemp||'''') ;
                      v_syncondes := replace(v_syncondes,'TEMPLOY1.CODEMPMT',''''||i.codempmt||'''') ;
                      v_syncondes := 'select count(*) from temploy1 where '||v_syncondes||' and codempid ='''||i.codempid||'''' ;
                      v_flgfound  := execute_qty(v_syncondes) ;
                  end if;

                  if v_flgfound <> 0 then
                      ---cal form formusal
                      v_pctincrease := 0;
                      begin
                          select amtminsa,amtmaxsa,midpoint
                            into v_amtminsa,v_amtmaxsa,v_midpoint
                            from tsalstr
                           where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
                             and jobgrade = i.jobgrade
                             and dteyreap = (select max(dteyreap)
                                               from tsalstr
                                              where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
                                                and jobgrade = i.jobgrade
                                                and dteyreap <= to_number(to_char(sysdate,'YYYY'))
                                                and rownum   = 1)
                             and rownum   = 1;
                      exception when no_data_found then
                          null;
                      end;

                      ---% increase
                      v_pctincrease := (((nvl(i.qtyadjtot,i.qtytotnet) - nvl(v_amtminsa,0)) / (nvl(v_amtmaxsa,0) - nvl(v_amtminsa,0))) *
                                       (r_tstdis.pctpoend - r_tstdis.pctpostr)) + r_tstdis.pctpostr;

                      if v_formusal is not null then
                          v_formusalds := v_formusal;
                          v_formusalds := replace(v_formusalds,'MITPOINT',''||v_midpoint||'') ;
                          v_formusalds := replace(v_formusalds,'PCTINCR',''||v_pctincrease||'') ;
                          v_formusalds := replace(v_formusalds,'BASICSALARY',''||i.amtincom||'') ;
                          v_amtcal     := execute_sql('select '||v_formusalds||' from dual');
                      end if;

                      v_amtcaln := v_amtcal;
                      if v_amtcal <> 0 and i.pctdsal is not null then
                          v_amtdsal := (v_amtcal * i.pctdsal)/100;
                          v_amtcaln := v_amtcal - v_amtdsal; --4,000
                      end if;
                      v_amtsaln := i.amtincom + v_amtcaln; --16,000
                      if v_amtsaln > v_amtmaxsa then --16,000 > 15,000
                          v_amtover := v_amtsaln - v_amtmaxsa; --1,000
                      end if;

                      --Check over salary
                      if i.amtincom <= v_amtmaxsa then --12,000 <= 15,000
                          if v_amtsaln > v_amtmaxsa then --16,000 > 15,000
                              if v_flgntover = 'N' then -- can not over
                                  v_amtcaln :=  v_amtmaxsa - i.amtincom; -- 15,000 - 12,000 = 3,000
                                  if v_flgpyntover = 'Y' then -- can pay amt over
                                      v_amtover := v_amtsaln - v_amtmaxsa; -- 16,000 - 15,000 = 1,000
                                      if v_formuntover is not null then
                                          v_formuntoverd := v_formuntover;
                                          v_formuntoverd := replace(v_formuntoverd,'AMTOVER',''||v_amtover||'') ;
                                          v_amtpayover   := execute_sql('select '||v_formuntoverd||' from dual');
                                      end if;
                                  else
                                      v_amtover    := 0;
                                      v_amtpayover := 0;
                                  end if;
                              end if;
                          end if;
                      elsif i.amtincom > v_amtmaxsa then --17,000 > 15,000
                          if v_flgover = 'N' then
                              v_amtcaln := 0;    --old 4,000
                              v_amtsaln := i.amtincom; --17,000
                              if v_flgpyover = 'Y' then
                                 v_amtover := v_amtsaln - v_amtmaxsa; -- 17,000 - 15,000 = 2,000
                                  if v_formuover is not null then
                                      v_formuoverd := v_formuover;
                                      v_formuoverd := replace(v_formuoverd,'AMTOVER',''||v_amtover||'') ;
                                      v_amtpayover := execute_sql('select '||v_formuoverd||' from dual');
                                  end if;
                              else
                                  v_amtover    := 0;
                                  v_amtpayover := 0;
                              end if;
                          end if;
                      end if; --Check over salary

                      if v_process = 'HRAP3XE' then
                          --insert/update tappraism
                          v_count := 0;
                          begin
                              select count(*) into v_count
                                from tappraism
                               where codempid = i.codempid
                                 and dteyreap = b_index_dteyreap
                                 and codcomp  = i.codcomp;
                          exception when no_data_found then
                              v_count := 0;
                          end;
                          v_amtcalne    := stdenc(nvl(v_amtcaln,0),i.codempid,v_chken);
                          v_amtsalne    := stdenc(nvl(v_amtsaln,0),i.codempid,v_chken);
                          v_amtmaxsae   := stdenc(nvl(v_amtmaxsa,0),i.codempid,v_chken);
                          v_amtminsae   := stdenc(nvl(v_amtminsa,0),i.codempid,v_chken);
                          v_amtovere    := stdenc(nvl(v_amtover,0),i.codempid,v_chken);
                          v_amtpayovere := stdenc(nvl(v_amtpayover,0),i.codempid,v_chken);

                          if v_count = 0 then
                              insert into tappraism ( dteyreap,codempid,codcomp,
                                                      flgsal,qtypuns,qtyta,
                                                      grade,pctsal,qtyscor,
                                                      pctdsal,amtmidsal,amtsalo,
                                                      amtbudg,amtsaln,amtceiling,
                                                      amtminsal,amtover,amtpayover,
                                                      codcreate,coduser)
                                     values         ( b_index_dteyreap,i.codempid,i.codcomp,
                                                      i.flgsal,i.qtypuns,i.qtyta,
                                                      i.grdap,v_pctincrease,i.qtytotnet,
                                                      i.pctdsal,v_midpoint,i.amtincom,
                                                      v_amtcalne,v_amtsalne,v_amtmaxsae,
                                                      v_amtminsae,v_amtovere,v_amtpayovere,
                                                      v_coduser,v_coduser);
                          else
                              update tappraism set flgsal     = i.flgsal,
                                                   grade      = i.grdap,
                                                   pctsal     = v_pctincrease,
                                                   qtyscor    = i.qtytotnet,
                                                   pctdsal    = i.pctdsal,
                                                   amtbudg    = v_amtcalne,
                                                   amtsaln    = v_amtsalne,
                                                   amtceiling = v_amtmaxsae,
                                                   amtminsal  = v_amtminsae,
                                                   amtover    = v_amtovere,
                                                   amtpayover = v_amtpayovere
                               where codempid = i.codempid
                                 and dteyreap = b_index_dteyreap
                                 and codcomp  = i.codcomp;
                          end if;
                      else
                          v_count := 0;
                          begin
                              select count(*) into v_count
                                from tapprais
                               where codempid = i.codempid
                                 and dteyreap = b_index_dteyreap;
                          exception when no_data_found then
                              v_count := 0;
                          end;

                          if v_count = 0 then
                              insert into tapprais (  codempid,dteyreap,--codcomlvl,
                                                      codcomp,codpos,typpayroll,
                                                      numlvl,jobgrade,qtywork,
                                                      flgsal,qtypuns,qtyta,
                                                      grade,qtyscore,pctcalsal,
                                                      pctdsal,amtmidsal,amtsal,
                                                      amtbudg,amtsaln,amtceiling,
                                                      amtminsal,amtover,amtlums,
                                                      staappr,codcreate,coduser)
                                     values         ( i.codempid,b_index_dteyreap,--i.codcomp,
                                                      i.codcomp,i.codpos,i.typpayroll,
                                                      i.numlvl,i.jobgrade,v_qtywork,
                                                      i.flgsal,i.qtypuns,i.qtyta,
                                                      i.grdap,i.qtytotnet,v_pctincrease,
                                                      i.pctdsal,v_midpoint,i.amtincom,
                                                      v_amtcaln,v_amtsaln,v_amtmaxsa,
                                                      v_amtminsa,v_amtover,v_amtpayover,
                                                      'P',v_coduser,v_coduser);
                          else
                              update tapprais  set flgsal     = i.flgsal,
                                                   grade      = i.grdap,
                                                   pctcalsal  = v_pctincrease,
                                                   qtyscore   = i.qtytotnet,
                                                   pctdsal    = i.pctdsal,
                                                   amtbudg    = v_amtcaln,
                                                   amtsaln    = v_amtsaln,
                                                   amtceiling = v_amtmaxsa,
                                                   amtminsal  = v_amtminsa,
                                                   amtover    = v_amtover,
                                                   amtlums    = v_amtpayover
                               where codempid = i.codempid
                                 and dteyreap = b_index_dteyreap;
                          end if;
                      end if;
                      b_index_sumrec := b_index_sumrec + 1;
                  end if;

              end if;

          end loop;
      end loop;

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
      v_sqlerrm := sqlerrm ;
    update tprocount
       set qtyproc  = b_index_sumrec,
           qtyerr   = b_index_sumerr,
           codempid = tappemp_codempid,
           dteupd   = sysdate,
           Flgproc  = 'E',
           remark   = substr('Error Step :'||v_sqlerrm,1,500)
     where codapp  = p_codapp
       and coduser = p_coduser
       and numproc = p_numproc ;
    commit;
  end ;

end hrap39b_batch;

/
