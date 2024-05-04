--------------------------------------------------------
--  DDL for Package HRMS_TABLE_TEMPLATE_COLUMN_SETTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS_TABLE_TEMPLATE_COLUMN_SETTING" AS
    global_v_coduser      varchar2(1000 char);
    global_v_codempid     varchar2(1000 char);
    global_v_lang         varchar2(100 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    v_zupdsal             varchar2(4000 char);
    v_chken               varchar2(10 char) := check_emp(get_emp);

    param_msg_error       varchar2(600);
    v_cursor			  number;
    v_dummy               integer;
    v_log_level           varchar2(100) := 'DEBUG';

    p_codapp              varchar2(100);     --- surachai 28/11/2023    
    -- surachai 28/11/2023(4448 #9698)
    procedure get_column_sort(json_str_input in clob,json_str_output out clob);
    procedure save_column_sort(json_str_input in clob,json_str_output out clob);
    procedure reset_column_sort(json_str_input in clob,json_str_output out clob);
END HRMS_TABLE_TEMPLATE_COLUMN_SETTING;

/
