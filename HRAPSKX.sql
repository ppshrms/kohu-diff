--------------------------------------------------------
--  DDL for Package HRAPSKX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPSKX" is
-- last update: 26/08/2020 16:50
    v_chken                 varchar2(100 char);
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen 	number;
    global_v_codempid     varchar2(100 char);
    v_zupdsal               varchar2(4000 char);
    global_v_codpswd        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    v_numseq              number := 1;
    --index

    b_index_codcompy        varchar2(4000 char);
    b_index_dteyreap        varchar2(4000 char);
    b_index_numtime         varchar2(4000 char);
    b_index_stakpi          varchar2(4000 char);
    b_index_color           varchar2(4000 char);
    --screen
    b_index_codcomp         varchar2(4000 char);
    b_index_codkpino        varchar2(4000 char);
    b_index_kpides          varchar2(4000 char); ----
    
    p_index_rows            json_object_t;

  procedure initial_value(json_str in clob);
  procedure get_data1(json_str_input in clob, json_str_output out clob);
  procedure gen_data1(json_str_output out clob);
  procedure get_data2(json_str_input in clob, json_str_output out clob);
  procedure gen_data2(json_str_output out clob);
  procedure get_graph(json_str_input in clob, json_str_output out clob);
  procedure gen_graph;
  procedure get_report(json_str_input in clob, json_str_output out clob);
  procedure gen_report;
END; -- Package spec

/
