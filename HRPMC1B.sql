--------------------------------------------------------
--  DDL for Package HRPMC1B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC1B" is
  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(1);

  b_index_dteimpot        date;
  b_index_typimpot        varchar2(200);
  b_index_codimpot        varchar2(200);
  b_index_filename        varchar2(200);

  v_rec_error             number  := 0;
  v_rec_tran              number  := 0;
  v_total                 number  := 0;
  v_pkey                  varchar2(500);
  type text is table of varchar2(4000) index by binary_integer;
    v_column 	text;
    v_head  	text;
    v_text  	text;

  type rec_text is table of text index by binary_integer;
    v_rec_text    rec_text;

  procedure initial_value (json_str in clob);
  procedure submit_data (json_str_input in clob, json_str_output out clob);
  procedure process_data (json_str_input in clob, json_str_output out clob);
end HRPMC1B;

/
