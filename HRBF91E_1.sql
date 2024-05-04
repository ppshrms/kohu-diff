--------------------------------------------------------
--  DDL for Package Body HRBF91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF91E" AS
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
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'DDMMYYYY');
    p_dteeffec_query    := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec_query'), 'DD/MM/YYYY');
    p_daybfst           := hcm_util.get_number_t(json_obj, 'dayst');
    p_daybfen           := hcm_util.get_number_t(json_obj, 'dayen');
    p_mthbfst           := hcm_util.get_number_t(json_obj, 'monthst');
    p_mthbfen           := hcm_util.get_number_t(json_obj, 'monthen');
    p_coddisisr         := hcm_util.get_string_t(json_obj, 'coddisisr');
    p_coddisovr         := hcm_util.get_string_t(json_obj, 'coddisovr');
    p_codincrt          := hcm_util.get_string_t(json_obj, 'codincrt');
    p_codinctv          := hcm_util.get_string_t(json_obj, 'codinctv');

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
    begin
      select dteeffec
        into p_dteeffec_query
        from tcontrbf
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
      if p_dteeffec < trunc(sysdate) then
        p_flgEdit := 'N';
      end if;
    exception when no_data_found then
      select max(dteeffec)
        into p_dteeffec_query
        from tcontrbf
      where codcompy = p_codcompy
        and dteeffec < p_dteeffec;
      if p_dteeffec < trunc(sysdate) then
        p_flgEdit  := 'N';
        if p_dteeffec_query is not null then
          p_dteeffec := p_dteeffec_query;
        else
          p_flgEdit  := 'Y';
        end if;
      end if;
    end;
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
    obj_data            json_object_t;

  begin
    begin
      select daybfst, daybfen, mthbfst, mthbfen, coddisisr, coddisovr, codincrt, codinctv
        into p_daybfst, p_daybfen, p_mthbfst, p_mthbfen, p_coddisisr, p_coddisovr, p_codincrt, p_codinctv
        from tcontrbf
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec_query;
    exception when no_data_found then
      null;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcompy', p_codcompy);
    obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
    obj_data.put('flgEdit', p_flgEdit);
    obj_data.put('dayst', to_char(nvl(p_daybfst, 1)));
    obj_data.put('monthst', to_char(nvl(p_mthbfst, 1)));
    obj_data.put('dayen', to_char(nvl(p_daybfen, 31)));
    obj_data.put('monthen', to_char(nvl(p_mthbfen, 12)));
    obj_data.put('coddisisr', p_coddisisr);
    obj_data.put('coddisovr', p_coddisovr);
    obj_data.put('codincrt', p_codincrt);
    obj_data.put('codinctv', p_codinctv);
    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    begin
      insert into tcontrbf
             (codcompy, dteeffec, daybfst, daybfen,
              mthbfst, mthbfen, coddisisr, coddisovr,
              codincrt, codinctv, dtecreate, codcreate, coduser)
      values (p_codcompy, p_dteeffec_query, p_daybfst, p_daybfen,
              p_mthbfst, p_mthbfen, p_coddisisr, p_coddisovr,
              p_codincrt, p_codinctv, sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update tcontrbf
         set daybfst   = p_daybfst,
             daybfen   = p_daybfen,
             mthbfst   = p_mthbfst,
             mthbfen   = p_mthbfen,
             coddisisr = p_coddisisr,
             coddisovr = p_coddisovr,
             codincrt  = p_codincrt,
             codinctv  = p_codinctv,
             dteupd    = sysdate,
             coduser   = global_v_coduser
       where codcompy  = p_codcompy
         and dteeffec  = p_dteeffec_query;
    end;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;
end HRBF91E;


/
