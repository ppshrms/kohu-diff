--------------------------------------------------------
--  DDL for Package HRTR51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR51E" AS
--15/08/2022 --redmine 8201
    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    param_json          JSON;

    p_codcompy   tcompny.codcompy%type;
    p_year       tyrtrpln.dteyear%type;
    p_codcate    tcodcate.CODCODEC%type;
    p_codcours    tyrtrpln.codcours%type;
    p_numclseq    tyrtrsch.numclseq%type;
    p_codinst_tr  tyrtrsch.codinst%type;
    p_codinst_sub tyrtrsch.codinst%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_inst(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_edit_index(json_str_input in clob, json_str_output out clob);
    procedure get_edit_detail(json_str_input in clob, json_str_output out clob);
    procedure save_edit_index(json_str_input in clob, json_str_output out clob);
    procedure save_edit_detail(json_str_input in clob, json_str_output out clob);

END HRTR51E;

/
