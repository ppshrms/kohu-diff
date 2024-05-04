--------------------------------------------------------
--  DDL for Package HRPY93R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY93R" as
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

  p_year                number;
  p_numrec              number;
  p_codcomp             tcenter.codcomp%type;
  p_codrevn             tcodrevn.codcodec%type;

  p_codapp1             varchar2(4000 char) := 'HRPY93R1'; -- ttemprpt ????????
  p_codapp2             varchar2(4000 char) := 'HRPY93R2'; -- ttemprpt ??????????
  p_codapp3             varchar2(4000 char) := 'HRPY93R3'; -- ttemprpt detail header, footer

  p_record_per_page     number := 10; --
  p_file_dir            varchar2(4000 char) := 'UTL_FILE_DIR';
  p_file_path           varchar2(4000 char) := get_tsetup_value('PATHEXCEL');


  procedure initial_value (json_str_input in clob);
  procedure check_detail1;
  procedure get_detail1(json_str_input in clob,json_str_output out clob);
  procedure gen_detail1(json_str_output out clob);

  procedure check_detail2;
  procedure get_detail2(json_str_input in clob,json_str_output out clob);
  procedure gen_detail2(json_str_output out clob);

  procedure check_detail3;
  procedure get_detail3(json_str_input in clob,json_str_output out clob);
  procedure gen_detail3(json_str_output out clob);
end hrpy93r;

/
