--------------------------------------------------------
--  DDL for Package Body STD_OT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_OT" is
-- last update: 21/04/2021 15:00        --redmine895

  procedure get_week_ot(p_codempid      in temploy1.codempid%type,
						p_numotreq      in varchar2,
						p_dtereq        in date,
						p_numseq        in number,
						p_dtestrt       in date,
                        p_dteend        in date,
                        p_qtyminb       number,
                        p_timbend       varchar2,
                        p_timbstr       varchar2,
                        p_qtymind       number,
                        p_timdend       varchar2,
                        p_timdstr       varchar2,
                        p_qtymina       number,
                        p_timaend       varchar2,
                        p_timastr       varchar2,
                        global_v_codempid varchar2,
                        a_dtestweek     out a_dtestr,
                        a_dteenweek     out a_dtestr,
                        a_sumwork       out a_qtyotstr,
                        a_sumotreqoth   out a_qtyotstr,
                        a_sumotreq      out a_qtyotstr,
                        a_sumot         out a_qtyotstr,
                        a_totwork       out a_qtyotstr,
                        v_qtyperiod     out number) is
    v_dtestrtwk     date;
    v_dteendwk      date;
    v_count_period  number;

  begin
    delete ttemprpt
     where codempid = global_v_codempid
       and codapp = 'CALOT36'||p_codempid;
       
    v_count_period              := 1;
    v_dtestrtwk                 := get_dtestrt_period (p_codempid ,p_dtestrt);
    v_dteendwk                  := v_dtestrtwk + 6;
    a_dtestweek(v_count_period) := v_dtestrtwk;
    a_dteenweek(v_count_period) := v_dteendwk;
    while p_dteend > v_dteendwk loop
        v_count_period              := v_count_period + 1;
        v_dtestrtwk                 := v_dteendwk + 1;
        v_dteendwk                  := v_dtestrtwk + 6;
        a_dtestweek(v_count_period) := v_dtestrtwk;
        a_dteenweek(v_count_period) := v_dteendwk;
    end loop;
    for i in 1..v_count_period loop
        get_totauto(p_codempid,a_dtestweek(i), a_dteenweek(i),global_v_codempid);
        get_ttotreq(p_codempid,p_dtereq,p_numseq,p_numotreq,a_dtestweek(i), a_dteenweek(i),global_v_codempid);
        get_totreq(p_codempid,p_numotreq,a_dtestweek(i), a_dteenweek(i),global_v_codempid);
        get_tovrtime(p_codempid,p_numotreq, a_dtestweek(i), a_dteenweek(i),global_v_codempid);
        get_calotreq(p_codempid, p_dtestrt, p_dteend,
                     p_qtyminb, p_timbend, p_timbstr,
                     p_qtymind, p_timdend, p_timdstr,
                     p_qtymina, p_timaend, p_timastr,
                     p_numotreq, global_v_codempid);
        a_sumwork(i)        := get_qtyminwk(p_codempid, a_dtestweek(i), a_dteenweek(i));
        begin
            select nvl(sum(nvl(temp31,0)),0)
              into a_sumotreqoth(i)
              from ttemprpt
             where codempid = global_v_codempid
               and codapp = 'CALOT36'||p_codempid
               and item1 = p_codempid
               and item10 in('1','2','3','4')
               and to_date(item2,'dd/mm/yyyy') between a_dtestweek(i) and a_dteenweek(i);
        exception when others then
            a_sumotreqoth(i) := 0;
        end;

        begin
            select nvl(sum(nvl(temp31,0)),0)
              into a_sumotreq(i)
              from ttemprpt
             where codempid = global_v_codempid
               and codapp = 'CALOT36'||p_codempid
               and item1 = p_codempid
               and item10 in('5')
               and to_date(item2,'dd/mm/yyyy') between a_dtestweek(i) and a_dteenweek(i);
        exception when others then
            a_sumotreq(i) := 0;
        end;
        a_sumot(i)          := a_sumotreqoth(i) + a_sumotreq(i);
        a_totwork(i)        := a_sumwork(i) + a_sumot(i);
    end loop;
    v_qtyperiod             := v_count_period;
  end;

  function get_dtestrt_period (p_codempid varchar2 ,p_dtestrot date) return date is
    v_codcompy      tcontrot.codcompy%type;
    v_startday      tgrpwork.startday%type;
    v_daystrtot     tgrpwork.startday%type;
    v_dtestrtwk     date;
    v_strtweek      date;
    v_monday        number;
  begin
/*      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcompy   := null;
      end;

      begin
          select startday
            into v_startday
            from tcontrot
           where codcompy = v_codcompy
             and dteeffec = (select max(dteeffec)
                               from tcontrot
                              where codcompy = v_codcompy
                                and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        v_startday   := null;
      end;
*/
    begin
      select startday into v_startday
        from tgrpwork a, temploy1 b
       where b.codempid = p_codempid
         and b.codcomp  like a.codcomp||'%'
         and a.codcalen = b.codcalen
         and a.dteeffec = (select max(c.dteeffec)
                             from tgrpwork c
                            where c.codcomp   = a.codcomp
                              and c.codcalen  = a.codcalen
                              and a.dteeffec <= p_dtestrot /*24/04/2024 : KOHU-HR2301 || sysdate*/)
         and rownum     = 1
    order by a.codcomp desc;
    exception when no_data_found then null;
    end;   
insert_temp2('YYY','YYY',1,p_codempid,to_char(p_dtestrot,'dd/mm/yyyy'),v_startday,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));    
    v_startday := nvl(v_startday,'2');

      begin
          Select NEXT_DAY(TRUNC(p_dtestrot,'IW'),v_startday)
            into v_dtestrtwk
            From dual;
      exception when others then
        v_dtestrtwk := sysdate;
      end;

      if v_dtestrtwk > p_dtestrot then
          v_dtestrtwk := v_dtestrtwk - 7;
      end if;
    return v_dtestrtwk;
  end get_dtestrt_period;

  function get_dtestrt_period2 (p_codcomp varchar2 ,p_codcalen varchar2 ,p_dtestrot date) return date is
    v_codcompy      tcontrot.codcompy%type;
    v_startday      tgrpwork.startday%type;
    v_daystrtot     tgrpwork.startday%type;
    v_dtestrtwk     date;
    v_strtweek      date;
    v_monday        number;
  begin
    begin
      select startday into v_startday
        from tgrpwork a
       where rpad(p_codcomp,21,'0') like a.codcomp ||'%'-- user22 : 01/04/2024 : KOHU-HR2301 || where a.codcomp  like p_codcomp ||'%'
         and a.codcalen = nvl(p_codcalen,a.codcalen)
         and a.dteeffec = (select max(c.dteeffec)
                             from tgrpwork c
                            where c.codcomp   = a.codcomp
                              and c.codcalen  = a.codcalen
                              and a.dteeffec <= p_dtestrot /*24/04/2024 : KOHU-HR2301 || sysdate*/)
         and rownum     = 1
    order by a.codcomp desc;
    exception when no_data_found then null;
    end;    
    v_startday := nvl(v_startday,'2');

      begin
          Select NEXT_DAY(TRUNC(p_dtestrot,'IW'),v_startday)
            into v_dtestrtwk
            From dual;
      exception when others then
        v_dtestrtwk := sysdate;
      end;

      if v_dtestrtwk > p_dtestrot then
          v_dtestrtwk := v_dtestrtwk - 7;
      end if;
    return v_dtestrtwk;
  end get_dtestrt_period2;  
/*
    function get_dtestrt_prdcomp(p_codcomp varchar2, p_dtestrot date) return date is
    v_codcompy      tcontrot.codcompy%type;
    v_startday      tgrpwork.startday%type;
    v_daystrtot     tgrpwork.startday%type;
    v_dtestrtwk     date;
    v_strtweek      date;
    v_monday        number;
  begin
      v_codcompy    := hcm_util.get_codcomp_level(p_codcomp,1);

      begin
          select startday
            into v_startday
            from tcontrot
           where codcompy = v_codcompy
             and dteeffec = (select max(dteeffec)
                               from tcontrot
                              where codcompy = v_codcompy
                                and dteeffec <= trunc(sysdate))
             and rownum = 1;
      exception when no_data_found then
        v_startday   := null;
      end;

      Select NEXT_DAY(TRUNC(p_dtestrot,'IW'),v_startday)
        into v_dtestrtwk
        From dual;

      if v_dtestrtwk > p_dtestrot then
          v_dtestrtwk := v_dtestrtwk - 7;
      end if;
      return v_dtestrtwk;
  end get_dtestrt_prdcomp;
*/
  function get_qtyminwk(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date) return number is
    v_qtydaywk              number;
    v_qtymin                number;
    tshiftcd_qtydaywk       number;
    v_qtyabsent             number;

    cursor c1 is
        select *
          from tattence
         where codempid = v_codempid
           and dtework between v_dtestrtwk and v_dteendwk;
  begin
    --<<user36 ST11 #9142 22/03/2023
    --Shift Work
    begin
      select sum(nvl(b.qtydaywk,0))
        into v_qtydaywk
        from tattence a,tshiftcd b
       where a.codempid = v_codempid
         and a.dtework  between v_dtestrtwk and v_dteendwk
         and a.typwork  not in ('H','S','T')
         and a.codshift = b.codshift;
    exception when no_data_found then
      v_qtydaywk := 0;
    end;
    --Abnormal Work
    begin
     select sum(nvl(qtyabsent,0) + nvl(qtyearly,0) + nvl(qtylate,0))                       
       into v_qtyabsent
       from tlateabs
      where codempid = v_codempid
        and dtework  between v_dtestrtwk and v_dteendwk;
    exception when no_data_found then
      v_qtyabsent := 0;
    end;
    --Leave
    begin
      select sum(nvl(qtymin,0))
        into v_qtymin
        from tleavetr
       where codempid = v_codempid
         and dtework between v_dtestrtwk and v_dteendwk;
    exception when no_data_found then
      v_qtymin := 0;
    end;

    v_qtydaywk := nvl(v_qtydaywk,0) - nvl(v_qtyabsent,0) - nvl(v_qtymin,0);
    -->>user36 ST11 #9142 22/03/2023
      /*old
      v_qtydaywk := 0;
      for r1 in c1 loop
        if (nvl(r1.qtyhwork,0) = 0 and r1.dtework >= trunc(sysdate) and r1.typwork = 'W') or
           (nvl(r1.qtyhwork,0) = 0 /*and r1.dtein is null and r1.dteout is null * /and r1.typwork = 'W')   then


            begin
--<<user14||16/02/2023||redmine9142            
             --select  nvl(dayabsent, 0)
             select nvl(dayabsent,0) + nvl(dayearly,0) + nvl(daylate,0)
-->>user14||16/02/2023||redmine9142                         
                 into v_qtyabsent
               from tlateabs
             where codempid = v_codempid
                and dtework     = r1.dtework;
             exception when no_data_found then
             v_qtyabsent  := 0;
            end;

            if  v_qtyabsent = 1 then
                tshiftcd_qtydaywk := 0;
            else
                begin
                    select sum(qtydaywk)
                      into tshiftcd_qtydaywk
                      from tshiftcd
                     where codshift = r1.codshift;
                exception when no_data_found then
                    tshiftcd_qtydaywk := 0;
                end;
            end if;
            v_qtydaywk := v_qtydaywk + nvl(tshiftcd_qtydaywk,0);
        else
            v_qtydaywk := v_qtydaywk + nvl(r1.qtyhwork,0);
        end if;
      end loop;

      begin
          select sum(qtymin)
            into v_qtymin
            from tleavetr
           where codempid = v_codempid
             and dtework between v_dtestrtwk and v_dteendwk;
      exception when no_data_found then
        v_qtymin := null;
      end;

     -- begin
     --    select  nvl(sum(qtyabsent), 0)
      --       into v_qtyabsent
     --      from tlateabs
      --   where codempid = v_codempid
     --       and dtework  between v_dtestrtwk and v_dteendwk;
     --    exception when no_data_found then
     --    v_qtyabsent  := 0;
    --  end;

      v_qtydaywk := nvl(v_qtydaywk,0) - nvl(v_qtymin,0);-- nvl(v_qtyabsent,0);*/

    return v_qtydaywk;
  end get_qtyminwk;


  procedure get_totauto(v_codempid          in temploy1.codempid%type,
                        v_dtestrtwk         date,
                        v_dteendwk          date,
                        global_v_codempid   varchar2) is
    v_numseq_tmp        ttemprpt.numseq%type;
    v_count_date    number;
    v_dte           date;
    v_dtestrt       date;
    v_dteend        date;
    v_codcompy      tcompny.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;
    v_qtyminot      number;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;

    v_codcalen      tattence.codcalen%type;
    v_codshift      tattence.codshift%type;
    v_typwork_auto  tattence.typwork%type;

    v_dtein         date;
    v_dteout        date;
    v_timin         varchar2(4);
    v_timout        varchar2(4);

    cursor c1 is
      select dtestrt,dtecancl,dteend,codcalen,codshift,typwork,timstrtb
              ,qtyminb,timendb,numotreq,timstrtd,qtymind,timendd,timstrta
              ,timenda,qtymina
        from totreqst
       where typotreq = '2'
         and (dtestrt between v_dtestrtwk and v_dteendwk
              or nvl(dtecancl,dteend) between v_dtestrtwk and v_dteendwk
              or v_dtestrtwk between dtestrt and nvl(dtecancl,dteend)
              or v_dteendwk between dtestrt and nvl(dtecancl,dteend))
         and ((v_codempid is not null
               and v_codempid = (select codempid
                                   from temploy1
                                  where codempid = v_codempid
                                    and codcomp like totreqst.codcomp||'%'
                                    and codcalen = nvl(totreqst.codcalen,codcalen))))
      order by numotreq;

    cursor c2 is
        select dtein, timin, dteout,timout,dteendw,timendw,dtestrtw,
               timstrtw,dtework,codempid,codshift
          from tattence
         where codempid = v_codempid
           and codcalen = nvl(v_codcalen,codcalen)
           and codshift = nvl(v_codshift,codshift)
           and ((typwork = v_typwork_auto and v_typwork_auto <> 'A')
                or  (v_typwork_auto = 'A' and typwork <> 'L'))
--           and typwork <> 'L' and nvl(qtyhwork,0) = 0      -- user18 2021-11-17
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = v_codempid;
    exception when no_data_found then
        v_codcompy := '';
    end;

    begin
        select dteeffec,condot,condextr
          into v_dteeffec,v_condot,v_condextr
          from tcontrot
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = v_codcompy
                              and dteeffec <= sysdate)
           and rownum <= 1;
    exception when no_data_found then null;
       v_dteeffec   := null;
       v_condot     := '';
       v_condextr   := '';
    end;

    for r1 in c1 loop
        v_dtestrt   := greatest(r1.dtestrt,v_dtestrtwk);
        v_dteend    := least(nvl(r1.dtecancl,r1.dteend),v_dteendwk);

        v_codcalen      := r1.codcalen;
        v_codshift      := r1.codshift;
        v_typwork_auto  := r1.typwork;

        for r2 in c2 loop
            v_qtyminot  := 0;
--<< user22 : 14/03/2024 : KOH-HR2301 ||
            v_dtein := null;
            v_dteout := null;
            /*v_dtein := r2.dtein;
            v_timin := r2.timin;

            v_dteout := r2.dteout;
            v_timout := r2.timout;*/
-->> user22 : 14/03/2024 : KOH-HR2301 ||
            if v_dtein is null then
                v_dtein := r2.dteendw - 1;
                v_timin := r2.timendw;
            end if;

            if v_dteout is null then
                v_dteout := r2.dtestrtw + 1;
                v_timout := r2.timstrtw;
            end if;

            if r1.timstrtb is not null or nvl(r1.qtyminb,0) > 0 then
                if nvl(r1.qtyminb,0) > 0 then
                    v_dtestrt2      := null;
                    v_timstrt2      := null;
                    v_dteend2       := null;
                    v_timend2       := null;
                    v_qtyminreq2    := r1.qtyminb;
                else
                    v_dtestrt2      := r2.dtework;
                    v_timstrt2      := replace(r1.timstrtb,':');
                    v_dteend2       := r2.dtework;
                    v_timend2       := replace(r1.timendb,':');
                    v_qtyminreq2    := null;
                    if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                        v_dteend2   := r2.dtework + 1;
                    end if;
                end if;

                hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                          null,r2.codempid,r2.dtework,'B',r2.codshift,
--                                          nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                          v_dtein,v_timin,v_dteout,v_timout,
                                          v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                          null,null,null,null,'Y',
                                          v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                for i in 1..5 loop
                    v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                end loop;

                if v_qtyminot > 0 then
                    if not chk_duptemp(r2.codempid, r2.dtework, 'B', global_v_codempid) then
                        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                        v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        insert into ttemprpt (codempid,codapp,numseq,
                                              item1,item2,item3,item4,item5,
                                              item6,item7,item8,item10,temp31)
                        values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                               r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'B', r1.numotreq,
                               to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timstrtb,
                               to_char(r1.dteend,'dd/mm/yyyy'), r1.timendb,
                               '3', v_qtyminot);
                    else
                        update ttemprpt
                           set temp31 = v_qtyminot,
                               item10 = '3'
                         where codempid = global_v_codempid
                           and codapp = 'CALOT36'||r2.codempid
                           and item1 = r2.codempid
                           and to_date(item2,'dd/mm/yyyy') = r2.dtework
                           and item3 = 'B';
                    end if;
                end if;
            end if;

            v_qtyminot  := 0;
            if r1.timstrtd is not null or nvl(r1.qtymind,0) > 0 then
                if nvl(r1.qtymind,0) > 0 then
                    v_dtestrt2      := null;
                    v_timstrt2      := null;
                    v_dteend2       := null;
                    v_timend2       := null;
                    v_qtyminreq2    := r1.qtymind;
                else
                    v_dtestrt2      := r2.dtestrtw;
                    v_timstrt2      := replace(r1.timstrtd,':');
                    v_dteend2       := r2.dteendw;
                    v_timend2       := replace(r1.timendd,':');
                    v_qtyminreq2    := null;
                    if v_timend2 < v_timstrt2  /*or r2.timendw < r2.timstrtw*/  then
                        v_dteend2   := r2.dtework + 1;
                    end if;
                    if v_timstrt2 < r2.timstrtw then
                        v_dtestrt2 := r2.dteendw;
                    end if;
                end if;

                hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                          null,r2.codempid,r2.dtework,'D',r2.codshift,
--                                          nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                          v_dtein,v_timin,v_dteout,v_timout,
                                          v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                          null,null,null,null,'Y',
                                          v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                for i in 1..5 loop
                    v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                end loop;

                if v_qtyminot > 0 then
                    if not chk_duptemp(r2.codempid, r2.dtework, 'D', global_v_codempid) then
                        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                        v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        insert into ttemprpt (codempid,codapp,numseq,
                                              item1,item2,item3,item4,item5,
                                              item6,item7,item8,item10,temp31)
                        values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                               r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'D', r1.numotreq,
                               to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timstrtd,
                               to_char(r1.dteend,'dd/mm/yyyy'), r1.timendd,
                               '3', v_qtyminot);
                    else
                        update ttemprpt
                           set temp31 = v_qtyminot,
                               item10 = '3'
                         where codempid = global_v_codempid
                           and codapp = 'CALOT36'||r2.codempid
                           and item1 = r2.codempid
                           and to_date(item2,'dd/mm/yyyy') = r2.dtework
                           and item3 = 'D';
                    end if;
                end if;
            end if;

            v_qtyminot  := 0;
            if r1.timstrta is not null or nvl(r1.qtymina,0) > 0 then
                    if nvl(r1.qtymina,0) > 0 then
                    v_dtestrt2      := null;
                    v_timstrt2      := null;
                    v_dteend2       := null;
                    v_timend2       := null;
                    v_qtyminreq2    := r1.qtymina;
                else
                    v_dtestrt2      := r2.dteendw;
                    v_timstrt2      := replace(r1.timstrta,':');
                    v_dteend2       := r2.dteendw;
                    v_timend2       := replace(r1.timenda,':');
                    v_qtyminreq2    := null;
                    if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                        v_dteend2   := r2.dteendw + 1;
                    end if;
                end if;

                hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                          null,r2.codempid,r2.dtework,'A',r2.codshift,
--                                          nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                          v_dtein,v_timin,v_dteout,v_timout,
                                          v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                          null,null,null,null,'Y',
                                          v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                for i in 1..5 loop
                    v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                end loop;

                if v_qtyminot > 0 then
                    if not chk_duptemp(r2.codempid, r2.dtework, 'A', global_v_codempid) then
                        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                        v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        insert into ttemprpt (codempid,codapp,numseq,
                                              item1,item2,item3,item4,item5,
                                              item6,item7,item8,item10,temp31)
                        values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                               r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'A', r1.numotreq,
                               to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timstrta,
                               to_char(r1.dteend,'dd/mm/yyyy'), r1.timenda,
                               '3', v_qtyminot);
                    else
                        update ttemprpt
                           set temp31 = v_qtyminot,
                               item10 = '3'
                         where codempid = global_v_codempid
                           and codapp = 'CALOT36'||r2.codempid
                           and item1 = r2.codempid
                           and to_date(item2,'dd/mm/yyyy') = r2.dtework
                           and item3 = 'A';
                    end if;
                end if;
            end if;
        end loop;
    end loop;
  end;

  procedure get_ttotreq(v_codempid          in temploy1.codempid%type,
                        v_dtereq            date,
                        v_numseq            number,
                        v_numotreq          varchar2,
                        v_dtestrtwk         date,
                        v_dteendwk          date,
                        global_v_codempid   varchar2) is
    v_numseq_tmp        ttemprpt.numseq%type;
    v_count_date    number;
    v_dte           date;
    v_dtestrt       date;
    v_dteend        date;
    v_codcompy      tcompny.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;
    v_qtyminot      number;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;

    v_dtein         date;
    v_dteout        date;
    v_timin         varchar2(4);
    v_timout        varchar2(4);

    cursor c1 is
      select *
        from ttotreq
       where codempid = v_codempid
         and (dtestrt between v_dtestrtwk and v_dteendwk
              or dteend between v_dtestrtwk and v_dteendwk
              or v_dtestrtwk between dtestrt and dteend
              or v_dteendwk between dtestrt and dteend
              )
         and nvl(staappr,'P') not in ('C','N')
--         and nvl(numotreq,'xxxx') <> nvl(v_numotreq,'yyyy')
         and codempid||to_char(dtereq,'yyyymmdd')||numseq <>
             v_codempid||to_char(v_dtereq,'yyyymmdd')||v_numseq
      order by dtestrt;
      
    cursor c2 is
        select *
          from tattence
         where codempid = v_codempid
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = v_codempid;
    exception when no_data_found then
        v_codcompy := '';
    end;

    begin
        select dteeffec,condot,condextr
          into v_dteeffec,v_condot,v_condextr
          from tcontrot
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = v_codcompy
                              and dteeffec <= sysdate)
           and rownum <= 1;
    exception when no_data_found then null;
       v_dteeffec   := null;
       v_condot     := '';
       v_condextr   := '';
    end;

    for r1 in c1 loop
        v_dtestrt   := r1.dtestrt;
        v_dteend   := r1.dteend;
        for r2 in c2 loop
            v_qtyminot  := 0;

--<< user22 : 14/03/2024 : KOH-HR2301 ||
            v_dtein := null;
            v_dteout := null;
            /*v_dtein := r2.dtein;
            v_timin := r2.timin;

            v_dteout := r2.dteout;
            v_timout := r2.timout;*/
-->> user22 : 14/03/2024 : KOH-HR2301 ||
            if v_dtein is null then
                v_dtein := r2.dteendw - 1;
                v_timin := r2.timendw;
            end if;

            if v_dteout is null then
                v_dteout := r2.dtestrtw + 1;
                v_timout := r2.timstrtw;
            end if;

            if r1.timbstr is not null or nvl(r1.qtyminb,0) > 0 then
                if max_req(r1.codempid, r1.dtestrt, r1.dtereq, r1.numseq, 'B', r1.numotreq, 'ESS') then
                    if nvl(r1.qtyminb,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtyminb;
                    else
                        v_dtestrt2      := r2.dtework;
                        v_timstrt2      := replace(r1.timbstr,':');
                        v_dteend2       := r2.dtework;
                        v_timend2       := replace(r1.timbend,':');
                        v_qtyminreq2    := null;
                        if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                            v_dteend2   := r2.dtework + 1;
                        end if;
                    end if;

                    hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                              null,r2.codempid,r2.dtework,'B',r2.codshift,
--                                              nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                              v_dtein,v_timin,v_dteout,v_timout,
                                              v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                              null,null,null,null,'Y',
                                              v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                    for i in 1..5 loop
                        v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                    end loop;

                    if v_qtyminot > 0 then
                        if not chk_duptemp(r2.codempid, r2.dtework, 'B', global_v_codempid) then
                            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                            v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            insert into ttemprpt (codempid,codapp,numseq,
                                                  item1,item2,item3,item4,item5,
                                                  item6,item7,item8,item10,temp31)
                            values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                                   r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'B', r1.numotreq,
                                   to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timbstr,
                                   to_char(r1.dteend,'dd/mm/yyyy'), r1.timbend,
                                   '1', v_qtyminot);
                        else
                            update ttemprpt
                               set temp31 = v_qtyminot,
                                   item10 = '1'
                             where codempid = global_v_codempid
                               and codapp = 'CALOT36'||r2.codempid
                               and item1 = r2.codempid
                               and to_date(item2,'dd/mm/yyyy') = r2.dtework
                               and item3 = 'B';
                        end if;
                    end if;
                end if;
            end if;

            v_qtyminot  := 0;
            if r1.timdstr is not null or nvl(r1.qtymind,0) > 0 then
                if max_req(r1.codempid, r1.dtestrt, r1.dtereq, r1.numseq, 'D', r1.numotreq, 'ESS') then
                    if nvl(r1.qtymind,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtymind;
                    else
                        v_dtestrt2      := r2.dtestrtw;
                        v_timstrt2      := replace(r1.timdstr,':');
                        v_dteend2       := r2.dteendw;
                        v_timend2       := replace(r1.timdend,':');
                        v_qtyminreq2    := null;
                        if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                            v_dteend2   := r2.dtework + 1;
                        end if;
                        if v_timstrt2 < r2.timstrtw then
                            v_dtestrt2 := r2.dteendw;
                        end if;

                    end if;

                    hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                              null,r2.codempid,r2.dtework,'D',r2.codshift,
--                                              nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                              v_dtein,v_timin,v_dteout,v_timout,
                                              v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                              null,null,null,null,'Y',
                                              v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                    for i in 1..5 loop
                        v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                    end loop;

                    if v_qtyminot > 0 then
                        if not chk_duptemp(r2.codempid, r2.dtework, 'D', global_v_codempid) then
                            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                            v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            insert into ttemprpt (codempid,codapp,numseq,
                                                  item1,item2,item3,item4,item5,
                                                  item6,item7,item8,item10,temp31)
                            values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                                   r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'D', r1.numotreq,
                                   to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timdstr,
                                   to_char(r1.dteend,'dd/mm/yyyy'), r1.timdend,
                                   '1', v_qtyminot);
                        else
                            update ttemprpt
                               set temp31 = v_qtyminot,
                                   item10 = '1'
                             where codempid = global_v_codempid
                               and codapp = 'CALOT36'||r2.codempid
                               and item1 = r2.codempid
                               and to_date(item2,'dd/mm/yyyy') = r2.dtework
                               and item3 = 'D';
                        end if;
                    end if;
                end if;
            end if;

            v_qtyminot  := 0;
            if r1.timastr is not null or nvl(r1.qtymina,0) > 0 then
                if max_req(r1.codempid, r1.dtestrt, r1.dtereq, r1.numseq, 'A', r1.numotreq, 'ESS') then
                    if nvl(r1.qtymina,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtymina;
                    else
                        v_dtestrt2      := r2.dteendw;
                        v_timstrt2      := replace(r1.timastr,':');
                        v_dteend2       := r2.dteendw;
                        v_timend2       := replace(r1.timaend,':');
                        v_qtyminreq2    := null;
                        if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                            v_dteend2   := r2.dteendw + 1;
                        end if;
                    end if;

                    hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                              null,r2.codempid,r2.dtework,'A',r2.codshift,
--                                              nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                              v_dtein,v_timin,v_dteout,v_timout,
                                              v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                              null,null,null,null,'Y',
                                              v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                    for i in 1..5 loop
                        v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                    end loop;
                    if v_qtyminot > 0 then
                        if not chk_duptemp(r2.codempid, r2.dtework, 'A', global_v_codempid) then
                            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            -- v_numseq_tmp := get_max_numseq(global_v_codempid); -- bk
                            v_numseq_tmp := get_max_numseq(global_v_codempid,r2.codempid); -- add
                            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                            insert into ttemprpt (codempid,codapp,numseq,
                                                  item1,item2,item3,item4,item5,
                                                  item6,item7,item8,item10,temp31)
                            values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq_tmp,
                                   r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), 'A', r1.numotreq,
                                   to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timastr,
                                   to_char(r1.dteend,'dd/mm/yyyy'), r1.timaend,
                                   '1', v_qtyminot);
                        else
                            update ttemprpt
                               set temp31 = v_qtyminot,
                                   item10 = '1'
                             where codempid = global_v_codempid
                               and codapp = 'CALOT36'||r2.codempid
                               and item1 = r2.codempid
                               and to_date(item2,'dd/mm/yyyy') = r2.dtework
                               and item3 = 'A';
                        end if;
                    end if;
                end if;
            end if;
        end loop;
    end loop;
  end;

  procedure get_totreq(v_codempid         in temploy1.codempid%type,
                        v_numotreq         varchar2,
                        v_dtestrtwk        date,
                        v_dteendwk         date,
                        global_v_codempid  varchar2) is
    v_numseq        ttemprpt.numseq%type;
    v_count_date    number;
    v_dte           date;
    v_dtestrt       date;
    v_dteend        date;
    v_codcompy      tcompny.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;
    v_qtyminot      number;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;

    v_dtein         date;
    v_dteout        date;
    v_timin         varchar2(4);
    v_timout        varchar2(4);

    cursor c1 is
      select *
        from totreqd
       where codempid = v_codempid
         and dtewkreq between v_dtestrtwk and v_dteendwk
         and nvl(numotreq,'xxxx') <> nvl(v_numotreq,'yyyy')
      order by dtestrt;

    cursor c2 is
        select *
          from tattence
         where codempid = v_codempid
           and typwork <> 'L'
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = v_codempid;
    exception when no_data_found then
        v_codcompy := '';
    end;

    begin
        select dteeffec,condot,condextr
          into v_dteeffec,v_condot,v_condextr
          from tcontrot
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = v_codcompy
                              and dteeffec <= sysdate)
           and rownum <= 1;
    exception when no_data_found then null;
       v_dteeffec   := null;
       v_condot     := '';
       v_condextr   := '';
    end;
    v_numseq := 0;
    for r1 in c1 loop
        v_dtestrt   := r1.dtewkreq;
        v_dteend    := r1.dtewkreq;
        for r2 in c2 loop
            v_qtyminot  := 0;

--<< user22 : 14/03/2024 : KOH-HR2301 ||
            v_dtein := null;
            v_dteout := null;
            /*v_dtein := r2.dtein;
            v_timin := r2.timin;

            v_dteout := r2.dteout;
            v_timout := r2.timout;*/
-->> user22 : 14/03/2024 : KOH-HR2301 ||
            if v_dtein is null then
                v_dtein := r2.dteendw - 1;
                v_timin := r2.timendw;
            end if;

            if v_dteout is null then
                v_dteout := r2.dtestrtw + 1;
                v_timout := r2.timstrtw;
            end if;
            if max_req(r1.codempid, r1.dtewkreq, null, null, r1.typot, r1.numotreq, 'AL') then

                if r1.typot = 'B' then
                    if nvl(r1.qtyminr,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtyminr;
                    else
                        v_dtestrt2      := r2.dtework;
                        v_timstrt2      := replace(r1.timstrt,':');
                        v_dteend2       := r2.dtework;
                        v_timend2       := replace(r1.timend,':');
                        v_qtyminreq2    := null;
                        if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                            v_dteend2   := r2.dtework + 1;
                        end if;
                    end if;
                elsif r1.typot = 'D' then
                    if nvl(r1.qtyminr,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtyminr;
                    else
                        v_dtestrt2      := r2.dtestrtw;
                        v_timstrt2      := replace(r1.timstrt,':');
                        v_dteend2       := r2.dteendw;
                        v_timend2       := replace(r1.timend,':');
                        v_qtyminreq2    := null;
                        if v_timstrt2 < r2.timstrtw then
                            v_dtestrt2 := r2.dteendw;
                        end if;
                    end if;
                elsif r1.typot = 'A' then
                    if nvl(r1.qtyminr,0) > 0 then
                        v_dtestrt2      := null;
                        v_timstrt2      := null;
                        v_dteend2       := null;
                        v_timend2       := null;
                        v_qtyminreq2    := r1.qtyminr;
                    else
                        v_dtestrt2      := r2.dteendw;
                        v_timstrt2      := replace(r1.timstrt,':');
                        v_dteend2       := r2.dteendw;
                        v_timend2       := replace(r1.timend,':');
                        v_qtyminreq2    := null;
                        if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
                            v_dteend2   := r2.dteendw + 1;
                        end if;
                    end if;
                end if;

--                if nvl(r1.qtyminr,0) > 0 then
--                    v_dtestrt2      := null;
--                    v_timstrt2      := null;
--                    v_dteend2       := null;
--                    v_timend2       := null;
--                    v_qtyminreq2    := r1.qtyminr;
--                else
--                    v_dtestrt2      := r1.dtestrt;
--                    v_timstrt2      := replace(r1.timstrt,':');
--                    v_dteend2       := r1.dteend;
--                    v_timend2       := replace(r1.timend,':');
--                    v_qtyminreq2    := null;
--                    if v_timend2 < v_timstrt2 /*or r2.timendw < r2.timstrtw*/  then
--                        v_dteend2   := r1.dteend + 1;
--                    end if;
--                end if;

                hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                          null,r2.codempid,r2.dtework,r1.typot,r2.codshift,
--                                          nvl(r2.dtein,r2.dtestrtw),nvl(r2.timin,'0000'),nvl(r2.dteout,r2.dteendw+1),nvl(r2.timout,'2359'),
                                          v_dtein,v_timin,v_dteout,v_timout,
                                          v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                          null,null,null,null,'Y',
                                          v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                for i in 1..5 loop
                    v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
                end loop;
                if v_qtyminot > 0 then
                    if not chk_duptemp(r2.codempid, r2.dtework, r1.typot, global_v_codempid) then
                        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        -- v_numseq := get_max_numseq(global_v_codempid); -- bk
                        v_numseq := get_max_numseq(global_v_codempid,r2.codempid); -- add
                        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                        insert into ttemprpt (codempid,codapp,numseq,
                                              item1,item2,item3,item4,item5,
                                              item6,item7,item8,item10,temp31)
                        values(global_v_codempid, 'CALOT36'||r2.codempid,v_numseq,
                               r2.codempid, to_char(r2.dtework,'dd/mm/yyyy'), r1.typot, r1.numotreq,
                               to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timstrt,
                               to_char(r1.dteend,'dd/mm/yyyy'), r1.timend,
                               '2', v_qtyminot);
                    else
                        update ttemprpt
                           set temp31 = v_qtyminot,
                               item10 = '2'
                         where codempid = global_v_codempid
                           and codapp = 'CALOT36'||r2.codempid
                           and item1 = r2.codempid
                           and to_date(item2,'dd/mm/yyyy') = r2.dtework
                           and item3 = r1.typot;
                    end if;
                end if;
            end if;
        end loop;
    end loop;
  end;

  procedure get_tovrtime(v_codempid         in temploy1.codempid%type,
                         v_numotreq         varchar2,
                         v_dtestrtwk        date,
                         v_dteendwk         date,
                         global_v_codempid  varchar2) is
    v_numseq    ttemprpt.numseq%type;
    cursor c1 is
        select *
          from tovrtime
         where codempid = v_codempid
           and dtework between v_dtestrtwk and v_dteendwk
           and nvl(numotreq,'xxxx') <> nvl(v_numotreq,'yyyy')
           and dtework not in (select to_date(item2,'dd/mm/yyyy')
                                 from ttemprpt
                                where item1 = v_codempid
                                  and codapp = 'CALOT36'||v_codempid
                                  and to_date(item2,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
                                  and codempid = global_v_codempid
                              );
  begin
    for r1 in c1 loop
        if not chk_duptemp(v_codempid, r1.dtework, r1.typot, global_v_codempid) then
            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
            -- v_numseq := get_max_numseq(global_v_codempid); -- bk
            v_numseq := get_max_numseq(global_v_codempid,r1.codempid); -- add
            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,item5,
                                  item6,item7,item8,item10,temp31)
            values(global_v_codempid, 'CALOT36'||r1.codempid,v_numseq,
                   r1.codempid, to_char(r1.dtework,'dd/mm/yyyy'), r1.typot, r1.numotreq,
                   to_char(r1.dtestrt,'dd/mm/yyyy'), r1.timstrt,
                   to_char(r1.dteend,'dd/mm/yyyy'), r1.timend,
                   '4', r1.qtyminot);
        else
            update ttemprpt
               set temp31 = r1.qtyminot,
                   item10 = '4'
             where codempid = global_v_codempid
               and codapp = 'CALOT36'||r1.codempid
               and item1 = r1.codempid
               and to_date(item2,'dd/mm/yyyy') = r1.dtework
               and item3 = r1.typot;
        end if;
    end loop;
  end;

  procedure get_calotreq(v_codempid varchar2,   v_dtestrt date,     v_dteend date,
                         v_qtyminb number,      v_timbend varchar2, v_timbstr varchar2,
                         v_qtymind number,      v_timdend varchar2, v_timdstr varchar2,
                         v_qtymina number,      v_timaend varchar2, v_timastr varchar2,
                         v_numotreq varchar2,
                         global_v_codempid varchar2) is

    v_qtyminot      number;
    v_dteot         date;
    v_a_tovrtime    tovrtime%rowtype;
    v_a_rteotpay    hral85b_batch.a_rteotpay;
    v_a_qtyminot    hral85b_batch.a_qtyminot;
    v_codcompy      tcontrot.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;
    v_numseq        number;

    v_dtein         date;
    v_dteout        date;
    v_timin         varchar2(4);
    v_timout        varchar2(4);
    v_timstotd    tshiftcd.timstotd%type;

    cursor c1 is
        select *
          from tattence
         where codempid = v_codempid
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = v_codempid;
    exception when no_data_found then
      v_codcompy := '';
    end;

    begin
        select dteeffec,condot,condextr
          into v_dteeffec,v_condot,v_condextr
          from tcontrot
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = v_codcompy
                              and dteeffec <= sysdate)
           and rownum <= 1;
    exception when no_data_found then null;
        v_dteeffec := null;
        v_condot   := '';
        v_condextr := '';
    end;

    for r1 in c1 loop
        v_qtyminot := 0;
--<< user22 : 14/03/2024 : KOH-HR2301 ||
        v_dtein := null;
        v_dteout := null;
        /*v_dtein := r2.dtein;
        v_timin := r2.timin;

        v_dteout := r2.dteout;
        v_timout := r2.timout;*/
-->> user22 : 14/03/2024 : KOH-HR2301 ||
        if v_dtein is null then
            v_dtein := r1.dteendw - 1;
            v_timin := r1.timendw;
        end if;

        if v_dteout is null then
            v_dteout := r1.dtestrtw + 1;
            v_timout := r1.timstrtw;
        end if;

        if nvl(v_qtyminb,0) > 0 or (v_timbstr is not null and v_timbend is not null) then
            if nvl(v_qtyminb,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtyminb;
            else
                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timbstr,':');
                v_dteend2       := r1.dtework;
                v_timend2       := replace(v_timbend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 /*or r1.timendw < r1.timstrtw */ then
                    v_dteend2   := r1.dtework + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'B',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
            if v_qtyminot > 0 then
                if not chk_duptemp(r1.codempid, r1.dtework, 'B', global_v_codempid) then
                    -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    -- v_numseq := get_max_numseq(global_v_codempid); -- bk
                    v_numseq := get_max_numseq(global_v_codempid,r1.codempid); -- add
                    -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    insert into ttemprpt (codempid,codapp,numseq,
                                          item1,item2,item3,item4,item5,
                                          item6,item7,item8,item10,temp31)
                    values(global_v_codempid, 'CALOT36'||r1.codempid,v_numseq,
                           r1.codempid, to_char(r1.dtework,'dd/mm/yyyy'), 'B', v_numotreq,
                           to_char(v_dtestrt,'dd/mm/yyyy'), v_timbstr,
                           to_char(v_dteend,'dd/mm/yyyy'), v_timbend,
                           '5', v_qtyminot);
                else
                    update ttemprpt
                       set temp31 = v_qtyminot,
                           item10 = '5'
                     where codempid = global_v_codempid
                       and codapp = 'CALOT36'||r1.codempid
                       and item1 = r1.codempid
                       and to_date(item2,'dd/mm/yyyy') = r1.dtework
                       and item3 = 'B';
                end if;
            end if;
        end if;

        v_qtyminot := 0;
        if nvl(v_qtymind,0) > 0 or (v_timdstr is not null and v_timdend is not null) then
            if nvl(v_qtymind,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymind;
            else
                begin
                  select timstotd
                    into v_timstotd
                    from tshiftcd
                   where codshift = r1.codshift;
                exception when no_data_found then null;
                end;
                v_timstotd      := nvl(v_timstotd,r1.timstrtw);

                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timdstr,':');
                if v_timstrt2 < v_timstotd then
                  v_dtestrt2    := v_dtestrt2 + 1 ;
                end if;
                v_dteend2       := v_dtestrt2;
                v_timend2       := replace(v_timdend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 then
                  v_dteend2 := v_dteend2 + 1 ;
                end if;

            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'D',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;

            if v_qtyminot > 0 then
                if not chk_duptemp(r1.codempid, r1.dtework, 'D', global_v_codempid) then
                    -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    -- v_numseq := get_max_numseq(global_v_codempid); -- bk
                    v_numseq := get_max_numseq(global_v_codempid,r1.codempid); -- add
                    -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    insert into ttemprpt (codempid,codapp,numseq,
                                          item1,item2,item3,item4,item5,
                                          item6,item7,item8,item10,temp31)
                    values(global_v_codempid, 'CALOT36'||r1.codempid,v_numseq,
                           r1.codempid, to_char(r1.dtework,'dd/mm/yyyy'), 'D', v_numotreq,
                           to_char(v_dtestrt,'dd/mm/yyyy'), v_timdstr,
                           to_char(v_dteend,'dd/mm/yyyy'), v_timdend,
                           '5', v_qtyminot);
                else
                    update ttemprpt
                       set temp31 = v_qtyminot,
                           item10 = '5'
                     where codempid = global_v_codempid
                       and codapp = 'CALOT36'||r1.codempid
                       and item1 = r1.codempid
                       and to_date(item2,'dd/mm/yyyy') = r1.dtework
                       and item3 = 'D';
                end if;
            end if;
        end if;

        v_qtyminot := 0;
        if nvl(v_qtymina,0) > 0 or (v_timastr is not null and v_timaend is not null) then
            if nvl(v_qtymina,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymina;
            else
                v_dtestrt2      := r1.dteendw;
                v_timstrt2      := replace(v_timastr,':');
                v_dteend2       := r1.dteendw;
                v_timend2       := replace(v_timaend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 /*or r1.timendw < r1.timstrtw */ then
                    v_dteend2   := r1.dteendw + 1 ;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'A',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;

            if v_qtyminot > 0 then
                if not chk_duptemp(r1.codempid, r1.dtework, 'A', global_v_codempid) then
                    -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    -- v_numseq := get_max_numseq(global_v_codempid); -- bk
                    v_numseq := get_max_numseq(global_v_codempid,r1.codempid); -- add
                    -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    insert into ttemprpt (codempid,codapp,numseq,
                                          item1,item2,item3,item4,item5,
                                          item6,item7,item8,item10,temp31)
                    values(global_v_codempid, 'CALOT36'||r1.codempid,v_numseq,
                           r1.codempid, to_char(r1.dtework,'dd/mm/yyyy'), 'A', v_numotreq,
                           to_char(v_dtestrt,'dd/mm/yyyy'), v_timastr,
                           to_char(v_dteend,'dd/mm/yyyy'), v_timaend,
                           '5', v_qtyminot);
                else
                    update ttemprpt
                       set temp31 = v_qtyminot,
                           item10 = '5'
                     where codempid = global_v_codempid
                       and codapp = 'CALOT36'||r1.codempid
                       and item1 = r1.codempid
                       and to_date(item2,'dd/mm/yyyy') = r1.dtework
                       and item3 = 'A';
                end if;
            end if;
        end if;
    end loop;
  end get_calotreq;
    
  -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
  -- function get_max_numseq(global_v_codempid varchar2) return number is -- bk
  function get_max_numseq(global_v_codempid varchar2, p_codempid varchar2) return number is -- add
  -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
    v_max_numseq    ttemprpt.numseq%type;
    
  begin
      begin
          select max(numseq)
            into v_max_numseq
            from ttemprpt
           where codempid = global_v_codempid
             -- and codapp = 'CALOT36' -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
             and codapp =  'CALOT36'||p_codempid; -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
      exception when no_data_found then
        v_max_numseq   := 0;
      end;
    
      return nvl(v_max_numseq,0) + 1;
  end get_max_numseq;

  function chk_duptemp(v_codempid varchar2, v_dtework date, v_typot varchar2, global_v_codempid varchar2) return boolean is
    v_count_dup    number;
  begin
      begin
          select count(*)
            into v_count_dup
            from ttemprpt
           where codempid = global_v_codempid
             and codapp = 'CALOT36'||v_codempid
             and item1 = v_codempid
             and to_date(item2,'dd/mm/yyyy') = v_dtework
             and item3 = v_typot;
      exception when no_data_found then
        v_count_dup   := 0;
      end;
      if v_count_dup > 0 then
        return true;
      else
        return false;
      end if;
  end chk_duptemp;

  function max_req(v_codempid varchar2, v_dtestrt date, v_dtereq date, v_numseq number, v_typot varchar2, v_numotreq varchar2, v_datatype varchar2) return boolean is
    v_maxreq        varchar2(50);
  begin
    if v_datatype = 'ESS' then
        begin
            select max(to_char(dtereq,'yyyymmdd')||lpad(numseq,3,'0'))
              into v_maxreq
              from ttotreq
             where codempid = v_codempid
               and dtestrt = v_dtestrt
               and nvl(staappr,'P') not in ('C','N')
               and (decode(v_typot,'B',timbstr,'D',timdstr,'A',timastr) is not null
                    or nvl(decode(v_typot,'B',qtyminb,'D',qtymind,'A',qtymina),0) > 0);
        exception when no_data_found then
            v_maxreq   := null;
        end;

        if to_char(v_dtereq,'yyyymmdd')||lpad(v_numseq,3,'0') = nvl(v_maxreq,'xxxx') then
            return true;
        else
            return false;
        end if;
    else
        begin
            select max(numotreq)
              into v_maxreq
              from totreqd
             where codempid = v_codempid
               and dtewkreq = v_dtestrt
               and typot = v_typot
               and dayeupd is null;
        exception when no_data_found then
            v_maxreq   := null;
        end;

        if v_numotreq = nvl(v_maxreq,'xxxx') then
            return true;
        else
            return false;
        end if;
    end if;
  end max_req;


  function get_qtyminot(p_codempid varchar2, v_dtestrt date, v_dteend date,
                        v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
                        v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
                        v_qtymina number,v_timaend varchar2,v_timastr varchar2) return number is

    v_qtyminot      number;
    v_dteot         date;
    v_a_tovrtime    tovrtime%rowtype;
    v_a_rteotpay    hral85b_batch.a_rteotpay;
    v_a_qtyminot    hral85b_batch.a_qtyminot;
    v_codcompy      tcontrot.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;

    v_dtein         date;
    v_dteout        date;
    v_timin         varchar2(4);
    v_timout        varchar2(4);

    cursor c1 is
        select *
          from tattence
         where codempid = p_codempid
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
      select  hcm_util.get_codcomp_level(codcomp,1)
        into  v_codcompy
        from  temploy1
       where  codempid = p_codempid;
    exception when no_data_found then
      v_codcompy := '';
    end;

    begin
      select  dteeffec,condot,condextr
        into  v_dteeffec,v_condot,v_condextr
        from  tcontrot
       where  codcompy = v_codcompy
         and  dteeffec = (select  max(dteeffec)
                            from  tcontrot
                           where  codcompy = v_codcompy
                             and  dteeffec <= sysdate)
         and  rownum <= 1;
    exception when no_data_found then null;
      v_dteeffec := null;
      v_condot   := '';
      v_condextr := '';
    end;

    for r1 in c1 loop
--<< user22 : 14/03/2024 : KOH-HR2301 ||
        v_dtein := null;
        v_dteout := null;
        /*v_dtein := r2.dtein;
        v_timin := r2.timin;

        v_dteout := r2.dteout;
        v_timout := r2.timout;*/
-->> user22 : 14/03/2024 : KOH-HR2301 ||
        if v_dtein is null then
            v_dtein := r1.dteendw - 1;
            v_timin := r1.timendw;
        end if;

        if v_dteout is null then
            v_dteout := r1.dtestrtw + 1;
            v_timout := r1.timstrtw;
        end if;

        if nvl(v_qtyminb,0) > 0 or (v_timbstr is not null and v_timbend is not null) then
            if nvl(v_qtyminb,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtyminb;
            else
                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timbstr,':');
                v_dteend2       := r1.dtework;
                v_timend2       := replace(v_timbend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 /*or r1.timendw < r1.timstrtw */ then
                    v_dteend2   := r1.dtework + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'B',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
        if nvl(v_qtymind,0) > 0 or (v_timdstr is not null and v_timdend is not null) then
            if nvl(v_qtymind,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymind;
            else
                v_dtestrt2      := r1.dtestrtw;
                v_timstrt2      := replace(v_timdstr,':');
                v_dteend2       := r1.dteendw;
                v_timend2       := replace(v_timdend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 /*or r1.timendw < r1.timstrtw*/  then
                    v_dteend2   := r1.dtework + 1;
                end if;
                if v_timstrt2 < r1.timstrtw then
                    v_dtestrt2 := r1.dteendw;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'D',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
        if nvl(v_qtymina,0) > 0 or (v_timastr is not null and v_timaend is not null) then
            if nvl(v_qtymina,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymina;
            else
                v_dtestrt2      := r1.dteendw;
                v_timstrt2      := replace(v_timastr,':');
                v_dteend2       := r1.dteendw;
                v_timend2       := replace(v_timaend,':');
                v_qtyminreq2    := null;
                if v_timend2 < v_timstrt2 /*or r1.timendw < r1.timstrtw */then
                    v_dteend2   := r1.dteendw + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'A',r1.codshift,
--                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtein,v_timin,v_dteout,v_timout,
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
    end loop;
    return v_qtyminot;
  end get_qtyminot;

  function get_qtyminotOth_notTmp (p_codempid varchar2 ,p_dtestrtwk date, p_dteendwk date, p_codapp varchar2, global_v_codempid varchar2) return number is
    v_sumotreqoth   number;
  begin
    if p_codapp = 'HRMS6KE3' then
        begin
            select nvl(sum(nvl(temp31,0)),0)
              into v_sumotreqoth
              from ttemprpt t1
             where codempid = global_v_codempid
               and codapp = 'CALOT36'||p_codempid
               and item1 = p_codempid
               and item10 in('1','2','3','4')
               and to_date(item2,'dd/mm/yyyy') between p_dtestrtwk and p_dteendwk
               and not exists(select item1
                                from ttemprpt t2
                               where to_date(t2.item1,'dd/mm/yyyy') = to_date(t1.item2,'dd/mm/yyyy')
                                 and t2.item2 = p_codempid
                                 and t2.item5 = t1.item3
                                 and t2.codempid = global_v_codempid
                                 and t2.codapp = p_codapp);
        exception when others then
            v_sumotreqoth := 0;
        end;
        return v_sumotreqoth;
    elsif p_codapp = 'HRAL41E' then
        begin
            select nvl(sum(nvl(temp31,0)),0)
              into v_sumotreqoth
              from ttemprpt t1
             where codempid = global_v_codempid
               and codapp = 'CALOT36'||p_codempid
               and item1 = p_codempid
               and item10 in('1','2','3','4')
               and to_date(item2,'dd/mm/yyyy') between p_dtestrtwk and p_dteendwk
               and not exists(select item1
                                from ttemprpt t2
                               where to_date(t2.item1,'dd/mm/yyyy') = to_date(t1.item2,'dd/mm/yyyy')
                                 and t2.item2 = p_codempid
                                 and t2.item4 = t1.item3
                                 and t2.codempid = global_v_codempid
                                 and t2.codapp = p_codapp);
        exception when others then
            v_sumotreqoth := 0;
        end;
        return v_sumotreqoth;
    end if;
  end get_qtyminotOth_notTmp;
end;

/
