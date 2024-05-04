--------------------------------------------------------
--  DDL for Package Body HRRP2PB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2PB_BATCH" is

    procedure start_process is
        v_coduser    temploy1.coduser%type := 'AUTOBATCH';
        v_msgerror   varchar2(1000 char) := null;
        v_descerr    varchar2(1000 char) := null;
        v_status     varchar2(1 char) := 'C';
        v_numrec     number := 0;
        v_error      varchar2(10 char);
        v_err_table	 varchar2(50 char);
        v_numrec2    number;
        v_error2     varchar2(10 char);
        v_err_table2 varchar2(50 char);
        v_sysdate    date := sysdate;

	begin
		begin
		   --Insert Update tmanpwmh ,tmanpwmd
       process_tmanpwmh_d ; --xxx  insert_tmanpwmh(out v_numseq)--insert_tmanpwmd(out v_numseq)
       update_ttmovemt ;--xxx  insert_tmanpwmh(out v_numseq)--insert_tmanpwmd(out v_numseq)
       --Insert Update tmanpwm
       process_temploy_month ;
       --Insert Update tmanpw
       process_temploy_year ;
		exception when others then
		  rollback;
		  v_status := 'E';
      v_descerr := substr( dbms_utility.format_error_backtrace() /*sqlerrm*/,1,200);
		end;
		--
		if v_status = 'C' and v_error is null then
			v_msgerror := 'Complete: '||v_numrec;
		elsif v_error is not null then
            v_msgerror := 'Error(1): '||v_error||' '||get_errorm_name(v_error,'102')||' '||v_err_table;
        else
			v_msgerror := substr('Error(2): '||v_numrec||' '||v_descerr,1,200);
		end if;
	  --
	  begin
	  	delete tautolog where codapp = 'HRRP2PB' and dtecall = v_sysdate;
		  insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
		                values('HRRP2PB',v_sysdate,v_sysdate,sysdate,'C',v_numrec,v_coduser);
	  end;
	  commit;
	end; -- start_process

  procedure cal_process(p_codcomp		    in	varchar2,
                        p_dteyrbug	    in	number,
                        p_dtemthbugstr	in	number,
                        p_dtemthbugend	in	number,
                        p_coduser	  	  in	varchar2,
                        p_numrec	  	  out number,
                        p_error         out varchar2,
                        p_err_table     out varchar2) is

    v_secur			    boolean;
    v_chkcal		    boolean;
    v_numrec        number;
    v_error         number := 0;
    v_status        varchar2(1 char);
    v_msgerror      varchar2(1000 char) := null;
    v_sysdate       date   := trunc(sysdate);

	begin
    para_coduser            := p_coduser;
    p_numrec                := 0;
    para_codcomp            := p_codcomp ;
    para_dteyrbug           := p_dteyrbug;
    para_dteyrbug           := p_dteyrbug;
    para_dtemthbugstr       := p_dtemthbugstr;
    para_dtemthbugend       := p_dtemthbugend ;

    if p_coduser <> 'AUTOBATCH' then
      begin
        select get_numdec(numlvlst,p_coduser) numlvlst, get_numdec(numlvlen,p_coduser) numlvlen
          into para_zminlvl,para_zwrklvl
          from tusrprof
         where coduser = p_coduser;
      exception when others then null;
      end;
    end if;
    for i in p_dtemthbugstr..p_dtemthbugend loop
            para_tmonth := i;
            para_st_date := to_date('01/'||para_tmonth||'/'||para_dteyrbug ,'dd/mm/yyyy');
            para_en_date := last_day(para_st_date) ;
            start_process;--(v_numrec);
    end loop;
    p_numrec := p_numseq;
	end;

PROCEDURE process_tmanpwmh_d  IS

  v_codempid   varchar2(10);
  v_codgrpos   varchar2(8);
  v_numseq     number :=0 ;

  cursor t_temploy1 is
	  select codempid,codcomp,codpos,codempmt,typemp,numlvl,codsex,codbrlc,codedlv,typpayroll,codcalen,codjob,jobgrade
	  from   temploy1
	  where  codcomp  like  para_codcomp||'%'
    --and    codempid  not in (select codempid from tmanpwh )
	  order by codempid ;
BEGIN
	   for i in t_temploy1 loop
        begin
          select codgrpos into v_codgrpos
          from   tgrppos
          where codcompy  = hcm_util.get_codcomp_level(i.codcomp,1)
          and   codpos = i.codpos ;
        exception when others then
          v_codgrpos := null ;
        end ;
				insert_tmanpwmh(i.codempid,
                                i.codempmt,
                                i.typemp     ,
                                i.codcomp    ,
                                i.codpos     ,
                                i.numlvl     ,
                                i.codbrlc   ,
                                i.codedlv     ,
                                i.typpayroll ,
                                i.codcalen    ,
                                i.codjob     ,
                                i.jobgrade   ,
                                v_codgrpos   ,
                                v_numseq);         
				insert_tmanpwmd(para_dteyrbug,para_tmonth,i.codempid,v_numseq);               
	  end loop;
    commit;
    p_numseq := v_numseq;
END;

PROCEDURE process_temploy_month  IS
  v_codcomp   varchar2(40) ;
  v_codpos    varchar2(30) ;
  v_dteyrbug	number;
  v_dtemthbug	number;
  v_qtytotrf	number;
  v_qtytotro	number;
  v_qtytotrc	number;
  v_qtytotre	number;
  v_qtybgman	number;
  v_qtyexman	number;
  v_qtyexmanf	number;
  v_qtyexmanm	number;
  v_qtypromote	number;
  v_amtpromote	number;
  v_amtsal	  number;
  v_sumhur 	  number;
  v_sumday 	  number;
  v_summth	  number;

  cursor c_temploy1 is
        select codcomp,codpos,count(codempid) qty,
               sum(decode(codsex,'F',1,0)) f_qty,
               sum(decode(codsex,'M',1,0)) m_qty
        from   temploy1
				where  codcomp  like para_codcomp||'%'
				and    staemp   in ('1','3')
        and    codpos   is not null
				and    dteempmt <= para_en_date
				group by codcomp,codpos ;

  cursor c_temploy3 is
      select   codempmt ,codcomp,
               stddec(amtincom1,a.codempid,para_chken ) amtincom1 ,
               stddec(amtincom2,a.codempid,para_chken ) amtincom2 ,
               stddec(amtincom3,a.codempid,para_chken ) amtincom3 ,
               stddec(amtincom4,a.codempid,para_chken ) amtincom4 ,
               stddec(amtincom5,a.codempid,para_chken ) amtincom5 ,
               stddec(amtincom6,a.codempid,para_chken ) amtincom6 ,
               stddec(amtincom7,a.codempid,para_chken ) amtincom7 ,
               stddec(amtincom8,a.codempid,para_chken ) amtincom8 ,
               stddec(amtincom9,a.codempid,para_chken ) amtincom9 ,
               stddec(amtincom10,a.codempid,para_chken ) amtincom10
        from   temploy1 a, temploy3 b
				where  a.codempid = b.codempid
        and    codcomp    = v_codcomp
        and    codpos     = v_codpos
        and    staemp   in ('1','3')
				and    dteempmt <= para_en_date ;
begin
    delete tmanpwm
	  where  dteyrbug  = para_dteyrbug
	  and    dtemthbug = para_tmonth
    and    codcomp  like para_codcomp||'%' ;
    for  i in c_temploy1 loop
          v_codcomp    := i.codcomp ;
          v_codpos     := i.codpos ;
          -- กำลังคนที่โอนเข้า (ในเดือนนี้)
          select count(distinct codempid) into v_qtytotrf
          from   ttmovemt
          where  staupd    = 'U'
          and 	 codcomp   = v_codcomp
          and		 codpos    = v_codpos
          and		(codcompt  <> v_codcomp or codposnow <> v_codpos )
          and    dteeffec between para_st_date and para_en_date ;

          -- กำลังคนที่โอนออก (ในเดือนนี้)
          select count(distinct codempid) into v_qtytotro
          from   ttmovemt
          where  staupd    = 'U'
          and 	 codcompt  = v_codcomp
          and		 codposnow = v_codpos
          and		(codcomp  <> v_codcomp or codpos <> v_codpos )
          and    dteeffec between para_st_date and para_en_date ;
          -- กำลังคนที่มีอยู่จริง (ต้นเดือน)
          v_qtyexman   := i.qty ; --???
          v_qtyexmanf  := i.f_qty;
          v_qtyexmanm  := i.m_qty ;
          -- กำลังคนที่รับใหม่ (ในเดือนนี้)
          v_qtytotrc   := 0;
          -- กำลังคนที่ลาออก (ในเดือนนี้)
          begin
              select count(distinct codempid) into v_qtytotre
              from   ttpminf a,tcodmove b
              where  codcomp  = v_codcomp
              and		 codpos   = v_codpos
              and    codtrn   = codcodec
              and		 codtrn   = '6' ;
          exception when others then
             v_qtytotre := 0 ;
          end ;
          -- อัตรากำลังตามงบประมาณ
          begin
            select qtybudgt into v_qtybgman
            from   tbudgetm
            where  dteyrbug = para_dteyrbug
            and 	 codcomp  = v_codcomp
            and		 codpos   = v_codpos
            and    dtereq   = (select max (dtereq)
                               from   tbudgetm
                               where  dteyrbug  = para_dteyrbug
                               and 	  codcomp = v_codcomp
                               and		codpos  = v_codpos ) ;
          exception when others then
             v_qtybgman := 0 ;
          end ;

          -- จำนวนคนที่ได้รับการเลื่อนตำแหน่ง
          select count(distinct codempid) into v_qtypromote
          from   ttmovemt a,tcodmove b
          where  staupd  = 'U'
          and 	 codcomp = v_codcomp
          and		 codpos  = v_codpos
          and    dteeffec between para_st_date and para_en_date
          and    codtrn  = codcodec
          and    typmove = '8';

          -- จำนวนเงินเลื่อนตำแหน่ง
          select sum( stddec(amtincadj1,a.codempid,para_chken )  +
                      stddec(amtincadj2,a.codempid,para_chken )  +
                      stddec(amtincadj3,a.codempid,para_chken )  +
                      stddec(amtincadj4,a.codempid,para_chken )  +
                      stddec(amtincadj5,a.codempid,para_chken )  +
                      stddec(amtincadj6,a.codempid,para_chken )  +
                      stddec(amtincadj7,a.codempid,para_chken )  +
                      stddec(amtincadj8,a.codempid,para_chken )  +
                      stddec(amtincadj9,a.codempid,para_chken )  +
                      stddec(amtincadj10,a.codempid,para_chken ) )
          into   v_amtpromote
          from   ttmovemt a,tcodmove b
          where  staupd  = 'U'
          and 	 codcomp = v_codcomp
          and		 codpos  = v_codpos
          and    dteeffec between para_st_date and para_en_date
          and    codtrn  = codcodec
          and    typmove = '8';

          -- เงินเดือนปัจจุบันรวม (รายได้ประจำทุกตัว
          v_amtsal     := 0 ;
          for j in c_temploy3 loop
              get_wage_income ( hcm_util.get_codcomp_level(j.codcomp,1),j.codempmt,
                               j.amtincom1,j.amtincom2,
                               j.amtincom3,j.amtincom4,
                               j.amtincom5,j.amtincom6,
                               j.amtincom7,j.amtincom8,
                               j.amtincom9,j.amtincom10,
                               v_sumhur ,v_sumday , v_summth) ;
              v_amtsal := v_amtsal + nvl(v_summth,0)  ;
          end loop;

          insert into tmanpwm (dteyrbug ,dtemthbug,codcomp,codpos,
                                qtytotrf,qtytotro,qtytotrc,
                                qtytotre,qtybgman,qtyexman,
                                qtyexmanf,qtyexmanm,qtypromote,
                                amtpromote,amtsal)
                       values  (para_dteyrbug, para_tmonth,
                                i.codcomp,i.codpos ,
                                v_qtytotrf,v_qtytotro,v_qtytotrc,
                                v_qtytotre,v_qtybgman,v_qtyexman,
                                v_qtyexmanf,v_qtyexmanm,v_qtypromote,
                                v_amtpromote,v_amtsal);
    end loop;
    commit;
end;

PROCEDURE process_temploy_year  IS
  v_codcomp   varchar2(40) ;
  v_codpos    varchar2(30) ;
  v_dteyrbug	number;
  v_dtemthbug	number;
  v_qtytotrf	number;
  v_qtytotro	number;
  v_qtytotrc	number;
  v_qtytotre	number;
  v_qtybgman	number;
  v_qtyexman	number;
  v_qtyexmanf	number;
  v_qtyexmanm	number;
  v_qtypromote	number;
  v_amtpromote	number;
  v_amtsal	  number;
  v_sumhur 	  number;
  v_sumday 	  number;
  v_summth	  number;

  cursor c_temploy1 is
        select codcomp,codpos,count(codempid) qty,
               sum(decode(codsex,'F',1,0)) f_qty,
               sum(decode(codsex,'M',1,0)) m_qty
        from   temploy1
				where  codcomp  like para_codcomp||'%'
				and    staemp   in ('1','3')
        and    codpos   is not null
        and    ( staemp   in ('1','3')  or (staemp = 9 and dteeffex >= para_en_date)  )
				and    to_char(dteempmt,'yyyy') <= para_dteyrbug
				group by codcomp,codpos ;

  cursor c_temploy3 is
      select   codempmt ,codcomp,
               stddec(amtincom1,a.codempid,para_chken ) amtincom1 ,
               stddec(amtincom2,a.codempid,para_chken ) amtincom2 ,
               stddec(amtincom3,a.codempid,para_chken ) amtincom3 ,
               stddec(amtincom4,a.codempid,para_chken ) amtincom4 ,
               stddec(amtincom5,a.codempid,para_chken ) amtincom5 ,
               stddec(amtincom6,a.codempid,para_chken ) amtincom6 ,
               stddec(amtincom7,a.codempid,para_chken ) amtincom7 ,
               stddec(amtincom8,a.codempid,para_chken ) amtincom8 ,
               stddec(amtincom9,a.codempid,para_chken ) amtincom9 ,
               stddec(amtincom10,a.codempid,para_chken ) amtincom10
        from   temploy1 a, temploy3 b
				where  a.codempid = b.codempid
        and    codcomp    = v_codcomp
        and    codpos     = v_codpos
        and    ( staemp   in ('1','3')  or (staemp = 9 and dteeffex >= para_en_date)  )
				and    to_char(dteempmt,'yyyy') <= para_dteyrbug  ;
begin
    delete tmanpw
	  where  dteyrbug  = para_dteyrbug
	  and    codcomp  like para_codcomp||'%' ;
    para_st_date := to_date('01/01/'||para_dteyrbug,'dd/mm/yyyy') ;
    para_en_date := to_date('31/12/'||para_dteyrbug,'dd/mm/yyyy') ;
    for  i in c_temploy1 loop
          v_codcomp    := i.codcomp ;
          v_codpos     := i.codpos ;
          -- กำลังคนที่โอนเข้า (ในเดือนนี้)
          select count(distinct codempid) into v_qtytotrf
          from   ttmovemt
          where  staupd    = 'U'
          and 	 codcomp   = v_codcomp
          and		 codpos    = v_codpos
          and		(codcompt  <> v_codcomp or codposnow <> v_codpos )
          and    dteeffec between para_st_date and para_en_date ;

          -- กำลังคนที่โอนออก (ในเดือนนี้)
          select count(distinct codempid) into v_qtytotro
          from   ttmovemt
          where  staupd    = 'U'
          and 	 codcompt  = v_codcomp
          and		 codposnow = v_codpos
          and		(codcomp  <> v_codcomp or codpos <> v_codpos )
          and    dteeffec between para_st_date and para_en_date ;
          -- กำลังคนที่มีอยู่จริง (ต้นเดือน)
          v_qtyexman   := i.qty ; --???
          v_qtyexmanf  := i.f_qty;
          v_qtyexmanm  := i.m_qty ;
          -- กำลังคนที่รับใหม่ (ในเดือนนี้)
          v_qtytotrc   := 0;
          -- กำลังคนที่ลาออก (ในเดือนนี้)
          begin
              select count(distinct codempid) into v_qtytotre
              from   ttpminf a,tcodmove b
              where  codcomp  = v_codcomp
              and		 codpos   = v_codpos
              and    codtrn   = codcodec
              and		 codtrn   = '6' ;
          exception when others then
             v_qtytotre := 0 ;
          end ;
          -- อัตรากำลังตามงบประมาณ
          begin
            select qtybudgt into v_qtybgman
            from   tbudgetm
            where  dteyrbug = para_dteyrbug
            and 	 codcomp  = v_codcomp
            and		 codpos   = v_codpos
            and    dtereq   = (select max (dtereq)
                               from   tbudgetm
                               where  dteyrbug  = para_dteyrbug
                               and 	  codcomp = v_codcomp
                               and		codpos  = v_codpos ) ;
          exception when others then
             v_qtybgman := 0 ;
          end ;

          -- จำนวนคนที่ได้รับการเลื่อนตำแหน่ง
          select count(distinct codempid) into v_qtypromote
          from   ttmovemt a,tcodmove b
          where  staupd  = 'U'
          and 	 codcomp = v_codcomp
          and		 codpos  = v_codpos
          and    dteeffec between para_st_date and para_en_date
          and    codtrn  = codcodec
          and    typmove = '8';

          -- จำนวนเงินเลื่อนตำแหน่ง
          select sum( stddec(amtincadj1,a.codempid,para_chken )  +
                      stddec(amtincadj2,a.codempid,para_chken )  +
                      stddec(amtincadj3,a.codempid,para_chken )  +
                      stddec(amtincadj4,a.codempid,para_chken )  +
                      stddec(amtincadj5,a.codempid,para_chken )  +
                      stddec(amtincadj6,a.codempid,para_chken )  +
                      stddec(amtincadj7,a.codempid,para_chken )  +
                      stddec(amtincadj8,a.codempid,para_chken )  +
                      stddec(amtincadj9,a.codempid,para_chken )  +
                      stddec(amtincadj10,a.codempid,para_chken ) )
          into   v_amtpromote
          from   ttmovemt a,tcodmove b
          where  staupd  = 'U'
          and 	 codcomp = v_codcomp
          and		 codpos  = v_codpos
          and    dteeffec between para_st_date and para_en_date
          and    codtrn  = codcodec
          and    typmove = '8';

          -- เงินเดือนปัจจุบันรวม (รายได้ประจำทุกตัว
          v_amtsal     := 0 ;
          for j in c_temploy3 loop
              get_wage_income ( hcm_util.get_codcomp_level(j.codcomp,1),j.codempmt,
                               j.amtincom1,j.amtincom2,
                               j.amtincom3,j.amtincom4,
                               j.amtincom5,j.amtincom6,
                               j.amtincom7,j.amtincom8,
                               j.amtincom9,j.amtincom10,
                               v_sumhur ,v_sumday , v_summth) ;
              v_amtsal := v_amtsal + nvl(v_summth,0)  ;
          end loop;

          insert into tmanpw (dteyrbug ,codcomp,codpos,
                                qtytotrf,qtytotro,qtytotrc,
                                qtytotre,qtybgman,qtyexman,
                                qtyexmanf,qtyexmanm,qtypromote,
                                amtpromote,
                                dtecreate,codcreate,dteupd,coduser)
                       values  (para_dteyrbug, i.codcomp,i.codpos ,
                                v_qtytotrf,v_qtytotro,v_qtytotrc,
                                v_qtytotre,v_qtybgman,v_qtyexman,
                                v_qtyexmanf,v_qtyexmanm,v_qtypromote,
                                v_amtpromote,
                                sysdate,para_coduser,sysdate,para_coduser );
    end loop;
    commit;
end;

PROCEDURE update_ttmovemt  IS
  v_codempid   varchar2(10);
  v_codgrpos   varchar2(8);
  v_numseq     number ;
  v_chk        number ;

  cursor t_codempid is
	  select distinct codempid
	  from   ttmovemt
	  where  codcomp like para_codcomp||'%'
	  and	 dteeffec between para_st_date and para_en_date
	  and	 staupd   in ('C','U')
	  order by codempid ;

  cursor t_ttmovemt1 is
	  select codempid,dteeffec,codcomp,codpos,codempmt,typemp,numlvl,codsex,codbrlc,codedlv,typpayroll,codcalen,codjob,jobgrade
	  from   ttmovemt
	  where  codempid = v_codempid
	  and	 dteeffec between para_st_date and para_en_date
	  and	 staupd   in ('C','U')
	  order by dteeffec desc,numseq desc;

 cursor t_ttmovemt2 is
	  select codempid,dteeffec,codcomp,codpos,codcompt,codposnow
	  from   ttmovemt
	  where  codempid = v_codempid
	  and	   dteeffec between para_st_date and para_en_date
	  and	   staupd   in ('C','U')
    and    codcomp||codpos <> codcompt||codposnow
	  order by dteeffec desc,numseq desc;

BEGIN
  for j in t_codempid loop
  	v_codempid := j.codempid ;
	  for i in t_ttmovemt1 loop
				begin
          select codgrpos into v_codgrpos
          from   tgrppos
          where codcompy  = hcm_util.get_codcomp_level(i.codcomp,1)
          and   codpos = i.codpos ;
        exception when others then
          v_codgrpos := null ;
        end ;
        insert_tmanpwmh(i.codempid,
                        i.codempmt,
                        i.typemp     ,
                        i.codcomp    ,
                        i.codpos     ,
                        i.numlvl     ,
                        i.codbrlc   ,
                        i.codedlv     ,
                        i.typpayroll ,
                        i.codcalen    ,
                        i.codjob     ,
                        i.jobgrade   ,
                        v_codgrpos   ,
                        v_numseq);
				insert_tmanpwmd(para_dteyrbug,para_tmonth,v_codempid,v_numseq);
				exit;
	  end loop;
    for i in t_ttmovemt2 loop
        begin
            select 1
            into   v_chk
            from   tposempd
            where  codempid = v_codempid
            and    dteefpos is null
            and    codcomp = i.codcomp
            and    codpos  = i.codpos
            and    rownum  = 1 ;
            update tposempd set dteefpos = i.dteeffec where codempid = v_codempid and codcomp = i.codcomp and codpos = i.codpos and dteefpos is null ;
            --exit ;
        exception when no_data_found then
          null ;
        end ;
        begin
            select 1
            into   v_chk
            from   tsuccpln
            where  codempid = v_codempid
            and    dteeffec is null
            and    codcomp = i.codcomp
            and    codpos  = i.codpos
            and    rownum  = 1 ;
            update tsuccpln set dteeffec = i.dteeffec where codempid = v_codempid and codcomp = i.codcomp and codpos = i.codpos and dteeffec is null ;
            --exit ;
        exception when no_data_found then
          null ;
        end ;
    end loop;
  end loop;
  commit;

END;

PROCEDURE insert_tmanpwmh(
         v_codempid     in varchar2,
         v_codempmt     in varchar2,
         v_typemp       in varchar2,
         v_codcomp      in varchar2,
         v_codpos       in varchar2,
         v_numlvl       in number,
         v_codbrlc      in varchar2,
         v_codedlv      in varchar2,
         v_typpayroll   in varchar2,
         v_codcalen     in varchar2,
         v_codjob       in varchar2,
         v_jobgrade     in varchar2,
         v_codgrpos     in varchar2,
         p_numseq       in out number ) IS

         v_numseq       number;

BEGIN
            begin
                select numseq into v_numseq
                from tmanpwh
                where codempid  = v_codempid
                and  codempmt   = v_codempmt
                and  typemp     = v_typemp
                and  codcomp    = v_codcomp
                and  codpos     = v_codpos
                and  numlvl     = v_numlvl
                and  codbrlc    = v_codbrlc
                and  nvl(codedlv,'???') = nvl(v_codedlv,'???')
                and  typpayroll = v_typpayroll
                and  codcalen   = v_codcalen
                and  codjob     = v_codjob
                and  jobgrade   = v_jobgrade
                and rownum = 1 ;
            exception when no_data_found then
                v_numseq := null;
            end;

            if v_numseq is null then
                begin
                    select nvl(max(numseq),0) into v_numseq
                    from tmanpwh
                    where codempid = v_codempid;
                exception when no_data_found then
                    v_numseq := 0;
                end;
                v_numseq := nvl(v_numseq,0) + 1;
                insert into tmanpwh(   codempid,numseq,codempmt,
                                        typemp,codcomp,codpos,
                                        numlvl,codbrlc,codedlv,
                                        typpayroll,codcalen,codjob,
                                        jobgrade ,codgrpos ,dteyearl,dtemthl,
                                        dtecreate,codcreate,dteupd,coduser)
                              values(   v_codempid,v_numseq,v_codempmt,
                                        v_typemp,v_codcomp,v_codpos,
                                        v_numlvl,v_codbrlc,v_codedlv,
                                        v_typpayroll,v_codcalen,v_codjob,
                                        v_jobgrade  ,v_codgrpos ,null,null,
                                        sysdate,para_coduser,sysdate,para_coduser );
            end if;
            p_numseq := v_numseq;
            commit;

END;

PROCEDURE insert_tmanpwmd (p_year in number,p_month in number,p_codempid in varchar2,p_numseq in number )  IS
	v_count     number := 0;
  v_staemp    varchar2(1 char);
  v_codsex    varchar2(1 char);
  v_ageemp    number ;
  v_agework   number ;
  v_agepos    number ;
  v_agestep   number ;
  v_dteempmt  date ;
  v_dteempdb  date ;
  v_dteefpos  date ;
  v_dteefstep date ;
  v_dteeffex  date ;
  v_dteend    date ;
  v_codcomp   temploy1.codcomp%type;

  v_month     number ;
  v_day       number ;

BEGIN
	  	begin
        select  dteempmt,dteempdb ,dteefpos , dteefstep ,dteeffex ,codsex,staemp,codcomp
        into    v_dteempmt , v_dteempdb ,v_dteefpos , v_dteefstep,v_dteeffex ,v_codsex,v_staemp,v_codcomp
        from    temploy1
        where   codempid = p_codempid ;
      exception when no_data_found then
			  v_count := 0;
			end ;

      get_service_year(v_dteempdb,sysdate,'Y',v_ageemp,v_month,v_day ) ;
      get_service_year(v_dteempmt,least(v_dteend,nvl(v_dteeffex,sysdate)),'Y',v_agework,v_month,v_day ) ;
      get_service_year(v_dteefpos,least(v_dteend,nvl(v_dteeffex,sysdate)),'Y',v_agepos,v_month,v_day ) ;
      get_service_year(v_dteefstep,least(v_dteend,nvl(v_dteeffex,sysdate)),'Y',v_agestep,v_month,v_day ) ;

      begin
					select count(codempid) into v_count
					from  tmanpwd
					where codempid = p_codempid
					and   dteyear  = p_year
					and   dtemonth = p_month;
			exception when no_data_found then
				  v_count := 0;
			end;

			if v_count = 0 then
						insert into tmanpwd(codempid,dteyear,dtemonth,numseq,
                                 ageemp,agework,agepos,codcomp,staemp,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(p_codempid,p_year,p_month,p_numseq ,
                                 v_ageemp , v_agework, v_agepos, v_codcomp ,v_staemp,
                                 trunc(sysdate),para_coduser,trunc(sysdate),para_coduser);
			else
				 		update tmanpwd set
				 			     numseq  = p_numseq
				 		where codempid = p_codempid
						and   dteyear  = p_year
						and   dtemonth = p_month;
			end if;
END;
end HRRP2PB_BATCH;

/
