--------------------------------------------------------
--  DDL for Package Body HRAL34B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL34B_BATCH" is
	procedure start_process is
		v_numrec			number := 0;
	  v_dtecall   	date := sysdate;

    cursor c_emp is
      select codempid,dtework,codcomp
        from (
              select codempid,dtework,codcomp
                from tattence
               where dtework between (trunc(sysdate) - 7) and trunc(sysdate)
        union
              select codempid,dtework,codcomp
                from tlateabs
               where dtework between (trunc(sysdate) - 30) and trunc(sysdate))               
    order by codempid,dtework;    
	begin
    for r_emp in c_emp loop
      std_al.cal_tattence(r_emp.codempid,r_emp.dtework,r_emp.dtework,g_coduser,v_numrec);
    end loop;
		commit;
	end;
end HRAL34B_BATCH;

/
