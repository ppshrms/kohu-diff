--------------------------------------------------------
--  DDL for Package Body HRESH3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESH3X" as
  procedure initial_value(json_str_input in clob) AS
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);

    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_monreqst          := hcm_util.get_string_t(json_obj, 'p_month1');
    p_yeareqst          := hcm_util.get_string_t(json_obj, 'p_year1');
    p_monreqen          := hcm_util.get_string_t(json_obj, 'p_month2');
    p_yeareqen          := hcm_util.get_string_t(json_obj, 'p_year2');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  procedure get_index_medical (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_medical(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index_medical;

  procedure gen_index_medical (json_str_output out clob) AS
    obj_data          json_object_t;
    obj_row           json_object_t := json_object_t();
    v_rcnt            number := 0;
    v_check_codempid  number := 0;
    v_flg_secur       boolean := false;
    v_flg_secur2      boolean := false;
    v_flg_exist       boolean := false;
    v_dtestrt         date;
    v_dteend          date;
    cursor c1 is
        select numvcher,codempid,dtereq,typamt,amtexp,amtalw,coddc,codcln,dtecrest,dtecreen,qtydcare
          from tclnsinf
         where codempid = p_codempid
           and dtereq between v_dtestrt and v_dteend
      order by dtereq asc;

  begin
    v_dtestrt := to_date('01/'||p_monreqst||'/'||p_yeareqst,'dd/mm/yyyy');
    v_dteend := to_date('01/'||p_monreqen||'/'||p_yeareqen,'dd/mm/yyyy');
    v_dteend := last_day(v_dteend);

    select count(codempid) into v_check_codempid
    from temploy1
    where codempid = p_codempid;

    if v_check_codempid = 0 then
         param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
    end if;

    /*if p_codempid is not null then
          v_flg_secur := secur_main.secur2(p_codempid,global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal);
          if not v_flg_secur then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
          end if;
      end if;*/

    if to_number(p_yeareqst) > to_number(p_yeareqen) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
    end if;

    if to_number(p_monreqst) > to_number(p_monreqen) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
    end if;

    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSINF');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
      obj_data := json_object_t();
      v_rcnt := v_rcnt + 1;
      --v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal);
      --if v_flg_secur2 then
        obj_data.put('numvcher',r1.numvcher);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('dtereq',to_char(r1.dtereq,'DD/MM/YYYY'));
        obj_data.put('typamt',get_tlistval_name('TYPAMT',r1.typamt,global_v_lang));
        obj_data.put('amtexp',r1.amtexp);
        obj_data.put('amtalw',r1.amtalw);
        obj_data.put('desc_coddc',get_tdcinf_name(r1.coddc,global_v_lang));
        obj_data.put('desc_codcln',get_tclninf_name(r1.codcln,global_v_lang));
        obj_data.put('dtecrest',to_char(r1.dtecrest,'DD/MM/YYYY'));
        obj_data.put('dtecreen',to_char(r1.dtecreen,'DD/MM/YYYY'));
        obj_data.put('qtydcare',r1.qtydcare);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      --end if;
    end loop;
    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TCLNSINF');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index_medical;
end hresh3x;

/
