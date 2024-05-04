--------------------------------------------------------
--  DDL for Package HCM_BREAKLEVEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_BREAKLEVEL" is
    -- global_param
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    p_codapp          varchar2(100 char);

    type map_number is table of number index by varchar2(1000 char);
    type array_varchar is table of varchar2(1000 char) index by binary_integer;
    type array_number is table of number index by binary_integer;
    type array_number_2d is table of array_number index by binary_integer;

    function get_breaklevel(json_str_input in clob) return clob;
    procedure get_comp_setup(json_str_input in clob,json_str_output out clob);
    procedure get_level(json_str_input in clob,json_str_output out clob);
    procedure save_level(json_str_input in clob,json_str_output out clob);

end hcm_breaklevel;

/
