--------------------------------------------------------
--  DDL for Package Body HRRP49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP49X" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
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

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_month             := to_number(hcm_util.get_string_t(json_obj,'p_month'));
    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codlinef          := hcm_util.get_string_t(json_obj,'p_codlinef');
    p_othdetail          := hcm_util.get_string_t(json_obj,'p_othdetail');

    p_flgCount          := hcm_util.get_string_t(json_obj,'p_flgCount');

    if p_flgCount is not null then
        searchIndex         := json_object_t(hcm_util.get_string_t(json_obj,'searchIndex'));
--    searchIndex         := hcm_util.get_json_t(json_obj,'searchIndex');
    end if;


  end;

  procedure check_index is
    v_count_compny  number := 0;
    v_count_pos  number := 0;
    v_secur  boolean := false;
  begin
    if p_codcompy is not null then
      begin
            select count(*) into v_count_compny
            from tcompny
            where codcompy like p_codcompy || '%' ;
        exception when others then null;
        end;
        if v_count_compny < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
             return;
        end if;
         v_secur := secur_main.secur7(p_codcompy, global_v_coduser);
          if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
    end if;

    if p_numpath is not null then
         begin
            select count(*) into v_count_pos
            from tposplnh
            where codcompy = p_codcompy
              and numpath  = p_numpath;
        exception when others then null;
        end;

        if v_count_pos < 1 then
             param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tposplnh');
             return;
        end if;
    end if;

    if p_codcomp is not null and p_codpos is not null then

       begin
            select count(*) into v_count_compny
            from tcenter
            where codcomp like p_codcomp || '%';
        exception when others then null;
        end;
        if v_count_compny < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
             return;
        end if;
         v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
          if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;

      begin
          select codpos into v_count_pos
            from tpostn
           where codpos = p_codpos;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
          return;
        end;
    end if;

  end;

  procedure gen_index(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result            json_object_t;
    v_row               number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;
    v_rcnt              number := 0; --<< user25 Date: 24/08/2021 #4516
    v_agepos            varchar2(10); --<< user25 Date : 28/09/2021 #6998

    cursor c_com_path is
      select numpath,numseq, codlinef, codcomp,codcompy, codpos, agepos, othdetail , dteeffec
        from tposplnd
       where codcompy = p_codcompy
         and numpath = p_numpath
         and dteeffec  = (select max(dteeffec)
                                   from tposplnd
                              where codcompy = p_codcompy
                                and numpath = p_numpath
                                and dteeffec <= sysdate)
      order by numseq;

    cursor c_com_pos is
      select a.numpath, decode(global_v_lang,'101',a.despathe,
                                  '102',a.despatht,
                                  '103',a.despath3,
                                  '104',a.despath4,
                                  '105',a.despath5) as despath , numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec --<< user25 Date : 28/09/2021 #6996
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq >= (select d.numseq
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp like p_codcomp || '%'
                                 and d.codpos      = p_codpos)

      order by a.numpath, b.numseq;



    begin
        obj_result  := json_object_t;
        obj_row     := json_object_t();
        v_rcnt      :=0; --<< user25 Date: 24/08/2021 #4516
        begin
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            if p_codcompy is not null then
              for r1 in c_com_path loop
                v_rcnt := v_rcnt+1;--<< user25 Date: 24/08/2021 #4516
                obj_data.put('info', '<i class="fa fa-info-circle _text-blue"></i>');--<< user25 Date: 06/10/2021 1. RP Module #6993
                obj_data.put('numpath',r1.numpath);
                obj_data.put('despath',get_tcodec_name('TCODNUMPATH',r1.numpath,global_v_lang));
                obj_data.put('numseq',r1.numseq);
                obj_data.put('codlinef',r1.codlinef);
                obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
                obj_data.put('codcomp',r1.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
            --<< user25 Date : 28/09/2021 #6998
--                obj_data.put('agepos',r1.agepos);
                v_agepos := round(r1.agepos/12)||'('||mod(r1.agepos,12)||')'; 
                obj_data.put('agepos',v_agepos);
            -->> user25 Date : 28/09/2021 #6998
                obj_data.put('othdetail',r1.othdetail);
                obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
                obj_data.put('codcompy',r1.codcompy);
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
              end loop;
            end if;

            if p_codcomp is not null and p_codpos is not null then
              for r1 in c_com_pos loop
                v_rcnt := v_rcnt+1; --<< user25 Date: 24/08/2021 #4516
                obj_data.put('info', '<i class="fa fa-info-circle _text-blue"></i>');--<< user25 Date: 06/10/2021 1. RP Module #6993
                obj_data.put('numpath',r1.numpath);
                obj_data.put('despath',get_tcodec_name('TCODNUMPATH',r1.numpath,global_v_lang));
                obj_data.put('numseq',r1.numseq);
                obj_data.put('codlinef',r1.codlinef);
                obj_data.put('desc_codlinef',get_tfunclin_name(r1.codcompy,r1.codlinef,global_v_lang));
                obj_data.put('codcomp',r1.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('agepos',r1.agepos);
                obj_data.put('othdetail',r1.othdetail);
                obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
                obj_data.put('codcompy',r1.codcompy);
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
              end loop;
            end if;

--<< user25 Date: 24/08/2021 #4516
          if v_row > 0 then
              json_str_output := obj_row.to_clob;
          else
              if v_rcnt = 0 then
                    param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TPOSPLND');
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
              else
                    json_str_output := obj_row.to_clob;
              end if;
         end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--        exception when others then null;
--        end;

--        if param_msg_error is not null then
--          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--        else
--            json_str_output := obj_row.to_clob;
--        end if;
-->> user25 Date: 24/08/2021 #4516
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
        from tposplnd
        where codcompy = p_codcompy
          and trunc(dteeffec) = p_dteeffec
          and numpath = p_numpath
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
        gen_numpath;
        if param_msg_error is null then
            gen_career_path_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path_name(json_str_output out clob) is
    obj_data            json_object_t;

    begin

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numpath',p_numpath);
        obj_data.put('desc_numpath',get_tcodec_name('TCODNUMPATH',p_numpath,global_v_lang));


        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := obj_data.to_clob;
        end if;

    end;

  procedure get_career_path_name (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        gen_numpath;
        if param_msg_error is null then
            gen_career_path_name(json_str_output);
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

  procedure gen_career_path(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_dteupd        date;
    v_numlevel      thisorg2.numlevel%type;
    v_row           number:=0;
    v_pre_codlinef  tposplnd.codlinef%type := '';


    cursor c1 is
      select  codlinef, numseq, codcomp, codpos
        from tposplnd
        where codcompy = p_codcompy
          and trunc(dteeffec) = p_dteeffec
          and numpath = p_numpath
          order by numseq;
  begin
      obj_row := json_object_t();
      v_pre_codlinef := '';

      for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('codlinef',r1.codlinef);
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('previousCodlinef',v_pre_codlinef);
--        obj_data.put('flgCurrent',v_flgCurrent);
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
    gen_numpath;
    if param_msg_error is null then
      gen_career_path(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save_detail as
   p_temp varchar2(100 char);
   v_secur  boolean := false;
  begin
    if p_codlinef is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codlinef');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
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
         where codcomp like p_codcomp || '%';
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

  end;

  procedure save_detail(json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_codpos        varchar2(100 char);
    v_agepos          tposplnd.agepos%type;
  begin

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
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'p_table');
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');

       if v_flg = 'delete' then

          begin
            delete from tposplnd
                  where codcompy = p_codcompy
                    and dteeffec = p_dteeffec
                    and numpath = p_numpath
                    and numseq   = v_numseq;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            return;
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

  procedure delete_path(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_numseq        varchar2(100 char);
  begin

         begin
          delete from tposplnd
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec
                  and numpath = p_numpath
                  and numseq   = p_numseq;
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

  procedure gen_numpath is
    v_numseq            number := 0;
    v_select_numseq     number;
    v_numpath           tposplnh.numpath%type;
    v_dteeffec          date;
    v_count         number;

    cursor c_com_pos is
       select a.numpath, numseq, codlinef,a.codcompy,codcomp,codpos,agepos,othdetail,a.dteeffec
        from tposplnh a, tposplnd b
       where a.codcompy = b.codcompy
         and a.numpath = b.numpath
         and a.dteeffec = b.dteeffec --<< user25 Date : 28/09/2021 #6996
         and a.dteeffec  = (select max(dteeffec)
                          from tposplnh c
                         where a.codcompy = c. codcompy
                           and a.numpath  =  c.numpath
                           and c.dteeffec <= sysdate)
         and b.numseq >= (select d.numseq
                                from tposplnd d
                              where d.codcompy  = a.codcompy
                                 and d.numpath    =  a.numpath
                                 and d.dteeffec     = a.dteeffec
                                 and d.codcomp like p_codcomp_query || '%'
                                 and d.codpos      = p_codpos_query)
      order by a.numpath;
  begin

    if p_flgCount <> 0 and p_flgCount is not null then
--        p_codcompy_query    := hcm_util.get_string_t(searchIndex,'codcompy');
--        p_numpath_query     := hcm_util.get_string_t(searchIndex,'numpath');
        p_codcomp_query     := hcm_util.get_string_t(searchIndex,'codcomp');
        p_codpos_query      := hcm_util.get_string_t(searchIndex,'codpos');
    end if;

    delete ttemprpt where codapp = 'HRRP49X' and codempid = global_v_codempid;
    v_numseq    := 0;

    if p_codcomp_query is not null and p_codpos_query is not null then
      for r1 in c_com_pos loop
          select count(*) 
            into v_count 
            from ttemprpt 
           where codempid = global_v_codempid 
             and codapp = 'HRRP49X' 
             and item1 = r1.numpath;

          if v_count  = 0 then
            v_numseq := v_numseq + 1;
            if r1.numpath = p_numpath then
                v_select_numseq := v_numseq;
            end if;
            insert into ttemprpt (codempid,codapp,numseq, item1,item2) 
            values (global_v_codempid, 'HRRP49X', v_numseq, r1.numpath, to_char(r1.dteeffec,'dd/mm/yyyy'));
          end if;
      end loop;
    end if;

    if p_flgCount = -1 then
        begin
            select item1, to_date(item2,'dd/mm/yyyy')
              into v_numpath, v_dteeffec
              from ttemprpt 
             where codempid = global_v_codempid
               and codapp = 'HRRP49X'
               and numseq = v_select_numseq - 1;
            p_numpath   := v_numpath;
            p_dteeffec  := v_dteeffec;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2490',global_v_lang);
            return;
        end;
    elsif p_flgCount = 1 then
        begin
            select item1, to_date(item2,'dd/mm/yyyy')
              into v_numpath, v_dteeffec
              from ttemprpt 
             where codempid = global_v_codempid
               and codapp = 'HRRP49X'
               and numseq = v_select_numseq + 1;
            p_numpath := v_numpath;
            p_dteeffec  := v_dteeffec;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2495',global_v_lang);
            return;
        end;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_numpath;
end hrrp49x;

/
