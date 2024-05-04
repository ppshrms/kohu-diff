--------------------------------------------------------
--  DDL for Package Body HRBF4BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4BX" AS
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

    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dteyrest          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyrest'));
    p_dteyreen          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyreen'));
    p_flginput          := to_char(hcm_util.get_number_t(json_obj, 'p_flginput'));
    p_dteyre            := to_number(hcm_util.get_number_t(json_obj, 'p_dteyre'));
    p_dtemth            := to_number(hcm_util.get_number_t(json_obj, 'p_dtemth'));
    p_codobf            := hcm_util.get_string_t(json_obj, 'p_codobf');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid_query is not null then
      begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codempid_query;
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
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
    v_dteyre           tobfsum.dteyre%type := 0;

    cursor c1 is
      select a.codempid, a.codobf, a.dteyre, a.dtemth, b.typepay, a.qtywidrw, a.qtytwidrw, a.amtwidrw, b.typebf 
        from tobfsum a, tobfcde b
       where a.codobf = b.codobf
         and codempid = p_codempid_query
         and dteyre   between p_dteyrest and p_dteyreen
         and dtemth   <> 13
       order by dteyre, dtemth, codobf;
    cursor c2 is
      select a.codempid, a.codobf, a.dteyre, a.dtemth, b.typepay, a.qtywidrw, a.qtytwidrw, a.amtwidrw, b.typebf 
        from tobfsum a, tobfcde b
       where a.codobf = b.codobf
         and codempid = p_codempid_query
         and dteyre   between p_dteyrest and p_dteyreen
         and dtemth   <> 13
       order by codobf, dteyre, dtemth;
  begin
    obj_row       := json_object_t();

    if p_flginput = '1' then
      for i in c1 loop
        if v_rcnt > 0 and i.dteyre <> v_dteyre then
          v_rcnt      := v_rcnt+1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('flgsum', 'Y');
          obj_data.put('qtytwidrw', get_label_name('HRBF4BX1', global_v_lang, 190));
          obj_data.put('amtwidrw', to_char(v_sum));
          obj_row.put(to_char(v_rcnt - 1), obj_data);
          v_sum       := 0;
        end if;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', '');
        obj_data.put('codempid', i.codempid);
        obj_data.put('dteyre', to_char(i.dteyre));
        obj_data.put('dtemth', to_char(i.dtemth));
        obj_data.put('desc_dtemth', get_tlistval_name('MONTH', i.dtemth, global_v_lang));
        obj_data.put('codobf', i.codobf);
        obj_data.put('desc_codobf', get_tobfcde_name(i.codobf, global_v_lang));
        obj_data.put('qtywidrw', to_char(i.qtywidrw, 'fm99,999,990'));
        if i.typepay = 'C' then
          obj_data.put('qtywidrw', to_char(i.qtywidrw, 'fm99,999,990.90'));
        end if;
        obj_data.put('qtytwidrw', i.qtytwidrw);
        obj_data.put('amtwidrw', i.amtwidrw);
        obj_data.put('typepay', i.typepay);
        v_sum       := v_sum + i.amtwidrw;
        v_total     := v_total + i.amtwidrw;
        v_dteyre    := i.dteyre;
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;

      if obj_row.get_size > 0 then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtytwidrw', get_label_name('HRBF4BX1', global_v_lang, 190));
        obj_data.put('amtwidrw', to_char(v_sum));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtytwidrw', get_label_name('HRBF4BX1', global_v_lang, 200));
        obj_data.put('amtwidrw', to_char(v_total));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    else
      for j in c2 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', j.codempid);
        obj_data.put('dteyre', to_char(j.dteyre));
        obj_data.put('dtemth', to_char(j.dtemth));
        obj_data.put('desc_dtemth', get_tlistval_name('MONTH', j.dtemth, global_v_lang));
        obj_data.put('codobf', j.codobf);
        obj_data.put('desc_codobf', get_tobfcde_name(j.codobf, global_v_lang));
--        obj_data.put('qtywidrw', j.qtywidrw);
        obj_data.put('qtywidrw', to_char(j.qtywidrw, 'fm99,999,990'));
        if j.typepay = 'C' then
          obj_data.put('qtywidrw', to_char(j.qtywidrw, 'fm99,999,990.90'));
        end if;
        obj_data.put('qtytwidrw', j.qtytwidrw);
        obj_data.put('amtwidrw', j.amtwidrw);
        obj_data.put('typepay', j.typepay);
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;
    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfsum');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure check_tobfinf AS
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid_query is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid_query, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
  end check_tobfinf;

  procedure get_tobfinf(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_tobfinf;
    if param_msg_error is null then
      gen_tobfinf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tobfinf;

  procedure gen_tobfinf (json_str_output out clob) AS
    obj_rows           json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_amount           number := 0;

    cursor c1 is
      select a.numvcher, a.codempid, a.codcomp, a.dtereq, a.codobf, a.typrelate, a.qtywidrw, a.amtwidrw, a.codappr, a.dteappr, b.typepay, b.amtvalue, b.typebf
        from tobfinf a, tobfcde b
       where a.codobf   = b.codobf
         and a.codempid = p_codempid_query
         and a.codobf   = p_codobf
         and to_number(to_char(a.dtereq, 'YYYY')) = p_dteyre
         and to_number(to_char(a.dtereq, 'MM'))   = p_dtemth
       order by a.dtereq, a.numvcher;
  begin
    obj_rows        := json_object_t();

    for i in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_amount    := 0;
      if i.typebf = 'C' then
        v_amount    := i.amtwidrw;
      else
        v_amount    := i.amtvalue;
      end if; 
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('codobf', i.codobf);
      obj_data.put('dtereq', to_char(i.dtereq, 'DD/MM/YYYY'));
      obj_data.put('numvcher', i.numvcher);
      obj_data.put('typrelate', i.typrelate);
      obj_data.put('desc_typrelate', get_tlistval_name('TYPERELATE', i.typrelate, global_v_lang));
      obj_data.put('qtywidrw', to_char(i.qtywidrw, 'fm99,999,990'));
        if i.typepay = 'C' then
          obj_data.put('qtywidrw', to_char(i.qtywidrw, 'fm99,999,990.90'));
        end if;
      obj_data.put('qtytwidrw', v_amount);
      obj_data.put('amtwidrw', i.amtwidrw);
      obj_data.put('desc_codappr', get_temploy_name(i.codappr, global_v_lang));
      obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
      obj_data.put('typepay', i.typepay);
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    if obj_rows.get_size > 0 then
      json_str_output := obj_rows.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfinf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_tobfinf;
end HRBF4BX;

/
