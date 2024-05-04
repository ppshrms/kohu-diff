--------------------------------------------------------
--  DDL for Package HRBF54B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF54B_BATCH" as

/*
	code by 	  : User14/Krisanai Mokkapun
   date        : 29/01/2020 11:01 #4133
*/

  para_numproc 		  number := nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_chken            varchar2(4 char):= check_emp(get_emp) ;
  para_chkreg 			  varchar2(100 char);
  para_zyear          number:= 0;
  para_numlvlsalst   number;
  para_numlvlsalen  number;

  para_codapp       tempaprq.codapp%type := 'HRBF54B';
  para_coduser	 	  temploy1.coduser%type;
  para_dtestrt       date;
  para_dteend        date;

  v_err_step          varchar2(1000) ;
  v_numerr           number:=0;
  v_numrec           number:=0;
  v_sqlerrm           varchar2(1000) ;



  indx_codcomp     tcenter.codcompy%type;
  indx_typpayroll     temploy1.typpayroll%type;
  indx_codempid     temploy1.codempid%type;
  indx_numperiod    number;
  indx_dtemthpay   number;
  indx_dteyrepay    number;
  indx_flgbonus      varchar2(1 char);


procedure start_process (p_codcomp 		in	varchar2,
                                  p_typpayrol		in	varchar2,
                                  p_codempid		in	varchar2,
                                  p_numperiod  in	number,
                                  p_dtemthpay  in	number,
                                  p_dteyrepay  in	number,
                                  p_flgbonus   in	varchar2,
                                  p_coduser		in	varchar2) ;

  procedure gen_group ;

  procedure gen_group_emp ;

  procedure gen_job ;

  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll    in	varchar2,
                         p_codempid    in	varchar2,
                         p_numperiod  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number,
                         p_flgbonus   in varchar2) ;

procedure process_loan (p_numcont   	in  varchar2,
                                   p_dtestrt in date,
                                   p_dteend in date,
                                   p_flgbonus  in varchar2) ;

procedure set_parameter (p_zyear          number ,
                                      p_dtestrt        varchar2 ,
                                      p_dteend        varchar2 ,
                                      p_coduser       varchar2 );

end HRBF54B_BATCH;

/
