--------------------------------------------------------
--  DDL for Package Body HRTR68X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR68X" AS
    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        p_codcompy         := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_year             := to_number(hcm_util.get_string(json_obj,'year'));
        p_codcours         := upper(hcm_util.get_string(json_obj,'codcours'));
        p_numclseq         := hcm_util.get_string(json_obj,'numgen');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_year is null or p_codcours is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp 
            from tcompny 
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompany');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp 
            from tcourse 
            where codcours like p_codcours
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
            return;
        end;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_data    json;
        obj_head    json;
        v_row       number := 0;
        v_row_secur number := 0;
        v_dtesubjd_desc varchar2(50 char);
        cursor c1 is
            select a.dteyear,a.codcompy,a.numclseq,a.codcours,a.codempid,a.codcomp,a.codpos,a.numlvl
            from TPOTENTP a          
            where a.dteyear = p_year
            and a.codcompy = p_codcompy
            and a.codcours = p_codcours
            and a.numclseq = p_numclseq
            and a.staappr = 'Y'
            and exists (select b.codempid from tpotentpd b
                            where b.dteyear = a.dteyear
                            and b.codcompy = a.codcompy
                            and b.numclseq = a.numclseq
                            and b.codcours = a.codcours
                            and b.codempid = a.codempid
                            and b.flgatend = 'Y')
            order by codcomp,codpos,codempid;
    begin

        v_dtesubjd_desc := get_dtesubjd_desc(p_year, p_codcompy, p_codcours, p_numclseq);
        obj_rows := json();
        obj_head := json();
        for i in c1 loop
                v_row := v_row+1;
                if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
                    v_row_secur := v_row_secur+1;
                	obj_data := json();
                	obj_data.put('dteyear',i.dteyear);
                	obj_data.put('codcompy',i.codcompy);
                	obj_data.put('numclseq',i.numclseq);
                	obj_data.put('codcours',i.codcours);
                	obj_data.put('codempid',i.codempid);
                	obj_data.put('employee_name',get_temploy_name(i.codempid,global_v_lang));
                	obj_data.put('codcomp',i.codcomp);
                	obj_data.put('agency',get_tcenter_name(i.codcomp,global_v_lang));
                	obj_data.put('codpos',i.codpos);
                	obj_data.put('position',get_tpostn_name(i.codpos,global_v_lang));
                	obj_data.put('numlvl',i.numlvl);
                    obj_data.put('image', get_emp_img(i.codempid));
                    obj_rows.put(to_char(v_row_secur-1),obj_data);
                end if;
        end loop;
        if v_row = 0 then  
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPOTENTP');
            return;
        elsif v_row > 0 and v_row_secur = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;            
        end if;
            obj_result := json();
            obj_head.put('dtesubjd_desc',v_dtesubjd_desc);            
        obj_head.put('counts',v_row_secur);
            obj_head.put('codcours',p_codcours);
            obj_head.put('desc_codcours',p_codcours||' - '||get_tcourse_name(p_codcours,global_v_lang));
            obj_head.put('rows',obj_rows);
            obj_result.put('0',obj_head);            
            dbms_lob.createtemporary(json_str_output, true);
            obj_result.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then 
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace; 
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

END HRTR68X;

/
