--------------------------------------------------------
--  DDL for Package HRPY5AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5AE" as
  -->>30/07/2020<<--
  --para
  param_msg_error       varchar2(600);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codpswd      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;

  p_codcomp             tcenter.codcomp%type;
  p_codempid_query      temploy1.codempid%type;
  p_dtemthpay           tloanslf.dtemthpay%type;
  p_dteyrepay           tloanslf.dteyrepay%type;

  type text is table of varchar2(4000) index by binary_integer;
    v_column 	text;
    v_head  	text;
    v_text  	text;

  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure save_data(json_str_input in clob,json_str_output out clob);
  procedure submit_import (json_str_input in clob, json_str_output out clob);
  procedure process_import (json_str_input in clob, json_str_output out clob);
end;

/
