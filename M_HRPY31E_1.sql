--------------------------------------------------------
--  DDL for Package Body M_HRPY31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPY31E" as

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
            select * from taccodb order by codacc;
    begin
        initial_value(json_str_input);
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codacc',i.codacc);
            obj_data.put('desacce',i.desacce);
            obj_data.put('desacct',i.desacct);
            obj_data.put('desacc3',i.desacc3);
            obj_data.put('desacc4',i.desacc4);
            obj_data.put('desacc5',i.desacc5);
            obj_data.put('poskeydb',i.poskeydb);
            obj_data.put('poskeycr',i.poskeycr);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
        return;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure validate_save(v_codacc varchar2,v_desacce varchar2,v_desacct varchar2,v_desacc3 varchar2,v_desacc4 varchar2,v_desacc5 varchar2,v_flg varchar2) as
        v_count number := 0;
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสบัญชี (HR2045)
        if v_codacc is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- ฟิลด์ที่บังคับใส่ข้อมูล ชื่อบัญชี (HR2045)
        if global_v_lang = '101' and v_desacce is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '102' and v_desacct is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '103' and v_desacc3 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '104' and v_desacc4 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '105' and v_desacc5 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if v_flg = 'Add' then
            -- ต้องไม่ซ้ากับที่มีอยู่ ตาม PK ของตาราง TACCODB (HR2005)
            begin
                select count(*) into v_count
                from taccodb
                where codacc = v_codacc;
            exception when others then null;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TACCODB');
                return;
            end if;
        end if;
    end validate_save;

    procedure save_index(json_str_input in clob,json_str_output out clob) as
        v_codacc  varchar2(25 char);
        v_desacce varchar2(150 char);
        v_desacct varchar2(150 char);
        v_desacc3 varchar2(150 char);
        v_desacc4 varchar2(150 char);
        v_desacc5 varchar2(150 char);
        v_poskeydb varchar2(2 char);
        V_poskeycr varchar2(2 char);
        v_flg varchar2(10 char);
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_count         number;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            obj_data      := hcm_util.get_json_t(param_json,to_char(i));
            v_codacc      := hcm_util.get_string_t(obj_data,'codacc');
            v_desacce     := hcm_util.get_string_t(obj_data,'desacce');
            v_desacct     := hcm_util.get_string_t(obj_data,'desacct');
            v_desacc3     := hcm_util.get_string_t(obj_data,'desacc3');
            v_desacc4     := hcm_util.get_string_t(obj_data,'desacc4');
            v_desacc5     := hcm_util.get_string_t(obj_data,'desacc5');
            v_poskeydb    := hcm_util.get_string_t(obj_data,'poskeydb');
            v_poskeycr    := hcm_util.get_string_t(obj_data,'poskeycr');

            v_flg         := hcm_util.get_string_t(obj_data,'flgEdit');

            validate_save(v_codacc,v_desacce,v_desacct,v_desacc3,v_desacc4,v_desacc5,v_flg);
            if param_msg_error is not null then
                exit;
            end if;

            if v_flg = 'Add' then
                insert into taccodb (
                    codacc,
                    desacce,
                    desacct,
                    desacc3,
                    desacc4,
                    desacc5,
                    poskeydb,
                    poskeycr,
                    codcreate,
                    coduser)
                values (
                    v_codacc,
                    v_desacce,
                    v_desacct,
                    v_desacc3,
                    v_desacc4,
                    v_desacc5,
                    v_poskeydb,
                    v_poskeycr,
                    global_v_coduser,
                    global_v_coduser);
            elsif v_flg = 'Edit' then
                update taccodb set
                    desacce = v_desacce,
                    desacct = v_desacct,
                    desacc3 = v_desacc3,
                    desacc4 = v_desacc4,
                    desacc5 = v_desacc5,
                    poskeydb = v_poskeydb,
                    poskeycr = v_poskeycr,
                    coduser = global_v_coduser
                where codacc = v_codacc;
            elsif v_flg = 'Delete' then
                begin
                    select count(*)
                      into v_count
                      from tglhtabi 
                     where codaccdr = v_codacc
                        or scodaccdr = v_codacc
                        or codacccr = v_codacc
                        or scodacccr = v_codacc;                    
                exception when others then
                    v_count := 0;
                end;

                if v_count = 0 then
                    delete from taccodb
                    where codacc = v_codacc;
                else
                    param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    exit;
                end if;
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

end M_HRPY31E;

/
