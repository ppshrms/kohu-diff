--------------------------------------------------------
--  DDL for Package Body HRBF1PD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1PD_BATCH" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 13/09/2021 14:01 #redmine 4254
*/

procedure start_process ( p_typcal   in	varchar2,
                                     p_codcomp 		in	varchar2,
                                     p_typpayrol		in	varchar2,
                                     p_codempid		in	varchar2,
                                     p_numperiod  in	number,
                                     p_dtemthpay  in	number,
                                     p_dteyrepay  in	number,
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
  indx_typcal           := p_typcal;
  para_coduser	 	   := p_coduser;

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
    select  dtestrt,dteend
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

      cursor c1 is
      select a.codempid, a.codcomp,b.numlvl
        from tclnsinf a,temploy1 b
     where a.codempid = b.codempid
         and a.codcomp like indx_codcomp||'%'
         and b.typpayroll   = nvl(indx_typpayroll, b.typpayroll)
         and a.codempid   = nvl(indx_codempid, a.codempid)
         and a.flgtranpy    = 'Y'
         and a.dteyrepay  = indx_dteyrepay  - para_zyear
         and a.dtemthpay = indx_dtemthpay
         and a.numperiod  = indx_numperiod
         and  not exists (select x.codempid
                          from ttaxcur x
                       where x.codempid = a.codempid
                           AND nvl(x.flgtrnbank,'N') = 'Y'
                           and x.dteyrepay  = a.dteyrepay
                           and x.dtemthpay = a.dtemthpay
                           and x.numperiod  = a.numperiod )
  order by a.codempid ;

   cursor c2 is
      select a.codempid, b.codcomp,b.numlvl
        from trepay a,temploy1 b
     where a.codempid = b.codempid
         and b.codcomp like indx_codcomp||'%'
         and b.typpayroll   = nvl(indx_typpayroll, b.typpayroll)
         and a.codempid   = nvl(indx_codempid, a.codempid)
         and a.dtelstpay =  ( indx_dteyrepay  - para_zyear)||lpad( indx_dtemthpay,2,0)|| indx_numperiod
         and  not exists (select x.codempid
                          from ttaxcur x
                       where x.codempid = a.codempid
                           AND nvl(x.flgtrnbank,'N') = 'Y'
                           and x.dteyrepay  =  indx_dteyrepay  - para_zyear
                           and x.dtemthpay =  indx_dtemthpay
                           and x.numperiod  =  indx_numperiod )
  order by a.codempid ;

        cursor c3 is
          select a.codempid, a.codcomp,b.numlvl
            from tobfinf a,temploy1 b
         where a.codempid = b.codempid
             and a.codcomp like indx_codcomp||'%'
             and b.typpayroll   = nvl(indx_typpayroll, b.typpayroll)
             and a.codempid   = nvl(indx_codempid, a.codempid)
             and a.flgtranpy    = 'Y' and a.typepay = '2'
             and a.dteyrepay  = indx_dteyrepay  - para_zyear
             and a.dtemthpay = indx_dtemthpay
             and a.numperiod  = indx_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numperiod )
      order by a.codempid ;

       cursor c4 is
          select a.codempid, a.codcomp,b.numlvl
            from ttravinf a,temploy1 b
         where a.codempid = b.codempid
             and a.codcomp like indx_codcomp||'%'
             and b.typpayroll   = nvl(indx_typpayroll, b.typpayroll)
             and a.codempid   = nvl(indx_codempid, a.codempid)
             and a.flgtranpy    = 'Y' and a.typepay = '2'
             and a.dteyrepay  = indx_dteyrepay  - para_zyear
             and a.dtemthpay = indx_dtemthpay
             and a.numperiod  = indx_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numperiod )
      order by a.codempid ;

      cursor c5 is
      select a.codempid,a.codcomp,b.numlvl
      from   tloaninf a,temploy1 b
      where  b.codempid = a.codempid
      and    b.codcomp 	 like indx_codcomp||'%'
      and    b.typpayroll   =  nvl(indx_typpayroll,b.typpayroll)
      and    a.codempid  	=  nvl(indx_codempid,a.codempid)
      and    a.dteyrpay	   =  indx_dteyrepay  - para_zyear
      and    a.mthpay	   =  indx_dtemthpay
      and    a.prdpay	   =  indx_numperiod
      and    a.typpayamt  = '1'
      and    a.staappr   	 = 'Y'
      and    nvl(a.flgpay,'N')  = 'Y'
      and  not exists (select x.codempid
                          from ttaxcur x
                       where x.codempid = a.codempid
                           AND nvl(x.flgtrnbank,'N') = 'Y'
                           and x.dteyrepay  = a.dteyrpay
                           and x.dtemthpay = a.mthpay
                           and x.numperiod  = a.prdpay )
      and  not exists (select x.numcont
                                from tloanpay x
                              where x.numcont  = a.numcont
                                  and x.flgtranpy = 'Y')
      order by a.codempid , numcont;

      cursor c6 is
         select a.codempid,a.codcomp,b.numlvl
           from tloanpay a,temploy1 b
         where b.codempid = a.codempid
             and a.codcomp like indx_codcomp||'%'
             and a.typpayroll    = nvl( indx_typpayroll,  b.typpayroll)
             and a.codempid  	= nvl( indx_codempid, b.codempid)
             and a.numperiod   = indx_numperiod
             and a.dtemthpay  = indx_dtemthpay
             and a.dteyrepay   = indx_dteyrepay  - para_zyear
             and a.typpay = '1'
             and nvl(a.flgtranpy,'N') = 'Y'
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numperiod )
            and  not exists (select x.numcont
                                from tloanpay x
                              where x.numcont  = a.numcont
                                  and x.dteyrepay||lpad(x.dtemthpay,2,0)||x.numperiod  > a.dteyrepay||lpad(a.dtemthpay,2,0)||a.numperiod)
         order by a.numcont, a.dterepmt desc;

        cursor c7 is
          select a.codempid, a.codcomp,b.numlvl
            from tinsdinf a,temploy1 b
         where a.codempid = b.codempid
             and a.codcomp like indx_codcomp||'%'
             and b.typpayroll   = nvl(indx_typpayroll, b.typpayroll)
             and a.codempid   = nvl(indx_codempid, a.codempid)
             and a.flgtranpy    = 'Y'
             and a.dteyrepay  = indx_dteyrepay  - para_zyear
             and a.dtemthpay = indx_dtemthpay
             and a.numprdpay  = indx_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               and nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numprdpay )
      order by a.codempid ;

begin

  delete tprocemp where codapp = para_codapp and coduser = para_coduser; commit;
  for r_emp in c1 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,  codempid)
                          values   (para_codapp,para_coduser,v_numproc,   r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c1 loop

  for r_emp in c2 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,  codempid)
                                values   (para_codapp,para_coduser,v_numproc,   r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c2 loop

  for r_emp in c3 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,  codempid)
                          values   (para_codapp,para_coduser,v_numproc,   r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c3 loop

      for r_emp in c4 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,codempid)
                          values   (para_codapp,para_coduser,v_numproc,r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c4 loop

  for r_emp in c5 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,codempid)
                          values   (para_codapp,para_coduser,v_numproc,r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c5 loop

  for r_emp in c6 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,codempid)
                          values   (para_codapp,para_coduser,v_numproc,r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c6 loop

    for r_emp in c7 loop
       v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
       if v_flgsecu then
         begin
           insert into tprocemp(codapp,coduser,numproc,codempid)
                          values   (para_codapp,para_coduser,v_numproc,r_emp.codempid);
         exception when dup_val_on_index then null;
         end;
       end if;
  end loop; --for r_emp in c7 loop

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

end gen_group_emp;


procedure gen_job is
  v_stmt			varchar2(1000 char);
  v_interval	varchar2(50 char);
  v_finish		varchar2(1 char);

  type a_number is table of number index by binary_integer;
     a_jobno	a_number;

begin

  for i in 1..para_numproc loop

    --v_stmt := 'HRBF1PD_batch.set_parameter ('||para_zyear||','''||to_char(para_dtestrt,'dd/mm/yyyy')||''','''||to_char(para_dteend,'dd/mm/yyyy')||''','''||para_coduser||''') ; '||

    v_stmt :=' HRBF1PD_batch.cal_process'||indx_typcal||'('''||para_codapp||''','''||para_coduser||''','||i||','''
                 ||indx_codcomp||''','''
                 ||indx_typpayroll||''','''
                 ||indx_codempid||''','
                 ||indx_numperiod||','
                 ||indx_dtemthpay||','
                 ||indx_dteyrepay||');' ;

    dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
  end loop;  --for i in 1..para_numproc loop
  --
  v_finish := 'u';
  loop
          for i in 1..para_numproc loop
            dbms_lock.sleep(10);
            begin
              select 'u' into v_finish
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
end gen_job;

procedure cal_process1 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_codincrt           tcontrbf.codincrt%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

   cursor c_tclnsinf is
         select a.rowid,
                   a.codempid, a.codcomp,a.amtalw , a.codrel,
                   a.dteyrepay , a.dtemthpay , a.numperiod
           from tclnsinf a,temploy1 b
        where a.codempid = b.codempid
            and a.codempid   = v_codempid
            and a.flgtranpy    = 'Y'
            and a.dteyrepay  = p_dteyrepay  - para_zyear
            and a.dtemthpay = p_dtemthpay
            and a.numperiod  = p_numperiod
     order by a.codempid ;

begin
  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numrec  := 0;
  v_numerr   := 0;
  for i in c_emp loop
       v_codempid  := i.codempid;
                for j in c_tclnsinf  loop
                      begin
                        select a.codincrt into v_codincrt
                        from tcontrbf  a
                        where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                        and a.dteeffec = (select max(b.dteeffec) from tcontrbf  b
                                                 where b.codcompy   = a.codcompy
                                                     and b.dteeffec  <= trunc(sysdate));
                        exception when no_data_found then
                           v_codincrt    := null;
                     end;

                     if v_codincrt is not null then
                        begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay1 ,v_rowid1
                            from tothinc
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      = v_codincrt ;
                         exception when no_data_found then
                              v_amtpay1  := 0;
                              v_rowid1     := null;
                         end;

                         begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay2 ,v_rowid2
                            from tothinc2
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      = v_codincrt
                              and codcompw  = j.codcomp;
                         exception when no_data_found then
                              v_amtpay2  := 0;
                              v_rowid2     := null;
                         end ;
                         if nvl(v_amtpay1,0) <> 0 then
                               v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtalw,0);
                               v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtalw,0);
                               if v_amtpay1 <= 0 then
                                    delete tothinc where rowid = v_rowid1;
                                    delete tothinc2 where rowid = v_rowid2;
                              else
                                    update tothinc
                                          set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid1 ;

                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;
                              end if;

                              v_numrec  := v_numrec + 1;
                              if j.codrel =   'E' then

                                   update tclnsum
                                         set amtpaye = nvl(amtpaye,0) - nvl(j.amtalw,0),
                                               coduser  = p_coduser
                                    where codempid   = j.codempid
                                        and dteyrepay   = j.dteyrepay
                                        and dtemthpay  = j.dtemthpay
                                        and numperiod   = j.numperiod;

                                else--if j.codrel <> 'E' then
                                   update tclnsum
                                         set amtpayf = nvl(amtpayf,0) - nvl(j.amtalw,0),
                                               coduser  = p_coduser
                                    where codempid   = j.codempid
                                        and dteyrepay   = j.dteyrepay
                                        and dtemthpay  = j.dtemthpay
                                        and numperiod   = j.numperiod;
                              end if;  --if j.codrel = 'E' then

                             delete tclnsum
                              where codempid   = j.codempid
                                  and dteyrepay   = j.dteyrepay
                                  and dtemthpay  = j.dtemthpay
                                  and numperiod   = j.numperiod
                                  and nvl(amtpaye,0)  = 0
                                  and nvl(amtpayf,0)   = 0
                                  and nvl(amtpayce,0) = 0
                                  and nvl(amtpaycf,0)  = 0
                                  and nvl(amtrepay,0)  = 0;

                              update tclnsinf
                                     set  flgtranpy    = 'N' ,
                                            flgupd = 'N',
                                            coduser  = p_coduser
                                  where rowid = j.rowid;
                         end if;--f nvl(v_amtpay1,0) <> 0 then
/*
--<<redmine4254                        
                        update tclnsinf
                                set  flgtranpy    = 'N' ,
                                       flgupd = 'N',
                                       dteyrepay  = null ,
                                       dtemthpay = null ,
                                       numperiod  = null ,
                                       coduser  = p_coduser
                          where rowid = j.rowid;
 -->>redmine4254        
 */
                     end if;  --if v_codincrt is not null then
                     commit;

                end loop; -- c_tclnsinf
  end loop;   -- for emp

	update tprocount
     set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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

end cal_process1;

procedure cal_process2 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is


  v_codempid		     temploy1.codempid%type;
  v_coddisovr           tcontrbf.coddisovr%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

   cursor c_trepay is
         select a.rowid,
                    a.codempid, a.amtoutstd, a.qtyrepaym, a.amtrepaym, a.dtestrpm,
                    a.qtypaid, a.dteclose, a.dtelstpay, a.amtlstpay ,
                    a.amtlstpayp , a.dtelstpayp,
                    b.codcomp, b.typpayroll, b.typemp
       from trepay a,temploy1 b
     where a.codempid = b.codempid
         and a.codempid   = v_codempid
         and a.dtelstpay =  ( p_dteyrepay  - para_zyear)||lpad( p_dtemthpay,2,0)|| p_numperiod
         and  not exists (select x.codempid
                          from ttaxcur x
                       where x.codempid = a.codempid
                           AND nvl(x.flgtrnbank,'N') = 'Y'
                           and x.dteyrepay  =  p_dteyrepay  - para_zyear
                           and x.dtemthpay =  p_dtemthpay
                           and x.numperiod  =  p_numperiod )
     order by a.codempid ;

begin
  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
       v_codempid  := i.codempid;
                for j in c_trepay  loop
                      begin
                        select a.coddisovr into v_coddisovr
                        from tcontrbf  a
                        where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                        and a.dteeffec = (select max(b.dteeffec) from tcontrbf  b
                                                 where b.codcompy   = a.codcompy
                                                     and b.dteeffec  <= trunc(sysdate));
                        exception when no_data_found then
                           v_coddisovr    := null;
                     end;

                     if v_coddisovr  is not null then
                        begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay1 ,v_rowid1
                            from tothinc
                          where codempid   = j.codempid
                              and dteyrepay  = p_dteyrepay  - para_zyear
                              and dtemthpay = p_dtemthpay
                              and numperiod  = p_numperiod
                              and codpay      = v_coddisovr ;
                         exception when no_data_found then
                              v_amtpay1  := 0;
                              v_rowid1     := null;
                         end;

                         begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay2 ,v_rowid2
                            from tothinc2
                          where codempid   = j.codempid
                             and dteyrepay  = p_dteyrepay  - para_zyear
                              and dtemthpay = p_dtemthpay
                              and numperiod  = p_numperiod
                              and codpay      = v_coddisovr
                              and codcompw  = j.codcomp;
                         exception when no_data_found then
                              v_amtpay2  := 0;
                              v_rowid2     := null;
                         end ;

                         if nvl(v_amtpay1,0) <> 0 then
                               v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtlstpay,0);
                               v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtlstpay,0);
                               if v_amtpay1 <= 0 then
                                    delete tothinc where rowid = v_rowid1;
                                    delete tothinc2 where rowid = v_rowid2;
                              else

                                    update tothinc
                                          set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid1 ;

                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;
                              end if;

                              v_numrec  := v_numrec + 1;
                                   update tclnsum
                                         set amtrepay      = amtrepay - nvl(j.amtlstpay,0) ,
                                               numprdpay   = null,
                                               coduser         = p_coduser
                                    where codempid   = j.codempid
                                        and dteyrepay   =p_dteyrepay  - para_zyear
                                        and dtemthpay  = p_dtemthpay
                                        and numperiod   = p_numperiod;

                             delete tclnsum
                              where codempid   = j.codempid
                                  and dteyrepay   = p_dteyrepay  - para_zyear
                                  and dtemthpay  = p_dtemthpay
                                  and numperiod   = p_numperiod
                                  and nvl(amtpaye,0)  = 0
                                  and nvl(amtpayf,0)   = 0
                                  and nvl(amtpayce,0) = 0
                                  and nvl(amtpaycf,0)  = 0
                                  and nvl(amtrepay,0)  = 0;

                             update trepay
                                   set   amtoutstd = nvl(amtoutstd,0) + j.amtlstpay,
                                            qtypaid   = nvl(qtypaid,0) - 1,
                                            amttotpay  = nvl(amttotpay,0)  - j.amtlstpay,
                                            amtlstpay =  j.amtlstpayp,
                                            dtelstpay  = j.dtelstpayp,
                                           flgclose   = decode(flgclose,'Y','N'),
                                           amtclose  = decode(flgclose,'Y',null),
                                           dteclose  = decode(flgclose,'Y',null),
                                           coduser  = p_coduser
                                where rowid = j.rowid;

                         end if;--f nvl(v_amtpay1,0) <> 0 then
                     end if;
                     commit;
                end loop; --c_tloaninf
  end loop;   -- for emp

	update tprocount
     set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
            qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process2;

procedure cal_process3 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is


  v_codempid		     temploy1.codempid%type;
  v_codincbf           tcontrbf.codincbf%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

   cursor c_tobfinf is
         select a.rowid,
                   a.codempid,  a.codcomp,    a.amtwidrw,   a.codobf,    a.numvcher,
                   a.dteyrepay,  a.dtemthpay, a.numperiod
           from tobfinf a,temploy1 b
        where a.codempid = b.codempid
            and a.codempid   = v_codempid
            and a.flgtranpy    = 'Y' and a.typepay = '2'
            and a.dteyrepay  = p_dteyrepay  - para_zyear
            and a.dtemthpay = p_dtemthpay
            and a.numperiod  = p_numperiod
     order by a.codempid ;

begin
  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
       v_codempid  := i.codempid;

                for j in c_tobfinf  loop
                      /*
                      begin
                        select a.codincbf into v_codincbf
                        from tcontrbf  a
                        where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                        and a.dteeffec = (select max(b.dteeffec) from tcontrbf  b
                                                 where b.codcompy   = a.codcompy
                                                     and b.dteeffec  <= trunc(sysdate));
                        exception when no_data_found then
                           v_codincbf    := null;
                     end;
                     */
                     begin
                            select codincbf
                            into v_codincbf
                            from tobfcompy
                          where codcompy  = hcm_util.get_codcomp_level(j.codcomp, '1')
                              and codobf   = j.codobf;
                       exception when no_data_found then
                           v_codincbf    := null;
                     end;

                     if  v_codincbf is not null then
                        begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay1 ,v_rowid1
                            from tothinc
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      = v_codincbf ;
                         exception when no_data_found then
                              v_amtpay1  := 0;
                              v_rowid1     := null;
                         end;

                         begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay2 ,v_rowid2
                            from tothinc2
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      =  v_codincbf
                              and codcompw  = j.codcomp;
                         exception when no_data_found then
                              v_amtpay2  := 0;
                              v_rowid2     := null;
                         end ;

                         if nvl(v_amtpay1,0) <> 0 then
                               v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtwidrw,0);
                               v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtwidrw,0);
                               if v_amtpay1 <= 0 then
                                    delete tothinc where rowid = v_rowid1;
                                    delete tothinc2 where rowid = v_rowid2;
                              else
                                    update tothinc
                                          set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid1 ;

                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;

                              end if;

                              v_numrec  := v_numrec + 1;
                              update tobfinf
                                    set  flgtranpy    = 'N' ,
                                           coduser  = p_coduser
                                where rowid = j.rowid;

                         end if;--f nvl(v_amtpay1,0) <> 0 then
                     end if;
                     commit;
                end loop; --c_tloaninf
  end loop;   -- for emp

	update tprocount
    set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process3;

procedure cal_process4 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

   cursor c_ttravinf is
         select a.rowid , a.codempid ,a.codcomp,a.amtreq,a.numtravrq,a.codpay,
         a.dteyrepay ,  a.dtemthpay , a.numperiod
          from ttravinf a, temploy1 b
         where a.codempid   = b.codempid
           and a.codempid   =  v_codempid
           and a.flgtranpy  = 'Y' and a.typepay = '2'
           and a.dteyrepay   = p_dteyrepay  - para_zyear
           and a.dtemthpay  = p_dtemthpay
           and a.numperiod  = p_numperiod
     order by a.codempid ;

begin
  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
       v_codempid  := i.codempid;

                for j in c_ttravinf  loop

                     if j.codpay is not null then
                        begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay1 ,v_rowid1
                            from tothinc
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      = j.codpay ;
                         exception when no_data_found then
                              v_amtpay1  := 0;
                              v_rowid1     := null;
                         end;

                         begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay2 ,v_rowid2
                            from tothinc2
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numperiod
                              and codpay      =  j.codpay
                              and codcompw  = j.codcomp;
                         exception when no_data_found then
                              v_amtpay2  := 0;
                              v_rowid2     := null;
                         end ;

                         if nvl(v_amtpay1,0) <> 0 then
                               v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtreq,0);
                               v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtreq,0);
                               if v_amtpay1 <= 0 then
                                    delete tothinc where rowid = v_rowid1;
                                    delete tothinc2 where rowid = v_rowid2;
                              else

                                    update tothinc
                                          set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid1 ;

                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;

                              end if;

                              v_numrec  := v_numrec + 1;
                              update ttravinf
                                    set  flgtranpy    = 'N' ,
                                           coduser  = p_coduser
                                where rowid = j.rowid;

                         end if;--f nvl(v_amtpay1,0) <> 0 then
                     end if;   --j.codpay
                     commit;
                end loop; --ttravinf
  end loop;   -- for emp

	update tprocount
   set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process4;

procedure cal_process5 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_codpaye          tintrteh.codpaye%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

      cursor c_tloaninf  is
         select a.codempid,a.codcomp,b.typpayroll,b.typemp,a.amtlon,a.codlon,a.numcont,b.numlvl,
           a.prdpay,a.mthpay,a.dteyrpay
           from tloaninf a,temploy1 b
        where  b.codempid     = a.codempid
            and  a.codempid  	= v_codempid
            and  a.dteyrpay	   =  p_dteyrepay  - para_zyear
            and  a.mthpay	      =  p_dtemthpay
            and  a.prdpay	      =  p_numperiod
            and  a.typpayamt  = '1'
            and  a.staappr   	  = 'Y'
            and  nvl(a.flgpay,'N')  = 'Y'
    order by a.codempid , numcont;


begin

  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
    v_codempid  := i.codempid;
          for j in c_tloaninf  loop
                begin
                  select a.codpaye into v_codpaye
                  from tintrteh  a
                  where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                  and a.codlon  =  j.codlon
                  and a.dteeffec = (select max(b.dteeffec) from tintrteh  b
                                           where b.codcompy   = a.codcompy
                                               and b.codlon  =  a.codlon
                                               and b.dteeffec  <= trunc(sysdate));
                  exception when no_data_found then
                     v_codpaye    := null;
               end;

               if v_codpaye is not null then

                  begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay1 ,v_rowid1
			             from tothinc
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrpay
                        and dtemthpay = j.mthpay
                        and numperiod  = j.prdpay
                        and codpay      = v_codpaye ;
			          exception when no_data_found then
			          	   v_amtpay1  := 0;
                        v_rowid1     := null;
			          end;

                   begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay2 ,v_rowid2
			             from tothinc2
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrpay
                        and dtemthpay = j.mthpay
                        and numperiod  = j.prdpay
                        and codpay      = v_codpaye
                        and codcompw  = j.codcomp;
			          exception when no_data_found then
			          	   v_amtpay2  := 0;
                        v_rowid2     := null;
			          end ;

                   if nvl(v_amtpay1,0) <> 0 then
                         v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtlon,0);
                         v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtlon,0);
                         if v_amtpay1 <= 0 then
                              delete tothinc where rowid = v_rowid1;
                              delete tothinc2 where rowid = v_rowid2;
                        else
                              update tothinc
                                    set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid1 ;

                                update tothinc2
                                    set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid2;

                        end if;

                        v_numrec  := v_numrec + 1;
                        update tloaninf
                              set   flgpay     = 'N',
                                     dteptrn   = null,
                                     coduser  = p_coduser
                          where numcont = j.numcont;

                   end if;--f nvl(v_amtpay1,0) <> 0 then
               end if;
               commit;

          end loop; --c_tloaninf
  end loop;   -- for emp

	update tprocount
     set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process5;

procedure cal_process6 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_codpayc          tintrteh.codpayc%type;
  v_codpayd          tintrteh.codpayd%type;

  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_amtpflat          number:= 0;

  v_numrec           number:=0;

  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_flgupd            varchar2(1);
  v_lstperiod         varchar2(10);

  v_dtelpay          date;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

         cursor c_tloanpay is
            select a.rowid,
                      a.numcont,   a.dterepmt, a.typtran, a.codempid,
                      a.codcomp,   a.typpayroll,  a.typpay,
                      a.numperiod, a.dtemthpay, a.dteyrepay,
                      a.amtpfin, A.amtpint, A.amtintst,
                      A.amtrepmt,  b.codlon , b.typintr , b.amtpflat , b.amttotpay,
                      a.amtinten
            from tloanpay a, tloaninf b
            where a.numcont  = b.numcont
               and a.codempid  	= v_codempid
               and a.numperiod    = p_numperiod
               and a.dtemthpay   = p_dtemthpay
               and a.dteyrepay    = p_dteyrepay  - para_zyear
               and a.typpay = '1'
               and nvl(a.flgtranpy,'N') = 'Y'
        order by a.numcont, a.dterepmt desc;

begin

  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
    v_codempid  := i.codempid;

          for j in c_tloanpay  loop
                v_flgupd     := 'N';
                v_lstperiod  := null;
                v_dtelpay  := null;
                begin
                  select a.codpayc ,a.codpayd into v_codpayc   , v_codpayd
                  from tintrteh  a
                  where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                  and a.codlon  =  j.codlon
                  and a.dteeffec = (select max(b.dteeffec) from tintrteh  b
                                           where b.codcompy   = a.codcompy
                                               and b.codlon  =  a.codlon
                                               and b.dteeffec  <= trunc(sysdate));
                  exception when no_data_found then
                     v_codpayc    := null;
                     v_codpayd    := null;
               end;

               if nvl(j.amtpfin,0) > 0 and v_codpayc is not null then
                  v_flgupd  := 'Y';
                  begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay1 ,v_rowid1
			             from tothinc
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrepay
                        and dtemthpay = j.dtemthpay
                        and numperiod  = j.numperiod
                        and codpay      = v_codpayc ;
			          exception when no_data_found then
			          	   v_amtpay1  := 0;
                        v_rowid1     := null;
			          end;

                   begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay2 ,v_rowid2
			             from tothinc2
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrepay
                        and dtemthpay = j.dtemthpay
                        and numperiod  = j.numperiod
                        and codpay      = v_codpayc
                        and codcompw  = j.codcomp;
			          exception when no_data_found then
			          	   v_amtpay2  := 0;
                        v_rowid2     := null;
			          end ;

                   if nvl(v_amtpay1,0) <> 0 then
                         v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtpfin,0);
                         v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtpfin,0);

                         if v_amtpay1 <= 0 then
                              delete tothinc where rowid = v_rowid1;
                              delete tothinc2 where rowid = v_rowid2;
                        else
                              update tothinc
                                    set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid1 ;

                                update tothinc2
                                    set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid2;
                        end if;
                    end if; --if nvl(v_amtpay1,0) <> 0 then
               end if;--if nvl(j.amtpfin,0) > 0 and v_codpayc is not null then

               if nvl(j.amtpint,0) > 0 and v_codpayd is not null then
                  v_flgupd  := 'Y';
                  begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay1 ,v_rowid1
			             from tothinc
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrepay
                        and dtemthpay = j.dtemthpay
                        and numperiod  = j.numperiod
                        and codpay      = v_codpayd;
			          exception when no_data_found then
			          	   v_amtpay1  := 0;
                        v_rowid1     := null;
			          end;

                   begin
			           select stddec(amtpay,codempid, para_chken) amtpay ,rowid
			              into v_amtpay2 ,v_rowid2
			             from tothinc2
			           where codempid   = j.codempid
			               and dteyrepay  = j.dteyrepay
                        and dtemthpay = j.dtemthpay
                        and numperiod  = j.numperiod
                        and codpay      = v_codpayd
                        and codcompw  = j.codcomp;
			          exception when no_data_found then
			          	   v_amtpay2  := 0;
                        v_rowid2     := null;
			          end ;

                   if nvl(v_amtpay1,0) <> 0 then
                         v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtpint,0);
                         v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtpint,0);
                         if v_amtpay1 <= 0 then
                              delete tothinc where rowid = v_rowid1;
                              delete tothinc2 where rowid = v_rowid2;
                        else
                              update tothinc
                                    set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid1 ;

                                update tothinc2
                                    set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                          coduser  = p_coduser
                                where rowid   = v_rowid2;
                        end if;
                 end if; --if nvl(v_amtpay1,0) <> 0 then
               end if; --if nvl(j.amtpint,0) > 0 and v_codpayc is not null then

               if v_flgupd  = 'Y' then
                  begin
                     select max(x.dteyrepay||lpad(x.dtemthpay,2,0)||x.numperiod),max(dterepmt)
                        into v_lstperiod ,v_dtelpay
                       from tloanpay x
                     where x.numcont  = j.numcont
                         and x.dteyrepay||lpad(x.dtemthpay,2,0)||x.numperiod < j.dteyrepay||lpad(j.dtemthpay,2,0)||j.numperiod  ;
                     exception when no_data_found then
                        v_lstperiod  := null;
                        v_dtelpay  := null;
                  end;

                  if  j.typintr in ('2','3') then
                      v_amtpflat    := nvl(j.amtpflat,0)  -  nvl(j.amtpint,0); --Fixed Rate
                  else
                      v_amtpflat   := 0;
                  end if;

                  v_numrec  := v_numrec + 1;
                  update tloaninf
                        set qtyperip    = qtyperip - 1,  --#redmine3993
                              amtnpfin   = nvl(amtnpfin,0)  +  nvl(j.amtpfin,0) ,
--<<error  amtintovr  #redmine3993
                              --amtintovr  = nvl(j.amtintst,0) + nvl(j.amtpint,0)  ,
                              amtintovr  = decode(nvl(j.amtintst,0),0,0,
                                                (nvl(j.amtintst,0) + nvl(j.amtpint,0))  ),
-->>error  amtintovr  #redmine3993
                              amttotpay = nvl(j.amttotpay,0) - nvl(j.amtpfin,0) ,
                              yrelcal      = to_number(substr(v_lstperiod,1,4)),
                              mthlcal     = to_number(substr(v_lstperiod,5,2)),
                              prdlcal      = to_number(substr(v_lstperiod,7,2)),
                              dtelpay     = v_dtelpay,
                              amtpflat   = v_amtpflat,
                              stalon      = 'P' ,--dteltrn = null,
                              dteaccls    = NULL ,
                              coduser    = p_coduser
                    where numcont = j.numcont;

                    update   tloanpay
                       set   amtpfinen     = 0 ,
                              amtinten      = 0 ,
--<<user19 9/1/2021
                             /*
                             numperiod    = null, dtemthpay   = null, dteyrepay    = null,
                             */
-->>user19 9/1/2021
                             flgtranpy      = 'N',
                             dtetrnpy       = null,
                             coduser        = p_coduser
                    where rowid = j.rowid;
               end if;  --if v_flgupd  = 'Y' then
               commit;

          end loop; --c_tloaninf
  end loop;   -- for emp

	update tprocount
  set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process6;

procedure cal_process7 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_codempid   in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_coddisisr           tcontrbf.coddisisr%TYPE;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

  cursor c_emp is
    select b.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by b.codempid;

   cursor c_tinsdinf is
         select a.rowid,
                    a.codempid, a.numisr,a.dteyear ,a.dtemonth ,
                    a.codcomp, a.typpayroll, a.amtpmiume,
                    a.numprdpay , a.dtemthpay , a.dteyrepay
           from tinsdinf a,temploy1 b
        where a.codempid = b.codempid
            and a.codempid   = v_codempid
            and a.flgtranpy    = 'Y'
            and a.dteyrepay   = p_dteyrepay  - para_zyear
            and a.dtemthpay  = p_dtemthpay
            and a.numprdpay  = p_numperiod
     order by a.codempid ;

begin
  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc;
  v_numerr := 0;
  for i in c_emp loop
       v_codempid  := i.codempid;
                for j in c_tinsdinf  loop
                      begin
                        select a.coddisisr into v_coddisisr
                        from tcontrbf  a
                        where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                        and a.dteeffec = (select max(b.dteeffec) from tcontrbf  b
                                                 where b.codcompy   = a.codcompy
                                                     and b.dteeffec  <= trunc(sysdate));
                        exception when no_data_found then
                           v_coddisisr    := null;
                     end;

                     if  v_coddisisr is not null then
                        begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay1 ,v_rowid1
                            from tothinc
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numprdpay
                              and codpay      = v_coddisisr ;
                         exception when no_data_found then
                              v_amtpay1  := 0;
                              v_rowid1     := null;
                         end;

                         begin
                          select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                             into v_amtpay2 ,v_rowid2
                            from tothinc2
                          where codempid   = j.codempid
                              and dteyrepay  = j.dteyrepay
                              and dtemthpay = j.dtemthpay
                              and numperiod  = j.numprdpay
                              and codpay      = v_coddisisr
                              and codcompw  = j.codcomp;
                         exception when no_data_found then
                              v_amtpay2  := 0;
                              v_rowid2     := null;
                         end ;

                         if nvl(v_amtpay1,0) <> 0 then
                               v_amtpay1  := nvl(v_amtpay1,0) - nvl(j.amtpmiume,0);
                               v_amtpay2  := nvl(v_amtpay2,0) - nvl(j.amtpmiume,0);
                               if v_amtpay1 <= 0 then
                                    delete tothinc where rowid = v_rowid1;
                                    delete tothinc2 where rowid = v_rowid2;
                              else
                                    update tothinc
                                          set amtpay   = stdenc(v_amtpay1,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid1 ;

                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;

                              end if;
                              v_numrec  := v_numrec + 1;
                                update  tdepltdte
                                     set qtypmium  =  qtypmium  - 1  ,
                                            amtpmium =  amtpmium -   nvl(j.amtpmiume ,0) ,
                                            flgtrnpy  =  'N' ,
                                            coduser  = p_coduser
                                    where numisr  = j.numisr
                                    and codcomp   = j.codcomp
                                    and typpayroll  = j.typpayroll
                                    and dteyear     = j.dteyear
                                    and dtemonth  = j.dtemonth;

                              delete tdepltdte
                                   where numisr    = j.numisr
                                    and codcomp   = j.codcomp
                                    and typpayroll  = j.typpayroll
                                    and dteyear    = j.dteyear
                                    and dtemonth  = j.dtemonth
                                    and nvl(qtypmium,0) = 0;

                              delete tinsdinf  where codempid  = j.codempid and numisr = j.numisr;

                         end if;--f nvl(v_amtpay1,0) <> 0 then
                     end if;
                     commit;

                end loop; --c_tloaninf
  end loop;   -- for emp

	update tprocount
   set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + v_numerr,
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
end cal_process7;


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

procedure auto_process2 is ----
  v_dteyrepay   number;
  v_dtemthpay   number;
  v_numperiod   number;

  cursor c_trepay is
    select b.codcomp,b.typpayroll
      from trepay a,temploy1 b
     where a.codempid  = b.codempid
       and a.dtelstpay = v_dteyrepay||lpad(v_dtemthpay,2,0)||v_numperiod
       and not exists (select x.codempid
                         from ttaxcur x
                        where x.codempid = a.codempid
                          and nvl(x.flgtrnbank,'N') = 'Y'
                          and x.dteyrepay = v_dteyrepay
                          and x.dtemthpay = v_dtemthpay
                          and x.numperiod = v_numperiod)
  group by b.codcomp,b.typpayroll
  order by b.codcomp,b.typpayroll;

  cursor c_period(p_codcomp     temploy1.codcomp%type,
                  p_typpayroll  temploy1.typpayroll%type) is
    select codcompy,typpayroll,numperiod,dtemthpay,dteyrepay
      from tdtepay
     where codcompy   = hcm_util.get_codcomp_level(p_codcomp, '1')
       and typpayroll = p_typpayroll
       and dteyrepay  = v_dteyrepay
       and dtemthpay  = v_dtemthpay
       and trunc(sysdate) between dtestrt and dteend
  order by dteyrepay,dtemthpay,numperiod;
begin
  --null;
  v_dtemthpay := to_number(to_char(sysdate,'mm'));
  v_dteyrepay := to_number(to_char(sysdate,'yyyy'));
  if v_dteyrepay > 2500 then
    v_dteyrepay := v_dteyrepay - 543;
  end if;
  for i in c_trepay loop
    for j in c_period(i.codcomp,i.typpayroll) loop
      HRBF1PD_batch.start_process('2',
                                   i.codcomp,
                                   i.typpayroll,
                                   null,
                                   j.numperiod,
                                   j.dtemthpay,
                                   j.dteyrepay,
                                   'AUTO');
    end loop;
  end loop;
end;
end HRBF1PD_batch;

/
