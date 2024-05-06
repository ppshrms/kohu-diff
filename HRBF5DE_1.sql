--------------------------------------------------------
--  DDL for Package Body HRBF5DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5DE" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_codlon          := hcm_util.get_string_t(json_obj,'p_codlon');
        p_dteeffec        := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

  end initial_value;

    procedure initial_save(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        param_detail        := hcm_util.get_json_t(json_obj,'indexData');
        param_table         := hcm_util.get_json_t(json_obj,'table');

        isAdd               := hcm_util.get_boolean_t(param_detail,'isAdd');
        isEdit              := hcm_util.get_boolean_t(param_detail,'isEdit');
        p_codcompy          := upper(hcm_util.get_string_t(param_detail,'codcompy'));
        p_codlon            := hcm_util.get_string_t(param_detail,'codlon');
        p_dteeffec          := to_date(hcm_util.get_string_t(param_detail,'dteeffec'),'dd/mm/yyyy');

        p_codpayc           := hcm_util.get_string_t(param_detail,'codpayc');
        p_codpayd           := hcm_util.get_string_t(param_detail,'codpayd');
        p_codpaye           := hcm_util.get_string_t(param_detail,'codpaye');
        p_typintr           := hcm_util.get_string_t(param_detail,'typintr');
        p_formula           := hcm_util.get_json_t(param_detail,'formula');
        p_code              := hcm_util.get_string_t(p_formula,'code');
        p_description       := hcm_util.get_string_t(p_formula,'description');
    end initial_save;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
    if p_codcompy is null or p_dteeffec is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tcompny
        where codcompy = p_codcompy;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
    end;

    begin
        select 'X' into v_temp
        from ttyploan
        where codlon = p_codlon;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTYPLOAN');
        return;
    end;

--  check secur7
    if secur_main.secur7(p_codcompy,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

  end check_index;

  procedure check_params1 as
    v_temp     varchar(1 char);
  begin
    if p_codpayc is null or p_codpayd is null or p_codpaye is null or p_typintr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tinexinfc
        where codcompy = p_codcompy
          and codpay = p_codpayc;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinfc');
        return;
    end;

    begin
        select 'X' into v_temp
        from tinexinf
        where codpay = p_codpayc
          and typpay in('5','6');
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinfc');
        return;
    end;

    begin
        select 'X' into v_temp
        from tinexinfc
        where codcompy = p_codcompy
          and codpay = p_codpaye;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinfc');
        return;
    end;

    begin
        select 'X' into v_temp
        from tinexinf
        where codpay = p_codpaye
          and typpay in ('2','3');
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
    end;

    if p_rateilon is not null and param_table.get_size != 0 then
        p_rateilon := null;
    end if;

    if p_typintr = '2' then
        if p_formula is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    else
        p_formula := null;
    end if;

  end check_params1;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_tintrteh      tintrteh%rowtype;
    v_exist         boolean;
    v_temp          varchar(10 char);
  begin
    begin
        select * 
          into v_tintrteh
          from tintrteh
         where codcompy = p_codcompy
           and codlon = p_codlon
           and dteeffec = p_dteeffecquery;
    exception when no_data_found then
        v_tintrteh := null;
    end;

    obj_data := json_object_t();

    obj_data.put('coderror',200);
    obj_data.put('isAdd',isAdd);
    obj_data.put('isEdit',isEdit);
    obj_data.put('codcompy',p_codcompy);
    obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
    obj_data.put('codlon',p_codlon);
    obj_data.put('codpayc',v_tintrteh.codpayc);
    obj_data.put('codpayd',v_tintrteh.codpayd);
    obj_data.put('codpaye',v_tintrteh.codpaye);
    obj_data.put('typintr',v_tintrteh.typintr);
--  add logical statement
    obj_data2 := json_object_t();
    obj_data2.put('code',v_tintrteh.formula);
    obj_data2.put('description',hcm_formula.get_description(v_tintrteh.formula,global_v_lang));--User37 #3450 BF Module 08/04/2021 get_logical_name('HRBF5DE',v_tintrteh.formula,global_v_lang));
    obj_data2.put('statement',v_tintrteh.statement);    
    obj_data.put('formula',obj_data2);
    if v_flgDisabled then
        obj_data.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
    end if;


    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_index;

  procedure gen_index_table(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_exist         boolean;
    v_temp          varchar(5 char);
    cursor c1 is
        select amtlon,rateilon
          from tintrted
         where codcompy = p_codcompy
           and codlon = p_codlon
           and dteeffec = p_dteeffecquery;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data  := json_object_t();
        obj_data.put('amtlon',i.amtlon);
        obj_data.put('rateilon',i.rateilon);
        obj_data.put('flgAdd',isAdd);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_index_table;

  procedure insert_or_update_tintrteh as
  begin
    begin
        insert into tintrteh
            (
             codcompy, codlon, dteeffec, codpayc, codpayd, codpaye,
             rateilon, typintr, formula, statement, codcreate, coduser
            )
        values
            (
                p_codcompy, p_codlon, p_dteeffec, p_codpayc, p_codpayd,
                p_codpaye, p_rateilon, p_typintr, p_code, p_description,
                global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
       update tintrteh
          set codpayc = p_codpayc,
              codpayd = p_codpayd,
              codpaye = p_codpaye,
              rateilon = p_rateilon,
              typintr = p_typintr,
              formula = p_code,
              statement = p_description,
              coduser = global_v_coduser
        where codcompy = p_codcompy
          and codlon = p_codlon
          and dteeffec = p_dteeffec;
    end;

  end insert_or_update_tintrteh;

  procedure insert_tintrted as
  begin
    insert into tintrted(codcompy,codlon,dteeffec,amtlon,rateilon,codcreate,coduser)
    values(p_codcompy,p_codlon,p_dteeffec,p_amtlon,p_rateilon,global_v_coduser,global_v_coduser);
  end insert_tintrted;

  procedure update_tintrted as
  begin
    update tintrted
    set amtlon = p_amtlon,
        rateilon = p_rateilon
    where codcompy = p_codcompy
      and codlon = p_codlon
      and dteeffec = p_dteeffec
      and amtlon = p_amtlonOld;
  end update_tintrted;

  procedure delete_tintrted as
  begin
    delete tintrted
     where codcompy = p_codcompy
       and codlon = p_codlon
       and dteeffec = p_dteeffec
       and amtlon = p_amtlonOld;
  end delete_tintrted;

  procedure initial_table(v_table json_object_t) as
      data_obj       json_object_t;
  begin
    for i in 0..v_table.get_size-1 loop
        data_obj    := hcm_util.get_json_t(v_table,to_char(i));
        p_amtlon    := to_number(hcm_util.get_string_t(data_obj,'amtlon'));
        p_amtlonOld := to_number(hcm_util.get_string_t(data_obj,'amtlonOld'));
        p_rateilon  := to_number(hcm_util.get_string_t(data_obj,'rateilon'));
        p_flag      := hcm_util.get_string_t(data_obj,'flg');
        if p_flag = 'add' then
            insert_tintrted;
        elsif p_flag = 'edit' then
            update_tintrted;
        elsif p_flag = 'delete' then
            delete_tintrted;
        end if;
    end loop;

  end initial_table;

  procedure get_index(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    gen_flg_status;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure get_index_table(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_flg_status;
    gen_index_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index_table;

  procedure save_index(json_str_input in clob,json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
  begin
    initial_save(json_str_input);
    json_obj    := json_object_t(json_str_input);
    if param_msg_error is null then
        insert_or_update_tintrteh;
        initial_table(param_table);
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
  end save_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_response          varchar2(1000 char);
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      if v_flgDisabled then
        v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
      end if;
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('msqerror', v_response);

      obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
     select count(*) into v_count
       from tintrteh
      where codcompy = p_codcompy
        and codlon = p_codlon
        and dteeffec  = p_dteeffec;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      select max(dteeffec) into v_maxdteeffec
        from tintrteh
       where codcompy = p_codcompy
         and codlon = p_codlon
         and dteeffec <= p_dteeffec;

      if v_maxdteeffec is null then
        select min(dteeffec) into v_maxdteeffec
          from tintrteh
         where codcompy = p_codcompy
           and codlon = p_codlon
           and dteeffec > p_dteeffec;
        if v_maxdteeffec is null then
            v_flgDisabled       := false;
            isAdd               := true; 
            isEdit              := false;
            return;
        else 
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        end if;
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

    if p_dteeffecquery < p_dteeffec then
        isAdd           := true; 
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

  end;

END HRBF5DE;

/
