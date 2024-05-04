--------------------------------------------------------
--  DDL for Package HRCO2KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2KE" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_codapp                  VARCHAR2(10 CHAR);  --???????????
  p_codempid_query          VARCHAR2(10 CHAR);  --???????????
  p_codcomp                 VARCHAR2(40 char);  --????????
  p_codpos                  VARCHAR2(4 CHAR);   --???????
  p_routeno                 VARCHAR2(10 CHAR);
  p_dtecreate               DATE;
  p_codcreate               VARCHAR2(50 CHAR);
  p_dteupd                  DATE;
  p_coduser                 VARCHAR2(50 CHAR);

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure edit_temproute(json_str_input in clob, json_str_output out clob);

end HRCO2KE;

/
