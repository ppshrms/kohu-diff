--------------------------------------------------------
--  DDL for Package Body HRALATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRALATE" as
-- last update: 20/04/2018 10:30:00
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy'); 

    v_host_attach_file  := get_tsetup_value('BACKEND_URL');
    begin
      select folder
        into v_path_attach_file
        from tfolderd
       where upper(codapp) like 'HRALATE';
    exception when no_data_found then
      v_path_attach_file := null;
    end;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    null;
  end check_index;

  function get_file_attach (v_fullpath varchar2) return varchar2 is
    v_file_name        varchar2(200 char);
  begin
    if v_fullpath is not null then
      v_file_name      := v_fullpath;
      v_file_name      := replace(v_file_name, v_host_attach_file);
      v_file_name      := replace(v_file_name, v_path_attach_file || '/');
    end if;
    return v_file_name;
  exception when others then
    return v_file_name;
  end;

  function get_assign_seqno (v_mailalno varchar2, v_dteeffec varchar2) return number is
    v_number           number;
  begin
    begin
      select nvl(max(seqno), 0) + 1
        into v_number
        from talasign
       where codcompy = p_codcompy
         and mailalno = v_mailalno
         and dteeffec = v_dteeffec;
    end;
    return v_number;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);

    cursor c_talalert is
      select mailalno, subject, dteeffec, flgeffec,codcompy
        from talalert
       where codcompy = p_codcompy 
    order by mailalno, dteeffec;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in c_talalert loop
      if r1.flgeffec = 'A' then
        v_status           := get_label_name('HRALATE', global_v_lang, '10');
      else
        v_status           := get_label_name('HRALATE', global_v_lang, '20');
      end if;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('mailalno', r1.mailalno);
      obj_data.put('subject', r1.subject);
      obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('desc_flgeffec', v_status);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure post_delete (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_data(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end post_delete;

  procedure delete_data (json_str_input in clob, json_str_output out clob) is
    json_str        json_object_t;
    param_json       json_object_t;
    param_json_row   json_object_t;
    v_mailalno       varchar2(8 char);
    v_dteeffec       date;
    v_codcompy      talalert.codcompy%type; 
  begin
    json_str               := json_object_t(json_str_input);
    param_json             := hcm_util.get_json_t(json_str, 'param_json');
    for i in 0..param_json.get_size-1 loop
      param_json_row       := hcm_util.get_json_t(param_json, to_char(i));
      v_codcompy           := hcm_util.get_string_t(param_json_row, 'codcompy');
      v_mailalno           := hcm_util.get_string_t(param_json_row, 'mailalno');
      v_dteeffec           := to_date(hcm_util.get_string_t(param_json_row, 'dteeffec'), 'dd/mm/yyyy');

      begin
        delete talalert
         where codcompy = v_codcompy 
           and mailalno = v_mailalno
           and trunc(dteeffec) = v_dteeffec;
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
        commit;
      exception when others then 
        null;
      end;

      begin
        delete talasign
         where codcompy = v_codcompy 
           and mailalno = v_mailalno
           and trunc(dteeffec) = v_dteeffec;
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
        commit;
      exception
        when others then null;
      end;
    end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  end delete_data;

  procedure check_detail is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codcompy');
      return;
    end if;  
  
    if p_mailalno is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'mailalno');
      return;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dteeffec');
      return;
    end if;
  end check_detail;

  procedure check_assign_exists (json_str_input in clob, json_str_output out clob) is
    codcompap           varchar2(4000 char);
    codposap            varchar2(4000 char);
    codempap            varchar2(4000 char);
    json_obj            json_object_t;
    json_codcompap      json_object_t;
    json_codposap       json_object_t;
    json_codempap       json_object_t;
    v_error_count       number;
    v_number_pos        number := 0;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    json_codcompap      := hcm_util.get_json_t(json_obj, 'codcompap');
    json_codposap       := hcm_util.get_json_t(json_obj, 'codposap');
    json_codempap       := hcm_util.get_json_t(json_obj, 'codempap');
--    json_codcompap      := json(codcompap);
--    json_codposap       := json(codposap);
--    json_codempap       := json(codempap);
    v_error_count       := 0;

    if json_codcompap.get_size > 0 then
      for i in 0..json_codcompap.get_size - 1 loop
        v_codcompap      := upper(hcm_util.get_string_t(json_codcompap, i));
        if v_codcompap is not null then
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, v_codcompap);
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;
        end if;
      end loop;
    end if;

    if json_codposap.get_size > 0 then
      for i in 0..json_codposap.get_size - 1 loop
        v_codposap      := upper(hcm_util.get_string_t(json_codposap, i));
        if v_codposap is not null then
          begin
            select count(*)
              into v_number_pos
              from tpostn
             where codpos = v_codposap;
          end;
          if v_number_pos < 1 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;
        end if;
      end loop;
    end if;

    if json_codempap.get_size > 0 then
      for i in 0..json_codempap.get_size - 1 loop
        v_codempap      := upper(hcm_util.get_string_t(json_codempap, i));
        if v_codempap is not null then
          param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, v_codempap);
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;
        end if;
      end loop;
    end if;

    json_str_output := json_object_t().to_clob();
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end check_assign_exists;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'codcompy')); 
    p_mailalno          := upper(hcm_util.get_string_t(json_obj, 'mailalno'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'ddmmyyyy');
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_pathfile        json_object_t;
    obj_assign          json_object_t;
    obj_child           json_object_t;
    v_rcnt              number;
    v_rcnt_child        number;
    v_temp_path_file    varchar2(200 char);
    v_data_found        varchar2(1 char) := 'N';
    v_dteeffec          date;

    cursor c_talalert is
      select t1.*
        from talalert t1
       where trunc(t1.dteeffec) <= v_dteeffec
         and mailalno = p_mailalno
         and codcompy = p_codcompy 
    order by t1.dteeffec desc
    fetch next 1 rows only;

  begin
    v_dteeffec            := p_dteeffec;
    for r1 in c_talalert loop
      v_data_found        := 'Y';
    end loop;

    if v_data_found = 'N' then
      begin
        select max(t1.dteeffec) as dteeffec
          into v_dteeffec
          from talalert t1
         where mailalno = p_mailalno
         and codcompy = p_codcompy
        fetch next 1 rows only;
      exception when no_data_found then
        v_dteeffec      := trunc(to_date(sysdate));
      end;
    end if;

    v_data_found            := 'N';
    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    for r1 in c_talalert loop
      v_data_found          := 'Y';
      v_rcnt_child          := 0;
      obj_data              := json_object_t();
      obj_assign            := json_object_t();

      v_temp_path_file     := v_host_attach_file || v_path_attach_file || '/';

      obj_data.put('coderror', '200');
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('mailalno', r1.mailalno);
      obj_data.put('dteeffec', to_char(p_dteeffec, 'dd/mm/yyyy'));
      obj_data.put('typemail', r1.typemail);
      obj_data.put('subject', r1.subject);
      obj_data.put('message', r1.message);
      obj_data.put('syncond', r1.syncond);
      obj_data.put('desc_syncond', get_logical_name('HRALATE', r1.syncond, global_v_lang));
      obj_data.put('statement', r1.statement);
      obj_data.put('flgeffec', r1.flgeffec);
      obj_data.put('flgperiod', r1.flgperiod);
      obj_data.put('dtestrt', r1.dtestrt);
      obj_data.put('dteend', r1.dteend);
      obj_data.put('qtydayr', r1.qtydayr);
      obj_data.put('dtelast', r1.dtelast);
      obj_data.put('qtytlate', r1.qtytlate);
      obj_data.put('qtytearly', r1.qtytearly);
      obj_data.put('qtytabs', r1.qtytabs);
      obj_data.put('qtylate', r1.qtylate);
      obj_data.put('qtyearly', r1.qtyearly);
      obj_data.put('qtyabsent', r1.qtyabsent);
      obj_data.put('dteabsent', r1.dteabsent);
      obj_data.put('codsend', r1.codsend);
      obj_data.put('dtecreate', r1.dtecreate);
      obj_data.put('codcreate', r1.codcreate);
      obj_data.put('desc_codcreate', r1.codcreate);
      obj_data.put('dteupd', r1.dteupd);
      obj_data.put('coduser', r1.coduser);
      obj_data.put('desc_coduser', r1.coduser);
      obj_data.put('flgAdd', false);

      obj_pathfile      := json_object_t();
--      if r1.fileattch1 is not null then
--        obj_pathfile.put('0', v_temp_path_file || r1.fileattch1);
--        if r1.fileattch2 is not null then
--          obj_pathfile.put('1', v_temp_path_file || r1.fileattch2);
--          if r1.fileattch3 is not null then
--            obj_pathfile.put('2', v_temp_path_file || r1.fileattch3);
--            if r1.fileattch4 is not null then
--              obj_pathfile.put('3', v_temp_path_file || r1.fileattch4);
--            end if;
--          end if;
--        end if;
--      end if;
      if r1.fileattch1 is not null then
        obj_pathfile.put('0', r1.fileattch1);
        if r1.fileattch2 is not null then
          obj_pathfile.put('1', r1.fileattch2);
          if r1.fileattch3 is not null then
            obj_pathfile.put('2', r1.fileattch3);
            if r1.fileattch4 is not null then
              obj_pathfile.put('3', r1.fileattch4);
            end if;
          end if;
        end if;
      end if;
      obj_data.put('pathfile', obj_pathfile);

      obj_data.put('assign', obj_assign);
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt              := v_rcnt + 1;

    end loop;

    if obj_row.get_size = 0 then
      obj_data             := json_object_t();
      obj_assign           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('file_dir', v_path_attach_file);
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('mailalno', p_mailalno);
      obj_data.put('dteeffec', to_char(p_dteeffec, 'dd/mm/yyyy'));
      obj_data.put('pathfile', obj_pathfile);
      obj_data.put('assign', obj_assign);
      obj_data.put('typemail', '1');
      obj_data.put('flgAdd', true);
      obj_data.put('flgeffec', 'C');
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt              := v_rcnt + 1;
    end if;

    json_str_output := obj_row.to_clob;
  end gen_detail;

  procedure get_assign (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'codcompy')); 
    p_mailalno          := upper(hcm_util.get_string_t(json_obj, 'mailalno'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'ddmmyyyy');
    check_detail;
    if param_msg_error is null then
      gen_assign(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_assign;

  procedure gen_assign (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_pathfile        json_object_t;
    obj_assign          json_object_t;
    obj_child           json_object_t;
    v_rcnt              number;
    v_rcnt_child        number;
    v_temp_path_file    varchar2(200 char);
    v_data_found        varchar2(1 char) := 'N';
    v_dteeffec          date;
    flgAdd              boolean := false;

    cursor c_talalert is
      select t1.*
        from talalert t1
       where trunc(t1.dteeffec) = v_dteeffec
         and codcompy = p_codcompy
         and mailalno = p_mailalno;

    cursor c_talasign is
      select t1.*
        from talasign t1
       where trunc(t1.dteeffec) = v_dteeffec
         and codcompy = p_codcompy 
         and mailalno = p_mailalno
    order by t1.seqno;

  begin
    v_dteeffec            := p_dteeffec;
    for r1 in c_talalert loop
      v_data_found        := 'Y';
    end loop;

    if v_data_found = 'N' then
      flgAdd := true;
      begin
        select max(t1.dteeffec) as dteeffec
          into v_dteeffec
          from talalert t1
         where mailalno = p_mailalno
           and codcompy = p_codcompy 
           and trunc(t1.dteeffec) <= sysdate;
      exception when no_data_found then
        v_dteeffec      := trunc(to_date(sysdate));
      end;
    end if;

    v_data_found            := 'N';
    obj_row                 := json_object_t();
    obj_data                := json_object_t();
    v_rcnt                  := 0;
    for r2 in c_talasign loop
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seqno', r2.seqno);
      obj_data.put('flgappr', r2.flgappr);
      obj_data.put('codcompap', r2.codcompap);
      obj_data.put('codposap', r2.codposap);
      obj_data.put('codempap', r2.codempap);
      obj_data.put('message', r2.message);
      obj_data.put('flgAdd', flgAdd);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt       := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_assign;

  procedure post_save (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
    json_assign         json_object_t;
    json_pathfile       json_object_t;
    v_json              json_object_t;
    v_total_assign      number := 0;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    obj_detail          := hcm_util.get_json_t(json_obj, 'detail');
    -- obj_detail          := json(p_detail);
    p_codcompy          := upper(hcm_util.get_string_t(obj_detail, 'codcompy')); 
    p_mailalno          := upper(hcm_util.get_string_t(obj_detail, 'mailalno'));
    p_dteeffec          := to_date(hcm_util.get_string_t(obj_detail, 'dteeffec'), 'dd/mm/yyyy');
    p_typemail          := hcm_util.get_string_t(obj_detail, 'typemail');
    p_subject           := hcm_util.get_string_t(obj_detail, 'subject');
    p_message           := hcm_util.get_string_t(obj_detail, 'message');
    p_syncond           := hcm_util.get_json_t(obj_detail, 'syncond');
    p_syncond_code      := hcm_util.get_string_t(p_syncond, 'code');
    p_syncond_statement := hcm_util.get_string_t(p_syncond, 'statement');
    p_flgeffec          := hcm_util.get_string_t(obj_detail, 'flgeffec');
    p_flgperiod         := hcm_util.get_string_t(obj_detail, 'flgperiod');
    p_dtestrt           := hcm_util.get_string_t(obj_detail, 'dtestrt');
    p_dteend            := hcm_util.get_string_t(obj_detail, 'dteend');
    p_qtydayr           := hcm_util.get_string_t(obj_detail, 'qtydayr');
    p_dtelast           := hcm_util.get_string_t(obj_detail, 'dtelast');
    p_qtytlate          := hcm_util.get_string_t(obj_detail, 'qtytlate');
    p_qtytearly         := hcm_util.get_string_t(obj_detail, 'qtytearly');
    p_qtytabs           := hcm_util.get_string_t(obj_detail, 'qtytabs');
    p_qtylate           := hcm_util.get_string_t(obj_detail, 'qtylate');
    p_qtyearly          := hcm_util.get_string_t(obj_detail, 'qtyearly');
    p_qtyabsent         := hcm_util.get_string_t(obj_detail, 'qtyabsent');
    p_dteabsent         := hcm_util.get_string_t(obj_detail, 'dteabsent');
    p_codsend           := upper(hcm_util.get_string_t(obj_detail, 'codsend'));
    begin
      json_pathfile     := hcm_util.get_json_t(obj_detail, 'pathfile');
    exception when others then
      json_pathfile     := json_object_t();
    end;
    json_assign         := hcm_util.get_json_t(json_obj, 'assign');
    -- json_assign         := json(p_assign);

    v_file1             := get_file_attach(hcm_util.get_string_t(json_pathfile, '0'));
    v_file2             := get_file_attach(hcm_util.get_string_t(json_pathfile, '1'));
    v_file3             := get_file_attach(hcm_util.get_string_t(json_pathfile, '2'));
    v_file4             := get_file_attach(hcm_util.get_string_t(json_pathfile, '3'));

    check_save_main;
    if param_msg_error is null then
      save_data_main;
    end if;

    begin
      select count(*)
        into v_total_assign
        from talasign
       where mailalno = p_mailalno
         and codcompy = p_codcompy 
         and dteeffec = p_dteeffec;
    exception when no_data_found then
      v_total_assign := 0;
    end;

    if json_assign.get_size = 0 and v_total_assign = 0 then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if param_msg_error is null then
      save_data_assign(json_assign);
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
  end post_save;

  procedure check_save_main is
  begin
    if p_flgperiod = 'D' then
      if p_dtestrt is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      elsif p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
      p_qtydayr := null;
    elsif p_flgperiod in ('M', 'P') then
      p_dtestrt := null;
      p_dteend := null;
    end if;

    if p_typemail = '1' then
      if p_qtytlate is null and p_qtytearly is null and p_qtytabs is null and p_qtylate is null and p_qtyearly is null and p_qtyabsent is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
      p_dteabsent := null;
    elsif p_typemail = '2' then
      if p_dteabsent is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
      p_qtytlate    := null;
      p_qtytearly   := null;
      p_qtytabs     := null;
      p_qtylate     := null;
      p_qtyearly    := null;
      p_qtyabsent   := null;
    end if;

    -- if p_assign is null then
    --   param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    -- end if;

    if p_codsend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codsend);
      return;
    end if;

  end check_save_main;

  procedure save_data_main is
  begin
    begin
      insert into talalert (codcompy , mailalno, dteeffec, typemail, subject,
                            message, syncond, flgeffec, flgperiod,
                            dtestrt, dteend, qtydayr, dtelast,
                            qtytlate, qtytearly, qtytabs, qtylate,
                            qtyearly, qtyabsent, dteabsent, codsend,
                            fileattch1, fileattch2, fileattch3, fileattch4,
                            dtecreate, codcreate, dteupd, coduser,
                            statement
                            )
                    values (p_codcompy , p_mailalno, p_dteeffec, p_typemail, p_subject,
                            p_message, p_syncond_code, p_flgeffec, p_flgperiod,
                            p_dtestrt, p_dteend, p_qtydayr, p_dtelast,
                            p_qtytlate, p_qtytearly, p_qtytabs, p_qtylate,
                            p_qtyearly, p_qtyabsent, p_dteabsent, p_codsend,
                            v_file1, v_file2, v_file3, v_file4,
                            sysdate, global_v_coduser, sysdate, global_v_coduser,
                            p_syncond_statement
                            );
    exception
      when dup_val_on_index then
        begin
          update talalert
             set typemail = p_typemail,
                 subject = p_subject,
                 message = p_message,
                 syncond = p_syncond_code,
                 flgeffec = p_flgeffec,
                 flgperiod = p_flgperiod,
                 dtestrt = p_dtestrt,
                 dteend = p_dteend,
                 qtydayr = p_qtydayr,
                 dtelast = p_dtelast,
                 qtytlate = p_qtytlate,
                 qtytearly = p_qtytearly,
                 qtytabs = p_qtytabs,
                 qtylate = p_qtylate,
                 qtyearly = p_qtyearly,
                 qtyabsent = p_qtyabsent,
                 dteabsent = p_dteabsent,
                 fileattch1 = v_file1,
                 fileattch2 = v_file2,
                 fileattch3 = v_file3,
                 fileattch4 = v_file4,
                 codsend = p_codsend,
                 dteupd = sysdate,
                 coduser = global_v_coduser,
                 statement = p_syncond_statement
           where mailalno = p_mailalno
             and codcompy = p_codcompy 
             and dteeffec = p_dteeffec;
        end;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end save_data_main;

  procedure check_save_assign is
    v_number_pos      number := 0;
  begin
    if v_flgappr is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'flgappr');
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if v_codcompap is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, v_codcompap);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if v_codposap is not null then
      begin
        select count(*)
          into v_number_pos
          from tpostn
         where codpos = v_codposap;
      end;
      if v_number_pos < 1 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
      end if;
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if v_codempap is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, v_codempap);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_save_assign;

  procedure save_data_assign (param_json in json_object_t) is
    v_json             json_object_t;
  begin
    for i in 0..param_json.get_size-1 loop
      v_json         := hcm_util.get_json_t(param_json,to_char(i));
      v_flg          := lower(hcm_util.get_string_t(v_json, 'flg'));
      v_seqno        := to_number(hcm_util.get_string_t(v_json, 'seqno'));
      v_flgappr      := upper(hcm_util.get_string_t(v_json, 'flgappr'));
      v_codcompap    := upper(hcm_util.get_string_t(v_json, 'codcompap'));
      v_codposap     := upper(hcm_util.get_string_t(v_json, 'codposap'));
      v_codempap     := upper(hcm_util.get_string_t(v_json, 'codempap'));
      v_message      := hcm_util.get_string_t(v_json, 'message');

      check_save_assign;
      if v_flg in ('add', 'insert') then
        v_seqno      := get_assign_seqno(p_mailalno, p_dteeffec);
        begin
          insert into talasign (codcompy ,mailalno, dteeffec, seqno, flgappr,
                                codcompap, codposap, codempap, message,
                                dtecreate, codcreate)
                        values (p_codcompy , p_mailalno, p_dteeffec, v_seqno, v_flgappr,
                                v_codcompap, v_codposap, v_codempap, v_message,
                                sysdate, global_v_coduser);
        end;
      elsif v_flg in ('edit', 'update') then
        begin
          update talasign
             set flgappr = v_flgappr,
                 codcompap = v_codcompap,
                 codposap = v_codposap,
                 codempap = v_codempap,
                 message = v_message,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where mailalno = p_mailalno
             and codcompy = p_codcompy 
             and dteeffec = p_dteeffec
             and seqno = v_seqno;
        end;
      elsif v_flg in ('remove', 'delete') then
        begin
          delete from talasign
                where mailalno = p_mailalno
                  and codcompy = p_codcompy 
                  and dteeffec = p_dteeffec
                  and seqno = v_seqno;
        end;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end save_data_assign;

  procedure post_send_mail (json_str_input in clob, json_str_output out clob) is
    v_number_mail       number := 0;
    json_obj            json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'codcompy'));
    p_mailalno          := upper(hcm_util.get_string_t(json_obj, 'mailalno'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'dd/mm/yyyy');
    begin
      select count(*)
        into v_number_mail
        from talalert
       where mailalno = p_mailalno
         and codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    end;
    if v_number_mail > 0 then
      ALERTMSG_AL.gen_typemail1(p_codcompy,p_mailalno, p_dteeffec, 'N');
      param_msg_error := get_error_msg_php('HR2046', global_v_lang);
      json_str_output := get_response_message('200', param_msg_error, global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR7522', global_v_lang);
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end post_send_mail;

end HRALATE;

/
