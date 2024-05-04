--------------------------------------------------------
--  DDL for Package ALERTMSG_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "ALERTMSG_AL" is
  p_lang        varchar2(15 char) := '102';
  p_coduser     varchar2(15 char) := 'TJS00001';

  procedure batchauto;
  procedure gen_typemail1(p_codcompy varchar2 ,p_mailalno varchar2,p_dteeffec date,p_auto varchar2);
  procedure gen_recipient(p_codcompy varchar2,p_mailalno varchar2,p_dteeffec date,p_seqno number,p_flgappr varchar2,p_codempap varchar2,p_codcompap varchar2, p_codposap varchar2, p_coduser varchar2, p_codapp varchar2);
  procedure gen_email(p_codcompy varchar2 ,p_mailalno varchar2,p_dteeffec date,p_coduser varchar2, p_codapp in varchar2);
  --
  procedure insert_ttemprpt(p_codempid in varchar2,p_codapp in varchar2,p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,p_item7 in varchar2,p_item8 in varchar2,p_item9 in varchar2,p_item10 in varchar2,p_item11 in varchar2,p_item12 in varchar2,p_item13 in varchar2,p_item14 in varchar2,p_item15 in varchar2);
  procedure cal_hm_concat(p_qtymin number, p_hm out varchar2);
end ALERTMSG_AL;
-- user22 : 18/11/2017 : STA4-1701 ||
-- user22 : 12/04/2018 : ST11-0001 ||

/
