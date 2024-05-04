--------------------------------------------------------
--  DDL for Package HRBF36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF36E" AS
    param_msg_error         varchar2(4000 char);
    param_msg_error_mail  varchar2(4000 char);     
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    p_codcomp               temploy1.codcomp%type;
    p_query_codempid        temploy1.codempid%type;
    p_numisr                tinsrer.numisr%type;
    p_dtechng               tchgins1.dtechng%type;
    p_dteeffec              tchgins1.dteeffec%type;
    p_flag                  varchar(50 char);
--  params tab1
    p_tab1                  json_object_t;
    p_codisrpo              tinsrer.codisrp%type;
    p_codisrp              tinsrer.codisrp%type;
    p_flgisro               tinsrer.flgisr%type;
    p_flgisr               tinsrer.flgisr%type;
    p_dtehlpsto             tinsrer.dtehlpst%type;
    p_dtehlpst             tinsrer.dtehlpst%type;
    p_dtehlpeno             tinsrer.dtehlpen%type;
    p_dtehlpen             tinsrer.dtehlpen%type;
    p_amtisrpo              tinsrer.amtisrp%type;
    p_amtisrp              tinsrer.amtisrp%type;
    p_codecovo              tinsrer.codecov%type;
    p_codecov              tinsrer.codecov%type;
    p_codfcovo              tinsrer.codfcov%type;
    p_codfcov              tinsrer.codfcov%type;
    p_flgcodcovo            tinsrer.codfcov%type;
    p_flgcodcov             tinsrer.codfcov%type;
    p_amtpmiummeo           tinsrer.amtpmiumme%type;
    p_amtpmiumme           tinsrer.amtpmiumme%type;
    p_amtpmiumyeo           tinsrer.amtpmiumye%type;
    p_amtpmiumye           tinsrer.amtpmiumye%type;
    p_amtpmiummco           tinsrer.amtpmiummc%type;
    p_amtpmiummc           tinsrer.amtpmiummc%type;
    p_amtpmiumyco           tinsrer.amtpmiumyc%type;
    p_amtpmiumyc           tinsrer.amtpmiumyc%type;
    p_remark                tchgins1.remark%type;
    p_codedit               tchgins1.codedit%type;
    p_dteedit               tchgins1.dteedit%type;
--  params tab2
    p_tab2                  json_object_t;
    p_numseq                tchgins2.numseq%type;
    p_nameinsr              tchgins2.nameinsr%type;
    p_typrelate             tchgins2.typrelate%type;
    p_dteempdb              tchgins2.dteempdb%type;
    p_status                tchgins2.flgchng%type;
    p_flgchng               tchgins2.flgchng%type;
--  params tab3
    p_tab3                  json_object_t;
    p_nambfisr              tchgins3.nambfisr%type;
    p_ratebf                tchgins3.ratebf%type;
-- params value

    p_typecal               varchar2(5 char);
    p_numfamily             number;
    p_numfamilyn            number;
    p_amtpmiummo            number;
    p_amtpmiumyo            number;
    p_amtpmiumeo            number;
    p_amtpmiumco            number;

    p_amtpmiumm             number;
    p_amtpmiumy             number;
    p_amtpmiume             number;
    p_amtpmiumc             number;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab3(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure get_valuecal(json_str_input in clob, json_str_output out clob);
  procedure get_insurance_plan(json_str_input in clob, json_str_output out clob);

END HRBF36E;

/
