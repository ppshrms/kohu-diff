--------------------------------------------------------
--  DDL for Package HRPY21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY21E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  obj_data          json_object_t;
  obj_row           json_object_t;

  p_codpay          varchar2(4 char);
  p_descpaye        varchar2(150 char);
  p_descpayt        varchar2(150 char);
  p_descpay3        varchar2(150 char);
  p_descpay4        varchar2(150 char);
  p_descpay5        varchar2(150 char);
  p_typpay          varchar2(1 char);
  p_flgtax          varchar2(1 char);
  p_flgfml          varchar2(1 char);
  p_formula         varchar2(500 char);
  p_flgcal          varchar2(1 char);
  p_flgform         varchar2(1 char);
  p_flgwork         varchar2(1 char);
  p_flgsoc          varchar2(1 char);
  p_flgpvdf         varchar2(1 char);
  p_typinc          varchar2(4 char);
  p_typpayr         varchar2(4 char);
  p_typpayt         varchar2(4 char);
  p_codtax          varchar2(4 char);
  desc_codtax       varchar2(150 char);
  p_dteeffec        date;
  p_amtmin          number(9,2);
  p_amtmax          number(9,2);
  p_taxpayr         varchar2(4 char);
  p_typincpnd       varchar2(4 char);
  p_typincpnd50     tinexinf.typincpnd50%type;
  p_desctaxe        varchar2(150 char);
  p_desctaxt        varchar2(150 char);
  p_desctax3        varchar2(150 char);
  p_desctax4        varchar2(150 char);
  p_desctax5        varchar2(150 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_formula(json_str_input in clob, json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);
  procedure get_codtax_detail(json_str_input in clob, json_str_output out clob);
  procedure get_formula(json_str_input in clob, json_str_output out clob);
  procedure static_report(json_str_input in clob, json_str_output out clob);
end HRPY21E;

/
