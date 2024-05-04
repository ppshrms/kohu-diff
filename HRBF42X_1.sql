--------------------------------------------------------
--  DDL for Package Body HRBF42X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF42X" AS
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

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DDMMYYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DDMMYYYY');
    p_typrep            := to_char(hcm_util.get_number_t(json_obj, 'p_typrep'));
    p_typpay            := to_char(hcm_util.get_number_t(json_obj, 'p_typpay'));
    p_numvcomp          := hcm_util.get_string_t(json_obj, 'p_numvcomp');
    p_codobf            := hcm_util.get_string_t(json_obj, 'p_codobf');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_codcomp           temploy1.codcomp%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcomp
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, '', 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_typpay = '3' then
      p_typpay := '%';
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  function get_amount (v_numvcomp tobfcomp.numvcomp%type, v_codobf tobfcompd.codobf%type) return number is
    v_count         number := 0;
  begin
    begin
      select count(a.codempid)
        into v_count
        from tobfinf a, temploy1 b
       where a.numvcomp = v_numvcomp
         and a.codobf   = v_codobf
         and a.codempid = b.codempid
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and 0 <> (select count(ts.codcomp)
                     from tusrcom ts
                    where ts.coduser = global_v_coduser
                      and b.codcomp like ts.codcomp||'%'
                      and rownum <= 1 );
    exception when no_data_found then
      null;
    end;
    return v_count;
  end get_amount;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;
    v_additional_year   number := 0;
    v_table             varchar2(10 char) := 'tobfcomp';

    cursor c1 is
     select a.numvcomp, a.dtereq, a.codreq, b.codobf,
            c.codunit, b.qtywidrw, c.amtvalue, b.amtwidrw,
            a.codappr, a.dteappr, a.dtepay, a.codcomp,
            a.dteyrepay, a.dtemthpay, a.numperiod
       from tobfcomp a, tobfcompd b, tobfcde c
      where a.numvcomp = b.numvcomp
        and b.codobf   = c.codobf
        and a.codcomp  like p_codcomp || '%'
        and a.dtereq   between p_dtestrt and p_dteend
        and a.typepay  like p_typpay
      order by a.numvcomp, b.codobf;
    cursor c2 is
     select a.numvcher, a.dtereq, a.codempid, a.codobf,
            c.codunit, a.qtywidrw, c.amtvalue, a.amtwidrw,
            a.codappr, a.dteappr, a.dtepay, b.codcomp,
            a.dteyrepay, a.dtemthpay, a.numperiod
       from tobfinf a, temploy1 b, tobfcde c
      where a.codempid = b.codempid
        and a.codobf   = c.codobf
        and b.codcomp  like p_codcomp || '%'
        and a.dtereq   between p_dtestrt and p_dteend
        and a.typepay  like p_typpay
      order by a.numvcher;
  begin
    obj_rows            := json_object_t();
    v_additional_year   := hcm_appsettings.get_additional_year;
    if p_typrep = '1' then
      v_table     := 'tobfcomp';
      for i in c1 loop
        v_found     := true;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
          if secur_main.secur2(i.codreq, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codcomp', i.codcomp);
            obj_data.put('dtereqst', to_char(p_dtestrt, 'DD/MM/YYYY'));
            obj_data.put('dtereqen', to_char(p_dteend, 'DD/MM/YYYY'));
            obj_data.put('typrep', p_typrep);
            obj_data.put('typpay', p_typpay);
            obj_data.put('numvcomp', i.numvcomp);
            obj_data.put('dtereq', to_char(i.dtereq, 'DD/MM/YYYY'));
            obj_data.put('codempid', i.codreq);
            obj_data.put('desc_codempid', get_temploy_name(i.codreq, global_v_lang));
            obj_data.put('codobf', i.codobf);
            obj_data.put('desc_codobf', get_tobfcde_name(i.codobf, global_v_lang));
            obj_data.put('desc_codunit', get_tcodunit_name(i.codunit, global_v_lang));
            obj_data.put('qtywidrw', i.qtywidrw);
            obj_data.put('amtvalue', i.amtvalue);
            obj_data.put('amtwidrw', i.amtwidrw);
            obj_data.put('print_status', get_label_name('HRBF42X1', global_v_lang, 230));
            obj_data.put('desc_status', '<div class="button-sm _bg-green"><i class="fa fa-check-circle"></i>' || get_label_name('HRBF42X1', global_v_lang, 230) || '</div>');
            obj_data.put('amount', get_amount(i.numvcomp, i.codobf));
            obj_data.put('dtepay', to_char(i.dtepay, 'DD/MM/YYYY'));
            obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
            obj_data.put('codappr', i.codappr);
            obj_data.put('desc_codappr', get_temploy_name(i.codappr, global_v_lang));
            obj_data.put('period', i.numperiod || ' ' || get_tlistval_name('MONTH', i.dtemthpay, global_v_lang) || ' ' || (to_number(i.dteyrepay) + v_additional_year));

            obj_rows.put(to_char(v_rcnt - 1), obj_data);
          end if;
        end if;
      end loop;
    else
      v_table     := 'tobfinf';
      for j in c2 loop
        v_found     := true;
        if secur_main.secur2(j.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp', j.codcomp);
          obj_data.put('dtereqst', to_char(p_dtestrt, 'DD/MM/YYYY'));
          obj_data.put('dtereqen', to_char(p_dteend, 'DD/MM/YYYY'));
          obj_data.put('typrep', p_typrep);
          obj_data.put('typpay', p_typpay);
          obj_data.put('numvcomp', j.numvcher);
          obj_data.put('dtereq', to_char(j.dtereq, 'DD/MM/YYYY'));
          obj_data.put('codempid', j.codempid);
          obj_data.put('desc_codempid', get_temploy_name(j.codempid, global_v_lang));
          obj_data.put('codobf', j.codobf);
          obj_data.put('desc_codobf', get_tobfcde_name(j.codobf, global_v_lang));
          obj_data.put('desc_codunit', get_tcodunit_name(j.codunit, global_v_lang));
          obj_data.put('qtywidrw', j.qtywidrw);
          obj_data.put('amtvalue', j.amtvalue);
          obj_data.put('amtwidrw', j.amtwidrw);
          obj_data.put('print_status', get_label_name('HRBF42X1', global_v_lang, 230));
          obj_data.put('desc_status', '<div class="button-sm _bg-green"><i class="fa fa-check-circle"></i>' || get_label_name('HRBF42X1', global_v_lang, 230) || '</div>');
          obj_data.put('dtepay', to_char(j.dtepay, 'DD/MM/YYYY'));
          obj_data.put('dteappr', to_char(j.dteappr, 'DD/MM/YYYY'));
          obj_data.put('codappr', j.codappr);
          obj_data.put('desc_codappr', get_temploy_name(j.codappr, global_v_lang));
          obj_data.put('period', j.numperiod || ' ' || get_tlistval_name('MONTH', j.dtemthpay, global_v_lang) || ' ' || (to_number(j.dteyrepay) + v_additional_year));

          obj_rows.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
    end if;
    if v_found then
      if obj_rows.get_size > 0 then
        json_str_output := obj_rows.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure get_tobfinf(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tobfinf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tobfinf;

  /*function gen_tobfinf(v_codempid tobfinf.codempid%type, v_codobf tobfinf.codobf%type, v_numvcomp tobfinf.numvcomp%type, v_dtereqst tobfinf.dtereq%type, v_dtereqen tobfinf.dtereq%type) return number is
    v_qtywidrw        tobfinf.qtywidrw%type := 0;
  begin
    begin
      select nvl(sum(qtywidrw), 0)
        into v_qtywidrw
        from tobfinf
       where codempid = v_codempid
         and dtereq   between v_dtereqst and v_dtereqen
         and codobf   = v_codobf
         and nvl(numvcomp, '@#$%') <> v_numvcomp;
    exception when no_data_found then
      null;
    end;
    return v_qtywidrw;
  end gen_tobfinf;*/

  function get_tobfsum(p_codempid tobfinf.codempid%type, p_codobf tobfinf.codobf%type, p_dtereq tobfinf.dtereq%type) return number is
    v_qtywidrw        tobfinf.qtywidrw%type := 0;
  begin
    begin
      select nvl(qtywidrw,0)
        into v_qtywidrw
        from tobfsum
       where codempid = p_codempid
         and dteyre   = to_char(p_dtereq,'YYYY')
         and dtemth   = 13
         and codobf   = p_codobf;
    exception when no_data_found then
      null;
    end;
    return v_qtywidrw;
  end;

  procedure gen_tobfinf (json_str_output out clob) AS
    obj_rows           json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_amount           number := 0;

    cursor c1 is
      select a.numvcher, a.codempid, a.qtywidrw, b.codpos, b.staemp, nvl(b.dteefpos, b.dteempmt) dtework,a.dtereq
        from tobfinf a, temploy1 b
       where a.codempid = b.codempid
         and numvcomp   = p_numvcomp
         and codobf     = p_codobf
       order by a.codempid;
  begin
    obj_rows        := json_object_t();

    for i in c1 loop
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numvcher', i.numvcher);
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('qtywidrw', i.qtywidrw);
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('staemp', i.staemp);
        obj_data.put('desc_staemp', get_tlistval_name('NAMESTAT', i.staemp, global_v_lang));
        obj_data.put('dtework', to_char(i.dtework, 'DD/MM/YYYY'));
        obj_data.put('amount', get_tobfsum(i.codempid, p_codobf, i.dtereq)); ---- , gen_tobfinf(i.codempid, p_codobf, p_numvcomp, p_dtestrt, p_dteend));
        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    if obj_rows.get_size > 0 then
      json_str_output := obj_rows.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfinf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_tobfinf;
end HRBF42X;

/
