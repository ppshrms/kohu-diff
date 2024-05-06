--------------------------------------------------------
--  DDL for Package HRPY12E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY12E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          json_object_t;
    json_input_obj      json_object_t;

    -- index
    p_codcompy          varchar2(4 char);
    p_dteeffec          number(4,0);
    p_dteyreff_query    number(4,0);

    isInsertReport      boolean := false;
    p_codapp            varchar2(10 char) := 'HRPY12E';
    v_flgDisabled       boolean;  
    v_flgAdd            boolean;
    v_count_flg_Delete  number;
    v_count_flg_Ot      number;



    procedure get_index(json_str_input in clob,json_str_output out clob);

    procedure save_index(json_str_input in clob,json_str_output out clob);

    procedure get_detail (json_str_input in clob, json_str_output out clob);
    procedure gen_detail (json_str_output out clob);
    procedure get_tab1 (json_str_input in clob, json_str_output out clob);
    procedure gen_tab1 (json_str_output out clob);
    procedure get_tab2 (json_str_input in clob, json_str_output out clob);
    procedure gen_tab2 (json_str_output out clob);
    procedure get_tab3 (json_str_input in clob, json_str_output out clob);
    procedure gen_tab3 (json_str_output out clob);
    procedure save_tab1 (json_str_output out clob);
    procedure save_tab2 (json_str_output out clob);
    procedure save_tab3 (json_str_output out clob);
    procedure gen_report (json_str_input in clob,json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt_table(obj_data in json_object_t); 

    procedure gen_flg_status;

end HRPY12E;

/
