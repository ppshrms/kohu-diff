--------------------------------------------------------
--  DDL for Package ALERTMSG_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "ALERTMSG_TR" is
  p_lang                varchar2(15 char) := '102';
  p_coduser             varchar2(15 char) := 'AUTO';
  p_codapp              varchar2(30 char);
  p_codapp_receiver     varchar2(30 char);
  p_codapp_file         varchar2(30 char);

  procedure batchauto;
  procedure gen_typemail1(p_codcompy varchar2, flg_log in varchar2,p_mailalno varchar2,p_dteeffec date,p_auto varchar2);
  procedure gen_typemail2(p_codcompy varchar2, flg_log in varchar2,p_mailalno varchar2,p_dteeffec date,p_auto varchar2);
  procedure gen_typemail3(p_codcompy varchar2, flg_log in varchar2,p_mailalno varchar2,p_dteeffec date,p_auto varchar2);
  procedure gen_typemail4(p_codcompy varchar2, flg_log in varchar2,p_mailalno varchar2,p_dteeffec date,p_auto varchar2);

  procedure gen_file (p_codcompy in varchar2,
                             p_mailalno in varchar2,
                             p_dteeffec in date,
                             p_where    in varchar2,
                             p_seq      in number,
                             p_typemail in varchar2);

  procedure insert_ttemprpt(p_codempid in varchar2,p_codapp in varchar2,p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,p_item7 in varchar2,p_item8 in varchar2,p_item9 in varchar2,p_item10 in varchar2,p_item11 in varchar2,p_item12 in varchar2,p_item13 in varchar2,p_item14 in varchar2,p_item15 in varchar2);
  procedure sendmail_alert( p_codcompy  in varchar2,
                            p_codempid  in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_codsend   in varchar2,
                            p_typemail  in varchar2,
                            p_message   in varchar2,
                            p_filname   in varchar2,
                            p_typesend  in varchar2);
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

  procedure auto_execute_mail_group (p_codcompy   in varchar2,
                               p_mailalno   in varchar2,
                               p_dteeffec   in date,
                               p_codempid   in varchar2,
                               p_msg_to     in clob,
                               p_typemail   in varchar2,
                               p_file       in varchar2,
                               p_typesend   in varchar2,
                               p_seqno      in number);

end ALERTMSG_TR;

/
