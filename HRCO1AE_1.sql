--------------------------------------------------------
--  DDL for Package Body HRCO1AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO1AE" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_flg           := hcm_util.get_string_t(json_obj,'p_flg');
    p_indexid           := hcm_util.get_string_t(json_obj,'p_indexid');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_subjecte          := hcm_util.get_string_t(json_obj,'p_subjecte');
    p_subjectt          := hcm_util.get_string_t(json_obj,'p_subjectt');
    p_subject3          := hcm_util.get_string_t(json_obj,'p_subject3');
    p_subject4          := hcm_util.get_string_t(json_obj,'p_subject4');
    p_subject5          := hcm_util.get_string_t(json_obj,'p_subject5');
    p_messagee          := hcm_util.get_string_t(json_obj,'p_messagee');
    p_messaget          := hcm_util.get_string_t(json_obj,'p_messaget');
    p_message3          := hcm_util.get_string_t(json_obj,'p_message3');
    p_message4          := hcm_util.get_string_t(json_obj,'p_message4');
    p_message5          := hcm_util.get_string_t(json_obj,'p_message5');
  end initial_value;

  procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
    if p_codcompy is not null then
      begin
        select codcompy
        into   p_codcompy
        from   tcompny
        where  codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcompy');
        return;
      end;
    end if;
    if p_codcompy is not null then
      error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if error_secur is not null then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_index;
  procedure check_index2 is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcompy is not null then
      begin
        select codcompy
        into   p_codcompy
        from   tcompny
        where  codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
        return;
      end;
    end if;
    if p_codcompy is not null then
      error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if error_secur is not null then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;
  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
--    if p_dteend is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--      return;
--    end if;
--    if (p_subjectt is null and p_subjecte is null and p_subject3 is null and p_subject4 is null and p_subject5 is null) then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--      return;
--    end if;
    if (p_messaget is null and p_messagee is null and p_message3 is null and p_message4 is null and p_message5 is null)  then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_tempmessage   varchar2(1000 char) := '';
  cursor c_tmessage is
    select rowid as indexid
    ,codcompy
    ,TO_CHAR(dtestrt, 'DD/MM/YYYY') as dtestrt
    ,TO_CHAR(dteend, 'DD/MM/YYYY') as dteend
    , SUBJECTT
    , SUBJECTE
    , SUBJECT3
    , SUBJECT4
    , SUBJECT5
    , messaget
    , messagee
    , message3
    , message4
    , message5
    , TO_CHAR(DTECREATE, 'DD/MM/YYYY') as DTECREATE
    , CODCREATE from tmessage
--    get_tcompny_name(CODCREATE,global_v_lang) as
    where codcompy = p_codcompy
      and ( dtestrt between p_dtestrt and p_dteend or
            dteend between p_dtestrt and p_dteend or
            p_dtestrt between dtestrt and dteend or
            p_dteend between dtestrt and dteend )
    order by dtestrt;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();
    for r1 in c_tmessage loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('indexid', r1.indexid);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('dtestrt', r1.dtestrt);
      obj_data.put('dteend', r1.dteend);
      obj_data.put('subjectt', r1.subjectt);
      obj_data.put('subjecte', r1.subjecte);
      obj_data.put('subject3', r1.subject3);
      obj_data.put('subject4', r1.subject4);
      obj_data.put('subject5', r1.subject5);
      obj_data.put('messagee', r1.messagee);
      obj_data.put('messaget', r1.messaget);
      obj_data.put('message3', r1.message3);
      obj_data.put('message4', r1.message4);
      obj_data.put('message5', r1.message5);
      obj_data.put('dtecreate', r1.dtecreate);
      obj_data.put('codcreate', r1.codcreate);
      obj_data.put('codlang', global_v_lang);

      IF  global_v_lang = '101' THEN
          obj_data.put('subject', r1.subjecte);
          obj_data.put('message', r1.messagee);
          v_tempmessage := r1.messagee;
      ELSIF global_v_lang = '102' THEN
          obj_data.put('subject', r1.subjectt);
          obj_data.put('message', r1.messaget);
          v_tempmessage := r1.messaget;
      ELSIF global_v_lang = '103' THEN
          obj_data.put('subject', r1.subject3);
          obj_data.put('message', r1.message3);
          v_tempmessage := r1.message3;
      ELSIF global_v_lang = '104' THEN
          obj_data.put('subject', r1.subject4);
          obj_data.put('message', r1.message4);
          v_tempmessage := r1.message4;
      ELSIF global_v_lang = '105' THEN
          obj_data.put('subject', r1.subject5);
          obj_data.put('message', r1.message5);
          v_tempmessage := r1.message5;
      ELSE
          obj_data.put('subject', r1.subjectt);
          obj_data.put('message', r1.messaget);
          v_tempmessage := r1.messaget;
      END IF;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_data (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--        json_str_output := 'test dump hrco3fe';
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

  procedure gen_dropdown (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;

  cursor c1 is
    select  *
    from    tlanguage
    where   namlang is not null
    and     namabb is not null   order by codlang;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('codlang', r1.codlang);
      obj_data.put('namlang', r1.namlang);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_dropdown (json_str_input in clob,json_str_output out clob) is
    obj_row json_object_t;
  begin
    --json_str_output := 'test dump hrco3fe';
    initial_value(json_str_input);
    --      check_index;
    if param_msg_error is null then
      gen_dropdown(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_dataedit (json_str_output out clob) is
  obj_data        json_object_t;
  begin
    begin
      select rowid as indexid
      , codcompy
      ,TO_CHAR(dtestrt, 'DD/MM/YYYY') as dtestrt
      ,TO_CHAR(dteend, 'DD/MM/YYYY') as dteend
      ,subjecte
      ,subjectt
      ,subject3
      ,subject4
      ,subject5
      ,messagee
      ,messaget
      ,message3
      ,message4
      ,message5
      into  p_indexid, p_codcompy ,p_dtestrt ,p_dteend ,p_subjecte ,p_subjectt ,p_subject3 ,p_subject4 ,p_subject5 ,p_messagee, p_messaget, p_message3 ,p_message4 ,p_message5
      from tmessage
      where codcompy = p_codcompy and dtestrt = p_dtestrt order by dtestrt;
    exception when no_data_found then
      param_msg_error := 'No Data Found';
    end;

    obj_data    := json_object_t();

    if param_msg_error is null then
--        dbms_lob.createtemporary(json_str_output, true);

        obj_data.put('coderror', '200');
        obj_data.put('indexid', p_indexid);
        obj_data.put('codcompy', p_codcompy);
        obj_data.put('dtestrt', p_dtestrt);
        obj_data.put('dteend', p_dteend);
        obj_data.put('subjectt', p_subjectt);
        obj_data.put('subjecte', p_subjecte);
        obj_data.put('subject3', p_subject3);
        obj_data.put('subject4', p_subject4);
        obj_data.put('subject5', p_subject5);
        obj_data.put('messaget', p_messaget);
        obj_data.put('messagee', p_messagee);
        obj_data.put('message3', p_message3);
        obj_data.put('message4', p_message4);
        obj_data.put('message5', p_message5);
        obj_data.put('codlang', global_v_lang);
        obj_data.put('flg', 'edit');
        IF  global_v_lang = '101' THEN
            obj_data.put('subject', p_subjecte);
            obj_data.put('message', p_messagee);
        ELSIF global_v_lang = '102' THEN
            obj_data.put('subject', p_subjectt);
            obj_data.put('message', p_messaget);
        ELSIF global_v_lang = '103' THEN
            obj_data.put('subject', p_subject3);
            obj_data.put('message', p_message3);
        ELSIF global_v_lang = '104' THEN
            obj_data.put('subject', p_subject4);
            obj_data.put('message', p_message4);
        ELSIF global_v_lang = '105' THEN
            obj_data.put('subject', p_subject5);
            obj_data.put('message', p_message5);
        ELSE
            obj_data.put('subject', p_subjectt);
            obj_data.put('message', p_messaget);
        END IF;

        json_str_output := obj_data.to_clob;
    else
--        dbms_lob.createtemporary(json_str_output, true);

        obj_data.put('coderror', '200');
        obj_data.put('indexid', '');
        obj_data.put('codcompy', '');
        obj_data.put('dtestrt', '');
        obj_data.put('dteend', '');
        obj_data.put('subjectt', '');
        obj_data.put('subjecte', '');
        obj_data.put('subject3', '');
        obj_data.put('subject4', '');
        obj_data.put('subject5', '');
        obj_data.put('messaget', '');
        obj_data.put('messagee', '');
        obj_data.put('message3', '');
        obj_data.put('message4', '');
        obj_data.put('message5', '');
        obj_data.put('codlang', '');
        obj_data.put('subject', '');
        obj_data.put('message', '');
        obj_data.put('flg', 'add');
        json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_dataedit (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
--    check_index2;
    if param_msg_error is null then
      gen_dataedit(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insupd_tmessage is
  begin
    begin
      insert into tmessage (codcompy ,dtestrt ,dteend ,subjecte ,subjectt ,subject3 ,subject4 ,subject5 ,
                            messagee ,messaget ,message3 ,message4 ,message5, codcreate,coduser)
      values (p_codcompy ,p_dtestrt ,p_dteend ,p_subjecte ,p_subjectt ,p_subject3 ,p_subject4 ,p_subject5 ,
              p_messagee,p_messaget,p_message3 ,p_message4 ,p_message5, global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tmessage
      set dteend = p_dteend,
          subjecte = p_subjecte,
          subjectt = p_subjectt,
          subject3 = p_subject3,
          subject4 = p_subject4,
          subject5 = p_subject5,
          messagee = p_messagee,
          messaget = p_messaget,
          message3 = p_message3,
          message4 = p_message4,
          message5 = p_message5,
          coduser = global_v_coduser
      where codcompy  = p_codcompy
      and   dtestrt   = p_dtestrt;
    end;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;
  end;
  --
  procedure delete_data as
  begin
    begin
      delete tmessage where rowid = p_rowid;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure edit_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_rowid           := hcm_util.get_string_t(param_json_row,'p_indexid');
        p_flg             := hcm_util.get_string_t(param_json_row,'p_flg');

        if(p_flg = 'delete') then
         delete_data;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure save_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      insupd_tmessage;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

END HRCO1AE;

/
