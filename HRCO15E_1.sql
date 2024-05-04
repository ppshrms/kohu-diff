--------------------------------------------------------
--  DDL for Package Body HRCO15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO15E" AS

  procedure check_index is
    error_secur VARCHAR2(4000 CHAR);
    begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;
    if p_codcompy is not null then
      begin
        select codcompy
        into p_codcompy
        from tcompny
        where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcompy');
        return;
      end;
    end if;

    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;
  end;

  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
    v_chk varchar2(1 char);--User37 #5254 Final Test Phase 1 V11 15/03/2021 
  begin
    if p_codplcy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codplcy');
      return;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
    --<<User37 #5254 Final Test Phase 1 V11 15/03/2021 
    begin
        select 'X'
          into v_chk
          from tcompplcy
         where codcompy = p_codcompy
           and codplcy = p_codplcy
           and dteeffec = p_dteeffec;
    exception when no_data_found then
        null;
    end;
    if v_chk = 'X' then
      param_msg_error := get_error_msg_php('HR1503',global_v_lang);
      return;
    end if;
    -->>User37 #5254 Final Test Phase 1 V11 15/03/2021 
    if p_filename is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'filename');
      return;
    end if;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');

    p_rowid             := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
  cursor c1 is
    select rowid as indexid, codcompy, codplcy, dteeffec, filename
--      , cast(dtecreate as date) as dtecreate, cast(codcreate as date) as codcreate, cast(dteupd as date) as dteupd
      , dtecreate, codcreate, dteupd
      , coduser
    from tcompplcy
    where codcompy  = p_codcompy
    order by dteeffec desc,codplcy;--User37 #5254 Final Test Phase 1 V11 15/03/2021 codplcy,dteeffec;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('indexid', r1.indexid);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('codplcy', r1.codplcy);
      obj_data.put('desc_codplcy',get_tcodec_name('TCODPLCY',r1.codplcy,global_v_lang));
      obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('filename', r1.filename);
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
  procedure get_data(json_str_input in clob, json_str_output out clob) AS
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

  procedure gen_folder (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
  cursor c1 is
    Select folder as select_fold From tfolderd where codapp = 'HRCO15E';
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('folder', r1.select_fold);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if param_msg_error is null then
      json_str_output:= obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_folder(json_str_input in clob, json_str_output out clob) AS
  obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_folder(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tcompplcy is
  begin
    begin
      insert into tcompplcy (codcompy, codplcy, dteeffec, filename, coduser, dtecreate,CODCREATE)
      values(p_codcompy, p_codplcy, p_dteeffec, p_filename, global_v_coduser, CURRENT_DATE, global_v_coduser);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure update_tcompplcy is
  begin
    begin
      update  tcompplcy
      set     filename    = p_filename,
              coduser     = global_v_coduser
      where   rowid       = p_rowid;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure delete_tcompplcy is
  begin
    begin
      delete tcompplcy where rowid = p_rowid;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure edit_tcompplcy(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    p_json          json_object_t;
    p_json_file     json_object_t;
    type_file       varchar(10 char) := '';
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_rowid           := hcm_util.get_string_t(param_json_row,'indexid');
        p_flg             := hcm_util.get_string_t(param_json_row,'flg');
        p_codplcy         := hcm_util.get_string_t(param_json_row,'codplcy');
        p_dteeffec        := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
        p_filename         := hcm_util.get_string_t(param_json_row,'filename');
        if p_flg = 'add' then
          check_save;
          if param_msg_error is null then
            save_tcompplcy;
          end if;
        elsif p_flg = 'edit' then
          update_tcompplcy;
        end if;
        if(p_flg = 'delete') then
         delete_tcompplcy;
        end if;
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
END HRCO15E;

/
