--------------------------------------------------------
--  DDL for Package HRAL9DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL9DE" is

  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  param_msg_error       varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  obj_data              json_object_t;
  obj_row               json_object_t;

  p_codapp              varchar2(10 char) := 'HRAL9DE';
  p_index_rows          varchar2(8 char);

  p_codpay              varchar2(4 char);
  p_codcompy            varchar2(500 char);
  p_dteeffec            date;
  p_codcompyQuery       varchar2(4000 char);
  p_codpayQuery         varchar2(4000 char);
  p_dteeffecQuery       date;
  p_numseq              number;
  p_numseqOld           number;
  p_syncond_json        json_object_t;
  p_synconds            clob;
  p_syncondd            clob;
  p_statement           clob;
  p_typwork             varchar2(1 char);
  p_qtyhrwks            number;
  p_qtyhrwke            number;
  p_timstrtw            varchar2(4 char);
  p_timendw             varchar2(4 char);
  p_formula             varchar2(500 char);
  p_flg                 varchar2(10 char);
  p_rowid               varchar2(1000 char);
  p_codcompy_lv1        tcompny.codcompy%type;
  p_typpayot            tcontals.typpayot%type;
  p_flgotb              tcontals.flgotb%type;
  p_flgotd              tcontals.flgotd%type;
  p_flgota              tcontals.flgota%type;

  v_typwork             varchar2(1 char);
  v_syncond             clob;
  v_statement           clob;

  p_dteeffecOld        date;
  isEdit               boolean := false;
  isAdd                boolean := false;
  isCopy               varchar2(1 char) := 'N';
  forceAdd             varchar2(1 char) := 'N';
  v_indexdteeffec      date;
  v_rowid              varchar2(4000 char);

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  procedure get_index(json_str_input in clob, json_str_output out clob);

  procedure get_detailpay_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detailpay_detail(json_str_output out clob);
  procedure get_detailpay_table(json_str_input in clob, json_str_output out clob);
  procedure gen_detailpay_table(json_str_output out clob);
  --procedure get_qualification_list(json_str_input in clob, json_str_output out clob);
  --procedure get_paycondition_list(json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);

  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob,json_str_output out clob);
  procedure delete_index(json_str_input in clob,json_str_output out clob);

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;

  function chk_flgtran(p_codcompy in varchar2, p_codpay in varchar2, p_dteeffec in date) return boolean;
end HRAL9DE;

/
