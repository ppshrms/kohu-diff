--------------------------------------------------------
--  DDL for Package HRTR55E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR55E" AS
-- update 02/08/2022 redmine8171

    param_msg_error             varchar2(4000 char);
    global_v_coduser            varchar2(100 char);
    global_v_codempid           varchar2(100 char);
    global_v_lang               varchar2(10 char) := '102';
    global_v_zminlvl            number;
    global_v_zwrklvl            number;
    global_v_numlvlsalst 	    number;
    global_v_numlvlsalen 	    number;
    v_zupdsal                   varchar2(4000 char);

    param_json                  json_object_t;

    p_dteyear                   tyrtrsch.dteyear%type;
    p_codcompy                  tyrtrsch.codcompy%type;
    p_codcours                  tyrtrsch.codcours%type;
    p_codcate                   tyrtrsch.codcate%type;
    p_numclseq                  tyrtrsch.numclseq%type;
    p_codinst                   tyrtrsch.codinst%type;
    p_codempid                  temploy1.codempid%type;
    p_codapp                    varchar2(20 char);

    p_codform                   varchar2(20 char);
    p_signature                 temploy1.codempid%type;
    p_refdoc                    varchar2(1000 char);
    p_attendee_filename         varchar2(1000 char);
    v_flgcontinue               boolean := false;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_emp_data(json_str_input in clob, json_str_output out clob);
    procedure get_waiting(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index_detail(json_str_input in clob, json_str_output out clob);
    procedure send_email(json_str_input in clob, json_str_output out clob);
--    procedure get_report_lecturer(json_str_input in clob, json_str_output out clob);
    procedure get_report_trainer(json_str_input in clob, json_str_output out clob);
    procedure get_template(json_str_input in clob, json_str_output out clob);

END HRTR55E;

/
