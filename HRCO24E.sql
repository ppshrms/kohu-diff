--------------------------------------------------------
--  DDL for Package HRCO24E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO24E" AS
param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          tpostn.coduser%type;
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_detail                  clob;
  obj_detail                json_object_t;
  p_flg                     varchar2(100 char);
  p_codpos                  varchar2(100 char);
  p_nampos                  varchar2(150 char);
  p_nampose                 varchar2(150 char);
  p_nampost                 varchar2(150 char);
  p_nampos3                 varchar2(150 char);
  p_nampos4                 varchar2(150 char);
  p_nampos5                 varchar2(150 char);
  p_namabb                  varchar2(150 char);
  p_namabbe                 varchar2(150 char);
  p_namabbt                 varchar2(150 char);
  p_namabb3                 varchar2(150 char);
  p_namabb4                 varchar2(150 char);
  p_namabb5                 varchar2(150 char);

  p_codposOld               varchar(150 char);
  p_namposOld               varchar(150 char);
  p_namposeOld              varchar(150 char);
  p_nampostOld              varchar(150 char);
  p_nampos3Old              varchar(150 char);
  p_nampos4Old              varchar(150 char);
  p_nampos5Old              varchar(150 char);
  p_namabbOld               varchar(150 char);
  p_namabbeOld              varchar(150 char);
  p_namabbtOld              varchar(150 char);
  p_namabb3Old              varchar(150 char);
  p_namabb4Old              varchar(150 char);
  p_namabb5Old              varchar(150 char);

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
--  procedure post_delete (json_str_input in clob, json_str_output out clob);
--  procedure delete_data (json_str_input in clob, json_str_output out clob);

  procedure save_tpostn (json_str_input in clob, json_str_output out clob);
  procedure save_data_main(json_str_input in clob, json_str_output out clob);

END HRCO24E;

/
