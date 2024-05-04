--------------------------------------------------------
--  DDL for Package HCM_LOV_CODCOMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_CODCOMP" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
--  function get_codcomp(json_str_input in clob) return clob;             --LOV for All cocomp (NEW LOVs)
--  function get_type_codcomp(json_str_input in clob) return T_LOV;             --LOV for All cocomp (NEW LOVs)
  function get_codcomp_new(json_str_input in clob) return T_LOV;
  function get_comp_level_name(p_codcompy varchar2, p_level number) return varchar2;
end;

/
