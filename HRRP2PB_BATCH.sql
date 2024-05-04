--------------------------------------------------------
--  DDL for Package HRRP2PB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2PB_BATCH" is
        para_zyear       number := 0;
        para_chken       varchar2(10) := check_emp(get_emp);
        para_coduser     temploy1.coduser%type;
        para_zminlvl  	 number;
        para_zwrklvl  	 number;
        para_zupdsal  	 varchar2(50 char);
        para_codcomp  	 varchar2(50 char);
        para_st_date     date ;
        para_en_date     date ;
        para_tmonth      number ;
        para_dteyrbug    number ;
        para_dtemthbugstr    number ;
        para_dtemthbugend     number ;
        p_numseq          number;

	type a_qtyminot is table of number index by binary_integer;
	type a_rteotpay is table of number(3,2) index by binary_integer;

  procedure  start_process;
  procedure  process_tmanpwmh_d ;
  procedure  update_ttmovemt ;
  procedure  process_temploy_month ;
  procedure  process_temploy_year ;
  procedure  cal_process(p_codcomp		in	varchar2,
                        p_dteyrbug	    in	number,
                        p_dtemthbugstr	in	number,
                        p_dtemthbugend	in	number,
                        p_coduser	  	in	varchar2,
                        p_numrec	  	out number,
                        p_error         out varchar2,
                        p_err_table     out varchar2);

PROCEDURE insert_tmanpwmh(
                        v_codempid     in varchar2,
                        v_codempmt     in varchar2,
                        v_typemp       in varchar2,
                        v_codcomp      in varchar2,
                        v_codpos       in varchar2,
                        v_numlvl       in number,
                        v_codbrlc      in varchar2,
                        v_codedlv      in varchar2,
                        v_typpayroll   in varchar2,
                        v_codcalen     in varchar2,
                        v_codjob       in varchar2,
                        v_jobgrade     in varchar2,
                        v_codgrpos     in varchar2,
                        p_numseq       in out number );

PROCEDURE insert_tmanpwmd(p_year in number,p_month in number,p_codempid in varchar2,p_numseq in number ) ;


end HRRP2PB_BATCH;

/
