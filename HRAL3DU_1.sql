--------------------------------------------------------
--  DDL for Package Body HRAL3DU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3DU" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_dtework     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    p_codchng     := hcm_util.get_string_t(json_obj,'p_codchng');
    p_timinst     := replace(hcm_util.get_string_t(json_obj,'p_timinst'),':');
    p_timinen     := replace(hcm_util.get_string_t(json_obj,'p_timinen'),':');
    p_timoutst    := replace(hcm_util.get_string_t(json_obj,'p_timoutst'),':');
    p_timouten    := replace(hcm_util.get_string_t(json_obj,'p_timouten'),':');
    p_timinnew    := hcm_util.get_string_t(json_obj,'p_timinnew');
    p_timoutnew   := hcm_util.get_string_t(json_obj,'p_timoutnew');

  end initial_value;

  procedure check_index is
  begin
    if p_codcalen is not null then
      begin
        select codcodec
        into   p_codcalen
        from   tcodwork
        where  codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcalen');
        return;
      end;
    end if;
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
    if param_msg_error is not null then
      return;
    end if;
    if p_dtework is null  then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtework');
      return;
    end if;
    if (p_timinst is not null) and (p_timinen is not null) then
      if to_number(p_timinst) > to_number(p_timinen) then
        param_msg_error := get_error_msg_php('HR2014',global_v_lang,'timinst');
        return;
      end if;
    end if;
    if p_timoutst is not null and p_timouten is not null then
      if to_number(p_timoutst) > to_number(p_timouten) then
        param_msg_error := get_error_msg_php('HR2014',global_v_lang,'timoutst');
        return;
      end if;
    end if;
  end check_index;

  procedure check_save is
    v_msg_error   varchar2(1000 char);
    v_label_name  varchar2(1000 char);
  begin
    -- chk 2045
    if v_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
      return;
    end if;
--    if v_timin is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timin');
--      return;
--    end if;
--    if v_timout is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timout');
--      return;
--    end if;
--    if v_timin is null and v_timout is null then
--      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'timenew');
--      return;
--    end if;
    --chk 2010
    if v_codchng is not null then
      begin
        select codcodec
        into   v_codchng
        from   tcodtime
        where  codcodec = v_codchng;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codchng');
        return;
      end;
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codchng');
      return;
    end if;
    -- chk 2020
--    if to_timestamp(v_dtein||' '||v_timin,'dd/mm/yyyyhh24mi') > to_timestamp(v_dteout||' '||v_timout,'dd/mm/yyyyhh24mi') then
--      param_msg_error := get_error_msg_php('HR2020',global_v_lang,'dtein');
--      return;
--    end if;
    begin
      select codshift
        into v_codshift
        from tshifcom
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and codshift = v_codshift;
    exception when no_data_found then
      v_msg_error     := get_error_msg_php('AL0061',global_v_lang,'tshifcom');
      v_label_name    := get_label_name('HRAL3DUC1',global_v_lang,'100');
      param_msg_error := replace(v_msg_error,'@#$%','['||v_label_name||':'||v_codempid||']@#$%');
      return;
    end;

    begin
      select timstrtw,timendw
        into v_timstrtw,v_timendw
        from tshiftcd
       where codshift = v_codshift;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
      return;
    end;
    if v_timstrtw < v_timendw then
      v_dteendw := v_dtework;
    else
      v_dteendw := v_dtework + 1;
    end if;
    --------------------------------------
--    v_dtein       := v_dtework;
--    v_dteout      := v_dteendw;
  end check_save;

  procedure save_tattence is
    row_tattence        tattence%rowtype;
    obj_check_dup       json_object_t := json_object_t();
    v_qtytlate          number := 0;
    v_qtytearly         number := 0;
    v_qtytabs           number := 0;
    v_abnormal          number;
    v_flgcalabs         varchar2(10);
    v_flginput          varchar2(1 char);
    v_qtydaywk          number := 0;
    v_daylate           number := 0;
    v_dayearly          number := 0;
    v_dayabsent         number := 0;
    v_qtynostam         number := 0;
    v_qtynostam_o       number := 0;
    v_flgatten          tattence.flgatten%type;
    log_qtylate         number;
    log_qtylate_o       number;
    log_qtyearly        number;
    log_qtyearly_o      number;
    log_qtyabsent       number;
    log_qtyabsent_o     number;
    log_qtynostam       number;
    log_qtynostam_o     number;

    v_codcompy          tcompny.codcompy%type;
    rt_tcontral	        tcontral%rowtype;
    v_typwork           tattence.typwork%type;
    v_rec               number;
  begin
    begin
      select *
        into row_tattence
        from tattence
       where codempid = v_codempid
         and dtework = v_dtework;
      --
      v_dtein       := v_dtework;
      v_dteout      := v_dteendw;
      v_qtynostam   := row_tattence.qtynostam;
      v_typwork     := row_tattence.typwork;
      v_flgatten    := row_tattence.flgatten;

      v_codcompy    := hcm_util.get_codcomp_level(v_codcomp,1);
      begin
        select * into rt_tcontral
          from tcontral
         where codcompy = v_codcompy
          and  dteeffec = (select max(dteeffec)
                             from tcontral
                            where codcompy = v_codcompy
                              and dteeffec <= sysdate)
          and  rownum <= 1;
      exception when no_data_found then
        null;
      end;

      std_al.cal_tlateabs(v_codempid,v_dtework,v_typwork,v_codshift,v_dtein,v_timin,
                          v_dteout,v_timout,global_v_coduser,'N',
                          v_qtylate,v_qtyearly,v_qtyabsent,v_rec);

      std_al.cal_tlateabs(v_codempid,v_dtework,v_typwork,v_codshift_o,v_dtein,v_timin_o,
                          v_dteout,v_timout_o,global_v_coduser,'N',
                          v_qtylate_o,v_qtyearly_o,v_qtyabsent_o,v_rec);
      --
      if v_dteendw > p_dtework then
        if nvl(to_number(v_timin), 0) < nvl(to_number(v_timstrtw), 0) and nvl(to_number(v_timin), 0) < nvl(to_number(v_timendw), 0) then
          v_dtein       := p_dtework + 1;
        end if;
        if nvl(to_number(v_timout), 0) > nvl(to_number(v_timstrtw), 0) and nvl(to_number(v_timout), 0) > nvl(to_number(v_timendw), 0) then
          v_dteout      := p_dtework;
        end if;
      else
        if nvl(to_number(v_timin), 0) > nvl(to_number(v_timendw), 0) then
          v_dtein       := p_dtework - 1;
        end if;
        if nvl(to_number(v_timout), 0) < nvl(to_number(v_timstrtw), 0) then
          v_dteout      := p_dtework + 1;
        end if;
      end if;

      if v_timin is null then
         v_dtein := null ;
      end if;
      if v_timout is null then
         v_dteout := null ;
      end if;

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
      if obj_check_dup.get_size > 0 then
        update tattence
          set  codshift = v_codshift,
               dtestrtw = v_dtework,
               timstrtw = v_timstrtw,
               dteendw  = v_dteendw,
               timendw  = v_timendw,
               dtein 	  = v_dtein,
               timin	  = v_timin,
               dteout	  = v_dteout,
               timout	  = v_timout,
               codchng	= v_codchng,
               dteupd   = trunc(sysdate),
               coduser  = global_v_coduser
         where codempid = v_codempid
           and dtework  = v_dtework;
      end if;

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

      if v_qtylate > 0 then
        v_qtytlate  := 1;
      else
        v_qtytlate  := 0;
      end if;
      --
      if v_qtyearly > 0 then
        v_qtytearly := 1;
      else
        v_qtytearly := 0;
      end if;
      --
      if v_qtyabsent > 0 then
        v_qtytabs   := 1;
      else
        v_qtytabs   := 0;
      end if;

      -- new --
      if v_qtynostam_o = v_qtynostam then
        log_qtynostam_o	:= null;
        log_qtynostam		:= null;
      else
        log_qtynostam_o	:= v_qtynostam_o;
        log_qtynostam		:= v_qtynostam;
      end if;
      --
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

      insert into tlogtime
                  (codempid,dtework,dteupd,codshift,coduser,codcomp,codcreate,
                   dteinold,timinold,dteoutold,timoutold,codshifold,
                   dteinnew,timinnew,dteoutnew,timoutnew,codshifnew,
                   codchngold,codchngnew)
           values
                (v_codempid,v_dtework,v_dteupd_log,v_codshift,global_v_coduser,v_codcomp,global_v_coduser,
                 log_dtein_o,log_timin_o,log_dteout_o,log_timout_o,log_codshift_o,
                 log_dtein,log_timin,log_dteout,log_timout,log_codshift,
                 v_codchng_o,v_codchng);

      v_abnormal := nvl(v_qtylate,0) + nvl(v_qtyearly,0) + nvl(v_qtyabsent,0) + nvl(v_qtynostam,0);
      if nvl(v_abnormal,0) > 0 then
        v_flginput  := 'Y';
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
      else
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
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		      number := 0;
    v_secur       varchar2(4000 char);
    v_timin       varchar2(10 char);
    v_timout      varchar2(10 char);
    v_timinnew    varchar2(10 char);
    v_timoutnew   varchar2(10 char);
    cursor c1 is
      select codempid,codshift,codcomp,dtein,timin,dteout,timout,codchng
        from tattence
       where codcomp like p_codcomp||'%'
         and codcalen = nvl(p_codcalen,codcalen)
         and dtework  = p_dtework
         and (timin between p_timinst and p_timinen or p_timinst is null)
         and (timout between p_timoutst and p_timouten or p_timoutst is null)
    order by codempid;

  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_row := json_object_t();
      for i in c1 loop
        v_secur := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,i.codempid);
        if v_secur is null then
          v_row := v_row + 1;
          obj_data := json_object_t();

          if i.timin is null then
            v_timin := null;
          else
            v_timin := substr(i.timin,1,2)||':'||substr(i.timin,3,2);
          end if;
          if i.timout is null then
            v_timout := null;
          else
            v_timout := substr(i.timout,1,2)||':'||substr(i.timout,3,2);
          end if;
          if p_timinnew is null then
            v_timinnew := null;
          else
            v_timinnew := substr(p_timinnew,1,2)||':'||substr(p_timinnew,3,2);
          end if;
          if p_timoutnew is null then
            v_timoutnew := null;
          else
            v_timoutnew := substr(p_timoutnew,1,2)||':'||substr(p_timoutnew,3,2);
          end if;

          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('codshift',i.codshift);
          obj_data.put('codshiftnew',i.codshift);
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('dtein',to_char(i.dtein,'dd/mm/yyyy'));
          obj_data.put('timin',v_timin);
          obj_data.put('dteout',to_char(i.dteout,'dd/mm/yyyy'));
          obj_data.put('timout',v_timout);
          obj_data.put('timinnew',v_timinnew);
          obj_data.put('timoutnew',v_timoutnew);
          obj_data.put('codchngold',i.codchng);
          obj_data.put('desc_codchngold',i.codchng||' - '||get_tcodec_name('TCODTIME',i.codchng,global_v_lang));
          obj_data.put('codchngnew',p_codchng);

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;

      if v_row > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tattence');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_index_update(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		      number := 0;
    v_secur       varchar2(4000 char);
    v_timin       varchar2(10 char);
    v_timout      varchar2(10 char);
    v_timinnew    varchar2(10 char);
    v_timoutnew   varchar2(10 char);
    v_codchngnew    tattence.codchng%type;

    l_data          aarray;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_codempid      TEMPLOY1.CODEMPID%TYPE;
    cursor c1 is
      select codempid,codshift,codcomp,dtein,timin,dteout,timout,codchng
        from tattence
       where codcomp like p_codcomp||'%'
         and codcalen = nvl(p_codcalen,codcalen)
         and dtework  = p_dtework
         and (timin between p_timinst and p_timinen or p_timinst is null)
         and (timout between p_timoutst and p_timouten or p_timoutst is null)
    order by codempid;

  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      param_json := hcm_util.get_json_t(json_object_t(json_str_input), 'param_json');
      for i in 0..param_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid       := hcm_util.get_string_t(param_json_row,'codempid');
        l_data(v_codempid) := 1;
      end loop;
      obj_row := json_object_t();
      for i in c1 loop
        v_secur := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,i.codempid);
        if v_secur is null then
          v_row := v_row + 1;
          obj_data := json_object_t();

          if i.timin is null then
            v_timin := null;
          else
            v_timin := substr(i.timin,1,2)||':'||substr(i.timin,3,2);
          end if;
          if i.timout is null then
            v_timout := null;
          else
            v_timout := substr(i.timout,1,2)||':'||substr(i.timout,3,2);
          end if;

          if l_data.exists(i.codempid) then
            v_timinnew      := substr(i.timin,1,2)||':'||substr(i.timin,3,2);
            v_timoutnew     := substr(i.timout,1,2)||':'||substr(i.timout,3,2);
            v_codchngnew    := i.codchng;
          else
            v_timinnew      := substr(p_timinnew,1,2)||':'||substr(p_timinnew,3,2);
            v_timoutnew     := substr(p_timoutnew,1,2)||':'||substr(p_timoutnew,3,2);
            v_codchngnew    := p_codchng;
          end if;
          if v_timinnew = ':' then
            v_timinnew  := null;
          end if;
          if v_timoutnew = ':' then
            v_timoutnew := null;
          end if;

          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('codshift',i.codshift);
          obj_data.put('codshiftnew',i.codshift);
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('dtein',to_char(i.dtein,'dd/mm/yyyy'));
          obj_data.put('timin',v_timin);
          obj_data.put('dteout',to_char(i.dteout,'dd/mm/yyyy'));
          obj_data.put('timout',v_timout);
          obj_data.put('timinnew',v_timinnew);
          obj_data.put('timoutnew',v_timoutnew);
          obj_data.put('codchngold',i.codchng);
          obj_data.put('desc_codchngold',i.codchng||' - '||get_tcodec_name('TCODTIME',i.codchng,global_v_lang));--<<user25 Date: 08/10/2021 #6065
--        obj_data.put('desc_codchngold',i.codchng||' - '||get_tlistval_name('CODCHNG',i.codchng,global_v_lang));--<<user25 Date: 08/10/2021 #6065
          obj_data.put('codchngnew',v_codchngnew);

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;

      json_str_output := obj_row.to_clob;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_update;
  --
  procedure save_data(json_str_input in clob, json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      v_dteupd_log  := sysdate;
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        v_dtework       := p_dtework;
        v_codshift_o    := hcm_util.get_string_t(param_json_row,'codshift');
        v_codshift      := nvl(hcm_util.get_string_t(param_json_row,'codshiftnew'),v_codshift_o);
        v_codchng_o     := hcm_util.get_string_t(param_json_row,'codchngold');
        v_codchng       := hcm_util.get_string_t(param_json_row,'codchngnew');
        v_dtein_o       := to_date(trim(hcm_util.get_string_t(param_json_row,'dtein')),'dd/mm/yyyy');
        v_timin_o       := replace(hcm_util.get_string_t(param_json_row,'timin'),':');
        v_timin         := replace(nvl(hcm_util.get_string_t(param_json_row,'timinnew'),v_timin_o),':');
        v_dteout_o      := to_date(trim(hcm_util.get_string_t(param_json_row,'dteout')),'dd/mm/yyyy');
        v_dteout        := v_dteout_o;
        v_timout_o      := replace(hcm_util.get_string_t(param_json_row,'timout'),':');
        v_timout        := replace(nvl(hcm_util.get_string_t(param_json_row,'timoutnew'),v_timout_o),':');

        check_save;
        save_tattence;

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
  end save_data;

end HRAL3DU;

/
