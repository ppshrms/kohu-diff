--------------------------------------------------------
--  DDL for Package AUTO_SENDMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AUTO_SENDMAIL" is
-- last update: 24/02/2021 18:01

  para_numseq  number := 0;
  p_lang_mail varchar2(3 char) := '102';
  p_lang      varchar2(3 char);
  p_zyear     number;
  p_subject   varchar2(1000 char);
  p_nummax    number := 25;

  p_max_column  number  := 15;
  type t_array_var2 is table of varchar2(2000 char) index by binary_integer;
    p_column_label    t_array_var2;
    p_column_value    t_array_var2;
    p_column_width    t_array_var2;
    p_text_align      t_array_var2;
  global_v_chken    varchar2(10 char) := hcm_secur.get_v_chken;

  procedure get_emp_mail_lang(p_codempid  in  varchar2);

  procedure hrms33u;
  procedure hrms63u;
  procedure hrms6lu;
  procedure hrms6nu;
  procedure hrms6bu;
  procedure hrms6eu;
  procedure hrms6ju;
  procedure hrms72u;
  procedure hrms75u;
  procedure hrms78u;
  procedure hrms37u;
  procedure hrms3cu;
  procedure hrms85u;
  procedure hrms89u;
  procedure hrms87u;
  procedure hrmss3u;
  procedure hrmss5u;
  procedure hrms92u;
  procedure hrms94u;
  --
  procedure find_cc(p_codempid  in  varchar2,
                    p_routeno   in  varchar2 ,
                    p_approvno  in  number,
                    p_typecc    out varchar2 ,
                    p_codempap  in out varchar2 ,
                    p_codcompap in out varchar2 ,
                    p_codposap  in out varchar2 );

  procedure replace_text(p_codapp    in varchar2,
                         p_type      in varchar2,
                         p_totemp    in number,
                         p_msg       out clob);

  procedure replace_text_app(p_msg        in out clob,
                             p_template   in varchar2,
                             p_mail_type  in varchar2,
                             p_func_appr  in varchar2,
                             p_codappr    in varchar2,
                             p_email      in varchar2,
                             p_data_table in clob,
                             p_data_list  in clob,
                             p_from       in varchar2,
                             p_subject    in varchar2);

  function formattime(ptime varchar2) return varchar2;

  procedure get_next_approve(p_codempid_temp in varchar2,
                             p_codapp_temp   in varchar2,
                             p_codapp        in varchar2,
                             p_codempid      in varchar2,
                             p_dtereq        in date,
                             p_numseq        in number,
                             p_typchg        in varchar2,
                             p_dtework       in date,
                             p_approveno     in number,
                             p_detail1       in varchar2,
                             p_detail2       in varchar2,
                             p_detail3       in varchar2,
                             p_detail4       in varchar2,
                             p_detail5       in varchar2);

  procedure get_next_approve_CC(p_codempid_temp in varchar2,
                                p_codapp_temp   in varchar2,
                                p_codapp        in varchar2,
                                p_codempid      in varchar2,
                                p_dtereq        in date,
                                p_numseq        in number,
                                p_typchg        in varchar2,
                                p_dtework       in date,
                                p_approveno     in number,
                                p_detail1       in varchar2,
                                p_detail2       in varchar2,
                                p_detail3       in varchar2,
                                p_detail4       in varchar2,
                                p_detail5       in varchar2,
                                p_codempap      in varchar2,
                                p_codcompap     in varchar2,
                                p_codposap      in varchar2);

  procedure get_next_approve_R(p_codempid_temp in varchar2,
                               p_codapp_temp   in varchar2,
                               p_codapp        in varchar2,
                               p_codempid      in varchar2,
                               p_dtereq        in date,
                               p_numseq        in number,
                               p_typchg        in varchar2,
                               p_dtework       in date,
                               p_approveno     in number,
                               p_detail1       in varchar2,
                               p_detail2       in varchar2,
                               p_detail3       in varchar2,
                               p_detail4       in varchar2,
                               p_detail5       in varchar2,
                               p_routeno       in varchar2);

  procedure upd_tautomail(p_codapp varchar2, p_codempid varchar2, p_dtereq date, p_numseq number, p_typchg varchar2, p_dtework date, p_flag number);
end; -- Package spec

/
