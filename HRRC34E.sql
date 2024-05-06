--------------------------------------------------------
--  DDL for Package HRRC34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC34E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

--  get index parameter
    p_codempts              tappoinfint.codempts%type;
    p_dteappoist            tappoinfint.dteappoi%type;
    p_dteappoien            tappoinfint.dteappoi%type;

--  get detail parameter
    p_numappl               tappoinf.numappl%type;
    p_numreqrq              tappoinf.numreqrq%type;
    p_codpos                tappoinf.codposrq%type;
    p_numapseq              tappoinf.numapseq%type;

--  get detail assessment parameter
    p_codform               tintvewd.codform%type;
    p_numgrup               tintvewd.numgrup%type;

--  save index parameter
    p_numitem               tintvewd.numitem%type;
    p_qtyfscor              tappodet.qtyfscor%type;
    p_grade                 tappodet.grade%type;
    p_qtyscore              tappodet.qtyscore%type;
    p_descnote              tappoinfint.descnote%type;

--  save index2 parameter
    p_stapphinv             tappoinfint.stapphinv%type;
    p_codasapl              tappoinfint.codasapl%type;
    p_stasign               tapphinv.stasign%type;
    p_qtyscoreavg           number;--tappoinf.qtyscoreavg%type;
    p_codasapll             tappoinf.codasapl%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_detail_assessment(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure save_index2(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_interview(json_str_input in clob, json_str_output out clob);

END HRRC34E;

/
