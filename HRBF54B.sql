--------------------------------------------------------
--  DDL for Package HRBF54B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF54B" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 29/01/2021 15:01 redmine#4144
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


  p_codcomp                tloaninf.codcomp%type;
  p_typpayroll               temploy1.typpayroll%type;
  p_codempid                temploy1.codempid%type;
  p_numperiod               number;
  p_dtemthpay              number;
  p_dteyrepay               number;
  p_flgbonus                  varchar2(1 char);

  v_dtestrt                    date;
  v_dteend                    date;
  v_numrec	                number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);
  procedure get_tdtepay(json_str_input in clob, json_str_output out clob);

end HRBF54B;

/
