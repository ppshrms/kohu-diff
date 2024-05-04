--------------------------------------------------------
--  DDL for Package HRPYB6E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYB6E" as

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  -- get parameter search index
  p_codpfinf                tpfmemb.codpfinf%type;
  p_codcomp                 temploy1.codcomp%type;
  p_codempid                temploy1.codempid%type;

  function is_number (p_string in varchar2) return int;
  --
  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_import_data(v_codempid   in varchar2,
                              v_amteaccu   in varchar2,
                              v_amtintaccu in varchar2,
                              v_amtcaccu   in varchar2,
                              v_amtinteccu in varchar2,
                              v_codplan    in varchar2,
                              v_err_text  out varchar2);
  --
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  --
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  --
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure import_data (json_str_input in clob, json_str_output out clob);
  procedure insert_tpfmlog(v_codempid     in varchar2,
                           v_field_name   in varchar2,
                           v_numseq       in number,
                           v_desold       in varchar2,
                           v_desnew       in varchar2);

  procedure insert_tpfbflog(v_codempid     in varchar2,
                           v_codplan       in varchar2,
                           v_amteaccu      in varchar2,
                           v_amtcaccu      in varchar2,
                           v_amtintaccu    in varchar2,
                           v_amtinteccu    in varchar2);

end HRPYB6E;

/
