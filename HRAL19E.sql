--------------------------------------------------------
--  DDL for Package HRAL19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL19E" is
-- last update: 20/11/2017 11:19

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_codcompy                varchar2(100 char);
  p_year                    number;
  p_codcompy_clone          varchar2(100 char);
  p_year_clone              number;
  p_dtestrt                 date;
  p_dteend                  date;
  p_dtestrto                 date;
  p_dteendo                  date;
  p_typwork                 varchar2(4000 char);
  p_desholdy                varchar2(4000 char);
  p_desholdye               varchar2(4000 char);
  p_desholdyt               varchar2(4000 char);
  p_desholdy3               varchar2(4000 char);
  p_desholdy4               varchar2(4000 char);
  p_desholdy5               varchar2(4000 char);
  p_flgdelete               varchar2(10 char);

  procedure get_holiday(json_str_input in clob, json_str_output out clob);
  procedure gen_holiday(json_str_output out clob);

  procedure set_holiday(json_str_input in clob, json_str_output out clob);

  procedure get_list_codcompy(json_str_input in clob, json_str_output out clob);
  procedure gen_list_codcompy(json_str_output out clob);

  procedure set_clone_codcompy(json_str_input in clob, json_str_output out clob);

end HRAL19E;

/
