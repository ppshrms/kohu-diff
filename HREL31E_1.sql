--------------------------------------------------------
--  DDL for Package Body HREL31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL31E" as
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcatexm         := hcm_util.get_string_t(json_obj,'p_codcatexm');
    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');
    p_codexamCopy       := hcm_util.get_string_t(json_obj,'p_codexamCopy');
    p_codquest          := hcm_util.get_string_t(json_obj,'p_codquest');
    p_typeexam          := hcm_util.get_string_t(json_obj,'p_typeexam');
    p_numques           := hcm_util.get_string_t(json_obj,'p_numques');
    p_qtyans            := hcm_util.get_string_t(json_obj,'p_qtyans');
    p_isCopy            := hcm_util.get_string_t(json_obj,'p_isCopy');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_chkExist    number := 0;
  begin
    if p_codcatexm is not null then
      begin
        select count(*) into v_chkExist
          from tcodcatexm
         where codcodec = p_codcatexm;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob) is
    obj_data                json_object_t;
    obj_row                 json_object_t;
    v_row                   number := 0;
    v_flg_disable_delete    varchar2(1 char);     --> Peerasak || Issue#9294 || 04042023

    cursor c1 is
        select tvtest.*, decode(global_v_lang,'101',namexame,
                                                   '102',namexam2,
                                                   '103',namexam3,
                                                   '104',namexam4,
                                                   '105',namexam5) namexam
          from tvtest
         where codcatexm = nvl(p_codcatexm, codcatexm)
      order by codcatexm, codexam;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcatexm', r1.codcatexm);
        obj_data.put('desc_codcatexm',get_tcodec_name('TCODCATEXM', r1.codcatexm, global_v_lang));
        obj_data.put('codexam',r1.codexam);
        obj_data.put('namexam',r1.namexam);
        obj_data.put('qtyexam',r1.qtyexam);
        
        --> Peerasak || Issue#9294 || 04042023
        begin
          select 
            case 
              when exists (
                select 1 from ttestemp where codexam = r1.codexam
              ) then 'Y' else 'N' 
            end
          into v_flg_disable_delete
          from dual;
        exception when others then 
          null;
        end;
        
        obj_data.put('flgDisableDelete', v_flg_disable_delete);
        --> Peerasak || Issue#9294 || 04042023
        
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index();
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copylist(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_row               number := 0;

    cursor c1 is
        select codexam, decode(global_v_lang,'101',namexame,
                                                   '102',namexam2,
                                                   '103',namexam3,
                                                   '104',namexam4,
                                                   '105',namexam5) namexam
          from tvtest
         where codexam != p_codexam
      order by codexam;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codexam',r1.codexam);
        obj_data.put('namexam',r1.namexam);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_copylist;

  procedure get_copylist (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copylist(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_main            json_object_t;
    obj_detail          json_object_t;
    obj_tab1            json_object_t;
    obj_tab2            json_object_t;
    obj_tab3            json_object_t;

    v_isAdd             boolean;
    v_isEdit            boolean;
    v_isCopy            varchar2(100 char);

    v_namexam           tvtest.namexame%type;
    v_namexame          tvtest.namexame%type;
    v_namexamt          tvtest.namexam2%type;
    v_namexam3          tvtest.namexam3%type;
    v_namexam4          tvtest.namexam4%type;
    v_namexam5          tvtest.namexam5%type;
    v_codcatexm         tvtest.codcatexm%type;
    v_codexam           tvtest.codexam%type;
    v_qtyexam           tvtest.qtyexam%type;
    v_qtyscore          tvtest.qtyscore%type;
    v_qtyscrpass        tvtest.qtyscrpass%type;
    v_qtyexammin        tvtest.qtyexammin%type;
    v_qtyalrtmin        tvtest.qtyalrtmin%type;
    v_flgmeasure        tvtest.flgmeasure%type;
    v_desexam           tvtest.desexam%type;

    obj_data            json_object_t;
    v_row               number := 0;


    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row_child         number := 0;
    v_count             number := 0;
    v_table             varchar2(100 char);
    param_json_row      json_object_t;

    v_codempid          ttestempd.codempid%type;
    v_dtetest           ttestempd.dtetest%type;
    v_desc_codempid     ttestemp.namtest%type;
    v_qtyques           tvtest.qtyexam%type;
    v_namsubj           tvquest.namsubje%type;
    v_typeexam          tvquest.typeexam%type;
    v_desques           tvquestd1.desquese%type;
    v_statest           ttestemp.statest%type;
    v_flgtest           ttestemp.flgtest%type;
    v_flgAdd            boolean;
    v_codquest_prev     tvquest.codquest%type;                                  --> Peerasak || 25/07/2022 issue#4576

    cursor c_tvquest is
        select a.codquest,
               decode(global_v_lang,'101',a.namsubje,
                                    '102',a.namsubj2,
                                    '103',a.namsubj3,
                                    '104',a.namsubj4,
                                    '105',a.namsubj5,
                                    a.namsubje) namsubj,
               a.typeexam, b.numques,
               decode(global_v_lang,'101',b.desquese,
                                    '102',b.desques2,
                                    '103',b.desques3,
                                    '104',b.desques4,
                                    '105',b.desques5,
                                     b.desquese) desques,
               b.qtyscore, a.qtyexam ,
               a.namsubje,
               a.namsubj2,
               a.namsubj3,
               a.namsubj4,
               a.namsubj5,
               b.desquese,
               b.desques2,
               b.desques3,
               b.desques4,
               b.desques5

          from tvquest a, tvquestd1 b
         where a.codexam = b.codexam
           and a.codquest = b.codquest
           and a.codexam = v_codexam
      order by a.codquest, b.numques;

    cursor c_tvtesta is
        select *
          from tvtesta
         where codexam = v_codexam
      order by scorest;

    v_namsubj_old       tvquest.namsubje%type;
    v_typeexam2     tvquest.typeexam%type;
  begin
    if p_codexamCopy is null then
        v_codexam   := p_codexam;
        v_isCopy    := 'N';
        v_flgAdd    := false;
    else
        v_codexam   := p_codexamCopy;
        v_isCopy    := 'Y';
        v_flgAdd    := true;
    end if;
    v_row       := 0;
    obj_tab2    := json_object_t();
    v_namsubj_old   := '';
    v_typeexam2 := '';
    for r1 in c_tvquest loop
        obj_data    := json_object_t();
        obj_data.put('coderror','200');

        --<< Start >> Peerasak || 25/07/2022 || issue#4576
        obj_data.put('codquest', '');
        obj_data.put('namsubj','');   
        obj_data.put('desc_typeexam','');   
        
        if v_codquest_prev <> r1.codquest or v_codquest_prev is null then
           obj_data.put('codquest', r1.codquest);
        end if;
        
        if v_namsubj_old <> r1.namsubj or v_namsubj_old is null then
            obj_data.put('namsubj',r1.namsubj);
        end if;
        
        if (v_typeexam2 <> r1.typeexam or v_typeexam2 is null) or v_codquest_prev <> r1.codquest or v_codquest_prev is null then
          obj_data.put('desc_typeexam',get_tlistval_name('TYPEEXAM2',r1.typeexam,global_v_lang));
        end if;
        --<< End >>   Peerasak || 29/07/2022 || issue#4576
        
        obj_data.put('namsubje',r1.namsubje);
        obj_data.put('namsubjt',r1.namsubj2);
        obj_data.put('namsubj3',r1.namsubj3);
        obj_data.put('namsubj4',r1.namsubj4);
        obj_data.put('namsubj5',r1.namsubj5);
        obj_data.put('typeexam',r1.typeexam);
        obj_data.put('numques',r1.numques);
        obj_data.put('desques',r1.desques);
        obj_data.put('desquese',r1.desquese);
        obj_data.put('desquest',r1.desques2);
        obj_data.put('desques3',r1.desques3);
        obj_data.put('desques4',r1.desques4);
        obj_data.put('desques5',r1.desques5);
        obj_data.put('qtyscore',r1.qtyscore);

        v_namsubj_old     := r1.namsubj;
        v_typeexam2       := r1.typeexam;
        v_codquest_prev   := r1.codquest;                                       --> Peerasak || 25/07/2022 issue#4576
        
        begin
            select count(*)
              into v_qtyexam
              from tvquestd2
             where codexam = v_codexam
               and codquest = r1.codquest
               and numques = r1.numques;
        exception when others then
            v_qtyexam := 0;
        end;
        obj_data.put('qtyexam',v_qtyexam);
        obj_tab2.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;

    v_row       := 0;
    obj_tab3    := json_object_t();
    
    for r2 in c_tvtesta loop
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgAdd',v_flgAdd);
        obj_data.put('scorest',r2.scorest);
        obj_data.put('scoreen',r2.scoreen);
        obj_data.put('remark',r2.remark);
        obj_tab3.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;

    begin
        select decode(global_v_lang,'101',namexame,
                                                       '102',namexam2,
                                                       '103',namexam3,
                                                       '104',namexam4,
                                                       '105',namexam5) namexam,
               codcatexm ,qtyexam,qtyscore,
               qtyscrpass ,qtyexammin ,qtyalrtmin ,flgmeasure ,desexam,
               namexame, namexam2, namexam3, namexam4, namexam5
          into v_namexam, v_codcatexm,v_qtyexam,v_qtyscore,
               v_qtyscrpass ,v_qtyexammin ,v_qtyalrtmin ,v_flgmeasure ,v_desexam,
               v_namexame, v_namexamt, v_namexam3, v_namexam4, v_namexam5
          from tvtest
         where codexam = v_codexam ;
        v_isAdd     := false;
        v_isEdit    := true;
    exception when no_data_found then
        v_isAdd     := true;
        v_isEdit    := false;
    end;

    obj_tab1 := json_object_t();
    obj_tab1.put('coderror','200');
    obj_tab1.put('codexam',p_codexam);
    obj_tab1.put('namexam',v_namexam);
    obj_tab1.put('namexame',v_namexame);
    obj_tab1.put('namexamt',v_namexamt);
    obj_tab1.put('namexam3',v_namexam3);
    obj_tab1.put('namexam4',v_namexam4);
    obj_tab1.put('namexam5',v_namexam5);
    obj_tab1.put('codcatexm',v_codcatexm);
    obj_tab1.put('qtyexam',v_qtyexam);
    obj_tab1.put('qtyscore',v_qtyscore);
    obj_tab1.put('qtyscrpass',v_qtyscrpass);
    obj_tab1.put('qtyexammin',v_qtyexammin);
    obj_tab1.put('qtyalrtmin',v_qtyalrtmin);
    obj_tab1.put('flgmeasure',v_flgmeasure);
    obj_tab1.put('desexam',v_desexam);

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('codexam',p_codexam);
    obj_detail.put('codexamCopy',p_codexamCopy);

    obj_main := json_object_t();
    obj_main.put('coderror','200');
    obj_main.put('isAdd',v_isAdd);
    obj_main.put('isEdit',v_isEdit);
    obj_main.put('isCopy',v_isCopy);
    obj_main.put('detail',obj_detail);
    obj_main.put('tab1',obj_tab1);
    obj_main.put('tab2',obj_tab2);
    obj_main.put('tab3',obj_tab3);
    begin
      select count(*) into v_count
        from ttestemp
       where codexam  = p_codexam
         and rownum   = 1;
    end;
    if v_count > 0 then
      obj_main.put('flgEdit', 'N');
      obj_main.put('error_msg','HR1450 '||get_terrorm_name('HR1450',global_v_lang));
    else
      obj_main.put('flgEdit', 'Y');
    end if;

    if param_msg_error is null then
      json_str_output := obj_main.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--
  --
  procedure gen_detail_tab2(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_table             varchar2(100 char);
    param_json_row      json_object_t;

    v_codempid          ttestempd.codempid%type;
    v_dtetest           ttestempd.dtetest%type;
    v_codexam           ttestempd.codexam%type;
    v_desc_codempid     ttestemp.namtest%type;
    v_qtyques           tvtest.qtyexam%type;
    v_namsubj           tvquest.namsubje%type;
    v_namsubje          tvquest.namsubje%type;
    v_namsubj2          tvquest.namsubj2%type;
    v_namsubj3          tvquest.namsubj3%type;
    v_namsubj4          tvquest.namsubj4%type;
    v_namsubj5          tvquest.namsubj5%type;

    v_qtyscore          tvquestd1.qtyscore%type;
    v_desques           tvquestd1.desquese%type;
    v_statest           ttestemp.statest%type;

    v_numques           tvquestd1.numques%type;
    v_numans            ttestempd.numans%type;
    v_score             ttestempd.score%type;
    v_answer            ttestempd.answer%type;
    obj_evaluate        json_object_t;
    obj_choice_row      json_object_t;
    obj_choice          json_object_t;
    obj_rightwrong      json_object_t;
    obj_select          json_object_t;
    obj_subjective      json_object_t;
    v_row_choice        number := 0;
    v_sum_qtyscore      number;
    v_sum_score         number;
    v_typeexam          tvquest.typeexam%type;
    v_flgtest           ttestemp.flgtest%type;
    v_typtest           ttestemp.typtest%type;

    v_codcompl          ttestemp.codcompl%type;
    v_codposl           ttestemp.codposl%type;
    count_ttestchk      number;


    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_flgDisabled       boolean;
    v_filename          varchar2(4000);

    v_qtyexam           tvquest.qtyexam%type;
    v_count_tvquestd1   number;

    cursor c_tvquestd1 is
        select tvquestd1.*, decode(global_v_lang,'101',desquese,
                                       '102',desques2,
                                       '103',desques3,
                                       '104',desques4,
                                       '105',desques5) desques
          from tvquestd1
         where codexam = p_codexam
           and codquest = p_codquest
      order by numques;

    cursor c_tvquestd2 is
        select tvquestd2.*, decode(global_v_lang,'101',desanse,
                                       '102',desans2,
                                       '103',desans3,
                                       '104',desans4,
                                       '105',desans5) desans
          from tvquestd2
         where codexam = p_codexam
           and codquest = p_codquest
           and numques = v_numques
      order by numans;

  begin
    obj_evaluate        := json_object_t();
    obj_rightwrong      := json_object_t();
    obj_select          := json_object_t();
    obj_subjective      := json_object_t();

    begin
        select typeexam
          into v_typeexam
          from tvquest
         where codexam = p_codexam
           and codquest = p_codquest;
    exception when no_data_found then
        v_typeexam := p_typeexam;
    end;

    begin
        select decode(global_v_lang,'101',namsubje,
                                    '102',namsubj2,
                                    '103',namsubj3,
                                    '104',namsubj4,
                                    '105',namsubj5,
                                    namsubje) namsubj,
               qtyexam,
               namsubje, namsubj2,namsubj3,namsubj4,namsubj5
          into v_namsubj, v_qtyexam,
               v_namsubje, v_namsubj2, v_namsubj3, v_namsubj4, v_namsubj5
          from tvquest
         where codquest = p_codquest
           and codexam = p_codexam;
    exception when no_data_found then
        v_namsubj   := null;
        v_qtyexam   := null;
    end;

    begin
        select count(numques)
          into v_count_tvquestd1
          from tvquestd1
         where codquest = p_codquest
           and codexam = p_codexam
           and numques = p_numques;
    exception when others then
        v_count_tvquestd1 := 0;
    end;

    if v_typeexam = '1' then
        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r1 in c_tvquestd1 loop
            v_numques := r1.numques;

            obj_choice_row   := json_object_t();
            v_row_choice     := 0;
            for r2 in c_tvquestd2 loop
                obj_choice := json_object_t();
                obj_choice.put('coderror','200');
                obj_choice.put('numseq',v_row_choice +1);
                obj_choice.put('choice',r2.numans);
                obj_choice.put('choice_desc',get_tlistval_name('ANSWER',r2.numans,global_v_lang));
                obj_choice.put('numans',r2.desans);
                obj_choice.put('numanse',r2.desanse);
                obj_choice.put('numanst',r2.desans2);
                obj_choice.put('numans3',r2.desans3);
                obj_choice.put('numans4',r2.desans4);
                obj_choice.put('numans5',r2.desans5);
                obj_choice.put('filename',r2.filename);

                obj_choice_row.put(to_char(v_row_choice), obj_choice);
                v_row_choice    := v_row_choice + 1;
            end loop;

            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',r1.numques);
            obj_data_child.put('desques',r1.desques);
            obj_data_child.put('desquese',r1.desquese);
            obj_data_child.put('desquest',r1.desques2);
            obj_data_child.put('desques3',r1.desques3);
            obj_data_child.put('desques4',r1.desques4);
            obj_data_child.put('desques5',r1.desques5);
            obj_data_child.put('qtyscore',r1.qtyscore);
            obj_data_child.put('numans',obj_choice_row);
            obj_data_child.put('answer',r1.numans);
            obj_data_child.put('filename',r1.filename);
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        if v_count_tvquestd1 = 0 then
            if v_row_choice > 0 then
                p_qtyans := v_row_choice;
            end if;
            obj_choice_row   := json_object_t();
            v_row_choice     := 0;
            for i in 0..(nvl(p_qtyans,0)-1) loop
                obj_choice := json_object_t();
                obj_choice.put('coderror','200');
                obj_choice.put('numseq',v_row_choice +1);
                obj_choice.put('choice',v_row_choice +1);
                obj_choice.put('choice_desc',get_tlistval_name('ANSWER',v_row_choice +1,global_v_lang));
                obj_choice.put('numans','');
                obj_choice.put('numanse','');
                obj_choice.put('numanst','');
                obj_choice.put('numans3','');
                obj_choice.put('numans4','');
                obj_choice.put('numans5','');
                obj_choice.put('filename','');

                obj_choice_row.put(to_char(v_row_choice), obj_choice);
                v_row_choice    := v_row_choice + 1;
            end loop;
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',p_numques);
            obj_data_child.put('desques','');
            obj_data_child.put('desquese','');
            obj_data_child.put('desquest','');
            obj_data_child.put('desques3','');
            obj_data_child.put('desques4','');
            obj_data_child.put('desques5','');
            obj_data_child.put('qtyscore','');
            obj_data_child.put('numans',obj_choice_row);
            obj_data_child.put('answer','');
            obj_data_child.put('filename','');
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end if;

        obj_select.put('coderror','200');
        obj_select.put('codquest',p_codquest);
        obj_select.put('typeexam',v_typeexam);
        obj_select.put('qtyexam',v_row_choice);
        obj_select.put('namsubj',v_namsubj);
        obj_select.put('namsubje',v_namsubje);
        obj_select.put('namsubjt',v_namsubj2);
        obj_select.put('namsubj3',v_namsubj3);
        obj_select.put('namsubj4',v_namsubj4);
        obj_select.put('namsubj5',v_namsubj5);
        obj_select.put('children',obj_row_child);
    elsif v_typeexam = '2' then
        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r1 in c_tvquestd1 loop
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',r1.numques);
            obj_data_child.put('desques',r1.desques);
            obj_data_child.put('desquese',r1.desquese);
            obj_data_child.put('desquest',r1.desques2);
            obj_data_child.put('desques3',r1.desques3);
            obj_data_child.put('desques4',r1.desques4);
            obj_data_child.put('desques5',r1.desques5);
            obj_data_child.put('qtyscore',r1.qtyscore);
            obj_data_child.put('answer',r1.numans);
            obj_data_child.put('filename',r1.filename);
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        if v_count_tvquestd1 = 0 then
            obj_data_child  := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',p_numques);
            obj_data_child.put('desques','');
            obj_data_child.put('desquese','');
            obj_data_child.put('desquest','');
            obj_data_child.put('desques3','');
            obj_data_child.put('desques4','');
            obj_data_child.put('desques5','');
            obj_data_child.put('qtyscore','');
            obj_data_child.put('answer','');
            obj_data_child.put('filename','');
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end if;

        obj_rightwrong.put('coderror','200');
        obj_rightwrong.put('codquest',p_codquest);
        obj_rightwrong.put('typeexam',v_typeexam);
        obj_rightwrong.put('qtyexam',2);
        obj_rightwrong.put('namsubj',v_namsubj);
        obj_rightwrong.put('namsubje',v_namsubje);
        obj_rightwrong.put('namsubjt',v_namsubj2);
        obj_rightwrong.put('namsubj3',v_namsubj3);
        obj_rightwrong.put('namsubj4',v_namsubj4);
        obj_rightwrong.put('namsubj5',v_namsubj5);
        obj_rightwrong.put('children',obj_row_child);
    elsif v_typeexam = '3' then
        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r1 in c_tvquestd1 loop
            v_numques       := r1.numques;

            obj_choice_row   := json_object_t();
            v_row_choice     := 0;
            for r2 in c_tvquestd2 loop
                obj_choice := json_object_t();
                obj_choice.put('coderror','200');
                obj_choice.put('numseq',v_row_choice + 1);
                obj_choice.put('choice',r2.numans);
                obj_choice.put('choice_desc',get_tlistval_name('ANSWER',r2.numans,global_v_lang));
                obj_choice.put('numans',r2.desans);
                obj_choice.put('numanse',r2.desanse);
                obj_choice.put('numanst',r2.desans2);
                obj_choice.put('numans3',r2.desans3);
                obj_choice.put('numans4',r2.desans4);
                obj_choice.put('numans5',r2.desans5);
                obj_choice.put('filename',r2.filename);
                obj_choice.put('score',r2.score);

                obj_choice_row.put(to_char(v_row_choice), obj_choice);
                v_row_choice    := v_row_choice + 1;
            end loop;

            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',r1.numques);
            obj_data_child.put('desques',r1.desques);
            obj_data_child.put('desquese',r1.desquese);
            obj_data_child.put('desquest',r1.desques2);
            obj_data_child.put('desques3',r1.desques3);
            obj_data_child.put('desques4',r1.desques4);
            obj_data_child.put('desques5',r1.desques5);
            obj_data_child.put('qtyscore',r1.qtyscore);
            obj_data_child.put('numans',obj_choice_row);
            obj_data_child.put('filename',r1.filename);
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        if v_count_tvquestd1 = 0 then
            if v_row_choice > 0 then
                p_qtyans := v_row_choice;
            end if;
            obj_choice_row   := json_object_t();
            v_row_choice     := 0;
            for i in 0..(p_qtyans-1) loop
                obj_choice := json_object_t();
                obj_choice.put('coderror','200');
                obj_choice.put('numseq',v_row_choice +1);
                obj_choice.put('choice',v_row_choice +1);
                obj_choice.put('choice_desc',get_tlistval_name('ANSWER',v_row_choice +1,global_v_lang));
                obj_choice.put('numans','');
                obj_choice.put('numanse','');
                obj_choice.put('numanst','');
                obj_choice.put('numans3','');
                obj_choice.put('numans4','');
                obj_choice.put('numans5','');
                obj_choice.put('filename','');
                obj_choice.put('score','');

                obj_choice_row.put(to_char(v_row_choice), obj_choice);
                v_row_choice    := v_row_choice + 1;
            end loop;
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',p_numques);
            obj_data_child.put('desques','');
            obj_data_child.put('desquese','');
            obj_data_child.put('desquest','');
            obj_data_child.put('desques3','');
            obj_data_child.put('desques4','');
            obj_data_child.put('desques5','');
            obj_data_child.put('qtyscore','');
            obj_data_child.put('numans',obj_choice_row);
            obj_data_child.put('filename','');
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end if;

        obj_evaluate.put('coderror','200');
        obj_evaluate.put('codquest',p_codquest);
        obj_evaluate.put('typeexam',v_typeexam);
        obj_evaluate.put('qtyexam',v_row_choice);
        obj_evaluate.put('namsubj',v_namsubj);
        obj_evaluate.put('namsubje',v_namsubje);
        obj_evaluate.put('namsubjt',v_namsubj2);
        obj_evaluate.put('namsubj3',v_namsubj3);
        obj_evaluate.put('namsubj4',v_namsubj4);
        obj_evaluate.put('namsubj5',v_namsubj5);
        obj_evaluate.put('children',obj_row_child);
    elsif v_typeexam = '4' then
        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r1 in c_tvquestd1 loop
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',r1.numques);
            obj_data_child.put('desques',r1.desques);
            obj_data_child.put('desquese',r1.desquese);
            obj_data_child.put('desquest',r1.desques2);
            obj_data_child.put('desques3',r1.desques3);
            obj_data_child.put('desques4',r1.desques4);
            obj_data_child.put('desques5',r1.desques5);
            obj_data_child.put('qtyscore',r1.qtyscore);
            obj_data_child.put('filename',r1.filename);

            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        if v_count_tvquestd1 = 0 then
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('numques',p_numques);
            obj_data_child.put('desques','');
            obj_data_child.put('desquese','');
            obj_data_child.put('desquest','');
            obj_data_child.put('desques3','');
            obj_data_child.put('desques4','');
            obj_data_child.put('desques5','');
            obj_data_child.put('qtyscore','');
            obj_data_child.put('filename','');
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end if;

        obj_subjective.put('coderror','200');
        obj_subjective.put('codquest',p_codquest);
        obj_subjective.put('typeexam',v_typeexam);
        obj_subjective.put('qtyexam',0);
        obj_subjective.put('namsubj',v_namsubj);
        obj_subjective.put('namsubje',v_namsubje);
        obj_subjective.put('namsubjt',v_namsubj2);
        obj_subjective.put('namsubj3',v_namsubj3);
        obj_subjective.put('namsubj4',v_namsubj4);
        obj_subjective.put('namsubj5',v_namsubj5);
        obj_subjective.put('children',obj_row_child);
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('question1',obj_select);
    obj_data.put('question2',obj_rightwrong);
    obj_data.put('question3',obj_evaluate);
    obj_data.put('question4',obj_subjective);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail_tab2;

  procedure get_detail_tab2 (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    param_tab1              json_object_t;
    param_tab2              json_object_t;
    param_tab3              json_object_t;

    v_codquest              tvquestd1.codquest%type;
    v_numques               tvquestd1.numques%type;
    v_flgDelete             boolean;
    v_count_numques         number;
    v_flg                   varchar2(100 char);
    v_scorest               tvtesta.scorest%type;
    v_scorestOld            tvtesta.scorest%type;
    v_scoreen               tvtesta.scoreen%type;
    v_remark                tvtesta.remark%type;

    v_namexame              tvtest.namexame%type;
    v_namexam2              tvtest.namexam2%type;
    v_namexam3              tvtest.namexam3%type;
    v_namexam4              tvtest.namexam4%type;
    v_namexam5              tvtest.namexam5%type;

    v_codcatexm             tvtest.codcatexm%type;
    v_qtyscore              tvtest.qtyscore%type;
    v_qtyscrpass            tvtest.qtyscrpass%type;
    v_qtyexammin            tvtest.qtyexammin%type;
    v_qtyalrtmin            tvtest.qtyalrtmin%type;
    v_qtyexam               tvtest.qtyexam%type;
    v_desexam               tvtest.desexam%type;
    v_flgmeasure            tvtest.flgmeasure%type;
    v_sum_qtyscore          number;

    v_max_scoreen           tvtesta.scoreen%type;
    v_last_scoreen          number;

    param_json_row          json_object_t;

    cursor c_tvquest is
        select *
          from tvquest
         where codexam = p_codexam
      order by codquest;

    cursor c_tvquestd1 is
        select *
          from tvquestd1
         where codexam = p_codexam
           and codquest = v_codquest
      order by numques;
    v_new_numques         number;

    cursor c_evaluate is
        select *
          from tvquest
         where codexam = p_codexam
           and typeexam = '3'
      order by codquest;

    cursor c_tvtesta is
        select *
          from tvtesta
         where codexam = p_codexam;
  begin
    p_codexam           := hcm_util.get_string_t(json_object_t(json_str_input),'p_codexam');
    p_codexamCopy       := hcm_util.get_string_t(json_object_t(json_str_input),'p_codexamCopy');
    p_isCopy            := hcm_util.get_string_t(json_object_t(json_str_input),'p_isCopy');
    param_tab1          := hcm_util.get_json_t(json_object_t(json_str_input),'param_tab1');
    param_tab2          := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'param_tab2'),'rows');
    param_tab3          := hcm_util.get_json_t(json_object_t(json_str_input),'param_tab3');

    v_namexame          := hcm_util.get_string_t(param_tab1,'namexame');
    v_namexam2          := hcm_util.get_string_t(param_tab1,'namexamt');
    v_namexam3          := hcm_util.get_string_t(param_tab1,'namexam3');
    v_namexam4          := hcm_util.get_string_t(param_tab1,'namexam4');
    v_namexam5          := hcm_util.get_string_t(param_tab1,'namexam5');

    v_codcatexm         := hcm_util.get_string_t(param_tab1,'codcatexm');
    v_qtyscore          := hcm_util.get_string_t(param_tab1,'qtyscore');
    v_qtyscrpass        := hcm_util.get_string_t(param_tab1,'qtyscrpass');
    v_qtyexammin        := hcm_util.get_string_t(param_tab1,'qtyexammin');
    v_qtyalrtmin        := hcm_util.get_string_t(param_tab1,'qtyalrtmin');
    v_desexam           := hcm_util.get_string_t(param_tab1,'desexam');
    v_flgmeasure        := hcm_util.get_string_t(param_tab1,'flgmeasure');

    if v_qtyscrpass > v_qtyscore then
        param_msg_error := get_error_msg_php('EL0051',global_v_lang);
    end if;

    if v_qtyalrtmin >= v_qtyexammin then
        param_msg_error := get_error_msg_php('EL0052',global_v_lang);
    end if;

    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    if p_isCopy = 'Y' then
        delete tvtest where codexam = p_codexam;
        delete tvtesta where codexam = p_codexam;
        delete tvquest where codexam = p_codexam;
        delete tvquestd1 where codexam = p_codexam;
        delete tvquestd2 where codexam = p_codexam;

        begin
            insert into tvquest (codexam,codquest,
                                 namsubje,namsubj2,namsubj3,namsubj4,namsubj5,
                                 qtyscore,typeexam,qtyexam,
                                 dtecreate,codcreate,dteupd,coduser)
            select p_codexam,codquest,
                   namsubje,namsubj2,namsubj3,namsubj4,namsubj5,
                   qtyscore,typeexam,qtyexam,
                   sysdate,global_v_coduser,sysdate,global_v_coduser
              from tvquest
             where codexam = p_codexamCopy;
        exception when others then null;
        end;

        begin
            insert into tvquestd1 (codexam,codquest,numques,
                                   desquese,desques2,desques3,desques4,desques5,
                                   filename,qtyscore,numans,
                                   dtecreate,codcreate,dteupd,coduser)
            select p_codexam,codquest,numques,
                   desquese,desques2,desques3,desques4,desques5,
                   filename,qtyscore,numans,
                   sysdate,global_v_coduser,sysdate,global_v_coduser
              from tvquestd1
             where codexam = p_codexamCopy;
        exception when others then null;
        end;

        begin
            insert into tvquestd2 (codexam,codquest,numques,numans,
                                   desanse,desans2,desans3,desans4,desans5,
                                   filename,score,
                                   dtecreate,codcreate,dteupd,coduser)
            select p_codexam,codquest,numques,numans,
                   desanse,desans2,desans3,desans4,desans5,
                   filename,score,
                   sysdate,global_v_coduser,sysdate,global_v_coduser
              from tvquestd2
             where codexam = p_codexamCopy;
        exception when others then null;
        end;

    end if;

    if param_tab2.get_size > 0 then
        for i in 0..param_tab2.get_size-1 loop
            param_json_row      := hcm_util.get_json_t(param_tab2,to_char(i));
            v_codquest          := hcm_util.get_string_t(param_json_row,'codquest');
            v_numques           := hcm_util.get_string_t(param_json_row,'numques');
            v_flgDelete         := hcm_util.get_boolean_t(param_json_row,'flgDelete');


            if v_flgDelete then
                delete tvquestd1
                 where codexam = p_codexam
                   and codquest = v_codquest
                   and numques = v_numques;

                delete tvquestd2
                 where codexam = p_codexam
                   and codquest = v_codquest
                   and numques = v_numques;

                select count (numques), sum(qtyscore)
                  into v_count_numques,v_sum_qtyscore
                  from tvquestd1
                 where codexam = p_codexam
                   and codquest = v_codquest;

                if v_count_numques = 0 then
                    delete tvquest
                     where codexam = p_codexam
                       and codquest = v_codquest;
                else
                    update tvquest
                       set qtyexam = v_count_numques,
                           qtyscore = v_sum_qtyscore
                     where codexam = p_codexam
                       and codquest = v_codquest;
                end if;
            end if;
        end loop;

        for r1 in c_tvquest loop
            v_new_numques   := 0;
            v_codquest      := r1.codquest;

            update tvquestd1
               set numques = numques * 1000
             where codexam = p_codexam
               and codquest = v_codquest;

            update tvquestd2
               set numques = numques * 1000
             where codexam = p_codexam
               and codquest = v_codquest;

            for r2 in c_tvquestd1 loop
                v_new_numques := v_new_numques + 1;
                update tvquestd1
                   set numques = v_new_numques
                 where codexam = p_codexam
                   and codquest = v_codquest
                   and numques = r2.numques;

                update tvquestd2
                   set numques = v_new_numques
                 where codexam = p_codexam
                   and codquest = v_codquest
                   and numques = r2.numques;
            end loop;
        end loop;
    end if;

    for r1 in c_tvquest loop
        if (v_flgmeasure = 'Y' and r1.typeexam != '3') then
            param_msg_error := get_error_msg_php('EL0057',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        elsif (v_flgmeasure = 'N' and r1.typeexam = '3') then
            param_msg_error := get_error_msg_php('EL0058',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
    end loop;

    if param_tab3.get_size > 0 then
        for i in 0..param_tab3.get_size-1 loop
            param_json_row      := hcm_util.get_json_t(param_tab3,to_char(i));
            v_flg               := hcm_util.get_string_t(param_json_row,'flg');
            v_scorest           := hcm_util.get_string_t(param_json_row,'scorest');
            v_scorestOld        := hcm_util.get_string_t(param_json_row,'scorestOld');
            v_scoreen           := hcm_util.get_string_t(param_json_row,'scoreen');
            v_remark            := hcm_util.get_string_t(param_json_row,'remark');

            if v_flg = 'delete' then
                delete tvtesta
                 where codexam = p_codexam
                   and scorest = v_scorestOld;
            elsif v_flg = 'add' then
                insert into tvtesta (codexam,scorest,scoreen,remark,
                                     dtecreate,codcreate,dteupd,coduser)
                values (p_codexam,v_scorest,v_scoreen,v_remark,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            elsif v_flg = 'edit' then
                update tvtesta
                   set scorest = v_scorest,
                       scoreen = v_scoreen,
                       remark = v_remark,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codexam = p_codexam
                   and scorest = v_scorestOld;
            end if;
        end loop;
    end if;

    v_last_scoreen := null;
    for r1 in c_tvtesta loop
        if v_last_scoreen is null then
            v_last_scoreen := r1.scoreen;
        else
            if r1.scorest != (v_last_scoreen + 1) then
                param_msg_error := get_error_msg_php('EL0059',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                rollback;
                return;
            else
                v_last_scoreen := r1.scoreen;
            end if;
        end if;
    end loop;

    begin
        select max(scoreen)
          into v_max_scoreen
          from tvtesta
         where codexam = p_codexam;
    exception when others then
        v_max_scoreen := 0;
    end;

    for r1 in c_evaluate loop
        if r1.qtyscore > v_max_scoreen then
            param_msg_error := get_error_msg_php('EL0053',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
    end loop;

    begin
        select count(*)
          into v_qtyexam
          from tvquestd1
         where codexam = p_codexam;
    exception when others then
        v_qtyexam := 0;
    end;

    begin
        insert into tvtest (codexam,namexame,namexam2,namexam3,namexam4,namexam5,
                            codcatexm,qtyscore,qtyscrpass,qtyexammin,qtyalrtmin,
                            qtyexam,desexam,flgmeasure,
                            dtecreate,codcreate,dteupd,coduser)
        values (p_codexam,v_namexame,v_namexam2,v_namexam3,v_namexam4,v_namexam5,
                v_codcatexm,v_qtyscore,v_qtyscrpass,v_qtyexammin,v_qtyalrtmin,
                v_qtyexam,v_desexam,v_flgmeasure,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvtest
           set namexame = v_namexame,
               namexam2 = v_namexam2,
               namexam3 = v_namexam3,
               namexam4 = v_namexam4,
               namexam5 = v_namexam5,
               codcatexm = v_codcatexm,
               qtyscore = v_qtyscore,
               qtyscrpass = v_qtyscrpass,
               qtyexammin = v_qtyexammin,
               qtyalrtmin = v_qtyalrtmin,
               qtyexam = v_qtyexam,
               desexam = v_desexam,
               flgmeasure = v_flgmeasure,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam;
    end;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(403,param_msg_error,global_v_lang);
    rollback;
  end save_detail;
  --
  procedure post_save_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--
  procedure save_index(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json              json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    v_flg                   varchar2(100 char);
    v_codexam               ttestemp.codexam%type;
    v2_chk_exam             number:=0; 

  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codexam           := hcm_util.get_string_t(param_json_row,'codexam');
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');

        if v_flg = 'delete' then
            -->> #4573 || 30/05/2022
            begin
               select count(*) into v2_chk_exam 
               from ttestemp where codexam = v_codexam ;
            end;            
            if v2_chk_exam > 0 then
                param_msg_error := get_error_msg_php('EL0061',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                rollback;
                return;
            end if;
            -->> #4573 || 30/05/2022

            delete tvtest
             where codexam = v_codexam;

            delete tvtesta
             where codexam = v_codexam;

            delete tvquest
             where codexam = v_codexam;

            delete tvquestd1
             where codexam = v_codexam;

            delete tvquestd2
             where codexam = v_codexam;
        end if;
      end loop;
    end if;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end save_index;
  --
  procedure post_save_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--
--
  procedure delete_question(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json              json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    v_flg                   varchar2(100 char);
    v_codexam               ttestemp.codexam%type;
    v_qtyexam               tvquest.qtyexam%type;
    v_qtyscore              tvquest.qtyscore%type;
    cursor c_tvquestd1 is
        select *
          from tvquestd1
         where codexam = p_codexam
           and codquest = p_codquest
      order by numques;
    v_new_numques           number;
  begin
    delete tvquestd1
     where codexam = p_codexam
       and codquest = p_codquest
       and numques = p_numques;

    delete tvquestd2
     where codexam = p_codexam
       and codquest = p_codquest
       and numques = p_numques;

    update tvquestd1
       set numques = numques * 1000
     where codexam = p_codexam
       and codquest = p_codquest;

    update tvquestd2
       set numques = numques * 1000
     where codexam = p_codexam
       and codquest = p_codquest;

    v_new_numques := 0;
    for r1 in c_tvquestd1 loop
        v_new_numques := v_new_numques + 1;
        update tvquestd1
           set numques = v_new_numques
         where codexam = p_codexam
           and codquest = p_codquest
           and numques = r1.numques;

        update tvquestd2
           set numques = v_new_numques
         where codexam = p_codexam
           and codquest = p_codquest
           and numques = r1.numques;
    end loop;

    select count(*) , sum(qtyscore)
      into v_qtyexam, v_qtyscore
      from tvquestd1
     where codexam = p_codexam
       and codquest = p_codquest;

    update tvquest
       set qtyexam = v_qtyexam,
           qtyscore = v_qtyscore
     where codexam = p_codexam
       and codquest = p_codquest;

    select count(*)
      into v_qtyexam
      from tvquestd1
     where codexam = p_codexam;

    update tvtest
       set qtyexam = v_qtyexam
     where codexam = p_codexam;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end delete_question;
  --
  procedure post_delete_question(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_question(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail_tab2(json_str_input in clob,json_str_output out clob) as
    param_data              json_object_t;
    param_detailExam        json_object_t;

    v_codquest              tvquestd1.codquest%type;
    v_numques               tvquestd1.numques%type;
    v_flgDelete             boolean;
    v_count_numques         number;
    v_flg                   varchar2(100 char);
    v_scorest               tvtesta.scorest%type;
    v_scorestOld            tvtesta.scorest%type;
    v_scoreen               tvtesta.scoreen%type;
    v_remark                tvtesta.remark%type;

    v_namexame              tvtest.namexame%type;
    v_namexam2              tvtest.namexam2%type;
    v_namexam3              tvtest.namexam3%type;
    v_namexam4              tvtest.namexam4%type;
    v_namexam5              tvtest.namexam5%type;

    v_codcatexm             tvtest.codcatexm%type;
    v_qtyscore              tvtest.qtyscore%type;
    v_qtyscrpass            tvtest.qtyscrpass%type;
    v_qtyexammin            tvtest.qtyexammin%type;
    v_qtyalrtmin            tvtest.qtyalrtmin%type;
    v_qtyexam               tvtest.qtyexam%type;
    v_desexam               tvtest.desexam%type;
    v_flgmeasure            tvtest.flgmeasure%type;

    v_desquese              tvquestd1.desquese%type;
    v_desques2              tvquestd1.desques2%type;
    v_desques3              tvquestd1.desques3%type;
    v_desques4              tvquestd1.desques4%type;
    v_desques5              tvquestd1.desques5%type;
    v_filename              tvquestd1.filename%type;
    v_filename_c            tvquestd2.filename%type;
    v_numans                tvquestd1.numans%type;
    a_numans                json_object_t;

    v_namsubje              tvquest.namsubje%type;
    v_namsubj2              tvquest.namsubj2%type;
    v_namsubj3              tvquest.namsubj3%type;
    v_namsubj4              tvquest.namsubj4%type;
    v_namsubj5              tvquest.namsubj5%type;
    v_typeexam              tvquest.typeexam%type;

    v_desanse               tvquestd2.desanse%type;
    v_desans2               tvquestd2.desans2%type;
    v_desans3               tvquestd2.desans3%type;
    v_desans4               tvquestd2.desans4%type;
    v_desans5               tvquestd2.desans5%type;
    v_choice                tvquestd2.numans%type;
    v_score                 tvquestd2.score%type;
    v_max_scoreen           tvtesta.scoreen%type;
    param_json_row          json_object_t;

    cursor c_evaluate is
        select *
          from tvquest
         where codexam = p_codexam
           and typeexam = '3'
      order by codquest;
  begin
    p_codexam           := hcm_util.get_string_t(json_object_t(json_str_input),'p_codexam');
    p_codquest          := hcm_util.get_string_t(json_object_t(json_str_input),'p_codquest');

    v_namsubje          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubje');
    v_namsubj2          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubjt');
    v_namsubj3          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj3');
    v_namsubj4          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj4');
    v_namsubj5          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj5');
    v_typeexam          := hcm_util.get_string_t(json_object_t(json_str_input),'p_typeexam');

    param_data          := hcm_util.get_json_t(json_object_t(json_str_input),'data');
    v_numques           := hcm_util.get_string_t(param_data,'numques');
    v_desquese          := hcm_util.get_string_t(param_data,'desquese');
    v_desques2          := hcm_util.get_string_t(param_data,'desquest');
    v_desques3          := hcm_util.get_string_t(param_data,'desques3');
    v_desques4          := hcm_util.get_string_t(param_data,'desques4');
    v_desques5          := hcm_util.get_string_t(param_data,'desques5');
    v_filename          := hcm_util.get_string_t(param_data,'filename');
    v_qtyscore          := hcm_util.get_string_t(param_data,'qtyscore');
    v_numans            := hcm_util.get_string_t(param_data,'answer');
    a_numans            := hcm_util.get_json_t(param_data,'numans');

    v_flgmeasure        := hcm_util.get_string_t(hcm_util.get_json_t(json_object_t(json_str_input),'detailExam'),'flgmeasure');

    if (v_flgmeasure = 'Y' and v_typeexam != '3') then
        param_msg_error := get_error_msg_php('EL0057',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    elsif (v_flgmeasure = 'N' and v_typeexam = '3') then
        param_msg_error := get_error_msg_php('EL0058',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    end if;

    if a_numans.get_size > 0 then
        for i in 0..a_numans.get_size-1 loop
            param_json_row      := hcm_util.get_json_t(a_numans,to_char(i));
            v_choice            := hcm_util.get_string_t(param_json_row,'choice');
            v_filename_c        := hcm_util.get_string_t(param_json_row,'filename');
            v_desanse           := hcm_util.get_string_t(param_json_row,'numanse');
            v_desans2           := hcm_util.get_string_t(param_json_row,'numanst');
            v_desans3           := hcm_util.get_string_t(param_json_row,'numans3');
            v_desans4           := hcm_util.get_string_t(param_json_row,'numans4');
            v_desans5           := hcm_util.get_string_t(param_json_row,'numans5');
            v_score             := hcm_util.get_string_t(param_json_row,'score');

            if v_typeexam = '3' and v_score > v_qtyscore then
                param_msg_error := get_error_msg_php('CO0007',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                rollback;
                return;
            end if;

            begin
                insert into tvquestd2 (codexam,codquest,numques,numans,
                                       desanse,desans2,desans3,desans4,desans5,
                                       filename,score,
                                       dtecreate,codcreate,dteupd,coduser)
                     values (p_codexam,p_codquest,v_numques,v_choice,
                                       v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                       v_filename_c,v_score,
                                       sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tvquestd2
                   set desanse = v_desanse,
                       desans2 = v_desans2,
                       desans3 = v_desans3,
                       desans4 = v_desans4,
                       desans5 = v_desans5,
                       filename = v_filename_c,
                       score = v_score,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codexam = p_codexam
                   and codquest = p_codquest
                   and numques = v_numques
                   and numans = v_choice;
            end;

        end loop;
    end if;


    if v_typeexam = '2' then
        v_desanse   := get_label_name('HREL31E3', 101, 155);
        v_desans2   := get_label_name('HREL31E3', 102, 155);
        v_desans3   := get_label_name('HREL31E3', 103, 155);
        v_desans4   := get_label_name('HREL31E3', 104, 155);
        v_desans5   := get_label_name('HREL31E3', 105, 155);
        begin
            insert into tvquestd2 (codexam,codquest,numques,numans,
                                   desanse,desans2,desans3,desans4,desans5,
                                   filename,score,
                                   dtecreate,codcreate,dteupd,coduser)
                 values (p_codexam,p_codquest,v_numques,1,
                                   v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                   null,null,
                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tvquestd2
               set desanse = v_desanse,
                   desans2 = v_desans2,
                   desans3 = v_desans3,
                   desans4 = v_desans4,
                   desans5 = v_desans5,
                   filename = null,
                   score = null,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codexam = p_codexam
               and codquest = p_codquest
               and numques = v_numques
               and numans = 1;
        end;

        v_desanse   := get_label_name('HREL31E3', 101, 156);
        v_desans2   := get_label_name('HREL31E3', 102, 156);
        v_desans3   := get_label_name('HREL31E3', 103, 156);
        v_desans4   := get_label_name('HREL31E3', 104, 156);
        v_desans5   := get_label_name('HREL31E3', 105, 156);
        begin
            insert into tvquestd2 (codexam,codquest,numques,numans,
                                   desanse,desans2,desans3,desans4,desans5,
                                   filename,score,
                                   dtecreate,codcreate,dteupd,coduser)
                 values (p_codexam,p_codquest,v_numques,2,
                                   v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                   null,null,
                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tvquestd2
               set desanse = v_desanse,
                   desans2 = v_desans2,
                   desans3 = v_desans3,
                   desans4 = v_desans4,
                   desans5 = v_desans5,
                   filename = null,
                   score = null,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codexam = p_codexam
               and codquest = p_codquest
               and numques = v_numques
               and numans = 2;
        end;
    end if;

    begin
        insert into tvquestd1 (codexam,codquest,numques,
                               desquese,desques2,desques3,desques4,desques5,
                               filename,qtyscore,numans,
                               dtecreate,codcreate,dteupd,coduser)
             values (p_codexam,p_codquest,v_numques,
                               v_desquese,v_desques2,v_desques3,v_desques4,v_desques5,
                               v_filename,v_qtyscore,v_numans,
                               sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvquestd1
           set desquese = v_desquese,
               desques2 = v_desques2,
               desques3 = v_desques3,
               desques4 = v_desques4,
               desques5 = v_desques5,
               filename = v_filename,
               qtyscore = v_qtyscore,
               numans = v_numans,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam
           and codquest = p_codquest
           and numques = v_numques;
    end;

    begin
        select count(*), sum(qtyscore)
          into v_qtyexam, v_qtyscore
          from tvquestd1
         where codexam = p_codexam
           and codquest = p_codquest;
    exception when others then
        v_qtyexam   := 0;
        v_qtyscore  := 0;
    end;

    begin
        insert into tvquest (codexam,codquest,
                             namsubje,namsubj2,namsubj3,namsubj4,namsubj5,
                             qtyscore,typeexam,qtyexam,
                             dtecreate,codcreate,dteupd,coduser)
             values (p_codexam,p_codquest,
                     v_namsubje,v_namsubj2,v_namsubj3,v_namsubj4,v_namsubj5,
                     v_qtyscore,v_typeexam,v_qtyexam,
                     sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvquest
           set namsubje = v_namsubje,
               namsubj2 = v_namsubj2,
               namsubj3 = v_namsubj3,
               namsubj4 = v_namsubj4,
               namsubj5 = v_namsubj5,
               qtyscore = v_qtyscore,
               typeexam = v_typeexam,
               qtyexam = v_qtyexam,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam
           and codquest = p_codquest;
    end;

    begin
        select max(scoreen)
          into v_max_scoreen
          from tvtesta
         where codexam = p_codexam;
    exception when others then
        v_max_scoreen  := 0;
    end;

    for r1 in c_evaluate loop
        if r1.qtyscore > v_max_scoreen then
            param_msg_error := get_error_msg_php('EL0053',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
    end loop;

    param_detailExam    := hcm_util.get_json_t(json_object_t(json_str_input),'detailExam');
    v_namexame          := hcm_util.get_string_t(param_detailExam,'namexame');
    v_namexam2          := hcm_util.get_string_t(param_detailExam,'namexamt');
    v_namexam3          := hcm_util.get_string_t(param_detailExam,'namexam3');
    v_namexam4          := hcm_util.get_string_t(param_detailExam,'namexam4');
    v_namexam5          := hcm_util.get_string_t(param_detailExam,'namexam5');

    v_codcatexm         := hcm_util.get_string_t(param_detailExam,'codcatexm');
    v_qtyscore          := hcm_util.get_string_t(param_detailExam,'qtyscore');
    v_qtyscrpass        := hcm_util.get_string_t(param_detailExam,'qtyscrpass');
    v_qtyexammin        := hcm_util.get_string_t(param_detailExam,'qtyexammin');
    v_qtyalrtmin        := hcm_util.get_string_t(param_detailExam,'qtyalrtmin');
    v_desexam           := hcm_util.get_string_t(param_detailExam,'desexam');
    v_flgmeasure        := hcm_util.get_string_t(param_detailExam,'flgmeasure');

    begin
        select count(*)
          into v_qtyexam
          from tvquestd1
         where codexam = p_codexam;
    exception when others then
        v_qtyexam  := 0;
    end;

    begin
        insert into tvtest (codexam,namexame,namexam2,namexam3,namexam4,namexam5,
                            codcatexm,qtyscore,qtyscrpass,qtyexammin,qtyalrtmin,
                            qtyexam,desexam,flgmeasure,
                            dtecreate,codcreate,dteupd,coduser)
        values (p_codexam,v_namexame,v_namexam2,v_namexam3,v_namexam4,v_namexam5,
                v_codcatexm,v_qtyscore,v_qtyscrpass,v_qtyexammin,v_qtyalrtmin,
                v_qtyexam,v_desexam,v_flgmeasure,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvtest
           set namexame = v_namexame,
               namexam2 = v_namexam2,
               namexam3 = v_namexam3,
               namexam4 = v_namexam4,
               namexam5 = v_namexam5,
               codcatexm = v_codcatexm,
               qtyscore = v_qtyscore,
               qtyscrpass = v_qtyscrpass,
               qtyexammin = v_qtyexammin,
               qtyalrtmin = v_qtyalrtmin,
               qtyexam = v_qtyexam,
               desexam = v_desexam,
               flgmeasure = v_flgmeasure,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam;
    end;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(403,param_msg_error,global_v_lang);
    rollback;
  end save_detail_tab2;
  --
  procedure post_save_detail_tab2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail_tab2(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail_tab2_all(json_str_input in clob,json_str_output out clob) as
    param_data              json_object_t;
    param_detailExam        json_object_t;

    v_codquest              tvquestd1.codquest%type;
    v_numques               tvquestd1.numques%type;
    v_flgDelete             boolean;
    v_count_numques         number;
    v_flg                   varchar2(100 char);
    v_scorest               tvtesta.scorest%type;
    v_scorestOld            tvtesta.scorest%type;
    v_scoreen               tvtesta.scoreen%type;
    v_remark                tvtesta.remark%type;

    v_namexame              tvtest.namexame%type;
    v_namexam2              tvtest.namexam2%type;
    v_namexam3              tvtest.namexam3%type;
    v_namexam4              tvtest.namexam4%type;
    v_namexam5              tvtest.namexam5%type;

    v_codcatexm             tvtest.codcatexm%type;
    v_qtyscore              tvtest.qtyscore%type;
    v_qtyscrpass            tvtest.qtyscrpass%type;
    v_qtyexammin            tvtest.qtyexammin%type;
    v_qtyalrtmin            tvtest.qtyalrtmin%type;
    v_qtyexam               tvtest.qtyexam%type;
    v_desexam               tvtest.desexam%type;
    v_flgmeasure            tvtest.flgmeasure%type;

    v_desquese              tvquestd1.desquese%type;
    v_desques2              tvquestd1.desques2%type;
    v_desques3              tvquestd1.desques3%type;
    v_desques4              tvquestd1.desques4%type;
    v_desques5              tvquestd1.desques5%type;
    v_filename              tvquestd1.filename%type;
    v_filename_c            tvquestd2.filename%type;
    v_numans                tvquestd1.numans%type;
    a_numans                json_object_t;

    v_namsubje              tvquest.namsubje%type;
    v_namsubj2              tvquest.namsubj2%type;
    v_namsubj3              tvquest.namsubj3%type;
    v_namsubj4              tvquest.namsubj4%type;
    v_namsubj5              tvquest.namsubj5%type;
    v_typeexam              tvquest.typeexam%type;

    v_desanse               tvquestd2.desanse%type;
    v_desans2               tvquestd2.desans2%type;
    v_desans3               tvquestd2.desans3%type;
    v_desans4               tvquestd2.desans4%type;
    v_desans5               tvquestd2.desans5%type;
    v_choice                tvquestd2.numans%type;
    v_score                 tvquestd2.score%type;
    v_max_scoreen           tvtesta.scoreen%type;
    param_json_row          json_object_t;
    param_question          json_object_t;

    cursor c_evaluate is
        select *
          from tvquest
         where codexam = p_codexam
           and typeexam = '3'
      order by codquest;

  begin
    p_codexam           := hcm_util.get_string_t(json_object_t(json_str_input),'p_codexam');
    p_codquest          := hcm_util.get_string_t(json_object_t(json_str_input),'p_codquest');

    v_namsubje          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubje');
    v_namsubj2          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubjt');
    v_namsubj3          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj3');
    v_namsubj4          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj4');
    v_namsubj5          := hcm_util.get_string_t(json_object_t(json_str_input),'p_namsubj5');
    v_typeexam          := hcm_util.get_string_t(json_object_t(json_str_input),'p_typeexam');

    if v_typeexam = '1' then
        param_question      := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'question1'),'children');
    elsif v_typeexam = '2' then
        param_question      := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'question2'),'children');
    elsif v_typeexam = '3' then
        param_question      := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'question3'),'children');
    elsif v_typeexam = '4' then
        param_question      := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'question4'),'children');
    end if;

    v_flgmeasure := hcm_util.get_string_t(hcm_util.get_json_t(json_object_t(json_str_input),'detailExam'),'flgmeasure');

    if (v_flgmeasure = 'Y' and v_typeexam != '3') then
        param_msg_error := get_error_msg_php('EL0057',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    elsif (v_flgmeasure = 'N' and v_typeexam = '3') then
        param_msg_error := get_error_msg_php('EL0058',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    end if;

    if param_question.get_size > 0 then
        for i in 0..param_question.get_size-1 loop
            param_data      := hcm_util.get_json_t(param_question,to_char(i));
            v_numques           := hcm_util.get_string_t(param_data,'numques');
            v_desquese          := hcm_util.get_string_t(param_data,'desquese');
            v_desques2          := hcm_util.get_string_t(param_data,'desquest');
            v_desques3          := hcm_util.get_string_t(param_data,'desques3');
            v_desques4          := hcm_util.get_string_t(param_data,'desques4');
            v_desques5          := hcm_util.get_string_t(param_data,'desques5');
            v_filename          := hcm_util.get_string_t(param_data,'filename');
            v_qtyscore          := hcm_util.get_string_t(param_data,'qtyscore');
            v_numans            := hcm_util.get_string_t(param_data,'answer');
            a_numans            := hcm_util.get_json_t(param_data,'numans');

            if a_numans.get_size > 0 then
                for j in 0..a_numans.get_size-1 loop
                    param_json_row      := hcm_util.get_json_t(a_numans,to_char(j));
                    v_choice            := hcm_util.get_string_t(param_json_row,'choice');
                    v_filename_c        := hcm_util.get_string_t(param_json_row,'filename');
                    v_desanse           := hcm_util.get_string_t(param_json_row,'numanse');
                    v_desans2           := hcm_util.get_string_t(param_json_row,'numanst');
                    v_desans3           := hcm_util.get_string_t(param_json_row,'numans3');
                    v_desans4           := hcm_util.get_string_t(param_json_row,'numans4');
                    v_desans5           := hcm_util.get_string_t(param_json_row,'numans5');
                    v_score             := hcm_util.get_string_t(param_json_row,'score');
                    begin
                        insert into tvquestd2 (codexam,codquest,numques,numans,
                                               desanse,desans2,desans3,desans4,desans5,
                                               filename,score,
                                               dtecreate,codcreate,dteupd,coduser)
                             values (p_codexam,p_codquest,v_numques,v_choice,
                                               v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                               v_filename_c,v_score,
                                               sysdate,global_v_coduser,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        update tvquestd2
                           set desanse = v_desanse,
                               desans2 = v_desans2,
                               desans3 = v_desans3,
                               desans4 = v_desans4,
                               desans5 = v_desans5,
                               filename = v_filename_c,
                               score = v_score,
                               dteupd = sysdate,
                               coduser = global_v_coduser
                         where codexam = p_codexam
                           and codquest = p_codquest
                           and numques = v_numques
                           and numans = v_choice;
                    end;

                end loop;
            end if;

            if v_typeexam = '2' then
                v_desanse   := get_label_name('HREL31E3', 101, 155);
                v_desans2   := get_label_name('HREL31E3', 102, 155);
                v_desans3   := get_label_name('HREL31E3', 103, 155);
                v_desans4   := get_label_name('HREL31E3', 104, 155);
                v_desans5   := get_label_name('HREL31E3', 105, 155);
                begin
                    insert into tvquestd2 (codexam,codquest,numques,numans,
                                           desanse,desans2,desans3,desans4,desans5,
                                           filename,score,
                                           dtecreate,codcreate,dteupd,coduser)
                         values (p_codexam,p_codquest,v_numques,1,
                                           v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                           null,null,
                                           sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tvquestd2
                       set desanse = v_desanse,
                           desans2 = v_desans2,
                           desans3 = v_desans3,
                           desans4 = v_desans4,
                           desans5 = v_desans5,
                           filename = null,
                           score = null,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codexam = p_codexam
                       and codquest = p_codquest
                       and numques = v_numques
                       and numans = 1;
                end;

                v_desanse   := get_label_name('HREL31E3', 101, 156);
                v_desans2   := get_label_name('HREL31E3', 102, 156);
                v_desans3   := get_label_name('HREL31E3', 103, 156);
                v_desans4   := get_label_name('HREL31E3', 104, 156);
                v_desans5   := get_label_name('HREL31E3', 105, 156);
                begin
                    insert into tvquestd2 (codexam,codquest,numques,numans,
                                           desanse,desans2,desans3,desans4,desans5,
                                           filename,score,
                                           dtecreate,codcreate,dteupd,coduser)
                         values (p_codexam,p_codquest,v_numques,2,
                                           v_desanse,v_desans2,v_desans3,v_desans4,v_desans5,
                                           null,null,
                                           sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tvquestd2
                       set desanse = v_desanse,
                           desans2 = v_desans2,
                           desans3 = v_desans3,
                           desans4 = v_desans4,
                           desans5 = v_desans5,
                           filename = null,
                           score = null,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codexam = p_codexam
                       and codquest = p_codquest
                       and numques = v_numques
                       and numans = 2;
                end;
            end if;
            begin
                insert into tvquestd1 (codexam,codquest,numques,
                                       desquese,desques2,desques3,desques4,desques5,
                                       filename,qtyscore,numans,
                                       dtecreate,codcreate,dteupd,coduser)
                     values (p_codexam,p_codquest,v_numques,
                                       v_desquese,v_desques2,v_desques3,v_desques4,v_desques5,
                                       v_filename,v_qtyscore,v_numans,
                                       sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tvquestd1
                   set desquese = v_desquese,
                       desques2 = v_desques2,
                       desques3 = v_desques3,
                       desques4 = v_desques4,
                       desques5 = v_desques5,
                       filename = v_filename,
                       qtyscore = v_qtyscore,
                       numans = v_numans,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codexam = p_codexam
                   and codquest = p_codquest
                   and numques = v_numques;
            end;
        end loop;
    end if;

    begin
        select count(*), sum(qtyscore)
          into v_qtyexam, v_qtyscore
          from tvquestd1
         where codexam = p_codexam
           and codquest = p_codquest;
    exception when others then
        v_qtyexam       := 0;
        v_qtyscore      := 0;
    end;

    begin
        insert into tvquest (codexam,codquest,
                             namsubje,namsubj2,namsubj3,namsubj4,namsubj5,
                             qtyscore,typeexam,qtyexam,
                             dtecreate,codcreate,dteupd,coduser)
             values (p_codexam,p_codquest,
                     v_namsubje,v_namsubj2,v_namsubj3,v_namsubj4,v_namsubj5,
                     v_qtyscore,v_typeexam,v_qtyexam,
                     sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvquest
           set namsubje = v_namsubje,
               namsubj2 = v_namsubj2,
               namsubj3 = v_namsubj3,
               namsubj4 = v_namsubj4,
               namsubj5 = v_namsubj5,
               qtyscore = v_qtyscore,
               typeexam = v_typeexam,
               qtyexam = v_qtyexam,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam
           and codquest = p_codquest;
    end;

    begin
        select max(scoreen)
          into v_max_scoreen
          from tvtesta
         where codexam = p_codexam;
    exception when others then
        v_max_scoreen := 0;
    end;

    for r1 in c_evaluate loop
        if r1.qtyscore > v_max_scoreen then
            param_msg_error := get_error_msg_php('EL0053',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
    end loop;

    param_detailExam    := hcm_util.get_json_t(json_object_t(json_str_input),'detailExam');
    v_namexame          := hcm_util.get_string_t(param_detailExam,'namexame');
    v_namexam2          := hcm_util.get_string_t(param_detailExam,'namexamt');
    v_namexam3          := hcm_util.get_string_t(param_detailExam,'namexam3');
    v_namexam4          := hcm_util.get_string_t(param_detailExam,'namexam4');
    v_namexam5          := hcm_util.get_string_t(param_detailExam,'namexam5');

    v_codcatexm         := hcm_util.get_string_t(param_detailExam,'codcatexm');
    v_qtyscore          := hcm_util.get_string_t(param_detailExam,'qtyscore');
    v_qtyscrpass        := hcm_util.get_string_t(param_detailExam,'qtyscrpass');
    v_qtyexammin        := hcm_util.get_string_t(param_detailExam,'qtyexammin');
    v_qtyalrtmin        := hcm_util.get_string_t(param_detailExam,'qtyalrtmin');
    v_desexam           := hcm_util.get_string_t(param_detailExam,'desexam');
    v_flgmeasure        := hcm_util.get_string_t(param_detailExam,'flgmeasure');

    begin
        select count(*)
          into v_qtyexam
          from tvquestd1
         where codexam = p_codexam;
    exception when others then
        v_qtyexam := 0;
    end;

    begin
        insert into tvtest (codexam,namexame,namexam2,namexam3,namexam4,namexam5,
                            codcatexm,qtyscore,qtyscrpass,qtyexammin,qtyalrtmin,
                            qtyexam,desexam,flgmeasure,
                            dtecreate,codcreate,dteupd,coduser)
        values (p_codexam,v_namexame,v_namexam2,v_namexam3,v_namexam4,v_namexam5,
                v_codcatexm,v_qtyscore,v_qtyscrpass,v_qtyexammin,v_qtyalrtmin,
                v_qtyexam,v_desexam,v_flgmeasure,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tvtest
           set namexame = v_namexame,
               namexam2 = v_namexam2,
               namexam3 = v_namexam3,
               namexam4 = v_namexam4,
               namexam5 = v_namexam5,
               codcatexm = v_codcatexm,
               qtyscore = v_qtyscore,
               qtyscrpass = v_qtyscrpass,
               qtyexammin = v_qtyexammin,
               qtyalrtmin = v_qtyalrtmin,
               qtyexam = v_qtyexam,
               desexam = v_desexam,
               flgmeasure = v_flgmeasure,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codexam = p_codexam;
    end;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(403,param_msg_error,global_v_lang);
    rollback;
  end save_detail_tab2_all;
  --
  procedure post_save_detail_tab2_all(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail_tab2_all(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HREL31E;

/
