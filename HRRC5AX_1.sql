--------------------------------------------------------
--  DDL for Package Body HRRC5AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC5AX" AS
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
    p_codemprc          := hcm_util.get_string_t(json_obj, 'p_codemprc');
    p_dtereqst          := to_date(hcm_util.get_string_t(json_obj, 'p_dtereqst'), 'DDMMYYYY');
    p_dtereqen          := to_date(hcm_util.get_string_t(json_obj, 'p_dtereqen'), 'DDMMYYYY');
    p_flgrecut          := hcm_util.get_string_t(json_obj, 'p_flgrecut');
    p_numreqst          := hcm_util.get_string_t(json_obj, 'p_numreqst');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
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
    v_qtyappl           treqest2.qtyreq%type;

    cursor c1 is
      select a.dtereq, a.numreqst, b.codpos, b.codjob, b.qtyreq, b.flgrecut, a.codcomp
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and a.codcomp  like p_codcomp || '%'
         and a.codemprc = nvl(p_codemprc, a.codemprc)
         and a.dtereq   between p_dtereqst and p_dtereqen
         and (b.flgrecut = p_flgrecut or p_flgrecut = 'A')
        order by a.dtereq, a.numreqst, b.codpos;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(i.dtereq, 'DD/MM/YYYY'));
      obj_data.put('numreqst', i.numreqst);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('codpos', i.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('codjob', i.codjob);
      obj_data.put('desc_codjob', get_tjobcode_name(i.codjob, global_v_lang));
      obj_data.put('flgrecut', i.flgrecut);
      obj_data.put('qtyreq', i.qtyreq);
      v_qtyappl           := 0;
      if i.flgrecut = 'E' then
        begin
          select count(numappl)
            into v_qtyappl
            from tapplinf
           where numreql = i.numreqst
             and codposl = i.codpos;
        exception when no_data_found then
          null;
        end;
      else
        begin
          select count(codempid)
            into v_qtyappl
            from tappeinf
           where numreqst = i.numreqst
             and codpos   = i.codpos;
        exception when no_data_found then
          null;
        end;
      end if;
      obj_data.put('qtyappl', v_qtyappl);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
     param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest1');
    else
      json_str_output := obj_rows.to_clob;
    end if;
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
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_dteappoist        tapphinv.dteappoist%type;
    v_dteappoien        tapphinv.dteappoien%type;
    v_qtyfscoresum      tapphinv.qtyfscoresum%type;
    v_qtyscoresum       tapphinv.qtyscoresum%type;
    v_stasign           tapphinv.stasign%type;
    v_codappr           tapphinv.codappr%type;
    v_dteappr           tapphinv.dteappr%type;
    v_table             varchar2(50 char);
    v_folderd_appl      tfolderd.codapp%type := 'HRRC21E';
    v_namdoc            tappldoc.namdoc%type;
    v_filedoc           tappldoc.filedoc%type;
    v_path_filename     varchar2(4000 char);

    cursor c_tapplinf is
      select numappl, codempid, statappl, stasign
        from tapplinf
       where numreql = p_numreqst
         and codposl = p_codpos
       order by numappl;
    cursor c_tappeinf is
      select codempid, dteappoi, perscore, codasapl, codconfrm, dteconfrm, status
        from tappeinf
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and codcomp  like p_codcomp
        order by codempid;

  begin
    obj_rows            := json_object_t();
    if p_flgrecut = 'E' then
      v_table             := 'tapplinf';
      for i in c_tapplinf loop
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', i.numappl);
        obj_data.put('desc_numappl', get_tapplinf_name(i.numappl, global_v_lang));
        obj_data.put('codempid', i.codempid);
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        v_stasign           := i.stasign;
        begin
          select dteappoist, dteappoien, qtyfscoresum, qtyscoresum, stasign, codappr, dteappr
            into v_dteappoist, v_dteappoien, v_qtyfscoresum, v_qtyscoresum, v_stasign, v_codappr, v_dteappr
            from tapphinv
           where numappl  = i.numappl
             and numreqrq = p_numreqst
             and codposrq = p_codpos;
        exception when no_data_found then
          v_dteappoist          := null;
          v_dteappoien          := null;
          v_qtyfscoresum        := null;
          v_qtyscoresum         := null;
          v_codappr             := null;
          v_dteappr             := null;
        end;
        obj_data.put('dteappoist', to_char(v_dteappoist, 'DD/MM/YYYY'));
        obj_data.put('dteappoien', to_char(v_dteappoien, 'DD/MM/YYYY'));
        obj_data.put('qtyfscoresum', v_qtyfscoresum);
        obj_data.put('qtyscoresum', v_qtyscoresum);
        obj_data.put('stasign', v_stasign);
        obj_data.put('desc_stasign', get_tlistval_name('STARC3GX', v_stasign, global_v_lang));
        begin
          select codappr, dteappr
            into v_codappr, v_dteappr
            from tapplcfm
           where numappl  = i.numappl
             and numreqrq = p_numreqst
             and codposrq = p_codpos;
        exception when no_data_found then
          null;
        end;
        obj_data.put('codappr', v_codappr);
        obj_data.put('desc_codappr', get_temploy_name(v_codappr, global_v_lang));
        obj_data.put('dteappr', to_char(v_dteappr, 'DD/MM/YYYY'));
        begin
          select namdoc, filedoc
            into v_namdoc, v_filedoc
            from tappldoc
           where numappl   = i.numappl
             and flgresume = 'Y';
          v_path_filename   := get_tsetup_value('PATHWORKPHP') || get_tfolderd(v_folderd_appl) || '/' || v_filedoc;
        exception when no_data_found then
          v_namdoc          := null;
          v_filedoc         := null;
          v_path_filename   := null;
        end;
        obj_data.put('namdoc', v_namdoc);
        obj_data.put('path_filename', v_path_filename);

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      v_table             := 'tappeinf';
      for j in c_tappeinf loop
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', '');
        obj_data.put('desc_numappl', get_temploy_name(j.codempid, global_v_lang));
        obj_data.put('codempid', j.codempid);
        obj_data.put('statappl', j.status);
        obj_data.put('desc_statappl', get_tlistval_name('STAEMPAPL', j.status, global_v_lang));
        obj_data.put('dteappoist', to_char(j.dteappoi, 'DD/MM/YYYY'));
        obj_data.put('dteappoien', to_char(j.dteappoi, 'DD/MM/YYYY'));
        obj_data.put('qtyfscoresum', '');
        obj_data.put('qtyscoresum', j.perscore);
        obj_data.put('stasign', j.codasapl);
        obj_data.put('desc_stasign', get_tlistval_name('CODASAPL', j.codasapl, global_v_lang));
        obj_data.put('codappr', j.codconfrm);
        obj_data.put('desc_codappr', get_temploy_name(j.codconfrm, global_v_lang));
        obj_data.put('dteappr', to_char(j.dteconfrm, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
     param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_detail;
end HRRC5AX;


/
