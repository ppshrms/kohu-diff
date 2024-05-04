--------------------------------------------------------
--  DDL for Package Body HRCO1BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO1BE" AS
  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      error_secur   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if error_secur is not null then
        param_msg_error := error_secur;
        return;
      end if;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;

    if p_subjecte is null and p_subjectt is null and p_subject3 is null and p_subject4 is null and p_subject5 is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'subject');
      return;
    end if;

    if p_codappr is not null and p_dteappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteappr');
      return;
    end if;

    if p_codappr is null and p_dteappr is not null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codappr');
      return;
    end if;

    if p_codappr is not null then
      begin
        select codempid
        into p_codappr
        from   temploy1
        where  codempid = p_codappr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codappr');
        return;
      end;
    end if;
  end;

  procedure check_index2 is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
  end;

  procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
    if p_codcomp is not null then
      begin
        select codcomp
        into p_codcomp
        from   tcenter
        where  codcomp = p_codcomp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcomp');
        return;
      end;
    end if;

    error_secur   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;

  end check_index;

  procedure check_detail is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_numseq is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;

    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if error_secur is not null then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
      return;
    end if;

  end check_detail;

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp          := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteeffec         := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'DD/MM/YYYY');
    p_numseq           := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_typemsg          := hcm_util.get_string_t(json_obj,'p_typemsg');

    p_dtestrt          := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'DD/MM/YYYY');
    p_dteend           := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'DD/MM/YYYY');
    p_subjecte         := hcm_util.get_string_t(json_obj,'p_subjecte');
    p_subjectt         := hcm_util.get_string_t(json_obj,'p_subjectt');
    p_subject3         := hcm_util.get_string_t(json_obj,'p_subject3');
    p_subject4         := hcm_util.get_string_t(json_obj,'p_subject4');
    p_subject5         := hcm_util.get_string_t(json_obj,'p_subject5');
    p_messagee         := hcm_util.get_clob_t(json_obj,'p_messagee');
    p_messaget         := hcm_util.get_clob_t(json_obj,'p_messaget');
    p_message3         := hcm_util.get_clob_t(json_obj,'p_message3');
    p_message4         := hcm_util.get_clob_t(json_obj,'p_message4');
    p_message5         := hcm_util.get_clob_t(json_obj,'p_message5');
    p_filename         := hcm_util.get_string_t(json_obj,'p_filename');
    p_namimgnews       := hcm_util.get_string_t(json_obj,'p_namimgnews');
    p_url              := hcm_util.get_string_t(json_obj,'p_url');
    p_codappr          := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr          := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');

    p_rowid           := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg             := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure insert_tannounce is
    v_numseq number;
  begin
    begin
      insert into tannounce (codcomp,numseq,dteeffec,subjecte,subjectt,subject3,subject4,subject5,
                             messagee,messaget,message3,message4,message5,filename,url,
                             namimgnews,
                             codappr,dteappr,codcreate,coduser,typemsg)
                    values  (p_codcomp,p_numseq,p_dteeffec,p_subjecte,p_subjectt,p_subject3,p_subject4,p_subject5,
                             p_messagee,p_messaget,p_message3,p_message4,p_message5,p_filename,p_url,
                             p_namimgnews,
                             p_codappr,p_dteappr,global_v_coduser,global_v_coduser,p_typemsg);
    exception when dup_val_on_index then
      update tannounce
      set url = p_url
        ,subjecte = p_subjecte
        ,subjectt = p_subjectt
        ,subject3 = p_subject3
        ,subject4 = p_subject4
        ,subject5 = p_subject5
        ,messagee = p_messagee
        ,messaget = p_messaget
        ,message3 = p_message3
        ,message4 = p_message4
        ,message5 = p_message5
        ,filename = p_filename
        ,namimgnews = p_namimgnews
        ,codappr = p_codappr
        ,dteappr = p_dteappr
        ,coduser = global_v_coduser
      where numseq  = p_numseq
      and codcomp   = p_codcomp
      and dteeffec  = p_dteeffec
      and typemsg   = p_typemsg;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end;
  --
  procedure save_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      insert_tannounce;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure gen_detail (json_str_output out clob) is
    obj_data          json_object_t;
    v_default_lang    tlanguage.namabb%type;
  begin
    begin
      select  numseq,codcomp,subjecte,subjectt,subject3,subject4,subject5,
              messagee,messaget,message3,message4,message5,codappr,dteappr,filename,
              namimgnews,url
      into    p_numseq,p_codcomp,p_subjecte,p_subjectt,p_subject3,p_subject4,p_subject5,
              p_messagee,p_messaget,p_message3,p_message4,p_message5,p_codappr,p_dteappr,p_filename,
              p_namimgnews,p_url
      from    tannounce
      where   codcomp   = p_codcomp
      and     dteeffec  = p_dteeffec
      and     typemsg   = p_typemsg
      and     numseq    = p_numseq;
    exception when no_data_found then
      param_msg_error := 'No Data Found';
    end;

    obj_data    := json_object_t();

    if param_msg_error is null then
--        dbms_lob.createtemporary(json_str_output, true);

        obj_data.put('coderror','200');
        obj_data.put('codcomp', p_codcomp);
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_data.put('numseq', p_numseq);
        obj_data.put('typemsg', p_typemsg);
        obj_data.put('subjecte', p_subjecte);
        obj_data.put('subjectt', p_subjectt);
        obj_data.put('subject3', p_subject3);
        obj_data.put('subject4', p_subject4);
        obj_data.put('subject5', p_subject5);
        if p_typemsg = 'A' then
          obj_data.put('message', '');
          obj_data.put('messagee', p_messagee);
          obj_data.put('messaget', p_messaget);
          obj_data.put('message3', p_message3);
          obj_data.put('message4', p_message4);
          obj_data.put('message5', p_message5);
          obj_data.put('filename', p_filename);
        else
          obj_data.put('message', '');
          obj_data.put('messagee', p_messagee);
          obj_data.put('messaget', p_messaget);
          obj_data.put('message3', p_message3);
          obj_data.put('message4', p_message4);
          obj_data.put('message5', p_message5);
          obj_data.put('filename', p_namimgnews);
        end if;
        obj_data.put('url', p_url);
        obj_data.put('codappr', p_codappr);
        obj_data.put('dteappr', to_char(p_dteappr,'dd/mm/yyyy'));
        obj_data.put('codlang', global_v_lang);
        obj_data.put('flg', 'edit');
        if  global_v_lang = '101' then
            obj_data.put('subject', p_subjecte);
            obj_data.put('message', p_messagee);
        elsif global_v_lang = '102' then
            obj_data.put('subject', p_subjectt);
            obj_data.put('message', p_messaget);
        elsif global_v_lang = '103' then
            obj_data.put('subject', p_subject3);
            obj_data.put('message', p_message3);
        elsif global_v_lang = '104' then
            obj_data.put('subject', p_subject4);
            obj_data.put('message', p_message4);
        elsif global_v_lang = '105' then
            obj_data.put('subject', p_subject5);
            obj_data.put('message', p_message5);
        else
            obj_data.put('subject', p_subjectt);
            obj_data.put('message', p_messaget);
        end if;
        json_str_output := obj_data.to_clob;
    else
--        dbms_lob.createtemporary(json_str_output, true);
        begin
          select  codlang
          into    v_default_lang
          from    tlanguage
          where   codlang   = global_v_lang;
        exception when no_data_found then
          v_default_lang    := '102';
        end;
        obj_data.put('coderror','200');
        obj_data.put('codcomp', p_codcomp);
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_data.put('numseq', p_numseq);
        obj_data.put('typemsg', p_typemsg);
        obj_data.put('subjecte', '');
        obj_data.put('subjectt', '');
        obj_data.put('subject3', '');
        obj_data.put('subject4', '');
        obj_data.put('subject5', '');
        obj_data.put('message', '');
        obj_data.put('messagee', '');
        obj_data.put('messaget', '');
        obj_data.put('message3', '');
        obj_data.put('message4', '');
        obj_data.put('message5', '');
        obj_data.put('codappr', '');
        obj_data.put('dteappr', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('codappr', global_v_codempid);
        obj_data.put('codlang', v_default_lang);
        obj_data.put('subject', '');
        obj_data.put('url', '');
        obj_data.put('flg', 'add');
        json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_typemsg_a     varchar2(200);
    v_typemsg_n     varchar2(200);

    cursor C2 is
        select numseq as numseq
              ,dteeffec
              ,typemsg
              ,get_temploy_name(codappr,global_v_lang) as desc_codappr
              ,subjecte as subjecte
              ,subjectt as subjectt
              ,subject3 as subject3
              ,subject4 as subject4
              ,subject5 as subject5
              ,messagee as messagee
              ,messaget as messaget
              ,message3 as message3
              ,message4 as message4
              ,message5 as message5
              ,codappr as codappr
              ,TO_CHAR(dteappr, 'DD/MM/YYYY') as dteappr
         from tannounce
        where codcomp  = p_codcomp
          and dteeffec between p_dtestrt and p_dteend
     order by dteeffec desc,numseq,typemsg;

     begin
        obj_row := json_object_t();
        obj_data := json_object_t();
        obj_result := json_object_t();

        for r1 in C2 loop
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();

            v_typemsg_a   := get_label_name('HRCO1BEC2',global_v_lang,990);
            v_typemsg_n   := get_label_name('HRCO1BEC2',global_v_lang,995);
            obj_data.put('codcomp', p_codcomp);
            obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
            obj_data.put('typemsg',r1.typemsg);
            obj_data.put('typemsg_desc', case when r1.typemsg = 'A' then v_typemsg_a
                                              when r1.typemsg = 'N' then v_typemsg_n
                                         end);
            obj_data.put('numseq', r1.numseq);
            obj_data.put('desc_codappr', r1.desc_codappr);
            obj_data.put('subjecte', r1.subjecte);
            obj_data.put('subjectt', r1.subjectt);
            obj_data.put('subject3', r1.subject3);
            obj_data.put('subject4', r1.subject4);
            obj_data.put('subject5', r1.subject5);
            obj_data.put('codappr', r1.codappr);
            obj_data.put('dteappr', r1.dteappr);
            obj_data.put('codlang', global_v_lang);
            if  global_v_lang = '101' then
              obj_data.put('subject', r1.subjecte);
            elsif global_v_lang = '102' then
              obj_data.put('subject', r1.subjectt);
            elsif global_v_lang = '103' then
              obj_data.put('subject', r1.subject3);
            elsif global_v_lang = '104' then
              obj_data.put('subject', r1.subject4);
            elsif global_v_lang = '105' then
              obj_data.put('subject', r1.subject5);
            else
              obj_data.put('subject', r1.subjectt);
            end if;
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
  end gen_data;
  procedure get_data (json_str_input in clob, json_str_output out clob) is
      obj_row json_object_t;
  begin
      --json_str_output := 'test dump hrco3fe';
      initial_value(json_str_input);
----      check_index;
      if param_msg_error is null then
        gen_data(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

   procedure gen_dropdown (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
        select *
        from tlanguage
        order by codlang;
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
  end gen_dropdown;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
      obj_row json_object_t;
  begin
      initial_value(json_str_input);
      check_index2;
      if param_msg_error is null then
        gen_detail(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;   
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure get_dropdown (json_str_input in clob,json_str_output out clob) is
      obj_row json_object_t;
  begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_dropdown(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_dropdown;

  procedure delete_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_codcomp          :=  hcm_util.get_string_t(param_json_row,'codcomp');
        p_dteeffec         :=  to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
        p_numseq           :=  hcm_util.get_string_t(param_json_row,'numseq');
        p_typemsg          :=  hcm_util.get_string_t(param_json_row,'typemsg');
        begin
          delete  tannounce
          where   codcomp   = p_codcomp
          and     dteeffec  = p_dteeffec
          and     numseq    = p_numseq
          and     typemsg   = p_typemsg;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          rollback;
        end;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
END HRCO1BE;

/
