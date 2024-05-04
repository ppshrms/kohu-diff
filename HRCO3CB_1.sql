--------------------------------------------------------
--  DDL for Package Body HRCO3CB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO3CB" as
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

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function explode(p_delimiter varchar2, p_string clob, p_limit number default 99) return arr_1d as
    v_str1        clob;
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    for i in 1..p_limit loop
      arr_result(i) := null;
    end loop;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;

  procedure runscript (json_str_input in clob, json_str_output out clob) AS
    json_str            json_object_t;
    param_json          json_object_t;
    param_json_row      json_object_t;
    v_file              json_object_t;
    v_filename          varchar2(150 char);
    v_logfile           clob;
    v_script_stmt       clob;
    l_sql_stmt          clob;
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    arr_result          arr_1d;
    v_code              NUMBER;
    v_errm              clob  ;--VARCHAR2(4000);
    v_script_stmt_x     clob;
    v_concat            varchar2(100);
    v_count             number;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    json_str               := json_object_t(json_str_input);
    param_json             := hcm_util.get_json_t(json_str, 'param_json');
    for i in 0..param_json.get_size-1 loop
      param_json_row        := hcm_util.get_json_t(param_json,to_char(i));
      v_file                := hcm_util.get_json_t(param_json_row,'filename');
      v_filename            := hcm_util.get_string_t(v_file, 'fileName');
       
      if UPPER(substr(v_filename,instr(v_filename,'.',-1)+1,length(v_filename)-instr(v_filename,'.',-1))) not in ('SQL','PKG','FNC') then
--        rollback;
        
        param_msg_error := get_error_msg_php('CO0035',global_v_lang);
        exit;
--        json_str_output := get_response_message(404, param_msg_error, global_v_lang);
--        return;
      end if;
      v_script_stmt         := hcm_util.get_clob_t(v_file, 'data');
      v_script_stmt         := replace(v_script_stmt, '/*', '**#STARTCOMMENT#**' );
      v_script_stmt         := replace(v_script_stmt, '*/', '**#STOPCOMMENT#**' );
--      v_script_stmt         := regexp_replace(v_script_stmt, '( ){2,}', ' ' ); -- replace multiple space to 1 space
      v_script_stmt         := regexp_replace(v_script_stmt, 'SET DEFINE OFF;', '', 1, 0, 'i'); -- remove set define off;
--      v_script_stmt         := regexp_replace(v_script_stmt, CHR(10)||'/', '', 1, 0, 'i'); -- remove / between script


      arr_result := explode(CHR(10)||'/', v_script_stmt,100);
      v_errm                := '';
      v_logfile             := '';

        for i_codleave in 1..100 loop
          v_script_stmt_x := arr_result(i_codleave);
--          v_logfile := v_logfile|| nvl(v_script_stmt_x,'xx');
          if (v_script_stmt_x is not null and (dbms_lob.getlength(v_script_stmt_x)) > 0 )  then
            v_script_stmt_x         := replace(v_script_stmt_x, '**#STARTCOMMENT#**', '/*' );
            v_script_stmt_x         := replace(v_script_stmt_x, '**#STOPCOMMENT#**', '*/' );
            begin
                if SUBSTR(v_filename, INSTR(v_filename, '.')+1, LENGTH(v_filename)) = 'sql' then
                   if upper(ltrim(v_script_stmt_x)) like '%DROP%PROCEDURE%;%' then
                    execute immediate 'begin execute immediate '''||replace(ltrim(v_script_stmt_x),';','')||''';   end;';
                   else
                    execute immediate 'begin ' || v_script_stmt_x || ' end;';
                   end if;
                else
                   execute immediate v_script_stmt_x;
                end if;
            exception when others then
                v_code      := SQLCODE;
                v_errm      := SQLERRM;
                v_logfile   := v_logfile || v_concat || v_errm;
                v_concat    := CHR(10)||'/'||CHR(10);
            end;          
          end if;
        end loop;
        v_logfile := nvl(v_logfile,'success');

      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('filename', v_file);
      obj_data.put('logfilename', ('log_'||v_filename));
      obj_data.put('logfile', v_logfile);
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;

    end loop;
    if param_msg_error is null then
--        commit;
        json_str_output := obj_row.to_clob;
    else
--        rollback;
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END runscript;

  procedure compile_invalid (json_str_input in clob, json_str_output out clob) is
    v_statement         varchar2(1000);
    cursor c1 is
        select      object_type, object_name, status
        from        user_objects
        where       status = 'INVALID'
        and         object_type in ('TRIGGER','PACKAGE','PACKAGE BODY','PROCEDURE','VIEW','FUNCTION')
        order by    object_type, object_name;
  begin
        for i in c1 loop
            if i.object_type = 'PACKAGE BODY' then
                v_statement := 'ALTER PACKAGE '||i.object_name||' COMPILE BODY' ;
            else
                v_statement := 'ALTER '||i.object_type||' '||i.object_name||' COMPILE' ;
            end if;
            begin
                Execute IMMEDIATE (v_statement);
            exception when others then
                null;
            end;
        end loop;
        
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  end compile_invalid;

  procedure msgerror (json_str_input in clob, json_str_output out clob) is
  obj_data             json_object_t;
  begin
        param_msg_error := get_error_msg_php('CO0035',global_v_lang);
        
        obj_data             := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response', replace(param_msg_error,'@#$%400',''));
        json_str_output := obj_data.to_clob();
        
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  end msgerror;

end HRCO3CB;

/
