--------------------------------------------------------
--  DDL for Package HRRP23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP23E" is

  param_msg_error           varchar2(4000 char);
  param_msg_error_mail      varchar2(4000 char);

  b_index_dteyrbug          tbudget.dteyrbug%type;
  b_index_codcomp           tbudget.codcomp%type;
  b_index_dtereq            tbudget.dtereq%type;
  b_index_codemprq          tbudget.codemprq%type;
  b_index_codpos            tbudget.codpos%type;

  p_qtynewn                 tbudget.qtyreqyr%type;
  p_qtypromoten             tbudget.qtypromote%type;
  p_qtyretin                tbudget.qtyreti%type;
  p_qtybudgtn               tbudget.qtybudgt%type;
  p_remarkrq                tbudget.remarkrq%type;
  p_newsalary               tbudget.amtnewsal%type;
  p_avgsalary               tbudget.amtavgsal%type;
  p_promsalary              tbudget.amtprosal%type;
  p_other                   tbudget.amtothbudgt%type;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_qtyexman           number;

  type data_error is table of varchar2(4000 char) index by binary_integer;
  p_text        data_error;
  p_error_code  data_error;
  p_numseq      data_error;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_tab1_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_detail(json_str_output out clob);

  procedure get_tab2_table(json_str_input in clob, json_str_output out clob);
  procedure gen_tab2_table(json_str_output out clob);

  procedure get_tab3_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab3_detail(json_str_output out clob);
--
  procedure get_tab3_table(json_str_input in clob, json_str_output out clob);
  procedure gen_tab3_table(json_str_output out clob);

  procedure delete_index(json_str_input in clob, json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);

  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);

  procedure send_mail_to_approve(para_dteyrbug   tbudget.dteyrbug%type,
                                 para_codcomp    tbudget.codcomp%type,
                                 para_codpos     tbudget.codpos%type,
                                 para_dtereq     tbudget.dtereq%type);
end hrrp23e;

/
