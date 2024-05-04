--------------------------------------------------------
--  DDL for Package DECLARE_VAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DECLARE_VAR" AS
  v_max					number := 0;
	v_amtexp			number;
	v_maxexp			number;
	v_amtdiff			number;
	TYPE codpay IS TABLE OF tinexinf.codpay%type INDEX BY BINARY_INTEGER;
		v_tab_codpay	codpay;
		v_tab_codtax	codpay;
	TYPE codeduct IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	     dvalue_code	codeduct;
	     evalue_code	codeduct;
	     ovalue_code	codeduct;
	TYPE char1 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
			 v_text	char1;

END DECLARE_VAR;

/
