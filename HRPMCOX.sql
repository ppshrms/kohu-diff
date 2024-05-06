--------------------------------------------------------
--  DDL for Package HRPMCOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMCOX" is

	global_v_coduser	        varchar2(100 char);
    global_v_codempid           varchar2(100 char);
	global_v_lang		        varchar2(10 char) := '102';
	param_msg_error		        varchar2(4000 char);
	global_v_zminlvl	        number;
	global_v_zwrklvl	        number;
	global_v_numlvlsalst	    number;
	global_v_numlvlsalen	    number;
	obj_data		            json_object_t;
	obj_row			            json_object_t;


    p_codcomp			        temploy1.codcomp%type;
    p_codempid_query			temploy1.codempid%type;
    p_dtestr			        temploy1.dteempmt%type;
    p_dteend			        temploy1.dteempmt%type;

    p_flglayout			        ttemcard.flglayout%type;
	p_codcard			        ttemcard.codcard%type;

    p_styletemp                 ttemcard.styletemp%type;
    p_namcard                   ttemcard.namcard%type;

    p_card                      json_object_t;
    p_listfield                 json_object_t;

	p_flg			            varchar2(10 char);
	p_template		            varchar2(100 char);
    p_flguse			        varchar2(100 char);
    p_flgstd			        varchar2(100 char);
    p_footer1			        varchar2(100 char);
    p_footer2			        varchar2(100 char);
    p_flgname			        varchar2(100 char);
    p_slogan			        varchar2(100 char);
    p_flgcomny			        varchar2(100 char);
    p_heighlogo			        varchar2(100 char);
    p_widlogo			        varchar2(100 char);
    p_namlogo			        varchar2(100 char);
    p_flgdata1			        varchar2(10 char);
    p_flgdata2			        varchar2(10 char);
    p_flgdata3			        varchar2(10 char);
--    p_codempid			        varchar2(100 char);
    v_zupdsal			        varchar2(10 char);
    --GenDataReport
    p_listsof_temploy           json_object_t;
    p_listsof_imagedata         json_object_t;
    p_listsof_template 	        json_object_t;

	procedure initial_value(json_str in clob);

	procedure check_getindex;    
	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure gen_index(json_str_output out clob);  

	procedure get_setlayout(json_str_input in clob, json_str_output out clob);
	procedure gen_setlayout(json_str_output out clob);

	procedure get_chooseformat(json_str_input in clob, json_str_output out clob);
	procedure gen_chooseformat(json_str_output out clob);

	procedure get_customtemplate(json_str_input in clob, json_str_output out clob);
	procedure gen_customtemplate(json_str_output out clob);

    procedure checkupdatetemcard_use(json_str_input in clob);
    procedure updatetemcard_use (json_str_input in clob,json_str_output out clob);

	procedure delete_template(json_str_input in clob,json_str_output out clob);

    function getDescData (p_columnname in varchar2) return varchar2;
    function getDescEmp (p_columnname in varchar2, p_codempid varchar2) return varchar2;

    procedure gen_listfield (p_flgdata1 in varchar2, p_flgdata2 in varchar2, p_flgdata3 in varchar2, obj_row in out json_object_t);

	procedure save_data(json_str_input in clob,json_str_output out clob);
	procedure check_save;

    procedure get_ttemcard_use (v_outobj out json_object_t);

    procedure init_datareport(json_str_input in clob);

    procedure get_datareport(json_str_input in clob,json_str_output out clob);

    procedure check_datareport(json_str_input in clob);

    procedure gen_datareport(json_str_output out clob);
    procedure gen_datareportHead(json_str_output out clob);

    procedure write_template_H1 (v_objdetail_template in json_object_t);

    procedure write_template_H2 (v_objdetail_template in json_object_t);

    procedure write_template_H3 (v_objdetail_template in json_object_t);

    procedure write_template_V1 (v_objdetail_template in json_object_t);

    procedure write_template_V2 (v_objdetail_template in json_object_t);

    procedure write_template_V3 (v_objdetail_template in json_object_t);

    function getcompybycodempid (v_codempid in varchar2, v_lang  in varchar2) return varchar2;

    function getempname (v_codempid in varchar2,v_flgname in varchar2 ,v_lang  in varchar2)  return varchar2;

    function serach_condition (v_codempid in varchar2,v_condition in varchar2,v_lang  in varchar2)return varchar2;

    function getpositionnamebycodempid (v_codempid in varchar2,v_lang  in varchar2) return varchar2;

    function getdepartmentbycodempid (v_codempid in varchar2,v_lang  in varchar2) return varchar2;

  end HRPMCOX;

/
