--------------------------------------------------------
--  DDL for Package Body HRPY35B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY35B_BATCH" as


procedure start_process (p_codcompy		in	varchar2,
                         p_dteyrepay  in	number,
                         p_dtemthpay  in	number,
                         p_numperiod  in	number,
                         p_typpayroll in	varchar2,
                         p_coduser		in	varchar2) is
begin
  indx_codcompy     := p_codcompy;
  indx_dteyrepay    := p_dteyrepay;
  indx_dtemthpay    := p_dtemthpay;
  indx_numperiod    := p_numperiod;
  indx_typpayroll   := p_typpayroll;
 	para_coduser	 	  := p_coduser;


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

	v_periodst		number;
	v_perioden		number;

   cursor c_ttaxcur is
     select codempid,codcomp,numlvl
       from ttaxcur
      where codcomp     like indx_codcompy||'%'
        and dteyrepay    = (indx_dteyrepay - para_zyear)
        and dtemthpay    = indx_dtemthpay
        and numperiod    between v_periodst and v_perioden
        and typpayroll   = nvl(indx_typpayroll,typpayroll)
        and stddec(amtnet,codempid,para_chken) >= 0
	 order by codempid;

begin

  if indx_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

	if nvl(indx_numperiod,0) > 0 then
		v_periodst := indx_numperiod;
		v_perioden := indx_numperiod;
	else
		v_periodst := 1;
		v_perioden := 9;
	end if;

  delete tprocemp where codapp = para_codapp and coduser = para_coduser; commit;
  for r_emp in c_ttaxcur loop
    v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
    if v_flgsecu then
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
  v_stmt			varchar2(1000 char);
  v_interval	varchar2(50 char);
  v_finish		varchar2(1 char);

  type a_number is table of number index by binary_integer;
     a_jobno	a_number;
begin

  --/*
  for i in 1..para_numproc loop
    v_stmt := 'hrpy35b_batch.cal_process('''||para_codapp||''','''||para_coduser||''','||i||','''
              ||indx_codcompy||''','
              ||indx_dteyrepay||','
              ||indx_dtemthpay||','
              ||indx_numperiod||');';

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
  --*/
  -- hrpy35b.cal_process(para_codapp,para_coduser,1,indx_codcompy ,indx_dteyrepay ,indx_dtemthpay ,indx_numperiod );
end;
procedure cal_process (p_codapp   	in  varchar2,
                       p_coduser   	in  varchar2,
                       p_numproc	  in  number,
                       p_codcompy		in	varchar2,
                       p_dteyrepay  in	number,
                       p_dtemthpay  in	number,
                       p_numperiod  in	number) is

	v_periodst		number;
	v_perioden		number;
  v_flgsecu			boolean;
  v_codempid		temploy1.codempid%type;
  v_codcomp			tcenter.codcomp%type;
  v_apcode 			varchar2(4 char);
  v_codpay			tgltabi.codpay%type;
  v_numperiod		number;
  v_amtgl 			number;
  v_flgcal			boolean;
  v_stmt				varchar2(4000 char);
  v_taccap			boolean;
  v_taccdep			boolean;
  v_tgltabi			boolean;
  v_tsecdepdr		boolean;
  v_tsecdepcr		boolean;
  v_cent				varchar2(10 char);
  v_chk         number := 0;
  chk_exp       number := 0;
  x							number;
  v_max					number;
  v_bankcd			tcontrpy.codpaypy9%type;
  v_flgfee			varchar2(1 char);
  v_numerr      number := 0;

  type vchar is table of tinexinf.codpay%type index by binary_integer;
    v_cdpay			vchar;
    v_flg				vchar;

  type vchar2 is table of tcenter.codcomp%type index by binary_integer;
    v_comp			vchar2;

  type vnum is table of number index by binary_integer;
    v_amt			  	vnum;
   -- v_typamt      vnum;

  cursor c_emp is
    select a.codempid,b.codcomp,b.numlvl,b.typpayroll,b.typemp
      from tprocemp a, temploy1 b
     where a.codempid = b.codempid
       and a.codapp   = p_codapp
       and a.coduser  = p_coduser
       and a.numproc  = p_numproc
    order by a.codempid;

  cursor c_ttaxcur is
    select a.codempid, a.codcomp, a.numlvl,   a.typpayroll, a.typemp, a.numperiod,
           a.typpaymt, a.bankfee, a.bankfee2, a.codgrpgl
      from ttaxcur a --,temploy1 b where a.codempid  = b.codempid
     where a.codempid  = v_codempid
       and a.dteyrepay = (p_dteyrepay - para_zyear)
       and a.dtemthpay = p_dtemthpay
       and a.numperiod between v_periodst and v_perioden
       and stddec(a.amtnet,a.codempid,para_chken) >= 0
  order by codempid;

  cursor c_tsinexct is
    select codpay, nvl(stddec(amtpay,codempid,para_chken),0) amtpay,codcomp
      from tsinexct
     where codempid  = v_codempid
       and dteyrepay = (p_dteyrepay - para_zyear)
       and dtemthpay = p_dtemthpay
       and numperiod = v_numperiod
  order by codpay;

  cursor c_taccap is
    select apcode,typpaymt
      from taccap
     where codcompy = p_codcompy
       and apcode   = v_apcode
	  order by apcode;

  cursor c_tgltabi is
    select b.codaccdr,b.scodaccdr,decode(b.costcentdr,null,'Y','N') as flgpostdr,b.costcentdr,
	         b.codacccr,b.scodacccr,decode(b.costcentcr,null,'Y','N') as flgpostcr,b.costcentcr
	    from tgltabi a, tglhtabi b
	   where a.codcompy = p_codcompy
       and a.apcode   = v_apcode
	     and codpay     = v_codpay
       and a.apcode   = b.apcode
       and a.apgrpcod = b.apgrpcod
       and a.codcompy = b.codcompy
	order by a.apcode,codpay;

begin

  if p_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

	if nvl(p_numperiod,0) > 0 then
		v_periodst := p_numperiod;
		v_perioden := p_numperiod;
	else
		v_periodst := 1;
		v_perioden := 9;
	end if;

	begin
		select codpaypy9 into v_bankcd
		  from tcontrpy
		 where codcompy = p_codcompy
		   and dteeffec = (select max(dteeffec)
		                     from tcontrpy
		                    where codcompy = p_codcompy
		                      and dteeffec <= sysdate);
	exception when no_data_found then
		v_bankcd := null;
	end;
  delete ttemperr where coduser = p_coduser and codapp = p_codapp||p_numproc  ; --and temp32 = p_numproc;
  v_numerr := 0;
  for i in c_emp loop
    v_codempid  := i.codempid;
    for r_ttaxcur in c_ttaxcur loop
      v_codcomp   := r_ttaxcur.codcomp;
      v_numperiod := r_ttaxcur.numperiod;

--<<user14||STA3590278
      for i in 1..50 loop
--for i in 1..20 loop
-->>user14||STA3590278
        v_cdpay(i)  := null;
        v_comp(i)   := null;
        v_flg(i)    := null;
        v_amt(i)    := 0;
        --v_typamt(i) := 0;
      end loop; --for i in 1..50 loop
      x     := 0;
      v_max := 0;

      for r_tsincexp in c_tsinexct loop
        chk_exp      := chk_exp + 1;
        x            := x + 1;
        v_max        := x;
        v_cdpay(x)   := r_tsincexp.codpay;
        v_comp(x)    := r_tsincexp.codcomp;
        v_amt(x)     := r_tsincexp.amtpay;
        --v_typamt(x)  := r_tsincexp.typamt;
      end loop; -- r_tsincexp

      if (r_ttaxcur.typpaymt = 'BK') and (v_bankcd is not null) and (nvl(r_ttaxcur.bankfee,0) + nvl(r_ttaxcur.bankfee2,0) > 0) then
        v_flgfee := 'N';
      else
        v_flgfee := 'Y';
      end if;
      v_taccap := false;

      v_apcode := r_ttaxcur.codgrpgl;
      for r_taccap in c_taccap loop
        v_apcode := r_taccap.apcode;
        v_flgcal := true;
        if (r_taccap.typpaymt <> 'ALL' ) and (r_taccap.typpaymt <> r_ttaxcur.typpaymt)   then
          v_flgcal := false;
        end if;
        if v_flgcal then
          v_taccap := true;
          for j in 1..v_max loop
            if v_flg(j) is null then
              v_tgltabi := false;
              v_codpay  := v_cdpay(j);
              v_amtgl   := v_amt(j);
              for r_tgltabi in c_tgltabi loop
                v_flg(j)  := 'Y';
                v_chk     := v_chk + 1;
                v_tgltabi := true;
                /*begin
                  select codcompgl into v_cent
                    from tsecdep
                   where codcomp = v_comp(j);
                exception when no_data_found then
                  v_cent := null;
                end;*/
                begin
                  select costcent into v_cent
                    from tcenter
                   where codcomp = v_comp(j);
                exception when no_data_found then
                  v_cent := null;
                end;
                cal_gl(v_codcomp,r_ttaxcur.codempid,p_codcompy,
                       p_dteyrepay,p_dtemthpay,v_numperiod,
                       v_apcode,v_cent,r_tgltabi.costcentdr,
                       r_tgltabi.codaccdr,r_tgltabi.scodaccdr,'DR',
                       v_amtgl,r_tgltabi.flgpostdr,r_taccap.typpaymt,
                       p_coduser,v_tsecdepdr);
                cal_gl(v_codcomp,r_ttaxcur.codempid,p_codcompy,
                       p_dteyrepay,p_dtemthpay,v_numperiod,
                       v_apcode,v_cent,r_tgltabi.costcentcr,
                       r_tgltabi.codacccr,r_tgltabi.scodacccr,'CR',
                       v_amtgl,r_tgltabi.flgpostcr,r_taccap.typpaymt,
                       p_coduser,v_tsecdepcr);

              end loop; -- for c_tgltabi
            end if;
          end loop; -- loop v_max
          -- Bank Fee
          if v_flgfee = 'N' then
            v_tgltabi := false;
            v_codpay  := v_bankcd;
            v_amtgl   := nvl(r_ttaxcur.bankfee,0) + nvl(r_ttaxcur.bankfee2,0);
            v_codcomp := r_ttaxcur.codcomp;
            for r_tgltabi in c_tgltabi loop
              v_chk     := v_chk + 1;
              v_tgltabi := true;
              /*begin
                select codcompgl into v_cent
                  from tsecdep
                 where codcomp = v_codcomp;
              exception when no_data_found then
                v_cent := null;
              end;*/
              begin
                select costcent into v_cent
                  from tcenter
                 where codcomp = v_codcomp;
              exception when no_data_found then
                v_cent := null;
              end;
              cal_gl(v_codcomp,r_ttaxcur.codempid,p_codcompy,
                     p_dteyrepay,p_dtemthpay,v_numperiod,
                     v_apcode,v_cent,r_tgltabi.costcentdr,
                     r_tgltabi.codaccdr,r_tgltabi.scodaccdr,'DR',
                     v_amtgl,r_tgltabi.flgpostdr,r_taccap.typpaymt,
                     p_coduser,v_tsecdepdr);


              cal_gl(v_codcomp,r_ttaxcur.codempid,p_codcompy,
                     p_dteyrepay,p_dtemthpay,v_numperiod,
                     v_apcode,v_cent,r_tgltabi.costcentcr,
                     r_tgltabi.codacccr,r_tgltabi.scodacccr,'CR',
                     v_amtgl,r_tgltabi.flgpostcr,r_taccap.typpaymt,
                     p_coduser,v_tsecdepcr);

              v_flgfee := 'Y';
            end loop; -- for c_tgltabi
          end if;

        end if;

      end loop; -- for c_taccap

      for k in 1..v_max loop
        if nvl(v_flg(k),'N') = 'N' then
          v_numerr := nvl(v_numerr,0) + 1;
          insert into ttemperr (coduser,codapp,numseq,
                                item01,item02,temp31,
                                item03)
                 values        (p_coduser,para_codapp||p_numproc,v_numerr,
                                r_ttaxcur.codempid,v_cdpay(k),v_amt(k),
                                'Y');
        end if;
      end loop;

      if v_flgfee = 'N' then
        v_numerr := nvl(v_numerr,0) + 1;
        insert into ttemperr (coduser,codapp,numseq,
                              item01,item02,temp31,
                              item03)
               values        (p_coduser,para_codapp||p_numproc,v_numerr,
                              r_ttaxcur.codempid,v_bankcd,v_amtgl,
                              'N');
      end if;
    end loop; -- for c_ttaxcur
  end loop;   -- for emp

	update tprocount
     set qtyerr   = nvl(qtyerr,0) + v_numerr,
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
         Flgproc  = 'E',
         remark   = substr('Error Step :'||v_err_step||' - '||v_sqlerrm,1,500)
   where codapp  = p_codapp
     and coduser = p_coduser
     and numproc = p_numproc ;
  commit;

end;

procedure cal_gl ( p_codcomp	  in	varchar2,
                   p_codempid	  in	varchar2,
                   p_codcompy   in	varchar2,
                   p_dteyrepay  in  number,
                   p_dtemthpay  in  number,
                   p_numperiod	in	number,
                   p_apcode			in	varchar2,
                   p_trcent			in  varchar2,
                   p_costcent		in	varchar2,
                   p_codacc			in	varchar2,
                   p_scodacc		in	varchar2,
                   p_flgdrcr		in	varchar2,
                   p_amtgl			in	number,
                   p_flgpost		in	varchar2,
                   p_typpaymt		in	varchar2,
                   p_coduser    in	varchar2,
                   p_tsecdep	 	in  out	boolean) is

  v_exist				boolean;
  v_costcent  	varchar2(10 char);
  v_typpaymt		varchar2(2 char);
  v_amtgl				number;
  v_flgdrcr			varchar2(2 char);

  cursor c_tgltrans is
    select rowid,flgdrcr,amtgl
      from tgltrans
     where codcompy  = p_codcompy
       and dteyrepay = (p_dteyrepay - para_zyear)
       and dtemthpay = p_dtemthpay
       and numperiod = p_numperiod
       and apcode		 = p_apcode
       and costcent  = v_costcent
       and codacc    = p_codacc
      and scodacc    = nvl(p_scodacc,' ');

begin
  if p_dteyrepay > 2500 then
    para_zyear  := 543;
  else
    para_zyear  := 0;
  end if;

v_err_step  := 2000;

	if p_codacc is not null then
		v_costcent := null;
		if p_flgpost = 'Y' then
      v_costcent := p_trcent;
		  p_tsecdep  := true;
		else
		  v_costcent := p_costcent;
			p_tsecdep  := true;
		end if;

v_err_step  := 2100;

		if v_costcent is not null then
			if p_typpaymt = 'CS' then
				v_typpaymt := '1';
			elsif p_typpaymt = 'BK' then
				v_typpaymt := '2';
			else
				v_typpaymt := '3';
			end if;

      v_exist   := false;
			v_flgdrcr := p_flgdrcr;
      for r_tgltrans in c_tgltrans loop
				v_exist := true;

v_err_step  := 2120;

				if r_tgltrans.flgdrcr = v_flgdrcr then
					v_amtgl := stddec(r_tgltrans.amtgl,p_codcompy,para_chken) + p_amtgl;
				else
					v_amtgl := stddec(r_tgltrans.amtgl,p_codcompy,para_chken) - p_amtgl;
					if v_amtgl < 0 then
						v_amtgl := abs(v_amtgl);
					else
						v_flgdrcr := r_tgltrans.flgdrcr;
					end if;
				end if;

				if v_amtgl = 0 then
					delete tgltrans where rowid = r_tgltrans.rowid;
				else
					update tgltrans
						set amtgl   = stdenc(v_amtgl,p_codcompy,para_chken),
								flgdrcr = v_flgdrcr,
						    coduser = p_coduser
						where rowid = r_tgltrans.rowid;
				end if;
      end loop;

v_err_step  := 2200;

      if not v_exist then
				insert into tgltrans (codcompy,dteyrepay,dtemthpay,
                              numperiod,apcode,costcent,
                              codacc,scodacc,typpaymt,
                              flgdrcr,amtgl,dtetrans,
                              coduser)
				       values        (p_codcompy,(p_dteyrepay - para_zyear),p_dtemthpay,
                              p_numperiod,p_apcode,v_costcent,
                              p_codacc,nvl(p_scodacc,' '),v_typpaymt,
                              p_flgdrcr,stdenc(p_amtgl,p_codcompy,para_chken),trunc(sysdate),
                              p_coduser);
      end if;
		end if; -- v_costcent is not null
v_err_step  := 2299;
	end if; -- p_codacc is not null
end;

end HRPY35B_BATCH;

/
