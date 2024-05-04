--------------------------------------------------------
--  DDL for Package HRTR22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR22E" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

    p_codcomp               tcenter.codcomp%type;
    p_index_codcomp         tcenter.codcomp%type;
    p_year                  tyrtrpln.dteyear%type;
    p_problem_numseq        ttrneedp.numseq%type;

    p_codcate               tcodcate.codcodec%type;
    p_codcours              tyrtrpln.codcours%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_general_emp(json_str_input in clob, json_str_output out clob);
    procedure process_general(json_str_input in clob, json_str_output out clob);
    procedure save_general_employee(json_str_input in clob, json_str_output out clob);

    procedure get_competency_emp(json_str_input in clob, json_str_output out clob);
    procedure get_problem_detail(json_str_input in clob, json_str_output out clob);
    procedure save_problem_detail(json_str_input in clob, json_str_output out clob);
    procedure get_problem_list(json_str_input in clob, json_str_output out clob);
    procedure gen_problem_list(json_str_output out clob);

    procedure get_inst(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRTR22E;

/
