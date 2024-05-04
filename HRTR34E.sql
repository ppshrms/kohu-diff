--------------------------------------------------------
--  DDL for Package HRTR34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR34E" AS

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
    param_get_idp               json_object_t;
    param_get_idp_detail        json_object_t;
    param_get_proc              json_object_t;

    p_dteyear                   tyrtrpln.dteyear%type;
    p_dteyreap                  tyrtrpln.dteyear%type;
    p_codcomp                   ttrneedp.codcomp%type;
    p_codcompy                  tyrtrpln.codcompy%type;
    p_codcours                  tyrtrpln.codcours%type;
    p_dtestrt                   tidpplans.dtestr%type;
    p_dteend                    tidpplans.dteend%type;
    p_codpos                    tidpplan.codpos%type;
    p_numtime                   tapptrnf.numtime%type;

    p_flgempnew                 varchar2(1);
    p_flgempmove                varchar2(1);
    p_dteempmtst                temploy1.dteempmt%type;
    p_dteempmtend               temploy1.dteempmt%type;
    p_dteeffecst                ttmovemt.dteeffec%type;
    p_dteeffecend               ttmovemt.dteeffec%type;

    p_flgClearTmp               varchar2(1);
    p_flgprior                  ttrneedg.flgprior%type;
    p_codskill                  ttrneedcc.codskill%type;
    p_grade                     ttrneedcc.grade%type;
    p_numseq                    ttrneedp.numseq%type;

    p_dtefrom                   tidpplans.dtetrst%type;
    p_dteto                     tidpplans.dtetren%type;
    p_qtyposst                  tbasictp.qtyposst%type;
    p_dtefrom_n                 date;
    p_dteto_n                   date;
    p_dtefrom_m                 date;
    p_dteto_m                   date;
    p_flgTab                    varchar2(1);

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure get_prev_year(json_str_input in clob, json_str_output out clob);
    procedure get_process(json_str_input in clob, json_str_output out clob);
    procedure send_mail(json_str_input in clob, json_str_output out clob);
    procedure get_planidp(json_str_input in clob, json_str_output out clob);
    procedure get_planidp_detail(json_str_input in clob, json_str_output out clob);
    procedure get_planevaluation(json_str_input in clob, json_str_output out clob);
    procedure get_planevaluation_detail(json_str_input in clob, json_str_output out clob);
    procedure get_planbasic(json_str_input in clob, json_str_output out clob);
    procedure get_planbasic_detail(json_str_input in clob, json_str_output out clob);
    procedure get_plansurvey(json_str_input in clob, json_str_output out clob);
    procedure get_plansurvey_general(json_str_input in clob, json_str_output out clob);
    procedure get_plansurvey_competency(json_str_input in clob, json_str_output out clob);
    procedure get_plansurvey_training(json_str_input in clob, json_str_output out clob);
    procedure get_planSurvey_summarycourse(json_str_input in clob, json_str_output out clob);
    procedure get_planSurvey_summarycourse_detail(json_str_input in clob, json_str_output out clob);

    procedure save_detail(json_str_input in clob, json_str_output out clob);

    procedure save_plan(json_str_input in clob, json_str_output out clob);


END HRTR34E;

/
