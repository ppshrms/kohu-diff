--------------------------------------------------------
--  DDL for Package HREL22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL22E" as
  --para
  param_msg_error       varchar2(4000);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;
  global_v_codcurr      varchar2(100);

  b_index_codapp        tappprof.codapp%type;
  b_index_coduser       tusrprof.coduser%type;
  b_index_codempid      temploy1.codempid%type;
  b_index_codcours      tcourse.codcours%type;
  b_index_codsubj       tvsubject.codsubj%type;
  b_index_dtecourst     tlrncourse.dtecourst%type;
  b_index_dtesubjst     tlrnsubj.dtesubjst%type;
  b_index_numclseq      tpotentp.numclseq%type;
  b_index_dteyear       tpotentp.dteyear%type;

  p_typcours            tvcourse.typcours%type;
  p_flgdata             tvcourse.flgdata%type;
  p_flgposttest         tvcourse.flgposttest%type;

  procedure initial_value(json_str in clob);
  procedure get_subject_detail(json_str_input in clob,json_str_output out clob);
  procedure insert_learn_start(json_str_input in clob,json_str_output out clob);
  procedure done_subject(json_str_input in clob,json_str_output out clob);
  procedure leave_subject(json_str_input in clob,json_str_output out clob);
end;

/
