--------------------------------------------------------
--  DDL for Package Body HRPM32U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM32U" IS
--31/03/2022 17:00
	PROCEDURE initial_value ( json_str IN CLOB ) IS
		json_obj		json_object_t;
	BEGIN
		json_obj            := json_object_t(json_str);
		global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
		pa_codempid         := hcm_util.get_string_t(json_obj, 'pa_codempid');
		pa_dtestr           := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'pa_dtestr')), 'dd/mm/yyyy');
		pa_dteend           := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'pa_dteend')), 'dd/mm/yyyy');

		pa_codcomp          := hcm_util.get_string_t(json_obj, 'pa_codcomp');
		flag_ga             := hcm_util.get_string_t(json_obj, 'flag_ga');

		p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
		p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		p_dtestr            := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dtestr')), 'dd/mm/yyyy');
		p_dteend            := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteend')), 'dd/mm/yyyy');
		p_dteduepr          := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteduepr')), 'dd/mm/yyyy');
        p_typproba          := hcm_util.get_string_t(json_obj, 'p_typproba');
        p_numseq           := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
        p_dteeffec          := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteeffec')), 'dd/mm/yyyy');
		hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
	END;

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN
		initial_value(json_str_input);
		IF ( p_codempid_query IS NULL AND p_codcomp IS NULL ) THEN
			param_msg_error := get_error_msg_php('HR2045', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		ELSIF ( p_codempid_query IS NOT NULL AND p_codcomp IS NOT NULL ) THEN
			pa_codcomp := '';
			return;
		ELSIF ( p_codcomp IS NOT NULL AND ( p_dtestr IS NULL OR p_dteend IS NULL ) ) THEN
			param_msg_error := get_error_msg_php('HR2045', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		ELSIF ( p_dtestr > p_dteend ) THEN
			param_msg_error := get_error_msg_php('HR2021', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

		IF param_msg_error IS NULL THEN
			gen_index(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

    PROCEDURE gen_index ( json_str_output OUT CLOB ) AS
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			NUMBER := 0;
		v_qtyasg		NUMBER := 0;
		v_approvno		ttprobat.approvno%type;
		v_data          VARCHAR(1);
		v_secur         VARCHAR(1);
		p_avg_avascore  number;
		v_flgpass		BOOLEAN;
        v_check         varchar2(500 char);
		v_dtestrt		DATE;
        v_count         number;--user37 #5171 Final Test Phase 1 V11 25/02/2021
        v_codrespr       ttprobat.codrespr%type;--nut

		CURSOR c_ttprobat IS
            SELECT ttprobat.*,decode(STAUPD,'C','Y',STAUPD) staappr
              FROM ttprobat
             WHERE codcomp LIKE p_codcomp || '%'
               AND codempid = nvl(p_codempid_query, codempid)
               AND staupd in ('P','A')
               AND dteduepr BETWEEN nvl(p_dtestr, dteduepr) AND nvl(p_dteend, dteduepr)
          ORDER BY codcomp,
                   codempid;
	BEGIN
		obj_row     := json_object_t();
		obj_data    := json_object_t();
		v_rcnt      := 0;
        v_data      := 'N';
		FOR r1 IN c_ttprobat LOOP
			BEGIN
				SELECT COUNT(*)
				  INTO v_qtyasg
				  FROM tproasgn
				 WHERE r1.codcomp LIKE codcomp || '%'
                   AND r1.codpos LIKE codpos
                   AND r1.codempid LIKE codempid
                   AND typproba = r1.typproba;

			EXCEPTION
			WHEN no_data_found THEN
				v_qtyasg := 0;
			END;
            v_approvno := nvl(r1.approvno,0) + 1;
            v_flgpass := chk_flowmail.check_approve('HRPM31E', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
            v_data := 'Y';
            if v_flgpass then
                v_rcnt := v_rcnt + 1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codpos', r1.codpos);
                obj_data.put('image', get_emp_img(r1.codempid));
                obj_data.put('codempid', r1.codempid);
                obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
                obj_data.put('typproba', r1.typproba);
                obj_data.put('desc_typproba', get_tlistval_name('NAMTPRO', r1.typproba, global_v_lang));
                BEGIN
                    SELECT dteempmt
                      INTO v_dtestrt
                      FROM temploy1
                     WHERE codempid = r1.codempid;
                EXCEPTION
                WHEN no_data_found THEN
                    v_dtestrt := NULL;
                END;

                --<<user37 #5171 Final Test Phase 1 V11 26/02/2021
                begin
                    select count(*)
                      into v_count
                      from tappbath
                     where codempid = r1.codempid
                       and dteduepr = r1.dteduepr
                       and numtime = (select max(numtime)
                                        from tappbath
                                       where codempid = r1.codempid
                                         and dteduepr = r1.dteduepr);
                exception when no_data_found then
                    v_count := 0;
                end;
                -->>user37 #5171 Final Test Phase 1 V11 26/02/2021
                obj_data.put('dtestrt', TO_CHAR(v_dtestrt, 'dd/mm/yyyy'));
                obj_data.put('dteduepr', TO_CHAR(r1.dteduepr, 'dd/mm/yyyy'));
                obj_data.put('avascore',  to_char(r1.avascore,'fm990.00'));--User37 #5188 Final Test Phase 1 V11 26/02/2021 r1.avascore);
                --<<User37 #5577 Final Test Phase 1 V11 25/03/2021
                    begin
                        select codrespr
                          into v_codrespr
                          from tapprobat
                         where codempid = r1.codempid
                           and dteduepr = r1.dteduepr
                           and approvno = (select max(approvno)
                                             from tapprobat
                                            where codempid = r1.codempid
                                              and dteduepr = r1.dteduepr);
                    exception when no_data_found then
                     v_codrespr := null;
                    end;
--                    obj_data.put('codrespr', v_codrespr);
                    obj_data.put('codrespr', nvl(v_codrespr,r1.codrespr));
                    obj_data.put('desc_codrespr', get_tlistval_name('NAMEVAL', nvl(v_codrespr,r1.codrespr), global_v_lang));
                --obj_data.put('codrespr', r1.codrespr);
                --obj_data.put('desc_codrespr', get_tlistval_name('NAMEVAL', r1.codrespr, global_v_lang));
                -->>User37 #5577 Final Test Phase 1 V11 25/03/2021
                obj_data.put('numseq', v_count);--user37 #5171 Final Test Phase 1 V11 25/02/2021 nvl(r1.approvno,0));
                obj_data.put('staupd', get_tlistval_name('STAAPPR', r1.staappr, global_v_lang));
                obj_row.put(TO_CHAR(v_rcnt - 1), obj_data);
            end if;
		END LOOP;
        if v_data = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
			json_str_output := get_response_message(403,param_msg_error,global_v_lang);
			return;
        elsif (v_rcnt = 0) then
			param_msg_error := get_error_msg_php('HR3008',global_v_lang);
			json_str_output := get_response_message(403,param_msg_error,global_v_lang);
			return;
		end if;
		json_str_output := obj_row.to_clob;
	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack
		|| ' '
		|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE get_popupinfo ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN
		initial_value(json_str_input);
		IF ( p_codempid_query IS NULL or p_dteduepr IS NULL ) THEN
			param_msg_error := get_error_msg_php('HR2045', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

		IF param_msg_error IS NULL THEN
			gen_popupinfo(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE gen_popupinfo ( json_str_output OUT CLOB ) AS
		obj_data		json_object_t;
		obj_row			json_object_t;
        v_count_numseq  number;
        v_last_dteeval  tappbath.dteeval%type;
        v_rcnt          number;

      cursor c_ttprobatd is
        select *
          from ttprobatd
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
      order by numtime;

	BEGIN
        obj_row     := json_object_t();
		v_rcnt      := 0;

        for r_ttprobatd in c_ttprobatd loop
            obj_data          := json_object_t();

            select count(*), max(dteeval)
              into v_count_numseq, v_last_dteeval
              from tappbath
             where codempid = p_codempid_query
               and dteduepr = p_dteduepr
               and numtime = r_ttprobatd.numtime;

            v_rcnt := v_rcnt + 1;
            obj_data.put('coderror', 200);
            obj_data.put('codempid', r_ttprobatd.codempid);
            obj_data.put('dteduepr', to_char(r_ttprobatd.dteduepr,'dd/mm/yyyy'));
            obj_data.put('numtime', r_ttprobatd.numtime);
            obj_data.put('avgscor', to_char(r_ttprobatd.avgscor,'fm990.00'));--User37 #5188 Final Test Phase 1 V11 26/02/2021 r_ttprobatd.avgscor);
            obj_data.put('codrespr', r_ttprobatd.codrespr);
            obj_data.put('desc_codrespr', get_tlistval_name('CODRESPR', r_ttprobatd.codrespr, global_v_lang));
            obj_data.put('count_numseq', v_count_numseq);
            obj_data.put('last_dteeval', to_char(v_last_dteeval,'dd/mm/yyyy'));
            obj_row.put(to_char(v_rcnt-1), obj_data); -- leave
        end loop;
		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE savedetail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		json_obj		        json_object_t;
        p_detail_obj            json_object_t;
        p_tab1_obj              json_object_t;
        p_tab2_obj              json_object_t;
        p_tab2_detail           json_object_t;
        p_tab2_table            json_object_t;
        datasal_row             json_object_t;

        p_codrespr		        ttprobat.codrespr%TYPE;
        p_dteoccup		        ttprobat.dteoccup%type;
        p_dteeffex              ttprobat.dteeffec%type;
        p_codexemp		        ttprobat.codexemp%TYPE;
        p_flgrepos              ttprobat.flgrepos%TYPE;
        p_flgssm		        ttprobat.flgssm%TYPE;
        p_flgblist		        ttprobat.flgblist%TYPE;
        p_qtyexpand		        ttprobat.qtyexpand%TYPE;
        p_desnote		        ttprobat.desnote%TYPE;

        p_codcomp               tapprobat.codcomp%type;
        p_codpos                tapprobat.codpos%type;
        v_dteexpand             date;
        v_staappr               tapprobat.staappr%type;

        TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom            p_num;
        sal_amtincadj           p_num;
        sal_amt                 p_num;
        sal_amtmax              p_num;
        TYPE p_cod IS TABLE OF varchar2(10) INDEX BY BINARY_INTEGER;
        sal_codincom            p_cod;
        v_flgadjin              ttprobat.flgadjin%type := 'N';
        v_amtinmth              number;
        v_amtindte              number;
        v_amtinhr               number;
        v_amtinadmth            number;
        v_amtinaddte            number;
        v_amtinadhr             number;
        v_staupd                ttprobat.staupd%type; -- สถานะข้อมูล (P-รอการพิจรณา,  N-ไม่อนุมัติ, M-ทดลองงานต่อ,  C-อนุมัติ , U-ประมวลผลแล้ว)
        v_approvno2             ttprobat.approvno%type;
        v_flgpass               BOOLEAN;
        v_check                 varchar2(500 char);

        v_typpayroll            tfincadj.typpayroll%type;
        v_codempmt              tfincadj.codempmt%type;

        v_codfrm_to             tfwmailh.codform%TYPE;
        v_msg_to                clob;
        v_template_to           clob;
        v_func_appr             tfwmailh.codappap%type;
        rowidmail               rowid;
        v_error                 varchar2(4000 char);
        v_error_cc              varchar2(4000 char);
        v_codadjin              tfincadj.codadjin%type;
        v_numseq                tfincadj.numseq%type;
	BEGIN
        initial_value(json_str_input);
		json_obj                := json_object_t(json_str_input);

        p_detail_obj            := hcm_util.get_json_t(json_obj, 'detail');
        p_tab1_obj              := hcm_util.get_json_t(json_obj, 'tab1');
        p_tab2_obj              := hcm_util.get_json_t(json_obj, 'tab2');
        p_tab2_detail           := hcm_util.get_json_t(p_tab2_obj, 'detail');
        p_tab2_table            := hcm_util.get_json_t(hcm_util.get_json_t(p_tab2_obj, 'table'), 'rows');
        -- tab1
        p_codempid_query        := hcm_util.get_string_t(p_tab1_obj, 'codempid');
        p_dteduepr              := TO_DATE(hcm_util.get_string_t(p_tab1_obj, 'dteduepr'), 'dd/mm/yyyy');
        p_codrespr              := hcm_util.get_string_t(p_tab1_obj, 'codrespr'); -- ผลการทดลองงาน (P-ผ่าน, N-ไม่ผ่าน, E-ขยายทดลองงาน)
        p_dteoccup              := TO_DATE(hcm_util.get_string_t(p_tab1_obj, 'dteoccup'), 'dd/mm/yyyy');
        p_dteeffex              := TO_DATE(hcm_util.get_string_t(p_tab1_obj, 'dteeffex'), 'dd/mm/yyyy');
        p_codexemp              := hcm_util.get_string_t(p_tab1_obj, 'codexemp');
        p_flgrepos              := hcm_util.get_string_t(p_tab1_obj, 'flgrepos');
        p_flgssm                := hcm_util.get_string_t(p_tab1_obj, 'flgssm');
        p_flgblist              := hcm_util.get_string_t(p_tab1_obj, 'flgblist');
        p_desnote               := hcm_util.get_string_t(p_tab1_obj, 'desnote');
        p_qtyexpand             := to_number(hcm_util.get_string_t(p_tab1_obj, 'qtyexpand'));
        p_typproba              := hcm_util.get_string_t(p_tab1_obj, 'typproba');
        p_codcomp               := hcm_util.get_string_t(p_tab1_obj, 'codcomp');
        p_codpos                := hcm_util.get_string_t(p_tab1_obj, 'codpos');
        FOR i IN 1..10 LOOP
            sal_amtincom(i)     := 0;
            sal_amtincadj(i)    := 0;
            sal_amt(i)          := 0;
            sal_codincom(i)     := '';
        END LOOP;

        FOR i IN 0..p_tab2_table.get_size - 1 LOOP
            datasal_row             := hcm_util.get_json_t(p_tab2_table, TO_CHAR(i));
            sal_codincom(i+1)       := hcm_util.get_string_t(datasal_row, 'codincom');
            sal_amtincom(i+1)       := to_number(hcm_util.get_string_t(datasal_row, 'amtincom'));
            sal_amtincadj(i+1)      := to_number(hcm_util.get_string_t(datasal_row, 'amtincadj'));
            sal_amt(i+1)            := to_number(hcm_util.get_string_t(datasal_row, 'amount'));
            sal_amtmax(i+1)         := to_number(hcm_util.get_string_t(datasal_row, 'amtmax'));
            if sal_amt(i+1) > sal_amtmax(i+1) then
                param_msg_error := get_error_msg_php('PM0066', global_v_lang);
                json_str_output := get_response_message('403', param_msg_error, global_v_lang);
                return;
            end if;
            if sal_amtincom(i+1) <> sal_amt(i+1) then
                v_flgadjin   := 'Y';
            end if;
        END LOOP;

        FOR i IN 1..10 LOOP
            if sal_amtincom(i) is null then
                sal_amtincom(i) := 0;
            end if;

            if sal_amtincadj(i) is null then
                sal_amtincadj(i) := 0;
            end if;

            if sal_amt(i) is null then
                sal_amt(i) := 0;
            end if;
        END LOOP;

        if p_typproba = '1' and p_codrespr in ('N','E') then
            v_flgadjin := 'N';
        end if;

        if v_flgadjin = 'N' then
            FOR i IN 1..10 LOOP
                sal_amtincom(i)     := null;
                sal_amtincadj(i)    := null;
                sal_amt(i)          := null;
            END LOOP;
        end if;

        begin
            select nvl(approvno,0)+1
              into v_approvno2
              from ttprobat
             where codempid = p_codempid_query
               and dteduepr = p_dteduepr;
        exception when others then
            v_approvno2 := 1;
        end;
--        v_approvno2 := 1;
        v_flgpass := chk_flowmail.check_approve('HRPM31E', p_codempid_query, v_approvno2, global_v_codempid, p_codcomp, p_codpos, v_check);

        IF NOT v_flgpass THEN
            if v_check = 'HR2010' then
              param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
            else
              param_msg_error := get_error_msg_php('HR3008', global_v_lang);
            end if;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            return;
        END IF;

        BEGIN
            SELECT rowid
              INTO rowidmail
              FROM ttprobat
             WHERE codempid = p_codempid_query
               AND dteduepr = p_dteduepr;
        EXCEPTION WHEN no_data_found THEN
            NULL;
        END;

        if p_codrespr = 'E' then
            v_dteexpand := p_dteduepr + p_qtyexpand;
        end if;

        if p_codrespr  in ('P','E') then
            v_staappr   := 'Y';
            p_dteeffex  := null;
            p_codexemp  := null;
            p_flgssm    := '';
        else
            v_staappr   := 'N';
            p_dteoccup  := null;
            p_qtyexpand := null;
            v_dteexpand := null;
        end if;

        insert into tapprobat ( codempid,dteduepr,approvno,codcomp,codpos,
                                typproba,codrespr,dteoccup,qtyexpand,dteexpand,
                                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                amtinmth,amtindte,amtinhr,amtincadj1,amtincadj2,
                                amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,
                                amtincadj8,amtincadj9,amtincadj10,amtinadmth,amtinaddte,
                                amtinadhr,codexemp,flgblist,flgssm,dteeffex,
                                codappr,dteappr,staappr,remark,flgrepos,
                                dtecreate,codcreate,dteupd,coduser)
             values (p_codempid_query,p_dteduepr,v_approvno2,p_codcomp,p_codpos,
                     p_typproba, p_codrespr, p_dteoccup,p_qtyexpand,v_dteexpand,
                     stdenc(sal_amt(1), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(2), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(3), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(4), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(5), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(6), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(7), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(8), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(9), p_codempid_query, global_v_chken),
                     stdenc(sal_amt(10), p_codempid_query, global_v_chken),
                     stdenc(v_amtinmth, p_codempid_query, global_v_chken),
                     stdenc(v_amtindte, p_codempid_query, global_v_chken),
                     stdenc(v_amtinhr, p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(1), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(2), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(3), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(4), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(5), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(6), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(7), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(8), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(9), p_codempid_query, global_v_chken),
                     stdenc(sal_amtincadj(10), p_codempid_query, global_v_chken),
                     stdenc(v_amtinadmth, p_codempid_query, global_v_chken),
                     stdenc(v_amtinaddte, p_codempid_query, global_v_chken),
                     stdenc(v_amtinadhr, p_codempid_query, global_v_chken),
                     p_codexemp, p_flgblist, p_flgssm, p_dteeffex,
                     global_v_codempid,trunc(sysdate), v_staappr, p_desnote, p_flgrepos,
                     sysdate,global_v_coduser,sysdate,global_v_coduser
             );
        if v_check = 'Y' then
            UPDATE ttprobat
               SET codrespr = p_codrespr,
                   dteoccup = p_dteoccup,
                   dteeffex = p_dteeffex,
                   codexemp = p_codexemp,
                   flgrepos = p_flgrepos,
                   flgssm = p_flgssm,
                   flgblist = p_flgblist,
                   qtyexpand = p_qtyexpand,
                   dteexpand = v_dteexpand,
                   remarkap = p_desnote,
                   dteappr = trunc(sysdate),
                   codappr = global_v_codempid,
                   staupd = 'C',
                   approvno = v_approvno2,
                   flgadjin = v_flgadjin,
                   amtincom1 = stdenc(sal_amt(1), p_codempid_query, global_v_chken),
                   amtincom2 = stdenc(sal_amt(2), p_codempid_query, global_v_chken),
                   amtincom3 = stdenc(sal_amt(3), p_codempid_query, global_v_chken),
                   amtincom4 = stdenc(sal_amt(4), p_codempid_query, global_v_chken),
                   amtincom5 = stdenc(sal_amt(5), p_codempid_query, global_v_chken),
                   amtincom6 = stdenc(sal_amt(6), p_codempid_query, global_v_chken),
                   amtincom7 = stdenc(sal_amt(7), p_codempid_query, global_v_chken),
                   amtincom8 = stdenc(sal_amt(8), p_codempid_query, global_v_chken),
                   amtincom9 = stdenc(sal_amt(9), p_codempid_query, global_v_chken),
                   amtincom10 = stdenc(sal_amt(10), p_codempid_query, global_v_chken),
                   amtincadj1 = stdenc(sal_amtincadj(1), p_codempid_query, global_v_chken),
                   amtincadj2 = stdenc(sal_amtincadj(2), p_codempid_query, global_v_chken),
                   amtincadj3 = stdenc(sal_amtincadj(3), p_codempid_query, global_v_chken),
                   amtincadj4 = stdenc(sal_amtincadj(4), p_codempid_query, global_v_chken),
                   amtincadj5 = stdenc(sal_amtincadj(5), p_codempid_query, global_v_chken),
                   amtincadj6 = stdenc(sal_amtincadj(6), p_codempid_query, global_v_chken),
                   amtincadj7 = stdenc(sal_amtincadj(7), p_codempid_query, global_v_chken),
                   amtincadj8 = stdenc(sal_amtincadj(8), p_codempid_query, global_v_chken),
                   amtincadj9 = stdenc(sal_amtincadj(9), p_codempid_query, global_v_chken),
                   amtincadj10 = stdenc(sal_amtincadj(10), p_codempid_query, global_v_chken),
                   amtinmth = stdenc(v_amtinmth, p_codempid_query, global_v_chken),
                   amtindte = stdenc(v_amtindte, p_codempid_query, global_v_chken),
                   amtinhr = stdenc(v_amtinhr, p_codempid_query, global_v_chken),
                   amtinadmth = stdenc(v_amtinadmth, p_codempid_query, global_v_chken),
                   amtinaddte = stdenc(v_amtinaddte, p_codempid_query, global_v_chken),
                   amtinadhr = stdenc(v_amtinadhr, p_codempid_query, global_v_chken),
                   coduser = global_v_coduser,
                   dteupd = trunc(sysdate)
             WHERE codempid = p_codempid_query
               AND dteduepr = p_dteduepr;

            select typpayroll, codempmt
              into v_typpayroll, v_codempmt
              from ttprobat
             where codempid = p_codempid_query
               and dteduepr = p_dteduepr;
            if p_typproba = '1' then
                v_codadjin := '0003';
            else
                v_codadjin := '0004';
            end if;

            begin   -- Select for NUMSEQ
                select max(numseq)
                  into v_numseq
                  from thismove
                 where codempid = p_codempid_query
                   and dteeffec = p_dteduepr;
              exception when no_data_found then v_numseq := 0;
            end;
            v_numseq  := nvl(v_numseq,0) + 1;

            if v_flgadjin = 'Y' then
                insert into tfincadj (dteeffec,codempid,numseq,codadjin,
                                      codempmt,codempmtt,
                                      typpayroll,typpayrolt,dtetranf,staupd,flgbf,
                                      amtinco1,amtinco2,amtinco3,amtinco4,amtinco5,
                                      amtinco6,amtinco7,amtinco8,amtinco9,amtinco10,
                                      amtincn1,amtincn2,amtincn3,amtincn4,amtincn5,
                                      amtincn6,amtincn7,amtincn8,amtincn9,amtincn10,
                                      codincom1,codincom2,codincom3,codincom4,codincom5,
                                      codincom6,codincom7,codincom8,codincom9,codincom10,
                                      dtecreate,codcreate,dteupd,coduser)
                               values (nvl(p_dteoccup,p_dteduepr) ,
                                      p_codempid_query,v_numseq,v_codadjin,
                                      v_codempmt,v_codempmt,
                                      v_typpayroll,v_typpayroll,trunc(sysdate),'T','N',
                                      stdenc(sal_amtincom(1), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(2), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(3), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(4), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(5), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(6), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(7), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(8), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(9), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincom(10), p_codempid_query, global_v_chken),
                                      
                                      stdenc(sal_amtincadj(1), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(2), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(3), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(4), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(5), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(6), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(7), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(8), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(9), p_codempid_query, global_v_chken),
                                      stdenc(sal_amtincadj(10), p_codempid_query, global_v_chken),
                                      
                                      sal_codincom(1),sal_codincom(2),sal_codincom(3),sal_codincom(4),sal_codincom(5),
                                      sal_codincom(6),sal_codincom(7),sal_codincom(8),sal_codincom(9),sal_codincom(10),
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
            end if;
        else
            UPDATE ttprobat
               SET dteappr = trunc(sysdate),
                   codappr = global_v_codempid,
                   staupd = 'A',
                   approvno = v_approvno2,
                   coduser = global_v_coduser,
                   DTEUPD = trunc(sysdate)
             WHERE codempid = p_codempid_query
               AND dteduepr = p_dteduepr;
        end if;
        commit;

        begin
            v_error_cc := chk_flowmail.send_mail_reply('HRPM32U', p_codempid_query, null , global_v_codempid, global_v_coduser, null, 'HRPM32U1', 160, 'U', v_staappr, v_approvno2, null, null, 'TTPROBAT', rowidmail, '1', null);
        EXCEPTION WHEN OTHERS THEN
            param_msg_error := get_error_msg_php('HR2403', global_v_lang);
            json_str_output := get_response_message('200', param_msg_error, global_v_lang);
            return;
        END;
        if v_flgpass AND v_check = 'N' AND v_staappr <> 'N' then
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRPM31E', p_codempid_query, global_v_codempid, global_v_coduser,null, 'HRPM32U1', 150, 'U', 'A', v_approvno2 + 1, null, null,'TTPROBAT',rowidmail, '1', null);
            EXCEPTION WHEN OTHERS THEN
                param_msg_error := get_error_msg_php('HR2403', global_v_lang);
                json_str_output := get_response_message('200', param_msg_error, global_v_lang);
                return;
            END;
        else
            v_error:= '2402';
        end if;
        IF v_error in ('2046','2402') THEN
            param_msg_error := get_error_msg_php('HR2402', global_v_lang);
        ELSE
            param_msg_error := get_error_msg_php('HR2403', global_v_lang);
        END IF;
		json_str_output := get_response_message('200', param_msg_error, global_v_lang);
		return;
	END;

	PROCEDURE getincome ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		obj_row			    json_object_t;
		v_codcomp		    temploy1.codcomp%TYPE;
		v_codempmt		    temploy1.codempmt%TYPE;

		v_amtothr_income	NUMBER := 0;
		v_amtday_income		NUMBER := 0;
		v_sumincom_income	NUMBER := 0;
		obj_sum			    json_object_t;
		obj_data		    json_object_t;

        json_obj            json_object_t;
        p_income            json_object_t;
        obj_income          json_object_t;
        datasal_row         json_object_t;
        v_codcurr           temploy3.codcurr%type;
        v_amtproadj         temploy3.amtproadj%type;

		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom                p_num;
        sal_amtincadj               p_num;
        sal_amt                     p_num;
	BEGIN
		json_obj            := json_object_t(json_str_input);
		p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		p_dteduepr          := to_date(hcm_util.get_string_t(json_obj, 'p_dteduepr'),'dd/mm/yyyy');
		p_typproba          := hcm_util.get_string_t(json_obj, 'p_typproba');
        p_income            := hcm_util.get_json_t(json_obj, 'p_income');
        obj_income          := hcm_util.get_json_t(p_income, 'rows');

        FOR i IN 1..10 LOOP
            sal_amtincom(i)     := 0;
            sal_amtincadj(i)    := 0;
            sal_amt(i)          := 0;
        END LOOP;

        FOR i IN 0..obj_income.get_size - 1 LOOP
            datasal_row             := hcm_util.get_json_t(obj_income, TO_CHAR(i));
            sal_amtincom(i+1)       := to_number(hcm_util.get_string_t(datasal_row, 'amtincom'));
            sal_amtincadj(i+1)      := to_number(hcm_util.get_string_t(datasal_row, 'amtincadj'));
            sal_amt(i+1)            := to_number(hcm_util.get_string_t(datasal_row, 'amount'));
        END LOOP;

        FOR i IN 1..10 LOOP
            if sal_amtincom(i) is null then
                sal_amtincom(i) := 0;
            end if;

            if sal_amtincadj(i) is null then
                sal_amtincadj(i) := 0;
            end if;

            if sal_amt(i) is null then
                sal_amt(i) := 0;
            end if;
        END LOOP;

        select codcurr, stddec(amtproadj, codempid, global_v_chken)
          into v_codcurr, v_amtproadj
          from temploy3
         where codempid = p_codempid_query;
        if v_amtproadj = 0  then
            v_amtproadj := sal_amtincom(1);
        end if;
        if p_typproba = '1' then
            BEGIN
                SELECT codempmt, hcm_util.get_codcomp_level(codcomp, 1)
                  INTO v_codempmt, v_codcomp
                  FROM temploy1
                WHERE codempid = p_codempid_query;
            EXCEPTION WHEN no_data_found THEN
                v_codempmt  := NULL;
                v_codcomp   := NULL;
            END;
        else
            BEGIN
                SELECT codempmt, hcm_util.get_codcomp_level(codcomp, 1)
                  INTO v_codempmt, v_codcomp
                  FROM ttmovemt
                 WHERE codempid = p_codempid_query
                   and dteduepr = p_dteduepr;
            EXCEPTION WHEN no_data_found THEN
                v_codempmt  := NULL;
                v_codcomp   := NULL;
            END;
        end if;

        obj_sum := json_object_t();
        obj_sum.put('coderror', '200');
        obj_sum.put('codcurr', v_codcurr);
        obj_sum.put('desc_codcur', get_tcodec_name('TCODCURR',v_codcurr,global_v_lang));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincom(1),sal_amtincom(2), sal_amtincom(3), sal_amtincom(4), sal_amtincom(5),
                        sal_amtincom(6), sal_amtincom(7), sal_amtincom(8), sal_amtincom(9), sal_amtincom(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_sum.put('amtincomm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_sum.put('amtincomd', to_char(v_amtday_income,'999,999,990.00'));
        obj_sum.put('amtincomh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincadj(1),sal_amtincadj(2), sal_amtincadj(3), sal_amtincadj(4), sal_amtincadj(5),
                        sal_amtincadj(6), sal_amtincadj(7), sal_amtincadj(8), sal_amtincadj(9), sal_amtincadj(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_sum.put('amtmaxm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_sum.put('amtmaxd', to_char(v_amtday_income,'999,999,990.00'));
        obj_sum.put('amtmaxh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amt(1),sal_amt(2), sal_amt(3), sal_amt(4), sal_amt(5),
                        sal_amt(6), sal_amt(7), sal_amt(8), sal_amt(9), sal_amt(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_sum.put('amountm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_sum.put('amountd', to_char(v_amtday_income,'999,999,990.00'));
        obj_sum.put('amounth', to_char(v_amtothr_income,'999,999,990.00'));

        obj_sum.put('afpro', to_char(v_amtproadj,'999,999,990.00'));

		dbms_lob.createtemporary(json_str_output, true);
		obj_sum.to_clob(json_str_output);
	END getincome;

	PROCEDURE genallowance ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		json_obj		            json_object_t;
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom                p_num;
        sal_amtincadj               p_num;
        sal_amt                     p_num;
		v_temploy1                  temploy1%rowtype;
		v_ttprobat                  ttprobat%rowtype;
		v_flg			            VARCHAR2(10 CHAR);
		v_flg_action		        VARCHAR2(10 CHAR);
		v_datasal                   CLOB;
		get_allowance               CLOB;
		codincom_dteeffec           VARCHAR(20);
		codincom_codempmt           VARCHAR(20);
		param_json		            json_object_t;
		obj_rowsal		            json_object_t;
		v_row			            NUMBER := 0;
		param_json_row		        json_object_t;
		v_codincom		            tinexinf.codpay%TYPE;
		v_desincom		            tinexinf.descpaye%TYPE;
		cnt_row			            NUMBER := 0;
		v_desunit		            VARCHAR2(150 CHAR);
		v_amtmax		            NUMBER;
		sal_allowance		        NUMBER;
		v_amount		            NUMBER;
		obj_data_salary		        json_object_t;
		param_json_allowance	    json_object_t;
		param_json_row_allowance	json_object_t;
		obj_sum			            json_object_t;
        p_income                    json_object_t;
        obj_income                  json_object_t;
        v_dteeffec                  ttprobat.dteeffec%type;
        v_numseq                    ttprobat.numseq%type;
        v_income1                   json_object_t;
        v_income1_amtincom          number;
        v_income1_amtincadj         number;
        v_income1_amount            number;
        obj_table                   json_object_t;
        obj_detail                  json_object_t;
        v_amtothr_income            number := 0;
        v_amtday_income             number := 0;
        v_sumincom_income           number := 0;
        v_codcurr                   temploy3.codcurr%type;
        v_amtproadj                 temploy3.amtproadj%type;
        v_codcomp                   temploy1.codcomp%type;
        v_codempmt                  temploy1.codempmt%type;
	BEGIN
		json_obj            := json_object_t(json_str_input);
		p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		p_dteduepr          := to_date(hcm_util.get_string_t(json_obj, 'p_dteduepr'),'dd/mm/yyyy');
		p_typproba          := hcm_util.get_string_t(json_obj, 'p_typproba');
        p_income            := hcm_util.get_json_t(json_obj, 'p_income');
        obj_income          := hcm_util.get_json_t(p_income, 'rows');
        v_income1           := hcm_util.get_json_t(obj_income, '0');
        v_income1_amtincom  := to_number(hcm_util.get_string_t(v_income1, 'amtincom'));
        v_income1_amtincadj := to_number(hcm_util.get_string_t(v_income1, 'amtincadj'));
        v_income1_amount    := to_number(hcm_util.get_string_t(v_income1, 'amount'));

		SELECT stddec(amtincom1, codempid, global_v_chken), stddec(amtincom2, codempid, global_v_chken),
               stddec(amtincom3, codempid, global_v_chken), stddec(amtincom4, codempid, global_v_chken),
               stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken),
               stddec(amtincom7, codempid, global_v_chken), stddec(amtincom8, codempid, global_v_chken),
               stddec(amtincom9, codempid, global_v_chken), stddec(amtincom10, codempid, global_v_chken),
               codcurr, stddec(amtproadj, codempid, global_v_chken)
		  INTO sal_amtincom(1), sal_amtincom(2),
               sal_amtincom(3), sal_amtincom(4),
               sal_amtincom(5), sal_amtincom(6),
               sal_amtincom(7), sal_amtincom(8),
               sal_amtincom(9), sal_amtincom(10),
               v_codcurr, v_amtproadj
		  FROM temploy3
		 WHERE codempid = p_codempid_query;

		FOR i IN 1..10 LOOP
            IF ( sal_amtincom(i) IS NULL ) THEN
                sal_amtincom(i) := 0;
            END IF;
        END LOOP;

        if p_typproba = '1' then
            BEGIN
                SELECT codcomp, codpos, numlvl, jobgrade,
                       codjob, typpayroll, codempmt, codbrlc
                  INTO v_temploy1.codcomp, v_temploy1.codpos,
                       v_temploy1.numlvl, v_temploy1.jobgrade,
                       v_temploy1.codjob, v_temploy1.typpayroll,
                       v_temploy1.codempmt, v_temploy1.codbrlc
                  FROM temploy1
                 WHERE codempid = p_codempid_query;
            EXCEPTION WHEN no_data_found THEN
                v_temploy1.codcomp          := NULL;
                v_temploy1.codpos           := NULL;
                v_temploy1.numlvl           := NULL;
                v_temploy1.jobgrade         := NULL;
                v_temploy1.codjob           := NULL;
                v_temploy1.typpayroll       := NULL;
                v_temploy1.codempmt         := NULL;
                v_temploy1.codbrlc          := NULL;
            END;
        else
            BEGIN
                select dteeffec, numseq
                  into v_dteeffec, v_numseq
                  from ttprobat
                 where codempid = p_codempid_query
                   and dteduepr = p_dteduepr;

                SELECT codcomp, codpos, numlvl, jobgrade,
                       codjob, typpayroll, codempmt, codbrlc
                  INTO v_temploy1.codcomp, v_temploy1.codpos,
                       v_temploy1.numlvl, v_temploy1.jobgrade,
                       v_temploy1.codjob, v_temploy1.typpayroll,
                       v_temploy1.codempmt, v_temploy1.codbrlc
                  FROM ttmovemt
                 WHERE codempid = p_codempid_query
                   and dteeffec = v_dteeffec
                   and numseq = v_numseq;
            EXCEPTION WHEN no_data_found THEN
                v_temploy1.codcomp          := NULL;
                v_temploy1.codpos           := NULL;
                v_temploy1.numlvl           := NULL;
                v_temploy1.jobgrade         := NULL;
                v_temploy1.codjob           := NULL;
                v_temploy1.typpayroll       := NULL;
                v_temploy1.codempmt         := NULL;
                v_temploy1.codbrlc          := NULL;
            END;

        end if;


        get_allowance := hcm_pm.get_tincpos('{"p_amtincom1":''' || 0
                                            || ''',"p_amtincom2":''' || sal_amtincom(2)
                                            || ''',"p_amtincom3":''' || sal_amtincom(3)
                                            || ''',"p_amtincom4":''' || sal_amtincom(4)
                                            || ''',"p_amtincom5":''' || sal_amtincom(5)
                                            || ''',"p_amtincom6":''' || sal_amtincom(6)
                                            || ''',"p_amtincom7":''' || sal_amtincom(7)
                                            || ''',"p_amtincom8":''' || sal_amtincom(8)
                                            || ''',"p_amtincom9":''' || sal_amtincom(9)
                                            || ''',"p_amtincom10":''' || sal_amtincom(10)
                                            || ''',"p_codcomp":''' || v_temploy1.codcomp
                                            || ''',"p_codpos":''' || v_temploy1.codpos
                                            || ''',"p_numlvl":''' || v_temploy1.numlvl
                                            || ''',"p_jobgrade":''' || v_temploy1.jobgrade
                                            || ''',"p_codjob":''' || v_temploy1.codjob
                                            || ''',"p_typpayroll":''' || v_temploy1.typpayroll
                                            || ''',"p_codempmt":''' || v_temploy1.codempmt
                                            || ''',"p_codbrlc":''' || v_temploy1.codbrlc
                                            || ''',"p_flgtype":''2''}');

        BEGIN
            SELECT TO_CHAR(( SELECT MAX(dteeffec)
                               FROM tcontpms
                              WHERE codcompy = hcm_util.get_codcomp_level(v_temploy1.codcomp, 1)), 'ddmmyyyy'),
                   codempmt
              INTO codincom_dteeffec,
                   codincom_codempmt
              FROM temploy1
             WHERE codempid = p_codempid_query;
        EXCEPTION WHEN no_data_found THEN
            codincom_dteeffec := NULL;
            codincom_codempmt := NULL;
        END;

        v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_temploy1.codcomp, 1)
                                            || ''',"p_dteeffec":''' || NULL
                                            || ''',"p_codempmt":''' || codincom_codempmt
                                            || ''',"p_lang":''' || global_v_lang || '''}');
        BEGIN
            SELECT stddec(amtincom1, codempid, global_v_chken),
                   greatest(0,stddec(amtincom2, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom3, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom4, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom5, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom6, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom7, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom8, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom9, codempid, global_v_chken)),
                   greatest(0,stddec(amtincom10, codempid, global_v_chken))
              INTO sal_amtincom(1), sal_amtincom(2),
                   sal_amtincom(3), sal_amtincom(4),
                   sal_amtincom(5), sal_amtincom(6),
                   sal_amtincom(7), sal_amtincom(8),
                   sal_amtincom(9), sal_amtincom(10)
              FROM temploy3
             WHERE codempid = p_codempid_query;
        EXCEPTION WHEN no_data_found THEN
            sal_amtincom(1) := 0;
            sal_amtincom(2) := 0;
            sal_amtincom(3) := 0;
            sal_amtincom(4) := 0;
            sal_amtincom(5) := 0;
            sal_amtincom(6) := 0;
            sal_amtincom(7) := 0;
            sal_amtincom(8) := 0;
            sal_amtincom(9) := 0;
            sal_amtincom(10) := 0;
        END;
        param_json              := json_object_t(v_datasal);
        param_json_allowance    := json_object_t(get_allowance);
        obj_rowsal              := json_object_t();
        v_row := -1;
        FOR i IN 1..10 LOOP
            sal_amtincadj(i)    := 0;
            sal_amt(i)          := 0;
        END LOOP;

        FOR i IN 0..9 LOOP
            param_json_row              := hcm_util.get_json_t(param_json, TO_CHAR(i));
            param_json_row_allowance    := hcm_util.get_json_t(param_json_allowance, TO_CHAR(i));
            sal_allowance               := hcm_util.get_string_t(param_json_row_allowance, 'amtincom');
            v_codincom                  := hcm_util.get_string_t(param_json_row, 'codincom');
            v_desincom                  := hcm_util.get_string_t(param_json_row, 'desincom');
            v_amtmax                    := hcm_util.get_string_t(param_json_row, 'amtmax');
            v_desunit                   := hcm_util.get_string_t(param_json_row, 'desunit');
            IF v_codincom IS NULL OR v_codincom = ' ' THEN
                EXIT;
            END IF;
            v_row                       := v_row + 1;
            obj_data_salary             := json_object_t();
            obj_data_salary.put('codincom', v_codincom);
            obj_data_salary.put('desincom', v_desincom);
            obj_data_salary.put('desunit', v_desunit);

            obj_data_salary.put('amtmax', v_amtmax);
            if(i = 0) then
                if v_amtproadj = 0  then
                    v_amtproadj := v_income1_amtincom;
                end if;
                sal_amtincom(1)     := v_income1_amtincom;
                sal_amtincadj(1)    := v_income1_amtincadj;
                sal_amt(1)          := v_income1_amount;
                obj_data_salary.put('amtincom', v_income1_amtincom);
                obj_data_salary.put('amtincadj', v_income1_amtincadj);
                obj_data_salary.put('amount', v_income1_amount);
            else
                sal_amtincom(i+1)     := sal_amtincom(i + 1);
                sal_amtincadj(i+1)    := sal_allowance - sal_amtincom(i + 1);
                sal_amt(i+1)          := sal_allowance;
                obj_data_salary.put('amtincom', sal_amtincom(i + 1));
                obj_data_salary.put('amtincadj', sal_allowance - sal_amtincom(i + 1));
                obj_data_salary.put('amount', sal_allowance);
            end if;

            obj_rowsal.put(v_row, obj_data_salary);
        end loop;
        obj_table       := json_object_t();
        obj_table.put('rows', obj_rowsal);

        obj_detail      := json_object_t();
        v_codcomp       := v_temploy1.codcomp;
        v_codempmt      := v_temploy1.codempmt;
        obj_detail.put('codcurr', v_codcurr);
        obj_detail.put('desc_codcur', get_tcodec_name('TCODCURR',v_codcurr,global_v_lang));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincom(1),sal_amtincom(2), sal_amtincom(3), sal_amtincom(4), sal_amtincom(5),
                        sal_amtincom(6), sal_amtincom(7), sal_amtincom(8), sal_amtincom(9), sal_amtincom(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_detail.put('amtincomm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_detail.put('amtincomd', to_char(v_amtday_income,'999,999,990.00'));
        obj_detail.put('amtincomh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincadj(1),sal_amtincadj(2), sal_amtincadj(3), sal_amtincadj(4), sal_amtincadj(5),
                        sal_amtincadj(6), sal_amtincadj(7), sal_amtincadj(8), sal_amtincadj(9), sal_amtincadj(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_detail.put('amtmaxm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_detail.put('amtmaxd', to_char(v_amtday_income,'999,999,990.00'));
        obj_detail.put('amtmaxh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amt(1),sal_amt(2), sal_amt(3), sal_amt(4), sal_amt(5),
                        sal_amt(6), sal_amt(7), sal_amt(8), sal_amt(9), sal_amt(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_detail.put('amountm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_detail.put('amountd', to_char(v_amtday_income,'999,999,990.00'));
        obj_detail.put('amounth', to_char(v_amtothr_income,'999,999,990.00'));

        obj_detail.put('afpro', to_char(v_amtproadj,'999,999,990.00'));


        obj_sum         := json_object_t();
        obj_sum.put('coderror', '200');
        obj_sum.put('detail', obj_detail);
        obj_sum.put('table', obj_table);
        json_str_output := obj_sum.to_clob;
    END genallowance;

	PROCEDURE get_numseq ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN
		initial_value(json_str_input);
		IF ( p_codempid_query IS NULL or p_dteduepr IS NULL ) THEN
			param_msg_error := get_error_msg_php('HR2045', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

		IF param_msg_error IS NULL THEN
			gen_numseq(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE gen_numseq ( json_str_output OUT CLOB ) AS
		obj_data		json_object_t;
		obj_row			json_object_t;
        v_count_numseq  number;
        v_last_dteeval  tappbath.dteeval%type;
        v_rcnt          number;
        v_chk_complete  number;
        v_max_approvno  number;
        v_check         varchar2(500 char);
        v_flgpass		BOOLEAN;
      cursor c_tapprobat is
        select approvno
          from tapprobat
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
      order by approvno desc;
	BEGIN
		obj_row     := json_object_t();
		v_rcnt      := 0;
        obj_row.put('coderror', 200);
        select count (codempid),max(approvno)
          into v_chk_complete,v_max_approvno
          from ttprobat
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
           and staupd = 'C';

        select nvl(max(approvno),0) + 1
          into v_max_approvno
          from tapprobat
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr;

        if v_chk_complete = 0 then
            v_rcnt := v_rcnt + 1;
            v_flgpass := chk_flowmail.check_approve('HRPM31E', p_codempid_query, v_max_approvno, global_v_codempid, null, null, v_check);

            obj_row.put(to_char(v_rcnt-1), to_char(v_max_approvno));
        end if;
        for r_tapprobat in c_tapprobat loop
            v_rcnt := v_rcnt + 1;
            obj_row.put(to_char(v_rcnt-1), to_char(r_tapprobat.approvno));
        end loop;


		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE get_detail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN
		initial_value(json_str_input);
		IF param_msg_error IS NULL THEN
			gen_detail(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE gen_detail ( json_str_output OUT CLOB ) AS
		obj_data		    json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        obj_tab2_detail     json_object_t;
        obj_tab2_table      json_object_t;
		obj_row			    json_object_t;
        v_count_numseq      number;
        v_last_dteeval      tappbath.dteeval%type;
        v_rcnt              number;
        v_dteefpos          date;
        v_codcurr           temploy3.codcurr%type;
        v_amtproadj         temploy3.amtproadj%type;
        v_codempmt          temploy1.codempmt%type;
        v_datasal           CLOB;
        v_datasal_json      json_object_t;
        obj_data_salary     json_object_t;
        TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        sal_amtincom        p_num;
		sal_amtincadj       p_num;
        sal_amt             p_num;
        v_codincom		    tinexinf.codpay%TYPE;
		v_desincom		    tinexinf.descpaye%TYPE;
        v_desunit		    VARCHAR2(150 CHAR);
		v_amtmax		    NUMBER;
        datasal_row         json_object_t;
        v_row               number := 0;
        obj_rowsal          json_object_t;
        v_amtothr_income    number := 0;
        v_amtday_income     number := 0;
        v_sumincom_income   number := 0;
        v_codcomp           temploy1.codcomp%type;
        v_codcompt          ttmovemt.codcompt%type := '';
        v_codposnow         ttmovemt.codposnow%type := '';

      cursor c_tapprobat is
        select *
          from tapprobat
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
           and approvno = ( select max(approvno)
                              from tapprobat
                             where codempid = p_codempid_query
                               and dteduepr = p_dteduepr
                               and approvno <= p_numseq);

      cursor c_ttprobat is
        select *
          from ttprobat
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr;
	BEGIN
        v_rcnt := 0;
		obj_row             := json_object_t();
        obj_data            := json_object_t();
        obj_tab1            := json_object_t();
        obj_tab2            := json_object_t();
        obj_tab2_detail     := json_object_t();
        obj_tab2_table      := json_object_t();

        begin
        select dteempmt, codempmt
          into v_dteefpos, v_codempmt
          from temploy1
         where codempid = p_codempid_query;
        exception when no_data_found then
            null;
        end;

        begin
        select codcurr, stddec(amtproadj, codempid, global_v_chken),
               greatest(0,stddec(amtincom1, codempid, global_v_chken)), greatest(0,stddec(amtincom2, codempid, global_v_chken)),
               greatest(0,stddec(amtincom3, codempid, global_v_chken)), greatest(0,stddec(amtincom4, codempid, global_v_chken)),
               greatest(0,stddec(amtincom5, codempid, global_v_chken)), greatest(0,stddec(amtincom6, codempid, global_v_chken)),
               greatest(0,stddec(amtincom7, codempid, global_v_chken)), greatest(0,stddec(amtincom8, codempid, global_v_chken)),
               greatest(0,stddec(amtincom9, codempid, global_v_chken)), greatest(0,stddec(amtincom10, codempid, global_v_chken))
          into v_codcurr, v_amtproadj,
               sal_amtincom(1), sal_amtincom(2),
               sal_amtincom(3), sal_amtincom(4),
               sal_amtincom(5), sal_amtincom(6),
               sal_amtincom(7), sal_amtincom(8),
               sal_amtincom(9), sal_amtincom(10)
          from temploy3
         where codempid = p_codempid_query;
        exception when no_data_found then
            null;
        end;

        for r1 in  c_tapprobat loop
            v_rcnt := v_rcnt + 1;
            v_codcomp := r1.codcomp;
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('numseq', p_numseq);
            obj_data.put('dteeval', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('codeval', r1.codappr);
            obj_data.put('desc_codeval', get_temploy_name(r1.codappr, global_v_lang));

            IF p_numseq <> r1.approvno then
                obj_data.put('flgDisable', false);
                obj_tab1.put('flgDisable', false);
            else
                obj_data.put('flgDisable', true);
                obj_tab1.put('flgDisable', true);
            end if;
            obj_tab1.put('codempid', r1.codempid);
            obj_tab1.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_tab1.put('codcomp', r1.codcomp);
            obj_tab1.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
            obj_tab1.put('codpos', r1.codpos);
            obj_tab1.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
            obj_tab1.put('typproba', r1.typproba);
            obj_tab1.put('desc_typproba', get_tlistval_name('NAMTPRO', r1.typproba, global_v_lang));
            obj_tab1.put('dteduepr', to_char(r1.dteduepr,'dd/mm/yyyy'));
            obj_tab1.put('dteoccup', nvl(to_char(r1.dteoccup,'dd/mm/yyyy'),''));
            obj_tab1.put('dteeffex', nvl(to_char(r1.dteeffex,'dd/mm/yyyy'),''));
            obj_tab1.put('codexemp', nvl(r1.codexemp,''));
            obj_tab1.put('flgrepos', nvl(r1.flgrepos,'Y'));
            obj_tab1.put('flgssm', nvl(r1.flgssm,''));
            obj_tab1.put('flgblist', nvl(r1.flgblist,'N'));
            obj_tab1.put('qtyexpand', nvl(to_char(r1.qtyexpand),''));
            obj_tab1.put('desnote', nvl(r1.remark,''));
            obj_tab1.put('codrespr', r1.codrespr);
            v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(r1.codcomp, 1)
                        || ''',"p_dteeffec":''' || NULL
                        || ''',"p_codempmt":''' || v_codempmt
                        || ''',"p_lang":''' || global_v_lang || '''}');
            v_datasal_json := json_object_t(v_datasal);

            for r2 in c_ttprobat loop
                if r2.typproba = '2' then
                    v_dteefpos := r2.dteeffec;
                    begin
                        select codcompt, codposnow
                          into v_codcompt, v_codposnow
                          from ttmovemt
                         where codempid = r2.codempid
                           and dteeffec = r2.dteeffec
                           and numseq = r2.numseq;
                    exception when others then
                        v_codcompt := '';
                        v_codposnow := '';
                    end;
                end if;


                obj_tab1.put('dteefpos', to_char(v_dteefpos,'dd/mm/yyyy'));
                obj_tab1.put('codcompt', v_codcompt);
                obj_tab1.put('codposnow', v_codposnow);
            end loop;

            sal_amtincadj(1) := stddec(r1.amtincadj1, r1.codempid, global_v_chken);
            sal_amtincadj(2) := stddec(r1.amtincadj2, r1.codempid, global_v_chken);
            sal_amtincadj(3) := stddec(r1.amtincadj3, r1.codempid, global_v_chken);
            sal_amtincadj(4) := stddec(r1.amtincadj4, r1.codempid, global_v_chken);
            sal_amtincadj(5) := stddec(r1.amtincadj5, r1.codempid, global_v_chken);
            sal_amtincadj(6) := stddec(r1.amtincadj6, r1.codempid, global_v_chken);
            sal_amtincadj(7) := stddec(r1.amtincadj7, r1.codempid, global_v_chken);
            sal_amtincadj(8) := stddec(r1.amtincadj8, r1.codempid, global_v_chken);
            sal_amtincadj(9) := stddec(r1.amtincadj9, r1.codempid, global_v_chken);
            sal_amtincadj(10) := stddec(r1.amtincadj10, r1.codempid, global_v_chken);

            sal_amt(1) := stddec(r1.amtincom1, r1.codempid, global_v_chken);
            sal_amt(2) := stddec(r1.amtincom2, r1.codempid, global_v_chken);
            sal_amt(3) := stddec(r1.amtincom3, r1.codempid, global_v_chken);
            sal_amt(4) := stddec(r1.amtincom4, r1.codempid, global_v_chken);
            sal_amt(5) := stddec(r1.amtincom5, r1.codempid, global_v_chken);
            sal_amt(6) := stddec(r1.amtincom6, r1.codempid, global_v_chken);
            sal_amt(7) := stddec(r1.amtincom7, r1.codempid, global_v_chken);
            sal_amt(8) := stddec(r1.amtincom8, r1.codempid, global_v_chken);
            sal_amt(9) := stddec(r1.amtincom9, r1.codempid, global_v_chken);
            sal_amt(10) := stddec(r1.amtincom10, r1.codempid, global_v_chken);

            sal_amtincom(1) := sal_amt(1) - sal_amtincadj(1);
            sal_amtincom(2) := sal_amt(2) - sal_amtincadj(2);
            sal_amtincom(3) := sal_amt(3) - sal_amtincadj(3);
            sal_amtincom(4) := sal_amt(4) - sal_amtincadj(4);
            sal_amtincom(5) := sal_amt(5) - sal_amtincadj(5);
            sal_amtincom(6) := sal_amt(6) - sal_amtincadj(6);
            sal_amtincom(7) := sal_amt(7) - sal_amtincadj(7);
            sal_amtincom(8) := sal_amt(8) - sal_amtincadj(8);
            sal_amtincom(9) := sal_amt(9) - sal_amtincadj(9);
            sal_amtincom(10) := sal_amt(10) - sal_amtincadj(10);

            if v_amtproadj = 0  then
                v_amtproadj := sal_amtincom(1);
            end if;
        end loop;

        if v_rcnt = 0 then
            obj_data.put('codempid', p_codempid_query);
            obj_data.put('desc_codempid', get_temploy_name(p_codempid_query, global_v_lang));
            obj_data.put('numseq', p_numseq);
            obj_data.put('dteeval', to_char(sysdate,'dd/mm/yyyy'));
            obj_data.put('codeval', global_v_codempid);
            obj_data.put('desc_codeval', get_temploy_name(global_v_codempid, global_v_lang));
            obj_data.put('flgDisable', false);

            for r2 in c_ttprobat loop
                v_codcomp := r2.codcomp;
                obj_tab1.put('flgDisable', false);
                obj_tab1.put('codempid', r2.codempid);
                obj_tab1.put('desc_codempid', get_temploy_name(r2.codempid, global_v_lang));
                obj_tab1.put('codcomp', r2.codcomp);
                obj_tab1.put('desc_codcomp', get_tcenter_name(r2.codcomp, global_v_lang));
                obj_tab1.put('codpos', r2.codpos);
                obj_tab1.put('desc_codpos', get_tpostn_name(r2.codpos, global_v_lang));
                obj_tab1.put('typproba', r2.typproba);
                obj_tab1.put('desc_typproba', get_tlistval_name('NAMTPRO', r2.typproba, global_v_lang));
                if r2.typproba = '2' then
                    v_dteefpos := r2.dteeffec;
                    begin
                        select codcompt, codposnow
                          into v_codcompt, v_codposnow
                          from ttmovemt
                         where codempid = r2.codempid
                           and dteeffec = r2.dteeffec
                           and numseq = r2.numseq;
                    exception when others then
                        v_codcompt := '';
                        v_codposnow := '';
                    end;
                end if;
                obj_tab1.put('dteefpos', to_char(v_dteefpos,'dd/mm/yyyy'));
                obj_tab1.put('dteduepr', to_char(r2.dteduepr,'dd/mm/yyyy'));
                obj_tab1.put('codrespr', r2.codrespr);
                obj_tab1.put('dteoccup', nvl(to_char(r2.dteoccup,'dd/mm/yyyy'),''));
                obj_tab1.put('dteeffex', nvl(to_char(r2.dteeffex,'dd/mm/yyyy'),''));
                obj_tab1.put('codexemp', nvl(r2.codexemp,''));
                obj_tab1.put('flgrepos', nvl(r2.flgrepos,'Y'));
                obj_tab1.put('codcompt', v_codcompt);
                obj_tab1.put('codposnow', v_codposnow);
                obj_tab1.put('flgssm', nvl(r2.flgssm,''));
                obj_tab1.put('flgblist', nvl(r2.flgblist,'N'));
                obj_tab1.put('qtyexpand', nvl(to_char(r2.qtyexpand),''));
                obj_tab1.put('desnote', nvl(r2.desnote,''));
                v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(r2.codcomp, 1)
                            || ''',"p_dteeffec":''' || NULL
                            || ''',"p_codempmt":''' || v_codempmt
                            || ''',"p_lang":''' || global_v_lang || '''}');
                v_datasal_json := json_object_t(v_datasal);
            end loop;

            if v_amtproadj = 0  then
                v_amtproadj := sal_amtincom(1);
            end if;
            sal_amtincadj(1)    := v_amtproadj - sal_amtincom(1);
            sal_amtincadj(2)    := 0;
            sal_amtincadj(3)    := 0;
            sal_amtincadj(4)    := 0;
            sal_amtincadj(5)    := 0;
            sal_amtincadj(6)    := 0;
            sal_amtincadj(7)    := 0;
            sal_amtincadj(8)    := 0;
            sal_amtincadj(9)    := 0;
            sal_amtincadj(10)   := 0;

            sal_amt(1)          := v_amtproadj;
            sal_amt(2)          := sal_amtincom(2);
            sal_amt(3)          := sal_amtincom(3);
            sal_amt(4)          := sal_amtincom(4);
            sal_amt(5)          := sal_amtincom(5);
            sal_amt(6)          := sal_amtincom(6);
            sal_amt(7)          := sal_amtincom(7);
            sal_amt(8)          := sal_amtincom(8);
            sal_amt(9)          := sal_amtincom(9);
            sal_amt(10)         := sal_amtincom(10);
        end if;

        obj_rowsal := json_object_t();

--        for i in 1..10 loop
--            sal_amtincadj
--        end loop;

        FOR i IN 0..v_datasal_json.get_size - 1 LOOP
            datasal_row  := hcm_util.get_json_t(v_datasal_json, TO_CHAR(i));
            v_codincom      := hcm_util.get_string_t(datasal_row, 'codincom');
            v_desincom      := hcm_util.get_string_t(datasal_row, 'desincom');
            v_amtmax        := hcm_util.get_string_t(datasal_row, 'amtmax');
            v_desunit       := hcm_util.get_string_t(datasal_row, 'desunit');
            IF v_codincom IS NULL OR v_codincom = ' ' THEN
                EXIT;
            END IF;
            v_row           := v_row + 1;
            obj_data_salary := json_object_t();
            obj_data_salary.put('codincom', v_codincom);
            obj_data_salary.put('desincom', v_desincom);
            obj_data_salary.put('desunit', v_desunit);
            obj_data_salary.put('amtincom', sal_amtincom(i+1));
            obj_data_salary.put('amtincadj', sal_amtincadj(i+1));
            obj_data_salary.put('amount', sal_amt(i+1));
            obj_data_salary.put('amtmax', v_amtmax);

            obj_rowsal.put(v_row-1, obj_data_salary);
        END LOOP;

        obj_tab2_detail.put('codcurr', v_codcurr);
        obj_tab2_detail.put('desc_codcur', get_tcodec_name('TCODCURR',v_codcurr,global_v_lang));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincom(1),sal_amtincom(2), sal_amtincom(3), sal_amtincom(4), sal_amtincom(5),
                        sal_amtincom(6), sal_amtincom(7), sal_amtincom(8), sal_amtincom(9), sal_amtincom(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_tab2_detail.put('amtincomm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_tab2_detail.put('amtincomd', to_char(v_amtday_income,'999,999,990.00'));
        obj_tab2_detail.put('amtincomh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amtincadj(1),sal_amtincadj(2), sal_amtincadj(3), sal_amtincadj(4), sal_amtincadj(5),
                        sal_amtincadj(6), sal_amtincadj(7), sal_amtincadj(8), sal_amtincadj(9), sal_amtincadj(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_tab2_detail.put('amtmaxm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_tab2_detail.put('amtmaxd', to_char(v_amtday_income,'999,999,990.00'));
        obj_tab2_detail.put('amtmaxh', to_char(v_amtothr_income,'999,999,990.00'));

		get_wage_income(v_codcomp, v_codempmt, sal_amt(1),sal_amt(2), sal_amt(3), sal_amt(4), sal_amt(5),
                        sal_amt(6), sal_amt(7), sal_amt(8), sal_amt(9), sal_amt(10),
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_tab2_detail.put('amountm', to_char(v_sumincom_income,'999,999,990.00'));
        obj_tab2_detail.put('amountd', to_char(v_amtday_income,'999,999,990.00'));
        obj_tab2_detail.put('amounth', to_char(v_amtothr_income,'999,999,990.00'));

        obj_tab2_detail.put('afpro', to_char(v_amtproadj,'999,999,990.00'));

        obj_tab2_table.put('rows', obj_rowsal);
        obj_tab2.put('detail', obj_tab2_detail);
        obj_tab2.put('table', obj_tab2_table);
        obj_row.put('coderror', 200);
        obj_row.put('detail', obj_data);
        obj_row.put('tab1', obj_tab1);
        obj_row.put('tab2', obj_tab2);

		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

END hrpm32u;

/
