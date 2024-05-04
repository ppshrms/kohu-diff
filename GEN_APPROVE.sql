--------------------------------------------------------
--  DDL for Package GEN_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GEN_APPROVE" is
  --user36 STA3 05/09/2016 create

  procedure find_approve_name(p_codempid    in varchar2,
                              p_seqno       in number,
                              p_flgappr     in varchar2,
                              p_codempap    in varchar2,
                              p_codcompap   in varchar2,
                              p_codposap    in varchar2,
                              p_codapp      in varchar2,
                              p_coduser     in varchar2,
                              p_stcodempid  in varchar2);
  --
  procedure insert_ttemprpt2(p_codempid in varchar2,p_codapp in varchar2,
                            p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,
                            p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,
                            p_item7 in varchar2,p_temp31 in number);

end;

/
