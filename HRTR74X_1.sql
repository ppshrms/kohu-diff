--------------------------------------------------------
--  DDL for Package Body HRTR74X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR74X" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy        tcompny.codcompy%type;
  begin
    if p_codcompy is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
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

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_numclseq         number;
    v_qtyppc           thisclss.qtyppc%type;
    v_amtcost          number;
    v_personn          number;

    cursor c1 is
      select codcate, codcours, codtparg, qtyptbdg, amtpbdg, qtynumcl
        from tyrtrpln
       where codcompy = p_codcompy
         and dteyear  = p_dteyear
         and qtynumcl > 0
       order by codcate, codcours, codtparg;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      begin
        select count(numclseq), sum(qtyppc), sum(qtyppc * amtcost)
          into v_numclseq, v_qtyppc, v_amtcost
          from thisclss
         where codcompy = p_codcompy
           and dteyear  = p_dteyear
           and codcours = i.codcours;
      exception when no_data_found then
        v_numclseq      := 0;
        v_qtyppc        := 0;
        v_amtcost       := 0;
      end;
      if i.qtynumcl <> v_numclseq then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        v_personn   := (nvl(i.qtyptbdg, 0) - nvl(v_qtyppc, 0));
        if v_personn < 0 then
          v_personn := 0;
        end if;
        obj_data.put('coderror', '200');
        obj_data.put('codcompy', p_codcompy);
        obj_data.put('dteyear', p_dteyear);
        obj_data.put('desc_codcate', get_tcodec_name('TCODCATE', i.codcate, global_v_lang));
        obj_data.put('codcours', i.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
        obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG', i.codtparg, global_v_lang));
        obj_data.put('qtyptbdg', nvl(i.qtyptbdg, 0));
        obj_data.put('amtpbdg', nvl(i.amtpbdg, 0));
        obj_data.put('qtynumcl', nvl(i.qtynumcl, 0));
        obj_data.put('numclseq', nvl(v_numclseq, 0));
        obj_data.put('qtyppc', nvl(v_qtyppc, 0));
        obj_data.put('genn', (nvl(i.qtynumcl, 0) - nvl(v_numclseq, 0)));
        obj_data.put('personn', v_personn);
        obj_data.put('remaining_budget', ((nvl(i.qtyptbdg, 0) * nvl(i.amtpbdg, 0)) - nvl(v_amtcost, 0)));

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tyrtrpln');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRTR74X;


/
