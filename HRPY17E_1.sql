--------------------------------------------------------
--  DDL for Package Body HRPY17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY17E" AS
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy  tcompny.codcompy%type;
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      begin
        select codcompy into v_codcompy
        from tcompny
        where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;

  end check_index;
  --
  function find_dteeffec (v_dteeffec in date) return date is
    v_tempdte date;
    v_maxdte date;
  begin
    v_tempdte := trunc(sysdate);
    begin
      select max(dteeffec) into v_maxdte
      from tcondept
      where codcompy = p_codcompy
      and dteeffec < v_dteeffec;
    exception when no_data_found then
      v_maxdte := null;
    end;
    return v_maxdte;
  end find_dteeffec;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row              json_object_t;
    obj_data             json_object_t;
    obj_table_row        json_object_t;
    obj_table            json_object_t;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    v_flg_exist          boolean := false;
    v_rcnt               number  := 0;
    v_total              number  := 0;
    v_flgedit            boolean := true;
    v_dteeffec           tcondept.dteeffec%type;
    v_tempdte            tcondept.dteeffec%type;
    v_codpaypy1          tcontrpy.codpaypy1%type;
    v_codpaypy2          tcontrpy.codpaypy2%type;
    v_codpaypy3          tcontrpy.codpaypy3%type;
    v_codpaypy12         tcontrpy.codpaypy12%type;
    v_codpaypy13         tcontrpy.codpaypy13%type;
    v_codpaypy14         tcontrpy.codpaypy14%type;
    v_count_exist        number := 0;
    v_flgAdd             boolean;
    v_flg_codpaypy1      boolean := false;
    v_flg_codpaypy2      boolean := false;
    v_flg_codpaypy3      boolean := false;
    v_flg_codpaypy13     boolean := false;
    v_flg_codpaypy14     boolean := false;
    v_flg_codpaypy12     boolean := false;
    cursor c1 is
      select codcompy,codpay,dteeffec,numseq
        from tcondept
       where codcompy = p_codcompy
         and dteeffec = v_dteeffec
    order by numseq;

--    cursor c3 is
--      select codcompy,codpay,dteeffec,numseq
--        from tcondept
--       where codcompy = p_codcompy
--         and dteeffec = v_dteeffec
--         and codpay in (v_codpaypy2,v_codpaypy3,v_codpaypy13,v_codpaypy14,v_codpaypy12)
--    order by numseq;

--    cursor c2 is
--      select codpaypy1 as codpay
--        from tcontrpy
--       where codcompy = p_codcompy
--         and codpaypy1 is not null
--         and dteeffec = (select max(dteeffec)
--                           from tcontrpy
--                          where codcompy = p_codcompy)
--       union
--      select codpay as codpay from tinexinf where TYPPAY = '6' and codpay in (select codpay from TINEXINFC where codcompy = p_codcompy);
  begin
    obj_row  := json_object_t();
    v_dteeffec := p_dteeffec;
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      v_tempdte := find_dteeffec(p_dteeffec);
      if v_tempdte is null then
        v_dteeffec := p_dteeffec;
      else
        v_dteeffec := v_tempdte;
      end if;
      v_flgAdd := true;
    else
        v_flgAdd := false;
    end if;
    for r1 in c1 loop
      v_flg_exist := true;
      v_flg_secure := secur_main.secur7(r1.codcompy,global_v_coduser);
      if v_flg_secure then
        begin
          select codpaypy1/*,codpaypy2,codpaypy3,codpaypy13 ,
                 codpaypy14, codpaypy12*/
            into v_codpaypy1/*,v_codpaypy2,v_codpaypy3,v_codpaypy13,
                 v_codpaypy14, v_codpaypy12*/
            from tcontrpy
           where codcompy = p_codcompy
             and dteeffec = (select max(dteeffec) from tcontrpy
                              where codcompy = p_codcompy);
        exception when no_data_found then
          v_codpaypy1 := ''; 
--          v_codpaypy2 := ''; 
--          v_codpaypy3 := ''; 
--          v_codpaypy13 := ''; 
--          v_codpaypy14 := ''; 
--          v_codpaypy12 := ''; 
        end;      

        v_flg_permission  := true;
        obj_data := json_object_t();
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('codpay', r1.codpay);
        obj_data.put('numseq', r1.numseq);
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));

        if r1.codpay in (v_codpaypy1/*,v_codpaypy2,v_codpaypy3,v_codpaypy13,v_codpaypy14, v_codpaypy12*/) then
            if r1.codpay = v_codpaypy1 then
                v_flg_codpaypy1 := true;
--            elsif r1.codpay = v_codpaypy2 then
--                v_flg_codpaypy2 := true;
--            elsif r1.codpay = v_codpaypy3 then
--                v_flg_codpaypy3 := true;
--            elsif r1.codpay = v_codpaypy13 then
--                v_flg_codpaypy13 := true;
--            elsif r1.codpay = v_codpaypy14 then
--                v_flg_codpaypy14 := true;
--            elsif r1.codpay = v_codpaypy12 then
--                v_flg_codpaypy12 := true;
            end if;
            obj_data.put('flgDisable', 'Y');
        else
            obj_data.put('flgDisable', 'N');
        end if;

        obj_data.put('flgAdd', v_flgAdd);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end if;
    end loop;

    if v_flgAdd then
        if v_codpaypy1 is not null and  not v_flg_codpaypy1 then
          obj_data := json_object_t();
          obj_data.put('codcompy', p_codcompy);
          obj_data.put('codpay', v_codpaypy1);
          obj_data.put('numseq',v_rcnt);
          obj_data.put('flgAdd', true);
          obj_data.put('flgDisable', 'Y');
          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
--        elsif v_codpaypy2 is not null and  not v_flg_codpaypy2 then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy2);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        elsif v_codpaypy3 is not null and  not v_flg_codpaypy3 then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy3);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        
--        elsif v_codpaypy13 is not null and  not v_flg_codpaypy13 then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy13);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        
--        elsif v_codpaypy14 is not null and  not v_flg_codpaypy14 then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy14);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        
--        elsif v_codpaypy12 is not null and  not v_flg_codpaypy12 then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy12);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
        end if;  
    end if;

    if v_flg_exist then
      if p_dteeffec < trunc(sysdate) then
        v_flgedit := false;
      end if;
    else
      v_flgedit := true;
      begin
        select count(codcompy) into v_count_exist
          from tcondept
         where codcompy = p_codcompy
           and dteeffec <= p_dteeffec;
      end;
      if v_count_exist = 0 then
--        for r1 in c2 loop
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', r1.codpay);
--          obj_data.put('numseq', v_rcnt + 1);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end loop;
        begin
          select codpaypy1 
          into v_codpaypy1
            from tcontrpy
           where codcompy = p_codcompy
             and dteeffec = (select max(dteeffec) from tcontrpy
                             where codcompy = p_codcompy);
        exception when no_data_found then
          v_codpaypy1 := '';
        end;
        if v_codpaypy1 is not null then
          obj_data := json_object_t();
          obj_data.put('codcompy', p_codcompy);
          obj_data.put('codpay', v_codpaypy1);
          obj_data.put('numseq',v_rcnt);
          obj_data.put('flgAdd', true);
          obj_data.put('flgDisable', 'Y');
          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
        end if;
--        begin
--          select codpaypy2 ,codpaypy3
--          into v_codpaypy2, v_codpaypy3
--            from tcontrpy
--           where codcompy = p_codcompy
--             and dteeffec = (select max(dteeffec) from tcontrpy
--                             where codcompy = p_codcompy);
--        exception when no_data_found then
--          v_codpaypy2 := '';
--          v_codpaypy3 := '';
--        end;
--        if v_codpaypy2 is not null then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy2);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end if;
--        if v_codpaypy3 is not null then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy3);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end if;
--        begin
--          select codpaypy13,codpaypy14 into v_codpaypy13,v_codpaypy14
--            from tcontrpy
--           where codcompy = p_codcompy
--             and dteeffec = (select max(dteeffec) from tcontrpy
--                             where codcompy = p_codcompy);
--        exception when no_data_found then
--          v_codpaypy13 := ''; v_codpaypy14 := '';
--        end;
--        if v_codpaypy13 is not null then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy13);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end if;
--        if v_codpaypy14 is not null then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy14);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end if;
--        begin
--          select codpaypy12 into v_codpaypy12
--            from tcontrpy
--           where codcompy = p_codcompy
--             and dteeffec = (select max(dteeffec) from tcontrpy
--                             where codcompy = p_codcompy);
--        exception when no_data_found then
--          v_codpaypy12 := '';
--        end;
--        if v_codpaypy12 is not null then
--          obj_data := json_object_t();
--          obj_data.put('codcompy', p_codcompy);
--          obj_data.put('codpay', v_codpaypy12);
--          obj_data.put('numseq',v_rcnt);
--          obj_data.put('flgAdd', true);
--          obj_data.put('flgDisable', 'Y');
--          obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
--          obj_row.put(to_char(v_rcnt), obj_data);
--          v_rcnt := v_rcnt + 1;
--        end if;
      end if;
    end if;

    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    obj_table     := json_object_t();
    obj_table_row := json_object_t();

    obj_table_row.put('rows', obj_row);
    obj_table.put('coderror', '200');
    obj_table.put('flgedit', v_flgedit);
    obj_table.put('table', obj_table_row);

    json_str_output := obj_table.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    obj_param_json json_object_t;
    param_json_row json_object_t;
    -- get param json
    v_codcompy      tcondept.codcompy%type;
    v_codpay        tcondept.codpay%type;
    v_numseq        tcondept.numseq%type;
    v_dteeffec      tcondept.dteeffec%type;
    v_flg           varchar2(100 char);
  begin
    initial_value(json_str_input);
--    check_index;
    obj_param_json        := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'params_json'));
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json, to_char(i));
        --
        v_codpay    := hcm_util.get_string_t(param_json_row,'codpay');
        v_numseq    := hcm_util.get_string_t(param_json_row,'numseq');
        v_flg       := hcm_util.get_string_t(param_json_row,'flg');
        v_dteeffec  := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
        if v_flg = 'delete' then
          begin
            delete tcondept
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numseq = v_numseq;
          exception when others then
            null;
          end;
        elsif v_flg = 'add' then
          begin
            select nvl(max(numseq) + 1, 1) into v_numseq
              from tcondept
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec;
          exception when no_data_found then
            v_numseq := 1;
          end;
          begin
            insert into tcondept (codcompy,dteeffec,numseq,codpay,dtecreate,codcreate)
            values (p_codcompy, p_dteeffec, v_numseq, v_codpay,trunc(sysdate),global_v_codempid);
          exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TCONDEPT');
          end;
        elsif(v_flg = 'edit') then
          begin
              update tcondept
              set codpay    =  v_codpay,
                  dteupd    =  trunc(sysdate),
                  coduser   =  global_v_coduser
            where codcompy  =  p_codcompy
              and dteeffec = p_dteeffec
              and numseq = v_numseq;
          exception when others then
            null;
          end;
        end if;
      end loop;
      --
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

END HRPY17E;

/
