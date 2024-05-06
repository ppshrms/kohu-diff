--------------------------------------------------------
--  DDL for Package HRES31X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES31X" is
-- last update: 01/12/2017 10:29

  param_msg_error     varchar2(4000 char);

  v_chken             varchar2(10 char) := hcm_secur.get_v_chken;
  v_additional        number := hcm_appsettings.get_additional_year;
  v_zyear             number;
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  global_v_lrunning   varchar2(10 char);

  b_index_codempid    varchar2(4000 char);
  p_start             number;
  p_end               number;
  p_flg               varchar2(4000 char);

  parameter_codempmt  varchar2(4000 char);
  v_view_codapp       varchar2(100 char);
  v_codtency          varchar2(4000 char);

  detail_namtitlt       varchar2(4000 char);
  detail_namfirstt      varchar2(4000 char);
  detail_namlastt       varchar2(4000 char);
  detail_tchildrn       varchar2(4000 char);
  detail_stamarry       varchar2(4000 char);
  detail_codsex         varchar2(4000 char);
  detail_codedlv        varchar2(4000 char);
  detail_codinst        varchar2(4000 char);
  detail_desnoffi       varchar2(4000 char);
  detail_numtelof       varchar2(4000 char);
  detail_desc_codcomp		varchar2(4000 char);
  detail_desc_codpos		varchar2(4000 char);
  detail_dteempmt			  varchar2(4000 char);
  detail_staemp			    varchar2(4000 char);
  detail_dteoccup			  varchar2(4000 char);
  detail_codempmt			  varchar2(4000 char);
  detail_dteefpos			  varchar2(4000 char);
  detail_typpayroll		  varchar2(4000 char);
  detail_amtincom			  varchar2(4000 char);
  detail_dteempmt_y			varchar2(4000 char);
  detail_dteempmt_m			varchar2(4000 char);
  detail_dteempdb_y			varchar2(4000 char);
  detail_dteempdb_m			varchar2(4000 char);
  detail_numappl			  varchar2(4000 char);
  detail_codpos			    varchar2(4000 char);
  detail_codcomp			  varchar2(4000 char);
  detail3_desc_codecurr  varchar2(4000 char);
  detail3_m_amttot      varchar2(4000 char);
  detail3_d_amttot      varchar2(4000 char);
  detail3_h_amttot      varchar2(4000 char);
  detail3_amtproadj      varchar2(200 char);

  type arr is table of varchar2(600) index by binary_integer;
  detail18_desother   arr;
  detail18_desvalue   arr;
  detail18_datatype   arr;

  function set_data(p_data varchar2) return varchar2;
  function get_col_comments (p_column   user_col_comments.column_name%type,
                           p_table    user_col_comments.table_name%type)
                           return user_col_comments.comments%type;
  procedure get_data_tempothr;

  procedure initial_value(json_str in clob);

  procedure hres31x_tab1(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab2(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab3(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab4(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab4_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab5_1(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab5_2(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab5_3(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab5_4(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab5_5(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab6_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab7_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab8(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab8_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab9(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab10_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab11_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab12_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab13_table_type(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab13_table(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab13_table_lang(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab13_popup(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab14_table(json_str_input in clob, json_str_output out clob);
  procedure hres31x_tab14_table_internal(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab15_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab16_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab17_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab18_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab19_table(json_str_input in clob, json_str_output out clob);

  procedure hres31x_tab20(json_str_input in clob, json_str_output out clob);

  procedure saveimagesprofile(p_file_name in varchar2,p_file_data in blob,p_codempid in varchar2,p_coduser in varchar2,r_message out varchar2,r_file_data out blob);
  procedure getimagesprofile(p_codempid in varchar2, r_file_name out varchar2,r_codempid out varchar2,r_file_data out blob);

END; -- Package spec

/
