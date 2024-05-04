--------------------------------------------------------
--  DDL for Package HRSC07E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC07E" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_dteeffec                tsetpass.dteeffec%type;
  p_dteeffecOld             tsetpass.dteeffec%type;
  p_qtypassmax              tsetpass.qtypassmax%type;
  p_qtypassmin              tsetpass.qtypassmin%type;
  p_qtynumdigit             tsetpass.qtynumdigit%type;
  p_qtyspecail              tsetpass.qtyspecail%type;
  p_qtyalpbup               tsetpass.qtyalpbup%type;
  p_qtyalpblow              tsetpass.qtyalpblow%type;
  p_agepass                 tsetpass.agepass%type;
  p_qtymistake              tsetpass.qtymistake%type;
  p_qtynopass               tsetpass.qtynopass%type;
  p_qtyotp                  tsetpass.qtyotp%type;
  p_timeotp                 tsetpass.timeotp%type;
  p_alepass                 tsetpass.alepass%type;
  p_flgchang                tsetpass.flgchang%type := 'Y';
  p_timeunlock              tsetpass.timeunlock%type;

  isEdit                    boolean := false;
  isAdd                     boolean := false;
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;

end HRSC07E;

/
