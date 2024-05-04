--------------------------------------------------------
--  DDL for Package HRBF1OX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1OX" is
-- last update: 28/11/2022 10:16
-- last update: 31/08/2020 18:16

  v_chken      varchar2(100 char);

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  p_datarows                json_object_t;
  obj_row                   json_object_t;

  v_codapp                  tprocapp.codapp%type:= 'HRBF1OX';
  v_numseq                  number := 0;

  b_index_codcomp           temploy1.codcomp%type;
  b_index_codempid          temploy1.codempid%type;
  b_index_dtestr            date;
  b_index_dteend            date;
  b_index_typbf1ox          varchar2(1);

  v_rowid_query             rowid;
  p_numvcher_query          tclnsinf.numvcher%type;

  --> Peerasak || Issue#8700 || 25/11/2022
  p_payment_voucher         varchar2(1 char);
  p_paymentstrt             date;
  p_paymentend              date;
  --> Peerasak || Issue#8700 || 25/11/2022

  procedure initial_value(json_str in clob);
--show data
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure gen_data2 (json_str_output out clob);
  procedure gen_data3 (json_str_output out clob);
  procedure gen_numpaymt(json_str_input in clob, json_str_output out clob);
--report
  procedure clear_ttemprpt;
  procedure initial_report(json_str in clob);
  procedure gen_report(json_str_input in clob,json_str_output out clob);
  procedure check_vouchernumber(json_str_input in clob,json_str_output out clob);
  procedure InsertTmpVoucher(json_str_input in clob,json_str_output out clob);
  procedure insert_report (json_str_output out clob) ;
--send mail
  procedure send_mailemp(json_str_input in clob, json_str_output out clob) ;

END; -- Package spec

/
