--------------------------------------------------------
--  DDL for Package HRBFS5X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFS5X" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              JSON;

    p_dteyear               integer;
    p_mthst                 integer;
    p_mthen                 integer;
    p_codcomp               tclnsinf.codcomp%type;
    p_coddc                 tdcinf.codcodec%type;
    p_list_coddc            json;

procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBFS5X;


/
