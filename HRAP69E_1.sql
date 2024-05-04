--------------------------------------------------------
--  DDL for Package Body HRAP69E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP69E" as
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
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_codcompyquery     := hcm_util.get_string_t(json_obj,'p_codcompyQuery');
    p_dteeffecquery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');
    p_isEdit            := hcm_util.get_boolean_t(json_obj,'p_isEdit');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure check_index is
    v_codcompy    tcompny.codcompy%type;
    v_dteeffec    tnineboxap.dteeffec%type;
    v_flgSecur    boolean;
    v_flgExist    number;
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      begin
        select codcompy 
          into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_box         json_object_t;
    obj_syncond     json_object_t;
    v_description   varchar2(4000 char);
    v_statement     tnineboxap.statement%type;
    v_syncond       tnineboxap.syncond%type;
    v_codgroup      tnineboxap.codgroup%type;
    v_namgroupt     tnineboxap.namgroupt%type;
    v_descgroup     tnineboxap.descgroup%type;
    v_flgsecur      boolean;
    v_msg_error     varchar2(4000 char) := '';
    v_response      varchar2(4000 char) := '';

  begin
    gen_flg_status;
    obj_data        := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcompy',p_codcompy);
    obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
    obj_data.put('flgDisable',v_flgDisabled);
    obj_data.put('isAdd',isAdd);
    obj_data.put('isEdit',isEdit);
    
    if v_flgDisabled then
      obj_data.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
    end if;
    --box 
    for i in 1..9 loop
      v_codgroup    := i;
      get_data_box(v_codgroup, p_codcompy, p_dteeffecquery, v_namgroupt, v_descgroup, v_statement, v_syncond);
      v_description := get_logical_desc(v_statement);
      obj_box       := json_object_t();
      obj_syncond := json_object_t();
      obj_syncond.put('code', nvl(v_syncond,''));
      obj_syncond.put('statement', nvl(v_statement,''));
      obj_syncond.put('description', nvl(v_description,''));
      obj_box.put('codgroup', nvl(v_codgroup,''));
      obj_box.put('namgroupt', nvl(v_namgroupt,''));
      obj_box.put('descgroup', nvl(v_descgroup,''));
      obj_box.put('syncond', obj_syncond);
      obj_data.put('box'||i, obj_box);
    end loop;
    if param_msg_error is null then
      json_str_output   := obj_data.to_clob;
    else
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_data_box(v_codgroup in varchar2, v_codcompy in tnineboxap.codcompy%type, v_dteeffec in date,
                                                 v_namgroupt out tnineboxap.namgroupt%type, 
                                                 v_descgroup out tnineboxap.descgroup%type, 
                                                 v_statement out tnineboxap.statement%type, 
                                                 v_syncond out tnineboxap.syncond%type) as
  begin
    begin
      select nvl(descgroup,''), nvl(namgroupt,''), nvl(statement,''), nvl(syncond ,'')
        into v_descgroup, v_namgroupt, v_statement, v_syncond
        from tnineboxap
       where codcompy = v_codcompy 
         and dteeffec = v_dteeffec 
         and codgroup = v_codgroup;
    exception when no_data_found then
      v_namgroupt := '';    v_descgroup := ''; 
      v_statement := '[]';  v_syncond   := ''; 
    end;
    if v_statement is null then
      v_statement := '[]';
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure check_save(json_str_input in clob) is
    v_flgDup      boolean := false;
    param_object  json_object_t;
    obj_box       json_object_t;
    obj_syncond   json_object_t;
    v_syncond1    tnineboxap.syncond%type;
    v_syncond2    tnineboxap.syncond%type;
  begin
    obj_syncond   := json_object_t();
    obj_box       := json_object_t();
    param_object  := json_object_t();

    param_object  := hcm_util.get_json_t(json_object_t(json_str_input),'params');    
    for i in 1..9 loop
      obj_box       := hcm_util.get_json_t(param_object,'box'||i);
      obj_syncond   := hcm_util.get_json_t(obj_box,'syncond');
      v_syncond1     := hcm_util.get_string_t(obj_syncond,'code');

      for j in 1..9 loop
        obj_box       := hcm_util.get_json_t(param_object,'box'||j);
        obj_syncond   := hcm_util.get_json_t(obj_box,'syncond');
        v_syncond2     := hcm_util.get_string_t(obj_syncond,'code');
        if i <> j then
          if v_syncond1 = v_syncond2 then
            v_flgDup := true;
            exit;
          end if;
        end if;
      end loop;
      if v_flgDup then
        param_msg_error := get_error_msg_php('HR1503',global_v_lang);
        exit;
      end if;
    end loop;
  end;
  procedure save_data(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
    obj_syncond       json_object_t;
    obj_box           json_object_t;
    param_object      json_object_t;

    v_syncond         tnineboxap.syncond%type;
    v_statement       clob;
    v_codgroup        tnineboxap.codgroup%type;
    v_namgroupt       tnineboxap.namgroupt%type;
    v_descgroup       tnineboxap.descgroup%type;
    type namgroup_ninebox is varray(9) of varchar2(1000 char);
	data_namgroup     namgroup_ninebox;
    type descgroup_ninebox is varray(9) of  varchar2(1000 char);
	data_descgroup    descgroup_ninebox;
  begin
    initial_value(json_str_input);
    check_save(json_str_input);
    if param_msg_error is null then
      obj_syncond   := json_object_t();
      obj_box       := json_object_t();
      param_object  := json_object_t();

      data_namgroup := namgroup_ninebox(get_label_name('HRAP69E1',global_v_lang,121),
                                        get_label_name('HRAP69E1',global_v_lang,91),
                                        get_label_name('HRAP69E1',global_v_lang,71),
                                        get_label_name('HRAP69E1',global_v_lang,191),
                                        get_label_name('HRAP69E1',global_v_lang,171),
                                        get_label_name('HRAP69E1',global_v_lang,151),
                                        get_label_name('HRAP69E1',global_v_lang,261),
                                        get_label_name('HRAP69E1',global_v_lang,241),
                                        get_label_name('HRAP69E1',global_v_lang,221));

      data_descgroup := descgroup_ninebox(get_label_name('HRAP69E1',global_v_lang,100),
                                          get_label_name('HRAP69E1',global_v_lang,80),
                                          get_label_name('HRAP69E1',global_v_lang,50),
                                          get_label_name('HRAP69E1',global_v_lang,120),
                                          get_label_name('HRAP69E1',global_v_lang,160),
                                          get_label_name('HRAP69E1',global_v_lang,130),
                                          get_label_name('HRAP69E1',global_v_lang,250),
                                          get_label_name('HRAP69E1',global_v_lang,230),
                                          get_label_name('HRAP69E1',global_v_lang,200));

      param_object  := hcm_util.get_json_t(json_object_t(json_str_input),'params');
      for i in 1..9 loop
        obj_box       := hcm_util.get_json_t(param_object,'box'||i);
        obj_syncond   := hcm_util.get_json_t(obj_box,'syncond');
        v_syncond     := hcm_util.get_string_t(obj_syncond,'code');
        v_statement   := hcm_util.get_string_t(obj_syncond,'statement');

        v_codgroup    := i;
--        regexp_replace('(HH)','\(|\)','')
--        v_namgroupt   := regexp_replace(data_namgroup(i),'\(|\)','');
        v_namgroupt   := hcm_util.get_string_t(obj_box,'namgroupt');
        v_descgroup   := hcm_util.get_string_t(obj_box,'descgroup');
--        v_descgroup   := data_descgroup(i);
        begin
          insert into tnineboxap (codcompy, dteeffec, codgroup, namgroupt, descgroup,
                                syncond, statement,
                                codcreate, coduser)
                 values (p_codcompy, p_dteeffec, v_codgroup, v_namgroupt, v_descgroup, 
                         v_syncond, v_statement,
                         global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
           begin 
              update tnineboxap
                 set namgroupt = v_namgroupt,
                     descgroup = v_descgroup,
                     syncond = v_syncond,
                     statement = v_statement
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and codgroup = v_codgroup;
            end;
        end;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
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
   procedure gen_copy_data(json_str_output out clob) as
    obj_data        json_object_t;
    obj_box         json_object_t;
    obj_syncond     json_object_t;
    v_description   varchar2(4000 char);
    v_statement     tnineboxap.statement%type;
    v_syncond       tnineboxap.syncond%type;
    v_codgroup      tnineboxap.codgroup%type;
    v_namgroupt     tnineboxap.namgroupt%type;
    v_descgroup     tnineboxap.descgroup%type;

    v_flgsecur      boolean;

  begin

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcompy',p_codcompy);
    obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
    obj_data.put('flgDisable',false);
    obj_data.put('isAdd',true);
    obj_data.put('isEdit',false);
    --box 
    for i in 1..9 loop
      v_codgroup    := i;
      get_data_box(v_codgroup, p_codcompyquery, p_dteeffecquery, v_namgroupt, v_descgroup, v_statement, v_syncond);
      v_description := get_logical_desc(v_statement);

      obj_box       := json_object_t();
      obj_syncond   := json_object_t();
      obj_syncond.put('code', nvl(v_syncond,''));
      obj_syncond.put('statement', nvl(v_statement,''));
      obj_syncond.put('description', nvl(v_description,''));
      obj_box.put('codgroup', nvl(v_codgroup,''));
      obj_box.put('namgroupt', nvl(v_namgroupt,''));
      obj_box.put('descgroup', nvl(v_descgroup,''));
      obj_box.put('syncond', obj_syncond);
      obj_data.put('box'||i, obj_box);
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

  procedure copy_data(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_popup_copy(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    cursor c1 is
      select distinct codcompy, dteeffec 
        from tnineboxap
       where codcompy||to_char(dteeffec,'yyymmdd') <> p_codcompy||to_char(p_dteeffec,'yyymmdd')
    order by codcompy, dteeffec;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      if secur_main.secur7(r1.codcompy,global_v_coduser) then
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('desc_codcompy', r1.codcompy || ' - ' || get_tcenter_name(get_compful(r1.codcompy), global_v_lang));
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
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

  procedure popup_copy(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_copy(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
      begin
        select count(*) into v_count
          from tnineboxap
         where codcompy = p_codcompy
           and dteeffec  = p_dteeffec;
      exception when no_data_found then
        v_count := 0;
      end;  
      
      if v_count = 0 then
        select max(dteeffec) 
          into v_maxdteeffec
          from tnineboxap
         where codcompy = p_codcompy
           and dteeffec <= p_dteeffec;
        if v_maxdteeffec is null then
            select min(dteeffec) into v_maxdteeffec
              from tnineboxap
             where codcompy = p_codcompy
               and dteeffec > p_dteeffec; 
            if v_maxdteeffec is null then
              v_flgDisabled := false;
            else 
                v_flgDisabled       := true;
                p_dteeffecquery     := v_maxdteeffec;
                p_dteeffec          := v_maxdteeffec;
            end if;
        else
            if p_dteeffec < trunc(sysdate) then
              v_flgDisabled := true;          
              p_dteeffec := v_maxdteeffec;       
            else
              v_flgDisabled := false;
            end if;
            p_dteeffecquery := v_maxdteeffec;       
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
  end gen_flg_status;

--  procedure gen_flg_status as
--    v_dteeffec        date;
--    v_count           number := 0;
--    v_maxdteeffec     date;
--  begin
--    begin
--        select count(*) 
--          into v_count
--          from tnineboxap
--         where codcompy = p_codcompy
--           and dteeffec  = p_dteeffec;
--        v_indexdteeffec := p_dteeffec;
--    exception when no_data_found then
--        v_count := 0;
--    end;
--
--    if v_count = 0 then
--        select max(dteeffec) 
--          into v_maxdteeffec
--          from tnineboxap
--         where codcompy = p_codcompy
--           and dteeffec <= p_dteeffec;
--
--        if v_maxdteeffec is null then
--          v_flgDisabled := false;          
--        else
--          if p_dteeffec < trunc(sysdate) then
--            v_flgDisabled       := true;
--            p_dteeffecquery     := v_maxdteeffec;
--            p_dteeffec          := v_maxdteeffec;
--          else
--            v_flgDisabled       := false;
--            p_dteeffecquery     := v_maxdteeffec;
--          end if;
--        end if;
--      else
--        if p_dteeffec < trunc(sysdate) then
--          v_flgDisabled := true;
--        else
--          v_flgDisabled := false;
--        end if;
--        p_dteeffecquery := p_dteeffec;
--      end if;
--
--    if p_dteeffecquery < p_dteeffec or p_dteeffecquery is null then
--        isAdd           := true;
--        isEdit          := false;
--    else
--        isAdd           := false;
--        isEdit          := not v_flgDisabled;
--    end if;
--
--    if forceAdd = 'Y' then
--      isEdit := false;
--      isAdd  := true;
--    end if;
--  end;

end HRAP69E;

/
