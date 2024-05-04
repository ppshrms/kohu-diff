--------------------------------------------------------
--  DDL for Package Body HRTR44X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR44X" AS
  procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        p_dteyear     := hcm_util.get_string(json_obj,'p_dteyear');
        p_codcompy   := upper(hcm_util.get_string(json_obj,'p_codcompy'));
        p_codcours   := upper(hcm_util.get_string(json_obj,'p_codcours'));

  end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_dteyear is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcompy||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
    cursor c1 is
        select dteyear,codcompy,codcate,codcours,plancond,qtyptpln,codtparg,qtyptbdg,amtclbdg
        from tyrtrpln
        where dteyear = p_dteyear
        and codcompy = p_codcompy
        and staappr = 'Y'
        order by codcate,codcours;

    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('dteyear',i.dteyear);
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('codcate',i.codcate);
            obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            obj_data.put('codcours',i.codcours);
            obj_data.put('desc_codcurs',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('plancond',get_tlistval_name('STACOURS',i.plancond,global_v_lang));
            obj_data.put('qtyptpln',i.qtyptpln);
            obj_data.put('codtparg',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
            obj_data.put('qtyptbdg',i.qtyptbdg);
            obj_data.put('amtclbdg',i.amtclbdg);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if obj_rows.count() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRPLN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure gen_info(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_data    json;
        obj_head    json;
    begin
        obj_head := json();
        obj_head.put('rows',std_tyrtrpln(p_codcompy,p_dteyear,p_codcours,global_v_lang));
        obj_result := json();
        obj_result.put('0',obj_head);
        dbms_lob.createtemporary(json_str_output, true);
        obj_result.to_clob(json_str_output);
    end gen_info;

    procedure get_info(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_info(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_info;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_detail as
        v_temp varchar2(1 char);
    begin
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_row_secur number := 0;
    cursor c1 is
        select a.codempid,b.codcomp,b.codpos,a.stacours,a.remark
        from ttpotent a,temploy1 b
        where a.dteyear = p_dteyear
        and a.codempid = b.codempid
        and codcompy = p_codcompy
        and a.codcours = p_codcours
        order by a.codempid;

    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
         if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
            v_row_secur := v_row_secur+1;
            obj_data := json();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('des_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('des_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('stacours',get_tlistval_name('STACOURS',i.stacours,global_v_lang));
            obj_data.put('remark',i.remark);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
        end loop;
        if  v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpotent');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        if ( v_row > 0 ) and ( v_row_secur = 0 ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

END HRTR44X;

/
