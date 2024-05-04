--------------------------------------------------------
--  DDL for Package STD_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_AL" is
-- last update: 29/04/2024, 21/04/2021 15:00        --redmine895

	v_chken varchar2(4 char) := check_emp(get_emp);

  -- ??????????
  procedure gen_tattence(p_codempid   in temploy1.codempid%type,
											   p_codcalen   in temploy1.codcalen%type,
											   p_dtework    in date,
											   p_coduser    in varchar2,
											   p_flgupd     in varchar2,  -- 'G' - generate attendance,'N' - new employee, 'M' - movement, 'C' - change group
								         p_codcomp    in temploy1.codcomp%type,
								         p_typpayroll in temploy1.typpayroll%type,
								         p_flgatten   in temploy1.flgatten%type,
								         p_codempmt   in temploy1.codempmt%type,
								         p_rec        in out number);

  -- ???????????? tattence
  procedure cal_tattence(p_codempid    in varchar2,
                         p_stdate      in date,
                         p_endate      in date,
                         p_coduser     in varchar2,
                         p_rec         in out number);

  procedure cal_tlateabs(p_codempid 	 in varchar2,
                         p_dtework     in date,
                         p_typwork     in varchar2,
                         p_codshift    in varchar2,
                         p_dtein       in date,
                         p_timin       in varchar2,
                         p_dteout      in date,
                         p_timout      in varchar2,
                         p_coduser     in varchar2,
                         p_flgcall     in varchar2 default 'N',
                         p_qtylate 	   out number,
                         p_qtyearly    out number,
                         p_qtyabsent   out number,
                         p_rec    	   in out number,
                         p_ignore_flginput in varchar2 default 'N'); --user46 fix #7198 29/11/2021

  -- leave (???????????)
  procedure entitlement( p_codempid in varchar2,
									       p_codleave in varchar2,
									       p_dtestrle in date,
									       p_zyear    in number,    --13/02/2021 drop
									       p_qtyleave out number,
									       p_qtypriyr out number,
									       p_dteeffec out date,
                         p_coduser  in varchar2 default null); -- user22 : 08/12/2021 : ST11 ||

  -- Cycle Leave (????????)
  procedure cycle_leave( p_codcompy in tcompny.codcompy%type,
                         p_codempid in varchar2,
                         p_codleave in varchar2,
									       p_dtestrle in date,
									       p_year     out number,
									       p_dtecycst out date,
									       p_dtecycen out date);

  -- Cycle Leave (?????????????)
  procedure cycle_leave2(p_codcompy in tcompny.codcompy%type,
                         p_codempid in varchar2,
                         p_codleave in varchar2,
									       p_year     in number,
									       p_dtecycst out date,
									       p_dtecycen out date);

  function gen_req(p_typgen  in varchar2,
						       p_table   in varchar2,
						       p_column  in varchar2,
						       p_gbyear  in varchar2,
                   p_codcomp in varchar2 default '',
                   p_typleave in varchar2 default '') return varchar2;

	procedure upd_req( p_typgen  in varchar2,
									   p_code    in varchar2,
									   p_codusr  in varchar2,
									   p_gbyear  in varchar2,
                     p_codcompy in varchar2 default '',
                     p_typleave in varchar2 default '');

	procedure get_inc(p_codempid in varchar2,
									  p_amthour out number,
									  p_amtday  out number,
									  p_amtmth  out number);

	procedure get_movemt (p_codempid 		in varchar2,
											  p_dteeffec 		in out date,
 											  p_staupd1  		in varchar2,
											  p_staupd2  		in varchar2,
											  p_codcomp  		in out varchar2,
											  p_codpos	 		in out varchar2,
											  p_numlvl   		in out number,
 											  p_codjob   		in out varchar2,
											  p_codempmt 		in out varchar2,
											  p_typemp   		in out varchar2,
											  p_typpayroll  in out varchar2,
											  p_codbrlc  		in out varchar2,
											  p_codcalen 		in out varchar2,
											  p_jobgrade 		in out varchar2,
											  p_codgrpgl  	in out varchar2,
											  p_amthour     in out number,
											  p_amtday	    in out number,
											  p_amtmth	    in out number);

	procedure get_movemt2(p_codempid 		in varchar2,
											  p_dteeffec 		in out date,
 											  p_staupd1  		in varchar2,
											  p_staupd2  		in varchar2,
											  p_codcomp  		in out varchar2,
											  p_codpos	 		in out varchar2,
											  p_numlvl   		in out number,
 											  p_codjob   		in out varchar2,
											  p_codempmt 		in out varchar2,
											  p_typemp   		in out varchar2,
											  p_typpayroll  in out varchar2,
											  p_codbrlc  		in out varchar2,
											  p_codcalen 		in out varchar2,
											  p_jobgrade 		in out varchar2,
											  p_codgrpgl 		in out varchar2,
											  p_amtincom1		in out number,
 											  p_amtincom2   in out number,
											  p_amtincom3   in out number,
											  p_amtincom4   in out number,
											  p_amtincom5   in out number,
											  p_amtincom6   in out number,
											  p_amtincom7   in out number,
											  p_amtincom8   in out number,
											  p_amtincom9   in out number,
											  p_amtincom10  in out number);

	function Cal_Min_Dup(p_dtestrt1 date,
	                     p_dteend1  date,
	                     p_dtestrt2 date,
	                     p_dteend2  date) return number;
                         
end;

/
