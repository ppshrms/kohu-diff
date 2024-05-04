--------------------------------------------------------
--  DDL for Package GEN_MAILTABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GEN_MAILTABLE" is

/*
	project 		    : ST11
	modify by 	    : User14/Krisanai Mokkapun
	modify date	 : 16/11/2020 16:01
*/

  global_v_chken    varchar2(10 char) := hcm_secur.get_v_chken;
  param_msg_error           varchar2(4000 char);
  p_lang_mail varchar2(3 char) := '102';
  p_max_column  number  := 15;
  p_flg_header  boolean;
  type t_array_var2 is table of varchar2(2000 char) index by binary_integer;
    p_column_label          t_array_var2;
    p_column_value          t_array_var2;
    p_column_width          t_array_var2;
    p_text_align            t_array_var2;
    p_column_empty    t_array_var2;


--  procedure get_message(p_codapp      in varchar2 ,
--                        p_lang        in varchar2,
--                        o_msg_to      out clob  ,
--                        p_template_to out clob  ,
--                        p_func_appr   out varchar2);

  function get_emp_mail_lang(p_codempid   in varchar2) return varchar2;

end; -- Package spec

/
