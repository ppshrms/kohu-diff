--------------------------------------------------------
--  DDL for Package HRBF38B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF38B" as
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(100 char);
  v_sqlerrm                 varchar2(1000) ;
  v_err_step                varchar2(1000) ;

  global_v_batch_codapp     varchar2(100 char)  := 'HRBF38B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRBF38B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_filename   varchar2(100 char);
  global_v_batch_pathfile   varchar2(100 char);
  para_numproc 		          number := nvl(get_tsetup_value('QTYPARALLEL'),2);

  p_dtemthpay               number;
  p_dteyrepay               number;
  p_period                  number;
  p_month                   number;
  p_year                    number;
  p_typpayroll              varchar2(100 char);
  p_codcomp                 varchar2(100 char);
  p_numisr                  varchar2(100 char);

  p_file_dir                varchar2(4000 char) := 'UTL_FILE_DIR';
  p_file_path               varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
  p_filename		            varchar2(4000 char);
  p_numrec	                number;
  p_amount	                number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure get_flgisr(json_str_input in clob, json_str_output out clob);
  procedure get_lastperiod(json_str_input in clob, json_str_output out clob);
  procedure gen_group ;
  procedure gen_group_emp ;
  procedure gen_job ;
  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll in	varchar2,
                         p_numisr     in	varchar2,
                         p_dtemonth   in  number,
                         p_dteyear	  in  number,
                         p_numprdpay  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number);
end hrbf38b;

/
