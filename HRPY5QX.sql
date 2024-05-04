--------------------------------------------------------
--  DDL for Package HRPY5QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5QX" as
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

  p_numperiod     number;
  p_month         number;
  p_year          number;
  p_codcomp       tcenter.codcomp%type;
  p_codcomp_tmp  tcenter.codcomp%type;
  p_codempid      temploy1.codempid%type;
  p_typpayroll    tcodtypy.codcodec%type;
  p_codpay        tinexinf.codpay%type;
  p_codpaypy1     tcontrpy.codpaypy1%type;
  p_codpaypy2     tcontrpy.codpaypy2%type;
  p_codpaypy3     tcontrpy.codpaypy3%type;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure check_detail1;
  procedure get_detail1(json_str_input in clob,json_str_output out clob);
  procedure gen_detail1(json_str_output out clob);

  procedure check_detail2;
  procedure get_detail2(json_str_input in clob,json_str_output out clob);
  procedure gen_detail2(json_str_output out clob);

  function get_date_label (v_numseq number,v_lang varchar2)return varchar2;
  function conv_fmt (p_value number,p_type varchar2) return varchar2;
  procedure del_temp (v_codapp varchar2,v_coduser varchar2);

  procedure insert_temp;

end hrpy5qx;

/
