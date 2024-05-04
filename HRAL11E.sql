--------------------------------------------------------
--  DDL for Package HRAL11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL11E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  p_codapp          varchar2(10 char) := 'HRAL11E';
  b_index_typleave  varchar2(100 char);
  b_index_codleave  varchar2(100 char);
  p_index_rows      varchar2(8 char);

  p_typleave        varchar2(4 char);
  p_namleavty       varchar2(4000 char);
  p_namleavtye      varchar2(4000 char);
  p_namleavtyt      varchar2(4000 char);
  p_namleavty3      varchar2(4000 char);
  p_namleavty4      varchar2(4000 char);
  p_namleavty5      varchar2(4000 char);
  p_qtydlepay       varchar2(100 char);
  p_flgdlemx        varchar2(1 char);
  p_qtydlepery      number;
  p_qtytimle        number;
  p_flgtimle        varchar2(1 char);
  p_flgtype         varchar2(1 char);
  p_daylevst        number;
  p_mthlevst        number;
  p_dayleven        number;
  p_mthleven        number;
  p_flgchol         varchar2(1 char);
  p_flgwkcal        varchar2(1 char);
  p_codpay          varchar2(1000 char);
  p_pctded          number;
  -- paternity leave --
  p_codlvprgnt      varchar2(1000 char);

  p_codleave        varchar2(4 char);
  p_namleavcd       varchar2(4000 char);
  p_namleavcde      varchar2(4000 char);
  p_namleavcdt      varchar2(4000 char);
  p_namleavcd3      varchar2(4000 char);
  p_namleavcd4      varchar2(4000 char);
  p_namleavcd5      varchar2(4000 char);
  p_syncond         varchar2(1000 char);
  p_statement       clob;
  p_qtydlefw        number;
  p_qtydlebw        number;
  p_flgleave        varchar2(1 char);
  p_flgchkprgnt     varchar2(1 char);
  p_qtyminle        varchar2(1000 char);
  p_qtyminunit      varchar2(1000 char);

  isInsertReport    boolean := false;
  json_index_rows   json_object_t;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_tab_typeleave(json_str_input in clob, json_str_output out clob);
  procedure gen_tab_typeleave(json_str_output out clob);
  procedure get_tab_codeleave(json_str_input in clob, json_str_output out clob);
  procedure gen_tab_codeleave(json_str_output out clob);

  procedure get_detail_codleave(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_codleave(json_str_input in clob, json_str_output out clob);
  procedure delete_index(json_str_input in clob, json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_detail(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);

end HRAL11E;

/
