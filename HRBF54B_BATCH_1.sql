--------------------------------------------------------
--  DDL for Package Body HRBF54B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF54B_BATCH" as

/*
	code by 	  : User14/Krisanai Mokkapun
   date        : 29/01/2020 11:01 #4133
*/

procedure start_process (p_codcomp 		in	varchar2,
                                     p_typpayrol		in	varchar2,
                                     p_codempid		in	varchar2,
                                     p_numperiod  in	number,
                                     p_dtemthpay  in	number,
                                     p_dteyrepay  in	number,
                                     p_flgbonus   in	varchar2,
                                     p_coduser		in	varchar2) is

     v_codcomp        temploy1.codcomp%type;
     v_typpayroll       temploy1.typpayroll%type;

begin
  indx_codcomp      := p_codcomp;
  indx_typpayroll      := p_typpayrol;
  indx_codempid      := p_codempid;
  indx_numperiod     := p_numperiod;
  indx_dtemthpay    := p_dtemthpay;
  indx_dteyrepay     := p_dteyrepay;
  indx_flgbonus       := p_flgbonus;
  para_coduser	 	  := p_coduser;

  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  if p_codempid is not null then
         begin
           select codcomp,typpayroll
             into v_codcomp,  v_typpayroll
             from temploy1
            where codempid = indx_codempid;
         exception when no_data_found then null;
          v_codcomp  := null;
          v_typpayroll  := null;
         end;
 end if;

  if p_codempid is null then
     v_codcomp   := indx_codcomp;
     v_typpayroll  := indx_typpayroll;
  end if;

  begin
--<<user14 12/01/2564   select  dtestrt,dteend
     select  dtestrt, dtepaymt
        into  para_dtestrt ,para_dteend
       from tdtepay
    where codcompy   = hcm_util.get_codcomp_level(v_codcomp, '1')
        and typpayroll    = v_typpayroll
        and dteyrepay   = indx_dteyrepay - para_zyear
        and dtemthpay  = indx_dtemthpay
        and numperiod   = indx_numperiod;
   exception when no_data_found then
          para_dtestrt     := null;
          para_dteend    := null;
   end ;

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
  -- create Job
  gen_job;

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
  v_numproc		  number := 99;
  v_zupdsal		  varchar2(50 char);
  v_flgsecu		  boolean;
  v_cnt				  number;
  v_rownumst	  number;
  v_rownumen	  number;


      cursor c_tloaninf1 is
            select a.codempid ,b.codcomp,b.numlvl
            from   tloaninf a,temploy1 b
            where  a.codempid = b.codempid
            and    b.codcomp like indx_codcomp||'%'
            and    b.typpayroll =  nvl( indx_typpayroll,b.typpayroll)
            and    a.codempid = nvl( indx_codempid,a.codempid)
            and    a.dteissue  <= para_dteend
            and    a.staappr    = 'Y'
            and    a.stalon     <> 'C'
            and    (a.dteaccls >= para_dtestrt  or a.dteaccls is null)
            and a.numcont not in (select c.numcont
                                             from tloanpay c
                                             where c.dteyrepay =indx_dteyrepay  - para_zyear
                                             and c.dtemthpay = indx_dtemthpay
                                             and c.numperiod = indx_numperiod
                                             and c.flgtranpy = 'Y')
            order by a.dtelonst;

begin

  delete tprocemp where codapp = para_codapp and coduser = para_coduser; commit;
  for r_emp in c_tloaninf1 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,  codempid)
                          values   (para_codapp,para_coduser,v_numproc,   r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c_tloaninf1 loop
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
  v_stmt			varchar2(1000 char);
  v_interval	varchar2(50 char);
  v_finish		varchar2(1 char);

  type a_number is table of number index by binary_integer;
     a_jobno	a_number;

begin
  if para_numproc > 1 then
  for i in 1..para_numproc loop
    v_stmt := 'HRBF54B_batch.set_parameter ('||para_zyear||','''||to_char(para_dtestrt,'dd/mm/yyyy')||''','''||to_char(para_dteend,'dd/mm/yyyy')||''','''||para_coduser||''') ; '||
                 ' HRBF54B_batch.cal_process('''||para_codapp||''','''||para_coduser||''','||i||','''
                 ||indx_codcomp||''','''
                 ||indx_typpayroll||''','''
                 ||indx_codempid||''','
                 ||indx_numperiod||','
                 ||indx_dtemthpay||','
                 ||indx_dteyrepay||','''
                 ||indx_flgbonus||''');';

    dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
  end loop;  --for i in 1..para_numproc loop

else
      HRBF54B_batch.set_parameter (para_zyear,to_char(para_dtestrt,'dd/mm/yyyy'),to_char(para_dteend,'dd/mm/yyyy'),para_coduser) ;
      HRBF54B_batch.cal_process(para_codapp,para_coduser,1,
                 indx_codcomp,
                 indx_typpayroll,
                 indx_codempid,
                 indx_numperiod,
                 indx_dtemthpay,
                 indx_dteyrepay,
                 indx_flgbonus );
end if;

    v_finish := 'N';

    loop
      for i in 1..para_numproc loop
        dbms_lock.sleep(5);
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
procedure cal_process ( p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number,
                                  p_flgbonus     in varchar2) is

  v_codempid		   temploy1.codempid%type;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

      cursor c_tloaninf  is
            select a.numcont,b.codempid,b.codcomp,b.numlvl,
                      b.staemp,b.dteeffex-1 before_dteffex
            from   tloaninf a,temploy1 b
          where  a.codempid = b.codempid
              and  a.codempid    = v_codempid
              and  a.dteissue  <= para_dteend
              and  a.staappr    = 'Y'
              and    a.stalon     <> 'C'
              and  (a.dteaccls >= para_dtestrt  or a.dteaccls is null)
              and a.numcont not in (select c.numcont
                                             from tloanpay c
                                             where c.dteyrepay =p_dteyrepay  - para_zyear
                                             and c.dtemthpay = p_dtemthpay
                                             and c.numperiod = p_numperiod
                                             and c.flgtranpy = 'Y')
            order by a.dtelonst;

begin

  indx_numperiod     := p_numperiod;
  indx_dtemthpay    := p_dtemthpay;
  indx_dteyrepay     := p_dteyrepay;
  indx_codcomp      := p_codcomp;
  indx_typpayroll      := p_typpayroll;
  indx_codempid      := p_codempid;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
    v_codempid  := i.codempid;

          for j in c_tloaninf  loop

             if j.before_dteffex >= para_dtestrt and j.before_dteffex <= para_dteend then
                   process_loan(j.numcont, para_dtestrt ,j.before_dteffex, p_flgbonus);
             elsif j.before_dteffex > para_dteend then
                   process_loan(j.numcont, para_dtestrt , para_dteend , p_flgbonus);
             elsif j.before_dteffex is null then
                  process_loan(j.numcont, para_dtestrt , para_dteend , p_flgbonus);
             end if;
          end loop; -- for c_ttaxcur
  end loop;   -- for emp

	update tprocount
     set qtyerr   = nvl(qtyerr,0) + v_numerr,
         QTYPROC  = nvl(QTYPROC,0) + v_numrec,
         flgproc  = 'Y' ,
         codempid = null,
         remark   = null
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc ;

commit;
exception when others then
  v_sqlerrm := sqlerrm ;
 	update tprocount
     set qtyerr   = nvl(qtyerr,0) + v_numerr,
         codempid = v_codempid ,
         dteupd   = sysdate,
         flgproc  = 'E',
         remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,500)
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc ;
  commit;

end;  --procedure cal_process

procedure process_loan (p_numcont   	in  varchar2,
                                   p_dtestrt       in   date,
                                   p_dteend       in  date,
                                   p_flgbonus     in  varchar2) is

    v_rateilon            tloanadj.ratelonn%type;
    v_formulan          tloanadj.formulan%type;
    v_statementn      tloanadj.statementn%type;
    v_dteeffec          date;
    v_dtelcalpay          date;

    v_dtestrcal          date;
    v_dteendcal         date;
    v_numseq           number;
    v_amtint             number;
    v_intpay             number;
    v_inststpay         number;
    v_amtlpay           number;
    v_amtintovr         number;

    v_amtpint           number;
    v_amtpfin           number;

    v_amtitotflat_new       number;
    v_amtiflat_new           number;

    v_adjust            varchar2(1);
    v_statment         tloanadj.formulan%type;
    v_typpayroll      temploy1.typpayroll%type;
    v_codcomp      temploy1.codcomp%type;

        cursor c_tloaninf is
            select a.rowid,
                      a.numcont,a.codempid,
                      a.typintr,a.amtnpfin,a.rateilon,a.amttlpay,
                      a.qtyperiod, nvl(a.amtintovr,0) amtintovr ,a.amtpflat, a.amtiflat, a.qtyperip,
                      a.amtpaybo,
                      a.dtestcal, a.dtelcal,a.dtelpay,
                      b.codcomp,b.typpayroll
              from tloaninf a ,temploy1 b
            where a.codempid = b.codempid
                and a.numcont = p_numcont
                and ( (a.dtelcal is null) or (a.dtelpay is null) or (v_dtelcalpay > a.dtelpay) )
        order by  a.numcont;

         cursor c_tloanadj is
         select a.dteeffec,a.dteeffeco,   a.ratelono, a.ratelonn,
                   a.formulao, a.formulan,  a.statemento,  a.statementn,
                   a.qtypayn,  a.qtypayo
           from tloanadj a
         where a.numcont = p_numcont
             and a.dteeffec between p_dtestrt  and p_dteend
             and a.typtran = '4'
      order by a.numcont, a.dteeffec, a.dteadjust;

begin

  if indx_typpayroll is not null then
     v_typpayroll := indx_typpayroll;
     v_codcomp := indx_codcomp;
  else
    begin
      select typpayroll,codcomp
        into v_typpayroll,v_codcomp
        from temploy1
       where codempid = indx_codempid;
    exception when no_data_found then
        v_typpayroll := null;
    end;
  end if;

  begin
    select dtepaymt 
      into v_dtelcalpay
      from tdtepay
     where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
       and numperiod = indx_numperiod
       and typpayroll = v_typpayroll
       and dtemthpay = indx_dtemthpay
       and dteyrepay = indx_dteyrepay;
    exception when others then
   null;
  end;

      for i in c_tloaninf loop
            delete ttrepayh where numcont = p_numcont and dtestrt >=  p_dtestrt;
            --delete tloanpay where numcont = p_numcont and dterepmt >=  p_dtestrt;
            delete tloanpay where numcont = p_numcont
            and dterepmt >=  p_dtestrt and typtran = '1';

            v_dtestrcal  := null;
            v_dteendcal := null;
            v_amtiflat_new     := null;
            v_amtitotflat_new  := null;
            v_numseq   := 0;
            v_amtint     := 0;

            v_rateilon        := null;
            v_formulan      := null;
            v_statementn  := null;
            v_dteeffec      := null;
            v_numerr   := 400;
            v_adjust     := 'N';

            for j in c_tloanadj loop
                  if (j.ratelono <> j.ratelonn)  or  (j.formulao  <> j.formulan) then
                              if i.typintr = '1' then --(Effective Rate)​​​​​​
                                   if v_adjust = 'N' then
                                            begin
                                               select max(dteend) + 1 into v_dtestrcal
                                                 from ttrepayh
                                               where numcont = p_numcont ;
                                               exception when no_data_found then
                                                       v_dtestrcal  := null;
                                             end;

                                             if v_dtestrcal is null  then
                                                v_dtestrcal := i.dtestcal;
                                             end if;
                                             v_dteendcal  := j.dteeffec - 1;

                                             v_numerr   := 450;
                                             v_amtint   := round((((v_dteendcal - v_dtestrcal) + 1) / 365) *  (j.ratelono / 100) *  i.amtnpfin,2);
                                             v_numseq := v_numseq + 1;
                                             insert into ttrepayh (numcont,dtestrt,dteend,numseq,
                                                                          amtprinc,amtintrest,rateilon,amtintst,
                                                                          numperiod,dtemthpay,dteyrepay,
                                                                          codcreate,coduser)
                                                             values (i.numcont ,v_dtestrcal, v_dteendcal,  v_numseq,
                                                                         i.amtnpfin , v_amtint , j.ratelono,  i.amtintovr,
                                                                         null,null,null,
                                                                         para_coduser,para_coduser);
                                       v_adjust := 'Y';
                                   end if;

                                     if v_adjust = 'Y' then
                                         v_dtestrcal   := j.dteeffec;
                                         v_dteendcal  := null;
                                         begin
                                                select min(a.dteeffec) - 1 into v_dteendcal
                                                 from tloanadj a
                                                where a.numcont = p_numcont
                                                and a.dteeffec > v_dtestrcal
                                                and a.dteeffec between p_dtestrt  and p_dteend
                                                and a.typtran = '4';
                                            exception when no_data_found then
                                                  v_dteendcal  := null;
                                         end;

                                         if v_dteendcal is null then
                                             v_dteendcal  := p_dteend;
                                         end if;

                                          v_numerr   := 500;
                                          v_amtint   := round((((v_dteendcal - v_dtestrcal) + 1) / 365) *  (j.ratelonn / 100) *  i.amtnpfin,2);
                                          v_numseq := v_numseq + 1;
                                          insert into ttrepayh (numcont,dtestrt,dteend,numseq,
                                                                       amtprinc,amtintrest,rateilon,amtintst,
                                                                       numperiod,dtemthpay,dteyrepay,
                                                                       codcreate,coduser)
                                                          values (i.numcont ,v_dtestrcal, v_dteendcal,  v_numseq,
                                                                      i.amtnpfin , v_amtint , nvl(j.ratelonn,j.ratelono) ,  i.amtintovr,
                                                                      null,null,null,
                                                                      para_coduser,para_coduser);

                                     end if;
                              elsif i.typintr in ('2','3') then--(Fixed Rate)​​​​​​
                                         v_adjust := 'Y';
                                         v_dtestrcal   := j.dteeffec;
                                         v_dteendcal  := null;
                                         begin
                                                select min(a.dteeffec) - 1 into v_dteendcal
                                                 from tloanadj a
                                                where a.numcont = p_numcont
                                                and a.dteeffec > v_dtestrcal
                                                and a.dteeffec between p_dtestrt  and p_dteend
                                                and a.typtran = '4';
                                            exception when no_data_found then
                                                  v_dteendcal  := null;
                                         end;
                                         if v_dteendcal is null then
                                             v_dteendcal  := p_dteend;
                                         end if;

                                         if (j.ratelono <> j.ratelonn)  then
                                            v_intpay             := i.amtnpfin * (j.ratelonn/12/100) * (i.qtyperiod - nvl(i.qtyperip,0) );
                                            v_amtitotflat_new := i.amtpflat + v_intpay;
                                            v_amtiflat_new     := v_amtitotflat_new /(i.qtyperiod - nvl(i.qtyperip,0) );
                                         end if;

                                         v_numerr   := 550;
                                         if i.typintr = '2'  and (j.formulao  <> j.formulan) then
                                                v_statment := j.formulan;
                                                v_statment := replace(v_statment, '[A]', i.amtnpfin);
                                                v_statment := replace(v_statment, '[R]', nvl(j.ratelonn,j.ratelono)/100  );
                                                v_statment := replace(v_statment, '[T]', i.qtyperiod);
                                                v_statment := replace(v_statment, '[P]', (i.qtyperiod - i.qtyperip));
                                                v_statment := 'select '||v_statment||' from dual';
                                                v_statment := replace(v_statment,'{','');
                                                v_statment := replace(v_statment,'}','');

                                                v_amtiflat_new    := execute_qty(v_statment);
                                                v_amtitotflat_new := v_amtiflat_new * (i.qtyperiod - nvl(i.qtyperip,0) );
                                                v_amtitotflat_new := v_amtitotflat_new + i.amtpflat;
                                         end if; --if (j.formulao  <> j.formulan) then

                                         v_amtint   :=  v_amtiflat_new;
                                         v_numseq := v_numseq + 1;
                                          insert into ttrepayh (numcont,dtestrt,dteend,numseq,
                                                                       amtprinc,amtintrest,rateilon,amtintst,
                                                                       numperiod,dtemthpay,dteyrepay,
                                                                       codcreate,coduser)
                                                          values (i.numcont ,v_dtestrcal, v_dteendcal,  v_numseq,
                                                                      i.amtnpfin , v_amtint , nvl(j.ratelonn,j.ratelono),  i.amtintovr,
                                                                      null,null,null,
                                                                      para_coduser,para_coduser);
                              end if;  --if i.typintr = '1' then

                              v_rateilon        := j.ratelonn;
                              v_formulan      := j.formulan;
                              v_statementn  := j.statementn;
                              v_dteeffec      := j.dteeffec;
                  end if; --if (a.ratelono <> a.ratelonn)
            end loop;  --for j in c_tloanadj loop

            if v_adjust = 'N' then
                  begin
                    select max(dteend) + 1 into v_dtestrcal
                      from ttrepayh
                    where numcont = p_numcont ;
                    exception when no_data_found then
                            v_dtestrcal  := null;
                  end;

                  if v_dtestrcal is null  then
                     v_dtestrcal := i.dtestcal;
                  end if;
                  v_dteendcal  := p_dteend;

                  v_numerr   := 600;
                   if i.typintr = '1' then--(Effective Rate)​​​​​​
                        v_amtint   := round((((v_dteendcal - v_dtestrcal) + 1) / 365) *  (i.rateilon / 100) *  i.amtnpfin,2);
                   elsif i.typintr in ( '2','3') then--(Fixed Rate)​​​​​​
                        v_amtint   := i.amtiflat;
                   end if;

                     v_numseq := v_numseq + 1;
                     insert into ttrepayh (numcont,dtestrt,dteend,numseq,
                                                  amtprinc,amtintrest,rateilon,amtintst,
                                                  numperiod,dtemthpay,dteyrepay,
                                                  codcreate,coduser)
                                     values (i.numcont ,v_dtestrcal, v_dteendcal,  v_numseq,
                                                 i.amtnpfin , v_amtint , i.rateilon,  i.amtintovr,
                                                 null,null,null,
                                                 para_coduser,para_coduser);
            end if;  --if v_adjust = 'N' then

            if p_flgbonus = 'Y' then
               v_amtlpay  := i.amtpaybo;
            else
               v_amtlpay  := i.amttlpay;  --i.amtnpfin
            end if;
            v_amtintovr  := nvl(i.amtintovr,0);
            v_inststpay   := v_amtintovr + nvl(v_amtint,0);

--<<user14--Error Program #4133 error last period
               v_amtlpay  := least(v_amtlpay, (nvl(i.amtnpfin,0) + v_inststpay) );
-->>user14--Error Program #4133 error last period

            if v_amtlpay > nvl(v_inststpay,0) then
               v_amtpfin   :=  v_amtlpay - v_inststpay;  --จ่ายต่องวด - ดอกเบี้ยที่คำนวณได้
               v_amtpint   :=  v_inststpay;
            else
               v_amtpfin    :=  0;
               v_amtpint    :=  v_amtlpay;
               v_amtintovr  := nvl(i.amtintovr,0) - v_amtpint;
            end if;
            v_numerr   := 650;
            v_numrec := v_numrec + 1 ;
            insert into tloanpay (numcont,dterepmt,typtran,codempid,
                                          codcomp,typpayroll,typpay,numperiod,
                                          dtemthpay,dteyrepay,amtpfin,amtpint,
                                          amtrepmt,flgtranpy,dtetrnpy,amtpfinst,
                                          amtpfinen,amtintst,amtinten,
                                          codcreate,coduser)
                                 values (i.numcont,          v_dteendcal,   '1',  i.codempid,
                                             i.codcomp,         i.typpayroll,     '1',  indx_numperiod,
                                             indx_dtemthpay,  indx_dteyrepay,             v_amtpfin,     v_amtpint,
                                             v_amtlpay,          'N',               null,             i.amtnpfin,
                                             null,                 i.amtintovr,    null,
                                             para_coduser,     para_coduser);
            if i.typintr = '1' then --(Effective Rate)​​​​​​
               v_amtpint  := 0;
            end if;

            v_numerr   := 700;
            update tloaninf
                 set dtelcal = trunc(sysdate),
                       --<<tloanadj
                       rateilon        = nvl(v_rateilon , rateilon) ,
                       formula       = nvl(v_formulan , formula),
                       statementf   = nvl(v_statementn , statementf),
                       dteeffec      = nvl(v_dteeffec , dteeffec),
                       amtitotflat    = nvl(v_amtitotflat_new, amtitotflat),--tloanadj HRBF55B
                       amtiflat        = nvl(v_amtiflat_new , amtiflat),       --tloanadj HRBF55B
                       -->>tloanadj
                       amtpflat      = nvl(amtpflat,0) + v_amtpint,--HRBF55B
                       coduser       = para_coduser
               where rowid = i.rowid;

                commit;
      end loop; --for i in c_tloaninf loop


end;  --process_loan

procedure set_parameter (p_zyear          number ,
                                      p_dtestrt        varchar2 ,
                                      p_dteend        varchar2,
                                      p_coduser       varchar2) is
begin

  para_zyear         := p_zyear;
  para_dtestrt        := to_date(p_dtestrt,'dd/mm/yyyy');
  para_dteend        := to_date(p_dteend,'dd/mm/yyyy');
  para_coduser       := p_coduser;
end; --procedure set_parameter

end hrbf54b_batch;

/
