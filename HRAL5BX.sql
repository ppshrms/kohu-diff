--------------------------------------------------------
--  DDL for Package HRAL5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5BX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    global_v_zupdsal   		  varchar2(4 char);

    type qtymin is table of number index by binary_integer;

    b_index_codempid        varchar2(10 char);
    b_index_codcomp         varchar2(50 char);
    b_index_month           varchar2(2 char);
    b_index_year            varchar2(4 char);

    b_codleave_e            varchar2(10 char);
    b_codleave_l            varchar2(10 char);
    b_codleave_a            varchar2(10 char);

    -- report
    p_codapp                varchar2(10 char) := 'HRAL5BX';
    b_codapp                varchar2(10 char) := 'HRAL5BX';
    isInsertReport          boolean := false;
      TYPE typ_char_number IS
    TABLE OF VARCHAR2(1000 CHAR) INDEX BY BINARY_INTEGER;

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_calendar(json_str_input in clob,json_str_output out clob);
    procedure gen_calendar(json_str_output out clob);
    procedure get_data_comp(json_str_input in clob,json_str_output out clob);
    procedure gen_data_comp(json_str_output out clob);
    procedure get_data_comp_summary(json_str_input in clob,json_str_output out clob);
    procedure gen_data_comp_summary(json_str_output out clob);

    procedure gen_report(json_str_input in clob,json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt_calendar(obj_data in json_object_t);
    procedure insert_ttemprpt_emp(arr_week_day in typ_char_number, arr_week_codshift in typ_char_number, arr_week_desc in typ_char_number, arr_week_typwork in typ_char_number);

end HRAL5BX;

/
