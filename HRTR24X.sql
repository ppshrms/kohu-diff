--------------------------------------------------------
--  DDL for Package HRTR24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR24X" is
    -- 20/01/2020
      param_msg_error         varchar2(4000 char);
      global_v_coduser        varchar2(100 char);
      global_v_codempid       varchar2(100 char);
      global_v_lang           varchar2(10 char) := '102';

      global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
      global_chken            varchar2(100 char);
      global_v_zminlvl  	    number;
      global_v_zwrklvl  	    number;
      global_v_numlvlsalst 	  number;
      global_v_numlvlsalen 	  number;
      v_zupdsal   		        varchar2(4 char);

      json_codinst            json;
      p_codapp                varchar2(20)  := 'HRTR24X';
      p_comgrp                tcompgrp.codcodec%type;
      p_codcomp               tcenter.codcomp%type;
      p_staemp                tlistval.list_value%type;
      p_codrep                trepdsph.codrep%type;
      p_codinst               tinstruc.codinst%type;
      p_stainst               varchar2(1  char);
      p_codempid              varchar2(10 char);
      p_showimg               varchar2(5);
      p_table_selected        treport.codtable%type;
      isInsertReport          boolean := false;

      procedure initial_value(json_str_input in clob);
      procedure get_codrep_detail(json_str_input in clob,json_str_output out clob);
      procedure get_table(json_str_input in clob,json_str_output out clob);
      procedure get_list_fields(json_str_input in clob,json_str_output out clob);
      procedure get_format_fields(json_str_input in clob,json_str_output out clob);
      procedure gen_format_fields (json_str_output out clob);
      procedure gen_style_column (v_objrow in json, v_img varchar2);
      procedure get_tab1_detail(json_str_input in clob, json_str_output out clob);
      procedure gen_tab1_detail(json_str_output out clob);
      procedure get_tab2_detail(json_str_input in clob, json_str_output out clob);
      procedure gen_tab2_detail(json_str_output out clob);
      procedure get_tab3_detail(json_str_input in clob, json_str_output out clob);
      procedure gen_tab3_detail(json_str_output out clob);
      procedure get_tab4_detail(json_str_input in clob, json_str_output out clob);
      procedure gen_tab4_detail(json_str_output out clob);
      procedure insert_trepdsph(p_r_trepdsph trepdsph%rowtype);
      function get_codempid_bycodinst(p_codinst varchar2) return varchar2;
      function get_tinstruc_stainst(p_codinst varchar2) return varchar2;
      procedure delete_codrep (json_str_input in clob, json_str_output out clob);

      procedure gen_report(json_str_input in clob, json_str_output out clob);
      procedure clear_ttemprpt;
      procedure insert_ttemprpt(obj_data in json);

      function  get_item_property (p_table in varchar2,p_field  in varchar2) return varchar2;
end hrtr24x;

/
