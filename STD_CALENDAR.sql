--------------------------------------------------------
--  DDL for Package STD_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_CALENDAR" AS

  global_v_coduser        varchar2(100 char);
  global_v_codpswd        VARCHAR2(100 CHAR);
  global_v_lang           varchar2(10 char);
  global_v_zminlvl  		  number;
  global_v_zwrklvl  		  number;
  global_v_zyear          number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;

  --value
  obj_row                 json_object_t;
  obj_data                json_object_t;

  p_codempid              VARCHAR2(1000 CHAR);
  p_codempid_query        VARCHAR2(1000 CHAR);
  p_year                  NUMBER;
  p_codcomp               VARCHAR2(1000 CHAR);
  param_msg_error         varchar2(4000 char);

  PROCEDURE get_typwork(json_str_input IN CLOB, json_str_output out CLOB);

END STD_CALENDAR;

/
