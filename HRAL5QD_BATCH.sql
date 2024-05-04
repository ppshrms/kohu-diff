--------------------------------------------------------
--  DDL for Package HRAL5QD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5QD_BATCH" is
	g_zyear     number := 0;-- v11 not use : pdk.check_year('');
	g_coduser		temploy1.coduser%type := 'AT'||to_char(sysdate,'ddmmyy');
	procedure start_process;
end HRAL5QD_BATCH;

/
