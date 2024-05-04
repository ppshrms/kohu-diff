--------------------------------------------------------
--  DDL for Package HRPM4IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4IE" is
--21/08/2019
 param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  v_mode                    varchar2(1 char);
  v_codapp                  varchar2(10 char);
  p_detail                  clob;
  obj_detail                json_object_t;
  p_codempid                temploy1.codempid%type;
  p_dteeffec                date;
  p_dteeffec_o              date;
  p_codexemp                tcodexem.codcodec%type;
  p_numexemp                ttexempt.numexemp%type;
  p_desnote                 ttexempt.desnote%type;
  p_flgblist                ttexempt.flgblist%type;
  p_flgssm                  ttexempt.flgssm%type;
  p_dteinput                date;
  p_codreq                  ttexempt.codreq%type;
  p_codcomp                 temploy1.codcomp%type;
  p_staupd                  ttexempt.staupd%type;

  v_staemp                  temploy1.staemp%type;
  v_dteyrepay               ttaxcur.dteyrepay%TYPE;
  v_dtemthpay               ttaxcur.dtemthpay%TYPE;
  v_numperiod               ttaxcur.numperiod%TYPE;

  v_codcomp                 ttexempt.codcomp%type;
  errormsg                  varchar2(4000 char);
  v_rowid                   rowId;

  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure vadidate_variable_getindex(json_str_input in clob) ;

  procedure post_save (json_str_input in clob, json_str_output out clob);
  procedure save_data_main;
  procedure validate_post_save(json_str_input in clob);

  procedure post_deldata(json_str_input in clob,json_str_output out clob);
  procedure deldata(json_str_output out clob);
  procedure validate_deldata(json_str_input in clob);

  procedure validate_send_mail(json_str_input in clob);
  procedure send_mail(json_str_input in clob,json_str_output out clob);
  procedure post_send_mail(json_str_input in clob, json_str_output out clob);

  function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2;
  function get_format_updatebycodempname (v_coduser in varchar2 , v_lang in varchar2) return  varchar2;
  function get_error_choose(v_error_2101 in varchar2,v_push_error in varchar2,v_lang in varchar2)  return varchar2;
end HRPM4IE;

/
