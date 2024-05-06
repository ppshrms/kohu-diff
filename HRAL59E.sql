--------------------------------------------------------
--  DDL for Package HRAL59E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL59E" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			    varchar2(4 char);
  global_v_zyear        varchar2(4 char) := 0;

  b_index_dtereq        date;   --date

  p_codempid            varchar2(100 char);
  p_codcomp             varchar2(100 char);
  p_numlereqg           varchar2(100 char);
  p_stdate              date;
  p_endate              date;
  p_codcalen            varchar2(100 char);
  p_codleave            varchar2(4 char);
  p_dteleave            date;
  p_dtestrt             date;
  p_timstrt             varchar2(10 char);
  p_dteend              date;
  p_timend              varchar2(10 char);
  p_deslereq            varchar2(4000 char);
  p_dteappr             date;
  p_codappr             varchar2(100 char);
  p_flgleave            varchar2(1 char);

  --
  v_codempid            varchar2(100 char);
  v_codcomp             varchar2(40 char);
  v_codshift            tshiftcd.codshift%type;
  v_qtyavgwk            number;
  p_codshift            tshiftcd.codshift%type;

  param_json2           json_object_t;
  param_file            json_object_t;
  param_warn            varchar2(10 char) := '';
  param_flgwarn         varchar2(100 char) := '';

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_groupleave_detail(json_str_input in clob, json_str_output out clob);
  procedure get_groupleave_table(json_str_input in clob, json_str_output out clob);
  procedure get_groupleave_attch(json_str_input in clob, json_str_output out clob);
  procedure get_empleave(json_str_input in clob, json_str_output out clob);
  procedure get_shiftcd(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure get_check_flgleave (json_str_input in clob, json_str_output out clob);
--  function check_leave_after(p_codcomp varchar2,p_dtereq date,p_dteleave date,p_daydelay number, p_codcalen varchar2) return varchar2;
end HRAL59E;

/
