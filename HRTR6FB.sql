--------------------------------------------------------
--  DDL for Package HRTR6FB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6FB" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  --4. TR Module #2983
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(100 char);
  --4. TR Module #2983
  global_v_codempid         varchar2(100 char);
  global_v_lrunning         varchar2(10 char);

  p_codapp                  varchar2(10 char) := 'HRTR6FB';
  p_year                    varchar2(4 char) ;
  p_codcomp                 varchar2(100 char);
  p_codcompy                varchar2(100 char);
  p_codcours                varchar2(100 char);
  p_generation              varchar2(4 char) ;
  p_typtest                 varchar2(2 char) ;
  p_qtyscore                number := 0;
  p_dtetrst                 varchar2(100 char);
  p_dtetren                 varchar2(100 char);
  p_numperiod               number := 0;
  -- index
  p_coduser                 tusrprof.coduser%type;

  p_typeauth                tusrprof.typeauth%type;
  p_typeuser                tusrprof.typeuser%type;
  -- save index
  json_params               json;

  p_codsecu                 tsecurh.codsecu%type;
  p_codproc                 tprocess.codproc%type;
    -- specific report
  json_coduser              json;

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text        data_error;
  p_error_code  data_error;
  p_numseq      data_error;
  p_colcodempid data_error;
  p_colqtys     data_error;
  p_status      data_error;
  p_desc_status data_error;
  p_desc_status_txt data_error;

  procedure initial_value (json_str in clob) ;
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure check_generation;
  procedure check_thisclss;
  procedure update_qtyscr (json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob) ;
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) ;
  function check_is_number(p_string IN VARCHAR2) return integer;

end HRTR6FB;

/
