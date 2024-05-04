--------------------------------------------------------
--  DDL for Package Body HCM_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_SERVICE" is

  function get_numseq(json_str in clob) return varchar2 is
    json_obj        json;
    p_table         varchar2(1000 char);
    p_coldtereq     varchar2(5000 char);
    p_colseqno      varchar2(1000 char);
    p_codempid      varchar2(1000 char);

    v_cursor			  number;
		v_dummy         integer;
		v_stmt			    varchar2(5000 char);
    v_numseq        varchar2(5000 char) := '0';

  begin
    json_obj              := json(json_str);
    global_v_coduser      := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang         := json_ext.get_string(json_obj,'p_lang');
    p_table               := json_ext.get_string(json_obj,'p_table');
    p_coldtereq           := json_ext.get_string(json_obj,'p_coldtereq');
    p_colseqno            := json_ext.get_string(json_obj,'p_colseqno');
    p_codempid            := json_ext.get_string(json_obj,'p_codempid');

    v_stmt := ' select nvl(max('||p_colseqno||'),0)
                from '||p_table||'
                where codempid = '''||p_codempid||'''
                and '||p_coldtereq||' = trunc(sysdate)';
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_numseq,1000);
    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_numseq);
    end loop; -- end while

    v_numseq := to_char(to_number(v_numseq) + 1);
    return v_numseq;

  exception when others then
    return sqlerrm;
  end get_numseq;
  --
  function get_empname(json_str in clob) return varchar2 is
      v_empname     varchar2(100 char) :=' ';
      v_codempid    temploy1.codempid%type;
      json_obj      json;
      resp_json_obj json;
  begin
      json_obj              := json(json_str);
      global_v_coduser      := json_ext.get_string(json_obj,'p_coduser');
      global_v_lang         := json_ext.get_string(json_obj,'p_lang');
      v_codempid            := json_ext.get_string(json_obj,'p_codempid');

      begin
        select get_temploy_name(v_codempid,global_v_lang)
          into v_empname
          from dual;
      exception when no_data_found then
        v_empname := '';
      end;

      return v_empname;
  end get_empname;
  --

end;

/
