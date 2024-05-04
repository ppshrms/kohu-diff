--------------------------------------------------------
--  DDL for Package Body HRBF1RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1RX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_codempid        := upper(hcm_util.get_string(json_obj,'codempid'));

    end initial_value;

    procedure check_index as
        v_temp          varchar2( 1 char );
    begin

        if (p_codcomp is null and p_codempid is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codempid is not null then
            begin
                select 'X' into v_temp
                from temploy1
                where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
        if p_codcomp is not null then
            -- check HR3007
            param_msg_error :=  hcm_secur.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;
    end check_index;

    function format_display_dtestrpm(v_dtestrpm varchar2) return varchar2 is
        v_str       varchar2(100 char);
        v_display   varchar2(100 char);
    begin
        if v_dtestrpm is null then
            return '';
        end if;
        v_str := replace(v_dtestrpm,'/');
        v_display := substr(v_str, 7)||'/'||
                     substr(v_str, 5,2)||'/'||
                     substr(v_str, 1,4);
        return v_display;
    end format_display_dtestrpm;

    procedure gen_index(json_str_output out clob) as
        obj_head        json;
        obj_data        json;

        v_row_secur     number := 0;
        v_count         number := 0;

        cursor c1 is
            select e.codcomp, t.codempid, t.amttpay, t.qtyrepaym, t.amtrepaym, t.dtestrpm, t.qtypaid, t.amttotpay, t.amtoutstd
            from trepay t,temploy1 e
            where t.codempid = nvl(p_codempid, t.codempid)
            and e.codcomp like nvl(p_codcomp,e.codcomp)||'%'
            and t.codempid = e.codempid
            and ( nvl(flgclose,'N') = 'N' or amtoutstd > 0   )
            order by e.codcomp asc, t.codempid asc, t.amttpay asc, t.amttotpay asc, t.amtoutstd asc;

    begin

        obj_head := json();
        for j in c1 loop
            v_count     := v_count + 1;
            if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur := v_row_secur+1;
                obj_data := json();
                obj_data.put('codcomp',j.codcomp);
                obj_data.put('codcomp_desc',get_tcenter_name(j.codcomp,global_v_lang));
                obj_data.put('image',get_emp_img(j.codempid));
                obj_data.put('codempid',j.codempid);
                obj_data.put('codempid_desc',get_temploy_name(j.codempid,global_v_lang));
                obj_data.put('amttpay',j.amttpay);
                obj_data.put('qtyrepaym',j.qtyrepaym);
                obj_data.put('amtrepaym',j.amtrepaym);
                obj_data.put('dtestrpm', format_display_dtestrpm(j.dtestrpm));
                obj_data.put('qtypaid', j.qtypaid);
                obj_data.put('amttotpay',j.amttotpay);
                obj_data.put('amtoutstd',j.amtoutstd);
                obj_head.put(v_row_secur-1,obj_data);
            end if;
        end loop;
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREPAY');
        end if;
        if v_count > 0 and v_row_secur = 0  then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        dbms_lob.createtemporary(json_str_output, true);

        obj_head.to_clob(json_str_output);
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

END HRBF1RX;

/
