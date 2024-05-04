--------------------------------------------------------
--  DDL for Package Body HRMS55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS55X" is
-- last update: 15/04/2019 20:13

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    b_index_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    b_index_typleave    := hcm_util.get_string_t(json_obj,'p_typleave');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure insert_tlereqd_temp
    (p_dtework  tlereqd.dtework%type,
     p_flgwork  varchar2,--tlereqd.flgwork%type,
     p_timstrt  tlereqd.timstrt%type,
     p_timend   tlereqd.timend%type,
     p_qtymin   tlereqd.qtymin%type,
     p_qtyday   tlereqd.qtyday%type,
     p_codempid varchar2,
     p_codleave varchar2,
     p_coduser  varchar2,
     p_numlereq varchar2,
     p_codcomp  varchar2,
     p_numlvl   number)
  is
    v_count    number;
  begin
    begin
      select count(*)
        into v_count
        from tlereqd_temp
       where dtework  = trunc(p_dtework)
         and flgwork  = p_flgwork
         and codleave = p_codleave;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count  = 0 then
      begin
        insert into tlereqd_temp (numlereq  ,dtework  ,
                             flgwork   ,codleave ,
                             codempid  ,timstrt  ,
                             timend    ,qtymin   ,
                             qtyday    ,dayeupd  ,
                             coduser   ,codcomp,numlvl)
              values (p_numlereq ,p_dtework ,
                             p_flgwork ,p_codleave,
                             p_codempid,p_timstrt ,
                             p_timend  ,p_qtymin  ,
                             p_qtyday  ,null      ,
                             p_coduser ,p_codcomp ,p_numlvl);  -- Modify
      exception when dup_val_on_index then
        null;
      end;
      commit;
    end if;
  end; -- Procedure insert_tlereqd
  --
  procedure cal_data (p_save     boolean,
                      p_dtestrt  date,
                      p_dteend   date ,
                      p_codempid varchar2, -- ADD
                      p_timstrt  varchar2, -- ADD
                      p_timend   varchar2, -- ADD
                      p_codleave varchar2, -- ADD
                      p_numlereq varchar2, -- ADD
                      p_coduser  varchar2,-- ADD
                      p_dtereq   varchar2,
                      p_seqno    number,
                      p_qtyday  out number,-- ADD
                      p_qtymin  out number,
                      p_flgleave in tlereqst.flgleave%type) is  -- ADD

    v_codempid    temploy1.codempid%type;
    v_codcomp     temploy1.codcomp%type;
    v_flgwkcal    tleavety.flgwkcal%type;
    v_flgchol     tleavety.flgchol%type;
    v_qtyvacat    tleavsum.qtyvacat%type;
    v_qtydleot    tleavsum.qtydleot%type;
    v_qtydlemx    tleavsum.qtydlemx%type;
    v_tleaverq    tleaverq%rowtype;
    r_tleavetr    tleavetr%rowtype;
    r_tlereqd     tlereqd%rowtype;
    v_error       boolean;
    v_date        date;
    v_dtework     tattence.dtework%type;
    v_dtelest     tlereqd.dtework%type;
    v_timlest     tlereqd.timstrt%type;
    v_dteleen     tlereqd.dtework%type;
    v_timleen     tlereqd.timend%type;
    v_qtymin      tlereqd.qtymin%type;
    v_qtyday      tlereqd.qtyday%type;
    v_sumday      number;
    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_flgdlemx    tleavety.flgdlemx%type;
    v_timstrt     tlereqd.timstrt%type;
    v_timend      tlereqd.timstrt%type;
    v_qtypriyr    NUMBER ;
    v_dteeffec    DATE ;
    v_yrecycle    NUMBER(4);
    v_dtecycst    DATE;
    v_dtecycen    DATE;
    v_strtw       DATE;
    v_endle       DATE;

    qty_day       NUMBER ;
    qty_min       NUMBER ;
    qtytime       NUMBER ;
    qtyday1       NUMBER:= 0;
    qtyday2       NUMBER:= 0;
    qtyday3       NUMBER:= 0;
    qtyday4       NUMBER:= 0;
    qtyday5       NUMBER:= 0;
    qtyday6       number:= 0;
    v_numlvl      number;

    p_qtyavgwk    NUMBER;
    v_qtyavgwk    number;

  cursor c_tattence is

      select codempid,dtework,typwork,codshift,codcalen,
             flgatten,dtestrtw,timstrtw,dteendw,timendw
      from   tattence
      where  codempid = p_codempid
      and    dtework  = v_dtework
      order by codempid,dtework;

--  cursor c_tattencr is
--      select codempid,dtework,typwork,codshift,codcalen,
--             flgatten,dtestrtw,timstrtw,dteendw,timendw
--      from   tattencr
--      where  codempid = p_codempid
--      and    dtework  = v_dtework
--      order by codempid,dtework;

  begin
    qty_day   := 0 ;
    qty_min   := 0 ;
    v_timstrt := p_timstrt ;
    v_timend  := p_timend  ;
    begin
        select * into v_tleaverq
          from tleaverq
         where codempid = p_codempid
           and dtereq   = to_date(p_dtereq,'ddmmyyyy')
           and seqno    = p_seqno;
    exception when no_data_found then
       null;
    end;

    <<main_loop>>
    loop
        if p_codempid is null or p_codleave is null or
             p_dtestrt is null  or p_dteend is null then
            exit main_loop;
        end if;

        begin
            select codempid,codcomp,numlvl
            into   v_codempid,v_codcomp,v_numlvl
            from   temploy1
            where  codempid = p_codempid;
        exception when no_data_found then
            exit main_loop;
        end;

    begin
        select qtyavgwk
        into   p_qtyavgwk   -- add
        from   tcontral
        where  codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
        and    dteeffec = (select max(dteeffec)
                                             from   tcontral
                                             where  codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
                                             and    dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
            and    rownum   = 1
            order by codcompy,dteeffec;
    exception when no_data_found then
            exit main_loop;
    end;

        begin
            select typleave,staleave
            into   v_typleave,v_staleave
            from   tleavecd
            where  codleave = p_codleave;
        exception when no_data_found then
            exit main_loop;
        end;

        begin
            select flgdlemx,nvl(qtydlepay,0),flgwkcal,flgchol
            into   v_flgdlemx,qtyday1,v_flgwkcal,v_flgchol
            from   tleavety
            where  typleave = v_typleave;
        exception when no_data_found then
            exit main_loop;
        end;

        std_al.entitlement(p_codempid  => p_codempid,
                          p_codleave  => p_codleave,
                          p_dtestrle  => p_dtestrt,
                          p_zyear     => v_zyear ,
                          p_qtyleave  => qtyday1,
                          p_qtypriyr  => v_qtypriyr,
                          p_dteeffec  => v_dteeffec);

        std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,'1'),p_codempid,v_staleave,p_dtestrt,v_yrecycle,v_dtecycst,v_dtecycen);
        qtyday1 := nvl(qtyday1,0) ;

        if v_flgdlemx = 'Y' and v_staleave = 'O' then
            if p_numlereq is not null then
                begin
                    select nvl(sum(qtyday),0)   into qtyday2
                    from   tleavetr
                    where  numlereq = p_numlereq;
                    qtytime := 1;
                exception when no_data_found then
                    qtyday2 := 0;
                end;
            end if;
        else
            begin
                select nvl(sum(qtydayle),0),nvl(sum(qtytleav),0)
                into   qtyday2,qtytime
                from   tleavsum
                where  codempid = p_codempid
                and    dteyear  = v_yrecycle - v_zyear
                and    typleave = v_typleave;
            exception when no_data_found then
                qtyday2 := 0;
            end;
        end if;
        qtyday3 := qtyday1 - qtyday2;
        v_date   := p_dtestrt;
        v_sumday := 0;
        <<cal_loop>>
        loop
              -- yesterday (tattence)
              if v_date = p_dtestrt and v_timstrt is not null then
                 v_dtework := v_date - 1;
                for r_tattence in c_tattence loop
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                    v_dteleen := r_tattence.dteendw;
                    if r_tattence.dteendw = v_tleaverq.dteend then
                        v_timleen := nvl(v_tleaverq.timend,r_tattence.timendw);
                    else
                        v_timleen := r_tattence.timendw;
                    end if;

                       begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattence.codshift;
                        exception when no_data_found then null;
                        end;

                        hral56b_batch.cal_time_leave( v_flgchol,v_codcomp,
                                        r_tattence.codcalen, r_tattence.typwork,
                                        r_tattence.codshift, r_tattence.dtestrtw,
                                        r_tattence.timstrtw, r_tattence.dteendw,
                                        r_tattence.timendw,v_dtelest,
                                        v_timlest, v_dteleen,
                                        v_timleen,v_qtymin,
                                        v_qtyday,v_qtyavgwk,p_flgleave);

                    if v_qtymin > 0 then
                        v_sumday := v_sumday + v_qtyday;
                        qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                        qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;
                        if p_save then
                            insert_tlereqd_temp(v_dtework,'W',v_timlest,v_timleen,v_qtymin,v_qtyday,
                                                p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                        end if;
                    end if;
                end loop; -- for r_tattence
              -- yesterday (tattencr)
                /*for r_tattencr in c_tattencr loop
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                    v_dteleen := r_tattencr.dteendw;
                    v_timleen := r_tattencr.timendw;
                    begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattencr.codshift;
                    exception when no_data_found then null;
                    end;
                    hral56b.cal_time_leave( v_flgchol,v_codcomp,
                                    r_tattencr.codcalen, r_tattencr.typwork,
                                    r_tattencr.codshift, r_tattencr.dtestrtw,
                                    r_tattencr.timstrtw, r_tattencr.dteendw,
                                    r_tattencr.timendw,
                                    v_dtelest, v_timlest, v_dteleen, v_timleen,
                                    v_qtymin,v_qtyday,v_qtyavgwk,p_flgleave);

                    if v_qtymin > 0 then
                        v_sumday := v_sumday + v_qtyday;
                        qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                        qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;

                        if p_save then
                            insert_tlereqd_temp(v_dtework,'R',v_timlest,v_timleen,v_qtymin,v_qtyday,
                                                p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                        end if;
                    end if;
                end loop; -- for r_tattencr*/
            end if; -- v_date = p_dtestrt and :tlereqst.timstrt is not null

            -- today (tattence)
            v_dtework := v_date;
            for r_tattence in c_tattence loop
                if v_date = p_dtestrt and v_timstrt is not null then
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                else
                    v_dtelest := r_tattence.dtestrtw;
                    v_timlest := r_tattence.timstrtw;
                end if;

            if v_timend  is not null then
                v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
                v_endle  := to_date(to_char(p_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
              if v_strtw >= v_endle then
                          exit cal_loop;
              end if;
            end if;
            --chai
                --if  v_date = p_dteend and v_timend is not null then
                if  r_tattence.dteendw >= p_dteend and v_timend is not null then
                    v_dteleen := p_dteend;
                    v_timleen := v_timend;
                else
                    v_dteleen := r_tattence.dteendw;
                    v_timleen := r_tattence.timendw;
                end if;

                     begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattence.codshift;
                    exception when no_data_found then null;
                    end;
                    hral56b_batch.cal_time_leave( v_flgchol,v_codcomp,
                                r_tattence.codcalen, r_tattence.typwork,
                                r_tattence.codshift, r_tattence.dtestrtw,
                                r_tattence.timstrtw, r_tattence.dteendw,
                                r_tattence.timendw,
                                v_dtelest, v_timlest, v_dteleen, v_timleen,
                                v_qtymin,v_qtyday,v_qtyavgwk,p_flgleave);

                if v_qtymin > 0 then
                    v_sumday := v_sumday + v_qtyday;
                    qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                    qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;

                    if p_save then
                    insert_tlereqd_temp(v_dtework,'W',v_timlest,v_timleen,v_qtymin,v_qtyday,
                                        p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                    end if;
                end if;
            end loop; -- for r_tattence
            -- today (tattencr)
            /*for r_tattencr in c_tattencr loop
                if v_date = p_dtestrt and v_timstrt is not null then
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                else
                    v_dtelest := r_tattencr.dtestrtw;
                    v_timlest := r_tattencr.timstrtw;
                end if;

                if v_timend  is not null then
                    v_strtw  := to_date(to_char(r_tattencr.dtestrtw,'dd/mm/yyyy')||r_tattencr.timstrtw,'dd/mm/yyyyhh24mi');
                    v_endle  := to_date(to_char(p_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
                    if v_strtw >= v_endle then
                        exit cal_loop;
                    end if;
                end if;

                if r_tattencr.dteendw >= p_dteend and v_timend is not null then
                    v_dteleen := p_dteend;
                    v_timleen := v_timend;
                else
                    v_dteleen := r_tattencr.dteendw;
                    v_timleen := r_tattencr.timendw;
                end if;

                   begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattencr.codshift;
                    exception when no_data_found then null;
                    end;
                    hral56b.cal_time_leave( v_flgchol,v_codcomp,
                                r_tattencr.codcalen, r_tattencr.typwork,
                                r_tattencr.codshift, r_tattencr.dtestrtw,
                                r_tattencr.timstrtw, r_tattencr.dteendw,
                                r_tattencr.timendw,
                                v_dtelest, v_timlest, v_dteleen, v_timleen,
                                v_qtymin,v_qtyday,v_qtyavgwk,p_flgleave);

                if v_qtymin > 0 then
                        v_sumday := v_sumday + v_qtyday;
                        qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                        qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;

                    if p_save then
                       insert_tlereqd_temp(v_dtework,'R',v_timlest,v_timleen,v_qtymin,v_qtyday,
                                           p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                    end if;
                end if;
            end loop; -- for r_tattencr*/
            v_date := v_date + 1;
            if v_date > p_dteend then
                exit cal_loop;
            end if;
        end loop;   -- main_loop

        if (v_sumday + qtyday2) > qtyday1 then
            if qtyday1 > qtyday2 then
                 qtyday5 := qtyday1 - qtyday2;
                 qtyday6 := v_sumday - (qtyday1 - qtyday2);
            else
                qtyday5 := 0;
                qtyday6 := v_sumday;
            end if;
        else
            qtyday5 := v_sumday;
            qtyday6 := 0;
        end if;
        exit main_loop;
    end loop; -- main_loop
    p_qtyday := qty_day;
    p_qtymin := qty_min;
  end;
  --
  procedure insert_tlereqst_temp(
    r_tleaverq  tleaverq%rowtype,
    v_numlereq  varchar2,
    v_qty_min   number,
    v_qty_day   number
  ) is
    v_numlvl  number;
    v_count   number;
    v_codappr varchar2(4000 char);
  begin
    begin
        select numlvl into v_numlvl
          from temploy1
         where codempid = r_tleaverq.codempid;
      exception when no_data_found then
        null;
      end;

      begin
          select count(*)
          into v_count
          from tlereqst_temp
          where numlereq = v_numlereq ;
      exception when no_data_found then  v_count := 0;
      end;

      if v_count  = 0 then
            INSERT INTO tlereqst_temp(codempid, dtereq  , codleave, dtestrt, timstrt, dteend,
                                     timend  , deslereq, numlereq, stalereq, dteappr, codappr,
                                     codcomp , coduser,dterecod,qtymin,qtyday,numlvl,flgleave,dteleave,codshift,filename)
                 select codempid, dtereq  , codleave, dtestrt, timstrt, dteend,
                         timend  , deslereq, v_numlereq , r_tleaverq.staappr, trunc(sysdate), v_codappr,-- user22 : 04/07/2016 : STA4590287 || p_codappr,
                         codcomp , coduser , dtereq,v_qty_min,v_qty_day,v_numlvl,flgleave,dteleave,codshift,filenam1
                   from tleaverq
                  WHERE codempid = r_tleaverq.codempid
                    AND dtereq   = r_tleaverq.dtereq
                    AND seqno    = r_tleaverq.seqno;

      else
                        UPDATE tlereqst_temp
                           SET codempid = r_tleaverq.codempid,
                               dtereq   = r_tleaverq.dtereq,
                               codleave = r_tleaverq.codleave,
                               dtestrt  = r_tleaverq.dtestrt,
                               timstrt  = r_tleaverq.timstrt,
                               dteend   = r_tleaverq.dteend,
                               timend   = r_tleaverq.timend,
                               dteappr  = trunc(sysdate),
                               codappr  = v_codappr,-- user22 : 04/07/2016 : STA4590287 || p_codappr, p_codappr,
                               codcomp  = r_tleaverq.codcomp,
                               flgleave = r_tleaverq.flgleave,
                               dteleave = r_tleaverq.dteleave,
                               codshift = r_tleaverq.codshift,
                               coduser  = global_v_coduser
                         where numlereq = v_numlereq ;
      end if;
      commit;
  end;
  --
  procedure gen_leave_temp is
    pragma autonomous_transaction;
    v_numlereq    taplverq.numlereq%type;
    v_codappr     varchar2(4000 char);
    v_numlvl      number;
    v_count       number := 0;
    v_qty_min     number;
    v_qty_day     number;
    v_cc  number := 0;

    cursor c_tleaverq is
      select rq.*
        from tleaverq rq, tleavecd cd, temploy1 em
               where rq.codleave = cd.codleave(+)
                 and rq.codempid = em.codempid
                 and rq.codempid = nvl(b_index_codempid,rq.codempid)
                 and rq.codcomp  like nvl(b_index_codcomp,rq.codcomp)
                 and cd.typleave = nvl(b_index_typleave,cd.typleave)
                 and rq.dteleave between b_index_dtestrt and b_index_dteend
                 and rq.staappr in ('P','A')
                 and rq.dtestrt is not null
                 and rq.dteend is not null
                 -- check secure
                 and (rq.codempid = global_v_codempid
                  or (rq.codempid <> global_v_codempid
                  and em.numlvl between global_v_zminlvl and global_v_zwrklvl
                  and 0 <> (select count(ts.codcomp)
                              from tusrcom ts
                             where ts.coduser = global_v_coduser
                               and rq.codcomp like ts.codcomp||'%'
                               and rownum    <= 1 )));
  begin
    for r_tleaverq in c_tleaverq loop
      v_numlereq := std_al.gen_req('LEAVTMP','tlereqst_temp','numlereq',v_zyear,get_codcompy(r_tleaverq.codcomp),'');
      std_al.upd_req('LEAVTMP',v_numlereq,global_v_coduser,v_zyear,get_codcompy(r_tleaverq.codcomp),'');
      cal_data(true,r_tleaverq.dtestrt,r_tleaverq.dteend,r_tleaverq.codempid,
               r_tleaverq.timstrt,r_tleaverq.timend,r_tleaverq.codleave,
               v_numlereq,global_v_coduser,to_char(r_tleaverq.dtereq,'ddmmyyyy'),r_tleaverq.seqno,v_qty_day,v_qty_min,r_tleaverq.flgleave);

      insert_tlereqst_temp(r_tleaverq,v_numlereq,v_qty_min,v_qty_day);
    end loop;
  end;
  --
  function format_hours(v_qtymin in number) return varchar2 is
  begin
    if v_qtymin is not null and v_qtymin <> 0 then
      return trunc(v_qtymin/60)||':'||lpad(mod(v_qtymin,60),2,'0');
    else
      return null;
    end if;
  end;
  --
  procedure check_index is
    v_typleave   varchar2(4000 char);
  begin
      if b_index_typleave is not null then
        begin
          select typleave into v_typleave
            from tleavety
           where typleave = b_index_typleave;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TLEAVETY');
          return;
        end;
      end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    v_row         number := 0;
    v_dtework     date;
    v_timinoutw   varchar2(100 char);
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_emp         number  := 0;
    v_secure      number  := 0;
    v_flgsecu     boolean := true;
    cursor c_data is
      select distinct module,codempid,codshift,codleave,dtework,timstrt,timend,staappr,codcomp,qtymin
         from (
            select distinct 'HRES62E' module,qdt.codempid,stt.codshift,qdt.codleave,
                   qdt.dtework,qdt.timstrt,qdt.timend,stt.stalereq staappr,qdt.codcomp,
                   qdt.numlereq,qdt.qtymin
              from tlereqst_temp stt,tlereqd_temp qdt,tleavecd cd,temploy1 em
             where stt.numlereq = qdt.numlereq
               and qdt.codleave = cd.codleave(+)
               and qdt.codempid = em.codempid
               and qdt.codempid = nvl(b_index_codempid,qdt.codempid)
               and qdt.codcomp  like nvl(b_index_codcomp,qdt.codcomp)
               and qdt.dtework  between b_index_dtestrt and b_index_dteend
               and cd.typleave = nvl(b_index_typleave,cd.typleave)
               and stt.dtestrt is not null
               and stt.dteend is not null
               -- check secure
               and (qdt.codempid = global_v_codempid
                or (qdt.codempid <> global_v_codempid
                and em.numlvl between global_v_zminlvl and global_v_zwrklvl
                and 0 <> (select count(ts.codcomp)
                            from tusrcom ts
                           where ts.coduser = global_v_coduser
                             and qdt.codcomp like ts.codcomp||'%'
                             and rownum    <= 1 )))
            union all
            select distinct 'HRAL51E' module,qd.codempid,st.codshift,qd.codleave,
                   nvl(tr.dtework,qd.dtework),nvl(tr.timstrt,qd.timstrt),nvl(tr.timend,qd.timend),'Y' staappr,qd.codcomp,
                   qd.numlereq,nvl(tr.qtymin,qd.qtymin)
              from tlereqst st,tlereqd qd, tleavecd cd,tleavetr tr, temploy1 em
             where st.numlereq = qd.numlereq
               and qd.codleave = cd.codleave(+)
               and qd.numlereq = tr.numlereq(+)
               and qd.codempid = tr.codempid(+) -- user4 || 28/11/2018 || case data in tleavetr and tlereqd are not match.
               and qd.dtework  = tr.dtework(+)  -- user4 || 28/11/2018 || case data in tleavetr and tlereqd are not match.
               and qd.codempid = em.codempid
               and qd.codempid = nvl(b_index_codempid,qd.codempid)
               and qd.codcomp  like nvl(b_index_codcomp,qd.codcomp)
               and qd.dtework  between b_index_dtestrt and b_index_dteend
               and cd.typleave = nvl(b_index_typleave,cd.typleave)
               and st.stalereq = 'A'
               and st.dtestrt is not null
               and st.dteend is not null
               -- check secure
               and (qd.codempid = global_v_codempid
                or (qd.codempid <> global_v_codempid
                and em.numlvl between global_v_zminlvl and global_v_zwrklvl
                and 0 <> (select count(ts.codcomp)
                            from tusrcom ts
                           where ts.coduser = global_v_coduser
                             and qd.codcomp like ts.codcomp||'%'
                             and rownum    <= 1 )))
            union all
            select distinct 'HRAL52U' module,tr.codempid,tr.codshift,tr.codleave,
                   tr.dtework,tr.timstrt,tr.timend,'Y' staappr,tr.codcomp,
                   tr.numlereq,tr.qtymin
              from tleavetr tr, tleavecd cd, temploy1 em
             where tr.codleave = cd.codleave(+)
               and tr.codempid = em.codempid
               and tr.codempid = nvl(b_index_codempid,tr.codempid)
               and tr.codcomp  like nvl(b_index_codcomp,tr.codcomp)
               and cd.typleave = nvl(b_index_typleave,cd.typleave)
               and tr.dtework  between b_index_dtestrt and b_index_dteend
               and (tr.numlereq is null or tr.numlereq not in (select numlereq from tlereqd))
               -- check secure
               and (tr.codempid = global_v_codempid
                or (tr.codempid <> global_v_codempid
                and em.numlvl between global_v_zminlvl and global_v_zwrklvl
                and 0 <> (select count(ts.codcomp)
                            from tusrcom ts
                           where ts.coduser = global_v_coduser
                             and tr.codcomp like ts.codcomp||'%'
                             and rownum    <= 1 )))
          )
          order by dtework,codempid,timstrt,timend;
  begin
    initial_value(json_str_input);
    check_index;
   if param_msg_error is null then
      -- create temp approve
      gen_leave_temp;
      -- query data
      obj_row := json_object_t();
      for r1 in c_data loop
      v_emp := v_emp + 1; --10/03/2021
        v_flgsecu := true;
        v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if v_flgsecu then
          v_secure := v_secure + 1;
              begin
                select substr(timstrtw,1,2)||':'||substr(timstrtw,3,2)||' - '||substr(timendw,1,2)||':'||substr(timendw,3,2)
                  into v_timinoutw
                  from tattence
                 where codempid = r1.codempid
                   and dtework  = v_dtework;
              exception when no_data_found then
                v_timinoutw := null;
              end;
              --
              v_row := v_row+1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('dtework',to_char(r1.dtework,'dd/mm/yyyy'));
              obj_data.put('codempid',r1.codempid);
              obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
              obj_data.put('codshift',r1.codshift);
              obj_data.put('desc_codshift',get_tshiftcd_name(r1.codshift,global_v_lang));
              obj_data.put('timinoutw',v_timinoutw);
              obj_data.put('codleave',r1.codleave);
              obj_data.put('desc_codleave',get_tleavecd_name(r1.codleave,global_v_lang));
              obj_data.put('timinoutl',substr(r1.timstrt,1,2)||':'||substr(r1.timstrt,3,2)||' - '||substr(r1.timend,1,2)||':'||substr(r1.timend,3,2));
              obj_data.put('qtyleave',format_hours(r1.qtymin));
              obj_data.put('staappr',r1.staappr);
              obj_data.put('status',get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));

              obj_row.put(to_char(v_row-1),obj_data);
          end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    if v_emp = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif v_secure = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
