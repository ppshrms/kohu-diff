--------------------------------------------------------
--  DDL for Package HRCO01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO01E" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codcompy                tcompny.codcompy%type;
  p_namcome                 tcompny.namcome%type;
  p_namcomt                 tcompny.namcomt%type;
  p_namcom3                 tcompny.namcom3%type;
  p_namcom4                 tcompny.namcom4%type;
  p_namcom5                 tcompny.namcom5%type;
  p_namste                  tcompny.namste%type;
  p_namstt                  tcompny.namstt%type;
  p_namst3                  tcompny.namst3%type;
  p_namst4                  tcompny.namst4%type;
  p_namst5                  tcompny.namst5%type;
  p_adrcome                 tcompny.adrcome%type;
  p_adrcomt                 tcompny.adrcomt%type;
  p_adrcom3                 tcompny.adrcom3%type;
  p_adrcom4                 tcompny.adrcom4%type;
  p_adrcom5                 tcompny.adrcom5%type;
  p_numtele                 tcompny.numtele%type;
  p_numfax                  tcompny.numfax%type;
  p_numcotax                tcompny.numcotax%type;
  p_descomp                 tcompny.descomp%type;
  p_numacsoc                tcompny.numacsoc%type;
  p_zipcode                 tcompny.zipcode%type;
  p_email                   tcompny.email%type;
  p_website                 tcompny.website%type;
  p_comimage                tcompny.comimage%type;
  p_namimgcom               tcompny.namimgcom%type;
  p_namimgmap               tcompny.namimgmap%type;
  p_addrnoe                 tcompny.addrnoe%type;
  p_addrnot                 tcompny.addrnot%type;
  p_addrno3                 tcompny.addrno3%type;
  p_addrno4                 tcompny.addrno4%type;
  p_addrno5                 tcompny.addrno5%type;
  p_soie                    tcompny.soie%type;
  p_soit                    tcompny.soit%type;
  p_soi3                    tcompny.soi3%type;
  p_soi4                    tcompny.soi4%type;
  p_soi5                    tcompny.soi5%type;
  p_mooe                    tcompny.mooe%type;
  p_moot                    tcompny.moot%type;
  p_moo3                    tcompny.moo3%type;
  p_moo4                    tcompny.moo4%type;
  p_moo5                    tcompny.moo5%type;
  p_roade                   tcompny.roade%type;
  p_roadt                   tcompny.roadt%type;
  p_road3                   tcompny.road3%type;
  p_road4                   tcompny.road4%type;
  p_road5                   tcompny.road5%type;
  p_villagee                tcompny.villagee%type;
  p_villaget                tcompny.villaget%type;
  p_village3                tcompny.village3%type;
  p_village4                tcompny.village4%type;
  p_village5                tcompny.village5%type;
  p_codsubdist              tcompny.codsubdist%type;
  p_coddist                 tcompny.coddist%type;
  p_codprovr                tcompny.codprovr%type;
  p_numacdsd                tcompny.numacdsd%type;
--  p_numcotax13              tcompny.numcotax13%type;
  p_buildinge               tcompny.buildinge%type;
  p_buildingt               tcompny.buildingt%type;
  p_building3               tcompny.building3%type;
  p_building4               tcompny.building4%type;
  p_building5               tcompny.building5%type;
  p_roomnoe                 tcompny.roomnoe%type;
  p_roomnot                 tcompny.roomnot%type;
  p_roomno3                 tcompny.roomno3%type;
  p_roomno4                 tcompny.roomno4%type;
  p_roomno5                 tcompny.roomno5%type;
  p_floore                  tcompny.floore%type;
  p_floort                  tcompny.floort%type;
  p_floor3                  tcompny.floor3%type;
  p_floor4                  tcompny.floor4%type;
  p_floor5                  tcompny.floor5%type;
  p_namimgcover             tcompny.namimgcover%type;
  p_welcomemsge             tcompny.welcomemsge%type;
  p_welcomemsgt             tcompny.welcomemsgt%type;
  p_welcomemsg3             tcompny.welcomemsg3%type;
  p_welcomemsg4             tcompny.welcomemsg4%type;
  p_welcomemsg5             tcompny.welcomemsg5%type;
  p_typbusiness             tcompny.typbusiness%type;
  p_dtecreate               tcompny.dtecreate%type;
  p_codcreate               tcompny.codcreate%type;
  p_dteupd                  tcompny.dteupd%type;
  p_coduser                 tcompny.coduser%type;
  p_ageretrf                tcompny.ageretrf%type;
  p_ageretrm                tcompny.ageretrm%type;

  p_contmsge                tcompny.contmsge%type;
  p_contmsgt                tcompny.contmsgt%type;
  p_contmsg3                tcompny.contmsg3%type;
  p_contmsg4                tcompny.contmsg4%type;
  p_contmsg5                tcompny.contmsg5%type;
  p_compgrp                 tcompny.compgrp%type;

  p_dteeffec                TPDPAITEM.dteeffec%type;
  p_dteeffec_tmp            TPDPAITEM.dteeffec%type;
  p_numseq                  TPDPAITEM.NUMITEM%type;
  p_flgChkDteeff            boolean;
  p_flgTab3NotEdit          boolean;
  p_flgAfterSave            boolean := false;
  p_isAfterSave             varchar2(10 char) := '';
  p_codapp                  varchar2(10 char) := 'HRCO01E';
  p_errorno                 varchar2(10 char);
  p_flgAdd                  boolean := false;
  isInsertReport            boolean := false;
  param_json                json_object_t;
  p_namimgmobi              tcompny.namimgmobi%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_PDPA (json_str_input in clob,json_str_output out clob);
  procedure popupPdpa (json_str_input in clob,json_str_output out clob);
  procedure list_pdpa (json_str_input in clob,json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure process_dteretire(json_str_input in clob, json_str_output out clob);
  function get_policy(v_codcompy in varchar2) return json_object_t ;

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

END HRCO01E;

/
