--------------------------------------------------------
--  DDL for Package HRBF1PD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1PD_BATCH" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 13/09/2021 14:01 #redmine 4254
*/

  para_numproc 		  number := nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_chken            varchar2(4 char):= check_emp(get_emp) ;
  para_chkreg 			  varchar2(100 char);
  para_zyear          number:= 0;
  para_numlvlsalst   number;
  para_numlvlsalen  number;

  para_codapp       tempaprq.codapp%type := 'HRBF1PD';
  para_coduser	 	  temploy1.coduser%type;
  para_dtestrt        date;
  para_dteend        date;

  v_err_step          varchar2(1000) ;
  v_numerr           number:=0;
  v_sqlerrm           varchar2(1000) ;



  indx_codcomp     tcenter.codcomp%type;
  indx_typpayroll     temploy1.typpayroll%type;
  indx_codempid     temploy1.codempid%type;
  indx_numperiod    number;
  indx_dtemthpay   number;
  indx_dteyrepay    number;
  indx_typcal          varchar2(1 char);


procedure start_process (p_typcal   in	varchar2,
                                  p_codcomp 		in	varchar2,
                                  p_typpayrol		in	varchar2,
                                  p_codempid		in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay  in	number,
                                  p_coduser		in	varchar2) ;

  procedure gen_group ;

  procedure gen_group_emp ;

  procedure gen_job ;

  procedure cal_process1 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

  procedure cal_process2 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

  procedure cal_process3 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

  procedure cal_process4 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

  procedure cal_process5 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

  procedure cal_process6 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

    procedure cal_process7 (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) ;

procedure set_parameter (p_zyear          number ,
                                      p_dtestrt        varchar2 ,
                                      p_dteend        varchar2 ,
                                      p_coduser       varchar2 );

procedure auto_process2; ----

end HRBF1PD_BATCH;

/
