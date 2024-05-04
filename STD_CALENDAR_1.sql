--------------------------------------------------------
--  DDL for Package Body STD_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_CALENDAR" AS
  procedure check_index is
  BEGIN
    if p_codempid is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      begin
        select codcomp
        into p_codcomp
        from TEMPLOY1
        where codempid = p_codempid;
      exception when no_data_found then
        p_codcomp := '';
      end;
    end if;
    if p_year is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;
  procedure initial_value(json_str in clob) is
    json_obj json_object_t;
  begin
    json_obj := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid              := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codempid_query        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year                  := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codcomp               := get_codcompy(p_codempid);

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  PROCEDURE gen_typwork(json_str_output out CLOB) IS
    obj_row json_object_t;
    v_row   NUMBER := 0;

    cursor c_typwork is
      select a.codempid,a.dtework,a.typwork,a.codshift,
             b.timstrtw,b.timendw,b.qtydaywk
        from tattence a,tshiftcd b
       where a.codshift  = b.codshift(+)
         and a.codempid  = p_codempid
         and to_char(a.dtework,'yyyy') = p_year
       order by a.codempid,a.dtework,a.typwork,a.codshift;
  BEGIN
    obj_row := json_object_t();

      FOR r1 IN c_typwork loop
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('codempid', nvl(p_codempid, ' '));
        obj_data.put('dtework', nvl(to_char(r1.dtework, 'DD/MM/YYYY'),''));
        obj_data.put('typwork', nvl(r1.typwork,''));
        obj_data.put('desc_typwork', nvl(get_tlistval_name('TYPWRKFUL',r1.typwork,global_v_lang),''));
        obj_data.put('codshift', nvl(r1.codshift,''));
        obj_data.put('desc_codshift', nvl(get_tshiftcd_name(r1.codshift,global_v_lang),''));
        obj_data.put('timstrtw', nvl(to_char(to_date(r1.timstrtw,'hh24mi'),'hh24:mi'),''));
        obj_data.put('timendw', nvl(to_char(to_date(r1.timendw,'hh24mi'),'hh24:mi'),''));
        obj_data.put('qtydaywk', nvl(hcm_util.convert_minute_to_hour(r1.qtydaywk) || ' Hrs',''));
        obj_data.put('dteyear', p_year);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  PROCEDURE get_typwork(json_str_input IN CLOB, json_str_output out CLOB) IS
  begin
    initial_value(json_str_input);
    check_index;
    IF param_msg_error IS NULL THEN
      gen_typwork(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
END STD_CALENDAR;

/
