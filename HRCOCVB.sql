--------------------------------------------------------
--  DDL for Package HRCOCVB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCOCVB" AS

  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  global_v_codempid   varchar2(100 char);
  global_v_type_year  varchar2(2 char);

  param_msg_error     varchar2(4000 char);

  type data_error is
    table of varchar2(4000) index by binary_integer;
  p_text              data_error;
  p_error_code        data_error;
  p_numseq            data_error;
  v_msgerror          varchar2(4000 char);

function check_date(p_date  in varchar2) return boolean;

function check_number(p_number  in varchar2) return boolean;

function check_year(p_year  in number) return number;

function check_dteyre (p_date in varchar2) return date;

function get_result(p_rec_tran   in number,
                    p_rec_err    in number)return clob;

procedure get_process(json_str_input    in clob, json_str_output   out clob);

procedure get_process_pm_temploy1(
  json_str_input in clob,
  json_str_output out clob
);

procedure validate_excel_pm_temploy1(
  json_str_input in clob,
  p_rec_tran out number,
  p_rec_error out number
);

END HRCOCVB;

/
