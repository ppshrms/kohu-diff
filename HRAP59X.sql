--------------------------------------------------------
--  DDL for Package HRAP59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP59X" is
-- last update: 10/08/2020 13:45
    v_chken                 varchar2(100 char);
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);
    global_v_codpswd        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    b_index_dteyreap        varchar2(4000 char);
    b_index_numtime         varchar2(4000 char);
    b_index_codcomp         varchar2(4000 char);
    b_index_codbon          varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index1(json_str_input in clob, json_str_output out clob);
  procedure gen_data1(json_str_output out clob);
  procedure get_index2(json_str_input in clob, json_str_output out clob);
  procedure gen_data2(json_str_output out clob);
END; -- Package spec

/
