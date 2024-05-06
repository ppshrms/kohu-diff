--------------------------------------------------------
--  DDL for Package HRPY5HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5HX" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          temploy1.coduser%type;
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  tempaprq.codapp%type := 'HRPY5HX';
  p_index_rows              varchar2(100 char);
  p_stamarry                varchar2(100 char);
  p_typtax                  varchar2(100 char);

  -- index
  p_codcomp                 tcenter.codcomp%type;
  p_codcompy                tcenter.codcompy%type;
  p_codempid                temploy1.codempid%type;
  p_typemp                  varchar2(100 char);
  p_staemp                  varchar2(100 char);

  -- detail
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;
  p_coddeduct               varchar2(100 char);
  --
  p_amtsalyr                number;
  p_amtproyr                number;
  p_amtsocyr                number;
  --
  -- declare value in package --
	v_max					            number := 0;
	v_amtexp			            number;
	v_maxexp			            number;
	v_amtdiff			            number;

  isInsertReport            boolean := false;
  json_index_rows           json_object_t;

  v_tab_numseq      number := 0;

  --
	TYPE codpay IS TABLE OF tinexinf.codpay%type INDEX BY BINARY_INTEGER;
		v_tab_codpay	codpay;
		v_tab_codtax	codpay;
	TYPE codeduct IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    dvalue_code	codeduct;
    evalue_code	codeduct;
    ovalue_code	codeduct;
	TYPE char1 IS TABLE OF VARCHAR2(2000 char) INDEX BY BINARY_INTEGER;
    v_text	char1;
  TYPE amtnet_array IS TABLE OF VARCHAR2(2000 char) INDEX BY BINARY_INTEGER;
    v_numseq_arr	amtnet_array;
    v_desproc_arr	amtnet_array;
    v_amtfml_arr	amtnet_array;

  function gtempded (v_empid 			varchar2,
                     v_codeduct 	varchar2,
                     v_type 			varchar2,
                     v_amtcode 		number,
                     p_amtsalyr 	number) return number;
  function  get_deduct(v_codeduct varchar2) return char;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_tab1 (json_str_output out clob);
  procedure gen_detail_tab2 (json_str_output out clob);
  procedure fetch_deductd (json_str_output out clob);
  procedure cal_amtnet (p_amtincom  in number,
                        p_amtsalyr  in number,
                        p_amtproyr	in number,
                        p_amtsocyr  in number,
                        p_amtnet	  out number,
                        p_numseq    out amtnet_array,
                        p_desproc   out amtnet_array,
                        p_amtfml    out amtnet_array);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_detail(obj_data in json_object_t);
  procedure insert_ttemprpt_detail_tab1(obj_data in json_object_t);
  procedure insert_ttemprpt_detail_tab2(obj_data in json_object_t);

end HRPY5HX;

/
