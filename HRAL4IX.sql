--------------------------------------------------------
--  DDL for Package HRAL4IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4IX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    type darr is table of date index by binary_integer;

    b_index_codempid        varchar2(10 char);
    b_index_codcomp         varchar2(50 char);
    b_index_codcalen        varchar2(4 char);
    b_index_deffecst1       date;
    b_index_v_othour        number;
    b_index_typehour        varchar2(1 char); --user36 TDKU-SM2101 28/07/2021
    b_index_type_rep        varchar2(1 char);

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure get_index_head(json_str_input in clob,json_str_output out clob);
    procedure gen_index_head(json_str_output out clob);
    function get_startday(p_date in date) return date; --user36 TDKU-SM2101 18/08/2021

end HRAL4IX;

/
