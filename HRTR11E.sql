--------------------------------------------------------
--  DDL for Package HRTR11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR11E" AS

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';
    global_v_zyear      number := 0;
    param_json          json_object_t;

    p_codcours          tcourse.codcours%type;
    p_codcoursCopy      tcourse.codcours%type;

    v_tcourse           tcourse%rowtype;
    v_tcoursub          tcoursub%rowtype;
    v_tcomptcr          tcomptcr%rowtype;
    v_tskilscor         tskilscor%rowtype;

    p_tab1              json_object_t;
    p_tab2              json_object_t;
    p_tab2_detail       json_object_t;
    p_tab2_table        json_object_t;
    p_tab3              json_object_t;

    isAdd               boolean;
    isEdit              boolean;
    isCopy              varchar2(1);
    p_flgcopy           varchar2(1);    

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure save_detail(json_str_input in clob, json_str_output out clob);

    procedure get_copylist(json_str_input in clob, json_str_output out clob);

END HRTR11E;

/
