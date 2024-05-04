--------------------------------------------------------
--  DDL for Package HRBF90E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF90E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

    p_codempid_query        temploy1.codempid%type;
--  tab1 parameters
    p_tab1                  json_object_t;

    p_flgheal1              thisheal.flgheal1%type;
    p_remark1               thisheal.remark1%type;
    p_flgheal2              thisheal.flgheal2%type;
    p_remark2               thisheal.remark1%type;
    p_flgheal3              thisheal.flgheal3%type;
    p_remark3               thisheal.remark1%type;
    p_flgheal4              thisheal.flgheal4%type;
    p_remark4               thisheal.remark1%type;
    p_flgheal5              thisheal.flgheal5%type;
    p_remark5               thisheal.remark1%type;
    p_flgheal6              thisheal.flgheal6%type;
    p_remark6               thisheal.remark1%type;
    p_flgheal7              thisheal.flgheal7%type;
    p_remark7               thisheal.remark7%type;
    p_flgheal8              thisheal.flgheal8%type;
    p_qtysmoke              thisheal.qtysmoke%type;
    p_qtyyear8              thisheal.qtyyear8%type;
    p_qtymth8               thisheal.qtymth8%type;
    p_qtysmoke2             thisheal.qtysmoke2%type;
    p_flgheal9              thisheal.flgheal9%type;
    p_qtyyear9              thisheal.qtyyear9%type;
    p_qtymth9               thisheal.qtymth9%type;
    p_desnote               thisheal.desnote%type;
--  tab2 parameters
    p_tab2                  json_object_t;
    p_descsick              thisheald.descsick%type;
    p_dteyear               thisheald.dteyear%type;
    p_numseq                thisheald.numseq%type;
--  tab3 parameters
    p_tab3                  json_object_t;
    p_tab4                  json_object_t;
    p_descrelate            thishealf.descrelate%type;
    p_descsick2             thishealf.descsick%type;
    p_numseq2                thishealf.numseq%type;

    p_flag              varchar2(100);

procedure get_index_tab1(json_str_input in clob, json_str_output out clob);

procedure get_index_tab2(json_str_input in clob, json_str_output out clob);

procedure get_index_tab3(json_str_input in clob, json_str_output out clob);

procedure get_index_tab4(json_str_input in clob, json_str_output out clob);

procedure save_index(json_str_input in clob, json_str_output out clob);

END HRBF90E;

/
