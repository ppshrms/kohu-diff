--------------------------------------------------------
--  DDL for Package Body HRRC21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E" is
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

    b_index_numappl     := hcm_util.get_string_t(json_obj,'p_numappl');
  end; -- end initial_value
  --
  procedure initial_tapplinf (json_obj in json_object_t,
                             t_tapplinf out tapplinf%rowtype) is
  begin
    t_tapplinf.codempid        := hcm_util.get_string_t(json_obj,'codempid');
    t_tapplinf.statappl        := hcm_util.get_string_t(json_obj,'statappl');
    t_tapplinf.flgqualify      := hcm_util.get_string_t(json_obj,'flgqualify');
    t_tapplinf.dtetrnjo        := to_date(hcm_util.get_string_t(json_obj,'dtetrnjo'),'dd/mm/yyyy');
    t_tapplinf.namimage        := hcm_util.get_string_t(json_obj,'namimage');
    t_tapplinf.codtitle        := hcm_util.get_string_t(json_obj,'codtitle');
    t_tapplinf.namfirste       := hcm_util.get_string_t(json_obj,'namfirste');
    t_tapplinf.namfirstt       := hcm_util.get_string_t(json_obj,'namfirstt');
    t_tapplinf.namfirst3       := hcm_util.get_string_t(json_obj,'namfirst3');
    t_tapplinf.namfirst4       := hcm_util.get_string_t(json_obj,'namfirst4');
    t_tapplinf.namfirst5       := hcm_util.get_string_t(json_obj,'namfirst5');
    t_tapplinf.namlaste        := hcm_util.get_string_t(json_obj,'namlaste');
    t_tapplinf.namlastt        := hcm_util.get_string_t(json_obj,'namlastt');
    t_tapplinf.namlast3        := hcm_util.get_string_t(json_obj,'namlast3');
    t_tapplinf.namlast4        := hcm_util.get_string_t(json_obj,'namlast4');
    t_tapplinf.namlast5        := hcm_util.get_string_t(json_obj,'namlast5');
    t_tapplinf.nickname        := hcm_util.get_string_t(json_obj,'nickname');
    t_tapplinf.codpos1         := hcm_util.get_string_t(json_obj,'codpos1');
    t_tapplinf.codpos2         := hcm_util.get_string_t(json_obj,'codpos2');
    t_tapplinf.codbrlc1        := hcm_util.get_string_t(json_obj,'codbrlc1');
    t_tapplinf.codbrlc2        := hcm_util.get_string_t(json_obj,'codbrlc2');
    t_tapplinf.codbrlc3        := hcm_util.get_string_t(json_obj,'codbrlc3');
    t_tapplinf.amtincfm        := hcm_util.get_string_t(json_obj,'amtincfm');
    t_tapplinf.amtincto        := hcm_util.get_string_t(json_obj,'amtincto');
    t_tapplinf.codcurr         := hcm_util.get_string_t(json_obj,'codcurr');
    t_tapplinf.codmedia        := hcm_util.get_string_t(json_obj,'codmedia');
    t_tapplinf.flgcar          := hcm_util.get_string_t(json_obj,'flgcar');
    t_tapplinf.carlicid        := hcm_util.get_string_t(json_obj,'carlicid');
    t_tapplinf.flgwork         := hcm_util.get_string_t(json_obj,'flgwork');
    t_tapplinf.numoffid        := hcm_util.get_string_t(json_obj,'numoffid');
    t_tapplinf.dteoffid        := to_date(hcm_util.get_string_t(json_obj,'dteoffid'),'dd/mm/yyyy');
    t_tapplinf.adrissue        := hcm_util.get_string_t(json_obj,'adrissue');
    t_tapplinf.codprov         := hcm_util.get_string_t(json_obj,'codprov');
    t_tapplinf.numtaxid        := hcm_util.get_string_t(json_obj,'numtaxid');
    t_tapplinf.numsaid         := hcm_util.get_string_t(json_obj,'numsaid');
    t_tapplinf.numpasid        := hcm_util.get_string_t(json_obj,'numpasid');
    t_tapplinf.dtepasid        := to_date(hcm_util.get_string_t(json_obj,'dtepasid'),'dd/mm/yyyy');
    t_tapplinf.numlicid        := hcm_util.get_string_t(json_obj,'numlicid');
    t_tapplinf.dtelicid        := to_date(hcm_util.get_string_t(json_obj,'dtelicid'),'dd/mm/yyyy');
    t_tapplinf.dteempdb        := to_date(hcm_util.get_string_t(json_obj,'dteempdb'),'dd/mm/yyyy');
    t_tapplinf.coddomcl        := hcm_util.get_string_t(json_obj,'coddomcl');
    t_tapplinf.codsex          := hcm_util.get_string_t(json_obj,'codsex');
    t_tapplinf.weight          := hcm_util.get_string_t(json_obj,'weight');
    t_tapplinf.height          := hcm_util.get_string_t(json_obj,'height');
    t_tapplinf.codblood        := hcm_util.get_string_t(json_obj,'codblood');
    t_tapplinf.codorgin        := hcm_util.get_string_t(json_obj,'codorgin');
    t_tapplinf.codnatnl        := hcm_util.get_string_t(json_obj,'codnatnl');
    t_tapplinf.codrelgn        := hcm_util.get_string_t(json_obj,'codrelgn');
    t_tapplinf.stamarry        := hcm_util.get_string_t(json_obj,'stamarry');
    t_tapplinf.stamilit        := hcm_util.get_string_t(json_obj,'stamilit');
    t_tapplinf.numprmid        := hcm_util.get_string_t(json_obj,'numprmid');
    t_tapplinf.dteprmst        := to_date(hcm_util.get_string_t(json_obj,'dteprmst'),'dd/mm/yyyy');
    t_tapplinf.dteprmen        := to_date(hcm_util.get_string_t(json_obj,'dteprmen'),'dd/mm/yyyy');
    t_tapplinf.adrrege         := hcm_util.get_string_t(json_obj,'adrrege');
    t_tapplinf.adrregt         := hcm_util.get_string_t(json_obj,'adrregt');
    t_tapplinf.adrreg3         := hcm_util.get_string_t(json_obj,'adrreg3');
    t_tapplinf.adrreg4         := hcm_util.get_string_t(json_obj,'adrreg4');
    t_tapplinf.adrreg5         := hcm_util.get_string_t(json_obj,'adrreg5');
    t_tapplinf.codprovr        := hcm_util.get_string_t(json_obj,'codprovr');
    t_tapplinf.codsubdistr     := hcm_util.get_string_t(json_obj,'codsubdistr');
    t_tapplinf.coddistr        := hcm_util.get_string_t(json_obj,'coddistr');
    t_tapplinf.codcntyi        := hcm_util.get_string_t(json_obj,'codcntyi');
    t_tapplinf.numtelemr       := hcm_util.get_string_t(json_obj,'numtelemr');
    t_tapplinf.numtelehr       := hcm_util.get_string_t(json_obj,'numtelehr');
    t_tapplinf.adrconte        := hcm_util.get_string_t(json_obj,'adrconte');
    t_tapplinf.adrcontt        := hcm_util.get_string_t(json_obj,'adrcontt');
    t_tapplinf.adrcont3        := hcm_util.get_string_t(json_obj,'adrcont3');
    t_tapplinf.adrcont4        := hcm_util.get_string_t(json_obj,'adrcont4');
    t_tapplinf.adrcont5        := hcm_util.get_string_t(json_obj,'adrcont5');
    t_tapplinf.codprovc        := hcm_util.get_string_t(json_obj,'codprovc');
    t_tapplinf.coddistc        := hcm_util.get_string_t(json_obj,'coddistc');
    t_tapplinf.codsubdistc     := hcm_util.get_string_t(json_obj,'codsubdistc');
    t_tapplinf.codposte        := hcm_util.get_string_t(json_obj,'codposte');
    t_tapplinf.codcntyc        := hcm_util.get_string_t(json_obj,'codcntyc');
    t_tapplinf.codpostc        := hcm_util.get_string_t(json_obj,'codpostc');
    t_tapplinf.numtelem        := hcm_util.get_string_t(json_obj,'numtelem');
    t_tapplinf.numteleh        := hcm_util.get_string_t(json_obj,'numteleh');
    t_tapplinf.email           := hcm_util.get_string_t(json_obj,'email');
    t_tapplinf.stadisb         := hcm_util.get_string_t(json_obj,'stadisb');
    t_tapplinf.numdisab        := hcm_util.get_string_t(json_obj,'numdisab');
    t_tapplinf.typdisp         := hcm_util.get_string_t(json_obj,'typdisp');
    t_tapplinf.dtedisb         := to_date(hcm_util.get_string_t(json_obj,'dtedisb'),'dd/mm/yyyy');
    t_tapplinf.dtedisen        := to_date(hcm_util.get_string_t(json_obj,'dtedisen'),'dd/mm/yyyy');
    t_tapplinf.desdisp         := hcm_util.get_string_t(json_obj,'desdisp');
    t_tapplinf.addinfo         := hcm_util.get_string_t(json_obj,'addinfo');
    t_tapplinf.actstudy        := hcm_util.get_string_t(json_obj,'actstudy');
    t_tapplinf.specabi         := hcm_util.get_string_t(json_obj,'specabi');
    t_tapplinf.compabi         := hcm_util.get_string_t(json_obj,'compabi');
    t_tapplinf.typthai         := hcm_util.get_string_t(json_obj,'typthai');
    t_tapplinf.typeng          := hcm_util.get_string_t(json_obj,'typeng');
    t_tapplinf.numreql         := hcm_util.get_string_t(json_obj,'numreql');
    t_tapplinf.codposl         := hcm_util.get_string_t(json_obj,'codposl');
    t_tapplinf.codcompl        := hcm_util.get_string_t(json_obj,'codcompl');
    t_tapplinf.numreqc         := hcm_util.get_string_t(json_obj,'numreqc');
    t_tapplinf.codposc         := hcm_util.get_string_t(json_obj,'codposc');
    t_tapplinf.codcomp         := hcm_util.get_string_t(json_obj,'codcomp');
    t_tapplinf.codempmt        := hcm_util.get_string_t(json_obj,'codempmt');
    t_tapplinf.qtywkemp        := hcm_util.get_string_t(json_obj,'qtywkemp');
    t_tapplinf.qtyduepr        := hcm_util.get_string_t(json_obj,'qtyduepr');
    t_tapplinf.dteappl         := to_date(hcm_util.get_string_t(json_obj,'dteappl'),'dd/mm/yyyy');
    t_tapplinf.qtyscore        := hcm_util.get_string_t(json_obj,'qtyscore');
    t_tapplinf.stasign         := hcm_util.get_string_t(json_obj,'stasign');
    t_tapplinf.descrej         := hcm_util.get_string_t(json_obj,'descrej');
    t_tapplinf.codreq          := hcm_util.get_string_t(json_obj,'codreq');
    t_tapplinf.codconf         := hcm_util.get_string_t(json_obj,'codconf');
    t_tapplinf.dteconff        := to_date(hcm_util.get_string_t(json_obj,'dteconff'),'dd/mm/yyyy');
    t_tapplinf.dteappoist      := to_date(hcm_util.get_string_t(json_obj,'dteappoist'),'dd/mm/yyyy');
    t_tapplinf.dteappoien      := to_date(hcm_util.get_string_t(json_obj,'dteappoien'),'dd/mm/yyyy');
    t_tapplinf.codappr         := hcm_util.get_string_t(json_obj,'codappr');
    t_tapplinf.dteappr         := to_date(hcm_util.get_string_t(json_obj,'dteappr'),'dd/mm/yyyy');
    t_tapplinf.codrej          := hcm_util.get_string_t(json_obj,'codrej');
    t_tapplinf.remark          := hcm_util.get_string_t(json_obj,'remark');
    t_tapplinf.flgblkls        := hcm_util.get_string_t(json_obj,'flgblkls');
    t_tapplinf.dteempmt        := to_date(hcm_util.get_string_t(json_obj,'dteempmt'),'dd/mm/yyyy');
    t_tapplinf.codemprc        := hcm_util.get_string_t(json_obj,'codemprc');
    t_tapplinf.amtsal          := hcm_util.get_string_t(json_obj,'amtsal');
    t_tapplinf.codfoll         := hcm_util.get_string_t(json_obj,'codfoll');
    t_tapplinf.dtefoll         := to_date(hcm_util.get_string_t(json_obj,'dtefoll'),'dd/mm/yyyy');
    t_tapplinf.numdoc          := hcm_util.get_string_t(json_obj,'numdoc');
  end; -- end initial_applinf
  --
  procedure initial_tapplfm (json_obj in json_object_t,t_tapplfm out tapplfm%rowtype) is
  begin
    t_tapplfm.numappl         := hcm_util.get_string_t(json_obj,'numappl');
    t_tapplfm.codempidsp      := hcm_util.get_string_t(json_obj,'codempidsp');
    t_tapplfm.namimgsp        := hcm_util.get_string_t(json_obj,'namimgsp');
    t_tapplfm.codtitle        := hcm_util.get_string_t(json_obj,'codtitle');
    t_tapplfm.namfirst        := hcm_util.get_string_t(json_obj,'namfirst');
    t_tapplfm.namlast         := hcm_util.get_string_t(json_obj,'namlast');
    t_tapplfm.namsp           := hcm_util.get_string_t(json_obj,'namsp');
    t_tapplfm.numoffid        := hcm_util.get_string_t(json_obj,'numoffid');
    t_tapplfm.stalife         := hcm_util.get_string_t(json_obj,'stalife');
    t_tapplfm.desnoffi        := hcm_util.get_string_t(json_obj,'desnoffi');
    t_tapplfm.codspocc        := hcm_util.get_string_t(json_obj,'codspocc');
    t_tapplfm.codtitlc        := hcm_util.get_string_t(json_obj,'codtitlc');
    t_tapplfm.namfstc         := hcm_util.get_string_t(json_obj,'namfstc');
    t_tapplfm.namlstc         := hcm_util.get_string_t(json_obj,'namlstc');
    t_tapplfm.namcont         := hcm_util.get_string_t(json_obj,'namcont');
    t_tapplfm.adrcont1        := hcm_util.get_string_t(json_obj,'adrcont1');
    t_tapplfm.codpost         := hcm_util.get_string_t(json_obj,'codpost');
    t_tapplfm.numtele         := hcm_util.get_string_t(json_obj,'numtele');
    t_tapplfm.numfax          := hcm_util.get_string_t(json_obj,'numfax');
    t_tapplfm.email           := hcm_util.get_string_t(json_obj,'email');
    t_tapplfm.desrelat        := hcm_util.get_string_t(json_obj,'desrelat');
    t_tapplfm.codcreate       := hcm_util.get_string_t(json_obj,'codcreate');
    t_tapplfm.coduser         := hcm_util.get_string_t(json_obj,'coduser');
  end; -- end initial_tapplfm
  --
  procedure initial_tappldoc(json_document json_object_t) is
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
  procedure check_get_personal is
    v_code    varchar2(200);
  begin
    if b_index_numappl is not null then
      begin
        select 'X'
          into v_code
          from tapplinf
         where numappl    = b_index_numappl;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tapplinf');
      end;
    end if;
  end;
  --
  procedure check_save_tapplinf(t_tapplinf in out tapplinf%rowtype) is
    v_code      varchar2(100);
    v_numlvl    number;
    v_ch        boolean;
    v_ctrl_codnatnl tsetdeflt.defaultval%type;
    v_chk_codempid  temploy1.codempid%type;
    v_chk_staemp    temploy1.staemp%type;
    v_codprovr      tapplinf.codprovr%type;
    v_coddistr      tapplinf.coddistr%type;
    v_codprovc      tapplinf.codprovc%type;
    v_coddistc      tapplinf.coddistc%type;
  begin
    begin
      select  defaultval
      into    v_ctrl_codnatnl
      from    tsetdeflt
      where   codapp    = 'HRRC21E'
      and     numpage   = 'HRRC21E11'
      and     fieldname = 'CODNATNL'
      and     seqno     = 1;
    exception when no_data_found then
      null;
    end;

    if t_tapplinf.numoffid is not null then
      if v_ctrl_codnatnl = t_tapplinf.codnatnl then
        v_ch := check_numoffid(t_tapplinf.numoffid);
        if not v_ch and param_flgwarn = 'S' then -- Start check warning
          param_msg_error := get_error_msg_php('PM0059',global_v_lang);
          param_flgwarn   := 'WARN1';
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
          where  numoffid = t_tapplinf.numoffid;
          param_msg_error   := get_error_msg_php('HR2006',global_v_lang);
          param_flgwarn     := 'WARN2';
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
          and    b.numoffid = t_tapplinf.numoffid
          and   (a.numappl <> b_index_numappl or b_index_numappl is null)
          and    a.staemp   <> '9'
          and rownum = 1;
          param_msg_error := replace(get_error_msg_php('PM0015',global_v_lang),get_label_name('HRRC21E1T1','102',10),
                             v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                             get_label_name('HRRC21E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang));
          param_flgwarn   := 'WARN3'; -- End check warning
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
         where (numappl <> b_index_numappl or b_index_numappl is null)
           and ((global_v_lang = '101' and trim(t_tapplinf.namfirste)||trim(t_tapplinf.namlaste) = ltrim(rtrim(namfirste))||ltrim(rtrim(namlaste)))
            or  (global_v_lang = '102' and trim(t_tapplinf.namfirstt)||trim(t_tapplinf.namlastt) = ltrim(rtrim(namfirstt))||ltrim(rtrim(namlastt)))
            or  (global_v_lang = '103' and trim(t_tapplinf.namfirst3)||trim(t_tapplinf.namlast3) = ltrim(rtrim(namfirst3))||ltrim(rtrim(namlast3)))
            or  (global_v_lang = '104' and trim(t_tapplinf.namfirst4)||trim(t_tapplinf.namlast4) = ltrim(rtrim(namfirst4))||ltrim(rtrim(namlast4)))
            or  (global_v_lang = '105' and trim(t_tapplinf.namfirst5)||trim(t_tapplinf.namlast5) = ltrim(rtrim(namfirst5))||ltrim(rtrim(namlast5))))
           and staemp <> '9'
        and rownum <= 1;
      --	alert_error.error_data('PM0013',global_v_lang);
        --mdf ให้แสดงรหัสพนักงาน และให้ เลือก save ต่อ หรือ ยกเลิก
        param_msg_error := get_error_msg_php('PM0013',global_v_lang);
        param_flgwarn   := 'WARN4'; -- End check warning
        return;
        --PM0013    ชื่อ-นามสกุล ซ้ำ
      exception when no_data_found then
        null;
      end;
    end if;

    if t_tapplinf.dtepasid <= t_tapplinf.dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dtepasid');
      return;
    end if;

    if t_tapplinf.dtelicid <= t_tapplinf.dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dtelicid');
      return;
    end if;

    if t_tapplinf.dteoffid <= t_tapplinf.dteempdb then
      param_msg_error := get_error_msg_php('PM0018',global_v_lang,null,'dteoffid');
      return;
    end if;

    if param_flgwarn = 'WARN3' then
      param_flgwarn     := 'WARN4';
    end if;
    if param_flgwarn = 'WARN4' then
      if (months_between(sysdate,t_tapplinf.dteempdb)) / 12 < 18 then
        param_msg_error := get_error_msg_php('PM0014',global_v_lang,null,'dteempdb');
        param_flgwarn   := 'WARN5'; -- End check warning
        return;
      end if;
    end if;
    param_flgwarn := null;

    if t_tapplinf.codprov is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = t_tapplinf.codprov;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovi');
        return;
      end;
    end if;

    if t_tapplinf.coddomcl is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = t_tapplinf.coddomcl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','coddomcl');
        return;
      end;
    end if;

    if t_tapplinf.codrelgn is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec = t_tapplinf.codrelgn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRELI','codrelgn');
        return;
      end;
    end if;

    if t_tapplinf.codorgin is not null then
      begin
        select codcodec into v_code
        from	 tcodregn
        where	 codcodec = t_tapplinf.codorgin;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODREGN','codorgin');
        return;
      end;
    end if;

    if t_tapplinf.codnatnl is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec = t_tapplinf.codnatnl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODNATN','codnatnl');
        return;
      end;
    end if;

    if t_tapplinf.dteappl is not null then
      if t_tapplinf.dteappl > trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR4508',global_v_lang,null,'dteappl');
      end if;
    end if;

    if t_tapplinf.dteappl is not null then
      if t_tapplinf.codbrlc1 = t_tapplinf.codbrlc2 or
         t_tapplinf.codbrlc1 = t_tapplinf.codbrlc3 or
         t_tapplinf.codbrlc2 = t_tapplinf.codbrlc3 then
        param_msg_error := get_label_name('HRRC21E1T61',global_v_lang,190)||' '||
                           get_error_msg_php('HR1503',global_v_lang);
      end if;
    end if;

    if t_tapplinf.codsubdistr is not null then
      begin
        select codsubdist,codprov,coddist
        into   v_code,v_codprovr,v_coddistr
        from	 tsubdist
        where	 codprov    = nvl(t_tapplinf.codprovr,codprov)
        and		 coddist    = nvl(t_tapplinf.coddistr,coddist)
        and		 codsubdist = t_tapplinf.codsubdistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBDIST','codsubdistr');
        return;
      end;
    end if;

    if t_tapplinf.coddistr is not null then
      begin
        select coddist,codprov into v_code,v_codprovr
        from	 tcoddist
        where	 codprov = nvl(t_tapplinf.codprovr,codprov)
        and		 coddist = t_tapplinf.coddistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDIST','coddistr');
        return;
      end;
    else
      t_tapplinf.coddistr  := v_coddistr;
    end if;

    if t_tapplinf.codprovr is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = t_tapplinf.codprovr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovr');
        return;
      end;
    else
      t_tapplinf.codprovr  := v_codprovr;
    end if;

    if t_tapplinf.codsubdistc is not null then
      begin
        select codsubdist,codprov,coddist
        into   v_code,v_codprovc,v_coddistc
        from	 tsubdist
        where	 codprov    = nvl(t_tapplinf.codprovc,codprov)
        and		 coddist    = nvl(t_tapplinf.coddistc,coddist)
        and		 codsubdist = t_tapplinf.codsubdistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBDIST','codsubdistc');
        return;
      end;
    end if;

    if t_tapplinf.coddistc is not null then
      begin
        select coddist,codprov into v_code,v_codprovc
        from	 tcoddist
        where	 codprov = nvl(t_tapplinf.codprovc,codprov)
        and		 coddist = t_tapplinf.coddistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDIST','coddistc');
        return;
      end;
    else
      t_tapplinf.coddistc  := v_coddistc;
    end if;

    if t_tapplinf.codprovc is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = t_tapplinf.codprovc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV','codprovc');
        return;
      end;
    else
      t_tapplinf.codprovc  := v_codprovc;
    end if;
  end; -- end check_save_tapplinf
  --
  procedure check_emergency_contact is
    v_code      varchar2(100);
    v_numlvl    number;
    v_codprovr  temploy2.codprovr%type;
    v_coddistr  temploy2.coddistr%type;
    v_codprovc  temploy2.codprovc%type;
    v_coddistc  temploy2.coddistc%type;
  begin
    null;
  end; -- end check_emergency_contact
  --
  procedure check_delete_personal is
    v_code        varchar2(100);
  begin
    null;
  end; -- end check_delete_personal
  --
  function gen_numappl (p_typgen  in varchar2, --'A'
                        p_table   in varchar2,  --TAPPLINF
                        p_column  in varchar2 --NUMAPPL
                        ) return varchar2 is

   v_year    varchar2(4 char);
   v_mm      varchar2(2 char);
   v_seq     number;
   v_id      varchar2(20 char);
   v_id2     varchar2(20 char);
   v_stmt    varchar2(200 char);

  begin
    v_year := to_char(sysdate,'yyyy') -  pdk.check_year('') ;
    v_mm   := lpad(to_char(sysdate,'mm'),2,'0');

    begin
      select  substr(max(NUMAPPL),5)  -- substr(max('6511000056'),5)
        into v_seq
        from TAPPLINF
       where to_char(DTEAPPL,'yyyymm') = to_char(sysdate,'yyyymm')  ;
    exception when others then
      v_seq := 1;
    end ;

    loop
      --ปี พ.ศ.(2หลัก)||เดือน(2หลัก)||running(6หลัก)
      v_id := lpad(substr(v_year,3,2),2,'0')||v_mm||lpad(nvl(v_seq,1),6,'0');
      v_stmt := 'select count(*) from '||p_table||' where '||p_column||' = '''||v_id||'''';

      if not execute_stmt(v_stmt) then
        return(v_id);
      end if;
      v_seq := nvl(v_seq,0) + 1;
    end loop;
  end;
  --
  procedure save_tapplinf(t_tapplinf tapplinf%rowtype) is
    v_namempe 		temploy1.namempe%type;
    v_namempt 		temploy1.namempt%type;
    v_namemp3 		temploy1.namemp3%type;
    v_namemp4 		temploy1.namemp4%type;
    v_namemp5 		temploy1.namemp5%type;
    v_numappl     varchar2(1000);
  begin
    v_namempe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',t_tapplinf.codtitle,'101')))||
                       ltrim(rtrim(t_tapplinf.namfirste))||' '||ltrim(rtrim(t_tapplinf.namlaste)),1,60);
    v_namempt	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',t_tapplinf.codtitle,'102')))||
                       ltrim(rtrim(t_tapplinf.namfirstt))||' '||ltrim(rtrim(t_tapplinf.namlastt)),1,60);
    v_namemp3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',t_tapplinf.codtitle,'103')))||
                       ltrim(rtrim(t_tapplinf.namfirst3))||' '||ltrim(rtrim(t_tapplinf.namlast3)),1,60);
    v_namemp4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',t_tapplinf.codtitle,'104')))||
                       ltrim(rtrim(t_tapplinf.namfirst4))||' '||ltrim(rtrim(t_tapplinf.namlast4)),1,60);
    v_namemp5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',t_tapplinf.codtitle,'105')))||
                       ltrim(rtrim(t_tapplinf.namfirst5))||' '||ltrim(rtrim(t_tapplinf.namlast5)),1,60);
    v_numappl     := b_index_numappl;

    if b_index_numappl is null then
--      v_numappl   := std_genid
      b_index_numappl := gen_numappl ('A','TAPPLINF','NUMAPPL');
    end if;

    begin
      insert into tapplinf(numappl,codempid,statappl,flgqualify,dtetrnjo,
                           namimage,codtitle,namempe,namempt,namemp3,
                           namemp4,namemp5,namfirste,namfirstt,namfirst3,
                           namfirst4,namfirst5,namlaste,namlastt,namlast3,
                           namlast4,namlast5,nickname,codpos1,codpos2,
                           codbrlc1,codbrlc2,codbrlc3,amtincfm,amtincto,
                           codcurr,codmedia,flgcar,carlicid,flgwork,
                           numoffid,dteoffid,adrissue,codprov,numtaxid,
                           numsaid,numpasid,dtepasid,numlicid,dtelicid,
                           dteempdb,coddomcl,codsex,weight,height,
                           codblood,codorgin,codnatnl,codrelgn,stamarry,
                           stamilit,numprmid,dteprmst,dteprmen,adrrege,
                           adrregt,adrreg3,adrreg4,adrreg5,codprovr,
                           codsubdistr,coddistr,codcntyi,numtelemr,numtelehr,
                           adrconte,adrcontt,adrcont3,adrcont4,adrcont5,
                           codprovc,coddistc,codsubdistc,codposte,codcntyc,
                           codpostc,numtelem,numteleh,email,stadisb,
                           numdisab,typdisp,dtedisb,dtedisen,desdisp,
                           addinfo,actstudy,specabi,compabi,typthai,
                           typeng,numreql,codposl,codcompl,numreqc,
                           codposc,codcomp,codempmt,qtywkemp,qtyduepr,
                           dteappl,qtyscore,stasign,descrej,codreq,
                           codconf,dteconff,dteappoist,dteappoien,codappr,
                           dteappr,codrej,remark,flgblkls,dteempmt,
                           codemprc,amtsal,codfoll,dtefoll,numdoc,
                           codcreate,coduser)
      values (b_index_numappl,t_tapplinf.codempid,'10',t_tapplinf.flgqualify,t_tapplinf.dtetrnjo,
              t_tapplinf.namimage,t_tapplinf.codtitle,v_namempe,v_namempt,v_namemp3,
              v_namemp4,v_namemp5,t_tapplinf.namfirste,t_tapplinf.namfirstt,t_tapplinf.namfirst3,
              t_tapplinf.namfirst4,t_tapplinf.namfirst5,t_tapplinf.namlaste,t_tapplinf.namlastt,t_tapplinf.namlast3,
              t_tapplinf.namlast4,t_tapplinf.namlast5,t_tapplinf.nickname,t_tapplinf.codpos1,t_tapplinf.codpos2,
              t_tapplinf.codbrlc1,t_tapplinf.codbrlc2,t_tapplinf.codbrlc3,t_tapplinf.amtincfm,t_tapplinf.amtincto,
              t_tapplinf.codcurr,t_tapplinf.codmedia,t_tapplinf.flgcar,t_tapplinf.carlicid,t_tapplinf.flgwork,
              t_tapplinf.numoffid,t_tapplinf.dteoffid,t_tapplinf.adrissue,t_tapplinf.codprov,t_tapplinf.numtaxid,
              t_tapplinf.numsaid,t_tapplinf.numpasid,t_tapplinf.dtepasid,t_tapplinf.numlicid,t_tapplinf.dtelicid,
              t_tapplinf.dteempdb,t_tapplinf.coddomcl,t_tapplinf.codsex,t_tapplinf.weight,t_tapplinf.height,
              t_tapplinf.codblood,t_tapplinf.codorgin,t_tapplinf.codnatnl,t_tapplinf.codrelgn,t_tapplinf.stamarry,
              t_tapplinf.stamilit,t_tapplinf.numprmid,t_tapplinf.dteprmst,t_tapplinf.dteprmen,t_tapplinf.adrrege,
              t_tapplinf.adrregt,t_tapplinf.adrreg3,t_tapplinf.adrreg4,t_tapplinf.adrreg5,t_tapplinf.codprovr,
              t_tapplinf.codsubdistr,t_tapplinf.coddistr,t_tapplinf.codcntyi,t_tapplinf.numtelemr,t_tapplinf.numtelehr,
              t_tapplinf.adrconte,t_tapplinf.adrcontt,t_tapplinf.adrcont3,t_tapplinf.adrcont4,t_tapplinf.adrcont5,
              t_tapplinf.codprovc,t_tapplinf.coddistc,t_tapplinf.codsubdistc,t_tapplinf.codposte,t_tapplinf.codcntyc,
              t_tapplinf.codpostc,t_tapplinf.numtelem,t_tapplinf.numteleh,t_tapplinf.email,t_tapplinf.stadisb,
              t_tapplinf.numdisab,t_tapplinf.typdisp,t_tapplinf.dtedisb,t_tapplinf.dtedisen,t_tapplinf.desdisp,
              t_tapplinf.addinfo,t_tapplinf.actstudy,t_tapplinf.specabi,t_tapplinf.compabi,t_tapplinf.typthai,
              t_tapplinf.typeng,t_tapplinf.numreql,t_tapplinf.codposl,t_tapplinf.codcompl,t_tapplinf.numreqc,
              t_tapplinf.codposc,t_tapplinf.codcomp,t_tapplinf.codempmt,t_tapplinf.qtywkemp,t_tapplinf.qtyduepr,
              t_tapplinf.dteappl,t_tapplinf.qtyscore,t_tapplinf.stasign,t_tapplinf.descrej,t_tapplinf.codreq,
              t_tapplinf.codconf,t_tapplinf.dteconff,t_tapplinf.dteappoist,t_tapplinf.dteappoien,t_tapplinf.codappr,
              t_tapplinf.dteappr,t_tapplinf.codrej,t_tapplinf.remark,t_tapplinf.flgblkls,t_tapplinf.dteempmt,
              t_tapplinf.codemprc,t_tapplinf.amtsal,t_tapplinf.codfoll,t_tapplinf.dtefoll,t_tapplinf.numdoc,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tapplinf
         set statappl       = t_tapplinf.statappl,
             flgqualify     = t_tapplinf.flgqualify,
             dtetrnjo       = t_tapplinf.dtetrnjo,
             namimage       = t_tapplinf.namimage,
             codtitle       = t_tapplinf.codtitle,
             namempe        = v_namempe,
             namempt        = v_namempt,
             namemp3        = v_namemp3,
             namemp4        = v_namemp4,
             namemp5        = v_namemp5,
             namfirste      = t_tapplinf.namfirste,
             namfirstt      = t_tapplinf.namfirstt,
             namfirst3      = t_tapplinf.namfirst3,
             namfirst4      = t_tapplinf.namfirst4,
             namfirst5      = t_tapplinf.namfirst5,
             namlaste       = t_tapplinf.namlaste,
             namlastt       = t_tapplinf.namlastt,
             namlast3       = t_tapplinf.namlast3,
             namlast4       = t_tapplinf.namlast4,
             namlast5       = t_tapplinf.namlast5,
             nickname       = t_tapplinf.nickname,
             codpos1        = t_tapplinf.codpos1,
             codpos2        = t_tapplinf.codpos2,
             codbrlc1       = t_tapplinf.codbrlc1,
             codbrlc2       = t_tapplinf.codbrlc2,
             codbrlc3       = t_tapplinf.codbrlc3,
             amtincfm       = t_tapplinf.amtincfm,
             amtincto       = t_tapplinf.amtincto,
             codcurr        = t_tapplinf.codcurr,
             codmedia       = t_tapplinf.codmedia,
             flgcar         = t_tapplinf.flgcar,
             carlicid       = t_tapplinf.carlicid,
             flgwork        = t_tapplinf.flgwork,
             numoffid       = t_tapplinf.numoffid,
             dteoffid       = t_tapplinf.dteoffid,
             adrissue       = t_tapplinf.adrissue,
             codprov        = t_tapplinf.codprov,
             numtaxid       = t_tapplinf.numtaxid,
             numsaid        = t_tapplinf.numsaid,
             numpasid       = t_tapplinf.numpasid,
             dtepasid       = t_tapplinf.dtepasid,
             numlicid       = t_tapplinf.numlicid,
             dtelicid       = t_tapplinf.dtelicid,
             dteempdb       = t_tapplinf.dteempdb,
             coddomcl       = t_tapplinf.coddomcl,
             codsex         = t_tapplinf.codsex,
             weight         = t_tapplinf.weight,
             height         = t_tapplinf.height,
             codblood       = t_tapplinf.codblood,
             codorgin       = t_tapplinf.codorgin,
             codnatnl       = t_tapplinf.codnatnl,
             codrelgn       = t_tapplinf.codrelgn,
             stamarry       = t_tapplinf.stamarry,
             stamilit       = t_tapplinf.stamilit,
             numprmid       = t_tapplinf.numprmid,
             dteprmst       = t_tapplinf.dteprmst,
             dteprmen       = t_tapplinf.dteprmen,
             adrrege        = t_tapplinf.adrrege,
             adrregt        = t_tapplinf.adrregt,
             adrreg3        = t_tapplinf.adrreg3,
             adrreg4        = t_tapplinf.adrreg4,
             adrreg5        = t_tapplinf.adrreg5,
             codprovr       = t_tapplinf.codprovr,
             codsubdistr    = t_tapplinf.codsubdistr,
             coddistr       = t_tapplinf.coddistr,
             codcntyi       = t_tapplinf.codcntyi,
             numtelemr      = t_tapplinf.numtelemr,
             numtelehr      = t_tapplinf.numtelehr,
             adrconte       = t_tapplinf.adrconte,
             adrcontt       = t_tapplinf.adrcontt,
             adrcont3       = t_tapplinf.adrcont3,
             adrcont4       = t_tapplinf.adrcont4,
             adrcont5       = t_tapplinf.adrcont5,
             codprovc       = t_tapplinf.codprovc,
             coddistc       = t_tapplinf.coddistc,
             codsubdistc    = t_tapplinf.codsubdistc,
             codposte       = t_tapplinf.codposte,
             codcntyc       = t_tapplinf.codcntyc,
             codpostc       = t_tapplinf.codpostc,
             numtelem       = t_tapplinf.numtelem,
             numteleh       = t_tapplinf.numteleh,
             email          = t_tapplinf.email,
             stadisb        = t_tapplinf.stadisb,
             numdisab       = t_tapplinf.numdisab,
             typdisp        = t_tapplinf.typdisp,
             dtedisb        = t_tapplinf.dtedisb,
             dtedisen       = t_tapplinf.dtedisen,
             desdisp        = t_tapplinf.desdisp,
             addinfo        = t_tapplinf.addinfo,
             actstudy       = t_tapplinf.actstudy,
             specabi        = t_tapplinf.specabi,
             compabi        = t_tapplinf.compabi,
             typthai        = t_tapplinf.typthai,
             typeng         = t_tapplinf.typeng,
             numreql        = t_tapplinf.numreql,
             codposl        = t_tapplinf.codposl,
             codcompl       = t_tapplinf.codcompl,
             numreqc        = t_tapplinf.numreqc,
             codposc        = t_tapplinf.codposc,
             codcomp        = t_tapplinf.codcomp,
             codempmt       = t_tapplinf.codempmt,
             qtywkemp       = t_tapplinf.qtywkemp,
             qtyduepr       = t_tapplinf.qtyduepr,
             dteappl        = t_tapplinf.dteappl,
             qtyscore       = t_tapplinf.qtyscore,
             stasign        = t_tapplinf.stasign,
             descrej        = t_tapplinf.descrej,
             codreq         = t_tapplinf.codreq,
             codconf        = t_tapplinf.codconf,
             dteconff       = t_tapplinf.dteconff,
             dteappoist     = t_tapplinf.dteappoist,
             dteappoien     = t_tapplinf.dteappoien,
             codappr        = t_tapplinf.codappr,
             dteappr        = t_tapplinf.dteappr,
             codrej         = t_tapplinf.codrej,
             remark         = t_tapplinf.remark,
             flgblkls       = t_tapplinf.flgblkls,
             dteempmt       = t_tapplinf.dteempmt,
             codemprc       = t_tapplinf.codemprc,
             amtsal         = t_tapplinf.amtsal,
             codfoll        = t_tapplinf.codfoll,
             dtefoll        = t_tapplinf.dtefoll,
             numdoc         = t_tapplinf.numdoc,
             coduser        = global_v_coduser
       where numappl        = b_index_numappl;
    end;
  end; -- end save_tapplinf
  --
  procedure save_tapplfm(t_tapplfm tapplfm%rowtype) is
  begin
    begin
      insert into tapplfm(numappl,codempidsp,namimgsp,codtitle,namfirst,
                          namlast,namsp,numoffid,stalife,desnoffi,
                          codspocc,codtitlc,namfstc,namlstc,namcont,
                          adrcont1,codpost,numtele,numfax,email,
                          desrelat,codcreate,coduser)
      values (b_index_numappl,t_tapplfm.codempidsp,t_tapplfm.namimgsp,t_tapplfm.codtitle,t_tapplfm.namfirst,
              t_tapplfm.namlast,t_tapplfm.namsp,t_tapplfm.numoffid,t_tapplfm.stalife,t_tapplfm.desnoffi,
              t_tapplfm.codspocc,t_tapplfm.codtitlc,t_tapplfm.namfstc,t_tapplfm.namlstc,t_tapplfm.namcont,
              t_tapplfm.adrcont1,t_tapplfm.codpost,t_tapplfm.numtele,t_tapplfm.numfax,t_tapplfm.email,
              t_tapplfm.desrelat,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tapplfm
         set codempidsp    = t_tapplfm.codempidsp,
             namimgsp      = t_tapplfm.namimgsp,
             codtitle      = t_tapplfm.codtitle,
             namfirst      = t_tapplfm.namfirst,
             namlast       = t_tapplfm.namlast,
             namsp         = t_tapplfm.namsp,
             numoffid      = t_tapplfm.numoffid,
             stalife       = t_tapplfm.stalife,
             desnoffi      = t_tapplfm.desnoffi,
             codspocc      = t_tapplfm.codspocc,
             codtitlc      = t_tapplfm.codtitlc,
             namfstc       = t_tapplfm.namfstc,
             namlstc       = t_tapplfm.namlstc,
             namcont       =  t_tapplfm.namfstc||' '||t_tapplfm.namlstc,
             adrcont1      = t_tapplfm.adrcont1,
             codpost       = t_tapplfm.codpost,
             numtele       = t_tapplfm.numtele,
             numfax        = t_tapplfm.numfax,
             email         = t_tapplfm.email,
             desrelat      = t_tapplfm.desrelat,
             coduser       = global_v_coduser
       where numappl       = b_index_numappl;
    end;
  end;
  --
  procedure save_tappldoc is
    v_numseq      number;
  begin
    for n in 1..document_tab.count loop
      v_numseq  := document_tab(n).numseq;
      if p_flg_del_doc(n) = 'delete' then
        delete from tappldoc
        where numappl   = b_index_numappl
        and   numseq    = v_numseq;
      else
        begin
          insert into tappldoc
              (codempid,numappl,numseq,
               namdoc,filedoc,dterecv,
               typdoc,dtedocen,numdoc,desnote,flgresume,
               codcreate,coduser)
            values
              (b_index_numappl,b_index_numappl,v_numseq,
               document_tab(n).namdoc,document_tab(n).filedoc,document_tab(n).dterecv,
               document_tab(n).typdoc,document_tab(n).dtedocen,document_tab(n).numdoc,document_tab(n).desnote,document_tab(n).flgresume,
               global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tappldoc
             set namdoc   = document_tab(n).namdoc,
                 filedoc  = document_tab(n).filedoc,
                 dterecv  = document_tab(n).dterecv,
                 typdoc   = document_tab(n).typdoc,
                 dtedocen = document_tab(n).dtedocen,
                 numdoc   = document_tab(n).numdoc,
                 desnote  = document_tab(n).desnote,
                 flgresume  = document_tab(n).flgresume,
                 coduser = global_v_coduser
           where numappl    = b_index_numappl
             and numseq     = v_numseq;
        end;
      end if;
    end loop;
  end; -- end save_tappldoc
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
    cursor c_tbcklst is
     select numoffid, decode(global_v_lang, '101', namempe
                                          , '102', namempt
                                          , '103', namemp3
                                          , '104', namemp4
                                          , '105', namemp5
                                          , namempt) as namemp,
            codexemp,get_tcodec_name('TCODEXEM',codexemp,global_v_lang) as desexemp
      from  tbcklst
      where numoffid  = v_numoffid;
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
    end loop;
    if flg_found = 'N' then
      obj_row.put('coderror', '200');
      obj_row.put('numoffid', '');
      obj_row.put('desc_numoffid', '');
      obj_row.put('desexemp',replace(get_error_msg_php('HR2055', global_v_lang),'@#$%400','')||' (TBCKLST)');
    end if;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure gen_applinf(json_str_output out clob) is
    obj_row         json_object_t;
    v_exists        boolean := false;
    v_msg_blacklist terrorm.descripe%type;
    cursor c1 is
      select codempid,statappl,flgqualify,dtetrnjo,
             namimage,codtitle,
             decode(global_v_lang,'101',namfirste
                                 ,'102',namfirstt
                                 ,'103',namfirst3
                                 ,'104',namfirst4
                                 ,'105',namfirst5) as namfirst,
             namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
             decode(global_v_lang,'101',namlaste
                                 ,'102',namlastt
                                 ,'103',namlast3
                                 ,'104',namlast4
                                 ,'105',namlast5) as namlast,
             namlaste,namlastt,namlast3,namlast4,namlast5,
             nickname,codpos1,codpos2,codbrlc1,codbrlc2,codbrlc3,
             amtincfm,amtincto,codcurr,codmedia,flgcar,carlicid,
             flgwork,numoffid,dteoffid,adrissue,codprov,numtaxid,
             numsaid,numpasid,dtepasid,numlicid,dtelicid,dteempdb,
             coddomcl,codsex,weight,height,codblood,
             codorgin,codnatnl,codrelgn,stamarry,stamilit,
             numprmid,dteprmst,dteprmen,
             decode(global_v_lang,'101',adrrege
                                 ,'102',adrregt
                                 ,'103',adrreg3
                                 ,'104',adrreg4
                                 ,'105',adrreg5) as adrreg,
             adrrege,adrregt,adrreg3,adrreg4,adrreg5,
             codprovr,codsubdistr,coddistr,codcntyi,
             numtelemr,numtelehr,
             decode(global_v_lang,'101',adrconte
                                 ,'102',adrcontt
                                 ,'103',adrcont3
                                 ,'104',adrcont4
                                 ,'105',adrcont5) as adrcont,
             adrconte,adrcontt,adrcont3,adrcont4,adrcont5,
             codprovc,coddistc,codsubdistc,codposte,codcntyc,codpostc,
             numtelem,numteleh,email,
             stadisb,numdisab,typdisp,dtedisb,dtedisen,desdisp,
             addinfo,actstudy,specabi,compabi,typthai,typeng,
             numreql,codposl,codcompl,numreqc,codposc,codcomp,
             codempmt,qtywkemp,qtyduepr,dteappl,qtyscore,
             stasign,descrej,codreq,codconf,
             dteconff,dteappoist,dteappoien,codappr,dteappr,
             codrej,remark,flgblkls,dteempmt,codemprc,amtsal,
             codfoll,dtefoll,numdoc
        from tapplinf
       where numappl      = b_index_numappl;

  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');

    for i in c1 loop
      v_exists    := true;

      obj_row.put('numappl',b_index_numappl);
      obj_row.put('codempid',i.codempid);
      obj_row.put('statappl',i.statappl);
      obj_row.put('flgqualify',i.flgqualify);
      obj_row.put('dtetrnjo',to_char(i.dtetrnjo,'dd/mm/yyyy'));
      obj_row.put('namimage',i.namimage);
      obj_row.put('codtitle',i.codtitle);
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
      obj_row.put('nickname',i.nickname);
      obj_row.put('codpos1',i.codpos1);
      obj_row.put('codpos2',i.codpos2);
      obj_row.put('codbrlc1',i.codbrlc1);
      obj_row.put('codbrlc2',i.codbrlc2);
      obj_row.put('codbrlc3',i.codbrlc3);
      obj_row.put('amtincfm',i.amtincfm);
      obj_row.put('amtincto',i.amtincto);
      obj_row.put('codcurr',i.codcurr);
      obj_row.put('codmedia',i.codmedia);
      obj_row.put('flgcar',i.flgcar);
      obj_row.put('carlicid',i.carlicid);
      obj_row.put('flgwork',i.flgwork);
      obj_row.put('numoffid',i.numoffid);
      obj_row.put('dteoffid',to_char(i.dteoffid,'dd/mm/yyyy'));
      obj_row.put('adrissue',i.adrissue);
      obj_row.put('codprov',i.codprov);
      obj_row.put('numtaxid',i.numtaxid);
      obj_row.put('numsaid',i.numsaid);
      obj_row.put('numpasid',i.numpasid);
      obj_row.put('dtepasid',to_char(i.dtepasid,'dd/mm/yyyy'));
      obj_row.put('numlicid',i.numlicid);
      obj_row.put('dtelicid',to_char(i.dtelicid,'dd/mm/yyyy'));
      obj_row.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
      obj_row.put('coddomcl',i.coddomcl);
      obj_row.put('codsex',i.codsex);
      obj_row.put('weight',i.weight);
      obj_row.put('height',i.height);
      obj_row.put('codblood',i.codblood);
      obj_row.put('codorgin',i.codorgin);
      obj_row.put('codnatnl',i.codnatnl);
      obj_row.put('codrelgn',i.codrelgn);
      obj_row.put('stamarry',i.stamarry);
      obj_row.put('stamilit',i.stamilit);
      obj_row.put('numprmid',i.numprmid);
      obj_row.put('dteprmst',to_char(i.dteprmst,'dd/mm/yyyy'));
      obj_row.put('dteprmen',to_char(i.dteprmen,'dd/mm/yyyy'));
      obj_row.put('adrreg',i.adrreg);
      obj_row.put('adrrege',i.adrrege);
      obj_row.put('adrregt',i.adrregt);
      obj_row.put('adrreg3',i.adrreg3);
      obj_row.put('adrreg4',i.adrreg4);
      obj_row.put('adrreg5',i.adrreg5);
      obj_row.put('codprovr',i.codprovr);
      obj_row.put('codsubdistr',i.codsubdistr);
      obj_row.put('coddistr',i.coddistr);
      obj_row.put('codcntyi',i.codcntyi);
      obj_row.put('numtelemr',i.numtelemr);
      obj_row.put('numtelehr',i.numtelehr);
      obj_row.put('adrcont',i.adrcont);
      obj_row.put('adrconte',i.adrconte);
      obj_row.put('adrcontt',i.adrcontt);
      obj_row.put('adrcont3',i.adrcont3);
      obj_row.put('adrcont4',i.adrcont4);
      obj_row.put('adrcont5',i.adrcont5);
      obj_row.put('codprovc',i.codprovc);
      obj_row.put('coddistc',i.coddistc);
      obj_row.put('codsubdistc',i.codsubdistc);
      obj_row.put('codposte',i.codposte);
      obj_row.put('codcntyc',i.codcntyc);
      obj_row.put('codpostc',i.codpostc);
      obj_row.put('numtelem',i.numtelem);
      obj_row.put('numteleh',i.numteleh);
      obj_row.put('email',i.email);
      obj_row.put('stadisb',i.stadisb);
      obj_row.put('numdisab',i.numdisab);
      obj_row.put('typdisp',i.typdisp);
      obj_row.put('dtedisb',to_char(i.dtedisb,'dd/mm/yyyy'));
      obj_row.put('dtedisen',to_char(i.dtedisen,'dd/mm/yyyy'));
      obj_row.put('desdisp',i.desdisp);
      obj_row.put('addinfo',i.addinfo);
      obj_row.put('actstudy',i.actstudy);
      obj_row.put('specabi',i.specabi);
      obj_row.put('compabi',i.compabi);
      obj_row.put('typthai',i.typthai);
      obj_row.put('typeng',i.typeng);
      obj_row.put('numreql',i.numreql);
      obj_row.put('codposl',i.codposl);
      obj_row.put('codcompl',i.codcompl);
      obj_row.put('numreqc',i.numreqc);
      obj_row.put('codposc',i.codposc);
      obj_row.put('codcomp',i.codcomp);
      obj_row.put('codempmt',i.codempmt);
      obj_row.put('qtywkemp',i.qtywkemp);
      obj_row.put('qtyduepr',i.qtyduepr);
      obj_row.put('dteappl',to_char(i.dteappl,'dd/mm/yyyy'));
      obj_row.put('qtyscore',i.qtyscore);
      obj_row.put('stasign',i.stasign);
      obj_row.put('descrej',i.descrej);
      obj_row.put('codreq',i.codreq);
      obj_row.put('codconf',i.codconf);
      obj_row.put('dteconff',to_char(i.dteconff,'dd/mm/yyyy'));
      obj_row.put('dteappoist',to_char(i.dteappoist,'dd/mm/yyyy'));
      obj_row.put('dteappoien',to_char(i.dteappoien,'dd/mm/yyyy'));
      obj_row.put('codappr',i.codappr);
      obj_row.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
      obj_row.put('codrej',i.codrej);
      obj_row.put('remark',i.remark);
      obj_row.put('flgblkls',i.flgblkls);
      obj_row.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy'));
      obj_row.put('codemprc',i.codemprc);
      obj_row.put('amtsal',i.amtsal);
      obj_row.put('codfoll',i.codfoll);
      obj_row.put('dtefoll',to_char(i.dtefoll,'dd/mm/yyyy'));
      obj_row.put('numdoc',i.numdoc);

      begin
        select get_terrorm_name('RC0006',global_v_lang)
          into v_msg_blacklist
          from tbcklst
         where numoffid     = i.numoffid;
      exception when no_data_found then
        v_msg_blacklist   := null;
      end;

      if v_msg_blacklist is not null then
        obj_row.put('alert_msg',v_msg_blacklist);
      elsif i.statappl in ('51','56') then
        obj_row.put('alert_msg',get_terrorm_name('RC0009',global_v_lang));
      elsif i.statappl = '54' then
        obj_row.put('alert_msg',get_terrorm_name('RC0010',global_v_lang));
      elsif i.statappl = '61' then
        obj_row.put('alert_msg',get_terrorm_name('RC0011',global_v_lang));
      elsif i.statappl = '62' then
        obj_row.put('alert_msg',get_terrorm_name('RC0012',global_v_lang));
      end if;

      obj_row.put('flgAdd',false);
    end loop;
    if not v_exists then
      obj_row.put('flgAdd',true);
    end if;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_applinf(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_get_personal;
    if param_msg_error is null then
      gen_applinf(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_emergency_contact(json_str_output out clob) is
    obj_data       json_object_t;
    v_exists       boolean  := false;
    cursor c1 is
      select numappl,codempidsp,namimgsp,codtitle,
             namfirst,namlast,namsp,numoffid,stalife,
             desnoffi,codspocc,codtitlc,namfstc,namlstc,
             namcont,adrcont1,codpost,numtele,numfax,
             email,desrelat
        from tapplfm
       where numappl      = b_index_numappl;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    for i in c1 loop
      v_exists    := true;
      obj_data.put('numappl',i.numappl);
      obj_data.put('codempidsp',i.codempidsp);
      obj_data.put('namimgsp',i.namimgsp);
      obj_data.put('codtitle',i.codtitle);
      obj_data.put('namfirst',i.namfirst);
      obj_data.put('namlast',i.namlast);
      obj_data.put('namsp',i.namsp);
      obj_data.put('numoffid',i.numoffid);
      obj_data.put('stalife',i.stalife);
      obj_data.put('desnoffi',i.desnoffi);
      obj_data.put('codspocc',i.codspocc);
      obj_data.put('codtitlc',i.codtitlc);
      obj_data.put('namfstc',i.namfstc);
      obj_data.put('namlstc',i.namlstc);
      obj_data.put('namcont',i.namcont);
      obj_data.put('adrcont1',i.adrcont1);
      obj_data.put('codpost',i.codpost);
      obj_data.put('numtele',i.numtele);
      obj_data.put('numfax',i.numfax);
      obj_data.put('email',i.email);
      obj_data.put('desrelat',i.desrelat);
    end loop;

    json_str_output := obj_data.to_clob;
  end;
  --
  procedure get_emergency_contact(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_emergency_contact(json_str_output);
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
      where numappl = b_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();
    for i in c_tappldoc loop
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
      obj_data.put('path_filename',get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||i.filedoc);
      obj_data.put('desnote',i.desnote);
      obj_data.put('flgresume',i.flgresume);
--      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
--      obj_data.put('coduser',i.coduser);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt    := v_rcnt + 1;
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
  procedure save_applinf(json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    json_applinf            json_object_t;
    json_emergency_contact  json_object_t;
    json_document           json_object_t;
    v_flgsecu			          boolean;
    v_zupdsal               varchar2(1);
    v_response_json         json_object_t;
    t_tapplinf              tapplinf%rowtype;
    t_tapplfm               tapplfm%rowtype;
    v_last_numappl          varchar2(100);
    v_num_appl              number;
    v_chk                   varchar2(1) := 'N';
    cursor c1 is
      select numappl
        from tapplinf
      order by 1 desc;
  begin
    initial_value(json_str_input);

    param_json              := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    json_applinf            := hcm_util.get_json_t(param_json,'applinf');
    json_emergency_contact  := hcm_util.get_json_t(param_json,'emergency_contact');
    json_document           := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'document'),'rows');

    if b_index_numappl is null then
      --gen numappl
      for i in c1 loop
        begin
          v_num_appl    := to_number(i.numappl);
          if substr(nvl(v_num_appl,'XX'),1,2) <> to_char(sysdate,'yy') then
            v_num_appl    := 1;
          else
            v_num_appl    := to_number(substr(v_num_appl,-8));
          end if;
          v_last_numappl  := to_char(sysdate,'yy')||lpad(v_num_appl,8,'0');
          exit;
        exception when others then
          null;
        end;
      end loop;
      v_last_numappl  := nvl(v_last_numappl,to_char(sysdate,'yy')||'00000001');
      for i in 1..100 loop
        begin
          select 'Y'
            into v_chk
            from tapplinf
           where numappl  = v_last_numappl;
          v_last_numappl  := to_number(v_last_numappl) + 1;
        exception when no_data_found then
          b_index_numappl := v_last_numappl;
          exit;
        end;
      end loop;
    end if;

    initial_tapplinf(json_applinf,t_tapplinf);
    initial_tapplfm(json_emergency_contact,t_tapplfm);
    initial_tappldoc(json_document);

    check_save_tapplinf(t_tapplinf);
    if param_msg_error is null then
      check_emergency_contact;
      if param_msg_error is null then
        null;
      end if;
    end if;

    if param_msg_error is null then
      save_tapplinf(t_tapplinf);
      save_tapplfm(t_tapplfm);
      save_tappldoc;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
      -- specific response --
      v_response_json := json_object_t(get_response_message(null,param_msg_error,global_v_lang));
      v_response_json.put('numappl',b_index_numappl);

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

    json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure delete_applinf(json_str_input in clob, json_str_output out clob) is
    param_json                      json_object_t;
    param_json_work                 json_object_t;
    v_statappl          tapplinf.statappl%type;
  begin
    initial_value(json_str_input);
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json_work             := hcm_util.get_json_t(param_json,'work');
--    check_delete_personal;
    begin
      select statappl
        into v_statappl
        from tapplinf
       where numappl    = b_index_numappl;
    exception when no_data_found then null;
    end;
    if param_msg_error is null and v_statappl = '10' then
      delete from tapplinf where numappl = b_index_numappl;
--      delete from tappimge where numappl = b_index_numappl;
      delete from tapplfm where numappl = b_index_numappl;
      delete from tapplrel where numappl = b_index_numappl;
      delete from teducatn where numappl = b_index_numappl;
      delete from tapplwex where numappl = b_index_numappl;
      delete from tapplref where numappl = b_index_numappl;
      delete from ttrainbf where numappl = b_index_numappl;
      delete from tcmptncy where numappl = b_index_numappl;
      delete from tcmptncy2 where numappl = b_index_numappl;
      delete from tappldoc where numappl = b_index_numappl;
      delete from tappfoll where numappl = b_index_numappl;
      delete from tapploth where numappl = b_index_numappl;
      delete from tlangabi where numappl = b_index_numappl;

      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end delete_applinf
  --
  procedure update_filedoc( p_codempid  varchar2,
                            p_filedoc   varchar2,
                            p_namedoc   varchar2,
                            p_type_doc  varchar2,
                            p_coduser   varchar2,
                            p_numrefdoc in out varchar2) is
--    v_numappl     temploy1.numappl%type; use b_index_numappl
    v_max_refdoc  tappldoc.numrefdoc%type;
    v_numrefdoc   tappldoc.numrefdoc%type;
    v_doc_seq     tappldoc.numseq%type;
  begin
    b_index_numappl   := p_codempid;
--    begin
--      select  nvl(numappl,p_codempid)
--      into    v_numappl
--      from    temploy1
--      where   codempid = p_codempid;
--    exception when no_data_found then
--      v_numappl := p_codempid;
--    end; use b_index_numappl

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
          where   numappl   = b_index_numappl
          and     numrefdoc is not null;
        end;

        begin
          select  nvl(max(numseq),0) + 1
          into    v_doc_seq
          from    tappldoc
          where   numappl   = b_index_numappl;
        end;

        v_numrefdoc   := p_codempid||lpad(to_number(v_max_refdoc) + 1, 5, '0');
        p_numrefdoc   := v_numrefdoc;
        insert into tappldoc(numappl,numseq,codempid,typdoc,namdoc,
                             filedoc,dterecv,flgresume,codcreate,coduser,numrefdoc)
                     values (b_index_numappl,v_doc_seq,p_codempid,p_type_doc,p_namedoc,
                             p_filedoc,trunc(sysdate),'N',p_coduser,p_coduser,v_numrefdoc);
      end if;
    else
      delete from tappldoc where numappl = b_index_numappl and numrefdoc = p_numrefdoc;
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
--           and (a.codempid <> p_codempid_query or p_codempid_query is null)
           and a.staemp   <> '9'
           and rownum = 1;
        v_errorno     := 'PM0015';
        v_msg_warning := replace(get_errorm_name('PM0015',global_v_lang),get_label_name('HRRC21E1T1','102',10),
                         v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                         get_label_name('HRRC21E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang));
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

    if v_numbank is not null or v_numbank2 is not null then
      begin
        select t1.codempid,t1.staemp
          into v_chk_codempid,v_chk_staemp
          from temploy1 t1, temploy3 t3
         where t1.codempid  = t3.codempid
           and (numbank in (v_numbank, v_numbank2) or numbank2 in (v_numbank, v_numbank2))
--           and (t1.codempid <> p_codempid_query or p_codempid_query is null)
           and rownum = 1;
        v_errorno     := 'PM0024';
        v_msg_warning := get_errorm_name('PM0024',global_v_lang)||' ('||
                         v_chk_codempid||' '||get_temploy_name(v_chk_codempid,global_v_lang)||' '||
                         get_label_name('HRRC21E1T3',global_v_lang,60)||' '||get_tlistval_name('NAMSTATA1',v_chk_staemp,global_v_lang)||')';
      exception when no_data_found then
        null;
      end;
    end if;

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
