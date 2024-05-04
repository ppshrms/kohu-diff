--------------------------------------------------------
--  DDL for Package HRPY5NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5NX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    global_v_chken          varchar2(4000 char);
    global_v_zyear          number := 0;
    v_zupdsal     		      varchar2(4 char);
    global_v_break          varchar2(4 char);

    p_codbrsoc              tcodsoc.codbrsoc%type;
    p_numbrlvl              tcodsoc.numbrlvl%type;
    p_year                  number;

    p_stdate                date;
    p_endate                date;
    p_endate2               date;
--    v_codbrsoc              varchar2(4 char);
--    flg_data                varchar2(1 char);
--    flg_fecth               varchar2(1 char);
    p_codapp                  varchar2(500 char) := 'HRPY5NX';
    isInsertReport            boolean := false;
    json_param_break        json_object_t;
    json_param_json         json_object_t;
    json_break_output       json_object_t;
    json_break_output_row   json_object_t;
    json_break_params       json_object_t;


  p_breaklevel1         boolean := false;
  p_breaklevel2         boolean := false;
  p_breaklevel3         boolean := false;
  p_breaklevel4         boolean := false;
  p_breaklevel5         boolean := false;
  p_breaklevel6         boolean := false;
  p_breaklevel7         boolean := false;
  p_breaklevel8         boolean := false;
  p_breaklevel9         boolean := false;
  p_breaklevel10        boolean := false;
  p_breaklevelAll       boolean := false; -- summary

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure clear_ttemprpt;
    procedure get_report(json_str_input in clob,json_str_output out clob);
    procedure insert_ttemprpt_data(obj_data in json_object_t);
    function split_number_id (v_item number) return varchar2;
    function split_account_id (v_item varchar2) return varchar2;

end hrpy5nx;

/
