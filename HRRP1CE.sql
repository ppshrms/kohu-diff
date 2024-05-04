--------------------------------------------------------
--  DDL for Package HRRP1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP1CE" is

  param_msg_error           varchar2(4000 char);

  p_codapp                  varchar2(10 char) := 'HRRP1CE';
  p_codcompy                tposplnd.codcomp%type;
  p_numpath                 tposplnd.numpath%type;
  p_dteeffec                tposplnh.dteeffec%type;

  p_numseq                  tposplnd.numseq%type;
  p_codpos                  tposplnd.codpos%type;
  p_codcomp                 tposplnd.codcomp%type;
  p_agework                 tposplnd.agework%type;
  p_agepos                  tposplnd.agepos%type;
  p_codlinef                tposplnd.codlinef%type;
  p_othdetail               tposplnd.othdetail%type;
  p_month                   number;
  p_year                    number;

  p_despath                 tposplnh.despathe%type;
  p_despathe                tposplnh.despathe%type;
  p_despatht                tposplnh.despatht%type;
  p_despath3                tposplnh.despath3%type;
  p_despath4                tposplnh.despath4%type;
  p_despath5                tposplnh.despath5%type;
  p_table                   json_object_t;

  json_obj                  json_object_t;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  isEdit                    boolean := true;
  isAdd                     boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';
  v_indexdteeffec           date;
  v_flgDisabled             boolean;
  p_dteeffecquery           tposplnh.dteeffec%type;


  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index_head (json_str_input in clob,json_str_output out clob);
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure get_index_table (json_str_input in clob,json_str_output out clob);
  procedure get_lov_codline (json_str_input in clob,json_str_output out clob);
  procedure post_save_index(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail(json_str_input in clob,json_str_output out clob);
  procedure post_delete_path(json_str_input in clob,json_str_output out clob);
  procedure gen_flg_status;

end hrrp1ce;

/
