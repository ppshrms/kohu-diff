--------------------------------------------------------
--  DDL for Package HRBF49E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF49E" AS

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    p_codapp          varchar2(10 char) := 'HRTR1FE';

    p_codcompy        tcompny.codcompy%type;
    p_codcompyCopy    tcompny.codcompy%type;
    p_flgCopy         varchar2(1 char);

    json_params       json;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure gen_index(json_str_output out clob);

    procedure get_copylist(json_str_input in clob, json_str_output out clob);
    procedure gen_copylist(json_str_output out clob);
    
    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRBF49E;

/
