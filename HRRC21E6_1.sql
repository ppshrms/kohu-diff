--------------------------------------------------------
--  DDL for Package Body HRRC21E6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E6" is
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
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
  end; -- end initial_value
  --
  procedure gen_reference(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    v_coduser         varchar2(500);
    v_dteupd          tapplref.dteupd%type;

    cursor c_tapplref is
      select  numappl,numseq,codempid,codempref,codtitle,
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
              decode(global_v_lang,'101',namrefe
                                  ,'102',namreft
                                  ,'103',namref3
                                  ,'104',namref4
                                  ,'105',namref5) as namref,
              flgref,despos,adrcont1,desnoffi,numtele,
              email,codoccup,remark,dteupd,coduser
      from    tapplref
      where   numappl    = b_index_numappl
      order by numseq;
  begin
    begin
      select coduser,dteupd
        into v_coduser,v_dteupd
        from (select dteupd, coduser 
                from tapplref
               where numappl      = b_index_numappl
              order by dteupd desc)
       where rownum = 1;
    exception when no_data_found then
      null;
    end;
    v_coduser   := get_codempid(v_coduser)||' '||get_temploy_name(get_codempid(v_coduser),global_v_lang);
    obj_row           := json_object_t();
    for i in c_tapplref loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numappl',i.numappl);
      obj_data.put('numseq',i.numseq);
      obj_data.put('codempref',i.codempref);
      obj_data.put('codtitle',i.codtitle);
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
      obj_data.put('namref',i.namref);
      obj_data.put('flgref',i.flgref);
      obj_data.put('desc_flgref',get_tlistval_name('FLGREF',i.flgref,global_v_lang));
      obj_data.put('despos',i.despos);
      obj_data.put('adrcont1',i.adrcont1);
      obj_data.put('desnoffi',i.desnoffi);
      obj_data.put('numtele',i.numtele);
      obj_data.put('email',i.email);
      obj_data.put('codoccup',i.codoccup);
      obj_data.put('remark',i.remark);
      obj_data.put('dteupd',to_char(v_dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',v_coduser);
      obj_data.put('codempupd',get_codempid(v_coduser));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_reference (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_reference(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob) is
    obj_row             json;
    v_codtitle          temploy1.codtitle%type;
    v_namfirst          temploy1.namfirste%type;
    v_namfirste         temploy1.namfirste%type;
    v_namfirstt         temploy1.namfirstt%type;
    v_namfirst3         temploy1.namfirst3%type;
    v_namfirst4         temploy1.namfirst4%type;
    v_namfirst5         temploy1.namfirst5%type;
    v_namlast           temploy1.namlaste%type;
    v_namlaste          temploy1.namlaste%type;
    v_namlastt          temploy1.namlastt%type;
    v_namlast3          temploy1.namlast3%type;
    v_namlast4          temploy1.namlast4%type;
    v_namlast5          temploy1.namlast5%type;
    v_dteempdb          temploy1.dteempdb%type;
    v_numtelec          temploy2.numtelec%type;
    v_adrcont           varchar2(1000);
    v_codpostc          temploy2.codpostc%type;
    v_email             temploy1.email%type;
    v_codpos            tpostn.codpos%type;
    v_desc_codcompy     varchar2(500);
    v_dteretire         date;
    v_numoffid          temploy2.numoffid%type;
  begin
    initial_value(json_str_input);
    begin
      select  codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              dteempdb,numtelec,
              decode(global_v_lang,'101',adrconte
                                  ,'102',adrcontt
                                  ,'103',adrcont3
                                  ,'104',adrcont4
                                  ,'105',adrcont5)||' '||
                                  get_label_name('HRPMC2EA1S',global_v_lang,'170')||' '||
                                  get_tsubdist_name(emp2.codsubdistc,global_v_lang)||' '||get_label_name('HRPMC2EA1S',global_v_lang,'180')||' '||
                                  get_tcoddist_name(emp2.coddistc,global_v_lang)||' '||get_label_name('HRPMC2EA1S',global_v_lang,'190')||' '||
                                  get_tcodec_name('TCODPROV',emp2.codprovc,global_v_lang)||' '||emp2.codpostc as adrcont,
              emp2.codpostc,emp1.email,
              emp1.codpos,get_tcompny_name(hcm_util.get_codcomp_level(emp1.codcomp,1,''),'102') as desc_codcopmy,
              emp1.dteretire,emp2.numoffid
      into    v_codtitle,v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,v_namfirst,
              v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,v_namlast,
              v_dteempdb,v_numtelec,
              v_adrcont,
              v_codpostc,v_email,
              v_codpos,v_desc_codcompy,
              v_dteretire,v_numoffid
      from    temploy1 emp1
              left join tcompny cpn on (get_codcompy(emp1.codcomp) = cpn.codcompy)
              left join temploy2 emp2 on (emp1.codempid = emp2.codempid)
              left join tfamily fam on (emp1.codempid = fam.codempid)
      where   emp1.codempid = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    obj_row   := json();
    obj_row.put('coderror','200');
    obj_row.put('codtitle',v_codtitle);
    obj_row.put('namfirst',v_namfirst);
    obj_row.put('namfirste',v_namfirste);
    obj_row.put('namfirstt',v_namfirstt);
    obj_row.put('namfirst3',v_namfirst3);
    obj_row.put('namfirst4',v_namfirst4);
    obj_row.put('namfirst5',v_namfirst5);
    obj_row.put('namlast',v_namlast);
    obj_row.put('namlaste',v_namlaste);
    obj_row.put('namlastt',v_namlastt);
    obj_row.put('namlast3',v_namlast3);
    obj_row.put('namlast4',v_namlast4);
    obj_row.put('namlast5',v_namlast5);
    obj_row.put('dteempdb',to_char(v_dteempdb,'dd/mm/yyyy'));
    obj_row.put('numtelec',v_numtelec);
    obj_row.put('adrcont',substr(v_adrcont,1,100));
    obj_row.put('codpostc',v_codpostc);
    obj_row.put('email',v_email);
    obj_row.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_row.put('desc_codcompy',v_desc_codcompy);
    obj_row.put('dteretire',to_char(v_dteretire,'dd/mm/yyyy'));
    obj_row.put('numoffid',v_numoffid);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- get_emp_detail
  --
  procedure initial_tab_reference(json_reference json_object_t) is
    json_reference_row    json_object_t;
  begin
    for i in 0..json_reference.get_size-1 loop
      json_reference_row                 := hcm_util.get_json_t(json_reference,to_char(i));
      p_flg_del_ref(i+1)                 := hcm_util.get_string_t(json_reference_row,'flg');
      reference_tab(i+1).numseq          := hcm_util.get_string_t(json_reference_row,'numseq');
      reference_tab(i+1).codempref       := hcm_util.get_string_t(json_reference_row,'codempref');
      reference_tab(i+1).codtitle        := hcm_util.get_string_t(json_reference_row,'codtitle');
      reference_tab(i+1).namfirste       := hcm_util.get_string_t(json_reference_row,'namfirste');
      reference_tab(i+1).namfirstt       := hcm_util.get_string_t(json_reference_row,'namfirstt');
      reference_tab(i+1).namfirst3       := hcm_util.get_string_t(json_reference_row,'namfirst3');
      reference_tab(i+1).namfirst4       := hcm_util.get_string_t(json_reference_row,'namfirst4');
      reference_tab(i+1).namfirst5       := hcm_util.get_string_t(json_reference_row,'namfirst5');
      reference_tab(i+1).namlaste        := hcm_util.get_string_t(json_reference_row,'namlaste');
      reference_tab(i+1).namlastt        := hcm_util.get_string_t(json_reference_row,'namlastt');
      reference_tab(i+1).namlast3        := hcm_util.get_string_t(json_reference_row,'namlast3');
      reference_tab(i+1).namlast4        := hcm_util.get_string_t(json_reference_row,'namlast4');
      reference_tab(i+1).namlast5        := hcm_util.get_string_t(json_reference_row,'namlast5');
      reference_tab(i+1).flgref          := hcm_util.get_string_t(json_reference_row,'flgref');
      reference_tab(i+1).despos          := hcm_util.get_string_t(json_reference_row,'despos');
      reference_tab(i+1).adrcont1        := hcm_util.get_string_t(json_reference_row,'adrcont1');
      reference_tab(i+1).desnoffi        := hcm_util.get_string_t(json_reference_row,'desnoffi');
      reference_tab(i+1).numtele         := hcm_util.get_string_t(json_reference_row,'numtele');
      reference_tab(i+1).email           := hcm_util.get_string_t(json_reference_row,'email');
      reference_tab(i+1).codoccup        := hcm_util.get_string_t(json_reference_row,'codoccup');
      reference_tab(i+1).remark          := hcm_util.get_string_t(json_reference_row,'remark');
    end loop;
  end; -- end initial_tab_reference
  --
  procedure save_spouse(json_spouse   json_object_t) is
    v_codempidsp     tapplfm.codempidsp%type;
    v_namimgsp       tapplfm.namimgsp%type;
    v_codtitle       tapplfm.codtitle%type;
    v_namfirst       tapplfm.namfirst%type;
    v_namlast        tapplfm.namlast%type;
    v_namsp          tapplfm.namsp%type;
    v_numoffid       tapplfm.numoffid%type;
    v_stalife        tapplfm.stalife%type;
    v_desnoffi       tapplfm.desnoffi%type;
  begin
    v_codempidsp     := hcm_util.get_string_t(json_spouse,'codempidsp');
    v_namimgsp       := hcm_util.get_string_t(json_spouse,'namimgsp');
    v_codtitle       := hcm_util.get_string_t(json_spouse,'codtitle');
    v_namfirst       := hcm_util.get_string_t(json_spouse,'namfirst');
    v_namlast        := hcm_util.get_string_t(json_spouse,'namlast');
    v_namsp          := hcm_util.get_string_t(json_spouse,'namsp');
    v_numoffid       := hcm_util.get_string_t(json_spouse,'numoffid');
    v_stalife        := hcm_util.get_string_t(json_spouse,'stalife');
    v_desnoffi       := hcm_util.get_string_t(json_spouse,'desnoffi');
    begin
      insert into tapplfm(numappl,codempidsp,namimgsp,codtitle,namfirst,
                          namlast,namsp,numoffid,stalife,desnoffi,
                          codcreate,coduser)
      values (b_index_numappl,v_codempidsp,v_namimgsp,v_codtitle,v_namfirst,
              v_namlast,v_namsp,v_numoffid,v_stalife,v_desnoffi,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tapplfm
         set codempidsp   = v_codempidsp,
             namimgsp     = v_namimgsp,
             codtitle     = v_codtitle,
             namfirst     = v_namfirst,
             namlast      = v_namlast,
             namsp        = v_namsp,
             numoffid     = v_numoffid,
             stalife      = v_stalife,
             desnoffi     = v_desnoffi,
             coduser      = global_v_coduser
       where numappl      = b_index_numappl;
    end;
  end;
  --
  procedure save_reference is
    v_numseq      number;

    v_namrefe        tapplref.namrefe%type;
    v_namreft        tapplref.namrefe%type;
    v_namref3        tapplref.namrefe%type;
    v_namref4        tapplref.namrefe%type;
    v_namref5        tapplref.namrefe%type;
  begin
    v_numseq    := 0;
    for n in 1..reference_tab.count loop
      v_numseq    := reference_tab(n).numseq;
      if p_flg_del_ref(n) = 'delete' then
        delete from tapplref
        where   numappl     = b_index_numappl
        and     numseq      = v_numseq;
      else
        if reference_tab(n).numseq > 0 then

          v_namrefe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'101')))||
                             ltrim(rtrim(reference_tab(n).namfirste))||' '||ltrim(rtrim(reference_tab(n).namlaste)),1,100);
          v_namreft	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'102')))||
                             ltrim(rtrim(reference_tab(n).namfirstt))||' '||ltrim(rtrim(reference_tab(n).namlastt)),1,100);
          v_namref3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'103')))||
                             ltrim(rtrim(reference_tab(n).namfirst3))||' '||ltrim(rtrim(reference_tab(n).namlast3)),1,100);
          v_namref4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'104')))||
                             ltrim(rtrim(reference_tab(n).namfirst4))||' '||ltrim(rtrim(reference_tab(n).namlast4)),1,100);
          v_namref5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'105')))||
                             ltrim(rtrim(reference_tab(n).namfirst5))||' '||ltrim(rtrim(reference_tab(n).namlast5)),1,100);

          begin
            insert into tapplref( numappl,numseq,codempid,codempref,codtitle,
                                  namrefe,namreft,namref3,namref4,namref5,
                                  namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                  namlaste,namlastt,namlast3,namlast4,namlast5,
                                  flgref,despos,adrcont1,desnoffi,numtele,
                                  email,codoccup,remark,codcreate,coduser)

                         values ( b_index_numappl,v_numseq,b_index_numappl,reference_tab(n).codempref,reference_tab(n).codtitle,
                                  v_namrefe,v_namreft,v_namref3,v_namref4,v_namref5,
                                  reference_tab(n).namfirste,reference_tab(n).namfirstt,reference_tab(n).namfirst3,reference_tab(n).namfirst4,reference_tab(n).namfirst5,
                                  reference_tab(n).namlaste,reference_tab(n).namlastt,reference_tab(n).namlast3,reference_tab(n).namlast4,reference_tab(n).namlast5,
                                  reference_tab(n).flgref,reference_tab(n).despos,reference_tab(n).adrcont1,reference_tab(n).desnoffi,reference_tab(n).numtele,
                                  reference_tab(n).email,reference_tab(n).codoccup,reference_tab(n).remark,global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            update  tapplref
            set     codtitle      = reference_tab(n).codtitle,
                    codempref     = reference_tab(n).codempref,
                    namrefe       = v_namrefe,
                    namreft       = v_namreft,
                    namref3       = v_namref3,
                    namref4       = v_namref4,
                    namref5       = v_namref5,
                    namfirste     = reference_tab(n).namfirste,
                    namfirstt     = reference_tab(n).namfirstt,
                    namfirst3     = reference_tab(n).namfirst3,
                    namfirst4     = reference_tab(n).namfirst4,
                    namfirst5     = reference_tab(n).namfirst5,
                    namlaste      = reference_tab(n).namlaste,
                    namlastt      = reference_tab(n).namlastt,
                    namlast3      = reference_tab(n).namlast3,
                    namlast4      = reference_tab(n).namlast4,
                    namlast5      = reference_tab(n).namlast5,
                    flgref        = reference_tab(n).flgref,
                    despos        = reference_tab(n).despos,
                    adrcont1      = reference_tab(n).adrcont1,
                    desnoffi      = reference_tab(n).desnoffi,
                    numtele       = reference_tab(n).numtele,
                    email         = reference_tab(n).email,
                    codoccup      = reference_tab(n).codoccup,
                    remark        = reference_tab(n).remark,
                    coduser       = global_v_coduser
            where   numappl       = b_index_numappl
              and   numseq        = v_numseq;
          end;
        end if;
      end if;
    end loop;
  end;
  --
  procedure save_reference(json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    param_json_reference    json_object_t;
    t_tapplfm               tapplfm%rowtype;
  begin
    initial_value(json_str_input);
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_json_reference        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'reference'),'rows');

    initial_tab_reference(param_json_reference);

    if param_msg_error is null then
      save_reference;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
