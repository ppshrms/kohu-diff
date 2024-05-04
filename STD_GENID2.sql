--------------------------------------------------------
--  DDL for Package STD_GENID2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_GENID2" IS
  PROCEDURE  gen_id
  	(p_codcomp   in  varchar2,
  	 p_codempmt  in  varchar2,
  	 p_codbrlc  in  varchar2,
  	 p_dteempmt  in  date,
  	 p_groupid   out varchar2,
  	 p_id        out varchar2,
  	 p_year      out number,
  	 p_month     out number,
  	 p_running   out varchar2,
  	 p_table     out varchar2,
  	 p_error     out varchar2) ;
  PROCEDURE upd_id
  	(p_groupid  in varchar2,
  	 p_year     in number,
  	 p_month		in number,
  	 p_running  in varchar2,
  	 p_coduser  in varchar2) ;
end;

/
