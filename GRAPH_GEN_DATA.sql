--------------------------------------------------------
--  DDL for Package GRAPH_GEN_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GRAPH_GEN_DATA" AS
  procedure gen_data(p_codcomp in varchar2, p_date in date);
  procedure gen_data_tattence(p_codcomp in varchar2, p_dtestr in date, p_dteend in date);
  procedure gen_data_tovrtime(p_codcomp in varchar2, p_dtestr in date, p_dteend in date);
  procedure gen_data_tlateabs(p_codcomp in varchar2, p_dtestr in date, p_dteend in date);
  procedure gen_data_tleavetr(p_codcomp in varchar2, p_dtestr in date, p_dteend in date);
end;

/
