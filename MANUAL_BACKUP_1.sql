--------------------------------------------------------
--  DDL for Package Body MANUAL_BACKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MANUAL_BACKUP" as
  /* Description
   *
   */
  procedure initial_value (json_str in clob) is
    json_obj            json_object_t;
  begin
    global_json_str     := json_str;
    json_obj            := json_object_t(json_str);
    v_module            := hcm_util.get_string_t(json_obj, 'p_module');
    v_type              := hcm_util.get_string_t(json_obj, 'p_type');
    v_user              := hcm_util.get_string_t(json_obj, 'p_user');
    v_last_update       := hcm_util.get_string_t(json_obj, 'p_day');
    v_custname          := hcm_util.get_string_t(json_obj, 'p_custname');

    json_input      := json_obj;

    if v_type is null then
      v_type            := global_default_type;
    end if;

    if v_user is null then
      v_user            := global_default_user;
    end if;

    if v_last_update is null then
      v_last_update     := global_default_day;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end initial_value;

  procedure self_remove_file (p_filename in varchar2) is
  begin
    if length(v_directory) is null or v_directory is null then
      v_directory := global_default_directory;
    end if;
    if p_filename is not null then
      UTL_FILE.FREMOVE(v_directory, p_filename);
    end if;
    return;
  exception
    when others then
      return;
  end self_remove_file;

  procedure self_write_file (p_filename in varchar2, p_text in varchar2) is
    v_use_file          varchar2(100 char);
    V_OBJ_FILE          UTL_FILE.FILE_TYPE;
  begin
    if length(v_directory) is null or v_directory is null then
      v_directory := global_default_directory;
    end if;
    if p_filename is null then
      v_use_file := to_char(DBMS_RANDOM.STRING('X', 10)) || '.txt';
    else
      v_use_file := p_filename;
    end if;
    V_OBJ_FILE       := UTL_FILE.FOPEN (v_directory, p_filename, 'a', 32000);
    UTL_FILE.PUT (V_OBJ_FILE, to_char(p_text));
    UTL_FILE.FCLOSE (V_OBJ_FILE);
    return;
  exception
    when others then
      return;
  end self_write_file;

  function get_function_name(function_name in varchar2) return varchar2 is
  v_name varchar2(50 char);
  begin
    v_name := function_name;
    if(instr(v_name,'_',1,1)>0) then
        v_name := substr(v_name,1,instr(v_name,'_',1,1)-1);
    end if;

    if(instr(v_name,'HR',1,1)>0) then
        if(instr(v_name,'.',1,1)>0) then
            v_name := substr(v_name,1,instr(v_name,'.',1,1)-1);
        end if;
    end if;

    return v_name;
  end;

  procedure get_backup_main (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_backup_main(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_backup_main;

  procedure gen_backup_main (json_str_output out clob) is
    v_text_temp                     varchar2(4000 char);
    v_object_name                   varchar2(100 char);
    v_object_type                   varchar2(100 char);
    v_object_ext                    varchar2(10 char);
    v_use_filename                  varchar2(100 char);
    v_write_by_line                 boolean := false;
    v_object_found                  clob;
    v_row_count                     number;
    v_exist_module                  boolean := false;
    cursor c_find_object is
      select upper(object_name) as object_name,
             case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end as object_type
        from all_objects
       where owner like v_user
         and last_ddl_time >= (sysdate - to_number(v_last_update))
         and object_name like '%' || nvl(v_module, '') || '%'
         and object_type in (select x.split_values as res_data
                               from (with t as
                                      (select v_type str
                                         from dual
                                        where v_type is not null
                                      )
                                    select regexp_substr (str, '[^,]+', 1, level) split_values
                                      from t
                                connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                    ) x
                            )
    group by case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end,
             object_name
    order by object_type, object_name;

    cursor c_find_source is
      select name, text, line
        from all_source
       where owner like v_user
         and upper(name) like v_object_name
         and upper(type) like v_object_type
    order by line;

  begin
    v_object_found        := '';
    v_row_count           := 0;
    for row_object in c_find_object loop
      v_row_count         := v_row_count + 1;
      v_object_name       := row_object.object_name;
      v_object_type       := row_object.object_type;

      if v_object_type = 'PACKAGE BODY' then
        continue;
      end if;

--      v_object_found      := v_object_found || v_object_type || ' :: ' || v_object_name || v_new_line;

      if v_object_type in ('FUNCTION') then
        v_object_ext := '.fnc';
      elsif v_object_type in ('PACKAGE') then
        v_object_ext := '.pkg';
      elsif v_object_type in ('PROCEDURE') then
        v_object_ext := '.prc';
      elsif v_object_type in ('TYPE') then
        v_object_ext := '.sql';
      else
        v_object_ext := '.sql';
      end if;
      if v_object_type in ('JAVA SOURCE') then
        v_write_by_line   := true;
      else
        v_write_by_line   := false;
      end if;

      v_directory         := global_default_directory||'_'||replace(v_object_type, ' ', '_');
DBMS_OUTPUT.PUT_LINE(v_directory);
      v_use_filename      := v_object_name||v_object_ext;
      v_use_filename      := replace(v_use_filename, ' ', '_');
      self_remove_file(v_use_filename);

      v_text_temp := '';
      for row_source in c_find_source loop
        if row_source.line = 1 then
          if v_object_type in ('TYPE') and v_object_name not like 'JSON%' then
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'drop type '||v_object_name||' force;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          else
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          end if;
        end if;
        v_text_temp   := v_text_temp||to_char(row_source.text);
        if v_write_by_line then
          v_text_temp := v_text_temp||v_new_line;
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        else
          if length(v_text_temp) > v_max_text then
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          end if;
        end if;
      end loop;

      if length(v_text_temp) is not null and length(v_text_temp) > 0 then
        self_write_file (v_use_filename, v_text_temp);
        v_text_temp := '';
      end if;
      self_write_file (v_use_filename, v_end_of_module);

      v_text_temp := '';
      if v_object_type in ('TYPE') then
        v_object_type := v_object_type || ' BODY';
        v_exist_module  := false;
        for row_source in c_find_source loop
          v_exist_module := true;
          if row_source.line = 1 then
            v_text_temp := v_text_temp||'create or replace ';
          end if;
          v_text_temp   := v_text_temp||to_char(row_source.text);
          if v_write_by_line then
            v_text_temp := v_text_temp||v_new_line;
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          else
            if length(v_text_temp) > v_max_text then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
          end if;
        end loop;

        if length(v_text_temp) is not null and length(v_text_temp) > 0 then
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        end if;
        if v_exist_module then
          self_write_file (v_use_filename, v_end_of_module);
        end if;
      end if;

      v_text_temp := '';
      if v_object_type in ('PACKAGE') then
        v_object_type := v_object_type || ' BODY';
        v_use_filename      := v_object_name||'_BODY'||v_object_ext;
        v_use_filename      := replace(v_use_filename, ' ', '_');
        self_remove_file(v_use_filename);
        v_exist_module  := false;
        for row_source in c_find_source loop
          v_exist_module := true;
          if row_source.line = 1 then
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          end if;
          v_text_temp   := v_text_temp||to_char(row_source.text);
          if v_write_by_line then
            v_text_temp := v_text_temp||v_new_line;
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          else
            if length(v_text_temp) > v_max_text then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
          end if;
        end loop;

        if length(v_text_temp) is not null and length(v_text_temp) > 0 then
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        end if;
        if v_exist_module then
          self_write_file (v_use_filename, v_end_of_module);
        end if;
      end if;
    end loop;
    v_object_found        := v_object_found || 'Total :: ' || to_char(v_row_count) || v_new_line;
    json_str_output       := v_object_found || 'success with params => ' || global_json_str;
  end gen_backup_main;

  procedure get_patch_standard (json_str_input in clob, json_str_output out clob) is
  begin

    initial_value(json_str_input);
    if param_msg_error is null then
      gen_patch_standard(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_patch_standard;

  procedure gen_patch_standard (json_str_output out clob) is
    v_text_temp                     varchar2(4000 char);
    v_object_name                   varchar2(100 char);
    v_object_type                   varchar2(100 char);
    v_object_ext                    varchar2(10 char);
    v_use_filename                  varchar2(100 char);
    v_temp_filename                  varchar2(100 char);
    v_write_by_line                 boolean := false;
    v_object_found                  clob;
    v_function_list                 clob := '';
    v_row_count                     number;
    v_exist_module                  boolean := false;
    version_file                    utl_file.File_Type;
    v_filename                      varchar2(100 char);
    cursor c_find_object is
      select upper(object_name) as object_name,
             case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end as object_type
        from all_objects a,tcustmodify b
       where owner like v_user
         and last_ddl_time >= (sysdate - to_number(v_last_update))
         and object_name like '%' || nvl(v_module, '') || '%'
         and object_type in (select x.split_values as res_data
                               from (with t as
                                      (select v_type str
                                         from dual
                                        where v_type is not null
                                      )
                                    select regexp_substr (str, '[^,]+', 1, level) split_values
                                      from t
                                connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                    ) x
                            )
         and   upper(object_name) = b.name
         and   flgmodify = 'N'
         and   custname = v_custname
    group by case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end,
             object_name
    order by object_type, object_name;

    cursor c_find_source is
      select name, text, line
        from all_source
       where owner like v_user
         and upper(name) like v_object_name
         and upper(type) like v_object_type
    order by line;

  begin
    v_object_found        := '';
    v_row_count           := 0;

    v_filename := 'patch_version.txt';
    version_file := utl_file.Fopen('UTL_DIR_BACKUP_FUNCTION',v_filename,'w');

    utl_file.Put_line(version_file,v_custname || '-' ||to_char(sysdate,'YYYYmmdd-hh24mi'));

    for row_object in c_find_object loop
      v_row_count         := v_row_count + 1;
      v_object_name       := row_object.object_name;
      v_object_type       := row_object.object_type;

      if v_object_type = 'PACKAGE BODY' then
        continue;
      end if;

      if v_object_type in ('FUNCTION') then
        v_object_ext := '.fnc';
      elsif v_object_type in ('PACKAGE') then
        v_object_ext := '.pkg';
      elsif v_object_type in ('PROCEDURE') then
        v_object_ext := '.prc';
      elsif v_object_type in ('TYPE') then
        v_object_ext := '.sql';
      else
        v_object_ext := '.sql';
      end if;
      if v_object_type in ('JAVA SOURCE') then
        v_write_by_line   := true;
      else
        v_write_by_line   := false;
      end if;

      v_directory         := global_default_directory||'_'||replace(v_object_type, ' ', '_');
      DBMS_OUTPUT.PUT_LINE(v_directory);
      v_use_filename      := v_object_name||v_object_ext;
      v_use_filename      := replace(v_use_filename, ' ', '_');
      self_remove_file(v_use_filename);

      v_temp_filename := v_use_filename;

      if(instr(v_temp_filename,'HR',1,1)>0) then
        v_temp_filename := get_function_name(v_temp_filename);
        utl_file.Put_line(version_file,v_temp_filename);
      end if;

      v_text_temp := '';
      for row_source in c_find_source loop
        if row_source.line = 1 then
          if v_object_type in ('TYPE') and v_object_name not like 'JSON%' then
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'drop type '||v_object_name||' force;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          else
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          end if;
        end if;
        v_text_temp   := v_text_temp||to_char(row_source.text);
        if v_write_by_line then
          v_text_temp := v_text_temp||v_new_line;
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        else
          if length(v_text_temp) > v_max_text then
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          end if;
        end if;
      end loop;

      if length(v_text_temp) is not null and length(v_text_temp) > 0 then
        self_write_file (v_use_filename, v_text_temp);
        v_text_temp := '';
      end if;
      self_write_file (v_use_filename, v_end_of_module);

      v_text_temp := '';
      if v_object_type in ('TYPE') then
        v_object_type := v_object_type || ' BODY';
        v_exist_module  := false;
        for row_source in c_find_source loop
          v_exist_module := true;
          if row_source.line = 1 then
            v_text_temp := v_text_temp||'create or replace ';
          end if;
          v_text_temp   := v_text_temp||to_char(row_source.text);
          if v_write_by_line then
            v_text_temp := v_text_temp||v_new_line;
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          else
            if length(v_text_temp) > v_max_text then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
          end if;
        end loop;

        if length(v_text_temp) is not null and length(v_text_temp) > 0 then
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        end if;
        if v_exist_module then
          self_write_file (v_use_filename, v_end_of_module);
        end if;
      end if;

      v_text_temp := '';
      if v_object_type in ('PACKAGE') then
        v_object_type := v_object_type || ' BODY';
        v_use_filename      := v_object_name||'_BODY'||v_object_ext;
        v_use_filename      := replace(v_use_filename, ' ', '_');
        self_remove_file(v_use_filename);
        v_exist_module  := false;
        for row_source in c_find_source loop
          v_exist_module := true;
          if row_source.line = 1 then
            v_text_temp := v_text_temp||'set define off;'||v_new_line;
            v_text_temp := v_text_temp||'create or replace ';
          end if;
          v_text_temp   := v_text_temp||to_char(row_source.text);
          if v_write_by_line then
            v_text_temp := v_text_temp||v_new_line;
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          else
            if length(v_text_temp) > v_max_text then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
          end if;
        end loop;

        if length(v_text_temp) is not null and length(v_text_temp) > 0 then
          self_write_file (v_use_filename, v_text_temp);
          v_text_temp := '';
        end if;
        if v_exist_module then
          self_write_file (v_use_filename, v_end_of_module);
        end if;
      end if;
    end loop;
    utl_file.Fclose(version_file);
    v_object_found        := v_object_found || 'Total :: ' || to_char(v_row_count) || v_new_line;
    json_str_output       := v_object_found || 'success with params => ' || global_json_str;
  end gen_patch_standard;

  procedure get_patch_package (json_str_input in clob, json_str_output out clob) is
  begin

    initial_value(json_str_input);
    if param_msg_error is null then
      gen_patch_package(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_patch_package;

  procedure gen_patch_package (json_str_output out clob) is
    v_text_temp                     varchar2(4000 char);
    v_object_name                   varchar2(100 char);
    v_object_type                   varchar2(100 char);
    v_object_ext                    varchar2(10 char);
    v_use_filename                  varchar2(100 char);
    v_temp_filename                  varchar2(100 char);
    v_write_by_line                 boolean := false;
    v_object_found                  clob;
    v_function_list                 clob := '';
    v_row_count                     number;
    v_exist_module                  boolean := false;
    version_file                    utl_file.File_Type;
    v_filename                      varchar2(100 char);
    v_function_name                 varchar2(20 char);
    param_json_row                  json_object_t;   
    obj_row                         json_object_t;  
    v_funct                         varchar2(20 char);
    cursor c_find_object2 is
      select upper(object_name) as object_name,
             case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end as object_type
        from all_objects a,tcustmodify b
       where owner like v_user
         and last_ddl_time >= (sysdate - to_number(v_last_update))
         and object_name like '%' || nvl(v_module, '') || '%'
         and object_type in (select x.split_values as res_data
                               from (with t as
                                      (select v_type str
                                         from dual
                                        where v_type is not null
                                      )
                                    select regexp_substr (str, '[^,]+', 1, level) split_values
                                      from t
                                connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                    ) x
                            )
         and   upper(object_name) = b.name
         and   flgmodify = 'N'
         and   custname = v_custname
    group by case when upper(object_type) = 'PACKAGE BODY' then 'PACKAGE'
                  when upper(object_type) = 'TYPE BODY' then 'TYPE'
                  else upper(object_type)
             end,
             object_name
    order by object_type, object_name;

    cursor c_find_object is
    select d_level,referenced_type object_type,referenced_name object_name,referenced_owner  
      from(
           select level d_level,referenced_type,referenced_name,referenced_owner
            from user_dependencies
                 start with  name = v_function_name
                 connect by  prior referenced_name = name
        and prior referenced_type = type
        and type = 'PACKAGE')
    where (referenced_type = 'PACKAGE' 
       or referenced_type = 'FUNCTION'
       or referenced_type = 'PROCEDURE')
--       and d_level = 1
       and referenced_owner = user
  order by referenced_type;

    cursor c_find_source is
      select name, text, line
        from all_source
       where owner like v_user
         and upper(name) like v_object_name
         and upper(type) like v_object_type
    order by line;

  begin
    v_object_found        := '';
    v_row_count           := 0;

    v_filename := 'patch_version.txt';
    version_file := utl_file.Fopen('UTL_DIR_BACKUP_FUNCTION',v_filename,'w');

    utl_file.Put_line(version_file,'SIT-STD-' ||to_char(sysdate,'YYYYmmdd-hh24mi'));
    insert_temp2('MONGKOL','HCMV11','json_input.get_size='||json_input.get_size);
    insert_temp2('MONGKOL','HCMV11','v_filename'||v_filename);
    for i in 0..json_input.get_size  loop
        param_json_row:= json_object_t(hcm_util.get_json_t(json_input, to_char(i)));
        v_function_name      := hcm_util.get_string_t(param_json_row, 'function_name');

        for row_object in c_find_object loop
          v_row_count         := v_row_count + 1;
          v_object_name       := row_object.object_name;
          v_object_type       := row_object.object_type;

          if v_object_type = 'PACKAGE BODY' then
            continue;
          end if;

          if v_object_type in ('FUNCTION') then
            v_object_ext := '.fnc';
          elsif v_object_type in ('PACKAGE') then
            v_object_ext := '.pkg';
          elsif v_object_type in ('PROCEDURE') then
            v_object_ext := '.prc';
          elsif v_object_type in ('TYPE') then
            v_object_ext := '.sql';
          else
            v_object_ext := '.sql';
          end if;
          if v_object_type in ('JAVA SOURCE') then
            v_write_by_line   := true;
          else
            v_write_by_line   := false;
          end if;

          v_directory         := global_default_directory||'_'||replace(v_object_type, ' ', '_');
          DBMS_OUTPUT.PUT_LINE(v_directory);
          v_use_filename      := v_object_name||v_object_ext;
          v_use_filename      := replace(v_use_filename, ' ', '_');
          self_remove_file(v_use_filename);

          v_temp_filename := v_use_filename;

          if(instr(v_temp_filename,'HR',1,1)>0) then
            v_temp_filename := get_function_name(v_temp_filename);
            utl_file.Put_line(version_file,v_temp_filename);
          end if;

          v_text_temp := '';
          for row_source in c_find_source loop
            if row_source.line = 1 then
              if v_object_type in ('TYPE') and v_object_name not like 'JSON%' then
                v_text_temp := v_text_temp||'set define off;'||v_new_line;
                v_text_temp := v_text_temp||'drop type '||v_object_name||' force;'||v_new_line;
                v_text_temp := v_text_temp||'create or replace ';
              else
                v_text_temp := v_text_temp||'set define off;'||v_new_line;
                v_text_temp := v_text_temp||'create or replace ';
              end if;
            end if;
            v_text_temp   := v_text_temp||to_char(row_source.text);
            if v_write_by_line then
              v_text_temp := v_text_temp||v_new_line;
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            else
              if length(v_text_temp) > v_max_text then
                self_write_file (v_use_filename, v_text_temp);
                v_text_temp := '';
              end if;
            end if;
          end loop;

          if length(v_text_temp) is not null and length(v_text_temp) > 0 then
            self_write_file (v_use_filename, v_text_temp);
            v_text_temp := '';
          end if;
          self_write_file (v_use_filename, v_end_of_module);

          v_text_temp := '';
          if v_object_type in ('TYPE') then
            v_object_type := v_object_type || ' BODY';
            v_exist_module  := false;
            for row_source in c_find_source loop
              v_exist_module := true;
              if row_source.line = 1 then
                v_text_temp := v_text_temp||'create or replace ';
              end if;
              v_text_temp   := v_text_temp||to_char(row_source.text);
              if v_write_by_line then
                v_text_temp := v_text_temp||v_new_line;
                self_write_file (v_use_filename, v_text_temp);
                v_text_temp := '';
              else
                if length(v_text_temp) > v_max_text then
                  self_write_file (v_use_filename, v_text_temp);
                  v_text_temp := '';
                end if;
              end if;
            end loop;

            if length(v_text_temp) is not null and length(v_text_temp) > 0 then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
            if v_exist_module then
              self_write_file (v_use_filename, v_end_of_module);
            end if;
          end if;

          v_text_temp := '';
          if v_object_type in ('PACKAGE') then
            v_object_type := v_object_type || ' BODY';
            v_use_filename      := v_object_name||'_BODY'||v_object_ext;
            v_use_filename      := replace(v_use_filename, ' ', '_');
            self_remove_file(v_use_filename);
            v_exist_module  := false;
            for row_source in c_find_source loop
              v_exist_module := true;
              if row_source.line = 1 then
                v_text_temp := v_text_temp||'set define off;'||v_new_line;
                v_text_temp := v_text_temp||'create or replace ';
              end if;
              v_text_temp   := v_text_temp||to_char(row_source.text);
              if v_write_by_line then
                v_text_temp := v_text_temp||v_new_line;
                self_write_file (v_use_filename, v_text_temp);
                v_text_temp := '';
              else
                if length(v_text_temp) > v_max_text then
                  self_write_file (v_use_filename, v_text_temp);
                  v_text_temp := '';
                end if;
              end if;
            end loop;

            if length(v_text_temp) is not null and length(v_text_temp) > 0 then
              self_write_file (v_use_filename, v_text_temp);
              v_text_temp := '';
            end if;
            if v_exist_module then
              self_write_file (v_use_filename, v_end_of_module);
            end if;
          end if;
        end loop;
    end loop;
    utl_file.Fclose(version_file);
    v_object_found        := v_object_found || 'Total :: ' || to_char(v_row_count) || v_new_line;
    json_str_output       := v_object_found || 'success with params => ' || global_json_str;  
  exception when others then
  param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  insert_temp2('MONGKOL','HCMV11','param_msg_error='||param_msg_error);
  end gen_patch_package;

end MANUAL_BACKUP;

/
