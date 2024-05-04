--------------------------------------------------------
--  DDL for Package HRPYB2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYB2E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';
    global_v_zminlvl    number;
    global_v_zwrklvl    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal           varchar2(4000 char);
    global_v_zyear      number := 0;

    param_json          json_object_t;

    p_codpfinf          tpfphinf.codpfinf%type;
    p_codplan          tpfpcinf.codplan%type;
    p_codcomp           temploy1.codcomp%type;
    p_codempid          temploy1.codempid%type;
    p_flgemp            tpfmemb.flgemp%type;
    p_dtedueprst        temploy1.dteduepr%type;
    p_dtedueprnd        temploy1.dteduepr%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_plan(json_str_input in clob, json_str_output out clob);
    procedure get_tpfpcinf(json_str_input in clob, json_str_output out clob);
    procedure get_history(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
end HRPYB2E;

/
