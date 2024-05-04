--------------------------------------------------------
--  DDL for Package HRBF3YU_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF3YU_BATCH" is
  global_v_coduser          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_lang             varchar2(10 char) := '102';
  para_zupdsal              varchar2(20 char);
  para_numproc 		          number := nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_codapp               varchar2(20 char) := 'HRBF3YU';
  para_coduser              tinsrer.coduser%type;
  para_numrec			          number := 0;

  para_codcomp              tinsrer.codcomp%type;
  para_numisr               tinsrer.numisr%type;
  para_month                number := 0;
  para_year 			          number := 0;
  --
  procedure start_process(p_codcomp    	varchar2,
                          p_numisr    	varchar2,
                          p_month	 	    number,
                          p_year        number,
                          p_coduser     varchar2,
                          p_lang        varchar2,
                          o_numrec1			out number,
                          o_numrec2			out number,
                          o_numrec3			out number);

  procedure gen_group_emp; -- create tprocemp
  procedure gen_group;     -- create tprocount
  procedure gen_job;       -- create Job & Process
  --
  procedure cal_start(p_codcomp    	varchar2,
                      p_numisr    	varchar2,
                      p_month	 	    number,
                      p_year        number,
                      p_coduser     varchar2,
                      p_numproc     number);
  procedure gen_new_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number);
  procedure gen_resign_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number);
  procedure gen_movement_insurance(p_codapp varchar2,p_coduser varchar2,p_numproc number);
end;

/
