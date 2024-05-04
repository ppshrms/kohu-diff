--------------------------------------------------------
--  DDL for Package HRPY46B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY46B_BATCH" as

--st11  --indx_codcomp||'%'

  para_numproc 		  number := nvl(get_tsetup_value('QTYPARALLEL'),2);
  para_chken        varchar2(4000 char):= hcm_secur.get_v_chken ;
  para_chkreg 			varchar2(100 char);
  para_zyear        number:= 0;
  para_numlvlsalst  number;
  para_numlvlsalen  number;

  para_codapp       varchar2(20 char) := 'HRPY46B';
  indx_codempid     temploy1.codempid%type;

  indx_codcomp	      varchar2(41 char);   --tcenter.codcomp%type;
  indx_codcomp2	      varchar2(41 char);   --tcenter.codcomp%type;

  indx_typpayroll      temploy1.typpayroll%type;
  indx_dteyrepay      number;

  indx_dtemthpay    number;
 	para_coduser	 	  tusrprof.coduser%type;
	para_codcurr	 	  varchar2(4 char);

	v_max					    number := 0;
	v_amtexp			    number;
	v_maxexp			    number;
	v_amtdiff			    number;
  v_codtax1         varchar2(20 char);

	param_codapp      varchar2(20 char);
	param_coduser	 	  tusrprof.coduser%type;
	param_numproc     number;

  p_flg_exist       boolean := false;
  p_flg_permission  boolean := false;
  type codpay is table of varchar2(20 char) index by binary_integer;
    v_tab_codpay	codpay;
    v_tab_codtax	codpay;


  type codeduct is table of number index by binary_integer;
    dvalue_code	codeduct;
    evalue_code	codeduct;
    ovalue_code	codeduct;

  type char1 is table of varchar2(2000 char) index by binary_integer;
    v_text	char1;


  procedure start_process (p_codempid		in	varchar2,
                           p_codcomp		in	varchar2,
                           p_typpayroll in	varchar2,

                           p_dteyrepay  in	number,
                           p_dtemthpay  in	number,
                           p_codcurr   	in  varchar2,
                           p_coduser		in	varchar2,
                           flg_exist    out boolean,
                           flg_permission out boolean);

  procedure gen_group ;

  procedure gen_group_emp;

  procedure gen_job;

  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,

                         p_numproc	  in  number,
                         p_codempid		in	varchar2,
                         p_codcomp		in	varchar2,
                         p_typpayroll in	varchar2,
                         p_dteyrepay  in	number,
                         p_dtemthpay  in	number,
                         p_codcurr    in	varchar2);

  procedure upd_tsincexp (p_codempid  	in varchar2,
                          p_codpay		  in varchar2,
                          p_dteyrepay   in number,
                          p_dtemthpay   in number,
                          p_numperiod   in number,

                          p_codcomp		  in varchar2,
                          p_typpayroll	in varchar2,
                          p_typemp		  in varchar2,
                          p_numlvl		  in number,
                          p_codbrlc		  in varchar2,
                          p_amtpay   	  in varchar2,
                          p_codempmt    in varchar2,
                          p_coduser     in varchar2);

  procedure upd_ttaxinc (p_codempid	    in varchar2,
                         p_dteyrepay    in number,
                         p_dtemthpay    in number,
                         p_numperiod	  in number,

                         p_codpay		    in varchar2,
                         p_codcomp		  in varchar2,
                         p_typpayroll	  in varchar2,
                         p_numlvl		    in number,
                         p_typpay		    in varchar2,
                         p_typinc		    in varchar2,
                         p_typpayt	    in varchar2,
                         p_amtpay   	  in number,
                         p_coduser      in varchar2,
                         v_typincom     in varchar2);

  procedure upd_tinctxpnd (p_codempid	    in varchar2,
                           p_dteyrepay    in number,
                           p_dtemthpay    in number,
                           p_numperiod	  in number,
                           p_codpay		    in varchar2,
                           p_codcomp		  in varchar2,
                           p_typpayroll	  in varchar2,
                           p_numlvl		    in number,
                           p_typpay		    in varchar2,
                           p_typinc		    in varchar2,
                           p_typpayt	    in varchar2,
                           p_amtpay   	  in number,
                           p_coduser      in varchar2);
end hrpy46b_batch;

/
