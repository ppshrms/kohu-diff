--------------------------------------------------------
--  DDL for Package HRRC2PB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC2PB" is
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRRC2PB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRRC2PB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  p_max     number;

  p_codcomp                 tcenter.codcomp%type;
  p_numreqst                treqest1.numreqst%type;
  p_numreqen                treqest1.numreqst%type;
  p_data_import             json_object_t;
  p_data_sheet              json_object_t;

  p_addinfo                 json_object_t; --ข้อมูลเพิ่มเติม
  p_doc                     json_object_t; --ข้อมูลเอกสารส่วนตัว
  p_edu                     json_object_t; --ข้อมูลประวัติการศึกษา
  p_emppref                 json_object_t; --เป้าหมายในการทำงาน
  p_exp                     json_object_t; --ข้อมูลประสบการณ์การทำงาน
  p_info                    json_object_t; --ข้อมูลส่วนตัวของผู้สมัคร
  p_lng                     json_object_t; --ความสามารถทางด้านภาษา
  p_ref                     json_object_t; --บุคคลอ้างอิง
  p_rel                     json_object_t; --ข้อมูลญาติพี่น้อง
  p_spouse                  json_object_t; --ข้อมูลคู่สมรส
  p_train                   json_object_t; --ข้อมูลการฝึกอบรม

--  p_dtestrt                 date;
--  p_dteend                  date;
--  p_dteyrbug                tmanpwm.dteyrbug%TYPE;
--  p_dtemthbugstr            tmanpwm.dtemthbug%TYPE;
--  p_dtemthbugend            tmanpwm.dtemthbug%TYPE;
--  
  p_numappl                 tapplinf.numappl%type;
  v_count_tapplinf          number;
  global_v_numreqst         treqest1.numreqst%type;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure process_data (json_str_input in clob, json_str_output out clob);

  procedure insert_tapplinf(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_teducatn(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tapplwex(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_ttrainbf(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tapploth(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tapplfm(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tapplrel(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tapplref(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tlangabi(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_addinfo(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);
  procedure insert_tappldoc(obj_response in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number);

  procedure check_error(p_item in varchar2, p_line in number, p_numseq in out number,p_num_error_row in out number , p_table in varchar2, p_column in varchar2, p_type in varchar2, obj_response in out json_object_t);

end HRRC2PB;

/
