--------------------------------------------------------
--  DDL for Package Body HRCO1DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO1DX" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp         := upper(hcm_util.get_string_t(json_obj,'codcomp'));

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- บังคับใส่ข้อมูล หน่วยงาน
        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
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

    function get_jobgroup_name(v_jobgroup varchar2) return varchar2 as
        tcodjobgrp_rec  tcodjobgrp%rowtype;
    begin
        begin
            select * into tcodjobgrp_rec
            from tcodjobgrp
            where jobgroup = v_jobgroup;
        exception when no_data_found then
            return '';
        end;

        if  global_v_lang = '101' then
            return tcodjobgrp_rec.namjobgrpe;
        elsif global_v_lang = '102' then
            return tcodjobgrp_rec.namjobgrpt;
        elsif global_v_lang = '103' then
            return tcodjobgrp_rec.namjobgrp3;
        elsif global_v_lang = '104' then
            return tcodjobgrp_rec.namjobgrp4;
        elsif global_v_lang = '105' then
            return tcodjobgrp_rec.namjobgrp5;
        else
            return tcodjobgrp_rec.namjobgrpe;
        end if;
    end get_jobgroup_name;

    procedure gen_index(json_str_output out clob) as
        obj_result  json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c_tjobpos is
            select codcomp,codpos,codjob,jobgrade,jobgroup
            from tjobpos
            where codcomp like p_codcomp||'%'
            order by codcomp,codpos;
    begin
        obj_result := json_object_t();
        for r1 in c_tjobpos loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('codcomp',get_format_codcomp(r1.codcomp));
            obj_data.put('namcomp',get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('codpos',r1.codpos);
            obj_data.put('nampos',get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('codjob',r1.codjob);
            obj_data.put('namcodjob',get_tjobcode_name(r1.codjob,global_v_lang));
            obj_data.put('jobgrade',r1.jobgrade);
            obj_data.put('namjobgrade',get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang));
            obj_data.put('jobgroup',r1.jobgroup);
            obj_data.put('namjobgroup',get_jobgroup_name(r1.jobgroup));
            obj_result.put(to_char(v_row - 1),obj_data);
        end loop;

        -- กรณีไม่พบข้อมูล
        if obj_result.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tjobpos');
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

end hrco1dx;

/
