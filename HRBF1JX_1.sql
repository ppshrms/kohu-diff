--------------------------------------------------------
--  DDL for Package Body HRBF1JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1JX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcln          := upper(hcm_util.get_string(json_obj,'codcln'));
        p_codcomp         := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_flgdocmt        := upper(hcm_util.get_string(json_obj,'flgdocmt'));
        p_numpaymt_st     := hcm_util.get_string(json_obj,'p_numpaymt_st');
        p_numpaymt_en     := hcm_util.get_string(json_obj,'p_numpaymt_en');
        p_dtecrest        := to_date(hcm_util.get_string(json_obj,'dtecrest'),'dd/mm/yyyy');
        p_dtecreen          := to_date(hcm_util.get_string(json_obj,'dtecreen'),'dd/mm/yyyy');
        p_dtereq_st          := to_date(hcm_util.get_string(json_obj,'dtereq_st'),'dd/mm/yyyy');
        p_dtereq_en          := to_date(hcm_util.get_string(json_obj,'dtereq_en'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcln is null or ((p_dtecrest is null or p_dtecreen is null) and (p_dtereq_st is null or p_dtereq_en is null))   then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_dtecrest > p_dtecreen then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_dtereq_st > p_dtereq_en then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_codcln is not null then
            begin
                select 'X' into v_temp
                from TCLNINF
                where codcln = p_codcln;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCLNINF');
                return;
            end;
        end if;

        if p_codcomp is not null then
            -- ('HR3007')
            param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_row_secur number := 0;

        cursor c1 is
            select numvcher, codempid, namsick, typpatient, codrel, dtecrest, dtecreen, dtereq, amtexp, amtalw
            from TCLNSINF a
            where CODCLN = p_codcln
                and codcomp like nvl(p_codcomp||'%',codcomp)
                and flgdocmt = nvl(p_flgdocmt,flgdocmt)
--                and numpaymt between nvl(p_numpaymt_st,numpaymt) and nvl(p_numpaymt_en,numpaymt)
                --<<User37 #5671 BF - PeoplePlus 02/04/2021 
                and (( p_numpaymt_st is null) or ((p_numpaymt_st is not null) and numinvoice is not null and numinvoice between nvl(p_numpaymt_st,numinvoice) and nvl(p_numpaymt_en,numinvoice)) )
--                and (numinvoice is not null and numinvoice between nvl(p_numpaymt_st,numinvoice) and nvl(p_numpaymt_en,numinvoice))
                -->>User37 #5671 BF - PeoplePlus 02/04/2021 
                and dtecrest between nvl(p_dtecrest, dtecrest) and nvl(p_dtecreen,dtecreen)
                and dtecreen between nvl(p_dtecrest, dtecrest) and nvl(p_dtecreen,dtecreen)
                and DTEREQ between nvl(p_dtereq_st, DTEREQ) and nvl(p_dtereq_en,DTEREQ)
            order by codempid,DTECREST;
    begin
        obj_rows := json();
        if p_flgdocmt = 'A' then
            p_flgdocmt := null;
        elsif p_flgdocmt  = 'Y' then
            p_flgdocmt := 'Y';
        elsif p_flgdocmt  = 'N' then
            p_flgdocmt := 'N';
        end if;
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur := v_row_secur+1;
                obj_data := json();
                obj_data.put('numvcher',i.numvcher);
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('namsick',i.namsick);
                obj_data.put('typpatient_desc',get_tlistval_name('TYPPATIENT', i.typpatient,global_v_lang));
                obj_data.put('typrel_desc',get_tlistval_name('TTYPRELATE', i.codrel,global_v_lang));
                obj_data.put('dtecrest',to_char(i.DTECREST,'dd/mm/yyyy'));
                obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('amtexp',i.amtexp);
                obj_data.put('amtalw',i.AMTALW);
                obj_rows.put(to_char(v_row_secur-1),obj_data);
            end if;
        end loop;
        if v_row_secur = 0 and v_row > 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSINF');
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

END HRBF1JX;

/
