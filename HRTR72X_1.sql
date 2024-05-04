--------------------------------------------------------
--  DDL for Package Body HRTR72X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR72X" AS
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
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dteyearst         := to_number(hcm_util.get_number_t(json_obj, 'p_dteyearst'));
    p_dteyearen         := to_number(hcm_util.get_number_t(json_obj, 'p_dteyearen'));
    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));
    p_codcours          := hcm_util.get_string_t(json_obj, 'p_codcours');
    p_numclseq          := to_number(hcm_util.get_number_t(json_obj, 'p_numclseq'));
    p_codtparg          := hcm_util.get_string_t(json_obj, 'p_codtparg');
    -- report
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function convert_numhour_to_minute (v_number number) return varchar2 is
  begin
    return (trunc(v_number) * 60) +  (mod(v_number, 1) * 100);
  end convert_numhour_to_minute;

  function get_tcodexpn_name (v_codexpn tcodexpn.codexpn%type, v_lang varchar2 default '102') return varchar2 is
    v_descod          tcodexpn.descode%type;
  begin
    begin
      select decode(global_v_lang, '101', descode
                                 , '102', descodt
                                 , '103', descodt
                                 , '104', descodt
                                 , '105', descodt
                                 , descode)
        into v_descod
        from tcodexpn
       where codexpn  = v_codexpn;
    exception when no_data_found then
      null;
    end;
    return v_descod;
  end get_tcodexpn_name;

  procedure check_index is
    v_codcompy         tcompny.codcompy%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
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
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_data_found        boolean := false;
    v_zupdsal           varchar2(100 char);
    v_flgeval           ttrimph.flgeval%type := 'U';

    cursor c1 is
      select codempid, codcomp, codpos, codtparg, dteyear, codcours, numclseq, dtetrst, dtetren, qtytrmin, amtcost, codinsts, codinst, codhotel, flgtrevl
        from thistrnn
       where dteyear  between p_dteyearst and p_dteyearen
         and codcomp  like p_codcomp || '%'
         and codempid = nvl(p_codempid, codempid)
       order by codcomp, codempid, codtparg, dteyear, codcours, numclseq;
  begin
    obj_row       := json_object_t();
    for i in c1 loop
      v_data_found  := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        begin
          select flgeval
            into v_flgeval
            from ttrimph
          where dteyear  = i.dteyear
            and codcours = i.codcours
            and numclseq = i.numclseq
            and codempid = i.codempid;
        exception when no_data_found then
          v_flgeval := 'U';
        end;
        v_rcnt        := v_rcnt+1;
        obj_data      := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codpos', i.codpos);
        obj_data.put('codtparg', to_char(i.codtparg));
        obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG', i.codtparg, global_v_lang));
        obj_data.put('dteyear', to_char(i.dteyear));
        obj_data.put('codcours', i.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
        obj_data.put('numclseq', i.numclseq);
        obj_data.put('dtetrst', to_char(i.dtetrst, 'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(i.dtetren, 'dd/mm/yyyy'));
        obj_data.put('qtytrmin', convert_numhour_to_minute(i.qtytrmin));
        obj_data.put('amtcost', nvl(i.amtcost, 0));
        obj_data.put('codinsts', i.codinsts);
        obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts, global_v_lang));
        obj_data.put('codinst', i.codinst);
        obj_data.put('desc_codinst', get_tinstruc_name(i.codinst, global_v_lang));
        obj_data.put('codhotel', i.codhotel);
        obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel, global_v_lang));
        obj_data.put('flgtrevl', v_flgeval);
        obj_data.put('desc_flgtrevl', get_tlistval_name('FLGEVAL', v_flgeval, global_v_lang));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_data_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thistrnn');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure check_detail is
    v_zupdsal          varchar2(100 char);
  begin
    if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
  end check_detail;

  procedure get_thistrnn (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thistrnn(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thistrnn;

  procedure gen_thistrnn (json_str_output out clob) AS
    obj_data            json_object_t;
    v_flgeval           ttrimph.flgeval%type := 'U';
    v_desc_flgtrain     varchar2(100 char) := get_label_name('HRTR72X4', global_v_lang, 430);

    cursor c1 is
      select codempid, codcomp, codtparg, dteyear, codcours,
             numclseq, dtetrst, dtetren, qtytrmin, amtcost,
             codinsts, codinst, codhotel, flgtrevl, typtrain,
             qtyprescr, qtyposscr, numcert, dtecert, descomptr,
             flgtrain, content, codpos
        from thistrnn
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codempid = p_codempid;
  begin
    obj_data      := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('image', get_emp_img(p_codempid));
    obj_data.put('codempid', p_codempid);
    obj_data.put('codcomp', '');
    obj_data.put('desc_codcomp', '');
    obj_data.put('codpos', '');
    obj_data.put('desc_codpos', '');
    obj_data.put('dteyear', '');
    obj_data.put('numclseq', '');
    obj_data.put('codtparg', '');
    obj_data.put('desc_codtparg', '');
    obj_data.put('codcours', '');
    obj_data.put('desc_codcours', '');
    obj_data.put('dtetrst', '');
    obj_data.put('dtetren', '');
    obj_data.put('qtytrmin', '');
    obj_data.put('amtcost', '');
    obj_data.put('codinsts', '');
    obj_data.put('desc_codinsts', '');
    obj_data.put('codinst', '');
    obj_data.put('desc_codinst', '');
    obj_data.put('codhotel', '');
    obj_data.put('desc_codhotel', '');
    obj_data.put('flgtrevl', v_flgeval);
    obj_data.put('desc_flgtrevl', v_flgeval);
    obj_data.put('typtrain', '');
    obj_data.put('typtrain', '');
    obj_data.put('desc_typtrain', '');
    obj_data.put('qtyprescr', '');
    obj_data.put('qtyposscr', '');
    obj_data.put('numcert', '');
    obj_data.put('dtecert', '');
    obj_data.put('descomptr', '');
    obj_data.put('flgtrain', '');
    obj_data.put('desc_flgtrain', v_desc_flgtrain);
    obj_data.put('content', '');
    for i in c1 loop
      begin
        select flgeval
          into v_flgeval
          from ttrimph
         where dteyear  = i.dteyear
           and codcours = i.codcours
           and numclseq = i.numclseq
           and codempid = i.codempid;
      exception when no_data_found then
        null;
      end;
      if i.flgtrain = 'Y' then
        v_desc_flgtrain := get_label_name('HRTR72X4', global_v_lang, 430);
      else
        v_desc_flgtrain := get_label_name('HRTR72X4', global_v_lang, 440);
      end if;
      obj_data.put('codempid', i.codempid);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('codpos', i.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('dteyear', to_char(i.dteyear));
      obj_data.put('numclseq', i.numclseq);
      obj_data.put('codtparg', i.codtparg);
      obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG', i.codtparg, global_v_lang));
      obj_data.put('codcours', i.codcours);
      obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
      obj_data.put('dtetrst', to_char(i.dtetrst, 'dd/mm/yyyy'));
      obj_data.put('dtetren', to_char(i.dtetren, 'dd/mm/yyyy'));
      obj_data.put('qtytrmin', convert_numhour_to_minute(i.qtytrmin));
      obj_data.put('amtcost', nvl(i.amtcost, 0));
      obj_data.put('codinsts', i.codinsts);
      obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts, global_v_lang));
      obj_data.put('codinst', i.codinst);
      obj_data.put('desc_codinst', get_tinstruc_name(i.codinst, global_v_lang));
      obj_data.put('codhotel', i.codhotel);
      obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel, global_v_lang));
      obj_data.put('flgtrevl', i.flgtrevl);
      obj_data.put('desc_flgtrevl', get_tlistval_name('FLGTREVL', i.flgtrevl, global_v_lang));
      obj_data.put('flgeval', v_flgeval);
      obj_data.put('desc_flgeval', get_tlistval_name('FLGEVAL', v_flgeval, global_v_lang));
      obj_data.put('typtrain', i.typtrain);
      obj_data.put('desc_typtrain', get_tlistval_name('TYPTRAIN', i.typtrain, global_v_lang));
      obj_data.put('qtyprescr', nvl(i.qtyprescr, 0));
      obj_data.put('qtyposscr', nvl(i.qtyposscr, 0));
      obj_data.put('numcert', i.numcert);
      obj_data.put('dtecert', to_char(i.dtecert, 'dd/mm/yyyy'));
      obj_data.put('descomptr', i.descomptr);
      obj_data.put('flgtrain', i.flgtrain);
      obj_data.put('desc_flgtrain', v_desc_flgtrain);
      obj_data.put('content', i.content);
    end loop;

    if isInsertReport then
      insert_ttemprpt(obj_data);
    end if;
    json_str_output := obj_data.to_clob;
  end gen_thistrnn;

  procedure get_tknowleg (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tknowleg(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tknowleg;

  procedure gen_tknowleg (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_folderd           varchar2(100 char);

    cursor c1 is
      select subject, attfile, url
        from tknowleg
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and (codempid = p_codempid
          or codempid  is null)
       order by itemno;
  begin
    obj_row       := json_object_t();
    if p_codtparg = '1' then
      v_folderd := 'HRTR63E';
    else
      v_folderd := 'HRTR7AE';
    end if;
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('subject', i.subject);
      obj_data.put('attfile', i.attfile);
      obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP') || get_tfolderd(v_folderd) || '/' || i.attfile);
      obj_data.put('url', i.url);
      obj_data.put('path_link', i.url);
      if isInsertReport then
        insert_ttemprpt_tknowleg(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tknowleg;

  procedure get_thistrnf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thistrnf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thistrnf;

  procedure gen_thistrnf (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_folderd           varchar2(100 char);

    cursor c1 is
      select filename, descfile
        from thistrnf
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codempid = p_codempid
       order by numseq;
  begin
    obj_row       := json_object_t();
    v_folderd := 'HRTR7AE';
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('filename', i.filename);
      obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP') || get_tfolderd(v_folderd) || '/' || i.filename);
      obj_data.put('descfile', i.descfile);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
      if isInsertReport then
        insert_ttemprpt_thistrnf(obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_thistrnf;

  procedure get_thistrnb (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thistrnb(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thistrnb;

  procedure gen_thistrnb (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select descomment
        from thistrnb
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codempid = p_codempid
       order by numseq;
  begin
    obj_row       := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('descomment', i.descomment);
      if isInsertReport then
        insert_ttemprpt_thistrnb(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_thistrnb;

  procedure get_thisclsss (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thisclsss(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thisclsss;

  procedure gen_thisclsss (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codcompy          tcompny.codcompy%type;

    cursor c1 is
      select descomment
        from thisclsss
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codcompy = v_codcompy
       order by numseq;
  begin
    obj_row       := json_object_t();
    v_codcomp     := hcm_util.get_temploy_field(p_codempid, 'codcomp');
    v_codcompy    := hcm_util.get_codcomp_level(v_codcomp, 1);
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('descomment', i.descomment);
      if isInsertReport then
        insert_ttemprpt_thisclsss(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_thisclsss;

  procedure get_thiscost (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thiscost(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thiscost;

  procedure gen_thiscost (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codexpn, typexpn, amtcost, amttrcost
        from thiscost
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codempid = p_codempid
       order by codexpn;
  begin
    obj_row       := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codexpn', i.codexpn);
      obj_data.put('desc_codexpn', get_tcodexpn_name(i.codexpn, global_v_lang));
      obj_data.put('typexpn', i.typexpn);
      obj_data.put('desc_typexpn', get_tlistval_name('TYPEXPN', i.typexpn, global_v_lang));
      obj_data.put('amtcost', nvl(i.amtcost, 0));
      obj_data.put('amttrcost', nvl(i.amttrcost, 0));
      if isInsertReport then
        insert_ttemprpt_thiscost(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_thiscost;

  procedure get_thistrnp (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thistrnp(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thistrnp;

  procedure gen_thistrnp (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numseq, descplan, dtestr, dteend, descomment
        from thistrnp
       where dteyear  = p_dteyear
         and codcours = p_codcours
         and numclseq = p_numclseq
         and codempid = p_codempid
       order by numseq;
  begin
    obj_row       := json_object_t();
    for i in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', i.numseq);
      obj_data.put('descplan', i.descplan);
      obj_data.put('dtestr', to_char(i.dtestr, 'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(i.dteend, 'dd/mm/yyyy'));
      obj_data.put('descomment', i.descomment);
      if isInsertReport then
        insert_ttemprpt_thistrnp(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_thistrnp;

  procedure initial_report (json_obj json_object_t) AS
  begin
    p_codempid          := hcm_util.get_string_t(json_obj, 'codempid');
    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'dteyear'));
    p_codcours          := hcm_util.get_string_t(json_obj, 'codcours');
    p_numclseq          := to_number(hcm_util.get_number_t(json_obj, 'numclseq'));
    p_codtparg          := hcm_util.get_string_t(json_obj, 'codtparg');
  end initial_report;

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

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 1;
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_desc_codcomp      varchar2(1000 char);
    v_codpos            thistrnn.codpos%type;
    v_desc_codpos       varchar2(1000 char);
    v_dteyear           thistrnn.dteyear%type;
    v_dteyear_output    varchar2(50 char);
    v_dtetrst           thistrnn.dtetrst%type;
    v_dtetrst_output    varchar2(50 char);
    v_dtetren           thistrnn.dtetren%type;
    v_dtetren_output    varchar2(50 char);
    v_dtecert           thistrnn.dtecert%type;
    v_dtecert_output    varchar2(50 char);
    v_numclseq          thistrnn.numclseq%type;
    v_codtparg          thistrnn.codtparg%type;
    v_desc_codtparg     varchar2(1000 char);
    v_codcours          thistrnn.codcours%type;
    v_desc_codcours     varchar2(1000 char);
    v_qtytrmin          thistrnn.qtytrmin%type;
    v_amtcost           thistrnn.amtcost%type;
    v_codinsts          thistrnn.codinsts%type;
    v_desc_codinsts     varchar2(1000 char);
    v_codinst           thistrnn.codinst%type;
    v_desc_codinst      varchar2(1000 char);
    v_codhotel          thistrnn.codhotel%type;
    v_desc_codhotel     varchar2(1000 char);
    v_flgtrevl          thistrnn.flgtrevl%type;
    v_desc_flgtrevl     varchar2(1000 char);
    v_flgeval           ttrimph.flgeval%type;
    v_desc_flgeval      varchar2(1000 char);
    v_typtrain          thistrnn.typtrain%type;
    v_desc_typtrain     varchar2(1000 char);
    v_qtyprescr         thistrnn.qtyprescr%type;
    v_qtyposscr         thistrnn.qtyposscr%type;
    v_numcert           thistrnn.numcert%type;
    v_descomptr         thistrnn.descomptr%type;
    v_flgtrain          thistrnn.flgtrain%type;
    v_desc_flgtrain     varchar2(1000 char);
    v_content           thistrnn.content%type;
    v_image             varchar2(1000 char);
  begin
    v_numseq            := get_ttemprpt_numseq(p_codapp);
    v_image             := hcm_util.get_string_t(obj_data, 'image');
    v_codempid          := hcm_util.get_string_t(obj_data, 'codempid');
    v_codcomp           := hcm_util.get_string_t(obj_data, 'codcomp');
    v_desc_codcomp      := hcm_util.get_string_t(obj_data, 'desc_codcomp');
    v_codpos            := hcm_util.get_string_t(obj_data, 'codpos');
    v_desc_codpos       := hcm_util.get_string_t(obj_data, 'desc_codpos');
    v_dteyear           := to_number(hcm_util.get_string_t(obj_data, 'dteyear'));
    v_dteyear_output    := v_dteyear + v_additional_year;
    v_dtetrst           := to_date(hcm_util.get_string_t(obj_data, 'dtetrst'), 'dd/mm/yyyy');
    v_dtetrst_output    := to_char(v_dtetrst, 'dd/mm/') || (to_number(to_char(v_dtetrst, 'yyyy')) + v_additional_year);
    v_dtetren           := to_date(hcm_util.get_string_t(obj_data, 'dtetren'), 'dd/mm/yyyy');
    v_dtetren_output    := to_char(v_dtetren, 'dd/mm/') || (to_number(to_char(v_dtetren, 'yyyy')) + v_additional_year);
    v_dtecert           := to_date(hcm_util.get_string_t(obj_data, 'dtecert'), 'dd/mm/yyyy');
    v_dtecert_output    := to_char(v_dtecert, 'dd/mm/') || (to_number(to_char(v_dtecert, 'yyyy')) + v_additional_year);
    v_numclseq          := hcm_util.get_string_t(obj_data, 'numclseq');
    v_codtparg          := hcm_util.get_string_t(obj_data, 'codtparg');
    v_desc_codtparg     := hcm_util.get_string_t(obj_data, 'desc_codtparg');
    v_codcours          := hcm_util.get_string_t(obj_data, 'codcours');
    v_desc_codcours     := hcm_util.get_string_t(obj_data, 'desc_codcours');
    v_qtytrmin          := hcm_util.get_string_t(obj_data, 'qtytrmin');
    v_amtcost           := hcm_util.get_string_t(obj_data, 'amtcost');
    v_codinsts          := hcm_util.get_string_t(obj_data, 'codinsts');
    v_desc_codinsts     := hcm_util.get_string_t(obj_data, 'desc_codinsts');
    v_codinst           := hcm_util.get_string_t(obj_data, 'codinst');
    v_desc_codinst      := hcm_util.get_string_t(obj_data, 'desc_codinst');
    v_codhotel          := hcm_util.get_string_t(obj_data, 'codhotel');
    v_desc_codhotel     := hcm_util.get_string_t(obj_data, 'desc_codhotel');
    v_flgtrevl          := hcm_util.get_string_t(obj_data, 'flgtrevl');
    v_desc_flgtrevl     := hcm_util.get_string_t(obj_data, 'desc_flgtrevl');
    v_flgeval           := hcm_util.get_string_t(obj_data, 'flgeval');
    v_desc_flgeval      := hcm_util.get_string_t(obj_data, 'desc_flgeval');
    v_typtrain          := hcm_util.get_string_t(obj_data, 'typtrain');
    v_desc_typtrain     := hcm_util.get_string_t(obj_data, 'desc_typtrain');
    v_qtyprescr         := hcm_util.get_string_t(obj_data, 'qtyprescr');
    v_qtyposscr         := hcm_util.get_string_t(obj_data, 'qtyposscr');
    v_numcert           := hcm_util.get_string_t(obj_data, 'numcert');
    v_descomptr         := hcm_util.get_string_t(obj_data, 'descomptr');
    v_flgtrain          := hcm_util.get_string_t(obj_data, 'flgtrain');
    v_desc_flgtrain     := hcm_util.get_string_t(obj_data, 'desc_flgtrain');
    v_content           := hcm_util.get_string_t(obj_data, 'content');
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
             item36, item37, item38
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_image, -- item1
             v_codempid, -- item2
             v_dteyear, -- item3
             v_codcours, -- item4
             v_numclseq, -- item5
             v_codtparg, -- item6
             v_codcomp, -- item7
             get_temploy_name(v_codempid, global_v_lang), -- item8
             v_dteyear_output, -- item9
             v_desc_codtparg, -- item10
             v_desc_codcours, -- item11
             v_dtetrst_output, -- item12
             v_dtetren_output, -- item13
             hcm_util.convert_minute_to_hour(v_qtytrmin), -- item14
             to_char(v_amtcost, 'fm99,999,999.90'), -- item15
             v_codinsts, -- item16
             v_desc_codinsts, -- item17
             v_codinst, -- item18
             v_desc_codinst, -- item19
             v_codhotel, -- item20
             v_desc_codhotel, -- item21
             v_flgtrevl, -- item22
             v_desc_flgtrevl, -- item23
             v_flgeval, -- item24
             v_desc_flgeval, -- item25
             v_typtrain, -- item26
             v_desc_typtrain, -- item27
             to_char(v_qtyprescr, 'fm999.90'), -- item28
             to_char(v_qtyposscr, 'fm999.90'), -- item29
             v_numcert, -- item30
             v_dtecert_output, -- item31
             v_descomptr, -- item32
             v_flgtrain, -- item33
             v_desc_flgtrain, -- item34
             v_content, -- item35
             v_desc_codcomp, -- item36
             v_codpos, -- item37
             v_desc_codpos -- item38
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;

  procedure insert_ttemprpt_tknowleg(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_subject           tknowleg.subject%type;
    v_attfile           tknowleg.attfile%type;
    v_url               tknowleg.url%type;
  begin
    v_codapp            := p_codapp || '1';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_subject           := hcm_util.get_string_t(obj_data, 'subject');
    v_attfile           := hcm_util.get_string_t(obj_data, 'attfile');
    v_url               := hcm_util.get_string_t(obj_data, 'url');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8, item9, item10
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_subject, -- item8
             v_attfile, -- item9
             v_url -- item10
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_tknowleg;

  procedure insert_ttemprpt_thistrnb(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_descomment        thistrnb.descomment%type;
  begin
    v_codapp            := p_codapp || '2';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_descomment        := hcm_util.get_string_t(obj_data, 'descomment');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_descomment -- item8
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnb;

  procedure insert_ttemprpt_thisclsss(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_descomment        thisclsss.descomment%type;
  begin
    v_codapp            := p_codapp || '2';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_descomment        := hcm_util.get_string_t(obj_data, 'descomment');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_descomment -- item8
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thisclsss;

  procedure insert_ttemprpt_thistrnf(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_filename          thistrnf.filename%type;
    v_descfile          thistrnf.descfile%type;
  begin
    v_codapp            := p_codapp || '3';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_filename          := hcm_util.get_string_t(obj_data, 'filename');
    v_descfile          := hcm_util.get_string_t(obj_data, 'descfile');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8, item9
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_filename, -- item8
             v_descfile -- item9
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnf;

  procedure insert_ttemprpt_thiscost(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_codexpn           thiscost.codexpn%type;
    v_desc_codexpn      varchar2(1000 char);
    v_typexpn           thiscost.typexpn%type;
    v_desc_typexpn      varchar2(1000 char);
    v_amtcost           thiscost.amtcost%type;
    v_amttrcost         thiscost.amttrcost%type;
  begin
    v_codapp            := p_codapp || '4';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_codexpn           := hcm_util.get_string_t(obj_data, 'codexpn');
    v_desc_codexpn      := hcm_util.get_string_t(obj_data, 'desc_codexpn');
    v_typexpn           := hcm_util.get_string_t(obj_data, 'typexpn');
    v_desc_typexpn      := hcm_util.get_string_t(obj_data, 'desc_typexpn');
    v_amtcost           := hcm_util.get_string_t(obj_data, 'amtcost');
    v_amttrcost         := hcm_util.get_string_t(obj_data, 'amttrcost');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8, item9, item10,
             item11, item12, item13
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_codexpn, -- item8
             v_desc_codexpn, -- item9
             v_typexpn, -- item10
             v_desc_typexpn, -- item11
             v_amtcost, -- item12
             v_amttrcost -- item13
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thiscost;

  procedure insert_ttemprpt_thistrnp(obj_data in json_object_t) is
    v_codapp            varchar2(10 char);
    v_numseq            number := 1;
    v_descplan          thistrnp.descplan%type;
    v_dtestr            thistrnp.dtestr%type;
    v_dtestr_output     varchar2(50 char);
    v_dteend            thistrnp.dteend%type;
    v_dteend_output     varchar2(50 char);
    v_descomment        thistrnp.descomment%type;
  begin
    v_codapp            := p_codapp || '5';
    v_numseq            := get_ttemprpt_numseq(v_codapp);
    v_descplan          := hcm_util.get_string_t(obj_data, 'descplan');
    v_dtestr            := to_date(hcm_util.get_string_t(obj_data, 'dtestr'), 'dd/mm/yyyy');
    v_dtestr_output     := to_char(v_dtestr, 'dd/mm/') || (to_number(to_char(v_dtestr, 'yyyy')) + v_additional_year);
    v_dteend            := to_date(hcm_util.get_string_t(obj_data, 'dteend'), 'dd/mm/yyyy');
    v_dteend_output     := to_char(v_dteend, 'dd/mm/') || (to_number(to_char(v_dteend, 'yyyy')) + v_additional_year);
    v_descomment        := hcm_util.get_string_t(obj_data, 'descomment');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item2, item3, item4, item5,
             item6, item8, item9, item10, item11
           )
      values
           (
             global_v_codempid, v_codapp, v_numseq,
             p_codempid, -- item2
             p_dteyear, -- item3
             p_codcours, -- item4
             p_numclseq, -- item5
             p_codtparg, -- item6
             v_descplan, -- item8
             v_dtestr_output, -- item9
             v_dteend_output, -- item10
             v_descomment -- item11
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnp;

  procedure gen_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_params.get_size - 1 loop
        if param_msg_error is not null then
          exit;
        end if;
        initial_report(hcm_util.get_json_t(json_params, to_char(i)));
        gen_thistrnn(json_output);
        gen_tknowleg(json_output);
        if p_codtparg = '2' then
          gen_thistrnb(json_output);
          gen_thistrnf(json_output);
          gen_thiscost(json_output);
          gen_thistrnp(json_output);
        else
          gen_thisclsss(json_output);
        end if;
      end loop;
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
end HRTR72X;


/
