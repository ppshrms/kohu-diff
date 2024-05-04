--------------------------------------------------------
--  DDL for Package Body HRCO28X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO28X" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_dtestr        := to_date(hcm_util.get_string_t(json_obj,'dtestr'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(json_obj,'dteend'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
    begin
        -- บังคับใส่ข้อมูล วันที่ตั้งแต่,สิ้นสุด
        if p_dtestr is null or p_dteend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- วันเริ่มต้นห้ามมากกว่าวันสิ้นสุด
        if p_dtestr > p_dteend then
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

    procedure gen_index(json_str_output out clob) as
        obj_result  json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c_tpostnlog is
            select * from tpostnlog
            where trunc(dtechg) between p_dtestr and p_dteend
            order by codpos,dtechg;
    begin
        obj_result  := json_object_t();
        for r1 in c_tpostnlog loop
            v_row   := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('desc_coderror',' ');
            obj_data.put('codpos',r1.codpos);
            obj_data.put('namposo',get_value_from_lang(r1.namposoe,r1.namposot,r1.namposo3,r1.namposo4,r1.namposo5));
            obj_data.put('nampos',get_value_from_lang(r1.nampose,r1.nampost,r1.nampos3,r1.nampos4,r1.nampos5));
            obj_data.put('namabbo',get_value_from_lang(r1.namabboe,r1.namabbot,r1.namabbo3,r1.namabbo4,r1.namabbo5));
            obj_data.put('namabb',get_value_from_lang(r1.namabbe,r1.namabbt,r1.namabb3,r1.namabb4,r1.namabb5));
            obj_data.put('dtechg',to_char(r1.dtechg,'dd/mm/yyyy hh24:mi:ss'));
            obj_data.put('coduser',r1.coduser);
            obj_result.put(to_char(v_row - 1),obj_data);
        end loop;

        -- กรณีไม่พบข้อมูล
        if obj_result.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpostnlog');
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

end hrco28x;

/
