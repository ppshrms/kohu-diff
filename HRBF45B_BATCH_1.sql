--------------------------------------------------------
--  DDL for Package Body HRBF45B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF45B_BATCH" as

/*
	code by 	  : User14/Krisanai Mokkapun
  modify      : 27/01/2021 17:01
*/

procedure start_process ( p_typcal         in	varchar2,
                                     p_codcomp 		in	varchar2,
                                     p_typpayrol		in	varchar2,
                                     p_numperiod   in	number,
                                     p_dtemthpay  in	number,
                                     p_dteyrepay   in	number,
                                     p_coduser		  in varchar2) is

begin


  indx_typcal         := p_typcal;
  indx_codcomp        := p_codcomp;
  indx_typpayroll     := p_typpayrol;
  indx_numperiod      := p_numperiod;
  indx_dtemthpay      := p_dtemthpay;
  indx_dteyrepay      := p_dteyrepay;
  para_coduser	 	    := p_coduser;

  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

  begin
       select get_numdec(numlvlsalst,p_coduser) numlvlst ,get_numdec(numlvlsalen,p_coduser) numlvlen
         into para_numlvlsalst,para_numlvlsalen
         from tusrprof
       where coduser = para_coduser;
     exception when others then
       null;
  end;

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
			select a.codempid , a.codcomp,b.numlvl
				from ttravinf a,temploy1 b
			 where a.codempid     = b.codempid
			   and a.codcomp    like indx_codcomp||'%'
			   and b.typpayroll      =  nvl(indx_typpayroll, b.typpayroll)
			   and a.dteyrepay     = indx_dteyrepay  - para_zyear
            and a.dtemthpay    = indx_dtemthpay
            and a.numperiod     = indx_numperiod
				and nvl(a.flgtranpy,'N') = 'N'
				and a.typepay      = '2'
				and nvl(a.amtreq,0)    > 0
     order by a.codempid;

    cursor c2 is
			select a.codempid , a.codcomp,b.numlvl
				from tobfinf a,temploy1 b
			 where a.codempid     = b.codempid
			   and a.codcomp    like indx_codcomp||'%'
			   and b.typpayroll      =  nvl(indx_typpayroll, b.typpayroll)
			   and a.dteyrepay     = indx_dteyrepay  - para_zyear
            and a.dtemthpay    = indx_dtemthpay
            and a.numperiod     = indx_numperiod
				and nvl(a.flgtranpy,'N') = 'N'
				and a.typepay      = '2'
				and nvl(a.amtwidrw,0)    > 0
     order by a.codempid;


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
  v_stmt			 varchar2(1000 char);
  v_interval	    varchar2(50 char);
  v_finish		    varchar2(1 char);

  type a_number is table of number index by binary_integer;
     a_jobno	a_number;

begin

  for i in 1..para_numproc loop

    v_stmt :=' HRBF45B_batch.cal_process'||indx_typcal||'('''||para_codapp||''','''||para_coduser||''','||i||','''
                 ||indx_codcomp||''','''
                 ||indx_typpayroll||''','
                 ||indx_numperiod||','
                 ||indx_dtemthpay||','
                 ||indx_dteyrepay||');';

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
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is

  v_codempid		     temploy1.codempid%type;
  v_costcent         tcenter.costcent%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

     cursor c_emp is
        select a.codempid
          from tprocemp a
        where  a.codapp   = p_codapp
            and a.coduser   = p_coduser
            and a.numproc  = p_numproc
     order by a.codempid;

       cursor c_ttravinf is
               select  a.rowid,
                 a.codempid,a.codpay,a.amtreq,a.codcomp,b.typpayroll,b.typemp,
                 a.dteyrepay , a.dtemthpay ,a.numperiod
                  from ttravinf a,temploy1 b
                where a.codempid    = b.codempid
                  and a.codempid      = v_codempid
                  and a.dteyrepay     = p_dteyrepay  - para_zyear
                  and a.dtemthpay    = p_dtemthpay
                  and a.numperiod     = p_numperiod
                  and nvl(a.flgtranpy,'N') = 'N'
                  and a.typepay      = '2'
                  and nvl(a.amtreq,0)    > 0
           order by a.codempid;

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
                           if   j.codpay is not null then
                              begin
                                select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                                   into v_amtpay1 ,v_rowid1
                                  from tothinc
                                where codempid   = j.codempid
                                    and dteyrepay  = j.dteyrepay
                                    and dtemthpay = j.dtemthpay
                                    and numperiod  = j.numperiod
                                    and codpay      = j.codpay;
                               exception when no_data_found then
                                    v_amtpay1  := 0;
                                    v_rowid1     := null;
                               end;

                              begin
                                     select costcent into v_costcent
                                       from tcenter
                                      where codcomp = j.codcomp;
                                    exception when no_data_found then
                                     v_costcent := null;
                              end;
                              if nvl(v_amtpay1,0) <> 0 then
                                    v_amtpay1  := nvl(v_amtpay1,0) + nvl(j.amtreq,0);
                                    update tothinc
                                          set amtpay      =  stdenc(v_amtpay1,codempid, para_chken) ,
                                                codcomp    =  j.codcomp ,
                                                typpayroll    = j.typpayroll ,
                                                typemp      = j.typemp ,
                                                costcent     = v_costcent,
                                                codsys        = 'BF' ,
                                                coduser     = p_coduser
                                      where rowid   = v_rowid1;
                              else
                                     v_amtpay1  := nvl(j.amtreq,0);
                                     insert into tothinc (codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                                               codcomp,typpayroll,typemp,qtypayda,qtypayhr,
                                                               qtypaysc,ratepay,amtpay,codsys,costcent,
                                                               codcreate,coduser)
                                                   values  (j.codempid, j.dteyrepay,  j.dtemthpay, j.numperiod, j.codpay,
                                                                j.codcomp, j.typpayroll, j.typemp,null,null,
                                                               null, null,  stdenc(v_amtpay1, j.codempid, para_chken)  ,'BF' , v_costcent,
                                                               p_coduser,   p_coduser);
                              end if; --if nvl(v_amtpay1,0) <> 0 then

                               begin
                                select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                                   into v_amtpay2 ,v_rowid2
                                  from tothinc2
                                where codempid   = j.codempid
                                    and dteyrepay  = j.dteyrepay
                                    and dtemthpay = j.dtemthpay
                                    and numperiod  = j.numperiod
                                    and codpay      = j.codpay
                                    and codcompw  = j.codcomp;
                               exception when no_data_found then
                                    v_amtpay2  := 0;
                                    v_rowid2     := null;
                               end;

                               if nvl(v_amtpay2,0) <> 0 then
                                      v_amtpay2  := nvl(v_amtpay2,0) + nvl(j.amtreq,0);
                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                               costcent   = v_costcent,
                                                codsys    = 'BF' ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;
                              else
                                       v_amtpay2  := nvl(j.amtreq,0);
                                       insert into tothinc2 (codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                                                         codcompw,qtypayda,qtypayhr,qtypaysc,amtpay,
                                                                         costcent,codsys,codcreate,coduser)
                                                            values (j.codempid, j.dteyrepay, j.dtemthpay, j.numperiod, j.codpay,
                                                                         j.codcomp, null, null, null, stdenc(v_amtpay2, j.codempid, para_chken),
                                                                         v_costcent, 'BF' ,p_coduser,p_coduser);
                               end if;--if nvl(v_amtpay2,0) <> 0 then

                               v_numrec  := v_numrec + 1;
                               update ttravinf
                                     set flgtranpy    = 'Y' ,
                                          coduser  = p_coduser
                                where rowid = j.rowid;
                     end if;--   if   j.codpay is not null then

                     commit;

                end loop; --c_ttravinf
  end loop;   -- for emp

--Redmine #3529
  update tprocount
    set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + nvl(v_numerr,0),
         flgproc  = 'Y' ,
         codempid = null,
         remark   = null,
         dteupd   = sysdate
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc;
--Redmine #3529
     commit;

exception when others then
  rollback; 
  v_sqlerrm := sqlerrm;
 	update tprocount
     set qtyerr   = nvl(qtyerr,0) + v_numerr,
         codempid = v_codempid ,
         dteupd   = sysdate,
         flgproc  = 'E',
         remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,500)
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc;
     commit;
end cal_process1;

procedure cal_process2 (p_codapp   	in  varchar2,
                                  p_coduser   	in  varchar2,
                                  p_numproc	  in  number,
                                  p_codcomp		in	varchar2,
                                  p_typpayroll    in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay   in	number ) is


  v_codempid		     temploy1.codempid%type;
  v_codincbf         tobfcompy.codincbf%type;
  v_costcent         tcenter.costcent%type;
  v_amtpay1         number:= 0;
  v_amtpay2         number:= 0;
  v_rowid1            varchar2(100);
  v_rowid2            varchar2(100);
  v_numrec           number:=0;

     cursor c_emp is
        select a.codempid
          from tprocemp a
        where a.codapp      = p_codapp
            and a.coduser     = p_coduser
            and a.numproc    = p_numproc
     order by a.codempid;

      cursor c_tobfinf is
       select a.rowid,
                   a.codempid , a.codcomp   , b.numlvl,     b.typpayroll,
                   b.typemp,     a.amtwidrw   , a.codobf,
                   a.dteyrepay , a.dtemthpay , a.numperiod
          from tobfinf a,temploy1 b
        where a.codempid      = b.codempid
            and a.codempid      = v_codempid
			   and a.dteyrepay     = p_dteyrepay  - para_zyear
            and a.dtemthpay    = p_dtemthpay
            and a.numperiod     = p_numperiod
				and nvl(a.flgtranpy,'N') = 'N'
				and a.typepay      = '2'
				and nvl(a.amtwidrw,0)    > 0
     order by a.codempid;

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
                      begin
                           select a.codincbf  into v_codincbf
                             from tobfcompy  a
                          where a.codcompy   = hcm_util.get_codcomp_level(j.codcomp, '1')
                              and a.codobf   = j.codobf;
                           exception when no_data_found then
                              v_codincbf    := null;
                     end;

                     if v_codincbf  is not null then
                              begin
                                select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                                   into v_amtpay1 ,v_rowid1
                                  from tothinc
                                where codempid   = j.codempid
                                    and dteyrepay  = j.dteyrepay
                                    and dtemthpay = j.dtemthpay
                                    and numperiod  = j.numperiod
                                    and codpay      = v_codincbf;
                               exception when no_data_found then
                                    v_amtpay1  := 0;
                                    v_rowid1     := null;
                               end;

                              begin
                                     select costcent into v_costcent
                                       from tcenter
                                      where codcomp = j.codcomp;
                                    exception when no_data_found then
                                     v_costcent := null;
                              end;
                              if nvl(v_amtpay1,0) <> 0 then
                                    v_amtpay1  := nvl(v_amtpay1,0) + nvl(j.amtwidrw,0);
                                    update tothinc
                                          set amtpay      =  stdenc(v_amtpay1,codempid, para_chken) ,
                                                codcomp    =  j.codcomp ,
                                                typpayroll    = j.typpayroll ,
                                                typemp      = j.typemp ,
                                                costcent     = v_costcent,
                                                codsys        = 'BF' ,
                                                coduser     = p_coduser
                                      where rowid   = v_rowid1;
                              else
                                     v_amtpay1  := nvl(j.amtwidrw,0);
                                     insert into tothinc (codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                                               codcomp,typpayroll,typemp,qtypayda,qtypayhr,
                                                               qtypaysc,ratepay,amtpay,codsys,costcent,
                                                               codcreate,coduser)
                                                   values  (j.codempid, j.dteyrepay,  j.dtemthpay, j.numperiod, v_codincbf ,
                                                                j.codcomp, j.typpayroll, j.typemp,null,null,
                                                               null, null,  stdenc(v_amtpay1, j.codempid, para_chken)  ,'BF' , v_costcent,
                                                               p_coduser,   p_coduser);
                              end if; --if nvl(v_amtpay1,0) <> 0 then

                               begin
                                select stddec(amtpay,codempid, para_chken) amtpay ,rowid
                                   into v_amtpay2 ,v_rowid2
                                  from tothinc2
                                where codempid   = j.codempid
                                    and dteyrepay  = j.dteyrepay
                                    and dtemthpay = j.dtemthpay
                                    and numperiod  = j.numperiod
                                    and codpay      = v_codincbf
                                    and codcompw  = j.codcomp;
                               exception when no_data_found then
                                    v_amtpay2  := 0;
                                    v_rowid2     := null;
                               end;
                               if nvl(v_amtpay2,0) <> 0 then
                                      v_amtpay2  := nvl(v_amtpay2,0) + nvl(j.amtwidrw,0);
                                      update tothinc2
                                          set amtpay   = stdenc(v_amtpay2,codempid, para_chken) ,
                                               costcent   = v_costcent,
                                                codsys    = 'BF' ,
                                                coduser  = p_coduser
                                      where rowid   = v_rowid2;
                              else
                                       v_amtpay2  := nvl(j.amtwidrw,0);
                                       insert into tothinc2 (codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                                                         codcompw,qtypayda,qtypayhr,qtypaysc,amtpay,
                                                                         costcent,codsys,codcreate,coduser)
                                                            values (j.codempid, j.dteyrepay, j.dtemthpay, j.numperiod, v_codincbf ,
                                                                         j.codcomp, null, null, null, stdenc(v_amtpay2, j.codempid, para_chken),
                                                                         v_costcent, 'BF' ,p_coduser,p_coduser);
                               end if;--if nvl(v_amtpay2,0) <> 0 then

                               v_numrec  := v_numrec + 1;
                               update tobfinf
                                     set flgtranpy    = 'Y' ,
                                          coduser      = p_coduser
                                where rowid = j.rowid;
                     end if; --if v_codincbf  is not null then

                     commit;
                end loop; --c_tobfinf

  end loop;   -- for emp

--Redmine #3529
  update tprocount
    set  qtyproc = nvl(qtyproc,0) + nvl(v_numrec,0),
         qtyerr   = nvl(qtyerr,0) + nvl(v_numerr,0),
         flgproc  = 'Y' ,
         codempid = null,
         remark   = null,
         dteupd   = sysdate
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc;
--Redmine #3529
     commit;

exception when others then
  rollback;
  v_sqlerrm := sqlerrm;
 	update tprocount
     set qtyerr   = nvl(qtyerr,0) + nvl(v_numerr,0),
         codempid = v_codempid ,
         dteupd   = sysdate,
         flgproc  = 'E',
         remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,500)
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc;
     commit;
end cal_process2;

end HRBF45B_batch;

/
