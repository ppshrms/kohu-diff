--------------------------------------------------------
--  DDL for Package HCM_LOV_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_AL" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_codec(p_table in varchar2, p_where in varchar2, p_code_name in varchar2 default 'codcodec', p_desc_name in varchar2 default 'descod') return clob;
  function get_shift(json_str_input in clob) return clob;
  function get_leave(json_str_input in clob) return clob;
  function get_type_leave(json_str_input in clob) return clob;
  function get_meeting_room(json_str_input in clob) return clob;
  function get_numotreq(json_str_input in clob) return clob;
  function get_leave_request(json_str_input in clob) return clob;
  function get_leave_request_group(json_str_input in clob) return clob;
  function get_shift_flexible_group(json_str_input in clob) return clob;    -- List Shift of Flexible Group
end;

/
