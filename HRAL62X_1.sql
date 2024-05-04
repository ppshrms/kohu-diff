--------------------------------------------------------
--  DDL for Package Body HRAL62X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL62X" as
-- last update: 06/03/2018 09:40
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid       := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp        := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_typabs         := upper(hcm_util.get_string_t(json_obj, 'p_typabs'));
    p_inquir         := upper(hcm_util.get_string_t(json_obj, 'p_inquir'));
    p_overlimit_tim  := hcm_util.get_string_t(json_obj, 'p_overlimit_tim');
    p_overlimit_hou  := hcm_util.get_string_t(json_obj, 'p_overlimit_hou');
    p_overlimit_min  := hcm_util.get_string_t(json_obj, 'p_overlimit_min');
    p_continuation_d := hcm_util.get_string_t(json_obj, 'p_continuation_d');
    p_dtestrt        := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend         := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'DD/MM/YYYY');

    p_tot_min        := (p_overlimit_hou * 60) + p_overlimit_min;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_typabs is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_inquir is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    else
      if p_inquir = '1' and nvl(p_overlimit_tim, 0) < 0 then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      elsif p_inquir = '2' and nvl(p_tot_min, 0) < 0 then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      elsif p_inquir = '3' and nvl(p_continuation_d, 0) < 0 then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

  function check_continue (v_codempid varchar2, v_case number) return number is
    v_qtyday    number := 0;
    v_qtydaymax number := 0;
    v_dtework   date;
    v_qty       number := 0;
    v_cur_date  date;
    cursor c_continue is
          select dtework,qtylate,qtyearly,qtyabsent,qtynostam
            from tlateabs
           where codempid = v_codempid
             and dtework between p_dtestrt and p_dteend
             and (
                   (nvl(qtylate,0)   > 0 and '1' = v_case)
                  or (nvl(qtyearly,0)  > 0 and '2' = v_case)
                  or (nvl(qtyabsent,0) > 0 and '3' = v_case)
                       )
      order by codempid;
  begin
    v_qtyday    := 0;
    v_qtydaymax := 0;
    for c1 in c_continue loop
      v_dtework := nvl(v_dtework,c1.dtework);

      if v_dtework <> c1.dtework then
        begin
          select count(*)
            into v_qty
            from tattence
           where codempid = v_codempid
             and dtework between v_dtework and c1.dtework
             and typwork in ('H','T');
        end;
        if v_qty <> trunc(c1.dtework - v_dtework) then
          v_qtyday    := 0;
        end if;
        v_dtework   := c1.dtework;
      end if;
      v_qtyday    := v_qtyday  + 1;
      v_dtework   := v_dtework + 1;
      if v_qtyday = 1 then
        v_cur_date := (v_dtework - 1);
      end if;

      if v_qtydaymax < v_qtyday then
        v_min_dtework := v_cur_date;
        v_max_dtework := (v_dtework - 1);

      end if;
      v_qtydaymax := greatest(v_qtydaymax,v_qtyday);
    end loop;
    return nvl(v_qtydaymax, 0);
  end;

  function char_time_to_format_time (p_tim varchar2) return varchar2 is
  begin
    if p_tim is not null then
      return substr(p_tim, 1, 2) || ':' || substr(p_tim, 3, 2);
    else
      return p_tim;
    end if;
  exception when others then
    return p_tim;
  end;

  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_min, 0) > 0 then
      v_hou_display        := trunc(p_min / 60);
      v_min_display        := lpad(mod(p_min, 60), 2, '0');
      return v_hou_display || ':' || v_min_display;
    else
      if p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
  exception when others then
    return p_min;
  end;

  function cal_times_count (p_tim number) return varchar2 is
  begin
    if nvl(p_tim, 0) > 0 then
      return p_tim;
    else
      return '';
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_data              varchar2(1 char);
    v_codcomp           varchar2(50 char);
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_check_secur       boolean;
    cursor c1 is
      select b.codempid, b.codcomp, b.numlvl, b.codpos,
             nvl(sum(a.qtylate), 0)    qtylate,    nvl(sum(a.daylate), 0)    daylate,     nvl(sum(a.qtytlate), 0)   qtytlate,
             nvl(sum(a.qtyearly), 0)   qtyearly,   nvl(sum(a.dayearly), 0)   dayearly,    nvl(sum(a.qtytearly), 0)  qtytearly,
             nvl(sum(a.qtyabsent), 0)  qtyabsent,  nvl(sum(a.dayabsent), 0)  dayabsent,   nvl(sum(a.qtytabs), 0)    qtytabs,
             nvl(sum(a.qtynostam), 0)  qtynostam
        from tlateabs a, temploy1 b
       where a.codempid = b.codempid
         and b.codcomp like p_codcomp || '%'
         and b.staemp <> '0'
         and trunc(a.dtework) between p_dtestrt and p_dteend
    group by b.codempid, b.codcomp, b.numlvl, b.codpos
    order by b.codcomp, b.codempid;
  begin
    obj_row               := json_object_t();
    v_rcnt                := 0;

    for r1 in c1 loop
      if v_flgdata = 'N' then
        <<cal_loop_data>>
        loop

          if p_typabs in ('1', '5') then
            if (p_inquir = '1' and r1.qtytlate > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtylate > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 1) > p_continuation_d) then
              v_flgdata  := 'Y'; exit cal_loop_data;
            end if;
          end if;
          if p_typabs in ('2', '5') then
            if (p_inquir = '1' and r1.qtytearly > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtyearly > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 2) > p_continuation_d) then
              v_flgdata  := 'Y'; exit cal_loop_data;
            end if;
          end if;
          if p_typabs in ('3', '5') then
            if (p_inquir = '1' and r1.qtytabs > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtyabsent > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 3) > p_continuation_d) then
              v_flgdata  := 'Y'; exit cal_loop_data;
            end if;
          end if;
          if p_typabs in ('4', '5') then
            if (p_inquir = '1' and r1.qtynostam > p_overlimit_tim)
            or (p_inquir = '3' and check_continue(r1.codempid, 3) > p_continuation_d) --25/11/2020
                then
              v_flgdata  := 'Y'; exit cal_loop_data;
            end if;
          end if;
          exit cal_loop_data;
        end loop;
      end if;

      v_check_secur      := SECUR_MAIN.SECUR2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_data := 'N';
        <<cal_loop_secur>>
        loop
          if p_typabs in ('1', '5') then
            if (p_inquir = '1' and r1.qtytlate > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtylate > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 1) > p_continuation_d) then
              v_data  := 'Y'; exit cal_loop_secur;
            end if;
          end if;
          if p_typabs in ('2', '5') then
            if (p_inquir = '1' and r1.qtytearly > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtyearly > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 2) > p_continuation_d) then
              v_data  := 'Y'; exit cal_loop_secur;
            end if;
          end if;
          if p_typabs in ('3', '5') then
            if (p_inquir = '1' and r1.qtytabs > p_overlimit_tim)
            or (p_inquir = '2' and r1.qtyabsent > p_tot_min)
            or (p_inquir = '3' and check_continue(r1.codempid, 3) > p_continuation_d) then
              v_data  := 'Y'; exit cal_loop_secur;
            end if;
          end if;
          if p_typabs in ('4', '5') then
            if (p_inquir = '1' and r1.qtynostam > p_overlimit_tim)
            or (p_inquir = '3' and check_continue(r1.codempid, 3) > p_continuation_d) --25/11/2020
                then
              v_data  := 'Y'; exit cal_loop_secur;
            end if;
          end if;
          exit cal_loop_secur;
        end loop;

        if v_data = 'Y' then
          v_flgsecur := 'Y';
          obj_data     := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpos', r1.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('qtylate', cal_hour_unlimited(r1.qtylate, true));
          obj_data.put('qtytlate', cal_times_count(r1.qtytlate));
          obj_data.put('qtyearly', cal_hour_unlimited(r1.qtyearly, true));
          obj_data.put('qtytearly', cal_times_count(r1.qtytearly));
          obj_data.put('qtyabsent', cal_hour_unlimited(r1.qtyabsent, true));
          obj_data.put('qtytabs', cal_times_count(r1.qtytabs));
          obj_data.put('qtynostam', cal_times_count(r1.qtynostam));
          obj_data.put('flgbreak', '');
          obj_data.put('dtestrt', to_char(p_dtestrt,'dd/mm/yyyy'));
          obj_data.put('dteend', to_char(p_dteend, 'dd/mm/yyyy'));
          obj_data.put('typabs', p_typabs);
          obj_data.put('inquir',p_inquir);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt       := v_rcnt + 1;
        end if;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlateabs');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
      if v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        json_str_output := obj_row.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure check_popup_detail is
  begin
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_inquir is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    else
      if p_inquir = '1' and nvl(p_overlimit_tim, 0) < 0 then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      else
        if p_inquir = '2' and nvl(p_tot_min, 0) < 0 then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          return;
        else
          if p_inquir = '3' and nvl(p_continuation_d, 0) < 0 then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
          end if;
        end if;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_popup_detail;

  procedure get_detail_popup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_popup_detail;
    if param_msg_error is null then
      gen_detail_popup(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_popup;

  procedure gen_detail_popup (json_str_output out clob) is
    obj_row            json;
    obj_data           json;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_data             varchar2(1 char);
    v_timstrtw         varchar2(10 char);
    v_timendw          varchar2(10 char);
    v_timin            varchar2(10 char);
    v_timout           varchar2(10 char);
    timinout           varchar2(100 char);
    timinouts          varchar2(100 char);
    v_secur            varchar2(4000 char);
    v_codpos           temploy1.codpos%type;
    v_codcomp          temploy1.codcomp%type;
    v_codempid         temploy1.codempid%type;

    cursor c_tlateabs is
      select codempid,dtework,
             qtylate,daylate,qtytlate,
             qtyearly,dayearly,qtytearly,
             qtyabsent,dayabsent,qtytabs,qtynostam
        from tlateabs
       where codempid = p_codempid
         and dtework between p_dtestrt and p_dteend
    order by dtework asc;
  begin
    obj_row          := json();
    v_rcnt           := 0;
    for c1 in c_tlateabs loop
        v_flgdata := 'Y';
        exit;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlateabs');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata := 'N';
    for c1 in c_tlateabs loop
      v_data         := 'N';
      if p_inquir = '3' then
        if (p_typabs in ('1', '5') and check_continue(c1.codempid, 1) > p_continuation_d)
        or (p_typabs in ('2', '5') and check_continue(c1.codempid, 2) > p_continuation_d)
        or (p_typabs in ('3', '5') and check_continue(c1.codempid, 3) > p_continuation_d) then
          if c1.dtework between v_min_dtework and v_max_dtework then
            v_data     := 'Y';
          end if;
        end if;
      else
        v_data       := 'Y';
      end if;

      if v_data = 'Y' then
        v_flgdata            := 'Y';

        timinout             := '';
        timinouts            := '';
        begin
          select a.timstrtw,a.timendw,a.timin,a.timout
            into v_timstrtw,v_timendw,v_timin,v_timout
            from tattence a
           where a.codempid = c1.codempid
             and a.dtework = c1.dtework
             and rownum <= 1;

        exception when no_data_found then
          v_timstrtw := '0000';
          v_timendw  := '0000';
          v_timin    := '0000';
          v_timout   := '0000';
        end;

        v_timstrtw   := char_time_to_format_time(v_timstrtw);
        v_timendw    := char_time_to_format_time(v_timendw);
        v_timin      := char_time_to_format_time(v_timin);
        v_timout     := char_time_to_format_time(v_timout);
        timinout     := v_timstrtw || ' - ' || v_timendw;
        timinouts    := v_timin || ' - ' || v_timout;

        begin
          select codcomp, codpos
            into v_codcomp, v_codpos
            from temploy1
           where codempid = c1.codempid;
        exception when no_data_found then
          null;
        end;

        obj_data             := json();
        obj_data.put('coderror', '200');
        obj_data.put('dtework', to_char(c1.dtework, 'DD/MM/YYYY'));
        obj_data.put('timinout', timinout);
        obj_data.put('timinouts', timinouts);
        obj_data.put('timstrtw', v_timstrtw);
        obj_data.put('timendw', v_timendw);
        obj_data.put('timin', v_timin);
        obj_data.put('timout', v_timout);
        obj_data.put('timlate', cal_hour_unlimited(c1.qtylate, true));
        obj_data.put('timback', cal_hour_unlimited(c1.qtyearly, true));
        obj_data.put('timabsent', cal_hour_unlimited(c1.qtyabsent, true));
        obj_data.put('qtyfrgtpass', cal_times_count(c1.qtynostam));
        obj_data.put('codempid', c1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(c1.codempid, global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp, null), global_v_lang));
        obj_data.put('codcomp', v_codcomp);

        --
        if isInsertReport and nvl(v_codempid, '@#$%') <> c1.codempid then
          insert_ttemprpt_main(obj_data);
        end if;
        if isInsertReport then
          insert_ttemprpt(obj_data);
        end if;
        v_codempid := c1.codempid;
        --
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt               := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'Y' then
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail_popup;

  procedure initial_report(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json(json_obj, 'p_index_rows');

  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_index_rows.count-1 loop
        p_index_rows      := hcm_util.get_json(json_index_rows, to_char(i));
        p_codempid        := hcm_util.get_string(p_index_rows, 'codempid');
        p_dtestrt         := to_date(hcm_util.get_string(p_index_rows, 'dtestrt'), 'DD/MM/YYYY');
        p_dteend          := to_date(hcm_util.get_string(p_index_rows, 'dteend'), 'DD/MM/YYYY');
        p_typabs          := hcm_util.get_string(p_index_rows, 'typabs');
        p_inquir          := hcm_util.get_string(p_index_rows, 'inquir');

        gen_detail_popup(json_output);
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
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_main(obj_data in json) is
    v_numseq            number := 0;
    p_data_rows         json;
    obj_data_table      json;
    v_codempid          varchar2(1000 char) := '';
    v_desc_codempid     varchar2(1000 char) := '';
    v_desc_codcomp      varchar2(1000 char) := '';
    v_desc_codpos       varchar2(1000 char) := '';
    v_codcomp           varchar2(1000 char) := '';

  begin
    v_codempid       := nvl(hcm_util.get_string(obj_data, 'codempid'), ' ');
    v_desc_codempid  := nvl(hcm_util.get_string(obj_data, 'desc_codempid'), ' ');
    v_desc_codcomp   := nvl(hcm_util.get_string(obj_data, 'desc_codcomp'), ' ');
    v_desc_codpos    := nvl(hcm_util.get_string(obj_data, 'desc_codpos'), ' ');
    v_codcomp        := nvl(hcm_util.get_string(obj_data, 'codcomp'), ' ');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    --
    v_numseq := v_numseq + 1;
    p_codapp := 'HRAL62X';
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6,item7,item8
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codempid,
             v_desc_codempid,
             v_desc_codcomp,
             v_desc_codpos,
             v_codcomp,
             null,null,null
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt_main;

  procedure insert_ttemprpt(obj_data in json) is
    v_numseq            number := 0;
    p_data_rows         json;
    obj_data_table      json;
    v_year              number := 0;
    v_dtework           date;
    v_dtework_          varchar2(100 char) := '';
    v_codempid          varchar2(1000 char) := '';
    v_timstrtw    			varchar2(1000 char) := '';
    v_timendw     			varchar2(1000 char) := '';
    v_timin       			varchar2(1000 char) := '';
    v_timout            varchar2(1000 char) := '';
    v_timlate           varchar2(1000 char) := '';
    v_timback           varchar2(1000 char) := '';
    v_timabsent         varchar2(1000 char) := '';
    v_qtyfrgtpass       varchar2(1000 char) := '';

  begin
   v_codempid        := nvl(hcm_util.get_string(obj_data, 'codempid'), ' ');
   v_timstrtw        := nvl(hcm_util.get_string(obj_data, 'timstrtw'), ' ');
   v_timendw         := nvl(hcm_util.get_string(obj_data, 'timendw'), ' ');
   v_timin        	 := nvl(hcm_util.get_string(obj_data, 'timin'), ' ');
   v_timout          := nvl(hcm_util.get_string(obj_data, 'timout'), ' ');
   v_timlate         := nvl(hcm_util.get_string(obj_data, 'timlate'), ' ');
   v_timback         := nvl(hcm_util.get_string(obj_data, 'timback'), ' ');
   v_timabsent       := nvl(hcm_util.get_string(obj_data, 'timabsent'), ' ');
   v_qtyfrgtpass     := nvl(hcm_util.get_string(obj_data, 'qtyfrgtpass'), ' ');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_year      := hcm_appsettings.get_additional_year;
    v_dtework   := to_date(hcm_util.get_string(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework_  := to_char(v_dtework, 'DD/MM/') || (to_number(to_char(v_dtework, 'YYYY')) + v_year);

    -- insert table --
    v_numseq := v_numseq + 1;
    p_codapp := 'HRAL62X1';
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4,item5, item6, item7, item8, item9, item10
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_codempid,
             v_dtework_,
             v_timstrtw,
             v_timendw,
             v_timin,
             v_timout,
             v_timlate,
             v_timback,
             v_timabsent,
             v_qtyfrgtpass
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt;

end HRAL62X;

/
