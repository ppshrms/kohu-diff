--------------------------------------------------------
--  DDL for Package HRAL71B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL71B_BATCH" is
-- last update: 15/02/2021 11:00        --SWD-ST11-1701-AL-06-Rev2.0_07

	para_zyear      number := 0;-- v11 not use : pdk.check_year('');
	para_chken      varchar2(4) := check_emp(get_emp);
	para_numlvlst	 	varchar2(10);
	para_numlvlen	 	varchar2(10);
	para_numproc 		number := nvl(get_tsetup_value('QTYPARALLEL'),2);
	--
	para_codapp_wh  varchar2(30);
	para_codapp     varchar2(30);
	para_coduser	 	temploy1.coduser%type;
	indx_codempid   temploy1.codempid%type;
	indx_codcomp	  temploy1.codcomp%type;
	indx_typpayroll temploy1.typpayroll%type;
	para_codpay			tinexinf.codpay%type;
	para_dteyrepay  number;
	para_dtemthpay  number;
	para_numperiod  number;
	para_dtestr		  date;
	para_dteend  		date;
	para_flgretprd 	varchar2(4);
	para_qtyretpriod	number;
	para_v_dtestrt	date;
	para_codcurr	 	varchar2(4);
	para_codcompy		tcompny.codcompy%type;
	para_typpayroll temploy1.typpayroll%type;
	--
	indx_codempid2  temploy1.codempid%type;
	para_dtework		date;
	para_numrec			number := 0;
	para_dteempmt 	date;
	para_dteeffex 	date;
	p_sqlerrm       varchar2(4000);

  procedure start_process(p_codapp    	varchar2,
                          p_codempid  	varchar2,
                          p_codcomp	  	varchar2,
                          p_typpayroll 	varchar2,
                          p_typpayroll2	varchar2, -- user22 : 10/07/2021 : ST11 || not usee
                          p_codpay    	varchar2,
                          p_dteyrepay 	number,
                          p_dtemthpay 	number,
                          p_numperiod 	number,
                          p_dtestr    	date,
                          p_dteend    	date,
                          p_flgretprd 	varchar2,
                          p_qtyretpriod	number,
                          p_v_dtestrt		date,
                          p_coduser   	varchar2,
                          p_codcurr   	varchar2,
                          o_codempid  	out varchar2,
                          o_dtework	  	out date,
                          o_remark    	out varchar2,--user22 : 06/07/2016 : STA3590292 ||
                          o_numrec	  	out number,
                          o_timcal    	out varchar2);

  procedure gen_group_emp; -- create tprocemp
  procedure gen_group;     -- create tprocount
  procedure gen_job;       -- create Job & Process
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
  procedure cal_start(p_codapp_wh  	varchar2,--user22 : 06/07/2016 : STA3590292 ||
                      p_codapp    	varchar2,
                      p_coduser   	varchar2,
                      p_numproc	  	number,
                      p_codpay    	varchar2,
                      p_dteyrepay 	number,
                      p_dtemthpay 	number,
                      p_numperiod 	number,
                      p_dtestr    	date,
                      p_dteend    	date,
                      p_flgretprd 	varchar2,
                      p_qtyretpriod	number,
                      p_v_dtestrt		date,
                      p_codempid  	varchar2,
                      p_codcomp	  	varchar2,
                      p_typpayroll 	varchar2,
                      p_codcompy  	varchar2,-- user22 : 10/07/2021 : ST11 ||
                      p_typpayroll2	varchar2,
                      p_codcurr   	varchar2);

  procedure cal_wage(p_codapp    varchar2,
                     p_coduser   varchar2,
                     p_numproc	 number);

	procedure cal_pay_wage_tatt(p_codempid 	varchar2,
	 	                        p_codcomp	varchar2,
	 	                        p_codapp    varchar2,
					            p_coduser   varchar2,
					            p_numproc	number);

  procedure cal_pay_ot(p_codapp    varchar2,
                       p_coduser   varchar2,
                       p_numproc	 number);

  procedure cal_pay_award(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number);

  procedure cal_pay_vacat(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number);

  procedure cal_pay_other(p_codapp    varchar2,
                          p_coduser   varchar2,
                          p_numproc	  number);

  procedure cal_ded_abs(p_codapp    varchar2,
                        p_coduser   varchar2,
                        p_numproc	  number);

  procedure cal_ded_ear(p_codapp    varchar2,
                        p_coduser   varchar2,
                        p_numproc	  number);

  procedure cal_ded_late(p_codapp    varchar2,
                         p_coduser   varchar2,
                         p_numproc	 number);

  procedure cal_ded_leave(p_codapp   varchar2,
                          p_coduser  varchar2,
                          p_numproc	 number);

  procedure cal_ded_leave2(p_codempid   varchar2,
                           p_typleave   varchar2,
	                         p_codapp     varchar2,
			                     p_coduser    varchar2,
			                     p_numproc	  number);

  procedure cal_ded_leave3(p_codempid   varchar2,
                           p_dteprgntst date,
	                         p_codapp     varchar2,
			                     p_coduser    varchar2,
			                     p_numproc	  number);

  procedure cal_adj_abs(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number);

  procedure cal_adj_abs_gen_tpaysum(p_codempid   varchar2,
                                                      p_coduser    varchar2,
																	   p_flgwork		 varchar2);

  procedure cal_adj_ear(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number);

  procedure cal_adj_ear_gen_tpaysum(p_codempid   varchar2,
                                                     p_coduser    varchar2,
																	  p_flgwork		 varchar2);

  procedure cal_adj_late(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number);

  procedure cal_adj_late_gen_tpaysum(p_codempid   varchar2,
                                                       p_coduser    varchar2,
																		 p_flgwork		varchar2);

  procedure cal_ret_wage(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number);

  procedure cal_ret_ot(p_codapp   varchar2,
                       p_coduser  varchar2,
                       p_numproc	number);

  procedure cal_ret_abs(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc  number);

  procedure cal_ret_ear(p_codapp   varchar2,
                        p_coduser  varchar2,
                        p_numproc	 number);

  procedure cal_ret_late(p_codapp   varchar2,
                         p_coduser  varchar2,
                         p_numproc	number);

  procedure cal_ret_leave(p_codapp   varchar2,
                          p_coduser  varchar2,
                          p_numproc  number);
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	function chk_tpaysum(p_codempid  varchar2,
											 p_codalw    varchar2,
											 p_codpay  	 varchar2) return varchar2;

	procedure upd_period(p_codempid   varchar2,
											 p_codalw 	  varchar2,
											 p_codpay    	varchar2);

	procedure del_tpaysum(p_codempid  varchar2,
											  p_codalw 	  varchar2,
											  p_codpay  	varchar2);

	procedure upd_tpaysum(p_codempid  varchar2,
                          p_codalw 	  varchar2,
						  p_codpay    varchar2,
						  p_codcomp   varchar2,
						  p_codpos	  varchar2,
						  p_typpayroll varchar2,
						  p_amtothr		number,
						  p_amtday		number,
						  p_qtyday 		number,
						  p_qtymin 		number,
						  p_amtpay 		number);

	procedure upd_tpaysum2(p_codempid  	varchar2,
						   p_codalw 	  varchar2,
						   p_codpay    	varchar2,
						   p_codcomp   varchar2,
						   p_codpos	  varchar2,
						   p_typpayroll varchar2,
						   p_dtework 		date,
						   p_codshift 	varchar2,
						   p_timstrt 		varchar2,
						   p_timend 		varchar2,
						   p_qtymin 	  number,
						   p_amtpay 	  number,
						   p_amtothr	  number,
						   p_amtday		  number);

	procedure upd_tpaysumd(p_codempid  	varchar2,
												 p_codcompw		varchar2,
												 p_rtesmot  	number,
												 p_qtymot	  	number,
												 p_amtottot  	number);

	function check_dteempmt(p_dtework 	date) return boolean;

	function check_period_time(p_dtestrt 	date,
	                           p_dteend 	date,
	                           p_timestrt varchar2,
	                           p_timeend  varchar2) return boolean;

	function cal_formula(p_codempid 	varchar2,
	                     p_formula	  varchar2,
	                     p_dtework 	  date) return number;

	procedure get_time(p_codempid 	varchar2,
		 								 p_dtework		date,
										 p_timin	    out varchar2,
										 p_timout	    out varchar2);
end;

/
