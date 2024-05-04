--------------------------------------------------------
--  DDL for Package HRAL82B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL82B" as

  /* TODO enter package declarations (types, exceptions, methods etc) here */
--?	Input   -  TEMPLOY1, TCONTRLV, TRATEVAC, TRATEVAC2
--?	Output  -  TLEAVSUM, TMTHEND, TPAYVAC ttnewemp
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);

    global_v_batch_codapp     varchar2(100 char)  := 'HRAL82B';
    global_v_batch_codalw     varchar2(100 char)  := 'HRAL82B';
    global_v_batch_dtestrt    date;
    global_v_batch_flgproc    varchar2(1 char)    := 'N';
    global_v_batch_qtyproc    number              := 0;
    global_v_batch_qtyerror   number              := 0;

    p_codcomp               varchar2(4000 char);
    p_codempid              varchar2(4000 char);
    p_year                  number;
    p_numperiod             number;
    p_dtemthpay             number;
    p_dteyrepay             number;
    p_flgprocess            varchar2(1 char);
    p_flgtyp                varchar2(1 char);
    p_dtecal                date;

    procedure initial_value(json_str_input in clob);
    procedure get_process(json_str_input in clob,json_str_output out clob);
    procedure check_process;
    procedure gen_process(json_str_output out clob);

    procedure get_latestupdate(json_str_input in clob,json_str_output out clob);
    procedure check_latestupdate;
    procedure gen_latestupdate(json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;
end HRAL82B;

/
