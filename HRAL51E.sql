--------------------------------------------------------
--  DDL for Package HRAL51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL51E" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char);

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);
    v_zyear                 varchar2(4 char) := 0;

    p_codcomp               temploy1.codcomp%type;
    p_codempid              temploy1.codempid%type;
    p_dtestr                date;
    p_dteend                date;
    p_numlereq              tlereqst.numlereq%type;
    p_codleave              tlereqst.codleave%type;
    p_dterecod              date;
    p_dteleave              date;
    -- paternity leave --
    p_dteprgntst            date;
    p_dayeupd               date;
    p_timprgnt              varchar2(100 char);
    --
    p_timstr                tlereqst.timstrt%type;
    p_timend                tlereqst.timend%type;
    p_flgleave              tlereqst.flgleave%type;
    p_deslereq              tlereqst.deslereq%type;
    p_stalereq              tlereqst.stalereq%type;
    p_dteappr               date;
    p_codappr               tlereqst.codappr%type;
    p_dtecancl              date;
    p_numlereqg             tlereqst.numlereqg%type;
    p_filename              tlereqst.filename%type;
    param_warn              varchar2(10 char) := '';
    param_flgwarn           varchar2(100 char) := '';
    p_timstr2                tlereqst.timstrt%type;
    p_timend2                tlereqst.timend%type;

    p_dtesave               date;
    p_flgtyp                varchar2(1 char);
    param_json              json_object_t;

    -- get_entitled_flagleave param
    p_typleave              varchar2(4000 char);
--    p_codleave              varchar2(4000 char);

    TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
    p_text        data_error;
    p_error_code  data_error;
    p_numseq      data_error;
    param_warn    varchar2(100 char) := '';

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure check_detail;
    procedure check_save;

    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);

    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);

    procedure get_detail_numlereq(json_str_input in clob,json_str_output out clob);
    procedure get_codshift_time(json_str_input in clob,json_str_output out clob);
    procedure get_entitled_flagleave(json_str_input in clob,json_str_output out clob);
--    procedure get_radio_buttons(json_str_input in clob,json_str_output out clob);

    procedure delete_index(json_str_input in clob,json_str_output out clob);
    procedure save_detail(json_str_input in clob,json_str_output out clob);

--    procedure get_import_process(json_str_input in clob, json_str_output out clob);
--    procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);

    procedure get_drilldown(json_str_input in clob,json_str_output out clob);
    procedure check_drilldown;
    procedure gen_drilldown(json_str_output out clob);
    procedure get_flgtype_leave (json_str_input in clob, json_str_output out clob);
    procedure get_paternity_date (json_str_input in clob, json_str_output out clob);
    function check_leave_after(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2;
  end HRAL51E;

/
