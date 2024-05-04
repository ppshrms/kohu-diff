--------------------------------------------------------
--  DDL for Package HCM_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOGIN" is
-- last update: 03/07/2023 10:32

  param_msg_error   varchar2(4000 char);
  v_error           varchar2(10) := 'ERROR';

  global_v_lang     varchar2(10 char) := '102';

  v_chken           varchar2(10) := check_emp(get_emp);
  p_timeotp   	    varchar2(1000 char);
  ctrl_da_01 		varchar2(1000 char);
  ctrl_da_02		varchar2(1000 char);
  ctrl_da_03		varchar2(1000 char);
  ctrl_da_04 		varchar2(1000 char);
  p_qtyotp 	        varchar2(1000 char);
  p_qtypassmax      varchar2(1000 char);
  p_qtypassmin      varchar2(1000 char);
  p_qtynopass       varchar2(1000 char);
  p_agepass 	    varchar2(1000 char);
  p_alepass         varchar2(1000 char);
  p_qtymistake      varchar2(1000 char);
  p_flgchang        varchar2(1000 char);
  p_flgaction       varchar2(1000 char);

  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  function check_pwd2 return varchar2;
  function get_user(json_str_input in clob) return clob;
  procedure get_autologin(json_str_input in clob,json_str_output out clob);

  procedure change_password(json_str_input in clob,json_str_output out clob);
  function msg_error(p_code in varchar2,p_lang in varchar2, p_table in varchar2 default null) return varchar2;
  procedure forgot_password(json_str_input in clob,json_str_output out clob);

  procedure get_label(json_str_input in clob,json_str_output out clob);
  procedure get_all_lang(json_str_input in clob,json_str_output out clob);

  procedure check_catch_authentication(json_str_input in clob,json_str_output out clob);
  procedure authen_middleware(json_str_input in clob,json_str_output out clob);
  procedure remove_tlogin(json_str_input in clob,json_str_output out clob);
  procedure update_access_time(json_str_input in clob,json_str_output out clob);

  procedure login_admin(json_str_input in clob,json_str_output out clob);
  procedure update_pdpa(json_str_input in clob,json_str_output out clob);

  procedure call_tsetpass;
  function check_ip_allow(p_ipaddr varchar2) return boolean;
  procedure get_check_otp(json_str_input in clob,json_str_output out clob);
  procedure login_setting(json_str_input in clob,json_str_output out clob);
  procedure login_sso(json_str_input in clob,json_str_output out clob);

  procedure set_pin_code_user(json_str_input in clob,json_str_output out clob);

  procedure login_pin(json_str_input in clob,json_str_output out clob);

--  new prem line
  function get_password(p_coduser in varchar2) return varchar2;
end;

/
