--------------------------------------------------------
--  DDL for Package Body HRAL52U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL52U" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_stdate            := to_date(trim(hcm_util.get_string_t(json_obj,'p_stdate')),'dd/mm/yyyy');
    p_endate            := to_date(trim(hcm_util.get_string_t(json_obj,'p_endate')),'dd/mm/yyyy');
    p_dtework           := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    p_timstrt           := replace(hcm_util.get_string_t(json_obj,'p_timstrt'),':');
    p_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'),':');
    p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
    p_numlereq          := hcm_util.get_string_t(json_obj,'p_numlereq');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index is
    v_secur   boolean := false;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    else
      v_secur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
        return;
      end if;
    end if;
  	if p_stdate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stdate');
      return;
    elsif p_endate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'endate');
      return;
    end if;
    if p_stdate > p_endate then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stdate > endate');
      return;
    end if;
  end check_index;
  --
  procedure check_save is
  begin
    if v_dtework is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtework');
      return;
    end if;
  	if v_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
      return;
    else
      begin
        select codshift into v_codshift
          from tshiftcd
         where codshift = v_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
        return;
      end;
    end if;
    if v_codleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codleave');
      return;
    else
      begin
        select codleave into v_codleave
          from tleavecd
         where codleave = v_codleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tleavecd');
        return;
      end;
    end if;
    if v_timstrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstrt');
      return;
    end if;
    if v_timend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timend');
      return;
    end if;
    if v_qtymins is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtymin');
      return;
    end if;
  end check_save;
  --
--  function check_holiday(p_codempid varchar2,p_dtework date,p_codleave varchar2) return boolean is
--    v_typwork   	varchar2(10);
--    v_flgchol   	varchar2(10);
--  begin
--    begin
--      select flgchol into v_flgchol
--        from tleavety
--       where typleave = (select typleave
--                           from tleavecd
--                          where codleave = p_codleave);
--    exception when no_data_found then
--      return false;
--    end;
--    if v_flgchol = 'N' then
--      return false;
--    else
--      begin
--        select typwork into v_typwork
--          from tattence
--         where codempid = p_codempid
--           and dtework  = p_dtework;
--      exception when no_data_found then
--        return false;
--      end;
--      if v_typwork in('H','S','T') then
--         return true;
--      else
--        return false;
--      end if;
--    end if;
--  end;
  --
  procedure ins_tlogleav is
    v_numseq		    number := 0;
    v_timstrt_tmp   varchar2(20 char);
    v_timends_tmp   varchar2(20 char);
  begin
    v_flgwork := 'W';
    if nvl(replace(v_timstrt_o, ':'), '654321') <> nvl(replace(v_timstrt, ':'), '654321') then
      v_numseq := v_numseq + 1;
      --
      if nvl(replace(v_timstrt, ':'),0) > 0 then
        v_timstrt_tmp := substr(v_timstrt,1,2)||':'||substr(v_timstrt,3,2);
      end if;
      --
      begin
        insert into tlogleav
          (dteupd,codempid,dtework,
           flgwork,codleave,numseq,
           codcomp,desfld,desold,
           desnew,coduser,codcreate)
        values
          (v_dteupd_log,p_codempid,v_dtework,
           v_flgwork,v_codleave,v_numseq,
           v_codcomp,'TIMSTRT',
--           substr(v_timstrt_o,1,2)||':'||substr(v_timstrt_o,3,2),
           to_char(v_timstrt_o),
           v_timstrt_tmp,
--           to_char(v_timstrt),
           global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then null;
      end;
    end if;
    if nvl(replace(v_timend_o, ':'), '654321') <> nvl(replace(v_timend, ':'), '654321') then
      v_numseq := v_numseq + 1;
      --
      if nvl(replace(v_timend, ':'),0) > 0 then
        v_timends_tmp := substr(v_timend,1,2)||':'||substr(v_timend,3,2);
      end if;
      --
      begin
        insert into tlogleav
          (dteupd,codempid,dtework,
           flgwork,codleave,numseq,
           codcomp,desfld,desold,
           desnew,coduser,codcreate)
        values
          (v_dteupd_log,p_codempid,v_dtework,
           v_flgwork,v_codleave,v_numseq,
           v_codcomp,'TIMEND',
--           substr(v_timend_o,1,2)||':'||substr(v_timend_o,3,2),
           to_char(v_timend_o),
           v_timends_tmp,
--           to_char(v_timend),
           global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then null;
      end;
    end if;
    if nvl(replace(v_qtymins_o, ':'), '654321') <> nvl(replace(v_qtymins, ':'), '654321') then
      v_numseq := v_numseq + 1;
      begin
        insert into tlogleav
          (dteupd,codempid,dtework,
           flgwork,codleave,numseq,
           codcomp,desfld,desold,
           desnew,coduser,codcreate)
        values
          (v_dteupd_log,p_codempid,v_dtework,
           v_flgwork,v_codleave,v_numseq,
           v_codcomp,'QTYMIN',
           to_char(v_qtymins_o),
           to_char(v_qtymins),
           global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then null;
      end;
    end if;
    if nvl(replace(v_dteprgntst_o, ':'), '654321') <> nvl(replace(v_dteprgntst, ':'), '654321') then
      v_numseq := v_numseq + 1;
      begin
        insert into tlogleav
          (dteupd,codempid,dtework,
           flgwork,codleave,numseq,
           codcomp,desfld,desold,
           desnew,coduser,codcreate)
        values
          (v_dteupd_log,p_codempid,v_dtework,
           v_flgwork,v_codleave,v_numseq,
           v_codcomp,'DTEPRGNTST',
           to_char(v_dteprgntst_o,'dd/mm/yyyy'),
           to_char(v_dteprgntst,'dd/mm/yyyy'),
           global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then null;
      end;
    end if;
  end;
  --
  procedure upd_tleavsum is
    v_flgfound 	boolean;
  cursor c_tleavsum is
    select rowid
      from tleavsum
     where codempid = p_codempid
       and dteyear  = v_yrecycle -- - :global.v_zyear
       and codleave = v_codleave
  order by codempid,dteyear,codleave;
  begin
    v_flgfound := false;
    for r_tleavsum in c_tleavsum loop
      v_flgfound := true;
      begin
        update tleavsum
           set qtyshrle = (qtyshrle - (v_qtymin_o / 60)) + (v_qtymin / 60),
               qtydayle = (nvl(qtydayle,0) - nvl(v_qtyday_o,0)) + nvl(v_qtyday,0),--User37 #5753 2.AL Module 27/04/2021 (qtydayle - v_qtyday_o) + v_qtyday,
                coduser = global_v_coduser
            where rowid = r_tleavsum.rowid;
      exception when others then null;
      end;
    end loop;
    if not v_flgfound then
      insert into tleavsum(codempid,dteyear,codleave,typleave,staleave,qtyshrle,
                           qtydayle,codcomp,typpayroll,dteupd,coduser)
                    values(p_codempid,v_yrecycle,v_codleave,v_typleave,v_staleave,(v_qtymin/60),
                           v_qtyday,v_codcomp,v_typpayroll,sysdate,global_v_coduser);
    end if;
  end;
  --
  function convert_time(p_time varchar2) return varchar2 as
    v_time varchar2(10 char);
  begin
    if p_time is null then
      v_time := null;
    else
      v_time := substr(p_time,1,2)||':'||substr(p_time,3,2);
    end if;
  return v_time;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row		        number := 0;
    v_timstrt       varchar2(10 char);
    v_timend        varchar2(10 char);
    v_qtymin        varchar2(10 char);
    v_flgtype       tleavety.flgtype%type;
    v_count_lvprgnt number  := 0;
    v_typleave      tleavecd.typleave%type;
    cursor c1 is
      select dtework,codshift,codleave,timstrt,timend,qtymin,qtyday,numlereq,dteprgntst
        from tleavetr
       where codempid = p_codempid
         and dtework between p_stdate and p_endate
    order by dtework,codleave;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_row := json_object_t();
      for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();

        if i.timstrt is null then
          v_timstrt := null;
        else
          v_timstrt := substr(i.timstrt,1,2)||':'||substr(i.timstrt,3,2);
        end if;
        if i.timend is null then
          v_timend := null;
        else
          v_timend := substr(i.timend,1,2)||':'||substr(i.timend,3,2);
        end if;
        if i.qtymin is null then
          v_qtymin := null;
        else
          v_qtymin := hcm_util.convert_minute_to_hour(i.qtymin);
        end if;
        --
        begin
          select t2.flgtype
            into v_flgtype
            from tleavecd t1, tleavety t2
           where t1.typleave  = t2.typleave
             and t1.codleave  = i.codleave;
        exception when others then
            v_flgtype  := null;
        end;
        obj_data.put('coderror','200');
        obj_data.put('dtework',to_char(i.dtework,'dd/mm/yyyy'));
        obj_data.put('codshift',i.codshift);
        obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift,global_v_lang));
        obj_data.put('codleave',i.codleave);
        obj_data.put('timstrt',v_timstrt);
        obj_data.put('timstrt_o',v_timstrt);
        obj_data.put('timend',v_timend);
        obj_data.put('timend_o',v_timend);
        obj_data.put('qtymin',v_qtymin);
        obj_data.put('qtymin_o',v_qtymin);
        obj_data.put('qtyday',i.qtyday);
        obj_data.put('qtyday_o',i.qtyday);
        obj_data.put('numlereq',i.numlereq);
        obj_data.put('dteprgntst',to_char(i.dteprgntst,'dd/mm/yyyy'));
        -- paternity leave --
        if v_flgtype = 'M' then
            obj_data.put('flglvprgnt','Y');
        else
            obj_data.put('flglvprgnt','N');
        end if;
        obj_data.put('flgtype',v_flgtype);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;

      json_str_output := obj_row.to_clob;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_codshift(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_codshift    varchar2(10 char);
    v_timstrtw    varchar2(10 char);
    v_timendw     varchar2(10 char);
  begin
    initial_value(json_str_input);

    begin
      select codshift,to_char(to_date(timstrtw,'hh24:mi'),'hh24:mi'),to_char(to_date(timendw,'hh24:mi'),'hh24:mi')
        into v_codshift,v_timstrtw,v_timendw
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtework;
    exception when no_data_found then
      v_codshift := null;
      v_timstrtw := null;
      v_timendw  := null;
    end;


    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codshift', v_codshift);
    obj_row.put('desc_codshift',get_tshiftcd_name(v_codshift,global_v_lang));
    obj_row.put('timstrtw', v_timstrtw);
    obj_row.put('timendw', v_timendw);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codshift;
  --
  procedure get_showleave(json_str_input in clob, json_str_output out clob) is
    obj_row      json_object_t;
    obj_data     json_object_t;
    v_coderr			varchar2(20 char);
    v_coderr2			varchar2(20 char);
    v_flgerr		  varchar2(1 char) := 'N';
    v_sumday			number;
    v_summin			number;
    v_qtyavgwk		number;
    v_dtelest			tlereqst.dtestrt%type;
    v_dteleen			tlereqst.dteend%type;
    v_qtyday1			number;
    v_qtyday2			number;
    v_qtyday3			number;
    v_qtyday4			number;
    v_qtyday5			number;
    v_qtyday6			number;
    v_qtyminle		number;
    v_qtyminrq		number;
    v_timstrt     varchar2(4);
    v_timend      varchar2(4);
    v_qtymin      number;
    v_qtyday      number;
    v_response    varchar2(1000 char);

    cursor c_tattence is
      select codempid,dtework,typwork,codshift,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtework;
  begin
    initial_value(json_str_input);

    if p_timstrt is not null and p_timend is not null then
		--if :tleavetr.flgwork = 'W' then
			for r_tattence in c_tattence loop
				if to_char(to_date(p_timstrt,'hh24mi'),'hh24mi') < r_tattence.timstrtw then
					v_dtelest := p_dtework + 1;
				else
					v_dtelest := p_dtework;
				end if;
				if to_char(to_date(p_timstrt,'hh24mi'),'hh24mi') < to_char(to_date(p_timend,'hh24mi'),'hh24mi') then
					v_dteleen := v_dtelest;
				else
					v_dteleen := v_dtelest + 1;
				end if;
			end loop; -- for r_tattence
		--
      begin
        select numlereq into v_numlereq
          from tleavetr
         where codempid = p_codempid
           and dtework  = p_dtework
           and codleave = p_codleave;
        exception when no_data_found then
           v_numlereq := '';
      end;
      hral56b_batch.gen_entitlement(p_codempid, v_numlereq,  null,  'H',
                                    p_codleave, p_dtework,  v_dtelest,  to_char(to_date(p_timstrt,'hh24mi'),'hh24mi'),
                                    v_dteleen,  to_char(to_date(p_timend,'hh24mi'),'hh24mi'),
                                    p_dtework,
                                    global_v_zyear, global_v_coduser,
                                    v_coderr, v_qtyday1,  v_qtyday2,  v_qtyday3,  v_qtyday4,  v_qtyday5,  v_qtyday6,
                                    v_qtyminle, v_qtyminrq, v_qtyavgwk);

      v_timstrt := to_char(to_date(p_timstrt,'hh24mi'),'hh24mi');
      v_timend  := to_char(to_date(p_timend,'hh24mi'),'hh24mi');
      --
      hral56b_batch.gen_min_req(false,v_numlereq,p_codempid,'H',p_codleave,
                          p_dtework,v_dtelest,v_timstrt,v_dteleen,v_timend,global_v_coduser,
                          v_summin,v_sumday,v_qtyavgwk,v_coderr2);
      --
      if v_coderr is not null then
        if v_coderr in ('AL0020','AL0037') then
          param_msg_error := get_error_msg_php(v_coderr,global_v_lang,'dtework');
          v_flgerr := 'Y';
        elsif v_coderr = 'AL0060' then
          param_msg_error := get_error_msg_php(v_coderr, global_v_lang, 'tleavcom');
          v_flgerr := 'Y';
        elsif v_coderr = 'AL0067' then
          param_msg_error := get_error_msg_php(v_coderr, global_v_lang,'timstrt');
          v_flgerr := 'Y';
        else
          param_msg_error := get_error_msg_php(v_coderr, global_v_lang);
          v_flgerr := 'N';
        end if;
      else
        if v_coderr is not null then
          param_msg_error := get_error_msg_php(v_coderr2, global_v_lang);
        end if;
      end if;

      if v_summin > 0 then
        v_qtymin	:= v_summin;
        v_qtyday 	:= v_sumday;
      end if;
    else
      v_qtymin := 0;
    end if;

    if param_msg_error is null then
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('timstrt',v_timstrt);
      obj_row.put('timend',v_timend);
      obj_row.put('qtymin',hcm_util.convert_minute_to_hour(v_qtymin));

      json_str_output := obj_row.to_clob;
    elsif param_msg_error is not null then
      obj_data := json_object_t();
      obj_data.put('coderror', '400');
      obj_data.put('flgerr', v_flgerr);

      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

      json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_showleave;
  --
  procedure get_info(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		      number := 0;
    v_numlereq    TLEREQST.NUMLEREQ%type;
    v_dtestrt     date;
    v_timstrt     tlereqst.timstrt%type;
    v_dteend      date;
    v_timend      tlereqst.timend%type;
    v_qtyday      number;
    v_dtework     date;
    v_typwork     varchar2(1 char);
    v_desshifte   tshiftcd.desshifte%type;
    v_timstrtw    tattence.timstrtw%type;
    v_timendw     tattence.timendw%type;
    v_qtydaywk    number;
    v_dtein       date;
    v_timin       tattence.timin%type;
    v_dteout      date;
    v_timout      tattence.timout%type;
    v_codshift    tattence.codshift%type;
  begin
    initial_value(json_str_input);
    check_index;

    begin
      select numlereq,dtestrt,timstrt,dteend,timend,qtyday
        into v_numlereq,v_dtestrt,v_timstrt,v_dteend,v_timend,v_qtyday
        from tlereqst
       where numlereq = p_numlereq;
    exception when no_data_found then
      v_numlereq := null;
      v_dtestrt  := null;
      v_timstrt  := null;
      v_dteend   := null;
      v_timend   := null;
      v_qtyday   := null;
    end;

    begin
      select a.dtework,a.typwork,b.desshifte,a.timstrtw,a.timendw,
             b.qtydaywk,a.dtein,a.timin,a.dteout,a.timout,a.codshift
        into v_dtework,v_typwork,v_desshifte,v_timstrtw,v_timendw,
             v_qtydaywk,v_dtein,v_timin,v_dteout,v_timout,v_codshift
        from tattence a,tshiftcd b
       where a.codshift = b.codshift
         and a.codempid = p_codempid
         and a.dtework  = p_dtework;
    exception when no_data_found then
      v_dtework   := null;
      v_typwork   := null;
      v_desshifte := null;
      v_timstrtw  := null;
      v_timendw   := null;
      v_qtydaywk  := null;
      v_dtein     := null;
      v_timin     := null;
      v_dteout    := null;
      v_timout    := null;
      v_codshift  := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('numlereq',v_numlereq);
    obj_row.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
    obj_row.put('timstrt',convert_time(v_timstrt));
    obj_row.put('dteend',to_char(v_dteend,'dd/mm/yyyy'));
    obj_row.put('timend',convert_time(v_timend));
    obj_row.put('qtyday',v_qtyday);
    obj_row.put('dtework',to_char(v_dtework,'dd/mm/yyyy'));
    obj_row.put('typwork',v_typwork);
    obj_row.put('desshifte',get_tshiftcd_name(v_codshift,global_v_lang));
    obj_row.put('timstrtw',convert_time(v_timstrtw));
    obj_row.put('timendw',convert_time(v_timendw));
    obj_row.put('qtydaywk',hcm_util.convert_minute_to_hour(v_qtydaywk));
    obj_row.put('dtetimin',to_char(v_dtein, 'dd/mm/yyyy')||' '||convert_time(v_timin));
    obj_row.put('dtetimout',to_char(v_dteout, 'dd/mm/yyyy')||' '||convert_time(v_timout));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_info;
  --
  procedure save_data(json_str_input in clob,json_str_output out clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_codempid        varchar2(100 char);
    v_codcompy        varchar2(10 char);
    v_flgatten        varchar2(1 char);
    v_dtecycst        date;
		v_dtecycen        date;
    v_flg             varchar2(10 char);
--    v_qtydayle        number;
    v_qtydaywk        number;
    v_cnt             number;

    v_dtelest			tlereqst.dtestrt%type;
    v_dteleen			tlereqst.dteend%type;
    v_qtyday1			number;
    v_qtyday2			number;
    v_qtyday3			number;
    v_qtyday4			number;
    v_qtyday5			number;
    v_qtyday6			number;
    v_qtyminle		number;
    v_qtyminrq		number;
    v_qtyavgwk		number;
    v_coderr			varchar2(20 char);
    v_numrec      number;
    v_sum_qtymin  number;

    cursor c_tattence is
      select codempid,dtework,typwork,codshift,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw
        from tattence
       where codempid = p_codempid
         and dtework  = v_dtework;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      v_dteupd_log  := sysdate;
      for i in 0..param_json.get_size-1 loop
        param_json_row := hcm_util.get_json_t(param_json,to_char(i));
        v_dtework      := to_date(trim(hcm_util.get_string_t(param_json_row,'dtework')),'dd/mm/yyyy');
        v_codshift     := hcm_util.get_string_t(param_json_row,'codshift');
        v_codleave     := hcm_util.get_string_t(param_json_row,'codleave');
        v_timstrt      := hcm_util.get_string_t(param_json_row,'timstrt');
        v_timstrt_o    := hcm_util.get_string_t(param_json_row,'timstrtOld');
        v_timend       := hcm_util.get_string_t(param_json_row,'timend');
        v_timend_o     := hcm_util.get_string_t(param_json_row,'timendOld');
        v_qtymins      := hcm_util.get_string_t(param_json_row,'qtymin');
        v_qtymins_o    := hcm_util.get_string_t(param_json_row,'qtymin_o');
        v_qtyday       := hcm_util.get_string_t(param_json_row,'qtyday');
        v_qtyday_o     := hcm_util.get_string_t(param_json_row,'qtydayOld');
        v_numlereq     := hcm_util.get_string_t(param_json_row,'numlereq');
        v_dteprgntst   := to_date(trim(hcm_util.get_string_t(param_json_row,'dteprgntst')),'dd/mm/yyyy');
        v_dteprgntst_o   := to_date(trim(hcm_util.get_string_t(param_json_row,'dteprgntstOld')),'dd/mm/yyyy');
        -- paternity leave --
--        v_timprgnt     := hcm_util.get_string_t(param_json_row,'timprgnt');
--        v_timprgnt_o   := hcm_util.get_string_t(param_json_row,'timprgntOld');
        --
        v_flg          := hcm_util.get_string_t(param_json_row,'flg');
        check_save;
        if v_flg = 'add' or v_flg = 'edit' then
          begin
            select codshift,codcomp,flgatten,typpayroll
              into v_codshift,v_codcomp,v_flgatten,v_typpayroll
              from tattence
             where codempid = p_codempid
               and dtework  = v_dtework;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'dtework');
          end;
          begin
            select a.codcompy into v_codcompy
              from tcenter a, tleavcom b
             where a.codcompy = b.codcompy
               and a.codcomp  = v_codcomp
               and b.typleave = (select typleave from tleavecd where codleave = v_codleave);
          exception when no_data_found then
            param_msg_error := get_error_msg_php('AL0060', global_v_lang ,'tleavcom');
          end;
          begin
            select typleave,staleave
              into v_typleave,v_staleave
              from tleavecd
             where codleave = v_codleave;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tleavecd');
          end;

          if param_msg_error is null then
            v_dtelest := null;
            v_dteleen := null;
            if v_timstrt is not null and v_timend is not null then
              for r_tattence in c_tattence loop
                if to_char(to_date(v_timstrt,'hh24mi'),'hh24mi') < r_tattence.timstrtw then
                  v_dtelest := v_dtework + 1;
                else
                  v_dtelest := v_dtework;
                end if;
                if to_char(to_date(v_timstrt,'hh24mi'),'hh24mi') < to_char(to_date(v_timend,'hh24mi'),'hh24mi') then
                  v_dteleen := v_dtelest;
                else
                  v_dteleen := v_dtelest + 1;
                end if;
              end loop;
              hral56b_batch.gen_entitlement(p_codempid, v_numlereq, null, 'H',
                                            v_codleave, v_dtework,  v_dtelest,  to_char(to_date(v_timstrt,'hh24mi'),'hh24mi'),
                                            v_dteleen,  to_char(to_date(v_timend,'hh24mi'),'hh24mi'),
                                            v_dteprgntst,
                                            global_v_zyear, global_v_coduser,
                                            v_coderr, v_qtyday1,  v_qtyday2,  v_qtyday3,
                                            v_qtyday4,v_qtyday5,  v_qtyday6,  v_qtyminle, v_qtyminrq, v_qtyavgwk);
            end if;

            if v_coderr is not null then
              param_msg_error := get_error_msg_php(v_coderr, global_v_lang);
            end if;
          end if;

          if param_msg_error is null then
            --<<User37 #5753 2.AL Module 27/04/2021 
            begin
                select qtyday into v_qtyday_o
                  from tleavetr
                 where codempid = p_codempid
                   and dtework  = v_dtework
                   and codleave = v_codleave;
              exception when no_data_found then null;
            end;
            -->>User37 #5753 2.AL Module 27/04/2021 
            if v_flg = 'add' then
              begin
                select codleave into v_codleave
                  from tleavetr
                 where codempid = p_codempid
                   and dtework  = v_dtework
                   and codleave = v_codleave;
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'dtework');
              exception when no_data_found then null;
              end;
              --
              v_qtyday_o := 0;
            end if;
            ----------- insert tleavetr ------------
            if v_qtymins is not null then
              v_qtymin := hcm_util.convert_hour_to_minute(v_qtymins);
            else
              v_qtymin := 0;
            end if;
            if v_qtymins_o is not null then
              v_qtymin_o := hcm_util.convert_hour_to_minute(v_qtymins_o);
            else
              v_qtymin_o := 0;
            end if;
            --
            begin
              select qtydaywk into v_qtydaywk
                from tshiftcd
               where codshift = v_codshift;
              v_qtyday := v_qtymin / v_qtydaywk;
            exception when no_data_found then
              v_qtydaywk := 0;
              v_qtyday := 0;
            end;
            begin
              insert into tleavetr(codempid,dtework,codleave,typleave,staleave,codcomp,typpayroll,
                                   codshift,flgatten,timstrt,timend,qtymin,qtyday,dteprgntst,
                                   dteupd,coduser
                                   )
                           values (p_codempid,v_dtework,v_codleave,v_typleave,v_staleave,v_codcomp,v_typpayroll,
                                   v_codshift,v_flgatten,v_timstrt,v_timend,v_qtymin,v_qtyday,v_dteprgntst,
                                   sysdate,global_v_coduser
                                   );
            exception when dup_val_on_index then
              begin
                update  tleavetr
                set     typleave   = v_typleave,
                        staleave   = v_staleave,
                        codcomp    = v_codcomp,
                        typpayroll = v_typpayroll,
                        codshift   = v_codshift,
                        flgatten   = v_flgatten,
                        timstrt    = v_timstrt,
                        timend     = v_timend,
                        qtymin     = v_qtymin,
                        qtyday     = v_qtyday,
                        dteprgntst = v_dteprgntst,
                        dteupd     = sysdate,
                        coduser    = global_v_coduser
                  where codempid   = p_codempid
                    and dtework    = v_dtework
                    and codleave   = v_codleave;
              exception when others then
                rollback;
              end;
            end;
            ----------- insert tleavsum ------------
            std_al.cycle_leave(v_codcompy,p_codempid,v_codleave,v_dtework,v_yrecycle,v_dtecycst,v_dtecycen);
            if v_yrecycle is null then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang);
              exit;
            else
              upd_tleavsum;
              ins_tlogleav;
            end if;
            -- update tleavsum standard package
            hral56b_batch.upd_tleavsum(p_codempid, v_dtework, v_codleave, global_v_coduser);
            --
            -- update temploy1 --
            if v_dteprgntst is not null then
              begin
                update temploy1 set dteprgntst = v_dteprgntst
                 where codempid = p_codempid;
              exception when others then null;
              end;
            end if;
          end if;-- param_msg_error is null
        elsif v_flg = 'delete' then
          begin
            select codcomp into v_codcomp
              from tattence
             where codempid = p_codempid
               and dtework  = v_dtework;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'dtework');
          end;
          --
          begin
            select a.codcompy into v_codcompy
              from tcenter a, tleavcom b
             where a.codcompy = b.codcompy
               and a.codcomp  = v_codcomp
               and b.typleave = (select typleave from tleavecd where codleave = v_codleave);
          exception when no_data_found then
            param_msg_error := get_error_msg_php('AL0060', global_v_lang ,'tleavcom');
          end;
          --
          if param_msg_error is null then
            delete from tleavetr
                  where codempid = p_codempid
                    and dtework  = v_dtework
                    and codleave = v_codleave;

            std_al.cycle_leave(v_codcompy,p_codempid,v_codleave,v_dtework,v_yrecycle,v_dtecycst,v_dtecycen);
            --
            if v_qtymins_o is not null then
              v_qtymin_o := hcm_util.convert_hour_to_minute(v_qtymins_o);
            else
              v_qtymin_o := 0;
            end if;
            --
            update tleavsum
               set qtyshrle = qtyshrle - (v_qtymin_o / 60),
                   qtydayle = qtydayle - nvl(v_qtyday,0),--User37 #5753 2.AL Module 27/04/2021 qtydayle - v_qtyday,
                   coduser  = global_v_coduser
             where codempid = p_codempid
               and dteyear  = v_yrecycle --(v_yrecycle - :global.v_zyear)
               and codleave = v_codleave;
            begin
              select count(codempid) into v_cnt
                from tleavetr
               where numlereq = v_numlereq;
            exception when others then
              v_cnt := 0;
            end;
            if v_cnt = 1 then
                update tleavsum
                   set qtytleav = greatest(qtytleav - 1,0),
                       coduser  = global_v_coduser
                 where codempid = p_codempid
                   and dteyear  = v_yrecycle --(v_yrecycle - :global.v_zyear)
                   and codleave = v_codleave;
            end if;
            -- clear params delete before insert logs --
            v_timstrt := null;
            v_timend  := null;
            v_qtymins := null;
            --
            v_dteprgntst := '';
            ins_tlogleav;
            -- update tleavsum standard package
            hral56b_batch.upd_tleavsum(p_codempid, v_dtework, v_codleave, global_v_coduser);
            --
          end if;
        end if;
      end loop;
      -- check leave per day --
      for i in 0..param_json.get_size-1 loop
        param_json_row := hcm_util.get_json_t(param_json,to_char(i));
        v_dtework      := to_date(trim(hcm_util.get_string_t(param_json_row,'dtework')),'dd/mm/yyyy');
        v_codshift     := hcm_util.get_string_t(param_json_row,'codshift');
        v_codleave     := hcm_util.get_string_t(param_json_row,'codleave');
      begin
        select qtydaywk into v_qtydaywk
          from tshiftcd
         where codshift = v_codshift;
      exception when no_data_found then
        v_qtydaywk := 0;
      end;
        begin
          select sum(qtymin) into v_sum_qtymin
            from tleavetr
           where codempid = p_codempid
             and dtework = v_dtework;
        exception when no_data_found then
          v_sum_qtymin := 0;
        end;
        if v_sum_qtymin > v_qtydaywk then
          param_msg_error := get_error_msg_php('AL0071', global_v_lang);
          exit;
        end if;
        --
      end loop;
      std_al.cal_tattence(p_codempid,p_stdate,p_endate,global_v_coduser,v_numrec);

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure get_flgtype_leave (json_str_input in clob, json_str_output out clob) is
    v_flgtype       tleavety.flgtype%type;
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_count_lvprgnt number := 0;
    v_dteprgntst    date;
  begin
    -- initial_value(json_str_input);
    json_obj      := json_object_t(json_str_input);
    p_codleave    := hcm_util.get_string_t(json_obj, 'p_codleave');
    p_codempid    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dtework     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    -- check type leave --
    begin
      select t2.flgtype into v_flgtype
        from tleavecd t1, tleavety t2
       where t1.typleave  = t2.typleave
         and t1.codleave  = p_codleave;
    exception when others then
        v_flgtype  := null;
    end;
    begin
      select dteprgntst into v_dteprgntst
        from temploy1
       where codempid = p_codempid
         and p_dtework between add_months(dteprgntst, -9) and dteprgntst;
    exception when others then
      v_dteprgntst := null;
    end;
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('flgtype',v_flgtype);
    --
    if v_flgtype = 'M'  then
      obj_data.put('flglvprgnt','Y');
      obj_data.put('dteprgntst',to_char(v_dteprgntst,'dd/mm/yyyy'));
    else
      obj_data.put('flglvprgnt','N');
      obj_data.put('dteprgntst','');
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_flgtype_leave;

end HRAL52U;

/
