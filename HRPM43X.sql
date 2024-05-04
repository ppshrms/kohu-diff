--------------------------------------------------------
--  DDL for Package HRPM43X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM43X" is

  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  param_msg_error       varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  obj_data              json_object_t;
  obj_main              json_object_t;
  obj_main1             json_object_t;
  obj_row               json_object_t;
  obj_row1              json_object_t;

  p_codcodec        varchar2(100 char);
  v_codcodec        varchar2(100 char);
  p_codcomp         varchar2(100 char);
  p_dtestr          date;
  p_dteend          date;
  p_staupd          varchar2(5);

  v_numseq          varchar2(100);
  v_codcomp         varchar2(100);
  v_codpos          varchar2(100);
  v_codjob          varchar2(100);
  v_numlvl          varchar2(100);
  v_codempmt        varchar2(100);
  v_typemp          varchar2(100);
  v_typpayroll      varchar2(100);
  v_codbrlc         varchar2(100);
  v_flgatten        varchar2(100);
  v_codcalen        varchar2(100);
  v_codpunsh        varchar2(100);
  v_codexemp        varchar2(100);
  v_jobgrade        varchar2(100);
  v_codgrpgl        varchar2(100);
  v_amtincom1       varchar2(100);
  v_amtincom2       varchar2(100);
  v_amtincom3       varchar2(100);
  v_amtincom4       varchar2(100);
  v_amtincom5       varchar2(100);
  v_amtincom6       varchar2(100);
  v_amtincom7       varchar2(100);
  v_amtincom8       varchar2(100);
  v_amtincom9       varchar2(100);
  v_amtincom10      varchar2(100);
  v_fullname        varchar2(200);
  v_codempid        varchar2(100);
  v_staupd          varchar2(100);
  v_desc_staupd     varchar2(100);
  v_dteeffec        date;
  v_dteend          date;
  v_dteend_str      varchar2(100);
  v_dtestr          date;
  v_stapost2        varchar2(100);
  v_approvno        number;
  v_dteappr         date;

  v_zupdsal   		varchar2(10 char);

  json_codempid_list            json_object_t;
  json_dteeffec_list            json_object_t;
  json_amtincom_all_list        json_object_t;
  json_amtincadj_all_list       json_object_t;
  json_amount_all_list          json_object_t;
  json_amtincom_day_all_list    json_object_t;
  json_amtincadj_day_all_list   json_object_t;
  json_amount_day_all_list      json_object_t;
  json_amtincom_hour_all_list   json_object_t;
  json_amtincadj_hour_all_list  json_object_t;
  json_amount_hour_all_list     json_object_t;
  json_amtded_list              json_object_t;
  json_amttotded_list           json_object_t;
  json_numseq_list              json_object_t;

  p_amtincom_all        varchar2(600);
  p_amtincadj_all       varchar2(600);
  p_amount_all          varchar2(600);
  p_amtincom_day_all    varchar2(600);
  p_amtincadj_day_all   varchar2(600);
  p_amount_day_all      varchar2(600);
  p_amtincom_hour_all   varchar2(600);
  p_amtincadj_hour_all  varchar2(600);
  p_amount_hour_all     varchar2(600);
  p_amtded              varchar(600);
  p_amttotded           varchar(600);
  p_numseq              varchar(600);

  p_codempid            ttprobat.codempid%type;
  p_dtecancel           date;
  p_dteend_report       varchar2(600);
  p_dtecancel_report    varchar2(600);
  p_numseq_report       varchar(600);
  p_desnote_report      varchar(600);
  global_v_chken		varchar2(10 char) := hcm_secur.get_v_chken;

  p_dteeffec_report     date;
  p_dteeffec            date;
  p_numhmref            varchar2(600);
  p_dtemistk            varchar2(600);
  p_refdoc              varchar2(600);
  p_desmist1            varchar2(600);

  p_codpunsh            varchar2(600);
  p_typpun              varchar2(600);
  p_dtestart_report     varchar2(600);
  p_remark              varchar2(600);
  p_flgexempt           varchar2(600);
  p_codexemp            varchar2(600);
  p_flgssm              varchar2(600);
  p_flgblist            varchar2(600);

  p_numprdst            varchar2(600);
  p_numprden            varchar2(600);
  p_codpay              varchar(600);

  p_numexemp            varchar(600);
  p_dteupd              varchar(600);
  p_coduser             varchar(600);

  p_stapost2            varchar(600);
  p_numreqst            varchar(600);
  p_flgduepr            varchar(600);
  p_countday            varchar(600);
  p_dteduepr            varchar(600);

  p_codcurr             varchar(600);

  p_index_rows          json_object_t;
  p_seqcancel           tsecpos.seqcancel%type;

  isInsertReport	    boolean := false;
  numYearReport         number;
  v_numseq_report		number := 0;

  p_codtrn              ttmovemt.codtrn%type;
  p_summary1            number;
  p_summary2            number;
  p_summary3            number;
  p_summary4            number;
  p_summary5            number;
  p_summary6            number;
  p_summary7            number;
  p_summary8            number;
  p_summary9            number;


  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure initial_value(json_str in clob);
  procedure check_getindex;
  procedure gen_data(json_str_output out clob);
  procedure initial_report(json_str in clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_report(json_str_output out clob);
  procedure clear_ttemprpt;
  procedure template1_main;
  procedure template1_table;
  procedure template2_main1;
  procedure template2_main2;
  procedure template2_main3;
  procedure template2_table;
  procedure template3_main;
  procedure template3_table;
  procedure template4_main;
  procedure template4_table;

  function get_flgduepr(p_flgduepr in varchar2) return varchar2;

end HRPM43X;

/
