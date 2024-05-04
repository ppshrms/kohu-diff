--------------------------------------------------------
--  DDL for Package Body HRAL5QD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5QD_BATCH" is
	procedure start_process is
		v_numrec			number;
	  v_dtecall   	date := sysdate;
	begin
		hral56b_batch.gen_leave_Cancel(null,'%',null,null,g_coduser,v_numrec); 
		--
  	delete tautolog where codapp = 'HRAL5QD' and dtecall = v_dtecall;
	  insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
	                values('HRAL5QD',v_dtecall,v_dtecall,sysdate,'C',v_numrec,g_coduser);
		commit;
	end;
end HRAL5QD_BATCH;

/
