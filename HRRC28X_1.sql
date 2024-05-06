--------------------------------------------------------
--  DDL for Package Body HRRC28X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC28X" AS
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
    p_numreqst          := hcm_util.get_string_t(json_obj, 'p_numreqst');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DDMMYYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DDMMYYYY');
    p_flgrecut          := hcm_util.get_string_t(json_obj, 'p_flgrecut');
    p_statappl          := hcm_util.get_string_t(json_obj, 'p_statappl');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codpos            tpostn.codpos%type;
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
    v_codjobpost        tjobpost.codjobpost%type;
    v_dtepost           tjobpost.dtepost%type;
    v_qtyappl           treqest2.qtyreq%type;
    v_qtyapp2           treqest2.qtyreq%type;
    v_qtyapp3           treqest2.qtyreq%type;
    v_dtereq            tappeinf.dtereq%type;
    v_codempid          tappeinf.codempid%type;

    cursor c1 is
      select dteopen, numreqst, codpos, codcomp, dteclose, flgrecut
        from treqest2
       where codcomp  like p_codcomp || '%'
         and numreqst = nvl(p_numreqst, numreqst)
         and codpos   = nvl(p_codpos, codpos)
         and dteopen  between p_dtestrt and p_dteend
       order by dteopen, numreqst ;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_found             := true;
      if secur_main.secur7(i.codcomp, global_v_coduser) then
        v_qtyappl           := 0;
        v_qtyapp2           := 0;
        v_qtyapp3           := 0;
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numreqst', i.numreqst);
        obj_data.put('dteopen', to_char(i.dteopen, 'DD/MM/YYYY'));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('flgrecut', i.flgrecut);
        v_dtepost           := null;
        v_codjobpost        := null;
        begin
          select codjobpost, dtepost
            into v_codjobpost, v_dtepost
            from tjobpost
           where numreqst = i.numreqst
             and codpos   = i.codpos
             and dtepost  = (select max(dtepost)
                               from tjobpost
                              where numreqst = i.numreqst
                                and codpos   = i.codpos)
            fetch first row only;
        exception when no_data_found then
          null;
        end;
        obj_data.put('codjobpost', v_codjobpost);
        obj_data.put('desc_codjobpost', get_tcodec_name('TCODJOBPOST', v_codjobpost, global_v_lang));
        obj_data.put('dtepost', to_char(v_dtepost, 'DD/MM/YYYY'));
        obj_data.put('dteclose', to_char(i.dteclose, 'DD/MM/YYYY'));

        if i.flgrecut = 'E' then
          begin
            select count(numappl)
              into v_qtyappl
              from tapplinf
             where numreql = i.numreqst
               and codposl = i.codpos
               and dteappl between p_dtestrt and p_dteend;
          exception when no_data_found then
            null;
          end;
          begin
            select count(numappl)
              into v_qtyapp2
              from tapplinf
             where numreql = i.numreqst
               and codposl = i.codpos
               and dteappl between p_dtestrt and p_dteend
               and statappl in ('51', '56', '61', '62');
          exception when no_data_found then
            null;
          end;
          begin
            select count(numappl)
              into v_qtyapp3
              from tapplinf
             where numreql  = i.numreqst
               and codposl  = i.codpos
               and dteappl  between p_dtestrt and p_dteend
               and statappl in ('22', '32', '52', '53', '54', '55', '63');
          exception when no_data_found then
            null;
          end;
        else
          begin
            select count(codempid)
              into v_qtyappl
              from tappeinf
             where numreqst = i.numreqst
               and codpos   = i.codpos
               and dtereq   between p_dtestrt and p_dteend;
          exception when no_data_found then
            null;
          end;
          begin
            select count(codempid)
              into v_qtyapp2
              from tappeinf
             where numreqst = i.numreqst
               and codpos   = i.codpos
               and dtereq   between p_dtestrt and p_dteend
               and staappr  = 'Y';
          exception when no_data_found then
            null;
          end;
          begin
            select count(codempid)
              into v_qtyapp3
              from tappeinf
             where numreqst = i.numreqst
               and codpos   = i.codpos
               and dtereq   between p_dtestrt and p_dteend
               and staappr  = 'N';
          exception when no_data_found then
            null;
          end;
        end if;
        obj_data.put('qtyappl', v_qtyappl);
        obj_data.put('qtyapp2', v_qtyapp2);
        obj_data.put('qtyapp3', v_qtyapp3);

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
      end if;
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;

  procedure get_qtyappl_group (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qtyappl_group(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_qtyappl_group;

  procedure gen_qtyappl_group (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(20 char);

    cursor c1 is
      select statappl, count(numappl) qtyappl, max(dtefoll) dtefoll
        from tapplinf
       where numreql = p_numreqst
         and codposl = p_codpos
         and dteappl between p_dtestrt and p_dteend
       group by statappl
       order by statappl;
    cursor c2 is
      select status, count(codempid) qtyappl, max(dtefoll) dtefoll
        from tappeinf
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and dtereq   between p_dtestrt and p_dteend
       group by status
       order by status;

  begin
    obj_rows            := json_object_t();
    if p_flgrecut = 'E' then
      for i in c1 loop
        v_table             := 'tapplinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('dtefoll', to_char(i.dtefoll, 'DD/MM/YYYY'));
        obj_data.put('qtyappl', i.qtyappl);

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      for j in c2 loop
        v_table             := 'tappeinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('statappl', j.status);
        obj_data.put('desc_statappl', get_tlistval_name('STAEMPAPL', j.status, global_v_lang));
        obj_data.put('dtefoll', to_char(j.dtefoll, 'DD/MM/YYYY'));
        obj_data.put('qtyappl', j.qtyappl);

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_qtyappl_group;

  procedure get_qtyappl_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qtyappl_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_qtyappl_detail;

  procedure gen_qtyappl_detail (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(20 char);

    cursor c1 is
      select numappl, codempid, statappl, dtefoll
        from tapplinf
       where numreql  = p_numreqst
         and codposl  = p_codpos
         and statappl = p_statappl
         and dteappl  between p_dtestrt and p_dteend
       order by numappl;
    cursor c2 is
      select '' numappl, codempid, status, dtefoll
        from tappeinf
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and status   = p_statappl
         and dtereq   between p_dtestrt and p_dteend
       order by codempid;

  begin
    obj_rows            := json_object_t();
    if p_flgrecut = 'E' then
      for i in c1 loop
        v_table             := 'tapplinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', i.numappl);
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_tapplinf_name(i.numappl, global_v_lang));
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('dtefoll', to_char(i.dtefoll, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      for j in c2 loop
        v_table             := 'tappeinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', j.numappl);
        obj_data.put('codempid', j.codempid);
        obj_data.put('desc_codempid', get_temploy_name(j.codempid, global_v_lang));
        obj_data.put('statappl', j.status);
        obj_data.put('desc_statappl', get_tlistval_name('STAEMPAPL', j.status, global_v_lang));
        obj_data.put('dtefoll', to_char(j.dtefoll, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_qtyappl_detail;

  procedure get_qtyappl_approve (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qtyappl_approve(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_qtyappl_approve;

  procedure gen_qtyappl_approve (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(20 char);

    cursor c1 is
      select numappl, dteempmt, amtsal
        from tapplinf
       where numreql  = p_numreqst
         and codposl  = p_codpos
         and statappl in ('51', '56', '61', '62')
         and dteappl  between p_dtestrt and p_dteend
       order by numappl;
    cursor c2 is
      select codempid, dteeffec, '' amtsal
        from tappeinf
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and staappr  = 'Y'
         and dtereq   between p_dtestrt and p_dteend
       order by codempid;

  begin
    obj_rows            := json_object_t();
    if p_flgrecut = 'E' then
      for i in c1 loop
        v_table             := 'tapplinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', i.numappl);
        obj_data.put('desc_numappl', get_tapplinf_name(i.numappl, global_v_lang));
        obj_data.put('amtsal', i.amtsal);
        obj_data.put('dteempmt', to_char(i.dteempmt, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      for j in c2 loop
        v_table             := 'tappeinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', j.codempid);
        obj_data.put('desc_numappl', get_temploy_name(j.codempid, global_v_lang));
        obj_data.put('amtsal', j.amtsal);
        obj_data.put('dteempmt', to_char(j.dteeffec, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_qtyappl_approve;

  procedure get_qtyappl_reject (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qtyappl_reject(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_qtyappl_reject;

  procedure gen_qtyappl_reject (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(20 char);

    cursor c1 is
      select numappl, codempid, statappl, codfoll, dtefoll, codpos2
        from tapplinf
       where numreql  = p_numreqst
         and codposl  = p_codpos
         and statappl in ('22', '32', '52', '53', '54', '55', '63')
         and dteappl  between p_dtestrt and p_dteend
       order by numappl;
    cursor c2 is
      select '' numappl, codempid, status, codfoll, dtefoll, '' codpos2
        from tappeinf
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and staappr  = 'N'
         and dtereq   between p_dtestrt and p_dteend
       order by codempid;

  begin
    obj_rows            := json_object_t();
    if p_flgrecut = 'E' then
      for i in c1 loop
        v_table             := 'tapplinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', i.numappl);
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_tapplinf_name(i.numappl, global_v_lang));
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('codfoll', i.codfoll);
        obj_data.put('desc_codfoll', get_temploy_name(i.codfoll, global_v_lang));
        obj_data.put('dtefoll', to_char(i.dtefoll, 'DD/MM/YYYY'));
        obj_data.put('codpos2', i.codpos2);
        obj_data.put('desc_codpos2', get_tpostn_name(i.codpos2, global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      for j in c2 loop
        v_table             := 'tappeinf';
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', j.numappl);
        obj_data.put('codempid', j.codempid);
        obj_data.put('desc_codempid', get_temploy_name(j.codempid, global_v_lang));
        obj_data.put('statappl', j.status);
        obj_data.put('desc_statappl', get_tlistval_name('STAEMPAPL', j.status, global_v_lang));
        obj_data.put('codfoll', j.codfoll);
        obj_data.put('desc_codfoll', get_temploy_name(j.codfoll, global_v_lang));
        obj_data.put('dtefoll', to_char(j.dtefoll, 'DD/MM/YYYY'));
        obj_data.put('codpos2', j.codpos2);
        obj_data.put('desc_codpos2', get_tpostn_name(j.codpos2, global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_qtyappl_reject;
end HRRC28X;

/
