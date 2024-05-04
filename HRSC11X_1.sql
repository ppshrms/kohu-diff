--------------------------------------------------------
--  DDL for Package Body HRSC11X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC11X" as
-- last update: 14/11/2018 22:31
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
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    -- index params
    p_coduser           := hcm_util.get_string_t(json_obj, 'coduser');
    p_codempid          := hcm_util.get_string_t(json_obj, 'codempid');
    p_codapp            := hcm_util.get_string_t(json_obj, 'codapp');
    p_timstrt           := nvl(hcm_util.get_string_t(json_obj, 'timstrt'), '0000');
    p_timend            := nvl(hcm_util.get_string_t(json_obj, 'timend'), '2359');

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt') || ' ' || nvl(p_timstrt, '0000'), 'ddmmyyyy hh24mi');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend') || ' ' || nvl(p_timend, '2359'), 'ddmmyyyy hh24mi');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp          temploy1.staemp%type;
    v_flgsecu         boolean := true;
    v_coduser         tusrprof.coduser%type;
    v_codapp          tappprof.codapp%type;
  begin
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

    if p_codempid is not null then
      v_staemp    := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      else
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu  then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    end if;

    if p_coduser is not null then
      begin
        select coduser
          into v_coduser
          from tusrprof
         where coduser = p_coduser;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tusrprof');
        return;
      end;
    end if;

    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from tappprof
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tappprof');
        return;
      end;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    v_exist                boolean := false;
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;
    v_flgsecu              boolean := false;

    cursor c_login is
      select a.luserid, b.codempid, a.lterminal, a.lipaddress, a.ldteacc, a.lcodrun
             ,a.lrunning --user37 #5783 6.SC Module 29/04/2021 
        from thislogin a, tusrprof b
      where a.luserid  = b.coduser
        and a.luserid  like nvl(p_coduser, '%')
        and b.codempid like nvl(p_codempid, '%')
        and a.lcodrun  like nvl(p_codapp, '%')
        and a.ldteacc between p_dtestrt and p_dteend
      order by luserid, ldtein, ldteacc;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_login loop
      v_exist           := true;
      v_flgsecu := false;
      v_flgsecu := secur_main.secur2(c1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('coduser', c1.luserid);
        obj_data.put('codempid', c1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(c1.codempid, global_v_lang));
        obj_data.put('terminal', c1.lterminal || ' ' || c1.lipaddress);
        obj_data.put('dtelog', to_char(c1.ldteacc, 'dd/mm/yyyy hh24:mi:ss'));
        obj_data.put('codapp', c1.lcodrun);
        --<<user37 #5783 6.SC Module 29/04/2021 
        --obj_data.put('desc_codapp', get_tappprof_name(c1.lcodrun, '1', global_v_lang));
        obj_data.put('desc_codapp', get_funcnam_sc(c1.lcodrun, '1', global_v_lang));
        obj_data.put('lrunning', c1.lrunning);
        -->>user37 #5783 6.SC Module 29/04/2021 

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    if v_exist then
      if obj_row.get_size > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error   := get_error_msg_php('HR3007', global_v_lang);
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'thislogin');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  --<<user37 #5783 6.SC Module 29/04/2021 
  FUNCTION get_funcnam_sc
    (v_codapp IN VARCHAR2 ,
     v_flag   IN VARCHAR2,
     v_select_language IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_name tappprof.desappe%TYPE;
    BEGIN
     IF v_flag = '1' then
       if v_codapp is  not null then
         IF v_select_language = '101' THEN BEGIN
             SELECT desappe  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          ELSIF v_select_language = '102' THEN  BEGIN
             SELECT desappt  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          ELSIF v_select_language = '103' THEN  BEGIN
             SELECT desapp3   INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          ELSIF v_select_language = '104' THEN  BEGIN
             SELECT desapp4  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          ELSIF v_select_language = '105' THEN  BEGIN
             SELECT desapp5    INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          ELSE BEGIN
             SELECT desappe  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
          END;
          END IF;
       ELSE
          v_name  :=  '  ';
       END IF;

     ELSIF v_flag = '2' then
        IF v_codapp is not null then
            IF v_select_language = '101' THEN BEGIN
                SELECT desrepe  INTO v_name
                FROM tappprof
                WHERE CODAPP =  UPPER(TRIM(v_codapp));
            END;
        ELSIF v_select_language = '102' THEN  BEGIN
             SELECT desrept  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
        END;
        ELSIF v_select_language = '103' THEN  BEGIN
             SELECT desrep3  INTO v_name
             FROM tappprof
             WHERE CODAPP = UPPER(TRIM(v_codapp));
        END;
        ELSIF v_select_language = '104' THEN  BEGIN
             SELECT desrep4   INTO v_name
             FROM tappprof
             WHERE CODAPP = UPPER(TRIM(v_codapp));
        END;
        ELSIF v_select_language = '105' THEN  BEGIN
             SELECT desrep5  INTO v_name
             FROM tappprof
             WHERE CODAPP =  UPPER(TRIM(v_codapp));
        END;
        ELSE BEGIN
             SELECT desappe INTO v_name
              FROM tappprof
             WHERE CODAPP = UPPER(TRIM(v_codapp));
        END;
        END IF;
       ELSE
          v_name  :=  '  ';
       END IF;
    END IF;
        RETURN (v_name);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN  RETURN('');
    END get_funcnam_sc;
    -->>user37 #5783 6.SC Module 29/04/2021 
end HRSC11X;

/
