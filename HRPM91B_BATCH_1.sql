--------------------------------------------------------
--  DDL for Package Body HRPM91B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM91B_BATCH" is
-- last update: 16/03/2023 11:12||IPO    
-- last update: 03/02/2023 17:01||sea-HR2201/redmine676    

  -- 0. Start Process
  procedure strart_process is
    v_codcomp           temploy1.codcomp%type:= '%';
    v_endate            date        := sysdate;
    v_coduser           temploy1.coduser%type := 'AUTO';
    v_sum               number;
    v_err               number;
    v_msgerror          varchar2(1000 char);
    v_status            varchar2(1 char) := 'C';
    v_user              number;
    v_erruser           number;

  begin

    parameter_numseq    := 0;
    delete ttemfilt where codapp = 'HRPM91B' and coduser = v_coduser;
    commit;


    insert into  tautolog (codapp, dtecall, dteprost, dteproen, status, remark, coduser)
    values('HRPM91B', v_endate, v_endate, null, null, null, 'AUTO');

    begin
      process_new_employment(v_codcomp  ,v_endate ,v_coduser , v_sum ,v_err,v_user,v_erruser);
      v_msgerror := 'New Emp.[Complete] ';
    exception  when others then
      v_status := 'E';
      v_msgerror := 'New Emp.[ERROR] ';
    end;
    begin
      process_reemployment(v_codcomp  ,v_endate ,v_coduser , null, v_sum ,v_err,v_user,v_erruser);
      v_msgerror := v_msgerror||',Re Emp.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Re Emp.[Error]';
    end;
    begin
      process_probation(v_codcomp  ,v_endate ,v_coduser , v_sum ,v_err);
      v_msgerror := v_msgerror||',Probat.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Probat.[Error]';
    end;
    begin
      process_movement(v_codcomp,v_endate,v_coduser,null,null,null,v_sum,v_err,v_user,v_erruser);
      v_msgerror := v_msgerror||',Movement.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Movement.[Error]';
    end;
    begin
      process_mistake(v_codcomp  ,v_endate ,v_coduser , v_sum ,v_err);
      v_msgerror := v_msgerror||',Mistake.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Mistake.[Error]';
    end;
    begin
      process_exemption(v_codcomp,null,v_endate,v_coduser,v_sum,v_err);-->> user22 : 07/10/2017 : STA4-1701 || process_exemption(v_codcomp,v_endate,v_coduser,v_sum,v_err);
      v_msgerror := v_msgerror||',Exemption.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Exemption.[Error]';
    end;
    begin
      process_tsecpos(v_codcomp  ,v_endate ,v_coduser , v_sum ,v_err); --user36 10/05/2022
      v_msgerror := v_msgerror||',Expired 2nd Pos.[Complete]';
    exception  when others then
      v_status := 'E';
      v_msgerror := v_msgerror ||',Expired 2nd Pos.[Error]';
    end;

    update tautolog set status = v_status ,dteproen = sysdate , remark = v_msgerror
     where codapp  = 'HRPM91B'
       and dtecall = v_endate;
    commit;
  end;

  -- 1. ttexempt
  procedure process_exemption(p_codcomp in varchar2,p_codempid in varchar2,p_endate in date,p_coduser in varchar2,
                                            o_sum out number,o_err out number, p_dtetim in date default sysdate) is
    v_zupdsal     varchar2(1 char);

    v_secu        boolean;
    v_staupd      ttexempt.staupd%type; -- exist from temploy1 = 'U' else = 'N'
    v_found2      varchar2(1 char);          -- exist from temploy2
    v_found3      varchar2(1 char);          -- exist from tbcklst
    v_codempid    ttexempt.codempid%type;
    v_dteeffec    ttexempt.dteeffec%type;
    v_numseq      thismove.numseq%type;
    v_codtrn      thismove.codtrn%type := '0006';
    v_typmove     thismove.typmove%type;
    v_numoffid    tbcklst.numoffid%type;    -- for select from tbcklst
    v_fileexe     varchar2(3 char);
    t_staemp      temploy1.staemp%type := '9';
    t_numoffid    temploy2.numoffid%type;
    v_desinfo     tbcklst.desinfo%type;

    --
    v_sum         number;
    v_err         number;
    v_chksecu     varchar2(1 char);
    v_zminlvl     number;
    v_zwrklvl     number;

    cursor c_ttexempt is
			select codempid, dteeffec, codcomp, codjob, codpos, numlvl, codexemp,
			       numexemp, typdoc, numannou, desnote, amtsalt, amtotht, codsex,
			       codedlv, totwkday, flgblist, staupd, flgrp, dteupd, coduser,
			       codappr, dteappr, codempmt, jobgrade, codgrpgl
			  from ttexempt i
		 	 where codcomp  like p_codcomp||'%'
		     and codempid = nvl(p_codempid,codempid)-- user22 : 07/10/2017 : STA4-1701 || +
		     and staupd   = 'C'
			   and dteeffec <= p_endate
		order by codempid,dteeffec;

    cursor c_temploy1 is
          select   rowid,codempid,codcomp,codpos,codjob,codbrlc,codempmt,numlvl,typemp,typpayroll,
                   staemp,codcalen,dteempmt,dteempdb,codsex,jobgrade,codgrpgl,
                   namempe,namempt,namemp3,namemp4,namemp5,
                   namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                   namlaste,namlastt,namlast3,namlast4,namlast5,codtitle,numappl
           from    temploy1
          where    codempid   =  v_codempid;

  begin
    v_sum  := 0;
    v_err  := 0;
    begin
       select typmove into v_typmove
         from tcodmove
        where codcodec = v_codtrn;
    exception when no_data_found then v_typmove := 'M';
    end;

    if p_coduser is not null then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
          into v_zminlvl,v_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;

    for i in c_ttexempt loop
      if p_coduser = 'AUTO' then
        v_secu   :=  true;
      else
        v_secu   :=  secur_main.secur1(i.codcomp,i.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
      end if;
      if v_secu then
        v_chksecu         :=  'Y';
        v_codempid        :=  i.codempid;
        v_dteeffec        :=  i.dteeffec;
        v_staupd          :=  'C';
        for j in c_temploy1 loop  -- exist in temploy1
          v_staupd  :=  'U';
          begin   -- select for numseq
            select max(numseq) into v_numseq
              from thismove
             where codempid = v_codempid
               and dteeffec = v_dteeffec;
          exception when no_data_found then v_numseq := 0;
          end;
          v_numseq  :=  nvl(v_numseq,0) + 1;
          --create data to table 'THISMOVE'
          insert into thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                               codpos,codjob,codbrlc,codempmt,numlvl,typemp,typpayroll,
                               staemp,codexemp,desnote,typdoc,codappr,flginput,flgadjin,codcalen,typmove,
                               dteempmt,jobgrade,codgrpgl,
                               codcreate,coduser)
                        values(v_codempid,v_dteeffec,v_numseq,v_codtrn,i.numannou,j.codcomp,
                               j.codpos,j.codjob,j.codbrlc,j.codempmt,j.numlvl,j.typemp,j.typpayroll,
                               j.staemp,i.codexemp,i.desnote,i.typdoc,i.codappr,'N','N',j.codcalen,v_typmove,
                               j.dteempmt,j.jobgrade,j.codgrpgl,
                               p_coduser ,p_coduser);

          if i.flgblist = 'Y' then   -- have data to back list table
            v_found2   := 'Y';
            begin   -- select for variable temploy2
              select numoffid into t_numoffid
                from temploy2
               where codempid = v_codempid;
            exception when no_data_found then v_found2 := 'N';
            end;
            begin
              select get_label_name('HRPM91BP2','102',10)
                into v_desinfo
                from ttpunsh
               where codempid   = v_codempid
                 and dtestart   <= v_dteeffec
                 and flgexempt  = 'Y'
                 and flgblist   = 'Y'
                 and rownum     <= 1;
            exception when no_data_found then
              v_desinfo   := get_label_name('HRPM91BP2','102',20);
            end;
            -- exist temploy2 and id. no. not null
            if v_found2 = 'Y' and t_numoffid is not null and  t_numoffid <> ' ' then
              v_found3 := 'Y';
              begin   -- select for variable tbcklst
                select numoffid into v_numoffid
                  from tbcklst
                 where tbcklst.numoffid = t_numoffid;
              exception when no_data_found then v_found3 := 'N';
              end;
              if v_found3 = 'N' then
                --create data to table 'TBCKLST'
               insert into tbcklst(numoffid,codtitle,codempid,namempe,namempt,namemp3,namemp4,namemp5,
                                   dteempmt,codcomp,codpos,dteeffex,codexemp,
                                   desexemp,dteempdb,codsex,
                                   namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                   namlaste,namlastt,namlast3,namlast4,namlast5,numappl,
                                   desinfo,
                                   codcreate,coduser)
                            values(t_numoffid,j.codtitle,v_codempid,j.namempe,j.namempt,j.namemp3,j.namemp4,j.namemp5,
                                   j.dteempmt,j.codcomp,j.codpos,v_dteeffec,i.codexemp,
                                   i.desnote,j.dteempdb,j.codsex,
                                   j.namfirste,j.namfirstt,j.namfirst3,j.namfirst4,j.namfirst5,
                                   j.namlaste,j.namlastt,j.namlast3,j.namlast4,j.namlast5,j.numappl,
                                   v_desinfo,
                                   p_coduser,p_coduser);
              else--update data to table 'TBCKLST'
                update tbcklst
                   set codempid    = v_codempid,        namempe     = j.namempe,
                       namempt     = j.namempt,         namemp3     = j.namemp3,
                       namemp4     = j.namemp4,         namemp5     = j.namemp5,
                       dteempmt    = j.dteempmt,        codcomp     = j.codcomp,
                       codpos      = j.codpos,          dteeffex    = v_dteeffec,
                       codexemp    = i.codexemp,        desexemp    = i.desnote,
                       dteempdb    = j.dteempdb,        codsex      = j.codsex,
                       namfirste   = j.namfirste,       namfirstt   = j.namfirstt,
                       namfirst3   = j.namfirst3,       namfirst4   = j.namfirst4,
                       namfirst5   = j.namfirst5,       namlaste    = j.namlaste,
                       namlastt    = j.namlastt,        namlast3    = j.namlast3,
                       namlast4    = j.namlast4,        namlast5    = j.namlast5,
                       codtitle    = j.codtitle,        coduser     = p_coduser ,
                       numappl     = j.numappl
                 where numoffid = v_numoffid;
              end if;  -- if v_found3 = 'Y' - exist tbcklst
            end if;  --if v_found2 = 'Y' and t_numoffid is not null - exist temploy2
          end if;  --if i.flgblist = 'Y' - include in black list
          -- update status employee to 'TEMPLOY1'
          update temploy1
             set staemp   = t_staemp,   -- 9-resign
                  dteeffex = v_dteeffec, coduser     = p_coduser
           where rowid = j.rowid;

          update tusrprof
             set flgact = '2'
           where codempid = v_codempid;

        end loop;  --for j in c_temploy1 loop

        -- update staupd to 'TTEXEMPT'
        update ttexempt
           set staupd    = v_staupd,   -- exist temploy1 = 'U' else = 'N'
               coduser   = p_coduser
         where codempid  = v_codempid
           and dteeffec  = v_dteeffec;

        if v_staupd <> 'C' then
          v_sum   :=  v_sum + 1;
        else
          v_err   :=  v_err + 1;
          ins_errtmp(i.codempid,i.codcomp,i.codpos,'HR2010','TEMPLOY1',v_topic7,p_coduser);

          -- insert batch process detail
          hcm_batchtask.insert_batch_detail(
            p_codapp   => global_v_batch_codapp,
            p_coduser  => p_coduser,
            p_codalw   => global_v_batch_codapp||'6',
            p_dtestrt  => p_dtetim,
            p_item01  => i.codempid,
            p_item02  => i.codcomp,
            p_item03  => i.codpos,
            p_item04  => 'HR2055',
            p_item05  => 'TEMPLOY1',
            p_item06  => v_topic7,
            p_item07  => p_coduser
          );
        end if;
      end if; --if v_secu then
    end loop; --for i in c_ttexempt loop
    o_sum   := v_sum;
    o_err   := v_err;
    commit;
  end;

  -- 2. Mistake
  procedure process_mistake (p_codcomp  in  varchar2,p_endate   in date,p_coduser in varchar2,
                             o_sum      out number ,o_err out number, p_dtetim in date default sysdate) is
    v_zupdsal      varchar2(1 char);
    v_secu         boolean;
    v_staupd       ttmistk.staupd%type;  -- exist from temploy1 = 'U' else = 'N'
    v_exist        varchar2(1 char);    -- exist from thismist / thispun
    v_codempid     ttmistk.codempid%type;
    v_dteeffec     ttmistk.dteeffec%type;
    v_codpunsh     ttpunsh.codpunsh%type;
    v_numseq       ttpunsh.numseq%type;
    v_codtrn9      tcodmove.codcodec%type := '0006';  -- for codtrn = '0006'-resign
    t_codempid     temploy1.codempid%type;  -- for select when exist
    t1_totwkday    number;
    t2_numoffid    temploy2.numoffid%type;
    t3_amtincom1   temploy3.amtincom1%type;
    t3_amtincom2   temploy3.amtincom2%type;
    t3_amtincom3   temploy3.amtincom3%type;
    t3_amtincom4   temploy3.amtincom4%type;

    t3_amtincom5   temploy3.amtincom5%type;
    t3_amtincom6   temploy3.amtincom6%type;
    t3_amtincom7   temploy3.amtincom7%type;
    t3_amtincom8   temploy3.amtincom8%type;
    t3_amtincom9   temploy3.amtincom9%type;
    t3_amtincom10  temploy3.amtincom10%type;
    t3_amtincomoth ttexempt.amtotht%type;

    tm_amtincom1   number;
    tm_amtincom2   number;
    tm_amtincom3   number;
    tm_amtincom4   number;
    tm_amtincom5   number;

    tm_amtincom6   number;
    tm_amtincom7   number;
    tm_amtincom8   number;
    tm_amtincom9   number;
    tm_amtincom10  number;
    tm_amtothr     number;
    tm_amtotday    number;
    tm_amtotmth    number;
    -- variable for ttpminf
    tp_numseq      ttpminf.numseq%type;
    v_stperiod     varchar2(10 char);
    v_enperiod     varchar2(10 char);
    v_codcompy     tdtepay.codcompy%type;

    v_typpayroll     tdtepay.typpayroll%type;
    --
    v_sum          number;
    v_err          number;
    v_chksecu      varchar2(1 char);
    v_zminlvl      number;
    v_zwrklvl      number;
    v_table        varchar2(30 char);
    v_error        varchar2(30 char);

    cursor c_ttmistk is
      select codempid,dteeffec,numhmref,refdoc,codcomp,codpos,codjob,numlvl,dteempmt,codempmt,typemp,typpayroll,desmist1,numannou,codappr,dteappr,dteupd,coduser ,dtemistk,jobgrade,codgrpgl,codmist
        from ttmistk
       where codcomp    like p_codcomp||'%'
         and staupd     = 'C'
         and dteeffec   <= p_endate
    order by codempid,dteeffec;

    cursor c_ttpunsh is
      select dteeffec,codpunsh,codempid,numseq,dtestart,dteend,codcomp,codjob,codpos,numlvl,
  --          ,codedlv,codsex
             staupd,typpun,remark,flgexempt,codexemp,flgblist,jobgrade,codgrpgl,dteupd,coduser,flgssm 
        from ttpunsh
       where dteeffec   = v_dteeffec
         and codempid   = v_codempid;

    cursor c_ttpunded is
     select dteeffec,codpunsh,codempid,codcomp,dteyearst,dtemthst,numprdst,dteyearen,dtemthen,numprden,codpay,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,amtincded1,amtincded2,amtincded3,amtincded4,amtincded5,amtincded6,amtincded7,amtincded8,amtincded9,amtincded10,amtded,amttotded,dteupd,coduser
       from ttpunded
      where dteeffec   = v_dteeffec
        and codempid   = v_codempid
        and codpunsh   = v_codpunsh;

    cursor c_temploy1 is
      select codempid,dteempmt,qtywkday,codcomp,codpos,codjob,numlvl,codcalen,codempmt,typemp,typpayroll,codbrlc,flgatten,codsex,codedlv,jobgrade,codgrpgl,staemp
        from temploy1
       where codempid   = v_codempid
         and staemp   in ('1','3','9');-- user22 : 17/05/2016 : STA3590267 || and staemp    in ('1','3');

    cursor c_tdtepay is
      select dtestrt,dteend,dteyrepay,dtemthpay,numperiod
        from tdtepay
       where codcompy   = v_codcompy
         and typpayroll = v_typpayroll
         and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') between v_stperiod and v_enperiod
    order by dteyrepay,dtemthpay,numperiod;

  begin
    v_sum  := 0;
    v_err  := 0;
    if p_coduser is not null then
      begin
       select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
         into v_zminlvl,v_zwrklvl
         from tusrprof
        where coduser = p_coduser;
      exception when others then null;
      end;
    end if;

    for i in c_ttmistk loop
      if p_coduser = 'AUTO' then
        v_secu  :=  true;
      else
        v_secu   :=  secur_main.secur1(i.codcomp,i.numlvl,p_coduser,
        v_zminlvl,v_zwrklvl,v_zupdsal);
      end if;
      if v_secu then
        v_chksecu    :=  'Y';
        v_codempid   :=  i.codempid;
        v_dteeffec   :=  i.dteeffec;
        v_staupd     :=  'C';
        v_error      := '2010';
        v_table      := 'TEMPLOY1';
        <<cal_loop>>
        for j in c_temploy1 loop  -- exist in temploy1
  --<< user22 : 17/05/2016 : STA3590267 ||
          if j.staemp = '9' then
            v_staupd  := 'N';
            v_error   := 'HR2101';
            v_table   := null;
            exit cal_loop;
          end if;
  -->> user22 : 17/05/2016 : STA3590267 ||
          v_staupd    := 'U';
          t1_totwkday := i.dteeffec - j.dteempmt + nvl(j.qtywkday,0);   --service year

          begin   -- select for variable temploy2
           select numoffid into t2_numoffid
             from temploy2
            where temploy2.codempid = v_codempid;
          exception when no_data_found then
  --<< user22 : 17/05/2016 : STA3590267 ||
            v_staupd  := 'C';
            v_error   := 'HR2101';
            v_table   := 'TEMPLOY2';
            exit cal_loop;
  -->> user22 : 17/05/2016 : STA3590267 ||
          end;

          begin   -- select for variable temploy3
           select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                  amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
             into t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,
                  t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10
             from temploy3
            where codempid = v_codempid;
          exception when no_data_found then
  --<< user22 : 17/05/2016 : STA3590267 ||
            v_staupd  := 'C';
            v_error   := 'HR2101';
            v_table   := 'TEMPLOY3';
            exit cal_loop;
  -->> user22 : 17/05/2016 : STA3590267 ||
          end;
          tm_amtincom1  := stddec(t3_amtincom1,v_codempid,v_chken);
          tm_amtincom2  := stddec(t3_amtincom2,v_codempid,v_chken);
          tm_amtincom3  := stddec(t3_amtincom3,v_codempid,v_chken);
          tm_amtincom4  := stddec(t3_amtincom4,v_codempid,v_chken);
          tm_amtincom5  := stddec(t3_amtincom5,v_codempid,v_chken);
          tm_amtincom6  := stddec(t3_amtincom6,v_codempid,v_chken);
          tm_amtincom7  := stddec(t3_amtincom7,v_codempid,v_chken);
          tm_amtincom8  := stddec(t3_amtincom8,v_codempid,v_chken);
          tm_amtincom9  := stddec(t3_amtincom9,v_codempid,v_chken);
          tm_amtincom10 := stddec(t3_amtincom10,v_codempid,v_chken);

          t3_amtincomoth := nvl(tm_amtincom2,0) + nvl(tm_amtincom3,0) + nvl(tm_amtincom4,0) + nvl(tm_amtincom5,0) +
                            nvl(tm_amtincom6,0) + nvl(tm_amtincom7,0) + nvl(tm_amtincom8,0) + nvl(tm_amtincom9,0) + nvl(tm_amtincom10,0);
          v_exist := 'Y';
          begin   -- check record is exist thismist
            select codempid into t_codempid
              from thismist
             where codempid = v_codempid
               and dteeffec = v_dteeffec;
          exception when no_data_found then v_exist := 'N';
          end;

          if v_exist = 'N' then
              --create data to table 'THISMIST'
            insert into
                thismist (codempid,dteeffec,numhmref,refdoc,codcomp,codpos,codjob,numlvl,
                          dteempmt,codempmt,typemp,typpayroll,desmist1,numannou,codappr,
                          dteappr,dtemistk,jobgrade,codgrpgl,codmist,
                          codcreate,coduser)
                   values(v_codempid,v_dteeffec,i.numhmref,i.refdoc,j.codcomp,
                          j.codpos,j.codjob,j.numlvl,j.dteempmt,j.codempmt,j.typemp,j.typpayroll,
                          i.desmist1,i.numannou,i.codappr,i.dteappr,i.dtemistk,j.jobgrade,j.codgrpgl,i.codmist,
                          p_coduser,p_coduser);
          else
              --update data to table 'THISMIST'
            update thismist set codempid = i.codempid,      numhmref   = i.numhmref,
                                  codcomp  = j.codcomp,       codpos     = j.codpos,
                                  codjob   = j.codjob,        numlvl     = j.numlvl,
                                  dteempmt = j.dteempmt,      codempmt   = j.codempmt,

                                  typemp   = j.typemp,        typpayroll = j.typpayroll,
                                  desmist1 = i.desmist1,      numannou   = i.numannou,
                                  jobgrade = j.jobgrade,      codgrpgl   = j.codgrpgl,
                                  coduser  = p_coduser
             where codempid = v_codempid
               and dteeffec = v_dteeffec;
          end if;  --if v_exist = 'N' not exist table thismist

          for k in c_ttpunsh loop   -- exist in 'ttpunsh'
            v_codpunsh := k.codpunsh;
            v_exist    := 'Y';

            begin   -- check record is exist thispun
              select codempid into t_codempid
                from thispun
               where codempid = v_codempid
                 and dteeffec = v_dteeffec
                 and codpunsh = v_codpunsh
                 and numseq = k.numseq;
               --fetch first row only;
            exception when no_data_found then v_exist := 'N';
            end;

            if v_exist = 'N' then--create data to table 'THISPUN'
              insert into thispun (dteeffec,codpunsh,codempid,numseq,dtestart,dteend,codcomp,codjob,
                                   codpos,numlvl,codsex,codedlv,staupd,typpun,remark,flgexempt,codexemp,
                                   flgblist,jobgrade,codgrpgl,flgssm,
                                   coduser,codcreate)
                            values(v_dteeffec,v_codpunsh,v_codempid,k.numseq,k.dtestart,k.dteend,j.codcomp,
                                   j.codjob,j.codpos,j.numlvl,j.codsex,j.codedlv,'U',k.typpun,k.remark,k.flgexempt,
                                   k.codexemp,k.flgblist,j.jobgrade,j.codgrpgl,k.flgssm,
                                   p_coduser,p_coduser);

            else--update data to table 'THISPUN'
              update thispun set dtestart = k.dtestart,      dteend   = k.dteend,
                                 codcomp  = j.codcomp,       codpos   = j.codpos,
                                 codjob   = j.codjob,        numlvl   = j.numlvl,
                                 codedlv  = j.codedlv,
                                 flgexempt= k.flgexempt,     typpun   = k.typpun,
                                 codexemp = k.codexemp,      flgblist = k.flgblist,
                                 jobgrade = j.jobgrade,      codgrpgl = j.codgrpgl,
                                 flgssm  = k.flgssm,
                                 coduser  = p_coduser
               where codempid = v_codempid
                 and dteeffec = v_dteeffec
                 and codpunsh = v_codpunsh
                 and numseq   = v_numseq;
            end if;  -- if v_exist = 'N' not exist table thispun

            if  k.flgexempt = 'Y' then  -- type of punsh is 3-black list create 'TTEXEMPT,TBCKLST'
                null;
            --#5770   กรณีที่มีกระทำผิดลงโทษ ให้พนักงานพ้นสภาพ HRPM91B ไม่ต้องสร้าง TTPMINF CODTRN = 0006 เพราะมีการสร้างตั้งแต่ HRPM44U (อนุมัติการเคลื่อนไหว) ( รบกวนตรวจสอบ TTEXEMPT ด้วยนะครับ ว่ามีการสร้างหรือ Update ค่าต่อหรือไม่)

--              v_exist := 'Y';
--              begin
--                select codempid into t_codempid
--                  from ttexempt
--                 where codempid = v_codempid
--                   and dteeffec = k.dtestart;--User37 #5725 1.PM Module 20/04/2021 v_dteeffec;
--              exception when no_data_found then v_exist := 'N';
--              end;
--              if v_exist = 'N' then-- create table 'TTEXEMPT'
--                insert into ttexempt (codempid,dteeffec,codcomp,codjob,codpos,numlvl,
--                                      codexemp,typdoc,numannou,amtsalt,amtotht,
--                                      codsex,codedlv,totwkday,flgblist,staupd,flgrp,
--                                      codempmt,desnote,jobgrade,codgrpgl,flgssm,
--                                      codcreate,coduser)
--                               values(v_codempid,k.dtestart/*v_dteeffec*/,j.codcomp,j.codjob,j.codpos,j.numlvl,
--                                      k.codexemp,'1',i.numannou,nvl(t3_amtincom1,0),t3_amtincomoth,
--                                      j.codsex,j.codedlv,t1_totwkday,k.flgblist,'C','N',
--                                      i.codempmt,k.remark,
--                                      j.jobgrade,j.codgrpgl,k.flgssm,
--                                      p_coduser,p_coduser);
--              else-- update table 'TTEXEMPT'
--                update ttexempt set codcomp  = j.codcomp,       codjob   = j.codjob,
--                                    codpos   = j.codpos,        numlvl   = j.numlvl,
--                                    codexemp = k.codexemp,      typdoc   = '1',
--                                    numannou = i.numannou,      amtsalt  = nvl(t3_amtincom1,0),
--                                    amtotht  = t3_amtincomoth,  codsex   = j.codsex,
--                                    jobgrade = j.jobgrade,      codgrpgl = j.codgrpgl,
--                                    codedlv  = j.codedlv,       totwkday = t1_totwkday,
--                                    flgblist = k.flgblist,      staupd   = 'C',
--                                    flgrp    = 'N',             flgssm   = k.flgssm ,
--                                    coduser  = p_coduser
--                 where codempid = v_codempid
--                   and dteeffec = k.dtestart;--User37 #5725 1.PM Module 20/04/2021 v_dteeffec;
--              end if;  -- end create/update table 'TTEXEMPT'
--
--              begin   -- select for ttpminf.numseq
--                select max(numseq) into tp_numseq
--                  from ttpminf
--                 where codempid  = v_codempid
--                   and dteeffec  = k.dtestart;--User37 #5725 1.PM Module 20/04/2021 v_dteeffec;
--              exception when no_data_found then tp_numseq := 0;
--              end;
--              tp_numseq  :=  nvl(tp_numseq,0) + 1;
--              -- create table 'TTPMINF'
--              insert into ttpminf(codempid,dteeffec,numseq,codtrn,codcomp,
--                                  codpos,codjob,numlvl,codempmt,codcalen,
--                                  codbrlc,typpayroll,typemp,flgatten,
--                                  flgal,flgrp,flgap,flgbf,flgtr,flgpy,codexemp,staemp,
--                                  jobgrade,coduser,codcreate)
--                           values(v_codempid,k.dtestart/*v_dteeffec*/,tp_numseq,v_codtrn9,j.codcomp,
--                                  j.codpos,j.codjob,j.numlvl,j.codempmt,j.codcalen,
--                                  j.codbrlc,j.typpayroll,j.typemp,j.flgatten,
--                                  'N','N','N','N','N','N',k.codexemp,'9',
--                                  j.jobgrade,p_coduser,p_coduser);

            elsif k.typpun in ('1','5')  then -- type of punsh is 1- ????????????????????? create 'TOTHINC'
                 for m in  c_ttpunded loop
                         if m.codpay is not null  then
                                    v_stperiod   := m.dteyearst||lpad(m.dtemthst,2,'0')||lpad(m.numprdst,2,'0');
                                    v_enperiod   := m.dteyearen||lpad(m.dtemthen,2,'0')||lpad(m.numprden,2,'0');
                                    v_codcompy   := hcm_util.get_codcomp_level(m.codcomp,'1');
                                    v_typpayroll := i.typpayroll;
                                    for n in  c_tdtepay loop
                                          ins_tempinc(i.codempid,n.numperiod,m.codpay,n.dtestrt,n.dteend,m.amtded,p_coduser);
                                    end loop;
                         end if;
                 end loop;--for m in  c_ttpunded loop

            end if;  --if k.typpun = '3' type of punsh is 3-black list

            for l in c_ttpunded loop   -- exist in 'ttpunded'
              v_exist    := 'Y';
              begin   -- check record is exist thispund
                select codempid into t_codempid
                 from  thispund
                where codempid = v_codempid
                  and dteeffec = v_dteeffec
                  and codpunsh = v_codpunsh;
              exception when no_data_found then v_exist := 'N';
              end;
              if v_exist = 'N' then--create data to table 'THISPUND'
                insert into thispund (dteeffec,codpunsh,codempid,codcomp,dteyearst,dtemthst,numprdst,dteyearen,
                                      dtemthen,numprden,codpay,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                      amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,amtincded1,amtincded2,
                                      amtincded3,amtincded4,amtincded5,amtincded6,amtincded7,amtincded8,amtincded9,
                                      amtincded10,amtded,amttotded,coduser,codcreate )
                               values(v_dteeffec,v_codpunsh,v_codempid,j.codcomp,l.dteyearst,l.dtemthst,l.numprdst,l.dteyearen,
                                      l.dtemthen,l.numprden,l.codpay,l.amtincom1,l.amtincom2,l.amtincom3,l.amtincom4,l.amtincom5,
                                      l.amtincom6,l.amtincom7,l.amtincom8,l.amtincom9,l.amtincom10,l.amtincded1,l.amtincded2,
                                      l.amtincded3,l.amtincded4,l.amtincded5,l.amtincded6,l.amtincded7,l.amtincded8,l.amtincded9,
                                      l.amtincded10,l.amtded,l.amttotded,p_coduser,p_coduser);
              else --update data to table 'THISPUND'
                update thispund  set codcomp  = l.codcomp,      dteyearst  = l.dteyearst,
                                    dtemthst  = l.dtemthst,     numprdst   = l.numprdst,
                                    dteyearen = l.dteyearen,    dtemthen   = l.dtemthen,
                                    numprden  = l.numprden,     codpay     = l.codpay,
                                    amtincom1 = l.amtincom1,    amtincom2  = l.amtincom2,
                                    coduser   = p_coduser
                where codempid = v_codempid
                  and dteeffec = v_dteeffec
                  and codpunsh = v_codpunsh;
              end if;-- if v_exist = 'N' not exist table thispund
            end loop; --for l in c_ttpunded loop
          end loop;  --for k in c_ttpunsh loop
        end loop;  --for j in c_temploy1 loop
       -- update staupd to 'TTMISTK  , TTPUNSH'
        update ttmistk
           set staupd    = v_staupd,   -- exist temploy1 = 'U' else = 'N'
               coduser   = p_coduser
         where codempid  = i.codempid
           and dteeffec  = i.dteeffec;

        update ttpunsh
           set staupd    = v_staupd,   -- exist temploy1 = 'U' else = 'N'
              coduser     = p_coduser
         where codempid  = i.codempid
           and dteeffec  = i.dteeffec;

        if v_staupd = 'U' then
          v_sum   :=  v_sum + 1;
        else
          ins_errtmp(i.codempid,i.codcomp,i.codpos,v_error,v_table,v_topic6,p_coduser);
          v_err   :=  v_err + 1;

          -- insert batch process detail
          hcm_batchtask.insert_batch_detail(
            p_codapp   => global_v_batch_codapp,
            p_coduser  => p_coduser,
            p_codalw   => global_v_batch_codapp||'4',
            p_dtestrt  => p_dtetim,
            p_item01  => i.codempid,
            p_item02  => i.codcomp,
            p_item03  => i.codpos,
            p_item04  => v_error,
            p_item05  => v_table,
            p_item06  => v_topic6,
            p_item07  => p_coduser
          );
        end if;
      end if; --if v_secu then
    end loop; --for i in c_ttmistk loop
    commit;
    o_sum   := v_sum;
    o_err   := v_err;
  --exception when others then
  --    update_tautolog('E');
  end;

  procedure ins_tempinc ( p_codempid   in temploy1.codempid%type,
                          p_periodpay  in  tempinc.periodpay%type,
                          p_codpay     in tempinc.codpay%type,
                          p_dtestrt    in tempinc.dtestrt%type,
                          p_dteend     in tempinc.dteend%type,
                          p_amtpay     in tempinc.amtfix%type,
                          p_coduser    in tempinc.coduser%type) is

      p_typemp  tothinc.typemp%type := ' ';
      v_exist      boolean;
      v_amt       number:=0;

  cursor c_tempinc is
      select codempid,stddec(amtfix,codempid,v_chken) amtp,rowid
      from   tempinc
      where  codempid  = p_codempid
      and    codpay    = p_codpay
      and    dtestrt   = p_dtestrt
      for update;

  begin
      v_exist := false;
      for r_tempinc in c_tempinc loop
          v_exist := true;
          v_amt   := r_tempinc.amtp + stddec(p_amtpay,r_tempinc.codempid,v_chken);
          update tempinc
               set amtfix    =   stdenc(v_amt,codempid,v_chken),
                     dteend   =   greatest(nvl(dteend,p_dteend),p_dteend) ,
                     coduser  =   p_coduser
           where rowid = r_tempinc.rowid;

      end loop;  --for r_tempinc in c_tempinc loop

      if not v_exist then
--          insert into tothinc(codempid,dteyrepay,dtemthpay,numperiod,codpay,codcomp,
--  --        ,codcurr
--                              typpayroll,typemp,amtpay,codsys,dteupd,coduser,codcreate)
--                       values(p_codempid,p_dteyrepay,p_dtemthpay,p_numperiod,p_codpay,p_codcomp,
--  --                     ,p_codcurr
--                              p_typpayroll,p_typemp,p_amtpay,p_codsys,p_dteupd,p_coduser,p_coduser);
          insert into tempinc(codempid,codpay,dtestrt,dteend,
                                      amtfix,periodpay,flgprort,
                                      coduser,codcreate)
                           values(p_codempid,p_codpay,p_dtestrt,p_dteend,
                                      p_amtpay,  p_periodpay ,'N',
                                      p_coduser,p_coduser);

      end if;  --if not v_exist then

   end;

  -- 3. Movement
  procedure process_movement(p_codcomp  in varchar2,
                             p_endate   in date,
                              p_coduser  in varchar2,
                              p_codempid in varchar2,
                              p_dteeffec in date,
                              p_codtrn   in varchar2,
                              o_sum      out number,
                              o_err      out number,
                              o_user     out number,
                              o_erruser  out number,
                              p_dtetim   in date default sysdate) is

    v_zupdsal        varchar2(1 char);
    v_amtincom     temploy3.amtincom1%type;
    v_amtincadj     temploy3.amtincom1%type;
    v_secu         boolean;
    v_staupd       ttmovemt.staupd%type;   -- Exist from temploy1 = 'U' else = 'C'

    v_fnsecpos     varchar2(1 char);    -- Exist from tsecpos
    v_codempid     ttmovemt.codempid%type;
    v_dteeffec     ttmovemt.dteeffec%type;
    v_numseq       thismove.numseq%type;
    v_seq          thismove.numseq%type;
    v_codtrn       ttmovemt.codtrn%type;  -- For typmove = '10'-Cancel Position
    v_typmove      thismove.typmove%type;
    -- Variable for temploy1
    t_dteefpos     temploy1.dteefpos%type;
    t_dteeflvl     temploy1.dteeflvl%type;
    t_dteefstep    temploy1.dteefstep%type;
    t_codsex       temploy1.codsex%type;
    t_codedlv      temploy1.codedlv%type;

    -- Variable for temploy3
    t3_amtincom1   temploy3.amtincom1%type;
    t3_amtincom2   temploy3.amtincom2%type;
    t3_amtincom3   temploy3.amtincom3%type;
    t3_amtincom4   temploy3.amtincom4%type;
    t3_amtincom5   temploy3.amtincom5%type;
    t3_amtincom6   temploy3.amtincom6%type;
    t3_amtincom7   temploy3.amtincom7%type;
    t3_amtincom8   temploy3.amtincom8%type;
    t3_amtincom9   temploy3.amtincom9%type;
    t3_amtincom10  temploy3.amtincom10%type;
    t3_amtothr     temploy3.amtothr%type;
    -- Variable for tsecpos

    t_numseq       tsecpos.numseq%type;
    t_seqcancel    ttmovemt.numseq%type;
    -- Variable for treqest1
    t_totqtyact   number;
    t_totreq       number;
    t_stareq       treqest1.stareq%type;
    -- Variable for treqest2
    t_qtyact       treqest2.qtyact%type;
    t_qtyreq       treqest2.qtyreq%type;
    -- Variable for thismove
    tm_amtincom1      number;
    tm_amtincom2      number;
    tm_amtincom3      number;

    tm_amtincom4      number;
    tm_amtincom5      number;
    tm_amtincom6      number;
    tm_amtincom7      number;
    tm_amtincom8      number;
    tm_amtincom9      number;
    tm_amtincom10     number;
    tm_amtothr2       number;
    tm_amtothr        number;
    tm_amtotday       number;
    tm_amtotmth       number;
    -- Variable for Encrypt
    tm_en_amtincom1   varchar2(50 char);

    tm_en_amtincom2   varchar2(50 char);
    tm_en_amtincom3   varchar2(50 char);
    tm_en_amtincom4   varchar2(50 char);
    tm_en_amtincom5   varchar2(50 char);
    tm_en_amtincom6   varchar2(50 char);
    tm_en_amtincom7   varchar2(50 char);
    tm_en_amtincom8   varchar2(50 char);
    tm_en_amtincom9   varchar2(50 char);
    tm_en_amtincom10  varchar2(50 char);
    tm_en_amtothr2    varchar2(50 char);
    tm_en_amtday2     varchar2(50 char);--29/04/2552
    tm_en_amtothr     varchar2(50 char);
    tm_en_amtotday    varchar2(50 char);

    tm_en_amtotmth    varchar2(50 char);

    -- Variable for tfincadj
    tf_numseq         tfincadj.numseq%type;

    to_amtincom1      number;
    to_amtincom2      number;
    to_amtincom3      number;
    to_amtincom4      number;
    to_amtincom5      number;
    to_amtincom6      number;
    to_amtincom7      number;
    to_amtincom8      number;

    to_amtincom9      number;
    to_amtincom10     number;

    to_en_amtincom1   varchar2(50 char);
    to_en_amtincom2   varchar2(50 char);
    to_en_amtincom3   varchar2(50 char);
    to_en_amtincom4   varchar2(50 char);
    to_en_amtincom5   varchar2(50 char);
    to_en_amtincom6   varchar2(50 char);
    to_en_amtincom7   varchar2(50 char);
    to_en_amtincom8   varchar2(50 char);
    to_en_amtincom9   varchar2(50 char);
    to_en_amtincom10  varchar2(50 char);


    to_codincom1   tcontpms.codincom1%type;
    to_codincom2   tcontpms.codincom2%type;
    to_codincom3   tcontpms.codincom3%type;
    to_codincom4   tcontpms.codincom4%type;
    to_codincom5   tcontpms.codincom5%type;
    to_codincom6   tcontpms.codincom6%type;
    to_codincom7   tcontpms.codincom7%type;
    to_codincom8   tcontpms.codincom8%type;
    to_codincom9   tcontpms.codincom9%type;
    to_codincom10  tcontpms.codincom10%type;
    ---
    v_sum         number;

    v_err         number;
    v_chksecu     varchar2(1 char);
    v_zminlvl     number;
    v_zwrklvl     number;
    v_table       varchar2(30 char);
    v_pass        number;
    v_user				number;
    v_erruser		  number;
    v_error       varchar2(30 char);

    cursor c_movemt is
      select codempid,dteeffec,numseq,codcompt,numlvlt
        from ttmovemt
       where dteeffec <= p_endate
         and codcompt like p_codcomp||'%'
         and staupd   = 'C'
         and codempid = nvl(p_codempid,codempid)
         and dteeffec = nvl(p_dteeffec,dteeffec)
         and codtrn   = nvl(p_codtrn,codtrn)
  order by codempid,dteeffec,numseq;

    cursor c_ttmovemt is
      select codempid, dteeffec, numseq, codtrn, codcomp, codpos, codjob, numlvl,
  --    flgreq,
             codbrlc, codcalen, flgatten, dteeffpos, stapost2, dteduepr,
             numreqst, codcompt, codposnow, codjobt, numlvlt, codbrlct, codcalet,
             flgattet, flgadjin, desnote, typdoc, numannou, codedlv, codsex, flgrp,
             staupd, codempmtt, codempmt, typpayrolt, typpayroll, typempt, typemp,
             amtincom1, amtincom2, amtincom3, amtincom4, amtincom5, amtincom6,
             amtincom7, amtincom8, amtincom9, amtincom10, amtincadj1, amtincadj2,
             amtincadj3, amtincadj4, amtincadj5, amtincadj6, amtincadj7, amtincadj8,
             amtincadj9, amtincadj10, amtothr, dteend, dteupd, coduser, codcurr,
             codappr, dteappr, dtecancel,jobgrade,jobgradet,codgrpgl ,codgrpglt
        from ttmovemt
       where codempid = v_codempid
         and dteeffec = v_dteeffec
         and numseq   = v_numseq;

    cursor c_temploy1 is
      select codempid,codcomp,codpos,codjob,numlvl,codbrlc,codcalen,flgatten,dteempmt,
             codedlv,codsex,codempmt,typpayroll,typemp,dteefpos,dteeflvl,staemp,jobgrade ,codgrpgl,dteefstep
        from temploy1
       where codempid = v_codempid
         and staemp   in ('1','3','9');

  begin
    v_sum         := 0;
    v_err         := 0;
    v_user        := 0;
    v_erruser     := 0;

    if p_coduser is not null then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
        into   v_zminlvl,v_zwrklvl
        from   tusrprof
        where  coduser = p_coduser;
      exception when others then null;
      end;
    end if;

    begin
      select codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10
        into to_codincom1,to_codincom2,to_codincom3,to_codincom4,to_codincom5,to_codincom6,to_codincom7,to_codincom8,to_codincom9,to_codincom10
        from tcontpms
       where dteeffec in (select max(dteeffec)
                            from tcontpms
                           where dteeffec <= sysdate
                             and codcompy = hcm_util.get_codcomp_level(p_codcomp,1))
         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then to_codincom1 := null;
    end;

    v_codtrn := '0007';
    for m in c_movemt loop
      if p_coduser = 'AUTO' then
        v_secu  :=  true;
      else
        v_secu  :=  secur_main.secur1(m.codcompt,m.numlvlt,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
      end if;

      if v_secu then
        v_chksecu         :=  'Y';
        v_codempid        :=  m.codempid;
        v_dteeffec        :=  m.dteeffec;
        v_numseq          :=  m.numseq;

        for i in c_ttmovemt loop
          begin
            select typmove
            into   v_typmove
            from   tcodmove
            where  tcodmove.codcodec = i.codtrn;
          exception when no_data_found then v_typmove := 'M';
          end;

          -- Amount Net Income From 'TTMOVEMT
          t_codsex      := i.codsex;
          t_codedlv     := i.codedlv;
          tm_amtincom1  := stddec(i.amtincom1,i.codempid,v_chken);
          tm_amtincom2  := stddec(i.amtincom2,i.codempid,v_chken);
          tm_amtincom3  := stddec(i.amtincom3,i.codempid,v_chken);
          tm_amtincom4  := stddec(i.amtincom4,i.codempid,v_chken);
          tm_amtincom5  := stddec(i.amtincom5,i.codempid,v_chken);
          tm_amtincom6  := stddec(i.amtincom6,i.codempid,v_chken);
          tm_amtincom7  := stddec(i.amtincom7,i.codempid,v_chken);
          tm_amtincom8  := stddec(i.amtincom8,i.codempid,v_chken);
          tm_amtincom9  := stddec(i.amtincom9,i.codempid,v_chken);
          tm_amtincom10 := stddec(i.amtincom10,i.codempid,v_chken);
          tm_amtothr    := stddec(i.amtothr,i.codempid,v_chken);

          v_staupd      := 'C';
          v_error       := '2010';
          v_table       := 'TEMPLOY1';
          <<cal_loop>>
          for j in c_temploy1 loop  -- Exist in temploy1
            if j.staemp = '9' then
              v_staupd  := 'N';
              v_error   := 'HR2101';
              v_table   := null;
              exit cal_loop;
            end if;

            t_codsex  := j.codsex;
            t_codedlv := j.codedlv;
            begin
              select  amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                      amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,amtothr
              into    t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,
                      t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10,t3_amtothr
              from    temploy3
              where   temploy3.codempid = v_codempid;
            exception when no_data_found then
              v_staupd  := 'C';
              v_error   := 'HR2101';
              v_table   := 'TEMPLOY3';
              exit cal_loop;
            end;

            v_staupd := 'U';  -- Status for Update to ttmovemt.staupd [Exist temploy1&temploy3]
            if i.numreqst is not null and i.numreqst <> ' ' then
              begin
                   --select totqtyact,totreq,stareq  into   t_totqtyact,t_totreq,t_stareq
                   select stareq  into t_stareq
                     from treqest1
                   where  numreqst = i.numreqst;
              exception when no_data_found then t_stareq := 'E';
              end;

              begin
                   select sum(nvl(qtyact,0)) , sum(nvl(qtyreq,0))
                   into   t_totqtyact,t_totreq
                   from   treqest2
                   where  numreqst = i.numreqst;
              exception when no_data_found then
                    t_totqtyact   := 0;
                    t_totreq       := 0;
              end;

                 if t_stareq <> 'E' then
                         t_totqtyact := nvl(t_totqtyact,0) + 1;
                         if t_totqtyact >= t_totreq then
                           t_totqtyact := t_totreq;
                           t_stareq    := 'C';  -- C-Closed
                         else
                           t_stareq    := 'F';  -- F-Fill
                         end if;

                         update treqest1
                            set
                                --totqtyact = t_totqtyact,
                                --dtechg    = i.dteeffec,
                                stareq    = t_stareq,
                                coduser   = p_coduser
                          where numreqst = i.numreqst;

                         t_stareq := 'Y';
                         begin
                           select qtyact,qtyreq into t_qtyact,t_qtyreq
                           from   treqest2
                           where  treqest2.numreqst = i.numreqst
                           and    treqest2.codpos   = i.codpos;
                         exception when no_data_found then t_stareq := 'N';
                         end;

                         if t_stareq = 'Y' then
                              t_qtyact := nvl(t_qtyact,0) + 1;
                              if t_qtyact > t_qtyreq then
                                 t_qtyact := t_qtyreq;
                              end if;

                              update treqest2
                              set   qtyact  = t_qtyact,
                                     --dtechg  = i.dteeffec,
                                     coduser = p_coduser
                              where  numreqst = i.numreqst
                              and    codpos   = i.codpos;
                         end if;

                 end if;  --if t_stareq <> 'E' - Exist in TREQEST1
            end if;  --if i.numreqst is not null and i.numreqst <> ' '

            if i.codtrn = '0007' then  -- Cancel Concurrent Position Delete 'TSECPOS'
                    v_fnsecpos := 'Y';
--<<user14 redmine#5129
                   /*
                   begin   -- Select for Variable tsecpos for delete
                      select numseq into t_numseq
                        from tsecpos
                       where tsecpos.codempid  = i.codempid
                         and tsecpos.dteeffec      = i.dteeffpos
                         and tsecpos.dtecancel    = i.dteeffec
                         and tsecpos.seqcancel   = i.numseq
                         and rownum = 1;
                    exception when no_data_found then
                          v_fnsecpos := 'N';
                    end;
                    */
-->>user14 redmine#5129

                    if v_fnsecpos = 'Y' then
                            delete tsecpos
                             where tsecpos.codempid  = i.codempid
                                 and tsecpos.dtecancel  = i.dteeffec
                                 and tsecpos.seqcancel  = i.numseq;
                    end if;
            end if;  --if i.codtrn = '0007'

            if i.stapost2 <> '0' and i.codtrn <> '0007' then  -- Promotion Create ttmovemt,tsecpos
              begin   -- Select for NUMSEQ

                select max(numseq) into t_numseq
                  from tsecpos
                 where codempid  = v_codempid
                   and dteeffec  = v_dteeffec;
              exception when no_data_found then t_numseq := 0;
              end;
              t_numseq  :=  nvl(t_numseq,0) + 1;

              --Promotion Create data to table 'TSECPOS'
              insert into tsecpos(codempid,dteeffec,numseq,codcomp,
                                        codpos,codjob,codbrlc,numlvl,
                                        stapost2,dteend,codcreate,coduser)
                              values(v_codempid,v_dteeffec,t_numseq,i.codcomp,
                                        i.codpos,i.codjob,i.codbrlc,i.numlvl,
                                        i.stapost2,i.dteend,p_coduser,p_coduser);
            end if;  --if i.stapost2 <> '0'

            -- Check If not (Promotion/Cancel Position) OR Promotion&Status Position is 0-Normal
            if ( i.codtrn <> '0007' and nvl(i.stapost2,'0') = '0') then
              if i.codpos is not null and i.codpos <> j.codpos and i.dteduepr is null then
                 t_dteefpos := i.dteeffec;   --ttmovemt
              else
                 t_dteefpos := j.dteefpos;   --temploy1
              end if;

              if i.numlvl is not null and i.numlvl <> j.numlvl and i.dteduepr is null then

                 t_dteeflvl := i.dteeffec;   --ttmovemt
              else
                 t_dteeflvl := j.dteeflvl;   --temploy1
              end if;

              if i.jobgrade is not null and i.jobgrade <> j.jobgrade and i.dteduepr is null then
                 t_dteefstep := i.dteeffec;   --ttmovemt
              else
                 t_dteefstep := j.dteefstep;  --temploy1
              end if;

              -- Update Data To 'TEMPLOY1'  M-??????????????????????????????
--<<redmine#2711
              --if v_typmove = 'M' then
              if v_typmove in ('M','8') then
-->>redmine#2711
                update temploy1
                   set dteefpos   = t_dteefpos,
                       dteeflvl   = t_dteeflvl,
                       dteefstep  = t_dteefstep,
                       codcomp    = decode(i.codcomp,i.codcompt,codcomp,i.codcomp),
                       codpos     = decode(i.codpos,i.codposnow,codpos,i.codpos),
                       codjob     = decode(i.codjob,i.codjobt,codjob,i.codjob),
                       numlvl     = decode(i.numlvl,i.numlvlt,numlvl,i.numlvl),
                       codbrlc    = decode(i.codbrlc,i.codbrlct,codbrlc,i.codbrlc),
                       flgatten   = decode(i.flgatten,i.flgattet,flgatten,i.flgatten),
                       codcalen   = decode(i.codcalen,i.codcalet,codcalen,i.codcalen),
                       typpayroll = decode(i.typpayroll,i.typpayrolt,typpayroll,i.typpayroll),
                       codempmt   = decode(i.codempmt,i.codempmtt,codempmt,i.codempmt),

                       typemp     = decode(i.typemp,i.typempt,typemp,i.typemp),
                       jobgrade   = decode(i.jobgrade,i.jobgradet,jobgrade,i.jobgrade),
                       codgrpgl   = decode(i.codgrpgl,i.codgrpglt,codgrpgl,i.codgrpgl),
                       numreqst   = i.numreqst, coduser     = p_coduser
                 where codempid = v_codempid;
              end if;
            end if;
            -- End Is not 5-Promotion, 10-Cancel Position, 11-Transfer&Promotion OR Is 5-Promotion, 11-Transfer&Promotion AND Status Position 2 = '0'-Normal

            begin   -- select for numseq
              select max(numseq) into v_seq
                from thismove
               where codempid = v_codempid
                 and dteeffec = v_dteeffec;
            exception when no_data_found then v_seq := 0;
            end;
            v_seq  :=  nvl(v_seq,0) + 1;

            --create data to table 'THISMOVE,TFINCADJ'/update table 'TEMPLOY3'
            if i.flgadjin = 'N' and i.codempmtt = i.codempmt then-- user22 : 09/05/2016 : STA3590264 || if i.flgadjin = 'N' then -- Not Adjust Income
                insert into thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                     codpos,codjob,codbrlc,codempmt,stapost2,numlvl,typemp,typpayroll,
                                     staemp,dteduepr,desnote,typdoc,codappr,flginput,flgadjin,
                                     codcalen,numreqst,dteend,typmove,
                                     dteempmt,jobgrade,codgrpgl,
                                     codcreate,coduser)
                              values(v_codempid,v_dteeffec,v_seq,i.codtrn,i.numannou,i.codcomp,
                                     i.codpos,i.codjob,i.codbrlc,i.codempmt,i.stapost2,i.numlvl,i.typemp,i.typpayroll,
                                     j.staemp,i.dteduepr,i.desnote,i.typdoc,i.codappr,'N',i.flgadjin,
                                     i.codcalen,i.numreqst,i.dteend,v_typmove,
                                     j.dteempmt,i.jobgrade,i.codgrpgl,
                                     p_coduser,p_coduser);
            else -- Adjust Income
              -- Sum Amount Net Income For Update 'TEMPLOY3
              tm_amtincom1  := stddec(t3_amtincom1,v_codempid,v_chken)  + stddec(i.amtincadj1,i.codempid,v_chken);
              tm_amtincom2  := stddec(t3_amtincom2,v_codempid,v_chken)  + stddec(i.amtincadj2,i.codempid,v_chken);
              tm_amtincom3  := stddec(t3_amtincom3,v_codempid,v_chken)  + stddec(i.amtincadj3,i.codempid,v_chken);
              tm_amtincom4  := stddec(t3_amtincom4,v_codempid,v_chken)  + stddec(i.amtincadj4,i.codempid,v_chken);
              tm_amtincom5  := stddec(t3_amtincom5,v_codempid,v_chken)  + stddec(i.amtincadj5,i.codempid,v_chken);
              tm_amtincom6  := stddec(t3_amtincom6,v_codempid,v_chken)  + stddec(i.amtincadj6,i.codempid,v_chken);
              tm_amtincom7  := stddec(t3_amtincom7,v_codempid,v_chken)  + stddec(i.amtincadj7,i.codempid,v_chken);
              tm_amtincom8  := stddec(t3_amtincom8,v_codempid,v_chken)  + stddec(i.amtincadj8,i.codempid,v_chken);
              tm_amtincom9  := stddec(t3_amtincom9,v_codempid,v_chken)  + stddec(i.amtincadj9,i.codempid,v_chken);
              tm_amtincom10 := stddec(t3_amtincom10,v_codempid,v_chken) + stddec(i.amtincadj10,i.codempid,v_chken);

              get_wage_income(hcm_util.get_codcomp_level(i.codcomp,'1'),i.codempmt,
                              tm_amtincom1, tm_amtincom2,
                              tm_amtincom3, tm_amtincom4,
                              tm_amtincom5, tm_amtincom6,
                              tm_amtincom7, tm_amtincom8,
                              tm_amtincom9, tm_amtincom10,
                              tm_amtothr, tm_amtotday, tm_amtotmth);

                              tm_amtothr  := round(tm_amtothr,2);
                              tm_amtotday := round(tm_amtotday,2);
                              tm_amtotmth := round(tm_amtotmth,2);

              tm_en_amtincom1  := stdenc(tm_amtincom1,v_codempid,v_chken);
              tm_en_amtincom2  := stdenc(tm_amtincom2,v_codempid,v_chken);
              tm_en_amtincom3  := stdenc(tm_amtincom3,v_codempid,v_chken);
              tm_en_amtincom4  := stdenc(tm_amtincom4,v_codempid,v_chken);
              tm_en_amtincom5  := stdenc(tm_amtincom5,v_codempid,v_chken);
              tm_en_amtincom6  := stdenc(tm_amtincom6,v_codempid,v_chken);
              tm_en_amtincom7  := stdenc(tm_amtincom7,v_codempid,v_chken);
              tm_en_amtincom8  := stdenc(tm_amtincom8,v_codempid,v_chken);
              tm_en_amtincom9  := stdenc(tm_amtincom9,v_codempid,v_chken);
              tm_en_amtincom10 := stdenc(tm_amtincom10,v_codempid,v_chken);
              tm_en_amtothr2   := stdenc(tm_amtothr,v_codempid,v_chken);
              tm_en_amtday2    := stdenc(tm_amtotday,v_codempid,v_chken);

              begin
                update temploy3
                   set amtincom1  = tm_en_amtincom1,  amtincom2  = tm_en_amtincom2,
                       amtincom3  = tm_en_amtincom3,  amtincom4  = tm_en_amtincom4,
                       amtincom5  = tm_en_amtincom5,  amtincom6  = tm_en_amtincom6,
                       amtincom7  = tm_en_amtincom7,  amtincom8  = tm_en_amtincom8,
                       amtincom9  = tm_en_amtincom9,  amtincom10 = tm_en_amtincom10,
                       amtothr    = tm_en_amtothr2,   amtday     = tm_en_amtday2, coduser     = p_coduser
                 where codempid = v_codempid;
              end;
              if i.flgadjin = 'Y' then-- user22 : 09/05/2016 : STA3590264 || +
                -- Create table 'THISMOVE'
                insert into thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                     codpos,codjob,codbrlc,codempmt,stapost2,numlvl,typemp,typpayroll,
                                     staemp,dteduepr,desnote,typdoc,codappr,flginput,flgadjin,
                                     amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                     amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                     amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                                     amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                                     codcalen,numreqst,dteend,codcurr,typmove,dteempmt,jobgrade,codgrpgl,
                                     codcreate,coduser)
                              values(v_codempid,v_dteeffec,v_seq,i.codtrn,i.numannou,i.codcomp,
                                     i.codpos,i.codjob,i.codbrlc,i.codempmt,i.stapost2,i.numlvl,i.typemp,i.typpayroll,
                                     j.staemp,i.dteduepr,i.desnote,i.typdoc,i.codappr,'N',i.flgadjin,
                                     tm_en_amtincom1,tm_en_amtincom2,tm_en_amtincom3,tm_en_amtincom4,tm_en_amtincom5,
                                     tm_en_amtincom6,tm_en_amtincom7,tm_en_amtincom8,tm_en_amtincom9,tm_en_amtincom10,
                                     i.amtincadj1,i.amtincadj2,
                                     i.amtincadj3,i.amtincadj4,
                                     i.amtincadj5,i.amtincadj6,
                                     i.amtincadj7,i.amtincadj8,
                                     i.amtincadj9,i.amtincadj10,
                                     i.codcalen,i.numreqst,i.dteend,i.codcurr,v_typmove,j.dteempmt,i.jobgrade,i.codgrpgl,
                                     p_coduser,p_coduser);

                to_amtincom1  := tm_amtincom1  - stddec(i.amtincadj1,v_codempid,v_chken);
                to_amtincom2  := tm_amtincom2  - stddec(i.amtincadj2,v_codempid,v_chken);
                to_amtincom3  := tm_amtincom3  - stddec(i.amtincadj3,v_codempid,v_chken);
                to_amtincom4  := tm_amtincom4  - stddec(i.amtincadj4,v_codempid,v_chken);
                to_amtincom5  := tm_amtincom5  - stddec(i.amtincadj5,v_codempid,v_chken);

                to_amtincom6  := tm_amtincom6  - stddec(i.amtincadj6,v_codempid,v_chken);
                to_amtincom7  := tm_amtincom7  - stddec(i.amtincadj7,v_codempid,v_chken);
                to_amtincom8  := tm_amtincom8  - stddec(i.amtincadj8,v_codempid,v_chken);
                to_amtincom9  := tm_amtincom9  - stddec(i.amtincadj9,v_codempid,v_chken);
                to_amtincom10 := tm_amtincom10 - stddec(i.amtincadj10,v_codempid,v_chken);

                to_en_amtincom1  := stdenc(to_amtincom1,v_codempid,v_chken);
                to_en_amtincom2  := stdenc(to_amtincom2,v_codempid,v_chken);
                to_en_amtincom3  := stdenc(to_amtincom3,v_codempid,v_chken);
                to_en_amtincom4  := stdenc(to_amtincom4,v_codempid,v_chken);
                to_en_amtincom5  := stdenc(to_amtincom5,v_codempid,v_chken);
                to_en_amtincom6  := stdenc(to_amtincom6,v_codempid,v_chken);
                to_en_amtincom7  := stdenc(to_amtincom7,v_codempid,v_chken);

                to_en_amtincom8  := stdenc(to_amtincom8,v_codempid,v_chken);
                to_en_amtincom9  := stdenc(to_amtincom9,v_codempid,v_chken);
                to_en_amtincom10 := stdenc(to_amtincom10,v_codempid,v_chken);

                ------------------------------------------------------------------------------
                begin
                    select max(numseq) into tf_numseq
                      from tfincadj
                     where codempid = v_codempid
                       and dteeffec = v_dteeffec;
                  exception when no_data_found then tf_numseq := 0;
                end;
                tf_numseq  :=  nvl(tf_numseq,0) + 1;

                insert into tfincadj(codempid,dteeffec,numseq,
                                      amtinco1,amtinco2,amtinco3,amtinco4,amtinco5,
                                      amtinco6,amtinco7,amtinco8,amtinco9,amtinco10,
                                      amtincn1,amtincn2,amtincn3,amtincn4,amtincn5,
                                      amtincn6,amtincn7,amtincn8,amtincn9,amtincn10,
                                      codincom1,codincom2,codincom3,codincom4,codincom5,
                                      codincom6,codincom7,codincom8,codincom9,codincom10,
                                      dtetranf,staupd,flgbf,
                                      typpayroll,typpayrolt,codempmt,codempmtt,
                                      coduser,codcreate)
                               values(v_codempid,v_dteeffec,tf_numseq,
                                       to_en_amtincom1,to_en_amtincom2,to_en_amtincom3,to_en_amtincom4,to_en_amtincom5,
                                       to_en_amtincom6,to_en_amtincom7,to_en_amtincom8,to_en_amtincom9,to_en_amtincom10,
                                       i.amtincadj1,i.amtincadj2,i.amtincadj3,i.amtincadj4,i.amtincadj5,
                                       i.amtincadj6,i.amtincadj7,i.amtincadj8,i.amtincadj9,i.amtincadj10,
                                       to_codincom1,to_codincom2,to_codincom3,to_codincom4,to_codincom5,
                                       to_codincom6,to_codincom7,to_codincom8,to_codincom9,to_codincom10,
                                       to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),'T','N',
                                       i.typpayroll,i.typpayrolt,i.codempmt,i.codempmtt,
                                       p_coduser,p_coduser);
              end if; -- i.flgadjin = 'Y'
            end if;  --i.flgadjin = 'N' and i.codempmtt = i.codempmt
          end loop;  --for j in c_temploy1 loop

        -- Update FLGUPD To ttmovemt
        -- stdenc data
          tm_en_amtincom1  := stdenc(tm_amtincom1,v_codempid,v_chken);
          tm_en_amtincom2  := stdenc(tm_amtincom2,v_codempid,v_chken);
          tm_en_amtincom3  := stdenc(tm_amtincom3,v_codempid,v_chken);
          tm_en_amtincom4  := stdenc(tm_amtincom4,v_codempid,v_chken);
          tm_en_amtincom5  := stdenc(tm_amtincom5,v_codempid,v_chken);
          tm_en_amtincom6  := stdenc(tm_amtincom6,v_codempid,v_chken);
          tm_en_amtincom7  := stdenc(tm_amtincom7,v_codempid,v_chken);
          tm_en_amtincom8  := stdenc(tm_amtincom8,v_codempid,v_chken);
          tm_en_amtincom9  := stdenc(tm_amtincom9,v_codempid,v_chken);
          tm_en_amtincom10 := stdenc(tm_amtincom10,v_codempid,v_chken);

          begin
            update ttmovemt
                  set   staupd     = v_staupd,   -- Exist temploy1 = 'U' else = 'N'
                         codsex     = t_codsex,           codedlv    = t_codedlv,
                         amtincom1  = tm_en_amtincom1,    amtincom2  = tm_en_amtincom2,
                         amtincom3  = tm_en_amtincom3,    amtincom4  = tm_en_amtincom4,
                         amtincom5  = tm_en_amtincom5,    amtincom6  = tm_en_amtincom6,
                         amtincom7  = tm_en_amtincom7,    amtincom8  = tm_en_amtincom8,
                         amtincom9  = tm_en_amtincom9,    amtincom10 = tm_en_amtincom10,
                         amtothr    = tm_en_amtothr2,
                         coduser   = p_coduser
             where codempid    = i.codempid
                 and dteeffec     = i.dteeffec
                 and numseq      = i.numseq;

            recal_movement(i.codempid,i.dteeffec,i.numseq,p_coduser);
          end;
/* 01/07/2020 st11
          if (i.codpos <> i.codposnow) or  (i.codcompt <> i.codcomp)then
            update tsuccpln
               set dteeffec = i.dteeffec
             where codcomp  = i.codcomp
               and codpos   = i.codpos
               and codempid = i.codempid
               and dteeffec is null;
          end if;
*/

/*
--<<redmine 2247 ST11
          if (i.codpos <> i.codposnow) or  (i.codcompt <> i.codcomp) or
             (i.numlvl <> i.numlvlt) or (i.jobgrade <> i.jobgradet) or
             (i.typemp <> i.typempt) or (i.codempmt <> i.codempmtt) or
             (i.codjob <> i.codjobt) then
*/
          /*user36 10/05/2022 cancel to do in ins_tusrprof
          if (i.codcompt <> i.codcomp) or (i.numlvl <> i.numlvlt)  then
-->>redmine 2247 ST11
             change_userprofile (i.codempid ,i.codcomp,i.codpos,i.numlvl,i.jobgrade,i.typemp,
                                       i.codempmt,i.codjob, i.codcompt,p_coduser,
                                       v_pass);

             v_secur := v_secur + v_pass;
          end if;
          */
          --<<user36 10/05/2022
          if (i.jobgrade <> i.jobgradet) or (i.codcompt <> i.codcomp) or
             (i.codpos <> i.codposnow)   or (i.codjob <> i.codjobt) or
             (i.codbrlc <> i.codbrlct)   or (i.numlvl <> i.numlvlt) or
             (i.codempmt <> i.codempmtt) or (i.typemp <> i.typempt)
             then
            global_v_coduser := p_coduser;
            ins_tusrprof(i.codempid);

            v_user := v_user + 1;
          end if;
          -->>user36 10/05/2022

          if v_staupd = 'U' then
             v_sum   :=  v_sum + 1;
          else
            ins_errtmp(i.codempid,i.codcomp,i.codpos,v_error,v_table,v_topic5,p_coduser);
            v_err   :=  v_err + 1;
--<<redmine 2249 ST11
            if (i.codcompt <> i.codcomp) then
               ins_errtmp(i.codempid,i.codcomp,i.codpos,v_error,v_table,v_topic8,p_coduser);
               v_erruser  := v_erruser + 1;
            end if;
-->>redmine 2249 ST11

              -- insert batch process detail
              hcm_batchtask.insert_batch_detail(
                p_codapp   => global_v_batch_codapp,
                p_coduser  => p_coduser,
                p_codalw   => global_v_batch_codapp||'2',
                p_dtestrt  => p_dtetim,
                p_item01  => i.codempid,
                p_item02  => i.codcomp,
                p_item03  => i.codpos,
                p_item04  => v_error,
                p_item05  => v_table,
                p_item06  => v_topic5,
                p_item07  => p_coduser
              );

              -- insert batch process detail
              hcm_batchtask.insert_batch_detail(
                p_codapp   => global_v_batch_codapp,
                p_coduser  => p_coduser,
                p_codalw   => global_v_batch_codapp||'8',
                p_dtestrt  => p_dtetim,
                p_item01  => i.codempid,
                p_item02  => i.codcomp,
                p_item03  => i.codpos,
                p_item04  => v_error,
                p_item05  => v_table,
                p_item06  => v_topic8,
                p_item07  => p_coduser
              );
          end if;
          --vv update career plan vv--
          update tposempd
             set dteefpos   = i.dteeffec , coduser     = p_coduser
           where codempid   = i.codempid
             and codcomp    = i.codcomp
             and codpos     = i.codpos
             and numseq     = (select max(numseq)
                                 from tposempd
                                where codempid = i.codempid);
        end loop; --for i in c_ttmovemt loop
      end if; --if v_secu then
    end loop; --for m in c_movemt loop
    commit;

    o_sum      := v_sum;
    o_err      := v_err;
    o_user     := v_user;
    o_erruser  := v_erruser;

  end process_movement;

  -- 4. New Employee
  procedure process_new_employment (p_codcomp  in  varchar2,p_endate  in date,p_coduser in varchar2,
                                    o_sum      out number,o_err       out number,
                                    o_user     out number,o_erruser   out number,
                                    p_dtetim   in date default sysdate) is
      v_zupdsal   varchar2(1 char);
      v_secu      boolean;

      v_codempid     ttnewemp.codempid%type;
      v_dteempmt    ttnewemp.dteempmt%type;
      v_numseq       thismove.numseq%type;
      v_codtrn         thismove.codtrn%type;
      v_typmove     thismove.typmove%type;
      v_staemp    varchar2(1 char);
      -- Variable for ttpminf
      tp_numseq   ttpminf.numseq%type;
      v_dteoccup  date;
      t3_amtincom1   temploy3.amtincom1%type;
      t3_amtincom2   temploy3.amtincom2%type;
      t3_amtincom3   temploy3.amtincom3%type;
      t3_amtincom4   temploy3.amtincom4%type;

      t3_amtincom5   temploy3.amtincom5%type;
      t3_amtincom6   temploy3.amtincom6%type;
      t3_amtincom7   temploy3.amtincom7%type;
      t3_amtincom8   temploy3.amtincom8%type;
      t3_amtincom9   temploy3.amtincom9%type;
      t3_amtincom10  temploy3.amtincom10%type;

      v_sum         number;
      v_err         number;
      v_user				number;
      v_erruser		  number;
      v_chksecu     varchar2(1 char);
      v_zminlvl     number;
      v_zwrklvl     number;



  cursor c_ttnewemp is
            /* select  codempid, dteempmt, codempmt, numreqst, codcomp, codpos, codjob, numlvl,
                    codbrlc, codcalen,  flgatten,  qtydatrq, dteduepr,
                    staemp, amtincom1, amtincom2, amtincom3, amtincom4, amtincom5, amtincom6,
                    amtincom7, amtincom8, amtincom9, amtincom10, amtothr, flgrp, flgupd,
                    codedlv, dteupd, coduser, typemp, typpayroll, codcurr*/
                      select  codempid, dteempmt,   codcomp, codpos,  numlvl ,codcalen,codcurr
                      from  ttnewemp
                      where codcomp like p_codcomp||'%'
                      and   dteempmt  <= p_endate
                      and   flgupd     = 'N'
  --<<user14||29/05/2021||redmine#5875
                union
                    select  a.codempid, dteempmt,   codcomp, codpos,  numlvl ,codcalen,codcurr
                    from    temploy1 a,temploy3 b
                    where   a.codempid = b.codempid
                    and a.staemp <> '9'
                    and a.codcomp like p_codcomp||'%'
                    and a.dteempmt  <= p_endate
                    and not exists ( select  d.codempid  from  ttnewemp d where d.codempid = a.codempid )
 -->>user14||29/05/2021||redmine#5875
                    order by codempid;


  cursor c2 is
        select  a.codempid, dteempmt, codempmt, numreqst, codcomp, codpos, codjob, numlvl,
                codbrlc, codcalen,  flgatten, qtydatrq, dteduepr, jobgrade, codgrpgl,
                staemp, amtincom1, amtincom2, amtincom3, amtincom4, amtincom5, amtincom6,
                amtincom7, amtincom8, amtincom9, amtincom10, amtothr,
                codedlv,   typemp, typpayroll, codcurr
        from    temploy1 a,temploy3 b
        where   a.codempid = b.codempid
        and     a.codempid = v_codempid;

  begin
      v_sum         := 0;
      v_err         := 0;
      v_user        := 0;
      v_erruser     := 0;

      v_codtrn      := '0001';

      if p_coduser is not null   then
          begin
           --select numlvlst ,numlvlen
           select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
           into   v_zminlvl,v_zwrklvl
           from   tusrprof
           where  coduser = p_coduser;
          exception when others then
             null;
          end;
      end if;

      begin
          select  typmove into v_typmove
            from  tcodmove
           where  codcodec = v_codtrn;
      exception when no_data_found then v_typmove := 'M';
      end;
    for i in c_ttnewemp loop
      if p_coduser = 'AUTO' then
          v_secu  :=  true;
      else
        v_secu    :=  secur_main.secur1(i.codcomp,i.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
      end if;

          if v_secu then
            if i.codcalen is not null then
               v_chksecu    :=  'Y';
               v_codempid   :=  i.codempid;
               for j in c2 loop
                   if j.dteduepr  is not null then
                        v_staemp   := '1';
                        v_dteoccup := null;
                   else
                        v_staemp   := '3';
                        v_dteoccup := j.dteempmt;
                   end if;
                   v_dteempmt      :=  j.dteempmt;

                   -- Process from RC
                   update temploy1
                   set     staemp   = v_staemp,
                           dteoccup = v_dteoccup,
                           coduser  = p_coduser
                   where codempid = v_codempid
                   and   staemp   = '0';
                       -- Process from RC

                   begin   -- Select for ttpminf.numseq
                       select max(numseq) into tp_numseq
                       from   ttpminf
                       where  codempid     = v_codempid
                       and    dteeffec   = v_dteempmt;
                   exception when no_data_found then tp_numseq := 0;
                   end;
                   tp_numseq  :=  nvl(tp_numseq,0) + 1;
                   --create data to table 'TTPMINF'
                          insert into
                                  ttpminf(codempid,dteeffec,numseq,codtrn,codcomp,
                                            codpos,codjob,numlvl,codempmt,codcalen,
                                            codbrlc,typpayroll,typemp,flgatten,
                                            flgal,flgrp,flgap,flgbf,flgtr,flgpy,
                                            jobgrade,staemp,
                                            codcreate, coduser)
                                      values(v_codempid,v_dteempmt,tp_numseq,v_codtrn,j.codcomp,
                                             j.codpos,j.codjob,j.numlvl,j.codempmt,j.codcalen,
                                             j.codbrlc,j.typpayroll,j.typemp,j.flgatten,
                                             'N','N','N','N','N','N',
                                             j.jobgrade,v_staemp,
                                             p_coduser,p_coduser);

                          begin   -- Select for NUMSEQ
                           select max(numseq)
                            into  v_numseq
                            from  thismove
                           where  codempid   = v_codempid
                             and  dteeffec   = v_dteempmt;
                          exception when no_data_found then v_numseq := 0;

                          end;
                          v_numseq  :=  nvl(v_numseq,0) + 1;
                          --create data to table 'THISMOVE'
                          insert into
                                  thismove(codempid,dteeffec,numseq,codtrn,codcomp,
                                                codpos,codjob,codbrlc,codempmt,numlvl,typemp,typpayroll,
                                                staemp,qtydatrq,dteduepr,flginput,flgadjin,
                                                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                                amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                                codcalen,numreqst,typmove,dteempmt,stapost2,
                                                jobgrade, codgrpgl,codcurr ,
                                                codcreate, coduser)
                                    values(v_codempid,v_dteempmt,v_numseq,v_codtrn,j.codcomp,
                                           j.codpos,j.codjob,j.codbrlc,j.codempmt,j.numlvl,j.typemp,j.typpayroll,
                                           v_staemp,j.qtydatrq,j.dteduepr,'N','Y',
                                           j.amtincom1,j.amtincom2,j.amtincom3,j.amtincom4,j.amtincom5,
                                           j.amtincom6,j.amtincom7,j.amtincom8,j.amtincom9,j.amtincom10,
                                           j.codcalen,j.numreqst,v_typmove,v_dteempmt,'0',
                                           j.jobgrade, j.codgrpgl,i.codcurr,
                                           p_coduser,p_coduser);
                              begin
                                      update ttnewemp
                                      set    flgupd   = 'Y',
                                             coduser  = p_coduser
                                      where  codempid = j.codempid;
 --<<user14||29/05/2021||redmine#5875
                                      if sql%notfound then
                                            insert into ttnewemp (codempid,dteempmt,codempmt,numreqst,
                                                                                    codcomp,codpos,codjob,numlvl,
                                                                                    codbrlc,codcalen,codshift,flgatten,
                                                                                    flgcrinc,qtydatrq,dteduepr,staemp,
                                                                                    amtincom1,amtincom2,amtincom3,amtincom4,
                                                                                    amtincom5,amtincom6,amtincom7,amtincom8,
                                                                                    amtincom9,amtincom10,amtothr,flgrp,
                                                                                    flgupd,codedlv,typemp,typpayroll,codcurr,
                                                                                    jobgrade,codgrpgl, codcreate,coduser)
                                                                     values (v_codempid,v_dteempmt, j.codempmt, j.numreqst,
                                                                                    j.codcomp, j.codpos, j.codjob, j.numlvl,
                                                                                    j.codbrlc,  j.codcalen,  null  ,  j.flgatten,
                                                                                    '2', j.qtydatrq,  j.dteduepr,  v_staemp,
                                                                                    j.amtincom1, j.amtincom2,  j.amtincom3, j.amtincom4,
                                                                                    j.amtincom5, j.amtincom6, j.amtincom7, j.amtincom8,
                                                                                    j.amtincom9, j.amtincom10, j.amtothr , 'N',
                                                                                    'Y', j.codedlv, j.typemp,  j.typpayroll,    j.codcurr,
                                                                                    j.jobgrade, j.codgrpgl, p_coduser,p_coduser);
                                      end if;
 --<<user14||29/05/2021||redmine#5875
                              end;
                              v_sum  :=  v_sum + 1;

/*
--<<test background process
loop
   if mod(to_number(to_char(sysdate,'mi')),2) = 0 then
      exit;
   end if;
end loop;
-->>test background process*/
--dbms_lock.sleep(100);

                  end loop;

              --<<user36 10/05/2022
              global_v_coduser := p_coduser;
              ins_tusrprof(i.codempid);

              v_user := v_user + 1;
              -->>user36 10/05/2022
            else
              v_err    :=  v_err + 1;
              ins_errtmp(i.codempid,i.codcomp,i.codpos,null,null,v_topic1,p_coduser);

              -- insert batch process detail
              hcm_batchtask.insert_batch_detail(
                p_codapp   => global_v_batch_codapp,
                p_coduser  => p_coduser,
                p_codalw   => global_v_batch_codapp||'1',
                p_dtestrt  => p_dtetim,
                p_item01  => i.codempid,
                p_item02  => i.codcomp,
                p_item03  => i.codpos,
                p_item04  => null,
                p_item05  => null,
                p_item06  => v_topic1,
                p_item07  => p_coduser
              );
            end if; -- if i.codcalen is not null then
          end if; --if v_secu then
    end loop; --for i in c_ttnewemp loop
    commit;
    o_sum      := v_sum;
    o_err      := v_err;
    o_user     := v_user;
    o_erruser  := v_erruser;
  end;

  -- 5. Probation
  procedure process_probation  (p_codcomp  in  varchar2,
                                             p_endate     in date,
                                             p_coduser    in varchar2,
                                             o_sum      out number ,o_err out number, p_dtetim in date default sysdate) is

      v_zupdsal      varchar2(1 char);
      v_secu         boolean;
      v_staupd       ttprobat.staupd%type;    -- Exist from temploy1 = 'U' else = 'N'
      v_found1       varchar2(1 char);    -- Exist from temploy1
      v_found3       varchar2(1 char);    -- Exist from temploy3
      v_foundtt      varchar2(1 char);    -- Exist from ttmovemt
      v_exist        varchar2(1 char);    -- Exist from ttexempt
      v_codempid     ttprobat.codempid%type;
      v_dteoccup     ttprobat.dteoccup%type;
      v_dteeffex     ttprobat.dteeffex%type;
      v_numseq       thismove.numseq%type;
      v_codtrn       thismove.codtrn%type;
      v_typmove      thismove.typmove%type;
      v_codtrn3      tcodmove.codcodec%type;  -- For codtrn = '0003'-Probation
      v_codtrn6      tcodmove.codcodec%type;  -- For codtrn = '0004'-Prob. for new position
      v_codtrn9      tcodmove.codcodec%type;  -- For codtrn = '0006'-Resign
      -- Variable for ttexempt
      tx_codempid    ttexempt.codempid%type;
      -- Variable for temploy1
      t1_dteefpos    temploy1.dteefpos%type;
      t1_dteeflvl    temploy1.dteeflvl%type;
      t1_dteoccup    temploy1.dteoccup%type;
      t1_dteempmt    temploy1.dteempmt%type;
      t1_totwkday    number;
      -- Variable for ttmovemt
      tt_dteeffec    ttmovemt.dteeffec%type;
      tt_stapost2    ttmovemt.stapost2%type;
      tt_codcompt    ttmovemt.codcompt%type;

      tt_codposnow   ttmovemt.codposnow%type;
      tt_codjobt     ttmovemt.codjobt%type;
      tt_numlvlt     ttmovemt.numlvlt%type;
      tt_codbrlct    ttmovemt.codbrlct%type;
      tt_flgattet    ttmovemt.flgattet%type;
      tt_codcalet    ttmovemt.codcalet%type;
      tt_typpayrolt  ttmovemt.typpayrolt%type;
      tt_codempmtt   ttmovemt.codempmtt%type;
      tt_typempt     ttmovemt.typempt%type;
      tt_jobgradet   ttmovemt.jobgradet%type;
      tt_codgrpglt   ttmovemt.codgrpglt%type;


    -- Variable for temploy3
      t3_amtincom1   temploy3.amtincom1%type;
      t3_amtincom2   temploy3.amtincom2%type;
      t3_amtincom3   temploy3.amtincom3%type;
      t3_amtincom4   temploy3.amtincom4%type;
      t3_amtincom5   temploy3.amtincom5%type;
      t3_amtincom6   temploy3.amtincom6%type;
      t3_amtincom7   temploy3.amtincom7%type;
      t3_amtincom8   temploy3.amtincom8%type;
      t3_amtincom9   temploy3.amtincom9%type;
      t3_amtincom10  temploy3.amtincom10%type;
      t3_amtincomoth ttexempt.amtotht%type;
    -- Variable for thismove
      tm_dteduepr    thismove.dteduepr%type;
    -- Variable for Encrypt
      tm_en_amtincom1   varchar2(50 char);
      tm_en_amtincom2   varchar2(50 char);
      tm_en_amtincom3   varchar2(50 char);
      tm_en_amtincom4   varchar2(50 char);
      tm_en_amtincom5   varchar2(50 char);
      tm_en_amtincom6   varchar2(50 char);
      tm_en_amtincom7   varchar2(50 char);
      tm_en_amtincom8   varchar2(50 char);
      tm_en_amtincom9   varchar2(50 char);
      tm_en_amtincom10  varchar2(50 char);
      tm_en_amtothr2    varchar2(50 char);
      tm_en_amtothr     varchar2(50 char);
      tm_en_amtday      varchar2(50 char);--29/04/2552
      tm_en_amtotday    varchar2(50 char);
      tm_en_amtotmth    varchar2(50 char);

      -- Variable for ttpminf
      tp_numseq      ttpminf.numseq%type;
      -- Variable for tfincadj
      tf_numseq      tfincadj.numseq%type;
      to_amtincom1   tfincadj.amtinco1%type;
      to_amtincom2   tfincadj.amtinco2%type;
      to_amtincom3   tfincadj.amtinco3%type;
      to_amtincom4   tfincadj.amtinco4%type;
      to_amtincom5   tfincadj.amtinco5%type;
      to_amtincom6   tfincadj.amtinco6%type;
      to_amtincom7   tfincadj.amtinco7%type;
      to_amtincom8   tfincadj.amtinco8%type;
      to_amtincom9   tfincadj.amtinco9%type;
      to_amtincom10  tfincadj.amtinco10%type;
      to_codincom1   tcontpms.codincom1%type;
      to_codincom2   tcontpms.codincom2%type;
      to_codincom3   tcontpms.codincom3%type;
      to_codincom4   tcontpms.codincom4%type;
      to_codincom5   tcontpms.codincom5%type;
      to_codincom6   tcontpms.codincom6%type;
      to_codincom7   tcontpms.codincom7%type;
      to_codincom8   tcontpms.codincom8%type;
      to_codincom9   tcontpms.codincom9%type;
      to_codincom10  tcontpms.codincom10%type;
--      to_codincom10  tfincadj.codincom10%type;

      tm_amtincom1   number;
      tm_amtincom2   number;
      tm_amtincom3   number;
      tm_amtincom4   number;
      tm_amtincom5   number;
      tm_amtincom6   number;
      tm_amtincom7   number;
      tm_amtincom8   number;
      tm_amtincom9   number;
      tm_amtincom10  number;

      td3_amtincom1   number;
      td3_amtincom2   number;
      td3_amtincom3   number;
      td3_amtincom4   number;
      td3_amtincom5   number;
      td3_amtincom6   number;
      td3_amtincom7   number;
      td3_amtincom8   number;
      td3_amtincom9   number;
      td3_amtincom10  number;

      tm_amtothr2     number;
      tm_amtothr      number;
      tm_amtotday     number;
      tm_amtotmth     number;

      tadj_amtincom1   number;
      tadj_amtincom2   number;
      tadj_amtincom3   number;
      tadj_amtincom4   number;
      tadj_amtincom5   number;
      tadj_amtincom6   number;
      tadj_amtincom7   number;
      tadj_amtincom8   number;
      tadj_amtincom9   number;
      tadj_amtincom10  number;
      v_staemp9        varchar2(1 char);
      ---
      v_sum         number;
      v_err         number;
      v_chksecu     varchar2(1 char);
      v_zminlvl     number;
      v_zwrklvl     number;

      cursor c_ttprobat is
          select  codempid, dteduepr, codcomp, codpos,   codempmt, typproba,
                     codrespr, dteoccup, dteeval, codappr, flgadjin, desnote, typdoc2, numlettr,
                     staupd, qtyexpand, dteexpand, /*scorepr,*/ amtincom1, amtincom2,
                     amtincom3, amtincom4, amtincom5, amtincom6, amtincom7, amtincom8, amtincom9,
                     amtincom10, amtincadj1, amtincadj2, amtincadj3, amtincadj4, amtincadj5,
                     amtincadj6, amtincadj7, amtincadj8, amtincadj9, amtincadj10, dteupd, coduser,
                     codexemp, codbrlc, typemp, typpayroll,
                     codcalen, codcurr, dteeffec, numseq, flgblist, dteeffex,
                     jobgrade,codgrpgl,flgrepos,numlvl
            from ttprobat
          where codcomp like p_codcomp||'%'
              and staupd     = 'C'
--redmine#5246
              and ( (nvl(dteoccup,dteduepr) <= p_endate) or (codrespr  = 'N' and dteeffex  <= p_endate) )
              --and dteoccup  <= p_endate
--redmine#5246
      order by codempid,dteoccup;

      cursor c_temploy1 is
          select  rowid,codempid,dteefpos,dteeflvl,dteempmt,codcomp,codpos,codjob,numlvl,staemp,codbrlc,
                    flgatten,codcalen,typpayroll,codempmt,typemp,qtywkday,dteoccup,codsex,codedlv,dteredue,
                    jobgrade,codgrpgl
            from  temploy1
          where codempid   = v_codempid
              and staemp    in ('1','3','9');

  begin
      v_sum    := 0;
      v_err    := 0;

      if p_coduser is not null   then
          begin
           --select numlvlst ,numlvlen
           select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
           into   v_zminlvl,v_zwrklvl
           from   tusrprof
           where  coduser = p_coduser;
          exception when others then
             null;
          end;
      end if;

      begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,
                       codincom6,codincom7,codincom8,codincom9,codincom10
          into   to_codincom1,to_codincom2,to_codincom3,to_codincom4,to_codincom5,
                       to_codincom6,to_codincom7,to_codincom8,to_codincom9,to_codincom10
          from  tcontpms
          where dteeffec = (  select max(dteeffec)
                                from tcontpms
                               where dteeffec <= sysdate
                                 and codcompy = hcm_util.get_codcomp_level(p_codcomp,1))
            and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then to_codincom1 := null;
      end;

      -- codeincome
      v_codtrn3 := '0003';
      v_codtrn6 := '0004';
      v_codtrn9 := '0006';

    for i in c_ttprobat loop

      if p_coduser= 'AUTO' then
          v_secu  :=  true;
      else
          v_secu    :=  secur_main.secur2(i.codempid,p_coduser,v_zminlvl,v_zwrklvl, v_zupdsal );
      end if;

      if v_secu then
              v_chksecu           :=  'Y';
              v_codempid          :=  i.codempid;
              v_dteoccup          :=  i.dteoccup;
              v_dteeffex          :=  i.dteeffex;
              v_staupd            :=  'C';  -- Status for Update to ttprobat.staupd [Not Exist temploy1]

              if i.typproba = '1' then   -- Type of Probation is 1-New Hire
                  v_codtrn := v_codtrn3;
              else                       -- Type of Probation is 2-New Position
                  v_codtrn := v_codtrn6;
              end if;

              begin
                           select  typmove
                           into  v_typmove
                           from    tcodmove
                           where tcodmove.codcodec = v_codtrn;
                exception when no_data_found then
                    v_typmove := 'M';
              end;

              -- Amount Net Income From 'TTPROBAT'
              tadj_amtincom1  :=  stddec(i.amtincadj1,v_codempid,v_chken);
              tadj_amtincom2  :=  stddec(i.amtincadj2,v_codempid,v_chken);
              tadj_amtincom3  :=  stddec(i.amtincadj3,v_codempid,v_chken);
              tadj_amtincom4  :=  stddec(i.amtincadj4,v_codempid,v_chken);
              tadj_amtincom5  :=  stddec(i.amtincadj5,v_codempid,v_chken);
              tadj_amtincom6  :=  stddec(i.amtincadj6,v_codempid,v_chken);
              tadj_amtincom7  :=  stddec(i.amtincadj7,v_codempid,v_chken);
              tadj_amtincom8  :=  stddec(i.amtincadj8,v_codempid,v_chken);
              tadj_amtincom9  :=  stddec(i.amtincadj9,v_codempid,v_chken);
              tadj_amtincom10 :=  stddec(i.amtincadj10,v_codempid,v_chken);

          for j in c_temploy1 loop
                  v_staupd    := 'U';
                  v_found3    := 'Y';
                  if j.staemp   in ('1','3') then
                         v_staemp9  := 'N';
                         begin
                               select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                         amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
                               into   t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,
                                        t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10
                               from temploy3
                             where  temploy3.codempid = v_codempid;
                         exception when no_data_found then
                                v_found3 := 'N';
                         end;

                         if v_found3 = 'Y' then
                               td3_amtincom1  := stddec(t3_amtincom1,v_codempid,v_chken);
                               td3_amtincom2  := stddec(t3_amtincom2,v_codempid,v_chken);
                               td3_amtincom3  := stddec(t3_amtincom3,v_codempid,v_chken);
                               td3_amtincom4  := stddec(t3_amtincom4,v_codempid,v_chken);
                               td3_amtincom5  := stddec(t3_amtincom5,v_codempid,v_chken);
                               td3_amtincom6  := stddec(t3_amtincom6,v_codempid,v_chken);
                               td3_amtincom7  := stddec(t3_amtincom7,v_codempid,v_chken);
                               td3_amtincom8  := stddec(t3_amtincom8,v_codempid,v_chken);
                               td3_amtincom9  := stddec(t3_amtincom9,v_codempid,v_chken);
                               td3_amtincom10 := stddec(t3_amtincom10,v_codempid,v_chken);

                               t3_amtincomoth := nvl(td3_amtincom2,0) + nvl(td3_amtincom3,0) +
                                                          nvl(td3_amtincom4,0) + nvl(td3_amtincom5,0) +
                                                          nvl(td3_amtincom6,0) + nvl(td3_amtincom7,0) +
                                                          nvl(td3_amtincom8,0) + nvl(td3_amtincom9,0) + nvl(td3_amtincom10,0);
                         end if;  --if v_found3 = 'Y' then

                         t1_dteefpos   := j.dteefpos;  --Effective Date for Position
                         t1_dteeflvl   := j.dteeflvl;  --Effective Date for Job Level
                         t1_dteempmt   := j.dteempmt;
                         tt_codcompt   := j.codcomp;
                         tt_codposnow  := j.codpos;
                         tt_codjobt    := j.codjob;
                         tt_numlvlt    := j.numlvl;
                         tt_codbrlct   := j.codbrlc;
                         tt_flgattet   := j.flgatten;
                         tt_codcalet   := j.codcalen;
                         tt_typpayrolt := j.typpayroll;
                         tt_codempmtt  := j.codempmt;
                         tt_typempt    := j.typemp;
                         tt_jobgradet  := j.jobgrade;
                         tt_codgrpglt  := j.codgrpgl;


                         if v_dteoccup is not null and t1_dteempmt is not null then
                         -- t1_totwkday := v_dteoccup - t1_dteempmt + nvl(j.qtywkday,0);   --Service Year
                          t1_totwkday := v_dteeffex - t1_dteempmt;   --Service Year
                         else
                              t1_totwkday := 0;
                         end if;

                         if i.typproba = '2' then  --2-Prob. Position
                                if i.dteeffec is not null and i.numseq is not null then
                                       v_foundtt := 'Y';
                                       begin   -- Select for Variable ttmovemt
                                            select dteeffec,stapost2,codcompt,codposnow,codjobt,numlvlt,
                                                   codbrlct,flgattet,codcalet,typpayrolt,codempmtt,typempt
                                              into tt_dteeffec,tt_stapost2,tt_codcompt,tt_codposnow,tt_codjobt,tt_numlvlt,
                                                   tt_codbrlct,tt_flgattet,tt_codcalet,tt_typpayrolt,tt_codempmtt,tt_typempt
                                              from ttmovemt
                                             where codempid = i.codempid
                                               and dteeffec = i.dteeffec
                                               and numseq   = i.numseq;
                                          exception when no_data_found then
                                              v_foundtt := 'N';
                                       end;
                                       if v_foundtt = 'Y' then
                                                 if tt_codposnow <> j.codpos then
                                                      t1_dteefpos := tt_dteeffec;
                                                 end if;
                                                 if tt_numlvlt <> j.numlvl then
                                                      t1_dteeflvl := tt_dteeffec;
                                                 end if;
                                       end if;  --Exist ttmovemt  if v_foundtt = 'Y' then

                                end if;  --if i.dteeffec is not null and i.numseq is not null
                         end if;  --if i.typproba = '2'-Prob. Position

                         -- Type of Probation is P-Pass,N-Not Pass,E-Extend
                         if i.codrespr = 'P' then      /* *** Type of Probation is P-Pass *** */
                               if  i.typproba = '1' then    --1-New Hire
                                   t1_dteoccup := v_dteoccup;
                               else                        --2-Prob. Position
                                   t1_dteoccup := j.dteoccup;
                               end if;
                               tm_dteduepr := t1_dteoccup - 1;

                               if v_found3 = 'Y' then  -- Exist in temploy3
                                           begin   -- Select for NUMSEQ
                                                   select max(numseq) into v_numseq
                                                   from  thismove
                                                   where   codempid = v_codempid
                                                   and dteeffec = v_dteoccup;
                                           exception when no_data_found then
                                               v_numseq := 0;
                                           end;
                                           v_numseq  := nvl(v_numseq,0) + 1;

                                           if i.flgadjin = 'N' then   -- Not Adjust Income
                                               insert into
                                                   thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                                               codpos,codbrlc,codempmt,typemp,typpayroll,
                                                                staemp,dteduepr,dteeval,/*scoreget,*/codrespr,
                                                                desnote,typdoc,codappr,flginput,flgadjin,codcalen,typmove,
                                                                codjob,numlvl,dteempmt,
                                                                jobgrade,codgrpgl ,
                                                                codcreate, coduser)
                                                       values(v_codempid,v_dteoccup,v_numseq,v_codtrn,i.numlettr,i.codcomp,
                                                            i.codpos,i.codbrlc,i.codempmt,i.typemp,i.typpayroll,
                                                            j.staemp,tm_dteduepr,i.dteeval,/*i.scorepr,*/i.codrespr,
                                                            i.desnote,i.typdoc2,i.codappr,'N',i.flgadjin,i.codcalen,v_typmove,
                                                            tt_codjobt,tt_numlvlt,t1_dteempmt,
                                                            i.jobgrade,i.codgrpgl ,
                                                            p_coduser,p_coduser);
                                           else-- Adjust Income
                                              -- Sum Amount Net Income For Update 'TEMPLOY3
                                               tm_amtincom1  := nvl(td3_amtincom1,0)  + nvl(tadj_amtincom1,0);
                                               tm_amtincom2  := nvl(td3_amtincom2,0)  + nvl(tadj_amtincom2,0);
                                               tm_amtincom3  := nvl(td3_amtincom3,0)  + nvl(tadj_amtincom3,0);
                                               tm_amtincom4  := nvl(td3_amtincom4,0)  + nvl(tadj_amtincom4,0);
                                               tm_amtincom5  := nvl(td3_amtincom5,0)  + nvl(tadj_amtincom5,0);
                                               tm_amtincom6  := nvl(td3_amtincom6,0)  + nvl(tadj_amtincom6,0);
                                               tm_amtincom7  := nvl(td3_amtincom7,0)  + nvl(tadj_amtincom7,0);
                                               tm_amtincom8  := nvl(td3_amtincom8,0)  + nvl(tadj_amtincom8,0);
                                               tm_amtincom9  := nvl(td3_amtincom9,0)  + nvl(tadj_amtincom9,0);
                                               tm_amtincom10 := nvl(td3_amtincom10,0) + nvl(tadj_amtincom10,0);

                                               get_wage_income (hcm_util.get_codcomp_level(i.codcomp,'1'),i.codempmt,
                                                                          nvl(tm_amtincom1,0), nvl(tm_amtincom2,0),
                                                                                nvl(tm_amtincom3,0), nvl(tm_amtincom4,0),
                                                                                nvl(tm_amtincom5,0), nvl(tm_amtincom6,0),
                                                                                nvl(tm_amtincom7,0), nvl(tm_amtincom8,0),
                                                                                nvl(tm_amtincom9,0), nvl(tm_amtincom10,0),
                                                                            tm_amtothr, tm_amtotday, tm_amtotmth);
                                               tm_amtothr       := round(tm_amtothr,2);
                                               tm_amtotday      := round(tm_amtotday,2);
                                               tm_amtotmth      := round(tm_amtotmth,2);

                                               tm_en_amtincom1  := stdenc(tm_amtincom1,v_codempid,v_chken);
                                               tm_en_amtincom2  := stdenc(tm_amtincom2,v_codempid,v_chken);
                                               tm_en_amtincom3  := stdenc(tm_amtincom3,v_codempid,v_chken);
                                               tm_en_amtincom4  := stdenc(tm_amtincom4,v_codempid,v_chken);
                                               tm_en_amtincom5  := stdenc(tm_amtincom5,v_codempid,v_chken);
                                               tm_en_amtincom6  := stdenc(tm_amtincom6,v_codempid,v_chken);
                                               tm_en_amtincom7  := stdenc(tm_amtincom7,v_codempid,v_chken);
                                               tm_en_amtincom8  := stdenc(tm_amtincom8,v_codempid,v_chken);
                                               tm_en_amtincom9  := stdenc(tm_amtincom9,v_codempid,v_chken);
                                               tm_en_amtincom10 := stdenc(tm_amtincom10,v_codempid,v_chken);

                                               tm_en_amtothr    := stdenc(tm_amtothr,v_codempid,v_chken);
                                               tm_en_amtday     := stdenc(tm_amtotday,v_codempid,v_chken);--29/04/2552

                                               insert into
                                                   thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                                                codpos,codbrlc,codempmt,typemp,typpayroll,
                                                                staemp,dteduepr,dteeval,/*scoreget,*/codrespr,
                                                                desnote,typdoc,codappr,flginput,flgadjin,
                                                                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                                                amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                                                amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                                                                amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                                                                codcalen,codcurr,typmove,codjob,numlvl,dteempmt,
                                                                jobgrade,codgrpgl ,
                                                                codcreate , coduser)

                                                       values(v_codempid,v_dteoccup,v_numseq,v_codtrn,i.numlettr,i.codcomp,
                                                            i.codpos,i.codbrlc,i.codempmt,i.typemp,i.typpayroll,
                                                            j.staemp,i.dteduepr,i.dteeval,/*i.scorepr,*/i.codrespr,
                                                            i.desnote,i.typdoc2,i.codappr,'N',i.flgadjin,
                                                            tm_en_amtincom1,tm_en_amtincom2,tm_en_amtincom3,tm_en_amtincom4,tm_en_amtincom5,
                                                            tm_en_amtincom6,tm_en_amtincom7,tm_en_amtincom8,tm_en_amtincom9,tm_en_amtincom10,
                                                            i.amtincadj1,i.amtincadj2,i.amtincadj3,i.amtincadj4,i.amtincadj5,
                                                            i.amtincadj6,i.amtincadj7,i.amtincadj8,i.amtincadj9,i.amtincadj10,
                                                            i.codcalen,i.codcurr,v_typmove,tt_codjobt,tt_numlvlt,t1_dteempmt,
                                                            i.jobgrade,i.codgrpgl,
                                                            p_coduser,p_coduser);
                                               begin
                                                   update temploy3
                                                   set amtincom1  = tm_en_amtincom1,  amtincom2  = tm_en_amtincom2,
                                                       amtincom3  = tm_en_amtincom3,  amtincom4  = tm_en_amtincom4,
                                                       amtincom5  = tm_en_amtincom5,  amtincom6  = tm_en_amtincom6,
                                                       amtincom7  = tm_en_amtincom7,  amtincom8  = tm_en_amtincom8,
                                                       amtincom9  = tm_en_amtincom9,  amtincom10 = tm_en_amtincom10,
                                                       amtothr    = tm_en_amtothr  ,  amtday     = tm_en_amtday,
                                                       coduser     = p_coduser
                                                   where   codempid = v_codempid;
                                               end;

                                               -- Keep old amtincom and code imcome
                                               to_amtincom1  := tm_amtincom1  - nvl(tadj_amtincom1,0);
                                               to_amtincom2  := tm_amtincom2  - nvl(tadj_amtincom2,0);
                                               to_amtincom3  := tm_amtincom3  - nvl(tadj_amtincom3,0);
                                               to_amtincom4  := tm_amtincom4  - nvl(tadj_amtincom4,0);
                                               to_amtincom5  := tm_amtincom5  - nvl(tadj_amtincom5,0);
                                               to_amtincom6  := tm_amtincom6  - nvl(tadj_amtincom6,0);
                                               to_amtincom7  := tm_amtincom7  - nvl(tadj_amtincom7,0);
                                               to_amtincom8  := tm_amtincom8  - nvl(tadj_amtincom8,0);
                                               to_amtincom9  := tm_amtincom9  - nvl(tadj_amtincom9,0);
                                               to_amtincom10 := tm_amtincom10 - nvl(tadj_amtincom10,0);

                                               --Encrypt
                                               tm_en_amtincom1  := stdenc(to_amtincom1,v_codempid,v_chken);
                                               tm_en_amtincom2  := stdenc(to_amtincom2,v_codempid,v_chken);
                                               tm_en_amtincom3  := stdenc(to_amtincom3,v_codempid,v_chken);
                                               tm_en_amtincom4  := stdenc(to_amtincom4,v_codempid,v_chken);
                                               tm_en_amtincom5  := stdenc(to_amtincom5,v_codempid,v_chken);
                                               tm_en_amtincom6  := stdenc(to_amtincom6,v_codempid,v_chken);
                                               tm_en_amtincom7  := stdenc(to_amtincom7,v_codempid,v_chken);
                                               tm_en_amtincom8  := stdenc(to_amtincom8,v_codempid,v_chken);
                                               tm_en_amtincom9  := stdenc(to_amtincom9,v_codempid,v_chken);
                                               tm_en_amtincom10 := stdenc(to_amtincom10,v_codempid,v_chken);
--<<Redmine#7881 user46 25/04/2022 Cut insert tfincadj
/*
                                               begin   -- Select for TFINCADJ.NUMSEQ
                                                   select max(numseq) into tf_numseq
                                                     from  tfincadj
                                                   where codempid = v_codempid
                                                       and dteeffec = v_dteoccup;
                                               exception when no_data_found then tf_numseq := 0;
                                               end;

                                               tf_numseq  :=  nvl(tf_numseq,0) + 1;
                                               insert into  tfincadj(codempid,dteeffec,numseq,
                                                                amtinco1,amtinco2,amtinco3,amtinco4,amtinco5,
                                                                amtinco6,amtinco7,amtinco8,amtinco9,amtinco10,
                                                                amtincn1,amtincn2,amtincn3,amtincn4,amtincn5,
                                                                amtincn6,amtincn7,amtincn8,amtincn9,amtincn10,
                                                                codincom1,codincom2,codincom3,codincom4,codincom5,
                                                                codincom6,codincom7,codincom8,codincom9,codincom10,
                                                                dtetranf,staupd,flgbf,
                                                                typpayroll,typpayrolt,codempmt,codempmtt,
                                                                codcreate ,coduser)
                                                       VALUES(v_codempid,v_dteoccup,tf_numseq,
                                                                tm_en_amtincom1,tm_en_amtincom2,tm_en_amtincom3,tm_en_amtincom4,tm_en_amtincom5,
                                                                tm_en_amtincom6,tm_en_amtincom7,tm_en_amtincom8,tm_en_amtincom9,tm_en_amtincom10,
                                                                I.amtincadj1,I.amtincadj2,I.amtincadj3,I.amtincadj4,I.amtincadj5,
                                                                I.amtincadj6,I.amtincadj7,I.amtincadj8,I.amtincadj9,I.amtincadj10,
                                                                to_codincom1,to_codincom2,to_codincom3,to_codincom4,to_codincom5,
                                                                to_codincom6,to_codincom7,to_codincom8,to_codincom9,to_codincom10,
                                                                 TO_DATE(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),'T','N',
                                                                 I.typpayroll,j.typpayroll,I.codempmt,j.codempmt,
                                                                 p_coduser,p_coduser);
*/
-->>Redmine#7881 user46 25/04/2022
                                           end if;  --if i.flgadjin = 'N'
                                            begin
                                                 update temploy1
                                                       set staemp    = '3',
                                                           dteoccup    = t1_dteoccup,  -- 1-NewHire[i.dteoccup] 2-Prob.Pos.[j.dteoccup]
                                                           dteefpos    = t1_dteefpos,
                                                           dteeflvl      = t1_dteeflvl ,
                                                           coduser     = p_coduser
                                                 where rowid = j.rowid;
                                            end;
                               end if;  --if v_found3 = 'Y' - Exist temploy3

                         elsif  i.codrespr = 'N' then      /* *** Type of Probation is N-Not Pass *** */
                     --<<redmine#5246
                               v_dteoccup  := i.dteeffex;
                     -->>redmine#5246
                               begin   -- Select for NUMSEQ
                                         select max(numseq) into v_numseq
                                           from thismove
                                         where codempid = v_codempid
                                             and dteeffec   = v_dteoccup;
                                       exception when no_data_found then v_numseq := 0;
                                end;

                               v_numseq  :=  nvl(v_numseq,0) + 1;
                               if   i.typproba = '1' then    /* ----- 1-New Hire must be Terminate ----- */
                                   insert into
                                       thismove(codempid,dteeffec,
                                                numseq,codtrn,numannou,codcomp,
                                                codpos,codbrlc,codempmt,typemp,typpayroll,
                                                staemp,dteduepr,dteeval,/*scoreget,*/codrespr,
                                                desnote,typdoc,codappr,flginput,flgadjin,codcalen,typmove,codjob,numlvl,dteempmt,
                                                jobgrade,codgrpgl,
                                                codcreate, coduser)
                                         values(v_codempid,v_dteoccup, --i.dteoccup,
                                                v_numseq,v_codtrn9,i.numlettr,i.codcomp,
                                                i.codpos,i.codbrlc,i.codempmt,i.typemp,i.typpayroll,
                                                '9',i.dteduepr,i.dteeval,/*i.scorepr,*/i.codrespr,
                                                i.desnote,i.typdoc2,i.codappr,'N','N',i.codcalen,v_typmove,tt_codjobt,tt_numlvlt,t1_dteempmt,
                                                i.jobgrade,i.codgrpgl,
                                                p_coduser,p_coduser);

                                   if v_found3 = 'Y' then  -- Exist in temploy3
                                       v_exist := 'Y';
                                       begin
                                         select codempid into tx_codempid
                                           from ttexempt
                                         where codempid = v_codempid
                                             and dteeffec = v_dteoccup
                                          fetch first row only;
                                       exception when no_data_found then
                                         v_exist := 'N';
                                       end;

                                       if v_exist = 'N' then
                                              -- Create table 'TTEXEMPT'
                                              insert into
                                                 ttexempt(codempid,dteeffec,codcomp,codjob,codpos,numlvl,
                                                          codexemp,typdoc,numannou,amtsalt,amtotht,
                                                          codsex,codedlv,totwkday,flgblist,staupd,flgrp,
                                                          jobgrade,codgrpgl,
                                                          codcreate,coduser)
                                                   VALUES(v_codempid,v_dteoccup,j.codcomp,j.codjob,j.codpos,j.numlvl,
                                                          I.codexemp,'2',I.numlettr,nvl(t3_amtincom1,0),nvl(t3_amtincomoth,0),
                                                          j.codsex,j.codedlv,t1_totwkday,nvl(I.flgblist,'N'),'U','N',
                                                          j.jobgrade,j.codgrpgl,
                                                          p_coduser,p_coduser);
                                        else
                                              begin
                                                    update ttexempt
                                                         set codcomp  = j.codcomp,                codjob   = j.codjob,
                                                               codpos    = j.codpos,                    numlvl   = j.numlvl,
                                                               codexemp = i.codexemp,             typdoc   = '2',
                                                               numannou = i.numlettr,                amtsalt  = nvl(t3_amtincom1,0),
                                                               amtotht  = nvl(t3_amtincomoth,0), codsex   = j.codsex,
                                                               codedlv  = j.codedlv,                    totwkday = t1_totwkday,
                                                               flgblist = nvl(i.flgblist,'N'),
                                                               staupd   = 'U',
                                                               flgrp    = 'N',
                                                               jobgrade = j.jobgrade,
                                                               codgrpgl = j.codgrpgl,
                                                               coduser  = p_coduser
                                                     where codempid = v_codempid
                                                         and dteeffec = v_dteoccup;
                                              end;
                                       end if;--if v_exist = 'N' then  -- End Create/Update table 'TTEXEMPT'

                                        -- Update Data To 'TEMPLOY1'
                                        begin
                                              update  temploy1
                                                    set staemp   = '9',
                                                         dteeffex = v_dteoccup ,
                                                         coduser     = p_coduser
                                               where rowid = j.rowid;
                                        end;

                                         begin   -- Select for ttpminf.numseq
                                                  select max(numseq) into tp_numseq
                                                    from  ttpminf
                                                  where codempid     = v_codempid
                                                      and dteeffec      = v_dteoccup;
                                               exception when no_data_found then
                                                   tp_numseq := 0;
                                         end;
                                         tp_numseq  :=  nvl(tp_numseq,0) + 1;
                                          -- Create table 'TTPMINF'
                                          insert into
                                                  ttpminf(codempid,dteeffec,numseq,codtrn,codcomp,
                                                            codpos,codjob,numlvl,codempmt,codcalen,
                                                            codbrlc,typpayroll,typemp,flgatten,
                                                            flgal,flgrp,flgap,flgbf,flgtr,flgpy,codexemp,staemp,
                                                            jobgrade,codcreate,coduser)
                                                values(v_codempid,v_dteoccup,tp_numseq,v_codtrn9,j.codcomp,
                                                          j.codpos,j.codjob,j.numlvl,j.codempmt,j.codcalen,
                                                          j.codbrlc,j.typpayroll,j.typemp,j.flgatten,
                                                          'N','N','N','N','N','N',i.codexemp,'9',
                                                          j.jobgrade,p_coduser,p_coduser);
                                   end if;  --if v_found3 = 'Y'

                          else    /*typproba = 2-Prob. Position must be Return Old Position ----- */
                                if  tt_stapost2 = '0' then  --regula Position
--<<redmine-5694
                                       if v_dteoccup is null then
                                           v_dteoccup  := i.dteduepr;
                                       end if;
--<<redmine-5694

                                       if  i.flgadjin = 'N' then   -- Not Adjust Income

--insert _temp 2('BALL','HRPM91B',2274, v_codempid  ,'v_dteoccup='||v_dteoccup,null,null,null,null,null,null,null);

                                           -- Create table 'THISMOVE'
                                           insert into
                                               thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                                           codpos,     codjob,
                                                           codbrlc,     codempmt,
                                                           stapost2,   dteempmt,    numlvl,
                                                           typemp,    typpayroll,
                                                           staemp,    dteduepr,    dteeval,/*scoreget,*/codrespr,
                                                           desnote,    typdoc,      codappr,flginput,
                                                           flgadjin,      codcalen,    typmove,
                                                           jobgrade,   codgrpgl ,
                                                           codcreate,  coduser)
                                                 values(v_codempid,v_dteoccup,v_numseq,v_codtrn,i.numlettr,i.codcomp,
                                                           i.codpos,   j.codjob,
                                                           i.codbrlc,   i.codempmt,
                                                           '0',            t1_dteempmt,        i.numlvl,
                                                           i.typemp,   i.typpayroll,
                                                           j.staemp,    i.dteduepr,       i.dteeval,/*i.scorepr,*/i.codrespr,
                                                           i.desnote,   i.typdoc2,        i.codappr,    'N',
                                                           'N',            i.codcalen,       v_typmove,
                                                           i.jobgrade,  i.codgrpgl ,
                                                           p_coduser,   p_coduser);
                                           -- End Create table 'THISMOVE'
                                      else-- flgadjin = Y
                                       -- Adjust Income
                                           if  v_found3 = 'Y' then  -- Exist in temploy3
                                                  -- Sum Amount Net Income For Update 'TEMPLOY3
                                                  tm_amtincom1  := nvl(td3_amtincom1,0)  + nvl(tadj_amtincom1,0);
                                                  tm_amtincom2  := nvl(td3_amtincom2,0)  + nvl(tadj_amtincom2,0);
                                                  tm_amtincom3  := nvl(td3_amtincom3,0)  + nvl(tadj_amtincom3,0);
                                                  tm_amtincom4  := nvl(td3_amtincom4,0)  + nvl(tadj_amtincom4,0);
                                                  tm_amtincom5  := nvl(td3_amtincom5,0)  + nvl(tadj_amtincom5,0);
                                                  tm_amtincom6  := nvl(td3_amtincom6,0)  + nvl(tadj_amtincom6,0);
                                                  tm_amtincom7  := nvl(td3_amtincom7,0)  + nvl(tadj_amtincom7,0);
                                                  tm_amtincom8  := nvl(td3_amtincom8,0)  + nvl(tadj_amtincom8,0);
                                                  tm_amtincom9  := nvl(td3_amtincom9,0)  + nvl(tadj_amtincom9,0);
                                                  tm_amtincom10 := nvl(td3_amtincom10,0) + nvl(tadj_amtincom10,0);

                                                  get_wage_income (hcm_util.get_codcomp_level(i.codcomp,'1'),i.codempmt,
                                                                          nvl(tm_amtincom1,0), nvl(tm_amtincom2,0),
                                                                          nvl(tm_amtincom3,0), nvl(tm_amtincom4,0),
                                                                          nvl(tm_amtincom5,0), nvl(tm_amtincom6,0),
                                                                          nvl(tm_amtincom7,0), nvl(tm_amtincom8,0),
                                                                          nvl(tm_amtincom9,0), nvl(tm_amtincom10,0),
                                                                          tm_amtothr, tm_amtotday, tm_amtotmth);

                                                  tm_amtothr        := round(tm_amtothr,2);
                                                  tm_amtotday      := round(tm_amtotday,2);
                                                  tm_amtotmth      := round(tm_amtotmth,2);
                                                  -- Create table 'THISMOVE'
                                                  tm_en_amtincom1  := stdenc(tm_amtincom1,v_codempid,v_chken);
                                                  tm_en_amtincom2  := stdenc(tm_amtincom2,v_codempid,v_chken);
                                                  tm_en_amtincom3  := stdenc(tm_amtincom3,v_codempid,v_chken);
                                                  tm_en_amtincom4  := stdenc(tm_amtincom4,v_codempid,v_chken);
                                                  tm_en_amtincom5  := stdenc(tm_amtincom5,v_codempid,v_chken);
                                                  tm_en_amtincom6  := stdenc(tm_amtincom6,v_codempid,v_chken);
                                                  tm_en_amtincom7  := stdenc(tm_amtincom7,v_codempid,v_chken);
                                                  tm_en_amtincom8  := stdenc(tm_amtincom8,v_codempid,v_chken);
                                                  tm_en_amtincom9  := stdenc(tm_amtincom9,v_codempid,v_chken);
                                                  tm_en_amtincom10 := stdenc(tm_amtincom10,v_codempid,v_chken);
                                                  tm_en_amtothr      := stdenc(tm_amtothr,v_codempid,v_chken);
                                                  tm_en_amtday      := stdenc(tm_amtotday,v_codempid,v_chken);--29/04/2552

                                                  insert into
                                                      thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                                               codpos,codbrlc,codempmt,
                                                               stapost2,
                                                               typemp,     typpayroll,
                                                               staemp,     dteduepr,dteeval,/*scoreget,*/codrespr,
                                                               desnote,     typdoc,codappr,flginput,flgadjin,
                                                               amtincom1, amtincom2,amtincom3,amtincom4,amtincom5,
                                                               amtincom6, amtincom7,amtincom8,amtincom9,amtincom10,
                                                               amtincadj1, amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                                                               amtincadj6, amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                                                               codcalen,    codcurr,   typmove,
                                                               codjob,       numlvl,    dteempmt,
                                                               jobgrade,    codgrpgl,
                                                               codcreate,   coduser)
                                                          values(v_codempid,v_dteoccup,v_numseq,v_codtrn,i.numlettr,i.codcomp,
                                                               i.codpos,i.codbrlc,i.codempmt,
                                                               '0',
                                                               i.typemp,i.typpayroll,
                                                               j.staemp,i.dteduepr,i.dteeval,/*i.scorepr,*/i.codrespr,
                                                               i.desnote,i.typdoc2,i.codappr,'N',i.flgadjin,
                                                               tm_en_amtincom1,tm_en_amtincom2,tm_en_amtincom3,tm_en_amtincom4,tm_en_amtincom5,
                                                               tm_en_amtincom6,tm_en_amtincom7,tm_en_amtincom8,tm_en_amtincom9,tm_en_amtincom10,
                                                               i.amtincadj1,i.amtincadj2,i.amtincadj3,i.amtincadj4,i.amtincadj5,
                                                               i.amtincadj6,i.amtincadj7,i.amtincadj8,i.amtincadj9,i.amtincadj10,
                                                               i.codcalen,i.codcurr,v_typmove,
                                                               tt_codjobt,tt_numlvlt,t1_dteempmt,
                                                               i.jobgrade,i.codgrpgl ,
                                                               p_coduser, p_coduser);
                                             -- End Create table 'THISMOVE'
                                             -- Update Data To 'TEMPLOY3'
                                               begin
                                                 update temploy3
                                                       set amtincom1  = tm_en_amtincom1,  amtincom2  = tm_en_amtincom2,
                                                            amtincom3  = tm_en_amtincom3,  amtincom4  = tm_en_amtincom4,
                                                            amtincom5  = tm_en_amtincom5,  amtincom6  = tm_en_amtincom6,
                                                            amtincom7  = tm_en_amtincom7,  amtincom8  = tm_en_amtincom8,
                                                            amtincom9  = tm_en_amtincom9,  amtincom10 = tm_en_amtincom10,
                                                            amtothr    = tm_en_amtothr  ,
                                                            amtday     = tm_en_amtday ,
                                                            coduser     = p_coduser
                                                  where codempid = v_codempid;
                                               end;
                                                -- Keep old amtincom and code imcome
                                                to_amtincom1  := tm_amtincom1  - nvl(tadj_amtincom1,0);
                                                to_amtincom2  := tm_amtincom2  - nvl(tadj_amtincom2,0);
                                                to_amtincom3  := tm_amtincom3  - nvl(tadj_amtincom3,0);
                                                to_amtincom4  := tm_amtincom4  - nvl(tadj_amtincom4,0);
                                                to_amtincom5  := tm_amtincom5  - nvl(tadj_amtincom5,0);
                                                to_amtincom6  := tm_amtincom6  - nvl(tadj_amtincom6,0);
                                                to_amtincom7  := tm_amtincom7  - nvl(tadj_amtincom7,0);
                                                to_amtincom8  := tm_amtincom8  - nvl(tadj_amtincom8,0);
                                                to_amtincom9  := tm_amtincom9  - nvl(tadj_amtincom9,0);
                                                to_amtincom10 := tm_amtincom10 - nvl(tadj_amtincom10,0);

                                                tm_en_amtincom1  := stdenc(to_amtincom1,v_codempid,v_chken);
                                                tm_en_amtincom2  := stdenc(to_amtincom2,v_codempid,v_chken);
                                                tm_en_amtincom3  := stdenc(to_amtincom3,v_codempid,v_chken);
                                                tm_en_amtincom4  := stdenc(to_amtincom4,v_codempid,v_chken);
                                                tm_en_amtincom5  := stdenc(to_amtincom5,v_codempid,v_chken);
                                                tm_en_amtincom6  := stdenc(to_amtincom6,v_codempid,v_chken);
                                                tm_en_amtincom7  := stdenc(to_amtincom7,v_codempid,v_chken);
                                                tm_en_amtincom8  := stdenc(to_amtincom8,v_codempid,v_chken);
                                                tm_en_amtincom9  := stdenc(to_amtincom9,v_codempid,v_chken);
                                                tm_en_amtincom10 := stdenc(to_amtincom10,v_codempid,v_chken);
--<<Redmine#7881 user46 25/04/2022 Cut insert tfincadj
/*                                                begin   -- Select for TFINCADJ.NUMSEQ
                                                      select max(numseq) into tf_numseq
                                                        from  tfincadj
                                                     where   codempid = v_codempid
                                                        and dteeffec = v_dteoccup;
                                                    exception when no_data_found then tf_numseq := 0;
                                                end;
                                                tf_numseq  :=  nvl(tf_numseq,0) + 1;
                                                  -- Create table 'TFINCADJ'
                                                  insert into
                                                      tfincadj(codempid,dteeffec,numseq,
                                                               amtinco1,amtinco2,amtinco3,amtinco4,amtinco5,
                                                               amtinco6,amtinco7,amtinco8,amtinco9,amtinco10,
                                                               amtincn1,amtincn2,amtincn3,amtincn4,amtincn5,
                                                               amtincn6,amtincn7,amtincn8,amtincn9,amtincn10,
                                                               codincom1,codincom2,codincom3,codincom4,codincom5,
                                                               codincom6,codincom7,codincom8,codincom9,codincom10,
                                                               dtetranf,staupd,flgbf,
                                                               typpayroll,typpayrolt,codempmt,codempmtt,
                                                               codcreate,coduser)
                                                      values(v_codempid,v_dteoccup,tf_numseq,
                                                               tm_en_amtincom1,tm_en_amtincom2,tm_en_amtincom3,tm_en_amtincom4,tm_en_amtincom5,
                                                               tm_en_amtincom6,tm_en_amtincom7,tm_en_amtincom8,tm_en_amtincom9,tm_en_amtincom10,
                                                               i.amtincadj1,i.amtincadj2,i.amtincadj3,i.amtincadj4,i.amtincadj5,
                                                               i.amtincadj6,i.amtincadj7,i.amtincadj8,i.amtincadj9,i.amtincadj10,
                                                               to_codincom1,to_codincom2,to_codincom3,to_codincom4,to_codincom5,
                                                               to_codincom6,to_codincom7,to_codincom8,to_codincom9,to_codincom10,
                                                                to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),'T','N',
                                                                i.typpayroll,j.typpayroll,i.codempmt,j.codempmt,
                                                                p_coduser,p_coduser);
                                                  -- End Create table 'TFINCADJ'
*/
-->>Redmine#7881 user46 25/04/2022
                                           end if;  --if v_found3 = 'Y'
                                       end if;  --if i.flgadjin = 'N'

                                      -- Update Data To 'TEMPLOY1'
                                       if   i.flgrepos = 'Y' then
                                            begin
                                                   update temploy1
                                                        set codcomp    = tt_codcompt,   codpos     = tt_codposnow,
                                                              codjob     = tt_codjobt,    numlvl     = tt_numlvlt,
                                                              codbrlc    = tt_codbrlct,   flgatten   = tt_flgattet,
                                                              codcalen   = tt_codcalet,   typpayroll = tt_typpayrolt,
                                                              codempmt   = tt_codempmtt,  typemp     = tt_typempt,
                                                              jobgrade   = tt_jobgradet,  codgrpgl   = tt_codgrpglt  ,
                                                              coduser     = p_coduser
                                                  where   rowid = j.rowid;
                                            end;
                                       end if;  --if   i.flgrepos = 'Y' then
                                   end if;  --if tt_stapost2 = '0'

                              end if;  --if i.typproba = '1'-New Hire

                           else    /*codrespr = E *** Type of Probation is E-Extend *** */
                                    begin   -- Select for NUMSEQ
                                       select max(numseq) into v_numseq
                                         from  thismove
                                       where codempid = v_codempid
                                           and dteeffec  = i.dteduepr;
                                       exception when no_data_found then
                                           v_numseq := 0;
                                    end;
                                    v_numseq  :=  nvl(v_numseq,0) + 1;

                                  -- Create table 'THISMOVE'
                                  insert into
                                      thismove(codempid,dteeffec,numseq,codtrn,numannou,codcomp,
                                               codpos,codbrlc,codempmt,typemp,typpayroll,
                                               staemp,dteduepr,dteeval,/*scoreget,*/codrespr,
                                               desnote,typdoc,codappr,flginput,flgadjin,codcalen,typmove,
                                               codjob,numlvl,dteempmt,
                                               jobgrade,codgrpgl,
                                               stapost2 ,qtyexpand ,
                                               codcreate,coduser)
                                       values(v_codempid,i.dteduepr, v_numseq,v_codtrn,i.numlettr,i.codcomp,
                                               i.codpos,    i.codbrlc,       i.codempmt,i.typemp,i.typpayroll,
                                               j.staemp,    i.dteexpand,  i.dteeval,/*i.scorepr,*/i.codrespr,
                                               i.desnote,   i.typdoc2,     i.codappr,'N','N',i.codcalen,v_typmove,
                                               tt_codjobt,  tt_numlvlt,     t1_dteempmt,
                                               i.jobgrade,  i.codgrpgl,
                                               '0' ,            i.qtyexpand ,
                                               p_coduser,  p_coduser);
                                           -- End Create table 'THISMOVE'

                                 if i.typproba = '1' then
                                      -- Update Data To 'TEMPLOY1'
                                      if j.dteredue is  null  then
                                              update temploy1
                                                    set dteduepr  = i.dteexpand,
                                                          coduser   = p_coduser
                                                where rowid = j.rowid;
                                      else
                                               update temploy1
                                                     set dteredue  = i.dteexpand,
                                                          coduser   = p_coduser
                                                where rowid = j.rowid;
                                      end if;

                                 else  --i.typproba = '2'
                                         -- Update Data To 'TTMOVEMT'
                                         update ttmovemt
                                               set dteduepr  = i.dteexpand ,
                                                    coduser   = p_coduser
                                          where codempid = i.codempid
                                              and dteeffec = i.dteeffec
                                              and numseq   = i.numseq;
                                 end if;--if i.typproba = '1' then

                                 /***************/
                          end if;  --if i.codrespr = 'P'
                  else
                        v_staemp9  := 'Y';
                  end if;  --if j.staemp   in ('1','3') then
         -- End Type of Probation is P-Pass,N-Not Pass,E-Extend

         end loop;  --for j in c_temploy1 loop

                   -- Update FLGUPD To ttprobat
                    tm_en_amtincom1  := stdenc(tm_amtincom1,v_codempid,v_chken);
                    tm_en_amtincom2  := stdenc(tm_amtincom2,v_codempid,v_chken);
                    tm_en_amtincom3  := stdenc(tm_amtincom3,v_codempid,v_chken);
                    tm_en_amtincom4  := stdenc(tm_amtincom4,v_codempid,v_chken);
                    tm_en_amtincom5  := stdenc(tm_amtincom5,v_codempid,v_chken);
                    tm_en_amtincom6  := stdenc(tm_amtincom6,v_codempid,v_chken);
                    tm_en_amtincom7  := stdenc(tm_amtincom7,v_codempid,v_chken);
                    tm_en_amtincom8  := stdenc(tm_amtincom8,v_codempid,v_chken);
                    tm_en_amtincom9  := stdenc(tm_amtincom9,v_codempid,v_chken);
                    tm_en_amtincom10 := stdenc(tm_amtincom10,v_codempid,v_chken);
                    if v_staemp9 = 'Y' then
                        update ttprobat
                              set staupd     = 'U',
                                   coduser   = p_coduser
                         where codempid   = i.codempid
                            and dteduepr     = i.dteduepr;
                    else
                            if i.flgadjin = 'N' then   -- Not Adjust Income
                                        update ttprobat
                                              set staupd     = v_staupd  ,
                                                    coduser   = p_coduser
                                         where codempid   = i.codempid
                                             and dteduepr   = i.dteduepr;
                            else
                                        update ttprobat
                                              set staupd     = v_staupd,
                                                   amtincom1  = tm_en_amtincom1,    amtincom2  = tm_en_amtincom2,
                                                   amtincom3  = tm_en_amtincom3,    amtincom4  = tm_en_amtincom4,
                                                   amtincom5  = tm_en_amtincom5,    amtincom6  = tm_en_amtincom6,
                                                   amtincom7  = tm_en_amtincom7,    amtincom8  = tm_en_amtincom8,
                                                   amtincom9  = tm_en_amtincom9,    amtincom10 = tm_en_amtincom10,
                                                   coduser   = p_coduser
                                        where  codempid   = i.codempid
                                            and dteduepr   = i.dteduepr;

                            end if;
                    end if;

                    if v_staupd <> 'C' then
                            v_sum    :=  v_sum + 1;
                    else
                            v_err    :=  v_err + 1;
                            -- GEN ERROR Modify 01/07/2011 by Mr.Sam
                            ins_errtmp(i.codempid,i.codcomp,i.codpos,'HR2055','TEMPLOY1',v_topic4,p_coduser);
                            -- GEN ERROR Modify 01/07/2011 by Mr.Sam

                            -- insert batch process detail
                            hcm_batchtask.insert_batch_detail(
                              p_codapp   => global_v_batch_codapp,
                              p_coduser  => p_coduser,
                              p_codalw   => global_v_batch_codapp||'7',
                              p_dtestrt  => p_dtetim,
                              p_item01  => i.codempid,
                              p_item02  => i.codcomp,
                              p_item03  => i.codpos,
                              p_item04  => 'HR2055',
                              p_item05  => 'TEMPLOY1',
                              p_item06  => v_topic4,
                              p_item07  => p_coduser
                            );

                    end if;--if v_staupd <> 'C' then

      end if; --if v_secu then
    end loop; --for i in c_ttprobat loop

    commit;
    o_sum   := v_sum;
    o_err   := v_err;
  end;--  procedure process_probation

  -- 6-Reemployment
  procedure process_reemployment (p_codcomp  in  varchar2,p_endate in date,p_coduser in varchar2,p_flgmove in varchar2,-- user22 : 07/10/2017 : STA4-1701 || + p_flgmove
                                  o_sum      out number,o_err       out number,
                                  o_user     out number,o_erruser   out number,
                                  p_dtetim in date default sysdate) is
    v_zupdsal      varchar2(1 char);
    v_secu         boolean;
    v_staupd       ttrehire.staupd%type;    -- Exist from temploy1 = 'U' else = 'N'
    v_found        varchar2(1 char);        -- Exist from temploy1,temploy2,temploy3
    v_dup          varchar2(1 char);
    v_codempid     ttrehire.codempid%type;  -- Old Codempid
    v_dtereemp     ttrehire.dtereemp%type;  -- New dteempmt
    v_codnewid     ttrehire.codnewid%type;  -- New Codempid
    t_codempid     temploy1.codempid%type;  -- For select when exist
    v_ocodempid    temploy1.ocodempid%type; -- Old Codempid
    -- Variable for thismove
    v_numseq       thismove.numseq%type;
    v_codtrn       thismove.codtrn%type;    -- For codtrn = '0002'-Rehire
    v_typmove      thismove.typmove%type;
    v_desnote      thismove.desnote%type;
    -- Variable for ttrehire
    tt_staemp      temploy1.staemp%type;
    tt_dteduepr    temploy1.dteduepr%type;
    tt_dteempmt    temploy1.dteempmt%type;
    tt_dteoccup    temploy1.dteoccup%type;
    tt_qtywkday    temploy1.qtywkday%type;
    -- Variable for tempimge

    -- Variable for tleavetr
    -- Variable for treqest1
    t_totqtyact    number;
    t_totreq       number;
    t_stareq       treqest1.stareq%type;
    -- Variable for treqest2
    t_qtyact       treqest2.qtyact%type;

    t1_codempid     temploy1.codempid%type;
    t1_codtitle     temploy1.codtitle%type;
    t1_namfirste    temploy1.namfirste%type;
    t1_namfirstt    temploy1.namfirstt%type;
    t1_namfirst3    temploy1.namfirst3%type;
    t1_namfirst4    temploy1.namfirst4%type;
    t1_namfirst5    temploy1.namfirst5%type;
    t1_namlaste     temploy1.namlaste%type;
    t1_namlastt     temploy1.namlastt%type;
    t1_namlast3     temploy1.namlast3%type;
    t1_namlast4     temploy1.namlast4%type;
    t1_namlast5     temploy1.namlast5%type;
    t1_namempe      temploy1.namempe%type;
    t1_namempt      temploy1.namempt%type;
    t1_namemp3      temploy1.namemp3%type;
    t1_namemp4      temploy1.namemp4%type;
    t1_namemp5      temploy1.namemp5%type;
    t1_codsex       temploy1.codsex%type;
    t1_dteempdb     temploy1.dteempdb%type;
    t1_stamarry     temploy1.stamarry%type;
    t1_staemp       temploy1.staemp%type;
    t1_dteempmt     temploy1.dteempmt%type;
    t1_codempmt     temploy1.codempmt%type;
    t1_codcomp      temploy1.codcomp%type;
    t1_codpos       temploy1.codpos%type;
    t1_codjob       temploy1.codjob%type;
    t1_numlvl       temploy1.numlvl%type;
    t1_codbrlc      temploy1.codbrlc%type;
    t1_codcalen     temploy1.codcalen%type;
    t1_dteefpos     temploy1.dteefpos%type;
    t1_dteeflvl     temploy1.dteeflvl%type;
    t1_flgreemp     temploy1.flgreemp%type;
    t1_qtywkday     temploy1.qtywkday%type;
    t1_codedlv      temploy1.codedlv%type;
    t1_codmajsb     temploy1.codmajsb%type;
    t1_numreqst     temploy1.numreqst%type;
    t1_dteduepr     temploy1.dteduepr%type;
    t1_dteoccup     temploy1.dteoccup%type;
    t1_typpayroll   temploy1.typpayroll%type;
    t1_qtydatrq     temploy1.qtydatrq%type;
    t1_numappl      temploy1.numappl%type;
    t1_flgatten     temploy1.flgatten%type;
    t1_typemp       temploy1.typemp%type;
    t1_numtelof     temploy1.numtelof%type;
    t1_email        temploy1.email%type;
    t1_ocodempid    temploy1.ocodempid%type;
    t1_dtereemp     temploy1.dtereemp%type;
    t1_dteredue     temploy1.dteredue%type;
    t1_dteeffex     temploy1.dteeffex%type;
    t1_dteupd       temploy1.dteupd%type;
    t1_coduser      temploy1.coduser%type;
    t1_jobgrade     temploy1.jobgrade%type;
    t1_dteefstep    temploy1.dteefstep%type;
    t1_codgrpgl     temploy1.codgrpgl%type;
    t1_stadisb      temploy1.stadisb%type;
    t1_numdisab     temploy1.numdisab%type;
    t1_typdisp      temploy1.typdisp%type;
    t1_dtedisb      temploy1.dtedisb%type;
    t1_dtedisen     temploy1.dtedisen%type;
    t1_desdisp      temploy1.desdisp%type;
    t1_dteretire    temploy1.dteretire%type;
    t2_stamilit     temploy1.stamilit%type;
    t2_adrrege      temploy2.adrrege%type;
    t2_adrregt      temploy2.adrregt%type;
    t2_adrreg3      temploy2.adrreg3%type;
    t2_adrreg4      temploy2.adrreg4%type;
    t2_adrreg5      temploy2.adrreg5%type;
    t2_codsubdistr  temploy2.codsubdistr%type;
    t2_coddistr     temploy2.coddistr%type;
    t2_codprovr     temploy2.codprovr%type;
    t2_codcntyr     temploy2.codcntyr%type;
    t2_codpostr     temploy2.codpostr%type;
    t2_adrconte     temploy2.adrconte%type;
    t2_adrcontt     temploy2.adrcontt%type;
    t2_adrcont3     temploy2.adrcont3%type;
    t2_adrcont4     temploy2.adrcont4%type;
    t2_adrcont5     temploy2.adrcont5%type;
    t2_codsubdistc  temploy2.codsubdistc%type;
    t2_coddistc     temploy2.coddistc%type;
    t2_codprovc     temploy2.codprovc%type;
    t2_codcntyc     temploy2.codcntyc%type;
    t2_codpostc     temploy2.codpostc%type;
    t2_numtelec     temploy2.numtelec%type;
    t2_codblood     temploy2.codblood%type;
    t2_weight       temploy2.weight%type;
    t2_high         temploy2.high%type;
    t2_codrelgn     temploy2.codrelgn%type;
    t2_codorgin     temploy2.codorgin%type;
    t2_codnatnl     temploy2.codnatnl%type;
    t2_coddomcl     temploy2.coddomcl%type;
    t2_numoffid     temploy2.numoffid%type;
    t2_adrissue     temploy2.adrissue%type;
    t2_codprovi     temploy2.codprovi%type;
    t2_dteoffid     temploy2.dteoffid%type;
    t2_numlicid     temploy2.numlicid%type;
    t2_dtelicid     temploy2.dtelicid%type;
    t2_numpasid     temploy2.numpasid%type;
    t2_dtepasid     temploy2.dtepasid%type;
    t2_numprmid     temploy2.numprmid%type;
    t2_dteprmst     temploy2.dteprmst%type;
    t2_dteprmen     temploy2.dteprmen%type;
    t3_codcurr     temploy3.codcurr%type;
    t3_amtincom1   temploy3.amtincom1%type;
    t3_amtincom2   temploy3.amtincom2%type;
    t3_amtincom3   temploy3.amtincom3%type;
    t3_amtincom4   temploy3.amtincom4%type;
    t3_amtincom5   temploy3.amtincom5%type;
    t3_amtincom6   temploy3.amtincom6%type;
    t3_amtincom7   temploy3.amtincom7%type;
    t3_amtincom8   temploy3.amtincom8%type;
    t3_amtincom9   temploy3.amtincom9%type;
    t3_amtincom10  temploy3.amtincom10%type;
    t3_numtaxid    temploy3.numtaxid%type;
    t3_numsaid     temploy3.numsaid%type;
    t3_flgtax      temploy3.flgtax%type;
    t3_typtax      temploy3.typtax%type;
    t3_codbank     temploy3.codbank%type;
    t3_numbank     temploy3.numbank%type;
    t3_amtbank     temploy3.amtbank%type;
    t3_codbank2    temploy3.codbank2%type;
    t3_numbank2    temploy3.numbank2%type;
    t3_amtothr     temploy3.amtothr%type;
    t3_amtday      temploy3.amtday%type;
    t3_dtebf       temploy3.dtebf%type;
    t3_amtincbf    temploy3.amtincbf%type;
    t3_amttaxbf    temploy3.amttaxbf%type;
    t3_amtpf       temploy3.amtpf%type;
    t3_amtsaid     temploy3.amtsaid%type;
    t3_dtebfsp     temploy3.dtebfsp%type;
    t3_amtincsp    temploy3.amtincsp%type;
    t3_amttaxsp    temploy3.amttaxsp%type;
    t3_amtsasp     temploy3.amtsasp%type;
    t3_amtpfsp     temploy3.amtpfsp%type;
    t3_qtychedu    temploy3.qtychedu%type;
    t3_qtychned    temploy3.qtychned%type;
    t3_dteyrrelf   temploy3.dteyrrelf%type;
    t3_dteyrrelt   temploy3.dteyrrelt%type;
    t3_amtrelas    temploy3.amtrelas%type;
    t3_amttaxrel   temploy3.amttaxrel%type;
    t3_numbrnch    temploy3.numbrnch%type;
    t3_numbrnch2   temploy3.numbrnch2%type;
    t3_amtproadj   temploy3.amtproadj%type;
    t3_typincom    temploy3.typincom%type;
    t3_flgslip     temploy3.flgslip%type;
    t3_amttranb    temploy3.amttranb%type;
    --
    v_amtothr      number;
    v_amtotday     number;
    v_amtotmth     number;
    tm_amtincom1   temploy3.amtincom1%type;
    tm_amtincom2   temploy3.amtincom2%type;
    tm_amtincom3   temploy3.amtincom3%type;
    tm_amtincom4   temploy3.amtincom4%type;
    tm_amtincom5   temploy3.amtincom5%type;
    tm_amtincom6   temploy3.amtincom6%type;
    tm_amtincom7   temploy3.amtincom7%type;
    tm_amtincom8   temploy3.amtincom8%type;
    tm_amtincom9   temploy3.amtincom9%type;
    tm_amtincom10  temploy3.amtincom10%type;
    tm_amtincadj1   temploy3.amtincom1%type;
    tm_amtincadj2   temploy3.amtincom2%type;
    tm_amtincadj3   temploy3.amtincom3%type;
    tm_amtincadj4   temploy3.amtincom4%type;
    tm_amtincadj5   temploy3.amtincom5%type;
    tm_amtincadj6   temploy3.amtincom6%type;
    tm_amtincadj7   temploy3.amtincom7%type;
    tm_amtincadj8   temploy3.amtincom8%type;
    tm_amtincadj9   temploy3.amtincom9%type;
    tm_amtincadj10  temploy3.amtincom10%type;
    tm_amtnett    temploy3.amtincom1%type;
    tm_amtcalt    temploy3.amtincom1%type;
    tm_amtinclt   temploy3.amtincom1%type;
    tm_amtincct   temploy3.amtincom1%type;
    tm_amtincnt   temploy3.amtincom1%type;
    tm_amtexplt   temploy3.amtincom1%type;
    tm_amtexpct   temploy3.amtincom1%type;
    tm_amtexpnt   temploy3.amtincom1%type;
    tm_amttaxt    temploy3.amtincom1%type;
    tm_amtgrstxt  temploy3.amtincom1%type;
    tm_amtsoct    temploy3.amtincom1%type;
    tm_amtsocat   temploy3.amtincom1%type;
    tm_amtsocct   temploy3.amtincom1%type;
    tm_amtcprvt   temploy3.amtincom1%type;
    tm_amtprovte  temploy3.amtincom1%type;
    tm_amtprovtc  temploy3.amtincom1%type;
    tm_amtsalyr   temploy3.amtincom1%type;
    tm_amttaxyr   temploy3.amtincom1%type;
    tm_amtsocyr   temploy3.amtincom1%type;
    tm_amttcprv   temploy3.amtincom1%type;
    tm_amtproyr   temploy3.amtincom1%type;
    v_amtlvded    temploy3.amtincom1%type;
    ---
    v_sum         number;
    v_err         number;
    v_user				number;
    v_erruser		  number;
    t_sum         number;
    t_err         number;
    v_chksecu     varchar2(1 char);
    v_zminlvl     number;
    v_zwrklvl     number;
    x_codempid		temploy1.codempid%type;
    v_chkreg 			varchar2(100);
    v_zyear				number;
    v_amtdeduct   number;
    v_flgcompDif	varchar2(1);
    v_codcomp			temploy1.codcomp%type;
    v_codempmt 		temploy1.codempmt%type;
    v_codcalen 		temploy1.codcalen%type;
    v_codbrlc  		temploy1.codbrlc%type;
    v_typpayroll  temploy1.typpayroll%type;
    v_typemp  		temploy1.typemp%type;
    v_flgatten  	temploy1.flgatten%type;
    v_staemp	  	temploy1.staemp%type;
    v_codpos	  	temploy1.codpos%type;
    v_codjob	  	temploy1.codjob%type;
    v_numlvl	  	temploy1.numlvl%type;
    v_codsex	  	temploy1.codsex%type;
    v_jobgrade  	temploy1.jobgrade%type;
    v_codgrpgl  	temploy1.codgrpgl%type;
    v_codedlv	  	temploy1.codedlv%type;
    v_dteempmt	 	temploy1.dteempmt%type;
    v_qtywkday		temploy1.qtywkday%type;
    tp_numseq			number;
    v_amtincom1		number;
    v_amtincom2 	number;
    v_amtincom3 	number;
    v_amtincom4 	number;
    v_amtincom5 	number;
    v_amtincom6 	number;
    v_amtincom7 	number;
    v_amtincom8 	number;
    v_amtincom9 	number;
    v_amtincom10	number;
    v_amtotht   	number;
    v_totwkday		number;

    v_namimage    tempimge.namimage%type;
    v_namsign     tempimge.namsign%type;

    v_codempidrehire    ttrehire.codempid%type; --user36 10/05/2022

    cursor c_ttrehire is
      select codempid, dtereemp, numreqst, codcomp, codpos,
             flgreemp, codnewid, flgrp, codsend, codappr, dteappr,
             staupd, remarkap, dteupd, coduser, dteduepr, staemp,
             codoldid, codbrlc, codempmt, typpayroll, typemp, codcalen, codjob,
             numlvl, flgatten, codcurr, jobgrade , codgrpgl ,
             amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
             amtincom6, amtincom7, amtincom8, amtincom9, amtincom10, amtothr,
             flgmove,codexemp
        from ttrehire
       where codcomp  like p_codcomp||'%'
         and staupd   = 'C'
         and dtereemp <= p_endate
         and flgmove  = nvl(p_flgmove,flgmove)
    order by codempid,dtereemp;

    cursor c_temploy1 is
      select codempid,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,namempe,namempt,namemp3,namemp4,namemp5,
             dteempdb,stamarry,codsex,dteempmt,codcomp,codpos,numlvl,staemp,dteeffex,flgatten,codbrlc,codempmt,typpayroll,typemp,codcalen,codjob,codcompr,codposre,
             dteeflvl,dteefpos,dteduepr,dteoccup,qtydatrq,numtelof,email,numreqst,numappl,ocodempid,flgreemp,dtereemp,dteredue,qtywkday,codedlv,codmajsb,numreqc,
             codposc,flgreq,stareq,codappr,dteappr,dteupd,coduser,staappr,remarkap,codreq,jobgrade,dteefstep,codgrpgl,stadisb,numdisab,typdisp,dtedisb,dtedisen,desdisp,dteretire,
             nickname,nicknamt,nicknam3,nicknam4,nicknam5,stamilit,nummobile,lineid,typtrav,qtylength,carlicen,typfuel,codbusno,codbusrt
        from temploy1
       where codempid  = v_codempid
         and staemp    = '9';

    cursor c_temploy2 is
      select codempid,adrrege,adrregt,adrreg3,adrreg4,adrreg5,codsubdistr,coddistr,codprovr,codcntyr,codpostr,adrconte,adrcontt,adrcont3,adrcont4,adrcont5,codsubdistc,coddistc,codprovc,
             codcntyc,codpostc,numtelec,codblood,weight,high,codrelgn,codorgin,codnatnl,coddomcl,numoffid,adrissue,codprovi,dteoffid,numlicid,dtelicid,numpasid,dtepasid,numprmid,dteprmst,dteprmen,
             codclnsc,numvisa,dtevisaexp,dteupd,coduser
        from temploy2
       where codempid  = v_codempid;

    cursor c_temploy3 is
      select codempid, codcurr, amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
             amtincom6, amtincom7, amtincom8, amtincom9, amtincom10, numtaxid, numsaid,
             flgtax, typtax, codbank, numbank, amtbank, codbank2, numbank2, amtothr, amtday,
             dtebf, amtincbf, amttaxbf, amtpf, amtsaid, dtebfsp,
             amtincsp, amttaxsp, amtsasp, amtpfsp, qtychedu, qtychned,
             dteyrrelf,dteyrrelt,amtrelas,amttaxrel,numbrnch,numbrnch2,
             typincom, flgslip
        from temploy3
       where codempid  = v_codempid;

    cursor c_tchildrn is
      select codempid,numseq,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
             namlaste,namlastt,namlast3,namlast4,namlast5,namche,namcht,namch3,namch4,namch5,
             numoffid,dtechbd,codsex,codedlv,stachld,stalife,dtedthch,flginc,flgedlv,flgdeduct,
             stabf,filename,numrefdoc
        from tchildrn
       where codempid  = v_codempid;

    cursor c_tspouse is
      select codempid,codempidsp,namimgsp,codtitle,namfirste,namfirstt,
             namfirst3,namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,
             namspe,namspt,namsp3,namsp4,namsp5,numoffid,numtaxid,codspocc,dtespbd,stalife,
             staincom,dtedthsp,desnoffi,numfasp,nummosp,dtemarry,codsppro,codspcty,desplreg,
             desnote,filename,numrefdoc
        from tspouse
       where codempid  = v_codempid;

    cursor c_tfamily is
      select codempid,codempfa,codtitlf,namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
             namlstfe,namlstft,namlstf3,namlstf4,namlstf5,namfathe,namfatht,namfath3,namfath4,namfath5,
             numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,staliff,dtedeathf,filenamf,numrefdocf,codempmo,
             codtitlm,namfstme,namfstmt,namfstm3,namfstm4,namfstm5,namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
             nammothe,nammotht,nammoth3,nammoth4,nammoth5,numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,stalifm,
             dtedeathm,filenamm,numrefdocm,codtitlc,namfstce,namfstct,namfstc3,namfstc4,namfstc5,
             namlstce,namlstct,namlstc3,namlstc4,namlstc5,namconte,namcontt,namcont3,namcont4,namcont5,
             adrcont1,codpost,numtele,numfax,email,desrelat
        from tfamily
       where codempid  = v_codempid;

    cursor c_trelatives is
      select codempid,numseq,codemprl,namrele,namrelt,namrel3,namrel4,namrel5,numtelec,adrcomt
        from trelatives
       where codempid  = v_codempid;

    cursor c_tempded is
      select codempid,coddeduct,amtdeduct,amtspded,dteupd,coduser
        from tempded
       where codempid  = v_codempid;

    cursor c_tdeductd is
      select coddeduct,amtdemax,flgdef
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy')) - v_zyear)
         and typdeduct in ('E','O','D')
         and coddeduct not in ('D001','D002','E001');

  begin
    v_codtrn      := '0002';
    v_sum         := 0;
    v_err         := 0;
    v_user        := 0;
    v_erruser     := 0;
    if p_coduser is not null   then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
          into v_zminlvl,v_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;
    for i in c_ttrehire loop
      if p_coduser = 'AUTO' then
        v_secu  :=  true;
      else
        v_secu   :=  secur_main.secur1(i.codcomp,i.numlvl,p_coduser,v_zminlvl,v_zwrklvl, v_zupdsal);
      end if;
      if v_secu then

        v_codempid := null;
        if i.flgmove = 'T' then
                      begin
                           select a.codempid,a.codcomp,a.codpos,a.codjob,a.numlvl,a.codempmt,a.codcalen,a.codbrlc,a.typpayroll,a.typemp,a.flgatten,a.staemp,a.codsex,a.jobgrade,a.codgrpgl,a.codedlv,a.dteempmt,a.qtywkday,
                                  stddec(b.amtincom1,b.codempid,v_chken),stddec(b.amtincom2,b.codempid,v_chken),stddec(b.amtincom3,b.codempid,v_chken),stddec(b.amtincom4,b.codempid,v_chken),stddec(b.amtincom5,b.codempid,v_chken),stddec(b.amtincom6,b.codempid,v_chken),stddec(b.amtincom7,b.codempid,v_chken),stddec(b.amtincom8,b.codempid,v_chken),stddec(b.amtincom9,b.codempid,v_chken),stddec(b.amtincom10,b.codempid,v_chken)
                             into v_codempid,v_codcomp,v_codpos,v_codjob,v_numlvl,v_codempmt,v_codcalen,v_codbrlc,v_typpayroll,v_typemp,v_flgatten,v_staemp,v_codsex,v_jobgrade,v_codgrpgl,v_codedlv,v_dteempmt,v_qtywkday,
                                  v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
                             from temploy1 a, temploy3 b
                            where a.codempid  = b.codempid
                              and a.codempid  = i.codempid
                              and a.staemp   <> '9';
                            exception when others then null;
                      end;

                      if v_codempid is not null then
                        v_amtotht  := nvl(v_amtincom2,0) + nvl(v_amtincom3,0) + nvl(v_amtincom4,0) + nvl(v_amtincom5,0) + nvl(v_amtincom6,0) + nvl(v_amtincom7,0) + nvl(v_amtincom8,0) + nvl(v_amtincom9,0) + nvl(v_amtincom10,0);
                        v_totwkday := (trunc(i.dtereemp) - v_dteempmt) + nvl(v_qtywkday,0);
                        begin
                          insert into ttexempt(codempid,dteeffec, codcomp,codjob,
                                                        codpos,codempmt,numlvl,codexemp,numexemp,
                                                        typdoc,numannou,desnote,amtsalt,
                                                        amtotht,codsex,codedlv,totwkday,
                                                        flgblist,staupd,flgrp,flgssm,
                                                        codappr,dteappr,remarkap,dteupd,
                                                        coduser,codreq,jobgrade,codgrpgl)
                                             values(v_codempid,trunc(i.dtereemp), v_codcomp,v_codjob,
                                                       v_codpos,v_codempmt,v_numlvl,i.codexemp,null,
                                                       null,null,null,stdenc(v_amtincom1,v_codempid,v_chken),
                                                       stdenc(v_amtotht,v_codempid,v_chken), v_codsex,v_codedlv,v_totwkday,
                                                       'N','C','N','1',
                                                       i.codsend,trunc(sysdate),null,trunc(sysdate),
                                                       i.codsend,v_codempid,v_jobgrade,v_codgrpgl);

--begin update  temploy1 set staemp      = '9', coduser     = p_coduser where   codempid    = v_codempid; end;

                          begin
                            select numseq into tp_numseq
                              from ttpminf
                             where codempid  = v_codempid
                               and dteeffec  = i.dtereemp
                               and codtrn    = '0006';
                          exception when no_data_found then
                            tp_numseq := null;
                          end;
                          if tp_numseq is null then
                            insert into	ttpminf(codempid,dteeffec,numseq,codtrn,
                                                codcomp,codpos,codjob,numlvl,codempmt,codcalen,codbrlc,typpayroll,typemp,flgatten,
                                                flgal,flgrp,flgap,flgbf,flgtr,flgpy,
                                                jobgrade,codexemp,
                                                staemp,dteupdc,dteupd,coduser)
                                         values(v_codempid,trunc(i.dtereemp),1,'0006',
                                                v_codcomp,v_codpos,v_codjob,v_numlvl,v_codempmt,v_codcalen,v_codbrlc,v_typpayroll,v_typemp,v_flgatten,
                                                'N','N','N','N','N','N',
                                                v_jobgrade,i.codexemp,
                                                v_staemp,trunc(sysdate),trunc(sysdate),p_coduser);
                          end if;--tp_numseq is null

                        process_exemption(v_codcomp,v_codempid,i.dtereemp,p_coduser,t_sum,t_err);
                        exception when dup_val_on_index then null;
                        end;
                      end if;--v_codempid is not null
        end if;-- if i.flgmove = 'T' then

        v_chksecu    		:=  'Y';
        v_staupd          :=  'C';
        v_dup              :=  'N';
        v_codempid      :=  i.codempid;
        v_codnewid      :=  i.codnewid;

        if v_codnewid = v_codempid then
          v_codnewid      :=  null;
        end if;
        v_dtereemp        :=  i.dtereemp;
        tt_dteempmt       :=  i.dtereemp;
        v_desnote         :=  'Old Emp. Code is ' || i.codempid;
        t1_staemp         :=  i.staemp;
        t1_dteduepr       :=  i.dteduepr;
        tt_dteduepr       :=  i.dteduepr;
        tt_staemp         :=  i.staemp;
        t1_dtereemp       :=  i.dtereemp;
        t3_amtincom1      :=  i.amtincom1;
        t3_amtincom2      :=  i.amtincom2;

        t3_amtincom3      :=  i.amtincom3;
        t3_amtincom4      :=  i.amtincom4;
        t3_amtincom5      :=  i.amtincom5;
        t3_amtincom6      :=  i.amtincom6;
        t3_amtincom7      :=  i.amtincom7;
        t3_amtincom8      :=  i.amtincom8;
        t3_amtincom9      :=  i.amtincom9;
        t3_amtincom10     :=  i.amtincom10;
        t3_codcurr        :=  i.codcurr ;
        t1_codempmt       :=  i.codempmt;
        t1_codcomp        :=  i.codcomp;
        t1_codpos         :=  i.codpos;
        t1_codjob         :=  i.codjob;
        t1_numlvl         :=  i.numlvl;
        t1_codbrlc        :=  i.codbrlc;
        t1_codcalen       :=  i.codcalen;
        t1_typpayroll     :=  i.typpayroll;
        t1_typemp         :=  i.typemp;
        t1_numreqst       :=  i.numreqst;
        t1_jobgrade       :=  i.jobgrade;
        t1_codgrpgl       :=  i.codgrpgl;
        t1_flgatten       :=  i.flgatten;
        if v_codnewid  is not null and v_codnewid  <> i.codempid  then
           v_ocodempid := i.codempid;
        else
           v_ocodempid := null;
        end if;

        if v_codnewid is not null then
          begin
            select 'Y' into v_dup
              from temploy1
             where codempid = v_codnewid;
          exception when others then v_dup := 'N';
          end;
        end if;


        v_codcomp := null;
        begin
          select codcomp into v_codcomp
          from   temploy1
          where  codempid = i.codempid;
        exception when others then v_dup := 'N';
        end;
        v_flgcompdif := 'N';
        if hcm_util.get_codcomp_level(i.codcomp,'1') <> hcm_util.get_codcomp_level(v_codcomp,'1') then
          v_flgcompdif := 'Y';
        end if;

        if v_dup = 'N' then
          for j in c_temploy1 loop     -- Exist Old Codempid in temploy1
            t1_codtitle   :=   j.codtitle;
            t1_namfirste  :=   j.namfirste;
            t1_namfirstt  :=   j.namfirstt;
            t1_namfirst3  :=   j.namfirst3;
            t1_namfirst4  :=   j.namfirst4;
            t1_namfirst5  :=   j.namfirst5;
            t1_namlaste   :=   j.namlaste;
            t1_namlastt   :=   j.namlastt;
            t1_namlast3   :=   j.namlast3;
            t1_namlast4   :=   j.namlast4;
            t1_namlast5   :=   j.namlast5;
            t1_namempe    :=   j.namempe;
            t1_namempt    :=   j.namempt;
            t1_namemp3    :=   j.namemp3;
            t1_namemp4    :=   j.namemp4;
            t1_namemp5    :=   j.namemp5;
            t1_codsex     :=   j.codsex;
            t1_dteempdb   :=   j.dteempdb;
            t1_stamarry   :=   j.stamarry;
            t1_dteempmt   :=   j.dteempmt;
            t1_dteefpos   :=   j.dteefpos;
            t1_dteeflvl   :=   j.dteeflvl;
            t1_flgreemp   :=   j.flgreemp;
            t1_qtywkday   :=   j.qtywkday;
            t1_codedlv    :=   j.codedlv;
            t1_codmajsb   :=   j.codmajsb;
            t1_dteoccup   :=   j.dteoccup;
            t1_qtydatrq   :=   j.qtydatrq;
            t1_numappl    :=   j.numappl;
            --t1_flgatten   :=   j.flgatten;
            t1_numtelof   :=   j.numtelof;
            t1_email      :=   j.email;
            t1_ocodempid  :=   j.ocodempid;
            t1_dteredue   :=   j.dteredue;
            t1_dteeffex   :=   j.dteeffex;
            tt_qtywkday   :=   t1_qtywkday;
            t1_dteefstep  :=   j.dteefstep;
            t1_stadisb   	:=   j.stadisb;
            t1_numdisab   :=   j.numdisab;
            t1_typdisp   	:=   j.typdisp;
            t1_dtedisb   	:=   j.dtedisb;
            t1_dtedisen   :=   j.dtedisen;
            t1_desdisp   	:=   j.desdisp;
            t1_dteretire  :=   j.dteretire;

            for r2 in c_temploy2 loop
  --						t2_stamilit     := r2.stamilit  ;
              t2_adrrege      := r2.adrrege   ;
              t2_adrregt      := r2.adrregt   ;
              t2_adrreg3      := r2.adrreg3   ;
              t2_adrreg4      := r2.adrreg4   ;
              t2_adrreg5      := r2.adrreg5   ;
              t2_codsubdistr  := r2.codsubdistr;
              t2_coddistr     := r2.coddistr  ;
              t2_codcntyr     := r2.codcntyr  ;
              t2_codpostr     := r2.codpostr  ;
              t2_adrconte     := r2.adrconte  ;
              t2_adrcontt     := r2.adrcontt  ;
              t2_adrcont3     := r2.adrcont3  ;
              t2_adrcont4     := r2.adrcont4  ;
              t2_adrcont5     := r2.adrcont5  ;
              t2_codsubdistc  := r2.codsubdistc;
              t2_coddistc     := r2.coddistc  ;
              t2_codprovc     := r2.codprovc  ;
              t2_codcntyc     := r2.codcntyc  ;
              t2_codpostc     := r2.codpostc  ;
              t2_numtelec     := r2.numtelec  ;
              t2_codblood     := r2.codblood  ;
              t2_weight       := r2.weight    ;
              t2_high         := r2.high      ;
              t2_codrelgn     := r2.codrelgn  ;
              t2_codorgin     := r2.codorgin  ;
              t2_codnatnl     := r2.codnatnl  ;
              t2_coddomcl     := r2.coddomcl  ;
              t2_numoffid     := r2.numoffid  ;
              t2_adrissue     := r2.adrissue  ;
              t2_codprovi     := r2.codprovi  ;
              t2_codprovr     := r2.codprovr  ;-- user22 : 15/09/2016 : STA3590323 ||
              t2_dteoffid     := r2.dteoffid  ;
              t2_numlicid     := r2.numlicid  ;
              t2_dtelicid     := r2.dtelicid  ;
              t2_numpasid     := r2.numpasid  ;
              t2_dtepasid     := r2.dtepasid  ;
              t2_numprmid     := r2.numprmid  ;
              t2_dteprmst     := r2.dteprmst  ;
              t2_dteprmen     := r2.dteprmen  ;
              for r3 in c_temploy3 loop  -- Exist Old Codempid in temploy3
                t3_numtaxid    := r3.numtaxid;
                t3_numsaid     := r3.numsaid ;
                t3_flgtax      := r3.flgtax  ;
                t3_typtax      := r3.typtax  ;
                t3_codbank     := r3.codbank ;
                t3_numbank     := r3.numbank ;
                t3_amtbank     := r3.amtbank ;
                t3_codbank2    := r3.codbank2;
                t3_numbank2    := r3.numbank2;
                t3_dtebf       := r3.dtebf   ;
                t3_amtincbf    := r3.amtincbf;
                t3_amttaxbf    := r3.amttaxbf;
                t3_amtpf       := r3.amtpf   ;
                t3_amtsaid     := r3.amtsaid ;
                t3_dtebfsp     := r3.dtebfsp ;
                t3_amtincsp    := r3.amtincsp;
                t3_amttaxsp    := r3.amttaxsp;
                t3_amtsasp     := r3.amtsasp ;
                t3_amtpfsp     := r3.amtpfsp ;
                t3_qtychedu    := r3.qtychedu;
                t3_qtychned    := r3.qtychned;
                t3_dteyrrelf   := r3.dteyrrelf;
                t3_dteyrrelt   := r3.dteyrrelt;
                t3_amtrelas    := r3.amtrelas;
                t3_amttaxrel   := r3.amttaxrel;
                t3_numbrnch    := r3.numbrnch;
                t3_numbrnch2   := r3.numbrnch2;
                t3_typincom    := r3.typincom;
                t3_flgslip     := r3.flgslip;

                v_staupd       := 'U';
                v_found        := 'Y';
                if v_codnewid is not null then
                  begin   -- Check Record is Exist temploy1
                    select codempid into t_codempid
                    from   temploy1
                    where  codempid = v_codnewid;
                  exception when no_data_found then v_found := 'N';
                  end;
                end if;
                -- Service Year & Hire Date

                -- ????????????????????????????????????????????????????????????????????????????????????????????? / ???????????????????????????????????????
                if i.flgreemp = '3' then
                  tt_qtywkday   := 0;
                  tt_dteempmt   := i.dtereemp;
                  tt_dteduepr   := i.dteduepr;
                  t1_dteefpos   := i.dtereemp;
                  t1_dteeflvl   := i.dtereemp;
                  t1_dteefstep  := i.dtereemp;

                -- ???????????????????????????????????????????????????????????????????????????????????? / ??????????????????????????????
                elsif i.flgreemp = '1' then
                  tt_qtywkday  := j.qtywkday;
                  tt_dteempmt  := j.dteempmt;
                  tt_dteduepr  := j.dteduepr;
                  if j.codpos <> t1_codpos then
                    t1_dteefpos := i.dtereemp;
                  end if;
                  if j.numlvl <> t1_numlvl then
                    t1_dteeflvl := i.dtereemp;
                  end if;
                  if j.jobgrade <> t1_jobgrade then
                    t1_dteefstep := i.dtereemp;
                  end if;

                -- ???????????????????????????????????????????????????????????????????????????????????? / ????????????????????????????????????????????????????????????????????????
                elsif i.flgreemp = '2' then
                  if t1_dteeffex is not null then
                     tt_qtywkday := (i.dtereemp - t1_dteeffex );
                     tt_qtywkday := (tt_qtywkday + nvl(t1_qtywkday,0));
                  else
                     tt_qtywkday := 0;
                  end if;
                  tt_dteempmt   := j.dteempmt;
                  tt_dteduepr   := j.dteduepr;
                  if j.codpos <> t1_codpos then
                    t1_dteefpos := i.dtereemp;
                  end if;
                  if j.numlvl <> t1_numlvl then
                    t1_dteeflvl := i.dtereemp;
                  end if;
                  if j.jobgrade <> t1_jobgrade then
                    t1_dteefstep := i.dtereemp;
                  end if;
                end if;

                -- Status Employee & Date due & Date Occup.
                if t1_dteduepr is not null then
                  tt_dteoccup := null;
                else
                  if i.flgreemp in ('1','2') then-- user22 : 17/05/2016 : STA3590267 || if i.flgreemp = '2' then -- Continue
                    tt_dteoccup := to_date(to_char(j.dteoccup,'dd/mm/yyyy'),'dd/mm/yyyy');
                  else
                    tt_dteoccup := to_date(to_char(i.dtereemp,'dd/mm/yyyy'),'dd/mm/yyyy');
                  end if;
                end if;
                -- Status Employee & Date due & Date Occup.
                if v_found = 'N' then --and  i.flgconti = 'N' then  -- Exist New Codempid in temploy1
                  insert into temploy1(codempid,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,namempe,namempt,namemp3,namemp4,namemp5,
                                       codsex,dteempdb,stamarry,staemp,dteempmt,codempmt,codcomp,codpos,codjob,numlvl,codbrlc,codcalen,
                                       dteefpos,dteeflvl,flgreemp,qtywkday,
                                       codedlv,codmajsb,numreqst,dteduepr,dteoccup,typpayroll,qtydatrq,
                                       numappl,flgatten,typemp,numtelof,
                                       email,ocodempid,dtereemp,dteredue,
                                       jobgrade,dteefstep,codgrpgl,stadisb,numdisab,typdisp,dtedisb,dtedisen,desdisp,
                                       dteeffex,codcompr,codposre,numreqc,codposc,flgreq,stareq,codappr,dteappr,staappr,remarkap,codreq,dteretire,
                                       nickname,nicknamt,nicknam3,nicknam4,nicknam5,stamilit,nummobile,lineid,typtrav,qtylength,carlicen,typfuel,codbusno,codbusrt,
                                       codcreate,coduser)
                                values(v_codnewid,t1_codtitle,t1_namfirste,t1_namfirstt,t1_namfirst3,t1_namfirst4,t1_namfirst5,t1_namlaste,t1_namlastt,t1_namlast3,t1_namlast4,t1_namlast5,t1_namempe,t1_namempt,t1_namemp3,t1_namemp4,t1_namemp5,
                                       t1_codsex,t1_dteempdb,t1_stamarry,t1_staemp,tt_dteempmt,t1_codempmt,t1_codcomp,t1_codpos,t1_codjob,t1_numlvl,t1_codbrlc,t1_codcalen,
                                       t1_dteefpos,t1_dteeflvl,t1_flgreemp,tt_qtywkday,
                                       t1_codedlv,t1_codmajsb,t1_numreqst,tt_dteduepr,tt_dteoccup,t1_typpayroll,t1_qtydatrq,
                                       t1_numappl,t1_flgatten,t1_typemp,t1_numtelof,
                                       t1_email,v_ocodempid,i.dtereemp,i.dteduepr ,
                                       t1_jobgrade,t1_dteefstep,t1_codgrpgl,t1_stadisb,t1_numdisab,t1_typdisp,t1_dtedisb,t1_dtedisen,t1_desdisp,
                                       null,j.codcompr,j.codposre,j.numreqc,j.codposc,j.flgreq,j.stareq,j.codappr,j.dteappr,j.staappr,j.remarkap,j.codreq,t1_dteretire,
                                       j.nickname,j.nicknamt,j.nicknam3,j.nicknam4,j.nicknam5,j.stamilit,j.nummobile,j.lineid,j.typtrav,j.qtylength,j.carlicen,j.typfuel,j.codbusno,j.codbusrt,
                                       p_coduser,p_coduser);
                  begin
                    select namimage,namsign
                      into v_namimage,v_namsign
                      from tempimge
                     where codempid   = v_ocodempid;
                  exception when no_data_found then
                    v_namimage  := null;
                    v_namsign   := null;
                  end;

                  begin
                    insert into tempimge(codempid,namimage,namsign,coduser,codcreate)
                                        values(v_codnewid,v_namimage,v_namsign,p_coduser,p_coduser);
                  exception when dup_val_on_index then
                       update tempimge
                             set namimage   = v_namimage,
                                   namsign    = v_namsign,
                                  coduser    = p_coduser
                        where codempid   = v_codnewid;
                  end;
                else
                  update  temploy1
                     set  staemp     = t1_staemp,
                          dteempmt   = tt_dteempmt,
                          codempmt   = t1_codempmt,
                          codcomp    = t1_codcomp,
                          codpos     = t1_codpos,
                          codjob     = t1_codjob,
                          numlvl     = t1_numlvl,
                          codbrlc    = t1_codbrlc,
                          codcalen   = t1_codcalen,
                          dteefpos   = t1_dteefpos,
                          dteeflvl   = t1_dteeflvl,
                          qtywkday   = tt_qtywkday,
                          numreqst   = t1_numreqst,
                          dteduepr   = tt_dteduepr,
                          dteoccup   = tt_dteoccup,
                          typpayroll = t1_typpayroll,
                          qtydatrq   = t1_qtydatrq,
                          flgatten   = t1_flgatten,
                          typemp     = t1_typemp,
                          numtelof   = t1_numtelof,
                          email      = t1_email,
                          ocodempid  = v_ocodempid,
                          dtereemp   = i.dtereemp,
                          dteredue   = i.dteduepr,
                          flgreemp   = i.flgreemp,
                          dteeffex   = null,
                          jobgrade   = t1_jobgrade,
                          dteefstep  = t1_dteefstep,
                          codgrpgl   = t1_codgrpgl,
                          stadisb    = t1_stadisb,
                          numdisab   = t1_numdisab,
                          typdisp    = t1_typdisp,
                          dtedisb    = t1_dtedisb,
                          dtedisen   = t1_dtedisen,
                          desdisp    = t1_desdisp,
                          codtitle   = t1_codtitle,
                          namfirste  = t1_namfirste,
                          namfirstt  = t1_namfirstt,
                          namfirst3  = t1_namfirst3,
                          namfirst4  = t1_namfirst4,
                          namfirst5  = t1_namfirst5,
                          namlaste   = t1_namlaste,
                          namlastt   = t1_namlastt,
                          namlast3   = t1_namlast3,
                          namlast4   = t1_namlast4,
                          namlast5   = t1_namlast5,
                          namempe    = t1_namempe,
                          namempt    = t1_namempt,
                          namemp3    = t1_namemp3,
                          namemp4    = t1_namemp4,
                          namemp5    = t1_namemp5,
                          codsex     = t1_codsex,
                          dteempdb   = t1_dteempdb,
                          stamarry   = t1_stamarry,
                          codedlv    = t1_codedlv,
                          codmajsb   = t1_codmajsb,
                          numappl    = t1_numappl,
                          codcompr   = j.codcompr,
                          codposre   = j.codposre,
                          numreqc    = j.numreqc,
                          codposc    = j.codposc,
                          flgreq     = j.flgreq,
                          stareq     = j.stareq,
                          codappr    = j.codappr,
                          dteappr    = j.dteappr,
                          staappr    = j.staappr,
                          remarkap   = j.remarkap,
                          codreq     = j.codreq,
                          dteretire  = t1_dteretire,
                          nickname    = j.nickname,
                          nicknamt    = j.nicknamt,
                          nicknam3    = j.nicknam3,
                          nicknam4    = j.nicknam4,
                          nicknam5    = j.nicknam5,
                          stamilit    = j.stamilit,
                          nummobile   = j.nummobile,
                          lineid      = j.lineid,
                          typtrav     = j.typtrav,
                          qtylength   = j.qtylength,
                          carlicen    = j.carlicen,
                          typfuel     = j.typfuel,
                          codbusno    = j.codbusno,
                          codbusrt    = j.codbusrt,
                          coduser    = p_coduser
                   where  codempid   = v_codempid;
                end if;--v_found = 'N'

                v_found   := 'Y';
                if v_codnewid is not null then
                  begin
                    select codempid into t_codempid
                      from temploy2
                     where codempid = v_codnewid;
                  exception when no_data_found then v_found := 'N';
                  end;
                end if;
                if v_found = 'N' then --and  i.flgconti = 'N' then  -- Exist New Codempid in temploy2
                  insert into temploy2( codempid,--stamilit,
                                        adrrege,adrregt,adrreg3,adrreg4,adrreg5,
                                        codsubdistr,coddistr,codcntyr,codpostr,codprovr,
                                        adrconte,adrcontt,adrcont3,adrcont4,adrcont5,codsubdistc,
                                        coddistc,codprovc,codcntyc,codpostc,numtelec,codblood,
                                        weight,high,codrelgn,codorgin,codnatnl,coddomcl,numoffid,
                                        adrissue,codprovi,dteoffid,
                                        numlicid,dtelicid,numpasid,dtepasid,
                                        numprmid,dteprmst,dteprmen,
                                        codclnsc,numvisa,dtevisaexp,
                                        codcreate,coduser)
                                values( v_codnewid,--t2_stamilit,
                                        t2_adrrege,t2_adrregt,t2_adrreg3,t2_adrreg4,t2_adrreg5,
                                        t2_codsubdistr,t2_coddistr,t2_codcntyr,t2_codpostr,t2_codprovr,
                                        t2_adrconte,t2_adrcontt,t2_adrcont3,t2_adrcont4,t2_adrcont5,t2_codsubdistc,
                                        t2_coddistc,t2_codprovc,t2_codcntyc,t2_codpostc,t2_numtelec,t2_codblood,
                                        t2_weight,t2_high,t2_codrelgn,t2_codorgin,t2_codnatnl,t2_coddomcl,t2_numoffid,
                                        t2_adrissue,t2_codprovi,t2_dteoffid,
                                        t2_numlicid,t2_dtelicid,t2_numpasid,t2_dtepasid,
                                        t2_numprmid,t2_dteprmst,t2_dteprmen,
                                        r2.codclnsc,r2.numvisa,r2.dtevisaexp,
                                        p_coduser,p_coduser);
                else
                  update  temploy2
                     set  --stamilit     =   t2_stamilit,
                          adrrege      =   t2_adrrege,
                          adrregt      =   t2_adrregt,
                          adrreg3      =   t2_adrreg3,
                          adrreg4      =   t2_adrreg4,
                          adrreg5      =   t2_adrreg5,
                          codprovr     =   t2_codprovr,
                          codsubdistr  =   t2_codsubdistr,
                          coddistr     =   t2_coddistr,
                          codcntyr     =   t2_codcntyr,
                          codpostr     =   t2_codpostr,
                          adrconte     =   t2_adrconte,
                          adrcontt     =   t2_adrcontt,
                          adrcont3     =   t2_adrcont3,
                          adrcont4     =   t2_adrcont4,
                          adrcont5     =   t2_adrcont5,
                          codsubdistc  =   t2_codsubdistc,
                          coddistc     =   t2_coddistc,
                          codprovc     =   t2_codprovc,
                          codcntyc     =   t2_codcntyc,
                          codpostc     =   t2_codpostc,
                          numtelec     =   t2_numtelec,
                          codblood     =   t2_codblood,
                          weight       =   t2_weight,
                          high         =   t2_high,
                          codrelgn     =   t2_codrelgn,
                          codorgin     =   t2_codorgin,
                          codnatnl     =   t2_codnatnl,
                          coddomcl     =   t2_coddomcl,
                          numoffid     =   t2_numoffid,
                          adrissue     =   t2_adrissue,
                          codprovi     =   t2_codprovi,
                          dteoffid     =   t2_dteoffid,
                          numlicid     =   t2_numlicid,
                          dtelicid     =   t2_dtelicid,
                          numpasid     =   t2_numpasid,
                          dtepasid     =   t2_dtepasid,
                          numprmid     =   t2_numprmid,
                          dteprmst     =   t2_dteprmst,
                          dteprmen     =   t2_dteprmen,
                          codclnsc     =   r2.codclnsc,
                          numvisa      =   r2.numvisa,
                          dtevisaexp   =   r2.dtevisaexp,
                          coduser      =   p_coduser
                    where codempid     =   v_codempid;
                end if;--v_found = 'N'

                v_found := 'Y';
                if  v_codnewid is not null  then
                     begin
                       select codempid into t_codempid
                         from temploy3
                        where codempid = v_codnewid;
                     exception when no_data_found then v_found := 'N';
                     end;
                end if;

                -- Decrypt
                t3_amtincom1 := stddec(t3_amtincom1,v_codempid,v_chken);
                t3_amtincom2 := stddec(t3_amtincom2,v_codempid,v_chken);
                t3_amtincom3 := stddec(t3_amtincom3,v_codempid,v_chken);
                t3_amtincom4 := stddec(t3_amtincom4,v_codempid,v_chken);
                t3_amtincom5 := stddec(t3_amtincom5,v_codempid,v_chken);
                t3_amtincom6 := stddec(t3_amtincom6,v_codempid,v_chken);
                t3_amtincom7 := stddec(t3_amtincom7,v_codempid,v_chken);
                t3_amtincom8 := stddec(t3_amtincom8,v_codempid,v_chken);
                t3_amtincom9 := stddec(t3_amtincom9,v_codempid,v_chken);
                t3_amtincom10:= stddec(t3_amtincom10,v_codempid,v_chken);

                get_wage_income(hcm_util.get_codcomp_level(t1_codcomp,'1'),t1_codempmt,
                                         t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10,
                                         v_amtothr,v_amtotday,v_amtotmth);

                v_amtothr    := round(v_amtothr,2);
                v_amtotday   := round(v_amtotday,2);
                v_amtotmth   := round(v_amtotmth,2);
                t3_amtothr   := v_amtothr;
                t3_amtday    := v_amtotday;

                t3_amtincbf  := stddec(t3_amtincbf,v_codempid,v_chken);
                t3_amttaxbf  := stddec(t3_amttaxbf,v_codempid,v_chken);
                t3_amtpf     := stddec(t3_amtpf,v_codempid,v_chken);
                t3_amtsaid   := stddec(t3_amtsaid,v_codempid,v_chken);
                t3_amtincsp  := stddec(t3_amtincsp,v_codempid,v_chken);
                t3_amttaxsp  := stddec(t3_amttaxsp,v_codempid,v_chken);
                t3_amtsasp   := stddec(t3_amtsasp,v_codempid,v_chken);
                t3_amtpfsp   := stddec(t3_amtpfsp,v_codempid,v_chken);
                t3_amtrelas  := stddec(t3_amtrelas,v_codempid,v_chken);
                t3_amttaxrel := stddec(t3_amttaxrel,v_codempid,v_chken);
                t3_amtproadj  := stddec(t3_amtproadj,v_codempid,v_chken);
                t3_amttranb   := stddec(t3_amttranb,v_codempid,v_chken);

                -- Encrypt
                if  v_codnewid is not null and v_codnewid <> v_codempid then
                       x_codempid := v_codnewid;
                else
                       x_codempid := v_codempid;
                end if;
                t3_amtincom1 := stdenc(t3_amtincom1,x_codempid,v_chken);
                t3_amtincom2 := stdenc(t3_amtincom2,x_codempid,v_chken);
                t3_amtincom3 := stdenc(t3_amtincom3,x_codempid,v_chken);
                t3_amtincom4 := stdenc(t3_amtincom4,x_codempid,v_chken);
                t3_amtincom5 := stdenc(t3_amtincom5,x_codempid,v_chken);
                t3_amtincom6 := stdenc(t3_amtincom6,x_codempid,v_chken);
                t3_amtincom7 := stdenc(t3_amtincom7,x_codempid,v_chken);
                t3_amtincom8 := stdenc(t3_amtincom8,x_codempid,v_chken);
                t3_amtincom9 := stdenc(t3_amtincom9,x_codempid,v_chken);
                t3_amtincom10:= stdenc(t3_amtincom10,x_codempid,v_chken);
                t3_amtothr   := stdenc(t3_amtothr,x_codempid,v_chken);
                t3_amtday    := stdenc(t3_amtday,x_codempid,v_chken);

                t3_amtincbf  := stdenc(t3_amtincbf,x_codempid,v_chken);
                t3_amttaxbf  := stdenc(t3_amttaxbf,x_codempid,v_chken);
                t3_amtpf     := stdenc(t3_amtpf,x_codempid,v_chken);
                t3_amtsaid   := stdenc(t3_amtsaid,x_codempid,v_chken);
                t3_amtincsp  := stdenc(t3_amtincsp,x_codempid,v_chken);
                t3_amttaxsp  := stdenc(t3_amttaxsp,x_codempid,v_chken);
                t3_amtsasp   := stdenc(t3_amtsasp,x_codempid,v_chken);
                t3_amtpfsp   := stdenc(t3_amtpfsp,x_codempid,v_chken);

                t3_amtrelas  := stdenc(t3_amtrelas,x_codempid,v_chken);
                t3_amttaxrel := stdenc(t3_amttaxrel,x_codempid,v_chken);
                t3_amtproadj  := stdenc(t3_amtproadj,x_codempid,v_chken);
                t3_amttranb   := stdenc(t3_amttranb,x_codempid,v_chken);
                /*if v_codnewid is not null and v_codnewid <> v_codempid then
                  -- Decrypt
                  t3_amtincom1 := stddec(t3_amtincom1,v_codempid,v_chken);
                  t3_amtincom2 := stddec(t3_amtincom2,v_codempid,v_chken);
                  t3_amtincom3 := stddec(t3_amtincom3,v_codempid,v_chken);
                  t3_amtincom4 := stddec(t3_amtincom4,v_codempid,v_chken);
                  t3_amtincom5 := stddec(t3_amtincom5,v_codempid,v_chken);
                  t3_amtincom6 := stddec(t3_amtincom6,v_codempid,v_chken);
                  t3_amtincom7 := stddec(t3_amtincom7,v_codempid,v_chken);
                  t3_amtincom8 := stddec(t3_amtincom8,v_codempid,v_chken);
                  t3_amtincom9 := stddec(t3_amtincom9,v_codempid,v_chken);
                  t3_amtincom10:= stddec(t3_amtincom10,v_codempid,v_chken);

                  get_wage_income(hcm_util.get_codcomp_level(t1_codcomp,'1'),t1_codempmt,
                                  t3_amtincom1, t3_amtincom2,t3_amtincom3, t3_amtincom4,t3_amtincom5, t3_amtincom6,t3_amtincom7, t3_amtincom8,t3_amtincom9, t3_amtincom10,
                                  v_amtothr, v_amtotday, v_amtotmth);

                  v_amtothr    := round(v_amtothr,2);
                  v_amtotday   := round(v_amtotday,2);
                  v_amtotmth   := round(v_amtotmth,2);
                  t3_amtothr   := v_amtothr;
                  t3_amtday    := v_amtotday;

                  t3_amtincbf  := stddec(t3_amtincbf,v_codempid,v_chken);
                  t3_amttaxbf  := stddec(t3_amttaxbf,v_codempid,v_chken);
                  t3_amtpf     := stddec(t3_amtpf,v_codempid,v_chken);
                  t3_amtsaid   := stddec(t3_amtsaid,v_codempid,v_chken);
                  t3_amtincsp  := stddec(t3_amtincsp,v_codempid,v_chken);

                  t3_amttaxsp  := stddec(t3_amttaxsp,v_codempid,v_chken);
                  t3_amtsasp   := stddec(t3_amtsasp,v_codempid,v_chken);
                  t3_amtpfsp   := stddec(t3_amtpfsp,v_codempid,v_chken);

                  -- Encrypt
                  t3_amtincom1 := stdenc(t3_amtincom1,v_codnewid,v_chken);
                  t3_amtincom2 := stdenc(t3_amtincom2,v_codnewid,v_chken);
                  t3_amtincom3 := stdenc(t3_amtincom3,v_codnewid,v_chken);
                  t3_amtincom4 := stdenc(t3_amtincom4,v_codnewid,v_chken);
                  t3_amtincom5 := stdenc(t3_amtincom5,v_codnewid,v_chken);
                  t3_amtincom6 := stdenc(t3_amtincom6,v_codnewid,v_chken);
                  t3_amtincom7 := stdenc(t3_amtincom7,v_codnewid,v_chken);
                  t3_amtincom8 := stdenc(t3_amtincom8,v_codnewid,v_chken);

                  t3_amtincom9 := stdenc(t3_amtincom9,v_codnewid,v_chken);
                  t3_amtincom10:= stdenc(t3_amtincom10,v_codnewid,v_chken);
                  t3_amtothr   := stdenc(t3_amtothr,v_codnewid,v_chken);
                  t3_amtday    := stdenc(t3_amtday,v_codnewid,v_chken);

                  t3_amtincbf  := stdenc(t3_amtincbf,v_codnewid,v_chken);
                  t3_amttaxbf  := stdenc(t3_amttaxbf,v_codnewid,v_chken);
                  t3_amtpf     := stdenc(t3_amtpf,v_codnewid,v_chken);
                  t3_amtsaid   := stdenc(t3_amtsaid,v_codnewid,v_chken);
                  t3_amtincsp  := stdenc(t3_amtincsp,v_codnewid,v_chken);
                  t3_amttaxsp  := stdenc(t3_amttaxsp,v_codnewid,v_chken);
                  t3_amtsasp   := stdenc(t3_amtsasp,v_codnewid,v_chken);
                  t3_amtpfsp   := stdenc(t3_amtpfsp,v_codnewid,v_chken);
                end if;*/--v_codnewid is not null and v_codnewid <> v_codempid
  -->> user22 : 09/05/2016 : STA3590263 ||

                if v_found = 'N' then --and  i.flgconti = 'N' then  -- Exist New Codempid in temploy3
                  insert into temploy3(codempid,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                        numtaxid,numsaid,flgtax,typtax,codbank,
                                        numbank,amtbank,codbank2,numbank2,amtothr,
                                        amtday,dtebf,amtincbf,amttaxbf,amtpf,
                                        amtsaid,dtebfsp,amtincsp,amttaxsp,amtsasp,
                                        amtpfsp,qtychedu,qtychned,
                                        dteyrrelf,dteyrrelt,amtrelas,amttaxrel,numbrnch,numbrnch2,
                                        amtproadj,typincom,amttranb,flgslip,
                                        codcreate,coduser)
                                 values(v_codnewid,t3_codcurr,t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10,
                                        t3_numtaxid,t3_numsaid,t3_flgtax,t3_typtax,t3_codbank,
                                        t3_numbank,t3_amtbank,t3_codbank2,t3_numbank2,t3_amtothr,
                                        t3_amtday,t3_dtebf,t3_amtincbf,t3_amttaxbf,t3_amtpf,
                                        t3_amtsaid,t3_dtebfsp,t3_amtincsp,t3_amttaxsp,t3_amtsasp,
                                        t3_amtpfsp,t3_qtychedu,t3_qtychned,
                                        t3_dteyrrelf,t3_dteyrrelt,t3_amtrelas,t3_amttaxrel,t3_numbrnch,t3_numbrnch2,
                                        t3_amtproadj,t3_typincom,t3_amttranb,t3_flgslip,
                                        p_coduser , p_coduser);
                else--Update data to table 'TEMPLOY3'
                  update temploy3
                     set codcurr    =  t3_codcurr ,
                          amtincom1  =  t3_amtincom1,
                          amtincom2  =  t3_amtincom2 ,
                          amtincom3  =  t3_amtincom3,
                          amtincom4  =  t3_amtincom4,

                          amtincom5  =  t3_amtincom5,
                          amtincom6  =  t3_amtincom6,
                          amtincom7  =  t3_amtincom7,
                          amtincom8  =  t3_amtincom8,
                          amtincom9  =  t3_amtincom9,
                          amtincom10 =  t3_amtincom10,
                          numtaxid   =  t3_numtaxid ,
                          numsaid    =  t3_numsaid  ,
                          flgtax     =  t3_flgtax   ,
                          typtax     =  t3_typtax   ,
                          codbank    =  t3_codbank   ,
                          numbank    =  t3_numbank  ,
                          amtbank    =  t3_amtbank  ,
                          codbank2   =  t3_codbank2 ,
                          numbank2   =  t3_numbank2 ,
                          amtothr    =  t3_amtothr  ,
                          amtday     =  t3_amtday   ,
                          dtebf      =  t3_dtebf    ,
                          amtincbf   =  t3_amtincbf ,
                          amttaxbf   =  t3_amttaxbf ,
                          amtpf      =  t3_amtpf    ,
                          amtsaid    =  t3_amtsaid  ,
                          dtebfsp    =  t3_dtebfsp  ,
                          amtincsp   =  t3_amtincsp ,
                          amttaxsp   =  t3_amttaxsp ,
                          amtsasp    =  t3_amtsasp  ,
                          amtpfsp    =  t3_amtpfsp  ,
                          qtychedu   =  t3_qtychedu ,
                          qtychned   =  t3_qtychned ,
                          dteyrrelf  =  t3_dteyrrelf,
                          dteyrrelt  =  t3_dteyrrelt,
                          amtrelas   =  t3_amtrelas,
                          amttaxrel  =  t3_amttaxrel,
                          numbrnch   =  t3_numbrnch,
                          numbrnch2  =  t3_numbrnch2,
                          amtproadj  =  t3_amtproadj,
                          typincom   =  t3_typincom,
                          amttranb   =  t3_amttranb,
                          flgslip    =  t3_flgslip,
                          coduser    =  p_coduser
                    where codempid = v_codempid;
                end if;--v_found = 'N'

                if v_codnewid is not null and i.flgreemp in ('1','2') then
                  -- Children
                  for tc in c_tchildrn loop
                    v_found   := 'Y';
                    begin
                      select codempid into t_codempid
                        from tchildrn
                       where tchildrn.codempid = v_codnewid
                         and tchildrn.numseq   = tc.numseq;
                    exception when no_data_found then v_found := 'N';
                    end;
                    if v_found = 'N' then
                      insert into tchildrn(codempid,numseq,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                           namlaste,namlastt,namlast3,namlast4,namlast5,namche,namcht,namch3,namch4,namch5,
                                           numoffid,dtechbd,codsex,codedlv,stachld,stalife,dtedthch,flginc,flgedlv,flgdeduct,
                                           stabf,filename,numrefdoc,codcreate,coduser)
                                    values( v_codnewid,tc.numseq,tc.codtitle,tc.namfirste,tc.namfirstt,tc.namfirst3,tc.namfirst4,tc.namfirst5,
                                            tc.namlaste,tc.namlastt,tc.namlast3,tc.namlast4,tc.namlast5,tc.namche,tc.namcht,tc.namch3,tc.namch4,tc.namch5,
                                            tc.numoffid,tc.dtechbd,tc.codsex,tc.codedlv,tc.stachld,tc.stalife,tc.dtedthch,tc.flginc,tc.flgedlv,tc.flgdeduct,
                                            tc.stabf,tc.filename,tc.numrefdoc,p_coduser,p_coduser);
                    end if;
                  end loop;

                  -- Spouse
                  for tu in c_tspouse loop
                       v_found := 'Y';
                       begin
                         select codempid into t_codempid
                           from tspouse
                          where tspouse.codempid = v_codnewid;
                       exception when no_data_found then v_found := 'N';
                       end;

                       if v_found = 'N' then
                         insert into tspouse(codempid,codempidsp,namimgsp,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                             namlaste,namlastt,namlast3,namlast4,namlast5,namspe,namspt,namsp3,namsp4,namsp5,numoffid,
                                             numtaxid,codspocc,dtespbd,stalife,staincom,dtedthsp,desnoffi,numfasp,nummosp,dtemarry,
                                             codsppro,codspcty,desplreg,desnote,filename,numrefdoc,
                                             codcreate,coduser)
                                      values(v_codnewid,tu.codempidsp,tu.namimgsp,tu.codtitle,tu.namfirste,tu.namfirstt,tu.namfirst3,tu.namfirst4,tu.namfirst5,
                                              tu.namlaste,tu.namlastt,tu.namlast3,tu.namlast4,tu.namlast5,tu.namspe,tu.namspt,tu.namsp3,tu.namsp4,tu.namsp5,tu.numoffid,
                                              tu.numtaxid,tu.codspocc,tu.dtespbd,tu.stalife,tu.staincom,tu.dtedthsp,tu.desnoffi,tu.numfasp,tu.nummosp,tu.dtemarry,
                                              tu.codsppro,tu.codspcty,tu.desplreg,tu.desnote,tu.filename,tu.numrefdoc,
                                              p_coduser,p_coduser);
                       end if;
                  end loop; --for tu in c_tspouse loop

                  -- Family
                  for tf in c_tfamily loop
                    v_found   := 'Y';
                    begin
                      select codempid into t_codempid
                        from tfamily
                       where tfamily.codempid = v_codnewid;
                    exception when no_data_found then v_found := 'N';
                    end;
                    if v_found = 'N' then
                            insert into tfamily(codempid,codempfa,codtitlf,namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
                                                namlstfe,namlstft,namlstf3,namlstf4,namlstf5,namfathe,namfatht,namfath3,
                                                namfath4,namfath5,numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,staliff,
                                                dtedeathf,filenamf,numrefdocf,codempmo,codtitlm,namfstme,namfstmt,namfstm3,
                                                namfstm4,namfstm5,namlstme,namlstmt,namlstm3,namlstm4,namlstm5,nammothe,
                                                nammotht,nammoth3,nammoth4,nammoth5,numofidm,dtebdmo,codmnatn,codmrelg,
                                                codmoccu,stalifm,dtedeathm,filenamm,numrefdocm,codtitlc,namfstce,namfstct,
                                                namfstc3,namfstc4,namfstc5,namlstce,namlstct,namlstc3,namlstc4,namlstc5,
                                                namconte,namcontt,namcont3,namcont4,namcont5,adrcont1,codpost,numtele,
                                                numfax,email,desrelat,
                                                codcreate,coduser)
                                        values(v_codnewid,tf.codempfa,tf.codtitlf,tf.namfstfe,tf.namfstft,tf.namfstf3,tf.namfstf4,tf.namfstf5,
                                               tf.namlstfe,tf.namlstft,tf.namlstf3,tf.namlstf4,tf.namlstf5,tf.namfathe,tf.namfatht,tf.namfath3,
                                               tf.namfath4,tf.namfath5,tf.numofidf,tf.dtebdfa,tf.codfnatn,tf.codfrelg,tf.codfoccu,tf.staliff,
                                               tf.dtedeathf,tf.filenamf,tf.numrefdocf,tf.codempmo,tf.codtitlm,tf.namfstme,tf.namfstmt,tf.namfstm3,
                                               tf.namfstm4,tf.namfstm5,tf.namlstme,tf.namlstmt,tf.namlstm3,tf.namlstm4,tf.namlstm5,tf.nammothe,
                                               tf.nammotht,tf.nammoth3,tf.nammoth4,tf.nammoth5,tf.numofidm,tf.dtebdmo,tf.codmnatn,tf.codmrelg,
                                               tf.codmoccu,tf.stalifm,tf.dtedeathm,tf.filenamm,tf.numrefdocm,tf.codtitlc,tf.namfstce,tf.namfstct,
                                               tf.namfstc3,tf.namfstc4,tf.namfstc5,tf.namlstce,tf.namlstct,tf.namlstc3,tf.namlstc4,tf.namlstc5,
                                               tf.namconte,tf.namcontt,tf.namcont3,tf.namcont4,tf.namcont5,tf.adrcont1,tf.codpost,tf.numtele,
                                               tf.numfax,tf.email,tf.desrelat,
                                               p_coduser,p_coduser);
                    end if;
                  end loop;
                  -- Family trelatives
                  for tr in c_trelatives loop
                    v_found   := 'Y';
                    begin
                      select codempid into t_codempid
                        from trelatives
                       where codempid = v_codnewid
                       fetch first row only;
                    exception when no_data_found then v_found := 'N';
                    end;
                    if v_found = 'N' then
                      insert into trelatives(codempid,numseq,codemprl,namrele,namrelt,namrel3,namrel4,namrel5,
                                            numtelec,adrcomt,codcreate,coduser)
                                  values(v_codnewid,tr.numseq,tr.codemprl,tr.namrele,tr.namrelt,tr.namrel3,tr.namrel4,tr.namrel5,
                                         tr.numtelec,tr.adrcomt,p_coduser,p_coduser);
                    end if;
                  end loop;
                end if;--v_codnewid is not null and  i.flgconti = 'N'


                -- Check ttrehire.numreqst for Update 'TREQEST1/TREQEST2'
                if i.numreqst is not null and i.numreqst <> ' ' then
                        begin
                            --select totqtyact,totreq,stareq into t_totqtyact,t_totreq,t_stareq
                             select stareq into t_stareq
                              from treqest1
                            where numreqst = i.numreqst;
                        exception when no_data_found then t_stareq := 'E';
                        end;

                        begin
                            select sum(nvl(qtyact,0)) , sum(nvl(qtyreq,0))
                               into t_totqtyact,t_totreq
                              from treqest2
                            where numreqst = i.numreqst;
                        exception when no_data_found then
                               t_totqtyact        := 0;
                               t_totreq            := 0;
                        end;

                        if t_stareq <> 'E' then
                          t_totqtyact := nvl(t_totqtyact,0) + 1;

                          if t_totqtyact >= t_totreq then
                             t_stareq  := 'C';  -- C-Closed
                          end if;
                          begin
                            update treqest1
                               set
                                 --totqtyact = t_totqtyact,
                                   stareq    = t_stareq,
                                   coduser   = p_coduser
                             where numreqst = i.numreqst;
                          end;
                          t_stareq := 'Y';
                          begin
                            select qtyact into t_qtyact
                              from treqest2
                             where treqest2.numreqst = i.numreqst
                               and treqest2.codpos   = i.codpos;
                          exception when no_data_found then t_stareq := 'N';
                          end;

                          if t_stareq = 'Y' then
                                  t_qtyact := nvl(t_qtyact,0) + 1;
                                  begin
                                          update treqest2
                                                set qtyact  = t_qtyact,
                                                      coduser = p_coduser
                                           where numreqst = i.numreqst
                                               and codpos   = i.codpos;
                                  end;
                          end if;--if t_stareq = 'Y' then
                        end if;  --t_stareq <> 'E'
                end if;  --if i.numreqst is not null and i.numreqst <> ' '2

                begin -- Select for NUMSEQ
                     select max(numseq) into v_numseq
                       from thismove
                     where codempid   = v_codempid
                         and dteeffec   = v_dtereemp;
                exception when no_data_found then
                  v_numseq := 0;
                end;
                v_numseq  :=  nvl(v_numseq,0) + 1;
                -- create data to table 'THISMOVE'
                insert into thismove(codempid,dteeffec,numseq,codtrn,codcomp,
                                     codpos,codjob,codbrlc,codempmt,numlvl,typemp,typpayroll,
                                     staemp,qtydatrq,dteduepr,flginput,flgadjin,desnote,
                                     amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                     amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                     codcalen,numreqst,typmove,dteempmt,
                                     codcurr, jobgrade,codgrpgl,
                                     codcreate ,coduser
                                     )
                              values(nvl(v_codnewid,v_codempid),v_dtereemp,v_numseq,v_codtrn,t1_codcomp,
                                      t1_codpos,t1_codjob,t1_codbrlc,t1_codempmt,t1_numlvl,t1_typemp,t1_typpayroll,
                                      tt_staemp,t1_qtydatrq,tt_dteduepr,'N','Y',v_desnote,
                                      t3_amtincom1,t3_amtincom2,t3_amtincom3,t3_amtincom4,t3_amtincom5,
                                      t3_amtincom6,t3_amtincom7,t3_amtincom8,t3_amtincom9,t3_amtincom10,
                                      t1_codcalen,t1_numreqst,v_typmove,tt_dteempmt,
                                      t3_codcurr, t1_jobgrade,t1_codgrpgl,
                                      p_coduser , p_coduser);
              end loop;  --for k3 in c_temploy3 loop
            end loop;  --for k2 in c_temploy2 loop
          end loop;  --for j in c_temploy1 loop
        end if;-- v_dup = 'N'

        -- Update STAUPD To 'ttrehire'
        begin
          update ttrehire
             set staupd     = v_staupd,
                 coduser    = p_coduser
           where codempid   = v_codempid
             and dtereemp   = v_dtereemp;
        end;

        if v_staupd <> 'C' then
                v_sum    :=  v_sum + 1;
                if i.codnewid is not null and i.flgreemp in ('1','2') then-- user22 : 17/05/2016 : STA3590267 || if i.codnewid is not null and i.flgconti = 'Y' then
                  replace_codempid(i.codempid,i.codnewid,v_flgcompdif);-- user22 : 10/08/2016 : STA3590307 || replace_codempid(i.codempid,i.codnewid);
        --<< user22 : 17/05/2016 : STA3590267 ||
                  if to_char(i.dtereemp,'yyyy') = to_char(t1_dteeffex,'yyyy') then
                    for tu in c_tempded loop
                      v_found := 'Y';
                      begin
                        select codempid into t_codempid
                          from tempded
                         where codempid  = i.codnewid
                           and coddeduct = tu.coddeduct;
                      exception when no_data_found then v_found := 'N';
                      end;
                      if v_found = 'N' then
                        insert into tempded(codempid,coddeduct,amtdeduct,amtspded,
                                                     codcreate,coduser)
                                     values(i.codnewid,tu.coddeduct,
                                            stdenc(stddec(tu.amtdeduct,tu.codempid,v_chken),i.codnewid,v_chken),
                                            stdenc(stddec(tu.amtspded,tu.codempid,v_chken),i.codnewid,v_chken),
                                            p_coduser,p_coduser);
                      end if;
                    end loop;--c_tempded
            else
              begin
                select value into v_chkreg
                  from v$nls_parameters
                 where parameter = 'NLS_CALENDAR';

                if v_chkreg = 'Thai Buddha' then
                  v_zyear := 543;
                else
                  v_zyear := 0;
                end if;
              exception when others then v_zyear := 0;
              end;
              for tu in c_tdeductd loop
                v_found := 'Y';
                begin
                  select codempid into t_codempid
                    from tempded
                   where codempid  = i.codnewid
                     and coddeduct = tu.coddeduct;
                exception when no_data_found then v_found := 'N';
                end;
                if v_found = 'N' then
                  if tu.flgdef = 'Y' then
                    v_amtdeduct := tu.amtdemax;
                  else
                    v_amtdeduct := 0;
                  end if;
                  insert into tempded(codempid,coddeduct,amtdeduct,amtspded,
                              codcreate,coduser)
                               values(i.codnewid,tu.coddeduct,
                                      stdenc(v_amtdeduct,i.codnewid,v_chken),
                                      stdenc(0,i.codnewid,v_chken),p_coduser,p_coduser);
                end if;
              end loop;--c_tdeductd
            end if;--to_char(i.dtereemp,'yyyy') = to_char(t1_dteeffex,'yyyy')
          end if;

          --<<user36 10/05/2022  j.codpos <> t1_codpos ,where by v_codempid
          v_codempidrehire := nvl(i.codnewid,i.codempid); --user36 10/05/2022
          for j in c_temploy1 loop
            if (j.jobgrade <> t1_jobgrade) or (j.codcomp <> t1_codcomp) or
               (j.codpos   <> t1_codpos)   or (j.codjob  <> t1_codjob) or
               (j.codbrlc  <> t1_codbrlc)  or (j.numlvl  <> t1_numlvl) or
               (j.codempmt <> t1_codempmt) or (j.typemp  <> t1_typemp)
               then
              global_v_coduser := p_coduser;
              ins_tusrprof(v_codempidrehire);

              v_user := v_user + 1;
            end if;
          end loop;
          -->>user36 10/05/2022
        else
          update ttrehire
                set staupd    = 'P',
                      coduser   = p_coduser
           where codempid  = v_codempid
               and dtereemp  = v_dtereemp;

          v_err   :=  v_err + 1;
          if i.flgmove = 'R' then
            ins_errtmp(i.codempid,i.codcomp,i.codpos,'HR2055','TEMPLOY3',v_topic2,p_coduser);

                      -- insert batch process detail
                      hcm_batchtask.insert_batch_detail(
                        p_codapp   => global_v_batch_codapp,
                        p_coduser  => p_coduser,
                        p_codalw   => global_v_batch_codapp||'3',
                        p_dtestrt  => p_dtetim,
                        p_item01  => i.codempid,
                        p_item02  => i.codcomp,
                        p_item03  => i.codpos,
                        p_item04  => 'HR2055',
                        p_item05  => 'TEMPLOY3',
                        p_item06  => v_topic2,
                        p_item07  => p_coduser
                      );
          else
            ins_errtmp(i.codempid,i.codcomp,i.codpos,'HR2055','TEMPLOY3',v_topic3,p_coduser);

                      -- insert batch process detail
                      hcm_batchtask.insert_batch_detail(
                        p_codapp   => global_v_batch_codapp,
                        p_coduser  => p_coduser,
                        p_codalw   => global_v_batch_codapp||'5',
                        p_dtestrt  => p_dtetim,
                        p_item01  => i.codempid,
                        p_item02  => i.codcomp,
                        p_item03  => i.codpos,
                        p_item04  => 'HR2055',
                        p_item05  => 'TEMPLOY3',
                        p_item06  => v_topic3,
                        p_item07  => p_coduser
                      );
          end if;
        end if;--v_staupd <> 'C'
      end if; --if v_secu then
      commit;
    end loop; --for i in c_ttrehire loop
    o_sum       := v_sum;
    o_err       := v_err;
    o_user      := v_user;
    o_erruser   := v_erruser;
  end;
  ---------------------
  procedure replace_codempid(p_codempid in varchar2,p_codnewid in varchar2,p_flgcompdif in varchar2) is

    v_table_name varchar2(20 char):= '#$%^';
    v_statment   varchar2(2000 char);
    v_statment2  varchar2(2000 char);
    v_comma      varchar2(10 char) := null;
    x            number;
    y            number;

    cursor c1 is
      select distinct table_name,column_name
        from user_tab_columns
       where table_name  like 'T%'
         and table_name  not in ('TEMPLOY1','TEMPLOY2','TEMPLOY3','TTREHIRE','TTPMINF','TPFMEMB','TUSRPROF','TPFICINF','TPFMEMRT','TPFMEMRT2','TINSRER','TBFICINF','TCHGINS1','TCHGINS2','TCHGINS3',
                                 'TEMPDED',-- user22 : 17/05/2016 : STA3590267 ||
                                 'TCHILDRN','TSPOUSE','TFAMILY','TRELATIVES',-- user22 : 23/08/2016 : STA3590307 ||
                                 'TTEXEMPT' )--user19 STD 10.4 New Error #4705
         and data_type   = 'VARCHAR2'
         and char_length = 10
         and column_name like 'COD%'
         and column_name not in ('CODUSER','CODINST','CODAPP','CODREP','CODPOS','CODCHG')
    order by table_name,column_name;
  begin

    if p_codempid <> p_codnewid then
--update tapbonus  set amtnbon = stdenc(stddec(amtnbon,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
--update tappayvac set amtlepay = stdenc(stddec(amtlepay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtmidsal = stdenc(stddec(amtmidsal,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtsal = stdenc(stddec(amtsal,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtbudg = stdenc(stddec(amtbudg,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtsaln = stdenc(stddec(amtsaln,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tapprais  set amtceiling = stdenc(stddec(amtceiling,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtminsal = stdenc(stddec(amtminsal,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtover = stdenc(stddec(amtover,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tapprais  set amtlums = stdenc(stddec(amtlums,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      --update tappraisa set amtsinc = stdenc(stddec(amtsinc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tappraisa set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tattence  set amtwork = stdenc(stddec(amtwork,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --phase 2 update tbonus    set amtsalcr = stdenc(stddec(amtsalcr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tbonus    set amtbon = stdenc(stddec(amtbon,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tbonus    set amtadjbo = stdenc(stddec(amtadjbo,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tbonus    set amtnbon = stdenc(stddec(amtnbon,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tcertifc  set amtsalt = stdenc(stddec(amtsalt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcertifc  set amtotht = stdenc(stddec(amtotht,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtsvr = stdenc(stddec(amtsvr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtothcps = stdenc(stddec(amtothcps,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtexctax = stdenc(stddec(amtexctax,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtprovf = stdenc(stddec(amtprovf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtexpnse = stdenc(stddec(amtexpnse,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amttaxcps = stdenc(stddec(amttaxcps,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amttaxpf = stdenc(stddec(amttaxpf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtavgsal = stdenc(stddec(amtavgsal,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tcompstn  set amtsalary = stdenc(stddec(amtsalary,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tempdech  set amtdeduct = stdenc(stddec(amtdeduct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tempdech  set amtspded = stdenc(stddec(amtspded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      -- user22 : 17/05/2016 : STA3590267 || update tempded   set amtdeduct = stdenc(stddec(amtdeduct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      -- user22 : 17/05/2016 : STA3590267 || update tempded   set amtspded = stdenc(stddec(amtspded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tempinc   set amtfix = stdenc(stddec(amtfix,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco1 = stdenc(stddec(amtinco1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco2 = stdenc(stddec(amtinco2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco3 = stdenc(stddec(amtinco3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco4 = stdenc(stddec(amtinco4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco5 = stdenc(stddec(amtinco5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco6 = stdenc(stddec(amtinco6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco7 = stdenc(stddec(amtinco7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco8 = stdenc(stddec(amtinco8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco9 = stdenc(stddec(amtinco9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtinco10 = stdenc(stddec(amtinco10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tfincadj  set amtincn1 = stdenc(stddec(amtincn1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn2 = stdenc(stddec(amtincn2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn3 = stdenc(stddec(amtincn3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn4 = stdenc(stddec(amtincn4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn5 = stdenc(stddec(amtincn5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn6 = stdenc(stddec(amtincn6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn7 = stdenc(stddec(amtincn7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn8 = stdenc(stddec(amtincn8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn9 = stdenc(stddec(amtincn9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tfincadj  set amtincn10 = stdenc(stddec(amtincn10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tguarntr  set amtmthin = stdenc(stddec(amtmthin,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update thismove  set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj1 = stdenc(stddec(amtincadj1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj2 = stdenc(stddec(amtincadj2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj3 = stdenc(stddec(amtincadj3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj4 = stdenc(stddec(amtincadj4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj5 = stdenc(stddec(amtincadj5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update thismove  set amtincadj6 = stdenc(stddec(amtincadj6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj7 = stdenc(stddec(amtincadj7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj8 = stdenc(stddec(amtincadj8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj9 = stdenc(stddec(amtincadj9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thismove  set amtincadj10 = stdenc(stddec(amtincadj10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update thispund  set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded1 = stdenc(stddec(amtincded1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded2 = stdenc(stddec(amtincded2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded3 = stdenc(stddec(amtincded3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded4 = stdenc(stddec(amtincded4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded5 = stdenc(stddec(amtincded5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded6 = stdenc(stddec(amtincded6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded7 = stdenc(stddec(amtincded7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded8 = stdenc(stddec(amtincded8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded9 = stdenc(stddec(amtincded9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtincded10 = stdenc(stddec(amtincded10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update thispund  set amtded = stdenc(stddec(amtded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update thispund  set amttotded = stdenc(stddec(amttotded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update timpoinc  set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtincbf = stdenc(stddec(amtincbf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amttaxbf = stdenc(stddec(amttaxbf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtpf = stdenc(stddec(amtpf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtsaid = stdenc(stddec(amtsaid,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtincsp = stdenc(stddec(amtincsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amttaxsp = stdenc(stddec(amttaxsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtsasp = stdenc(stddec(amtsasp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastded  set amtpfsp = stdenc(stddec(amtpfsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastempd set amtdeduct = stdenc(stddec(amtdeduct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlastempd set amtspded = stdenc(stddec(amtspded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlateabs  set amtlate = stdenc(stddec(amtlate,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tlateabs  set amtearly = stdenc(stddec(amtearly,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tlateabs  set amtabsent = stdenc(stddec(amtabsent,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tleavetr  set amtlvded = stdenc(stddec(amtlvded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tothinc   set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tothpay   set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update totpaydt  set amtottot = stdenc(stddec(amtottot,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update totsum    set amtottot = stdenc(stddec(amtottot,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update totsum    set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update totsumd   set amtspot = stdenc(stddec(amtspot,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tovrtime  set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tovrtime  set amtottot = stdenc(stddec(amtottot,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysum   set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysum   set amtday = stdenc(stddec(amtday,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tpaysum   set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysum2  set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysum2  set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysum2  set amtday = stdenc(stddec(amtday,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpaysumd  set amtottot = stdenc(stddec(amtottot,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpayvac   set amtday = stdenc(stddec(amtday,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpayvac   set amtlepay = stdenc(stddec(amtlepay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      /*
      update tpfmemb   set amtcaccu = stdenc(stddec(amtcaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfmemb   set amtcretn = stdenc(stddec(amtcretn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfmemb   set amteaccu = stdenc(stddec(amteaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfmemb   set amteretn = stdenc(stddec(amteretn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfmemb   set amtinteccu = stdenc(stddec(amtinteccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfmemb   set amtintaccu = stdenc(stddec(amtintaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      */
      update tpfpay   set amtretn = stdenc(stddec(amtretn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfpay   set amtintretn = stdenc(stddec(amtintretn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfpay   set amtcaccu = stdenc(stddec(amtcaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tpfpay   set amttax = stdenc(stddec(amttax,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update trccontc set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update trccontc set amtsum = stdenc(stddec(amtsum,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tre tabs set amtlate = stdenc(stddec(amtlate,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tre tabs set amtearly = stdenc(stddec(amtearly,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tre tabs set amtabsent = stdenc(stddec(amtabsent,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tsincexp set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tsincexp set amtpay_e = stdenc(stddec(amtpay_e,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tsinexct set amtpay = stdenc(stddec(amtpay,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --  update tsinexct set amtpay_e = stdenc(stddec(amtpay_e,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      /*
      update ttaxcur set amtnet = stdenc(stddec(amtnet,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcal = stdenc(stddec(amtcal,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincl = stdenc(stddec(amtincl,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincc = stdenc(stddec(amtincc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincn = stdenc(stddec(amtincn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpl = stdenc(stddec(amtexpl,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpc = stdenc(stddec(amtexpc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpn = stdenc(stddec(amtexpn,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttax = stdenc(stddec(amttax,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtgrstx = stdenc(stddec(amtgrstx,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsoc = stdenc(stddec(amtsoc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsoca = stdenc(stddec(amtsoca,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsocc = stdenc(stddec(amtsocc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcprv = stdenc(stddec(amtcprv,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtprove = stdenc(stddec(amtprove,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtprovc = stdenc(stddec(amtprovc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtproie = stdenc(stddec(amtproie,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtproic = stdenc(stddec(amtproic,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtnet1 = stdenc(stddec(amtnet1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtnet2 = stdenc(stddec(amtnet2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttaxmas set amtnett = stdenc(stddec(amtnett,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtcalt = stdenc(stddec(amtcalt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtinclt = stdenc(stddec(amtinclt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtincct = stdenc(stddec(amtincct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtincnt = stdenc(stddec(amtincnt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtexplt = stdenc(stddec(amtexplt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtexpct = stdenc(stddec(amtexpct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtexpnt = stdenc(stddec(amtexpnt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amttaxt = stdenc(stddec(amttaxt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtgrstxt = stdenc(stddec(amtgrstxt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtsoct = stdenc(stddec(amtsoct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtsocat = stdenc(stddec(amtsocat,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtsocct = stdenc(stddec(amtsocct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtcprvt = stdenc(stddec(amtcprvt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtprovte = stdenc(stddec(amtprovte,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtprovtc = stdenc(stddec(amtprovtc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtsalyr = stdenc(stddec(amtsalyr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amttaxyr = stdenc(stddec(amttaxyr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtsocyr = stdenc(stddec(amtsocyr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amttcprv = stdenc(stddec(amttcprv,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas set amtproyr = stdenc(stddec(amtproyr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      */
      --user19 29/03/2018
      update ttaxcur set amtcal    = stdenc(stddec(amtcal       ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcalc	 = stdenc(stddec(amtcalc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcale	 = stdenc(stddec(amtcale      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcalo	 = stdenc(stddec(amtcalo      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtcprv	 = stdenc(stddec(amtcprv      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpc	 = stdenc(stddec(amtexpc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpl	 = stdenc(stddec(amtexpl      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtexpn	 = stdenc(stddec(amtexpn      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtgrstx	 = stdenc(stddec(amtgrstx     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincc	 = stdenc(stddec(amtincc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincl	 = stdenc(stddec(amtincl      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincn	 = stdenc(stddec(amtincn      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtincom1 = stdenc(stddec(amtincom1    ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtnet	   = stdenc(stddec(amtnet       ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtnet1	 = stdenc(stddec(amtnet1      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtnet2	 = stdenc(stddec(amtnet2      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtothc	 = stdenc(stddec(amtothc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtothe	 = stdenc(stddec(amtothe      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtotho	 = stdenc(stddec(amtotho      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtproic	 = stdenc(stddec(amtproic     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtproie	 = stdenc(stddec(amtproie     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtprovc	 = stdenc(stddec(amtprovc     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtprove	 = stdenc(stddec(amtprove     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsalyr	 = stdenc(stddec(amtsalyr     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsoc	   = stdenc(stddec(amtsoc       ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsoca	 = stdenc(stddec(amtsoca      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amtsocc	 = stdenc(stddec(amtsocc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttax	   = stdenc(stddec(amttax       ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttaxc	 = stdenc(stddec(amttaxc      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttaxe	 = stdenc(stddec(amttaxe      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttaxo	 = stdenc(stddec(amttaxo      ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttaxoth = stdenc(stddec(amttaxoth    ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxcur set amttaxyr	 = stdenc(stddec(amttaxyr     ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttaxmas  set amtcalct  = stdenc(stddec(amtcalct ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtcalet	= stdenc(stddec(amtcalet ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtcalot	= stdenc(stddec(amtcalot ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtcalt		= stdenc(stddec(amtcalt	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtcprvt	= stdenc(stddec(amtcprvt ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtexpct	= stdenc(stddec(amtexpct ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtexplt	= stdenc(stddec(amtexplt ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtexpnt	= stdenc(stddec(amtexpnt ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtgrstxt	= stdenc(stddec(amtgrstxt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtincct	= stdenc(stddec(amtincct ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtinclt	= stdenc(stddec(amtinclt ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtincnt	= stdenc(stddec(amtincnt ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtnett		= stdenc(stddec(amtnett	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtothc		= stdenc(stddec(amtothc	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtothe		= stdenc(stddec(amtothe	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtotho		= stdenc(stddec(amtotho	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtprovtc	= stdenc(stddec(amtprovtc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtprovte	= stdenc(stddec(amtprovte,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtproyr	= stdenc(stddec(amtproyr ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtsalyr	= stdenc(stddec(amtsalyr ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtsocat	= stdenc(stddec(amtsocat ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtsocct	= stdenc(stddec(amtsocct ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtsoct		= stdenc(stddec(amtsoct	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amtsocyr	= stdenc(stddec(amtsocyr ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxct	= stdenc(stddec(amttaxct ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxet	= stdenc(stddec(amttaxet ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxot	= stdenc(stddec(amttaxot ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxoth	= stdenc(stddec(amttaxoth,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxt		= stdenc(stddec(amttaxt	 ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttaxyr	= stdenc(stddec(amttaxyr ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmas  set amttcprv	= stdenc(stddec(amttcprv ,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      --user19 29/03/2018
      update ttaxded set amtform = stdenc(stddec(amtform,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxdet set amtfix = stdenc(stddec(amtfix,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxinc set amtinc = stdenc(stddec(amtinc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxinc set amttax = stdenc(stddec(amttax,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --phase 2 update ttbonus set amtsalcr = stdenc(stddec(amtsalcr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttbonus set amtbon = stdenc(stddec(amtbon,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --phase 2 update ttbonus set amtadjbo = stdenc(stddec(amtadjbo,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --phase 2 update ttbonus set amtnbon = stdenc(stddec(amtnbon,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttemadj1 set amttadj = stdenc(stddec(amttadj,codemprq,v_chken),codemprq,v_chken) where codemprq = p_codempid;
      update ttemadj2 set amtincod = stdenc(stddec(amtincod,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttemadj2 set amtincnw = stdenc(stddec(amtincnw,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttemadj2 set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      /* -- user19 29/03/2018
      update ttexempt set amtsalt = stdenc(stddec(amtsalt,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttexempt set amtotht = stdenc(stddec(amtotht,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      */ -- user19 29/03/2018
      update ttmovemt set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttmovemt set amtincadj1 = stdenc(stddec(amtincadj1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj2 = stdenc(stddec(amtincadj2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj3 = stdenc(stddec(amtincadj3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj4 = stdenc(stddec(amtincadj4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj5 = stdenc(stddec(amtincadj5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj6 = stdenc(stddec(amtincadj6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj7 = stdenc(stddec(amtincadj7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj8 = stdenc(stddec(amtincadj8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj9 = stdenc(stddec(amtincadj9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtincadj10 = stdenc(stddec(amtincadj10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttmovemt set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttnewemp set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttnewemp set amtothr = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj7 = stdenc(stddec(amtincadj7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj8 = stdenc(stddec(amtincadj8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj9 = stdenc(stddec(amtincadj9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj10 = stdenc(stddec(amtincadj10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttprobat set amtinadmth = stdenc(stddec(amtinadmth,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtinaddte = stdenc(stddec(amtinaddte,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtinadhr = stdenc(stddec(amtinadhr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttprobat set amtinmth = stdenc(stddec(amtinmth,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtindte = stdenc(stddec(amtindte,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtinhr = stdenc(stddec(amtinhr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj1 = stdenc(stddec(amtincadj1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj2 = stdenc(stddec(amtincadj2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj3 = stdenc(stddec(amtincadj3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj4 = stdenc(stddec(amtincadj4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj5 = stdenc(stddec(amtincadj5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttprobat set amtincadj6 = stdenc(stddec(amtincadj6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttpunded set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded1 = stdenc(stddec(amtincded1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded2 = stdenc(stddec(amtincded2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded3 = stdenc(stddec(amtincded3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded4 = stdenc(stddec(amtincded4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded5 = stdenc(stddec(amtincded5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded6 = stdenc(stddec(amtincded6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded7 = stdenc(stddec(amtincded7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update ttpunded set amtincded8 = stdenc(stddec(amtincded8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded9 = stdenc(stddec(amtincded9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtincded10 = stdenc(stddec(amtincded10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amtded = stdenc(stddec(amtded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttpunded set amttotded = stdenc(stddec(amttotded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
--update ttranpm set amtincom = stdenc(stddec(amtincom,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttranpm set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
--update ttranpm set amtsinc = stdenc(stddec(amtsinc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttranpmd set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttranpmd set amtsinc = stdenc(stddec(amtsinc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttsalst1 set amtincom = stdenc(stddec(amtincom,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttsalst1 set amtsinc = stdenc(stddec(amtsinc,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttsalst1 set amtadj = stdenc(stddec(amtadj,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update ttsalst1 set amtover = stdenc(stddec(amtover,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;

      update tytdinc set amtpay1 = stdenc(stddec(amtpay1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay2 = stdenc(stddec(amtpay2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay3 = stdenc(stddec(amtpay3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay4 = stdenc(stddec(amtpay4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay5 = stdenc(stddec(amtpay5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay6 = stdenc(stddec(amtpay6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay7 = stdenc(stddec(amtpay7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay8 = stdenc(stddec(amtpay8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay9 = stdenc(stddec(amtpay9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay10 = stdenc(stddec(amtpay10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay11 = stdenc(stddec(amtpay11,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update tytdinc set amtpay12 = stdenc(stddec(amtpay12,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --<< user22 : 10/08/2016 : STA3590307 ||
      update ttaxded set amtform  = stdenc(stddec(amtform,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxdet set amtfix   = stdenc(stddec(amtfix,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasd set amtdeduct = stdenc(stddec(amtdeduct,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasd set amtspded  = stdenc(stddec(amtspded,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasf set amtfml  = stdenc(stddec(amtfml,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtincbf = stdenc(stddec(amtincbf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amttaxbf = stdenc(stddec(amttaxbf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtsaid  = stdenc(stddec(amtsaid,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtpf    = stdenc(stddec(amtpf,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtincsp = stdenc(stddec(amtincsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amttaxsp = stdenc(stddec(amttaxsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtsasp  = stdenc(stddec(amtsasp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      update ttaxmasl set amtpfsp  = stdenc(stddec(amtpfsp,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tpfirinf set amtcaccu = stdenc(stddec(amtcaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      --update tpfirinf set amteaccu = stdenc(stddec(amteaccu,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid;
      -->> user22 : 10/08/2016 : STA3590307 ||
      /*--TTREHIRE
      update ttrehire set amtincom1 = stdenc(stddec(amtincom1,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom2 = stdenc(stddec(amtincom2,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom3 = stdenc(stddec(amtincom3,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom4 = stdenc(stddec(amtincom4,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom5 = stdenc(stddec(amtincom5,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom6 = stdenc(stddec(amtincom6,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom7 = stdenc(stddec(amtincom7,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom8 = stdenc(stddec(amtincom8,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom9 = stdenc(stddec(amtincom9,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtincom10 = stdenc(stddec(amtincom10,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set amtothr    = stdenc(stddec(amtothr,codempid,v_chken),p_codnewid,v_chken) where codempid = p_codempid and staupd in ('N','U');
            update ttrehire set codempid  = p_codnewid where codempid = p_codempid and staupd in ('N','U');*/
      for i in c1 loop
        y           := 0;
        v_statment2 := 'select count(*) from '||i.table_name||' where '||i.column_name||' = '''||p_codnewid||'''';
        y           := execute_qty(v_statment2);
        if y > 0 then
          gen_temp_tabledup(p_codempid,p_codnewid,v_statment2);
        else
          v_statment := 'update '||i.table_name||' set '||i.column_name||' = '''||p_codnewid||'''';
          v_statment := v_statment ||' where '||i.column_name||' = '''||p_codempid||'''';
          x := execute_delete(v_statment);
        end if;
      end loop;

  --<< user22 : 10/08/2016 : STA3590307 ||
      commit;
      --if p_flgcompdif = 'Y' then
      if p_flgcompdif = '#' then
                 delete tsincexp where codempid = p_codempid;
                 insert into tsincexp(select p_codempid,dteyrepay,dtemthpay,numperiod,codpay,codcomp,typpayroll,typemp,costcent,amtpay,typincexp,typinc,typpayr,typpayt,amtpay_e,codcurr_e,numlvl,flgslip,codbrlc,codcurr,codempmt,dtecreate,codcreate,dteupd,coduser from tsincexp where codempid = p_codnewid);
                 delete tsinexct where codempid = p_codempid;
                 insert into tsinexct(select p_codempid,dteyrepay,dtemthpay,numperiod,codpay,codcomp,costcent,amtpay,dteupd,coduser,dtecreate,codcreate from tsinexct where codempid = p_codnewid);

                 delete ttaxcur where codempid = p_codempid;
                 insert into ttaxcur
                  (codempid,dteyrepay,dtemthpay,numperiod,amtnet,amtcal,amtincl,amtincc,amtincn,amtexpl,amtexpc,amtexpn,amttax,amtgrstx,flgsoc,
                  amtsoc,amtsoca,amtsocc,amtcprv,amtprove,amtprovc,amtproie,amtproic,pctemppf,pctcompf,codcomp,typpayroll,numlvl,typemp,codbrlc,staemp,dteeffex,codcurr,amtincom1,codbank,numbank,bankfee,amtnet1,codbank2,numbank2,bankfee2,
                  amtnet2,qtywork,typpaymt,amtcale,amtcalc,codgrpgl,amtcalo,amttaxe,amttaxc,amttaxo,codpos,codempmt,jobgrade,flgtax,amtsalyr,amtothe,amtothc,amtotho,amttaxyr,amttaxoth,codcompy,dtecreate,codcreate,dteupd,coduser,typincom,flgtrnbank)
                  (select codempid,dteyrepay,dtemthpay,numperiod,amtnet,amtcal,amtincl,amtincc,amtincn,amtexpl,amtexpc,amtexpn,amttax,amtgrstx,flgsoc,
                  amtsoc,amtsoca,amtsocc,amtcprv,amtprove,amtprovc,amtproie,amtproic,pctemppf,pctcompf,codcomp,typpayroll,numlvl,typemp,codbrlc,staemp,dteeffex,codcurr,amtincom1,codbank,numbank,bankfee,amtnet1,codbank2,numbank2,bankfee2,
                  amtnet2,qtywork,typpaymt,amtcale,amtcalc,codgrpgl,amtcalo,amttaxe,amttaxc,amttaxo,codpos,codempmt,jobgrade,flgtax,amtsalyr,amtothe,amtothc,amtotho,amttaxyr,amttaxoth,codcompy,dtecreate,codcreate,dteupd,coduser,typincom,flgtrnbank
                  from ttaxcur
                  where codempid = p_codnewid);

                 delete ttaxded where codempid = p_codempid;
                 insert into ttaxded(select p_codempid,dteyrepay,dtemthpay,numperiod,numseq,descproc,formula,amtform,dteupd,coduser from ttaxded where codempid = p_codnewid);
                 delete ttaxdet where codempid = p_codempid;
                 insert into ttaxdet(select dteyear,p_codempid,amtfix,mqtypay,mthpay,perdpay from ttaxdet where codempid = p_codnewid);
                 delete ttaxinc where codempid = p_codempid;
                 insert into ttaxinc(select p_codempid,dteyrepay,dtemthpay,numperiod,typinc,typpayt,codcomp,typpayroll,numlvl,amtinc,amttax,dtecreate,codcreate,dteupd,coduser,typincom from ttaxinc where codempid = p_codnewid);
                 delete ttaxmas where codempid = p_codempid;
                 insert into ttaxmas(select p_codempid,dteyrepay,codcomp,amtnett,amtcalt,amtinclt,amtincct,amtincnt,amtexplt,amtexpct,amtexpnt,amttaxt,amtgrstxt,amtsoct,amtsocat,amtsocct,amtcprvt,amtprovte,amtprovtc,amtsalyr,amttaxyr,amtsocyr,amttcprv,amtproyr,qtyworkt,dteupd,coduser,amtcalet,amtcalct,amtcalot,amttaxet,amttaxct,amttaxot,amtothe,amtothc,amtotho,amttaxoth from ttaxmas where codempid = p_codnewid); --user36 STA3590309 13/09/2016 add field 'amttaxoth'
                 delete ttaxmasd where codempid = p_codempid;
                 insert into ttaxmasd(select dteyrepay,p_codempid,coddeduct,amtdeduct,amtspded,dteupd,coduser,dtemthpay,numperiod from ttaxmasd where codempid = p_codnewid);
                 delete ttaxmasf where codempid = p_codempid;
                 insert into ttaxmasf(select dteyrepay,p_codempid,numseq,desproce,desproct,desproc3,desproc4,desproc5,amtfml,dteupd,coduser,dtemthpay,numperiod from ttaxmasf where codempid = p_codnewid);
                 delete ttaxmasl where codempid = p_codempid;
                 insert into ttaxmasl(select dteyrepay,p_codempid,codcomp,typtax,flgtax,stamarry,amtincbf,amttaxbf,amtsaid,amtpf,amtincsp,amttaxsp,amtsasp,amtpfsp,dteupd,coduser,dtemthpay,numperiod from ttaxmasl where codempid = p_codnewid);
                 delete tpfirinf where codempid = p_codempid;
                 --insert into tpfirinf(select p_codempid,dteeffec,codpolicy,codplan,qtycompst,amtcaccu,amteaccu,ratecsbt,rateesbt,dtecalen,dtecreate,codcreate,dteupd,coduser from tpfirinf where codempid = p_codnewid);
                 --
                 update tsincexp set amtpay = stdenc(stddec(amtpay,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update tsincexp set amtpay_e = stdenc(stddec(amtpay_e,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update tsinexct set amtpay = stdenc(stddec(amtpay,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 --  update tsinexct set amtpay_e = stdenc(stddec(amtpay_e,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 /*
                 update ttaxcur set amtnet = stdenc(stddec(amtnet,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcal = stdenc(stddec(amtcal,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincl = stdenc(stddec(amtincl,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincc = stdenc(stddec(amtincc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincn = stdenc(stddec(amtincn,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpl = stdenc(stddec(amtexpl,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpc = stdenc(stddec(amtexpc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpn = stdenc(stddec(amtexpn,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttax = stdenc(stddec(amttax,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtgrstx = stdenc(stddec(amtgrstx,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsoc = stdenc(stddec(amtsoc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsoca = stdenc(stddec(amtsoca,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsocc = stdenc(stddec(amtsocc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcprv = stdenc(stddec(amtcprv,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtprove = stdenc(stddec(amtprove,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtprovc = stdenc(stddec(amtprovc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtproie = stdenc(stddec(amtproie,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtproic = stdenc(stddec(amtproic,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincom1 = stdenc(stddec(amtincom1,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtnet1 = stdenc(stddec(amtnet1,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtnet2 = stdenc(stddec(amtnet2,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtnett = stdenc(stddec(amtnett,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtcalt = stdenc(stddec(amtcalt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtinclt = stdenc(stddec(amtinclt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtincct = stdenc(stddec(amtincct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtincnt = stdenc(stddec(amtincnt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtexplt = stdenc(stddec(amtexplt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtexpct = stdenc(stddec(amtexpct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtexpnt = stdenc(stddec(amtexpnt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttaxt = stdenc(stddec(amttaxt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtgrstxt = stdenc(stddec(amtgrstxt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtsoct = stdenc(stddec(amtsoct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtsocat = stdenc(stddec(amtsocat,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtsocct = stdenc(stddec(amtsocct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtcprvt = stdenc(stddec(amtcprvt,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtprovte = stdenc(stddec(amtprovte,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtprovtc = stdenc(stddec(amtprovtc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtsalyr = stdenc(stddec(amtsalyr,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttaxyr = stdenc(stddec(amttaxyr,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtsocyr = stdenc(stddec(amtsocyr,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttcprv = stdenc(stddec(amttcprv,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtproyr = stdenc(stddec(amtproyr,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtcalet = stdenc(stddec(amtcalet,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtcalct = stdenc(stddec(amtcalct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtcalot = stdenc(stddec(amtcalot,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttaxet = stdenc(stddec(amttaxet,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttaxct = stdenc(stddec(amttaxct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amttaxot = stdenc(stddec(amttaxot,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtothe  = stdenc(stddec(amtothe,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtothc  = stdenc(stddec(amtothc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas set amtotho  = stdenc(stddec(amtotho,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 */
                 update ttaxcur set amtcal    = stdenc(stddec(amtcal       ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcalc	 = stdenc(stddec(amtcalc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcale	 = stdenc(stddec(amtcale      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcalo	 = stdenc(stddec(amtcalo      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtcprv	 = stdenc(stddec(amtcprv      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpc	 = stdenc(stddec(amtexpc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpl	 = stdenc(stddec(amtexpl      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtexpn	 = stdenc(stddec(amtexpn      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtgrstx	 = stdenc(stddec(amtgrstx     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincc	 = stdenc(stddec(amtincc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincl	 = stdenc(stddec(amtincl      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincn	 = stdenc(stddec(amtincn      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtincom1 = stdenc(stddec(amtincom1    ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtnet	   = stdenc(stddec(amtnet       ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtnet1	 = stdenc(stddec(amtnet1      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtnet2	 = stdenc(stddec(amtnet2      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtothc	 = stdenc(stddec(amtothc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtothe	 = stdenc(stddec(amtothe      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtotho	 = stdenc(stddec(amtotho      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtproic	 = stdenc(stddec(amtproic     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtproie	 = stdenc(stddec(amtproie     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtprovc	 = stdenc(stddec(amtprovc     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtprove	 = stdenc(stddec(amtprove     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsalyr	 = stdenc(stddec(amtsalyr     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsoc	   = stdenc(stddec(amtsoc       ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsoca	 = stdenc(stddec(amtsoca      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amtsocc	 = stdenc(stddec(amtsocc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttax	   = stdenc(stddec(amttax       ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttaxc	 = stdenc(stddec(amttaxc      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttaxe	 = stdenc(stddec(amttaxe      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttaxo	 = stdenc(stddec(amttaxo      ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttaxoth = stdenc(stddec(amttaxoth    ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxcur set amttaxyr	 = stdenc(stddec(amttaxyr     ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;

                 update ttaxmas  set amtcalct  = stdenc(stddec(amtcalct  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtcalet	= stdenc(stddec(amtcalet  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtcalot	= stdenc(stddec(amtcalot  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtcalt		= stdenc(stddec(amtcalt	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtcprvt	= stdenc(stddec(amtcprvt  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtexpct	= stdenc(stddec(amtexpct  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtexplt	= stdenc(stddec(amtexplt  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtexpnt	= stdenc(stddec(amtexpnt  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtgrstxt	= stdenc(stddec(amtgrstxt ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtincct	= stdenc(stddec(amtincct  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtinclt	= stdenc(stddec(amtinclt  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtincnt	= stdenc(stddec(amtincnt  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtnett		= stdenc(stddec(amtnett	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtothc		= stdenc(stddec(amtothc	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtothe		= stdenc(stddec(amtothe	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtotho		= stdenc(stddec(amtotho	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtprovtc	= stdenc(stddec(amtprovtc ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtprovte	= stdenc(stddec(amtprovte ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtproyr	= stdenc(stddec(amtproyr  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtsalyr	= stdenc(stddec(amtsalyr  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtsocat	= stdenc(stddec(amtsocat  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtsocct	= stdenc(stddec(amtsocct  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtsoct		= stdenc(stddec(amtsoct	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amtsocyr	= stdenc(stddec(amtsocyr  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxct	= stdenc(stddec(amttaxct  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxet	= stdenc(stddec(amttaxet  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxot	= stdenc(stddec(amttaxot  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxoth	= stdenc(stddec(amttaxoth ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxt		= stdenc(stddec(amttaxt	  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttaxyr	= stdenc(stddec(amttaxyr  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmas  set amttcprv	= stdenc(stddec(amttcprv  ,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;

                 update ttaxded set amtform    = stdenc(stddec(amtform,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxdet set amtfix     = stdenc(stddec(amtfix,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxinc set amtinc     = stdenc(stddec(amtinc,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxinc set amttax     = stdenc(stddec(amttax,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;

                 update ttaxded set amtform = stdenc(stddec(amtform,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxdet set amtfix  = stdenc(stddec(amtfix,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasd set amtdeduct = stdenc(stddec(amtdeduct,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasd set amtspded  = stdenc(stddec(amtspded,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasf set amtfml  = stdenc(stddec(amtfml,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtincbf = stdenc(stddec(amtincbf,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amttaxbf = stdenc(stddec(amttaxbf,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtsaid  = stdenc(stddec(amtsaid,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtpf    = stdenc(stddec(amtpf,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtincsp = stdenc(stddec(amtincsp,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amttaxsp = stdenc(stddec(amttaxsp,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtsasp  = stdenc(stddec(amtsasp,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 update ttaxmasl set amtpfsp  = stdenc(stddec(amtpfsp,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 --update tpfirinf set amtcaccu = stdenc(stddec(amtcaccu,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
                 --update tpfirinf set amteaccu = stdenc(stddec(amteaccu,p_codnewid,v_chken),p_codempid,v_chken) where codempid = p_codempid;
      end if;--p_flgcompDif = 'Y'
  -->> user22 : 10/08/2016 : STA3590307 ||
    end if;
  end;
  ---------------------
  procedure recal_movement
      (p_codempid         in varchar2,
       p_dteeffec         in date,
       p_numseq           in number,
       p_coduser          in varchar2) is

      prv_codcomp         temploy1.codcomp%type;
      v_codcompt          temploy1.codcomp%type;
      v_codcomp           temploy1.codcomp%type;

      prv_codpos          temploy1.codpos%type;
      v_codposnow         temploy1.codpos%type;
      v_codpos            temploy1.codpos%type;

      prv_codjob          temploy1.codjob%type;
      v_codjobt           temploy1.codjob%type;
      v_codjob            temploy1.codjob%type;

      prv_numlvl          temploy1.numlvl%type;
      v_numlvlt           temploy1.numlvl%type;
      v_numlvl            temploy1.numlvl%type;

      prv_codbrlc         temploy1.codbrlc%type;
      v_codbrlct          temploy1.codbrlc%type;
      v_codbrlc           temploy1.codbrlc%type;

      prv_codcalen        temploy1.codcalen%type;
      v_codcalet          temploy1.codcalen%type;
      v_codcalen          temploy1.codcalen%type;

      prv_codempmt        temploy1.codempmt%type;
      v_codempmtt         temploy1.codempmt%type;
      v_codempmt          temploy1.codempmt%type;

      prv_typpayroll      temploy1.typpayroll%type;
      v_typpayrolt        temploy1.typpayroll%type;
      v_typpayroll        temploy1.typpayroll%type;

      prv_typemp          temploy1.typemp%type;
      v_typempt           temploy1.typemp%type;
      v_typemp            temploy1.typemp%type;


      prv_flgatten          temploy1.flgatten%TYPE;  --ST11
      v_flgattent           temploy1.flgatten%TYPE;  --ST11
      v_flgatten            temploy1.flgatten%TYPE;  --ST11

      prv_jobgrade          temploy1.jobgrade%type;  --ST11
      v_jobgradet            temploy1.jobgrade%type;  --ST11
      v_jobgrade             temploy1.jobgrade%type;  --ST11

      prv_codgrpgl          temploy1.codgrpgl%type;  --ST11
      v_codgrpglt           temploy1.codgrpgl%type;   --ST11
      v_codgrpgl             temploy1.codgrpgl%type;  --ST11


      v_amtincom1         number := 0;
      v_amtincom2         number := 0;
      v_amtincom3         number := 0;
      v_amtincom4         number := 0;
      v_amtincom5         number := 0;
      v_amtincom6         number := 0;
      v_amtincom7         number := 0;
      v_amtincom8         number := 0;
      v_amtincom9         number := 0;
      v_amtincom10        number := 0;

      v_sumincadj1        number := 0;
      v_sumincadj2        number := 0;
      v_sumincadj3        number := 0;
      v_sumincadj4        number := 0;
      v_sumincadj5        number := 0;
      v_sumincadj6        number := 0;
      v_sumincadj7        number := 0;
      v_sumincadj8        number := 0;
      v_sumincadj9        number := 0;
      v_sumincadj10       number := 0;

  cursor c_ttmovemt is
      select  codempid,dteeffec,numseq,codtrn,
              codcompt,codcomp,codposnow,codpos,codjobt,codjob,
              numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,
              codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
              flgattet, flgatten,jobgradet,jobgrade,codgrpglt,codgrpgl,
              amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
              amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
              amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
              amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,namtab
      from ((select codempid,dteeffec,numseq,codtrn,
                   codcompt,codcomp,codposnow,codpos,codjobt,codjob,
                   numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,
                   codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
                   flgattet, flgatten,jobgradet,jobgrade,codgrpglt,codgrpgl,

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
                   stddec(amtincadj1,codempid,v_chken) amtincadj1,
                   stddec(amtincadj2,codempid,v_chken) amtincadj2,
                   stddec(amtincadj3,codempid,v_chken) amtincadj3,

                   stddec(amtincadj4,codempid,v_chken) amtincadj4,
                   stddec(amtincadj5,codempid,v_chken) amtincadj5,
                   stddec(amtincadj6,codempid,v_chken) amtincadj6,
                   stddec(amtincadj7,codempid,v_chken) amtincadj7,
                   stddec(amtincadj8,codempid,v_chken) amtincadj8,
                   stddec(amtincadj9,codempid,v_chken) amtincadj9,
                   stddec(amtincadj10,codempid,v_chken) amtincadj10,
                     'TTMOVEMT' namtab
                   from   ttmovemt
               where  codempid  = p_codempid)
               union
              (select codempid,dteduepr dteeffec,0 numseq,'0003' codtrn,
                                codcomp codcompt,codcomp,codpos codposnow,codpos,' ' codjobt,' ' codjob,
                                numlvl numlvlt,numlvl,codbrlc codbrlct,codbrlc,codcalen codcalet,codcalen,
                                codempmt codempmtt,codempmt,typpayroll typpayrolt,typpayroll,typemp typempt,typemp,
                                null flgattet, null flgatten,
                                jobgrade jobgradet,jobgrade,
                                codgrpgl codgrpglt,codgrpgl,

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
                                stddec(amtincadj1,codempid,v_chken) amtincadj1,

                                stddec(amtincadj2,codempid,v_chken) amtincadj2,
                                stddec(amtincadj3,codempid,v_chken) amtincadj3,
                                stddec(amtincadj4,codempid,v_chken) amtincadj4,
                                stddec(amtincadj5,codempid,v_chken) amtincadj5,
                                stddec(amtincadj6,codempid,v_chken) amtincadj6,
                                stddec(amtincadj7,codempid,v_chken) amtincadj7,
                                stddec(amtincadj8,codempid,v_chken) amtincadj8,
                                stddec(amtincadj9,codempid,v_chken) amtincadj9,
                                stddec(amtincadj10,codempid,v_chken) amtincadj10,
                                'TTPROBAT' namtab
                 from   ttprobat
                 where  codempid  = p_codempid))
    where ((dteeffec = p_dteeffec and numseq >= p_numseq)
                 or   (dteeffec > p_dteeffec))
      order by dteeffec,numseq;

  begin
    select nvl(sum(amtincadj1),0),nvl(sum(amtincadj2),0),nvl(sum(amtincadj3),0),nvl(sum(amtincadj4),0),nvl(sum(amtincadj5),0),
             nvl(sum(amtincadj6),0),nvl(sum(amtincadj7),0),nvl(sum(amtincadj8),0),nvl(sum(amtincadj9),0),nvl(sum(amtincadj10),0)

    into    v_sumincadj1,v_sumincadj2,v_sumincadj3,v_sumincadj4,v_sumincadj5,
              v_sumincadj6,v_sumincadj7,v_sumincadj8,v_sumincadj9,v_sumincadj10

    from ((select stddec(amtincadj1,codempid,v_chken) amtincadj1,
                       stddec(amtincadj2,codempid,v_chken) amtincadj2,
                       stddec(amtincadj3,codempid,v_chken) amtincadj3,
                       stddec(amtincadj4,codempid,v_chken) amtincadj4,
                       stddec(amtincadj5,codempid,v_chken) amtincadj5,
                       stddec(amtincadj6,codempid,v_chken) amtincadj6,
                       stddec(amtincadj7,codempid,v_chken) amtincadj7,
                       stddec(amtincadj8,codempid,v_chken) amtincadj8,
                       stddec(amtincadj9,codempid,v_chken) amtincadj9,
                       stddec(amtincadj10,codempid,v_chken) amtincadj10
                  from   ttmovemt
                  where  codempid  = p_codempid
                  and ((dteeffec = p_dteeffec and numseq > p_numseq)
                  or dteeffec > p_dteeffec)
                  and staupd = 'U')
      union
                  (select stddec(amtincadj1,codempid,v_chken) amtincadj1,
                                stddec(amtincadj2,codempid,v_chken) amtincadj2,
                                stddec(amtincadj3,codempid,v_chken) amtincadj3,
                                stddec(amtincadj4,codempid,v_chken) amtincadj4,
                                stddec(amtincadj5,codempid,v_chken) amtincadj5,
                                stddec(amtincadj6,codempid,v_chken) amtincadj6,
                                stddec(amtincadj7,codempid,v_chken) amtincadj7,
                                stddec(amtincadj8,codempid,v_chken) amtincadj8,
                                stddec(amtincadj9,codempid,v_chken) amtincadj9,
                                stddec(amtincadj10,codempid,v_chken) amtincadj10
                  from   ttprobat
                  where  codempid  = p_codempid
                  and ((dteeffec = p_dteeffec and numseq > p_numseq)
                  or dteeffec > p_dteeffec)
                  and staupd = 'U'));

      for r1 in c_ttmovemt loop
          if r1.dteeffec = p_dteeffec and r1.numseq = p_numseq then

              prv_codcomp := r1.codcomp;
              prv_codpos := r1.codpos;
              prv_codjob := r1.codjob;
              prv_numlvl := r1.numlvl;
              prv_codbrlc := r1.codbrlc;
              prv_codcalen := r1.codcalen;
              prv_codempmt := r1.codempmt;
              prv_typpayroll := r1.typpayroll;
              prv_typemp := r1.typemp;
--<<st11
               prv_flgatten          := r1.flgatten;
               prv_jobgrade        := r1.jobgrade;
               prv_codgrpgl         := r1.codgrpgl;
-->>st11

              v_amtincom1 := nvl(r1.amtincom1,0) - v_sumincadj1;
              v_amtincom2 := nvl(r1.amtincom2,0) - v_sumincadj2;
              v_amtincom3 := nvl(r1.amtincom3,0) - v_sumincadj3;
              v_amtincom4 := nvl(r1.amtincom4,0) - v_sumincadj4;
              v_amtincom5 := nvl(r1.amtincom5,0) - v_sumincadj5;

              v_amtincom6 := nvl(r1.amtincom6,0) - v_sumincadj6;
              v_amtincom7 := nvl(r1.amtincom7,0) - v_sumincadj7;
              v_amtincom8 := nvl(r1.amtincom8,0) - v_sumincadj8;
              v_amtincom9 := nvl(r1.amtincom9,0) - v_sumincadj9;
              v_amtincom10 := nvl(r1.amtincom10,0) - v_sumincadj10;

              update ttmovemt
                  set amtincom1 = stdenc(v_amtincom1,codempid,v_chken),
                          amtincom2 = stdenc(v_amtincom2,codempid,v_chken),
                          amtincom3 = stdenc(v_amtincom3,codempid,v_chken),
                          amtincom4 = stdenc(v_amtincom4,codempid,v_chken),
                          amtincom5 = stdenc(v_amtincom5,codempid,v_chken),
                          amtincom6 = stdenc(v_amtincom6,codempid,v_chken),
                          amtincom7 = stdenc(v_amtincom7,codempid,v_chken),

                          amtincom8 = stdenc(v_amtincom8,codempid,v_chken),
                          amtincom9 = stdenc(v_amtincom9,codempid,v_chken),
                          amtincom10 = stdenc(v_amtincom10,codempid,v_chken),
                          coduser = p_coduser
                  where codempid = p_codempid
                  and     dteeffec = r1.dteeffec
                  and     numseq   = r1.numseq;
          else
              v_codcompt := prv_codcomp;  -- CODCOMP
              v_codcomp := r1.codcomp;
              if r1.codcompt = r1.codcomp then
                  v_codcomp := prv_codcomp;
              end if;
              prv_codcomp := v_codcomp;

              v_codposnow := prv_codpos;  -- CODPOS
              v_codpos := r1.codpos;
              if r1.codposnow = r1.codpos then
                  v_codpos := prv_codpos;
              end if;
              prv_codpos := v_codpos;

              v_codjobt := prv_codjob;    -- CODJOB
              v_codjob := r1.codjob;
              if r1.codjobt = r1.codjob then
                  v_codjob := prv_codjob;
              end if;
              prv_codjob := v_codjob;

              v_numlvlt := prv_numlvl;    -- NUMLVL
              v_numlvl := r1.numlvl;
              if r1.numlvlt = r1.numlvl then
                  v_numlvl := prv_numlvl;
              end if;
              prv_numlvl := v_numlvl;

              v_codbrlct := prv_codbrlc;  -- CODBRLC
              v_codbrlc := r1.codbrlc;
              if r1.codbrlct = r1.codbrlc then
                  v_codbrlc := prv_codbrlc;
              end if;
              prv_codbrlc := v_codbrlc;

              v_codcalet := prv_codcalen; -- CODCALEN
              v_codcalen := r1.codcalen;
              if r1.codcalet = r1.codcalen then
                  v_codcalen := prv_codcalen;
              end if;
              prv_codcalen := v_codcalen;

              v_codempmtt := prv_codempmt;    -- CODEMPMT
              v_codempmt := r1.codempmt;
              if r1.codempmtt = r1.codempmt then
                  v_codempmt := prv_codempmt;
              end if;
              prv_codempmt := v_codempmt;

              v_typpayrolt := prv_typpayroll; -- TYPPAYROLL
              v_typpayroll := r1.typpayroll;
              if r1.typpayrolt = r1.typpayroll then
                  v_typpayroll := prv_typpayroll;
              end if;
              prv_typpayroll := v_typpayroll;

              v_typempt := prv_typemp;    -- TYPEMP
              v_typemp := r1.typemp;
              if r1.typempt = r1.typemp then
                  v_typemp := prv_typemp;
              end if;
              prv_typemp := v_typemp;

--<<redmine2847
               v_flgattent := prv_flgatten;    -- flgatten
               v_flgatten := r1.flgatten;
               if r1.flgattet = r1.flgatten then
                  v_flgatten := prv_flgatten;
               end if;
               prv_flgatten := v_flgatten;

               v_jobgradet := prv_jobgrade;    -- jobgrade
               v_jobgrade := r1.jobgrade;
               if r1.jobgradet = r1.jobgrade then
                  v_jobgrade := prv_jobgrade;
               end if;
               prv_jobgrade := v_jobgrade;

               v_codgrpglt := prv_codgrpgl;    -- codgrpgl
               v_codgrpgl := r1.codgrpgl;
               if r1.codgrpglt = r1.codgrpgl then
                  v_codgrpgl := prv_codgrpgl;
               end if;
               prv_codgrpgl := v_codgrpgl;
-->>redmine2847

              v_amtincom1 := v_amtincom1 + nvl(r1.amtincadj1,0);
              v_amtincom2 := v_amtincom2 + nvl(r1.amtincadj2,0);
              v_amtincom3 := v_amtincom3 + nvl(r1.amtincadj3,0);
              v_amtincom4 := v_amtincom4 + nvl(r1.amtincadj4,0);
              v_amtincom5 := v_amtincom5 + nvl(r1.amtincadj5,0);
              v_amtincom6 := v_amtincom6 + nvl(r1.amtincadj6,0);
              v_amtincom7 := v_amtincom7 + nvl(r1.amtincadj7,0);
              v_amtincom8 := v_amtincom8 + nvl(r1.amtincadj8,0);
              v_amtincom9 := v_amtincom9 + nvl(r1.amtincadj9,0);
              v_amtincom10 := v_amtincom10 + nvl(r1.amtincadj10,0);

              if  r1.namtab = 'TTMOVEMT' then

                  update ttmovemt
                      set   codcompt   = v_codcompt,          codcomp = v_codcomp,
                              codjobt      = v_codjobt,             codjob = v_codjob,
                              codposnow = v_codposnow,         codpos = v_codpos,
                              numlvlt = v_numlvlt,                   numlvl = v_numlvl,
                              codbrlct = v_codbrlct,                 codbrlc = v_codbrlc,
                              codcalet = v_codcalet,                codcalen = v_codcalen,
                              codempmtt = v_codempmtt,       codempmt = v_codempmt,
                              typpayrolt = v_typpayrolt,           typpayroll = v_typpayroll,
                              typempt = v_typempt,               typemp = v_typemp,
--<<redmine2847
                              flgattet     = v_flgattent,             flgatten   =v_flgatten,
                              jobgradet  = v_jobgradet ,          jobgrade   = v_jobgrade,
                              codgrpglt   = v_codgrpglt,           codgrpgl   = v_codgrpgl,
-->>redmine2847
                              amtincom1 = stdenc(v_amtincom1,codempid,v_chken),
                              amtincom2 = stdenc(v_amtincom2,codempid,v_chken),
                              amtincom3 = stdenc(v_amtincom3,codempid,v_chken),
                              amtincom4 = stdenc(v_amtincom4,codempid,v_chken),
                              amtincom5 = stdenc(v_amtincom5,codempid,v_chken),
                              amtincom6 = stdenc(v_amtincom6,codempid,v_chken),
                              amtincom7 = stdenc(v_amtincom7,codempid,v_chken),
                              amtincom8 = stdenc(v_amtincom8,codempid,v_chken),
                              amtincom9 = stdenc(v_amtincom9,codempid,v_chken),
                              amtincom10 = stdenc(v_amtincom10,codempid,v_chken),
                              coduser = p_coduser
                      where codempid = p_codempid
                      and     dteeffec = r1.dteeffec
                      and     numseq   = r1.numseq;

              else
                  update ttprobat
                        set codcomp        = v_codcomp,
                              codpos        = v_codpos,           numlvl      = v_numlvl,
                              codbrlc        = v_codbrlc,           codcalen   = v_codcalen,
                              codempmt   = v_codempmt,       typpayroll = v_typpayroll,
                              typemp       = v_typemp,

--<<redmine2847
                              jobgrade   = v_jobgrade,
                              codgrpgl   = v_codgrpgl,
-->>redmine2847

                              amtincom1 = stdenc(v_amtincom1,codempid,v_chken),
                              amtincom2 = stdenc(v_amtincom2,codempid,v_chken),
                              amtincom3 = stdenc(v_amtincom3,codempid,v_chken),
                              amtincom4 = stdenc(v_amtincom4,codempid,v_chken),
                              amtincom5 = stdenc(v_amtincom5,codempid,v_chken),
                              amtincom6 = stdenc(v_amtincom6,codempid,v_chken),
                              amtincom7 = stdenc(v_amtincom7,codempid,v_chken),
                              amtincom8 = stdenc(v_amtincom8,codempid,v_chken),
                              amtincom9 = stdenc(v_amtincom9,codempid,v_chken),
                              amtincom10 = stdenc(v_amtincom10,codempid,v_chken),
                              coduser = p_coduser
                      where codempid = p_codempid
                      and     dteduepr = r1.dteeffec;

              end if;
          end if;
      end loop;

  end recal_movement;
  ---------------

  procedure ins_errtmp( p_codempid   varchar2,
                                  p_codcomp    varchar2,
                                  p_codpos      varchar2,
                                  p_code         varchar2,
                                  p_table         varchar2,
                                  p_topic         varchar2,
                                  p_coduser     varchar2) is -- From Transection

      v_coduser      temploy1.coduser%type := 'AUTO';
      v_num          number:=0;
      v_descerr      ttemfilt.item07%type;

  begin
      if p_table is not null then
         v_descerr  :=  '('||p_table||') '||get_errorm_name(p_code,'102');
      else
         v_descerr  := get_errorm_name(p_code,'102');
      end if;

      parameter_numseq   := nvl(parameter_numseq,0) + 1;
      insert  into ttemfilt
                     (codapp,coduser,numseq,
                     item01,item02,item03,item04,item05,item06,item07,item08)
                     values
                     ('HRPM91B',p_coduser,parameter_numseq,
                     p_codempid,get_temploy_name(p_codempid,'102'),
                     p_codcomp,get_tcenter_name(p_codcomp,'102'),
                     p_codpos,get_tpostn_name(p_codpos,'102'),
                     v_descerr,p_topic);
  end ins_errtmp;

  PROCEDURE gen_temp_tabledup (p_codempid varchar2, p_codempidnew varchar2 ,p_msg varchar2) IS

    v_numseq	number;

  BEGIN
    begin
      select max(numseq)
        into v_numseq
        from ttemfilt
       where coduser = 'GEN_TDUP'
         and codapp = 'HRPM91B';
    exception when no_data_found then
      v_numseq	:= 0;
    end;

    v_numseq	:= nvl(v_numseq,0) + 1;
    insert into ttemfilt (coduser, codapp, numseq, item01,item02,item03)
                  values ('GEN_TDUP','HRPM91B',v_numseq,p_codempid,p_codempidnew,p_msg);

    commit;
  END gen_temp_tabledup;

  procedure ins_tusrprof(p_codempid in varchar2) is --user36 10/05/2022
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_header        number;
    v_type          varchar2(1 char);
    v_exist         varchar2(1 char) := 'N';
    v_numlvlst      number;
    v_numlvlen      number;
    v_usrcom        temploy1.codcomp%type;
    v_numseq        number;
    v_typecodusr    tcontrusr.typecodusr%type;
    v_typepwd       tcontrusr.typepwd%type;
    v_coduser       tusrprof.coduser%type;
    v_codpswd       tusrprof.codpswd%type;
    v_numoffid      temploy2.numoffid%type;
    v_numpasid      temploy2.numpasid%type;
    v_year          number;
    v_run           number;
    p_codpswd_hash  varchar2(4000 char);
    v_chk           varchar2(1 char);

    cursor c_tusrprof is
      select coduser,typeuser,flgact,numlvlst,numlvlen
        from tusrprof
       where codempid = p_codempid
    order by coduser;

  begin
    begin
      select codcomp,codpos,numlvl into v_codcomp,v_codpos,v_numlvlen
      from   temploy1
      where  codempid = p_codempid;
    exception when no_data_found then
      return;
    end;
    begin
      select count(*) into v_header
      from   temphead
      where  codempidh = p_codempid
        or (codcomph||codposh in (select codcomp||codpos
                                    from temploy1
                                   where codempid = p_codempid
                                   union
                                  select codcomp||codpos
                                    from tsecpos
                                   where codempid = p_codempid
                                     and dteeffec <= trunc(sysdate)
                                     and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)));
    end;
    if v_header > 0 then
      v_type      := '3';
      v_numlvlst  := 1;
    else
      v_type      := '2';
      v_numlvlst  := v_numlvlen;
    end if;
    for i in c_tusrprof loop --ประเภทผู้ใช้งาน [ 4-System Admin, 1-HR , 2-พนักงาน , 3-หัวหน้างาน ]
      v_exist := 'Y';
      if i.typeuser in ('2','3') then
        --1.TUSRPROF--
        update tusrprof set typeuser = v_type,
                            flgact   = '1',
                            numlvlst = pwdenc(v_numlvlst, i.coduser, v_chken),
                            numlvlen = pwdenc(v_numlvlen, i.coduser, v_chken),
                            dteupd   = sysdate,
                            coduser2 = global_v_coduser
        where  coduser = i.coduser;

        ins_tusrlog(i.coduser, 'tusrprof', 'typeuser', v_type, i.typeuser);
        ins_tusrlog(i.coduser, 'tusrprof', 'flgact'  , '1', i.flgact);
        ins_tusrlog(i.coduser, 'tusrprof', 'numlvlst', v_numlvlst, pwddec(i.numlvlst, i.coduser, v_chken));
        ins_tusrlog(i.coduser, 'tusrprof', 'numlvlen', v_numlvlen, pwddec(i.numlvlen, i.coduser, v_chken));

        ----USERS----
        update users
           set codempid   = p_codempid,
               updated_at = sysdate
         where email      = i.coduser;

        --2.TUSRCOM--
        ins_tusrcom(p_codempid,i.coduser,v_type);

        --3.TUSRPROC--
        ins_tusrproc(p_codempid,i.coduser,v_type);
      end if;
    end loop;

    if v_exist = 'N' then --Gen New User
      begin
        select typecodusr,typepwd
        into   v_typecodusr,v_typepwd
        from   tcontrusr
        where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
        and    dteeffec = (select max(dteeffec)
                           from   tcontrusr
                           where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                           and    dteeffec <= trunc(sysdate));
      exception when no_data_found then
        return;
      end;
      if v_typecodusr = 'E' then
        v_coduser := p_codempid;
      elsif v_typecodusr = 'Y' then
        v_year := substr(to_char(sysdate,'yyyy'),3,2);
        begin
          select nvl(seqno,0) + 1 into v_run
            from tlastreq
           where codcompy = 'XXXX'
             and typgen   = 'USERID'
             and dteyear  = v_year
             and dtemth   = 13;
        exception when others then v_run := 1;
        end;
        --
        loop
          v_coduser := v_year||lpad(v_run,8,'0');
          begin
            select 'Y'
            into   v_chk
            from   tusrprof
            where  coduser = v_coduser;
          exception when no_data_found then
            exit;
          end;
          v_run := v_run + 1;
        end loop;
        --
        begin
          insert into tlastreq(codcompy,typgen,dteyear,dtemth,seqno,dtecreate,codcreate,dteupd,coduser)
                        values('XXXX','USERID',v_year,13,v_run,trunc(sysdate),global_v_coduser,trunc(sysdate),global_v_coduser);
        exception when others then
          update tlastreq
             set seqno    = v_run
           where codcompy = 'XXXX'
             and typgen   = 'USERID'
             and dteyear  = v_year
             and dtemth   = 13;
        end;
      end if;
      if v_typepwd = 'E' then
        v_codpswd := p_codempid;
      elsif v_typepwd = 'I' then
        begin
          select numoffid, numpasid
          into   v_numoffid, v_numpasid
          from   temploy2
          where  codempid = p_codempid;
        exception when no_data_found then null;
        end;
        v_codpswd := substr(nvl(v_numoffid, v_numpasid), -5);
      end if;
      --1.TUSRPROF--
      insert into tusrprof(coduser,codempid,typeuser,
                           flgact,flgtranl,flgchgpass,
                           numlvlst,numlvlen,
                           numlvlsalst,numlvlsalen,
                           codpswd,flgalter,flgauth,
                           coduser2,dtecreate,usrcreate
                           )
                    values(v_coduser,p_codempid,v_type,
                           '1','N','N',
                           pwdenc(v_numlvlst, v_coduser, v_chken),pwdenc(v_numlvlen, v_coduser, v_chken),
                           pwdenc(0, v_coduser, v_chken),pwdenc(0, v_coduser, v_chken),
                           pwdenc(v_codpswd, v_coduser, v_chken),'N','2',
                           global_v_coduser,sysdate,global_v_coduser);

      ins_tusrlog(v_coduser,'tusrprof', 'coduser', v_coduser);
      ins_tusrlog(v_coduser,'tusrprof', 'codempid', p_codempid);
      ins_tusrlog(v_coduser,'tusrprof', 'typeuser', v_type);
      ins_tusrlog(v_coduser,'tusrprof', 'flgact', '1');
      ins_tusrlog(v_coduser,'tusrprof', 'flgtranl', 'N');
      ins_tusrlog(v_coduser,'tusrprof', 'flgchgpass', 'N');
      ins_tusrlog(v_coduser,'tusrprof', 'numlvlst', v_numlvlst);
      ins_tusrlog(v_coduser,'tusrprof', 'numlvlen', v_numlvlen);
      ins_tusrlog(v_coduser,'tusrprof', 'numlvlsalst', 0);
      ins_tusrlog(v_coduser,'tusrprof', 'numlvlsalen', 0);
      ins_tusrlog(v_coduser,'tusrprof', 'codpswd', '*****');
      ins_tusrlog(v_coduser,'tusrprof', 'flgalter', 'N');
      ins_tusrlog(v_coduser,'tusrprof', 'flgauth', '2');

      ----USERS----
      p_codpswd_hash := call_api_backend(get_tsetup_value('PATHAPI')||'api/login/genPassword/'||v_codpswd);
      delete users where name = v_coduser; --temp
      insert into users (name, email, password, is_client, created_at, updated_at, username, codempid)
                 values (v_coduser, v_coduser, p_codpswd_hash, '1', sysdate, sysdate, v_coduser, p_codempid);

      --2.TUSRCOM--
      ins_tusrcom(p_codempid,v_coduser,v_type);


      --3.TUSRPROC--
      ins_tusrproc(p_codempid,v_coduser,v_type);
    end if;
    commit;
  exception when others then null;
  end;

  procedure ins_tusrcom(p_codempid in varchar2,p_coduser in varchar2,p_type in varchar2) is
    v_usrcom    temploy1.codcomp%type;

    cursor c_del is
      select coduser,codcomp
        from tusrcom
       where coduser = p_coduser;

    cursor c_comp is
      select codcomp
        from temploy1
       where codempid = p_codempid
      union
      select codcomp
        from tsecpos
       where codempid = p_codempid
         and dteeffec <= trunc(sysdate)
         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
      union
      select b.codcomp
        from temphead a, temploy1 b
       where a.codempid = b.codempid
         and (a.codempidh = p_codempid
          or (a.codcomph||codposh in (select codcomp||codpos
                                        from temploy1
                                       where codempid = p_codempid
                                     union
                                      select codcomp||codpos
                                        from tsecpos
                                       where codempid   = p_codempid
                                         and dteeffec  <= trunc(sysdate)
                                         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))))
         and a.codempid is not null
         and p_type = '3'
      union
      select codcomp
        from temphead
       where (codempidh = p_codempid
          or (codcomph||codposh in (select codcomp||codpos
                                      from temploy1
                                     where codempid = p_codempid
                                   union
                                    select codcomp||codpos
                                      from tsecpos
                                     where codempid   = p_codempid
                                       and dteeffec  <= trunc(sysdate)
                                       and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))))
         and codcomp is not null
         and p_type = '3'
    order by 1;

  begin
--<<IPO//16/03/2023
/*
    for i in c_del loop
      delete tusrcom where coduser = i.coduser and codcomp = i.codcomp;

      ins_tusrlog(i.coduser, 'tusrcom', 'coduser', '', i.coduser);
      ins_tusrlog(i.coduser, 'tusrcom', 'codcomp', '', i.codcomp);
    end loop;
*/
    for j in c_comp loop
            for i in c_del loop
              delete tusrcom where coduser = i.coduser and codcomp = i.codcomp;
        
              ins_tusrlog(i.coduser, 'tusrcom', 'coduser', '', i.coduser);
              ins_tusrlog(i.coduser, 'tusrcom', 'codcomp', '', i.codcomp);
            end loop;      
          exit;
    end loop;  -- for j in c_comp loop
-->>IPO//16/03/2023

    for j in c_comp loop
      if p_type = '3' then
        v_usrcom := get_codcomp_level(j.codcomp);
      elsif p_type = '2' then
        v_usrcom := j.codcomp;
      end if;
--5514      
      begin
        insert into tusrcom(coduser,codcomp,dtecreate,codcreate,rcupdid)
                     values(p_coduser,v_usrcom,sysdate,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then null;
      end;

      ins_tusrlog(p_coduser, 'tusrcom', 'coduser', p_coduser);
      ins_tusrlog(p_coduser, 'tusrcom', 'codcomp', v_usrcom);
    end loop;
  exception when others then null;
  end;

  procedure ins_tusrproc(p_codempid in varchar2,p_coduser in varchar2,p_type in varchar2) is
    v_flgcal    boolean;
    v_cond      varchar2(4000);
    v_stmt      varchar2(4000);
    v_codcompy  tcontrusrd.codcompy%type;
    v_dteeffec  tcontrusrd.dteeffec%type;
    v_numseq    tcontrusrd.numseq%type;

    v_dtemovemt   date := trunc(sysdate);
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
    v_check       varchar2(10);
    
    cursor c_del is
      select coduser,codproc,flgauth
        from tusrproc
       where coduser = p_coduser;

    cursor c_tcontrusrd is
      select codcompy,dteeffec,numseq,syncond
      from   tcontrusrd
      where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
      and    dteeffec = (select max(dteeffec)
                         from   tcontrusr
                         where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                         and    dteeffec <= trunc(sysdate))
      and    typeusr  = decode(p_type,'2','E','H')
      order by numseq;

    cursor c_tcontrusrm is
      select *
      from   tcontrusrm
      where  codcompy = v_codcompy
      and    dteeffec = v_dteeffec
      and    numseq   = v_numseq
      order by codproc;

  begin
---<<check issue sea-HR2201/redmine676    
     std_al.get_movemt(p_codempid,v_dtemovemt,'C','U',
                                      v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                      v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                      v_amthour,v_amtday,v_amtmth);
                                  
    v_check := 'N';
    for i in c_tcontrusrd loop
      v_check := 'Y';
    end loop;
    if v_check = 'N' then
      return;  
    end if;
    v_check := 'N';
--->>check issue sea-HR2201/redmine676    


--<<IPO//16/03/2023
/*
    for i in c_del loop
      delete tusrproc where coduser = i.coduser and codproc = i.codproc;

      ins_tusrlog(i.coduser, 'tusrproc', 'coduser', '', i.coduser);
      ins_tusrlog(i.coduser, 'tusrproc', 'codproc', '', i.codproc);
      ins_tusrlog(i.coduser, 'tusrproc', 'flgauth', '', i.flgauth);
    end loop;
*/
-->>IPO//16/03/2023

 
    for k in c_tcontrusrd loop
      v_flgcal := true;
      if k.syncond is not null then
        v_cond := k.syncond;
        v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
        v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
        v_cond := replace(v_cond,'TEMPLOY1.CODEMPID',''''||p_codempid||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
        v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
        v_stmt := 'select count(*) from dual where '||v_cond;
        v_flgcal := execute_stmt(v_stmt);
      end if;

      if v_flgcal then
        v_codcompy := k.codcompy;
        v_dteeffec := k.dteeffec;
        v_numseq   := k.numseq;
--<<IPO//16/03/2023        
        for l in c_tcontrusrm loop
                  for i in c_del loop
                      delete tusrproc where coduser = i.coduser and codproc = i.codproc;
                    
                      ins_tusrlog(i.coduser, 'tusrproc', 'coduser', '', i.coduser);
                      ins_tusrlog(i.coduser, 'tusrproc', 'codproc', '', i.codproc);
                      ins_tusrlog(i.coduser, 'tusrproc', 'flgauth', '', i.flgauth);
                 end loop;    
                 exit;--for l in c_tcontrusrm loop
        end loop;  --for l in c_tcontrusrm loop
 -->>IPO//16/03/2023
 
        for l in c_tcontrusrm loop          
--<< user22 : 07/08/2022 : ST11 ||
          v_check := std_sc.chk_license_by_module(l.codproc);
          if v_check = 'Y' then
-->> user22 : 07/08/2022 : ST11 ||
--5631
            begin
              insert into tusrproc(coduser,codproc,flgauth,dtecreate,codcreate,rcupdid)
                            values(p_coduser,l.codproc,'2',sysdate,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
              null;
            end;
            ins_tusrlog(p_coduser, 'tusrproc', 'coduser', p_coduser);
            ins_tusrlog(p_coduser, 'tusrproc', 'codproc', l.codproc);
            ins_tusrlog(p_coduser, 'tusrproc', 'flgauth', '2');
          end if;--if v_check = 'Y' then -- user22 : 07/08/2022 : ST11 ||
        end loop;  --for l in c_tcontrusrm loop
       
        exit;  --for k in c_tcontrusrd loop
      end if; -- if v_flgcal then
    end loop;  -- for k in c_tcontrusrd loop
  end;

  procedure ins_tusrlog( p_coduser in varchar2, p_table in varchar2, p_column in varchar2, p_descnew in varchar2, p_descold in varchar2 default null) as
    tusrlog_seqnum    number;
  begin
    begin
      select nvl(max(seqnum), 0)
        into tusrlog_seqnum
        from tusrlog
       where rcupdid = global_v_coduser
         and dteupd  = sysdate;
    end;
    if nvl(p_descold, '@#$%') <> nvl(p_descnew, '@#$%') or p_column = 'codpswd' then
      tusrlog_seqnum := tusrlog_seqnum + 1;
      begin
        insert
          into tusrlog
               (rcupdid, dteupd, seqnum, coduser, codtable, codcolmn, descold, descnew)
        values (global_v_coduser, sysdate, tusrlog_seqnum, p_coduser, upper(p_table), upper(p_column), p_descold, p_descnew);
      exception when others then
        null;
      end;
    end if;
  exception when others then
    null;--param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end ins_tusrlog;

  function get_codcomp_level(p_codcomp in varchar2) return varchar2 is
    v_codcomp         varchar2(4000 char);
    v_concat          varchar2(1000 char) := '';
    v_comlevel        number := 0;

    TYPE codcom IS TABLE OF VARCHAR2(1000 CHAR) INDEX BY BINARY_INTEGER;
      v_codcom        codcom;

  begin
    for i in 1..10 loop
      v_codcom(i) := '';
    end loop;

    begin
      select codcom1,codcom2,codcom3,codcom4,codcom5,codcom6,codcom7,codcom8,codcom9,codcom10 ,comlevel
        into v_codcom(1),v_codcom(2),v_codcom(3),v_codcom(4),v_codcom(5),v_codcom(6),v_codcom(7),v_codcom(8),v_codcom(9),v_codcom(10) ,v_comlevel
        from tcenter
       where codcomp = p_codcomp;
    exception when no_data_found then
      null;
    end;

    for i in 1..v_comlevel loop
      v_codcomp := v_codcomp||v_codcom(i);
    end loop;

    return v_codcomp;
  end;
  --
  procedure process_tsecpos(p_codcomp  in  varchar2,p_endate   in date,p_coduser in varchar2,
                            o_sum      out number  ,o_err out number  ,p_dtetim in date default sysdate) is --user36 10/05/2022 for Expired 2nd Position
    v_zupdsal       varchar2(1 char);
    v_secu          boolean;
    v_sum           number;
    v_err           number;
    v_zminlvl       number;
    v_zwrklvl       number;

    cursor c_tsecpos is
      select b.coduser,b.codcomp,a.codempid,a.codpos,e.codcomp as emp_comp
        from tsecpos a, tusrcom b, tusrprof c, temploy1 e
       where a.codempid  = c.codempid
         and b.coduser   = c.coduser
         and a.codempid  = e.codempid
         and a.codcomp   like b.codcomp
         and nvl(dtecancel,dteend) < trunc(sysdate)
         and e.codcomp   not like b.codcomp||'%'
    order by b.coduser;

  begin
    v_sum     := 0;
    v_err     := 0;
    if p_coduser is not null and p_coduser <> 'AUTO' then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
          into v_zminlvl,v_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;
    for i in c_tsecpos loop
      if p_coduser = 'AUTO' then
        v_secu := true;
      else
        v_secu := secur_main.secur2(i.codempid,p_coduser,v_zminlvl,v_zwrklvl, v_zupdsal);
      end if;
      if v_secu then
        begin
          delete tusrcom where coduser = i.coduser and codcomp = i.codcomp;

          ins_tusrlog(i.coduser, 'tusrcom', 'coduser', '', i.coduser);
          ins_tusrlog(i.coduser, 'tusrcom', 'codcomp', '', i.codcomp);

          v_sum := v_sum + 1;
        exception when others then
          v_err := v_err + 1;

          ins_errtmp(i.codempid,i.codcomp,i.codpos,null,null,v_topic9,p_coduser);

          -- insert batch process detail
          hcm_batchtask.insert_batch_detail(
            p_codapp   => global_v_batch_codapp,
            p_coduser  => p_coduser,
            p_codalw   => global_v_batch_codapp||'9',
            p_dtestrt  => p_dtetim,
            p_item01  => i.codempid,
            p_item02  => i.codcomp,
            p_item03  => i.codpos,
            p_item04  => null,
            p_item05  => null,
            p_item06  => v_topic9,
            p_item07  => p_coduser
          );
        end;
      end if; --if v_secu then
    end loop; --for i in c_tsecpos loop
    commit;
    o_sum   := v_sum;
    o_err   := v_err;
  end;
end;

/
