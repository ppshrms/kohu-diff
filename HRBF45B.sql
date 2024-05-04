--------------------------------------------------------
--  DDL for Package HRBF45B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF45B" as

/*
	code by 	     : User14/Krisanai Mokkapun
	modify        : 26/01/2021 17:30
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

  global_v_batch_codapp     varchar2(100 char)  := 'HRBF45B'; 
  global_v_batch_codalw     varchar2(100 char)  := 'HRBF45B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_filename   varchar2(100 char);
  global_v_batch_pathfile   varchar2(100 char);

  p_codcomp                 tcenter.codcomp%type; 
  p_typpayroll              temploy1.typpayroll%type;
  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_typcal                  varchar2(1 char);

  v_dtestrt                 date;
  v_dteend                  date;
  v_numrec	                number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);
--Redmine #5559
  procedure msg_err2(p_error in varchar2);
--Redmine #5559
end HRBF45B;

/
