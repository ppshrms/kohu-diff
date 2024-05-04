--------------------------------------------------------
--  DDL for Package HCM_STATEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_STATEMENT" AS
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  global_v_zminlvl  	  number;
  global_v_zwrklvl  	  number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal   		      varchar2(4 char);

  -- p_type varchar2 ex. 'varchar2' (default), 'number', 'date', 'datetime', 'boolean'
  procedure bind(p_stmt in out clob, p_key_bind in varchar2, p_val_bind in varchar2, p_type in clob default 'varchar2');

  /* p_obj key
       1. stmt clob (require) ex. 'select * from temploy1 where codempid = '53100' ',
       2. children json (optional) ex. {"child1": [object_child1], "child2": [object_child2]},
       3. obj_type varchar2 ex. 'record', 'table' (default)
     p_flg_parent is flg to determine that p_obj is parent for generate key coderror to parent obj
  */
  function execute_clob(p_obj json, p_flg_parent boolean default true) return clob;
  function execute_obj(p_obj json, p_flg_parent boolean default true) return json;
  function execute_obj_t(p_obj json_object_t, p_flg_parent boolean default true) return json_object_t;

  -- p_obj_type varchar2 ex. 'record', 'table' (default)
  function execute_clob(p_stmt clob, p_obj_type varchar2 default 'table') return clob;
  function execute_obj(p_stmt clob, p_obj_type varchar2 default 'table') return json;
  function execute_obj_t(p_stmt clob, p_obj_type varchar2 default 'table') return json_object_t;

  /*
    json_str_input := '{"p_codempid":"53100"}';
    select hcm_statement.exampleXX(json_str_input) from dual;
  */
  function example1(json_str_input in clob) return clob;
  function example2(json_str_input in clob) return clob;
  function example3(json_str_input in clob) return clob;
  function example4(json_str_input in clob) return clob;
  function example5(json_str_input in clob) return clob;
  function example6(json_str_input in clob) return clob;

END HCM_STATEMENT;

/
