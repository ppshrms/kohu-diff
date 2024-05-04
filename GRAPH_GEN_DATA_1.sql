--------------------------------------------------------
--  DDL for Package Body GRAPH_GEN_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_GEN_DATA" AS
  procedure gen_data(p_codcomp in varchar2, p_date in date) is
    v_dtestr  date;
    v_dteend  date;
  begin
    v_dteend := last_day(p_date);  
    v_dtestr := add_months(v_dteend,-1) +1;
    gen_data_tattence(p_codcomp,v_dtestr,v_dteend);
    gen_data_tovrtime(p_codcomp,v_dtestr,v_dteend);
    gen_data_tlateabs(p_codcomp,v_dtestr,v_dteend);
    gen_data_tleavetr(p_codcomp,v_dtestr,v_dteend);
  end; 
  --
  procedure gen_data_tattence(p_codcomp in varchar2, p_dtestr in date, p_dteend in date) is
    cursor c1 is
      select to_char(tattence.dtework,'yyyy') dteyre,
             to_char(to_number(to_char(tattence.dtework,'mm'))) dtemonth,
             tattence.codcomp,tattence.codcalen,tattence.codshift,temploy1.numlvl,tcenter.comlevel,tcenter.compgrp,
             sum(tshiftcd.qtydaywk) qtyminwrkw,
             sum(tattence.qtyhwork - (nvl(tlateabs.qtylate,0) + nvl(tlateabs.qtyearly,0) + nvl(tleavetr.qtyminle,0))) qtyminwrk,
             count(*) qtydaywrkw,
             sum((tattence.qtyhwork - nvl(tlateabs.qtylate,0) - nvl(tlateabs.qtyearly,0) - nvl(tleavetr.qtyminle,0))/tshiftcd.qtydaywk) qtydaywrk
        from tattence,tshiftcd,tcenter,temploy1,tlateabs,
            (select codempid,dtework,sum(qtymin) as qtyminle from tleavetr group by codempid,dtework) tleavetr
       where tattence.codshift = tshiftcd.codshift
         and tattence.codcomp  = tcenter.codcomp
         and tattence.codempid = temploy1.codempid
         and tattence.codempid = tlateabs.codempid(+)
         and tattence.dtework  = tlateabs.dtework(+)
         and tattence.codempid = tleavetr.codempid(+)
         and tattence.dtework  = tleavetr.dtework(+)
         and tattence.typwork  not in ('H','T','S')
         and temploy1.numlvl   is not null
         and tattence.qtyhwork > 0
         and tattence.dtework  between p_dtestr and p_dteend
         and tattence.codcomp like p_codcomp||'%'
         --and to_char(tattence.dtework,'yyyy') = to_char(sysdate,'yyyy')
    group by to_char(tattence.dtework,'yyyy'),to_char(to_number(to_char(tattence.dtework,'mm'))),tattence.codcomp,tattence.codcalen,tattence.codshift,temploy1.numlvl,tcenter.comlevel,tcenter.compgrp;

  begin
    delete graph_tattence where dteyre = to_char(p_dtestr,'yyyy') and dtemonth = to_number(to_char(p_dtestr,'mm')); commit;
    for r1 in c1 loop
      begin
        insert into graph_tattence(dteyre,dtemonth,compgrp,codcomp,comlevel,codcalen,codshift,numlvl,qtyminwrkw,qtyminwrk,qtydaywrkw,qtydaywrk)
                            values(r1.dteyre,r1.dtemonth,r1.compgrp,r1.codcomp,r1.comlevel,r1.codcalen,r1.codshift,r1.numlvl,r1.qtyminwrkw,r1.qtyminwrk,r1.qtydaywrkw,r1.qtydaywrk);
      end;
    end loop;
    commit;
  end;  
  --
  procedure gen_data_tovrtime(p_codcomp in varchar2, p_dtestr in date, p_dteend in date) is
    cursor c1 is
      select to_char(tovrtime.dtework,'yyyy') dteyre,
             to_char(to_number(to_char(tovrtime.dtework,'mm'))) dtemonth,
             tovrtime.codcomp,tovrtime.codcalen,tovrtime.codshift,temploy1.numlvl,tovrtime.codrem,tcenter.comlevel,tcenter.compgrp,
             sum(tovrtime.qtyminot) qtyminot,
             sum(tovrtime.qtyminot/tshiftcd.qtydaywk) qtydayot
        from tovrtime, tcenter, temploy1, tshiftcd
       where tovrtime.codcomp   = tcenter.codcomp
         and tovrtime.codempid  = temploy1.codempid
         and tovrtime.codshift  = tshiftcd.codshift
         and temploy1.numlvl    is not null
         and tovrtime.dtework   between p_dtestr and p_dteend -- to_char(tovrtime.dtework,'yyyy') = to_char(sysdate,'yyyy')
         and tovrtime.codcomp   like p_codcomp||'%'
    group by to_char(tovrtime.dtework,'yyyy'),to_char(to_number(to_char(tovrtime.dtework,'mm'))),tovrtime.codcomp,tovrtime.codcalen,tovrtime.codshift,temploy1.numlvl,tovrtime.codrem,tcenter.comlevel,tcenter.compgrp;

  begin
    delete graph_tovrtime where dteyre = to_char(p_dtestr,'yyyy') and dtemonth = to_number(to_char(p_dtestr,'mm')); commit;
    for r1 in c1 loop
      begin
        insert into graph_tovrtime(dteyre,dtemonth,compgrp,codcomp,comlevel,codcalen,codshift,numlvl,codrem,qtyminot,qtydayot)
                            values(r1.dteyre,r1.dtemonth,r1.compgrp,r1.codcomp,r1.comlevel,r1.codcalen,r1.codshift,r1.numlvl,r1.codrem,r1.qtyminot,r1.qtydayot);
      end;
    end loop;
    commit;
  end;
  --
  procedure gen_data_tlateabs(p_codcomp in varchar2, p_dtestr in date, p_dteend in date) is
    cursor c1 is
      select to_char(tlateabs.dtework,'yyyy') dteyre,
             to_char(to_number(to_char(tlateabs.dtework,'mm'))) dtemonth,
             tlateabs.codcomp,tattence.codcalen,tlateabs.codshift,temploy1.numlvl,ttimereq.codreqst,tcenter.comlevel,tcenter.compgrp,
             sum(qtylate) qtyminlate,
             sum(qtyearly) qtyminearly,
             sum(qtyabsent) qtyminabsent,
             sum(daylate) qtydaylate,
             sum(dayearly) qtydayearly,
             sum(dayabsent) qtydayabsent,
             sum(qtytlate) qtytlate,
             sum(qtytearly) qtytearly,
             sum(qtytabs) qtytabs
        from tlateabs,tattence,tcenter,temploy1,ttimereq
       where tlateabs.codempid  = tattence.codempid
         and tlateabs.dtework   = tattence.dtework
         and tlateabs.codcomp   = tcenter.codcomp
         and tlateabs.codempid  = temploy1.codempid
         and tlateabs.codempid  = ttimereq.codempid(+)
         and tlateabs.dtework   = ttimereq.dtework(+)
         and 'Y'                = ttimereq.staappr(+)   
         and temploy1.numlvl    is not null         
         and tlateabs.dtework  between p_dtestr and p_dteend -- and to_char(tlateabs.dtework,'yyyy') = to_char(sysdate,'yyyy')
         and tlateabs.codcomp like p_codcomp||'%'     
    group by to_char(tlateabs.dtework,'yyyy'),to_char(to_number(to_char(tlateabs.dtework,'mm'))),tlateabs.codcomp,tattence.codcalen,tlateabs.codshift,temploy1.numlvl,ttimereq.codreqst,tcenter.comlevel,tcenter.compgrp;

  begin
    delete graph_tlateabs where dteyre = to_char(p_dtestr,'yyyy') and dtemonth = to_number(to_char(p_dtestr,'mm')); commit;
    for r1 in c1 loop
      begin
        insert into graph_tlateabs(dteyre,dtemonth,compgrp,codcomp,comlevel,codcalen,codshift,numlvl,
                                   codreqst,qtyminlate,qtyminearly,qtyminabsent,qtydaylate,qtydayearly,qtydayabsent,qtytlate,qtytearly,qtytabs)
                            values(r1.dteyre,r1.dtemonth,r1.compgrp,r1.codcomp,r1.comlevel,r1.codcalen,r1.codshift,r1.numlvl,
                                   r1.codreqst,r1.qtyminlate,r1.qtyminearly,r1.qtyminabsent,r1.qtydaylate,r1.qtydayearly,r1.qtydayabsent,r1.qtytlate,r1.qtytearly,r1.qtytabs);
      end;
    end loop;
    commit;
  end;
  --
  procedure gen_data_tleavetr(p_codcomp in varchar2, p_dtestr in date, p_dteend in date) is
    cursor c1 is
      select to_char(tleavetr.dtework,'yyyy') dteyre,
             to_char(to_number(to_char(tleavetr.dtework,'mm'))) dtemonth,
             tleavetr.codcomp,tattence.codcalen,tleavetr.codshift,temploy1.numlvl,tleavetr.codleave,tcenter.comlevel,tcenter.compgrp,
             sum(tleavetr.qtymin) qtyminleave,
             sum(tleavetr.qtymin/tshiftcd.qtydaywk) qtydayleave
        from tleavetr,tattence,tcenter,temploy1,tshiftcd
       where tleavetr.codempid  = tattence.codempid
         and tleavetr.dtework   = tattence.dtework
         and tleavetr.codcomp   = tcenter.codcomp
         and tleavetr.codempid  = temploy1.codempid
         and tleavetr.codshift  = tshiftcd.codshift
         and temploy1.numlvl    is not null
         and tleavetr.dtework  between p_dtestr and p_dteend -- and to_char(tleavetr.dtework,'yyyy') = to_char(sysdate,'yyyy')
         and tleavetr.codcomp like p_codcomp||'%'         
        group by to_char(tleavetr.dtework,'yyyy'),to_char(to_number(to_char(tleavetr.dtework,'mm'))),tleavetr.codcomp,tattence.codcalen,tleavetr.codshift,temploy1.numlvl,tleavetr.codleave,tcenter.comlevel,tcenter.compgrp;
  begin
    delete graph_tleavetr where dteyre = to_char(p_dtestr,'yyyy') and dtemonth = to_number(to_char(p_dtestr,'mm')); commit;
    for r1 in c1 loop
      begin
        insert into graph_tleavetr(dteyre,dtemonth,compgrp,codcomp,comlevel,codcalen,codshift,numlvl,codleave,qtyminleave,qtydayleave)
                            values(r1.dteyre,r1.dtemonth,r1.compgrp,r1.codcomp,r1.comlevel,r1.codcalen,r1.codshift,r1.numlvl,r1.codleave,r1.qtyminleave,r1.qtydayleave);
      end;
    end loop;
    commit;
  end;    
end;

/
