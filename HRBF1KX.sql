--------------------------------------------------------
--  DDL for Package HRBF1KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1KX" AS
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_codcomp           tclnsinf.codcomp%type;
    p_typpayroll        tclnsum.typpayroll%type;
    p_periodpay_period  tclnsinf.NUMPERIOD%type;
    p_periodpay_month   tclnsinf.DTEMTHPAY%type;
    p_periodpay_year    tclnsinf.DTEYREPAY%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_index2(json_str_input in clob, json_str_output out clob);

END HRBF1KX;

/
