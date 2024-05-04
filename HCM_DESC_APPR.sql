--------------------------------------------------------
--  DDL for Package HCM_DESC_APPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_DESC_APPR" IS
-- last update: 16/09/2019 15:30

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_codapp                  TAPMOVMT.CODAPP%TYPE;
  p_codempid                TAPMOVMT.CODEMPID%TYPE;
  p_dteeffec                TAPMOVMT.DTEEFFEC%TYPE;
  p_numseq                  TAPMOVMT.NUMSEQ%TYPE;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_movement_types (json_str_input in clob, json_str_output out clob);
  procedure get_desc_approver (json_str_input in clob, json_str_output out clob);
END HCM_DESC_APPR;

/
