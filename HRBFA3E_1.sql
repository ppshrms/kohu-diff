--------------------------------------------------------
--  DDL for Package Body HRBFA3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFA3E" AS

    procedure initial_value(json_str_input in clob) as
        json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
        p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_codprgheal        := upper(hcm_util.get_string_t(json_obj,'p_codprgheal'));
        p_codempid_query    := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));
        p_codheal           := upper(hcm_util.get_string_t(json_obj,'p_codheal'));

    end initial_value;

    procedure check_index as
        v_temp      varchar(1 char);
        v_temp2     varchar(1 char);
    begin
        --  check null parameters
        if  p_dteyear is null or p_codcomp is null or p_codprgheal is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        --  check  codcomp in tcenter
        begin
            select 'X' into v_temp
              from tcenter
             where codcomp like p_codcomp || '%'
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

--  check secure7
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

--  check codprgheal in thealcde
        begin
            select 'X' into v_temp2
              from thealcde
             where codprgheal = p_codprgheal;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thealcde');
            return;
        end;

    end check_index;

    procedure check_detail as
        v_temp     varchar(1 char);
        v_temp2    varchar(1 char);
    begin
--  check null parameters
        if p_codempid_query is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--  check employee
        begin
            select 'X' into v_temp
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;

--  check employee status
        begin
            select 'X' into v_temp2
              from temploy1
             where codempid = p_codempid_query
               and staemp <> 9;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        end;

--  check secur2
        if secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

--  check codempid in codcomp redmine
        begin
            select 'X' into v_temp
              from temploy1
             where codempid = p_codempid_query
               and codcomp like p_codcomp||'%';
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR7523',global_v_lang);
            return;
        end;

    end check_detail;

    procedure check_param1 as
    begin
        if p_codcln is null or p_amtheal is null or p_dteheal is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end check_param1;

    procedure check_param2 as
    begin
        if p_codheal is null or p_chkresult is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end check_param2;

    procedure gen_index(json_str_output out clob) as
        obj_data    json_object_t;
        v_codcln    thealinf.codcln%type;
        v_amtheal   thealinf.amtheal%type;
        v_dteheal   thealinf.dteheal%type;
        v_dtehealen   thealinf.dtehealen%type;
        v_namdoc    thealinf.namdoc%type;
        v_numcert   thealinf.numcert%type;
        v_namdoc2   thealinf.namdoc2%type;
        v_numcert2  thealinf.numcert2%type;
        v_flag      varchar(50 char):= 'Edit';
    begin
        begin
            select codcln,amtheal,dteheal,dtehealen,namdoc,numcert,namdoc2,numcert2 into v_codcln,v_amtheal,v_dteheal,v_dtehealen,v_namdoc,v_numcert,v_namdoc2,v_numcert2
             from thealinf
            where dteyear = p_dteyear
              and get_compful(codcomp) = get_compful(p_codcomp)
              and codprgheal = p_codprgheal
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THEALINF');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;

        obj_data := json_object_t();
        obj_data.put('codcln',v_codcln);
        obj_data.put('dteheal',to_char(v_dteheal,'dd/mm/yyyy'));
        obj_data.put('dtehealen',to_char(v_dtehealen,'dd/mm/yyyy'));
        obj_data.put('amtheal',v_amtheal);
        obj_data.put('namdoc',v_namdoc);
        obj_data.put('numcert',v_numcert);
        obj_data.put('namdoc2',v_namdoc2);
        obj_data.put('numcert2',v_numcert2);
        obj_data.put('coderror',200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);

    end gen_index;

    procedure gen_index_table(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select codempid,codcomp,dteheal,amtheal,dteyear,codprgheal
              from thealinf1
             where dteyear = p_dteyear
               and codcomp like p_codcomp || '%'
               and codprgheal = p_codprgheal
            order by codempid;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                obj_data := json_object_t();
                v_row := v_row+1;
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('dteheal',to_char(i.dteheal,'dd/mm/yyyy'));
                obj_data.put('amtheal',i.amtheal);
                obj_data.put('dteyear',i.dteyear);
                obj_data.put('codprgheal',i.codprgheal);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

--        if obj_rows.count() = 0 then
--            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THEALINF');
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            return;
--        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_index_table;

    procedure gen_detail(json_str_output out clob) as
        obj_data        json_object_t;
        v_namdoc        thealinf1.namdoc%type;
        v_numcert       thealinf1.numcert%type;
        v_namdoc2       thealinf1.namdoc2%type;
        v_numcert2      thealinf1.numcert2%type;
        v_descheal      thealinf1.descheal%type;
        v_dtefollow     thealinf1.dtefollow%type;
        v_amtheal       thealinf.amtheal%type;
        v_codcln        thealinf1.codcln%type;
        v_dteheal       thealinf1.dteheal%type;
    begin
        begin
            select codcln,dteheal,namdoc,numcert,
                   namdoc2,numcert2,descheal,dtefollow,amtheal
              into v_codcln,v_dteheal,v_namdoc,v_numcert,
                   v_namdoc2,v_numcert2,v_descheal,v_dtefollow,v_amtheal
              from thealinf1
             where dteyear = p_dteyear
               and codempid = p_codempid_query
               and codprgheal = p_codprgheal;
        exception when no_data_found then
            v_namdoc    := '';
            v_numcert   := '';
            v_namdoc2   := '';
            v_numcert2  := '';
            v_descheal  := '';
            v_dtefollow := '';
        end;

        obj_data := json_object_t();
        obj_data.put('codempid',p_codempid_query);
        obj_data.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
        obj_data.put('dteyear',p_dteyear);
        obj_data.put('codprgheal',p_codprgheal);
        obj_data.put('desc_codprgheal',get_thealcde_name(p_codprgheal,global_v_lang));
        obj_data.put('codcln',v_codcln);
        obj_data.put('dteheal',to_char(v_dteheal,'dd/mm/yyyy'));
        obj_data.put('amtheal',v_amtheal);
        obj_data.put('namdoc',v_namdoc);
        obj_data.put('numcert',v_numcert);
        obj_data.put('namdoc2',v_namdoc2);
        obj_data.put('numcert2',v_numcert2);
        obj_data.put('descheal',v_descheal);
        obj_data.put('dtefollow',to_char(v_dtefollow,'dd/mm/yyyy'));
        obj_data.put('coderror',200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail;

    procedure gen_detail_table(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_qtysetup  thealcde2.qtysetup%type;
        cursor c1 is
            select codheal,descheck,chkresult,descheal
              from thealinf2
             where dteyear = p_dteyear
               and codempid = p_codempid_query
               and codprgheal = p_codprgheal
          order by codheal;

        cursor c2 is
            select codheal,qtysetup
              from thealcde2
             where codprgheal = p_codprgheal
          order by codheal;

    begin
        obj_rows := json_object_t();
        for i in c1 loop
            begin
                select qtysetup into v_qtysetup
                  from thealcde2
                 where codprgheal = p_codprgheal
                   and codheal = i.codheal;
            exception when no_data_found then
                v_qtysetup := '';
                --<<User37 6795 01/09/2021
                begin
                    select qtysetup into v_qtysetup
                      from thealcde2
                     where codheal = i.codheal
                       and rownum <= 1
                       order by codprgheal;
                exception when no_data_found then
                  v_qtysetup := '';
                end;
                -->>User37 6795 01/09/2021
            end;
            obj_data := json_object_t();
            v_row := v_row+1;
            obj_data.put('codheal',i.codheal);
            obj_data.put('qtysetup',v_qtysetup);
            obj_data.put('descheck',i.descheck);
            obj_data.put('chkresult',i.chkresult);
            obj_data.put('descheal',i.descheal);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        if v_row = 0 then
            for i2 in c2 loop
                obj_data := json_object_t();
                v_row := v_row+1;
                obj_data.put('codheal',i2.codheal);
                obj_data.put('qtysetup',i2.qtysetup);
                obj_data.put('descheck','');
                obj_data.put('chkresult','');
                obj_data.put('descheal','');
                obj_data.put('flgAdd',true);
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_detail_table;

    procedure update_thealinf1 as
    begin
        update thealinf1
           set descheal = p_descheal,
               namdoc = p_namdoc,
               numcert = p_numcert,
               namdoc2 = p_namdoc2,
               numcert2 = p_numcert2,
               amtheal = p_amtheal,
               dtefollow = p_dtefollow,
               coduser = global_v_coduser,
               dteheal = p_dteheal
         where codempid = p_codempid_query
           and dteyear = p_dteyear
           and codprgheal = p_codprgheal;
    end update_thealinf1;

    procedure insert_thealinf2 as
    begin
        begin
            insert into thealinf2(codempid,dteyear,codprgheal,codheal,descheck,chkresult,descheal,codcreate,coduser)
            values(p_codempid_query,p_dteyear,p_codprgheal,p_codheal,p_descheck,p_chkresult,p_descheal2,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'thealinf2');
        end;
    end insert_thealinf2;

    procedure update_thealinf2 as
    begin
        update thealinf2
           set descheck = p_descheck,
               chkresult = p_chkresult,
               descheal = p_descheal2,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dteyear = p_dteyear
           and codprgheal = p_codprgheal
           and codheal = p_codheal;
    end update_thealinf2;

    procedure delete_thealinf2 as
    begin
        delete from thealinf2
              where codempid = p_codempid_query
                and dteyear = p_dteyear
                and codprgheal = p_codprgheal
                and codheal = p_codheal;
    end delete_thealinf2;

  procedure gen_codheal(json_str_output out clob) as
    obj_data    json_object_t;
    v_qtysetup  thealcde2.qtysetup%type;
  begin
    begin
        select qtysetup into v_qtysetup
        from thealcde2
        where codheal = p_codheal
          and codprgheal = p_codprgheal;
    exception when no_data_found then
        v_qtysetup := '';
        --<<User37 6795 27/08/2021
        begin
            select qtysetup into v_qtysetup
              from thealcde2
             where codheal = p_codheal
               and rownum <= 1
               order by codprgheal;
        exception when no_data_found then
          v_qtysetup := '';
        end;
        -->>User37 6795 27/08/2021
    end;
    obj_data := json_object_t();
    obj_data.put('qtysetup',v_qtysetup);
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_codheal;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_index_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index_table(json_str_output);
     else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index_table;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_table(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_detail_table;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
    data_obj2      json_object_t;
    v_count        number;
    v_amtheal       thealinf.amtheal%type;
    v_codcln        thealinf.codcln%type;
    v_dteheal       thealinf.dteheal%type;
    v_dtehealen     thealinf.dtehealen%type;
    v_namdoc        thealinf.namdoc%type;
    v_namdoc2       thealinf.namdoc2%type;
    v_numcert       thealinf.numcert%type;
    v_numcert2      thealinf.numcert2%type;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    param_detail        := hcm_util.get_json_t(param_json,'detail');

    v_amtheal           := hcm_util.get_string_t(param_detail,'amtheal');
    v_namdoc            := hcm_util.get_string_t(param_detail,'namdoc');
    v_numcert           := hcm_util.get_string_t(param_detail,'numcert');
    v_namdoc2           := hcm_util.get_string_t(param_detail,'namdoc2');
    v_numcert2          := hcm_util.get_string_t(param_detail,'numcert2');

    update thealinf
       set amtheal = v_amtheal,
           namdoc = v_namdoc,
           numcert = v_numcert,
           namdoc2 = v_namdoc2,
           numcert2 = v_numcert2
     where dteyear = p_dteyear
       and codcomp = p_codcomp
       and codprgheal = p_codprgheal;

--    for i in 0..param_json.get_size-1 loop
--        data_obj            := hcm_util.get_json_t(param_json,to_char(i));
----      initial description paramerters
--        p_codempid_query    := upper(hcm_util.get_string_t(data_obj,'p_codempid_query'));
--        p_dteyear           := to_number(hcm_util.get_string_t(data_obj,'p_dteyear'));
--        p_codprgheal        := hcm_util.get_string_t(data_obj,'p_codprgheal');
--        p_codcln            := hcm_util.get_string_t(data_obj,'p_codcln');
--        p_dteheal           := to_date(hcm_util.get_string_t(data_obj,'p_dteheal'),'dd/mm/yyyy');
--        p_codcomp           := hcm_util.get_string_t(data_obj,'p_codcomp');
--        p_namdoc            := hcm_util.get_string_t(data_obj,'p_namdoc');
--        p_numcert           := hcm_util.get_string_t(data_obj,'p_numcert');
--        p_namdoc2           := hcm_util.get_string_t(data_obj,'p_namdoc2');
--        p_numcert2          := hcm_util.get_string_t(data_obj,'p_numcert2');
--        p_descheal          := hcm_util.get_string_t(data_obj,'p_descheal');
--        p_dtefollow         := to_date(hcm_util.get_string_t(data_obj,'p_dtefollow'),'dd/mm/yyyy');
--        p_amtheal           := to_number(hcm_util.get_string_t(data_obj,'p_amtheal'));
--        p_list_codheal      := hcm_util.get_json_t(data_obj,'p_list_codheal');
--        p_flag              := hcm_util.get_string_t(data_obj,'p_flag');
--
--        check_param1;
--
--        if param_msg_error is not null then
--           json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--           return;
--        end if;
--
--        if p_flag = 'Add' then
--            update_thealinf;
--            insert_thealinf1;
--        elsif p_flag = 'Edit' then
--            update_thealinf1;
--        elsif p_flag = 'Delete' then
--            delete_thealinf1;
--        end if;
--
--        for i in 0..p_list_codheal.get_size-1 loop
--            data_obj2     := hcm_util.get_json_t(p_list_codheal,to_char(i));
--            p_codheal     := upper(hcm_util.get_string_t(data_obj2,'p_codheal'));
--            p_descheck    := hcm_util.get_string_t(data_obj2,'p_descheck');
--            p_chkresult   := hcm_util.get_string_t(data_obj2,'p_chkresult');
--            p_descheal2   := hcm_util.get_string_t(data_obj2,'p_descheal2');
--            p_flag2       := hcm_util.get_string_t(data_obj2,'p_flag2');
--
--            if p_flag2 != 'Delete' then
--                check_param2;
--            end if;
--
--            if param_msg_error is not null then
--                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--                return;
--            end if;
--
--            if p_flag2 = 'Add' then
--                insert_thealinf2;
--            elsif p_flag2 = 'Edit' then
--                update_thealinf2;
--            elsif p_flag2 = 'Delete' then
--                delete_thealinf2;
--            end if;
--
--        end loop;
--    end loop;
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

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    json_main       json_object_t;
    json_table     json_object_t;
    data_obj       json_object_t;
    data_obj2      json_object_t;
    v_count        number;
    v_amtheal       thealinf.amtheal%type;
    v_codcln        thealinf.codcln%type;
    v_dteheal       thealinf.dteheal%type;
    v_dtehealen     thealinf.dtehealen%type;
    v_namdoc        thealinf.namdoc%type;
    v_namdoc2       thealinf.namdoc2%type;
    v_numcert       thealinf.numcert%type;
    v_numcert2      thealinf.numcert2%type;
    json_str_input2 clob;

  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    param_detail        := hcm_util.get_json_t(param_json,'detail');
    p_list_codheal      := hcm_util.get_json_t(param_json,'table');

    p_dteyear           := hcm_util.get_string_t(param_detail,'dteyear');
    p_codprgheal        := upper(hcm_util.get_string_t(param_detail,'codprgheal'));
    p_codempid_query    := upper(hcm_util.get_string_t(param_detail,'codempid'));

    p_codcln            := hcm_util.get_string_t(param_detail,'codcln');
    p_dteheal           := to_date(hcm_util.get_string_t(param_detail,'dteheal'),'dd/mm/yyyy');
    p_codcomp           := hcm_util.get_string_t(param_detail,'codcomp');
    p_namdoc            := hcm_util.get_string_t(param_detail,'namdoc');
    p_numcert           := hcm_util.get_string_t(param_detail,'numcert');
    p_namdoc2           := hcm_util.get_string_t(param_detail,'namdoc2');
    p_numcert2          := hcm_util.get_string_t(param_detail,'numcert2');
    p_descheal          := hcm_util.get_string_t(param_detail,'descheal');
    p_dtefollow         := to_date(hcm_util.get_string_t(param_detail,'dtefollow'),'dd/mm/yyyy');
    p_amtheal           := to_number(hcm_util.get_string_t(param_detail,'amtheal'));

    --<<User37 #6794 30/08/2021
    p_codcomp           := hcm_util.get_string_t(param_json,'codcomp');
    if p_dteheal is not null then
        begin
            select dteheal,dtehealen into v_dteheal,v_dtehealen
              from thealinf
             where dteyear = p_dteyear
               and get_compful(codcomp) = get_compful(p_codcomp)
               and codprgheal = p_codprgheal
               and rownum = 1;
        exception when no_data_found then
            null;
        end;
--        if p_dteheal not between v_dteheal and v_dtehealen then
--            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
--        end if;
    end if;
    -->>User37 #6794 30/08/2021

    update_thealinf1;
    json_main  := json_object_t();
    for i in 0..p_list_codheal.get_size-1 loop
        data_obj2     := hcm_util.get_json_t(p_list_codheal,to_char(i));
        p_codheal     := upper(hcm_util.get_string_t(data_obj2,'codheal'));
        p_descheck    := hcm_util.get_string_t(data_obj2,'descheck');
        p_chkresult   := hcm_util.get_string_t(data_obj2,'chkresult');
        p_descheal2   := hcm_util.get_string_t(data_obj2,'descheal');
        p_flag2       := hcm_util.get_string_t(data_obj2,'flg');


        if p_flag2 != 'delete' then
            check_param2;
        end if;

        if param_msg_error is not null then
            exit;
        end if;

        if p_flag2 = 'add' then
            insert_thealinf2;
        elsif p_flag2 = 'edit' then
            update_thealinf2;
        elsif p_flag2 = 'delete' then
            delete_thealinf2;
        end if;
    end loop;
    if param_msg_error is null then
        commit;
        gen_index_table(json_str_input2);
        json_table := json_object_t(json_str_input2);
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_main.put('coderror',200);
        json_main.put('response',replace(param_msg_error,'@#$%201',null));
        json_main.put('table',json_table);
        dbms_lob.createtemporary(json_str_output, true);
        json_main.to_clob(json_str_output);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  procedure get_codheal(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_codheal(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codheal;

END HRBFA3E;

/
