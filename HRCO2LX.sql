--------------------------------------------------------
--  DDL for Package HRCO2LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2LX" as

    param_msg_error varchar2(4000 char);
    global_v_coduser varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang varchar2(10 char) := '102';

    p_routeno    twkflowh.routeno%type;
    p_codpos     tpostn.codpos%type;
    p_codcomp    tcenter.codcomp%type;
    p_codempa    temploy1.codempid%type;

    p_codapp     twkflpr.codapp%type;
    p_seqno      twkflph.seqno%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_workflow(json_str_input in clob, json_str_output out clob);
    procedure get_workflow_tab1(json_str_input in clob, json_str_output out clob);
    procedure get_workflow_tab2(json_str_input in clob, json_str_output out clob);

end hrco2lx;

/
