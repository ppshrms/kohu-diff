--------------------------------------------------------
--  DDL for Package HRPY35B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY35B_BATCH" as

/*
	project 		: ST11	
	error date	: 16/11/2020 17:17
*/

  para_numproc 		  number := 1;--nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_chken        varchar2(4 char):= check_emp(get_emp) ;
  para_chkreg 			varchar2(100 char);
  para_zyear        number:= 0;
  para_numlvlsalst  number;
  para_numlvlsalen  number;

  v_err_step          varchar2(1000) ;
  v_sqlerrm           varchar2(1000) ;

  para_codapp       tempaprq.codapp%type := 'HRPY35B';
  indx_codcompy     tcenter.codcompy%type;
  indx_dteyrepay    number;
  indx_dtemthpay    number;
  indx_typpayroll   varchar2(100 char);

  indx_numperiod    number;
 	para_coduser	 	  temploy1.coduser%type;


  procedure start_process (p_codcompy		in	varchar2,
                           p_dteyrepay  in	number,
                           p_dtemthpay  in	number,
                           p_numperiod  in	number,
                           p_typpayroll in	varchar2,
                           p_coduser		in	varchar2) ;

  procedure gen_group ;

  procedure gen_group_emp ;


  procedure gen_job ;

  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcompy		in	varchar2,
                         p_dteyrepay  in	number,
                         p_dtemthpay  in	number,
                         p_numperiod  in	number) ;

  procedure cal_gl ( p_codcomp	  in	varchar2,
                     p_codempid	  in	varchar2,

                     p_codcompy   in	varchar2,
                     p_dteyrepay  in  number,
                     p_dtemthpay  in  number,
                     p_numperiod	in	number,
                     p_apcode			in	varchar2,
                     p_trcent			in  varchar2,
                     p_costcent		in	varchar2,
                     p_codacc			in	varchar2,
                     p_scodacc		in	varchar2,
                     p_flgdrcr		in	varchar2,
                     p_amtgl			in	number,
                     p_flgpost		in	varchar2,
                     p_typpaymt		in	varchar2,

                     p_coduser    in	varchar2,
                     p_tsecdep	 	in  out	boolean) ;

end HRPY35B_BATCH;

/
