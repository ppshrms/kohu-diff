--------------------------------------------------------
--  DDL for Package HRPY2KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2KX" as

    v_chken                 varchar2(10 char);
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    p_codcomp               varchar2(40 char);
    p_codempid              varchar2(10 char);

    p_dteyrepay             tlegalexp.dteyrepay%type;
    p_dtemthpay             tlegalexp.dtemthpay%type;
    p_codlegald             tlegalexe.codlegald%type;
    p_codpay1               tlegalexp.codpay%type;
    p_codpay2               tlegalexp.codpay%type;
    p_codpay3               tlegalexp.codpay%type;
    p_codpay4               tlegalexp.codpay%type;
    p_codpay5               tlegalexp.codpay%type;
    p_codpay6               tlegalexp.codpay%type;
    p_codpay7               tlegalexp.codpay%type;
    p_codpay8               tlegalexp.codpay%type;
    p_codpay9               tlegalexp.codpay%type;
    p_codpay10              tlegalexp.codpay%type;
    p_codpay11              tlegalexp.codpay%type;
    p_codpay12              tlegalexp.codpay%type;

    p_dtestr                date;
    p_dteend                date;

    procedure initial_value(json_str_input in clob);
    procedure get_report(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_report(json_str_output out clob);
    procedure get_csv(json_str_input in clob, json_str_output out clob);
    procedure gen_csv(json_str_output out clob);

end HRPY2KX;

/
