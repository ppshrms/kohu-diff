--------------------------------------------------------
--  DDL for Package HCM_MASTERPAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_MASTERPAGE" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_codcomp  varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  varchar2(100 char);
  p_main_color              varchar2(100 char);
  p_advance_color           varchar2(100 char);
  p_file_name               varchar2(100 char);
  p_maillang                 varchar2(100 char);

  v_limit             number;
  v_start             number;
  v_codempid          varchar2(4000 char);
  v_staappr           varchar2(100 char);
  v_codapp            varchar2(100 char);
  v_codcomp           varchar2(100 char);

  type arr_1d is table of varchar2(4000 char) index by binary_integer;
  v_arr_staappr       arr_1d;

  procedure get_favorite(json_str_input in clob, json_str_output out clob);
  procedure save_favorite(json_str_input in clob, json_str_output out clob);

  procedure save_theme(json_str_input in clob, json_str_output out clob);

  procedure save_logo(json_str_input in clob, json_str_output out clob);

  procedure get_setting(json_str_input in clob, json_str_output out clob);

  procedure save_email_language(json_str_input in clob, json_str_output out clob);

  procedure get_all_account(json_str_input in clob, json_str_output out clob);

  -------------------------- Approve Message -----------------------------
  procedure get_approve(json_str_input in clob, json_str_output out clob);
	function  chkapprovehres71e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres74e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres77e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres32e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres34e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres36e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres62e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres6ae(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres6ie(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres6ke(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres81e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres88e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres6de(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres86e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres3be(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehress2e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehress4e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres6me(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres95e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres84e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres91e(p_codapp in varchar2,p_codappr in varchar2) return number;
	function  chkapprovehres93e(p_codapp in varchar2,p_codappr in varchar2) return number;

  ------------------------------ Request Message -------------------------

  procedure get_request_total(json_str_input in clob, json_str_output out clob);
  procedure get_request(json_str_input in clob, json_str_output out clob);
  function explode(p_delimiter varchar2, p_string long, p_limit number)return arr_1d;

end;

/
