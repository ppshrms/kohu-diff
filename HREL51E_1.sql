--------------------------------------------------------
--  DDL for Package Body HREL51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL51E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_datest            := to_date(hcm_util.get_string_t(json_obj,'p_datest'),'dd/mm/yyyy');
    p_dateen            := to_date(hcm_util.get_string_t(json_obj,'p_dateen'),'dd/mm/yyyy');
    p_typtest           := hcm_util.get_string_t(json_obj,'p_typtest');
    p_codcatexm         := hcm_util.get_string_t(json_obj,'p_codcatexm');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    p_codquest          := hcm_util.get_string_t(json_obj,'p_codquest');
    p_dtetest           := to_date(hcm_util.get_string_t(json_obj,'p_dtetest'),'ddmmyyyy');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_flgcall           := hcm_util.get_string_t(json_obj,'p_flgcall');
    p_typetest           := hcm_util.get_string_t(json_obj,'p_typetest');
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
        select count(*) into v_count_comp
          from tcenter
         where codcomp like p_codcomp || '%' ;
      exception when others then null;
      end;
      if v_count_comp < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end if;

/* -- #4636 || 01/06/2022
      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
*/ -- #4636 || 01/06/2022

    end if;
    if p_codcours is null and p_codcatexm is null and p_codexam is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codcours is not null then
      begin
        select count(*) into v_chkExist
          from tcourse
         where codcours = p_codcours;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
        return;
      end if;
    end if;
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
    if p_codexam is not null then
      begin
        select count(*) into v_chkExist
          from tvtest
         where codexam = p_codexam;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_codexam           ttestchk.codexam%type;
    v_codpos            ttestchk.codposc%type;
    v_codcomp           ttestchk.codcomp%type;
    v_codempid          ttestchk.codempidc%type;
    v_staemp            temploy1.staemp%type;
    v_flggrade          varchar2(2 char);
    v_table             varchar2(100 char);
    v_check_secur       boolean;
    v_chksecu           boolean := false;
    v_flgdata           boolean := false;
    v2_codcomp          varchar2(100 char);
    v2_codpos           varchar2(100 char);

    cursor c1 is
        select a.rowid,a.*, b.codcatexm, b.qtyexam, decode(global_v_lang,'101',namexame,
                                                   '102',namexam2,
                                                   '103',namexam3,
                                                   '104',namexam4,
                                                   '105',namexam5) namexam
          from ttestemp a, tvtest b
         where a.codexam = b.codexam
           and ((p_typtest = '2'
                and typtest in ('2','3','4','5')
                and codcomp like p_codcomp||'%'
                and ((codcours = nvl(p_codcours, codcours) and codcours is not null) or (codcours is null and p_codcours is null ) ))
            or (p_typtest = '1'
                and typtest = '1'
                and codcompl like p_codcomp||'%'))
           and b.codcatexm = nvl(p_codcatexm, b.codcatexm)
           and a.codexam = nvl(p_codexam, a.codexam)
           and flgtest in ('C', 'G')
           and dtetest between p_datest and p_dateen           
           and a.codempidc is not null  -- #4632 || 08/06/2022         
      order by b.codcatexm, a.codexam, a.codempid;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
        v_flgdata := true;
--<<  #4636 || 01/06/2022
        --v_check_secur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        begin
            select codcomp ,codpos 
            into v2_codcomp ,v2_codpos
            from temploy1
            where codempid = global_v_codempid;
        exception when no_data_found then
            v2_codcomp := null;
            v2_codpos  := null;
        end;

        if nvl(r1.codempidc,'@#$%^') = global_v_codempid then
            v_check_secur := true;
        else
           if (r1.codcompc = v2_codcomp) and (r1.codposc = v2_codpos) then
                v_check_secur := true;    
           else
                v_check_secur := false;
           end if; 
        end if;
-->>  #4636 || 01/06/2022

        if v_check_secur then
            v_chksecu := true;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('rowid',r1.rowid);
            obj_data.put('codcatexm',r1.codcatexm);
            obj_data.put('desc_codcatexm',get_tcodec_name('TCODCATEXM', r1.codcatexm, global_v_lang));
            obj_data.put('codexam',r1.codexam);
            obj_data.put('namexam',r1.namexam);
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',r1.namtest);
            obj_data.put('dtetest', to_char(r1.dtetest,'dd/mm/yyyy'));
            obj_data.put('status',get_tlistval_name('FLGTEST',r1.flgtest,global_v_lang));
            obj_data.put('codempidc',r1.codempidc);
            obj_data.put('desc_codempidc',get_temploy_name(r1.codempidc,global_v_lang));
            obj_data.put('dtecheck', to_char(r1.dtecheck,'dd/mm/yyyy'));
            obj_data.put('score',r1.score);
            obj_data.put('statest', r1.statest);
            obj_data.put('qtyques',r1.qtyexam);
            obj_data.put('typtest',r1.typtest);
            obj_data.put('typetest',r1.typetest);
            obj_row.put(to_char(v_row), obj_data);
            v_row := v_row + 1;
        end if;
      end loop;
    if not v_flgdata  then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTESTEMP');
    elsif not v_check_secur then
      param_msg_error := get_error_msg_php('EL0055', global_v_lang);  -- #4636 || 01/06/2022
      --param_msg_error := get_error_msg_php('HR3007', global_v_lang); #4636 || 01/06/2022
    end if;
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
  procedure gen_detail(json_str_output out clob) is
    obj_data            json_object_t;
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
    v_typeexam          tvquest.typeexam%type;
    v_qtyscore          tvquestd1.qtyscore%type;
    v_desques           tvquestd1.desquese%type;
    v_statest           ttestemp.statest%type;
    v_flgtest           ttestemp.flgtest%type;
    v_typetest           ttestemp.flgtest%type;
    v_typtest           ttestemp.flgtest%type;
    v_desc_codempidc    ttestemp.codempid%type;
    v_score             ttestempd.score%type;

    cursor c_ttestempd is
        select *
          from ttestempd
         where codempid = v_codempid
           and codexam = v_codexam
           and dtetest = v_dtetest
           and typetest = v_typetest
           and typtest = v_typtest
      order by codquest, numques;

    cursor c1 is
        select a.codquest,a.codexam,a.typeexam,b.numques,
        decode(global_v_lang,'101',desquese,
                                          '102',desques2,
                                          '103',desques3,
                                          '104',desques4,
                                          '105',desques5) as desques,
       decode(global_v_lang,'101',namsubje,
                                           '102',namsubj2,
                                           '103',namsubj3,
                                           '104',namsubj4,
                                           '105',namsubj5) as namsubj,
        b.qtyscore
        from tvquest a, tvquestd1 b
        where a.codexam = v_codexam
        and a.codexam = b.codexam
        and a.codquest = b.codquest
        order by codquest, numques;

  begin
    obj_row := json_object_t();
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
        v_desc_codempid     := hcm_util.get_string_t(param_json_row,'desc_codempid');
        v_dtetest           := to_date(hcm_util.get_string_t(param_json_row,'dtetest'),'dd/mm/yyyy');
        v_codexam           := hcm_util.get_string_t(param_json_row,'codexam');
        v_qtyques           := hcm_util.get_string_t(param_json_row,'qtyques');
        v_typetest          := hcm_util.get_string_t(param_json_row,'typetest');
        v_typtest           := hcm_util.get_string_t(param_json_row,'typtest');
        v_desc_codempidc    := hcm_util.get_string_t(param_json_row,'codempidc');

        begin
            select flgtest, statest
              into v_flgtest, v_statest
              from ttestemp
             where codempid = v_codempid
               and dtetest = v_dtetest
               and codexam = v_codexam
               and typetest = v_typetest
               and typtest = v_typtest;
        exception when no_data_found then
            v_flgtest := null;
            v_statest := null;
        end;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',v_codempid);
        obj_data.put('desc_codempid',v_desc_codempid);
        obj_data.put('codexam',v_codexam);
        obj_data.put('dtetest',to_char(v_dtetest,'dd/mm/yyyy'));
        obj_data.put('qtyques',v_qtyques);
        obj_data.put('codexam',v_codexam);
        obj_data.put('flgtest', v_flgtest);
        obj_data.put('statest', v_statest);
        obj_data.put('typetest', v_typetest);
        obj_data.put('typtest', v_typtest);
        obj_data.put('desc_codempidc', get_temploy_name(v_desc_codempidc,global_v_lang));


        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r2 in c1 loop

            begin
                select score
                  into v_score
                  from ttestempd
                 where codexam = r2.codexam
                   and codempid = v_codempid
                   and codquest = r2.codquest
                   and dtetest = v_dtetest
                   and typetest = v_typetest
                   and typtest = v_typtest
                   and numques = r2.numques;
            exception when no_data_found then
                v_namsubj := null;
                v_typeexam := null;
            end;
--            begin
--                select decode(global_v_lang,'101',namsubje,
--                                           '102',namsubj2,
--                                           '103',namsubj3,
--                                           '104',namsubj4,
--                                           '105',namsubj5) namsubj,
--                       typeexam
--                  into v_namsubj, v_typeexam
--                  from tvquest
--                 where codexam = r2.codexam
--                   and codquest = r2.codquest;
--            exception when no_data_found then
--                v_namsubj := null;
--                v_typeexam := null;
--            end;
--
--            begin
--                select decode(global_v_lang,'101',desquese,
--                                           '102',desques2,
--                                           '103',desques3,
--                                           '104',desques4,
--                                           '105',desques5) desques,
--                       qtyscore
--                  into v_desques , v_qtyscore
--                  from tvquestd1
--                 where codexam = r2.codexam
--                   and codquest = r2.codquest
--                   and numques = r2.numques;
--            exception when no_data_found then
--                v_desques := null;
--                v_qtyscore := null;
--            end;

            obj_data_child  := json_object_t();
            obj_data_child.put('coderror','200');
            obj_data_child.put('codempid',v_codempid);
            obj_data_child.put('numseq',v_row_child + 1);
            obj_data_child.put('codquest',r2.codquest);
            obj_data_child.put('namsubje',r2.namsubj);
            obj_data_child.put('typquest',get_tlistval_name('TYPEEXAM2',r2.typeexam,global_v_lang));
            obj_data_child.put('typeexam',r2.typeexam);
            obj_data_child.put('numques',r2.numques);
            obj_data_child.put('desques',r2.desques);
            obj_data_child.put('qtyscore',r2.qtyscore);
            obj_data_child.put('score',v_score);
            obj_data_child.put('typetest', v_typetest);
            obj_data_child.put('typtest', v_typtest);
            if v_score is null then
--                obj_data_child.put('statest',get_label_name('HREL51EC2',global_v_lang,'210'));
                obj_data_child.put('statest_',false);
            else
                obj_data_child.put('statest',get_label_name('HREL51EC2',global_v_lang,'200'));
                obj_data_child.put('statest_',true);
            end if;
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        obj_data.put('children',obj_row_child);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;

    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
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
  procedure gen_detail_exam(json_str_output out clob) is
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
    v_codexamchk        texampos.codexamchk%type;

    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_flgDisabled       boolean;
    v_filename          varchar2(4000);
    v_error             varchar2(200) := '';

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
    exception when others then
        null;
    end;

    if v_typeexam in ('1','2','3') then
        v_row_child     := 0;
        obj_row_child   := json_object_t();
        for r1 in c_tvquestd1 loop
            v_numques := r1.numques;
            begin
                select numans, score
                  into v_numans, v_score
                  from ttestempd
                 where codempid = p_codempid_query
                   and codexam = r1.codexam
                   and dtetest = p_dtetest
                   and codquest = r1.codquest
                   and numques = r1.numques
                   and typtest = p_typtest
                   and typetest = p_typetest;
            exception when no_data_found then
                v_numans    := null;
                v_score     := 0;
            end;

            v_sum_qtyscore  := nvl(v_sum_qtyscore,0) + nvl(r1.qtyscore,0);
            v_sum_score     := nvl(v_sum_score,0) + nvl(v_score,0);

            obj_choice_row   := json_object_t();
            v_row_choice     := 0;

            for r2 in c_tvquestd2 loop
                v_filename := r2.filename;
                if v_filename is not null then
                  v_filename := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL31E2') || '/' || v_filename;
                end if;
                obj_choice := json_object_t();
                obj_choice.put('coderror','200');
                obj_choice.put('desc_grditem',r2.desans);
                obj_choice.put('filename',v_filename);
                obj_choice.put('grad',r2.numans);
                if v_typeexam in('1','3') then
                    obj_choice.put('desc_grad',get_tlistval_name('ANSWER',r2.numans,global_v_lang));
                end if;
                obj_choice.put('item',v_row_choice + 1);
                obj_choice.put('numans',v_numans);
                obj_choice_row.put(to_char(v_row_choice), obj_choice);


                v_row_choice    := v_row_choice + 1;
            end loop;

            v_filename := r1.filename;

            if v_filename is not null then
              v_filename := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL31E1') || '/' || v_filename;
            end if;
            obj_data_child := json_object_t();
            obj_data_child.put('coderror','200');
            if v_typeexam = '1' then
                obj_data_child.put('corctans',get_tlistval_name('ANSWER',r1.numans,global_v_lang));
            end if;

            obj_data_child.put('desanse',obj_choice_row);
            obj_data_child.put('desques',r1.desques);
            obj_data_child.put('filenamehead',v_filename);
            obj_data_child.put('numques',r1.numques);
            obj_data_child.put('score',v_score);
            obj_data_child.put('answer',v_numans);
            obj_row_child.put(to_char(v_row_child), obj_data_child);
            v_row_child     := v_row_child + 1;
        end loop;

        obj_data_child := json_object_t();
        obj_data_child.put('qtyscore',v_sum_qtyscore);
        obj_data_child.put('score',v_sum_score);
        if v_typeexam = '1' then
            obj_select.put('coderror','200');
            obj_select.put('detail',obj_data_child);
            obj_select.put('table',obj_row_child);
        elsif v_typeexam = '2' then
            obj_rightwrong.put('coderror','200');
            obj_rightwrong.put('detail',obj_data_child);
            obj_rightwrong.put('table',obj_row_child);
        elsif v_typeexam = '3' then
            obj_evaluate.put('coderror','200');
            obj_evaluate.put('detail',obj_data_child);
            obj_evaluate.put('table',obj_row_child);
        end if;
    elsif v_typeexam = '4' then
        v_row_child     := 0;
        obj_row_child   := json_object_t();

        begin
            select flgtest, typtest,codposl
              into v_flgtest, v_typtest,v_codposl
              from ttestemp
             where codempid = p_codempid_query
               and codexam = p_codexam
               and dtetest = p_dtetest;
        exception when others then
            v_flgtest := null;
            v_typtest := null;
        end;
        if v_flgtest = 'G' then
            v_flgDisabled   := true;
            v_error := get_error_msg_php('EL0056',global_v_lang);
            v_error := replace(v_error,'@#$%400','');
        else
            v_flgDisabled := false;
            if v_typtest = '1' then
                begin
                    select codexamchk
                      into v_codexamchk
                      from texampos
                     where codpos = v_codposl
--                       and p_codexam in (codexam1,codexam2,codexam3,codexam4)
                       and codexam = p_codexam
                       and codexamchk = global_v_codempid;
                exception when no_data_found then
                    v_codexamchk := null;
                end;
                if v_codexamchk is null then
                    param_msg_error := get_error_msg_php('EL0055',global_v_lang);
                end if;
            else
                begin
                    select count(*)
                      into count_ttestchk
                      from ttestchk
                     where codexam = p_codexam;
                exception when others then
                    count_ttestchk := 0;
                end;
                if count_ttestchk = 0 then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTESTCHK');
                else
                    begin
                        select codcomp, codpos
                          into v_codcomp, v_codpos
                          from temploy1
                         where codempid = global_v_codempid;
                    exception when others then
                        v_codcomp   := null;
                        v_codpos   := null;
                    end;

                    begin
                        select count(*)
                          into count_ttestchk
                          from ttestchk
                         where codcomp like p_codcomp||'%'
                           and codexam = p_codexam
                           and ((codempidc is not null and global_v_codempid = codempidc)
                                or (codcompc = v_codcomp and codposc = v_codpos));
                    exception when others then
                        count_ttestchk   := 0;
                    end;

                    if count_ttestchk  = 0 then
                        param_msg_error := get_error_msg_php('EL0055',global_v_lang);
                    end if;
                end if;
            end if;
        end if;
        if param_msg_error is null then
            for r1 in c_tvquestd1 loop
                begin
                    select answer, score
                      into v_answer, v_score
                      from ttestempd
                     where codempid = p_codempid_query
                       and codexam = r1.codexam
                       and dtetest = p_dtetest
                       and codquest = r1.codquest
                       and numques = r1.numques
                       and typtest = p_typtest
                       and typetest = p_typetest;
                exception when no_data_found then
                    v_answer    := null;
                    v_score     := null;
                end;

                v_filename := r1.filename;
                if v_filename is not null then
                  v_filename := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL31E1') || '/' || v_filename;
                end if;

                obj_data_child := json_object_t();
                obj_data_child.put('coderror','200');
                obj_data_child.put('answer',v_answer);
                obj_data_child.put('desques',r1.desques);
                obj_data_child.put('filenamehead',v_filename);
                obj_data_child.put('numques',r1.numques);
                obj_data_child.put('score',v_score);

                obj_row_child.put(to_char(v_row_child), obj_data_child);
                v_row_child     := v_row_child + 1;
            end loop;

            obj_subjective.put('coderror','200');
            obj_data_child := json_object_t();
            obj_data_child.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
            obj_data_child.put('typtest','');
            obj_data_child.put('flgdisabled',v_flgDisabled);
            obj_data_child.put('warning',v_error);
            obj_subjective.put('detail',obj_data_child);
            obj_subjective.put('table',obj_row_child);
        end if;
    end if;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
    obj_detail.put('typtest','');

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('evaluate',obj_evaluate);
    obj_data.put('rightwrong',obj_rightwrong);
    obj_data.put('select',obj_select);
    obj_data.put('subjective',obj_subjective);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail_exam;

  procedure get_detail_exam (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_exam(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_popupscore(json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_codexam           ttestchk.codexam%type;
    v_codpos            ttestchk.codposc%type;
    v_codcomp           ttestchk.codcomp%type;
    v_codempid          ttestchk.codempidc%type;
    v_staemp            temploy1.staemp%type;
    v_flggrade          varchar2(2 char);
    v_table             varchar2(100 char);
    cursor c1 is
        select *
          from tvtesta
         where codexam = p_codexam
      order by scorest;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('score',r1.scorest||'-'||r1.scoreen);
        obj_data.put('descscore',r1.remark);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
      end loop;
    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TVTESTA');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_popupscore;

  procedure get_popupscore (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popupscore(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_subjective(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json              json_object_t;
    v_numques               ttestempd.numques%type;
    v_score                 ttestempd.score%type;
    v_fullscore             tvquestd1.qtyscore%type;

    obj_data                json_object_t;
    obj_detail              json_object_t;
    obj_table               json_object_t;

    v_qtyscrpass            tvtest.qtyscrpass%type;
    sum_score               ttestempd.score%type;
    v_statest               varchar2(1);
    count_notchk            number;
  begin
    obj_table := json_object_t();
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_numques       := hcm_util.get_string_t(param_json_row,'numques');
        v_score         := hcm_util.get_string_t(param_json_row,'score');

        begin
          select qtyscore
            into v_fullscore
            from tvquestd1
           where codexam = p_codexam
            and codquest = p_codquest
             and numques = v_numques;
        exception when no_data_found then
          v_fullscore := 0;
        end;


        if v_score is not null  then
            param_json_row.put('statest',get_label_name('HREL51EC2',global_v_lang,'200'));
            if v_score > v_fullscore then
              param_msg_error := get_error_msg_php('EL0061',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              rollback;
              return;
            end if;
        else
            param_json_row.put('statest',get_label_name('HREL51EC2',global_v_lang,'210'));
            param_msg_error := get_error_msg_php('EL0060',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
            return;
        end if;

        param_json_row.put('statest_',true);
        param_json_row.put('codquest',p_codquest);
        update ttestempd
           set score = v_score,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and codexam = p_codexam
           and dtetest = p_dtetest
           and codquest = p_codquest
           and numques = v_numques;
        obj_table.put(to_char(i),param_json_row);
      end loop;
    end if;

    begin
        select sum(score)
          into sum_score
          from ttestempd
         where codempid = p_codempid_query
           and codexam = p_codexam
           and dtetest = p_dtetest
           and typtest = p_typtest
           and typetest = p_typetest;
    exception when others then
        sum_score := 0;
    end;

    begin
        select nvl(qtyscrpass,0)
          into v_qtyscrpass
          from tvtest
         where codexam = p_codexam;
    exception when others then
        v_qtyscrpass := 0;
    end;

    begin
        select count(*)
          into count_notchk
          from ttestempd
         where codempid = p_codempid_query
           and codexam = p_codexam
           and dtetest = p_dtetest
           and score is null
           and typtest = p_typtest
           and typetest = p_typetest;
    exception when others then
        count_notchk := 0;
    end;

    if count_notchk > 0 then
        v_statest := '';
    else
        if sum_score >= v_qtyscrpass then
            v_statest := 'Y';
        else
            v_statest := 'N';
        end if;
    end if;

    obj_detail := json_object_t();
    obj_detail.put('statest',v_statest);
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('response',replace(param_msg_error,'@#$%201',null));
    obj_data.put('detail',obj_detail);
    obj_data.put('table',obj_table);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end save_subjective;
  --
  procedure post_save_subjective(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_subjective(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json              json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    v_flg                   varchar2(100 char);
    v_numseq                varchar2(100 char);
    v_codpos                ttestchk.codposc%type;
    v_codcomp               ttestchk.codcomp%type;

    v_codempid              ttestemp.codempidc%type;
    v_dtetest               ttestemp.dtetest%type;
    v_codexam               ttestemp.codexam%type;
    v_typtest               ttestemp.typtest%type;
    v_typetest              ttestemp.typetest%type;
    v_score                 ttestemp.score%type;
    v_codcompc              ttestemp.codcompc%type;
    v_codposc               ttestemp.codposc%type;
    v_qtyscrpass            tvtest.qtyscrpass%type;
    v_statest               ttestemp.statest%type;
    v_ttestemp              ttestemp%rowtype;
    v_summary_checked       boolean;
    v_statest_              boolean;
    v_tpotentp              tpotentp%rowtype;
    v_tyrtrsch              tyrtrsch%rowtype;
    v_tcourse               tcourse%rowtype;
    v_thisclss              thisclss%rowtype;
    v_qtyprescr             thistrnn.qtyprescr%type;
--    v_qtyposscr             thistrnn.qtytotscr%type;
--    v_qtytrflw              thistrnn.qtytrflw%type;
--    v_dtetrflw              thistrnn.dtetrfu%type;
--    v_costcent              thistrnn.costcent%type;
    v_tinstruc              tinstruc%rowtype;
/*    el_dteexam1	      thistrnn.dteexam1%type;
    el_dteexam2	      thistrnn.dteexam2%type;
    el_codexam	      thistrnn.codexam%type;
    el_codexam2	      thistrnn.codexam2%type; */

    v_typeexam      tvquest.typeexam%type;
  begin
    begin
        select codcomp, codpos
          into v_codcompc, v_codposc
          from temploy1
         where codempid = global_v_codempid;
    exception when others then
        v_codcompc  := null;
        v_codposc  := null;
    end;

    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
        v_dtetest           := to_date(hcm_util.get_string_t(param_json_row,'dtetest'),'dd/mm/yyyy');
        v_codexam           := hcm_util.get_string_t(param_json_row,'codexam');
        v_typtest           := hcm_util.get_string_t(param_json_row,'typtest');
        v_typetest          := hcm_util.get_string_t(param_json_row,'typetest');

        param_json_child    := hcm_util.get_json_t(param_json_row,'children');
        v_score             := 0;
        v_summary_checked := false;
        for j in 0..param_json_child.get_size-1 loop
          param_json_row_child  := hcm_util.get_json_t(param_json_child,to_char(j));
          v_numseq              := hcm_util.get_string_t(param_json_row_child,'numseq');
          v_score               := v_score + nvl(to_number(hcm_util.get_string_t(param_json_row_child,'score')),0);
          v_statest_            := hcm_util.get_boolean_t(param_json_row_child,'statest_');
          v_typeexam            := hcm_util.get_string_t(param_json_row_child,'typeexam');

          if v_typeexam = 4 and not v_summary_checked then
            v_summary_checked := true;
--            exit;
          end if;
        end loop;

        if v_summary_checked then
            begin
                select nvl(qtyscrpass,0)
                  into v_qtyscrpass
                  from tvtest
                 where codexam = v_codexam;
            exception when others then
                v_qtyscrpass  := 0;
            end;

            if v_score >= v_qtyscrpass then
                v_statest := 'Y';
            else
                v_statest := 'N';
            end if;


           begin
            update ttestemp
               set flgtest = 'G',
                   dtecheck = sysdate,
                   codempidc = global_v_codempid,
                   codcompc = v_codcompc,
                   codposc = v_codposc,
                   score = v_score,
                   statest = v_statest,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = v_codempid
               and dtetest = v_dtetest
               and codexam = v_codexam
               and typtest = v_typtest
               and typetest = v_typetest;
            exception when others then
              null;
            end;

            begin
                select *
                  into v_ttestemp
                  from ttestemp
                 where codempid = v_codempid
                   and dtetest = v_dtetest
                   and codexam = v_codexam
                   and typtest = v_typtest
                  and typetest = v_typetest;
            exception when others then
                v_qtyscrpass  := 0;
            end;

            if v_ttestemp.flglogin = '3' and v_ttestemp.chaptno is not null then
                update tlrnchap
                   set staexam = v_ttestemp.statest,
                       score = v_ttestemp.score,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = v_ttestemp.codempid
                   and dtechapst = v_ttestemp.dtetrain
                   and codcours = v_ttestemp.codcours
                   and codsubj = v_ttestemp.codsubj
                   and chaptno = v_ttestemp.chaptno;
            elsif v_ttestemp.flglogin = '3' and v_ttestemp.codsubj is not null then
                update tlrnsubj
                   set staexam = v_ttestemp.statest,
                       score = v_ttestemp.score,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = v_ttestemp.codempid
                   and dtesubjst = v_ttestemp.dtetrain
                   and codcours = v_ttestemp.codcours
                   and codsubj = v_ttestemp.codsubj;
            elsif v_ttestemp.flglogin = '3' then
                if v_ttestemp.typetest = '1' then
                    update tlrncourse
                       set stapreteset = v_ttestemp.statest,
                           qtyprescr = v_ttestemp.score,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codempid = v_ttestemp.codempid
                       and dtecourst = v_ttestemp.dtetrain
                       and codcours = v_ttestemp.codcours;
                elsif v_ttestemp.typetest = '2' then
                    update tlrncourse
                       set staposttest = v_ttestemp.statest,
                           qtyposscr = v_ttestemp.score,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codempid = v_ttestemp.codempid
                       and dtecourst = v_ttestemp.dtetrain
                       and codcours = v_ttestemp.codcours;
                end if;
            elsif v_ttestemp.flglogin = '1' then
                update tappoinf
                   set qtyfscore = v_ttestemp.qtyscore,
--                       numgrd = v_ttestemp.score,
                       qtyscoreavg = v_ttestemp.score,
                       codasapl = decode(v_statest,'Y','P','F'),
                       stapphinv = 'C'
                 where numappl = v_ttestemp.numappl
                   and numreqrq = v_ttestemp.numreql
                   and codposrq = v_ttestemp.codposl
                   and numapseq = (select max(numapseq)
                                     from tappoinf
                                    where numappl = v_ttestemp.numappl
                                      and numreqrq = v_ttestemp.numreql
                                      and codposrq = v_ttestemp.codposl);
            elsif v_ttestemp.flglogin = '2' then
                begin
                    select *
                      into v_tpotentp
                      from tpotentp
                     where dteyear = v_ttestemp.dteyear
                       and numclseq = v_ttestemp.numclseq
                       and codcours = v_ttestemp.codcours
                       and codempid = v_ttestemp.codempid;
                exception when no_data_found then
                    v_tpotentp := null;
                end;

                begin
                    select *
                      into v_tyrtrsch
                      from tyrtrsch
                     where dteyear     = v_ttestemp.dteyear
                       and codcours    = v_ttestemp.codcours
                       and numclseq    = v_ttestemp.numclseq;
                exception when no_data_found then
                    v_tyrtrsch := null;
                end;

                begin
                    select *
                      into v_thisclss
                      from thisclss
                     where dteyear     = v_ttestemp.dteyear
                       and codcours    = v_ttestemp.codcours
                       and numclseq    = v_ttestemp.numclseq;
                exception when no_data_found then
                    v_thisclss := null;
                end;

                begin
                    select *
                      into v_tcourse
                      from tcourse
                     where codcours    = v_ttestemp.codcours;
                exception when no_data_found then
                    v_tcourse := null;
                end;

                begin
                    select *
                      into v_tinstruc
                      from tinstruc
                     where codinst    = v_tyrtrsch.codinst;
                exception when no_data_found then
                    v_tinstruc := null;
                end;

--                if v_tcourse.qtytrflw > 0 and v_tcourse.qtytrflw is not null then
--                    v_dtetrflw := add_months(v_tyrtrsch.dtetren,v_tcourse.qtytrflw);
--                else
--                    v_dtetrflw := null;
--                end if;

/*                if v_ttestemp.typetest = '1' then
                    v_qtyprescr := v_ttestemp.score;
                    el_dteexam1 := sysdate;
                    el_codexam := p_codexam;
                elsif v_ttestemp.typetest = '2' then
--                    v_qtyposscr := v_ttestemp.score;
                    el_dteexam2 := sysdate;
                    el_codexam2 := p_codexam;
                end if;*/

--                begin
--                insert into thistrnn(
--                                    codempid,dteyear,codcours,numclseq,dtemonth,
--                                    codpos,codcomp,codtparg,codplan,amttrexp,
--                                    qtyctpr,dtecntr,destrfu1,flgtrevl,qtytotscr,
--                                    dtetrst,dtetren,codinsts,codhotel,qtytrhur,
--                                    descommt,dtecrte,codcrte,remarks,dtetrfu,
--                                    codrespn,qtyabshr,codinst,dteupd,coduser,
--                                    codcate,numcert,dtecert,typtrain,flgupdcmp,
--                                    desbenefit,dessummary,descomment,qtyprescr,
--                                    dteinput,flgeva,dteexam1,dteexam2,codexam,codexam2
--                                    )
--                            values(v_ttestemp.codempid,v_ttestemp.dteyear,v_ttestemp.codcours,v_ttestemp.numclseq,v_tpotentp.dtemonth,
--                                    v_tpotentp.codpos,v_tpotentp.codcomp,v_tpotentp.codtparg,v_thisclss.codplan,v_tyrtrsch.amtcost,
--                                    null,null,v_thisclss.objective,decode(v_statest,'Y','P','F'),v_qtyposscr,
--                                    v_tyrtrsch.dtetrst,v_tyrtrsch.dtetren,v_tyrtrsch.codinsts,v_tyrtrsch.codhotel,(nvl(v_tyrtrsch.qtytrmin,0)*60),
--                                    v_tcourse.descommt,null,null,null,v_dtetrflw,
--                                    v_thisclss.codrespn,null,v_tyrtrsch.codinst,sysdate,global_v_coduser,
--                                    v_tcourse.codcate,null,null,v_thisclss.typtrain,v_thisclss.flgupdcmp,
--                                    v_thisclss.desbenefit,v_thisclss.dessummary,v_thisclss.descomment,v_qtyprescr,
--                                    sysdate,null,el_dteexam1,el_dteexam2,el_codexam,el_codexam2);
--
--                exception when dup_val_on_index then
--                    update thistrnn
--                       set dtemonth = v_tpotentp.dtemonth,
--                            codpos = v_tpotentp.codpos,
--                            codcomp = v_tpotentp.codcomp,
--                            codtparg = v_tpotentp.codtparg,
--                            codplan = v_thisclss.codplan,
--                            amttrexp = v_tyrtrsch.amtcost,
--                            qtyctpr = null,
--                            dtecntr = null,
--                            destrfu1 = v_thisclss.objective,
--                            flgtrevl = decode(v_statest,'Y','P','F'),
--                            qtytotscr = v_qtyposscr,
--                            dtetrst = v_tyrtrsch.dtetrst,
--                            dtetren = v_tyrtrsch.dtetren,
--                            codinsts = v_tyrtrsch.codinsts,
--                            codhotel = v_tyrtrsch.codhotel,
--                            qtytrhur = (nvl(v_tyrtrsch.qtytrmin,0)*60),
--                            descommt = v_tcourse.descommt,
--                            dtecrte = null,
--                            codcrte = null,
--                            remarks = null,
--                            dtetrfu = v_dtetrflw,
--                            codrespn = v_thisclss.codrespn,
--                            qtyabshr = null,
--                            codinst = v_tyrtrsch.codinst,
--                            dteupd = sysdate,
--                            coduser = global_v_coduser,
--                            codcate = v_tcourse.codcate,
--                            numcert = null,
--                            dtecert = null,
--                            typtrain = v_thisclss.typtrain,
--                            flgupdcmp = v_thisclss.flgupdcmp,
--                            desbenefit = v_thisclss.desbenefit,
--                            dessummary = v_thisclss.dessummary,
--                            descomment = v_thisclss.descomment,
--                            qtyprescr = v_qtyprescr,
--                            dteinput = sysdate,
--                            flgeva = null,
--                            dteexam1 = el_dteexam1,
--                            dteexam2 = el_dteexam2,
--                            codexam = el_codexam,
--                            codexam2 = el_codexam2
--                            where codempid = v_ttestemp.codempid
--                            and dteyear = v_ttestemp.dteyear
--                            and codcours = v_ttestemp.codcours
--                            and numclseq = v_ttestemp.numclseq;
--                 end;
            end if;

        end if;

      end loop;

    end if;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
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
  procedure gen_export(json_str_output out clob) is
    obj_data            json_object_t;
    obj_main_data       json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    obj_tableEx1        json_object_t;
    obj_tableEx2        json_object_t;
    obj_tableEx3        json_object_t;
    obj_tableEx4        json_object_t;

    v_row               number := 0;
    v_row_tableEx1      number := 0;
    v_row_tableEx2      number := 0;
    v_row_tableEx3      number := 0;
    v_row_tableEx4      number := 0;

    v_row_child         number := 0;
    v_count             number := 0;
    v_table             varchar2(100 char);
    param_json_row      json_object_t;

    v_codempid          ttestempd.codempid%type;
    v_dtetest           ttestempd.dtetest%type;
    v_codexam           ttestempd.codexam%type;
    v_qtyques           tvtest.qtyexam%type;
    v_namsubj           tvquest.namsubje%type;
    v_typeexam          tvquest.typeexam%type;
    v_qtyscore          tvquestd1.qtyscore%type;
    v_desques           tvquestd1.desquese%type;
    v_statest           ttestemp.statest%type;
    v_flgtest           ttestemp.flgtest%type;
    v_ttestemp          ttestemp%rowtype;

    v_score             ttestrcr2.score%type;
    v_qtyans            ttestrcr2.qtyans%type;
    v_typetest           ttestemp.typetest%type;
    v_typtest           ttestemp.typtest%type;

    cursor c_ttestempd is
        select *
          from ttestempd
         where codempid = v_codempid
           and codexam = v_codexam
           and dtetest = v_dtetest;
    cursor c_tvquest is
        select *
          from tvquest
         where codexam  = v_codexam;
  begin
    obj_row         :=  json_object_t();
    obj_tableEx1    :=  json_object_t();
    obj_tableEx2    :=  json_object_t();
    obj_tableEx3    :=  json_object_t();
    obj_tableEx4    :=  json_object_t();
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
        v_dtetest           := to_date(hcm_util.get_string_t(param_json_row,'dtetest'),'dd/mm/yyyy');
        v_codexam           := hcm_util.get_string_t(param_json_row,'codexam');
        v_typetest           := hcm_util.get_string_t(param_json_row,'typetest');
        v_typtest           := hcm_util.get_string_t(param_json_row,'typtest');

        begin
            select *
              into v_ttestemp
              from ttestemp
             where codempid = v_codempid
               and dtetest = v_dtetest
               and codexam = v_codexam
               and typetest = v_typetest
               and typtest = v_typtest;
        exception when others then
            null;
        end;

        if v_ttestemp.flgtest = 'G' then
            if v_ttestemp.typtest = '1' then
                begin
                    insert into ttestrcr1 (codcomp,numreq,codpos,numappl,codexam,
                                           dtetest,qtyscore,score,
                                           codempidc,dtecheck, statest,
                                           dtecreate,codcreate,dteupd,coduser)
                    values (v_ttestemp.codcompl,v_ttestemp.numreql,v_ttestemp.codposl,v_ttestemp.numappl,v_ttestemp.codexam,
                            v_ttestemp.dtetest,v_ttestemp.qtyscore,v_ttestemp.score,
                            v_ttestemp.codempidc,v_ttestemp.dtecheck,v_ttestemp.statest,
                            sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update ttestrcr1
                       set dtetest = v_ttestemp.dtetest,
                           qtyscore = v_ttestemp.qtyscore,
                           score = v_ttestemp.score,
                           codempidc = v_ttestemp.codempidc,
                           dtecheck = v_ttestemp.dtecheck,
                           statest = v_ttestemp.statest,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codcomp = v_ttestemp.codcompl
                       and numreq = v_ttestemp.numreql
                       and codpos = v_ttestemp.codposl
                       and numappl = v_ttestemp.numappl
                       and codexam = v_ttestemp.codexam;
                end;
                obj_data_child := json_object_t();
                obj_data_child.put('codcomp',v_ttestemp.codcompl);
                obj_data_child.put('numreq',v_ttestemp.numreql);
                obj_data_child.put('codpos',v_ttestemp.codposl);
                obj_data_child.put('numappl',v_ttestemp.numappl);
                obj_data_child.put('codexam',v_ttestemp.codexam);
                obj_data_child.put('dtetest',to_char(v_ttestemp.dtetest,'dd/mm/yyyy'));
                obj_data_child.put('qtyscore',v_ttestemp.qtyscore);
                obj_data_child.put('score',v_ttestemp.score);
                obj_data_child.put('codempidc',v_ttestemp.codempidc);
                obj_data_child.put('dtecheck',to_char(v_ttestemp.dtecheck,'dd/mm/yyyy'));
                obj_data_child.put('statest',get_tlistval_name('STATEST', v_ttestemp.statest, global_v_lang));
                obj_tableEx1.put(to_char(v_row_tableEx1),obj_data_child);
                v_row_tableEx1 := v_row_tableEx1 + 1;

                for r1 in c_tvquest loop
                    begin
                        select count(numques)
                          into v_qtyans
                          from ttestempd
                         where codempid = v_codempid
                           and dtetest = v_dtetest
                           and codexam = v_codexam
                           and codquest = r1.codquest
                           and (answer is not null or
                                numans is not null)
                            and typtest = v_typtest
                            and typetest = v_typetest;
                    exception when others then
                        v_qtyans := 0;
                    end;


                    begin
                    select sum(nvl(score,0))
                      into v_score
                      from ttestempd
                     where codempid = v_codempid
                       and dtetest = v_dtetest
                       and codexam = v_codexam
                       and codquest = r1.codquest
                       and typtest = v_typtest
                       and typetest = v_typetest;
                    exception when others then
                        v_score := 0;
                    end;

                    begin
                        insert into ttestrcr2 (numappl,codexam,dtetest,codquest,
                                               qtyques,qtyans,qtyscore,score,
                                               dtecreate,codcreate,dteupd,coduser)
                        values (v_ttestemp.numappl,v_ttestemp.codexam,v_ttestemp.dtetest,r1.codquest,
                                r1.qtyexam,v_qtyans,r1.qtyscore,v_score,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        update ttestrcr2
                           set qtyques = r1.qtyexam,
                               qtyans = v_qtyans,
                               qtyscore = r1.qtyscore,
                               score = v_score,
                               dteupd = sysdate,
                               coduser = global_v_coduser
                         where numappl = v_ttestemp.numappl
                           and codexam = v_ttestemp.codexam
                           and dtetest = v_ttestemp.dtetest
                           and codquest = r1.codquest;
                    end;

                    obj_data_child := json_object_t();
                    obj_data_child.put('numappl',v_ttestemp.numappl);
                    obj_data_child.put('codexam',v_ttestemp.codexam);
                    obj_data_child.put('dtetest',to_char(v_ttestemp.dtetest,'dd/mm/yyyy'));
                    obj_data_child.put('codquest',r1.codquest);
                    obj_data_child.put('qtyques',r1.qtyexam);
                    obj_data_child.put('qtyans',v_qtyans);
                    obj_data_child.put('qtyscore',r1.qtyscore);
                    obj_data_child.put('score',v_score);
                    obj_tableEx2.put(to_char(v_row_tableEx2),obj_data_child);
                    v_row_tableEx2 := v_row_tableEx2 + 1;
                end loop;
            elsif v_ttestemp.typtest in ('2','5') then
                begin
                    insert into ttesttrr1 (dteyear,codcompy,codcours,numclseq,
                                           typtest,codempid,codexam,dtetest,
                                           qtyscore,score,codempidc,dtecheck,statest,
                                           dtecreate,codcreate,dteupd,coduser)
                    values (v_ttestemp.dteyear,hcm_util.get_codcomp_level(v_ttestemp.codcomp,1),v_ttestemp.codcours,v_ttestemp.numclseq,
                            v_ttestemp.typtest,v_ttestemp.codempid,v_ttestemp.codexam,v_ttestemp.dtetest,
                            v_ttestemp.qtyscore,v_ttestemp.score,v_ttestemp.codempidc,v_ttestemp.dtecheck,v_ttestemp.statest,
                            sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update ttesttrr1
                       set qtyscore = v_ttestemp.qtyscore,
                           score = v_ttestemp.score,
                           codempidc = v_ttestemp.codempidc,
                           dtecheck = v_ttestemp.dtecheck,
                           statest = v_ttestemp.statest,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where dteyear = v_ttestemp.dteyear
                       and codcompy = hcm_util.get_codcomp_level(v_ttestemp.codcomp,1)
                       and codcours = v_ttestemp.codcours
                       and numclseq = v_ttestemp.numclseq
                       and typtest = v_ttestemp.typtest
                       and codempid = v_ttestemp.codempid
                       and codexam = v_ttestemp.codexam
                       and dtetest = v_ttestemp.dtetest;
                end;

                obj_data_child := json_object_t();
                obj_data_child.put('dteyear',v_ttestemp.dteyear);
                obj_data_child.put('codcompy',hcm_util.get_codcomp_level(v_ttestemp.codcomp,1));
                obj_data_child.put('codcours',v_ttestemp.codcours);
                obj_data_child.put('numclseq',v_ttestemp.numclseq);
                obj_data_child.put('typtest',v_ttestemp.typtest);
                obj_data_child.put('codempid',v_ttestemp.codempid);
                obj_data_child.put('codexam',v_ttestemp.codexam);
                obj_data_child.put('dtetest',to_char(v_ttestemp.dtetest,'dd/mm/yyyy'));
                obj_data_child.put('qtyscore',v_ttestemp.qtyscore);
                obj_data_child.put('score',v_ttestemp.score);
                obj_data_child.put('codempidc',v_ttestemp.codempidc);
                obj_data_child.put('dtecheck',to_char(v_ttestemp.dtecheck,'dd/mm/yyyy'));
                obj_data_child.put('statest',get_tlistval_name('STATEST', v_ttestemp.statest, global_v_lang));
                obj_tableEx3.put(to_char(v_row_tableEx3),obj_data_child);
                v_row_tableEx3 := v_row_tableEx3 + 1;

            elsif v_ttestemp.typtest in ('3','4') then
                begin
                    insert into ttestotr1 (codcomp,codempid,codexam,dtetest,
                                           qtyscore,score,statest,
                                           dtecreate,codcreate,dteupd,coduser)
                    values (v_ttestemp.codcomp,v_ttestemp.codempid,v_ttestemp.codexam,v_ttestemp.dtetest,
                            v_ttestemp.qtyscore,v_ttestemp.score,v_ttestemp.statest,
                            sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update ttestotr1
                       set qtyscore = v_ttestemp.qtyscore,
                           score = v_ttestemp.score,
                           statest = v_ttestemp.statest,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codcomp = v_ttestemp.codcomp
                       and codempid = v_ttestemp.codempid
                       and codexam = v_ttestemp.codexam
                       and dtetest = v_ttestemp.dtetest;
                end;

                obj_data_child := json_object_t();
                obj_data_child.put('codcomp',v_ttestemp.codcomp);
                obj_data_child.put('codempid',v_ttestemp.codempid);
                obj_data_child.put('codexam',v_ttestemp.codexam);
                obj_data_child.put('dtetest',to_char(v_ttestemp.dtetest,'dd/mm/yyyy'));
                obj_data_child.put('qtyscore',v_ttestemp.qtyscore);
                obj_data_child.put('score',v_ttestemp.score);
                obj_data_child.put('statest',get_tlistval_name('STATEST', v_ttestemp.statest, global_v_lang));
                obj_tableEx4.put(to_char(v_row_tableEx4),obj_data_child);
                v_row_tableEx4 := v_row_tableEx4 + 1;
            end if;
        end if;

    end loop;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    obj_main_data := json_object_t();
    obj_main_data.put('coderror','200');
    obj_main_data.put('response',replace(param_msg_error,'@#$%201',null));
    obj_main_data.put('file1',obj_tableEx1);
    obj_main_data.put('file2',obj_tableEx2);
    obj_main_data.put('file3',obj_tableEx3);
    obj_main_data.put('file4',obj_tableEx4);
    json_str_output := obj_main_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_export;

  procedure post_export (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_export(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HREL51E;

/
