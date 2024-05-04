--------------------------------------------------------
--  DDL for Package HRAL5CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5CX" as
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';

  global_v_zyear          number;
  global_v_zminlvl        number;
  global_v_zwrklvl        number;
  global_v_numlvlsalst    number;
  global_v_numlvlsalen    number;
  global_v_zupdsal        varchar2(4 char);

  p_codapp                varchar2(10 char) := 'HRAL5CX';
  p_index_rows            varchar2(8 char);

  p_codempid              varchar2(4000 char);
  p_codempid2             varchar2(4000 char);
  p_codcomp               varchar2(4000 char);
  p_year                  varchar2(4000 char);
  p_typleave              json_object_t;
  p_typleave2             varchar2(4000 char);
  str_typleave            varchar2(4000 char);
  p_codleave              varchar2(4000 char);

  json_index_rows         json_object_t;
  isInsertReport          boolean := false;
  p_codleave_array        json_object_t;

  function get_qtyavgwk(v_codcomp varchar2, v_codempid varchar2) return number;
  function day_to_dhhmm(v_day number,v_qtyavgwk number) return varchar2;
  procedure initial_value(json_str_input in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure check_index;
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure check_detail;
  procedure gen_detail(json_str_output out clob);

  procedure get_label(json_str_input in clob,json_str_output out clob);
  procedure check_label;
  procedure gen_label(json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t, p_dtecycst date);

  function convert_typleave_to_str (json_typleave json_object_t) return varchar2;
  function cal_dhm_concat (p_qtyday number, v_qtyavgwk number) return varchar2;

  procedure save_index (json_str_input in clob, json_str_output out clob);

  procedure get_day(p_dtecycst in date,p_month in number,p_dtestr out date,p_dteend out date);
end HRAL5CX;


/
