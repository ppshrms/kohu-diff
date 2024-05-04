--------------------------------------------------------
--  DDL for Package HRBF4QE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF4QE" AS
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    param_json          JSON_object_t;

    p_codcompy      tconttrav.codcompy%type;
    p_dteeffec      tconttrav.dteeffec%type;
    p_dteeffecquery tconttrav.dteeffec%type;
    p_codexp        tconttrav.codexp%type;
    p_codtravunit   tconttrav.codtravunit%type;    
    p_detail        JSON_object_t;

  isEdit                    boolean := true;
  isAdd                     boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';
  v_indexdteeffec           date;
  v_flgDisabled             boolean;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure gen_flg_status;

END HRBF4QE;

/
