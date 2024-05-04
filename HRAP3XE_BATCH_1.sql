--------------------------------------------------------
--  DDL for Package Body HRAP3XE_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3XE_BATCH" as

  procedure start_process (p_codapp  in varchar2,
                           p_coduser in varchar2,
                           p_numproc in number,
                           p_process in varchar2,
                           p_codcomp in varchar2,
                           p_dteyreap in varchar2,
                           p_param_json in clob)  is
  begin

    para_numproc := p_numproc;
    para_codapp  := p_codapp;
    para_coduser := p_coduser;

    -- create tprocount
    gen_group;

    -- create Job
    gen_job(p_codapp,p_coduser,p_numproc,p_process,p_codcomp,p_dteyreap,p_param_json);
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
                         p_codcomp in varchar2,
                         p_dteyreap in varchar2,
                         p_param_json in clob)  is
    v_stmt			clob;
    v_interval	    varchar2(50 char);
    v_finish		varchar2(1 char);

    type a_number is table of number index by binary_integer;
       a_jobno	a_number;

  begin
    for i in 1..para_numproc loop
--    for i in 1..1 loop

      v_stmt :=' hrap3xe_batch.cal_process('''||p_codapp||''','''
                   ||p_coduser||''','''
                   ||i||''','''
                   ||p_process||''','''
                   ||p_codcomp||''','''
                   ||p_dteyreap||''','''
                   ||p_param_json||''');' ;
      dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
    end loop;  --for i in 1..para_numproc loop
    --
    v_finish := 'U';
--    para_numproc :=  1 ;
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
                         p_numproc in number,
                         p_process in varchar2,
                         p_codcomp in varchar2,
                         p_dteyreap in varchar2,
                         p_param_json in clob)  is

        v_param_json            json_object_t;
        p_sumrec                number:=0;
        p_sumerr                number:=0;
        param_json_row          json_object_t;
        v_grade                 varchar2(2 char);
        v_pctpoend              number;
        v_pctpostr              number;
        v_size                  number;
        v_pctwkstr              number;
        v_pctwkend              number;
        v_sqlerrm               varchar2(1000 char) ;
        v_runproc               number := 0;


        cursor c_tstdis  is
            select grade,pctpostr,pctpoend,pctactstr,pctactend
              from tstdis
             where codcomp  = p_codcomp
               and dteyreap = p_dteyreap
               and pctactstr is not null
            order by grade;

  begin
      v_numproc  := p_numproc;
      v_process  := p_process ;

      if v_process = 'HRAP3XE' then
          delete ttemprpt where codapp like 'HRAP3EMSG%' ;
      else
          delete ttemprpt where codapp like 'HRAP39MSG%' ;
      end if;
      commit;

      b_index_sumrec := 0;
      b_index_sumerr := 0;

    --TSTAPSALD
    if p_process  = 'HRAP3XE' then
        v_param_json := json_object_t(p_param_json);
        hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,v_numlvlsalst,v_numlvlsalen);
        for j in 0..v_param_json.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(v_param_json,to_char(j));
            v_grade         := hcm_util.get_string_t(param_json_row,'grade');
            v_pctpostr      := to_number(hcm_util.get_string_t(param_json_row,'percst'));
            v_pctpoend      := to_number(hcm_util.get_string_t(param_json_row,'percen'));
            v_runproc       := v_runproc + 1;

            process_salary (p_codapp,p_coduser,v_runproc,p_process,p_codcomp ,p_dteyreap,v_grade,v_pctpostr,v_pctpoend);

        end loop;
    else --p_process  = 'HRAP39B' then
        for i in c_tstdis loop
            process_salary (p_codapp,p_coduser,p_numproc,p_process,p_codcomp ,p_dteyreap,i.grade,i.pctactstr,i.pctactend);
        end loop;
    end if;

      update tprocount
       set qtyproc  = b_index_sumrec,
           qtyerr   = b_index_sumerr,
           flgproc  = 'Y'
      where codapp  = p_codapp
        and coduser = p_coduser
        and numproc = p_numproc ;

      commit;
      p_sumrec := b_index_sumrec;
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

    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end ;

    procedure process_salary (p_codapp   in varchar2,
                              p_coduser  in varchar2,
                              p_numproc  in number,
                              p_process  in varchar2,
                              p_codcomp  in varchar2,
                              p_dteyreap in varchar2,
                              p_grade    in varchar2,
                              p_pctpostr in number,
                              p_pctpoend in number) is


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

        v_codempid          temploy1.codempid%type;
        v_amtincom          temploy3.amtincom1%type;
        v_qtytotnet 	    tappemp.qtytotnet%type;
        v_qtytotnetn 	    tappemp.qtytotnet%type;
        v_timtotnet 	    number;
        v_qtyta             tappemp.qtyta%type;
        v_qtytan            tappemp.qtyta%type;
        v_timta  	        number;
        v_qtypuns           tappemp.qtypuns%type;
        v_qtypunsn          tappemp.qtypuns%type;
        v_timpuns    	    number;
        v_flgsal            tappemp.flgsal%type;
        v_pctdsal           tappemp.pctdsal%type;
        v_pctdsaln          tappemp.pctdsal%type;
        v_timpctdsal    	number;

        v_grade             varchar2(2 char);
        v_sqlerrm           varchar2(1000 char) ;
        v_flgsecu	        boolean;
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

        v_midpointe         tappraism.amtmidsal%type;
        v_amtsaloe          tappraism.amtmidsal%type;
        v_amtcalne          tappraism.amtmidsal%type;
        v_amtsalne          tappraism.amtmidsal%type;
        v_amtmaxsae         tappraism.amtmidsal%type;
        v_amtminsae         tappraism.amtmidsal%type;
        v_amtovere          tappraism.amtmidsal%type;
        v_amtpayovere       tappraism.amtmidsal%type;
        v_amtsalnovr        tappraism.amtmidsal%type;
        v_amtcalnovr        tappraism.amtmidsal%type;
        v_dteapend          tstdisd.dteapend%type;

        v_pctpoend            number;
        v_pctpostr            number;
        v_size                number;
        v_pctwkstr            number;
        v_pctwkend            number;

      cursor c_tappemp is
          select a.codempid,a.codcomp,a.codpos,a.numlvl,a.codaplvl,a.jobgrade,
                 d.typpayroll,d.dteempmt,d.staemp,d.typemp,d.codempmt ,
                 stddec(c.amtincom1,a.codempid,v_chken) amtincom
            from tappemp a,tprocemp b, temploy3 c, temploy1 d
           where a.codempid = b.codempid
             and a.codempid = c.codempid
             and a.codempid = d.codempid
             and b.codapp   = p_codapp
             and b.coduser  = p_coduser
             and b.numproc  = p_numproc
             and a.dteyreap = p_dteyreap
          order by codempid;

        cursor c_ttmovemt is
            select stddec(amtincom1,codempid,v_chken) amtincom
              from ttmovemt
             where codempid  = v_codempid
               and dteeffec  <= v_dteapend
             order by numseq desc;

    begin


        v_pctpoend := p_pctpoend;
        v_pctpostr := p_pctpostr;
        begin
            select syncond,flgntover,flgpyntover,formuntover,flgover,flgpyover,formuover
            into v_syncond,v_flgntover,v_flgpyntover,v_formuntover,v_flgover,v_flgpyover,v_formuover
            from tcontrap
           where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
             and dteyreap  = (select max(dteyreap)
                                from tcontrap
                               where codcompy   = hcm_util.get_codcomp_level(p_codcomp,1)
                                 and dteyreap   <= p_dteyreap);
        exception when no_data_found then
          null;
        end;

        for i in c_tappemp loop
            v_flgsecu := secur_main.secur1(i.codcomp,i.numlvl,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,v_numlvlsalst,v_numlvlsalen);
            v_flgsecu := true;
            tappemp_codempid := i.codempid;

            v_pctdsaln  := 0;

            if v_flgsecu then
                v_qtywork := trunc(months_between(trunc(sysdate),i.dteempmt));
                v_flgfound := 0;
                if v_syncond is not null then
                    v_syncondes := v_syncond ;
                    v_syncondes := replace(v_syncondes,'V_HRPMA1.AGE_POS',''||v_qtywork||'') ;
                    v_syncondes := replace(v_syncondes,'V_HRPMA1.STAEMP',''''||i.staemp||'''') ;
                    v_syncondes := replace(v_syncondes,'V_HRPMA1.TYPEMP',''''||i.typemp||'''') ;
                    v_syncondes := replace(v_syncondes,'V_HRPMA1.CODEMPMT',''''||i.codempmt||'''') ;
                    v_syncondes := 'select count(*) from V_HRPMA1 where '||v_syncondes||' and codempid ='''||i.codempid||'''' ;
                    v_flgfound  := execute_qty(v_syncondes) ;
                end if;
                v_flgsal := 'Y';
                begin
                    select flgsal into v_flgsal
                      from tappemp
                     where codempid  = i.codempid
                       and dteyreap  = p_dteyreap
                       and nvl(flgsal,'N')    = 'N'
                       and rownum    = 1;
                exception when no_data_found then
                    v_flgsal := 'Y';
                end;

                if v_flgfound <> 0 and v_flgsal = 'Y' then

                    v_codempid := i.codempid;

                    begin
                        select pctwkstr,pctwkend
                          into v_pctwkstr,v_pctwkend
                          from tstdis
                         where i.codcomp  like codcomp||'%'
                           and dteyreap = p_dteyreap
                           and grade    = p_grade ;
                    exception when others then
                        v_pctwkstr := 0 ;
                        v_pctwkend := 0 ;
                    end ;

                    begin
                        select sum(nvl(qtyadjtot,nvl(qtytotnet,0))),sum(decode(nvl(qtyadjtot,nvl(qtytotnet,0)),0,0,1)),
                               sum(nvl(qtyta,0)),sum(decode(qtyta,0,0,1)),
                               sum(nvl(qtypuns,0)),sum(decode(qtypuns,0,0,1)),
                               sum(nvl(pctdsal,0)),sum(decode(pctdsal,0,0,1))
                        into   v_qtytotnet,v_timtotnet,
                               v_qtyta,v_timta,
                               v_qtypuns,v_timpuns,
                               v_pctdsal,v_timpctdsal
                         from  tappemp a
                        where  a.codempid  = i.codempid
                          and  a.dteyreap  = p_dteyreap
                          and exists  (select 1 from tstdisd b
                                        where a.codcomp   like b.codcomp||'%'
                                          and b.dteyreap  = a.dteyreap
                                          and b.numtime   = a.numtime
                                          and b.flgsal    = 'Y'
--#5552
                                          and exists(select codaplvl
                                                      from tempaplvl
                                                     where dteyreap = a.dteyreap
                                                       and numseq  = a.numtime
                                                       and codaplvl = b.codaplvl
                                                       and codempid = i.codempid )
--#5552
                                          );
                    exception when others then
                        v_qtytotnet := 0; v_timtotnet   := 0;
                        v_qtyta 	:= 0; v_timta       := 0;
                        v_qtypuns 	:= 0; v_timpuns     := 0;
                    end ;

                    if nvl(v_timtotnet,0) <> 0 then
                        v_qtytotnetn  := 	round(nvl(v_qtytotnet,0) / v_timtotnet,2);
                    end if;

                    if nvl(v_timta,0) <> 0 then
                        v_qtytan  := 	round(nvl(v_qtyta,0) / v_timta,2);
                    end if;

                    if nvl(v_timpuns,0) <> 0 then
                        v_qtypunsn  := 	round(nvl(v_qtypuns,0) / v_timpuns,2);
                    end if;

                    if nvl(v_timpctdsal,0) <> 0 then
                        v_pctdsaln  := 	nvl(round(nvl(v_pctdsal,0) / v_timpctdsal,2),0);
                    end if;


                    if v_qtytotnetn between v_pctwkstr and v_pctwkend then

                        v_pctincrease := 0;
                        begin
                          select amtminsa,amtmaxsa,midpoint
                            into v_amtminsa,v_amtmaxsa,v_midpoint
                            from tsalstr
                           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                             and jobgrade = i.jobgrade
                             and dteyreap = (select max(dteyreap)
                                               from tsalstr
                                              where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                                and jobgrade = i.jobgrade
                                                and dteyreap <= p_dteyreap
                                                and rownum   = 1)
                             and rownum   = 1;
                        exception when no_data_found then
                          null;
                        end;
                        ---cal form formusal
                        begin
                            select formusal into v_formusal
                              from tapbudgt
                             where dteyreap   = p_dteyreap
                               and i.codcomp  like codcomp||'%'
                               and rownum     = 1;
                        exception when no_data_found then
                            v_formusal := null;
                        end;

                        --% increase
                        v_pctincrease := 0;
                        if (nvl(v_amtmaxsa,0) - nvl(v_amtminsa,0)) <> 0 then
                            v_pctincrease := round((((v_qtytotnetn - v_pctwkstr)/(v_pctwkend - v_pctwkstr )) * ((v_pctpoend  - v_pctpostr))) + v_pctpostr,2) ;
                        end if;

                        begin
                            select max(dteapend) into v_dteapend
                              from tstdisd
                             where dteyreap   = p_dteyreap
                               and i.codcomp  like codcomp||'%'
--#5552
                               and exists(select codaplvl
                                          from tempaplvl
                                         where dteyreap = p_dteyreap
                                           and codaplvl = tstdisd.codaplvl)
--#5552
                               ;
                        exception when no_data_found then
                            v_dteapend := null;
                        end;
                        v_amtincom := i.amtincom;
                        for j in c_ttmovemt loop
                            v_amtincom := j.amtincom;
                            exit;
                        end loop;

                        if v_formusal is not null then
                            v_formusalds := v_formusal;
--                            v_formusalds := replace(v_formusalds,'MITPOINT',''||v_midpoint||'') ;
--                            v_formusalds := replace(v_formusalds,'PCTINCR',''||v_pctincrease||'') ;
--                            v_formusalds := replace(v_formusalds,'BASICSALARY',''||v_amtincom||'') ;
                            v_formusalds := replace(v_formusalds,'{[AMTMID]}',''||v_midpoint||'') ;
                            v_formusalds := replace(v_formusalds,'{[AMTINC]}',''||v_pctincrease||'/100') ;
                            v_formusalds := replace(v_formusalds,'{[AMTSAL]}',''||v_amtincom||'') ;
--                            select {[AMTSAL]}*{[AMTINC]} from dual
                            v_amtcal     := execute_sql('select '||v_formusalds||' from dual');
                        end if;

                        v_amtcaln := v_amtcal;

                        if v_amtcal <> 0 and v_flgsal = 'Y' then
                            v_amtdsal := (v_amtcal * v_pctdsaln)/100;
                            v_amtcaln := v_amtcal - v_amtdsal; --4,000
                        end if;
                        v_amtsaln := nvl(v_amtincom,0) + v_amtcaln; --175,000 + 5,000 = 180,000
                        if v_amtsaln > v_amtmaxsa then --180,000 > 180,000
                            v_amtover := v_amtsaln - v_amtmaxsa; --1,000
                        end if;

                        --Check over salary
                        v_amtsalnovr := v_amtsaln;
                        if v_amtincom <= v_amtmaxsa then --175,000 <= 180,000
--                          v_amtsalnovr := v_amtincom;
                          if v_amtsaln > v_amtmaxsa then --190,113 > 180,000
                              if v_flgntover = 'N' then -- can not over
                                  v_amtcaln    := v_amtmaxsa - v_amtincom; -- 180,000 - 175,000 = 5,000
                                  v_amtsalnovr := v_amtmaxsa;
                                  if v_flgpyntover = 'Y' then -- can pay amt over
                                      v_amtover := v_amtsaln - v_amtmaxsa; -- 190,113 - 180,000 = 10,113
                                      if v_formuntover is not null then
                                          v_formuntoverd := v_formuntover;
                                          v_formuntoverd := replace(v_formuntoverd,'[AMTOVER]',''||v_amtover||'') ;
                                          v_formuntoverd := replace(v_formuntoverd,'{',null) ;
                                          v_formuntoverd := replace(v_formuntoverd,'}',null) ;
                                          v_amtpayover   := execute_sql('select '||v_formuntoverd||' from dual');
                                      end if;
                                  else
                                      v_amtover    := 0;
                                      v_amtpayover := 0;
                                  end if;
                              end if;
                          end if;
                        elsif v_amtincom > v_amtmaxsa then --1,000,000 > 160,000
                          if v_flgover = 'N' then
                              v_amtcalnovr := v_amtcaln;
                              v_amtcaln    := 0;    --old 14,100
                              v_amtsaln    := v_amtincom; --1,000,000
                              v_amtsalnovr := v_amtsaln;
                              if v_flgpyover = 'Y' then
                                 v_amtover := v_amtcalnovr;---v_amtsaln - v_amtmaxsa; -- 1,000,000 - 160,000 = 2,000
                                  if v_formuover is not null then
                                      v_formuoverd := v_formuover;
                                      v_formuoverd := replace(v_formuoverd,'[AMTOVER]',''||v_amtover||'') ;
                                      v_formuoverd := replace(v_formuoverd,'{',null) ;
                                      v_formuoverd := replace(v_formuoverd,'}',null) ;
                                      v_amtpayover := execute_sql('select '||v_formuoverd||' from dual');
                                  end if;
                              else
                                  v_amtover    := 0;
                                  v_amtpayover := 0;
                              end if;
                          end if;
                        end if; --Check over salary

                        v_midpointe   := stdenc(nvl(v_midpoint,0),i.codempid,v_chken);
                        v_amtsaloe    := stdenc(nvl(v_amtincom,0),i.codempid,v_chken);
                        v_amtcalne    := stdenc(nvl(v_amtcaln,0),i.codempid,v_chken);
                        v_amtsalne    := stdenc(nvl(v_amtsalnovr,0),i.codempid,v_chken);
                        v_amtmaxsae   := stdenc(nvl(v_amtmaxsa,0),i.codempid,v_chken);
                        v_amtminsae   := stdenc(nvl(v_amtminsa,0),i.codempid,v_chken);
                        v_amtovere    := stdenc(nvl(v_amtover,0),i.codempid,v_chken);
                        v_amtpayovere := stdenc(nvl(v_amtpayover,0),i.codempid,v_chken);

                        if v_process = 'HRAP3XE' then
                            --insert/update tappraism
                            v_count := 0;
                            begin
                                select count(*) into v_count
                                  from tappraism
                                 where codempid = i.codempid
                                   and dteyreap = p_dteyreap
                                   and codcomp  = i.codcomp;
                            exception when no_data_found then
                                v_count := 0;
                            end;
                            if v_count = 0 then
                              insert into tappraism ( dteyreap,codempid,codcomp,
                                                      flgsal,qtypuns,qtyta,
                                                      grade,pctsal,qtyscor,
                                                      pctdsal,amtmidsal,amtsalo,
                                                      amtbudg,amtsaln,amtceiling,
                                                      amtminsal,amtover,amtpayover,
                                                      codcreate,coduser)
                                     values         ( p_dteyreap,i.codempid,i.codcomp,
                                                      v_flgsal,v_qtypunsn,v_qtytan,
                                                      p_grade,v_pctincrease,v_qtytotnetn,
                                                      v_pctdsaln,v_midpointe,v_amtsaloe,
                                                      v_amtcalne,v_amtsalne,v_amtmaxsae,
                                                      v_amtminsae,v_amtovere,v_amtpayovere,
                                                      p_coduser,p_coduser);
                            else
                              update tappraism set flgsal     = v_flgsal,
                                                   grade      = p_grade,
                                                   pctsal     = v_pctincrease,
                                                   qtyscor    = v_qtytotnetn,
                                                   pctdsal    = v_pctdsaln,
                                                   amtmidsal  = v_midpointe,
                                                   amtsalo    = v_amtsaloe,
                                                   amtbudg    = v_amtcalne,
                                                   amtsaln    = v_amtsalne,
                                                   amtceiling = v_amtmaxsae,
                                                   amtminsal  = v_amtminsae,
                                                   amtover    = v_amtovere,
                                                   amtpayover = v_amtpayovere
                               where codempid = i.codempid
                                 and dteyreap = p_dteyreap
                                 and codcomp  = i.codcomp;
                            end if;
                        else

                            v_count := 0;
                            begin
                              select count(*) into v_count
                                from tapprais
                               where codempid = i.codempid
                                 and dteyreap = p_dteyreap;
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
                                     values         ( i.codempid,p_dteyreap,--i.codcomp,
                                                      i.codcomp,i.codpos,i.typpayroll,
                                                      i.numlvl,i.jobgrade,v_qtywork,
                                                      v_flgsal,v_qtypunsn,v_qtytan,
                                                      p_grade,v_qtytotnetn,v_pctincrease,
                                                      v_pctdsaln,v_midpointe,v_amtsaloe,
                                                      v_amtcalne,v_amtsalne,v_amtmaxsae,
                                                      v_amtminsae,v_amtovere,v_amtpayovere,
                                                      'P',p_coduser,p_coduser);
                            else
                              update tapprais  set flgsal     = v_flgsal,
                                                   grade      = p_grade,
                                                   pctcalsal  = v_pctincrease,
                                                   qtyscore   = v_qtytotnetn,
                                                   pctdsal    = v_pctdsaln,
                                                   amtmidsal  = v_midpointe,
                                                   amtsal     = v_amtsaloe,
                                                   amtbudg    = v_amtcaln,
                                                   amtsaln    = v_amtsalne,
                                                   amtceiling = v_amtmaxsae,
                                                   amtminsal  = v_amtminsae,
                                                   amtover    = v_amtovere,
                                                   amtlums    = v_amtpayovere
                               where codempid = i.codempid
                                 and dteyreap = p_dteyreap;
                            end if;

                        end if;
                        b_index_sumrec := b_index_sumrec + 1;

                    end if; ---if v_qtytotnetn between v_pctwkstr and v_pctwkend then
                end if; ---if v_flgfound <> 0 and v_flgsal = 'Y' then
            end if; ---if v_flgsecu then
        end loop;   ---for i in c_tappemp loop
    end;

end hrap3xe_batch;

/
