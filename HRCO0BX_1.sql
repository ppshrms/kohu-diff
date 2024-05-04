--------------------------------------------------------
--  DDL for Package Body HRCO0BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO0BX" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codpos        := upper(hcm_util.get_string_t(json_obj,'codpos'));
        p_codcomp       := upper(hcm_util.get_string_t(json_obj,'codcomp'));
        p_dtestr        := to_date(hcm_util.get_string_t(json_obj,'dtestr'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(json_obj,'dteend'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- บังคับใส่ข้อมูล หน่วยงาน,วันที่ตั้งแต่,สิ้นสุด
        if (p_codcomp is null) or (p_dtestr is null) or (p_dteend is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        --ถ้าวันที่เริ่มต้นมากกว่าวันที่สิ้นสุด
        if (p_dtestr > p_dteend) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        -- รหัสตำแหน่งต้องมีในตาราง tpostn (HR2010)
        if p_codpos is not null then
            begin
                select 'X' into v_temp
                from tpostn
                where codpos = p_codpos;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
                return;
            end;
        end if;
        -- รหัสหน่วยงาน ต้องมีในตาราง tcenter (HR2010)
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            fetch first 1 rows only;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

        -- ตรวจสอบ secure (HR3007)
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_result  json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c_tlogjobpos is
            select * from tlogjobpos
            where
                codpos = nvl(p_codpos,codpos) and
                codcomp like p_codcomp||'%' and
                trunc(dtechg) between p_dtestr and p_dteend
            order by dtechg,codpos;
    begin
        obj_result := json_object_t();

        for r1 in c_tlogjobpos loop
            -- ระดับพนักงานเริ่มต้น
            if r1.joblvlsto is not null or r1.joblvlstn is not null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi'));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
                obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('coduser',r1.codcreate);
                obj_data.put('fldedit',get_label_name('HRCO0BX',global_v_lang,910));
                obj_data.put('value_old',r1.joblvlsto);
                obj_data.put('value_new',r1.joblvlstn);
                obj_result.put(to_char(v_row - 1),obj_data);
            end if;

            -- ระดับพนักงานสิ้นสุด
            if r1.joblvleno is not null or r1.joblvlenn is not null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi'));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
                obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('coduser',r1.codcreate);
                obj_data.put('fldedit',get_label_name('HRCO0BX',global_v_lang,920));
                obj_data.put('value_old',r1.joblvleno);
                obj_data.put('value_new',r1.joblvlenn);
                obj_result.put(to_char(v_row - 1),obj_data);
            end if;

            -- job code
            if r1.codjobo is not null or r1.codjobn is not null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi'));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
                obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('coduser',r1.codcreate);
                obj_data.put('fldedit',get_label_name('HRCO0BX',global_v_lang,930));
                obj_data.put('value_old',r1.codjobo);
                obj_data.put('value_new',r1.codjobn);
                obj_result.put(to_char(v_row - 1),obj_data);
            end if;

            -- job grade
            if r1.jobgradeo is not null or r1.jobgraden is not null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi'));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
                obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('coduser',r1.codcreate);
                obj_data.put('fldedit',get_label_name('HRCO0BX',global_v_lang,940));
                obj_data.put('value_old',r1.jobgradeo);
                obj_data.put('value_new',r1.jobgraden);
                obj_result.put(to_char(v_row - 1),obj_data);
            end if;

            -- job group
            if r1.jobgroupo is not null or r1.jobgroupn is not null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi'));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
                obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('coduser',r1.codcreate);
                obj_data.put('fldedit',get_label_name('HRCO0BX',global_v_lang,950));
                obj_data.put('value_old',r1.jobgroupo);
                obj_data.put('value_new',r1.jobgroupn);
                obj_result.put(to_char(v_row - 1),obj_data);
            end if;
        end loop;

        -- กรณีไม่พบข้อมูล
        if obj_result.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlogjobpos');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_result.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
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

end hrco0bx;

/
