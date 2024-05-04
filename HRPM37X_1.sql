--------------------------------------------------------
--  DDL for Package Body HRPM37X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM37X" is

  PROCEDURE initial_value (json_str IN CLOB) IS
		json_obj   json_object_t := json_object_t(json_str);
	BEGIN
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
		p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
		p_typproba          := hcm_util.get_string_t(json_obj,'p_typproba');
		p_codrespr          := hcm_util.get_string_t(json_obj,'p_codrespr');
		p_dteduepr_str      := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteduepr_str') ),'dd/mm/yyyy');

		p_dteduepr_end      := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteduepr_end') ),'dd/mm/yyyy');

		p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
		p_dteduepr          := TO_DATE(hcm_util.get_string_t(json_obj,'p_dteduepr'),'ddmmyyyy');
		p_typdata           := hcm_util.get_string_t(json_obj,'p_typdata');
        p_dteeffec          := TO_DATE(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');
        p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	END initial_value;

	PROCEDURE get_index (json_str_input    IN CLOB,json_str_output   OUT CLOB) AS
	BEGIN
		initial_value(json_str_input);
		check_getindex;
		IF param_msg_error IS NULL THEN
			gen_index(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;

	EXCEPTION
	WHEN OTHERS THEN
	  param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
	  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE check_getindex IS
		v_codcomp         VARCHAR2(100);
		v_secur_codcomp   BOOLEAN;
	BEGIN
		IF p_codcomp IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
			return;
		END IF;

		IF p_dteduepr_str IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_str');
			return;
		END IF;

		IF p_dteduepr_end IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_end');
			return;
		END IF;

		IF p_typproba IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_typproba');
			return;
		END IF;

		IF p_codrespr IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codrespr');
			return;
		END IF;

		IF p_dteduepr_str IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_str');
			return;
		END IF;

		IF p_dteduepr_str > p_dteduepr_end THEN
			param_msg_error := get_error_msg_php('HR2021',global_v_lang);
			return;
		END IF;

		IF p_codcomp IS NOT NULL THEN
			BEGIN
				SELECT
					COUNT(*)
				INTO v_codcomp
				FROM
					tcenter
				WHERE
					codcomp LIKE p_codcomp || '%';

			EXCEPTION
				WHEN no_data_found THEN
					param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
					return;
			END;

			v_secur_codcomp := secur_main.secur7(p_codcomp || '%',global_v_coduser);
			IF v_secur_codcomp = false THEN  -- Check User authorize view codcomp
				param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
				return;
			END IF;

		END IF;

	END;

	PROCEDURE gen_index (json_str_output OUT CLOB) IS
		v_rcnt             NUMBER := 0;
		v_rcnt_found       NUMBER := 0;
		v_codrespr         VARCHAR2(100);
		v_secur_codempid   BOOLEAN;
		v_avascore         NUMBER;
		v_p_zupdzap        VARCHAR2(100);

		cursor c1 is
			select '1' typdata, a.codempid, a.dteduepr, a.codpos, a.codcomp, a.codrespr,
				   a.dteeffex, a.dteoccup, b.dteempmt
			  from ttprobat a, temploy1 b
			 where a.codempid = b.codempid
			   and a.codcomp  like p_codcomp||'%'
			   and a.dteduepr between p_dteduepr_str and  p_dteduepr_end
			   and a.typproba = p_typproba
			   and  (a.codrespr in ( 'P','N','E') and (p_codrespr  = a.codrespr  or  p_codrespr = 'A'))
			 union
			select '2' typdata, a.codempid, a.dteduepr, b.codpos, b.codcomp, a.codrespr,
				   null dteeffex, null dteoccup, b.dteempmt
			  from ttprobatd a, temploy1 b
			 where a.codempid = b.codempid
			   and b.codcomp  like p_codcomp||'%'
			   and a.dteduepr between p_dteduepr_str and  p_dteduepr_end
			   and ( (p_typproba = '1' and b.staemp = 1) or (p_typproba = '2' and b.staemp = 3))
			   and  (a.codrespr = 'M' and (p_codrespr = 'M' or p_codrespr = 'A'))
			   and not exists (select codempid from ttprobat c
									where c.codempid = a.codempid
									  and c.dteduepr  = a.dteduepr)
		  order by codcomp, codempid;
	BEGIN
		obj_row := json_object_t ();
		FOR i IN c1 LOOP
			v_secur_codempid := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap);
			IF v_secur_codempid THEN
			    v_rcnt := v_rcnt + 1;
                v_rcnt_found := v_rcnt_found + 1;
                obj_data := json_object_t ();
                obj_data.put('coderror','200');
                obj_data.put('image',nvl(get_emp_img(i.codempid),i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
                obj_data.put('codpos',i.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
                obj_data.put('dteempmt',TO_CHAR(i.dteempmt,'dd/mm/yyyy') );
                obj_data.put('dteeffex',TO_CHAR(i.dteeffex,'dd/mm/yyyy') );
                obj_data.put('dteduepr',TO_CHAR(i.dteduepr,'dd/mm/yyyy') );
                obj_data.put('codrespr',get_tlistval_name ('NAMEVAL', i.codrespr , global_v_lang));
                obj_data.put('dteoccup',TO_CHAR(i.dteoccup,'dd/mm/yyyy') );
                obj_data.put('typdata',i.typdata );
                obj_data.put('typproba',p_typproba );

                v_avascore := 0;
                For i_numtime in 1..4 loop
                    v_avascore := 0;
                    begin
                        select a.avgscor
                          into v_avascore
                          from TTPROBATD a
                         where a.codempid = i.codempid
                           and a.dteduepr = i.dteduepr
                           and a.numtime = i_numtime;
                    exception when others then
                        v_avascore := null;
                    end;
                    obj_data.put('avascore_'||to_char(i_numtime),v_avascore);
                end loop;
                    obj_row.put(TO_CHAR(v_rcnt_found - 1),obj_data);
			END IF;
		END LOOP;
		json_str_output := obj_row.to_clob;
		IF v_rcnt_found = 0 AND v_rcnt > 0 THEN
			param_msg_error := get_error_msg_php('HR3007',global_v_lang,NULL);
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		elsif v_rcnt = 0 then
		   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		WHEN OTHERS THEN
			param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_index;

	PROCEDURE get_detail (json_str_input    IN CLOB,json_str_output   OUT CLOB) AS
	BEGIN
		initial_value(json_str_input);
		IF param_msg_error IS NULL THEN
			gen_detail(json_str_output);
		ELSE
			json_str_output := get_response_message(400,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
	  param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
	  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_detail (json_str_output OUT CLOB) IS
		v_rcnt             NUMBER := 0;
		v_rcnt_found       NUMBER := 0;
		v_codrespr         VARCHAR2(100);
		v_secur_codempid   BOOLEAN;
		v_avascore         NUMBER;
		v_p_zupdzap        VARCHAR2(100);
        v_ttmovemt_dteeffec          date;
        v_ttmovemt_numseq            number;
        obj_data            json_object_t;

		cursor c1 is
			select a.codeval, a.typproba, b.dteempmt, a.dteduepr, a.dteeval, a.codrespr,
				   a.dteeffex, a.flgrepos , '' codcompo, '' codposo,
				   a.codexemp, a.qtyexpand, /*'P' flgappr,*/ a.dteeffec, a.numseq
			  from ttprobat a, temploy1 b
			 where a.codempid = b.codempid
			   and a.codempid = p_codempid_query
			   and a.dteduepr = p_dteduepr;

		cursor c2 is
			select a.staeval, b.dteempmt, a.dteduepr, a.dteeval, a.codrespr, a.flgrepos , a.codexemp, a.codeval, a.qtyexpand, a.flgappr
			  from tappbath a, temploy1 b
			 where a.codempid = b.codempid
			   and a.codempid = p_codempid_query
			   and a.dteduepr = p_dteduepr
			   and a.numtime = (select max(numtime) from tappbath where codempid = p_codempid_query)
			   and a.numseq = (select max(numseq) from tappbath b where b.codempid = p_codempid_query and b.dteduepr = p_dteduepr and b.numtime = a.numtime and dteeval is not null);

		cursor c3 is
			select *
			from ttmovemt
			where codempid = p_codempid_query
              and dteeffec = v_ttmovemt_dteeffec
              and numseq = v_ttmovemt_numseq;
	BEGIN
		obj_data    := json_object_t ();
        obj_row     := json_object_t ();

		if p_typproba = '1' then --User37 #5251 Final Test Phase 1 V11 01/03/2021 p_typdata = '1' then
			FOR r1 IN c1 LOOP
                v_ttmovemt_dteeffec := r1.dteeffec;
                v_ttmovemt_numseq   := r1.numseq;
                obj_data.put('codempid',p_codempid_query);
				obj_data.put('codeval',r1.codeval);
				obj_data.put('desc_codeval',get_temploy_name(r1.codeval,global_v_lang));
				obj_data.put('desc_typproba',get_tlistval_name('NAMTPRO', r1.typproba, global_v_lang));
				obj_data.put('typproba',r1.typproba);
				obj_data.put('dteempmt',TO_CHAR(r1.dteempmt,'dd/mm/yyyy') );
				obj_data.put('dteduepr',TO_CHAR(r1.dteduepr,'dd/mm/yyyy') );
				obj_data.put('dteeval',TO_CHAR(r1.dteeval,'dd/mm/yyyy') );
				obj_data.put('codrespr',r1.codrespr);
				obj_data.put('dteeffex',TO_CHAR(r1.dteeffex,'dd/mm/yyyy') );
				for r2 in c2 loop
					obj_data.put('staeval',r2.staeval );
				    obj_data.put('flgappr',r2.flgappr);
				end loop;
				obj_data.put('flgrepos',r1.flgrepos);
				obj_data.put('codexemp',r1.codexemp);
				obj_data.put('qtyexpand',r1.qtyexpand);
--				obj_data.put('flgappr',r1.flgappr);
				obj_data.put('dteeffec',TO_CHAR(v_ttmovemt_dteeffec,'dd/mm/yyyy'));
				obj_data.put('numseq',v_ttmovemt_numseq);
			end loop;
		elsif p_typproba = '2' then --User37 #5251 Final Test Phase 1 V11 01/03/2021 p_typdata = '2' then
			FOR r2 IN c2 LOOP
                obj_data.put('codempid',p_codempid_query);
                if p_typproba = '1' then
                    obj_data.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
                    obj_data.put('typproba',p_typproba);
                    obj_data.put('codcompo','');
                    obj_data.put('codposo','');
                else
                    begin
                    select dteeffec, numseq
                      into v_ttmovemt_dteeffec, v_ttmovemt_numseq
                      from ttmovemt
                     where codempid = p_codempid_query
                       and dteduepr = p_dteduepr
                       and rownum = 1;
                     exception when others then
                        v_ttmovemt_dteeffec := null;
                        v_ttmovemt_numseq   := null;
                     end;

                    obj_data.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
                    obj_data.put('typproba',p_typproba);
                    for r3 in c3 loop
                        obj_data.put('codcompo',r3.codcompt);
                        obj_data.put('codposo',r3.codposnow);
                    end loop;
                end if;
                obj_data.put('codeval',r2.codeval);
                obj_data.put('desc_codeval',get_temploy_name(r2.codeval,global_v_lang));
                obj_data.put('dteempmt',TO_CHAR(r2.dteempmt,'dd/mm/yyyy') );
                obj_data.put('dteduepr',TO_CHAR(r2.dteduepr,'dd/mm/yyyy') );
                obj_data.put('dteeval',TO_CHAR(r2.dteeval,'dd/mm/yyyy') );
                obj_data.put('codrespr',r2.codrespr);
                obj_data.put('dteeffex','');
                obj_data.put('staeval',r2.staeval );
                obj_data.put('flgrepos',r2.flgrepos);
                obj_data.put('codexemp',r2.codexemp);
                obj_data.put('qtyexpand',r2.qtyexpand);
                obj_data.put('flgappr',r2.flgappr);
				obj_data.put('dteeffec',TO_CHAR(v_ttmovemt_dteeffec,'dd/mm/yyyy'));
				obj_data.put('numseq',v_ttmovemt_numseq);
			END LOOP;
		end if;
        obj_data.put('coderror', '200');
      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);
	END gen_detail;

	PROCEDURE get_ttprobatd (json_str_input    IN CLOB,json_str_output   OUT CLOB) AS
	BEGIN
		initial_value(json_str_input);
		IF param_msg_error IS NULL THEN
			gen_ttprobatd(json_str_output);
		ELSE
			json_str_output := get_response_message(400,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
	  param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
	  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_ttprobatd (json_str_output OUT CLOB) IS
		v_rcnt             NUMBER := 0;
        obj_data            json_object_t;
        v_count_numseq      number;
        v_last_dteeval      date;

      cursor c_ttprobatd is
        select *
          from ttprobatd
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
      order by numtime;

	BEGIN
      obj_row   := json_object_t ();

      for r_ttprobatd in c_ttprobatd loop
        obj_data := json_object_t ();

        select count(*), max(dteeval)
          into v_count_numseq, v_last_dteeval
          from tappbath
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
           and numtime = r_ttprobatd.numtime;

        v_rcnt := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('numtime', r_ttprobatd.numtime);
        obj_data.put('avgscor', r_ttprobatd.avgscor);
        obj_data.put('codrespr', r_ttprobatd.codrespr);
        obj_data.put('desc_codrespr',get_tlistval_name('CODRESPR', r_ttprobatd.codrespr, global_v_lang));
        obj_data.put('count_numseq', v_count_numseq);
        obj_data.put('last_dteeval', to_char(v_last_dteeval,'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1), obj_data); -- leave
      end loop;
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
	END gen_ttprobatd;

	PROCEDURE get_detail_popup (json_str_input    IN CLOB,json_str_output   OUT CLOB) AS
	BEGIN
		initial_value(json_str_input);
		IF param_msg_error IS NULL THEN
			gen_detail_popup(json_str_output);
		ELSE
			json_str_output := get_response_message(400,param_msg_error,global_v_lang);
		END IF;
	EXCEPTION WHEN OTHERS THEN
	  param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
	  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE gen_detail_popup (json_str_output OUT CLOB) IS
		v_rcnt              NUMBER := 0;
        obj_data            json_object_t;
        m_codcomp           temploy1.codcomp%type;
        m_codpos            temploy1.codpos%type;
        m_codjob            temploy1.codjob%type;
        m_codempmt          temploy1.codempmt%type;
        m_typemp            temploy1.typemp%type;
        m_date2             temploy1.dtereemp%type;
        m_dteduepr          temploy1.dteduepr%type;
        m_dteempmt          temploy1.dteempmt%type;
        v_aday               number;
	BEGIN
      obj_data := json_object_t();
      IF ( p_typproba = 1 ) THEN
          BEGIN
              SELECT codcomp, codpos, codjob, codempmt,
                     typemp, dtereemp, dteduepr,dteempmt, (dteduepr - DTEEMPMT) +1
                INTO m_codcomp, m_codpos, m_codjob, m_codempmt,
                     m_typemp, m_date2, m_dteduepr, m_dteempmt, v_aday
                FROM temploy1
               WHERE codempid = p_codempid_query;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
              m_date2       := NULL;
          END;
      ELSE
          BEGIN
              SELECT codcomp, codpos, codjob,
                     codempmt, typemp, dteeffec
                INTO m_codcomp, m_codpos, m_codjob,
                     m_codempmt, m_typemp, m_dteduepr
                FROM ttmovemt
               WHERE codempid = p_codempid_query
                 AND dteeffec = p_dteeffec
                 AND numseq = p_numseq;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
          END;

          BEGIN
              SELECT dteempmt, (dteduepr - DTEEMPMT) +1
                INTO m_dteempmt, v_aday
                FROM temploy1
               WHERE codempid = p_codempid_query;
          EXCEPTION WHEN no_data_found THEN
              m_dteempmt     := NULL;
          END;
      END IF;

      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid_query, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(m_codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(m_codpos, global_v_lang));
      obj_data.put('desc_codjob', get_tjobcode_name(m_codjob, global_v_lang));
      obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL', m_codempmt, global_v_lang));
      obj_data.put('desc_typemp', get_tcodec_name('TCODCATG', m_typemp, global_v_lang));
      obj_data.put('dtereemp', TO_CHAR(m_date2, 'dd/mm/yyyy'));
      obj_data.put('dteduepr', TO_CHAR(p_dteduepr, 'dd/mm/yyyy'));
      obj_data.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
      obj_data.put('dteempmt', to_char(m_dteempmt,'dd/mm/yyyy'));
      obj_data.put('day_probation', v_aday);

      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);
	END gen_detail_popup;

  procedure initial_report(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj            := json_object_t(json_str);
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

		p_index_rows := hcm_util.get_json_t(json_obj, 'p_index_rows');
	end initial_report;

	procedure gen_report(json_str_input in clob,json_str_output out clob) is
		json_output clob;
        obj_row     json_object_t;
	begin
		initial_value(json_str_input);
		initial_report(json_str_input);
		isInsertReport  := true;
		numYearReport   := HCM_APPSETTINGS.get_additional_year();

		if param_msg_error is null then
			clear_ttemprpt;
			for i in 0..p_index_rows.get_size-1 loop
                obj_row                 := hcm_util.get_json_t(p_index_rows, to_char(i));
				p_codempid_query        := hcm_util.get_string_t(obj_row, 'codempid');
				p_codempid              := hcm_util.get_string_t(obj_row, 'codempid');
				p_dteduepr              := TO_DATE(hcm_util.get_string_t(obj_row, 'dteduepr'),'dd/mm/yyyy');
                p_typproba              := hcm_util.get_string_t(obj_row, 'typproba');
                v_codcomp               := hcm_util.get_string_t(obj_row, 'codcomp');
                v_codpos                := hcm_util.get_string_t(obj_row, 'codpos');
--				insert_report(json_str_output);
--				table1;
--				table2;
--				table3;
                v_numseq := v_numseq + 1;
                begin
                    INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2 )
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'MAIN', p_codempid_query );
                exception when dup_val_on_index then
                    null; 
                end;
                v_numseq := v_numseq + 1;
                get_detail_report_forms;
                get_detail_report;
                commit;
			end loop;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;

	PROCEDURE insert_report (json_str_output OUT CLOB) IS
		v_rcnt             NUMBER := 0;
		v_rcnt_found       NUMBER := 0;
		v_codrespr         VARCHAR2(100 char);
		v_secur_codempid   BOOLEAN;
		v_p_zupdzap        VARCHAR2(100 char);

    v_imageh           VARCHAR2(1000 char);
    v_folder           tfolderd.folder%type;
    v_has_image        varchar2(1) := 'N';

		cursor c1 is
			select '1' typdata, a.codempid, a.dteduepr, a.codpos, a.codcomp, a.codrespr,
				   a.dteeffex, a.dteoccup, b.dteempmt, a.codform
			  from ttprobat a, temploy1 b
			 where a.codempid = b.codempid
			   and a.codempid = p_codempid_query
			   and a.dteduepr = p_dteduepr
			   and a.typproba = p_typproba
			 union
			select '2' typdata, a.codempid, a.dteduepr, b.codpos, b.codcomp, a.codrespr,
				   null dteeffex, null dteoccup, b.dteempmt, a.codform
			  from ttprobatd a, temploy1 b
			 where a.codempid = b.codempid
			   and a.codempid  = p_codempid_query
			   and a.dteduepr = p_dteduepr
			   and ( (p_typproba = '1' and b.staemp = 1) or (p_typproba = '2' and b.staemp = 3))
			   and not exists (select codempid from ttprobat c
									where c.codempid = a.codempid
									  and c.dteduepr  = a.dteduepr)
		  order by codempid;
	BEGIN
		obj_row := json_object_t ();
		FOR i IN c1 LOOP
            v_rcnt      := v_rcnt + 1;
            v_codform   := i.codform;
            p_codempid  := i.codempid;
            p_codcomp   := i.codcomp;

            begin
                select max(numtime)
                  into max_numtime_37x
                  from tappbath
                 where codempid = p_codempid_query
                   and flgappr = 'C'
                   and dteduepr = p_dteduepr;
            exception when no_data_found then
                max_numtime_37x := 0;
            end;

            begin
                select max(numseq)
                  into max_numseq_37x
                  from tappbath
                 where codempid = p_codempid_query
                   and flgappr = 'C'
                   and dteduepr = p_dteduepr
                   and numtime = max_numtime_37x;
            exception when no_data_found then
                max_numseq_37x := 0;
            end;

            table31;

            begin
              select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||namimage
                into v_imageh
                from tempimge
               where codempid = p_codempid_query
               and namimage is not null;
               v_has_image := 'Y';
            exception when no_data_found then
              v_imageh := '';
              v_has_image := 'N';
            end;
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
            VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                    i.codempid, get_temploy_name(i.codempid,global_v_lang),
                    i.codempid, get_tcenter_name(i.codcomp,global_v_lang),
                    i.codpos||' - '||get_tpostn_name(i.codpos,global_v_lang),
                    get_tlistval_name('NAMTPRO', p_typproba, global_v_lang),
                    hcm_util.get_date_buddhist_era(i.dteempmt),
                    hcm_util.get_date_buddhist_era(i.dteduepr),
                    p_codrespr_report,
                    nvl(to_char(p_qtyexpand),'-'),
                    p_desnote, v_has_image, v_imageh,to_char(p_dteduepr,'dd/mm/yyyy')
                    );
            commit;
            v_numseq := v_numseq + 1;
            table4;
            v_rcnt_found := 1;
		END LOOP;
		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END insert_report;

	procedure clear_ttemprpt is
	begin
		begin
			delete
			  from ttemprpt
			 where codempid = global_v_codempid
			   and codapp = 'HRPM37X';
		exception when others then
			null;
		end;
	end clear_ttemprpt;



  PROCEDURE get_detail_report IS
      json_output         CLOB;
      cursorquestion      SYS_REFCURSOR;
      cursoranswer        SYS_REFCURSOR;
      v_codform           tproasgh.codform%TYPE;
      q_codform           tintvews.codform%TYPE;
      q_numgrup           tintvews.numgrup%TYPE;
      q_desgrup           tintvews.desgrupt%TYPE;
      q_qtyfscor          tintvews.qtyfscor%TYPE;
      v_maxscore          NUMBER;
      v_qtywgt            NUMBER;
      v_qtywgt_tintvewd   NUMBER;
      obj_data            json_object_t;
      obj_row6            json_object_t;
      numanswer           NUMBER := 0;
      v_qtyfscor          tintvewd.qtyfscor%TYPE;
      v_desitem           tintvewd.desitemt%TYPE;
      v_definit           tintvewd.definitt%TYPE;
      v_numitem           tintvewd.numitem%TYPE;
      obj_col6            json_object_t;
      tappbati_numitem    tappbati.numitem%TYPE;
      v_rcnt              NUMBER := 0;
      obj_row5            json_object_t;
      tappbati_qtyscor    tappbati.qtyscor%TYPE;
      tappbati_grdscor    tappbati.grdscor%TYPE;
      h_codempid          VARCHAR(500);
      h_codpos            VARCHAR(500);
      h_tcenter_level     VARCHAR(500);
      h_tcenter_name      VARCHAR(500);
      h_typproba          VARCHAR(500);
      h_dteefpos_normal   VARCHAR(500);
      h_dteduepr_normal   VARCHAR(500);
      h_dteefpos          VARCHAR(500);
      h_dteduepr          VARCHAR(500);
      assessor_codeval    VARCHAR(500);
      assessor_codpos     VARCHAR(500);
      assessor_pos        VARCHAR(500);
      v_commboss          tappbath.commboss%TYPE;
      v_codrespr          tappbath.codrespr%TYPE;
      v_qtyexpand         tappbath.qtyexpand%TYPE;
      v_desnote           tappbath.desnote%TYPE;
      v_pointsum          tintvewd.qtyfscor%TYPE;
      v_imageh            tempimge.namimage%type;
      v_folder            tfolderd.folder%type;
      v_has_image         varchar2(1) := 'N';
      v_staeval           tappbath.staeval%type;
      v_flgrepos            tappbath.flgrepos%type;

      v_max_numtime     number;
      v_max_numseq      number;
      v_codeval         tappbath.codeval%type;

      CURSOR c_questiongroup IS
        SELECT codform, numgrup, qtyfscor,
               decode(global_v_lang,
                     101,desgrupe,
                     102,desgrupt,
                     103,desgrup3,
                     104,desgrup4,
                     105,desgrup5) desgrup
          FROM tintvews
         WHERE codform = v_codform;

      CURSOR c_question IS
        SELECT qtyfscor, desitemt, numitem, qtywgt,
               decode(global_v_lang,
                     101,desiteme,
                     102,desitemt,
                     103,desitem3,
                     104,desitem4,
                     105,desitem5) desitem,
               decode(global_v_lang,
                     101,definite,
                     102,definitt,
                     103,definit3,
                     104,definit4,
                     105,definit5) definit

          FROM tintvewd
         WHERE codform = q_codform
           AND numgrup = q_numgrup
      ORDER BY numgrup, numitem;
  BEGIN
--      v_max_numtime     := hrpm31e.get_max_numtime(p_codempid_query,p_dteduepr);
--      v_max_numseq      := hrpm31e.get_max_numseq(p_codempid_query,p_dteduepr, v_max_numtime);

        begin
            select max(numtime)
              into v_max_numtime
              from tappbath
             where codempid = p_codempid_query
               and flgappr = 'C'
               and dteduepr = p_dteduepr;
        exception when no_data_found then
            v_max_numtime := 0;
        end;

        begin
            select max(numseq)
              into v_max_numseq
              from tappbath
             where codempid = p_codempid_query
               and flgappr = 'C'
               and dteduepr = p_dteduepr
               and numtime = v_max_numtime;
        exception when no_data_found then
            v_max_numseq := 0;
        end;

      v_pointsum := 0;
      BEGIN
          SELECT codform
           INTO v_codform
           FROM tproasgh
          WHERE v_codcomp LIKE codcomp || '%'
            AND v_codpos LIKE codpos
            AND p_codempid_query LIKE codempid
            AND typproba = p_typproba
            AND ROWNUM = 1
       ORDER BY codempid DESC, codcomp DESC;
      EXCEPTION WHEN no_data_found THEN
        v_codform := NULL;
      END;

      BEGIN
          SELECT TO_CHAR(dteefpos, 'dd/mm/yyyy') AS dteefpos,
                 TO_CHAR(dteduepr, 'dd/mm/yyyy') AS dteduepr
            INTO h_dteefpos_normal,
                 h_dteduepr_normal
            FROM temploy1
           WHERE codempid = p_codempid_query;
       EXCEPTION WHEN no_data_found THEN
          h_dteefpos_normal := NULL;
          h_dteduepr_normal := NULL;
      END;

      h_codempid        := p_codempid_query
                            || ' - '
                            || get_temploy_name(p_codempid_query, global_v_lang);
      h_tcenter_level   := hcm_util.get_codcomp_level(v_codcomp, 1);
      h_tcenter_name    := h_tcenter_level
                            || ' - '
                            || get_tcenter_name(h_tcenter_level, global_v_lang);
      h_codpos          := v_codpos
                            || ' - '
                            || get_tpostn_name(v_codpos, global_v_lang);
      h_typproba        := get_tlistval_name('NAMTPRO', p_typproba, global_v_lang);

      BEGIN
          SELECT codeval, codrespr, qtyexpand, desnote,  flgrepos
            INTO v_codeval, v_codrespr, v_qtyexpand, v_desnote, v_flgrepos
            FROM ttprobat
           WHERE codempid = p_codempid_query
             and dteduepr = p_dteduepr;
      EXCEPTION WHEN no_data_found THEN
          v_codrespr    := NULL;
          v_qtyexpand   := NULL;
      END;


      BEGIN
          SELECT nvl(v_codeval,codeval),commboss, 
                 nvl(v_codrespr,codrespr), nvl(v_qtyexpand,qtyexpand), 
                 nvl(v_desnote,desnote), staeval, nvl(v_flgrepos,flgrepos)
            INTO v_codeval, v_commboss, v_codrespr, v_qtyexpand, v_desnote, v_staeval,v_flgrepos
            FROM tappbath
           WHERE codempid = p_codempid_query
             and dteduepr = p_dteduepr
             AND numtime = v_max_numtime
             AND numseq = v_max_numseq;
      EXCEPTION WHEN no_data_found THEN
          v_commboss    := NULL;
          v_codrespr    := NULL;
          v_qtyexpand   := NULL;
      END;

      BEGIN
          SELECT codpos
            INTO assessor_pos
            FROM temploy1
           WHERE codempid = v_codeval;
      EXCEPTION WHEN no_data_found THEN
        assessor_pos := NULL;
      END;

      assessor_codeval := v_codeval
                          || ' - '
                          || get_temploy_name(v_codeval, global_v_lang);
      assessor_codpos := assessor_pos
                         || ' - '
                         || get_tpostn_name(assessor_pos, global_v_lang);

        begin
          select namimage
            into v_imageh
            from tempimge
           where codempid = p_codempid_query;
        exception when no_data_found then
          v_imageh := null;
        end;

        if v_imageh is not null then
          v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
          v_has_image   := 'Y';
        end if;

      if p_typproba ='1' then
        v_flgrepos  := null;
      end if;

     INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2, item5,
                             item6, item7, item8,item9,item10,
                             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,item21)
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'HEAD', p_codempid_query, h_codempid,
                             h_tcenter_name, h_codpos, h_typproba,
                             TO_CHAR(add_months(TO_DATE(h_dteefpos_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             TO_CHAR(add_months(TO_DATE(h_dteduepr_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             assessor_codeval, assessor_codpos, v_max_numtime, v_max_numseq, v_codrespr, v_qtyexpand, v_desnote,
                             v_has_image, v_imageh,v_staeval,v_flgrepos );

      v_numseq := v_numseq + 1;


--      select
-- ITEM2 as codempid,
-- ITEM5 as empName,
-- ITEM6 as company,
-- ITEM7 as posi,
-- ITEM8 as typejob,
-- ITEM9 as dteStart,
-- ITEM10 as dteFinish,
-- ITEM15, ITEM16,
-- ITEM20, ITEM21
--from ttemprpt
--where codempid = $P{p_codempid}
--                and codapp = 'HRPM37X'
--                and ITEM1 = 'FORM2'
--                AND ITEM2 = $P{p_codempid_query}


     INSERT INTO ttemprpt ( codempid, codapp, numseq, 
                             item1, item2, item5,
                             item6, item7, item8,item9,item10,
                             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,item21)
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 
                             'FORM2', p_codempid_query, h_codempid,
                             h_tcenter_name, h_codpos, h_typproba,
                             TO_CHAR(add_months(TO_DATE(h_dteefpos_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             TO_CHAR(add_months(TO_DATE(h_dteduepr_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             assessor_codeval, assessor_codpos, v_max_numtime, v_max_numseq, v_codrespr, v_qtyexpand, v_desnote,
                             v_has_image, v_imageh,v_staeval,v_flgrepos );

      v_numseq := v_numseq + 1;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                             item2, item5, item6 )
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'HEADTABLE',
                             p_codempid_query, v_codform || ' - ' || get_tintview_name(v_codform, global_v_lang), v_commboss );

      v_numseq := v_numseq + 1;
      FOR r1 in c_questiongroup LOOP
        q_codform   := r1.codform;
        q_numgrup   := r1.numgrup;
        q_desgrup  := r1.desgrup;
        q_qtyfscor  := r1.qtyfscor;
        INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2, item5,
                             item6, item7, item8, item9, item10, item11 )
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE', p_codempid_query, q_numgrup,
                             '', q_desgrup, '', '', '', '' );

        v_numseq := v_numseq + 1;
        numanswer := 0;

        FOR r2 in c_question LOOP
            v_qtyfscor  := r2.qtyfscor;
            v_desitem   := r2.desitem;
            v_definit   := r2.definit;
            v_numitem   := r2.numitem;
            v_qtywgt    := r2.qtywgt;

            BEGIN
                SELECT numitem, qtyscor, grdscor
                  INTO tappbati_numitem, tappbati_qtyscor, tappbati_grdscor
                  FROM tappbati
                 WHERE codempid = p_codempid_query
                   and dteduepr = p_dteduepr
                   AND numgrup = q_numgrup
                   AND numtime = v_max_numtime
                   AND numseq = v_max_numseq
                   AND numitem = v_numitem;
            EXCEPTION WHEN no_data_found THEN
                tappbati_numitem := 0;
                tappbati_qtyscor := 0;
                tappbati_grdscor := '';
            END;

            INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                   item5, item6, item7, item8, item9,
                                   item10, item11 )
                          VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE', p_codempid_query,
                                   '', v_numitem, v_desitem, v_definit, v_qtywgt,
                                   tappbati_grdscor, tappbati_qtyscor );

            v_pointsum  := v_pointsum + tappbati_qtyscor;
            v_numseq    := v_numseq + 1;
            numanswer   := numanswer + 1;
        END LOOP;
      END LOOP;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                             item5, item6, item7, item8, item9,
                             item10, item11 )
                    VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE', p_codempid_query,
                             '', '', get_label_name('HRPM37X3', global_v_lang, 180), '', '',
                             '', v_pointsum );
      v_numseq := v_numseq + 1;
  END get_detail_report;

  PROCEDURE get_detail_report_forms IS
      json_output         CLOB;
      cursorquestion      SYS_REFCURSOR;
      cursoranswer        SYS_REFCURSOR;
      v_codform           tproasgh.codform%TYPE;
      q_codform           tintvews.codform%TYPE;
      q_numgrup           tintvews.numgrup%TYPE;
      q_desgrupt          tintvews.desgrupt%TYPE;
      q_qtyfscor          tintvews.qtyfscor%TYPE;
      v_maxscore          NUMBER;
      v_qtywgt            NUMBER;
      obj_data            json_object_t;
      obj_row6            json_object_t;
      numanswer           NUMBER := 0;
      v_qtyfscor          tintvewd.qtyfscor%TYPE;
      v_desitemt          tintvewd.desitemt%TYPE;
      v_numitem           tintvewd.numitem%TYPE;
      obj_col6            json_object_t;
      tappbati_numitem    tappbati.numitem%TYPE;
      v_rcnt              NUMBER := 0;
      obj_row5            json_object_t;
      tappbati_qtyscor    tappbati.qtyscor%TYPE;
--      h_codempid          VARCHAR(500);
--      h_codpos            VARCHAR(500);
--      h_tcenter_level     VARCHAR(500);
--      h_tcenter_name      VARCHAR(500);
--      h_typproba          VARCHAR(500);
--      h_dteefpos_normal   VARCHAR(500);
--      h_dteduepr_normal   VARCHAR(500);
--      h_dteefpos          VARCHAR(500);
--      h_dteduepr          VARCHAR(500);
      assessor_codeval    VARCHAR(500);
      assessor_codpos     VARCHAR(500);
      assessor_pos        VARCHAR(500);
      flgdata_t301        boolean := false;
      flgdata_t302        boolean := false;
      flgdata_t303        boolean := false;
      v_qtyavgwk                NUMBER;
      o_day                     NUMBER;
      o_hr                      NUMBER;
      o_min                     NUMBER;
      o_dhm                     VARCHAR(15 CHAR);
      v_aday                    NUMBER;

      v_dtestrt         date;
      v_dteend          date;
      CURSOR t301 IS
          SELECT SUM(qtyday) numleave, typleave
            FROM tleavetr
           WHERE codempid = p_codempid_query
             AND dtework BETWEEN nvl(v_dtestrt,dtework) AND nvl(v_dteend,dtework)
        GROUP BY typleave
        ORDER BY typleave;

      CURSOR t302 IS
          SELECT 1 numseq,get_label_name('HRPM31E', global_v_lang, 10) typcolumn,
                 SUM(daylate) qtyday,
                 SUM(qtytlate) qty_sum
            FROM tlateabs
           WHERE codempid = p_codempid_query
             AND dtework BETWEEN nvl(v_dtestrt,dtework) AND nvl(v_dteend,dtework)
           UNION
          SELECT 2 numseq,get_label_name('HRPM31E', global_v_lang, 20),
                 SUM(dayearly) qtyday,
                 SUM(qtytearly) qty_sum
            FROM tlateabs
           WHERE codempid = p_codempid_query
             AND dtework BETWEEN nvl(v_dtestrt,dtework) AND nvl(v_dteend,dtework)
           UNION
          SELECT 3 numseq,get_label_name('HRPM31E', global_v_lang, 30),
                 SUM(dayabsent) qtyday,
                 SUM(qtytabs) qty_sum
            FROM tlateabs
           WHERE codempid = p_codempid_query
             AND dtework BETWEEN nvl(v_dtestrt,dtework) AND nvl(v_dteend,dtework);

      CURSOR t303 IS
          SELECT TO_CHAR(a.dteeffec, 'dd/mm/yyyy') AS dteeffec,
                 a.codmist,
                 a.desmist1,
                 b.numseq,
                 b.codpunsh,
                 b.typpun,
                 TO_CHAR(b.dtestart, 'dd/mm/yyyy') AS dtestart,
                 TO_CHAR(b.dteend, 'dd/mm/yyyy') AS dteend,
                 b.codempid
            FROM ttmistk   a,
                 ttpunsh   b
           WHERE a.codempid = p_codempid_query
             AND a.codempid = b.codempid
             AND a.dteeffec = b.dteeffec
             AND a.staupd IN ( 'C', 'U' )
             AND a.dteeffec BETWEEN nvl(v_dtestrt, a.dteeffec) AND nvl(v_dteend, a.dteeffec)
        ORDER BY a.dteeffec,
                 b.codpunsh,
                 b.numseq;

  BEGIN
    if p_typproba = 1 then
        select dteempmt
          into v_dtestrt
          from temploy1
         where codempid = p_codempid_query;
    else
        BEGIN
            select dteeffec
              into v_dtestrt
              from ttprobat
             where codempid = p_codempid_query;
        EXCEPTION WHEN no_data_found THEN
            select dteeffec
              into v_dtestrt
              from ttmovemt
             where codempid = p_codempid_query
             and dteduepr = p_dteduepr
             and rownum = 1;
        END;
    end if;
    v_dteend := p_dteduepr;

      FOR r2 IN t301 LOOP
          flgdata_t301 := true;
          v_qtyavgwk := hrpm31e.func_get_qtyavgwk (v_codcomp);
          hcm_util.cal_dhm_hm(r2.numleave, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                 item2, item5, item6, item7 )
                        VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE1',
                                 p_codempid_query,r2.typleave, get_tleavety_name(r2.typleave, global_v_lang), o_dhm );
          v_numseq := v_numseq + 1;
      END LOOP;

      IF NOT flgdata_t301 THEN
          FOR i IN 1..2 LOOP
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                     item2, item5, item6, item7 )
                            VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE1',
                                     p_codempid_query, '', '', '' );
              v_numseq := v_numseq + 1;
          END LOOP;
      END IF;

      FOR i IN t302 LOOP
          flgdata_t302 := true;
          v_qtyavgwk    := hrpm31e.func_get_qtyavgwk (v_codcomp);
          hcm_util.cal_dhm_hm(i.qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                 item2, item5, item6, item7 )
                        VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE2',
                                 p_codempid_query, i.typcolumn, i.qty_sum, o_dhm );

          v_numseq := v_numseq + 1;
      END LOOP;

      FOR r4 IN t303 LOOP
          flgdata_t303 := true;
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                 item5,
                                 item6, item7, item8,
                                 item9,
                                 item10,
                                 item11,
                                 item12 )
                        VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE3', p_codempid_query,
                                 TO_CHAR(add_months(TO_DATE(r4.dteeffec, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                                 get_tcodec_name('tcodmist', r4.codmist, global_v_lang), r4.desmist1, r4.numseq,
                                 r4.codpunsh || ' - ' || get_tcodec_name('TCODPUNH', r4.codpunsh, global_v_lang),
                                 get_tlistval_name('NAMTPUN', r4.typpun, global_v_lang),
                                 TO_CHAR(add_months(TO_DATE(r4.dtestart, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                                 TO_CHAR(add_months(TO_DATE(r4.dteend, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy') );
          v_numseq := v_numseq + 1;
      END LOOP;
      IF NOT flgdata_t303 THEN
          FOR i IN 1..2 LOOP
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                     item5, item6, item7, item8, item9, item10, item11, item12 )
                            VALUES ( global_v_codempid, 'HRPM37X', v_numseq, 'TABLE3', p_codempid_query,
                                     '', '', '', '', '', '', '', '' );
              v_numseq := v_numseq + 1;
          END LOOP;
      END IF;
  END get_detail_report_forms;    


	procedure table1 is
		o_day           number;
		o_hr            number;
		o_min           number;
		o_dhm           varchar(15 char);
		v_qtyavgwk      number;
        v_count         number;
        CURSOR t301 IS
            select sum(qtyday) qtyday, typleave
              from tleavetr
             where codempid = p_codempid_query
          group by typleave
          order by typleave;
	begin
        v_count := 0;
		FOR r2 IN t301 LOOP
            v_count := v_count +1;
			begin
				select qtyavgwk
                  into v_qtyavgwk
				  from tcontral
				 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
				   and dteeffec = (select max(dteeffec)
								     from tcontral
								    where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
								      and dteeffec <= trunc(sysdate));
			exception when no_data_found then
				v_qtyavgwk := null;
			end;
            hcm_util.cal_dhm_hm (r2.qtyday,0,0,v_qtyavgwk,'1',o_day,o_hr,o_min,o_dhm);

            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item14)
            VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                    p_codempid, 'TABLE1_DETAIL',
                    r2.typleave,
                    get_tleavety_name(r2.typleave, global_v_lang), o_dhm,to_char(p_dteduepr,'dd/mm/yyyy'));
            commit;
            v_numseq := v_numseq + 1;
		END LOOP;
        if v_count = 0 then
            for i in 1..2 loop
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item14)
                VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                        p_codempid, 'TABLE1_DETAIL',
                        '',
                        '', '',to_char(p_dteduepr,'dd/mm/yyyy'));
                commit;
                v_numseq := v_numseq + 1;
            end loop;
        end if;
	end table1;

	procedure table2 is
		o_day                     number;
		o_hr                      number;
		o_min                     number;
		o_dhm                     varchar(15 char);
		v_qtyavgwk                number;
	CURSOR t302 IS
		select get_label_name('HRPM31E', global_v_lang, 10) as typcolumn,
               sum(daylate) as qtyday,
               sum(qtytlate) as qty_sum
		  from tlateabs
		 WHERE codempid = p_codempid_query
         group by codempid
         UNION
		select get_label_name('HRPM31E', global_v_lang, 20) as typcolumn,
               sum(dayearly) as qtyday,
               sum(qtytearly) as qty_sum
		  from tlateabs
		 WHERE codempid = p_codempid_query
		 UNION
		select get_label_name('HRPM31E', global_v_lang, 30) as typcolumn ,
               sum(dayabsent) as qtyday,
               sum(qtytabs) as qty_sum
		  from tlateabs
		 WHERE codempid = p_codempid_query
        ;
	begin
		FOR i IN t302 LOOP
            begin
                select qtyavgwk
                  into v_qtyavgwk
                  from tcontral
                 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                   and dteeffec = (select max(dteeffec)
                                     from tcontral
                                    where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                      and dteeffec <= trunc(sysdate));
            exception when no_data_found then
                v_qtyavgwk := null;
            end;

			hcm_util.cal_dhm_hm (i.qtyday,0,0,v_qtyavgwk,'1',o_day,o_hr,o_min,o_dhm);

			insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item14)
					VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                            p_codempid, 'TABLE2_DETAIL',
                            i.typcolumn, i.qty_sum, o_dhm,to_char(p_dteduepr,'dd/mm/yyyy'));
			commit;
			v_numseq := v_numseq + 1;
		end loop;
	end table2;

	procedure table3 is
        v_count number;
        v_dtestart  varchar2(100);
        v_dteend  varchar2(100);
        CURSOR t303 IS
            SELECT a.dteeffec, a.codmist, a.desmist1, b.numseq, b.codpunsh,
                   b.typpun, b.dtestart, b.dteend, b.codempid
              FROM ttmistk a,
                   ttpunsh b
             WHERE a.codempid = p_codempid_query
               AND a.codempid = b.codempid
               AND a.dteeffec = b.dteeffec
               AND a.staupd IN ( 'C', 'U' )
          ORDER BY a.dteeffec, b.codpunsh, b.numseq;
	begin
        v_count := 0;
		FOR i IN t303 LOOP
            v_count := v_count + 1;
            if i.dtestart is not null then
                v_dtestart := hcm_util.get_date_buddhist_era(i.dtestart);
            else
                v_dtestart := '';
            end if;

            if i.dteend is not null then
                v_dteend := hcm_util.get_date_buddhist_era(i.dteend);
            else
                v_dteend := '';
            end if;

			insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item14)
            VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                    p_codempid, 'TABLE3_DETAIL',
                    hcm_util.get_date_buddhist_era(i.dteeffec),
                    get_tcodec_name('TCODMIST', i.codmist, global_v_lang), i.desmist1, i.numseq, i.codpunsh,
                    get_tcodec_name('TCODPUNH',i.codpunsh,global_v_lang),
                    get_tlistval_name('NAMTPUN',i.typpun,global_v_lang),
                    v_dtestart,
                    v_dteend,to_char(p_dteduepr,'dd/mm/yyyy'));
			commit;
			v_numseq := v_numseq + 1;
		end loop;

        if v_count = 0 then
            for i in 1..2 loop
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item14)
                VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                        p_codempid, 'TABLE3_DETAIL',
                        '',
                        '', '', '', '',
                        '',
                        '',
                        '',
                        '',to_char(p_dteduepr,'dd/mm/yyyy'));
                commit;
                v_numseq := v_numseq + 1;
            end loop;
        end if;

	end table3;

	procedure table31 is
        CURSOR t31 IS
            SELECT a.qtyexpand, a.codrespr, a.commboss, a.codeval, b.codpos
              FROM tappbath a
         left join ttprobat b on a.codempid = b.codempid
             WHERE a.codempid = p_codempid_query
               AND a.numseq = max_numseq_37x
               AND a.numtime = max_numtime_37x;
	begin
		FOR i IN t31 LOOP
		  p_qtyexpand       := i.qtyexpand;
		  p_codrespr_report := i.codrespr;
		  p_desnote         := i.commboss;
		end loop;
	end table31;

	procedure table4 is
        cursor t4 is
            select a.qtyexpand, a.codrespr, a.commboss, a.codeval,
                   nvl(a.codposeval,c.codpos) codpos ,
                   a.numseq, a.numtime, a.codform
              from tappbath a
         left join ttprobat b
                on a.codempid = b.codempid and a.dteduepr = b.dteduepr
         left join temploy1 c
                on a.codeval = c.codempid
             where a.codempid = p_codempid_query
               and a.flgappr = 'C'
               and a.dteduepr = p_dteduepr
          order by a.numtime, a.numseq;
	begin
		FOR i IN t4 LOOP
		  p_qtyexpand           := nvl(to_char(i.qtyexpand),'-');
		  p_codrespr_report     := i.codrespr;
		  p_desnote             := i.commboss;
		  p_codeval_name        := get_temploy_name(i.codeval,global_v_lang);
		  p_codeval             := i.codeval;
		  p_codeval_position    := i.codpos||' - '||get_tpostn_name(i.codpos,global_v_lang);
		  v_numseq_report       := i.numseq;
		  v_numtime             := i.numtime;

		  insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item14)
		  values (global_v_codempid, 'HRPM37X',v_numseq,
                  p_codempid, 'TABLE4_DETAIL',
                  v_numtime, v_numseq_report,
                  p_codeval, p_codeval_name,
                  p_codeval_position,
                  v_codform, get_tintview_name(v_codform,  global_v_lang),
                  p_codrespr_report, p_qtyexpand, p_desnote,to_char(p_dteduepr,'dd/mm/yyyy') );
		  commit;
		  v_numseq := v_numseq + 1;
		  table41;
		end loop;
	end table4;

	procedure table41 is
        v_sum_qtyscor number;
        cursor t41 is
            select a.numgrup, sum(a.qtyscor) qtyscor
              from tappbati a
             where a.codempid = p_codempid_query
               and a.dteduepr = p_dteduepr
               and a.numseq = v_numseq_report
               and a.numtime = v_numtime
          group by a.numgrup
          order by a.numgrup;
	begin
        v_sum_qtyscor := 0;
		FOR i IN t41 LOOP
		  v_numgrup := i.numgrup;
		  table5;
		  table51;
          v_sum_qtyscor := v_sum_qtyscor + i.qtyscor;
		end loop;

        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,item14)
        VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                p_codempid, 'TABLE4_DETAIL_SUB',
                v_numtime, v_numseq_report,
                '', '', get_label_name('HRPM37X3', global_v_lang, 180),
                '', '', '', v_sum_qtyscor,to_char(p_dteduepr,'dd/mm/yyyy'));
        commit;
        v_numseq := v_numseq + 1;
	end table41;

	procedure table5 is
        CURSOR t5 IS
            SELECT codform, numgrup, desgrupt, qtyfscor
              FROM tintvews
             WHERE codform = v_codform
               AND numgrup = v_numgrup;
	begin
		FOR i IN t5 LOOP
			INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,item14)
            VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                    p_codempid, 'TABLE4_DETAIL_SUB',
                    v_numtime, v_numseq_report,
                    i.numgrup, '', i.desgrupt,
                    '', '', '', '',to_char(p_dteduepr,'dd/mm/yyyy'));
            commit;
			v_numseq := v_numseq + 1;
		end loop;
	end table5;

	procedure table51 is
        CURSOR t51 IS
            select a.desitemt, a.definitt, a.qtywgt,
                   a.numitem, b.grdscor, b.qtyscor
              from tintvewd a
         left join tappbati b
                on b.numitem = a.numitem and b.numgrup=v_numgrup
             where a.codform = v_codform
                and a.numgrup = v_numgrup
                and b.numtime = v_numtime
                and b.numseq = v_numseq_report
                and b.codempid = p_codempid_query
                and b.dteduepr = p_dteduepr
           order by a.numgrup, a.numitem;
	begin
		FOR i IN t51 LOOP
			INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,item14)
            VALUES (global_v_codempid, 'HRPM37X',v_numseq,
                    p_codempid, 'TABLE4_DETAIL_SUB',
                    v_numtime, v_numseq_report,
                    '', i.numitem, i.desitemt,
                    i.definitt, i.qtywgt, i.grdscor, i.qtyscor,to_char(p_dteduepr,'dd/mm/yyyy'));
            commit;
            v_numseq := v_numseq + 1;
		end loop;
	end table51;
END HRPM37X;

/
