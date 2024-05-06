--------------------------------------------------------
--  DDL for Package Body HRSC10X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC10X" as
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
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
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
  cursor c_tusrlog is
    select rcupdid,dteupd,seqnum,coduser,codtable,codcolmn,descold,descnew
      from tusrlog
     where trunc(dteupd) between p_dtestrt and p_dteend
  order by dteupd desc, seqnum, rcupdid;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tusrlog loop
      v_exist           := true;
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('seqnum', c1.seqnum);
      obj_data.put('dteupd', to_char(c1.dteupd, 'dd/mm/yyyy'));
      obj_data.put('timupd', to_char(c1.dteupd, 'hh24:mi:ss'));
      obj_data.put('rcupdid', c1.rcupdid);
      obj_data.put('coduser', c1.coduser);
      obj_data.put('desc_coduser', get_temploy_name(get_codempid(c1.coduser), global_v_lang));
      obj_data.put('fldedit', get_tcoldesc_name(c1.codtable, c1.codcolmn, global_v_lang));
      obj_data.put('descold',get_description(c1.codtable,c1.codcolmn,c1.descold));
      obj_data.put('descnew',get_description(c1.codtable,c1.codcolmn,c1.descnew));
--      obj_data.put('descnew', c1.descnew);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    if v_exist then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'tusrlog');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  FUNCTION get_description ( p_table IN VARCHAR2, p_field IN VARCHAR2, p_code IN VARCHAR2 ) RETURN VARCHAR2 IS
        v_desc        VARCHAR2(500) := p_code;
        v_stament     VARCHAR2(500);
        v_funcdesc    VARCHAR2(500);
        v_data_type   VARCHAR2(500);
    BEGIN
        IF p_code IS NULL THEN
            RETURN v_desc;
        END IF;
        BEGIN
            SELECT funcdesc, data_type
              INTO v_funcdesc, v_data_type
              FROM tcoldesc
             WHERE codtable = p_table
               AND codcolmn = p_field
               AND ROWNUM = 1;
        EXCEPTION WHEN no_data_found THEN
            v_funcdesc := NULL;
        END;

        IF v_funcdesc IS NOT NULL THEN
            v_stament := 'select ' || v_funcdesc || ' from dual';
            v_stament := replace(v_stament,'P_CODE','''' || p_code || '''');
            v_stament := replace(v_stament,'P_LANG','''' || global_v_lang||'''');
            RETURN  execute_desc(v_stament);
        ELSE
            IF v_data_type = 'DATE' THEN
                if INSTR(v_desc,'/') > 0 then
                    v_desc := hcm_util.get_date_buddhist_era(TO_DATE(v_desc,'dd/mm/yyyy'));
					RETURN (v_desc);
                elsif INSTR(v_desc,'-') > 0 then
                    v_desc := hcm_util.get_date_buddhist_era(TO_DATE(SUBSTR(v_desc,1,10),'yyyy-mm-dd'));
					RETURN (v_desc);
                else
                    RETURN v_desc;
                end if;
            ELSE
                RETURN v_desc;
            END IF;
        END IF;
    END;
end HRSC10X;

/
