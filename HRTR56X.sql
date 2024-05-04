--------------------------------------------------------
--  DDL for Package HRTR56X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR56X" AS

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    param_json          JSON;

    p_codcompy      tcompny.codcompy%type;
    p_year          ttrsubjd.dteyear%type;
    p_codcours      ttrsubjd.codcours%type;
    p_numclseq      ttrsubjd.numclseq%type;
    p_codapp        ttemprpt.codapp%type;
    p_codinst       ttrsubjd.codinst%type;

    p_signature     temploy1.codempid%type;
    p_refdoc        varchar2(1000 char);
    p_codform       tfrmmail.codform%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);
    procedure send_email(json_str_input in clob, json_str_output out clob);
    procedure get_template(json_str_input in clob, json_str_output out clob);

END HRTR56X;

/
