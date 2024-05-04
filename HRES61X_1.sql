--------------------------------------------------------
--  DDL for Package Body HRES61X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES61X" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    --v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    --global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempidQuery'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_codcalen          := upper(hcm_util.get_string_t(json_obj,'p_codcalen'));
    p_month             := hcm_util.get_string_t(json_obj,'p_month');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_month_insert      := hcm_util.get_string_t(json_obj,'p_month');

    -- set to use
    p_month             := lpad(p_month, 2, '0');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_token         varchar2(4 char);
    v_staemp        temploy1.staemp%type;
    v_flgsecu       boolean := true;
  begin
    /* --ST11 #7491 || 09/05/2022
    if p_codempid is null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    */
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
          return;
      else
          if global_v_codempid <> p_codempid then
              null;
              /* --ST11 #7491 || 09/05/2022
              v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
              if not v_flgsecu  then
                param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                return;
              end if;
              */
          end if;
      end if;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_codempid    temploy1.codempid%type;
    v_codcomp     temploy1.codcomp%type;
    v_codcalen    temploy1.codcalen%type;
    v_codcompy    varchar2(1000 char);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select CODEMPID,CODCOMP,CODCALEN
        into v_codempid,v_codcomp,v_codcalen
        from temploy1
       where codempid = global_v_codempid
         and rownum = 1;
    end;
    v_codcompy := nvl(get_codcompy(trim(v_codcomp)),'');
    obj_row.put('coderror', '200');
    obj_row.put('codempid',nvl(v_codempid,''));
    obj_row.put('codcompy',nvl(get_tcompny_name(trim(v_codcompy),global_v_lang),''));
    obj_row.put('codcalen',nvl(get_tcodec_name('TCODWORK',trim(v_codcalen),global_v_lang),''));

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_calendar (json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_tmp       json_object_t;
    v_row             number := 0;
    first_date    date;
    end_date      date;
    v_day         number := 1;
    v_typwork     varchar2(1 char);
    v_codshift    varchar2(4 char);
    v_date        date;

    v_codcomp     varchar2(4000 char);
    v_codcalen    varchar2(4000 char);
    v_desholdy    varchar2(4000 char);
    v_holdy_comp  varchar2(2000 char);
    v_holdy_leave varchar2(2000 char);
    v_comp_holidy tgholidy.codcomp%type;

    v_traditional_hol   varchar2(1) := 'T';
    v_shutdown_hol      varchar2(1) := 'S';

    v_numofweek           number := 0;
    arr_week_day          typ_char_number;
    arr_week_codshift     typ_char_number;
    arr_week_desc         typ_char_number;
    arr_week_typwork      typ_char_number;
  begin
    obj_row := json_object_t();

    if isInsertReport then
      for d in 1 .. 7 loop
        arr_week_day(d)      := '';
        arr_week_codshift(d) := '';
        arr_week_desc(d)     := '';
        arr_week_typwork(d)  := '';
      end loop;
    end if;

    first_date   := to_date('01/'|| nvl(p_month, '01') ||'/'||p_year,'dd/mm/yyyy');

    if p_month is not null then
      end_date := last_day(first_date);
    else
      end_date := to_date('31/12/'||p_year,'dd/mm/yyyy');
    end if;

    begin
      select codcomp, codcalen
        into v_codcomp, v_codcalen
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end;
    v_comp_holidy   := get_tgholidy_codcomp(v_codcomp,v_codcalen,p_year);

    for i in 0 .. end_date - first_date loop
        v_date := to_date(first_date + i);

        begin
          select typwork, codshift
            into v_typwork, v_codshift
            from tattence
           where codempid = p_codempid
             and dtework  = v_date;
        exception when no_data_found then
          v_typwork  := null;
          v_codshift := null;
        end;

        v_desholdy        := null;
        v_holdy_comp      := null;
        if v_typwork != 'W' then
          if v_typwork in (v_traditional_hol,v_shutdown_hol) then
            begin
              select decode(global_v_lang , '101', desholdye
                                          , '102', desholdyt
                                          , '103', desholdy3
                                          , '104', desholdy4
                                          , '105', desholdy5
                                          , '') desholdy
               into v_holdy_comp
               from tgholidy
              where codcomp     = v_comp_holidy
                and dteyear     = p_year
                and codcalen    = v_codcalen
                and dtedate     = v_date
                and typwork     = v_typwork
              order by codcomp desc;
            exception when no_data_found then
              v_holdy_comp  := null;
            end;
            if v_holdy_comp is null then
              v_holdy_comp  := get_tlistval_name('TYPWROK',v_typwork,global_v_lang);
            end if;

          end if;
          v_holdy_leave     := null;

          begin
            select listagg(get_tleavecd_name(codleave, global_v_lang), ', ') within group (order by codleave) "codleave"
              into v_holdy_leave
              from tleavetr
             where codempid = p_codempid
               and dtework = v_date;
          exception when no_data_found then
            null;
          end;
          v_desholdy      := v_holdy_comp || v_holdy_leave;
        end if;

        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('dtedate',to_char(v_date,'dd/mm/yyyy'));
        obj_data.put('typwork',v_typwork);
        obj_data.put('codshift',v_codshift);
        obj_data.put('desholdy',v_desholdy);

        if isInsertReport then
          if nvl(b_month, '99') <> to_char(v_date, 'mm') then
            b_month      := to_char(v_date, 'mm');
            obj_tmp      := json_object_t();
            obj_tmp.put('month1', get_tlistval_name('NAMMTHFUL', to_char(to_number(b_month)), global_v_lang));
            obj_tmp.put('month2', get_tlistval_name('NAMMTHABB', to_char(to_number(b_month)), global_v_lang));
            obj_tmp.put('year1', to_char(to_number(p_year) + to_number(hcm_appsettings.get_additional_year)));
            b_codapp := p_codapp;
            insert_ttemprpt_emp_main(obj_tmp);
          end if;

          if v_typwork in (v_traditional_hol,v_shutdown_hol) then
            b_codapp := p_codapp || '2';
            insert_ttemprpt_emp_main(obj_data);
          end if;

          v_numofweek := to_number(to_char(v_date, 'D'));
          arr_week_day(v_numofweek)      := to_char(v_date,'dd');
          arr_week_codshift(v_numofweek) := v_codshift;
          arr_week_desc(v_numofweek)     := v_desholdy;
          arr_week_typwork(v_numofweek)  := v_typwork;

          if v_numofweek = 7 or v_date = last_day(v_date) then
            b_codapp := p_codapp || '1';
            insert_ttemprpt_emp(arr_week_day, arr_week_codshift, arr_week_desc, arr_week_typwork);
            for d in 1 .. 7 loop
              arr_week_day(d)      := '';
              arr_week_codshift(d) := '';
              arr_week_desc(d)     := '';
              arr_week_typwork(d)  := '';
            end loop;
          end if;
        end if;

        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    if isInsertReport then
      if v_numofweek < 7 then
        for d in (v_numofweek + 1) .. 7 loop
          arr_week_day(d)      := '';
          arr_week_codshift(d) := '';
          arr_week_desc(d)     := '';
          arr_week_typwork(d)  := '';
        end loop;
        b_codapp := p_codapp || '1';
        insert_ttemprpt_emp(arr_week_day, arr_week_codshift, arr_week_desc, arr_week_typwork);
      end if;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_groupplan(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_stdate          date;
    v_endate          date;
    v_total       number := 0;
    v_row         number := 0;
    v_day         number := 0;
    o_codcalen    varchar2(400 char) := '!@#$';
    o_codcomp     varchar2(400 char) := '!@#$';
    v_first       boolean := true;
    v_desc_codcalen varchar2(4000 char) := '';
    v_codcomp     varchar2(400 char);
    v_codcalen    varchar2(400 char);
    v_emp_count   number;
    cursor c_tgrpplan is
      select codcomp,codcalen
            from tgrpplan p
          -- where(codcomp||'%' like p_codcomp||'%' or p_codcomp||'%' like codcomp||'%')
          where codcomp like p_codcomp||'%'
            and codcalen = nvl(p_codcalen,codcalen)
            and dtework between v_stdate and v_endate
        group by codcomp,codcalen
        order by codcomp,codcalen;

    cursor c_tgrpplan2 is
    select codcomp,dtework,codcalen,typwork,codshift
        from tgrpplan
       where codcomp    = v_codcomp
         and codcalen = v_codcalen
         and dtework  between v_stdate and v_endate
    group by codcomp,dtework,codcalen,typwork,codshift
    order by dtework;

  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      obj_row  := json_object_t();
      v_stdate := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
      v_endate := last_day(v_stdate);

      for r1 in c_tgrpplan loop
        v_total := 1;
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, r1.codcomp);
        if param_msg_error is not null then
          exit;
        end if;
        v_codcomp  := r1.codcomp;
        v_codcalen := r1.codcalen;
        if r1.codcomp <> o_codcomp then
          o_codcalen := '!@#$';
          v_day := 0;
          v_first := true;
        end if;
        for r2 in c_tgrpplan2 loop
          v_day := v_day + 1;
          if r2.codcalen <> o_codcalen then
            if v_first = false then
              obj_row.put(to_char(v_row-1),obj_data);
            end if;
            v_first := false;
            v_row := v_row + 1;
            v_day := 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcomp', nvl(r2.codcomp, ''));
            obj_data.put('desc_codcomp', get_tcenter_name(r2.codcomp, global_v_lang));
            obj_data.put('codcalen', nvl(r2.codcalen, ''));
            begin
              select decode(global_v_lang, '101', descode,
                                           '102', descodt,
                                           '103', descod3,
                                           '104', descod4,
                                           '105', descod5,
                                                  descode)
                into v_desc_codcalen
                from tcodwork
               where codcodec = r2.codcalen;
            exception when no_data_found then
              v_desc_codcalen := '';
            end;
            obj_data.put('desc_codcalen', nvl(v_desc_codcalen, ''));
          end if;
          obj_data.put('month', lpad(to_char(p_month),2,'0'));
          obj_data.put('year', p_year);
          obj_data.put('typwork'||lpad(to_char(v_day),2,'0'), nvl(r2.typwork, ''));
          obj_data.put('codshift'||lpad(to_char(v_day),2,'0'), nvl(r2.codshift, ''));
          o_codcalen := r2.codcalen;
          o_codcomp  := r2.codcomp;
        end loop;
        begin
          select nvl(count(codempid), 0)
            into v_emp_count
            from temploy1 a
           where r1.codcomp = get_tgrpwork_codcomp(get_tattence_codcomp(codempid, v_stdate, v_endate), null)
             and exists (select b.codcalen
                           from tattence b
                          where a.codempid = b.codempid
                            and b.dtework between v_stdate and v_endate
                            and codcalen = r1.codcalen)
             and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, codempid) = 'Y';
        end;
        obj_data.put('emp_count', to_char(v_emp_count));
        obj_row.put(to_char(v_row-1),obj_data);

      end loop;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif obj_row.get_size = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tgrpplan');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      if isInsertReport then
        if param_msg_error is null then
          clear_ttemprpt;
        end if;
        if param_msg_error is null then
          insert_report_comp(obj_row);
        end if;
      else
        json_str_output := obj_row.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_groupplan;

  procedure get_groupemp(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_groupemp(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  end get_groupemp;

  procedure gen_groupemp(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_stdate          date;
    v_endate          date;
    v_codempid    varchar2(100 char);
    v_total       number := 0;
    v_row         number := 0;
    v_day         number := 0;
    o_codempid    varchar2(400 char) := '!@#$';
    v_first       boolean := true;
    v_date        date;
    v_dteempmt    date;
    v_dteeffex    date;
    v_flgsecu     boolean := true;

    cursor c_temploy1 is
      select codempid,codcomp,numlvl
        from temploy1 a
      where get_tgrpwork_codcomp(get_tattence_codcomp(codempid,v_stdate,v_endate),null) = p_codcomp
        and codcalen in (select codcalen
                      from tattence b
                    where a.codempid = b.codempid
                      and dtework between v_stdate and v_endate
                      and codcalen = p_codcalen)
    order by codempid;

    cursor c_tattence is
      select codcomp,dtework,codcalen,typwork,codshift
          from tattence
        where codempid = v_codempid
          and dtework  between v_stdate and v_endate
      order by dtework;

  begin
    if param_msg_error is null then
      obj_row  := json_object_t();
      v_stdate := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
      v_endate := last_day(v_stdate);

      for r1 in c_temploy1 loop
        v_flgsecu := true;
        --ST11 #7491 || 09/05/2022  v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if v_flgsecu then
          v_codempid  := r1.codempid;
          for r2 in c_tattence loop
            v_day := v_day + 1;
            if r1.codempid <> o_codempid then
              if v_first = false then
                obj_row.put(to_char(v_row-1),obj_data);
              end if;
              v_first := false;
              v_row := v_row + 1;
              v_day := 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('codempid',v_codempid);
              obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
              obj_data.put('codcomp',r2.codcomp);
              begin
                select dteempmt,dteeffex
                  into v_dteempmt,v_dteeffex
                  from temploy1
                 where codempid = v_codempid;
              exception when no_data_found then
                v_dteempmt := null;
                v_dteeffex := null;
              end;
              obj_data.put('dteempmt',to_char(v_dteempmt,'dd/mm/yyyy'));
              obj_data.put('dteeffex',to_char(v_dteeffex,'dd/mm/yyyy'));
              v_date := v_stdate;
              loop
                obj_data.put('month', lpad(to_char(p_month),2,'0'));
                obj_data.put('year', p_year);
                obj_data.put('codcalen', p_codcalen);
                obj_data.put('codcalen'||to_char(v_date,'dd'),'');
                obj_data.put('typwork'||to_char(v_date,'dd'),'');
                obj_data.put('codshift'||to_char(v_date,'dd'),'');
              exit when v_date = v_endate;
                v_date := v_date+1;
              end loop;
            end if;
            obj_data.put('month', lpad(to_char(p_month),2,'0'));
            obj_data.put('year', p_year);
            obj_data.put('codcalen'||to_char(r2.dtework,'dd'),nvl(r2.codcalen, ''));
            obj_data.put('typwork'||to_char(r2.dtework,'dd'),nvl(r2.typwork, ''));
            obj_data.put('codshift'||to_char(r2.dtework,'dd'),nvl(r2.codshift, ''));
            o_codempid := v_codempid;
          end loop;
          obj_row.put(to_char(v_row-1),obj_data);
          if isInsertReport then
            if param_msg_error is null then
              insert_ttemprpt_comp(0, obj_data);
            end if;
          end if;
        end if;
      end loop;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_groupemp;

  procedure get_calendar(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_calendar(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_calendar;

  procedure get_shift(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
        select codshift, timstrtw, timendw
          from tshiftcd
      order by codshift;
  begin
    obj_row    := json_object_t();

    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codshift', i.codshift);
      obj_data.put('desc_codshift', get_tshiftcd_name(i.codshift, global_v_lang));
      obj_data.put('timstrtw', i.timstrtw);
      obj_data.put('timendw', i.timendw);
      obj_data.put('timshift', substr(i.timstrtw, 1, 2)||':'||substr(i.timstrtw, 3, 2)||' - '||substr(i.timendw, 1, 2)||':'||substr(i.timendw, 3, 2));

      obj_row.put(to_char(v_row-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_shift;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like p_codapp || '%';
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end clear_ttemprpt;

  procedure initial_report (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempidQuery');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_month             := hcm_util.get_string_t(json_obj,'p_month');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');

    -- set to use
    p_month             := lpad(p_month, 2, '0');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    b_codapp            := p_codapp;
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    obj_data          json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if p_codempid is null then
      if param_msg_error is null then
        get_groupplan(json_str_input, json_output);
      end if;
    else
      b_codapp := p_codapp;
      clear_ttemprpt;
      gen_calendar(json_output);
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

  procedure insert_report_comp(obj_row in json_object_t) is
    obj_data            json_object_t;
    v_numseq            number := 0;
    v_emp_count         number := 0;
    json_str_output     clob;

  begin
    if obj_row.get_size > 0 then
      begin
        select nvl(max(numseq), 0)
          into v_numseq
          from ttemprpt
        where codempid = global_v_codempid
          and codapp   = p_codapp;
      exception when no_data_found then
        null;
      end;
      obj_data        := json_object_t();
      for i in 0 .. obj_row.get_size - 1 loop
        obj_data        := hcm_util.get_json_t(obj_row, to_char(i));
        p_codcomp  := hcm_util.get_string_t(obj_data, 'codcomp');
        p_codcalen := hcm_util.get_string_t(obj_data, 'codcalen');

        v_numseq := v_numseq + 1;
        obj_data.put('codempid', hcm_util.get_string_t(obj_data, 'desc_codcomp'));
        obj_data.put('desc_codempid', hcm_util.get_string_t(obj_data, 'desc_codcalen'));

        insert_ttemprpt_comp(v_numseq, obj_data);

        if param_msg_error is not null then
          return;
        end if;

        v_numseq := v_numseq + 1;
        v_emp_count := to_number(hcm_util.get_string_t(obj_data, 'emp_count'));
        obj_data := json_object_t();
        obj_data.put('codempid', get_label_name('HRES61X', global_v_lang, '490'));
        obj_data.put('desc_codempid', to_char(v_emp_count));
        insert_ttemprpt_comp(v_numseq, obj_data);
        v_numseq := v_numseq + v_emp_count;
        if param_msg_error is not null then
          return;
        else
          check_index;
          if param_msg_error is null then
            gen_groupemp(json_str_output);
          else
            return;
          end if;
        end if;
      end loop;
    end if;
  end insert_report_comp;

  procedure insert_ttemprpt_comp(v_numseq in number, obj_data in json_object_t) is
    b_numseq            number := 0;
    v_item1             ttemprpt.item1%type;    v_item2             ttemprpt.item2%type;    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;    v_item5             ttemprpt.item5%type;    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;    v_item8             ttemprpt.item8%type;    v_item9             ttemprpt.item9%type;
    v_item10            ttemprpt.item10%type;   v_item11            ttemprpt.item11%type;   v_item12            ttemprpt.item12%type;
    v_item13            ttemprpt.item13%type;   v_item14            ttemprpt.item14%type;   v_item15            ttemprpt.item15%type;
    v_item16            ttemprpt.item16%type;   v_item17            ttemprpt.item17%type;   v_item18            ttemprpt.item18%type;
    v_item19            ttemprpt.item19%type;   v_item20            ttemprpt.item20%type;   v_item21            ttemprpt.item21%type;
    v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;   v_item24            ttemprpt.item24%type;
    v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;   v_item27            ttemprpt.item27%type;
    v_item28            ttemprpt.item28%type;   v_item29            ttemprpt.item29%type;   v_item30            ttemprpt.item30%type;
    v_item31            ttemprpt.item31%type;
    v_item32            ttemprpt.item32%type;   v_item33            ttemprpt.item33%type;   v_item34            ttemprpt.item34%type;
    v_item35            ttemprpt.item35%type;
    v_item41            ttemprpt.item41%type;   v_item42            ttemprpt.item42%type;   v_item43            ttemprpt.item43%type;
    v_item44            ttemprpt.item44%type;   v_item45            ttemprpt.item45%type;   v_item46            ttemprpt.item46%type;
    v_item47            ttemprpt.item47%type;   v_item48            ttemprpt.item48%type;   v_item49            ttemprpt.item49%type;
    v_item50            ttemprpt.item50%type;   v_item51            ttemprpt.item51%type;   v_item52            ttemprpt.item52%type;
    v_item53            ttemprpt.item53%type;   v_item54            ttemprpt.item54%type;   v_item55            ttemprpt.item55%type;
    v_item56            ttemprpt.item56%type;   v_item57            ttemprpt.item57%type;   v_item58            ttemprpt.item58%type;
    v_item59            ttemprpt.item59%type;   v_item60            ttemprpt.item60%type;   v_item61            ttemprpt.item61%type;
    v_item62            ttemprpt.item62%type;   v_item63            ttemprpt.item63%type;   v_item64            ttemprpt.item64%type;
    v_item65            ttemprpt.item65%type;   v_item66            ttemprpt.item66%type;   v_item67            ttemprpt.item67%type;
    v_item68            ttemprpt.item68%type;   v_item69            ttemprpt.item69%type;   v_item70            ttemprpt.item70%type;
    v_item71            ttemprpt.item71%type;

  begin
    v_item32 := hcm_util.get_string_t(obj_data, 'codempid');
    v_item33 := hcm_util.get_string_t(obj_data, 'desc_codempid');
    v_item34 := hcm_util.get_string_t(obj_data, 'codcomp');
    v_item35 := hcm_util.get_string_t(obj_data, 'codcalen');
    v_item1  := hcm_util.get_string_t(obj_data, 'codshift01');
    v_item2  := hcm_util.get_string_t(obj_data, 'codshift02');
    v_item3  := hcm_util.get_string_t(obj_data, 'codshift03');
    v_item4  := hcm_util.get_string_t(obj_data, 'codshift04');
    v_item5  := hcm_util.get_string_t(obj_data, 'codshift05');
    v_item6  := hcm_util.get_string_t(obj_data, 'codshift06');
    v_item7  := hcm_util.get_string_t(obj_data, 'codshift07');
    v_item8  := hcm_util.get_string_t(obj_data, 'codshift08');
    v_item9  := hcm_util.get_string_t(obj_data, 'codshift09');
    v_item10 := hcm_util.get_string_t(obj_data, 'codshift10');
    v_item11 := hcm_util.get_string_t(obj_data, 'codshift11');
    v_item12 := hcm_util.get_string_t(obj_data, 'codshift12');
    v_item13 := hcm_util.get_string_t(obj_data, 'codshift13');
    v_item14 := hcm_util.get_string_t(obj_data, 'codshift14');
    v_item15 := hcm_util.get_string_t(obj_data, 'codshift15');
    v_item16 := hcm_util.get_string_t(obj_data, 'codshift16');
    v_item17 := hcm_util.get_string_t(obj_data, 'codshift17');
    v_item18 := hcm_util.get_string_t(obj_data, 'codshift18');
    v_item19 := hcm_util.get_string_t(obj_data, 'codshift19');
    v_item20 := hcm_util.get_string_t(obj_data, 'codshift20');
    v_item21 := hcm_util.get_string_t(obj_data, 'codshift21');
    v_item22 := hcm_util.get_string_t(obj_data, 'codshift22');
    v_item23 := hcm_util.get_string_t(obj_data, 'codshift23');
    v_item24 := hcm_util.get_string_t(obj_data, 'codshift24');
    v_item25 := hcm_util.get_string_t(obj_data, 'codshift25');
    v_item26 := hcm_util.get_string_t(obj_data, 'codshift26');
    v_item27 := hcm_util.get_string_t(obj_data, 'codshift27');
    v_item28 := hcm_util.get_string_t(obj_data, 'codshift28');
    v_item29 := hcm_util.get_string_t(obj_data, 'codshift29');
    v_item30 := hcm_util.get_string_t(obj_data, 'codshift30');
    v_item31 := hcm_util.get_string_t(obj_data, 'codshift31');
    v_item41 := hcm_util.get_string_t(obj_data, 'typwork01');
    v_item42 := hcm_util.get_string_t(obj_data, 'typwork02');
    v_item43 := hcm_util.get_string_t(obj_data, 'typwork03');
    v_item44 := hcm_util.get_string_t(obj_data, 'typwork04');
    v_item45 := hcm_util.get_string_t(obj_data, 'typwork05');
    v_item46 := hcm_util.get_string_t(obj_data, 'typwork06');
    v_item47 := hcm_util.get_string_t(obj_data, 'typwork07');
    v_item48 := hcm_util.get_string_t(obj_data, 'typwork08');
    v_item49 := hcm_util.get_string_t(obj_data, 'typwork09');
    v_item50 := hcm_util.get_string_t(obj_data, 'typwork10');
    v_item51 := hcm_util.get_string_t(obj_data, 'typwork11');
    v_item52 := hcm_util.get_string_t(obj_data, 'typwork12');
    v_item53 := hcm_util.get_string_t(obj_data, 'typwork13');
    v_item54 := hcm_util.get_string_t(obj_data, 'typwork14');
    v_item55 := hcm_util.get_string_t(obj_data, 'typwork15');
    v_item56 := hcm_util.get_string_t(obj_data, 'typwork16');
    v_item57 := hcm_util.get_string_t(obj_data, 'typwork17');
    v_item58 := hcm_util.get_string_t(obj_data, 'typwork18');
    v_item59 := hcm_util.get_string_t(obj_data, 'typwork19');
    v_item60 := hcm_util.get_string_t(obj_data, 'typwork20');
    v_item61 := hcm_util.get_string_t(obj_data, 'typwork21');
    v_item62 := hcm_util.get_string_t(obj_data, 'typwork22');
    v_item63 := hcm_util.get_string_t(obj_data, 'typwork23');
    v_item64 := hcm_util.get_string_t(obj_data, 'typwork24');
    v_item65 := hcm_util.get_string_t(obj_data, 'typwork25');
    v_item66 := hcm_util.get_string_t(obj_data, 'typwork26');
    v_item67 := hcm_util.get_string_t(obj_data, 'typwork27');
    v_item68 := hcm_util.get_string_t(obj_data, 'typwork28');
    v_item69 := hcm_util.get_string_t(obj_data, 'typwork29');
    v_item70 := hcm_util.get_string_t(obj_data, 'typwork30');
    v_item71 := hcm_util.get_string_t(obj_data, 'typwork31');

    if v_numseq = 0 then
      begin
        select nvl(max(numseq), 0)
          into b_numseq
          from ttemprpt
        where codempid = global_v_codempid
          and codapp   = p_codapp;
        b_numseq := b_numseq + 1;
      exception when no_data_found then
        null;
      end;
    else
      b_numseq := v_numseq;
    end if;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6,
            item7,  item8,  item9,  item10, item11, item12,
            item13, item14, item15, item16, item17, item18,
            item19, item20, item21, item22, item23, item24,
            item25, item26, item27, item28, item29, item30,
            item31, item32, item33, item34, item35,
            item41, item42, item43, item44, item45, item46,
            item47, item48, item49, item50, item51, item52,
            item53, item54, item55, item56, item57, item58,
            item59, item60, item61, item62, item63, item64,
            item65, item66, item67, item68, item69, item70,
            item71, item72, item73
          )
      values
          (
            global_v_codempid, p_codapp, b_numseq,
            v_item1,  v_item2,  v_item3,  v_item4,  v_item5,  v_item6,
            v_item7,  v_item8,  v_item9,  v_item10, v_item11, v_item12,
            v_item13, v_item14, v_item15, v_item16, v_item17, v_item18,
            v_item19, v_item20, v_item21, v_item22, v_item23, v_item24,
            v_item25, v_item26, v_item27, v_item28, v_item29, v_item30,
            v_item31, v_item32, v_item33, v_item34, v_item35,
            v_item41, v_item42, v_item43, v_item44, v_item45, v_item46,
            v_item47, v_item48, v_item49, v_item50, v_item51, v_item52,
            v_item53, v_item54, v_item55, v_item56, v_item57, v_item58,
            v_item59, v_item60, v_item61, v_item62, v_item63, v_item64,
            v_item65, v_item66, v_item67, v_item68, v_item69, v_item70,
            v_item71, p_year, p_month_insert
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_comp;

  procedure insert_ttemprpt_emp(arr_week_day in typ_char_number, arr_week_codshift in typ_char_number, arr_week_desc in typ_char_number, arr_week_typwork in typ_char_number) is
    v_numseq            number := 0;
    v_item1             ttemprpt.item1%type;    v_item2             ttemprpt.item2%type;    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;    v_item5             ttemprpt.item5%type;    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;    v_item8             ttemprpt.item8%type;    v_item9             ttemprpt.item9%type;
    v_item11            ttemprpt.item11%type;   v_item12            ttemprpt.item12%type;   v_item13            ttemprpt.item13%type;
    v_item14            ttemprpt.item14%type;   v_item15            ttemprpt.item15%type;   v_item16            ttemprpt.item16%type;
    v_item17            ttemprpt.item17%type;
    v_item21            ttemprpt.item21%type;   v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;
    v_item24            ttemprpt.item24%type;   v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;
    v_item27            ttemprpt.item27%type;
    v_item31            ttemprpt.item31%type;   v_item32            ttemprpt.item32%type;   v_item33            ttemprpt.item33%type;
    v_item34            ttemprpt.item34%type;   v_item35            ttemprpt.item35%type;   v_item36            ttemprpt.item36%type;
    v_item37            ttemprpt.item37%type;
    v_item38            ttemprpt.item38%type;
    v_item39            ttemprpt.item39%type;
    v_item40            ttemprpt.item40%type;
    v_item41            ttemprpt.item41%type;
    v_item42            ttemprpt.item42%type;
    v_item43            ttemprpt.item43%type;
    v_item44            ttemprpt.item44%type;

  begin
    v_item1  := arr_week_day(1);
    v_item2  := arr_week_day(2);
    v_item3  := arr_week_day(3);
    v_item4  := arr_week_day(4);
    v_item5  := arr_week_day(5);
    v_item6  := arr_week_day(6);
    v_item7  := arr_week_day(7);
    v_item8  := b_month;
    v_item9  := p_year;

    v_item11 := arr_week_codshift(1);
    v_item12 := arr_week_codshift(2);
    v_item13 := arr_week_codshift(3);
    v_item14 := arr_week_codshift(4);
    v_item15 := arr_week_codshift(5);
    v_item16 := arr_week_codshift(6);
    v_item17 := arr_week_codshift(7);

    v_item21 := arr_week_desc(1);
    v_item22 := arr_week_desc(2);
    v_item23 := arr_week_desc(3);
    v_item24 := arr_week_desc(4);
    v_item25 := arr_week_desc(5);
    v_item26 := arr_week_desc(6);
    v_item27 := arr_week_desc(7);

    v_item31 := arr_week_typwork(1);
    v_item32 := arr_week_typwork(2);
    v_item33 := arr_week_typwork(3);
    v_item34 := arr_week_typwork(4);
    v_item35 := arr_week_typwork(5);
    v_item36 := arr_week_typwork(6);
    v_item37 := arr_week_typwork(7);

    --day name--
    v_item38  := get_label_name('HRES61XC1', global_v_lang, '10');
    v_item39  := get_label_name('HRES61XC1', global_v_lang, '20');
    v_item40  := get_label_name('HRES61XC1', global_v_lang, '30');
    v_item41  := get_label_name('HRES61XC1', global_v_lang, '40');
    v_item42  := get_label_name('HRES61XC1', global_v_lang, '50');
    v_item43  := get_label_name('HRES61XC1', global_v_lang, '60');
    v_item44  := get_label_name('HRES61XC1', global_v_lang, '70');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = b_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6,
            item7,  item8,  item9,
            item11, item12, item13, item14, item15, item16,
            item17,
            item21, item22, item23, item24, item25, item26,
            item27,
            item31, item32, item33, item34, item35, item36,
            item37,
            item38, item39, item40, item41, item42, item43, item44
          )
      values
          (
            global_v_codempid, b_codapp, v_numseq,
            v_item1,  v_item2,  v_item3,  v_item4,  v_item5,  v_item6,
            v_item7,  v_item8,  v_item9,
            v_item11, v_item12, v_item13, v_item14, v_item15, v_item16,
            v_item17,
            v_item21, v_item22, v_item23, v_item24, v_item25, v_item26,
            v_item27,
            v_item31, v_item32, v_item33, v_item34, v_item35, v_item36,
            v_item37,
            v_item38, v_item39, v_item40, v_item41, v_item42, v_item43, v_item44
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_emp;

  procedure insert_ttemprpt_emp_main(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_item1             ttemprpt.item1%type;
    v_item2             ttemprpt.item2%type;
    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;
    v_item5             ttemprpt.item5%type;
    v_item6             ttemprpt.item6%type;

  begin
    v_item1  := b_month;
    v_item2  := p_year;
    if b_codapp = 'HRES61X' then
      v_item3  := hcm_util.get_string_t(obj_data, 'month1');
      v_item4  := hcm_util.get_string_t(obj_data, 'month2');
      v_item5  := hcm_util.get_string_t(obj_data, 'year1');
      v_item6  := get_tlistval_name('NAMDAYFUL', to_char(to_date('01/' || v_item1 || '/' || v_item2, 'DD/MM/YYYY'), 'D'), global_v_lang);
    else
      v_item3  := hcm_util.get_string_t(obj_data, 'typwork');
      v_item4  := hcm_util.get_string_t(obj_data, 'dtedate');
      v_item4  := to_char(to_date(v_item4, 'dd/mm/yyyy'), 'dd/mm') || '/' || to_char(to_number(to_char(to_date(v_item4, 'dd/mm/yyyy'), 'yyyy')) + to_number(hcm_appsettings.get_additional_year));
      v_item5  := hcm_util.get_string_t(obj_data, 'desholdy');
    end if;

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = b_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6
          )
      values
          (
            global_v_codempid, b_codapp, v_numseq,
            v_item1,  v_item2,  v_item3,  v_item4,  v_item5,  v_item6
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_emp_main;
end hres61x;

/
