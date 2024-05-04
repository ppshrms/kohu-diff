--------------------------------------------------------
--  DDL for Package Body HRPM4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4DE" IS

	PROCEDURE initial_value ( json_str IN CLOB ) IS
		json_obj		    json_object_t;
		get_username        VARCHAR(100);
	BEGIN
		json_obj            := json_object_t(json_str);
		global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
		pa_codcurr          := hcm_util.get_string_t(json_obj, 'pa_codcurr');
		p_flag              := hcm_util.get_string_t(json_obj, 'pa_flag');
		p_codempid          := hcm_util.get_string_t(json_obj, 'pa_codempid');
		p_numseq            := hcm_util.get_string_t(json_obj, 'pa_numseq');
		p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'pa_dteeffec'), 'dd/mm/yyyy');
		p_codtrn            := hcm_util.get_string_t(json_obj, 'pa_codtrn');
		p_codcreate         := hcm_util.get_string_t(json_obj, 'pa_codcreate');
		p_stapost2          := hcm_util.get_string_t(json_obj, 'pa_stapost2');
		p_dteduepr          := to_date(hcm_util.get_string_t(json_obj, 'pa_dteduepr'), 'dd/mm/yyyy');
		p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'pa_dteend'), 'dd/mm/yyyy');
		p_numreqst          := hcm_util.get_string_t(json_obj, 'pa_numreqst');
		p_flgduepr          := hcm_util.get_string_t(json_obj, 'pa_flgduepr');
		p_desnote           := hcm_util.get_string_t(json_obj, 'pa_desnote');
		p_countday          := hcm_util.get_string_t(json_obj, 'pa_countday');
--<< user20 Date: 03/09/2021  PM Module- #6097		p_dteeffpos         := p_dteeffec + p_countday;
		p_dteeffpos         := p_dteeffec + p_countday - 1;
--<< user20 Date: 03/09/2021  PM Module- #6097
		obj_row1            := hcm_util.get_string_t(json_obj, 'codcomp');
		obj_row2            := hcm_util.get_string_t(json_obj, 'codpos');
		obj_row3            := hcm_util.get_string_t(json_obj, 'numlvl');
		obj_row4            := hcm_util.get_string_t(json_obj, 'codjob');
		obj_row5            := hcm_util.get_string_t(json_obj, 'codempmt');
		obj_row6            := hcm_util.get_string_t(json_obj, 'typemp');
		obj_row7            := hcm_util.get_string_t(json_obj, 'typpayroll');
		obj_row8            := hcm_util.get_string_t(json_obj, 'codbrlc');
		obj_row9            := hcm_util.get_string_t(json_obj, 'flgatten');
		obj_row10           := hcm_util.get_string_t(json_obj, 'codcalen');
		obj_row11           := hcm_util.get_string_t(json_obj, 'jobgrade');
		obj_row12           := hcm_util.get_string_t(json_obj, 'codgrpgl');
        p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
        p_index_codcomp     := hcm_util.get_string_t(json_obj, 'p_codcomp');
        p_index_codtrn      := hcm_util.get_string_t(json_obj, 'p_codtrn');
        p_index_dtestr      := to_date(hcm_util.get_string_t(json_obj, 'p_dtestr'), 'dd/mm/yyyy');
        p_index_dteend      := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');
		detail_codempid     := hcm_util.get_string_t(json_obj, 'detail_codempid');
		detail_numseq       := hcm_util.get_string_t(json_obj, 'detail_numseq');
		detail_dteeffec     := to_date(hcm_util.get_string_t(json_obj, 'detail_dteeffec'), 'dd/mm/yyyy');
		detail_codtrn       := hcm_util.get_string_t(json_obj, 'detail_codtrn');
		detail_flag         := hcm_util.get_string_t(json_obj, 'detail_flag');
		modal_codpos        := hcm_util.get_string_t(json_obj, 'detail_codpos');
		modal_codcomp       := hcm_util.get_string_t(json_obj, 'detail_codcomp');
		pa_amtothr          := replace(hcm_util.get_string_t(json_obj, 'pa_amtothr'),',','');
		modal_codcomp       := hcm_util.get_codcomp_level(modal_codcomp, 1);
		hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
	END;

    PROCEDURE check_index (json_str_input IN CLOB) AS
        v_count         number;
        v_flgsecu       boolean := false;
        v_zupdsal       varchar2(4000 char);
	BEGIN
        if p_index_codcomp is not null then
            param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_index_codcomp);
			if(param_msg_error is not null ) then
				return;
			end if;
        end if;

        if p_codempid_query is not null then
            begin
              select count(*) into v_count
                from temploy1
               where codempid like p_codempid_query
                 and staemp in ('0');
              if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2102', global_v_lang, 'temploy1');
                return;
              end if;
            end;

            v_flgsecu := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if not v_flgsecu  then
                param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                return ;
            END IF;
        end if;
    END;

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			      json_object_t;
		check_staemp_emp	NUMBER;
	BEGIN
		initial_value(json_str_input);
        check_index(json_str_input);
		IF param_msg_error IS NULL THEN
			gen_index(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE gen_index ( json_str_output OUT CLOB ) AS
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			NUMBER := 0;
        v_flgsecu       boolean := false;
        v_zupdsal       varchar2(4000 char);

		CURSOR c1 IS
		SELECT ttmovemt.* ,
               decode(staupd,'C','Y',staupd) staappr
		  FROM ttmovemt
		 WHERE codempid = nvl(p_codempid_query,codempid)
           AND codcomp like p_index_codcomp||'%'
           AND dteeffec between nvl(p_index_dtestr,dteeffec) and nvl(p_index_dteend,dteeffec)
           AND codtrn = nvl(p_index_codtrn,codtrn)
           AND codtrn > '0007'
      ORDER BY dteeffec DESC, codempid,
		       numseq;
	BEGIN
		obj_row     := json_object_t();
		obj_data    := json_object_t();
		FOR r1 IN c1 LOOP
            v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
			if v_flgsecu then
                v_rcnt := v_rcnt + 1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('rcnt', TO_CHAR(v_rcnt));
                obj_data.put('dteeffec', TO_CHAR(r1.dteeffec, 'dd/mm/yyyy'));
                obj_data.put('codtrn', get_tcodec_name('TCODMOVE', r1.codtrn, global_v_lang));
                obj_data.put('id_codtrn', r1.codtrn);
                obj_data.put('numseq', r1.numseq);
                obj_data.put('image', get_emp_img (r1.codempid));
                obj_data.put('codempid', r1.codempid);
                obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('dteend', TO_CHAR(r1.dteend, 'dd/mm/yyyy'));
                obj_data.put('remarkap', convert(r1.desnote,'AL32UTF8','utf8'));
                obj_data.put('staappr', get_tlistval_name('STAAPPR', r1.staappr, global_v_lang));
                obj_data.put('staapprchar', r1.staupd);
                obj_row.put(TO_CHAR(v_rcnt - 1), obj_data);
            end if;
		END LOOP;
		IF param_msg_error IS NULL THEN
			json_str_output := obj_row.to_clob();
		ELSE
			json_str_output := get_response_message('400', param_msg_error, global_v_lang);
		END IF;

	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE savedata ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		obj_row			        json_object_t;
		obj_data		        json_object_t;
		salchage		        number;
		sumsal			        number;
		amtmax			        number;
		col3                    VARCHAR2(50 CHAR);
		v_amtmax_param_json_row	number;
		p_paramssalary		    json_object_t;
		sqlupdate               VARCHAR2(4000);
		sqlupdatesal            VARCHAR2(4000);
		tp1_codcomp		        temploy1.codcomp%TYPE;
		tp1_codpos		        temploy1.codpos%TYPE;
		tp1_numlvl		        temploy1.numlvl%TYPE;
		tp1_codjob		        temploy1.codjob%TYPE;
		tp1_codempmt		    temploy1.codempmt%TYPE;
		param_json		        json_object_t;
		tp1_typemp		        temploy1.typemp%TYPE;
		tp1_typpayroll		    temploy1.typpayroll%TYPE;
		tp1_codbrlc		        temploy1.codbrlc%TYPE;
		tp1_flgatten		    temploy1.flgatten%TYPE;
		tp1_codcalen		    temploy1.codcalen%TYPE;
		tp1_jobgrade		    temploy1.jobgrade%TYPE;
		tp1_codgrpgl		    temploy1.codgrpgl%TYPE;
		indexrows		        NUMBER;
		chk_staemp_0		    temploy1.staemp%TYPE;
		v_datasal               CLOB;
		param_json_row		    json_object_t;
		chk_salary              varchar2(20);
		tp1_codsex		        temploy1.codsex%type;
		v_dteefstep		        date;
		v_dteefpos		        date;
		v_dteeflvl		        date;

        v_approvno              ttmovemt.approvno%type;
        v_checkapp              boolean := false;
        v_check                 varchar2(500 char);
        pctadj                  number;
        v_typmove		        tcodmove.typmove%TYPE;
        v_flgsecur              varchar2(4000);
        v_numlvl_old            temploy1.numlvl%type;

        x_stareq                temploy1.stareq%type;
        x_numreqc               temploy1.numreqc%type;
        v_stareq                treqest1.stareq%type;
        v_qtyact                treqest2.qtyact%type;
        v_qtyreq                treqest2.qtyreq%type;
	BEGIN
		initial_value(json_str_input);
		obj_data := json_object_t(json_str_input);
		BEGIN
			SELECT staemp,dteefstep,dteefpos,dteeflvl
			  INTO chk_staemp_0,v_dteefstep,v_dteefpos,v_dteeflvl
			  FROM temploy1
			 WHERE codempid = p_codcreate;
		EXCEPTION WHEN no_data_found THEN
			chk_staemp_0 := NULL;
		END;

		BEGIN
			SELECT numlvl
			  INTO v_numlvl_old
			  FROM temploy1
			 WHERE codempid = p_codempid;
		EXCEPTION WHEN no_data_found THEN
			v_numlvl_old := NULL;
		END;

        if v_numlvl_old not between global_v_numlvlsalst and global_v_numlvlsalen then
            if obj_row3 between global_v_numlvlsalst and global_v_numlvlsalen then
                param_msg_error := get_error_msg_php('HR3012', global_v_lang);
                json_str_output := get_response_message('403', param_msg_error, global_v_lang);
                return;
            end if;
        end if;

        v_flgsecur := hcm_secur.secur_main7(obj_row1,global_v_coduser);
        if v_flgsecur = 'N' then
			param_msg_error := get_error_msg_php('HR3007', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
        end if;

		IF ( chk_staemp_0 = 0 ) THEN
			param_msg_error := get_error_msg_php('HR2102', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

		IF ( p_codtrn IN ( '0001', '0002', '0003', '0004', '0005', '0006', '0007' ) ) THEN
			param_msg_error := get_error_msg_php('PM0036', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

        if p_dteend is not null then
            if p_dteend < trunc(sysdate) or p_dteend < p_dteeffec then
                param_msg_error := get_error_msg_php('PM0037', global_v_lang);
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                return;
            end if;
        end if;

		IF ( p_dteeffec > p_dteeffpos ) THEN
			param_msg_error := get_error_msg_php('PM0061', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;
        v_approvno := 1;

        v_checkapp := chk_flowmail.check_approve ('HRPM4DE', p_codempid, v_approvno, global_v_codempid, null, null, v_check);
        IF NOT v_checkapp AND v_check = 'HR2010' THEN
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            return;
        END IF;

        BEGIN
            SELECT typmove
              INTO v_typmove
              FROM tcodmove
             WHERE codcodec = p_codtrn;
        EXCEPTION WHEN no_data_found THEN
            v_typmove := NULL;
        END;

		chk_salary := hcm_util.get_string_t(obj_data, 'pa_chk_salary');

        if v_typmove = 'A' and chk_salary = 'N' then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang,'v_adjamt1');
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            return;
        end if;

		BEGIN
			SELECT codcomp, codpos, numlvl, codjob, codempmt, typemp,
                   typpayroll, codbrlc, flgatten, codcalen, jobgrade, codgrpgl, codsex
			  INTO tp1_codcomp, tp1_codpos, tp1_numlvl, tp1_codjob, tp1_codempmt, tp1_typemp,
                   tp1_typpayroll, tp1_codbrlc, tp1_flgatten, tp1_codcalen, tp1_jobgrade, tp1_codgrpgl, tp1_codsex
			  FROM temploy1
			 WHERE codempid = p_codempid;
		EXCEPTION WHEN no_data_found THEN
			NULL;
		END;

--        if tp1_codpos <> obj_row2 then
--            if v_typmove <> '8' then
--                param_msg_error := get_error_msg_php('PM0128', global_v_lang);
--                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
--                return;
--            end if;
--        end if;

        if v_typmove = '8' and tp1_codpos = obj_row2 then
            param_msg_error := get_error_msg_php('PM0129', global_v_lang);
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            return;
        end if;


        if p_numreqst is not null then
            begin
                select stareq, numreqc
                  into x_stareq ,x_numreqc
                  from temploy1
                 where codempid = p_codempid;
            exception when others then
                null;
            end;

            if x_numreqc = p_numreqst and x_stareq = '51' then
                null;
            else
                begin
                    select stareq
                      into v_stareq
                      from treqest1
                     where numreqst = p_numreqst;

                    if v_stareq = 'C' then
                        param_msg_error := get_error_msg_php('HR4502', global_v_lang,'TREQEST1');
                        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                        return;
--                        msg_error('TREQEST1','HR4502','ttmovemt.numreqst');
                    elsif v_stareq = 'X' then
                        param_msg_error := get_error_msg_php('HR5006', global_v_lang,'TREQEST1');
                        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                        return;
--                        msg_error('TREQEST1','HR5006','ttmovemt.numreqst');
                    else
                        begin
                            select qtyact, qtyreq
                              into v_qtyact, v_qtyreq
                              from treqest2
                             where numreqst = p_numreqst
                               and codpos = obj_row2;

                            if v_qtyact + 1 > v_qtyreq then
                                param_msg_error := get_error_msg_php('HR4502', global_v_lang,'TREQEST2');
                                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                                return;
--                                msg_error('TREQEST2','HR4502','ttmovemt.numreqst');
                            end if;
                        exception when no_data_found then
                            param_msg_error := get_error_msg_php('HR5005', global_v_lang,'TREQEST2');
                            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                            return;
--                            msg_error('TREQEST2','HR5005','ttmovemt.numreqst');
                        end;
                    end if;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TREQEST1');
                    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                    return;
--                    msg_error('TREQEST1','HR2010','ttmovemt.numreqst');
                end;
            end if;
        end if;

		IF ( p_flag = 'update' ) THEN
			obj_row := json_object_t();

			if (chk_salary = 'Y') then
				p_paramssalary := hcm_util.get_json_t(obj_data,'params');
				obj_row := json_object_t();

				v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(obj_row1, 1)
                            || ''',"p_dteeffec":''' || NULL
                            || ''',"p_codempmt":''' || obj_row5
                            || ''',"p_lang":''' || global_v_lang || '''}');
				param_json := json_object_t(v_datasal);

				FOR i IN 1..p_paramssalary.get_size LOOP
					param_json_row          := hcm_util.get_json_t(param_json, TO_CHAR(i-1));
					obj_row                 := hcm_util.get_json_t(p_paramssalary, TO_CHAR(i - 1));
					v_amtmax_param_json_row := hcm_util.get_string_t(param_json_row, 'amtmax');
					salchage                := hcm_util.get_string_t(obj_row, 'salchage');
					amtmax                  := hcm_util.get_string_t(obj_row, 'amtmax');
					sumsal                  := hcm_util.get_string_t(obj_row, 'sumsal');
                    pctadj                  := hcm_util.get_string_t(obj_row, 'persent');

					if ( sumsal > v_amtmax_param_json_row ) then
						param_msg_error     := get_error_msg_php('PM0066', global_v_lang);
						json_str_output     := get_response_message('403', param_msg_error, global_v_lang);
						ROLLBACK;
						return;
					end if;

					BEGIN
						sqlupdate := 'UPDATE TTMOVEMT SET
                                    AMTINCOM' || i || ' = ''' || stdenc(sumsal, p_codempid, global_v_chken) || ''',
                                    AMTINCADJ' || i || ' = ''' || stdenc(salchage, p_codempid, global_v_chken) || ''',
                                    PCTADJ' || i || ' = ''' || pctadj || '''
                                    WHERE codempid = ''' || p_codempid || '''
                                    and to_char(dteeffec,''YYYY-MM-DD '')|| ''00:00:00'' = ''' || p_dteeffec || '''
                                    AND numseq = ''' || p_numseq || '''
                                    AND codtrn = ''' || p_codtrn || ''' ';
						EXECUTE IMMEDIATE sqlupdate;
					END;
				END LOOP;
            else
                update ttmovemt
                   set amtincom1 = null, amtincom2 = NULL,
                       amtincom3 = NULL, amtincom4 = NULL,
                       amtincom5 = NULL, amtincom6 = NULL,
                       amtincom7 = NULL, amtincom8 = NULL,
                       amtincom9 = NULL, amtincom10 = NULL,
                       amtincadj1 = NULL, amtincadj2 = NULL,
                       amtincadj3 = NULL, amtincadj4 = NULL,
                       amtincadj5 = NULL, amtincadj6 = NULL,
                       amtincadj7 = NULL, amtincadj8 = NULL,
                       amtincadj9 = NULL, amtincadj10 = NULL,
                       pctadj1 = NULL, pctadj2 = NULL,
                       pctadj3 = NULL, pctadj4 = NULL,
                       pctadj5 = NULL, pctadj6 = NULL,
                       pctadj7 = NULL, pctadj8 = NULL,
                       pctadj9 = NULL, pctadj10 = NULL
                 where codempid = p_codempid
			       and to_char(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = p_dteeffec
			       and numseq = p_numseq
			       and codtrn = p_codtrn;
			end if;

			UPDATE ttmovemt
			   SET codreq = p_codcreate,
                   codcreate = global_v_coduser,
                   codcurr = pa_codcurr,
                   desnote = p_desnote,
                   stapost2 = p_stapost2,
                   dteend = p_dteend,
                   numreqst = p_numreqst,
                   flgduepr = p_flgduepr,
                   dteduepr = p_dteeffpos,
                   coduser = global_v_coduser,
                   codcomp = obj_row1,
                   codpos = obj_row2,
                   numlvl = obj_row3,
                   codjob = obj_row4,
                   codempmt = obj_row5,
                   typemp = obj_row6,
                   typpayroll = obj_row7,
                   codbrlc = obj_row8,
                   flgatten = obj_row9,
                   codcalen = obj_row10,
                   jobgrade = obj_row11,
                   codgrpgl = obj_row12,
                   flgadjin = chk_salary,
                   amtothr = stdenc(pa_amtothr, p_codempid, global_v_chken)
			 WHERE codempid = p_codempid
			   AND to_char(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = p_dteeffec
			   AND numseq = p_numseq
			   AND codtrn = p_codtrn;
		ELSE
			INSERT INTO ttmovemt ( codreq, dteefstep, codcurr, codcreate, codempid, numseq,
                                   dteeffec, codtrn, stapost2, dteend, numreqst, desnote,
                                   dteduepr, flgduepr, staupd, flgadjin, amtothr, coduser,
                                   flgrp, dteefpos, dteeflvl )
                 VALUES ( p_codcreate, v_dteefstep, pa_codcurr, global_v_coduser, p_codempid, p_numseq,
                          p_dteeffec, p_codtrn, p_stapost2, p_dteend, p_numreqst, p_desnote,
                          p_dteeffpos, p_flgduepr, 'P', chk_salary, stdenc(pa_amtothr, p_codempid, global_v_chken), global_v_coduser,
                          'N', v_dteefpos,v_dteeflvl );
			if (chk_salary = 'Y') then
				p_paramssalary  := hcm_util.get_json_t(obj_data,'params');
				obj_row         := json_object_t();

				v_datasal       := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(obj_row1, 1)
                                    || ''',"p_dteeffec":''' || NULL
                                    || ''',"p_codempmt":''' || obj_row5
                                    || ''',"p_lang":''' || global_v_lang || '''}');
				param_json      := json_object_t(v_datasal);

				FOR i IN 1..p_paramssalary.get_size LOOP
					param_json_row          := hcm_util.get_json_t(param_json, to_char(i-1));
					obj_row                 := hcm_util.get_json_t(p_paramssalary, to_char(i - 1));
					v_amtmax_param_json_row := hcm_util.get_string_t(param_json_row, 'amtmax');
					salchage                := hcm_util.get_string_t(obj_row, 'salchage');
					amtmax                  := hcm_util.get_string_t(obj_row, 'amtmax');
					sumsal                  := hcm_util.get_string_t(obj_row, 'sumsal');
                    pctadj                  := hcm_util.get_string_t(obj_row, 'persent');
					IF ( sumsal > v_amtmax_param_json_row ) then
						param_msg_error     := get_error_msg_php('PM0066', global_v_lang);
						json_str_output     := get_response_message('403', param_msg_error, global_v_lang);
						ROLLBACK;
						RETURN;
					END IF;
					BEGIN
						sqlupdatesal := 'UPDATE TTMOVEMT SET
                                            AMTINCOM' || i || ' = ''' || stdenc(sumsal, p_codempid, global_v_chken) || ''',
                                            AMTINCADJ' || i || ' = ''' || stdenc(salchage, p_codempid, global_v_chken) || ''',
                                            PCTADJ' || i || ' = ''' || pctadj || '''
                                        WHERE codempid = ''' || p_codempid || '''
                                            and to_char(dteeffec,''YYYY-MM-DD '')|| ''00:00:00'' = ''' || p_dteeffec || '''
                                            AND numseq = ''' || p_numseq || '''
                                            AND codtrn = ''' || p_codtrn || ''' ';
						EXECUTE IMMEDIATE sqlupdatesal;
					END;
				END LOOP;
			end if;
		END IF;


		sqlupdate := 'UPDATE TTMOVEMT SET
            codcompt = ''' || tp1_codcomp || ''',
            codposnow = ''' || tp1_codpos || ''',
            numlvlt = ''' || tp1_numlvl || ''',
            codjobt = ''' || tp1_codjob || ''',
            codempmtt = ''' || tp1_codempmt || ''',
            typempt = ''' || tp1_typemp || ''',
            typpayrolt = ''' || tp1_typpayroll || ''',
            codbrlct = ''' || tp1_codbrlc || ''',
            flgattet = ''' || tp1_flgatten || ''',
            codcalet = ''' || tp1_codcalen || ''',
            jobgradet = ''' || tp1_jobgrade || ''',
            codgrpglt = ''' || tp1_codgrpgl || ''',
            codcomp = ''' || obj_row1 || ''',
            codpos = ''' || obj_row2 || ''',
            numlvl = ''' || obj_row3 || ''',
            codjob = ''' || obj_row4 || ''',
            codempmt = ''' || obj_row5 || ''',
            typemp = ''' || obj_row6 || ''',
            typpayroll = ''' || obj_row7 || ''',
            codbrlc = ''' || obj_row8 || ''',
            flgatten = ''' || obj_row9 || ''',
            codcalen = ''' || obj_row10 || ''',
            jobgrade = ''' || obj_row11 || ''',
            codgrpgl = ''' || obj_row12 || ''',
            codsex = ''' || tp1_codsex || '''
            WHERE codempid = ''' || p_codempid || '''
            and to_char(dteeffec,''YYYY-MM-DD '')|| ''00:00:00'' = ''' || p_dteeffec || '''
            AND numseq = ''' || p_numseq || '''
            AND codtrn = ''' || p_codtrn || ''' ';
		EXECUTE IMMEDIATE sqlupdate;
		param_msg_error := get_error_msg_php('HR2401', global_v_lang);
		json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		return;
	END savedata;

	PROCEDURE getdetail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN

		obj_row := json_object_t();
		initial_value(json_str_input);
		gendetail(json_str_output);
	END getdetail;

	PROCEDURE gendetail ( json_str_output OUT CLOB ) IS
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		v_rcnt			    NUMBER;
		v_total             p_num;
		v_adjust            p_num;
		v_amont             p_num;
        data_modal          json_object_t;
		countloop		    NUMBER := 0;
		v_countrow_ttmovemt	NUMBER;
		v_total2            p_num;
		v_adjust2           p_num;
		v_amont2            p_num;
		v_total3            p_num;
		v_adjust3           p_num;
		v_amont3            p_num;
		obj_row1		    json_object_t;
		obj_row2		    json_object_t;
		obj_row3		    json_object_t;
		obj_row4		    json_object_t;
		obj_row5		    json_object_t;
		obj_row6		    json_object_t;
		obj_row7		    json_object_t;
		obj_row8		    json_object_t;
		obj_row9		    json_object_t;
		obj_row10		    json_object_t;
		obj_row11		    json_object_t;
		obj_row12		    json_object_t;
		obj_data1		    json_object_t;
		obj_data2		    json_object_t;
		obj_data3		    json_object_t;
		obj_data4		    json_object_t;
		obj_data5		    json_object_t;
		obj_data6		    json_object_t;
		obj_data7		    json_object_t;
		obj_data8		    json_object_t;
		obj_data9		    json_object_t;
		obj_data10		    json_object_t;
		obj_data11		    json_object_t;
		obj_data12		    json_object_t;
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		obj_data_sal		json_object_t;
		obj_sal			    json_object_t;
		obj_sal_sum		    json_object_t;
		obj_field		    json_object_t := json_object_t();
		v_codcomp		    ttmovemt.codcomp%TYPE;
		v_codpos		    ttmovemt.codpos%TYPE;
        v_codtrn            ttmovemt.codtrn%TYPE;
		v_numlvl		    ttmovemt.numlvl%TYPE;
		v_codjob		    ttmovemt.codjob%TYPE;
		v_codempmt		    ttmovemt.codempmt%TYPE;
		v_typemp		    ttmovemt.typemp%TYPE;
		v_typpayroll		ttmovemt.typpayroll%TYPE;
		v_codbrlc		    ttmovemt.codbrlc%TYPE;
		v_flgatten		    ttmovemt.flgatten%TYPE;
		v_codcalen		    ttmovemt.codcalen%TYPE;
		v_jobgrade		    ttmovemt.jobgrade%TYPE;
		v_codgrpgl		    ttmovemt.codgrpgl%TYPE;
		v_codcompt		    ttmovemt.codcompt%TYPE;
		v_codposnow		    ttmovemt.codposnow%TYPE;
		v_numlvlt		    ttmovemt.numlvlt%TYPE;
		v_codjobt		    ttmovemt.codjobt%TYPE;
		v_codempmtt		    ttmovemt.codempmtt%TYPE;
		v_typempt		    ttmovemt.typempt%TYPE;
		v_typpayrolt		ttmovemt.typpayrolt%TYPE;
		v_codbrlct		    ttmovemt.codbrlct%TYPE;
		v_flgattet		    ttmovemt.flgattet%TYPE;
		v_codcalet		    ttmovemt.codcalet%TYPE;
		v_jobgradet		    ttmovemt.jobgrade%TYPE;
		v_codgrpglt		    ttmovemt.codgrpglt%TYPE;
		v_stapost2		    ttmovemt.stapost2%TYPE;
		codincom_dteeffec   VARCHAR(20);
		codincom_codempmt   VARCHAR(20);
		v_datasal           CLOB;
		paramsearchdetail	json_object_t;
		v_amtothr_income	NUMBER := 0;
		v_amtday_income		NUMBER := 0;
		v_sumincom_income	NUMBER := 0;
		v_amtothr_adj		NUMBER := 0;
		v_amtday_adj		NUMBER := 0;
		v_sumincom_adj		NUMBER := 0;
		v_amtothr_simple	NUMBER := 0;
		v_amtday_simple		NUMBER := 0;
		v_sumincom_simple	NUMBER := 0;
		sal_amtincom        p_num;
		sal_amtincadj       p_num;
        sal_pctadj          p_num;
		param_json		    json_object_t;
		obj_sum			    json_object_t;
		v_countday		    VARCHAR2(200 CHAR);
		obj_rowsal		    json_object_t;
		param_json_row		json_object_t;
		v_codincom		    tinexinf.codpay%TYPE;
		v_desincom		    tinexinf.descpaye%TYPE;
		cnt_row			    NUMBER := 0;
		v_desunit		    VARCHAR2(150 CHAR);
		v_amtmax		    NUMBER;
		v_amount		    NUMBER;
		v_row			    NUMBER := 0;
		obj_data_salary		json_object_t;
		temp1_codcomp		temploy1.codcomp%TYPE;
		temp1_codpos		temploy1.codpos%TYPE;
		temp1_numlvl		temploy1.numlvl%TYPE;
		temp1_codjob		temploy1.codjob%TYPE;
		temp1_codempmt		temploy1.codempmt%TYPE;
		temp1_typemp		temploy1.typemp%TYPE;
		temp1_typpayroll	temploy1.typpayroll%TYPE;
		temp1_codbrlc		temploy1.codbrlc%TYPE;
		temp1_flgatten		temploy1.flgatten%TYPE;
		temp1_codcalen		temploy1.codcalen%TYPE;
		temp1_jobgrade		temploy1.jobgrade%TYPE;
		temp1_codgrpgl		temploy1.codgrpgl%TYPE;
		tt_stapost2		    ttmovemt.stapost2%TYPE;
		tt_flgduepr		    ttmovemt.flgduepr%TYPE;
		v_flgtype		    NUMBER;
		sal_amtmax          p_num;
		data_in             CLOB;
		data_out            CLOB;
		paramjson		    json_object_t;
		objtemp			    json_object_t;
        v_ocodempid         VARCHAR2(2000 CHAR);
        v_flgadjin          ttmovemt.flgadjin%type;

		CURSOR detailmodal IS
            SELECT *
              FROM thismove
             WHERE codempid = detail_codempid
                or v_ocodempid  like '%' || codempid  || '%'
          order by dteeffec desc, numseq;

		CURSOR c1 IS
            SELECT ttmovemt.*,
                   ttmovemt.rowid
              FROM ttmovemt
             WHERE codempid = detail_codempid
               AND dteeffec = detail_dteeffec
               AND numseq = detail_numseq
               AND codtrn = detail_codtrn;

		flgpass			    BOOLEAN;
		v_qtybud		    NUMBER;
		modal_tab		    json_object_t;
		v_qtyman		    NUMBER;
		v_qtyret		    NUMBER;
		v_qtynew1		    NUMBER;
		v_qtynew2		    NUMBER;
		v_qtynew		    NUMBER;
		v_qtywip		    NUMBER;
		v_qtywipemp		    NUMBER;
		v_qtyvac		    NUMBER;
		detail_modal		json_object_t;
		chk_staemp_9		temploy1.staemp%TYPE;
		v_dteempmt		    temploy1.dteempmt%TYPE;
		v_typmove		    tcodmove.typmove%TYPE;
		temploy3_codcurr	temploy3.codcurr%TYPE;

        v_countttmovemt     number;
	BEGIN
        BEGIN
			SELECT dteempmt
			  INTO v_dteempmt
			  FROM temploy1
			 WHERE codempid = detail_codempid;
		EXCEPTION WHEN no_data_found THEN
			v_dteempmt := NULL;
		END;

        IF ( detail_codtrn IN ( '0001', '0002', '0003', '0004', '0005', '0006', '0007' ) ) THEN
			param_msg_error := get_error_msg_php('PM0036', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

        IF ( v_dteempmt > detail_dteeffec ) THEN
			param_msg_error := get_error_msg_php('PM0061', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		END IF;

        flgsecur := secur_main.secur2(detail_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

        if not flgsecur then
			param_msg_error := get_error_msg_php('HR3007', global_v_lang);
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
        end if;

        BEGIN
            SELECT typmove
              INTO v_typmove
              FROM tcodmove
             WHERE codcodec = detail_codtrn;
        EXCEPTION WHEN no_data_found THEN
            v_typmove := NULL;
        END;

        if v_typmove = 'A' and v_zupdsal ='N' then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            json_str_output := get_response_message('403', param_msg_error, global_v_lang);
            return ;
        end if;

        BEGIN
			SELECT staemp
			  INTO chk_staemp_9
			  FROM temploy1
			 WHERE codempid = detail_codempid;
		EXCEPTION WHEN no_data_found THEN
			chk_staemp_9 := NULL;
		END;

--		IF ( chk_staemp_9 = 9 ) THEN
--			param_msg_error := get_error_msg_php('HR2101', global_v_lang);
--			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
--			return;
--		END IF;

        obj_sum         := json_object_t();
		obj_row         := json_object_t();
		obj_data        := json_object_t();
		v_rcnt          := 0;
		obj_row1        := json_object_t();
		detail_modal    := json_object_t;
		obj_data1       := json_object_t();
		obj_data2       := json_object_t();
		obj_data3       := json_object_t();
		obj_data4       := json_object_t();
		obj_data5       := json_object_t();
		obj_data6       := json_object_t();
		obj_data7       := json_object_t();
		obj_data8       := json_object_t();
		obj_data9       := json_object_t();
		obj_data10      := json_object_t();
		obj_data11      := json_object_t();
		obj_data12      := json_object_t();
		modal_tab       := json_object_t();

        BEGIN
            SELECT count(*)
              INTO v_countttmovemt
              FROM ttmovemt
             WHERE codempid = detail_codempid
               AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
               AND numseq = detail_numseq;
        EXCEPTION WHEN no_data_found THEN
            v_countttmovemt := 0;
        END;

        IF ( v_countttmovemt > 0 ) THEN
			BEGIN
				SELECT ( dteduepr - dteeffec ) + 1 countday,
                        nvl(codcomp,''), nvl(codcompt,''),
                        nvl(codpos,''), nvl(codposnow,''),
                        nvl(numlvl,''), nvl(numlvlt,''),
                        nvl(codjob,''), nvl(codjobt,''),
                        nvl(codempmt,''), nvl(codempmtt,''),
                        nvl(typemp,''), nvl(typempt,''),
                        nvl(typpayroll,''),nvl(typpayrolt,''),
                        nvl(codbrlc,''), nvl(codbrlct,''),
                        nvl(flgatten,''),nvl(flgattet,''),
                        nvl(codcalen,''),nvl(codcalet,''),
                        nvl(jobgrade,''), nvl(jobgradet,''),
                        nvl(codgrpgl,''), nvl(codgrpglt,''),
                        nvl(codtrn,''),
                        flgadjin
				  INTO v_countday,
                       v_codcomp, v_codcompt,
                       v_codpos, v_codposnow,
                       v_numlvl, v_numlvlt,
                       v_codjob, v_codjobt,
                       v_codempmt, v_codempmtt,
                       v_typemp, v_typempt,
                       v_typpayroll, v_typpayrolt,
                       v_codbrlc, v_codbrlct,
                       v_flgatten,v_flgattet,
                       v_codcalen, v_codcalet,
                       v_jobgrade, v_jobgradet,
                       v_codgrpgl, v_codgrpglt,
                       v_codtrn,
                       v_flgadjin
				  FROM ttmovemt
				 WHERE codempid = detail_codempid
				   AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
				   AND numseq = detail_numseq;
			EXCEPTION WHEN no_data_found THEN
				v_countday      := '';
				v_codcompt      := '';
				v_codposnow     := '';
				v_numlvlt       := '';
				v_codjobt       := '';
				v_codempmtt     := '';
				v_typempt       := '';
				v_typpayrolt    := '';
				v_codbrlct      := '';
				v_flgattet      := '';
				v_codcalet      := '';
				v_jobgradet     := '';
				v_codgrpglt     := '';
                v_codtrn        := '';
                v_flgadjin      := 'N';
			END;

            detail_codtrn := v_codtrn;

			obj_data1.put('coderror', '200');
			obj_data1.put('col1', get_label_name('HRPM44U', global_v_lang, 10));
			obj_data1.put('col2', v_codcompt);
			obj_data1.put('col3', v_codcomp);
			obj_data2.put('coderror', '200');
			obj_data2.put('col1', get_label_name('HRPM44U', global_v_lang, 20));
			obj_data2.put('col2', v_codposnow);
			obj_data2.put('col3', v_codpos);
			obj_data3.put('coderror', '200');
			obj_data3.put('col1', get_label_name('HRPM44U', global_v_lang, 30));
			obj_data3.put('col2', v_numlvlt);
			obj_data3.put('col3', v_numlvl);
			obj_data4.put('coderror', '200');
			obj_data4.put('col1', get_label_name('HRPM44U', global_v_lang, 40));
			obj_data4.put('col2', v_codjobt);
			obj_data4.put('col3', v_codjob);
			obj_data5.put('coderror', '200');
			obj_data5.put('col1', get_label_name('HRPM44U', global_v_lang, 50));
			obj_data5.put('col2', v_codempmtt );
			obj_data5.put('col3', v_codempmt);
			obj_data6.put('coderror', '200');
			obj_data6.put('col1', get_label_name('HRPM44U', global_v_lang, 60));
			obj_data6.put('col2', v_typempt );
			obj_data6.put('col3', v_typemp);
			obj_data7.put('coderror', '200');
			obj_data7.put('col1', get_label_name('HRPM44U', global_v_lang, 70));
			obj_data7.put('col2', v_typpayrolt );
			obj_data7.put('col3', v_typpayroll);
			obj_data8.put('coderror', '200');
			obj_data8.put('col1', get_label_name('HRPM44U', global_v_lang, 80));
			obj_data8.put('col2', v_codbrlct );
			obj_data8.put('col3', v_codbrlc);
			obj_data9.put('coderror', '200');
			obj_data9.put('col1', get_label_name('HRPM44U', global_v_lang, 90));
			obj_data9.put('col2', v_flgattet );
			obj_data9.put('col3', v_flgatten);
			obj_data10.put('coderror', '200');
			obj_data10.put('col1', get_label_name('HRPM44U', global_v_lang, 100));
			obj_data10.put('col2', v_codcalet );
			obj_data10.put('col3', v_codcalen);
			obj_data11.put('coderror', '200');
			obj_data11.put('col1', get_label_name('HRPM44U', global_v_lang, 110));
			obj_data11.put('col2', v_jobgradet );
			obj_data11.put('col3', v_jobgrade);
			obj_data12.put('coderror', '200');
			obj_data12.put('col1', get_label_name('HRPM44U', global_v_lang, 120));
			obj_data12.put('col2', v_codgrpglt );
			obj_data12.put('col3', v_codgrpgl);

            FOR r1 IN c1 LOOP
				obj_field := json_object_t();
				obj_field.put('dteeffec', nvl(TO_CHAR(r1.dteeffec, 'dd/mm/yyyy'),''));

				BEGIN
					SELECT typmove
					  INTO v_typmove
					  FROM tcodmove
					 WHERE codcodec = r1.codtrn;
				EXCEPTION WHEN no_data_found THEN
					v_typmove := NULL;
				END;

				obj_field.put('v_typmove', v_typmove);
				obj_field.put('codtrn', r1.codtrn);
				obj_field.put('dteduepr', nvl(to_char(r1.dteduepr, 'dd/mm/yyyy'),''));
				obj_field.put('dteend', nvl(to_char(r1.dteend, 'dd/mm/yyyy'),''));
				obj_field.put('desnote', nvl(r1.desnote,''));
				obj_field.put('codempid', r1.codempid);
				obj_field.put('numreqst', nvl(r1.numreqst,''));
				obj_field.put('stapost2', r1.stapost2);
				obj_field.put('flgduepr', r1.flgduepr);
				obj_field.put('staupd', r1.staupd);
--				IF ( r1.staupd = 'C' OR r1.staupd = 'U' ) THEN
				IF ( r1.staupd = 'C' OR r1.staupd = 'U' OR r1.staupd = 'A' OR r1.staupd = 'N') THEN
					obj_field.put('staupd_boolean', true);
					obj_field.put('staupd_alert', get_msgerror('HR1500', global_v_lang));
				ELSE
					obj_field.put('staupd_boolean', false);
				END IF;
				obj_field.put('numseq', r1.numseq);
                if r1.staupd not in  ('U','N') then
                    obj_field.put('flag', 'update');
                else
                    obj_field.put('flag', '');
                end if;
				obj_field.put('rowid', r1.rowid);
				obj_field.put('countday', nvl(v_countday,''));
				obj_field.put('codcreate', get_codempid(r1.codcreate));
				obj_field.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
				obj_field.put('coduser', get_codempid(r1.coduser));
				obj_field.put('desc_coduser', r1.coduser || ' - ' || get_temploy_name(get_codempid(r1.coduser), global_v_lang));
				obj_field.put('codcurr', nvl(r1.codcurr,''));
			END LOOP;

            if v_flgadjin = 'Y' then
                BEGIN
                    SELECT stddec(amtincom1, codempid, global_v_chken), stddec(amtincom2, codempid, global_v_chken),
                           stddec(amtincom3, codempid, global_v_chken), stddec(amtincom4, codempid, global_v_chken),
                           stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken),
                           stddec(amtincom7, codempid, global_v_chken), stddec(amtincom8, codempid, global_v_chken),
                           stddec(amtincom9, codempid, global_v_chken), stddec(amtincom10, codempid, global_v_chken)
                      INTO sal_amtincom(1), sal_amtincom(2),
                           sal_amtincom(3), sal_amtincom(4),
                           sal_amtincom(5), sal_amtincom(6),
                           sal_amtincom(7), sal_amtincom(8),
                           sal_amtincom(9), sal_amtincom(10)
                      FROM ttmovemt
                     WHERE codempid = detail_codempid
                       AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
                       AND numseq = detail_numseq
                       AND codtrn = detail_codtrn;
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

                BEGIN
                    SELECT stddec(amtincadj1, codempid, global_v_chken), stddec(amtincadj2, codempid, global_v_chken),
                           stddec(amtincadj3, codempid, global_v_chken), stddec(amtincadj4, codempid, global_v_chken),
                           stddec(amtincadj5, codempid, global_v_chken), stddec(amtincadj6, codempid, global_v_chken),
                           stddec(amtincadj7, codempid, global_v_chken), stddec(amtincadj8, codempid, global_v_chken),
                           stddec(amtincadj9, codempid, global_v_chken), stddec(amtincadj10, codempid, global_v_chken),
                           pctadj1, pctadj2, pctadj3, pctadj4, pctadj5,
                           pctadj6, pctadj7, pctadj8, pctadj9, pctadj10
                      INTO sal_amtincadj(1), sal_amtincadj(2),
                           sal_amtincadj(3), sal_amtincadj(4),
                           sal_amtincadj(5), sal_amtincadj(6),
                           sal_amtincadj(7), sal_amtincadj(8),
                           sal_amtincadj(9), sal_amtincadj(10),
                           sal_pctadj(1), sal_pctadj(2),
                           sal_pctadj(3), sal_pctadj(4),
                           sal_pctadj(5), sal_pctadj(6),
                           sal_pctadj(7), sal_pctadj(8),
                           sal_pctadj(9), sal_pctadj(10)
                      FROM ttmovemt
                     WHERE codempid = detail_codempid
                       AND to_char(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
                       AND numseq = detail_numseq
                       AND codtrn = detail_codtrn;
                EXCEPTION WHEN no_data_found THEN
                    sal_amtincadj(1) := 0;
                    sal_amtincadj(2) := 0;
                    sal_amtincadj(3) := 0;
                    sal_amtincadj(4) := 0;
                    sal_amtincadj(5) := 0;
                    sal_amtincadj(6) := 0;
                    sal_amtincadj(7) := 0;
                    sal_amtincadj(8) := 0;
                    sal_amtincadj(9) := 0;
                    sal_amtincadj(10) := 0;
                    sal_pctadj(1) := 0;
                    sal_pctadj(2) := 0;
                    sal_pctadj(3) := 0;
                    sal_pctadj(4) := 0;
                    sal_pctadj(5) := 0;
                    sal_pctadj(6) := 0;
                    sal_pctadj(7) := 0;
                    sal_pctadj(8) := 0;
                    sal_pctadj(9) := 0;
                    sal_pctadj(10) := 0;
                END;
            else
				BEGIN
					SELECT greatest(0,stddec(amtincom1, codempid, global_v_chken)),
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
					 WHERE codempid = detail_codempid;
				EXCEPTION WHEN no_data_found THEN
					sal_amtincom(1)     := 0;
					sal_amtincom(2)     := 0;
					sal_amtincom(3)     := 0;
					sal_amtincom(4)     := 0;
					sal_amtincom(5)     := 0;
					sal_amtincom(6)     := 0;
					sal_amtincom(7)     := 0;
					sal_amtincom(8)     := 0;
					sal_amtincom(9)     := 0;
					sal_amtincom(10)    := 0;
				END;
                    sal_amtincadj(1) := 0;
                    sal_amtincadj(2) := 0;
                    sal_amtincadj(3) := 0;
                    sal_amtincadj(4) := 0;
                    sal_amtincadj(5) := 0;
                    sal_amtincadj(6) := 0;
                    sal_amtincadj(7) := 0;
                    sal_amtincadj(8) := 0;
                    sal_amtincadj(9) := 0;
                    sal_amtincadj(10) := 0;
                    sal_pctadj(1) := 0;
                    sal_pctadj(2) := 0;
                    sal_pctadj(3) := 0;
                    sal_pctadj(4) := 0;
                    sal_pctadj(5) := 0;
                    sal_pctadj(6) := 0;
                    sal_pctadj(7) := 0;
                    sal_pctadj(8) := 0;
                    sal_pctadj(9) := 0;
                    sal_pctadj(10) := 0;
            end if;

            BEGIN
				SELECT to_char(( SELECT MAX(dteeffec)
                                   FROM tcontpms
                                  WHERE codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)), 'ddmmyyyy')
				  INTO codincom_dteeffec
				  FROM temploy1
				 WHERE codempid = detail_codempid;
			EXCEPTION WHEN no_data_found THEN
				codincom_dteeffec := NULL;
				codincom_codempmt := NULL;
			END;

            v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcomp, 1)
                        || ''',"p_dteeffec":''' || NULL
                        || ''',"p_codempmt":''' || v_codempmt
                        || ''',"p_lang":''' || global_v_lang || '''}');
			param_json := json_object_t(v_datasal);
            obj_rowsal := json_object_t();
			v_row := -1;

            FOR i IN 0..9 LOOP
				sal_amtmax(i+1) := 0;
			end loop;
            FOR i IN 0..param_json.get_size - 1 LOOP
				param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
				v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
				v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
				v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
				v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
				IF v_codincom IS NULL OR v_codincom = ' ' THEN
					EXIT;
				END IF;
				v_row           := v_row + 1;
				obj_data_salary := json_object_t();
				obj_data_salary.put('codincom', v_codincom);
				obj_data_salary.put('desincom', v_desincom);
				obj_data_salary.put('desunit', v_desunit);
				obj_data_salary.put('amtmax', sal_amtincom(i+1)- sal_amtincadj(i + 1));
				obj_data_salary.put('amtmax_hide', sal_amtincom(i+1)-sal_amtincadj(i + 1));

				IF ( sal_amtincom(i + 1)-sal_amtincadj(i + 1) = 0) THEN
					obj_data_salary.put('persent', '0');
				ELSE
					obj_data_salary.put('persent', nvl(to_char(sal_pctadj(i + 1)),''));
--					obj_data_salary.put('persent', (sal_amtincadj(i + 1) / (sal_amtincom(i + 1)-sal_amtincadj(i + 1))) * 100);
				END IF;
				obj_data_salary.put('salchage', sal_amtincadj(i + 1));
				obj_data_salary.put('sumsal', sal_amtincom(i+1));

				obj_data_salary.put('sumsal_hidden', sal_amtincom(i+1));
				sal_amtmax(i+1) := sal_amtincom(i+1) + sal_amtincadj(i + 1);
				obj_rowsal.put(v_row, obj_data_salary);
			END LOOP;
		ELSE
            IF ( chk_staemp_9 = 9 ) THEN
                param_msg_error := get_error_msg_php('HR2101', global_v_lang);
                json_str_output := get_response_message('403', param_msg_error, global_v_lang);
                return;
            END IF;
            SELECT COUNT(*)
			  INTO v_countrow_ttmovemt
			  FROM ttmovemt
			 WHERE codempid = detail_codempid
			   AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
			   AND numseq = detail_numseq
			   AND codtrn = detail_codtrn;
            IF ( v_countrow_ttmovemt = 0 ) THEN
                begin
                    select codtrn
                      into v_codtrn
                      from ttmovemt
                     where codempid = detail_codempid
                       and to_char(dteeffec,'yyyymmdd')||lpad(numseq,2,'0') > to_char(detail_dteeffec,'yyyymmdd')||lpad(detail_numseq,2,'0')
                       and staupd <> 'N'
                       and rownum = 1;
                    param_msg_error := get_error_msg_php('PM0063', global_v_lang);
                    json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
                    return;
                exception when no_data_found then
                    null;
                end;

                obj_sum.put('set_insert', true);
				obj_field := json_object_t();
				obj_field.put('dteeffec', TO_CHAR(detail_dteeffec, 'dd/mm/yyyy'));
				BEGIN
					SELECT typmove
					  INTO v_typmove
					  FROM tcodmove
					 WHERE codcodec = detail_codtrn;
				EXCEPTION WHEN no_data_found THEN
					v_typmove := NULL;
				END;

                BEGIN
					SELECT codcurr,
                           greatest(0,stddec(amtincom1, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom2, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom3, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom4, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom5, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom6, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom7, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom8, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom9, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom10, codempid, global_v_chken))
					  INTO temploy3_codcurr, sal_amtincom(1), sal_amtincom(2),
                           sal_amtincom(3), sal_amtincom(4),
                           sal_amtincom(5), sal_amtincom(6),
                           sal_amtincom(7), sal_amtincom(8),
                           sal_amtincom(9), sal_amtincom(10)
					  FROM temploy3
					 WHERE codempid = detail_codempid;
				EXCEPTION WHEN no_data_found THEN
					temploy3_codcurr    := NULL;
					sal_amtincom(1)     := 0;
					sal_amtincom(2)     := 0;
					sal_amtincom(3)     := 0;
					sal_amtincom(4)     := 0;
					sal_amtincom(5)     := 0;
					sal_amtincom(6)     := 0;
					sal_amtincom(7)     := 0;
					sal_amtincom(8)     := 0;
					sal_amtincom(9)     := 0;
					sal_amtincom(10)    := 0;
				END;
                BEGIN
					SELECT codcomp, codpos, numlvl, codjob, codempmt, typemp,
                           typpayroll, codbrlc, flgatten, codcalen, jobgrade, codgrpgl
					  INTO temp1_codcomp, temp1_codpos, temp1_numlvl, temp1_codjob, temp1_codempmt, temp1_typemp,
                           temp1_typpayroll, temp1_codbrlc, temp1_flgatten, temp1_codcalen, temp1_jobgrade, temp1_codgrpgl
					  FROM temploy1
					 WHERE codempid = detail_codempid;
				EXCEPTION
				WHEN no_data_found THEN
					temp1_codcomp       := NULL;
					temp1_codpos        := NULL;
					temp1_numlvl        := NULL;
					temp1_codjob        := NULL;
					temp1_codempmt      := NULL;
					temp1_typemp        := NULL;
					temp1_typpayroll    := NULL;
					temp1_codbrlc       := NULL;
					temp1_flgatten      := NULL;
					temp1_codcalen      := NULL;
					temp1_jobgrade      := NULL;
					temp1_codgrpgl      := NULL;
				END;
                BEGIN
					SELECT to_char(( SELECT MAX(dteeffec)
                                      FROM tcontpms
                                     WHERE codcompy = hcm_util.get_codcomp_level(temp1_codcomp, 1)), 'ddmmyyyy'),
                                           codempmt
					  INTO codincom_dteeffec,
                           codincom_codempmt
					  FROM temploy1
					 WHERE codempid = detail_codempid;
				EXCEPTION WHEN no_data_found THEN
					codincom_dteeffec := NULL;
					codincom_codempmt := NULL;
				END;
                v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(temp1_codcomp, 1)
                            || ''',"p_dteeffec":''' || NULL
                            || ''',"p_codempmt":''' || codincom_codempmt
                            || ''',"p_lang":''' || global_v_lang || '''}');
                param_json := json_object_t(v_datasal);
				obj_rowsal := json_object_t();
				v_row := -1;
                for i in 0..9 loop
					sal_amtincadj(i+1) := 0;
				end loop;
                FOR i IN 0..param_json.get_size - 1 LOOP
					param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
					v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
					v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
					v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
					v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
					IF v_codincom IS NULL OR v_codincom = ' ' THEN
						EXIT;
					END IF;

					v_row           := v_row + 1;
					obj_data_salary := json_object_t();
					obj_data_salary.put('codincom', v_codincom);
					obj_data_salary.put('desincom', v_desincom);
					obj_data_salary.put('desunit', v_desunit);
					obj_data_salary.put('amtmax', sal_amtincom(i+1));
					obj_data_salary.put('amtmax_hide', sal_amtincom(i+1));
					obj_data_salary.put('salchage', 0);
					IF ( sal_amtincom(i + 1)-sal_amtincadj(i + 1) = 0) THEN
						obj_data_salary.put('persent', 0);
					ELSE
						obj_data_salary.put('persent', trim(TO_CHAR((sal_amtincadj(i + 1) / (sal_amtincom(i + 1)-sal_amtincadj(i + 1))) * 100, '999,999,990.00')));
					END IF;
					obj_data_salary.put('sumsal', sal_amtincom(i + 1));
					obj_data_salary.put('sumsal_hidden', sal_amtincom(i + 1));
					obj_rowsal.put(v_row, obj_data_salary);
				END LOOP;

				FOR i IN 1..10 LOOP
                    IF ( sal_amtincom(i) IS NULL ) THEN
                        sal_amtincom(i) := 0;
                    END IF;
                END LOOP;

                get_wage_income(hcm_util.get_codcomp_level(temp1_codcomp, 1), codincom_codempmt, sal_amtincom(1), sal_amtincom(2),
                                sal_amtincom(3), sal_amtincom(4), sal_amtincom(5), sal_amtincom(6), sal_amtincom(7), sal_amtincom(8),
                                sal_amtincom(9), sal_amtincom(10), v_amtothr_income, v_amtday_income, v_sumincom_income);

                get_wage_income(hcm_util.get_codcomp_level(temp1_codcomp, 1), codincom_codempmt, 0, 0, 0 , 0, 0, 0, 0, 0, 0, 0,
                                v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

                get_wage_income(hcm_util.get_codcomp_level(temp1_codcomp, 1), codincom_codempmt, sal_amtincom(1) - 0, sal_amtincom(2) - 0,
                                sal_amtincom(3) - 0, sal_amtincom(4) - 0, sal_amtincom(5) - 0 , sal_amtincom(6) - 0, sal_amtincom(7) - 0,
                                sal_amtincom(8) - 0, sal_amtincom(9) - 0, sal_amtincom(10) - 0, v_amtothr_simple, v_amtday_simple, v_sumincom_simple);

                obj_field.put('codcurr', nvl(temploy3_codcurr,''));
                obj_field.put('v_typmove', v_typmove);
                obj_field.put('codtrn', detail_codtrn);
                obj_field.put('codempid', detail_codempid);
                obj_field.put('numseq', detail_numseq);
                obj_field.put('stapost2', '0');
                obj_field.put('flgduepr', 'N');
                obj_field.put('codcreate', global_v_codempid);
                obj_field.put('staupd_boolean', false);

                obj_data1.put('coderror', '200');
                obj_data1.put('col1', get_label_name('HRPM44U', global_v_lang, 10));
                obj_data1.put('col2', temp1_codcomp);
                obj_data1.put('col3', temp1_codcomp);
                obj_data2.put('coderror', '200');
                obj_data2.put('col1', get_label_name('HRPM44U', global_v_lang, 20));
                obj_data2.put('col2', temp1_codpos);
                obj_data2.put('col3', temp1_codpos);
                obj_data3.put('coderror', '200');
                obj_data3.put('col1', get_label_name('HRPM44U', global_v_lang, 30));
                obj_data3.put('col2', temp1_numlvl);
                obj_data3.put('col3', temp1_numlvl);
                obj_data4.put('coderror', '200');
                obj_data4.put('col1', get_label_name('HRPM44U', global_v_lang, 40));
                obj_data4.put('col2', temp1_codjob);
                obj_data4.put('col3', temp1_codjob);
                obj_data5.put('coderror', '200');
                obj_data5.put('col1', get_label_name('HRPM44U', global_v_lang, 50));
                obj_data5.put('col2', temp1_codempmt);
                obj_data5.put('col3', temp1_codempmt);
                obj_data6.put('coderror', '200');
                obj_data6.put('col1', get_label_name('HRPM44U', global_v_lang, 60));
                obj_data6.put('col2', temp1_typemp);
                obj_data6.put('col3', temp1_typemp);
                obj_data7.put('coderror', '200');
                obj_data7.put('col1', get_label_name('HRPM44U', global_v_lang, 70));
                obj_data7.put('col2', temp1_typpayroll);
                obj_data7.put('col3', temp1_typpayroll);
                obj_data8.put('coderror', '200');
                obj_data8.put('col1', get_label_name('HRPM44U', global_v_lang, 80));
                obj_data8.put('col2', temp1_codbrlc);
                obj_data8.put('col3', temp1_codbrlc);
                obj_data9.put('coderror', '200');
                obj_data9.put('col1', get_label_name('HRPM44U', global_v_lang, 90));
                obj_data9.put('col2', temp1_flgatten);
                obj_data9.put('col3', temp1_flgatten);
                obj_data10.put('coderror', '200');
                obj_data10.put('col1', get_label_name('HRPM44U', global_v_lang, 100));
                obj_data10.put('col2', temp1_codcalen);
                obj_data10.put('col3', temp1_codcalen);
                obj_data11.put('coderror', '200');
                obj_data11.put('col1', get_label_name('HRPM44U', global_v_lang, 110));
                obj_data11.put('col2', temp1_jobgrade);
                obj_data11.put('col3', temp1_jobgrade);
                obj_data12.put('coderror', '200');
                obj_data12.put('col1', get_label_name('HRPM44U', global_v_lang, 120));
                obj_data12.put('col2', temp1_codgrpgl);
                obj_data12.put('col3', temp1_codgrpgl);
            ELSE
                obj_sum.put('set_insert', false);
                FOR r1 IN c1 LOOP
                    obj_field := json_object_t();
                    obj_field.put('dteeffec', TO_CHAR(r1.dteeffec, 'dd/mm/yyyy'));
                    BEGIN
                        SELECT typmove
                          INTO v_typmove
                          FROM tcodmove
                         WHERE codcodec = r1.codtrn;
                    EXCEPTION
                    WHEN no_data_found THEN
                        v_typmove := NULL;
                    END;
                    obj_field.put('v_typmove', v_typmove);
                    obj_field.put('codtrn', r1.codtrn);
                    obj_field.put('dteduepr', nvl(to_char(r1.dteduepr, 'dd/mm/yyyy'),''));
                    obj_field.put('dteend', nvl(to_char(r1.dteend, 'dd/mm/yyyy'),''));
                    obj_field.put('desnote', r1.desnote);
                    obj_field.put('codempid', r1.codempid);
                    obj_field.put('numreqst', nvl(r1.numreqst,''));
                    obj_field.put('stapost2', r1.stapost2);
                    obj_field.put('flgduepr', r1.flgduepr);
                    obj_field.put('staupd', r1.staupd);
                    IF ( r1.staupd = 'C' OR r1.staupd = 'U' OR r1.staupd = 'A') THEN
                        obj_field.put('staupd_boolean', true);
                        obj_field.put('staupd_alert', get_msgerror('HR1500', global_v_lang));
                    ELSE
                        obj_field.put('staupd_boolean', false);
                    END IF;
                    obj_field.put('numseq', r1.numseq);
                    if r1.staupd <> 'U' then
                        obj_field.put('flag', 'update');
                    else
                        obj_field.put('flag', '');
                    end if;
                    obj_field.put('rowid', r1.rowid);
                    obj_field.put('countday', nvl(v_countday,''));
                    obj_field.put('codcreate', get_codempid(r1.codcreate));
                    obj_field.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
                    obj_field.put('coduser', r1.coduser || ' - ' || get_temploy_name(get_codempid(r1.coduser), global_v_lang));
                    obj_field.put('codcurr', nvl(r1.codcurr,''));
                END LOOP;

                BEGIN
                    SELECT codcomp, codpos, numlvl, codjob, codempmt, typemp,
                           typpayroll, codbrlc, flgatten, codcalen, jobgrade, codgrpgl
                      INTO temp1_codcomp, temp1_codpos, temp1_numlvl, temp1_codjob, temp1_codempmt, temp1_typemp,
                           temp1_typpayroll, temp1_codbrlc, temp1_flgatten, temp1_codcalen, temp1_jobgrade, temp1_codgrpgl
                      FROM temploy1
                     WHERE codempid = detail_codempid;
                EXCEPTION WHEN no_data_found THEN
                    temp1_codcomp       := NULL;
                    temp1_codpos        := NULL;
                    temp1_numlvl        := NULL;
                    temp1_codjob        := NULL;
                    temp1_codempmt      := NULL;
                    temp1_typemp        := NULL;
                    temp1_typpayroll    := NULL;
                    temp1_codbrlc       := NULL;
                    temp1_flgatten      := NULL;
                    temp1_codcalen      := NULL;
                    temp1_jobgrade      := NULL;
                    temp1_codgrpgl      := NULL;
                END;

                BEGIN
                    SELECT ( dteduepr - dteeffec ) + 1 countday, codcomp, codpos, numlvl, codjob, codempmt,
                           typemp, typpayroll, codbrlc, flgatten, codcalen, jobgrade, codgrpgl
                      INTO v_countday, v_codcompt, v_codposnow, v_numlvlt, v_codjobt, v_codempmtt,
                           v_typempt, v_typpayrolt, v_codbrlct, v_flgattet, v_codcalet, v_jobgradet, v_codgrpglt
                      FROM ttmovemt
                     WHERE codempid = detail_codempid
                       AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
                       AND numseq = detail_numseq
                       AND codtrn = detail_codtrn;
                EXCEPTION WHEN no_data_found THEN
                    v_countday      := NULL;
                    v_codcompt      := NULL;
                    v_codposnow     := NULL;
                    v_numlvlt       := NULL;
                    v_codjobt       := NULL;
                    v_codempmtt     := NULL;
                    v_typempt       := NULL;
                    v_typpayrolt    := NULL;
                    v_codbrlct      := NULL;
                    v_flgattet      := NULL;
                    v_codcalet      := NULL;
                    v_jobgradet     := NULL;
                    v_codgrpglt     := NULL;
                END;

                obj_data1.put('coderror', '200');
                obj_data1.put('col1', get_label_name('HRPM44U', global_v_lang, 10));
                obj_data1.put('col2', v_codcompt);
                obj_data1.put('col3', temp1_codcomp);
                obj_data2.put('coderror', '200');
                obj_data2.put('col1', get_label_name('HRPM44U', global_v_lang, 20));
                obj_data2.put('col2', v_codposnow);
                obj_data2.put('col3', temp1_codpos);
                obj_data3.put('coderror', '200');
                obj_data3.put('col1', get_label_name('HRPM44U', global_v_lang, 30));
                obj_data3.put('col2', v_numlvlt);
                obj_data3.put('col3', temp1_numlvl);
                obj_data4.put('coderror', '200');
                obj_data4.put('col1', get_label_name('HRPM44U', global_v_lang, 40));
                obj_data4.put('col2', v_codjobt);
                obj_data4.put('col3', temp1_codjob);
                obj_data5.put('coderror', '200');
                obj_data5.put('col1', get_label_name('HRPM44U', global_v_lang, 50));
                obj_data5.put('col2', v_codempmtt);
                obj_data5.put('col3', temp1_codempmt);
                obj_data6.put('coderror', '200');
                obj_data6.put('col1', get_label_name('HRPM44U', global_v_lang, 60));
                obj_data6.put('col2', v_typempt);
                obj_data6.put('col3', temp1_typemp);
                obj_data7.put('coderror', '200');
                obj_data7.put('col1', get_label_name('HRPM44U', global_v_lang, 70));
                obj_data7.put('col2', v_typpayrolt);
                obj_data7.put('col3', temp1_typpayroll);
                obj_data8.put('coderror', '200');
                obj_data8.put('col1', get_label_name('HRPM44U', global_v_lang, 80));
                obj_data8.put('col2', v_codbrlct);
                obj_data8.put('col3', temp1_codbrlc);
                obj_data9.put('coderror', '200');
                obj_data9.put('col1', get_label_name('HRPM44U', global_v_lang, 90));
                obj_data9.put('col2', v_flgattet);
                obj_data9.put('col3', temp1_flgatten);
                obj_data10.put('coderror', '200');
                obj_data10.put('col1', get_label_name('HRPM44U', global_v_lang, 100));
                obj_data10.put('col2', v_codcalet);
                obj_data10.put('col3', temp1_codcalen);
                obj_data11.put('coderror', '200');
                obj_data11.put('col1', get_label_name('HRPM44U', global_v_lang, 110));
                obj_data11.put('col2', v_jobgradet);
                obj_data11.put('col3', temp1_jobgrade);
                obj_data12.put('coderror', '200');
                obj_data12.put('col1', get_label_name('HRPM44U', global_v_lang, 120));
                obj_data12.put('col2', v_codgrpglt);
                obj_data12.put('col3', temp1_codgrpgl);
                BEGIN
                    SELECT stddec(amtincom1, codempid, global_v_chken), stddec(amtincom2, codempid, global_v_chken),
                           stddec(amtincom3, codempid, global_v_chken), stddec(amtincom4, codempid, global_v_chken),
                           stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken),
                           stddec(amtincom7, codempid, global_v_chken), stddec(amtincom8, codempid, global_v_chken),
                           stddec(amtincom9, codempid, global_v_chken), stddec(amtincom10, codempid, global_v_chken)
                      INTO sal_amtincom(1), sal_amtincom(2),
                           sal_amtincom(3), sal_amtincom(4),
                           sal_amtincom(5), sal_amtincom(6),
                           sal_amtincom(7), sal_amtincom(8),
                           sal_amtincom(9), sal_amtincom(10)
                      FROM ttmovemt
                     WHERE codempid = detail_codempid
                       AND to_char(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
                       AND numseq = detail_numseq
                       AND codtrn = detail_codtrn;
                EXCEPTION WHEN no_data_found THEN
                    sal_amtincom(1)     := 0;
                    sal_amtincom(2)     := 0;
                    sal_amtincom(3)     := 0;
                    sal_amtincom(4)     := 0;
                    sal_amtincom(5)     := 0;
                    sal_amtincom(6)     := 0;
                    sal_amtincom(7)     := 0;
                    sal_amtincom(8)     := 0;
                    sal_amtincom(9)     := 0;
                    sal_amtincom(10)    := 0;
                END;

                BEGIN
                    SELECT stddec(amtincadj1, codempid, global_v_chken), stddec(amtincadj2, codempid, global_v_chken),
                           stddec(amtincadj3, codempid, global_v_chken), stddec(amtincadj4, codempid, global_v_chken),
                           stddec(amtincadj5, codempid, global_v_chken), stddec(amtincadj6, codempid, global_v_chken),
                           stddec(amtincadj7, codempid, global_v_chken), stddec(amtincadj8, codempid, global_v_chken),
                           stddec(amtincadj9, codempid, global_v_chken), stddec(amtincadj10, codempid, global_v_chken)
                      INTO sal_amtincadj(1), sal_amtincadj(2),
                           sal_amtincadj(3), sal_amtincadj(4),
                           sal_amtincadj(5), sal_amtincadj(6),
                           sal_amtincadj(7), sal_amtincadj(8),
                           sal_amtincadj(9), sal_amtincadj(10)
                      FROM ttmovemt
                     WHERE codempid = detail_codempid
                       AND TO_CHAR(dteeffec, 'YYYY-MM-DD') || ' 00:00:00' = detail_dteeffec
                       AND numseq = detail_numseq
                       AND codtrn = detail_codtrn;
                EXCEPTION WHEN no_data_found THEN
                    sal_amtincadj(1) := 0;
                    sal_amtincadj(2) := 0;
                    sal_amtincadj(3) := 0;
                    sal_amtincadj(4) := 0;
                    sal_amtincadj(5) := 0;
                    sal_amtincadj(6) := 0;
                    sal_amtincadj(7) := 0;
                    sal_amtincadj(8) := 0;
                    sal_amtincadj(9) := 0;
                    sal_amtincadj(10) := 0;
                END;

                BEGIN
                    SELECT TO_CHAR(( SELECT MAX(dteeffec)
                                       FROM tcontpms
                                      WHERE codcompy = hcm_util.get_codcomp_level(v_codcompt, 1)), 'ddmmyyyy')
                      INTO codincom_dteeffec
                      FROM temploy1
                     WHERE codempid = detail_codempid;
                EXCEPTION WHEN no_data_found THEN
                    codincom_dteeffec := NULL;
                END;

                v_datasal   := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcompt, 1)
                            || ''',"p_dteeffec":''' || NULL
                            || ''',"p_codempmt":''' || v_codempmtt
                            || ''',"p_lang":''' || global_v_lang || '''}');
                param_json  := json_object_t(v_datasal);
                obj_rowsal  := json_object_t();
                v_row       := -1;

                FOR i IN 0..9 LOOP
                    sal_amtmax(i+1) := 0;
                end loop;
                FOR i IN 0..param_json.get_size - 1 LOOP
                    param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
                    v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
                    v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
                    v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
                    v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
                    IF v_codincom IS NULL OR v_codincom = ' ' THEN
                        EXIT;
                    END IF;
                    v_row           := v_row + 1;
                    obj_data_salary := json_object_t();
                    obj_data_salary.put('codincom', v_codincom);
                    obj_data_salary.put('desincom', v_desincom);
                    obj_data_salary.put('desunit', v_desunit);
                    obj_data_salary.put('amtmax', sal_amtincom(i+1)-sal_amtincadj(i + 1));
                    obj_data_salary.put('amtmax_hide', sal_amtincom(i+1)-sal_amtincadj(i + 1));

                    IF ( sal_amtincom(i + 1)-sal_amtincadj(i + 1) = 0) THEN
                        obj_data_salary.put('persent', 0);
                    ELSE
                        obj_data_salary.put('persent', trim(TO_CHAR((sal_amtincadj(i + 1) / (sal_amtincom(i + 1)-sal_amtincadj(i + 1))) * 100, '999,999,990.00')));
                    END IF;
                    obj_data_salary.put('salchage', sal_amtincadj(i + 1));
                    obj_data_salary.put('sumsal', sal_amtincom(i+1));

                    obj_data_salary.put('sumsal_hidden', sal_amtincom(i+1));
                    sal_amtmax(i+1) := sal_amtincom(i+1) + sal_amtincadj(i + 1);
                    obj_rowsal.put(v_row, obj_data_salary);
                END LOOP;
            END IF;
        END IF;

        obj_field.put('chk_salary', '');
        obj_field.put('flgfirstchange', true);
        obj_field.put('v_zupdsal', v_zupdsal);


        v_rcnt      := 0;
        modal_tab   := json_object_t();
        v_ocodempid := replace(replace(get_ocodempid(detail_codempid),'[',''),']','');--User37 #5721 1.PM Module 20/04/2021 get_ocodempid(detail_codempid);

        FOR r1 IN detailmodal loop
            detail_modal := json_object_t();
            v_rcnt      := v_rcnt + 1;
            detail_modal.put('codempid', r1.codempid);
            detail_modal.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            detail_modal.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
            detail_modal.put('codtrn', get_tcodec_name('TCODMOVE',r1.codtrn,global_v_lang));
            detail_modal.put('numseq', r1.numseq);
            detail_modal.put('codcomp',get_tcenter_name( r1.codcomp , global_v_lang));
            detail_modal.put('codpos', get_tpostn_name (r1.codpos ,global_v_lang));
            modal_tab.put(to_char(v_rcnt - 1), detail_modal);
        end loop;

        obj_sum.put('coderror', '200');
        obj_sal     := json_object_t();
        obj_sal_sum := json_object_t();
        obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 650));
        obj_sal.put('sal1', trim(TO_CHAR(v_sumincom_simple, '999,999,990.00')));
        obj_sal.put('sal2', trim(TO_CHAR(v_sumincom_adj, '999,999,990.00')));
        obj_sal.put('sal3', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
        obj_sal_sum.put(0, obj_sal);
        obj_sal     := json_object_t();
        obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 660));
        obj_sal.put('sal1', trim(TO_CHAR(v_amtday_simple, '999,999,990.00')));
        obj_sal.put('sal2', trim(TO_CHAR(v_amtday_adj, '999,999,990.00')));
        obj_sal.put('sal3', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
        obj_sal_sum.put(1, obj_sal);
        obj_sal     := json_object_t();
        obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 670));
        obj_sal.put('sal1', trim(TO_CHAR(v_amtothr_simple, '999,999,990.00')));
        obj_sal.put('sal2', trim(TO_CHAR(v_amtothr_adj, '999,999,990.00')));
        obj_sal.put('sal3', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
        obj_sal_sum.put(2, obj_sal);
        obj_sum.put('obj_sal_sum', obj_sal_sum);
        obj_sum.put('v_datasal', obj_rowsal);

        obj_sum.put('codcomp', obj_data1);
        obj_sum.put('codpos', obj_data2);
        obj_sum.put('numlvl', obj_data3);
        obj_sum.put('codjob', obj_data4);
        obj_sum.put('codempmt', obj_data5);
        obj_sum.put('typemp', obj_data6);
        obj_sum.put('typpayroll', obj_data7);
        obj_sum.put('codbrlc', obj_data8);
        obj_sum.put('flgatten', obj_data9);
        obj_sum.put('codcalen', obj_data10);
        obj_sum.put('jobgrade', obj_data11);
        obj_sum.put('codgrpgl', obj_data12);

        obj_sum.put('tab_open', true);
        obj_sum.put('des', obj_field);
        obj_sum.put('detail_modal', modal_tab);

        BEGIN
            SELECT codcomp, codpos
              into temp1_codcomp,temp1_codpos
              FROM temploy1
             WHERE codempid = detail_codempid;
        EXCEPTION WHEN no_data_found THEN
            temp1_codcomp := NULL;
            temp1_codpos := NULL;
        END;

        data_modal := json_object_t();
        data_modal.put('codpos', temp1_codpos);
        data_modal.put('codcomp', temp1_codcomp);
        obj_sum.put('data_modal', data_modal);

        obj_sum.put('v_qtybud', '');
        obj_sum.put('v_qtyman', '');
        obj_sum.put('v_qtyret', '');
        obj_sum.put('v_qtynew', '');
        obj_sum.put('v_qtyvac', '');

        json_str_output := obj_sum.to_clob;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END gendetail;

	FUNCTION get_msgerror ( v_errorno IN VARCHAR2, v_lang IN VARCHAR2 ) RETURN VARCHAR2 IS
		v_descripe		terrorm.descripe%TYPE;
	BEGIN
		BEGIN
			SELECT DECODE(v_lang, '101', descripe, '102', descript, '103', descrip3, '104', descrip4, '105', descrip5, descripe)
			  INTO v_descripe
			  FROM terrorm
             WHERE errorno = v_errorno;
			RETURN v_errorno || ' ' || v_descripe;
		EXCEPTION
            WHEN no_data_found THEN
                RETURN '';
            WHEN OTHERS THEN
                RETURN '';
		END;
	END get_msgerror;

	PROCEDURE getdelete ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			NUMBER;
		p_dteeffec		ttmovemt.dteeffec%TYPE;
		p_codtrn		ttmovemt.codtrn%TYPE;
		p_codempid		ttmovemt.codempid%TYPE;
        p_numseq        ttmovemt.numseq%type;
		arr_destory		json_object_t;
	BEGIN
		obj_data    := json_object_t(json_str_input);
		arr_destory := hcm_util.get_json_t(obj_data,'params');
		obj_row     := json_object_t();
		v_rcnt      := 0;
		FOR i IN 0..arr_destory.get_size - 1 LOOP
			obj_row     := json_object_t();
			obj_row     := hcm_util.get_json_t(arr_destory,TO_CHAR(i));
			p_codtrn    := hcm_util.get_string_t(obj_row, 'id_codtrn');
			p_dteeffec  := TO_DATE(hcm_util.get_string_t(obj_row, 'dteeffec'), 'dd/mm/yyyy');
			p_codempid  := hcm_util.get_string_t(obj_row, 'codempid');
            p_numseq    := hcm_util.get_string_t(obj_row, 'numseq');

			BEGIN
				DELETE
                  FROM ttmovemt
				 WHERE ( codtrn = p_codtrn )
                   AND staupd = 'P'
				   AND ( dteeffec = p_dteeffec )
				   AND codempid = p_codempid
                   and numseq = p_numseq;
            EXCEPTION WHEN OTHERS THEN
                null;
			END;
		END LOOP;

		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
		return;
	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END getdelete;

	PROCEDURE getsendmail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		json_obj		      json_object_t;
		param_flag		    NUMBER;
		param_codempid		ttmovemt.codempid%TYPE;
		param_numseq		  ttmovemt.numseq%TYPE;
		param_dteeffec		ttmovemt.dteeffec%TYPE;
		param_codtrn		  ttmovemt.codtrn%TYPE;
		global_v_lang		  VARCHAR2(10 CHAR) := '102';
		v_msg_to          clob;
		v_templete_to     clob;
		v_func_appr       tfwmailh.codappap%type;
		v_codform		      tfwmailh.codform%TYPE;

		v_rowid           ROWID;
		param_codcomp		  ttmovemt.codcomp%TYPE;
		param_codpos		  ttmovemt.codpos%TYPE;
		global_v_codempid	VARCHAR2(100 CHAR);
		global_v_coduser	VARCHAR2(100 CHAR);
		v_error			      terrorm.errorno%TYPE;
		obj_respone		    json_object_t;
		obj_respone_data  VARCHAR(500);
		obj_sum			      json_object_t;
        v_approvno    ttmovemt.approvno%type;
	BEGIN
		json_obj            := json_object_t(json_str_input);
		param_flag          := hcm_util.get_string_t(json_obj, 'param_flag');
		param_codempid      := hcm_util.get_string_t(json_obj, 'param_codempid');
		param_numseq        := hcm_util.get_string_t(json_obj, 'param_numseq');
		param_dteeffec      := hcm_util.get_string_t(json_obj, 'param_dteeffec');
		param_codtrn        := hcm_util.get_string_t(json_obj, 'param_codtrn');
		param_codcomp       := hcm_util.get_string_t(json_obj, 'param_codcomp');
		param_codpos        := hcm_util.get_string_t(json_obj, 'param_codpos');
		v_rowid             := hcm_util.get_string_t(json_obj, 'v_rowid');
		global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
		global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
		global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');

        begin
            select nvl(approvno,0) + 1
              into v_approvno
              from ttmovemt
             where rowid = v_rowid;
        exception when no_data_found then
            v_approvno := 1;
        end;

		IF ( param_flag = '1' ) THEN
            v_error := chk_flowmail.send_mail_for_approve('HRPM4DE', param_codempid, global_v_codempid, global_v_coduser, null, 'HRPM44U1', 960, 'E', 'P', v_approvno, null, null,'TTMOVEMT',v_rowid, '1', null);

            IF v_error = '2046' THEN
                param_msg_error     := get_error_msg_php('HR' || v_error, global_v_lang);
                json_str_output     := get_response_message(NULL, param_msg_error, global_v_lang);
                obj_respone         := json_object_t(json_str_output);
                obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
                obj_sum             := json_object_t();
                obj_sum.put('coderror', '200');
                obj_sum.put('flg_send', false);
                obj_sum.put('desc_coderror', obj_respone_data);
                obj_sum.put('response', obj_respone_data);
                json_str_output := obj_sum.to_clob;
            ELSE ---7525
                v_error := 'HR7522';
                param_msg_error     := get_error_msg_php(v_error,global_v_lang);
                json_str_output     := get_response_message(NULL,param_msg_error,global_v_lang);
                return;
            END IF;
		ELSE
			param_msg_error     := get_error_msg_php('HR0007', global_v_lang);
			json_str_output     := get_response_message(NULL, param_msg_error, global_v_lang);
			obj_respone         := json_object_t(json_str_output);
			obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
			obj_sum             := json_object_t();
			obj_sum.put('coderror', '200');
			obj_sum.put('flg_send', true);
			obj_sum.put('desc_coderror', obj_respone_data);
            obj_sum.put('response', obj_respone_data);
			json_str_output := obj_sum.to_clob;
		END IF;
	END getsendmail;

	PROCEDURE getincome ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		TYPE p_num          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		obj_row			      json_object_t;
		dataadj0		      json_object_t;
		v_rcnt			      NUMBER := 0;
		v_codcomp		      temploy1.codcomp%TYPE;
		v_codempid		    temploy1.codempid%TYPE;
		v_codempmt		    temploy1.codempmt%TYPE;
		v_salchage1		    NUMBER;
		v_salchage2		    NUMBER;
		v_salchage3		    NUMBER;
		v_salchage4		    NUMBER;
		v_salchage5		    NUMBER;
		v_salchage6		    NUMBER;
		v_salchage7		    NUMBER;
		v_salchage8		    NUMBER;
		v_salchage9		    NUMBER;
		v_salchage10	    NUMBER;
		v_amtincom1		    NUMBER;
		v_amtincom2		    NUMBER;
		v_amtincom3		    NUMBER;
		v_amtincom4		    NUMBER;
		v_amtincom5		    NUMBER;
		v_amtincom6		    NUMBER;
		v_amtincom7		    NUMBER;
		v_amtincom8		    NUMBER;
		v_amtincom9		    NUMBER;
		v_amtincom10		  NUMBER;
		v_amtothr_income	NUMBER := 0;
		v_amtday_income		NUMBER := 0;
		v_sumincom_income	NUMBER := 0;
		v_amtothr_adj		  NUMBER := 0;
		v_amtday_adj		  NUMBER := 0;
		v_sumincom_adj		NUMBER := 0;
		v_amtothr_simple	NUMBER := 0;
		v_amtday_simple		NUMBER := 0;
		v_sumincom_simple	NUMBER := 0;
		obj_sum			      json_object_t;
		count_arr_income	NUMBER := 0;
		obj_sal_sum		    json_object_t;
		obj_sal			      json_object_t;
		obj_data		      json_object_t;
	BEGIN
		obj_data        := json_object_t(json_str_input);
		v_salchage1     := hcm_util.get_string_t(obj_data, 'dataAdj0');
		v_salchage2     := hcm_util.get_string_t(obj_data, 'dataAdj1');
		v_salchage3     := hcm_util.get_string_t(obj_data, 'dataAdj2');
		v_salchage4     := hcm_util.get_string_t(obj_data, 'dataAdj3');
		v_salchage5     := hcm_util.get_string_t(obj_data, 'dataAdj4');
		v_salchage6     := hcm_util.get_string_t(obj_data, 'dataAdj5');
		v_salchage7     := hcm_util.get_string_t(obj_data, 'dataAdj6');
		v_salchage8     := hcm_util.get_string_t(obj_data, 'dataAdj7');
		v_salchage9     := hcm_util.get_string_t(obj_data, 'dataAdj8');
		v_salchage10    := hcm_util.get_string_t(obj_data, 'dataAdj9');
		v_amtincom1     := hcm_util.get_string_t(obj_data, 'dataIncome0');
		v_amtincom2     := hcm_util.get_string_t(obj_data, 'dataIncome1');
		v_amtincom3     := hcm_util.get_string_t(obj_data, 'dataIncome2');
		v_amtincom4     := hcm_util.get_string_t(obj_data, 'dataIncome3');
		v_amtincom5     := hcm_util.get_string_t(obj_data, 'dataIncome4');
		v_amtincom6     := hcm_util.get_string_t(obj_data, 'dataIncome5');
		v_amtincom7     := hcm_util.get_string_t(obj_data, 'dataIncome6');
		v_amtincom8     := hcm_util.get_string_t(obj_data, 'dataIncome7');
		v_amtincom9     := hcm_util.get_string_t(obj_data, 'dataIncome8');
		v_amtincom10    := hcm_util.get_string_t(obj_data, 'dataIncome9');
		v_codempid      := hcm_util.get_string_t(obj_data, 'dataCodempid');
        v_codempmt      := hcm_util.get_string_t(obj_data, 'codempmt');
        v_codcomp      := hcm_util.get_string_t(obj_data, 'codcomp');

		get_wage_income(v_codcomp, v_codempmt, v_amtincom1,v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                        v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_amtothr_income, v_amtday_income, v_sumincom_income);

		get_wage_income(v_codcomp, v_codempmt, v_salchage1, v_salchage2, v_salchage3, v_salchage4, v_salchage5,
                        v_salchage6, v_salchage7, v_salchage8, v_salchage9, v_salchage10, v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

		get_wage_income(v_codcomp, v_codempmt, v_amtincom1 - v_salchage1, v_amtincom2 - v_salchage2, v_amtincom3 - v_salchage3,
                        v_amtincom4 - v_salchage4, v_amtincom5 - v_salchage5, v_amtincom6 - v_salchage6, v_amtincom7 - v_salchage7,
                        v_amtincom8 - v_salchage8, v_amtincom9 - v_salchage9, v_amtincom10 - v_salchage10, v_amtothr_simple,
                        v_amtday_simple, v_sumincom_simple);

		obj_sum := json_object_t();
		obj_sum.put('coderror', '200');
		obj_sal := json_object_t();
		obj_sal_sum := json_object_t();
        -- Monthly
		obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 650));
		obj_sal.put('sal1', trim(TO_CHAR(v_sumincom_simple, '999,999,990.00')));  -- current
		obj_sal.put('sal2', trim(TO_CHAR(v_sumincom_adj, '999,999,990.00'))); -- Adjust
		obj_sal.put('sal3', trim(TO_CHAR(v_sumincom_income, '999,999,990.00'))); -- New
		obj_sal_sum.put(0, obj_sal);
		obj_sal := json_object_t();
        -- Daily
		obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 660));
		obj_sal.put('sal1', trim(TO_CHAR(v_amtday_simple, '999,999,990.00'))); -- current
		obj_sal.put('sal2', trim(TO_CHAR(v_amtday_adj, '999,999,990.00'))); -- Adjust
		obj_sal.put('sal3', trim(TO_CHAR(v_amtday_income, '999,999,990.00'))); -- New
		obj_sal_sum.put(1, obj_sal);
		obj_sal := json_object_t();
        -- Hour
		obj_sal.put('col', get_label_name('HRPM4DE2', global_v_lang, 670));
		obj_sal.put('sal1', trim(TO_CHAR(v_amtothr_simple, '999,999,990.00'))); -- current
		obj_sal.put('sal2', trim(TO_CHAR(v_amtothr_adj, '999,999,990.00'))); -- Adjust
		obj_sal.put('sal3', trim(TO_CHAR(v_amtothr_income, '999,999,990.00'))); -- New
		obj_sal_sum.put(2, obj_sal);
		obj_sum.put('obj_sal_sum', obj_sal_sum);
		json_str_output := obj_sum.to_clob;
	END getincome;

	PROCEDURE genallowance ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		json_obj		            json_object_t;
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom                    p_num;
		v_sal_allowance                 p_num;
		v_temploy1                      temploy1%rowtype;
		v_ttmovemt                      ttmovemt%rowtype;
		v_flg			                VARCHAR2(10 CHAR);
		v_flg_action	                VARCHAR2(10 CHAR);
		v_datasal                       CLOB;
		get_allowance                   CLOB;
		codincom_dteeffec               VARCHAR(20);
		codincom_codempmt               VARCHAR(20);
		param_json		                json_object_t;
		obj_rowsal		                json_object_t;
		v_row			                NUMBER := 0;
		param_json_row		            json_object_t;
		v_codincom		                tinexinf.codpay%TYPE;
		v_desincom		                tinexinf.descpaye%TYPE;
		cnt_row			                NUMBER := 0;
		v_desunit		                VARCHAR2(150 CHAR);
		v_amtmax		                NUMBER;
		sal_allowance		            NUMBER;
		v_amount		                NUMBER;
		obj_data_salary		            json_object_t;
		param_json_allowance	        json_object_t;
		param_json_row_allowance	    json_object_t;
		obj_sum			                json_object_t;
		v_amtothr_income	            NUMBER := 0;
		v_amtday_income		            NUMBER := 0;
		v_sumincom_income	            NUMBER := 0;
		v_amtothr_adj		            NUMBER := 0;
		v_amtday_adj		            NUMBER := 0;
		v_sumincom_adj		            NUMBER := 0;
		v_amtothr_simple	            NUMBER := 0;
		v_amtday_simple		            NUMBER := 0;
		v_sumincom_simple	            NUMBER := 0;
		obj_sal_sum		                json_object_t;
		v_amtmax_sal                    p_num;
		obj_sal			                json_object_t;
        p_amtincom1adj                  number;
        p_amtincom1new                  number;
        p_amtincom1old                  number;
        p_amtincom1percent              number;
        p_datasal                       json_object_t;
        p_skipGen                       boolean;
	BEGIN
		json_obj                := json_object_t(json_str_input);
		v_ttmovemt.codempid     := hcm_util.get_string_t(json_obj, 'detail_codempid');
		v_ttmovemt.numseq       := hcm_util.get_number_t(json_obj, 'detail_numseq');
		v_ttmovemt.codtrn       := hcm_util.get_string_t(json_obj, 'detail_codtrn');
		v_ttmovemt.dteeffec     := TO_DATE(hcm_util.get_string_t(json_obj, 'detail_dteeffec'), 'dd/mm/yyyy');
		v_flg_action            := hcm_util.get_string_t(json_obj, 'v_flg_action');

		v_ttmovemt.stapost2     := hcm_util.get_string_t(json_obj, 'detail_stapost2');
		v_ttmovemt.flgduepr     := hcm_util.get_string_t(json_obj, 'detail_flgduepr');
		v_ttmovemt.codcomp      := hcm_util.get_string_t(json_obj, 'ttmovemt_codcomp');
		v_ttmovemt.codpos       := hcm_util.get_string_t(json_obj, 'ttmovemt_codpos');
		v_ttmovemt.numlvl       := hcm_util.get_number_t(json_obj, 'ttmovemt_numlvl');
		v_ttmovemt.jobgrade     := hcm_util.get_string_t(json_obj, 'ttmovemt_jobgrade');
		v_ttmovemt.codjob       := hcm_util.get_string_t(json_obj, 'ttmovemt_codjob');
		v_ttmovemt.typpayroll   := hcm_util.get_string_t(json_obj, 'ttmovemt_typpayroll');
		v_ttmovemt.codempmt     := hcm_util.get_string_t(json_obj, 'ttmovemt_codempmt');
		v_ttmovemt.codbrlc      := hcm_util.get_string_t(json_obj, 'ttmovemt_codbrlc');
        p_amtincom1adj          := to_number(hcm_util.get_string_t(json_obj, 'amtincom1adj'));
        p_amtincom1new          := to_number(hcm_util.get_string_t(json_obj, 'amtincom1new'));
        p_amtincom1old          := to_number(hcm_util.get_string_t(json_obj, 'amtincom1old'));
        p_amtincom1percent      := to_number(hcm_util.get_string_t(json_obj, 'amtincom1percent'));
        p_datasal               := hcm_util.get_json_t(json_obj, 'v_datasal');
        p_skipGen               := hcm_util.get_boolean_t(json_obj, 'skipGen');

		IF ( v_ttmovemt.stapost2 IN ( 1, 2 ) AND v_ttmovemt.flgduepr = 'Y' ) THEN
			v_flg := 1;
		ELSE
			v_flg := 2;
		END IF;

		SELECT greatest(0,stddec(amtincom1, codempid, global_v_chken)),
               greatest(0,stddec(amtincom2, codempid, global_v_chken)),
               greatest(0,stddec(amtincom3, codempid, global_v_chken)),
               greatest(0,stddec(amtincom4, codempid, global_v_chken)),
               greatest(0,stddec(amtincom5, codempid, global_v_chken)),
               greatest(0,stddec(amtincom6, codempid, global_v_chken)),
               greatest(0,stddec(amtincom7, codempid, global_v_chken)),
               greatest(0,stddec(amtincom8, codempid, global_v_chken)),
               greatest(0,stddec(amtincom9, codempid, global_v_chken)),
               greatest(0,stddec(amtincom10, codempid, global_v_chken))
		  INTO sal_amtincom(1),
               sal_amtincom(2),
               sal_amtincom(3),
               sal_amtincom(4),
               sal_amtincom(5),
               sal_amtincom(6),
               sal_amtincom(7),
               sal_amtincom(8),
               sal_amtincom(9),
               sal_amtincom(10)
		  FROM temploy3
		 WHERE codempid = v_ttmovemt.codempid;

		FOR i IN 1..10 LOOP IF ( sal_amtincom(i) IS NULL ) THEN
			sal_amtincom(i) := 0;
		END IF;
	END LOOP;
	BEGIN
		SELECT codcomp
		  INTO v_temploy1.codcomp
		  FROM temploy1
		 WHERE codempid = v_ttmovemt.codempid;
	EXCEPTION
	WHEN no_data_found THEN
		v_temploy1.codcomp      := NULL;
	END;
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
                                    || ''',"p_codcomp":''' || v_ttmovemt.codcomp
                                    || ''',"p_codpos":''' || v_ttmovemt.codpos
                                    || ''',"p_numlvl":''' || v_ttmovemt.numlvl
                                    || ''',"p_jobgrade":''' || v_ttmovemt.jobgrade
                                    || ''',"p_codjob":''' || v_ttmovemt.codjob
                                    || ''',"p_typpayroll":''' || v_ttmovemt.typpayroll
                                    || ''',"p_codempmt":''' || v_ttmovemt.codempmt
                                    || ''',"p_codbrlc":''' || v_ttmovemt.codbrlc
                                    || ''',"p_flgtype":''' || v_flg || '''}');
	BEGIN
		SELECT TO_CHAR(( SELECT MAX(dteeffec)
                           FROM tcontpms
                          WHERE codcompy = hcm_util.get_codcomp_level(v_ttmovemt.codcomp, 1)), 'ddmmyyyy')
		  INTO codincom_dteeffec
		  FROM temploy1
		 WHERE codempid = v_ttmovemt.codempid;
	EXCEPTION WHEN no_data_found THEN
		codincom_dteeffec := NULL;
	END;

	v_datasal := hcm_pm.get_codincom('{"p_codcompy":'''
                                || hcm_util.get_codcomp_level(v_ttmovemt.codcomp, 1)
                                || ''',"p_dteeffec":''' || NULL
                                || ''',"p_codempmt":''' || v_ttmovemt.codempmt
                                || ''',"p_lang":''' || global_v_lang || '''}');
	BEGIN
		SELECT greatest(0,stddec(amtincom1, codempid, global_v_chken)),
               greatest(0,stddec(amtincom2, codempid, global_v_chken)),
               greatest(0,stddec(amtincom3, codempid, global_v_chken)),
               greatest(0,stddec(amtincom4, codempid, global_v_chken)),
               greatest(0,stddec(amtincom5, codempid, global_v_chken)),
               greatest(0,stddec(amtincom6, codempid, global_v_chken)),
               greatest(0,stddec(amtincom7, codempid, global_v_chken)),
               greatest(0,stddec(amtincom8, codempid, global_v_chken)),
               greatest(0,stddec(amtincom9, codempid, global_v_chken)),
               greatest(0,stddec(amtincom10, codempid, global_v_chken))
		  INTO sal_amtincom(1),
               sal_amtincom(2),
               sal_amtincom(3),
               sal_amtincom(4),
               sal_amtincom(5),
               sal_amtincom(6),
               sal_amtincom(7),
               sal_amtincom(8),
               sal_amtincom(9),
               sal_amtincom(10)
		  FROM temploy3
		 WHERE codempid = v_ttmovemt.codempid;
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
	v_row                   := -1;

	FOR i IN 0..9 LOOP
		v_sal_allowance(i+1) := 0;
	end loop;

	FOR i IN 0..9 LOOP
		param_json_row              := hcm_util.get_json_t(param_json, TO_CHAR(i));
		param_json_row_allowance    := hcm_util.get_json_t(param_json_allowance, TO_CHAR(i));
		sal_allowance               := hcm_util.get_string_t(param_json_row_allowance, 'amtincom');
		v_codincom                  := hcm_util.get_string_t(param_json_row, 'codincom');
		v_desincom                  := hcm_util.get_string_t(param_json_row, 'desincom');
		v_amtmax                    := hcm_util.get_string_t(param_json_row, 'amtmax');
		v_desunit                   := hcm_util.get_string_t(param_json_row, 'desunit');

        if p_skipGen then
            obj_data_salary             := hcm_util.get_json_t(p_datasal, TO_CHAR(i));
            obj_data_salary.put('desunit', v_desunit);
            p_datasal.put(TO_CHAR(i), obj_data_salary);
            obj_rowsal := p_datasal;
        else
            IF v_codincom IS NULL OR v_codincom = ' ' THEN
                EXIT;
            END IF;
            v_row               := v_row + 1;
            obj_data_salary     := json_object_t();
            obj_data_salary.put('codincom', v_codincom);
            obj_data_salary.put('desincom', v_desincom);
            obj_data_salary.put('desunit', v_desunit);
            obj_data_salary.put('amtmax', sal_amtincom(i + 1));
            obj_data_salary.put('amtmax_hide', sal_amtincom(i + 1));

            -- fix issue #4990
            obj_data_salary.put('persent', 0);
            /*IF sal_amtincom(i + 1) = 0 THEN
                obj_data_salary.put('persent', 0);
            ELSE
                obj_data_salary.put('persent', round((((sal_allowance - sal_amtincom(i + 1)) / sal_amtincom(i + 1)) * 100),2));
            END IF;*/

            if (i = 0) then
                obj_data_salary.put('sumsal',p_amtincom1new );
                obj_data_salary.put('sumsal_hidden', p_amtincom1new);
                obj_data_salary.put('salchage', p_amtincom1adj);
                obj_data_salary.put('persent', nvl(p_amtincom1percent,0));
            else
                obj_data_salary.put('salchage', sal_allowance - sal_amtincom(i + 1));
                obj_data_salary.put('sumsal', sal_allowance );
                obj_data_salary.put('sumsal_hidden', sal_allowance);
            end if;

            IF ( sal_allowance = 0 OR sal_allowance IS NULL OR sal_allowance = '' ) THEN
                v_sal_allowance(i+1) := 0;
            ELSE
                v_sal_allowance(i+1) := sal_allowance;
            END IF;
            obj_rowsal.put(v_row, obj_data_salary);
        end if;
	END LOOP;

	obj_sum := json_object_t();
	obj_sum.put('obj_sal_sum', obj_sal_sum);
	obj_sum.put('coderror', '200');
	obj_sum.put('v_datasal', obj_rowsal);

	json_str_output := obj_sum.to_clob;
END genallowance;

PROCEDURE GetDetailModal (json_str_input IN CLOB,json_str_output OUT CLOB) AS
    json_obj		    json_object_t;
    temp1_codcomp   temploy1.codcomp%type;
    temp1_codpos    temploy1.codpos%type;
    c_q1            number;
    c_q2            number;
    c_q3            number;
    c_q4            number;
    c_q5            number;

    v_qtybud        number;
    v_qtyman        number;
    v_qtyret        number;
    v_qtynew1       number;
    v_qtynew2       number;
    v_qtynew        number;
    v_qtywip        number;
    v_qtywipemp     number;
    v_qtyvac        number;
    obj_sum         json_object_t;
	BEGIN
		json_obj        := json_object_t(json_str_input);
		temp1_codcomp   := hcm_util.get_string_t(json_obj, 'detail_codcomp');
		temp1_codpos    := hcm_util.get_string_t(json_obj, 'detail_codpos');

        begin
            select qtybgman, qtyexman
              into v_qtybud, v_qtyman
              from tmanpwm
             where dteyrbug = extract(year from sysdate)
               and dtemthbug = extract(month from sysdate)
               and codcomp = temp1_codcomp
               and codpos = temp1_codpos;
        exception when no_data_found then
            v_qtybud := null;
            v_qtyman := null;
        end;

        if v_qtybud is null then
            begin
                select qtybudgt
                  into v_qtybud
                  from tbudgetm
                 where dteyrbug = EXTRACT(year FROM sysdate)
                   and codcomp = temp1_codcomp
                   and codpos = temp1_codpos;
            exception when no_data_found then
                v_qtybud := null;
            end;
        end if;

        if v_qtybud is null then
            begin
                select nvl(qtybudgt,0)
                  into v_qtybud
                  from tbudget
                 where dteyrbug = EXTRACT(year FROM sysdate)
                   and codcomp = temp1_codcomp
                   and codpos = temp1_codpos;
            exception when no_data_found then
                v_qtybud := 0;
            end;
        end if;

        if v_qtyman is null then
            begin
            select count(*)
              into v_qtyman
              from temploy1
             where staemp in (1,3)
               and codcomp = temp1_codcomp
               and codpos = temp1_codpos;
            exception when no_data_found then
                v_qtyman := 0;
            end;
        end if;

        begin
            select count(codempid)
              into v_qtyret
              from ttexempt
             where staupd  = 'C'
               and codcomp = temp1_codcomp
               and codpos = temp1_codpos;
        exception when no_data_found then
            v_qtyret := 0;
        end;

        begin
            select count(codempid)
              into v_qtynew1
              from ttrehire
             where staupd  = 'C'
               and codcomp = temp1_codcomp
               and codpos = temp1_codpos;
        exception when no_data_found then
            v_qtynew1 := 0;
        end;

--        begin
--            select count(codempid)
--              into v_qtynew2
--              from temploy1
--             where staemp  = '0'
--               and codcomp = temp1_codcomp
--               and codpos = temp1_codpos;
--        exception when no_data_found then
--            v_qtynew2 := 0;
--        end;
        v_qtynew2 := 0;

        v_qtynew := nvl(v_qtynew1,0) + nvl(v_qtynew2,0);

        begin
            select nvl(sum(nvl(qtyreq,0)),0)
              into v_qtywip
              from treqest1 a, treqest2 b
             where a.numreqst  = b.numreqst
               and a.codcomp = temp1_codcomp
               and b.codpos = temp1_codpos
               and a.stareq = 'P';
        exception when no_data_found then
            v_qtywip := 0;
        end;

        begin
            select count(codempid)
              into v_qtywipemp
              from temploy1
             where codcomp = temp1_codcomp
               and codpos = temp1_codpos
               and staemp = '0';
        exception when no_data_found then
            v_qtywipemp := 0;
        end;

        v_qtywip := greatest ((v_qtywip - v_qtywipemp),0);
        v_qtyvac := nvl(v_qtybud,0) - (nvl(v_qtyman,0) - nvl(v_qtyret,0) + nvl(v_qtynew,0) + nvl(v_qtywip,0));
        v_qtyvac := greatest(v_qtyvac,0);

        obj_sum := json_object_t();
        obj_sum.put('coderror', '200');
        obj_sum.put('v_qtybud', v_qtybud);
        obj_sum.put('v_qtyman', v_qtyman + v_qtynew);
        obj_sum.put('v_qtyret', v_qtyret);
        obj_sum.put('v_qtywip', v_qtywip);
        obj_sum.put('v_qtyvac', v_qtyvac);

        json_str_output := obj_sum.to_clob;

END GetDetailModal;

END hrpm4de;

/
