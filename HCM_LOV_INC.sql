--------------------------------------------------------
--  DDL for Package HCM_LOV_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_INC" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_income_deduct(json_str_input in clob) return clob;             --LOV for All  Income/Deduction All (LOV_INC.LOV_INC1 =>> typpay like '%')
  function get_income(json_str_input in clob) return clob;                    --LOV for All  Income (LOV_INC.LOV_INC2 =>> typpay ='1')
  function get_income_other_regular(json_str_input in clob) return clob;      --LOV for All  Income Other Regular (LOV_INC.LOV_INC3 = >>typpay in ('2','3'))
  function get_income_other_temporary3(json_str_input in clob) return clob;
  function get_income_other_temporary5(json_str_input in clob) return clob;
  function get_income_other_temporary(json_str_input in clob) return clob;    --LOV for All  Income-other- (LOV_INC.LOV_INC4 = >>typpay in ('4','5','6'))
  function get_income_regular_temporary(json_str_input in clob) return clob;  --LOV for All  Income-other- (LOV_INC.LOV_INC5 = >>typpay in ('1','2','3'))
  function get_income_other_regular_pay(json_str_input in clob) return clob;  --LOV for All  Income- (LOV_INC.LOV_INC8 = >>typpay in ('2'))
  function get_income_deduction_regular(json_str_input in clob) return clob;  --LOV for All  Income- (LOV_INC.LOV_INC9 = >>typpay in ('4'))
  function get_income_tax(json_str_input in clob) return clob;                --LOV for All  Income- (LOV_INC.LOV_INC10 = >>typpay in ('6'))
  function get_income_deduction_reg_temp(json_str_input in clob) return clob; --LOV for All  Income- (LOV_INC.LOV_INC11 = >>typpay in ('4','5'))
  function get_income_bank_free(json_str_input in clob) return clob;          --LOV for All  Income- (LOV_INC.LOV_INC13 = >>typpay in ('7'))
  function get_income_group(json_str_input in clob) return clob;              --LOV for Income Group- (LOV_INC.LOV_INC12)

end;

/
