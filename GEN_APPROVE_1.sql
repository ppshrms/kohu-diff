--------------------------------------------------------
--  DDL for Package Body GEN_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GEN_APPROVE" is

procedure find_approve_name(p_codempid    in varchar2,    --EMPLOYEE for find all approver( or CODAPMAN from pre-seqno in AP)
                            p_seqno       in number,
                            p_flgappr     in varchar2,
                            p_codempap    in varchar2,
                            p_codcompap   in varchar2,
                            p_codposap    in varchar2,
                            p_codapp      in varchar2,
                            p_coduser     in varchar2,
                            p_stcodempid  in varchar2) is --EMPLOYEE for find all approver

  v_codempap        temploy1.codempid%type;
	v_codcompap       temploy1.codcomp%type;
  v_codposap        temploy1.codpos%type;
	v_codcomp         temploy1.codcomp%type;
  v_codpos          temploy1.codpos%type;

  v_codcompy        varchar2(10);
  v_codlinef        varchar2(4);
  v_dteeffec        date;
  v_pageno          number;
  v_rowno           number;
  v_columnno        number;
  v_torgprt         varchar2(1) := 'N';
  v_setorg2         varchar2(1) := 'N';
  v_staemp          varchar2(1);
  v_flgasem         varchar2(1);
  v_flag						varchar2(1);

  cursor c_temphead1 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codempid = p_codempid
  order by codempidh;

  cursor c_temphead2 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codcomp  = v_codcomp
       and codpos   = v_codpos
  order by codcomph,codposh;
  --
/*
	cursor c_torgprt is
		select a.codcompy,a.codlinef,a.dteeffec,a.pageno,a.rowno,a.columnno,a.codempid,
		       b.pagenoh,b.rownoh,b.columnnoh
		  from torgprt2 a,torgprt b
		 where a.codcompy  = b.codcompy
		   and a.codlinef  = b.codlinef
		   and a.dteeffec  = b.dteeffec
		   and a.pageno    = b.pageno
		   and a.rowno     = b.rowno
		   and a.columnno  = b.columnno
		   and a.codempid  = p_codempid
		   and b.flgappr   = 'A'
		   and rownum      = 1;

	cursor c_torgprt2_set is
		select codempid
		  from torgprt2
		 where codcompy  = v_codcompy
		   and codlinef  = v_codlinef
		   and dteeffec  = v_dteeffec
		   and pageno    = v_pageno
		   and rowno     = v_rowno
		   and columnno  = v_columnno
		   and rownum    = 1;

	cursor c_torgprt2_notset is
		select codcompp,codpospr
		  from torgprt
		 where codcompy  = v_codcompy
		   and codlinef  = v_codlinef
		   and dteeffec  = v_dteeffec
		   and pageno    = v_pageno
		   and rowno     = v_rowno
		   and columnno  = v_columnno
		   and flgappr   = 'A'
		   and rownum    = 1;

	cursor c_torgprt2_no is
		select codcompy,codlinef,dteeffec,pageno,rowno,columnno,pagenoh,rownoh,columnnoh
		  from torgprt
		 where codcompp  = v_codcomp
		   and codpospr  = v_codpos
		   and flgappr   = 'A';
*/
	cursor c_codapman is
	  select codempid from (select codempid
	                          from temploy1
	        								 where codcomp  = v_codcompap
	        									 and codpos   = v_codposap
	        									 and ( (staemp   in  ('1','3') and v_staemp = '3')
                                    or (staemp = '9' and v_staemp = '9') )
	        								 union
	        								select codempid
	        									from tsecpos
	        								 where codcomp  = v_codcompap
	        									 and codpos   = v_codposap
	        									 and dteeffec <= sysdate
	        									 and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
	        								) a
--	   where a.codempid not in (select b.codempid
--                                from torgprt2 b
--                               where b.codempid = a.codempid)
	order by codempid;
  --item1=APPROVER,item2=CODEMPAP,item3=CODCOMPAP,item4=CODPOSAP,item5=EMP_NO_COMPLETE

begin
  --
  --delete ttemprpt2 where codapp = p_codapp and codempid = p_coduser;
  --commit;
  --
  begin
    select codcomp,codpos
      into v_codcomp,v_codpos
      from temploy1
     where codempid = p_codempid;
  exception when no_data_found then return;
  end;
  --
  if p_flgappr = '1' then
  	v_flag := 'N';
    for j in c_temphead1 loop
    	v_flag := 'Y';
      v_codempap  := j.codempidh;
      v_codcompap := j.codcomph;
      v_codposap  := j.codposh;
      if j.codempidh is not null then
        insert_ttemprpt2(p_coduser,p_codapp,j.codempidh,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
      else
        v_staemp := '3';
        for r_codapman in c_codapman loop
          v_flgasem := 'Y';
          insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
        end loop;
        if v_flgasem = 'N' then
          v_staemp := '9';
          for r_codapman in c_codapman loop
            insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
          end loop;
        end if;
      end if;
    end loop;
    --
    if v_flag = 'N' then
	    for j in c_temphead2 loop
	      v_codempap  := j.codempidh;
	      v_codcompap := j.codcomph;
	      v_codposap  := j.codposh;
	      if j.codempidh is not null then
	        insert_ttemprpt2(p_coduser,p_codapp,j.codempidh,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
	      else
	        v_staemp := '3';
	        for r_codapman in c_codapman loop
	          v_flgasem := 'Y';
	          insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
	        end loop;
	        if v_flgasem = 'N' then
	          v_staemp := '9';
	          for r_codapman in c_codapman loop
	            insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
	          end loop;
	        end if;
	      end if;
	    end loop;
  	end if;

  elsif p_flgappr = '2' then
    v_torgprt     := 'N';
/*    for r_torgprt in c_torgprt loop
      v_torgprt   := 'Y';
      v_codcompy	:= r_torgprt.codcompy;
      v_codlinef	:= r_torgprt.codlinef;
      v_dteeffec	:= r_torgprt.dteeffec;
      v_pageno		:= r_torgprt.pagenoh;
      v_rowno			:= r_torgprt.rownoh;
      v_columnno	:= r_torgprt.columnnoh;
      v_setorg2   := 'N';
      for r_torgprt2_set in c_torgprt2_set loop
        v_setorg2   := 'Y';
        v_codempap  := r_torgprt2_set.codempid;
        v_codcompap := null;
        v_codposap  := null;
        insert_ttemprpt2(p_coduser,p_codapp,r_torgprt2_set.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
      end loop;
      if v_setorg2 = 'N' then
        for r_torgprt2_notset in c_torgprt2_notset loop
          v_codempap  := null;
          v_codcompap := r_torgprt2_notset.codcompp;
          v_codposap  := r_torgprt2_notset.codpospr;
          v_staemp := '3';
          for r_codapman in c_codapman loop
            v_flgasem := 'Y';
            insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
          end loop;
          if v_flgasem = 'N' then
            v_staemp := '9';
            for r_codapman in c_codapman loop
              insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
            end loop;
          end if;
        end loop;
      end if;
    end loop;
    --
    if v_torgprt = 'N' then
      for r_torgprt2_no in c_torgprt2_no loop
        v_codcompy	:= r_torgprt2_no.codcompy;
        v_codlinef	:= r_torgprt2_no.codlinef;
        v_dteeffec	:= r_torgprt2_no.dteeffec;
        v_pageno		:= r_torgprt2_no.pagenoh;
        v_rowno			:= r_torgprt2_no.rownoh;
        v_columnno	:= r_torgprt2_no.columnnoh;
        v_setorg2   := 'N';
        for r_torgprt2_set in c_torgprt2_set loop
          v_setorg2  := 'Y';
          v_codempap  := r_torgprt2_set.codempid;
          v_codcompap := null;
          v_codposap  := null;
          insert_ttemprpt2(p_coduser,p_codapp,r_torgprt2_set.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
        end loop;
        if v_setorg2 = 'N' then
          for r_torgprt2_notset in c_torgprt2_notset loop
            v_codempap  := null;
            v_codcompap := r_torgprt2_notset.codcompp;
            v_codposap  := r_torgprt2_notset.codpospr;
            v_staemp := '3';
            for r_codapman in c_codapman loop
              v_flgasem := 'Y';
              insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
            end loop;
            if v_flgasem = 'N' then
              v_staemp := '9';
              for r_codapman in c_codapman loop
                insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
              end loop;
            end if;
          end loop;
        end if;
        exit;
      end loop;
    end if;
    --
*/
  elsif p_flgappr = '3' then
    v_codempap  := null;
    v_codcompap := p_codcompap;
    v_codposap  := p_codposap;
    v_staemp := '3';
    for r_codapman in c_codapman loop
      v_flgasem := 'Y';
      insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
    end loop;
    if v_flgasem = 'N' then
      v_staemp := '9';
      for r_codapman in c_codapman loop
        insert_ttemprpt2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
      end loop;
    end if;

  elsif p_flgappr = '4' then
    v_codempap  := p_codempap;
    v_codcompap := null;
    v_codposap  := null;
    insert_ttemprpt2(p_coduser,p_codapp,p_codempap,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);

  elsif p_flgappr = '5' then
    v_codempap  := p_stcodempid;
    v_codcompap := null;
    v_codposap  := null;
    insert_ttemprpt2(p_coduser,p_codapp,p_stcodempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno);
  end if;

  commit;
end;

procedure insert_ttemprpt2 (p_codempid in varchar2,p_codapp in varchar2,
                            p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,
                            p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,
                            p_item7 in varchar2,p_temp31 in number) is
  v_numseq  number;
  --call from find_approve_name--
  --item1=APPROVER,item2=CODEMPAP,item3=CODCOMPAP,item4=CODPOSAP,item5=EMPLOYEE for find all approver,
  --item6=EMPLOYEE for find all approver( or CODAPMAN from pre-seqno in AP),
  --item7=FLGAPPR,temp31=SEQNO
begin
  begin
    select nvl(max(numseq),0) + 1 into v_numseq
      from ttemprpt2
     where codempid = p_codempid
       and codapp   = p_codapp;
  exception when no_data_found then v_numseq := 1;
  end;
  --
  insert into ttemprpt2(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,temp31)
  values(p_codempid,p_codapp,v_numseq,p_item1,p_item2,p_item3,p_item4,p_item5,p_item6,p_item7,p_temp31);
  commit;
end; --insert_ttemprpt2

end;

/
