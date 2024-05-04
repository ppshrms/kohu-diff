--------------------------------------------------------
--  DDL for Package HRBF1PD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1PD" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 13/09/2021 16:01
*/

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRBF1PD';
  global_v_batch_codalw     varchar2(100 char)  := 'HRBF1PD';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codcomp                 tcenter.codcomp%type;
  p_typpayroll                temploy1.typpayroll%type;
  p_codempid                temploy1.codempid%type;
  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_typcal                  varchar2(1 char);

  v_dtestrt                 date;
  v_dteend                  date;
  v_numrec	                number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);
  procedure process_trepay (p_numrec in out number, p_numerr in out number,p_dteend in out date) ;

end HRBF1PD;

/
