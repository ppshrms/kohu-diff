--------------------------------------------------------
--  DDL for Package HRAL91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL91E" is
-- last update: 04/01/2018 12:23

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codapp                  varchar2(10 char) := 'HRAL91E';
  p_codempid                varchar2(4000 char);
  p_codempid_query          varchar2(4000 char);
  p_codcompy                varchar2(4000 char);
  p_dteeffec                date;
  p_codcompyQuery           varchar2(4000 char);
  p_dteeffecQuery           date;
  p_dteeffecOld             date;
  p_typabs                  varchar2(4000 char);
  isEdit                    boolean := false;
  isAdd                     boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';

  json_input_obj            json_object_t;
  isInsertReport            boolean := false;
  v_msqerror                varchar2(4000 char);
  v_detailDisabled          boolean;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;

  procedure get_tab1_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_detail (json_str_output out clob);
  procedure get_tab1_table1 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_table1 (json_str_output out clob);
  procedure get_tab1_table2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_table2 (json_str_output out clob);
  procedure get_data_tcontal4 (json_str_input in clob, json_str_output out clob);
  procedure gen_data_tcontal4 (json_str_output out clob);


  procedure get_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab2 (json_str_output out clob);
  procedure get_tab3 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab3 (json_str_output out clob);

  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure save_tab1_detail (json_str_output out clob);
  procedure save_tab1_table1 (json_str_output out clob);
  procedure save_tab1_table2 (json_str_output out clob);
  procedure save_data_tcontal4 (json_str_output out clob);
  procedure save_tab2 (json_str_output out clob);
  procedure save_tab3 (json_str_output out clob);

  procedure get_popup (json_str_input in clob, json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);
  procedure insert_ttemprpt_tab1_table2(obj_data in json_object_t);
  procedure insert_ttemprpt_tab1_table3(obj_data in json_object_t);
  procedure insert_ttemprpt_tab2(obj_data in json_object_t);
  procedure insert_ttemprpt_tab3(obj_data in json_object_t);

  function checkTcodec (codcodec in varchar2, codcodec_val in varchar2, v_typpay in varchar2 default null) return varchar2;

  procedure save_tab1_table2_update (json_current in out json_object_t, v_typabs number);
  procedure save_tab1_table2_insert (json_current in out json_object_t, v_typabs number);

  procedure save_tab1_tcontal4_update (json_current in out json_object_t, v_typabs number);
  procedure save_tab1_tcontal4_insert (json_current in out json_object_t, v_typabs number);

  procedure save_tab2_update (json_current in out json_object_t, v_typabs number, v_numseq number);
  procedure save_tab2_insert (json_current in out json_object_t, v_typabs number, v_numseq number);

end HRAL91E;

/
