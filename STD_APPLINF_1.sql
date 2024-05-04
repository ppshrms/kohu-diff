--------------------------------------------------------
--  DDL for Package Body STD_APPLINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_APPLINF" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_numcont           := hcm_util.get_string_t(json_obj,'p_numcont');
    p_numappl           := hcm_util.get_string_t(json_obj,'p_numappl');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure get_tapplinf(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tapplinf(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tapplinf(json_str_output out clob)as
    obj_data        json_object_t;
    cursor c_tapplinf is
      select tapplinf.*,
             decode(global_v_lang, '101', namfirste,
                                   '102', namfirstt,
                                   '103', namfirst3,
                                   '104', namfirst4,
                                   '105', namfirst5,
                                   namfirste) namfirst ,
             decode(global_v_lang, '101', namlaste,
                                   '102', namlastt,
                                   '103', namlast3,
                                   '104', namlast4,
                                   '105', namlast5,
                                   namlaste) namlast ,
             decode(global_v_lang, '101', adrconte,
                                   '102', adrcontt,
                                   '103', adrcont3,
                                   '104', adrcont4,
                                   '105', adrcont5,
                                   adrconte) adrcont ,
             decode(global_v_lang, '101', adrrege,
                                   '102', adrregt,
                                   '103', adrreg3,
                                   '104', adrreg4,
                                   '105', adrreg5,
                                   adrrege) adrreg 
        from tapplinf
       where numappl = p_numappl;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', '');
    for r1 in c_tapplinf loop
        obj_data.put('image', r1.namimage);
        obj_data.put('numappl', r1.numappl);
        obj_data.put('desc_numappl', get_tapplinf_name(r1.numappl,global_v_lang));
        obj_data.put('codtitle', r1.codtitle);
        obj_data.put('desc_codtitle', get_tlistval_name('CODTITLE',r1.codtitle,global_v_lang));
        obj_data.put('nickname', r1.nickname);
        obj_data.put('namfirst', r1.namfirst);
        obj_data.put('namlast', r1.namlast);
        obj_data.put('dteappl', to_char(r1.dteappl,'dd/mm/yyyy'));
        obj_data.put('codpos1', r1.codpos1);
        obj_data.put('desc_codpos1', get_tpostn_name(r1.codpos1,global_v_lang));
        obj_data.put('codpos2', r1.codpos2);
        obj_data.put('desc_codpos2', get_tpostn_name(r1.codpos2,global_v_lang));
        obj_data.put('codbrlc1', r1.codbrlc1);
        obj_data.put('desc_codbrlc1', get_tcodloca_name(r1.codbrlc1,global_v_lang));
        obj_data.put('codbrlc2', r1.codbrlc2);
        obj_data.put('desc_codbrlc2', get_tcodloca_name(r1.codbrlc2,global_v_lang));
        obj_data.put('codbrlc3', r1.codbrlc3);
        obj_data.put('desc_codbrlc3', get_tcodloca_name(r1.codbrlc3,global_v_lang));
        obj_data.put('amtincfm', to_char(r1.amtincfm,'fm999,999,999,990.00'));
        obj_data.put('amtincto', to_char(r1.amtincto,'fm999,999,999,990.00'));
        obj_data.put('codcurr', r1.codcurr);
        obj_data.put('desc_codcurr', get_tcodec_name('TCODCURR',r1.codcurr,global_v_lang));
        obj_data.put('codmedia', r1.codmedia);
        obj_data.put('desc_codmedia', get_tcodec_name('TCODMEDI',r1.codmedia, global_v_lang));
        obj_data.put('flgcar', r1.flgcar);
        obj_data.put('carlicid', r1.carlicid);
        obj_data.put('flgwork', r1.flgwork);
        -- tab personal information
        obj_data.put('dteempdb', to_char(r1.dteempdb,'dd/mm/yyyy'));
        obj_data.put('coddomcl', r1.coddomcl);
        obj_data.put('desc_coddomcl', get_tcodec_name('TCODPROV',r1.coddomcl,global_v_lang));
        obj_data.put('codsex', r1.codsex);
        obj_data.put('desc_codsex', get_tlistval_name('NAMSEX',r1.codsex,global_v_lang));
        obj_data.put('numoffid', r1.numoffid);
        obj_data.put('adrissue', r1.adrissue);
        obj_data.put('dteoffid', to_char(r1.dteoffid,'dd/mm/yyyy'));
        obj_data.put('codprov', r1.codprov);
        obj_data.put('desc_codprov', get_tcodec_name('TCODPROV',r1.codprov,global_v_lang));
        obj_data.put('stamarry', r1.stamarry);
        obj_data.put('desc_stamarry', get_tlistval_name('NAMMARRY',r1.stamarry,global_v_lang));
        obj_data.put('stamilit', r1.stamilit);
        obj_data.put('desc_stamilit', get_tlistval_name('NAMMILIT',r1.stamilit,global_v_lang));
        obj_data.put('numtaxid', r1.numtaxid);
        obj_data.put('numsaid', r1.numsaid);
        obj_data.put('codblood', r1.codblood);
        obj_data.put('weight', r1.weight);
        obj_data.put('height', r1.height);
        obj_data.put('codrelgn', r1.codrelgn);
        obj_data.put('desc_codrelgn', get_tcodec_name('TCODRELI',r1.codrelgn,global_v_lang));
        obj_data.put('codorgin', r1.codorgin);
        obj_data.put('desc_codorgin', get_tcodec_name('TCODREGN',r1.codorgin,global_v_lang));
        obj_data.put('codnatnl', r1.codnatnl);
        obj_data.put('desc_codnatnl', get_tcodec_name('TCODNATN',r1.codnatnl,global_v_lang));
        obj_data.put('numlicid', r1.numlicid);
        obj_data.put('dtelicid', to_char(r1.dtelicid,'dd/mm/yyyy'));
        obj_data.put('numpasid', r1.numpasid);
        obj_data.put('dtepasid', to_char(r1.dtepasid,'dd/mm/yyyy'));
        obj_data.put('numprmid', r1.numprmid);
        obj_data.put('dteprmst', to_char(r1.dteprmst,'dd/mm/yyyy'));
        obj_data.put('dteprmen', to_char(r1.dteprmen,'dd/mm/yyyy'));
        -- tab address contact
        obj_data.put('adrreg', r1.adrreg);
        obj_data.put('codsubdistr', r1.codsubdistr);
        obj_data.put('desc_codsubdistr', get_tsubdist_name(r1.codsubdistr,global_v_lang));
        obj_data.put('coddistr', r1.coddistr);
        obj_data.put('desc_coddistr', get_tcoddist_name(r1.coddistr,global_v_lang));
        obj_data.put('codprovr', r1.codprovr);
        obj_data.put('desc_codprovr', get_tcodec_name('TCODPROV', r1.codprovr,global_v_lang));
        obj_data.put('codcntyi', r1.codcntyi);
        obj_data.put('desc_codcntyi', get_tcodec_name('TCODCNTY', r1.codcntyi, global_v_lang));
        obj_data.put('codposte', r1.codposte);
        obj_data.put('adrcont', r1.adrcont);
        obj_data.put('codprovc', r1.codprovc);
        obj_data.put('desc_codprovc', get_tcodec_name('TCODPROV', r1.codprovc,global_v_lang));
        obj_data.put('coddistc', r1.coddistc);
        obj_data.put('desc_coddistc', get_tcoddist_name(r1.coddistc,global_v_lang));
        obj_data.put('codsubdistc', r1.codsubdistc);
        obj_data.put('desc_codsubdistc', get_tsubdist_name(r1.codsubdistc,global_v_lang));
        obj_data.put('codcntyc',r1.codcntyc);
        obj_data.put('desc_codcntyc', get_tcodec_name('TCODCNTY', r1.codcntyc, global_v_lang));
        obj_data.put('codpostc', r1.codpostc);
        obj_data.put('numtelem', r1.numtelem);
        obj_data.put('email', r1.email);
        obj_data.put('numtelemr', r1.numtelemr); 
        obj_data.put('numtelehr', r1.numtelehr); 
        obj_data.put('numteleh', r1.numteleh);
        -- disabled information;
        obj_data.put('stadisb', r1.stadisb);
        obj_data.put('numdisab', r1.numdisab);
        obj_data.put('desc_typdisp', get_tcodec_name('TCODDISP',r1.typdisp,global_v_lang));
        obj_data.put('dtedisb', to_char(r1.dtedisb,'dd/mm/yyyy'));
        obj_data.put('dtedisen', to_char(r1.dtedisen,'dd/mm/yyyy'));
        obj_data.put('desdisp', r1.desdisp);
        -- talent
        obj_data.put('actstudy', r1.actstudy);
        obj_data.put('specabi', r1.specabi);
        obj_data.put('typthai', r1.typthai);
        obj_data.put('typeng', r1.typeng);
        obj_data.put('compabi', r1.compabi);
        obj_data.put('addinfo', r1.addinfo);

        -- appl status
        obj_data.put('statappl', r1.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL',r1.statappl, global_v_lang));
        obj_data.put('desc_stasign', get_tlistval_name('STASIGN',r1.stasign,global_v_lang));
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('dteempmt', to_char(r1.dteempmt,'dd/mm/yyyy'));
        obj_data.put('numreqc', r1.numreqc);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codposc', get_tpostn_name(r1.codposc,global_v_lang));
        obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL', r1.codempmt, global_v_lang));
        obj_data.put('flgblkls', r1.flgblkls);
        obj_data.put('remark', r1.remark);
        obj_data.put('dtefoll', to_char(r1.dtefoll,'dd/mm/yyyy'));
        obj_data.put('desc_codrej', get_tcodec_name('TCODREJE',r1.codrej,global_v_lang));
        obj_data.put('numreql', r1.numreql);
        obj_data.put('desc_codposl', get_tpostn_name(r1.codposl,global_v_lang));
        obj_data.put('desc_codcompl', get_tcenter_name(r1.codcompl,global_v_lang));
    end loop;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplinf;

  procedure get_tapplref(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapplref(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapplref;

  procedure gen_tapplref(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number:=0;
      cursor c_tapplref is
        select tapplref.*,
               decode(global_v_lang, '101', namrefe,
                                     '102', namreft,
                                     '103', namref3,
                                     '104', namref4,
                                     '105', namref5,
                                   namrefe) namref 
          from tapplref
         where numappl = p_numappl
      order by numseq;
    begin
      obj_row := json_object_t();
      for r1 in c_tapplref loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq',r1.numseq);
          obj_data.put('namref',r1.namref);
          obj_data.put('despos',r1.despos);
          obj_data.put('adrcont1',r1.adrcont1);
          obj_data.put('codoccup',r1.codoccup);
          obj_data.put('desc_codoccup',get_tcodec_name('TCODOCCU',r1.codoccup,global_v_lang));
          obj_data.put('flgref',r1.flgref);
          obj_data.put('desc_flgref',get_tlistval_name('FLGREF',r1.flgref,global_v_lang));
          obj_data.put('desnoffi',r1.desnoffi);
          obj_data.put('numtele',r1.numtele);
          obj_data.put('email',r1.email);
          obj_data.put('remark',r1.remark);  
          obj_data.put('codempref',r1.codempref);
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplref;

  procedure get_teducatn(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_teducatn(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_teducatn;

  procedure gen_teducatn(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_teducatn is
        select * 
          from teducatn
         where numappl = p_numappl
      order by numseq;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_teducatn loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');

        obj_data.put('numseq',r1.numseq);
        obj_data.put('desc_codedlv',get_tcodec_name('tcodeduc', r1.codedlv, global_v_lang));
        obj_data.put('desc_flgeduc',get_tlistval_name('FLGEDUC',r1.flgeduc,global_v_lang));
        obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',r1.coddglv,global_v_lang));
        obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',r1.codmajsb,global_v_lang));
        obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ', r1.codminsb, global_v_lang));
        obj_data.put('desc_codinst',get_tcodec_name('TCODINST',r1.codinst,global_v_lang));
        obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',r1.codcount,global_v_lang));
        obj_data.put('numgpa', r1.numgpa);
        obj_data.put('stayear', r1.stayear);
        obj_data.put('dtegyear', r1.dtegyear);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_teducatn;  

  procedure get_tappldoc(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tappldoc(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tappldoc;

  procedure gen_tappldoc(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_tappldoc is
        select * 
          from tappldoc
         where numappl = p_numappl
      order by numseq;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tappldoc loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('desc_typdoc',get_tlistval_name('TYPDOC', r1.typdoc , global_v_lang));
        obj_data.put('namdoc',r1.namdoc);
        obj_data.put('filedoc',r1.filedoc);
        obj_data.put('path_file',get_tsetup_value('PATHWORKPHP')||get_tfolderd('HEPMC2E')||'/'||r1.filedoc);
        if r1.flgresume = 'Y' then
          obj_data.put('flgresume',get_label_name('HRPMC2E1P9',global_v_lang,100));
        elsif r1.flgresume = 'N' then
          obj_data.put('flgresume',get_label_name('HRPMC2E1P9',global_v_lang,110));
        end if;
        obj_data.put('numdoc',r1.numdoc);
        obj_data.put('dterecv',to_char(r1.dterecv,'dd/mm/yyyy'));
        obj_data.put('dtedocen',to_char(r1.dtedocen,'dd/mm/yyyy'));
        obj_data.put('desnote',r1.desnote);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tappldoc;  
  procedure get_tloaninf2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
--    gen_tloaninf2(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure get_tapphinv(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapphinv(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapphinv;

  procedure gen_tapphinv(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_tapphinv is
        select * 
          from tapphinv
         where numappl = p_numappl
      order by numreqrq;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tapphinv loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');

        obj_data.put('numreqrq',r1.numreqrq);
        obj_data.put('desc_codposrq',get_tpostn_name(r1.codposrq,global_v_lang));
        obj_data.put('dtecreate',to_char(r1.dtecreate,'dd/mm/yyyy'));
        obj_data.put('qtyscoresum',r1.qtyscoresum);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('numappl',r1.numappl);
        obj_data.put('codposrq',r1.codposrq);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapphinv;  

  procedure get_tapplwex(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapplwex(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapplwex;

  procedure gen_tapplwex(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_tapplwex is
        select * 
          from tapplwex
         where numappl = p_numappl
      order by numseq;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tapplwex loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');

        obj_data.put('numseq',r1.numseq);
        obj_data.put('desnoffi',r1.desnoffi);
        obj_data.put('desoffi1',r1.desoffi1);
        obj_data.put('deslstpos',r1.deslstpos);
        obj_data.put('dtestart',to_char(r1.dtestart,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy')); 
        obj_data.put('deslstjob1',r1.deslstjob1);
        obj_data.put('numteleo',r1.numteleo);
        obj_data.put('namboss',r1.namboss);
        obj_data.put('desres',r1.desres);
        obj_data.put('amtincom',to_char(greatest(0,nvl(stddec(r1.amtincom,r1.codempid,v_chken),0)), 'fm999,999,990.00'));
        obj_data.put('remark',r1.remark);
--        obj_data.put('dteupd',to_char(r1.dteupd,'dd/mm/yyyy'));
--        obj_data.put('coduser',get_codempid(r1.coduser)|| ' - '||get_temploy_name(get_codempid(r1.coduser),global_v_lang));
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplwex;  

  procedure get_ttrainbf(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_ttrainbf(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_ttrainbf;

  procedure gen_ttrainbf(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_ttrainbf is
        select * 
          from ttrainbf
         where numappl = p_numappl
      order by numseq;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_ttrainbf loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');

        obj_data.put('numseq',r1.numseq);
        obj_data.put('destrain',r1.destrain);
        obj_data.put('desplace',r1.desplace);
        obj_data.put('dtetrain',to_char(r1.dtetrain,'dd/mm/yyyy'));
        obj_data.put('dtetren',to_char(r1.dtetren,'dd/mm/yyyy'));
        obj_data.put('desinstu',r1.desinstu);
        obj_data.put('filedoc',r1.filedoc);
        obj_data.put('path_file',get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E')||'/'||r1.filedoc);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_ttrainbf;  


  procedure get_tcmptncy(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tcmptncy(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcmptncy;

  procedure gen_tcmptncy(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_tcmptncy is
        select codtency, get_tcodec_name('TCODSKIL', codtency, global_v_lang) desccodtency, grade
          from tcmptncy
         where numappl = p_numappl
         union 
        select '' , descskil ,grade
          from tcmptncy2
         where numappl = p_numappl
      order by codtency ;      

    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tcmptncy loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codtency',r1.codtency);
        obj_data.put('desc_codtency',r1.desccodtency);
        obj_data.put('grade',get_tlistval_name('GRADSKIL',r1.grade, global_v_lang));
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tcmptncy;    


  procedure get_applhistory(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_applhistory(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_applhistory;

  procedure gen_applhistory(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      v_numoffid        tapplinf.numoffid%type;
      v_qtyscoresum     tapphinv.qtyscoresum%type;
      v_stasign         tapphinv.stasign%type;

      cursor c_tapplinf is
        select * 
          from tapplinf
         where numappl <> p_numappl
           and numoffid = v_numoffid;

    begin
      begin
          select numoffid
            into v_numoffid
            from tapplinf
           where numappl = p_numappl;      
      exception when others then
        v_numoffid := null;
      end;

      v_rcnt    := 0;
      obj_row   := json_object_t();
      for r1 in c_tapplinf loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        begin
            select qtyscoresum, stasign
              into v_qtyscoresum, v_stasign
              from tapphinv
             where numappl = p_numappl
               and numreqrq = r1.numreqc
               and codposrq = r1.codposc;
        exception when others then
            v_qtyscoresum := 0;
            v_stasign := null;
        end;   
        obj_data.put('dteappl',to_char(r1.dteappl,'dd/mm/yyyy'));
        obj_data.put('desc_codpos1',get_tpostn_name(r1.codpos1,global_v_lang));
        obj_data.put('desc_codpos2',get_tpostn_name(r1.codpos2,global_v_lang));
        obj_data.put('numappl',r1.numappl);
        obj_data.put('desc_statappl',get_tlistval_name('STATAPPL',r1.statappl, global_v_lang));
        obj_data.put('numreql',r1.numreql);
        obj_data.put('desc_codposl',get_tpostn_name(r1.codposl,global_v_lang));
        obj_data.put('dtefoll',to_char(r1.dtefoll,'dd/mm/yyyy'));
        obj_data.put('qtyscoresum',v_qtyscoresum);
        obj_data.put('desc_stasign',get_tlistval_name('STASIGN',v_stasign,global_v_lang));
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_applhistory;      

  procedure get_tapplfm(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapplfm(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapplfm;

  procedure gen_tapplfm(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      v_numoffid        tapplinf.numoffid%type;
      cursor c_tapplfm is
        select * 
          from tapplfm
         where numappl = p_numappl;

    begin
      v_rcnt        := 0;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response','');      
      for r1 in c_tapplfm loop
        obj_data.put('image',get_emp_img(r1.codempidsp));
        obj_data.put('codempidsp',r1.codempidsp);
        obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',r1.codtitle,global_v_lang));
        obj_data.put('namfirst',r1.namfirst);
        obj_data.put('namlast',r1.namlast);
        obj_data.put('numoffid',r1.numoffid);
        obj_data.put('stalife',r1.stalife);
        obj_data.put('codspocc',r1.codspocc);
        obj_data.put('desc_codspocc',get_tcodec_name('TCODOCCU',r1.codspocc,global_v_lang));
        obj_data.put('desnoffi',r1.desnoffi);

--        obj_data.put('desc_codtitlc',get_tlistval_name('CODTITLE',r1.codtitlc,global_v_lang));
--        obj_data.put('namfstc',r1.namfstc);
--        obj_data.put('namlstc',r1.namlstc);

        obj_data.put('namcont',r1.namcont);
        obj_data.put('desrelat',r1.desrelat);
        obj_data.put('adrcont1',r1.adrcont1);
        obj_data.put('codpost',r1.codpost);
        obj_data.put('numtele',r1.numtele);
        obj_data.put('email',r1.email);
        obj_data.put('numfax',r1.numfax);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_data.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplfm;      

  procedure get_tapploth(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapploth(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapploth;

  procedure gen_tapploth(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      cursor c_tapploth is
        select * 
          from tapploth
         where numappl = p_numappl;

    begin
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response','');      
      for r1 in c_tapploth loop


        obj_data.put('flgcivil',nvl(r1.flgcivil,'N'));
        obj_data.put('lastpost',r1.lastpost);
        obj_data.put('departmn',r1.departmn);
        obj_data.put('flgmilit',r1.flgmilit);
        obj_data.put('desexcem',r1.desexcem);
        obj_data.put('flgordan',r1.flgordan);
        obj_data.put('flgcase',r1.flgcase);
        obj_data.put('desdisea',r1.desdisea);
        obj_data.put('dessymp',r1.dessymp);
        obj_data.put('flgill',r1.flgill);
        obj_data.put('desill',r1.desill);
        obj_data.put('flgarres',r1.flgarres);
        obj_data.put('desarres',r1.desarres);
        obj_data.put('flgknow',r1.flgknow);
        obj_data.put('name',r1.name);
        obj_data.put('flgappl',r1.flgappl);
        obj_data.put('lastpos2',r1.lastpos2);
        obj_data.put('agewrkyr',r1.agewrkyr);
        obj_data.put('agewrkmth',r1.agewrkmth);
        obj_data.put('hobby',r1.hobby);

        obj_data.put('reason',r1.reason);
        obj_data.put('flgstrwk',r1.flgstrwk);
        obj_data.put('dtewkst',to_char(r1.dtewkst,'dd/mm/yyyy'));
        obj_data.put('qtydayst',r1.qtydayst);
        obj_data.put('jobdesc',r1.jobdesc);
        obj_data.put('desc_codlocat',ltrim(rtrim(get_tcodec_name('TCODLOCA',r1.codlocat,global_v_lang))));
        obj_data.put('flgprov',r1.flgprov);
        obj_data.put('flgoversea',r1.flgoversea);
      end loop;
      json_str_output := obj_data.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapploth;    

  procedure get_tlangabi(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tlangabi(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tlangabi;

  procedure gen_tlangabi(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      cursor c_tlangabi is
        select * 
          from tlangabi
         where numappl = p_numappl
      order by codlang;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tlangabi loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');

        obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',r1.codlang,global_v_lang));
        obj_data.put('flglist',get_tlistval_name('FLGLANG',r1.flglist,global_v_lang));
        obj_data.put('flgspeak',get_tlistval_name('FLGLANG',r1.flgspeak,global_v_lang));
        obj_data.put('flgread',get_tlistval_name('FLGLANG',r1.flgread,global_v_lang));
        obj_data.put('flgwrite',get_tlistval_name('FLGLANG',r1.flgwrite,global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tlangabi;    

  procedure get_tapplrel(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tapplrel(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapplrel;

  procedure gen_tapplrel(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number:=0;
      cursor c_tapplrel is
        select tapplrel.*
          from tapplrel
         where numappl = p_numappl
      order by numseq;
    begin
      obj_row := json_object_t();
      for r1 in c_tapplrel loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('response','');
          obj_data.put('numseq',r1.numseq);
          obj_data.put('codemprl',r1.codemprl);
          obj_data.put('namrel',r1.namrel);
          obj_data.put('numtelec',r1.numtelec);
          obj_data.put('adrcomt',r1.adrcomt);
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplrel;

end std_applinf;

/
