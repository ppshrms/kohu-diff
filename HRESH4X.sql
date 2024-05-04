--------------------------------------------------------
--  DDL for Package HRESH4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESH4X" is
-- last update: 15/04/2019 14:08
  param_msg_error       varchar2(4000 char);

  global_v_chken        varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear               number;
  global_v_codempid     varchar2(100 char);
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_codcomp      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(10 char);

  b_index_codempid      varchar2(4000 char);
  b_index_stdate        date;
  b_index_endate        date;
  p_module              varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  function get_wage_income_func(  p_codempid  in varchar2,
                                  p_amt1      in varchar2,
                                  p_amt2      in varchar2,
                                  p_amt3      in varchar2,
                                  p_amt4      in varchar2,
                                  p_amt5      in varchar2,
                                  p_amt6      in varchar2,
                                  p_amt7      in varchar2,
                                  p_amt8      in varchar2,
                                  p_amt9      in varchar2,
                                  p_amt10     in varchar2) return number;

end; -- Package spec

/
