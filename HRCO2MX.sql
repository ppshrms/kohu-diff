--------------------------------------------------------
--  DDL for Package HRCO2MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2MX" as
  param_msg_error varchar2(4000 char);
  global_v_coduser varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang varchar2(10 char) := '102';

  p_routeno    twkflowd.routeno%type;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_route_detail(json_str_input in clob, json_str_output out clob);
    
end hrco2mx;

/
