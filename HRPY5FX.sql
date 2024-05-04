--------------------------------------------------------
--  DDL for Package HRPY5FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5FX" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_money_str   number;
  p_money_end   number;
  p_codcomp     tcenter.codcomp%type;
  p_typpayroll  tcodtypy.codcodec%type;

  p_level1      boolean;
  p_level2      boolean;
  p_level3      boolean;
  p_level4      boolean;
  p_level5      boolean;
  p_level6      boolean;
  p_level7      boolean;
  p_level8      boolean;
  p_level9      boolean;
  p_level10     boolean;
  p_leveltotal  boolean;

  p_level1_c    number := 0;
  p_level2_c    number := 0;
  p_level3_c    number := 0;
  p_level4_c    number := 0;
  p_level5_c    number := 0;
  p_level6_c    number := 0;
  p_level7_c    number := 0;
  p_level8_c    number := 0;
  p_level9_c    number := 0;
  p_level10_c   number := 0;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure initial_value_breaklevel (json_str_input in clob);

  procedure check_breaklevelcustom;
  procedure post_breaklevelcustom(json_str_input in clob,json_str_output out clob);
  procedure breaklevelcustom_data(json_str_output out clob);
end hrpy5fx;

/
