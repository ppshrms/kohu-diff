--------------------------------------------------------
--  DDL for Package HRES38X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES38X" is
-- last update: 09/07/2019 09:42
  param_msg_error       varchar2(4000 char);

  v_chken               varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear               number;
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  --
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  global_v_zyear            number := 0;
  global_v_zupdsal      varchar2(100 char);

  b_index_codempid      varchar2(4000 char);
  p_start               number;
  p_end                 number;
  p_limit               number;

  p_codempid            varchar2(4000 char);
  p_dteeffec            date;
  p_numseq              number;
  p_codcomp             varchar2(4000 char);
  p_numhmref            varchar2(4000 char);
  p_codform             varchar2(4000 char);
  p_codtrn              varchar2(4000 char);
  p_typmove             varchar2(4000 char);
  p_codmove             thismist.codmist%type;
  p_dateprint           tdocinf.dtehmref%type;
  p_type_move     tcodmove.codcodec%type;
  numYearReport             number;
  itemSelected		json_object_t;
	p_url		        varchar2(1000 char);
  --
  b_index_s_mth         varchar2(4000 char);
  b_index_e_mth         varchar2(4000 char);
  b_index_s_year        number;
  b_index_e_year        number;
  --
  ctrl_s_date           date;
  ctrl_e_date           date;
  --
  p_namimglet     tfmrefr.namimglet%type;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;
  --
  --
  v_view_codapp         varchar2(100 char);
  v_document_msg        clob;
  v_document_name       varchar2(4000 char);
  p_file_dir            varchar2(4000 char) := 'UTL_FILE_DIR';
  --
  type array_value is table of varchar2(100) index by binary_integer;
    declare_param_param     array_value;
    declare_param_value     array_value;
    declare_param_label     array_value;

    declare_param_fparam    array_value;
    declare_param_fdata     array_value;
    declare_param_flabel    array_value;

	declare_param_qty       number := 0;
	declare_param_numseq    number := 0;
	declare_param_numcol    number := 0;
	declare_param_maxcol    number := 0;

  ctrl_amtincadj        varchar2(100);
  ctrl_amtincadj1       varchar2(100);
  ctrl_amtincadj10      varchar2(100);
  ctrl_amtincadj2       varchar2(100);
  ctrl_amtincadj3       varchar2(100);
  ctrl_amtincadj4       varchar2(100);
  ctrl_amtincadj5       varchar2(100);
  ctrl_amtincadj6       varchar2(100);
  ctrl_amtincadj7       varchar2(100);
  ctrl_amtincadj8       varchar2(100);
  ctrl_amtincadj9       varchar2(100);
  ctrl_amtincom         varchar2(100);
  ctrl_amtincom1        varchar2(100);
  ctrl_amtincom10       varchar2(100);
  ctrl_amtincom2        varchar2(100);
  ctrl_amtincom3        varchar2(100);
  ctrl_amtincom4        varchar2(100);
  ctrl_amtincom5        varchar2(100);
  ctrl_amtincom6        varchar2(100);
  ctrl_amtincom7        varchar2(100);
  ctrl_amtincom8        varchar2(100);
  ctrl_amtincom9        varchar2(100);
  ctrl_amtincomo1       varchar2(100);
  ctrl_amtincomo10      varchar2(100);
  ctrl_amtincomo2       varchar2(100);
  ctrl_amtincomo3       varchar2(100);
  ctrl_amtincomo4       varchar2(100);
  ctrl_amtincomo5       varchar2(100);
  ctrl_amtincomo6       varchar2(100);
  ctrl_amtincomo7       varchar2(100);
  ctrl_amtincomo8       varchar2(100);
  ctrl_amtincomo9       varchar2(100);
  ctrl_codcurr          varchar2(100);
  ctrl_codincom1        varchar2(100);
  ctrl_codincom10       varchar2(100);
  ctrl_codincom2        varchar2(100);
  ctrl_codincom3        varchar2(100);
  ctrl_codincom4        varchar2(100);
  ctrl_codincom5        varchar2(100);
  ctrl_codincom6        varchar2(100);
  ctrl_codincom7        varchar2(100);
  ctrl_codincom8        varchar2(100);
  ctrl_codincom9        varchar2(100);
  ctrl_descpay1         varchar2(100);
  ctrl_descpay10        varchar2(100);
  ctrl_descpay2         varchar2(100);
  ctrl_descpay3         varchar2(100);
  ctrl_descpay4         varchar2(100);
  ctrl_descpay5         varchar2(100);
  ctrl_descpay6         varchar2(100);
  ctrl_descpay7         varchar2(100);
  ctrl_descpay8         varchar2(100);
  ctrl_descpay9         varchar2(100);
  ctrl_descurr          varchar2(100);
  ctrl_desunit1         varchar2(100);
  ctrl_desunit10        varchar2(100);
  ctrl_desunit2         varchar2(100);
  ctrl_desunit3         varchar2(100);
  ctrl_desunit4         varchar2(100);
  ctrl_desunit5         varchar2(100);
  ctrl_desunit6         varchar2(100);
  ctrl_desunit7         varchar2(100);
  ctrl_desunit8         varchar2(100);
  ctrl_desunit9         varchar2(100);
  ctrl_unitcal1         varchar2(100);
  ctrl_unitcal10        varchar2(100);
  ctrl_unitcal2         varchar2(100);
  ctrl_unitcal3         varchar2(100);
  ctrl_unitcal4         varchar2(100);
  ctrl_unitcal5         varchar2(100);
  ctrl_unitcal6         varchar2(100);
  ctrl_unitcal7         varchar2(100);
  ctrl_unitcal8         varchar2(100);
  ctrl_unitcal9         varchar2(100);

  procedure initial_value(json_str in clob);
  procedure initial_report (json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_document(json_str_input in clob, json_str_output out clob);
  procedure gen_document( json_str_output out clob);
end; -- Package spec

/
