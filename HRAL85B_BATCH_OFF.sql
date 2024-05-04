--------------------------------------------------------
--  DDL for Package HRAL85B_BATCH_OFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL85B_BATCH_OFF" is
  para_zyear      number := 0;-- v11 not use : pdk.check_year('');
  para_chken      varchar2(10) := check_emp(get_emp);
  para_coduser    temploy1.coduser%type;
  para_zminlvl    number;
  para_zwrklvl    number;
  para_zupdsal    varchar2(50 char);
  type a_qtyminot is table of number index by binary_integer;
  type a_rteotpay is table of number(3,2) index by binary_integer;

  procedure start_process;

  procedure cal_process(p_codempid    in  varchar2,
                        p_codcomp     in  varchar2,
                        p_codcalen    in  varchar2,
                        p_typpayroll  in  varchar2,
                        p_dtestrt     in  date,
                        p_dteend      in  date,
                        p_coduser     in  varchar2,
                        p_numrec      out number,
                        p_error       out varchar2,
                        p_err_table   out varchar2);

  function check_ot(p_codempid varchar2,p_dtework date,p_typot varchar2) return boolean;

  procedure cal_time_ot(p_codcompy    varchar2,
                        p_dteeffec    date,
                        p_condot      varchar2,
                        p_condextr    varchar2,
                        --
                        p_numotreq    varchar2,
                        p_codempid    varchar2,
                        p_dtewkreq    date,
                        p_typot       varchar2, --B,D,A
                        --
                        p_codshift    varchar2,
                        p_dtein       date,   --tattence.dtein
                        p_timin       varchar2, --tattence.timin
                        p_dteout      date,     --tattence.dteout
                        p_timout      varchar2, --tattence.timout
                        --
                        p_dtestrt     date,   --totreqd.dtestrt
                        p_timstrt     varchar2, --totreqd.timstrt
                        p_dteend      date,     --totreqd.dteend
                        p_timend      varchar2, --totreqd.timend
                        p_qtyminreq   number,
                        --
                        p_codrem      varchar2,
                        p_codappr     varchar2,
                        p_dteappr     date,
                        p_coduser     varchar2,
                        p_chkwkfull   varchar2,-- N = For hral42u Only, Y = else other heal4ke,hral85b
                        --
                        p_tovrtime    out tovrtime%rowtype,
                        p_rteotpay    out a_rteotpay,
                        p_qtyminot    out a_qtyminot);

  procedure cal_break_ot(p_codcompy   in varchar2,
                         p_dteeffec   in date,
                         p_numseq     in number,
                         p_dtework    in date,
                         p_strtot     in date,
                         p_endot      in date,
                         p_qtyminot   in out number,
                         p_qtydedbrk  out number,
                         p_codcomp    in varchar2,
                         p_codpos     in varchar2,
                         p_numlvl     in number,
                         p_codjob     in varchar2,
                         p_codempmt   in varchar2,
                         p_typemp     in varchar2,
                         p_typpayroll in varchar2,
                         p_codbrlc    in varchar2,
                         p_codcalen   in varchar2,
                         p_jobgrade   in varchar2,
                         p_codgrpgl   in varchar2,
                         p_codshift   in varchar2,
                         p_typwork    in varchar2,
                         p_typot      in varchar2);

  function cal_round_ot(p_codcompy    varchar2,
                        p_dteeffec    date,
                        p_qtyminot    number,
                        p_codcomp     varchar2,
                        p_codpos      varchar2,
                        p_numlvl      number,
                        p_typemp      varchar2,
                        p_codempmt    varchar2,
                        p_codcalen    varchar2,
                        p_codshift    varchar2,
                        p_typwork     varchar2,
                        p_typot       varchar2,
                        p_jobgrade    varchar2,
                        p_typpayroll  varchar2) return number;

  procedure InsUpdDel_ot(p_codempid   varchar2,
                         p_dtework    date,
                         p_typot      varchar2,
                         p_type       varchar2,   --D=Delete, A=Insert/Update
                         p_tovrtime   tovrtime%rowtype,
                         p_rteotpay   a_rteotpay,
                         p_qtyminot   a_qtyminot,
                         p_rec        in out number);

  procedure Find_period_time(p_type     varchar2, --'1' = find period of Setup Time / OT Break, '2' = find period of Shift Break
                             p_dtework  date,
                             p_codshift varchar2,
                             p_dtestrt  date,
                             p_dteend   date,
                             p_timestrt varchar2,
                             p_timeend  varchar2,
                             p_dtedupst out date,
                             p_dtedupen out date,
                             p_mindup   out number);

  procedure gen_compensate(p_codempid    in varchar2,
                           p_codcomp     in varchar2,
                           p_codcalen    in varchar2,
                           p_typpayroll  in varchar2,
                           p_dtestrt     in date,
                           p_coduser     in varchar2,
                           p_numrec      out number,
                           p_error       out varchar2,
                           p_err_table   out varchar2);

end HRAL85B_BATCH_OFF;

/
