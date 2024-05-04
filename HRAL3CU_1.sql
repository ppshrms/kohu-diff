--------------------------------------------------------
--  DDL for Package Body HRAL3CU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3CU" is

  function min_to_num(p_min number) return number is
    v_num		number;
  begin
    v_num := (trunc(p_min / 60,0) + (mod(p_min,60) / 100)) * 100;
    return(v_num);
  end;

  function num_to_min(p_num number) return number is
    v_min		number;
  begin
    v_min := (trunc((p_num / 100) / 1,0) * 60) + mod((p_num / 100),1) * 100;
    return(v_min);
  end;

  procedure check_index is
    v_staemp    varchar2(2 char);
    v_codcomp   temploy1.codcomp%type;
    v_secur     boolean;
  begin
    if p_codempid is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
       return;
    end if;
    if p_dtestr is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stdate');
       return;
    end if;
    if p_dteend is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang,'endate');
       return;
    end if;
    begin
      select staemp,codcomp into v_staemp,v_codcomp
      from   temploy1
      where  codempid = p_codempid;
    exception when others then
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
       return;
    end ;
    if v_staemp = '0' then
      param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
      return;
--    elsif v_staemp = '9' then
--      param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
--      return;
    end if;
    if p_dtestr > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'stdate');
      return;
    end if;

--    param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
		if param_msg_error is not null then
      return;
		end if;
--    v_secur := secur_main.secur3(v_codcomp,p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--    if v_secur  then
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
--      return;
--    end if;
  end;

 /* procedure check_save_index is
  v_codshift  varchar2(100 char);
  begin
    begin
      select codcomp
      into   p_codcomp
      from   temploy1
      where  codempid = p_codempid;
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
      return;
    end ;
    if p_typwork is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typwork');
      return;
    end if;
    if p_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
      return;
    end if;
    begin
      select timstrtw,timendw
      into   v_timstrtw,v_timendw
      from   tshiftcd
      where  codshift = p_codshift;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
      return;
    end;

    begin
      select codshift into v_codshift
        from  tshifcom
       where  codshift  = p_codshift
         and  codcompy  = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0061',global_v_lang,'codshift');
      return;
    end;
--    if p_timin is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timin');
--      return;
--    end if;
--
--    if p_timout is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timout');
--      return;
--    end if;

    -- chk 2020 --
--    if p_codchng is not null then
--      begin
--        select codcodec
--        into   p_codchng
--        from   tcodtime
--        where  codcodec = p_codchng;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtime.codchng');
--        return;
--      end;
--    end if;

    if  v_timstrtw < v_timendw then
      p_dteendw := p_dtework;
    else
      p_dteendw := p_dtework + 1;
    end if;
  end;*/

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := '';
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    --
    p_date              := to_date(hcm_util.get_string_t(json_obj,'p_date'), 'dd/mm/yyyy');
    p_codshift          := hcm_util.get_string_t(json_obj,'p_codshift');
    p_timino            := hcm_util.get_string_t(json_obj,'p_timino');
    p_timouto           := hcm_util.get_string_t(json_obj,'p_timouto');
    p_timinn            := hcm_util.get_string_t(json_obj,'p_timinn');
    p_timoutn           := hcm_util.get_string_t(json_obj,'p_timoutn');

    p_dtework           := to_date(hcm_util.get_string_t(json_obj,'p_dtework'),'dd/mm/yyyy');
    p_typwork           := hcm_util.get_string_t(json_obj,'p_typwork');
    p_dtein             := to_date(hcm_util.get_string_t(json_obj,'p_dtein'),'dd/mm/yyyy');
    p_dteout            := to_date(hcm_util.get_string_t(json_obj,'p_dteout'),'dd/mm/yyyy');
    p_timin             := replace(hcm_util.get_string_t(json_obj,'p_timin'),':','');
    p_timout            := replace(hcm_util.get_string_t(json_obj,'p_timout'),':','');


  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_timin         varchar2(5 char);
    v_timout        varchar2(5 char);

    cursor c1 is
      select a.codempid, a.dtework, a.typwork, a.codshift, a.dtein, a.timin, a.dteout, a.timout,
             a.codchng, a.codcomp, a.qtynostam, a.timstrtw, a.timendw,
             b.qtylate, b.qtyearly, b.qtyabsent, b.flginput, c.qtydaywk,
             c.timstrtw timstrtw_def, c.timendw timendw_def
        from tattence a, tlateabs b, tshiftcd c
       where a.codempid = b.codempid(+)
         and a.dtework  = b.dtework(+)
         and a.codempid = p_codempid
         and a.dtework between p_dtestr and p_dteend
         and a.codshift  = c.codshift(+)
       order by dtework;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data := json_object_t();

      v_timin  := '';
      v_timout := '';
      if r1.timin is not null then
        v_timin  := substr(r1.timin, 1, 2) || ':' || substr(r1.timin, 3, 2);
      end if;
      if r1.timout is not null then
        v_timout := substr(r1.timout, 1, 2) || ':' || substr(r1.timout, 3, 2);
      end if;

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));
      obj_data.put('dte', get_namdayabb(to_number(to_char(r1.dtework,'d')) ,global_v_lang));
      obj_data.put('typwork', r1.typwork);
      obj_data.put('codshift', r1.codshift);

      obj_data.put('dtein', to_char(r1.dtein,'dd/mm/yyyy'));
      obj_data.put('dteout', to_char(r1.dteout,'dd/mm/yyyy'));
      obj_data.put('timinn', r1.timin);
      obj_data.put('timoutn', r1.timout);

--      if r1.dtein is not null then
--        obj_data.put('dtein', to_char(r1.dtein,'dd/mm/yyyy'));
--        obj_data.put('dteout', to_char(r1.dteout,'dd/mm/yyyy'));
--        obj_data.put('timinn', r1.timin);
--        obj_data.put('timoutn', r1.timout);
--      else
--        obj_data.put('dtein', to_char(r1.dtework,'dd/mm/yyyy'));
--        obj_data.put('timinn', r1.timstrtw_def);
--        obj_data.put('timoutn', r1.timendw_def);
--        if r1.timendw_def > r1.timstrtw_def then
--            obj_data.put('dteout', to_char(r1.dtework,'dd/mm/yyyy'));
--        else
--            obj_data.put('dteout', to_char(r1.dtework + 1,'dd/mm/yyyy'));
--        end if;
--      end if;
      obj_data.put('dteino', to_char(r1.dtein,'dd/mm/yyyy'));
      obj_data.put('dteouto', to_char(r1.dteout,'dd/mm/yyyy'));
      obj_data.put('timino', v_timin);
      obj_data.put('timouto', v_timout);
      obj_data.put('timstrtw', substr(r1.timstrtw,1,2)||':'||substr(r1.timstrtw,3,4));
      obj_data.put('timendw', substr(r1.timendw,1,2)||':'||substr(r1.timendw,3,4));
      obj_data.put('codchng', r1.codchng);
      obj_data.put('qtynostam', to_char(nvl(r1.qtynostam,'0')));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('qtylate', hcm_util.convert_minute_to_hour(r1.qtylate));
      obj_data.put('qtyearly', hcm_util.convert_minute_to_hour(r1.qtyearly));
      obj_data.put('qtyabsent', hcm_util.convert_minute_to_hour(r1.qtyabsent));
      obj_data.put('flginput', r1.flginput);
      obj_data.put('qtydaywk', r1.qtydaywk);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  /*procedure post_index(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index(json_str_input);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_index;

  procedure save_index(json_str_input in clob) is
    json_obj        json;
    json_obj2       json;
    param_json      json;
    param_json_row  json;
    v_flg           varchar2(1000 char);

--    v_dtein_o 	    date ;
    v_timin_o		    varchar2(10);
--    v_dteout_o      date ;
    v_timout_o	    varchar2(10);
    v_codchng_o     varchar2(10);
    v_typwork_o     varchar2(10);
    v_codshift_o    varchar2(10);
    v_qtynostam_o   number;

    v_qtylate_o      number;
    v_qtyearly_o     number;
    v_qtyabsent_o    number;

    v_timin			    varchar2(10);
    v_timout		    varchar2(10);
    v_codchng		    varchar2(10);
    v_typwork       varchar2(10);
    v_codshift      varchar2(10);
    v_qtynostam     number;

    v_qtylate       number;
    v_qtyearly      number;
    v_qtyabsent     number;
    --
    v_flgatten      varchar2(10);
    v_qtydaywk      number;
    v_qtytlate      number;
    v_qtytearly     number;
    v_qtytabs       number;
    v_flgcalabs     varchar2(10);
    v_flginput      varchar2(10);
    v_qtyhwork      number;
    v_daylate       number;
    v_dayearly      number;
    v_dayabsent     number;
    v_dtein         date;
    v_dteout        date;
    v_tmp_dtein     date;
    v_tmp_dteout    date;
    v_dtein_o       date;
    v_dteout_o      date;
    v_dtein_n       date;
    v_dteout_n      date;
    v_check         varchar2(1 char) := 'N';
    v_abnormal      number;
  begin
    param_json := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    if param_msg_error is null then
      for i in 0..param_json.count-1 loop
        param_json_row   := json(param_json.get(to_char(i)));
        p_codempid       := hcm_util.get_string(param_json_row,'codempid');
        p_typwork        := hcm_util.get_string(param_json_row,'typwork');
        p_codshift       := hcm_util.get_string(param_json_row,'codshift');
        p_dtework        := to_date(hcm_util.get_string(param_json_row,'date'),'dd/mm/yyyy');
--        p_timstrtw       := hcm_util.get_string(param_json_row,'timstrtw');
--        p_timendw        := hcm_util.get_string(param_json_row,'timendw');
        p_timin          := replace(hcm_util.get_string(param_json_row,'timinn'),':','');
        p_timout         := replace(hcm_util.get_string(param_json_row,'timoutn'),':','');
        p_codchng        := hcm_util.get_string(param_json_row,'codchng');
        p_qtynostam      := nvl(to_number(hcm_util.get_string(param_json_row,'qtynostam')),0);

        p_qtylate        := to_number(hcm_util.convert_hour_to_minute(hcm_util.get_string(param_json_row,'timlate')));
        p_qtyearly       := to_number(hcm_util.convert_hour_to_minute(hcm_util.get_string(param_json_row,'timback')));
        p_qtyabsent      := to_number(hcm_util.convert_hour_to_minute(hcm_util.get_string(param_json_row,'timabsen')));
        v_flg            := hcm_util.get_string(param_json_row,'flg');
        --
        p_qtylate        := nvl(p_qtylate,0);
        p_qtyearly       := nvl(p_qtyearly,0);
        p_qtyabsent      := nvl(p_qtyabsent,0);
        --
        check_save_index;
        if v_flg = 'edit' then
          if param_msg_error is null then
            begin
              select a.typwork, a.codshift, a.timin, a.timout,
                     a.codchng, a.qtynostam, b.qtylate, b.qtyearly, b.qtyabsent,
                     a.dtein, a.dteout
                into p_tmp_typwork, p_tmp_codshift, p_tmp_timin, p_tmp_timout,
                     p_tmp_codchng, p_tmp_qtynostam, p_tmp_qtylate, p_tmp_qtyearly, p_tmp_qtyabsent,
                     v_tmp_dtein, v_tmp_dteout
                from tattence a, tlateabs b
               where a.codempid = b.codempid(+)
                 and a.dtework  = b.dtework(+)
                 and a.codempid = p_codempid
                 and a.dtework  = p_dtework;
            end;
            -- check change value
            if p_tmp_timin	= p_timin then
              v_timin_o := null;
              v_timin		:= null;
            else
              v_timin_o := p_tmp_timin;
              v_timin		:= p_timin;
            end if;
            --
            if p_tmp_timout = p_timout then
              v_timout_o	:= null;
              v_timout		:= null;
            else
              v_timout_o	:= p_tmp_timout;
              v_timout		:= p_timout;
            end if;
            --
            if p_tmp_codchng = p_codchng then
              v_codchng_o	:= null;
              v_codchng		:= null;
            else
              v_codchng_o	:= p_tmp_codchng;
              v_codchng		:= p_codchng;
            end if;
            --
            if p_tmp_typwork = p_typwork then
              v_typwork_o	:= null;
              v_typwork		:= null;
            else
              v_typwork_o	:= p_tmp_typwork;
              v_typwork		:= p_typwork;
            end if;
            --
            if p_tmp_codshift = p_codshift then
              v_codshift_o	:= null;
              v_codshift		:= null;
            else
              v_codshift_o	:= p_tmp_codshift;
              v_codshift		:= p_codshift;
            end if;
            --
            if p_tmp_qtynostam = p_qtynostam then
              v_qtynostam_o	:= null;
              v_qtynostam	  := null;
            else
              v_qtynostam_o	:= p_tmp_qtynostam;
              v_qtynostam	  := p_qtynostam;
              v_check       := 'Y';
            end if;
            --
            if p_tmp_qtylate = p_qtylate then
              v_qtylate_o	:= null;
              v_qtylate	  := null;
            else
              v_qtylate_o	:= p_tmp_qtylate;
              v_qtylate	  := p_qtylate;
              v_check       := 'Y';
            end if;
            --
            if p_tmp_qtyearly = p_qtyearly then
              v_qtyearly_o	:= null;
              v_qtyearly	  := null;
            else
              v_qtyearly_o	:= p_tmp_qtyearly;
              v_qtyearly	  := p_qtyearly;
              v_check       := 'Y';
            end if;
            --
            if p_tmp_qtyabsent = p_qtyabsent then
              v_qtyabsent_o	:= null;
              v_qtyabsent	  := null;
            else
              v_qtyabsent_o	:= p_tmp_qtyabsent;
              v_qtyabsent   := p_qtyabsent;
              v_check       := 'Y';
            end if;
            --
            v_dtein         := p_dtework;
            v_dteout        := p_dtework;
            if to_date(p_timin, 'HH24MI') > to_date(p_timout, 'HH24MI') then
              v_dteout      := v_dteout + 1;
            end if;
            --
            if v_tmp_dtein = v_dtein then
              v_dtein_o    := null;
              v_dtein_n    := null;
            else
              v_dtein_o    := v_tmp_dtein;
              v_dtein_n    := v_dtein;
            end if;
            --
            if v_tmp_dteout = v_dteout then
              v_dteout_o    := null;
              v_dteout_n    := null;
            else
              v_dteout_o    := v_tmp_dteout;
              v_dteout_n    := v_dteout;
            end if;

            -- check time update null
            if p_timin is null then
              v_dtein := null;
            end if;
            --
            if p_timout is null then
              v_dteout := null;
            end if;

            --
            begin
              select flgatten into  v_flgatten
                from tattence
               where codempid = p_codempid
                 and dtework  = p_dtework;
            exception when no_data_found then
              v_flgatten := null;
            end;
            --
            begin
              select qtydaywk into v_qtydaywk
                from tshiftcd
               where codshift = p_codshift;
            exception when no_data_found then v_qtydaywk := 0;
            end;
            --
            if v_qtydaywk = 0 then
               v_daylate   := 0;
               v_dayearly  := 0;
               v_dayabsent := 0;
            else
               v_daylate   := trunc(nvl(p_qtylate / v_qtydaywk,0),2);
               v_dayearly  := trunc(nvl(p_qtyearly / v_qtydaywk,0),2);
               v_dayabsent := trunc(nvl(p_qtyabsent / v_qtydaywk,0),2);
            end if;
            --
            if p_qtylate > 0 then
              v_qtytlate := 1;
            else
              v_qtytlate := 0;
            end if;
            --
            if p_qtyearly > 0 then
              v_qtytearly := 1;
            else
              v_qtytearly := 0;
            end if;
            --
            if p_qtyabsent > 0 then
              v_qtytabs := 1;
            else
              v_qtytabs := 0;
            end if;
            --
            if p_qtyabsent > 0 then
              v_qtyhwork := v_qtydaywk - p_qtyabsent;
            else
              v_qtyhwork := v_qtydaywk;
            end if;
            --
            if v_qtyhwork < 0 then
              v_qtyhwork := 0;
            end if;
            --
--            if v_timin is not null or  v_timout is not null or v_codchng is not null or
--               v_typwork is not null or v_codshift is not null or v_qtynostam is not null then
              -- update tlateabs
              update  tattence
                 set  typwork   = p_typwork,
                      codshift  = p_codshift,
                      dtestrtw  = p_dtework,
                      timstrtw  = v_timstrtw,
                      dteendw   = p_dteendw,
                      timendw   = v_timendw,
                      dtein     = v_dtein,
                      timin	    = p_timin,
                      dteout    = v_dteout,
                      timout	  = p_timout,
                      codchng	  = p_codchng,
                      qtynostam = p_qtynostam ,
                      qtyhwork  = v_qtyhwork,
                      dteupd    = trunc(sysdate),
                      coduser   = global_v_coduser
                where codempid  = p_codempid
                and   dtework   = p_dtework;
                -- insert logtime
                insert into tlogtime
                              (codempid,dtework,dteupd,codshift,coduser,codcreate,codcomp,
                               timinold,timoutold,codchngold,typworkold,codshifold,
                               timinnew,timoutnew,codchngnew,typworknew,codshifnew,
                               qtynostamo,qtynostamn, dteinold, dteoutold, dteinnew, dteoutnew)
                  values
                              (p_codempid,p_dtework,sysdate,p_codshift,global_v_coduser,global_v_coduser,p_codcomp,
                               v_timin_o,v_timout_o,v_codchng_o,v_typwork_o,v_codshift_o,
                               v_timin,v_timout,v_codchng,v_typwork,v_codshift,
                               v_qtynostam_o,v_qtynostam, v_dtein_o, v_dteout_o, v_dtein_n, v_dteout_n);
--            end if;
            --
            if v_check = 'Y' then
              -- check abnormal time is null
              v_abnormal := nvl(p_qtylate,0) + nvl(p_qtyearly,0) + nvl(p_qtyabsent,0) + nvl(p_qtynostam,0);
              if nvl(v_abnormal,0) > 0 then
                v_flginput  := 'Y';
                v_flgcalabs := 'N';
                --
                begin
                  insert into tlateabs
                              (codempid,dtework,codcomp,qtylate,qtyearly,qtyabsent,dteupd,coduser,codcreate,
                               codshift,flgatten,qtytlate,qtytearly,qtytabs,flgcalabs,qtynostam,
                               flginput,daylate,dayearly,dayabsent,flgcallate,flgcalear)
                       values (p_codempid,p_dtework,p_codcomp,p_qtylate,p_qtyearly,p_qtyabsent,sysdate,global_v_coduser,global_v_coduser,
                               p_codshift,v_flgatten,v_qtytlate,v_qtytearly,v_qtytabs,v_flgcalabs,p_qtynostam,
                               v_flginput,v_daylate,v_dayearly,v_dayabsent,'N','N');
                exception when dup_val_on_index then
                  update  tlateabs
                     set  qtylate   = p_qtylate,
                          qtyearly  = p_qtyearly,
                          qtyabsent = p_qtyabsent,
                          qtynostam = p_qtynostam,
                          flginput  = v_flginput,
                          dteupd    = sysdate,
                          coduser   = global_v_coduser
                   where  codempid  = p_codempid
                     and  dtework   = p_dtework;
                end;
                -- insert log
                insert into tloglate(dteupd,codempid,dtework,flgwork,codcomp,codshift,qtylateo,qtylaten,
                            qtyearlyo,qtyearlyn,qtyabsento,qtyabsentn,qtynostamo,qtynostamn,coduser,codcreate)
                     values(sysdate,p_codempid,p_dtework,'W',p_codcomp,p_codshift,v_qtylate_o,v_qtylate,
                            v_qtyearly_o,v_qtyearly,v_qtyabsent_o,v_qtyabsent,v_qtynostam_o,v_qtynostam,
                            global_v_coduser,global_v_coduser);
              else
                -- insert tloglate
                if p_dtework is not null then
                  if v_qtylate_o   is not null or v_qtyearly_o  is not null or
                     v_qtyabsent_o is not null or v_qtynostam_o is not null then
                    begin
                       insert into tloglate
                                  (dteupd,codempid,dtework,flgwork,codcomp,codshift,
                                   qtylateo,qtylaten,qtyearlyo,qtyearlyn,qtyabsento,qtyabsentn,qtynostamo,qtynostamn,coduser)
                            values(sysdate,p_codempid,p_dtework,'W',p_codcomp,p_codshift,
                                   v_qtylate_o,null,
                                   v_qtyearly_o,null,
                                   v_qtyabsent_o,null,
                                   v_qtynostam_o,null,global_v_coduser);
                    exception when no_data_found then null;
                    end;
                  end if;
                end if;
                -- delete tlateabs
                delete from tlateabs where codempid = p_codempid and dtework = p_dtework;
                --
              end if;
            end if;
          end if;
        end if;
      end loop;
    end if;
  end save_index;*/

  procedure check_abnormal_time is
  begin
    begin
      select hcm_util.get_codcompy(codcomp)
        into p_codcompy
        from temploy1
       where codempid = p_codempid;
    end;
    --
    if p_codshift is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codshift');
      return;
    else
      begin
        select codshift
          into p_codshift
          from tshifcom
         where codcompy = p_codcompy
           and codshift = p_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('AL0061', global_v_lang);
        return;
      end;
      --
      begin
        select timstrtw, timendw
          into v_timstrtw, v_timendw
          from tshiftcd
         where codshift = p_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codshift');
        return;
      end;
    end if;
    --
--<<user46 NXP-HR2101 fix #147 16/11/2021
--    if p_timout <= p_timin then
--      p_dteout := p_dtework + 1;
--      p_dtein  := p_dtework;
--    els
-->>
    if p_timin is null and p_timout is not null then
      p_dtein  := null;
      p_dteout := p_dtework;
    elsif p_timout is null and p_timin is not null then
      p_dtein  := p_dtework;
      p_dteout  := null;
    elsif p_timin is null and p_timout is null then
      p_dtein  := null;
      p_dteout  := null;
--<<user46 NXP-HR2101 fix #147 16/11/2021
--    else
--      p_dteout := p_dtework;
--      p_dtein  := p_dtework;
-->>
    end if;
  end;

  procedure get_abnormal_time(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_abnormal_time;
    if param_msg_error is null then
      gen_abnormal_time(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_abnormal_time;

  procedure gen_abnormal_time(json_str_output out clob) is
    obj_data          json_object_t;
    v_timlate         number;
    v_timback         number;
    v_timabsen        number;
    v_flginput        varchar2(1 char);
    rt_tcontral	      tcontral%rowtype;
    v_rec             number;
  begin
    obj_data          := json_object_t();
    v_timlate         := 0;
    v_timback         := 0;
    v_timabsen        := 0;
    v_flginput        := 'N';
    begin
  		select * into rt_tcontral
  		  from tcontral
  		 where codcompy = p_codcompy
  		  and  dteeffec = (select max(dteeffec)
  					      				 from tcontral
                          where codcompy = p_codcompy
										  	    and dteeffec <= sysdate)
			  and  rownum <= 1;
  	exception when no_data_found then
      null;
  	end;
    -- gen tlateabs

    std_al.cal_tlateabs(p_codempid,p_dtework,p_typwork,p_codshift,p_dtein,p_timin,
                        p_dteout,p_timout,global_v_coduser,'N',
                        v_timlate,v_timback,v_timabsen,v_rec);
    --
    obj_data.put('coderror', 200);
    obj_data.put('timlate', hcm_util.convert_minute_to_hour(v_timlate));
    obj_data.put('timback', hcm_util.convert_minute_to_hour(v_timback));
    obj_data.put('timabsen', hcm_util.convert_minute_to_hour(v_timabsen));
--    obj_data.put('flginput', v_flginput);
    --
    if param_msg_error is null then
			json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  end gen_abnormal_time;

  procedure save_tattence_tlateabs is
    row_tattence        tattence%rowtype;
    obj_check_dup       json_object_t := json_object_t();
    obj_check_dup_abs   json_object_t := json_object_t();
    v_abnormal          number;
    v_flgcalabs         varchar2(10);
    v_flginput          varchar2(10);
    v_timlate           number;
    v_timback           number;
    v_timabsen          number;
    v_rec               number;
  begin
    begin
      begin
        select * into row_tattence
          from tattence
         where codempid  = v_codempid
           and dtework   = v_dtework;
      exception when others then null;
      end;
      --
      -- chk duplicate tattence --
      if nvl(row_tattence.codshift, '@#') <> nvl(v_codshift, '@#') then
        obj_check_dup.put('codshift', row_tattence.codshift);
      end if;
      if nvl(to_char(row_tattence.dtestrtw, 'YYYYMMDD'), '@#') <> nvl(to_char(v_dtework, 'YYYYMMDD'), '@#') then
        obj_check_dup.put('dtestrtw', row_tattence.dtestrtw);
      end if;
      if nvl(row_tattence.timstrtw, '@#') <> nvl(v_timstrtw, '@#') then
        obj_check_dup.put('timstrtw', row_tattence.timstrtw);
      end if;
      if nvl(to_char(row_tattence.dteendw, 'YYYYMMDD'), '@#') <> nvl(to_char(v_dteendw, 'YYYYMMDD'), '@#') then
        obj_check_dup.put('dteendw', row_tattence.dteendw);
      end if;
      if nvl(row_tattence.timendw, '@#') <> nvl(v_timendw, '@#') then
        obj_check_dup.put('timendw', row_tattence.timendw);
      end if;
      if nvl(to_char(row_tattence.dtein, 'YYYYMMDD'), '@#') <> nvl(to_char(v_dtein, 'YYYYMMDD'), '@#') then
        obj_check_dup.put('dtein', row_tattence.dtein);
      end if;
      if nvl(row_tattence.timin, '@#') <> nvl(v_timin, '@#') then
        obj_check_dup.put('timin', row_tattence.timin);
      end if;
      if nvl(to_char(row_tattence.dteout, 'YYYYMMDD'), '@#') <> nvl(to_char(v_dteout, 'YYYYMMDD'), '@#') then
        obj_check_dup.put('dteout', row_tattence.dteout);
      end if;
      if nvl(row_tattence.timout, '@#') <> nvl(v_timout, '@#') then
        obj_check_dup.put('timout', row_tattence.timout);
      end if;
      if nvl(row_tattence.codchng, '@#') <> nvl(v_codchng, '@#') then
        obj_check_dup.put('codchng', row_tattence.codchng);
      end if;
      -- new --
      if nvl(row_tattence.typwork, '@#') <> nvl(v_typwork, '@#') then
        obj_check_dup.put('typwork', row_tattence.typwork);
      end if;
      if nvl(row_tattence.qtynostam, 0) <> nvl(v_qtynostam, 0) then
        obj_check_dup.put('qtynostam', row_tattence.qtynostam);
      end if;
      if nvl(row_tattence.qtyhwork, 0) <> nvl(v_qtyhwork, 0) then
        obj_check_dup.put('qtyhwork', row_tattence.qtyhwork);
      end if;
      --
      -- chk duplicate lateabs --
      if nvl(v_qtynostam, 0) > 0 then
        obj_check_dup_abs.put('qtynostam', v_qtynostam);
      end if;
      if nvl(v_qtylate, 0) > 0 then
        obj_check_dup_abs.put('qtylate', v_qtylate);
      end if;
      if nvl(v_qtyearly, 0) > 0 then
        obj_check_dup_abs.put('qtyearly', v_qtyearly);
      end if;
      if nvl(v_qtyabsent, 0) > 0 then
        obj_check_dup_abs.put('qtyabsent', v_qtyabsent);
      end if;
      --
      if obj_check_dup.get_size > 0 then
        update tattence
          set  typwork  = v_typwork,
               codshift = v_codshift,
               dtestrtw = v_dtework,
               timstrtw = v_timstrtw,
               dteendw  = v_dteendw,
               timendw  = v_timendw,
               dtein 	  = v_dtein,
               timin	  = v_timin,
               dteout	  = v_dteout,
               timout	  = v_timout,
               codchng	= v_codchng,
               qtynostam= v_qtynostam,
               qtyhwork = v_qtyhwork,
               dteupd   = trunc(sysdate),
               coduser  = global_v_coduser
         where codempid = v_codempid
           and dtework  = v_dtework;
        --
        insert into tlogtime
                    (codempid,dtework,dteupd,codshift,coduser,codcomp,codcreate,
                     dteinold,timinold,dteoutold,timoutold,codchngold,typworkold,codshifold,qtynostamo,
                     dteinnew,timinnew,dteoutnew,timoutnew,codchngnew,typworknew,codshifnew,qtynostamn)
             values
                  (v_codempid,v_dtework,v_dteupd_log,v_codshift,global_v_coduser,v_codcomp,global_v_coduser,
                   log_dtein_o,log_timin_o,log_dteout_o,log_timout_o,log_codchng_o,log_typwork_o,log_codshift_o,log_qtynostam_o,
                   log_dtein,log_timin,log_dteout,log_timout,log_codchng,log_typwork,log_codshift,log_qtynostam);
      end if;
      --
      if obj_check_dup_abs.get_size > 0 then
        -- check abnormal time is null
        v_abnormal := nvl(v_qtylate,0) + nvl(v_qtyearly,0) + nvl(v_qtyabsent,0) + nvl(v_qtynostam,0);
        if nvl(v_abnormal,0) > 0 then
--<<user46 26/11/2021 nxp-hr2101
          std_al.cal_tlateabs(v_codempid,v_dtework,v_typwork,v_codshift,v_dtein,v_timin,
                              v_dteout,v_timout,global_v_coduser,'N',
                              v_timlate,v_timback,v_timabsen,v_rec,'Y');
          if v_qtylate = v_timlate and v_qtyearly = v_timback and v_qtyabsent = v_timabsen then
            v_flginput  := 'N';
          else
            v_flginput  := 'Y';
          end if;
-->>user46 26/11/2021 nxp-hr2101
          v_flgcalabs := 'N';
          begin
            insert into tlateabs
                        (codempid,dtework,codcomp,qtylate,qtyearly,qtyabsent,dteupd,coduser,codcreate,
                         codshift,flgatten,qtytlate,qtytearly,qtytabs,flgcalabs,qtynostam,
                         flginput,daylate,dayearly,dayabsent,flgcallate,flgcalear)
                 values (v_codempid,v_dtework,v_codcomp,v_qtylate,v_qtyearly,v_qtyabsent,sysdate,global_v_coduser,global_v_coduser,
                         v_codshift,v_flgatten,v_qtytlate,v_qtytearly,v_qtytabs,v_flgcalabs,v_qtynostam,
                         v_flginput,v_daylate,v_dayearly,v_dayabsent,'N','N');
          exception when dup_val_on_index then
            update  tlateabs
               set  qtylate   = v_qtylate,
                    qtyearly  = v_qtyearly,
                    qtyabsent = v_qtyabsent,
                    qtynostam = v_qtynostam,
                    -- update 26/02/2019
                    daylate   = v_daylate,
                    dayearly  = v_dayearly,
                    dayabsent = v_dayabsent,
                    qtytlate  = v_qtytlate,
                    qtytearly = v_qtytearly,
                    qtytabs   = v_qtytabs,
                    --
                    flginput  = v_flginput,
                    dteupd    = sysdate,
                    coduser   = global_v_coduser
             where  codempid  = v_codempid
               and  dtework   = v_dtework;
          end;
          -- insert log
          insert into tloglate(dteupd,codempid,dtework,flgwork,codcomp,codshift,qtylateo,qtylaten,
                      qtyearlyo,qtyearlyn,qtyabsento,qtyabsentn,qtynostamo,qtynostamn,coduser,codcreate)
               values(v_dteupd_log,v_codempid,v_dtework,'W',v_codcomp,v_codshift,log_qtylate_o,log_qtylate,
                      log_qtyearly_o,log_qtyearly,log_qtyabsent_o,log_qtyabsent,log_qtynostam_o,log_qtynostam,
                      global_v_coduser,global_v_coduser);
        end if;
      else
        -- insert tloglate
        if v_dtework is not null then
          if v_qtylate_o   is not null or v_qtyearly_o  is not null or
             v_qtyabsent_o is not null or v_qtynostam_o is not null then
            begin
               insert into tloglate
                          (dteupd,codempid,dtework,flgwork,codcomp,codshift,
                           qtylateo,qtylaten,qtyearlyo,qtyearlyn,qtyabsento,qtyabsentn,qtynostamo,qtynostamn,coduser,codcreate)
                    values(v_dteupd_log,v_codempid,v_dtework,'W',v_codcomp,v_codshift,
                           log_qtylate_o,null,
                           log_qtyearly_o,null,
                           log_qtyabsent_o,null,
                           log_qtynostam_o,null,global_v_coduser,global_v_coduser);
            exception when no_data_found then null;
            end;
          end if;
        end if;
        -- delete tlateabs
        delete from tlateabs where codempid = v_codempid and dtework = v_dtework;
        --
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;

  procedure check_save is
    v_msg_error   varchar2(1000 char);
    v_label_name  varchar2(1000 char);
    v_datein_tmp  date;
    v_dateout_tmp date;
  begin
    begin
      select codcomp
        into   v_codcomp
        from   temploy1
        where  codempid = v_codempid;
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
      return;
    end ;
    if v_typwork is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typwork');
      return;
    end if;
    if v_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
      return;
    end if;
    -- chk 2045
    if v_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
      return;
    end if;
    --
    begin
      select codshift
        into v_codshift
        from tshifcom
       where codcompy = hcm_util.get_codcompy(v_codcomp)
         and codshift = v_codshift;
    exception when no_data_found then
      v_msg_error     := get_error_msg_php('AL0061',global_v_lang,'tshifcom');
      param_msg_error := replace(v_msg_error,'@#$%','['||'Date :'||v_dtework||']@#$%');
      return;
    end;
    -- check date in --
    if v_dtein is not null then
      v_datein_tmp := to_date(to_char(v_dtein,'dd/mm/yyyy')||to_char(to_date(v_timin,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');
      begin
        select codempid into v_codempid
          from tattence
         where codempid = v_codempid
           and dtework  = (v_dtework - 1)
           and to_date(to_char(dteout,'dd/mm/yyyy')||timout,'dd/mm/yyyyhh24mi') > v_datein_tmp;
        param_msg_error := get_error_msg_php('AL0058',global_v_lang,to_char(v_dtein,'dd/mm/yyyy'));
        return;
      exception when no_data_found then null;
      end;
    end if;
    -- check date out --
    if v_dteout is not null then
      v_dateout_tmp := to_date(to_char(v_dteout,'dd/mm/yyyy')||to_char(to_date(v_timout,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');
      begin
        select codempid into v_codempid
          from tattence
         where codempid = v_codempid
           and dtework  = (v_dtework + 1)
           and to_date(to_char(dtein,'dd/mm/yyyy')||timin,'dd/mm/yyyyhh24mi') < v_dateout_tmp;

        param_msg_error := get_error_msg_php('AL0059',global_v_lang,to_char(v_dteout,'dd/mm/yyyy'));
        return;
      exception when no_data_found then null;
      end;
    end if;
    -- user03 14/08/2019
--    begin
--      select dtein, dteout into v_dtein_o, v_dteout_o
--        from tattence
--       where codempid  = v_codempid
--         and dtework   = v_dtework;
--    exception when others then
--      null;
--    end;
    --
    begin
      select timstrtw,timendw
        into v_timstrtw,v_timendw
        from tshiftcd
       where codshift = v_codshift;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
      return;
    end;
    --
    if v_timstrtw < v_timendw then
      v_dteendw := v_dtework;
    else
      v_dteendw := v_dtework + 1;
    end if;
    --------------------------------------
    --  user03 14/08/2019
--    v_dtein       := v_dtework;
--    v_dteout      := v_dteendw;
--    --
--    if v_dteendw > v_dtework then
--      if nvl(to_number(v_timin), 0) < nvl(to_number(v_timstrtw), 0) and nvl(to_number(v_timin), 0) < nvl(to_number(v_timendw), 0) then
--        v_dtein       := v_dtework + 1;
--      end if;
--      if nvl(to_number(v_timout), 0) > nvl(to_number(v_timstrtw), 0) and nvl(to_number(v_timout), 0) > nvl(to_number(v_timendw), 0) then
--        v_dteout      := v_dtework;
--      end if;
--    else
--      if nvl(to_number(v_timout), 0) < nvl(to_number(v_timstrtw), 0) then
--        v_dteout      := v_dtework + 1;
--      end if;
--    end if;
    --
    if v_timin is null then
      v_dtein   := null;
    end if;

    if v_timout is null then
      v_dteout   := null;
    end if;
    --
    if v_dtein_o = v_dtein then
      log_dtein_o := null;
      log_dtein   := null;
    else
      log_dtein_o := v_dtein_o;
      log_dtein   := v_dtein;
    end if;
    if v_timin_o = v_timin then
      log_timin_o := null;
      log_timin		:= null;
    else
      log_timin_o := v_timin_o;
      log_timin		:= v_timin;
    end if;
    if v_dteout_o = v_dteout then
      log_dteout_o	:= null;
      log_dteout		:= null;
    else
      log_dteout_o	:= v_dteout_o;
      log_dteout		:= v_dteout;
    end if;
    if v_timout_o = v_timout then
      log_timout_o	:= null;
      log_timout		:= null;
    else
      log_timout_o	:= v_timout_o;
      log_timout		:= v_timout;
    end if;
    if v_codchng_o = v_codchng then
      log_codchng_o	:= null;
      log_codchng		:= null;
    else
      log_codchng_o	:= v_codchng_o;
      log_codchng		:= v_codchng;
    end if;
    if v_codshift_o = v_codshift then
      log_codshift_o	:= null;
      log_codshift		:= null;
    else
      log_codshift_o	:= v_codshift_o;
      log_codshift		:= v_codshift;
    end if;
    -- new --
    if v_qtynostam_o = v_qtynostam then
      log_qtynostam_o	:= null;
      log_qtynostam		:= null;
    else
      log_qtynostam_o	:= v_qtynostam_o;
      log_qtynostam		:= v_qtynostam;
    end if;
    if v_typwork_o = v_typwork then
      log_typwork_o	  := null;
      log_typwork 		:= null;
    else
      log_typwork_o	  := v_typwork_o;
      log_typwork  		:= v_typwork;
    end if;
    -- new --
    if v_qtylate_o = v_qtylate then
      log_qtylate_o   := null;
      log_qtylate	    := null;
    else
      log_qtylate_o	  := v_qtylate_o;
      log_qtylate	    := v_qtylate;
    end if;
    --
    if v_qtyearly_o = v_qtyearly then
      log_qtyearly_o	:= null;
      log_qtyearly	  := null;
    else
      log_qtyearly_o	:= v_qtyearly_o;
      log_qtyearly	  := v_qtyearly;
    end if;
    --
    if v_qtyabsent_o = v_qtyabsent then
      log_qtyabsent_o	:= null;
      log_qtyabsent	  := null;
    else
      log_qtyabsent_o	:= v_qtyabsent_o;
      log_qtyabsent   := v_qtyabsent;
    end if;

    -- check time update null
    if v_timin is null then
      v_dtein         := null;
    end if;
    --
    if v_timout is null then
      v_dteout        := null;
    end if;
    --
    begin
      select flgatten into  v_flgatten
        from tattence
       where codempid = v_codempid
         and dtework  = v_dtework;
    exception when no_data_found then v_flgatten := null;
    end;
    --
    begin
      select qtydaywk into v_qtydaywk
        from tshiftcd
       where codshift = v_codshift;
    exception when no_data_found then v_qtydaywk := 0;
    end;
    --
    if v_qtydaywk = 0 then
      v_daylate   := 0;
      v_dayearly  := 0;
      v_dayabsent := 0;
    else
      v_daylate   := nvl(v_qtylate,0) / nvl(v_qtydaywk,0);
      v_dayearly  := nvl(v_qtyearly,0) / nvl(v_qtydaywk,0);
      v_dayabsent := nvl(v_qtyabsent,0) / nvl(v_qtydaywk,0);
    end if;
    --
    if nvl(v_qtylate,0) > 0 then
      v_qtytlate := 1;
    else
      v_qtytlate := 0;
    end if;
    --
    if nvl(v_qtyearly,0) > 0 then
      v_qtytearly := 1;
    else
      v_qtytearly := 0;
    end if;
    --
    if nvl(v_qtyabsent,0) > 0 then
      v_qtytabs := 1;
    else
      v_qtytabs := 0;
    end if;
    --
    if nvl(v_qtyabsent,0) > 0 then
      v_qtyhwork := nvl(v_qtydaywk,0) - nvl(v_qtyabsent,0);
    else
      v_qtyhwork := v_qtydaywk;
    end if;
    --
    if v_qtyhwork < 0 then
      v_qtyhwork := 0;
    end if;
  end check_save;

  procedure post_index(json_str_input in clob, json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      v_dteupd_log  := sysdate;
      for i in 0..param_json.get_size-1 loop
        param_json_row  := json_object_t(hcm_util.get_json_t(param_json,to_char(i)));
        v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        v_dtework       := to_date(hcm_util.get_string_t(param_json_row,'date'),'dd/mm/yyyy');
        v_codshift_o    := hcm_util.get_string_t(param_json_row,'codshiftOld');
        v_codshift      := hcm_util.get_string_t(param_json_row,'codshift');
        v_codchng_o     := hcm_util.get_string_t(param_json_row,'codchngOld');
        v_codchng       := hcm_util.get_string_t(param_json_row,'codchng');
        v_dtein         := to_date(hcm_util.get_string_t(param_json_row,'dteinn'),'dd/mm/yyyy');
        v_dteout        := to_date(hcm_util.get_string_t(param_json_row,'dteoutn'),'dd/mm/yyyy');
        v_dtein_o       := to_date(hcm_util.get_string_t(param_json_row,'dtein'),'dd/mm/yyyy');
        v_dteout_o      := to_date(hcm_util.get_string_t(param_json_row,'dteout'),'dd/mm/yyyy');
        v_timin_o       := replace(hcm_util.get_string_t(param_json_row,'timinnOld'),':');
        v_timin         := replace(hcm_util.get_string_t(param_json_row,'timinn'),':');
        v_timout_o      := replace(hcm_util.get_string_t(param_json_row,'timoutnOld'),':');
        v_timout        := replace(hcm_util.get_string_t(param_json_row,'timoutn'),':');
        --
        v_qtynostam     := nvl(to_number(hcm_util.get_string_t(param_json_row,'qtynostam')),0);
        v_qtynostam_o   := nvl(to_number(hcm_util.get_string_t(param_json_row,'qtynostamOld')),0);
        v_typwork       := hcm_util.get_string_t(param_json_row,'typwork');
        v_typwork_o     := hcm_util.get_string_t(param_json_row,'typworkOld');
        --
        v_qtylate       := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timlate')),0));
        v_qtyearly      := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timback')),0));
        v_qtyabsent     := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timabsen')),0));
        v_qtylate_o     := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timlateOld')),0));
        v_qtyearly_o    := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timbackOld')),0));
        v_qtyabsent_o   := to_number(nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'timabsenOld')),0));
        v_qtydaywk_o    := to_number(nvl(hcm_util.get_string_t(param_json_row,'qtydaywkOld'),0));
        v_qtydaywk      := to_number(nvl(hcm_util.get_string_t(param_json_row,'qtydaywk'),0));

        if (v_qtylate + v_qtyearly + v_qtyabsent) > v_qtydaywk then
            param_msg_error := get_error_msg_php('AL0071',global_v_lang);
            exit;
        end if;
        --
        check_save;
        save_tattence_tlateabs;
      end loop;

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
  end post_index;

  procedure get_default_time(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    p_dtework           := to_date(hcm_util.get_string_t(json_obj,'p_dtework'),'ddmmyyyy');
    p_codshift          := hcm_util.get_string_t(json_obj,'p_codshift');
    p_dteinn            := to_date(hcm_util.get_string_t(json_obj,'p_dteinn'),'ddmmyyyy');

    if param_msg_error is null then
      gen_default_time(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_default_time;

  procedure gen_default_time(json_str_output out clob) is
    obj_data            json_object_t;
    v_timlate           number;
    v_timback           number;
    v_timabsen          number;
    v_flginput          varchar2(1 char);
    rt_tcontral	        tcontral%rowtype;
    v_rec               number;
    v_tshiftcd          tshiftcd%rowtype;
  begin
    obj_data          := json_object_t();
    v_timlate         := 0;
    v_timback         := 0;
    v_timabsen        := 0;
    v_flginput        := 'N';
    begin
  		select *
          into v_tshiftcd
  		  from tshiftcd
  		 where codshift = p_codshift;
  	exception when no_data_found then
      null;
  	end;

    obj_data.put('coderror', 200);
    obj_data.put('timinn', v_tshiftcd.timstrtw);
    obj_data.put('timoutn', v_tshiftcd.timendw);
    if v_tshiftcd.timendw > v_tshiftcd.timstrtw then
        obj_data.put('dteoutn', to_char(p_dteinn,'dd/mm/yyyy'));
    else
        obj_data.put('dteoutn', to_char(p_dteinn + 1,'dd/mm/yyyy'));
    end if;
    --
    if param_msg_error is null then
        json_str_output := obj_data.to_clob;
    else
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  end gen_default_time;

end HRAL3CU;

/
