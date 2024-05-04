--------------------------------------------------------
--  DDL for Package Body HCM_DRILLDOWN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_DRILLDOWN" IS
-- last update: 23/02/2018 12:02

  procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_codempid          := hcm_util.get_string(json_obj, 'p_codempid_query');
    p_codskill          := hcm_util.get_string(json_obj, 'p_codskill');
    p_flgsecur          := nvl(hcm_util.get_string(json_obj, 'p_flgsecur'),'Y');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_count     number  := 0;
    v_zupdsal   varchar2(1);
    v_flgsecu   boolean := false;
  begin
    if p_codempid is not null then
      if p_flgsecur = 'Y' then
        begin
          select count(*) into v_count
            from temploy1
           where codempid like p_codempid
             and staemp in ('0','1','3','9');
        exception when no_data_found then
          null;
        end;

        if v_count = 0 then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
          return;
        END IF;
--        get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu  then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        END IF;
      end if;
    end if;
  end check_index;

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
    obj_data            json;
    v_age_year          number;
    v_age_month         number;
    v_age_day           number;
    v_wrk_year          number;
    v_wrk_month         number;
    v_wrk_day           number;

    v_amtinc1           number := 0;
    v_codcur            varchar2(100 char);
    v_salary            varchar2(100 char);
    v_codcompy          TCENTER.CODCOMPY%TYPE;
    v_amth              number;
    v_amtd              number;
    v_amtm              number;
    v_check_secur       boolean;

    cursor c1 is
      select t1.codempmt,
            t1.codempid,
            t1.dteempdb,
            t1.codcomp,
            t1.codpos,
            t1.codjob,
            t1.numlvl,
            t1.codbrlc,
            t1.codcalen,
            t1.dteefpos,
            t1.dteeflvl,
            t1.qtywkday,
            t1.codedlv,
            t1.codmajsb,
            t1.typpayroll,
            t1.qtydatrq,
            t1.typemp,
            t1.dteempmt,
            t1.dteeffex,
            t1.dteduepr,
            t1.staemp,
            t1.email,
            t1.numappl,
            t2.numoffid
        from temploy1 t1, temploy2 t2
       where t1.codempid (+)= t2.codempid
         and t1.codempid = p_codempid
    fetch next 1 rows only;
  begin
    obj_data            := json();
    for r1 in c1 loop
      obj_data.put('coderror', '200');
      obj_data.put('codempmt', r1.codempmt);
      obj_data.put('desc_codempmt', get_tcodec_name('tcodempl', r1.codempmt, global_v_lang));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('dteempdb', to_char(r1.dteempdb, 'dd/mm/yyyy'));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob, global_v_lang));
      obj_data.put('numlvl', r1.numlvl);
      obj_data.put('codcalen', r1.codcalen);
      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', r1.codcalen, global_v_lang));
      obj_data.put('codedlv', r1.codedlv);
      obj_data.put('desc_codedlv', get_tcodec_name('tcodeduc', r1.codedlv, global_v_lang));
      obj_data.put('codmajsb', r1.codmajsb);
      obj_data.put('desc_codmajsb', get_tcodec_name('tcodmajr', r1.codmajsb, global_v_lang));
      obj_data.put('typpayroll', r1.typpayroll);
      obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', r1.typpayroll, global_v_lang));
      obj_data.put('typemp', r1.typemp);
      obj_data.put('desc_typemp', get_tcodec_name('tcodcatg', r1.typemp, global_v_lang));
      obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
      obj_data.put('dteeffex', to_char(r1.dteeffex, 'dd/mm/yyyy'));
      obj_data.put('dteduepr', to_char(r1.dteduepr, 'dd/mm/yyyy'));
      obj_data.put('staemp', r1.staemp);
      obj_data.put('desc_staemp', get_tlistval_name('NAMESTAT', r1.staemp, global_v_lang));
      obj_data.put('email', r1.email);
      obj_data.put('numoffid', get_masking_data(r1.numoffid));

      v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      v_codcompy        := get_codcompy(r1.codcomp);
      if v_zupdsal = 'Y' then
        begin
          select to_number(nvl(stddec(amtincom1,codempid,v_chken),0)), codcurr
            into v_amtinc1, v_codcur
            from temploy3
           where codempid = p_codempid;
        exception when no_data_found then
          v_salary      := null;
        end;
        get_wage_income(v_codcompy, r1.codempmt,
                        v_amtinc1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        v_amth, v_amtd, v_amtm);
        v_amth          := round(v_amth, 2);
        v_amtd          := round(v_amtd, 2);
        v_amtm          := round(v_amtm, 2);
        v_salary        := to_char(nvl(v_amtm, 0), 'fm999,999,990.00') || '  ' || get_tcodec_name('TCODCURR', v_codcur, global_v_lang);
      else
        v_salary := null;
      end if;
      obj_data.put('salary', v_salary);

      get_service_year(r1.dteempdb, sysdate, 'Y' , v_age_year, v_age_month, v_age_day);
      get_service_year(r1.dteempmt + nvl(r1.qtywkday, 0), nvl(r1.dteeffex, sysdate), 'Y' , v_wrk_year, v_wrk_month, v_wrk_day);
      obj_data.put('svyryre', v_wrk_year);
      obj_data.put('svyrmth', v_wrk_month);
      obj_data.put('ageyre', v_age_year);
      obj_data.put('agemth', v_age_month);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_index;

  procedure get_employment_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_employment_data(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_employment_data;

  procedure gen_employment_data (json_str_output out clob) is
    obj_data            json;
    v_age_year          number;
    v_age_month         number;
    v_age_day           number;
    v_wrk_year          number;
    v_wrk_month         number;
    v_wrk_day           number;

    v_lvl_year          number;
    v_lvl_month         number;
    v_lvl_day           number;
    v_pos_year          number;
    v_pos_month         number;
    v_pos_day           number;

    v_amtinc1           number := 0;
    v_codcur            varchar2(100 char);
    v_salary            varchar2(100 char);
    v_codcompy          TCENTER.CODCOMPY%TYPE;
    v_amth              number;
    v_amtd              number;
    v_amtm              number;
    v_codedlv           varchar2(100 char);
    v_codmajsb          varchar2(100 char);
    v_codinst           TEDUCATN.CODINST%TYPE;
    v_codminsb          TEDUCATN.CODMINSB%TYPE;
    v_check_secur       boolean := false;

    cursor c1 is
      select t1.codempmt,
            t1.codempid,
            t1.dteempdb,
            t1.codcomp,
            t1.codpos,
            t1.codjob,
            t1.numlvl,
            t1.codbrlc,
            t1.codcalen,
            t1.dteefpos,
            t1.dteeflvl,
            t1.qtywkday,
            t1.codedlv,
            t1.codmajsb,
            t1.typpayroll,
            t1.qtydatrq,
            t1.typemp,
            t1.dteempmt,
            t1.dteeffex,
            t1.dteduepr,
            t1.staemp,
            t1.email,
            t1.numappl,
            t1.flgatten
        from temploy1 t1
       where t1.codempid = p_codempid
    fetch next 1 rows only;
  begin
    obj_data            := json();
    for r1 in c1 loop
      obj_data.put('coderror', '200');
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
      obj_data.put('numlvl', r1.numlvl);
      obj_data.put('flgatten', get_tlistval_name('NAMSTAMP',r1.flgatten, global_v_lang));
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob, global_v_lang));
      obj_data.put('desc_codempmt', get_tcodec_name('tcodempl', r1.codempmt, global_v_lang));
      obj_data.put('desc_typemp', get_tcodec_name('tcodcatg', r1.typemp, global_v_lang));
      obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', r1.typpayroll, global_v_lang));
      obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));

      v_codcompy        := get_codcompy(r1.codcomp);
      v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_zupdsal = 'Y' then
        begin
          select to_number(nvl(stddec(amtincom1,codempid,v_chken),0)), codcurr
            into v_amtinc1, v_codcur
            from temploy3
           where codempid = p_codempid;
        exception when no_data_found then
          v_salary      := null;
        end;
        get_wage_income(v_codcompy, r1.codempmt,
                        v_amtinc1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        v_amth, v_amtd, v_amtm);
        v_amth          := round(v_amth, 2);
        v_amtd          := round(v_amtd, 2);
        v_amtm          := round(v_amtm, 2);
        v_salary        := to_char(v_amtm, 'fm999,999,990.00') || '  ' || get_tcodec_name('TCODCURR', v_codcur, global_v_lang);
      else
        v_salary := null;
      end if;
      obj_data.put('salary', v_salary);

      get_service_year(r1.dteempdb, sysdate, 'Y' , v_age_year, v_age_month, v_age_day);
      get_service_year(r1.dteempmt + nvl(r1.qtywkday, 0), nvl(r1.dteeffex, sysdate), 'Y' , v_wrk_year, v_wrk_month, v_wrk_day);
      get_service_year(r1.dteeflvl, nvl(r1.dteeffex, sysdate), 'Y' , v_lvl_year, v_lvl_month, v_lvl_day);
      get_service_year(r1.dteefpos, nvl(r1.dteeffex, sysdate), 'Y' , v_pos_year, v_pos_month, v_pos_day);
      obj_data.put('svyryre', v_wrk_year);
      obj_data.put('svyrmth', v_wrk_month);
      obj_data.put('ageyre', v_age_year);
      obj_data.put('agemth', v_age_month);
      obj_data.put('lvlyre', v_lvl_year);
      obj_data.put('lvlmth', v_lvl_month);
      obj_data.put('posyre', v_pos_year);
      obj_data.put('posmth', v_pos_month);

      begin
        select codinst, codminsb ,codedlv,codmajsb
          into v_codinst, v_codminsb, v_codedlv, v_codmajsb
          from teducatn
         where codempid = p_codempid
           and flgeduc = 1
        fetch next 1 rows only;
      exception when no_data_found then
        v_codinst           := null;
        v_codminsb          := null;
      end;

      obj_data.put('desc_codedlv', get_tcodec_name('TCODEDUC', v_codedlv, global_v_lang));
      obj_data.put('desc_codmajsb', get_tcodec_name('TCODMAJR', v_codmajsb, global_v_lang));
      obj_data.put('desc_codinst', get_tcodec_name('TCODINST', v_codinst, global_v_lang));
      obj_data.put('desc_codminsb', get_tcodec_name('TCODSUBJ', v_codminsb, global_v_lang));

    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_employment_data;

  procedure get_work_experience (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_work_experience(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_work_experience;

  procedure gen_work_experience (json_str_output out clob) is
    obj_data              json;
    obj_row               json;
    v_cntrow              number;

    cursor c1 is
      select numseq,
            desnoffi,
            deslstpos,
            dtestart,
            dteend,
            numappl
        from tapplwex
       where codempid = p_codempid
    order by numseq;
  begin
    obj_data          := json();
    v_cntrow          := 0;
    for r1 in c1 loop
      obj_row         := json();

      obj_row.put('desnoffi', r1.desnoffi);
      obj_row.put('deslstpos', r1.deslstpos);
      obj_row.put('dtestart', to_char(r1.dtestart, 'dd/mm/yyyy'));
      obj_row.put('dteend', to_char(r1.dteend, 'dd/mm/yyyy'));
      obj_row.put('numappl', r1.numappl);

      obj_data.put(to_char(v_cntrow), obj_row);
      v_cntrow          := v_cntrow + 1;
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_work_experience;

  procedure get_history_salary (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_history_salary(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_history_salary;

  procedure gen_history_salary (json_str_output out clob) is
    obj_data              json;
    obj_row               json;
    v_cntrow              number;
    obj_salary_incre      json;
    obj_appraisal         json;
    v_old_salary          number;
    v_new_salary          number;
    v_check_secur         boolean := false;

    cursor c1 is
      select dteeffec, amtincom1, amtincadj1, codempid
        from thismove
       where codempid = p_codempid
    order by dteeffec;

    cursor c2 is
      select dteyreap, grade
        from tapprais
       where codempid = p_codempid
      order by dteyreap;
  begin
    obj_salary_incre  := json();
    v_cntrow          := 0;

    for r1 in c1 loop
      obj_row         := json();
      v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_zupdsal = 'Y' then
        v_old_salary  := to_number(nvl(stddec(r1.amtincom1, r1.codempid, v_chken), 0)) - to_number(nvl(stddec(r1.amtincadj1, r1.codempid, v_chken), 0));
        v_new_salary  := to_number(nvl(stddec(r1.amtincadj1, r1.codempid, v_chken), 0));
      else
        v_old_salary  := null;
        v_new_salary  := null;
      end if;
      obj_row.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
      obj_row.put('old_salary', v_old_salary);
      obj_row.put('new_salary', v_new_salary);

      obj_salary_incre.put(to_char(v_cntrow), obj_row);
      v_cntrow          := v_cntrow + 1;
    end loop;

    obj_appraisal     := json();
    v_cntrow          := 0;
    for r2 in c2 loop
      obj_row         := json();
      obj_row.put('dteyreap', r2.dteyreap);
      obj_row.put('grdap', r2.grade);

      obj_appraisal.put(to_char(v_cntrow), obj_row);
      v_cntrow          := v_cntrow + 1;
    end loop;

    obj_row           := json();
    obj_row.put('salary', obj_salary_incre);
    obj_row.put('appraisal', obj_appraisal);
    obj_data          := json();
    obj_data.put('0', obj_row);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_history_salary;

  procedure get_history_punishment (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_history_punishment(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_history_punishment;

  procedure gen_history_punishment (json_str_output out clob) is
    obj_data              json;
    obj_row               json;
    v_cntrow              number;
    v_desmist             THISMIST.DESMIST1%TYPE;

    cursor c1 is
      select codpunsh, dtestart, dteend, dteeffec, codempid
        from thispun
       where codempid = p_codempid
    order by dteeffec, codpunsh, numseq;
  begin
    obj_data          := json();
    v_cntrow          := 0;
    for r1 in c1 loop

      begin
        select desmist1
          into v_desmist
          from thismist
         where codempid = r1.codempid
           and dteeffec = r1.dteeffec
        fetch next 1 rows only;
      exception when no_data_found then
        v_desmist     := null;
      end;
      obj_row         := json();
      obj_row.put('codpunsh', r1.codpunsh);
      obj_row.put('desc_codpunsh', get_tcodec_name('TCODPUNH', r1.codpunsh, global_v_lang));
      obj_row.put('dtestart', to_char(r1.dtestart, 'dd/mm/yyyy'));
      obj_row.put('dteend', to_char(r1.dteend, 'dd/mm/yyyy'));
      obj_row.put('desc_desmist', v_desmist);

      obj_data.put(to_char(v_cntrow), obj_row);
      v_cntrow          := v_cntrow + 1;
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_history_punishment;
  --
  procedure check_competency is
    v_code    varchar2(100);
  begin
    if p_codskill is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodskil
        where   codcodec    = p_codskill;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODSKIL');
        return;
      end;
    end if;
  end;
  --
  procedure get_competency_level (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_competency;
    if param_msg_error is null then
      gen_competency_level(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure gen_competency_level (json_str_output out clob) is
    obj_row     json;
    obj_data    json;
    v_cntrow    number  := 0;
    cursor c1 is
      select  codskill,grade,
              decode(global_v_lang,'101',namgrade
                                  ,'102',namgradt
                                  ,'103',namgrad3
                                  ,'104',namgrad4
                                  ,'105',namgrad5) as namgrade
      from    tskilscor
      where   codskill    = p_codskill
      order by codskill;
  begin
    obj_row   := json();
    for i in c1 loop
      obj_data    := json();
      v_cntrow    := v_cntrow + 1;
      obj_data.put('coderror','200');
      obj_data.put('codskill',i.codskill);
      obj_data.put('grade',i.grade);
      obj_data.put('namgrade',i.namgrade);
      obj_row.put(to_char(v_cntrow - 1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end;
END HCM_DRILLDOWN;

/
