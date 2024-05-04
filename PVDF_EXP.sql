--------------------------------------------------------
--  DDL for Package PVDF_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "PVDF_EXP" IS
  PROCEDURE HEAD(p_pvdf					in number,
   							 p_typpayroll		in varchar2,
   							 p_numcomp			in varchar2,
   							 p_numfund  		in varchar2,
   							 p_dtepay				in date,
   							 p_dtemthpay		in varchar2,
   							 p_dteyrepay		in number,
   							 p_totamtprove 	in number,
   							 p_totamtprovc	in number,
   							 p_totrec				in number,
   							 p_namcomp			in varchar2,
  							 p_global				in number,
  							 p_codlang			in varchar2,
  							 p_text					out varchar2);

  PROCEDURE BODY(p_pvdf				in number,
                        p_codempid		in varchar2,
   							 p_dteempmt		in date,
   							 p_dteeffec		in date,
   							 p_dtereti		in date,
   							 p_dtepay			in date,
   							 p_numperiod	in number,
   							 p_dtemthpay	in varchar2,
   							 p_dteyrepay	in number,
   							 p_typpayroll	in varchar2,
   							 p_numcomp		in varchar2,
   							 p_numfund  	in varchar2,
   							 p_nummember	in varchar2,
		  					 p_namtitlt		in varchar2,
		  					 p_namfirstt	in varchar2,
		  					 p_namlastt		in varchar2,
		  					 p_namempt		in varchar2,
		  					 p_namcomt		in varchar2,
								 p_amtprove		in number,
								 p_amtprovc		in number,
								 p_codcomp   	in varchar2,
								 p_flg				in number,
  							 p_global			in number,
  							 p_codlang		in varchar2,
  							 p_codpfinf		in varchar2,
  							 p_chken		in varchar2,
  							 p_text				out varchar2,
  							 p_text1		  out varchar2,
  							 p_text2			out varchar2);
END;

/
