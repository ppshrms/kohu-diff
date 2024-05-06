--------------------------------------------------------
--  DDL for Package Body HRRC21E5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E5" is
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
  procedure gen_spouse(json_str_output out clob) is
    obj_data      json_object_t;
    v_codempidsp  tapplfm.codempidsp%type;
    v_namimgsp    tapplfm.namimgsp%type;
    v_codtitle    tapplfm.codtitle%type;
    v_namfirst    tapplfm.namfirst%type;
    v_namlast     tapplfm.namlast%type;
    v_namsp       tapplfm.namsp%type;
    v_numoffid    tapplfm.numoffid%type;
    v_stalife     tapplfm.stalife%type;
    v_desnoffi    tapplfm.desnoffi%type;
    v_codspocc    tapplfm.codspocc%type;

  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    begin
      select codempidsp,namimgsp,codtitle,namfirst,namlast,
             namsp,numoffid,stalife,desnoffi,codspocc
        into v_codempidsp,v_namimgsp,v_codtitle,v_namfirst,
             v_namlast,v_namsp,v_numoffid,v_stalife,v_desnoffi,v_codspocc
        from tapplfm
       where numappl       = b_index_numappl;
    exception when no_data_found then null;
    end;
    obj_data.put('codempidsp',v_codempidsp);
    obj_data.put('namimgsp',v_namimgsp);
    obj_data.put('codtitle',v_codtitle);
    obj_data.put('namfirst',v_namfirst);
    obj_data.put('namlast',v_namlast);
    obj_data.put('namsp',v_namsp);
    obj_data.put('numoffid',v_numoffid);
    obj_data.put('stalife',nvl(v_stalife,'Y'));
    obj_data.put('desnoffi',v_desnoffi);
    obj_data.put('codspocc',v_codspocc);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_spouse (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_spouse(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_relative(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number  := 0;
    cursor c_trelatives is
      select  numseq,codemprl,namrel,
              numtelec,adrcomt
      from    tapplrel
      where   numappl = b_index_numappl;
  begin
    obj_row    := json_object_t();
    for i in c_trelatives loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numseq',i.numseq);
      obj_data.put('codemprl',i.codemprl);
      obj_data.put('namrel',i.namrel);
      obj_data.put('numtelec',i.numtelec);
      obj_data.put('adrcomt',i.adrcomt);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_relative (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_relative(json_str_output);
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
    v_namlast           temploy1.namlaste%type;
    v_numoffid          temploy2.numoffid%type;
    v_adrcomt           varchar2(1000);
    v_desc_codcopmy     varchar2(500);
    v_codoccu           varchar2(20);
    v_numtelec          temploy2.numtelec%type;
  begin
    initial_value(json_str_input);
    begin
      select  codtitle,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,numoffid,
              get_tcompny_name(get_codcompy(emp1.codcomp),global_v_lang) as desc_codcopmy,
              '0006' as codoccu,numtelec,
              decode(global_v_lang,'101',adrcome
                                  ,'102',adrcomt
                                  ,'103',adrcom3
                                  ,'104',adrcom4
                                  ,'105',adrcom5)||' '||cpn.numtele as adrcomt
      into    v_codtitle,v_namfirst,v_namlast,v_numoffid,
              v_desc_codcopmy,v_codoccu,v_numtelec,v_adrcomt
      from    temploy1 emp1
              left join tcompny cpn on (get_codcompy(emp1.codcomp) = cpn.codcompy)
              left join temploy2 emp2 on (emp1.codempid = emp2.codempid)
      where   emp1.codempid = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    obj_row   := json();
    obj_row.put('coderror','200');
    obj_row.put('codtitle',v_codtitle);
    obj_row.put('namfirst',v_namfirst);
    obj_row.put('namlast',v_namlast);
    obj_row.put('namemp',get_temploy_name(b_index_codempid,global_v_lang));
    obj_row.put('numoffid',v_numoffid);
    obj_row.put('desc_codcopmy',v_desc_codcopmy);
    obj_row.put('codoccu',v_codoccu);
    obj_row.put('numtelec',v_numtelec);
    obj_row.put('adrcomt',substr(v_desc_codcopmy||' '||v_adrcomt,1,300));

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- get_emp_detail
  --
  procedure initial_tab_relatives(json_relatives json_object_t) is
    json_relatives_row    json_object_t;
  begin
    for i in 0..json_relatives.get_size-1 loop
      json_relatives_row                    := hcm_util.get_json_t(json_relatives,to_char(i));
      p_flg_del_relatives(i+1)              := hcm_util.get_string_t(json_relatives_row,'flg');
      relatives_tab(i+1).numseq             := hcm_util.get_string_t(json_relatives_row,'numseq');
      relatives_tab(i+1).codemprl           := hcm_util.get_string_t(json_relatives_row,'codemprl');
      relatives_tab(i+1).namrel             := hcm_util.get_string_t(json_relatives_row,'namrel');
      relatives_tab(i+1).numtelec           := hcm_util.get_string_t(json_relatives_row,'numtelec');
      relatives_tab(i+1).adrcomt            := hcm_util.get_string_t(json_relatives_row,'adrcomt');
    end loop;
  end; -- end initial_tab_relatives
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
    v_codspocc       tapplfm.codspocc%type;
  begin
    v_codempidsp     := hcm_util.get_string_t(json_spouse,'codempidsp');
    v_namimgsp       := hcm_util.get_string_t(json_spouse,'namimgsp');
    v_codtitle       := hcm_util.get_string_t(json_spouse,'codtitle');
    v_namfirst       := hcm_util.get_string_t(json_spouse,'namfirst');
    v_namlast        := hcm_util.get_string_t(json_spouse,'namlast');
    v_namsp          := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirst||' '||v_namlast;
    v_numoffid       := hcm_util.get_string_t(json_spouse,'numoffid');
    v_stalife        := hcm_util.get_string_t(json_spouse,'stalife');
    v_desnoffi       := hcm_util.get_string_t(json_spouse,'desnoffi');
    v_codspocc       := hcm_util.get_string_t(json_spouse,'codspocc');
    begin
      insert into tapplfm(numappl,codempidsp,namimgsp,codtitle,namfirst,
                          namlast,namsp,numoffid,stalife,desnoffi,codspocc,
                          codcreate,coduser)
      values (b_index_numappl,v_codempidsp,v_namimgsp,v_codtitle,v_namfirst,
              v_namlast,v_namsp,v_numoffid,v_stalife,v_desnoffi,v_codspocc,
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
             codspocc     = v_codspocc,
             coduser      = global_v_coduser
       where numappl      = b_index_numappl;
    end;
  end;
  --
  procedure save_relatives is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
  begin
    for n in 1..relatives_tab.count loop
      v_numseq    := relatives_tab(n).numseq;
      if p_flg_del_relatives(n) = 'delete' then
        delete from tapplrel
        where   numappl     = b_index_numappl
        and     numseq      = v_numseq;
      else
        begin
          insert into tapplrel(numappl,numseq,codemprl,namrel,numtelec,
                               adrcomt,codcreate,coduser)
                       values (b_index_numappl,v_numseq,relatives_tab(n).codemprl,relatives_tab(n).namrel,relatives_tab(n).numtelec,
                               relatives_tab(n).adrcomt,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tapplrel
             set codemprl    = relatives_tab(n).codemprl,
                 namrel      = relatives_tab(n).namrel,
                 numtelec    = relatives_tab(n).numtelec,
                 adrcomt     = relatives_tab(n).adrcomt,
                 coduser     = global_v_coduser
           where numappl     = b_index_numappl
             and numseq      = v_numseq;
        end;
      end if;
    end loop;
  end; -- end save_relatives
  --
  procedure save_family(json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    param_json_spouse       json_object_t;
    param_json_relatives    json_object_t;
    t_tapplfm               tapplfm%rowtype;
  begin
    initial_value(json_str_input);
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_json_spouse           := hcm_util.get_json_t(param_json,'spouse');
    param_json_relatives        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'relatives'),'rows');

    initial_tab_relatives(param_json_relatives);

    if param_msg_error is null then
      save_spouse(param_json_spouse);
      save_relatives;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
