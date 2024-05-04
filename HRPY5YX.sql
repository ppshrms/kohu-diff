--------------------------------------------------------
--  DDL for Package HRPY5YX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5YX" as

  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char);
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

  -- get parameter search index
  p_codapp                  varchar2(100 char) := 'HRPY5YX';
  p_numperiod               number;
  p_month                   number;
  p_year                    number;
  p_codcomp                 varchar2(100 char);
  p_codempid                varchar2(10 char);
  p_codpay                  varchar2(10 char);
  p_typpayroll              varchar2(10 char);
  v_amtnet                  number;

  p_codcomp_tmp   tcenter.codcomp%type;
  p_codpaypy2     tcontrpy.codpaypy2%type;
  p_codpaypy3     tcontrpy.codpaypy3%type;
  p_codpaypy7     tcontrpy.codpaypy7%type;

  procedure initial_value (json_str_input in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  function get_detail1(json_str_input clob) return t_hrpy5yx_detail1;
  function gen_detail1 return t_hrpy5yx_detail1;

  function get_detail2(json_str_input clob) return t_hrpy5yx_detail2;
  function gen_detail2 return t_hrpy5yx_detail2;

  function get_date_label (v_numseq number,v_lang varchar2)return varchar2;
  function conv_fmt (p_value number,p_type varchar2) return varchar2;
  procedure del_temp (v_codapp varchar2,v_coduser varchar2);

  procedure insert_temp;
end HRPY5YX;

/
