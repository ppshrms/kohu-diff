--------------------------------------------------------
--  DDL for Package HRAP3RB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3RB" AS

  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
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
  v_zupdsal                 varchar2(1);

  b_index_filename          varchar2(200 char);
  b_index_dteyreap          tappemp.dteyreap%type;
  b_index_numtime           tappemp.numtime%type;
  b_index_derimiter         varchar2(10 char);
  b_index_dteimpot          date;
  b_index_codimpot          varchar2(200 char);

  v_rec_error               number  := 0;
  v_rec_tran                number  := 0;
  v_total                   number  := 0;
  v_pkey                    varchar2(500 char);

 --<<Nut
  param_upload              json_object_t;
  p_codempid                varchar2(500 char);
  p_stats                   varchar2(1 char);
  p_qtybeh                  tappemp.qtybeh%type;
  p_qtycmp                  tappemp.qtycmp%type;
  p_qtykpic                 tappemp.qtykpic%type;
  p_qtykpid                 tappemp.qtykpid%type;
  p_qtykpie                 tappemp.qtykpie%type;
  p_remark                  tappemp.remark3%type;
  p_codaplvl                varchar2(500 char);
  p_codcomp                 varchar2(500 char);
  p_qtypuns                 number;
  p_qtyta                   number;
  p_pctdbon                 number;
  p_pctdsal                 number;
  p_flgsal                  tappemp.flgsal%type;
  p_flgbonus                tappemp.flgbonus%type;
  -->>nut

  type text is table of varchar2(4000 char) index by binary_integer;
    v_column 	text;
    v_head  	text;
    v_text  	text;

  type rec_text is table of text index by binary_integer;
    v_rec_text    rec_text;

  procedure initial_value (json_str in clob);
  procedure submit_data (json_str_input in clob, json_str_output out clob);
  procedure comfirm_data (json_str_input in clob, json_str_output out clob);
  procedure gen_workingtime_detail(p_qtypuns out number, p_qtyta out number, p_pctdbon out number
                                   ,p_pctdsal out number, p_flgsal out varchar2, p_flgbonus out varchar2);--User37 #4460 14/09/2021


END HRAP3RB;

/
