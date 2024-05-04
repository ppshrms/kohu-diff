--------------------------------------------------------
--  DDL for Package Body HRCO08E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO08E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcompy      := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_codsys        := upper(hcm_util.get_string_t(json_obj,'p_codsys'));

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_secur boolean;
        v_secur_codcomp varchar2(1000 char);
    begin
        -- ให้ระบุรหัสบริษัท และ เลือกระบบงาน
        if (p_codcompy is null) or (p_codsys is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสบริษัท ต้องมีข้อมูลในตาราง TCOMPNY
        begin
            select 'X' into v_temp from tcompny where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        -- รหัสระบบงานย่อย ต้องมีข้อมูลในตาราง TLISTVAL where CODAPP = ‘SUBSYSTEM’
        begin
            select 'X' into v_temp from tlistval where codapp = 'SUBSYSTEM' and list_value = p_codsys and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TLISTVAL');
            return;
        end;
        -- รหัสบริษัทให้เช็ค   Security   จาก package HCM_SECUR.SECUR_CODCOMP
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_numseq    tcontdel.numseq%type;
        v_rec_tcontdel tcontdel%rowtype;
        cursor c_tdelmain is
            select codsys,numseq,decode(global_v_lang,'101',descripte,'102',descriptt
                                        ,'103',descript3,'104',descript4,'105',descript5) descript
            from tdelmain
            where codsys = p_codsys
            order by numseq;
    begin
        obj_rows := json_object_t();
        for c1 in c_tdelmain loop
            v_row := v_row + 1;
            begin
                select * into v_rec_tcontdel from tcontdel
                where codcompy = p_codcompy
                and codsys = p_codsys
                and numseq = c1.numseq;
            exception when no_data_found then
                v_rec_tcontdel := null;
            end;

            obj_data := json_object_t();
            obj_data.put('numseq',c1.numseq);
            obj_data.put('descript',c1.descript);
            obj_data.put('yredel',trunc(nvl(v_rec_tcontdel.qtymonth,0) / 12,0));
            obj_data.put('mthdel',mod(nvl(v_rec_tcontdel.qtymonth,0),12));
            obj_data.put('dteupd',to_char(v_rec_tcontdel.dteupd,'dd/mm/yyyy'));
            obj_data.put('coduser',v_rec_tcontdel.coduser);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
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
    end get_index;

    procedure save_data(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        json_data   json_object_t;
        v_numseq    tcontdel.numseq%type;
        v_yredel    number;
        v_mthdel    number;
        v_flgedit   varchar2(10 char);
        v_count     number := 0;
        v_qtymonth  tcontdel.qtymonth%type;
    begin
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            json_data   := hcm_util.get_json_t(param_json,to_char(i));
            v_numseq    := to_number(hcm_util.get_string_t(json_data,'numseq'));
            v_yredel    := to_number(hcm_util.get_string_t(json_data,'yredel'));
            v_mthdel    := to_number(hcm_util.get_string_t(json_data,'mthdel'));
            if v_mthdel >= 12 then
                param_msg_error := get_error_msg_php('CO0031',global_v_lang);
                exit;
            end if;
            v_flgedit   := hcm_util.get_string_t(json_data,'flgedit');
            v_qtymonth  := (nvl(v_yredel,0) * 12) + nvl(v_mthdel,0);
            if v_flgedit = 'Edit' then
                begin
                    select count(*) into v_count
                    from tcontdel
                    where codcompy = p_codcompy
                    and codsys = p_codsys
                    and numseq = v_numseq;
                exception when others then
                    v_count := 0;
                end;

                if v_count < 1 then
                    insert into tcontdel (codcompy, codsys, numseq, qtymonth, dteupd, coduser, dtecreate, codcreate)
                    values (p_codcompy, p_codsys, v_numseq, v_qtymonth, sysdate, global_v_coduser, sysdate, global_v_coduser);
                else
                    update tcontdel set
                        qtymonth   = v_qtymonth,
                        dteupd     = sysdate,
                        coduser    = global_v_coduser
                    where codcompy = p_codcompy
                        and codsys = p_codsys
                        and numseq = v_numseq;
                end if;
            end if;
        end loop;
        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            save_data(json_str_input,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;
end HRCO08E;

/
