--------------------------------------------------------
--  DDL for Package Body HCM_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_FORMULA" as

  procedure initial_value(json_str_input in clob) as
    json_obj        json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_stmt              := hcm_util.get_string_t(json_obj,'p_stmt');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_execute_syntax as
  begin
    if p_stmt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;
  procedure get_execute_syntax(json_str_input in clob,json_str_output out clob) as
    -- unsolve problem in this procedure
    -- if we have had this kind of formula
    -- x/(y-z)   it will return error because this formula will be changed into (1)/((1)-(1))     = 1/0  cannot divide by zero error
    -- x/(y-z-a) it will return pass  because this formula will be changed into (1)/((1)-(1)-(1)) = 1/-1
    v_syntax    boolean;
    v_count     number;
    v_length    number;
    v_stmt      varchar2(4000 char);
    v_formula   varchar2(4000 char);
    v_codpay    varchar2(5 char);
    v_str       varchar2(4000 char);
  begin
    initial_value(json_str_input);
--    check_execute_syntax;
    if p_stmt is null then
      param_msg_error := get_error_msg_php('HR2820', global_v_lang, 'function.formula');
      json_str_output := get_response_message('200', param_msg_error, global_v_lang);
      return;
    end if;
    if param_msg_error is null then
      v_formula := p_stmt;
      v_length  := length(v_formula);
      v_stmt    := v_formula;
      v_stmt   := replace(v_stmt,'{[AMTHRS]}','(1)'); -- from {Hr}  to [AMTHRS]
      v_stmt   := replace(v_stmt,'{[AMTDAY]}','(1)'); -- from {Day} to [AMTDAY]
      v_stmt   := replace(v_stmt,'{[AMTMTH]}','(1)'); -- from {Mon} to [AMTMTH]
      v_stmt   := replace(v_stmt,'{[AMTSAL]}','(1)'); -- from {Mon} to [AMTSAL] demo hrap1ce
      v_stmt   := replace(v_stmt,'{[AMTMID]}','(1)'); -- from {Mon} to [AMTMID] demo hrap1ce
      v_stmt   := replace(v_stmt,'{[AMTINC]}','(1)'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_stmt   := replace(v_stmt,'{[AMTBASIC]}','(1)'); -- future plan
      v_stmt   := replace(v_stmt,'{[A]}','(1)'); -- Principal
      v_stmt   := replace(v_stmt,'{[R]}','(1)'); -- Interest
      v_stmt   := replace(v_stmt,'{[T]}','(1)'); -- Interest Period
      v_stmt   := replace(v_stmt,'{[P]}','(1)'); -- Remain Installments
      v_stmt   := replace(v_stmt,'{[AMOUNT]}','(1)'); -- AMOUNT
      v_stmt   := replace(v_stmt,'{[RATE]}','(1)'); -- RATE
      v_stmt   := replace(v_stmt,'{[AMTOVER]}','(1)'); -- Over Amount
      v_stmt   := replace(v_stmt,'{[SOC]}','(1)'); -- Social Security
      v_stmt   := replace(v_stmt,'{[PVF]}','(1)'); -- Provident Fund
      v_stmt   := replace(v_stmt,'?','*');
      v_stmt   := replace(v_stmt,'?','/');
      -- replace from table
      v_stmt   := replace_statement(v_stmt, '{&', '}',  'tinexinf',  'codpay');
      v_stmt   := replace_statement(v_stmt, '{[', ']}', 'tcodeduct', 'coddeduct');

      -- replace [itemX]
      -- X is number more than 1
      v_stmt   := regexp_replace(v_stmt,'{item[1-9][0-9]{0,}}','(1)');
      begin
        execute immediate 'select '||v_stmt||' from dual' into v_count;
        v_syntax := true;
      exception when others then
        v_syntax := false;
      end;
      if not v_syntax then
        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2820',global_v_lang,'function.formula');
        json_str_output := get_response_message('200',param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_execute_syntax;

  function replace_statement(v_stmt       varchar2,v_prefix     varchar2,v_suffix     varchar2,
                             v_table_name varchar2,v_field_name varchar2,v_replace_to varchar2 default '(1)') return varchar2 as
    v_cursor_id      integer;
    v_col            number;
    v_desctab        dbms_sql.desc_tab;
    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;

    v_new_stmt  varchar2(4000 char);
  	v_statement varchar2(4000 char);
  	v_field     varchar2(4000 char);
  begin
    v_new_stmt := v_stmt;

    -- initial cursor
    v_statement := 'select ' || v_field_name || ' from ' || v_table_name;
    v_cursor_id := dbms_sql.open_cursor;
    dbms_output.put_line(v_cursor_id);
    dbms_sql.parse(v_cursor_id, v_statement, dbms_sql.native);
    dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);

    -- set data type
    for i in 1 .. v_col loop
      if v_desctab(i).col_type = 1 then
        dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
      elsif v_desctab(i).col_type = 2 then
        dbms_sql.define_column(v_cursor_id, i, v_number);
      elsif v_desctab(i).col_type = 12 then
        dbms_sql.define_column(v_cursor_id, i, v_date);
      end if;
    end loop;

    -- fetch cursor
    v_fetch := dbms_sql.execute(v_cursor_id);
    while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
      for i in 1 .. v_col loop
        if (v_desctab(i).col_name = upper(v_field_name)) then
          dbms_sql.column_value(v_cursor_id, i, v_field);
          v_new_stmt := replace(v_new_stmt,v_prefix || v_field || v_suffix,v_replace_to);
        end if;
      end loop;
    end loop;

    -- close cursor & return
    dbms_sql.close_cursor(v_cursor_id);
    return v_new_stmt;
  exception when others then
    -- error
    if dbms_sql.is_open(v_cursor_id) then
        dbms_sql.close_cursor(v_cursor_id);
    end if;
    return null;
  end replace_statement;

  function replace_statement_desc (v_stmt varchar2, v_prefix varchar2, v_suffix varchar2, v_table_name varchar2, v_field_name varchar2, v_desc_name varchar2, p_lang varchar2) return varchar2 as
    v_cursor_id      integer;
    v_col            number;
    v_desctab        dbms_sql.desc_tab;
    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;

    v_new_stmt       varchar2(4000 char);
  	v_statement      varchar2(4000 char);
  	v_field          varchar2(100 char);
  	v_code           varchar2(100 char);
    v_regexp         varchar2(100 char);
  	v_code_replace   varchar2(100 char);
    v_replace_succ   varchar2(1);
  begin
    v_new_stmt := v_stmt;
    v_regexp   := v_prefix || '(\w+)' || v_suffix;
--    v_regexp   := '(\w+)';
    v_code_replace := v_new_stmt;
    while regexp_substr(v_code_replace, v_regexp) is not null loop
      v_code_replace := regexp_substr(v_code_replace, v_regexp);
      v_code := regexp_substr(v_code_replace, '(\w+)');
      -- initial cursor
      v_statement := 'select decode(''' || p_lang || ''', ''101'', ' || v_desc_name || 'e,
                                                          ''102'', ' || v_desc_name || 't,
                                                          ''103'', ' || v_desc_name || '3,
                                                          ''104'', ' || v_desc_name || '4,
                                                          ''105'', ' || v_desc_name || '5, ' || v_desc_name || 'e) as ' || v_desc_name
                      || '  from ' || v_table_name
                      || ' where ' || v_field_name || ' = ''' || v_code || '''';
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_statement, dbms_sql.native);
      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);

      -- set data type
      for i in 1 .. v_col loop
        if v_desctab(i).col_type = 1 then
          dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
        elsif v_desctab(i).col_type = 2 then
          dbms_sql.define_column(v_cursor_id, i, v_number);
        elsif v_desctab(i).col_type = 12 then
          dbms_sql.define_column(v_cursor_id, i, v_date);
        end if;
      end loop;

      -- fetch cursor
      v_fetch := dbms_sql.execute(v_cursor_id);
      v_replace_succ := 'N';
      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        for i in 1 .. v_col loop
          if (v_desctab(i).col_name = upper(v_desc_name)) then
            dbms_sql.column_value(v_cursor_id, i, v_field);
            v_new_stmt := replace(v_new_stmt, v_code_replace, '{' || v_field || '}');
            v_replace_succ := 'Y';
          end if;
        end loop;
      end loop;
      if v_replace_succ = 'N' then
        v_new_stmt := replace(v_new_stmt, v_code_replace, 'DescNull');
      end if;
      v_code_replace := v_new_stmt;
      -- close cursor & return
      dbms_sql.close_cursor(v_cursor_id);
    end loop;
    return v_new_stmt;
  exception when others then
    -- error
    if dbms_sql.is_open(v_cursor_id) then
        dbms_sql.close_cursor(v_cursor_id);
    end if;
    return null;
  end replace_statement_desc;

  function get_description (v_stmt varchar2, p_lang varchar2) return varchar2 as
    v_count     number;
    v_length    number;
    v_new_stmt  varchar2(4000 char);
  begin
    v_new_stmt := v_stmt;
    if param_msg_error is null then
      v_length     := length(v_new_stmt);
      v_new_stmt   := replace(v_new_stmt, '{[AMTHRS]}',   '{' || get_label_name('STDFORMULA', p_lang, '30') || '}'); -- from {Hr}  to [AMTHRS]
      v_new_stmt   := replace(v_new_stmt, '{[AMTDAY]}',   '{' || get_label_name('STDFORMULA', p_lang, '40') || '}'); -- from {Day} to [AMTDAY]
      v_new_stmt   := replace(v_new_stmt, '{[AMTMTH]}',   '{' || get_label_name('STDFORMULA', p_lang, '50') || '}'); -- from {Mon} to [AMTMTH]
      v_new_stmt   := replace(v_new_stmt, '{[AMTSAL]}',   '{' || get_label_name('STDFORMULA', p_lang, '90') || '}'); -- from {Mon} to [AMTSAL] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[AMTMID]}',   '{' || get_label_name('STDFORMULA', p_lang, '100') || '}'); -- from {Mon} to [AMTMID] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[AMTINC]}',   '{' || get_label_name('STDFORMULA', p_lang, '110') || '}'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[A]}',   '{' || get_label_name('STDFORMULA', p_lang, '120') || '}'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[R]}',   '{' || get_label_name('STDFORMULA', p_lang, '130') || '}'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[T]}',   '{' || get_label_name('STDFORMULA', p_lang, '140') || '}'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[P]}',   '{' || get_label_name('STDFORMULA', p_lang, '150') || '}'); -- from {Mon} to [AMTINC] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[AMOUNT]}',   '{' || get_label_name('STDFORMULA', p_lang, '160') || '}'); -- from {Mon} to [AMOUNT] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[RATE]}',   '{' || get_label_name('STDFORMULA', p_lang, '170') || '}'); -- from {Mon} to [RATE] demo hrap1ce
      v_new_stmt   := replace(v_new_stmt, '{[AMTOVER]}',   '{' || get_label_name('STDFORMULA', p_lang, '180') || '}'); -- from {Mon} to [AMTOVER] demo hrap62e
      v_new_stmt   := replace(v_new_stmt, '{[SOC]}',   '{' || get_label_name('STDFORMULA', p_lang, '190') || '}'); -- from {Mon} to [SOC] demo hrpy96r
      v_new_stmt   := replace(v_new_stmt, '{[PVF]}',   '{' || get_label_name('STDFORMULA', p_lang, '200') || '}'); -- from {Mon} to [PVF] demo hrpy96r
      v_new_stmt   := replace(v_new_stmt, '{[AMTBASIC]}', '(1)'); -- future plan
      v_new_stmt   := replace(v_new_stmt, '*', to_char(CHR(50071)));
      v_new_stmt   := replace(v_new_stmt, '/', to_char(CHR(50103)));
      -- replace from table
      v_new_stmt   := replace_statement_desc(v_new_stmt, '{&', '}',  'tinexinf' , 'codpay',    'descpay', p_lang);
      v_new_stmt   := replace_statement_desc(v_new_stmt, '{[', ']}', 'tcodeduct', 'coddeduct', 'descnam', p_lang);

      -- replace [itemX]
      -- X is number more than 1
      v_new_stmt   := regexp_replace(v_new_stmt,'{item[1-9][0-9]{0,}}','(1)');
    end if;
    return v_new_stmt;
  end get_description;
end hcm_formula;

/
