--------------------------------------------------------
--  DDL for Package Body HRAL27X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL27X" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codshift        := hcm_util.get_string_t(json_obj,'p_codshift');
    p_codcalen        := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_dtestrt         := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'ddmmyyyy');
    p_dteend          := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
    v_codcalen      varchar2(100 char);
    v_codshift      varchar2(100 char);
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcalen is not null then
      begin
        select codcodec
          into v_codcalen
          from tcodwork
          where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodwork');
        return;
      end;
    end if;

    if p_codshift is not null then
      begin
        select codshift
          into v_codshift
          from tshiftcd
          where codshift = p_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tshiftcd');
        return;
      end;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
    end if;
  end check_index;
  --
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    obj_result  json_object_t;
    v_rcnt      number := 0;
    v_exists    boolean := false;
    v_flgsecu   boolean := true;

    cursor c_tattence is
      select att.codcalen,
             att.codshift,
             att.dtework,
             att.timstrtw,
             att.timendw,
             att.typwork,
             att.codempid,
             emp.codcomp,
             emp.codpos
        from tattence att,temploy1 emp
       where att.codempid = emp.codempid
         and att.codcomp  like p_codcomp || '%'
         and att.codcalen = nvl(p_codcalen, att.codcalen)
         and att.codshift = nvl(p_codshift, att.codshift)
         and att.dtework  between p_dtestrt and p_dteend
       order by att.codcalen, att.codshift, att.dtework, att.codcomp,att.codempid;

  begin
    obj_row     := json_object_t();
    obj_result  := json_object_t();
    
    for r_tattence in c_tattence loop
      v_exists    := true;

      v_flgsecu := secur_main.secur2(r_tattence.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcalen', r_tattence.codcalen || ' - ' || get_tcodec_name('TCODWORK', r_tattence.codcalen, global_v_lang));
        obj_data.put('codshift', r_tattence.codshift || ' - ' || r_tattence.timstrtw || ' - ' || r_tattence.timendw);
        obj_data.put('dtework', to_char(r_tattence.dtework,'dd/mm/yyyy'));
        obj_data.put('typwork', r_tattence.typwork);
        obj_data.put('image', get_emp_img(r_tattence.codempid));
        obj_data.put('codempid', r_tattence.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r_tattence.codempid, global_v_lang));
        obj_data.put('codcomp', r_tattence.codcomp);
        obj_data.put('codpos', r_tattence.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r_tattence.codpos, global_v_lang));
        obj_row.put(to_char(v_rcnt-1), obj_data);
      end if;
    end loop;

    if v_exists then
      if obj_row.get_size > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tattence');
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  --
end HRAL27X;

/
