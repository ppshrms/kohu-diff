--------------------------------------------------------
--  DDL for Package Body HRRC5DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC5DX" AS
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
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_flginput          := hcm_util.get_string_t(json_obj, 'p_flginput');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codpos            temploy1.codpos%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
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
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;
    v_chken             varchar2(10 char) := hcm_secur.get_v_chken;

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos, a.dteefpos, b.qtyguar qtyguar_job, b.amtcolla amtcolla_job, c.qtyquar, 
             stddec(c.amtcolla,c.codempid,v_chken) amtcolla, stddec(c.amtbudguar,c.codempid,v_chken) amtbudguar
        from temploy1 a ,tjobcode b, ttotguar c
       where a.codempid = c.codempid
         and a.codjob   = b.codjob 
         and a.codcomp  like p_codcomp || '%'
         and a.codpos   = nvl(p_codpos, a.codpos)
         and ((p_flginput   = '1' and
             (nvl(b.amtguarntr, 0) > nvl(stddec(c.amtbudguar,c.codempid,v_chken), 0) or
              nvl(b.amtcolla, 0)   > nvl(stddec(c.amtcolla,c.codempid,v_chken), 0)))
         or (p_flginput   = '2' and
             (nvl(b.amtguarntr, 0) <  nvl(stddec(c.amtbudguar,c.codempid,v_chken), 0) or
              nvl(b.amtcolla, 0)   < nvl(stddec(c.amtcolla,c.codempid,v_chken), 0))))
       order by a.codcomp, a.codpos, a.codempid;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_found             := true;
      if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('dteefpos', to_char(i.dteefpos, 'DD/MM/YYYY'));
        obj_data.put('qtyguar_job', nvl(i.qtyguar_job, 0));
        obj_data.put('amtcolla_job', nvl(i.amtcolla_job, 0));
        obj_data.put('qtyquar', nvl(i.qtyquar, 0));
        obj_data.put('amtcolla', nvl(i.amtcolla, 0));
        obj_data.put('amtbudguar', nvl(i.amtbudguar, 0));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      end if;
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;

  procedure get_tguarntr (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tguarntr(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tguarntr;

  procedure gen_tguarntr (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select a.codempid, a.numseq, a.codempgrt, a.codtitle,
             decode(global_v_lang, '101', a.namguare
                                 , '102', a.namguart
                                 , '103', a.namguar3
                                 , '104', a.namguar4
                                 , '105', a.namguar5
                                 , a.namguare) namguar,
             a.dtegucon, a.dteidexp, a.amtguarntr, a.desrelat, b.staemp
        from tguarntr a, temploy1 b
       where a.codempid  = p_codempid
         and a.codempgrt = b.codempid(+)
       order by a.numseq;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numseq', i.numseq);
      obj_data.put('codempg', i.codempgrt);
      if i.codempgrt is null then
        obj_data.put('desc_codempg', get_tlistval_name('CODTITLE', i.codtitle, global_v_lang) || i.namguar);
      else
        obj_data.put('desc_codempg', get_temploy_name(i.codempgrt, global_v_lang));
      end if;
      obj_data.put('dtegucon', to_char(i.dtegucon, 'DD/MM/YYYY'));
      obj_data.put('dteidexp', to_char(i.dteidexp, 'DD/MM/YYYY'));
      obj_data.put('amtguarntr', nvl(stddec(i.amtguarntr, i.codempid, v_chken), 0));
      obj_data.put('desrelat', i.desrelat);
      obj_data.put('status', i.staemp);
      obj_data.put('desc_status', get_tlistval_name('FSTAEMP', i.staemp, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tguarntr;

  procedure get_tcolltrl (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcolltrl(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tcolltrl;

  procedure gen_tcolltrl (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codempid, numcolla, typcolla, descoll, amtcolla, status, numdocum, dtecolla
        from tcolltrl
       where codempid = p_codempid
       order by numcolla;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numcolla', i.numcolla);
      obj_data.put('typcolla', i.typcolla);
      obj_data.put('desc_typcolla', get_tcodec_name('TCODCOLA', i.typcolla, global_v_lang));
      obj_data.put('descoll', i.descoll);
      obj_data.put('amtcolla', nvl(stddec(i.amtcolla, i.codempid, v_chken), 0));
      obj_data.put('numdocum', i.numdocum);
      obj_data.put('dtecolla', to_char(i.dtecolla, 'DD/MM/YYYY'));
      obj_data.put('status', i.status);
      obj_data.put('desc_status', get_tlistval_name('STACOLTRL', i.status, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcolltrl');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tcolltrl;
end HRRC5DX;

/
