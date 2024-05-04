--------------------------------------------------------
--  DDL for Package HRTR13X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR13X" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
    global_chken            varchar2(100 char);
    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;

    p_codapp                varchar2(10 char) := 'HRTR13X';
    p_codrep                varchar2(10 char);
    json_codcours           json;
    p_showimg               varchar2(5);
    p_table_selected        treport.codtable%type;
    p_codcours              tcourse.codcours%type;
    isInsertReport          boolean := false;

    procedure initial_value(json_str_input in clob);

    procedure get_codrep_detail (json_str_input in clob, json_str_output out clob);
    procedure gen_codrep_detail (json_str_output out clob);
    procedure get_format_fields (json_str_input in clob, json_str_output out clob);
    procedure gen_format_fields (json_str_output out clob);
    procedure get_list_fields (json_str_input in clob, json_str_output out clob);
    procedure gen_list_fields (json_str_output out clob);
    procedure get_table (json_str_input in clob, json_str_output out clob);
    procedure gen_table (json_str_input in clob, json_str_output out clob);
    procedure get_tab1_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_tab1_detail(json_str_output out clob);
    procedure get_tab2_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_tab2_detail(json_str_output out clob);
    procedure get_tab3_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_tab3_detail(json_str_output out clob);
    procedure delete_codrep (json_str_input in clob, json_str_output out clob);

    procedure gen_report(json_str_input in clob, json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt(obj_data in json);
    procedure insert_trepdsph(p_r_trepdsph trepdsph%rowtype);
    procedure gen_style_column (v_objrow in json, v_img varchar2);
    function  get_item_property (p_table in varchar2,p_field  in varchar2) return varchar2;

END HRTR13X;

/
