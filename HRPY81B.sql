--------------------------------------------------------
--  DDL for Package HRPY81B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY81B" as
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

  global_v_batch_codapp     varchar2(100 char)  := 'HRPY81B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPY81B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_filename   varchar2(100 char);
  global_v_batch_pathfile   varchar2(100 char);

  p_dtestr              date;
  p_dteend              date;
  p_rec                 number;
  p_file_dir            varchar2(4000 char) := 'UTL_FILE_DIR';
  p_file_path           varchar2(4000 char) := get_tsetup_value('PATHEXCEL');

  p_month               number;
  p_year                number;
  p_codcomp             tcenter.codcomp%type;
  p_codbrsoc            tcodsoc.codbrsoc%type;
  p_numbrlvl            tcodsoc.numbrlvl%type;
  p_type                varchar2(1 char); -- '1' new emp, '2' resign
  procedure initial_value (json_str_input in clob);

  procedure check_process;
  procedure get_process(json_str_input in clob,json_str_output out clob);
  procedure gen_process(json_str_output out clob);
  function chk_flgscoc(v_codempid varchar2) return varchar2;

  function check_index_batchtask(json_str_input clob) return varchar2;

end hrpy81b; -- TCODSOC

/
