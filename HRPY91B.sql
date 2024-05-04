--------------------------------------------------------
--  DDL for Package HRPY91B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY91B" as
    param_msg_error       varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(10 char);
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    global_v_chken        varchar2(4000 char);
    global_v_form         varchar2(4000 char) := 'HRPY91B';
    global_v_zyear        number := 0;
    v_zupdsal     		    varchar2(4 char);

    global_v_batch_codapp     varchar2(100 char)  := 'HRPY91B';
    global_v_batch_codalw     varchar2(100 char)  := 'HRPY91B';
    global_v_batch_dtestrt    date;
    global_v_batch_flgproc    varchar2(1 char)    := 'N';
    global_v_batch_qtyproc    number              := 0;
    global_v_batch_qtyerror   number              := 0;
    global_v_batch_filename   varchar2(500 char);
    global_v_batch_pathfile   varchar2(2000 char);
    --
    p_file_dir            varchar2(4000 char) := 'UTL_FILE_DIR';
    p_file_path           varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
    --
    p_dteyrepay           number;
    p_codcomp             tcenter.codcomp%type;
    p_codempid_query      temploy1.codempid%type;
    p_typpayroll          temploy1.typpayroll%type;
    --
    b_index_delimiter     varchar2(4000 char);
    p_sumrec              number := 0;
    -- declare var --
    p_var_max					    number := 0;
    p_var_amtexp			    number;
    p_var_maxexp			    number;
    p_var_amtdiff			    number;
    -- temploy1 global --
    p_temp_codempid       varchar2(4000 char);
    p_temp_stamarry       varchar2(4000 char);
    p_temp_typtax         varchar2(4000 char);
    
    index_codcompy        tcompny.codcompy%type;
    
    TYPE codeduct IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      p_dvalue_code	  codeduct;
      p_evalue_code	  codeduct;
      p_ovalue_code	  codeduct;
    type char1 is table of varchar2(4000) index by binary_integer;
      p_var_item		  char1;
      p_var_fldtype	  char1;
    type num1 is table of number index by binary_integer;
      p_var_numseq		num1;
      p_var_fldlength	num1;
      p_var_fldscale	num1;
    TYPE char2 IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
      v_text	char2;

    procedure initial_value (json_str_input in clob);
    procedure check_index;
    procedure get_process_batch(json_str_input in clob, json_str_output out clob);
    procedure gen_data_batch(p_exist out boolean, p_secur	out boolean, p_runseq in varchar);
--    procedure get_detail_choose(json_str_input in clob, json_str_output out clob);
    procedure exec_ttaxmd(json_str_input in clob,json_str_output out clob);
    procedure exec_ttaxmedia(json_str_input in clob,json_str_output out clob);
    procedure save_ttaxmedia(json_str_input in clob, json_str_output out clob);

    function check_index_batchtask(json_str_input clob) return varchar2;
end hrpy91b;

/
