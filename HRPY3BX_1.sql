--------------------------------------------------------
--  DDL for Package Body HRPY3BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY3BX" as

    procedure initial_value(json_str_input in clob) is
        json_obj   json_object_t := json_object_t(json_str_input);
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcompy        := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_apcode          := hcm_util.get_string_t(json_obj,'p_apcode');
        p_dtestr          := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
        p_dteend          := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับการใส่ข้อมูล Alert HR2045
        if p_dtestr is null or p_dteend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสบริษัท ต้องมีข้อมูลในตาราง TCOMPNY (HR2010)
        if p_codcompy is not null then
            begin
                select 'X' into v_temp from tcompny where codcompy = p_codcompy;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                return;
            end;
        end if;

        -- รหัสกลุ่มบัญชี GL ต้องมีข้อมูลในตาราง TCODGRPGL (HR2010)
        if p_apcode is not null then
            begin
                select 'X' into v_temp from tcodgrpgl where codcodec = p_apcode;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODGRPGL');
                return;
            end;
        end if;

        -- วันที่แก้ไขตั้งแต่ ถ้า > วันที่แก้ไขถึง แจ้งเตือน (HR2021)
        if p_dtestr > p_dteend then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        -- รหัสบริษัทให้ Check Security โดยใช้ secur_main.secur7
        if p_codcompy is not null then
            if secur_main.secur7(p_codcompy,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    procedure get_fldedit_name(p_fldedit in varchar2,p_descold in varchar2,p_descnew in varchar2, v_fldname out varchar2,v_descold out varchar2,v_descnew out varchar2) as
        --<<nut 
        v_seqdescold number;
        v_seqdescnew number;
        -->>nut 
    begin
        if p_fldedit = 'APCODE' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,110);
            v_descold := p_descold||' - '||get_tcodec_name('TCODGRPGL',p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_tcodec_name('TCODGRPGL',p_descnew,global_v_lang);
        elsif p_fldedit = 'TYPPAYMT' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,120);
            --<<User37 Final Test Phase 1 V11 #2859 17/11/2020  
            /*v_descold := p_descold||' - '||get_tlistval_name('TYPPAYMT',p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_tlistval_name('TYPPAYMT',p_descnew,global_v_lang);*/
            v_seqdescold := null;
            v_seqdescnew := null;
            if p_descold = 'BK' then
                v_seqdescold := 40;
            elsif p_descold = 'CS' then
                v_seqdescold := 50;
            elsif p_descold = 'ALL' then
                v_seqdescold := 60;
            end if;
            if p_descnew = 'BK' then
                v_seqdescnew := 40;
            elsif p_descnew = 'CS' then
                v_seqdescnew := 50;
            elsif p_descnew = 'ALL' then
                v_seqdescnew := 60;
            end if;
            v_descold := p_descold||' - '||get_label_name('HRPY32E',global_v_lang,v_seqdescold);
            v_descnew := p_descnew||' - '||get_label_name('HRPY32E',global_v_lang,v_seqdescnew);
            -->>User37 Final Test Phase 1 V11 #2859 17/11/2020   
        elsif p_fldedit = 'APGRPCOD' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,130);
            v_descold := p_descold||' - '||get_tcodec_name('TCODGRPAP',p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_tcodec_name('TCODGRPAP',p_descnew,global_v_lang);
        elsif p_fldedit = 'CODACCDR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,140);
            v_descold := p_descold||' - '||get_taccodb_name('TACCODB',p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_taccodb_name('TACCODB',p_descnew,global_v_lang);
        elsif p_fldedit = 'SCODACCDR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,150);
            v_descold := p_descold;
            v_descnew := p_descnew;
        elsif p_fldedit = 'FLGPOSTDR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,160);
            if p_descold = 'Y' then
                v_descold := p_descold||' - '||get_label_name('HRPY3BX',global_v_lang,240);
            elsif p_descold = 'N' then
                v_descold := p_descold||' - '||get_label_name('HRPY3BX',global_v_lang,250);
            end if;
            if p_descnew = 'Y' then
                v_descnew := p_descnew||' - '||get_label_name('HRPY3BX',global_v_lang,240);
            elsif p_descnew = 'N' then
                v_descnew := p_descnew||' - '||get_label_name('HRPY3BX',global_v_lang,250);
            end if;
        elsif p_fldedit = 'COSTCENTDR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,170);
            v_descold := p_descold;
            v_descnew := p_descnew;
        elsif p_fldedit = 'CODACCCR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,180);
            v_descold := p_descold||' - '||get_taccodb_name('TACCODB',p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_taccodb_name('TACCODB',p_descnew,global_v_lang);
        elsif p_fldedit = 'SCODACCCR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,190);
            v_descold := p_descold;
            v_descnew := p_descnew;
        elsif p_fldedit = 'FLGPOSTCR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,200);
            if p_descold = 'Y' then
                v_descold := p_descold||' - '||get_label_name('HRPY3BX',global_v_lang,240);
            elsif p_descold = 'N' then
                v_descold := p_descold||' - '||get_label_name('HRPY3BX',global_v_lang,250);
            end if;
            if p_descnew = 'Y' then
                v_descnew := p_descnew||' - '||get_label_name('HRPY3BX',global_v_lang,240);
            elsif p_descnew = 'N' then
                v_descnew := p_descnew||' - '||get_label_name('HRPY3BX',global_v_lang,250);
            end if;
        elsif p_fldedit = 'COSTCENTCR' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,210);
            v_descold := p_descold;
            v_descnew := p_descnew;
        elsif p_fldedit = 'CODPAY' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,220);
            v_descold := p_descold||' - '||get_tinexinf_name(p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_tinexinf_name(p_descnew,global_v_lang);
        elsif p_fldedit = 'CODCOMPY' then
            v_fldname := get_label_name('HRPY3BX',global_v_lang,260);
            v_descold := p_descold||' - '||get_tcompny_name(p_descold,global_v_lang);
            v_descnew := p_descnew||' - '||get_tcompny_name(p_descnew,global_v_lang);
        else
            v_fldname := null;
        end if;
        if v_descold is null then
            v_descold := null;
        elsif p_descnew is null then
            v_descnew := null;
        end if;
    end get_fldedit_name;

    procedure gen_data(json_str_output out clob) as
        v_row       number := 0;
        rec_tlogap  tlogap%rowtype;
        obj_rows    json_object_t := json_object_t();
        obj_data    json_object_t;
        v_fldname   varchar2(150 char);
        v_descold   varchar2(150 char);
        v_descnew   varchar2(150 char);

        cursor c1 is
            select codcompy,dteupd,apcode,apgrpcod,numseq,fldedit,descold,descnew,coduser,rowid
            from tlogap
            where codcompy = nvl(p_codcompy,codcompy)
                and apcode = nvl(p_apcode,apcode)
                and trunc(dteupd) between p_dtestr and p_dteend
            order by codcompy,dteupd,numseq;
    begin
        for i in c1 loop
            v_row := v_row + 1;
            get_fldedit_name(i.fldedit,i.descold,i.descnew,v_fldname,v_descold,v_descnew);
            obj_data := json_object_t();
            obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
            obj_data.put('timeupd',to_char(i.dteupd,'hh24:mi:ss'));
            obj_data.put('coduser',get_temploy_name(get_codempid(i.coduser),global_v_lang));
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('namcompy',get_tcompny_name(i.codcompy,global_v_lang));
            obj_data.put('apcode',i.apcode);
            obj_data.put('namapcode',get_tcodec_name('TCODGRPGL',i.apcode,global_v_lang));
            obj_data.put('apgrpcod',i.apgrpcod);
            if trim(i.apgrpcod) <> '-' then
                obj_data.put('namapgrpcod',get_tcodec_name('TCODGRPAP',i.apgrpcod,global_v_lang)||i.apgrpcod);
            end if;
            obj_data.put('fldedit',v_fldname);
            obj_data.put('descold',v_descold);
            obj_data.put('descnew',v_descnew);
            obj_rows.put(to_char(v_row - 1),obj_data);
        end loop;
        -- กรณีไม่พบข้อมูล
        if obj_rows.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOGAP');
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

end HRPY3BX;

/
