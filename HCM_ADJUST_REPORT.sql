--------------------------------------------------------
--  DDL for Package HCM_ADJUST_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_ADJUST_REPORT" AS
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

    function GET_LOV(json_str_input in clob) return clob;
    function GET_TABLES(json_str_input in clob) return clob;
    function GET_CONFIGS(json_str_input in clob) return clob;
    function SAVE_CONFIGS(json_str_input in clob) return clob;
    function DELETE_CONFIGS(json_str_input in clob) return clob;
    function GET_DATA(json_str_input in clob) return clob;
    function CHECK_STATEMENT(json_str_input in clob) return clob;
END HCM_ADJUST_REPORT;

/
