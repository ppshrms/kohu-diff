--------------------------------------------------------
--  DDL for Package HRTR70X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR70X" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    p_codempid              thistrnn.codempid%type;
    p_dtetrst               thistrnn.dtetrst%type;
    p_dtetren               thistrnn.dtetren%type;
    p_dteyear               thistrnn.dteyear%type;
    p_codcours              thistrnn.codcours%type;
    p_numclseq              thistrnn.numclseq%type;
    p_codapp                varchar2(10 char) := 'HRTR70X';
    json_select_arr         json;
    isInsertReport          boolean := false;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure get_thistrnn(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnn(json_str_output out clob);
    procedure get_thistrnf(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnf(json_str_output out clob);
    procedure get_thiscost(json_str_input in clob, json_str_output out clob);
    procedure gen_thiscost(json_str_output out clob);
    procedure get_thistrnb(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnb(json_str_output out clob);
    procedure get_tknowleg(json_str_input in clob, json_str_output out clob);
    procedure gen_tknowleg(json_str_output out clob);
    function get_codcompy_by_codempid(p_codempid in varchar2) return varchar2;
    function get_codcomp_by_codempid(p_codempid in varchar2) return varchar2;
    procedure get_thistrnp(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnp(json_str_output out clob);
    procedure gen_report(json_str_input in clob,json_str_output out clob);
    procedure initial_report(json_str in clob);
    procedure clear_ttemprpt;
    --procedure gen_report_thistrnf (json_str_output out clob);
    procedure insert_ttemprpt_thistrnn(obj_data in json);
    procedure insert_ttemprpt_thistrnf(obj_data in json);
    procedure insert_ttemprpt_thiscost(obj_data in json);
    procedure insert_ttemprpt_thistrnb(obj_data in json);
    procedure insert_ttemprpt_tknowleg(obj_data in json);
    procedure insert_ttemprpt_thistrnp(obj_data in json);

end HRTR70X;

/
