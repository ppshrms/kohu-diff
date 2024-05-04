--------------------------------------------------------
--  DDL for Package Body HRCO2IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2IE" AS

  procedure check_index is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_routeno is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'routeno');
      return;
    end if;
  end;

  procedure check_tab_twkflowd is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_typeapp = 3 then
      if p_codposa is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if p_codcompa is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;
    if p_typecc = 3 then
      if p_codposc is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if p_codcompc is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;
    if p_typeapp = 4 and p_codempa is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_typecc = 4 and p_codempc is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_codposa is not null then
      begin
        select codpos
        into   p_codposa
        from   tpostn
        where  codpos = p_codposa;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
        return;
      end;
    end if;
    if p_codposc is not null then
      begin
        select codpos
        into   p_codposc
        from   tpostn
        where  codpos = p_codposc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
    end if;

    if p_codcompa is not null then
      begin
        select codcomp
        into   p_codcompa
        from   tcenter
        where  codcomp = p_codcompa;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
        return;
      end;
    end if;
    if p_codcompc is not null then
      begin
        select codcomp
        into   p_codcompc
        from   tcenter
        where  codcomp = p_codcompc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
    end if;

    if p_codempa is not null then
      begin
        select codempid
        into   p_codempa
        from   temploy1
        where  codempid = p_codempa;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
    end if;
    if p_codempc is not null then
      begin
        select codempid
        into   p_codempc
        from   temploy1
        where  codempid = p_codempc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
    end if;
  end;

  procedure check_tab_twkflowde is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codempid is not null then
      begin
        select codempid
        into   p_codempid
        from   temploy1
        where  codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
    end if;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_routeno           := hcm_util.get_string_t(json_obj,'p_routeno');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_namlabele         := hcm_util.get_string_t(json_obj,'p_namlabele');
    p_namlabelt         := hcm_util.get_string_t(json_obj,'p_namlabelt');
    p_namlabel3         := hcm_util.get_string_t(json_obj,'p_namlabel3');
    p_namlabel4         := hcm_util.get_string_t(json_obj,'p_namlabel4');
    p_namlabel5         := hcm_util.get_string_t(json_obj,'p_namlabel5');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');

    p_desroute            := hcm_util.get_string_t(json_obj,'p_desroute');
    p_desroutt            := hcm_util.get_string_t(json_obj,'p_desroutt');
    p_desrout3            := hcm_util.get_string_t(json_obj,'p_desrout3');
    p_desrout4            := hcm_util.get_string_t(json_obj,'p_desrout4');
    p_desrout5            := hcm_util.get_string_t(json_obj,'p_desrout5');
    p_approvno            := hcm_util.get_string_t(json_obj,'p_approvno');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure get_index (json_str_input in clob, json_str_output out clob)  is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
  cursor c1 is
    select  routeno,
            decode(global_v_lang, '101', desroute
                                , '102', desroutt
                                , '103', desrout3
                                , '104', desrout4
                                , '105', desrout5) as desroutt,
            approvno
    from    twkflowh
    order by routeno;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('routeno', r1.routeno);
      obj_data.put('desroutt', r1.desroutt);
      obj_data.put('approvno', r1.approvno);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_route_detail (json_str_output out clob) as
    obj_row       json_object_t;
    cursor c_twkflowh is
      select  routeno,
              decode(global_v_lang, '101', desroute
                                  , '102', desroutt
                                  , '103', desrout3
                                  , '104', desrout4
                                  , '105', desrout5) as desrout,
              desroute,desroutt,desrout3,desrout4,desrout5,approvno
      from    twkflowh
      where   routeno     = p_routeno;
  begin
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('routeno',p_routeno);
    for i in c_twkflowh loop
      obj_row.put('coderror', '200');
      obj_row.put('routeno',p_routeno);
      obj_row.put('desrout',i.desrout);
      obj_row.put('desroutt',i.desroutt);
      obj_row.put('desroute',i.desroute);
      obj_row.put('desrout3',i.desrout3);
      obj_row.put('desrout4',i.desrout4);
      obj_row.put('desrout5',i.desrout5);
      obj_row.put('approvno',i.approvno);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_route_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_route_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_route_table (json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_rcnt        number := 0;
    cursor c_twkflowd is
      select  routeno,numseq,typeapp,typecc,CODCOMPA,CODPOSA,CODEMPA,CODCOMPC,CODPOSC,CODEMPC
      from    twkflowd
      where   routeno     = p_routeno
      order by numseq;
  begin
    obj_row := json_object_t();
    for i in c_twkflowd loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('routeno',i.routeno);
      obj_data.put('numseq',i.numseq);
      obj_data.put('typeapp',i.typeapp);
      if i.typeapp = '1' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,50));
      elsif i.typeapp = '2' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,60));
      elsif i.typeapp = '3' then
        if i.CODPOSA is not null then
            obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,80)||' : '||get_tpostn_name(i.CODPOSA, global_v_lang)||' '||get_label_name('HRCO2IEC3',global_v_lang,90)||' : '||get_tcenter_name(i.CODCOMPA, global_v_lang));
        else
            obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,70));
        end if;
      elsif i.typeapp = '4' then
        obj_data.put('desc_typeapp',i.CODEMPA||' : '||get_temploy_name(i.CODEMPA,global_v_lang));
      end if;
      obj_data.put('typecc',i.typecc);
      if i.typecc = '1' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,120));
      elsif i.typecc = '2' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,130));
      elsif i.typecc = '3' then
        if i.CODPOSC is not null then
            obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,80)||' : '||get_tpostn_name(i.CODPOSC, global_v_lang)||' '||get_label_name('HRCO2IEC3',global_v_lang,90)||' : '||get_tcenter_name(i.CODCOMPC, global_v_lang));
        else
            obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,140));
        end if;
      elsif i.typecc = '4' then
        obj_data.put('desc_typecc',i.CODEMPC||' : '||get_temploy_name(i.CODEMPC,global_v_lang));
      elsif i.typecc = '5' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,180));
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_route_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_route_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_approver (json_str_output out clob) as
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_instead         json_object_t;
    obj_row_instead     json_object_t;
    obj_rows_instead    json_object_t;
    v_rcnt              number := 0;
    v_rcnt_instead      number := 0;
    v_numseq            number;
  cursor c_twkflowd is
      select  routeno,numseq,typeapp,codcompa,codposa,codempa,
              typecc,codcompc,codposc,codempc
      from    twkflowd
      where   routeno     = p_routeno
      order by numseq;
  cursor c_twkflowde is
    select a.routeno, a.numseq, a.codempid, b.codcomp, b.codpos
      from twkflowde a, temploy1 b
     where a.codempid   = b.codempid
       and a.routeno    = p_routeno
       and a.numseq     = v_numseq
     order by a.codempid;
  begin
    obj_row   := json_object_t();
    for i in c_twkflowd loop
      v_rcnt              := v_rcnt+1;
      obj_data            := json_object_t();
      obj_rows_instead    := json_object_t();
      v_rcnt_instead      := 0;
      obj_data.put('coderror', '200');
      obj_data.put('routeno',i.routeno);
      obj_data.put('numseq',i.numseq);
      obj_data.put('typeapp',i.typeapp);
      if i.typeapp = '1' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,50));
      elsif i.typeapp = '2' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,60));
      elsif i.typeapp = '3' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,70));
      elsif i.typeapp = '4' then
        obj_data.put('desc_typeapp',get_label_name('HRCO2IEC3',global_v_lang,100));
      end if;
      obj_data.put('codcompa', i.codcompa);
      obj_data.put('codposa', i.codposa);
      obj_data.put('codempa', i.codempa);
      obj_data.put('typecc',i.typecc);
      if i.typecc = '1' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,120));
      elsif i.typecc = '2' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,130));
      elsif i.typecc = '3' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,140));
      elsif i.typecc = '4' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,170));
      elsif i.typecc = '5' then
        obj_data.put('desc_typecc',get_label_name('HRCO2IEC3',global_v_lang,180));
      end if;
      obj_data.put('codcompc', i.codcompc);
      obj_data.put('codposc', i.codposc);
      obj_data.put('codempc', i.codempc);
      obj_instead   := json_object_t();
      v_numseq      := i.numseq;
      for j in c_twkflowde loop
        v_rcnt_instead    := v_rcnt_instead + 1;
        obj_row_instead   := json_object_t();

        obj_row_instead.put('routeno', j.routeno);
        obj_row_instead.put('numseq', j.numseq);
        obj_row_instead.put('codempid', j.codempid);
        obj_row_instead.put('codcomp_desc', get_tcenter_name(j.codcomp, global_v_lang));
        obj_row_instead.put('codpos_desc', get_tpostn_name(j.codpos, global_v_lang));
        obj_instead.put(to_char(v_rcnt_instead-1),obj_row_instead);
      end loop;
      obj_rows_instead.put('rows', obj_instead);
      obj_data.put('instead', obj_rows_instead);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_approver (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_approver(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_emp_detail (json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
    v_codcomp_desc    varchar2(500);
    v_codpos_desc     varchar2(500);
  begin
    initial_value(json_str_input);
    begin
      select    get_tcenter_name(codcomp,global_v_lang),get_tpostn_name(codpos,global_v_lang)
      into      v_codcomp_desc, v_codpos_desc
      from      temploy1
      where     codempid    = p_codempid_query;
    exception when no_data_found then
      v_codcomp_desc    := null;
      v_codpos_desc     := null;
    end;
    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcomp_desc',v_codcomp_desc);
    obj_row.put('codpos_desc',v_codpos_desc);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := json_object_t(param_json.get(to_char(i)));

        p_routeno    := hcm_util.get_string_t(param_json_row,'routeno');
        p_flg        := hcm_util.get_string_t(param_json_row,'flg');

        if(p_flg = 'delete') then
          delete from twkflowh where routeno = p_routeno;
          delete from twkflowde where routeno = p_routeno;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure insert_twkflowh is
  begin
    begin
      insert into twkflowh(routeno,desroute,desroutt,desrout3,desrout4,desrout5,approvno,codcreate,coduser)
                    values(p_routeno,p_desroute,p_desroutt,p_desrout3,p_desrout4,p_desrout5,p_approvno,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update twkflowh
      set desroute      = p_desroute,
          desroutt      = p_desroutt,
          desrout3      = p_desrout3,
          desrout4      = p_desrout4,
          desrout5      = p_desrout5,
          approvno      = p_approvno,
          coduser       = p_coduser
      where routeno     = p_routeno;
    end;
  end;
  --
  procedure save_route(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;

    v_numseq  number;
    cursor twkflowd is
      select routeno,numseq
        from twkflowd
       where routeno = p_routeno
    order by routeno,numseq;

  begin
    initial_value(json_str_input);
    insert_twkflowh;
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      p_routeno    := hcm_util.get_string_t(param_json_row,'routeno');
      p_numseq     := hcm_util.get_string_t(param_json_row,'numseq');
      p_flg        := hcm_util.get_string_t(param_json_row,'flg');

      if(p_flg = 'delete') then
        delete from twkflowd where routeno = p_routeno and numseq = p_numseq;
        delete from twkflowde where routeno = p_routeno and numseq = p_numseq;
        --
        v_numseq := 100;
        for i in twkflowd loop
          v_numseq := v_numseq + 1;
          update twkflowd
             set numseq = v_numseq
           where routeno = i.routeno and numseq = i.numseq;
        end loop;
        v_numseq := 0;
        for i in twkflowd loop
          v_numseq := v_numseq + 1;
          update twkflowd
             set numseq = v_numseq
           where routeno = i.routeno and numseq = i.numseq;
        end loop;        
      end if;
    end loop;
    if param_msg_error is null then
      if p_call_from_appr = 'N' then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      end if;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_twkflowd is
  begin
    begin
      insert into twkflowd (routeno, numseq, typeapp, codcompa, codposa, codempa, typecc, codcompc, codposc, codempc, codcreate, coduser)
      values (p_routeno, p_numseq_appr, p_typeapp, p_codcompa, p_codposa, p_codempa, p_typecc, p_codcompc, p_codposc, p_codempc, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      begin
        update twkflowd
        set typeapp = p_typeapp ,
            codcompa = p_codcompa ,
            codposa = p_codposa ,
            codempa = p_codempa ,
            typecc = p_typecc ,
            codcompc = p_codcompc ,
            codposc = p_codposc ,
            codempc = p_codempc ,
            coduser = global_v_coduser
        where routeno = p_routeno and numseq = p_numseq_appr;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        rollback;
      end;
    end;
  end;
  --
  procedure check_save_appr is
  begin
    if p_typeapp = '3' and p_typecc = '3' then
      if p_codcompa = p_codcompc and p_codposa = p_codposc then
        param_msg_error := get_error_msg_php('HR1503',global_v_lang);
      end if;
    elsif p_typeapp = '4' and p_typecc = '4' then
      if p_codempa = p_codempc then
        param_msg_error := get_error_msg_php('HR1503',global_v_lang);
      end if;
    end if;
  end;
  --
  procedure save_approver(json_str_input in clob, json_str_output out clob) as
    param_json                json_object_t;
    param_json_row            json_object_t;
    param_json_instead        json_object_t;
    param_json_row_instead    json_object_t;
    v_codempid                twkflowde.codempid%type;
    v_flg_instead             varchar2(10);
    temp_output               clob;
    v_staemp                  VARCHAR2(1);
  begin
    initial_value(json_str_input);
    p_call_from_appr    := 'Y';
    save_route(json_str_input, temp_output);
    p_call_from_appr    := 'N';
--    check_tab_twkflowd;
    if param_msg_error is null then
      param_msg_error := null;
      param_json := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str_appr'),'rows');
--      param_json := hcm_util.get_json(hcm_util.get_json(param_json_row,'json_input_str_appr'),'rows');
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        p_numseq_appr       := hcm_util.get_string_t(param_json_row,'numseq');
        p_routeno           := hcm_util.get_string_t(param_json_row,'routeno');
        p_typeapp           := hcm_util.get_string_t(param_json_row,'typeapp');
        p_codcompa          := hcm_util.get_string_t(param_json_row,'codcompa');
        p_codposa           := hcm_util.get_string_t(param_json_row,'codposa');
        p_codempa           := hcm_util.get_string_t(param_json_row,'codempa');
        p_typecc            := hcm_util.get_string_t(param_json_row,'typecc');
        p_codcompc          := hcm_util.get_string_t(param_json_row,'codcompc');
        p_codposc           := hcm_util.get_string_t(param_json_row,'codposc');
        p_codempc           := hcm_util.get_string_t(param_json_row,'codempc');
  --      param_json_instead  := json(hcm_util.get_string(json(param_json_row),'instead'));
        insert_twkflowd;
        check_save_appr;
        exit when param_msg_error is not null;
        param_json_instead  := hcm_util.get_json_t(hcm_util.get_json_t(param_json_row,'instead'),'rows');
        for j in 0..param_json_instead.get_size-1 loop

          param_json_row_instead    := hcm_util.get_json_t(param_json_instead,to_char(j));
          v_codempid                := hcm_util.get_string_t(param_json_row_instead,'codempid');
          v_flg_instead             := hcm_util.get_string_t(param_json_row_instead,'flg');

          select staemp
          into v_staemp
          from temploy1
          where codempid = v_codempid;
          if p_codempa = v_codempid then
            param_msg_error := get_error_msg_php('HR1503',global_v_lang);
            exit;
          end if;
          if (v_staemp = '0' AND v_flg_instead <> 'delete') then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);

          elsif (v_staemp = '9' AND v_flg_instead <> 'delete') then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
          else
              if v_flg_instead = 'delete' then
                delete from twkflowde
                where routeno   = p_routeno
                and   numseq    = p_numseq_appr
                and   codempid  = v_codempid;
              elsif v_flg_instead = 'add' then
                insert into twkflowde(routeno,numseq,codempid,codcreate,coduser)
                               values(p_routeno,p_numseq_appr,v_codempid,global_v_coduser,global_v_coduser);
              end if;
          end if;
        end loop;
      end loop;
    end if;

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
  procedure upd_tempaprq(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then

      chk_workflow.upd_tempaprq(p_routeno);

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

END HRCO2IE;

/
