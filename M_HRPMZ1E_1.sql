--------------------------------------------------------
--  DDL for Package Body M_HRPMZ1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPMZ1E" as
/* Cust-Modify: KOHU-HR2301 */
-- last update: 12/06/2023 14:04

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin

    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_typcode           := hcm_util.get_string_t(json_obj, 'p_typcode');
    p_tablename         := hcm_util.get_string_t(json_obj, 'p_tablename'); 
    p_lovtype           := hcm_util.get_string_t(json_obj, 'p_lovtype'); 

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) is
    obj_row            json_object_t := json_object_t();
    obj_data           json_object_t;
    v_rcnt             number  := 0;
    v_table            varchar2(100 char);
    v_cursor_id        integer;
    v_col              number;
    v_count            number := 0;
    v_desctab          dbms_sql.desc_tab;
    v_stmt             varchar2(4000 char);

    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;
    v_col_num        number := 0;

    type table_cursor is ref cursor;
    hrpmz1e_cursor    table_cursor;

    v_codcodec  varchar2(200 char);
    v_descod    varchar2(200 char);
    v_descode   varchar2(200 char);
    v_descodt   varchar2(200 char);
    v_descod3   varchar2(200 char);
    v_descod4   varchar2(200 char);
    v_descod5   varchar2(200 char);
    v_qtysap    number;
    v_qtyhcm    number;
    vv_test clob;

    cursor c1 is
      select typcode,tablename,codapp,
             destyp3,destyp4,destyp5,destype,destypt,
             decode( global_v_lang,'101',destype,
                                   '102',destypt,
                                   '103',destyp3,
                                   '104',destyp4,
                                   '105',destyp5) destyp
        from ttypecode
       where datatype is not null
    order by typcode;

  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for r1 in c1 loop
--      begin
--        select count(*) into v_qtysap
--        from   tmapcode
--        where  typcode = r1.typcode
--        and    hcmcode is null;
--      end;
--      if v_qtysap = 0 then
--        v_qtysap := 0;
--      end if;
--      begin
--        select count(*) into v_qtyhcm
--        from   tmapcode
--        where  typcode = r1.typcode
--        and    hcmcode is not null;
--      end;
--      if v_qtyhcm = 0 then
--        v_qtyhcm := 0;
--      end if;

      select count(sapcode), count(hcmcode) into v_qtysap,v_qtyhcm 
      from tmapcode 
      where typcode  = r1.typcode;
      
      v_qtysap := v_qtysap - v_qtyhcm;
      
      v_rcnt          := v_rcnt + 1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('typcode', r1.typcode);
      obj_data.put('desc_typcode', r1.destyp);
      obj_data.put('tablename', r1.tablename);
      obj_data.put('qtymapp', v_qtyhcm);
      obj_data.put('qtyunmapp', v_qtysap);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure gen_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_data_all    json_object_t;

    v_rcnt          number  := 0;
    v_tablename     ttypecode.tablename%type;
    v_lovname       ttypecode.codapp%type;
    v_datatype        varchar2(100 char);

    cursor c1 is
      select sapcode, hcmcode
        from tmapcode
       where typcode = p_typcode
    order by sapcode;

  begin

    begin
      select tablename,codapp,datatype into v_tablename,v_lovname,v_datatype
      from  ttypecode
      where typcode = p_typcode;
    exception when no_data_found then
      v_table     := '';
      v_lovname   := '';
      v_datatype  := '';
    end;

    obj_row       := json_object_t();
    obj_data_all  := json_object_t();
    v_rcnt        := 0;

    for r1 in c1 loop
      v_rcnt          := v_rcnt + 1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('wkdcode',r1.sapcode);
      obj_data.put('hrmscode',nvl(r1.hcmcode,''));
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    obj_data_all.put('coderror', '200');
    obj_data_all.put('typcode',p_typcode);
    obj_data_all.put('tablename',v_tablename);
    obj_data_all.put('lovtype',v_lovname);
    obj_data_all.put('datatype',v_datatype);

    obj_data_all.put('table',obj_row);

    json_str_output := obj_data_all.to_clob;
  end gen_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    v_stmt              varchar2(2000 char) := '';
    v_comlvl            varchar2(3 char);
    v_flgcond           number;

    v_wkdcode     tmapcode.sapcode%type;
    v_wkdcodeOld  tmapcode.sapcode%type;
    v_hrmscode    tmapcode.hcmcode%type;
    v_tablename   ttypecode.tablename%type;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    
    for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));

        v_wkdcode       := hcm_util.get_string_t(param_json_row,'wkdcode');
        v_wkdcodeOld    := hcm_util.get_string_t(param_json_row,'wkdcodeOld');
        v_hrmscode      := hcm_util.get_string_t(param_json_row,'hrmscode');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');

        if v_flg = 'add' then
            begin
                insert into tmapcode (typcode,sapcode,hcmcode,dtecreate,codcreate,dteupd,coduser)
                values               (p_typcode,v_wkdcode,v_hrmscode,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TMAPCODE');
            end;
        elsif v_flg = 'edit' then
            update tmapcode set sapcode  = v_wkdcode,
                                hcmcode = v_hrmscode,
                                dteupd   = sysdate,
                                coduser  = global_v_coduser
            where typcode = p_typcode
              and sapcode = v_wkdcodeOld;
        elsif v_flg = 'delete' then
            delete tmapcode
             where typcode = p_typcode
               and sapcode = v_wkdcode;
        end if;
    end loop;
    <<end_loop>>
    null;
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
        rollback;
        end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  
  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    v_stmt              varchar2(2000 char) := '';
    v_comlvl            varchar2(3 char);
    v_flgcond           number;

    v_typecode     tmapcode.typcode%type;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop

        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        --
        v_typecode   := hcm_util.get_string_t(param_json_row,'typcode');
        v_flg       := hcm_util.get_string_t(param_json_row,'flg');
       
        if v_flg = 'delete' then
            delete tmapcode
             where typcode = v_typecode;
        end if;
    end loop;
    <<end_loop>>
    null;
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
        rollback;
        end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- >>
END M_HRPMZ1E;

/
