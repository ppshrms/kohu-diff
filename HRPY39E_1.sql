--------------------------------------------------------
--  DDL for Package Body HRPY39E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY39E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    end initial_value;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        obj_row json_object_t;
        obj_data json_object_t;
        v_row number :=0;
        cursor c1 is
            select * from tcoscent order by costcent;
    begin
        initial_value(json_str_input);
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('costcent',i.costcent);
            obj_data.put('namcente',i.namcente);
            obj_data.put('namcentt',i.namcentt);
            obj_data.put('namcent3',i.namcent3);
            obj_data.put('namcent4',i.namcent4);
            obj_data.put('namcent5',i.namcent5);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
        return;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure validate_save(v_costcent varchar2,v_namcente varchar2,v_namcentt varchar2,v_namcent3 varchar2,v_namcent4 varchar2,v_namcent5 varchar2,v_flg varchar2) as
        v_count number := 0;
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล รหัส Cost Center (HR2045)
        if v_costcent is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- ฟิลด์ที่บังคับใส่ข้อมูล ชื่อ Cost Center (HR2045)
        if global_v_lang = '101' and v_namcente is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '102' and v_namcentt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '103' and v_namcent3 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '104' and v_namcent4 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '105' and v_namcent5 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if v_flg = 'Add' then
            -- ตรวจสอบ การ Dup ของ PK : กรณีรหัสซ้า (HR2005 TCOSCENT)
            begin
                select count(*) into v_count
                from tcoscent
                where costcent = v_costcent;
            exception when others then null;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TCOSCENT');
                return;
            end if;
        end if;

        if v_flg = 'Delete' then
            -- ตรวจสอบว่ามีการนาไปใช้หรือยัง จากตารางดังนี้ tcenter.costcent ถ้าเจอข้อมูลให้แจ้งเตือน HR1450
            begin
                select count(*) into v_count
                from tcenter
                where costcent = v_costcent;
            exception when others then null;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TCENTER');
                return;
            end if;
        end if;
    end validate_save;

    procedure save_index(json_str_input in clob,json_str_output out clob) as
        v_costcent varchar2(25 char);
        v_namcente varchar2(150 char);
        v_namcentt varchar2(150 char);
        v_namcent3 varchar2(150 char);
        v_namcent4 varchar2(150 char);
        v_namcent5 varchar2(150 char);
        v_flg varchar2(10 char);
        json_obj        json_object_t;
        obj_data        json_object_t;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            obj_data        := hcm_util.get_json_t(param_json,to_char(i));
            v_costcent      := hcm_util.get_string_t(obj_data,'costcent');
            v_namcente      := hcm_util.get_string_t(obj_data,'namcente');
            v_namcentt      := hcm_util.get_string_t(obj_data,'namcentt');
            v_namcent3      := hcm_util.get_string_t(obj_data,'namcent3');
            v_namcent4      := hcm_util.get_string_t(obj_data,'namcent4');
            v_namcent5      := hcm_util.get_string_t(obj_data,'namcent5');
            v_flg           := hcm_util.get_string_t(obj_data,'flgEdit');

            validate_save(v_costcent,v_namcente,v_namcentt,v_namcent3,v_namcent4,v_namcent5,v_flg);
            if param_msg_error is not null then
                exit;
            end if;

            if v_flg = 'Add' then
                insert into tcoscent (
                    costcent,
                    namcente,
                    namcentt,
                    namcent3,
                    namcent4,
                    namcent5,
                    codcreate,
                    coduser)
                values (
                    v_costcent,
                    v_namcente,
                    v_namcentt,
                    v_namcent3,
                    v_namcent4,
                    v_namcent5,
                    global_v_coduser,
                    global_v_coduser);
            elsif v_flg = 'Edit' then
                update tcoscent
                set
                    namcente = v_namcente,
                    namcentt = v_namcentt,
                    namcent3 = v_namcent3,
                    namcent4 = v_namcent4,
                    namcent5 = v_namcent5,
                    coduser = global_v_coduser
                where costcent = v_costcent;
            elsif v_flg = 'Delete' then
                delete from tcoscent where costcent = v_costcent;
            end if;
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

end HRPY39E;

/
