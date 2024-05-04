--------------------------------------------------------
--  DDL for Package HRPY2OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2OE" is
-- last update: 24/08/2018 16:15

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  varchar2(100 char) := 'HRPY2OE';
  -- index
  p_dtestrt                 date;
  p_dteend                  date;
  p_dteresignstrt           date;
  p_dteresignend            date;
  p_codcomp                 varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_typretmt                varchar2(4 char);
  -- detail
  p_dtevcher                date;
  p_tcontpms_codincom1      varchar2(4 char);
  p_tcontpms_codincom2      varchar2(4 char);
  p_tcontpms_codincom3      varchar2(4 char);
  p_tcontpms_codincom4      varchar2(4 char);
  p_tcontpms_codincom5      varchar2(4 char);
  p_tcontpms_codincom6      varchar2(4 char);
  p_tcontpms_codincom7      varchar2(4 char);
  p_tcontpms_codincom8      varchar2(4 char);
  p_tcontpms_codincom9      varchar2(4 char);
  p_tcontpms_codincom10     varchar2(4 char);
  p_wrkyr                   tcompstn.wrkyr%type;
  p_cal                     varchar2(1 char);
  p_flgavgsal               varchar2(1 char);
  p_flgexpnse               varchar2(1 char);
  p_flgavgsal_tmp           varchar2(1 char);
  p_flgexpnse_tmp           varchar2(1 char);
  -- tdeducto
  p_qtysrvyr                number;
  p_qtyday                  number;
  p_qtymthsal               number;
  p_pctplus                 number(5,2);
  p_amtratec1               number(8,2);
  p_amtratec2               number(8,2);
  p_pctexprt                number(5,2);
  p_amtmaxtax               number(9,2);
  p_amtmaxday               number;
  -- tcompstn
  p_tcompstn_amtprovf       tcompstn.amtprovf%type;
--p_tcompstn_amtsvr         tcompstn.amtsvr%type;
  p_tcompstn_amtsvr         number;
  p_tcompstn_amtexctax      tcompstn.amtexctax%type;
  p_tcompstn_amtothcps      tcompstn.amtothcps%type;
  p_tcompstn_amtexpnse      tcompstn.amtexpnse%type;
  p_tcompstn_amttaxcps      tcompstn.amttaxcps%type;
  p_tcompstn_amtavgsal      tcompstn.amtavgsal%type;
  p_tcompstn_stavcher       tcompstn.stavcher%type;
  p_tcompstn_wrkyr          tcompstn.wrkyr%type;
  p_tcompstn_flgavgsal      tcompstn.flgavgsal%type;
  p_tcompstn_flgexpnse      tcompstn.flgexpnse%type;
  p_tcompstn_total_amt      number;
  -- temploy1, temploy3
  p_typpayroll              temploy1.typpayroll%type;
  p_codcurr                 temploy3.codcurr%type;
  p_amtsalary               temploy3.amtincom1%type;

  -- cal_amttax
  p_amtnet                  number;
  p_flgtax                  varchar2(10 char);
  json_index_rows           json_object_t;
  v_flgsecur                boolean;
  v_zupdsal                 varchar2(10 char);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_scrlabel(json_str_input in clob, json_str_output out clob);
  procedure gen_scrlabel(json_str_output out clob);
  procedure get_tdeducto(json_str_input in clob, json_str_output out clob);
  procedure gen_tdeducto(json_str_output out clob);
  procedure save_tdeducto(json_str_input in clob, json_str_output out clob);
  procedure get_tcompstn(json_str_input in clob, json_str_output out clob);
  procedure gen_tcompstn(json_str_output out clob);
  procedure get_amttax(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);

  function get_amtsvr (p_type varchar2) return number;
  function get_amtexctax (p_type varchar2) return number;
  function get_avgsal (p_type varchar2) return number;
  function get_tax_cal return number;
  function get_fst_pay return number;
  function cal_amttax (p_amtnet number,
                       p_flgtax varchar2) return number;
  procedure temp_report;
  procedure gen_report(json_str_input in clob, json_str_output out clob);

end HRPY2OE;

/
