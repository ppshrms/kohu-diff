--------------------------------------------------------
--  DDL for Package Body OTBUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "OTBUDGET" is  

  procedure get_manpw_budget(p_codcomp in varchar2,p_dtestrt in date,p_dteend in date,
                             p_qtymanpw out number,p_qtyhworkall out number) is
    
    v_qtydaywk      number;

    cursor c1 is
      select codshift,count(dtework) as qtyday
      from   tattence 
      where  codcomp  = rpad(p_codcomp,21,'0') --user36 KOHU-HR2301 #1803 26/03/2024 ||codcomp  like p_codcomp||'%'
      and    dtework  between p_dtestrt and p_dteend
      and    typwork  in ('W','L')
      group by codshift
      order by codshift;

  begin
    begin
      select count(distinct(codempid))  
      into   p_qtymanpw
      from   tattence 
      where  codcomp  = rpad(p_codcomp,21,'0') --user36 KOHU-HR2301 #1803 26/03/2024 ||codcomp  like p_codcomp||'%'
      and    dtework  between p_dtestrt and p_dteend
      and    typwork  in ('W','L');
    exception when no_data_found then null;
    end;

    p_qtyhworkall := 0;
    for i in c1 loop
      begin
        select qtydaywk
        into   v_qtydaywk
        from   tshiftcd
        where  codshift = i.codshift;
      exception when no_data_found then 
        v_qtydaywk := 0;
      end;
      p_qtyhworkall := p_qtyhworkall + (i.qtyday * v_qtydaywk);
    end loop;
  end;

  procedure get_ot_budget(p_qtyhworkall in number,p_pctbudget in number,p_pctabslv in number,
                          p_qtyhwork out number,p_qtybudget out number) is
    v_min				number;
  begin
    if nvl(p_pctabslv, 0) > 0 then
      p_qtyhwork := p_qtyhworkall * (100 - p_pctabslv) / 100;
    else
      p_qtyhwork := p_qtyhworkall;
    end if;
    p_qtybudget := p_qtyhwork * p_pctbudget / 100;

    --<<user36 KOHU-HR2301 10/11/2023 fix issue uat #1467 ปัดเศษแบบ V9
		if p_qtyhwork > 0 then
			v_min := mod(p_qtyhwork,60);
			if v_min >= 30 then
				p_qtyhwork := (trunc(p_qtyhwork/60,0)*60) + 60;
			else
				p_qtyhwork := (trunc(p_qtyhwork/60,0)*60);
			end if;
		end if;

		if p_qtybudget > 0 then
			v_min := mod(p_qtybudget,60);
			if v_min >= 30 then
				p_qtybudget := (trunc(p_qtybudget/60,0)*60) + 60;
			else
				p_qtybudget := (trunc(p_qtybudget/60,0)*60);
			end if;
		end if;	
    -->>user36 KOHU-HR2301 10/11/2023
  end;

  procedure get_bugget_data(p_codempid in varchar2,p_dtework in date,p_codcompw in varchar2,
                            p_dtereq in date,p_numseq in number,p_dtestrt in date,p_dteend in date,
                            p_codcompbg out varchar2,p_qtybudget out number,p_qtyothot out number) is

    v_1stday        date;
    v_dtestrt       date;
    v_dteend        date;
    v_qtyothot_al   number := 0;
    v_qtyothot_al2  number := 0;

    cursor c1 is
      select codcomp,qtybudget
      from   tbudgetot
      where  dteyear    = to_number(to_char(p_dtework, 'yyyy'))
      and    dtemonth   = to_number(to_char(p_dtework, 'mm'))  
      and    p_codcompw like codcomp || '%'
      order by codcomp desc;

  begin
    v_dtestrt := p_dtestrt;----greatest(p_dtestrt, to_date('01/'||to_char(p_dtework,'mm/yyyy'),'dd/mm/yyyy') );
    v_dteend := p_dteend;----least(p_dtestrt + 6, last_day(p_dtework));
    ----
    for i in c1 loop
      p_codcompbg := i.codcomp;
      p_qtybudget := i.qtybudget;
      exit;
    end loop;
    --
    v_1stday := to_date('01/'||to_char(p_dtework, 'mm/yyyy'), 'dd/mm/yyyy');
    p_qtybudget := p_qtybudget * (/*p*/v_dteend - /*p*/v_dtestrt + 1)
                               / (last_day(v_1stday) - v_1stday + 1);
    --
    p_qtyothot := 0;
    begin
      select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
      into   p_qtyothot
      from   ttotreq a, tovrtime b
      where  a.codcompbg  = p_codcompbg
      and    a.dtestrt    between /*p*/v_dtestrt and /*p*/v_dteend
      and    a.staappr    not in ('C', 'N')
      and    a.numotreq   = b.numotreq (+)
      and    not (a.codempid = p_codempid and a.dtereq = p_dtereq and a.numseq = p_numseq)
      and    to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') 
             = (select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0'))
                from   ttotreq c
                where  a.codempid = c.codempid
                and    a.dtestrt  = c.dtestrt
                and    c.staappr  not in ('C', 'N') --user36 KOHU 02/04/2024
                );
    exception when no_data_found then null;
    end;
    begin
      select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
      into   v_qtyothot_al
      from   totreqd a, tovrtime b
      where  otbudget.get_codcompbg(nvl(a.codcompw, a.codcomp), a.dtewkreq) = p_codcompbg 
      and    a.dtewkreq between /*p*/v_dtestrt and /*p*/v_dteend
      and    a.numotreq = b.numotreq(+)
      and    a.codempid = b.codempid(+)
      and    a.dtewkreq = b.dtework(+)
      and    a.typot    = b.typot(+)
      and    not exists (select c.numotreq 
                         from   ttotreq c 
                         where  c.numotreq = a.numotreq)
      and    a.numotreq = (select max(d.numotreq)
                           from   totreqd d
                           where  a.codempid = d.codempid   
                           and    a.dtewkreq = d.dtewkreq     
                           and    a.typot    = d.typot         
                           );
    exception when no_data_found then null;
    end;
    begin
      select nvl(sum(qtyminot), 0)
      into   v_qtyothot_al2
      from   tovrtime 
      where  otbudget.get_codcompbg(nvl(codcompw, codcomp), dtework) = p_codcompbg 
      and    dtework  between /*p*/v_dtestrt and /*p*/v_dteend
      and    numotreq is null;
    exception when no_data_found then null;
    end;
    p_qtyothot := p_qtyothot + v_qtyothot_al + v_qtyothot_al2;
  end;

  /*procedure upd_qtyotreq(p_codcompbg in varchar2,p_month in number,p_year in number) is
    v_qtyotpend     number;
    v_qtyotappr     number;
  begin
    begin
      select nvl(sum(nvl(qtyotreq,0)),0)
      into   v_qtyotpend
      from   ttotreq 
      where  codcompbg = p_codcompbg
      and    to_number(to_char(dtestrt, 'yyyy'))  = p_year
      and    to_number(to_char(dtestrt, 'mm'))    = p_month
      and    staappr   in ('P', 'A');
    exception when no_data_found then null;
    end;
    begin
      select nvl(sum(nvl(qtyotreq,0)),0)
      into   v_qtyotappr
      from   ttotreq 
      where  codcompbg = p_codcompbg
      and    to_number(to_char(dtestrt, 'yyyy'))  = p_year
      and    to_number(to_char(dtestrt, 'mm'))    = p_month
      and    staappr   = 'Y';
    exception when no_data_found then null;
    end;
    --
    update tbudgetot set qtyotpend  = v_qtyotpend,
                         qtyotappr  = v_qtyotappr
    where  dteyear  = p_year
    and    dtemonth = p_month
    and    codcomp  = p_codcompbg;

    commit;
  end;*/

  function get_codcompbg(p_codcompw in varchar2,p_dtework in date) return varchar2 is

    v_codcompbg     varchar2(40 char);

    cursor c1 is
      select codcomp
      from   tbudgetot
      where  dteyear  = to_number(to_char(p_dtework, 'yyyy'))
      and    dtemonth = to_number(to_char(p_dtework, 'mm'))  
      and    p_codcompw like codcomp || '%'
      order by codcomp desc;

  begin
    for i in c1 loop
      v_codcompbg := i.codcomp;
      exit;
    end loop;
    return v_codcompbg;
  end;
end;

/
