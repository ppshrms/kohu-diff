--------------------------------------------------------
--  DDL for Package Body HRES68X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES68X" AS
-- last update: 26/02/2020 10:39

  procedure initial_value(json_str in clob) AS
  json_obj        json_object_t;
  BEGIN
    json_obj            := json_object_t(json_str);

    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));
  END initial_value;
  --
  procedure check_index is
  begin
    if b_index_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codempid');
      return;
    else
    if global_v_codempid <> b_index_codempid then
          param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
          if param_msg_error is not null then
            return;
          end if;
      end if;
    end if;
  end;
  --
  procedure get_data_emp(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      gen_data_emp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_emp(json_str_output out clob) is
    obj_data        json_object_t;
    temploy_name      varchar2(500 char);
  begin
    temploy_name := get_temploy_name(b_index_codempid,global_v_lang);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', b_index_codempid);
    obj_data.put('desc_codempid', temploy_name);
    obj_data.put('year', '');
    obj_data.put('month', '');
    json_str_output := obj_data.to_clob;
  end;
  --

  procedure get_calendar(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_calendar(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_calendar;

  procedure gen_calendar(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    objLang         json_object_t;
    v_holdy_leave varchar2(2000 char);
    v_holdy_time varchar2(100 char);
    v_rcnt          number;
    --<<User37 #5097 Final Test Phase 1 V11 24/03/2021
    v_desholdye     varchar2(200 char);
    v_desholdyt     varchar2(200 char);
    v_desholdy3     varchar2(200 char);
    v_desholdy4     varchar2(200 char);
    v_desholdy5     varchar2(200 char);
    v_desholdy      varchar2(200 char);
    v_codcomp     varchar2(4000 char);
    v_codcalen    varchar2(4000 char);
    v_comp_holidy tgholidy.codcomp%type;
    --v_desholdy    varchar2(4000 char);
    --v_holdy_comp  varchar2(2000 char);
    --v_holdy_leave varchar2(2000 char);
    -->>User37 #5097 Final Test Phase 1 V11 24/03/2021
    cursor c_calendar is
      --<<User37 #5097 Final Test Phase 1 V11 24/03/2021
      select a.dtework,a.codshift,a.typwork
        from tattence a
       where a.codempid = b_index_codempid
         and to_char(a.dtework,'yyyy') = nvl(p_year, to_char(sysdate, 'YYYY'))
    order by a.dtework asc;
      /*select a.dtework,a.codshift,nvl(b.typwork,a.typwork) typwork,b.desholdye,b.desholdyt,b.desholdy3,b.desholdy4,b.desholdy5,
             decode(global_v_lang, '101', b.desholdye,
                                   '102', b.desholdyt,
                                   '103', b.desholdy3,
                                   '104', b.desholdy4,
                                   '105', b.desholdy5,
                                   '') desholdy
--             c.codleave, c.timstrt, c.timend    , tleavetr c
        from tattence a, tholiday b
       where hcm_util.get_codcomp_level(a.codcomp,1) = b.codcompy(+)
         and a.dtework  = b.dtedate(+)
--         and a.codempid = c.codempid(+)
--         and a.dtework  = c.dtework(+)
         and a.codempid = b_index_codempid
         and to_char(a.dtework,'yyyy') = nvl(p_year, to_char(sysdate, 'YYYY'))
    order by a.dtework asc;*/-->>User37 #5097 Final Test Phase 1 V11 24/03/2021
  begin
    v_rcnt     := 0;
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    for i in c_calendar loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('dteyear',to_char(i.dtework,'yyyy'));
      obj_data.put('dtedate',to_char(i.dtework, 'dd/mm/yyyy'));
      obj_data.put('codshift',i.codshift);
      obj_data.put('typwork',i.typwork);
      --<<User37 #5097 Final Test Phase 1 V11 24/03/2021
      v_desholdye   := '';
      v_desholdyt   := '';
      v_desholdy3   := '';
      v_desholdy4   := '';
      v_desholdy5   := '';
      v_desholdy    := '';
      obj_data.put('desholdye','');
      obj_data.put('desholdyt','');
      obj_data.put('desholdy3','');
      obj_data.put('desholdy4','');
      obj_data.put('desholdy5','');
      -->>User37 #5097 Final Test Phase 1 V11 24/03/2021
--      obj_data.put('codleave',i.codleave);
--      obj_data.put('timstrt',i.timstrt);
--      obj_data.put('timend',i.timend);
      if (nvl(i.typwork,'@') = 'L') then
--        obj_data.put('desholdy',get_tleavecd_name(i.codleave,global_v_lang));
        begin
            select listagg(codleave || ' - ' || get_tleavecd_name(codleave, global_v_lang), ', ') within group (order by codleave) "codleave",
               listagg(substr(timstrt, 1, 2) || ':' || substr(timstrt, 3) || ' - ' || substr(timend, 1, 2) || ':' || substr(timend, 3), ', ') within group (order by timstrt) "timstrt"
              into v_holdy_leave,v_holdy_time
              from tleavetr
             where codempid = b_index_codempid
               and dtework = i.dtework;
          exception when no_data_found then
            v_holdy_leave := null;
            v_holdy_time := null;
          end;
          obj_data.put('timstrt',v_holdy_time);
          obj_data.put('desholdy',v_holdy_leave);

      else
        --<<User37 #5097 Final Test Phase 1 V11 24/03/2021
        --obj_data.put('desholdy',i.desholdy);
        if (nvl(i.typwork,'@') != 'W') then
            begin
              select codcomp, codcalen
                into v_codcomp, v_codcalen
                from temploy1
               where codempid = b_index_codempid;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
              return;
            end;
            v_comp_holidy   := get_tgholidy_codcomp(v_codcomp,v_codcalen,p_year);
            begin
              select decode(global_v_lang , '101', desholdye
                                          , '102', desholdyt
                                          , '103', desholdy3
                                          , '104', desholdy4
                                          , '105', desholdy5
                                          , '') desholdy,desholdye,desholdyt,desholdy3,desholdy4,desholdy5
               into v_desholdy,v_desholdye,v_desholdyt,v_desholdy3,v_desholdy4,v_desholdy5
               from tgholidy
              where codcomp     = v_comp_holidy
                and dteyear     = nvl(p_year, to_char(sysdate, 'YYYY'))
                and codcalen    = v_codcalen
                and dtedate     = i.dtework
                and typwork     = i.typwork
              order by codcomp desc;
            exception when no_data_found then
              null;
            end;
            obj_data.put('desholdy',v_desholdy);
        end if;
        -->>User37 #5097 Final Test Phase 1 V11 24/03/2021
      end if;
     -- obj_data.put('desholdy',i.desholdy);
      /*User37 #5097 Final Test Phase 1 V11 24/03/2021 obj_data.put('desholdye',i.desholdye);
      obj_data.put('desholdyt',i.desholdyt);
      obj_data.put('desholdy3',i.desholdy3);
      obj_data.put('desholdy4',i.desholdy4);
      obj_data.put('desholdy5',i.desholdy5);*/

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_calendar;


  procedure gen_shift(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row           number := 0;
    v_dte_temp_st   date;
    v_dte_temp_en   date;
    v_dte_st        date;
    v_dte_en        date;
    v_dte_text      varchar2(10 char) := '01/01/2019';
    cursor c1 is
        select codshift, timstrtw, timendw, qtydaywk
          from tshiftcd
      order by codshift;
  begin
    obj_row    := json_object_t();

    for i in c1 loop
     v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codshift', i.codshift);
      obj_data.put('desc_codshift', get_tshiftcd_name(i.codshift, global_v_lang));
      obj_data.put('timshift', substr(i.timstrtw, 1, 2)||':'||substr(i.timstrtw, 3, 2)||' - '||substr(i.timendw, 1, 2)||':'||substr(i.timendw, 3, 2));
      obj_row.put(to_char(v_row-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end ;


  procedure get_shift(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_shift(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;


END HRES68X;

/
