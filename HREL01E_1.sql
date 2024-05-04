--------------------------------------------------------
--  DDL for Package Body HREL01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL01E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_codcate           := hcm_util.get_string_t(json_obj,'p_codcate');
    p_codsubject        := hcm_util.get_string_t(json_obj,'p_codsubject');
    p_chaptno           := hcm_util.get_string_t(json_obj,'p_chaptno');

    p_coursDetail       := hcm_util.get_json_t(json_obj,'coursDetail');
    p_subjectDetail     := hcm_util.get_json_t(json_obj,'subjectDetail');
    p_lessonDetail      := hcm_util.get_json_t(json_obj,'lessonDetail');

    p_tcourse           := hcm_util.get_json_t(p_coursDetail,'tcourse');
    p_tcoursub          := hcm_util.get_json_t(p_coursDetail,'tcoursub');

    p_tvchapter         := hcm_util.get_json_t(json_obj,'tvchapter');
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcours is null and p_codcate is null then
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
    if p_codcate is not null then
      begin
        select count(*) into v_chkExist
          from tcodcate
         where codcodec = p_codcate;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATE');
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_qtysubj           number := 0;
    v_flgpreteset       tvcourse.flgpreteset%type;
    v_flgposttest       tvcourse.flgposttest%type;
    v_typcours          tvcourse.typcours%type;
    v_chk_learn         varchar2(1 char) := 'N';

    cursor c1 is
      select codcate, codcours,flgelern  --typcours
        from tcourse
       where codcours = nvl(p_codcours, codcours)
         and codcate = nvl(p_codcate, codcate)
--         and flgelern = 'Y'
       order by codcate,codcours;
       
  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_count     := v_count + 1;
      v_chk_learn := 'N';
      obj_data.put('coderror', '200');
      obj_data.put('codcate', r1.codcate);
      obj_data.put('desc_codcate', get_tcodec_name('TCODCATE',r1.codcate, global_v_lang));
      obj_data.put('codcours', r1.codcours);
      obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
      
      begin
        select count(*) into v_qtysubj
          from tcoursub
         where codcours = r1.codcours;
      end;
      
      obj_data.put('qtysubj', v_qtysubj);
      --
      begin
        select flgpreteset, flgposttest, decode(typcours,'1','Y','2','O',typcours) 
          into v_flgpreteset, v_flgposttest, v_typcours
          from tvcourse
         where codcours = r1.codcours;
      exception when no_data_found then
        v_flgpreteset := null;
        v_flgposttest := null;
        v_typcours := null;
      end;

      obj_data.put('flgpretest', v_flgpreteset);
      obj_data.put('desc_flgpretest', get_tlistval_name('FLGPRORT' , v_flgpreteset, global_v_lang));
      obj_data.put('flgposttest', v_flgposttest);
      obj_data.put('desc_flgposttest', get_tlistval_name('FLGPRORT' , v_flgposttest, global_v_lang));

/* --#4628 || 27/05/2022
      if v_typcours = '1' then
        v_typcours := 'Y';
      elsif v_typcours = '2' then
        v_typcours := 'O';
      end if;
*/ --#4628 || 27/05/2022

      if v_typcours is not null then
        obj_data.put('typcours', v_typcours);
        obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , v_typcours, global_v_lang));
      else
        begin
          select decode(typcours,'1','Y','2','O',typcours) 
            into v_typcours
            from tcourse
           where codcours = p_codcours;
        exception when no_data_found then
          v_typcours := null;
        end;
--<< #4628 || 27/05/2022        
        if v_typcours is not null then
          obj_data.put('typcours', v_typcours);
          obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , v_typcours , global_v_lang));
        else
          obj_data.put('typcours', '');
          obj_data.put('desc_typcours', '');
        end if;
/*        
        if v_typcours = '1' then
          v_typcours := 'Y';
        elsif v_typcours = '2' then
          v_typcours := 'O';
        end if;

        if v_typcours = '1' then
          obj_data.put('typcours', v_typcours);
          obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , 'Y', global_v_lang));
        elsif v_typcours = '2' then
          obj_data.put('typcours', v_typcours);
          obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , 'O', global_v_lang));
        else
          obj_data.put('typcours', '');
          obj_data.put('desc_typcours', '');
        end if;
*/ -->> #4628 || 27/05/2022
      end if;
      
      begin
        select 'Y'
          into v_chk_learn
          from tlrncourse
         where codcours     = r1.codcours
           and stalearn in ('A')                                                --Peerasak || 02/08/22 || Issue#4617
           and rownum       = 1;                        
      exception when no_data_found then
        v_chk_learn   := 'N';
      end;
      
      obj_data.put('chk_learn',v_chk_learn);
      if v_chk_learn = 'Y' then
        obj_data.put('error_msg','HR1450 '||get_terrorm_name('HR1450',global_v_lang));
      end if;
      --
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    
    if v_count = 0 then
      param_msg_error := get_error_msg_php('EL0007', global_v_lang);
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
  procedure gen_detail_tcourse(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_data_row        json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_qtysubj           number := 0;
    v_flgpreteset       tvcourse.flgpreteset%type;
    v_flgposttest       tvcourse.flgposttest%type;
    v_typcours          tvcourse.typcours%type;
    v_chkExist          varchar2(2 char);
    v_tvcourse          tvcourse%rowtype;
    v_tcourse           tcourse%rowtype;
    v_qtychapt          tvsubject.qtychapt%type;
    v_flglearn          tvsubject.flglearn%type;
    v_flgexam           tvsubject.flgexam%type;
    v_flgelern          tcourse.flgelern%type;
    
    cursor c1 is
      select *
        from tcoursub
       where codcours = p_codcours
       order by codsubj asc;
  begin
    begin
      select * into v_tvcourse
        from tvcourse
       where codcours = p_codcours;
      v_chkExist := 'Y';
    exception when no_data_found then
      v_chkExist := 'N';
      v_tvcourse := null;
    end;

    obj_data := json_object_t();

    if v_chkExist = 'Y' then
/* --<< #4628 || 27/05/2022     
      if v_tvcourse.typcours = '1' then
        v_typcours := 'Y';
      elsif v_tvcourse.typcours = '2' then
        v_typcours := 'O';
      end if;
*/ -->> #4628 || 27/05/2022  
      obj_data.put('coderror', '200');
      obj_data.put('codcours', v_tvcourse.codcours);
      obj_data.put('codcate', v_tvcourse.codcate);
      obj_data.put('desc_codcate', v_tvcourse.codcate || ' - ' ||get_tcodec_name('TCODCATE', v_tvcourse.codcate, global_v_lang));
      obj_data.put('typcours', nvl(v_tvcourse.typcours,'Y'));
      obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , nvl(v_tvcourse.typcours,'Y'), global_v_lang));
      obj_data.put('descours', v_tvcourse.descours);
      obj_data.put('filemedia', v_tvcourse.filemedia);
      obj_data.put('flgdashboard', v_tvcourse.flgdashboard);
      obj_data.put('flgdata', v_tvcourse.flgdata);
      obj_data.put('flgpreteset', v_tvcourse.flgpreteset);
      obj_data.put('flgposttest', v_tvcourse.flgposttest);
      obj_data.put('codexampr', v_tvcourse.codexampr);
      obj_data.put('codcatpre', v_tvcourse.codcatpre);
      obj_data.put('codexampo', v_tvcourse.codexampo);
      obj_data.put('codcatpo', v_tvcourse.codcatpo);
      obj_data.put('staresult', v_tvcourse.staresult);
      
      begin
        select count(*) into v_count
          from tlrncourse
         where codcours = v_tvcourse.codcours
           and stalearn in ('A');                                               --Peerasak || 02/08/22 || Issue#4617
--           and stalearn in ('A','C');
      end;
      
      if v_count > 0 then
        obj_data.put('flgEdit', 'N');
        obj_data.put('error_msg','HR1450 '||get_terrorm_name('HR1450',global_v_lang));
      else
        obj_data.put('flgEdit', 'Y');
      end if;
    else
      begin
        select * into v_tcourse
          from tcourse
         where codcours = p_codcours;
        v_chkExist := 'Y';
      exception when no_data_found then
        v_chkExist := 'N';
        v_tvcourse := null;
      end;
      
      begin
        select decode(typcours,'1','Y','2','O',typcours) 
        into v_typcours
        from tcourse
        where codcours = p_codcours;
      exception when no_data_found then
        v_typcours := null;
      end;
      
/*      --<< #4628 || 27/05/2022
      if v_typcours = '1' then
        v_typcours := 'Y';
      elsif v_typcours = '2' then
        v_typcours := 'O';
      end if;
      
*/      -->> #4628 || 27/05/2022
      obj_data.put('coderror', '200');
      obj_data.put('codcours', v_tcourse.codcours);
      obj_data.put('codcate', v_tcourse.codcate);
      obj_data.put('desc_codcate', v_tcourse.codcate || ' - ' ||get_tcodec_name('TCODCATE', v_tcourse.codcate, global_v_lang));
      obj_data.put('typcours', v_tcourse.typcours);
      obj_data.put('desc_typcours', get_tlistval_name('TYPCOURS2' , v_typcours, global_v_lang));
      obj_data.put('descours', '');
      obj_data.put('filemedia', '');
      obj_data.put('flgdashboard', '');
      obj_data.put('flgdata', '');
      obj_data.put('flgpreteset', 'N');
      obj_data.put('codexampr', '');
      obj_data.put('codcatpre', '');
      obj_data.put('flgposttest', 'N');
      obj_data.put('codexampo', '');
      obj_data.put('codcatpo', '');
      obj_data.put('staresult', '');
      obj_data.put('flgEdit', 'Y');
    end if;
    
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data_row   := json_object_t();
      v_row    := v_row + 1;
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codcours', r1.codcours);
      obj_data_row.put('codsubj', r1.codsubj);
      obj_data_row.put('desc_codsubj', get_tsubject_name(r1.codsubj, global_v_lang));
      begin
        select qtychapt, flglearn, flgexam into v_qtychapt, v_flglearn, v_flgexam
          from tvsubject
         where codcours = r1.codcours
           and codsubj = r1.codsubj;
      exception when no_data_found then
        v_qtychapt := null;
        v_flglearn := null;
        v_flgexam := null;
      end;
      obj_data_row.put('qtychapt', v_qtychapt);
      obj_data_row.put('flglearn', v_flglearn);
      obj_data_row.put('desc_flglearn', get_tlistval_name('FLGLEARN' , v_flglearn, global_v_lang));
      obj_data_row.put('flgexam', v_flgexam);
      obj_data_row.put('desc_flgexam', get_tlistval_name('FLGEXAM' , v_flgexam, global_v_lang));
      --
      obj_row.put(to_char(v_row-1),obj_data_row);
    end loop;
    obj_data.put('table', obj_row);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail_tcourse (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tcourse(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_subject(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_data_row        json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_qtysubj           number := 0;
    v_flgpreteset       tvcourse.flgpreteset%type;
    v_flgposttest       tvcourse.flgposttest%type;
    v_typcours          tvcourse.typcours%type;
    v_chkExist          varchar2(2 char);
    v_tvsubject         tvsubject%rowtype;
    v_tcourse           tcourse%rowtype;

    cursor c1 is
      select CHAPTNO,QTYTRAINM,FLGEXAM,
             decode(global_v_lang,'101',NAMCHAPTE
                                 ,'102',NAMCHAPTt
                                 ,'103',NAMCHAPT3
                                 ,'104',NAMCHAPT4
                                 ,'105',NAMCHAPT5) as namchapt

        from tvchapter
       where codcours = p_codcours
         and codsubj = p_codsubject
       order by chaptno asc;
  begin
    begin
      select * into v_tvsubject
        from tvsubject
       where codcours = p_codcours
         and codsubj = p_codsubject;
      v_chkExist := 'Y';
    exception when no_data_found then
      v_chkExist := 'N';
      v_tvsubject := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcours', p_codcours);
    obj_data.put('codsubj', p_codsubject);
    obj_data.put('dessubj', v_tvsubject.dessubj);
    obj_data.put('flglearn', v_tvsubject.flglearn);
    obj_data.put('flgexam', v_tvsubject.flgexam);
    obj_data.put('codexam', v_tvsubject.codexam);
    obj_data.put('codcatexm', v_tvsubject.codcatexm);
    obj_data.put('staexam', v_tvsubject.staexam);

    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data_row   := json_object_t();
      v_row    := v_row + 1;
      obj_data_row.put('coderror', '200');
      obj_data_row.put('chaptno', r1.chaptno);
      obj_data_row.put('namchapt', r1.namchapt);
      obj_data_row.put('qtytrainm', hcm_util.convert_minute_to_hour (r1.qtytrainm));
      obj_data_row.put('flgexam', r1.flgexam);
      obj_data_row.put('desc_flgexam', get_tlistval_name('FLGEXAM2', r1.flgexam, global_v_lang));
      --
      obj_row.put(to_char(v_row-1),obj_data_row);
    end loop;
    obj_data.put('table', obj_row);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail_subject (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_subject(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_lesson_detail(json_str_input in clob,json_str_output out clob) is
    json_input          json_object_t;
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_data_row        json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_qtysubj           number := 0;
    v_flgpreteset       tvcourse.flgpreteset%type;
    v_flgposttest       tvcourse.flgposttest%type;
    v_typcours          tvcourse.typcours%type;
    v_namchapt          tvchapter.namchapte%type;
    v_chkExist          varchar2(2 char);
    v_tvchapter         tvchapter%rowtype;
    v_flglearn          tvsubject.flglearn%type;
    v_flgexam           tvsubject.flgexam%type;
  begin
    json_input    := json_object_t(json_str_input);
    v_flglearn    := hcm_util.get_string_t(json_input,'p_flglearn');
    v_flgexam     := hcm_util.get_string_t(json_input,'p_flgexam');

    begin
      select * into v_tvchapter
        from tvchapter
       where codcours = p_codcours
         and codsubj = p_codsubject
         and chaptno = p_chaptno;
    exception when no_data_found then
      v_tvchapter := null;
    end;
    begin
      select decode(global_v_lang,'101',NAMCHAPTE
                                 ,'102',NAMCHAPTt
                                 ,'103',NAMCHAPT3
                                 ,'104',NAMCHAPT4
                                 ,'105',NAMCHAPT5) as namchapt
        into v_namchapt
        from tvchapter
       where codcours = p_codcours
         and codsubj = p_codsubject
         and chaptno = p_chaptno;
    exception when no_data_found then
      v_namchapt := '';
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcours', p_codcours);
    obj_data.put('codsubj', p_codsubject);
    obj_data.put('chaptno', p_chaptno);
    obj_data.put('namchapt', v_namchapt );
    obj_data.put('namchapte', v_tvchapter.namchapte );
    obj_data.put('namchaptt', v_tvchapter.namchaptt );
    obj_data.put('namchapt3', v_tvchapter.namchapt3 );
    obj_data.put('namchapt4', v_tvchapter.namchapt4 );
    obj_data.put('namchapt5', v_tvchapter.namchapt5 );
    obj_data.put('deschaptt', v_tvchapter.deschaptt );
    obj_data.put('filemedia', v_tvchapter.filemedia );
    obj_data.put('namemedia', v_tvchapter.namemedia );
    obj_data.put('namelink', v_tvchapter.namelink );
    obj_data.put('desclink', v_tvchapter.desclink );
    obj_data.put('filedoc', v_tvchapter.filedoc );
    obj_data.put('namefiled', v_tvchapter.namefiled );
    if v_flgexam in ('1','3') then
      obj_data.put('flgexam', '2' );
      obj_data.put('codexam', '' );
      obj_data.put('codcatexm', '' );
      obj_data.put('staexam', 'N' );
    else
      if v_flglearn = '1' then
        obj_data.put('flgexam', '1' );
      else
        obj_data.put('flgexam', v_tvchapter.flgexam );
      end if;
      obj_data.put('codexam', v_tvchapter.codexam );
      obj_data.put('codcatexm', v_tvchapter.codcatexm );
      obj_data.put('staexam', v_tvchapter.staexam );
    end if;
    obj_data.put('qtytrainm', hcm_util.convert_minute_to_hour(v_tvchapter.qtytrainm));
    obj_data.put('qtytrmin', hcm_util.convert_minute_to_hour(v_tvchapter.qtytrmin));

    begin
      select count(*) into v_count
        from tlrnchap
       where codcours = p_codcours
         and codsubj = p_codsubject
         and chaptno = p_chaptno
         and stalearn = 'A';
    end;
    if v_count > 0 then
      obj_data.put('flgLearnStatus', 'Y' );
    else
      obj_data.put('flgLearnStatus', 'N' );
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_lesson_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_lesson_detail(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save_detail is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
    v_codcours    tvcourse.codcours%type;
    v_codcate     tvcourse.codcate%type;
    v_descours    tvcourse.descours%type;
    v_filemedia   tvcourse.filemedia%type;
    v_typcours		tvcourse.typcours%type;
    v_flgdashboard	tvcourse.flgdashboard%type;
    v_flgdata		    tvcourse.flgdata%type;
    v_flgpreteset		tvcourse.flgpreteset%type;
    v_flgposttest		tvcourse.flgposttest%type;
    v_codexampr		tvcourse.codexampr%type;
    v_codcatpre		tvcourse.codcatpre%type;
    v_codexampo		tvcourse.codexampo%type;
    v_codcatpo		tvcourse.codcatpo%type;
    v_staresult		tvcourse.staresult%type;
  begin
    v_descours      := hcm_util.get_string_t(p_tcourse,'descours');
    v_filemedia     := hcm_util.get_string_t(p_tcourse,'filemedia');
    v_flgpreteset   := hcm_util.get_string_t(p_tcourse,'flgpreteset');
    v_flgposttest   := hcm_util.get_string_t(p_tcourse,'flgposttest');
    v_descours      := hcm_util.get_string_t(p_tcourse,'descours');
    v_codexampr	    := hcm_util.get_string_t(p_tcourse,'codexampr');
    v_codcatpre	    := hcm_util.get_string_t(p_tcourse,'codcatpre');
    v_codexampo	    := hcm_util.get_string_t(p_tcourse,'codexampo');
    v_codcatpo	    := hcm_util.get_string_t(p_tcourse,'codcatpo');

    if v_descours is null or v_filemedia is null or v_flgpreteset is null or v_flgposttest is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if v_flgpreteset = 'Y' then
      if v_codexampr is null and v_codcatpre is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if v_codexampr is not null then
        begin
          select count(*) into v_chkExist
            from tvtest
           where codexam = v_codexampr;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
          return;
        end if;
      end if;
      if v_codcatpre is not null then
        begin
          select count(*) into v_chkExist
            from tcodcatexm
           where codcodec = v_codcatpre;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
          return;
        end if;
      end if;
    end if;
    if v_flgposttest = 'Y' then
      if v_codexampo is null and v_codcatpo is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if v_codexampo is not null then
        begin
          select count(*) into v_chkExist
            from tvtest
           where codexam = v_codexampo;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
          return;
        end if;
      end if;
      if v_codcatpo is not null then
        begin
          select count(*) into v_chkExist
            from tcodcatexm
           where codcodec = v_codcatpo;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
          return;
        end if;
      end if;
    end if;
  end;

  procedure post_save_detail(json_str_input in clob,json_str_output out clob) as
    json_row        json_object_t;
    params_tcoursub json_object_t;
    param_json_row  json_object_t;
    v_chkExist      number := 0;
    -- course
    v_codcours      tvcourse.codcours%type;
    v_codcate       tvcourse.codcate%type;
    v_descours      tvcourse.descours%type;
    v_filemedia     tvcourse.filemedia%type;
    v_typcours		tvcourse.typcours%type;
    v_flgdashboard	tvcourse.flgdashboard%type;
    v_flgdata		tvcourse.flgdata%type;
    v_flgpreteset	tvcourse.flgpreteset%type;
    v_flgposttest	tvcourse.flgposttest%type;
    v_codexampr		tvcourse.codexampr%type;
    v_codcatpre		tvcourse.codcatpre%type;
    v_codexampo		tvcourse.codexampo%type;
    v_codcatpo		tvcourse.codcatpo%type;
    v_staresult		tvcourse.staresult%type;
    -- subject
    v_codsubj	    tvsubject.codsubj%type;
    v_dessubj	    tvsubject.dessubj%type;
    v_flglearn	    tvsubject.flglearn%type;
    v_flgexam	    tvsubject.flgexam%type;
    v_codexam	    tvsubject.codexam%type;
    v_codcatexm	    tvsubject.codcatexm%type;
    v_staexam	    tvsubject.staexam%type;
    -- chapter
    v_chaptno		tvchapter.chaptno%type;
    v_namchapt		tvchapter.namchapte%type;
    v_desc_flgexam	varchar2(500 char);
    v_amountSubj    number := 0;
    v_namchapte		tvchapter.namchapte%type;
    v_namchaptt		tvchapter.namchaptt%type;
    v_namchapt3		tvchapter.namchapt3%type;
    v_namchapt4		tvchapter.namchapt4%type;
    v_namchapt5		tvchapter.namchapt5%type;
    v_deschaptt		tvchapter.deschaptt%type;
    v_namemedia		tvchapter.namemedia%type;
    v_namelink		tvchapter.namelink%type;
    v_desclink		tvchapter.desclink%type;
    v_filedoc		tvchapter.filedoc%type;
    v_namefiled		tvchapter.namefiled%type;
    v_qtytrainm		varchar2(100 char);
    v_qtytrmin		varchar2(100 char);
    --
    v_flg           varchar2(10 char);
    v2_qtysubj      number;
    v2_qtychapt     number;

  begin
    initial_value(json_str_input);
    check_save_detail;

    if param_msg_error is null then

      v_codcours			:= hcm_util.get_string_t(p_tcourse,'codcours');
      v_codcate			    := hcm_util.get_string_t(p_tcourse,'codcate');
      v_descours			:= hcm_util.get_string_t(p_tcourse,'descours');
      v_filemedia			:= hcm_util.get_string_t(p_tcourse,'filemedia');
      v_typcours			:= hcm_util.get_string_t(p_tcourse,'typcours');
      v_flgdashboard	    := nvl(hcm_util.get_string_t(p_tcourse,'flgdashboard'),'N');
      v_flgdata			    := nvl(hcm_util.get_string_t(p_tcourse,'flgdata'),'N');
      v_flgpreteset		    := hcm_util.get_string_t(p_tcourse,'flgpreteset');
      v_flgposttest		    := hcm_util.get_string_t(p_tcourse,'flgposttest');
      v_codexampr			:= hcm_util.get_string_t(p_tcourse,'codexampr');
      v_codcatpre			:= hcm_util.get_string_t(p_tcourse,'codcatpre');
      v_codexampo			:= hcm_util.get_string_t(p_tcourse,'codexampo');
      v_codcatpo			:= hcm_util.get_string_t(p_tcourse,'codcatpo');
      v_staresult			:= hcm_util.get_string_t(p_tcourse,'staresult');

      begin
        select count(*) into v_chkExist
          from tvcourse
         where codcours = v_codcours;
      exception when others then null;
      end;

      v2_qtysubj:=null;  v2_qtychapt:=null;
      begin
      select count(distinct codsubj),sum(qtychapt) into v2_qtysubj , v2_qtychapt
            from tvsubject
            where codcours = v_codcours ;
      exception when others then null;
      end;
      if v_chkExist = 0 then
        insert into tvcourse(codcours,codcate,codcatpre,codexampr,codcatpo,codexampo,
                             flgpreteset,flgposttest,filemedia,staresult,typcours,
                             descours,flgdata,flgdashboard,/*flgrelrn,flgshwans,*/codcreate,coduser,
                             qtysubj,qtychapt)
        values(v_codcours,v_codcate,v_codcatpre,v_codexampr,v_codcatpo,v_codexampo,
               v_flgpreteset,v_flgposttest,v_filemedia,v_staresult,decode(v_typcours,'1','Y','2','O',v_typcours),
               v_descours,v_flgdata,v_flgdashboard,/*v_flgrelrn,v_flgshwans,*/global_v_coduser,global_v_coduser,
               v2_qtysubj , v2_qtychapt);
      else
        update tvcourse
          set codcate = v_codcate,
              codcatpre = v_codcatpre,
              codexampr = v_codexampr,
              codcatpo = v_codcatpo,
              codexampo = v_codexampo,
              flgpreteset = v_flgpreteset,
              flgposttest = v_flgposttest,
              filemedia = v_filemedia,
              staresult = v_staresult,
              typcours = decode(v_typcours,'1','Y','2','O',v_typcours),
              descours = v_descours,
              flgdata = v_flgdata,
              flgdashboard = v_flgdashboard,
              coduser = global_v_coduser,
              qtysubj  = v2_qtysubj,
              qtychapt = v2_qtychapt
        where codcours = v_codcours;
      end if;

      -- subject
      if p_subjectDetail.get_size <> 0 then
        p_tcoursub    := hcm_util.get_json_t(p_subjectDetail,'tcoursub');
        p_tvchapter   := hcm_util.get_json_t(p_subjectDetail,'tvchapter');
        v_codcours	  := hcm_util.get_string_t(p_tcoursub,'codcours');
        v_codsubj	    := hcm_util.get_string_t(p_tcoursub,'codsubj');
        v_dessubj	    := hcm_util.get_string_t(p_tcoursub,'dessubj');
        v_flglearn	  := hcm_util.get_string_t(p_tcoursub,'flglearn');
        v_flgexam	    := hcm_util.get_string_t(p_tcoursub,'flgexam');
        v_codexam	    := hcm_util.get_string_t(p_tcoursub,'codexam');
        v_codcatexm	  := hcm_util.get_string_t(p_tcoursub,'codcatexm');
        v_staexam	    := hcm_util.get_string_t(p_tcoursub,'staexam');

        begin
          select count(*) into v_chkExist
            from tvsubject
           where codcours = v_codcours
           and codsubj = v_codsubj;
        exception when others then null;
        end;
        if v_chkExist = 0 then
          insert into tvsubject(codcours,codsubj,flglearn,flgexam,
                                codexam,codcatexm,staexam,dessubj,codcreate,coduser)
                values(v_codcours,v_codsubj,v_flglearn,v_flgexam,
                       v_codexam,v_codcatexm,v_staexam,v_dessubj,global_v_coduser,global_v_coduser);
        else
          update tvsubject
            set flglearn = v_flglearn,
                flgexam = v_flgexam,
                codexam = v_codexam,
                codcatexm = v_codcatexm,
                staexam = v_staexam,
                dessubj = v_dessubj,
                coduser = global_v_coduser
          where codcours = v_codcours
          and codsubj = v_codsubj;

          if v_flgexam in ('1','3') then ----no exam     
            begin
              update tvchapter
                  set flgexam   = '2',
                      codexam   = v_codexam,
                      codcatexm = v_codcatexm,
                      staexam   = v_staexam,
                      coduser   = global_v_coduser
                where codcours  = v_codcours
                and   codsubj   = v_codsubj;
            exception when others then
              null;
            end;
          elsif v_flgexam = '2' then
            begin
              update tvchapter
                set flgexam   = '1',
                    coduser   = global_v_coduser
              where codcours  = v_codcours
              and   codsubj   = v_codsubj;
            exception when others then
              null;
            end;
          end if;
        end if;

        for i in 0..p_tvchapter.get_size-1 loop
          param_json_row        := hcm_util.get_json_t(p_tvchapter,to_char(i));
          v_flg     		    := hcm_util.get_string_t(param_json_row, 'flg');
          v_chaptno	            := hcm_util.get_string_t(param_json_row, 'chaptno');
          v_namchapt	        := hcm_util.get_string_t(param_json_row, 'namchapt');
          v_qtytrainm	        := hcm_util.get_string_t(param_json_row, 'qtytrainm');
          v_flgexam	            := hcm_util.get_string_t(param_json_row, 'flgexam');
          v_desc_flgexam	    := hcm_util.get_string_t(param_json_row, 'desc_flgexam');

          if v_flg = 'delete' then
            begin
              delete tvchapter
              where codcours = v_codcours
              and codsubj = v_codsubj
              and chaptno = v_chaptno;
            end;
          end if;
        end loop;
        begin
          select count(*) into v_amountSubj
            from tvchapter
           where codcours = v_codcours
             and codsubj = v_codsubj;
        end;
        begin
          update tvsubject
              set qtychapt = v_amountSubj
            where codcours = v_codcours
            and codsubj = v_codsubj;
        end;
--<< #4661 || 11/05/2022
        v2_qtysubj := null;  v2_qtychapt := null;
        begin
            select count(distinct codsubj),sum(qtychapt) into v2_qtysubj , v2_qtychapt
            from tvsubject
            where codcours = v_codcours ;

--insert_ttemprpt('AB2','AB2','Point1','v2_qtysubj='||v2_qtysubj,'v2_qtychapt='||v2_qtychapt,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));

        end;
        begin
            update tvcourse
            set  qtysubj = v2_qtysubj,
                 qtychapt = v2_qtychapt
            where codcours = v_codcours;

--insert_ttemprpt('AB2','AB2','Point2','v2_qtysubj='||v2_qtysubj,'v2_qtychapt='||v2_qtychapt,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));

        end;
--<< #4661 || 11/05/2022
      end if;

      -- chapter
      if p_lessonDetail.get_size <> 0 then

        v_codcours		:= hcm_util.get_string_t(p_lessonDetail,'codcours');
        v_codsubj		:= hcm_util.get_string_t(p_lessonDetail,'codsubj');
        v_chaptno		:= hcm_util.get_string_t(p_lessonDetail,'chaptno');
        v_namchapte		:= hcm_util.get_string_t(p_lessonDetail,'namchapte');
        v_namchaptt		:= hcm_util.get_string_t(p_lessonDetail,'namchaptt');
        v_namchapt3		:= hcm_util.get_string_t(p_lessonDetail,'namchapt3');
        v_namchapt4		:= hcm_util.get_string_t(p_lessonDetail,'namchapt4');
        v_namchapt5		:= hcm_util.get_string_t(p_lessonDetail,'namchapt5');
        v_deschaptt		:= hcm_util.get_string_t(p_lessonDetail,'deschaptt');
        v_filemedia		:= hcm_util.get_string_t(p_lessonDetail,'filemedia');
        v_namemedia		:= hcm_util.get_string_t(p_lessonDetail,'namemedia');
        v_namelink		:= hcm_util.get_string_t(p_lessonDetail,'namelink');
        v_desclink		:= hcm_util.get_string_t(p_lessonDetail,'desclink');
        v_filedoc		:= hcm_util.get_string_t(p_lessonDetail,'filedoc');
        v_namefiled		:= hcm_util.get_string_t(p_lessonDetail,'namefiled');
        v_flgexam		:= hcm_util.get_string_t(p_lessonDetail,'flgexam');
        v_codexam		:= hcm_util.get_string_t(p_lessonDetail,'codexam');
        v_codcatexm		:= hcm_util.get_string_t(p_lessonDetail,'codcatexm');
        v_staexam		:= hcm_util.get_string_t(p_lessonDetail,'staexam');
        v_qtytrainm		:= hcm_util.get_string_t(p_lessonDetail,'qtytrainm');
        v_qtytrmin		:= hcm_util.get_string_t(p_lessonDetail,'qtytrmin');

        if v_chaptno is null then
          begin
            select nvl(max(chaptno),0) into v_chaptno
              from tvchapter
             where codcours = v_codcours
               and codsubj = v_codsubj;
          exception when others then null;
          end;
        end if;
        begin
          select count(*) into v_chkExist
            from tvchapter
           where codcours = v_codcours
             and codsubj = v_codsubj
             and chaptno = v_chaptno;
        exception when others then null;
        end;
        if v_chkExist = 0 then
          insert into tvchapter(codcours, codsubj, chaptno,
                                namchapte, namchaptt, namchapt3, namchapt4, namchapt5,
                                qtytrainm, qtytrmin,
                                flgexam, codexam, codcatexm, staexam,
                                filemedia, namemedia, namelink, deschaptt, desclink, filedoc, namefiled,
                                codcreate, coduser)
                         values(v_codcours, v_codsubj, v_chaptno,
                                v_namchapte, v_namchaptt, v_namchapt3, v_namchapt4, v_namchapt5,
                                hcm_util.convert_hour_to_minute(v_qtytrainm), hcm_util.convert_hour_to_minute(v_qtytrmin),
                                v_flgexam, v_codexam, v_codcatexm, v_staexam,
                                v_filemedia, v_namemedia, v_namelink, v_deschaptt, v_desclink, v_filedoc, v_namefiled,
                                global_v_coduser, global_v_coduser);
        else
          update tvchapter
            set namchapte = v_namchapte,
                namchaptt = v_namchaptt,
                namchapt3 = v_namchapt3,
                namchapt4 = v_namchapt4,
                namchapt5 = v_namchapt5,
                qtytrainm = hcm_util.convert_hour_to_minute(v_qtytrainm),
                qtytrmin = hcm_util.convert_hour_to_minute(v_qtytrmin),
                flgexam = v_flgexam,
                codexam = v_codexam,
                codcatexm = v_codcatexm,
                staexam = v_staexam,
                filemedia = v_filemedia,
                namemedia = v_namemedia,
                namelink = v_namelink,
                deschaptt = v_deschaptt,
                desclink = v_desclink,
                filedoc = v_filedoc,
                namefiled = v_namefiled,
                coduser = global_v_coduser
          where codcours = v_codcours
            and codsubj = v_codsubj
            and chaptno = v_chaptno;
        end if;
        begin
          select count(*) into v_amountSubj
            from tvchapter
           where codcours = v_codcours
             and codsubj = v_codsubj;
        end;
        begin
          update tvsubject
              set qtychapt = v_amountSubj
            where codcours = v_codcours
            and codsubj = v_codsubj;
        end;        
--<< #4661 || 11/05/2022
        v2_qtysubj := null;  v2_qtychapt := null;
        begin
            select count(distinct codsubj),sum(qtychapt) into v2_qtysubj , v2_qtychapt
            from tvsubject
            where codcours = v_codcours ;

--insert_ttemprpt('AB2','AB2','Point3','v2_qtysubj='||v2_qtysubj,'v2_qtychapt='||v2_qtychapt,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));

        end;
        begin
            update tvcourse
            set  qtysubj = v2_qtysubj,
                 qtychapt = v2_qtychapt
            where codcours = v_codcours;

--insert_ttemprpt('AB2','AB2','Point4','v2_qtysubj='||v2_qtysubj,'v2_qtychapt='||v2_qtychapt,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));

        end;
--<< #4661 || 11/05/2022
      end if;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save_subject is
    v_count_comp        number := 0;
    v_chkExist          number := 0;
    v_sizeDataParam     number := 0;
    v_sizeDataQuery     number := 0;
    v_secur             boolean := false;
    v_codcours	        tvsubject.codcours%type;
    v_codsubj	        tvsubject.codsubj%type;
    v_dessubj	        tvsubject.dessubj%type;
    v_flglearn	        tvsubject.flglearn%type;
    v_flgexam	        tvsubject.flgexam%type;
    v_codexam	        tvsubject.codexam%type;
    v_codcatexm	        tvsubject.codcatexm%type;
    v_staexam	        tvsubject.staexam%type;
  begin
    v_codcours	    := hcm_util.get_string_t(p_tcoursub,'codcours');
    v_codsubj	    := hcm_util.get_string_t(p_tcoursub,'codsubj');
    v_dessubj	    := hcm_util.get_string_t(p_tcoursub,'dessubj');
    v_flglearn	    := hcm_util.get_string_t(p_tcoursub,'flglearn');
    v_flgexam	    := hcm_util.get_string_t(p_tcoursub,'flgexam');
    v_codexam	    := hcm_util.get_string_t(p_tcoursub,'codexam');
    v_codcatexm	    := hcm_util.get_string_t(p_tcoursub,'codcatexm');
    v_staexam	    := hcm_util.get_string_t(p_tcoursub,'staexam');

    if v_dessubj is null or v_flglearn is null or v_flgexam is null or v_staexam is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if v_flgexam = '1' then
      if v_codexam is null and v_codcatexm is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if v_codexam is not null then
        begin
          select count(*) into v_chkExist
            from tvtest
           where codexam = v_codexam;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
          return;
        end if;
      end if;
      if v_codcatexm is not null then
        begin
          select count(*) into v_chkExist
            from tcodcatexm
           where codcodec = v_codcatexm;
        exception when others then null;
        end;
        if v_chkExist < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
          return;
        end if;
      end if;
    end if;

--    v_sizeDataQuery
    begin
      select count(*) into v_sizeDataQuery
      from tvchapter
      where codcours = v_codcours
      and codsubj = v_codsubj;
    end;
    v_sizeDataParam := p_tvchapter.get_size;
  end;

  procedure initial_subject(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_codcate           := hcm_util.get_string_t(json_obj,'p_codcate');
    p_codsubject        := hcm_util.get_string_t(json_obj,'p_codsubject');
    p_chaptno           := hcm_util.get_string_t(json_obj,'p_chaptno');

    p_tcoursub          := hcm_util.get_json_t(json_obj,'tcoursub');
    p_tvchapter         := hcm_util.get_json_t(json_obj,'tvchapter');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure post_save_subject(json_str_input in clob,json_str_output out clob) as
    param_json_row      json_object_t;
    v_chkExist          number := 0;
    v_amountSubj        number := 0;
    v_codcours	        tvsubject.codcours%type;
    v_codsubj	        tvsubject.codsubj%type;
    v_dessubj	        tvsubject.dessubj%type;
    v_flglearn	        tvsubject.flglearn%type;
    v_flgexam	        tvsubject.flgexam%type;
    v_codexam	        tvsubject.codexam%type;
    v_codcatexm	        tvsubject.codcatexm%type;
    v_staexam	        tvsubject.staexam%type;
    v_flg	            varchar2(10 char);
    v_chaptno		    tvchapter.chaptno%type;
    v_namchapt		    tvchapter.namchapte%type;
    v_qtytrainm		    varchar2(500 char);
    v_desc_flgexam		varchar2(500 char);

  begin
    initial_subject(json_str_input);
    check_save_subject;
    if param_msg_error is null then

      v_codcours	  := hcm_util.get_string_t(p_tcoursub,'codcours');
      v_codsubj	    := hcm_util.get_string_t(p_tcoursub,'codsubj');
      v_dessubj	    := hcm_util.get_string_t(p_tcoursub,'dessubj');
      v_flglearn	  := hcm_util.get_string_t(p_tcoursub,'flglearn');
      v_flgexam	    := hcm_util.get_string_t(p_tcoursub,'flgexam');
      v_codexam	    := hcm_util.get_string_t(p_tcoursub,'codexam');
      v_codcatexm	  := hcm_util.get_string_t(p_tcoursub,'codcatexm');
      v_staexam	    := hcm_util.get_string_t(p_tcoursub,'staexam');
      begin
        select count(*) into v_chkExist
          from tvsubject
         where codcours = v_codcours
         and codsubj = v_codsubj;
      exception when others then null;
      end;
      if v_chkExist = 0 then
        insert into tvsubject(codcours,codsubj,flglearn,flgexam,
                              codexam,codcatexm,staexam,dessubj,codcreate,coduser)
              values(v_codcours,v_codsubj,v_flglearn,v_flgexam,
                     v_codexam,v_codcatexm,v_staexam,v_dessubj,global_v_coduser,global_v_coduser);
      else
        update tvsubject
          set flglearn = v_flglearn,
              flgexam = v_flgexam,
              codexam = v_codexam,
              codcatexm = v_codcatexm,
              staexam = v_staexam,
              dessubj = v_dessubj,
              coduser = global_v_coduser
        where codcours = v_codcours
        and codsubj = v_codsubj;
      end if;

      if v_flgexam in ('1','3')  then
        begin
          update tvchapter
            set flgexam = '2',
                codexam = null,
                codcatexm = null,
                staexam = 'N',
                coduser = global_v_coduser
          where codcours = v_codcours
          and codsubj = v_codsubj;
        exception when others then
          null;
        end;
      elsif v_flgexam = '2' then
        begin
          update tvchapter
            set flgexam = '1',
                coduser = global_v_coduser
          where codcours = v_codcours
          and codsubj = v_codsubj;
        exception when others then
          null;
        end;
      end if;

      for i in 0..p_tvchapter.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(p_tvchapter,to_char(i));
        v_flg     		    := hcm_util.get_string_t(param_json_row, 'flg');
        v_chaptno	        := hcm_util.get_string_t(param_json_row, 'chaptno');
        v_namchapt	      := hcm_util.get_string_t(param_json_row, 'namchapt');
        v_qtytrainm	      := hcm_util.get_string_t(param_json_row, 'qtytrainm');
        v_flgexam	        := hcm_util.get_string_t(param_json_row, 'flgexam');
        v_desc_flgexam	  := hcm_util.get_string_t(param_json_row, 'desc_flgexam');

        if v_flg = 'delete' then
          begin
            delete tvchapter
            where codcours = v_codcours
            and codsubj = v_codsubj
            and chaptno = v_chaptno;
          end;
        end if;
      end loop;
      begin
        select count(*) into v_amountSubj
          from tvchapter
         where codcours = v_codcours
           and codsubj = v_codsubj;
      end;
      begin
        update tvsubject
            set qtychapt = v_amountSubj
          where codcours = v_codcours
          and codsubj = v_codsubj;
      end;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure post_save_lesson(json_str_input in clob,json_str_output out clob) as
    param_json_row    json_object_t;
    json_obj          json_object_t;
    v_chkExist    number := 0;
    v_amountSubj  number := 0;
    v_codcours		tvchapter.codcours%type;
    v_codsubj		tvchapter.codsubj%type;
    v_chaptno		tvchapter.chaptno%type;
    v_namchapte		tvchapter.namchapte%type;
    v_namchaptt		tvchapter.namchaptt%type;
    v_namchapt3		tvchapter.namchapt3%type;
    v_namchapt4		tvchapter.namchapt4%type;
    v_namchapt5		tvchapter.namchapt5%type;
    v_deschaptt		tvchapter.deschaptt%type;
    v_filemedia		tvchapter.filemedia%type;
    v_namemedia		tvchapter.namemedia%type;
    v_namelink		tvchapter.namelink%type;
    v_desclink		tvchapter.desclink%type;
    v_filedoc		tvchapter.filedoc%type;
    v_namefiled		tvchapter.namefiled%type;
    v_flgexam		tvchapter.flgexam%type;
    v_codexam		tvchapter.codexam%type;
    v_codcatexm		tvchapter.codcatexm%type;
    v_staexam		tvchapter.staexam%type;
    v_flglearn	  tvsubject.flglearn%type;
    v_dessubj	    tvsubject.dessubj%type;
    v_qtytrainm		varchar2(100 char);
    v_qtytrmin		varchar2(100 char);
    v_typfile     tvchapter.typfile%type;

  begin
    initial_value(json_str_input);
    json_obj  := json_object_t(json_str_input);
    if param_msg_error is null then
      p_tcoursub      := hcm_util.get_json_t(json_obj,'subjectDetail');
      v_codcours	  := hcm_util.get_string_t(p_tcoursub,'codcours');
      v_codsubj	      := hcm_util.get_string_t(p_tcoursub,'codsubj');
      v_dessubj	      := hcm_util.get_string_t(p_tcoursub,'dessubj');
      v_flglearn	  := hcm_util.get_string_t(p_tcoursub,'flglearn');
      v_flgexam	      := hcm_util.get_string_t(p_tcoursub,'flgexam');
      v_codexam	      := hcm_util.get_string_t(p_tcoursub,'codexam');
      v_codcatexm	  := hcm_util.get_string_t(p_tcoursub,'codcatexm');
      v_staexam	      := hcm_util.get_string_t(p_tcoursub,'staexam');
      begin
        select count(*) into v_chkExist
          from tvsubject
         where codcours = v_codcours
         and codsubj = v_codsubj;
      exception when others then null;
      end;
      if v_chkExist = 0 then
        insert into tvsubject(codcours,codsubj,flglearn,flgexam,
                              codexam,codcatexm,staexam,dessubj,codcreate,coduser)
              values(v_codcours,v_codsubj,v_flglearn,v_flgexam,
                     v_codexam,v_codcatexm,v_staexam,v_dessubj,global_v_coduser,global_v_coduser);
      else
        update tvsubject
          set flglearn = v_flglearn,
              flgexam = v_flgexam,
              codexam = v_codexam,
              codcatexm = v_codcatexm,
              staexam = v_staexam,
              dessubj = v_dessubj,
              coduser = global_v_coduser
        where codcours = v_codcours
        and codsubj = v_codsubj;
      end if;
    end if;


    if param_msg_error is null then
      v_codcours		  := hcm_util.get_string_t(p_lessonDetail,'codcours');
      v_codsubj		    := hcm_util.get_string_t(p_lessonDetail,'codsubj');
      v_chaptno		  := hcm_util.get_string_t(p_lessonDetail,'chaptno');
      v_namchapte		:= hcm_util.get_string_t(p_lessonDetail,'namchapte');
      v_namchaptt		:= hcm_util.get_string_t(p_lessonDetail,'namchaptt');
      v_namchapt3		:= hcm_util.get_string_t(p_lessonDetail,'namchapt3');
      v_namchapt4		:= hcm_util.get_string_t(p_lessonDetail,'namchapt4');
      v_namchapt5		:= hcm_util.get_string_t(p_lessonDetail,'namchapt5');
      v_deschaptt		:= hcm_util.get_string_t(p_lessonDetail,'deschaptt');
      v_filemedia		:= hcm_util.get_string_t(p_lessonDetail,'filemedia');
      v_namemedia		:= hcm_util.get_string_t(p_lessonDetail,'namemedia');
      v_namelink		:= hcm_util.get_string_t(p_lessonDetail,'namelink');
      v_desclink		:= hcm_util.get_string_t(p_lessonDetail,'desclink');
      v_filedoc		    := hcm_util.get_string_t(p_lessonDetail,'filedoc');
      v_namefiled		:= hcm_util.get_string_t(p_lessonDetail,'namefiled');
      v_flgexam		    := hcm_util.get_string_t(p_lessonDetail,'flgexam');
      v_codexam		    := hcm_util.get_string_t(p_lessonDetail,'codexam');
      v_codcatexm		:= hcm_util.get_string_t(p_lessonDetail,'codcatexm');
      v_staexam		    := hcm_util.get_string_t(p_lessonDetail,'staexam');
      v_qtytrainm		:= hcm_util.get_string_t(p_lessonDetail,'qtytrainm');
      v_qtytrmin		:= hcm_util.get_string_t(p_lessonDetail,'qtytrmin');

      if v_filemedia is not null then
        v_typfile   := 'F';                                                     -- Peerasak || 01/08/65 || Issue#4659
      elsif v_namelink is not null then
        v_typfile   := 'L';
      end if;

      --<< #4624 || 11/05/2022
      if hcm_util.convert_hour_to_minute(v_qtytrmin) > hcm_util.convert_hour_to_minute(v_qtytrainm) then
         param_msg_error := get_error_msg_php('EL0012',global_v_lang);
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         return;
      end if;
      -->> #4624 || 11/05/2022

      --<<
      begin
        select count(*) into v_chkExist
          from tvchapter
         where codcours = v_codcours
           and codsubj  = v_codsubj
           and chaptno  <> v_chaptno
           and codexam  = v_codexam;
      exception when others then null;
      end;
      if v_chkExist > 0 then
        param_msg_error := get_error_msg_php('EL0010',global_v_lang);
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         return;
      end if;

      begin
        select count(*) into v_chkExist
          from tvchapter
         where codcours = v_codcours
           and codsubj  = v_codsubj
           and chaptno  <> v_chaptno
           and codcatexm = v_codcatexm;
      exception when others then null;
      end;
      if v_chkExist > 0 then
        param_msg_error := get_error_msg_php('EL0011',global_v_lang);
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         return;
      end if;
      -->>

      if v_chaptno is null then
        begin
          select nvl(max(chaptno),0) into v_chaptno
            from tvchapter
           where codcours = v_codcours
             and codsubj = v_codsubj;
        exception when others then null;
        end;
      end if;
      begin
        select count(*) into v_chkExist
          from tvchapter
         where codcours = v_codcours
           and codsubj = v_codsubj
           and chaptno = v_chaptno;
      exception when others then null;
      end;
      if v_chkExist = 0 then
        insert into tvchapter(codcours, codsubj, chaptno,
                              namchapte, namchaptt, namchapt3, namchapt4, namchapt5,
                              qtytrainm, qtytrmin,
                              flgexam, codexam, codcatexm, staexam,
                              filemedia, namemedia, namelink, deschaptt, desclink, filedoc, namefiled,
                              typfile, codcreate, coduser)
                       values(v_codcours, v_codsubj, v_chaptno,
                              v_namchapte, v_namchaptt, v_namchapt3, v_namchapt4, v_namchapt5,
                              hcm_util.convert_hour_to_minute(v_qtytrainm), hcm_util.convert_hour_to_minute(v_qtytrmin),
                              v_flgexam, v_codexam, v_codcatexm, v_staexam,
                              v_filemedia, v_namemedia, v_namelink, v_deschaptt, v_desclink, v_filedoc, v_namefiled,
                              v_typfile, global_v_coduser, global_v_coduser);
      else
        update tvchapter
          set namchapte = v_namchapte,
              namchaptt = v_namchaptt,
              namchapt3 = v_namchapt3,
              namchapt4 = v_namchapt4,
              namchapt5 = v_namchapt5,
              qtytrainm = hcm_util.convert_hour_to_minute(v_qtytrainm),
              qtytrmin = hcm_util.convert_hour_to_minute(v_qtytrmin),
              flgexam = v_flgexam,
              codexam = v_codexam,
              codcatexm = v_codcatexm,
              staexam = v_staexam,
              filemedia = v_filemedia,
              namemedia = v_namemedia,
              namelink = v_namelink,
              deschaptt = v_deschaptt,
              desclink = v_desclink,
              filedoc = v_filedoc,
              namefiled = v_namefiled,
              typfile = v_typfile,
              coduser = global_v_coduser
        where codcours = v_codcours
          and codsubj = v_codsubj
          and chaptno = v_chaptno;
      end if;
      begin
        select count(*) into v_amountSubj
          from tvchapter
         where codcours = v_codcours
           and codsubj = v_codsubj;
      end;
      begin
        update tvsubject
            set qtychapt = v_amountSubj
          where codcours = v_codcours
          and codsubj = v_codsubj;
      end;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrel01e;

/
