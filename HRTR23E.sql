--------------------------------------------------------
--  DDL for Package HRTR23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR23E" AS
    param_msg_error       varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(100 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    v_zupdsal             varchar2(4000 char);

    param_json          json_object_t;

    p_grade             tidpcptc.grade%type;
    p_src               varchar2(100 char);
    p_dteyear           tidpcptc.dteyear%type;
    p_codempid_query    temploy1.codempid%type;
    p_codcomp           tbasictp.codcomp%type;
    p_codpos            tbasictp.codpos%type;
    p_dteappr           tidpplan.dteappr%type;
    p_competency        json_object_t;
    p_competency_type   tidpcptc.codtency%type;
    p_competency_code   tidpcptc.codskill%type;
    p_description       tidpcptcd.desdevp%type;
    p_grdemp            tidpcptc.grdemp%type;
    p_list_cours        json_object_t;
    p_codcours          tidpplans.codcours%type;
    p_codcate           tidpplans.codcate%type;
    p_commtfoll         tidpplan.commtfoll%type;
    p_dtetrst           tidpplans.dtetrst%type;
    p_dtetren           tidpplans.dtetren%type;
    p_list_description  json_object_t;
--    p_codskill          tidpcptcd.codskill%type;
    p_coddevp           tidpcptcd.coddevp%type;
    p_desdevp           tidpcptcd.desdevp%type;
    p_targetdev         tidpcptcd.targetdev%type;
    p_dtestr            tidpplans.dtestr%type;
    p_dteend            tidpplans.dteend%type;
    p_desresults        tidpcptcd.desresults%type;

    v_c2_numseq         tposempd.numseq%type;

    p_typemp            tbasictp.typemp%type;
    p_typfrom           tidpplans.typfrom%type;
    p_stadevp           tidpplan.stadevp%type;
    p_commtemp          tidpplan.commtemp%type;
    p_commtemph         tidpplan.commtemph%type;
    p_dteconf           tidpplan.dteconf%type;
    p_dteconfh          tidpplan.dteconfh%type;
    p_pctsucc           tidpcptcd.pctsucc%type;
    p_remark            tidpcptcd.remark%type;
    p_codapp            ttemprpt.codapp%type;
    p_codappr           tidpplan.codappr%type;
    p_flag              varchar(50 char);

    param_detail        json_object_t;
    param_tiddplans     json_object_t;
    param_tidpcptc      json_object_t;
    param_tidpcptcd     json_object_t;

    param_flgwarn       varchar2(100 char) := '';--nut 

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_succession_plan(json_str_input in clob, json_str_output out clob);

    procedure get_next_succession_plan(json_str_input in clob, json_str_output out clob);

    procedure get_career_plan(json_str_input in clob, json_str_output out clob);

    procedure get_evaluation(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure delete_index(json_str_input in clob, json_str_output out clob);

    procedure get_report(json_str_input in clob, json_str_output out clob);

    procedure get_gap_competency(json_str_input in clob, json_str_output out clob);

END HRTR23E;

/
