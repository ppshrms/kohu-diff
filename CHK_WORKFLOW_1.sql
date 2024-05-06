--------------------------------------------------------
--  DDL for Package Body CHK_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CHK_WORKFLOW" is

	function find_route(p_codapp   in varchar2 ,
	                    p_codempid in varchar2,
	                    p_others   in varchar2 default null) return varchar2 is-- user22 : 17/10/2017 : STA4-1701 || + p_others
/*==== p_others for ====
  - typleave
  - codtparg
*/
    v_stmt      varchar2(2000) ;
    v_desc      varchar2(2000) ;
    v_flgfound	boolean;
    v_route     varchar2(20) ;
    v_codcomp   varchar2(40);
    v_codpos    varchar2(4);
    v_numlvl		number;
    v_codempmt  varchar2(4);
    v_typemp    varchar2(4);
    v_flgdata   varchar2(1) := 'N';

    cursor c_temproute is
      select routeno
        from temproute
       where codapp      = p_codapp
         and p_codempid  like codempid
         and v_codcomp   like codcomp||'%'-- user22 : 13/01/2016 : STA3590197 || and v_codcomp   like codcomp
         and v_codpos    like codpos
    order by codempid desc,codcomp desc;

    cursor c_twkflph is
      select routeno,syncond,strseq
        from twkflph
       where codapp = p_codapp
    order by seqno ;

	begin
    begin
      select codcomp,codpos,numlvl,codempmt,typemp -- user46 : 02/08/2016 : afafsdfadfsd || select codcomp,codpos
        into v_codcomp,v_codpos,v_numlvl,v_codempmt,v_typemp-- user46 : 02/08/2016 : afafsdfadfsd || into v_codcomp,v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;

    for i in c_temproute loop
      v_flgdata := 'Y';
      v_route   := i.routeno;
      exit;
    end loop;
    if v_flgdata = 'N' then
      for i in c_twkflph loop
        if i.syncond is null then
          v_strseq := i.strseq ;
          return i.routeno ;
        else
					v_desc := i.syncond;
					v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
					v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
					v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
					v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
					v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
					v_desc := replace(v_desc,'TEMPLOY1.CODEMPID',''''||p_codempid||'''');
					v_desc := replace(v_desc,'TLEAVETY.TYPLEAVE',''''||p_others||'''');
					v_desc := replace(v_desc,'TCOURSE.CODTPARG',''''||p_others||'''');
					v_stmt := 'select count(*) from dual where '||v_desc;

					v_flgfound := execute_stmt(v_stmt);
					if v_flgfound then
						v_strseq := i.strseq ;
						v_route  := i.routeno ;
						exit;
					end if;
        end if;
      end loop ;
    end if;
    return v_route ;
	end;

	function find_strseq(p_codapp in varchar2 ,p_codempid in varchar2) return number is
	       v_stmt   varchar2(2000) ;
	       v_strseq number ;
	       v_codcomp   temploy1.codcomp%type;
	       v_codpos     temploy1.codpos%type;
	       v_flgdata   varchar2(1) := 'N';

	     cursor c_temproute is
	        select routeno
	          from temproute
	         where codapp      = p_codapp
	           and p_codempid  like codempid
	           and v_codcomp   like codcomp||'%'-- user22 : 13/01/2016 : STA3590197 || and v_codcomp   like codcomp
	           and v_codpos    like codpos
	        order by codempid desc,codcomp desc;

	       cursor c1 is
	       select routeno,syncond,strseq
	       from   twkflph
	       where  codapp = p_codapp
	       order by seqno ;
	  begin
	    begin
	        select codcomp,codpos into v_codcomp,v_codpos
	          from temploy1
	         where codempid = p_codempid;
	    exception when no_data_found then
	         null;
	    end;

	    for i in c_temproute loop
	        v_flgdata := 'Y';
	        exit;
	    end loop;
	    if  v_flgdata = 'N' then
        FOR i IN c1 LOOP
          IF i.syncond IS NULL THEN
              RETURN i.strseq ;
          ELSE
              v_stmt := 'select count(codempid) from temploy1 where ( '||i.syncond||' ) and codempid ='''||p_codempid||'''' ;
              IF  execute_qty(v_stmt) > 0 THEN
                  v_strseq := i.strseq ;
                  EXIT;
              END IF;
          END IF;
        END LOOP ;
	    end if;

	    return v_strseq ;
	end;
--
  procedure get_message(
  p_codapp      in  varchar2 ,p_codempid in varchar2,p_lang in varchar2,
  o_msg_to      out clob  ,o_msg_cc   out clob ,
  p_template_to out clob  ,p_template_cc out clob ,p_func_appr out varchar2) is
--    v_statment clob ;
    v_msg_to   twkflpf.codfrmto%type ;
    v_msg_cc   twkflpf.codfrmcc%type ;
    v_syncond  clob ;
    v_qty      number;
    v_codcomp  varchar2(40) ;
    v_codpos   varchar2(4) ;
    v_numlvl   number;
    v_codempmt varchar2(4) ;
    v_typemp   varchar2(4) ;

cursor c1 is
     select *
     from  twkflpf
     where codapp =p_codapp ;
begin
    begin
        select codcomp,codpos,numlvl,codempmt,typemp
        into   v_codcomp,v_codpos,v_numlvl,v_codempmt,v_typemp
        from   temploy1
        where  codempid = p_codempid ;
    exception when others then
        null;
    end;
    for i in c1 loop
            v_msg_to    := i.codfrmto ;
            v_msg_cc    := i.codfrmcc ;
            p_func_appr := i.codappap ;
    end loop ;

    if v_msg_to is not null then
        begin
          select decode(p_lang,'101',messagee,
                               '102',messaget,
                               '103',message3,
                               '104',message4,
                               '105',message5,
                               '101',messagee) msg
          into  o_msg_to
          from  tfrmmail
          where codform = v_msg_to ;
        exception when others then
          o_msg_to := null ;
        end ;

     end if;
     if v_msg_cc is not null then
        begin
          select decode(p_lang,'101',messagee,
                               '102',messaget,
                               '103',message3,
                               '104',message4,
                               '105',message5,
                               '101',messagee) msg
          into  o_msg_cc
          from  tfrmmail
        where codform = v_msg_cc ;
        exception when others then
          o_msg_cc := null ;
        end ;
     end if;
     begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
        into  p_template_to
        from  tfrmmail
        where codform = 'TEMPLATETO' ;
     exception when others then
        p_template_to := null ;
     end ;
     begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
        into  p_template_cc
        from  tfrmmail
        where codform = 'TEMPLATECC' ;
     exception when others then
        p_template_cc := null ;
     end ;
  end; -- procedure
--
  function chk_nextstep(
                      p_codapp    in varchar2,p_routeno  in varchar2,
                      p_approveno in number  ,p_codempap in varchar2,
                      p_codcompap in out varchar2 ,p_codposap  in out varchar2) return varchar2 is

  v_return  varchar2(20) := null  ;
  v_found   varchar2(1)  := null  ;
  v_numseq  number  := nvl(p_approveno,0) + 1  ;
  v_twkflowd  twkflowd%rowtype ;
  v_maxseq  number := 0;
  cursor c1 is
     select codempid
     from  temploy1
     where codcomp = p_codcompap
     and   codpos  = p_codposap
     and   staemp in ('1','3')
     union
     select  codempid
     from   tsecpos
     where codcomp = p_codcompap
     and   codpos = p_codposap
     and   dteeffec <= sysdate
     and   (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) ;

  begin
    begin
      select max(numseq)
      into   v_maxseq
      from   twkflowd
      where  routeno = p_routeno;
    end;
    if v_numseq >= nvl(v_maxseq,0) then
        return null;
    end if;

    begin
      select *
      into   v_twkflowd
      from   twkflowd
      where  routeno = p_routeno
      and    numseq = v_numseq ;
    exception when no_data_found then
      v_twkflowd := null  ;
    end ;

    if v_twkflowd.typeapp in (1,2,3) then
        for i in c1 loop
             begin
                select 'Y'
                into   v_found
                from   tassignm
                where  codempid = i.codempid
                --and codapp = p_codapp
                and flgassign = 'N'
                and codcomp = p_codcompap
                and codpos  = p_codposap
                and dtestrt <= sysdate
                and (dteend >= trunc(sysdate) or dteend is null )
                and rownum = 1 ;
            exception when no_data_found then
                v_found := 'N' ;
            end ;
            if v_found = 'Y' then
               v_return := i.codempid;
               exit;
            end if;
        end loop;
    elsif v_twkflowd.typeapp = 4 then -- By Employee
        begin
            select 'Y'
            into   v_found
            from   tassignm
            where  codempid = v_twkflowd.codempa
            --and codapp = p_codapp
            and flgassign = 'N'
            and dtestrt  <= sysdate
            and (dteend  >= trunc(sysdate) or dteend is null )
            and rownum = 1 ;
        exception when no_data_found then
            v_found := 'N' ;
        end ;
        if v_found = 'Y' then
           v_return := v_twkflowd.codempa ;
        end if;
    end if;
    return v_return ;
  end;
--
  function send_mail_to_approve (
    p_codapp    in varchar2 ,p_routeno  in varchar2,
    p_approveno in number   ,p_codempap in varchar2,
    p_codcompap in varchar2 ,p_codposap in varchar2,
    p_msg_to    in clob     ,p_msg_cc   in clob,p_lang in number) return varchar2 is

    v_msg      clob := p_msg_to ;
    v_error    varchar2(10) ;
    v_codempid varchar2(10) ;
    msg_error  varchar2(10) := 'aaaa' ;
    v_coduser  varchar2(10) ;
    v_email    varchar2(100) ;
   cursor c1 is
    select codempid
      from temploy1
     where codempid = nvl(p_codempap,codempid)
       and codcomp  = nvl(p_codcompap,codcomp)
       and codpos   = nvl(p_codposap,codpos)
       and staemp in ('1','3')
   union
    select codempid
      from tsecpos
     where codempid  = nvl(p_codempap,codempid)
       and codcomp   = nvl(p_codcompap,codcomp)
       and codpos    = nvl(p_codposap,codpos)
       and dteeffec <= sysdate
       and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
       and p_codempap is null;--07/11/2551

  begin

        if  p_codempap  is null and
            p_codcompap is null and
            p_codposap  is null  then
            return '2405' ;
        end if;
        for i in c1 loop
            v_codempid := i.codempid ;
            begin
            select coduser into v_coduser
            from tusrprof
            where codempid = v_codempid
            and   rownum = 1 ;
            exception when no_data_found then
              v_coduser := null;
            end ;
            begin
               select email
               into   v_email
               from  temploy1
               where codempid =  v_codempid ;
            exception when no_data_found then
              v_email := null ;
            end ;

            if v_coduser is not null and v_email is not null then
                v_msg      := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg      := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg      := replace(v_msg ,'[P_LANG]',p_lang);
                v_msg      := replace(v_msg ,'[P_CC]','-');
                v_msg      := replace(v_msg ,'[PARAM1]', get_temploy_name(v_codempid,p_lang));
                v_msg      := replace(v_msg ,'[P_EMAIL]',get_temploy_name(v_codempid,p_lang)||'{'||v_email||'}');
                v_error    := send_mail(v_email,v_msg);
            end if;
        end loop;
        if v_error = '7521' then
            return '2046';
        else
            return '7522';
        end if;
  end;
--
function get_approve_name(p_codempap in varchar2, p_codcompap in varchar2, p_codposap in varchar2,p_lang in varchar2) return varchar2 is
cursor c1 is
  select codempid from (
        select codempid
        from temploy1
        where codcomp   = p_codcompap
        and  codpos = p_codposap
        and  staemp in  ('1','3')
        union
        select codempid
        from tsecpos
        where codcomp   = p_codcompap
        and  codpos = p_codposap
        and dteeffec <= sysdate
        and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
        )
     order by codempid;
begin
 if p_codempap is not null then
    return get_temploy_name(p_codempap,p_lang);
 else
    for i in c1 loop
       return get_temploy_name(i.codempid,p_lang);
       exit ;
    end loop ;
      return ' ';
 end if;
end;

function find_start_seq(p_codapp in varchar2 ,p_codempid in varchar2) return number is
       v_stmt      varchar2(2000) ;
       v_route     varchar2(20) ;
       v_codcomp   varchar2(40);
       v_codpos    varchar2(4);
       v_flgdata   varchar2(1) := 'N';

     cursor c_temproute is
        select routeno
          from temproute
         where codapp      = p_codapp
           and p_codempid  like codempid
           and v_codcomp   like codcomp||'%'-- user22 : 13/01/2016 : STA3590197 || and v_codcomp   like codcomp
           and v_codpos    like codpos
        order by codempid desc,codcomp desc;

       cursor c1 is
       select routeno,syncond--,strseq
       from   twkflph
       where  codapp = p_codapp
       order by seqno ;
  begin

  begin
        select codcomp,codpos into v_codcomp,v_codpos
          from temploy1
         where codempid = p_codempid;
    exception when no_data_found then
         null;
    end;

    for i in c_temproute loop
        v_flgdata := 'Y';
        exit;
    end loop;
    if  v_flgdata = 'N' then
        for i in c1 loop
            if i.syncond is null then
                --v_strseq := i.strseq ;
                return i.routeno ;
            else
                v_stmt := 'select count(codempid) from temploy1 where ( '||i.syncond||' ) and codempid ='''||p_codempid||'''' ;
                if  execute_qty(v_stmt) > 0 then
                    --v_strseq := i.strseq ;
                    v_route := i.routeno ;
                    exit;
                end if;
            end if;
        end loop ;
    end if;
    return v_strseq ;
end;
--
  procedure find_next_approve(p_codapp    in varchar2 ,
                            p_routeno   in out varchar2,
                            p_codempid  in varchar2,
                            p_dtereq    in varchar2,
                            p_numseq    in number,
                            p_approveno in out number,
                            p_codappr   in varchar2,
                            p_others    in varchar2 default null) is -- user22 : 17/10/2017 : STA4-1701 || + p_others

    v_stmt          varchar2(2000) ;
    v_route         varchar2(200) ;
    v_numseq        number ;
    v_seqno         number := 0;
    v_codappr       varchar2(20);
    v_codcomp       varchar2(40) ;
    v_codpos        varchar2(4) ;
    v_codempid      varchar2(10);


    v_codcompy       varchar2(4);
    v_codlinef       varchar2(4);
    v_dteeffec       date;
    v_pageno         number;
    v_rowno          number;
    v_columnno       number;
    v_torgprt        varchar2(1) := 'N';
    v_setorg2        varchar2(1) := 'N';
    v_codapman       varchar2(10);
    v_codcompapr     varchar2(40);
    v_codposapr      varchar2(4);
    v_codcompemp     varchar2(40);
    v_codposemp      varchar2(4);
    v_exist          varchar2(1):= 'N';
    flg_nextseq      varchar2(1):= 'N';
    v_approveno      number := p_approveno ;
    v_max_approv     number ;
    v_found					 varchar2(1):= 'N';
    v_chkhead				 varchar2(1):= 'N';
    v_codempidh      varchar2(10);

    v_approveno_tmp number;
    v_routeno       varchar2(40);

    --<<user36 KOHU-SM2301 02/12/2023
    type a_char is table of varchar2(20 char) index by binary_integer; 
      a_codappr     a_char;

    v_cnt           number := 0;
    -->>user36 KOHU-SM2301 02/12/2023

    cursor c_twkflowd is
      select *
        from twkflowd
       where routeno = p_routeno
         and numseq  = v_numseq ;

    cursor c_temphead1 is
      select replace(codempidh,'%',null) as codempidh,
             replace(codcomph,'%',null) as codcomph,
             replace(codposh,'%',null) as codposh
        from temphead--1
       where codempid = v_codempid
    order by codempidh;

    cursor c_temphead2 is
      select replace(codempidh,'%',null) as codempidh,
             replace(codcomph,'%',null) as codcomph,
             replace(codposh,'%',null) as codposh
        from temphead--2
       where codcomp  = v_codcomp
         and codpos   = v_codpos
    order by codcomph,codposh;

--<< user22 : 06/06/2019 : SMTL620336 ||
    cursor c_temploy1 is
      select codempid
        from temploy1
       where codcomp  = v_codcomp
         and codpos   = v_codpos
         and staemp in ('1','3')
    order by codempid;
-->> user22 : 06/06/2019 : SMTL620336 ||

/*    cursor c_torgprt is
      select a.codcompy,a.codlinef,a.dteeffec,a.pageno,a.rowno,a.columnno,a.codempid,
             b.pagenoh,b.rownoh,b.columnnoh
        from torgprt2 a,torgprt b
       where a.codcompy  = b.codcompy
         and a.codlinef  = b.codlinef
         and a.dteeffec  = b.dteeffec
         and a.pageno    = b.pageno
         and a.rowno     = b.rowno
         and a.columnno  = b.columnno
         and a.codempid  = v_codempid
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
         and columnno  = v_columnno;

    cursor c_torgprt2_notset is
      select codcompp,codpospr
        from torgprt
       where codcompy  = v_codcompy
         and codlinef  = v_codlinef
         and dteeffec  = v_dteeffec
         and pageno    = v_pageno
         and rowno     = v_rowno
         and columnno  = v_columnno
         and flgappr   = 'A';

    cursor c_torgprt2_no is
      select codcompy,codlinef,dteeffec,pageno,rowno,columnno,pagenoh,rownoh,columnnoh
        from torgprt
       where codcompp  = v_codcompemp
         and codpospr  = v_codposemp
         and flgappr   = 'A';
*/
    cursor c_tempaprq is
      select *
        from tempaprq
       where codapp   = p_codapp
         and codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq   = p_numseq
         and approvno = p_approveno;

    cursor c_tempaprq_next is
      select *
        from tempaprq
       where codapp   = p_codapp
         and codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq   = p_numseq
         and approvno = v_numseq;       
begin
  --<<user36 KOHU-SM2301 02/12/2023
  if p_codapp in ('HRES62E','HRES6ME','HRES6AE','HRES6DE') then
    begin
      select count(*) into v_cnt 
      from  tempaprq 
      where codapp   = p_codapp
      and   codempid = p_codempid
      and   dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
      and   numseq   = p_numseq;
    end;
    if v_cnt = 0 then
      /*----delete tempaprq where codapp = p_codapp
                      and codempid = p_codempid
                      and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
                      and numseq   = p_numseq;*/
      --
      begin
        select codappr1,codappr2,codappr3,codappr4
          into a_codappr(1),a_codappr(2),a_codappr(3),a_codappr(4)
          from tempflow
         where codapp   = p_codapp
           and codempid = p_codempid;
      exception when no_data_found then
        return;
      end;
      for i in 1..4 loop
        if a_codappr(i) is not null then
          insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                               codempap,codcompap,codposap,dteupd,coduser,routeno)
                        values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,i,1,
                               a_codappr(i),null,null,trunc(sysdate),p_codappr,p_routeno);
        end if;
      end loop;
    end if;
    return;
  end if;
  -->>user36 KOHU-SM2301 02/12/2023
  if p_routeno is null then
    p_routeno   := find_route(p_codapp,p_codappr,p_others);
    if p_approveno = 0 and  nvl(v_strseq,0) > 1  then
      p_approveno :=  v_strseq - 1;
      flg_nextseq := 'Y';
    end if;
  end if;
  begin
    select approvno into v_max_approv
      from twkflowh
     where routeno = p_routeno;
  exception when no_data_found then v_max_approv := 0;
  end;
  if p_approveno = v_max_approv then
    return;
  end if;

  v_numseq    := nvl(p_approveno,0) + 1 ;

  delete tempaprq where codapp   = p_codapp
                    and codempid = p_codempid
                    and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
                    and numseq   = p_numseq
                    and approvno = v_numseq;
  v_codempid := p_codempid;
  for i in c_twkflowd loop
		v_found := 'N'; -- user22 : 17/10/2017 : STA4-1701 ||
    if i.typeapp = 1 then    -- Head
      v_chkhead := 'N';
      if p_codapp in ('HRES62E','HRES6ME','HRES6AE','HRES6DE','HRES6KE','HRMS62E') then
        begin
          select codempidh
          into  v_codempidh
          from  twkchhr
          where codempid = p_codempid
          and   to_date(p_dtereq,'dd/mm/yyyy') between dtestrt and dteend
          and   codcompo <> nvl(codcomp,'!@#$')
          and   flghead ='Y';
          v_chkhead := 'Y';
        exception when no_data_found then
          null;
        end;
      end if;
      if v_chkhead = 'Y' then --Head from twkchhr
        v_seqno := nvl(v_seqno,0) + 1;
        insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                             codempap,codcompap,codposap,dteupd,coduser,routeno)
                      values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                             v_codempidh,null,null,trunc(sysdate),p_codappr,p_routeno);
        v_found := 'Y';

      else --Head from Normal setup
        if v_numseq = 1 or flg_nextseq = 'Y' then
          if flg_nextseq = 'Y' then
            if v_flgskip = 'N' then
                v_flgskip   := 'Y';
                for j in 1..v_numseq loop
                    v_approveno_tmp := j-1;
                    find_next_approve(p_codapp ,p_routeno,p_codempid,p_dtereq,p_numseq,v_approveno_tmp,p_codappr,p_others);
                end loop;
                v_found := 'Y';
            end if;
          else
              v_exist := 'N';
              for j in c_temphead1 loop
                v_exist := 'Y' ;
                v_seqno := nvl(v_seqno,0) + 1;
                insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                     codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                              values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                     j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
                v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
              end loop;
              if v_exist = 'N' then
                begin
                  select codcomp,codpos
                    into v_codcomp,v_codpos
                    from temploy1
                   where codempid = v_codempid ;
                exception when no_data_found then null;
                end;
                for j in c_temphead2 loop
                  v_seqno := nvl(v_seqno,0) + 1;
                  insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                       codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                                values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                       j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
                  v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
                end loop;
              end if;--v_exist
          end if;
        else--v_numseq > 1
        --<< user55 : 31/07/2019

          --<< user22 : 17/06/2019 : SMTL620341 ||
          for k in c_tempaprq loop
            begin
              select codcomp,codpos
                into v_codcomp,v_codpos
                from temploy1
               where codempid = p_codappr;
            exception when no_data_found then null;
            end;
            if (v_codcomp = nvl(k.codcompap,'!@#$%') and v_codpos = nvl(k.codposap,'!@#$%')) or p_codappr = nvl(k.codempap,'!@#$%') then
              v_exist := 'N';
              v_codempid := p_codappr;
              for j in c_temphead1 loop
                v_exist := 'Y';
                v_seqno := nvl(v_seqno,0) + 1;
                insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                     codempap,codcompap,codposap,dteupd,coduser,routeno)
                              values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                     j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                v_found := 'Y';
              end loop;
              if v_exist = 'N' then
                for j in c_temphead2 loop
                  v_exist := 'Y';
                  v_seqno := nvl(v_seqno,0) + 1;
                  insert into tempaprq(codapp,codempid,dtereq, numseq,approvno,seqno,
                                       codempap,codcompap,codposap,dteupd,coduser,routeno)
                                values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                       j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                  v_found := 'Y';
                end loop;--c_temphead2
              end if;-- v_exist = 'N'
            else -- (v_codcomp = nvl(k.codcompap,'!@#$%') and v_codpos = nvl(k.codposap,'!@#$%')) or p_codappr = nvl(k.codempap,'!@#$%')
              v_codempid := k.codempap;
              if k.codempap is not null then
                begin
                  select codcomp,codpos
                    into v_codcomp,v_codpos
                    from temploy1
                   where codempid = k.codempap;
                exception when no_data_found then null;
                end;
                for j in c_temphead1 loop
                  v_exist := 'Y';
                  v_seqno := nvl(v_seqno,0) + 1;
                  insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                       codempap,codcompap,codposap,dteupd,coduser,routeno)
                                values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                       j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                  v_found := 'Y';
                end loop;
                if v_exist = 'N' then
                  for j in c_temphead2 loop
                    v_exist := 'Y';
                    v_seqno := nvl(v_seqno,0) + 1;
                    insert into tempaprq(codapp,codempid,dtereq, numseq,approvno,seqno,
                                         codempap,codcompap,codposap,dteupd,coduser,routeno)
                                  values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                         j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                    v_found := 'Y';
                  end loop;--c_temphead2
                end if;-- v_exist = 'N'
              else -- k.codempap is not null
                v_codcomp := k.codcompap;
                v_codpos  := k.codposap;
                for r_emp in c_temploy1 loop
                  v_codempid := r_emp.codempid;
                  for j in c_temphead1 loop
                    v_exist := 'Y';
                    v_seqno := nvl(v_seqno,0) + 1;
                    insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                         codempap,codcompap,codposap,dteupd,coduser,routeno)
                                  values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                         j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                    v_found := 'Y';
                  end loop;
                  --
                  if v_exist = 'N' then
                    begin
                      select codcomp,codpos
                        into v_codcomp,v_codpos
                        from temploy1
                       where codempid = v_codempid;
                    exception when no_data_found then null;
                    end;
                    for j in c_temphead2 loop
                      v_exist := 'Y';
                      v_seqno := nvl(v_seqno,0) + 1;
                      insert into tempaprq(codapp,codempid,dtereq, numseq,approvno,seqno,
                                           codempap,codcompap,codposap,dteupd,coduser,routeno)
                                    values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                           j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                      v_found := 'Y';
                    end loop;--c_temphead2
                  end if;
                end loop;--c_temploy1
                --
                if v_exist = 'N' then
                  v_codcomp := k.codcompap;
                  v_codpos  := k.codposap;
                  for j in c_temphead2 loop
                    v_exist := 'Y';
                    v_seqno := nvl(v_seqno,0) + 1;
                    insert into tempaprq(codapp,codempid,dtereq, numseq,approvno,seqno,
                                         codempap,codcompap,codposap,dteupd,coduser,routeno)
                                  values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                         j.codempidh,j.codcomph,j.codposh,trunc(sysdate),p_codappr,p_routeno);
                    v_found := 'Y';
                  end loop;--c_temphead2
                end if;-- v_exist = 'N'
              end if; -- k.codempap is not null
            end if;-- (v_codcomp = nvl(k.codcompap,'!@#$%') and v_codpos = nvl(k.codposap,'!@#$%')) or p_codappr = nvl(k.codempap,'!@#$%')
          end loop; --c_tempaprq
-->> user22 : 17/06/2019 : SMTL620341 ||
        end if;
-->> user22 : 06/06/2019 : SMTL620336 ||
      end if;--v_numseq = 1 or flg_nextseq = 'Y'
    elsif i.typeapp = 2 then -- Head Organize
      begin
        select codcomp,codpos
          into v_codcompemp,v_codposemp
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
/*      v_torgprt     := 'N';
      for r_torgprt in c_torgprt loop
        v_torgprt   := 'Y';
        v_codcompy  := r_torgprt.codcompy;
        v_codlinef  := r_torgprt.codlinef;
        v_dteeffec  := r_torgprt.dteeffec;
        v_pageno    := r_torgprt.pagenoh;
        v_rowno     := r_torgprt.rownoh;
        v_columnno  := r_torgprt.columnnoh;
        v_setorg2   := 'N';
        for r_torgprt2_set in c_torgprt2_set loop
          v_setorg2  := 'Y';
          v_seqno := nvl(v_seqno,0) + 1;
          insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                               codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                        values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                               r_torgprt2_set.codempid,null,null,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
        	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
        end loop;
        if v_setorg2 = 'N' then
          for r_torgprt2_notset in c_torgprt2_notset loop
            v_seqno := nvl(v_seqno,0) + 1;
            insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                 codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                          values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                 null,r_torgprt2_notset.codcompp,r_torgprt2_notset.codpospr,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
          	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
          end loop;--c_torgprt2_notset
        end if;--v_setorg2
      end loop;--c_torgprt
      if v_torgprt = 'N' then
        for r_torgprt2_no in c_torgprt2_no loop
          v_codcompy  := r_torgprt2_no.codcompy;
          v_codlinef  := r_torgprt2_no.codlinef;
          v_dteeffec  := r_torgprt2_no.dteeffec;
          v_pageno    := r_torgprt2_no.pagenoh;
          v_rowno     := r_torgprt2_no.rownoh;
          v_columnno  := r_torgprt2_no.columnnoh;
          v_setorg2   := 'N';
          for r_torgprt2_set in c_torgprt2_set loop
            v_setorg2  := 'Y';
            v_seqno := nvl(v_seqno,0) + 1;
            insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                 codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                          values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                 r_torgprt2_set.codempid,null,null,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
          	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
          end loop;--c_torgprt2_set
          if v_setorg2 = 'N' then
            for r_torgprt2_notset in c_torgprt2_notset loop
              v_seqno := nvl(v_seqno,0) + 1;
              insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                                   codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                            values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,v_seqno,
                                   null,r_torgprt2_notset.codcompp,r_torgprt2_notset.codpospr,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
            	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
            end loop;
            exit;
          end if;--v_setorg2
        end loop;--c_torgprt2_no
      end if;--v_torgprt = 'N'
*/
    elsif i.typeapp = 3 then -- Department,position
      insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                           codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                    values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,(nvl(v_seqno,0) + 1),
                           null,i.codcompa,i.codposa,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
    	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
    elsif i.typeapp = 4 then -- Employee
      insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                           codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                    values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,(nvl(v_seqno,0) + 1),
                           i.codempa,null,null,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
    	v_found := 'Y'; -- user22 : 17/10/2017 : STA4-1701 ||
    end if;--i.typeapp = 1
--<< user22 : 17/10/2017 : STA4-1701 ||
  	if v_found = 'N' then
      insert into tempaprq(codapp,codempid,dtereq,numseq,approvno,seqno,
                           codempap,codcompap,codposap,dteupd,coduser,routeno)-- user22 : 17/10/2017 : STA4-1701 || + routeno
                    values(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,v_numseq,1,
                           null,null,null,trunc(sysdate),p_codappr,p_routeno);-- user22 : 17/10/2017 : STA4-1701 || + routeno
  	end if;
-->> user22 : 17/10/2017 : STA4-1701 ||
  end loop;--c_twkflowd
end;
	--
 	function check_next_approve(p_codapp    in varchar2,
                             p_routeno   in varchar2,
                             p_codempid  in varchar2,
                             p_dtereq    in varchar2,
                             p_numseq    in number,
                             p_approveno in number,
                             p_codappr   in varchar2) return varchar2 is

    v_codappr       varchar2(20);
    v_codcomp       varchar2(40) ;
    v_codpos        varchar2(4) ;
    v_codempid      varchar2(10);
    v_max_approv    number ;
    v_approveno     number := p_approveno + 1;

    cursor c_tempaprq_next is
      select codempap ,codcompap,codposap
        from tempaprq
       where codapp   = p_codapp
         and codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq   = p_numseq
         and approvno = v_approveno;

begin
    --if  v_approveno = 1 and
    begin
        select approvno into v_max_approv
        from   twkflowh
        where  routeno = p_routeno ;
    exception when no_data_found then
        v_max_approv := 0 ;
    end ;
   -- if  p_approveno =  v_max_approv  then
    if  v_approveno >  v_max_approv  then
        return null ;
    end if;

    begin
        select codcomp,codpos into v_codcomp,v_codpos
        from   temploy1
        where  codempid = p_codappr ;
    exception when others then    null ;
    end ;
    for i in c_tempaprq_next loop
        if  i.codempap = p_codappr  or (i.codcompap = v_codcomp  and i.codposap = v_codpos ) then
             v_codappr := p_codappr;
             exit;
        end if;
    end loop;
    return v_codappr ;
end;

procedure check_approve(p_codapp in varchar2,p_codapprove in varchar2) is
begin
    delete tempappr where codapp = p_codapp and codappr = p_codapprove ;
    commit ;
    check_assign(p_codapp ,p_codapprove ,p_codapprove);
    commit;
end ;

procedure check_assign(p_codapp in varchar2,p_codapprove in varchar2,p_codempid in varchar2) is
v_found   varchar2(1) ;
v_flg     varchar2(1) ;
v_codcomp varchar2(40);
v_codpos  varchar2(4) ;

cursor c_codcomp is
        select codcomp,codpos
        from (
        select codcomp,codpos
        from  temploy1
        where codempid = p_codempid
        union
        select  codcomp,codpos
        from   tsecpos
        where  codempid =  p_codempid
        and    dteeffec <= sysdate
        and   (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) )
        where  (codcomp,codpos) not in (select codcomp,codpos
                                          from  tassignm
                                       --where codapp   = p_codapp
                                         where  codempid = p_codempid
                                           and   dtestrt  <= sysdate
                                           and (dteend  >= trunc(sysdate) or dteend is null )) ;

cursor c_assign  is
        select codempid,codcomp,codpos
        from  tassignm
        --WHERE codapp  = p_codapp
        where codempas  = p_codempid
        and dtestrt  <= sysdate
        and (dteend  >= trunc(sysdate) or dteend is null )
        and flgassign = 'E'
        union
        select codempid,codcomp,codpos
        from  tassignm
        --where codapp  = p_codapp
        where (codcomas ,codposas)in (select codcomp,codpos
                                     from temploy1
                                     where codempid = p_codempid)
        and  dtestrt  <= sysdate
        and (dteend  >= trunc(sysdate) or dteend is null )
        and flgassign = 'P' ;

begin
        for i in c_codcomp loop
           begin
            INSERT INTO tempappr (codapp ,codappr ,codempid ,codcomp ,codpos)
            VALUES (p_codapp ,p_codapprove,p_codempid,i.codcomp,i.codpos) ;
           exception when others then
              null ;
           end ;
        end loop ;
        for i in c_assign loop
           begin
            INSERT INTO tempappr (codapp ,codappr ,codempid ,codcomp ,codpos)
            VALUES (p_codapp ,p_codapprove,i.codempid,i.codcomp,i.codpos) ;
           exception when others then
              null ;
           end ;
        end loop ;
        /*
        FOR i IN c_assign LOOP
             check_assign(p_codapp ,p_codapprove ,i.codempid );
        END LOOP ;
        */

end ;

procedure get_message_reply  (p_codapp      in varchar2 ,
                              p_codempid    in varchar2,
                              p_lang        in varchar2,
                              o_replyapp    out varchar2,
                              o_msg_to      out clob,
                              o_replyno     out varchar2,
                              o_msg_cc      out clob,
                              p_template_to out clob,
                              p_template_cc out clob,
                              p_func_appr   out varchar2,
                              p_codfrm_to   out varchar2,
                              p_codfrm_cc   out varchar2,
                              p_others in varchar2 default null)
   is

 v_statment varchar2(5000) ;
 v_msg_to   varchar2(5000) ;
 v_msg_cc   varchar2(5000) ;
 v_syncond  varchar2(5000) ;
 v_qty      number;
 v_codcomp  tcenter.codcomp%type ;
 v_codpos   tpostn.codpos%type ;
 v_numlvl   number;
 v_codempmt varchar2(4) ;
 v_typemp   varchar2(4) ;

cursor c1 is
     select *
     from  twkflph
     where codapp = p_codapp
     order by seqno ;
   -- Declare program variables as shown above
cursor c2 is
     select *
     from  twkflpf
     where codapp =p_codapp ;

begin
    begin
        select codcomp,codpos,numlvl,codempmt,typemp
        into   v_codcomp,v_codpos,v_numlvl,v_codempmt,v_typemp
        from    temploy1
        where   codempid = p_codempid ;
    exception when others then
        null;
    end;
    for i in c2 loop
        p_func_appr := i.codappap ;
    end loop;
    for i in c1 loop
        v_syncond := i.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||p_codempid||'''') ;
          v_statment := replace(v_statment,'TLEAVETY.TYPLEAVE',''''||p_others||'''');
					v_statment := replace(v_statment,'TCOURSE.CODTPARG',''''||p_others||'''');
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||p_codempid||'''' ;

          v_qty := execute_qty(v_statment) ;
          if v_qty > 0 then--replyapp,typreplya,replyno,typreplyn

            if i.replyapp <> 'N' then
               o_replyapp  := i.typreplya||i.typreplyar;
            else
               o_replyapp  := i.replyapp;
            end if;
            if i.replyno <> 'N' then
                o_replyno   := i.typreplyn||i.typreplynr;
            else
                o_replyno   := i.replyno;
            end if;
            v_msg_to    := i.codfrmap ;
            v_msg_cc    := i.codfrmno ;
            exit ;
          end if;
        else
            if i.replyapp <> 'N' then
                o_replyapp  := i.typreplya||i.typreplyar;
            else
                o_replyapp  := i.replyapp;
            end if;
            if i.replyno <> 'N' then
                o_replyno   := i.typreplyn||i.typreplynr;
            else
                o_replyno   := i.replyno;
            end if;
            v_msg_to    := i.codfrmap ;
            v_msg_cc    := i.codfrmno ;
           exit ;
        end if;
     end loop ;
     p_codfrm_to    := v_msg_to;
     p_codfrm_cc    := v_msg_cc;



     if v_msg_to is not null then
        begin
          select decode(p_lang,'101',messagee,
                               '102',messaget,
                               '103',message3,
                               '104',message4,
                               '105',message5,
                               messagee) msg
          into  o_msg_to
          from  tfrmmail
          where codform = v_msg_to ;
        exception when others then
          o_msg_to := null ;
        end ;
     end if;
     if v_msg_cc is not null then
        begin
          select decode(p_lang,'101',messagee,
                               '102',messaget,
                               '103',message3,
                               '104',message4,
                               '105',message5,
                               messagee) msg
          into  o_msg_cc
          from  tfrmmail
        where codform = v_msg_cc ;
        exception when others then
          o_msg_cc := null ;
        end ;
     end if;

     begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             messagee) msg
        into  p_template_to
        from  tfrmmail
        where codform = 'TEMPLATE' ;
     exception when others then
        p_template_to := null ;
     end ;
     p_template_cc := p_template_to;
end; -- Procedure

function  check_privilege(p_codapp     in varchar2,
                          p_codempid   in varchar2,
                          p_dtereq     in date,
                          p_numseq     in number,
                          p_approvno   in number,
                          p_codappr    in varchar2) return varchar2 is

    v_chkpri        varchar2(1) := 'N';
    v_codcomp       varchar2(40);
    v_codpos        varchar2(4);
    v_codappr       varchar2(20);
    cursor c_codcomp is
        select codcomp,codpos
          from (select codcomp,codpos
                  from temploy1
                 where codempid = p_codappr
               union
                select codcomp,codpos
                  from tsecpos
                 where codempid = p_codappr
                   and dteeffec <= sysdate
                   and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null));
--<< user36 : 10/02/2016 : STA3590219 ||
         /*where  (codcomp,codpos) not in (select codcomp,codpos
                                           from tassignm
                                          where codapp   = p_codapp
                                            and codempid = p_codappr
                                            and dtestrt  <= sysdate
                                            and (dteend  >= trunc(sysdate) or dteend is null ) ) ;*/
-->> user36 : 10/02/2016 : STA3590219 ||
    cursor c_assign  is
        select codempid,codcomp,codpos
          from tassignm
         --where codapp    = p_codapp
         where codempas  = p_codappr
           and dtestrt  <= sysdate
           and (dteend  >= trunc(sysdate) or dteend is null )
           and flgassign = 'E'
        union
        select codempid,codcomp,codpos
          from tassignm
         --where codapp    = p_codapp
         where (codcomas ,codposas) in (select codcomp,codpos
                                          from temploy1
                                         where codempid = p_codappr)
           and dtestrt  <= sysdate
           and (dteend  >= trunc(sysdate) or dteend is null )
           and flgassign = 'P' ;

    cursor c_tempaprq is
        select codempap,codcompap,codposap
          from tempaprq
         where ((codempap = nvl(v_codappr,'@#$')) or (codcompap = v_codcomp and codposap = v_codpos))
           and codapp    = p_codapp
           and codempid  = p_codempid
           and dtereq    = p_dtereq
           and numseq    = p_numseq
           and approvno  = p_approvno;

  begin
    v_chkpri := 'N';
 
    for i in c_codcomp loop
        v_codappr := p_codappr;
        v_codcomp := i.codcomp;
        v_codpos  := i.codpos;

        for j in c_tempaprq loop
           v_chkpri := 'Y';
           exit;
        end loop;
    end loop;

    if v_chkpri = 'N' then
        for i in c_assign loop
            v_codappr := i.codempid;
            v_codcomp := i.codcomp;
            v_codpos  := i.codpos;
            for j in c_tempaprq loop
               v_chkpri := 'Y';
               exit;
            end loop;
        end loop;
    end if;

    return v_chkpri;
  end;

	function get_next_approve  (p_codapp    in varchar2 ,
	                            p_codempid  in varchar2,
	                            p_dtereq    in varchar2,
	                            p_numseq    in number,
	                            p_approveno in number,
	                            p_lang      in varchar2) return varchar2 is
	  pragma autonomous_transaction; --<< user46 : 02/09/2016 : STA3590294 || J (User4)
		v_appr_name  	varchar2(1000) ;
		v_con        	varchar2(10) ;
		v_codcomp    	varchar2(40) ;
		v_codpos     	varchar2(4) ;
		v_count      	number ;
		v_qtyemp     	number := 5;
		v_codapp		  varchar2(30);
		v_numseq		  number := 0;
		v_codempid		varchar2(10);
		v_codempas		varchar2(10);
		v_codcomas		varchar2(40);
		v_codposas		varchar2(4);
    v_lasttypeapp varchar2(2);
    v_nexttypeapp varchar2(2);
    v_codappr     taplverq.codappr%type;
    v_head        varchar2(2);

	cursor c1 is
    select distinct 
          replace(codempap,'%',null) codempap,
          replace(codcompap,'%',null) codcompap,
          replace(codposap,'%',null) codposap,
          routeno
	   from tempaprq
	  where codapp   = p_codapp
	    and codempid = p_codempid
	    and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
	    and numseq   = p_numseq
	    and approvno = nvl(p_approveno,0) + 1;

	cursor c2 is
		select codempid,codcomp,codpos
	      from temploy1
	     where ((codcomp  = v_codcomp
	       and codpos    = v_codpos)
	        or (codempid in  (select codempid
	                           from tsecpos
	                          where codcomp = v_codcomp
	                            and codpos  = v_codpos
	                            and dteeffec <= sysdate
	                            and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) )) )
	       and staemp in ('1','3')
	  order by codempid ;

	cursor c3 is
		select item1 as codempid,item2 as codcomp,item3 as codpos
	      from ttemprpt2
	     where codempid = p_codapp
	       and codapp   = v_codapp
	  group by item1,item2,item3
	  order by item1;

	cursor c4 is
	  select codempas,codcomas,codposas
	    from tassignm
	   --where codapp    = p_codapp
	   where codempid  = v_codempid
	     and codcomp   = v_codcomp
	     and codpos    = v_codpos
	     and dtestrt  <= sysdate
	     and (dteend   >= trunc(sysdate) or dteend is null)
	     and flgassign in ('E','P');

	cursor c5 is
	  select codempid
	    from temploy1
	   where codempid <> v_codempid
	     and codempid  = nvl(v_codempas,codempid)
	     and codcomp   = nvl(v_codcomas,codcomp)
	     and codpos    = nvl(v_codposas,codpos)
	     and staemp in ('1','3')
       union
	  select codempid
	    from tsecpos
	   where codempid <> v_codempid
	     and codempid  = nvl(v_codempas,codempid)
	     and codcomp   = nvl(v_codcomas,codcomp)
	     and codpos    = nvl(v_codposas,codpos)
	     and dteeffec <= sysdate
	     and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) ;

	begin
--<< user22 : 08/02/2016 : STA3590210 ||
		v_codapp := to_char(sysdate,'ddmmyyyyhh24miss')|| ROUND(DBMS_RANDOM.VALUE(10,99));
		delete ttemprpt2
     where codempid = p_codapp
       and codapp = v_codapp;
-->> user22 : 08/02/2016 : STA3590210 ||
		--
		v_count := 0 ;
		for i in c1 loop
      --<<user36 SEA-HR2201 #682 13/02/2023
      begin
        select typeapp into v_lasttypeapp
        from   twkflowd
        where  routeno = i.routeno
        and    numseq  = nvl(p_approveno,0);
      exception when no_data_found then null;
      end;
      begin
        select typeapp into v_nexttypeapp
        from   twkflowd
        where  routeno = i.routeno
        and    numseq  = nvl(p_approveno,0) + 1;
      exception when no_data_found then null;
      end;
      if v_lasttypeapp = '1' and v_nexttypeapp = '1' then
        v_codappr := find_codappr(p_codapp,p_codempid,to_date(p_dtereq,'dd/mm/yyyy'),p_numseq,p_approveno);
        v_head := check_emphead(v_codappr,i.codempap,i.codcompap,i.codposap);
        if v_head = 'N' then
          goto next_data;
        end if;
      end if;
      -->>user36 SEA-HR2201 #682 13/02/2023
      if i.codempap is not null then
        --v_qtyemp := v_qtyemp + 1 ;
        v_appr_name := v_appr_name ||v_con||i.codempap||' '||get_temploy_name(i.codempap,p_lang);
        v_con := ' , ' ;
--<< user22 : 08/02/2016 : STA3590210 ||
        begin
          select codcomp,codpos
            into v_codcomp,v_codpos
            from temploy1
           where codempid = i.codempap;
        exception when no_data_found then
          v_codcomp := null;
          v_codpos  := null;
        end;
        v_numseq := v_numseq + 1;
        begin
          insert into ttemprpt2(codempid,codapp,numseq,item1,item2,item3)
               values (p_codapp,v_codapp,v_numseq,i.codempap,v_codcomp,v_codpos);
        exception when dup_val_on_index then
          update ttemprpt2
             set item1 = i.codempap,
                 item2 = v_codcomp,
                 item3 = v_codpos
           where codempid = p_codapp
             and codapp   = v_codapp
             and numseq   = v_numseq;
        end;
        v_count := v_count + 1 ;
        if v_count >= v_qtyemp then
          commit;--<< user46 : 02/09/2016 : STA3590294
          return substr(v_appr_name,1,600);
        end if;
-->> user22 : 08/02/2016 : STA3590210 ||
      else
        v_codcomp := i.codcompap;
        v_codpos  := i.codposap;
        for j in c2 loop
          v_appr_name := v_appr_name ||v_con||j.codempid||' '||get_temploy_name(j.codempid,p_lang);
          v_con := ' , ' ;
--<< user22 : 08/02/2016 : STA3590210 ||
          v_numseq := v_numseq + 1;
          insert into ttemprpt2(codempid,codapp,numseq,item1,item2,item3)
               values (p_codapp,v_codapp,v_numseq,j.codempid,i.codcompap,i.codposap);
-->> user22 : 08/02/2016 : STA3590210 ||
          v_count := v_count + 1;
          if v_count >= v_qtyemp then
            commit;--<< user46 : 02/09/2016 : STA3590294
            return substr(v_appr_name,1,600);
          end if;
        end loop;
      end if;
      --<<user36 SEA-HR2201 #682 13/02/2023
      <<next_data>>
      null;
      -->>user36 SEA-HR2201 #682 13/02/2023
    end loop;
--<< user22 : 08/02/2016 : STA3590210 ||
		commit;

		if v_count < v_qtyemp then
            for r3 in c3 loop
                v_codempid := r3.codempid;
				v_codcomp  := r3.codcomp;
				v_codpos   := r3.codpos;
                for r4 in c4 loop
--                    v_codempid := r3.codempid;
--                    v_codcomp  := r3.codcomp;
--                    v_codpos   := r3.codpos;
                    v_codempas  := r4.codempas;
                    v_codcomas  := r4.codcomas;
                    v_codposas  := r4.codposas;
                    for r5 in c5 loop
                        v_appr_name := v_appr_name ||v_con||r5.codempid||' '||get_temploy_name(r5.codempid,p_lang)||'('||get_label_name('ESS',p_lang,10)||')';
						v_con := ' , ' ;
						v_count := v_count + 1;
						if v_count >= v_qtyemp then
                            commit;--<< user46 : 02/09/2016 : STA3590294
							return substr(v_appr_name,1,600);
						end if;
					end loop;--c5
				end loop;--c4
			end loop;--c3
		end if;

		delete ttemprpt2 where codempid = p_codapp and codapp = v_codapp;
		commit;
-->> user22 : 08/02/2016 : STA3590210 ||
		if  v_appr_name is not null  then
		  return substr(v_appr_name,1,600);
		else
		  return 'N/A';
		end if;
	end;

  --<<user36 SEA-HR2201 #682 13/02/2023
  function find_codappr(p_codapp    in varchar2 ,
                        p_codempid  in varchar2,
                        p_dtereq    in date,
                        p_numseq    in number,
                        p_approveno in number) return varchar2 is

    v_codappr   taplverq.codappr%type;

  begin
    if p_codapp = 'HRES71E' then--hres72u
      begin
        select codappr into v_codappr
          from tapmedrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES74E' then--hres75u
      begin
        select codappr into v_codappr
          from tapobfrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES77E' then--hres78u
      begin
        select codappr into v_codappr
          from taploanrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES32E' then--hres33u
      null;--hres33u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
    elsif p_codapp = 'HRES34E' then--hres35u
      begin
        select codappr into v_codappr
          from tapmoverq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES36E' then--hres37u
      null;--hres33u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
    elsif p_codapp = 'HRES62E' then--hres63u
      begin
        select codappr into v_codappr 
        from  taplverq 
        where codempid = p_codempid
        and   dtereq   = p_dtereq
        and   seqno    = p_numseq
        and   approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES6ME' then--hres6me
      begin
        select codappr into v_codappr
          from taplvecc
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and seqno    = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES6AE' then--hres6bu
      null;--hres6bu use chk_workflow.check_next_step_hres33u(______________.dtework)
    elsif p_codapp = 'HRES6DE' then--hres6eu
      begin
        select codappr into v_codappr
          from tapwrkrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and seqno    = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES6IE' then--hres6ju
      v_codappr  := 'PHASE2';
      /*begin
        select codappr into v_codappr
          from taptrnrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and seqno    = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;*/
    elsif p_codapp = 'HRES6KE' then--hres6lu
      begin
        select codappr into v_codappr
          from taptotrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES81E' then--hres85u
      begin
        select codappr into v_codappr
          from taptrvrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES88E' then--hres89u
      begin
        select codappr into v_codappr
          from tapjobrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES86E' then--hres87e
      begin
        select codappr into v_codappr
          from tapresrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRESS2E' then--hress3u
      null;--hress3u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
    elsif p_codapp = 'HRESS4E' then--hress5u
      null;--hress5u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
    elsif p_codapp = 'HRES95E' then--hres96u
      begin
        select codappr into v_codappr
          from taprplerq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES6KE' then--hres3cu
      null;--This Function not use Route
    elsif p_codapp = 'HRES91E' then--hres92u
      begin
        select codappr into v_codappr
          from taptrcerq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    elsif p_codapp = 'HRES93E' then--hres94u
      begin
        select codappr into v_codappr
          from taptrcanrq
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = p_approveno;
      exception when no_data_found then
        v_codappr := null;
      end;
    end if;
    --
    return v_codappr;
  end;

  function check_emphead (p_codempid varchar2,p_codempidh in varchar2,p_codcomph in varchar2,p_codposh in varchar2) return varchar2 is
--Only for check from Head Setup again after gen at tempaprq
    v_codcomp    temphead.codcomph%type := '';
    v_codpos     temphead.codposh%type := '';
    v_chk_head1   varchar2(1) := 'N';

    cursor c_head1 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh
      from    temphead
      where   (codempid  = p_codempid  or codcomp||codpos = v_codcomp||v_codpos)
      and     (codempidh = p_codempidh or codcomph||codposh = p_codcomph||p_codposh)
      order by numseq;

  begin
    begin
      select codpos,codcomp into v_codpos,v_codcomp
      from   temploy1
      where  codempid = p_codempid;
    exception when no_data_found then null;
    end;
    for j in c_head1 loop
      v_chk_head1  := 'Y';
      exit;
    end loop;

    return(v_chk_head1);
  end;
  -->>user36 SEA-HR2201 #682 13/02/2023

--<< user22 : 04/07/2016 : STA3590287 || return v_codappr;
  function check_next_step(p_codapp    in varchar2,
                           p_routeno   in varchar2,
                           p_codempid  in varchar2,
                           p_dtereq    in varchar2,
                           p_numseq    in number,
                           p_approveno in number,
                           p_codappr   in varchar2) return varchar2 is

  v_codappr       varchar2(20);
  v_codcomp       varchar2(40);
  v_codcompap     varchar2(40);
  v_codpos        varchar2(4);
  v_codposap      varchar2(4);
  v_codempid      varchar2(10);
  v_max_approv    number ;
  v_approveno     number := p_approveno + 1;
  v_found         varchar2(1) := 'N';

  cursor c_tempaprq is
    select codempap ,codcompap,codposap
      from tempaprq
     where codapp   = p_codapp
       and codempid = p_codempid
       and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
       and numseq   = p_numseq
       and approvno = v_approveno;

  cursor c_emp is
		select codempid,codcomp,codpos
		  from(select codempid,codcomp,codpos
					   from temploy1
					  where codcomp  = v_codcompap
				      and codpos   = v_codposap
				      and staemp   in ('1','3')
			union
			     select codempid,codcomp,codpos
				     from tsecpos
				    where codcomp  = v_codcompap
				      and codpos   = v_codposap
				      and dteeffec <= sysdate
				      and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))
		order by codempid;
begin
  begin
    select approvno into v_max_approv
      from twkflowh
     where routeno = p_routeno ;
  exception when no_data_found then v_max_approv := 0 ;
  end;
  if v_approveno = v_max_approv then
		return null;
  end if;

  for i in c_tempaprq loop
	  begin
		  select codcomp,codpos into v_codcomp,v_codpos
		    from temploy1
		   where codempid = p_codappr;
	  exception when others then v_codcomp := null; v_codpos := null;
	  end;
		if i.codempap = p_codappr or (i.codcompap = v_codcomp and i.codposap = v_codpos) then
			if p_codapp = 'HRES71E' then--hres72u
				begin
					select codappr into v_codappr
					  from tapmedrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES74E' then--hres75u
				begin
					select codappr into v_codappr
					  from tapobfrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES77E' then--hres78u
				begin
					select codappr into v_codappr
					  from taploanrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES32E' then--hres33u
				null;--hres33u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
			elsif p_codapp = 'HRES34E' then--hres35u
				begin
					select codappr into v_codappr
					  from tapmoverq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES36E' then--hres37u
				null;--hres33u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
			elsif p_codapp = 'HRES62E' then--hres63u
				begin
					select codappr into v_codappr
					  from taplverq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and seqno     = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES6ME' then--hres6me
				begin
					select codappr into v_codappr
					  from taplvecc
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and seqno     = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES6AE' then--hres6bu
				null;--hres6bu use chk_workflow.check_next_step_hres33u(______________.dtework)
			elsif p_codapp = 'HRES6DE' then--hres6eu
				begin
					select codappr into v_codappr
					  from tapwrkrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and seqno     = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES6IE' then--hres6ju
				v_codappr  := 'PHASE2';
        /*begin
					select codappr into v_codappr
					  from taptrnrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;*/
			elsif p_codapp = 'HRES6KE' then--hres6lu
				begin
					select codappr into v_codappr
					  from taptotrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES81E' then--hres85u
				begin
					select codappr into v_codappr
					  from taptrvrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES88E' then--hres89u
				begin
					select codappr into v_codappr
					  from tapjobrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES86E' then--hres87e
				begin
					select codappr into v_codappr
					  from tapresrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRESS2E' then--hress3u
				null;--hress3u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
			elsif p_codapp = 'HRESS4E' then--hress5u
				null;--hress5u use chk_workflow.check_next_step_hres33u(tapempch.typreq)
			elsif p_codapp = 'HRES95E' then--hres96u
				begin
					select codappr into v_codappr
					  from taprplerq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES6KE' then--hres3cu
				null;--This Function not use Route
			elsif p_codapp = 'HRES91E' then--hres92u
				begin
					select codappr into v_codappr
					  from taptrcerq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES93E' then--hres94u
				begin
					select codappr into v_codappr
					  from taptrcanrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			end if;
		end if;--i.codempap = p_codappr or (i.codcompap = v_codcomp and  i.codposap = v_codpos)
  	--
		if i.codcompap is not null then
			v_codcompap := i.codcompap;
			v_codposap  := i.codposap;
			for k in c_emp loop
				begin
				  select 'Y'
					  into v_found
					  from tassignm
					 where codempid  = k.codempid
					   and codcomp   = k.codcomp
						 and codpos    = k.codpos
					   --and codapp    = p_codapp
					   and flgassign = 'N'
					   and dtestrt   <= sysdate
					   and (dteend   >= trunc(sysdate) or dteend is null)
					   and rownum    = 1;
					return k.codempid;
				exception when no_data_found then null;
				end;
			end loop;--c_emp
		elsif i.codempap is not null then
		  begin
			  select codcomp,codpos into v_codcomp,v_codpos
			    from temploy1
			   where codempid = i.codempap;
		  exception when others then v_codcomp := null; v_codpos := null;
		  end;
			begin
			  select 'Y'
				  into v_found
				  from tassignm
				 where codempid  = i.codempap
				   and codcomp   = v_codcomp
					 and codpos    = v_codpos
				   --and codapp    = p_codapp
				   and flgassign = 'N'
				   and dtestrt   <= sysdate
				   and (dteend   >= trunc(sysdate) or dteend is null)
				   and rownum    = 1 ;
				return i.codempap;
			exception when no_data_found then null;
			end;
		end if;
  end loop;--c_tempaprq
  return null;
end;
/*
function Check_Next_Step( p_codapp    in varchar2,
                          p_routeno   in varchar2,
                          p_codempid  in varchar2,
                          p_dtereq    in varchar2,
                          p_numseq    in number,
                          p_approveno in number,
                          p_codappr   in varchar2) return varchar2 is

  v_codappr       varchar2(20);
  v_codcomp       varchar2(40) ;
  v_codpos        varchar2(4) ;
  v_codempid      varchar2(10);
  v_max_approv    number ;
  v_approveno     number := p_approveno + 1;
  v_found         varchar2(1) := 'N';

  cursor c_tempaprq_next is
    select codempap ,codcompap,codposap
      from tempaprq
     where codapp   = p_codapp
       and codempid = p_codempid
       and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
       and numseq   = p_numseq
       and approvno = v_approveno;
begin
  begin
    select approvno into v_max_approv
      from twkflowh
     where routeno = p_routeno ;
  exception when no_data_found then v_max_approv := 0 ;
  end;
  if v_approveno = v_max_approv then
		return null;
  end if;

  begin
	  select codcomp,codpos into v_codcomp,v_codpos
	    from temploy1
	   where codempid = p_codappr;
  exception when others then null;
  end;

  for i in c_tempaprq_next loop
		if i.codempap = p_codappr or (i.codcompap = v_codcomp and  i.codposap = v_codpos ) then
			if i.codcompap is not null then
				begin
				  select 'Y'
				    into v_found
				    from tassignm
				   where codempid  = p_codappr
				     and codapp    = p_codapp
					   and flgassign = 'N'
					   and codcomp   = i.codcompap
					   and codpos    = i.codposap
					   and dtestrt   <= sysdate
					   and (dteend   >= trunc(sysdate) or dteend is null)
					   and rownum    = 1;
				exception when no_data_found then v_found := 'N';
				end ;
			elsif i.codempap is not null  then
				begin
				  select 'Y'
					  into v_found
					  from tassignm
					 where codempid  = p_codappr
					   and codapp    = p_codapp
					   and flgassign = 'N'
					   and codcomp   = v_codcomp
 					   and codpos    = v_codpos
					   and dtestrt   <= sysdate
					   and (dteend   >= trunc(sysdate) or dteend is null)
					   and rownum    = 1 ;
				exception when no_data_found then v_found := 'N' ;
				end ;
			end if;
			if v_found = 'Y' then
			  v_codappr := p_codappr;
			  exit;
			end if;
		end if;
  end loop;
  return v_codappr;
end;
*/
-->> user22 : 04/07/2016 : STA3590287 ||
  function check_next_step2(p_codapp    in varchar2,
                            p_routeno   in varchar2,
                            p_codempid  in varchar2,
                            p_dtereq    in varchar2,
                            p_numseq    in number,
                            p_typreq	  in varchar2,
                            p_dtework	  in varchar2,
                            p_approveno in number,
                            p_codappr   in varchar2) return varchar2 is

  v_codappr       varchar2(20);
  v_codcomp       varchar2(40);
  v_codcompap     varchar2(40);
  v_codpos        varchar2(4);
  v_codposap      varchar2(4);
  v_codempid      varchar2(10);
  v_max_approv    number ;
  v_approveno     number := p_approveno + 1;
  v_found         varchar2(1) := 'N';

  cursor c_tempaprq is
    select codempap ,codcompap,codposap
      from tempaprq
     where codapp   = p_codapp
       and codempid = p_codempid
       and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
       and numseq   = p_numseq
       and approvno = v_approveno;

  cursor c_emp is
		select codempid,codcomp,codpos
		  from(select codempid,codcomp,codpos
					   from temploy1
					  where codcomp  = v_codcompap
				      and codpos   = v_codposap
				      and staemp   in ('1','3')
			union
			     select codempid,codcomp,codpos
				     from tsecpos
				    where codcomp  = v_codcompap
				      and codpos   = v_codposap
				      and dteeffec <= sysdate
				      and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))
		order by codempid;
begin
  begin
    select approvno into v_max_approv
      from twkflowh
     where routeno = p_routeno ;
  exception when no_data_found then v_max_approv := 0 ;
  end;
  if v_approveno = v_max_approv then
		return null;
  end if;
  for i in c_tempaprq loop
	  begin
		  select codcomp,codpos into v_codcomp,v_codpos
		    from temploy1
		   where codempid = p_codappr;
	  exception when others then v_codcomp := null; v_codpos := null;
	  end;
		if i.codempap = p_codappr or (i.codcompap = v_codcomp and i.codposap = v_codpos) then
			if p_codapp = 'HRES32E' then--hres33u
				begin
					select codappr into v_codappr
					  from tapempch
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and typreq    = p_typreq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES36E' then--hres37u
				begin
					select codappr into v_codappr
					  from tapempch
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and typreq    = p_typreq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRES6AE' then--hres6bu
				begin
					select codappr into v_codappr
					  from taptimrq
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and dtework   = to_date(p_dtework,'dd/mm/yyyy')
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRESS2E' then--hress3u
				begin
					select codappr into v_codappr
					  from tapempch
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and typreq    = p_typreq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			elsif p_codapp = 'HRESS4E' then--hress5u
				begin
					select codappr into v_codappr
					  from tapempch
           where codempid  = p_codempid
             and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq    = p_numseq
             and typreq    = p_typreq
             and approvno  = (v_approveno - 1)
             and codappr   = p_codappr;
        	return p_codappr;
				exception when no_data_found then v_codappr := null;
				end;
			end if;
		end if;--i.codempap = p_codappr or (i.codcompap = v_codcomp and  i.codposap = v_codpos)
  	--
		if i.codcompap is not null then
			v_codcompap := i.codcompap;
			v_codposap  := i.codposap;
			for k in c_emp loop
				begin
				  select 'Y'
					  into v_found
					  from tassignm
					 where codempid  = k.codempid
					   and codcomp   = k.codcomp
						 and codpos    = k.codpos
					   --and codapp    = p_codapp
					   and flgassign = 'N'
					   and dtestrt   <= sysdate
					   and (dteend   >= trunc(sysdate) or dteend is null)
					   and rownum    = 1;
					return k.codempid;
				exception when no_data_found then null;
				end;
			end loop;--c_emp
		elsif i.codempap is not null then
		  begin
			  select codcomp,codpos into v_codcomp,v_codpos
			    from temploy1
			   where codempid = i.codempap;
		  exception when others then v_codcomp := null; v_codpos := null;
		  end;
			begin
			  select 'Y'
				  into v_found
				  from tassignm
				 where codempid  = i.codempap
				   and codcomp   = v_codcomp
					 and codpos    = v_codpos
				   --and codapp    = p_codapp
				   and flgassign = 'N'
				   and dtestrt   <= sysdate
				   and (dteend   >= trunc(sysdate) or dteend is null)
				   and rownum    = 1 ;
				return i.codempap;
			exception when no_data_found then null;
			end;
		end if;
  end loop;--c_tempaprq
  return null;
end;
--<< user4: 23/01/2018 : STA4610233 || data_not_found when tempaprq has more than 1 record, and first record not found in cursor c1
/*--<< user22 : 20/08/2016 : STA3590307 ||
	procedure find_approval(p_codapp    in varchar2,
		                      p_codempid  in varchar2,
		                      p_dtereq    in varchar2,
		                      p_numseq    in number,
		                      p_approveno in number,
		                      p_table			out varchar2,
		                      p_coderr		out varchar2) is

	v_approvno   number := nvl(p_approveno,0) + 1;
  v_found	     varchar2(1);
  t_codcomp    varchar2(40);
  t_codpos     varchar2(4);

  cursor c1 is
  	select codempid
      from temploy1
     where codcomp = t_codcomp
       and codpos  = t_codpos
       and staemp in ('1','3')
  union
    select codempid
      from tsecpos
     where codcomp = t_codcomp
       and codpos  = t_codpos
       and dteeffec <= sysdate
       and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null);

	begin
		begin
			select codcompap,codposap into t_codcomp,t_codpos
			  from tempaprq
			 where codapp    = p_codapp
			   and codempid  = p_codempid
			   and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
			   and numseq    = p_numseq
			   and approvno  = v_approvno
			   and rownum    = 1;
		exception when no_data_found then
			p_table  := 'twkflph';
			p_coderr := 'ES0053';
		end;
		if t_codcomp is not null then
			v_found := 'N';
			for r1 in c1 loop
				v_found := 'Y';
				exit;
			end loop;
			if v_found = 'N' then
				p_table  := 'twkflph';
				p_coderr := 'ES0053';
			end if;
		end if;
	end;
-->> user22 : 20/08/2016 : STA3590307 || */
  procedure find_approval(p_codapp    in varchar2,
		                      p_codempid  in varchar2,
		                      p_dtereq    in varchar2,
		                      p_numseq    in number,
		                      p_approveno in number,
		                      p_table			out varchar2,
		                      p_coderr		out varchar2) is

    v_approvno   number := nvl(p_approveno,0) + 1;
    v_found	     varchar2(1);
    t_codcomp    varchar2(40);
    t_codpos     varchar2(4);

    cursor c_tempaprq is
      select codcompap,codposap
        from tempaprq a
       where codapp    = p_codapp
         and codempid  = p_codempid
         and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq    = p_numseq
         and approvno  = v_approvno
         and ((codcompap is null and codempap is not null) or
             (codcompap is not null
               and exists ( select codempid
                              from temploy1
                             where codcomp = a.codcompap
                               and codpos  = a.codposap
                               and staemp in ('1','3')
                          union
                            select b.codempid
                              from tsecpos b,temploy1 c
                             where b.codempid = c.codempid(+)
                               and b.codcomp = a.codcompap
                               and b.codpos  = a.codposap
                               and b.dteeffec <= sysdate
                               and c.staemp in ('1','3')
                               and(nvl(b.dtecancel,b.dteend) >= trunc(sysdate) or nvl(b.dtecancel,b.dteend) is null ))));

	begin
    v_found := 'N';
    for r_tempaprq in c_tempaprq loop
      v_found := 'Y';
      exit;
    end loop;

    if v_found = 'N' then
      p_table  := 'twkflph';
      p_coderr := 'ES0053';
    end if;
	end;
-->> user4 : 23/01/2018

--<< user22 : 17/10/2017 : STA4-1701 ||
  procedure upd_tempaprq(p_routeno in varchar2) is
  	v_routeno			varchar2(100);
  	v_approvno		number;
	/*
  cursor c1 is
		  select codapp,codempid,dtereq,numseq,approvno,coduser as codappr,routeno
        from tempaprq
       where codempap  is null
         and codcompap is null
         and codposap  is null
         and routeno   = nvl(p_routeno,routeno);
  */
  	cursor c1 is
		  select codapp,codempid,dtereq,numseq,approvno,coduser as codappr,routeno
		    from (
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tleaverq b
		           where a.codapp    = 'HRES62E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.seqno
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
		          union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttotreq b
		           where a.codapp    = 'HRES6KE'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, trefreq b
		           where a.codapp    = 'HRES36E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttimereq b
		           where a.codapp    = 'HRES6AE'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tworkreq b
		           where a.codapp    = 'HRES6DE'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.seqno
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttrnreq b
		           where a.codapp    = 'HRES6IE'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tleavecc b
		           where a.codapp    = 'HRES6ME'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.seqno
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tmedreq b
		           where a.codapp    = 'HRES71E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tobfreq b
		           where a.codapp    = 'HRES74E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tloanreq b
		           where a.codapp    = 'HRES77E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttravreq b
		           where a.codapp    = 'HRES81E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tresreq b
		           where a.codapp    = 'HRES86E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tjobreq b
		           where a.codapp    = 'HRES88E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttrncerq b
		           where a.codapp    = 'HRES91E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, ttrncanrq b
		           where a.codapp    = 'HRES93E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.stappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, treplacerq b
		           where a.codapp    = 'HRES95E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tpfmemrq b
		           where a.codapp    = 'HRESS2E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.seqno
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tircreq b
		           where a.codapp    = 'HRESS4E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
              union
		          select a.codapp,a.codempid,a.dtereq,a.numseq,a.approvno,a.coduser,b.routeno
		            from tempaprq a, tempch b
		           where a.codapp    = 'HRES32E'
		             and a.codempid  = b.codempid
		             and a.dtereq    = b.dtereq
		             and a.numseq    = b.numseq
		             and b.routeno   = p_routeno
                 and b.staappr in ('P','A')
                 and a.approvno  = b.approvno + 1
                 );
  begin
		for r1 in c1 loop
			v_routeno  := r1.routeno;
			v_approvno := nvl(r1.approvno,0) - 1;
			chk_workflow.find_next_approve(r1.codapp,v_routeno,r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,v_approvno,r1.codappr);
		end loop;--for r1 in c1 loop
    commit;
	end;
-->> user22 : 17/10/2017 : STA4-1701 ||

--<< user4 : 23/05/2018 : STA4-1701 ||
  procedure send_mail_to_responsible is
    cursor c_tempaprq is
      select pr.codempid as emres, a.codapp, a.codempid as emreq, a.dtereq, a.numseq, emp1.email
			  from tempaprq a, twkflpr pr, temploy1 emp1
       where a.codapp     = pr.codapp
         and pr.codempid  = emp1.codempid
         and emp1.email   is not null
         and (
						--HRES32E	?????????????????????????????????.
  		   		 exists (select b.codempid
  		   		          from tempch b
					           where a.codapp    = 'HRES32E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))

						--HRES34E	??????????????????
  		   	or exists (select b.codempid
  		   		          from tmovereq b
					           where a.codapp    = 'HRES34E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES36E	????????????????????????
  		   	or exists (select b.codempid
  		   		          from trefreq b
					           where a.codapp    = 'HRES36E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))

						--HRES3BE	???????????????????????.
  		   	or exists (select b.codempid
  		   		          from tcompln b
					           where a.codapp    = 'HRES3BE'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtecompl
					             and a.numseq    = b.numcomp
					             and a.approvno  = 1
					             and b.stacompl  = 'N')
						--HRES62E	??????????
  		   	or exists (select b.codempid
  		   		          from tleaverq b
					           where a.codapp    = 'HRES62E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.seqno
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES77E	?????????????????????????
  		   	or exists (select b.codempid
  		   		          from tloanreq b
					           where a.codapp    = 'HRES77E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES6AE	?????????????????????????-???
  		   	or exists (select b.codempid
  		   		          from ttimereq b
					           where a.codapp    = 'HRES6AE'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES6DE	??????????????????????????
  		   	or exists (select b.codempid
  		   		          from tworkreq b
					           where a.codapp    = 'HRES6DE'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.seqno
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES6IE	?????????????????????
  		   	or exists (select b.codempid
  		   		          from ttrnreq b
					           where a.codapp    = 'HRES6IE'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES6KE	???????????????????????????
  		   	or exists (select b.codempid
  		   		          from ttotreq b
					           where a.codapp    = 'HRES6KE'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES6ME	???????????????????
  		   	or exists (select b.codempid
  		   		          from tleavecc b
					           where a.codapp    = 'HRES6ME'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.seqno
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES71E	????????????????????????????????
  		   	or exists (select b.codempid
  		   		          from tmedreq b
					           where a.codapp    = 'HRES71E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES74E	???????????????????????????
  		   	or exists (select b.codempid
  		   		          from tobfreq b
					           where a.codapp    = 'HRES74E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES81E	????????????????????????
  		   	or exists (select b.codempid
  		   		          from ttravreq b
					           where a.codapp    = 'HRES81E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES86E	???????????????????
  		   	or exists (select b.codempid
  		   		          from tresreq b
					           where a.codapp    = 'HRES86E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES88E	????????????????????????????
  		   	or exists (select b.codempid
  		   		          from tjobreq b
					           where a.codapp    = 'HRES88E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES91E	??????????????????????????????
  		   	or exists (select b.codempid
  		   		          from ttrncerq b
					           where a.codapp    = 'HRES91E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRES93E	????????????????????????????????
  		   	or exists (select b.codempid
  		   		          from ttrncanrq b
					           where a.codapp    = 'HRES93E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.stappr   in ('P','A'))
						--HRES95E	????????????????
  		   	or exists (select b.codempid
  		   		          from treplacerq b
					           where a.codapp    = 'HRES95E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRESS2E	????????????????????????????????????
  		   	or exists (select b.codempid
  		   		          from tpfmemrq b
					           where a.codapp    = 'HRESS2E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.seqno
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
						--HRESS4E	???????????????????
  		   	or exists (select b.codempid
  		   		          from tircreq b
					           where a.codapp    = 'HRESS4E'
					             and a.codempid  = b.codempid
					             and a.dtereq    = b.dtereq
					             and a.numseq    = b.numseq
					             and a.approvno  =(nvl(b.approvno,0) + 1)
					             and b.staappr   in ('P','A'))
  		       )
         and (not exists (
                select emp2.codempid
                  from temploy1 emp2
                 where emp2.codempid  = nvl(a.codempap,emp2.codempid)
                   and emp2.codcomp   = nvl(a.codcompap,emp2.codcomp)
                   and emp2.codpos    = nvl(a.codposap,emp2.codpos)
                   and emp2.staemp in ('1','3')
                union
                select sec.codempid
                  from tsecpos sec
                 where sec.codempid  = nvl(a.codempap,sec.codempid)
                   and sec.codcomp   = nvl(a.codcompap,sec.codcomp)
                   and sec.codpos    = nvl(a.codposap,sec.codpos)
                   and sec.dteeffec <= sysdate
                   and(nvl(sec.dtecancel,sec.dteend) >= trunc(sysdate) or nvl(sec.dtecancel,sec.dteend) is null)
              ) or ( a.codempap is null
                   and a.codcompap is null
                   and a.codposap is null
                   )
             )
      order by pr.codempid, a.codapp, a.codempid, a.dtereq, a.numseq;

    v_report          varchar2(4000) ;
    v_head            varchar2(4000) ;
    v_attach_file     varchar2(200) ;
    v_coduser         varchar2(100) := 'APPROVAL';
    v_codapp          varchar2(100) := 'REQUEST_THAT_NOT_FOUND';
    v_lang            varchar2(10)  := '102';
    v_error           varchar2(20) := 'HR2401';
    v_numseq          number  := 0;
    v_tmp_codempid    temploy1.codempid%type;
    v_tmp_email       temploy1.email%type;
    v_tmp_codapp      varchar2(100);
    v_insert_app      varchar2(100);

    v_msg_to          clob;
		v_template_cc     clob;
    v_message		      clob;
    v_send_msg        clob;
    v_subject         varchar2(2000);
  begin
    ----<<insert head column report----
    delete from ttempprm where codapp = v_codapp;
    begin
      insert into ttempprm(codempid,codapp,
                           label1,label2,label3,
                           label4,label5)
                   values (v_coduser,v_codapp,
                           get_label_name('HRMS62EC1',v_lang,20),get_label_name('HRMS62EC1',v_lang,30),get_label_name('HRMS62EC1',v_lang,40),
                           get_label_name('HRMS62EC1',v_lang,50),get_label_name('HRMS62EC1',v_lang,60));
    end;
    ----insert head column report>>----
    v_report        := 'item1,item2,item3,item4,item5';
    v_head          := 'label1,label2,label3,label4,label5';
    ----Clear data temp----
    delete from ttemprpt where codapp = v_codapp;
    -----------------------
    v_attach_file   := get_tsetup_value('PATHTEMP')||lower(v_codapp||'_'||v_coduser)||'.xls';
    ---<< set form mail
    begin
    	select descodt, messaget
    	  into v_subject, v_msg_to
    	  from tfrmmail
    	 where codform = 'HRES17ETO' ;
    exception when no_data_found then
      v_msg_to := null ;
    end ;

    begin
    	select messaget
    	  into v_template_cc
    	  from tfrmmail
    	 where codform = 'TEMPLATEFM' ;
    exception when no_data_found then
    	  v_template_cc := null ;
    end ;
    --->> set form mail

    v_message  := replace(v_template_cc,'[P_MESSAGE]', replace(replace(v_msg_to,chr(10),'<br>'),' ','&nbsp;'));
    v_message  := replace(v_message,'[P_OTHERMSG]', null);
    v_message  := replace(v_message,'[PARA_FROM]',null);
    v_message  := replace(v_message,'([PARA_POSITION])',null);

    for r_tempaprq in c_tempaprq loop --find by codapp
      if nvl(v_tmp_codempid,r_tempaprq.emres) <> r_tempaprq.emres then --send mail when diff respondible
        commit;
        ---<<gen excel and send mail---
        v_send_msg  := replace(v_message,'[PARAM1]', get_temploy_name(v_tmp_codempid,v_lang));
        --excel(v_report,v_head,v_coduser,v_codapp);
        v_error         := sendmail_attachfile(get_tsetup_value('MAILEESS'),v_tmp_email,v_subject,v_send_msg,v_attach_file,null,null,null,null);
        --->>gen excel and send mail---
        v_numseq        := 0;
        v_tmp_codapp    := null;
        v_tmp_codempid  := r_tempaprq.emres;
        v_tmp_email     := r_tempaprq.email;
        ----Clear data temp----
        delete from ttemprpt where codapp = v_codapp;
        -----------------------
      elsif v_tmp_codempid is null then
        v_tmp_codempid  := r_tempaprq.emres;
        v_tmp_email     := r_tempaprq.email;
      end if;
      ---<<break codapp
      if v_tmp_codapp = r_tempaprq.codapp then
        v_insert_app  := null;
      else
        v_tmp_codapp  := r_tempaprq.codapp;
        v_insert_app  := get_tappprof_name(r_tempaprq.codapp,1,v_lang);
      end if;
      --->>break codapp
      ---<<inset data file excel---
      v_numseq := v_numseq + 1;
      begin
        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5)
        values (v_coduser, v_codapp, v_numseq, v_insert_app, r_tempaprq.emreq, get_temploy_name(r_tempaprq.emreq,v_lang), r_tempaprq.dtereq, r_tempaprq.numseq);
      exception when dup_val_on_index then
        null;
      end;
      --->>inset data file excel---
    end loop;
    ---<<send mail when last respondible
    commit;
    v_send_msg  := replace(v_message,'[PARAM1]', get_temploy_name(v_tmp_codempid,v_lang));
    --excel(v_report,v_head,v_coduser,v_codapp);
    v_error := sendmail_attachfile(get_tsetup_value('MAILEESS'),v_tmp_email,v_subject,v_send_msg,v_attach_file,null,null,null,null);
    --->>send mail when last respondible
  end;
--<< user4 : 23/05/2018 : STA4-1701 ||
  procedure replace_text_frmmail(p_template     in clob,
                                 p_table_req    in varchar2,
                                 p_rowid        in varchar2,
                                 p_subject      in varchar2,
                                 p_codform      in varchar2,
                                 p_coduser      in varchar2,
                                 p_lang         in varchar2,
                                 p_msg          in out clob) is
    data_file     clob;
    crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
    v_http        varchar2(1000 char);
    v_message     clob;
    v_template    clob;
    v_codpos      tpostn.codpos%type;
    p_codappr     temploy1.codempid%type   := get_codempid(p_coduser);
    v_email       varchar2(100 char);

    v_codlang     varchar2(3);
    v_codtable    varchar2(15);
    v_codcolmn    varchar2(60);
    v_funcdesc    varchar2(200);
    v_flgchksal   varchar2(1);
    v_statmt		  clob;
    v_item			  varchar2(500);
    v_value       varchar2(500);
    v_data_type   varchar2(200);

    v_codempid_req    temploy1.codempid%type;
    v_data_table_head clob;
    v_data_table_body clob;
    v_data_table      clob;
    v_data_list       clob;
    v_text_align      varchar2(1000 char);
    v_num             number := 0;
    v_sum_length      number := 0;

    type t_array_num is table of number index by binary_integer;
      v_col_length    t_array_num;

    cursor c1 is
      select b.fparam,b.ffield,
             decode(v_codlang ,'101',descripe
                              ,'102',descript
                              ,'103',descrip3
                              ,'104',descrip4
                              ,'105',descrip5) as descript,
             b.codtable,c.fwhere,
             'select '||b.ffield||' from '||b.codtable||' where '||c.fwhere as stm ,flgdesc
          from tfrmmail a,tfrmmailp b,tfrmtab c
          where a.codform   = p_codform
            and a.codform   = b.codform
            and a.typfrm    = c.typfrm
            and b.codtable  = c.codtable
       order by b.numseq;
  BEGIN
      v_http :=  get_tsetup_value('PATHMOBILE');
      begin
          select codpos,email  into v_codpos,v_email
          from temploy1
          where codempid = p_codappr;
      exception when no_data_found then
          v_codpos := null;
          v_email  := null;
      end;

     v_message   := p_msg ;
     v_template  := p_template ;
--     v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ','&nbsp;'));
     v_message   := replace(v_template,'[P_MESSAGE]', replace(v_message,chr(10),'<br>'));
     v_message   := replace(v_message,'&lt;', '<');
     v_message   := replace(v_message,'&gt;', '>');
     data_file   := v_message ;

     p_msg :=   'From: ' ||v_email|| crlf ||
                'To: [P_EMAIL]'||crlf||
                'Subject: '||p_subject||crlf||
                'Content-Type: text/html';

      if p_table_req like 'v_%' then
          execute immediate 'select codempid from '||p_table_req||' where row_id = '''||p_rowid||''' ' into v_codempid_req;
      else
          execute immediate 'select codempid from '||p_table_req||' where rowid = '''||p_rowid||''' ' into v_codempid_req;
      end if;
      --Get language from PM letter--
      begin
        select codlang
          into v_codlang
          from tfmrefr
         where codform = p_codform;
      exception when no_data_found then
        v_codlang := p_lang;
      end;
      v_codlang := nvl(v_codlang,p_lang);

      -- set head data
      v_data_table_head := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
      v_data_table_head := v_data_table_head||'<tr class="TextBody" bgcolor="#006699">';

      -- set body data
      v_data_table_body  := '<tr class="TextBody"  bgcolor="#EFF4F8">';
      v_data_list        := '<div>';

      for i in c1 loop
        v_num := v_num + 1;
        v_codtable := i.codtable;
        v_codcolmn := i.ffield;

        begin
          select funcdesc ,flgchksal, data_type into v_funcdesc,v_flgchksal,v_data_type
            from tcoldesc
           where codtable = v_codtable
             and codcolmn = v_codcolmn;
        exception when no_data_found then
          v_funcdesc := null;
          v_flgchksal:= 'N' ;
        end;

        if nvl(i.flgdesc,'N') = 'N' then
          v_funcdesc := null;
        end if;

        if v_flgchksal = 'Y' then
          v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
        elsif v_data_type = 'NUMBER' and i.ffield not in ('NUMSEQ','SEQNO') then
          v_statmt  := 'select to_char('||i.ffield||',''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
        elsif v_funcdesc is not null and i.flgdesc = 'Y' then
          v_funcdesc := replace(v_funcdesc,'P_CODE',i.ffield) ;
          v_funcdesc := replace(v_funcdesc,'P_LANG',v_codlang) ;
          v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
          v_funcdesc := replace(v_funcdesc,'P_TEXT',global_v_chken) ;
          v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where  '||i.fwhere ;
        elsif v_data_type = 'DATE' then
          v_statmt  := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where  '||i.fwhere ;
        else
          v_statmt  := i.stm ;
        end if;

        v_statmt    := replace(v_statmt,'[#CODEMPID]',v_codempid_req);
        v_statmt    := replace(v_statmt,'[#ROWID]',p_rowid);

        v_value   := execute_desc(v_statmt) ;
        if i.ffield like 'TIM%' then
          if v_value is not null then
            declare
              v_chk_length    number;
            begin
              select  char_length
              into    v_chk_length
              from    user_tab_columns
              where   table_name    = i.codtable
              and     column_name   = i.ffield;
              if v_chk_length = 4 then
                v_value   := substr(lpad(v_value,4,'0'),1,2)||':'||substr(lpad(v_value,4,'0'),-2,2);
              end if;
            exception when no_data_found then
              null;
            end;
          else
            v_value := ' - ';
          end if;
        end if;
        if v_flgchksal = 'Y' then
          v_value   := null ;
        end if;

        -- set column attribute
        if (i.ffield like 'TIM%') or (i.ffield like 'COD%' and nvl(i.flgdesc,'N') <> 'Y') or (v_data_type = 'DATE') or (i.ffield in ('NUMSEQ','SEQNO')) then
          v_text_align        := 'center';
          v_col_length(v_num) := 3;
        elsif v_data_type = 'NUMBER' then
          v_text_align        := 'right';
          v_col_length(v_num) := 3;
        else
          v_text_align        := 'left';
          v_col_length(v_num) := 5;
        end if;
        v_sum_length := v_sum_length + v_col_length(v_num);

        -- replace value
        data_file := replace(data_file,i.fparam,v_value); -- case use param in message

        -- set head data
        v_data_table_head  := v_data_table_head||'<td width="[COL_WIDTH_'||v_num||']%" align="center"><font color="#FFFFFF">'||i.descript||'</font></td>';

        -- set body data
        v_data_table_body  := v_data_table_body||'<td align="'||v_text_align||'">'||v_value||'</td>';
        v_data_list        := v_data_list||'<div>'||i.descript||': '||v_value||'</div>';
      end loop;

      -- set head data
      v_data_table_head  := v_data_table_head||'</tr>';

      -- set body data
      v_data_table_body  := v_data_table_body||'</tr>';
      v_data_list        := v_data_list||'</div>';

      v_data_table := v_data_table_head||v_data_table_body||'<table>';

      -- replace column width
      for n in 1..v_num loop
        v_data_table := replace(v_data_table,'[COL_WIDTH_'||n||']',to_char(trunc(v_col_length(n)*100/v_sum_length)));
      end loop;

      -- replace data in template
      if data_file like ('%[TABLE]%') then
        data_file  := replace(data_file  ,'[TABLE]', v_data_table);
      end if;
      if data_file like ('%[LIST]%') then
        data_file  := replace(data_file  ,'[LIST]', v_data_list);
      end if;

      if data_file like ('%[PARAM-LINK]%') then
--        data_file  := replace(data_file  ,'[PARAM-LINK]', '<a href="'||v_http||'"><span style="background: #1155cc;color: #fff;padding: 10px 20px;margin-left: 20px;text-align:center;margin-top:10px;"><b>APPROVE</b></span></a>');
        data_file  := replace(data_file  ,'[PARAM-LINK]', '<a href="'||v_http||'"><b>APPROVE</b></a>');
      end if;
      if data_file like ('%[PARAM-FROM]%') then
        data_file  := replace(data_file  ,'[PARAM-FROM]', get_temploy_name(p_codappr,v_codlang));
      end if;
      if data_file like ('%[PARAM-FROM-POSITION]%') then
        data_file  := replace(data_file  ,'[PARAM-FROM-POSITION]',get_tpostn_name(v_codpos,v_codlang));
      end if;
      p_msg := p_msg||crlf||crlf||data_file;
  end;
  -- end replace_text_frmmail
  procedure sendmail_to_approve(p_codapp        varchar2,
                                p_codtable_req  varchar2,
                                p_rowid_req     varchar2,
                                p_codtable_appr varchar2,
                                p_codempid      temploy1.codempid%type,
                                p_dtereq        date,
                                p_seqno         number,
                                p_staappr       varchar2,
                                p_approvno      varchar2,
                                p_subject_mail_codapp  varchar2,
                                p_subject_mail_numseq  varchar2,
                                p_lang          varchar2,
                                p_coduser       varchar2,
                                p_typchg        varchar2 default null,
                                p_others        varchar2 default null) is
    v_replyapp              varchar2(2 char) ;
    v_replyno               varchar2(2 char) ;
    v_msg1                  clob;
    v_msg2                  clob;
    v_msg_to                clob;
    v_msg_cc                clob;
    v_msg_no                clob;
    v_template_to           clob;
    v_template_cc           clob;
    v_func_appr             varchar2(20 char) ;
    v_error                 varchar2(20 char) ;
    v_codappr               temploy1.codempid%type:= ' ' ;
    v_codappr_last          temploy1.codempid%type:= ' ' ;
    v_approvno              varchar2(10 char);
    v_email_approver        varchar2(50 char);
    v_email_codempid        varchar2(50 char);
    v_codform_to            tfrmmail.codform%type;
    v_codform_cc            tfrmmail.codform%type;
    v_stmt                  varchar2(4000 char);
    v_cursor                number;
    v_dummy                 integer;
    v_lang_mail_approver    varchar2(100 char);
    v_lang_mail_codempid    varchar2(100 char);
    v_conftable             varchar2(100 char);--nut
  begin
    --<< receiver template for each receiver's lang
    begin
      select decode(lower(maillang),'en','101','th','102',maillang),email
        into v_lang_mail_codempid,v_email_codempid
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then v_lang_mail_codempid := '101';
    end;
    if v_lang_mail_codempid not in ('101','102','103','104','105') or v_lang_mail_codempid is null then
      v_lang_mail_codempid  := '101';
    end if;
    -->> receiver template for each receiver's lang

    chk_workflow.Get_message_reply(p_codapp,p_codempid,v_lang_mail_codempid,v_replyapp,v_msg_to,v_replyno,v_msg_no,v_template_to,v_template_cc,v_func_appr,v_codform_to,v_codform_cc,p_others ) ;
    if (p_staappr <> 'N' and v_replyapp <> 'N') or
       (p_staappr =  'N' and v_replyno  <> 'N') then
       -- mail reply (approve and reject)

      if p_staappr = 'N' then
         v_msg1 := v_msg_no;--no
      else
         v_msg1 := v_msg_to;
      end if;

      if ((substr(v_replyapp,1,1) in ('1','2') ) and  p_staappr in ( 'A','Y')  ) or
          ( p_staappr = 'N'  and substr(v_replyno,1,1) in ( '1','2'))  then         -- mail reply to approval (approve and reject)
        --<<User37 #4827 21/04/2021
        if upper(p_codtable_appr) in ('TAPOBFRQ','TAPMEDRQ') then --User37 #4813 21/04/2021  if upper(p_codtable_appr) = 'TAPOBFRQ' then
            v_conftable := ' and a.numseq    = '||p_seqno||' ';
        else
            v_conftable := ' and a.seqno    = '||p_seqno||' ';
        end if;
        -->>User37 #4827 21/04/2021
        v_stmt :=  ' select a.codappr,a.approvno,b.email '||
                     ' from '||p_codtable_appr||' a,temploy1 b '||
                    ' where a.codempid = '''||p_codempid||''' '||
                      ' and a.dtereq   = to_date('''||to_char(p_dtereq,'dd/mm/yyyy')||''',''dd/mm/yyyy'') '||
                      v_conftable;--User37 #4827 21/04/2021 ' and a.seqno    = '||p_seqno||' ';

        if p_typchg is not null then
          v_stmt := v_stmt||' and typreq = '''||p_typchg||''' ';
        end if;

        v_stmt := v_stmt||' and a.codappr  = b.codempid '||
                      ' and a.approvno <= '''||p_approvno||''' '||
                   ' order by a.approvno desc ';

        if p_codapp in ('HRES32E','HRES36E','HRES6AE','HRES86E','HRESS2E','HRES6KE','HRESS4E','HRES91E','HRES6IE','HRES88E') then
          v_stmt  := replace(v_stmt,'and a.seqno','and a.numseq');
        end if;
        commit;
        v_cursor  := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
        dbms_sql.define_column(v_cursor,1,v_codappr,1000);
        dbms_sql.define_column(v_cursor,2,v_approvno,1000);
        dbms_sql.define_column(v_cursor,3,v_email_approver,1000);

        v_dummy := dbms_sql.execute(v_cursor);
        while (dbms_sql.fetch_rows(v_cursor) > 0) loop
          dbms_sql.column_value(v_cursor,1,v_codappr);
          dbms_sql.column_value(v_cursor,2,v_approvno);
          dbms_sql.column_value(v_cursor,3,v_email_approver);

          if v_approvno = p_approvno then
            v_codappr_last := v_codappr ;
          else
            if (v_codappr_last <> v_codappr) or (v_codappr_last = v_codappr and p_approvno - v_approvno = 1) then
              --<< receiver template for each receiver's lang
              begin
                select decode(lower(maillang),'en','101','th','102',maillang)
                  into v_lang_mail_approver
                  from temploy1
                 where codempid = v_codappr;
              exception when no_data_found then v_lang_mail_approver := '101';
              end;
              if v_lang_mail_approver not in ('101','102','103','104','105') or v_lang_mail_approver is null then
                v_lang_mail_approver  := '101';
              end if;
              chk_workflow.Get_message_reply(p_codapp,v_codappr,v_lang_mail_approver,v_replyapp,v_msg_to,v_replyno,v_msg_no,v_template_to,v_template_cc,v_func_appr,v_codform_to,v_codform_cc,p_others ) ;
              if p_staappr = 'N' then
                 v_msg2 := v_msg_no;--no
              else
                 v_msg2 := v_msg_to;
              end if;
              -->> receiver template for each receiver's lang

              chk_workflow.replace_text_frmmail( p_template     => v_template_cc,
                                                 p_table_req    => p_codtable_req,
                                                 p_rowid        => p_rowid_req,
                                                 p_subject      => get_label_name(p_subject_mail_codapp,v_lang_mail_approver,p_subject_mail_numseq),
                                                 p_codform      => v_codform_cc,
                                                 p_coduser      => p_coduser,
                                                 p_lang         => v_lang_mail_approver,
                                                 p_msg          => v_msg2);
              -- send mail reply to previous approver
              if v_email_approver is not null then
                v_msg2   := replace(v_msg2,'[P_EMAIL]',v_email_approver);
                v_msg2   := replace(v_msg2,'[PARAM-TO]',get_temploy_name(v_codappr,v_lang_mail_approver));
                v_error  := SEND_MAIL(v_email_approver,v_msg2);
              end if;
              if (p_staappr <> 'N' and substr(v_replyapp,1,1) = '1') or
                 (p_staappr =  'N' and substr(v_replyno,1,1)  = '1') then
                exit;
              end if;
            end if;
          end if;
        end loop;
      end if;

      -- mail reply to employee (approve and reject)
      if (p_staappr = 'A' and substr(v_replyapp,2,1) = '1') or
         (p_staappr = 'Y' and substr(v_replyapp,2,1) in ('1','2')) or
         (p_staappr = 'N' and substr(v_replyno,2,1)  = '1') then
        if v_email_codempid is not null then
          v_msg2 := v_msg1;
          chk_workflow.replace_text_frmmail( p_template     => v_template_cc,
                                             p_table_req    => p_codtable_req,
                                             p_rowid        => p_rowid_req,
                                             p_subject      => get_label_name(p_subject_mail_codapp,v_lang_mail_codempid,p_subject_mail_numseq),
                                             p_codform      => v_codform_cc,
                                             p_coduser      => p_coduser,
                                             p_lang         => v_lang_mail_codempid,
                                             p_msg          => v_msg2);

          v_msg2   := replace(v_msg2,'[P_EMAIL]',v_email_codempid);
          v_msg2   := replace(v_msg2,'[PARAM-TO]',get_temploy_name(p_codempid,v_lang_mail_codempid));
          -- send mail reply to employee
          v_error  := SEND_MAIL(v_email_codempid,v_msg2);
        end if;
      end if;
    end if;

  end;
end;

/
