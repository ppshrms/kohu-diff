--------------------------------------------------------
--  DDL for Package HRAL82B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL82B_BATCH" is
  global_v_zminlvl  	  number;
  global_v_zwrklvl  	  number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;
  procedure start_process;
  procedure gen_vacation(p_codempid	in varchar2,
                         p_codcomp	in varchar2,
                         p_dtecal	  in date,
                         p_coduser	in varchar2,
                         p_numrec	out number);

  function entitlement_round(p_qtyvacat in number,p_typround in varchar2) return number;

end hral82b_batch;


--<< user22 01/01/2020 : V10.4
  /*procedure cal_process(p_codempid	in	varchar2,
                        p_codcomp	in	varchar2,
                        p_dtecal	in	date,
                        p_coduser	in	varchar2,
                        p_numrec	out number,
                        p_error     out varchar2,
                        p_err_table out varchar2);

  procedure cal_privilage(p_numrec    in out number);
  procedure cal_vacation (p_numrec    in out number);

  procedure cal_payvac_yearly(  p_codempid	in	varchar2,
                                p_codcomp	in	varchar2,
                                p_dtecal	in	date,
                                p_dteyrepay	in	number,
                                p_coduser	in	varchar2,
                                p_numrec	out number,
                                p_error     out varchar2,
                                p_err_table out varchar2);

  procedure cal_payvac_resign(p_codempid	in	varchar2,
                              p_codcomp		in	varchar2,
                              p_dtecal		in	date,
                              p_dteyrepay	in	number,
                              p_dtemthpay	in	number,
                              p_numperiod	in	number,
                              p_coduser		in	varchar2,
                              p_numrec		out number,
                              p_error       out varchar2,
                              p_err_table   out varchar2);

	procedure gen_income(p_codempid varchar2,p_amthour out number,p_amtday out number,p_amtmonth out number);
  function chk_exempt(p_codempid varchar2) return varchar2;*/
-->> user22 01/01/2020 : V10.4

/
