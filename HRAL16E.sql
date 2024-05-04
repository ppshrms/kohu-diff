--------------------------------------------------------
--  DDL for Package HRAL16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL16E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  temploy1.coduser%type;
  global_v_codempid temploy1.codempid%type;
  global_v_lang     varchar2(10 char) := '102';

  p_codapp          tempaprq.codapp%type := 'HRAL16E';
  b_index_codshift  tshiftcd.codshift%type;

  p_codshift        tshiftcd.codshift%type;
  p_desshiftt       varchar2(150 char);
  p_desshift        varchar2(150 char);
  p_desshifte       varchar2(150 char);
  p_desshift3       varchar2(150 char);
  p_desshift4       varchar2(150 char);
  p_desshift5       varchar2(150 char);
  p_qtydaywk        number;
  p_grpshift        varchar2(8 char);
  p_timstrtw        varchar2(8 char);
  p_timendw         varchar2(8 char);
  p_timstrtb        varchar2(8 char);
  p_timendb         varchar2(8 char);
  p_stampinst       varchar2(8 char);
  p_stampinen       varchar2(8 char);
  p_stampoutst      varchar2(8 char);
  p_stampouten      varchar2(8 char);
  p_timstotd        varchar2(8 char);
  p_timenotd        varchar2(8 char);
  p_timstotdb       varchar2(8 char);
  p_timenotdb       varchar2(8 char);
  p_timstotb        varchar2(8 char);
  p_timenotb        varchar2(8 char);
  p_timstota        varchar2(8 char);
  p_timenota        varchar2(8 char);
  p_qtywkfull       number;

  json_params       json_object_t;
  json_codshift     json_object_t;
  isInsertReport    boolean := false;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

end HRAL16E;

/
