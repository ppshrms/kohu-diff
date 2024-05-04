--------------------------------------------------------
--  DDL for Package HRCO1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO1DE" AS 

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_roomno        tcodroom.roomno%type;
  p_roomname      tcodroom.roomname%type;
  p_roomnamt      tcodroom.roomnamt%type;
  p_roomnam3      tcodroom.roomnam3%type;
  p_roomnam4      tcodroom.roomnam4%type;
  p_roomnam5      tcodroom.roomnam5%type;
  p_floor         tcodroom.floor%type;
  p_building      tcodroom.building%type;
  p_remark        tcodroom.remark%type;
  p_accessori     tcodroom.accessori%type;
  p_qtypers       tcodroom.qtypers%type;
  p_status        tcodroom.status%type;
  p_codrespon1        tcodroom.codrespon1%type;
  p_namimgroom        tcodroom.namimgroom%type;
  p_codrespon2        tcodroom.codrespon2%type;

  json_param            json_object_t;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure delete_index(json_str_input in clob, json_str_output out clob);

END HRCO1DE;

/
