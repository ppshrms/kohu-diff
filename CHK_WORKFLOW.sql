--------------------------------------------------------
--  DDL for Package CHK_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CHK_WORKFLOW" is

  global_v_chken    varchar2(10 char) := hcm_secur.get_v_chken;
  v_strseq   number;
  v_flgskip   varchar2(1) := 'N';

  function  find_route(p_codapp in varchar2 ,p_codempid in varchar2,p_others in varchar2 default null) return varchar2;
  function  find_strseq(p_codapp in varchar2 ,p_codempid in varchar2) return number;
  procedure get_message(
                    p_codapp      in  varchar2 ,p_codempid in varchar2,p_lang in varchar2,
                    o_msg_to      out clob  ,o_msg_cc   out clob ,
                    p_template_to out clob  ,p_template_cc out clob ,p_func_appr out varchar2);
  function chk_nextstep(
                    p_codapp    in varchar2,p_routeno  in varchar2,
                    p_approveno in number  ,p_codempap in varchar2,
                    p_codcompap in out varchar2 ,p_codposap  in out varchar2) return varchar2;

  function send_mail_to_approve (
                                p_codapp    in varchar2 ,p_routeno  in varchar2,
                                p_approveno in number   ,p_codempap in varchar2,
                                p_codcompap in varchar2 ,p_codposap in varchar2,
                                p_msg_to    in clob     ,p_msg_cc   in clob,p_lang in number) return varchar2;
  procedure check_approve(p_codapp in varchar2,p_codapprove in varchar2);
  procedure check_assign(p_codapp in varchar2,p_codapprove in varchar2,p_codempid in varchar2);
  procedure get_message_reply(p_codapp      in varchar2 ,
                              p_codempid    in varchar2,
                              p_lang        in varchar2,
                              o_replyapp    out varchar2,
                              o_msg_to      out clob,
                              o_replyno     out varchar2,
                              o_msg_cc      out clob,
                              p_template_to out clob,
                              p_template_cc out clob,
                              p_func_appr   out varchar2,
                              p_codfrm_to   out varchar2,
                              p_codfrm_cc   out varchar2,
                              p_others in varchar2 default null);
  function get_approve_name(p_codempap in varchar2, p_codcompap in varchar2, p_codposap in varchar2,p_lang in varchar2) return varchar2;

  function  check_privilege(p_codapp     in varchar2,
                            p_codempid   in varchar2,
                            p_dtereq     in date,
                            p_numseq     in number,
                            p_approvno   in number,
                            p_codappr    in varchar2) return varchar2;

  procedure find_next_approve(p_codapp    in varchar2 ,
                              p_routeno   in out varchar2,
                              p_codempid  in varchar2,
                              p_dtereq    in varchar2,
                              p_numseq    in number,
                              p_approveno in out number,
                              p_codappr   in varchar2,
                              p_others  in varchar2 default null);-- user22 : 17/10/2017 : STA4-1701 || + p_others

--<< user22 : 17/10/2017 : STA4-1701 || move to find_next_approve
/*
--<< user22 : 02/08/2016 : STA3590307 ||
  procedure find_next_approve_leave(p_codapp    in varchar2 ,
                                    p_routeno   in out varchar2,
                                    p_codempid  in varchar2,
                                    p_dtereq    in varchar2,
                                    p_numseq    in number,
                                    p_approveno in out number,
                                    p_codappr   in varchar2,
                                    p_others  in varchar2);
-->> user22 : 02/08/2016 : STA3590307 ||
*/
-->> user22 : 17/10/2017 : STA4-1701 ||

  function get_next_approve  (p_codapp    in varchar2,
                              p_codempid  in varchar2,
                              p_dtereq    in varchar2,
                              p_numseq    in number,
                              p_approveno in number,
                              p_lang      in varchar2 ) return varchar2;
  function find_start_seq(p_codapp in varchar2 ,p_codempid in varchar2) return number;
  --<<user36 SEA-HR2201 #682 13/02/2023
  function find_codappr(p_codapp    in varchar2 ,
                        p_codempid  in varchar2,
                        p_dtereq    in date,
                        p_numseq    in number,
                        p_approveno in number) return varchar2;

  function check_emphead(p_codempid   in varchar2,
                         p_codempidh  in varchar2,
                         p_codcomph   in varchar2,
                         p_codposh    in varchar2) return varchar2;
  -->>user36 SEA-HR2201 #682 13/02/2023

  function check_next_approve(p_codapp    in varchar2,
                              p_routeno   in varchar2,
                              p_codempid  in varchar2,
                              p_dtereq    in varchar2,
                              p_numseq    in number,
                              p_approveno in number,
                              p_codappr   in varchar2) return varchar2;

  function check_next_step(  p_codapp    in varchar2,
                             p_routeno   in varchar2,
                             p_codempid  in varchar2,
                             p_dtereq    in varchar2,
                             p_numseq    in number,
                             p_approveno in number,
                             p_codappr   in varchar2) return varchar2 ;

--<< user22 : 04/07/2016 : STA3590287 ||
  function check_next_step2(p_codapp    in varchar2,
                            p_routeno   in varchar2,
                            p_codempid  in varchar2,
                            p_dtereq    in varchar2,
                            p_numseq    in number,
                            p_typreq		in varchar2,
                            p_dtework	  in varchar2,
                            p_approveno in number,
                            p_codappr   in varchar2) return varchar2;
-->> user22 : 04/07/2016 : STA3590287 ||

--<< user22 : 20/08/2016 : STA3590307 ||
	procedure find_approval(p_codapp    in varchar2,
	                        p_codempid  in varchar2,
	                        p_dtereq    in varchar2,
	                        p_numseq    in number,
	                        p_approveno in number,
	                        p_table			out varchar2,
	                        p_coderr		out varchar2);
-->> user22 : 20/08/2016 : STA3590307 ||

--<< user22 : 17/10/2017 : STA4-1701 ||
  procedure upd_tempaprq(p_routeno   in varchar2);
-->> user22 : 17/10/2017 : STA4-1701 ||

--<< user4 : 23/05/2018 : STA4-1701 ||
  procedure send_mail_to_responsible;
--<< user4 : 23/05/2018 : STA4-1701 ||
  procedure replace_text_frmmail(p_template     in clob,
                                 p_table_req    in varchar2,
                                 p_rowid        in varchar2,
                                 p_subject      in varchar2,
                                 p_codform      in varchar2,
                                 p_coduser      in varchar2,
                                 p_lang         in varchar2,
                                 p_msg          in out clob);
  --
  procedure sendmail_to_approve(p_codapp        varchar2,
                                p_codtable_req  varchar2,
                                p_rowid_req     varchar2,
                                p_codtable_appr varchar2,
                                p_codempid      temploy1.codempid%type,
                                p_dtereq        date,
                                p_seqno         number,
                                p_staappr       varchar2,
                                p_approvno      varchar2,
                                p_subject_mail_codapp  varchar2,
                                p_subject_mail_numseq  varchar2,
                                p_lang          varchar2,
                                p_coduser       varchar2,
                                p_typchg        varchar2 default null,
                                p_others        varchar2 default null);
end;

/
