--------------------------------------------------------
--  DDL for Package Body HCM_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_HELP" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codmodule         := SUBSTR(upper(hcm_util.get_string_t(json_obj,'p_codmodule')), -2,2);
    p_search            := upper(hcm_util.get_string_t(json_obj,'p_search'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_main        json_object_t;
    obj_row         json_object_t;
    obj_mainbox     json_object_t;
    obj_module      json_object_t;
    row_mainbox     number := 0;
    cursor c_mainbox is
        select thelp.* , decode(global_v_lang, '101',descmodulee,
                                         '102',descmodulet,
                                         '103',descmodule3,
                                         '104',descmodule4,
                                         '105',descmodule5,
                                         descmodulee) descmodule
          from thelp
         where codmodule in ('OV','ST','DB')
      order by DECODE (codmodule,'OV',1,'ST',2, 'DB',3) ;

    cursor c_module is
        select thelp.* , decode(global_v_lang, '101',descmodulee,
                                         '102',descmodulet,
                                         '103',descmodule3,
                                         '104',descmodule4,
                                         '105',descmodule5,
                                         descmodulee) descmodule
          from thelp
         where codmodule not in ('OV','ST','DB')
      order by DECODE (codmodule,'RP',1,'RC',2, 'PM',3,'AL',4,'PY',5,'BF',6,'AP',7,'TR',8,'ES',9,'MS',10,'EL',11,'JO',12,'SC',13,'CO',14,'SA',15);
  begin
    obj_mainbox := json_object_t();
    for r1 in c_mainbox loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');

        if r1.codmodule = 'OV' then
            obj_data.put('icon','rocket');
        elsif r1.codmodule = 'ST' then
            obj_data.put('icon','desktop');
        elsif r1.codmodule = 'DB' then
            obj_data.put('icon','tachometer-alt');
        end if;

        obj_data.put('codmodule',r1.codmodule);
        obj_data.put('desc_codmodule',get_tlistval_name('MODULED',r1.codmodule,global_v_lang));
        obj_data.put('descmodule', r1.descmodule);
        obj_data.put('filedoc',r1.filedoc);
        obj_data.put('filemedia',r1.filemedia);
        if r1.filedoc is null then
            v_path_filename := '';
        else
            v_path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r1.filedoc;
        end if;
        if r1.filemedia is null then
            v_path_vdoname := '';
        else
            v_path_vdoname := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r1.filemedia;
        end if;
        obj_data.put('path_filename',v_path_filename);
        obj_data.put('path_vdoname',v_path_vdoname);
        obj_mainbox.put(to_char(row_mainbox),obj_data);
        row_mainbox := row_mainbox + 1;
    end loop;

    row_mainbox     := 0;
    obj_module      := json_object_t();
    for r2 in c_module loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codmodule',r2.codmodule);
        obj_data.put('desc_codmodule',get_tlistval_name('MODULED',r2.codmodule,global_v_lang));
        obj_data.put('descmodule', r2.descmodule);
        obj_data.put('filedoc',r2.filedoc);
        obj_data.put('filemedia',r2.filemedia);
        if r2.filedoc is null then
            v_path_filename := '';
        else
            v_path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filedoc;
        end if;
        if r2.filemedia is null then
            v_path_vdoname := '';
        else
            v_path_vdoname := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filemedia;
        end if;
        obj_data.put('path_filename',v_path_filename);
        obj_data.put('path_vdoname',v_path_vdoname);
        obj_module.put(to_char(row_mainbox),obj_data);
        row_mainbox := row_mainbox + 1;
    end loop;

    obj_main := json_object_t();
    obj_main.put('coderror','200');
    obj_main.put('mainBox',obj_mainbox);
    obj_main.put('module',obj_module);

    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_help_module(json_str_output out clob)as
    obj_data            json_object_t;
    obj_main            json_object_t;
    obj_row             json_object_t;
    obj_topic           json_object_t;
    obj_subtopic        json_object_t;
    obj_subtopic_data   json_object_t;
    row_topic           number := 0;
    row_subtopic        number := 0;
    v_numtopic          thelpd.numtopic%type;
    v_filedoc_module    thelp.filedoc%type;
    cursor c_topic is
        select thelpd.* , decode(global_v_lang, '101',namtopice,
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
          from thelpd
         where codmodule = p_codmodule
      order by numtopic ;
    cursor c_subtopic is
        select thelpt.* , decode(global_v_lang, '101',namsupe,
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
          from thelpt
         where codmodule = p_codmodule
           and numtopic = v_numtopic
      order by subtopic;
  begin
    obj_topic := json_object_t();
    for r1 in c_topic loop
        v_numtopic := r1.numtopic;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('namtopic',r1.namtopic);
        obj_data.put('desctopic',r1.desctopic);

        obj_subtopic := json_object_t();
        row_subtopic    := 0;
        for r2 in c_subtopic loop
            obj_subtopic_data := json_object_t();
            obj_subtopic_data.put('coderror','200');
            obj_subtopic_data.put('namsup',r2.namsup);
            obj_subtopic_data.put('desctopic',r2.desctopic);
            obj_subtopic_data.put('filedoc',r2.filedoc);
            obj_subtopic_data.put('filemedia',r2.filemedia);
            if r2.filedoc is null then
                v_path_filename := '';
            else
                v_path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filedoc;
            end if;
            if r2.filemedia is null then
                v_path_vdoname := '';
            else
                v_path_vdoname := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filemedia;
            end if;
            obj_subtopic_data.put('path_filename',v_path_filename);
            obj_subtopic_data.put('path_vdoname',v_path_vdoname);  
            obj_subtopic.put(to_char(row_subtopic),obj_subtopic_data);
            row_subtopic := row_subtopic + 1;
        end loop;        
        obj_data.put('subtopic', obj_subtopic);
        obj_topic.put(to_char(row_topic),obj_data);
        row_topic := row_topic + 1;
    end loop;

    begin
      select get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||filedoc
        into v_filedoc_module
        from thelp
       where codmodule = p_codmodule;
    exception when no_data_found then
      v_filedoc_module := null;
    end;

    obj_main := json_object_t();
    obj_main.put('coderror','200');
    obj_main.put('codmodule',p_codmodule);
    obj_main.put('desc_codmodule',get_tlistval_name('MODULED',p_codmodule,global_v_lang));
    obj_main.put('filedoc_module',v_filedoc_module);
    obj_main.put('topic',obj_topic);

    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_help_module;

  procedure get_help_module(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_help_module(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;  


  procedure gen_help_search(json_str_output out clob)as
    obj_data            json_object_t;
    obj_module          json_object_t;
    obj_subtopic_data   json_object_t;
    obj_subtopic        json_object_t;
    row_mainbox         number := 0;
    row_subtopic        number := 0;
    v_codmodule         thelpt.codmodule%type;

    cursor c_module is
        select distinct codmodule
          from thelpt
         where upper(namsupe) like '%'||upper(p_search)||'%'
            or upper(namsupt) like '%'||upper(p_search)||'%'
            or upper(namsup3) like '%'||upper(p_search)||'%'
            or upper(namsup4) like '%'||upper(p_search)||'%'
            or upper(namsup5) like '%'||upper(p_search)||'%'
            or upper(desctopice) like '%'||upper(p_search)||'%'
            or upper(desctopict) like '%'||upper(p_search)||'%'
            or upper(desctopic3) like '%'||upper(p_search)||'%'
            or upper(desctopic4) like '%'||upper(p_search)||'%'
            or upper(desctopic5) like '%'||upper(p_search)||'%'
      order by decode (codmodule,'RP',1,'RC',2, 'PM',3,'AL',4,'PY',5,'BF',6,'AP',7,'TR',8,'ES',9,'MS',10,'EL',11,'JO',12,'SC',13,'CO',14,'SA',15);

    cursor c_subtopic is
        select thelpt.* , decode(global_v_lang, '101',namsupe,
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
          from thelpt
         where codmodule = v_codmodule
           and (upper(namsupe) like '%'||upper(p_search)||'%'
                or upper(namsupt) like '%'||upper(p_search)||'%'
                or upper(namsup3) like '%'||upper(p_search)||'%'
                or upper(namsup4) like '%'||upper(p_search)||'%'
                or upper(namsup5) like '%'||upper(p_search)||'%'
                or upper(desctopice) like '%'||upper(p_search)||'%'
                or upper(desctopict) like '%'||upper(p_search)||'%'
                or upper(desctopic3) like '%'||upper(p_search)||'%'
                or upper(desctopic4) like '%'||upper(p_search)||'%'
                or upper(desctopic5) like '%'||upper(p_search)||'%')
      order by subtopic;
  begin
    obj_module := json_object_t();
    for r1 in c_module loop
        v_codmodule := r1.codmodule;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codmodule',r1.codmodule);
        obj_data.put('desc_codmodule',get_tlistval_name('MODULED',r1.codmodule,global_v_lang));

        obj_subtopic := json_object_t();
        row_subtopic    := 0;
        for r2 in c_subtopic loop
            obj_subtopic_data := json_object_t();
            obj_subtopic_data.put('coderror','200');
            obj_subtopic_data.put('codmodule',r1.codmodule);
            obj_subtopic_data.put('desc_codmodule',get_tlistval_name('MODULED',r1.codmodule,global_v_lang));
            obj_subtopic_data.put('namsup',r2.namsup);
            obj_subtopic_data.put('desctopic',r2.desctopic);
            obj_subtopic_data.put('filedoc',r2.filedoc);
            obj_subtopic_data.put('filemedia',r2.filemedia);
            if r2.filedoc is null then
                v_path_filename := '';
            else
                v_path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filedoc;
            end if;
            if r2.filemedia is null then
                v_path_vdoname := '';
            else
                v_path_vdoname := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filemedia;
            end if;
            obj_subtopic_data.put('path_filename',v_path_filename);
            obj_subtopic_data.put('path_vdoname',v_path_vdoname);  
            obj_subtopic.put(to_char(row_subtopic),obj_subtopic_data);
            row_subtopic := row_subtopic + 1;
        end loop;
        obj_data.put('subtopic',obj_subtopic);

        obj_module.put(to_char(row_mainbox),obj_data);
        row_mainbox := row_mainbox + 1;
    end loop;
    json_str_output := obj_module.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_help_search;

  procedure get_help_search(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_help_search(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_help_module_search(json_str_output out clob)as
    obj_subtopic_data   json_object_t;
    obj_subtopic        json_object_t;
    row_subtopic        number := 0;

    cursor c_subtopic is
        select thelpt.* , decode(global_v_lang, '101',namsupe,
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
          from thelpt
         where codmodule = p_codmodule
           and (upper(namsupe) like '%'||upper(p_search)||'%'
                or upper(namsupt) like '%'||upper(p_search)||'%'
                or upper(namsup3) like '%'||upper(p_search)||'%'
                or upper(namsup4) like '%'||upper(p_search)||'%'
                or upper(namsup5) like '%'||upper(p_search)||'%'
                or upper(desctopice) like '%'||upper(p_search)||'%'
                or upper(desctopict) like '%'||upper(p_search)||'%'
                or upper(desctopic3) like '%'||upper(p_search)||'%'
                or upper(desctopic4) like '%'||upper(p_search)||'%'
                or upper(desctopic5) like '%'||upper(p_search)||'%')
      order by subtopic;
  begin
    obj_subtopic := json_object_t();
    row_subtopic    := 0;
    for r2 in c_subtopic loop
        obj_subtopic_data := json_object_t();
        obj_subtopic_data.put('coderror','200');
        obj_subtopic_data.put('namsup',r2.namsup);
        obj_subtopic_data.put('desctopic',r2.desctopic);
        obj_subtopic_data.put('filedoc',r2.filedoc);
        obj_subtopic_data.put('filemedia',r2.filemedia);
        if r2.filedoc is null then
            v_path_filename := '';
        else
            v_path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filedoc;
        end if;
        if r2.filemedia is null then
            v_path_vdoname := '';
        else
            v_path_vdoname := get_tsetup_value('PATHDOC')||get_tfolderd('HRCO71E')||'/'||r2.filemedia;
        end if;
        obj_subtopic_data.put('path_filename', v_path_filename);
        obj_subtopic_data.put('path_vdoname', v_path_vdoname);  
        obj_subtopic.put(to_char(row_subtopic),obj_subtopic_data);
        row_subtopic := row_subtopic + 1;
    end loop;

    json_str_output := obj_subtopic.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_help_module_search;

  procedure get_help_module_search(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_help_module_search(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HCM_HELP;

/
