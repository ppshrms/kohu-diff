--------------------------------------------------------
--  DDL for Package Body HRAL16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL16E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
  --test
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codshift  := hcm_util.get_string_t(json_obj,'p_codshift');

    p_codshift    := hcm_util.get_string_t(json_obj,'codshift');
    p_desshift    := hcm_util.get_string_t(json_obj,'desc_codshift');
    p_desshifte   := hcm_util.get_string_t(json_obj,'desshifte');
    p_desshiftt   := hcm_util.get_string_t(json_obj,'desshiftt');
    p_desshift3   := hcm_util.get_string_t(json_obj,'desshift3');
    p_desshift4   := hcm_util.get_string_t(json_obj,'desshift4');
    p_desshift5   := hcm_util.get_string_t(json_obj,'desshift5');
    p_qtydaywk    := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtydaywk'));
    p_grpshift    := hcm_util.get_string_t(json_obj,'grpshift');
    p_timstrtw    := hcm_util.get_string_t(json_obj,'timstrtw');
    p_timendw     := hcm_util.get_string_t(json_obj,'timendw');
    p_timstrtb    := hcm_util.get_string_t(json_obj,'timstrtb');
    p_timendb     := hcm_util.get_string_t(json_obj,'timendb');
    p_stampinst   := hcm_util.get_string_t(json_obj,'stampinst');
    p_stampinen   := hcm_util.get_string_t(json_obj,'stampinen');
    p_stampoutst  := hcm_util.get_string_t(json_obj,'stampoutst');
    p_stampouten  := hcm_util.get_string_t(json_obj,'stampouten');
    p_timstotd    := hcm_util.get_string_t(json_obj,'timstotd');
    p_timenotd    := hcm_util.get_string_t(json_obj,'timenotd');
    p_timstotdb   := hcm_util.get_string_t(json_obj,'timstotdb');
    p_timenotdb   := hcm_util.get_string_t(json_obj,'timenotdb');
    p_timstotb    := hcm_util.get_string_t(json_obj,'timstotb');
    p_timenotb    := hcm_util.get_string_t(json_obj,'timenotb');
    p_timstota    := hcm_util.get_string_t(json_obj,'timstota');
    p_timenota    := hcm_util.get_string_t(json_obj,'timenota');
    p_qtywkfull   := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtywkfull'));

    json_params   := hcm_util.get_json_t(json_obj, 'json_input_str');

  end initial_value;
  --
  procedure check_index is
    v_secur         boolean := false;
    v_timstrtw2     varchar2(8 char);
    v_timstota2     varchar2(8 char);
    v_timstrtb2     varchar2(20 char);
    v_timendb2      varchar2(20 char);
    v_dtest         varchar2(20 char);
    v_dteen         varchar2(20 char);
    v_numot         number := 0;
    v_numb          number := 0;
  begin
--  hcm_util.convert_hour_to_minute('5:00')

    if p_qtydaywk is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtydaywk');
      return;
    end if;
    if p_qtydaywk <= 0 then
      param_msg_error := get_error_msg_php('HR2024',global_v_lang);
      return;
    end if;
    if p_qtydaywk > 1440 then
      param_msg_error := get_error_msg_php('HR2015',global_v_lang,'qtydaywk');
      return;
    end if;
    if p_timstrtw is not null then
      v_timstrtw2 := p_timstrtw;
      p_timstrtw  := replace(p_timstrtw,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstrtw');
      return;
    end if;
    if p_timendw is not null then
      p_timendw	:= replace(p_timendw,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timendw');
      return;
    end if;
    if p_timstrtb is not null then
      v_timstrtb2 := p_timstrtb;
      p_timstrtb := replace(p_timstrtb,':');
    end if;
    if p_timendb is not null then
      v_timendb2 := p_timendb;
      p_timendb	:= replace(p_timendb,':');
    end if;
    if p_stampinst is not null then
      p_stampinst := replace(p_stampinst,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stampinst');
      return;
    end if;
    if p_stampinen is not null then
      p_stampinen	:= replace(p_stampinen,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stampinen');
      return;
    end if;
    if p_stampoutst is not null then
      p_stampoutst := replace(p_stampoutst,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stampoutst');
      return;
    end if;
    if p_stampouten is not null then
      p_stampouten	:= replace(p_stampouten,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stampouten');
      return;
    end if;
    if p_timstotd is not null then
      p_timstotd := replace(p_timstotd,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstotd');
      return;
    end if;
    if p_timenotd is not null then
      p_timenotd	:= replace(p_timenotd,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timenotd');
      return;
    end if;
    if p_timstotdb is not null then
      p_timstotdb := replace(p_timstotdb,':');
    end if;
    if p_timenotdb is not null then
      p_timenotdb	:= replace(p_timenotdb,':');
    end if;
    if p_timstotb is not null then
      p_timstotb := replace(p_timstotb,':');
    end if;
    if p_timenotb is not null then
      p_timenotb	:= replace(p_timenotb,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timenotb');
      return;
    end if;
    if p_timstota is not null then
      v_timstota2 := p_timstota;
      p_timstota  := replace(p_timstota,':');
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstota');
      return;
    end if;
    if p_timenota is not null then
      p_timenota := replace(p_timenota,':');
    end if;

    v_dtest := to_char(to_date(to_char(sysdate,'DD/MM/YYYY')|| ' '||v_timstrtw2,'DD/MM/YYYY hh24:mi'),'DD/MM/YYYY hh24:mi');

    v_dteen  := to_char(to_date(to_char(sysdate,'DD/MM/YYYY')|| ' '||v_timstota2,'DD/MM/YYYY hh24:mi'),'DD/MM/YYYY hh24:mi');

    v_timstrtb2 := to_char(to_date(to_char(sysdate,'DD/MM/YYYY')|| ' '||v_timstrtb2,'DD/MM/YYYY hh24:mi'),'DD/MM/YYYY hh24:mi');
    v_timendb2  := to_char(to_date(to_char(sysdate,'DD/MM/YYYY')|| ' '||v_timendb2,'DD/MM/YYYY hh24:mi'),'DD/MM/YYYY hh24:mi');

    v_numb := abs(trunc(60 *(24 *(to_date(v_timstrtb2, 'DD/MM/YYYY hh24:mi') - to_date(v_timendb2, 'DD/MM/YYYY hh24:mi')))));

    if hcm_util.convert_hour_to_minute(v_timstrtw2)>hcm_util.convert_hour_to_minute(v_timstota2) then
       v_dteen  := to_char(to_date(to_char(sysdate+1,'DD/MM/YYYY')|| ' '||v_timstota2,'DD/MM/YYYY hh24:mi'),'DD/MM/YYYY hh24:mi');
    end if;
    v_numot := abs(60 *(24 * (to_date(v_dtest, 'DD/MM/YYYY hh24:mi') - to_date(v_dteen, 'DD/MM/YYYY hh24:mi'))));

--    if p_qtywkfull > 0 and (p_qtywkfull  < (v_numot - v_numb)) then
--       param_msg_error := replace(get_error_msg_php('AL0075',global_v_lang),'xxx',floor((v_numot - v_numb)/60)||':'||lpad(to_char(mod(v_numot - v_numb,60)),2,'0'));
--       return;
--    end if;

  end check_index;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row		    number := 0;
    cursor c1 is
        select codshift,timstrtw,timendw
          from tshiftcd
      order by codshift;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();

    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codshift',i.codshift);
      obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift,global_v_lang));
      obj_data.put('timshift',substr(i.timstrtw,1,2)||':'||substr(i.timstrtw,3,2)||'-'||substr(i.timendw,1,2)||':'||substr(i.timendw,3,2));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
  --
  procedure gen_detail(json_str_output out clob) as
    obj_row       json_object_t;
    v_qtydaywk    number;
--    v_brkflexi    number;
    v_timstrtw    varchar2(8 char);
    v_timendw     varchar2(8 char);
    v_timstrtb    varchar2(8 char);
    v_timendb     varchar2(8 char);
    v_stampinst   varchar2(8 char);
    v_stampinen   varchar2(8 char);
    v_stampoutst  varchar2(8 char);
    v_stampouten  varchar2(8 char);
    v_timstotd    varchar2(8 char);
    v_timenotd    varchar2(8 char);
    v_timstotdb   varchar2(8 char);
    v_timenotdb   varchar2(8 char);
    v_timstotb    varchar2(8 char);
    v_timenotb    varchar2(8 char);
    v_timstota    varchar2(8 char);
    v_timenota    varchar2(8 char);
    v_grpshift    varchar2(4 char);
    v_qtywkfull   number;

  begin
    begin
      select qtydaywk,/*'' brkflexi,*/timstrtw,timendw,timstrtb,timendb,stampinst,
             stampinen,stampoutst,stampouten,timstotd,timenotd,timstotdb,
             timenotdb,timstotb,timenotb,timstota,timenota,qtywkfull,grpshift
        into v_qtydaywk,/*v_brkflexi,*/v_timstrtw,v_timendw,v_timstrtb,v_timendb,v_stampinst,
             v_stampinen,v_stampoutst,v_stampouten,v_timstotd,v_timenotd,v_timstotdb,
             v_timenotdb,v_timstotb,v_timenotb,v_timstota,v_timenota,v_qtywkfull,v_grpshift
        from tshiftcd
       where codshift = b_index_codshift;
    exception when no_data_found then
      v_qtydaywk    := null;
--      v_brkflexi    := null;
      v_timstrtw    := null;
      v_timendw     := null;
      v_timstrtb    := null;
      v_timendb     := null;
      v_stampinst   := null;
      v_stampinen   := null;
      v_stampoutst  := null;
      v_stampouten  := null;
      v_timstotd    := null;
      v_timenotd    := null;
      v_timstotdb   := null;
      v_timenotdb   := null;
      v_timstotb    := null;
      v_timenotb    := null;
      v_timstota    := null;
      v_timenota    := null;
      v_grpshift    := null;
      v_qtywkfull   := null;
    end;

    if v_timstrtw is not null then
      v_timstrtw := substr(v_timstrtw,1,2)||':'||substr(v_timstrtw,3,2);
    end if;
    if v_timendw is not null then
      v_timendw	:= substr(v_timendw,1,2)||':'||substr(v_timendw,3,2);
    end if;
    if v_timstrtb is not null then
      v_timstrtb := substr(v_timstrtb,1,2)||':'||substr(v_timstrtb,3,2);
    end if;
    if v_timendb is not null then
      v_timendb	:= substr(v_timendb,1,2)||':'||substr(v_timendb,3,2);
    end if;
    if v_stampinst is not null then
      v_stampinst := substr(v_stampinst,1,2)||':'||substr(v_stampinst,3,2);
    end if;
    if v_stampinen is not null then
      v_stampinen	:= substr(v_stampinen,1,2)||':'||substr(v_stampinen,3,2);
    end if;
    if v_stampoutst is not null then
      v_stampoutst := substr(v_stampoutst,1,2)||':'||substr(v_stampoutst,3,2);
    end if;
    if v_stampouten is not null then
      v_stampouten	:= substr(v_stampouten,1,2)||':'||substr(v_stampouten,3,2);
    end if;
    if v_timstotd is not null then
      v_timstotd := substr(v_timstotd,1,2)||':'||substr(v_timstotd,3,2);
    end if;
    if v_timenotd is not null then
      v_timenotd	:= substr(v_timenotd,1,2)||':'||substr(v_timenotd,3,2);
    end if;
    if v_timstotdb is not null then
      v_timstotdb := substr(v_timstotdb,1,2)||':'||substr(v_timstotdb,3,2);
    end if;
    if v_timenotdb is not null then
      v_timenotdb	:= substr(v_timenotdb,1,2)||':'||substr(v_timenotdb,3,2);
    end if;
    if v_timstotb is not null then
      v_timstotb := substr(v_timstotb,1,2)||':'||substr(v_timstotb,3,2);
    end if;
    if v_timenotb is not null then
      v_timenotb	:= substr(v_timenotb,1,2)||':'||substr(v_timenotb,3,2);
    end if;
    if v_timstota is not null then
      v_timstota := substr(v_timstota,1,2)||':'||substr(v_timstota,3,2);
    end if;
    if v_timenota is not null then
      v_timenota	:= substr(v_timenota,1,2)||':'||substr(v_timenota,3,2);
    end if;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codshift',b_index_codshift);
    obj_row.put('desc_codshift',get_tshiftcd_name(b_index_codshift,global_v_lang));
    obj_row.put('desc_codshifte',get_tshiftcd_name(b_index_codshift,101));
    obj_row.put('desc_codshiftt',get_tshiftcd_name(b_index_codshift,102));
    obj_row.put('desc_codshift3',get_tshiftcd_name(b_index_codshift,103));
    obj_row.put('desc_codshift4',get_tshiftcd_name(b_index_codshift,104));
    obj_row.put('desc_codshift5',get_tshiftcd_name(b_index_codshift,105));
    obj_row.put('qtydaywk', hcm_util.convert_minute_to_hour(v_qtydaywk));
--    obj_row.put('brkflexi', v_brkflexi);
    obj_row.put('grpshift', v_grpshift);
    obj_row.put('desc_grpshift', get_tcodec_name('tcodflex',v_grpshift,global_v_lang));
    obj_row.put('timstrtw', v_timstrtw);
    obj_row.put('timendw', v_timendw);
    obj_row.put('timstrtb', v_timstrtb);
    obj_row.put('timendb', v_timendb);
    obj_row.put('stampinst', v_stampinst);
    obj_row.put('stampinen', v_stampinen);
    obj_row.put('stampoutst', v_stampoutst);
    obj_row.put('stampouten', v_stampouten);
    obj_row.put('timstotd', v_timstotd);
    obj_row.put('timenotd', v_timenotd);
    obj_row.put('timstotdb', v_timstotdb);
    obj_row.put('timenotdb', v_timenotdb);
    obj_row.put('timstotb', v_timstotb);
    obj_row.put('timenotb', v_timenotb);
    obj_row.put('timstota', v_timstota);
    obj_row.put('timenota', v_timenota);
    obj_row.put('qtywkfull', hcm_util.convert_minute_to_hour(v_qtywkfull));

    if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_row);
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;
  --
  procedure save_data(json_str_input in clob, json_str_output out clob) is
    v_desshifte   varchar2(150 char);
    v_desshiftt   varchar2(150 char);
    v_desshift3   varchar2(150 char);
    v_desshift4   varchar2(150 char);
    v_desshift5   varchar2(150 char);
  begin
    initial_value(json_str_input);
    check_index;
--    begin
--  		select desshifte,desshiftt,desshift3,desshift4,desshift5
--        into v_desshifte,v_desshiftt,v_desshift3,v_desshift4,v_desshift5
--        from tshiftcd
--       where codshift = p_codshift;
--    exception when no_data_found then
--      v_desshifte := null;
--      v_desshiftt := null;
--      v_desshift3 := null;
--      v_desshift4 := null;
--      v_desshift5 := null;
--    end;

--    if global_v_lang = '101' then
--      v_desshifte := p_desshift;
--    elsif global_v_lang = '102' then
--      v_desshiftt := p_desshift;
--    elsif global_v_lang = '103' then
--      v_desshift3 := p_desshift;
--    elsif global_v_lang = '104' then
--      v_desshift4 := p_desshift;
--    elsif global_v_lang = '105' then
--      v_desshift5 := p_desshift;
--    end if;

    if param_msg_error is null then
        if p_qtywkfull = 0 then
            p_qtywkfull := null;
        end if;
      begin
        insert into tshiftcd(codshift,desshifte,desshiftt,desshift3,desshift4,desshift5,
                             qtydaywk,grpshift,timstrtw,timendw,timstrtb,timendb,stampinst,
                             stampinen,stampoutst,stampouten,timstotd,timenotd,timstotdb,
                             timenotdb,timstotb,timenotb,timstota,timenota,qtywkfull,codcreate, coduser)
                     values (p_codshift,p_desshifte,p_desshiftt,p_desshift3,p_desshift4,p_desshift5,
                             p_qtydaywk,p_grpshift,p_timstrtw,p_timendw,p_timstrtb,p_timendb,p_stampinst,
                             p_stampinen,p_stampoutst,p_stampouten,p_timstotd,p_timenotd,p_timstotdb,
                             p_timenotdb,p_timstotb,p_timenotb,p_timstota,p_timenota,p_qtywkfull,global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        begin
          update  tshiftcd
          set     desshifte   = p_desshifte,
                  desshiftt   = p_desshiftt,
                  desshift3   = p_desshift3,
                  desshift4   = p_desshift4,
                  desshift5   = p_desshift5,
                  qtydaywk    = p_qtydaywk,
                  grpshift    = p_grpshift,
                  timstrtw    = p_timstrtw,
                  timendw     = p_timendw,
                  timstrtb    = p_timstrtb,
                  timendb     = p_timendb,
                  stampinst   = p_stampinst,
                  stampinen   = p_stampinen,
                  stampoutst  = p_stampoutst,
                  stampouten  = p_stampouten,
                  timstotd    = p_timstotd,
                  timenotd    = p_timenotd,
                  timstotdb   = p_timstotdb,
                  timenotdb   = p_timenotdb,
                  timstotb    = p_timstotb,
                  timenotb    = p_timenotb,
                  timstota    = p_timstota,
                  timenota    = p_timenota,
                  qtywkfull   = p_qtywkfull,
                  dteupd      = trunc(sysdate),
                  coduser     = global_v_coduser
          where   codshift = p_codshift;
        exception when others then
          rollback;
        end;
      end;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;
   --
  procedure delete_data(json_str_input in clob,json_str_output out clob) is
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      for i in 0..json_params.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(json_params, to_char(i));
        p_codshift      := hcm_util.get_string_t(param_json_row,'codshift');

        begin
          delete from tshiftcd
                where codshift = p_codshift;
        exception when others then
          null;
        end;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_data;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_codshift       := hcm_util.get_json_t(json_obj, 'p_codshift');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_codshift.get_size-1 loop
        b_index_codshift := hcm_util.get_string_t(json_codshift, to_char(i));
        gen_detail(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_codshift      		varchar2(1000 char) := '';
    v_desc_codshift  		varchar2(1000 char) := '';
    v_qtydaywk       		varchar2(1000 char) := '';
    v_grpshift      		varchar2(1000 char) := '';
    v_desc_grpshift     varchar2(1000 char) := '';
    v_timstrtw    			varchar2(1000 char) := '';
    v_timendw    	  		varchar2(1000 char) := '';
    v_timstrtb    	  	varchar2(1000 char) := '';
    v_timendb    	  	  varchar2(1000 char) := '';
    v_stampinst    	  	varchar2(1000 char) := '';
    v_stampinen    	  	varchar2(1000 char) := '';
    v_stampoutst    	  varchar2(1000 char) := '';
    v_stampouten    	  varchar2(1000 char) := '';
    v_timstotd    	  	varchar2(1000 char) := '';
    v_timenotd    	  	varchar2(1000 char) := '';
    v_timstotdb    	  	varchar2(1000 char) := '';
    v_timenotdb    	  	varchar2(1000 char) := '';
    v_timstotb    	  	varchar2(1000 char) := '';
    v_timenotb    	  	varchar2(1000 char) := '';
    v_timstota    	  	varchar2(1000 char) := '';
    v_timenota    	  	varchar2(1000 char) := '';
    v_qtywkfull    	  	varchar2(1000 char) := '';
  begin
    v_codshift       			:= nvl(hcm_util.get_string_t(obj_data, 'codshift'), '');
    v_desc_codshift   		:= nvl(hcm_util.get_string_t(obj_data, 'desc_codshift'), ' ');
    v_qtydaywk       			:= nvl(hcm_util.get_string_t(obj_data, 'qtydaywk'), '');
    v_grpshift      			:= nvl(hcm_util.get_string_t(obj_data, 'grpshift'), '');
    v_timstrtw      			:= nvl(hcm_util.get_string_t(obj_data, 'timstrtw'), '');
    v_timendw      				:= nvl(hcm_util.get_string_t(obj_data, 'timendw'), '');
    v_timstrtb      			:= nvl(hcm_util.get_string_t(obj_data, 'timstrtb'), '');
    v_timendb      				:= nvl(hcm_util.get_string_t(obj_data, 'timendb'), '');
    v_stampinst      			:= nvl(hcm_util.get_string_t(obj_data, 'stampinst'), '');
    v_stampinen      			:= nvl(hcm_util.get_string_t(obj_data, 'stampinen'), '');
    v_stampoutst      		:= nvl(hcm_util.get_string_t(obj_data, 'stampoutst'), '');
    v_stampouten      		:= nvl(hcm_util.get_string_t(obj_data, 'stampouten'), '');
    v_timstotd      			:= nvl(hcm_util.get_string_t(obj_data, 'timstotd'), '');
    v_timenotd      			:= nvl(hcm_util.get_string_t(obj_data, 'timenotd'), '');
    v_timstotdb      			:= nvl(hcm_util.get_string_t(obj_data, 'timstotdb'), '');
    v_timenotdb      			:= nvl(hcm_util.get_string_t(obj_data, 'timenotdb'), '');
    v_timstotb      			:= nvl(hcm_util.get_string_t(obj_data, 'timstotb'), '');
    v_timenotb      			:= nvl(hcm_util.get_string_t(obj_data, 'timenotb'), '');
    v_timstota      			:= nvl(hcm_util.get_string_t(obj_data, 'timstota'), '');
    v_timenota      			:= nvl(hcm_util.get_string_t(obj_data, 'timenota'), '');
    v_qtywkfull      			:= nvl(hcm_util.get_string_t(obj_data, 'qtywkfull'), '');
    v_desc_grpshift      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_grpshift'), '');

    if v_grpshift is null then
      v_grpshift := ' ';
    end if;
    if v_desc_grpshift is null then
      v_desc_grpshift := ' ';
    end if;
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, /*item4,*/ item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15,
             item16, item17, item18, item19, item20,
             item21, item22, item23
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
              v_codshift,
              v_desc_codshift,
              v_qtydaywk,
              /*nvl(hcm_util.get_string(obj_data, 'brkflexi'), ''), */
              v_grpshift,
              v_timstrtw,
              v_timendw,
              v_timstrtb,
              v_timendb,
              v_stampinst,
              v_stampinen,
              v_stampoutst,
              v_stampouten,
              v_timstotd,
              v_timenotd,
              v_timstotdb,
              v_timenotdb,
              v_timstotb,
              v_timenotb,
              v_timstota,
              v_timenota,
              v_qtywkfull,
              v_desc_grpshift
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt;

end HRAL16E;

/
