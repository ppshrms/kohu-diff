--------------------------------------------------------
--  DDL for Package HRPYBAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYBAX" as
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

  p_codcomp             tcenter.codcomp%type;
  p_codpfinf            tpfmemb.codpfinf%type;
  p_dtestr              date;
  p_dteend              date;

  p_breakLevelConfig    json_object_t;
  p_rows                json_object_t;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure check_breaklevelcustom;
  procedure post_breaklevelcustom(json_str_input in clob,json_str_output out clob);
  procedure breaklevelcustom_data(json_str_output out clob);

end hrpybax;

/
