--------------------------------------------------------
--  DDL for Package HRCO2NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2NX" as

    param_msg_error varchar2(4000 char);
    global_v_coduser varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_codapp    twkfunct.codapp%type;
    p_codcomp   tcenter.codcomp%type;
    p_codpos    tpostn.codpos%type;
    p_codempid  temploy1.codempid%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

--redmine #5306
  procedure msg_err2(p_error in varchar2);
--redmine #5306
end HRCO2NX;

/
