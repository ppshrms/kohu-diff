--------------------------------------------------------
--  DDL for Package CHK_FLOWMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CHK_FLOWMAIL" is

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


  procedure get_message(p_codapp      in varchar2 ,
                        p_lang        in varchar2,
                        o_msg_to      out clob  ,
                        p_template_to out clob  ,
                        p_func_appr   out varchar2);

  procedure get_message_reply(p_codapp      in varchar2,
                              p_lang        in varchar2,
                              p_staappr     in varchar2,
                              o_msg_to      out clob,
                              o_template_to out clob);

  function check_approve (p_codapp   in varchar2,
                          p_codempid in varchar2,
                          p_approvno in out number,--(nvl(a.approvno,0) + 1)
                          p_codappr  in varchar2,
                          p_codcomp  in varchar2,
                          p_codpos   in varchar2,
                          p_check    out varchar2)   --out Y/N/HR2010
                          return boolean;

  function check_codappr (p_codapp   in varchar2,
                          p_codappr  in varchar2)   --out Y/N/HR2010
                          return boolean;

  function send_mail_to_approve (p_codapp    in varchar2 ,
                                 p_codempid  in varchar2,
                                 p_codrcord  in varchar2,
                                 p_msg_to    in clob,
                                 p_file      in long,
                                 p_subject   in varchar2,
                                 p_fromtype  in varchar2,
                                 p_staappr   in varchar2,
                                 p_lang      in number,
                                 p_approvno  in number,
                                 p_codcomp   in varchar2,
                                 p_codpos    in varchar2,
                                 p_attach_mode    in varchar2 default null)
                                 return varchar2;

  function send_mail_for_approve (p_codapp          in varchar2 ,
                                 p_codempid         in varchar2,
                                 p_codrcord         in varchar2,
                                 p_coduser          in varchar2,
                                 p_file             in long,
                                 p_subject_codapp   in varchar2,
                                 p_subject_numseq   in number,
                                 p_fromtype         in varchar2,
                                 p_staappr          in varchar2,
                                 p_approvno         in number,
                                 p_codcomp          in varchar2,
                                 p_codpos           in varchar2,
                                 p_table_req        in varchar2,
                                 p_rowid            in varchar2,
                                 p_typparam         in varchar2,
                                 p_attach_mode      in varchar2 default null)
                                 return varchar2;

  function send_mail_reply(p_codapp    in varchar2 ,
                           p_codempid  in varchar2,
                           p_codreq    in varchar2,
                           p_codappr   in varchar2,
                           p_coduser   in varchar2,
                           p_file      in long,
                           p_subject_codapp in varchar2,
                           p_subject_numseq in number,
                           p_fromtype  in varchar2,
                           p_staappr   in varchar2,
                           p_approvno  in number,
                           p_codcomp   in varchar2,
                           p_codpos    in varchar2,
                           p_table_req        in varchar2,
                           p_rowid            in varchar2,
                           p_typparam         in varchar2,
                           p_attach_mode    in varchar2 default null)
                           return varchar2;

  procedure check_attachfile (p_codapp   in varchar2,
                              p_codempid in varchar2,
                              p_coduser  in varchar2,
                              p_approvno in number,
                              p_codcomp  in varchar2,
                              p_codpos   in varchar2);

  procedure replace_text_frmmail(p_template     in clob,
                                 p_table_req    in varchar2,
                                 p_rowid        in varchar2,
                                 p_subject      in varchar2,
                                 p_codform      in varchar2,
                                 p_typparam     in varchar2,
                                 p_func_appr    in varchar2,
                                 p_coduser      in varchar2,
                                 p_lang           in varchar2,
                                 p_msg           in out clob,
                                 p_chkparam    in varchar2 default 'Y',
                                 p_file   in long  default null);

  procedure replace_param(p_table_req    in varchar2,
                           p_rowid        in varchar2,
                           p_codform      in varchar2,
                           p_typparam     in varchar2,
                           p_lang         in varchar2,
                           p_msg          in out clob,
                           p_chkparam    in varchar2 default 'Y');


  procedure get_message_result(p_codform      in varchar2 ,
                               p_lang        in varchar2,
                               o_msg_to      out clob  ,
                               p_template_to out clob);

  function send_mail_to_emp (p_codempid  in varchar2,
                                        p_codrcord   in varchar2,
                                        p_msg_to    in clob,
                                        p_file           in long,
                                        p_subject     in varchar2,
                                        p_fromtype   in varchar2,
                                        p_lang          in number,
                                        p_filename1 in varchar2 default null,
                                        p_filename2 in varchar2 default null,
                                        p_filename3 in varchar2 default null,
                                        p_attach_mode in varchar2 default null,
                                        p_fixemail in varchar2 default null,
                                        p_func_appr  in varchar2 default null,
                                        p_codappr    in varchar2 default null)
                                        return varchar2;

--function get_emp_mail_lang(p_codempid   in varchar2) return varchar2; -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 28/03/2024 | Fix issue 4449#1746
  function get_emp_mail_lang(p_codempid   in varchar2,p_default_lang in varchar2 default '101') return varchar2;
  procedure get_receiver (p_codapp        in varchar2 ,
                            p_codempid      in varchar2,
                            p_fromtype      in varchar2,
                            p_approvno      in number,
                            p_codcomp       in varchar2,
                            p_codpos        in varchar2,
                            a_receiver      out t_array_var2,
                            v_qty_receiver  out number);
end; -- Package spec

/
