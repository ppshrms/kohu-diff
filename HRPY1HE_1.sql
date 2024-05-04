--------------------------------------------------------
--  DDL for Package Body HRPY1HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1HE" as
    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codcompy        := hcm_util.get_string_t(json_obj,'codcompy');
        p_typbank         := hcm_util.get_string_t(json_obj,'typbank');

    end initial_value;

    procedure check_index is
        v_count_compny  number := 0;
    begin
        -- รหัสบริษัท ตรวจสอบรหัสต้องมีอยู่ในตาราง tcompny (hr2010 tcompny)
        begin
            select count(*) into v_count_compny
            from tcompny
            where codcompy = p_codcompy;
        exception when others then null;
        end;
        if v_count_compny < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
             return;
        end if;
        -- รหัสบริษัท ตรวจสอบ secure (hr3007)
        if p_codcompy is not null then
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
          if param_msg_error is not null then
            return;
          end if;
        end if;
    end check_index;

    procedure gen_data(json_str_output out clob) is
        obj_result      json_object_t;
        obj_tbnkmdi     json_object_t;
        obj_row         json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_tbnkmdi1_rec  tbnkmdi1%rowtype;

        cursor c1 is
            select * from tbnkmdi2
            where
                codcompy = p_codcompy and
                typbank = p_typbank;
    begin
        obj_result := json_object_t;
        obj_tbnkmdi  := json_object_t();
        obj_row := json_object_t();
        begin
            select * into v_tbnkmdi1_rec
            from tbnkmdi1
            where
                codcompy = p_codcompy and
                typbank = p_typbank;
        exception when no_data_found then
--            v_row := v_row + 1;
--            obj_data := json();
--            obj_data.put('codbank','');
--            obj_data.put('codmedia','');
--            obj_data.put('bankfee','');
--            obj_row.put(to_char(v_row - 1),obj_data);
            obj_tbnkmdi.put('codcompy',p_codcompy);
            obj_tbnkmdi.put('typbank',p_typbank);
            obj_tbnkmdi.put('numacct','');
            obj_tbnkmdi.put('codbkserv','');
            obj_tbnkmdi.put('rows',obj_row);
            obj_result.put(0,obj_tbnkmdi);
            json_str_output := obj_result.to_clob;
            return;
        end;
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codbank',i.codbank);
            obj_data.put('desc_codbank',get_tcodec_name('tcodbank',i.codbank,global_v_lang));
            obj_data.put('codmedia',i.codmedia);
            obj_data.put('bankfee',nvl(to_char(i.bankfee),''));
            obj_row.put(to_char(v_row - 1),obj_data);
        end loop;
        obj_tbnkmdi.put('codcompy',v_tbnkmdi1_rec.codcompy);
        obj_tbnkmdi.put('typbank',v_tbnkmdi1_rec.typbank);
        obj_tbnkmdi.put('numacct',v_tbnkmdi1_rec.numacct);
        obj_tbnkmdi.put('codbkserv',v_tbnkmdi1_rec.codbkserv);
        obj_tbnkmdi.put('rows',obj_row);
        obj_result.put(0,obj_tbnkmdi);
        json_str_output := obj_result.to_clob;
    end gen_data;

    procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            gen_data(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    function check_save_tbnkmdi2 (json_obj json_object_t) return boolean is
        v_codbank       varchar2(4 char);
        v_codmedia      varchar2(4 char);
        v_bankfee       number(7,2) := 0;
        v_editflg       varchar2(10 char);
        v_count_codbank number := 0;
        v_count_dup     number := 0;
    begin
        v_codbank := hcm_util.get_string_t(json_obj,'codbank');
        v_codmedia := hcm_util.get_string_t(json_obj,'codmedia');
        v_bankfee := to_number(hcm_util.get_string_t(json_obj,'bankfee'));
        v_editflg := hcm_util.get_string_t(json_obj,'editflg');
        -- ฟิลด์ที่บังคับใส่ข้อมูล (hr2045)
        if v_codbank is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codbank');
            return false;
        elsif v_codmedia is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codmedia');
            return false;
        end if;
        -- รหัสธนาคาร จะต้องมีอยู่จริงในตาราง tcodbank (hr2010)
        select count(*) into v_count_codbank from tcodbank where codcodec = v_codbank;
        if v_count_codbank < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodbank');
            return false;
        end if;
        if v_editflg = 'Add' or v_editflg = 'Edit' then
            -- ค่าธรรมเนียม ใส่ได้ตั้งแต่ 0-9999.99 (hr2020)
            if v_bankfee is not null then
                if v_bankfee < 0 or v_bankfee > 9999.99 then
                    param_msg_error := get_error_msg_php('HR2020',global_v_lang,'0-9999.99');
                    return false;
                end if;
            end if;
            if v_editflg = 'Add' then
                -- ตรวจสอบ การ dup ของ pk : กรณีรหัสซ้า (hr2005 tbnkmdi2)
                begin
                    select count(*) into v_count_dup
                    from tbnkmdi2
                    where
                        codcompy = p_codcompy and
                        typbank = p_typbank and
                        codbank = v_codbank;
                exception when others then null;
                end;
                if v_count_dup > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tbnkmdi2');
                    return false;
                end if;
            end if;
        end if;

        return true;
    end;

    procedure save_tbnkmdi2 (json_obj json_object_t) is
        v_codbank       varchar2(4 char);
        v_codmedia      varchar2(4 char);
        v_bankfee       number(6,2) := 0;
        v_editflg       varchar2(10 char);
    begin
        v_codbank := hcm_util.get_string_t(json_obj,'codbank');
        v_codmedia := hcm_util.get_string_t(json_obj,'codmedia');
        v_bankfee := to_number(hcm_util.get_string_t(json_obj,'bankfee'));
        v_editflg := hcm_util.get_string_t(json_obj,'editflg');
        if v_editflg = 'Add' then
            insert into tbnkmdi2 (
                codcompy,
                typbank,
                codbank,
                codmedia,
                bankfee,
                dtecreate,
                codcreate,
                coduser
            ) values (
                p_codcompy,
                p_typbank,
                v_codbank,
                v_codmedia,
                v_bankfee,
                sysdate,
                global_v_coduser,
                global_v_coduser
            );
        elsif v_editflg = 'Edit' then
            update tbnkmdi2 set
                codmedia    = v_codmedia,
                bankfee     = v_bankfee,
                dteupd      = sysdate,
                coduser     = global_v_coduser
            where
                codcompy = p_codcompy and
                typbank = p_typbank and
                codbank = v_codbank;
        elsif v_editflg = 'Delete' then
            delete from tbnkmdi2
            where
                codcompy = p_codcompy and
                typbank = p_typbank and
                codbank = v_codbank;
        end if;
    end;

    procedure save_data (json_str_input in clob,json_str_output out clob) is
        json_obj    json_object_t;
        obj_tbnkmdi2    json_object_t;
        v_numacct       varchar2(14 char);
        v_codbkserv     varchar2(10 char);
        v_temp          varchar2(1 char);
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            json_obj    := json_object_t(json_str_input);
            param_json  := hcm_util.get_json_t(json_obj,'param_json');
            v_numacct   := hcm_util.get_string_t(json_obj,'numacct');
            v_codbkserv := hcm_util.get_string_t(json_obj,'codbkserv');
            begin
                select 'x' into v_temp
                from tbnkmdi1
                where
                    codcompy = p_codcompy and
                    typbank = p_typbank;
            exception when no_data_found then
                insert into tbnkmdi1 (
                    codcompy,
                    typbank,
                    numacct,
                    codbkserv,
                    codcreate,
                    coduser)
                values (
                    p_codcompy,
                    p_typbank,
                    v_numacct,
                    v_codbkserv,
                    global_v_coduser,
                    global_v_coduser);
            end;
            if v_temp = 'x' then
                update tbnkmdi1 set
                    numacct     = v_numacct,
                    codbkserv   = v_codbkserv,
                    dteupd      = sysdate,
                    coduser     = global_v_coduser
                where
                    codcompy = p_codcompy and
                    typbank = p_typbank;
            end if;
            for i in 0..param_json.get_size-1 loop
                obj_tbnkmdi2 := hcm_util.get_json_t(param_json,to_char(i));
                if check_save_tbnkmdi2(obj_tbnkmdi2) = false then
                    exit;
                else
                    save_tbnkmdi2(obj_tbnkmdi2);
                end if;
            end loop;
            if param_msg_error is null then
              commit;
              param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            else
              rollback;
            end if;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;


end HRPY1HE;

/
