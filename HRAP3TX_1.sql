--------------------------------------------------------
--  DDL for Package Body HRAP3TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3TX" is
-- last update: 18/09/2020 10:52

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    b_index_dteyreap      := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
    b_index_codcompy      := hcm_util.get_string_t(json_obj,'p_codcompy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt                  number := 0;
    v_flgdata_tkpicmph      varchar2(1 char) := 'N';
    v_flgdata_tkpicmpdp     varchar2(1 char) := 'N';
    v_flgsecu               varchar2(1 char) := 'N';
    v_codempid              varchar2(100 char) := '!@#$';
    flgpass     	          boolean; 
    v_zupdsal   	          varchar2(4);
    v_seqno                 number := 0;
    v_codkpi                varchar2(100);
    v_kpides                tkpidph.kpides%type;

    cursor c1 is 
        select balscore,codkpi,kpides,target
          from tkpicmph
         where dteyreap = b_index_dteyreap
           and codcompy = b_index_codcompy
        order by balscore,codkpi;

    cursor c2 is 
        select codkpino,codcomp,target,kpivalue
          from tkpicmpdp
         where dteyreap = b_index_dteyreap
           and codcompy = b_index_codcompy
           and codkpi = v_codkpi
        order by codkpino,codcomp;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata_tkpicmph := 'Y';
        v_codkpi := i.codkpi;
        for j in c2 loop
            v_flgdata_tkpicmpdp := 'Y';
            flgpass := secur_main.secur7(j.codcomp,global_v_coduser);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('bsc', i.balscore);
                obj_data.put('desc_bsc', get_tlistval_name('BALSCORE',i.balscore,global_v_lang));
                obj_data.put('codkpi', i.codkpi);
                obj_data.put('kpides', i.kpides);
                obj_data.put('target', i.target);

                obj_data.put('codkpino', j.codkpino);
                begin
                    select kpides
                      into v_kpides
                      from tkpicmppl 
                     where dteyreap = b_index_dteyreap 
                       and codcompy  = b_index_codcompy
                       and codkpi  = i.codkpi
                       and codkpino = j.codkpino;
                exception when no_data_found then
                    v_kpides := null;
                end;

                obj_data.put('desc_kpiap', v_kpides);
                obj_data.put('codcomp', j.codcomp);
                obj_data.put('desc_codcompap', get_tcenter_name(j.codcomp,global_v_lang));
                obj_data.put('description', j.target);
                obj_data.put('value', j.kpivalue);

                obj_data.put('dteyreap', b_index_dteyreap);
                obj_data.put('codcompy', b_index_codcompy);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
    end loop;
    if v_flgdata_tkpicmph = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tkpicmph');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgdata_tkpicmpdp = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tkpicmpdp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_data_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean; 

    cursor c1 is
        select objective
          from tobjective
         where dteyreap = b_index_dteyreap
           and codcompy = b_index_codcompy;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('objective', '');
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur7(b_index_codcompy,global_v_coduser);
        if flgpass then
            obj_data.put('coderror', '200');
            obj_data.put('objective', i.objective);
            exit;
        end if;
    end loop;

    json_str_output := obj_data.to_clob;
  end;
  --
end;

/
