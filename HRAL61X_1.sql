--------------------------------------------------------
--  DDL for Package Body HRAL61X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL61X" as
-- last update: 05/03/2018 11:05
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    -- index params
    p_codempid    := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp     := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codcalen    := upper(hcm_util.get_string_t(json_obj, 'p_codcalen'));
    p_dtestrt     := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend      := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');
    -- special
    v_text_key    := 'otrate';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    check_codcalen        TCODWORK.CODCODEC%TYPE;
  begin
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcalen is not null then
      begin
        select codcodec
          into check_codcalen
          from tcodwork
         where codcodec like p_codcalen
        fetch next 1 rows only;
      exception when no_data_found then
        check_codcalen  := null;
      end;
      if check_codcalen is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodwork');
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end check_index;

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

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
--         and dteeffec = (select max(b.dteeffec)
--                           from totratep2 b
--                          where b.codcompy = v_codcompy
--                            and b.dteeffec <= sysdate)
    order by rteotpay;
  begin
    obj_ot_col := json_object_t();
    for row_ot in max_ot_col loop
      v_max_ot_col := v_max_ot_col + 1;
      obj_ot_col.put(to_char(v_max_ot_col), row_ot.rteotpay);
    end loop;
    return obj_ot_col;
  exception
  when others then
    return json_object_t();
  end;

  procedure get_employee (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_employee(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_employee;

  procedure gen_employee (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_secur            varchar2(4000 char);
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);
    v_check_secur       boolean;
    cursor c1 is
      select a.codempid, a.codcalen, a.codcomp, a.numlvl
        from temploy1 a
       where a.codempid = nvl(p_codempid, a.codempid)
         and a.codcomp like p_codcomp || '%'
         and codcalen = nvl(p_codcalen, codcalen)
         and exists (select b.codempid
                      from tattence b
                     where b.codempid = a.codempid
                       and b.dtework  between p_dtestrt and p_dteend
                       and rownum = 1 )
    order by a.codcomp, a.codempid;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata              := 'N';
    for r1 in c1 loop
      v_check_secur     := SECUR_MAIN.SECUR2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_check_secur then
          v_flgdata            := 'Y';
          obj_data     := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codcalen', r1.codcalen);
          obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt       := v_rcnt + 1;
        end if;
    end loop;
    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_employee;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
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
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_late              number;
    v_early             number;
    v_absent            number;
    v_before            number;
    v_during            number;
    v_after             number;
    p_tmp_codempid      varchar2(100 char);
    p_tmp_dtework       date;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_codcomp           varchar2(50 char);
    v_codcomp_old       varchar2(50 char);
    v_codcalen          varchar2(50 char);
    v_codcalen_old      varchar2(50 char);
    v_desc_codcalen     varchar2(200 char);
    v_desc_codcalen_old  varchar2(200 char);
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_secur             varchar2(4000 char);
    v_timinout          varchar2(4000 char);
    v_codcompy          varchar2(50 char);
    v_max_ot_col        number := 0;
    obj_ot_col          json_object_t;
    v_ot_min            number;
    v_ot_min_oth        number;
    v_rteotpay          number;
    v_check_secur       boolean;

    v_rateot5           varchar2(100 char);
    v_rateot_min5       number;
    v_rteotpay_t        number := 0;

    v_dtework           date;
    v_coscent           varchar2(100 char);
    v_codcomp_charge    varchar2(100 char);

    param_timin         varchar2(100 char);
    param_timout        varchar2(100 char);
    v_absent_all        number :=0;
    v_late_all          number :=0;
    v_early_all         number :=0;
    v_qtymin_all        number :=0;
    v_ot1_all           number :=0;
    v_ot2_all           number :=0;
    v_ot3_all           number :=0;
    v_ot4_all           number :=0;
    v_ot5_all           number :=0;
    old_codempid        temploy1.codempid%type;

    v_codleave          varchar2(1000 char);
    v_desc_codleave     varchar2(1000 char);
    v_qtymin_lv         number; 

    cursor c1 is
      select a.codempid, a.codcalen, a.codcomp, a.numlvl
        from temploy1 a
       where a.codempid = nvl(p_codempid, a.codempid)
         and a.codcomp like p_codcomp || '%'
         and codcalen = nvl(p_codcalen, codcalen)
         and exists (select b.codempid
                      from tattence b
                     where b.codempid = a.codempid
                       and trunc(b.dtework) between p_dtestrt and p_dteend
                       and rownum = 1)
    order by a.codcalen,a.codcomp, a.codempid;

    cursor c_tattence is
      select codempid,dtework,typwork,codshift,timstrtw,timendw,timin,timout,codcomp,codchng,codcalen,rowid
        from tattence
       where codempid = p_tmp_codempid
         and dtework between p_dtestrt and p_dteend
         order by dtework;

    cursor c_tleavetr is
      select codleave,nvl(qtymin,0) qtymin
        from tleavetr
       where codempid = p_tmp_codempid
         and dtework = p_tmp_dtework
         and qtymin > 0
         order by codleave ;

--    cursor c_tatmfile is -- user3 || 13/08/2019
--      select to_char(to_date(max(timtime),'hh24mi'),'hh24:mi') timout,
--             to_char(to_date(min(timtime),'hh24mi'),'hh24:mi') timin
--        from tatmfile
--       where codempid = p_tmp_codempid
--         and trunc(dtedate)  = v_dtework
--         and flginput = 2;
       cursor c_tatmfile is -- user3 || 13/08/2019
        select to_char(to_date((timtime),'hh24mi'),'hh24:mi') timinout ,CODRECOD
          from tatmfile
         where codempid = p_tmp_codempid
           and dtedate  = v_dtework
           and flginput = 2
           order by DTETIME ;
--         and dtetime between to_date(to_char(v_dtework,'dd/mm/yyyy')||param_timin,'dd/mm/yyyyhh24:mi') -- user55
--         and to_date(to_char(v_dtework,'dd/mm/yyyy')||param_timout,'dd/mm/yyyyhh24:mi'); -- user55

  begin

    obj_row                 := json_object_t();
    v_rcnt                  := 0;

    v_codcompy              := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif p_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col            := get_ot_col(v_codcompy);
    for r1 in c1 loop
      v_flgdata           := 'Y';
      v_check_secur       := SECUR_MAIN.SECUR2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

      if v_check_secur then
        v_flgsecur       := 'Y';
          p_tmp_codempid := r1.codempid;
          param_timin    := '';
          param_timout   := '';
          for r2 in c_tattence loop
            v_flgdata        := 'Y';
            v_dtework        := r2.dtework;
            p_tmp_dtework    := r2.dtework;

            param_timin      := char_time_to_format_time(r2.timin);
            param_timout     := char_time_to_format_time(r2.timout);
            v_codcalen       := r2.codcalen;
            v_desc_codcalen  := get_tcodec_name('tcodwork', r2.codcalen, global_v_lang);
--            v_codcalen       := r1.codcalen;
--            v_desc_codcalen  := get_tcodec_name('tcodwork', r1.codcalen, global_v_lang);

            if r1.codempid <> old_codempid then
              obj_data         := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('numseq', '');
              obj_data.put('image', '');
              obj_data.put('dtestrt', to_char(p_dtestrt,'dd/mm/yyyy'));
              obj_data.put('dteend', to_char(p_dteend,'dd/mm/yyyy'));
              obj_data.put('codempid', old_codempid);
              obj_data.put('desc_codempid', get_temploy_name(old_codempid,global_v_lang));
              obj_data.put('codcalen', ''); --user36 19/01/2023
              obj_data.put('desc_codcalen', ''); --user36 19/01/2023
--              obj_data.put('codcalen', nvl(p_codcalen,v_codcalen_old));
--              obj_data.put('desc_codcalen', v_desc_codcalen_old);
              obj_data.put('codcomp', v_codcomp_old);
              obj_data.put('desc_codcomp', '');
              obj_data.put('dtework', '');
              obj_data.put('typwork', '');
              obj_data.put('codshift', '');
              obj_data.put('timstrtw', '');
              obj_data.put('timendw', '');
              obj_data.put('timin', '');
              obj_data.put('timout', '');
              obj_data.put('otkey', v_text_key);
              obj_data.put('otlen', v_rateot_length+1);
              obj_data.put('timoutc',get_label_name('HRAL61XC1', global_v_lang, '350'));
              obj_data.put('v_late', hcm_util.convert_minute_to_hour(v_late_all));
              obj_data.put('v_early', hcm_util.convert_minute_to_hour(v_early_all));
              obj_data.put('v_absent', hcm_util.convert_minute_to_hour(v_absent_all));
              obj_data.put('qtymin', hcm_util.convert_minute_to_hour(v_qtymin_all));
              obj_data.put('otrate1', hcm_util.convert_minute_to_hour(v_ot1_all));
              obj_data.put('otrate2', hcm_util.convert_minute_to_hour(v_ot2_all));
              obj_data.put('otrate3', hcm_util.convert_minute_to_hour(v_ot3_all));
              obj_data.put('otrate4', hcm_util.convert_minute_to_hour(v_ot4_all));
              obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_ot5_all));
              obj_row.put(to_char(v_rcnt), obj_data);
              if isInsertReport then
                    insert_ttemprpt(obj_data);
              end if;
              v_rcnt           := v_rcnt + 1;
              v_late_all       := 0;
              v_early_all      := 0;
              v_absent_all     := 0;
              v_qtymin_all     := 0;
              v_ot1_all        := 0;
              v_ot2_all        := 0;
              v_ot3_all        := 0;
              v_ot4_all        := 0;
              v_ot5_all        := 0;
            end if;

            old_codempid          := r1.codempid;
            v_codcalen_old        := r1.codcalen;
            v_codcomp_old         := r1.codcomp;
            v_desc_codcalen_old   := v_desc_codcalen;

            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dtestrt', to_char(p_dtestrt,'dd/mm/yyyy'));
            obj_data.put('dteend', to_char(p_dteend,'dd/mm/yyyy'));
            obj_data.put('codempid', r2.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
            obj_data.put('codcalen', r2.codcalen); --user36 19/01/2023
            obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r2.codcalen, global_v_lang)); --user36 19/01/2023
--            obj_data.put('codcalen', r1.codcalen);
--            obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
            obj_data.put('dtework', to_char(p_tmp_dtework, 'DD/MM/YYYY'));
            obj_data.put('typwork', r2.typwork);
            obj_data.put('codshift', r2.codshift);
            obj_data.put('timstrtw', char_time_to_format_time(r2.timstrtw));
            obj_data.put('timendw', char_time_to_format_time(r2.timendw));
            obj_data.put('timin', char_time_to_format_time(r2.timin));
            obj_data.put('timout', char_time_to_format_time(r2.timout));

            begin
              select nvl(qtylate,0),nvl(qtyearly,0),nvl(qtyabsent,0)
                into v_late, v_early, v_absent
                from tlateabs
               where codempid = p_tmp_codempid
                 and dtework = p_tmp_dtework;
            exception when no_data_found then
              v_late         := 0;
              v_early        := 0;
              v_absent       := 0;
            end;
            begin
              select codcomp into v_codcomp_charge
                from twkchhr
               where codempid = r2.codempid
                 and r2.dtework between dtestrt and dteend
                 and codcomp is not null
                 and dtestrt = (select max(dtestrt)
                                  from twkchhr
                                 where codempid = r2.codempid
                                   and r2.dtework between dtestrt and dteend
                                   and codcomp is not null);
            exception when no_data_found then
              v_codcomp_charge := r2.codcomp;
            end;

            begin
              select costcent into v_coscent
                from tcenter
               where codcomp = v_codcomp_charge
                 and rownum <= 1
            order by codcomp;
            exception when no_data_found then
              v_coscent := null;
            end;
            v_late_all   := v_late_all + v_late;
            v_early_all  := v_early_all + v_early;
            v_absent_all := v_absent_all + v_absent;
            obj_data.put('v_late', cal_hour_unlimited(v_late, true));
            obj_data.put('v_early', cal_hour_unlimited(v_early, true));
            obj_data.put('v_absent', cal_hour_unlimited(v_absent, true));
            obj_data.put('codcomp_charge',get_tcenter_name(v_codcomp_charge, global_v_lang));
            obj_data.put('coscent',v_coscent);
            obj_data.put('codchng', get_tcodec_name('tcodtime', r2.codchng, global_v_lang));

            --<<13/03/2021
            /*for r3 in c_tleavetr loop
              obj_data.put('codleave', r3.codleave);
              obj_data.put('desc_codleave', get_tleavecd_name(r3.codleave, global_v_lang));
              obj_data.put('qtymin', cal_hour_unlimited(r3.qtymin, true));
              v_qtymin_all := v_qtymin_all + r3.qtymin;
            end loop;*/
            v_codleave := '';
            v_desc_codleave := '';
            v_qtymin_lv := null;
            for r3 in c_tleavetr loop
              v_codleave := v_codleave|| r3.codleave||'/ ';
              v_desc_codleave := v_desc_codleave|| get_tleavecd_name(r3.codleave, global_v_lang)||'/ ';
              v_qtymin_lv := nvl(v_qtymin_lv,0) + r3.qtymin;
              v_qtymin_all := v_qtymin_all + r3.qtymin;
            end loop;
            v_codleave      := substr(v_codleave,1,length(v_codleave)-2);
            v_desc_codleave := substr(v_desc_codleave,1,length(v_desc_codleave)-2);        
            obj_data.put('codleave', v_codleave);
            obj_data.put('desc_codleave', v_desc_codleave);
            obj_data.put('qtymin', cal_hour_unlimited(v_qtymin_lv, true));
            -->>13/03/2021

            obj_data.put('otkey', v_text_key);
            obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.get_size

            v_rateot5 := null;
            v_rateot_min5 := 0;
            for i in 1..obj_ot_col.get_size loop
              v_rteotpay_t := to_number(hcm_util.get_string_t(obj_ot_col, to_char(i)));
              begin
                select nvl(sum(qtyminot), 0)
                  into v_ot_min
                  from totpaydt
                 where codempid = p_tmp_codempid
                   and dtework = p_tmp_dtework
                   and rteotpay = v_rteotpay_t;
              exception when no_data_found then
                v_ot_min      := 0;
              end;

              if i <= v_rateot_length then -- case < 5 rate
                obj_data.put(v_text_key||i, cal_hour_unlimited(v_ot_min, true));
                obj_data.put(v_text_key||'_min'||i, v_ot_min);
                if i = 1 then
                  v_ot1_all := v_ot1_all + v_ot_min;
                elsif i = 2 then
                  v_ot2_all := v_ot2_all + v_ot_min;
                elsif i = 3 then
                  v_ot3_all := v_ot3_all + v_ot_min;
                elsif i = 4 then
                  v_ot4_all := v_ot4_all + v_ot_min;
                end if;
              else  -- case >= 5 rate
                v_rateot_min5 := v_rateot_min5 + nvl(v_ot_min, 0);
                v_rateot5 := cal_hour_unlimited(v_rateot_min5, true);
                v_ot5_all := v_ot5_all + v_ot_min;
              end if;
            end loop;
            --<<13/03/2021
            v_ot_min_oth := 0;
            begin 
              select nvl(sum(qtyminot), 0)
                into v_ot_min_oth
                from totpaydt
               where codempid = p_tmp_codempid
                 and dtework = p_tmp_dtework
                 and rteotpay not in (select distinct(rteotpay)
                                        from totratep2
                                       where codcompy = v_codcompy
                                      );
              v_rateot_min5 := v_rateot_min5 + nvl(v_ot_min_oth, 0);
              v_rateot5 := cal_hour_unlimited(v_rateot_min5, true);
              v_ot5_all := v_ot5_all + v_ot_min_oth;
            exception when no_data_found then
              v_ot_min_oth := 0;
            end; 
            -->>13/03/2021
            obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
            obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
            --
--            for r5 in c_tatmfile loop
--              obj_data.put('timinc',r5.timin);   -- user3 || 13/08/2019
--              obj_data.put('timoutc',r5.timout); -- user3 || 13/08/2019
--            end loop;
            v_timinout := '';
            for r5 in c_tatmfile loop
              v_timinout :=  v_timinout || ',' || r5.CODRECOD ||'-'|| r5.timinout; -- user3 || 13/08/2019
            end loop;
            if v_timinout is not null then
              v_timinout := SUBSTR(v_timinout,2,length(v_timinout));
            end if;
            obj_data.put('timinout',v_timinout);
            --report--
              if isInsertReport then
                insert_ttemprpt(obj_data);

              end if;

            obj_data.put('numseq', to_char(v_rcnt+1));
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
          end loop;

      end if;
    end loop;

    obj_data         := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '');
    obj_data.put('image', '');
    obj_data.put('dtestrt', '');
    obj_data.put('dteend', '');
    if isInsertReport then
      obj_data.put('codempid', old_codempid);
      obj_data.put('codcalen', ''); --user36 19/01/2023
      obj_data.put('desc_codcalen', ''); --user36 19/01/2023
--      obj_data.put('codcalen', nvl(p_codcalen,v_codcalen));
--      obj_data.put('desc_codcalen', v_desc_codcalen_old);
      obj_data.put('codcomp', v_codcomp_old);
    else
      --<< user4 || 17/01/2023
      /*obj_data.put('codempid', '');
      obj_data.put('codcalen', '');
      obj_data.put('desc_codcalen', '');
      obj_data.put('codcomp', '');*/
      obj_data.put('dtestrt', to_char(p_dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(p_dteend,'dd/mm/yyyy'));
      obj_data.put('codempid', old_codempid);
      obj_data.put('desc_codempid', get_temploy_name(old_codempid,global_v_lang));
      obj_data.put('codcalen', ''); --user36 19/01/2023
      obj_data.put('desc_codcalen', ''); --user36 19/01/2023
--      obj_data.put('codcalen', nvl(p_codcalen,v_codcalen));
--      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', nvl(p_codcalen,v_codcalen), global_v_lang));
      obj_data.put('codcomp', v_codcomp_old);
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp_old, global_v_lang));
      -->> user4 || 17/01/2023
    end if;
    obj_data.put('desc_codcomp', '');
    obj_data.put('dtework', '');
    obj_data.put('typwork', '');
    obj_data.put('codshift', '');
    obj_data.put('timstrtw', '');
    obj_data.put('timendw', '');
    obj_data.put('timin', '');
    obj_data.put('timout', '');
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1);
    obj_data.put('timoutc',get_label_name('HRAL61XC1', global_v_lang, '350'));
    obj_data.put('v_late', hcm_util.convert_minute_to_hour(v_late_all));
    obj_data.put('v_early', hcm_util.convert_minute_to_hour(v_early_all));
    obj_data.put('v_absent', hcm_util.convert_minute_to_hour(v_absent_all));
    obj_data.put('qtymin', hcm_util.convert_minute_to_hour(v_qtymin_all));
    obj_data.put('otrate1', hcm_util.convert_minute_to_hour(v_ot1_all));
    obj_data.put('otrate2', hcm_util.convert_minute_to_hour(v_ot2_all));
    obj_data.put('otrate3', hcm_util.convert_minute_to_hour(v_ot3_all));
    obj_data.put('otrate4', hcm_util.convert_minute_to_hour(v_ot4_all));
    obj_data.put('otrate5', hcm_util.convert_minute_to_hour(v_ot5_all));
    obj_row.put(to_char(v_rcnt), obj_data);
    if isInsertReport then
          insert_ttemprpt(obj_data);
    end if;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tattence');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

  end check_ot_head;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
    v_codcompy          TCENTER.CODCOMPY%TYPE;
  begin
    initial_value(json_str_input);
    check_ot_head;
    if param_msg_error is null then
      gen_ot_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
    obj_data           json_object_t;
    obj_row            json_object_t;
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
    v_count            number;
    v_other            varchar2(100 char);
    v_rateot5          varchar2(100 char);
    v_ot_col           varchar2(100 char);
  begin
    obj_data            := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif p_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.get_size
--    for i in 1..obj_ot_col.get_size loop
--      obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
--    end loop;
--    for i in 1..v_rateot_length loop
--      obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
--    end loop;
    for i in 1..v_rateot_length loop
      v_ot_col := hcm_util.get_string_t(obj_ot_col, to_char(i));
      if v_ot_col is not null then
        obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
      else
        obj_data.put(v_text_key||i, ' ');
      end if;
    end loop;

    v_count  := obj_ot_col.get_size;
    v_other  := get_label_name('HRAL61XC1', global_v_lang, '310');
      v_rateot5 := null;
      if v_count > v_rateot_length then
        if v_count = v_rateot_length + 1 then
          v_rateot5 := hcm_util.get_string_t(obj_ot_col, to_char(v_rateot_length + 1));
        else
          v_rateot5 := v_other;
          end if;
      end if;
      obj_data.put(v_text_key||to_char(v_rateot_length+1), nvl(v_rateot5, v_other));

--    obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
    obj_row.put(0, obj_data);
    json_str_output := obj_row.to_clob;
  end gen_ot_head;

  procedure check_codcalen is
    check_codcalen        TCODWORK.CODCODEC%TYPE;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcalen is not null then
      begin
        select codcodec
          into check_codcalen
          from tcodwork
         where codcodec like p_codcalen
        fetch next 1 rows only;
      exception when no_data_found then
        check_codcalen  := null;
      end;
      if check_codcalen is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodwork');
        return;
      end if;
    end if;
  end check_codcalen;

  procedure get_codcalen (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_codcalen(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codcalen;

  procedure gen_codcalen (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    cursor c1 is
      select a.codcalen, count(a.codempid) employee
        from temploy1 a
       where a.codempid = nvl(p_codempid, a.codempid)
         and a.codcomp like p_codcomp || '%'
         and codcalen = nvl(p_codcalen, codcalen)
         and exists (select b.codempid
                      from tattence b
                     where b.codempid = a.codempid
                       and b.dtework between p_dtestrt and p_dteend
                       and rownum = 1)
    group by a.codcalen
    order by a.codcalen;
  begin
    obj_data        := json_object_t();
    v_rcnt          := 0;
    for r1 in c1 loop
      v_flgdata     := 'Y';
      obj_row       := json_object_t();
      obj_row.put('coderror', 200);
      obj_row.put('codcomp', p_codcomp);
      obj_row.put('codcalen', r1.codcalen);
      obj_row.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
      obj_row.put('employee', r1.employee);

      obj_data.put(to_char(v_rcnt), obj_row);
      v_rcnt        := v_rcnt + 1;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end gen_codcalen;

  procedure get_codempid_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_codempid_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codempid_detail;

  procedure gen_codempid_detail (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number;
    v_flddata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    cursor c1 is
      select a.codcalen
        from temploy1 a
       where a.codempid = nvl(p_codempid, a.codempid)
         and a.codcomp like p_codcomp || '%'
         and codcalen = nvl(p_codcalen, codcalen)
         and exists (select b.codempid
                      from tattence b
                     where b.codempid = a.codempid
                       and trunc(b.dtework) between p_dtestrt and p_dteend
                       and rownum = 1)
    group by a.codcalen
    order by a.codcalen;
  begin
    obj_data          := json_object_t();
    for r1 in c1 loop
      obj_data.put('coderror', 200);
      obj_data.put('codcalen', r1.codcalen);
      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
      exit;
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_codempid_detail;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codcalen          := upper(hcm_util.get_string_t(json_obj, 'p_codcalen'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    v_text_key          := 'otrate';
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      gen_index(json_output);
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

--  procedure insert_ttemprpt_head(obj_data in json_object_t) is
--    v_numseq            number := 0;
--    v_year              number := 0;
--    v_dtestrt           varchar2(100 char) := '';
--    v_dteend            varchar2(100 char) := '';
--    v_count             number;
--    v_other             varchar2(100 char);
--    v_rateot            arr_1d;
--  begin
--    v_year       := hcm_appsettings.get_additional_year;
--    v_dtestrt    := to_char(p_dtestrt, 'DD/MM/') || (to_number(to_char(p_dtestrt, 'YYYY')) + v_year);
--    v_dteend     := to_char(p_dteend, 'DD/MM/') || (to_number(to_char(p_dteend, 'YYYY')) + v_year);
--    begin
--      select nvl(max(numseq), 0)
--        into v_numseq
--        from ttemprpt
--       where codempid = p_codempid
--         and codapp   = p_codapp;
--    exception when no_data_found then
--      null;
--    end;
--    v_numseq      := v_numseq + 1;
--    v_count       := hcm_util.get_string_t(obj_data, 'otlen');
--    v_other       := get_label_name('HRAL61XC1', global_v_lang, '310');
--
--    for i_rateot in 1..v_rateot_length+1 loop
--      v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
--    end loop;
--
--    begin
--      insert
--       into ttemprpt
--           ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6,
--             item7, item8, item9, item10, item11
--           )
--      values
--           (
--             p_codempid, p_codapp, v_numseq,
--             nvl(hcm_util.get_string_t(obj_data, 'codempid'), ''),
--             nvl(hcm_util.get_string_t(obj_data, 'codcalen'), ''),
--             nvl(hcm_util.get_string_t(obj_data, 'desc_codcalen'), ''),
--             nvl(hcm_util.get_string_t(obj_data, 'codcomp'), ''),
--             nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), ''),
--             v_dtestrt || ' - ' || v_dteend,
--             v_rateot(1), v_rateot(2), v_rateot(3), v_rateot(4), v_rateot(5)
--           );
--    exception when others then
--      null;
--    end;
--  end insert_ttemprpt_head;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dtestrt           varchar2(100 char) := '';
    v_dteend            varchar2(100 char) := '';
    v_dtework           date;
    v_dtework_          varchar2(100 char) := '';
    v_count             number;
    v_other             number := 0;
    v_rateot            arr_1d;

    v_codempid          varchar2(100 char) := '';
    v_codcomp           temploy1.codcomp%type;
    v_desc_codempid     varchar2(1000 char) := '';
    v_codcalen          varchar2(100 char) := '';
    v_desc_codcalen     varchar2(1000 char) := '';
    v_typwork           varchar2(1000 char) := '';
    v_codshift          varchar2(1000 char) := '';
    v_timstrtw          varchar2(1000 char) := '';
    v_timendw           varchar2(1000 char) := '';
    v_timin             varchar2(1000 char) := '';
    v_timout            varchar2(1000 char) := '';
    v_late              varchar2(1000 char) := '';
    v_early             varchar2(1000 char) := '';
    v_absent            varchar2(1000 char) := '';
    v_codchng           varchar2(1000 char) := '';
    v_desc_codleave     varchar2(1000 char) := '';
    v_qtymin            varchar2(1000 char) := '';
    v_timinc            varchar2(1000 char) := '';
    v_timoutc           varchar2(1000 char) := '';
    v_codcomp_charge    varchar2(1000 char) := '';
    v_coscent           varchar2(1000 char) := '';
    v_timinout          varchar2(1000 char) := '';
    v_emp_image         varchar2(600);
    v_flg_img           varchar2(1) := 'N';
    v_folder            varchar2(600);

  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dtestrt    := to_char(p_dtestrt, 'DD/MM/') || (to_number(to_char(p_dtestrt, 'YYYY')) + v_year);
    v_dteend     := to_char(p_dteend, 'DD/MM/') || (to_number(to_char(p_dteend, 'YYYY')) + v_year);
    v_dtework    := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework_   := to_char(v_dtework, 'DD/MM/') || (to_number(to_char(v_dtework, 'YYYY')) + v_year);
    --v_count      := hcm_util.get_string_t(obj_data, 'otlen');
    v_codempid       := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_codcomp        := nvl(hcm_util.get_string_t(obj_data, 'codcomp'), '');
    v_desc_codempid  := get_temploy_name(hcm_util.get_string_t(obj_data, 'codempid'), global_v_lang);
    begin
      select codcalen into v_codcalen
      from   temploy1
      where  codempid = v_codempid;
    exception when others then null;
    end; --user36 19/01/2023
    v_desc_codcalen  := get_tcodec_name('tcodwork', v_codcalen, global_v_lang); --user36 19/01/2023
--    v_codcalen       := nvl(hcm_util.get_string_t(obj_data, 'codcalen'), ''); 
--    v_desc_codcalen  := nvl(hcm_util.get_string_t(obj_data, 'desc_codcalen'), ''); 
    v_typwork        := nvl(hcm_util.get_string_t(obj_data, 'typwork'), '');
    v_codshift       := nvl(hcm_util.get_string_t(obj_data, 'codshift'), '');
    v_timstrtw       := nvl(hcm_util.get_string_t(obj_data, 'timstrtw'), '');
    v_timendw        := nvl(hcm_util.get_string_t(obj_data, 'timendw'), '');
    v_timin          := nvl(hcm_util.get_string_t(obj_data, 'timin'), '');
    v_timout         := nvl(hcm_util.get_string_t(obj_data, 'timout'), '');
    v_late           := nvl(hcm_util.get_string_t(obj_data, 'v_late'), '');
    v_early          := nvl(hcm_util.get_string_t(obj_data, 'v_early'), '');
    v_absent         := nvl(hcm_util.get_string_t(obj_data, 'v_absent'), '');
    v_codchng        := nvl(hcm_util.get_string_t(obj_data, 'codchng'), '');
    v_desc_codleave  := nvl(hcm_util.get_string_t(obj_data, 'desc_codleave'), '');
    v_qtymin         := nvl(hcm_util.get_string_t(obj_data, 'qtymin'), '');
    v_timinc         := nvl(hcm_util.get_string_t(obj_data, 'timinc'), '');
    v_timoutc        := nvl(hcm_util.get_string_t(obj_data, 'timoutc'), '');
    v_codcomp_charge := nvl(hcm_util.get_string_t(obj_data, 'codcomp_charge'), '');
    v_coscent        := nvl(hcm_util.get_string_t(obj_data, 'coscent'), '');
    v_timinout       := nvl(hcm_util.get_string_t(obj_data, 'timinout'), '');
    v_emp_image      := get_emp_img(v_codempid);
    v_folder         := get_tfolderd('HRPMC2E1');
    

    for i_rateot in 1..v_rateot_length+1 loop
      v_rateot(i_rateot) := hcm_util.get_string_t(obj_data, v_text_key||i_rateot);
    end loop;
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
      
    if v_emp_image is not null then
      v_emp_image   := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_emp_image;
      v_flg_img     := 'Y';
    end if;

      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3, item4,item5, item6, item7, item8, item9, item10, item11, item12,
               item13, item14, item15, item16, item17, item18, item19, item20,
               item21, item22, item23, item24, item25,
               item26, item27, item28, item29, item30, item31, item32
             )
        values
             ( global_v_codempid, p_codapp, v_numseq,
               v_codempid,
               v_desc_codempid,
--               v_codempid || ' - ' || v_desc_codempid,
               v_codcalen,
               v_codcalen || ' - ' || v_desc_codcalen,
               p_codcomp,
--               nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), ''),
               get_tcenter_name(p_codcomp, global_v_lang),
               v_dtestrt || ' - ' || v_dteend,
               v_dtework_,
               v_typwork,
               v_codshift,
               v_timstrtw,
               v_timendw,
               v_timin,
               v_timout,
               v_late,
               v_early,
               v_absent,
               v_codchng,
               v_desc_codleave,
               v_qtymin,
               v_rateot(1), v_rateot(2), v_rateot(3), v_rateot(4), v_rateot(5),
               v_timinout,
               v_timoutc,
               v_codcomp_charge,
               v_coscent,
               v_codcomp,
               v_emp_image,v_flg_img
        );
      exception when others then
        null;
      end;
  end insert_ttemprpt;

end HRAL61X;

/
