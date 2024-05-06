--------------------------------------------------------
--  DDL for Package HRTR6DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6DX" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    json_params             json;
    p_year                  thistrnn.dteyear%type;
    p_codcomp               thistrnn.codcomp%type;
    p_codcours              thistrnn.codcours%type;
    p_numclseq              thistrnn.numclseq%type;
    p_codempid              thistrnn.codempid%type;

    p_codapp                varchar2(10 char) := 'HRTR6DX';
    json_select_arr         json;
    isInsertReport          boolean := false;
    p_desc_codempid         varchar2(1000 char);
    p_desc_codpos           varchar2(1000 char);
    p_desc_codcours         varchar2(1000 char);
    p_dtetrst               thistrnn.dtetrst%type;
    p_dtetren               thistrnn.dtetren%type;


    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);
    procedure gen_report(json_str_input in clob,json_str_output out clob);
    procedure initial_report(json_str in clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt_main;
    procedure insert_ttemprpt_sub(obj_data in json);

end HRTR6DX;

/
