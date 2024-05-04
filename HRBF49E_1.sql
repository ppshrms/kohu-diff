--------------------------------------------------------
--  DDL for Package Body HRBF49E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF49E" AS

  procedure initial_value(json_str in clob) is
        json_obj   json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codcompy          := hcm_util.get_string(json_obj, 'p_codcompy');
        p_codcompyCopy      := hcm_util.get_string(json_obj, 'p_codcompyCopy');
        p_flgCopy           := hcm_util.get_string(json_obj, 'p_flgCopy');

        json_params         := hcm_util.get_json(json_obj, 'json_input_str');

    end initial_value;

    procedure check_index is
        v_codcompy  tcompny.codcompy%type;
    begin
        begin
            select codcompy into v_codcompy from TCOMPNY where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;

        if not secur_main.secur7(p_codcompy, global_v_coduser) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as

    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;

        if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_index(json_str_output out clob) as
        obj_data    json;
        obj_row     json;
        v_row       number := 0;
        cursor c1 is
            select  codobf, codincbf
            from    tobfcompy
            where   codcompy = nvl(p_codcompyCopy,p_codcompy)
            order by codobf;
    begin
        obj_row    := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('coderror','200');
            if p_flgCopy = 'Y' then
                obj_data.put('flgAdd',true);
            else
                obj_data.put('flgAdd',false);
            end if;
            obj_data.put('codobf',i.codobf);
            obj_data.put('codincbf',i.codincbf);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index;

    procedure get_copylist(json_str_input in clob, json_str_output out clob) as

    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_copylist(json_str_output);
        end if;

        if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copylist;

    procedure gen_copylist(json_str_output out clob) as
        obj_data    json;
        obj_row     json;
        v_row       number := 0;
        cursor c1 is
            select  distinct codcompy
            from    tobfcompy
            where   codcompy <> p_codcompy
            order by codcompy;
    begin
        obj_row    := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('coderror','200');
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('desc_codcompy',get_tcenter_name(i.codcompy,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_copylist;

    procedure check_save is
        param_json_row  json;
        v_codcompy  tcompny.codcompy%type;
        v_codobf    tobfcompy.codobf%type;
        v_codincbf  tobfcompy.codincbf%type;
        v_flg       varchar2(6 char);
    begin
        begin
            select codcompy into v_codcompy from TCOMPNY where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;

        if not secur_main.secur7(p_codcompy, global_v_coduser) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        for i in 0..json_params.count-1 loop
            param_json_row  := hcm_util.get_json(json_params, to_char(i));
            v_codobf        := hcm_util.get_string(param_json_row, 'codobf');
            v_codincbf      := hcm_util.get_string(param_json_row, 'codincbf');
            v_flg           := hcm_util.get_string(param_json_row, 'flg');

            if v_codobf is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;

            if v_codincbf is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;

            begin
                select codobf into v_codobf from TOBFCDE where codobf = v_codobf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TOBFCDE');
                return;
            end;

            begin
                select codpay into v_codincbf from TINEXINF where codpay = v_codincbf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TINEXINF');
                return;
            end;

            begin
                select codpay into v_codincbf from TINEXINFC where codcompy = p_codcompy and codpay = v_codincbf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TINEXINFC');
                return;
            end;

        end loop;

    end check_save;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        param_json_row      json;
        v_codobf            tobfcompy.codobf%type;
        v_codobf_old        tobfcompy.codobf%type;
        v_codincbf          tobfcompy.codincbf%type;
        v_flg               varchar2(6 char);
        v_count_tobfcftd    number;
        v_count_tobfcfpd    number;
        v_count_tobfinf     number;
    begin
        initial_value(json_str_input);
        check_save;

        if param_msg_error is null then
            if p_flgCopy = 'Y' then
                begin
                    delete tobfcompy where codcompy = p_codcompy;
                exception when others then
                    null;
                end;
            end if;
            for i in 0..json_params.count-1 loop
                param_json_row      := hcm_util.get_json(json_params, to_char(i));
                v_codobf            := hcm_util.get_string(param_json_row, 'codobf');
                v_codobf_old        := hcm_util.get_string(param_json_row, 'codobfOld');
                v_codincbf          := hcm_util.get_string(param_json_row, 'codincbf');
                v_flg               := hcm_util.get_string(param_json_row, 'flg');
                v_count_tobfcftd    := 0;
                v_count_tobfcfpd    := 0;
                v_count_tobfinf     := 0;

                if v_flg = 'add' then
                    begin
                        insert into tobfcompy(codcompy,codobf,codincbf,codcreate,dtecreate)
                        values (p_codcompy,v_codobf,v_codincbf,global_v_coduser,trunc(sysdate));
                    exception when dup_val_on_index then
                        param_msg_error := p_flgCopy||get_error_msg_php('HR2005',global_v_lang, 'TOBFCOMPY');
                    end;
                elsif v_flg = 'edit' then
                    begin
                        update  tobfcompy
                        set     codobf    = v_codobf,
                                codincbf  = v_codincbf,
                                dteupd    = trunc(sysdate),
                                coduser   = global_v_coduser
                        where   codcompy  = p_codcompy
                        and     codobf    = v_codobf_old;
                    exception when others then
                        rollback;
                    end;
                elsif v_flg = 'delete' then
                    begin
                        select count(*) into v_count_tobfcftd
                        from TOBFCFTD a, TEMPLOY1 b
                        where   a.codempid = b.codempid
                        and     codobf = v_codobf
                        and     get_codcompy(b.codcomp) = p_codcompy
                        and     rownum = 1;
                    exception when others then
                        null;
                    end;
                    begin
                        select count(*) into v_count_tobfcfpd
                        from TOBFCFPD
                        where   codcomp like p_codcompy || '%'
                        and     codobf = v_codobf
                        and     rownum = 1;
                    exception when others then
                        null;
                    end;
                    begin
                        select count(*) into v_count_tobfinf
                        from TOBFINF
                        where   codcomp like p_codcompy || '%'
                        and     codobf = v_codobf
                        and     rownum = 1;
                    exception when others then
                        null;
                    end;
                    if v_count_tobfcftd > 0 or v_count_tobfcfpd > 0 or v_count_tobfinf > 0 then
                        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    else
                        begin
                            delete
                            from    tobfcompy
                            where   codcompy = p_codcompy
                            and     codobf = v_codobf;
                        exception when others then
                            null;
                        end;
                    end if;
                end if;
            end loop;
        end if;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

END HRBF49E;

/
