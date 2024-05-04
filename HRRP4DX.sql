--------------------------------------------------------
--  DDL for Package HRRP4DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP4DX" is
-- last update: 11/08/2020 14:00
  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid	        VARCHAR2(100 CHAR);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  --block b_index
  b_index_codcomp    varchar2(4000 char);
  b_index_codpos     varchar2(4000 char);
  b_index_dteyear    varchar2(4000 char);
  b_index_numtime    varchar2(4000 char);
  b_index_typerep    varchar2(4000 char);  --แสดงข้อมูลตาม (1-ตามลำดับ , 2-ตามสถานะ)
  b_index_stasuccr   varchar2(4000 char);  --สถานะ
  --
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

END; -- Package spec

/
