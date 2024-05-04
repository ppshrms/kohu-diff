--------------------------------------------------------
--  DDL for Package Body HCM_STATEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_STATEMENT" AS
  procedure initial_value(json_str_input in clob) is
    json_obj json;
  begin
    json_obj        := json(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function replace_stmt_with_parent_obj(p_stmt in clob, p_obj json) return clob is
    v_stmt        clob;
    v_keyword     varchar2(100 char) := ':parent';
    v_parent_key  varchar2(100 char);
    v_substr      varchar2(100 char);
  begin
    v_stmt    := p_stmt;
    while REGEXP_COUNT(v_stmt, v_keyword) > 0 loop
      v_substr := REGEXP_SUBSTR(v_stmt, '(\S*)(\s)', instr(v_stmt, v_keyword), 1);
      v_substr := replace(v_substr, chr(10), ''); -- replace enter charecter
      v_substr := replace(v_substr, ',', ''); -- replace , charecter
      v_substr := trim(v_substr); -- clean space charecter
      v_parent_key := substr(v_substr, instr(v_substr, '.') + 1, length(v_substr));
      bind(v_stmt, v_substr, hcm_util.get_string(p_obj, v_parent_key));
    end loop;

    return v_stmt;
  end;

  function replace_stmt_with_parent_obj_t(p_stmt in clob, p_obj json_object_t) return clob is
    v_stmt        clob;
    v_keyword     varchar2(100 char) := ':parent';
    v_parent_key  varchar2(100 char);
    v_substr      varchar2(100 char);
  begin
    v_stmt    := p_stmt;
    while REGEXP_COUNT(v_stmt, v_keyword) > 0 loop
      v_substr := REGEXP_SUBSTR(v_stmt, '(\S*)(\s)', instr(v_stmt, v_keyword), 1);
      v_substr := replace(v_substr, chr(10), ''); -- replace enter charecter
      v_substr := replace(v_substr, ',', ''); -- replace , charecter
      v_substr := trim(v_substr); -- clean space charecter
      v_parent_key := substr(v_substr, instr(v_substr, '.') + 1, length(v_substr));
      bind(v_stmt, v_substr, hcm_util.get_string_t(p_obj, v_parent_key));
    end loop;

    return v_stmt;
  end;

  procedure bind(p_stmt in out clob, p_key_bind in varchar2, p_val_bind in varchar2, p_type in clob default 'varchar2') as
  begin
    if p_type = 'varchar2' then
      p_stmt := replace(p_stmt, p_key_bind, q'[']' || p_val_bind || q'[']');
    elsif p_type = 'number' then
      p_stmt := replace(p_stmt, p_key_bind, q'[to_number(']' || p_val_bind || q'[')]');
    elsif p_type = 'date' then
      p_stmt := replace(p_stmt, p_key_bind, q'[to_date(']' || p_val_bind || q'[', 'dd/mm/yyyy')]');
    elsif p_type = 'datetime' then
      p_stmt := replace(p_stmt, p_key_bind, q'[to_date(']' || p_val_bind || q'[', 'dd/mm/yyyy hh24:mi:ss')]');
    elsif p_type = 'boolean' then
      p_stmt := replace(p_stmt, p_key_bind, p_val_bind);
    end if;
  end;

  function execute_clob(p_obj json, p_flg_parent boolean default true) return clob AS
    obj_row           json;
    json_str_output   clob;
  begin
    obj_row := execute_obj(p_obj, p_flg_parent);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
    return json_str_output;
  end;

  function execute_obj(p_obj json, p_flg_parent boolean default true) return json AS
    l_theCursor       integer default dbms_sql.open_cursor;
    l_columnValue     varchar2(4000);
    l_status          integer;
    l_descTbl         dbms_sql.desc_tab;
    l_colCnt          number;

    obj_data          json;
    obj_row           json;
    v_row             number := 0;
    json_str_output   clob;
    v_query           clob := hcm_util.get_string(p_obj, 'stmt');
    v_query_child     clob;
    v_obj_children    json  := hcm_util.get_json(p_obj, 'children');
    v_key_children    json_list;
    v_key_child       varchar2(100 char);
    v_obj_child       json;
  begin
    if v_query is not null then
      dbms_sql.parse(l_theCursor,v_query,dbms_sql.native);
      dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl);

      for i in 1 .. l_colCnt loop
        dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
      end loop;

      l_status := dbms_sql.execute(l_theCursor);
      obj_row := json();
      while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        obj_data := json();
        for i in 1 .. l_colCnt loop
          dbms_sql.column_value( l_theCursor, i, l_columnValue );
          obj_data.put(lower(l_descTbl(i).col_name), l_columnValue);
        end loop;
        if v_obj_children.count > 0 then
          v_key_children  := v_obj_children.get_keys;
          for i in 1..v_key_children.count loop
            v_key_child := replace(v_key_children.get(i).to_char, '"', '');
            v_obj_child := hcm_util.get_json(v_obj_children, v_key_child);
            v_query_child := replace_stmt_with_parent_obj(hcm_util.get_string(v_obj_child, 'stmt'), obj_data);
            v_obj_child.put('stmt', v_query_child);
            obj_data.put(v_key_child, execute_obj(v_obj_child, false));
          end loop;
        end if;
        if p_flg_parent = true then
          obj_data.put('coderror', '200');
        end if;
        if nvl(hcm_util.get_string(p_obj, 'obj_type'), 'table') = 'record' then
          dbms_sql.close_cursor( l_theCursor );
          return obj_data;
        end if;
        v_row := v_row + 1;
        obj_row.put(to_char(v_row - 1), obj_data);
      end loop;
      dbms_sql.close_cursor( l_theCursor );
      return obj_row;
    else
      obj_row := json();
      obj_data := json();
      if v_obj_children.count > 0 then
        v_key_children  := v_obj_children.get_keys;
        for i in 1..v_key_children.count loop
          v_key_child := replace(v_key_children.get(i).to_char, '"', '');
          v_obj_child := hcm_util.get_json(v_obj_children, v_key_child);
          v_query_child := replace_stmt_with_parent_obj(hcm_util.get_string(v_obj_child, 'stmt'), obj_data);
          v_obj_child.put('stmt', v_query_child);
          obj_data.put(v_key_child, execute_obj(v_obj_child, false));
        end loop;
      end if;
      if p_flg_parent = true then
        obj_data.put('coderror', '200');
      end if;
      if nvl(hcm_util.get_string(p_obj, 'obj_type'), 'table') = 'record' then
        return obj_data;
      end if;
      v_row := v_row + 1;
      obj_row.put(to_char(v_row - 1), obj_data);
      return obj_row;
    end if;
  exception when others then dbms_sql.close_cursor( l_theCursor ); RAISE;
  end execute_obj;

  function execute_obj_t(p_obj json_object_t, p_flg_parent boolean default true) return json_object_t AS
    l_theCursor       integer default dbms_sql.open_cursor;
    l_columnValue     varchar2(4000);
    l_status          integer;
    l_descTbl         dbms_sql.desc_tab;
    l_colCnt          number;

    obj_data          json_object_t;
    obj_row           json_object_t;
    v_row             number := 0;
    json_str_output   clob;
    v_query           clob := hcm_util.get_string_t(p_obj, 'stmt');
    v_query_child     clob;
    v_obj_children    json_object_t  := hcm_util.get_json_t(p_obj, 'children');
    v_key_children    json_key_list;
    v_key_child       varchar2(100 char);
    v_obj_child       json_object_t;
  begin
    if v_query is not null then
      dbms_sql.parse(l_theCursor,v_query,dbms_sql.native);
      dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl);

      for i in 1 .. l_colCnt loop
        dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
      end loop;

      l_status := dbms_sql.execute(l_theCursor);
      obj_row := json_object_t();
      while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        obj_data := json_object_t();
        for i in 1 .. l_colCnt loop
          dbms_sql.column_value( l_theCursor, i, l_columnValue );
          obj_data.put(lower(l_descTbl(i).col_name), l_columnValue);
        end loop;
        if v_obj_children.get_size > 0 then
          v_key_children  := v_obj_children.get_keys;
          for i in 1..v_obj_children.get_size loop
            v_key_child := replace(v_key_children(i), '"', '');
            v_obj_child := hcm_util.get_json_t(v_obj_children, v_key_child);
            v_query_child := replace_stmt_with_parent_obj_t(hcm_util.get_string_t(v_obj_child, 'stmt'), obj_data);
            v_obj_child.put('stmt', v_query_child);
            obj_data.put(v_key_child, execute_obj_t(v_obj_child, false));
          end loop;
        end if;
        if p_flg_parent = true then
          obj_data.put('coderror', '200');
        end if;
        if nvl(hcm_util.get_string_t(p_obj, 'obj_type'), 'table') = 'record' then
          dbms_sql.close_cursor( l_theCursor );
          return obj_data;
        end if;
        v_row := v_row + 1;
        obj_row.put(to_char(v_row - 1), obj_data);
      end loop;
      dbms_sql.close_cursor( l_theCursor );
      return obj_row;
    else
      obj_row := json_object_t();
      obj_data := json_object_t();
      if v_obj_children.get_size > 0 then
        v_key_children  := v_obj_children.get_keys;
        for i in 1..v_obj_children.get_size loop
          v_key_child := replace(v_key_children(i), '"', '');
          v_obj_child := hcm_util.get_json_t(v_obj_children, v_key_child);
          v_query_child := replace_stmt_with_parent_obj_t(hcm_util.get_string_t(v_obj_child, 'stmt'), obj_data);
          v_obj_child.put('stmt', v_query_child);
          obj_data.put(v_key_child, execute_obj_t(v_obj_child, false));
        end loop;
      end if;
      if p_flg_parent = true then
        obj_data.put('coderror', '200');
      end if;
      if nvl(hcm_util.get_string_t(p_obj, 'obj_type'), 'table') = 'record' then
        return obj_data;
      end if;
      v_row := v_row + 1;
      obj_row.put(to_char(v_row - 1), obj_data);
      return obj_row;
    end if;
  exception when others then dbms_sql.close_cursor( l_theCursor ); RAISE;
  end execute_obj_t;

  function execute_clob(p_stmt clob, p_obj_type varchar2 default 'table') return clob is
    v_obj json := json();
  begin
    v_obj.put('stmt', p_stmt);
    v_obj.put('obj_type', p_obj_type);
    return execute_clob(v_obj);
  end;

  function execute_obj(p_stmt clob, p_obj_type varchar2 default 'table') return json is
    v_obj json := json();
  begin
    v_obj.put('stmt', p_stmt);
    v_obj.put('obj_type', p_obj_type);
    return execute_obj(v_obj);
  end;

  function execute_obj_t(p_stmt clob, p_obj_type varchar2 default 'table') return json_object_t is
    v_obj json_object_t := json_object_t();
  begin
    v_obj.put('stmt', p_stmt);
    v_obj.put('obj_type', p_obj_type);
    return execute_obj_t(v_obj);
  end;

  function example1(json_str_input in clob) return clob is
    v_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';
  begin
    initial_value(json_str_input);
    bind(v_stmt, ':codempid', global_v_codempid);
    return execute_clob(v_stmt);
  end;

  function example2(json_str_input in clob) return clob is
    obj_row    json := json();
    v_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';

    json_str_output clob;
  begin
    initial_value(json_str_input);
    bind(v_stmt, ':codempid', global_v_codempid);

    obj_row := execute_obj(v_stmt);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

    return json_str_output;
  end;

  -- select hcm_statement.example1('{"p_coduser":"TJS00001","p_codempid":"53100","p_lang":"102"}') from dual;
  function example3(json_str_input in clob) return clob is
    v_parent_obj      json := json();
    v_parent_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';
    v_children_obj    json := json();
    v_child_obj       json := json();
    v_child_stmt      varchar2(32000 char) := q'[
      select dtework, typwork
        from tattence
       where codempid = :parent.codempid
         and rownum <= 10
    ]';

    json_str_output clob;
  begin
    initial_value(json_str_input);

    v_child_obj.put('stmt', v_child_stmt);

    v_children_obj.put('events', v_child_obj);

    bind(v_parent_stmt, ':codempid', global_v_codempid);
    v_parent_obj.put('stmt', v_parent_stmt);
    v_parent_obj.put('children', v_children_obj);

    json_str_output := hcm_statement.execute_clob(v_parent_obj);

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    return json_str_output;
  end;

  -- select hcm_statement.example2('{"p_coduser":"TJS00001","p_codempid":"53100","p_lang":"102"}') from dual;
  function example4(json_str_input in clob) return clob is
    v_parent_obj      json := json();
    v_parent_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';
    v_children_obj    json := json();
    v_child_obj       json := json();
    v_child_stmt      varchar2(32000 char) := q'[
      select dtework, typwork
        from tattence
       where codempid = :parent.codempid
         and rownum <= 10
    ]';

    json_str_output clob;
  begin
    initial_value(json_str_input);

    v_child_obj.put('stmt', v_child_stmt);
    v_child_obj.put('obj_type', 'record');

    v_children_obj.put('events', v_child_obj);

    bind(v_parent_stmt, ':codempid', global_v_codempid);
    v_parent_obj.put('stmt', v_parent_stmt);
    v_parent_obj.put('obj_type', 'record');
    v_parent_obj.put('children', v_children_obj);

    json_str_output := hcm_statement.execute_clob(v_parent_obj);

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    return json_str_output;
  end;

  -- select hcm_statement.example3('{"p_coduser":"TJS00001","p_codempid":"53100","p_lang":"102"}') from dual;
  function example5(json_str_input in clob) return clob is
    v_parent_obj      json := json();
    v_parent_stmt     clob := q'[
      select codempid, numlvl, coduser
        from temploy1
       where codempid = :codempid
    ]';
    v_children_obj    json := json();
    v_child_obj       json := json();
    v_child_stmt      varchar2(32000 char) := q'[
      select dtework, typwork
        from tattence
       where codempid = :parent.codempid
         and coduser = :parent.coduser
         and rownum <= 10
    ]';

    json_str_output clob;
  begin
    initial_value(json_str_input);

    v_child_obj.put('stmt', v_child_stmt);
    v_child_obj.put('obj_type', 'record');

    v_children_obj.put('events', v_child_obj);

    bind(v_parent_stmt, ':codempid', global_v_codempid);
    v_parent_obj.put('stmt', v_parent_stmt);
    v_parent_obj.put('obj_type', 'record');
    v_parent_obj.put('children', v_children_obj);

    json_str_output := hcm_statement.execute_clob(v_parent_obj);

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    return json_str_output;
  end;

  function example6(json_str_input in clob) return clob is
    obj_row    json := json();
    v_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';

    json_str_output clob;
  begin
    initial_value(json_str_input);
    bind(v_stmt, ':codempid', global_v_codempid);

    obj_row := execute_obj(v_stmt);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

    return json_str_output;
  end;

  function example7(json_str_input in clob) return clob is
    v_stmt     clob := q'[
      select codempid, numlvl
        from temploy1
       where codempid = :codempid
    ]';
  begin
    initial_value(json_str_input);
    bind(v_stmt, ':codempid', global_v_codempid);
    return execute_clob(v_stmt);
  end;
END HCM_STATEMENT;

/
