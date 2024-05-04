--------------------------------------------------------
--  DDL for Package HRES39X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES39X" as 

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  v_dteeffex                date;
  v_dteyrepay               ttaxcur.dteyrepay%TYPE;
  v_dtemthpay               ttaxcur.dtemthpay%TYPE;
  v_numperiod               ttaxcur.numperiod%TYPE;

  p_codempid                temploy1.codempid%type; 
  p_codcomp                 temploy1.codcomp%type; 
  p_codapp                  ttemprpt.codapp%type := 'HRES39X'; 

  p_intwno                  tresreq.intwno%type;
  p_dtereq                  tresreq.dtereq%type;
  p_numseq                  tresreq.numseq%type;

  v_numseq		              number := 0;
  numYearReport		          number := 0;

  procedure initial_value (json_str in clob);  
  --head info
  procedure get_emp_info (json_str_input in clob, json_str_output out clob);
  procedure vadidate_variable_get_emp_info(json_str_input in clob);
  procedure gen_emp_info (json_str_output out clob);
  -- tloaninf_info
  procedure get_tloaninf_info(json_str_input in clob, json_str_output out clob);
  procedure validate_tloaninf_info(json_str_input in clob);
  procedure gen_tloaninf_info( json_str_output out clob);
  -- trepay_info
  procedure get_trepay_info (json_str_input in clob, json_str_output out clob);
  procedure validate_trepay_info(json_str_input in clob);
  procedure gen_trepay_info (json_str_output out clob);
  --tfunddet_info
  procedure get_tfunddet_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tfunddet_info(json_str_input in clob);
  procedure gen_tfunddet_info ( json_str_output out clob);
  --tassets_info
  procedure get_tassets_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tassets_info(json_str_input in clob);
  procedure gen_tassets_info (json_str_output out clob);
end hres39x;

/
