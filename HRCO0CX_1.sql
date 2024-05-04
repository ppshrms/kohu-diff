--------------------------------------------------------
--  DDL for Package Body HRCO0CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO0CX" AS

  procedure initial_value (json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_jobgroup          := hcm_util.get_string_t(json_obj, 'p_jobgroup');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_flgsecu             boolean := false;
    v_codcompy            tcenter.codcompy%type;
    v_codpos              tjobpos.codpos%type;
    v_jobgroup            tjobgroup.jobgroup%type;
    v_codtency            tcomptnc.codtency%type;
    v_chk_codcompy        number;
  begin
    if (p_codcomp is null) and (p_codpos is null) and (p_jobgroup is null) then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codcomp is not null then
      begin
        select count(codcompy)
          into v_chk_codcompy
          from tcenter
         where codcomp like p_codcomp||'%';
      end;
      if v_chk_codcompy < 1 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end if;
      v_flgsecu := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang,'codcomp');
        return;
      end if;
    end if;

    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos like p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tpostn');
        return;
      end;
    end if;

    if p_jobgroup is not null then
      begin
        select distinct(jobgroup)
          into v_jobgroup
          from tjobgroup
         where jobgroup like p_jobgroup;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tjobgroup');
          return;
      end;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
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
    v_rcnt              number := 0;
    v_data_found        boolean := false;
    v_secur             boolean := false;
    v_flgsecu           boolean := false;

    cursor cl is
      select a.codcomp, a.codpos, a.jobgroup, b.codtency, b.codskill, b.score
        from tjobpos a, tjobposskil b
       where a.codcomp  = b.codcomp
         and a.codpos   = b.codpos
         and a.codcomp  like p_codcomp || '%'
         and a.codpos   = nvl(p_codpos, a.codpos)
         and a.jobgroup = nvl(p_jobgroup, a.jobgroup)
       order by a.jobgroup, a.codpos, a.codcomp, b.codtency, b.codskill;

  begin

    obj_row := json_object_t();
    for r1 in cl loop
      v_data_found    := true;
      v_flgsecu := secur_main.secur7(r1.codcomp, global_v_coduser);
      if v_flgsecu then
        v_secur         := true;
        v_rcnt          := v_rcnt + 1;
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('jobgroup', r1.jobgroup);
        obj_data.put('desc_jobgroup',get_tcodjobgrp_name(r1.jobgroup, global_v_lang));
        obj_data.put('codtency', r1.codtency);
        obj_data.put('desc_codtency', get_tcomptnc_name(r1.codtency, global_v_lang));
        obj_data.put('codskill', r1.codskill);
        obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL', r1.codskill, global_v_lang));
        obj_data.put('score', r1.score);

        obj_row.put(to_char(v_rcnt-1), obj_data);
      end if;
    end loop;

    if (v_data_found) then
      if (not v_secur) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tjobposskil');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRCO0CX;

/
