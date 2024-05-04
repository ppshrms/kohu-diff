--------------------------------------------------------
--  DDL for Package HRTR1FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR1FE" AS

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    p_codapp          varchar2(10 char) := 'HRTR1FE';

    p_codexpn         varchar2(1000 char);

    json_params       json;
    json_codexpn      json;
    isInsertReport    boolean := false;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure gen_report(json_str_input in clob, json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt(obj_data in json);

END HRTR1FE;


/
