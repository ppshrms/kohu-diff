--------------------------------------------------------
--  DDL for Package HRAL96E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL96E" is

  param_msg_error           varchar2(4000 char);

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
  global_v_zupdsal          varchar2(4 char);

  p_codapp                  varchar2(10 char) := 'HRAL96E';
  p_index_rows              varchar2(8 char);

  p_codcomp                 varchar2(1000 char);
  p_codempid                varchar2(1000 char);
  p_codaward                varchar2(1000 char);

  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;
  p_qtyaccaw                number;
  p_qtyoldacc               number;
  p_chkcodempid             boolean := false;
  p_dtecalc                 date;

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;
  procedure check_save_detail;
  procedure check_save_detail_table (p_flg varchar2);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure get_att_award(json_str_input in clob, json_str_output out clob);
  procedure gen_att_award(json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);

  procedure get_dtecalc(json_str_input in clob, json_str_output out clob);
  procedure gen_dtecalc(json_str_output out clob);

end HRAL96E;

/
