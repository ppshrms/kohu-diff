--------------------------------------------------------
--  DDL for Package Body HRPY46B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY46B_BATCH" as
  procedure start_process (p_codempid   in  varchar2,
                           p_codcomp    in  varchar2,
                           p_typpayroll in  varchar2,
                           p_dteyrepay  in  number,
                           p_dtemthpay  in  number,
                           p_codcurr    in  varchar2,
                           p_coduser    in  varchar2,
                           flg_exist    out boolean,
                           flg_permission out boolean) is
  begin
    indx_codempid     := p_codempid;
    indx_codcomp      := p_codcomp;
    indx_codcomp2     := p_codcomp;

    indx_codcomp    := indx_codcomp||'%';
    indx_typpayroll   := p_typpayroll;
    indx_dteyrepay    := p_dteyrepay;
    indx_dtemthpay    := p_dtemthpay;
    para_coduser      := p_coduser;
    para_codcurr      := p_codcurr;

    begin
      select get_numdec(numlvlsalst,p_coduser) numlvlst ,get_numdec(numlvlsalen,p_coduser) numlvlen
        into para_numlvlsalst,para_numlvlsalen
        from tusrprof
      where coduser = para_coduser ;
    exception when others then
      null;
    end ;
    -- create tprocount
    gen_group;
    -- create tprocemp
    gen_group_emp;
    -- create Job & Process
    gen_job;
    flg_exist := p_flg_exist;
    flg_permission := p_flg_permission;
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

  procedure gen_group_emp is
    v_numproc   number := 99;
    v_zupdsal   varchar2(50 char);

    v_flgsecu   boolean;
    v_cnt       number;
    v_rownumst  number;
    v_rownumen  number;

    cursor c_temploy1 is
      select codempid,codcomp,numlvl,typemp,codbrlc,typpayroll,codempmt
        from temploy1
       where (indx_codempid is not null  and codempid  = indx_codempid)
          or (indx_codempid is null and codcomp like indx_codcomp and typpayroll = nvl(indx_typpayroll,typpayroll))
      order by codempid;

  begin


    delete tprocemp where codapp = para_codapp and coduser = para_coduser; commit;
    for r_emp in c_temploy1 loop
      p_flg_exist := true;
        v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
      if v_flgsecu then
        p_flg_permission := true;
        begin
          insert into tprocemp(codapp,coduser,numproc,codempid)
               values         (para_codapp,para_coduser,v_numproc,r_emp.codempid);
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

  procedure gen_job is
    v_stmt      varchar2(1000 char);
    v_interval  varchar2(50 char);
    v_finish    varchar2(1 char);

    type a_number is table of number index by binary_integer;
       a_jobno  a_number;

  begin
    if indx_codempid is not null then
      para_numproc := 1;

    end if;
    for i in 1..para_numproc loop
      v_stmt := 'hrpy46b_batch.cal_process('''||para_codapp||''','''||para_coduser||''','||i||','''
                ||indx_codempid||''','''
                ||indx_codcomp2||''','''
                ||indx_typpayroll||''','
                ||indx_dteyrepay||','
                ||indx_dtemthpay||','''
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
        exception when no_data_found then
          v_finish := 'Y';
        end;
      end loop;
      if v_finish = 'Y' then
        exit;

      end if;
    end loop;
  end;

  procedure cal_process (p_codapp     in  varchar2,
                         p_coduser    in  varchar2,
                         p_numproc    in  number,
                         p_codempid   in  varchar2,
                         p_codcomp    in  varchar2,
                         p_typpayroll in  varchar2,
                         p_dteyrepay  in  number,
                         p_dtemthpay  in  number,
                         p_codcurr    in  varchar2) is

    v_exist       varchar2(1 char);
    v_secur       varchar2(1 char);
    v_flgsecu     boolean := false;
    v_stmt        varchar2(4000 char);
    v_codempid    temploy1.codempid%type;
    v_typemp      temploy1.typemp%type;
    v_numlvl      number;
    v_codbrlc     varchar2(10 char);
    v_codcompy    tcenter.codcompy%type;
    v_codtax      varchar2(10 char);
    v_execute     number;

    v_stdate      date;
    v_endate      date;
    v_codpay      tsincexp.codpay%type;
    v_found       boolean;
    v_amt         number := 0;
    v_sumrec1     number := 0;
    v_sumrec2     number := 0;
    v_zupdsal     varchar2(1 char);
    tmp_amtpay    varchar2(20 char);
    v_typincom    ttaxcur.typincom%type;
    v_err_step    varchar2(100);
    v_sqlerrm     varchar2(1000);
    v_chk_codpay  tsincexp.codpay%type;

    type v_amtpay1 is table of number index by binary_integer;
      v_amtpay      v_amtpay1;


    cursor c_emp is
      select a.codempid,b.codcomp,b.numlvl,b.typemp,b.codbrlc,b.typpayroll,b.codempmt
        from tprocemp a, temploy1 b
       where a.codempid = b.codempid
         and a.codapp   = p_codapp
         and a.coduser  = p_coduser
         and a.numproc  = p_numproc
      order by a.codempid;

    cursor c_tothpay is
      select numperiod,codpay,amtpay,codcomp,typpayroll
        from tothpay
       where codempid  = v_codempid

         and dteyrepay = p_dteyrepay - para_zyear
         and dtemthpay = p_dtemthpay;

    cursor c_tcompstn is
      select flgcps,amttaxcps,amtsvr,amtothcps,codcomp,typpayroll
        from tcompstn
       where codempid = v_codempid
         and dtevcher between v_stdate and v_endate
         and stavcher = 'F';

    cursor c_tsincexp is
      select codpay,codcomp,typpayroll,numlvl,typinc,typpayr,
             typpayt,typincexp,stddec(amtpay,codempid,para_chken) amtpay,numperiod
        from tsincexp
       where codempid = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
      order by numperiod;

    cursor c_tytdinc is
      select rowid
        from tytdinc
       where codcompy  = v_codcompy
         and dteyrepay = p_dteyrepay - para_zyear
         and codempid  = v_codempid
         and codpay    = v_codpay;

    cursor c_ttaxtab is
      select codpay,codtax
        from ttaxtab;

  begin
  --<< user22 : 23/03/2016 : STA3590240 ||
    param_codapp  := p_codapp;
    param_coduser := p_coduser;
    param_numproc := p_numproc;
  -->> user22 : 23/03/2016 : STA3590240 ||
    v_err_step := '01';-- user22 : 23/03/2016 : STA3590240 ||
    if p_dteyrepay > 2500 then
      para_zyear  := 543;
    else
      para_zyear  := 0;
    end if;
    begin
       select codpaypy1 ,codpaypy8
         into v_codtax1,v_codpay
         from tcontrpy
        where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
          and dteeffec  = (select max(dteeffec)
                             from tcontrpy
                            where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
                              and dteeffec  <= trunc(sysdate));
    exception when no_data_found then
      v_codtax1 :=  null;
      v_codpay  :=  null;
    end;

    if v_codpay is not null then
      begin
        select codtax into v_codtax
          from ttaxtab
         where codpay = v_codpay;
        v_codtax1 :=  v_codtax;
      exception when no_data_found then
        v_codtax := null;
      end;
    end if;

    v_max := 0;
    for r_ttaxtab in c_ttaxtab loop
      v_max := v_max + 1;
      v_tab_codtax(v_max) := r_ttaxtab.codtax;
    end loop;
    v_stdate  := to_date('01/'||lpad(p_dtemthpay,2,'0')||'/'||lpad((p_dteyrepay - para_zyear),4,'0'),'dd/mm/yyyy');
    v_endate  := last_day(v_stdate);
    v_sumrec1 := 0;
    v_sumrec2 := 0;
    v_err_step := '02';-- user22 : 23/03/2016 : STA3590240 ||
    for r_emp in c_emp loop
      v_codempid := r_emp.codempid;
      v_typemp   := r_emp.typemp;
      v_numlvl   := r_emp.numlvl;
      v_codbrlc  := r_emp.codbrlc;

      --?????????????(1-???????????, 3-?????????? ? ??????? 3%, 4-?????????? ? ??????? 5%, 5-?????????? ? ??????? 15%)
      begin
        select nvl(c.typincom,'1')
          into v_typincom
          from ttaxcur c
         where c.codempid	 = v_codempid
           and c.dteyrepay = (p_dteyrepay - para_zyear)
           and c.dtemthpay = p_dtemthpay
           and rownum = 1;
      exception when no_data_found then
         v_typincom  := '1';
      end;

      v_stmt := 'update tytdinc set amtpay'||p_dtemthpay||' = stdenc(0,codempid,'''||para_chken||'''), coduser = '''||para_coduser||''''||
                ' where dteyrepay = '||(p_dteyrepay - para_zyear)||
                ' and codempid = '''||v_codempid||'''';

      v_execute := execute_delete(v_stmt);

      --pnd1
      delete ttaxinc
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay;

      --pnd3
      delete tinctxpnd
       where codempid	 = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay;

      delete tsincexp
       where codempid  =  v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and flgslip   = '2';

      for r_tothpay in c_tothpay loop
        begin
          select typemp,numlvl,codbrlc into v_typemp,v_numlvl,v_codbrlc
            from ttaxcur
           where codempid  =  v_codempid
             and dteyrepay = (p_dteyrepay - para_zyear)
             and dtemthpay = p_dtemthpay
             and numperiod = r_tothpay.numperiod;
        exception when no_data_found then null;
        end;

        upd_tsincexp(v_codempid,r_tothpay.codpay,p_dteyrepay,
                     p_dtemthpay,r_tothpay.numperiod,r_tothpay.codcomp,
                     r_tothpay.typpayroll,v_typemp,v_numlvl,
                     v_codbrlc,r_tothpay.amtpay,r_emp.codempmt,
                     p_coduser);

      end loop; -- for tothpay

      for r_tcompstn in c_tcompstn loop
        begin
          select typemp,numlvl,codbrlc into v_typemp,v_numlvl,v_codbrlc
            from ttaxcur
           where codempid  =  v_codempid
             and dteyrepay = (p_dteyrepay - para_zyear)
             and dtemthpay = p_dtemthpay
             and numperiod = 1;
        exception when no_data_found then null;
        end;

        if v_codpay is not null then
          v_amt       := nvl(stddec(r_tcompstn.amtsvr,v_codempid,para_chken),0) + nvl(stddec(r_tcompstn.amtothcps,v_codempid,para_chken),0);
          tmp_amtpay  := stdenc(v_amt,v_codempid,para_chken);
          upd_tsincexp(v_codempid,v_codpay,p_dteyrepay,
                       p_dtemthpay,1,r_tcompstn.codcomp,
                       r_tcompstn.typpayroll,v_typemp,v_numlvl,
                       v_codbrlc,tmp_amtpay,r_emp.codempmt,
                       p_coduser);
          if v_codtax1 is not null then
            upd_tsincexp(v_codempid,v_codtax1,p_dteyrepay,
                         p_dtemthpay,1,r_tcompstn.codcomp,
                         r_tcompstn.typpayroll,v_typemp,v_numlvl,
                         v_codbrlc,r_tcompstn.amttaxcps,r_emp.codempmt,
                         p_coduser);
          end if;
          v_sumrec1 := v_sumrec1 + 1;
        end if;
      end loop; -- for tcompstn

      for r_tsincexp in c_tsincexp loop
        for i in 1..12 loop
          v_amtpay(i) := 0;
        end loop;
        v_amtpay(p_dtemthpay) := r_tsincexp.amtpay;
        v_found    := false;
        v_codpay   := r_tsincexp.codpay;
        v_codcompy := hcm_util.get_codcomp_level(r_tsincexp.codcomp,1);

        if nvl(v_typincom,'1') <> '1' then
           r_tsincexp.typinc  := null;
        end if;
        for r_tytdinc in c_tytdinc loop
          v_found := true;
          update  tytdinc
            set   amtpay1   = stdenc(stddec(amtpay1,codempid,para_chken) + v_amtpay(1),codempid,para_chken),
                  amtpay2   = stdenc(stddec(amtpay2,codempid,para_chken) + v_amtpay(2),codempid,para_chken),
                  amtpay3   = stdenc(stddec(amtpay3,codempid,para_chken) + v_amtpay(3),codempid,para_chken),
                  amtpay4   = stdenc(stddec(amtpay4,codempid,para_chken) + v_amtpay(4),codempid,para_chken),
                  amtpay5   = stdenc(stddec(amtpay5,codempid,para_chken) + v_amtpay(5),codempid,para_chken),
                  amtpay6   = stdenc(stddec(amtpay6,codempid,para_chken) + v_amtpay(6),codempid,para_chken),
                  amtpay7   = stdenc(stddec(amtpay7,codempid,para_chken) + v_amtpay(7),codempid,para_chken),
                  amtpay8   = stdenc(stddec(amtpay8,codempid,para_chken) + v_amtpay(8),codempid,para_chken),
                  amtpay9   = stdenc(stddec(amtpay9,codempid,para_chken) + v_amtpay(9),codempid,para_chken),
                  amtpay10  = stdenc(stddec(amtpay10,codempid,para_chken) + v_amtpay(10),codempid,para_chken),
                  amtpay11  = stdenc(stddec(amtpay11,codempid,para_chken) + v_amtpay(11),codempid,para_chken),
                  amtpay12  = stdenc(stddec(amtpay12,codempid,para_chken) + v_amtpay(12),codempid,para_chken),
                  codcomp   = r_tsincexp.codcomp,
                  typpayroll = r_tsincexp.typpayroll,
                  typinc    = r_tsincexp.typinc,
                  typpayr   = r_tsincexp.typpayr,
                  typpayt   = r_tsincexp.typpayt,
                  typpay    = r_tsincexp.typincexp,
                  coduser   = p_coduser
            where rowid = r_tytdinc.rowid;
        end loop;
        if not v_found then
          insert into tytdinc(codcompy,dteyrepay,codempid,
                              codpay,amtpay1,amtpay2,
                              amtpay3,amtpay4,amtpay5,
                              amtpay6,amtpay7,amtpay8,
                              amtpay9,amtpay10,amtpay11,
                              amtpay12,codcomp,typpayroll,
                              typinc,typpayr,typpayt,
                              typpay,coduser,codcreate)
                  values     (v_codcompy,(p_dteyrepay - para_zyear),v_codempid,
                              v_codpay,stdenc(v_amtpay(1),v_codempid,para_chken),stdenc(v_amtpay(2),v_codempid,para_chken),
                              stdenc(v_amtpay(3),v_codempid,para_chken),stdenc(v_amtpay(4),v_codempid,para_chken),stdenc(v_amtpay(5),v_codempid,para_chken),
                              stdenc(v_amtpay(6),v_codempid,para_chken),stdenc(v_amtpay(7),v_codempid,para_chken),stdenc(v_amtpay(8),v_codempid,para_chken),
                              stdenc(v_amtpay(9),v_codempid,para_chken),stdenc(v_amtpay(10),v_codempid,para_chken),stdenc(v_amtpay(11),v_codempid,para_chken),
                              stdenc(v_amtpay(12),v_codempid,para_chken),r_tsincexp.codcomp,r_tsincexp.typpayroll,
                              r_tsincexp.typinc,r_tsincexp.typpayr,r_tsincexp.typpayt,
                              r_tsincexp.typincexp,p_coduser,p_coduser);
        end if;


        if nvl(v_typincom,'1') = '1' then
          upd_ttaxinc(v_codempid,p_dteyrepay,p_dtemthpay,
                      r_tsincexp.numperiod,v_codpay,r_tsincexp.codcomp,
                      r_tsincexp.typpayroll,r_tsincexp.numlvl,r_tsincexp.typincexp,
                      r_tsincexp.typinc,r_tsincexp.typpayt,r_tsincexp.amtpay,p_coduser,v_typincom);
        else

            begin
              select codpay
                into v_chk_codpay
                from tinexinf
               where codpay = v_codpay
                 and (typincpnd is not null or typincpnd50 is not null);
                exception when no_data_found then 
                    v_chk_codpay := null;
            end;

             if v_chk_codpay is not null then
                 upd_tinctxpnd(v_codempid,p_dteyrepay,p_dtemthpay,
                               r_tsincexp.numperiod,v_codpay,r_tsincexp.codcomp,
                               r_tsincexp.typpayroll,r_tsincexp.numlvl,r_tsincexp.typincexp,
                               r_tsincexp.typinc,r_tsincexp.typpayt,r_tsincexp.amtpay,
                               p_coduser);
             end if;                
        end if;
        v_sumrec2 := v_sumrec2 + 1;
      end loop; -- for tsincexp
    end loop; -- c_emp

    update tprocount
       set qtyproc  = nvl(qtyproc,0) + v_sumrec2,
           qtyerr   = nvl(qtyerr,0) + v_sumrec1,
           flgproc  = 'Y'
     where codapp  = p_codapp
       and coduser = p_coduser
       and numproc = p_numproc ;
    commit;

  exception when others then
      v_sqlerrm := sqlerrm ;
    update tprocount
       set qtyproc  = nvl(qtyproc,0) + v_sumrec2,
           qtyerr   = nvl(qtyerr,0) + v_sumrec1,
           codempid = v_codempid ,
           dteupd   = sysdate,
           Flgproc  = 'E',
           remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,500)
     where codapp  = p_codapp
       and coduser = p_coduser
       and numproc = p_numproc ;
     commit;
  -->> user22 : 23/03/2016 : STA3590240 ||
  end;

  procedure upd_tsincexp (p_codempid    in varchar2,
                          p_codpay      in varchar2,
                          p_dteyrepay   in number,
                          p_dtemthpay   in number,
                          p_numperiod   in number,
                          p_codcomp     in varchar2,
                          p_typpayroll  in varchar2,
                          p_typemp      in varchar2,
                          p_numlvl      in number,
                          p_codbrlc     in varchar2,
                          p_amtpay      in varchar2,
                          p_codempmt    in varchar2,
                          p_coduser     in varchar2) is

      v_exist     boolean := false;

      tmp_amt     number:= 0;
      v_codcurr   varchar2(4 char);
      v_sqlerrm   varchar2(1000);

    cursor c_tsincexp is
      select rowid,stddec(amtpay,p_codempid,para_chken) amtpay
        from tsincexp
       where codempid  = p_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay    = p_codpay
         and flgslip   = '2';


    cursor c_tinexinf is
      select typinc,typpayr,typpayt,typpay
        from tinexinf
       where codpay = p_codpay;

  begin

    for r_tinexinf in c_tinexinf loop
      for r_tsincexp in c_tsincexp loop
        v_exist := true;

        tmp_amt := nvl(r_tsincexp.amtpay,0) + stddec(p_amtpay,p_codempid,para_chken);
        update  tsincexp

          set   amtpay      = stdenc(tmp_amt,p_codempid,para_chken),
                typinc      = r_tinexinf.typinc,
                typpayr     = r_tinexinf.typpayr,
                typpayt     = r_tinexinf.typpayt,
                typincexp   = r_tinexinf.typpay,
                codcurr     = para_codcurr,
                numlvl      = p_numlvl,
                typpayroll  = p_typpayroll,
                codcomp     = p_codcomp,
                typemp      = p_typemp,
                codbrlc     = p_codbrlc,
                coduser     = p_coduser,
                dteupd      = trunc(sysdate),
                amtpay_e    = stdenc(tmp_amt,p_codempid,para_chken),
                codcurr_e   = para_codcurr,
                codempmt    = p_codempmt
          where rowid = r_tsincexp.rowid;
      end loop;
      if not v_exist then
        insert into tsincexp(dteyrepay,codempid,codpay,
                             dtemthpay,numperiod,flgslip,
                             amtpay,codcomp,typinc,
                             typpayr,typpayt,typincexp,
                             coduser,typpayroll,typemp,
                             codbrlc,codcurr,numlvl,
                             dteupd,amtpay_e,codcurr_e,
                             codempmt,codcreate )
            values          ((p_dteyrepay - para_zyear),p_codempid,p_codpay,
                              p_dtemthpay,p_numperiod,'2',
                              p_amtpay,p_codcomp,r_tinexinf.typinc,
                              r_tinexinf.typpayr,r_tinexinf.typpayt,r_tinexinf.typpay,
                              p_coduser,p_typpayroll,p_typemp,
                              p_codbrlc,para_codcurr,p_numlvl,
                              trunc(sysdate),p_amtpay,para_codcurr,
                              p_codempmt,p_coduser);
      end if;
    end loop;
  --<< user22 : 23/03/2016 : STA3590240 ||
  exception when others then
    v_sqlerrm := sqlerrm ;
    update tprocount
       set codempid = p_codempid ,
           dteupd   = sysdate,
           Flgproc  = 'E',
           remark   = substr('Error Step : A1'||' - '||v_sqlerrm,1,500)
     where codapp  = param_codapp
       and coduser = param_coduser
       and numproc = param_numproc;
     commit;
  -->> user22 : 23/03/2016 : STA3590240 ||
  end;


  procedure upd_ttaxinc (p_codempid     in varchar2,
                         p_dteyrepay    in number,
                         p_dtemthpay    in number,
                         p_numperiod    in number,
                         p_codpay       in varchar2,
                         p_codcomp      in varchar2,
                         p_typpayroll   in varchar2,
                         p_numlvl       in number,
                         p_typpay       in varchar2,
                         p_typinc       in varchar2,
                         p_typpayt      in varchar2,
                         p_amtpay       in number,
                         p_coduser      in varchar2,
                         v_typincom      in varchar2) is


    v_exist       boolean := false;
    v_typinc      varchar2(4 char);
    v_amtinc      number := 0;
    v_amttax      number := 0;
    tmp_amtinc    number := 0;
    tmp_amttax    number := 0;
    v_sqlerrm     varchar2(1000);

    cursor c_ttaxinc is
      select rowid,stddec(amtinc,p_codempid,para_chken) amtinc,
             stddec(amttax,p_codempid,para_chken) amttax
        from ttaxinc

       where codempid  = p_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and typinc    = v_typinc
         and typpayt   = p_typpayt;

  begin

    v_typinc := p_typinc;
    if v_typinc is not null then

      if p_typpay = '6' then

        v_amttax := p_amtpay;
        v_amtinc := 0;
      else
        v_amtinc := p_amtpay;
        v_amttax := 0;
      end if;

      if v_amtinc <> 0 and p_typpay in ('4','5') then
        v_amtinc := v_amtinc * -1;
      end if;

      for r_ttaxinc in c_ttaxinc loop
        v_exist := true;

         tmp_amtinc  := nvl(r_ttaxinc.amtinc,0) + v_amtinc;
         tmp_amttax  := nvl(r_ttaxinc.amttax,0) + v_amttax;
        update  ttaxinc
          set   typpayt     = p_typpayt,
                amtinc      = stdenc(tmp_amtinc,p_codempid,para_chken),
                amttax      = stdenc(tmp_amttax,p_codempid,para_chken),
                codcomp     = p_codcomp,
                typpayroll  = p_typpayroll,
                numlvl      = p_numlvl,
                coduser     = p_coduser,
                dteupd      = trunc(sysdate),
                typincom  =  v_typincom
          where rowid = r_ttaxinc.rowid;
      end loop;

      if not v_exist then
        insert into ttaxinc(codempid,dteyrepay,dtemthpay,
                            numperiod,typinc,typpayt,
                            amtinc,amttax,codcomp,
                            typpayroll,numlvl,coduser,
                            dteupd,typincom,
                            codcreate
                            )
                  values   (p_codempid,(p_dteyrepay - para_zyear),p_dtemthpay,
                            p_numperiod,v_typinc,p_typpayt,
                            stdenc(v_amtinc,p_codempid,para_chken),stdenc(v_amttax,p_codempid,para_chken),p_codcomp,
                            p_typpayroll,p_numlvl,p_coduser,
                            trunc(sysdate),v_typincom,
                            p_coduser
                            );
      end if;
    end if;
  --<< user22 : 23/03/2016 : STA3590240 ||
  exception when others then
    v_sqlerrm := sqlerrm ;
    update tprocount
       set codempid = p_codempid ,
           dteupd   = sysdate,
           Flgproc  = 'E',
           remark   = substr('Error Step : B1'||' - '||v_sqlerrm,1,500)
     where codapp  = param_codapp
       and coduser = param_coduser
       and numproc = param_numproc;
     commit;
  -->> user22 : 23/03/2016 : STA3590240 ||
  end;

  procedure upd_tinctxpnd (p_codempid	    in varchar2,
                           p_dteyrepay    in number,
                           p_dtemthpay    in number,
                           p_numperiod	  in number,
                           p_codpay		    in varchar2,
                           p_codcomp		  in varchar2,
                           p_typpayroll	  in varchar2,
                           p_numlvl		    in number,
                           p_typpay		    in varchar2,
                           p_typinc		    in varchar2,
                           p_typpayt	    in varchar2,
                           p_amtpay   	  in number,
                           p_coduser      in varchar2) is

  v_exist			  boolean := false;
  v_typinc   	  varchar2(4 char);
  v_amtinc   	  number := 0;
  v_amttax   	  number := 0;
  tmp_amtinc   	number := 0;
  tmp_amttax   	number := 0;

  cursor c_tinctxpnd is
    select rowid,stddec(amtinc,p_codempid,para_chken) amtinc,stddec(amttax,p_codempid,para_chken) amttax
      from tinctxpnd
     where codempid	 = p_codempid
       and dteyrepay = p_dteyrepay
       and dtemthpay = p_dtemthpay
       and numperiod = p_numperiod
       and codpay	 = p_codpay;
  begin
    begin
      select typincpnd
        into v_typinc
        from tinexinf
       where codpay	= p_codpay;
    exception when no_data_found then
         v_typinc    := null;
    end;
    if v_typinc is not null then
      if p_typpay = '6' then
        v_amttax := p_amtpay;
        v_amtinc := 0;
      else
        v_amtinc := p_amtpay;
        v_amttax := 0;
      end if;

      if v_amtinc <> 0 and p_typpay in ('4','5') then
        v_amtinc := v_amtinc * -1;
      end if;
      for r_tinctxpnd in c_tinctxpnd loop
        v_exist	:= true;
        tmp_amtinc	 :=	nvl(r_tinctxpnd.amtinc,0) + v_amtinc;
        tmp_amttax	 :=	nvl(r_tinctxpnd.amttax,0) + v_amttax;

        update tinctxpnd
           set typinc			=	v_typinc,
               amtinc			=	stdenc(tmp_amtinc,p_codempid,para_chken),
               amttax			=	stdenc(tmp_amttax,p_codempid,para_chken),
               codcomp		    =	p_codcomp,
               typpayroll	    =	p_typpayroll,
               numlvl			=	p_numlvl,
               coduser		    =   p_coduser,
               dteupd           =   trunc(sysdate)
         where rowid            =   r_tinctxpnd.rowid;
      end loop;

      if not v_exist then
        insert into tinctxpnd(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                            typinc,amtinc,amttax,
                            codcomp,typpayroll,numlvl,codcreate,dtecreate,coduser,dteupd)
                  values   (p_codempid,(p_dteyrepay - para_zyear),p_dtemthpay,p_numperiod,p_codpay,
                            v_typinc,stdenc(v_amtinc,p_codempid,para_chken),stdenc(v_amttax,p_codempid,para_chken),
                            p_codcomp,p_typpayroll,p_numlvl,p_coduser,trunc(sysdate),p_coduser,trunc(sysdate));
      end if;
    end if; 	 --if v_typinc is not null then
  end;
end hrpy46b_batch;

/
