--------------------------------------------------------
--  DDL for Package HRAPS7X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPS7X" is
-- last update: 18/09/2020 21:45
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

    b_index_codcomp         temploy1.codcomp%type;
    b_index_jobgrade        varchar2(100 char);
    b_index_amtsal_st       number;
    b_index_amtsal_en       number;
    b_index_amt_maxsal      number;
    p_rangeMax1   number;
    p_rangeMax2   number;
    p_rangeMax3   number;
    p_rangeMax4   number;
    p_rangeMax5   number;
    p_rangeMin1   number;
    p_rangeMin2   number;
    p_rangeMin3   number;
    p_rangeMin4   number;
    p_rangeMin5   number;
--#4233
    b_index_jobgrad2        varchar2(100 char);
    b_index_desgrad2        varchar2(500 char);
--#4233

--sann
p_ranksalmin number;
p_ranksalmax number;
--sann

  procedure initial_value(json_str in clob);
  procedure get_index1(json_str_input in clob, json_str_output out clob);
  procedure gen_data1(json_str in clob,json_str_output out clob);
  procedure get_index2(json_str_input in clob, json_str_output out clob);
  procedure gen_data2(json_str in clob, json_str_output out clob);
END; -- Package spec


/
