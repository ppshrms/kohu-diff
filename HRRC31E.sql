--------------------------------------------------------
--  DDL for Package HRRC31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC31E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

-- get index parameter
    p_numreqst              tapphinv.numreqst%type;
    p_codcomp               treqest1.codcomp%type;
    p_codemprc              treqest1.codemprc%type;
    p_codpos                tapplinf.codpos1%type;
    p_dteappoist            tapplinf.dteappoist%type;
    p_dteappoien            tapplinf.dteappoien%type;
    p_numappl               tapplinf.numappl%type;
-- save index paramter
    p_codform               tfmrefr.codform%type;
    p_codexam               tappoinf.codexam%type;
    p_numapseq              tappoinf.numapseq%type;
    p_dteappoi              tappoinf.dteappoi%type;
    p_timappoi              tappoinf.timappoi%type;
    p_typappty              tappoinf.typappty%type;
    p_descnote              tappoinf.descnote%type;
    p_stapphinv             tappoinf.stapphinv%type;
    p_codasapl              tappoinf.codasapl%type;
    p_qtyfscore             tappoinf.qtyfscore%type;
    p_location              tappoinf.location%type;

    p_statappl              tapphinv.statappl%type;

    p_stasign               tapphinv.stasign%type; -- ฟิลด์ ‘ผลการคัดเลือก’
    p_qtyfscoresum          tapphinv.qtyfscoresum%type; -- ฟิลด์ ‘รวมคะแนนเต็ม’ (บรรทัด รวม)
    p_qtyscoresum           tapphinv.qtyscoresum%type; -- ฟิลด์ ‘รวมคะแนนที่ได้’ (บรรทัด รวม)

    -- report fparam
    global_v_codpswd	    varchar2(100 char);
    v_chken			          varchar2(10 char);

    obj_row			          json_object_t;
    obj_data		          json_object_t;

    p_flgappr_mail              varchar2(10 char);
    p_refdoc                    varchar2(1000 char);
    p_detail_obj	            json_object_t;
    p_resultfparam        json_object_t;

	  p_dateprint_date	        date;
    global_v_zyear		    number := 0;
	  p_dataSelectedObj	        json_object_t;
    type arr_1d is table of varchar2(4000 char) index by binary_integer;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_detail_sub(json_str_input in clob, json_str_output out clob);

    procedure get_interviewer(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_result(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure save_index2(json_str_input in clob, json_str_output out clob);

    procedure import_data_process(json_str_input in clob, json_str_output out clob);

    procedure get_probation_form(json_str_input in clob, json_str_output out clob);

    procedure get_html_message(json_str_input in clob, json_str_output out clob);

    procedure sendemail(json_str_input in clob, json_str_output out clob);

END HRRC31E;

/
