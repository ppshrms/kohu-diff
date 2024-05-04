--------------------------------------------------------
--  DDL for Package Body HRRP1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP1CE" is

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_numpath           := hcm_util.get_string_t(json_obj,'p_numpath');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'ddmmyyyy');

    p_codcomp           := hcm_util.get_string_t(json_obj,'d_codcomp');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_month             := to_number(nvl(hcm_util.get_string_t(json_obj,'p_month'),0));
    p_year              := to_number(nvl(hcm_util.get_string_t(json_obj,'p_year'),0));
    p_codlinef          := hcm_util.get_string_t(json_obj,'p_codlinef');
    p_othdetail         := hcm_util.get_string_t(json_obj,'p_othdetail');

    p_despath           := hcm_util.get_string_t(json_obj,'p_despath');
    p_despathe          := hcm_util.get_string_t(json_obj,'p_despathe');
    p_despatht          := hcm_util.get_string_t(json_obj,'p_despatht');
    p_despath3          := hcm_util.get_string_t(json_obj,'p_despath3');
    p_despath4          := hcm_util.get_string_t(json_obj,'p_despath4');
    p_despath5          := hcm_util.get_string_t(json_obj,'p_despath5');
    p_table             := hcm_util.get_json_t(json_obj,'p_table');

  end;

  procedure check_index is
    v_count_compny      number := 0;
    v_secur             boolean := false;
  begin
    if p_codcompy is null then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
        return;
    else
        begin
            select count(*) into v_count_compny
              from tcompny
             where codcompy like p_codcompy || '%' ;
        exception when others then
            null;
        end;
        if v_count_compny < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
             return;
        end if;
        v_secur := secur_main.secur7(p_codcompy, global_v_coduser);
        if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
            return;
        end if;
    end if;
  end;

  procedure gen_index_head(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_numpath           tposplnh.numpath%type;
    begin
        begin
            select numpath
              into v_numpath
              from tposplnh
             where codcompy = p_codcompy
               and dteeffec = ( select max(dteeffec)
                                  from tposplnh
                                 where dteeffec <= p_dteeffec
                                   and codcompy = p_codcompy)
               and rownum = 1;
        exception when no_data_found then
            v_numpath := null;
        end;

        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numpath',nvl(v_numpath,''));--user37 #3500 RP - PeoplePlus 26/02/2021 v_numpath);
        obj_data.put('despath','');
        obj_data.put('despathe','');
        obj_data.put('despatht','');
        obj_data.put('despath3','');
        obj_data.put('despath4','');
        obj_data.put('despath5','');
--        if p_dteeffec < trunc(sysdate) then
--            obj_data.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400'));
--        else
--            obj_data.put('msgerror','');
--        end if;
        obj_result  := json_object_t;
        obj_result.put('coderror','200');
        obj_result.put('detail',obj_data);
        json_str_output := obj_result.to_clob;
    end gen_index_head;

  procedure get_index_head (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index();
    if param_msg_error is null then
        gen_index_head(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;

    cursor c1 is
        select despathe, despatht, despath3, despath4, despath5 ,
               decode(global_v_lang,'101', despathe ,
                                    '102', despatht,
                                    '103', despath3,
                                    '104', despath4,
                                    '105', despath5,despathe) despath
          from tposplnh
         where codcompy = p_codcompy
           and trunc(dteeffec) = p_dteeffecquery
           and numpath = p_numpath;
  begin
    obj_result  := json_object_t;
    obj_row     := json_object_t();
    gen_flg_status;

    obj_data := json_object_t();
    obj_data.put('coderror','200');

    for r1 in c1 loop
      obj_data.put('despath',r1.despath);
      obj_data.put('despathe',r1.despathe);
      obj_data.put('despatht',r1.despatht);
      obj_data.put('despath3',r1.despath3);
      obj_data.put('despath4',r1.despath4);
      obj_data.put('despath5',r1.despath5);
    end loop;
    if isAdd or isEdit then
        obj_data.put('canedit',true);
    else
        obj_data.put('canedit',false);
    end if;
    obj_data.put('flgDisable',v_flgDisabled);
    obj_data.put('isAdd',isAdd);
    obj_data.put('isEdit',isEdit);

    if v_flgDisabled then
      obj_data.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
    end if;

    obj_data.put('codcompy',p_codcompy);
    obj_data.put('numpath',nvl(p_numpath,''));--user37 #3500 RP - PeoplePlus 26/02/2021 p_numpath);
    obj_data.put('dteeffec',to_char(p_dteeffec, 'dd/mm/yyyy'));
    json_str_output := obj_data.to_clob;
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

  procedure gen_index_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;
    v_flgAdd            boolean;

    cursor c1 is
        select numseq, codlinef, codcompy,codcomp, codpos, othdetail, agepos
          from tposplnd
         where codcompy = p_codcompy
           and trunc(dteeffec) = p_dteeffecquery
           and numpath = p_numpath;
  begin
    obj_result  := json_object_t;
    obj_row     := json_object_t();
    gen_flg_status;

    begin
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgAdd',isAdd);
        for r1 in c1 loop
          obj_data.put('numseq',r1.numseq);
          obj_data.put('codlinef',r1.codlinef);
          obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
          obj_data.put('codcomp',r1.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('codpos',r1.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('agepos',nvl(r1.agepos,0));
          obj_data.put('agepos_show',trunc(nvl(r1.agepos,0)/12)||' ('||mod(nvl(r1.agepos,0),12)||')');
          obj_data.put('othdetail',r1.othdetail);
          obj_data.put('canedit', not v_flgDisabled);
          obj_row.put(to_char(v_row), obj_data);
          v_row        := v_row + 1;
        end loop;
    exception when others then
        null;
    end;
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  end gen_index_table;

  procedure get_index_table (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_index_table(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_lov_codline(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;

      cursor c1 is
        select a.codlinef,b.codcompp,b.codpospr,b.numlevel, a.codcompy
          from thisorg a, thisorg2 b
         where a.codcompy = b.codcompy
           and a.codlinef = b.codlinef
           and a.dteeffec = b.dteeffec
           and staorg = 'A'
           and a.codcompy = p_codcompy
      order by a.codlinef;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codlineforg',r1.codlinef || ' - ' || get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
      obj_data.put('codlinef',r1.codlinef);
      obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
      obj_data.put('codcomp',r1.codcompp);
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcompp,global_v_lang));
      obj_data.put('codpos',r1.codpospr);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpospr,global_v_lang));
      obj_data.put('numlevel',r1.numlevel);
      obj_row.put(to_char(v_row), obj_data);
      v_row := v_row + 1;
    end loop;
    json_str_output := obj_row.to_clob;
  end;

  procedure get_lov_codline (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_lov_codline(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure convert_month_to_year_month(in_month in number, out_year out number, out_month out number)as
  begin
    out_year := (in_month/12);
    out_year := FLOOR(out_year);
    out_month := in_month - (out_year *12) ;
  end;

  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_dteupd        date;
    v_numlevel      thisorg2.numlevel%type;
    v_year          number:=0;
    v_month         number:=0;
    v_dteeffec      tposplnd.dteeffec%type;

    cursor c1 is
      select  numseq, codlinef, codcompy,codcomp, codpos, othdetail, agepos
        from tposplnd
        where codcompy = p_codcompy
          and trunc(dteeffec) = p_dteeffecquery
          and numpath = p_numpath
          and numseq = p_numseq;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    gen_flg_status;
--    begin
--        select max(dteeffec)
--          into v_dteeffec
--          from tposplnd
--         where codcompy = p_codcompy
--           and trunc(dteeffec) <= p_dteeffec
--           and numpath = p_numpath
--           and numseq = p_numseq;
--    exception when no_data_found then
--        v_dteeffec := p_dteeffec;
--    end;

    for r1 in c1 loop
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef);
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('codpos',r1.codpos);
        convert_month_to_year_month(r1.agepos,v_year,v_month);
        if v_month = 0 then
          obj_data.put('year',v_year);
          obj_data.put('month','');
        elsif v_year = 0 then
          obj_data.put('year','');
          obj_data.put('month',v_month);
        else
          obj_data.put('year',v_year);
          obj_data.put('month',v_month);
        end if;
        obj_data.put('othdetail',r1.othdetail);

        begin
            select b.numlevel
              into v_numlevel
              from thisorg a, thisorg2 b
             where a.codcompy = b.codcompy
               and a.codlinef = b.codlinef
               and a.dteeffec = b.dteeffec
               and a.codcompy = r1.codcompy
               and a.codlinef = r1.codlinef
               and a.staorg = 'A'
               and b.codcompp = r1.codcomp
               and b.codpospr = r1.codpos;
        exception when no_data_found then
            v_numlevel := null;
        end;
        obj_data.put('numlevel',v_numlevel);
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

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save_detail as
   p_temp   varchar2(100 char);
   v_secur  boolean := false;
   v_count  number;
  begin
--    if p_codlinef is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codlinef');
--      return;
--    end if;
    if p_codlinef is not null then
      begin
        select codlinef
          into p_codlinef
          from thisorg
         where codlinef = p_codlinef
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thisorg');
        return;
      end;
    end if;
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;
    if p_codpos is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
      return;
    end if;
    if p_month is null and p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'agepos');
      return;
    end if;
    if p_othdetail is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'othdetail');
      return;
    end if;

    if p_codcomp is not null then
      begin
        select codcomp
          into p_temp
          from tcenter
         where codcomp like p_codcomp || '%' ;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end;
          v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
          if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
            return;
          end if;
          if hcm_util.get_codcomp_level(p_codcomp,1) <> hcm_util.get_codcomp_level(p_codcompy,1) then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCOMPNY');
            return;
          end if;
    end if;

    if p_codpos is not null then
       begin
          select codpos
            into p_temp
            from tpostn
           where codpos = p_codpos;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
          return;
        end;
    end if;

    if p_codlinef is not null and p_codpos is not null and p_codcomp is not null then
        begin
          select b.codpospr
            into p_temp
          from thisorg a, thisorg2 b
          where a.codcompy = b.codcompy
            and a.codlinef = b.codlinef
            and a.dteeffec = b.dteeffec
            and a.codcompy = p_codcompy
            and a.codlinef = p_codlinef
            and a.staorg   = 'A'
            and b.codcompp = p_codcomp
            and b.codpospr = p_codpos;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thisorg');
          return;
        end;
    end if;

    if p_month > 11 then
       param_msg_error := get_error_msg_php('HR2020',global_v_lang);
       return;
    end if;

    if p_codcomp is not null and p_codpos is not null and p_numpath is not null then
       begin
          select p_codcompy
            into p_temp
          from tposplnd
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and numpath = p_numpath
           and codpos = p_codpos
           and numseq <> p_numseq
           and rownum = 1;
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tposplnd');
        exception when no_data_found then
          null;
        end;
    end if;

--    if p_numlevel is not null then
--        select count (*)
--          into  v_count
--          from thisorg a, thisorg2 b
--          where a.codcompy = b.codcompy
--            and a.codlinef = b.codlinef
--            and a.dteeffec = b.dteeffec
--            and a.codcompy = p_codcompy
--            and a.codlinef = p_codlinef
--            and a.staorg = 'A'
--            and b.codcompp = p_codcomp
--            and b.codpospr = p_codpos
--            and b.numlevel = p_numlevel;
--    end if;

  end;

  procedure save_detail(json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_agepos          tposplnd.agepos%type;
    v_numseq        varchar2(100 char);
    v_codlinef      tposplnd.codlinef%type;
    v_codcomp       tposplnd.codcomp%type;
    v_codpos        tposplnd.codpos%type;
    v_othdetail     tposplnd.othdetail%type;
    v_flgAdd        boolean;
    v_flgDelete     boolean;
  begin

    begin
        insert into tposplnh (codcompy,dteeffec,numpath,
                              despathe,despatht,despath3,despath4,despath5,
                              dtecreate,codcreate,dteupd,coduser)
        values (p_codcompy, p_dteeffec, p_numpath,
                p_despathe, p_despatht, p_despath3, p_despath4, p_despath5,
                sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tposplnh
           set despathe = p_despathe,
               despatht = p_despatht,
               despath3 = p_despath3,
               despath4 = p_despath4,
               despath5 = p_despath5,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numpath = p_numpath;
    end;

    v_agepos := (p_year * 12) + p_month;
    if p_numseq is null then
      begin
        select max(numseq) + 1
          into p_numseq
          from tposplnd
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and numpath = p_numpath;
      exception when others then
        p_numseq := 1;
      end;
    end if;
    begin
        insert into tposplnd (codcompy,dteeffec,numpath,numseq,codlinef,codcomp,codpos,agepos,othdetail,dtecreate,codcreate,dteupd,coduser)
        values (p_codcompy, p_dteeffec,p_numpath,p_numseq,p_codlinef,p_codcomp,p_codpos,v_agepos,p_othdetail,sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update tposplnd
           set codlinef = p_codlinef,
               codcomp = p_codcomp,
               codpos = p_codpos,
               agepos = v_agepos,
               othdetail = p_othdetail,
               dteupd   = sysdate,
               coduser  = global_v_coduser
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and numpath  = p_numpath
           and numseq   = p_numseq;
    end;

    param_json := hcm_util.get_json_t(p_table,'rows');
    for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_codlinef      := hcm_util.get_string_t(param_json_row,'codlinef');
        v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        v_codpos        := hcm_util.get_string_t(param_json_row,'codpos');
        v_agepos        := hcm_util.get_string_t(param_json_row,'agepos');
        v_othdetail     := hcm_util.get_string_t(param_json_row,'othdetail');
        v_flgAdd        := hcm_util.get_boolean_t(param_json_row,'flgAdd');
        v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_numseq <> p_numseq then
            if v_flgDelete then
                begin
                    delete
                      from tposplnd
                     where codcompy = p_codcompy
                       and dteeffec = p_dteeffec
                       and numpath = p_numpath
                       and numseq   = v_numseq;
                exception when others then
                    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                    return;
                end;
            elsif v_flgAdd then
                begin
                    insert into tposplnd (codcompy,dteeffec,numpath,numseq,codlinef,codcomp,codpos,agepos,othdetail,dtecreate,codcreate,dteupd,coduser)
                    values (p_codcompy, p_dteeffec,p_numpath,v_numseq,v_codlinef,v_codcomp,v_codpos,v_agepos,v_othdetail,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    null;
                end;
            end if;
        end if;
    end loop;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  end save_detail;

  procedure post_save_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save_detail;
    if param_msg_error is null then
      save_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_index(json_str_input in clob,json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_numseq        varchar2(100 char);
    v_codlinef      tposplnd.codlinef%type;
    v_codcomp       tposplnd.codcomp%type;
    v_codpos        tposplnd.codpos%type;
    v_agepos        tposplnd.agepos%type;
    v_othdetail     tposplnd.othdetail%type;
    v_flgAdd        boolean;
    v_flgDelete     boolean;
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'p_table');
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        v_codlinef      := hcm_util.get_string_t(param_json_row,'codlinef');
        v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        v_codpos        := hcm_util.get_string_t(param_json_row,'codpos');
        v_agepos        := hcm_util.get_string_t(param_json_row,'agepos');
        v_othdetail     := hcm_util.get_string_t(param_json_row,'othdetail');
        v_flgAdd        := hcm_util.get_boolean_t(param_json_row,'flgAdd');
        v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_flg = 'delete' then
             begin
                delete
                  from tposplnd
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numpath = p_numpath
                   and numseq   = v_numseq;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                return;
            end;
        elsif v_flg = 'add' then
            begin
                insert into tposplnd (codcompy,dteeffec,numpath,numseq,codlinef,codcomp,codpos,agepos,othdetail,dtecreate,codcreate,dteupd,coduser)
                values (p_codcompy, p_dteeffec,p_numpath,v_numseq,v_codlinef,v_codcomp,v_codpos,v_agepos,v_othdetail,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end;
        end if;
      end loop;
    end if;

    begin
        insert into tposplnh (codcompy,dteeffec,numpath,despathe,despatht,despath3,despath4,despath5,dtecreate,codcreate,dteupd,coduser)
        values (p_codcompy, p_dteeffec, p_numpath, p_despathe, p_despatht, p_despath3, p_despath4, p_despath5,  sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tposplnh
           set despathe = p_despathe,
               despatht = p_despatht,
               despath3 = p_despath3,
               despath4 = p_despath4,
               despath5 = p_despath5,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numpath = p_numpath;
    end;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end save_index;

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

  procedure delete_path(json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_numseq        varchar2(100 char);
  begin
    begin
        delete from tposplnd
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and numpath = p_numpath;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        return;
    end;
    if param_msg_error is null then
      begin
        delete from tposplnh
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec
                and numpath = p_numpath;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        return;
      end;
    end if;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end delete_path;

  procedure post_delete_path(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_path(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
        select count(*)
          into v_count
          from tposplnh
         where codcompy = p_codcompy
           and numpath = p_numpath
           and dteeffec  = p_dteeffec;
        v_indexdteeffec := p_dteeffec;
    exception when no_data_found then
        v_count := 0;
    end;

    if v_count = 0 then
        select max(dteeffec)
          into v_maxdteeffec
          from tposplnh
         where codcompy = p_codcompy
           and numpath = p_numpath
           and dteeffec <= p_dteeffec;

        if v_maxdteeffec is null then
          v_flgDisabled := false;
        else
          if p_dteeffec < trunc(sysdate) then
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
          else
            v_flgDisabled       := false;
            p_dteeffecquery     := v_maxdteeffec;
          end if;
        end if;
      else
        if p_dteeffec < trunc(sysdate) then
          v_flgDisabled := true;
        else
          v_flgDisabled := false;
        end if;
        p_dteeffecquery := p_dteeffec;
      end if;

    if p_dteeffecquery < p_dteeffec or p_dteeffecquery is null then
        isAdd           := true;
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    end if;
  end;
end hrrp1ce;

/
