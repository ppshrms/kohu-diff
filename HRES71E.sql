--------------------------------------------------------
--  DDL for Package HRES71E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES71E" as
--Error ST11/user14||14/02/2023||STT-SS-2101||redmine754
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
  global_v_zwrklvl	        number;
  global_v_numlvlsalst	    number;
  global_v_numlvlsalen	    number;
  global_v_zupdsal		      varchar2(4 char);

  param_json_row            json_object_t;
  p_codcomp                 tcenter.codcomp%type;
  p_codempid                temploy1.codempid%type;
  p_codpos                  tmedreq.codpos%type;
  p_dtereq                  date;
  p_numseq                  tmedreq.numseq%type;
  p_dtestrt                 date;
  p_dteend                  date;
  p_numvcher                tmedreq.numvcher%type;
  p_codrel                  tmedreq.codrel%type;
  p_dtecrest                tmedreq.dtecrest%type;
  p_typamt                  tmedreq.typamt%type;
  p_typrel                  tmedreq.codrel%type;
  p_amtexp                  tmedreq.amtexp%type;
  p_staappr                 tmedreq.staappr%type;
  p_namsick       tmedreq.namsick%type;
  p_codcln        tmedreq.codcln%type;
  p_coddc         tmedreq.coddc%type;
  p_typpatient    tmedreq.typpatient%type;
  p_dtecreen      tmedreq.dtecreen%type;
  p_dtebill       tmedreq.dtebill%type;
  p_qtydcare      tmedreq.qtydcare%type;
  p_flgdocmt      tmedreq.flgdocmt%type;
  p_amtalw        tmedreq.amtalw%type;
  p_amtavai       tmedreq.amtavai%type;
  p_amtovrpay     tmedreq.amtovrpay%type;
  p_amtemp        tmedreq.amtemp%type;
  p_amtpaid       tmedreq.amtpaid%type;
  p_dteappr       tmedreq.dteappr%type;
  p_codappr       tmedreq.codappr%type;
  p_typpay        tmedreq.typpay%type;
  p_dtepaid       tmedreq.dtepaid%type;
  p_numdocmt      tmedreq.numdocmt%type;
  p_typpayroll    tmedreq.typpayroll%type;

  tmedreq_approvno    tmedreq.approvno%type;
  tmedreq_routeno     tmedreq.routeno%type;
  tmedreq_staappr     tmedreq.staappr%type;
  tmedreq_codappr     tmedreq.codappr%type;
  tmedreq_dteappr     tmedreq.dteappr%type;
  tmedreq_remarkap    tmedreq.remarkap%type;

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure check_save(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure get_relation(json_str_input in clob, json_str_output out clob);
  procedure get_credit(json_str_input in clob, json_str_output out clob);
  procedure cancel_data(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure send_mail (json_str_input in clob, json_str_output out clob);
end hres71e;

/
