--------------------------------------------------------
--  DDL for Package HRAL34B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL34B_BATCH" is
	g_coduser		temploy1.coduser%type := 'AT'||to_char(sysdate,'ddmmyy');
	procedure start_process;
end HRAL34B_BATCH;

/
