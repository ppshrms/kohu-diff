--------------------------------------------------------
--  DDL for Package Body HRCO3DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO3DE" AS
procedure check_save is
  begin
    if p_desclabele is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'tapplscr');
--      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabele');
      return;
    end if;
    if length(p_desclabele) > 150 then
      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabele');
      return;
    end if;
    if length(p_desclabelt) > 150 then
      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabelt');
      return;
    end if;
    if length(p_desclabel3) > 150 then
      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabel3');
      return;
    end if;
    if length(p_desclabel4) > 150 then
      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabel4');
      return;
    end if;
    if length(p_desclabel5) > 150 then
      param_msg_error := get_error_msg_php('HR0910',global_v_lang,'desclabel5');
      return;
    end if;
  end;

 procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codapp is null and p_codproc is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codproc');
      return;
    end if;
    if p_codapp is not null and p_codproc is not null then
      p_codapp := null;
    end if;
    if p_codapp is not null then
      begin
        select codapp
        into p_codapp_query
        from   TAPPPROF
        where  codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codapp');
        return;
      end;
    end if;


--    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
--    if error_secur is not null then
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
--      return;
--    end if;

  end check_index;
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp');
    p_codproc           := hcm_util.get_string_t(json_obj,'p_codproc');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_desclabele        := hcm_util.get_string_t(json_obj,'p_desclabele');
    p_desclabelt        := hcm_util.get_string_t(json_obj,'p_desclabelt');
    p_desclabel3        := hcm_util.get_string_t(json_obj,'p_desclabel3');
    p_desclabel4        := hcm_util.get_string_t(json_obj,'p_desclabel4');
    p_desclabel5        := hcm_util.get_string_t(json_obj,'p_desclabel5');

    p_rowid           := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg           := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    temp_codapp varchar2(4000 char) := 'NULL';
    v_rcnt          number := 0;

--    cursor c1 is
--    select get_tappprof_name(codapp,'1', global_v_lang)  as codname,
--        codapp,
--        numseq,
--        desclabele,
--        desclabelt,
--        desclabel3,
--        desclabel4,
--        desclabel5
--        from tapplscr
--        where substr(codapp,1,6) in
--            (
--                select distinct substr(codapp,1,6)
--                from tappprof
--                where nvl(codproc,'!') = nvl(p_codproc , nvl(codproc, '!'))
--                and codapp = nvl(p_codapp, codapp)
--            )
--        order by codapp,numseq;
    cursor c1 is
      select  get_tappprof_name(pro.codapp,'1', global_v_lang) as codname,
              pro.codapp, scr.codapp as appscr, scr.numseq,
              scr.desclabele, scr.desclabelt, scr.desclabel3, scr.desclabel4, scr.desclabel5
      from    tappprof pro, tapplscr scr
      where   substr(pro.codapp,1,6)  = substr(scr.codapp,1,6)
      and     pro.codapp              = nvl(p_codapp, pro.codapp)
      and     nvl(pro.codproc,'!')    = nvl(p_codproc , nvl(pro.codproc, '!'))
      order by codapp,appscr,numseq;

     begin
        obj_row := json_object_t();
        obj_data := json_object_t();
        obj_result := json_object_t();
        for r1 in c1 loop
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
--            if r1.codapp not like '%' || temp_codapp || '%'  or temp_codapp = 'NULL' then
--                obj_data.put('codapp2', r1.codapp);
--                obj_data.put('codname', r1.codname);
--                temp_codapp := r1.codapp;
--            else
--                obj_data.put('codapp2', '');
--                obj_data.put('codname', '');
--            end if;
            obj_data.put('codapp2', r1.codapp);
            obj_data.put('codname', r1.codname);
            obj_data.put('codapp', r1.appscr);
            obj_data.put('numseq', r1.numseq);
            obj_data.put('desclabele', r1.desclabele);
            obj_data.put('desclabelt', r1.desclabelt);
            obj_data.put('desclabel3', r1.desclabel3);
            obj_data.put('desclabel4', r1.desclabel4);
            obj_data.put('desclabel5', r1.desclabel5);

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

procedure update_data is
  begin
    begin
      update tapplscr
      set desclabele = p_desclabele ,
          desclabelt = p_desclabelt ,
          desclabel3 = p_desclabel3 ,
          desclabel4 = p_desclabel4 ,
          desclabel5 = p_desclabel5 ,
          dteupd  = sysdate ,
          coduser = global_v_coduser,
          typscr  = 'Y'
      where numseq = p_numseq
      and codapp = p_codapp;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;


procedure save_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_codapp          := hcm_util.get_string_t(param_json_row,'codapp');
        p_numseq          := hcm_util.get_string_t(param_json_row,'numseq');
        p_desclabele      := hcm_util.get_string_t(param_json_row,'desclabel1');
        p_desclabelt      := hcm_util.get_string_t(param_json_row,'desclabel2');
        p_desclabel3      := hcm_util.get_string_t(param_json_row,'desclabel3');
        p_desclabel4      := hcm_util.get_string_t(param_json_row,'desclabel4');
        p_desclabel5      := hcm_util.get_string_t(param_json_row,'desclabel5');
        p_flg             := hcm_util.get_string_t(param_json_row,'flg');

        check_save;
        if(p_flg = 'edit') then
         update_data;
        end if;
--        if(p_flg = 'edit') then
--         update_temproute;
--        end if;
--        if(p_flg = 'delete') then
--         delete_temproute;
--        end if;
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
    procedure gen_header_info(json_str_output out clob)as
    obj_data    json_object_t;
    obj_row     json_object_t;
    data_row    json_object_t;
    v_rcnt      number;
    v_desclabel tcodlang.descode%type;

    cursor c_tlanguage is
      select codlang2
        from tlanguage
       where codlang2 is not null
    order by codlang;
  begin
    obj_row   := json_object_t();
    data_row  := json_object_t();
    v_rcnt := 0;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codapp', p_codapp||' - ' ||get_tappprof_name(p_codapp,1,global_v_lang));

    for r1 in c_tlanguage loop
      begin
        select decode(global_v_lang, '101', descode,
                                     '102', descodt,
                                     '103', descod3,
                                     '104', descod4,
                                     '105', descod5) desclabel
          into v_desclabel
          from tcodlang
          where codcodec = r1.codlang2;
      exception when no_data_found then
        v_desclabel := '';
      end;
      data_row.put('desclabel'||(v_rcnt+1),v_desclabel);
      v_rcnt := v_rcnt + 1;
    end loop;
    obj_data.put('language',data_row);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_header_info;

  procedure get_header_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_header_info(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRCO3DE;

/
