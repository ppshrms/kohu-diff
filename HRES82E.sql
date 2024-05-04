--------------------------------------------------------
--  DDL for Package HRES82E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES82E" is

  param_msg_error   varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lrunning varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  v_file            utl_file.file_type;
  v_file_name       varchar2 (4000 char);

  obj_row           json_object_t;
  json_long         varchar2(4000 char);
  b_index_codempid  temploy1.codempid%type;



  p_dtereq           tassetreq.dtereq%type;
  p_dteend           tassetreq.dteend%type;
  p_stabook           tassetreq.stabook%type;
  p_typasset         tassetreq.typasset%type;

  p_dtereserv       troomreq.dtereserv%type;
  p_roomno        tcodroom.roomno%type;
  p_timstrt         troomreq.timstrt%type;
  p_timend          troomreq.timend%type;
  p_seqno           troomreq.seqno%type;
  p_qtypers          troomreq.seqno%type;
  p_object          troomreq.object%type;
  p_remark          troomreq.remark%type;
  p_flgwarning      varchar2(2 char);

  b_sdate           varchar2(4000 char);
  b_amtintaccu      varchar2(4000 char);
  v_amtintaccu      varchar2(4000 char);
  v_amtinteccu      varchar2(4000 char);
  v_view_codapp     varchar2(100 char);
  global_v_codapp   varchar2(100 char);

  procedure initial_value(json_str in clob);



  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_popup(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure post_detail_save(json_str_input in clob, json_str_output out clob);
  procedure get_schedule(json_str_input in clob, json_str_output out clob);

  procedure check_index;

END;

/
