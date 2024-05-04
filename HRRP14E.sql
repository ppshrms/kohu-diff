--------------------------------------------------------
--  DDL for Package HRRP14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP14E" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  p_comgrp              varchar2(4000 char);
  p_codcompy            varchar2(4000 char);
  p_codlinef            varchar2(4000 char);
  p_dtetrial            date;

  procedure initial_value(json_str in clob);
  function get_codcompst(json_str_input in clob) return T_LOV;
end;

/
