--------------------------------------------------------
--  DDL for Package HRBF26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF26E" as 
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

  p_codcomp                 tcenter.codcomp%type;
  p_codempid                temploy1.codempid%type;
  p_year                    varchar2(10 char);

  p_numvcher                tclnsinf.numvcher%type;
  p_codrel                  tclnsinf.codrel%type;
  p_dtecrest                tclnsinf.dtecrest%type;
  p_typamt                  tclnsinf.typamt%type;
  p_typrel                  tclnsinf.codrel%type;
  p_amtexp                  tclnsinf.amtexp%type;
  p_dtereq                  date;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index_table(json_str_input in clob, json_str_output out clob);
  procedure get_index_header(json_str_input in clob, json_str_output out clob);
  procedure get_amount(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure insert_log(v_fldedit in varchar2, v_desold in varchar2, v_desnew in varchar2,
                       v_codempid in varchar2,v_dteyre in varchar2,v_typamt in varchar2, v_typrelate  in varchar2);
end hrbf26e;

/
