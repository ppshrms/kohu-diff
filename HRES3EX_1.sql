--------------------------------------------------------
--  DDL for Package Body HRES3EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES3EX" is
-- last update: 15/04/2019 15:38

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

  end initial_value;
  --

  procedure get_dteeffec(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dteeffec(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

 procedure gen_dteeffec(json_str_output out clob) is
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_dteeffec      tcompplcy.dteeffec%type;

  begin
       begin
        select codempid
          into v_codempid
          from tusrprof
         where coduser = global_v_coduser;
         exception when no_data_found then
            v_codempid := null;
        end;
        ------------
        begin
          select hcm_util.get_codcomp_level(codcomp, '1')
            into v_codcompy
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_codcompy := null;
        end;
        -----------
         begin
          select nvl(min(dteeffec),trunc(sysdate))
            into v_dteeffec
            from tcompplcy
           where codcompy = v_codcompy;
        exception when no_data_found then
           v_dteeffec := null;
        end;
        -----------


      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtest',to_char(v_dteeffec,'dd/mm/yyyy'));
      json_str_output :=   obj_data.to_clob;

  end;

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
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_ocodempid     varchar2(200 char);
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_pathdoc       varchar(5000 char);
    --<<User37 #5254 Final Test Phase 1 V11 15/03/2021
    v_filename      varchar(5000 char);
    cursor c1 is
      select dteeffec,codplcy from(
      select max(dteeffec) dteeffec,max(codplcy) codplcy
        from tcompplcy
       where codcompy = b_index_codcomp
         and trunc(dteeffec) between  trunc(b_index_dtest) and trunc(b_index_dteen)
       group by codplcy)
    --   order by dteeffec desc,codplcy;
       order by codplcy;
    /*cursor c1 is
      select dteeffec,codplcy,filename
        from tcompplcy
       where codcompy = b_index_codcomp
         and trunc(dteeffec) between  trunc(b_index_dtest) and trunc(b_index_dteen)
      order by dteeffec desc,codplcy;*/
    -->>User37 #5254 Final Test Phase 1 V11 15/03/2021

  begin
    begin
      select hcm_util.get_codcomp_level(codcomp, '1')
        into b_index_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      b_index_codcomp := null;
    end;
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      --<<User37 #5254 Final Test Phase 1 V11 15/03/2021
      begin
        select filename
          into v_filename
          from tcompplcy
         where codcompy = b_index_codcomp
           and codplcy = r1.codplcy
           and trunc(dteeffec) = trunc(r1.dteeffec);
      exception when no_data_found then
        v_filename := null;
      end;
      obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('seqno',v_rcnt);
      obj_data.put('codplcy',r1.codplcy);
      obj_data.put('desc_codplcy',get_tcodec_name('TCODPLCY',r1.codplcy,global_v_lang));
      obj_data.put('filename',v_filename);
      obj_data.put('pathname',get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO15E') || '/' ||v_filename);
      /*obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('seqno',v_rcnt);
      obj_data.put('codplcy',r1.codplcy);
      obj_data.put('desc_codplcy',get_tcodec_name('TCODPLCY',r1.codplcy,global_v_lang));
      obj_data.put('filename',r1.filename);
      obj_data.put('pathname',get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO15E') || '/' ||r1.filename);*/
      -->>User37 #5254 Final Test Phase 1 V11 15/03/2021

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcompplcy');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
  procedure check_index is
  begin
    if b_index_dtest is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_dteen is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_dtest > b_index_dteen  then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;
end;

/
