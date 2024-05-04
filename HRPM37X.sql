--------------------------------------------------------
--  DDL for Package HRPM37X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM37X" is

  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  param_msg_error       varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  obj_data              json_object_t;
  obj_row               json_object_t;

  json_codempid_list    json_object_t;
  json_dteduepr_list    json_object_t;

  p_codcomp       ttprobat.codcomp%type;
  p_codempid      ttprobat.codempid%type;
  p_typproba      ttprobat.typproba%type;
  p_codrespr      ttprobat.codrespr%type;
  p_dteduepr_str  ttprobat.dteduepr%type;
  p_dteduepr_end  ttprobat.dteduepr%type;

  p_qtyexpand         varchar2(600 char);
  p_codrespr_report   varchar2(600 char);
  p_desnote           varchar2(600 char);
  p_codeval_name      varchar2(600 char);
  p_codeval           varchar2(600 char);
  p_codeval_position  varchar2(600 char);

  isInsertReport    boolean := false;
  numYearReport     number;
  v_numseq          number := 0;
  max_numtime_37x   varchar2(10);
  max_numseq_37x    varchar2(10);
  v_codform         varchar2(100);
  v_numgrup         varchar2(100);
  v_numseq_report   varchar(600);
  v_numtime         varchar(600);
  v_numitem         varchar(600);

  v_codcomp         temploy1.codcomp%type;
  v_codpos          temploy1.codpos%type;

  p_codempid_query  ttprobat.codempid%type;
  p_dteduepr        ttprobat.dteduepr%type;
  p_typdata         varchar2(1);
  p_dteeffec        ttmovemt.dteeffec%type;
  p_numseq          ttmovemt.numseq%type;
  p_index_rows      json_object_t;

  procedure initial_value(json_str in clob);
  procedure check_getindex;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure get_ttprobatd(json_str_input in clob, json_str_output out clob);
  procedure gen_ttprobatd(json_str_output out clob);  

  procedure get_detail_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_popup(json_str_output out clob);

  procedure initial_report(json_str in clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_report(json_str_output out clob);
  procedure clear_ttemprpt;
  procedure get_detail_report;
  procedure get_detail_report_forms;
  procedure table1;
  procedure table2;
  procedure table3;
  procedure table31;
  procedure table4;
  procedure table41;
  procedure table5;
  procedure table51;

end HRPM37X;

/
