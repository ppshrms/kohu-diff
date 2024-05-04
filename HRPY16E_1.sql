--------------------------------------------------------
--  DDL for Package Body HRPY16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY16E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codbrsoc        := hcm_util.get_string_t(json_obj,'codbrsoc');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล
        if p_codbrsoc is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        obj_row json_object_t;
        obj_data json_object_t;
        v_row number :=0;
        cursor c1 is
            select codcompy,
                    codbrlc,
                    codbrsoc,
                    numbrlvl,
                    adrcome1,
                    zipcode,
                    numtele,
                    numfax
            from tcodsoc
            where codbrsoc = p_codbrsoc
            order by codcompy,codbrlc;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            obj_row := json_object_t();
            for i in c1 loop
                -- ก่อนนาข้อมูลมาแสดงให้ตรวจสอบสิทธิ Secure โดยใช้ secur_main.secur7
                if secur_main.secur7(i.codcompy,global_v_coduser) = true then
                    v_row := v_row+1;
                    obj_data := json_object_t();
                    obj_data.put('codcompy',i.codcompy);
                    obj_data.put('codbrlc',i.codbrlc);
                    obj_data.put('numbrlvl',i.numbrlvl);
                    obj_data.put('codbrlc_name',get_tcodloca_name(i.codbrlc,global_v_lang));
                    obj_row.put(to_char(v_row-1),obj_data);
                end if;
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
        v_codcompy  varchar2(4 char);
        v_codbrlc   varchar2(4 char);
        v_numbrlvl  varchar2(6 char);
        v_adrcome1  varchar2(300 char);
        v_zipcode   varchar2(5 char);
        v_numtele   varchar2(30 char);
        v_numfax    varchar2(20 char);
        v_flg       varchar2(10 char);
        json_obj    json_object_t;
        obj_data    json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            json_obj        := json_object_t(json_str_input);
            param_json      := hcm_util.get_json_t(json_obj,'param_json');
            for i in 0..param_json.get_size-1 loop
                obj_data    := hcm_util.get_json_t(param_json,to_char(i));
                v_codcompy  := hcm_util.get_string_t(obj_data,'codcompy');
                v_codbrlc   := hcm_util.get_string_t(obj_data,'codbrlc');
                v_numbrlvl  := hcm_util.get_string_t(obj_data,'numbrlvl');
                v_adrcome1  := hcm_util.get_string_t(obj_data,'adrcome1');
                v_zipcode   := hcm_util.get_string_t(obj_data,'zipcode');
                v_numtele   := hcm_util.get_string_t(obj_data,'numtele');
                v_numfax    := hcm_util.get_string_t(obj_data,'numfax');
                v_flg       := hcm_util.get_string_t(obj_data,'flgEdit');

                -- ฟิลด์ที่บังคับใส่ข้อมูล(HR2045) ที่อยู่,ลำดับสาขา
                if v_flg = 'Add' or v_flg = 'Edit' then
                    if v_adrcome1 is null or v_numbrlvl is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                        exit;
                    end if;
                end if;
                if v_flg = 'Add' then
                    insert into tcodsoc (
                        codcompy,
                        codbrlc,
                        codbrsoc,
                        numbrlvl,
                        adrcome1,
                        zipcode,
                        numtele,
                        numfax,
                        codcreate,
                        coduser)
                    values  (
                        v_codcompy,
                        v_codbrlc,
                        p_codbrsoc,
                        v_numbrlvl,
                        v_adrcome1,
                        v_zipcode,
                        v_numtele,
                        v_numfax,
                        global_v_coduser,
                        global_v_coduser);
                elsif v_flg = 'Edit' then
                    update tcodsoc set
                        numbrlvl = v_numbrlvl,
                        adrcome1 = v_adrcome1,
                        zipcode  = v_zipcode,
                        numtele  = v_numtele,
                        numfax   = v_numfax,
                        coduser  = global_v_coduser
                    where
                        codcompy = v_codcompy and
                        codbrlc = v_codbrlc and
                        codbrsoc = p_codbrsoc;
                elsif v_flg = 'Delete' then
                    delete from tcodsoc
                    where
                        codcompy = v_codcompy and
                        codbrlc = v_codbrlc and
                        codbrsoc = p_codbrsoc;
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
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    procedure validate_get_detail(v_codcompy varchar2,v_codbrlc varchar2) as
        v_temp varchar2(1 char);
        v_count number:=0;
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล(HR2045) รหัสบริษัท,สถานที่ทางาน
        if v_codcompy is null or v_codbrlc is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- ตรวจสอบรหัสต้องมีอยู่ในตาราง TCOMPNY (HR2010)
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy = v_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;

        -- ตรวจสอบรหัสต้องมีอยู่ในตาราง TCODLOCA (HR2010)
        begin
            select 'X' into v_temp
            from tcodloca
            where codcodec = v_codbrlc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODLOCA');
            return;
        end;
        -- ตรวจสอบ หน่วยงานและสถานที่ทางาน ที่ระบุจะต้องไม่เคยนาไปบันทึกในกลุ่มสาขาอื่น ตรวจสอบที่ตาราง TCODSOC กรณีพบข้อมูลซ้าให้แจ้งเตือน PY0028 - หน่วยงานและสถานที่ทางานมีอยู่ในกลุ่มประกันสังคมอื่น
        begin
            select count(*) into v_count
            from tcodsoc
            where
                codcompy = v_codcompy and
                codbrlc = v_codbrlc and
                codbrsoc != p_codbrsoc;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('PY0028',global_v_lang);
            return;
        end if;
        -- ตรวจสอบ Secure (HR3007)
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, v_codcompy);
    end;
    procedure get_detail(json_str_input in clob,json_str_output out clob) as
        json_obj json_object_t;
        v_codcompy  tcenter.codcompy%type;
        v_codbrlc   varchar2(4 char);
--        v_codbrsoc  varchar2(2 char);
        v_numbrlvl  varchar2(6 char);
        v_adrcome1  tcompny.adrcome%type;
        v_zipcode   tcompny.zipcode%type;
        v_numtele   tcompny.numtele%type;
        v_numfax    tcompny.numfax%type;
        v_flg       varchar2(10 char);
        v_temp      varchar2(1 char);
        v_cadrcome  tcompny.adrcome%type;
        v_cadrcomt  tcompny.adrcomt%type;
        v_cadrcom3  tcompny.adrcom3%type;
        v_cadrcom4  tcompny.adrcom4%type;
        v_cadrcom5  tcompny.adrcom5%type;
        obj_data json_object_t;
        obj_row json_object_t := json_object_t();
    begin
        initial_value(json_str_input);
        check_index;

        json_obj          := json_object_t(json_str_input);
        v_codcompy  := hcm_util.get_string_t(json_obj,'codcompy');
        v_codbrlc   := hcm_util.get_string_t(json_obj,'codbrlc');
        validate_get_detail(v_codcompy,v_codbrlc);
        
        if param_msg_error is null then
        
            begin
                select 'X' into v_temp
                from tcodsoc
                where
                    codcompy = v_codcompy and
                    codbrlc = v_codbrlc and
                    codbrsoc = p_codbrsoc;
            exception when no_data_found then
                begin
                    select
                        adrcome,
                        adrcomt,
                        adrcom3,
                        adrcom4,
                        adrcom5,
                        zipcode,
                        numtele,
                        numfax
                    into
                        v_cadrcome,
                        v_cadrcomt,
                        v_cadrcom3,
                        v_cadrcom4,
                        v_cadrcom5,
                        v_zipcode,
                        v_numtele,
                        v_numfax
                    from tcompny
                    where codcompy = v_codcompy;
                    
                    if global_v_lang = '101' then
                        v_adrcome1 := v_cadrcome;
                    elsif global_v_lang = '102' then
                        v_adrcome1 := v_cadrcomt;
                    elsif global_v_lang = '103' then
                        v_adrcome1 := v_cadrcom3;
                    elsif global_v_lang = '104' then
                        v_adrcome1 := v_cadrcom4;
                    elsif global_v_lang = '105' then
                        v_adrcome1 := v_cadrcom5;
                    end if;
                exception when no_data_found then
                    v_adrcome1 := '';
                    v_zipcode := '';
                    v_numtele := '';
                    v_numfax := '';
                end;
                v_numbrlvl := '';
                v_flg := 'Add';
            end;
            if v_temp = 'X' then
                begin
                    select
                        numbrlvl,
                        adrcome1,
                        zipcode,
                        numtele,
                        numfax,
                        'Edit'
                    into
                        v_numbrlvl,
                        v_adrcome1,
                        v_zipcode,
                        v_numtele,
                        v_numfax,
                        v_flg
                    from tcodsoc
                    where
                        codcompy = v_codcompy and
                        codbrlc = v_codbrlc and
                        codbrsoc = p_codbrsoc;
                exception when others then null;
                end;
            end if;
            
            obj_data := json_object_t();
            obj_data.put('codcompy',v_codcompy);
            obj_data.put('codbrlc',v_codbrlc);
            obj_data.put('codbrsoc',p_codbrsoc);
            obj_data.put('numbrlvl',v_numbrlvl);
            obj_data.put('adrcome1',v_adrcome1);
            obj_data.put('zipcode',v_zipcode);
            obj_data.put('numtele',v_numtele);
            obj_data.put('numfax',v_numfax);
            obj_data.put('flgEdit',v_flg);
            obj_row.put('0',obj_data);
            json_str_output := obj_row.to_clob;

            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

end HRPY16E;

/
