--------------------------------------------------------
--  DDL for Package OTBUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "OTBUDGET" is
  
  procedure get_manpw_budget(p_codcomp in varchar2,p_dtestrt in date,p_dteend in date,
                             p_qtymanpw out number,p_qtyhworkall out number);

  procedure get_ot_budget(p_qtyhworkall in number,p_pctbudget in number,p_pctabslv in number,
                          p_qtyhwork out number,p_qtybudget out number);

  procedure get_bugget_data(p_codempid in varchar2,p_dtework in date,p_codcompw in varchar2,
                            p_dtereq in date,p_numseq in number,p_dtestrt in date,p_dteend in date,
                            p_codcompbg out varchar2,p_qtybudget out number,p_qtyothot out number);

  --procedure upd_qtyotreq(p_codcompbg in varchar2,p_month in number,p_year in number);

  function get_codcompbg(p_codcompw in varchar2,p_dtework in date) return varchar2;

end;


/
