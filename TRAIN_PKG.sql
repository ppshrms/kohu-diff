--------------------------------------------------------
--  DDL for Package TRAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "TRAIN_PKG" is
    global_v_num    number := 0;
    param_msg_error varchar2(600 char);
    global_v_lang   varchar2(100 char) := '102';
    
    global_v_query  clob            := NULL;
    
    v_codempid    tt.codempid%type    := NULL;
    v_staemp      tt.staemp%type      := null;
    v_cstr        tt.cstr%type        := NULL;
    v_d1          varchar2(100 char)  := NULL;
    v_d2          varchar2(100 char)  := NULL;
    v_date1       tt.date1%type       := NULL;
    v_date2       tt.date2%type       := NULL;
    
    function train_sum(p_input1 number, p_input2 number) return number;
    procedure train_sum2(p_input1  number, p_input2 number, p_output1 out number);
    procedure save_data(json_str_input in clob,json_str_output out clob);
    procedure delete_data(json_str_input in clob,json_str_output out clob);
    procedure search_data(json_str_input in clob,json_str_output out clob);
    procedure get_data(json_str_input in clob,json_str_output out clob);
end;

--json_str_input := {"p_codempid":"1"}
--
--json_str_output := {"staemp":"0","c":"a"}

/
