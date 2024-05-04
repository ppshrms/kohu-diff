--------------------------------------------------------
--  DDL for Package Body HRCO3BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO3BE" AS

  procedure initial_value (json_str in clob) AS
 json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_objectname        := hcm_util.get_string_t(json_obj,'p_objectname');
    p_objecttype        := hcm_util.get_string_t(json_obj,'p_objecttype');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;
--

  procedure check_detail is
  begin
    if p_objectname is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'objectname');
      return;
    elsif p_objecttype is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'objecttype');
      return;
    end if;
  end check_detail;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
 begin
    initial_value(json_str_input);

    gen_index(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);
    cursor cl is
        select      object_type, object_name, status
        from        user_objects
        where       status = 'INVALID'
        and         object_type in ('TRIGGER','PACKAGE','PACKAGE BODY','PROCEDURE','VIEW','FUNCTION')
        order by    object_type, object_name;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in cl loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('objectname', r1.object_name);
      obj_data.put('objecttype', r1.object_type);
      obj_data.put('status', r1.status);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  END gen_index;


    procedure get_detail (json_str_input in clob, json_str_output out clob) AS
 begin
    initial_value(json_str_input);

    check_detail;
    if param_msg_error is null then
        select      count(*)
        into        v_sourcelength
        from        USER_SOURCE
        where       name = p_objectname
        AND         type = p_objecttype;

        if(v_sourcelength > 0) then
            gen_detail(json_str_output);
        else
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'USER_SOURCE');
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);
    cursor cl is
        select      line, text
        from        USER_SOURCE
        where       name = p_objectname
        AND         type = p_objecttype
        ORDER BY    line;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in cl loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('line', r1.line);
      obj_data.put('text', r1.text);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  END gen_detail;


    procedure compile_invalid_object (json_str_input in clob, json_str_output out clob) AS
        json_str            json_object_t;
        param_json          json_object_t;
        param_json_row      json_object_t;
        v_objectname        user_objects.object_name%type;
        v_objecttype        user_objects.object_type%type;
        v_statement         varchar2(1000);
    begin
        initial_value(json_str_input);

        json_str               := json_object_t(json_str_input);
        param_json             := hcm_util.get_json_t(json_str, 'param_json');
        for i in 0..param_json.get_size-1 loop
            param_json_row       := hcm_util.get_json_t(param_json,to_char(i));
            v_objectname         := hcm_util.get_string_t(param_json_row, 'objectname');
            v_objecttype         := hcm_util.get_string_t(param_json_row, 'objecttype');
        
            if v_objecttype = 'PACKAGE BODY' then
                v_statement := 'ALTER PACKAGE '||v_objectname||' COMPILE BODY' ;
            else
                v_statement := 'ALTER '||v_objecttype||' '||v_objectname||' COMPILE' ;
            end if;
            begin
                Execute IMMEDIATE (v_statement);
            exception when others then
                null;
            end;
        end loop;
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END compile_invalid_object;

END HRCO3BE;

/
