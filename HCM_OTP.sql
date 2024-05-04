--------------------------------------------------------
--  DDL for Package HCM_OTP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_OTP" is
-- last update: 12/07/2021 11:31

  param_msg_error   varchar2(4000 char);
  global_v_lang     varchar2(10 char);
  p_timeotp   	    varchar2(1000 char);
  p_qtyotp 	        varchar2(1000 char);
  p_otptype 	      varchar2(1000 char);

  function rand(p_digit number) return varchar2;
  procedure call_tsetpass;
  procedure get_otp_config(json_str_input in clob,json_str_output out clob);
  procedure insert_tlogsms(p_nummobile varchar2, p_length_msg varchar2,p_codform varchar2,p_coduser varchar2);
  procedure send_otp(p_codform in varchar2, p_coduser in varchar2, p_phone in varchar2, p_lang in varchar2,
                     p_ref out varchar2, p_message_sms out long);
  procedure get_otp_setup(json_str_input in clob,json_str_output out clob);
  procedure get_otp(json_str_input in clob,json_str_output out clob);
  procedure post_otp(json_str_input in clob,json_str_output out clob);
end;

/
