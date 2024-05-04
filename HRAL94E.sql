--------------------------------------------------------
--  DDL for Package HRAL94E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL94E" is
-- last update: 15/01/2018 10:50

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codapp                  varchar2(10 char) := 'HRAL94E';

  p_codempid                varchar2(4000 char);
  p_codempid_query          varchar2(4000 char);
  p_codcompy                tcontraw.codcompy%type;
  p_codaward                tcontraw.codaward%type;
  p_dteeffec                tcontraw.dteeffec%type;
  p_codcompyQuery           varchar2(4000 char);
  p_codawardQuery           varchar2(4000 char);
  p_dteeffecQuery           date;
  p_dteeffecOld             date;

  isEdit                    boolean := true;
  isadd                     boolean := false;
  isAddOrigin               boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';
  v_flgadd                  boolean := false;
  v_indexdteeffec           date;
  p_isAddOrigin             varchar2(10 char);

  json_input_obj            json_object_t;
  v_msqerror                varchar2(4000 char);
  v_detailDisabled          boolean;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;
  procedure get_tab1_detail (json_str_input in clob, json_str_output out clob);
  procedure get_tab1_table1 (json_str_input in clob, json_str_output out clob);
  procedure get_tab1_table2 (json_str_input in clob, json_str_output out clob);
  procedure get_tab1_table3 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_detail (json_str_output out clob);
  procedure gen_tab1_table1 (json_str_output out clob);
  procedure gen_tab1_table2 (json_str_output out clob);
  procedure gen_tab1_table3 (json_str_output out clob);

  procedure get_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab2 (json_str_output out clob);

  procedure get_popup (json_str_input in clob, json_str_output out clob);

  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure save_tab1_detail (json_str_output out clob);
  procedure save_tab1_table1 (json_str_output out clob);
  procedure save_tab1_table2 (json_str_output out clob);
  procedure save_tab1_table3 (json_str_output out clob);
  procedure save_tab2 (json_str_output out clob);

  function checkTcodec (codcodec in varchar2, codcodec_val in varchar2) return varchar2;

  isInsertReport    boolean := false;

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

end HRAL94E;

/
