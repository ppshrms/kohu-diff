--------------------------------------------------------
--  DDL for Package HRRC3JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC3JE" AS
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

--  get_index parameter
    p_codemprc              treqest1.codemprc%type;
    p_codcomp               treqest1.codcomp%type;
    p_dtereqst              treqest1.dtereq%type;
    p_dtereqen              treqest1.dtereq%type;
--  get detail parameter
    p_codpos                treqest2.codpos%type;
    p_numreqst              treqest1.numreqst%type;
    p_codjob                treqest2.codjob%type;
--  save_index parameter
    p_dtepost               tjobpost.dtepost%type;
    p_codjobpost            tjobpost.codjobpost%type;
    p_flag                  varchar(10 char);
    p_dteclose              tjobpost.dteclose%type;
    p_welfare               treqest2.welfare%type;
    p_remark                tjobpost.remark%type;
    p_flgtrans              tjobpost.flgtrans%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_jobdescription(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure save_transfer(json_str_input in clob, json_str_output out clob);

    procedure get_export_excel_data(json_str_input in clob, json_str_output out clob);

END HRRC3JE;

/
