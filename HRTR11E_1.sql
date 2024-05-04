--------------------------------------------------------
--  DDL for Package Body HRTR11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR11E" AS

  procedure initial_value(json_str_input in clob) is
    json_obj          json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcours        := UPPER(hcm_util.get_string_t(json_obj,'p_codcours'));
    p_codcoursCopy    := UPPER(hcm_util.get_string_t(json_obj,'p_codcoursCopy'));
    
    if p_codcoursCopy is not null then
        p_flgcopy   := 'Y';
    else
        p_flgcopy   := 'N';
    end if;
  end initial_value;
  
  procedure gen_index(json_str_output out clob) as
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_count1    number;
    v_count2    number;

    cursor c1 is
        select codcours,codcate
          from tcourse
      order by codcours;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row       := v_row+1;
        obj_data    := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('codcate',i.codcate);
        obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
        v_count1 := 0;
        v_count2 := 0;
        begin
            select count(codcours)
              into v_count1
              from thistrnn
             where codcours like i.codcours
               and rownum = 1;
        exception when no_data_found then
            v_count1 := 0;
        end;
        begin
            select count(codcours)
              into v_count2
              from tpotentp
             where codcours like i.codcours
               and rownum = 1;
        exception when no_data_found then
            v_count2 := 0;
        end;
        
        if v_count1 > 0 or v_count1 > 0 then
            obj_data.put('flgDelDisabled',true);
        else
            obj_data.put('flgDelDisabled',false);
        end if;
        
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;
  
  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;  

  procedure check_save_index as
    v_count1    number;
    v_count2    number;
  begin
    if p_codcours is not null then
        begin
            select count(codcours)
              into v_count1
              from thistrnn
             where codcours like p_codcours
               and rownum = 1;
        exception when no_data_found then
            v_count1 := 0;
        end;
        begin
            select count(codcours)
              into v_count2
              from tpotentp
             where codcours like p_codcours
               and rownum = 1;
        exception when no_data_found then
            v_count2 := 0;
        end;
        if v_count1 > 0 or v_count1 > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            return;
        end if;
    end if;
  end check_save_index;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    v_flg           varchar2(10);
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        json_obj            := hcm_util.get_json_t(param_json,to_char(i));
        v_flg               := hcm_util.get_string_t(json_obj,'flg');
        p_codcours          := hcm_util.get_string_t(json_obj,'codcours');
        
        if v_flg = 'delete' then
            check_save_index;
            if param_msg_error is null then 
                begin
                    delete tcourse where codcours = p_codcours;
                    delete tcoursub where codcours = p_codcours;
                    delete tcomptcr where codcours = p_codcours;
                exception when others then
                    null;
                end;
            else  
                rollback;
                exit;
            end if;
        end if;
    end loop;
    
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure gen_detail(json_str_output out clob) as
    obj_main        json_object_t;
    obj_rows        json_object_t;
    obj_data        json_object_t;
    obj_tab1        json_object_t;
    obj_tab2        json_object_t;
    obj_tab2_detail json_object_t;
    obj_tab2_table  json_object_t;
    obj_tab3        json_object_t;
    obj_syncond     json_object_t;
    v_row           number := 0;
    
    v_namgrade      tskilscor.namgrade%type;
    v_namgradt      tskilscor.namgradt%type;
    v_namgrad3      tskilscor.namgrad3%type;
    v_namgrad4      tskilscor.namgrad4%type;
    v_namgrad5      tskilscor.namgrad5%type;
    v_namgrad       tskilscor.namgrade%type;

    cursor c1 is
        select codskill,grade
          from tcomptcr
         where codcours = nvl(p_codcoursCopy,p_codcours)
      order by codskill;

    cursor c2 is
        select codsubj,codinst,qtytrhr
          from tcoursub
         where codcours = nvl(p_codcoursCopy,p_codcours)
      order by codsubj;
  begin
    isAdd       := false;
    isEdit      := false;
    obj_main    := json_object_t();
    
    begin
        select * 
          into v_tcourse
          from tcourse
         where codcours = nvl(p_codcoursCopy,p_codcours);
        isEdit       := true;
    exception when no_data_found then
        v_tcourse               := null;
        v_tcourse.filecommt     := 'N';
        v_tcourse.coddevp       := 'C';
        v_tcourse.flgelern      := 'N';
        isAdd                   := true;
    end;
    
    obj_tab1 := json_object_t();
    obj_tab1.put('coderror',200);
    obj_tab1.put('codcours',p_codcours);
    obj_tab1.put('namcourse',v_tcourse.namcourse);
    obj_tab1.put('namcourst',v_tcourse.namcourst);
    obj_tab1.put('namcours3',v_tcourse.namcours3);
    obj_tab1.put('namcours4',v_tcourse.namcours4);
    obj_tab1.put('namcours5',v_tcourse.namcours5);
    
    if global_v_lang = '101' then
        obj_tab1.put('namcours',v_tcourse.namcourse);
    elsif global_v_lang = '102' then
        obj_tab1.put('namcours',v_tcourse.namcourst);
    elsif global_v_lang = '103' then
        obj_tab1.put('namcours',v_tcourse.namcours3);
    elsif global_v_lang = '104' then
        obj_tab1.put('namcours',v_tcourse.namcours4);
    elsif global_v_lang = '105' then
        obj_tab1.put('namcours',v_tcourse.namcours5);
    end if;
        
    obj_tab1.put('codcate',v_tcourse.codcate);
    obj_tab1.put('descours',v_tcourse.descours);
    obj_tab1.put('typtrain',v_tcourse.typtrain);
    obj_tab1.put('url1',v_tcourse.url1);
    obj_tab1.put('url2',v_tcourse.url2);
    obj_tab1.put('codsubj',v_tcourse.codsubj);
    obj_tab1.put('coddevp',v_tcourse.coddevp);
    obj_tab1.put('descdevp',v_tcourse.descdevp);
    obj_tab1.put('codinst',v_tcourse.codinst);
    obj_tab1.put('codconslt',v_tcourse.codconslt);
    obj_tab1.put('flgcommt',v_tcourse.flgcommt);
    obj_tab1.put('descommt',v_tcourse.descommt);
    obj_tab1.put('descommt2',v_tcourse.descommt2);
    
    obj_syncond := json_object_t();
    obj_syncond.put('code',trim(nvl(v_tcourse.syncond,' ')));
    obj_syncond.put('description',trim(nvl(get_logical_desc(v_tcourse.statement),' ')));
--    obj_syncond.put('description',trim(nvl(get_logical_name('HRTR11E',v_tcourse.syncond,global_v_lang),' ')));
    obj_syncond.put('statement',nvl(v_tcourse.statement,'[]'));
    obj_tab1.put('syncond',obj_syncond);
    obj_tab1.put('qtytrhur',hcm_util.convert_minute_to_hour(v_tcourse.qtytrhur * 60));
    obj_tab1.put('qtytrday',v_tcourse.qtytrday);
    obj_tab1.put('qtytrflw',v_tcourse.qtytrflw);
    obj_tab1.put('filecommt',v_tcourse.filecommt);
    
    obj_tab2_detail := json_object_t();
    obj_tab2_detail.put('coderror',200);
    obj_tab2_detail.put('descobjt',v_tcourse.descobjt);
    obj_tab2_detail.put('descbenefit',v_tcourse.descbenefit);
    obj_tab2_detail.put('codresp',v_tcourse.codresp);
    obj_tab2_detail.put('filename',v_tcourse.filename);
    obj_tab2_detail.put('qtyppc',v_tcourse.qtyppc);
    obj_tab2_detail.put('amtbudg',v_tcourse.amtbudg);
    obj_tab2_detail.put('desceval',v_tcourse.desceval);
    obj_tab2_detail.put('desmeasure',v_tcourse.desmeasure);
    obj_tab2_detail.put('codform',v_tcourse.codform);
    obj_tab2_detail.put('codcomptr',v_tcourse.codcomptr);
    obj_tab2_detail.put('flgelern',v_tcourse.flgelern);
    obj_tab2_detail.put('typcours',v_tcourse.typcours);
    
    obj_tab2_table  := json_object_t();
    for r1 in c1 loop
        v_row           := v_row + 1;
        obj_data        := json_object_t();
        obj_data.put('coderror',200);
        if p_flgcopy = 'Y' then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        obj_data.put('codskill',r1.codskill);
        obj_data.put('grade',r1.grade);
        
        begin
          select namgrade, namgradt, namgrad3, namgrad4, namgrad5,
                 decode(global_v_lang,'101',namgrade
                                     ,'102',namgradt
                                     ,'103',namgrad3
                                     ,'104',namgrad4
                                     ,'105',namgrad5) as namgrad

            into v_namgrade, v_namgradt, v_namgrad3, v_namgrad4, v_namgrad5, v_namgrad
            from tskilscor
           where codskill = r1.codskill
             and grade = r1.grade;
        exception when no_data_found then
          v_namgrad  := ''; v_namgrade := ''; v_namgradt := ''; 
          v_namgrad3 := ''; v_namgrad4 := ''; v_namgrad5 := '';
        end;
        
        obj_data.put('namgrad',v_namgrad);
        obj_data.put('namgrade',v_namgrade);
        obj_data.put('namgradt',v_namgradt);
        obj_data.put('namgrad3',v_namgrad3);
        obj_data.put('namgrad4',v_namgrad4);
        obj_data.put('namgrad5',v_namgrad5);
        obj_tab2_table.put(to_char(v_row-1),obj_data);
    end loop;
    
    obj_tab2    := json_object_t();
    obj_tab2.put('coderror',200);
    obj_tab2.put('detail',obj_tab2_detail);
    obj_tab2.put('table',obj_tab2_table);
    
    obj_tab3    := json_object_t();
    v_row       := 0;
    for r2 in c2 loop
        v_row           := v_row + 1;
        obj_data        := json_object_t();
        obj_data.put('coderror',200);
        if p_flgcopy = 'Y' then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        obj_data.put('codsubj',r2.codsubj);
        obj_data.put('codinst',r2.codinst);
        obj_data.put('qtytrhr',hcm_util.convert_minute_to_hour(r2.qtytrhr * 60)); 
        obj_tab3.put(to_char(v_row-1),obj_data);
    end loop;    
    
    if param_msg_error is null then
        obj_main.put('coderror',200);
        if p_codcoursCopy is null then
            obj_main.put('isCopy','N');
        else
            obj_main.put('isCopy','Y');
            isAdd    := true;
            isEdit   := false;
        end if;
        obj_main.put('isAdd',isAdd);
        obj_main.put('isEdit',isEdit);
        obj_main.put('tab1',obj_tab1);
        obj_main.put('tab2',obj_tab2);
        obj_main.put('tab3',obj_tab3);

        json_str_output := obj_main.to_clob;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end gen_detail;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_copylist(json_str_output out clob) as
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;

    cursor c1 is
        select distinct codcours,codcate
          from tcourse
         where codcours <> p_codcours
      order by codcours;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_copylist;
  
  procedure get_copylist(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_copylist(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_copylist;

  procedure check_save as
    v_temp   varchar2(1 char);
  begin
--  check input language
    if global_v_lang = '101' and v_tcourse.namcourse is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '102' and v_tcourse.namcourst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '103' and v_tcourse.namcours3 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '104' and v_tcourse.namcours4 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '105' and v_tcourse.namcours5 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check null
    if v_tcourse.codcate is null 
        or v_tcourse.coddevp is null 
        or (nvl(v_tcourse.qtytrhur,0) <= 0) 
        or v_tcourse.syncond is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check descommt
    if v_tcourse.flgcommt = 'Y' then
        if v_tcourse.descommt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    else
        v_tcourse.descommt := '';
    end if;

     if v_tcourse.codcate is not null then
         begin
            select distinct 'X' into v_temp
              from tcodcate
             where codcodec = v_tcourse.codcate;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodcate');
            return;
         end;
     end if;

--   check null in tsubject
     if v_tcourse.codsubj is not null then
         begin
            select distinct 'X' into v_temp
              from tsubject
             where codcodec = v_tcourse.codsubj;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tsubject');
            return;
         end;
     end if;

--   check null in tinstruc
     if v_tcourse.codinst is not null then
        begin
            select 'X' into v_temp
              from tinstruc
             where codinst = v_tcourse.codinst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinstruc');
            return;
        end;
     end if;

     if v_tcourse.codconslt is not null then
        begin
            select 'X' into v_temp
              from temploy1
             where codempid = v_tcourse.codconslt
               and staemp not in (0,9);
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;
     end if;  
    
    -- tab2
--  check null parameters
    if nvl(v_tcourse.qtyppc,0) <= 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codresp in temploy1
    if v_tcourse.codresp is not null then
        begin
            select 'X' into v_temp
              from temploy1
             where codempid = v_tcourse.codresp
               and staemp not in (0,9);
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;
    end if;

--  check null codform in tintview & v_tcourse.qtytrflw not null
    if v_tcourse.codform is not null then
        if nvl(v_tcourse.qtytrflw,0) <= 0 then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
              from tintview
             where codform = v_tcourse.codform;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tintview');
            return;
        end;
    end if;

--  check codcomptr in tcenter
    if v_tcourse.codcomptr is not null then
        begin
            select 'X' into v_temp
              from tcenter
             where codcomp like v_tcourse.codcomptr || '%'
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
    end if;
  end check_save;
  
  procedure check_tab2 as
  begin
--  check null parameters
    if v_tcomptcr.codskill is null or v_tcomptcr.grade is null or
       (v_tskilscor.namgrade is null and
        v_tskilscor.namgradt is null and
        v_tskilscor.namgrad3 is null and
        v_tskilscor.namgrad4 is null and
        v_tskilscor.namgrad5 is null) then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_tab2;
  
  procedure check_tab3 as
    v_temp        varchar2(1 char);
    v_sumhr       number;
  begin
    if v_tcoursub.codsubj is null or nvl(v_tcoursub.qtytrhr,0) <= 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if v_tcoursub.codinst is not null then
        begin
            select 'X' into v_temp
              from tinstruc
             where codinst = v_tcoursub.codinst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinstruc');
            return;
        end;
    end if;
  end check_tab3;
  
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    obj_syncond     json_object_t;
    
    data_obj        json_object_t;
    v_flg           varchar2(10);
    v_sumqtytrhr    number;
  begin
    initial_value(json_str_input);
    json_obj                := json_object_t(json_str_input);
    p_tab1                  := hcm_util.get_json_t(json_obj,'tab1');
    p_tab2                  := hcm_util.get_json_t(json_obj,'tab2');
    p_tab2_detail           := hcm_util.get_json_t(p_tab2,'detail');
    p_tab2_table            := hcm_util.get_json_t(json_obj,'competency');
    p_tab3                  := hcm_util.get_json_t(json_obj,'tab3');
    isAdd                   := hcm_util.get_boolean_t(json_obj,'isAdd');
    isEdit                  := hcm_util.get_boolean_t(json_obj,'isEdit');
    isCopy                  := hcm_util.get_string_t(json_obj,'isCopy');   
    
    p_codcours              := hcm_util.get_string_t(p_tab1,'codcours');
    v_tcourse.namcourse     := hcm_util.get_string_t(p_tab1,'namcourse');
    v_tcourse.namcourst     := hcm_util.get_string_t(p_tab1,'namcourst');
    v_tcourse.namcours3     := hcm_util.get_string_t(p_tab1,'namcours3');
    v_tcourse.namcours4     := hcm_util.get_string_t(p_tab1,'namcours4');
    v_tcourse.namcours5     := hcm_util.get_string_t(p_tab1,'namcours5');
    v_tcourse.codcate       := hcm_util.get_string_t(p_tab1,'codcate');
    v_tcourse.descours      := hcm_util.get_string_t(p_tab1,'descours');
    v_tcourse.typtrain      := hcm_util.get_string_t(p_tab1,'typtrain');
    v_tcourse.url1          := hcm_util.get_string_t(p_tab1,'url1');
    v_tcourse.url2          := hcm_util.get_string_t(p_tab1,'url2');
    v_tcourse.coddevp       := hcm_util.get_string_t(p_tab1,'coddevp');
    v_tcourse.descdevp      := hcm_util.get_string_t(p_tab1,'descdevp');
    v_tcourse.codinst       := hcm_util.get_string_t(p_tab1,'codinst');
    v_tcourse.codsubj       := hcm_util.get_string_t(p_tab1,'codsubj');
    v_tcourse.codconslt     := hcm_util.get_string_t(p_tab1,'codconslt');
    v_tcourse.flgcommt      := hcm_util.get_string_t(p_tab1,'flgcommt');
    v_tcourse.descommt      := hcm_util.get_string_t(p_tab1,'descommt');
    v_tcourse.descommt2     := hcm_util.get_string_t(p_tab1,'descommt2');
    obj_syncond             := hcm_util.get_json_t(p_tab1,'syncond');
    v_tcourse.syncond       := hcm_util.get_string_t(obj_syncond,'code');
    v_tcourse.statement     := hcm_util.get_string_t(obj_syncond,'statement');
    v_tcourse.qtytrhur      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(p_tab1,'qtytrhur'))/60;
    v_tcourse.qtytrflw      := hcm_util.get_string_t(p_tab1,'qtytrflw');
    v_tcourse.qtytrday      := hcm_util.get_string_t(p_tab1,'qtytrday');
    v_tcourse.filecommt     := hcm_util.get_string_t(p_tab1,'filecommt');
    v_tcourse.descobjt      := hcm_util.get_string_t(p_tab2_detail,'descobjt');
    v_tcourse.descbenefit   := hcm_util.get_string_t(p_tab2_detail,'descbenefit');
    v_tcourse.codresp       := hcm_util.get_string_t(p_tab2_detail,'codresp');
    v_tcourse.filename      := hcm_util.get_string_t(p_tab2_detail,'filename');
    v_tcourse.qtyppc        := hcm_util.get_string_t(p_tab2_detail,'qtyppc');
    v_tcourse.amtbudg       := hcm_util.get_string_t(p_tab2_detail,'amtbudg');
    v_tcourse.desceval      := hcm_util.get_string_t(p_tab2_detail,'desceval');
    v_tcourse.desmeasure    := hcm_util.get_string_t(p_tab2_detail,'desmeasure');
    v_tcourse.codform       := hcm_util.get_string_t(p_tab2_detail,'codform');
    v_tcourse.codcomptr     := hcm_util.get_string_t(p_tab2_detail,'codcomptr');
    v_tcourse.flgelern      := hcm_util.get_string_t(p_tab2_detail,'flgelern');
    v_tcourse.typcours      := hcm_util.get_string_t(p_tab2_detail,'typcours');
    
    check_save;
    
    if param_msg_error is null then
        if isCopy = 'Y' then
            delete tcourse where codcours = p_codcours;
            delete tcoursub where codcours = p_codcours;
            delete tcomptcr where codcours = p_codcours;
        end if;
        
        begin 
            insert into tcourse(codcours,namcourse,namcourst,namcours3,namcours4,namcours5,
                                codcate,descours,typtrain,url1,url2,
                                coddevp,descdevp,codinst,codsubj,codconslt,
                                flgcommt,descommt,descommt2,syncond,statement,
                                qtytrhur,qtytrflw,qtytrday,filecommt,
                                descobjt,descbenefit,codresp,filename,
                                qtyppc,amtbudg,desceval,desmeasure,codform,
                                codcomptr,flgelern,typcours,
                                dtecreate,codcreate,dteupd,coduser)
            values(p_codcours,v_tcourse.namcourse,v_tcourse.namcourst,v_tcourse.namcours3,v_tcourse.namcours4,v_tcourse.namcours5,
                   v_tcourse.codcate,v_tcourse.descours,v_tcourse.typtrain,v_tcourse.url1,v_tcourse.url2,
                   v_tcourse.coddevp,v_tcourse.descdevp,v_tcourse.codinst,v_tcourse.codsubj,v_tcourse.codconslt,
                   v_tcourse.flgcommt,v_tcourse.descommt,v_tcourse.descommt2,v_tcourse.syncond,v_tcourse.statement,
                   v_tcourse.qtytrhur,v_tcourse.qtytrflw,v_tcourse.qtytrday,v_tcourse.filecommt,
                   v_tcourse.descobjt,v_tcourse.descbenefit,v_tcourse.codresp,v_tcourse.filename,
                   v_tcourse.qtyppc,v_tcourse.amtbudg,v_tcourse.desceval,v_tcourse.desmeasure,v_tcourse.codform,
                   v_tcourse.codcomptr,v_tcourse.flgelern,v_tcourse.typcours,
                   sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tcourse
               set namcourse = v_tcourse.namcourse,
                   namcourst = v_tcourse.namcourst,
                   namcours3 = v_tcourse.namcours3,
                   namcours4 = v_tcourse.namcours4,
                   namcours5 = v_tcourse.namcours5,
                   codcate = v_tcourse.codcate,
                   descours = v_tcourse.descours,
                   typtrain = v_tcourse.typtrain,
                   url1 = v_tcourse.url1,
                   url2 = v_tcourse.url2,
                   coddevp = v_tcourse.coddevp,
                   descdevp = v_tcourse.descdevp,
                   codinst = v_tcourse.codinst,
                   codsubj = v_tcourse.codsubj,
                   codconslt = v_tcourse.codconslt,
                   flgcommt = v_tcourse.flgcommt,
                   descommt = v_tcourse.descommt,
                   descommt2 = v_tcourse.descommt2,
                   syncond = v_tcourse.syncond,
                   statement = v_tcourse.statement,
                   qtytrhur = v_tcourse.qtytrhur,
                   qtytrflw = v_tcourse.qtytrflw,
                   qtytrday = v_tcourse.qtytrday,
                   filecommt = v_tcourse.filecommt,
                   descobjt = v_tcourse.descobjt,
                   descbenefit = v_tcourse.descbenefit,
                   codresp = v_tcourse.codresp,
                   filename = v_tcourse.filename,
                   qtyppc = v_tcourse.qtyppc,
                   amtbudg = v_tcourse.amtbudg,
                   desceval = v_tcourse.desceval,
                   desmeasure = v_tcourse.desmeasure,
                   codform = v_tcourse.codform,
                   codcomptr = v_tcourse.codcomptr,
                   flgelern = v_tcourse.flgelern,
                   typcours = v_tcourse.typcours,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codcours = p_codcours;
        end;
    end if;
    
    if param_msg_error is null then
        for i in 0..p_tab2_table.get_size-1 loop
            data_obj                := hcm_util.get_json_t(p_tab2_table,to_char(i));
            v_flg                   := hcm_util.get_string_t(data_obj,'flg');
            v_tcomptcr.codskill     := hcm_util.get_string_t(data_obj,'codskill');
            v_tcomptcr.grade        := hcm_util.get_string_t(data_obj,'grade');
            
            v_tskilscor.namgrade    := hcm_util.get_string_t(data_obj,'namgrade');
            v_tskilscor.namgradt    := hcm_util.get_string_t(data_obj,'namgradt');
            v_tskilscor.namgrad3    := hcm_util.get_string_t(data_obj,'namgrad3');
            v_tskilscor.namgrad4    := hcm_util.get_string_t(data_obj,'namgrad4');
            v_tskilscor.namgrad5    := hcm_util.get_string_t(data_obj,'namgrad5');
            
            check_tab2;
            
            if v_flg = 'delete' then
                delete tcomptcr 
                 where codskill = v_tcomptcr.codskill
                   and grade = v_tcomptcr.grade
                   and codcours = p_codcours;
            else
                begin
                    insert into tcomptcr(codskill,grade,codcours,
                                         dtecreate,codcreate,dteupd,coduser)
                    values(v_tcomptcr.codskill,v_tcomptcr.grade,p_codcours,
                           sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tcomptcr
                       set grade = v_tcomptcr.grade,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codskill =v_tcomptcr.codskill
                       and grade = v_tcomptcr.grade
                       and codcours = p_codcours;
                end;
    
                begin
                    insert into tskilscor(codskill,grade,
                                          namgrade,namgradt,namgrad3,namgrad4,namgrad5,
                                          dtecreate,codcreate,dteupd,coduser)
                    values(v_tcomptcr.codskill,v_tcomptcr.grade,
                           v_tskilscor.namgrade,v_tskilscor.namgradt,v_tskilscor.namgrad3,v_tskilscor.namgrad4,v_tskilscor.namgrad5,
                           sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tskilscor
                       set namgrade = v_tskilscor.namgrade,
                           namgradt = v_tskilscor.namgradt,
                           namgrad3 = v_tskilscor.namgrad3,
                           namgrad4 = v_tskilscor.namgrad4,
                           namgrad5 = v_tskilscor.namgrad5,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codskill = v_tcomptcr.codskill
                       and grade = v_tcomptcr.grade;
                end;
            end if;
        end loop;
    end if;
    
    if param_msg_error is null then
        for i in 0..p_tab3.get_size-1 loop
            data_obj                := hcm_util.get_json_t(p_tab3,to_char(i));
            v_flg                   := hcm_util.get_string_t(data_obj,'flg');
            v_tcoursub.codsubj      := hcm_util.get_string_t(data_obj,'codsubj');
            v_tcoursub.codinst      := hcm_util.get_string_t(data_obj,'codinst');
            v_tcoursub.qtytrhr     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(data_obj,'qtytrhr'))/60;
            
            check_tab3;
            if param_msg_error is not null then
                exit;
            end if;
            
            if v_flg = 'delete' then
                delete tcoursub 
                 where codsubj = v_tcoursub.codsubj
                   and codcours = p_codcours;
            else
                begin
                    insert into tcoursub(codcours,codsubj,codinst,qtytrhr,
                                         dtecreate,codcreate,dteupd,coduser)
                    values(p_codcours,v_tcoursub.codsubj,v_tcoursub.codinst,v_tcoursub.qtytrhr,
                           sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tcoursub
                       set codinst = v_tcoursub.codinst,
                           qtytrhr = v_tcoursub.qtytrhr,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codsubj = v_tcoursub.codsubj
                       and codcours = p_codcours;
                end;
            end if;
        end loop; 
    end if;
    
    if param_msg_error is null then
        begin 	
          select sum(qtytrhr)
            into v_sumqtytrhr
            from tcoursub
           where codcours = p_codcours;
        exception when no_data_found then
          v_sumqtytrhr := 0;	 
        end;	
        v_sumqtytrhr   := nvl(v_sumqtytrhr,0);
        
        if nvl(v_sumqtytrhr,0) <> v_tcourse.qtytrhur then
          param_msg_error := get_error_msg_php('TR0001',global_v_lang);
        end if;
    end if;
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;
END HRTR11E;

/
