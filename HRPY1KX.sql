--------------------------------------------------------
--  DDL for Package HRPY1KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY1KX" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_codcomp       tcostemp.codcomp%type;
    p_codempid      tcostemp.codempid%type;
    p_numprdst      tcostemp.numprdst%type;
    p_dtemthst      tcostemp.dtemthst%type;
    p_dteyearst     tcostemp.dteyearst%type;
    p_numprden      tcostemp.numprden%type;
    p_dtemthen      tcostemp.dtemthen%type;
    p_dteyearen     tcostemp.dteyearen%type;
    p_flgdata       varchar2(1 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

end HRPY1KX;

/
