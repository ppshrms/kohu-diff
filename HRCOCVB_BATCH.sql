--------------------------------------------------------
--  DDL for Package HRCOCVB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCOCVB_BATCH" as
  v_chken         varchar2(4):= check_emp(get_emp) ;
  param_msg_error     varchar2(4000 char);
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  global_v_codempid   varchar2(100 char);
  global_v_type_year  varchar2(2 char);
  p_codcomp           varchar2(4000 char);
  v_codcomp           varchar2(100 char);
  v_msgerror          varchar2(4000 char);
  v_numseq_tmp        number;
  type data_error is
    table of varchar2(4000) index by binary_integer;
  p_text              data_error;
  p_error_code        data_error;
  p_numseq            data_error;


  function check_date(p_date  in varchar2) return boolean;

  function check_number(p_number  in varchar2) return boolean;

  function check_year(p_year  in number) return number;

  function check_dteyre (p_date in varchar2) return date;

  function get_result(p_rec_tran   in number,
                      p_rec_err    in number)return clob;
-- CO
  -- TCOMPNY
  procedure get_process_co_tcompny(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_co_tcompny(json_str_input in clob,
                                      p_rec_tran     out number,
                                      p_rec_error    out number);
  -- TCENTER, TCOMPNYD
  procedure get_process_co_tcenter(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_co_tcenter(json_str_input in clob,
                                      p_rec_tran     out number,
                                      p_rec_error    out number);
  -- TPOSTN
  procedure get_process_co_tpostn(json_str_input    in clob,
                                  json_str_output   out clob);

  procedure validate_excel_co_tpostn(json_str_input in clob,
                                     p_rec_tran     out number,
                                     p_rec_error    out number);
  -- TJOBCODE, TJOBDET
  procedure get_process_co_tjobcode(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_co_tjobcode(json_str_input in clob,
                                     p_rec_tran       out number,
                                     p_rec_error      out number);

  -- TCODAPLV, TCODAPPO, TCODASST, TCODAWRD, TCODBANK, TCODBONS, TCODBUSNO, TCODBUSRT, TCODCATE, TCODCATEXM, TCODCATG, TCODCERT, TCODCHGSH, TCODCNTY, TCODCOLA, TCODCURR, TCODDEVT, TCODDGEE, TCODDISP, TCODEDUC,TCODEMPL, TCODEXP, TCODFLEX, TCODGPOS, TCODGPPAY, TCODGRBUG, TCODGRPAP, TCODGRPGL, TCODHEAL, TCODINST, TCODISRP, TCODJOBG, TCODJOBPOST, TCODLANG, TCODLEGALD, TCODLOCA, TCODMAJR, TCODMEDI, TCODMIST, TCODMOVE,TCODNATN, TCODOCCU, TCODOTRQ, TCODPFINF, TCODPFPLC, TCODPFPLN, TCODPLCY, TCODPROV, TCODPUNH, TCODREASON, TCODREGN, TCODRELI, TCODRETM, TCODREVN, TCODREWD, TCODSERV, TCODSIZE, TCODSKIL, TCODSLIP, TCODSUBJ,TCODTIME, TCODTRAVUNIT, TCODTYDOC, TCODTYPCRT,TCODTYPWRK, TCODTYPY, TCODUNIT, TCODWORK, TCOMPGRP, TDCINF, TSUBJECT
  procedure get_process_co_tcommon(json_str_input   in clob,
                                   json_str_output  out clob);

  procedure validate_excel_co_tcommon(json_str_input in clob,
                                      p_rec_tran     out number,
                                      p_rec_error    out number);
-- PM
  procedure get_process_pm_temploy1(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_temploy1(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_temploy2(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_temploy2(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_temploy3(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_temploy3(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

   procedure get_process_pm_teducatn(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_teducatn(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

   procedure get_process_pm_tapplwex(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_tapplwex(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_tfamily(json_str_input    in clob,
                                                      json_str_output   out clob);

  procedure validate_excel_pm_tfamily(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_tspouse(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tspouse(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tchildrn(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tchildrn(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tapplref(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tapplref(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_ttrainbf(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_ttrainbf(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tguarntr(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tguarntr(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tcolltrl(json_str_input    in clob,
                                                     json_str_output   out clob);

  procedure validate_excel_pm_tcolltrl(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_trelatives(json_str_input    in clob,
                                                     json_str_output   out clob);

  procedure validate_excel_pm_trelatives(json_str_input in clob,
                                                         p_rec_tran     out number,
                                                         p_rec_error    out number);

  procedure get_process_pm_thismove(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_thismove(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_thismist (json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_thismist(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tbcklst(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tbcklst(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tlegalexe(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tlegalexe(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;

  procedure get_process_pm_tlegalexd(json_str_input  in clob,
                                                     json_str_output out clob);

  procedure validate_excel_pm_tlegalexd(json_str_input in clob,
                                                        p_rec_tran     out number,
                                                        p_rec_error    out number) ;
-- PY
  procedure get_process_py_tcoscent(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_py_tcoscent(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_py_taccodb(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_taccodb(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_py_tempinc(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tempinc(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

  procedure get_process_py_tempded(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tempded(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

  procedure get_process_py_tempded_sp(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tempded_sp(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

  procedure get_process_py_tinexinf(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tinexinf(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

  procedure get_process_py_tpfmemb(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tpfmemb(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

  procedure get_process_py_tsincexp(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_py_tsincexp(json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number);

-- AL
  procedure get_process_al_tshiftcd(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_al_tshiftcd(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_al_tlateabs(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_al_tlateabs(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_al_tleavetr(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_al_tleavetr(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_al_tleavsum(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_al_tleavsum(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_al_tempawrd(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_al_tempawrd(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

-- BF
  procedure get_process_bf_tclnsinf(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_tclnsinf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_bf_thwccase(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_thwccase(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_bf_tobfinf(json_str_input    in clob,
                                  json_str_output   out clob);

  procedure validate_excel_bf_tobfinf(json_str_input in clob,
                                      v_rec_tran     out number,
                                      v_rec_error    out number);

  procedure get_process_bf_ttravinf(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_ttravinf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_bf_thisheal(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_thisheal(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_bf_tloaninf(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_tloaninf(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_bf_tinsrer(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_bf_tinsrer(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

-- TR
  procedure get_process_tr_tcourse(json_str_input    in clob,
                                   json_str_output   out clob);

  procedure validate_excel_tr_tcourse(json_str_input in clob,
                                      v_rec_tran     out number,
                                      v_rec_error    out number);

  procedure get_process_tr_tinstruc(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_tr_tinstruc(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

  procedure get_process_tr_tcoursub(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_tr_tcoursub(json_str_input in clob,
                                       v_rec_tran     out number,
                                       v_rec_error    out number);

-- EL    
  procedure get_process_el_tvcourse(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvcourse(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_el_tvsubject(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvsubject(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_el_tvchapter(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvchapter(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_el_tvtest(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvtest(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

  procedure get_process_el_tvquest(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvquest(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);               

  procedure get_process_el_tvquestd1(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvquestd1(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);          

  procedure get_process_el_tvquestd2(json_str_input    in clob,
                                        json_str_output   out clob);

  procedure validate_excel_el_tvquestd2(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);   

  procedure get_process_el_tvtesta(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_el_tvtesta(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

-- RP

  procedure get_process_rp_tposemph(json_str_input    in clob,
                                    json_str_output   out clob);

  procedure validate_excel_rp_tposemph(json_str_input in clob,
                                       p_rec_tran     out number,
                                       p_rec_error    out number);

end hrcocvb_batch;

/
