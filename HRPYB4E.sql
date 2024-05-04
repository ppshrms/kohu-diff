--------------------------------------------------------
--  DDL for Package HRPYB4E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYB4E" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(4 char);

  p_codcomp                 varchar2(100 char);
  p_chkcodempid             varchar2(100 char);
  p_dtereti_fr              date;
  p_dtereti_to              date;

  p_nummember               varchar2(100 char);
  p_dtereti                 date;

  p_codempid_query          varchar2(100 char);
  p_amtcaccu                number;
  p_amtcaccu2               number;
  p_amtretn                 number;
  p_amttax                  number;
  p_numvcher                varchar2(100 char);
  p_desnote                 varchar2(500 char);
  p_dtevcher                date;
  p_accinte                 number;
  p_accintc  	              number;
  p_amtinte	                number;
  p_amtintc	                number;
  p_rateeret	              number;
  p_ratecret	              number;
  p_accmembe	              number;
  p_accmembc	              number;
  p_sumamt1	                number;
  p_sumamt2	                number;
  p_codpfinf                TPFMEMB.CODPFINF%type;
  p_codplan                 TPFMEMB.CODPFINF%type;
  p_qtywrkmth               number;
  p_qtymember               number;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;
  procedure check_save_detail;
--  procedure check_save_detail_table (p_flg varchar2);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  function gen_detail(json_str_input in clob) return clob;

  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure find_emp_data(detail1_stmt out clob,
                          v_yearwork out number,v_monthwork out number,v_daywork out number,                          
                          v_yearmember out number,v_monthmember out number,v_daymember out number); --09/12/2020
end HRPYB4E;

/
