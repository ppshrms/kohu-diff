--------------------------------------------------------
--  DDL for Package HRTR7AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR7AE" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    json_params             json;

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;

    p_codempid              varchar2(4000 char);
    p_year                  varchar2(4 char);
    p_codcours              varchar2(100 char);
    p_dtetrst               varchar2(100 char);

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure check_search;
    procedure get_thistrnn(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnn (json_str_output out clob);
    procedure get_thistrnp(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnp(json_str_output out clob);
    procedure get_thistrnf(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnf(json_str_output out clob);
    procedure get_thistrnb(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrnb(json_str_output out clob);
    procedure get_thistrns(json_str_input in clob, json_str_output out clob);
    procedure gen_thistrns(json_str_output out clob);
    procedure get_tknowleg(json_str_input in clob, json_str_output out clob);
    procedure gen_tknowleg(json_str_output out clob);
    procedure get_thiscost(json_str_input in clob, json_str_output out clob);
    procedure gen_thiscost(json_str_output out clob);
    procedure save_all (json_str_input in clob, json_str_output out clob);
    procedure save_thistrnn (json_thistrnn_obj in json  , param_msg_error out varchar2);
    procedure save_thistrnf (json_thistrnf_obj in json  , param_msg_error out varchar2);
    procedure save_thistrnb (json_thistrnb_obj in json  , param_msg_error out varchar2);
    procedure save_thistrns (json_thistrns_obj in json  , param_msg_error out varchar2);
    procedure save_tknowleg (json_tknowleg_obj in json  , param_msg_error out varchar2);
    procedure save_thistrnp (json_thistrnp_obj in json  , param_msg_error out varchar2);
    procedure save_thiscost (json_thiscost_obj in json  , param_msg_error out varchar2);
    function get_numclseq(p_codcours in varchar2,p_year in varchar2,p_dtetrst in date) return number ;
    function get_codcomp_by_codempid(p_codempid in varchar2) return varchar2;
    function get_codpos_by_codempid(p_codempid in varchar2) return varchar2;
    function get_costcent_by_codcomp(v_codcomp in varchar2) return varchar2;
    function get_codcompy_by_codempid(p_codempid in varchar2) return varchar2;
    procedure get_descommt_by_codcours(json_str_input in clob, json_str_output out clob);
    procedure check_validate_save_tab1 (json_thistrnn_obj in json);
    procedure delete_index (json_str_input in clob, json_str_output out clob);

end HRTR7AE;

/
