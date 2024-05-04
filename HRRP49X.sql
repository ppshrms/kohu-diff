--------------------------------------------------------
--  DDL for Package HRRP49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP49X" is

  param_msg_error           varchar2(4000 char);

  p_codapp                  varchar2(10 char) := 'HRRP49X';
  p_codcompy                tposplnd.codcompy%type;
  p_numpath                 tposplnd.numpath%type;
  p_dteeffec                thisorg.dteeffec%type;

  p_numseq                  tposplnd.numseq%type;
  p_codpos                  tposplnd.codpos%type;
  p_codcomp                 tposplnd.codcomp%type;
  p_agework                 tposplnd.agework%type;
  p_agepos                  tposplnd.agepos%type;
  p_codlinef                tposplnd.codlinef%type;
  p_othdetail               tposplnd.othdetail%type;
  p_month                   number;
  p_year                    number;

  p_despath                 tposplnh.despathe%type;
  p_despathe                tposplnh.despathe%type;
  p_despatht                tposplnh.despatht%type;
  p_despath3                tposplnh.despath3%type;
  p_despath4                tposplnh.despath4%type;
  p_despath5                tposplnh.despath5%type;
  p_table                   json_object_t;
  p_flgCount                number;
  searchIndex               json_object_t;

  p_codcompy_query          tposplnd.codcompy%type;
  p_numpath_query           tposplnd.numpath%type;
  p_codcomp_query           tposplnd.codcomp%type;
  p_codpos_query            tposplnd.codpos%type;

  json_obj    json_object_t;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure gen_numpath;

  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_career_path (json_str_input in clob,json_str_output out clob);
  procedure get_career_path_table (json_str_input in clob,json_str_output out clob);
  procedure get_career_path_name (json_str_input in clob,json_str_output out clob);


end hrrp49x;

/
