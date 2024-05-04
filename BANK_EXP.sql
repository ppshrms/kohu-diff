--------------------------------------------------------
--  DDL for Package BANK_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "BANK_EXP" IS
  PROCEDURE HEAD(p_bank				in number,
  							 p_codbkserv 	in varchar2,
  							 p_numacct 		in varchar2,
  							 p_codcomp		in varchar2,
  							 p_totamt			in number,
  							 p_totemp			in number,
  							 p_dtepaymt	  in date,
 							 	 p_dtetran		in date,
  							 p_global			in number,
  							 p_codlang		in varchar2,
  							 p_text				out varchar2,
  							 p_rec				out number);

  PROCEDURE BODY(p_bank				in number,
  							 p_codbkserv 	in varchar2,
  							 p_numacct 		in varchar2,
  							 p_sumrec			in number,
  							 p_codempid		in varchar2,
  							 p_codbank		in varchar2,
  							 p_numbank		in varchar2,
  							 p_amtpay			in number,
  							 p_dtepaymt		in date,
  							 p_codcomp		in varchar2,
  							 p_totemp		 	in number,
  							 p_totamt			in number,
  							 p_dtetran		in date,
  							 p_codmedia		in varchar2,
  							 p_global			in number,
  							 p_codlang		in varchar2,
  							 p_text				out varchar2);

  PROCEDURE TAIL(p_bank				in number,
  							 p_codbkserv 	in varchar2,
  							 p_numacct 		in varchar2,
  							 p_sumrec			in number,
  							 p_totamt			in number,
  							 p_dtepaymt		in date,
 							 	 p_global			in number,
 							 	 p_text				out varchar2);
END;

/
