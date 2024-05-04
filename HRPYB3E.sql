--------------------------------------------------------
--  DDL for Package HRPYB3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYB3E" is

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
  global_v_zupdsal          number;

  p_codcomp                 varchar2(100 char);
  p_codcompy                varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_dteeffec                date;
  p_codpfinf                varchar2(100 char);
  p_pvdffmt                 varchar2(100 char);
  p_numcomp                 varchar2(100 char);
  p_dteeffecquery           date;
  p_dteeffecOld             date;
  p_dteeffeco               date;
  p_flgsearch               varchar2(1 char);

  p_codplan                 varchar2(100 char);
  p_codplanOld              varchar2(100 char);
  p_codpolicy               varchar2(100 char);
  p_codpolicyOld            varchar2(100 char);
  p_pctinvt                 number;
  p_pctinvtold              number;
  v_flgDisabled             boolean;  

  isEdit                    boolean := true;
  isAdd                     boolean := false;
  forceAdd                  varchar2(1 char) := 'N';
  v_flgadd                  boolean := false;
  v_indexdteeffec          date;


  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;
  procedure check_save_detail;
  procedure check_save_detail_tablep ;
  procedure check_save_detail_tablec ;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);

end HRPYB3E;

/
