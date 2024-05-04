--------------------------------------------------------
--  DDL for Package Body HRBF11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF11E" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcln         := upper(hcm_util.get_string(json_obj,'codcln'));

    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        v_row           number := 0;

        cursor c1 is
            select CODCLN,typcln
            from TCLNINF  a
            order by codcln;
    begin

        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('codcln',i.CODCLN);
            obj_data.put('codcln_desc',get_tclninf_name(i.CODCLN,global_v_lang));
            obj_data.put('typcln',i.typcln);
            obj_data.put('typcln_desc',get_tlistval_name('NTYPCLN', i.typcln, global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
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

    procedure gen_detail(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;
        obj_data        json;

        cursor c1detail is
            select codcln,desclne,desclnt,descln3,descln4,descln5,typcln,adresse,adresst,adress3,adress4,adress5,CODSUBDISTR, CODDISTR, CODPROVR, NUMTELEC
            from tclninf a
            where codcln = p_codcln;

    begin

        obj_rows := json();
        for i in c1detail loop
            obj_rows.put('flag','edit');
            obj_rows.put('codcln',i.CODCLN);
            obj_rows.put('codcln_desce',i.desclne);
            obj_rows.put('codcln_desct',i.desclnt);
            obj_rows.put('codcln_desc3',i.descln3);
            obj_rows.put('codcln_desc4',i.descln4);
            obj_rows.put('codcln_desc5',i.descln5);
            obj_rows.put('typcln',i.typcln);
            obj_rows.put('typcln_desc',get_tlistval_name('NTYPCLN', i.typcln, global_v_lang));
            obj_rows.put('adresse',i.adresse);
            obj_rows.put('adresst',i.adresst);
            obj_rows.put('adress3',i.adress3);
            obj_rows.put('adress4',i.adress4);
            obj_rows.put('adress5',i.adress5);
            obj_rows.put('codsubdistr',i.codsubdistr);
            obj_rows.put('coddistr',i.coddistr);
            obj_rows.put('codprovr',i.codprovr);
            obj_rows.put('numtelec',i.numtelec);
        end loop;
        obj_rows.put('flag','edit');
        obj_head := json();
        obj_head.put('0',obj_rows);
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail;

    procedure gen_detail_default(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;
        obj_data        json;

    begin

        obj_rows := json();
        obj_rows.put('codcln','');
        obj_rows.put('codcln_desce','');
        obj_rows.put('codcln_desct','');
        obj_rows.put('codcln_desc3','');
        obj_rows.put('codcln_desc4','');
        obj_rows.put('codcln_desc5','');
        obj_rows.put('typcln','');
        obj_rows.put('typcln_desc','');
        obj_rows.put('adresse','');
        obj_rows.put('adresst','');
        obj_rows.put('adress3','');
        obj_rows.put('adress4','');
        obj_rows.put('adress5','');
        obj_rows.put('codsubdistr','');
        obj_rows.put('coddistr','');
        obj_rows.put('codprovr','');
        obj_rows.put('numtelec','');
        obj_rows.put('flag','add');

        obj_head := json();
        obj_head.put('0',obj_rows);
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail_default;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            begin
                select 'Y' into v_temp
                from TCLNINF a
                where CODCLN = p_codcln;
            exception when no_data_found then
                v_temp := 'N';
            end;
            if v_temp = 'Y' then
                gen_detail(json_str_output);
            elsif  v_temp = 'N' then
                gen_detail_default(json_str_output);
            end if;
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure add_detail(json_obj json) as
        v_codcln            tclninf.codcln%type;
        v_codcln_desce      tclninf.DESCLNE%type;
        v_codcln_desct      tclninf.DESCLNT%type;
        v_codcln_desc3      tclninf.DESCLN3%type;
        v_codcln_desc4      tclninf.DESCLN4%type;
        v_codcln_desc5      tclninf.DESCLN5%type;
        v_typcln            tclninf.typcln%type;
        v_adresse            tclninf.adresse%type;
        v_adresst            tclninf.adresst%type;
        v_adress3            tclninf.adress3%type;
        v_adress4            tclninf.adress4%type;
        v_adress5            tclninf.adress5%type;
        v_codsubdistr       tclninf.codsubdistr%type;
        v_coddistr          tclninf.coddistr%type;
        v_codprovr          tclninf.codprovr%type;
        v_numtelec          tclninf.numtelec%type;
    begin
        v_codcln             := upper(hcm_util.get_string(json_obj,'codcln'));
        v_codcln_desce       := hcm_util.get_string(json_obj,'codcln_desce');
        v_codcln_desct       := hcm_util.get_string(json_obj,'codcln_desct');
        v_codcln_desc3       := hcm_util.get_string(json_obj,'codcln_desc3');
        v_codcln_desc4       := hcm_util.get_string(json_obj,'codcln_desc4');
        v_codcln_desc5       := hcm_util.get_string(json_obj,'codcln_desc5');
        v_typcln             := upper(hcm_util.get_string(json_obj,'typcln'));
        v_adresse             := hcm_util.get_string(json_obj,'adresse');
        v_adresst             := hcm_util.get_string(json_obj,'adresst');
        v_adress3             := hcm_util.get_string(json_obj,'adress3');
        v_adress4             := hcm_util.get_string(json_obj,'adress4');
        v_adress5             := hcm_util.get_string(json_obj,'adress5');
        v_codsubdistr        := upper(hcm_util.get_string(json_obj,'codsubdistr'));
        v_coddistr           := upper(hcm_util.get_string(json_obj,'coddistr'));
        v_codprovr           := upper(hcm_util.get_string(json_obj,'codprovr'));
        v_numtelec           := hcm_util.get_string(json_obj,'numtelec');

        INSERT INTO tclninf (codcln,DESCLNE,DESCLNT,DESCLN3,DESCLN4,DESCLN5,typcln,adresse,adresst,adress3,adress4,adress5,codsubdistr,coddistr,codprovr,numtelec, codcreate, coduser )
        VALUES (v_codcln,v_codcln_desce,v_codcln_desct,v_codcln_desc3,v_codcln_desc4,v_codcln_desc5,v_typcln,v_adresse,v_adresst,v_adress3,v_adress4,v_adress5,v_codsubdistr,v_coddistr,v_codprovr,v_numtelec, global_v_coduser, global_v_coduser );

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end add_detail;

    procedure update_detail(json_obj json) as
        v_codcln            tclninf.codcln%type;
        v_codcln_desce      tclninf.DESCLNE%type;
        v_codcln_desct      tclninf.DESCLNT%type;
        v_codcln_desc3      tclninf.DESCLN3%type;
        v_codcln_desc4      tclninf.DESCLN4%type;
        v_codcln_desc5      tclninf.DESCLN5%type;
        v_typcln            tclninf.typcln%type;
        v_adresse            tclninf.adresse%type;
        v_adresst            tclninf.adresst%type;
        v_adress3            tclninf.adress3%type;
        v_adress4            tclninf.adress4%type;
        v_adress5            tclninf.adress5%type;
        v_codsubdistr       tclninf.codsubdistr%type;
        v_coddistr         tclninf.coddistr%type;
        v_codprovr         tclninf.codprovr%type;
        v_numtelec         tclninf.numtelec%type;
    begin
        v_codcln            := upper(hcm_util.get_string(json_obj,'codcln'));
        v_codcln_desce       := hcm_util.get_string(json_obj,'codcln_desce');
        v_codcln_desct       := hcm_util.get_string(json_obj,'codcln_desct');
        v_codcln_desc3       := hcm_util.get_string(json_obj,'codcln_desc3');
        v_codcln_desc4       := hcm_util.get_string(json_obj,'codcln_desc4');
        v_codcln_desc5       := hcm_util.get_string(json_obj,'codcln_desc5');
        v_typcln            := upper(hcm_util.get_string(json_obj,'typcln'));
        v_adresse             := hcm_util.get_string(json_obj,'adresse');
        v_adresst             := hcm_util.get_string(json_obj,'adresst');
        v_adress3             := hcm_util.get_string(json_obj,'adress3');
        v_adress4             := hcm_util.get_string(json_obj,'adress4');
        v_adress5             := hcm_util.get_string(json_obj,'adress5');
        v_codsubdistr       := upper(hcm_util.get_string(json_obj,'codsubdistr'));
        v_coddistr          := upper(hcm_util.get_string(json_obj,'coddistr'));
        v_codprovr          := upper(hcm_util.get_string(json_obj,'codprovr'));
        v_numtelec          := hcm_util.get_string(json_obj,'numtelec');

       update tclninf
        set typcln        = v_typcln,
            DESCLNE       = v_codcln_desce,
            DESCLNT       = v_codcln_desct,
            DESCLN3       = v_codcln_desc3,
            DESCLN4       = v_codcln_desc4,
            DESCLN5       = v_codcln_desc5,
            adresse       = v_adresse,
            adresst       = v_adresst,
            adress3       = v_adress3,
            adress4       = v_adress4,
            adress5       = v_adress5,
            codsubdistr   = v_codsubdistr,
            coddistr      = v_coddistr,
            codprovr      = v_codprovr,
            numtelec      = v_numtelec,
             coduser =  global_v_coduser
        where codcln = v_codcln;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end update_detail;

    procedure check_save_detail(json_obj json) as
        v_temp              varchar2(1 char);
        v_codcln            tclninf.codcln%type;
        v_codcln_desce      tclninf.DESCLNE%type;
        v_codcln_desct      tclninf.DESCLNT%type;
        v_codcln_desc3      tclninf.DESCLN3%type;
        v_codcln_desc4      tclninf.DESCLN4%type;
        v_codcln_desc5      tclninf.DESCLN5%type;
        v_typcln            tclninf.typcln%type;
        v_adresse            tclninf.adresse%type;
        v_adresst            tclninf.adresst%type;
        v_adress3            tclninf.adress3%type;
        v_adress4            tclninf.adress4%type;
        v_adress5            tclninf.adress5%type;
        v_codsubdistr       tclninf.codsubdistr%type;
        v_coddistr         tclninf.coddistr%type;
        v_codprovr         tclninf.codprovr%type;
        v_numtelec         tclninf.numtelec%type;
    begin
        v_codcln            := upper(hcm_util.get_string(json_obj,'codcln'));
        v_codcln_desce       := hcm_util.get_string(json_obj,'codcln_desce');
        v_codcln_desct       := hcm_util.get_string(json_obj,'codcln_desct');
        v_codcln_desc3       := hcm_util.get_string(json_obj,'codcln_desc3');
        v_codcln_desc4       := hcm_util.get_string(json_obj,'codcln_desc4');
        v_codcln_desc5       := hcm_util.get_string(json_obj,'codcln_desc5');
        v_typcln            := upper(hcm_util.get_string(json_obj,'typcln'));
        v_adresse             := hcm_util.get_string(json_obj,'adresse');
        v_adresst             := hcm_util.get_string(json_obj,'adresst');
        v_adress3             := hcm_util.get_string(json_obj,'adress3');
        v_adress4             := hcm_util.get_string(json_obj,'adress4');
        v_adress5             := hcm_util.get_string(json_obj,'adress5');
        v_codsubdistr       := upper(hcm_util.get_string(json_obj,'codsubdistr'));
        v_coddistr          := upper(hcm_util.get_string(json_obj,'coddistr'));
        v_codprovr          := upper(hcm_util.get_string(json_obj,'codprovr'));
        v_numtelec          := upper(hcm_util.get_string(json_obj,'numtelec'));

        if v_codcln is null or v_typcln is null or v_codsubdistr is null  or v_coddistr is null or v_codprovr is null or v_numtelec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--        or v_codcln_desce is null or v_codcln_desct is null or v_codcln_desc3 is null or v_codcln_desc4 is null or v_codcln_desc5 is null
--        or v_adresse is null or v_adresst is null or v_adress3 is null or v_adress4 is null or v_adress5 is null

        if (global_v_lang ='101') and ((v_codcln_desce is null) or v_adresse is null ) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang ='102') and ((v_codcln_desct is null) or v_adresst is null ) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang ='103') and ((v_codcln_desc3 is null) or v_adress3 is null ) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang ='104') and ((v_codcln_desc4 is null) or v_adress4 is null ) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang ='105') and ((v_codcln_desc5 is null) or v_adress5 is null ) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from TCODPROV
            where CODCODEC = v_codprovr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV');
            return;
        end;
        begin
            select 'X' into v_temp
            from TCODDIST
            where CODDIST = v_coddistr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDIST');
            return;
        end;
        begin
            select 'X' into v_temp
            from TSUBDIST
            where CODSUBDIST = v_codsubdistr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBDIST');
            return;
        end;
    end check_save_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        v_flag      varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj          := json(json_str_input);
        check_save_detail(json_obj);
        if param_msg_error is null then
            v_flag  := hcm_util.get_string(json_obj,'flag');
            if v_flag = 'add' then
                add_detail(json_obj);
            elsif v_flag = 'edit' then
                update_detail(json_obj);
            end if;
        end if;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure check_save_index(detail_obj json) as
        v_temp      varchar2(1 char);
        v_not_existed   boolean;
        v_codcln     tclninf.codcln%TYPE;
        v_count_TCLNSINF number := 0;
        v_count_THWCCASE number := 0;
        v_count_THWCCASE_CODCLNPRIV number := 0;
        v_count_THEALINF1 number := 0;
    begin
        v_codcln := upper(hcm_util.get_string(detail_obj, 'codcln'));

               select count(*)
               into v_count_TCLNSINF
               from TCLNSINF
               where upper(codcln) = v_codcln;
            if v_count_TCLNSINF > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TCLNSINF');
                return;
            end if;

               select count(*)
               into v_count_THWCCASE
               from THWCCASE
               where upper(CODCLN) = v_codcln;
            if v_count_THWCCASE > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'THWCCASE');
                return;
            end if;

        /*      
        select count(*)
               into v_count_THWCCASE_CODCLNPRIV
               from THWCCASE
               where upper(CODCLNPRIV) = v_codcln;
            if v_count_THWCCASE_CODCLNPRIV > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'THWCCASE');
                return;
            end if;*/

               select count(*)
               into v_count_THEALINF1
               from THEALINF1
               where upper(codcln) = v_codcln;
            if v_count_THEALINF1 > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'THEALINF1');
                return;
            end if;
    end check_save_index;

    PROCEDURE delete_index( detail_obj json) AS
        v_codcln     tclninf.codcln%TYPE;
    BEGIN
        v_codcln := upper(hcm_util.get_string(detail_obj, 'codcln'));

        DELETE tclninf
            where codcln = v_codcln;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        param_json  json;
        detail_obj  json;

        v_flag      varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj          := json(json_str_input);
        param_json := hcm_util.get_json(json_obj, 'param_json');

        FOR i IN 0..param_json.count - 1 LOOP
            detail_obj := hcm_util.get_json(param_json, to_char(i));
            v_flag := hcm_util.get_string(detail_obj, 'flag');
            IF v_flag = 'del' THEN
                check_save_index(detail_obj);
                if param_msg_error is null then
                    delete_index(detail_obj);
                end if;
            END IF;
        END LOOP;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

END HRBF11E;

/
