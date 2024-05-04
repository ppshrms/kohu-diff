--------------------------------------------------------
--  DDL for Package Body HRPY2CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2CX" as

    -- Update 13/08/2019 10:51
    -- Update 26/11/2020 11:15

    procedure initial_value(json_str_input in clob) is
        json_obj   json_object_t := json_object_t(json_str_input);
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_dtemthpay       := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
        p_dteyrepay       := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
        p_numperiod       := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
        p_codempid        := hcm_util.get_string_t(json_obj,'codempid');
        p_codcomp         := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_codpay          := upper(hcm_util.get_string_t(json_obj,'p_codpay'));
        p_dtestr          := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
        p_dteend          := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับการใส่ข้อมูล Alert HR2045
        if p_dtemthpay is null or p_dteyrepay is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสพนักงาน ต้องมีข้อมูลในตาราง TEMPLOY1 (HR2010)
        if p_codempid is not null then
            begin
                select 'X' into v_temp
                 from temploy1
                where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
        end if;
        -- รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER (HR2010)
        if p_codcomp is not null then
            begin
                select 'X' into v_temp
                from tcenter
                where codcomp like p_codcomp||'%'
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;
        end if;
        -- รหัสรายได้/ส่วนหัก ต้องมีข้อมูลในตาราง TINEXINF (HR2010)
        if p_codpay is not null then
            begin
                select 'X' into v_temp
                 from tinexinf
                where codpay = p_codpay;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINEXINF');
                return;
            end;
        end if;
        -- หากระบุรหัสหน่วยงานรหัสได้/ส่วหัก ต้องมีข้อมูลในตาราง TINEXINFC (HR2010)
        if p_codcomp is not null and p_codpay is not null then
            begin
                select 'X' into v_temp
                from tinexinfc
                where codpay = p_codpay
                and p_codcomp like codcompy||'%';
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINEXINFC');
                return;
            end;
        end if;
        -- วันที่แก้ไขตั้งแต่ หรือ วันที่แก้ไขถึง ต้องระบุทั้งคู่ ระบุอย่างใดอย่างหนึ่งไม่ได้
        if p_dtestr is not null or p_dteend is not null then
            if p_dteend is null or p_dtestr is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end if;
        -- วันที่แก้ไขตั้งแต่ ถ้า > วันที่แก้ไขถึง แจ้งเตือน (HR2021)
        if p_dtestr > p_dteend then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
        if p_codempid is not null then
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
        if p_codcomp is not null then
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    procedure gen_data(json_str_output out clob) as
        v_secur         boolean := false;
        v_codempid      tcostemp.codempid%type;
        obj_data        json_object_t;
        obj_rows        json_object_t;
        v_row           number := 0;
        v_found         varchar2(1 char) := 'N';
        v_typeincome    varchar2(150 char);
        v_fldname       varchar2(150 char);
        v_desold        varchar2(150 char);
        v_desnew        varchar2(150 char);
        cursor c1 is
            select dteupd,numseq,codcomp,codempid,dteyrepay,dtemthpay,numperiod,'2' as typincome,codpay,desfld,desold,desnew,dtepay,rowid
            from tlogothpay
            where numperiod = nvl(p_numperiod,numperiod)
            and dtemthpay = p_dtemthpay
            and dteyrepay = p_dteyrepay
            and codempid = nvl(p_codempid,codempid)
            and nvl(codcomp,'%') like p_codcomp||'%'
            and codpay = nvl(p_codpay,codpay)
            and trunc(dteupd) between nvl(p_dtestr,trunc(dteupd))
                and nvl(p_dteend,trunc(dteupd))
            union
            select dteupd,numseq,codcomp,codempid,dteyrepay,dtemthpay,numperiod,'1' as typincome,codpay,desfld,desold,desnew,null,rowid
            from tlogothinc
            where numperiod = nvl(p_numperiod,numperiod)
            and dtemthpay = p_dtemthpay
            and dteyrepay = p_dteyrepay
            and codempid = nvl(p_codempid,codempid)
            and nvl(codcomp,'%') like p_codcomp||'%'
            and codpay = nvl(p_codpay,codpay)
            and trunc(dteupd) between nvl(p_dtestr,trunc(dteupd))
                and nvl(p_dteend,trunc(dteupd))
            order by dteupd,numseq,codcomp,codempid,dteyrepay,numperiod,codpay,dtepay;
    begin
        obj_rows    := json_object_t();
        for i in c1 loop
            v_found   := 'Y';
            v_desold  := '';
            v_desnew  := '';
            -- Check Security โดยใช้ secur_main.secur3
            v_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_secur = true then
                if i.typincome = '1' then
                    v_typeincome := get_label_name('HRPY2CX',global_v_lang,170);
                elsif i.typincome = '2' then
                    v_typeincome := get_label_name('HRPY2CX',global_v_lang,180);
                end if;
                if i.desfld = 'QTYPAYDA' then
                    v_fldname := get_label_name('HRPY28BC2',global_v_lang,40);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'QTYPAYHR' then
                    v_fldname := get_label_name('HRPY28BC2',global_v_lang,50);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'QTYPAYSC' then
                    v_fldname := get_label_name('HRPY28BC2',global_v_lang,60);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'AMTPAY' then
                    v_fldname := get_label_name('HRPY22EC1',global_v_lang,80);
                    if v_zupdsal = 'Y' then
                        v_desold  := to_char(nvl(stddec(i.desold,i.codempid,hcm_secur.get_v_chken),0),'fm999,990.00');
                        v_desnew  := to_char(nvl(stddec(i.desnew,i.codempid,hcm_secur.get_v_chken),0),'fm999,990.00');
                    end if;
                elsif i.desfld = 'FLGPYCTAX' then
                    v_fldname := get_label_name('HRPY28BC1',global_v_lang,60);
                    v_desold  := get_tlistval_name('TFLGPYCTAX',i.desold,global_v_lang);
                    v_desnew  := get_tlistval_name('TFLGPYCTAX',i.desnew,global_v_lang);
                elsif i.desfld = 'CODCOMP' then
                    v_fldname := get_label_name('HRPY22EC1',global_v_lang,120);
                    v_desold  := get_tcenter_name(i.desold,global_v_lang);
                    v_desnew  := get_tcenter_name(i.desnew,global_v_lang);
                elsif i.desfld = 'CODCOMPW' then
                    v_fldname := get_label_name('HRPY28BC2',global_v_lang,90);
                    v_desold  := get_tcenter_name(i.desold,global_v_lang);
                    v_desnew  := get_tcenter_name(i.desnew,global_v_lang);
                elsif i.desfld = 'CODEMPID' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,40);
                    v_desold  := get_temploy_name(i.desold,global_v_lang);
                    v_desnew  := get_temploy_name(i.desnew,global_v_lang);
                elsif i.desfld = 'CODPAY' then
                    v_fldname := get_label_name('HRPY23EP2',global_v_lang,20);
                    v_desold  := get_tinexinf_name(i.desold,global_v_lang);
                    v_desnew  := get_tinexinf_name(i.desnew,global_v_lang);
                elsif i.desfld = 'CODSYS' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,220);
                    v_desold  := get_tlistval_name('TCODSYS',i.desold,global_v_lang);
                    v_desnew  := get_tlistval_name('TCODSYS',i.desnew,global_v_lang);
                elsif i.desfld = 'COSTCENT' then
                    v_fldname := get_label_name('HRPY26XC1',global_v_lang,170);
                    v_desold  := get_tcoscent_name(i.desold,global_v_lang);
                    v_desnew  := get_tcoscent_name(i.desnew,global_v_lang);
                elsif i.desfld = 'DTEMTHPAY' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,230);
                    v_desold  := get_nammthful(i.desold,global_v_lang);
                    v_desnew  := get_nammthful(i.desnew,global_v_lang);
                elsif i.desfld = 'DTEPAY' then
                    v_fldname := get_label_name('HRPY55X',global_v_lang,100);
                    v_desold  := to_char(i.desold,'dd/mm/yyyy');
                    v_desnew  := to_char(i.desnew,'dd/mm/yyyy');
                elsif i.desfld = 'DTEYREPAY' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,240);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'NUMPERIOD' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,250);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'RATEPAY' then
                    v_fldname := get_label_name('HRPY2CX',global_v_lang,260);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'TYPEMP' then
                    v_fldname := get_label_name('HRPY5YX',global_v_lang,70);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                elsif i.desfld = 'TYPPAYROLL' then
                    v_fldname := get_label_name('HRPY22EC1',global_v_lang,130);
                    v_desold  := i.desold;
                    v_desnew  := i.desnew;
                else
                    v_fldname := nvl(i.desfld,'-');
                    v_desold  := nvl(i.desold,'-');
                    v_desnew  := nvl(i.desnew,'-');
                end if;

--                if i.desold is null then
--                    v_desold := null;
--                end if;
--                if i.desnew is null then
--                    v_desnew := null;
--                end if;
                if v_fldname is not null then
                    v_row    := v_row + 1;

                    obj_data := json_object_t();
                    obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy hh24:mi:ss'));
                    obj_data.put('image',get_emp_img(i.codempid));
                    obj_data.put('codempid',i.codempid);
                    obj_data.put('empname',get_temploy_name(i.codempid,global_v_lang));
                    if global_v_lang = 102 then
                        obj_data.put('dteperiod',to_char(i.numperiod)||'/'||get_tlistval_name('NAMMTHFUL',i.dtemthpay,global_v_lang)||'/'||to_char(i.dteyrepay+543));
                    else
                        obj_data.put('dteperiod',to_char(i.numperiod)||'/'||get_tlistval_name('NAMMTHFUL',i.dtemthpay,global_v_lang)||'/'||to_char(i.dteyrepay));
                    end if;
                    obj_data.put('typincome',v_typeincome);
                    obj_data.put('codpay',i.codpay);
                    obj_data.put('namcodpay',get_tinexinf_name(i.codpay,global_v_lang));
                    obj_data.put('fldname',v_fldname);
                    obj_data.put('desold',v_desold);
                    obj_data.put('desnew',v_desnew);
                    obj_rows.put(to_char(v_row - 1),obj_data);
                end if;
            end if;
        end loop;
        -- กรณีไม่พบข้อมูล
        if obj_rows.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOGOTHINC');
            if v_found = 'Y' then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            end if;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_rows.to_clob;
    end gen_data;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_data(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

end HRPY2CX;

/
