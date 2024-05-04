--------------------------------------------------------
--  DDL for Package HRBFS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFS2X" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(100 char);

  p_codcompy                tobfdep.codcomp%type;
  p_dteyre                  tobfdep.dteyre%type;
  p_flginput                varchar2(1 char);
  -- graph
  p_codapp                  varchar2(10 char) := 'HRBFS2X';
  p_numseq                  number := 1;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(
    v_graph_title varchar2,
    v_item1 varchar2,
    v_item2 varchar2,
    v_item3 varchar2,
    v_item4 varchar2,
    v_item5 varchar2,
    v_item6 varchar2,
    v_item7 varchar2,
    v_item8 varchar2,
    v_item9 varchar2,
    v_item10 varchar2,
    v_item11 varchar2,
    v_item12 varchar2,
    v_item13 varchar2
  );
END HRBFS2X;


/
