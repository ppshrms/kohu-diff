--------------------------------------------------------
--  DDL for Package HRTR6CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6CE" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    json_params             json_object_t;
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal               varchar2(4 char);
    p_year                  thistrnn.dteyear%type;
    p_codcomp               thistrnn.codcomp%type;
    p_codcours              thistrnn.codcours%type;
    p_numclseq              thistrnn.numclseq%type;
    p_codempid              thistrnn.codempid%type;
    p_codpos                thistrnn.codpos%type;
    p_codeval               ttrimph.codeval%type;
    p_new_docform           tintvewd.codform%type;
    p_codform               tintvewd.codform%type;
    p_save_codempid         thistrnn.codempid%type;
    p_save_year             thistrnn.dteyear%type;
    p_save_numclseq         thistrnn.numclseq%type;
    p_save_codcours         thistrnn.codcours%type;
    p_save_codeval          ttrimph.codeval%type;
    p_save_dteeval          ttrimph.dteeval%type;
    p_save_codform          ttrimph.codform%type;
    p_save_flgperform       ttrimph.flgeval%type;
    p_save_comment_sugges   ttrimph.descommt%type;
    save_table_form_obj            json_object_t;
    save_ttrimpi_obj               json_object_t;
    save_thistrnp_obj              json_object_t;
    save_ttrimps_obj              json_object_t;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure get_index_table(json_str_input in clob,json_str_output out clob);
    procedure gen_index_table(json_str_output out clob);
    procedure get_detail_form(json_str_input in clob,json_str_output out clob);
    procedure gen_detail_form1(json_str_output out clob);
    procedure gen_detail_form2(json_str_output out clob);
    procedure get_detail_plan(json_str_input in clob,json_str_output out clob);
    procedure gen_detail_plan(json_str_output out clob);
    procedure get_detail_comment_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail_comment_detail(json_str_output out clob);
    procedure get_detail_comment_table(json_str_input in clob,json_str_output out clob);
    procedure gen_detail_comment_table(json_str_output out clob);
    function get_codform_ttrimph(p_codempid in varchar2,p_year in varchar2,p_codcours in varchar2,p_numclseq in varchar2) return varchar2;
    procedure get_detail_from_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail_from_detail(json_str_output out clob);
    procedure get_new_codform(json_str_input in clob,json_str_output out clob);
    procedure gen_new_codform(json_str_output out clob);
    procedure save_all (json_str_input in clob,json_str_output out clob);
    procedure save_ttrimph (save_table_form_obj in json_object_t, param_msg_error out varchar2);
    procedure save_ttrimpi (save_ttrimpi_obj in json_object_t, param_msg_error out varchar2);
    procedure save_thistrnp (save_thistrnp_obj in json_object_t, param_msg_error out varchar2);
    procedure save_ttrimps (save_ttrimps_obj in json_object_t, param_msg_error out varchar2);
    procedure delete_index (json_str_input in clob, json_str_output out clob);
    procedure get_eval_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_eval_detail(json_str_output out clob);
    procedure get_position (json_str_input in clob, json_str_output out clob) ;

end HRTR6CE;


/
