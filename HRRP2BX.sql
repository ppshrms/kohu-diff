--------------------------------------------------------
--  DDL for Package HRRP2BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2BX" is
-- last update: 10/08/2020 13:45
    v_chken      varchar2(100 char);
    param_msg_error     varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen 	number;
    v_zupdsal             varchar2(4000 char);
    global_v_codpswd      varchar2(100 char);
    global_v_lang         varchar2(10 char) := '102';

    b_index_year        varchar2(4000 char);
    b_index_codcomp     varchar2(4000 char);
    b_index_codlinef    varchar2(4000 char);
    b_index_codcompy    varchar2(4000 char);
    b_index_dteappr     date;
    b_index_codappr     varchar2(4000 char);
    b_index_staappr     varchar2(4000 char);
    b_index_CODCOMPP    varchar2(4000 char);
    b_index_CODPOSPR    varchar2(4000 char);
    b_index_dtereq      date;
    b_index_codpos      varchar2(4000 char);
    b_index_month       varchar2(2 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_detail1(json_str_input in clob, json_str_output out clob);
  procedure gen_detail1(json_str_output out clob);
  procedure get_detail2(json_str_input in clob, json_str_output out clob);
  procedure gen_detail2(json_str_output out clob);
END; -- Package spec

/
