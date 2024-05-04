--------------------------------------------------------
--  DDL for Package Body HRES80X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES80X" as
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

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dteyear           := nvl(hcm_util.get_string_t(json_obj, 'p_dteyear'),to_char(sysdate,'yyyy'));
    -- report
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_additional_year   := to_number(hcm_appsettings.get_additional_year);

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function get_date_output (v_dteinput date) return varchar2 is
  begin
    return to_char(v_dteinput, 'DD/MM/') || (to_number(to_char(v_dteinput, 'YYYY')) + p_additional_year);
  end get_date_output;

  function get_year_output (v_dteyear varchar2) return varchar2 is
  begin
    return to_char(to_number(v_dteyear) + p_additional_year);
  end get_year_output;

  procedure check_detail is
    v_staemp            temploy1.staemp%type;
    v_zupdsal           varchar2(100 char);
  begin
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is not null then
        if global_v_codempid <> p_codempid then
            null;
            /* --ST11 #7491 || 09/05/2022
            if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
              param_msg_error := get_error_msg_php('HR3007', global_v_lang);
              return;
            end if;
             */
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_detail;

  procedure get_thisheal (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thisheal(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thisheal;

  procedure gen_thisheal (json_str_output out clob) AS
    obj_data            json_object_t;
    v_found             boolean := false;

    cursor c1 is
      select flgheal1, remark1, flgheal2, remark2, flgheal3, remark3, flgheal4, remark4,
             flgheal5, remark5, flgheal6, remark6, flgheal7, remark7, flgheal8, qtysmoke,
             qtyyear8, qtymth8, qtysmoke2, flgheal9, qtyyear9, qtymth9, desnote
        from thisheal
       where codempid = p_codempid;
  begin
    obj_data      := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgheal1', '');
    obj_data.put('remark1', '');
    obj_data.put('flgheal2', '');
    obj_data.put('remark2', '');
    obj_data.put('flgheal3', '');
    obj_data.put('remark3', '');
    obj_data.put('flgheal4', '');
    obj_data.put('remark4', '');
    obj_data.put('flgheal5', '');
    obj_data.put('remark5', '');
    obj_data.put('flgheal6', '');
    obj_data.put('remark6', '');
    obj_data.put('flgheal7', '');
    obj_data.put('remark7', '');
    obj_data.put('flgheal8', '');
    obj_data.put('qtysmoke', '');
    obj_data.put('qtyyear8', '');
    obj_data.put('qtymth8', '');
    obj_data.put('qtysmoke2', '');
    obj_data.put('flgheal9', '');
    obj_data.put('qtyyear9', '');
    obj_data.put('qtymth9', '');
    obj_data.put('desnote', '');
    for i in c1 loop
      v_found         := true;
      obj_data.put('flgheal1', i.flgheal1);
      obj_data.put('remark1', i.remark1);
      obj_data.put('flgheal2', i.flgheal2);
      obj_data.put('remark2', i.remark2);
      obj_data.put('flgheal3', i.flgheal3);
      obj_data.put('remark3', i.remark3);
      obj_data.put('flgheal4', i.flgheal4);
      obj_data.put('remark4', i.remark4);
      obj_data.put('flgheal5', i.flgheal5);
      obj_data.put('remark5', i.remark5);
      obj_data.put('flgheal6', i.flgheal6);
      obj_data.put('remark6', i.remark6);
      obj_data.put('flgheal7', i.flgheal7);
      obj_data.put('remark7', i.remark7);
      obj_data.put('flgheal8', i.flgheal8);
      obj_data.put('qtysmoke', i.qtysmoke);
      obj_data.put('qtyyear8', i.qtyyear8);
      obj_data.put('qtymth8', i.qtymth8);
      obj_data.put('qtysmoke2', i.qtysmoke2);
      obj_data.put('flgheal9', i.flgheal9);
      obj_data.put('qtyyear9', i.qtyyear9);
      obj_data.put('qtymth9', i.qtymth9);
      obj_data.put('desnote', i.desnote);
    end loop;

    if not v_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'thisheal');
      return;
    end if;

    if isInsertReport then
      insert_ttemprpt(obj_data.to_clob);
    end if;
    json_str_output := obj_data.to_clob;
  end gen_thisheal;

  procedure get_thisheald (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thisheald(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thisheald;

  procedure gen_thisheald (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numseq, descsick, dteyear
        from thisheald
       where codempid = p_codempid;
  begin
    obj_rows      := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt + 1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('numseq', i.numseq);
      obj_data.put('descsick', i.descsick);
      obj_data.put('dteyear', i.dteyear);

      if isInsertReport then
        insert_ttemprpt_thisheald(obj_data.to_clob);
      end if;
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_thisheald;

  procedure get_thishealf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thishealf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thishealf;

  procedure gen_thishealf (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numseq, descrelate, descsick
        from thishealf
       where codempid = p_codempid;
  begin
    obj_rows      := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt + 1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('numseq', i.numseq);
      obj_data.put('descrelate', i.descrelate);
      obj_data.put('descsick', i.descsick);

      if isInsertReport then
        insert_ttemprpt_thishealf(obj_data.to_clob);
      end if;
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_thishealf;

  procedure get_thealinfx (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinfx(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinfx;

  procedure gen_thealinfx (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select b.dteyear
        from thealcde a, thealinf1 b
       where a.codprgheal = b.codprgheal
         and typpgm = '1'
         and codempid = p_codempid
       group by b.dteyear
       order by b.dteyear desc;
  begin
    obj_rows      := json_object_t();
    obj_data      := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt + 1;
      obj_data.put(to_char(v_rcnt - 1), i.dteyear);
    end loop;
    obj_rows.put('coderror', '200');
    obj_rows.put('dteyear', obj_data);
    json_str_output := obj_rows.to_clob;
  end gen_thealinfx;

  procedure get_thealinfl (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinfl(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinfl;

  procedure gen_thealinfl (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select b.dteyear, b.dteheal, a.codprgheal, a.typpgm,
             decode(global_v_lang, '101', a.desheale,
                                   '102', a.deshealt,
                                   '103', a.desheal3,
                                   '104', a.desheal4,
                                   '105', a.desheal5, a.desheale) desheal
        from thealcde a, thealinf1 b
       where a.codprgheal = b.codprgheal
         and typpgm <> '1'
         and codempid = p_codempid
       order by b.dteheal desc;
  begin
    obj_rows      := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt + 1;
      if v_rcnt = 3 then
        exit;
      end if;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteheal', to_char(i.dteheal, 'DD/MM/YYYY'));
      obj_data.put('codprgheal', i.codprgheal);
      obj_data.put('desheal', i.desheal);
      obj_data.put('dteyear', i.dteyear);
      obj_data.put('typpgm', i.typpgm);

      if isInsertReport then
        insert_ttemprpt_thealinf1(obj_data.to_clob);
      end if;
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_thealinfl;

  procedure get_thealinf1 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinf1(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinf1;

  procedure gen_thealinf1 (json_str_output out clob) AS
    obj_data            json_object_t;
    v_descheal          thealinf1.descheal%type;
  begin
    begin
      select descheal
        into v_descheal
      from (select descheal
                  from thealinf1
                  where codempid  = p_codempid
                      and dteyear = p_dteyear
                      order by dteheal desc)
      where rownum = 1;
    exception when no_data_found then
      null;
    end;
    obj_data      := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('dteyear', p_dteyear);
    obj_data.put('descheal', v_descheal);
    json_str_output := obj_data.to_clob;
  end gen_thealinf1;

  procedure get_thealinf2 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinf2(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinf2;

  procedure gen_thealinf2 (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_rcnt2             number := 0;
    v_rcnt3             number := 0;
    v_descheck          thealinf2.descheck%type;
    v_chkresult         thealinf2.chkresult%type;

    cursor c1 is
      select b.codheal
        from thealinf1 a, thealinf2 b
       where a.codempid   = p_codempid
         and a.codempid   = b.codempid
         and a.codprgheal = b.codprgheal
         and a.dteyear    = b.dteyear
         and a.dteyear    in (p_dteyear, (p_dteyear - 1), (p_dteyear - 2))
       group by b.codheal
       order by b.codheal;
    cursor c2 is
      select b.dteheal, a.codprgheal, b.dteyear
        from thealcde a, thealinf1 b
       where a.codprgheal = b.codprgheal
         and typpgm <> '1'
         and codempid = p_codempid
       order by b.dteheal desc;
  begin
    obj_rows      := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt + 1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codheal', i.codheal);
      obj_data.put('desc_codheal', get_tcodec_name('tcodheal', i.codheal, global_v_lang));
      v_rcnt2       := 0;
      for v_dteyear in reverse (p_dteyear - 2) .. p_dteyear  loop
        v_rcnt2       := v_rcnt2 + 1;
        begin
          select a.descheck, a.chkresult
            into v_descheck, v_chkresult
            from thealinf2 a, thealcde b
           where a.codempid   = p_codempid
             and a.dteyear    = v_dteyear
             and a.codheal    = i.codheal
             and a.codprgheal = b.codprgheal
             and b.typpgm     = '1'
           fetch first 1 rows only;
        exception when no_data_found then
          v_descheck  := null;
          v_chkresult := null;
        end;
        obj_data.put('descheck' || v_rcnt2, v_descheck);
        obj_data.put('chkresult' || v_rcnt2, get_tlistval_name('CHKRESUL', v_chkresult, global_v_lang));
      end loop;
      v_rcnt3       := 0;
      for j in c2 loop
        v_rcnt3       := v_rcnt3 + 1;
        if v_rcnt3 = 3 then
          exit;
        end if;
        begin
          select descheck, chkresult
            into v_descheck, v_chkresult
            from thealinf2
           where codempid   = p_codempid
             and dteyear    = j.dteyear
             and codprgheal = j.codprgheal
             and codheal    = i.codheal
           fetch first 1 rows only;
        exception when no_data_found then
          v_descheck  := null;
          v_chkresult := null;
        end;
        obj_data.put('descheckO' || v_rcnt3, v_descheck);
        obj_data.put('chkresultO' || v_rcnt3, get_tlistval_name('CHKRESUL', v_chkresult, global_v_lang));
      end loop;

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_thealinf2;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  function get_ttemprpt_numseq (v_codapp varchar2) return number is
    v_numseq            number := 1;
  begin
    begin
      select nvl(max(numseq), 0) + 1
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = v_codapp;
    exception when no_data_found then
      null;
    end;
    return v_numseq;
  end;

  procedure insert_ttemprpt (json_str_input clob) is
    v_numseq            number := 1;
    obj_data            json_object_t;
    v_dteempdb          temploy1.dteempdb%type;
    v_dteempdb_output   ttemprpt.item2%type;
    v_codsex            temploy1.codsex%type;
    v_adrreg            temploy2.adrrege%type;
    v_codsubdistr       temploy2.codsubdistr%type;
    v_coddistr          temploy2.coddistr%type;
    v_codprovr          temploy2.codprovr%type;
    v_numtelec          temploy2.numtelec%type;
    v_numtelof          temploy1.numtelof%type;
    v_dteempmt          temploy1.dteempmt%type;
    v_dteempmt_output   ttemprpt.item10%type;
    v_numoffid          temploy2.numoffid%type;
    v_codpostr          temploy2.codpostr%type;
    v_adrcont           temploy2.adrconte%type;
    v_codsubdistc       temploy2.codsubdistc%type;
    v_coddistc          temploy2.coddistc%type;
    v_codprovc          temploy2.codprovc%type;
    v_codpostc          temploy2.codpostc%type;
    v_namcom            tcompny.namcome%type;
    v_addrno            tcompny.addrnoe%type;
    v_soi               tcompny.soie%type;
    v_road              tcompny.roade%type;
    v_codsubdist        tcompny.codsubdist%type;
    v_coddist           tcompny.coddist%type;
    v_codprov           tcompny.codprovr%type;
    v_zipcode           tcompny.zipcode%type;
    v_numtele           tcompny.numtele%type;
    v_flgheal1          ttemprpt.item1%type;
    v_remark1           ttemprpt.item1%type;
    v_flgheal2          ttemprpt.item1%type;
    v_remark2           ttemprpt.item1%type;
    v_flgheal3          ttemprpt.item1%type;
    v_remark3           ttemprpt.item1%type;
    v_flgheal4          ttemprpt.item1%type;
    v_remark4           ttemprpt.item1%type;
    v_flgheal5          ttemprpt.item1%type;
    v_remark5           ttemprpt.item1%type;
    v_flgheal6          ttemprpt.item1%type;
    v_remark6           ttemprpt.item1%type;
    v_flgheal7          ttemprpt.item1%type;
    v_remark7           ttemprpt.item1%type;
    v_flgheal8          ttemprpt.item1%type;
    v_qtysmoke          ttemprpt.item1%type;
    v_qtyyear8          ttemprpt.item1%type;
    v_qtymth8           ttemprpt.item1%type;
    v_qtysmoke2         ttemprpt.item1%type;
    v_flgheal9          ttemprpt.item1%type;
    v_qtyyear9          ttemprpt.item1%type;
    v_qtymth9           ttemprpt.item1%type;
    v_desnote           ttemprpt.item1%type;
  begin
    v_numseq            := get_ttemprpt_numseq(p_codapp);
    begin
      select a.dteempdb, a.codsex,
             decode(global_v_lang, '101', b.adrrege,
                                   '102', b.adrregt,
                                   '103', b.adrreg3,
                                   '104', b.adrreg4,
                                   '105', b.adrreg5, b.adrrege) adrreg,
             b.codsubdistr, b.coddistr, b.codprovr, b.numtelec, a.numtelof, a.dteempmt,
             b.numoffid, b.codpostr,
             decode(global_v_lang, '101', b.adrconte,
                                   '102', b.adrcontt,
                                   '103', b.adrcont3,
                                   '104', b.adrcont4,
                                   '105', b.adrcont5, b.adrconte) adrcont,
             b.codsubdistc, b.coddistc, b.codprovc, b.codpostc,
             decode(global_v_lang, '101', c.namcome,
                                   '102', c.namcomt,
                                   '103', c.namcom3,
                                   '104', c.namcom4,
                                   '105', c.namcom5, c.namcome) namcom,
             decode(global_v_lang, '101', c.addrnoe,
                                   '102', c.addrnot,
                                   '103', c.addrno3,
                                   '104', c.addrno4,
                                   '105', c.addrno5, c.addrnoe) addrno,
             decode(global_v_lang, '101', c.soie,
                                   '102', c.soit,
                                   '103', c.soi3,
                                   '104', c.soi4,
                                   '105', c.soi5, c.soie) soi,
             decode(global_v_lang, '101', c.roade,
                                   '102', c.roadt,
                                   '103', c.road3,
                                   '104', c.road4,
                                   '105', c.road5, c.roade) road,
             c.codsubdist, c.coddist, c.codprovr codprov, c.zipcode, c.numtele
        into v_dteempdb, v_codsex, v_adrreg, v_codsubdistr, v_coddistr, v_codprovr,
             v_numtelec, v_numtelof, v_dteempmt, v_numoffid, v_codpostr, v_adrcont,
             v_codsubdistc, v_coddistc, v_codprovc, v_codpostc, v_namcom, v_addrno,
             v_soi, v_road, v_codsubdist, v_coddist, v_codprov, v_zipcode, v_numtele
        from temploy1 a
        left join temploy2 b on a.codempid = b.codempid
        left join tcompny c  on hcm_util.get_codcomp_level(a.codcomp, 1)  = c.codcompy
       where a.codempid = p_codempid;
    exception when no_data_found then
      null;
    end;
    v_dteempdb_output   := get_date_output(v_dteempdb);
    v_dteempmt_output   := get_date_output(v_dteempmt);
    obj_data            := json_object_t(json_str_input);
    v_flgheal1          := hcm_util.get_string_t(obj_data, 'flgheal1');
    v_remark1           := hcm_util.get_string_t(obj_data, 'remark1');
    v_flgheal2          := hcm_util.get_string_t(obj_data, 'flgheal2');
    v_remark2           := hcm_util.get_string_t(obj_data, 'remark2');
    v_flgheal3          := hcm_util.get_string_t(obj_data, 'flgheal3');
    v_remark3           := hcm_util.get_string_t(obj_data, 'remark3');
    v_flgheal4          := hcm_util.get_string_t(obj_data, 'flgheal4');
    v_remark4           := hcm_util.get_string_t(obj_data, 'remark4');
    v_flgheal5          := hcm_util.get_string_t(obj_data, 'flgheal5');
    v_remark5           := hcm_util.get_string_t(obj_data, 'remark5');
    v_flgheal6          := hcm_util.get_string_t(obj_data, 'flgheal6');
    v_remark6           := hcm_util.get_string_t(obj_data, 'remark6');
    v_flgheal7          := hcm_util.get_string_t(obj_data, 'flgheal7');
    v_remark7           := hcm_util.get_string_t(obj_data, 'remark7');
    v_flgheal8          := hcm_util.get_string_t(obj_data, 'flgheal8');
    v_qtysmoke          := hcm_util.get_string_t(obj_data, 'qtysmoke');
    v_qtyyear8          := hcm_util.get_string_t(obj_data, 'qtyyear8');
    v_qtymth8           := hcm_util.get_string_t(obj_data, 'qtymth8');
    v_qtysmoke2         := hcm_util.get_string_t(obj_data, 'qtysmoke2');
    v_flgheal9          := hcm_util.get_string_t(obj_data, 'flgheal9');
    v_qtyyear9          := hcm_util.get_string_t(obj_data, 'qtyyear9');
    v_qtymth9           := hcm_util.get_string_t(obj_data, 'qtymth9');
    v_desnote           := hcm_util.get_string_t(obj_data, 'desnote');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15,
             item16, item17, item18, item19, item20,
             item21, item22, item23, item24, item25,
             item26, item27, item28, item29, item30,
             item31, item32, item33, item34, item35,
             item36, item37, item38, item39, item40,
             item41, item42, item43, item44, item45,
             item46, item47, item48, item49, item50
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             p_codempid, -- item1
             v_dteempdb_output, -- item2
             get_tlistval_name('NAMSEX', v_codsex, global_v_lang), -- item3
             v_adrreg, -- item4
             get_tsubdist_name(v_codsubdistr, global_v_lang), -- item5
             get_tcoddist_name(v_coddistr, global_v_lang), -- item6
             get_tcodec_name('TCODPROV', v_codprovr, global_v_lang), -- item7
             v_numtelec, -- item8
             v_numtelof, -- item9
             v_dteempmt_output, -- item10
             v_numoffid, -- item11
             v_codpostr, -- item12
             v_adrcont, -- item13
             get_tsubdist_name(v_codsubdistc, global_v_lang), -- item14
             get_tcoddist_name(v_coddistc, global_v_lang), -- item15
             get_tcodec_name('TCODPROV', v_codprovc, global_v_lang), -- item16
             v_codpostc, -- item17
             v_namcom, -- item18
             v_addrno, -- item19
             v_soi, -- item20
             v_road, -- item21
             get_tsubdist_name(v_codsubdist, global_v_lang), -- item22
             get_tcoddist_name(v_coddist, global_v_lang), -- item23
             get_tcodec_name('TCODPROV', v_codprov, global_v_lang), -- item24
             v_zipcode, -- item25
             v_numtele, -- item26
             v_flgheal1, -- item27
             v_remark1, -- item28
             v_flgheal2, -- item29
             v_remark2, -- item30
             v_flgheal3, -- item31
             v_remark3, -- item32
             v_flgheal4, -- item33
             v_remark4, -- item34
             v_flgheal5, -- item35
             v_remark5, -- item36
             v_flgheal6, -- item37
             v_remark6, -- item38
             v_flgheal7, -- item39
             v_remark7, -- item40
             v_flgheal8, -- item41
             v_qtysmoke, -- item42
             v_qtyyear8, -- item43
             v_qtymth8, -- item44
             v_qtysmoke2, -- item45
             v_flgheal9, -- item46
             v_qtyyear9, -- item47
             v_qtymth9, -- item48
             v_desnote, -- item49
             get_emp_img(p_codempid) -- item50
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;

  procedure insert_ttemprpt_thisheald (json_str_input clob) is
    v_numseq            number := 1;
    obj_data            json_object_t;
    v_codapp            varchar2(10 char);
    v_rcnt              ttemprpt.item1%type;
    v_numseq2           ttemprpt.item1%type;
    v_descsick          ttemprpt.item1%type;
    v_dteyear           ttemprpt.item1%type;
  begin
    v_codapp            := p_codapp || '2';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    obj_data            := json_object_t(json_str_input);
    v_rcnt              := hcm_util.get_string_t(obj_data, 'rcnt');
    v_numseq2           := hcm_util.get_string_t(obj_data, 'numseq');
    v_descsick          := hcm_util.get_string_t(obj_data, 'descsick');
    v_dteyear           := get_year_output(hcm_util.get_string_t(obj_data, 'dteyear'));
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item1
             v_rcnt, -- item2
             v_numseq2, -- item3
             v_descsick, -- item4
             v_dteyear -- item5
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thisheald;

  procedure insert_ttemprpt_thishealf (json_str_input clob) is
    v_numseq            number := 1;
    obj_data            json_object_t;
    v_codapp            varchar2(10 char);
    v_rcnt              ttemprpt.item1%type;
    v_numseq2           ttemprpt.item1%type;
    v_descrelate        ttemprpt.item1%type;
    v_descsick          ttemprpt.item1%type;
  begin
    v_codapp            := p_codapp || '3';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    obj_data            := json_object_t(json_str_input);
    v_rcnt              := hcm_util.get_string_t(obj_data, 'rcnt');
    v_numseq2           := hcm_util.get_string_t(obj_data, 'numseq');
    v_descrelate        := hcm_util.get_string_t(obj_data, 'descrelate');
    v_descsick          := hcm_util.get_string_t(obj_data, 'descsick');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item1
             v_rcnt, -- item2
             v_numseq2, -- item3
             v_descrelate, -- item4
             v_descsick -- item5
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thishealf;

  procedure insert_ttemprpt_tapplwex is
    v_rcnt              number := 0;
    v_numseq            number := 1;
    v_dtework           ttemprpt.item1%type;
    v_codapp            varchar2(10 char);

    cursor c1 is
      select desnoffi, deslstjob1, desjob, dtestart, dteend, desrisk, desprotc
        from tapplwex
       where codempid = p_codempid
       order by numseq;
  begin
    v_codapp            := p_codapp || '1';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    for i in c1 loop
      if param_msg_error is null then
        v_dtework         := get_date_output(i.dtestart) || ' - ' || get_date_output(i.dteend);
        v_rcnt            := v_rcnt + 1;
        begin
          insert
            into ttemprpt
              (
                codempid, codapp, numseq,
                item1, item2, item3, item4, item5,
                item6, item7, item8
              )
          values
              (
                global_v_codempid, v_codapp, v_numseq,
                p_codempid, -- item1
                v_rcnt, -- item2
                i.desnoffi, -- item3
                i.deslstjob1, -- item4
                i.desjob, -- item5
                v_dtework, -- item6
                i.desrisk, -- item7
                i.desprotc -- item8
              );
          v_numseq            := v_numseq + 1;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
        end;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_tapplwex;

  procedure insert_ttemprpt_thealinf2 is
    v_numseq            number := 1;
    v_codapp            varchar2(10 char);
    v_numseq2           number := 1;
    v_codapp2           varchar2(10 char);
    v_codprgheal        thealinf1.codprgheal%type;
    v_codcln            thealinf1.codcln%type;
    v_dteheal           thealinf1.dteheal%type;
    v_codcomp           thealinf1.codcomp%type;
    v_namdoc            thealinf1.namdoc%type;
    v_numcert           thealinf1.numcert%type;
    v_namdoc2           thealinf1.namdoc2%type;
    v_numcert2          thealinf1.numcert2%type;
    v_descheal          thealinf1.descheal%type;
    v_dtefollow         thealinf1.dtefollow%type;
    v_amtheal           thealinf1.amtheal%type;
    v_dtehealen         thealinf1.dtehealen%type;
    v_dteyear_output    ttemprpt.item1%type;
    v_dteheal_output    ttemprpt.item1%type;
    v_adress            tclninf.adresse%type;
    v_dteyear           thealinf1.dteyear%type;
    cursor c1 is
      select codheal, descheck, chkresult, descheal
        from thealinf2
        where codprgheal = v_codprgheal
          and codempid   = p_codempid
          and dteyear    = v_dteyear
        order by codheal;
  begin
    v_codapp            := p_codapp || '4';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    for x in reverse (p_dteyear - 2) .. p_dteyear  loop
      v_dteyear           := x;
      if param_msg_error is not null then
        exit;
      end if;
      begin
        select a.codprgheal, a.codcln, a.dteheal, a.codcomp, a.namdoc, a.numcert,
               a.namdoc2, a.numcert2, a.descheal, a.dtefollow, a.amtheal, a.dtehealen
          into v_codprgheal, v_codcln, v_dteheal, v_codcomp, v_namdoc, v_numcert,
               v_namdoc2, v_numcert2, v_descheal, v_dtefollow, v_amtheal, v_dtehealen
          from thealinf1 a, thealcde b
         where a.codprgheal = b.codprgheal
           and a.codempid   = p_codempid
           and a.dteyear    = v_dteyear
           and b.typpgm     = '1'
         fetch first 1 rows only;
      exception when no_data_found then
        v_codprgheal        := null;
        v_codcln            := null;
        v_dteheal           := null;
        v_codcomp           := null;
        v_namdoc            := null;
        v_numcert           := null;
        v_namdoc2           := null;
        v_numcert2          := null;
        v_descheal          := null;
        v_dtefollow         := null;
        v_amtheal           := null;
        v_dtehealen         := null;
      end;
      v_dteyear_output          := get_year_output(v_dteyear);
      v_dteheal_output          := get_date_output(v_dteheal);
      begin
        select decode(global_v_lang, '101', adresse,
                                     '102', adresst,
                                     '103', adress3,
                                     '104', adress4,
                                     '105', adress5, adresse)
          into v_adress
          from tclninf
         where codcln = v_codcln;
      exception when no_data_found then
        v_adress            := null;
      end;
      begin
        insert
          into ttemprpt
            (
              codempid, codapp, numseq,
              item1, item2, item3, item4, item5,
              item6, item7, item8, item9, item10,
              item11, item12
            )
        values
            (
              global_v_codempid, v_codapp, v_numseq,
              p_codempid, -- item1
              v_dteyear_output, -- item2
              v_codprgheal, -- item3
              '1', -- item4 typpgm
              v_dteheal_output, -- item5
              v_namdoc, -- item6
              v_numcert, -- item7
              v_namdoc2, -- item8
              v_numcert2, -- item9
              get_tclninf_name(v_codcln, global_v_lang), -- item10
              v_adress, -- item11
              v_descheal
            );
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
      v_codapp2           := p_codapp || '5';
      v_numseq2           := get_ttemprpt_numseq(v_codapp2);
      for i in c1 loop
        begin
          insert
            into ttemprpt
              (
                codempid, codapp, numseq,
                item1, item2, item3, item4, item5,
                item6, item7
              )
          values
              (
                global_v_codempid, v_codapp2, v_numseq2,
                p_codempid, -- item1
                v_dteyear_output, -- item2
                v_codprgheal, -- item3
                i.codheal || ' - ' || get_tcodec_name('tcodheal', i.codheal, global_v_lang), -- item4
                i.descheck, -- item5
                get_tlistval_name('CHKRESUL', i.chkresult, global_v_lang), -- item6
                i.descheal -- item7
              );
          v_numseq2           := v_numseq2 + 1;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
        end;
      end loop;
      v_numseq            := v_numseq + 1;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thealinf2;

  procedure insert_ttemprpt_thealinf1 (json_str_input clob) is
    v_numseq            number := 1;
    v_codapp            varchar2(10 char);
    v_numseq2           number := 1;
    v_codapp2           varchar2(10 char);
    obj_data            json_object_t;
    v_codprgheal        thealinf1.codprgheal%type;
    v_codcln            thealinf1.codcln%type;
    v_dteheal           thealinf1.dteheal%type;
    v_codcomp           thealinf1.codcomp%type;
    v_namdoc            thealinf1.namdoc%type;
    v_numcert           thealinf1.numcert%type;
    v_namdoc2           thealinf1.namdoc2%type;
    v_numcert2          thealinf1.numcert2%type;
    v_descheal          thealinf1.descheal%type;
    v_dtefollow         thealinf1.dtefollow%type;
    v_amtheal           thealinf1.amtheal%type;
    v_dtehealen         thealinf1.dtehealen%type;
    v_dteyear_output    ttemprpt.item1%type;
    v_dteheal_output    ttemprpt.item1%type;
    v_adress            tclninf.adresse%type;
    v_dteyear           thealinf1.dteyear%type;
    v_typpgm            thealcde.typpgm%type;
    cursor c1 is
      select codheal, descheck, chkresult, descheal
        from thealinf2
        where codprgheal = v_codprgheal
          and codempid   = p_codempid
          and dteyear    = v_dteyear
        order by codheal;
  begin
    v_codapp            := p_codapp || '4';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    obj_data            := json_object_t(json_str_input);
    v_dteyear           := hcm_util.get_number_t(obj_data, 'dteyear');
    v_codprgheal        := hcm_util.get_string_t(obj_data, 'codprgheal');
    v_typpgm            := hcm_util.get_string_t(obj_data, 'typpgm');
    begin
      select a.codcln, a.dteheal, a.codcomp, a.namdoc, a.numcert,
              a.namdoc2, a.numcert2, a.descheal, a.dtefollow, a.amtheal, a.dtehealen
        into v_codcln, v_dteheal, v_codcomp, v_namdoc, v_numcert,
              v_namdoc2, v_numcert2, v_descheal, v_dtefollow, v_amtheal, v_dtehealen
        from thealinf1 a
       where a.codempid   = p_codempid
         and a.dteyear    = v_dteyear
         and a.codprgheal = v_codprgheal
       fetch first 1 rows only;
    exception when no_data_found then
      v_codprgheal        := null;
      v_codcln            := null;
      v_dteheal           := null;
      v_codcomp           := null;
      v_namdoc            := null;
      v_numcert           := null;
      v_namdoc2           := null;
      v_numcert2          := null;
      v_descheal          := null;
      v_dtefollow         := null;
      v_amtheal           := null;
      v_dtehealen         := null;
    end;
    v_dteyear_output          := get_year_output(v_dteyear);
    v_dteheal_output          := get_date_output(v_dteheal);
    begin
      select decode(global_v_lang, '101', adresse,
                                    '102', adresst,
                                    '103', adress3,
                                    '104', adress4,
                                    '105', adress5, adresse)
        into v_adress
        from tclninf
        where codcln = v_codcln;
    exception when no_data_found then
      v_adress            := null;
    end;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1, item2, item3, item4, item5,
            item6, item7, item8, item9, item10,
            item11, item12
          )
      values
          (
            global_v_codempid, v_codapp, v_numseq,
            p_codempid, -- item1
            v_dteyear_output, -- item2
            v_codprgheal, -- item3
            v_typpgm, -- item4 typpgm
            v_dteheal_output, -- item5
            v_namdoc, -- item6
            v_numcert, -- item7
            v_namdoc2, -- item8
            v_numcert2, -- item9
            get_tclninf_name(v_codcln, global_v_lang), -- item10
            v_adress, -- item11
            v_descheal -- item12
          );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    v_codapp2           := p_codapp || '5';
    v_numseq2           := get_ttemprpt_numseq(v_codapp2);
    for i in c1 loop
      begin
        insert
          into ttemprpt
            (
              codempid, codapp, numseq,
              item1, item2, item3, item4, item5,
              item6, item7
            )
        values
            (
              global_v_codempid, v_codapp2, v_numseq2,
              p_codempid, -- item1
              v_dteyear_output, -- item2
              v_codprgheal, -- item3
              i.codheal || ' - ' || get_tcodec_name('tcodheal', i.codheal, global_v_lang), -- item4
              i.descheck, -- item5
              get_tlistval_name('CHKRESUL', i.chkresult, global_v_lang), -- item6
              i.descheal -- item7
            );
        v_numseq2           := v_numseq2 + 1;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thealinf1;

  procedure insert_ttemprpt_thwccase is
    v_rcnt              number := 0;
    v_numseq            number := 1;
    v_dteacd_output     ttemprpt.item1%type;
    v_codapp            varchar2(10 char);
    v_numday            ttemprpt.temp1%type;
    v_item7             ttemprpt.item7%type;
    v_item8             ttemprpt.item8%type;

--    cursor c1 is
--      select dteacd, desnote, coddc, dtestr, dteend
--        from thwccase
--       where codempid = p_codempid
--       order by dteacd;
  begin
    v_codapp            := p_codapp || '6';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
--    for i in c1 loop
--      if param_msg_error is null then
--        v_dteacd_output   := get_date_output(i.dteacd);
--        v_rcnt            := v_rcnt + 1;
--        v_numday          := (i.dteend -  i.dtestr) + 1;
--        v_item7           := null;
--        v_item8           := null;
--        if v_numday > 3 then
--          v_item7           := v_numday;
--        else
--          v_item8           := v_numday;
--        end if;
--        begin
--          insert
--            into ttemprpt
--              (
--                codempid, codapp, numseq,
--                item1, item2, item3, item4, item5,
--                item6, item7, item8
--              )
--          values
--              (
--                global_v_codempid, v_codapp, v_numseq,
--                p_codempid, -- item1
--                v_dteacd_output, -- item2
--                i.desnote, -- item3
--                get_tdcinf_name(i.coddc, global_v_lang), -- item4
--                null, -- item5
--                null, -- item6
--                v_item7, -- item7
--                v_item8 -- item8
--              );
--          v_numseq            := v_numseq + 1;
--        exception when others then
--          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
--        end;
--      end if;
--    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thwccase;

  procedure gen_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      if param_msg_error is null then
        gen_thisheal(json_output);
      end if;
      if param_msg_error is null then
        insert_ttemprpt_tapplwex;
      end if;
      if param_msg_error is null then
        gen_thisheald(json_output);
      end if;
      if param_msg_error is null then
        gen_thishealf(json_output);
      end if;
      if param_msg_error is null then
        insert_ttemprpt_thealinf2;
      end if;
      if param_msg_error is null then
        gen_thealinfl(json_output);
      end if;
      if param_msg_error is null then
        insert_ttemprpt_thwccase;
      end if;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end gen_report;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
  begin
    obj_data      := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));

    json_str_output := obj_data.to_clob;

  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;


end hres80x;

/
