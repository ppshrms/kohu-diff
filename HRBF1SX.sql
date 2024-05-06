--------------------------------------------------------
--  DDL for Package HRBF1SX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1SX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    p_compgrp               tcompgrp.codcodec%type;
    p_codcomp               tcenter.codcomp%type;
    p_comp_level            number;
    p_dte_start             ttravinf.dtereq%type;
    p_dte_end               ttravinf.dtereq%type;
    p_coddc                 tclnsinf.coddc%type;
    p_codrel                tclnsinf.codrel%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_total(json_str_input in clob, json_str_output out clob);
    procedure get_list_tsetcomp(json_str_input in clob, json_str_output out clob);

END HRBF1SX;

/
