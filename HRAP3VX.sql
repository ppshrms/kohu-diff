--------------------------------------------------------
--  DDL for Package HRAP3VX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3VX" is
-- last update: 26/08/2020 16:50
    v_chken                 varchar2(100 char);
    param_msg_error         varchar2(4000 char);
    global_v_codempid       varchar2(100 char);
    global_v_coduser        varchar2(100 char);
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);
    global_v_codpswd        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    --index
    b_index_dteyreap        tkpiemp.dteyreap%type;
    b_index_numtime         tkpiemp.numtime%type;
    b_index_codcomp         tcenter.codcomp%type;
    b_index_codempid        temploy1.codempid%type;
    --screen
    b_index_codkpino        tkpiemp.codkpi%type;

    isInsertReport          boolean := false;
    p_codapp                varchar2(10 char) := 'HRAP3VX';

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_index_table(json_str_input in clob, json_str_output out clob);
  procedure gen_index_table(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_table(json_str_output out clob);
  procedure gen_report (json_str_input in clob,json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);
END; -- Package spec

/
