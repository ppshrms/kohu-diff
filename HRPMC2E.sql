--------------------------------------------------------
--  DDL for Package HRPMC2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC2E" is
-- last update: 03/11/2022 18:17

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

  p_codempid_query          varchar2(4000 char);
  param_numreqst            varchar2(4000 char);
  param_codpos              varchar2(4000 char);
  parameter_groupid         varchar2(100);
  parameter_year            number;
  parameter_month           number;
  parameter_running         varchar2(100);
  ---personal tab---
  personal_codempid           varchar2(4000 char);
  personal_image              varchar2(4000 char);
  personal_signature          varchar2(4000 char);
  personal_codtitle           varchar2(4000 char);
  personal_namfirste          varchar2(4000 char);
  personal_namfirstt          varchar2(4000 char);
  personal_namfirst3          varchar2(4000 char);
  personal_namfirst4          varchar2(4000 char);
  personal_namfirst5          varchar2(4000 char);
  personal_namlaste           varchar2(4000 char);
  personal_namlastt           varchar2(4000 char);
  personal_namlast3           varchar2(4000 char);
  personal_namlast4           varchar2(4000 char);
  personal_namlast5           varchar2(4000 char);
  personal_nickname           varchar2(4000 char);
  personal_nicknamt           varchar2(4000 char);
  personal_nicknam3           varchar2(4000 char);
  personal_nicknam4           varchar2(4000 char);
  personal_nicknam5           varchar2(4000 char);
  personal_numtelec           varchar2(4000 char);
  personal_nummobile          varchar2(4000 char);
  personal_lineid             varchar2(4000 char);
  personal_numoffid           varchar2(4000 char);
  personal_dteoffid           date;
  personal_adrissue           varchar2(4000 char);
  personal_codprovi           varchar2(4000 char);
  personal_codclnsc           varchar2(4000 char);
  personal_numpasid           varchar2(4000 char);
  personal_dtepasid           date;
  personal_numvisa            varchar2(4000 char);
  personal_dtevisaexp         date;
  personal_numlicid           varchar2(4000 char);
  personal_dtelicid           date;
  personal_dteempdb           date;
  personal_coddomcl           varchar2(4000 char);
  personal_codsex             varchar2(4000 char);
  personal_weight             varchar2(4000 char);
  personal_high               varchar2(4000 char);
  personal_codblood           varchar2(4000 char);
  personal_codorgin           varchar2(4000 char);
  personal_codnatnl           varchar2(4000 char);
  personal_codrelgn           varchar2(4000 char);
  personal_stamarry           varchar2(4000 char);
  personal_stamilit           varchar2(4000 char);
  personal_numprmid           varchar2(4000 char);
  personal_dteprmst           date;
  personal_dteprmen           date;
  personal_numappl            varchar2(4000 char);
  personal_dteretire          date;

  ---address tab---
  address_adrrege             varchar2(4000 char);
  address_adrregt             varchar2(4000 char);
  address_adrreg3             varchar2(4000 char);
  address_adrreg4             varchar2(4000 char);
  address_adrreg5             varchar2(4000 char);
  address_codprovr            varchar2(4000 char);
  address_coddistr            varchar2(4000 char);
  address_codsubdistr         varchar2(4000 char);
  address_codcntyr            varchar2(4000 char);
  address_codpostr            varchar2(4000 char);
  address_adrconte            varchar2(4000 char);
  address_adrcontt            varchar2(4000 char);
  address_adrcont3            varchar2(4000 char);
  address_adrcont4            varchar2(4000 char);
  address_adrcont5            varchar2(4000 char);
  address_codprovc            varchar2(4000 char);
  address_coddistc            varchar2(4000 char);
  address_codsubdistc         varchar2(4000 char);
  address_codcntyc            varchar2(4000 char);
  address_codpostc            varchar2(4000 char);

  ---work tab---
  work_dteempmt               date;
  work_staemp                 varchar2(4000 char);
  work_dteeffex               date;
  work_codcomp                varchar2(4000 char);
  work_codpos                 varchar2(4000 char);
  work_dteefpos               date;
  work_numlvl                 varchar2(4000 char);
  work_dteeflvl               date;
  work_codbrlc                varchar2(4000 char);
  work_codempmt               varchar2(4000 char);
  work_typpayroll             varchar2(4000 char);
  work_typemp                 varchar2(4000 char);
  work_codcalen               varchar2(4000 char);
  work_flgatten               varchar2(4000 char);
  work_codjob                 varchar2(4000 char);
  work_jobgrade               varchar2(4000 char);
  work_dteefstep              date;
  work_codgrpgl               varchar2(4000 char);
  work_stadisb                varchar2(4000 char);
  work_numdisab               varchar2(4000 char);
  work_dtedisb                date;
  work_dtedisen               date;
  work_typdisp                varchar2(4000 char);
  work_desdisp                varchar2(4000 char);
  work_qtyduepr               number;
  work_dteduepr               date;
  work_yredatrq               number;
  work_mthdatrq               number;
  work_qtydatrq               varchar2(4000 char);
  work_dteoccup               date;
  work_numtelof               varchar2(4000 char);
  work_email                  varchar2(4000 char);
  work_numreqst               varchar2(4000 char);--varchar2(4000 char);
  work_ocodempid              varchar2(4000 char);
  work_dtereemp               date;
  work_qtyredue               number;
  work_dteredue               date;
  work_flgpdpa                temploy1.flgpdpa%type;
  work_dtepdpa                date;

  ---travel tab---
  travel_typtrav              varchar2(4000 char);
  travel_carlicen             varchar2(4000 char);
  travel_typfuel              varchar2(4000 char);
  travel_qtylength            varchar2(4000 char);
  travel_codbusno             varchar2(4000 char);
  travel_codbusrt             varchar2(4000 char);

  ---income tab---
  income_codcurr          varchar2(4000 char);
--  income_afpro            number;
  income_amtothr          number;
  income_amtday           number;
  income_sumincom         number;
  TYPE income_rec IS RECORD (
    amtincom    number,
    amtmax      number);
  type income_type is table of income_rec index by binary_integer;
    income_table    income_type;

  ---tax detail tab---
  tax_detail_codempid          varchar2(4000 char);
  tax_detail_numtaxid          varchar2(4000 char);
  tax_detail_numsaid           varchar2(4000 char);
  tax_detail_flgtax            varchar2(4000 char);
  tax_detail_typtax            varchar2(4000 char);
  tax_detail_typincom          varchar2(4000 char);
  tax_detail_dteyrrelf         number;
  tax_detail_dteyrrelt         number;
  tax_detail_amtrelas          varchar2(4000 char);
  tax_detail_amttaxrel         varchar2(4000 char);
  tax_detail_codbank           varchar2(4000 char);
  tax_detail_numbank           varchar2(4000 char);
  tax_detail_numbrnch          varchar2(4000 char);
  tax_detail_amtbank           varchar2(4000 char);
  tax_detail_amttranb          varchar2(4000 char);
  tax_detail_codbank2          varchar2(4000 char);
  tax_detail_numbank2          varchar2(4000 char);
  tax_detail_numbrnch2         varchar2(4000 char);
  tax_detail_qtychldb          temploy3.qtychldb%type;
  tax_detail_qtychlda          temploy3.qtychlda%type;
  tax_detail_qtychldd          temploy3.qtychldd%type;
  tax_detail_qtychldi          temploy3.qtychldi%type;
  tax_detail_frsmemb           date;
  tax_detail_flgslip           temploy3.flgslip%type;

  over_income_dtebf            date;
  over_income_amtincbf         varchar2(4000 char);
  over_income_amttaxbf         varchar2(4000 char);
  over_income_amtpf            varchar2(4000 char);
  over_income_amtsaid          varchar2(4000 char);

  TYPE tax_rec IS RECORD (
    coddeduct   tdeductd.coddeduct%type,
    amtdeduct   number);
  TYPE tax_type IS TABLE OF tax_rec
    INDEX BY BINARY_INTEGER;
  tax_exemption           tax_type;
  tax_allowance           tax_type;
  others_deduct           tax_type;

  ---spouse tab---
  sp_over_income_numtaxid         varchar2(4000 char);
  sp_over_income_dtebfsp          date;
  sp_over_income_amtincsp         varchar2(4000 char);
  sp_over_income_amttaxsp         varchar2(4000 char);
  sp_over_income_amtsasp          varchar2(4000 char);
  sp_over_income_amtpfsp          varchar2(4000 char);

  p_flg_warn                      varchar2(1);

  sp_tax_exemption          tax_type;
  sp_tax_deduct             tax_type;
  sp_others_deduct          tax_type;

  ---hisname tab---
  type hisname_type is table of thisname%ROWTYPE index by binary_integer;
    hisname_tab    hisname_type;
  type flg_del_hisname_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_hisname   flg_del_hisname_type;

  ---document tab---
  type document_type is table of tappldoc%ROWTYPE index by binary_integer;
    document_tab    document_type;
  type flg_del_doc_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_doc   flg_del_doc_type;

  ---p cal amt temploy3---
  p_amtincom1		  varchar2(4000 char);
  p_amtincom2		  varchar2(4000 char);
  p_amtincom3		  varchar2(4000 char);
  p_amtincom4		  varchar2(4000 char);
  p_amtincom5		  varchar2(4000 char);
  p_amtincom6		  varchar2(4000 char);
  p_amtincom7		  varchar2(4000 char);
  p_amtincom8		  varchar2(4000 char);
  p_amtincom9		  varchar2(4000 char);
  p_amtincom10	  varchar2(4000 char);
  p_amtothr 		  varchar2(4000 char);
  p_amtday 		    varchar2(4000 char);
  p_amtincbf 		  varchar2(4000 char);
  p_amttaxbf 		  varchar2(4000 char);
  p_amtpf 		    varchar2(4000 char);
  p_amtsaid 		  varchar2(4000 char);
  p_amtincsp 		  varchar2(4000 char);
  p_amttaxsp 		  varchar2(4000 char);
  p_amtpfsp 		  varchar2(4000 char);
  p_amtsasp 		  varchar2(4000 char);
  p_amtrelas  	  varchar2(4000 char);
  p_amttaxrel     varchar2(4000 char);

  ---p others---
  p_o_staemp		  varchar2(4000 char);

  --params smart card--
  param_numoffid            varchar2(4000 char);
  param_desc_codtitle       varchar2(4000 char);
  param_namfirstt           varchar2(4000 char);
  param_namlastt            varchar2(4000 char);
  param_namfirste           varchar2(4000 char);
  param_namlaste            varchar2(4000 char);
  param_dteempdb            varchar2(4000 char);
  param_desc_codsex         varchar2(4000 char);
  param_number              varchar2(4000 char);
  param_moo                 varchar2(4000 char);
  param_trok                varchar2(4000 char);
  param_soi                 varchar2(4000 char);
  param_road                varchar2(4000 char);
  param_desc_subdist        varchar2(4000 char);
  param_desc_dist           varchar2(4000 char);
  param_desc_province       varchar2(4000 char);
  param_adrissue            varchar2(4000 char);
  param_dteoffid            varchar2(4000 char);
  procedure get_blacklist_data(json_str_input in clob, json_str_output out clob);
  procedure gen_blacklist_data(json_str_input in clob, json_str_output out clob);

  procedure get_personal(json_str_input in clob, json_str_output out clob);
  procedure gen_personal(json_str_output out clob);

  procedure get_address(json_str_input in clob, json_str_output out clob);
  procedure gen_address(json_str_output out clob);

  procedure get_work(json_str_input in clob, json_str_output out clob);
  procedure gen_work(json_str_output out clob);

  procedure get_travel(json_str_input in clob, json_str_output out clob);
  procedure gen_travel(json_str_output out clob);

  procedure get_income_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_income_detail(json_str_output out clob);

  procedure get_income_table(json_str_input in clob, json_str_output out clob);
  procedure gen_income_table(json_str_output out clob);

  procedure get_tax_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tax_detail(json_str_output out clob);

  procedure get_over_income(json_str_input in clob, json_str_output out clob);
  procedure gen_over_income(json_str_output out clob);

  procedure get_tax_exemption(json_str_input in clob, json_str_output out clob);
  procedure gen_tax_exemption(json_str_output out clob);

  procedure get_tax_allowance(json_str_input in clob, json_str_output out clob);
  procedure gen_tax_allowance(json_str_output out clob);

  procedure get_others_deduct(json_str_input in clob, json_str_output out clob);
  procedure gen_others_deduct(json_str_output out clob);

  procedure get_sp_over_income(json_str_input in clob, json_str_output out clob);
  procedure gen_sp_over_income(json_str_output out clob);

  procedure get_sp_tax_exemption(json_str_input in clob, json_str_output out clob);
  procedure gen_sp_tax_exemption(json_str_output out clob);

  procedure get_sp_tax_deduct(json_str_input in clob, json_str_output out clob);
  procedure gen_sp_tax_deduct(json_str_output out clob);

  procedure get_sp_others_deduct(json_str_input in clob, json_str_output out clob);
  procedure gen_sp_others_deduct(json_str_output out clob);

  procedure get_hisname(json_str_input in clob, json_str_output out clob);
  procedure gen_hisname(json_str_output out clob);

  procedure get_document(json_str_input in clob, json_str_output out clob);
  procedure gen_document(json_str_output out clob);
  procedure check_tab_document(json_str_input in clob, json_str_output out clob);

  procedure get_codpos_data(json_str_input in clob, json_str_output out clob);
  procedure get_wage_income_data(json_str_input in clob, json_str_output out clob);
  procedure get_head( p_codcomp in varchar2,
                      p_codpos in varchar2,
                      p_codcomph out varchar2,
                      p_codposh out varchar2,
                      p_codempidh out varchar2,
                      p_stapost out varchar2);

  procedure get_income_allowance(json_str_input in clob, json_str_output out clob);
  procedure gen_income_allowance(json_str_output out clob);

  procedure get_data_income(json_str_input in clob, json_str_output out clob);
  procedure gen_data_income(json_str_output out clob);

  procedure get_popup_change_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_change_detail(json_str_input in clob, json_str_output out clob);

  procedure get_map_smart_card(json_str_input in clob, json_str_output out clob);

  procedure get_default_value(json_str_input in clob, json_str_output out clob);
  procedure get_default_value_by_codcomp(json_str_input in clob, json_str_output out clob);

  procedure save_personal_tax(json_str_input in clob, json_str_output out clob);
  procedure delete_personal_tax(json_str_input in clob, json_str_output out clob);
  procedure update_filedoc( p_codempid  varchar2,
                            p_filedoc   varchar2,
                            p_namedoc   varchar2,
                            p_type_doc  varchar2,
                            p_coduser   varchar2,
                            p_numrefdoc in out varchar2);
  procedure get_msg_warning(json_str_input in clob, json_str_output out clob);
end HRPMC2E;

/
