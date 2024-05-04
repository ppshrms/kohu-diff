--------------------------------------------------------
--  DDL for Package STD_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_TAX" IS
  --Update date 07/02/2024 15:50
  v_numday        number:= 30;
  v_chken         varchar2(4):= check_emp(get_emp) ;
  v_lang          varchar2(3);
  v_coduser       varchar2(20);
  v_numproc       number;
  v_zyear         number:= 0;
  v_numlvlsalst   number;
  v_numlvlsalen   number;

  b_var_codempid    temploy1.codempid%type;
  b_var_codcompy    tcompny.codcompy%type;
  b_var_typpayroll  temploy1.typpayroll%type;
  b_var_dtebeg      date;
  b_var_dteend      date;
  b_var_ratechge    number;
  b_var_mqtypay     number;
  b_var_balperd     number;
  b_var_perdpay     number;
  b_var_stacal      varchar2(1);
  b_var_staemp      varchar2(1) := 0 ;

  b_var_amtcal      number;
  b_var_dteyreff    number;
  b_var_socfix      number;
  b_var_profix      number;
  b_var_tempinc     number;
  b_var_flglast        varchar2(1);
  b_var_amt_oth    number;
  b_index_numperiod number;
  b_index_dtemthpay number;
  b_index_dteyrepay number;
  b_index_codempid  temploy1.codempid%type;
  b_index_codcomp   temploy1.codcomp%type;
  b_index_newflag   varchar2(1);
  b_index_flag      varchar2(1);
  b_index_flgretro  varchar2(1);
  b_index_sumrec    number;
  b_index_sumerr    number;

  declare_var_v_max     number;
  declare_var_v_amtexp  number;
  declare_var_v_maxexp  number;
  declare_var_v_amtdiff number;
  declare_var_v_amtfix number;

  declare_var_v_amtdedfix number := 0;
  declare_var_v_amtdedoth number := 0;
  declare_var_v_amtothfix number := 0;

  declare_var_it4       number := 0;
  declare_var_it5       number := 0;
  declare_var_it6       number := 0;

  declare_var_forecast4       number := 0;
  declare_var_forecast5       number := 0;
  declare_var_forecast6       number := 0;
  declare_var_forecast_othfix number := 0;
    type codpay is table of varchar2(4 char) index by binary_integer;
        declare_var_v_tab_codpay	      codpay;
        declare_var_v_tab_codtax	      codpay;
        declare_var_tempinc_codpay4     codpay;
        declare_var_tempinc_codpay5     codpay;
        declare_var_tempinc_codpay6     codpay;
        declare_var_dedinc              codpay;
    type codeduct is table of number index by binary_integer;
        declare_var_dvalue_code	   codeduct;
        declare_var_evalue_code	   codeduct;
        declare_var_ovalue_code	   codeduct;
        declare_var_tempinc_amt4   codeduct;
        declare_var_tempinc_amt5   codeduct;
        declare_var_tempinc_amt6   codeduct;

    type char1 is table of varchar2(2000) index by binary_integer;
        declare_var_v_text	     char1;

  tcontpm_codcurr   tcontrpy.codcurr%type;

  tcontpms_codincom1    tcontpms.codincom1%type;
  tcontpms_codincom2    tcontpms.codincom2%type;
  tcontpms_codincom3    tcontpms.codincom3%type;
  tcontpms_codincom4    tcontpms.codincom4%type;
  tcontpms_codincom5    tcontpms.codincom5%type;
  tcontpms_codincom6    tcontpms.codincom6%type;
  tcontpms_codincom7    tcontpms.codincom7%type;
  tcontpms_codincom8    tcontpms.codincom8%type;
  tcontpms_codincom9    tcontpms.codincom9%type;
  tcontpms_codincom10   tcontpms.codincom10%type;

  tcontpms_codretro1    tcontpms.codretro1%type;
  tcontpms_codretro2    tcontpms.codretro2%type;
  tcontpms_codretro3    tcontpms.codretro3%type;
  tcontpms_codretro4    tcontpms.codretro4%type;
  tcontpms_codretro5    tcontpms.codretro5%type;
  tcontpms_codretro6    tcontpms.codretro6%type;
  tcontpms_codretro7    tcontpms.codretro7%type;
  tcontpms_codretro8    tcontpms.codretro8%type;
  tcontpms_codretro9    tcontpms.codretro9%type;
  tcontpms_codretro10   tcontpms.codretro10%type;

  tcontrpy_flgfmlsc   tcontrpy.flgfmlsc%type;
  tcontrpy_flgfml     tcontrpy.flgfml%type;
  tcontrpy_codpaypy1  tcontrpy.codpaypy1%type;
  tcontrpy_codpaypy2  tcontrpy.codpaypy2%type;
  tcontrpy_codpaypy3  tcontrpy.codpaypy3%type;
  tcontrpy_codpaypy4  tcontrpy.codpaypy4%type;
  tcontrpy_codpaypy5  tcontrpy.codpaypy5%type;
  tcontrpy_codpaypy6  tcontrpy.codpaypy6%type;
  tcontrpy_codpaypy7  tcontrpy.codpaypy7%type;
  tcontrpy_codpaypy8  tcontrpy.codpaypy8%type;
  tcontrpy_codpaypy10 tcontrpy.codpaypy10%type;
  tcontrpy_codpaypy11 tcontrpy.codpaypy11%type;
  tcontrpy_codpaypy12 tcontrpy.codpaypy12%type;
  tcontrpy_codpaypy13 tcontrpy.codpaypy13%type;
  tcontrpy_codpaypy14 tcontrpy.codpaypy14%type;

  tcontrpy_codtax     varchar2(4);
  tcontrpy_amtminsoc  number;
  tcontrpy_amtmaxsoc  number;
  tcontrpy_qtyage     number;
  tcontrpy_typesitm   tcontrpy.typesitm%type;
  tcontrpy_typededtax tcontrpy.typededtax%type;
  tcontrpy_syncond      tcontrpy.syncond%type;

  temploy1_codempid   temploy1.codempid%type;
  temploy1_codcomp    temploy1.codcomp%type;
  temploy1_stamarry   temploy1.stamarry%type;
  temploy1_dteempdb   temploy1.dteempdb%type;
  temploy1_dteempmt   date;
  temploy1_staemp     temploy1.staemp%type;
  temploy1_codbrlc    temploy1.codbrlc%type;
  temploy1_codpos     temploy1.codpos%type;
  temploy1_dteeffex   date;
  temploy1_typpayroll temploy1.typpayroll%type;
  temploy1_typemp     temploy1.typemp%type;
  temploy1_codempmt   temploy1.codempmt%type;
  temploy1_numlvl     temploy1.numlvl%type;
  temploy1_jobgrade   temploy1.jobgrade%type;
  temploy1_codgrpgl   temploy1.codgrpgl%type;
  temploy1_qtydatrq   temploy1.qtydatrq%type;
  temploy1_dtedatrq   date;

  ttmovemt_codcomp    tcenter.codcomp%type;
  ttmovemt_codpos     tpostn.codpos%type;
  ttmovemt_codjob     varchar2(4 char);
  ttmovemt_dteempmt   date;
  ttmovemt_codempmt   temploy1.codempid%type;
  ttmovemt_typpayroll varchar2(4 char);
  ttmovemt_codcalen   varchar2(4 char);
  ttmovemt_numlvl     number;
  ttmovemt_typemp     varchar2(4 char);
  ttmovemt_codbrlc    varchar2(4 char);
  ttmovemt_staemp     varchar2(4 char);
  ttmovemt_jobgrade   varchar2(4 char);
  ttmovemt_codgrpgl   varchar2(4 char);

  temploy3_codempid   temploy3.codempid%type;
  temploy3_typtax     temploy3.typtax%type;
  temploy3_flgtax     temploy3.flgtax%type;
  temploy3_codcurr    temploy3.codcurr%type;
  temploy3_numsaid	  temploy3.numsaid%type;
  temploy3_amtincom1    number;
  temploy3_amtincom2	number;
  temploy3_amtincom3	number;
  temploy3_amtincom4	number;
  temploy3_amtincom5	number;
  temploy3_amtincom6	number;
  temploy3_amtincom7	number;
  temploy3_amtincom8	number;
  temploy3_amtincom9	number;
  temploy3_amtincom10   number;
  temploy3_codbank      temploy3.codbank%type;
  temploy3_numbank	    temploy3.numbank%type;
  temploy3_codbank2     temploy3.codbank2%type;
  temploy3_numbank2     temploy3.numbank2%type;
  temploy3_amtbank	    number;
  temploy3_amtincbf     number;
  temploy3_amttaxbf     number;
  temploy3_amtpf        number;
  temploy3_amtsaid      number;
  temploy3_amtincsp     number;
  temploy3_amttaxsp     number;
  temploy3_amtpfsp      number;
  temploy3_amtsasp      number;
  temploy3_typincom     temploy3.typincom%type;
  temploy3_flgsoc       varchar2(1 char);

  tpfhinf_dteeffec    date;

  tssrate_pctsoc      number;
  tssrate_pctsocc     number;

  parameter_emp_error varchar2(1);

  c_pctemppf 		     number ;
	c_pctcompf 		     number ;
  v_err_step         varchar2(1000) ;
  v_process          varchar2(10) ;
  v_flagbug          varchar2(100) := get_tsetup_value('CAL_TAX');
  v_dteyrst          date ;
  v_dteyren          date ;
  v_round 	         number := 0;
  v_maxeducat        number := 0;
  v_maxDonate        number := 0;
  v_maxded           number := 0;
  declare_var_dedamt codeduct;
  para_numproc       number :=  nvl(get_tsetup_value('QTYPARALLEL'),2);

  procedure process_ (  p_codapp      in varchar2,
                        p_coduser     in varchar2,
                        p_numperiod   in number,
                        p_dtemthpay	  in number,
                        p_dteyrepay   in number,
                        p_codcomp     in varchar2,
                        p_typpayroll  in varchar2,
                        p_codempid    in varchar2,
                        p_newflag     in varchar2,
                        p_flag        in varchar2,
                        p_flgretro    in varchar2,
                        p_lang        in varchar2);


  procedure start_process (p_codapp  in varchar2,
                           p_coduser in varchar2,
                           p_numproc in number,
                           p_process in varchar2 ,
                           --
                           p_codcomp    in varchar2 ,
                           p_typpayroll in varchar2 ,
                           p_codempid   in varchar2 ,
                           p_numperiod  in varchar2 ,
                           p_dtemthpay  in varchar2 ,
                           p_dteyrepay  in varchar2 ,
                           p_newflag     in varchar2 ,
                           p_flag        in varchar2 ,
                           p_flgretro    in varchar2 ,
                           p_lang        in varchar2 );

  PROCEDURE clear_olddata;

  PROCEDURE exec_temploy3;

  procedure insert_error (p_error in varchar2);

  PROCEDURE cal_bassal(p_stdate in date,
                       p_endate in date,
                       p_qtyday in number,
                       p_deduct in number,
                       p_numday	in number);

  procedure cal_bassal_hrpy44b ;

  PROCEDURE cal_oth_ot;

  procedure cal_tempinc(p_stdate date,
                        p_endate date);

  procedure cal_tempinc_hrpy44b (p_stdate date,p_endate date) ;

  procedure cal_tempinc_estimate (p_stdate date,p_endate date) ;

  procedure cal_tax(p_stdate in date,
                    p_endate in date,
                    p_codapp in varchar2);

  PROCEDURE cal_tothpay;

  PROCEDURE upd_ttaxmasl;

  PROCEDURE upd_tsincexp(p_codpay 	in tinexinf.codpay%type,
                         p_flgslip	in tsincexp.flgslip%type,
                         p_local		in boolean,
                         p_amtpay 	in out number);

  function cal_formula (p_codpay in tinexinf.codpay%type,
	                      p_amtpay in number) return number;

  function proc_round (p_flgfml		varchar2,
	                     p_amount		number)  return number;

  PROCEDURE cal_prov (p_stdate 		in date,
                      p_endate 		in date,
                      p_amtcprv 	in number,
                      p_amtprove	in out number,
                      p_amtprovc 	in out number,
                      p_amtproyr	in out number);

  PROCEDURE cal_social(p_amtsoc			in number,
	 									   p_amtsoc_oth	in number,
	 									   p_amtsoca		in out number,
	 									   p_amtsocc		in out number,
	 									   p_amtsocyr		in out number);

  procedure cal_estimate (p_estimate out number,
	                        p_divice		in out number);

  procedure cal_amtnet (p_amtincom  in number,
	 										  p_amtsalyr  in number,
 	 									    p_amtproyr	in number,
	 										  p_amtsocyr  in number,
	 									    p_amtnet	  out number);

  procedure cal_amttax (p_amtnet 	in number,
                        p_flgtax		in varchar2,
                        p_sumtax  	in number,
                        p_taxa  		in number,
                        p_amttax  	out number);

  FUNCTION gtempded (v_empid 			varchar2,
	 								   v_codeduct 	varchar2,
	 								   v_type 			varchar2,
	 								   v_amtcode 		number,
   								   p_amtsalyr 	number) RETURN number;

 FUNCTION get_deduct(v_codeduct varchar2) RETURN char;

 PROCEDURE upd_ttaxmasd (p_coddeduct	in varchar2,
                         p_typdeduct	in varchar2,
                         p_amt				in number);

 procedure get_parameter(pb_var_codempid      in varchar2,
                         pb_var_codcompy      in varchar2,
                         pb_var_typpayroll    in varchar2,
                         pb_var_dtebeg        in varchar2,
                         pb_var_dteend        in varchar2,
                         pb_var_ratechge      in number,
                         pb_var_mqtypay       in number,
                         pb_var_balperd      in  number,
                         pb_var_perdpay       in number,
                         pb_var_stacal        in varchar2,
                         pb_var_amtcal        in number,
                         pb_var_dteyreff      in number,
                         pb_var_socfix        in number,
                         pb_var_profix        in number,
                         pb_var_tempinc       in number,
                         pb_var_flglast       in varchar2,
                         pb_index_numperiod   in number,
                         pb_index_dtemthpay   in number,
                         pb_index_dteyrepay   in number,
                         pb_index_codempid    in varchar2,
                         pb_index_codcomp     in varchar2,
                         pb_index_newflag     in varchar2,
                         pb_index_flag        in varchar2,
                         pb_index_flgretro    in varchar2,
                         ptcontpm_codcurr     in varchar2,
                         ptcontrpy_flgfmlsc   in varchar2,
                         ptcontrpy_flgfml     in varchar2,
                         ptcontrpy_codpaypy1  in varchar2,
                         ptcontrpy_codpaypy2  in varchar2,
                         ptcontrpy_codpaypy3  in varchar2,
                         ptcontrpy_codpaypy4  in varchar2,
                         ptcontrpy_codpaypy5  in varchar2,
                         ptcontrpy_codpaypy6  in varchar2,
                         ptcontrpy_codpaypy7  in varchar2,
                         ptcontrpy_codpaypy8  in varchar2,
                         ptcontrpy_codtax     in varchar2,
                         ptcontrpy_amtminsoc  in number,
                         ptcontrpy_amtmaxsoc  in number,
                         ptcontrpy_qtyage     in number,
                         ptcontpms_codincom1  in varchar2,
                         ptcontpms_codincom2  in varchar2,
                         ptcontpms_codincom3  in varchar2,
                         ptcontpms_codincom4  in varchar2,
                         ptcontpms_codincom5  in varchar2,
                         ptcontpms_codincom6  in varchar2,
                         ptcontpms_codincom7  in varchar2,
                         ptcontpms_codincom8  in varchar2,
                         ptcontpms_codincom9  in varchar2,
                         ptcontpms_codincom10 in varchar2,
                         ptcontpms_codretro1  in varchar2,
                         ptcontpms_codretro2  in varchar2,
                         ptcontpms_codretro3  in varchar2,
                         ptcontpms_codretro4  in varchar2,
                         ptcontpms_codretro5  in varchar2,
                         ptcontpms_codretro6  in varchar2,
                         ptcontpms_codretro7  in varchar2,
                         ptcontpms_codretro8  in varchar2,
                         ptcontpms_codretro9  in varchar2,
                         ptcontpms_codretro10 in varchar2,
                         ptpfhinf_dteeffec    in varchar2,
                         ptssrate_pctsoc      in number,
                         pv_coduser           in varchar2,
                         pv_lang              in varchar2);

  procedure process_clearyear ;
  procedure msg_err (p_error in varchar2) ;
  procedure round_up_amt(p_codpay 	in tinexinf.codpay%type,
                         p_amtpay 	in out number) ;
  procedure get_oth_ded ;
  procedure cal_studyded ;
  procedure cal_Legalded(p_amtnet 	in out number);
end;


/
