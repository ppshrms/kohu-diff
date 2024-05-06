--------------------------------------------------------
--  DDL for Package Body HRRC3HU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3HU" AS
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
    p_codposl           := hcm_util.get_string_t(json_obj, 'p_codposl');
    p_numreqst          := hcm_util.get_string_t(json_obj, 'p_numreqst');
    p_stasign           := hcm_util.get_string_t(json_obj, 'p_stasign');
    p_statappl          := hcm_util.get_string_t(json_obj, 'p_statappl');
    p_numappl           := hcm_util.get_string_t(json_obj, 'p_numappl');
    p_codempmt          := hcm_util.get_string_t(json_obj, 'p_codempmt');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numapseq          := hcm_util.get_string_t(json_obj, 'p_numapseq');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codcomp           tcenter.codcomp%type;
    v_codpos            tpostn.codpos%type;
    v_numreqst          treqest2.numreqst%type;
  begin
    if p_codcomp is not null then
      v_codcomp           := hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = v_codcomp;
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
    if p_codcomp is not null or p_codpos is not null or p_numreqst is not null then
      begin
        select numreqst
          into v_numreqst
          from treqest2
         where numreqst = nvl(p_numreqst, numreqst)
           and codpos   = nvl(p_codpos, codpos)
           and codcomp  = nvl(v_codcomp, codcomp)
           and flgrecut in ('E','O')
         fetch first row only;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        return;
      end;
      begin
        select nvl(sum(qtyreq), 0), nvl(sum(qtyact), 0)
          into p_qtyreq, p_qtyact
          from treqest2
         where numreqst = nvl(p_numreqst, numreqst)
           and codpos   = nvl(p_codpos, codpos)
           and codcomp  = nvl(v_codcomp, codcomp)
           and flgrecut in ('E','O');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        return;
      end;
    end if;
  end check_index;

  procedure get_search_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_search_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_search_index;

  procedure gen_search_index (json_str_output out clob) AS
    obj_data            json_object_t;
  begin
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('qtyreq', p_qtyreq);
    obj_data.put('qtyact', p_qtyact);
    obj_data.put('qtyrem', (p_qtyreq - p_qtyact));

    json_str_output := obj_data.to_clob;
  end gen_search_index;

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
    v_table             varchar2(50 char);

    cursor c_tapphinv is
      select a.numappl, decode(global_v_lang, '101', a.namempe,
                                              '102', a.namempt,
                                              '103', a.namemp3,
                                              '104', a.namemp4,
                                              '105', a.namemp5, a.namempe) namemp,
             a.namimage, b.numreqrq, b.codcomp, b.codposrq, b.statappl,
             b.qtyscoresum, a.amtincto, a.amtsal, a.codempid, a.codemprc
        from tapplinf a, tapphinv b
       where a.numappl  = b.numappl
         and b.numreqrq = nvl(p_numreqst, b.numreqrq)
         and b.codcomp  like p_codcomp || '%'
         and b.codposrq = nvl(p_codpos, b.codposrq)
         and b.codasapl  = nvl(p_stasign, b.codasapl)
         and a.numdoc   is null
       order by numappl;

    cursor c_tapplinf is
      select a.numappl, decode(global_v_lang, '101', a.namempe,
                                              '102', a.namempt,
                                              '103', a.namemp3,
                                              '104', a.namemp4,
                                              '105', a.namemp5, a.namempe) namemp,
             a.namimage, a.numreql, a.codcompl, a.codposl, a.statappl,
             '' qtyscoresum, a.amtincto, a.amtsal, a.codempid, a.codemprc
        from tapplinf a
       where a.numreql  = nvl(p_numreqst, a.numreql)
         and a.codcompl like p_codcomp || '%'
         and a.codposl  = nvl(p_codpos, a.codposl)
         and a.statappl = nvl(p_statappl, a.statappl)
         and a.numdoc   is null
       order by numappl;
  begin
    obj_rows            := json_object_t();
    if p_stasign is null then
      v_table             := 'tapplinf';
      for j in c_tapplinf loop
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', j.namimage);
        obj_data.put('numappl', j.numappl);
        obj_data.put('namemp', j.namemp);
        obj_data.put('codempid', j.codempid);
        obj_data.put('numreqst', j.numreql);
        obj_data.put('codcomp', j.codcompl);
        obj_data.put('codpos', j.codposl);
        obj_data.put('statappl', j.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', j.statappl, global_v_lang));
        obj_data.put('qtyscoresum', j.qtyscoresum);
        obj_data.put('amtincto', j.amtincto);
        obj_data.put('amtsal', stddec(j.amtsal,j.numappl,v_chken));
        obj_data.put('codemprc', j.codemprc);
        obj_data.put('desc_codemprc', get_temploy_name(j.codemprc, global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      v_table             := 'tapphinv';
      for i in c_tapphinv loop
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', i.namimage);
        obj_data.put('numappl', i.numappl);
        obj_data.put('namemp', i.namemp);
        obj_data.put('codempid', i.codempid);
        obj_data.put('numreqst', i.numreqrq);
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codpos', i.codposrq);
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('qtyscoresum', i.qtyscoresum);
        obj_data.put('amtincto', i.amtincto);
        obj_data.put('amtsal', stddec(i.amtsal,i.numappl,v_chken));
        obj_data.put('codemprc', i.codemprc);
        obj_data.put('desc_codemprc', get_temploy_name(i.codemprc, global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;

  procedure check_detail is
  begin
    p_codcompy          := hcm_util.get_codcomp_level(p_codcomp, 1);
    begin
      select dteeffec
        into p_dteeffec
        from tcontpms
       where codcompy = p_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = p_codcompy
                            and dteeffec <= sysdate);
    exception when no_data_found then
      null;
    end;

    begin
      select codempid
        into p_codempid
        from tapplinf
       where numappl = p_numappl;
    exception when no_data_found then
      null;
    end;
  end check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
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
    v_stasign           tapplcfm.stasign%type;
    v_codrej            tapplcfm.codrej%type;
    v_remark            tapplcfm.remark%type;
    v_flgblkls          tapplcfm.flgblkls%type;
    v_dteempmt          tapplcfm.dteempmt%type;
    v_numreqc           tapplcfm.numreqc%type;
    v_codposc           tapplcfm.codposc%type;
    v_codcomp           tapplcfm.codcomp%type;
    v_codposl           tapplcfm.codposl%type;
    v_codcompl          tapplcfm.codcompl%type;
    v_codempmt          tapplcfm.codempmt%type;
    v_qtywkemp          tapplcfm.qtywkemp%type;
    v_qtyduepr          tapplcfm.qtyduepr%type;
    v_amttotal          tapplcfm.amttotal%type;
    v_amtsalpro         tapplcfm.amtsalpro%type;
    v_welfare           tapplcfm.welfare%type;
    v_codcurr           tapplcfm.codcurr%type;
    v_flg               varchar2(20 char) := 'add';
  begin
    begin
      select codcurr
        into v_codcurr
        from tcontrpy
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    exception when no_data_found then
      null;
    end;
    begin
      select welfare
        into v_welfare
        from treqest2
       where numreqst = p_numreqst
         and codpos   = p_codpos
         and flgrecut = 'E';
    exception when no_data_found then
      null;
    end;
    begin
      select stasign, codrej, remark, flgblkls, dteempmt, numreqc, codposc,
             codcomp, codposl, codcompl, codempmt, qtywkemp, qtyduepr,
             amttotal, amtsalpro, welfare, codcurr
        into v_stasign, v_codrej, v_remark, v_flgblkls, v_dteempmt, v_numreqc, v_codposc,
             v_codcomp, v_codposl, v_codcompl, v_codempmt, v_qtywkemp, v_qtyduepr,
             v_amttotal, v_amtsalpro, v_welfare, v_codcurr
        from tapplcfm
       where numappl  = p_numappl
         and numreqrq = p_numreqst
         and codposrq = p_codpos;
      v_flg               := 'edit';
    exception when no_data_found then
      v_flg               := 'add';
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flg', v_flg);
    obj_data.put('codempid', p_codempid);
    obj_data.put('numappl', p_numappl);
    obj_data.put('desc_numappl', get_tapplinf_name(p_numappl, global_v_lang));
    obj_data.put('codposrq', p_codpos);
    obj_data.put('numreqst', p_numreqst);
    obj_data.put('statappl', p_statappl);
    obj_data.put('stasign', v_stasign);
    obj_data.put('codrej', v_codrej);
    obj_data.put('remark', v_remark);
    obj_data.put('flgblkls', v_flgblkls);
    obj_data.put('dteempmt', to_char(v_dteempmt, 'DD/MM/YYYY'));
    obj_data.put('numreqc', nvl(v_numreqc, p_numreqst));
    obj_data.put('codposc', v_codposc);
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('codposl', nvl(v_codposl, p_codpos));
    obj_data.put('codcompl', nvl(v_codcompl, p_codcomp));
    obj_data.put('codempmt', v_codempmt);
    obj_data.put('qtywkyre', floor(nvl(v_qtywkemp, 0) / 12));
    obj_data.put('qtywkmth', mod(nvl(v_qtywkemp, 0), 12));
    obj_data.put('qtyduepr', v_qtyduepr);
    obj_data.put('amttotal', stddec(v_amttotal,p_numappl,v_chken));
    obj_data.put('amtsalpro', stddec(v_amtsalpro,p_numappl,v_chken));
    obj_data.put('welfare', v_welfare);
    obj_data.put('codcurr', v_codcurr);
    obj_data.put('desc_codcurr', get_tcodec_name('TCODCURR', v_codcurr, global_v_lang));

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure get_detail_table (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_table;

  procedure gen_detail_table (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;
    v_codincom1         tapplcfm.codincom1%type;
    v_codincom2         tapplcfm.codincom2%type;
    v_codincom3         tapplcfm.codincom3%type;
    v_codincom4         tapplcfm.codincom4%type;
    v_codincom5         tapplcfm.codincom5%type;
    v_codincom6         tapplcfm.codincom6%type;
    v_codincom7         tapplcfm.codincom7%type;
    v_codincom8         tapplcfm.codincom8%type;
    v_codincom9         tapplcfm.codincom9%type;
    v_codincom10        tapplcfm.codincom10%type;
    v_amtincom1         tapplcfm.amtincom1%type;
    v_amtincom2         tapplcfm.amtincom2%type;
    v_amtincom3         tapplcfm.amtincom3%type;
    v_amtincom4         tapplcfm.amtincom4%type;
    v_amtincom5         tapplcfm.amtincom5%type;
    v_amtincom6         tapplcfm.amtincom6%type;
    v_amtincom7         tapplcfm.amtincom7%type;
    v_amtincom8         tapplcfm.amtincom8%type;
    v_amtincom9         tapplcfm.amtincom9%type;
    v_amtincom10        tapplcfm.amtincom10%type;
    v_unitcal1          tapplcfm.unitcal1%type;
    v_unitcal2          tapplcfm.unitcal2%type;
    v_unitcal3          tapplcfm.unitcal3%type;
    v_unitcal4          tapplcfm.unitcal4%type;
    v_unitcal5          tapplcfm.unitcal5%type;
    v_unitcal6          tapplcfm.unitcal6%type;
    v_unitcal7          tapplcfm.unitcal7%type;
    v_unitcal8          tapplcfm.unitcal8%type;
    v_unitcal9          tapplcfm.unitcal9%type;
    v_unitcal10         tapplcfm.unitcal10%type;
    v_amtmax1           tcontpmd.amtmax1%type := 99999999.99;
    v_amtmax2           tcontpmd.amtmax2%type := 99999999.99;
    v_amtmax3           tcontpmd.amtmax3%type := 99999999.99;
    v_amtmax4           tcontpmd.amtmax4%type := 99999999.99;
    v_amtmax5           tcontpmd.amtmax5%type := 99999999.99;
    v_amtmax6           tcontpmd.amtmax6%type := 99999999.99;
    v_amtmax7           tcontpmd.amtmax7%type := 99999999.99;
    v_amtmax8           tcontpmd.amtmax8%type := 99999999.99;
    v_amtmax9           tcontpmd.amtmax9%type := 99999999.99;
    v_amtmax10          tcontpmd.amtmax10%type := 99999999.99;
  begin
    obj_rows            := json_object_t();
    begin
      select codincom1, codincom2, codincom3, codincom4, codincom5,
             codincom6, codincom7, codincom8, codincom9, codincom10
        into v_codincom1, v_codincom2, v_codincom3, v_codincom4, v_codincom5,
             v_codincom6, v_codincom7, v_codincom8, v_codincom9, v_codincom10
        from tcontpms
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    exception when no_data_found then
      null;
    end;

    begin
      select unitcal1, unitcal2, unitcal3, unitcal4, unitcal5,
             unitcal6, unitcal7, unitcal8, unitcal9, unitcal10,
             amtmax1, amtmax2, amtmax3, amtmax4, amtmax5,
             amtmax6, amtmax7, amtmax8, amtmax9, amtmax10
        into v_unitcal1, v_unitcal2, v_unitcal3, v_unitcal4, v_unitcal5,
             v_unitcal6, v_unitcal7, v_unitcal8, v_unitcal9, v_unitcal10,
             v_amtmax1, v_amtmax2, v_amtmax3, v_amtmax4, v_amtmax5,
             v_amtmax6, v_amtmax7, v_amtmax8, v_amtmax9, v_amtmax10
        from tcontpmd
       where codcompy = p_codcompy
         -- softberry || 22/05/2023 || #9252and dteeffec = p_dteeffec
         -- softberry || 22/05/2023 || #9252 || and codempmt = nvl(p_codempmt, codempmt) 
         -- << softberry || 22/05/2023 || #9252
         and codempmt = p_codempmt
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = p_codcompy
                            and dteeffec <= sysdate)
        -- >> softberry || 22/05/2023 || #9252
       fetch first row only;
    exception when no_data_found then
      null;
    end;

   /* begin
      select amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
             amtincom6, amtincom7, amtincom8, amtincom9, amtincom10
        into v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
             v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
        from temploy3
       where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;*/
    begin
      select/* codincom1, codincom2, codincom3, codincom4, codincom5,
             codincom6, codincom7, codincom8, codincom9, codincom10,*/
             amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
             amtincom6, amtincom7, amtincom8, amtincom9, amtincom10--,
            /* unitcal1, unitcal2, unitcal3, unitcal4, unitcal5,
             unitcal6, unitcal7, unitcal8, unitcal9, unitcal10*/
        into /*v_codincom1, v_codincom2, v_codincom3, v_codincom4, v_codincom5,
             v_codincom6, v_codincom7, v_codincom8, v_codincom9, v_codincom10,*/
             v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
             v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10--,
            /* v_unitcal1, v_unitcal2, v_unitcal3, v_unitcal4, v_unitcal5,
             v_unitcal6, v_unitcal7, v_unitcal8, v_unitcal9, v_unitcal10*/
        from tapplcfm
       where numappl  = p_numappl
         and numreqrq = p_numreqst
         and codposrq = nvl(p_codpos, p_codposl);
    exception when no_data_found then
      null;
    end;
    if v_codincom1 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom1);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom1, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom1, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax1);
      obj_data.put('unitcal', v_unitcal1);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal1, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom2 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom2);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom2, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom2, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax2);
      obj_data.put('unitcal', v_unitcal2);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal2, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom3 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom3);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom3, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom3, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax3);
      obj_data.put('unitcal', v_unitcal3);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal3, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom4 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom4);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom4, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom4, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax4);
      obj_data.put('unitcal', v_unitcal4);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal4, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom5 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom5);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom5, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom5, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax5);
      obj_data.put('unitcal', v_unitcal5);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal5, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom6 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom6);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom6, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom6, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax6);
      obj_data.put('unitcal', v_unitcal6);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal6, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom7 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom7);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom7, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom7, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax7);
      obj_data.put('unitcal', v_unitcal7);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal7, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom8 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom8);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom8, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom8, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax8);
      obj_data.put('unitcal', v_unitcal8);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal8, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom9 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom9);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom9, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom9, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax9);
      obj_data.put('unitcal', v_unitcal9);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal9, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;
    if v_codincom10 is not null then
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codincom', v_codincom10);
      obj_data.put('desc_codincom', get_tinexinf_name(v_codincom10, global_v_lang));
      obj_data.put('amtincom', stddec(v_amtincom10, p_numappl, v_chken));
      obj_data.put('amtmax', v_amtmax10);
      obj_data.put('unitcal', v_unitcal10);
      obj_data.put('desc_unitcal', get_tlistval_name('NAMEUNIT', v_unitcal10, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end if;

    json_str_output := obj_rows.to_clob;
  end gen_detail_table;

  procedure get_detail_numreqst (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_numreqst(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_numreqst;

  procedure gen_detail_numreqst (json_str_output out clob) AS
    obj_data            json_object_t;
    v_numreqst          treqest2.numreqst%type;
    v_codposc           tapplcfm.codposc%type;
    v_codcomp           tapplcfm.codcomp%type;
  begin
    begin
      select numreqst, codpos, codcomp
        into v_numreqst, v_codposc, v_codcomp
        from treqest2
       where codpos   = p_codpos
         and codcomp  = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y')
         and flgrecut = 'E'
         and nvl(qtyact, 0) < qtyreq
       order by numreqst
       fetch first row only;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST2'); -- softberry || 23/02/2023 || #9173 || null;
    end;
    if param_msg_error is null then -- softberry || 23/02/2023 || #9173
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numreqst', v_numreqst);
        obj_data.put('codposc', v_codposc);
        obj_data.put('codcomp', v_codcomp);

        json_str_output := obj_data.to_clob;
--<< softberry || 23/02/2023 || #9173
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
-->> softberry || 23/02/2023 || #9173
  end gen_detail_numreqst;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    obj_rows            json_object_t;
    obj_table           json_object_t;
    v_codempid          tapplinf.codempid%type;
    v_numappl           tapplcfm.numappl%type;
    v_numreqrq          tapplcfm.numreqrq%type;
    v_codposrq          tapplcfm.codposrq%type;
    v_statappl          tapplinf.statappl%type;
    v_stasign           tapplcfm.stasign%type;
    v_codrej            tapplcfm.codrej%type;
    v_remark            tapplcfm.remark%type;
    v_flgblkls          tapplcfm.flgblkls%type;
    v_dteempmt          tapplcfm.dteempmt%type;
    v_numreqc           tapplcfm.numreqc%type;
    v_codposc           tapplcfm.codposc%type;
    v_codcomp           tapplcfm.codcomp%type;
    v_codposl           tapplcfm.codposl%type;
    v_codcompl          tapplcfm.codcompl%type;
    v_codempmt          tapplcfm.codempmt%type;
    v_qtywkyre          tapplcfm.qtywkemp%type;
    v_qtywkmth          tapplcfm.qtywkemp%type;
    v_qtywkemp          tapplcfm.qtywkemp%type;
    v_qtyduepr          tapplcfm.qtyduepr%type;
    v_amttotal          tapplcfm.amttotal%type;
    v_amtsalpro         tapplcfm.amtsalpro%type;
    v_welfare           tapplcfm.welfare%type;
    v_codcurr           tapplcfm.codcurr%type;
    v_rcnt              number;
    v_codincom1         tapplcfm.codincom1%type;
    v_codincom2         tapplcfm.codincom2%type;
    v_codincom3         tapplcfm.codincom3%type;
    v_codincom4         tapplcfm.codincom4%type;
    v_codincom5         tapplcfm.codincom5%type;
    v_codincom6         tapplcfm.codincom6%type;
    v_codincom7         tapplcfm.codincom7%type;
    v_codincom8         tapplcfm.codincom8%type;
    v_codincom9         tapplcfm.codincom9%type;
    v_codincom10        tapplcfm.codincom10%type;

--<< softberry || 15/05/2023 || #9252     
    v_amtmax            tcontpmd.amtmax1%type;
    v_amtmax1           tcontpmd.amtmax1%type := 99999999.99;
    v_amtmax2           tcontpmd.amtmax2%type := 99999999.99;
    v_amtmax3           tcontpmd.amtmax3%type := 99999999.99;
    v_amtmax4           tcontpmd.amtmax4%type := 99999999.99;
    v_amtmax5           tcontpmd.amtmax5%type := 99999999.99;
    v_amtmax6           tcontpmd.amtmax6%type := 99999999.99;
    v_amtmax7           tcontpmd.amtmax7%type := 99999999.99;
    v_amtmax8           tcontpmd.amtmax8%type := 99999999.99;
    v_amtmax9           tcontpmd.amtmax9%type := 99999999.99;
    v_amtmax10          tcontpmd.amtmax10%type := 99999999.99;    
-->> softberry || 15/05/2023 || #9252
    v_amtincom1         tapplcfm.amtincom1%type;
    v_amtincom2         tapplcfm.amtincom2%type;
    v_amtincom3         tapplcfm.amtincom3%type;
    v_amtincom4         tapplcfm.amtincom4%type;
    v_amtincom5         tapplcfm.amtincom5%type;
    v_amtincom6         tapplcfm.amtincom6%type;
    v_amtincom7         tapplcfm.amtincom7%type;
    v_amtincom8         tapplcfm.amtincom8%type;
    v_amtincom9         tapplcfm.amtincom9%type;
    v_amtincom10        tapplcfm.amtincom10%type;
    v_unitcal1          tapplcfm.unitcal1%type;
    v_unitcal2          tapplcfm.unitcal2%type;
    v_unitcal3          tapplcfm.unitcal3%type;
    v_unitcal4          tapplcfm.unitcal4%type;
    v_unitcal5          tapplcfm.unitcal5%type;
    v_unitcal6          tapplcfm.unitcal6%type;
    v_unitcal7          tapplcfm.unitcal7%type;
    v_unitcal8          tapplcfm.unitcal8%type;
    v_unitcal9          tapplcfm.unitcal9%type;
    v_unitcal10         tapplcfm.unitcal10%type;
    v_amtothr           number;
    v_amtday            number;
    v_amtmth            number;
    v_codcompy          tcenter.codcompy%type;
    v_count             number := 0;
    v_sum               number := 0;
    b_numoffid          tapplinf.numoffid%type;
    b_codempid          tapplinf.codempid%type;
    b_numappl           tapplinf.numappl%type;
    b_codtitle          tapplinf.codtitle%type;
    b_namfirste         tapplinf.namfirste%type;
    b_namfirstt         tapplinf.namfirstt%type;
    b_namfirst3         tapplinf.namfirst3%type;
    b_namfirst4         tapplinf.namfirst4%type;
    b_namfirst5         tapplinf.namfirst5%type;
    b_namlaste          tapplinf.namlaste%type;
    b_namlastt          tapplinf.namlastt%type;
    b_namlast3          tapplinf.namlast3%type;
    b_namlast4          tapplinf.namlast4%type;
    b_namlast5          tapplinf.namlast5%type;
    b_namempe           tapplinf.namempe%type;
    b_namempt           tapplinf.namempt%type;
    b_namemp3           tapplinf.namemp3%type;
    b_namemp4           tapplinf.namemp4%type;
    b_namemp5           tapplinf.namemp5%type;
    b_dteempmt          tapplinf.dteempmt%type;
    b_codcomp           tapplinf.codcomp%type;
    b_codsex            tapplinf.codsex%type;
    b_namimage          tapplinf.namimage%type;
    b_numpasid          tapplinf.numpasid%type;
    b_dteempdb          tapplinf.dteempdb%type;
    v_emp               temploy1.codempid%type;

--<< softberry || 24/02/2023 || #9173
    v_check_codpos            tpostn.codpos%type;
-->> softberry || 24/02/2023 || #9173
  begin
    initial_value(json_str_input);
    obj_data          := hcm_util.get_json_t(json_params, 'detail');
    obj_table         := hcm_util.get_json_t(json_params, 'table');
    v_codempid        := hcm_util.get_string_t(obj_data, 'codempid');
    v_numappl         := hcm_util.get_string_t(obj_data, 'numappl');
    v_numreqrq        := hcm_util.get_string_t(obj_data, 'numreqst');
    v_codposrq        := hcm_util.get_string_t(obj_data, 'codposrq');
    v_statappl        := hcm_util.get_string_t(obj_data, 'statappl');
    v_stasign         := hcm_util.get_string_t(obj_data, 'stasign');
    v_codrej          := hcm_util.get_string_t(obj_data, 'codrej');
    v_remark          := hcm_util.get_string_t(obj_data, 'remark');
    v_flgblkls        := hcm_util.get_string_t(obj_data, 'flgblkls');
    v_dteempmt        := to_date(hcm_util.get_string_t(obj_data, 'dteempmt'), 'DD/MM/YYYY');
    v_numreqc         := hcm_util.get_string_t(obj_data, 'numreqc');
    v_codposc         := hcm_util.get_string_t(obj_data, 'codposc');
    v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
    v_codposl         := hcm_util.get_string_t(obj_data, 'codposl');
    v_codcompl        := hcm_util.get_string_t(obj_data, 'codcompl');
    v_codempmt        := hcm_util.get_string_t(obj_data, 'codempmt');
    v_qtywkyre        := to_number(hcm_util.get_number_t(obj_data, 'qtywkyre'));
    v_qtywkmth        := to_number(hcm_util.get_number_t(obj_data, 'qtywkmth'));
    v_qtywkemp        := (v_qtywkyre * 12) + v_qtywkmth;
    v_qtyduepr        := hcm_util.get_string_t(obj_data, 'qtyduepr');
    v_amttotal        := hcm_util.get_string_t(obj_data, 'amttotal');
    v_amtsalpro       := hcm_util.get_string_t(obj_data, 'amtsalpro');
    v_welfare         := hcm_util.get_string_t(obj_data, 'welfare');
    v_codcurr         := hcm_util.get_string_t(obj_data, 'codcurr');
    v_codcompy        := hcm_util.get_codcomp_level(v_codcomp, 1);

--<< softberry || 24/02/2023 || #9173

    if v_statappl = '51' then -->> softberry || 30/03/2023 || #9251
--<< softberry || 24/05/2023 || #9251   
        begin
          select codpos
            into v_check_codpos
            from treqest2
           where codpos   = v_codposc
             and codcomp  = hcm_util.get_codcomp_level(v_codcomp, null, null, 'Y')
             and flgrecut in ('E','O')
             and nvl(qtyact, 0) < nvl(qtyreq, 0)
           order by numreqst
           fetch first row only;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('RC0001',global_v_lang,null);
        end;    
-->> softberry || 24/5/2023 || #9251       
        begin
            select codpos
              into v_check_codpos
              from tpostn
             where codpos = v_codposc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        end;
    end if; -->> softberry || 30/03/2023 || #9251
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
-->> softberry || 24/02/2023 || #9173

--<< softberry || 22/05/2023 || #9252   
    p_codcompy          := hcm_util.get_codcomp_level(v_codcomp, 1);
    begin
      select amtmax1, amtmax2, amtmax3, amtmax4, amtmax5,
             amtmax6, amtmax7, amtmax8, amtmax9, amtmax10
        into v_amtmax1, v_amtmax2, v_amtmax3, v_amtmax4, v_amtmax5,
             v_amtmax6, v_amtmax7, v_amtmax8, v_amtmax9, v_amtmax10
        from tcontpmd
       where codcompy = p_codcompy
         and codempmt = v_codempmt
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = p_codcompy
                            and dteeffec <= sysdate)
       fetch first row only;
    exception when no_data_found then
      null;
    end;
-->> softberry || 22/05/2023 || #9252   

    for i in 0 .. obj_table.get_size - 1 loop
      obj_rows        := hcm_util.get_json_t(obj_table, to_char(i));
      v_rcnt          := hcm_util.get_number_t(obj_rows, 'rcnt');
      if v_rcnt = 1 then
        v_codincom1           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom1           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal1            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom1) > v_amtmax1 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252   
      elsif v_rcnt = 2 then
        v_codincom2           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom2           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal2            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom2) > v_amtmax2 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252         
      elsif v_rcnt = 3 then
        v_codincom3           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom3           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal3            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom3) > v_amtmax3 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252              
      elsif v_rcnt = 4 then
        v_codincom4           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom4           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal4            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom4) > v_amtmax4 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252           
      elsif v_rcnt = 5 then
        v_codincom5           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom5           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal5            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom5) > v_amtmax5 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252          
      elsif v_rcnt = 6 then
        v_codincom6           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom6           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal6            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom6) > v_amtmax6 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252          
      elsif v_rcnt = 7 then
        v_codincom7           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom7           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal7            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom7) > v_amtmax7 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252         
      elsif v_rcnt = 8 then
        v_codincom8           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom8           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal8            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom8) > v_amtmax8 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252           
      elsif v_rcnt = 9 then
        v_codincom9           := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom9           := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal9            := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom9) > v_amtmax9 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252         
      elsif v_rcnt = 10 then
        v_codincom10          := hcm_util.get_string_t(obj_rows, 'codincom');
        v_amtincom10          := hcm_util.get_string_t(obj_rows, 'amtincom');
        v_unitcal10           := hcm_util.get_string_t(obj_rows, 'unitcal');
    --<< softberry || 15/05/2023 || #9252   
        v_amtmax              := nvl(hcm_util.get_string_t(obj_rows, 'amtmax'),99999999.99);
        if to_number(v_amtincom10) > v_amtmax10 then
            param_msg_error := get_error_msg_php('PM0066', global_v_lang);
        end if;
    -->> softberry || 15/05/2023 || #9252            
      end if;
    end loop;
    --<< softberry || 30/03/2023 || #9252
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    -->> softberry || 30/03/2023 || #9252
    if v_statappl = '51' then
      v_stasign := 'Y';
    elsif v_statappl = '54' then
      v_stasign := 'N';
    else
      v_stasign := null;
    end if;
    if v_statappl in ('51','54') then
      v_emp := get_codempid(global_v_coduser);
      begin
        insert into tapplcfm (
                    numappl, numreqrq, codposrq, stasign, codrej,
                    remark, flgblkls, dteempmt, numreqc, codposc,
                    codcomp, codposl, codcompl, codempmt, qtywkemp, qtyduepr,
                    codincom1, codincom2, codincom3, codincom4, codincom5,
                    codincom6, codincom7, codincom8, codincom9, codincom10,
                    amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                    amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                    amttotal,
                    unitcal1, unitcal2, unitcal3, unitcal4, unitcal5,
                    unitcal6, unitcal7, unitcal8, unitcal9, unitcal10,
                    amtsalpro, welfare, codcurr, dteappr, codappr,
                    dtecreate, codcreate, coduser)
             values (
                    v_numappl, v_numreqrq, v_codposrq, v_stasign, v_codrej,
                    v_remark, v_flgblkls, v_dteempmt, v_numreqc, v_codposc,
                    v_codcomp, v_codposl, v_codcompl, v_codempmt, v_qtywkemp, v_qtyduepr,
                    v_codincom1, v_codincom2, v_codincom3, v_codincom4, v_codincom5,
                    v_codincom6, v_codincom7, v_codincom8, v_codincom9, v_codincom10,
                    stdenc(v_amtincom1, v_numappl, v_chken), stdenc(v_amtincom2, v_numappl, v_chken), stdenc(v_amtincom3, v_numappl, v_chken), stdenc(v_amtincom4, v_numappl, v_chken), stdenc(v_amtincom5, v_numappl, v_chken),
                    stdenc(v_amtincom6, v_numappl, v_chken), stdenc(v_amtincom7, v_numappl, v_chken), stdenc(v_amtincom8, v_numappl, v_chken), stdenc(v_amtincom9, v_numappl, v_chken), stdenc(v_amtincom10, v_numappl, v_chken),
                    stdenc(v_amttotal, v_numappl, v_chken),
                    v_unitcal1, v_unitcal2, v_unitcal3, v_unitcal4, v_unitcal5,
                    v_unitcal6, v_unitcal7, v_unitcal8, v_unitcal9, v_unitcal10,
                    stdenc(v_amtsalpro, v_numappl, v_chken), v_welfare, v_codcurr, sysdate, /*global_v_coduser,*/v_emp,
                    sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tapplcfm
           set stasign    = v_stasign,
               codrej     = v_codrej,
               remark     = v_remark,
               flgblkls   = v_flgblkls,
               dteempmt   = v_dteempmt,
               numreqc    = v_numreqc,
               codposc    = v_codposc,
               codcomp    = v_codcomp,
               codposl    = v_codposl,
               codcompl   = v_codcompl,
               codempmt   = v_codempmt,
               qtywkemp   = v_qtywkemp,
               qtyduepr   = v_qtyduepr,
               codincom1  = v_codincom1,
               codincom2  = v_codincom2,
               codincom3  = v_codincom3,
               codincom4  = v_codincom4,
               codincom5  = v_codincom5,
               codincom6  = v_codincom6,
               codincom7  = v_codincom7,
               codincom8  = v_codincom8,
               codincom9  = v_codincom9,
               codincom10 = v_codincom10,
               amtincom1  = stdenc(v_amtincom1, v_numappl, v_chken),
               amtincom2  = stdenc(v_amtincom2, v_numappl, v_chken),
               amtincom3  = stdenc(v_amtincom3, v_numappl, v_chken),
               amtincom4  = stdenc(v_amtincom4, v_numappl, v_chken),
               amtincom5  = stdenc(v_amtincom5, v_numappl, v_chken),
               amtincom6  = stdenc(v_amtincom6, v_numappl, v_chken),
               amtincom7  = stdenc(v_amtincom7, v_numappl, v_chken),
               amtincom8  = stdenc(v_amtincom8, v_numappl, v_chken),
               amtincom9  = stdenc(v_amtincom9, v_numappl, v_chken),
               amtincom10 = stdenc(v_amtincom10, v_numappl, v_chken),
               amttotal   = stdenc(v_amttotal, v_numappl, v_chken),
               unitcal1   = v_unitcal1,
               unitcal2   = v_unitcal2,
               unitcal3   = v_unitcal3,
               unitcal4   = v_unitcal4,
               unitcal5   = v_unitcal5,
               unitcal6   = v_unitcal6,
               unitcal7   = v_unitcal7,
               unitcal8   = v_unitcal8,
               unitcal9   = v_unitcal9,
               unitcal10  = v_unitcal10,
               amtsalpro  = stdenc(v_amtsalpro, v_numappl, v_chken),
               welfare    = v_welfare,
               codcurr    = v_codcurr,
               dteappr    = sysdate,
               --codappr    = global_v_coduser,
               codappr    = v_emp,
               dteupd     = sysdate,
               coduser    = global_v_coduser
         where numappl    = v_numappl
           and numreqrq   = v_numreqrq
           and codposrq   = v_codposrq;
      end;
    else
      delete tapplcfm
       where numappl    = v_numappl
         and numreqrq   = v_numreqrq
         and codposrq   = v_codposrq;
    end if;


    get_wage_income(v_codcompy, v_codempmt,
                    v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                    v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                    v_amtothr, v_amtday, v_amtmth);
    begin
      update tapplinf
         set statappl = v_statappl,
             dtefoll  = sysdate,
             numreqc  = v_numreqc,
             codposc  = v_codposc,
             codcomp  = v_codcomp,
             codempmt = v_codempmt,
             qtywkemp = v_qtywkemp,
             qtyduepr = v_qtyduepr,
             codrej   = v_codrej,
             remark   = v_remark,
             flgblkls = v_flgblkls,
             amtsal   = stdenc(v_amtmth, v_numappl, v_chken),
             coduser  = global_v_coduser,
             dteupd   = sysdate,
             dteempmt = v_dteempmt
       where numappl  = v_numappl;
    exception when others then
      null;
    end;
    begin
      insert into tappfoll
              (numappl, dtefoll, statappl, numreqst, codrej, remark, dtecreate, codcreate, coduser)
      values (v_numappl, sysdate, v_statappl, v_numreqrq, v_codrej, v_remark, sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
    begin
      update treqest1
         set dterec   = sysdate,
             coduser  = global_v_coduser,
             dteupd   = sysdate
       where numreqst = v_numreqrq;
    exception when others then
      null;
    end;
    if v_statappl in ('51', '56') then
      begin
        select count(a.numappl), nvl(avg(stddec(b.amtsal,b.numappl,v_chken)), 0)
          into v_count, v_sum
          from tapplcfm a, tapplinf b
         where a.numappl  = b.numappl
           and a.numreqrq = v_numreqrq
           and a.codposrq = v_codposrq
           and b.statappl in ('51', '56');
      exception when no_data_found then
        v_count     := 1;
        v_sum       := v_amtmth;
      end;
      begin
        update treqest2
           set dtechoose = sysdate,
               qtyact    = v_count,
               amtsalavg = v_sum,
               coduser   = global_v_coduser,
               dteupd    = sysdate
         where numreqst  = v_numreqrq
           and codpos    = v_codposc;
      exception when others then
        null;
      end;
    else
      begin
        update treqest2
           set dtechoose = sysdate,
               coduser   = global_v_coduser,
               dteupd    = sysdate
         where numreqst = v_numreqrq
           and codpos   = v_codposc;
      exception when others then
        null;
      end;
    end if;
    if v_statappl = '54' and v_flgblkls = 'Y' then
      begin
        select numoffid, codempid, numappl,
               codtitle, namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
               namlaste, namlastt, namlast3, namlast4, namlast5,
               namempe, namempt, namemp3, namemp4, namemp5,
               dteempmt, codcomp,
               codsex, namimage, numpasid, dteempdb
          into b_numoffid, b_codempid, b_numappl,
               b_codtitle, b_namfirste, b_namfirstt, b_namfirst3, b_namfirst4, b_namfirst5,
               b_namlaste, b_namlastt, b_namlast3, b_namlast4, b_namlast5,
               b_namempe, b_namempt, b_namemp3, b_namemp4, b_namemp5,
               b_dteempmt, b_codcomp,
               b_codsex, b_namimage, b_numpasid, b_dteempdb
          from tapplinf
         where numappl = v_numappl;
        begin
          insert into tbcklst
                  (numoffid, codempid, numappl,
                   codtitle, namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
                   namlaste, namlastt, namlast3, namlast4, namlast5,
                   namempe, namempt, namemp3, namemp4, namemp5,
                   dteempmt, codcomp, desexemp,
                   codsex, namimage, numpasid, dteempdb,
                   dtecreate, codcreate, coduser)
           values (b_numoffid, b_codempid, b_numappl,
                   b_codtitle, b_namfirste, b_namfirstt, b_namfirst3, b_namfirst4, b_namfirst5,
                   b_namlaste, b_namlastt, b_namlast3, b_namlast4, b_namlast5,
                   b_namempe, b_namempt, b_namemp3, b_namemp4, b_namemp5,
                   b_dteempmt, b_codcomp, v_remark,
                   b_codsex, b_namimage, b_numpasid, b_dteempdb,
                   sysdate, global_v_coduser, sysdate);
        exception when dup_val_on_index then
          update tbcklst
             set desexemp  = v_remark,
                 codempid  = b_codempid,
                 numappl   = b_numappl,
                 codtitle  = b_codtitle,
                 namfirste = b_namfirste,
                 namfirstt = b_namfirstt,
                 namfirst3 = b_namfirst3,
                 namfirst4 = b_namfirst4,
                 namfirst5 = b_namfirst5,
                 namlaste  = b_namlaste,
                 namlastt  = b_namlastt,
                 namlast3  = b_namlast3,
                 namlast4  = b_namlast4,
                 namlast5  = b_namlast5,
                 namempe   = b_namempe,
                 namempt   = b_namempt,
                 namemp3   = b_namemp3,
                 namemp4   = b_namemp4,
                 namemp5   = b_namemp5,
                 dteempmt  = b_dteempmt,
                 codcomp   = b_codcomp,
                 codsex    = b_codsex,
                 namimage  = b_namimage,
                 numpasid  = b_numpasid,
                 dteempdb  = b_dteempdb,
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where numoffid  = b_numoffid;
        end;
      exception when no_data_found then
        null;
      end;
    end if;
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
  end save_detail;

  procedure get_tappoinf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tappoinf(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tappoinf;

  procedure gen_tappoinf (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(50 char) := 'tappoinf';
    v_qtyfscore         tappoinf.qtyfscore%type := 0;
    v_qtyscoreavg       tappoinf.qtyscoreavg%type := 0;
    v_codasapl          tappoinf.codasapl%type := 'P';

    cursor c_tappoinf is
      select numappl, numreqrq, codposrq,
             numapseq, typappty, dteappoi,
             codform, codexam, descnote,
             qtyfscore, qtyscoreavg, codasapl, stapphinv
        from tappoinf
       where numappl  = p_numappl
         and numreqrq = p_numreqst
         and codposrq = p_codpos
       order by numapseq;
  begin
    obj_rows            := json_object_t();
    for i in c_tappoinf loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numappl', i.numappl);
      obj_data.put('numreqrq', i.numreqrq);
      obj_data.put('codposrq', i.codposrq);
      obj_data.put('numapseq', i.numapseq);
      obj_data.put('dteappoi', to_char(i.dteappoi, 'DD/MM/YYYY'));
      obj_data.put('codform', i.codform);
      obj_data.put('codexam', i.codexam);
      obj_data.put('typappty', i.typappty);
      obj_data.put('desc_typappty', get_tlistval_name('TYPAPPTY', i.typappty, global_v_lang));
      obj_data.put('descnote', i.descnote);
      obj_data.put('stapphinv', i.stapphinv);
      obj_data.put('desc_stapphinv', get_tlistval_name('STAPPHINV', i.stapphinv, global_v_lang));
      obj_data.put('qtyfscore', i.qtyfscore);
      obj_data.put('qtyscoreavg', i.qtyscoreavg);
      obj_data.put('codasapl', i.codasapl);
      obj_data.put('desc_codasapl', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));

      v_qtyfscore           := v_qtyfscore + i.qtyfscore;
      v_qtyscoreavg         := v_qtyscoreavg + i.qtyscoreavg;
      if i.codasapl <> 'P' then
        v_codasapl            := i.codasapl;
      end if;
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgsum', 'Y');
      obj_data.put('desc_stapphinv', get_label_name('HRRC3HUC4', global_v_lang, 140));
      obj_data.put('qtyfscore', v_qtyfscore);
      obj_data.put('qtyscoreavg', v_qtyscoreavg);
      obj_data.put('codasapl', v_codasapl);
      obj_data.put('desc_codasapl', get_tlistval_name('CODASAPL', v_codasapl, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tappoinf;

  procedure get_tappoinfint (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tappoinfint(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tappoinfint;

  procedure gen_tappoinfint (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_table             varchar2(50 char) := 'tappoinfint';

    cursor c_tappoinfint is
      select a.codempts, b.codpos, a.qtyscore, a.codasapl, a.descnote
        from tappoinfint a, temploy1 b
       where a.codempts = b.codempid
         and a.numappl  = p_numappl
         and a.numreqrq = p_numreqst
         and a.codposrq = p_codpos
         and a.numapseq = p_numapseq
       order by a.codempts;
  begin
    obj_rows            := json_object_t();
    for i in c_tappoinfint loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numappl', p_numappl);
      obj_data.put('numreqrq', p_numreqst);
      obj_data.put('codposrq', p_codpos);
      obj_data.put('numapseq', p_numapseq);
      obj_data.put('codempts', i.codempts);
      obj_data.put('desc_codempts', get_temploy_name(i.codempts, global_v_lang));
      obj_data.put('codpos', i.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('qtyscore', i.qtyscore);
      obj_data.put('codasapl', i.codasapl);
      obj_data.put('desc_codasapl', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));
      obj_data.put('descnote', i.descnote);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tappoinfint;
end HRRC3HU;

/
