--------------------------------------------------------
--  DDL for Package HRCO26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO26E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    param_json          json_object_t;
    json_obj_main       json_object_t;

    param_tjobpos       json_object_t;
    param_json1         json_object_t;
    param_json2         json_object_t;

    p_codcomp    tjobpos.codcomp%type;
    p_codpos     tjobpos.codpos%type;
    p_codskill   tjobposskil.codskill%type;
    p_codtency   tjobposskil.codtency%type;
    p_jobgroup   tjobgroup.jobgroup%type;
    p_codkpi     tjobkpi.codkpi%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_competency(json_str_input in clob, json_str_output out clob);

    procedure get_popup_codtency(json_str_input in clob, json_str_output out clob);
    procedure get_popup_kpi(json_str_input in clob, json_str_output out clob);

    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_kpi;
    procedure save_competency;

end HRCO26E;

/
