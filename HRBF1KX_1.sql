--------------------------------------------------------
--  DDL for Package Body HRBF1KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1KX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp               := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_typpayroll            := hcm_util.get_string(json_obj,'typpayroll');
        p_periodpay_period      := to_number(hcm_util.get_string(json_obj,'periodpay_period'));
        p_periodpay_month       := to_number(hcm_util.get_string(json_obj,'periodpay_month'));
        p_periodpay_year        := to_number(hcm_util.get_string(json_obj,'periodpay_year'));

    end initial_value;

    procedure check_index as
        v_temp          varchar2( 1 char );
    begin

        if p_codcomp is null or p_typpayroll is null or p_periodpay_period is null or p_periodpay_month is null
          or p_periodpay_year is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from TCODTYPY
            where codcodec = p_typpayroll;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
            return;
        end;

        if p_codcomp is not null then
            -- check HR3007 HR2010
            param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;
    end check_index;

    procedure gen_index_type_1(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;

        v_row_secur     number := 0;
        v_count         number := 0;

        cursor c1 is
            select codcomp,codempid,dtemthpay,dteyrepay,numperiod, nvl(amtpaye,0) +nvl( amtpayf,0) amtpay
            from TCLNSUM
            where codcomp like p_codcomp||'%'
            and typpayroll = p_typpayroll
            and dteyrepay = p_periodpay_year
            and dtemthpay = p_periodpay_month
            and numperiod = p_periodpay_period
            and nvl(amtpaye,0) + nvl( amtpayf,0) > 0
            order by codcomp, codempid asc;

    begin

        obj_head := json();

        for j in c1 loop
            v_count     := v_count + 1;
            if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur := v_row_secur+1;
                obj_rows := json();
                obj_rows.put('codcomp',j.codcomp);
                obj_rows.put('codcomp_desc',get_tcenter_name(j.codcomp,global_v_lang));
                obj_rows.put('numperiod',j.numperiod);
                obj_rows.put('dtemthpay',j.dtemthpay);
                obj_rows.put('dteyrepay',j.dteyrepay);
                obj_rows.put('image',get_emp_img(j.codempid));
                obj_rows.put('codempid',j.codempid);
                obj_rows.put('codempid_desc',get_temploy_name(j.codempid,global_v_lang));
                obj_rows.put('amtpay',j.amtpay);
                obj_head.put(to_char(v_row_secur-1),obj_rows);
            end if;
        end loop;

        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSUM');
        end if;
        if v_count > 0 and v_row_secur = 0  then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_index_type_1;

    procedure gen_index_type_2(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;

        v_row_secur     number := 0;
        v_count         number := 0;

        cursor c1 is
            select codcomp,numperiod,dtemthpay,dteyrepay,codempid,amtrepay,numprdpay
            from TCLNSUM
            where codcomp like p_codcomp||'%'
            and typpayroll = p_typpayroll
            and dteyrepay = p_periodpay_year
            and dtemthpay = p_periodpay_month
            and numperiod = p_periodpay_period
            and amtrepay > 0
            order by codcomp, codempid asc;
    begin

        obj_head := json();

        for j in c1 loop
            v_count     := v_count + 1;
            if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur := v_row_secur+1;
                obj_rows := json();
                obj_rows.put('codcomp',j.codcomp);
                obj_rows.put('codcomp_desc',get_tcenter_name(j.codcomp,global_v_lang));
                obj_rows.put('numperiod',j.numperiod);
                obj_rows.put('dtemthpay',j.dtemthpay);
                obj_rows.put('dteyrepay',j.dteyrepay);
                obj_rows.put('image',get_emp_img(j.codempid));
                obj_rows.put('codempid',j.codempid);
                obj_rows.put('codempid_desc',get_temploy_name(j.codempid,global_v_lang));
                obj_rows.put('numprdpay',j.numprdpay);
                obj_rows.put('amtrepay',j.amtrepay);
                obj_head.put(to_char(v_row_secur-1),obj_rows);
            end if;
        end loop;

        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSUM');
        end if;
        if v_count > 0 and v_row_secur = 0  then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_index_type_2;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index_type_1(json_str_output);
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

    procedure get_index2(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index_type_2(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index2;
END HRBF1KX;

/
