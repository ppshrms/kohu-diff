--------------------------------------------------------
--  DDL for Package HRPY3AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY3AB" as

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
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRPY3AB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPY3AB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_filename   varchar2(100 char);
  global_v_batch_pathfile   varchar2(100 char);

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_codempid                varchar2(100 char);

  v_flgdata                 varchar2(1);
  v_flgfetch                varchar2(1);
  v_flg_data	              boolean := false;
  v_flg_se		              boolean := false;

  para_numproc 	  	number     :=  1 ;  --nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_chken        varchar2(4 char):= check_emp(get_emp) ;
  para_zyear        number:= 0;
  para_numlvlsalst  number;
  para_numlvlsalen  number;

  para_codapp       varchar2(20 char) := 'HRPY3AB';
  indx_codcompy	    varchar2(40 char);
  indx_codempid	    varchar2(10 char);
  indx_typpayroll   varchar2(4 char);
  indx_dteyrepay    number;

  indx_dtemthpay    number;
  indx_numperiod    number;
 	para_coduser	 	  temploy1.coduser%type;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);

  --

  procedure start_process (o_numrec out number) ;
  /*
  (p_codcompy		in	varchar2,
                           p_typpayroll in	varchar2,
                           p_dteyrepay  in	number,
                           p_dtemthpay  in	number,
                           p_numperiod  in	number,
                           p_coduser		in	varchar2) ; */

  procedure gen_group ;


  procedure gen_group_emp ;

  procedure gen_job;

  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcompy		in	varchar2,
                         p_typpayroll in	varchar2,
                         p_dteyrepay  in	number,
                         p_dtemthpay  in	number,
                         p_numperiod  in	number) ;


  procedure upd_tsinexct(p_codempid 		in varchar2,
                         p_dteyrepay    in number,
                         p_dtemthpay    in number,
                         p_numperiod    in number,
                         p_codpay				in varchar2,
                         p_costcent			in varchar2,
                         p_codcomp			in varchar2,
                         p_amt					in number,
                         p_coduser      in varchar2) ;

  function check_index_batchtask(json_str_input clob) return varchar2;
end HRPY3AB;


/
