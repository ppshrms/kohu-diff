--------------------------------------------------------
--  DDL for Package Body HRBF4AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4AE" AS
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
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'DD/MM/YYYY');
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_codcompy          tcompny.codcompy%type;
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
      select max(dteeffec)
        into p_dteeffecTo
        from tobfbgyr
       where codcompy = p_codcompy
         and dteeffec <= p_dteeffec;
    exception when no_data_found then
      null;
    end;
  end;

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
    v_dteeffec          tobfbgyr.dteeffec%type;
    v_flg_add           boolean := false;
    cursor c1 is
     select numseq, amtalwyr, syncond, statement
       from tobfbgyr
       where codcompy = p_codcompy
         and dteeffec = (select max(dteeffec) 
                           from tobfbgyr
                          where dteeffec <= v_dteeffec
                            and codcompy = p_codcompy
                          )
       order by numseq;


  begin
    v_dteeffec      := p_dteeffec;
    if p_dteeffecTo is not null and p_dteeffec < trunc(sysdate) then
      v_dteeffec      := p_dteeffecTo;
    end if;
    if p_dteeffec >= trunc(sysdate) and p_dteeffec > p_dteeffecTo then
      v_flg_add   := true;
    end if;
    
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', i.numseq);
      obj_data.put('amtalwyr', i.amtalwyr);
      obj_data.put('desc_amtalwyr', hcm_formula.get_description(i.amtalwyr, global_v_lang));
      obj_data.put('description', get_logical_desc(i.statement)); ----2021 obj_data.put('syncond', i.syncond);
      obj_data.put('syncond', i.syncond);
      obj_data.put('statement', i.statement);
      obj_data.put('flgAdd', v_flg_add);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_dteeffec          tobfbgyr.dteeffec%type;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    v_dteeffec  := p_dteeffec;
    if p_dteeffecTo is not null and p_dteeffec < trunc(sysdate) then
      v_dteeffec        := p_dteeffecTo;
      obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1505', global_v_lang), global_v_lang));
      obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
    end if;
    obj_data.put('dteeffec', to_char(v_dteeffec, 'DD/MM/YYYY'));
    json_str_output := obj_data.to_clob;
  end gen_detail;

  function find_max_numseq return number is
    v_numseq            tobfbgyr.numseq%type := 0;
  begin
    begin
      select max(numseq)
        into v_numseq
        from tobfbgyr
       where codcompy  = p_codcompy
         and dteeffec  = p_dteeffec;
    exception when no_data_found then
      null;
    end;
    return v_numseq;
  end find_max_numseq;

  procedure check_save (v_numseq tobfbgyr.numseq%type, v_syncond tobfbgyr.syncond%type) as
    b_numseq            tobfbgyr.numseq%type;
  begin
    begin
      select numseq
        into b_numseq
        from tobfbgyr
       where codcompy  = p_codcompy
         and dteeffec  = p_dteeffec
         and numseq    <> v_numseq
         and syncond   = v_syncond;
      param_msg_error := get_error_msg_php('HR8860', global_v_lang);
    exception when others then
      null;
    end;
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_numseq            tobfbgyr.numseq%type;
    b_numseq            tobfbgyr.numseq%type := 0;
    obj_calculator      json_object_t;
    v_amtalwyr          tobfbgyr.amtalwyr%type;
    obj_syncond         json_object_t;
    v_syncond           tobfbgyr.syncond%type;
    v_statement         tobfbgyr.statement%type;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(json_params, to_char(i));
      v_flg           := hcm_util.get_string_t(obj_data, 'flg');
      v_numseq        := to_number(hcm_util.get_number_t(obj_data, 'numseq'));
      obj_calculator  := hcm_util.get_json_t(obj_data, 'amtalwyr');
      v_amtalwyr      := hcm_util.get_string_t(obj_calculator, 'code');
      obj_syncond     := hcm_util.get_json_t(obj_data, 'syncond');
      v_syncond       := hcm_util.get_string_t(obj_syncond, 'code');
      v_statement     := hcm_util.get_string_t(obj_syncond, 'statement');
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from tobfbgyr
            where codcompy  = p_codcompy
              and dteeffec  = p_dteeffec
              and numseq    = v_numseq;
          exception when others then
            null;
          end;
        elsif v_flg = 'edit' then
          v_check_flg := true;
          if v_numseq is null then
            b_numseq            := find_max_numseq;
            v_numseq            := nvl(b_numseq, 0) + 1;
          end if;
          check_save(v_numseq, v_syncond);
          if param_msg_error is null then
            begin
              insert into tobfbgyr
                     (codcompy, dteeffec, numseq, amtalwyr, syncond, statement, dtecreate, codcreate, coduser)
              values (p_codcompy, p_dteeffec, v_numseq, v_amtalwyr, v_syncond, v_statement, sysdate, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              update tobfbgyr
                 set amtalwyr  = v_amtalwyr,
                     syncond   = v_syncond,
                     statement = v_statement,
                     dteupd    = sysdate,
                     coduser   = global_v_coduser
               where codcompy  = p_codcompy
                 and dteeffec  = p_dteeffec
                 and numseq    = v_numseq;
            end;
          end if;
        else
          v_check_flg := true;
          b_numseq            := find_max_numseq;
          b_numseq            := nvl(b_numseq, 0) + 1;
          check_save(b_numseq, v_syncond);
          if param_msg_error is null then
            begin
              insert into tobfbgyr
                     (codcompy, dteeffec, numseq, amtalwyr, syncond, statement, dtecreate, codcreate, coduser)
              values (p_codcompy, p_dteeffec, b_numseq, v_amtalwyr, v_syncond, v_statement, sysdate, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              null;
            end;
          end if;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      if v_check_flg then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      end if;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRBF4AE;

/
