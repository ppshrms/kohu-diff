--------------------------------------------------------
--  DDL for Package Body M_HRCO2KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRCO2KE" AS
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

   procedure gen_tempflow (json_str_output out clob) is
     obj_data        json_object_t;
     obj_row         json_object_t;
     obj_result      json_object_t;
     v_rcnt          number := 0;
     v_check_secur   boolean := false;
     v_codcomp       temploy1.codcomp%type; -- issue4449#1485 22/11/2023

     cursor c1 is
       select tempflow.*
         from tempflow
   inner join temploy1
           on tempflow.codempid = temploy1.codempid
        where tempflow.codempid = nvl(p_codempid_query, tempflow.codempid)
          and temploy1.codcomp like p_codcomp || '%'
          and temploy1.codpos = nvl(p_codpos, temploy1.codpos)
          and tempflow.codapp = p_codapp  -- mo-kohu-sm2301
        order by tempflow.codempid;

   begin
     obj_row := json_object_t();
     obj_data := json_object_t();
     obj_result := json_object_t();
     for r1 in c1 loop
       if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then

         --> issue4449#1485 22/11/2023
         begin 
           select codcomp
             into v_codcomp
             from temploy1
            where CODEMPID = r1.codempid;
         end;
         --< issue4449#1485 22/11/2023

         v_check_secur := true;
         v_rcnt        := v_rcnt+1;
         obj_data      := json_object_t();
         obj_data.put('codapp', r1.codapp);
         obj_data.put('codempid', r1.codempid);
         obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_data.put('desc_codcompy', get_tcenter_name(v_codcomp,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_data.put('pctotreq1', r1.pctotreq1);
         obj_data.put('codappr1', r1.codappr1);
         obj_data.put('desc_codappr1', get_temploy_name(r1.codappr1,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_data.put('pctotreq2', r1.pctotreq2);
         obj_data.put('codappr2', r1.codappr2);
         obj_data.put('desc_codappr2', get_temploy_name(r1.codappr2,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_data.put('pctotreq3', r1.pctotreq3);
         obj_data.put('codappr3', r1.codappr3);
         obj_data.put('desc_codappr3', get_temploy_name(r1.codappr3,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_data.put('pctotreq4', r1.pctotreq4);
         obj_data.put('codappr4', r1.codappr4);
         obj_data.put('desc_codappr4', get_temploy_name(r1.codappr4,global_v_lang)); -- issue4449#1485 22/11/2023
         obj_row.put(to_char(v_rcnt-1),obj_data);
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

  procedure get_tempflow (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tempflow(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save_tempflow is
    error_secur     VARCHAR2(4000 CHAR);
    staemp_tmp      number;
    staemp1         number;
    staemp2         number;
    staemp3         number;
    staemp4         number;
  begin

--    ตรวจสอบสถานะพนักงาน
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

      if (staemp_tmp = 9) then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
        return;
      end if;
      if (staemp_tmp = 0) then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
        return;
      end if;
    end if;

--    เช็็คอัตรา OT ในแต่ละขั้น โดยห้ามน้อยกว่าหรือเท่ากับขั้นก่อนหน้า
    if p_pctotreq2 is not null then
      if TO_NUMBER(p_pctotreq1) >= TO_NUMBER(p_pctotreq2) then
        param_msg_error := get_error_msg_php('COZ001',global_v_lang);
        return;
      end if;
    end if;

    if p_pctotreq3 is not null then
      if TO_NUMBER(p_pctotreq2) >= TO_NUMBER(p_pctotreq3) then
        param_msg_error := get_error_msg_php('COZ001',global_v_lang);
        return;
      end if;
    end if;

    if p_pctotreq4 is not null then
      if TO_NUMBER(p_pctotreq3) >= TO_NUMBER(p_pctotreq4) then
        param_msg_error := get_error_msg_php('COZ001',global_v_lang);
        return;
      end if;
    end if;

--    เช็ตรหัสผู้อนุมัติไม่ให้ระบุซ้ำกัน
    if p_codappr2 is not null then
      if p_codappr1 = p_codappr2 then
        param_msg_error := get_error_msg_php('COZ002',global_v_lang);
        return;
      end if;
    end if;

    if p_codappr3 is not null then
      if (p_codappr1 = p_codappr3) or (p_codappr2 = p_codappr3) then
        param_msg_error := get_error_msg_php('COZ002',global_v_lang);
        return;
      end if;
    end if;

    if p_codappr4 is not null then
      if (p_codappr1 = p_codappr4) or (p_codappr2 = p_codappr4)or (p_codappr3 = p_codappr4) then
        param_msg_error := get_error_msg_php('COZ002',global_v_lang);
        return;
      end if;
    end if;

--    เช็คสถานพนักงานผู้อนุมัติ
    if p_codappr1 is not null then
      begin
        select staemp
          into staemp1
          from temploy1
         where codempid = p_codappr1;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;

      if (staemp1 = 9) then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
        return;
      end if;
      if (staemp1 = 0) then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
        return;
      end if;
    end if;

    if p_codappr2 is not null then
      begin
        select staemp
          into staemp2
          from temploy1
         where codempid = p_codappr2;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;

      if (staemp2 = 9) then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
        return;
      end if;
      if (staemp2 = 0) then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
        return;
      end if;
    end if;

    if p_codappr3 is not null then
      begin
        select staemp
          into staemp3
          from temploy1
         where codempid = p_codappr3;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;

      if (staemp3 = 9) then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
        return;
      end if;
      if (staemp3 = 0) then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
        return;
      end if;
    end if;

    if p_codappr4 is not null then
      begin
        select staemp
          into staemp4
          from temploy1
         where codempid = p_codappr4;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;

      if (staemp4 = 9) then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'codempid');
        return;
      end if;
      if (staemp4 = 0) then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'codempid');
        return;
      end if;
    end if;
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

  procedure edit_tempflow(json_str_input in clob, json_str_output out clob) as
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
        p_codappr1        := hcm_util.get_string_t(param_json_row,'p_codappr1');
        p_pctotreq1       := TO_NUMBER(hcm_util.get_string_t(param_json_row,'p_pctotreq1'));
        p_codappr2        := hcm_util.get_string_t(param_json_row,'p_codappr2');
        p_pctotreq2       := TO_NUMBER(hcm_util.get_string_t(param_json_row,'p_pctotreq2'));
        p_codappr3        := hcm_util.get_string_t(param_json_row,'p_codappr3');
        p_pctotreq3       := TO_NUMBER(hcm_util.get_string_t(param_json_row,'p_pctotreq3'));
        p_codappr4        := hcm_util.get_string_t(param_json_row,'p_codappr4');
        p_pctotreq4       := TO_NUMBER(hcm_util.get_string_t(param_json_row,'p_pctotreq4'));

        p_rowid           := hcm_util.get_string_t(param_json_row,'p_rowid');
        p_flg             := hcm_util.get_string_t(param_json_row,'p_flg');

        check_save_tempflow;
        if param_msg_error is not null then
--            ข้อความให้ดูที่ terrorm
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        if(p_flg = 'delete') then
          delete tempflow
--           where codapp = 'HRES6KE'  -- mo-kohu-sm2301
           where codapp = p_codapp  -- mo-kohu-sm2301
             and codempid = p_codempid_query;
        elsif(p_flg = 'add' or p_flg = 'edit') then
          begin
            insert_tempflow;
--            insert into tempflow(codapp, codempid, codappr1, pctotreq1, codappr2, pctotreq2, codappr3, pctotreq3, codappr4, pctotreq4)
--            values (p_codapp, p_codempid_query, p_codappr1, p_pctotreq1, p_codappr2, p_pctotreq2, p_codappr3, p_pctotreq3, p_codappr4, p_pctotreq4);
--         exception when dup_val_on_index then
--            update tempflow
--               set codappr1  = p_codappr1,  
--                   pctotreq1 = p_pctotreq1,  
--                   codappr2  = p_codappr2,  
--                   pctotreq2 = p_pctotreq2,  
--                   codappr3  = p_codappr3,  
--                   pctotreq3 = p_pctotreq3,  
--                   codappr4  = p_codappr4,  
--                   pctotreq4 = p_pctotreq4
--             where codapp    = p_codapp 
--               and codempid  = p_codempid_query; 
          end;
        end if;
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
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    format_text_json(json_str_input, v_rec_tran, v_rec_err);

    if param_msg_error is null then
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('rec_tran', v_rec_tran);
      obj_row.put('rec_err', v_rec_err);
      obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null)); 

      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first .. p_numseq.last loop
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;
      end if;

      obj_row.put('table', obj_result);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    --
    data_file 		   varchar2(6000 char);
    v_column	       number := 9;
    v_error			     boolean;
    v_err_code  	   varchar2(1000 char);
    v_err_field  	   varchar2(1000 char);
    v_err_table		   varchar2(20 char);
    -- 
    v_staemp         temploy1.staemp%type;
    v_staemp1        temploy1.staemp%type;
    v_staemp2        temploy1.staemp%type;
    v_staemp3        temploy1.staemp%type;
    v_staemp4        temploy1.staemp%type;

    v_check_data1    boolean := false;
    v_check_data2    boolean := false;
    v_check_data3    boolean := false;
    v_check_data4    boolean := false;

    v_flgfound  	   boolean;
    v_cnt			       number := 0;
    v_num            number := 0;
    v_concat         varchar2(10 char);

    i                number;
    type leng is table of number index by binary_integer; 
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    type text is table of varchar2(1000 char) index by binary_integer;
      v_text   text;
      v_field  text;
      v_key    text;

    type t_check_duplicate_data is table of boolean index by varchar2(30);  -- array
      v_check_duplicate_data        t_check_duplicate_data    := t_check_duplicate_data();

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;

      --assign chk_len 
--    for i in 1..v_column loop
--      if i in (1,2,4,6,8) then
--        chk_len(i) := 10;      
--      elsif i in (3,5,7,9) then
--        chk_len(i) := 5;
--      else
--        chk_len(i) := 0;   
--      end if;
--    end loop;

    for i in 1..v_column loop
      v_field(i) := null;
      v_key(i)   := null;
    end loop;
    p_codapp     := hcm_util.get_string_t(json_object_t(json_str_input),'p_codapp');
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
      v_key(v_num)      := hcm_util.get_string_t(param_column_row,'key');
    end loop;
    --
    for rw in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(rw));

      begin
        v_err_code      := null;
        v_err_field     := null;
        v_err_table     := null;
        v_error 	    := false;
        --
        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,v_key(1));  -- codempid
          v_text(2)   := hcm_util.get_string_t(param_json_row,v_key(2));  -- codappr1
          v_text(3)   := hcm_util.get_string_t(param_json_row,v_key(3));  -- pctotreq1
          v_text(4)   := hcm_util.get_string_t(param_json_row,v_key(4));  -- codappr2
          v_text(5)   := hcm_util.get_string_t(param_json_row,v_key(5));  -- pctotreq2
          v_text(6)   := hcm_util.get_string_t(param_json_row,v_key(6));  -- codappr3
          v_text(7)   := hcm_util.get_string_t(param_json_row,v_key(7));  -- pctotreq3
          v_text(8)   := hcm_util.get_string_t(param_json_row,v_key(8));  -- codappr4
          v_text(9)   := hcm_util.get_string_t(param_json_row,v_key(9));  -- pctotreq4

          p_codempid_query   := v_text(1);
          p_pctotreq1        := TO_NUMBER(v_text(2));
          p_codappr1         := v_text(3);
          p_pctotreq2        := TO_NUMBER(v_text(4));
          p_codappr2         := v_text(5);
          p_pctotreq3        := TO_NUMBER(v_text(6));
          p_codappr3         := v_text(7);
          p_pctotreq4        := TO_NUMBER(v_text(8));
          p_codappr4         := v_text(9);

          -- push row values
          data_file := null;
          v_concat := null;
          for i in 1..v_column loop
            data_file := data_file||v_concat||v_text(i);
            v_concat  := ',';
          end loop;

          -- check null in codempid
          if v_text(1) is null then
            v_error	 	:= true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(1);
--            v_err_table := 'TEMPLOY1'; issue4448#10001
            exit cal_loop;
          end if;

          -- check data in temploy1           
          begin
            select codempid, staemp
              into v_codempid, v_staemp
              from temploy1
             where codempid = v_text(1);
         exception when no_data_found then
           v_error	   := true;
           v_err_code  := 'HR2010';
           v_err_field := v_field(1);
           exit cal_loop;
           return;
          end;

          -- เช็คสิทธิ์ดูข้อมูล
          if not secur_main.secur2(v_text(1), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_error	    := true;
            v_err_code  := 'HR3007';
            v_err_field := v_field(1);
            exit cal_loop;
            return;
          end if;

          -- check status codempid
          if v_staemp = 0 then
            v_error	    := true;
            v_err_code  := 'HR2102';
            v_err_field := v_field(1);
            exit cal_loop;
          elsif v_staemp = 9 then
            v_error	    := true;
            v_err_code  := 'HR2101';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

           --check length all columns    
--          for i in 1..v_column loop
--            if v_text(i) is not null or length(trim(v_text(i))) is not null then                                 
--              if(length(v_text(i)) > chk_len(i)) then                               
--                v_error     := true;
--                v_err_code  := 'HR2020';
--                v_err_field := v_field(i);
--                exit cal_loop;
--              end if;   
--            end if;
--          end loop;

          if not v_check_duplicate_data.Exists(v_text(1)) then --เช็คตัวที่มีอยู่ ถ้าไม่มีตัวซ้ำให้เก็บค่า true
            v_check_duplicate_data(v_text(1))   := true;
          else
            v_error	 := true;
            v_err_code  := 'COZ004';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

          if (v_text(2) is null or v_text(3) is null) then
            if v_text(2) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(2);
              exit cal_loop;
            end if;
            if v_text(3) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;
          else
            v_check_data1   := true;
          end if;

         if ((v_text(4) is null or v_text(5) is null) and v_check_data1 = false) then
           if v_text(4) is null then
             v_error	 := true;
             v_err_code  := 'HR2045';
             v_err_field := v_field(4);
             exit cal_loop;
           end if;
           if v_text(5) is null then
             v_error	 := true;
             v_err_code  := 'HR2045';
             v_err_field := v_field(5);
             exit cal_loop;
           end if;
         else
           if v_text(4) is not null and v_text(5) is null then
             v_error	 := true;
             v_err_code  := 'HR2045';
             v_err_field := v_field(5);
             exit cal_loop;
           end if;
           if v_text(5) is not null and v_text(4) is null then
             v_error	 := true;
             v_err_code  := 'HR2045';
             v_err_field := v_field(4);
             exit cal_loop;
           end if;
           if v_text(4) is null and v_text(5) is null then
             v_check_data2   := false;
           else
             if TO_NUMBER(v_text(2)) >= TO_NUMBER(v_text(4)) then
               v_error	   := true;
               v_err_code  := 'COZ001';
               v_err_field := v_field(4);
               exit cal_loop;
             end if;
             if v_text(5) = v_text(3) then -- เช็ครหัสผู้อนุมัติห้ามซ้ำกับตัวอื่น
               v_error	   := true;
               v_err_code  := 'COZ002';
               v_err_field := v_field(5);
               exit cal_loop;
             end if;
             if v_check_data1 = false then
               v_error	   := true;
               v_err_code  := 'HR2045';
               v_err_field := v_field(2);
               exit cal_loop;
             end if;
             v_check_data2   := true;
           end if;
         end if;

         if ((v_text(6) is null or v_text(7) is null) and (v_check_data2 = false and v_check_data1 = false)) then
           if v_text(6) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(6);
              exit cal_loop;
            end if;
            if v_text(7) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(7);
              exit cal_loop;
            end if;
         else
            if v_text(6) is not null and v_text(7) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(7);
              exit cal_loop;
            end if;
            if v_text(7) is not null and v_text(6) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(6);
              exit cal_loop;
            end if;
            if v_text(6) is null and v_text(7) is null then
              v_check_data3   := false;
            else
              if TO_NUMBER(v_text(4)) >= TO_NUMBER(v_text(6)) then
                v_error	    := true;
                v_err_code  := 'COZ001';
                v_err_field := v_field(6);
                exit cal_loop;
              end if;
              if v_text(7) = v_text(5) or v_text(7) = v_text(3) then 
                v_error	    := true;
                v_err_code  := 'COZ002';
                v_err_field := v_field(7);
                exit cal_loop;
              end if;
              if (v_check_data2 = false) then
                v_error	    := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(4);
                exit cal_loop;
              end if;
              v_check_data3   := true;
            end if;
         end if;

         if ((v_text(8) is null or v_text(9) is null) and (v_check_data3 = false and v_check_data2 = false and v_check_data1 = false)) then
           if v_text(8) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(8);
              exit cal_loop;
            end if;
            if v_text(9) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(9);
              exit cal_loop;
            end if;
         else
            if v_text(8) is not null and v_text(9) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(9);
              exit cal_loop;
            end if;
            if v_text(9) is not null and v_text(8) is null then
              v_error	  := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(8);
              exit cal_loop;
            end if;
            if v_text(8) is null and v_text(9) is null then
              v_check_data4   := false;
            else
              if TO_NUMBER(v_text(6)) >= TO_NUMBER(v_text(8)) then
                v_error	    := true;
                v_err_code  := 'COZ001';
                v_err_field := v_field(8);
                exit cal_loop;
              end if;
              if v_text(9) = v_text(7) or v_text(9) = v_text(5) or v_text(9) = v_text(3) then 
                v_error	    := true;
                v_err_code  := 'COZ002';
                v_err_field := v_field(9);
                exit cal_loop;
              end if;
              if (v_check_data3 = false) then
                v_error	    := true;
                v_err_code  := 'HR2045';
                v_err_field := v_field(6);
                exit cal_loop;
              end if;
              v_check_data4   := true;
            end if;
         end if;


          --          เช็ตผู้อนุมัติ
          if v_text(3) is not null then
            begin
              select staemp
                into v_staemp1
                from temploy1
               where codempid = v_text(3);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(3);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(3), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(3);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp1 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(3);
              exit cal_loop;
            elsif v_staemp1 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;
          end if;

--          เช็ตผู้อนุมัติ
          if v_text(5) is not null then
            begin
              select staemp
                into v_staemp2
                from temploy1
               where codempid = v_text(5);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(5);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(5), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(5);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp2 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(5);
              exit cal_loop;
            elsif v_staemp2 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(5);
              exit cal_loop;
            end if;
          end if;

--          เช็ตผู้อนุมัติ
          if v_text(7) is not null then
            begin
              select staemp
                into v_staemp3
                from temploy1
               where codempid = v_text(7);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(7);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(7), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(7);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp3 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(7);
              exit cal_loop;
            elsif v_staemp3 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(7);
              exit cal_loop;
            end if;
          end if;

--          เช็ตผู้อนุมัติ
          if v_text(9) is not null then
            begin
              select staemp
                into v_staemp3
                from temploy1
               where codempid = v_text(9);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(9);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(9), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(9);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp3 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(9);
              exit cal_loop;
            elsif v_staemp3 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(9);
              exit cal_loop;
            end if;
          end if;

          exit cal_loop;
        end loop; -- cal_loop

        -- update status
        if not v_error then
          v_rec_tran   := v_rec_tran + 1;
          insert_tempflow;
          commit;
        else
          v_rec_error  := v_rec_error + 1;
          v_cnt        := v_cnt+1;

          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||' ['||v_err_field||']';
          p_numseq(v_cnt)     := rw;
        end if;--not v_error

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

  --> mo-kohu-sm2301
  procedure get_work_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    format_work_text_json(json_str_input, v_rec_tran, v_rec_err);

    if param_msg_error is null then
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('rec_tran', v_rec_tran);
      obj_row.put('rec_err', v_rec_err);
      obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null)); 

      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first .. p_numseq.last loop
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;
      end if;

      obj_row.put('table', obj_result);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure format_work_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    --
    data_file 		   varchar2(6000 char);
    v_column	       number := 5;
    v_error			     boolean;
    v_err_code  	   varchar2(1000 char);
    v_err_field  	   varchar2(1000 char);
    v_err_table		   varchar2(20 char);
    -- 
    v_staemp         temploy1.staemp%type;
    v_staemp1        temploy1.staemp%type;
    v_staemp2        temploy1.staemp%type;
    v_staemp3        temploy1.staemp%type;
    v_staemp4        temploy1.staemp%type;

    v_flgfound  	   boolean;
    v_cnt			       number := 0;
    v_num            number := 0;
    v_concat         varchar2(10 char);

    i                number;
    type leng is table of number index by binary_integer; 
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 

    type text is table of varchar2(1000 char) index by binary_integer;
      v_text   text;
      v_field  text;
      v_key    text;

    type t_check_duplicate_data is table of boolean index by varchar2(30);  -- array
      v_check_duplicate_data        t_check_duplicate_data    := t_check_duplicate_data();

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;

    for i in 1..v_column loop
      v_field(i) := null;
      v_key(i)   := null;
    end loop;
    p_codapp     := hcm_util.get_string_t(json_object_t(json_str_input),'p_codapp');
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
      v_key(v_num)      := hcm_util.get_string_t(param_column_row,'key');
    end loop;
    --
    for rw in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(rw));

      begin
        v_err_code      := null;
        v_err_field     := null;
        v_err_table     := null;
        v_error 	    := false;
        --
        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,v_key(1));  -- codempid
          v_text(2)   := hcm_util.get_string_t(param_json_row,v_key(2));  -- codappr1
          v_text(3)   := hcm_util.get_string_t(param_json_row,v_key(3));  -- codappr2
          v_text(4)   := hcm_util.get_string_t(param_json_row,v_key(4));  -- codappr3
          v_text(5)   := hcm_util.get_string_t(param_json_row,v_key(5));  -- codappr4

          p_codempid_query   := v_text(1);
          p_codappr1         := v_text(2);
          p_codappr2         := v_text(3);
          p_codappr3         := v_text(4);
          p_codappr4         := v_text(5);

          -- push row values
          data_file := null;
          v_concat := null;
          for i in 1..v_column loop
            data_file := data_file||v_concat||v_text(i);
            v_concat  := ',';
          end loop;

          -- check null in codempid
          if v_text(1) is null then
            v_error	 	:= true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;
          -- check data in temploy1           
          begin
            select codempid, staemp
              into v_codempid, v_staemp
              from temploy1
             where codempid = v_text(1);
         exception when no_data_found then
           v_error	   := true;
           v_err_code  := 'HR2010';
           v_err_field := v_field(1);
           exit cal_loop;
           return;
          end;

          -- เช็คสิทธิ์ดูข้อมูล
          if not secur_main.secur2(v_text(1), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_error	    := true;
            v_err_code  := 'HR3007';
            v_err_field := v_field(1);
            exit cal_loop;
            return;
          end if;

          -- check status codempid
          if v_staemp = 0 then
            v_error	    := true;
            v_err_code  := 'HR2102';
            v_err_field := v_field(1);
            exit cal_loop;
          elsif v_staemp = 9 then
            v_error	    := true;
            v_err_code  := 'HR2101';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

          if not v_check_duplicate_data.Exists(v_text(1)) then --เช็คตัวที่มีอยู่ ถ้าไม่มีตัวซ้ำให้เก็บค่า true
            v_check_duplicate_data(v_text(1))   := true;
          else
            v_error	 := true;
            v_err_code  := 'COZ004';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

--          เช็ตผู้อนุมัติขั้นที่ 1
          if v_text(2) is null then
             v_error	 	 := true;
             v_err_code  := 'HR2045';
             v_err_field := v_field(2);
            exit cal_loop;
          end if;

--          if v_text(2) is not null then
          begin
            select staemp
              into v_staemp1
              from temploy1
             where codempid = v_text(2);
         exception when no_data_found then
            v_error	   := true;
            v_err_code  := 'HR2010';
            v_err_field := v_field(2);
            exit cal_loop;
            return;
          end;

--           เช็คสิทธิ์ดูข้อมูล
          if not secur_main.secur2(v_text(2), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_error	   := true;
            v_err_code  := 'HR3007';
            v_err_field := v_field(2);
            exit cal_loop;
            return;
          end if;

--           check status
          if v_staemp1 = 0 then
            v_error	   := true;
            v_err_code  := 'HR2102';
            v_err_field := v_field(2);
            exit cal_loop;
          elsif v_staemp1 = 9 then
            v_error	   := true;
            v_err_code  := 'HR2101';
            v_err_field := v_field(2);
            exit cal_loop;
          end if;
--          end if;

--          เช็ตผู้อนุมัติขั้นที่ 2
          if v_text(3) is not null then
            begin
              select staemp
                into v_staemp2
                from temploy1
               where codempid = v_text(3);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(3);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(3), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(3);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp2 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(3);
              exit cal_loop;
            elsif v_staemp2 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;

--          เช็คผู้อนุมัติห้ามซ้ำกัน
            if (v_text(2) = v_text(3)) then
              v_error	   := true;
              v_err_code  := 'COZ002';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;
          end if;

--          เช็ตผู้อนุมัติขั้นที่ 3
          if v_text(4) is not null then
            begin
              select staemp
                into v_staemp3
                from temploy1
               where codempid = v_text(4);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(4);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(4), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(4);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp3 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(4);
              exit cal_loop;
            elsif v_staemp3 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(4);
              exit cal_loop;
            end if;

            if (v_text(2) = v_text(4)) or (v_text(3) = v_text(4))  then
              v_error	   := true;
              v_err_code  := 'COZ002';
              v_err_field := v_field(4);
              exit cal_loop;
            end if;

            if v_text(3) is null then
              insert into A(a, b) values('text3(1)', v_text(3));
              commit;
              v_error	   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;
          end if;
          insert into A(a, b) values('text5(1)', v_text(5));
              commit;
--          เช็ตผู้อนุมัติขั้นที่ 4
          if v_text(5) is not null then
            begin
              select staemp
                into v_staemp3
                from temploy1
               where codempid = v_text(5);
           exception when no_data_found then
              v_error	   := true;
              v_err_code  := 'HR2010';
              v_err_field := v_field(5);
              exit cal_loop;
              return;
            end;

--           เช็คสิทธิ์ดูข้อมูล
            if not secur_main.secur2(v_text(5), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	   := true;
              v_err_code  := 'HR3007';
              v_err_field := v_field(5);
              exit cal_loop;
              return;
            end if;

--           check status
            if v_staemp3 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_field := v_field(5);
              exit cal_loop;
            elsif v_staemp3 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_field := v_field(5);
              exit cal_loop;
            end if;
--            issue4449#1686 remove end if
            if (v_text(2) = v_text(5)) or (v_text(3) = v_text(5)) or (v_text(4) = v_text(5))  then
              v_error	   := true;
              v_err_code  := 'COZ002';
              v_err_field := v_field(5);
              exit cal_loop;
            end if;

            if v_text(3) is null then
              insert into A(a, b) values('text3', v_text(3));
              commit;
              v_error	   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(3);
              exit cal_loop;
            end if;

            if v_text(4) is null then
              v_error	   := true;
              v_err_code  := 'HR2045';
              v_err_field := v_field(4);
              exit cal_loop;
            end if;
--            issue4449#1686 move end if
          end if;

          exit cal_loop;
        end loop; -- cal_loop

        -- update status
        if not v_error then
          v_rec_tran   := v_rec_tran + 1;
          insert_tempflow;
          commit;
        else
          v_rec_error  := v_rec_error + 1;
          v_cnt        := v_cnt+1;

          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||' ['||v_err_field||']';
          p_numseq(v_cnt)     := rw;
        end if;--not v_error

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
  --< mo-kohu-sm2301

  procedure insert_tempflow is
  begin
    begin
       insert into tempflow(codapp, codempid, codappr1, pctotreq1, codappr2, pctotreq2, codappr3, pctotreq3, codappr4, pctotreq4, codcreate, coduser)
            values (p_codapp, p_codempid_query, p_codappr1, p_pctotreq1, p_codappr2, p_pctotreq2, p_codappr3, p_pctotreq3, p_codappr4, p_pctotreq4, global_v_coduser, global_v_coduser);
         exception when dup_val_on_index then
            update tempflow
               set codappr1  = p_codappr1,  
                   pctotreq1 = p_pctotreq1,  
                   codappr2  = p_codappr2,  
                   pctotreq2 = p_pctotreq2,  
                   codappr3  = p_codappr3,  
                   pctotreq3 = p_pctotreq3,  
                   codappr4  = p_codappr4,  
                   pctotreq4 = p_pctotreq4,
                   coduser   = global_v_coduser
             where codapp    = p_codapp 
               and codempid  = p_codempid_query; 
    end;
  exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
  end;

END M_HRCO2KE;

/
