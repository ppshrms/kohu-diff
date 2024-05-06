--------------------------------------------------------
--  DDL for Package HRBF5JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5JE" as

-- last update: 27/01/2021 17:31

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
	global_v_zwrklvl	        number;
	global_v_numlvlsalst	    number;
	global_v_numlvlsalen	    number;
	global_v_zupdsal		      varchar2(4 char);

  p_codempid                temploy1.codempid%type;
  p_codlon                  ttyploan.codlon%type;
  p_amtlonap                tintrted.amtlon%type;

  type arr_1d is table of varchar2(4000 char) index by binary_integer;
  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail_rateilon(json_str_input in clob, json_str_output out clob);
  procedure get_popupdetail(json_str_input in clob, json_str_output out clob);
  procedure get_popuptable(json_str_input in clob, json_str_output out clob);
  procedure cal_loan (json_str_input in clob, json_str_output out clob);
  function get_latest_dteeffec(v_codcompy in varchar2,v_codlon  in varchar2) return varchar2;
end hrbf5je;

/
