--------------------------------------------------------
--  DDL for Package HRAP5AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP5AB" AS 

  v_chken               varchar2(10 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			varchar2(4 char);
  global_v_codcurr      varchar2(100 char);

  b_index_dteyreap      number;
  b_index_numtime       number;
  b_index_codcomp       temploy1.codcomp%type;  
  b_index_codcompy      tcompny.codcompy%type; 
  b_index_codbon        tbonus.codcomp%type;  

  p_codempid            temploy1.codempid%type; 
  p_codcomp             temploy1.codcomp%type; 
  p_typpayroll          temploy1.typpayroll%type; 
  p_codbon              tbonus.codbon%type; 
  p_codpay              tsincexp.codpay%type; 
  p_numperiod           number;
  p_dtemthpay           number;
  p_dteyrepay           number;
  p_codcompy            tcompny.codcompy%type; 

  p_numemp              number;
  p_amtbon              number;

  procedure initial_value(json_str in clob) ;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob) ;
  procedure post_transfer_data (json_str_input in clob, json_str_output out clob);
  procedure transfer_data;

  procedure ins_tothinc (v_codempid   in temploy1.codempid%type,
                         v_dteyrepay  in tothinc.dteyrepay%type,
                         v_dtemthpay  in tothinc.dtemthpay%type,
                         v_numperiod  in tothinc.numperiod%type,
                         v_codpay     in tothinc.codpay%type,
                         v_codcomp	  in tothinc.codcomp%type,
                         v_typpayroll in tothinc.typpayroll%type,
                         v_amtnbon     in tothinc.amtpay%type) ;

END HRAP5AB;

/
