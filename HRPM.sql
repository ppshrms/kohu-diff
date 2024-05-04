--------------------------------------------------------
--  DDL for Package HRPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM" is
  p_lang                varchar2(15) := '102';
  p_coduser             varchar2(15) := 'AUTO';
  p_codapp              varchar2(30 char);
  para_codapp           varchar2(30 char);
  p_codapp_receiver     varchar2(30 char);
  p_codapp_file         varchar2(30 char);
  --
  procedure hrpmate;                                                                                                                                                                                                                                                                                                          v_chken   varchar2(4)   := check_emp(get_emp) ;
  --
  procedure gen_birthday (p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date);
                          
  procedure gen_probation(p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date);
  procedure gen_probationn( p_codcompy  in varchar2,
                            flg_log     in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_typemail  in varchar2);
  procedure gen_probationp( p_codcompy  in varchar2,
                            flg_log     in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_typemail  in varchar2);

  procedure gen_file (p_codcompy in varchar2,
                      p_mailalno in varchar2,
                      p_dteeffec in date,
                      p_where    in varchar2,
                      p_seq      in number,
                      p_typemail in varchar2);
  --
  procedure gen_ttmovemt (p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date);

  procedure check_ttmovemt (p_codempid  in varchar2,
                            p_dteeffect in date,
                            p_numseq    in number,
                            p_codobf    in varchar2,
                            p_datachg   in out varchar2,
                            p_numobfn   in out number,
                            p_amtwidrwn in out number,
                            p_qtywidrwn in out number,
                            p_numobfo   in out number,
                            p_amtwidrwo in out number,
                            p_qtywidrwo in out number);
  procedure sendmail_ttmovemt(p_codempid  in varchar2,
                              p_dteeffect in date,
                              p_numseq    in number,
                              p_codcompy  in varchar2,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date,
                              p_codsend   in varchar2,
                              p_typemail  in varchar2,
                              p_message   in clob,
                              p_mail_message    in clob,
                              p_filname   in varchar2,
                              p_typesend  in varchar2);
  procedure replace_text_ttmovemt (p_msg       in out clob,
                                   p_template  in clob,
                                   p_codempid  in varchar2,
                                   p_dteeffect in date,
                                   p_numseq    in number,
                                   p_codsend   in varchar2,
                                   p_codcompy  in varchar2,
                                   p_mailalno  in varchar2,
                                   p_dteeffec  in date,
                                   p_typemail  in varchar2,
                                   p_mail_message    in clob,
                                   p_typesend  in varchar2);
  --
  procedure gen_prbcodpos(p_codcompy in varchar2,
                          flg_log    in varchar2,
                          p_mailalno in varchar2,
                          p_dteeffec in date);

  procedure gen_prbcodposn( p_codcompy  in varchar2,
                            flg_log     in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date);

  procedure gen_prbcodposp( p_codcompy  in varchar2,
                            flg_log     in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date);

  function check_stmt (p_syncond    varchar2) return varchar2;
  --
  procedure gen_public_holiday (p_codcompy  in varchar2,
                                flg_log in varchar2,
                                p_mailalno in varchar2,
                                p_dteeffec in date);
  procedure sendmail_public( p_codempid  in varchar2,
                             p_mailalno  in varchar2,
                             p_dteeffec  in date,
                             p_dtepublic in date,
                             p_codsend   in varchar2,
                             p_typemail  in varchar2,
                             p_subject   in varchar2,
                             p_message   in clob,
                             p_filename  in varchar2,
                             p_typesend  in varchar2);
  procedure replace_text_public(p_msg       in out clob,
                                p_template  in clob,
                                p_codempid  in varchar2,
                                p_codsend   in varchar2,
                                p_mailalno  in varchar2,
                                p_dteeffec  in date,
                                p_dtepublic in date,
                                p_typemail  in varchar2,
                                p_typesend  in varchar2);
  --
  procedure gen_resign (p_codcompy in varchar2,
                        flg_log    in varchar2,
                        p_mailalno in varchar2,
                        p_dteeffec in date);
  procedure sendmail_resign  (p_codcompy  in varchar2,
                              p_codempid  in varchar2,
                              p_dteeffect in date,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date,
                              p_codsend   in varchar2,
                              p_typemail  in varchar2,
                              p_message   in clob,
                              p_filname   in varchar2,
                              p_typesend  in varchar2) ;
  procedure replace_text_resign   (p_msg       in out clob,
                                   p_template  in clob,
                                   p_codempid  in varchar2,
                                   p_dteeffect in date,
                                   p_codsend   in varchar2,
                                   p_codcompy  in varchar2,
                                   p_mailalno  in varchar2,
                                   p_dteeffec  in date,
                                   p_typemail  in varchar2,
                                   p_typesend  in varchar2);
  procedure gen_conditions  (p_codempid  in varchar2,
                             p_codapp    in varchar2,
                             p_subject   in varchar2,
                             p_numdatets in out number,
                             p_numdatinf in out number,
                             p_numdatpay in out number,
                             p_numdatdet in out number);
  ----
  procedure gen_retire(p_codcompy  in varchar2,
                       flg_log     in varchar2,
                       p_mailalno  in varchar2,
                       p_dteeffec  in date);
  --
  procedure gen_newemp(p_codcompy  in varchar2,
                       flg_log     in varchar2,
                       p_mailalno  in varchar2,
                       p_dteeffec  in date);
                       
  procedure gen_exprworkpmit(p_codcompy  in varchar2,
                             flg_log     in varchar2,
                             p_mailalno  in varchar2,
                             p_dteeffec  in date);
                             
  procedure gen_exprvisa(p_codcompy  in varchar2,
                         flg_log     in varchar2,
                         p_mailalno  in varchar2,
                         p_dteeffec  in date);
                         
  procedure gen_exprdoc(p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date);

  procedure gen_congratpos(p_codcompy  in varchar2,
                           flg_log     in varchar2,
                           p_mailalno  in varchar2,
                           p_dteeffec  in date);

  procedure gen_congratnewemp(p_codcompy  in varchar2,
                              flg_log     in varchar2,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date);
                              
  procedure sendmail_alert( p_codcompy  in varchar2,
                            p_codempid  in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_codsend   in varchar2,
                            p_typemail  in varchar2,
                            p_message   in clob,
                            p_filname   in varchar2,
                            p_typesend  in varchar2);
                            
  procedure sendmail_group( p_codcompy  in varchar2,
                            p_codempid  in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_codsend   in varchar2,
                            p_typemail  in varchar2,
                            p_message   in varchar2,
                            p_filname   in varchar2,
                            p_typesend  in varchar2,
                            p_seqno     in number);
                            
  procedure replace_text_sendmail(p_msg        in out clob,
                                   p_template  in clob,
                                   p_codempid  in varchar2,
                                   p_codsend   in varchar2,
                                   p_codcompy  in varchar2,
                                   p_mailalno  in varchar2,
                                   p_dteeffec  in date,
                                   p_typemail  in varchar2,
                                   p_typesend  in varchar2);
  --
  procedure auto_execute_mail (p_codcompy   in varchar2,
                               p_mailalno   in varchar2,
                               p_dteeffec   in date,
                               p_codempid   in varchar2,
                               p_msg_to     in clob,
                               p_typemail   in varchar2,
                               p_file       in varchar2,
                               p_typesend   in varchar2);

  procedure auto_execute_mail_group (p_codcompy   in varchar2,
                               p_mailalno   in varchar2,
                               p_dteeffec   in date,
                               p_codempid   in varchar2,
                               p_msg_to     in clob,
                               p_typemail   in varchar2,
                               p_file       in varchar2,
                               p_typesend   in varchar2,
                               p_seqno      in number);

  procedure insert_talertlog (p_codcompy  in varchar2,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date,
                              p_fieldc1   in varchar2,
                              p_fieldc2   in varchar2,
                              p_fieldc3   in varchar2,
                              p_fieldc4   in varchar2,
                              p_fieldc5   in varchar2,
                              p_fieldd1   in date,
                              p_fieldd2   in date,
                              p_fieldd3   in date);

  procedure find_approve_name(p_codempid    in varchar2,
                              p_seqno       in number,
                              p_flgappr     in varchar2,
                              p_codempap    in varchar2,
                              p_codcompap   in varchar2,
                              p_codposap    in varchar2,
                              p_codapp      in varchar2,
                              p_coduser     in varchar2,
                              p_stcodempid  in varchar2);
                              

--  procedure insert_ttemprpt2(p_codempid in varchar2,p_codapp in varchar2,
--                            p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,
--                            p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,
--                            p_item7 in varchar2,p_temp31 in number);
END;

/
