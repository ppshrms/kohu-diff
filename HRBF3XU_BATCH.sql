--------------------------------------------------------
--  DDL for Package HRBF3XU_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF3XU_BATCH" is
  global_v_coduser          varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  para_zupdsal              varchar2(20 char);
  para_numproc 		          number := nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_codapp               varchar2(20 char) := 'HRBF3XU';
  para_codempid             temploy1.codempid%type;
  para_coduser              tinsrer.coduser%type;
  para_codcomp              tinsrer.codcomp%type;
  para_numisr               tinsrer.numisr%type;
  para_numisro              tinsrer.numisr%type;
  para_type                 varchar2(20 char);
  para_codlang              varchar2(20 char);
  para_numrec			          number := 0;
  --
  procedure start_process(p_codcomp    	varchar2,
                          p_numisr    	varchar2,
                          p_numisro	  	varchar2,
                          p_type        varchar2,--1 new , 2 renew
                          p_coduser     varchar2,
                          p_codlang     varchar2,
                          o_numrec			out number);

  procedure gen_group_emp; -- create tprocemp
  procedure gen_group;     -- create tprocount
  procedure gen_job;       -- create Job & Process
  --
  procedure cal_start(p_codcomp    	varchar2,
                      p_numisr    	varchar2,
                      p_numisro	  	varchar2,
                      p_type        varchar2,--1 new , 2 renew
                      p_coduser     varchar2,
                      p_codlang     varchar2,
                      p_numproc     number);
  procedure gen_new_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number);
  procedure gen_renew_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number);
end;

/
