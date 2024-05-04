--------------------------------------------------------
--  DDL for Package HRPY2CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2CX" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_dtemthpay         tlogothinc.dtemthpay%type;
    p_dteyrepay         tlogothinc.dteyrepay%type;
    p_numperiod         tlogothinc.numperiod%type;
    p_codempid          tlogothinc.codempid%type;
    p_codcomp           tlogothinc.codcomp%type;
    p_codpay            tlogothinc.codpay%type;
    p_dtestr            tlogothinc.dteupd%type;
    p_dteend            tlogothinc.dteupd%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
end HRPY2CX;

/
