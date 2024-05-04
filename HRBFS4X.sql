--------------------------------------------------------
--  DDL for Package HRBFS4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFS4X" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    p_codapp                varchar2(10 char) := 'HRBFS4X';
    p_codcomp               tclnsinf.codcomp%type;
    p_dteyear               number;
    p_dtemonthfr            varchar2(2 char);
    p_dtemonthto            varchar2(2 char);
    p_typamt                varchar2(1 char);
    p_typrep                varchar2(1 char);
    p_breaklevel            varchar2(2 char);

    procedure initial_value(json_str_input in clob);

    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);

    procedure get_dropdowns (json_str_input in clob, json_str_output out clob);
    procedure gen_dropdowns (json_str_output out clob);

    procedure gen_graph(obj_row in json);

end HRBFS4X;


/
