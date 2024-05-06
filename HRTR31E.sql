--------------------------------------------------------
--  DDL for Package HRTR31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR31E" AS
    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';
    global_v_zyear      number := 0;

    param_json          JSON;
    p_codcomp           tcenter.codcomp%type;
    p_codpos            tpostn.codpos%type;
    p_qtyminhr          ttrnnhr.qtyminhr%type;
    p_qtyminhr_str      varchar2(100 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRTR31E;

/
