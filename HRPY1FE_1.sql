--------------------------------------------------------
--  DDL for Package Body HRPY1FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1FE" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_dteyrepay     := hcm_util.get_string_t(json_obj,'dteyrepay');
        p_dtemthpay     := hcm_util.get_string_t(json_obj,'dtemthpay');
        p_codcurr       := hcm_util.get_string_t(json_obj,'codcurr');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล ปี,เดือน,ฐานสกุลเงิน
        if p_dteyrepay is null or p_dtemthpay is null or p_codcurr is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- ฐานสกุลเงิน ตรวจสอบรหัสต้องมีอยู่ในตาราง TCODCURR (HR2010 TCODCURR)
        begin
            select 'X' into v_temp
            from tcodcurr
            where codcodec = p_codcurr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            return;
        end;
    end;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        obj_row         json_object_t;
        obj_data        json_object_t;
        --<<User37 #5488 Final Test Phase 1 V11 08/03/2021 
        obj_table       json_object_t;
        obj_rowtable    json_object_t;
        obj_detailtable json_object_t;
        detail_obj      json_object_t;     
        v_flgDisable    boolean;
        v_warning       varchar2(1000 char);
        v_dteyrepay       number;
        -->>User37 #5488 Final Test Phase 1 V11 08/03/2021 
        v_row number :=0;
        cursor c1 is
            select * from tratechg
            where
                dteyrepay = p_dteyrepay and
                dtemthpay = p_dtemthpay and
                codcurr = p_codcurr;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            obj_row := json_object_t();
            --<<User37 #5488 Final Test Phase 1 V11 08/03/2021 
            obj_table := json_object_t();
            obj_rowtable := json_object_t();
            obj_detailtable := json_object_t();
            detail_obj   := json_object_t();     
            -->>User37 #5488 Final Test Phase 1 V11 08/03/2021 
            for i in c1 loop
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('codcurr_e',i.codcurr_e);
                obj_data.put('desc_codcurr_e',get_tcodec_name('TCODCURR',i.codcurr_e,global_v_lang));
                obj_data.put('codcurr_name',get_tcodec_name('TCODCURR',i.codcurr_e,global_v_lang));
                obj_data.put('ratecurr',i.ratecurr);
                obj_data.put('ratecurr_e',i.ratecurr_e);
                obj_table.put(to_char(v_row-1),obj_data);--User37 #5488 Final Test Phase 1 V11 08/03/2021 obj_row.put(to_char(v_row-1),obj_data);
                v_dteyrepay := i.dteyrepay;--User37 #5488 Final Test Phase 1 V11 08/03/2021 
            end loop;
            --<<User37 #5488 Final Test Phase 1 V11 08/03/2021 
            obj_rowtable.put('rows', obj_table);
            obj_row.put('coderror','200');
            obj_row.put('table', obj_rowtable);
            if to_number(p_dteyrepay) < to_number(to_char(sysdate,'yyyy')) then
                v_flgDisable := true;
                v_warning    := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400');
                if v_dteyrepay is null then
                    v_dteyrepay  := to_number(p_dteyrepay);
                    v_flgDisable := false;
                    v_warning    := '';
                end if;
            else
                v_dteyrepay  := to_number(p_dteyrepay);
                v_flgDisable := false;
                v_warning    := '';
            end if;
            detail_obj.put('flgDisable',v_flgDisable);
            detail_obj.put('warning',v_warning);
            detail_obj.put('dteyrepay',v_dteyrepay);
            obj_row.put('detail',detail_obj);
            -->>User37 #5488 Final Test Phase 1 V11 08/03/2021 
            json_str_output := obj_row.to_clob;
            return;
        end if;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure validate_save(v_codcurr_e varchar2,v_ratecurr number,v_ratecurr_e number,v_flg varchar2) as
        v_count number:=0;
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล (HR2045)
        if v_codcurr_e is null or v_ratecurr is null or v_ratecurr_e is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- อัตราแลกเปลี่ยนถ้า <= 0 แจ้งเตือน HR2019 - ค่าที่ระบุต้องมีค่ามากกว่าศูนย์
        if upper(v_flg) = 'ADD' or upper(v_flg) = 'EDIT' then
            if v_ratecurr <= 0 or v_ratecurr_e <= 0 then
                param_msg_error := get_error_msg_php('HR2019',global_v_lang);
                return;
            end if;
        end if;

        -- รหัสสกุลเงินที่ระบุจะต้อง <> ฐานสกุลเงิน แจ้งเตือน PY0004 – รหัสสกุลเงินที่บันทึกต้องไม่ตรงกับฐานสกุลเงิน
        if v_codcurr_e = p_codcurr then
            param_msg_error := get_error_msg_php('PY0004',global_v_lang);
            return;
        end if;

        -- ตรวจสอบ การ Dup ของ PK : กรณีรหัสซ้า (HR2005 TRATECHG)
        if upper(v_flg) = 'ADD' then
            begin
                select count(*) into v_count
                from tratechg
                where
                    dteyrepay = p_dteyrepay and
                    dtemthpay = p_dtemthpay and
                    codcurr = p_codcurr and
                    codcurr_e = v_codcurr_e;
            exception when others then null;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TRATECHG');
                return;
            end if;
        end if;

    end validate_save;

    procedure save_index(json_str_input in clob,json_str_output out clob) as
        v_codcurr_e     varchar2(4 char);
        v_ratechge1     number(17,10);
        v_ratechge2     number(17,10);
        v_ratecurr      number(17,10);
        v_ratecurr_e    number(17,10);
        v_flg           varchar2(10 char);
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_count         number := 0;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            json_obj        := json_object_t(json_str_input);
            param_json      := hcm_util.get_json_t(json_obj,'param_json');
            for i in 0..param_json.get_size-1 loop
                obj_data        := hcm_util.get_json_t(param_json,to_char(i));
                v_codcurr_e     := hcm_util.get_string_t(obj_data,'codcurr_e');
                v_ratecurr      := to_number(hcm_util.get_string_t(obj_data,'ratecurr'));
                v_ratecurr_e    := to_number(hcm_util.get_string_t(obj_data,'ratecurr_e'));
                v_ratechge1     := v_ratecurr/v_ratecurr_e;
                v_ratechge2     := v_ratecurr_e/v_ratecurr;
                v_flg           := hcm_util.get_string_t(obj_data,'flg');

                validate_save(v_codcurr_e,v_ratecurr,v_ratecurr_e,v_flg);
                if param_msg_error is not null then
                    exit;
                end if;

                if upper(v_flg) = 'ADD' then

                    -- ข้อมูลหลัก
                    insert into tratechg (
                        dteyrepay,
                        dtemthpay,
                        codcurr,
                        codcurr_e,
                        ratechge,
                        ratecurr,
                        ratecurr_e,
                        codcreate,
                        coduser)
                    values (
                        p_dteyrepay,
                        p_dtemthpay,
                        p_codcurr,
                        v_codcurr_e,
                        v_ratechge1,
                        v_ratecurr,
                        v_ratecurr_e,
                        global_v_coduser,
                        global_v_coduser);

                    -- ข้อมูลตรงข้าม
                    begin
                        insert into tratechg (
                            dteyrepay,
                            dtemthpay,
                            codcurr,
                            codcurr_e,
                            ratechge,
                            ratecurr,
                            ratecurr_e,
                            codcreate,
                            coduser)
                        values (
                            p_dteyrepay,
                            p_dtemthpay,
                            v_codcurr_e,
                            p_codcurr,
                            v_ratechge2,
                            v_ratecurr_e,
                            v_ratecurr,
                            global_v_coduser,
                            global_v_coduser);
                    exception when dup_val_on_index then
                        update tratechg set
                            ratechge = v_ratechge2,
                            ratecurr = v_ratecurr_e,
                            ratecurr_e = v_ratecurr,
                            coduser = global_v_coduser
                        where
                            dteyrepay = p_dteyrepay and
                            dtemthpay = p_dtemthpay and
                            codcurr = v_codcurr_e and
                            codcurr_e = p_codcurr;
                    end;
                elsif upper(v_flg) = 'EDIT' then

                    -- ข้อมูลหลัก
                    update tratechg set
                        ratechge = v_ratechge1,
                        ratecurr = v_ratecurr,
                        ratecurr_e = v_ratecurr_e,
                        coduser = global_v_coduser
                    where
                        dteyrepay = p_dteyrepay and
                        dtemthpay = p_dtemthpay and
                        codcurr = p_codcurr and
                        codcurr_e = v_codcurr_e;

                    begin
                        select count(*) into v_count
                        from tratechg
                        where
                            dteyrepay = p_dteyrepay and
                            dtemthpay = p_dtemthpay and
                            codcurr = v_codcurr_e and
                            codcurr_e = p_codcurr;
                    exception when others then null;
                    end;

                    -- ข้อมูลตรงข้าม
                    if v_count > 0 then
                        update tratechg set
                            ratechge = v_ratechge2,
                            ratecurr = v_ratecurr_e,
                            ratecurr_e = v_ratecurr,
                            coduser = global_v_coduser
                        where
                            dteyrepay = p_dteyrepay and
                            dtemthpay = p_dtemthpay and
                            codcurr = v_codcurr_e and
                            codcurr_e = p_codcurr;
                    else
                        insert into tratechg (
                            dteyrepay,
                            dtemthpay,
                            codcurr,
                            codcurr_e,
                            ratechge,
                            ratecurr,
                            ratecurr_e,
                            codcreate,
                            coduser)
                        values (
                            p_dteyrepay,
                            p_dtemthpay,
                            v_codcurr_e,
                            p_codcurr,
                            v_ratechge2,
                            v_ratecurr_e,
                            v_ratecurr,
                            global_v_coduser,
                            global_v_coduser);
                    end if;

                elsif upper(v_flg) = 'DELETE' then
                    delete from tratechg
                    where
                        dteyrepay = p_dteyrepay and
                        dtemthpay = p_dtemthpay and
                        codcurr   = p_codcurr and
                        codcurr_e = v_codcurr_e;

                    -- ข้อมูลตรงข้าม
                    delete from tratechg
                    where
                        dteyrepay = p_dteyrepay and
                        dtemthpay = p_dtemthpay and
                        codcurr   = v_codcurr_e and
                        codcurr_e = p_codcurr;
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
    end save_index;

end HRPY1FE;

/
