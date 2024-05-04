--------------------------------------------------------
--  DDL for Package Body HRAL2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL2HX" as
-- last update: 27/02/2018 12:02
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
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_typabs            := upper(hcm_util.get_string_t(json_obj, 'p_typabs'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'DD/MM/YYYY');

    -- drilldown
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
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

    if p_typabs is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data (json_str_output out clob) is
    v_flgdata               varchar2(1 char) := 'N';
    v_flgsecur              varchar2(1 char) := 'N';
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_rcnt                  number;
    v_codcomp               varchar2(50 char);
    v_lvlst                 number;
    v_lvlen                 number;
    v_comlevel              number;
    v_namcentlvl            varchar2(4000 char);
    v_namcent               varchar2(4000 char);
    v_check_secur           boolean;
    cursor c1 is
      select a.codempid, a.codcomp, a.numlvl, a.codpos, a.dteempmt, a.rowid
        from temploy1 a
       where a.codcomp like p_codcomp || '%' 
         and a.staemp in ('1', '3')
         and a.codempid not in (select distinct(b.codempid)
                                from tlateabs b
                               where trunc(b.dtework) between p_dtestrt and p_dteend
                                 and (
                                      (nvl(b.qtylate,0)         > 0 and '1' = p_typabs)
                                       or (nvl(b.qtyearly,0)    > 0 and '2' = p_typabs)
                                       or (nvl(b.qtyabsent,0)   > 0 and '3' = p_typabs)
                                       or (nvl(b.qtynostam,0)   > 0 and '4' = p_typabs)
                                       or ('5' = p_typabs)
                                      )
                              )
         and  exists (select codempid
                        from tattence b
                       where a.codempid = b.codempid
                         and b.dtework between p_dtestrt and p_dteend) --06/03/2021
    order by codcomp, codempid;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      v_flgdata            := 'Y';
      v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur            := 'Y';
        obj_data             := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcompny_name(r1.codcomp, global_v_lang));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('dteempmt', to_char(r1.dteempmt, 'DD/MM/YYYY'));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tattence');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
--      dbms_lob.createtemporary(json_str_output, true);
--      obj_row.to_clob(json_str_output);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure gen_drilldown (json_str_output out clob) is
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_rcnt                  number;
    cursor c1 is
      select codempid,dtework,typwork,codshift,timstrtw,timendw,timin,timout,codcomp,rowid
        from tattence
       where codempid = p_codempid
         and trunc(dtework) between p_dtestrt and p_dteend
      order by dtework; --06/03/2021
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
      obj_data.put('typwork', r1.typwork);
      obj_data.put('codshift', get_tshiftcd_name(r1.codshift,global_v_lang));
      obj_data.put('timstrtw', char_time_to_format_time(r1.timstrtw));
      obj_data.put('timendw', char_time_to_format_time(r1.timendw));
      obj_data.put('timin', char_time_to_format_time(r1.timin));
      obj_data.put('timout', char_time_to_format_time(r1.timout));

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_drilldown;

  procedure get_drilldown (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_drilldown(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_drilldown;

end HRAL2HX;

/
