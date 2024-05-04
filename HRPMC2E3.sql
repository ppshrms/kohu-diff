--------------------------------------------------------
--  DDL for Package HRPMC2E3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC2E3" is
-- last update: 07/8/2018 11:40

  param_msg_error           varchar2(4000 char);
  param_flgwarn             varchar2(10 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  work_codcomp              varchar2(4000 char);

  p_codempid_query          varchar2(4000 char);

  --- spouse tab ---
--  spouse_codempid          tspouse.codempid%type;
  spouse_codempidsp        tspouse.codempidsp%type;
  spouse_namimgsp          tspouse.namimgsp%type;
  spouse_codtitle          tspouse.codtitle%type;
--  spouse_namfirst          tspouse.namfirst%type;
  spouse_namfirste         tspouse.namfirste%type;
  spouse_namfirstt         tspouse.namfirstt%type;
  spouse_namfirst3         tspouse.namfirst3%type;
  spouse_namfirst4         tspouse.namfirst4%type;
  spouse_namfirst5         tspouse.namfirst5%type;
  spouse_namlaste          tspouse.namlaste%type;
--  spouse_namlast           tspouse.namlast%type;
  spouse_namlastt          tspouse.namlastt%type;
  spouse_namlast3          tspouse.namlast3%type;
  spouse_namlast4          tspouse.namlast4%type;
  spouse_namlast5          tspouse.namlast5%type;
  spouse_numoffid          tspouse.numoffid%type;
  spouse_dtespbd           tspouse.dtespbd%type;
  spouse_stalife           tspouse.stalife%type;
  spouse_dtedthsp          tspouse.dtedthsp%type;
  spouse_staincom          tspouse.staincom%type;
  spouse_desnoffi          tspouse.desnoffi%type;
  spouse_codspocc          tspouse.codspocc%type;
  spouse_numfasp           tspouse.numfasp%type;
  spouse_nummosp           tspouse.nummosp%type;
  spouse_dtemarry          tspouse.dtemarry%type;
  spouse_codsppro          tspouse.codsppro%type;
  spouse_codspcty          tspouse.codspcty%type;
  spouse_desplreg          tspouse.desplreg%type;
  spouse_desnote           tspouse.desnote%type;
  spouse_filename          tspouse.filename%type;
  spouse_flg               varchar2(100 char);

  --- children tab ---
  type children_type is table of tchildrn%ROWTYPE index by binary_integer;
    children_tab    children_type;
  type flg_del_children_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_children   flg_del_children_type;

  --- father_mother tab ---
  famo_codempfa          tfamily.codempfa%type;
  famo_codtitlf          tfamily.codtitlf%type;
--  famo_namfstf           tfamily.namfstf%type;
  famo_namfstfe          tfamily.namfstfe%type;
  famo_namfstft          tfamily.namfstft%type;
  famo_namfstf3          tfamily.namfstf3%type;
  famo_namfstf4          tfamily.namfstf4%type;
  famo_namfstf5          tfamily.namfstf5%type;
--  famo_namlstf           tfamily.namlstf%type;
  famo_namlstfe          tfamily.namlstfe%type;
  famo_namlstft          tfamily.namlstft%type;
  famo_namlstf3          tfamily.namlstf3%type;
  famo_namlstf4          tfamily.namlstf4%type;
  famo_namlstf5          tfamily.namlstf5%type;
  famo_numofidf          tfamily.numofidf%type;
  famo_dtebdfa           tfamily.dtebdfa%type;
  famo_codfnatn          tfamily.codfnatn%type;
  famo_codfrelg          tfamily.codfrelg%type;
  famo_codfoccu          tfamily.codfoccu%type;
  famo_staliff           tfamily.staliff%type;
  famo_dtedeathf         tfamily.dtedeathf%type;
  famo_filenamf          tfamily.filenamf%type;
  famo_codempmo          tfamily.codempmo%type;
  famo_codtitlm          tfamily.codtitlm%type;
--  famo_namfstm           tfamily.namfstm%type;
  famo_namfstme          tfamily.namfstme%type;
  famo_namfstmt          tfamily.namfstmt%type;
  famo_namfstm3          tfamily.namfstm3%type;
  famo_namfstm4          tfamily.namfstm4%type;
  famo_namfstm5          tfamily.namfstm5%type;
--  famo_namlstm           tfamily.namlstm%type;
  famo_namlstme          tfamily.namlstme%type;
  famo_namlstmt          tfamily.namlstmt%type;
  famo_namlstm3          tfamily.namlstm3%type;
  famo_namlstm4          tfamily.namlstm4%type;
  famo_namlstm5          tfamily.namlstm5%type;
  famo_numofidm          tfamily.numofidm%type;
  famo_dtebdmo           tfamily.dtebdmo%type;
  famo_codmnatn          tfamily.codmnatn%type;
  famo_codmrelg          tfamily.codmrelg%type;
  famo_codmoccu          tfamily.codmoccu%type;
  famo_stalifm           tfamily.stalifm%type;
  famo_dtedeathm         tfamily.dtedeathm%type;
  famo_filenamm          tfamily.filenamm%type;
  famo_codtitlc          tfamily.codtitlc%type;
--  famo_namfstc           tfamily.namfstc%type;
  famo_namfstce          tfamily.namfstce%type;
  famo_namfstct          tfamily.namfstct%type;
  famo_namfstc3          tfamily.namfstc3%type;
  famo_namfstc4          tfamily.namfstc4%type;
  famo_namfstc5          tfamily.namfstc5%type;
--  famo_namlstc           tfamily.namlstc%type;
  famo_namlstce          tfamily.namlstce%type;
  famo_namlstct          tfamily.namlstct%type;
  famo_namlstc3          tfamily.namlstc3%type;
  famo_namlstc4          tfamily.namlstc4%type;
  famo_namlstc5          tfamily.namlstc5%type;
  famo_adrcont1          tfamily.adrcont1%type;
  famo_codpost           tfamily.codpost%type;
  famo_numtele           tfamily.numtele%type;
  famo_numfax            tfamily.numfax%type;
  famo_email             tfamily.email%type;
  famo_desrelat          tfamily.desrelat%type;
  famo_flg               varchar2(100 char);

  --- relatives tab ---
  type relatives_type is table of trelatives%ROWTYPE index by binary_integer;
    relatives_tab    relatives_type;
  type flg_del_relatives_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_relatives   flg_del_relatives_type;

  procedure get_spouse(json_str_input in clob, json_str_output out clob);
  procedure gen_spouse(json_str_output out clob);

  procedure get_children(json_str_input in clob, json_str_output out clob);
  procedure gen_children(json_str_output out clob);
  procedure get_sta_submit_chi(json_str_input in clob, json_str_output out clob);

  procedure get_father_mother(json_str_input in clob, json_str_output out clob);
  procedure gen_father_mother(json_str_output out clob);

  procedure get_relatives(json_str_input in clob, json_str_output out clob);
  procedure gen_relatives(json_str_output out clob);

  procedure get_emp_detail(json_str_input in clob, json_str_output out clob);

  procedure get_popup_change_family(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_change_family(json_str_input in clob, json_str_output out clob);

  procedure save_family(json_str_input in clob, json_str_output out clob);

end HRPMC2E3;

/
