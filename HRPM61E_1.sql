--------------------------------------------------------
--  DDL for Package Body HRPM61E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM61E" is
--user37 NXP-HR2101 18/11/2021-- last update: 18/11/2021 16:59 
 PROCEDURE initial_value ( json_str IN CLOB ) IS
        json_obj   json_object_t := json_object_t(json_str);
    BEGIN
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');
        p_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');
        p_stacaselw     := hcm_util.get_string_t(json_obj,'p_stacaselw');
        p_numcaselw     := hcm_util.get_string_t(json_obj,'p_numcaselw');
        p_codlegald     := hcm_util.get_string_t(json_obj,'p_codlegald');
        p_namlegalb     := hcm_util.get_string_t(json_obj,'p_namlegalb');
        p_namplntiff    := hcm_util.get_string_t(json_obj,'p_namplntiff');
        p_dtestr        := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtestrt') ),'dd/mm/yyyy');
        p_dteend        := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteend') ),'dd/mm/yyyy');

        p_dteyrded    := hcm_util.get_string_t(json_obj,'p_dteyrded');
        p_dtemthded   := hcm_util.get_string_t(json_obj,'p_dtemthded');
        p_numprdded   := hcm_util.get_string_t(json_obj,'p_numprdded');
        p_qtyperd     := hcm_util.get_string_t(json_obj,'p_qtyperd');
        p_amtfroze    := hcm_util.get_string_t(json_obj,'p_amtfroze');
        p_pctded_h    := hcm_util.get_string_t(json_obj,'p_pctded');
        p_amtmin      := hcm_util.get_string_t(json_obj,'p_amtmin');
        p_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');

        --<<user37 NXP-HR2101 18/11/2021 
        p_civillaw    := hcm_util.get_string_t(json_obj,'p_civillaw');
        p_banklaw     := upper(hcm_util.get_string_t(json_obj,'p_banklaw'));
        -->>user37 NXP-HR2101 18/11/2021 
        --<<user46 NXP-HR2101 20/12/2021 
        p_numbanklg   := hcm_util.get_string_t(json_obj,'p_numbanklg');
        p_numkeep     := upper(hcm_util.get_string_t(json_obj,'p_numkeep'));
        -->>user46 NXP-HR2101 20/12/2021 

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    END initial_value;

    PROCEDURE get_json_obj ( json_str_input IN CLOB ) IS
        json_obj   json_object_t := json_object_t(json_str_input);
    BEGIN
        p_legalexd    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str') );
    END get_json_obj;

    PROCEDURE get_legal_detail ( json_str_output OUT CLOB ) IS
        v_numcaselw        tlegalexe.numcaselw%TYPE;
        v_namplntiff       tlegalexe.namplntiff%TYPE;
        v_namlegalb        tlegalexe.namlegalb%TYPE;
        v_dtestrt          tlegalexe.dtestrt%TYPE;
        v_dteend           tlegalexe.dteend%TYPE;
        v_codlegald        tlegalexe.codlegald%TYPE;
        v_qtyperd          tlegalexe.qtyperd%TYPE;
        v_amtfroze         tlegalexe.amtfroze%TYPE;
        v_amtmin           tlegalexe.amtmin%TYPE;
        v_stacaselw        tlegalexe.stacaselw%TYPE;
        v_amtded           tlegalexe.amtded%TYPE;
        v_pctded           tlegalexe.pctded%TYPE;
        v_dteupd           tlegalexe.dteupd%TYPE;
        v_codcomp          tlegalexe.codcomp%TYPE;
        v_coduser          VARCHAR2(100);
        v_codlegald_desc   VARCHAR2(500);
        v_stacaselw_desc   VARCHAR2(500);
        v_image            tempimge.namimage%type;
        v_folder           tfolderd.folder%type;
        v_has_image        varchar2(1) := 'N';
        --<<user37 NXP-HR2101 18/11/2021 
        v_civillaw          tlegalexe.civillaw%TYPE;
        v_banklaw           tlegalexe.banklaw%TYPE;
        -->>user37 NXP-HR2101 18/11/2021 
        v_numbanklg         tlegalexe.numbanklg%TYPE;
        v_numkeep           tlegalexe.numkeep%TYPE;

    BEGIN
      begin
        select  dteupd,get_codempid(coduser),codlegald,get_tcodec_name('TCODLEGALD',codlegald,global_v_lang),
                numcaselw,namplntiff,namlegalb,dtestrt,dteend,
                qtyperd,amtfroze,amtmin,stacaselw,get_tlistval_name('STACASELW',stacaselw,global_v_lang),amtded,
                pctded,codcomp,
                civillaw,banklaw,--user37 NXP-HR2101 18/11/2021 
                numbanklg,numkeep --<< user46 NXP-HR2101 20/12/2021
        into    v_dteupd,v_coduser,v_codlegald,v_codlegald_desc,
                v_numcaselw,v_namplntiff,v_namlegalb,v_dtestrt,v_dteend,
                v_qtyperd,v_amtfroze,v_amtmin,v_stacaselw,v_stacaselw_desc,v_amtded,
                v_pctded,v_codcomp,
                v_civillaw,v_banklaw,--user37 NXP-HR2101 18/11/2021 
                v_numbanklg,v_numkeep
        from    tlegalexe
        where   codempid    = p_codempid
        and     numcaselw   = p_numcaselw;
      exception when no_data_found then
        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = p_codempid;
        end;
      end;
      IF v_stacaselw = 'C' THEN
          param_msg_error := get_error_msg_php('PM0094',global_v_lang,'');
          begin
              select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') into param_msg_error from dual;
          end;
--      elsif nvl(v_stacaselw,'P') = 'P' and stddec(v_amtded,p_codempid,v_chken) > 0 then
--            param_msg_error := get_error_msg_php('PM0117',global_v_lang,'');
--            begin
--              select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') into param_msg_error from dual;
--            end;
      END IF;
      begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image
          from tempimge
         where codempid = p_codempid;--User37 #1765 Final Test Phase 1 V11 31/03/2021 global_v_codempid;
      exception when no_data_found then
        v_image := null;
      end;
      if v_image is not null then
        v_image      := get_tsetup_value('PATHWORKPHP')||v_image;
        v_has_image   := 'Y';
      end if;
      if isInsertReport then
          --Report insert TTEMPRPT

          insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item5,item6,item7,item8,
                                        item9,item10,item11,item12,item13,item14,item15,item16,item17)
                               values (global_v_codempid, 'HRPM61E',v_numseq,'DETAIL',p_codempid,p_numcaselw,
                                      v_codlegald ||' - '|| v_codlegald_desc,
                                      v_namlegalb,
                                      v_namplntiff,
                                      to_char(add_months(to_date(to_char(v_dtestrt,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                      to_char(add_months(to_date(to_char(v_dteend,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                      v_qtyperd ||' '||get_label_name('HRPM61E2',global_v_lang,230),
                                      TRIM(to_char(stddec(v_amtfroze,p_codempid,v_chken), '999,999,990.00' )) ||' '||get_label_name('HRPM61E2',global_v_lang,240),
                                      TRIM(to_char(stddec(v_amtmin,p_codempid,v_chken), '999,999,990.00' )) ||' '||get_label_name('HRPM61E2',global_v_lang,240),
                                      v_stacaselw,
                                      get_temploy_name(p_codempid,global_v_lang),
                                      to_char(nvl(v_pctded,0),'fm990.00'),v_image,v_has_image );
          v_numseq := v_numseq + 1;
      else
            obj_data := json_object_t ();
            obj_data.put('coderror','200');
            obj_data.put('response',param_msg_error);
            obj_data.put('codempid',p_codempid);
            obj_data.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang) );
            obj_data.put('numcaselw',v_numcaselw);
            obj_data.put('codlegald',v_codlegald);
            obj_data.put('desc_codlegald',v_codlegald_desc);
            obj_data.put('namlegalb',v_namlegalb);
            obj_data.put('namplntiff',v_namplntiff);
            obj_data.put('dtestrt',TO_CHAR(v_dtestrt,'dd/mm/yyyy') );
            obj_data.put('dteend',TO_CHAR(v_dteend,'dd/mm/yyyy') );
            obj_data.put('dteupd',TO_CHAR(v_dteupd,'dd/mm/yyyy') );
            obj_data.put('stacaselw',v_stacaselw);
            obj_data.put('coduser',v_coduser);
            obj_data.put('desc_stacaselw',v_stacaselw_desc);
            obj_data.put('qtyperd',v_qtyperd);
            obj_data.put('amtfroze',stddec(v_amtfroze,p_codempid,v_chken));
            obj_data.put('amtmin',stddec(v_amtmin,p_codempid,v_chken));
            obj_data.put('pctded',v_pctded);
            obj_data.put('codcompy',hcm_util.get_codcomp_level(v_codcomp,1));
            --<<user37 NXP-HR2101 18/11/2021 
            obj_data.put('civillaw',v_civillaw);
            obj_data.put('banklaw',v_banklaw);
            -->>user37 NXP-HR2101 18/11/2021 
            if (nvl(v_stacaselw,'P') = 'P' and stddec(v_amtded,p_codempid,v_chken) > 0) then
              obj_data.put('flgupd','S');
            elsif (nvl(v_stacaselw,'P') = 'C') then
              obj_data.put('flgupd','N');
            else
              obj_data.put('flgupd','Y');
            end if;            
--            if (nvl(v_stacaselw,'P') = 'P' and stddec(v_amtded,p_codempid,v_chken) > 0) or (nvl(v_stacaselw,'P') = 'C')then
--              obj_data.put('flgupd','N');
--            else
--              obj_data.put('flgupd','Y');
--            end if;
            obj_data.put('numbanklg',v_numbanklg);
            obj_data.put('numkeep',v_numkeep);
        end if;

        json_str_output := obj_data.to_clob;
    EXCEPTION WHEN no_data_found THEN
        obj_data := json_object_t ();
        obj_data.put('coderror','200');
        json_str_output := obj_data.to_clob;
    WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE get_legal_detail_sub ( json_str_output OUT CLOB ) IS
        v_rcnt   NUMBER := 0;
        v_amtdmin number;
        CURSOR c_tlegalexd IS
        SELECT  codpay, get_tinexinf_name(codpay,global_v_lang) AS desc_codpay, pctded,
                stddec(amtdmin,codempid,v_chken) as amtdminec, dteupd, coduser,
                get_temploy_name(coduser,global_v_lang) AS codusername,
                amtdmin as amtdmin--User37 NXP-HR2101 #181 09/12/2021 
           FROM tlegalexd
          WHERE codempid = p_codempid
            AND numcaselw = p_numcaselw
          ORDER BY codpay;
    BEGIN
        obj_child_row := json_object_t ();
        FOR i IN c_tlegalexd LOOP
          --<<User37 NXP-HR2101 #181 09/12/2021 
          if i.amtdmin is null then
            v_amtdmin := null;
          else
            v_amtdmin := stddec(i.amtdmin,p_codempid,v_chken);
          end if;
          -->>User37 NXP-HR2101 #181 09/12/2021 
          if isInsertReport then
            --Report insert TTEMPRPT
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM5,ITEM6,ITEM7,ITEM8)
            VALUES (global_v_codempid, 'HRPM61E',v_numseq,'TABLE',p_codempid,p_numcaselw, i.codpay, i.desc_codpay, i.pctded, v_amtdmin);
            v_numseq := v_numseq + 1;
          else
            v_rcnt := v_rcnt + 1;
            obj_data := json_object_t ();
            obj_data.put('codpay',i.codpay);
            obj_data.put('codpay_hidden',i.codpay);
            obj_data.put('desc_codpay',i.desc_codpay);
            obj_data.put('pctded',i.pctded);
            obj_data.put('amtdmin',v_amtdmin);
            obj_data.put('dteupd',TO_CHAR(i.dteupd,'dd/mm/yyyy') );
            obj_data.put('coduser',i.coduser);
            obj_data.put('desc_coduser',i.codusername);
            obj_child_row.put(TO_CHAR(v_rcnt - 1),obj_data);
          end if;
        END LOOP;
        json_str_output := obj_child_row.to_clob;
    EXCEPTION WHEN no_data_found THEN
        obj_data := json_object_t ();
        obj_data.put('coderror','200');
        json_str_output := obj_data.to_clob;
    WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE check_getindex IS

        v_codcomp          VARCHAR2(100);
        v_codempid         VARCHAR2(100);
        v_codcomp_empid    VARCHAR2(100);
        v_numlvl           VARCHAR2(100);
        v_staemp           VARCHAR2(1);
        v_secur_codempid   BOOLEAN;
        v_secur_codcomp    BOOLEAN;
    BEGIN
        IF p_codcomp IS NULL AND p_codempid IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
            return;
        END IF;

        IF p_codcomp IS NOT NULL AND p_codempid IS NOT NULL THEN
            p_codcomp := '';
        END IF;

        IF p_codcomp IS NOT NULL AND p_codempid IS NULL THEN
            IF p_stacaselw IS NULL OR p_dtestr IS NULL then--User37 08/01/2021 #2354 Final Test Phase 1 V11 OR p_dteend IS NULL THEN
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            END IF;
        END IF;

        IF p_codcomp IS NOT NULL THEN
            BEGIN
                SELECT COUNT(*)
                INTO v_codcomp
                FROM tcenter
                WHERE codcomp LIKE p_codcomp || '%';
            EXCEPTION WHEN no_data_found THEN
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
              return;
            END;

            v_secur_codcomp := secur_main.secur7(p_codcomp || '%',global_v_coduser);
            IF v_secur_codcomp = false THEN
                param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
                return;
            END IF;

        END IF;

        IF p_codempid IS NOT NULL THEN
            BEGIN
                SELECT codempid, staemp, codcomp, numlvl
                INTO v_codempid, v_staemp, v_codcomp_empid, v_numlvl
                FROM temploy1
                WHERE codempid = p_codempid;
            EXCEPTION WHEN no_data_found THEN
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
              return;
            END;

            IF v_codcomp_empid IS NOT NULL AND v_numlvl IS NOT NULL THEN
                v_secur_codempid := secur_main.secur1(v_codcomp_empid,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen ,v_zupdsal);
                IF v_secur_codempid = false THEN
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang,v_codcomp_empid);
                    return;
                END IF;
            END IF;
            IF v_staemp = 0 THEN
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                return;
            END IF;
        END IF;
    END;
    PROCEDURE check_detail IS

        v_codcomp          VARCHAR2(100);
        v_codempid         VARCHAR2(100);
        v_codcomp_empid    VARCHAR2(100);
        v_numlvl           VARCHAR2(100);
        v_staemp           VARCHAR2(1);
        v_secur_codempid   BOOLEAN;
        v_secur_codcomp    BOOLEAN;
    BEGIN
        IF p_numcaselw IS NULL or p_codempid IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        END IF;

        IF p_codempid IS NOT NULL THEN
            BEGIN
                SELECT codempid, staemp, codcomp, numlvl
                INTO v_codempid, v_staemp, v_codcomp_empid, v_numlvl
                FROM temploy1
                WHERE codempid = p_codempid;
            EXCEPTION WHEN no_data_found THEN
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
                    return;
            END;
--                v_secur_codempid := secur_main.secur1(v_codcomp_empid,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen ,v_zupdsal);
            v_secur_codempid := secur_main.secur2(p_codempid, global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal);
            IF v_secur_codempid = false THEN
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            END IF;
            IF v_staemp = 0 THEN
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                return;
            END IF;
        END IF;
    END;

    PROCEDURE check_save IS
        v_count     NUMBER;
        v_coduser   VARCHAR2(100);
        v_dteempmt  temploy1.dteempmt%type;

    BEGIN
        IF p_codlegald IS NULL OR p_namplntiff IS NULL OR p_dtestr IS NULL OR
           p_qtyperd IS NULL OR p_amtfroze IS NULL OR p_amtmin IS NULL OR p_stacaselw IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM tcodlegald
        WHERE codcodec = p_codlegald;
        IF v_count = 0 THEN
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODLEGALD');
            return;
        END IF;

        --<<user37 NXP-HR2101 18/11/2021 
        if p_banklaw is not null then --<<user46 NXP-HR2101 20/12/2021
          SELECT COUNT(*) INTO v_count
          FROM tcodbank
          WHERE codcodec = p_banklaw;
          IF v_count = 0 THEN
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodbank');
              return;
          END IF;
        end if;
        -->>user37 NXP-HR2101 18/11/2021 

        BEGIN
            SELECT hcm_util.get_codcomp_level(codcomp, 1) , dteempmt
            INTO  p_codcompy, v_dteempmt
            FROM temploy1
            WHERE codempid = p_codempid;
        EXCEPTION WHEN OTHERS THEN
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                return;
        END;
        ---30/08/2523 < 01/09/2523
         IF p_dtestr <  v_dteempmt THEN
            param_msg_error := get_error_msg_php('PM0137',global_v_lang);
            return;
        END IF;
        FOR i IN 0..p_legalexd.get_size - 1 LOOP
            param_json_row := hcm_util.get_json_t(p_legalexd,TO_CHAR(i));
            p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
            p_codpay_hidden := hcm_util.get_string_t(param_json_row,'codpay_hidden');
            p_pctded        := to_number(hcm_util.get_string_t(param_json_row,'pctded') );
--            p_amtdmin := to_number(hcm_util.get_string_t(param_json_row,'amtdmin') );
            p_flg := hcm_util.get_string_t(param_json_row,'flg');
--            IF p_codpay IS NULL OR p_pctded IS NULL /*OR p_amtdmin IS NULL */THEN
--                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--                return;
--            END IF;

            v_count := 0;
            SELECT COUNT(*)
            INTO v_count
            FROM tinexinf
            WHERE codpay = p_codpay
            AND typpay IN ( '1', '2', '3' );

            IF v_count = 0 THEN
                param_msg_error := get_error_msg_php('PY0030',global_v_lang,'TINEXINF');
                return;
            END IF;

            BEGIN
                SELECT hcm_util.get_codcomp_level(codcomp, 1) , dteempmt
                INTO  p_codcompy, v_dteempmt
                FROM temploy1
                WHERE codempid = p_codempid;
            EXCEPTION WHEN OTHERS THEN
                    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                    return;
            END;
            ---30/08/2523 < 01/09/2523
--             IF p_dtestr <  v_dteempmt THEN
--                param_msg_error := get_error_msg_php('PM0137',global_v_lang);
--                return;
--            END IF;

            v_count := 0;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_count
                    FROM tinexinfc
                    WHERE codcompy = p_codcompy
                    AND codpay = p_codpay;
                EXCEPTION WHEN OTHERS THEN
                        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                        return;
                END;

            IF v_count = 0 THEN
                param_msg_error := get_error_msg_php('PY0044',global_v_lang,'TINDEXINFC');
                return;
            END IF;

            v_count := 0;
            IF p_flg = 'add' OR p_flg = 'edit' THEN
                BEGIN
                    SELECT COUNT(*)
                    INTO v_count
                    FROM tlegalexd
                    WHERE codempid = p_codempid
                    AND numcaselw = p_numcaselw
                    AND codpay = p_codpay;

                    IF v_count > 0 AND p_flg = 'add' THEN
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TLEGALEXD');
                        return;
                    END IF;

                    IF v_count > 0 AND p_flg = 'edit' AND p_codpay_hidden <> p_codpay THEN
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TLEGALEXD');
                        return;
                    END IF;

                EXCEPTION WHEN OTHERS THEN
                  param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                  return;
                END;
            END IF;
        END LOOP;
    END;

    PROCEDURE gen_data ( json_str_output OUT CLOB ) IS

        v_rcnt              NUMBER := 0;
        v_rcnt_found        NUMBER := 0;
        v_secur_codempid    BOOLEAN;
        v_flgsecur          BOOLEAN;
        v_image_path        varchar2(500);
        v_image_name        varchar2(500);

        CURSOR c_tlegalexe IS
          SELECT b.codempid, b.numcaselw, b.codlegald, b.namlegalb,
                 b.namplntiff, b.dtestrt, b.dteend, b.stacaselw,
                 get_tlistval_name('STACASELW',b.stacaselw,global_v_lang) AS desc_stacaselw,
                 a.numlvl, a.codcomp, b.amtded
          FROM   temploy1 a,
                 tlegalexe b
          WHERE  a.codempid = b.codempid
            AND  a.codempid = nvl(p_codempid,a.codempid)
            AND  a.codcomp LIKE p_codcomp||'%'
            AND  ((b.stacaselw = nvl(p_stacaselw,'A') ) or (nvl(p_stacaselw,'A') = 'A'))
            AND  ((dtestrt between nvl(p_dtestr,dtestrt) AND nvl(p_dteend,dtestrt)) or
                 (dteend between nvl(p_dtestr,dteend) AND nvl(p_dteend,dteend)) or
                 (nvl(p_dtestr,dtestrt) between dtestrt and dteend) or
                 (nvl(p_dteend,dteend) between dtestrt and dteend))
          ORDER BY CODEMPID;

    BEGIN
        obj_row := json_object_t ();
        v_image_path  := '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/';
        FOR i IN c_tlegalexe LOOP
            v_rcnt := v_rcnt + 1;
            IF ( p_codempid IS NULL OR p_codempid = '' ) THEN
                v_secur_codempid := secur_main.secur7(i.codcomp, global_v_coduser);
            ELSE
                v_secur_codempid := secur_main.secur1(hcm_util.get_codcomp_level(i.codcomp, 1),i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            END IF;

            IF v_secur_codempid THEN
                v_flgsecur := secur_main.secur2(i.codempid, global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, global_v_zupdsal);
                if v_flgsecur then
                  v_rcnt_found := v_rcnt_found + 1;
                  obj_data := json_object_t ();
                  obj_data.put('coderror','200');
                  v_image_name  := get_emp_img(i.codempid);
                  if v_image_name is not null then
                    obj_data.put('logo_image',v_image_path||v_image_name);
                  else
                    obj_data.put('logo_image','');
                  end if;
                  obj_data.put('image',nvl(get_emp_img(i.codempid),i.codempid));
                  obj_data.put('codempid',i.codempid);
                  obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
                  obj_data.put('numcaselw',i.numcaselw);
                  obj_data.put('codlegald',i.codlegald);
                  obj_data.put('namlegalb',i.namlegalb);
                  obj_data.put('namplntiff',i.namplntiff);
                  obj_data.put('dtestrt',TO_CHAR(i.dtestrt,'dd/mm/yyyy') );
                  obj_data.put('dteend',TO_CHAR(i.dteend,'dd/mm/yyyy') );
                  obj_data.put('stacaselw',i.stacaselw);
                  if (nvl(i.stacaselw,'P') = 'P' and stddec(i.amtded,i.codempid,v_chken) > 0) or (nvl(i.stacaselw,'P') = 'C')then
                    obj_data.put('flgupd','N');
                  else
                    obj_data.put('flgupd','Y');
                  end if;
                  obj_data.put('desc_stacaselw',i.desc_stacaselw);
                  obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
                end if;
            ELSE
                v_rcnt_found := 0;
            END IF;
        END LOOP;

--        IF v_rcnt_found = 0 AND v_rcnt <> 0 THEN
--            param_msg_error := get_error_msg_php('HR3007',global_v_lang,'TLEGALEXE');
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            return;
--        END IF;
        json_str_output := obj_row.to_clob;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END gen_data;

    PROCEDURE save_tlegalexe IS
        v_count    NUMBER;
        v_number   NUMBER;
        v_number2  varchar2(20 char);
        v_qtyperd  NUMBER;

    BEGIN
        IF param_msg_error IS NULL THEN
            BEGIN
                SELECT COUNT(*)
                INTO v_count
                FROM  tlegalexe
                WHERE codempid = p_codempid
                  AND numcaselw = p_numcaselw;
            EXCEPTION WHEN OTHERS THEN
                    v_count := 0;
            END;

            IF p_codcomp is null then
                begin
                    select codcomp
                    into p_codcomp
                    from temploy1
                    where codempid = p_codempid;
                exception when no_data_found then
                    p_codempid := null;
                end;
            end if;

            IF v_count = 0 THEN
                BEGIN
                  insert into tlegalexe (codempid,numcaselw,codcomp,codlegald,namlegalb,namplntiff,
                                         dtestrt,dteend,qtyperd,amtfroze,pctded,amtmin,stacaselw,
                                         dteyrded,dtemthded,numprdded,dtecreate,codcreate,
                                         civillaw,banklaw,--user37 NXP-HR2101 18/11/2021 
                                         numbanklg,numkeep)--user46 NXP-HR2101 20/12/2021
                                 values (p_codempid,p_numcaselw,p_codcomp,p_codlegald,p_namlegalb,p_namplntiff,
                                         p_dtestr,p_dteend,p_qtyperd,stdenc(p_amtfroze,p_codempid,v_chken),p_pctded_h,stdenc(p_amtmin,p_codempid,v_chken),p_stacaselw,
                                         p_dteyrded,p_dtemthded,p_numprdded,sysdate,global_v_coduser,
                                         p_civillaw,p_banklaw,--user37 NXP-HR2101 18/11/2021 
                                         p_numbanklg,p_numkeep);

                END;

            ELSE
                BEGIN
                   begin
                        SELECT qtyperded,qtyperd
                          INTO v_number, v_qtyperd
                          FROM tlegalexe
                         WHERE codempid = p_codempid
                           AND numcaselw = p_numcaselw;
                        exception when no_data_found then
                             v_number   := 0;
                             v_qtyperd  := 0;
                   end;

                    IF  v_qtyperd < nvl(v_number,0)   THEN
                        param_msg_error := get_error_msg_php('PM0095',global_v_lang,'tlegalexe');
                        return;
                    END IF;

                    IF v_number IS NOT NULL AND p_qtyperd < nvl(v_number,0)   THEN
                        param_msg_error := get_error_msg_php('PM0096',global_v_lang,'tlegalexe');
                        return;
                    END IF;

                    SELECT stddec(amtded,p_codempid,v_chken)
                    INTO v_number2
                    FROM tlegalexe
                    WHERE codempid = p_codempid
                    AND numcaselw = p_numcaselw;
/*
                    IF v_number2 IS NOT NULL AND v_number2 < stddec(p_amtmin,p_codempid,v_chken) THEN
                        param_msg_error := get_error_msg_php('PM0096',global_v_lang,'TLEGALEXE');
                        return;
                    END IF;

                    IF v_number > 0 AND stddec(p_amtfroze,p_codempid,v_chken) IS NOT NULL THEN
                        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLEGALEXE');
                    END IF;
*/
                    SELECT count(*)
                    INTO v_number
                    FROM tlegalexe
                    WHERE codempid = p_codempid
                    AND stacaselw = 'C'
                    AND numcaselw = p_numcaselw;

                    IF v_number > 0 THEN
                        param_msg_error := get_error_msg_php('PM0094',global_v_lang,'');
                        return;
                    END IF;

                    UPDATE tlegalexe
                    SET codcomp = p_codcomp,
                        codlegald = p_codlegald,
                        namlegalb = p_namlegalb,
                        namplntiff = p_namplntiff,
                        dtestrt = p_dtestr,
                        dteend = p_dteend,
                        amtfroze = stdenc(p_amtfroze,p_codempid,v_chken),
                        pctded = p_pctded_h,
                        amtmin = stdenc(p_amtmin,p_codempid,v_chken),
                        stacaselw = p_stacaselw,
                        -- << Adisak STD: when edit data not update dteyreded, dtemthded, numprdded -- 2023/01/27 12:08
                        -- dteyrded = p_dteyrded,
                        -- dtemthded = p_dtemthded,
                        -- numprdded = p_numprdded,
                        dteupd = SYSDATE,
                        coduser = global_v_coduser,
                        qtyperd = p_qtyperd,
                        --<<user37 NXP-HR2101 18/11/2021 
                        civillaw = p_civillaw,
                        banklaw = p_banklaw,
                        -->>user37 NXP-HR2101 18/11/2021 
                        --<<user46 NXP-HR2101 20/12/2021 
                        numbanklg = p_numbanklg,
                        numkeep = p_numkeep
                        -->>user46 NXP-HR2101 20/12/2021 
                    WHERE codempid = p_codempid
                    AND numcaselw = p_numcaselw;

                END;
            END IF;

        END IF;
    EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END;

    PROCEDURE save_tlegalexd IS
      v_amtdmin tlegalexd.amtdmin%type;--User37 NXP-HR2101 #181 09/12/2021 
    BEGIN
        IF param_msg_error IS NULL THEN
            --<<User37 NXP-HR2101 #181 09/12/2021 
            if p_amtdmin is null then
              v_amtdmin := null;
            else
              v_amtdmin := stdenc(p_amtdmin,p_codempid,v_chken);
            end if;
            -->>User37 NXP-HR2101 #181 09/12/2021 
            IF p_flg = 'add' THEN
                BEGIN
                  --<<User37 NXP-HR2101 #181 09/12/2021 
                  /*insert into tlegalexd (codempid,numcaselw,codpay,pctded,dtecreate,codcreate)
                       values (p_codempid,p_numcaselw,p_codpay,p_pctded,sysdate,global_v_coduser);*/
                  insert into tlegalexd (codempid,numcaselw,codpay,pctded,amtdmin,dtecreate,codcreate)
                       values (p_codempid,p_numcaselw,p_codpay,p_pctded,v_amtdmin,sysdate,global_v_coduser);
                  -->>User37 NXP-HR2101 #181 09/12/2021 
                END;
            ELSIF p_flg = 'edit' THEN
                BEGIN
                    UPDATE tlegalexd
                    SET pctded = p_pctded,
                        amtdmin = v_amtdmin,--User37 NXP-HR2101 #181 09/12/2021 
                        dteupd = SYSDATE,
                        coduser = global_v_coduser
                  WHERE codempid = p_codempid
                    AND numcaselw = p_numcaselw
                    AND codpay = p_codpay;

                END;
            ELSIF p_flg = 'delete' THEN
                BEGIN
                    DELETE FROM tlegalexd
                    WHERE codempid = p_codempid
                      AND numcaselw = p_numcaselw
                      AND codpay = p_codpay;
                END;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END;

    PROCEDURE get_index ( json_str_input    IN CLOB, json_str_output   OUT CLOB ) AS
    BEGIN
        initial_value(json_str_input);
        check_getindex;
        IF param_msg_error IS NULL THEN
            gen_data(json_str_output);
        ELSE
            json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE get_index_legal_detail ( json_str_input    IN CLOB, json_str_output   OUT CLOB ) AS
    BEGIN
        param_msg_error := NULL;
        initial_value(json_str_input);
        check_detail;
        IF param_msg_error IS NULL THEN
            get_legal_detail(json_str_output);
        ELSE
            json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE get_index_legal_detail_sub ( json_str_input    IN CLOB, json_str_output   OUT CLOB ) AS
    BEGIN
        param_msg_error := NULL;
        initial_value(json_str_input);
        check_detail;
        IF param_msg_error IS NULL THEN
            get_legal_detail_sub(json_str_output);
        ELSE
            json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE save_data ( json_str_input    IN CLOB, json_str_output   OUT CLOB ) IS
        param_json_row   json_object_t;
    BEGIN
        initial_value(json_str_input);
        get_json_obj(json_str_input);
        check_save;
        IF param_msg_error IS NULL THEN
            save_tlegalexe;
            FOR i IN 0..p_legalexd.get_size - 1 LOOP
                param_json_row  := hcm_util.get_json_t(p_legalexd,TO_CHAR(i));
                p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
                p_pctded        := to_number(hcm_util.get_string_t(param_json_row,'pctded') );
                p_amtdmin        := to_number(hcm_util.get_string_t(param_json_row,'amtdmin') );--User37 NXP-HR2101 #181 09/12/2021 
                p_flg           := hcm_util.get_string_t(param_json_row,'flg');
                save_tlegalexd;
            END LOOP;

            IF param_msg_error IS NULL THEN
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                COMMIT;
            ELSE
                ROLLBACK;
            END IF;
        END IF;

        json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
    EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    PROCEDURE delete_index ( json_str_input    IN CLOB, json_str_output   OUT CLOB ) IS
        param_json_row   json_object_t;
        json_obj   json_object_t;
        param_json   json_object_t;
    BEGIN
        initial_value(json_str_input);
        json_obj           := json_object_t(json_str_input);
        param_json          := json_object_t();
        param_json          := json_object_t(hcm_util.get_string_t(json_obj,'json_input_str'));
        param_msg_error     := NULL;

        IF param_msg_error IS NULL THEN
            FOR i IN 0..param_json.get_size - 1 LOOP
                param_json_row := hcm_util.get_json_t(param_json,TO_CHAR(i) );
                p_numcaselw := hcm_util.get_string_t(param_json_row,'numcaselw');
                p_stacaselw := hcm_util.get_string_t(param_json_row,'stacaselw');
                p_codempid := hcm_util.get_string_t(param_json_row,'codempid');

                IF p_stacaselw = 'C' THEN
                    param_msg_error := get_error_msg_php('PM0094',global_v_lang,'');
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
                END IF;
                BEGIN
                    DELETE FROM tlegalexd
                    WHERE
                        codempid = p_codempid
                        AND numcaselw = p_numcaselw;

                    DELETE FROM tlegalexe
                    WHERE
                        codempid = p_codempid
                        AND numcaselw = p_numcaselw;
                END;
            END LOOP;
            COMMIT;
        END IF;
        IF param_msg_error IS NULL THEN
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
        COMMIT;
        json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' '|| dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

  procedure initial_report(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str);
        v_chken             := hcm_secur.get_v_chken;
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		json_codshift       := hcm_util.get_json_t(json_obj, 'p_codshift');

        json_numcaselw  := hcm_util.get_json_t(json_obj, 'p_numcaselw');
	end initial_report;

	procedure gen_report(json_str_input in clob,json_str_output out clob) is
		json_output clob;
	begin
		initial_report(json_str_input);
		isInsertReport := true;
        numYearReport := HCM_APPSETTINGS.get_additional_year();

		if param_msg_error is null then
			clear_ttemprpt;

			for i in 0..json_codshift.get_size-1 loop
				p_codempid := hcm_util.get_string_t(json_codshift, to_char(i));
                p_numcaselw := hcm_util.get_string_t(json_numcaselw, to_char(i));

                get_legal_detail(json_str_output);
                get_legal_detail_sub(json_str_output);

              commit;
			end loop;

		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;


	procedure clear_ttemprpt is
	begin
		begin
			delete
			from ttemprpt
			where codempid = global_v_codempid
			and codapp = 'HRPM61E';
		exception when others then
			null;
		end;
	end clear_ttemprpt;

  procedure get_codpay_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
    --      select  codpay,decode(global_v_lang,'101',descpaye,
--                                          '102',descpayt,
--                                          '103',descpay3,
--                                          '104',descpay4,
--                                          '105',descpay5) desc_codpay
--        from  tinexinf
--       where  typpay in ('1','2','3')
--         and  codpay in (select codpay from TINEXINFC where codcompy = p_codcompy)
--         and  codpay not in (select codpay
--                               from tcontpms t1
--                              where codcompy = p_codcompy
--                                and instr('|'||codincom1||'|'||codincom2||'|'||codincom3||'|'||codincom4||'|'||codincom5||'|'||codincom6||'|'||codincom7||'|'||codincom8||'|'||codincom9||'|'||codincom10||'|', '|'||codpay||'|') > 0
--                                and dteeffec = (select max(dteeffec)
--                                                  from tcontpms t2
--                                                 where t2.codcompy = p_codcompy
--                                                   and t2.dteeffec <= trunc(sysdate)))
--        order by  codpay;

        --<< wanlapa #753 15/02/2023
        select  codpay,decode(global_v_lang,'101',descpaye,
                                          '102',descpayt,
                                          '103',descpay3,
                                          '104',descpay4,
                                          '105',descpay5) desc_codpay
        from  tinexinf
        where  typpay in ('1','2','3')
         and  codpay in (select codpay from TINEXINFC where codcompy = p_codcompy)
         and  codpay not in (select codincom1 from tcontpms
                             where codcompy = p_codcompy
                             and dteeffec = (select max(dteeffec)
                                             from tcontpms t2
                                             where t2.codcompy = p_codcompy
                                             and t2.dteeffec <= trunc(sysdate)))
        order by  codpay;
        -- wanlapa #753 15/02/2023
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpay',i.codpay);
      obj_data.put('desc_codpay',i.desc_codpay);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpay_all;

END HRPM61E;

/
