--------------------------------------------------------
--  DDL for Package HRBF4KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF4KE" AS
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    param_json          JSON;

    p_codcomp       TOBFCFP.codcomp%type;
    p_numseq        TOBFCFP.numseq%type;
    p_dtestart      TOBFCFP.dtestart%type;
    p_dteend        TOBFCFP.dteend%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_children(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure get_codobf(json_str_input in clob, json_str_output out clob);

END HRBF4KE;

/
