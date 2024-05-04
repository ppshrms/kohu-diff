--------------------------------------------------------
--  DDL for Package HRTR6BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6BX" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    --<<User37 #2996 4. TR Module 26/04/2021 
    global_v_numlvlsalst    varchar2(100 char);
    global_v_numlvlsalen    varchar2(100 char);
    -->>User37 #2996 4. TR Module 26/04/2021 
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    json_params             json;

    p_dteyear               thisclss.dteyear%type;
    p_codcomp               tcenter.codcomp%type;
    p_codcours              thisclss.codcours%type;
    p_numclseq              thisclss.numclseq%type;
    p_typetest              varchar2(1 char);
    p_codexam               thisclss.codexampr%type;
    p_stdte                 thisclss.dteprest%type;
    p_endte                 thisclss.dtepreen%type;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index_1(json_str_output out clob);
    procedure gen_index_2(json_str_output out clob);
    procedure get_index_header(json_str_input in clob,json_str_output out clob);
    procedure gen_index_header_1(json_str_output out clob);
    procedure gen_index_header_2(json_str_output out clob);

end HRTR6BX;

/
