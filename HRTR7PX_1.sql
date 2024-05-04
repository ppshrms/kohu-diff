--------------------------------------------------------
--  DDL for Package Body HRTR7PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7PX" AS
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
    p_dtemonthst        := to_number(hcm_util.get_number_t(json_obj, 'p_dtemonthst'));
    p_dtemonthen        := to_number(hcm_util.get_number_t(json_obj, 'p_dtemonthen'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy         tcompny.codcompy%type;
  begin
    if p_codcompy is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = hcm_util.get_codcomp_level(p_codcompy, 1);
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
    v_sum              number := 0;
    v_total            number := 0;
    v_codtparg         varchar2(10 char) := '1';

    cursor c1 is
      select '1' as codtparg, codcours, numclseq, dtetrst, dtetren, qtyppc, numcert, dtecert, amttotexp
        from thisclss
       where codcompy = p_codcompy
         and dteyear  = p_dteyear
         and to_number(dtemonth) between p_dtemonthst and p_dtemonthen
      union
      select codtparg, codcours, numclseq, dtetrst, dtetren, count(codempid), numcert, dtecert, sum(nvl(amtcost, 0))
        from thistrnn a
       where codcomp  like p_codcompy || '%'
         and dteyear  = p_dteyear
         and to_number(dtemonth) between p_dtemonthst and p_dtemonthen
         and codtparg = '2'
       group by codtparg, codcours, numclseq, dtetrst, dtetren, numcert, dtecert
       order by codtparg, codcours, numclseq, dtetrst;
  begin
    obj_row       := json_object_t();

    for i in c1 loop
      if v_rcnt > 0 and i.codtparg <> v_codtparg then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('dtecert', get_label_name('HRTR7PX1', global_v_lang, 150));
        obj_data.put('amttotexp', to_char(v_sum));
        v_sum       := 0;

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG', i.codtparg, global_v_lang));
      obj_data.put('codcours', i.codcours);
      obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
      obj_data.put('numclseq', i.numclseq);
      obj_data.put('dtetrst', to_char(i.dtetrst, 'dd/mm/yyyy'));
      obj_data.put('dtetren', to_char(i.dtetren, 'dd/mm/yyyy'));
      obj_data.put('qtyppc', nvl(i.qtyppc, 0));
      obj_data.put('numcert', i.numcert);
      obj_data.put('dtecert', to_char(i.dtecert, 'dd/mm/yyyy'));
      obj_data.put('amttotexp', to_char(i.amttotexp));
      v_sum       := v_sum + i.amttotexp;
      v_total     := v_total + i.amttotexp;
      v_codtparg  := i.codtparg;

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if obj_row.get_size > 0 then
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgsum', 'Y');
      obj_data.put('dtecert', get_label_name('HRTR7PX1', global_v_lang, 150));
      obj_data.put('amttotexp', to_char(v_sum));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgsum', 'Y');
      obj_data.put('dtecert', get_label_name('HRTR7PX1', global_v_lang, 160));
      obj_data.put('amttotexp', to_char(v_total));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thisclss');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRTR7PX;


/
