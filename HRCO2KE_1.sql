--------------------------------------------------------
--  DDL for Package Body HRCO2KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2KE" AS
  procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codempid_query is not null
      and p_codcomp is not null
      and p_codpos is not null then
        p_codcomp := null;
        p_codpos := null;
        return;
    end if;
    if p_codcomp is not null and p_codpos is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
      return;
    end if;
    if p_codapp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codapp');
      return;
    end if;
    if p_codempid_query is not null then
      begin
        select codempid
        into   p_codempid_query
        from   temploy1
        where  codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
    end if;

    error_secur := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid_query);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;

    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;

  end;

  procedure check_save is
  error_secur VARCHAR2(4000 CHAR);
  staemp_tmp number;
  begin
    if p_codempid_query is null and p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    end if;
    if p_routeno is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'routeno');
      return;
    end if;

    if p_codempid_query is not null
      and p_codcomp is not null
      and p_codpos is not null then
        p_codcomp := null;
        p_codpos := null;
        return;
    end if;

    if p_codempid_query is not null then
      begin
        select codempid , staemp
        into   p_codempid_query, staemp_tmp
        from   temploy1
        where  codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
    end if;

    if (staemp_tmp = 9) then
      param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
      return;
    end if;

    error_secur := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, global_v_codempid);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;

    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
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
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_routeno           := hcm_util.get_string_t(json_obj,'p_routeno');
    p_dtecreate         := to_date(hcm_util.get_string_t(json_obj,'p_dtecreate'),'dd/mm/yyyy');
    p_codcreate         := hcm_util.get_string_t(json_obj,'p_codcreate');
    p_dteupd            := to_date(hcm_util.get_string_t(json_obj,'p_dteupd'),'dd/mm/yyyy');
    p_coduser           := hcm_util.get_string_t(json_obj,'p_coduser');

    p_rowid             := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
        select rowid as indexid, codapp,
            replace(codempid, '%', null) as codempid,
            replace(codcomp, '%', null) as codcomp,
            replace(codpos, '%', null) as codpos, routeno
        from temproute
        where codapp   =  p_codapp
        and ((codempid = nvl(p_codempid_query,codempid))
                and (codempid in (select codempid from temploy1
                                          where codcomp  like nvl(p_codcomp||'%','%')
                                          ))
       or ((codcomp like nvl(p_codcomp||'%','%') and p_codempid_query is null)
        and codpos   = nvl( p_codpos,codpos)))
        order by codempid desc,codcomp,codpos;
--    select rowid as indexid, codapp,
--            replace(codempid, '%', null) as codempid,
--            replace(codcomp, '%', null) as codcomp,
--            replace(codpos, '%', null) as codpos, routeno
--        from temproute
--        where codapp  = p_codapp
--            and (( codempid = nvl(p_codempid_query, codempid)))
--              or (codempid in (select codempid from temploy1
--                                where codcomp like p_codcomp||'%'
--                                and p_codcomp is not null))
--            and codcomp like p_codcomp||'%'
--            and codpos = nvl(p_codpos,codpos)
--        order by codempid desc, codcomp, codpos;

   begin


      obj_row := json_object_t();
      obj_data := json_object_t();
      obj_result := json_object_t();
      for r1 in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('indexid', r1.indexid);
        obj_data.put('codapp', r1.codapp);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('codpos', r1.codpos);
        obj_data.put('routeno', r1.routeno);

        obj_row.put(to_char(v_rcnt-1),obj_data);
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
  procedure get_data (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_temproute is
  begin
    begin
      insert into temproute (codapp, codempid, codcomp, codpos, routeno, coduser, codcreate)
      values(p_codapp, p_codempid_query, p_codcomp, p_codpos, p_routeno, global_v_coduser, global_v_codempid);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure delete_temproute is
  begin
    begin
      delete temproute where rowid = p_rowid;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;

  procedure check_data_save is
    v_rowcheck    VARCHAR2(20 CHAR) ;
    error_secur   VARCHAR2(4000 CHAR) ;
  begin
    begin
        select rowid
        into   v_rowcheck
        from   temproute
        where  codapp = p_codapp and codempid = p_codempid_query and codcomp = p_codcomp and codpos = p_codpos;
    exception when no_data_found then
        v_rowcheck := null ;
    end;

    if v_rowcheck is not null then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TEMPROUTE');
        return;
    end if;
  end;

  procedure edit_temproute(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_codapp          := hcm_util.get_string_t(param_json_row,'p_codapp');
        p_codempid_query  := hcm_util.get_string_t(param_json_row,'p_codempid_query');
        p_codcomp         := hcm_util.get_string_t(param_json_row,'p_codcomp');
        p_codpos          := hcm_util.get_string_t(param_json_row,'p_codpos');
        p_routeno         := hcm_util.get_string_t(param_json_row,'p_routeno');

        p_rowid           := hcm_util.get_string_t(param_json_row,'p_rowid');
        p_flg             := hcm_util.get_string_t(param_json_row,'p_flg');

        check_save;
        if(p_flg = 'add') then
         if p_codempid_query is not null then
           p_codcomp := '%';
           p_codpos  := '%';
         elsif p_codcomp is not null and p_codpos is not null then
           p_codempid_query := '%';
         end if;
         check_data_save;

         if param_msg_error is null then
            save_temproute;
         end if;
        end if;

        if(p_flg = 'edit') then
          begin
           update temproute 
              set routeno = p_routeno 
            where rowid = p_rowid;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;          
        end if;

        if(p_flg = 'delete') then
         delete_temproute;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
--        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRCO2KE;

/
