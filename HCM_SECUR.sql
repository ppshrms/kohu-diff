--------------------------------------------------------
--  DDL for Package HCM_SECUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_SECUR" is
-- last update: 17/10/2017 10:10
  v_chken varchar2(4000 char);

  function get_v_chken return varchar2;
  function hcmenc(v_data in varchar2) return varchar2;
  function hcmdec(v_data in varchar2) return varchar2;
  function hcmenc_with_key(v_data in varchar2,v_key in varchar2) return varchar2;
  function hcmdec_with_key(v_datakey in varchar2,v_key in varchar2) return varchar2;
  procedure save_tlogin(json_str clob, resp_json_str out clob);
  procedure remove_tlogin(json_str clob, resp_json_str out clob);
  function get_lrunning(json_str clob) return varchar2;
  function get_module_license(p_module varchar) return number;
  function get_timeout return number;
  procedure get_global_secur(p_coduser in varchar2,global_v_zminlvl out number,global_v_zwrklvl out number,global_v_numlvlsalst out number,global_v_numlvlsalen out number);
  function secur_codcomp(p_coduser in varchar2, p_lang in varchar2, p_codcomp in varchar2) return varchar2;
  function secur_codempid(p_coduser in varchar2, p_lang in varchar2, p_codempid in varchar2, p_chk_resign in boolean default true) return varchar2;
  function get_coderror(msg_status in varchar2,param_msg_error in varchar2,p_lang in varchar2 default '101') return varchar2;
  function get_response(msg_status in varchar2,param_msg_error in varchar2,p_lang in varchar2 default '101') return varchar2;
  function secur_codcomp_cursor(p_coduser in varchar2, p_codcomp in varchar2) return varchar2;
  function secur_codempid_cursor(p_coduser varchar2, p_numlvlst number, p_numlvlen number, p_codempid varchar2) return varchar2;
  function secur2_cursor(p_coduser varchar2, p_numlvlst number, p_numlvlen number, p_codempid varchar2) return varchar2;
  function secur_main7(p_codcomp in varchar2,p_coduser in varchar2) return varchar2;
end;

/
