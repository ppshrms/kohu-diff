--------------------------------------------------------
--  DDL for Package HRAP35B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP35B" as
    param_msg_error           varchar2(4000 char);
    v_chken                   varchar2(10 char);
    global_v_coduser          varchar2(100 char);
    global_v_lang             varchar2(10 char) := '102';
    global_v_codempid         varchar2(100 char);
    global_v_zyear            number := 0;
    global_v_zminlvl          number;
    global_v_zwrklvl          number;
    global_v_numlvlsalst      number;
    global_v_numlvlsalen      number;
    v_zupdsal                 varchar2(4 char);

    p_dteyreap                number;
    p_numtime                 number;
    p_codcomp                 varchar2(100 char);
    p_codempid                varchar2(100 char);
    p_codreq                  varchar2(100 char);
    p_codcacultr              varchar2(100 char);
    p_flgcal                  varchar2(100 char);


    b_var_codempid    temploy1.codempid%type;
    b_var_codcompy    tcompny.codcompy%type;
    b_var_typpayroll  temploy1.typpayroll%type;
    b_var_staemp      varchar2(1) := 0 ;

    procedure get_process(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);

end HRAP35B;

/
