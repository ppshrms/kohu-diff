--------------------------------------------------------
--  DDL for Package HRAL73X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL73X" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			    varchar2(4 char);
  global_v_codcurr      varchar2(100 char);
  global_chken          varchar2(100 char);

  p_codapp              varchar2(10 char) := 'HRAL73X';
  p_index_rows          varchar2(8 char);

  p_codempid            varchar2(100 char);
  p_codcomp             varchar2(100 char);
  p_typpayroll          varchar2(10 char);
  p_numperiod           number;
  p_dtemthpay           number;
  p_dteyrepay           number;
  p_codcompy            varchar2(100 char);
  p_report              varchar2(1 char);
  p_codpay              tpaysum.codpay%type;
  p_codalw              tpaysum.codalw%type;

  v_codcomp             varchar2(100 char);
  v_typpayroll          varchar2(10 char);
  v_codpay              varchar2(100 char);
  v_dteeffec            date;
  v_qtyhrs              varchar2(10 char); --???????. (OT)
  v_amount              number; --????????? (OT)
  v_flgbrk              number;
  v_codalw              varchar2(100 char);
  v_total               varchar2(1000 char);
  v_desctotal           varchar2(1000 char);

  p_breaklevel1         boolean := false;
  p_breaklevel2         boolean := false;
  p_breaklevel3         boolean := false;
  p_breaklevel4         boolean := false;
  p_breaklevel5         boolean := false;
  p_breaklevel6         boolean := false;
  p_breaklevel7         boolean := false;
  p_breaklevel8         boolean := false;
  p_breaklevel9         boolean := false;
  p_breaklevel10        boolean := false;
  p_breaklevelAll       boolean := false; -- summary

  p_qtymin1          number := 0;
	p_amtpay1          number := 0;
	p_qtymin2          number := 0;
	p_amtpay2          number := 0;
	p_qtymin3          number := 0;
	p_amtpay3          number := 0;
	p_qtymin4          number := 0;
	p_amtpay4          number := 0;
	p_qtymin5          number := 0;
	p_amtpay5          number := 0;
	p_qtymin6          number := 0;
	p_amtpay6          number := 0;
	p_qtymin7          number := 0;
	p_amtpay7          number := 0;
	p_qtymin8          number := 0;
	p_amtpay8          number := 0;
	p_qtymin9          number := 0;
	p_amtpay9          number := 0;
	p_qtymin10         number := 0;
	p_amtpay10         number := 0;
	p_qtyminCodempid   number := 0;
	p_amtpayCodempid   number := 0;

  json_index_rows     json_object_t;
  isInsertReport      boolean := false;

  json_param_break        json_object_t;
  json_param_json         json_object_t;
  json_break_output       json_object_t;
  json_break_output_row   json_object_t;
  json_break_params       json_object_t;

  type a_string is table of varchar2(1000 char) index by binary_integer;
    v_chklvl  	a_string;
    v_lvl   		a_string;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure gen_detail_ot(json_str_output out clob);
  procedure gen_detail_summary(json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_head(obj_data in json_object_t);
  procedure insert_ttemprpt_ot(obj_data in json_object_t);
  procedure insert_ttemprpt_summary(obj_data in json_object_t);
  procedure insert_ttemprpt(obj_data in json_object_t);

  procedure get_breaklevel (json_str_input in clob,json_str_output out clob);
end HRAL73X;

/
