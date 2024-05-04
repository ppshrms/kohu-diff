--------------------------------------------------------
--  DDL for Package HRCO2AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2AE" AS

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  -- global var
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  -- get val search index
  p_ttypcode                varchar2(100 char);


  --province
  p_codprov                 varchar2(4 char);
  p_codcodec                varchar2(4 char);
  p_descod                  varchar2(150 char);
  p_descode                 varchar2(150 char);
  p_descodt                 varchar2(150 char);
  p_descod3                 varchar2(150 char);
  p_descod4                 varchar2(150 char);
  p_descod5                 varchar2(150 char);
  --district
 p_coddist                  varchar2(100 char);
  p_namdist                 varchar2(150 char);
  p_namdistt                varchar2(150 char);
  p_namdiste                varchar2(150 char);
  p_namdist3                varchar2(150 char);
  p_namdist4                varchar2(150 char);
  p_namdist5                varchar2(150 char);
  p_codpost                 varchar(5 char);
  -- sub district
  p_codsubdist              varchar2(4 char);
  p_descodsubdist           varchar2(150 char);
  p_descodsubdiste          varchar2(150 char);
  p_descodsubdistt          varchar2(150 char);
  p_descodsubdist3          varchar2(150 char);
  p_descodsubdist4          varchar2(150 char);
  p_descodsubdist5          varchar2(150 char);
  p_codpostsubdist          varchar2(5 char);

  p_count                   number;

  p_rowid                   varchar2(20 char);
  p_flg                     varchar2(10 char);

  procedure get_tcodprov(json_str_input in clob,json_str_output out clob);
  procedure get_province_detail(json_str_input in clob,json_str_output out clob);
  procedure get_district_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_tcodprov(json_str_output out clob);
  procedure get_tcoddist(json_str_input in clob,json_str_output out clob);
  procedure gen_tcoddist(json_str_output out clob);
  procedure get_tsubdist(json_str_input in clob,json_str_output out clob);
  procedure delete_tcodprov(json_str_input in clob,json_str_output out clob);
  procedure delete_tcoddist(json_str_input in clob,json_str_output out clob);
  procedure save_tsubdist(json_str_input in clob,json_str_output out clob);

END HRCO2AE;

/
