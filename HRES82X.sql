--------------------------------------------------------
--  DDL for Package HRES82X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES82X" AS

  param_msg_error     varchar2(4000 char);
  v_chken             varchar2(10 char);

  -- global var
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_codempid         varchar2(100 char);

  v_zyear           number;
--  b_index_codempid  varchar2(4000 char);
--  p_start           number;
--  p_end             number;
  b_dteyrepay       number;
  b_dtemthpay       number;
  b_numperiod       number;
  b_codcompy        varchar(1000 char);

  p_amtincom			number;
  p_amtsalyr			number;
  p_amtproyr			number;
  p_amtsocyr			number;
  p_amtnet			  number;


  v_view_codapp     varchar2(100 char);
  v_view_codapp_tab1_table1          varchar2(100 char);
  v_view_codapp_tab3_table1          varchar2(100 char);
  v_view_codapp_tab4_table1          varchar2(100 char);
  v_view_codapp_tab5_table1          varchar2(100 char);

  procedure initial_value(json_str in clob);
  --Code Tab1 Detail
  procedure gen_tab1_detail(json_str_input in clob, json_str_output out clob);

  -- Code TAB2_TABLE2
  procedure get_index_tab1_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab1_table1(json_str_output out clob);

  function gtempded (v_empid varchar2, 
                      v_codeduct    varchar2,
                      v_type        varchar2,
                      v_amtcode     number,
                      p_amtsalyr 	number) return number;
  FUNCTION get_deduct(v_codeduct varchar2) RETURN char;

  -- Code TAB3_TABLE1
  procedure get_index_tab3_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab3_table1(json_str_output out clob);

  -- Code TAB4_TABLE1
  procedure get_index_tab4_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab4_table1(json_str_output out clob);

  -- Code TAB5_TABLE1
  procedure get_index_tab5_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab5_table1(json_str_output out clob);


END HRES82X;

/
