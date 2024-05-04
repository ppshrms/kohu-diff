--------------------------------------------------------
--  DDL for Package Body HRPMC2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E" is
-- last update: 09/01/2020 16:37

  function gen_numseq (p_block in varchar2,p_item in varchar2) return number is
     v_numseq number ;
  begin
--     v_numseq := name_in(p_block||'.'||p_item);
     return  nvl(v_numseq,0) + 1 ;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_flg_warn          := 'N';
  end; -- end initial_value
  --
  procedure initial_tab_personal (json_obj in json_object_t) is
  begin
    personal_image          := hcm_util.get_string_t(json_obj,'image');
    personal_signature      := hcm_util.get_string_t(json_obj,'signature');
    personal_codtitle       := hcm_util.get_string_t(json_obj,'codtitle');
    personal_namfirste      := hcm_util.get_string_t(json_obj,'namfirste');
    personal_namfirstt      := hcm_util.get_string_t(json_obj,'namfirstt');
    personal_namfirst3      := hcm_util.get_string_t(json_obj,'namfirst3');
    personal_namfirst4      := hcm_util.get_string_t(json_obj,'namfirst4');
    personal_namfirst5      := hcm_util.get_string_t(json_obj,'namfirst5');
    personal_namlaste       := hcm_util.get_string_t(json_obj,'namlaste');
    personal_namlastt       := hcm_util.get_string_t(json_obj,'namlastt');
    personal_namlast3       := hcm_util.get_string_t(json_obj,'namlast3');
    personal_namlast4       := hcm_util.get_string_t(json_obj,'namlast4');
    personal_namlast5       := hcm_util.get_string_t(json_obj,'namlast5');
    personal_nickname       := hcm_util.get_string_t(json_obj,'nickname');
    personal_nicknamt       := hcm_util.get_string_t(json_obj,'nicknamt');
    personal_nicknam3       := hcm_util.get_string_t(json_obj,'nicknam3');
    personal_nicknam4       := hcm_util.get_string_t(json_obj,'nicknam4');
    personal_nicknam5       := hcm_util.get_string_t(json_obj,'nicknam5');
    personal_numtelec       := hcm_util.get_string_t(json_obj,'numtelec');
    personal_nummobile      := hcm_util.get_string_t(json_obj,'nummobile');
    personal_lineid         := hcm_util.get_string_t(json_obj,'lineid');
    personal_numoffid       := hcm_util.get_string_t(json_obj,'numoffid');
    personal_dteoffid       := to_date(hcm_util.get_string_t(json_obj,'dteoffid'),'dd/mm/yyyy');
    personal_adrissue       := hcm_util.get_string_t(json_obj,'adrissue');
    personal_codprovi       := hcm_util.get_string_t(json_obj,'codprovi');
    personal_codclnsc       := hcm_util.get_string_t(json_obj,'codclnsc');
    personal_numpasid       := hcm_util.get_string_t(json_obj,'numpasid');
    personal_dtepasid       := to_date(hcm_util.get_string_t(json_obj,'dtepasid'),'dd/mm/yyyy');
    personal_numvisa        := hcm_util.get_string_t(json_obj,'numvisa');
    personal_dtevisaexp     := to_date(hcm_util.get_string_t(json_obj,'dtevisaexp'),'dd/mm/yyyy');
    personal_numlicid       := hcm_util.get_string_t(json_obj,'numlicid');
    personal_dtelicid       := to_date(hcm_util.get_string_t(json_obj,'dtelicid'),'dd/mm/yyyy');
    personal_dteempdb       := to_date(hcm_util.get_string_t(json_obj,'dteempdb'),'dd/mm/yyyy');
    personal_coddomcl       := hcm_util.get_string_t(json_obj,'coddomcl');
    personal_codsex         := hcm_util.get_string_t(json_obj,'codsex');
    personal_weight         := hcm_util.get_string_t(json_obj,'weight');
    personal_high           := hcm_util.get_string_t(json_obj,'high');
    personal_codblood       := hcm_util.get_string_t(json_obj,'codblood');
    personal_codorgin       := hcm_util.get_string_t(json_obj,'codorgin');
    personal_codnatnl       := hcm_util.get_string_t(json_obj,'codnatnl');
    personal_codrelgn       := hcm_util.get_string_t(json_obj,'codrelgn');
    personal_stamarry       := hcm_util.get_string_t(json_obj,'stamarry');
    personal_stamilit       := hcm_util.get_string_t(json_obj,'stamilit');
    personal_numprmid       := hcm_util.get_string_t(json_obj,'numprmid');
    personal_dteprmst       := to_date(hcm_util.get_string_t(json_obj,'dteprmst'),'dd/mm/yyyy');
    personal_dteprmen       := to_date(hcm_util.get_string_t(json_obj,'dteprmen'),'dd/mm/yyyy');
    personal_numappl        := hcm_util.get_string_t(json_obj,'numappl');
    personal_numappl        := nvl(trim(personal_numappl),p_codempid_query);
    personal_dteretire      := to_date(hcm_util.get_string_t(json_obj,'dteretire'),'dd/mm/yyyy');
  end; -- end initial_tab_personal
  --
  procedure initial_tab_address (json_obj in json_object_t) is
  begin
    address_adrrege           := hcm_util.get_string_t(json_obj,'adrrege');
    address_adrregt           := hcm_util.get_string_t(json_obj,'adrregt');
    address_adrreg3           := hcm_util.get_string_t(json_obj,'adrreg3');
    address_adrreg4           := hcm_util.get_string_t(json_obj,'adrreg4');
    address_adrreg5           := hcm_util.get_string_t(json_obj,'adrreg5');
    address_codprovr          := hcm_util.get_string_t(json_obj,'codprovr');
    address_coddistr          := hcm_util.get_string_t(json_obj,'coddistr');
    address_codsubdistr       := hcm_util.get_string_t(json_obj,'codsubdistr');
    address_codcntyr          := hcm_util.get_string_t(json_obj,'codcntyr');
    address_codpostr          := hcm_util.get_string_t(json_obj,'codpostr');
    address_adrconte          := hcm_util.get_string_t(json_obj,'adrconte');
    address_adrcontt          := hcm_util.get_string_t(json_obj,'adrcontt');
    address_adrcont3          := hcm_util.get_string_t(json_obj,'adrcont3');
    address_adrcont4          := hcm_util.get_string_t(json_obj,'adrcont4');
    address_adrcont5          := hcm_util.get_string_t(json_obj,'adrcont5');
    address_codprovc          := hcm_util.get_string_t(json_obj,'codprovc');
    address_coddistc          := hcm_util.get_string_t(json_obj,'coddistc');
    address_codsubdistc       := hcm_util.get_string_t(json_obj,'codsubdistc');
    address_codcntyc          := hcm_util.get_string_t(json_obj,'codcntyc');
    address_codpostc          := hcm_util.get_string_t(json_obj,'codpostc');
  end; -- end initial_tab_address
  --
  procedure initial_tab_work (json_obj in json_object_t) is
  begin
    work_dteempmt          := to_date(hcm_util.get_string_t(json_obj,'dteempmt'),'dd/mm/yyyy');
    work_staemp            := hcm_util.get_string_t(json_obj,'staemp');
    work_dteeffex          := to_date(hcm_util.get_string_t(json_obj,'dteeffex'),'dd/mm/yyyy');
    work_codcomp           := hcm_util.get_string_t(json_obj,'codcomp');
    work_codpos            := hcm_util.get_string_t(json_obj,'codpos');
    work_dteefpos          := to_date(hcm_util.get_string_t(json_obj,'dteefpos'),'dd/mm/yyyy');
    work_numlvl            := hcm_util.get_string_t(json_obj,'numlvl');
    work_dteeflvl          := to_date(hcm_util.get_string_t(json_obj,'dteeflvl'),'dd/mm/yyyy');
    work_codbrlc           := hcm_util.get_string_t(json_obj,'codbrlc');
    work_codempmt          := hcm_util.get_string_t(json_obj,'codempmt');
    work_typpayroll        := hcm_util.get_string_t(json_obj,'typpayroll');
    work_typemp            := hcm_util.get_string_t(json_obj,'typemp');
    work_codcalen          := hcm_util.get_string_t(json_obj,'codcalen');
    work_flgatten          := hcm_util.get_string_t(json_obj,'flgatten');
    work_codjob            := hcm_util.get_string_t(json_obj,'codjob');
    work_jobgrade          := hcm_util.get_string_t(json_obj,'jobgrade');
    work_dteefstep         := to_date(hcm_util.get_string_t(json_obj,'dteefstep'),'dd/mm/yyyy');
    work_codgrpgl          := hcm_util.get_string_t(json_obj,'codgrpgl');
    work_stadisb           := hcm_util.get_string_t(json_obj,'stadisb');
    work_numdisab          := hcm_util.get_string_t(json_obj,'numdisab');
    work_dtedisb           := to_date(hcm_util.get_string_t(json_obj,'dtedisb'),'dd/mm/yyyy');
    work_dtedisen          := to_date(hcm_util.get_string_t(json_obj,'dtedisen'),'dd/mm/yyyy');
    work_typdisp           := hcm_util.get_string_t(json_obj,'typdisp');
    work_desdisp           := hcm_util.get_string_t(json_obj,'desdisp');
    work_qtyduepr          := hcm_util.get_string_t(json_obj,'qtyduepr');
    work_dteduepr          := to_date(hcm_util.get_string_t(json_obj,'dteduepr'),'dd/mm/yyyy');
    work_yredatrq          := hcm_util.get_string_t(json_obj,'yredatrq');
    work_mthdatrq          := hcm_util.get_string_t(json_obj,'mthdatrq');
    work_qtydatrq          := hcm_util.get_string_t(json_obj,'qtydatrq');
    work_dteoccup          := to_date(hcm_util.get_string_t(json_obj,'dteoccup'),'dd/mm/yyyy');
    work_numtelof          := hcm_util.get_string_t(json_obj,'numtelof');
    work_email             := hcm_util.get_string_t(json_obj,'email');
    work_numreqst          := hcm_util.get_string_t(json_obj,'numreqst');
    param_numreqst         := hcm_util.get_string_t(json_obj,'param_numreqst');
    param_codpos           := hcm_util.get_string_t(json_obj,'param_codpos');
    work_ocodempid         := hcm_util.get_string_t(json_obj,'ocodempid');
    work_dtereemp          := to_date(hcm_util.get_string_t(json_obj,'dtereemp'),'dd/mm/yyyy');
    work_qtyredue          := hcm_util.get_string_t(json_obj,'qtyredue');
    work_dteredue          := to_date(hcm_util.get_string_t(json_obj,'dteredue'),'dd/mm/yyyy');
    work_flgpdpa           := hcm_util.get_string_t(json_obj,'flgpdpa');
    work_dtepdpa           := to_date(hcm_util.get_string_t(json_obj,'dtepdpa'),'dd/mm/yyyy');
  end; -- end initial_tab_work
  --
  procedure initial_tab_travel (json_obj in json_object_t) is
  begin
    travel_typtrav         := hcm_util.get_string_t(json_obj,'typtrav');
    travel_carlicen        := hcm_util.get_string_t(json_obj,'carlicen');
    travel_typfuel         := hcm_util.get_string_t(json_obj,'typfuel');
    travel_qtylength       := hcm_util.get_string_t(json_obj,'qtylength');
    travel_codbusno        := hcm_util.get_string_t(json_obj,'codbusno');
    travel_codbusrt        := hcm_util.get_string_t(json_obj,'codbusrt');
  end; -- end initial_tab_travel
  --
  procedure initial_tab_income (json_obj_detail in json_object_t, json_obj_table in json_object_t) is
    json_row      json_object_t;
    v_codcompy    tcenter.codcompy%type;
  begin
    income_codcurr          := hcm_util.get_string_t(json_obj_detail,'codcurr');
--    income_afpro            := hcm_util.get_string(json_obj_detail,'afpro');
--    income_amtothr          := hcm_util.get_string(json_obj_detail,'amtothr');
--    income_amtday           := hcm_util.get_string(json_obj_detail,'amtday');
--    income_sumincom         := hcm_util.get_string(json_obj_detail,'sumincom');

    for i in 0..json_obj_table.get_size-1 loop
      json_row                      := hcm_util.get_json_t(json_obj_table,to_char(i));
      income_table(i + 1).amtincom  := replace(hcm_util.get_string_t(json_row, 'amtincom'),',','');
      income_table(i + 1).amtmax    := replace(hcm_util.get_string_t(json_row, 'amtmax'),',','');
    end loop;
    for i in (json_obj_table.get_size + 1)..10 loop
      income_table(i).amtincom  := null;
      income_table(i).amtmax    := null;
    end loop;

--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp = work_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    get_wage_income(v_codcompy,work_codempmt,
                    nvl(income_table(1).amtincom,0),nvl(income_table(2).amtincom,0),
                    nvl(income_table(3).amtincom,0),nvl(income_table(4).amtincom,0),
                    nvl(income_table(5).amtincom,0),nvl(income_table(6).amtincom,0),
                    nvl(income_table(7).amtincom,0),nvl(income_table(8).amtincom,0),
                    nvl(income_table(9).amtincom,0),nvl(income_table(10).amtincom,0),
                    income_amtothr,income_amtday,income_sumincom);
  end; -- end initial_tab_income
  --
  procedure initial_tab_tax(json_tax_detail json_object_t,
                            json_over_income json_object_t,
                            json_tax_exemption json_object_t,
                            json_tax_allowance json_object_t,
                            json_others_deduct json_object_t) is
    json_tax_exemption_row       json_object_t;
    json_tax_allowance_row       json_object_t;
    json_others_deduct_row       json_object_t;
  begin
    tax_detail_codempid           := hcm_util.get_string_t(json_tax_detail,'codempid');
    tax_detail_numtaxid           := hcm_util.get_string_t(json_tax_detail,'numtaxid');
    tax_detail_numsaid            := hcm_util.get_string_t(json_tax_detail,'numsaid');
    tax_detail_flgtax             := hcm_util.get_string_t(json_tax_detail,'flgtax');
    tax_detail_typtax             := hcm_util.get_string_t(json_tax_detail,'typtax');
    tax_detail_typincom           := hcm_util.get_string_t(json_tax_detail,'typincom');
    tax_detail_dteyrrelf          := hcm_util.get_string_t(json_tax_detail,'dteyrrelf');
    tax_detail_dteyrrelt          := hcm_util.get_string_t(json_tax_detail,'dteyrrelt');
    tax_detail_amtrelas           := hcm_util.get_string_t(json_tax_detail,'amtrelas');
    tax_detail_amttaxrel          := hcm_util.get_string_t(json_tax_detail,'amttaxrel');
    tax_detail_codbank            := hcm_util.get_string_t(json_tax_detail,'codbank');
    tax_detail_numbank            := hcm_util.get_string_t(json_tax_detail,'numbank');
    tax_detail_numbrnch           := hcm_util.get_string_t(json_tax_detail,'numbrnch');
    tax_detail_amtbank            := hcm_util.get_string_t(json_tax_detail,'amtbank');
    tax_detail_amttranb           := hcm_util.get_string_t(json_tax_detail,'amttranb');
    tax_detail_codbank2           := hcm_util.get_string_t(json_tax_detail,'codbank2');
    tax_detail_numbank2           := hcm_util.get_string_t(json_tax_detail,'numbank2');
    tax_detail_numbrnch2          := hcm_util.get_string_t(json_tax_detail,'numbrnch2');
    tax_detail_qtychldb           := hcm_util.get_string_t(json_tax_detail,'qtychldb');
    tax_detail_qtychlda           := hcm_util.get_string_t(json_tax_detail,'qtychlda');
    tax_detail_qtychldd           := hcm_util.get_string_t(json_tax_detail,'qtychldd');
    tax_detail_qtychldi           := hcm_util.get_string_t(json_tax_detail,'qtychldi');
    tax_detail_frsmemb            := to_date(hcm_util.get_string_t(json_tax_detail,'frsmemb'),'dd/mm/yyyy');
    tax_detail_flgslip            := hcm_util.get_string_t(json_tax_detail,'flgslip');

    over_income_dtebf             := to_date(hcm_util.get_string_t(json_over_income,'dtebf'),'dd/mm/yyyy');
    over_income_amtincbf          := hcm_util.get_string_t(json_over_income,'amtincbf');
    over_income_amttaxbf          := hcm_util.get_string_t(json_over_income,'amttaxbf');
    over_income_amtpf             := hcm_util.get_string_t(json_over_income,'amtpf');
    over_income_amtsaid           := hcm_util.get_string_t(json_over_income,'amtsaid');

    for i in 0..json_tax_exemption.get_size-1 loop
      json_tax_exemption_row          := hcm_util.get_json_t(json_tax_exemption,to_char(i));
      tax_exemption(i + 1).coddeduct  := hcm_util.get_string_t(json_tax_exemption_row, 'coddeduct');
      tax_exemption(i + 1).amtdeduct  := hcm_util.get_string_t(json_tax_exemption_row, 'amtdeduct');
    end loop;

    for i in 0..json_tax_allowance.get_size-1 loop
      json_tax_allowance_row          := hcm_util.get_json_t(json_tax_allowance,to_char(i));
      tax_allowance(i + 1).coddeduct  := hcm_util.get_string_t(json_tax_allowance_row, 'coddeduct');
      tax_allowance(i + 1).amtdeduct  := hcm_util.get_string_t(json_tax_allowance_row, 'amtdeduct');
    end loop;

    for i in 0..json_others_deduct.get_size-1 loop
      json_others_deduct_row    := hcm_util.get_json_t(json_others_deduct,to_char(i));
      others_deduct(i + 1).coddeduct  := hcm_util.get_string_t(json_others_deduct_row, 'coddeduct');
      others_deduct(i + 1).amtdeduct  := hcm_util.get_string_t(json_others_deduct_row, 'amtdeduct');
    end loop;
  end; -- end initial_tab_tax
  --
  procedure initial_tab_spouse(json_sp_over_income json_object_t,
                               json_sp_tax_exemption json_object_t,
                               json_sp_tax_deduct json_object_t,
                               json_sp_others_deduct json_object_t) is
    json_sp_tax_exemption_row   json_object_t;
    json_sp_tax_deduct_row      json_object_t;
    json_sp_others_deduct_row   json_object_t;
  begin
    sp_over_income_numtaxid       := hcm_util.get_string_t(json_sp_over_income,'numtaxid');
    sp_over_income_dtebfsp        := to_date(hcm_util.get_string_t(json_sp_over_income,'dtebfsp'),'dd/mm/yyyy');
    sp_over_income_amtincsp       := hcm_util.get_string_t(json_sp_over_income,'amtincsp');
    sp_over_income_amttaxsp       := hcm_util.get_string_t(json_sp_over_income,'amttaxsp');
    sp_over_income_amtsasp        := hcm_util.get_string_t(json_sp_over_income,'amtsasp');
    sp_over_income_amtpfsp        := hcm_util.get_string_t(json_sp_over_income,'amtpfsp');

    for i in 0..json_sp_tax_exemption.get_size-1 loop
      json_sp_tax_exemption_row          := hcm_util.get_json_t(json_sp_tax_exemption,to_char(i));
      sp_tax_exemption(i + 1).coddeduct  := hcm_util.get_string_t(json_sp_tax_exemption_row, 'coddeduct');
      sp_tax_exemption(i + 1).amtdeduct  := hcm_util.get_string_t(json_sp_tax_exemption_row, 'amtdeduct');
    end loop;

    for i in 0..json_sp_tax_deduct.get_size-1 loop
      json_sp_tax_deduct_row          := hcm_util.get_json_t(json_sp_tax_deduct,to_char(i));
      sp_tax_deduct(i + 1).coddeduct  := hcm_util.get_string_t(json_sp_tax_deduct_row, 'coddeduct');
      sp_tax_deduct(i + 1).amtdeduct  := hcm_util.get_string_t(json_sp_tax_deduct_row, 'amtdeduct');
    end loop;

    for i in 0..json_sp_others_deduct.get_size-1 loop
      json_sp_others_deduct_row    := hcm_util.get_json_t(json_sp_others_deduct,to_char(i));
      sp_others_deduct(i + 1).coddeduct  := hcm_util.get_string_t(json_sp_others_deduct_row, 'coddeduct');
      sp_others_deduct(i + 1).amtdeduct  := hcm_util.get_string_t(json_sp_others_deduct_row, 'amtdeduct');
    end loop;
  end; -- end initial_tab_spouse
  --
  procedure initial_tab_hisname(json_hisname json_object_t) is
    json_hisname_row    json_object_t;
  begin
    for i in 0..json_hisname.get_size-1 loop
      json_hisname_row                   := hcm_util.get_json_t(json_hisname,to_char(i));
      p_flg_del_hisname(i+1)             := hcm_util.get_string_t(json_hisname_row,'flgrow');
      hisname_tab(i+1).dtechg            := to_date(hcm_util.get_string_t(json_hisname_row,'dtechg'),'dd/mm/yyyy');
      hisname_tab(i+1).codtitle          := hcm_util.get_string_t(json_hisname_row,'codtitle');
      hisname_tab(i+1).namfirste         := hcm_util.get_string_t(json_hisname_row,'namfirste');
      hisname_tab(i+1).namfirstt         := hcm_util.get_string_t(json_hisname_row,'namfirstt');
      hisname_tab(i+1).namfirst3         := hcm_util.get_string_t(json_hisname_row,'namfirst3');
      hisname_tab(i+1).namfirst4         := hcm_util.get_string_t(json_hisname_row,'namfirst4');
      hisname_tab(i+1).namfirst5         := hcm_util.get_string_t(json_hisname_row,'namfirst5');
      hisname_tab(i+1).namlaste          := hcm_util.get_string_t(json_hisname_row,'namlaste');
      hisname_tab(i+1).namlastt          := hcm_util.get_string_t(json_hisname_row,'namlastt');
      hisname_tab(i+1).namlast3          := hcm_util.get_string_t(json_hisname_row,'namlast3');
      hisname_tab(i+1).namlast4          := hcm_util.get_string_t(json_hisname_row,'namlast4');
      hisname_tab(i+1).namlast5          := hcm_util.get_string_t(json_hisname_row,'namlast5');
      hisname_tab(i+1).deschang          := hcm_util.get_string_t(json_hisname_row,'deschang');
    end loop;
  end;
  --
  procedure initial_tab_document(json_document json_object_t) is
    json_document_row     json_object_t;
  begin
    for i in 0..json_document.get_size-1 loop
      json_document_row                 := hcm_util.get_json_t(json_document,to_char(i));
      p_flg_del_doc(i+1)                := hcm_util.get_string_t(json_document_row,'flgrow');
      document_tab(i+1).numseq          := hcm_util.get_string_t(json_document_row,'numseq');
      document_tab(i+1).typdoc          := hcm_util.get_string_t(json_document_row,'typdoc');
      document_tab(i+1).namdoc          := hcm_util.get_string_t(json_document_row,'namdoc');
      document_tab(i+1).dterecv         := to_date(hcm_util.get_string_t(json_document_row,'dterecv'),'dd/mm/yyyy');
      document_tab(i+1).dtedocen        := to_date(hcm_util.get_string_t(json_document_row,'dtedocen'),'dd/mm/yyyy');
      document_tab(i+1).numdoc          := hcm_util.get_string_t(json_document_row,'numdoc');
      document_tab(i+1).filedoc         := hcm_util.get_string_t(json_document_row,'filedoc');
      document_tab(i+1).desnote         := hcm_util.get_string_t(json_document_row,'desnote');
      document_tab(i+1).flgresume       := hcm_util.get_string_t(json_document_row,'flgresume');
    end loop;
  end;
  --
  procedure initial_smart_card(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj                   := json_object_t(json_str);
    param_numoffid            := hcm_util.get_string_t(json_obj,'numoffid');
    param_desc_codtitle       := hcm_util.get_string_t(json_obj,'desc_codtitle');
    param_namfirstt           := hcm_util.get_string_t(json_obj,'namfirstt');
    param_namlastt            := hcm_util.get_string_t(json_obj,'namlastt');
    param_namfirste           := hcm_util.get_string_t(json_obj,'namfirste');
    param_namlaste            := hcm_util.get_string_t(json_obj,'namlaste');
    param_dteempdb            := hcm_util.get_string_t(json_obj,'dteempdb');
    param_desc_codsex         := hcm_util.get_string_t(json_obj,'desc_codsex');
    param_number              := hcm_util.get_string_t(json_obj,'number');
    param_moo                 := hcm_util.get_string_t(json_obj,'moo');
    param_trok                := hcm_util.get_string_t(json_obj,'trok');
    param_soi                 := hcm_util.get_string_t(json_obj,'soi');
    param_road                := hcm_util.get_string_t(json_obj,'road');
    param_desc_subdist        := hcm_util.get_string_t(json_obj,'desc_subdist');
    param_desc_dist           := hcm_util.get_string_t(json_obj,'desc_dist');
    param_desc_province       := hcm_util.get_string_t(json_obj,'desc_province');
    param_adrissue            := hcm_util.get_string_t(json_obj,'adrissue');
    param_dteoffid            := hcm_util.get_string_t(json_obj,'dteoffid');
  end; -- end initial_smart_card
  --
  function check_emp_status return varchar2 is
    v_status    varchar2(100);
  begin
    begin
      select  'UPDATE'
      into    v_status
      from    temploy1
      where   codempid = p_codempid_query;
    exception when no_data_found then
      v_status  := 'INSERT';
    end;
    return v_status;
  end;
  --
  procedure check_get_personal is
    v_codempid_length   number;
    v_error             boolean := false;
    v_zupdsal           varchar2(10);

    v_chkrc  varchar2(10);
  begin
    begin
      select  char_length
      into    v_codempid_length
      from    user_tab_columns
      where   table_name = 'TEMPLOY1'
      and     column_name = 'CODEMPID';
    exception when no_data_found then
      v_codempid_length := null;
    end;

    if v_codempid_length is not null then
      if v_codempid_length < length(p_codempid_query) then
        param_msg_error   := get_error_msg_php('HR2057',global_v_lang,'max length : 10');
        return;
      end if;
    end if;

    if p_codempid_query is not null then
      v_error   := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--<<--03/11/2022
    begin
      select  'X'
      into    v_chkrc
      from    temploy1
      where   codempid  = p_codempid_query
      and staemp = '0' and nvl(numlvl,0) = 0;
      v_error := true;
    exception when no_data_found then
      null;
    end;
--<<--03/11/2022
--
      if not v_error then
        --param_msg_error   := get_error_msg_php('HR3007'||'SSSSSSSS',global_v_lang);
        param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure check_tab_personal is
    v_code      varchar2(100);
    v_numlvl    number;
    v_ch        boolean;
    v_ctrl_codnatnl tsetdeflt.defaultval%type;
    v_chk_codempid  temploy1.codempid%type;
    v_chk_staemp    temploy1.staemp%type;
  begin
    begin
      select  defaultval
      into    v_ctrl_codnatnl
      from    tsetdeflt
      where   codapp    = 'HRPMC2E'
      and     numpage   = 'HRPMC2E11'
      and     fieldname = 'CODNATNL'
      and     seqno     = 1;
    exception when no_data_found then
      null;
    end;

    if personal_numoffid is not null then
      if v_ctrl_codnatnl = personal_codnatnl then
        v_ch := check_numoffid(personal_numoffid);
        if not v_ch and param_flgwarn = 'S' then -- Start check warning
          param_msg_error := get_error_msg_php('PM0059',global_v_lang);
          param_flgwarn   := 'WARN1';
          p_flg_warn      := 'Y';
          return;
        end if;
      end if;

      if param_flgwarn = 'S' then
        param_flgwarn   := 'WARN1';
      end if;

      if param_flgwarn = 'WARN1' then
        begin
          select numoffid	into v_code
          from   tbcklst
          where  numoffid = personal_numoffid;
          param_msg_error   := get_error_msg_php('HR2006',global_v_lang);
          param_flgwarn     := 'WARN2';
          p_flg_warn      := 'Y';
          return;
        exception when no_data_found then
          null;
        end;
      end if;
      if param_flgwarn = 'WARN1' then
        param_flgwarn     := 'WARN2';
      end if;

      if param_flgwarn = 'WARN2' then
        begin
          select a.codempid,a.staemp
          into   v_chk_codempid,v_chk_staemp
          from   temploy1 a,temploy2 b
          where  a.codempid = b.codempid
          and    b.numoffid = personal_numoffid
          and   (a.codempid <> p_codempid_query or p_codempid_query is null)
          and    a.staemp   <> '9'
          and rownum = 1;
          param_msg_error := replace(get_error_msg_php('PM0015',global_v_lang),get_label_name('HRPMC2E1T1','102',10),
                             v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                             get_label_name('HRPMC2E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang));
          param_flgwarn   := 'WARN3'; -- End check warning
          p_flg_warn      := 'Y';
          return;
        exception when no_data_found then
          null;
        end;
      end if;
	  end if;
    if param_flgwarn in ('S','WARN2') then
      param_flgwarn     := 'WARN3';
    end if;

    if param_flgwarn = 'WARN3' then
      begin
        select codempid into v_code
          from temploy1
         where (codempid <> p_codempid_query or p_codempid_query is null)
--             and ((global_v_lang = '101' and v_name = ltrim(rtrim(namfirste))||ltrim(rtrim(namlaste)))
--              or  (global_v_lang = '102' and v_name = ltrim(rtrim(namfirstt))||ltrim(rtrim(namlastt)))
--              or  (global_v_lang = '103' and v_name = ltrim(rtrim(namfirst3))||ltrim(rtrim(namlast3)))
--              or  (global_v_lang = '104' and v_name = ltrim(rtrim(namfirst4))||ltrim(rtrim(namlast4)))
--              or  (global_v_lang = '105' and v_name = ltrim(rtrim(namfirst5))||ltrim(rtrim(namlast5))))
           and ((global_v_lang = '101' and trim(personal_namfirste)||trim(personal_namlaste) = ltrim(rtrim(namfirste))||ltrim(rtrim(namlaste)))
            or  (global_v_lang = '102' and trim(personal_namfirstt)||trim(personal_namlastt) = ltrim(rtrim(namfirstt))||ltrim(rtrim(namlastt)))
            or  (global_v_lang = '103' and trim(personal_namfirst3)||trim(personal_namlast3) = ltrim(rtrim(namfirst3))||ltrim(rtrim(namlast3)))
            or  (global_v_lang = '104' and trim(personal_namfirst4)||trim(personal_namlast4) = ltrim(rtrim(namfirst4))||ltrim(rtrim(namlast4)))
            or  (global_v_lang = '105' and trim(personal_namfirst5)||trim(personal_namlast5) = ltrim(rtrim(namfirst5))||ltrim(rtrim(namlast5))))
           and staemp <> '9'
        and rownum <= 1;
      --	alert_error.error_data('PM0013',global_v_lang);
        --mdf ให้แสดงรหัสพนักงาน และให้ เลือก save ต่อ หรือ ยกเลิก
        param_msg_error := get_error_msg_php('PM0013',global_v_lang);
        param_flgwarn   := 'WARN4'; -- End check warning
        p_flg_warn      := 'Y';
        return;
        --PM0013    ชื่อ-นามสกุล ซ้ำ
      exception when no_data_found then
        null;
      end;
    end if;

    if personal_dtepasid <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dtepasid');
      return;
    end if;

    if personal_dtelicid <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dtelicid');
      return;
    end if;

    if personal_dteoffid <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dteoffid');
      return;
    end if;

    if param_flgwarn = 'WARN3' then
      param_flgwarn     := 'WARN4';
    end if;
    if param_flgwarn = 'WARN4' then
      if (months_between(sysdate,personal_dteempdb)) / 12 < 18 then
        param_msg_error := get_error_msg_php('PM0014',global_v_lang,null,'dteempdb');
        param_flgwarn   := 'WARN5'; -- End check warning
        p_flg_warn      := 'Y';
        return;
      end if;
    end if;

    if personal_codprovi is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = personal_codprovi;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovi');
        return;
      end;
    end if;

    if personal_codclnsc is not null then
      begin
        select codcln into v_code
        from	 tclninf
        where	 codcln = personal_codclnsc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCLNINF','codclnsc');
        return;
      end;
    end if;

    if personal_coddomcl is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = personal_coddomcl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','coddomcl');
        return;
      end;
    end if;

    if personal_codrelgn is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec = personal_codrelgn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRELI','codrelgn');
        return;
      end;
    end if;

    if personal_codorgin is not null then
      begin
        select codcodec into v_code
        from	 tcodregn
        where	 codcodec = personal_codorgin;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODREGN','codorgin');
        return;
      end;
    end if;

    if personal_codnatnl is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec = personal_codnatnl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODNATN','codnatnl');
        return;
      end;
    end if;
  end; -- end check_tab_personal
  --
  procedure check_tab_address is
    v_code      varchar2(100);
    v_numlvl    number;
    v_codprovr  temploy2.codprovr%type;
    v_coddistr  temploy2.coddistr%type;
    v_codprovc  temploy2.codprovc%type;
    v_coddistc  temploy2.coddistc%type;
  begin
    if address_codsubdistr is not null then
      begin
        select codsubdist,codprov,coddist
        into   v_code,v_codprovr,v_coddistr
        from	 tsubdist
        where	 codprov    = nvl(address_codprovr,codprov)
        and		 coddist    = nvl(address_coddistr,coddist)
        and		 codsubdist = address_codsubdistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBDIST','codsubdistr');
        return;
      end;
    end if;

    if address_coddistr is not null then
      begin
        select coddist,codprov into v_code,v_codprovr
        from	 tcoddist
        where	 codprov = nvl(address_codprovr,codprov)
        and		 coddist = address_coddistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDIST','coddistr');
        return;
      end;
    else
      address_coddistr  := v_coddistr;
    end if;

    if address_codprovr is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = address_codprovr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovr');
        return;
      end;
    else
      address_codprovr  := v_codprovr;
    end if;

    if address_codsubdistc is not null then
      begin
        select codsubdist,codprov,coddist
        into   v_code,v_codprovc,v_coddistc
        from	 tsubdist
        where	 codprov    = nvl(address_codprovc,codprov)
        and		 coddist    = nvl(address_coddistc,coddist)
        and		 codsubdist = address_codsubdistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBDIST','codsubdistc');
        return;
      end;
    end if;

    if address_coddistc is not null then
      begin
        select coddist,codprov into v_code,v_codprovc
        from	 tcoddist
        where	 codprov = nvl(address_codprovc,codprov)
        and		 coddist = address_coddistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDIST','coddistc');
        return;
      end;
    else
      address_coddistc  := v_coddistc;
    end if;

    if address_codprovc is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = address_codprovc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovc');
        return;
      end;
    else
      address_codprovc  := v_codprovc;
    end if;
  end; -- end check_tab_address
  --
  procedure check_tab_work is
    v_code      varchar2(100);
    v_numlvl    number;
    v_maxlvl  	tjobpos.joblvlst%type;
    v_minlvl		tjobpos.joblvlen%type;
    v_codcomp   tcenter.codcomp%type;
    v_qtyact    treqest2.qtyact%type;
    v_qtyreq    treqest2.qtyreq%type;
    v_qtydatrq  number;--treqest2.qtydatrq%type;
    v_flgsecu		boolean;
    v_zupdsal   varchar2(1);
    v_codcompy  varchar2(100);
  begin
    begin
      select  numlvl
      into    v_numlvl
      from    temploy1
      where   codempid  = p_codempid_query;
    exception when no_data_found then
      null;
    end;

    if work_numlvl not between global_v_zminlvl and global_v_zwrklvl then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,null,'numlvl');
      return;
    end if;

    if (v_numlvl not between global_v_numlvlsalst and global_v_numlvlsalen) and
      (work_numlvl between global_v_numlvlsalst and global_v_numlvlsalen) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,null,'numlvl');
      return;
    end if;

    if work_dteempmt <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0019',global_v_lang,null,'dteempmt');
      return;
    end if;

    if work_dteeflvl <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0021',global_v_lang,null,'dteeflvl');
      return;
    end if;

    if work_dteefpos <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0022',global_v_lang,null,'dteefpos');
      return;
    end if;

    if work_dteefstep <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0057',global_v_lang,null,'dteefstep');
      return;
    end if;

    if work_dteoccup <= personal_dteempdb then
      param_msg_error := get_error_msg_php('PM0023',global_v_lang,null,'dteoccup');
      return;
    end if;

    if work_dteempmt > work_dteeffex then
      param_msg_error := get_error_msg_php('PM0020',global_v_lang,null,'dteempmt');
      return;
    end if;

    if work_dteeflvl < work_dteempmt then
      param_msg_error := get_error_msg_php('PM0049',global_v_lang,null,'dteeflvl');
      return;
    end if;

    if work_dteefpos < work_dteempmt then
      param_msg_error := get_error_msg_php('PM0050',global_v_lang,null,'dteefpos');
      return;
    end if;

    if work_dteefstep < work_dteempmt then
      param_msg_error := get_error_msg_php('PM0054',global_v_lang,null,'dteefstep');
      return;
    end if;

    if nvl(work_qtyduepr,0) > 0 and work_dteduepr is null then
      work_dteduepr := work_dteempmt + nvl(work_qtyduepr,0) - 1;
      -- Adisak redmine ##9350 25/04/2023 19:46
--    else
--      work_dteduepr := null;
      -- Adisak redmine ##9350 25/04/2023 19:46
    end if;

    if work_staemp = '1' then
      work_dteoccup := null;
    elsif work_staemp = '0' then
      if nvl(work_qtyduepr,0) > 0 then
        work_dteoccup := null;
      end if;
    elsif work_staemp = '9' then
      if nvl(work_qtyduepr,0) = 0 and nvl(work_qtyredue,0) = 0 and work_dteoccup is null then
        work_dteoccup := nvl(work_dtereemp,work_dteempmt);
      end if;
    end if;

  	if work_dteoccup < work_dteempmt then
      param_msg_error := get_error_msg_php('PM0052',global_v_lang,null,'dteoccup');
      return;
    end if;

    begin
--      select nummaxlvl,numminlvl into v_maxlvl,v_minlvl
--      from	 tpostn
--      where	 codpos = work_codpos;
/*      begin
        select  joblvlen,joblvlst
        into    v_maxlvl,v_minlvl
        from    tjobpos
        where   codcomp   like work_codcomp||'%'
        and     codpos    = work_codpos
        and     rownum    = 1;
      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TJOBPOS');
        return;
      end;*/
      if v_maxlvl is not null then
        if work_numlvl < v_minlvl then
          param_msg_error := get_error_msg_php('PM0009',global_v_lang,v_minlvl||' - '||v_maxlvl,'numlvl');
          return;
        elsif work_numlvl > v_maxlvl then
          param_msg_error := get_error_msg_php('PM0008',global_v_lang,v_minlvl||' - '||v_maxlvl,'numlvl');
          return;
        end if;
      end if;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN','codpos');
      return;
    end;

    work_qtydatrq := (nvl(work_yredatrq,0) * 12) + nvl(work_mthdatrq,0);
    if work_numreqst is not null then
      begin
        select codcomp into v_codcomp
        from 	 treqest1
        where	 numreqst = work_numreqst;
        if v_codcomp <> work_codcomp then
          param_msg_error := get_error_msg_php('HR4522',global_v_lang,'TREQEST1','numreqst');
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TREQEST1','numreqst');
        return;
      end;
--      if param_numreqst <> work_numreqst or param_codpos <> work_codpos then
      begin
        select nvl(qtyact,0),nvl(qtyreq,0),0--nvl(qtydatrq,0)
        into   v_qtyact,v_qtyreq,v_qtydatrq
        from 	 treqest2
        where	 numreqst = work_numreqst
        and		 codpos		= work_codpos;
        if v_qtyact >= v_qtyreq then
          param_msg_error := get_error_msg_php('HR4502',global_v_lang,null,'numreqst');
          return;
        else
          work_qtydatrq := v_qtydatrq;
          work_yredatrq := trunc(v_qtydatrq / 12);
          work_mthdatrq := mod(v_qtydatrq,12);
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR5005',global_v_lang,null,'numreqst');
        return;
      end;
--      end if;
    end if;

    v_flgsecu := secur_main.secur1(work_codcomp,work_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if not v_flgsecu then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;

    if nvl(v_numlvl,0) <> 0  then
	  	if v_numlvl not between global_v_numlvlsalst and  global_v_numlvlsalen then
        if work_numlvl between global_v_numlvlsalst and  global_v_numlvlsalen then
          param_msg_error := get_error_msg_php('HR3012',global_v_lang,null,'numlvl');
          return;
        end if;
			end if;
		end if;

    begin
      select codcodec into v_code
      from	 tcodloca
      where	 codcodec = work_codbrlc;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODLOCA','codbrlc');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodempl
      where	 codcodec = work_codempmt;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEMPL','codempmt');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodtypy
      where	 codcodec = work_typpayroll;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY','typpayroll');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodcatg
      where	 codcodec = work_typemp;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATG','typemp');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodwork
      where	 codcodec = work_codcalen;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK','codcalen');
      return;
    end;

    begin
      select codjob into v_code
      from	 tjobcode
      where	 codjob = work_codjob;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TJOBCODE','codjob');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodjobg
      where	 codcodec = work_jobgrade;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODJOBG','jobgrade');
      return;
    end;

    begin
      select codcodec into v_code
      from	 tcodgrpgl
      where	 codcodec = work_codgrpgl;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODGRPGL','codgrpgl');
      return;
    end;

    if work_typdisp is not null then
      begin
        select codcodec into v_code
        from	 tcoddisp
        where	 codcodec = work_typdisp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDISP','typdisp');
        return;
      end;
    end if;

    if work_dtedisb > work_dtedisen then
      param_msg_error := get_error_msg_php('HR6625',global_v_lang,null,'dtedisen');
      return;
    end if;

--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp = work_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    begin
      select  distinct 'X'
      into    v_code
      from    tcontpmd
      where   codcompy  = v_codcompy
      and     codempmt  = work_codempmt;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCONTPMD','codempmt');
      return;
    end;
  end; -- end check_tab_work
  --
  procedure check_tab_travel is
    v_code      varchar2(100);
    v_numlvl    number;
  begin
    if travel_codbusno is not null then
      begin
        select codcodec into v_code
        from	 tcodbusno
        where	 codcodec = travel_codbusno;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODBUSNO','codbusno');
        return;
      end;
    end if;

    if travel_codbusrt is not null then
      begin
        select codcodec into v_code
        from	 tcodbusrt
        where	 codcodec = travel_codbusrt;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODBUSRT','codbusrt');
        return;
      end;
    end if;
    if param_flgwarn = 'WARN4' then
      param_flgwarn     := 'WARN5';
    end if;
    if param_flgwarn = 'WARN5' then
      if to_number(travel_qtylength) > 200 then
        param_msg_error := get_error_msg_php('PM0114',global_v_lang);
        param_flgwarn   := 'WARN6'; -- End check warning
        p_flg_warn      := 'Y';
        return;
      end if;
    end if;
  end; -- end check_tab_travel
  --
  procedure check_tab_income is
    v_code      varchar2(100);
    v_numlvl    number;
  begin
--    get_incom;
    if income_codcurr is not null then
      begin
        select codcodec into v_code
        from	 tcodcurr
        where	 codcodec = income_codcurr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCURR','codcurr');
        return;
      end;
    end if;
	  --<<user36 STA3590210 02/02/2016
	  for i in 1..10 loop
      if nvl(income_table(i).amtincom,0) > 0 and income_table(i).amtmax is not null then
        if nvl(income_table(i).amtincom,0) > income_table(i).amtmax then
          param_msg_error := get_error_msg_php('PM0066',global_v_lang,'TCONTPMD','amtincom');
          return;
        end if;
      end if;
		end loop;
  end; -- end check_tab_income
  --
  procedure check_tab_tax_detail is
    v_code      varchar2(100);
    v_numlvl    number;
  begin
    if tax_detail_flgtax is null then
	  	tax_detail_flgtax := '1';
	  end if;

		if personal_stamarry is null then
			tax_detail_typtax := '1';
	  end if;

		if personal_stamarry = 'S' then
			tax_detail_typtax := '1';
	  end if;

	  if tax_detail_codbank is not null then
		  begin
		  	select codcodec into v_code
		  	from	 tcodbank
		  	where	 codcodec = tax_detail_codbank;
		  exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODBANK','codbank');
        return;
		  end;
		end if;

	  if tax_detail_codbank2 is not null then
		  begin
		  	select codcodec into v_code
		  	from	 tcodbank
		  	where	 codcodec = tax_detail_codbank2;
		  exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODBANK','codbank2');
        return;
		  end;
		end if;
/*
		if tax_detail_codbank = tax_detail_codbank2 and
			 tax_detail_numbank = tax_detail_numbank2 then
      param_msg_error := get_error_msg_php('PM0024',global_v_lang,null,'numbank2');
      return;
		end if;
*/
    if tax_detail_dteyrrelf is not null or tax_detail_dteyrrelt is not null then
			if tax_detail_dteyrrelf > tax_detail_dteyrrelt then
        param_msg_error := get_error_msg_php('HR2027',global_v_lang,null,'dteyrrelt');
        return;
			end if;
		end if;

    if nvl(tax_detail_amtbank,0) = 100 then
			tax_detail_codbank2 := null;
      tax_detail_numbank2 := null;
      tax_detail_numbrnch2 := null;
		end if;

    if tax_detail_qtychldd > 3 then
      param_msg_error   := get_error_msg_php('PM0116',global_v_lang,null,'qtychldd');
      return;
    else
      if (nvl(tax_detail_qtychldb,0) +
          nvl(tax_detail_qtychlda,0) +
          nvl(tax_detail_qtychldd,0)) > 3 and
          nvl(tax_detail_qtychldd,0) > 0 then
        param_msg_error   := get_error_msg_php('PM0115',global_v_lang,null,'qtychldd');
        return;
      end if;
    end if;

    if param_flgwarn = 'WARN5' then
      param_flgwarn     := 'WARN6';
    end if;

    if param_flgwarn = 'WARN6' then
      declare
        v_chk_codempid  temploy1.codempid%type;
        v_chk_staemp    temploy1.staemp%type;
      begin
        select t1.codempid,t1.staemp
          into v_chk_codempid,v_chk_staemp
          from temploy1 t1, temploy3 t3
         where t1.codempid  = t3.codempid
           and (numbank in (tax_detail_numbank, tax_detail_numbank2)
            or numbank2 in (tax_detail_numbank, tax_detail_numbank2))
           and (t1.codempid <> p_codempid_query or p_codempid_query is null)
           and rownum = 1;
        param_msg_error := replace(get_error_msg_php('PM0024',global_v_lang,null,'numbank'),'@#$%',' ('||
                           v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                           get_label_name('HRPMC2E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang)||')@#$%');
        param_flgwarn   := 'WARN7'; -- End check warning
        p_flg_warn      := 'Y';
        return;
      exception when no_data_found then
        null;
      end;
    end if;
    param_flgwarn   := null;
  end; -- end check_tab_tax_detail
  --
  procedure check_tab_over_income is
  begin
    if over_income_dtebf is null then
	  	over_income_dtebf := to_date('01/01/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
	  elsif over_income_dtebf > trunc(sysdate) then
      param_msg_error := get_error_msg_php('PM0025',global_v_lang,null,'dtebf');
      return;
	  end if;
  end; -- end check_tab_over_income
  --
  procedure check_tab_sp_over_income is
  begin
    if sp_over_income_dtebfsp is null then
	  	sp_over_income_dtebfsp := to_date('01/01/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
	  elsif sp_over_income_dtebfsp > trunc(sysdate) then
      param_msg_error := get_error_msg_php('PM0025',global_v_lang,null,'dtebfsp');
      return;
	  end if;
  end; -- end check_tab_sp_over_income
  --
  procedure check_delete_personal is
    v_code        varchar2(100);
  begin
    if work_staemp <> '9' or work_dteeffex > trunc(sysdate) then
      param_msg_error := get_error_msg_php('PM0016',global_v_lang);
      return;
    else
      begin
        select  codempid into v_code
        from 	  ttaxmas
        where   codempid  = p_codempid_query
        and     rownum    = 1;
        param_msg_error := get_error_msg_php('HR1507',global_v_lang);
        return;
      exception when no_data_found then
        null;
      end;
    end if;
  end; -- end check_delete_personal
  --
  procedure check_get_allowance is
    v_code        varchar2(100);
    v_flgsecu			boolean;
  begin
    if work_staemp = '0' then
      param_msg_error := get_error_msg_php('HR2102',global_v_lang);
      return;
    elsif work_staemp = '9' then
      param_msg_error := get_error_msg_php('HR2101',global_v_lang);
      return;
    end if;

    v_flgsecu := secur_main.secur7(work_codcomp,global_v_coduser);
    if not v_flgsecu then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;

    if work_codempmt is not null then
      begin
        select codcodec into v_code
        from	 tcodempl
        where	 codcodec = work_codempmt;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEMPL');
        return;
      end;
    end if;
  end; -- end check_get_allowance
  --
  procedure check_get_default_value_by_codcomp is
    v_code        varchar2(100);
    v_flgsecu			boolean;
  begin
    v_flgsecu := secur_main.secur7(work_codcomp,global_v_coduser);
    if not v_flgsecu then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;

    begin
      select codcomp into v_code
      from	 tcenter
      where	 codcomp = work_codcomp;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
      return;
    end;
  end; -- end check_get_default_value_by_codcomp
  --
  procedure check_get_data_income is
    v_code        varchar2(100);
    v_flgsecu			boolean;
  begin
    v_flgsecu := secur_main.secur7(work_codcomp,global_v_coduser);
    if not v_flgsecu then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;

    begin
      select codcodec into v_code
      from	 tcodempl
      where	 codcodec = work_codempmt;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEMPL');
      return;
    end;
  end; -- end check_get_data_income
  --
  procedure check_get_map_smart_card(json_str_output out clob) is
    obj_row               json_object_t;

    v_adrreg              varchar2(4000 char);
    v_codtitle            tlistval.list_value%type;
    v_codsex              temploy1.codsex%type;
    v_dteempdb            date;
    v_codprovice	        varchar2(5);
    v_codampphor	        varchar2(5);
    v_codthombon	        varchar2(5);
    v_adrissue            temploy2.adrissue%type;
    v_codpost             temploy2.codpostc%type;
    v_dteoffid            date;

    v_flg  			          varchar2(1);
    v_hbd					        date;
    v_chkhpd			        number;
    v_chkoff			        number;
    v_off					        date;
    v_sysdate			        number;
  begin
    obj_row   := json_object_t();
    if param_numoffid is not null then
      v_sysdate       := to_number(to_char(sysdate,'yyyy'));
      v_adrreg        := param_number||' '||param_moo||' '||param_trok||' '||param_soi||' '||param_road;
      if param_desc_codtitle is not null then
        begin
          select  list_value
          into    v_codtitle
          from    tlistval
          where   codapp      = 'CODTITLE'
          and     desc_label  = param_desc_codtitle
          and     codlang     = global_v_lang
          and     list_value  is not null;
        exception when no_data_found then
          v_codtitle  := null;
        end;
        if v_codtitle is null then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang, get_label_name('HRPMC2E1P2',global_v_lang,50));
          return;
        end if;
      end if;

      if param_desc_codsex is not null then
        if param_desc_codsex not in ('F','M') then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang, get_label_name('HRPMC2E1P2',global_v_lang,110));
          return;
        end if;
        v_codsex    := param_desc_codsex;
      end if;

      if param_dteempdb is not null then
        begin
          select to_date(param_dteempdb,'dd/mm/yyyy') into v_hbd
          from dual;
          v_flg := 'Y';
        exception when others then
          v_flg := 'N';
          param_msg_error   := get_error_msg_php('HR2020', global_v_lang, get_label_name('HRPMC2E1P2',global_v_lang,100));
          return;
        end;

        if v_flg = 'Y' then
          v_chkhpd := to_number(to_char(v_hbd,'yyyy'));
          if v_sysdate > 2500 and v_chkhpd < 2400 then
            v_chkhpd := v_chkhpd + 543;
          elsif v_sysdate < 2500 and v_chkhpd > 2400 then
            v_chkhpd := v_chkhpd - 543;
          end if;
          v_dteempdb  := to_date(to_char(v_hbd,'dd/mm')||to_char(v_chkhpd),'dd/mm/yyyy');
        end if;
      end if;
      --Provice
      if param_desc_province is not null then
        begin
          select  codcodec into v_codprovice
          from    tcodprov
          where   param_desc_province like '%'||decode(global_v_lang,'102',descodt
                                                                    ,'101',descode
                                                                    ,'103',descod3
                                                                    ,'104',descod4
                                                                    ,'105',descod5)||'%';
        exception when no_data_found then
          v_codprovice := null;
        end;
        if v_codprovice is null then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang,'TCODPROV');
          return;
        end if;
      end if;
      --Amphor
      if param_desc_dist is not null then
        begin
          select  coddist into v_codampphor
          from    tcoddist
          where   param_desc_dist like '%'||decode(global_v_lang,'102',namdistt
                                                                ,'101',namdiste
                                                                ,'103',namdist3
                                                                ,'104',namdist4
                                                                ,'105',namdist5)||'%'
          and codprov = v_codprovice
          and rownum = 1;
        exception when no_data_found then
          v_codampphor := null;
        end;

        if v_codampphor is null then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang,'TCODDIST');
          return;
        end if;
      end if;
      --Thombon
      if param_desc_subdist is not null then
        begin
          select  codsubdist into v_codthombon
          from    tsubdist
          where   param_desc_subdist like '%'||decode(global_v_lang,'102',namsubdistt
                                                                   ,'101',namsubdiste
                                                                   ,'103',namsubdist3
                                                                   ,'104',namsubdist4
                                                                   ,'105',namsubdist5)||'%'
          and codprov = v_codprovice
          and coddist = v_codampphor
          and rownum = 1;
        exception when no_data_found then
            v_codthombon := null;
        end;
        if v_codthombon is null then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang,'TSUBDIST');
          return;
        end if;
      end if;

      if param_dteoffid is not null then
        begin
          select to_date(param_dteoffid,'dd/mm/yyyy') into v_off
          from dual;
          v_flg := 'Y';
        exception when others then
          v_flg := 'N';
          param_msg_error   := get_error_msg_php('HR2020', global_v_lang, get_label_name('HRPMC2E1P2',global_v_lang,210));
          return;
        end;
          if v_flg = 'Y' then
            v_chkoff := to_number(to_char(v_off,'yyyy'));
            if v_sysdate > 2500 and v_chkoff < 2500 then
              v_chkoff := v_chkoff + 543;
            elsif v_sysdate < 2500 and v_chkoff > 2500 then
              v_chkoff := v_chkoff - 543;
            end if;
            v_dteoffid  := to_date(to_char(v_off,'dd/mm')||to_char(v_chkoff),'dd/mm/yyyy');
          end if;
      end if;

      --Code post
      begin
        select codpost into v_codpost
          from tcoddist
         where coddist = v_codampphor;
      exception when no_data_found   then
         v_codpost := null ;
      end;
    end if;
    obj_row.put('coderror','200');
    obj_row.put('numoffid',param_numoffid);
    obj_row.put('codtitle',v_codtitle);
    obj_row.put('namfirstt',param_namfirstt);
    obj_row.put('namlastt',param_namlastt);
    obj_row.put('namfirste',param_namfirste);
    obj_row.put('namlaste',param_namlaste);
    obj_row.put('adrreg',v_adrreg);
    obj_row.put('codsex',v_codsex);
    obj_row.put('dteempdb',to_char(v_dteempdb,'dd/mm/yyyy'));
    obj_row.put('codprovice',v_codprovice);
    obj_row.put('codampphor',v_codampphor);
    obj_row.put('codthombon',v_codthombon);
    obj_row.put('adrissue',substr(substr(param_adrissue,1,instr(param_adrissue,'/')-1),1,20));
    obj_row.put('codpost',v_codpost);
    obj_row.put('dteoffid',to_char(v_dteoffid,'dd/mm/yyyy'));
    json_str_output := obj_row.to_clob;
  end; -- end check_get_map_smart_card
  --
  function gen_newid return varchar2 is
    v_dteyear	    number;
    v_codnewid    temploy1.codempid%type;
    v_groupid    varchar2(10);
    v_table      varchar2(10);
    v_error      varchar2(10);
  begin
    std_genid2.gen_id(work_codcomp,work_codempmt,work_codbrlc,work_dteempmt,parameter_groupid,v_codnewid,parameter_year,parameter_month,parameter_running,v_table,v_error);
    if v_error is not null then
      param_msg_error   := get_error_msg_php(v_error,global_v_lang,v_table);
      return '';
    else
      return v_codnewid;
    end if;
  end;
  --
  procedure upd_log1
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_fldedit 	in varchar2,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	    in out boolean) is

     v_exist		 boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

    cursor c_ttemlog1 is
      select rowid
      from   ttemlog1
      where  codempid = p_codempid_query
      and		 dteedit	= sysdate
      and		 numpage	= p_numpage
      and    fldedit  = upper(p_fldedit);
  begin
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;
--      if :parameter.codapp in ('PMC2','RECRUIT') then sssssssssssssssssssssssssssssss
        p_upd := true;
        for r_ttemlog1 in c_ttemlog1 loop
          v_exist := true;
          update ttemlog1
          set    codcomp 	= work_codcomp,
                 desold 	= v_desold,
                 desnew 	= v_desnew,
                 flgenc 	= p_flgenc,
                 codtable = upper(p_codtable),
                 dteupd 	= trunc(sysdate),
                 coduser 	= global_v_coduser
          where  rowid = r_ttemlog1.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog1
            (codempid,dteedit,numpage,fldedit,codcomp,
             desold,desnew,flgenc,codtable,dteupd,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,upper(p_fldedit),work_codcomp,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),trunc(sysdate),global_v_coduser);
        end if;
    end if;
  end; -- end upd_log1
  --
  procedure upd_log2
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_numseq		in number,
     p_fldedit 	in varchar2,
     p_typkey 	in varchar2,
     p_fldkey 	in varchar2,
     p_codseq 	in varchar2,
     p_dteseq 	in date,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	in out boolean,
     p_flgdata  in varchar2 default 'U') is
    v_exist		boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

  cursor c_ttemlog2 is
    select rowid
    from   ttemlog2
    where  codempid = p_codempid_query
    and		 dteedit	= sysdate
    and		 numpage	= p_numpage
    and		 numseq 	= p_numseq
    and    fldedit  = upper(p_fldedit);
  begin
    if check_emp_status = 'INSERT' then--and:parameter.codapp <> 'REHIRE'
      p_upd := true;--Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;

--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog2 in c_ttemlog2 loop
          v_exist := true;
          update ttemlog2
          set    typkey = p_typkey,
                 fldkey = upper(p_fldkey),
                 codseq = p_codseq,
                 dteseq = p_dteseq,
                 codcomp = work_codcomp,
                 desold = v_desold,
                 desnew = v_desnew,
                 flgenc = p_flgenc,
                 codtable = upper(p_codtable),
                 flgdata = upper(p_flgdata),
                 coduser = global_v_coduser,
                 codcreate = global_v_coduser
          where  rowid = r_ttemlog2.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog2
            (codempid,dteedit,numpage,numseq,fldedit,codcomp,
             typkey,fldkey,codseq,dteseq,
             desold,desnew,flgenc,codtable,codcreate,coduser,
             flgdata)
          values
            (p_codempid_query,sysdate,p_numpage,p_numseq,upper(p_fldedit),work_codcomp,
             p_typkey,p_fldkey,p_codseq,p_dteseq,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),global_v_coduser,global_v_coduser,
             p_flgdata);
        end if;
--      end if;
    end if;
  end; -- end upd_log2
  --
  procedure upd_log3
    (p_codtable	  in varchar2,
     p_numpage 	  in varchar2,
     p_typdeduct 	in varchar2,
     p_coddeduct 	in varchar2,
     p_desold 	  in varchar2,
     p_desnew 	  in varchar2,
     p_upd	      in out boolean) is

    v_exist		boolean := false;

  cursor c_ttemlog3 is
    select rowid
    from   ttemlog3
    where  codempid  = p_codempid_query
    and		 dteedit	 = sysdate
    and		 numpage	 = p_numpage
    and    typdeduct = p_typdeduct
    and    coddeduct = p_coddeduct;
  begin
    if check_emp_status = 'INSERT' then
      p_upd := true; --Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog3 in c_ttemlog3 loop
          v_exist := true;
          update ttemlog3
          set    codcomp = work_codcomp,
                 desold = p_desold,
                 desnew = p_desnew,
                 codtable = upper(p_codtable),
                 codcreate = global_v_coduser,
                 coduser = global_v_coduser
          where  rowid = r_ttemlog3.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog3
            (codempid,dteedit,numpage,typdeduct,coddeduct,
             codcomp,desold,desnew,codtable,codcreate,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,p_typdeduct,p_coddeduct,
             work_codcomp,p_desold,p_desnew,upper(p_codtable),global_v_coduser,global_v_coduser);
        end if;
--      end if;
    end if;
  end; -- end upd_log3
  --
  procedure save_temploy1 is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_updname			boolean := false;
    v_numseq			number;
    v_name				boolean;

    v_qtydatrq    temploy1.qtydatrq%type;
    v_namempe 		temploy1.namempe%type;
    v_namempt 		temploy1.namempt%type;
    v_namemp3 		temploy1.namemp3%type;
    v_namemp4 		temploy1.namemp4%type;
    v_namemp5 		temploy1.namemp5%type;
    v_namempeo 		temploy1.namempe%type;
    v_namempto 		temploy1.namempt%type;
    v_namemp3o 		temploy1.namemp3%type;
    v_namemp4o 		temploy1.namemp4%type;
    v_namemp5o 		temploy1.namemp5%type;

    v_codtitle    varchar2(100 char);
    v_namfirste   varchar2(100 char);
    v_namfirstt   varchar2(100 char);
    v_namfirst3   varchar2(100 char);
    v_namfirst4   varchar2(100 char);
    v_namfirst5   varchar2(100 char);
    v_namlaste    varchar2(100 char);
    v_namlastt    varchar2(100 char);
    v_namlast3    varchar2(100 char);
    v_namlast4    varchar2(100 char);
    v_namlast5    varchar2(100 char);

    v_dtechg			thisname.dtechg%type;

    cursor c_temploy1 is
      select  codempid,codtitle,namfirste,namfirstt,namfirst3,
              namfirst4,namfirst5,namlaste,namlastt,namlast3,
              namlast4,namlast5,namempe,namempt,namemp3,
              namemp4,namemp5,nickname,nicknamt,nicknam3,
              nicknam4,nicknam5,dteempdb,stamarry,codsex,
              stamilit,dteempmt,dteretire,codcomp,codpos,
              numlvl,staemp,dteeffex,flgatten,codbrlc,
              codempmt,typpayroll,typemp,codcalen,codjob,
              codcompr,codposre,dteeflvl,dteefpos,dteduepr,
              dteoccup,qtydatrq,numtelof,nummobile,email,
              lineid,numreqst,numappl,ocodempid,flgreemp,
              dtereemp,dteredue,qtywkday,codedlv,codmajsb,
              numreqc,codposc,flgreq,stareq,codappr,
              dteappr,staappr,remarkap,codreq,jobgrade,
              dteefstep,codgrpgl,stadisb,numdisab,typdisp,
              dtedisb,dtedisen,desdisp,typtrav,qtylength,
              carlicen,typfuel,codbusno,codbusrt,flgpdpa,
              dtepdpa,rowid
      from    temploy1
      where   codempid    = p_codempid_query;

    cursor c_name is
      select rowid
      from	 thisname
      where	 codempid = p_codempid_query
      and		 dtechg		= trunc(sysdate);
  begin
    v_namempe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',personal_codtitle,'101')))||
                       ltrim(rtrim(personal_namfirste))||' '||ltrim(rtrim(personal_namlaste)),1,60);
    v_namempt	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',personal_codtitle,'102')))||
                       ltrim(rtrim(personal_namfirstt))||' '||ltrim(rtrim(personal_namlastt)),1,60);
    v_namemp3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',personal_codtitle,'103')))||
                       ltrim(rtrim(personal_namfirst3))||' '||ltrim(rtrim(personal_namlast3)),1,60);
    v_namemp4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',personal_codtitle,'104')))||
                       ltrim(rtrim(personal_namfirst4))||' '||ltrim(rtrim(personal_namlast4)),1,60);
    v_namemp5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',personal_codtitle,'105')))||
                       ltrim(rtrim(personal_namfirst5))||' '||ltrim(rtrim(personal_namlast5)),1,60);
    v_numseq := 0;
    for i in c_temploy1 loop
      v_codtitle    := i.codtitle;
      v_namfirste   := i.namfirste;
      v_namfirstt   := i.namfirstt;
      v_namfirst3   := i.namfirst3;
      v_namfirst4   := i.namfirst4;
      v_namfirst5   := i.namfirst5;
      v_namlaste    := i.namlaste;
      v_namlastt    := i.namlastt;
      v_namlast3    := i.namlast3;
      v_namlast4    := i.namlast4;
      v_namlast5    := i.namlast5;
      p_o_staemp    := i.staemp;
      v_exist       := true;
      v_qtydatrq    := nvl(work_yredatrq,0)*12 + nvl(work_mthdatrq,0);
      upd_log1('temploy1','11','codtitle','C',i.codtitle,personal_codtitle,'N',v_upd);
      upd_log1('temploy1','11','namfirste','C',i.namfirste,personal_namfirste,'N',v_upd);
      upd_log1('temploy1','11','namfirstt','C',i.namfirstt,personal_namfirstt,'N',v_upd);
      upd_log1('temploy1','11','namfirst3','C',i.namfirst3,personal_namfirst3,'N',v_upd);
      upd_log1('temploy1','11','namfirst4','C',i.namfirst4,personal_namfirst4,'N',v_upd);
      upd_log1('temploy1','11','namfirst5','C',i.namfirst5,personal_namfirst5,'N',v_upd);
      upd_log1('temploy1','11','namlaste','C',i.namlaste,personal_namlaste,'N',v_upd);
      upd_log1('temploy1','11','namlastt','C',i.namlastt,personal_namlastt,'N',v_upd);
      upd_log1('temploy1','11','namlast3','C',i.namlast3,personal_namlast3,'N',v_upd);
      upd_log1('temploy1','11','namlast4','C',i.namlast4,personal_namlast4,'N',v_upd);
      upd_log1('temploy1','11','namlast5','C',i.namlast5,personal_namlast5,'N',v_upd);
--      if 	:parameter.codapp = 'RECRUIT'  then
--        update tapplinf
--        set    dteempmt = work_dteempmt
--        where numappl   = :tab2.numappl ;
--      end if;
      if v_upd then
        v_namempeo	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',i.codtitle,'101')))||' '||
                           ltrim(rtrim(i.namfirste))||' '||ltrim(rtrim(i.namlaste)),1,60);
        v_namempto	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',i.codtitle,'102')))||' '||
                           ltrim(rtrim(i.namfirstt))||' '||ltrim(rtrim(i.namlastt)),1,60);
        v_namemp3o	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',i.codtitle,'103')))||' '||
                           ltrim(rtrim(i.namfirst3))||' '||ltrim(rtrim(i.namlast3)),1,60);
        v_namemp4o	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',i.codtitle,'104')))||' '||
                           ltrim(rtrim(i.namfirst4))||' '||ltrim(rtrim(i.namlast4)),1,60);
        v_namemp5o	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',i.codtitle,'105')))||' '||
                           ltrim(rtrim(i.namfirst5))||' '||ltrim(rtrim(i.namlast5)),1,60);
        v_updname   := true;

        v_numseq  := hisname_tab.count;
        v_numseq  := v_numseq + 1;
        v_dtechg  := trunc(sysdate);
        upd_log2('thisname','18',v_numseq,'codtitle','D','dtechg',null,v_dtechg,'C',i.codtitle,personal_codtitle,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namfirste','D','dtechg',null,v_dtechg,'C',i.namfirste,personal_namfirste,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namfirstt','D','dtechg',null,v_dtechg,'C',i.namfirstt,personal_namfirstt,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namfirst3','D','dtechg',null,v_dtechg,'C',i.namfirst3,personal_namfirst3,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namfirst4','D','dtechg',null,v_dtechg,'C',i.namfirst4,personal_namfirst4,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namfirst5','D','dtechg',null,v_dtechg,'C',i.namfirst5,personal_namfirst5,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namlaste','D','dtechg',null,v_dtechg,'C',i.namlaste,personal_namlaste,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namlastt','D','dtechg',null,v_dtechg,'C',i.namlastt,personal_namlastt,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namlast3','D','dtechg',null,v_dtechg,'C',i.namlast3,personal_namlast3,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namlast4','D','dtechg',null,v_dtechg,'C',i.namlast4,personal_namlast4,'N',v_name);
        upd_log2('thisname','18',v_numseq,'namlast5','D','dtechg',null,v_dtechg,'C',i.namlast5,personal_namlast5,'N',v_name);
      end if;
      upd_log1('temploy1','11','nickname','C',i.nickname,personal_nickname,'N',v_upd);
      upd_log1('temploy1','11','nicknamt','C',i.nicknamt,personal_nicknamt,'N',v_upd);
      upd_log1('temploy1','11','nicknam3','C',i.nicknam3,personal_nicknam3,'N',v_upd);
      upd_log1('temploy1','11','nicknam4','C',i.nicknam4,personal_nicknam4,'N',v_upd);
      upd_log1('temploy1','11','nicknam5','C',i.nicknam5,personal_nicknam5,'N',v_upd);
      upd_log1('temploy1','11','nummobile','C',i.nummobile,personal_nummobile,'N',v_upd);
      upd_log1('temploy1','11','lineid','C',i.lineid,personal_lineid,'N',v_upd);
      upd_log1('temploy1','11','dteempdb','D',to_char(i.dteempdb,'dd/mm/yyyy'),to_char(personal_dteempdb,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','11','codsex','C',i.codsex,personal_codsex,'N',v_upd);
      upd_log1('temploy1','11','stamarry','C',i.stamarry,personal_stamarry,'N',v_upd);
      upd_log1('temploy1','11','stamilit','C',i.stamilit,personal_stamilit,'N',v_upd);
      upd_log1('temploy1','11','numappl','C',i.numappl,personal_numappl,'N',v_upd);
      upd_log1('temploy1','11','dteretire','D',to_char(i.dteretire,'dd/mm/yyyy'),to_char(personal_dteretire,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','dteempmt','D',to_char(i.dteempmt,'dd/mm/yyyy'),to_char(work_dteempmt,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','staemp','C',i.staemp,work_staemp,'N',v_upd);
      upd_log1('temploy1','13','dteeffex','D',to_char(i.dteeffex,'dd/mm/yyyy'),to_char(work_dteeffex,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','codcomp','C',i.codcomp,work_codcomp,'N',v_upd);
      upd_log1('temploy1','13','codpos','C',i.codpos,work_codpos,'N',v_upd);
      upd_log1('temploy1','13','dteefpos','D',to_char(i.dteefpos,'dd/mm/yyyy'),to_char(work_dteefpos,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','numlvl','C',i.numlvl,work_numlvl,'N',v_upd);
      upd_log1('temploy1','13','dteeflvl','D',to_char(i.dteeflvl,'dd/mm/yyyy'),to_char(work_dteeflvl,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','codbrlc','C',i.codbrlc,work_codbrlc,'N',v_upd);
      upd_log1('temploy1','13','codempmt','C',i.codempmt,work_codempmt,'N',v_upd);
      upd_log1('temploy1','13','typpayroll','C',i.typpayroll,work_typpayroll,'N',v_upd);
      upd_log1('temploy1','13','typemp','C',i.typemp,work_typemp,'N',v_upd);
      upd_log1('temploy1','13','codcalen','C',i.codcalen,work_codcalen,'N',v_upd);
      upd_log1('temploy1','13','flgatten','C',i.flgatten,work_flgatten,'N',v_upd);
      upd_log1('temploy1','13','codjob','C',i.codjob,work_codjob,'N',v_upd);
      upd_log1('temploy1','13','jobgrade','C',i.jobgrade,work_jobgrade,'N',v_upd);
      upd_log1('temploy1','13','dteefstep','D',to_char(i.dteefstep,'dd/mm/yyyy'),to_char(work_dteefstep,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','codgrpgl','C',i.codgrpgl,work_codgrpgl,'N',v_upd);
      upd_log1('temploy1','13','stadisb','C',i.stadisb,work_stadisb,'N',v_upd);
      upd_log1('temploy1','13','numdisab','C',i.numdisab,work_numdisab,'N',v_upd);
      upd_log1('temploy1','13','dtedisb','D',to_char(i.dtedisb,'dd/mm/yyyy'),to_char(work_dtedisb,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','dtedisen','D',to_char(i.dtedisen,'dd/mm/yyyy'),to_char(work_dtedisen,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','typdisp','C',i.typdisp,work_typdisp,'N',v_upd);
      upd_log1('temploy1','13','desdisp','C',i.desdisp,work_desdisp,'N',v_upd);
      upd_log1('temploy1','13','dteduepr','D',to_char(i.dteduepr,'dd/mm/yyyy'),to_char(work_dteduepr,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','yredatrq','C',i.qtydatrq,v_qtydatrq,'N',v_upd);
      upd_log1('temploy1','13','dteoccup','D',to_char(i.dteoccup,'dd/mm/yyyy'),to_char(work_dteoccup,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','numtelof','C',i.numtelof,work_numtelof,'N',v_upd);
      upd_log1('temploy1','13','email','C',i.email,work_email,'N',v_upd);
      upd_log1('temploy1','13','numreqst','C',i.numreqst,work_numreqst,'N',v_upd);
      upd_log1('temploy1','13','ocodempid','C',i.ocodempid,work_ocodempid,'N',v_upd);
      upd_log1('temploy1','13','dtereemp','D',to_char(i.dtereemp,'dd/mm/yyyy'),to_char(work_dtereemp,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','dteredue','D',to_char(i.dteredue,'dd/mm/yyyy'),to_char(work_dteredue,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy1','13','flgpdpa','C',i.flgpdpa,work_flgpdpa,'N',v_upd);
      upd_log1('temploy1','13','dtepdpa','D',to_char(i.dtepdpa,'dd/mm/yyyy'),to_char(work_dtepdpa,'dd/mm/yyyy'),'N',v_upd);

      upd_log1('temploy1','14','typtrav','C',i.typtrav,travel_typtrav,'N',v_upd);
      upd_log1('temploy1','14','carlicen','C',i.carlicen,travel_carlicen,'N',v_upd);
      upd_log1('temploy1','14','typfuel','C',i.typfuel,travel_typfuel,'N',v_upd);
      upd_log1('temploy1','14','qtylength','C',i.qtylength,travel_qtylength,'N',v_upd);
      upd_log1('temploy1','14','codbusno','C',i.codbusno,travel_codbusno,'N',v_upd);
      upd_log1('temploy1','14','codbusrt','C',i.codbusrt,travel_codbusrt,'N',v_upd);
      if v_upd then
        update  temploy1
        set     codtitle          = personal_codtitle,
                namfirste         = personal_namfirste,
                namfirstt         = personal_namfirstt,
                namfirst3         = personal_namfirst3,
                namfirst4         = personal_namfirst4,
                namfirst5         = personal_namfirst5,
                namlaste          = personal_namlaste,
                namlastt          = personal_namlastt,
                namlast3          = personal_namlast3,
                namlast4          = personal_namlast4,
                namlast5          = personal_namlast5,
                namempe           = v_namempe,
                namempt           = v_namempt,
                namemp3           = v_namemp3,
                namemp4           = v_namemp4,
                namemp5           = v_namemp5,
                nickname          = personal_nickname,
                nicknamt          = personal_nicknamt,
                nicknam3          = personal_nicknam3,
                nicknam4          = personal_nicknam4,
                nicknam5          = personal_nicknam5,
                nummobile         = personal_nummobile,
                lineid            = personal_lineid,
                dteempdb          = personal_dteempdb,
                codsex            = personal_codsex,
                stamarry          = personal_stamarry,
                stamilit          = personal_stamilit,
                numappl           = nvl(trim(personal_numappl),p_codempid_query),
                dteretire         = personal_dteretire,
                dteempmt          = work_dteempmt,
                staemp            = work_staemp,
                dteeffex          = work_dteeffex,
                codcomp           = work_codcomp,
                codpos            = work_codpos,
                dteefpos          = work_dteefpos,
                numlvl            = work_numlvl,
                dteeflvl          = work_dteeflvl,
                codbrlc           = work_codbrlc,
                codempmt          = work_codempmt,
                typpayroll        = work_typpayroll,
                typemp            = work_typemp,
                codcalen          = work_codcalen,
                flgatten          = work_flgatten,
                codjob            = work_codjob,
                jobgrade          = work_jobgrade,
                dteefstep         = work_dteefstep,
                codgrpgl          = work_codgrpgl,
                stadisb           = work_stadisb,
                numdisab          = work_numdisab,
                dtedisb           = work_dtedisb,
                dtedisen          = work_dtedisen,
                typdisp           = work_typdisp,
                desdisp           = work_desdisp,
                dteduepr          = work_dteduepr,
                qtydatrq          = v_qtydatrq,
                dteoccup          = work_dteoccup,
                numtelof          = work_numtelof,
                email             = work_email,
                numreqst          = work_numreqst,
                ocodempid         = work_ocodempid,
                dtereemp          = work_dtereemp,
                dteredue          = work_dteredue,
                typtrav           = travel_typtrav,
                carlicen          = travel_carlicen,
                typfuel           = travel_typfuel,
                qtylength         = travel_qtylength,
                codbusno          = travel_codbusno,
                codbusrt          = travel_codbusrt,
                flgpdpa           = work_flgpdpa,
                dtepdpa           = work_dtepdpa,
                coduser           = global_v_coduser
        where   rowid  = i.rowid;
      end if;
    end loop;
    if not v_exist then
      insert into temploy1(codempid,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                           namlaste,namlastt,namlast3,namlast4,namlast5,nickname,
                           nicknamt,nicknam3,nicknam4,nicknam5,
                           namempe,namempt,namemp3,namemp4,namemp5,nummobile,lineid,
                           dteempdb,codsex,stamarry,stamilit,numappl,dteretire,
                           dteempmt,staemp,dteeffex,codcomp,codpos,dteefpos,
                           numlvl,dteeflvl,codbrlc,codempmt,typpayroll,typemp,
                           codcalen,flgatten,codjob,jobgrade,dteefstep,codgrpgl,
                           stadisb,numdisab,dtedisb,dtedisen,typdisp,desdisp,
                           dteduepr,qtydatrq,dteoccup,numtelof,email,numreqst,
                           ocodempid,dtereemp,dteredue,typtrav,carlicen,typfuel,
                           qtylength,codbusno,codbusrt,flgpdpa,dtepdpa,coduser,codcreate)
                   values (p_codempid_query,personal_codtitle,personal_namfirste,personal_namfirstt,personal_namfirst3,personal_namfirst4,personal_namfirst5,
                           personal_namlaste,personal_namlastt,personal_namlast3,personal_namlast4,personal_namlast5,personal_nickname,
                           personal_nicknamt,personal_nicknam3,personal_nicknam4,personal_nicknam5,
                           v_namempe,v_namempt,v_namemp3,v_namemp4,v_namemp5,personal_nummobile,personal_lineid,
                           personal_dteempdb,personal_codsex,personal_stamarry,personal_stamilit,nvl(trim(personal_numappl),p_codempid_query),personal_dteretire,
                           work_dteempmt,work_staemp,work_dteeffex,work_codcomp,work_codpos,work_dteefpos,
                           work_numlvl,work_dteeflvl,work_codbrlc,work_codempmt,work_typpayroll,work_typemp,
                           work_codcalen,work_flgatten,work_codjob,work_jobgrade,work_dteefstep,work_codgrpgl,
                           work_stadisb,work_numdisab,work_dtedisb,work_dtedisen,work_typdisp,work_desdisp,
                           work_dteduepr,v_qtydatrq,work_dteoccup,work_numtelof,work_email,work_numreqst,
                           work_ocodempid,work_dtereemp,work_dteredue,travel_typtrav,travel_carlicen,travel_typfuel,
                           travel_qtylength,travel_codbusno,travel_codbusrt,work_flgpdpa,work_dtepdpa,global_v_coduser,global_v_coduser);
    end if;
    if v_updname then
      v_name := false;
      for r_name in c_name loop
        v_name := true;
        update thisname
          set codtitle  = v_codtitle,    namfirste   = v_namfirste,
              namfirstt = v_namfirstt,   namfirst3   = v_namfirst3,
              namfirst4 = v_namfirst4,   namfirst5   = v_namfirst5,
              namlaste  = v_namlaste,    namlastt 	 = v_namlastt,
              namlast3  = v_namlast3,    namlast4 	 = v_namlast4,
              namlast5  = v_namlast5,    namempe     = v_namempeo,
              namempt   = v_namempto,	   namemp3	   = v_namemp3o,
              namemp4   = v_namemp4o,	   namemp5     = v_namemp5o,
              dteupd	= trunc(sysdate),
              coduser	= global_v_coduser
          where rowid = r_name.rowid;
      end loop;
      if not v_name then
        insert into thisname
          (codempid,dtechg,codtitle,
           namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
           namlaste,namlastt,namlast3,namlast4,namlast5,
           namempe,namempt,namemp3,namemp4,namemp5,
           codcreate,coduser)
        values
          (p_codempid_query,trunc(sysdate),v_codtitle,
           v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,
           v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,
           v_namempeo,v_namempto,v_namemp3o,v_namemp4o,v_namemp5o,
           global_v_coduser,global_v_coduser);
      end if;
    end if;
  end; -- end save_temploy1
  --
  procedure save_temploy2 is
    v_exist				boolean := false;
    v_upd					boolean := false;
    cursor c_temploy2 is
      select  codempid,adrrege,adrregt,adrreg3,adrreg4,
              adrreg5,codsubdistr,coddistr,codprovr,codcntyr,
              codpostr,adrconte,adrcontt,adrcont3,adrcont4,
              adrcont5,codsubdistc,coddistc,codprovc,codcntyc,
              codpostc,numtelec,codblood,weight,high,
              codrelgn,codorgin,codnatnl,coddomcl,numoffid,
              adrissue,codprovi,dteoffid,codclnsc,numlicid,
              dtelicid,numpasid,dtepasid,numvisa,dtevisaexp,
              numprmid,dteprmst,dteprmen,rowid
      from    temploy2
      where   codempid    = p_codempid_query;
  begin
    for i in c_temploy2 loop
      v_exist := true;
--      if global_v_lang = '101' then
--        personal_adrrege   := personal_adrreg;
--        personal_adrconte  := personal_adrcont;
--      elsif global_v_lang = '102' then
--        personal_adrregt   := personal_adrreg;
--        personal_adrcontt  := personal_adrcont;
--      elsif global_v_lang = '103' then
--        personal_adrreg3   := personal_adrreg;
--        personal_adrcont3  := personal_adrcont;
--      elsif global_v_lang = '104' then
--        personal_adrreg4   := personal_adrreg;
--        personal_adrcont4  := personal_adrcont;
--      elsif global_v_lang = '105' then
--        personal_adrreg5   := personal_adrreg;
--        personal_adrcont5  := personal_adrcont;
--      end if;
      upd_log1('temploy2','11','numtelec','C',i.numtelec,personal_numtelec,'N',v_upd);
      upd_log1('temploy2','11','numoffid','C',i.numoffid,personal_numoffid,'N',v_upd);
      upd_log1('temploy2','11','dteoffid','D',to_char(i.dteoffid,'dd/mm/yyyy'),to_char(personal_dteoffid,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','11','adrissue','C',i.adrissue,personal_adrissue,'N',v_upd);
      upd_log1('temploy2','11','codprovi','C',i.codprovi,personal_codprovi,'N',v_upd);
      upd_log1('temploy2','11','codclnsc','C',i.codclnsc,personal_codclnsc,'N',v_upd);
      upd_log1('temploy2','11','numpasid','C',i.numpasid,personal_numpasid,'N',v_upd);
      upd_log1('temploy2','11','dtepasid','D',to_char(i.dtepasid,'dd/mm/yyyy'),to_char(personal_dtepasid,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','11','numvisa','C',i.numvisa,personal_numvisa,'N',v_upd);
      upd_log1('temploy2','11','dtevisaexp','D',to_char(i.dtevisaexp,'dd/mm/yyyy'),to_char(personal_dtevisaexp,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','11','numlicid','C',i.numlicid,personal_numlicid,'N',v_upd);
      upd_log1('temploy2','11','dtelicid','D',to_char(i.dtelicid,'dd/mm/yyyy'),to_char(personal_dtelicid,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','11','coddomcl','C',i.coddomcl,personal_coddomcl,'N',v_upd);
      upd_log1('temploy2','11','weight','N',i.weight,personal_weight,'N',v_upd);
      upd_log1('temploy2','11','high','N',i.high,personal_high,'N',v_upd);
      upd_log1('temploy2','11','codblood','C',i.codblood,personal_codblood,'N',v_upd);
      upd_log1('temploy2','11','codorgin','C',i.codorgin,personal_codorgin,'N',v_upd);
      upd_log1('temploy2','11','codnatnl','C',i.codnatnl,personal_codnatnl,'N',v_upd);
      upd_log1('temploy2','11','codrelgn','C',i.codrelgn,personal_codrelgn,'N',v_upd);
      upd_log1('temploy2','11','numprmid','C',i.numprmid,personal_numprmid,'N',v_upd);
      upd_log1('temploy2','11','dteprmst','D',to_char(i.dteprmst,'dd/mm/yyyy'),to_char(personal_dteprmst,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','11','dteprmen','D',to_char(i.dteprmen,'dd/mm/yyyy'),to_char(personal_dteprmen,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy2','12','adrrege','C',i.adrrege,address_adrrege,'N',v_upd);
      upd_log1('temploy2','12','adrregt','C',i.adrregt,address_adrregt,'N',v_upd);
      upd_log1('temploy2','12','adrreg3','C',i.adrreg3,address_adrreg3,'N',v_upd);
      upd_log1('temploy2','12','adrreg4','C',i.adrreg4,address_adrreg4,'N',v_upd);
      upd_log1('temploy2','12','adrreg5','C',i.adrreg5,address_adrreg5,'N',v_upd);
      upd_log1('temploy2','12','codprovr','C',i.codprovr,address_codprovr,'N',v_upd);
      upd_log1('temploy2','12','coddistr','C',i.coddistr,address_coddistr,'N',v_upd);
      upd_log1('temploy2','12','codsubdistr','C',i.codsubdistr,address_codsubdistr,'N',v_upd);
      upd_log1('temploy2','12','codcntyr','C',i.codcntyr,address_codcntyr,'N',v_upd);
      upd_log1('temploy2','12','codpostr','C',i.codpostr,address_codpostr,'N',v_upd);
      upd_log1('temploy2','12','adrconte','C',i.adrconte,address_adrconte,'N',v_upd);
      upd_log1('temploy2','12','adrcontt','C',i.adrcontt,address_adrcontt,'N',v_upd);
      upd_log1('temploy2','12','adrcont3','C',i.adrcont3,address_adrcont3,'N',v_upd);
      upd_log1('temploy2','12','adrcont4','C',i.adrcont4,address_adrcont4,'N',v_upd);
      upd_log1('temploy2','12','adrcont5','C',i.adrcont5,address_adrcont5,'N',v_upd);
      upd_log1('temploy2','12','codprovc','C',i.codprovc,address_codprovc,'N',v_upd);
      upd_log1('temploy2','12','coddistc','C',i.coddistc,address_coddistc,'N',v_upd);
      upd_log1('temploy2','12','codsubdistc','C',i.codsubdistc,address_codsubdistc,'N',v_upd);
      upd_log1('temploy2','12','codcntyc','C',i.codcntyc,address_codcntyc,'N',v_upd);
      upd_log1('temploy2','12','codpostc','C',i.codpostc,address_codpostc,'N',v_upd);
      if v_upd then
        update  temploy2
        set     numtelec      = personal_numtelec,
                numoffid      = personal_numoffid,
                dteoffid      = personal_dteoffid,
                adrissue      = personal_adrissue,
                codprovi      = personal_codprovi,
                codclnsc      = personal_codclnsc,
                numpasid      = personal_numpasid,
                dtepasid      = personal_dtepasid,
                numvisa       = personal_numvisa,
                dtevisaexp    = personal_dtevisaexp,
                numlicid      = personal_numlicid,
                dtelicid      = personal_dtelicid,
                coddomcl      = personal_coddomcl,
                weight        = personal_weight,
                high          = personal_high,
                codblood      = personal_codblood,
                codorgin      = personal_codorgin,
                codnatnl      = personal_codnatnl,
                codrelgn      = personal_codrelgn,
                numprmid      = personal_numprmid,
                dteprmst      = personal_dteprmst,
                dteprmen      = personal_dteprmen,
                adrrege       = address_adrrege,
                adrregt       = address_adrregt,
                adrreg3       = address_adrreg3,
                adrreg4       = address_adrreg4,
                adrreg5       = address_adrreg5,
                codprovr      = address_codprovr,
                coddistr      = address_coddistr,
                codsubdistr   = address_codsubdistr,
                codcntyr      = address_codcntyr,
                codpostr      = address_codpostr,
                adrconte      = address_adrconte,
                adrcontt      = address_adrcontt,
                adrcont3      = address_adrcont3,
                adrcont4      = address_adrcont4,
                adrcont5      = address_adrcont5,
                codprovc      = address_codprovc,
                coddistc      = address_coddistc,
                codsubdistc   = address_codsubdistc,
                codcntyc      = address_codcntyc,
                codpostc      = address_codpostc,
                coduser       = global_v_coduser
        where   rowid         = i.rowid;
      end if;
    end loop;
    if not v_exist then
      insert into temploy2(codempid,numtelec,numoffid,dteoffid,adrissue,codprovi,codclnsc,
                           numpasid,dtepasid,numvisa,dtevisaexp,numlicid,dtelicid,
                           coddomcl,weight,high,codblood,codorgin,codnatnl,
                           codrelgn,numprmid,dteprmst,dteprmen,adrrege,adrregt,
                           adrreg3,adrreg4,adrreg5,codprovr,coddistr,codsubdistr,
                           codcntyr,codpostr,adrconte,adrcontt,adrcont3,adrcont4,
                           adrcont5,codprovc,coddistc,codsubdistc,codcntyc,codpostc,
                           coduser,codcreate)
                   values (p_codempid_query,personal_numtelec,personal_numoffid,personal_dteoffid,personal_adrissue,personal_codprovi,personal_codclnsc,
                           personal_numpasid,personal_dtepasid,personal_numvisa,personal_dtevisaexp,personal_numlicid,personal_dtelicid,
                           personal_coddomcl,personal_weight,personal_high,personal_codblood,personal_codorgin,personal_codnatnl,
                           personal_codrelgn,personal_numprmid,personal_dteprmst,personal_dteprmen,address_adrrege,address_adrregt,
                           address_adrreg3,address_adrreg4,address_adrreg5,address_codprovr,address_coddistr,address_codsubdistr,
                           address_codcntyr,address_codpostr,address_adrconte,address_adrcontt,address_adrcont3,address_adrcont4,
                           address_adrcont5,address_codprovc,address_coddistc,address_codsubdistc,address_codcntyc,address_codpostc,
                           global_v_coduser,global_v_coduser);
    end if;
  end; -- end save_temploy2
  --
  procedure save_temploy3 is
    v_exist				boolean := false;
    v_upd					boolean := false;

    cursor c_temploy3 is
      select  codcurr,amtincom1,amtincom2,amtincom3,amtincom4,
              amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
              amtothr,amtday,numtaxid,numsaid,flgtax,typincom,
              typtax,dteyrrelf,dteyrrelt,amtrelas,amttaxrel,codbank,
              numbank,numbrnch,amtbank,amttranb,codbank2,numbank2,
              numbrnch2,qtychldb,qtychlda,qtychldd,qtychldi,dtebf,amtincbf,amttaxbf,
              amtpf,amtsaid,dtebfsp,amtincsp,amttaxsp,
              amtsasp,amtpfsp,flgslip,rowid
      from    temploy3
      where   codempid    = p_codempid_query;
  begin
    p_amtincom1 := stdenc(nvl(income_table(1).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom2 := stdenc(nvl(income_table(2).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom3 := stdenc(nvl(income_table(3).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom4 := stdenc(nvl(income_table(4).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom5 := stdenc(nvl(income_table(5).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom6 := stdenc(nvl(income_table(6).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom7 := stdenc(nvl(income_table(7).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom8 := stdenc(nvl(income_table(8).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom9 := stdenc(nvl(income_table(9).amtincom,0),p_codempid_query,global_v_chken);
    p_amtincom10 := stdenc(nvl(income_table(10).amtincom,0),p_codempid_query,global_v_chken);
    p_amtothr   := stdenc(round(nvl(income_amtothr,0),2),p_codempid_query,global_v_chken);
    p_amtday    := stdenc(round(nvl(income_amtday,0),2),p_codempid_query,global_v_chken);
    p_amtincbf  := stdenc(nvl(over_income_amtincbf,0),p_codempid_query,global_v_chken);
    p_amttaxbf  := stdenc(nvl(over_income_amttaxbf,0),p_codempid_query,global_v_chken);
    p_amtpf     := stdenc(nvl(over_income_amtpf,0),p_codempid_query,global_v_chken);
    p_amtsaid   := stdenc(nvl(over_income_amtsaid,0),p_codempid_query,global_v_chken);
    p_amtincsp  := stdenc(nvl(sp_over_income_amtincsp,0),p_codempid_query,global_v_chken);
    p_amttaxsp  := stdenc(nvl(sp_over_income_amttaxsp,0),p_codempid_query,global_v_chken);
    p_amtpfsp   := stdenc(nvl(sp_over_income_amtpfsp,0),p_codempid_query,global_v_chken);
    p_amtsasp   := stdenc(nvl(sp_over_income_amtsasp,0),p_codempid_query,global_v_chken);
    p_amtrelas  := stdenc(nvl(tax_detail_amtrelas,0),p_codempid_query,global_v_chken);
    p_amttaxrel := stdenc(nvl(tax_detail_amttaxrel,0),p_codempid_query,global_v_chken);
    tax_detail_amttranb := stdenc(nvl(tax_detail_amttranb,0),p_codempid_query,global_v_chken); --user18 05/02/2021
    for i in c_temploy3 loop
      v_exist := true;
      upd_log1('temploy3','15','codcurr','C',i.codcurr,income_codcurr,'N',v_upd);
--      upd_log1('temploy3','15','afpro','C',i.afpro,income_,'N',v_upd);
      upd_log1('temploy3','15','amtincom1','C',i.amtincom1,p_amtincom1,'Y',v_upd);
      upd_log1('temploy3','15','amtincom2','C',i.amtincom2,p_amtincom2,'Y',v_upd);
      upd_log1('temploy3','15','amtincom3','C',i.amtincom3,p_amtincom3,'Y',v_upd);
      upd_log1('temploy3','15','amtincom4','C',i.amtincom4,p_amtincom4,'Y',v_upd);
      upd_log1('temploy3','15','amtincom5','C',i.amtincom5,p_amtincom5,'Y',v_upd);
      upd_log1('temploy3','15','amtincom6','C',i.amtincom6,p_amtincom6,'Y',v_upd);
      upd_log1('temploy3','15','amtincom7','C',i.amtincom7,p_amtincom7,'Y',v_upd);
      upd_log1('temploy3','15','amtincom8','C',i.amtincom8,p_amtincom8,'Y',v_upd);
      upd_log1('temploy3','15','amtincom9','C',i.amtincom9,p_amtincom9,'Y',v_upd);
      upd_log1('temploy3','15','amtincom10','C',i.amtincom10,p_amtincom10,'Y',v_upd);
      upd_log1('temploy3','15','amtothr','C',i.amtothr,p_amtothr,'Y',v_upd);
      upd_log1('temploy3','15','amtday','C',i.amtday,p_amtday,'Y',v_upd);
      upd_log1('temploy3','161','numtaxid','C',i.numtaxid,tax_detail_numtaxid,'N',v_upd);
      upd_log1('temploy3','161','numsaid','C',i.numsaid,tax_detail_numsaid,'N',v_upd);
--      upd_log1('temploy3','161','frsmemb','C',i.frsmemb,tax_detail_frsmemb,'N',v_upd);
      upd_log1('temploy3','161','flgtax','C',i.flgtax,tax_detail_flgtax,'N',v_upd);
      upd_log1('temploy3','161','typtax','C',i.typtax,tax_detail_typtax,'N',v_upd);
      upd_log1('temploy3','161','typincom','C',i.typincom,tax_detail_typincom,'N',v_upd);
      upd_log1('temploy3','161','dteyrrelf','N',i.dteyrrelf,tax_detail_dteyrrelf,'N',v_upd);
      upd_log1('temploy3','161','dteyrrelt','N',i.dteyrrelt,tax_detail_dteyrrelt,'N',v_upd);
      upd_log1('temploy3','161','amtrelas','C',i.amtrelas,p_amtrelas,'Y',v_upd);
      upd_log1('temploy3','161','amttaxrel','C',i.amttaxrel,p_amttaxrel,'Y',v_upd);
      upd_log1('temploy3','161','codbank','C',i.codbank,tax_detail_codbank,'N',v_upd);
      upd_log1('temploy3','161','numbank','N',i.numbank,tax_detail_numbank,'N',v_upd);
      upd_log1('temploy3','161','numbrnch','C',i.numbrnch,tax_detail_numbrnch,'N',v_upd);
      upd_log1('temploy3','161','amtbank','C',i.amtbank,tax_detail_amtbank,'N',v_upd);
      upd_log1('temploy3','161','amttranb','C',i.amttranb,tax_detail_amttranb,'Y',v_upd);
      upd_log1('temploy3','161','codbank2','C',i.codbank2,tax_detail_codbank2,'N',v_upd);
      upd_log1('temploy3','161','numbank2','C',i.numbank2,tax_detail_numbank2,'N',v_upd);
      upd_log1('temploy3','161','numbrnch2','C',i.numbrnch2,tax_detail_numbrnch2,'N',v_upd);
      upd_log1('temploy3','161','flgslip','C',i.flgslip,tax_detail_flgslip,'N',v_upd);

      upd_log1('temploy3','164','qtychldb','N',i.qtychldb,tax_detail_qtychldb,'N',v_upd);
      upd_log1('temploy3','164','qtychlda','N',i.qtychlda,tax_detail_qtychlda,'N',v_upd);
      upd_log1('temploy3','164','qtychldd','N',i.qtychldd,tax_detail_qtychldd,'N',v_upd);
      upd_log1('temploy3','164','qtychldi','N',i.qtychldi,tax_detail_qtychldi,'N',v_upd);

      upd_log1('temploy3','162','dtebf','D',to_char(i.dtebf,'dd/mm/yyyy'),to_char(over_income_dtebf,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy3','162','amtincbf','C',i.amtincbf,p_amtincbf,'Y',v_upd);
      upd_log1('temploy3','162','amttaxbf','C',i.amttaxbf,p_amttaxbf,'Y',v_upd);
      upd_log1('temploy3','162','amtpf','C',i.amtpf,p_amtpf,'Y',v_upd);
      upd_log1('temploy3','162','amtsaid','C',i.amtsaid,p_amtsaid,'Y',v_upd);
--      upd_log1('tspouse','171','numtaxid','C',i.numtaxid,:tab71.numtaxid,'N',v_upd);
      upd_log1('temploy3','171','dtebfsp','D',to_char(i.dtebfsp,'dd/mm/yyyy'),to_char(sp_over_income_dtebfsp,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('temploy3','171','amtincsp','C',i.amtincsp,p_amtincsp,'Y',v_upd);
      upd_log1('temploy3','171','amttaxsp','C',i.amttaxsp,p_amttaxsp,'Y',v_upd);
      upd_log1('temploy3','171','amtsasp','C',i.amtsasp,p_amtsasp,'Y',v_upd);
      upd_log1('temploy3','171','amtpfsp','C',i.amtpfsp,p_amtpfsp,'Y',v_upd);

      if v_upd then
        update  temploy3
        set     codcurr         = income_codcurr,
                amtincom1       = p_amtincom1,
                amtincom2       = p_amtincom2,
                amtincom3       = p_amtincom3,
                amtincom4       = p_amtincom4,
                amtincom5       = p_amtincom5,
                amtincom6       = p_amtincom6,
                amtincom7       = p_amtincom7,
                amtincom8       = p_amtincom8,
                amtincom9       = p_amtincom9,
                amtincom10      = p_amtincom10,
                amtothr         = p_amtothr,
                amtday          = p_amtday,
                numtaxid        = tax_detail_numtaxid,
                numsaid         = tax_detail_numsaid,
                flgtax          = tax_detail_flgtax,
                typtax          = tax_detail_typtax,
                typincom        = tax_detail_typincom,
                dteyrrelf       = tax_detail_dteyrrelf,
                dteyrrelt       = tax_detail_dteyrrelt,
                amtrelas        = p_amtrelas,
                amttaxrel       = p_amttaxrel,
                codbank         = tax_detail_codbank,
                numbank         = tax_detail_numbank,
                numbrnch        = tax_detail_numbrnch,
                amtbank         = tax_detail_amtbank,
                amttranb        = tax_detail_amttranb,
                codbank2        = tax_detail_codbank2,
                numbank2        = tax_detail_numbank2,
                numbrnch2       = tax_detail_numbrnch2,
                qtychldb        = tax_detail_qtychldb,
                qtychlda        = tax_detail_qtychlda,
                qtychldd        = tax_detail_qtychldd,
                qtychldi        = tax_detail_qtychldi,
                dtebf           = over_income_dtebf,
                amtincbf        = p_amtincbf,
                amttaxbf        = p_amttaxbf,
                amtpf           = p_amtpf,
                amtsaid         = p_amtsaid,
                dtebfsp         = sp_over_income_dtebfsp,
                amtincsp        = p_amtincsp,
                amttaxsp        = p_amttaxsp,
                amtsasp         = p_amtsasp,
                amtpfsp         = p_amtpfsp,
                flgslip         = tax_detail_flgslip,
                coduser         = global_v_coduser
        where   rowid           = i.rowid;
      end if;
    end loop;
    if not v_exist then
      insert into temploy3(codempid,codcurr,amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,amtothr,
                           amtday,numtaxid,numsaid,flgtax,typtax,typincom,dteyrrelf,
                           dteyrrelt,amtrelas,amttaxrel,codbank,numbank,numbrnch,
                           amtbank,amttranb,codbank2,numbank2,numbrnch2,qtychldb,
                           qtychlda,qtychldd,qtychldi,dtebf,amtincbf,amttaxbf,amtpf,amtsaid,
                           dtebfsp,amtincsp,amttaxsp,amtsasp,amtpfsp,coduser,
                           codcreate,flgslip)
                   values (p_codempid_query,income_codcurr,p_amtincom1,p_amtincom2,p_amtincom3,p_amtincom4,p_amtincom5,
                           p_amtincom6,p_amtincom7,p_amtincom8,p_amtincom9,p_amtincom10,p_amtothr,
                           p_amtday,tax_detail_numtaxid,tax_detail_numsaid,tax_detail_flgtax,tax_detail_typtax,tax_detail_typincom,tax_detail_dteyrrelf,
                           tax_detail_dteyrrelt,p_amtrelas,p_amttaxrel,tax_detail_codbank,tax_detail_numbank,tax_detail_numbrnch,
                           tax_detail_amtbank,tax_detail_amttranb,tax_detail_codbank2,tax_detail_numbank2,tax_detail_numbrnch2,tax_detail_qtychldb,
                           tax_detail_qtychlda,tax_detail_qtychldd,tax_detail_qtychldi,over_income_dtebf,p_amtincbf,p_amttaxbf,p_amtpf,p_amtsaid,
                           sp_over_income_dtebfsp,p_amtincsp,p_amttaxsp,p_amtsasp,p_amtpfsp,global_v_coduser,
                           global_v_coduser,tax_detail_flgslip);
    end if;
  end; -- end save_temploy3
  --
  procedure save_tlastded is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_dteyrepay		number;
    cursor c_tlastded is
      select rowid
      from	 tlastded
      where	 dteyrepay  = v_dteyrepay
      and		 codempid   = p_codempid_query;
  begin
--    if :parameter.codapp in('PMC2','RECRUIT') then
      v_dteyrepay := to_number(to_char(sysdate,'yyyy')) - global_v_zyear;
      if v_upd or not v_exist then
        v_exist := false;
        for i in c_tlastded loop
          v_exist := true;
          update tlastded
            set codcomp  = work_codcomp,
                typtax   = tax_detail_typtax,
                flgtax   = tax_detail_flgtax,
                amtincbf = p_amtincbf,
                amttaxbf = p_amttaxbf,
                amtpf    = p_amtpf,
                amtsaid  = p_amtsaid,
                amtincsp = p_amtincsp,
                amttaxsp = p_amttaxsp,
                amtsasp  = p_amtsasp,
                amtpfsp  = p_amtpfsp,
                stamarry = personal_stamarry,
                coduser  = global_v_coduser,
                dteyrrelf	= tax_detail_dteyrrelf,
                dteyrrelt	= tax_detail_dteyrrelt,
                amtrelas	= p_amtrelas,
                amttaxrel	= p_amttaxrel
            where rowid = i.rowid;
        end loop;
        if not v_exist then
          insert into tlastded
            (dteyrepay,codempid,codcomp,
             typtax,flgtax,stamarry,
             amtincbf,amttaxbf,amtpf,amtsaid,
             amtincsp,amttaxsp,amtsasp,amtpfsp,
             dteupd,coduser,
             dteyrrelf,dteyrrelt,amtrelas,amttaxrel)
          values
            (v_dteyrepay,p_codempid_query,work_codcomp,
             tax_detail_typtax,tax_detail_flgtax,personal_stamarry,
             p_amtincbf,p_amttaxbf,p_amtpf,p_amtsaid,
             p_amtincsp,p_amttaxsp,p_amtsasp,p_amtpfsp,
             trunc(sysdate),global_v_coduser,
             tax_detail_dteyrrelf,tax_detail_dteyrrelt,p_amtrelas,p_amttaxrel);
        end if;
      end if;
--    end if;
  end; -- end save_tlastded
  --
  procedure save_ttnewemp is
    v_exist				boolean := false;
    v_upd					boolean := false;
    cursor c_ttnewemp is
      select flgupd, rowid
      from	 ttnewemp
      where	 codempid = p_codempid_query;
  begin
--    if :parameter.codapp in('PMC2','RECRUIT') and work_staemp <> '0' then
    if work_staemp <> '0' then
      v_exist := false;
      for i in c_ttnewemp loop
        v_exist := true;
        if   i.flgupd = 'N'  then
          update ttnewemp
            set	 dteempmt = work_dteempmt,
                 codempmt = work_codempmt,
                 numreqst = work_numreqst,
                 codcomp = work_codcomp,
                 codpos = work_codpos,
                 codjob = work_codjob,
                 jobgrade  = work_jobgrade,
                 codgrpgl  = work_codgrpgl,
                 numlvl = work_numlvl,
                 codbrlc = work_codbrlc,
                 codcalen = work_codcalen,
                 flgatten = work_flgatten,
                 qtydatrq = work_qtydatrq,
                 dteduepr = work_dteduepr,
                 staemp = work_staemp,
                 amtincom1 = p_amtincom1,
                 amtincom2 = p_amtincom2,
                 amtincom3 = p_amtincom3,
                 amtincom4 = p_amtincom4,
                 amtincom5 = p_amtincom5,
                 amtincom6 = p_amtincom6,
                 amtincom7 = p_amtincom7,
                 amtincom8 = p_amtincom8,
                 amtincom9 = p_amtincom9,
                 amtincom10 = p_amtincom10,
                 amtothr = p_amtothr,
--                 codedlv = work_codedlv,
                 typemp = work_typemp,
                 typpayroll = work_typpayroll,
                 codcurr = income_codcurr,
                 coduser = global_v_coduser
            where rowid = i.rowid;
        end if;
      end loop;

--      if not v_exist and (:parameter.codapp = 'RECRUIT' or
--                         (:parameter.codapp = 'PMC2' and  (o_staemp = '0' or o_staemp is null  )) ) then
      if not v_exist and (p_o_staemp = '0' or p_o_staemp is null) then
        insert into ttnewemp
          (codempid,dteempmt,codempmt,numreqst,
           codcomp,codpos,codjob,jobgrade,codgrpgl,numlvl,codbrlc,
           codcalen,flgatten,qtydatrq,dteduepr,staemp,
           amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
           amtothr,flgrp,flgupd,--codedlv,
           typemp,typpayroll,codcurr,coduser)
        values
          (p_codempid_query,work_dteempmt,work_codempmt,work_numreqst,
           work_codcomp,work_codpos,work_codjob,work_jobgrade,work_codgrpgl,work_numlvl,work_codbrlc,
           work_codcalen,work_flgatten,work_qtydatrq,work_dteduepr,work_staemp,
           p_amtincom1,p_amtincom2,p_amtincom3,p_amtincom4,p_amtincom5,
           p_amtincom6,p_amtincom7,p_amtincom8,p_amtincom9,p_amtincom10,
           p_amtothr,'N','N',--work_codedlv,
           work_typemp,work_typpayroll,income_codcurr,global_v_coduser);
      end if;
    end if;
  end; -- end save_ttnewemp
  --
  procedure save_tssmemb is
    v_code      varchar2(100);
    v_upd       boolean;
    v_exist			boolean;
    v_chk				varchar2(100);
    cursor c_tssmemb is
      select frsmemb,rowid
      from	 tssmemb
      where	 codempid = p_codempid_query;
  begin
--    if tax_detail_numsaid is not null and tax_detail_frsmemb is not null then
    if tax_detail_numsaid is not null then
      v_exist := false;	v_upd := false;
      for i in c_tssmemb loop
        v_exist := true;
        upd_log1('tssmemb','161','frsmemb','D',to_char(i.frsmemb,'dd/mm/yyyy'),to_char(tax_detail_frsmemb,'dd/mm/yyyy'),'N',v_upd);
        ---------------------------------------------
        begin
          select		numsaid	into	v_chk
          from			tssmemb
          where			codempid	=	p_codempid_query;
        exception	when	no_data_found then
          v_chk	:= null;
        end;
        if nvl(v_chk,'%$#@') <> tax_detail_numsaid then
          v_upd := true;
        end if;
        ----------------------------------------------
        if v_upd then
          update tssmemb
          set    numsaid = tax_detail_numsaid,
                flgsaid = 'Y',
                frsmemb = tax_detail_frsmemb,
                codcomp = work_codcomp,
                dteupd	 = sysdate,
                coduser = global_v_coduser
          where rowid = i.rowid;
        end if;
      end loop;
      if not v_exist then
        upd_log1('tssmemb','161','frsmemb','D',null,to_char(tax_detail_frsmemb,'dd/mm/yyyy'),'N',v_upd);
        if check_emp_status = 'INSERT' then
          v_upd := true;
        end if;
        if v_upd then
          insert into tssmemb
            (codempid,numsaid,flgsaid,frsmemb,
            codcomp,dteupd,coduser)
          values
            (p_codempid_query,tax_detail_numsaid,'Y',tax_detail_frsmemb,
            work_codcomp,sysdate,global_v_coduser);
        end if;
      end if;
    end if;
    --    if :parameter.codapp in('PMC2','RECRUIT') then
    if tax_detail_numsaid is null and tax_detail_frsmemb is null then
      delete from tssmreq
        where codempid = p_codempid_query
        and 	typereq = '1';
    elsif tax_detail_numsaid is not null and tax_detail_frsmemb is not null then
      begin
        select numsaid into v_code
        from 	tssmreq
        where codempid = p_codempid_query
        and		rownum	 = 1 -- Error No: UFP-550258 Edit by user4 (ORA-01422)
        and 	typereq  = '1';
      exception when no_data_found then
        insert into tssmreq
          (codempid,dtereq,typereq,codcomp,
          stareq,dterec,coduserec,numsaid,
          dteupd,coduser)
        values
          (p_codempid_query,tax_detail_frsmemb,'1',work_codcomp,
          '1',tax_detail_frsmemb,global_v_coduser,tax_detail_numsaid,
          sysdate,global_v_coduser);
      end;
    end if;
--  end if;
  end; -- c_tssmemb
  --
  procedure upd_tempded
    (p_block			in varchar2,
     p_typdeduct 	in varchar2,
     p_typdata		in varchar2, -- E-???????,S-???????
     p_tax        tax_type)
  is
    v_exist			boolean;
    v_upd				boolean;
    v_dteyrepay	number;
    v_coddeduct tempded.coddeduct%type;
    v_amtdeduct varchar2(20);
    v_amtspded  varchar2(20);
    v_key       number;
  cursor c_tempded is
    select amtdeduct,amtspded,rowid
    from	 tempded
    where	 codempid  = p_codempid_query
    and		 coddeduct = v_coddeduct;
  cursor c_tlastempd is
    select rowid
    from	 tlastempd
    where	 dteyrepay = v_dteyrepay
    and		 codempid  = p_codempid_query
    and    coddeduct = v_coddeduct;
  begin
    v_key := p_tax.first;
    while v_key is not null loop
      if p_tax(v_key).coddeduct is not null then
        v_dteyrepay     := to_number(to_char(sysdate,'yyyy')) - global_v_zyear;
        v_coddeduct     := p_tax(v_key).coddeduct;
        v_amtdeduct     := stdenc(0,p_codempid_query,global_v_chken);
        v_amtspded      := stdenc(0,p_codempid_query,global_v_chken);

        if p_typdata = 'E' then
          v_amtdeduct   := stdenc(p_tax(v_key).amtdeduct,p_codempid_query,global_v_chken);
        else
          v_amtspded    := stdenc(p_tax(v_key).amtdeduct,p_codempid_query,global_v_chken);
        end if;

        v_exist := false;	v_upd := false;
        for i in c_tempded loop
          v_exist := true;
          if p_typdata = 'E' then
            upd_log3('tempded',p_block,p_typdeduct,v_coddeduct,i.amtdeduct,v_amtdeduct,v_upd);
            v_amtspded := i.amtspded;
          else
            upd_log3('tempded',p_block,p_typdeduct,v_coddeduct,i.amtspded,v_amtspded,v_upd);
            v_amtdeduct := i.amtdeduct;
          end if;
          if v_upd then
            update tempded
              set	amtdeduct = v_amtdeduct,
                  amtspded  = v_amtspded,
                  coduser   = global_v_coduser,
                  codcreate = global_v_coduser
              where rowid = i.rowid;
          end if;
        end loop;

        if not v_exist then
          if p_typdata = 'E' then
            upd_log3('tempded',p_block,p_typdeduct,v_coddeduct,null,v_amtdeduct,v_upd);
          else
            upd_log3('tempded',p_block,p_typdeduct,v_coddeduct,null,v_amtspded,v_upd);
          end if;

          if check_emp_status = 'INSERT' then
            v_upd := true;
          end if;
          if v_upd then
            insert into tempded
              (codempid,coddeduct,amtdeduct,amtspded,
               dteupd,coduser)
            values
              (p_codempid_query,v_coddeduct,v_amtdeduct,v_amtspded,
               trunc(sysdate),global_v_coduser);
          end if;
        end if;
        if v_upd or not v_exist then
          v_exist := false;
          for r_tlastempd in c_tlastempd loop
            v_exist := true;
            update tlastempd
              set	codcomp   = work_codcomp,
                  amtdeduct = nvl(v_amtdeduct,0),
                  amtspded  = nvl(v_amtspded,0),
                  coduser   = global_v_coduser
              where rowid = r_tlastempd.rowid;
          end loop;

          if not v_exist then
            insert into tlastempd
              (dteyrepay,codempid,coddeduct,
               codcomp,amtdeduct,amtspded,
               codcreate,coduser)
            values
              (v_dteyrepay,p_codempid_query,v_coddeduct,
               work_codcomp,nvl(v_amtdeduct,0),nvl(v_amtspded,0),
               global_v_coduser,global_v_coduser);
          end if;
        end if;
      end if;
      v_key := p_tax.next(v_key);
    end loop;
  end; -- end tempded
  --
  procedure save_tspouse is
    v_exist				boolean := false;
    v_upd					boolean := false;
    cursor t_spouse is
      select  numtaxid, rowid
      from    tspouse
      where   codempid  = p_codempid_query;
  begin
    for i in t_spouse loop
      v_exist   := true;
      upd_log1('tspouse','171','numtaxid','C',i.numtaxid,sp_over_income_numtaxid,'N',v_upd);
      if v_upd then
        update  tspouse
        set     numtaxid  = sp_over_income_numtaxid
        ,       coduser   = global_v_coduser
        where   rowid     = i.rowid;
      end if;
    end loop;
    if not v_exist and sp_over_income_numtaxid is not null then
      insert into tspouse(codempid, numtaxid, codcreate, coduser)
                  values (p_codempid_query, sp_over_income_numtaxid, global_v_coduser, global_v_coduser);
    end if;
  end; -- end save_tspouse
  --
  procedure save_thisname is
    v_dtechg			thisname.dtechg%type;
    v_exist				boolean;
    v_upd					boolean;
    v_numseq      number;
    v_namempe 		temploy1.namempe%type;
    v_namempt 		temploy1.namempt%type;
    v_namemp3 		temploy1.namemp3%type;
    v_namemp4 		temploy1.namemp4%type;
    v_namemp5 		temploy1.namemp5%type;
    cursor c_thisname is
      select codempid,dtechg,codtitle,namfirste,namfirstt,
             namfirst3,namfirst4,namfirst5,namlaste,namlastt,
             namlast3,namlast4,namlast5,namempe,namempt,
             namemp3,namemp4,namemp5,deschang,rowid
      from	 thisname
      where	 codempid = p_codempid_query
      and		 dtechg   = v_dtechg;
  begin
    v_numseq  := 0;
    for n in 1..hisname_tab.count loop
      if p_flg_del_hisname(n) = 'delete' then
        delete from thisname
        where codempid  = p_codempid_query
--        and   dtechg    = to_date(hisname_tab(n).dtechg,'dd/mm/yyyy');
        and   dtechg    = hisname_tab(n).dtechg;
      else
        v_dtechg  := hisname_tab(n).dtechg;
        v_numseq  := v_numseq + 1;
        v_exist   := false;
        v_upd     := false;
        v_namempe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',hisname_tab(n).codtitle,'101')))||' '||
                           ltrim(rtrim(hisname_tab(n).namfirste))||' '||ltrim(rtrim(hisname_tab(n).namlaste)),1,60);
        v_namempt	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',hisname_tab(n).codtitle,'102')))||' '||
                           ltrim(rtrim(hisname_tab(n).namfirstt))||' '||ltrim(rtrim(hisname_tab(n).namlastt)),1,60);
        v_namemp3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',hisname_tab(n).codtitle,'103')))||' '||
                           ltrim(rtrim(hisname_tab(n).namfirst3))||' '||ltrim(rtrim(hisname_tab(n).namlast3)),1,60);
        v_namemp4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',hisname_tab(n).codtitle,'104')))||' '||
                           ltrim(rtrim(hisname_tab(n).namfirst4))||' '||ltrim(rtrim(hisname_tab(n).namlast4)),1,60);
        v_namemp5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',hisname_tab(n).codtitle,'105')))||' '||
                           ltrim(rtrim(hisname_tab(n).namfirst5))||' '||ltrim(rtrim(hisname_tab(n).namlast5)),1,60);
        for i in c_thisname loop
          v_exist := true;

          upd_log2('thisname','18',v_numseq,'codtitle','D','dtechg',null,v_dtechg,'C',i.codtitle,hisname_tab(n).codtitle,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirste','D','dtechg',null,v_dtechg,'C',i.namfirste,hisname_tab(n).namfirste,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirstt','D','dtechg',null,v_dtechg,'C',i.namfirstt,hisname_tab(n).namfirstt,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst3','D','dtechg',null,v_dtechg,'C',i.namfirst3,hisname_tab(n).namfirst3,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst4','D','dtechg',null,v_dtechg,'C',i.namfirst4,hisname_tab(n).namfirst4,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst5','D','dtechg',null,v_dtechg,'C',i.namfirst5,hisname_tab(n).namfirst5,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlaste','D','dtechg',null,v_dtechg,'C',i.namlaste,hisname_tab(n).namlaste,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlastt','D','dtechg',null,v_dtechg,'C',i.namlastt,hisname_tab(n).namlastt,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast3','D','dtechg',null,v_dtechg,'C',i.namlast3,hisname_tab(n).namlast3,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast4','D','dtechg',null,v_dtechg,'C',i.namlast4,hisname_tab(n).namlast4,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast5','D','dtechg',null,v_dtechg,'C',i.namlast5,hisname_tab(n).namlast5,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'deschang','D','dtechg',null,v_dtechg,'C',i.deschang,hisname_tab(n).deschang,'N',v_upd);
          if v_upd then
            update thisname
              set	codtitle = hisname_tab(n).codtitle,
                  namempe = v_namempe,
                  namempt = v_namempt,
                  namemp3	= v_namemp3,
                  namemp4 = v_namemp4,
                  namemp5 = v_namemp5,
                  namfirste = hisname_tab(n).namfirste,
                  namfirstt = hisname_tab(n).namfirstt,
                  namfirst3 = hisname_tab(n).namfirst3,
                  namfirst4 = hisname_tab(n).namfirst4,
                  namfirst5 = hisname_tab(n).namfirst5,
                  namlaste = hisname_tab(n).namlaste,
                  namlastt = hisname_tab(n).namlastt,
                  namlast3 = hisname_tab(n).namlast3,
                  namlast4 = hisname_tab(n).namlast4,
                  namlast5 = hisname_tab(n).namlast5,
                  deschang = hisname_tab(n).deschang,
                  coduser = global_v_coduser
              where rowid = i.rowid;
          end if;
        end loop;
        if not v_exist then
          upd_log2('thisname','18',v_numseq,'codtitle','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).codtitle,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirste','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namfirste,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirstt','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namfirstt,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst3','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namfirst3,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst4','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namfirst4,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namfirst5','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namfirst5,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlaste','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namlaste,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlastt','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namlastt,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast3','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namlast3,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast4','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namlast4,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'namlast5','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).namlast5,'N',v_upd);
          upd_log2('thisname','18',v_numseq,'deschang','D','dtechg',null,v_dtechg,'C',null,hisname_tab(n).deschang,'N',v_upd);
          if v_upd then
            insert into thisname
              (codempid,dtechg,codtitle,
               namempe,namempt,namemp3,namemp4,namemp5,
               namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
               namlaste,namlastt,namlast3,namlast4,namlast5,
               deschang,
               codcreate,coduser)
            values
              (p_codempid_query,v_dtechg,hisname_tab(n).codtitle,
               v_namempe,v_namempt,v_namemp3,v_namemp4,v_namemp5,
               hisname_tab(n).namfirste,hisname_tab(n).namfirstt,hisname_tab(n).namfirst3,hisname_tab(n).namfirst4,hisname_tab(n).namfirst5,
               hisname_tab(n).namlaste,hisname_tab(n).namlastt,hisname_tab(n).namlast3,hisname_tab(n).namlast4,hisname_tab(n).namlast5,
               hisname_tab(n).deschang,
               global_v_coduser,global_v_coduser);
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_thisname
  --
  procedure save_tappldoc is
    v_exist				boolean;
    v_upd					boolean;
    v_numseq      number;
    v_numappl     temploy1.numappl%type;
    cursor c_tappldoc is
      select numappl,numseq,codempid,typdoc,namdoc,
             filedoc,dterecv,dtedocen,numdoc,desnote,
             flgresume,numrefdoc,rowid
      from	 tappldoc
      where	 numappl  = v_numappl
      and		 numseq   = v_numseq;
  begin
    v_numseq  := 0;

    begin
      select  nvl(numappl,codempid)
      into    v_numappl
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      v_numappl   := nvl(personal_numappl,p_codempid_query);
    end;

    for n in 1..document_tab.count loop
      v_numseq  := document_tab(n).numseq;
      if p_flg_del_doc(n) = 'delete' then
--        for i in c_tappldoc loop
--          upd_log2('tappldoc','19',v_numseq,'namdoc','N','numseq',null,null,'C',i.namdoc,null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'dterecv','N','numseq',null,null,'D',to_char(i.dterecv,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'typdoc','N','numseq',null,null,'C',i.typdoc,null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'dtedocen','N','numseq',null,null,'D',to_char(i.dtedocen,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'numdoc','N','numseq',null,null,'C',i.numdoc,null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'desnote','N','numseq',null,null,'C',i.desnote,null,'N',v_upd,'D');
--          upd_log2('tappldoc','19',v_numseq,'flgresume','N','numseq',null,null,'C',i.flgresume,null,'N',v_upd,'D');
--        end loop;

        update ttrainbf
           set filedoc   = null,
               coduser   = global_v_coduser
         where numappl   = v_numappl
           and numrefdoc = (select  numrefdoc
                            from    tappldoc
                            where   numappl     = v_numappl
                            and     numseq      = v_numseq);

        delete from tappldoc
        where numappl   = v_numappl
        and   numseq    = v_numseq;
      else
        v_exist := false;	v_upd := false;
        for i in c_tappldoc loop
          v_exist := true;
          upd_log2('tappldoc','19',v_numseq,'filedoc','N','numseq',null,null,'C',i.filedoc,document_tab(n).filedoc,'N',v_upd);
          if v_upd and i.numrefdoc is not null then
            if i.typdoc = '0001' then
              update  ttrainbf
              set     filedoc = document_tab(n).filedoc,
                      coduser = global_v_coduser
              where   numappl   = v_numappl
              and     numrefdoc = i.numrefdoc;
            end if;
          end if;
          upd_log2('tappldoc','19',v_numseq,'namdoc','N','numseq',null,null,'C',i.namdoc,document_tab(n).namdoc,'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'dterecv','N','numseq',null,null,'D',to_char(i.dterecv,'dd/mm/yyyy'),to_char(document_tab(n).dterecv,'dd/mm/yyyy'),'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'typdoc','N','numseq',null,null,'C',i.typdoc,document_tab(n).typdoc,'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'dtedocen','N','numseq',null,null,'D',to_char(i.dtedocen,'dd/mm/yyyy'),to_char(document_tab(n).dtedocen,'dd/mm/yyyy'),'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'numdoc','N','numseq',null,null,'C',i.numdoc,document_tab(n).numdoc,'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'desnote','N','numseq',null,null,'C',i.desnote,document_tab(n).desnote,'N',v_upd);
          upd_log2('tappldoc','19',v_numseq,'flgresume','N','numseq',null,null,'C',i.flgresume,document_tab(n).flgresume,'N',v_upd);

          if v_upd then
            update tappldoc
              set	namdoc   = document_tab(n).namdoc,
                  filedoc  = document_tab(n).filedoc,
                  dterecv  = document_tab(n).dterecv,
                  typdoc   = document_tab(n).typdoc,
                  dtedocen = document_tab(n).dtedocen,
                  numdoc   = document_tab(n).numdoc,
                  desnote  = document_tab(n).desnote,
                  flgresume  = document_tab(n).flgresume,
                  coduser = global_v_coduser
              where rowid = i.rowid;
          end if;
        end loop;
        if not v_exist then
          upd_log2('tappldoc','19',v_numseq,'namdoc','N','numseq',null,null,'C',null,document_tab(n).namdoc,'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'filedoc','N','numseq',null,null,'C',null,document_tab(n).filedoc,'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'dterecv','N','numseq',null,null,'D',null,to_char(document_tab(n).dterecv,'dd/mm/yyyy'),'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'typdoc','N','numseq',null,null,'C',null,document_tab(n).typdoc,'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'dtedocen','N','numseq',null,null,'D',null,to_char(document_tab(n).dtedocen,'dd/mm/yyyy'),'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'numdoc','N','numseq',null,null,'C',null,document_tab(n).numdoc,'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'desnote','N','numseq',null,null,'C',null,document_tab(n).desnote,'N',v_upd,'I');
          upd_log2('tappldoc','19',v_numseq,'flgresume','N','numseq',null,null,'C',null,document_tab(n).flgresume,'N',v_upd,'I');

          if v_upd then
            insert into tappldoc
              (codempid,numappl,numseq,
               namdoc,filedoc,dterecv,
               typdoc,dtedocen,numdoc,desnote,flgresume,
               codcreate,coduser)
            values
              (p_codempid_query,v_numappl,v_numseq,
               document_tab(n).namdoc,document_tab(n).filedoc,document_tab(n).dterecv,
               document_tab(n).typdoc,document_tab(n).dtedocen,document_tab(n).numdoc,document_tab(n).desnote,document_tab(n).flgresume,
               global_v_coduser,global_v_coduser);
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_tappldoc
  --
  procedure save_tempimge is
    v_exist				boolean := false;
    v_upd					boolean := false;
    cursor c_tempimge is
      select  namimage,namsign,rowid
      from    tempimge
      where   codempid    = p_codempid_query;
  begin
    for i in c_tempimge loop
      v_exist := true;
      upd_log1('tempimge','11','namimage','C',i.namimage,personal_image,'N',v_upd);
      upd_log1('tempimge','11','namsign','C',i.namsign,personal_signature,'N',v_upd);
      if v_upd then
        update  tempimge
        set     namimage      = personal_image,
                namsign       = personal_signature,
                coduser       = global_v_coduser
        where   rowid         = i.rowid;
      end if;
    end loop;
    if not v_exist then
      insert into tempimge(codempid,namimage,namsign,codcreate,coduser)
                   values (p_codempid_query,personal_image,personal_signature,global_v_coduser,global_v_coduser);
    end if;
  end; -- end save_tempimge
  --
  function get_last_edit(p_numpage varchar2,
                         p_last_empimg out varchar2,
                         p_last_dteedit out varchar2) return varchar2 is
    v_last_emp      varchar2(100 char);
    v_last_empimg   varchar2(100 char);
    v_last_dteedit  varchar2(100);
    v_additional    number := hcm_appsettings.get_additional_year;
  begin
    begin
      select  distinct get_codempid(coduser),
              to_char(add_months(dteedit,12*v_additional),'dd/mm/yyyy hh24:mi')
      into    v_last_emp, v_last_dteedit
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = p_numpage
      and     dteedit     = ( select  max(dteedit)
                              from    ttemlog1
                              where   codempid    = p_codempid_query
                              and     numpage     = p_numpage);
    exception when no_data_found then
      v_last_emp        := '';
      v_last_dteedit    := '';
    end;

    if v_last_emp is not null then
      begin
        select  namimage
        into    v_last_empimg
        from    tempimge
        where   codempid  = v_last_emp;
      exception when no_data_found then
        v_last_empimg   := '';
      end;
    end if;
    p_last_empimg     := v_last_empimg;
    p_last_dteedit    := v_last_dteedit;

    return v_last_emp;
  end; -- end get_last_edit
  --
  function get_desciption (p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 is
    v_desc     varchar2(500 char):= p_code;
    v_stament  varchar2(500 char);
    v_funcdesc varchar2(500 char);
    v_data_type varchar2(500 char);
  begin
    if p_code is null then
      return v_desc ;
    end if;

    begin
      select  funcdesc,data_type
      into    v_funcdesc,v_data_type
      from    tcoldesc
      where   codtable  = p_table
      and     codcolmn  = p_field
      and     rownum    = 1 ;
    exception when no_data_found then
       v_funcdesc := null;
    end ;

    if v_funcdesc is not null   then
      v_stament   := 'select '||v_funcdesc||'from dual' ;
      v_stament   := replace(v_stament,'P_CODE',''''||p_code||'''') ;
      v_stament   := replace(v_stament,'P_LANG',global_v_lang) ;
      return execute_desc (v_stament) ;
    else
      if v_data_type = 'DATE' then
        return hcm_util.get_date_buddhist_era(to_date(v_desc,'dd/mm/yyyy'));
      elsif p_field in ('STAYEAR','DTEGYEAR') then
        return v_desc + global_v_zyear;
      else
        return v_desc ;
      end if;
    end if;
  end; -- end get_desciption
  --
  function get_tfolderd(p_codapp varchar2) return varchar2 is
    v_folder    tfolderd.folder%type;
  begin
    begin
      select  folder
      into    v_folder
      from    tfolderd
      where   codapp = p_codapp;
    exception when no_data_found then
      v_folder  := '';
    end;
    return v_folder;
  end; -- end get_tfolderd
  --
  procedure get_blacklist_data(json_str_input in clob, json_str_output out clob) is
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_blacklist_data(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_blacklist_data(json_str_input in clob, json_str_output out clob) is
    obj_row        json_object_t;
    json_obj        json_object_t;
    flg_found       varchar2(1) := 'N';

    v_numoffid      varchar2(4000 char);
    v_folder        tfolderd.folder%type;
    cursor c_tbcklst is
      select bkl.numoffid, decode(global_v_lang, '101', bkl.namempe
                                               , '102', bkl.namempt
                                               , '103', bkl.namemp3
                                               , '104', bkl.namemp4
                                               , '105', bkl.namemp5
                                               , bkl.namempt) as namemp,
             bkl.codexemp,get_tcodec_name('TCODEXEM',bkl.codexemp,global_v_lang) as desexemp,
             bkl.namimage as bklimg, img.namimage as empimg
        from tbcklst bkl
        left join tempimge img
          on bkl.codempid  = img.codempid
        left join temploy2 em2
          on bkl.numoffid  = em2.numoffid
         and img.codempid  = em2.codempid
       where bkl.numoffid  = v_numoffid;
    v_path_file   varchar2(500) := get_tsetup_value('PATHWORKPHP');
  begin
    ---<<initial_value---
    json_obj            := json_object_t(json_str_input);
    v_numoffid          := hcm_util.get_string_t(json_obj,'p_numoffid');
    --->>initial_value---
    obj_row    := json_object_t();
    for i in c_tbcklst loop
      flg_found   := 'Y';
      obj_row.put('coderror', '200');
      obj_row.put('numoffid',i.numoffid);
      obj_row.put('desc_numoffid',i.namemp);
      obj_row.put('desexemp',i.desexemp);
      if i.bklimg is not null then
        begin select folder into v_folder from tfolderd where codapp = 'HRPMB3E';
        exception when no_data_found then null; end;
        obj_row.put('namimage',v_path_file||'/'||v_folder||'/'||i.bklimg);
      end if;
      if i.empimg is not null then
        begin select folder into v_folder from tfolderd where codapp = 'HRPMC2E1';
        exception when no_data_found then null; end;
        obj_row.put('namimage',v_path_file||'/'||v_folder||'/'||i.empimg);
      end if;
    end loop;
    if flg_found = 'N' then
      obj_row.put('coderror', '200');
      obj_row.put('numoffid', '');
      obj_row.put('desc_numoffid', '');
      obj_row.put('desexemp',replace(get_error_msg_php('HR2055', global_v_lang),'@#$%400','')||' (TBCKLST)');
    end if;
    json_str_output := obj_row.to_clob;
--    if flg_found = 'Y' then
--      dbms_lob.createtemporary(json_str_output, true);
--      obj_row.to_clob(json_str_output);
--    else
--      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBCKLST');
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
  end;
  --
  procedure get_personal(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_get_personal;
    if param_msg_error is null then
      gen_personal(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_personal(json_str_output out clob) is
    obj_row         json_object_t;
    v_age_year      number;
    v_age_month     number;
    v_day           number;
    v_codcompy      tcenter.codcompy%type;
    v_ageretrm      number;
    v_ageretrf      number;
    v_exists        boolean := false;
    v_image         tempimge.namimage%type;
    v_signature     tempimge.namsign%type;
    cursor c_personal is
     select e1.codempid,codtitle,'' as image,'' as signature,
            decode(global_v_lang,'101',namfirste,
                                 '102',namfirstt,
                                 '103',namfirst3,
                                 '104',namfirst4,
                                 '105',namfirst5) as namfirst,
            namfirste,
            namfirstt,
            namfirst3,
            namfirst4,
            namfirst5,
            decode(global_v_lang,'101',namlaste,
                                 '102',namlastt,
                                 '103',namlast3,
                                 '104',namlast4,
                                 '105',namlast5) as namlast,
            namlaste,
            namlastt,
            namlast3,
            namlast4,
            namlast5,
            decode(global_v_lang,'101',nickname,
                                 '102',nicknamt,
                                 '103',nicknam3,
                                 '104',nicknam4,
                                 '105',nicknam5) as nicknam,
            nickname,
            nicknamt,
            nicknam3,
            nicknam4,
            nicknam5,
            numtelec, nummobile, lineid, numoffid, dteoffid, adrissue,
            codprovi, codclnsc, numpasid, dtepasid, numvisa, dtevisaexp,
            numlicid, dtelicid, dteempdb, coddomcl, '' as age, codsex,
            weight, high, codblood, codorgin, codnatnl, codrelgn,
            stamarry, stamilit, numprmid, dteprmst, dteprmen, numappl,
            dteretire, codcomp
      from  temploy1 e1, temploy2 e2
      where e1.codempid = p_codempid_query
      and   e1.codempid = e2.codempid;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp          = 'HRPMC2E'
      and     h.numpage         = 'HRPMC2E11'
--      and     (h.numpage      = 'HRPMC2E11'
--                or (h.numpage = 'HRPMC2E13' and fieldname in ('AGERETRM','AGERETRF'))
--              )
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;

--    cursor c_deflt_ageret is
--      select  fieldname, defaultval
--      from    tsetdeflh h, tsetdeflt d
--      where   h.codapp            = 'HRPMC2E'
--      and     h.numpage = 'HRPMC2E13' and fieldname in ('AGERETRM','AGERETRF')
--      and     nvl(h.flgdisp,'Y')  = 'Y'
--      and     h.codapp            = d.codapp
--      and     h.numpage           = d.numpage
--      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');

    for i in c_personal loop
      v_exists    := true;
      v_codcompy  := hcm_util.get_codcomp_level(i.codcomp,1);

      begin
        select  namimage, namsign
        into    v_image, v_signature
        from    tempimge
        where   codempid    = p_codempid_query;
      exception when no_data_found then
        v_image       := '';
        v_signature   := '';
      end;

      obj_row.put('codempid',i.codempid);
      obj_row.put('codtitle',i.codtitle);
      obj_row.put('image',v_image);
      obj_row.put('path_image',get_tfolderd('HRPMC2E1'));
      obj_row.put('signature',v_signature);
      obj_row.put('path_sign',get_tfolderd('HRPMC2E2'));
      obj_row.put('namfirst',i.namfirst);
      obj_row.put('namfirste',i.namfirste);
      obj_row.put('namfirstt',i.namfirstt);
      obj_row.put('namfirst3',i.namfirst3);
      obj_row.put('namfirst4',i.namfirst4);
      obj_row.put('namfirst5',i.namfirst5);
      obj_row.put('namlast',i.namlast);
      obj_row.put('namlaste',i.namlaste);
      obj_row.put('namlastt',i.namlastt);
      obj_row.put('namlast3',i.namlast3);
      obj_row.put('namlast4',i.namlast4);
      obj_row.put('namlast5',i.namlast5);
      obj_row.put('nicknam',i.nicknam);
      obj_row.put('nickname',i.nickname);
      obj_row.put('nicknamt',i.nicknamt);
      obj_row.put('nicknam3',i.nicknam3);
      obj_row.put('nicknam4',i.nicknam4);
      obj_row.put('nicknam5',i.nicknam5);
      obj_row.put('numtelec',i.numtelec);
      obj_row.put('nummobile',i.nummobile);
      obj_row.put('lineid',i.lineid);
      obj_row.put('numoffid',i.numoffid);
      obj_row.put('dteoffid',to_char(i.dteoffid,'dd/mm/yyyy'));
      obj_row.put('adrissue',i.adrissue);
      obj_row.put('codprovi',i.codprovi);
      obj_row.put('codclnsc',i.codclnsc);
      obj_row.put('numpasid',i.numpasid);
      obj_row.put('dtepasid',to_char(i.dtepasid,'dd/mm/yyyy'));
      obj_row.put('numvisa',i.numvisa);
      obj_row.put('dtevisaexp',to_char(i.dtevisaexp,'dd/mm/yyyy'));
      obj_row.put('numlicid',i.numlicid);
      obj_row.put('dtelicid',to_char(i.dtelicid,'dd/mm/yyyy'));
      obj_row.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
      obj_row.put('coddomcl',i.coddomcl);

      get_service_year(i.dteempdb,trunc(sysdate),'Y',v_age_year,v_age_month,v_day);

      obj_row.put('age_year',v_age_year);
      obj_row.put('age_month',v_age_month);
      obj_row.put('codsex',i.codsex);
      obj_row.put('weight',i.weight);
      obj_row.put('high',i.high);
      obj_row.put('codblood',i.codblood);
      obj_row.put('codorgin',i.codorgin);
      obj_row.put('codnatnl',i.codnatnl);
      obj_row.put('codrelgn',i.codrelgn);
      obj_row.put('stamarry',i.stamarry);
      obj_row.put('stamilit',i.stamilit);
      obj_row.put('numprmid',i.numprmid);
      obj_row.put('dteprmst',to_char(i.dteprmst,'dd/mm/yyyy'));
      obj_row.put('dteprmen',to_char(i.dteprmen,'dd/mm/yyyy'));
      obj_row.put('numappl',i.numappl);
      obj_row.put('dteretire',to_char(i.dteretire,'dd/mm/yyyy'));
    end loop;
--    for i in c_deflt_ageret loop
--      obj_row.put(lower(i.fieldname),i.defaultval);
--    end loop;
    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
      obj_row.put('flg','add');
    end if;
    /*------------------
    --  dteretire   --
    ------------------
    begin
      select  ageretrm, ageretrf
      into    v_ageretrm, v_ageretrf
      from    tcontpms
      where   codcompy  = v_codcompy
      and     dteeffec  = ( select  max(dteeffec)
                            from    tcontpms
                            where   codcompy  = v_codcompy);
    exception when no_data_found then
      v_ageretrm  := '';
      v_ageretrf  := '';
    end;
    ---------------------------
    obj_row.put('ageretrm',v_ageretrm);
    obj_row.put('ageretrf',v_ageretrf);*/

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_address(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_address(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_address(json_str_output out clob) is
    obj_row        json_object_t;
    v_exists       boolean  := false;
    cursor c_address is
     select e1.codempid,
            decode(global_v_lang, '101', adrrege,
                                  '102', adrregt,
                                  '103', adrreg3,
                                  '104', adrreg4,
                                  '105', adrreg5) as adrreg,
            adrrege,
            adrregt,
            adrreg3,
            adrreg4,
            adrreg5,
            codprovr,
            coddistr,
            codsubdistr,
            codcntyr,
            codpostr,
            decode(global_v_lang, '101', adrconte,
                                  '102', adrcontt,
                                  '103', adrcont3,
                                  '104', adrcont4,
                                  '105', adrcont5) as adrcont,
            adrconte,
            adrcontt,
            adrcont3,
            adrcont4,
            adrcont5,
            codprovc,
            coddistc,
            codsubdistc,
            codcntyc,
            codpostc
      from  temploy1 e1, temploy2 e2
      where e1.codempid = p_codempid_query
      and   e1.codempid = e2.codempid;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E12'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_address loop
      v_exists    := true;
      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('adrreg',i.adrreg);
      obj_row.put('adrrege',i.adrrege);
      obj_row.put('adrregt',i.adrregt);
      obj_row.put('adrreg3',i.adrreg3);
      obj_row.put('adrreg4',i.adrreg4);
      obj_row.put('adrreg5',i.adrreg5);
      obj_row.put('codprovr',i.codprovr);
      obj_row.put('coddistr',i.coddistr);
      obj_row.put('codsubdistr',i.codsubdistr);
      obj_row.put('codcntyr',i.codcntyr);
      obj_row.put('codpostr',i.codpostr);
      obj_row.put('adrcont',i.adrcont);
      obj_row.put('adrconte',i.adrconte);
      obj_row.put('adrcontt',i.adrcontt);
      obj_row.put('adrcont3',i.adrcont3);
      obj_row.put('adrcont4',i.adrcont4);
      obj_row.put('adrcont5',i.adrcont5);
      obj_row.put('codprovc',i.codprovc);
      obj_row.put('coddistc',i.coddistc);
      obj_row.put('codsubdistc',i.codsubdistc);
      obj_row.put('codcntyc',i.codcntyc);
      obj_row.put('codpostc',i.codpostc);
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_work(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_work(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_work(json_str_output out clob) is
    obj_row       json_object_t;
    v_codempidh   temphead.codempidh%type; --from temphead, temphead
    v_codcomph    temphead.codcomph%type;
    v_codposh     temphead.codposh%type;
    v_stapost     tsecpos.stapost2%type; -- from tsecpos

--    v_codcomp     temploy1.codcomp%type;
--    v_codpos      temploy1.codpos%type;
    v_last_emp      varchar2(100 char);
    v_last_empimg   varchar2(100 char);
    v_last_dteedit  varchar2(100);

    v_svyryre     number;
    v_svyrmth     number;
    v_day         number;

    v_chk_head1   varchar2(1) := 'N';
    v_codtrn001   varchar2(1);
    v_lock_edit   varchar2(1);

    v_exists      boolean := false;
    v_default_qtyduepr    varchar2(150);
    cursor c_work is
     select emp.codempid,dteempmt, '' as ageemp, staemp, dteeffex, codcomp, emp.codpos,
            get_tpostninit_name(emp.codpos,global_v_lang) as namabb,
            dteefpos, numlvl, dteeflvl, codbrlc, codempmt, typpayroll,
            typemp, codcalen, flgatten, codjob, jobgrade, dteefstep,
            codgrpgl, stadisb, numdisab, dtedisb, dtedisen, typdisp,
            desdisp, dteduepr - dteempmt + 1 as qtyduepr, dteduepr,
            trunc(qtydatrq / 12) as yredatrq, mod(qtydatrq,12) as mthdatrq,
            dteoccup, numtelof, email, numreqc, numreqst, stareq, ocodempid, dtereemp,
            dteredue - dtereemp + 1 as qtyredue, dteredue, qtywkday,
            emp.dteupd, emp.coduser, qtydatrq, flgpdpa, dtepdpa
      from  temploy1 emp, tpostn pos
      where emp.codpos     = pos.codpos(+)
      and   emp.codempid   = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E13'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');

    begin
      select    'Y'
      into      v_codtrn001
      from      ttpminf
      where     codempid  = p_codempid_query
      and       codtrn    = '0001'
      and       rownum    = 1;
    exception when no_data_found then
      v_codtrn001   := 'N';
    end;

    begin
      select    flgupd
      into      v_lock_edit
      from      ttnewemp
      where     codempid  = p_codempid_query
      and       rownum    = 1;
    exception when no_data_found then
      v_lock_edit   := 'N';
    end;

    begin
      select  defaultval
      into    v_default_qtyduepr
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E13'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      and     d.fieldname         = 'QTYDUEPR';
    exception when no_data_found then
      v_default_qtyduepr    := '119';
    end;

    for i in c_work loop
      -- Adisak redmine 4448#9338 18/04/2023 10:41
      if i.staemp = 3 then
        v_default_qtyduepr := '';
      end if;
      -- Adisak redmine 4448#9338 18/04/2023 10:41

      v_exists    := true;
      get_head(i.codcomp, i.codpos, v_codcomph, v_codposh, v_codempidh, v_stapost);
      param_numreqst  := null;
      if i.numreqc <> i.numreqst and i.stareq = '51' then
        param_numreqst  := i.numreqc;
--        :parameter.numreqst := i.numreqc;
      else
        param_numreqst  := i.numreqst;
--        :parameter.numreqst := i.numreqst;
      end if;

      v_last_emp    := get_last_edit('13',v_last_empimg,v_last_dteedit);

      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy'));

      get_service_year(i.dteempmt + nvl(i.qtywkday,0),nvl(i.dteeffex,sysdate),'Y',v_svyryre,v_svyrmth,v_day);

      obj_row.put('svyryre',v_svyryre);
      obj_row.put('svyrmth',v_svyrmth);
      obj_row.put('staemp',i.staemp);
      obj_row.put('dteeffex',to_char(i.dteeffex,'dd/mm/yyyy'));
      obj_row.put('codcomp',i.codcomp);
      obj_row.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_row.put('codpos',i.codpos);
      obj_row.put('namabb',i.namabb);
      obj_row.put('dteefpos',to_char(i.dteefpos,'dd/mm/yyyy'));
      obj_row.put('numlvl',i.numlvl);
      obj_row.put('dteeflvl',to_char(i.dteeflvl,'dd/mm/yyyy'));
      obj_row.put('codbrlc',i.codbrlc);
      obj_row.put('codempmt',i.codempmt);
      obj_row.put('typpayroll',i.typpayroll);
      obj_row.put('typemp',i.typemp);
      obj_row.put('codcalen',i.codcalen);
      obj_row.put('flgatten',i.flgatten);
      obj_row.put('codjob',i.codjob);
      obj_row.put('jobgrade',i.jobgrade);
      obj_row.put('dteefstep',to_char(i.dteefstep,'dd/mm/yyyy'));
      obj_row.put('codgrpgl',i.codgrpgl);
      obj_row.put('codempidh',v_codempidh);
      obj_row.put('codcomph',v_codcomph);
      obj_row.put('codposh',v_codposh);
      obj_row.put('stapost',v_stapost);

--      obj_row.put('dteefpos',to_char(i.dteempmt,'dd/mm/yyyy'));
--      obj_row.put('dteeflvl',to_char(i.dteempmt,'dd/mm/yyyy'));
--      obj_row.put('dteefstep',to_char(i.dteempmt,'dd/mm/yyyy'));


      if nvl(v_stapost,'0') = '0' then
        obj_row.put('desc_stapost',get_label_name('HRPM4DE1',global_v_lang,140));
      elsif v_stapost = '1' then
        obj_row.put('desc_stapost',get_label_name('HRPM4DE2',global_v_lang,390));
      elsif v_stapost = '2' then
        obj_row.put('desc_stapost',get_label_name('HRPM4DE2',global_v_lang,400));
      end if;
      obj_row.put('stadisb',i.stadisb);
      obj_row.put('numdisab',i.numdisab);
      obj_row.put('dtedisb',to_char(i.dtedisb,'dd/mm/yyyy'));
      obj_row.put('dtedisen',to_char(i.dtedisen,'dd/mm/yyyy'));
      obj_row.put('typdisp',i.typdisp);
      obj_row.put('desdisp',i.desdisp);
      obj_row.put('qtyduepr',i.qtyduepr);
      obj_row.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy'));
      obj_row.put('yredatrq',i.yredatrq);
      obj_row.put('mthdatrq',i.mthdatrq);
      obj_row.put('qtydatrq',i.qtydatrq);
      obj_row.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy'));
      obj_row.put('numtelof',i.numtelof);
      obj_row.put('email',i.email);
      obj_row.put('numreqst',i.numreqst);
      obj_row.put('param_numreqst',param_numreqst);
      obj_row.put('param_codpos',i.codpos);
      obj_row.put('ocodempid',i.ocodempid);
      obj_row.put('dtereemp',to_char(i.dtereemp,'dd/mm/yyyy'));
      obj_row.put('qtyredue',i.qtyredue);
      obj_row.put('dteredue',to_char(i.dteredue,'dd/mm/yyyy'));
      obj_row.put('qtywkday',i.qtywkday);
      obj_row.put('lock_staemp',v_codtrn001);
      obj_row.put('lock_edit',v_lock_edit);
      obj_row.put('dteupd',v_last_dteedit);
      obj_row.put('coduser',v_last_emp||' - '||get_temploy_name(v_last_emp,global_v_lang));
      obj_row.put('last_empimg',v_last_emp);
      obj_row.put('default_qtyduepr',v_default_qtyduepr);
      obj_row.put('flgpdpa',i.flgpdpa);
      obj_row.put('dtepdpa',to_char(i.dtepdpa,'dd/mm/yyyy'));
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
      obj_row.put('default_qtyduepr',v_default_qtyduepr);
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_travel(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_travel(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_travel(json_str_output out clob) is
    obj_row       json_object_t;
    v_exists      boolean := false;
    cursor c_travel is
     select codempid,typtrav,carlicen,typfuel,
            qtylength,codbusno,codbusrt
      from  temploy1
      where codempid = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E14'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_travel loop
      v_exists    := true;
      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('typtrav',i.typtrav);
      obj_row.put('carlicen',i.carlicen);
      obj_row.put('typfuel',i.typfuel);
      obj_row.put('qtylength',i.qtylength);
      obj_row.put('codbusno',i.codbusno);
      obj_row.put('codbusrt',i.codbusrt);
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_income_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_income_detail(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_income_detail(json_str_output out clob) is
    obj_row          json_object_t;
    v_codcompy       tcompny.codcompy%type;
    v_codempid       temploy1.codempid%type;
    v_codempmt       temploy1.codempmt%type;
    v_codcomp        temploy1.codcomp%type;
    v_codcurr        temploy3.codcurr%type;
    type p_num is table of number index by binary_integer;
      v_amtincom    p_num;
    v_amtothr         number;
    v_amtday          number;
    v_sumincom        number;
    v_amtproadj       number;
    v_last_emp        varchar2(100 char);
    v_last_empimg     varchar2(100 char);
    v_last_dteedit    varchar2(100);
    v_codtrn001       varchar2(1);
    v_lock_edit       varchar2(1);
    v_zupdsal         varchar2(1) := 'N';
    v_flgsecu         boolean := false;
    v_disp_sal        varchar2(1) := 'N';
  begin
    obj_row     := json_object_t();
    obj_row.put('coderror','200');
    begin
      select    flgupd
      into      v_lock_edit
      from      ttnewemp
      where     codempid  = p_codempid_query
      and       rownum    = 1;
    exception when no_data_found then
      v_lock_edit   := 'N';
    end;

    v_flgsecu := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
    if v_flgsecu and v_zupdsal = 'Y' then
      v_disp_sal  := 'Y';
    end if;

    begin
      select  emp1.codempid,emp1.codempmt,emp1.codcomp,
              stddec(amtincom1,emp1.codempid,global_v_chken),
              stddec(amtincom2,emp1.codempid,global_v_chken),
              stddec(amtincom3,emp1.codempid,global_v_chken),
              stddec(amtincom4,emp1.codempid,global_v_chken),
              stddec(amtincom5,emp1.codempid,global_v_chken),
              stddec(amtincom6,emp1.codempid,global_v_chken),
              stddec(amtincom7,emp1.codempid,global_v_chken),
              stddec(amtincom8,emp1.codempid,global_v_chken),
              stddec(amtincom9,emp1.codempid,global_v_chken),
              stddec(amtincom10,emp1.codempid,global_v_chken),
              codcurr,stddec(amtproadj,emp1.codempid,global_v_chken)
      into    v_codempid, v_codempmt, v_codcomp,
              v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
              v_codcurr, v_amtproadj
      from    temploy1 emp1, temploy3 emp3
      where   emp1.codempid   = p_codempid_query
      and     emp1.codempid   = emp3.codempid;
    exception when no_data_found then
      v_amtincom(1)   := 0;
      v_amtincom(2)   := 0;
      v_amtincom(3)   := 0;
      v_amtincom(4)   := 0;
      v_amtincom(5)   := 0;
      v_amtincom(6)   := 0;
      v_amtincom(7)   := 0;
      v_amtincom(8)   := 0;
      v_amtincom(9)   := 0;
      v_amtincom(10)  := 0;
    end;

    for i in 1..10 loop
      v_amtincom(i)   := greatest(0, v_amtincom(i));
    end loop;
    v_last_emp    := get_last_edit('15',v_last_empimg,v_last_dteedit);
    if v_codempid is not null then
--      begin
--        select  codcompy
--        into    v_codcompy
--        from    tcenter
--        where   codcomp = v_codcomp;
--      exception when no_data_found then
--        v_codcompy  := null;
--      end;
      v_codcompy  := hcm_util.get_codcomp_level(v_codcomp,1);
      get_wage_income(v_codcompy,v_codempmt,
                      nvl(v_amtincom(1),0),nvl(v_amtincom(2),0),
                      nvl(v_amtincom(3),0),nvl(v_amtincom(4),0),
                      nvl(v_amtincom(5),0),nvl(v_amtincom(6),0),
                      nvl(v_amtincom(7),0),nvl(v_amtincom(8),0),
                      nvl(v_amtincom(9),0),nvl(v_amtincom(10),0),
                      v_amtothr,v_amtday,v_sumincom);
      obj_row.put('coderror','200');
      obj_row.put('codempid',v_codempid);
      obj_row.put('codcurr',v_codcurr);
      obj_row.put('afpro',to_char(v_amtproadj,'999,999,990.00'));
      obj_row.put('amtothr',to_char(v_amtothr,'999,999,990.00'));
      obj_row.put('amtday',to_char(v_amtday,'999,999,990.00'));
      obj_row.put('sumincom',to_char(v_sumincom,'999,999,990.00'));
      obj_row.put('lock_edit',v_lock_edit);
      obj_row.put('dteupd',v_last_dteedit);
      obj_row.put('coduser',v_last_emp||' - '||get_temploy_name(v_last_emp,global_v_lang));
      obj_row.put('last_empimg',v_last_emp);
      obj_row.put('disp_sal',v_disp_sal);
    end if;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_income_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_income_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_income_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_row             number := 0;

    param_json        json_object_t;
    param_json_row    json_object_t;

    v_json_codincom   clob;
    v_json_input      clob;

    v_codcompy       tcompny.codcompy%type;
    v_codempid       temploy1.codempid%type;
    v_codempmt       temploy1.codempmt%type;
    v_codcomp        temploy1.codcomp%type;
    type p_num is table of number index by binary_integer;
      v_amtincom    p_num;

    v_codincom      tinexinf.codpay%type;
    v_desincom      tinexinf.descpaye%type;
    v_desunit       varchar2(150 char);
    v_amtmax        number;

  begin
    obj_row    := json_object_t();
    begin
      select  emp1.codempid,emp1.codempmt,emp1.codcomp,
              stddec(amtincom1,emp1.codempid,global_v_chken),
              stddec(amtincom2,emp1.codempid,global_v_chken),
              stddec(amtincom3,emp1.codempid,global_v_chken),
              stddec(amtincom4,emp1.codempid,global_v_chken),
              stddec(amtincom5,emp1.codempid,global_v_chken),
              stddec(amtincom6,emp1.codempid,global_v_chken),
              stddec(amtincom7,emp1.codempid,global_v_chken),
              stddec(amtincom8,emp1.codempid,global_v_chken),
              stddec(amtincom9,emp1.codempid,global_v_chken),
              stddec(amtincom10,emp1.codempid,global_v_chken)
      into    v_codempid, v_codempmt, v_codcomp,
              v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
      from    temploy1 emp1, temploy3 emp3
      where   emp1.codempid   = p_codempid_query
      and     emp1.codempid   = emp3.codempid;
    exception when no_data_found then
      v_amtincom(1)   := 0;
      v_amtincom(2)   := 0;
      v_amtincom(3)   := 0;
      v_amtincom(4)   := 0;
      v_amtincom(5)   := 0;
      v_amtincom(6)   := 0;
      v_amtincom(7)   := 0;
      v_amtincom(8)   := 0;
      v_amtincom(9)   := 0;
      v_amtincom(10)  := 0;
    end;

    for i in 1..10 loop
      v_amtincom(i)   := greatest(0, v_amtincom(i));
    end loop;

--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp = v_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy  := hcm_util.get_codcomp_level(v_codcomp,1);
    v_json_input      := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmt||'","p_lang":"'||global_v_lang||'"}';
    v_json_codincom   := hcm_pm.get_codincom(v_json_input);
    param_json        := json_object_t(v_json_codincom);
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codincom          := hcm_util.get_string_t(param_json_row,'codincom');
      v_desincom          := hcm_util.get_string_t(param_json_row,'desincom');
      v_desunit           := hcm_util.get_string_t(param_json_row,'desunit');
      v_amtmax            := hcm_util.get_string_t(param_json_row,'amtmax');
      v_row       := v_row + 1;
      if v_codincom is not null then
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',v_codempid);
        obj_data.put('codincom',v_codincom);
        obj_data.put('desincom',v_desincom);
        obj_data.put('desunit',v_desunit);
        obj_data.put('amtmax',v_amtmax);
--        obj_data.put('amtincom',to_char(v_amtincom(i + 1),'999,999,990.00'));
        obj_data.put('amtincom',v_amtincom(i + 1));
        obj_row.put(v_row - 1, obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_tax_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tax_detail(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tax_detail(json_str_output out clob) is
    obj_row     json_object_t;
    v_frsmemb   tssmemb.frsmemb%type;
    v_exists    boolean := false;
    cursor c_tax_detail is
      select  codempid,numtaxid,numsaid,flgtax,typtax,dteyrrelf,dteyrrelt,
              stddec(amtrelas,codempid,global_v_chken) as amtrelas,
              stddec(amttaxrel,codempid,global_v_chken) as amttaxrel,
              codbank,numbank,numbrnch,amtbank,
              stddec(amttranb,codempid,global_v_chken) as amttranb, -- user18 05/02/2021,
              codbank2,
              numbank2,numbrnch2,typincom,
              qtychldb,qtychlda,qtychldd,qtychldi,flgslip
      from    temploy3
      where   codempid = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E161'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;

    cursor c_default_cal_deduct is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E164'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_tax_detail loop
      v_exists    := true;
      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('numtaxid',i.numtaxid);
      obj_row.put('numsaid',i.numsaid);

      begin
        select frsmemb into v_frsmemb
        from   tssmemb
        where  codempid = p_codempid_query;
      exception when no_data_found then
        v_frsmemb   := null;
      end;

      obj_row.put('frsmemb',to_char(v_frsmemb,'dd/mm/yyyy'));
      obj_row.put('flgtax',i.flgtax);
      obj_row.put('typtax',i.typtax);
      obj_row.put('typincom',i.typincom);
      obj_row.put('dteyrrelf',i.dteyrrelf);
      obj_row.put('dteyrrelt',i.dteyrrelt);
      obj_row.put('amtrelas',i.amtrelas);
      obj_row.put('amttaxrel',i.amttaxrel);
      obj_row.put('codbank',i.codbank);
      obj_row.put('numbank',i.numbank);
      obj_row.put('numbrnch',i.numbrnch);
      obj_row.put('amtbank',i.amtbank);
      obj_row.put('amttranb',i.amttranb);
      obj_row.put('codbank2',i.codbank2);
      obj_row.put('numbank2',i.numbank2);
      obj_row.put('numbrnch2',i.numbrnch2);
      obj_row.put('qtychldb',i.qtychldb);
      obj_row.put('qtychlda',i.qtychlda);
      obj_row.put('qtychldd',i.qtychldd);
      obj_row.put('qtychldi',i.qtychldi);
      obj_row.put('flgslip',i.flgslip);
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
    end if;
    for i in c_default_cal_deduct loop
      if i.fieldname = 'CODDEDUCT' then
        obj_row.put('coddedchil',i.defaultval);
      elsif i.fieldname = 'AMTCHLDB' then
        obj_row.put('amtchldb',i.defaultval);
      elsif i.fieldname = 'AMTCHLDA' then
        obj_row.put('amtchlda',i.defaultval);
      elsif i.fieldname = 'AMTCHLDD' then
        obj_row.put('amtchldd',i.defaultval);
      elsif i.fieldname = 'CODDEDUCT2' then
        obj_row.put('coddeduct2',i.defaultval);
      elsif i.fieldname = 'AMTCHLDI' then
        obj_row.put('amtchldi',i.defaultval);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_over_income(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_over_income(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_over_income(json_str_output out clob) is
    obj_row     json_object_t;
    v_exists    boolean := false;
    cursor c_over_income is
      select  codempid,dtebf,
              stddec(amtincbf,codempid,global_v_chken) as amtincbf,
              stddec(amttaxbf,codempid,global_v_chken) as amttaxbf,
              stddec(amtpf,codempid,global_v_chken) as amtpf,
              stddec(amtsaid,codempid,global_v_chken) as amtsaid
      from    temploy3
      where   codempid = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E162'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');

    for i in c_over_income loop
      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('dtebf',to_char(i.dtebf,'dd/mm/yyyy'));
      obj_row.put('amtincbf',i.amtincbf);
      obj_row.put('amttaxbf',i.amttaxbf);
      obj_row.put('amtpf',i.amtpf);
      obj_row.put('amtsaid',i.amtsaid);
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_tax_exemption(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    gen_tax_exemption(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tax_exemption(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_tax_exemption is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                             and codcompy  = v_codcompy)
      and     typdeduct   = 'E'
      and     codcompy    = v_codcompy
      and     coddeduct   <> 'E001'
      order by coddeduct;
  begin
    if work_codcomp is null then
      begin
        select  codempid,hcm_util.get_codcomp_level(codcomp,1)
        into    v_codempid,v_codcompy
        from    temploy1
        where   codempid    = p_codempid_query;
      exception when no_data_found then
        v_codempid  := '';
      end;
    else
      v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    end if;

    obj_row    := json_object_t();
    for i in c_tax_exemption loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtdeduct into v_amtdeduct
        from	 tempded
        where	 codempid	  = p_codempid_query
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,p_codempid_query,global_v_chken);
      exception when no_data_found then
        if i.flgdef = 'Y' and check_emp_status = 'INSERT' then
          v_amtdedect_dec := i.amtdemax;
        else
          v_amtdedect_dec := 0;
        end if;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_tax_allowance(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    gen_tax_allowance(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tax_allowance(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_tax_allowance is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff  = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                              and codcompy  = v_codcompy)
      and     codcompy  = v_codcompy
      and     typdeduct = 'D'
      and     coddeduct not in ('D001','D002')
      order by coddeduct;
  begin
    if work_codcomp is null then
      begin
        select  codempid,hcm_util.get_codcomp_level(codcomp,1)
        into    v_codempid,v_codcompy
        from    temploy1
        where   codempid    = p_codempid_query;
      exception when no_data_found then
        v_codempid  := '';
      end;
    else
      v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    end if;
    obj_row    := json_object_t();
    for i in c_tax_allowance loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtdeduct into v_amtdeduct
        from	 tempded
        where	 codempid	  = v_codempid
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,v_codempid,global_v_chken);
      exception when no_data_found then
        if i.flgdef = 'Y' then
          v_amtdedect_dec := i.amtdemax;
        else
          v_amtdedect_dec := 0;
        end if;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_data.put('amtdemax',nvl(i.amtdemax,0));
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_others_deduct(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    gen_others_deduct(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_others_deduct(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_others_deduct is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff  = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                              and codcompy  = v_codcompy)
      and     codcompy  = v_codcompy
      and     typdeduct = 'O'
      order by coddeduct;
  begin
    if work_codcomp is null then
      begin
        select  codempid,hcm_util.get_codcomp_level(codcomp,1)
        into    v_codempid,v_codcompy
        from    temploy1
        where   codempid    = p_codempid_query;
      exception when no_data_found then
        v_codempid  := '';
      end;
    else
      v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    end if;

    obj_row    := json_object_t();
    for i in c_others_deduct loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtdeduct into v_amtdeduct
        from	 tempded
        where	 codempid	  = p_codempid_query
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,p_codempid_query,global_v_chken);
      exception when no_data_found then
        if i.flgdef = 'Y' and check_emp_status = 'INSERT' then
          v_amtdedect_dec := i.amtdemax;
        else
          v_amtdedect_dec := 0;
        end if;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_sp_over_income(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_sp_over_income(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_sp_over_income(json_str_output out clob) is
    obj_row         json_object_t;
    v_numtaxid_sp   tspouse.numtaxid%type;
    v_exists        boolean := false;
    cursor c_sp_over_income is
      select  emp3.codempid,--sp.numtaxid,
              emp3.dtebfsp,
              stddec(emp3.amtincsp,p_codempid_query,global_v_chken) as amtincsp,
              stddec(emp3.amttaxsp,p_codempid_query,global_v_chken) as amttaxsp,
              stddec(emp3.amtsasp,p_codempid_query,global_v_chken) as amtsasp,
              stddec(emp3.amtpfsp,p_codempid_query,global_v_chken) as amtpfsp
      from    temploy3 emp3, tspouse sp
      where   emp3.codempid   = sp.codempid(+)
      and     emp3.codempid   = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E17'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    begin
      select  numtaxid
      into    v_numtaxid_sp
      from    tspouse
      where   codempid  = p_codempid_query;
    exception when no_data_found then
      v_numtaxid_sp := null;
    end;
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_sp_over_income loop
      v_exists    := true;
      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('numtaxid',v_numtaxid_sp);--i.numtaxid);
      obj_row.put('dtebfsp',to_char(i.dtebfsp,'dd/mm/yyyy'));
      obj_row.put('amtincsp',i.amtincsp);
      obj_row.put('amttaxsp',i.amttaxsp);
      obj_row.put('amtsasp',i.amtsasp);
      obj_row.put('amtpfsp',i.amtpfsp);
    end loop;

    if not v_exists then
      for i in c_default loop
        obj_row.put(lower(i.fieldname),i.defaultval);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_sp_tax_exemption(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_sp_tax_exemption(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_sp_tax_exemption(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_sp_tax_exemption is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                             and codcompy  = v_codcompy)
      and     typdeduct   = 'E'
      and     codcompy    = v_codcompy
      and     coddeduct   <> 'E001'
      order by coddeduct;
  begin
    begin
      select  codempid,hcm_util.get_codcomp_level(codcomp,1)
      into    v_codempid,v_codcompy
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      v_codempid  := '';
    end;

    obj_row    := json_object_t();
    for i in c_sp_tax_exemption loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtspded into v_amtdeduct
        from	 tempded
        where	 codempid	  = p_codempid_query
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,p_codempid_query,global_v_chken);
      exception when no_data_found then
        v_amtdedect_dec   := 0;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_sp_tax_deduct(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_sp_tax_deduct(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_sp_tax_deduct(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_sp_tax_deduct is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff  = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                              and codcompy  = v_codcompy)
      and     typdeduct = 'D'
      and     codcompy  = v_codcompy
      and     coddeduct not in ('D001','D002')
      order by coddeduct;
  begin
    begin
      select  codempid,hcm_util.get_codcomp_level(codcomp,1)
      into    v_codempid,v_codcompy
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      v_codempid  := '';
    end;

    obj_row    := json_object_t();
    for i in c_sp_tax_deduct loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtspded into v_amtdeduct
        from	 tempded
        where	 codempid	  = p_codempid_query
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,p_codempid_query,global_v_chken);
      exception when no_data_found then
        v_amtdedect_dec   := 0;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_data.put('amtdemax',i.amtdemax);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_sp_others_deduct(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_sp_others_deduct(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_sp_others_deduct(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_amtdeduct     tempded.amtdeduct%type;
    v_amtdedect_dec number;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_desdeduct     tcodeduct.descnamt%type;
    cursor c_sp_others_deduct is
      select  coddeduct,
              flgdef,
              amtdemax
      from    tdeductd
      where   dteyreff  = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                              and codcompy  = v_codcompy)
      and     codcompy  = v_codcompy
      and     typdeduct = 'O'
      order by coddeduct;
  begin
    begin
      select  codempid,hcm_util.get_codcomp_level(codcomp,1)
      into    v_codempid,v_codcompy
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      v_codempid  := '';
    end;

    obj_row    := json_object_t();
    for i in c_sp_others_deduct loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();

      v_desdeduct := get_tcodeduct_name(i.coddeduct,global_v_lang);
      begin
        select amtspded into v_amtdeduct
        from	 tempded
        where	 codempid	  = p_codempid_query
        and		 coddeduct  = i.coddeduct;
        v_amtdedect_dec   := stddec(v_amtdeduct,p_codempid_query,global_v_chken);
      exception when no_data_found then
        v_amtdedect_dec   := 0;
      end;

      obj_data.put('coderror','200');
      obj_data.put('codempid',v_codempid);
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',v_desdeduct);
      obj_data.put('amtdeduct',v_amtdedect_dec);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_hisname(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_hisname(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_hisname(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    cursor c_hisname is
      select  codempid,dtechg,codtitle,
              decode(global_v_lang, '101', namfirste,
                                    '102', namfirstt,
                                    '103', namfirst3,
                                    '104', namfirst4,
                                    '105', namfirst5) as namfirst,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang, '101', namlaste,
                                    '102', namlastt,
                                    '103', namlast3,
                                    '104', namlast4,
                                    '105', namlast5) as namlast,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              deschang,dteupd,coduser
      from    thisname
      where   codempid  = p_codempid_query
      order by dtechg asc;
  begin
    obj_row    := json_object_t();
    for i in c_hisname loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('dtechg',to_char(i.dtechg,'dd/mm/yyyy'));
      obj_data.put('codtitle',i.codtitle);
      obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',i.codtitle,global_v_lang));
      obj_data.put('namfirst',i.namfirst);
      obj_data.put('namfirste',i.namfirste);
      obj_data.put('namfirstt',i.namfirstt);
      obj_data.put('namfirst3',i.namfirst3);
      obj_data.put('namfirst4',i.namfirst4);
      obj_data.put('namfirst5',i.namfirst5);
      obj_data.put('namlast',i.namlast);
      obj_data.put('namlaste',i.namlaste);
      obj_data.put('namlastt',i.namlastt);
      obj_data.put('namlast3',i.namlast3);
      obj_data.put('namlast4',i.namlast4);
      obj_data.put('namlast5',i.namlast5);
      obj_data.put('deschang',i.deschang);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_document(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_document(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_document(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_numappl       temploy1.numappl%type;
    cursor c_tappldoc is
      select codempid,numseq,namdoc,filedoc,dterecv,
             typdoc,dtedocen,numdoc,desnote,dteupd,
             flgresume,coduser
      from  tappldoc
      where numappl = v_numappl
      order by numseq;
  begin
    begin
      select  numappl
      into    v_numappl
      from    temploy1
      where   codempid  = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    obj_row    := json_object_t();
    for i in c_tappldoc loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numappl',v_numappl);
      obj_data.put('numseq',i.numseq);
      obj_data.put('typdoc',i.typdoc);
      obj_data.put('desc_typdoc',get_tcodec_name('TCODTYDOC',i.typdoc,global_v_lang));
      obj_data.put('namdoc',i.namdoc);
      obj_data.put('dterecv',to_char(i.dterecv,'dd/mm/yyyy'));
      obj_data.put('dtedocen',to_char(i.dtedocen,'dd/mm/yyyy'));
      obj_data.put('numdoc',i.numdoc);
      obj_data.put('filedoc',i.filedoc);
      obj_data.put('desnote',i.desnote);
      obj_data.put('flgresume',i.flgresume);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure check_tab_document(json_str_input in clob, json_str_output out clob) is
    json_document     json_object_t;
    v_typdoc          tappldoc.typdoc%type;
    v_code            varchar2(100);
  begin
    initial_value(json_str_input);
    json_document     := json_object_t(json_str_input);
    v_typdoc          := hcm_util.get_string_t(json_document,'typdoc');
    begin
      select  codcodec
      into    v_code
      from    tcodtydoc
      where   codcodec    = v_typdoc;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYDOC');
    end;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_codpos_data(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_codempidh   temphead.codempidh%type; --from temphead, temphead
    v_codcomph    temphead.codcomph%type;
    v_codposh     temphead.codposh%type;
    v_stapost     tsecpos.stapost2%type; -- from tsecpos
    v_numlvl      temploy1.numlvl%type;
    v_numlvlen    tjobpos.joblvlen%type;
    v_codjob      tjobpos.codjob%type;
    v_jobgrade    tjobpos.jobgrade%type;
    v_codcompy    tcenter.codcompy%type;
    v_ageretrm    number;
    v_ageretrf    number;
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    get_head(work_codcomp,work_codpos,v_codcomph,v_codposh,v_codempidh,v_stapost);
    begin
     select   joblvlst, joblvlen
       into   v_numlvl, v_numlvlen
       from   tjobpos
      where   codpos	= work_codpos
      and     codcomp   = work_codcomp
      and     codjob    = work_codjob;
    exception when no_data_found then
      v_numlvl := 0;
      v_numlvlen := 99;
    end;

--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp   = work_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
--    begin
--      select  ageretrm, ageretrf
--      into    v_ageretrm, v_ageretrf
--      from    tcontpms
--      where   codcompy  = v_codcompy
--      and     dteeffec  = ( select  max(dteeffec)
--                            from    tcontpms
--                            where   codcompy  = v_codcompy);
--    exception when no_data_found then
--      v_ageretrm  := '';
--      v_ageretrf  := '';
--    end;

    if work_codcomp is not null and work_codpos is not null then
      begin
        select codjob,jobgrade into v_codjob,v_jobgrade
          from tjobpos
         where codpos  = work_codpos
           and codcomp = work_codcomp;
      exception when no_data_found then
        v_codjob		:= null;
        v_jobgrade	:= null;
      end;
    end if;
    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('codempidh',v_codempidh);
    obj_row.put('codcomph',v_codcomph);
    obj_row.put('codposh',v_codposh);
    obj_row.put('namabb',replace(get_tpostninit_name(work_codpos,global_v_lang),'*',''));
    obj_row.put('stapost',v_stapost);
    obj_row.put('numlvl',v_numlvl);
    --< [START] bow.sarunya | issue4448#5995 [23/12/2023]
    obj_row.put('numlvlen',v_numlvlen);
    --> [END] bow.sarunya | issue4448#5995 [23/12/2023]
    obj_row.put('codjob',v_codjob);
    obj_row.put('jobgrade',v_jobgrade);
    obj_row.put('ageretrm',v_ageretrm);
    obj_row.put('ageretrf',v_ageretrf);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_wage_income_data(json_str_input in clob, json_str_output out clob) is
    param_json            json_object_t;
    obj_row               json_object_t;

    v_amtothr             number;
    v_amtday              number;
    v_sumincom            number;
    v_codcompy            tcenter.codcompy%type;

    v_codcomp             tcenter.codcomp%type;
    v_codempmt            temploy1.codempmt%type;
    v_amtincom1           number;
    v_amtincom2           number;
    v_amtincom3           number;
    v_amtincom4           number;
    v_amtincom5           number;
    v_amtincom6           number;
    v_amtincom7           number;
    v_amtincom8           number;
    v_amtincom9           number;
    v_amtincom10          number;
  begin
    param_json        := json_object_t(json_str_input);
    v_codcomp         := hcm_util.get_string_t(param_json,'codcomp');
    v_codempmt        := hcm_util.get_string_t(param_json,'codempmt');
    v_amtincom1       := hcm_util.get_string_t(param_json,'amtincom1');
    v_amtincom2       := hcm_util.get_string_t(param_json,'amtincom2');
    v_amtincom3       := hcm_util.get_string_t(param_json,'amtincom3');
    v_amtincom4       := hcm_util.get_string_t(param_json,'amtincom4');
    v_amtincom5       := hcm_util.get_string_t(param_json,'amtincom5');
    v_amtincom6       := hcm_util.get_string_t(param_json,'amtincom6');
    v_amtincom7       := hcm_util.get_string_t(param_json,'amtincom7');
    v_amtincom8       := hcm_util.get_string_t(param_json,'amtincom8');
    v_amtincom9       := hcm_util.get_string_t(param_json,'amtincom9');
    v_amtincom10      := hcm_util.get_string_t(param_json,'amtincom10');

--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp   = v_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy  := hcm_util.get_codcomp_level(v_codcomp,1);
    get_wage_income(v_codcompy,v_codempmt,
                    nvl(v_amtincom1,0),nvl(v_amtincom2,0),
                    nvl(v_amtincom3,0),nvl(v_amtincom4,0),
                    nvl(v_amtincom5,0),nvl(v_amtincom6,0),
                    nvl(v_amtincom7,0),nvl(v_amtincom8,0),
                    nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                    v_amtothr,v_amtday,v_sumincom);

    obj_row   := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('amtothr',to_char(v_amtothr,'999,999,990.00'));
    obj_row.put('amtday',to_char(v_amtday,'999,999,990.00'));
    obj_row.put('sumincom',to_char(v_sumincom,'999,999,990.00'));
    -- end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- end get_wage_income_data
  procedure get_head( p_codcomp in varchar2,
                      p_codpos in varchar2,
                      p_codcomph out varchar2,
                      p_codposh out varchar2,
                      p_codempidh out varchar2,
                      p_stapost out varchar2) is

    v_codempidh   temphead.codempidh%type := ''; --from temphead, temphead
    v_codcomph    temphead.codcomph%type := '';
    v_codposh     temphead.codposh%type := '';
    v_stapost     tsecpos.stapost2%type := ''; -- from tsecpos
    v_chk_head1   varchar2(1) := 'N';

    cursor c_head1 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
              decode(codempidh,'%',2,1) sorting
      from    temphead
      where   codempid = p_codempid_query
      order by sorting,numseq;

    cursor c_head2 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
              decode(codempidh,'%',2,1) sorting
      from    temphead
      where   codcomp = p_codcomp
      and     codpos  = p_codpos
      order by sorting,numseq;
  begin
    for j in c_head1 loop
      v_chk_head1  := 'Y' ;
      if j.codempidh  is not null then
        v_codempidh := j.codempidh ;
      else
        v_codcomph  := j.codcomph ;
        v_codposh   := j.codposh ;
      end if;
      exit;
    end loop;
    if 	v_chk_head1 = 'N' then
      for j in c_head2 loop
        v_chk_head1  := 'Y' ;
        if j.codempidh  is not null then
          v_codempidh := j.codempidh ;
        else
          v_codcomph  := j.codcomph ;
          v_codposh   := j.codposh ;
        end if;
        exit;
      end loop;
    end if;
    if v_codcomph is not null then
      begin
        select codempid into v_codempidh
          from temploy1
         where codcomp  = v_codcomph
           and codpos   = v_codposh
           and staemp   in  ('1','3')
           and rownum   = 1;
           v_stapost := null;
      exception when no_data_found then
        begin
          select codempid,stapost2 into v_codempidh,v_stapost
            from tsecpos
           where codcomp	= v_codcomph
             and codpos	  = v_codposh
             and dteeffec <= sysdate
             and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
             and rownum   = 1;
        exception when no_data_found then
          v_codempidh := null;
          v_stapost := null;
        end;
      end;
    end if;
    p_codcomph      := v_codcomph;
    p_codposh       := v_codposh;
    p_codempidh     := v_codempidh;
    p_stapost       := v_stapost;
  end; -- end get_head
  --
  procedure get_income_allowance(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    check_get_allowance;
    if param_msg_error is null then
      gen_income_allowance(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_income_allowance
  --
  procedure gen_income_allowance(json_str_output out clob) is
    obj_row          json_object_t;
    v_incond         varchar2(50);
    v_codcompy       tcompny.codcompy%type;
    v_codcurr        temploy3.codcurr%type;
    type p_num is table of number index by binary_integer;
      v_amtincom    p_num;

    v_amtothr         number;
    v_amtday          number;
    v_sumincom        number;

  begin
    begin
      select  stddec(amtincom1,emp1.codempid,global_v_chken),
              stddec(amtincom2,emp1.codempid,global_v_chken),
              stddec(amtincom3,emp1.codempid,global_v_chken),
              stddec(amtincom4,emp1.codempid,global_v_chken),
              stddec(amtincom5,emp1.codempid,global_v_chken),
              stddec(amtincom6,emp1.codempid,global_v_chken),
              stddec(amtincom7,emp1.codempid,global_v_chken),
              stddec(amtincom8,emp1.codempid,global_v_chken),
              stddec(amtincom9,emp1.codempid,global_v_chken),
              stddec(amtincom10,emp1.codempid,global_v_chken),
              codcurr
      into    v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
              v_codcurr
      from    temploy1 emp1, temploy3 emp3
      where   emp1.codempid   = p_codempid_query
      and     emp1.codempid   = emp3.codempid;
    exception when no_data_found then
      v_amtincom(1)   := 0;
      v_amtincom(2)   := 0;
      v_amtincom(3)   := 0;
      v_amtincom(4)   := 0;
      v_amtincom(5)   := 0;
      v_amtincom(6)   := 0;
      v_amtincom(7)   := 0;
      v_amtincom(8)   := 0;
      v_amtincom(9)   := 0;
      v_amtincom(10)  := 0;
    end;

    for i in 1..10 loop
      v_amtincom(i)   := greatest(0, v_amtincom(i));
    end loop;

    if work_staemp = '1' then
      gen_tincpos ('1',                work_codcomp,          work_codpos,
                   work_numlvl,        work_jobgrade,         work_codjob,
                   work_typpayroll,    work_codempmt,         work_codbrlc,
                   global_v_chken,     v_incond,
                   v_amtincom(1),      v_amtincom(2),         v_amtincom(3),
                   v_amtincom(4),      v_amtincom(5),         v_amtincom(6),
                   v_amtincom(7),      v_amtincom(8),         v_amtincom(9),
                   v_amtincom(10));
    elsif work_staemp = '3' then
      gen_tincpos ('2',                 work_codcomp,          work_codpos,
                   work_numlvl,         work_jobgrade,         work_codjob,
                   work_typpayroll,     work_codempmt,         work_codbrlc,
                   global_v_chken,      v_incond,
                   v_amtincom(1),       v_amtincom(2),        v_amtincom(3),
                   v_amtincom(4),       v_amtincom(5),        v_amtincom(6),
                   v_amtincom(7),       v_amtincom(8),        v_amtincom(9),
                   v_amtincom(10));
    end if;

    v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    if v_codcurr is null then
      begin
        select codcurr
          into v_codcurr
          from TCONTRPY
         where codcompy = v_codcompy
           and dteeffec	= (select max(dteeffec)
                           from   TCONTRPY
                           where  codcompy = v_codcompy
                           and    dteeffec <= trunc(sysdate) )  ;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_row     := json_object_t();
    get_wage_income(v_codcompy,work_codempmt,
                    nvl(v_amtincom(1),0),nvl(v_amtincom(2),0),
                    nvl(v_amtincom(3),0),nvl(v_amtincom(4),0),
                    nvl(v_amtincom(5),0),nvl(v_amtincom(6),0),
                    nvl(v_amtincom(7),0),nvl(v_amtincom(8),0),
                    nvl(v_amtincom(9),0),nvl(v_amtincom(10),0),
                    v_amtothr,v_amtday,v_sumincom);
    obj_row.put('coderror','200');
    obj_row.put('codempid',p_codempid_query);
    obj_row.put('codcurr',v_codcurr);
    -- obj_row.put('afpro','v_afpro');
    obj_row.put('amtothr',to_char(v_amtothr,'fm999,999,990.00'));
    obj_row.put('amtday',to_char(v_amtday,'fm999,999,990.00'));
    obj_row.put('sumincom',to_char(v_sumincom,'fm999,999,990.00'));
    for i in 1..10 loop
      obj_row.put('amtincom'||i,v_amtincom(i));
    end loop;
    -- end if;
    json_str_output := obj_row.to_clob;
  end; -- end gen_income_allowance
  --
  procedure get_data_income(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    check_get_data_income;
    if param_msg_error is null then
      gen_data_income(json_str_output);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_data_income
  --
  procedure gen_data_income(json_str_output out clob) is
    v_codcompy        tcompny.codcompy%type;
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_json_input      clob;
    v_json_codincom   clob;
    v_cnt             number  := 0;
  begin
--    begin
--      select  codcompy
--      into    v_codcompy
--      from    tcenter
--      where   codcomp = work_codcomp;
--    exception when no_data_found then
--      v_codcompy  := null;
--    end;
    v_codcompy        := hcm_util.get_codcomp_level(work_codcomp,1);
    v_json_input      := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||work_codempmt||'","p_lang":"'||global_v_lang||'"}';
    v_json_codincom   := hcm_pm.get_codincom(v_json_input);
    param_json        := json_object_t(v_json_codincom);
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      if hcm_util.get_string_t(param_json_row,'codincom') is not null then
        v_cnt   := v_cnt + 1;
      end if;
    end loop;
    if v_cnt > 0 then
      json_str_output   := v_json_codincom;
    else
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCONTPMD');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  end; -- end gen_data_income
  --
  procedure gen_default_value_by_codcomp(json_str_output out clob) is
    obj_row          json_object_t;
    v_codcompy       tcompny.codcompy%type;
    v_codcurr        temploy3.codcurr%type;
    v_ageretrm       number;
    v_ageretrf       number;
  begin
    obj_row     := json_object_t();
    v_codcompy  := hcm_util.get_codcomp_level(work_codcomp,1);
    begin
      select codcurr
        into v_codcurr
        from TCONTRPY
       where codcompy = v_codcompy
         and dteeffec	= (select max(dteeffec)
                         from   TCONTRPY
                         where  codcompy = v_codcompy
                         and    dteeffec <= trunc(sysdate) )  ;
		exception when no_data_found then
      null;
		end;
    --
    begin
      select ageretrm,ageretrf
        into v_ageretrm,v_ageretrf
        from tcompny
       where codcompy = v_codcompy;
		exception when no_data_found then
      null;
		end;
    obj_row.put('coderror','200');
    obj_row.put('codcurr',v_codcurr);
    obj_row.put('ageretrm',v_ageretrm);
    obj_row.put('ageretrf',v_ageretrf);
    json_str_output := obj_row.to_clob;
  end; -- end gen_default_value_by_codcomp
  --
  procedure get_default_value_by_codcomp(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_tab_work(json_object_t(json_str_input));
    check_get_default_value_by_codcomp;
    if param_msg_error is null then
      gen_default_value_by_codcomp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_default_value_by_codcomp
  --
  procedure get_popup_change_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_detail(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_popup_change_detail
  --
  procedure gen_popup_change_detail(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    json_obj      json_object_t;
    v_rcnt        number  := 0;
    v_numpage     varchar2(100);
    v_dteempmt    date;
    v_coltype     varchar2(100);

    cursor c1 is
      select  '1' typedit,codempid,dteedit,numpage,fldedit,null as typkey,null as fldkey,
              desold,desnew,flgenc,codtable,coduser,null codedit,
              '' as flgdata
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '2' typedit,codempid,dteedit,numpage,fldedit,typkey,fldkey,
              desold,desnew,flgenc,codtable,coduser,
              decode(typkey,'N',to_char(numseq),
                            'C',codseq,
                            'D',to_char(dteseq,'dd/mm/yyyy'),null) as codedit,
              flgdata
      from    ttemlog2
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '3' typedit,codempid,dteedit,numpage,typdeduct as fldedit,null as typkey,null as fldkey,
              desold,desnew,'Y' flgenc,codtable,coduser,coddeduct codedit,
              '' as flgdata
      from    ttemlog3
      where   codempid = p_codempid_query
      and     numpage = v_numpage
      order by dteedit desc,codedit;
  begin
    json_obj        := json_object_t(json_str_input);
    v_numpage       := hcm_util.get_string_t(json_obj,'numpage');
    obj_row         := json_object_t();

    begin
      select  dteempmt into v_dteempmt
      from    temploy1
      where   codempid  = p_codempid_query;
		exception when no_data_found then
			v_dteempmt  := null;
		end;

    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('typedit',i.typedit);
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteedit',to_char(i.dteedit,'dd/mm/yyyy hh24:mi:ss'));
      obj_data.put('numpage',i.numpage);
      obj_data.put('fldedit',i.fldedit);

      if i.typedit = '3' then
        obj_data.put('data1',get_tlistval_name('TYPEDEDUCT',i.fldedit,global_v_lang));
        obj_data.put('data2',get_tcodeduct_name(i.codedit,global_v_lang));
      else



        --<<Final Test Phase 1 V11 #3036
        if i.fldedit = 'DTEDUEPR' then
          obj_data.put('data1',get_label_name('HRPMC2E1T3',global_v_lang,360));--obj_data.put('data1','ctrl_label4.di_v150');
        else
          obj_data.put('data1',get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang));
        end if;

            if i.fldedit = 'YREDATRQ' then
              obj_data.put('data1',get_label_name('HRPMC2E1T3',global_v_lang,370));
            else
              obj_data.put('data1',get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang));
            end if;

            -->>Final Test Phase 1 V11 #3036
            if i.typedit = '1' then
              obj_data.put('data2',i.codedit);
            else
             if i.typkey = 'D' then
                obj_data.put('data2',hcm_util.get_date_buddhist_era(to_date(i.codedit,'dd/mm/yyyy')));
             else
                obj_data.put('data2',i.codedit);
             end if;
           end if;

      end if;
      obj_data.put('typkey',i.typkey);
      obj_data.put('fldkey',i.fldkey);

      if i.flgenc = 'Y' then
        if i.desold is not null then
          obj_data.put('desold',to_char(stddec(i.desold,p_codempid_query,global_v_chken),'fm999,999,999,999,990.00'));
        end if;
        if i.desnew is not null then
          obj_data.put('desnew',to_char(stddec(i.desnew,p_codempid_query,global_v_chken),'fm999,999,999,999,990.00'));
        end if;
      else
        if i.fldedit = 'DTEDUEPR' then
          if i.desold is not null then
            obj_data.put('desold',(add_months(to_date(i.desold,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
          if i.desnew is not null then
            obj_data.put('desnew',(add_months(to_date(i.desnew,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
      --  elsif i.fldedit in ('STAYEAR','DTEGYEAR') then
       elsif ((i.fldedit  like '%YRE%' or i.fldedit  like '%YEAR%') and v_coltype = 'NUMBER') then
          obj_data.put('desold',hcm_util.get_year_buddhist_era(i.desold));
          obj_data.put('desnew',hcm_util.get_year_buddhist_era(i.desnew));
        else
          begin
            select coltype
              into v_coltype
              from col
             where cname    = i.fldedit
               and tname    = i.codtable
               and rownum <= 1;
               exception when no_data_found then
                v_coltype := null;
          end;

          if v_coltype = 'NUMBER' then
                obj_data.put('desold',i.desold);
                obj_data.put('desnew',i.desnew);
          elsif v_coltype = 'DATE' then
                obj_data.put('desold',hcm_util.get_date_buddhist_era(to_date(i.desold,'dd/mm/yyyy')));
                obj_data.put('desnew',hcm_util.get_date_buddhist_era(to_date(i.desnew,'dd/mm/yyyy')));
          else
                obj_data.put('desold',get_desciption (i.codtable,i.fldedit,i.desold));
                obj_data.put('desnew',get_desciption (i.codtable,i.fldedit,i.desnew));
          end if;
        end if;
      end if;
      obj_data.put('flgenc',i.flgenc);
      obj_data.put('codtable',i.codtable);
      obj_data.put('coduser',i.coduser);
      obj_data.put('codedit',i.codedit);
      obj_data.put('exphighli',get_tsetup_value('SET_HIGHLIGHT'));
      obj_data.put('flgdata',i.flgdata);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end; -- gen_popup_change_detail
  --
  procedure get_map_smart_card(json_str_input in clob, json_str_output out clob) is
    v_adrreg              varchar2(4000 char);
    v_codtitle            tlistval.list_value%type;
    v_codsex              temploy1.codsex%type;
    v_ageretrm            number;
    v_ageretrf            number;
  begin
    initial_value(json_str_input);
    initial_smart_card(json_str_input);
    check_get_map_smart_card(json_str_output);
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_map_smart_card
  --
  procedure get_default_value(json_str_input in clob, json_str_output out clob) is
    json_str        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number  := 0;
    v_codapp        tsetdeflt.codapp%type;
    v_str_numpage   varchar2(4000 char);
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcompny.codcompy%type;
    v_ageretrm      tcompny.ageretrm%type;
    v_ageretrf      tcompny.ageretrf%type;

    cursor c_default is
      select  h.numpage,tablename,fieldname,defaultval
      from    tsetdeflh h, tsetdeflt d
--      where   h.codapp            = v_codapp
      where   (instr(v_codapp,','||h.codapp||',') > 0 or h.codapp = v_codapp)
      and     instr(v_str_numpage,','||h.numpage||',') > 0
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    json_str        := json_object_t(json_str_input);
    v_codapp        := hcm_util.get_string_t(json_str,'p_codapp');
    v_str_numpage   := hcm_util.get_string_t(json_str,'p_numpage');
    v_codempid      := hcm_util.get_string_t(json_str,'p_codempid');

    begin
      select  hcm_util.get_codcomp_level(codcomp,1)
      into    v_codcompy
      from    temploy1
      where   codempid    = v_codempid;
    end;
    begin
      select  ageretrm,ageretrf
      into    v_ageretrm,v_ageretrf
      from    tcompny
      where   codcompy    = v_codcompy;
    exception when no_data_found then
      v_ageretrm  := '60';
      v_ageretrf  := '60';
    end;
    obj_row     := json_object_t();
    if v_ageretrm is not null then
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numpage','HRPMC2E41');
      obj_data.put('tablename','TCOMPNY');
      obj_data.put('fieldname','AGERETRM');
      obj_data.put('defaultval',v_ageretrm);
      obj_row.put(v_rcnt - 1,obj_data);

      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numpage','HRPMC2E41');
      obj_data.put('tablename','TCOMPNY');
      obj_data.put('fieldname','AGERETRF');
      obj_data.put('defaultval',v_ageretrf);
      obj_row.put(v_rcnt - 1,obj_data);
    end if;
    for i in c_default loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numpage',i.numpage);
      obj_data.put('tablename',i.tablename);
      obj_data.put('fieldname',i.fieldname);
      obj_data.put('defaultval',i.defaultval);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_default_value
  --
  procedure save_personal_tax(json_str_input in clob, json_str_output out clob) is
    param_json                      json_object_t;
    param_json_personal             json_object_t;
    param_json_address              json_object_t;
    param_json_work                 json_object_t;
    param_json_travel               json_object_t;
    param_json_incom                json_object_t;
    param_json_incom_detail         json_object_t;
    param_json_incom_table          json_object_t;
    param_json_tax                  json_object_t;
    param_json_tax_detail           json_object_t;
    param_json_over_income          json_object_t;
    param_json_tax_exemption        json_object_t;
    param_json_tax_allowance        json_object_t;
    param_json_others_deduct        json_object_t;
    param_json_spouse               json_object_t;
    param_json_sp_over_income       json_object_t;
    param_json_sp_tax_exemption     json_object_t;
    param_json_sp_tax_deduct        json_object_t;
    param_json_sp_others_deduct     json_object_t;
    param_json_hisname              json_object_t;
    param_json_document             json_object_t;
    v_flgsecu			                  boolean;
    v_zupdsal                       varchar2(1);
    v_response_json                 json_object_t;
  begin
    initial_value(json_str_input);
--    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json_personal         := hcm_util.get_json_t(param_json, 'personal');
--    param_json_personal         := hcm_util.get_json(param_json,'personal');
    param_json_address          := hcm_util.get_json_t(param_json,'address');
    param_json_work             := hcm_util.get_json_t(param_json,'work');
    param_json_travel           := hcm_util.get_json_t(param_json,'travel');
    param_json_incom            := hcm_util.get_json_t(param_json,'income');
    param_json_incom_detail     := hcm_util.get_json_t(param_json_incom,'detail');
    param_json_incom_table      := hcm_util.get_json_t(hcm_util.get_json_t(param_json_incom,'table'),'rows');
    param_json_tax              := hcm_util.get_json_t(param_json,'tax');
    param_json_tax_detail       := hcm_util.get_json_t(param_json_tax,'tax_detail');
    param_json_over_income      := hcm_util.get_json_t(param_json_tax,'over_income');
    param_json_tax_exemption    := hcm_util.get_json_t(hcm_util.get_json_t(param_json_tax,'tax_exemption'),'rows');
    param_json_tax_allowance    := hcm_util.get_json_t(hcm_util.get_json_t(param_json_tax,'tax_allowance'),'rows');
    param_json_others_deduct    := hcm_util.get_json_t(hcm_util.get_json_t(param_json_tax,'others_deduct'),'rows');
    param_json_spouse           := hcm_util.get_json_t(param_json,'spouse');
    param_json_sp_over_income   := hcm_util.get_json_t(param_json_spouse,'sp_over_income');
    param_json_sp_tax_exemption := hcm_util.get_json_t(hcm_util.get_json_t(param_json_spouse,'sp_tax_exemption'),'rows');
    param_json_sp_tax_deduct    := hcm_util.get_json_t(hcm_util.get_json_t(param_json_spouse,'sp_tax_deduct'),'rows');
    param_json_sp_others_deduct := hcm_util.get_json_t(hcm_util.get_json_t(param_json_spouse,'sp_others_deduct'),'rows');
    param_json_hisname          := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'hisname'),'rows');
    param_json_document         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'document'),'rows');
    initial_tab_personal(param_json_personal);
    initial_tab_address(param_json_address);
    initial_tab_work(param_json_work);
    initial_tab_travel(param_json_travel);
    initial_tab_income(param_json_incom_detail, param_json_incom_table);
    initial_tab_tax(param_json_tax_detail,
                    param_json_over_income,
                    param_json_tax_exemption,
                    param_json_tax_allowance,
                    param_json_others_deduct);
    initial_tab_spouse(param_json_sp_over_income,
                       param_json_sp_tax_exemption,
                       param_json_sp_tax_deduct,
                       param_json_sp_others_deduct);
    initial_tab_hisname(param_json_hisname);
    initial_tab_document(param_json_document);
    check_tab_personal;
    if param_msg_error is null then
      check_tab_address;
      if param_msg_error is null then
        check_tab_work;
        if param_msg_error is null then
          check_tab_travel;
          if param_msg_error is null then
            check_tab_income;
            if param_msg_error is null then
              check_tab_tax_detail;
              if param_msg_error is null then
                check_tab_over_income;
                if param_msg_error is null then
                  check_tab_sp_over_income;
                  if param_msg_error is null then
                    if p_codempid_query is null then
                      p_codempid_query    :=  gen_newid;
                      if param_msg_error is null then
                        std_genid2.upd_id(parameter_groupid,parameter_year,parameter_month,parameter_running,global_v_coduser);
                      end if;
                --      commit;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;

    if param_msg_error is null then
      save_temploy1;
      save_temploy2;
      save_temploy3;
      save_tlastded;
      save_ttnewemp;
      save_tssmemb;
      save_tspouse;
      save_thisname;
      save_tappldoc;
      save_tempimge;

    	v_flgsecu := secur_main.secur1(work_codcomp,work_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_zupdsal = 'Y' then
        upd_tempded('163','E','E',tax_exemption);
        upd_tempded('164','D','E',tax_allowance);
        upd_tempded('165','O','E',others_deduct);
        upd_tempded('172','E','S',sp_tax_exemption);
        upd_tempded('173','D','S',sp_tax_deduct);
        upd_tempded('174','O','S',sp_others_deduct);
      end if;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
      -- specific response --
      v_response_json := json_object_t(get_response_message(null,param_msg_error,global_v_lang));
      v_response_json.put('codempid',p_codempid_query);

      json_str_output := v_response_json.to_clob;
      return;
    else
      rollback;
    end if;

    if param_flgwarn = 'WARNE' then
      param_flgwarn := null;
    elsif param_flgwarn not like 'WARN%' then
      param_flgwarn := null;
    end if;
    if p_flg_warn = 'N' then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
    end if;
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure delete_personal_tax(json_str_input in clob, json_str_output out clob) is
    param_json                      json_object_t;
    param_json_work                 json_object_t;
  begin
    initial_value(json_str_input);
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json_work             := hcm_util.get_json_t(param_json,'work');
    initial_tab_work(param_json_work);
    check_delete_personal;
    if param_msg_error is null then
    	delete from temploy1 where codempid = p_codempid_query;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end delete_personal_tax
  --
  procedure update_filedoc( p_codempid  varchar2,
                            p_filedoc   varchar2,
                            p_namedoc   varchar2,
                            p_type_doc  varchar2,
                            p_coduser   varchar2,
                            p_numrefdoc in out varchar2) is
    v_numappl     temploy1.numappl%type;
    v_max_refdoc  tappldoc.numrefdoc%type;
    v_numrefdoc   tappldoc.numrefdoc%type;
    v_doc_seq     tappldoc.numseq%type;
  begin
    begin
      select  nvl(numappl,p_codempid)
      into    v_numappl
      from    temploy1
      where   codempid = p_codempid;
    exception when no_data_found then
      v_numappl := p_codempid;
    end;

    if p_filedoc is not null then
      if p_numrefdoc is not null then
        update  tappldoc
        set     filedoc   = p_filedoc,
                coduser   = p_coduser
        where   numrefdoc = p_numrefdoc;
      else
        begin
          select  nvl(max(substr(numrefdoc, -5)),0)
          into    v_max_refdoc
          from    tappldoc
          where   numappl   = v_numappl
          and     numrefdoc is not null;
        end;

        begin
          select  nvl(max(numseq),0) + 1
          into    v_doc_seq
          from    tappldoc
          where   numappl   = v_numappl;
        end;

        v_numrefdoc   := p_codempid||lpad(to_number(v_max_refdoc) + 1, 5, '0');
        p_numrefdoc   := v_numrefdoc;
        insert into tappldoc(numappl,numseq,codempid,typdoc,namdoc,
                             filedoc,dterecv,flgresume,codcreate,coduser,numrefdoc)
                     values (v_numappl,v_doc_seq,p_codempid,p_type_doc,p_namedoc,
                             p_filedoc,trunc(sysdate),'N',p_coduser,p_coduser,v_numrefdoc);
      end if;
    else
      delete from tappldoc where numappl = v_numappl and numrefdoc = p_numrefdoc;
      p_numrefdoc   := null;
    end if;
  end; -- end update_filedoc
  --
  procedure get_msg_warning(json_str_input in clob, json_str_output out clob) is
    json_input    json_object_t;
    obj_data      json_object_t;

    v_chk_codempid  temploy1.codempid%type;
    v_chk_staemp    temploy1.staemp%type;

    v_errorno         varchar2(20);
    v_msg_warning     varchar2(2000);
    v_ctrl_codnatnl   varchar2(100);
    v_code            varchar2(100);

    v_numoffid    varchar2(2000);
    v_codnatnl    varchar2(2000);
    v_dteempdb    date;
    v_numbank     varchar2(2000);
    v_numbank2    varchar2(2000);
    v_ch          boolean;
  begin
    initial_value(json_str_input);
    json_input    := json_object_t(json_str_input);
    v_numoffid    := hcm_util.get_string_t(json_input,'p_numoffid');
    v_codnatnl    := hcm_util.get_string_t(json_input,'p_codnatnl');
    v_dteempdb    := to_date(hcm_util.get_string_t(json_input,'p_dteempdb'),'dd/mm/yyyy');
    v_numbank     := hcm_util.get_string_t(json_input,'p_numbank');
    v_numbank2    := hcm_util.get_string_t(json_input,'p_numbank2');

    begin
      select  defaultval
      into    v_ctrl_codnatnl
      from    tsetdeflt
      where   codapp    = 'HRPMC2E'
      and     numpage   = 'HRPMC2E11'
      and     fieldname = 'CODNATNL'
      and     seqno     = 1;
    exception when no_data_found then
      null;
    end;

    if v_numoffid is not null then
      if v_codnatnl is not null and v_ctrl_codnatnl = v_codnatnl then
        v_ch := check_numoffid(v_numoffid);
        if not v_ch then -- Start check warning
          v_errorno       := 'PM0059';
          v_msg_warning   := get_errorm_name('PM0059',global_v_lang);
          goto check_end;
        end if;
      end if;

      begin
        select numoffid	into v_code
          from tbcklst
         where numoffid   = v_numoffid;
        v_errorno       := 'HR2006';
        v_msg_warning   := get_errorm_name('HR2006',global_v_lang);
        goto check_end;
      exception when no_data_found then
        null;
      end;

      begin
        select a.codempid,a.staemp
          into v_chk_codempid,v_chk_staemp
          from temploy1 a,temploy2 b
         where a.codempid = b.codempid
           and b.numoffid = v_numoffid
           and (a.codempid <> p_codempid_query or p_codempid_query is null)
           and a.staemp   <> '9'
           and rownum = 1;
        v_errorno     := 'PM0015';
        v_msg_warning := replace(get_errorm_name('PM0015',global_v_lang),get_label_name('HRPMC2E1T1','102',10),
                         v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                         get_label_name('HRPMC2E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang));
        goto check_end;
      exception when no_data_found then
        null;
      end;
    end if;

    if v_dteempdb is not null then
      if (months_between(sysdate,v_dteempdb)) / 12 < 18 then
        v_errorno       := 'PM0014';
        v_msg_warning   := get_errorm_name('PM0014',global_v_lang);
        goto check_end;
      end if;
    end if;
/*
    if v_numbank is not null or v_numbank2 is not null then
      begin
        select t1.codempid,t1.staemp
          into v_chk_codempid,v_chk_staemp
          from temploy1 t1, temploy3 t3
         where t1.codempid  = t3.codempid
           and (numbank in (v_numbank, v_numbank2) or numbank2 in (v_numbank, v_numbank2))
           and (t1.codempid <> p_codempid_query or p_codempid_query is null)
           and rownum = 1;
        v_errorno     := 'PM0024';
        v_msg_warning := get_errorm_name('PM0024',global_v_lang)||' ('||
                         v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                         get_label_name('HRPMC2E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang)||')';
      exception when no_data_found then
        null;
      end;
    end if;
*/
    <<check_end>>
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('errorno',v_errorno);
    obj_data.put('msg_warning',v_msg_warning);
    json_str_output   := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
