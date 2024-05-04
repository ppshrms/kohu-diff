--------------------------------------------------------
--  DDL for Package HRAL2JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL2JE" as
    --global
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(10 char);
    global_v_zminlvl  		number;
    global_v_zwrklvl  		number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    global_v_day_edit  	  number := 15;
    v_zupdsal   			    varchar2(10 char);

      --value
    obj_row               json_object_t;
    obj_data              json_object_t;

    param_msg_error       varchar2(600);
    p_codempid            varchar2(1000 char);
    p_codcomp             varchar2(1000 char);
    p_codcomp_query       varchar2(1000 char);
    p_codcalen            varchar2(1000 char);
    p_month               varchar2(2 char);
    p_year                varchar2(4 char);

    v_stdate	            date;
    v_endate	            date;
    v_codshift            varchar2(10);
    v_timstrtw            varchar2(10);
    v_timendw             varchar2(10);
    v_flglog              varchar2(1 char);

    tattence_dtestrtw     date;
    tattence_dtestrtw_o   date;
    tattence_dteendw      date;
    tattence_dteendw_o    date;
    tattence_codshift     varchar2(10);
    tattence_codshift_o   varchar2(10);
    tattence_codcomp      varchar2(1000 char);
    tattence_typwork      varchar2(10);
    tattence_typwork_o    varchar2(10);

    procedure get_groupplan(json_str_input in clob,json_str_output out clob);
    procedure get_groupemp(json_str_input in clob,json_str_output out clob);
    procedure get_addemp(json_str_input in clob,json_str_output out clob);
    procedure save_groupplan(json_str_input in clob,json_str_output out clob);
    procedure save_groupemp(json_str_input in clob,json_str_output out clob);
    procedure index_save(json_str_input in clob,json_str_output out clob);
    procedure get_traditional_days(json_str_input in clob,json_str_output out clob);
    procedure get_shutdown_days(json_str_input in clob,json_str_output out clob);
    function get_log_exists (v_check_codempid varchar2, v_check_date date) return varchar2;
end HRAL2JE;

/
