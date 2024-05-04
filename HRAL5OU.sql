--------------------------------------------------------
--  DDL for Package HRAL5OU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5OU" as
/* Cust-Modify: std */
-- last update: 23/12/2022 12:02
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char);
    para_zyear              number := 0;

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_chken     	    varchar2(4000 char) := hcm_secur.get_v_chken;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);
    p_data                  number := 0;
    p_secur                 boolean := false; --24/03/2021
    p_codempid              temploy1.codempid%type;
    p_codcomp               tcenter.codcomp%type;
    p_year                  varchar2(4000 char);
    p_dtestr                date;
    p_dteend                date;
    p_dtereq                date;
    p_flgreq                varchar2(4000 char);
    p_staappr               varchar2(4000 char);
    p_numperiod             number;
    p_dtemthpay             number;
    p_dteyrepay             number;
    p_codappr               varchar2(4000 char);
    p_dteappr               date;
--    p_remarkap              varchar2(4000 char);
    p_remarkApprove         varchar2(4000 char);
    p_remarkReject          varchar2(4000 char);
    param_json              json_object_t;
    p_dteyear               number;
    p_amtlepay              number;
    p_qtylepay              varchar2(4000 char);
    p_qtybalance            varchar2(4000 char);
    p_day                   number;
    p_hour                  number;
    p_min                   number;

    function ddhrmi_to_dd(v_time varchar2,v_codempid varchar2) return number;
    procedure initial_value(json_str_input in clob);

    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    function chk_exempt(p_codempid varchar2) return varchar2;
    procedure gen_index(json_str_output out clob);

    procedure get_edit(json_str_input in clob,json_str_output out clob);
    procedure check_edit;
    procedure gen_edit(json_str_output out clob);

    procedure get_save(json_str_input in clob,json_str_output out clob);
    procedure gen_save(json_str_output out clob);

    procedure delete_data (v_codempid in varchar2,v_dteyear in number ,
                           v_dtereq in date      ,v_flgreq in varchar2);
    procedure approve_data (v_staappr    in varchar2 ,v_codempid  in varchar2,
                            v_codleave  in varchar2 ,v_dteyear   in number  ,
                            v_dtereq    in date     ,v_flgreq    in varchar2,
                            v_numperiod in number   ,v_dtemthpay in number  ,
                            v_dteyrepay in number   ,v_remarkap  in varchar2,
                            v_codappr   in varchar2 ,v_dteappr   in date,
                            v_row_id    in number);

    procedure send_approve(json_str_input in clob,json_str_output out clob);
    procedure check_approve;
    procedure approve_data (json_str_output out clob);

    procedure post_save(json_str_input in clob,json_str_output out clob);
    procedure save_data(json_str_output out clob);
end HRAL5OU;

/
