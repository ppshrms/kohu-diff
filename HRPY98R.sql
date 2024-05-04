--------------------------------------------------------
--  DDL for Package HRPY98R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY98R" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  global_v_zyear        number := 0;
  v_zupdsal     		    varchar2(4 char);

  p_dteyrepay           number;
  p_typrep              number;
  p_codcomp             tcenter.codcomp%type;
  p_typincom            varchar2(4000 char);
  p_codapp              varchar2(4000 char);
  p_codapp1             varchar2(4000 char) := 'HRPY98R1'; -- ttemprpt ????????
  p_codapp2             varchar2(4000 char) := 'HRPY98R2';

--  procedure clear_ttemprpt;
  procedure get_page_number (p_record_per_page in number,
                             p_sum_page  out number);
  procedure initial_value (json_str_input in clob);
  procedure check_detail;
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_detail_sum(json_str_output out clob);
  procedure gen_detail_det(json_str_output out clob);

end HRPY98R;

/
