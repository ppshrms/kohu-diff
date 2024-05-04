--------------------------------------------------------
--  DDL for Package HRCO34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO34E" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  params_json               json_object_t;
  p_errorno                 terrorm.errorno%type;
  p_errortyp                terrorm.errortyp%type;
  p_descrip                 terrorm.descripe%type;
  p_descripe                terrorm.descripe%type;
  p_descript                terrorm.descript%type;
  p_descrip3                terrorm.descrip3%type;
  p_descrip4                terrorm.descrip4%type;
  p_descrip5                terrorm.descrip5%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure post_save (json_str_input in clob, json_str_output out clob);
  procedure save_data;
  procedure get_typeauth (json_str_input in clob, json_str_output out clob);
END HRCO34E;

/
