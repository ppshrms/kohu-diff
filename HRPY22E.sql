--------------------------------------------------------
--  DDL for Package HRPY22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY22E" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_numperiod           totsum.numperiod%type;
  p_month               totsum.dtemthpay%type;
  p_year                totsum.dteyrepay%type;
  p_codcomp             tcenter.codcomp%type;
  p_codcompw            totsumd.codcompw%type;
  p_qtysmot             totsum.qtysmot%type;
  p_amtottot            totsum.amtottot%type;
  p_typpayroll          temploy1.typpayroll%type;
  p_codempid            temploy1.codempid%type;
  param_json            json_object_t;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure check_detail;
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_table (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_table (json_str_output out clob);

  procedure check_save_index;
  procedure post_save_index (json_str_input in clob, json_str_output out clob);
  procedure save_index (json_str_output out clob);

  procedure check_save_detail;
  procedure post_save_detail (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_output out clob);

  procedure insert_totsum (v_codempid in varchar2, v_numperiod in varchar2, v_month in varchar2, v_year in varchar2, v_costcent varchar2 default null);
  procedure delete_totsumd (v_codempid in varchar2, v_numperiod in varchar2, v_month in varchar2, v_year in varchar2, v_rtesmot in varchar2, v_codcompw in varchar2);
  procedure delete_totsum (v_codempid in varchar2, v_numperiod in varchar2, v_month in varchar2, v_year in varchar2);
  procedure update_totsum;

   procedure get_codcompw (json_str_input in clob, json_str_output out clob);

end hrpy22e;

/
