--------------------------------------------------------
--  DDL for Package Body HRRC27U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC27U" AS
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
    p_numreqst          := hcm_util.get_string_t(json_obj, 'p_numreqst');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codpos            tpostn.codpos%type;
    v_numreqst          treqest2.numreqst%type;

    cursor c1 is
      select numreqst, codemprc
        into v_numreqst, p_codemprc
        from treqest2
       where numreqst = nvl(p_numreqst, numreqst)
         and codpos   = nvl(p_codpos, codpos)
         and codcomp  like p_codcomp || '%'
         and flgrecut in ('E','O')
       order by numreqst desc;
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
    if p_numreqst is not null then
      begin
        select numreqst, codemprc
          into p_numreqst, p_codemprc
          from treqest2
         where numreqst = p_numreqst
           and codpos   = nvl(p_codpos, codpos)
           and codcomp  like p_codcomp || '%'
           and flgrecut in ('E','O');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        return;
      end;
    end if;
    if p_numreqst is null then
      for i in c1 loop
        v_numreqst        := i.numreqst;
        p_codemprc        := i.codemprc;
        exit;
      end loop;
      if v_numreqst is null then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        return;
      end if;
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
    v_codemprc          treqest2.codemprc%type;
  begin
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codemprc', p_codemprc);
    obj_data.put('desc_codemprc', get_temploy_name(p_codemprc, global_v_lang));

    json_str_output := obj_data.to_clob;
  end gen_search_index;

  function check_statement (v_numreqst treqest2.numreqst%type,
                            v_numappl tapplinf.numappl%type,
                            v_codpos1 tapplinf.codpos1%type,
                            v_codpos2 tapplinf.codpos2%type,
                            v_codcompl tapplinf.codcompl%type,
                            v_table varchar2 default 'V_HRRC26') return boolean as
    v_flgfound        boolean := false;
    v_statment        varchar2(1000 char);
    v_syncond         treqest2.syncond%type;
    v_qtyscore        tapplinf.qtyscore%type;
    v_dteempdb        tapplinf.dteempdb%type;
    v_age             number := 0;
    v_codsex          tapplinf.codsex%type;
    v_coddomcl        tapplinf.coddomcl%type;
    v_amtincfm        tapplinf.amtincfm%type;

  begin
    begin
      select syncond
        into v_syncond
        from treqest2
       where numreqst = v_numreqst
         and (v_codpos1    = nvl(codpos, v_codpos1)
              or v_codpos2 = nvl(codpos, nvl(v_codpos2, v_codpos1)))
         and nvl(codcomp, '%')  like v_codcompl || '%'
         and flgrecut in ('E','O');
    exception when no_data_found then
      null;
    end;
    if v_syncond is not null then
      v_flgfound        := false;
      begin
        select nvl(qtyscore, 0), dteempdb, floor(months_between(sysdate, dteempdb) / 12) age, codsex, coddomcl, amtincfm
          into v_qtyscore, v_dteempdb, v_age, v_codsex, v_coddomcl, v_amtincfm
          from tapplinf
         where numappl = v_numappl;
      exception when no_data_found then
        null;
      end;
      v_statment := v_syncond;
      v_statment := replace(v_statment, v_table || '.SCORE', v_qtyscore);
      v_statment := replace(v_statment, v_table || '.AGE', v_age);
      v_statment := replace(v_statment, v_table || '.CODSEX','''' || v_codsex || '''');
      v_statment := replace(v_statment, v_table || '.CODDOMCL','''' || v_coddomcl || '''');
      v_statment := replace(v_statment, v_table || '.AMTINCFM', v_amtincfm);
      v_statment := 'select count(*) from dual where ' || v_statment;
      v_flgfound := execute_stmt(v_statment);
      return v_flgfound;
    end if;
    return true;
  end check_statement;

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
--    v_folderd_appl      tfolderd.codapp%type := 'HRRC21E';
    v_folderd_appl      tfolderd.codapp%type := 'HRPMC2E';
    v_namdoc            tappldoc.namdoc%type;
    v_filedoc           tappldoc.filedoc%type;
    v_path_filename     varchar2(4000 char);
    v_disp_qtyscore     clob;

    cursor c1 is
      select numappl, decode(global_v_lang, '101', namempe,
                                            '102', namempt,
                                            '103', namemp3,
                                            '104', namemp4,
                                            '105', namemp5, namempe) namemp,
             codpos1, codpos2, nvl(qtyscore, 0) qtyscore, namimage,
             dteappoist, dteappoien, numreql, codcompl
        from tapplinf
       where numreql  = nvl(p_numreqst, numreql)
         and nvl(codcompl, '%') like p_codcomp || '%'
         and (codpos1    = nvl(p_codpos, codpos1)
              or codpos2 = nvl(p_codpos, nvl(codpos2, codpos1)))
         and statappl = '21'
       order by numappl;
  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      if check_statement(i.numreql, i.numappl, i.codpos1, i.codpos2, i.codcompl) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', i.namimage);
        obj_data.put('numappl', i.numappl);
        obj_data.put('namemp', i.namemp);
        obj_data.put('numreql', i.numreql);
        obj_data.put('codcompl', i.codcompl);
        obj_data.put('codpos1', i.codpos1);
        obj_data.put('desc_codpos1', get_tpostn_name(i.codpos1, global_v_lang));
        obj_data.put('codpos2', i.codpos2);
        obj_data.put('desc_codpos2', get_tpostn_name(i.codpos2, global_v_lang));
        obj_data.put('qtyscore', i.qtyscore);
        obj_data.put('desc_qtyscore', i.qtyscore || ' ' || get_label_name('HRRC27U', global_v_lang, 130));
        v_disp_qtyscore   := '<i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i>';
        if i.qtyscore = 1 then
          v_disp_qtyscore   := '<i class="fas fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i>';
        elsif i.qtyscore = 2 then
          v_disp_qtyscore   := '<i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i>';
        elsif i.qtyscore = 3 then
          v_disp_qtyscore   := '<i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i>';
        elsif i.qtyscore = 4 then
          v_disp_qtyscore   := '<i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>';
        elsif i.qtyscore = 5 then
          v_disp_qtyscore   := '<i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>';
        end if;
        obj_data.put('disp_qtyscore', v_disp_qtyscore);
        obj_data.put('dteappoist', to_char(i.dteappoist, 'DD/MM/YYYY'));
        obj_data.put('dteappoien', to_char(i.dteappoien, 'DD/MM/YYYY'));
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
      end if;
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapplinf');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;

  procedure check_save (v_dteappoist in tapplinf.dteappoist%type) is
  begin
    if trunc(v_dteappoist) < trunc(sysdate) then
      param_msg_error := get_error_msg_php('HR8519', global_v_lang);
      return;
    end if;
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flgStaappr        varchar2(5 char);
    v_numappl           tapplinf.numappl%type;
    v_numreql           tapplinf.numreql%type;
    v_codcompl          tapplinf.codcompl%type;
    v_codpos1           tapplinf.codpos1%type;
    v_codpos2           tapplinf.codpos2%type;
    v_dteappoist        tapplinf.dteappoist%type;
    v_dteappoien        tapplinf.dteappoien%type;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(json_params, to_char(i));
      if param_msg_error is null then
        v_flgStaappr      := hcm_util.get_string_t(obj_data, 'flgStaappr');
        v_numappl         := hcm_util.get_string_t(obj_data, 'numappl');
        v_numreql         := hcm_util.get_string_t(obj_data, 'numreql');
        v_codcompl        := hcm_util.get_string_t(obj_data, 'codcompl');
        v_codpos1         := hcm_util.get_string_t(obj_data, 'codpos1');
        v_codpos2         := hcm_util.get_string_t(obj_data, 'codpos2');
        v_dteappoist      := to_date(hcm_util.get_string_t(obj_data, 'dteappoist'), 'DD/MM/YYYY');
        v_dteappoien      := to_date(hcm_util.get_string_t(obj_data, 'dteappoien'), 'DD/MM/YYYY');
        check_save(v_dteappoist);
        if param_msg_error is not null then
          exit;
        end if;
        if v_flgStaappr = 'A' then
          begin
            insert into tappfoll
                    (numappl, dtefoll, statappl, numreqst, codpos, dtecreate, codcreate, coduser)
            values (v_numappl, sysdate, '31', v_numreql, v_codpos1, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            insert into tapphinv
                    (numappl, numreqrq, codposrq, codcomp, stapphinv, statappl, dteappoist, dteappoien, dtecreate, codcreate, coduser)
            values (v_numappl, v_numreql, v_codpos1, v_codcompl, 'P', '31', v_dteappoist, v_dteappoien, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            update treqest1
               set dterec   = sysdate,
                   coduser  = global_v_coduser,
                   dteupd   = sysdate
             where numreqst = v_numreql;
          exception when others then
            null;
          end;
          begin
            update treqest2
               set dtechoose = sysdate,
                   coduser   = global_v_coduser,
                   dteupd    = sysdate
             where numreqst = v_numreql
               and codpos   = v_codpos1;
          exception when others then
            null;
          end;
          begin
            update tapplinf
               set statappl   = '31',
                   dteappoist = v_dteappoist,
                   dteappoien = v_dteappoien,
                   dtefoll    = sysdate,
                   coduser    = global_v_coduser,
                   dteupd     = sysdate
             where numappl    = v_numappl;
          exception when others then
            null;
          end;
        else
          begin
            insert into tappfoll
                    (numappl, dtefoll, statappl, numreqst, codpos, dtecreate, codcreate, coduser)
            values (v_numappl, sysdate, '32', v_numreql, v_codpos1, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            update tapplinf
               set statappl   = '32',
                   dtefoll    = sysdate,
                   coduser    = global_v_coduser,
                   dteupd     = sysdate
             where numappl    = v_numappl;
          exception when others then
            null;
          end;
        end if;
      end if;
    end loop;
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
end HRRC27U;

/
