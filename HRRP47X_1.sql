--------------------------------------------------------
--  DDL for Package Body HRRP47X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP47X" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_detail is
    v_codempid  tposemph.codempid%type;
    v_secur  boolean := false;
  begin
    begin
      select codempid into v_codempid
        from tposemph
       where codempid = b_index_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPOSEMPH');
      return;
    end;
  end;


  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;

    cursor c1 is
      select codcomp, codpos, codreview, dtereview, shorttrm, midterm, longtrm,
             descstr, descweek, descoop, descthreat,descdevp
        from tposemph
       where codempid = b_index_codempid;

  begin

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',b_index_codempid);

      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('codreview',r1.codreview);
        obj_data.put('desc_codreview',get_temploy_name(r1.codreview,global_v_lang));
        obj_data.put('dtereview',to_char(r1.dtereview, 'dd/mm/yyyy'));
        obj_data.put('shorttrm',r1.shorttrm);
        obj_data.put('midterm',r1.midterm);
        obj_data.put('longtrm',r1.longtrm);
        obj_data.put('descstr',r1.descstr);
        obj_data.put('descweek',r1.descweek);
        obj_data.put('descoop',r1.descoop);
        obj_data.put('descthreat',r1.descthreat);
        obj_data.put('descdevp',r1.descdevp);
      exit;
      end loop;

      if v_count = 0 then
          begin
            select codcomp,codpos
              into v_codcomp,v_codpos
            from temploy1
            where codempid = b_index_codempid;
            obj_data.put('codcomp',v_codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
            obj_data.put('codpos',v_codpos);
            obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
          exception when no_data_found then
            obj_data.put('codcomp','');
            obj_data.put('desc_codcomp','');
            obj_data.put('codpos','');
            obj_data.put('desc_codpos','');
          end;
        end if;

        if isInsertReport then
          obj_data.put('item1','DETAIL');
          insert_ttemprpt(obj_data);
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

  procedure gen_table1(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcompy      tcenter.codcompy%type;
    v_codpos        temploy1.codpos%type;
    v_coduser       tusrprof.coduser%type;
    v_count         number := 0;
    v_row           number := 0;

    cursor c1 is
      select  numseq, codlinef, codcomp, codpos,  dteefpos, dteposdue
        from tposempd
        where codempid = b_index_codempid;
  begin
        begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into v_codcompy
            from temploy1
            where codempid = b_index_codempid;
          exception when no_data_found then
            null;
          end;
        obj_row := json_object_t();
      for r1 in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('desc_codlinef',get_tfunclin_name(v_codcompy,r1.codlinef,global_v_lang));
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('dteefpos',to_char(r1.dteefpos, 'dd/mm/yyyy'));
        obj_data.put('dteposdue',to_char(r1.dteposdue, 'dd/mm/yyyy'));
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;

         if isInsertReport then
          obj_data.put('item1','TABLE1');
          obj_data.put('item2',b_index_codempid);
          obj_data.put('item3',v_count);
          obj_data.put('item4',get_tfunclin_name(v_codcompy,r1.codlinef,global_v_lang));
          obj_data.put('item5',get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('item6',get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('item7',hcm_util.get_date_buddhist_era(r1.dteefpos));
          obj_data.put('item8',hcm_util.get_date_buddhist_era(r1.dteposdue));
          insert_ttemprpt_table(obj_data);
        end if;
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

  procedure get_table1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_table2(json_str_output out clob)as
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
      select  codcours,dtestr,dteend,dtetrst
         from tposemptr
        where codempid = b_index_codempid
        and codcomp = v_codcomp
        and codpos = v_codpos
        order by codcours;

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = b_index_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;


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

        if isInsertReport then
          obj_data.put('item1','TABLE2');
          obj_data.put('item2',b_index_codempid);
          obj_data.put('item3',v_count);
          obj_data.put('item4',r1.codcours);
          obj_data.put('item5',get_tcourse_name(r1.codcours,global_v_lang));
          obj_data.put('item6',hcm_util.get_date_buddhist_era(r1.dtestr));
          obj_data.put('item7',hcm_util.get_date_buddhist_era(r1.dteend));
          obj_data.put('item8',hcm_util.get_date_buddhist_era(r1.dtetrst));
          insert_ttemprpt_table(obj_data);
        end if;

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

  procedure get_table2(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_table3(json_str_output out clob)as
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
      select  coddevp,desdevp,targetdev,dtestr,dteend,desresults
         from tposempdev
        where codempid = b_index_codempid
        and codcomp = v_codcomp
        and codpos = v_codpos;

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = b_index_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;


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
        obj_data.put('desdevp',r1.desdevp);
        obj_data.put('targetdev',r1.targetdev);
        obj_data.put('dtestr',to_char(r1.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('desresults',r1.desresults);
        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;

         if isInsertReport then
          obj_data.put('item1','TABLE3');
          obj_data.put('item2',b_index_codempid);
          obj_data.put('item3',v_count);
          obj_data.put('item4',r1.coddevp);
          obj_data.put('item5',get_tcodec_name('TCODDEVT',r1.coddevp,global_v_lang));
          obj_data.put('item6',r1.desdevp);
          obj_data.put('item7',r1.targetdev);
          obj_data.put('item8',hcm_util.get_date_buddhist_era(r1.dtestr));
          obj_data.put('item9',hcm_util.get_date_buddhist_era(r1.dteend));
          obj_data.put('item10',r1.desresults);
          insert_ttemprpt_table(obj_data);
        end if;

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

  procedure get_table3(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure get_graph (json_str_input in clob, json_str_output out clob) as
    obj_main        json_object_t;
    obj_sub         json_object_t;
    obj_row         json_object_t;

    obj_result      json_object_t;

    main_dataX      json_object_t;
    main_dataY1     json_object_t;
    main_dataY2     json_object_t;
    obj_dataY1      json_object_t;
    obj_dataY2      json_object_t;

    obj_sub_dataY   json_object_t;
    obj_row_sub     json_object_t;
    data_row_sub    json_object_t;
    sub_dataX       json_object_t;
    sub_dataY       json_object_t;

    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codtency      tposempctc.codtency%type;
    v_count         number := 0;
    v_row           number := 0;
    v_row2          number := 0;
    v_numseq        number := 1;
    v_codapp        varchar2(10 char) := 'HRRP47X';
    cursor c1 is
      select  codempid, codcomp, codpos, codskill, codtency, grade, grdemp, desdevp
         from tposempctc
        where codempid = b_index_codempid
        and codcomp = v_codcomp
        and codpos = v_codpos;

    cursor c2 is
      select codcomp,codpos
         from tposempd
        where codempid = b_index_codempid
        and dteefpos is null
        and rownum = 1
        order by numseq;

    cursor c3 is
      select distinct codempid, codcomp, codpos, codtency
        from tposempctc
       where codempid = b_index_codempid
         and codcomp = v_codcomp
         and codpos = v_codpos
       group by codempid, codcomp, codpos, codtency;

    cursor c4 is
      select codskill, codtency, grade, grdemp
        from tposempctc
       where codempid = b_index_codempid
         and codcomp = v_codcomp
         and codpos = v_codpos
         and codtency = v_codtency;
  begin
    for r2 in c2 loop
      v_codcomp := r2.codcomp;
      v_codpos := r2.codpos;
    end loop;

    obj_row := json_object_t();

    main_dataY1 := json_object_t();
    main_dataY2 := json_object_t();
    main_dataX := json_object_t();

    for r1 in c1 loop
      main_dataY1.put(to_char(v_row),r1.grade);
      main_dataY2.put(to_char(v_row),r1.grdemp);
      main_dataX.put(to_char(v_row),r1.codskill);

      v_row := v_row + 1;
    end loop;

    obj_sub  := json_object_t();
    for r3 in c3 loop
      v_codtency := r3.codtency;

      sub_dataY  := json_object_t();
      sub_dataX  := json_object_t();
      v_row2 := 0;
      for r4 in c4 loop
        sub_dataY.put(to_char(v_row2),r4.grdemp);
        sub_dataX.put(to_char(v_row2),r4.codskill);
        v_row2 := v_row2 + 1;
      end loop;
      obj_sub_dataY := json_object_t();
      obj_sub_dataY.put('label','');
      obj_sub_dataY.put('data',sub_dataY);

      obj_row := json_object_t();
      obj_row.put(0, obj_sub_dataY);

      obj_row_sub  := json_object_t();
      obj_row_sub.put('head',v_codtency);
      obj_row_sub.put('dataY',obj_row);
      obj_row_sub.put('dataX',sub_dataX);

      obj_sub.put(v_count,obj_row_sub);
      v_count := v_count + 1;
    end loop;

    obj_dataY1 := json_object_t();
    obj_dataY1.put('label',get_label_name('HRRP47X1',global_v_lang,460));
    obj_dataY1.put('data',main_dataY1);

    obj_dataY2 := json_object_t();
    obj_dataY2.put('label',get_label_name('HRRP47X1',global_v_lang,470));
    obj_dataY2.put('data',main_dataY2);

    obj_row := json_object_t();
    obj_row.put(0, obj_dataY1);
    obj_row.put(1, obj_dataY2);

    obj_main  := json_object_t();
    obj_main.put('dataY',obj_row);
    obj_main.put('dataX',main_dataX);

    data_row_sub := json_object_t();
    data_row_sub.put('rows',obj_sub);

    obj_result := json_object_t();
    obj_result.put('coderror','200');
    obj_result.put('mainGraph',obj_main);
    obj_result.put('subGraph',data_row_sub);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;


      cursor c1 is
        select distinct codlinef
          from tposempd
          where codempid = b_index_codempid
       order by codlinef;

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

    end gen_career_path_table;

  procedure get_career_path_table (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            gen_career_path_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path(json_str_output out clob)as
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
        where codempid = b_index_codempid
        order by numseq;
  begin
      obj_row := json_object_t();
      v_pre_codlinef := '';

      begin
        select codcomp,codpos
          into v_codcomp,v_codpos
        from temploy1
        where codempid = b_index_codempid;
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

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      gen_detail(json_output);
      gen_table1(json_output);
      gen_table2(json_output);
      gen_table3(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_image           tempimge.namimage%type;
    v_folder           tfolderd.folder%type;
    v_has_image        varchar2(1) := 'N';
    v_image2           tempimge.namimage%type;
    v_folder2           tfolderd.folder%type;
    v_has_image2        varchar2(1) := 'N';
    v_codreview        temploy1.codempid%type := '';


    v_codempid          varchar2(100 char) := '';
    v_codcomp           temploy1.codcomp%type;
    v_codpos           temploy1.codpos%type;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;
    v_item11      ttemprpt.item11%type;
    v_item12      ttemprpt.item12%type;
    v_item13      ttemprpt.item13%type;
    v_item14      ttemprpt.item14%type;
    v_item15      ttemprpt.item15%type;

  begin

    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_item3        := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), '');
    v_codpos       := nvl(hcm_util.get_string_t(obj_data, 'codpos'), '');
    v_item7         := nvl(hcm_util.get_string_t(obj_data, 'descstr'), '');
    v_item8         := nvl(hcm_util.get_string_t(obj_data, 'descweek'), '');
    v_item9         := nvl(hcm_util.get_string_t(obj_data, 'descoop'), '');
    v_item10         := nvl(hcm_util.get_string_t(obj_data, 'descthreat'), '');
    v_item11         := nvl(hcm_util.get_string_t(obj_data, 'descdevp'), '');
    v_codreview      := nvl(hcm_util.get_string_t(obj_data, 'codreview'), '');
    v_item12         := nvl(hcm_util.get_string_t(obj_data, 'desc_codreview'), '');
    v_item13         := nvl(hcm_util.get_string_t(obj_data, 'dtereview'), '');

    if v_item13 is not null then
      v_item13 := hcm_util.get_date_buddhist_era(to_date(v_item13,'dd/mm/yyyy'));
    end if;
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;

       begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image
          from tempimge
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_image := null;
      end;

      if v_image is not null then
        v_image      := get_tsetup_value('PATHWORKPHP')||v_image;
        v_has_image   := 'Y';
      end if;

      begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image2
          from tempimge
         where codempid = v_codreview;
      exception when no_data_found then
        v_image2 := null;
      end;

      if v_image2 is not null then
        v_image2      := get_tsetup_value('PATHWORKPHP')||v_image2;
        v_has_image2   := 'Y';
      end if;

      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10, item11
               ,item12, item13, item14, item15
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             ,v_codpos || ' - ' || v_item4,v_has_image,v_image, v_item7, v_item8, v_item9, v_item10, v_item11
             ,v_codreview || ' - ' || v_item12, v_item13, v_has_image, v_image2
        );
      exception when others then
        null;
      end;
  end;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;


    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;


  begin

    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := nvl(hcm_util.get_string_t(obj_data, 'item2'), '');
    v_item3       := nvl(hcm_util.get_string_t(obj_data, 'item3'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'item4'), '');
    v_item5       := nvl(hcm_util.get_string_t(obj_data, 'item5'), '');
    v_item6       := nvl(hcm_util.get_string_t(obj_data, 'item6'), '');
    v_item7       := nvl(hcm_util.get_string_t(obj_data, 'item7'), '');
    v_item8       := nvl(hcm_util.get_string_t(obj_data, 'item8'), '');
    v_item9       := nvl(hcm_util.get_string_t(obj_data, 'item9'), '');
    v_item10      := nvl(hcm_util.get_string_t(obj_data, 'item10'), '');



    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;



      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             , v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, v_item10
        );
      exception when others then
        null;
      end;
  end;

end hrrp47x;

/
