--------------------------------------------------------
--  DDL for Package HRCO41D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO41D" is
-- last update: 19/03/2021 20:15 Error Program #5081
  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params       json;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codempid        varchar2(100 char);
  p_codcompy        varchar2(100 char);
  p_codcomp         varchar2(100 char);
  p_codsys          varchar2(100 char);


  procedure get_tcontdel_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tcontdel_index (json_str_output out clob) ;
  procedure condel_tdeltblh_index (json_str_input in clob, json_str_output out clob) ;

end HRCO41D;

/
