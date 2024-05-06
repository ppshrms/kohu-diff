--------------------------------------------------------
--  DDL for Package Body HRCO71E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO71E" as
-- last update: 20/04/2018 10:30:00
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    param_msg_error     := '';
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codmodule         := upper(hcm_util.get_string_t(json_obj,'p_codmodule'));
    p_numtopic          := hcm_util.get_string_t(json_obj,'p_numtopic');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_topic (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
  begin
    initial_value(json_str_input);
--    check_detail;
    if param_msg_error is null then
      gen_topic(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_topic;

  procedure gen_topic (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_child           json_object_t;
    obj_main            json_object_t;
    obj_detail          json_object_t;

    v_rcnt              number;
    v_rcnt_child        number;
    v_data_found        varchar2(1 char) := 'N';
    v_dteeffec          date;

    v_thelp             thelp%rowtype;
    v_descmodule        thelp.descmodulee%type;
    v_qtydoc            number;

    cursor c_thelpd is
      select t1.*, decode(global_v_lang, '101',namtopice,
                                         '102',namtopict,
                                         '103',namtopic3,
                                         '104',namtopic4,
                                         '105',namtopic5,
                                         namtopice) namtopic,
             decode(global_v_lang, '101',desctopice,
             '102',desctopict,
             '103',desctopic3,
             '104',desctopic4,
             '105',desctopic5,
             desctopice) desctopic
        from thelpd t1
       where codmodule = p_codmodule
    order by numtopic;

  begin
    begin
        select * 
          into v_thelp
          from thelp
         where codmodule = p_codmodule;    
    exception when no_data_found then
        v_thelp := null;
    end;

    if global_v_lang = '101' then
        v_descmodule := v_thelp.descmodulee;
    elsif global_v_lang = '102' then
        v_descmodule := v_thelp.descmodulet;
    elsif global_v_lang = '103' then
        v_descmodule := v_thelp.descmodule3;
    elsif global_v_lang = '104' then
        v_descmodule := v_thelp.descmodule4;
    elsif global_v_lang = '105' then
        v_descmodule := v_thelp.descmodule5;
    end if;

    obj_detail              := json_object_t();
    obj_detail.put('codmodule', p_codmodule);
    obj_detail.put('descmodule', v_descmodule);
    obj_detail.put('descmodulee', v_thelp.descmodulee);
    obj_detail.put('descmodulet', v_thelp.descmodulet);
    obj_detail.put('descmodule3', v_thelp.descmodule3);
    obj_detail.put('descmodule4', v_thelp.descmodule4);
    obj_detail.put('descmodule5', v_thelp.descmodule5);
    obj_detail.put('filedoc', v_thelp.filedoc);
    obj_detail.put('filemedia', v_thelp.filemedia);

    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    for r1 in c_thelpd loop
      v_rcnt_child          := 0;
      obj_data              := json_object_t();

      select count (subtopic)
        into v_qtydoc
        from thelpt
       where codmodule = p_codmodule
         and numtopic = r1.numtopic;

      obj_data.put('coderror', '200');
      obj_data.put('numtopic', r1.numtopic);
      obj_data.put('namtopic', r1.namtopic);
      obj_data.put('desctopic', r1.desctopic);
      obj_data.put('qtydoc',v_qtydoc);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt              := v_rcnt + 1;
    end loop;

    obj_main              := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_row);
    json_str_output := obj_main.to_clob;
  end gen_topic;

  procedure get_subtopic (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
  begin
    initial_value(json_str_input);
--    check_detail;
    if param_msg_error is null then
      gen_subtopic(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_subtopic;

  procedure gen_subtopic (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_child           json_object_t;
    obj_main            json_object_t;
    obj_detail          json_object_t;

    v_rcnt              number;
    v_rcnt_child        number;
    v_data_found        varchar2(1 char) := 'N';

    v_thelpd            thelpd%rowtype;
    v_namtopic          thelpd.namtopice%type;
    v_desctopic         thelpd.desctopice%type;

    cursor c_thelpt is
      select t1.*, decode(global_v_lang, '101',namsupe,
                                         '102',namsupt,
                                         '103',namsup3,
                                         '104',namsup4,
                                         '105',namsup5,
                                         namsupe) namsup,
             decode(global_v_lang, '101',desctopice,
             '102',desctopict,
             '103',desctopic3,
             '104',desctopic4,
             '105',desctopic5,
             desctopice) desctopic
        from thelpt t1
       where codmodule = p_codmodule
         and numtopic = p_numtopic
    order by subtopic;

  begin
    begin
        select * 
          into v_thelpd
          from thelpd
         where codmodule = p_codmodule
           and numtopic = p_numtopic;    
    exception when no_data_found then
        v_thelpd := null;
    end;

    if global_v_lang = '101' then
        v_namtopic  := v_thelpd.namtopice;
        v_desctopic := v_thelpd.desctopice;
    elsif global_v_lang = '102' then
        v_namtopic  := v_thelpd.namtopict;
        v_desctopic := v_thelpd.desctopict;
    elsif global_v_lang = '103' then
        v_namtopic := v_thelpd.namtopic3;
        v_desctopic := v_thelpd.desctopic3;
    elsif global_v_lang = '104' then
        v_namtopic := v_thelpd.namtopic4;
        v_desctopic := v_thelpd.desctopic4;
    elsif global_v_lang = '105' then
        v_namtopic := v_thelpd.namtopic5;
        v_desctopic := v_thelpd.desctopic5;
    end if;

    obj_detail              := json_object_t();
    obj_detail.put('codmodule', p_codmodule);
    obj_detail.put('numtopic', p_numtopic);
    obj_detail.put('namtopic', v_namtopic);
    obj_detail.put('namtopice', v_thelpd.namtopice);
    obj_detail.put('namtopict', v_thelpd.namtopict);
    obj_detail.put('namtopic3', v_thelpd.namtopic3);
    obj_detail.put('namtopic4', v_thelpd.namtopic4);
    obj_detail.put('namtopic5', v_thelpd.namtopic5);
    obj_detail.put('desctopic', v_desctopic);
    obj_detail.put('desctopice', v_thelpd.desctopice);
    obj_detail.put('desctopict', v_thelpd.desctopict);
    obj_detail.put('desctopic3', v_thelpd.desctopic3);
    obj_detail.put('desctopic4', v_thelpd.desctopic4);
    obj_detail.put('desctopic5', v_thelpd.desctopic5); 

    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    for r1 in c_thelpt loop
      v_rcnt_child          := 0;
      obj_data              := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('subtopic', r1.subtopic);
      obj_data.put('namsup', r1.namsup);
      obj_data.put('namsupe', r1.namsupe);
      obj_data.put('namsupt', r1.namsupt);
      obj_data.put('namsup3', r1.namsup3);
      obj_data.put('namsup4', r1.namsup4);
      obj_data.put('namsup5', r1.namsup5);
      obj_data.put('desctopic', r1.desctopic);
      obj_data.put('desctopice', r1.desctopice);
      obj_data.put('desctopict', r1.desctopict);
      obj_data.put('desctopic3', r1.desctopic3);
      obj_data.put('desctopic4', r1.desctopic4);
      obj_data.put('desctopic5', r1.desctopic5);
      obj_data.put('filedoc', r1.filedoc);
      obj_data.put('filemedia', r1.filemedia);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt              := v_rcnt + 1;
    end loop;

    obj_main              := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_row);
    json_str_output := obj_main.to_clob;
  end gen_subtopic;

  procedure post_save_subtopic (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
    v_json              json_object_t;

    obj_topic           json_object_t;
    topic_detail        json_object_t;
    topic_table         json_object_t;
    obj_subtopic        json_object_t;
    subtopic_detail     json_object_t;
    subtopic_table      json_object_t;

    v_codmodule         thelp.codmodule%type;
    v_descmodulee       thelp.descmodulee%type;
    v_descmodulet       thelp.descmodulet%type;
    v_descmodule3       thelp.descmodule3%type;
    v_descmodule4       thelp.descmodule4%type;
    v_descmodule5       thelp.descmodule5%type;

    v_numtopic          thelpd.numtopic%type;
    v_desctopice        thelpd.desctopice%type;
    v_desctopict        thelpd.desctopict%type;
    v_desctopic3        thelpd.desctopic3%type;
    v_desctopic4        thelpd.desctopic4%type;
    v_desctopic5        thelpd.desctopic5%type;
    v_namtopice         thelpd.namtopice%type;
    v_namtopict         thelpd.namtopict%type;
    v_namtopic3         thelpd.namtopic3%type;
    v_namtopic4         thelpd.namtopic4%type;
    v_namtopic5         thelpd.namtopic5%type;
    param_json_row      json_object_t;
    v_subtopic          thelpt.subtopic%type;
    v_subtopicOld       thelpt.subtopic%type;
    v_namsupe           thelpt.namsupe%type;
    v_namsupt           thelpt.namsupt%type;
    v_namsup3           thelpt.namsup3%type;
    v_namsup4           thelpt.namsup4%type;
    v_namsup5           thelpt.namsup5%type;

  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    obj_topic           := hcm_util.get_json_t(json_obj, 'param_topic');
    obj_subtopic        := hcm_util.get_json_t(json_obj, 'param_subtopic');

    topic_detail        := hcm_util.get_json_t(obj_topic, 'detail');
    topic_table         := hcm_util.get_json_t(obj_topic, 'table');
    v_codmodule         := hcm_util.get_string_t(topic_detail,'codmodule');
    p_descmodule        := hcm_util.get_string_t(topic_detail,'descmodule');
    v_descmodulee       := hcm_util.get_string_t(topic_detail,'descmodulee');
    v_descmodulet       := hcm_util.get_string_t(topic_detail,'descmodulet');
    v_descmodule3       := hcm_util.get_string_t(topic_detail,'descmodule3');
    v_descmodule4       := hcm_util.get_string_t(topic_detail,'descmodule4');
    v_descmodule5       := hcm_util.get_string_t(topic_detail,'descmodule5');
    p_filedoc           := hcm_util.get_string_t(topic_detail,'filedoc');
    p_filemedia         := hcm_util.get_string_t(topic_detail,'filemedia');

    subtopic_detail     := hcm_util.get_json_t(obj_subtopic, 'detail');
    subtopic_table      := hcm_util.get_json_t(obj_subtopic, 'table');
    v_numtopic          := hcm_util.get_string_t(subtopic_detail,'numtopic');
    v_desctopice        := hcm_util.get_string_t(subtopic_detail,'desctopice');
    v_desctopict        := hcm_util.get_string_t(subtopic_detail,'desctopict');
    v_desctopic3        := hcm_util.get_string_t(subtopic_detail,'desctopic3');
    v_desctopic4        := hcm_util.get_string_t(subtopic_detail,'desctopic4');
    v_desctopic5        := hcm_util.get_string_t(subtopic_detail,'desctopic5');
    v_namtopice         := hcm_util.get_string_t(subtopic_detail,'namtopice');
    v_namtopict         := hcm_util.get_string_t(subtopic_detail,'namtopict');
    v_namtopic3         := hcm_util.get_string_t(subtopic_detail,'namtopic3');
    v_namtopic4         := hcm_util.get_string_t(subtopic_detail,'namtopic4');
    v_namtopic5         := hcm_util.get_string_t(subtopic_detail,'namtopic5');
    check_save_subtopic;
    if param_msg_error is null then
        begin
            insert into thelp (codmodule,descmodulee,descmodulet,descmodule3,descmodule4,descmodule5,
                               filedoc,filemedia,
                               dtecreate,codcreate,dteupd,coduser)
            values (v_codmodule,v_descmodulee,v_descmodulet,v_descmodule3,v_descmodule4,v_descmodule5,
                    p_filedoc,p_filemedia,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);        
        exception when dup_val_on_index then
            update thelp
               set descmodulee = v_descmodulee,
                   descmodulet = v_descmodulet,
                   descmodule3 = v_descmodule3,
                   descmodule4 = v_descmodule4,
                   descmodule5 = descmodule5,
                   filedoc = p_filedoc,
                   filemedia = p_filemedia,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codmodule = v_codmodule;
        end;

        begin
            insert into thelpd (codmodule,numtopic,
                                namtopice,namtopict,namtopic3,namtopic4,namtopic5,
                                desctopice,desctopict,desctopic3,desctopic4,desctopic5,
                                dtecreate,codcreate,dteupd,coduser)
            values (v_codmodule,v_numtopic,
                    v_namtopice,v_namtopict,v_namtopic3,v_namtopic4,v_namtopic5,
                    v_desctopice,v_desctopict,v_desctopic3,v_desctopic4,v_desctopic5,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update thelpd
               set namtopice = v_namtopice,
                   namtopict = v_namtopict,
                   namtopic3 = v_namtopic3,
                   namtopic4 = v_namtopic4,
                   namtopic5 = v_namtopic5,
                   desctopice = v_desctopice,
                   desctopict = v_desctopict,
                   desctopic3 = v_desctopic3,
                   desctopic4 = v_desctopic4,
                   desctopic5 = v_desctopic5,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codmodule = v_codmodule
               and numtopic = v_numtopic;
        end;

        for i in 0..(subtopic_table.get_size - 1) loop
            param_json_row      := hcm_util.get_json_t(subtopic_table,to_char(i));
            v_flg               := hcm_util.get_string_t(param_json_row,'flg');
            v_subtopic          := hcm_util.get_string_t(param_json_row,'subtopic');
            v_subtopicOld       := hcm_util.get_string_t(param_json_row,'subtopicOld');
            v_desctopice        := hcm_util.get_string_t(param_json_row,'desctopice');
            v_desctopict        := hcm_util.get_string_t(param_json_row,'desctopict');
            v_desctopic3        := hcm_util.get_string_t(param_json_row,'desctopic3');
            v_desctopic4        := hcm_util.get_string_t(param_json_row,'desctopic4');
            v_desctopic5        := hcm_util.get_string_t(param_json_row,'desctopic5');
            p_filedoc           := hcm_util.get_string_t(param_json_row,'filedoc');
            p_filemedia         := hcm_util.get_string_t(param_json_row,'filemedia');
            v_namsupe           := hcm_util.get_string_t(param_json_row,'namsupe');
            v_namsupt           := hcm_util.get_string_t(param_json_row,'namsupt');
            v_namsup3           := hcm_util.get_string_t(param_json_row,'namsup3');
            v_namsup4           := hcm_util.get_string_t(param_json_row,'namsup4');
            v_namsup5           := hcm_util.get_string_t(param_json_row,'namsup5');
            if v_flg = 'delete' then
                delete thelpt
                 where codmodule = v_codmodule
                   and numtopic = v_numtopic
                   and subtopic = v_subtopicOld;
            elsif v_flg = 'add' then
                insert into thelpt (codmodule,numtopic,subtopic,
                                    namsupe,namsupt,namsup3,namsup4,namsup5,
                                    desctopice,desctopict,desctopic3,desctopic4,desctopic5,
                                    filedoc,filemedia,
                                    dtecreate,codcreate,dteupd,coduser)
                values (v_codmodule,v_numtopic,v_subtopic,
                        v_namsupe,v_namsupt,v_namsup3,v_namsup4,v_namsup5,
                        v_desctopice,v_desctopict,v_desctopic3,v_desctopic4,v_desctopic5,
                        p_filedoc,p_filemedia,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            elsif v_flg = 'edit' then
                update thelpt
                   set subtopic = v_subtopic,
                       namsupe = v_namsupe,
                       namsupt = v_namsupt,
                       namsup3 = v_namsup3,
                       namsup4 = v_namsup4,
                       namsup5 = v_namsup5,
                       desctopice = v_desctopice,
                       desctopict = v_desctopict,
                       desctopic3 = v_desctopic3,
                       desctopic4 = v_desctopic4,
                       desctopic5 = v_desctopic5,
                       filedoc = p_filedoc,
                       filemedia = p_filemedia,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codmodule = v_codmodule
                   and numtopic = v_numtopic
                   and subtopic = v_subtopicOld;
            end if;
        end loop;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(403,param_msg_error,global_v_lang);
  end post_save_subtopic;

  procedure post_save_topic (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
    v_json              json_object_t;

    obj_topic           json_object_t;
    topic_detail        json_object_t;
    topic_table         json_object_t;

    v_codmodule         thelp.codmodule%type;
    v_descmodulee       thelp.descmodulee%type;
    v_descmodulet       thelp.descmodulet%type;
    v_descmodule3       thelp.descmodule3%type;
    v_descmodule4       thelp.descmodule4%type;
    v_descmodule5       thelp.descmodule5%type;

    v_numtopic          thelpd.numtopic%type;
    param_json_row      json_object_t;
    v_flgDelete         boolean;

  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    topic_detail        := hcm_util.get_json_t(json_obj, 'param_detail');
    topic_table         := hcm_util.get_json_t(json_obj, 'param_table');
    v_codmodule         := hcm_util.get_string_t(topic_detail,'codmodule');
    v_descmodulee       := hcm_util.get_string_t(topic_detail,'descmodulee');
    v_descmodulet       := hcm_util.get_string_t(topic_detail,'descmodulet');
    v_descmodule3       := hcm_util.get_string_t(topic_detail,'descmodule3');
    v_descmodule4       := hcm_util.get_string_t(topic_detail,'descmodule4');
    v_descmodule5       := hcm_util.get_string_t(topic_detail,'descmodule5');
    p_filedoc           := hcm_util.get_string_t(topic_detail,'filedoc');
    p_filemedia         := hcm_util.get_string_t(topic_detail,'filemedia');

--    check_save_main;
    if param_msg_error is null then
        begin
            insert into thelp (codmodule,descmodulee,descmodulet,descmodule3,descmodule4,descmodule5,
                               filedoc,filemedia,
                               dtecreate,codcreate,dteupd,coduser)
            values (v_codmodule,v_descmodulee,v_descmodulet,v_descmodule3,v_descmodule4,v_descmodule5,
                    p_filedoc,p_filemedia,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);        
        exception when dup_val_on_index then
            update thelp
               set descmodulee = v_descmodulee,
                   descmodulet = v_descmodulet,
                   descmodule3 = v_descmodule3,
                   descmodule4 = v_descmodule4,
                   descmodule5 = v_descmodule5,
                   filedoc = p_filedoc,
                   filemedia = p_filemedia,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codmodule = v_codmodule;
        end;

        for i in 0..(topic_table.get_size - 1) loop
            param_json_row      := hcm_util.get_json_t(topic_table,to_char(i));
            v_flg               := hcm_util.get_string_t(param_json_row,'flg');
            v_numtopic          := hcm_util.get_string_t(param_json_row,'numtopic');
            if v_flg = 'delete' then
                delete thelpd
                 where codmodule = v_codmodule
                   and numtopic = v_numtopic;
                delete thelpt
                 where codmodule = v_codmodule
                   and numtopic = v_numtopic;

            end if;
        end loop;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(403,param_msg_error,global_v_lang);
  end post_save_topic;

  procedure check_save_subtopic is
  begin
    if p_descmodule is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    elsif p_filedoc is null and p_filemedia is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    end if;

  end check_save_subtopic;

end HRCO71E;

/
