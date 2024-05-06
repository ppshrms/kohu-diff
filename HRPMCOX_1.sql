--------------------------------------------------------
--  DDL for Package Body HRPMCOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMCOX" IS

	PROCEDURE initial_value (json_str IN clob) IS
		json_obj		json_object_t := json_object_t(json_str);
	BEGIN
		global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid        := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang 			:= hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp 				:= hcm_util.get_string_t(json_obj,'p_codcomp');
        p_codempid_query 		:= hcm_util.get_string_t(json_obj,'p_codempid_query');
        p_dtestr 				:= TO_DATE(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
        p_dteend 				:= TO_DATE(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

        p_flglayout 			:= hcm_util.get_string_t(json_obj,'p_flglayout');

        p_codcard 				:= hcm_util.get_string_t(json_obj,'p_codcard');

        p_card                  := hcm_util.get_json_t(json_obj,'p_card');
        p_listfield             := hcm_util.get_json_t(json_obj,'p_listFields');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	END initial_value;

	PROCEDURE check_getindex IS
		v_codcomp		      VARCHAR2(100);
		v_codempid		    VARCHAR2(100);
		v_codcomp_empid		VARCHAR2(100);
		v_numlvl		      VARCHAR2(100);
		v_staemp		      VARCHAR2(1);
		v_secur_codempid	BOOLEAN;
		v_secur_codcomp		BOOLEAN;
	BEGIN
		IF p_codcomp IS NULL AND p_codempid_query IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
			return;
		END IF;

		IF p_codcomp IS NOT NULL AND p_codempid_query IS NOT NULL THEN
			p_codcomp := '';
			p_dtestr := '';
			p_dteend := '';
		END IF;
		IF p_dtestr IS NOT NULL THEN
			IF p_dteend IS NULL THEN
				param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestr');
				return;
			END IF;
		END IF;

		IF p_dteend IS NOT NULL THEN
			IF p_dtestr IS NULL THEN
				param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
				return;
			END IF;
		END IF;
		IF p_dteend IS NOT NULL AND p_dtestr IS NOT NULL THEN
			IF p_dteend < p_dtestr THEN
				param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dtestr');
				return;
			END IF;
		END IF;

		IF p_codempid_query IS NOT NULL THEN
			BEGIN
				SELECT codempid, staemp, codcomp, numlvl
				  INTO v_codempid, v_staemp, v_codcomp_empid, v_numlvl
				  FROM TEMPLOY1
				 WHERE codempid = p_codempid_query;
			EXCEPTION WHEN no_data_found THEN
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
				return;
			END;

			IF v_codcomp_empid IS NOT NULL AND v_numlvl IS NOT NULL THEN
				v_secur_codempid := secur_main.secur1(v_codcomp_empid,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl
				,v_zupdsal);
				IF v_secur_codempid = false THEN
					param_msg_error := get_error_msg_php('HR3007',global_v_lang,v_codcomp_empid);
					return;
				END IF;

			END IF;
			IF v_staemp = 0 THEN
				param_msg_error := get_error_msg_php('HR2102',global_v_lang);
				return;
			END IF;

			IF v_staemp = 9 THEN
				param_msg_error := get_error_msg_php('HR2101',global_v_lang);
				return;
			END IF;
		END IF;

		IF p_codcomp IS NOT NULL THEN
			BEGIN
				SELECT COUNT(*)
				  INTO v_codcomp
				  FROM tcenter
				 WHERE codcomp like p_codcomp||'%';
			EXCEPTION WHEN no_data_found THEN
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
				return;
			END;

			v_secur_codcomp := secur_main.secur7(p_codcomp||'%',global_v_coduser);
			IF v_secur_codcomp = false THEN -- Check User authorize view codcomp
				param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
				return;
			END IF;
		END IF;
	END;

	PROCEDURE check_save IS
		v_count			NUMBER;
	BEGIN
		IF p_namcard IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'namcard');
			return;
		END IF;
	END;

	PROCEDURE gen_index ( json_str_output OUT CLOB ) IS
		v_rcnt			        NUMBER := 0;
		v_rcnt_found		    NUMBER := 0;
		v_secur_codempid	    BOOLEAN;
        v_secur			        boolean;
        v_obj_main              json_object_t;
        v_obj_template          json_object_t;
        v_ttemcard              ttemcard%rowtype;

		cursor c1 IS 
            select codempid, codcomp, numlvl,
                   get_tlistval_name('CODTITLE',codtitle,global_v_lang) ||decode(global_v_lang,'101',namfirste,
                                        '102',namfirstt,
                                        '103',namfirst3,
                                        '104',namfirst4,
                                        '105',namfirst5,namfirste) namfirst,
                   decode(global_v_lang,'101',namlaste,
                                        '102',namlastt,
                                        '103',namlast3,
                                        '104',namlast4,
                                        '105',namlast5,namlaste) namlast
		      from temploy1
		     where codcomp like p_codcomp || '%'
		       AND codempid = nvl(p_codempid_query,codempid)
		       and dteempmt between nvl(p_dtestr,dteempmt) AND nvl(p_dteend,dteempmt)
		       and staemp IN ( '1', '3' )
		  order by codempid;

	BEGIN
		obj_row			:= json_object_t();
        v_obj_template  := json_object_t();

        begin 
            select *
              into v_ttemcard
              from ttemcard
             where flguse = 'Y'
              and rownum = 1
          order by codcard;              
        exception when no_data_found then
            v_ttemcard := null;
        end;

        v_obj_template.put('coderror','200');
        v_obj_template.put('codcard',v_ttemcard.codcard);
        v_obj_template.put('namcard',v_ttemcard.namcard);
        v_obj_template.put('flglayout',v_ttemcard.flglayout);
        if v_ttemcard.namlogo is not null then
            v_obj_template.put('namlogo',get_tsetup_value('PATHDOC')||get_tfolderd('HRPMCOX')||'/'||v_ttemcard.namlogo);
        end if;
        v_obj_template.put('widlogo',v_ttemcard.widlogo);
        v_obj_template.put('heighlogo',v_ttemcard.heighlogo);
        v_obj_template.put('flgcomny',v_ttemcard.flgcomny);
        v_obj_template.put('slogan',v_ttemcard.slogan);
        v_obj_template.put('flgname',v_ttemcard.flgname);
        v_obj_template.put('flgdata1',v_ttemcard.flgdata1);
        v_obj_template.put('descdata1',getDescData (v_ttemcard.flgdata1));
        v_obj_template.put('flgdata2',v_ttemcard.flgdata2);
        v_obj_template.put('descdata2',getDescData (v_ttemcard.flgdata2));
        v_obj_template.put('flgdata3',v_ttemcard.flgdata3);
        v_obj_template.put('descdata3',getDescData (v_ttemcard.flgdata3));
        v_obj_template.put('footer1',v_ttemcard.footer1);
        v_obj_template.put('footer2',v_ttemcard.footer2);
        v_obj_template.put('flgstd',v_ttemcard.flgstd);
        v_obj_template.put('flguse',v_ttemcard.flguse);
        v_obj_template.put('styletemp',v_ttemcard.styletemp);

		FOR r1 IN c1 LOOP
            v_rcnt_found    := v_rcnt_found + 1;
            v_secur         := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
			if v_secur then
                v_rcnt          := v_rcnt + 1;
                obj_data		:= json_object_t ();
                obj_data.put('coderror','200');
                obj_data.put('image',get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E1')||'/'||get_emp_img (r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('desc_codempid1',r1.namfirst);
                obj_data.put('desc_codempid2',r1.namlast);
                obj_data.put('desc_codcompy',get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
                obj_data.put('desc_data1',getDescEmp (v_ttemcard.flgdata1, r1.codempid));
                obj_data.put('desc_data2',getDescEmp (v_ttemcard.flgdata2, r1.codempid));
                obj_data.put('desc_data3',getDescEmp (v_ttemcard.flgdata3, r1.codempid));

                obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);            
            end if;
		END LOOP;

		IF v_rcnt_found > 0 and v_rcnt = 0 THEN
			IF p_codempid_query IS NOT NULL THEN
				param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
			ELSE
				param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
			END IF;
			return;
		END IF;

        IF v_rcnt_found = 0 THEN
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        END IF;



        v_obj_main      := json_object_t();
        v_obj_main.put('coderror','200');
        v_obj_main.put('table',obj_row);
        v_obj_main.put('template',v_obj_template);

		json_str_output := v_obj_main.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_index;

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
		check_getindex;
		IF param_msg_error IS NULL THEN
			gen_index(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE get_setlayout ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
		check_getindex;
		IF param_msg_error IS NULL THEN
			gen_setlayout(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_setlayout ( json_str_output OUT CLOB ) IS
		v_rcnt			        NUMBER := 0;
		v_rcnt_found		    NUMBER := 0;
		v_secur_codempid	    BOOLEAN;
        v_secur			        boolean;

		cursor c1 IS 
            select *
		      from ttemcard
		     where flgstd = 'Y'
              and flglayout = '1'
              and rownum = 1
		  order by codcard;

		cursor c2 IS 
            select *
		      from ttemcard
		     where flgstd = 'Y'
              and flglayout = '2'
              and rownum = 1
		  order by codcard;
	BEGIN
		obj_row			:= json_object_t();
		FOR r1 IN c1 LOOP
            v_rcnt          := v_rcnt + 1;
            obj_data		:= json_object_t ();
            obj_data.put('coderror','200');
            obj_data.put('codcard',r1.codcard);
            obj_data.put('namcard',r1.namcard);
            obj_data.put('flglayout',r1.flglayout);
            obj_data.put('namlogo',r1.namlogo);
            obj_data.put('widlogo',r1.widlogo);
            obj_data.put('heighlogo',r1.heighlogo);
            obj_data.put('flgcomny',r1.flgcomny);
            obj_data.put('slogan',r1.slogan);
            obj_data.put('flgname',r1.flgname);
            obj_data.put('flgdata1',r1.flgdata1);
            obj_data.put('descdata1',getDescData (r1.flgdata1));
            obj_data.put('flgdata2',r1.flgdata2);
            obj_data.put('descdata2',getDescData (r1.flgdata2));
            obj_data.put('flgdata3',r1.flgdata3);
            obj_data.put('descdata3',getDescData (r1.flgdata3));
            obj_data.put('footer1',r1.footer1);
            obj_data.put('footer2',r1.footer2);
            obj_data.put('flgstd',r1.flgstd);
            obj_data.put('flguse',r1.flguse);
            obj_data.put('styletemp',r1.styletemp);
            obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);            
		END LOOP;

		FOR r1 IN c2 LOOP
            v_rcnt          := v_rcnt + 1;
            obj_data		:= json_object_t ();
            obj_data.put('coderror','200');
            obj_data.put('codcard',r1.codcard);
            obj_data.put('namcard',r1.namcard);
            obj_data.put('flglayout',r1.flglayout);
            obj_data.put('namlogo',r1.namlogo);
            obj_data.put('widlogo',r1.widlogo);
            obj_data.put('heighlogo',r1.heighlogo);
            obj_data.put('flgcomny',r1.flgcomny);
            obj_data.put('slogan',r1.slogan);
            obj_data.put('flgname',r1.flgname);
            obj_data.put('flgdata1',r1.flgdata1);
            obj_data.put('descdata1',getDescData (r1.flgdata1));
            obj_data.put('flgdata2',r1.flgdata2);
            obj_data.put('descdata2',getDescData (r1.flgdata2));
            obj_data.put('flgdata3',r1.flgdata3);
            obj_data.put('descdata3',getDescData (r1.flgdata3));
            obj_data.put('footer1',r1.footer1);
            obj_data.put('footer2',r1.footer2);
            obj_data.put('flgstd',r1.flgstd);
            obj_data.put('flguse',r1.flguse);
            obj_data.put('styletemp',r1.styletemp);
            obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);            
		END LOOP;

		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_setlayout;    

	PROCEDURE get_chooseformat ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
--		check_getindex;
		IF param_msg_error IS NULL THEN
			gen_chooseformat(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_chooseformat ( json_str_output OUT CLOB ) IS
		v_rcnt			        NUMBER := 0;

		cursor c1 IS 
            select *
		      from ttemcard
		     where flglayout = p_flglayout
		  order by decode(flgstd,'Y',1,2), codcard;
	BEGIN
		obj_row			:= json_object_t();
		FOR r1 IN c1 LOOP
            v_rcnt          := v_rcnt + 1;
            obj_data		:= json_object_t ();
            obj_data.put('coderror','200');
            obj_data.put('codcard',r1.codcard);
            obj_data.put('namcard',r1.namcard);
            obj_data.put('flglayout',r1.flglayout);
            obj_data.put('namlogo',r1.namlogo);
            obj_data.put('widlogo',r1.widlogo);
            obj_data.put('heighlogo',r1.heighlogo);
            obj_data.put('flgcomny',r1.flgcomny);
            obj_data.put('slogan',r1.slogan);
            obj_data.put('flgname',r1.flgname);
            obj_data.put('flgdata1',r1.flgdata1);
            obj_data.put('descdata1',getDescData (r1.flgdata1));
            obj_data.put('flgdata2',r1.flgdata2);
            obj_data.put('descdata2',getDescData (r1.flgdata2));
            obj_data.put('flgdata3',r1.flgdata3);
            obj_data.put('descdata3',getDescData (r1.flgdata3));
            obj_data.put('footer1',r1.footer1);
            obj_data.put('footer2',r1.footer2);
            obj_data.put('flgstd',r1.flgstd);
            obj_data.put('flguse',r1.flguse);
            obj_data.put('styletemp',r1.styletemp);
            obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);            
		END LOOP;

		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_chooseformat;    

	PROCEDURE get_customtemplate ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
--		check_getindex;
		IF param_msg_error IS NULL THEN
			gen_customtemplate(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_customtemplate ( json_str_output OUT CLOB ) IS
		v_rcnt			        NUMBER := 0;
		v_rcnt_found		    NUMBER := 0;
		v_secur_codempid	    BOOLEAN;
        v_secur			        boolean;
        obj_main                json_object_t;
        obj_listFields          json_object_t;
        obj_row                 json_object_t;
        v_numseq                number := 0;
		cursor c1 IS 
            select *
		      from ttemcard
		     where codcard = p_codcard;
	BEGIN
		obj_data			:= json_object_t();
        obj_data.put('coderror','200');
		FOR r1 IN c1 LOOP
            if r1.flgstd = 'Y' then
                obj_data.put('codcard',p_codcard);
                obj_data.put('namcard','');
                obj_data.put('flguse','N');
            else
                obj_data.put('codcard',r1.codcard);
                obj_data.put('namcard',r1.namcard);
                obj_data.put('flguse',r1.flguse);
            end if;
            obj_data.put('flglayout',r1.flglayout);
            obj_data.put('namlogo',r1.namlogo);
            obj_data.put('widlogo',r1.widlogo);
            obj_data.put('heighlogo',r1.heighlogo);
            obj_data.put('flgcomny',r1.flgcomny);
            obj_data.put('slogan',r1.slogan);
            obj_data.put('flgname',r1.flgname);
            obj_data.put('flgdata1',r1.flgdata1);
            obj_data.put('descdata1',getDescData (r1.flgdata1));
            obj_data.put('flgdata2',r1.flgdata2);
            obj_data.put('descdata2',getDescData (r1.flgdata2));
            obj_data.put('flgdata3',r1.flgdata3);
            obj_data.put('descdata3',getDescData (r1.flgdata3));
            obj_data.put('footer1',r1.footer1);
            obj_data.put('footer1',r1.footer1);
            obj_data.put('footer2',r1.footer2);
            obj_data.put('flgstd','N');
            obj_data.put('styletemp',r1.styletemp);

            obj_row             := json_object_t();

            gen_listfield(r1.flgdata1, r1.flgdata2, r1.flgdata3, obj_row);
--            -- CODPOS
--            obj_listFields      := json_object_t();
--            obj_listFields.put('coderror','200');
--            if r1.flgdata1 = 'CODPOS' or r1.flgdata2 = 'CODPOS' or r1.flgdata3 = 'CODPOS' then
--                obj_listFields.put('flgcheck',true);
--            else
--                obj_listFields.put('flgcheck',false);
--            end if;
--            obj_listFields.put('flgdata','CODPOS');
--            obj_listFields.put('descode',getDescData ('CODPOS'));
--            obj_row.put(TO_CHAR(0),obj_listFields);
--            
--            -- CODCOMP
--            obj_listFields      := json_object_t();
--            obj_listFields.put('coderror','200');
--            if r1.flgdata1 = 'CODCOMP' or r1.flgdata2 = 'CODCOMP' or r1.flgdata3 = 'CODCOMP' then
--                obj_listFields.put('flgcheck',true);
--            else
--                obj_listFields.put('flgcheck',false);
--            end if;
--            obj_listFields.put('flgdata','CODCOMP');
--            obj_listFields.put('descode',getDescData ('CODCOMP'));
--            obj_row.put(TO_CHAR(1),obj_listFields);
--            
--            -- CODEMPID
--            obj_listFields      := json_object_t();
--            obj_listFields.put('coderror','200');
--            if r1.flgdata1 = 'CODEMPID' or r1.flgdata2 = 'CODEMPID' or r1.flgdata3 = 'CODEMPID' then
--                obj_listFields.put('flgcheck',true);
--            else
--                obj_listFields.put('flgcheck',false);
--            end if;
--            obj_listFields.put('flgdata','CODEMPID');
--            obj_listFields.put('descode',getDescData ('CODEMPID'));
--            obj_row.put(TO_CHAR(2),obj_listFields);
		END LOOP;

		obj_main			:= json_object_t();
        obj_main.put('coderror','200');
        obj_main.put('card',obj_data);
        obj_main.put('listFields',obj_row);

		json_str_output := obj_main.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_customtemplate; 

	PROCEDURE save_data ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		v_numcard		    NUMBER;
		v_numcard_txt		VARCHAR2(20);
		v_chk			    VARCHAR2(1);
        v_flgcheck          boolean;
        v_flgdata           ttemcard.flgdata1%type;
        param_json_row      json_object_t;
        v_numseq            number := 0;
        v_obj_data          json_object_t;

        v_flgstd            ttemcard.flgstd%type;

	BEGIN
		initial_value(json_str_input);

        p_codcard 				:= hcm_util.get_string_t(p_card,'codcard');
        p_flglayout 			:= hcm_util.get_string_t(p_card,'flglayout');
        p_namlogo 				:= hcm_util.get_string_t(p_card,'namlogo');
        p_flgcomny 				:= hcm_util.get_string_t(p_card,'flgcomny');
        p_slogan 				:= hcm_util.get_string_t(p_card,'slogan');
        p_flgname 				:= hcm_util.get_string_t(p_card,'flgname');
--        p_flgdata1 				:= hcm_util.get_string_t(p_card,'flgdata1');
--        p_flgdata2 				:= hcm_util.get_string_t(p_card,'flgdata2');
--        p_flgdata3 				:= hcm_util.get_string_t(p_card,'flgdata3');
        p_footer1 				:= hcm_util.get_string_t(p_card,'footer1');
        p_footer2 				:= hcm_util.get_string_t(p_card,'footer2');
        p_flgstd 				:= hcm_util.get_string_t(p_card,'flgstd');
        p_flguse 				:= hcm_util.get_string_t(p_card,'flguse');
        p_namcard 				:= hcm_util.get_string_t(p_card,'namcard');
        p_styletemp 			:= hcm_util.get_string_t(p_card,'styletemp'); 

        p_flgdata1 				:= null;
        p_flgdata2 				:= null;
        p_flgdata3 				:= null;

        begin
            select flgstd
              into v_flgstd
              from ttemcard
             where codcard = p_codcard;
        exception when no_data_found then
            v_flgstd := 'Y';
        end;
        for i in 0..p_listfield.get_size-1 loop
            param_json_row      := hcm_util.get_json_t(p_listfield,to_char(i));
            v_flgcheck          := hcm_util.get_boolean_t(param_json_row,'flgcheck');
            v_flgdata           := upper(hcm_util.get_string_t(param_json_row,'flgdata'));
            if v_flgcheck then
                v_numseq := v_numseq + 1;
                if v_numseq = 1 then
                    p_flgdata1  := v_flgdata;
                elsif v_numseq = 2 then
                    p_flgdata2  := v_flgdata;
                elsif v_numseq = 3 then
                    p_flgdata3  := v_flgdata;
                end if;
            end if;
        end loop;

		check_save;
		IF param_msg_error IS NULL THEN

            if v_flgstd = 'Y' then
                SELECT MAX(codcard)
                  INTO v_numcard
                  FROM ttemcard;

                v_numcard := to_number(v_numcard);

                LOOP
                    v_numcard := v_numcard + 1;
                    BEGIN
                        SELECT 'X'
                          INTO v_chk
                          FROM ttemcard
                         WHERE codcard = lpad(v_numcard,10,'0');
                    EXCEPTION WHEN no_data_found THEN
                        EXIT;
                    END;
                END LOOP;

                v_numcard_txt := lpad(v_numcard,10,'0');  

				insert into ttemcard (codcard, flglayout, namlogo, flgcomny, slogan,
                                      flgname, flgdata1, flgdata2, flgdata3,
                                      footer1, footer2, flgstd, flguse, namcard, styletemp,
                                      codcreate, coduser, dtecreate, dteupd) 
                values (v_numcard_txt, p_flglayout, p_namlogo, p_flgcomny, p_slogan,
                        p_flgname, p_flgdata1, p_flgdata2, p_flgdata3,
                        p_footer1, p_footer2, p_flgstd, p_flguse, p_namcard, p_styletemp,
                        global_v_coduser,global_v_coduser,SYSDATE,SYSDATE);    

                p_codcard := v_numcard_txt;
            else
				update ttemcard
			  	   set flglayout = p_flglayout,
				       namlogo = p_namlogo,
				       flgcomny = p_flgcomny,
                       slogan = p_slogan,
                       flgname = p_flgname,
                       flgdata1 = p_flgdata1,
                       flgdata2 = p_flgdata2,
                       flgdata3 = p_flgdata3,
                       footer1 = p_footer1,
                       footer2 = p_footer2,
                       flgstd = p_flgstd,
                       flguse = p_flguse,
                       namcard = p_namcard,
                       styletemp = p_styletemp,
                       coduser = global_v_coduser,
                       dteupd = SYSDATE
				 where codcard = p_codcard;            
            end if;

			IF param_msg_error IS NULL THEN
--				param_msg_error := get_error_msg_php('HR2401',global_v_lang);
				COMMIT;
			ELSE
				ROLLBACK;
			END IF;
		END IF;

        IF param_msg_error IS NULL THEN
            v_obj_data      := json_object_t();
            v_obj_data.put('coderror','200');
            v_obj_data.put('response',replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201'));
            v_obj_data.put('codcard',p_codcard);    
            json_str_output := v_obj_data.to_clob;
        else
            json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
        end if;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE delete_template ( json_str_input IN CLOB, json_str_output OUT CLOB) IS
        v_flguse            ttemcard.flguse%type;
    BEGIN
		initial_value(json_str_input);

        begin
            select flguse 
              into v_flguse
              from ttemcard
             where codcard = p_codcard;
        exception when no_data_found then
            v_flguse := 'N';
        end;

		IF v_flguse = 'Y' THEN
			param_msg_error := get_error_msg_php('PM0092',global_v_lang);
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		END IF;

        begin
            delete ttemcard
             where codcard = p_codcard;
            param_msg_error := NULL;
        exception when others then null; end; 

		IF param_msg_error IS NULL THEN
			param_msg_error := get_error_msg_php('HR2425',global_v_lang);
			COMMIT;
		ELSE
			ROLLBACK;
		END IF;

		COMMIT;
		json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

  procedure get_ttemcard_use (v_outobj out json_object_t) as
    v_objdata     json_object_t;
    v_countrow    number := 0;
    cursor c1 is 
     select *
		   from ttemcard
		  where flguse = 'Y' ;
  begin
      v_outobj := json_object_t ();
      for i in c1 loop
          v_objdata		:= json_object_t ();

          v_objdata.put('codcard',i.codcard);
          v_objdata.put('namcard',i.namcard);
          v_objdata.put('flglayout',i.flglayout);
          v_objdata.put('namlogo',i.namlogo);
          v_objdata.put('widlogo',i.widlogo);
          v_objdata.put('heighlogo',i.heighlogo);
          v_objdata.put('flgcomny',i.flgcomny);
          v_objdata.put('slogan',i.slogan);
          v_objdata.put('flgname',i.flgname);
          v_objdata.put('flgdata1',i.flgdata1);
          v_objdata.put('flgdata2',i.flgdata2);
          v_objdata.put('flgdata3',i.flgdata3);
          v_objdata.put('footer1',i.footer1);
          v_objdata.put('footer2',i.footer2);
          v_objdata.put('flgstd',i.flgstd);
          v_objdata.put('flguse',i.flguse);

         v_countrow := v_countrow + 1;
         v_outobj.put(v_countrow,v_objdata);
      end loop;
  end get_ttemcard_use;

    procedure init_datareport(json_str_input in clob) as
    v_json_obj json_object_t;
    begin
      v_json_obj  := json_object_t(json_str_input);
      p_listsof_imagedata   := hcm_util.get_json_t(v_json_obj,'p_imageData');
--      get_ttemcard_use(p_listsof_template);

      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    end;

    procedure get_datareport(json_str_input in clob,json_str_output out clob) as
    begin
        initial_value(json_str_input);
        init_datareport(json_str_input);
--        check_datareport(json_str_input);
        if (param_msg_error is not null) then
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        else
           gen_datareportHead(json_str_output);
           gen_datareport (json_str_output);
        end if;

     EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack
		|| ' '
		|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end;

    procedure checkupdatetemcard_use(json_str_input in clob) as
    begin
        if (p_codcard is null or length(p_codcard) = 0 ) then
            param_msg_error := get_error_msg_php('HR2030',global_v_lang);
        end if;
    end checkupdatetemcard_use ;

    procedure updatetemcard_use (json_str_input in clob,json_str_output out clob) as
        v_objdetail     json_object_t;
    begin
        initial_value(json_str_input);
        checkupdatetemcard_use(json_str_input);

        if (param_msg_error is not null or length (param_msg_error) > 0) then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            begin
                update ttemcard 
                   set flguse = 'N'
                 where codcard <> p_codcard;

                update ttemcard 
                   set flguse = 'Y'
                 where codcard = p_codcard;
                commit;
                param_msg_error := get_error_msg_php('HR2401', global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end ;
        end if;
    exception  when others then
        param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end updatetemcard_use;

    procedure check_datareport(json_str_input in clob) as
    v_countemploy    number;
    v_counttemplate     number;
    begin
            v_countemploy := p_listsof_temploy.get_size;
            v_counttemplate := p_listsof_template.get_size;

            if (v_countemploy = 0) then
                param_msg_error := get_error_msg_php('HR2030',global_v_lang);
            end if;

            if (v_counttemplate = 0) then
                param_msg_error := get_error_msg_php('HR2030',global_v_lang);
            end if;

    end;

    procedure gen_datareportHead(json_str_output out clob) as
      v_imageh            tempimge.namimage%type;
      v_folder            tfolderd.folder%type;
      v_has_image         varchar2(1) := 'N'; 
    begin
        begin
            delete from ttemprpt
             where codempid = global_v_codempid
               and codapp = 'HRPMCOX';
        end;

        begin
          select namimage
            into v_imageh
            from tempimge
           where codempid = global_v_codempid;
        exception when no_data_found then
          v_imageh := null;
        end;

        if v_imageh is not null then
          v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
          v_has_image   := 'Y';
        end if;


          INSERT INTO ttemprpt (codempid,codapp,numseq,
                                  item1,
                                  item2,item3,
                                  item4,item5,
                                  item6,item7,
                                  item8,item9)
          values (global_v_codempid,'HRPMCOX',1,
                  'DETAIL',
                  p_codcomp,get_tcenter_name(p_codcomp,global_v_lang),
                  p_codempid_query,get_temploy_name(p_codempid_query,global_v_lang),
                  hcm_util.get_date_buddhist_era(p_dtestr),hcm_util.get_date_buddhist_era(p_dteend),
                  v_has_image,v_imageh);
    end;

    procedure gen_datareport(json_str_output out clob) as
        v_counttemplate         number;
        v_objdetail_template    json_object_t;
        v_imagedata             varchar2(4000);
        v_numseq                number := 2;

    begin
        v_counttemplate   := p_listsof_imagedata.get_size;

        for i in 1..v_counttemplate loop
            v_imagedata    := hcm_util.get_string_t(p_listsof_imagedata,to_char(i));
            INSERT INTO ttemprpt (codempid,codapp,numseq,
                                  item1,
                                  item2,item3,
                                  item4,item5,
                                  item6,item7,
                                  item8)
            values (global_v_codempid,'HRPMCOX',v_numseq,
                  'TABLE',
                  p_codcomp,get_tcenter_name(p_codcomp,global_v_lang),
                  p_codempid_query,get_temploy_name(p_codempid_query,global_v_lang),
                  hcm_util.get_date_buddhist_era(p_dtestr),hcm_util.get_date_buddhist_era(p_dteend),
                  v_imagedata); 
            v_numseq := v_numseq + 1;      
        end loop;

        if (param_msg_error is not null or param_msg_error <> ' ') then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            param_msg_error := get_error_msg_php('HR2401', global_v_lang);
            json_str_output := get_response_message(200,param_msg_error,global_v_lang);
        end if;
    end;

     procedure write_template_V1 (v_objdetail_template in json_object_t) as
        v_counttemploy number;
        v_objdetail_temploy json_object_t;
        v_ttemcard_codcard ttemcard.codcard%type;
        v_ttemcard_namcard ttemcard.namcard%type;
        v_ttemcard_flglayout ttemcard.flglayout%type;
        v_ttemcard_namlogo ttemcard.namlogo%type;
        v_ttemcard_flgcomny ttemcard.flgcomny%type;
        v_ttemcard_slogan   ttemcard.slogan%type;
        v_ttemcard_flgname  ttemcard.flgname%type;
        v_ttemcard_flgdata1 ttemcard.flgdata1%type;
        v_ttemcard_flgdata2 ttemcard.flgdata2%type;
        v_ttemcard_flgdata3 ttemcard.flgdata3%type;
        v_ttemcard_footer1  ttemcard.footer1%type;
        v_ttemcard_footer2  ttemcard.footer2%type;
        v_ttemcard_flgstd   ttemcard.flgstd%type;
        v_ttemcard_flguse   ttemcard.flguse%type;

        --Detail ttemprpt
        v_ttemprpt_codempid ttemprpt.codempid%type;
        v_ttemprpt_codapp ttemprpt.codapp%type;
        v_ttemprpt_numseq  ttemprpt.numseq%type;
        v_pointer number;
        v_countrow_insert number := 1;
        v_complete  boolean;
        -- person 1
        v_person1_item1 ttemprpt.item1%type;
        v_person1_item2 ttemprpt.item2%type;
        v_person1_item3 ttemprpt.item3%type;
        v_person1_item4 ttemprpt.item4%type;
        v_person1_item5 ttemprpt.item5%type;
        v_person1_item6 ttemprpt.item6%type;
        v_person1_item7 ttemprpt.item7%type;
        v_person1_item8 ttemprpt.item8%type;
        v_person1_item9 ttemprpt.item9%type;
        v_person1_item10 ttemprpt.item10%type;
        v_person1_item100 ttemprpt.item100%type;
        v_person1_item104 ttemprpt.item104%type;
       -- person 2
        v_person2_item11 ttemprpt.item11%type;
        v_person2_item12 ttemprpt.item12%type;
        v_person2_item13 ttemprpt.item13%type;
        v_person2_item14 ttemprpt.item14%type;
        v_person2_item15 ttemprpt.item15%type;
        v_person2_item16 ttemprpt.item16%type;
        v_person2_item17 ttemprpt.item17%type;
        v_person2_item18 ttemprpt.item18%type;
        v_person2_item19 ttemprpt.item19%type;
        v_person2_item20 ttemprpt.item20%type;
        v_person2_item101 ttemprpt.item101%type;
        v_person2_item105 ttemprpt.item105%type;
        -- person 3
        v_person3_item21 ttemprpt.item21%type;
        v_person3_item22 ttemprpt.item22%type;
        v_person3_item23 ttemprpt.item23%type;
        v_person3_item24 ttemprpt.item24%type;
        v_person3_item25 ttemprpt.item25%type;
        v_person3_item26 ttemprpt.item26%type;
        v_person3_item27 ttemprpt.item27%type;
        v_person3_item28 ttemprpt.item28%type;
        v_person3_item29 ttemprpt.item29%type;
        v_person3_item30 ttemprpt.item30%type;
        v_person3_item102 ttemprpt.item102%type;
        v_person3_item106 ttemprpt.item106%type;
         -- person 4
        v_person4_item31 ttemprpt.item31%type;
        v_person4_item32 ttemprpt.item32%type;
        v_person4_item33 ttemprpt.item33%type;
        v_person4_item34 ttemprpt.item34%type;
        v_person4_item35 ttemprpt.item35%type;
        v_person4_item36 ttemprpt.item36%type;
        v_person4_item37 ttemprpt.item37%type;
        v_person4_item38 ttemprpt.item38%type;
        v_person4_item39 ttemprpt.item39%type;
        v_person4_item40 ttemprpt.item40%type;
        v_person4_item103 ttemprpt.item103%type;
        v_person4_item107 ttemprpt.item107%type;
      begin
            v_counttemploy :=  p_listsof_temploy.get_size;
            v_ttemcard_codcard :=  hcm_util.get_string_t(v_objdetail_template,'codcard');
            v_ttemcard_namcard :=  hcm_util.get_string_t(v_objdetail_template,'namcard');
            v_ttemcard_flglayout :=  hcm_util.get_string_t(v_objdetail_template,'flglayout');
            v_ttemcard_namlogo := hcm_util.get_string_t(v_objdetail_template,'namlogo');
            v_ttemcard_flgcomny := hcm_util.get_string_t(v_objdetail_template,'flgcomny');
            v_ttemcard_slogan := hcm_util.get_string_t(v_objdetail_template,'slogan');
            v_ttemcard_flgname := hcm_util.get_string_t(v_objdetail_template,'flgname');
            v_ttemcard_flgdata1 := hcm_util.get_string_t(v_objdetail_template,'flgdata1');
            v_ttemcard_flgdata2 := hcm_util.get_string_t(v_objdetail_template,'flgdata2');
            v_ttemcard_flgdata3 :=  hcm_util.get_string_t(v_objdetail_template,'flgdata3');
            v_ttemcard_footer1  := hcm_util.get_string_t(v_objdetail_template,'footer1');
            v_ttemcard_footer2  := hcm_util.get_string_t(v_objdetail_template,'footer2');
            v_ttemcard_flgstd    :=  hcm_util.get_string_t(v_objdetail_template,'flgstd');
            v_ttemcard_flguse    :=  hcm_util.get_string_t(v_objdetail_template,'flguse');

            v_pointer := 1;

                for i in 1..v_counttemploy
                loop
                         v_objdetail_temploy := hcm_util.get_json_t(p_listsof_temploy,i);
                         if (v_pointer = 1) then

                            v_person1_item2 := 'Y';
                            v_person1_item3 := 'file_uploads'||'/'|| get_tfolderd('HRPM1D') ||'/'|| v_ttemcard_namlogo;

                            if ( upper(v_ttemcard_flgcomny) = 'Y') then
                                   v_person1_item4  := getcompybycodempid(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),global_v_lang);
                            else
                                    v_person1_item4  :=  null;
                            end if;

                            v_person1_item5 := v_ttemcard_slogan ;
                            v_person1_item6 := getempname (hcm_util.get_string_t(v_objdetail_temploy,'codempid'),
                                                                                v_ttemcard_flgname,
                                                                                global_v_lang);

                            v_person1_item7 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata1, global_v_lang);

                            v_person1_item8 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata2, global_v_lang);

                            if (length (v_person1_item8) > 0) then
                                    v_person1_item8 := v_person1_item8 ||' \n ';
                            end if;
                             v_person1_item8 :=  v_person1_item8 ||  serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata3, global_v_lang);

                            v_person1_item9 := v_ttemcard_footer1;
                            v_person1_item10 := v_ttemcard_footer2;
                            v_person1_item100 := '*'||hcm_util.get_string_t(v_objdetail_temploy,'codempid')||'*';

                            v_pointer := 2;
                            v_complete := false;
                         elsif (v_pointer = 2) then

                            v_person2_item12 := 'Y';
                            v_person2_item13 := 'file_uploads'||'/'|| get_tfolderd('HRPM1D') ||'/'|| v_ttemcard_namlogo;

                            if ( upper(v_ttemcard_flgcomny) = 'Y') then
                                   v_person2_item14  := getcompybycodempid(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),global_v_lang);
                            else
                                    v_person2_item14  :=  null;
                            end if;

                            v_person2_item15 := v_ttemcard_slogan ;
                            v_person2_item16 := getempname (hcm_util.get_string_t(v_objdetail_temploy,'codempid'),
                                                                                v_ttemcard_flgname,
                                                                                global_v_lang);

                            v_person2_item17 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata1, global_v_lang);

                            v_person2_item18 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata2, global_v_lang);

                            if (length (v_person2_item18) > 0) then
                                    v_person2_item18 := v_person2_item18 ||' \n ';
                            end if;
                             v_person2_item18 :=  v_person2_item18 ||  serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata3, global_v_lang);

                            v_person2_item19 := v_ttemcard_footer1;
                            v_person2_item20 := v_ttemcard_footer2;
                            v_person2_item101 := '*'||hcm_util.get_string_t(v_objdetail_temploy,'codempid')||'*';

                            v_pointer := 3;
                            v_complete := false;
                         elsif (v_pointer = 3) then

                            v_person3_item22 := 'Y';
                            v_person3_item23 := 'file_uploads'||'/'|| get_tfolderd('HRPM1D') ||'/'|| v_ttemcard_namlogo;

                            if ( upper(v_ttemcard_flgcomny) = 'Y') then
                                   v_person3_item24  := getcompybycodempid(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),global_v_lang);
                            else
                                    v_person3_item24  :=  null;
                            end if;

                            v_person3_item25 := v_ttemcard_slogan ;
                            v_person3_item26 := getempname (hcm_util.get_string_t(v_objdetail_temploy,'codempid'),
                                                                                v_ttemcard_flgname,
                                                                                global_v_lang);

                            v_person3_item27 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata1, global_v_lang);

                            v_person3_item28 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata2, global_v_lang);

                            if (length (v_person3_item28) > 0) then
                                    v_person3_item28 := v_person3_item28 ||' \n ';
                            end if;
                             v_person3_item28 :=  v_person3_item28 ||  serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata3, global_v_lang);

                            v_person3_item29 := v_ttemcard_footer1;
                            v_person3_item30 := v_ttemcard_footer2;
                            v_person3_item102 := '*'||hcm_util.get_string_t(v_objdetail_temploy,'codempid')||'*';

                            v_pointer := 4;
                            v_complete := false;
                         elsif (v_pointer = 4) then

                            v_person4_item32 := 'Y';
                            v_person4_item33 := 'file_uploads'||'/'|| get_tfolderd('HRPM1D') ||'/'|| v_ttemcard_namlogo;

                            if ( upper(v_ttemcard_flgcomny) = 'Y') then
                                   v_person4_item34  := getcompybycodempid(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),global_v_lang);
                            else
                                    v_person4_item34  :=  null;
                            end if;

                            v_person4_item35 := v_ttemcard_slogan ;
                            v_person4_item36 := getempname (hcm_util.get_string_t(v_objdetail_temploy,'codempid'),
                                                                                v_ttemcard_flgname,
                                                                                global_v_lang);

                            v_person4_item37 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata1, global_v_lang);

                            v_person4_item38 := serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata2, global_v_lang);

                            if (length (v_person4_item38) > 0) then
                                    v_person4_item38 := v_person4_item38 ||' \n ';
                            end if;
                             v_person4_item38 :=  v_person4_item38 ||  serach_condition(hcm_util.get_string_t(v_objdetail_temploy,'codempid'),v_ttemcard_flgdata3, global_v_lang);

                            v_person4_item39 := v_ttemcard_footer1;
                            v_person4_item40 := v_ttemcard_footer2;
                            v_person4_item103 := '* '||hcm_util.get_string_t(v_objdetail_temploy,'codempid')||' *';

                           v_pointer :=1;
                           v_complete := true;
                           -- insert
                           insert into ttemprpt (
                            CODEMPID,CODAPP, NUMSEQ,
                            ITEM1,ITEM2,ITEM3
                            ,ITEM4,ITEM5,ITEM6
                            ,ITEM7 ,ITEM8 ,ITEM9
                            ,ITEM10  ,ITEM12
                            ,ITEM13 ,ITEM14  ,ITEM15
                            ,ITEM16  ,ITEM17  ,ITEM18
                            ,ITEM19 ,ITEM20
                            ,ITEM22  ,ITEM23 ,ITEM24
                            ,ITEM25  ,ITEM26  ,ITEM27
                            ,ITEM28 ,ITEM29  ,ITEM30,
                             ITEM32 ,ITEM33 ,ITEM34
                            ,ITEM35 ,ITEM36 ,ITEM37
                            ,ITEM38 ,ITEM39, ITEM40,ITEM100,
                            ITEM101,ITEM102,ITEM103 )values(
                             global_v_codempid,'HRPMCOX',v_countrow_insert,
                             v_ttemcard_codcard,v_person1_item2,v_person1_item3,
                             v_person1_item4,v_person1_item5,v_person1_item6,
                             v_person1_item7,v_person1_item8,v_person1_item9,v_person1_item10,
                             v_person2_item12,v_person2_item13,
                             v_person2_item14,v_person2_item15,v_person2_item16,
                             v_person2_item17,v_person2_item18,v_person2_item19,v_person2_item20,
                             v_person3_item22,v_person3_item23,
                             v_person3_item24,v_person3_item25,v_person3_item26,
                             v_person3_item27,v_person3_item28,v_person3_item29,v_person3_item30,
                             v_person4_item32,v_person4_item33,
                             v_person4_item34,v_person4_item35,v_person4_item36,
                             v_person4_item37,v_person4_item38,v_person4_item39,v_person4_item40,
                             v_person1_item100,v_person2_item101,v_person3_item102,v_person4_item103);

                           v_countrow_insert := v_countrow_insert + 1 ;

                           -- Clear Data
                                    v_person1_item2  := null;
                                    v_person1_item3  := null;
                                    v_person1_item4  := null;
                                    v_person1_item5  := null;
                                    v_person1_item6  := null;
                                    v_person1_item7  := null;
                                    v_person1_item8  := null;
                                    v_person1_item9  := null;
                                    v_person1_item10 := null;
                                    v_person1_item100 := null;
                                   -- person 2
                                    v_person2_item12 := null;
                                    v_person2_item13 := null;
                                    v_person2_item14 := null;
                                    v_person2_item15 := null;
                                    v_person2_item16 := null;
                                    v_person2_item17 := null;
                                    v_person2_item18 := null;
                                    v_person2_item19 := null;
                                    v_person2_item20 := null;
                                    v_person2_item101 := null;
                                    -- person 3
                                    v_person3_item22 := null;
                                    v_person3_item23 := null;
                                    v_person3_item24 := null;
                                    v_person3_item25 := null;
                                    v_person3_item26 := null;
                                    v_person3_item27 := null;
                                    v_person3_item28 := null;
                                    v_person3_item29 := null;
                                    v_person3_item30 := null;
                                    v_person3_item102 := null;
                                     -- person 4
                                    v_person4_item32 := null;
                                    v_person4_item33 := null;
                                    v_person4_item34 := null;
                                    v_person4_item35 := null;
                                    v_person4_item36 := null;
                                    v_person4_item37 := null;
                                    v_person4_item38 := null;
                                    v_person4_item39 := null;
                                    v_person4_item40 := null;
                                    v_person4_item103 := null;
                         end if;
                end loop;

                            if ( v_complete = false) then

                                 insert into ttemprpt (
                                    CODEMPID,CODAPP, NUMSEQ,
                                    ITEM1,ITEM2,ITEM3
                                    ,ITEM4,ITEM5,ITEM6
                                    ,ITEM7 ,ITEM8 ,ITEM9
                                    ,ITEM10  ,ITEM12
                                    ,ITEM13 ,ITEM14  ,ITEM15
                                    ,ITEM16  ,ITEM17  ,ITEM18
                                    ,ITEM19 ,ITEM20
                                    ,ITEM22  ,ITEM23 ,ITEM24
                                    ,ITEM25  ,ITEM26  ,ITEM27
                                    ,ITEM28 ,ITEM29  ,ITEM30,
                                     ITEM32 ,ITEM33 ,ITEM34
                                    ,ITEM35 ,ITEM36 ,ITEM37
                                    ,ITEM38 ,ITEM39, ITEM40,ITEM100,
                                    ITEM101,ITEM102,ITEM103 )values(
                                         global_v_codempid,'HRPMCOX',v_countrow_insert,
                                         v_ttemcard_codcard,v_person1_item2,v_person1_item3,
                                         v_person1_item4,v_person1_item5,v_person1_item6,
                                         v_person1_item7,v_person1_item8,v_person1_item9,v_person1_item10,
                                         v_person2_item12,v_person2_item13,
                                         v_person2_item14,v_person2_item15,v_person2_item16,
                                         v_person2_item17,v_person2_item18,v_person2_item19,v_person2_item20,
                                         v_person3_item22,v_person3_item23,
                                         v_person3_item24,v_person3_item25,v_person3_item26,
                                         v_person3_item27,v_person3_item28,v_person3_item29,v_person3_item30,
                                         v_person4_item32,v_person4_item33,
                                         v_person4_item34,v_person4_item35,v_person4_item36,
                                         v_person4_item37,v_person4_item38,v_person4_item39,v_person4_item40,
                                         v_person1_item100,v_person2_item101,v_person3_item102,v_person4_item103);

                            end if;

       EXCEPTION
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack
		|| ' '
		|| dbms_utility.format_error_backtrace;
     end;

    procedure write_template_H1 (v_objdetail_template in json_object_t) as
     begin
        null;
     end;

    procedure write_template_H2 (v_objdetail_template in json_object_t) as
     begin
        null;
     end;

    procedure write_template_H3 (v_objdetail_template in json_object_t) as
     begin
        null;
     end;


    procedure write_template_V2 (v_objdetail_template in json_object_t) as
     begin
        null;
     end;

    procedure write_template_V3 (v_objdetail_template in json_object_t) as
     begin
        null;
     end;

      function serach_condition (v_codempid in varchar2,v_condition in varchar2,v_lang  in varchar2)return varchar2 is
      begin
                if (v_condition is null or length(trim(v_condition)) = 0) then
                    return null;
                elsif (upper(v_condition) = 'CODPOS') then
                   return getpositionnamebycodempid(v_codempid,v_lang);
                elsif (upper(v_condition) = 'CODCOMP') then
                  return getdepartmentbycodempid(v_codempid,v_lang) ;
                elsif (upper(v_condition) = 'CODEMPID') then
                  return  get_label_name('HRPM57X2',v_lang,30) ;
                end if;

      end serach_condition;

    function getcompybycodempid (v_codempid in varchar2, v_lang  in varchar2) return varchar2  is
    v_codcomp    temploy1.codcomp%type;
    begin
                begin
                        select codcomp into v_codcomp
                        from temploy1
                        where codempid = v_codempid ;
                        return get_tcompny_name( hcm_util.get_codcomp_level(v_codcomp, 1),v_lang);
                   exception
               when no_data_found then
                return '';
               end ;
    end getcompybycodempid;

     function getempname (v_codempid in varchar2,v_flgname in varchar2 ,v_lang  in varchar2)  return varchar2 is
     v_firstname   temploy1.namfirste%type;
     v_lastname   temploy1.namlaste%type;

     begin

             begin
                     select decode(v_lang  ,'101',NAMFIRSTE,
   	                                '102',NAMFIRSTT,
   	                                '103',NAMFIRST3,
   	                                '104',NAMFIRST4,
   	                                '105',NAMFIRST5,NAMFIRSTE),
                                    decode(v_lang  ,'101',NAMLASTE,
   	                                '102',NAMLASTT,
   	                                '103',NAMLAST3,
   	                                '104',NAMLAST4,
   	                                '105',NAMLAST5,NAMLASTE)
                     into   v_firstname,v_lastname
                     from   temploy1
                     where  codempid   = v_codempid ;

                     if (upper(v_flgname) = '1') then
                        return v_firstname ||' '|| v_lastname;
                     else
                        return v_firstname ||'\n'|| v_lastname;
                     end if;
             exception
                when no_data_found then
                        return '';
             end;

     end getempname;

     function getpositionnamebycodempid (v_codempid in varchar2,v_lang  in varchar2) return varchar2 is
      v_positionname tpostn.nampose%type;
      begin
                begin
                            select get_tpostn_name(codpos,v_lang) into v_positionname
                            from temploy1
                            where  codempid   = v_codempid ;
                              return v_positionname;
                exception
                when no_data_found then
                        return '';
                end;
     end getpositionnamebycodempid;

      function getdepartmentbycodempid (v_codempid in varchar2,v_lang  in varchar2) return varchar2 is
        v_codcomp temploy1.codcomp%type;
      begin
              begin
                            select codcomp into v_codcomp
                            from temploy1
                            where  codempid   = v_codempid ;
                              return get_tcenter_name(v_codcomp,v_lang) ;
                exception
                when no_data_found then
                        return '';
                end;
      end getdepartmentbycodempid;

      function getDescData (p_columnname in varchar2) return varchar2 is
        v_codcomp temploy1.codcomp%type;
      begin
        if p_columnname = 'CODCOMP' then
            return get_label_name('HRPMCOX',global_v_lang,150);
        elsif p_columnname = 'CODEMPID' then
            return get_label_name('HRPMCOX',global_v_lang,60);
        elsif p_columnname = 'CODPOS' then
            return get_label_name('HRPMCOX',global_v_lang,140);
        else
            return '';
        end if;
      end getDescData;

      function getDescEmp (p_columnname in varchar2, p_codempid varchar2) return varchar2 is
        v_codcomp   temploy1.codcomp%type;
        v_codpos    temploy1.codpos%type;
      begin
        begin
            select codcomp,codpos
              into v_codcomp,v_codpos
              from temploy1
             where codempid = p_codempid;            
        exception when no_data_found then
            v_codcomp   := null;
            v_codpos    := null;
        end;

        if p_columnname = 'CODCOMP' then
            return get_tcenter_name(v_codcomp,global_v_lang);
        elsif p_columnname = 'CODEMPID' then
            return p_codempid;
        elsif p_columnname = 'CODPOS' then
            return get_tpostn_name(v_codpos,global_v_lang);
        else
            return '';
        end if;
      end getDescEmp;

      procedure gen_listfield (p_flgdata1 in varchar2, p_flgdata2 in varchar2, p_flgdata3 in varchar2, obj_row in out json_object_t) is
            v_numseq                number;
            obj_listFields          json_object_t;
            obj_listFields1         json_object_t;
            obj_listFields2         json_object_t;
            obj_listFields3         json_object_t;
            v_flg_codpos            boolean;
            v_flg_codcomp           boolean;
            v_flg_codempid          boolean;
      begin

            -- CODPOS
            obj_listFields      := json_object_t();
            obj_listFields.put('coderror','200');
            if p_flgdata1 = 'CODPOS' or p_flgdata2 = 'CODPOS' or p_flgdata3 = 'CODPOS' then
                obj_listFields.put('flgcheck',true);
            else
                obj_listFields.put('flgcheck',false);
            end if;
            obj_listFields.put('flgdata','CODPOS');
            obj_listFields.put('descode',getDescData ('CODPOS'));

            if p_flgdata1 = 'CODPOS' then
                v_numseq := 0;
                obj_listFields1 := obj_listFields;
            elsif p_flgdata2 = 'CODPOS' then
                v_numseq := 1;
                obj_listFields2 := obj_listFields;
            elsif p_flgdata3 = 'CODPOS' then
                v_numseq := 2;
                obj_listFields3 := obj_listFields;
            else
                if p_flgdata1 is null then
                    v_numseq := 0;
                    obj_listFields1 := obj_listFields;
                elsif p_flgdata2 is null then
                    v_numseq := 1;
                    obj_listFields2 := obj_listFields;
                else
                    v_numseq := 2;
                    obj_listFields3 := obj_listFields;
                end if;
            end if;

            -- CODCOMP
            obj_listFields      := json_object_t();
            obj_listFields.put('coderror','200');
            if p_flgdata1 = 'CODCOMP' or p_flgdata2 = 'CODCOMP' or p_flgdata3 = 'CODCOMP' then
                obj_listFields.put('flgcheck',true);
            else
                obj_listFields.put('flgcheck',false);
            end if;
            obj_listFields.put('flgdata','CODCOMP');
            obj_listFields.put('descode',getDescData ('CODCOMP'));

            if p_flgdata1 = 'CODCOMP' then
                v_numseq := 0;
                obj_listFields1 := obj_listFields;
            elsif p_flgdata2 = 'CODCOMP' then
                v_numseq := 1;
                obj_listFields2 := obj_listFields;
            elsif p_flgdata3 = 'CODCOMP' then
                v_numseq := 3;
                obj_listFields1 := obj_listFields;
            else
                if p_flgdata2 is null then
                    v_numseq := 1;
                    obj_listFields2 := obj_listFields;
                else
                    v_numseq := 2;
                    obj_listFields3 := obj_listFields;
                end if;
            end if;

            -- CODEMPID
            obj_listFields      := json_object_t();
            obj_listFields.put('coderror','200');
            if p_flgdata1 = 'CODEMPID' or p_flgdata2 = 'CODEMPID' or p_flgdata3 = 'CODEMPID' then
                obj_listFields.put('flgcheck',true);
            else
                obj_listFields.put('flgcheck',false);
            end if;
            obj_listFields.put('flgdata','CODEMPID');
            obj_listFields.put('descode',getDescData ('CODEMPID'));

            if p_flgdata1 = 'CODEMPID' then
                v_numseq := 0;
                obj_listFields1 := obj_listFields;
            elsif p_flgdata2 = 'CODEMPID' then
                v_numseq := 1;
                obj_listFields2 := obj_listFields;
            elsif p_flgdata3 = 'CODEMPID' then
                v_numseq := 2;
                obj_listFields3 := obj_listFields;
            else
                v_numseq := 2;
                obj_listFields3 := obj_listFields;
            end if;

            obj_row.put(TO_CHAR(0),obj_listFields1);
            obj_row.put(TO_CHAR(1),obj_listFields2);
            obj_row.put(TO_CHAR(2),obj_listFields3);
      end gen_listfield;

END hrpmcox;

/
