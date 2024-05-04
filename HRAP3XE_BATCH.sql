--------------------------------------------------------
--  DDL for Package HRAP3XE_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3XE_BATCH" as

  v_chken                 varchar2(4):= check_emp(get_emp) ;
  v_lang                  varchar2(3);
  v_coduser               varchar2(20);
  v_numproc               number;
  v_process               varchar2(10) ;
  v_zyear                 number:= 0;
  v_numlvlsalst           number;
  v_numlvlsalen           number;
  global_v_zminlvl        number;
  global_v_zwrklvl        number;
  b_index_sumrec          number;
  b_index_sumerr          number;
  para_numproc            number;
  para_codapp             varchar2(10 char);
  para_coduser            varchar2(100 char);

  b_index_codcomp         temploy1.codcomp%type;
  b_index_dteyreap        number;
  b_var_numtime           tstdisd.numtime%type;

  tappemp_codempid        tappemp.codempid%type;

  param_msg_error           varchar2(4000 char);
  procedure start_process (p_codapp  in varchar2,
                       p_coduser in varchar2,
                       p_numproc in number,
                       p_process in varchar2 ,
                       p_codcomp in varchar2 ,
                       p_dteyreap in varchar2 ,
                       p_param_json in clob) ;

  procedure gen_group;

  procedure gen_job (p_codapp  in varchar2,
                     p_coduser in varchar2,
                     p_numproc in number,
                     p_process in varchar2 ,
                     p_codcomp in varchar2 ,
                     p_dteyreap in varchar2 ,
                     p_param_json in clob) ;
  procedure cal_process (p_codapp  in varchar2,
                       p_coduser in varchar2,
                       p_numproc in number,
                       p_process in varchar2 ,
                       p_codcomp in varchar2 ,
                       p_dteyreap in varchar2 ,
                       p_param_json in clob) ;

    procedure process_salary (p_codapp   in varchar2,
                              p_coduser  in varchar2,
                              p_numproc  in number,
                              p_process  in varchar2,
                              p_codcomp  in varchar2,
                              p_dteyreap in varchar2,
                              p_grade    in varchar2,
                              p_pctpostr in number,
                              p_pctpoend in number) ;

end hrap3xe_batch;


/
