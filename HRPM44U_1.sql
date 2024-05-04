--------------------------------------------------------
--  DDL for Package Body HRPM44U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM44U" IS
	PROCEDURE initial_value ( json_str IN CLOB ) IS
		json_obj json_object_t;
	BEGIN
		json_obj                := json_object_t(json_str);
		global_v_coduser        := hcm_util.get_string_t(json_obj, 'p_coduser');
		global_v_codpswd        := hcm_util.get_string_t(json_obj, 'p_codpswd');
		global_v_lang           := hcm_util.get_string_t(json_obj, 'p_lang');
		global_v_codempid       := hcm_util.get_string_t(json_obj, 'p_codempid');
		p_codcomp               := hcm_util.get_string_t(json_obj, 'p_codcomp');
		p_dtestr                := TO_DATE(hcm_util.get_string_t(json_obj, 'p_dtestr'), 'dd/mm/yyyy');
		p_dteend                := TO_DATE(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');
		v_tresintw_numqes       := hcm_util.get_string_t(json_obj, 'p_numques');
		p_codempid_query        := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		v_tresintw_numqes_now   := hcm_util.get_string_t(json_obj, 'p_numques_now');
		p_dteeffec              := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'dd/mm/yyyy');
		p_table                 := hcm_util.get_string_t(json_obj, 'p_table');
		p_numseq                := hcm_util.get_string_t(json_obj, 'p_numseq');
		flg_numseq              := hcm_util.get_string_t(json_obj, 'flg_numseq');
		call_from               := hcm_util.get_string_t(json_obj, 'call_from');
		p_codmist               := hcm_util.get_string_t(json_obj, 'p_codmist');
		hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
	END;

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		obj_row			json_object_t;
	BEGIN
		initial_value(json_str_input);
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
		obj_data		    json_object_t;
		obj_row			    json_object_t;
		obj_row2		    json_object_t;
		obj_result		    json_object_t;
		obj_jsonsummany		json_object_t;
		v_typesend		    number;
		v_secur             varchar(2);
		v_rcnt			    number := 0;
		v_data              varchar(1);
		v_check             varchar2(500 char);
		v_approvno          number;
		v_right4ce          boolean;
		v_right4de          boolean;
		v_right4ge          boolean;
		v_right4ie          boolean;
        v_codpos            tsecpos.codpos%type;
        v_stapost2          tsecpos.stapost2%type;
        v_dteend            tsecpos.dteend%type;
        v_numseq            number;

		CURSOR c_ttmistk IS
			SELECT *
			  FROM ttmistk
			 WHERE codcomp LIKE p_codcomp || '%'
			   AND dteeffec BETWEEN p_dtestr AND p_dteend
			   AND (staupd = 'P' OR staupd = 'A')
		  ORDER BY dteeffec,codempid;

		CURSOR c_ttexempt IS
			SELECT *
			  FROM ttexempt
			 WHERE codcomp LIKE p_codcomp || '%'
			   AND dteeffec BETWEEN p_dtestr AND p_dteend
			   AND (staupd = 'P' OR staupd = 'A')
		  ORDER BY dteeffec,codempid ;

		CURSOR c_ttmovemt IS
			SELECT *
			  FROM ttmovemt
			 WHERE codcomp LIKE p_codcomp || '%'
			   AND dteeffec BETWEEN p_dtestr AND p_dteend
			   AND (staupd = 'P' OR staupd = 'A')
			   and codtrn <> '0007'
		  ORDER BY dteeffec,codempid;

		CURSOR c_ttmovemt0007 IS
			SELECT *
			  FROM ttmovemt
			 WHERE codcomp LIKE p_codcomp || '%'
			   AND codtrn = '0007'
			   AND dteeffec BETWEEN p_dtestr AND p_dteend
			   AND (staupd = 'P' OR staupd = 'A')
		  ORDER BY dteeffec,codempid;

	BEGIN
		obj_row := json_object_t();
		obj_row2 := json_object_t();
		obj_data := json_object_t();

		v_right4ce  := chk_flowmail.check_codappr ('HRPM4CE', global_v_codempid);
		v_right4de  := chk_flowmail.check_codappr ('HRPM4DE', global_v_codempid);
		v_right4ge  := chk_flowmail.check_codappr ('HRPM4GE', global_v_codempid);
		v_right4ie  := chk_flowmail.check_codappr ('HRPM4IE', global_v_codempid);

		if not v_right4ce AND not v_right4de AND NOT v_right4ge AND NOT v_right4ie then
			param_msg_error := get_error_msg_php('HR3008', global_v_lang,'tfwmailc');
			json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
			return;
		else
			if v_right4ge then
				FOR r1 IN c_ttmistk LOOP
					v_approvno := nvl(r1.approvno,0) + 1;
                    v_secur2 := secur_main.secur1(r1.codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
					v_flgpass := chk_flowmail.check_approve('HRPM4GE', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
--                v_secur2 := true;
                    if (v_flgpass and v_secur2) then
						v_data      := 'Y';
						v_secur     := 'Y';
						v_rcnt      := v_rcnt + 1;
						obj_data    := json_object_t();
						obj_data.put('coderror', '200');
						obj_data.put('rcnt', to_char(v_rcnt));
						obj_data.put('image', get_emp_img(r1.codempid));
						obj_data.put('codempid', r1.codempid);
						obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
						obj_data.put('dteeffecsort', to_char(r1.dteeffec, 'yyyymmdd'));
						obj_data.put('codtrn', get_label_name('HRPM44U', global_v_lang, 1));
						obj_data.put('table', 'TTMISTK');
						obj_data.put('numseq', '1');
						obj_data.put('seqcancel', '1');
						obj_data.put('namemp', get_temploy_name(r1.codempid, global_v_lang));
						obj_data.put('namcent', get_tcenter_name(r1.codcomp, global_v_lang));
						obj_data.put('staupd', get_tlistval_name ('STAUPD', r1.staupd, global_v_lang));
						obj_data.put('last_approvno', nvl(r1.approvno,0));
						obj_data.put('last_dteappr', to_char(r1.dteappr, 'DD/MM/YYYY'));
						obj_data.put('flgappr', v_flgpass);
						obj_data.put('codmist', r1.codmist);
                        obj_data.put('viewsalary',global_v_zupdsal );
						obj_row.put(to_char(v_rcnt - 1), obj_data);
					end if;
				END LOOP;
			end if;

			if v_right4ie then
				FOR r1 IN c_ttexempt LOOP
				v_approvno := nvl(r1.approvno,0) + 1;
                    v_secur2 := secur_main.secur1(r1.codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
					v_flgpass := chk_flowmail.check_approve('HRPM4IE', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
					if (v_flgpass and v_secur2) then
						v_data      := 'Y';
						v_secur     := 'Y';
						v_rcnt      := v_rcnt + 1;
						obj_data    := json_object_t();
						obj_data.put('coderror', '200');
						obj_data.put('rcnt', TO_CHAR(v_rcnt));
						obj_data.put('codempid', r1.codempid);
						obj_data.put('image', get_emp_img(r1.codempid));
						obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
						obj_data.put('dteeffecsort', to_char(r1.dteeffec, 'yyyymmdd'));
						obj_data.put('codtrn', get_label_name('HRPM44U', global_v_lang, 2));
						obj_data.put('table', 'TTEXEMPT');
						obj_data.put('numseq', '1');
						obj_data.put('seqcancel', '1');
						obj_data.put('namemp', get_temploy_name(r1.codempid, global_v_lang));
						obj_data.put('namcent', get_tcenter_name(r1.codcomp, global_v_lang));
						obj_data.put('staupd', GET_TLISTVAL_NAME ('STAUPD', r1.staupd, global_v_lang));
						obj_data.put('last_approvno', nvl(r1.approvno,0));
						obj_data.put('last_dteappr', TO_CHAR(r1.dteappr, 'DD/MM/YYYY'));
						obj_data.put('flgappr', v_flgpass);
                        obj_data.put('viewsalary',global_v_zupdsal );
						obj_row.put(to_char(v_rcnt - 1), obj_data);
					end if;
				END LOOP;
			end if;
			hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);

			if v_right4de then
				FOR r1 IN c_ttmovemt LOOP
					v_approvno := nvl(r1.approvno,0) + 1;
                    v_secur2    := secur_main.secur1(r1.codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
					v_flgpass := chk_flowmail.check_approve('HRPM4DE', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
                    if (v_flgpass and v_secur2) then
						v_data      := 'Y';
						v_secur     := 'Y';
						v_rcnt      := v_rcnt + 1;
						obj_data    := json_object_t();
						obj_data.put('coderror', '200');
						obj_data.put('rcnt', to_char(v_rcnt));
						obj_data.put('codempid', r1.codempid);
						obj_data.put('image', get_emp_img(r1.codempid));
						obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
						obj_data.put('dteeffecsort', to_char(r1.dteeffec, 'yyyymmdd'));
						obj_data.put('codtrn', get_tcodec_name('TCODMOVE', r1.codtrn, global_v_lang));
						obj_data.put('table', 'TTMOVEMT');
						obj_data.put('numseq', r1.numseq);
                        obj_data.put('seqcancel', r1.numseq);
						obj_data.put('namemp', get_temploy_name(r1.codempid, global_v_lang));
						obj_data.put('namcent', get_tcenter_name(r1.codcomp, global_v_lang));
						obj_data.put('staupd', get_tlistval_name ('STAUPD', r1.staupd, global_v_lang));
						obj_data.put('last_approvno', nvl(r1.approvno,0));
						obj_data.put('last_dteappr', to_char(r1.dteappr, 'dd/mm/yyyy'));
						obj_data.put('flgappr', v_flgpass);
						obj_data.put('codtrnid', r1.codtrn);
						obj_data.put('p_codmist', 1);
                        obj_data.put('viewsalary',global_v_zupdsal );
						obj_row.put(to_char(v_rcnt - 1), obj_data);
					end if;
				END LOOP;
			end if;

			if v_right4ce then
				FOR r1 IN c_ttmovemt0007 LOOP
					v_approvno := nvl(r1.approvno,0) + 1;
                    v_secur2 := secur_main.secur1(r1.codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
					v_flgpass := chk_flowmail.check_approve('HRPM4CE', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
                    if (v_flgpass and v_secur2) then
                        begin
                        select codpos, stapost2, dteend,numseq
                          into v_codpos, v_stapost2, v_dteend,v_numseq
                          from tsecpos
                         where codempid = r1.codempid
                           and dtecancel = r1.dteeffec
                           and seqcancel = r1.numseq;
                        exception when others then
                            v_codpos := null;
                            v_stapost2 := null;
                            v_dteend := null;
                        end;

						v_data      := 'Y';
						v_secur     := 'Y';
						v_rcnt      := v_rcnt + 1;
						obj_data    := json_object_t();
						obj_data.put('coderror', '200');
						obj_data.put('rcnt', to_char(v_rcnt));
						obj_data.put('codempid', r1.codempid);
						obj_data.put('image', get_emp_img(r1.codempid));
						obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
						obj_data.put('dteeffecsort', to_char(r1.dteeffec, 'yyyymmdd'));
						obj_data.put('codtrn', get_label_name('HRPM44U', global_v_lang, 4));
						obj_data.put('table', 'TTMOVEMT0007');
						obj_data.put('numseq', v_numseq);
                        obj_data.put('seqcancel', r1.numseq);
						obj_data.put('namemp', get_temploy_name(r1.codempid, global_v_lang));
						obj_data.put('namcent', get_tcenter_name(r1.codcomp, global_v_lang));
						obj_data.put('staupd', get_tlistval_name ('STAUPD', r1.staupd, global_v_lang));
						obj_data.put('last_approvno', nvl(r1.approvno,0));
						obj_data.put('last_dteappr', to_char(r1.dteappr, 'DD/MM/YYYY'));
						obj_data.put('flgappr', v_flgpass);
						obj_data.put('codtrnid', r1.codtrn);
						obj_data.put('p_codmist', 1);
                        obj_data.put('viewsalary',global_v_zupdsal );
                        obj_data.put('codpos', v_codpos);
                        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
                        obj_data.put('stapost2', v_stapost2);
                        obj_data.put('desc_stapost2', get_tlistval_name('STAPOST2',v_stapost2,global_v_lang));
                        obj_data.put('dteend', to_char(v_dteend, 'dd/mm/yyyy'));
                        obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
						obj_row.put(to_char(v_rcnt - 1), obj_data);
					end if;
				END LOOP;
			end if;
		end if;

		IF param_msg_error IS NULL THEN
			json_str_output := obj_row.to_clob;
		ELSE
			json_str_output := get_response_message('400', param_msg_error, global_v_lang);
		END IF;

	EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	END;

	PROCEDURE getdetail ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		json_obj		json_object_t;
	BEGIN
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);

		IF p_table = 'TTEXEMPT' THEN
			gendetail_ttexempt(json_str_output);
		ELSIF p_table = 'TTMOVEMT' THEN
			gendetail(json_str_output);
		ELSIF p_table = 'TTMOVEMT0007' THEN
			gendetail_ttmovemt0007(json_str_output);
		ELSIF p_table = 'TTMISTK' THEN
			gendetail_ttmistk(json_str_output);
		END IF;
  exception when others then
	param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END getdetail;

	PROCEDURE gendetail_ttmistk ( json_str_output OUT CLOB ) IS
		obj_data		        json_object_t;
		obj_sal			        json_object_t;
		obj_sum			        json_object_t;
		obj_row			        json_object_t;
		obj_data_cal	        json_object_t;
		obj_data_blank          json_object_t;
		v_codempid_ttpunsh      ttpunsh.codempid%TYPE;
		v_numseq		        ttpunsh.numseq%TYPE;
		v_codpunsh		        ttpunsh.codpunsh%TYPE;
		v_typpun		        ttpunsh.typpun%TYPE;
		v_dtestart		        ttpunsh.dtestart%TYPE;
		v_dteend		        ttpunsh.dteend%TYPE;
		v_flgexempt		        ttpunsh.flgexempt%TYPE;
		v_codexemp		        ttpunsh.codexemp%TYPE;
		v_flgssm		        ttpunsh.flgssm%TYPE;
		v_flgblist		        ttpunsh.flgblist%TYPE;
		v_remark		        ttpunsh.remark%TYPE;
		v1_codempid		        ttmistk.codempid%TYPE;
		v1_dteeffec		        ttmistk.dteeffec%TYPE;
		v1_numhmref		        ttmistk.numhmref%TYPE;
		v1_dtemistk		        ttmistk.dtemistk%TYPE;
		v1_refdoc		        ttmistk.refdoc%TYPE;
		v1_desmist1		        ttmistk.desmist1%TYPE;
		v1_dtecreate		    ttmistk.dtecreate%TYPE;
		v1_codcreate		    ttmistk.codcreate%TYPE;
		v1_codmist		        ttmistk.codmist%TYPE;
		TYPE p_num IS
		TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom            p_num;
		sal_amtincadj           p_num;
		sal_codempid		    temploy1.codempid%TYPE;
		sal_codempmt		    temploy1.codempmt%TYPE;
		sal_codcomp		        temploy1.codcomp%TYPE;
		v_numprdst		        ttpunded.numprdst%TYPE;
		v_dtemthst		        ttpunded.dtemthst%TYPE;
		v_dteyearst		        ttpunded.dteyearst%TYPE;
		v_numprden		        ttpunded.numprden%TYPE;
		v_dtemthen		        ttpunded.dtemthen%TYPE;
		v_dteyearen		        ttpunded.dteyearen%TYPE;
		v_amtdoth               VARCHAR(5000);
		v_amtded                VARCHAR(5000);
		v_amttotded             VARCHAR(5000);
		v_codempid		        temploy1.codempid%TYPE;
		v_codcomp		        temploy1.codcomp%TYPE;
		codincom_dteeffec       tcontpms.dteeffec%TYPE;
		codincom_codempmt	    temploy1.codempmt%TYPE;
		v_datasal               CLOB;
		obj_rowsal		        json_object_t;
		param_json_row		    json_object_t;
		param_json		        json_object_t;
		v_codincom		        tinexinf.codpay%TYPE;
		v_desincom		        tinexinf.descpaye%TYPE;
		v_desunit		        VARCHAR2(150 CHAR);
		v_amtmax		        NUMBER;
		cnt_row			        NUMBER := 0;
		v_row			        NUMBER := 0;
		v_suminperiod		    number := 0 ;
	BEGIN
		obj_row := json_object_t();
		IF ( flg_numseq IS NULL ) THEN
			p_numseq := 1;
		ELSE
			IF ( flg_numseq = 0 ) THEN
				p_numseq := p_numseq - 1;
			ELSE
				p_numseq := p_numseq + 1;
			END IF;
		END IF;
		SELECT codmist, codempid, dteeffec, numhmref, dtemistk,
			   refdoc, desmist1, dtecreate, codcreate
		  INTO v1_codmist, v1_codempid, v1_dteeffec, v1_numhmref, v1_dtemistk,
			   v1_refdoc, v1_desmist1, v1_dtecreate, v1_codcreate
		  FROM ttmistk
		 WHERE codempid = p_codempid_query
		   AND dteeffec = p_dteeffec;

		BEGIN
			SELECT codempid, numseq, codpunsh, typpun, dtestart,
				   dteend, flgexempt, codexemp, flgssm, flgblist, remark
			  INTO v_codempid_ttpunsh, v_numseq, v_codpunsh, v_typpun, v_dtestart,
				   v_dteend, v_flgexempt, v_codexemp, v_flgssm, v_flgblist, v_remark
			  FROM ttpunsh
			 WHERE codempid = p_codempid_query
			   AND dteeffec = p_dteeffec
			   AND numseq = p_numseq;
		EXCEPTION
		WHEN no_data_found THEN
			v_numseq    := NULL;
			v_codpunsh  := NULL;
			v_typpun    := NULL;
			v_dtestart  := NULL;
			v_dteend    := NULL;
			v_flgexempt := NULL;
			v_codexemp  := NULL;
			v_flgssm    := NULL;
			v_flgblist  := NULL;
			v_remark    := NULL;
		END;

		if (v_codempid_ttpunsh is null and call_from is not null) then
			param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TTMISTK');
			json_str_output := get_response_message('403', param_msg_error, global_v_lang);
			return;
		end if;

		obj_data := json_object_t();
		obj_data.put('numseq', v_numseq);
		obj_data.put('codpunsh', v_codpunsh);
		obj_data.put('typpun', v_typpun);
		obj_data.put('dtestart', TO_CHAR(v_dtestart, 'DD/MM/YYYY'));
		obj_data.put('dteend', TO_CHAR(v_dteend, 'DD/MM/YYYY'));
		obj_data.put('flgexempt', v_flgexempt);
		obj_data.put('codexemp', v_codexemp);
		obj_data.put('flgssm', v_flgssm);
		obj_data.put('flgblist', v_flgblist);
		obj_data.put('remark', v_remark);
		obj_data.put('codempid', v1_codempid);
		obj_data.put('dteeffec', TO_CHAR(v1_dteeffec, 'DD/MM/YYYY'));
		obj_data.put('numhmref', v1_numhmref);
		obj_data.put('dtemistk', TO_CHAR(v1_dtemistk, 'DD/MM/YYYY'));
		obj_data.put('codmist', v1_codmist);
		obj_data.put('refdoc', v1_refdoc);
		obj_data.put('desmist1', v1_desmist1);
		obj_data.put('dtecreate', TO_CHAR(v1_dtecreate, 'DD/MM/YYYY'));
		obj_data.put('codcreate', get_codempid(v1_codcreate));

		BEGIN
			SELECT  stddec(amtincom1, codempid, global_v_chken), stddec(amtincom2, codempid, global_v_chken), stddec(amtincom3, codempid, global_v_chken),
					stddec(amtincom4, codempid, global_v_chken), stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken),
					stddec(amtincom7, codempid, global_v_chken), stddec(amtincom8, codempid, global_v_chken), stddec(amtincom9, codempid, global_v_chken),
					stddec(amtincom10, codempid, global_v_chken), stddec(amtincded1, codempid, global_v_chken), stddec(amtincded2, codempid, global_v_chken),
					stddec(amtincded3, codempid, global_v_chken), stddec(amtincded4, codempid, global_v_chken), stddec(amtincded5, codempid, global_v_chken),
					stddec(amtincded6, codempid, global_v_chken), stddec(amtincded7, codempid, global_v_chken), stddec(amtincded8, codempid, global_v_chken),
					stddec(amtincded9, codempid, global_v_chken), stddec(amtincded10, codempid, global_v_chken),
					numprdst, dtemthst, dteyearst, numprden, dtemthen, dteyearen, codempid,
					stddec(amtdoth, codempid, global_v_chken), stddec(amtded, codempid, global_v_chken), stddec(amttotded, codempid, global_v_chken)
			INTO    sal_amtincom(1), sal_amtincom(2), sal_amtincom(3),
					sal_amtincom(4), sal_amtincom(5), sal_amtincom(6),
					sal_amtincom(7), sal_amtincom(8), sal_amtincom(9),
					sal_amtincom(10), sal_amtincadj(1), sal_amtincadj(2),
					sal_amtincadj(3), sal_amtincadj(4), sal_amtincadj(5),
					sal_amtincadj(6), sal_amtincadj(7), sal_amtincadj(8),
					sal_amtincadj(9), sal_amtincadj(10),
					v_numprdst, v_dtemthst, v_dteyearst, v_numprden, v_dtemthen, v_dteyearen, v_codempid,
					v_amtdoth, v_amtded, v_amttotded
			FROM    ttpunded
			WHERE   codempid = p_codempid_query
			  AND   codpunsh = v_codpunsh
			  AND   dteeffec = p_dteeffec;
		EXCEPTION
		WHEN no_data_found THEN
			sal_amtincom(1)     := NULL;
			sal_amtincom(2)     := NULL;
			sal_amtincom(3)     := NULL;
			sal_amtincom(4)     := NULL;
			sal_amtincom(5)     := NULL;
			sal_amtincom(6)     := NULL;
			sal_amtincom(7)     := NULL;
			sal_amtincom(8)     := NULL;
			sal_amtincom(9)     := NULL;
			sal_amtincom(10)    := NULL;
			sal_amtincadj(1)    := NULL;
			sal_amtincadj(2)    := NULL;
			sal_amtincadj(3)    := NULL;
			sal_amtincadj(4)    := NULL;
			sal_amtincadj(5)    := NULL;
			sal_amtincadj(6)    := NULL;
			sal_amtincadj(7)    := NULL;
			sal_amtincadj(8)    := NULL;
			sal_amtincadj(9)    := NULL;
			sal_amtincadj(10)   := NULL;
			v_numprdst          := NULL;
			v_dtemthst          := NULL;
			v_dteyearst         := NULL;
			v_numprden          := NULL;
			v_dtemthen          := NULL;
			v_dteyearen         := NULL;
			v_amtdoth           := NULL;
			v_amtded            := NULL;
			v_amttotded         := NULL;
			v_codempid          := null;
		END;
		FOR i IN 1..10 LOOP
			sal_amtincom(i)     := greatest(0, sal_amtincom(i));
			sal_amtincadj(i)    := greatest(0, sal_amtincadj(i));
		END LOOP;

		obj_sal := json_object_t();
		obj_sal.put('numprdst', v_numprdst);
		obj_sal.put('dtemthst', v_dtemthst);
		obj_sal.put('dteyearst', v_dteyearst);
		obj_sal.put('numprden', v_numprden);
		obj_sal.put('dtemthen', v_dtemthen);
		obj_sal.put('dteyearen', v_dteyearen);
		obj_sal.put('amtdoth', v_amtdoth);
		obj_sal.put('amtded', v_amtded);
		obj_sal.put('amttotded', v_amttotded);
		BEGIN
			SELECT codcomp
			  INTO v_codcomp
			  FROM temploy1
			 WHERE codempid = p_codempid_query;

			SELECT ( SELECT MAX(dteeffec)
					   FROM tcontpms
					  WHERE codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)),
				   codempmt
			  INTO codincom_dteeffec,
				   codincom_codempmt
			  FROM temploy1
			 WHERE codempid = p_codempid_query;
		EXCEPTION
		WHEN no_data_found THEN
			v_codcomp           := NULL;
			codincom_dteeffec   := SYSDATE;
			codincom_codempmt   := NULL;
		END;
		SELECT hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcomp, 1)
				|| ''',"p_dteeffec":''' || TO_CHAR(codincom_dteeffec, 'dd/mm/yyyy')
				|| ''',"p_codempmt":''' || codincom_codempmt || ''',"p_lang":''' || global_v_lang || '''}')
		  INTO v_datasal
		  FROM dual;

		obj_rowsal := json_object_t();
		param_json := json_object_t(v_datasal);
		FOR i IN 0..param_json.get_size - 1 LOOP
			param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
			v_desincom      := hcm_util.get_string_t(param_json_row, 'codincom');
			IF v_desincom IS NOT NULL OR v_desincom != '' THEN
				cnt_row := cnt_row + 1;
			END IF;
		END LOOP;

		COMMIT;
		FOR i IN 0..cnt_row - 1 LOOP
			param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
			v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
			v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
			v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
			v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
			v_row           := v_row + 1;
			obj_data_cal    := json_object_t();
			obj_data_cal.put('coderror', '200');
			obj_data_cal.put('codincom', v_codincom);
			obj_data_cal.put('desincom', v_desincom);
			obj_data_cal.put('desunit', v_desunit);
			obj_data_cal.put('amtmax', nvl(sal_amtincom(i + 1), '0'));
			obj_data_cal.put('salchage', nvl(sal_amtincadj(i + 1), '0'));
			obj_data_cal.put('sumsal', nvl(sal_amtincom(i + 1), '0') + nvl(sal_amtincadj(i + 1), '0'));

			v_suminperiod   := v_suminperiod + nvl(sal_amtincadj(i + 1), '0');
			obj_row.put(v_row, obj_data_cal);
		END LOOP;

		obj_sum := json_object_t();
		obj_data_blank := json_object_t();
		obj_sum.put('ttmistk', obj_data);

		obj_sum.put('obj_row1', obj_data_blank);
		obj_sum.put('obj_row2', obj_data_blank);
		obj_sum.put('obj_row3', obj_data_blank);
		obj_sum.put('obj_row4', obj_data_blank);
		obj_sum.put('obj_row5', obj_data_blank);
		obj_sum.put('obj_row6', obj_data_blank);
		obj_sum.put('obj_row7', obj_data_blank);
		obj_sum.put('obj_row8', obj_data_blank);
		obj_sum.put('obj_row9', obj_data_blank);
		obj_sum.put('obj_row10', obj_data_blank);
		obj_sum.put('obj_row11', obj_data_blank);
		obj_sum.put('obj_row12', obj_data_blank);
		obj_sum.put('t2', obj_data_blank);
		obj_sum.put('obj_c_tresintw', obj_data_blank);
		obj_sum.put('qtydayle', obj_data_blank);
		obj_sum.put('qtyvacat', obj_data_blank);
		obj_sum.put('obj_c_trepay', obj_data_blank);
		obj_sum.put('ttexempt', obj_data_blank);
		obj_sum.put('ttmovemt0007', obj_data_blank);

		obj_sum.put('obj_sal', obj_sal);
		obj_sum.put('obj_table_sal', obj_row);
		obj_sum.put('coderror', '200');
		obj_sum.put('flg_table', 'TTMISTK');
        flgsecur := secur_main.secur2(p_codempid_query ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        obj_sum.put('v_zupdsal', v_zupdsal);
		json_str_output := obj_sum.to_clob;
	END gendetail_ttmistk;

	PROCEDURE gendetail_ttmovemt0007 ( json_str_output OUT CLOB ) IS
		obj_data		        json_object_t;
		obj_sum			        json_object_t;
		obj_data_blank          json_object_t;
		v_codempid		        ttmovemt.codempid%TYPE;
		v_codpos		        ttmovemt.codpos%TYPE;
		v_stapost2		        ttmovemt.stapost2%TYPE;
		v_dteeffec		        ttmovemt.dteeffec%TYPE;
		v_dteduepr		        ttmovemt.dteduepr%TYPE;
		v_codtrn		        ttmovemt.codtrn%TYPE;
		v_dtecancel		        ttmovemt.dtecancel%TYPE;
		v_numseq		        ttmovemt.numseq%TYPE;
		v_desnote		        ttmovemt.desnote%TYPE;
		v_codcreate		        ttmovemt.codcreate%TYPE;
		v_codcomp		        ttmovemt.codcomp%TYPE;
		codincom_dteeffec       tcontpms.dteeffec%TYPE;
		codincom_codempmt	    temploy1.codempmt%TYPE;
		v_datasal               CLOB;
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		v_amtincom              p_num;
		v_amtincadj             p_num;
		v_total                 p_num;
		v_adjust                p_num;
		v_amont                 p_num;
		v_total2                p_num;
		v_adjust2               p_num;
		v_amont2                p_num;
		v_total3                p_num;
		v_adjust3               p_num;
		v_amont3                p_num;
		amtincadj1		        NUMBER := 0;
		amtincadj2		        NUMBER := 0;
		amtincadj3		        NUMBER := 0;
		amtincadj4		        NUMBER := 0;
		amtincadj5		        NUMBER := 0;
		amtincadj6		        NUMBER := 0;
		amtincadj7		        NUMBER := 0;
		amtincadj8		        NUMBER := 0;
		amtincadj9		        NUMBER := 0;
		amtincadj10		        NUMBER := 0;
		amtincom1		        NUMBER := 0;
		amtincom2		        NUMBER := 0;
		amtincom3		        NUMBER := 0;
		amtincom4		        NUMBER := 0;
		amtincom5		        NUMBER := 0;
		amtincom6		        NUMBER := 0;
		amtincom7		        NUMBER := 0;
		amtincom8		        NUMBER := 0;
		amtincom9		        NUMBER := 0;
		amtincom10		        NUMBER := 0;
		amtincadj		        NUMBER := 0;
		amtincom		        NUMBER := 0;
		replacecol              VARCHAR(20);
		param_json		        json_object_t;
		obj_rowsal		        json_object_t;
		param_json_row		    json_object_t;
		v_codincom		        tinexinf.codpay%TYPE;
		v_desincom		        tinexinf.descpaye%TYPE;
		cnt_row			        NUMBER := 0;
		v_desunit		        VARCHAR2(150 CHAR);
		v_amtmax		        NUMBER;
		v_amount		        NUMBER;
		v_row			        NUMBER := 0;
		obj_data_salary		    json_object_t;
		limitloop		        NUMBER := 0;
		countloop		        NUMBER := 0;
		v_amtothr_income	    NUMBER := 0;
		v_amtday_income		    NUMBER := 0;
		v_sumincom_income	    NUMBER := 0;
		v_amtothr_adj		    NUMBER := 0;
		v_amtday_adj		    NUMBER := 0;
		v_sumincom_adj		    NUMBER := 0;
		v_amtothr_simple	    NUMBER := 0;
		v_amtday_simple		    NUMBER := 0;
		v_sumincom_simple	    NUMBER := 0;
		flag_has_data		    NUMBER := 0;
		v_codempmt		        temploy1.codempmt%TYPE;
		v_codcompy		        tcompny.codcompy%TYPE;
		obj_calculator		    json_object_t;
		calculator		        json_object_t;
	BEGIN

	begin
		SELECT codcomp, codempid, codpos, stapost2, dteeffec, dteduepr,
			   codtrn, dtecancel, numseq, desnote, codcreate
		  INTO v_codcomp, v_codempid, v_codpos, v_stapost2, v_dteeffec, v_dteduepr,
			   v_codtrn, v_dtecancel, v_numseq, v_desnote, v_codcreate
		  FROM ttmovemt
		 WHERE codempid = p_codempid_query
		   AND numseq = p_numseq
		   AND dteeffec = p_dteeffec;
		exception when no_data_found then
			v_codcomp   := null;
			v_codempid  := null;
			v_codpos    := null;
			v_stapost2  := null;
			v_dteeffec  := null;
			v_dteduepr  := null;
			v_codtrn    := null;
			v_dtecancel := null;
			v_numseq    := null;
			v_desnote   := null;
			v_codcreate := null;
		end;

		obj_data    := json_object_t();
		obj_sum     := json_object_t();
		obj_data.put('codempid', v_codempid);
		obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
		obj_data.put('codpos', get_tpostn_name(v_codpos, global_v_lang));
		obj_data.put('stapost2', get_tlistval_name('STAPOST2', v_stapost2, global_v_lang));
		obj_data.put('dteeffec', TO_CHAR(v_dteeffec, 'DD/MM/YYYY'));
		obj_data.put('dteduepr', TO_CHAR(v_dteduepr, 'DD/MM/YYYY'));
		obj_data.put('codtrn', get_tcodec_name('TCODMOVE', v_codtrn, global_v_lang));
		obj_data.put('dtecancel', TO_CHAR(v_dtecancel, 'DD/MM/YYYY'));
		obj_data.put('numseq', v_numseq);
		obj_data.put('desnote', v_desnote);
		obj_data.put('codcreate', v_codcreate);
		BEGIN
			SELECT (SELECT MAX(dteeffec)
							   FROM tcontpms
							  WHERE codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)),
				   codempmt
			  INTO codincom_dteeffec,
				   codincom_codempmt
			  FROM temploy1
			 WHERE codempid = v_codempid;
		EXCEPTION
		WHEN no_data_found THEN
			v_codcomp           := NULL;
			codincom_dteeffec   := SYSDATE;
			codincom_codempmt   := NULL;
		END;

		SELECT hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcomp, 1)
				|| ''',"p_dteeffec":''' || TO_CHAR(codincom_dteeffec, 'dd/mm/yyyy')
				|| ''',"p_codempmt":''' || codincom_codempmt || ''',"p_lang":''' || global_v_lang || '''}')
		  INTO v_datasal
		  FROM dual;

		begin
			SELECT stddec(amtincadj1, codempid, global_v_chken), stddec(amtincadj2, codempid, global_v_chken),
				   stddec(amtincadj3, codempid, global_v_chken), stddec(amtincadj4, codempid, global_v_chken),
				   stddec(amtincadj5, codempid, global_v_chken), stddec(amtincadj6, codempid, global_v_chken),
				   stddec(amtincadj7, codempid, global_v_chken), stddec(amtincadj8, codempid, global_v_chken),
				   stddec(amtincadj9, codempid, global_v_chken), stddec(amtincadj10, codempid, global_v_chken),
				   stddec(amtincom1, codempid, global_v_chken), stddec(amtincom2, codempid, global_v_chken),
				   stddec(amtincom3, codempid, global_v_chken), stddec(amtincom4, codempid, global_v_chken),
				   stddec(amtincom5, codempid, global_v_chken), stddec(amtincom6, codempid, global_v_chken),
				   stddec(amtincom7, codempid, global_v_chken), stddec(amtincom8, codempid, global_v_chken),
				   stddec(amtincom9, codempid, global_v_chken), stddec(amtincom10, codempid, global_v_chken)
			  INTO v_amtincadj(1), v_amtincadj(2),
				   v_amtincadj(3), v_amtincadj(4),
				   v_amtincadj(5), v_amtincadj(6),
				   v_amtincadj(7), v_amtincadj(8),
				   v_amtincadj(9), v_amtincadj(10),
				   v_amtincom(1), v_amtincom(2),
				   v_amtincom(3), v_amtincom(4),
				   v_amtincom(5), v_amtincom(6),
				   v_amtincom(7), v_amtincom(8),
				   v_amtincom(9), v_amtincom(10)
			  FROM ttmovemt
			 WHERE codempid = p_codempid_query
			   AND numseq = p_numseq
			   AND dteeffec = p_dteeffec;
		exception when no_data_found then
			v_amtincadj(1):= 0;
			v_amtincadj(2):= 0;
			v_amtincadj(3):= 0;
			v_amtincadj(4):= 0;
			v_amtincadj(5):= 0;
			v_amtincadj(6):= 0;
			v_amtincadj(7):= 0;
			v_amtincadj(8):= 0;
			v_amtincadj(9):= 0;
			v_amtincadj(10):= 0;
			v_amtincom(1):= 0;
			v_amtincom(2):= 0;
			v_amtincom(3):= 0;
			v_amtincom(4):= 0;
			v_amtincom(5):= 0;
			v_amtincom(6):= 0;
			v_amtincom(7):= 0;
			v_amtincom(8):= 0;
			v_amtincom(9):= 0;
			v_amtincom(10):= 0;
		end;

		obj_rowsal := json_object_t();
		param_json := json_object_t(v_datasal);

		FOR i IN 0..param_json.get_size - 1 LOOP
			param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
			v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
			IF v_desincom IS NULL OR v_desincom = ' ' THEN
				EXIT;
			ELSE
				cnt_row     := cnt_row + 1;
			END IF;

		END LOOP;
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
			obj_data_salary.put('salchage', nvl(v_amtincadj(i + 1), '0'));

			obj_data_salary.put('codincom', v_codincom);
			obj_data_salary.put('desincom', v_desincom);
			obj_data_salary.put('desunit', v_desunit);
			obj_data_salary.put('amtmax', nvl(v_amtincom(i + 1), '0') - nvl(v_amtincadj(i + 1), '0'));
			obj_data_salary.put('sumsal', nvl(v_amtincom(i + 1), '0'));
			v_total(i + 1)  := nvl(v_amtmax, 0);
			v_adjust(i + 1) := nvl(v_amtincadj(i + 1), '0');

			v_amont(i + 1)  := nvl(v_amtincom(i + 1), '0');
			countloop       := i + 1;
			obj_rowsal.put(v_row, obj_data_salary);
		END LOOP;

		FOR i IN countloop..10 LOOP
			v_total(i)  := 0;
			v_adjust(i) := 0;
			v_amont(i)  := 0;
		END LOOP;
		BEGIN
			SELECT COUNT(*)
			  INTO flag_has_data
			  FROM thismove
			 WHERE codempid = v_codempid
			   AND dteeffec = p_dteeffec
			   AND numseq = v_numseq;

		END;
		IF flag_has_data > 0 THEN
			BEGIN
				SELECT codcomp, codempmt
				  INTO v_codcomp, v_codempmt
				  FROM thismove
				 WHERE codempid = v_codempid
				   AND dteeffec = p_dteeffec
				   AND numseq = v_numseq;

			END;
			BEGIN
				SELECT codcompy
				  INTO v_codcompy
				  FROM tcenter
				 WHERE codcomp LIKE v_codcomp || '%';
			END;
		ELSE
			BEGIN
				SELECT codempmt, codcomp
				  INTO v_codempmt, v_codcomp
				  FROM temploy1
				 WHERE codempid = v_codempid;
				SELECT codcompy
				  INTO v_codcompy
				  FROM tcenter
				 WHERE codcomp LIKE v_codcomp || '%';
			END;
		END IF;

		get_wage_income(v_codcompy, v_codempmt, v_amont(1), v_amont(2), v_amont(3), v_amont(4), v_amont(5),
						v_amont(6), v_amont(7), v_amont(8), v_amont(9), v_amont(10), v_amtothr_income, v_amtday_income, v_sumincom_income);

		get_wage_income(v_codcompy, v_codempmt, v_adjust(1), v_adjust(2), v_adjust(3), v_adjust(4), v_adjust(5),
						v_adjust(6), v_adjust(7), v_adjust(8), v_adjust(9), v_adjust(10), v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

		get_wage_income(v_codcompy, v_codempmt, v_amont(1) - v_adjust(1), v_amont(2) - v_adjust(2), v_amont(3) - v_adjust(3),
						v_amont(4) - v_adjust(4), v_amont(5) - v_adjust(5), v_amont(6) - v_adjust(6), v_amont(7) - v_adjust(7),
						v_amont(8) - v_adjust(8), v_amont(9) - v_adjust(9), v_amont(10) - v_adjust(10), v_amtothr_simple, v_amtday_simple, v_sumincom_simple);

		obj_sum         := json_object_t();
		obj_data_blank  := json_object_t();
		obj_sum.put('ttmovemt0007', obj_data);

		obj_sum.put('obj_row1', obj_data_blank);
		obj_sum.put('obj_row2', obj_data_blank);
		obj_sum.put('obj_row3', obj_data_blank);
		obj_sum.put('obj_row4', obj_data_blank);
		obj_sum.put('obj_row5', obj_data_blank);
		obj_sum.put('obj_row6', obj_data_blank);
		obj_sum.put('obj_row7', obj_data_blank);
		obj_sum.put('obj_row8', obj_data_blank);
		obj_sum.put('obj_row9', obj_data_blank);
		obj_sum.put('obj_row10', obj_data_blank);
		obj_sum.put('obj_row11', obj_data_blank);
		obj_sum.put('obj_row12', obj_data_blank);
		obj_sum.put('t2', obj_data_blank);
		obj_sum.put('obj_sal', obj_data_blank);

		obj_sum.put('t3', obj_rowsal);
		obj_sum.put('v_amtothr_income', v_amtothr_income);
		obj_sum.put('v_amtday_income', v_amtday_income);
		obj_sum.put('v_sumincom_income', v_sumincom_income);
		obj_sum.put('v_amtothr_adj', v_amtothr_adj);
		obj_sum.put('v_amtday_adj', v_amtday_adj);
		obj_sum.put('v_sumincom_adj', v_sumincom_adj);
		obj_sum.put('v_amtothr_simple', v_amtothr_simple);
		obj_sum.put('v_amtday_simple', v_amtday_simple);
		obj_sum.put('v_sumincom_simple', v_sumincom_simple);
		obj_sum.put('coderror', '200');
		obj_sum.put('flg_table', 'TTMOVEMT0007');

        flgsecur := secur_main.secur2(p_codempid_query ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        obj_sum.put('v_zupdsal', v_zupdsal);

		json_str_output := obj_sum.to_clob;
	END gendetail_ttmovemt0007;

	PROCEDURE gendetail_ttexempt ( json_str_output OUT CLOB ) IS
		v_codempid		            ttexempt.codempid%TYPE;
		v_dteeffec		            ttexempt.dteeffec%TYPE;
		v_numexemp		            ttexempt.numexemp%TYPE;
		v_flgblist		            ttexempt.flgblist%TYPE;
		v_codexemp		            ttexempt.codexemp%TYPE;
		v_flgssm		            ttexempt.flgssm%TYPE;
		v_desnote		            ttexempt.desnote%TYPE;
		v_dtecreate		            ttexempt.dtecreate%TYPE;
		v_codcreate		            ttexempt.codcreate%TYPE;
		v_dteupd		            ttexempt.dteupd%TYPE;
		v_coduser		            ttexempt.coduser%TYPE;
		v_staupd		            ttexempt.staupd%TYPE;
		obj_data		            json_object_t;
		obj_sum			            json_object_t;
		obj_data_blank              json_object_t;
		popup_codcomp		        temploy1.codcomp%TYPE;
		popup_codpos		        temploy1.codpos%TYPE;
		popup_dteempmt		        temploy1.dteempmt%TYPE;
		popup_dteeffex		        temploy1.dteeffex%TYPE;
		popup_staemp		        temploy1.staemp%TYPE;
		popup_dteretire		        temploy1.dteretire%TYPE;
		p_leave_codleave_vacation	tleavecd.codleave%TYPE;
		p_leave_typleave_vacation	tleavecd.typleave%TYPE;
		p_leave_codleave_ot	        tleavecd.codleave%TYPE;
		p_leave_typleave_ot	        tleavecd.typleave%TYPE;
		p_yrecyclev_vacation	    NUMBER;
		p_dtecycstv_vacation	    DATE;
		p_dtecycenv_vacation	    DATE;
		p_yrecyclev_ot		        NUMBER;
		p_dtecycstv_ot		        DATE;
		p_dtecycenv_ot		        DATE;
		p_yrecyclev_hpd_vacation	NUMBER;
		p_dtecycstv_hpd_vacation	DATE;
		p_dtecycenv_hpd_vacation	DATE;
		p_yrecyclev_year_and_leave_ot	NUMBER;
		p_dtecycstv_year_and_leave_ot	DATE;
		p_dtecycenv_year_and_leave_ot	DATE;
		qtyvacat_vacation	        NUMBER;
		qtydayle_vacation	        NUMBER;
		balance_vacation	        NUMBER;
		qtydleot_ot		            NUMBER;
		qtydayle_ot		            NUMBER;
		balance_ot		            NUMBER;
		v_flgdlemxv		            tleavety.flgdlemx%TYPE;
		v_flgdlemxc		            tleavety.flgdlemx%TYPE;
		v_qtyreqv		            NUMBER;
		v_qtyreqc		            NUMBER;
		p_qtyavhwk		            tcontral.qtyavgwk%TYPE;
		o_qtyvacat_day_vacation	    NUMBER;
		o_qtyvacat_hr_vacation	    NUMBER;
		o_qtyvacat_min_vacation	    NUMBER;
		o_qtyvacat_dhm_vacation     VARCHAR(20 CHAR);
		o_qtydayle_day_vacation	    NUMBER;
		o_qtydayle_hr_vacation	    NUMBER;
		o_qtydayle_min_vacation	    NUMBER;
		o_qtydayle_dhm_vacation     VARCHAR(20 CHAR);
		o_balance_day_vacation	    NUMBER;
		o_balance_hr_vacation	    NUMBER;
		o_balance_min_vacation	    NUMBER;
		o_balance_dhm_vacation      VARCHAR(20 CHAR);
		o_qtyreqv_day_vacation	    NUMBER;
		o_qtyreqv_hr_vacation	    NUMBER;
		o_qtyreqv_min_vacation	    NUMBER;
		o_qtyreqv_dhm_vacation      VARCHAR(20 CHAR);
		o_qtyvacat_day_ot	        NUMBER;
		o_qtyvacat_hr_ot	        NUMBER;
		o_qtyvacat_min_ot	        NUMBER;
		o_qtyvacat_dhm_ot           VARCHAR(20 CHAR);
		o_qtydayle_day_ot	        NUMBER;
		o_qtydayle_hr_ot	        NUMBER;
		o_qtydayle_min_ot	        NUMBER;
		o_qtydayle_dhm_ot           VARCHAR(20 CHAR);
		o_balance_day_ot	        NUMBER;
		o_balance_hr_ot		        NUMBER;
		o_balance_min_ot	        NUMBER;
		o_balance_dhm_ot            VARCHAR(20 CHAR);
		o_qtyreqc_day_ot	        NUMBER;
		o_qtyreqc_hr_ot		        NUMBER;
		o_qtyreqc_min_ot	        NUMBER;
		o_qtyreqc_dhm_ot            VARCHAR(20 CHAR);
		obj_row			            json_object_t;
		p_codcomp		            temploy1.codcomp%TYPE;
		obj_row_sub		            json_object_t;
		obj_data_va		            json_object_t;
		obj_data_ot		            json_object_t;
		v_rcnt			            NUMBER := 0;
		v_qtyavqwk		            NUMBER;
		v_codleavev		            VARCHAR2(500 CHAR);
		v_typleavev		            VARCHAR2(500 CHAR);
		v_qtyvacatv		            NUMBER;
		v_qtydaylev		            NUMBER;
		v_balancev		            NUMBER;
		o_qtyvacatv_d		        NUMBER;
		o_qtyvacatv_h		        NUMBER;
		o_qtyvacatv_m		        NUMBER;
		o_qtyvacatv_dhm		        VARCHAR2(500 CHAR);
		o_qtydaylev_d		        NUMBER;
		o_qtydaylev_h		        NUMBER;
		o_qtydaylev_m		        NUMBER;
		o_qtydaylev_dhm		        VARCHAR2(500 CHAR);
		o_balancev_d		        NUMBER;
		o_balancev_h		        NUMBER;
		o_balancev_m		        NUMBER;
		o_balancev_dhm		        VARCHAR2(500 CHAR);
		o_qtyreqv_d		            NUMBER;
		o_qtyreqv_h		            NUMBER;
		o_qtyreqv_m		            NUMBER;
		o_qtyreqv_dhm		        VARCHAR2(500 CHAR);
		v_codcomp		            VARCHAR2(500 CHAR);
		v_yrecyclev		            VARCHAR2(500 CHAR);
		v_dtecycstv		            DATE;
		v_dtecycenv		            DATE;
		v_dtecycstv_new		        VARCHAR2(500 CHAR);
		v_dtecycenv_new		        VARCHAR2(500 CHAR);
		v_codleavec		            VARCHAR2(500 CHAR);
		v_typleavec		            VARCHAR2(500 CHAR);
		v_qtyvacatc		            NUMBER;
		v_qtydaylec		            NUMBER;
		v_balancec		            NUMBER;
		v_yrecyclec		            VARCHAR2(500 CHAR);
		v_dtecycstc		            DATE;
		v_dtecycenc		            DATE;
		o_qtyvacatc_d		        NUMBER;
		o_qtyvacatc_h		        NUMBER;
		o_qtyvacatc_m		        NUMBER;
		o_qtyvacatc_dhm		        VARCHAR2(500 CHAR);
		o_qtydaylec_d		        NUMBER;
		o_qtydaylec_h		        NUMBER;
		o_qtydaylec_m		        NUMBER;
		o_qtydaylec_dhm		        VARCHAR2(500 CHAR);
		o_balancec_d		        NUMBER;
		o_balancec_h		        NUMBER;
		o_balancec_m		        NUMBER;
		o_balancec_dhm		        VARCHAR2(500 CHAR);
		o_qtyreqc_d		            NUMBER;
		o_qtyreqc_h		            NUMBER;
		o_qtyreqc_m		            NUMBER;
		o_qtyreqc_dhm		        VARCHAR2(500 CHAR);
		v_dtecycstc_new		        VARCHAR2(500 CHAR);
		v_dtecycenc_new		        VARCHAR2(500 CHAR);
		v_count_ttemprpt	        VARCHAR2(500 CHAR);

		CURSOR c_tempinc IS
			SELECT codpay, get_tinexinf_name(codpay, global_v_lang) codpayname, periodpay, amtfix,
				   dtestrt, dteend, dtecancl, stddec(amtfix, p_codempid_query, v_chken) amount
			  FROM tempinc
			 WHERE nvl(dtecancl, dteend) <= SYSDATE
			   AND codempid = p_codempid_query;

		CURSOR c_tloaninf IS
			SELECT dtelonst, numcont, get_ttyploan_name(codlon, global_v_lang) codlon, amtlon,
				   nvl(amtnpfin, 0) + nvl(amtintovr, 0) balance, numlon, qtyperiod, qtyperip
			  FROM tloaninf
			 WHERE amtnpfin <> 0
			   AND staappr = 'Y'
			   AND stalon <> 'C'
			   AND codempid = p_codempid_query;

		CURSOR c_trepay IS
			SELECT qtyrepaym, amtrepaym,
				   DECODE(dtestrpm, NULL, NULL, substr(dtestrpm, 7, 5) || '/' || substr(dtestrpm, 5, 2) || '/' || substr(dtestrpm, 1, 4)) dtestrpm,
				   amtoutstd, amtoutstd - amttotpay balance, qtypaid,
				   DECODE(dtelstpay, NULL, NULL, substr(dtelstpay, 7, 5) || '/' || substr(dtelstpay, 5, 2) || '/' || substr(dtelstpay, 1, 4)) dtelstpay
			  FROM trepay
			 WHERE codempid = p_codempid_query
			   AND dteappr = ( SELECT MAX(dteappr)
								 FROM trepay
								WHERE codempid = p_codempid_query
								  AND dteappr <= SYSDATE );

		CURSOR c_fundtrnn IS
			SELECT t1.codcours, get_tcourse_name(t1.codcours,global_v_lang) desc_codcours,
			   t2.descommt, t2.descommt2, dtecomexp
			  FROM thistrnn t1, tcourse t2
			 WHERE t1.codcours = t2.codcours
			   AND t2.flgcommt = 'Y'
			   AND codempid = p_codempid_query;
		CURSOR c_tassets IS
			SELECT t1.codasset, get_taseinf_name(t1.codasset, global_v_lang) assetname, t1.dtercass, t1.remark
			  FROM tassets t1, tasetinf t2
			 WHERE t1.codasset = t2.codasset
			   AND t1.codempid = p_codempid_query;

		obj_tloaninf		    json_object_t;
		obj_c_trepay		    json_object_t;
		obj_c_fundtrnn		    json_object_t;
		obj_c_tassets		    json_object_t;
		v_formula		        tformula.formula%TYPE;
		p_codpay		        tempinc.codpay%TYPE;
		p_detailpay             VARCHAR(500);
		p_periodpay		        tempinc.periodpay%TYPE;
		v_formula_chk		    NUMBER;
		v_sal			        NUMBER;
		obj_c_tempinc		    json_object_t;
		v_dteyrepay		        ttaxcur.dteyrepay%TYPE;
		v_dtemthpay		        ttaxcur.dtemthpay%TYPE;
		v_numperiod		        ttaxcur.numperiod%TYPE;
		tothinc_codpayname      VARCHAR(500);
		tothinc_amtpay		    tothinc.amtpay%TYPE;
		tothinc_codsys		    tothinc.codsys%TYPE;
		cursortothinc           SYS_REFCURSOR;
		tothinc_codpay		    tothinc.codpay%TYPE;
		tothinc_period          VARCHAR(1000);
		obj_tothinc		        json_object_t;
		obj_c_tcolltrl		    json_object_t;

		CURSOR c_tcolltrl IS
			SELECT staded, typcolla, get_tcodec_name('TCODCOLA', typcolla, global_v_lang) nameasset,
				   descoll, numdocum, amtcolla,
				   dtecolla, dtestrt, amtdedcol,
				   amtcolla - amtdedcol amtbalance
			  FROM tcolltrl a
			 WHERE a.codempid = p_codempid_query
			   AND staded NOT IN ( 'N', 'C' )
		  ORDER BY dtecolla;

		obj_c_tresintw		json_object_t;
		tresintw_intwno		tresreq.intwno%TYPE;
		tresintw_numqes		tresintw.numqes%TYPE;
		tresintw_details	tresintw.details%TYPE;
		tresintw_response	tresintw.response%TYPE;

		CURSOR c_1 IS
			SELECT 'HRES71E' codapp, a.codempid, a.dtereq,
				   a.numseq, a.staappr, a.remarkap remark
			  FROM tmedreq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES71E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES71E' ) ) )
		 UNION ALL
			SELECT 'HRES74E' codapp, a.codempid, a.dtereq,
				   a.numseq, a.staappr, a.remarkap remark
			  FROM tobfreq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES74E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES74E' ) ) )
		 UNION ALL
			SELECT 'HRES77E' codapp, a.codempid, a.dtereq,
				   a.numseq, a.staappr, a.remarkap remark
			  FROM tloanreq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES77E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES77E' ) ) )
		 UNION ALL
			SELECT 'HRES32E' codapp, a.codempid, a.dtereq,
				   a.numseq, a.staappr, a.remarkap remark
			  FROM tempch a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES32E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES32E' ) ) )
		 UNION ALL
			SELECT 'HRES36E' codapp, a.codempid, a.dtereq,
				   a.numseq, a.staappr, a.remarkap remark
			  FROM trefreq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES36E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES36E' ) ) )
		 UNION ALL
			SELECT 'HRES62E' codapp, a.codempid, a.dtereq,
				   0 numseq, a.staappr, a.remarkap remark
			  FROM tleaverq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES62E', codempid, dtereq, 0,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES62E' ) ) )
		 UNION ALL
			SELECT 'HRES6AE' codapp, a.codempid, a.dtereq,
				   numseq, a.staappr, a.remarkap remark
			  FROM ttimereq a,
				   twkflowh b
			 WHERE a.routeno = b.routeno
			   AND staappr IN ( 'P', 'A' )
			   AND ( 'Y' = chk_workflow.check_privilege('HRES6AE', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					 OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	   FROM twkflowde c
																	  WHERE c.routeno = a.routeno
																		AND c.codempid = p_codempid_query )
							AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																								FROM twkflpf
																							   WHERE codapp = 'HRES6AE' ) ) )
		 UNION ALL
			SELECT 'HRES34E' codapp, a.codempid, a.dtereq,
				   numseq, a.staappr, a.remarkap remark
			 FROM tmovereq a,
				  twkflowh b
			WHERE a.routeno = b.routeno
			  AND staappr IN ( 'P', 'A' )
			  AND ( 'Y' = chk_workflow.check_privilege('HRES34E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
					OR ( ( a.routeno, nvl(a.approvno, 0) + 1 ) IN ( SELECT routeno, numseq
																	  FROM twkflowde c
																	 WHERE c.routeno = a.routeno
																	   AND c.codempid = p_codempid_query )
						   AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= ( SELECT hrtotal
																							   FROM twkflpf
																							  WHERE codapp = 'HRES34E' ) ) )
		UNION ALL
		SELECT
		'HRES6DE' codapp,
		a.codempid,
		a.dtereq,
		0 numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tworkreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES6DE', codempid, dtereq, 0,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES6DE'
		) ) )
		UNION ALL
		SELECT
		'HRES6IE' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		ttrnreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES6IE', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES6IE'
		) ) )
		UNION ALL
		SELECT
		'HRES6KE' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		ttotreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES6KE', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES6KE'
		) ) )
		UNION ALL
		SELECT
		'HRES81E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		ttravreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES81E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES81E'
		) ) )
		UNION ALL
		SELECT
		'HRES86E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tresreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES86E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES86E'
		) ) )
		UNION ALL
		SELECT
		'HRES88E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tjobreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES88E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES88E'
		) ) )
		UNION ALL
		SELECT
		'HRESS2E' codapp,
		a.codempid,
		a.dtereq,
		0 numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tpfmemrq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRESS2E', codempid, dtereq, 0,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRESS2E'
		) ) )
		UNION ALL
		SELECT
		'HRES3BE' codapp,
		a.codempid,
		a.dtecompl dtereq,
		NULL numseq,
		a.stacompl staappr,
		NULL remark
		FROM
		tcompln a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND a.stacompl IN (
		'N',
		'D'
		)
		AND 'Y' = chk_workflow.check_privilege('HRES3BE', a.codempid, a.dtecompl, a.numcomp, 1, p_codempid_query)
		UNION ALL
		SELECT
		'HRESS4E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tircreq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRESS4E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRESS4E'
		) ) )
		UNION ALL
		SELECT
		'HRES6ME' codapp,
		a.codempid,
		a.dtereq,
		0 numseq,
		a.staappr,
		a.remarkap remark
		FROM
		tleavecc a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES6ME', codempid, dtereq, 0,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES6ME'
		) ) )
		UNION ALL
		SELECT
		'HRES95E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		a.staappr,
		a.remarkap remark
		FROM
		treplacerq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND staappr IN (
		'P',
		'A'
		)
		AND ( 'Y' = chk_workflow.check_privilege('HRES95E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES95E'
		) ) )
		UNION ALL
		SELECT
		'HRES91E' codapp,
		a.codempid,
		a.dtereq,
		numseq,
		' ' staappr,
		a.remarkap remark
		FROM
		ttrncerq a,
		twkflowh b
		WHERE
		a.routeno = b.routeno
		AND ( 'Y' = chk_workflow.check_privilege('HRES91E', codempid, dtereq, numseq,(nvl(a.approvno, 0) + 1), p_codempid_query)
		OR ( ( a.routeno,
		nvl(a.approvno, 0) + 1 ) IN (
		SELECT
		routeno,
		numseq
		FROM
		twkflowde c
		WHERE
		c.routeno = a.routeno
		AND c.codempid = p_codempid_query
		)
		AND ( ( ( SYSDATE - nvl(dteapph, dteinput) ) * 1440 ) / 60 ) >= (
		SELECT
		hrtotal
		FROM
		twkflpf
		WHERE
		codapp = 'HRES91E'
		) ) );

		obj_approve_remain	json_object_t;
	BEGIN
		obj_approve_remain := json_object_t();
		v_rcnt := 0;
		FOR r1 IN c_1 LOOP
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('type', get_tappprof_name(r1.codapp, '1', global_v_lang));
			obj_data.put('codempid', r1.codempid);
			obj_data.put('emp_name', get_temploy_name(r1.codempid, global_v_lang));
			obj_data.put('emp_image', get_image(r1.codempid, 'hrpm90x'));
			obj_data.put('dtereq', TO_CHAR(r1.dtereq, 'dd/mm/yyyy'));
			obj_data.put('numseq', r1.numseq);
			obj_data.put('staappr', get_tlistval_name('STAAPPR', r1.staappr, global_v_lang));
			obj_data.put('remark', r1.remark);
			obj_approve_remain.put(TO_CHAR(v_rcnt), obj_data);
			v_rcnt := v_rcnt + 1;
		END LOOP;

		BEGIN
			SELECT codleave, typleave
			  INTO v_codleavev, v_typleavev
			  FROM tleavecd
			 WHERE staleave = 'V';
		EXCEPTION WHEN no_data_found THEN
			v_codleavev := NULL;
		END;

		BEGIN
			SELECT qtyvacat, qtydayle, nvl(qtyvacat, 0) - nvl(qtydayle, 0)
			  INTO v_qtyvacatv, v_qtydaylev, v_balancev
			  FROM tleavsum
			 WHERE codleave = v_codleavev
			   AND dteyear = to_number(TO_CHAR(SYSDATE, 'yyyy'))
			   AND codempid = p_codempid_query;
		EXCEPTION WHEN no_data_found THEN
			NULL;
		END;

		std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp, '1'), p_codempid_query, 'V', SYSDATE, v_yrecyclev, v_dtecycstv, v_dtecycenv);

		BEGIN
			SELECT flgdlemx
			  INTO v_flgdlemxv
			  FROM tleavety
			 WHERE typleave = v_typleavev;
		EXCEPTION WHEN no_data_found THEN
			NULL;
		END;
		IF v_flgdlemxv = 'Y' THEN
			v_qtyreqv := 0;
		ELSE
			v_dtecycstv_new := TO_CHAR(v_dtecycstv, 'yyyymmdd');
			v_dtecycstv_new := TO_CHAR(v_dtecycstv, 'yyyymmdd');
			BEGIN
				SELECT nvl(SUM(qtyday), 0)
				  INTO v_qtyreqv
				  FROM tlereqd
				 WHERE codempid = p_codempid_query
				   AND dtework BETWEEN TO_DATE(v_dtecycstv_new, 'yyyymmdd') AND TO_DATE(v_dtecycstv_new, 'yyyymmdd')
				   AND codleave = v_codleavev
				   AND dayeupd IS NULL;
			EXCEPTION WHEN no_data_found THEN
				NULL;
			END;
		END IF;

		BEGIN
			SELECT codleave, typleave
			  INTO v_codleavec, v_typleavec
			  FROM tleavecd
			 WHERE staleave = 'V';
		EXCEPTION WHEN no_data_found THEN
			v_codleavec := NULL;
		END;

		BEGIN
			SELECT qtydleot, qtydayle, nvl(qtyvacat, 0) - nvl(qtydayle, 0)
			  INTO v_qtyvacatc, v_qtydaylec, v_balancec
			  FROM tleavsum
			 WHERE codleave = v_codleavec
			   AND dteyear = to_number(TO_CHAR(SYSDATE, 'yyyy'))
			   AND codempid = p_codempid_query;
		EXCEPTION WHEN no_data_found THEN
			NULL;
		END;

		std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp, 1), p_codempid_query, 'C', SYSDATE, v_yrecyclec, v_dtecycstc, v_dtecycenc);

		BEGIN
			SELECT flgdlemx
			  INTO v_flgdlemxc
			  FROM tleavety
			 WHERE typleave = v_typleavec;
		EXCEPTION WHEN no_data_found THEN
			NULL;
		END;

		IF v_flgdlemxv = 'Y' THEN
			v_qtyreqc := 0;
		ELSE
			v_dtecycstc_new := TO_CHAR(v_dtecycstc, 'yyyymmdd');
			v_dtecycstc_new := TO_CHAR(v_dtecycstc, 'yyyymmdd');
			BEGIN
				SELECT nvl(SUM(qtyday), 0)
				  INTO v_qtyreqc
				  FROM tlereqd
				 WHERE codempid = p_codempid_query
				   AND dtework BETWEEN TO_DATE(v_dtecycstc_new, 'yyyymmdd') AND TO_DATE(v_dtecycstc_new, 'yyyymmdd')
				   AND codleave = v_codleavev
				   AND dayeupd IS NULL;
			EXCEPTION WHEN no_data_found THEN
				v_qtyreqc := 0;
			END;
		END IF;

		v_qtyavqwk := hcm_util.get_qtyavgwk('', p_codempid_query);

		hcm_util.cal_dhm_hm(v_qtyvacatv, 0, 0, v_qtyavqwk, '1', o_qtyvacatv_d, o_qtyvacatv_h, o_qtyvacatv_m, o_qtyvacatv_dhm);
		hcm_util.cal_dhm_hm(v_qtydaylev, 0, 0, v_qtyavqwk, '1', o_qtydaylev_d, o_qtydaylev_h, o_qtydaylev_m, o_qtydaylev_dhm);
		hcm_util.cal_dhm_hm(v_balancev, 0, 0, v_qtyavqwk, '1', o_balancev_d, o_balancev_h, o_balancev_m, o_balancev_dhm);
		hcm_util.cal_dhm_hm(v_qtyreqv, 0, 0, v_qtyavqwk, '1', o_qtyreqv_d, o_qtyreqv_h, o_qtyreqv_m, o_qtyreqv_dhm);
		hcm_util.cal_dhm_hm(v_qtyvacatc, 0, 0, v_qtyavqwk, '1', o_qtyvacatc_d, o_qtyvacatc_h, o_qtyvacatc_m, o_qtyvacatc_dhm);
		hcm_util.cal_dhm_hm(v_qtydaylec, 0, 0, v_qtyavqwk, '1', o_qtydaylec_d, o_qtydaylec_h, o_qtydaylec_m, o_qtydaylec_dhm);
		hcm_util.cal_dhm_hm(v_balancec, 0, 0, v_qtyavqwk, '1', o_balancec_d, o_balancec_h, o_balancec_m, o_balancec_dhm);
		hcm_util.cal_dhm_hm(v_qtyreqc, 0, 0, v_qtyavqwk, '1', o_qtyreqc_d, o_qtyreqc_h, o_qtyreqc_m, o_qtyreqc_dhm);

		obj_row := json_object_t();
		obj_row_sub := json_object_t();
		obj_data_va := json_object_t();
		obj_data_ot := json_object_t();
		obj_data_va.put('coderror', '200');
		obj_data_va.put('o_qtyvacatv_d', o_qtyvacatv_d || get_label_name('HRPM90X', global_v_lang, 1));

		obj_data_va.put('o_qtyvacatv_h', o_qtyvacatv_h || get_label_name('HRPM90X', global_v_lang, 2));
		obj_data_va.put('o_qtyvacatv_m', o_qtyvacatv_m || get_label_name('HRPM90X', global_v_lang, 3));

		obj_data_va.put('o_qtyvacatv_dhm', o_qtyvacatv_dhm);
		obj_data_va.put('o_qtydaylev_d', o_qtydaylev_d || get_label_name('HRPM90X', global_v_lang, 1));
		obj_data_va.put('o_qtydaylev_h', o_qtydaylev_h || get_label_name('HRPM90X', global_v_lang, 2));

		obj_data_va.put('o_qtydaylev_m', o_qtydaylev_m || get_label_name('HRPM90X', global_v_lang, 3));
		obj_data_va.put('o_qtydaylev_dhm', o_qtydaylev_dhm);
		obj_data_va.put('o_balancev_d', o_balancev_d || get_label_name('HRPM90X', global_v_lang, 1));

		obj_data_va.put('o_balancev_h', o_balancev_h || get_label_name('HRPM90X', global_v_lang, 2));
		obj_data_va.put('o_balancev_m', o_balancev_m || get_label_name('HRPM90X', global_v_lang, 3));

		obj_data_va.put('o_balancev_dhm', o_balancev_dhm);
		obj_data_va.put('o_qtyreqv_d', o_qtyreqv_d || get_label_name('HRPM90X', global_v_lang, 1));
		obj_data_va.put('o_qtyreqv_h', o_qtyreqv_h || get_label_name('HRPM90X', global_v_lang, 2));

		obj_data_va.put('o_qtyreqv_m', o_qtyreqv_m || get_label_name('HRPM90X', global_v_lang, 3));
		obj_data_va.put('o_qtyreqv_dhm', o_qtyreqv_dhm);

		obj_data_ot.put('coderror', '200');
		obj_data_ot.put('o_qtyvacatc_d', o_qtyvacatc_d || get_label_name('HRPM90X', global_v_lang, 1));
		obj_data_ot.put('o_qtyvacatc_h', o_qtyvacatc_h || get_label_name('HRPM90X', global_v_lang, 2));

		obj_data_ot.put('o_qtyvacatc_m', o_qtyvacatc_m || get_label_name('HRPM90X', global_v_lang, 3));
		obj_data_ot.put('o_qtyvacatc_dhm', o_qtyvacatc_dhm);
		obj_data_ot.put('o_qtydaylec_d', o_qtydaylec_d || get_label_name('HRPM90X', global_v_lang, 1));

		obj_data_ot.put('o_qtydaylec_h', o_qtydaylec_h || get_label_name('HRPM90X', global_v_lang, 2));
		obj_data_ot.put('o_qtydaylec_m', o_qtydaylec_m || get_label_name('HRPM90X', global_v_lang, 3));

		obj_data_ot.put('o_qtydaylec_dhm', o_qtydaylec_dhm);
		obj_data_ot.put('o_balancec_d', o_balancec_d || get_label_name('HRPM90X', global_v_lang, 1));
		obj_data_ot.put('o_balancec_h', o_balancec_h || get_label_name('HRPM90X', global_v_lang, 2));

		obj_data_ot.put('o_balancec_m', o_balancec_m || get_label_name('HRPM90X', global_v_lang, 3));
		obj_data_ot.put('o_balancec_dhm', o_balancec_dhm);
		obj_data_ot.put('o_qtyreqc_d', o_qtyreqc_d || get_label_name('HRPM90X', global_v_lang, 1));

		obj_data_ot.put('o_qtyreqc_h', o_qtyreqc_h || get_label_name('HRPM90X', global_v_lang, 2));
		obj_data_ot.put('o_qtyreqc_m', o_qtyreqc_m || get_label_name('HRPM90X', global_v_lang, 3));

		obj_data_ot.put('o_qtyreqc_dhm', o_qtyreqc_dhm);
		obj_c_tresintw := json_object_t();
		BEGIN
			IF ( v_tresintw_numqes = 1 ) THEN
				v_tresintw_numqes_now := v_tresintw_numqes_now + 1;
			ELSIF ( v_tresintw_numqes = 0 ) THEN
				v_tresintw_numqes_now := v_tresintw_numqes_now - 1;
			ELSE
				v_tresintw_numqes_now := 1;
			END IF;

			SELECT b.intwno, a.numqes, a.details, a.response
			  INTO tresintw_intwno, tresintw_numqes, tresintw_details, tresintw_response
			  FROM tresintw a,
				   tresreq b
			 WHERE a.codempid = b.codempid
			   AND a.dtereq = b.dtereq
			   AND a.numseq = b.numseq
			   AND a.codempid = p_codempid_query
			   AND b.staappr = 'Y'
			   AND a.numqes = v_tresintw_numqes_now;
		EXCEPTION WHEN no_data_found THEN
			IF ( v_tresintw_numqes = 0 ) THEN
				param_msg_error := get_error_msg_php('HR8842', global_v_lang);
				json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
				return;
			ELSE
				NULL;
			END IF;
		END;

		obj_c_tresintw.put('tresintw_intwno', tresintw_intwno);
		obj_c_tresintw.put('tresintw_numqes', tresintw_numqes);
		obj_c_tresintw.put('tresintw_details', tresintw_details);
		obj_c_tresintw.put('tresintw_response', tresintw_response);
		obj_c_tcolltrl := json_object_t();

		FOR i IN c_tcolltrl LOOP
			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;
			obj_data.put('typcolla', i.typcolla);
			obj_data.put('nameasset', i.nameasset);
			obj_data.put('descoll', i.descoll);
			obj_data.put('numdocum', i.numdocum);
			obj_data.put('amtcolla', i.amtcolla);
			obj_data.put('dtecolla', i.dtecolla);
			obj_data.put('dtestrt', i.dtestrt);
			obj_data.put('amtdedcol', i.amtdedcol);
			obj_data.put('amtbalance', i.amtbalance);
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', TO_CHAR(v_rcnt));
			obj_c_tcolltrl.put(TO_CHAR(v_rcnt - 1), obj_data);
		END LOOP;

		BEGIN
			SELECT dteyrepay, dtemthpay, numperiod
			  INTO v_dteyrepay, v_dtemthpay, v_numperiod
			  FROM ttaxcur
			 WHERE codempid = p_codempid_query
			   AND dteyrepay || dtemthpay || numperiod = ( SELECT MAX(dteyrepay || dtemthpay || numperiod)
															 FROM ttaxcur
															WHERE codempid = p_codempid_query );
		EXCEPTION WHEN no_data_found THEN
			v_dteyrepay := NULL;
			v_dtemthpay := NULL;
			v_numperiod := NULL;
		END;

		BEGIN
			OPEN cursortothinc FOR
				SELECT codpay, get_tinexinf_name(codpay, global_v_lang) codpayname,
					   amtpay, codsys,
					   numperiod || '/' || get_tlistval_name('NAMMTHFUL', dtemthpay, global_v_lang) || '/' || ( dteyrepay ) period
				  FROM tothinc
				 WHERE EXISTS ( SELECT *
								  FROM tsincexp
								 WHERE tothinc.codempid = tsincexp.codempid
								   AND tothinc.dteyrepay = tsincexp.dteyrepay
								   AND tothinc.dtemthpay = tsincexp.dtemthpay
								   AND tothinc.numperiod = tsincexp.numperiod
								   AND tothinc.codpay = tsincexp.codpay)
				   AND codempid = p_codempid_query
				   AND dteyrepay = v_dteyrepay
				   AND dtemthpay = v_dtemthpay
				   AND numperiod = v_numperiod;

			obj_tothinc := json_object_t();
			LOOP FETCH cursortothinc INTO
				tothinc_codpay,
				tothinc_codpayname,
				tothinc_amtpay,
				tothinc_codsys,
				tothinc_period;
			EXIT WHEN cursortothinc%notfound;
				obj_data    := json_object_t();
				v_rcnt      := v_rcnt + 1;
				obj_data.put('codpay', tothinc_codpay);
				obj_data.put('codpayname', tothinc_codpayname);
				obj_data.put('period', tothinc_amtpay);
				obj_data.put('amtpay', tothinc_codsys);
				obj_data.put('codsys', tothinc_period);
				obj_data.put('codsys', tothinc_period);
				obj_tothinc.put(TO_CHAR(v_rcnt - 1), obj_data);
			END LOOP;
		END;

		obj_c_tempinc := json_object_t();
		FOR i IN c_tempinc LOOP
			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;

			BEGIN
				SELECT formula
				  INTO v_formula
				  FROM tformula
				 WHERE codpay = i.codpay
				   AND dteeffec = ( SELECT MAX(dteeffec)
									  FROM tformula
									 WHERE codpay = i.codpay
									   AND dteeffec <= SYSDATE );
			EXCEPTION WHEN no_data_found THEN
				v_formula := NULL;
			END;

			obj_data.put('codpay', i.codpay);
			obj_data.put('codpayname', i.codpayname);
			obj_data.put('periodpay', i.periodpay);
			obj_data.put('formula', v_formula);
			obj_data.put('amount', i.amount);
			obj_data.put('dtestrt', i.dtestrt);
			obj_data.put('dteend', i.dteend);
			obj_data.put('dtecancl', i.dtecancl);
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', TO_CHAR(v_rcnt));
			obj_c_tempinc.put(TO_CHAR(v_rcnt - 1), obj_data);
		END LOOP;

		obj_c_tassets := json_object_t();
		FOR i IN c_tassets LOOP
			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;
			obj_data.put('codasset', i.codasset);
			obj_data.put('assetname', i.assetname);
			obj_data.put('dtercass', i.dtercass);
			obj_data.put('remark', i.remark);
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', TO_CHAR(v_rcnt));
			obj_c_tassets.put(TO_CHAR(v_rcnt - 1), obj_data);
		END LOOP;

		obj_c_fundtrnn := json_object_t();
		FOR i IN c_fundtrnn LOOP
			obj_data := json_object_t();
			v_rcnt := v_rcnt + 1;
			obj_data.put('codcours', i.codcours);
			obj_data.put('desc_codcours', i.desc_codcours);
			obj_data.put('descommt', i.descommt);
			obj_data.put('descommt2', i.descommt2);
			obj_data.put('dtecomexp', to_char(i.dtecomexp,'dd/mm/yyyy'));
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', TO_CHAR(v_rcnt));
			obj_c_fundtrnn.put(TO_CHAR(v_rcnt - 1), obj_data);
		END LOOP;

		obj_c_trepay := json_object_t();
		FOR i IN c_trepay LOOP
			obj_c_trepay.put('qtyrepaym', i.qtyrepaym);
			obj_c_trepay.put('amtrepaym', i.amtrepaym);
			obj_c_trepay.put('dtestrpm', i.dtestrpm);
			obj_c_trepay.put('balance', i.balance);
			obj_c_trepay.put('qtypaid', i.qtypaid);
			obj_c_trepay.put('dtelstpay', i.dtelstpay);
			obj_c_trepay.put('amtoutstd', i.amtoutstd);
			obj_c_trepay.put('coderror', '200');
		END LOOP;

		obj_tloaninf := json_object_t();
		FOR i IN c_tloaninf LOOP
			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;
			obj_data.put('dtelonst', TO_CHAR(i.dtelonst, 'DD/MM/YYYY'));
			obj_data.put('numcont', i.numcont);
			obj_data.put('codlon', i.codlon);
			obj_data.put('amtlon', i.amtlon);
			obj_data.put('balance', i.balance);
			obj_data.put('numlon', i.numlon);
			obj_data.put('qtyperiod', i.qtyperiod);
			obj_data.put('qtyperip', i.qtyperip);
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', TO_CHAR(v_rcnt));
			obj_tloaninf.put(TO_CHAR(v_rcnt - 1), obj_data);
		END LOOP;

		SELECT codempid, dteeffec, numexemp, flgblist, codexemp,
			   flgssm, desnote, dtecreate, CODREQ, dteupd,
			   coduser, staupd
		  INTO v_codempid, v_dteeffec, v_numexemp, v_flgblist, v_codexemp,
			   v_flgssm, v_desnote, v_dtecreate, v_codcreate, v_dteupd,
			   v_coduser, v_staupd
		  FROM ttexempt
		 WHERE codempid = p_codempid_query
		   AND dteeffec = p_dteeffec;

		obj_data := json_object_t();
		obj_data.put('codempid', v_codempid);
		obj_data.put('dteeffec', to_char(v_dteeffec, 'dd/mm/yyyy'));
		obj_data.put('numexemp', v_numexemp);
		obj_data.put('flgblist', v_flgblist);
		obj_data.put('codexemp', v_codexemp);
		obj_data.put('flgssm', v_flgssm);
		obj_data.put('desnote', v_desnote);
		obj_data.put('dtecreate', to_char(v_dtecreate, 'dd/mm/yyyy'));
		obj_data.put('codcreate', v_codcreate);
		obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
		obj_data.put('coduser', v_coduser);
		obj_data.put('desc_coduser', get_temploy_name(get_codempid(v_coduser),global_v_lang));

		SELECT codcomp, codpos, dteempmt, dteeffex, staemp, dteretire
		  INTO popup_codcomp, popup_codpos, popup_dteempmt, popup_dteeffex, popup_staemp, popup_dteretire
		  FROM temploy1
		 WHERE codempid = p_codempid_query;

--		obj_data.put('popup_dteeffex', TO_CHAR(popup_dteeffex, 'DD/MM/YYYY'));
		obj_data.put('popup_dteeffex', TO_CHAR(v_dteeffec, 'DD/MM/YYYY'));
		obj_data.put('popup_staemp', get_tlistval_name('STAEMP', popup_staemp, global_v_lang));
		obj_data.put('popup_dteretire', TO_CHAR(popup_dteretire, 'DD/MM/YYYY'));
		obj_data.put('popup_codcomp', get_tcenter_name(popup_codcomp, global_v_lang));
		obj_data.put('popup_codpos', get_tpostn_name(popup_codpos, global_v_lang));
		obj_data.put('popup_staupd', get_tlistval_name('STAUPD', v_staupd, global_v_lang));
		obj_data.put('popup_dteempmt', TO_CHAR(popup_dteempmt, 'DD/MM/YYYY'));

		BEGIN
			SELECT codleave, typleave
			  INTO p_leave_codleave_vacation, p_leave_typleave_vacation
			  FROM tleavecd
			 WHERE staleave = 'V';
			SELECT codleave, typleave
			  INTO p_leave_codleave_ot, p_leave_typleave_ot
			  FROM tleavecd
			 WHERE staleave = 'C';
		EXCEPTION WHEN no_data_found THEN
			p_leave_codleave_vacation   := NULL;
			p_leave_typleave_vacation   := NULL;
			p_leave_codleave_ot         := NULL;
			p_leave_typleave_ot         := NULL;
		END;

		popup_codcomp := hcm_util.get_codcomp_level(popup_codcomp, 1);
		std_al.cycle_leave(popup_codcomp, p_codempid_query, 'V', SYSDATE, p_yrecyclev_vacation, p_dtecycstv_vacation, p_dtecycenv_vacation);

		BEGIN
			SELECT qtyvacat, qtydayle, nvl(qtyvacat, 0) - nvl(qtydayle, 0)
			  INTO qtyvacat_vacation, qtydayle_vacation, balance_vacation
			  FROM tleavsum
			 WHERE codleave = p_leave_codleave_vacation
			   AND dteyear = p_yrecyclev_vacation
			   AND codempid = p_codempid_query;
		EXCEPTION WHEN no_data_found THEN
			qtyvacat_vacation   := NULL;
			qtydayle_vacation   := NULL;
			balance_vacation    := NULL;
		END;

		std_al.cycle_leave(popup_codcomp, p_codempid_query, 'C', SYSDATE, p_yrecyclev_ot, p_dtecycstv_ot, p_dtecycenv_ot);

		BEGIN
			SELECT qtydleot, qtydayle, nvl(qtyvacat, 0) - nvl(qtydayle, 0)
			  INTO qtydleot_ot, qtydayle_ot, balance_ot
			  FROM tleavsum
			 WHERE codleave = p_leave_codleave_ot
			   AND dteyear = p_yrecyclev_ot
			   AND codempid = p_codempid_query;
		EXCEPTION WHEN no_data_found THEN
			qtydleot_ot := NULL;
			qtydayle_ot := NULL;
			balance_ot := NULL;
		END;

		std_al.cycle_leave(popup_codcomp, p_codempid_query, 'V', SYSDATE, p_yrecyclev_hpd_vacation, p_dtecycstv_hpd_vacation, p_dtecycenv_hpd_vacation);
		std_al.cycle_leave(popup_codcomp, p_codempid_query, 'C', SYSDATE, p_yrecyclev_year_and_leave_ot, p_dtecycstv_year_and_leave_ot, p_dtecycenv_year_and_leave_ot);

		BEGIN
			SELECT flgdlemx
			  INTO v_flgdlemxv
			  FROM tleavety
			 WHERE typleave = p_leave_typleave_vacation;

			SELECT flgdlemx
			  INTO v_flgdlemxc
			  FROM tleavety
			 WHERE typleave = p_leave_typleave_ot;
		EXCEPTION WHEN no_data_found THEN
			v_flgdlemxv := NULL;
			v_flgdlemxc := NULL;
		END;

		IF v_flgdlemxv = 'Y' THEN
			v_qtyreqv := 0;
		ELSE
			BEGIN
				SELECT nvl(SUM(qtyday), 0)
				  INTO v_qtyreqv
				  FROM tlereqd
				 WHERE codempid = p_codempid_query
				   AND dtework BETWEEN p_dtecycstv_vacation AND p_dtecycenv_vacation
				   AND codleave = p_leave_codleave_vacation
				   AND dayeupd IS NULL;
			EXCEPTION WHEN no_data_found THEN
				v_qtyreqv := 0;
			END;
		END IF;

		IF ( v_flgdlemxc = 'Y' ) THEN
			v_qtyreqc := 0;
		ELSE
			BEGIN
				SELECT nvl(SUM(qtyday), 0)
				  INTO v_qtyreqc
				  FROM tlereqd
				 WHERE codempid = p_codempid_query
				   AND dtework BETWEEN p_dtecycstv_ot AND p_dtecycenv_ot
				   AND codleave = p_leave_codleave_ot
				   AND dayeupd IS NULL;
			EXCEPTION WHEN no_data_found THEN
				v_qtyreqc := 0;
			END;
		END IF;

		BEGIN
			SELECT qtyavgwk
			  INTO p_qtyavhwk
			  FROM tcontral
			 WHERE codcompy = p_codempid_query
			   AND dteeffec = ( SELECT MAX(dteeffec)
								  FROM tcontral
								 WHERE dteeffec <= SYSDATE
								   AND codcompy = p_codempid_query );
		EXCEPTION WHEN no_data_found THEN
			p_qtyavhwk := 0;
		END;

		hcm_util.cal_dhm_hm(qtyvacat_vacation, 0, 0, p_qtyavhwk, '1', o_qtyvacat_day_vacation, o_qtyvacat_hr_vacation, o_qtyvacat_min_vacation , o_qtyvacat_dhm_vacation);
		hcm_util.cal_dhm_hm(qtydayle_vacation, 0, 0, p_qtyavhwk, '1', o_qtydayle_day_vacation, o_qtydayle_hr_vacation, o_qtydayle_min_vacation , o_qtydayle_dhm_vacation);
		hcm_util.cal_dhm_hm(balance_ot, 0, 0, p_qtyavhwk, '1', o_balance_day_vacation, o_balance_hr_vacation, o_balance_min_vacation , o_balance_dhm_vacation);
		hcm_util.cal_dhm_hm(v_qtyreqv, 0, 0, p_qtyavhwk, '1', o_qtyreqv_day_vacation, o_qtyreqv_hr_vacation, o_qtyreqv_min_vacation , o_qtyreqv_dhm_vacation);
		hcm_util.cal_dhm_hm(qtydleot_ot, 0, 0, p_qtyavhwk, '1', o_qtyvacat_day_ot, o_qtyvacat_hr_ot, o_qtyvacat_min_ot, o_qtyvacat_dhm_ot );
		hcm_util.cal_dhm_hm(qtydayle_ot, 0, 0, p_qtyavhwk, '1', o_qtydayle_day_ot, o_qtydayle_hr_ot, o_qtydayle_min_ot, o_qtydayle_dhm_ot );
		hcm_util.cal_dhm_hm(balance_ot, 0, 0, p_qtyavhwk, '1', o_balance_day_ot, o_balance_hr_ot, o_balance_min_ot, o_balance_dhm_ot );
		hcm_util.cal_dhm_hm(v_qtyreqc, 0, 0, p_qtyavhwk, '1', o_qtyreqc_day_ot, o_qtyreqc_hr_ot, o_qtyreqc_min_ot, o_qtyreqc_dhm_ot );

		obj_row         := json_object_t();
		obj_data_blank  := json_object_t();
		obj_row.put('o_qtyvacat_day_vacation', o_qtyvacat_day_vacation);
		obj_row.put('o_qtyvacat_hr_vacation', o_qtyvacat_hr_vacation);
		obj_row.put('o_qtyvacat_min_vacation', o_qtyvacat_min_vacation);
		obj_row.put('o_qtyvacat_dhm_vacation', o_qtyvacat_dhm_vacation);
		obj_row.put('o_qtydayle_day_vacation', o_qtydayle_day_vacation);
		obj_row.put('o_qtydayle_hr_vacation', o_qtydayle_hr_vacation);
		obj_row.put('o_qtydayle_min_vacation', o_qtydayle_min_vacation);
		obj_row.put('o_qtydayle_dhm_vacation', o_qtydayle_dhm_vacation);
		obj_row.put('o_balance_day_vacation', o_balance_day_vacation);
		obj_row.put('o_balance_hr_vacation', o_balance_hr_vacation);
		obj_row.put('o_balance_min_vacation', o_balance_min_vacation);
		obj_row.put('o_balance_dhm_vacation', o_balance_dhm_vacation);
		obj_row.put('o_qtyreqv_day_vacation', o_qtyreqv_day_vacation);
		obj_row.put('o_qtyreqv_hr_vacation', o_qtyreqv_hr_vacation);
		obj_row.put('o_qtyreqv_min_vacation', o_qtyreqv_min_vacation);
		obj_row.put('o_qtyreqv_dhm_vacation', o_qtyreqv_dhm_vacation);
		obj_row.put('o_qtyvacat_day_ot', o_qtyvacat_day_ot);
		obj_row.put('o_qtyvacat_hr_ot', o_qtyvacat_hr_ot);
		obj_row.put('o_qtyvacat_min_ot', o_qtyvacat_min_ot);
		obj_row.put('o_qtyvacat_dhm_ot', o_qtyvacat_dhm_ot);
		obj_row.put('o_qtydayle_day_ot', o_qtydayle_day_ot);
		obj_row.put('o_qtydayle_hr_ot', o_qtydayle_hr_ot);
		obj_row.put('o_qtydayle_min_ot', o_qtydayle_min_ot);
		obj_row.put('o_qtydayle_dhm_ot', o_qtydayle_dhm_ot);
		obj_row.put('o_balance_day_ot', o_balance_day_ot);
		obj_row.put('o_balance_hr_ot', o_balance_hr_ot);
		obj_row.put('o_balance_min_ot', o_balance_min_ot);
		obj_row.put('o_balance_dhm_ot', o_balance_dhm_ot);
		obj_row.put('o_qtyreqc_day_ot', o_qtyreqc_day_ot);
		obj_row.put('o_qtyreqc_hr_ot', o_qtyreqc_hr_ot);
		obj_row.put('o_qtyreqc_min_ot', o_qtyreqc_min_ot);
		obj_row.put('o_qtyreqc_dhm_ot', o_qtyreqc_dhm_ot);
		obj_row.put('coderror', '200');
		obj_row.put('response', '');

		obj_sum := json_object_t();
		obj_sum.put('obj_approve_remain', obj_approve_remain);
		obj_sum.put('qtyvacat', obj_data_va);
		obj_sum.put('qtydayle', obj_data_ot);
		obj_sum.put('obj_c_tresintw', obj_c_tresintw);
		obj_sum.put('obj_c_tcolltrl', obj_c_tcolltrl);
		obj_sum.put('obj_tothinc', obj_tothinc);
		obj_sum.put('obj_c_tempinc', obj_c_tempinc);
		obj_sum.put('obj_row', obj_row);
		obj_sum.put('obj_c_tassets', obj_c_tassets);
		obj_sum.put('obj_tloaninf', obj_tloaninf);
		obj_sum.put('ttexempt', obj_data);
		obj_sum.put('obj_c_trepay', obj_c_trepay);
		obj_sum.put('obj_c_fundtrnn', obj_c_fundtrnn);

		obj_sum.put('ttmistk', obj_data_blank);
		obj_sum.put('obj_sal', obj_data_blank);
		obj_sum.put('obj_row1', obj_data_blank);
		obj_sum.put('obj_row2', obj_data_blank);
		obj_sum.put('obj_row3', obj_data_blank);
		obj_sum.put('obj_row4', obj_data_blank);
		obj_sum.put('obj_row5', obj_data_blank);
		obj_sum.put('obj_row6', obj_data_blank);
		obj_sum.put('obj_row7', obj_data_blank);
		obj_sum.put('obj_row8', obj_data_blank);
		obj_sum.put('obj_row9', obj_data_blank);
		obj_sum.put('obj_row10', obj_data_blank);
		obj_sum.put('obj_row11', obj_data_blank);
		obj_sum.put('obj_row12', obj_data_blank);
		obj_sum.put('t2', obj_data_blank);
        flgsecur := secur_main.secur2(p_codempid_query ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        obj_sum.put('v_zupdsal', v_zupdsal);
		obj_sum.put('coderror', '200');
		obj_sum.put('flg_table', 'TTEXEMPT');
		json_str_output := obj_sum.to_clob;
	END gendetail_ttexempt;

	PROCEDURE gendetail ( json_str_output OUT CLOB ) IS
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		v_rcnt			    NUMBER;
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		obj_row2		    json_object_t;
		obj_tab2		    json_object_t;
		obj_data_blank      json_object_t;
		v_codcomp		    ttmovemt.codcomp%TYPE;
		v_codpos		    ttmovemt.codpos%TYPE;
		v_numlvl		    ttmovemt.numlvl%TYPE;
		v_codjob		    ttmovemt.codjob%TYPE;
		v_codempmt		    ttmovemt.codempmt%TYPE;
		v_typemp		    ttmovemt.typemp%TYPE;
		v_typpayroll	    ttmovemt.typpayroll%TYPE;
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
		v_typpayrolt	    ttmovemt.typpayrolt%TYPE;
		v_codbrlct		    ttmovemt.codbrlct%TYPE;
		v_flgattet		    ttmovemt.flgattet%TYPE;
		v_codcalet		    ttmovemt.codcalet%TYPE;
		v_jobgradet		    ttmovemt.jobgrade%TYPE;
		v_codgrpglt		    ttmovemt.codgrpglt%TYPE;
		v2_codcreate		ttmovemt.codcreate%TYPE;
		v2_stapost2		    ttmovemt.stapost2%TYPE;
		v2_dteeffpos		ttmovemt.dteeffpos%TYPE;
		v2_dteduepr		    ttmovemt.dteduepr%TYPE;
		v2_numreqst		    ttmovemt.numreqst%TYPE;
		v2_flgduepr		    ttmovemt.flgduepr%TYPE;
		v2_daytest		    NUMBER;
		v2_desnote		    ttmovemt.desnote%TYPE;
		v2_codempid		    ttmovemt.codempid%TYPE;
		v2_numseq		    ttmovemt.numseq%TYPE;
		v2_dteeffec		    ttmovemt.dteeffec%TYPE;
		v2_codtrn		    ttmovemt.codtrn%TYPE;
		v2_coduser		    ttmovemt.coduser%TYPE;
		v2_dteupd		    ttmovemt.dteupd%TYPE;
		v2_dteend		    ttmovemt.dteend%type;
		obj_sum			    json_object_t;
		v_sal_codcomp		temploy1.codcomp%TYPE;
		codincom_dteeffec	tcontpms.dteeffec%TYPE;
		codincom_codempmt	temploy1.codempmt%TYPE;
		v_datasal           CLOB;
		amtincom            p_num;
		amtincadj           p_num;
		param_json		    json_object_t;
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
		v_amtothr_income	NUMBER := 0;
		v_amtday_income		NUMBER := 0;
		v_sumincom_income	NUMBER := 0;
		v_amtothr_adj		NUMBER := 0;
		v_amtday_adj		NUMBER := 0;
		v_sumincom_adj		NUMBER := 0;
		v_amtothr_simple	NUMBER := 0;
		v_amtday_simple		NUMBER := 0;
		v_sumincom_simple	NUMBER := 0;
		obj_row_income		json_object_t;
		obj_income		    json_object_t;
	BEGIN
		SELECT codcomp, codpos, numlvl, codjob, codempmt,
			   typemp, typpayroll, codbrlc, flgatten, codcalen,
			   jobgrade, codgrpgl, codcompt, codposnow, numlvlt,
			   codjobt, codempmtt, typempt, typpayrolt, codbrlct,
			   flgattet, codcalet, jobgradet, codgrpglt
		  INTO v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt,
			   v_typemp, v_typpayroll, v_codbrlc, v_flgatten, v_codcalen,
			   v_jobgrade, v_codgrpgl, v_codcompt, v_codposnow, v_numlvlt,
			   v_codjobt, v_codempmtt, v_typempt, v_typpayrolt, v_codbrlct,
			   v_flgattet, v_codcalet, v_jobgradet, v_codgrpglt
		  FROM ttmovemt
		 WHERE codempid = p_codempid_query
		   AND numseq = p_numseq
		   AND dteeffec = p_dteeffec;

		SELECT dteend, coduser, dteupd, codcreate, codtrn,
			   codempid, numseq, dteeffec, stapost2, dteeffpos,
			   dteduepr, numreqst, flgduepr, ( dteduepr - dteeffec ) daytest , desnote
		  INTO v2_dteend, v2_coduser, v2_dteupd, v2_codcreate, v2_codtrn,
			   v2_codempid, v2_numseq, v2_dteeffec, v2_stapost2, v2_dteeffpos,
			   v2_dteduepr, v2_numreqst, v2_flgduepr, v2_daytest, v2_desnote
		  FROM ttmovemt
		 WHERE codempid = p_codempid_query
		   AND numseq = p_numseq
		   AND dteeffec = p_dteeffec;
		BEGIN
			SELECT codcomp
			  INTO v_sal_codcomp
			  FROM temploy1
			 WHERE codempid = p_codempid_query;

			SELECT (SELECT MAX(dteeffec)
							   FROM tcontpms
							  WHERE codcompy = hcm_util.get_codcomp_level(v_sal_codcomp,1)),
				   codempmt
			  INTO codincom_dteeffec,
				   codincom_codempmt
			  FROM temploy1
			 WHERE codempid = p_codempid_query;
		EXCEPTION
		WHEN no_data_found THEN
			v_sal_codcomp := NULL;
			codincom_dteeffec := SYSDATE;
			codincom_codempmt := NULL;
		END;

		v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_sal_codcomp, 1)
						|| ''',"p_dteeffec":''' || TO_CHAR(codincom_dteeffec, 'dd/mm/yyyy')
						|| ''',"p_codempmt":'''|| codincom_codempmt|| ''',"p_lang":'''|| global_v_lang|| '''}');
		BEGIN
			SELECT stddec(amtincadj1, codempid, global_v_chken),
				   stddec(amtincadj2, codempid, global_v_chken),
				   stddec(amtincadj3, codempid, global_v_chken),
				   stddec(amtincadj4, codempid, global_v_chken),
				   stddec(amtincadj5, codempid, global_v_chken),
				   stddec(amtincadj6, codempid, global_v_chken),
				   stddec(amtincadj7, codempid, global_v_chken),
				   stddec(amtincadj8, codempid, global_v_chken),
				   stddec(amtincadj9, codempid, global_v_chken),
				   stddec(amtincadj10, codempid, global_v_chken),
				   stddec(amtincom1, codempid, global_v_chken),
				   stddec(amtincom2, codempid, global_v_chken),
				   stddec(amtincom3, codempid, global_v_chken),
				   stddec(amtincom4, codempid, global_v_chken),
				   stddec(amtincom5, codempid, global_v_chken),
				   stddec(amtincom6, codempid, global_v_chken),
				   stddec(amtincom7, codempid, global_v_chken),
				   stddec(amtincom8, codempid, global_v_chken),
				   stddec(amtincom9, codempid, global_v_chken),
				   stddec(amtincom10, codempid, global_v_chken)
			  INTO amtincadj(1), amtincadj(2), amtincadj(3),
				   amtincadj(4), amtincadj(5), amtincadj(6),
				   amtincadj(7), amtincadj(8), amtincadj(9),
				   amtincadj(10), amtincom(1), amtincom(2),
				   amtincom(3), amtincom(4), amtincom(5),
				   amtincom(6), amtincom(7), amtincom(8),
				   amtincom(9), amtincom(10)
			  FROM ttmovemt
			 WHERE codempid = p_codempid_query
			   AND numseq = p_numseq
			   AND dteeffec = p_dteeffec;
		EXCEPTION WHEN no_data_found THEN
			amtincadj(1) := 0;
			amtincadj(2) := 0;
			amtincadj(3) := 0;
			amtincadj(4) := 0;
			amtincadj(5) := 0;
			amtincadj(6) := 0;
			amtincadj(7) := 0;
			amtincadj(8) := 0;
			amtincadj(9) := 0;
			amtincadj(10) := 0;
			amtincom(1) := 0;
			amtincom(2) := 0;
			amtincom(3) := 0;
			amtincom(4) := 0;
			amtincom(5) := 0;
			amtincom(6) := 0;
			amtincom(7) := 0;
			amtincom(8) := 0;
			amtincom(9) := 0;
			amtincom(10) := 0;
		END;
		obj_rowsal := json_object_t();
		param_json := json_object_t(v_datasal);
		FOR i IN 0..param_json.get_size - 1 LOOP
			param_json_row  := hcm_util.get_json_t(param_json, TO_CHAR(i));
			v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
			IF v_desincom IS NULL OR v_desincom = ' ' THEN
				EXIT;
			ELSE
				cnt_row := cnt_row + 1;
			END IF;

		END LOOP;
		FOR i IN 0..cnt_row LOOP
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
			obj_data_salary.put('salchage', trim(TO_CHAR(amtincadj(i + 1), '999,999,990.00')));

			obj_data_salary.put('codincom', v_codincom);
			obj_data_salary.put('desincom', v_desincom);
			IF amtincom(i + 1) - amtincadj(i + 1) = 0 THEN
				obj_data_salary.put('persent', 0);
			ELSE
				obj_data_salary.put('persent', trim(TO_CHAR(amtincadj(i + 1) / (amtincom(i + 1) - amtincadj(i + 1)) * 100 , '999,999,990.00' )));
			END IF;

			obj_data_salary.put('desunit', v_desunit);
			obj_data_salary.put('sumsal', trim(TO_CHAR(nvl(amtincom(i + 1), 0), '999,999,990.00')));
			obj_data_salary.put('amtmax', trim(TO_CHAR(nvl(amtincom(i + 1), '0') - nvl(amtincadj(i + 1), '0'), '999,999,990.00')));
			obj_rowsal.put(v_row, obj_data_salary);
		END LOOP;

		obj_row2 := json_object_t();
		obj_tab2 := json_object_t();
		obj_tab2.put('stapost2', v2_stapost2);
		obj_tab2.put('coduser_to_codempid', get_codempid(v2_coduser));
		obj_tab2.put('coduser', v2_coduser || ' - ' || get_temploy_name(get_codempid(v2_coduser), global_v_lang));
		obj_tab2.put('dteupd', to_char(v2_dteupd, 'dd/mm/yyyy'));
		obj_tab2.put('dteeffpos', to_char(v2_dteeffpos, 'dd/mm/yyyy'));
		obj_tab2.put('dteduepr', to_char(v2_dteduepr, 'dd/mm/yyyy'));
		obj_tab2.put('numreqst', v2_numreqst);
		obj_tab2.put('dteend', to_char(v2_dteend, 'dd/mm/yyyy'));
		obj_tab2.put('codtrn', v2_codtrn);
		obj_tab2.put('flgduepr', v2_flgduepr);
		obj_tab2.put('daytest', v2_daytest);
		obj_tab2.put('desnote', v2_desnote);
		obj_tab2.put('codcreate', get_codempid(v2_codcreate));
		obj_tab2.put('codempid', v2_codempid);
		obj_tab2.put('numseq', v2_numseq);
		obj_tab2.put('dteeffec', to_char(v2_dteeffec, 'dd/mm/yyyy'));
		obj_tab2.put('flgmov', get_tcodec_name('TCODMOVE', v2_codtrn, global_v_lang));
		obj_row := json_object_t();
		obj_data := json_object_t();
		get_wage_income(hcm_util.get_codcomp_level(v_codcompt, 1), v_codempmtt, amtincom(1), amtincom(2), amtincom(3), amtincom(4),
						amtincom(5), amtincom(6), amtincom(7), amtincom(8), amtincom(9), amtincom(10), v_amtothr_income,
						v_amtday_income, v_sumincom_income);

		get_wage_income(hcm_util.get_codcomp_level(v_codcompt, 1), v_codempmtt, amtincadj(1), amtincadj(2), amtincadj(3), amtincadj(4),
						amtincadj(5), amtincadj(6), amtincadj(7), amtincadj(8), amtincadj(9), amtincadj(10), v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

		get_wage_income(hcm_util.get_codcomp_level(v_codcompt, 1), v_codempmtt, amtincom(1) - amtincadj(1), amtincom(2) - amtincadj(2),
						amtincom(3) - amtincadj(3), amtincom(4) - amtincadj(4), amtincom(5) - amtincadj(5), amtincom(6) - amtincadj(6),
						amtincom(7) - amtincadj(7), amtincom(8) - amtincadj(8), amtincom(9) - amtincadj(9), amtincom(10) - amtincadj(10),
						v_amtothr_simple, v_amtday_simple, v_sumincom_simple);
		obj_income      := json_object_t();
		obj_row_income  := json_object_t();
		obj_income.put('income', get_label_name('HRPM44U', global_v_lang, 130));
		obj_income.put('income1', trim(TO_CHAR(v_sumincom_simple, '999,999,990.00')));
		obj_income.put('income2', trim(TO_CHAR(v_sumincom_adj, '999,999,990.00')));
		obj_income.put('income3', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
		obj_row_income.put(0, obj_income);
		obj_income      := json_object_t();
		obj_income.put('income', get_label_name('HRPM44U', global_v_lang, 140));
		obj_income.put('income1', trim(TO_CHAR(v_amtday_simple, '999,999,990.00')));
		obj_income.put('income2', trim(TO_CHAR(v_amtday_adj, '999,999,990.00')));
		obj_income.put('income3', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
		obj_row_income.put(1, obj_income);
		obj_income      := json_object_t();
		obj_income.put('income', get_label_name('HRPM44U', global_v_lang, 150));
		obj_income.put('income1', trim(TO_CHAR(v_amtothr_simple, '999,999,990.00')));
		obj_income.put('income2', trim(TO_CHAR(v_amtothr_adj, '999,999,990.00')));
		obj_income.put('income3', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
		obj_row_income.put(2, obj_income);
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
		obj_data_blank  := json_object_t();

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
		obj_data5.put('col2', v_codempmtt);
		obj_data5.put('col3', v_codempmt);
		obj_data6.put('coderror', '200');
		obj_data6.put('col1', get_label_name('HRPM44U', global_v_lang, 60));
		obj_data6.put('col2', v_typempt);
		obj_data6.put('col3', v_typemp);
		obj_data7.put('coderror', '200');
		obj_data7.put('col1', get_label_name('HRPM44U', global_v_lang, 70));
		obj_data7.put('col2', v_typpayrolt);
		obj_data7.put('col3', v_typpayroll);
		obj_data8.put('coderror', '200');
		obj_data8.put('col1', get_label_name('HRPM44U', global_v_lang, 80));
		obj_data8.put('col2', v_codbrlct);
		obj_data8.put('col3', v_codbrlc);
		obj_data9.put('coderror', '200');
		obj_data9.put('col1', get_label_name('HRPM44U', global_v_lang, 90));
		obj_data9.put('col2', v_flgattet);
		obj_data9.put('col3', v_flgatten);
		obj_data10.put('coderror', '200');
		obj_data10.put('col1', get_label_name('HRPM44U', global_v_lang, 100));
		obj_data10.put('col2', v_codcalet);
		obj_data10.put('col3', v_codcalen);
		obj_data11.put('coderror', '200');
		obj_data11.put('col1', get_label_name('HRPM44U', global_v_lang, 110));
		obj_data11.put('col2', v_jobgradet);
		obj_data11.put('col3', v_jobgrade);
		obj_data12.put('coderror', '200');
		obj_data12.put('col1', get_label_name('HRPM44U', global_v_lang, 120));
		obj_data12.put('col2', v_codgrpglt);
		obj_data12.put('col3', v_codgrpgl);
		obj_sum := json_object_t();
		obj_sum.put('obj_row1', obj_data1);
		obj_sum.put('obj_row2', obj_data2);
		obj_sum.put('obj_row3', obj_data3);
		obj_sum.put('obj_row4', obj_data4);
		obj_sum.put('obj_row5', obj_data5);
		obj_sum.put('obj_row6', obj_data6);
		obj_sum.put('obj_row7', obj_data7);
		obj_sum.put('obj_row8', obj_data8);
		obj_sum.put('obj_row9', obj_data9);
		obj_sum.put('obj_row10', obj_data10);
		obj_sum.put('obj_row11', obj_data11);
		obj_sum.put('obj_row12', obj_data12);
		obj_sum.put('obj_row_income', obj_row_income);
		obj_sum.put('t1', obj_row);
		obj_sum.put('t2', obj_tab2);
		obj_sum.put('t3', obj_rowsal);

		obj_sum.put('ttexempt', obj_data_blank);
		obj_sum.put('obj_sal', obj_data_blank);
		obj_sum.put('ttmistk', obj_data_blank);
		obj_sum.put('ttmovemt0007', obj_data_blank);


		obj_sum.put('flg_table', 'TTMOVEMT');

        flgsecur := secur_main.secur2(p_codempid_query ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        obj_sum.put('v_zupdsal', v_zupdsal);

		obj_sum.put('coderror', '200');
		json_str_output := obj_sum.to_clob;
	END gendetail;

	PROCEDURE getupdate ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		json_obj		    json_object_t;
		params			    json_object_t;
		obj_row			    json_object_t;
		p_codempid		    temploy1.codempid%TYPE;
		p_dteeffec		    date;
		p_codtrn		    ttmovemt.codtrn%TYPE;
		p_numseq		    NUMBER;
		p_seqcancel		    NUMBER;
		p_table             VARCHAR(20);
		p_flg               ttpunsh.staupd%type;
		p_notapprove        ttmovemt.remarkap%type;
		p_approve           ttmovemt.remarkap%type;
		v_stmt			    clob;
		p_detail		    ttmovemt.remarkap%type;
		p_date			    date;
		v_dtestart		    ttpunsh.dtestart%TYPE;
		v_codpunsh		    ttpunsh.codpunsh%TYPE;
    v_numseq_pun      ttpunsh.numseq%TYPE;
		max_numseq		    ttpminf.numseq%TYPE;
		ttpminf_codempid	ttpminf.codempid%TYPE;
		ttpminf_dteeffec	ttpminf.dteeffec%TYPE;
		ttpminf_codtrn		ttpminf.codtrn%TYPE;
		ttpminf_codcomp		ttpminf.codcomp%TYPE;
		ttpminf_codpos		ttpminf.codpos%TYPE;
		ttpminf_codjob		ttpminf.codjob%TYPE;
		ttpminf_numlvl		ttpminf.numlvl%TYPE;
		ttpminf_codempmt	ttpminf.codempmt%TYPE;
		ttpminf_typpayroll	ttpminf.typpayroll%TYPE;
		ttpminf_typemp		ttpminf.typemp%TYPE;
		ttpminf_dtecreate	ttpminf.dtecreate%TYPE;
		ttpminf_codcreate	ttpminf.codcreate%TYPE;
		ttpminf_dteupd		ttpminf.dteupd%TYPE;
		ttpminf_coduser		ttpminf.coduser%TYPE;
        ttpminf_codcalen    ttpminf.codcalen%TYPE;
        ttpminf_codbrlc     ttpminf.codbrlc%TYPE;
        ttpminf_flgatten    ttpminf.flgatten%TYPE;
        ttpminf_codexemp    ttpminf.codexemp%TYPE;
        ttpminf_staemp      ttpminf.staemp%TYPE;
        ttpminf_jobgrade    ttpminf.jobgrade%TYPE;

		ttexempt_codempid	ttexempt.codempid%TYPE;
		ttexempt_dteeffec	ttexempt.dteeffec%TYPE;
		ttexempt_codcomp	ttexempt.codcomp%TYPE;
		ttexempt_codjob		ttexempt.codjob%TYPE;
		ttexempt_codpos		ttexempt.codpos%TYPE;
		ttexempt_codempmt	ttexempt.codempmt%TYPE;
		ttexempt_numlvl		ttexempt.numlvl%TYPE;
        ttexempt_codexemp   ttexempt.codexemp%TYPE;
		ttexempt_dtecreate	ttexempt.dtecreate%TYPE;
		ttexempt_codcreate	ttexempt.codcreate%TYPE;
		ttexempt_dteupd		ttexempt.dteupd%TYPE;
		ttexempt_coduser	ttexempt.coduser%TYPE;
		ttexempt_numannou   ttmistk.numannou%type;
		ttexempt_amtsalt    ttexempt.amtsalt%type;
		ttexempt_amtotht    ttexempt.amtotht%type;
		ttexempt_codsex     temploy1.codsex%type;
		ttexempt_totwkday   ttexempt.totwkday%type;
		ttexempt_desmist1   ttexempt.desnote%type;
		ttexempt_codappr    ttexempt.codappr%type;
		ttexempt_dteappr    ttexempt.dteappr%type;
		ttexempt_remarkap   ttexempt.remarkap%type;
    ttexempt_codedlv    ttexempt.codedlv%type;
    ttexempt_flgblist   ttexempt.flgblist%type;
    ttexempt_flgssm     ttexempt.flgssm%type;
    ttexempt_codreq     ttexempt.codreq%type;
		v_approvno          ttmovemt.approvno%type;
		v_checkapp          boolean := false;
		v_check             varchar2(500 char);
		v_codapp            varchar2(500 char);
		v_typmove           tcodmove.typmove%type;
		v_stapost2          ttmovemt.stapost2%type;

		v_msg_to            clob;
		v_template_to       clob;
		v_func_appr         tfwmailh.codappap%type;
		rowidmail           rowid;
		v_codfrm_to         tfwmailh.codform%TYPE;
		v_error             varchar2(4000 char);
		v_error_cc          varchar2(4000 char);
        p_codreq            temploy1.codempid%type;
        v_codapp_reply      varchar2(500 char);

	BEGIN
		json_obj            := json_object_t(json_str_input);
		params              := hcm_util.get_json_t(json_obj,'dataRows');
		global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
		p_notapprove        := hcm_util.get_string_t(json_obj, 'notapprove');
		p_approve           := hcm_util.get_string_t(json_obj, 'approve');
		p_date              := TO_DATE(hcm_util.get_string_t(json_obj, 'date'), 'dd/mm/yyyy');
		FOR i IN 0..params.get_size - 1 LOOP
			obj_row     := json_object_t();
			obj_row     := hcm_util.get_json_t(params,TO_CHAR(i));
			p_dteeffec  := TO_DATE(hcm_util.get_string_t(obj_row, 'dteeffec'), 'dd/mm/yyyy');
			p_codempid  := hcm_util.get_string_t(obj_row, 'codempid');
			p_table     := hcm_util.get_string_t(obj_row, 'table');
			p_flg       := hcm_util.get_string_t(obj_row, 'flgStaappr');
			p_numseq    := hcm_util.get_string_t(obj_row, 'numseq');
			p_seqcancel    := hcm_util.get_string_t(obj_row, 'seqcancel');
			p_codtrn    := hcm_util.get_string_t(obj_row, 'codtrnid');

			IF ( p_flg = 'A' OR p_flg = 'C' ) THEN
				p_detail    := p_approve;
				p_flg       := 'C';
			ELSE
				p_detail    := p_notapprove;
			END IF;

			IF (p_table = 'TTMOVEMT' OR p_table = 'TTMOVEMT0007') THEN
				IF p_table = 'TTMOVEMT' THEN
					v_codapp := 'HRPM4DE';
          v_codapp_reply := 'HRPM44U';
				ELSIF p_table = 'TTMOVEMT0007' THEN
					v_codapp := 'HRPM4CE';
          v_codapp_reply := 'HRPM44U3';
          p_numseq := p_seqcancel;
				END IF;

				SELECT nvl(approvno,0) + 1, TYPMOVE, STAPOST2, TTMOVEMT.rowid,codreq
				  INTO v_approvno, v_typmove, v_stapost2, rowidmail,p_codreq
				  FROM TTMOVEMT, TCODMOVE
				 WHERE codempid = p_codempid
				   AND TTMOVEMT.CODTRN = TCODMOVE.CODCODEC
				   AND DTEEFFEC = p_dteeffec
				   AND NUMSEQ = p_numseq
				   AND CODTRN = p_codtrn;

				v_checkapp := chk_flowmail.check_approve(v_codapp,p_codempid, v_approvno, global_v_codempid, null, null, v_check);
				if v_checkapp then
					if p_flg <> 'N'  then
						if v_check = 'Y' then
							p_flg := 'C';
						else
							p_flg := 'A';
						end if;
					end if;
					v_stmt := 'update   ttmovemt set
                                        staupd = ''' || p_flg || ''' ,
                                        codappr = ''' || global_v_codempid || ''',
                                        dteappr = to_date(''' || to_char(p_date,'dd/mm/yyyy') || ''',''dd/mm/yyyy''),
                                        remarkap = ''' || replace(p_detail,'''','''''') || ''',
                                        dteupd = to_date(''' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss''),
                                        coduser = ''' || global_v_coduser || ''',
                                        approvno = ' || to_char(v_approvno) || '
								where   codempid = ''' || p_codempid || '''
								and     dteeffec = to_date(''' || to_char(p_dteeffec,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
								and     codtrn = ''' || p_codtrn || '''
								and     numseq = ' || p_numseq;
					IF p_table = 'TTMOVEMT' THEN
						v_stmt := v_stmt || ' and numseq = ' || p_numseq ;
					END IF;

					if p_flg = 'C' then
						if v_typmove <> 'A' AND v_stapost2 = 0 then
							BEGIN
								SELECT nvl(MAX(numseq),0) + 1
								  INTO max_numseq
								  FROM ttpminf
								 WHERE codempid = p_codempid
								   AND dteeffec = p_dteeffec;
							EXCEPTION WHEN no_data_found THEN
								max_numseq := 1;
							END;

							SELECT t1.codempid, t1.dteeffec, t1.codcomp, t1.codpos, t1.codjob,
								   t1.numlvl, t1.codempmt, t1.typpayroll, t1.typemp, t1.dtecreate,
								   t1.codcreate, t1.dteupd, t1.coduser,
                                   t1.codcalen, t1.codbrlc, t1.flgatten, t2.staemp, t2.jobgrade
							  INTO ttpminf_codempid, ttpminf_dteeffec, ttpminf_codcomp, ttpminf_codpos, ttpminf_codjob,
								   ttpminf_numlvl, ttpminf_codempmt, ttpminf_typpayroll, ttpminf_typemp, ttpminf_dtecreate,
								   ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser,
                                   ttpminf_codcalen, ttpminf_codbrlc, ttpminf_flgatten, ttpminf_staemp, ttpminf_jobgrade
							  FROM TTMOVEMT t1, temploy1 t2
							 WHERE t1.codempid = p_codempid
                               and t1.codempid = t2.codempid
							   AND t1.NUMSEQ = p_numseq
							   AND t1.dteeffec = p_dteeffec;


                            INSERT INTO ttpminf (
                                        codempid, dteeffec, numseq, codtrn, codcomp, codpos,
                                        codjob, numlvl, codempmt, codcalen, codbrlc,
                                        typpayroll, typemp, flgatten,
                                        flgal, flgrp, flgap, flgbf, flgtr, flgpy,
                                        codexemp, staemp,
                                        dtecreate, codcreate, dteupd, coduser, jobgrade,dteupdc,coduserc )
                                 VALUES (
                                        ttpminf_codempid, ttpminf_dteeffec, max_numseq, p_codtrn, ttpminf_codcomp, ttpminf_codpos,
                                        ttpminf_codjob, ttpminf_numlvl, ttpminf_codempmt, ttpminf_codcalen, ttpminf_codbrlc,
                                        ttpminf_typpayroll, ttpminf_typemp, ttpminf_flgatten,
                                        'N', 'N', 'N', 'N', 'N', 'N',
                                        null, ttpminf_staemp,
                                        ttpminf_dtecreate, ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser, ttpminf_jobgrade,p_date,global_v_codempid );

						end if;
					end if;
				else
					if v_check = 'HR2010' then
					  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
					else
					  param_msg_error := get_error_msg_php('HR3008', global_v_lang,'tfwmailc');
					end if;
					ROLLBACK;
					json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
					return;
				end if;
			ELSIF ( p_table = 'TTMISTK' ) THEN
				v_codapp := 'HRPM4GE';
                v_codapp_reply := 'HRPM44U1';
				SELECT nvl(approvno,0) + 1, rowid,codreq
				  INTO v_approvno, rowidmail,p_codreq
				  FROM TTMISTK
				 WHERE codempid = p_codempid
				   AND DTEEFFEC = p_dteeffec;

				v_checkapp := chk_flowmail.check_approve(v_codapp,p_codempid, v_approvno, global_v_codempid, null, null, v_check);
				if v_checkapp then
					if p_flg <> 'N'  then
						if v_check = 'Y' then
							p_flg := 'C';
						else
							p_flg := 'A';
						end if;
					end if;

					v_stmt := 'update ttmistk set
								staupd = ''' || p_flg || ''' ,
								codappr = ''' || global_v_codempid || ''',
								dteappr = to_date(''' || to_char(p_date,'dd/mm/yyyy') || ''',''dd/mm/yyyy''),
								remarkap = ''' || replace(p_detail,'''','''''') || ''',
								dteupd = to_date(''' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss''),
								coduser = ''' || global_v_coduser || ''',
								approvno = ' || to_char(v_approvno)
								|| ' where codempid = ''' || p_codempid
								|| ''' and dteeffec = to_date(''' || to_char(p_dteeffec,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ;
					IF ( p_flg IN ('C','N') ) THEN
						BEGIN
							UPDATE TTPUNSH
							   SET STAUPD = p_flg,
								   DTEUPD = SYSDATE,
								   CODUSER = global_v_coduser
							 WHERE codempid = p_codempid
							   AND dteeffec = p_dteeffec;
						END;

						IF p_flg = 'C' THEN
							BEGIN
								SELECT dtestart, codpunsh, numseq
								  INTO v_dtestart, v_codpunsh, v_numseq_pun
								  FROM ttpunsh
								 WHERE codempid = p_codempid
								   AND dteeffec = p_dteeffec
								   AND flgexempt = 'Y'
								   AND ROWNUM <= 1;
							EXCEPTION
							WHEN no_data_found THEN
								v_dtestart := NULL;
								v_codpunsh := NULL;
                v_numseq_pun := NULL;
							END;

--							IF ( v_codpunsh = '0005' ) THEN
							IF ( v_codpunsh is not null ) THEN
								BEGIN
									SELECT nvl(MAX(numseq),0) + 1
									  INTO max_numseq
									  FROM ttpminf
									 WHERE codempid = p_codempid
									   AND dteeffec = p_dteeffec;
								EXCEPTION
								WHEN no_data_found THEN
									max_numseq := 1;
								END;

--								SELECT codempid, dteeffec, codcomp, codpos, codjob,
--									   numlvl, codempmt, typpayroll, typemp, dtecreate,
--									   codcreate, dteupd, coduser
--								  INTO ttpminf_codempid, ttpminf_dteeffec, ttpminf_codcomp, ttpminf_codpos, ttpminf_codjob,
--									   ttpminf_numlvl, ttpminf_codempmt, ttpminf_typpayroll, ttpminf_typemp, ttpminf_dtecreate,
--									   ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser
--								  FROM ttmistk
--								 WHERE codempid = p_codempid
--								   AND dteeffec = p_dteeffec;

								SELECT t1.codempid, t1.dteeffec, emp1.codcomp, emp1.codjob, emp1.codpos,
									   t1.codempmt, emp1.numlvl, t2.codexemp, t1.numannou,
                                       stdenc(greatest(nvl(stddec(emp3.amtincom1, emp3.codempid, global_v_chken),0),0), emp3.codempid, global_v_chken),
									   stdenc(
                                           stddec(emp3.amtincom2, emp3.codempid, global_v_chken) +
                                           stddec(emp3.amtincom3, emp3.codempid, global_v_chken) + stddec(emp3.amtincom4, emp3.codempid, global_v_chken) +
                                           stddec(emp3.amtincom5, emp3.codempid, global_v_chken) + stddec(emp3.amtincom6, emp3.codempid, global_v_chken) +
                                           stddec(emp3.amtincom7, emp3.codempid, global_v_chken) + stddec(emp3.amtincom8, emp3.codempid, global_v_chken) +
                                           stddec(emp3.amtincom9, emp3.codempid, global_v_chken) + stddec(emp3.amtincom10, emp3.codempid, global_v_chken)
                                       , emp3.codempid, global_v_chken),
									   emp1.codsex,emp1.codedlv, t1.dteeffec - emp1.dteempmt + nvl(emp1.qtywkday,0),
                                       t2.flgblist, t2.flgssm, t1.desmist1,
									   t1.codappr, t1.dteappr, t1.remarkap,

                                       t1.codempid, t1.dteeffec, t1.codcomp, t1.codpos, t1.codjob,
									   t1.numlvl, t1.codempmt, t1.typpayroll, t1.typemp, t1.dtecreate,
									   t1.codcreate, t1.dteupd, t1.coduser,
                                       emp1.codcalen, emp1.codbrlc, emp1.flgatten,
                                       t2.codexemp, emp1.staemp, emp1.jobgrade, t1.codreq


								  INTO ttexempt_codempid, ttexempt_dteeffec, ttexempt_codcomp, ttexempt_codjob, ttexempt_codpos,
									   ttexempt_codempmt, ttexempt_numlvl, ttexempt_codexemp, ttexempt_numannou, ttexempt_amtsalt,
									   ttexempt_amtotht,
									   ttexempt_codsex, ttexempt_codedlv, ttexempt_totwkday,
                                       ttexempt_flgblist, ttexempt_flgssm, ttexempt_desmist1,
									   ttexempt_codappr, ttexempt_dteappr, ttexempt_remarkap,

                                       ttpminf_codempid, ttpminf_dteeffec, ttpminf_codcomp, ttpminf_codpos, ttpminf_codjob,
									   ttpminf_numlvl, ttpminf_codempmt, ttpminf_typpayroll, ttpminf_typemp, ttpminf_dtecreate,
									   ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser,
                                       ttpminf_codcalen, ttpminf_codbrlc, ttpminf_flgatten,
                                       ttpminf_codexemp, ttpminf_staemp, ttpminf_jobgrade, ttexempt_codreq

								  FROM ttmistk t1, ttpunsh t2, temploy1 emp1, temploy3 emp3
								 WHERE t1.codempid = p_codempid
                   AND t1.dteeffec = p_dteeffec
                   AND t1.codempid = t2.codempid
                   AND t1.dteeffec = t2.dteeffec
								   AND t1.codempid = emp1.codempid
								   AND t1.codempid = emp3.codempid
                   AND t2.codpunsh = v_codpunsh
                   AND t2.numseq   = v_numseq_pun;

								INSERT INTO ttexempt(
											codempid, dteeffec, codcomp, codjob, codpos,
											codempmt, numlvl, codexemp, typdoc, numannou,
                                            amtsalt, amtotht, codsex, codedlv,
											totwkday, flgblist, staupd, flgrp, flgssm,
                                            dteupd, coduser, desnote,
                                            approvno, codappr, dteappr, remarkap, codreq)
									 VALUES (ttexempt_codempid, v_dtestart, ttexempt_codcomp, ttexempt_codjob, ttexempt_codpos,
                                            ttexempt_codempmt, ttexempt_numlvl, ttexempt_codexemp,'1', ttexempt_numannou,
                                            ttexempt_amtsalt, ttexempt_amtotht, ttexempt_codsex, ttexempt_codedlv,
											ttexempt_totwkday,ttexempt_flgblist, 'C', 'N', ttexempt_flgssm,
                                            trunc(sysdate), global_v_coduser, ttexempt_desmist1,
                                            v_approvno, ttexempt_codappr, ttexempt_dteappr, ttexempt_remarkap, ttexempt_codreq);

								INSERT INTO ttpminf (
											codempid, dteeffec, numseq, codtrn, codcomp, codpos,
											codjob, numlvl, codempmt, codcalen, codbrlc,
                                            typpayroll, typemp, flgatten,
											flgal, flgrp, flgap, flgbf, flgtr, flgpy,
                                            codexemp, staemp, jobgrade,
											dtecreate, codcreate, dteupd, coduser,dteupdc,coduserc )
									 VALUES (
											ttpminf_codempid, v_dtestart, max_numseq, '0006', ttpminf_codcomp, ttpminf_codpos,
											ttpminf_codjob, ttpminf_numlvl, ttpminf_codempmt, ttpminf_codcalen, ttpminf_codbrlc,
                                            ttpminf_typpayroll, ttpminf_typemp, ttpminf_flgatten,
											'N', 'N', 'N', 'N', 'N', 'N',
                                            ttpminf_codexemp, ttpminf_staemp, ttpminf_jobgrade,
											ttpminf_dtecreate, ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser,p_date,global_v_codempid );

							END IF;
						END IF;
					END IF;
				ELSE
					if v_check = 'HR2010' then
					  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
					else
					  param_msg_error := get_error_msg_php('HR3008', global_v_lang,'tfwmailc');
					end if;
					ROLLBACK;
					json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
					return;
				END IF;
			ELSIF ( p_table = 'TTEXEMPT' ) THEN
				v_codapp := 'HRPM4IE';
                v_codapp_reply := 'HRPM44U2';

				SELECT nvl(approvno,0) + 1, rowid, codreq
				  INTO v_approvno, rowidmail, p_codreq
				  FROM TTEXEMPT
				 WHERE codempid = p_codempid
				   AND DTEEFFEC = p_dteeffec;

				v_checkapp := chk_flowmail.check_approve (v_codapp,p_codempid, v_approvno, global_v_codempid, null, null, v_check);
				if v_checkapp then
					if p_flg <> 'N'  then
						if v_check = 'Y' then
							p_flg := 'C';
						else
							p_flg := 'A';
						end if;
					end if;

					v_stmt := 'update ttexempt set
								staupd = ''' || p_flg || ''' ,
								codappr = ''' || global_v_codempid || ''',
								dteappr = to_date(''' || to_char(p_date,'dd/mm/yyyy') || ''',''dd/mm/yyyy''),
								remarkap = ''' || replace(p_detail,'''','''''') || ''',
								dteupd = to_date(''' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss''),
								coduser = ''' || global_v_coduser || ''',
								approvno = ' || to_char(v_approvno)
								|| ' where codempid = ''' || p_codempid
								|| ''' and dteeffec = to_date(''' || to_char(p_dteeffec,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ;

				   if p_flg = 'C' then
						BEGIN
							SELECT nvl(MAX(numseq),0) + 1
							  INTO max_numseq
							  FROM ttpminf
							 WHERE codempid = p_codempid
							   AND dteeffec = p_dteeffec;
						EXCEPTION
						WHEN no_data_found THEN
							max_numseq := 1;
						END;

						SELECT t1.codempid, t1.dteeffec, t1.codcomp, t1.codpos, t1.codjob,
							   t1.numlvl, t1.codempmt, t2.typpayroll, t2.typemp, t1.dtecreate,
							   t1.codcreate, t1.dteupd, t1.coduser, t2.codcalen, t2.codbrlc,
							   t2.flgatten, t1.codexemp, t2.staemp, t2.jobgrade
						  INTO ttpminf_codempid, ttpminf_dteeffec, ttpminf_codcomp, ttpminf_codpos, ttpminf_codjob,
							   ttpminf_numlvl, ttpminf_codempmt, ttpminf_typpayroll, ttpminf_typemp, ttpminf_dtecreate,
							   ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser, ttpminf_codcalen, ttpminf_codbrlc,
							   ttpminf_flgatten, ttpminf_codexemp, ttpminf_staemp, ttpminf_jobgrade
						  FROM ttexempt t1, temploy1 t2
						 WHERE t1.codempid = p_codempid
						   AND t1.codempid = t2.codempid
						   AND t1.dteeffec = p_dteeffec;

						INSERT INTO ttpminf (
									codempid, dteeffec, numseq, codtrn, codcomp, codpos,
									codjob, numlvl, codempmt, codcalen, codbrlc,
									typpayroll, typemp, flgatten,
									flgal, flgrp, flgap, flgbf, flgtr, flgpy,
									codexemp, staemp, jobgrade,
									dtecreate, codcreate, dteupd, coduser,dteupdc,coduserc )
							 VALUES (
									ttpminf_codempid, ttpminf_dteeffec, max_numseq, '0006', ttpminf_codcomp, ttpminf_codpos,
									ttpminf_codjob, ttpminf_numlvl, ttpminf_codempmt, ttpminf_codcalen, ttpminf_codbrlc,
									ttpminf_typpayroll, ttpminf_typemp, ttpminf_flgatten,
									'N', 'N', 'N', 'N', 'N', 'N',
									ttpminf_codexemp, ttpminf_staemp, ttpminf_jobgrade,
									ttpminf_dtecreate, ttpminf_codcreate, ttpminf_dteupd, ttpminf_coduser,p_date,global_v_codempid );
				   end if;
				ELSE
					if v_check = 'HR2010' then
					  param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
					else
					  param_msg_error := get_error_msg_php('HR3008', global_v_lang,'tfwmailc');
					end if;
					ROLLBACK;
					json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
					return;
				END IF;
			END IF;

			BEGIN
				if p_flg <> 'N' then
					p_flg := 'Y';
				end if;
				EXECUTE IMMEDIATE v_stmt;
				INSERT INTO tapmovmt(codapp, codempid, dteeffec, numseq, approvno,
									 codappr, dteappr, staappr, remark, dtecreate, codcreate, coduser)
				VALUES (v_codapp, p_codempid, p_dteeffec, p_numseq, v_approvno,
						global_v_codempid, p_date, p_flg, p_detail, sysdate, global_v_coduser, global_v_coduser);
			EXCEPTION WHEN OTHERS THEN
				rollback;
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                return;
			END;
            begin
                v_error_cc := chk_flowmail.send_mail_reply(v_codapp_reply, p_codempid, p_codreq , global_v_codempid, global_v_coduser, null, 'HRPM44U1', 970, 'U', p_flg, v_approvno, null, null, p_table, rowidmail, '1', null);
            EXCEPTION WHEN OTHERS THEN
                v_error_cc := '2403';
            END;
			if v_checkapp AND v_check = 'N' AND p_flg <> 'N' then
				if p_table = 'TTMOVEMT0007' then
					p_table := 'TTMOVEMT';
				end if;
                begin
                    v_error := chk_flowmail.send_mail_for_approve(v_codapp, p_codempid, global_v_codempid, global_v_coduser, null, 'HRPM44U1', 960, 'U', p_flg, v_approvno + 1, null, null,p_table,rowidmail, '1', null);
                EXCEPTION WHEN OTHERS THEN
                    v_error := '2403';
                END;
            else
                v_error:= v_error_cc;
            end if;
		END LOOP;
		COMMIT;
        IF v_error in ('2046','2402') THEN
            param_msg_error := get_error_msg_php('HR2402', global_v_lang);
        ELSE
            param_msg_error := get_error_msg_php('HR2403', global_v_lang);
        END IF;
		json_str_output := get_response_message('200', param_msg_error, global_v_lang);
		return;
	END getupdate;

  procedure get_exintw_detail (json_str_input in clob, json_str_output out clob) AS
  begin
	initial_value(json_str_input);

	if param_msg_error is null then
	  gen_exintw_detail(json_str_output);
	else
	  json_str_output := get_response_message(null, param_msg_error, global_v_lang);
	end if;
  exception when others then
	param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_exintw_detail;

  procedure gen_exintw_detail (json_str_output out clob) AS
	obj_data           json_object_t;
	v_dtereq           tresreq.dtereq%type;
	v_numseq           tresreq.numseq%type;
	v_dteeffec         tresreq.dteeffec%type;
	v_codexemp         tresreq.codexemp%type;
	v_staappr          tresreq.staappr%type;
	v_desnote          tresreq.desnote%type;
	v_codempid         tresreq.codempid%type;
	v_intwno           tresreq.intwno%type;
	v_response         varchar2(4000 char);
	v_codpos           temploy1.codpos%type;
	cursor c1_texintwh is
	  select intwno
		from texintwh
	   where v_codpos between codposst and codposen
	   order by intwno;
  begin
	v_codempid := p_codempid_query;

	  begin
		SELECT codpos
		  INTO v_codpos
		  FROM temploy1
		 where codempid = v_codempid;
	  exception when no_data_found then
		null;
	  end;

	  begin
		select dtereq, numseq
		  into v_dtereq, v_numseq
		  from tresreq
		 where codempid = v_codempid
		   and staappr in ('P', 'A')
		   and rownum = 1;
	  exception when no_data_found then
		null;
	  end;
	if v_dtereq is not null then
	  obj_data        := json_object_t(get_response_message(null, get_error_msg_php('ES0027', global_v_lang), global_v_lang));
	  v_response      := hcm_util.get_string_t(obj_data, 'response');
	  p_dtereq        := v_dtereq;
	  p_numseq        := v_numseq;
	elsif p_numseq is null then
	  begin
		select nvl(max(numseq), 0) numseq
		  into v_numseq
		  from tresreq
		 where codempid = v_codempid
		   and dtereq   = p_dtereq;
		p_numseq := v_numseq + 1;
	  exception when others then
		null;
	  end;
	end if;
	begin
	  select dteeffec,
			 codexemp,
			 staappr,
			 desnote,
			 intwno
		into v_dteeffec,
			 v_codexemp,
			 v_staappr,
			 v_desnote,
			 v_intwno
	  from tresreq
	  where codempid = v_codempid
		and dtereq   = p_dtereq
		and numseq   = p_numseq;
	exception when no_data_found then
	  null;
	end;
	if v_intwno is null then
	  for r1 in c1_texintwh loop
		v_intwno := r1.intwno;
		exit;
	  end loop;
	end if;

	obj_data := json_object_t();
	obj_data.put('coderror', '200');
	obj_data.put('response', v_response);
	obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
	obj_data.put('numseq', p_numseq);
	obj_data.put('dteeffec', to_char(nvl(v_dteeffec, trunc(sysdate)), 'dd/mm/yyyy'));
	obj_data.put('codexemp', v_codexemp);
	obj_data.put('staappr', v_staappr);
	obj_data.put('desnote', v_desnote);
	obj_data.put('codempid', v_codempid);
	obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
	obj_data.put('intwno', v_intwno);
	obj_data.put('codpos', v_codpos);
	obj_data.put('desc_codpos', v_codpos || ' - ' || get_tpostn_name(v_codpos, global_v_lang));

	json_str_output := obj_data.to_clob;
  end gen_exintw_detail;

  function get_resintw (v_numcate texintwd.numcate%type, v_numseq texintwd.numseq%type) return varchar2 is
	v_response          tresintw.response%type;
  begin
	begin
	  select response
		into v_response
		from tresintw
	   where codempid = global_v_codempid
		 and dtereq   = p_dtereq
		 and numseq   = p_numseq
		 and numcate  = v_numcate
		 and numqes   = v_numseq;
	exception when no_data_found then
	  null;
	end;
	return v_response;
  end;

  function get_exintws (v_intwno texintws.intwno%type, v_numcate texintws.numcate%type) return varchar2 is
	v_namcate           texintws.namcatee%type;
  begin
	begin
	  select decode(global_v_lang, '101', namcatee,
								   '102', namcatet,
								   '103', namcate3,
								   '104', namcate4,
								   '105', namcate5,
								   namcatee)
		into v_namcate
		from texintws
	   where intwno  = v_intwno
		 and numcate = v_numcate;
	exception when no_data_found then
	  null;
	end;
	return v_namcate;
  end;

  procedure get_texintw (json_str_input in clob, json_str_output out clob) AS
  begin
	initial_value(json_str_input);
	if param_msg_error is null then
	  gen_texintw(json_str_output);
	else
	  json_str_output := get_response_message(null, param_msg_error, global_v_lang);
	end if;
  exception when others then
	param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_texintw;

  procedure gen_texintw (json_str_output out clob) AS
	obj_rowd            json_object_t;
	obj_data            json_object_t;
	obj_row             json_object_t;
	obj_datad           json_object_t;
	obj_rowc            json_object_t;
	obj_datac           json_object_t;
	v_rcnt              number := 0;
	v_rcntd             number := 0;
	v_rcntc             number := 0;
	v_numcate           texintwd.numcate%type;
	v_numseq            texintwd.numseq%type;
	v_numans            texintwc.numans%type;
	v_dtereq            tresreq.dtereq%type;

	cursor c1_texintwh is
	  select intwno
		from texintwh
	   where (SELECT codpos FROM temploy1 where codempid = p_codempid_query) between codposst and codposen
	   order by intwno;

	cursor c1 is
	  select numcate
		from texintwd
	   where intwno = p_intwno
	   group by numcate
	   order by numcate;

	cursor c2 is
	  select t1.numcate, t1.numseq,
			 decode(global_v_lang, '101', t1.detailse,
								   '102', t1.detailst,
								   '103', t1.details3,
								   '104', t1.details4,
								   '105', t1.details5) details,
			 t1.detailse, t1.detailst, t1.details3, t1.details4, t1.details5, t2.typeques
		from texintwd t1, texintws t2
	   where t1.intwno     = p_intwno
		 and t1.numcate = v_numcate
		 and t1.intwno  = t2.intwno
		 and t1.numcate = t2.numcate
	   order by numcate, numseq;

	cursor c3 is
	  select numans, decode(global_v_lang, '101', detailse,
															'102', detailst,
															'103', details3,
															'104', details4,
															'105', details5) details,
			 detailse, detailst, details3, details4, details5
		from texintwc
	   where intwno  = p_intwno
		 and numcate = v_numcate
		 and numseq  = v_numseq
	   order by numans;

  begin
	obj_row                 := json_object_t();
	v_rcnt                  := 0;
	if p_numseq is null then
	  begin
		select dtereq, numseq
		  into v_dtereq, v_numseq
		  from tresreq
		 where codempid = p_codempid_query
		   and staappr in ('P', 'A')
		   and rownum = 1;
	  exception when no_data_found then
		null;
	  end;
	end if;
	if v_dtereq is not null then
	  p_dtereq        := v_dtereq;
	  p_numseq        := v_numseq;
	end if;

	if p_intwno is null then
	  for r1 in c1_texintwh loop
		p_intwno := r1.intwno;
		exit;
	  end loop;
	end if;
	for r1 in c1 loop
	  v_numcate               := r1.numcate;
	  obj_rowd                := json_object_t();
	  v_rcnt                  := v_rcnt + 1;
	  v_rcntd                 := 0;
	  for r2 in c2 loop
		v_rcntd                 := v_rcntd + 1;
		obj_datad               := json_object_t();
		v_numseq                := r2.numseq;
		obj_datad.put('coderror', '200');
		obj_datad.put('numcate', to_char(r2.numcate));
		obj_datad.put('numseq', to_char(r2.numseq));
		obj_datad.put('details', r2.details);
		obj_datad.put('detailse', r2.detailse);
		obj_datad.put('detailst', r2.detailst);
		obj_datad.put('details3', r2.details3);
		obj_datad.put('details4', r2.details4);
		obj_datad.put('details5', r2.details5);
		obj_datad.put('typeques', to_char(r2.typeques));
		obj_datad.put('result', get_resintw(v_numcate, v_numseq));

		obj_rowc              := json_object_t();
		v_rcntc               := 0;
		for r3 in c3 loop
		  obj_datac             := json_object_t();
		  v_rcntc               := v_rcntc + 1;
		  obj_datac.put('coderror', '200');
		  obj_datac.put('numans', to_char(r3.numans));
		  obj_datac.put('details', r3.details);
		  obj_datac.put('detailse', r3.detailse);
		  obj_datac.put('detailst', r3.detailst);
		  obj_datac.put('details3', r3.details3);
		  obj_datac.put('details4', r3.details4);
		  obj_datac.put('details5', r3.details5);

		  obj_rowc.put(to_char(v_rcntc - 1), obj_datac);
		end loop;
		obj_datad.put('children', obj_rowc);

		obj_rowd.put(to_char(v_rcntd - 1), obj_datad);
	  end loop;
	  obj_data                := json_object_t();
	  obj_data.put('coderror', '200');
	  obj_data.put('namcate', to_char(v_numcate) || '. ' || get_exintws(p_intwno, v_numcate));
	  obj_data.put('texintw', obj_rowd);

	  obj_row.put(to_char(v_rcnt - 1), obj_data);
	end loop;

	json_str_output := obj_row.to_clob;
  end gen_texintw;
END hrpm44u;

/
