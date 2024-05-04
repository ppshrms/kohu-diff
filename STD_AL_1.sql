--------------------------------------------------------
--  DDL for Package Body STD_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_AL" is
-- last update: 29/04/2024, 21/04/2021 15:00        --redmine895
  procedure gen_tattence(p_codempid   in temploy1.codempid%type,
											   p_codcalen   in temploy1.codcalen%type,
											   p_dtework    in date,
											   p_coduser    in varchar2,
											   p_flgupd     in varchar2,  -- 'G' - generate attendance,'N' - new employee, 'M' - movement, 'C' - change group
								         p_codcomp    in temploy1.codcomp%type,
								         p_typpayroll in temploy1.typpayroll%type,
								         p_flgatten   in temploy1.flgatten%type,
								         p_codempmt   in temploy1.codempmt%type,
								         p_rec        in out number) is


    v_codshift      tgrpplan.codshift%type;
    v_codshift2     tgrpplan.codshift%type;
	  v_typwork       tgrpplan.typwork%type;
	  v_dtestrtw      tgrpplan.dtework%type;
	  v_dteendw       tgrpplan.dtework%type;
	  v_timstrtw      tshiftcd.timstrtw%type;
	  v_timendw       tshiftcd.timendw%type;
	  v_dtein         tattence.dtein%type;
	  v_dteout        tattence.dteout%type;
	  v_flgfound      boolean;
	  v_log			      varchar2(20) := 'N';

  	cursor c_tattence is
      select dtein,dteout,typwork,rowid,timin,timout
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtework;

	begin
		begin
			select 'Y' into v_log
			  from tlogtime
			 where codempid = p_codempid
			   and dtework  = p_dtework
			   and rownum   = 1;
		exception when no_data_found then v_log := 'N';
		end;
--<<user14 13/02/2021 13:30
    begin
      select codshift into v_codshift2
        from twkchhr
       where codempid   = p_codempid
         and p_dtework between dtestrt and dteend
         and codshift  is not null;
    exception when no_data_found then
      v_codshift2     := null;
    end;
 --<<user14 13/02/2021 13:30

  	begin
    	select codshift,typwork into v_codshift,v_typwork
        from tgrpplan
       where codcomp  = get_tgrpwork_codcomp(p_codcomp,p_codcalen)
         and codcalen = p_codcalen
         and dtework  = p_dtework;

      v_codshift := nvl(v_codshift2,v_codshift) ;  --<<user14 13/02/2021 13:30
      begin
        select timstrtw,timendw into v_timstrtw,v_timendw
          from tshiftcd
         where codshift =  v_codshift;

        v_dtestrtw := p_dtework;
        if to_number(v_timstrtw) >= to_number(v_timendw) then
          v_dteendw := p_dtework + 1;
        else
         v_dteendw := p_dtework;
        end if;
      exception when no_data_found then
       null;-- return;
      -- v_timstrtw := null; v_timendw := null;
      -- v_dtestrtw := null; v_dteendw := null;
      end;

      v_flgfound := false;
      for r_tattence in c_tattence loop
        if r_tattence.typwork = 'L' then
          v_typwork := 'L' ;
        end if;
        v_flgfound := true;
        if v_log = 'Y' then --user36 ST11 29/04/2024 (KOHU #1908) || if v_log = 'Y' or r_tattence.timin is not null or r_tattence.timout is not null then
          if p_flgupd = 'C' then
            null;
          --user14 elsif p_flgupd in ('G','M') then
          elsif p_flgupd in ('G','M','N') then
            update tattence
               set codcomp    = p_codcomp,
                   typpayroll = p_typpayroll,
                   flgatten   = p_flgatten,
                   codempmt   = p_codempmt,
                   coduser    = p_coduser
            where rowid = r_tattence.rowid;
            p_rec := p_rec + 1;
          end if;
        else--v_log = 'N'
          if p_flgupd = 'C' then
            update tattence
               set typwork  = v_typwork,
                   codshift = v_codshift,
                   codcalen = p_codcalen,
                   dtestrtw = v_dtestrtw,
                   timstrtw = v_timstrtw,
                   dteendw  = v_dteendw,
                   timendw  = v_timendw,
                   coduser  = p_coduser
             where rowid    = r_tattence.rowid;
             p_rec := p_rec + 1;
          elsif p_flgupd in ('G','M','N') then--user14 elsif p_flgupd in ('G','M') then
            update tattence
               set codcomp    = p_codcomp,
                   typpayroll = p_typpayroll,
                   flgatten   = p_flgatten,
                   codempmt   = p_codempmt,
                   typwork    = v_typwork,
                   codshift   = v_codshift,
                   codcalen   = p_codcalen,
                   dtestrtw   = v_dtestrtw,
                   timstrtw   = v_timstrtw,
                   dteendw    = v_dteendw,
                   timendw    = v_timendw,
                   coduser    = p_coduser
            where rowid = r_tattence.rowid;
            p_rec := p_rec + 1;
          end if;
        end if;--if v_log = 'N' then
      end loop; -- for r_tattence

      if not v_flgfound then
          insert into tattence(codempid,dtework,typwork,codshift,dtestrtw,timstrtw,dteendw,timendw,
                              codcomp,typpayroll,codcalen,flgatten,codempmt,flgcalwk,codcreate,coduser)
                       values(p_codempid,p_dtework,v_typwork,v_codshift,v_dtestrtw,v_timstrtw,v_dteendw,v_timendw,
                              p_codcomp,p_typpayroll,p_codcalen,p_flgatten,p_codempmt,'N',p_coduser,p_coduser);
          p_rec := p_rec + 1;
      end if;
    exception when no_data_found then null;
    end; -- select tgrpplan
  end;
  --
  procedure cal_tattence(p_codempid    in varchar2,
                         p_stdate      in date,
                         p_endate      in date,
                         p_coduser     in varchar2,
                         p_rec         in out number) is
    v_qtylate     number;
    v_qtyearly    number;
    v_qtyabsent   number;

    cursor c_tattence is
      select codempid,dtework,rowid,codshift,typwork,
             dtein,timin,dteout,timout
        from tattence
       where codempid = p_codempid
         and dtework between p_stdate and p_endate
    order by codempid,dtework;
	begin
		for r_tattence in c_tattence loop
      cal_tlateabs(r_tattence.codempid,r_tattence.dtework,r_tattence.typwork,r_tattence.codshift,
                   r_tattence.dtein,r_tattence.timin,r_tattence.dteout,r_tattence.timout,
                   p_coduser,'Y',v_qtylate,v_qtyearly,v_qtyabsent,p_rec);
		end loop; -- for r_tattence
	end;
  --
  procedure cal_tlateabs(p_codempid 	 in varchar2,
                         p_dtework     in date,
                         p_typwork     in varchar2,
                         p_codshift    in varchar2,
                         p_dtein       in date,
                         p_timin       in varchar2,
                         p_dteout      in date,
                         p_timout      in varchar2,
                         p_coduser     in varchar2,
                         p_flgcall     in varchar2 default 'N',
                         p_qtylate 	   out number,
                         p_qtyearly    out number,
                         p_qtyabsent   out number,
                         p_rec    	   in out number,
                         p_ignore_flginput in varchar2 default 'N') is --user46 fix #7198 29/11/2021
		v_codpunsh  	    varchar2(10);
		v_exist           boolean;
		v_qtydaywk        tshiftcd.qtydaywk%type;
		v_codcompy        tcompny.codcompy%type;
		v_codcalen        tattence.codcalen%type;
		v_typwork         tattence.typwork%type;
		v_stampin         date;
		v_stampout        date;
		v_strtw           date;
		v_endw            date;
		v_dtestrtw        tattence.dtestrtw%type;
		v_dteendw         tattence.dteendw%type;
		v_timstrtw        tshiftcd.timstrtw%type;
		v_timendw         tshiftcd.timendw%type;
		v_strtb           date;
		v_endb            date;
		v_dtestrtb        tattence.dtework%type;
		v_dteendb         tattence.dtework%type;
		v_timstrtb        tshiftcd.timstrtw%type;
		v_timendb         tshiftcd.timendw%type;
		v_strtle          date;
		v_endle           date;
		v_qtymin    	    tleavetr.qtymin%type;
		v_qtylate   	    tlateabs.qtylate%type;
		v_qtyearly  	    tlateabs.qtyearly%type;
		v_qtyabsent 	    tlateabs.qtyabsent%type;
		v_qtytlate  	    tlateabs.qtytlate%type;
		v_qtytearly 	    tlateabs.qtytearly%type;
		v_qtytabs   	    tlateabs.qtytabs%type;
		v_minbrk    	    number;
		v_minlv	    	    number;
		t_minlv	    	    number;
		v_minlbk    	    number;
		v_minute          varchar2(2);
		v_hour            varchar2(2);
		v_date            date;
		v_qtytimle  	    number(2);
		v_flginput  	    tlateabs.flginput%type;
    v_qtylate_input   tlateabs.qtylate%type;
		v_qtyearly_input  tlateabs.qtyearly%type;
		v_qtyabs_input    tlateabs.qtyabsent%type;
		v_typabs          tcontal3.typabs%type;
		v_min             number;
		v_timoutst        twkchhr.timoutst%type;
		v_timouten        twkchhr.timouten%type;
		v_strto           date;
		v_endo            date;
		v_qtynostam 	    tlateabs.qtynostam%type;
		v_qtydayle  	    number;

        v_chktr           varchar2(1);
        v_timin_tr       tshiftcd.timstrtw%type;
        v_timin2_tr    tshiftcd.timstrtw%type;

        rt_tcontral       tcontral%rowtype;

		cursor c_tattence is
		  select rowid,codcomp,codcalen,flgatten,codshift,dtestrtw,timstrtw,dteendw,timendw,qtyhwork,codchng,qtynostam
		    from tattence
		   where codempid = p_codempid
		     and dtework  = p_dtework
		order by codempid,dtework;

		cursor c_tleavetr is
		  select rowid,timstrt,timend,qtymin,qtyday
		    from tleavetr
		   where codempid = p_codempid
		     and dtework  = p_dtework
		order by codempid,dtework,timstrt;

		cursor c_tlateabs is
		  select rowid,flgcalabs
		    from tlateabs
		   where codempid = p_codempid
		     and dtework  = p_dtework
    order by codempid,dtework;

		cursor c_tcontal3 is
		  select qtymin
 		    from tcontal3
		   where codcompy = rt_tcontral.codcompy
		     and dteeffec = rt_tcontral.dteeffec
		     and typabs   = v_typabs
		     and v_min between qtyminst and qtyminen;

		cursor c_tcontal4 is
		  select qtymin,typecal
		    from tcontal4
		   where codcompy = rt_tcontral.codcompy
		     and dteeffec = rt_tcontral.dteeffec
		     and typabs   = v_typabs
		     and v_min between qtyminst and qtyminen;

	begin
		for r_tattence in c_tattence loop
      <<main_loop>> loop
        v_qtylate  := 0;    v_qtyearly  := 0;   v_qtyabsent := 0;
        v_qtytlate := 0;    v_qtytearly := 0;   v_qtytabs := 0;
        v_qtymin   := 0;    v_qtynostam := 0;
        v_dtestrtw := r_tattence.dtestrtw;
        v_timstrtw := r_tattence.timstrtw;
        v_dteendw  := r_tattence.dteendw;
        v_timendw  := r_tattence.timendw;
        begin
          select *
            into rt_tcontral
            from tcontral
           where codcompy = hcm_util.get_codcomp_level(r_tattence.codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontral
                              where codcompy = hcm_util.get_codcomp_level(r_tattence.codcomp,1)
                                and dteeffec <= sysdate);
        exception when no_data_found then null;
        end;
        begin
          v_stampin  := to_date(to_char(p_dtein,'dd/mm/yyyy')||p_timin,'dd/mm/yyyyhh24mi');
          v_stampout := to_date(to_char(p_dteout,'dd/mm/yyyy')||p_timout,'dd/mm/yyyyhh24mi');
        exception when others then
          v_stampin := null; v_stampout := null;
        end;
/*#7198
        begin
          select timstrtb,timendb,qtydaywk
            into v_timstrtb,v_timendb,v_qtydaywk
            from tshiftcd
           where codshift = p_codshift;
        exception when no_data_found then
          exit main_loop;
        end;
--#7198*/
        begin
          select timstrtw,timstrtb,timendb,timendw,qtydaywk
            into v_timstrtw,v_timstrtb,v_timendb,v_timendw,v_qtydaywk
            from tshiftcd
           where codshift = p_codshift;
        exception when no_data_found then
          exit main_loop;
        end;
--#7198
--<<user46 NXP-HR2101 fix #147 16/11/2021
        if v_timstrtw > v_timendw then
          v_dtestrtw    := p_dtework;
          v_dteendw     := p_dtework + 1;
        else
          v_dtestrtw    := p_dtework;
          v_dteendw     := p_dtework;
        end if;
-->>user46 NXP-HR2101 fix #147 16/11/2021
        v_strtw := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||v_timstrtw,'dd/mm/yyyyhh24mi');
        v_endw  := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');

--#7198
/*        if v_timstrtw > v_timendw then --<< comment by user46 29/11/2021
          v_endw := v_endw + 1;
        end if;*/ -->>
--#7198

        if v_timstrtb is not null and v_timendb is not null then
          if v_timstrtb < v_timstrtw then
            v_dtestrtb := v_dtestrtw + 1;
          else
            v_dtestrtb := v_dtestrtw;
          end if;
          if v_timstrtb > v_timendb then
            v_dteendb := v_dtestrtb + 1;
          else
            v_dteendb := v_dtestrtb;
          end if;
          v_strtb := to_date(to_char(v_dtestrtb,'dd/mm/yyyy')||v_timstrtb,'dd/mm/yyyyhh24mi');
          v_endb  := to_date(to_char(v_dteendb,'dd/mm/yyyy')||v_timendb,'dd/mm/yyyyhh24mi');
        else
          v_strtb := null; v_dtestrtb := null; v_timstrtb := null;
          v_endb  := null; v_dteendb  := null; v_timendb  := null;
        end if;
        if p_timin is null and p_timout is null then
          begin
            select timoutst,timouten
              into v_timoutst,v_timouten
              from twkchhr
             where codempid  = p_codempid
               and p_dtework between dtestrt and dteend
               and rownum    = 1;

            if v_timoutst is not null and v_timouten is not null then
              v_strto := to_date(to_char(p_dtework,'dd/mm/yyyy')||v_timoutst,'dd/mm/yyyyhh24mi');
              if v_timoutst > v_timouten then
                v_endo := to_date(to_char(p_dtework + 1,'dd/mm/yyyy')||v_timouten,'dd/mm/yyyyhh24mi');
              else
                v_endo := to_date(to_char(p_dtework,'dd/mm/yyyy')||v_timouten,'dd/mm/yyyyhh24mi');
              end if;
              v_stampin  := v_strto;
              v_stampout := v_endo;
              /*v_stampin  := least(nvl(v_stampin,v_strto),v_strto);
              v_stampout := greatest(nvl(v_stampout,v_endo),v_endo);
            else
              v_stampin  := v_strtw;
              v_stampout := v_endw;*/
              --
              if p_flgcall = 'Y' then
                update tattence
                   set dtein   = to_date(to_char(v_stampin,'dd/mm/yyyy'),'dd/mm/yyyy'),
                       timin   = to_char(v_stampin,'hh24mi'),
                       dteout  = to_date(to_char(v_stampout,'dd/mm/yyyy'),'dd/mm/yyyy'),
                       timout  = to_char(v_stampout,'hh24mi'),
                       coduser = p_coduser,
                       dteupd  = sysdate
                 where codempid = p_codempid
                   and dtework  = p_dtework;
                --
                insert into tlogtime(codempid,dtework,dteupd,
                                     codshift,codcomp,codcreate,coduser,
                                     dteinold,timinold,dteoutold,timoutold,
                                     dteinnew,timinnew,dteoutnew,timoutnew)
                              values(p_codempid,p_dtework,sysdate,
                                     p_codshift,r_tattence.codcomp,p_coduser,p_coduser,
                                     null,null,null,null,
                                     to_date(to_char(v_stampin,'dd/mm/yyyy'),'dd/mm/yyyy'),to_char(v_stampin,'hh24mi'),to_date(to_char(v_stampout,'dd/mm/yyyy'),'dd/mm/yyyy'),to_char(v_stampout,'hh24mi'));
              end if; -- p_flgcall = 'Y'
            end if; -- v_timoutst is not null and v_timouten is not null
          exception when no_data_found then null;
          end;
        end if; -- p_timin is null and p_timout is null
        -- SUM LEAVE HOUR
        v_qtymin := 0; v_qtytimle := 0; v_qtydayle := 0;
        for r_tleavetr in c_tleavetr loop
          v_qtydayle := v_qtydayle + r_tleavetr.qtyday;
          v_qtymin   := v_qtymin + r_tleavetr.qtymin;
          v_qtytimle := v_qtytimle + 1;
          if r_tleavetr.timstrt < r_tattence.timstrtw then
            v_strtle := to_date(to_char(r_tattence.dtestrtw + 1,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
          else
            v_strtle := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
          end if;
          if r_tleavetr.timstrt < r_tleavetr.timend then
            v_endle  := to_date(to_char(v_strtle,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
          else
            v_endle  := to_date(to_char(v_strtle + 1,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
          end if;
        end loop;
        --
        v_codcompy  := hcm_util.get_codcomp_level(r_tattence.codcomp,1);
        v_codcalen  := r_tattence.codcalen;
        v_typwork   := p_typwork;
        if v_qtymin >= v_qtydaywk then
          v_typwork := 'L';
        elsif p_typwork = 'L' then
          begin
            select codcalen,typwork
              into v_codcalen,v_typwork
              from tgrpplan
             where codcomp  = get_tgrpwork_codcomp(r_tattence.codcomp,v_codcalen)
               and codcalen = v_codcalen
               and dtework  = p_dtework;
          exception when no_data_found then
            v_typwork := p_typwork;
          end;
        end if;
        --
        begin
          select flginput,qtyabsent,
                 qtylate,qtyearly
            into v_flginput,v_qtyabs_input,
                 v_qtylate_input,v_qtyearly_input --user46 fix #7198 29/11/2021
            from tlateabs
           where codempid = p_codempid
             and dtework  = p_dtework;
        exception when no_data_found then
          v_flginput := 'N'; v_qtyabs_input := 0;
          v_qtylate_input     := 0;
          v_qtyearly_input    := 0;
        end;

-->> user4 + user 22 || 21/02/2024
--        if nvl(v_flginput,'N') = 'Y' and nvl(p_ignore_flginput,'N') = 'N' then --user46 fix #7198 29/11/2021
--          v_qtylate   := v_qtylate_input;
--          v_qtyearly  := v_qtyearly_input;
--          v_qtyabsent := v_qtyabs_input;
--        else
--<< user4 + user 22 || 21/02/2024
          if v_strtw <= sysdate then
            if p_flgcall = 'Y' then
              delete tlateabs
               where codempid = p_codempid
                 and dtework  = p_dtework;
            end if;
            --
            begin
              select codpunsh into v_codpunsh
                from ttpunsh
               where codempid  = p_codempid
                 and staupd    in ('C','U')
                 and p_dtework between dtestart and dteend
                 and dteeffec <= trunc(sysdate)
                 and typpun    = '5'
                 and rownum    = 1;
            exception when others then
                v_codpunsh := null;
            end;

--<<redmine895
           v_chktr := 'N';
            if v_codpunsh is null then
                    begin
                      select 'Y',timin,timin2
                       into v_chktr,v_timin_tr, v_timin2_tr
                        from tpotentpd
                       where codempid  = p_codempid
                        and dtetrain   = p_dtework
                        --and nvl(qtytrabs,0)  <> 0
                         and rownum    = 1;
                    exception when others then
                        v_chktr := 'N';
                        v_timin_tr  := null;
                        v_timin2_tr  := null;
                    end;
                    if  v_chktr = 'Y' then
                              if  v_timin_tr is not null then --if  v_timin_tr is not null and v_timin2_tr is null then
                                  v_stampin    := v_dtestrtw;  --least(v_dtestrtw ,  nvl(v_stampin,v_dtestrtw) );
                                  --v_stampout  := v_strtb;      --greatest( v_strtb , nvl(v_stampout,v_strtb) );
                              end if;

                            if  v_timin2_tr is not null then   --if  v_timin_tr is null and v_timin2_tr is not null then
                                  --v_stampin      :=  least(v_endb , nvl(v_stampin,v_endb) );
                                  v_stampout  := v_endw;   --greatest( v_stampout , nvl(v_endw,v_stampout) );
                            end if;

                            if  v_timin_tr is null and  v_timin2_tr is  null then
                                 v_stampin     :=  null;
                                 v_stampout  :=  null;
                            end if;
                    end if;  --if  v_chktr = 'Y' then
            end if;
-->>redmine895

            if  r_tattence.flgatten in ('Y','O') and v_codpunsh is null and v_qtydayle < 1 then
              if v_typwork = 'W' then
                v_qtynostam := r_tattence.qtynostam;
                if r_tattence.flgatten = 'Y' then
                  if p_dtework <> to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') or sysdate >= v_endw then
                    if v_stampin is null and v_stampout is null then
                      v_qtyabsent := v_qtydaywk - v_qtymin;
                    elsif v_stampin is null or v_stampout is null then
                      if nvl(rt_tcontral.flgrdabs,'H') = 'H' then
                        v_qtyabsent := v_qtydaywk / 2;
                      else
                        v_qtyabsent := v_qtydaywk - v_qtymin;
                      end if;
                    end if;
                  else
                    if v_stampin is null then
                      v_qtyabsent := v_qtydaywk / 2;
                    end if;
                  end if;
                  if v_qtyabsent > 0 then
                    v_qtytabs := 1;
                    goto next_loop;
                  end if;
                elsif r_tattence.flgatten = 'O' then
                  if p_dtework <> to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') or sysdate >= v_endw then
                    if v_stampin is null and v_stampout is null then
                      v_qtyabsent := v_qtydaywk - v_qtymin;
                    end if;
                  end if;
                  goto next_loop;
                end if; -- r_tattence.flgatten = 'Y'
                -- Late----------------------------------------------------------
                if v_stampin is not null and v_stampin > v_strtw then
                  v_qtylate := 0; v_minbrk := 0; v_minlv := 0; v_minlbk := 0;
                  v_qtylate := Cal_Min_Dup(v_strtw,v_stampin,v_strtw,v_endw);
                  v_minbrk  := Cal_Min_Dup(v_strtw,v_stampin,v_strtb,v_endb);
                  v_qtylate := v_qtylate - v_minbrk;

                  for r_tleavetr in c_tleavetr loop
                    if r_tleavetr.timstrt < r_tattence.timstrtw then
                      v_strtle := to_date(to_char(r_tattence.dtestrtw + 1,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    else
                      v_strtle := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    end if;
                    if r_tleavetr.timstrt < r_tleavetr.timend then
                      v_endle  := to_date(to_char(v_strtle,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    else
                      v_endle  := to_date(to_char(v_strtle + 1,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    end if;
                    t_minlv  := Cal_Min_Dup(v_strtw,v_stampin,v_strtle,v_endle);
                    v_minlv  := v_minlv  + t_minlv;
                    if t_minlv > 0 and v_minbrk > 0 then
                      v_minlbk := v_minlbk + least(Cal_Min_Dup(v_strtb,v_endb,v_strtle,v_endle),v_minbrk);
                      v_minlv  := v_minlv - v_minlbk;
                    end if;
                  end loop; -- c_tleavetr loop

                  v_qtylate := v_qtylate - v_minlv;
                  if v_qtylate > v_qtydaywk then
                    v_qtylate := v_qtydaywk;
                  elsif v_qtylate < 0 then
                    v_qtylate := 0;
                  end if;

                  -- Round up minute(Late)
                  v_typabs := '1';
                  v_min := v_qtylate;
                  for r_tcontal3 in c_tcontal3 loop
                    v_min := r_tcontal3.qtymin;
                  end loop;

                  v_qtylate := v_min;
                  for r_tcontal4 in c_tcontal4 loop
                    if r_tcontal4.typecal = '1' then
                      v_qtyabsent := v_qtyabsent + r_tcontal4.qtymin;
                    else
                      v_qtyabsent := v_qtyabsent + v_qtylate;--user22 : 18/02/2020 || v_qtyabsent := v_qtyabsent + greatest(r_tcontal4.qtymin,v_qtylate);
                    end if;
                    v_qtylate := 0;
                    v_qtytabs := 1;
                  end loop;

                  if v_qtylate > 0 then
                    v_qtytlate := 1;
                  end if;
                end if; -- Late

                -- Early----------------------------------------------------------
                if v_stampout is not null and v_stampout < v_endw then
                  v_qtyearly := 0; v_minbrk := 0; v_minlv := 0; v_minlbk := 0;
                  v_qtyearly := Cal_Min_Dup(v_stampout,v_endw,v_strtw,v_endw);
                  v_minbrk   := Cal_Min_Dup(v_stampout,v_endw,v_strtb,v_endb);
                  v_qtyearly := v_qtyearly - v_minbrk;
                  for r_tleavetr in c_tleavetr loop
                    if r_tleavetr.timstrt < r_tattence.timstrtw then
                      v_strtle := to_date(to_char(r_tattence.dtestrtw + 1,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    else
                      v_strtle := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    end if;
                    if r_tleavetr.timstrt < r_tleavetr.timend then
                      v_endle  := to_date(to_char(v_strtle,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    else
                      v_endle  := to_date(to_char(v_strtle + 1,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    end if;
                    t_minlv  := Cal_Min_Dup(v_stampout,v_endw,v_strtle,v_endle);
                    v_minlv  := v_minlv + t_minlv;
                    if t_minlv > 0 and v_minbrk > 0 then--??????????????????????????????? ???????????????????????????????????????????????????????????????(v_minbrk)
                      v_minlbk := v_minlbk + least(Cal_Min_Dup(v_strtb,v_endb,v_strtle,v_endle),v_minbrk);
                      v_minlv  := v_minlv - v_minlbk;
                    end if;
                  end loop; -- c_tleavetr loop
                  v_qtyearly := v_qtyearly - v_minlv;
                  if v_qtyearly > v_qtydaywk then
                    v_qtyearly := v_qtydaywk;
                  elsif v_qtyearly < 0 then
                    v_qtyearly := 0;
                  end if;

                  -- Round up minute (Early)
                  v_typabs    := '2';
                  v_min       := v_qtyearly;
                  for r_tcontal3 in c_tcontal3 loop
                    v_min   := r_tcontal3.qtymin;
                  end loop;
                  v_qtyearly  := v_min;

                  for r_tcontal4 in c_tcontal4 loop
                    if r_tcontal4.typecal = '1' then
                      v_qtyabsent := v_qtyabsent + r_tcontal4.qtymin;
                    else
                      v_qtyabsent := v_qtyabsent + v_qtyearly;
                    end if;
                    v_qtyearly  := 0;
                    v_qtytabs   := 1;
                  end loop;

                  if v_qtyearly > 0 then
                      v_qtytearly := 1;
                  end if;
                end if; -- Early
              end if; -- v_typwork = 'W'
              --
              <<next_loop>>
              -- Round up minute (Absent)
              v_typabs    := '3';
              v_min       := v_qtyabsent;

              for r_tcontal3 in c_tcontal3 loop
                v_min := r_tcontal3.qtymin;
              end loop;

              v_qtyabsent := v_min;
              --
              if v_qtylate > v_qtydaywk then
                v_qtylate := v_qtydaywk;
              end if;
              if v_qtyearly > v_qtydaywk then
                v_qtyearly := v_qtydaywk;
              end if;
              if v_qtyabsent > v_qtydaywk then
                v_qtyabsent := v_qtydaywk;
              end if;

--HR-KOHU-2301
            if p_codshift = 'V2' and v_qtylate > 0 then
                v_qtyabsent := v_qtylate + nvl(v_qtyabsent,0);
                v_qtylate   := 0;
            end if;
            
            
            if p_codshift = 'O5' and v_qtylate > 6 then
                v_qtyabsent := v_qtylate + nvl(v_qtyabsent,0);
                v_qtylate   := 0;
            end if;
--HR-KOHU-2301

              -- check flag proc call
              if p_flgcall = 'Y' then
                if (v_qtylate > 0 or v_qtyearly > 0 or v_qtyabsent > 0 or v_qtynostam > 0) then       
                  begin
                    insert into tlateabs(codempid,dtework,
                                         qtylate,qtyearly,qtyabsent,
                                         daylate,dayearly,dayabsent,
                                         qtytlate,qtytearly,qtytabs,qtynostam,
                                         codshift,codcomp,flgatten,flginput,flgcallate,flgcalear,flgcalabs,codcreate,dtecreate,coduser,dteupd)
                                  values(p_codempid,p_dtework,
                                         v_qtylate,v_qtyearly,v_qtyabsent,
                                         (v_qtylate / v_qtydaywk),(v_qtyearly / v_qtydaywk),(v_qtyabsent / v_qtydaywk),
                                         v_qtytlate,v_qtytearly,v_qtytabs,v_qtynostam,
                                         p_codshift,r_tattence.codcomp,r_tattence.flgatten,'N','N','N','N',p_coduser,sysdate,p_coduser,sysdate);
                  exception when dup_val_on_index then
                    update tlateabs
                       set qtylate   = v_qtylate,
                           qtyearly  = v_qtyearly,
                           qtyabsent = v_qtyabsent,
                           daylate   = (v_qtylate / v_qtydaywk),
                           dayearly  = (v_qtyearly / v_qtydaywk),
                           dayabsent = (v_qtyabsent / v_qtydaywk),
                           qtytlate  = v_qtytlate,
                           qtytearly = v_qtytearly,
                           qtytabs   = v_qtytabs,
                           qtynostam = v_qtynostam,
                           codshift  = p_codshift,
                           codcomp   = r_tattence.codcomp,
                           flgatten  = r_tattence.flgatten,
                           coduser   = p_coduser,
                           dteupd    = sysdate
                     where codempid  = p_codempid
                       and dtework   = p_dtework;
                  end;
                  p_rec := nvl(p_rec,0) + 1;
                /*else
                  delete tlateabs
                   where codempid = p_codempid
                     and dtework  = p_dtework;*/
                end if;
              end if; -- p_flgcall = 'Y'
            end if; --r_tattence.flgatten in ('Y','O') and v_codpunsh is null and v_qtydayle < 1
          end if; -- v_strtw <= sysdate
--        end if; --nvl(v_flginput,'N') = 'Y' -- user4 + user 22 || 21/02/2024

        -- check update tattence
        if p_flgcall = 'Y' then
          if v_typwork in ('H','S','T') or v_codpunsh is not null then
            v_qtydaywk := 0;
          elsif v_typwork = 'W' then
            v_qtydaywk := v_qtydaywk - v_qtyabsent;
          end if;
          --
          update tattence
             set qtyhwork = v_qtydaywk,
                 typwork  = v_typwork,
                 coduser  = p_coduser
           where rowid = r_tattence.rowid;
        end if; -- p_flgcall = 'Y'
        -- return value
        p_qtylate 	  := nvl(v_qtylate,0);
        p_qtyearly    := nvl(v_qtyearly,0);
        p_qtyabsent   := nvl(v_qtyabsent,0);

        exit main_loop;
      end loop; -- main_loop
    end loop; -- c_tattence loop
	end;
  --
  procedure entitlement(p_codempid in varchar2,
                        p_codleave in varchar2,
                        p_dtestrle in date,
                        p_zyear    in number,   --13/02/2021 drop
                        p_qtyleave out number,
                        p_qtypriyr out number,
                        p_dteeffec out date,
                        p_coduser  in varchar2 default null) is -- user22 : 08/12/2021 : ST11 || p_coduser not null for Request Leave (AL, ESS, MSS)

    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_codcomp			temploy1.codcomp%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_dteeffex    temploy1.dteeffex%type;
    v_staemp      temploy1.staemp%type;

    v_qtywkday    temploy1.qtywkday%type;
    v_flgfound    boolean;
    v_sum         number;
    v_qtydlepay   tleavety.qtydlepay%type;
    v_flgwkcal    tleavety.flgwkcal%type;
    v_qtydayle    tleavsum.qtydayle%type;
    v_qtylepay    tleavsum.qtylepay%type;
    v_qtyavgwk    tcontral.qtyavgwk%type;
    v_yrecycle    number;
    v_dtecycst    date;
    v_dtecycen    date;
    v_numrec      number;
    v_qtylimit    number;
    v_dteprien    date;
  begin
    p_qtyleave := null;
    p_qtypriyr := null;
    p_dteeffec := null;

    begin
      select typleave,staleave
        into v_typleave,v_staleave
        from tleavecd
       where codleave = p_codleave;
    exception when no_data_found then return;
    end;

    begin
      select codcomp,dteempmt,dteeffex,staemp
        into v_codcomp,v_dteempmt,v_dteeffex,v_staemp
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    if v_staemp = '9' and v_dteeffex <= p_dtestrle then
      return;
    end if;

    cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,p_codleave,p_dtestrle,v_yrecycle,v_dtecycst,v_dtecycen);
    if v_dteeffex <= v_dtecycst then
      return;
    end if;
    if v_staleave <> 'V' then
      v_flgfound := hral56b_batch.check_condition_leave(p_codempid,p_codleave,p_dtestrle,'1');
      if not v_flgfound then
        return;
      end if;
    end if;
    --
    if v_staleave = 'V' then
      begin
        select dteeffeclv,nvl(qtylepay,0)
          into p_dteeffec,v_qtylepay
          from tleavsum
         where codempid = p_codempid
           and dteyear  = v_yrecycle
           and codleave = p_codleave;
      exception when no_data_found then
--<< user22 : 08/12/2021 : ST11 ||
        if p_coduser is not null then
          hral82b_batch.gen_vacation(p_codempid,null,p_dtestrle,p_coduser,v_numrec);
        end if;
-->> user22 : 08/12/2021 : ST11 ||
        v_qtylepay := 0;
      end;

      begin
        select nvl(qtypriyr,0),nvl(qtyvacat,0)
          into p_qtypriyr,p_qtyleave
          from tleavsum2
         where codempid = p_codempid
           and p_dtestrle  between dtecycst and dtecycen
           and codleave = p_codleave
           and dteyear  = v_yrecycle;
      exception when no_data_found then
        p_qtypriyr := 0;
        p_qtyleave := 0;
      end;
--<< user22 : 16/03/2022 : ST11 ||
      if p_qtypriyr = 0 then
        begin
          select nvl(qtypriyr,0),dtecycen
            into v_qtylimit,v_dteprien
            from tleavsum2
           where codempid = p_codempid
             and codleave = p_codleave
             and dteyear  = v_yrecycle
             and monthno  = (select max(b.monthno)
                               from tleavsum2 b
                              where b.codempid = tleavsum2.codempid
                                and b.codleave = tleavsum2.codleave
                                and b.dteyear  = tleavsum2.dteyear
                                and qtypriyr   > 0);
        exception when no_data_found then v_qtylimit := 0;
        end;
        if v_qtylimit > 0 then
          v_qtydayle := 0;
          begin
            select nvl(sum(qtyday),0) into v_qtydayle
              from tleavetr
             where codempid  = p_codempid
               and dtework   between v_dtecycst and v_dteprien
               and codleave  = p_codleave;
          end;
          p_qtypriyr := least(v_qtylimit,v_qtydayle);
          p_qtyleave := nvl(p_qtyleave,0) + nvl(p_qtypriyr,0);
        end if;
      end if; -- if p_qtypriyr = 0 then
-->> user22 : 16/03/2022 : ST11 ||


      p_qtyleave := greatest(p_qtyleave - v_qtylepay,0);
    elsif v_staleave = 'C' then
      begin
        select qtyavgwk
          into v_qtyavgwk
          from tcontral
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontral
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate)
           and rownum <= 1;
      exception when no_data_found then null;
      end;

      begin
        select nvl(sum(qtyleave),0) into p_qtyleave
          from tovrtime
         where codempid = p_codempid
           and dtework  between v_dtecycst and v_dtecycen;
       exception when no_data_found then null;
      end;
      p_qtyleave := p_qtyleave / v_qtyavgwk;
      begin
        select nvl(qtydleot,0) - nvl(qtydayle,0) into p_qtypriyr
          from tleavsum
         where codempid = p_codempid
           and dteyear  = (v_yrecycle - 1)
           and codleave = p_codleave;
      exception when no_data_found then p_qtypriyr := 0;
      end;
      if p_qtypriyr < 0 then
        p_qtypriyr := 0;
      end if;
      p_qtyleave := p_qtyleave + p_qtypriyr;

    elsif v_staleave in('F','O') then
      begin
        select qtydlepay,flgwkcal
          into v_qtydlepay,v_flgwkcal
          from tleavety
         where typleave = v_typleave;
      exception when no_data_found then return;
      end;

      v_sum := p_dtestrle - v_dteempmt;
      if v_flgwkcal = 'Y' and v_sum < 365 then
        v_qtydlepay := (v_qtydlepay * v_sum) / 365;
      end if;
      p_qtyleave := v_qtydlepay;
    end if;
 	end;
  --
  procedure cycle_leave ( p_codcompy in tcompny.codcompy%type,
													p_codempid in varchar2,
													p_codleave in varchar2,
													p_dtestrle in date,
													p_year     out number,
													p_dtecycst out date,
													p_dtecycen out date) is

      v_daylevst    tleavety.daylevst%type;
      v_mthlevst  	tleavety.mthlevst%type;
      v_staleave		tleavecd.staleave%type;
      v_typleave		tleavecd.typleave%type;
      v_flgmthvac   varchar2(30);
      v_dteempmt    date;
      v_ddmm        varchar2(4);
  begin
    p_dtecycst := null;
    p_dtecycen := null;
    p_year     := null;
    if p_codcompy is not null and p_dtestrle is not null then
      begin
        select staleave,typleave
          into v_staleave,v_typleave
          from tleavecd
         where codleave = p_codleave;
      exception when no_data_found then null;
      end;
    	if v_staleave = 'V' then
	      begin
	        select daylevst,mthlevst,flgmthvac
	          into v_daylevst,v_mthlevst,v_flgmthvac
	          from tcontrlv
	         where codcompy = p_codcompy
	           and dteeffec = (select max(dteeffec)
	                             from tcontrlv
	                            where codcompy  = p_codcompy
	                              and dteeffec <= sysdate);
				exception when no_data_found then null;
				end;
    	else
	      begin
	        select daylevst,mthlevst
	          into v_daylevst,v_mthlevst
	          from tleavety
	         where typleave = v_typleave;
				exception when no_data_found then null;
				end;
    	end if;
    	--
	    if v_staleave = 'V' and v_flgmthvac = '1' then
	      begin
	        select dteempmt  into v_dteempmt
	          from temploy1
	         where codempid = p_codempid;
	      exception when no_data_found then null;
	      end;
	      v_ddmm := lpad(to_char(v_dteempmt,'dd'),2,'0')||lpad(to_char(v_dteempmt,'mm'),2,'0');
	    else
	    	v_ddmm := lpad(v_daylevst,2,'0')||lpad(to_char(v_mthlevst),2,'0');
	    end if;
	    --
	    begin
	    	p_dtecycst := to_date(v_ddmm||to_char(p_dtestrle,'yyyy'),'ddmmyyyy');
      exception when others then
        if v_ddmm = '2902' then
          p_dtecycst := to_date('2802'||to_char(p_dtestrle,'yyyy'),'ddmmyyyy');
        end if;
      end;
	    --
			if p_dtestrle < p_dtecycst then
				p_dtecycst := add_months(p_dtecycst,-12);
			end if;
			p_dtecycen := add_months(p_dtecycst,12) - 1;
			p_year := to_number(to_char(p_dtecycst,'yyyy'));
    end if;-- if p_codcompy is not null and p_dtestrle is not null then
  end;
  --
  procedure cycle_leave2( p_codcompy in tcompny.codcompy%type,
													p_codempid in varchar2,
													p_codleave in varchar2,
													p_year     in number,
													p_dtecycst out date,
													p_dtecycen out date) is

      v_dtestrle    date;
      v_yrecycle		number;
  begin
    p_dtecycst := null;
    p_dtecycen := null;
    --
    v_dtestrle := to_date('01/01/'||p_year,'dd/mm/yyyy');
    cycle_leave(p_codcompy,p_codempid,p_codleave,v_dtestrle,v_yrecycle,p_dtecycst,p_dtecycen);
		if p_year <> v_yrecycle then
			p_dtecycst := add_months(p_dtecycst,12);
			p_dtecycen := add_months(p_dtecycen,12);
		end if;
  end;
  --
  function gen_req(p_typgen  in varchar2,
						       p_table   in varchar2,
						       p_column  in varchar2,
						       p_gbyear  in varchar2,
                   p_codcomp in varchar2 default '',
                   p_typleave in varchar2 default '') return varchar2 is
	  v_year		varchar2(4);
	  v_mm      varchar2(2);
	  v_seq     number;
	  v_id      varchar2(20);
	  v_id2     varchar2(20);
	  v_stmt    varchar2(200);
  begin
		v_year := to_char(sysdate,'yyyy') -  p_gbyear ;
		v_mm   := lpad(to_char(sysdate,'mm'),2,'0');

		begin
		  select nvl(seqno,0) + 1 into v_seq
		    from tlastreq
		   where codcompy = p_codcomp
         and typgen   = p_typgen
		     and dteyear  = v_year
		     and dtemth   = v_mm;
		exception when others then v_seq := 1;
		end ;

		loop
          if p_typgen in ('LEAV','LEAT','LEAVTMP','TTOT','OTRQ') then
            if p_typleave is not null then
              v_id := p_typleave||p_codcomp||lpad(substr(v_year,3,2),2,'0')||v_mm||lpad(nvl(v_seq,1),3,'0');
            else
              v_id := p_codcomp||lpad(substr(v_year,3,2),2,'0')||v_mm||lpad(nvl(v_seq,1),7,'0');
            end if;
          else
            v_id := lpad(substr(v_year,3,2),2,'0')||'-'||v_mm||'-'||lpad(nvl(v_seq,1),6,'0');
          end if;
			v_stmt := 'select count(*) from '||p_table||' where '||p_column||' = '''||v_id||'''';

			if not execute_stmt(v_stmt) then
				return(v_id);
			end if;
			v_seq := nvl(v_seq,0) + 1;
		end loop;
  end;
	--
	procedure upd_req( p_typgen  in varchar2,
									   p_code    in varchar2,
									   p_codusr  in varchar2,
									   p_gbyear  in varchar2,
                     p_codcompy in varchar2 default '',
                     p_typleave in varchar2 default '') is

		v_year     varchar2(4);
		v_mm       varchar2(2);
    v_running  varchar2(20);
    v_prefix_numlereq varchar2(20);
  begin
		v_year := to_char(sysdate,'yyyy') - p_gbyear;
		v_mm   := lpad(to_char(sysdate,'mm'),2,'0');

    -- find length prefix of numlereq without running number
    v_prefix_numlereq := p_typleave||p_codcompy||lpad(substr(v_year,3,2),2,'0')||v_mm;
    -- find running number
    v_running := substr(p_code,length(v_prefix_numlereq)+1);

		begin
			insert into tlastreq(codcompy,typgen,dteyear,dtemth,seqno,dteupd,codcreate,coduser)
		                values(p_codcompy,p_typgen,v_year,v_mm,to_number(v_running),trunc(sysdate),p_codusr,p_codusr);
		exception when others then
			update tlastreq
			   set seqno    = to_number(v_running)
			 where codcompy = p_codcompy
         and typgen   = p_typgen
			   and dteyear  = v_year
			   and dtemth   = v_mm;
		end;
		commit;
	end;
	--

	procedure get_inc(p_codempid in varchar2,
									  p_amthour out number,
									  p_amtday  out number,
									  p_amtmth  out number) is

	c_codcurr		TCONTRPY.codcurr%type;
	v_ratechge	tratechg.ratechge%type;

	cursor c_emp is
		select a.codempid,a.codcomp,a.codempmt,b.codcurr,b.amtincom1,b.amtincom2,b.amtincom3,b.amtincom4,b.amtincom5,b.amtincom6,b.amtincom7,b.amtincom8,b.amtincom9,b.amtincom10
		  from temploy1 a , temploy3 b
		 where a.codempid = b.codempid
		   and a.codempid = p_codempid;
	begin
		for r1 in c_emp loop
			get_wage_income(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempmt,
											nvl(stddec(r1.amtincom1,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom2,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom3,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom4,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom5,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom6,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom7,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom8,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom9,r1.codempid,v_chken),0),
											nvl(stddec(r1.amtincom10,r1.codempid,v_chken),0),
											p_amthour,p_amtday,p_amtmth);
			--
			begin
				select codcurr into c_codcurr
				  from TCONTRPY
				 where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
				   and dteeffec = (select max(dteeffec)
				                     from TCONTRPY
				                    where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
				                      and dteeffec <= sysdate);
			exception when no_data_found then null;
			end;

			v_ratechge := get_exchange_rate(to_char(sysdate,'yyyy'),to_char(sysdate,'mm'),c_codcurr,r1.codcurr);
			p_amthour  := p_amthour * v_ratechge;
			p_amtday   := p_amtday  * v_ratechge;
			p_amtmth   := p_amtmth  * v_ratechge;
		end loop;
	end;
	--
	procedure get_movemt (p_codempid 		in varchar2,
											  p_dteeffec 		in out date,
 											  p_staupd1  		in varchar2,
											  p_staupd2  		in varchar2,
											  p_codcomp  		in out varchar2,
											  p_codpos	 		in out varchar2,
											  p_numlvl   		in out number,
 											  p_codjob   		in out varchar2,
											  p_codempmt 		in out varchar2,
											  p_typemp   		in out varchar2,
											  p_typpayroll  in out varchar2,
											  p_codbrlc  		in out varchar2,
											  p_codcalen 		in out varchar2,
											  p_jobgrade 		in out varchar2,
											  p_codgrpgl  	in out varchar2,
											  p_amthour     in out number,
											  p_amtday	    in out number,
											  p_amtmth	    in out number) is

	v_ocodempid   TEMPLOY1.CODEMPID%TYPE;
	v_flgcaladj		boolean;
	v_flgfound 		boolean;
  v_amtincom1		number := 0;
  v_amtincom2   number := 0;
  v_amtincom3   number := 0;
  v_amtincom4   number := 0;
  v_amtincom5   number := 0;
	v_amtincom6   number := 0;
	v_amtincom7   number := 0;
	v_amtincom8   number := 0;
	v_amtincom9   number := 0;
	v_amtincom10  number := 0;
	c_codcurr		TCONTRPY.codcurr%type;
	v_codcurr		TCONTRPY.codcurr%type;
	v_ratechge	tratechg.ratechge%type;

	cursor c1 is
		select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
		  from (select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
					    from ttmovemt
		   		   where codempid  = p_codempid
					     and dteeffec <= p_dteeffec
					     and codtrn   <> '0007'
					     and staupd   in(p_staupd1,p_staupd2)
		 union
		  		  select dteoccup dteeffec,0 numseq,codcomp,codpos,numlvl,null as codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
  				    from ttprobat
				     where codempid  = p_codempid
					     and dteoccup <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
		 union
		  		  select dtereemp dteeffec,0 numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
  				    from ttrehire
				     where(codempid  = p_codempid or codempid = v_ocodempid)
  					   and dtereemp <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2))
	order by dteeffec desc,numseq desc;

	cursor c11 is
		select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
		  from (select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
  					  from ttmovemt
		   		   where codempid  = p_codempid
					     and dteeffec <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
					     and flgadjin  = 'Y'
		 union
		  		  select codempid,dteoccup dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
				      from ttprobat
				     where codempid  = p_codempid
					     and dteoccup <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
					     and flgadjin  = 'Y'
		 union
		  		  select codempid,dtereemp dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
				      from ttrehire
				     where(codempid  = p_codempid or codempid = v_ocodempid)
					     and dtereemp <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2))
	order by dteeffec desc,numseq desc;

	cursor c2 is
		select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
		  from (select dteeffec,numseq,codcompt as codcomp,codposnow as codpos,numlvlt as numlvl,codjobt as codjob,codempmtt as codempmt,typempt as typemp,typpayrolt as typpayroll,codbrlct as codbrlc,codcalet as codcalen,jobgradet as jobgrade,codgrpglt as codgrpgl
					    from ttmovemt
		   		   where codempid = p_codempid
					     and dteeffec > p_dteeffec
					     and codtrn  <> '0007'
					     and staupd  in('C','U')
		 union
		  		  select dteoccup dteeffec,0 numseq,codcomp,codpos,numlvl,null as codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
				      from ttprobat
				     where codempid = p_codempid
					     and dteoccup > p_dteeffec
  					   and staupd  in('C','U'))
	order by dteeffec,numseq;

	cursor c21 is
		select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
					 amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
		  from (select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
								   amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
					    from ttmovemt
		   		   where codempid = p_codempid
					     and dteeffec > p_dteeffec
					     and staupd in('C','U')
					     and flgadjin  = 'Y'
		 union
		  		 select codempid,dteoccup dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
								  amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
				     from ttprobat
				    where codempid = p_codempid
					    and dteoccup > p_dteeffec
					    and staupd in('C','U')
					    and flgadjin  = 'Y')
		order by dteeffec,numseq;

	begin
	  begin
			select a.ocodempid,a.codcomp,a.codpos,a.numlvl,a.codjob,a.codempmt,a.typemp,a.typpayroll,a.codbrlc,a.codcalen,a.jobgrade,a.codgrpgl
			  into v_ocodempid,p_codcomp,p_codpos,p_numlvl,p_codjob,p_codempmt,p_typemp,p_typpayroll,p_codbrlc,p_codcalen,p_jobgrade,p_codgrpgl
 			  from temploy1 a
			 where a.codempid = p_codempid;
		exception when no_data_found then null;
		end;
		v_ocodempid := nvl(v_ocodempid,p_codempid);
		get_inc(p_codempid,p_amthour,p_amtday,p_amtmth);
		--
		for r1 in c1 loop
			p_codcomp  := r1.codcomp;
			p_codpos   := r1.codpos;
			p_numlvl   := r1.numlvl;
			p_codjob   := r1.codjob;
			p_codempmt := r1.codempmt;
			p_typemp   := r1.typemp;
			p_typpayroll := r1.typpayroll;
			p_codbrlc  := r1.codbrlc;
			p_codcalen := r1.codcalen;
			p_jobgrade := r1.jobgrade;
			p_codgrpgl := r1.codgrpgl;
			exit;
		end loop;

		v_flgcaladj := false;
		for r11 in c11 loop
		  v_flgcaladj  := true;
		  v_codcurr    := r11.codcurr;
			v_amtincom1  := nvl(stddec(r11.amtincom1,r11.codempid,v_chken),0);
			v_amtincom2  := nvl(stddec(r11.amtincom2,r11.codempid,v_chken),0);
			v_amtincom3  := nvl(stddec(r11.amtincom3,r11.codempid,v_chken),0);
			v_amtincom4  := nvl(stddec(r11.amtincom4,r11.codempid,v_chken),0);
			v_amtincom5  := nvl(stddec(r11.amtincom5,r11.codempid,v_chken),0);
			v_amtincom6  := nvl(stddec(r11.amtincom6,r11.codempid,v_chken),0);
			v_amtincom7  := nvl(stddec(r11.amtincom7,r11.codempid,v_chken),0);
			v_amtincom8  := nvl(stddec(r11.amtincom8,r11.codempid,v_chken),0);
			v_amtincom9  := nvl(stddec(r11.amtincom9,r11.codempid,v_chken),0);
			v_amtincom10 := nvl(stddec(r11.amtincom10,r11.codempid,v_chken),0);
			exit;
		end loop;
		--
		v_flgfound := false;
		for r2 in c2 loop
			v_flgfound := true;
			p_codcomp  := r2.codcomp;
			p_codpos   := r2.codpos;
			p_numlvl   := r2.numlvl;
			p_codjob   := r2.codjob;
			p_codempmt := r2.codempmt;
			p_typemp   := r2.typemp;
			p_typpayroll := r2.typpayroll;
			p_codbrlc  := r2.codbrlc;
			p_codcalen := r2.codcalen;
			p_jobgrade := r2.jobgrade;
			p_codgrpgl := r2.codgrpgl;
			exit;
		end loop;

		if not v_flgcaladj then  --????????????????????????
			for r21 in c21 loop
			  v_flgcaladj  := true;
			  p_dteeffec   := r21.dteeffec;
				v_codcurr    := r21.codcurr;
				v_amtincom1  := nvl(stddec(r21.amtincom1,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj1,r21.codempid,v_chken),0);
				v_amtincom2  := nvl(stddec(r21.amtincom2,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj2,r21.codempid,v_chken),0);
				v_amtincom3  := nvl(stddec(r21.amtincom3,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj3,r21.codempid,v_chken),0);
				v_amtincom4  := nvl(stddec(r21.amtincom4,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj4,r21.codempid,v_chken),0);
				v_amtincom5  := nvl(stddec(r21.amtincom5,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj5,r21.codempid,v_chken),0);
				v_amtincom6  := nvl(stddec(r21.amtincom6,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj6,r21.codempid,v_chken),0);
				v_amtincom7  := nvl(stddec(r21.amtincom7,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj7,r21.codempid,v_chken),0);
				v_amtincom8  := nvl(stddec(r21.amtincom8,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj8,r21.codempid,v_chken),0);
				v_amtincom9  := nvl(stddec(r21.amtincom9,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj9,r21.codempid,v_chken),0);
				v_amtincom10 := nvl(stddec(r21.amtincom10,r21.codempid,v_chken),0)- nvl(stddec(r21.amtincadj10,r21.codempid,v_chken),0);
				exit;
			end loop;
		end if;
		--
		if v_flgcaladj then
			get_wage_income(hcm_util.get_codcomp_level(p_codcomp,1),p_codempmt,v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10,
					            p_amthour,p_amtday,p_amtmth);
			--
			begin
				select codcurr into c_codcurr
				  from TCONTRPY
				 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
				   and dteeffec = (select max(dteeffec)
				                     from TCONTRPY
				                    where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
				                      and dteeffec <= sysdate);
			exception when no_data_found then null;
			end;
			v_ratechge := get_exchange_rate(to_char(p_dteeffec,'yyyy'),to_char(p_dteeffec,'mm'),c_codcurr,v_codcurr);
			p_amthour  := p_amthour * v_ratechge;
			p_amtday   := p_amtday  * v_ratechge;
			p_amtmth   := p_amtmth  * v_ratechge;
		end if;
		if not v_flgfound then
			p_dteeffec := null;
		end if;
	end;
	--
	procedure get_movemt2(p_codempid 		in varchar2,
											  p_dteeffec 		in out date,
 											  p_staupd1  		in varchar2,
											  p_staupd2  		in varchar2,
											  p_codcomp  		in out varchar2,
											  p_codpos	 		in out varchar2,
											  p_numlvl   		in out number,
 											  p_codjob   		in out varchar2,
											  p_codempmt 		in out varchar2,
											  p_typemp   		in out varchar2,
											  p_typpayroll  in out varchar2,
											  p_codbrlc  		in out varchar2,
											  p_codcalen 		in out varchar2,
											  p_jobgrade 		in out varchar2,
											  p_codgrpgl 		in out varchar2,
											  p_amtincom1		in out number,
 											  p_amtincom2   in out number,
											  p_amtincom3   in out number,
											  p_amtincom4   in out number,
											  p_amtincom5   in out number,
											  p_amtincom6   in out number,
											  p_amtincom7   in out number,
											  p_amtincom8   in out number,
											  p_amtincom9   in out number,
											  p_amtincom10  in out number) is
	v_ocodempid   TEMPLOY1.CODEMPID%TYPE;
	v_flgcaladj		boolean;
	v_flgfound 		boolean;
	c_codcurr		TCONTRPY.codcurr%type;
	v_codcurr		TCONTRPY.codcurr%type;
	v_ratechge	tratechg.ratechge%type;
  param_msg_error varchar2(4000 char);
	cursor c1 is
		select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
		  from (select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
					    from ttmovemt
		   		   where codempid  = p_codempid
					     and dteeffec <= p_dteeffec
					     and codtrn   <> '0007'
					     and staupd   in(p_staupd1,p_staupd2)
		 union
		  		  select dteoccup dteeffec,0 numseq,codcomp,codpos,numlvl,null as codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
  				    from ttprobat
				     where codempid  = p_codempid
					     and dteoccup <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
		 union
		  		  select dtereemp dteeffec,0 numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
  				    from ttrehire
				     where(codempid  = p_codempid or codempid = v_ocodempid)
  					   and dtereemp <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2))
	order by dteeffec desc,numseq desc;

	cursor c11 is
		select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
		  from (select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
  					  from ttmovemt
		   		   where codempid  = p_codempid
					     and dteeffec <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
					     and flgadjin  = 'Y'
		 union
		  		  select codempid,dteoccup dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
				      from ttprobat
				     where codempid  = p_codempid
					     and dteoccup <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2)
					     and flgadjin  = 'Y'
		 union
		  		  select codempid,dtereemp dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
				      from ttrehire
				     where(codempid  = p_codempid or codempid = v_ocodempid)
					     and dtereemp <= p_dteeffec
					     and staupd   in(p_staupd1,p_staupd2))
	order by dteeffec desc,numseq desc;

	cursor c2 is
		select dteeffec,numseq,codcomp,codpos,numlvl,codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
		  from (select dteeffec,numseq,codcompt as codcomp,codposnow as codpos,numlvlt as numlvl,codjobt as codjob,codempmtt as codempmt,typempt as typemp,typpayrolt as typpayroll,codbrlct as codbrlc,codcalet as codcalen,jobgradet as jobgrade,codgrpglt as codgrpgl
					    from ttmovemt
		   		   where codempid = p_codempid
					     and dteeffec > p_dteeffec
					     and codtrn  <> '0007'
					     and staupd  in('C','U')
		 union
		  		  select dteoccup dteeffec,0 numseq,codcomp,codpos,numlvl,null as codjob,codempmt,typemp,typpayroll,codbrlc,codcalen,jobgrade,codgrpgl
				      from ttprobat
				     where codempid = p_codempid
					     and dteoccup > p_dteeffec
  					   and staupd  in('C','U'))
	order by dteeffec,numseq;

	cursor c21 is
		select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
					 amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
		  from (select codempid,dteeffec,numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
								   amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
					    from ttmovemt
		   		   where codempid = p_codempid
					     and dteeffec > p_dteeffec
					     and staupd in('C','U')
					     and flgadjin  = 'Y'
		 union
		  		 select codempid,dteoccup dteeffec,0 numseq,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
								  amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,flgadjin
				     from ttprobat
				    where codempid = p_codempid
					    and dteoccup > p_dteeffec
					    and staupd in('C','U')
					    and flgadjin  = 'Y')
		order by dteeffec,numseq;

	begin
	  begin
			select a.ocodempid,a.codcomp,a.codpos,a.numlvl,a.codjob,a.codempmt,a.typemp,a.typpayroll,a.codbrlc,a.codcalen,a.jobgrade,a.codgrpgl,b.codcurr,
			       nvl(stddec(b.amtincom1,b.codempid,v_chken),0) amtincom1,
						 nvl(stddec(b.amtincom2,b.codempid,v_chken),0) amtincom2,
						 nvl(stddec(b.amtincom3,b.codempid,v_chken),0) amtincom3,
						 nvl(stddec(b.amtincom4,b.codempid,v_chken),0) amtincom4,
						 nvl(stddec(b.amtincom5,b.codempid,v_chken),0) amtincom5,
						 nvl(stddec(b.amtincom6,b.codempid,v_chken),0) amtincom6,
						 nvl(stddec(b.amtincom7,b.codempid,v_chken),0) amtincom7,
						 nvl(stddec(b.amtincom8,b.codempid,v_chken),0) amtincom8,
						 nvl(stddec(b.amtincom9,b.codempid,v_chken),0) amtincom9,
						 nvl(stddec(b.amtincom10,b.codempid,v_chken),0) amtincom10
			  into v_ocodempid,p_codcomp,p_codpos,p_numlvl,p_codjob,p_codempmt,p_typemp,p_typpayroll,p_codbrlc,p_codcalen,p_jobgrade,p_codgrpgl,
			       v_codcurr,p_amtincom1,p_amtincom2,p_amtincom3,p_amtincom4,p_amtincom5,p_amtincom6,p_amtincom7,p_amtincom8,p_amtincom9,p_amtincom10
 			  from temploy1 a, temploy3 b
			 where a.codempid = b.codempid
			   and a.codempid = p_codempid;
		exception when no_data_found then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          null;
		end;
		v_ocodempid := nvl(v_ocodempid,p_codempid);
		--
		for r1 in c1 loop
			p_codcomp  := r1.codcomp;
			p_codpos   := r1.codpos;
			p_numlvl   := r1.numlvl;
			p_codjob   := r1.codjob;
			p_codempmt := r1.codempmt;
			p_typemp   := r1.typemp;
			p_typpayroll := r1.typpayroll;
			p_codbrlc  := r1.codbrlc;
			p_codcalen := r1.codcalen;
			p_jobgrade := r1.jobgrade;
			p_codgrpgl := r1.codgrpgl;
			exit;
		end loop;

		v_flgcaladj := false;
		for r11 in c11 loop
		  v_flgcaladj  := true;
		  v_codcurr    := r11.codcurr;
			p_amtincom1  := nvl(stddec(r11.amtincom1,r11.codempid,v_chken),0);
			p_amtincom2  := nvl(stddec(r11.amtincom2,r11.codempid,v_chken),0);
			p_amtincom3  := nvl(stddec(r11.amtincom3,r11.codempid,v_chken),0);
			p_amtincom4  := nvl(stddec(r11.amtincom4,r11.codempid,v_chken),0);
			p_amtincom5  := nvl(stddec(r11.amtincom5,r11.codempid,v_chken),0);
			p_amtincom6  := nvl(stddec(r11.amtincom6,r11.codempid,v_chken),0);
			p_amtincom7  := nvl(stddec(r11.amtincom7,r11.codempid,v_chken),0);
			p_amtincom8  := nvl(stddec(r11.amtincom8,r11.codempid,v_chken),0);
			p_amtincom9  := nvl(stddec(r11.amtincom9,r11.codempid,v_chken),0);
			p_amtincom10 := nvl(stddec(r11.amtincom10,r11.codempid,v_chken),0);
			exit;
		end loop;
		--
		v_flgfound := false;
		for r2 in c2 loop
			v_flgfound := true;
			p_codcomp  := r2.codcomp;
			p_codpos   := r2.codpos;
			p_numlvl   := r2.numlvl;
			p_codjob   := r2.codjob;
			p_codempmt := r2.codempmt;
			p_typemp   := r2.typemp;
			p_typpayroll := r2.typpayroll;
			p_codbrlc  := r2.codbrlc;
			p_codcalen := r2.codcalen;
			p_jobgrade := r2.jobgrade;
			p_codgrpgl := r2.codgrpgl;
			exit;
		end loop;

		if not v_flgcaladj then  --????????????????????????
			for r21 in c21 loop
			  v_flgcaladj  := true;
			  p_dteeffec   := r21.dteeffec;
				v_codcurr    := r21.codcurr;
				p_amtincom1  := nvl(stddec(r21.amtincom1,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj1,r21.codempid,v_chken),0);
				p_amtincom2  := nvl(stddec(r21.amtincom2,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj2,r21.codempid,v_chken),0);
				p_amtincom3  := nvl(stddec(r21.amtincom3,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj3,r21.codempid,v_chken),0);
				p_amtincom4  := nvl(stddec(r21.amtincom4,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj4,r21.codempid,v_chken),0);
				p_amtincom5  := nvl(stddec(r21.amtincom5,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj5,r21.codempid,v_chken),0);
				p_amtincom6  := nvl(stddec(r21.amtincom6,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj6,r21.codempid,v_chken),0);
				p_amtincom7  := nvl(stddec(r21.amtincom7,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj7,r21.codempid,v_chken),0);
				p_amtincom8  := nvl(stddec(r21.amtincom8,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj8,r21.codempid,v_chken),0);
				p_amtincom9  := nvl(stddec(r21.amtincom9,r21.codempid,v_chken),0) - nvl(stddec(r21.amtincadj9,r21.codempid,v_chken),0);
				p_amtincom10 := nvl(stddec(r21.amtincom10,r21.codempid,v_chken),0)- nvl(stddec(r21.amtincadj10,r21.codempid,v_chken),0);
				exit;
			end loop;
		end if;
		--
		if v_flgcaladj then
			begin
				select codcurr into c_codcurr
				  from TCONTRPY
				 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
				   and dteeffec = (select max(dteeffec)
				                     from TCONTRPY
				                    where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
				                      and dteeffec <= sysdate);
			exception when no_data_found then null;
			end;
			v_ratechge := get_exchange_rate(to_char(p_dteeffec,'yyyy'),to_char(p_dteeffec,'mm'),c_codcurr,v_codcurr);
			p_amtincom1 := p_amtincom1 * v_ratechge;
			p_amtincom2 := p_amtincom2 * v_ratechge;
			p_amtincom3 := p_amtincom3 * v_ratechge;
			p_amtincom4 := p_amtincom4 * v_ratechge;
			p_amtincom5 := p_amtincom5 * v_ratechge;
			p_amtincom6 := p_amtincom6 * v_ratechge;
			p_amtincom7 := p_amtincom7 * v_ratechge;
			p_amtincom8 := p_amtincom8 * v_ratechge;
			p_amtincom9 := p_amtincom9 * v_ratechge;
			p_amtincom10:= p_amtincom10 * v_ratechge;
		end if;
		if not v_flgfound then
			p_dteeffec := null;
		end if;
	end;
	--
	function Cal_Min_Dup(p_dtestrt1 date,p_dteend1 date,p_dtestrt2 date,p_dteend2 date) return number is
	  v_date			date;
	  v_mindup 		number := 0;
	  v_minute		number := to_date(to_char(sysdate,'dd/mm/yyyy')||'0801','dd/mm/yyyyhh24mi') - to_date(to_char(sysdate,'dd/mm/yyyy')||'0800','dd/mm/yyyyhh24mi');--1 Minute
	begin
		 if (p_dtestrt1 > p_dtestrt2 and p_dtestrt1 < p_dteend2) or
		    (p_dteend1  > p_dtestrt2 and p_dteend1  < p_dteend2) or
		    (p_dtestrt2 > p_dtestrt1 and p_dtestrt2 < p_dteend1) or
		    (p_dteend2  > p_dtestrt1 and p_dteend2  < p_dteend1) or
		    (p_dtestrt1 = p_dtestrt2 and p_dteend1  = p_dteend2) then
	   	v_date := p_dtestrt1;
			loop
				if v_date between p_dtestrt2 and p_dteend2 then
					v_mindup := v_mindup +1;
				end if;
				v_date := v_date + v_minute;
				if (v_date >= p_dteend1) or (v_date >= p_dteend2) then
					return(v_mindup);
				end if;
			end loop;
		end if;
		return(0);
	end;
    
end;

/
