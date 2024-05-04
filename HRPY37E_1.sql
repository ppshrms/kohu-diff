--------------------------------------------------------
--  DDL for Package Body HRPY37E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY37E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp        := hcm_util.get_string_t(json_obj,'codcomp');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสหน่วยงาน
        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสหน่วยงาน ตรวจสอบรหัสต้องมีอยู่ในตาราง TCENTER (HR2010 TCENTER)
        begin
            select 'X' into v_temp
            from tcenter
            where
                codcomp like p_codcomp||'%' and
                rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;
        -- ตรวจสอบ Secure (HR3007)
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        return;
    end;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        obj_row json_object_t;
        obj_data json_object_t;
        v_row number :=0;
        cursor c1 is
            select codcomp,costcent
            from tcenter
            where codcomp like p_codcomp||'%'
            order by codcomp;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            obj_row := json_object_t();
            for i in c1 loop
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('formatcodcomp',i.codcomp);
                obj_data.put('centername',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('costcent',i.costcent);
                obj_data.put('coscentname',get_tcoscent_name(i.costcent,global_v_lang));
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
            json_str_output := obj_row.to_clob;
            return;
        end if;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure save_index(json_str_input in clob,json_str_output out clob) as
        v_codcomp   varchar2(40 char);
		v_costcent  varchar2(25 char);
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_temp varchar2(1 char);
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            obj_data        := hcm_util.get_json_t(param_json,to_char(i));
            v_codcomp       := hcm_util.get_string_t(obj_data,'codcomp');
            v_costcent      := hcm_util.get_string_t(obj_data,'costcent');
            -- รหัส Cost Center จะต้องมีอยู่จริงในตาราง TCOSCENT (HR2010)
            if v_costcent is not null then
                 begin
                    select 'X' into v_temp
                    from tcoscent
                    where costcent = v_costcent;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOSCENT');
                    exit;
                end;
            end if;

            update tcenter
            set
                costcent = v_costcent,
                coduser = global_v_coduser
            where codcomp = v_codcomp;

        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

end HRPY37E;

/
