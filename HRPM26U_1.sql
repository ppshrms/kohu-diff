--------------------------------------------------------
--  DDL for Package Body HRPM26U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM26U" AS
    PROCEDURE initial_value ( json_str IN CLOB ) IS
        json_obj json_object_t;
    BEGIN
        json_obj            := json_object_t(json_str);
        global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
        global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
        p_codcomp           := hcm_util.get_string_t(json_obj, 'codcomp');
        p_codmov            := hcm_util.get_string_t(json_obj, 'codmov');
        p_dtestr            := TO_DATE(hcm_util.get_string_t(json_obj, 'dtestr'), 'dd/mm/yyyy');
        p_dteend            := TO_DATE(hcm_util.get_string_t(json_obj, 'dteend'), 'dd/mm/yyyy');
        p_codcompindex      := substr(hcm_util.get_string_t(json_obj, 'p_codcompindex'), 1, 3);

        p_codempid          := hcm_util.get_string_t(json_obj, 'codempid');
        p_codempmt          := hcm_util.get_string_t(json_obj, 'codempmt');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    END initial_value;

    PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
    BEGIN
        initial_value(json_str_input);
        IF ( p_codcomp IS NULL OR p_codmov IS NULL OR p_dtestr IS NULL OR p_dteend IS NULL ) THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            json_str_output := get_response_message('403', param_msg_error, global_v_lang);
            return;
        ELSIF ( p_dtestr > p_dteend ) THEN
            param_msg_error := get_error_msg_php('HR2021', global_v_lang);
            json_str_output := get_response_message('403', param_msg_error, global_v_lang);
            return;
        END IF;

        gen_index(json_str_output);
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_index;

    PROCEDURE gen_index ( json_str_output OUT CLOB ) IS
        obj_row      json_object_t;
        obj_data     json_object_t;
        v_rcnt       NUMBER;
        v_flgpass    BOOLEAN;
        v_empcodpos  temploy1.codpos%type;
        v_empcodcomp temploy1.codcomp%type;
        v_stmt       varchar2(4000 char);
        v_descond    varchar2(4000 char);
        v_cursor_id  integer;
        v_flgfound	 boolean;

        v_approvno  ttrehire.approvno%type;
        v_check     varchar2(500 char);
        CURSOR datarows IS
            SELECT a.*
              FROM ttrehire a, temploy1 b
             WHERE a.codempid = b.codempid
               AND a.codcomp LIKE p_codcomp || '%'
               AND (a.staupd = 'P' OR a.staupd = 'A')
               AND ( a.flgmove = p_codmov OR p_codmov = 'A' )
               AND a.dtereemp BETWEEN p_dtestr AND p_dteend
          ORDER BY a.codempid,
                   a.dtereemp;

--        CURSOR emp_codition IS
--            SELECT d.numseq, d.syncond
--              FROM ttrehire a, tfwmaile b, tfwmailh c, tfwmailc d
--             WHERE a.codcomp LIKE p_codcomp || '%'
--               AND (a.staupd = 'P' OR a.staupd = 'A')
--               AND b.codapp = c.codapp
--               AND b.codapp = d.codapp
--               AND b.numseq = d.numseq
--               AND c.codappap = 'HRPM26U'
--               AND (a.flgmove = p_codmov OR p_codmov = 'A' )
--               AND ((b.flgappr = 'E' and b.codempap = global_v_codempid)
--                     OR (b.flgappr = 'D' and b.codcompap = v_empcodcomp AND b.codposap = v_empcodpos))
--                     AND nvl(a.approvno,0)+1  = b.seqno
--               AND a.dtereemp BETWEEN p_dtestr AND p_dteend
--          GROUP BY d.numseq, d.syncond
--          ORDER BY d.numseq;

    BEGIN
        BEGIN
            SELECT codpos, codcomp
              INTO v_empcodpos, v_empcodcomp
              FROM temploy1
             WHERE codempid = global_v_codempid;
        EXCEPTION WHEN no_data_found THEN
            v_empcodpos     := NULL;
            v_empcodcomp    := NULL;
        END;

        if not chk_flowmail.check_codappr ('HRPM21E', global_v_codempid) then
            param_msg_error := get_error_msg_php('HR3008', global_v_lang,'tfwmailc');
            json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
        else

            obj_row := json_object_t();
            v_rcnt  := 0;

            FOR r1 IN datarows LOOP
                v_flgfound := true;
                v_approvno := nvl(r1.approvno,0) + 1;
                v_flgpass := chk_flowmail.check_approve('HRPM21E', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
--                FOR r2 IN emp_codition LOOP
--                    v_stmt      := ' select codempid from temploy1 where codempid = ''' || r1.codempid || '''';
--                    v_descond   := r2.syncond;
--
--                    v_descond   := replace(v_descond,'TEMPLOY1.CODCOMP',''''||r1.CODCOMP||'''');
--                    v_descond   := replace(v_descond,'TEMPLOY1.CODPOS',''''||r1.CODPOS||'''');
--                    v_descond   := replace(v_descond,'TEMPLOY1.NUMLVL',r1.NUMLVL);
--                    v_descond   := replace(v_descond,'TEMPLOY1.CODEMPMT',''''||r1.CODEMPMT||'''');
--                    v_descond   := replace(v_descond,'TEMPLOY1.TYPEMP',''''||r1.TYPEMP||'''');
--                    v_descond   := replace(v_descond,'TEMPLOY1.CODEMPID',''''||r1.codempid||'''');
--                    v_stmt      := 'select count(*) from dual where '||v_descond;
--                    v_flgfound  := execute_stmt(v_stmt);
--                    if v_flgfound then
--                        exit;
--                    end if;
--                END LOOP;
               --test if  1=1 then
                if v_flgfound AND v_flgpass then
                    obj_data    := json_object_t();
                    v_rcnt      := v_rcnt + 1;
                    obj_data.put('index_codempid', r1.codempid);
                    obj_data.put('index_dtereemp', TO_CHAR(r1.dtereemp, 'dd/mm/yyyy'));
                    obj_data.put('dtereemp', TO_CHAR(r1.dtereemp, 'dd/mm/yyyy'));
                    obj_data.put('codempid', r1.codempid);
                    obj_data.put('codnewid', r1.codnewid);
                    obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
                    obj_data.put('numreqst', r1.numreqst);
                    obj_data.put('namcentt', get_tcenter_name(r1.codcomp, global_v_lang));
                    obj_data.put('flgmove', r1.flgmove);
                    obj_data.put('desc_flgmove', get_tlistval_name('TYPREHIRE', r1.flgmove, global_v_lang));
                    obj_data.put('staupd', get_tlistval_name('STAUPD', r1.staupd, global_v_lang));
                    obj_data.put('codcomp', r1.codcomp);
                    obj_data.put('codpos', r1.codpos);
                    obj_data.put('coderror', '200');
                    obj_data.put('rownumber', v_rcnt);
                    obj_data.put('last_approvno', nvl(r1.approvno,0));
                    obj_data.put('last_dteappr', TO_CHAR(r1.dteappr, 'DD/MM/YYYY'));
                    obj_data.put('flgappr', v_flgpass);
                    obj_row.put(TO_CHAR(v_rcnt), obj_data);
                END IF;
            END LOOP;

            json_str_output := obj_row.to_clob;
        end if;

    END gen_index;

    PROCEDURE getupdate ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
        obj_row          json_object_t;
        obj_data         json_object_t;
        v_rcnt           NUMBER;
        p_codcomp        ttrehire.codcomp%TYPE;
        p_codpos         ttrehire.codpos%TYPE;
        idp              ttrehire.codempid%TYPE;
        p_params         json_object_t;
        flag             VARCHAR(1 CHAR);
        notapprove       ttrehire.remarkap%TYPE;
        approve          ttrehire.remarkap%TYPE;
        dateja           VARCHAR(20 CHAR);
        obj_data_obj     VARCHAR(1000);
        obj              json_object_t;
        index_codempid   ttrehire.codempid%TYPE;
        index_dtereemp   ttrehire.dtereemp%TYPE;
        v_msg_to         clob;
        v_template_to    clob;
        v_func_appr      tfwmailh.codappap%type;
        rowidmail        VARCHAR2(50);
        tp_numseq        NUMBER;
        v_codtrn         tcodmove.codcodec%TYPE;
        v_staemp         ttrehire.staemp%TYPE;
        v_codcomp        ttrehire.codcomp%TYPE;
        v_codpos         ttrehire.codpos%TYPE;
        v_codjob         ttrehire.codjob%TYPE;
        v_numlvl         ttrehire.numlvl%TYPE;
        v_codempmt       ttrehire.codempmt%TYPE;
        v_codcalen       ttrehire.codcalen%TYPE;
        v_codbrlc        ttrehire.codbrlc%TYPE;
        v_jobgrade       ttrehire.jobgrade%type;
        v_typpayroll     ttrehire.typpayroll%TYPE;
        v_typemp         ttrehire.typemp%TYPE;
        v_flgatten       ttrehire.flgatten%TYPE;
        v_checkapp       boolean := false;
        v_check          varchar2(500 char);
        v_approvno       number;
        v_error          varchar2(4000 char);
		v_error_cc       varchar2(4000 char);
        p_codreq        temploy1.codempid%type;
        v_codnewid       ttrehire.codnewid%type;
    BEGIN
        initial_value(json_str_input);

        obj_data    := json_object_t(json_str_input);
        notapprove  := hcm_util.get_string_t(obj_data, 'notApprove');
        approve     := hcm_util.get_string_t(obj_data, 'approve');
        dateja      := TO_DATE(hcm_util.get_string_t(obj_data, 'date'), 'dd/mm/yyyy');
        p_params    := hcm_util.get_json_t(obj_data,'dataRows');
        obj_row     := json_object_t();
        v_rcnt      := 0;
        FOR i IN 0..p_params.get_size - 1 LOOP
            obj_row         := json_object_t();
            obj_row         := hcm_util.get_json_t(p_params,TO_CHAR(i));
            idp             := hcm_util.get_string_t(obj_row, 'codempid');
            flag            := hcm_util.get_string_t(obj_row, 'flgStaappr');
            p_codcomp       := hcm_util.get_string_t(obj_row, 'codcomp');
            p_codpos        := hcm_util.get_string_t(obj_row, 'codpos');
            index_codempid  := hcm_util.get_string_t(obj_row, 'index_codempid');
            index_dtereemp  := TO_DATE(hcm_util.get_string_t(obj_row, 'index_dtereemp'), 'dd/mm/yyyy');

            BEGIN
                SELECT staemp, codcomp, codpos, codjob,
                       numlvl, codempmt, codcalen, codbrlc, typpayroll,
                       typemp, flgatten, nvl(approvno,0) + 1, jobgrade,codnewid
                  INTO v_staemp, v_codcomp, v_codpos, v_codjob,
                       v_numlvl, v_codempmt, v_codcalen, v_codbrlc, v_typpayroll,
                       v_typemp, v_flgatten, v_approvno, v_jobgrade ,v_codnewid
                  FROM ttrehire
                 WHERE codempid = index_codempid
                   AND dtereemp = index_dtereemp;
            EXCEPTION WHEN no_data_found THEN
                NULL;
            END;

            v_checkapp := chk_flowmail.check_approve ('HRPM21E', idp, v_approvno, global_v_codempid, v_codcomp, v_codpos, v_check);
            if v_checkapp then
                BEGIN
                    IF ( flag = 'N' ) THEN
                        UPDATE ttrehire
                           SET staupd = 'N',
                               dteappr = dateja,
                               remarkap = notapprove,
                               codappr = global_v_codempid,
                               coduser = global_v_coduser,
                               approvno = v_approvno
                         WHERE codempid = index_codempid
                           AND dtereemp = index_dtereemp;

                           INSERT INTO TAPMOVMT(CODAPP, CODEMPID, DTEEFFEC, NUMSEQ, APPROVNO,
                                                CODAPPR, DTEAPPR, STAAPPR, REMARK, DTECREATE, CODCREATE, CODUSER)
                           VALUES ('HRPM21E', index_codempid, index_dtereemp, 1, v_approvno,
                                    global_v_codempid, dateja, 'N', notapprove, sysdate, global_v_coduser, global_v_coduser);
                        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
                    END IF;

                    IF ( flag = 'A' ) THEN
                        BEGIN
                            SELECT codcodec
                              INTO v_codtrn
                              FROM tcodmove
                             WHERE typmove = '2'
                               AND ROWNUM = 1;
                        EXCEPTION WHEN no_data_found THEN
                            NULL;
                        END;
                        --Chai 21/02/2023
                        v_codnewid := nvl(v_codnewid,index_codempid) ;
                        BEGIN
                            SELECT MAX(numseq)
                              INTO tp_numseq
                              FROM ttpminf
                             WHERE codempid = v_codnewid --index_codempid
                               AND dteeffec = index_dtereemp;
                        EXCEPTION WHEN no_data_found THEN
                            tp_numseq := NULL;
                        END;

                        tp_numseq := nvl(tp_numseq, 0) + 1;
                        INSERT INTO ttpminf ( codempid, dteeffec, numseq, codtrn, codcomp,
                                              codpos, codjob, numlvl, codempmt, codcalen,
                                              codbrlc, typpayroll, typemp, flgatten, flgal,
                                              flgrp, flgap, flgbf, flgtr, flgpy,
                                              dteupd, coduser, staemp, jobgrade)
                             --VALUES ( index_codempid, index_dtereemp, tp_numseq, v_codtrn, v_codcomp,
                             VALUES ( v_codnewid, index_dtereemp, tp_numseq, v_codtrn, v_codcomp,

                                      v_codpos, v_codjob, v_numlvl, v_codempmt, v_codcalen,
                                      v_codbrlc, v_typpayroll, v_typemp, v_flgatten, 'N',
                                      'N', 'N', 'N', 'N', 'N',
                                      trunc(SYSDATE), global_v_coduser, v_staemp, v_jobgrade );

                        BEGIN
                            SELECT ROWID,get_codempid(codcreate)
                              INTO rowidmail,p_codreq
                              FROM ttrehire
                             WHERE codempid = index_codempid
                               AND dtereemp = index_dtereemp;
                        END;
                        BEGIN
                            if v_check = 'Y' then
                                UPDATE ttrehire
                                   SET staupd = 'C',
                                       dteappr = dateja,
                                       remarkap = approve,
                                       codappr = global_v_codempid,
                                       coduser = global_v_coduser,
                                       approvno = v_approvno
                                 WHERE codempid = index_codempid
                                   AND dtereemp = index_dtereemp;
                              param_msg_error := get_error_msg_php('HR2401', global_v_lang);
                            elsif v_check = 'N' then
                                UPDATE ttrehire
                                   SET staupd = 'A',
                                       dteappr = dateja,
                                       remarkap = approve,
                                       codappr = global_v_codempid,
                                       coduser = global_v_coduser,
                                       approvno = v_approvno
                                 WHERE codempid = index_codempid
                                   AND dtereemp = index_dtereemp;
                            end if;

                            begin
                              INSERT INTO TAPMOVMT(CODAPP, CODEMPID, DTEEFFEC, NUMSEQ, APPROVNO,
                                                   CODAPPR, DTEAPPR, STAAPPR, REMARK, DTECREATE, CODCREATE, CODUSER)
                              VALUES ('HRPM21E', index_codempid, index_dtereemp,1, v_approvno,
                                      global_v_codempid, dateja, 'Y', approve,sysdate,global_v_coduser,global_v_coduser);
                            exception when dup_val_on_index then null;
                            end;

                            v_error_cc := chk_flowmail.send_mail_reply('HRPM26U', idp, p_codreq , global_v_codempid, global_v_coduser, null, 'HRPM26U2', 520, 'U', flag, v_approvno, null, null, 'TTREHIRE', rowidmail, '1', null);

                            if v_checkapp AND v_check = 'N'  AND flag <> 'N' then
                                v_error := chk_flowmail.send_mail_for_approve('HRPM21E', idp, global_v_codempid, global_v_coduser, null, 'HRPM26U2', 510, 'U', flag, v_approvno + 1 , null, null,'TTREHIRE', rowidmail, '1', null);
                            END IF;
                        EXCEPTION WHEN OTHERS THEN
                            rollback;
                        END;
                    END IF;
                END;
            else
                if v_check = 'HR2010' then
                  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
                  ROLLBACK;
                  json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
                  return;
                else
                  param_msg_error := get_error_msg_php('HR3008', global_v_lang);
                  ROLLBACK;
                  json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
                  return;
                end if;
            end if;
        END LOOP;
        COMMIT;
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        json_str_output := get_response_message('200', param_msg_error, global_v_lang);
--        json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
        return;
    END getupdate;

    PROCEDURE get_detail ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
        json_obj json_object_t;
    BEGIN
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        detail_codempid := hcm_util.get_string_t(json_obj, 'p_codempidindex');
        gen_detail(json_str_output);
    END get_detail;

    PROCEDURE gen_detail ( json_str_output OUT CLOB ) IS
        v_rcnt              NUMBER;
        obj_row             json_object_t;
        obj_data            json_object_t;
        v_yearnow           NUMBER;
        v_monthnow          NUMBER;
        v_yearbirth         NUMBER;
        v_monthbirth        NUMBER;
        obj_row2            json_object_t;
        global_v_chken		varchar2(10 char) := hcm_secur.get_v_chken;
        TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        v_amtincom          p_num;
        v_datasal           CLOB;
        obj_sum             json_object_t;
        v_numoffid          temploy2.numoffid%TYPE;
        v_findemp           NUMBER;
        flg_data            BOOLEAN := false;
        codincom_codempmt   VARCHAR(50);
        datenow             VARCHAR(50);
        param_json          json_object_t;
        obj_rowsal          json_object_t;
        param_json_row      json_object_t;
        v_codincom          tinexinf.codpay%TYPE;
        v_desincom          tinexinf.descpaye%TYPE;
        cnt_row             NUMBER := 0;
        v_desunit           VARCHAR2(150 CHAR);
        v_amtmax            NUMBER;
        v_row               NUMBER := 0;
        obj_data_salary     json_object_t;
        v_codempmt          ttrehire.codempmt%type;
        v_codcomp           ttrehire.codcomp%type;
        v_amtothr_income     NUMBER;
        v_amtday_income      NUMBER;
        v_sumincom_income    NUMBER;
        flgsecur            boolean;

      CURSOR tbdata IS
        SELECT a.*, a.dteduepr - a.dtereemp daytest
          FROM ttrehire a
         WHERE codempid = detail_codempid;
    BEGIN
        SELECT numoffid
          INTO v_numoffid
          FROM temploy2
         WHERE codempid = detail_codempid;

        SELECT COUNT(*)
          INTO v_findemp
          FROM tbcklst
         WHERE numoffid = v_numoffid;

        obj_row := json_object_t();
        v_rcnt := 0;

        flgsecur := secur_main.secur2(detail_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        FOR r1 IN tbdata LOOP
            obj_data := json_object_t();
            flg_data := true;
            obj_data.put('coderror', '200');
            obj_data.put('daytest', r1.daytest);
            obj_data.put('flgmov', r1.flgmove);
            obj_data.put('codempmt', r1.codempmt);
            obj_data.put('codcurr', r1.codcurr);
            obj_data.put('datetrans', TO_CHAR(r1.dtereemp, 'dd/mm/yyyy'));
            obj_data.put('department', r1.codpos);
            obj_data.put('flgtaemp', r1.staemp);
            obj_data.put('glcode', r1.codgrpgl);
            obj_data.put('groupemp', r1.codcalen);
            obj_data.put('jobdes', r1.codjob);
            obj_data.put('jobgrade', r1.jobgrade);
            obj_data.put('typpayroll', r1.typpayroll);
            obj_data.put('location', r1.codbrlc);
            obj_data.put('lving', r1.numlvl);
            obj_data.put('namrhir', r1.flgreemp);
            obj_data.put('namstamp', r1.typemp);
            obj_data.put('newcodempid', r1.codnewid);
            obj_data.put('operator', r1.codsend);
            obj_data.put('position', r1.codcomp);
            obj_data.put('refnumber', r1.numreqst);
            obj_data.put('savetime', r1.flgatten);
            obj_data.put('keycodempid', r1.codempid);
            obj_data.put('approvno', r1.approvno);
            obj_data.put('idp', r1.codempid);
            obj_data.put('codexemp', r1.codexemp);
            obj_data.put('v_zupdsal', v_zupdsal);
            v_rcnt := v_rcnt + 1;
            obj_row.put(0, obj_data);
        END LOOP;

        IF NOT flg_data THEN
            obj_data    := json_object_t();
            obj_row     := json_object_t();
            v_rcnt      := 1;
            obj_data.put('keycodempid', detail_codempid);
            obj_data.put('v_zupdsal', v_zupdsal);
            obj_row.put(0, obj_data);
        END IF;

        SELECT TO_CHAR(SYSDATE, 'DDMMYYYY')
          INTO datenow
          FROM dual;

        BEGIN
            SELECT codempmt
              INTO codincom_codempmt
              FROM temploy1
             WHERE codempid = detail_codempid;
        EXCEPTION WHEN no_data_found THEN
            p_codcompindex      := NULL;
            codincom_codempmt   := 'M';
        END;

        COMMIT;

        SELECT hcm_pm.get_codincom('{"p_codcompy":''' || p_codcompindex
                                   || ''',"p_dteeffec":''' || null
                                   || ''',"p_codempmt":''' || codincom_codempmt
                                   || ''',"p_lang":''' || global_v_lang
                                   || '''}')
          INTO v_datasal
          FROM dual;

        param_json := json_object_t(v_datasal);
        obj_rowsal := json_object_t();
        FOR i IN 0..param_json.get_size - 1 LOOP
            param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
            v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
            IF v_desincom IS NULL OR v_desincom = ' ' THEN
                EXIT;
            ELSE
                cnt_row := cnt_row + 1;
            END IF;
        END LOOP;

        BEGIN
            SELECT codempmt, hcm_util.get_codcomp_level(codcomp, 1), stddec(amtincom1, codempid, global_v_chken),
                   stddec(amtincom2, codempid, global_v_chken), stddec(amtincom3, codempid, global_v_chken), stddec(amtincom4, codempid, global_v_chken),
                   stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken), stddec(amtincom7, codempid, global_v_chken),
                   stddec(amtincom8, codempid, global_v_chken), stddec(amtincom9, codempid, global_v_chken), stddec(amtincom10, codempid, global_v_chken)
              INTO v_codempmt, v_codcomp, v_amtincom(1),
                   v_amtincom(2), v_amtincom(3), v_amtincom(4),
                   v_amtincom(5), v_amtincom(6), v_amtincom(7),
                   v_amtincom(8), v_amtincom(9), v_amtincom(10)
              FROM ttrehire
             WHERE codempid = detail_codempid;
        EXCEPTION WHEN no_data_found THEN
            FOR i IN 1..10 LOOP
                v_amtincom(i) := 0;
            END LOOP;
        END;

        FOR i IN 0..cnt_row - 1 LOOP
            param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
            v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
            v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
            IF v_codincom IS NULL OR v_codincom = ' ' THEN
                EXIT;
            END IF;
            v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
            v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
            v_row           := v_row + 1;
            obj_data_salary := json_object_t();
            obj_data_salary.put('coderror', '200');
            obj_data_salary.put('codincom', v_codincom);
            obj_data_salary.put('desincom', v_desincom);
            obj_data_salary.put('desunit', v_desunit);
            obj_data_salary.put('amtmax', trim(TO_CHAR(v_amtincom(i + 1), '999,999,990.00')));
            obj_rowsal.put(v_row, obj_data_salary);
        END LOOP;

        get_wage_income(v_codcomp, v_codempmt, v_amtincom(1), v_amtincom(2), v_amtincom(3), v_amtincom(4),
                        v_amtincom(5), v_amtincom(6), v_amtincom(7), v_amtincom(8), v_amtincom(9), v_amtincom(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_sum := json_object_t();
        obj_sum.put('t1', obj_data);
        obj_sum.put('t2', obj_rowsal);
        obj_sum.put('v_amtothr_income', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
        obj_sum.put('v_amtday_income', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
        obj_sum.put('v_sumincom_income', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        obj_sum.put('response', param_msg_error);
        obj_sum.put('coderror', '200');
        json_str_output := obj_sum.to_clob;
    END gen_detail;
END hrpm26u;

/
