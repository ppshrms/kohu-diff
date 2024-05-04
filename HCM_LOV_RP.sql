--------------------------------------------------------
--  DDL for Package HCM_LOV_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_RP" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor                  number;
  v_dummy               integer;
  v_stmt                      varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_group_position(json_str_input in clob) return clob;             --LOV List of Group Position
  function get_mail_alert_number_rp(json_str_input in clob) return clob;       --LOV List of Mail Alert Number
  function get_line_of_work(json_str_input in clob) return clob;               --LOV List of Line work
  function get_line_of_work_origin(json_str_input in clob) return clob;        --LOV List of Line work
  function get_line_of_work2(json_str_input in clob) return clob;              --LOV List of Line work 2
  function get_path_no(json_str_input in clob) return clob;                    --LOV List of Path No
  function get_num_path_no(json_str_input in clob) return clob;                --LOV List of Path Number (tposplnh)
end;

/
