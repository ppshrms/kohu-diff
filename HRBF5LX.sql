--------------------------------------------------------
--  DDL for Package HRBF5LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5LX" AS

-- last update: 26/01/2021 16:01
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_codcomp           tloaninf.codcomp%type;
    p_codlon            tloaninf.codlon%type;
    p_codempid          tloaninf.codempid%type;
    p_dte_st            tloaninf.DTESTCAL%type;
    p_dte_en            tloaninf.DTESTCAL%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF5LX;

/
