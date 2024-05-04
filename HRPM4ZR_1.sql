--------------------------------------------------------
--  DDL for Package Body HRPM4ZR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4ZR" is

 PROCEDURE initial_value (
        json_str IN CLOB
    ) IS
        json_obj   json_object_t := json_object_t(json_str);
    BEGIN
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
        p_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_staupd := hcm_util.get_string_t(json_obj,'p_staupd');
        p_codcodec := hcm_util.get_string_t(json_obj,'p_codcodec');
        p_dtestr := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtestrt') ),'dd/mm/yyyy');

        p_dteend := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteend') ),'dd/mm/yyyy');

        if p_staupd = 'A' then
           p_staupd := null;
        end if;

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen)

        ;
    END initial_value;

    PROCEDURE initial_value_check (
        json_str IN CLOB
    ) IS
        json_obj   json_object_t := json_object_t(json_str);
    BEGIN
        p_codcomp_check := hcm_util.get_string_t(json_obj,'p_codcomp_check');
        p_codpos_check := hcm_util.get_string_t(json_obj,'p_codpos_check');
        p_codjob_check := hcm_util.get_string_t(json_obj,'p_codjob_check');
        p_numlvl_check := hcm_util.get_string_t(json_obj,'p_numlvl_check');
        p_codempmt_check := hcm_util.get_string_t(json_obj,'p_codempmt_check');
        p_typemp_check := hcm_util.get_string_t(json_obj,'p_typemp_check');
        p_typpayroll_check := hcm_util.get_string_t(json_obj,'p_typpayroll_check');
        p_codbrlc_check := hcm_util.get_string_t(json_obj,'p_codbrlc_check');
        p_flgatten_check := hcm_util.get_string_t(json_obj,'p_flgatten_check');
        p_codcalen_check := hcm_util.get_string_t(json_obj,'p_codcalen_check');
        p_codpunsh_check := hcm_util.get_string_t(json_obj,'p_codpunsh_check');
        p_codexemp_check := hcm_util.get_string_t(json_obj,'p_codexemp_check');
        p_jobgrade_check := hcm_util.get_string_t(json_obj,'p_jobgrade_check');
        p_codgrpgl_check := hcm_util.get_string_t(json_obj,'p_codgrpgl_check');
        p_amtincom1_check := hcm_util.get_string_t(json_obj,'p_amtincom1_check');
        p_amtincom2_check := hcm_util.get_string_t(json_obj,'p_amtincom2_check');
        p_amtincom3_check := hcm_util.get_string_t(json_obj,'p_amtincom3_check');
        p_amtincom4_check := hcm_util.get_string_t(json_obj,'p_amtincom4_check');
        p_amtincom5_check := hcm_util.get_string_t(json_obj,'p_amtincom5_check');
        p_amtincom6_check := hcm_util.get_string_t(json_obj,'p_amtincom6_check');
        p_amtincom7_check := hcm_util.get_string_t(json_obj,'p_amtincom7_check');
        p_amtincom8_check := hcm_util.get_string_t(json_obj,'p_amtincom8_check');
        p_amtincom9_check := hcm_util.get_string_t(json_obj,'p_amtincom9_check');
        p_amtincom10_check := hcm_util.get_string_t(json_obj,'p_amtincom10_check');
        p_length := hcm_util.get_string_t(json_obj,'p_length');
        p_list_value        := hcm_util.get_json_t(json_obj, 'p_listValue');
    END initial_value_check;

    procedure make_list_json is
      v_maxrcnt    number := 0;
      v_list_num   varchar2(4 char);
      v_list_num2   varchar2(4 char);
      begin
        obj_list := json_object_t();
        v_maxrcnt    := p_list_value.get_size;
         for i in 0..v_maxrcnt - 1 loop
           v_list_num  := hcm_util.get_string_t(p_list_value, to_char(i));
           obj_list.put(v_list_num,to_char(i) );
         end loop;
    end;

    PROCEDURE check_getindex IS
        v_codcomp         VARCHAR2(100);
        v_secur_codcomp   BOOLEAN;
    BEGIN

        IF TO_NUMBER(p_length) > 16 THEN
			param_msg_error := get_error_msg_php('HR2001',global_v_lang,'');
			return;
		END IF;

        IF p_codcomp IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
            return;
        END IF;

        IF p_dtestr IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestr');
            return;
        END IF;

        IF p_dteend IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
            return;
        END IF;

        IF p_dteend < p_dtestr THEN
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        END IF;

        IF p_codcodec IS NOT NULL THEN
            BEGIN
                SELECT
                    codcodec
                INTO v_codcodec
                FROM
                    tcodmove
                WHERE
                    codcodec = p_codcodec;

            EXCEPTION
                WHEN no_data_found THEN
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodmove');
                    return;
            END;
        END IF;

        v_secur_codcomp := secur_main.secur7(v_codcomp,global_v_coduser);
        IF v_secur_codcomp = false THEN  -- Check User authorize view codcomp
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
            return;
        END IF;

    END;

    PROCEDURE get_codincom IS
    BEGIN
        BEGIN
            SELECT
                codincom1,
                codincom2,
                codincom3,
                codincom4,
                codincom5,
                codincom6,
                codincom7,
                codincom8,
                codincom9,
                codincom10
            INTO
                v_codincom1,
                v_codincom2,
                v_codincom3,
                v_codincom4,
                v_codincom5,
                v_codincom6,
                v_codincom7,
                v_codincom8,
                v_codincom9,
                v_codincom10
            FROM
                tcontpms
            WHERE
                codcompy = p_codcomp
                AND dteeffec IN (
                    SELECT
                        MAX(dteeffec)
                    FROM
                        tcontpms
                    WHERE
                        codcompy = p_codcomp
                        AND dteeffec <= SYSDATE
                );

        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;
    END;

    PROCEDURE gen_field_name (
        json_str_output OUT CLOB
    ) IS

        CURSOR c_treport2 IS SELECT
                                numseq,
                                DECODE(global_v_lang,'101',nambrowe,'102',nambrowt,'103',nambrow3,'104',nambrow4,'105',nambrow5,nambrowe
                                ) nambrow
                            FROM
                                treport2
                            WHERE
                                codapp = 'HRPM4ZR'
                            ORDER BY
                                numseq;

        v_codpay   VARCHAR2(40);
        v_index    NUMBER;
    BEGIN
        obj_row := json_object_t ();
        obj_row1 := json_object_t ();
        obj_row2 := json_object_t ();
        obj_row3 := json_object_t ();
        obj_row4 := json_object_t ();
        obj_row.put('coderror','200');
        get_codincom ();
        v_index := 0;
        FOR i IN c_treport2 LOOP
            obj_data := json_object_t ();
            IF i.numseq BETWEEN 910 AND 100000 THEN
                IF i.numseq = 910 THEN
                    v_codpay := v_codincom1;
                ELSIF i.numseq = 920 THEN
                    v_codpay := v_codincom2;
                ELSIF i.numseq = 930 THEN
                    v_codpay := v_codincom3;
                ELSIF i.numseq = 940 THEN
                    v_codpay := v_codincom4;
                ELSIF i.numseq = 950 THEN
                    v_codpay := v_codincom5;
                ELSIF i.numseq = 960 THEN
                    v_codpay := v_codincom6;
                ELSIF i.numseq = 970 THEN
                    v_codpay := v_codincom7;
                ELSIF i.numseq = 980 THEN
                    v_codpay := v_codincom8;
                ELSIF i.numseq = 990 THEN
                    v_codpay := v_codincom9;
                ELSIF i.numseq = 10000 THEN
                    v_codpay := v_codincom10;
                END IF;

                IF v_codpay IS NOT NULL THEN
                    obj_data.put('listValue',i.numseq);
                    obj_data.put('listDesc',get_tinexinf_name(v_codpay,global_v_lang) );
                    v_index := v_index + 1;
                    obj_row2.put(TO_CHAR(v_index - 1),obj_data);
                ELSE
                    NULL;
                END IF;

            ELSE
                obj_data.put('listValue',i.numseq);
                obj_data.put('listDesc',i.nambrow);
                v_index := v_index + 1;
                obj_row2.put(TO_CHAR(v_index - 1),obj_data);
            END IF;

        END LOOP;

        obj_row1.put('rows',obj_row2);
        obj_row.put('listFields',obj_row1);
        obj_row3.put('rows',obj_row4);
        obj_row.put('formatFields',obj_row3);
        json_str_output := obj_row.to_clob;
    EXCEPTION
        WHEN no_data_found THEN
            obj_data := json_object_t ();
            obj_data.put('coderror','200');
            json_str_output := obj_data.to_clob;
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE gen_data (
        json_str_output OUT CLOB
    ) IS

        v_rcnt             NUMBER := 0;
        v_rcnt_main        NUMBER := 0;
        v_secur_codempid   BOOLEAN;

        --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
        v_secure           varchar2(1 char) := 'N';
        v_data             varchar2(2 char) := 'N';
        -->>User37 #4940 Final Test Phase 1 V11 24/02/2021

        CURSOR c_tcodmove IS SELECT
                                 codcodec,
                                 typmove
                             FROM
                                 tcodmove
                             WHERE
                                 codcodec LIKE nvl(p_codcodec,codcodec)
                              order by codcodec asc;

        c2                 SYS_REFCURSOR;
    BEGIN
        make_list_json;
        obj_main := json_object_t ();
        obj_main1 := json_object_t ();
        obj_main.put('coderror',200);
        v_rcnt := 0;
        v_rcnt_main := 0;

        v_param0 := hcm_util.get_string_t(obj_list,'10');
        v_param1 := hcm_util.get_string_t(obj_list,'20');
        v_param2 := hcm_util.get_string_t(obj_list,'30');
        v_param3 := hcm_util.get_string_t(obj_list,'40');
        v_param4 := hcm_util.get_string_t(obj_list,'50');
        v_param5 := hcm_util.get_string_t(obj_list,'60');
        v_param6 := hcm_util.get_string_t(obj_list,'70');
        v_param7 := hcm_util.get_string_t(obj_list,'80');
        v_param8 := hcm_util.get_string_t(obj_list,'90');
        v_param9 := hcm_util.get_string_t(obj_list,'100');
        v_param10 := hcm_util.get_string_t(obj_list,'110');
        v_param11 := hcm_util.get_string_t(obj_list,'120');
        v_param12 := hcm_util.get_string_t(obj_list,'130');
        v_param13 := hcm_util.get_string_t(obj_list,'140');
        v_param14 := hcm_util.get_string_t(obj_list,'910');
        v_param15 := hcm_util.get_string_t(obj_list,'920');
        v_param16 := hcm_util.get_string_t(obj_list,'930');
        v_param17 := hcm_util.get_string_t(obj_list,'940');
        v_param18 := hcm_util.get_string_t(obj_list,'950');
        v_param19 := hcm_util.get_string_t(obj_list,'960');
        v_param20 := hcm_util.get_string_t(obj_list,'970');
        v_param21 := hcm_util.get_string_t(obj_list,'980');
        v_param22 := hcm_util.get_string_t(obj_list,'990');
        v_param23 := hcm_util.get_string_t(obj_list,'1000');


        FOR i IN c_tcodmove LOOP
            obj_row := json_object_t ();
            IF ( i.codcodec = '0001' AND p_codcodec IS NULL ) OR p_codcodec = '0001' THEN
                v_rcnt := 0;
                obj_row := json_object_t ();
                OPEN c2 FOR SELECT
                                codcomp,
                                codpos,
                                codjob,
                                numlvl,
                                codempmt,
                                typemp,
                                typpayroll,
                                codbrlc,
                                flgatten,
                                codcalen,
                                NULL AS codpunsh,
                                NULL AS codexemp,
                                jobgrade,
                                codgrpgl,
                                stddec(amtincom1,codempid,v_chken),
                                stddec(amtincom2,codempid,v_chken),
                                stddec(amtincom3,codempid,v_chken),
                                stddec(amtincom4,codempid,v_chken),
                                stddec(amtincom5,codempid,v_chken),
                                stddec(amtincom6,codempid,v_chken),
                                stddec(amtincom7,codempid,v_chken),
                                stddec(amtincom8,codempid,v_chken),
                                stddec(amtincom9,codempid,v_chken),
                                stddec(amtincom10,codempid,v_chken),
                                codempid,
                                dteempmt AS dteeffec
                            FROM
                                ttnewemp
                            WHERE
                                codcomp like p_codcomp || '%'
                                AND dteempmt >= nvl(p_dtestr,dteempmt)
                                AND dteempmt <= nvl(p_dteend,dteempmt)
                            ORDER BY codcomp,codempid;

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_codjob,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_flgatten,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec;

                    EXIT WHEN c2%notfound;
                    IF true = true THEN
                    v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_rcnt := v_rcnt + 1;
                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                        IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if;--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;
                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttnewemp');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttnewemp');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode','0001');
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            ELSIF ( i.codcodec = '0002' AND p_codcodec IS NULL ) OR p_codcodec = '0002' THEN
                v_rcnt := 0;
                obj_row := json_object_t ();
                OPEN c2 FOR SELECT
                                codcomp,
                                codpos,
                                codjob,
                                numlvl,
                                codempmt,
                                typemp,
                                typpayroll,
                                codbrlc,
                                flgatten,
                                codcalen,
                                NULL AS codpunsh,
                                NULL AS codexemp,
                                jobgrade,
                                codgrpgl,
                                stddec(amtincom1,codempid,v_chken),
                                stddec(amtincom2,codempid,v_chken),
                                stddec(amtincom3,codempid,v_chken),
                                stddec(amtincom4,codempid,v_chken),
                                stddec(amtincom5,codempid,v_chken),
                                stddec(amtincom6,codempid,v_chken),
                                stddec(amtincom7,codempid,v_chken),
                                stddec(amtincom8,codempid,v_chken),
                                stddec(amtincom9,codempid,v_chken),
                                stddec(amtincom10,codempid,v_chken),
                                codempid,
                                dtereemp AS dteeffec
                            FROM
                                ttrehire
                            WHERE
                                codcomp LIKE p_codcomp || '%'
                                and staupd = nvl(p_staupd,staupd)
                                AND dtereemp >= nvl(p_dtestr,dtereemp)
                                AND dtereemp <= nvl(p_dteend,dtereemp)
                            ORDER BY codcomp,codempid;

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_codjob,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_flgatten,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec;

                    EXIT WHEN c2%notfound;
                    IF true = true THEN
                     v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                     v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_rcnt := v_rcnt + 1;
                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                        IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;
                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttrehire');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttrehire');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode','0002');
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            ELSIF ( i.codcodec = '0003' AND p_codcodec IS NULL ) OR p_codcodec = '0003' THEN
                v_rcnt := 0;
                obj_row := json_object_t ();
                OPEN c2 FOR SELECT
                                codcomp,
                                codpos,
                                numlvl,
                                codempmt,
                                typemp,
                                typpayroll,
                                codbrlc,
                                codcalen,
                                NULL AS codpunsh,
                                codexemp,
                                jobgrade,
                                codgrpgl,
                                stddec(amtincom1,codempid,v_chken),
                                stddec(amtincom2,codempid,v_chken),
                                stddec(amtincom3,codempid,v_chken),
                                stddec(amtincom4,codempid,v_chken),
                                stddec(amtincom5,codempid,v_chken),
                                stddec(amtincom6,codempid,v_chken),
                                stddec(amtincom7,codempid,v_chken),
                                stddec(amtincom8,codempid,v_chken),
                                stddec(amtincom9,codempid,v_chken),
                                stddec(amtincom10,codempid,v_chken),
                                codempid,
                                dteduepr AS dteeffec
                            FROM
                                ttprobat
                            WHERE
                                codcomp LIKE p_codcomp || '%'
                                and staupd = nvl(p_staupd,staupd)
                                AND dteduepr >= nvl(p_dtestr,dteduepr)
                                AND dteduepr <= nvl(p_dteend,dteduepr)
                            ORDER BY codcomp,codempid;

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec;

                    EXIT WHEN c2%notfound;
                    IF true = true THEN
                     v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                     v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        begin
                            select codjob,flgatten
                              into v_codjob,v_flgatten
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then
                            v_codjob    := null;
                            v_flgatten  := null;
                        end;


                        v_rcnt := v_rcnt + 1;
                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                        IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if;--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;
                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttprobat');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttprobat');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode','0003');
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            ELSIF ( i.codcodec = '0005' AND p_codcodec IS NULL ) OR p_codcodec = '0005' THEN
                v_rcnt := 0;
                obj_row := json_object_t ();
                --<<User37 #4949 Final Test Phase 1 V11 24/02/2021
                /*OPEN c2 FOR SELECT
                                a.codcomp,
                                a.codpos,
                                a.codjob,
                                a.numlvl,
                                a.codempmt,
                                a.typemp,
                                a.typpayroll,
                                NULL AS codbrlc,
                                NULL AS flgatten,
                                NULL AS codcalen,
                                NULL AS codpunsh,
                                NULL AS codexemp,
                                a.jobgrade,
                                a.codgrpgl,
                                NULL AS amtincom1,
                                NULL AS amtincom2,
                                NULL AS amtincom3,
                                NULL AS amtincom4,
                                NULL AS amtincom5,
                                NULL AS amtincom6,
                                NULL AS amtincom7,
                                NULL AS amtincom8,
                                NULL AS amtincom9,
                                NULL AS amtincom10,
                                codempid,
                                dteeffec
                            FROM
                                ttmistk a
                            WHERE
                                a.codcomp like p_codcomp || '%'
                                AND a.dteeffec >= nvl(p_dtestr,dteeffec)
                                AND a.dteeffec <= nvl(p_dteend,dteeffec)
                                and staupd = nvl(p_staupd,staupd)
                            UNION
                            SELECT
                                b.codcomp,
                                b.codpos,
                                b.codjob,
                                b.numlvl,
                                NULL AS codempmt,
                                NULL AS typemp,
                                NULL AS typpayroll,
                                NULL AS codbrlc,
                                NULL AS flgatten,
                                NULL AS codcalen,
                                NULL AS codpunsh,
                                NULL AS codexemp,
                                b.jobgrade,
                                NULL AS codgrpgl,
                                NULL AS amtincom1,
                                NULL AS amtincom2,
                                NULL AS amtincom3,
                                NULL AS amtincom4,
                                NULL AS amtincom5,
                                NULL AS amtincom6,
                                NULL AS amtincom7,
                                NULL AS amtincom8,
                                NULL AS amtincom9,
                                NULL AS amtincom10,
                                codempid,
                                dteeffec
                            FROM
                                ttpunsh b
                            WHERE
                                b.codcomp like p_codcomp || '%'
                                AND b.dteeffec >= nvl(p_dtestr,dteeffec)
                                AND b.dteeffec <= nvl(p_dteend,dteeffec);*/
                OPEN c2 FOR SELECT
                                a.codcomp,
                                a.codpos,
                                a.codjob,
                                a.numlvl,
                                a.codempmt,
                                a.typemp,
                                a.typpayroll,
                                NULL AS codbrlc,
                                NULL AS flgatten,
                                NULL AS codcalen,
                                b.codpunsh,
                                b.codexemp,
                                a.jobgrade,
                                a.codgrpgl,
                                NULL AS amtincom1,
                                NULL AS amtincom2,
                                NULL AS amtincom3,
                                NULL AS amtincom4,
                                NULL AS amtincom5,
                                NULL AS amtincom6,
                                NULL AS amtincom7,
                                NULL AS amtincom8,
                                NULL AS amtincom9,
                                NULL AS amtincom10,
                                a.codempid,
                                a.dteeffec
                            from ttmistk a, ttpunsh b
                            where a.codempid = b.codempid
                              and a.dteeffec = b.dteeffec
                              and a.codcomp like p_codcomp || '%'
                              and a.dteeffec >= nvl(p_dtestr,a.dteeffec)
                              and a.dteeffec <= nvl(p_dteend,a.dteeffec)
                              and a.staupd = nvl(p_staupd,a.staupd);
                -->>User37 #4949 Final Test Phase 1 V11 24/02/2021

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_codjob,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_flgatten,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec;

                    EXIT WHEN c2%notfound;
                    IF true = true THEN
                     v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                     v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        --<<User37 #4946 Final Test Phase 1 V11 24/02/2021
                        begin
                            select t1.flgatten,t1.codbrlc,t1.codcalen,
                                   stddec(t2.amtincom1,t2.codempid,v_chken),
                                   stddec(t2.amtincom2,t2.codempid,v_chken),
                                   stddec(t2.amtincom3,t2.codempid,v_chken),
                                   stddec(t2.amtincom4,t2.codempid,v_chken),
                                   stddec(t2.amtincom5,t2.codempid,v_chken),
                                   stddec(t2.amtincom6,t2.codempid,v_chken),
                                   stddec(t2.amtincom7,t2.codempid,v_chken),
                                   stddec(t2.amtincom8,t2.codempid,v_chken),
                                   stddec(t2.amtincom9,t2.codempid,v_chken),
                                   stddec(t2.amtincom10,t2.codempid,v_chken)
                              into v_flgatten,v_codbrlc,v_codcalen,
                                   v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                                   v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
                              from temploy1 t1, temploy3 t2
                             where t1.codempid = t2.codempid
                               and t1.codempid = v_codempid;
                        exception when no_data_found then
                            v_codjob    := null;
                            v_flgatten  := null;
                        end;
                        -->>User37 #4946 Final Test Phase 1 V11 24/02/2021

                        v_rcnt := v_rcnt + 1;
                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                       IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang)  );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang));
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang));
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if;--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;
                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpunsh');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpunsh');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode','0005');
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            ELSIF ( i.codcodec = '0006' AND p_codcodec IS NULL ) OR p_codcodec = '0006' THEN
                obj_row := json_object_t ();
                v_rcnt := 0;
                OPEN c2 FOR SELECT
                                codcomp,
                                codpos,
                                codjob,--User37 #4937 Final Test Phase 1 V11 24/02/2021 NULL AS codjob,
                                numlvl,
                                codempmt,
                                NULL AS typemp,
                                NULL AS typpayroll,
                                NULL AS codbrlc,
                                NULL AS flgatten,
                                NULL AS codcalen,
                                NULL AS codpunsh,
                                codexemp,
                                jobgrade,
                                NULL AS codgrpgl,
                                NULL AS amtincom1,
                                NULL AS amtincom2,
                                NULL AS amtincom3,
                                NULL AS amtincom4,
                                NULL AS amtincom5,
                                NULL AS amtincom6,
                                NULL AS amtincom7,
                                NULL AS amtincom8,
                                NULL AS amtincom9,
                                NULL AS amtincom10,
                                codempid,
                                dteeffec
                            FROM
                                ttexempt
                            WHERE
                                codcomp like p_codcomp || '%'
                                AND dteeffec >= nvl(p_dtestr,dteeffec)
                                AND dteeffec <= nvl(p_dteend,dteeffec)
                                and staupd = nvl(p_staupd,staupd)
                            order by codcomp,codempid;

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_codjob,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_flgatten,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec;

                    EXIT WHEN c2%notfound;
                    IF true = true THEN
                     v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                     v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        --<<User37 #4937 Final Test Phase 1 V11 24/02/2021
                        begin
                            select t1.flgatten,t1.typemp,t1.typpayroll,t1.codbrlc,t1.codcalen,t1.codgrpgl,
                                   stddec(t2.amtincom1,t2.codempid,v_chken),
                                   stddec(t2.amtincom2,t2.codempid,v_chken),
                                   stddec(t2.amtincom3,t2.codempid,v_chken),
                                   stddec(t2.amtincom4,t2.codempid,v_chken),
                                   stddec(t2.amtincom5,t2.codempid,v_chken),
                                   stddec(t2.amtincom6,t2.codempid,v_chken),
                                   stddec(t2.amtincom7,t2.codempid,v_chken),
                                   stddec(t2.amtincom8,t2.codempid,v_chken),
                                   stddec(t2.amtincom9,t2.codempid,v_chken),
                                   stddec(t2.amtincom10,t2.codempid,v_chken)
                              into v_flgatten,v_typemp,v_typpayroll,v_codbrlc,v_codcalen,v_codgrpgl,
                                   v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                                   v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
                              from temploy1 t1, temploy3 t2
                             where t1.codempid = t2.codempid
                               and t1.codempid = v_codempid;
                        exception when no_data_found then
                            v_codjob    := null;
                            v_flgatten  := null;
                        end;
                        -->>User37 #4937 Final Test Phase 1 V11 24/02/2021

                        v_rcnt := v_rcnt + 1;
                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                        IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if;--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;
                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpush');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpush');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode','0006');
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            ELSE
                obj_row := json_object_t ();
                v_rcnt  := 0;
                OPEN c2 FOR SELECT
                                codcomp,
                                codpos,
                                codjob,
                                numlvl,
                                codempmt,
                                typemp,
                                typpayroll,
                                codbrlc,
                                flgatten,
                                codcalen,
                                NULL AS codpunsh,
                                NULL AS codexemp,
                                jobgrade,
                                codgrpgl,
                                stddec(amtincom1,codempid,v_chken),
                                stddec(amtincom2,codempid,v_chken),
                                stddec(amtincom3,codempid,v_chken),
                                stddec(amtincom4,codempid,v_chken),
                                stddec(amtincom5,codempid,v_chken),
                                stddec(amtincom6,codempid,v_chken),
                                stddec(amtincom7,codempid,v_chken),
                                stddec(amtincom8,codempid,v_chken),
                                stddec(amtincom9,codempid,v_chken),
                                stddec(amtincom10,codempid,v_chken),
                                codempid,
                                dteeffec,
                                numseq--User37 #4951 Final Test Phase 1 V11 15/03/2021
                            FROM
                                ttmovemt
                            WHERE
                                codcomp like p_codcomp || '%'
                                AND dteeffec >= nvl(p_dtestr,dteeffec)
                                AND dteeffec <= nvl(p_dteend,dteeffec)
                                and staupd = nvl(p_staupd,staupd)
                                and codtrn = nvl(p_codcodec,i.codcodec)
                            ORDER BY codcomp,codempid;

                LOOP
                    FETCH c2 INTO
                        v_codcomp,
                        v_codpos,
                        v_codjob,
                        v_numlvl,
                        v_codempmt,
                        v_typemp,
                        v_typpayroll,
                        v_codbrlc,
                        v_flgatten,
                        v_codcalen,
                        v_codpunsh,
                        v_codexemp,
                        v_jobgrade,
                        v_codgrpgl,
                        v_amtincom1,
                        v_amtincom2,
                        v_amtincom3,
                        v_amtincom4,
                        v_amtincom5,
                        v_amtincom6,
                        v_amtincom7,
                        v_amtincom8,
                        v_amtincom9,
                        v_amtincom10,
                        v_codempid,
                        v_dteeffec,
                        v_numseq;--User37 #4951 Final Test Phase 1 V11 15/03/2021

                    EXIT WHEN c2%notfound;
                    v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal
                    );

                    IF true = true THEN
                     v_data := 'Y';--User37 #4940 Final Test Phase 1 V11 24/02/2021
                     v_secur_codempid := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); --user36 STT #935 18/05/2023 ||secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);

                        if v_secur_codempid then --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_secure := 'Y'; --User37 #4940 Final Test Phase 1 V11 24/02/2021
                        v_rcnt := v_rcnt + 1;

                        obj_data := json_object_t ();
                        obj_data.put('coderror','200');
                        IF v_param0 is not null THEN
                            obj_data.put('param'||v_param0,get_tcenter_name(v_codcomp,global_v_lang) );
                        END IF;

                        IF v_param1 is not null THEN
                            obj_data.put('param'||v_param1,get_tpostn_name(v_codpos,global_v_lang) );
                        END IF;

                        IF v_param2 is not null THEN
                            obj_data.put('param'||v_param2,get_tjobcode_name(v_codjob,global_v_lang) );
                        END IF;

                        IF v_param3 is not null THEN
                            obj_data.put('param'||v_param3,v_numlvl);
                        END IF;

                        IF v_param4 is not null THEN
                            obj_data.put('param'||v_param4,get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                        END IF;

                        IF v_param5 is not null THEN
                            obj_data.put('param'||v_param5,get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                        END IF;

                        IF v_param6 is not null THEN
                            obj_data.put('param'||v_param6,get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang) );
                        END IF;

                        IF v_param7 is not null THEN
                            obj_data.put('param'||v_param7,get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                        END IF;

                        IF v_param8 is not null THEN
                            obj_data.put('param'||v_param8,get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang));--User37 #4935 Final Test Phase 1 V11 24/02/2021 v_flgatten);
                        END IF;

                        IF v_param9 is not null THEN
                            obj_data.put('param'||v_param9,get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                        END IF;

                        IF v_param10 is not null THEN
                            obj_data.put('param'||v_param10,get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                        END IF;

                        IF v_param11 is not null THEN
                            obj_data.put('param'||v_param11,get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                        END IF;

                        IF v_param12 is not null THEN
                            obj_data.put('param'||v_param12,get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                        END IF;

                        IF v_param13 is not null THEN
                            obj_data.put('param'||v_param13,get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                        END IF;

                        IF v_param14 is not null THEN
                            if v_zupdsal = 'Y' then
                              v_amtincom1 := to_char(to_number(v_amtincom1),'fm999,999,999,990.00');
                            else
                              v_amtincom1 := '';
                            end if;
                            obj_data.put('param'||v_param14,v_amtincom1);
                        END IF;

                        IF v_param15 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom2 := to_char(to_number(v_amtincom2),'fm999,999,999,990.00');
                           else
                              v_amtincom2 := '';
                           end if;
                            obj_data.put('param'||v_param15,v_amtincom2);
                        END IF;

                        IF v_param16 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom3 := to_char(to_number(v_amtincom3),'fm999,999,999,990.00');
                           else
                              v_amtincom3 := '';
                           end if;
                            obj_data.put('param'||v_param16,v_amtincom3);
                        END IF;

                        IF v_param17 is not null THEN
                          if v_zupdsal = 'Y' then
                              v_amtincom4 := to_char(to_number(v_amtincom4),'fm999,999,999,990.00');
                          else
                              v_amtincom4 := '';
                          end if;
                            obj_data.put('param'||v_param17,v_amtincom4);
                        END IF;

                        IF v_param18 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom5 := to_char(to_number(v_amtincom5),'fm999,999,999,990.00');
                          else
                              v_amtincom5 := '';
                          end if;
                            obj_data.put('param'||v_param18,v_amtincom5);
                        END IF;

                        IF v_param19 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom6 := to_char(to_number(v_amtincom6),'fm999,999,999,990.00');
                           else
                              v_amtincom6 := '';
                           end if;
                            obj_data.put('param'||v_param19,v_amtincom6);
                        END IF;

                        IF v_param20 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom7 := to_char(to_number(v_amtincom7),'fm999,999,999,990.00');
                           else
                              v_amtincom7 := '';
                           end if;
                            obj_data.put('param'||v_param20,v_amtincom7);
                        END IF;

                        IF v_param21 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom8 := to_char(to_number(v_amtincom8),'fm999,999,999,990.00');
                           else
                              v_amtincom8 := '';
                           end if;
                            obj_data.put('param'||v_param21,v_amtincom8);
                        END IF;

                        IF v_param22 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom9 := to_char(to_number(v_amtincom9),'fm999,999,999,990.00');
                           else
                              v_amtincom9 := '';
                           end if;
                            obj_data.put('param'||v_param22,v_amtincom9);
                        END IF;

                        IF v_param23 is not null THEN
                           if v_zupdsal = 'Y' then
                              v_amtincom10 := to_char(to_number(v_amtincom10),'fm999,999,999,990.00');
                           else
                              v_amtincom10 := '';
                           end if;
                            obj_data.put('param'||v_param23,v_amtincom10);
                        END IF;

                        obj_data.put('image',get_emp_img(v_codempid));
                        obj_data.put('codempid',v_codempid);
                        obj_data.put('codcomp',v_codcomp);
                        obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                        obj_data.put('dteeffec',TO_CHAR(v_dteeffec,'dd/mm/yyyy') );
                        obj_data.put('numseq',to_char(v_numseq));--User37 #4951 Final Test Phase 1 V11 15/03/2021
                        obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                        end if;--User37 #4940 Final Test Phase 1 V11 24/02/2021
                    END IF;

                END LOOP;

                CLOSE c2;

                --<<User37 #4940 Final Test Phase 1 V11 24/02/2021
                /*IF v_rcnt = 0 THEN
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpush');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);*/
                if v_data = 'N' then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttmovemt');
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                elsif v_secure = 'N' then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    obj_row.put('coderror','400');
                    obj_row.put('response',param_msg_error);
                -->>User37 #4940 Final Test Phase 1 V11 24/02/2021
                else
                  if v_rcnt > 0 then
                      obj_row1 := json_object_t ();
                      obj_row1.put('codcode',nvl(p_codcodec,i.codcodec) );
                      obj_row1.put('rows',obj_row);
                      v_rcnt_main := v_rcnt_main + 1;
                      obj_main1.put(TO_CHAR(v_rcnt_main - 1),obj_row1);
                  end if;
                END IF;
            END IF;
        END LOOP;

        if v_rcnt_main = 0 then
           if p_codcodec is null then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttmovemt');
           end if;
           json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
          obj_main.put('detail',obj_main1);
          json_str_output := obj_main.to_clob;
        end if;

    EXCEPTION
        WHEN no_data_found THEN
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexe');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
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
    BEGIN
        initial_value(json_str_input);
        initial_value_check(json_str_input);
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

    PROCEDURE get_index_field_name (
        json_str_input    IN CLOB,
        json_str_output   OUT CLOB
    ) AS
    BEGIN
        param_msg_error := NULL;
        initial_value(json_str_input);
        check_getindex;
        IF param_msg_error IS NULL THEN
            gen_field_name(json_str_output);
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


END HRPM4ZR;

/
