--------------------------------------------------------
--  DDL for Package STD_OT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_OT" is
-- last update: 21/04/2021 15:00        --redmine895

	v_chken varchar2(4 char) := check_emp(get_emp);

	type a_dtestr is table of date index by binary_integer;
	type a_qtyotstr is table of number index by binary_integer;

    v_a_tovrtime    tovrtime%rowtype;
    v_a_rteotpay    hral85b_batch.a_rteotpay;
    v_a_qtyminot    hral85b_batch.a_qtyminot;

  -- ??????????
  procedure get_week_ot(p_codempid      in temploy1.codempid%type,
						p_numotreq      in varchar2,
						p_dtereq        in date,
						p_numseq        in number,
						p_dtestrt       in date, 
                        p_dteend        in date,
                        p_qtyminb number, 
                        p_timbend varchar2, 
                        p_timbstr varchar2,
                        p_qtymind number, 
                        p_timdend varchar2, 
                        p_timdstr varchar2,
                        p_qtymina number, 
                        p_timaend varchar2, 
                        p_timastr varchar2,
                        global_v_codempid varchar2,
                        a_dtestweek     out a_dtestr,
                        a_dteenweek     out a_dtestr,
                        a_sumwork       out a_qtyotstr,
                        a_sumotreqoth   out a_qtyotstr,
                        a_sumotreq      out a_qtyotstr,
                        a_sumot         out a_qtyotstr,
                        a_totwork       out a_qtyotstr,
                        v_qtyperiod     out number);

  function get_dtestrt_period (p_codempid varchar2 ,p_dtestrot date) return date;  
  function get_dtestrt_period2 (p_codcomp varchar2 ,p_codcalen varchar2, p_dtestrot date) return date;  
  --function get_dtestrt_prdcomp(p_codcomp varchar2, p_dtestrot date) return date;

  function get_qtyminwk(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date) return number;

  -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
  -- function get_max_numseq(global_v_codempid varchar2) return number;  -- bk
  function get_max_numseq(global_v_codempid varchar2, p_codempid varchar2) return number; -- add
  -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887

  function chk_duptemp(v_codempid varchar2, v_dtework date, v_typot varchar2, global_v_codempid varchar2) return boolean;

  procedure get_totauto(v_codempid          in temploy1.codempid%type,
                        v_dtestrtwk         date, 
                        v_dteendwk          date,
                        global_v_codempid   varchar2);

  procedure get_ttotreq(v_codempid          in temploy1.codempid%type,
                        v_dtereq            date,
                        v_numseq            number,
                        v_numotreq          varchar2,
                        v_dtestrtwk         date, 
                        v_dteendwk          date,
                        global_v_codempid   varchar2);

  procedure get_totreq(v_codempid         in temploy1.codempid%type,
                        v_numotreq         varchar2,
                        v_dtestrtwk        date, 
                        v_dteendwk         date,
                        global_v_codempid  varchar2);        

  procedure get_tovrtime(v_codempid     in temploy1.codempid%type,
                         v_numotreq     varchar2,
                         v_dtestrtwk    date, 
                         v_dteendwk     date,
                         global_v_codempid varchar2);

  procedure get_calotreq(v_codempid varchar2, v_dtestrt date, v_dteend date,
                         v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
                         v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
                         v_qtymina number,v_timaend varchar2,v_timastr varchar2,
                         v_numotreq varchar2,
                         global_v_codempid varchar2);  

  function max_req(v_codempid varchar2, v_dtestrt date, v_dtereq date, v_numseq number, v_typot varchar2, v_numotreq varchar2, v_datatype varchar2) return boolean;

  function get_qtyminot(p_codempid varchar2, v_dtestrt date, v_dteend date,
                        v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
                        v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
                        v_qtymina number,v_timaend varchar2,v_timastr varchar2) return number;  

  function get_qtyminotOth_notTmp (p_codempid varchar2 ,p_dtestrtwk date, p_dteendwk date, p_codapp varchar2, global_v_codempid varchar2) return number;  

end;


/
