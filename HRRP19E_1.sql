--------------------------------------------------------
--  DDL for Package Body HRRP19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP19E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

--  p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');--<< user25 Date : 08/09/2021 1. RP Module  #4549
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');--<< user25 Date : 08/09/2021 1. RP Module  #4549
    p_shorttrm          := hcm_util.get_string_t(json_obj,'p_shorttrm');
    p_midterm           := hcm_util.get_string_t(json_obj,'p_midterm');
    p_longtrm           := hcm_util.get_string_t(json_obj,'p_longtrm');
    p_codreview         := hcm_util.get_string_t(json_obj,'p_codreview');
    p_dtereview         := to_date(hcm_util.get_string_t(json_obj,'p_dtereview'), 'dd/mm/yyyy');
    p_descstr           := hcm_util.get_string_t(json_obj,'p_descstr');
    p_descweek          := hcm_util.get_string_t(json_obj,'p_descweek');
    p_descoop           := hcm_util.get_string_t(json_obj,'p_descoop');
    p_descthreat        := hcm_util.get_string_t(json_obj,'p_descthreat');
    p_descdevp          := hcm_util.get_string_t(json_obj,'p_descdevp');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_numpath           := hcm_util.get_string_t(json_obj,'p_numpath');

    p_codskill           := hcm_util.get_string_t(json_obj,'p_codskill');--<< user25 Date : 08/09/2021 1. RP Module #4561

    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    if p_codcomp is null and p_codpos is null then
    begin
      select codpos,codcomp
        into p_codpos,p_codcomp
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      p_codpos  := null;
      p_codcomp := null;
    end;
    end if;
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

  end;

  --
  procedure check_detail is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_temp      varchar2(10 char);
    v_flgSecur  boolean;
  begin
    begin
      select 'X' , staemp
      into v_temp, v_staemp
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;

--    if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) = false then
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--      return;
--    end if;

      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;

      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
   end;

  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;

    cursor c1 is
      select  codcomp, codpos, codreview, dtereview, shorttrm, midterm, longtrm
        from tposemph
        where codempid = p_codempid
          --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
          and codcomp = v_codcomp
          and codpos = v_codpos;
          -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  begin
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',p_codempid);
      --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
      begin
            select codcomp,codpos
              into v_codcomp,v_codpos
            from temploy1
            where codempid = p_codempid;
      end;
      -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
      for r1 in c1 loop
        v_count := v_count + 1;

        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('codreview',r1.codreview);
        obj_data.put('dtereview',to_char(r1.dtereview, 'dd/mm/yyyy'));
        obj_data.put('shorttrm',r1.shorttrm);
        obj_data.put('midterm',r1.midterm);
        obj_data.put('longtrm',r1.longtrm);
        obj_data.put('flg','Y');--<<user25 Date:29/09/2021  #4564
        --<<user25 Date:30/09/2021  #4564
        if (r1.codcomp = v_codcomp and r1.codpos = v_codpos) then
           obj_data.put('flgDisabledDetail','N'); --Y = เปิด Tab ปกติ /N = ปิดเเท้บ
        else
             obj_data.put('flgDisabledDetail','Y'); --Y = เปิด Tab ปกติ /N = ปิดเเท้บ
        end if;
         -->>user25 Date:30/09/2021  #4564

      end loop;

      if v_count = 0 then
          begin
            select codcomp,codpos
              into v_codcomp,v_codpos
            from temploy1
            where codempid = p_codempid;
            obj_data.put('codcomp',v_codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
            obj_data.put('codpos',v_codpos);
            obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
            obj_data.put('flg','N'); --<<user25 Date:29/09/2021  #4564
            obj_data.put('flgDisabledDetail','N');--<<user25 Date:30/09/2021  #4564
          exception when no_data_found then
            obj_data.put('codcomp','');
            obj_data.put('desc_codcomp','');
            obj_data.put('codpos','');
            obj_data.put('desc_codpos','');
            obj_data.put('flg','N');--<<user25 Date:29/09/2021  #4564
            obj_data.put('flgDisabledDetail','N');--<<user25 Date:30/09/2021  #4564
          end;
        end if;

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab1(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;

    cursor c1 is
      select  descstr, descweek, descoop, descthreat
        from tposemph
        where codempid = p_codempid;
  begin
        obj_data := json_object_t();
        obj_data.put('coderror','200');

      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data.put('descstr',r1.descstr);
        obj_data.put('descweek',r1.descweek);
        obj_data.put('descoop',r1.descoop);
        obj_data.put('descthreat',r1.descthreat);

      end loop;

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab2(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;
    v_row           number := 0;
    v_dteefpos      temploy1.dteefpos%type;

    cursor c1 is
      select  numseq, codlinef, codcomp, codpos,  dteefpos, dteposdue
        from tposempd
        where codempid = p_codempid;
  begin
        begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into v_codcompy
            from temploy1
            where codempid = p_codempid;
          exception when no_data_found then
               null;
          end;


        obj_row := json_object_t();

      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        --<< user 25 Date : 08/11/2021 #4559
        begin
            select dteefpos
             into v_dteefpos
             from temploy1
            where codempid = p_codempid
            and codpos = r1.codpos;
          exception when no_data_found then
               v_dteefpos := r1.dteefpos;--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 v_dteefpos := null;
          end;
          -->> user 25 Date : 08/11/2021 #4559
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef); --<< user25 Date : 09/09/2021 1. RP Module #4549
        obj_data.put('desc_codlinef',get_tfunclin_name(v_codcompy,r1.codlinef,global_v_lang));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
--        obj_data.put('dteefpos',to_char(r1.dteefpos, 'dd/mm/yyyy')); --<< user 25 Date : 08/11/2021 #4559
        obj_data.put('dteefpos',to_char(v_dteefpos, 'dd/mm/yyyy')); --<< user 25 Date : 08/11/2021 #4559
        obj_data.put('dteposdue',to_char(r1.dteposdue, 'dd/mm/yyyy'));
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab3(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;
    v_row           number := 0;

    cursor c1 is
      select  descdevp
        from tposemph
        where codempid = p_codempid;

    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    cursor c2 is
      select CODCOMP,CODPOS
        from tposempd
        where codempid = p_codempid
      order by numseq desc;
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    begin
       obj_data := json_object_t();
        obj_data.put('coderror','200');
      for r1 in c1 loop
        obj_data.put('descdevp',r1.descdevp);
      end loop;
      --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
      for r1 in c2 loop
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        exit;
      end loop;
      -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab3(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab3_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_grade         tcmptncy.grade%type;
    v_count         number := 0;
    v_row           number := 0;

    cursor c1 is
      select  codempid, codcomp, codpos, codskill, codtency, grade, grdemp, desdevp
         from tposempctc
        where codempid = p_codempid
        --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
        and codcomp = p_codcomp
        and codpos = p_codpos;
        /*and codcomp = v_codcomp
        and codpos = v_codpos;*/
        -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = p_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;

    cursor c3 is
      select codtency,codskill,grade
         from tjobposskil
        where codcomp = v_codcomp
        and codpos = v_codpos
        order by codtency,codskill;

  begin

       for r2 in c2 loop
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
       end loop;

        obj_row := json_object_t();

      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codskill',r1.codskill);
        obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
        obj_data.put('codtency',r1.codtency);
        obj_data.put('grade',r1.grade);
        obj_data.put('gradehide',r1.grade);

        obj_data.put('level',r1.grdemp);
        obj_data.put('gap',(r1.grade - nvl(r1.grdemp,0)));
        obj_data.put('desdevp',r1.desdevp);
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

      /*User37 #4561 #4559 #4552 1. RP Module 16/12/2021 if v_count = 0 then
         for r3 in c3 loop
            v_count := v_count + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codskill',r3.codskill);
            obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r3.codskill, global_v_lang));
            obj_data.put('codtency',r3.codtency);
            obj_data.put('grade',r3.grade);
            obj_data.put('gradehide',r3.grade);

            begin
                select grade
                into v_grade
                  from tcmptncy
                 where codempid = p_codempid
                   and codtency = r3.codskill;
            exception when no_data_found then
               v_grade := null;
            end;
            obj_data.put('level',v_grade);
            obj_data.put('gap',(r3.grade - nvl(v_grade,0)));
            obj_data.put('desdevp',' ');
            obj_row.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
          end loop;
      end if;*/

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab3_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab3_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

 procedure gen_detail_tab4_table1(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_grade         tjobposskil.grade%type;
    --<< user25 Date: 07/09/2021 1. RP Module #4562
    v_grade_emp     tcmptncy.grade%type;
    v_codcours      tcomptcr.codcours%type;
    v_codskill      tcomptcr.codskill%type;
    -->> user25 Date: 07/09/2021 1. RP Module #4562

    cursor c1 is
      select  codcours,dtestr,dteend,dtetrst
         from tposemptr
        where codempid = p_codempid
        --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
        and codcomp = p_codcomp
        and codpos = p_codpos
        --and codcomp = v_codcomp
        --and codpos = v_codpos
        -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
        order by codcours;

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = p_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;


--<< user25 Date: 07/09/2021 1. RP Module #4562
    cursor c3 is
      select codtency,codskill,grade
         from tjobposskil
        where codcomp = v_codcomp
        and codpos = v_codpos
        order by codtency,codskill;

    cursor c4 is
      select  codcours
         from tcomptcr
        where codskill = v_codskill
          and grade between (v_grade_emp+1) and v_grade
          group by codcours
     order by codcours;
-->> user25 Date: 07/09/2021 1. RP Module #4562

  begin
       for r2 in c2 loop
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
       end loop;
        obj_row := json_object_t();

       for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcours',r1.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
        obj_data.put('dtestr',to_char(r1.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('dtetrst',to_char(r1.dtetrst,'dd/mm/yyyy'));
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

--<< user25 Date: 07/09/2021 1. RP Module #4562
   ---insert----
    /*User37 #4561 #4559 #4552 1. RP Module 16/12/2021 if v_count = 0 then
        for r3 in c3 loop
            v_count := v_count + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');

             begin
                select grade
                into v_grade_emp
                  from tcmptncy
                 where codempid = p_codempid
                   and codtency = r3.codskill;
            exception when no_data_found then
               v_grade_emp := null;
            end;

              v_codskill    := r3.codskill;
              v_grade_emp   := v_grade_emp;
              v_grade       := r3.grade;
              for r4 in c4 loop
                v_count := v_count + 1;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codcours',r4.codcours);
                obj_data.put('desc_codcours',get_tcourse_name(r4.codcours,global_v_lang));
                obj_data.put('dtestr','');
                obj_data.put('dteend','');
                obj_data.put('dtetrst','');
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
              end loop;
      end loop;
    end if;*/
-->> user25 Date: 07/09/2021 1. RP Module #4562

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab4_table1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab4_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab4_table2(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_grade         tjobposskil.grade%type;

--<< user25 Date: 07/09/2021 1. RP Module #4562
    v_grade_emp     tcmptncy.grade%type;
    v_codcours      tcomptcr.codcours%type;
    v_codskill      tcomptdev.codskill%type;
--<< user25 Date: 07/09/2021 1. RP Module #4562

    cursor c1 is
       select   coddevp,desdevp,targetdev,dtestr,dteend,desresults
         from   tposempdev
        where   codempid = p_codempid
          --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
          and   codcomp = p_codcomp
          and   codpos = p_codpos;
          /*User37 #4561 #4559 #4552 1. RP Module 16/12/2021 and   codcomp = v_codcomp
          and   codpos = v_codpos;*/
          -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

    cursor c2 is
       select   codcomp,codpos
         from   tposempd
        where   codempid = p_codempid
          and   dteefpos is null
          and   rownum = 1
     order by   numseq;

--<< user25 Date: 07/09/2021 1. RP Module #4562
    cursor c3 is
      select    codtency,codskill,grade
        from    tjobposskil
       where    codcomp = v_codcomp
         and    codpos = v_codpos
    order by    codtency,codskill;

    cursor c4 is
      select    coddevp
        from    tcomptdev
       where    codskill = v_codskill
         and    grade between (v_grade_emp+1) and v_grade
    group by    coddevp
    order by    coddevp;
-->> user25 Date: 07/09/2021 1. RP Module #4562

  begin
       for r2 in c2 loop
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
       end loop;

        obj_row := json_object_t();

      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('coddevp',r1.coddevp);
        obj_data.put('desc_coddevp',get_tcodec_name('TCODDEVT',r1.coddevp,global_v_lang));
        obj_data.put('targetdev',r1.targetdev);
        obj_data.put('desdevp',r1.desdevp);
        obj_data.put('dtestr',to_char(r1.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('desresults',r1.desresults);
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

--<< user25 Date: 07/09/2021 1. RP Module #4562
   ---insert----
    /*User37 #4561 #4559 #4552 1. RP Module 16/12/2021 if v_count = 0 then
      for r3 in c3 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');

        begin
          select grade
          into v_grade_emp
            from tcmptncy
           where codempid = p_codempid
             and codtency = r3.codskill;
        exception when no_data_found then
          v_grade_emp := null;
        end;
        v_codskill    := r3.codskill;
        v_grade_emp   := v_grade_emp;
        v_grade       := r3.grade;
        for r4 in c4 loop
          v_count := v_count + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('coddevp',r4.coddevp);
          obj_data.put('desc_coddevp',get_tcodec_name('TCODDEVT',r4.coddevp,global_v_lang));
          obj_data.put('targetdev','');
          obj_data.put('desdevp','');
          obj_data.put('dtestr','');
          obj_data.put('dteend','');
          obj_data.put('desresults','');
          obj_data.put('flgAdd',true);
          obj_row.put(to_char(v_row), obj_data);
          v_row        := v_row + 1;
        end loop;
      end loop;
    end if;*/
-->> user25 Date: 07/09/2021 1. RP Module #4562

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab4_table2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab4_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_detail (json_str_output out clob) is
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
  begin

      if trunc(p_dtereview) < trunc(sysdate) then
       param_msg_error := get_error_msg_php('HR8519',global_v_lang);
       return;
     end if;

      begin
        select codcomp,codpos
          into v_codcomp,v_codpos
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        v_codcomp := null;
        v_codpos := null;
      end;
    begin
      insert into tposemph
             (codempid,codreview, dtereview, codcomp, codpos, shorttrm, midterm, longtrm, descstr, descweek, descoop,
             descthreat,descdevp, coduser, codcreate)
      values (p_codempid,p_codreview, p_dtereview, v_codcomp, v_codpos, p_shorttrm, p_midterm, p_longtrm, p_descstr, p_descweek, p_descoop,
             p_descthreat,p_descdevp, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update tposemph
         set codreview    = p_codreview,
             dtereview    = p_dtereview,
             codcomp      = v_codcomp,
             codpos       = v_codpos,
             shorttrm     = p_shorttrm,
             midterm      = p_midterm,
             longtrm      = p_longtrm,
             descstr      = p_descstr,
             descweek     = p_descweek,
             descoop      = p_descoop,
             descthreat   = p_descthreat,
             descdevp     = p_descdevp,
             coduser      = global_v_coduser,
             codcreate    = global_v_coduser
       where codempid     = p_codempid;
    end;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab2_table (json_str_output out clob) is
   obj_tab2               json_object_t;
   obj_tab1               json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_rowId               varchar2(1000 char);
    v_codleaveOld         varchar2(100 char);
    v_codleave            varchar2(100 char);
    v_timleave            number;
    v_qtyminlv            number;
    v_codcomp             tcenter.codcomp%type;
    v_codpos              temploy1.codpos%type;
    v_dteefpos            tposempd.dteefpos%type;
    v_numseq              tposempd.numseq%type;
    v_codlinef            tposempd.codlinef%type;
    v_agepos              tposempd.agepos%type;
    v_dteposdue           tposempd.dteposdue%type;
    v_flgDelete           boolean := false;
    v_flgAdd              boolean := false;
    v_flg                 varchar2(10 char);

  begin
    obj_tab1              := hcm_util.get_json_t(json_obj,'tab2');
    json_param_obj        := hcm_util.get_json_t(obj_tab1,'rows');

    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    delete tposempd where codempid = p_codempid;
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_codlinef          := hcm_util.get_string_t(json_row, 'codlinef');
      v_codcomp           := hcm_util.get_string_t(json_row, 'codcomp');
      v_codpos            := hcm_util.get_string_t(json_row, 'codpos');
      v_numseq            := hcm_util.get_string_t(json_row, 'numseq');
      v_agepos            := hcm_util.get_string_t(json_row, 'agepos');
      v_dteefpos          := to_date(hcm_util.get_string_t(json_row, 'dteefpos'),'dd/mm/yyyy');
      v_dteposdue         := to_date(hcm_util.get_string_t(json_row, 'dteposdue'),'dd/mm/yyyy');
      v_flgDelete         := hcm_util.get_boolean_t(json_row, 'flgDelete');
      if v_flgDelete then
        null;
      else
        if v_numseq is null then
          begin
            select nvl(max(numseq),0) + 1 into v_numseq
              from tposempd
             where codempid = p_codempid;
          exception when no_data_found then
            v_numseq := 1;
          end;
        end if;

        begin
          insert into tposempd (codempid,numseq,codlinef,codcomp,codpos,agepos,dteefpos,dteposdue,dtecreate,codcreate, coduser)
               values (p_codempid, v_numseq,v_codlinef,v_codcomp,v_codpos,v_agepos,v_dteefpos,v_dteposdue,sysdate, global_v_coduser , global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;
    /*for i in 0..json_param_obj .get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_codlinef          := hcm_util.get_string_t(json_row, 'codlinef');
      v_codcomp           := hcm_util.get_string_t(json_row, 'codcomp');
      v_codpos            := hcm_util.get_string_t(json_row, 'codpos');
      v_numseq            := hcm_util.get_string_t(json_row, 'numseq');
      v_agepos            := hcm_util.get_string_t(json_row, 'agepos');
      v_dteefpos          := to_date(hcm_util.get_string_t(json_row, 'dteefpos'),'dd/mm/yyyy');
      v_dteposdue         := to_date(hcm_util.get_string_t(json_row, 'dteposdue'),'dd/mm/yyyy');
      v_flgDelete         := hcm_util.get_boolean_t(json_row, 'flgDelete');
      v_flgAdd            := hcm_util.get_boolean_t(json_row, 'flgAdd');

      if v_flgDelete then
        begin
          delete tposempd
           where codempid = p_codempid
             and numseq = v_numseq;
        end;
      elsif v_flgAdd then
        if v_numseq is null then
          begin
            select nvl(max(numseq),0) + 1 into v_numseq
              from tposempd
             where codempid = p_codempid;
          exception when no_data_found then
            v_numseq := 1;
          end;
        end if;

        begin
          insert into tposempd (codempid,numseq,codlinef,codcomp,codpos,agepos,dteefpos,dteposdue,dtecreate,codcreate, coduser)
               values (p_codempid, v_numseq,v_codlinef,v_codcomp,v_codpos,v_agepos,v_dteefpos,v_dteposdue,sysdate, global_v_coduser , global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;*/
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab3_table (json_str_output out clob) is
   obj_tab2              json_object_t;
   obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_flag                varchar2(100 char);
    v_codcomp            tcenter.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_codskill            tposempctc.codskill%type;
    v_codtency            tposempctc.codtency%type;
    v_grade            tposempctc.grade%type;
    v_grdemp            tposempctc.grdemp%type;
    v_desdevp            tposempctc.desdevp%type;
    v_flg              varchar2(10 char);
    v_flgDelete          boolean;--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

  begin
    obj_tab1              := hcm_util.get_json_t(json_obj,'tab3');
    obj_tab2              := hcm_util.get_json_t(obj_tab1,'rows');--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
      v_codpos := null;
    end;
    delete tposempctc where codempid = p_codempid and codcomp = v_codcomp and codpos = v_codpos;
    for i in 0..obj_tab2.get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab2,to_char(i));
      v_codskill            := hcm_util.get_string_t(json_row, 'codskill');
      v_codtency             := hcm_util.get_string_t(json_row, 'codtency');
      v_grade             := hcm_util.get_string_t(json_row, 'grade');
      v_grdemp             := hcm_util.get_string_t(json_row, 'level');
      v_desdevp          := hcm_util.get_string_t(json_row, 'desdevp');
      v_flg                := hcm_util.get_string_t(json_row, 'flg');  
      v_flgDelete          := hcm_util.get_boolean_t(json_row, 'flgDelete');
      if v_flgDelete then
        null;
      else
        begin
          insert into tposempctc
                 (codempid,codcomp,codpos,codskill,codtency,grade,grdemp,desdevp,codcreate,coduser)
          values (p_codempid,v_codcomp,v_codpos,v_codskill,v_codtency,v_grade,v_grdemp,v_desdevp, global_v_coduser, global_v_coduser);
         end;
      end if;
    end loop;
    /*
    begin
       select codcomp,codpos
           into v_codcomp,v_codpos
           from tposempd
          where codempid = p_codempid
          and dteefpos is null
          and rownum = 1
          order by numseq;
     exception when no_data_found then
       v_codcomp := p_codcomp;
       v_codpos  := p_codpos;
     end;
    for i in 0..obj_tab1 .get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab1,to_char(i));
      v_codskill            := hcm_util.get_string_t(json_row, 'codskill');
      v_codtency             := hcm_util.get_string_t(json_row, 'codtency');
      v_grade             := hcm_util.get_string_t(json_row, 'grade');
      v_grdemp             := hcm_util.get_string_t(json_row, 'level');
      v_desdevp          := hcm_util.get_string_t(json_row, 'desdevp');
      v_flg                := hcm_util.get_string_t(json_row, 'flg');

      if v_flg = 'add' then
         begin
          insert into tposempctc
                 (codempid,codcomp,codpos,codskill,codtency,grade,grdemp,desdevp,codcreate,coduser)
          values (p_codempid,v_codcomp,v_codpos,v_codskill,v_codtency,v_grade,v_grdemp,v_desdevp, global_v_coduser, global_v_coduser);
         end;
     elsif v_flg = 'edit' then
        begin
          insert into tposempctc
                 (codempid,codcomp,codpos,codskill,codtency,grade,grdemp,desdevp,codcreate,coduser)
          values (p_codempid,v_codcomp,v_codpos,v_codskill,v_codtency,v_grade,v_grdemp,v_desdevp, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tposempctc
             set codtency   = v_codtency,
                 grade      = v_grade,
                 grdemp     = v_grdemp,
                 desdevp    = v_desdevp,
                 coduser    = global_v_coduser
           where codempid   = p_codempid
             and codcomp    = v_codcomp
             and codpos     = v_codpos
             and codskill   = v_codskill;
          end;
        elsif v_flg = 'delete' then
           delete from tposempctc
                  where codempid   = p_codempid
                  and codcomp      = v_codcomp
                  and codpos       = v_codpos
                  and codskill     = v_codskill;
        end if;
    end loop;*/
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab4_table1 (json_str_output out clob) is
   obj_tab2              json_object_t;
   obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_flag                varchar2(100 char);
    v_codcomp             tcenter.codcomp%type;
    v_codpos              temploy1.codpos%type;
    v_codcours            tposemptr.codcours%type;
    v_dtestr              tposemptr.dtestr%type;
    v_dteend               tposemptr.dteend%type;
    v_dtetrst              tposemptr.dtetrst%type;
    v_dtetren             tposemptr.dtetren%type;
    v_flg                 varchar2(10 char);
    v_flgDelete          boolean;

  begin
    obj_tab1              := hcm_util.get_json_t(json_obj,'tab4Tab1');
    obj_tab2              := hcm_util.get_json_t(obj_tab1,'rows');--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
      v_codpos := null;
    end;

    delete tposemptr where codempid = p_codempid and codcomp = v_codcomp and codpos = v_codpos ;
    for i in 0..obj_tab2.get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab2,to_char(i));
      v_codcours          := hcm_util.get_string_t(json_row, 'codcours');
      v_dtestr            := to_date(hcm_util.get_string_t(json_row, 'dtestr'),'dd/mm/yyyy');
      v_dteend            := to_date(hcm_util.get_string_t(json_row, 'dteend'),'dd/mm/yyyy');
      v_dtetrst           := to_date(hcm_util.get_string_t(json_row, 'dtetrst'),'dd/mm/yyyy');
      v_dtetren           := to_date(hcm_util.get_string_t(json_row, 'dtetrst'),'dd/mm/yyyy');
      v_flg               := hcm_util.get_string_t(json_row, 'flg');
      v_flgDelete          := hcm_util.get_boolean_t(json_row, 'flgDelete');
      if v_flgDelete then
        null;
      else
        insert into tposemptr
                 (codempid,codcomp,codpos,codcours,dtestr,dteend,dtetrst,dtetren)
          values (p_codempid,v_codcomp,v_codpos,v_codcours,v_dtestr,v_dteend,v_dtetrst,v_dtetren);
      end if;
    end loop;
    /*
    begin
       select codcomp,codpos
           into v_codcomp,v_codpos
           from tposempd
          where codempid = p_codempid
          and dteefpos is null
          and rownum = 1
          order by numseq;
     exception when no_data_found then
       v_codcomp := p_codcomp;
       v_codpos  := p_codpos;
     end;
    for i in 0..obj_tab1 .get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab1,to_char(i));
      v_codcours          := hcm_util.get_string_t(json_row, 'codcours');
      v_dtestr            := to_date(hcm_util.get_string_t(json_row, 'dtestr'),'dd/mm/yyyy');
      v_dteend            := to_date(hcm_util.get_string_t(json_row, 'dteend'),'dd/mm/yyyy');
      v_dtetrst           := to_date(hcm_util.get_string_t(json_row, 'dtetrst'),'dd/mm/yyyy');
      v_dtetren           := to_date(hcm_util.get_string_t(json_row, 'dtetrst'),'dd/mm/yyyy');
      v_flg               := hcm_util.get_string_t(json_row, 'flg');

        if v_flg = 'add' or v_flg = 'edit' then
         begin
          insert into tposemptr
                 (codempid,codcomp,codpos,codcours,dtestr,dteend,dtetrst,dtetren)
          values (p_codempid,v_codcomp,v_codpos,v_codcours,v_dtestr,v_dteend,v_dtetrst,v_dtetren);
         exception when dup_val_on_index then
          update tposemptr
           set dtestr     = v_dtestr,
               dteend     = v_dteend,
               dtetrst    = v_dtetrst,
               dtetren    = v_dtetren,
               coduser    = global_v_coduser
         where codempid   = p_codempid
           and codcomp    = v_codcomp
           and codpos     = v_codpos
           and codcours   = v_codcours;
         end;
        elsif v_flg = 'delete' then
           delete from tposemptr
                  where codempid   = p_codempid
                   and codcomp     = v_codcomp
                   and codpos      = v_codpos
                   and codcours    = v_codcours;
        end if;
    end loop;*/
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab4_table2 (json_str_output out clob) is
   obj_tab2              json_object_t;
   obj_tab1              json_object_t;
    json_param_obj       json_object_t;
    json_row             json_object_t;
    v_flag               varchar2(100 char);
    v_codcomp            tcenter.codcomp%type;
    v_codpos             temploy1.codpos%type;
    v_coddevp            tposempdev.coddevp%type;
    v_desdevp            tposempdev.desdevp%type;
    v_targetdev          tposempdev.targetdev%type;
    v_dtestr             tposempdev.dtestr%type;
    v_dteend             tposempdev.dteend%type;
    v_desresults         tposempdev.desresults%type;
    v_flg                varchar2(10 char);
    v_flgDelete          boolean;--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

  begin
    obj_tab1              := hcm_util.get_json_t(json_obj,'tab4Tab2');
    obj_tab2              := hcm_util.get_json_t(obj_tab1,'rows');--User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
      v_codpos := null;
    end;
    delete tposempdev where codempid = p_codempid and codcomp = v_codcomp and codpos = v_codpos;
    for i in 0..obj_tab2.get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab2,to_char(i));
      v_coddevp            := hcm_util.get_string_t(json_row, 'coddevp');
      v_desdevp            := hcm_util.get_string_t(json_row, 'desdevp');
      v_targetdev          := hcm_util.get_string_t(json_row, 'targetdev');
      v_dtestr             := to_date(hcm_util.get_string_t(json_row, 'dtestr'),'dd/mm/yyyy');
      v_dteend             := to_date(hcm_util.get_string_t(json_row, 'dteend'),'dd/mm/yyyy');
      v_desresults         := hcm_util.get_string_t(json_row, 'desresults');
      v_flg                := hcm_util.get_string_t(json_row, 'flg');
      v_flgDelete          := hcm_util.get_boolean_t(json_row, 'flgDelete');
      if v_flgDelete then
        null;  
      else
        insert into tposempdev
                   (codempid,codcomp,codpos,coddevp,desdevp,targetdev,dtestr,dteend,desresults)
            values (p_codempid,v_codcomp,v_codpos,v_coddevp,v_desdevp,v_targetdev,v_dtestr,v_dteend,v_desresults);
      end if;
    end loop;
    /*
    begin
       select codcomp,codpos
           into v_codcomp,v_codpos
           from tposempd
          where codempid = p_codempid
          and dteefpos is null
          and rownum = 1
          order by numseq;
     exception when no_data_found then
       v_codcomp := p_codcomp;
       v_codpos  := p_codpos;
     end;
    for i in 0..obj_tab1.get_size-1 loop
      json_row            := hcm_util.get_json_t(obj_tab1,to_char(i));
      v_coddevp            := hcm_util.get_string_t(json_row, 'coddevp');
      v_desdevp            := hcm_util.get_string_t(json_row, 'desdevp');
      v_targetdev          := hcm_util.get_string_t(json_row, 'targetdev');
      v_dtestr             := to_date(hcm_util.get_string_t(json_row, 'dtestr'),'dd/mm/yyyy');
      v_dteend             := to_date(hcm_util.get_string_t(json_row, 'dteend'),'dd/mm/yyyy');
      v_desresults         := hcm_util.get_string_t(json_row, 'desresults');
      v_flg                := hcm_util.get_string_t(json_row, 'flg');

        if v_flg = 'add' or v_flg = 'edit' then
          begin
            insert into tposempdev
                   (codempid,codcomp,codpos,coddevp,desdevp,targetdev,dtestr,dteend,desresults)
            values (p_codempid,v_codcomp,v_codpos,v_coddevp,v_desdevp,v_targetdev,v_dtestr,v_dteend,v_desresults);
          exception when dup_val_on_index then
            begin
              update tposempdev
               set desdevp     = v_desdevp,
                   targetdev   = v_targetdev,
                   dtestr      = v_dtestr,
                   dteend      = v_dteend,
                   desresults  = v_desresults,
                   coduser     = global_v_coduser
             where codempid    = p_codempid
               and codcomp     = v_codcomp
               and codpos      = v_codpos
               and coddevp    = v_coddevp;
            end;
          end;
        elsif v_flg = 'delete' then
          begin
            delete from tposempdev
                    where codempid    = p_codempid
                      and codcomp     = v_codcomp
                      and codpos      = v_codpos
                      and coddevp   = v_coddevp;
          end;
        end if;

    end loop;*/
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

--<< user25 Date: 07/09/2021 1. RP Module #4564
  procedure check_save is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_temp      varchar2(10 char);
    v_flgSecur  boolean;
  begin
        begin
          select 'X' , staemp
          into v_temp, v_staemp
            from temploy1
           where codempid = p_codreview;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        end;

          if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;

      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
  end;
-->> user25 Date: 07/09/2021 1. RP Module #456

  procedure post_save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_save;--<< user25 Date: 07/09/2021 1. RP Module #4564
    json_obj      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');


    if param_msg_error is null then
      save_tab1_detail (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab2_table (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab3_table (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab4_table1 (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab4_table2 (json_str_output);
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_save_detail;

  procedure gen_path_no(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result            json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
--    v_dteeffec          date;

    v_numseq            varchar2(100 char);
    v_codlinef           varchar2(2000 char);
    v_desc_codlinef     varchar2(4000 char);
    v_codcomp           varchar2(2000 char);
    v_desc_codcomp      varchar2(4000 char);
    v_codpos           varchar2(2000 char);
    v_desc_codpos      varchar2(4000 char);
    v_othdetail      varchar2(4000 char);
    v_agepos         varchar2(100 char);
    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    --v_numpath           varchar2(100 char) := '';
    --v_dteeffec         varchar2(2000 char);
    v_codcompy      tposplnh.codcompy%type;
    v_numpath       tposplnh.numpath%type;
    v_dteeffec      tposplnh.dteeffec%type;
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    cursor c_com_pos is
      select a.numpath, decode(global_v_lang,'101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec --<< user25 Date : 09/09/2021 1. RP Module #4549
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq) --User37 #4561 #4559 #4552 1. RP Module 16/12/2021 and b.numseq >= (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos      = p_codpos)
      order by a.numpath, b.numseq;

      --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
      cursor c1 is
        select numseq,codlinef,codcompy,codcomp,codpos,agepos,othdetail
          from tposplnd a
          where a.codcompy  = v_codcompy
            and a.numpath   = v_numpath
            and a.dteeffec  = v_dteeffec
            and a.numseq > (select min(b.numseq) --User37 #4561 #4559 #4552 1. RP Module 16/12/2021 and b.numseq >= (select min(d.numseq)
                                from tposplnd b
                              where b.codcompy  = a.codcompy
                                 and b.numpath    =  a.numpath
                                 and b.dteeffec     = a.dteeffec
                                 and b.codcomp = p_codcomp
                                 and b.codpos      = p_codpos)
        order by numpath,numseq;

    begin
        obj_result := json_object_t;
        obj_row := json_object_t();

        --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
        for r1 in c_com_pos loop
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          if v_numpath is null or v_numpath <> r1.numpath then
            v_codcompy := r1.codcompy;
            v_numpath  := r1.numpath;
            v_dteeffec := r1.dteeffec;
            for i in c1 loop
              if check_gap(p_codempid,i.codcomp,i.codpos) = 'N' then
              obj_data.put('numpath',r1.numpath);
              obj_data.put('numseq',i.numseq);
              obj_data.put('codlinef',i.codlinef);
              obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,i.codlinef,global_v_lang));
              obj_data.put('codcomp',i.codcomp);
              obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
              obj_data.put('codpos',i.codpos);
              obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
              obj_data.put('agepos',i.agepos);
              obj_data.put('othdetail',i.othdetail);
              obj_data.put('dteeffec',to_char(r1.dteeffec, 'dd/mm/yyyy'));
              obj_data.put('flgDisabledCareer','Y'); --Y = เปิด Tab ปกติ /N = ปิดเเท้บ --<<user25 Date:30/09/2021  #4564
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
              exit;
              end if;
            end loop;
            v_numpath := r1.numpath;
          end if;
        end loop;
        /*begin
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            if p_codcomp is not null and p_codpos is not null then
              for r1 in c_com_pos loop
                v_found_count := v_found_count+1;
               if v_numpath is null or v_numpath = r1.numpath then
--<< user25 Date : 08/09/2021 1. RP Module #4549
--                v_numseq := v_numseq || '<br>' || r1.numseq || '</br>';
--                v_codlinef := v_codlinef || '<br>' || r1.codlinef || '</br>';
--                v_desc_codlinef := v_desc_codlinef || '<br>' || get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang) || '</br>';
--                v_codcomp := v_codcomp || '<br>' || r1.codcomp || '</br>';
--                v_desc_codcomp := v_desc_codcomp || '<br>' || get_tcenter_name(r1.codcomp,global_v_lang) || '</br>';
--                v_codpos := v_codpos || '<br>' || r1.codpos || '</br>';
--                v_desc_codpos := v_desc_codpos || '<br>' || get_tpostn_name(r1.codpos,global_v_lang) || '</br>';
--                v_othdetail := v_othdetail || '<br>' || r1.othdetail || '</br>';
--                v_agepos := v_agepos || '<br>' || r1.agepos || '</br>';
--                v_dteeffec := v_dteeffec || '<br>' || to_char(r1.dteeffec, 'dd/mm/yyyy') || '</br>';
--                v_numpath := r1.numpath;

                v_numseq := v_numseq || r1.numseq || '</br>';
                v_codlinef := v_codlinef || r1.codlinef || '</br>';
                v_desc_codlinef := v_desc_codlinef ||  get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang) || '</br>';
                v_codcomp := v_codcomp ||r1.codcomp || '</br>';
                v_desc_codcomp := v_desc_codcomp ||  get_tcenter_name(r1.codcomp,global_v_lang) || '</br>';
                v_codpos := v_codpos ||  r1.codpos || '</br>';
                v_desc_codpos := v_desc_codpos ||  get_tpostn_name(r1.codpos,global_v_lang) || '</br>';
                v_othdetail := v_othdetail ||  r1.othdetail || '</br>';
--              v_agepos := v_agepos || r1.agepos || '</br>';
                v_agepos := v_agepos || round(r1.agepos/12)||' ('||mod(r1.agepos,12)||')' || '</br>';
                v_dteeffec := v_dteeffec ||  to_char(r1.dteeffec, 'dd/mm/yyyy') || '</br>';
                v_numpath := r1.numpath;
-->>  user25 Date : 08/09/2021 1. RP Module #4549
               else
                obj_data.put('numpath',v_numpath);
                obj_data.put('numseq',v_numseq);
                obj_data.put('codlinef',v_codlinef);
                obj_data.put('desc_codlinef',v_desc_codlinef);
                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',v_desc_codcomp);
                obj_data.put('codpos',v_codpos);
                obj_data.put('desc_codpos',v_desc_codpos);
                obj_data.put('agepos',v_agepos);
                obj_data.put('othdetail',v_othdetail);
                obj_data.put('dteeffec',v_dteeffec);
                obj_data.put('flgDisabledCareer','Y'); --Y = เปิด Tab ปกติ /N = ปิดเเท้บ --<<user25 Date:30/09/2021  #4564
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
                v_numseq := '';
                v_codlinef := '';
                v_desc_codlinef := '';
                v_codcomp := '';
                v_desc_codcomp := '';
                v_codpos := '';
                v_desc_codpos := '';
                v_othdetail := '';
                v_agepos := '';
                v_dteeffec := '';
                v_numpath := r1.numpath;
               end if;

              end loop;

             if nvl(v_found_count,0) > 0 then
                obj_data.put('numpath',v_numpath);
                obj_data.put('numseq',v_numseq);
                obj_data.put('codlinef',v_codlinef);
                obj_data.put('desc_codlinef',v_desc_codlinef);
                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',v_desc_codcomp);
                obj_data.put('codpos',v_codpos);
                obj_data.put('desc_codpos',v_desc_codpos);
                obj_data.put('agepos',v_agepos);
                obj_data.put('othdetail',v_othdetail);
                obj_data.put('dteeffec',v_dteeffec);
                obj_data.put('flgDisabledCareer','Y'); --Y = เปิด Tab ปกติ /N = ปิดเเท้บ --<<user25 Date:30/09/2021  #4564
                obj_row.put(to_char(v_row), obj_data);
             end if;

            end if;

        exception when others then null;
        end;*/
        -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 

        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := obj_row.to_clob;
        end if;

  end gen_path_no;

  procedure get_path_no(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_path_no(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_dteefpos      temploy1.dteefpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_dteposdue     date;
    v_agepos        varchar2(10);--<< user25 Date : 28/09/2021 #4549
    --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
    obj_rowtab2     json_object_t;
    obj_rowtab3d    json_object_t;
    obj_rowtab3t    json_object_t;
    obj_rowtab41    json_object_t;
    obj_rowtab42    json_object_t;
    obj_datatab2    json_object_t;
    obj_datatab3d   json_object_t;
    obj_datatab3t   json_object_t;
    obj_datatab41   json_object_t;
    obj_datatab42   json_object_t;
    obj_datarows    json_object_t;

    cursor c1 is
      select a.numpath, decode(global_v_lang,'101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
          and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec --<< user25 Date : 28/09/2021 #4549
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq >= (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                -- and d.codcomp like p_codcomp || '%'
                                 and d.codcomp = p_codcomp
                                 and d.codpos      = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;

--    cursor c1 is
--      select  numseq, codlinef, codcompy,codcomp, codpos, othdetail, agepos
--        from tposplnd
--        where codcomp = p_codcomp
--          and codpos = p_codpos
--          and numpath = p_numpath
--          and numseq >= (select min(d.numseq)
--                                from tposplnd d
--                              where
--                                  d.codcomp like p_codcomp || '%'
--                                 and d.codpos      = p_codpos
--                                 and d.numpath = p_numpath) ;
    begin

      --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
      /*obj_row := json_object_t();
      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef);
        obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('agepos',r1.agepos);

        begin
          select dteefpos
            into v_dteefpos
          from temploy1
          where codempid  =  p_codempid
          and codpos      =  p_codpos
          and codcomp     =  p_codcomp;
        exception when no_data_found then
          v_dteefpos := null;
        end;
        obj_data.put('dteefpos',to_char(v_dteefpos, 'dd/mm/yyyy'));
        if v_dteefpos is not null then
          v_dteposdue := ADD_MONTHS( v_dteefpos, r1.agepos );
        end if;
        obj_data.put('dteposdue',to_char(v_dteposdue, 'dd/mm/yyyy'));
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;*/

    obj_data := json_object_t();
    obj_rowtab2 := json_object_t();
    obj_datarows := json_object_t();
    v_row := 0;
    for i in 1..5 loop
      v_row := v_row + 1;
      obj_datatab2 := json_object_t();
      obj_datatab2.put('agepos', 13);
      obj_datatab2.put('codcomp','0004000200020002000000000000000000000000');
      obj_datatab2.put('codlinef', '0004');
      obj_datatab2.put('codpos', '0030');
      obj_datatab2.put('desc_codcomp', 'แผนกขายและการตลาด');
      obj_datatab2.put('desc_codlinef', 'สาย Quality Assurance (สาย 0004)');
      obj_datatab2.put('desc_codpos', 'Sale');
      obj_datatab2.put('dteefpos','11/11/2010');
      obj_datatab2.put('dteposdue','11/12/2011');
      obj_datatab2.put('numseq', i);
      obj_rowtab2.put(to_char(v_row-1),obj_datatab2);
    end loop;
    obj_datarows.put('rows', obj_rowtab2);
    obj_data.put('tab2', obj_datarows);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_path(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_path(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;


--<< user25 Date : 08/09/2021 1. RP Module #4561
  procedure gen_codtency(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_dteefpos      temploy1.dteefpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_dteposdue     date;
    v_codcomp       tcenter.codcomp%type;
    v_codtency      tcompskil.codtency%type;
    v_grade         tjobposskil.grade%type;

   cursor c1 is
     select  codtency
       from  tcompskil
      where  codskill  = p_codskill
   order by  codtency;

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = p_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;


   cursor c3 is
    select  b.codtency,a.grade
      from  tjobposskil a, tcompskil b
     where  a.codtency  = b.codtency
       and  a.codskill  = b.codskill
      and   b.codskill  = p_codskill
      and   a.codpos    = v_codpos
      and   a.codcomp   = v_codcomp
       order by b.codtency,a.grade;

    begin
      for r1 in c1 loop
        v_codtency := r1.codtency;
       end loop;

       for r2 in c2 loop
        v_codcomp := r2.codcomp;
        v_codpos  := r2.codpos;
       end loop;

      obj_row := json_object_t();
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      for r1 in c1 loop
        obj_data.put('codtency',r1.codtency);

            begin
             select grade
               into v_grade
              from  tjobposskil
             where  codskill  = p_codskill
              and   codpos    = v_codpos
              and   codcomp   = v_codcomp
              and   codtency  = v_codtency;
            exception when no_data_found then
             v_grade := null;
            end;
        obj_data.put('grade',v_grade);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
      end loop;


    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

/*
      procedure gen_codtency(json_str_output out clob)as
        obj_data        json_object_t;
        obj_row         json_object_t;
        v_codempid      temploy1.codempid%type;
        v_codcompy      tcenter.codcompy%type;
        v_codpos        temploy1.codpos%type;
        v_dteefpos      temploy1.dteefpos%type;
        v_count         number := 0;
        v_row           number := 0;
        v_dteposdue     date;

       cursor c1 is
          select b.codtency,a.grade
             from tjobposskil a, tcompskil b;

        begin

          obj_row := json_object_t();
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          for r1 in c1 loop
            obj_data.put('codtency',r1.codtency);
            obj_data.put('grade',r1.grade);
            obj_row.put(to_char(v_row), obj_data);
            v_row := v_row + 1;
          end loop;

        if param_msg_error is null then
          json_str_output := obj_row.to_clob;
        else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end;
*/
-->> user25 Date : 08/09/2021 1. RP Module #4561


  procedure get_codtency(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_codtency(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_detail(json_str_output out clob)as
    obj_data        json_object_t;

    v_count         number := 0;


  begin

      begin
        delete from tposemph
             where codempid = p_codempid;
      exception when others then
        null;
      end;

      begin
        delete from tposempd
             where codempid = p_codempid;
      exception when others then
        null;
      end;

      begin
        delete from tposempctc
             where codempid = p_codempid;
      exception when others then
        null;
      end;

      begin
        delete from tposemptr
             where codempid = p_codempid;
      exception when others then
        null;
      end;

      begin
        delete from tposempdev
             where codempid = p_codempid;
      exception when others then
        null;
      end;

    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
      end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure post_delete_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path_plan_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;

      cursor c1 is
        select codlinef
          from tposempd
          where codempid = p_codempid
          group by codlinef;--<< user25 Date : 09/09/2021 1. RP Module  #4559
      -- order by numseq;--<< user25 Date : 09/09/2021 1. RP Module  #4559

    begin
        obj_result := json_object_t;
        obj_row := json_object_t();

        for r1 in c1 loop
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('itemkey',r1.codlinef);
          obj_row.put(to_char(v_row), obj_data);
          v_row        := v_row + 1;
        end loop;

        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := obj_row.to_clob;
        end if;

    end;

  procedure get_career_path_plan_table (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            gen_career_path_plan_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path_plan(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_dteupd        date;
    v_numlevel      thisorg2.numlevel%type;
    v_row           number:=0;
    v_pre_codlinef  tposplnd.codlinef%type := '';
    v_flgCurrent    varchar2(3 char) := '';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    cursor c1 is
      select  codlinef, numseq, codcomp, codpos
        from tposempd
        where codempid = p_codempid
        order by numseq;
  begin
      obj_row := json_object_t();
      v_pre_codlinef := '';

      begin
        select codcomp,codpos
          into v_codcomp,v_codpos
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
       v_codcomp := null;
       v_codpos  := null;
      end;

      for r1 in c1 loop
        v_flgCurrent := '';
        if r1.codcomp = v_codcomp and r1.codpos = v_codpos then
          v_flgCurrent := 'Y';
        end if;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef);
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('previousCodlinef',v_pre_codlinef);
        obj_data.put('flgCurrent',v_flgCurrent);
        v_pre_codlinef := r1.codlinef;

        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_path_plan(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_path_plan(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  procedure gen_career_tab2(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;
    v_row           number := 0;
    v_dteefpos      temploy1.dteefpos%type;
    v_chk           varchar2(1 char) := 'N';

    cursor c1 is
      select numseq, codlinef, codcomp, codpos,  dteefpos, dteposdue
        from tposempd
       where codempid = p_codempid
      order by numseq;

    cursor c2 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq >= (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;

    cursor c3 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;
  begin
        begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into v_codcompy
            from temploy1
            where codempid = p_codempid;
          exception when no_data_found then
               null;
          end;


        obj_row := json_object_t();

      for r1 in c1 loop
        v_count := 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        begin
            select dteefpos
             into v_dteefpos
             from temploy1
            where codempid = p_codempid
            and codpos = r1.codpos;
          exception when no_data_found then
               v_dteefpos := null;
          end;
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef);
        obj_data.put('desc_codlinef',get_tfunclin_name(v_codcompy,r1.codlinef,global_v_lang));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('dteefpos',to_char(nvl(r1.dteefpos,v_dteefpos), 'dd/mm/yyyy'));
        obj_data.put('dteposdue',to_char(r1.dteposdue, 'dd/mm/yyyy'));
        if nvl(r1.dteefpos,v_dteefpos) is null then
          v_chk := 'Y';
        end if;
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;
      if v_count = 0 then
        v_row        := 0;
        for r2 in c2 loop
          if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' or (p_codcomp = r2.codcomp and p_codpos = r2.codpos) then
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          begin
            select dteefpos
             into v_dteefpos
             from temploy1
            where codempid = p_codempid
            and codpos = r2.codpos;
          exception when no_data_found then
            v_dteefpos := null;
          end;
          v_row        := v_row + 1;
          obj_data.put('numseq',v_row);
          obj_data.put('codlinef',r2.codlinef);
          obj_data.put('desc_codlinef',get_tfunclin_name(v_codcompy,r2.codlinef,global_v_lang));
          obj_data.put('codcomp',r2.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(r2.codcomp,global_v_lang));
          obj_data.put('codpos',r2.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r2.codpos,global_v_lang));
          obj_data.put('dteefpos',to_char(v_dteefpos, 'dd/mm/yyyy'));
          obj_data.put('dteposdue','');
          obj_data.put('flgAdd',true);
          obj_row.put(to_char(v_row-1), obj_data);
          end if;
          if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' then
            exit;
          end if;
        end loop;
      else
        if v_chk = 'N' then
          for r3 in c3 loop
            if check_gap(p_codempid,r3.codcomp,r3.codpos) = 'N' then
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              begin
                select dteefpos
                  into v_dteefpos
                  from temploy1
                 where codempid = p_codempid
                   and codpos = r3.codpos;
              exception when no_data_found then
                v_dteefpos := null;
              end;
              v_row        := v_row + 1;
              obj_data.put('numseq',v_row);
              obj_data.put('codlinef',r3.codlinef);
              obj_data.put('desc_codlinef',get_tfunclin_name(v_codcompy,r3.codlinef,global_v_lang));
              obj_data.put('codcomp',r3.codcomp);
              obj_data.put('desc_codcomp',get_tcenter_name(r3.codcomp,global_v_lang));
              obj_data.put('codpos',r3.codpos);
              obj_data.put('desc_codpos',get_tpostn_name(r3.codpos,global_v_lang));
              obj_data.put('dteefpos',to_char(v_dteefpos, 'dd/mm/yyyy'));
              obj_data.put('dteposdue','');
              obj_data.put('flgAdd',true);
              obj_row.put(to_char(v_row-1), obj_data);
              exit;
            end if;
          end loop;
        end if;
      end if;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_tab2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_tab3(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;
    v_row           number := 0;

    cursor c1 is
      select descdevp
        from tposemph
       where codempid = p_codempid;

    cursor c2 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;
    begin
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      for r2 in c2 loop
        if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' then
          obj_data.put('codcomp',r2.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(r2.codcomp,global_v_lang));
          obj_data.put('codpos',r2.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r2.codpos,global_v_lang));
          obj_data.put('flgAdd',true);
          exit;
        end if;
      end loop;

      for r1 in c1 loop
        obj_data.put('descdevp',r1.descdevp);
        exit;
      end loop;

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_tab3(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_tab3_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_grade         tcmptncy.grade%type;
    v_count         number := 0;
    v_row           number := 0;

    cursor c1 is
      select codtency,codskill,grade
        from tjobposskil
       where codcomp = v_codcomp
         and codpos = v_codpos
        order by codtency,codskill;

    cursor c2 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;
  begin
    obj_row := json_object_t();

    for r2 in c2 loop
      if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' then
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
        exit;
      end if;
    end loop;

    for r1 in c1 loop
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codskill',r1.codskill);
      obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
      obj_data.put('codtency',r1.codtency);
      obj_data.put('grade',r1.grade);
      obj_data.put('gradehide',r1.grade);
      obj_data.put('flgAdd',true);

      begin
        select grade
          into v_grade
          from tcmptncy
         where codempid = p_codempid
           and codtency = r1.codskill;
      exception when no_data_found then
        v_grade := null;
      end;
      obj_data.put('level',v_grade);
      obj_data.put('gap',(r1.grade - nvl(v_grade,0)));
      obj_data.put('desdevp',' ');
      obj_row.put(to_char(v_row), obj_data);
      v_row        := v_row + 1;
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_tab3_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_tab3_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

 procedure gen_career_tab4_table1(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_grade         tjobposskil.grade%type;
    v_grade_emp     tcmptncy.grade%type;
    v_codcours      tcomptcr.codcours%type;
    v_codskill      tcomptcr.codskill%type;

    cursor c1 is
      select codtency,codskill,grade
        from tjobposskil
       where codcomp = v_codcomp
         and codpos = v_codpos
        order by codtency,codskill;

    cursor c2 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;

    cursor c3 is
      select codcours
        from tcomptcr
       where codskill = v_codskill
         and grade between (v_grade_emp+1) and v_grade
      group by codcours
      order by codcours;

  begin
    obj_row := json_object_t();

    for r2 in c2 loop
      if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' then
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
        exit;
      end if;
    end loop;

    for r1 in c1 loop
      begin
        select grade
          into v_grade_emp
          from tcmptncy
         where codempid = p_codempid
           and codtency = r1.codskill;
      exception when no_data_found then
        v_grade_emp := 0;
      end;

      v_codskill    := r1.codskill;
      v_grade_emp   := v_grade_emp;
      v_grade       := r1.grade;

      for r3 in c3 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcours',r3.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(r3.codcours,global_v_lang));
        obj_data.put('dtestr','');
        obj_data.put('dteend','');
        obj_data.put('dtetrst','');
        obj_data.put('flgAdd',true);
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_tab4_table1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_tab4_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_tab4_table2(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_count         number := 0;
    v_row           number := 0;
    v_grade         tjobposskil.grade%type;

    v_grade_emp     tcmptncy.grade%type;
    v_codcours      tcomptcr.codcours%type;
    v_codskill      tcomptdev.codskill%type;

    cursor c1 is
      select codtency,codskill,grade
        from tjobposskil
       where codcomp = v_codcomp
         and codpos = v_codpos
        order by codtency,codskill;

    cursor c2 is
      select a.numpath, decode('102','101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and b.numpath = p_numpath
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq > (select min(d.numseq)
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp = p_codcomp
                                 and d.codpos  = p_codpos
                                 and d.numpath = p_numpath)
       order by a.numpath, b.numseq;

    cursor c3 is
      select coddevp
        from tcomptdev
       where codskill = v_codskill
         and grade between (v_grade_emp+1) and v_grade
      group by coddevp
      order by coddevp;

  begin
    obj_row := json_object_t();

    for r2 in c2 loop
      if check_gap(p_codempid,r2.codcomp,r2.codpos) = 'N' then
        v_codcomp := r2.codcomp;
        v_codpos := r2.codpos;
        exit;
      end if;
    end loop;

    for r1 in c1 loop
      begin
        select grade
          into v_grade_emp
          from tcmptncy
         where codempid = p_codempid
           and codtency = r1.codskill;
      exception when no_data_found then
        v_grade_emp := 0;
      end;

      v_codskill    := r1.codskill;
      v_grade_emp   := v_grade_emp;
      v_grade       := r1.grade;

      for r3 in c3 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('coddevp',r3.coddevp);
        obj_data.put('desc_coddevp',get_tcodec_name('TCODDEVT',r3.coddevp,global_v_lang));
        obj_data.put('targetdev','');
        obj_data.put('desdevp','');
        obj_data.put('dtestr','');
        obj_data.put('dteend','');
        obj_data.put('desresults','');
        obj_data.put('flgAdd',true);
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end loop;
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_career_tab4_table2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_tab4_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  function check_gap(pa_codempid in varchar,pa_codcomp in varchar2,pa_codpos in varchar2) return varchar2 is
    v_gap   varchar2(1 char) := 'Y';
    v_grade tjobposskil.grade%type;
    cursor c1 is
      select codtency,codskill,grade,score
        from tjobposskil
       where codpos = pa_codpos
         and codcomp = pa_codcomp
        order by codtency,codskill;
  begin
    for i in c1 loop
      begin
        select grade
          into v_grade
          from tcmptncy
         where codempid = pa_codempid
           and codtency = i.codskill;
      exception when no_data_found then
        v_grade := null;
      end;
      if nvl(v_grade,0) < nvl(i.grade,0) then
        v_gap := 'N';
        exit;
      end if;
    end loop;
    return v_gap;
  end check_gap;
  -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
end hrrp19e;

/
