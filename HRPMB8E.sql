--------------------------------------------------------
--  DDL for Package HRPMB8E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB8E" is

	param_msg_error		varchar2(4000 char);
	v_chken				    varchar2(10 char);
	global_v_coduser	varchar2(100 char);
	global_v_codpswd	varchar2(100 char);
	global_v_lang		  varchar2(10 char) := '102';
	global_v_zyear		number := 0;
	global_v_lrunning	varchar2(10 char);
	p_codcompy		    TCONTPMS.CODCOMPY%type;
	p_dteeffec		    date;

	procedure get_detail (json_str_input in clob, json_str_output out clob);

	procedure gen_detail (json_str_output out clob);
  
  function set_index_obj_data(tcontpms_rec tcontpms%rowtype) return json_object_t;
  
  procedure save_detail (json_str_input in clob, json_str_output out clob);

	procedure saveData (json_str_input in clob, json_str_output out clob);
  
	function check_codincom(p_codincom varchar2) return boolean;
  
  function check_codretro(p_codretro varchar2) return boolean;

end HRPMB8E ;

/
