--------------------------------------------------------
--  DDL for Package Body HRAL5DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5DX" as
-- last update: 21/03/2018 10:20:00
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
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codempid is not null then
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
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flgsecur         varchar2(1 char) := 'N';
    v_set_date         varchar2(100 char);
    v_real_date        varchar2(100 char);
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);
    v_comlevel         number;
    v_oldval           varchar2(100 char);
    v_newval           varchar2(100 char);
    v_desfld           varchar2(100 char);
    v_check_secur      boolean;
    cursor c1 is
      select a.rowid, a.dteupd, a.coduser, a.codempid, a.codleave, a.dtework,
             a.desfld, a.desold, a.desnew, b.numlvl, b.codcomp, a.flgwork, a.numseq
        from tlogleav a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid = nvl(p_codempid, a.codempid)
         and b.codcomp like p_codcomp || '%'
         and a.dtework between p_dtestrt and p_dteend
     order by a.dteupd, a.coduser, a.codempid,
              a.codleave, a.dtework, a.numseq;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      v_flgdata            := 'Y';
      v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur        := 'Y';

        v_set_date       := '';
        v_real_date      := '';

        v_oldval          := r1.desold;
        if v_oldval = ':' then
          v_oldval        := '';
        elsif v_oldval not like '%:%' and REGEXP_LIKE(v_oldval, '^[[:digit:]]+$') and r1.desfld <> 'TIMPRGNT' then
          v_oldval        := hcm_util.convert_minute_to_hour(v_oldval);
        end if;

        v_newval          := r1.desnew;
        if v_newval = ':' then
          v_newval        := '';
        elsif v_newval not like '%:%' and  REGEXP_LIKE(v_newval, '^[[:digit:]]+$') and r1.desfld <> 'TIMPRGNT' then
          v_newval        := hcm_util.convert_minute_to_hour(v_newval);
        end if;

        v_desfld      := r1.desfld;
        if v_desfld = 'TIMSTRT' then
          v_desfld := get_label_name('HRAL52UC2',global_v_lang,'90');
        elsif v_desfld = 'TIMEND' then
          v_desfld := get_label_name('HRAL52UC2',global_v_lang,'100');
        elsif v_desfld = 'QTYMIN' then
          v_desfld := get_label_name('HRAL52UC2',global_v_lang,'110');
        elsif v_desfld = 'TIMPRGNT' then
          v_desfld := get_label_name('HRAL52UC1',global_v_lang,'110');
        end if;

        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
        obj_data.put('timupd', to_char(r1.dteupd, 'HH24:MI:SS'));
        obj_data.put('dteupd2', to_char(r1.dteupd,'dd/mm/yyyy hh24:mi:ss'));
        obj_data.put('user', r1.coduser);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('dteleave', to_char(r1.dtework, 'DD/MM/YYYY'));
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('remark', v_desfld);
        obj_data.put('oldval', v_oldval);
        obj_data.put('newval', v_newval);
        obj_data.put('flgwork', r1.flgwork);
        obj_data.put('numseq', r1.numseq);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlogleav');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
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

end HRAL5DX;

/
