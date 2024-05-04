--------------------------------------------------------
--  DDL for Package HRPY6KB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY6KB" as
--08/07/2020 11:00
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

  global_v_batch_codapp     varchar2(100 char)  := 'HRPY6KB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPY6KB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codcomp             tcenter.codcomp%type;
  p_codempid            temploy1.codempid%type;
  p_year                number;
  procedure initial_value (json_str_input in clob);

  procedure check_process;
  procedure get_process(json_str_input in clob,json_str_output out clob);
  procedure gen_process(json_str_output out clob);

  procedure start_process(p_dteyrepay in number,
                          p_codcomp   in varchar2,
                          p_codempid  in varchar2,
                          o_numrec    out number,
                          o_time      out varchar2);

  function check_index_batchtask(json_str_input clob) return varchar2;
end hrpy6kb;

/
