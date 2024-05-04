--------------------------------------------------------
--  DDL for Package Body HRES3FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES3FX" is
-- last update: 15/04/2019 16:01

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_dtest       := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    b_index_dteen       := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteeffec    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteeffec')),'dd/mm/yyyy');
    b_index_numseq      := to_char(hcm_util.get_string_t(json_obj,'p_numseq'));

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);

    cursor c1 is
      select codcomp,dteeffec,numseq,filename,url,
             decode(global_v_lang, '101', subjecte,
                                   '102', subjectt,
                                   '103', subject3,
                                   '104', subject4,
                                   '105', subject5, subjecte) subject
        from tannounce
       where typemsg = 'A'
         and ctrl_codcomp like codcomp||'%'
         and trunc(dteeffec) between  trunc(b_index_dtest) and trunc(b_index_dteen)
      order by dteeffec desc,numseq;

  begin
    obj_row := json_object_t();

    begin
      select folder
        into v_filepath
        from tfolderd
       where codapp = 'HRCO1BE';
    exception when no_data_found then
      v_filepath := null;
    end;

    for r1 in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('numseq',r1.numseq);
      obj_data.put('subject',r1.subject);
      obj_data.put('filename',r1.filename);
      obj_data.put('path_link',r1.url);
      obj_data.put('path_filename',get_tsetup_value('PATHDOC')||v_filepath||'/'||r1.filename);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tannounce');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_data      json_object_t;
    v_filepath    varchar2(100 char);

    cursor c1 is
      select filename,url,codappr,dteappr,
             decode(global_v_lang, '101', subjecte,
                                   '102', subjectt,
                                   '103', subject3,
                                   '104', subject4,
                                   '105', subject5, subjecte) subject,
             decode(global_v_lang, '101', messagee,
                                   '102', messaget,
                                   '103', message3,
                                   '104', message4,
                                   '105', message5, messagee) message
        from tannounce
       where codcomp   = b_index_codcomp
         and dteeffec  = b_index_dteeffec
         and numseq    = b_index_numseq
         and typemsg   = 'A';

  begin
    obj_data := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('subject', r1.subject);
      obj_data.put('remark', r1.message);
      obj_data.put('filename', r1.filename);
      obj_data.put('url', r1.url);
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
      if r1.filename is not null then
        begin
          select folder
            into v_filepath
            from tfolderd
           where codapp = 'HRCO1BE';
        exception when no_data_found then
          v_filepath := null;
        end;
        obj_data.put('attfile', get_tsetup_value('PATHDOC')||v_filepath||'/'||r1.filename);
      else
        obj_data.put('attfile', '');
      end if;
    end loop;
    json_str_output := obj_data.to_clob;
  end;
  --
  procedure check_index is
  begin
    begin
      select codcomp into ctrl_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      ctrl_codcomp := null;
    end;
    if b_index_dtest is not null then
      if b_index_dteen is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
    end if;
    if b_index_dteen is not null then
      if b_index_dtest is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
    end if;
    if b_index_dtest > b_index_dteen then
          param_msg_error := get_error_msg_php('HR2020',global_v_lang);
          return;
    end if;
  end;
  --
end;

/
