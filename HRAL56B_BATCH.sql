--------------------------------------------------------
--  DDL for Package HRAL56B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL56B_BATCH" is
  --param_msg_error varchar2(4000 char);
  para_dtestrt		date;
  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;
  param_msg_error varchar2(4000 char);
  procedure start_process;
  procedure gen_leave_Cancel(p_codempid	in	varchar2,
                             p_codcomp	in	varchar2,
                             p_stdate		in	date,
                             p_endate		in	date,
                             p_coduser	in	varchar2,
                             p_numrec		out number);

  procedure gen_leave(p_codempid	in	varchar2,
                      p_codcomp		in	varchar2,
                      p_stdate		in	date,
                      p_endate		in	date,
                      p_coduser	  in	varchar2,
                      p_numrec		out number);

	procedure upd_tleavsum(p_codempid 	in varchar2,
                         p_dtework		in date,
                         p_codleave		in varchar2,
                         p_coduser		in varchar2);

	procedure del_tleavetr(p_codempid 	in varchar2,
                         p_dtework		in date,
                         p_codleave		in varchar2,
                         p_coduser		in varchar2);

  procedure cal_time_leave(p_flgchol    in tleavety.flgchol%type,
                           p_codcomp    in temploy1.codcomp%type,
                           p_codcalen   in tattence.codcalen%type,
                           p_typwork    in tattence.typwork%type,
                           p_codshift   in tattence.codshift%type,
                           p_dtestrtw   in tattence.dtestrtw%type,
                           p_timstrtw   in tattence.timstrtw%type,
                           p_dteendw    in tattence.dteendw%type,
                           p_timendw    in tattence.timendw%type,
                           p_dtestrtle  in tlereqst.dtestrt%type,
                           p_timstrtle  in out tlereqst.timstrt%type,
                           p_dteendle   in tlereqst.dtestrt%type,
                           p_timendle   in out tlereqst.timstrt%type,
                           p_qtymin     out tleavetr.qtymin%type,
                           p_qtyday     out tleavetr.qtyday%type,
                           p_qtyavgwk   in number,
                           p_flgleave   in varchar2);

	procedure gen_entitlement(p_codempid   in varchar2,
                            p_numlereq   in varchar2,
                            p_dayeupd    in date,
                            p_flgleave   in varchar2,
                            p_codleave   in varchar2,
                            p_dteleave   in date,
                            p_dtestrt    in date,
                            p_timstrt    in varchar2,
                            p_dteend     date,
                            p_timend     in varchar2,
                            p_dteprgntst in date,
                            p_v_zyear    in number,
                            p_coduser    in varchar2,
	                          p_coderr     out varchar2,
                            p_qtyday1    out number, -- day entitle
                            p_qtyday2    out number, -- day leave
                            p_qtyday3    out number, -- day leave req (AL + ESS)
                            p_qtyday4    out number, -- balance
                            p_qtyday5    out number, -- day leave pay
                            p_qtyday6    out number, -- day leave not pay
                            p_qtyday7    out number, -- time leave
                            p_qtyday8    out number, -- time leave req (AL + ESS)
                            p_qtyavgwk   out number);

	procedure gen_min_req(p_save         in boolean,
                        p_numlereq     in varchar2,
                        p_codempid     in varchar2,
                        p_flgleave     in varchar2,
                        p_codleave     in varchar2,
                        p_dteleave     in date,
                        p_dtestrt      in date,
                        p_timstrt      in out varchar2,
                        p_dteend       date,
                        p_timend       in out varchar2,
                        p_coduser      in varchar2,
	                      p_summin       out number,
                        p_sumday       out number,
                        p_qtyavgwk     out number,
                        p_coderr       out varchar2);

  function check_condition_leave(p_codempid in varchar2,p_codleave in varchar2,p_dteeffec in date,p_flgmaster in varchar2) return boolean;--p_flgmaster = 1 = temploy1, 2 = movement

--<< 20210213 Package not Use
/*
  procedure cal_process
		(p_codempid		in	varchar2,
		 p_codcomp		in	varchar2,
		 p_stdate			in	date,
		 p_endate			in	date,
		 p_coduser		in	varchar2,
		 p_numrec			out number);

	procedure gen_tlereqd
		(p_codempid		in	varchar2,
		 p_codcomp		in	varchar2,
		 p_stdate			in	date,
		 p_endate			in	date,
		 p_coduser		in	varchar2);

	procedure cal_leave
		(p_tlereqd		in 	tlereqd%rowtype,
		 p_tleavetr 	out tleavetr%rowtype,
		 p_error    	out boolean,
		 p_coduser		in	varchar2,
		 p_zminlvl		in	number,
		 p_zwrklvl		in	number,
		 p_zyear			in	number,
		 p_yrecycle		in	number,
		 p_qtyavgwk		in	number);

	procedure upd_tleavetr
		(p_tleavetr 	in tleavetr%rowtype,
		 p_coduser		in varchar2,
		 p_zyear			in number,
		 p_yrecycle		in number,
		 p_numrec			in out number);*/
end HRAL56B_BATCH;

/
