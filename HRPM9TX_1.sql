--------------------------------------------------------
--  DDL for Package Body HRPM9TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM9TX" IS

    PROCEDURE initial_value (
        json_str IN CLOB
    ) IS
        json_obj   json_object_t := json_object_t(json_str);
    BEGIN
        global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
        global_chken := hcm_secur.get_v_chken;
        global_v_zyear := hcm_util.get_string_t(json_obj,'p_v_zyear');
        p_typedit := hcm_util.get_string_t(json_obj,'p_typedit');
        p_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_dteedit_st := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteedit_st') ),'dd/mm/yyyy');

        p_dteedit_en := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteedit_en') ),'dd/mm/yyyy');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen)

        ;
    END initial_value;

    PROCEDURE check_getindex IS
        v_codcomp             VARCHAR2(100 char);
        v_secur_codcomp_txt   VARCHAR2(1000 char);
    BEGIN
        IF p_typedit IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typedit');
            return;
        END IF;

        IF p_dteedit_st IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteedit_st');
            return;
        END IF;

        IF p_dteedit_en IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteedit_en');
            return;
        END IF;

        IF p_dteedit_st > p_dteedit_en THEN
            param_msg_error := get_error_msg_php('HR2021',global_v_lang,'');
            return;
        END IF;

        IF p_codcomp IS NOT NULL THEN
            BEGIN
                SELECT
                    codcomp
                INTO v_codcomp
                FROM
                    tcenter
                WHERE
                    codcomp = p_codcomp;

            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            v_secur_codcomp_txt := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
            IF v_secur_codcomp_txt IS NOT NULL THEN
                param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
                return;
            END IF;

        END IF;

    END;

    function checkNull(str in varchar2) RETURN varchar2 is
    returnVal varchar2(1000) := '***';
    begin
        if substr(str,1,3) != '***' then
            returnVal := str;
        end if;
        return  returnVal;
    end checkNull;

    PROCEDURE gen_data ( json_str_output OUT CLOB ) IS
        v_rcnt             NUMBER := 0;
        v_rcnt_found       NUMBER := 0;
        v_timoutst         VARCHAR2(10);
        v_timouten         VARCHAR2(10);
        v_timoutside       VARCHAR2(100);
        v_secur_codempid   BOOLEAN;
        v_flgdata          VARCHAR2(1) := 'N';
        --<<User37 Final Test Phase 1 V11 #3046 09/11/2020
        v_flgsecr          VARCHAR2(1) := 'N';
        v_secur            boolean;
        v_zupdsal          VARCHAR2(1) := 'N';

        v_secur2           boolean;
        v_zupdsal2         VARCHAR2(1) := 'N';
        -->>User37 Final Test Phase 1 V11 #3046 09/11/2020
        v_coltype           VARCHAR2(100) ;

        CURSOR c1 IS
            SELECT typedit, dteedit, codempid, numpage, fldedit,
                   typkey, desold, desnew, flgenc, codtable,
                   coduser, codedit, numseq
              FROM ( ( SELECT  '1' typedit, dteedit, codempid, numpage, fldedit,
                              NULL typkey, desold, desnew, flgenc, codtable,
                              coduser, NULL codedit, null numseq
                         FROM ttemlog1
                        WHERE codcomp LIKE p_codcomp||'%'
                          AND trunc(dteedit) BETWEEN p_dteedit_st AND p_dteedit_en
                          AND ( ( p_typedit = '999' )
                                 OR ( numpage LIKE to_number(p_typedit)|| '%' ) )
                      )
                      UNION
                      ( SELECT '2' typedit, dteedit, codempid, numpage, fldedit,
                               typkey, desold, desnew, flgenc, codtable,
                               coduser, DECODE(typkey,'N',TO_CHAR(numseq),'C',codseq,'D',
                               hcm_util.get_date_buddhist_era(dteseq)
                               /*TO_CHAR(dteseq,'DD/MM/YYYY')*/,NULL) codedit, numseq
                          FROM ttemlog2
                         WHERE codcomp LIKE p_codcomp||'%'
                           AND trunc(dteedit) BETWEEN p_dteedit_st AND p_dteedit_en
                           AND ( ( p_typedit = '999' )
                                 OR ( numpage LIKE to_number(p_typedit) || '%' ) )
                       )
                       UNION
                       ( SELECT '3' typedit, dteedit, codempid, numpage, typdeduct fldedit,
                                NULL typkey, desold, desnew, 'Y' flgenc, codtable,
                                coduser, coddeduct codedit, null numseq
                           FROM ttemlog3
                          WHERE codcomp LIKE p_codcomp||'%'
                            AND trunc(dteedit) BETWEEN p_dteedit_st AND p_dteedit_en
                            AND ( ( p_typedit = '999' )
                                  OR ( numpage LIKE to_number(p_typedit) || '%' ) )
                        )
                      )
          ORDER BY dteedit DESC,
                   codedit;

    BEGIN
        obj_row := json_object_t ();
        FOR i IN c1 LOOP
            v_flgdata   := 'Y';
            --<<User37 Final Test Phase 1 V11 #3046 09/11/2020
            v_secur     := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--3404
            v_zupdsal2 := 'N';
--3404
            if v_secur then
                v_flgsecr := 'Y';
--3404
                v_secur2  := secur_main.secur2(i.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal2);
--3404
            -->>User37 Final Test Phase 1 V11 #3046 09/11/2020
            v_rcnt      := v_rcnt + 1;
            v_rcnt_found := v_rcnt_found + 1;
            obj_data := json_object_t ();
            obj_data.put('coderror','200');
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
            obj_data.put('dteedit2',TO_CHAR(i.dteedit,'dd/mm/yyyy'));
            obj_data.put('dteedit',TO_CHAR(i.dteedit,'dd/mm/yyyy hh24:mi:ss'));
            obj_data.put('coduser',i.coduser);
            obj_data.put('numseq',i.numseq);
            obj_data.put('fldedit',i.fldedit);
            obj_data.put('numpage',i.numpage);


          begin
            select coltype
              into v_coltype
              from col
             where cname    = i.fldedit
               and tname    = i.codtable
               and rownum <= 1;
               exception when no_data_found then
                v_coltype := null;
          end;
            IF i.typedit = '3' THEN
                obj_data.put('typedit',checkNull(get_tlistval_name('TYPEDIT',substr(i.numpage,1,2),global_v_lang)));
                --<<User37 Final Test Phase 1 V11 #3037 01/12/2020
                /*obj_data.put('typedit',checkNull(get_tlistval_name('TYPEDIT',i.numpage,global_v_lang))
                                         || checkNull(get_tlistval_name('TYPEPRODUCT',i.fldedit,global_v_lang)));*/
                -->>User37 Final Test Phase 1 V11 #3037 01/12/2020
            ELSE
                --<<User37 Final Test Phase 1 V11 #3037 09/11/2020
                if length(i.numpage) > 2 then
                    obj_data.put('typedit',checkNull(get_tlistval_name('TYPEDIT',substr(i.numpage,1,2),global_v_lang)));
                else
                    obj_data.put('typedit',checkNull(get_tlistval_name('TYPEDIT',i.numpage,global_v_lang)));
                end if;
                --obj_data.put('typedit',checkNull(get_tlistval_name('TYPEDIT',i.numpage,global_v_lang)));
                -->>User37 Final Test Phase 1 V11 #3037 09/11/2020
            END IF;

            IF i.typedit = '3' THEN
                --<<User37 Final Test Phase 1 V11 #3037 01/12/2020
                obj_data.put('typdeduct',checkNull(get_tlistval_name('TYPEDEDUCT',i.fldedit,global_v_lang)));
                --obj_data.put('typdeduct',checkNull(get_tlistval_name('TYPDEDUCT',i.fldedit,global_v_lang)));
                -->>User37 Final Test Phase 1 V11 #3037 01/12/2020
            ELSE
                    if i.fldedit = 'DTEDUEPR' then
                        obj_data.put('typdeduct',get_label_name('HRPMC2E1T3',global_v_lang,360));
                    elsif i.fldedit = 'YREDATRQ' then
                        obj_data.put('typdeduct',get_label_name('HRPMC2E1T3',global_v_lang,370));
                    else
                        obj_data.put('typdeduct',checkNull(get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang)));
                    end if;
            END IF;



            IF i.typedit = '3' THEN
                obj_data.put('codedit',checkNull(get_tcodeduct_name(i.codedit,global_v_lang)));--User37 Final Test Phase 1 V11 18/11/2020 obj_data.put('codedit','aaa'||checkNull(get_tcodeduct_name(i.codedit,global_v_lang)));
            ELSE
                obj_data.put('codedit','');--User37 Final Test Phase 1 V11 18/11/2020 obj_data.put('codedit',i.codedit);
            END IF;

            IF i.flgenc = 'Y' THEN
--3404                obj_data.put('desold',TO_CHAR(stddec(i.desold,i.codempid,global_chken) ) );
                IF nvl(v_zupdsal2, 'N') = 'Y' THEN
                    obj_data.put('desold',TO_CHAR(stddec(i.desold,i.codempid,global_chken) ) );
                ELSE
                    obj_data.put('desold', ' ');
                END IF;
--3404
            ELSE
               if v_coltype  = 'NUMBER' then
                obj_data.put('desold',i.desold);
               else
                obj_data.put('desold',get_description(i.codtable,i.fldedit,i.desold));
               end if;
            END IF;


            IF i.flgenc = 'Y' THEN
--3404                obj_data.put('desnew',TO_CHAR(stddec(i.desnew,i.codempid,global_chken) ) );
                IF nvl(v_zupdsal2, 'N') = 'Y' THEN
                    obj_data.put('desnew',TO_CHAR(stddec(i.desnew,i.codempid,global_chken) ) );
                ELSE
                    obj_data.put('desnew', ' ');
                END IF;
--3404
            ELSE
                if v_coltype  = 'NUMBER' then
                    obj_data.put('desnew',i.desnew);
                else
                    obj_data.put('desnew',get_description(i.codtable,i.fldedit,i.desnew));
                end if;
            END IF;

            --<<User37 #2265 Final Test Phase 1 V11 24/03/2021 
          --  if i.fldedit in ('DTEGYEAR','STAYEAR') and v_coltype = 'NUMBER' then
            if ((i.fldedit  like '%YRE%' or i.fldedit  like '%YEAR%') and v_coltype = 'NUMBER') then
                obj_data.put('desnew',hcm_util.get_year_buddhist_era(i.desnew));
                obj_data.put('desold',hcm_util.get_year_buddhist_era(i.desold));
            end if;
            -->>User37 #2265 Final Test Phase 1 V11 24/03/2021 

            obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
            end if;--secure  User37 Final Test Phase 1 V11 #3046 09/11/2020
        END LOOP;
        --json_str_output := obj_row.to_clob;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTEMLOG1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    --<<User37 Final Test Phase 1 V11 #3046 09/11/2020
    elsif v_flgsecr = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'TTEMLOG1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    -->>User37 Final Test Phase 1 V11 #3046 09/11/2020
    else
      json_str_output := obj_row.to_clob;
    end if;

    EXCEPTION
    /*
        WHEN no_data_found THEN
    --param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTEMLOG1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    */
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END gen_data;

    PROCEDURE get_index (
        json_str_input    IN CLOB,
        json_str_output   OUT CLOB
    ) AS
        obj_row   json_object_t;
    BEGIN
        initial_value(json_str_input);
        check_getindex;
        IF param_msg_error IS NULL THEN
            gen_data(json_str_output);
        ELSE
            json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    FUNCTION get_description (
        p_table   IN VARCHAR2,
        p_field   IN VARCHAR2,
        p_code    IN VARCHAR2
    ) RETURN VARCHAR2 IS

        v_desc        VARCHAR2(4000) := p_code;
        v_stament     VARCHAR2(500);
        v_funcdesc    VARCHAR2(500);
        v_data_type   VARCHAR2(500);
    BEGIN
        IF p_code IS NULL THEN
            RETURN v_desc;
        END IF;

        BEGIN
            SELECT
                funcdesc,
                data_type
            INTO
                v_funcdesc,
                v_data_type
            FROM
                tcoldesc
            WHERE
                codtable = p_table
                AND codcolmn = p_field
                AND ROWNUM = 1;

        EXCEPTION
            WHEN no_data_found THEN
                v_funcdesc := NULL;
        END;
       IF v_funcdesc IS NOT NULL THEN
            --<<User37 Final Test Phase 1 V11 18/11/2020
            if v_funcdesc like '%HCM_UTIL.GET_YEAR_BUDDHIST_ERA%' then
                v_stament := 'select '
                             || v_funcdesc
                             || ' from dual';
                v_stament := replace(v_stament,'P_CODE',''''
                                                          || p_code
                                                          || '''');
                RETURN execute_desc(v_stament);
            else
                v_stament := 'select '
                             || v_funcdesc
                             || ' from dual';
                v_stament := replace(v_stament,'P_CODE',''''
                                                          || p_code
                                                          || '''');
                v_stament := replace(v_stament,'P_LANG','''' || global_v_lang||'''');
                RETURN execute_desc(v_stament);

            end if;
            /*v_stament := 'select '
                         || v_funcdesc
                         || ' from dual';
            v_stament := replace(v_stament,'P_CODE',''''
                                                      || p_code
                                                      || '''');
            v_stament := replace(v_stament,'P_LANG','''' || global_v_lang||'''');
            RETURN execute_desc(v_stament);*/
            -->>User37 Final Test Phase 1 V11 18/11/2020
        ELSE
            IF v_data_type = 'DATE' THEN
                if INSTR(v_desc,'/') > 0 then
                    v_desc := hcm_util.get_date_buddhist_era(TO_DATE(v_desc,'dd/mm/yyyy'));
					RETURN (v_desc);
                elsif INSTR(v_desc,'-') > 0 then
                    v_desc := hcm_util.get_date_buddhist_era(TO_DATE(SUBSTR(v_desc,1,10),'yyyy-mm-dd'));
					RETURN (v_desc);
                else
                    RETURN v_desc;
                end if;
            ELSE
                RETURN v_desc;
            END IF;
        END IF;

    END;

    FUNCTION get_date (
		p_date			IN VARCHAR2
		)			RETURN VARCHAR2 IS
	BEGIN
		if global_v_lang = 101 then
            RETURN p_date;
        end if;
        if global_v_lang = 102 then
            return TO_CHAR(TO_DATE(p_date,'dd/mm/yyyy'),'dd/mm/yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai');
        end if;
	END;

END HRPM9TX;

/
