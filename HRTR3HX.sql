--------------------------------------------------------
--  DDL for Package HRTR3HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR3HX" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);
  v_zupdsal                 varchar2(4 char);

  p_codapp                  varchar2(10 char) := 'HRT3NX';
  p_codcompy                varchar2(100 char);
  p_codcomp                 temploy1.codcomp%type ;
  p_contact_codempid        temploy1.codempid%type ;
  p_signer_codempid         temploy1.codempid%type ;
  p_year                    varchar2(4 char) ;
  p_from_month              varchar2(20 char) ;
  p_to_month                varchar2(20 char) ;
  p_ratio_mantrain          number;
  p_posname                 varchar2(100 char) ;

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
  --p_codapp                  varchar2(10 char) := 'HRSC01E';

  procedure initial_value (json_str in clob) ;
  procedure get_rpt (json_str_input in clob, json_str_output out clob) ;
  procedure gen_rpt (json_str_output out clob) ;
  procedure get_position (json_str_input in clob, json_str_output out clob) ;
  procedure clear_ttemprpt;

end HRTR3HX;


/
