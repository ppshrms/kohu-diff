--------------------------------------------------------
--  DDL for Package HRTR67X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR67X" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_lrunning         varchar2(10 char);

  p_codapp                  varchar2(10 char) := 'HRT67X';
  p_year                    varchar2(4 char) ;
  p_codcomp                 thistrnn.codcomp%type;
  p_codcours                thistrnn.codcours%type;
  p_generation              varchar2(4 char) ;
  p_codempid_query          thistrnn.codempid%type;
  p_dtecrte                 thistrnn.dtecrte%type;
  p_codcrte                 thistrnn.codcomp%type;
  p_codcrte_position        varchar2(100 char);
  p_remark                  varchar2(100 char);
  p_dtetrst                 varchar2(100 char);
  p_dtetren                 varchar2(100 char);
  p_desc_codempid           varchar2(100 char);
  p_dtecrte_2               varchar2(100 char);

  -- index
  p_coduser                 tusrprof.coduser%type;

 -- p_codcomp                 temploy1.codcomp%type;
  p_typeauth                tusrprof.typeauth%type;
  p_typeuser                tusrprof.typeuser%type;
  -- save index
  json_params               json;

  p_codsecu                 tsecurh.codsecu%type;
  p_codproc                 tprocess.codproc%type;
    -- specific report
  isInsertReport            boolean := false;
  json_coduser              json;

  procedure initial_value (json_str in clob) ;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure check_index;
  procedure check_dtecrte;
  procedure update_dtecrte;
  procedure clear_ttemprpt;

  procedure insert_ttemprpt_thistrnn(obj_data in json);
  procedure get_position (json_str_input in clob, json_str_output out clob) ;
  procedure gen_report(json_str_input in clob, json_str_output out clob);

end HRTR67X;


/
