--------------------------------------------------------
--  DDL for Package Body HRCO09X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO09X" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp       := upper(hcm_util.get_string_t(json_obj,'codcomp'));
        p_dtestr        := to_date(hcm_util.get_string_t(json_obj,'dtestr'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(json_obj,'dteend'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสหน่วยงาน,วันที่เริ่มต้น,วันที่สิ้นสุด
        if (p_codcomp is null) or (p_dtestr is null) or (p_dteend is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสหน่วยงานที่ระบุต้องมีในตาราง TCENTER
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            fetch first 1 rows only;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;
        -- กรณีระบุวันที่สิ้นสุด น้อยกว่า วันที่เริ่มต้น
        if p_dteend < p_dtestr then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;
    end check_index;

    function get_value_from_lang (v_lang1 varchar2,v_lang2 varchar2,v_lang3 varchar2,v_lang4 varchar2,v_lang5 varchar2) return varchar2 as
    begin
        if global_v_lang = '101' then
                return v_lang1;
        elsif global_v_lang = '102' then
                return v_lang2;
        elsif global_v_lang = '103' then
                return v_lang3;
        elsif global_v_lang = '104' then
                return v_lang4;
        elsif global_v_lang = '105' then
                return v_lang5;
        else
                return v_lang1;
        end if;
    end get_value_from_lang;

    function gen_data_row (v_codcomp varchar2,v_dteeffec date,v_label_numseq number,v_old varchar2,v_new varchar2,v_dteupd date,v_coduser varchar2) return json_object_t as
        obj_data    json_object_t;
    begin
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('codcomp_desc',get_format_codcomp(v_codcomp));
        obj_data.put('center_name',get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
        obj_data.put('fldedit',get_label_name('HRCO09X',global_v_lang,v_label_numseq));
        obj_data.put('value_old',v_old);
        obj_data.put('value_new',v_new);
        obj_data.put('dteupd',to_char(v_dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',v_coduser);
        return obj_data;
    end gen_data_row;

    procedure gen_index(json_str_output out clob) as
        obj_row     json_object_t;
        obj_data    json_object_t;
        v_row       number :=0;
        cursor c1 is
            select * from tcenterlog
            where
                codcomp like p_codcomp||'%' and
                dteeffec between p_dtestr and p_dteend
            order by codcomp,dteeffec desc;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            -- รหัสหน่วยงาน check secur_main.secur7
            if secur_main.secur7(i.codcomp,global_v_coduser) = true then
                -- ชื่อหน่วยงาน
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        910,
                        get_value_from_lang(i.namcentoe,i.namcentot,i.namcento3,i.namcento4,i.namcento5),
                        get_value_from_lang(i.namcente,i.namcentt,i.namcent3,i.namcent4,i.namcent5),
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
                -- ตำแหน่งผู้รับผิดชอบ
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        920,
                        get_tpostn_name(i.codposro,global_v_lang),
                        get_tpostn_name(i.codposr,global_v_lang),
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
                -- ชื่อย่อ
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        930,
                        get_value_from_lang(i.naminitoe,i.naminitot,i.naminito3,i.naminito4,i.naminito5),
                        get_value_from_lang(i.naminite,i.naminitt,i.naminit3,i.naminit4,i.naminit5),
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
                -- รหัส Cost Center
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        940,
                        i.costcento,
                        i.costcent,
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
                -- รหัสกลุ่มบริษัท
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        950,
                        get_tcodec_name('TCOMPGRP',i.compgrpo,global_v_lang),
                        get_tcodec_name('TCOMPGRP',i.compgrp,global_v_lang),
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
                -- สถานะ
                v_row       := v_row + 1;
                obj_row.put(
                    to_char(v_row-1),
                    gen_data_row(
                        i.codcomp,
                        i.dteeffec,
                        960,
                        get_tlistval_name('STATCENTER',i.flgacto,global_v_lang),
                        get_tlistval_name('STATCENTER',i.flgact,global_v_lang),
                        nvl(i.dteupd,i.dtecreate),
                        nvl(i.coduser,i.codcreate)
                    )
                );
            end if;
        end loop;
        if obj_row.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcenterlog');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        else
            json_str_output := obj_row.to_clob;
        end if;
    end gen_index;

    procedure get_index (json_str_input in clob, json_str_output out clob) as
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

end hrco09x;

/
