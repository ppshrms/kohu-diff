--------------------------------------------------------
--  DDL for Package Body HRPY21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY21E" is

    procedure initial_value(json_str in clob) is
        json_obj   json_object_t := json_object_t(json_str);
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codpay          := hcm_util.get_string_t(json_obj,'codpay');
        p_descpaye        := hcm_util.get_string_t(json_obj,'descpaye');
        p_descpayt        := hcm_util.get_string_t(json_obj,'descpayt');
        p_descpay3        := hcm_util.get_string_t(json_obj,'descpay3');
        p_descpay4        := hcm_util.get_string_t(json_obj,'descpay4');
        p_descpay5        := hcm_util.get_string_t(json_obj,'descpay5');
        p_typpay          := hcm_util.get_string_t(json_obj,'typpay');
        p_flgtax          := hcm_util.get_string_t(json_obj,'flgtax');
--<< user20 Date: 11/09/2021  #6880        p_flgfml          := hcm_util.get_string_t(json_obj,'flgfml');
        p_flgfml          := substr(hcm_util.get_string_t(json_obj,'flgfml') , 1 , 1);
--<< user20 Date: 11/09/2021  #6880
        p_formula         := hcm_util.get_string_t(json_obj,'formula');
        p_flgcal          := nvl(hcm_util.get_string_t(json_obj,'flgcal'),'N');
        p_flgform         := nvl(hcm_util.get_string_t(json_obj,'flgform'),'N');
        p_flgwork         := nvl(hcm_util.get_string_t(json_obj,'flgwork'),'N');
        p_flgsoc          := nvl(hcm_util.get_string_t(json_obj,'flgsoc'),'N');
        p_flgpvdf         := nvl(hcm_util.get_string_t(json_obj,'flgpvdf'),'N');
        p_typinc          := hcm_util.get_string_t(json_obj,'typinc');
        p_typpayr         := hcm_util.get_string_t(json_obj,'typpayr');
        p_typpayt         := hcm_util.get_string_t(json_obj,'typpayt');
        p_codtax          := hcm_util.get_string_t(json_obj,'codtax');
        p_dteeffec        := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');
        p_amtmin          := to_number(hcm_util.get_string_t(json_obj,'amtmin'));
        p_amtmax          := to_number(hcm_util.get_string_t(json_obj,'amtmax'));
        p_taxpayr         := hcm_util.get_string_t(json_obj,'taxpayr');
        p_typincpnd       := hcm_util.get_string_t(json_obj,'typincpnd');
        p_typincpnd50     := hcm_util.get_string_t(json_obj,'typincpnd50');
        p_desctaxe        := hcm_util.get_string_t(json_obj,'desctaxe');
        p_desctaxt        := hcm_util.get_string_t(json_obj,'desctaxt');
        p_desctax3        := hcm_util.get_string_t(json_obj,'desctax3');
        p_desctax4        := hcm_util.get_string_t(json_obj,'desctax4');
        p_desctax5        := hcm_util.get_string_t(json_obj,'desctax5');
    end initial_value;

    procedure check_index is
        v_code    varchar2(100);
    begin
        if p_dteeffec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        --สูตรคำนวณ
        if p_formula is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_formula like '%'||p_codpay||'%' then
            param_msg_error := get_error_msg_php('PY0026',global_v_lang);
            return;
        end if;

        if p_amtmin is not null then
            if p_amtmin > p_amtmax then
                param_msg_error := get_error_msg_php('HR2022',global_v_lang);
                return;
            end if;
        end if;
        --    p_amtmax          := to_number(hcm_util.get_string(json_obj,'amtmax'));
    end check_index;

    procedure check_validate is
        v_count          number := 0;
        v_tmp            varchar2(1);
--        v_codincom1			varchar2(2);
        v_codpaypy1			tcontrpy.codpaypy1%type;

    begin
        if p_codpay is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        --รายละเอียด รหัสค่าใช้จ่าย
        if global_v_lang = '101' then
            if p_descpaye is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        elsif global_v_lang = '102' then
            if p_descpayt is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        elsif global_v_lang = '103' then
            if p_descpay3 is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        elsif global_v_lang = '104' then
            if p_descpay4 is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        elsif global_v_lang = '105' then
            if p_descpay5 is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        end if;


        --ประเภทรหัส
        if p_typpay is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        --ชนิดของภาษี
        if p_flgtax is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        --การปัดเศษ
        if p_flgfml is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        --    -- กรณีระบุ ใช้สูตร สูตรคานวณบังคับระบุ (HR2045)
        --    if p_flgform = 'Y' then
        --        if p_formula = '' or p_formula = null then
        --            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'formula');
        --        end if;
        --    end if;

        -- กรณีคำนวณภาษีต้องมีการบันทึก รหัสพิมพ์ ภงด.1 และหนังสือรับรอง
        if p_flgcal = 'Y' then
            if p_typinc is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
            if p_typpayt is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        end if;

        if p_typinc is not null then
            begin
                select 'X' into v_tmp
                from tcodrevn
                where codcodec = p_typinc;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            end;
        end if;

        if p_typpayr is not null then
            begin
                select 'X'
                into v_tmp
                from tcodslip
                where codcodec = p_typpayr;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            end;
        end if;

        if p_typpayt is not null then
            begin
                select 'X' into v_tmp
                from tcodcert
                where codcodec = p_typpayt;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            end;
        end if;

--<< user20 Date: 17/09/2021 #6883
        if p_typpayt = p_typincpnd50 then
            param_msg_error := get_error_msg_php('PY0074',global_v_lang);
        end if;
--<< user20 Date: 17/09/2021 #6883

        -- ถ้าประเภทรายได้เป็นรายได้ประจำหรือการลงบัญชีไม่ให้มีการกำหนดรหัสภาษี
        if p_typpay not in ('2','3','4','5') then
            p_codtax  		 := null;
            p_taxpayr          := null;
            p_desctaxe         := null;
            p_desctaxt         := null;
            p_desctax3         := null;
            p_desctax4         := null;
            p_desctax5         := null;
            --p_desc_codtax  := null;
            --p_typinc       := null;
            --p_desc_typinc  := null;
            --p_typpayr      := null;
            --p_desc_typpayr := null;
            --p_typpayt      := null;
            --p_desc_typpayt := null;
        end if;

        if p_codtax is not null then
            begin
                select 'X'
                into v_tmp
                from tinexinf
                where
                    codpay = p_codtax and
                    typpay <> '6';
                param_msg_error := get_error_msg_php('PY0003',global_v_lang);
            exception when no_data_found then
                v_tmp  := null;
            end;

            begin
                select 'X' into v_tmp from tinexinf
                where
                    codpay = p_codtax;
                    desc_codtax := substr(get_tinexinf_name(p_codtax,global_v_lang),1,35);
            exception when no_data_found then
            v_tmp  := null;
            end;
        end if;

        if p_codtax is not null then
            begin
                select codpaypy1 into v_codpaypy1
                from tcontrpy
                where
                    dteeffec <= (
                        select max(dteeffec)
                        from tcontrpy
                        where dteeffec <= sysdate)
                    and rownum = 1;
            exception when no_data_found then
                v_codpaypy1 := null;
            end;

            if v_codpaypy1 = p_codtax then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
            end if;

            if p_codtax = p_codpay then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
            else

                begin
                    select count(*)
                      into v_count
                      from ttaxtab
                     where codpay <> p_codpay
                       and codtax = p_codtax;
                exception when no_data_found then
                    v_count := 0;
                end;

                if v_count > 0 then
                    param_msg_error := get_error_msg_php('PY0029',global_v_lang);
                end if;

                if p_codtax is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;

--                if p_taxpayr is null then
--                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--                end if;
            end if;

            if p_typinc is not null then
                begin
                    select 'X'
                      into v_tmp
                      from tcodrevn
                     where codcodec = p_typinc;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang);
                end;
            end if;

            if p_typpayr is not null then
                begin
                    select 'X'
                      into v_tmp
                      from tcodslip
                     where codcodec = p_typpayr;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang);
                end;
            end if;

            if p_typpayt is not null then
                begin
                    select 'X'
                      into v_tmp
                      from tcodcert
                     where codcodec = p_typpayt;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang);
                end;
            end if;
        end if;
    end;


    procedure get_formula(json_str_input in clob, json_str_output out clob) is
        obj_data    json_object_t;
        obj_row     json_object_t;
        v_formula   tformula.formula%type;
        v_amtmin	number := 0;
        v_amtmax	number := 0;
        v_dteeffec  date;
        --    v_warning   varchar2(150 char) := '';
    begin
        initial_value(json_str_input);
        if trunc(p_dteeffec) < trunc(sysdate) then
             param_msg_error := get_error_msg_php('PY0071',global_v_lang);
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;


        begin
            select formula, amtmin, amtmax, dteeffec
              into v_formula, v_amtmin, v_amtmax, v_dteeffec
              from tformula
             where codpay = p_codpay
               and dteeffec = p_dteeffec;
        --        if v_dteeffec < sysdate then
        --            v_warning := get_error_msg_php('HR1501','102');
        --        end if;
        exception when no_data_found then
            v_formula := '';
            v_amtmin := 0;
            v_amtmax := 0;
            v_dteeffec := '';
        end;
        obj_row := json_object_t();
        obj_data := json_object_t();
        obj_data.put('formula', v_formula);
        obj_data.put('formula_desc', v_formula);
        obj_data.put('amtmin', v_amtmin);
        obj_data.put('amtmax', v_amtmax);
        obj_data.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
        --    obj_data.put('warning',v_warning);
        obj_row.put('0',obj_data);
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        v_total     number;
        v_row		    number := 0;

        cursor c1 is
            select codpay, typpay, flgcal, flgpvdf, flgsoc, flgform
              from tinexinf
          order by codpay;
    begin
        initial_value(json_str_input);
        obj_row := json_object_t();

        for r1 in c1 loop
            v_row    := v_row+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codpay', r1.codpay);
            obj_data.put('descpay', get_tinexinf_name(r1.codpay,global_v_lang));
            obj_data.put('typpay', get_tlistval_name('TYPEINC',r1.typpay,global_v_lang));
            obj_data.put('flgcal', get_tlistval_name('TFLGCAL',r1.flgcal,global_v_lang));
            obj_data.put('flgpvdf', get_tlistval_name('TFLGCAL',r1.flgpvdf,global_v_lang));
            obj_data.put('flgsoc', get_tlistval_name('TFLGCAL',r1.flgsoc,global_v_lang));
            obj_data.put('flgform', get_tlistval_name('TFLGFORM',r1.flgform,global_v_lang));

            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;
    --
    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_total     number;
        v_row		number := 0;
        v_codpay    varchar2(4 char);
        v_descpaye  varchar2(150 char);
        v_descpayt  varchar2(150 char);
        v_descpay3  varchar2(150 char);
        v_descpay4  varchar2(150 char);
        v_descpay5  varchar2(150 char);
        v_typpay    varchar2(1 char);
        v_flgtax    varchar2(1 char);
        v_flgfml    varchar2(1 char);
        v_flgpvdf   varchar2(1 char);
        v_flgwork   varchar2(1 char);
        v_flgsoc    varchar2(1 char);
        v_flgcal    varchar2(1 char);
        v_flgform   varchar2(1 char);
        v_typinc    varchar2(4 char);
        v_typpayr   varchar2(4 char);
        v_typpayt   varchar2(4 char);
        v_formula   varchar2(50 char);
        v_amtmin	number := 0;
        v_amtmax	number := 0;
        v_dteeffec  date;
        v_codtax    varchar2(4 char);
        v_taxpayr   varchar2(4 char);
        v_typincpnd  varchar2(4 char);
        v_typincpnd50   tinexinf.typincpnd50%type;
        v_desctaxe   varchar2(150 char);
        v_desctaxt   varchar2(150 char);
        v_desctax3   varchar2(150 char);
        v_desctax4   varchar2(150 char);
        v_desctax5   varchar2(150 char);
        v_check_new varchar2(4 char);
        json_obj    json_object_t;
        param_json  json_object_t;
        cursor c_formula is
            select formula,amtmin,amtmax,dteeffec
            from tformula
            where
                codpay = p_codpay and
                dteeffec <= sysdate
            order by dteeffec desc;

    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');

        obj_row := json_object_t();
        if param_json.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        for i in 0..param_json.get_size-1 loop
            v_row := v_row + 1;
            p_codpay   := hcm_util.get_string_t(param_json,to_char(i));
            if p_codpay is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                exit;
            end if;
            --กรณีเป็นข้อมูลใหม่ที่ไม่เคยมีในฐานข้อมูล ให้ Default ค่าตั้งต้น (ประเภทรหัส = รายได้ประจา,ชนิดภาษี = หักภาษี ณ ที่จ่าย,เงื่อนไขการปัดเศษ = ทศนิยม 2 ตาแหน่ง)
            begin
                select codpay
                  into v_check_new
                  from tinexinf
                 where codpay = upper(p_codpay);
            exception when no_data_found then
                if param_json.get_size = 1 then
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('codpay', p_codpay);
                    obj_data.put('typpay', '1');
                    obj_data.put('flgtax', '1');
                    obj_data.put('flgfml', '4');

                    json_str_output := obj_data.to_clob;
                    return;
                else
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
                    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                    return;
                end if;
            end;
            begin
                select codpay, descpaye, descpayt, descpay3, descpay4,
                       descpay5, typpay, flgtax, flgfml, flgpvdf,
                       flgwork, flgsoc, flgcal, flgform, typinc,
                       typpayr, typpayt, typincpnd, typincpnd50, rownum
                  into v_codpay, v_descpaye, v_descpayt, v_descpay3, v_descpay4,
                       v_descpay5, v_typpay, v_flgtax, v_flgfml, v_flgpvdf,
                       v_flgwork, v_flgsoc, v_flgcal, v_flgform, v_typinc,
                       v_typpayr, v_typpayt, v_typincpnd, v_typincpnd50, v_total
                from tinexinf
                where codpay = p_codpay;
            exception when no_data_found then
                v_total := 0;
            end;
            -- สูตรคำนวน
            for r1 in c_formula loop
                v_formula  := r1.formula;
                v_amtmin   := r1.amtmin;
                v_amtmax   := r1.amtmax;
                v_dteeffec := r1.dteeffec;
                exit;
            end loop;

            -- ข้อมูลคู่ภาษี
            begin
                select codtax into v_codtax
                  from ttaxtab
                 where codpay = p_codpay;
            exception when no_data_found then
                v_codtax := '';
            end;

            begin
                select typpayr,descpaye,descpayt,descpay3,descpay4,descpay5
                  into v_taxpayr,v_desctaxe,v_desctaxt,v_desctax3,v_desctax4,v_desctax5
                  from tinexinf
                 where codpay = v_codtax;
            exception when no_data_found then
                v_taxpayr := '';
                v_desctaxe := '';
                v_desctaxt := '';
                v_desctax3 := '';
                v_desctax4 := '';
                v_desctax5 := '';
            end;
            if v_total > 0 then
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codpay', v_codpay);
                obj_data.put('descpaye', v_descpaye);
                obj_data.put('descpayt', v_descpayt);
                obj_data.put('descpay3', v_descpay3);
                obj_data.put('descpay4', v_descpay4);
                obj_data.put('descpay5', v_descpay5);
                obj_data.put('typpay', v_typpay);
                obj_data.put('flgtax', v_flgtax);
                obj_data.put('flgfml', v_flgfml);
                obj_data.put('flgpvdf', v_flgpvdf);
                obj_data.put('flgwork', v_flgwork);
                obj_data.put('flgsoc', v_flgsoc);
                obj_data.put('flgcal', v_flgcal);
                obj_data.put('flgform', v_flgform);
                obj_data.put('typinc', v_typinc);
                obj_data.put('typpayr', v_typpayr);
                obj_data.put('typpayt', v_typpayt);
                obj_data.put('typincpnd', v_typincpnd);
                obj_data.put('typincpnd50', v_typincpnd50);
                obj_data.put('formula', v_formula);
                obj_data.put('formula_desc', v_formula);
                obj_data.put('amtmin', v_amtmin);
                obj_data.put('amtmax', v_amtmax);
                obj_data.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
                obj_data.put('codtax', v_codtax);
                obj_data.put('taxpayr', v_taxpayr);
                obj_data.put('desctaxe', v_desctaxe);
                obj_data.put('desctaxt', v_desctaxt);
                obj_data.put('desctax3', v_desctax3);
                obj_data.put('desctax4', v_desctax4);
                obj_data.put('desctax5', v_desctax5);

                obj_row.put(to_char(v_row - 1),obj_data);
            else
                param_msg_error := get_error_msg_php('HR2055',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        end loop;
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;
    --

    procedure update_log(v_codpay varchar2,v_fldedit varchar2,v_descold varchar2,v_descnew varchar2) is
        v_numseq number := 0;
    begin
        select count(*) + 1 into v_numseq
        from tlogcodpay;

        insert into tlogcodpay ( dteupd, codpay, numseq, fldedit, descold, descnew, codcreate, coduser)
        values ( sysdate, v_codpay, v_numseq, v_fldedit, v_descold, v_descnew, global_v_coduser, global_v_coduser);
    end;

    procedure save_formula_2 is
        v_count        number;
        rec_tformula   tformula%rowtype;
    begin
        begin
            select count(*)
              into v_count
              from tformula
             where codpay = p_codpay;
        exception when others then
            v_count := 0;
        end;

        if v_count = 0 then
            begin
                insert into tformula( codpay, dteeffec, formula, amtmin, amtmax, dteupd, coduser, codcreate)
                values( p_codpay, p_dteeffec, p_formula, p_amtmin, p_amtmax, trunc(sysdate), global_v_coduser, global_v_coduser);
            end;
            -- log add
            update_log(p_codpay,'DTEEFFEC',null,to_char(p_dteeffec,'dd/mm/yyyy'));
            update_log(p_codpay,'FORMULA',null,p_formula);
            update_log(p_codpay,'AMTMIN',null,p_amtmin);
            update_log(p_codpay,'AMTMAX',null,p_amtmax);
        else
            -- log edit
            select * into rec_tformula from tformula where codpay = p_codpay;
            if rec_tformula.dteeffec != p_dteeffec then
                update_log(p_codpay,'DTEEFFEC',to_char(rec_tformula.dteeffec,'dd/mm/yyyy'),to_char(p_dteeffec,'dd/mm/yyyy'));
            end if;
            if rec_tformula.formula != p_formula then
                update_log(p_codpay,'FORMULA',rec_tformula.formula,p_formula);
            end if;
            if rec_tformula.amtmin != p_amtmin then
                update_log(p_codpay,'AMTMIN',rec_tformula.amtmin,p_amtmin);
            end if;
            if rec_tformula.amtmax != p_amtmax then
                update_log(p_codpay,'AMTMAX',rec_tformula.amtmax,p_amtmax);
            end if;
            begin
                update tformula
                   set dteeffec = p_dteeffec,
                       formula  = p_formula,
                       amtmin   = p_amtmin,
                       amtmax   = p_amtmax,
                       coduser  = global_v_coduser
                 where codpay = p_codpay;
            end;
        end if;
    end save_formula_2;

    procedure save_index(json_str_input in clob, json_str_output out clob) is
        v_count        number;
        v_codpay       varchar2(4 char);
        rec_tax        tinexinf%rowtype;
        rec_tinexinf   tinexinf%rowtype;
--<< user20 Date: 17/09/2021 #6883
        rec_tinexinf2  tinexinf%rowtype;
--<< user20 Date: 17/09/2021 #6883
        v_grppay       varchar2(1 char);
        v_check_new    varchar2(4 char);
        v_old_codtax   varchar2(10 char);
    begin
        initial_value(json_str_input);
        check_validate;
        --    -- เช็คสูตร
        --    if p_flgform = 'Y' then
        --        check_index;
        --    end if;
        if param_msg_error is null then
          -- คู่ภาษี
            if p_codtax is not null then
                -- เช็คตารางคู่ภาษี p_codtax
                begin
                    select count(*) into v_count
                    from ttaxtab
                    where codpay = p_codpay;
        --                 and codtax = p_codtax;
                exception when others then
                    v_count := 0;
                end;
                -- บันทึกลงตารางคู่ภาษี
                if v_count = 0 then
                    begin
                        insert into ttaxtab(codpay, codtax, dteupd, codcreate, coduser)
                        values(p_codpay, p_codtax, trunc(sysdate), global_v_coduser, global_v_coduser);
                    end;
                    update_log(p_codpay,'CODTAX',null,p_codtax);
                else
                    begin
                        select codtax into v_old_codtax
                        from ttaxtab
                        where codpay = p_codpay;
                    exception when no_data_found then
                        v_old_codtax := null;
                    end;
                    begin
                        update ttaxtab set
                            codtax = p_codtax,
                            dteupd = trunc(sysdate),
                            coduser = global_v_coduser
                         where codpay = p_codpay;
                    end;
                    update_log(p_codpay,'CODTAX',v_old_codtax,p_codtax);
                end if;
                -- เช็คว่าคู่ภาษีมีข้อมูลในตาราง รายได้/ส่วนหัก
                begin
                    select count(*) into v_count
                    from tinexinf
                    where codpay = p_codtax;
                exception when others then
                    v_count := 0;
                end;
                -- บันทึกรหัสภาษีลงในตาราง รายได้/ส่วนหัก

                if v_count = 0 then
                    begin
                        insert into tinexinf( codpay, descpaye, descpayt, descpay3, descpay4, descpay5,
                                              typpay, flgtax, flgpvdf, flgwork, flgsoc, flgcal, coduser,
                                              typinc, typpayr, typpayt, typincpnd, typincpnd50, flgform, grppay, flgfml, codcreate)
                        values( p_codtax, p_desctaxe, p_desctaxt, p_desctax3, p_desctax4, p_desctax5,
                                '6', '1', 'N', 'N', 'N' , 'N', global_v_coduser, p_typinc, p_taxpayr,
                                p_typpayt, p_typincpnd, p_typincpnd50, 'N', '2', '4', global_v_coduser);
                    end;
                    -- log add
                    update_log(p_codtax,'CODPAY',null,p_codtax);
                    if global_v_lang = '101' then
                        update_log(p_codtax,'DESCPAYE',null,p_desctaxe);
                    elsif  global_v_lang = '102' then
                        update_log(p_codtax,'DESCPAYT',null,p_desctaxt);
                    elsif  global_v_lang = '102' then
                        update_log(p_codtax,'DESCPAY3',null,p_desctax3);
                    elsif  global_v_lang = '102' then
                        update_log(p_codtax,'DESCPAY4',null,p_desctax4);
                    elsif  global_v_lang = '102' then
                        update_log(p_codtax,'DESCPAY5',null,p_desctax5);
                    end if;
                    update_log(p_codtax,'TYPPAY',null,'6');
                    update_log(p_codtax,'FLGTAX',null,'1');
                    update_log(p_codtax,'FLGFML',null,'4');
                    update_log(p_codtax,'FLGPVDF',null,'N');
                    update_log(p_codtax,'FLGWORK',null,'N');
                    update_log(p_codtax,'FLGSOC',null,'N');
                    update_log(p_codtax,'FLGCAL',null,'N');
                    update_log(p_codtax,'FLGFORM',null,'N');
                    update_log(p_codtax,'TYPINC',null,p_typinc);
                    update_log(p_codtax,'TYPPAYR',null,p_taxpayr);
                    update_log(p_codtax,'TYPPAYT',null,p_typpayt);
                    update_log(p_codtax,'TYPINCPND',null,p_typincpnd);
                    update_log(p_codtax,'GRPPAY',null,'2');
                else
                    -- log edit
                    select * into rec_tax from tinexinf where codpay = p_codtax;
                    if rec_tax.typpayr != p_taxpayr then
                        update_log(p_codtax,'TYPPAYR',rec_tax.typpayr,p_taxpayr);
                    end if;

                    if global_v_lang = '101' and rec_tax.descpaye != p_desctaxe then
                        update_log(p_codtax,'DESCPAYE',rec_tax.descpaye,p_desctaxe);
                    elsif  global_v_lang = '102' and rec_tax.descpayt != p_desctaxt then
                        update_log(p_codtax,'DESCPAYT',rec_tax.descpayt,p_desctaxt);
                    elsif  global_v_lang = '103' and rec_tax.descpay3 != p_desctax3 then
                        update_log(p_codtax,'DESCPAY3',rec_tax.descpay3,p_desctax3);
                    elsif  global_v_lang = '104' and rec_tax.descpay4 != p_desctax4 then
                        update_log(p_codtax,'DESCPAY4',rec_tax.descpay4,p_desctax4);
                    elsif  global_v_lang = '105' and rec_tax.descpay5 != p_desctax5 then
                        update_log(p_codtax,'DESCPAY5',rec_tax.descpay5,p_desctax5);
                    end if;

                    begin
                        update tinexinf
                           set typpayr  = p_taxpayr,
                               descpaye = p_desctaxe,
                               descpayt = p_desctaxt,
                               descpay3 = p_desctax3,
                               descpay4 = p_desctax4,
                               descpay5 = p_desctax5,
                               coduser  = global_v_coduser
                         where codpay = p_codtax;
                    end;
                end if;
--<< user20 Date: 14/10/2021 #6881
            else
                begin
                    select codtax into v_old_codtax
                    from ttaxtab
                    where codpay = p_codpay;
                exception when no_data_found then
                    v_old_codtax := null;
                end;
                begin
                    update ttaxtab set
                        codtax = p_codtax,
                        dteupd = trunc(sysdate),
                        coduser = global_v_coduser
                     where codpay = p_codpay;
                end;
                update_log(p_codpay,'CODTAX',v_old_codtax,p_codtax);
--<< user20 Date: 14/10/2021 #6881
            end if;
          -- close ภาษี

          -- รายได้ส่วนหัก
            begin
                select count(*) into v_count
                  from tinexinf
                 where codpay = p_codpay;
            exception when others then
                v_count := 0;
            end;

            if v_count = 0 then
                -- กรณีเป็นข้อมูลใหม่ที่ไม่เคยมีในฐานข้อมูล ให้ Default ค่าตั้งต้น ดังนี้ [ประเภทรหัส = รายได้ประจำ,ชนิดภาษี = หักภาษี ณ ที่จ่าย,เงื่อนไขการปัดเศษ = ทศนิยม 2 ตาแหน่ง]
                begin
                  insert into tinexinf( codpay, typpay, flgtax, flgfml, coduser, codcreate)
                  values( p_codpay, '1', '1', '4', global_v_coduser, global_v_coduser);
                end;
                commit;

                -- log add
                update_log(p_codpay,'CODPAY',null,p_codpay);
                update_log(p_codpay,'TYPPAY',null,'1');
                update_log(p_codpay,'FLGTAX',null,'1');
                update_log(p_codpay,'FLGFML',null,'4');
--<< user20 Date: 17/09/2021 #6883
                update_log(p_codpay,'TYPINC',null,p_typinc);
                update_log(p_codpay,'TYPPAYR',null,p_typpayr);
                update_log(p_codpay,'TYPPAYT',null,p_typpayt);

                if p_codtax is not null  then
                    begin
                        select * into rec_tinexinf2
                        from tinexinf
                        where codpay = p_codtax;
                    exception when no_data_found then null;
                        update_log(p_codtax,'CODPAY',null,p_codtax);
                        update_log(p_codtax,'TYPPAYR',null,p_taxpayr);
                    end;
                    if rec_tinexinf2.typpayr <> p_taxpayr then
                        update_log(p_codtax,'TYPPAYR',rec_tinexinf2.typpayr,p_taxpayr);
                    end if;
                end if;
--<< user20 Date: 17/09/2021 #6883
            end if;
            -- GRPPAY hardcode = 1 รายได้ ถ้ามาจากรหัสภาษี GRPPAY hardcode = 2 ค่าใช้จ่าย
            if p_typpay = '6' then
                v_grppay := '2';
            end if;

            -- log edit
            begin
                select * into rec_tinexinf
                from tinexinf
                where codpay = p_codpay;
            exception when no_data_found then null;
            end;

            if rec_tinexinf.typinc != p_typinc then
                update_log(p_codpay,'TYPINC',rec_tinexinf.typinc,p_typinc);
            end if;
            if rec_tinexinf.typpayr != p_typpayr then
                update_log(p_codpay,'TYPPAYR',rec_tinexinf.typpayr,p_typpayr);
            end if;
            if rec_tinexinf.typpayt != p_typpayt then
                update_log(p_codpay,'TYPPAYT',rec_tinexinf.typpayt,p_typpayt);
            end if;
--<< user20 Date: 17/09/2021 #6883
            if rec_tinexinf.typincpnd != p_typincpnd then
                update_log(p_codpay,'TYPINCPND',rec_tinexinf.typincpnd,p_typincpnd);
            end if;
            if rec_tinexinf.typincpnd50 != p_typincpnd50 then
                update_log(p_codpay,'TYPINCPND50',rec_tinexinf.typincpnd50,p_typincpnd50);
            end if;

            if p_codtax is not null  then
                begin
                    select * into rec_tinexinf2
                    from tinexinf
                    where codpay = p_codtax;
                exception when no_data_found then null;
                    update_log(p_codtax,'CODPAY',null,p_codtax);
                    update_log(p_codtax,'TYPPAYR',null,p_taxpayr);
                end;
                if rec_tinexinf2.typpayr <> p_taxpayr then
                    update_log(p_codtax,'TYPPAYR',rec_tinexinf2.typpayr,p_taxpayr);
                end if;
            end if;
--<< user20 Date: 17/09/2021 #6883
            if global_v_lang = '101' and rec_tinexinf.descpaye != p_descpaye then
                update_log(p_codpay,'DESCPAYE',rec_tinexinf.descpaye,p_descpaye);
            elsif  global_v_lang = '102' and rec_tinexinf.descpayt != p_descpayt then
                update_log(p_codpay,'DESCPAYT',rec_tinexinf.descpayt,p_descpayt);
            elsif  global_v_lang = '103' and rec_tinexinf.descpay3 != p_descpay3 then
                update_log(p_codpay,'DESCPAY3',rec_tinexinf.descpay3,p_descpay3);
            elsif  global_v_lang = '104' and rec_tinexinf.descpay4 != p_descpay4 then
                update_log(p_codpay,'DESCPAY4',rec_tinexinf.descpay4,p_descpay4);
            elsif  global_v_lang = '105' and rec_tinexinf.descpay5 != p_descpay5 then
                update_log(p_codpay,'DESCPAY5',rec_tinexinf.descpay5,p_descpay5);
            end if;
            if rec_tinexinf.typpay != p_typpay then
                update_log(p_codpay,'TYPPAY',rec_tinexinf.typpay,p_typpay);
            end if;
            if rec_tinexinf.flgtax != p_flgtax then
                update_log(p_codpay,'FLGTAX',rec_tinexinf.flgtax,p_flgtax);
            end if;
            if rec_tinexinf.flgfml != p_flgfml then
                update_log(p_codpay,'FLGFML',rec_tinexinf.flgfml,p_flgfml);
            end if;
            if rec_tinexinf.flgcal != p_flgcal then
                update_log(p_codpay,'FLGCAL',rec_tinexinf.flgcal,p_flgcal);
            end if;
            if rec_tinexinf.flgform != p_flgform then
                update_log(p_codpay,'FLGFORM',rec_tinexinf.flgform,p_flgform);
            end if;
            if rec_tinexinf.flgwork != p_flgwork then
                update_log(p_codpay,'FLGWORK',rec_tinexinf.flgwork,p_flgwork);
            end if;
            if rec_tinexinf.flgsoc != p_flgsoc then
                update_log(p_codpay,'FLGSOC',rec_tinexinf.flgsoc,p_flgsoc);
            end if;
            if rec_tinexinf.flgpvdf != p_flgpvdf then
                update_log(p_codpay,'FLGPVDF',rec_tinexinf.flgpvdf,p_flgpvdf);
            end if;
            if rec_tinexinf.grppay != v_grppay then
                update_log(p_codpay,'GRPPAY',rec_tinexinf.grppay,v_grppay);
            end if;

            begin
                update tinexinf
                set typinc   = p_typinc,
                    typpayr  = p_typpayr,
                    typpayt  = p_typpayt,
                    typincpnd  = p_typincpnd,
                    typincpnd50  = p_typincpnd50,
                    descpaye = p_descpaye,
                    descpayt = p_descpayt,
                    descpay3 = p_descpay3,
                    descpay4 = p_descpay4,
                    descpay5 = p_descpay5,
                    typpay   = p_typpay,
                    flgtax   = p_flgtax,
                    flgfml   = p_flgfml,
                    flgcal   = p_flgcal,
                    flgform  = p_flgform,
                    flgwork  = p_flgwork,
                    flgsoc   = p_flgsoc ,
                    flgpvdf  = p_flgpvdf,
                    grppay   = v_grppay,
                    coduser  = global_v_coduser
                where
                    codpay = p_codpay;
            end;
            -- บันทึกสูตรคำนวณ
    --            if p_flgform = 'Y' then
    --                save_formula_2;
    --            end if;
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        end if;
        --        -- สูตรคำนวณ
        --        if p_flgform = 'Y' then
        --            save_formula(json_str_input, json_str_output);
        --        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    procedure save_formula(json_str_input in clob, json_str_output out clob) is
        v_count        number;
        rec_tformula   tformula%rowtype;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            begin
                select count(*)
                  into v_count
                  from tformula
                 where codpay = p_codpay;
            exception when others then
                v_count := 0;
            end;

            if v_count = 0 then
                begin
                    insert into tformula( codpay, dteeffec, formula, amtmin, amtmax, dteupd, coduser, codcreate)
                    values( p_codpay, p_dteeffec, p_formula, p_amtmin, p_amtmax, trunc(sysdate), global_v_coduser, global_v_coduser);
                end;
                -- log add
                update_log(p_codpay,'DTEEFFEC',null,to_char(p_dteeffec,'dd/mm/yyyy'));
                update_log(p_codpay,'FORMULA',null,p_formula);
                update_log(p_codpay,'AMTMIN',null,p_amtmin);
                update_log(p_codpay,'AMTMAX',null,p_amtmax);
            else
                -- log edit
                begin
                    select *
                      into rec_tformula
                      from tformula
                     where codpay = p_codpay;
                exception when no_data_found then
                    return;
                end;
                if rec_tformula.dteeffec != p_dteeffec then
                    update_log(p_codpay,'DTEEFFEC',to_char(rec_tformula.dteeffec,'dd/mm/yyyy'),to_char(p_dteeffec,'dd/mm/yyyy'));
                end if;
                if rec_tformula.formula != p_formula then
                    update_log(p_codpay,'FORMULA',rec_tformula.formula,p_formula);
                end if;
                if rec_tformula.amtmin != p_amtmin then
                    update_log(p_codpay,'AMTMIN',rec_tformula.amtmin,p_amtmin);
                end if;
                if rec_tformula.amtmax != p_amtmax then
                    update_log(p_codpay,'AMTMAX',rec_tformula.amtmax,p_amtmax);
                end if;
                begin
                    update tformula
                       set dteeffec = p_dteeffec,
                           formula  = p_formula,
                           amtmin   = p_amtmin,
                           amtmax   = p_amtmax,
                           coduser  = global_v_coduser
                     where codpay = p_codpay;
                end;
            end if;
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
    end save_formula;

    procedure check_delete(v_codpay varchar2) is
        v_count number := 0;
    begin
        begin
            select count(*)
              into v_count
              from tinexinf
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
            return;
        end if;
        -- ตรวจสอบว่ามีการนาไปใช้หรือยัง จากตารางดังนี้ tempinc,tothinc,tothpay,treconc,tytdinc,tgltabi,tsincexp ถ้าเจอข้อมูลให้แจ้งเตือน HR1450 และส่งชื่อตารางที่เจอ ตอนแสดงข้อความเตือนด้วย
        begin
            select count(*)
              into v_count
              from tempinc
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tempinc');
            return;
        end if;
        begin
            select count(*)
              into v_count
              from tothinc
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tothinc');
            return;
        end if;
        begin
            select count(*)
              into v_count
              from tothpay
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tothpay');
            return;
        end if;
        begin
            select count(*)
              into v_count
              from treconc
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'treconc');
            return;
        end if;
        begin
            select count(*)
              into v_count
              from tytdinc
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tytdinc');
            return;
        end if;
        begin
            select count(*) into v_count
            from tgltabi
            where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tgltabi');
            return;
        end if;
        begin
            select count(*)
              into v_count
              from tsincexp
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tsincexp');
            return;
        end if;
    end;

    procedure update_log_delete(v_codpay varchar2) is
        rec_tinexinf    tinexinf%rowtype;
        rec_ttaxtab     ttaxtab%rowtype;
        rec_tformula    tformula%rowtype;
        v_desc          varchar2(150 char);
        v_count_taxtab  number := 0;
        v_count_formula number := 0;
    begin
    -- TINEXINF เก็บ Log ทุกคอลัมน์ ยกเว้น dtecreate,codcreate,dteupd,coduser
        begin
            select *
              into rec_tinexinf
              from tinexinf
             where codpay = v_codpay;
        exception when others then
            null;
        end;
        update_log(v_codpay,'CODPAY',rec_tinexinf.codpay,null);
        update_log(v_codpay,'TYPPAY',rec_tinexinf.typpay,null);
        update_log(v_codpay,'FLGTAX',rec_tinexinf.flgtax,null);
        update_log(v_codpay,'FLGFML',rec_tinexinf.flgfml,null);
        update_log(v_codpay,'FLGPVDF',rec_tinexinf.flgpvdf,null);
        update_log(v_codpay,'FLGWORK',rec_tinexinf.flgwork,null);
        update_log(v_codpay,'FLGSOC',rec_tinexinf.flgsoc,null);
        update_log(v_codpay,'FLGCAL',rec_tinexinf.flgcal,null);
        update_log(v_codpay,'FLGFORM',rec_tinexinf.flgform,null);
        update_log(v_codpay,'TYPINC',rec_tinexinf.typinc,null);
        update_log(v_codpay,'TYPPAYR',rec_tinexinf.typpayr,null);
        update_log(v_codpay,'TYPPAYT',rec_tinexinf.typpayt,null);
        update_log(v_codpay,'TYPINCPND',rec_tinexinf.typincpnd,null);
        update_log(v_codpay,'GRPPAY',rec_tinexinf.grppay,null);

        -- TINEXINF คำอธิบายเก็บ Log เฉพาะภาษาที่ login
        if global_v_lang = '101' then
            update_log(v_codpay,'DESCPAYE',rec_tinexinf.descpaye,null);
        elsif global_v_lang = '102' then
            update_log(v_codpay,'DESCPAYT',rec_tinexinf.descpayt,null);
        elsif global_v_lang = '103' then
            v_desc := rec_tinexinf.descpay3;
            update_log(v_codpay,'DESCPAY3',rec_tinexinf.descpay3,null);
        elsif global_v_lang = '104' then
            v_desc := rec_tinexinf.descpay4;
            update_log(v_codpay,'DESCPAY4',rec_tinexinf.descpay4,null);
        elsif global_v_lang = '105' then
            v_desc := rec_tinexinf.descpay5;
            update_log(v_codpay,'DESCPAY5',rec_tinexinf.descpay5,null);
        end if;

        -- TTAXTAB เก็บ Log เฉพาะคอลัมน์ codpay,codtax
        begin
            select count(*)
              into v_count_taxtab
              from ttaxtab
             where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count_taxtab > 0 then
            begin
                select *
                  into rec_ttaxtab
                  from ttaxtab
                 where codpay = v_codpay;
            exception when others then
                null;
            end;
            update_log(v_codpay,'CODTAX',rec_ttaxtab.codtax,null);
        end if;

        -- TFORMULA เก็บ Log ทุกคอลัมน์
        begin
            select count(*) into v_count_formula
            from tformula
            where codpay = v_codpay;
        exception when others then null;
        end;
        if v_count_formula > 0 then
            begin
                select *
                  into rec_tformula
                  from tformula
                 where codpay = v_codpay
                   and dteeffec = (select max(dteeffec) from tformula where codpay = v_codpay );
--                order by dteeffec desc
--                fetch first 1 rows only;
            exception when others then
                null;
            end;
            update_log(v_codpay,'DTEEFFEC',to_char(rec_tformula.dteeffec,'dd/mm/yyyy'),null);--User37 14/05/2021 update_log(v_codpay,'DTEEFFEC',rec_tformula.dteeffec,null);
            update_log(v_codpay,'FORMULA',rec_tformula.formula,null);
            update_log(v_codpay,'AMTMIN',rec_tformula.amtmin,null);
            update_log(v_codpay,'AMTMAX',rec_tformula.amtmax,null);
        end if;
    end;

    procedure delete_data(json_str_input in clob, json_str_output out clob) is
        param_json json_object_t;
        v_codpay varchar2(4 char);
    begin
        initial_value(json_str_input);
        param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        for i in 0..param_json.get_size-1 loop
            v_codpay := hcm_util.get_string_t(param_json,to_char(i));
            check_delete(v_codpay);
            if param_msg_error is null then
                -- log
                update_log_delete(v_codpay);
                -- ลบข้อมูลที่เกี่ยวข้องดังนี้
                delete from tformula where codpay = v_codpay;
                delete from ttaxtab where codpay = v_codpay;
                delete from tinexinf where codpay = v_codpay;
            end if;
        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        else
            rollback;
        end if;
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure get_codtax_detail(json_str_input in clob, json_str_output out clob) is
        obj_data        json_object_t;
        obj_row         json_object_t;
        v_count         number := 0;
        v_taxpayr       varchar2(4 char);
        v_desctaxe      varchar2(150 char);
        v_desctaxt      varchar2(150 char);
        v_desctax3      varchar2(150 char);
        v_desctax4      varchar2(150 char);
        v_desctax5      varchar2(150 char);
        rec_tinexinf    tinexinf%rowtype;
    begin
        initial_value(json_str_input);
        if p_codtax = p_codpay then
            param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        else
            begin
                select count(*)
                  into v_count
                  from ttaxtab
                 where codpay <> p_codpay
                   and codtax = p_codtax;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('PY0029',global_v_lang);
            end if;

            if p_codtax is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
        end if;
        if param_msg_error is null then
            obj_row     := json_object_t();
            obj_data    := json_object_t();
            begin
                select *
                  into rec_tinexinf
                  from tinexinf
                 where codpay = p_codtax;
            exception when no_data_found then
                rec_tinexinf.typpayr := '';
                rec_tinexinf.descpaye := '';
                rec_tinexinf.descpayt := '';
                rec_tinexinf.descpay3 := '';
                rec_tinexinf.descpay4 := '';
                rec_tinexinf.descpay5 := '';
            end;
            obj_data.put('taxpayr', rec_tinexinf.typpayr);
            obj_data.put('desctaxe', rec_tinexinf.descpaye);
            obj_data.put('desctaxt', rec_tinexinf.descpayt);
            obj_data.put('desctax3', rec_tinexinf.descpay3);
            obj_data.put('desctax4', rec_tinexinf.descpay4);
            obj_data.put('desctax5', rec_tinexinf.descpay5);
            obj_row.put('0',obj_data);

            json_str_output := obj_row.to_clob;
        else
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure static_report(json_str_input in clob, json_str_output out clob) is
        v_numseq    number := 0;
        v_codapp    varchar2(10 char) := 'HRPY21E';
        param_json  json_object_t;
        obj_data    json_object_t;
        v_codpay    varchar2(600 char);
        v_typpay    varchar2(600 char);
        v_flgtax    varchar2(600 char);
        v_flgfml    varchar2(600 char);
        v_flgcal    varchar2(600 char);
        v_flgwork   varchar2(600 char);
        v_flgsoc    varchar2(600 char);
        v_flgpvdf   varchar2(600 char);
        v_flgform   varchar2(600 char);
        v_formula   varchar2(600 char);
        v_typinc    varchar2(600 char);
        v_typpayr   varchar2(600 char);
        v_typpayt   varchar2(600 char);
        v_codtax    varchar2(600 char);
        v_taxpayr   varchar2(600 char);
        v_typincpnd varchar2(600 char);
        v_typincpnd50 varchar2(600 char);
    begin
        initial_value(json_str_input);
        param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        delete from ttemprpt
         where codapp = v_codapp
           and codempid = global_v_codempid;
        for i in 0..param_json.get_size-1 loop
            obj_data    := hcm_util.get_json_t(param_json,to_char(i));
            v_codpay    := hcm_util.get_string_t(obj_data,'codpay');
            v_typpay    := hcm_util.get_string_t(obj_data,'typpay');
            v_flgtax    := hcm_util.get_string_t(obj_data,'flgtax');
            v_flgfml    := hcm_util.get_string_t(obj_data,'flgfml');
            v_flgcal    := hcm_util.get_string_t(obj_data,'flgcal');
            v_flgwork   := hcm_util.get_string_t(obj_data,'flgwork');
            v_flgsoc    := hcm_util.get_string_t(obj_data,'flgsoc');
            v_flgpvdf   := hcm_util.get_string_t(obj_data,'flgpvdf');
            v_flgform   := hcm_util.get_string_t(obj_data,'flgform');
            v_formula   := hcm_util.get_string_t(obj_data,'formula_desc');
            v_typinc    := hcm_util.get_string_t(obj_data,'typinc');
            v_typpayr   := hcm_util.get_string_t(obj_data,'typpayr');
            v_typpayt   := hcm_util.get_string_t(obj_data,'typpayt');
            v_codtax    := hcm_util.get_string_t(obj_data,'codtax');
            v_taxpayr   := hcm_util.get_string_t(obj_data,'taxpayr');
            v_typincpnd := hcm_util.get_string_t(obj_data,'typincpnd');
            v_typincpnd50 := hcm_util.get_string_t(obj_data,'typincpnd50');
            insert into ttemprpt ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6,
                                   item7, item8, item9, item10, item11, item12, item13, item14, item15, item16,item17)
            values ( global_v_codempid, 'HRPY21E', i + 1, v_codpay, v_typpay, v_flgtax, v_flgfml, v_flgcal, v_flgwork,
                     v_flgsoc, v_flgpvdf, v_flgform, v_formula, v_typinc, v_typpayr, v_typpayt, v_codtax, v_taxpayr, v_typincpnd,v_typincpnd50);
                commit;
        end loop;

        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

end HRPY21E;

/
