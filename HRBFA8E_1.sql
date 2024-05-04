--------------------------------------------------------
--  DDL for Package Body HRBFA8E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFA8E" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codprgheal        := hcm_util.get_string_t(json_obj, 'p_codprgheal');
    -- save detail
    p_codcln            := hcm_util.get_string_t(json_obj, 'p_codcln');
    p_dteheal           := to_date(hcm_util.get_string_t(json_obj, 'p_dteheal'), 'DD/MM/YYYY');
    p_dtehealen         := to_date(hcm_util.get_string_t(json_obj, 'p_dtehealen'), 'DD/MM/YYYY');
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_detail is
    v_codcompy          tcenter.codcompy%type;
    v_codprgheal        thealcde.codprgheal%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codprgheal is not null then
      begin
        select codprgheal, syncond, qtymth
          into v_codprgheal, p_syncond, p_qtymth
          from thealcde
         where codprgheal = p_codprgheal;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'thealcde');
        return;
      end;
    end if;
  end check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data            json_object_t;
    v_codcln            thealinf.codcln%type;
    v_dteheal           thealinf.dteheal%type;
    v_dtehealen         thealinf.dtehealen%type;
  begin

    begin
      select codcln, dteheal, dtehealen
        into v_codcln, v_dteheal, v_dtehealen
        from thealinf
       where dteyear    = p_dteyear
         and codcomp    = p_codcomp
--         and codcomp    like p_codcomp || '%' -- 2022/11/30 #8723
         and codprgheal = p_codprgheal
       fetch first 1 rows only;
    exception when no_data_found then
      null;
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcln', v_codcln);
    obj_data.put('dteheal', to_char(v_dteheal, 'DD/MM/YYYY'));
    obj_data.put('dtehealen', to_char(v_dtehealen, 'DD/MM/YYYY'));

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure get_thealinf1 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinf1(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinf1;

  procedure gen_thealinf1 (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_desc_status       tlistval.desc_label%type;
    v_cursor            number;
    v_stmt              clob;
    v_dummy             integer;
    v_codcomp           temploy1.codcomp%type;
    v_codempid          temploy1.codempid%type;
    v_codsex            temploy1.codsex%type;
    v_dteempdb          temploy1.dteempdb%type;
    v_dteheal           thealinf1.dteheal%type;
    v_dteheal_check     thealinf1.dteheal%type;
    v_continue          boolean := false;

    cursor c1 is
      select codempid, codcomp, dteheal
        from thealinf1
       where dteyear    = p_dteyear
--         and codcomp    like p_codcomp || '%' -- 2022/11/30 #8723
         and codcomphf  = p_codcomp
         and codprgheal = p_codprgheal
       order by codempid;
  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        if i.dteheal is null then
          obj_data.put('flgEdit', true);
          v_desc_status       := get_tlistval_name('CHKHEAL', 'N', global_v_lang);
        else
          v_desc_status       := get_tlistval_name('CHKHEAL', 'Y', global_v_lang);
        end if;
        obj_data.put('coderror', '200');
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('desc_status', v_desc_status);
        obj_data.put('dteheal', to_char(i.dteheal, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      v_stmt := 'select distinct codcomp, codempid, codsex, dteempdb' ||
                '  from v_hrpma1' ||
--                ' where codcomp = ''' || rpad(p_codcomp, 40, '0') || '''' ||
                ' where codcomp like ''' || p_codcomp || '%''' ||
                '   and staemp  not in (''0'', ''9'')' ||
                '   and (' || nvl(p_syncond, '1=1') || ')' ||
                ' order by codempid';
      v_cursor  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor, v_stmt, dbms_sql.native);
      dbms_sql.define_column(v_cursor, 1, v_codcomp, 1000);
      dbms_sql.define_column(v_cursor, 2, v_codempid, 1000);
      dbms_sql.define_column(v_cursor, 3, v_codsex, 1000);
      dbms_sql.define_column(v_cursor, 4, v_dteempdb);

      v_dummy := dbms_sql.execute(v_cursor);
      while (dbms_sql.fetch_rows(v_cursor) > 0) loop
        dbms_sql.column_value(v_cursor, 1, v_codcomp);
        dbms_sql.column_value(v_cursor, 2, v_codempid);
        dbms_sql.column_value(v_cursor, 3, v_codsex);
        dbms_sql.column_value(v_cursor, 4, v_dteempdb);

        if secur_main.secur3(v_codcomp, v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
-- <<     surachai bk | 06/12/2022 (ย้ายการเช็คกำหนดการตรวจสุขภาพไป เช็คตอน save)| #8717
--          v_continue          := true;
--          if p_qtymth > 0 then
--            v_continue          := false;
--            begin
--              select max(dteheal)
--                into v_dteheal
--                from thealinf1
--               where codempid   = v_codempid
--                 and codprgheal = p_codprgheal
--                 and dteyear    <= p_dteyear;
--            exception when no_data_found then
--              null;
--            end;
--            if v_dteheal is null then
--              v_continue          := true;
--            else
--              v_dteheal_check     := add_months(v_dteheal, p_qtymth);
--              if trunc(v_dteheal_check) <= trunc(sysdate) then
--                v_continue          := true;
--              end if;
--            end if;
--          end if;
--          if v_continue then
            v_rcnt              := v_rcnt + 1;
            obj_data            := json_object_t();
            v_desc_status       := get_tlistval_name('CHKHEAL', 'N', global_v_lang);
            obj_data.put('coderror', '200');
            obj_data.put('flgEdit', true);
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', v_codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
            obj_data.put('desc_status', v_desc_status);
            obj_data.put('dteheal', '');

            obj_rows.put(to_char(v_rcnt - 1), obj_data);
--          end if;
-- >>
        end if;

            v_rcnt              := v_rcnt + 1;
            obj_data            := json_object_t();
            v_desc_status       := get_tlistval_name('CHKHEAL', 'N', global_v_lang);
            obj_data.put('coderror', '200');
            obj_data.put('flgEdit', true);
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', v_codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
            obj_data.put('desc_status', v_desc_status);
            obj_data.put('dteheal', '');

            obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
      dbms_sql.close_cursor(v_cursor);
    end if;

    json_str_output := obj_rows.to_clob;
  end gen_thealinf1;

  procedure get_thealinf1_data (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_thealinf1_data(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thealinf1_data;

  procedure gen_thealinf1_data (json_str_output out clob) AS
    obj_data            json_object_t;
    v_desc_status       tlistval.desc_label%type;
    v_cursor            number;
    v_stmt              clob;
    v_dummy             integer;
    v_codcomp           temploy1.codcomp%type;
    v_codempid          temploy1.codempid%type;
    v_dteheal           thealinf1.dteheal%type;
    v_dteheal_check     thealinf1.dteheal%type;
    v_msg_warning       varchar2(4000 char);
  begin
    v_codcomp           := hcm_util.get_temploy_field(p_codempid, 'codcomp');
    if not secur_main.secur3(v_codcomp, p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    if v_codcomp not like p_codcomp || '%' then
      param_msg_error := get_error_msg_php('HR7523', global_v_lang);
      return;
    end if;
    if p_qtymth > 0 then
      begin
        select max(dteheal)
          into v_dteheal
          from thealinf1
         where codempid   = p_codempid
           and codprgheal = p_codprgheal
           and dteyear    <= p_dteyear;
      exception when no_data_found then
        null;
      end;
      insert into a values(v_dteheal, 'b');
      if v_dteheal is not null then
        v_dteheal_check     := add_months(v_dteheal, p_qtymth);
        insert into a values (v_dteheal_check, 'a');
        if trunc(v_dteheal_check) > trunc(sysdate) then
          v_msg_warning     := get_error_msg_php('BF0065', global_v_lang);
--          param_msg_error     := get_error_msg_php('BF0065', global_v_lang);
--          return;
        end if;
        if trunc(v_dteheal_check) not between p_dteheal and p_dtehealen then
          v_msg_warning     := get_error_msg_php('BF0065', global_v_lang, v_codempid);
        end if;
      end if;
    end if;
    v_stmt := 'select distinct codempid' ||
              '  from v_hrpma1' ||
              ' where codempid = ''' || p_codempid || '''' ||
              '   and staemp   not in (''0'', ''9'')' ||
              '   and (' || nvl(p_syncond, '1=1') || ')';
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor, v_stmt, dbms_sql.native);
    dbms_sql.define_column(v_cursor, 1, v_codempid, 1000);

    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor, 1, v_codempid);
    end loop;
    if v_codempid is null then
      v_msg_warning := get_error_msg_php('BF0014', global_v_lang);
    end if;
    v_desc_status       := get_tlistval_name('CHKHEAL', 'N', global_v_lang);
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgAdd', true);
    obj_data.put('response', replace(v_msg_warning, '@#$%400'));
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang));
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('desc_status', v_desc_status);
    obj_data.put('dteheal', '');

    json_str_output := obj_data.to_clob;
  end gen_thealinf1_data;

  procedure check_save is
    obj_data            json_object_t;
    v_codprgheal        thealcde.codprgheal%type;
    v_flg               varchar2(10 char);
    v_codempid          thealinf1.codempid%type;
    v_codcomp           thealinf1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_dteeffex          temploy1.dteeffex%type;
    v_continue          boolean := false;
    v_dteheal           thealinf1.dteheal%type;
    v_dteheal_check     thealinf1.dteheal%type;
  begin
    if p_codprgheal is not null then
      begin
        select codprgheal, amtheal
          into v_codprgheal, p_amtheal
          from thealcde
         where codprgheal = p_codprgheal;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'thealcde');
        return;
      end;
    end if;
    -- << surachai 02/12/202||validate typemp <> 9
    for i in 0 .. json_params.get_size - 1 loop
        obj_data        := hcm_util.get_json_t(json_params, to_char(i));
        if param_msg_error is null then
            v_flg             := hcm_util.get_string_t(obj_data, 'flg');
            v_codempid        := hcm_util.get_string_t(obj_data, 'codempid');
            v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
            if v_flg = 'add' then
                 -- << surachai 02/12/202||validate typemp <> 9
                begin
                    select staemp,dteeffex into v_staemp,v_dteeffex
                    from temploy1
                    where codempid = v_codempid;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010', global_v_lang,'temploy1');
                    return;
                end;
                if v_staemp = '9' and v_dteeffex < p_dteheal then
                    param_msg_error := get_error_msg_php('HR2101', global_v_lang);
                    return;
                end if;
            end if;
            -- >>
            -- << surachai 02/12/202||เช็กว่าแต่ละคนถึงรอบตรวจสุขภาพยัง || #8717
            begin
            select qtymth
            into p_qtymth
            from thealcde
            where codprgheal = p_codprgheal;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'thealcde');
                return;
            return;
            end;
            if v_flg = 'add' or v_flg = 'edit' then
                 v_continue          := false;
                 begin
                    select max(dteheal)
                    into v_dteheal
                    from thealinf1
                    where codempid   = v_codempid
                     and codprgheal = p_codprgheal
                     and dteyear    <= p_dteyear;
                exception when no_data_found then
                    null;
                end;
--                if v_dteheal is null then
--                    v_continue          := true;
--                else
--                  v_dteheal_check     := add_months(v_dteheal, p_qtymth);
--                    if trunc(v_dteheal_check) not between p_dteheal and p_dtehealen then
--                        param_msg_error := get_error_msg_php('BF0065', global_v_lang,v_codempid);
--                        return;
--                    end if;
--                end if;
            end if;
            -- >>
        end if;
      end loop;
      -->>

  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
    v_codempid          thealinf1.codempid%type;
    v_codcomp           thealinf1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_dteeffex          temploy1.dteeffex%type;
  begin
    initial_value(json_str_input);
    check_save;

    if param_msg_error is null then

      begin
        insert into thealinf
                (codcomp, dteyear, codprgheal, codcln, dteheal, dtehealen, amtheal, dtecreate, codcreate, coduser)
        values (p_codcomp, p_dteyear, p_codprgheal, p_codcln, p_dteheal, p_dtehealen, p_amtheal, sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update thealinf
            set codcln     = p_codcln,
                dteheal    = p_dteheal,
                dtehealen  = p_dtehealen,
                amtheal    = p_amtheal,
                coduser    = global_v_coduser,
                dteupd     = sysdate
          where codcomp = p_codcomp -- surachai add 02/12/2022 ||4448 std new bf >> #8712
--            codcomp    = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y') -- surachai bk 02/12/2022 ||4448 std new bf >> #8712
            and dteyear    = p_dteyear
            and codprgheal = p_codprgheal;
      end;
      for i in 0 .. json_params.get_size - 1 loop
        obj_data        := hcm_util.get_json_t(json_params, to_char(i));
        if param_msg_error is null then
          v_flg             := hcm_util.get_string_t(obj_data, 'flg');
          v_codempid        := hcm_util.get_string_t(obj_data, 'codempid');
          v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
          if v_flg = 'delete' then
            begin
              delete from thealinf1
               where codempid   = v_codempid
                 and dteyear    = p_dteyear
                 and codprgheal = p_codprgheal;
            exception when others then
              null;
            end;
          else
            v_check_flg := true;
            begin
              insert into thealinf1
                     (codempid, dteyear, codprgheal, codcln, codcomp, amtheal, dtecreate, codcreate, coduser, codcomphf)
              values (v_codempid, p_dteyear, p_codprgheal, p_codcln, hcm_util.get_codcomp_level(v_codcomp, null, null, 'Y'), p_amtheal, sysdate, global_v_coduser, global_v_coduser, p_codcomp);
            exception when dup_val_on_index then
              update thealinf1
                 set codcln     = p_codcln,
                     codcomp    = hcm_util.get_codcomp_level(v_codcomp, null, null, 'Y'),
                     codcomphf  = p_codcomp,
                     amtheal    = p_amtheal,
                     coduser    = global_v_coduser,
                     dteupd     = sysdate
               where codempid   = v_codempid
                 and dteyear    = p_dteyear
                 and codprgheal = p_codprgheal;
            end;
          end if;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      if v_check_flg then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      end if;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRBFA8E;

/
