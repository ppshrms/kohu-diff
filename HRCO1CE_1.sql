--------------------------------------------------------
--  DDL for Package Body HRCO1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO1CE" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_intwno            := hcm_util.get_string_t(json_obj,'intwno');
    p_namintwe          := hcm_util.get_string_t(json_obj,'namintwe');
    p_namintwt          := hcm_util.get_string_t(json_obj,'namintwt');
    p_namintw3          := hcm_util.get_string_t(json_obj,'namintw3');
    p_namintw4          := hcm_util.get_string_t(json_obj,'namintw4');
    p_namintw5          := hcm_util.get_string_t(json_obj,'namintw5');
    p_codposst          := hcm_util.get_string_t(json_obj,'codposst');
    p_codposen          := hcm_util.get_string_t(json_obj,'codposen');

    p_intwno            := hcm_util.get_string_t(json_obj,'intwno');
    p_numcate           := hcm_util.get_string_t(json_obj,'numcate');
    p_namcatee          := hcm_util.get_string_t(json_obj,'namcatee');
    p_namcatet          := hcm_util.get_string_t(json_obj,'namcatet');
    p_namcate3          := hcm_util.get_string_t(json_obj,'namcate3');
    p_namcate4          := hcm_util.get_string_t(json_obj,'namcate4');
    p_namcate5          := hcm_util.get_string_t(json_obj,'namcate5');
    p_typeques          := hcm_util.get_string_t(json_obj,'typeques');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_save is
  begin
    if (p_codposst > p_codposen) then
      param_msg_error := get_error_msg_php('CO0036', global_v_lang,'TPOSTN');
      return;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_count_cate  number  := 0;
    v_rcnt        number  := 0;
    cursor c_texintwh is
      select  f.intwno,
              decode(global_v_lang,'101',namintwe
                                  ,'102',namintwt
                                  ,'103',namintw3
                                  ,'104',namintw4
                                  ,'105',namintw5) as namintw,
              namintwe,namintwt,namintw3,namintw4,namintw5,
              codposst,codposen,
              codposst||' '||get_tpostn_name(codposst,global_v_lang)||' - '||
              codposen||' '||get_tpostn_name(codposen,global_v_lang) as for_codpos,
              count(numcate) as cnt_numcate
      from texintwh f,texintws c
--      where f.intwno  = nvl(c.intwno,f.intwno)
      group by f.intwno,namintwe,namintwt,namintw3,namintw4,namintw5,codposst,codposen
      order by intwno;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c_texintwh loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('intwno', i.intwno);
      obj_data.put('namintw', i.namintw);
      obj_data.put('namintwe', i.namintwe);
      obj_data.put('namintwt', i.namintwt);
      obj_data.put('namintw3', i.namintw3);
      obj_data.put('namintw4', i.namintw4);
      obj_data.put('namintw5', i.namintw5);
      obj_data.put('codposst', i.codposst);
      obj_data.put('codposen', i.codposen);
      obj_data.put('for_codpos', i.for_codpos);
      begin
        select count(*)
          into v_count_cate
          from texintws
         where intwno = i.intwno;
      end;
      obj_data.put('cnt_numcate', v_count_cate);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_category_table(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_count_quest number  := 0;
    v_rcnt        number  := 0;
    cursor c_texintws is
      select c.intwno,c.numcate,
              decode(102,'101',namcatee
                        ,'102',namcatet
                        ,'103',namcate3
                        ,'104',namcate4
                        ,'105',namcate5) as namcate,
              typeques
          from texintws c,texintwd q
         where c.intwno = p_intwno
      group by c.intwno,c.numcate,namcatee,namcatet,namcate3,namcate4,namcate5,typeques
      order by numcate;
--      select  c.intwno,c.numcate,
--              decode(global_v_lang,'101',namcatee
--                                  ,'102',namcatet
--                                  ,'103',namcate3
--                                  ,'104',namcate4
--                                  ,'105',namcate5) as namcate,
--              typeques,count(q.numseq) as cnt_question
--      from texintws c,texintwd q
--      where c.intwno  = q.intwno
--      and   c.numcate = q.numcate
--      and   c.intwno  = p_intwno
--      group by c.intwno,c.numcate,namcatee,namcatet,namcate3,namcate4,namcate5,typeques
--      order by namcate;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c_texintws loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('intwno', i.intwno);
      obj_data.put('numcate', i.numcate);
      obj_data.put('namcate', i.namcate);
      obj_data.put('typeques', i.typeques);
      if i.typeques = 1 then
        obj_data.put('typeques_desc', get_label_name('HRCO1CEC3',global_v_lang,60));
      else
        obj_data.put('typeques_desc', get_label_name('HRCO1CEC3',global_v_lang,50));
      end if;
      begin
        select count(*)
          into v_count_quest
          from texintwd
         where intwno = i.intwno
           and numcate = i.numcate;
      end;
      obj_data.put('cnt_question', v_count_quest);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_category_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_category_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_category_question(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_row_tab     json_object_t;
    obj_row_ques    json_object_t;
    obj_data_ques   json_object_t;
    v_rcnt          number  := 0;
    v_rcnt_ques     number  := 0;
    v_numcate       texintws.numcate%type;
    cursor c_texintws is
      select  intwno,numcate,
              decode(global_v_lang,'101',namcatee
                                  ,'102',namcatet
                                  ,'103',namcate3
                                  ,'104',namcate4
                                  ,'105',namcate5) as namcate,
              namcatee,namcatet,namcate3,namcate4,namcate5,
              typeques
      from    texintws c
      where   intwno  = p_intwno
      order by numcate;

    cursor c_texintwd is
      select  intwno,numcate,numseq,
              decode(global_v_lang,'101',detailse
                                  ,'102',detailst
                                  ,'103',details3
                                  ,'104',details4
                                  ,'105',details5) as details
      from    texintwd
      where   intwno  = p_intwno
      and     numcate = v_numcate
      order by numseq;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c_texintws loop
      obj_data      := json_object_t();
      obj_row_tab   := json_object_t();
      obj_row_ques  := json_object_t();
      v_rcnt        := v_rcnt + 1;
      v_rcnt_ques   := 0;
      v_numcate     := i.numcate;
      obj_data.put('coderror', '200');
      obj_data.put('intwno',i.intwno);
      obj_data.put('numcate',i.numcate);
      obj_data.put('namcate',i.namcate);
      obj_data.put('namcatee',i.namcatee);
      obj_data.put('namcatet',i.namcatet);
      obj_data.put('namcate3',i.namcate3);
      obj_data.put('namcate4',i.namcate4);
      obj_data.put('namcate5',i.namcate5);
      obj_data.put('typeques',i.typeques);
      for j in c_texintwd loop
        obj_data_ques   := json_object_t();
        v_rcnt_ques     := v_rcnt_ques + 1;
        obj_data_ques.put('intwno',j.intwno);
        obj_data_ques.put('numcate',j.numcate);
        obj_data_ques.put('numseq',j.numseq);
        obj_data_ques.put('details',j.details);
        obj_row_ques.put(to_char(v_rcnt_ques-1),obj_data_ques);
      end loop;
      obj_data.put('numques',v_rcnt_ques);
      obj_row_tab.put('rows',obj_row_ques);
      obj_data.put('questionTable', obj_row_tab);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_category_question(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_category_question(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_question_choice(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_row_tab     json_object_t;
    obj_row_choice  json_object_t;
    obj_data_choice json_object_t;
    v_rcnt          number  := 0;
    v_rcnt_ques     number  := 0;
    v_numseq        texintwd.numseq%type;
    cursor c_texintwd is
      select  intwno,numcate,numseq,
              decode(global_v_lang,'101',detailse
                                  ,'102',detailst
                                  ,'103',details3
                                  ,'104',details4
                                  ,'105',details5) as details,
              detailse,detailst,details3,details4,details5
      from  texintwd
      where intwno  = p_intwno
      and   numcate = p_numcate
      order by numseq;
    cursor c_texintwc is
      select  intwno,numcate,numseq,numans,
              decode(global_v_lang,'101',detailse
                                  ,'102',detailst
                                  ,'103',details3
                                  ,'104',details4
                                  ,'105',details5) as details,
              detailse,detailst,details3,details4,details5
      from  texintwc c
      where intwno  = p_intwno
      and   numcate = p_numcate
      and   numseq  = v_numseq
      order by numans;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c_texintwd loop
      obj_data        := json_object_t();
      obj_row_tab     := json_object_t();
      obj_row_choice  := json_object_t();
      v_rcnt          := v_rcnt + 1;
      v_rcnt_ques     := 0;
      v_numseq        := i.numseq;
      obj_data.put('coderror', '200');
      obj_data.put('intwno',i.intwno);
      obj_data.put('numcate',i.numcate);
      obj_data.put('numseq',i.numseq);
      obj_data.put('details',i.details);
      obj_data.put('detailse',i.detailse);
      obj_data.put('detailst',i.detailst);
      obj_data.put('details3',i.details3);
      obj_data.put('details4',i.details4);
      obj_data.put('details5',i.details5);
      for j in c_texintwc loop
        obj_data_choice   := json_object_t();
        v_rcnt_ques     := v_rcnt_ques + 1;
        obj_data_choice.put('intwno',j.intwno);
        obj_data_choice.put('numcate',j.numcate);
        obj_data_choice.put('numseq',j.numseq);
        obj_data_choice.put('numans',j.numans);
        obj_data_choice.put('details',j.details);
        obj_data_choice.put('detailse',j.detailse);
        obj_data_choice.put('detailst',j.detailst);
        obj_data_choice.put('details3',j.details3);
        obj_data_choice.put('details4',j.details4);
        obj_data_choice.put('details5',j.details5);
        obj_row_choice.put(to_char(v_rcnt_ques-1),obj_data_choice);
      end loop;
      obj_row_tab.put('rows',obj_row_choice);
      obj_data.put('choice', obj_row_tab);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_question_choice(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_question_choice(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    p_flg           varchar2(10);
    v_chkExist      number;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      p_intwno    := hcm_util.get_string_t(param_json_row,'intwno');
      p_flg       := hcm_util.get_string_t(param_json_row,'flg');
      begin
        select count(*) into v_chkExist
        from tresreq
        where intwno = p_intwno;
      end;
      if(p_flg = 'delete') then
        if v_chkExist = 0 then
          delete from texintwh where intwno = p_intwno;
        else
          param_msg_error := get_error_msg_php('HR1450',global_v_lang);
          exit;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure insert_texintwh is
  begin
    begin
      insert into texintwh(intwno,namintwe,namintwt,namintw3,namintw4,namintw5,
                           codposst,codposen,codcreate,coduser)
                   values (p_intwno,p_namintwe,p_namintwt,p_namintw3,p_namintw4,p_namintw5,
                           p_codposst,p_codposen,global_v_lang,global_v_lang);
    exception when dup_val_on_index then
      update  texintwh
         set  namintwe    = p_namintwe,
              namintwt    = p_namintwt,
              namintw3    = p_namintw3,
              namintw4    = p_namintw4,
              namintw5    = p_namintw5,
              codposst    = p_codposst,
              codposen    = p_codposen,
              coduser     = global_v_lang
      where   intwno      = p_intwno;
    end;
  end;
  --
  procedure save_category(json_str_input in clob,json_str_output out clob) is
    param_json                json_object_t;
    param_json_row            json_object_t;
    param_json_category       json_object_t;
    param_json_row_category   json_object_t;
    v_codempid                twkflowde.codempid%type;
    v_flg_category            varchar2(10);
    temp_output               clob;
  begin
    initial_value(json_str_input);
    check_save;
    insert_texintwh;
    if param_msg_error is null then
      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        p_intwno                  := hcm_util.get_string_t(param_json_row,'intwno');
        p_numcate                 := hcm_util.get_string_t(param_json_row,'numcate');
        v_flg_category            := hcm_util.get_string_t(param_json_row,'flg');
        if v_flg_category = 'delete' then
          delete from texintws
          where intwno    = p_intwno
          and   numcate   = p_numcate;
        end if;
      end loop;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_texintws is
  begin
    begin
      insert into texintws(intwno,numcate,namcatee,namcatet,
                          namcate3,namcate4,namcate5,typeques,
                          codcreate,coduser)
                   values (p_intwno,p_numcate,p_namcatee,p_namcatet,
                           p_namcate3,p_namcate4,p_namcate5,p_typeques,
                           global_v_lang,global_v_lang);
    exception when dup_val_on_index then
      update texintws
         set namcatee    = p_namcatee,
             namcatet    = p_namcatet,
             namcate3    = p_namcate3,
             namcate4    = p_namcate4,
             namcate5    = p_namcate5,
             typeques    = p_typeques,
             coduser     = global_v_lang
      where  intwno      = p_intwno
      and    numcate     = p_numcate;
    end;
  end;
  --
  procedure save_question(json_str_input in clob,json_str_output out clob) is
    param_json                json_object_t;
    param_json_row            json_object_t;
    param_json_question       json_object_t;
    param_json_row_question   json_object_t;
    v_codempid                twkflowde.codempid%type;
    v_flg_question            varchar2(10);
    temp_output               clob;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'json_str_input'),'rows');
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      p_intwno            := hcm_util.get_string_t(param_json_row,'intwno');
      p_numcate           := hcm_util.get_string_t(param_json_row,'numcate');
      p_namcatee          := hcm_util.get_string_t(param_json_row,'namcatee');
      p_namcatet          := hcm_util.get_string_t(param_json_row,'namcatet');
      p_namcate3          := hcm_util.get_string_t(param_json_row,'namcate3');
      p_namcate4          := hcm_util.get_string_t(param_json_row,'namcate4');
      p_namcate5          := hcm_util.get_string_t(param_json_row,'namcate5');
      p_typeques          := hcm_util.get_string_t(param_json_row,'typeques');
      insert_texintws;
      param_json_question  := hcm_util.get_json_t(json_object_t(param_json_row.get('questionTable')),'rows');
      for j in 0..param_json_question.get_size-1 loop
        param_json_row_question     := hcm_util.get_json_t(param_json_question,to_char(j));
        p_numcate                 := hcm_util.get_string_t(param_json_row_question,'numcate');
        p_numseq                  := hcm_util.get_string_t(param_json_row_question,'numseq');
        v_flg_question            := hcm_util.get_string_t(param_json_row_question,'flg');
        if v_flg_question = 'delete' then
          delete from texintwd
          where intwno    = p_intwno
          and   numcate   = p_numcate
          and   numseq    = p_numseq;
        end if;
      end loop;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_texintwd is
  begin
    begin
      insert into texintwd(intwno,numcate,numseq,detailse,detailst,details3,details4,details5,codcreate,coduser)
                   values (p_intwno,p_numcate,p_numseq,p_detailse,p_detailst,p_details3,p_details4,p_details5,global_v_lang,global_v_lang);
    exception when dup_val_on_index then
      update texintwd
         set detailse     = p_detailse,
             detailst     = p_detailst,
             details3     = p_details3,
             details4     = p_details4,
             details5     = p_details5,
             coduser      = global_v_lang
      where  intwno      = p_intwno
      and    numcate     = p_numcate
      and    numseq      = p_numseq;
    end;
  end;
  --
  procedure save_choice(json_str_input in clob,json_str_output out clob) is
    param_json                json_object_t;
    param_json_row            json_object_t;
    param_json_choice         json_object_t;
    param_json_row_choice     json_object_t;
    v_codempid                twkflowde.codempid%type;
    v_flg_choice              varchar2(10);
    temp_output               clob;

    v_chk_exists              varchar2(1);
    v_numseq                  number;
  begin
    initial_value(json_str_input);
    param_msg_error := null;
    -------
    begin
      select  'Y'
      into    v_chk_exists
      from    texintwh
      where   intwno    = p_intwno
      and     rownum    = 1;
    exception when no_data_found then
      v_chk_exists  := 'N';
    end;
    if v_chk_exists = 'N' then
      insert_texintwh;
    end if;
    ------
    ------
    begin
      select  'Y'
      into    v_chk_exists
      from    texintws
      where   intwno    = p_intwno
      and     numcate   = p_numcate
      and     rownum    = 1;
    exception when no_data_found then
      v_chk_exists  := 'N';
    end;
    if v_chk_exists = 'N' then
      insert_texintws;
    end if;
    -------
    param_json := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'json_str_input'),'rows');
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      p_numseq            := hcm_util.get_string_t(param_json_row,'numseq');
      p_detailse          := hcm_util.get_string_t(param_json_row,'detailse');
      p_detailst          := hcm_util.get_string_t(param_json_row,'detailst');
      p_details3          := hcm_util.get_string_t(param_json_row,'details3');
      p_details4          := hcm_util.get_string_t(param_json_row,'details4');
      p_details5          := hcm_util.get_string_t(param_json_row,'details5');
      insert_texintwd;
      param_json_choice  := hcm_util.get_json_t(json_object_t(param_json_row.get('choice')),'rows');
      for j in 0..param_json_choice.get_size-1 loop
        param_json_row_choice     := hcm_util.get_json_t(param_json_choice,to_char(j));
        p_numans                  := hcm_util.get_string_t(param_json_row_choice,'numans');
        p_detailse_ans            := hcm_util.get_string_t(param_json_row_choice,'detailse');
        p_detailst_ans            := hcm_util.get_string_t(param_json_row_choice,'detailst');
        p_details3_ans            := hcm_util.get_string_t(param_json_row_choice,'details3');
        p_details4_ans            := hcm_util.get_string_t(param_json_row_choice,'details4');
        p_details5_ans            := hcm_util.get_string_t(param_json_row_choice,'details5');
        v_flg_choice              := hcm_util.get_string_t(param_json_row_choice,'flg');
        if v_flg_choice = 'delete' then
          delete from texintwc
          where intwno    = p_intwno
          and   numcate   = p_numcate
          and   numseq    = p_numseq
          and   numans    = p_numans;
        elsif v_flg_choice = 'add' then
          begin
            select  nvl(max(numans),0)
            into    p_numans
            from    texintwc
            where   intwno    = p_intwno
            and     numcate   = p_numcate
            and     numseq    = p_numseq;
          end;
          p_numans  := p_numans + 1;
          insert into texintwc(intwno,numcate,numseq,numans,
                               detailse,detailst,details3,details4,details5,
                               codcreate,coduser)
                        values(p_intwno,p_numcate,p_numseq,p_numans,
                               p_detailse_ans,p_detailst_ans,p_details3_ans,p_details4_ans,p_details5_ans,
                               global_v_coduser,global_v_coduser);
        end if;
      end loop;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/
