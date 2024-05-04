--------------------------------------------------------
--  DDL for Package HRRC1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC1FX" AS 

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  global_v_codempid         varchar2(100 char);

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  b_index_codcomp           temploy1.codcomp%type;
  b_index_numreqst          varchar2(1000 char);
  b_index_dtereqst          date;
  b_index_dtereqen          date;
  b_index_codpos            temploy1.codpos%type;
  v_data                    varchar2(10 char) := 'N';

  p_codapp                  varchar2(100 char) := 'HRRC1FX';

  isInsertReport            boolean := false;
  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure clear_ttemprpt;
  procedure get_report(json_str_input in clob,json_str_output out clob);
  procedure insert_ttemprpt_data(obj_data in json_object_t);
  procedure insert_ttemprpt_waiverint(obj_data in json_object_t);
  procedure insert_ttemprpt_waiverwrk(obj_data in json_object_t);
  function get_remark_detail (p_statappl in varchar2,p_codapp in varchar2) return json_object_t ;
  function gen_data return json_object_t;


END HRRC1FX;



/
