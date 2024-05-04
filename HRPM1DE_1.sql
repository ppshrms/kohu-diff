--------------------------------------------------------
--  DDL for Package Body HRPM1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM1DE" is

  PROCEDURE initial_value ( json_str		IN CLOB ) IS
		json_obj		json_object_t := json_object_t(json_str);
	BEGIN
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
		p_codasset          := hcm_util.get_string_t(json_obj,'p_codasset');
		p_dtercass          := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtercass') ),'dd/mm/yyyy');
		p_dtertass          := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtertass') ),'dd/mm/yyyy');

		p_dtestr            := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtestr') ),'dd/mm/yyyy');
		p_dteend            := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteend') ),'dd/mm/yyyy');

		p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
		p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	END initial_value;

	PROCEDURE check_index IS
	BEGIN
		IF p_codcomp IS NULL AND p_codempid IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
			return;
		END IF;

		IF p_codcomp IS NOT NULL AND p_codempid IS NOT NULL THEN
			p_codcomp := '';
		END IF;
		IF p_codcomp IS NOT NULL AND p_codempid IS NULL THEN
			IF p_stacaselw IS NULL OR p_dtestr IS NULL OR p_dteend IS NULL THEN
				param_msg_error := get_error_msg_php('HR2045',global_v_lang);
				return;
			END IF;
		END IF;   
	END check_index;

	PROCEDURE check_getindex IS

		v_codempid		    VARCHAR2(100 char);
		v_codcomp_empid		VARCHAR2(100 char);
		v_numlvl		      VARCHAR2(100 char);
		v_staemp		      VARCHAR2(1 char);
		v_flgasset		    VARCHAR2(1 char);
		v_secur_codempid	BOOLEAN;
    chk_repeatedly number;
	BEGIN
    IF trunc(p_dtercass) >= trunc(SYSDATE) + 1 THEN
			param_msg_error := get_error_msg_php('PM0012',global_v_lang);
			return;
		END IF;
		IF p_codempid IS NULL THEN
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		END IF;
		IF p_dtestr IS NOT NULL THEN
			IF p_dteend IS NULL THEN
				param_msg_error := get_error_msg_php('HR2041',global_v_lang);
				return;
			END IF;

		END IF;
		IF p_dteend IS NOT NULL THEN
			IF p_dtestr IS NULL THEN
				param_msg_error := get_error_msg_php('HR2041',global_v_lang);
				return;
			END IF;
		END IF;

		IF p_dtestr > p_dteend THEN
			param_msg_error := get_error_msg_php('HR2021',global_v_lang);
			return;
		END IF;
		IF p_codempid IS NOT NULL THEN
			BEGIN
				SELECT
				codempid,
				staemp,
				codcomp,
				numlvl
				INTO
				v_codempid,
				v_staemp,
				v_codcomp_empid,
				v_numlvl
				FROM
				temploy1
				WHERE
				codempid = p_codempid;

			EXCEPTION
			WHEN no_data_found THEN
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
				return;
			END;
			IF v_codcomp_empid IS NOT NULL AND v_numlvl IS NOT NULL THEN
				v_secur_codempid := secur_main.secur1(v_codcomp_empid,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

				IF v_secur_codempid = false THEN
					param_msg_error := get_error_msg_php('HR3007',global_v_lang,v_codcomp_empid);
					return;
				END IF;
			END IF;

			IF v_staemp = 0 THEN
				param_msg_error := get_error_msg_php('HR2102',global_v_lang);
				return;
			END IF;
			--<<User37 08/01/2021 #69 Final Test Phase 1 V11
            /*IF v_staemp = 9 THEN
				param_msg_error := get_error_msg_php('HR2101',global_v_lang);
				return;
			END IF;*/
            -->>User37 08/01/2021 #69 Final Test Phase 1 V11
		END IF;
	END;
  PROCEDURE check_asetinf IS
		v_flgasset		    VARCHAR2(1 char);
	BEGIN
    begin
        select flgasset
          into v_flgasset
          from tasetinf
         where codasset = p_codasset;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TASETINF');
      return;
    end;
    if v_flgasset <> 1 then
      param_msg_error := get_error_msg_php('PM0131',global_v_lang,'TASETINF');
      return;
    end if;
	END;
	PROCEDURE gen_data (json_str_output OUT CLOB) IS
		v_rcnt			NUMBER := 0;
    v_image     TASETINF.NAMIMAGE%type;
		CURSOR c_tassests IS
      select a.codasset,get_tasetinf_name(a.codasset,global_v_lang) AS desc_codasset,remark,dtercass
        from tassets a, tasetinf b
       where a.codasset  = b.codasset
         and a.codempid = p_codempid
         and a.dtercass BETWEEN nvl(p_dtestr,dtercass) AND nvl(p_dteend,dtercass)
         and b.flgasset  = 1
       order by  a.dtercass, a.codasset;
	BEGIN
		obj_row			:= json_object_t ();
		FOR i IN c_tassests LOOP
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codasset',i.codasset);
			obj_data.put('desc_codasset',i.desc_codasset);
			obj_data.put('remark',i.remark);
			obj_data.put('dtercass',TO_CHAR(i.dtercass,'dd/mm/yyyy') );
      begin
        select NAMIMAGE into v_image from TASETINF where codasset = i.codasset;
      exception when no_data_found then
        v_image := '';
      end;
			obj_data.put('image',v_image );
			obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
		END LOOP;
		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN no_data_found THEN
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexe');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_data;

	PROCEDURE gen_data_detail (json_str_output OUT CLOB) IS
		v_rcnt			NUMBER := 0;
		chk_repeatedly			NUMBER := 0;
		v_typasset		tasetinf.typasset%TYPE;
		CURSOR c_tassests IS
      SELECT codasset,get_tasetinf_name(codasset,global_v_lang) AS desc_codasset,
             remark,dtercass,dtertass,get_codempid(coduser) AS coduser,dteupd
       FROM tassets
      WHERE codempid = p_codempid
        AND codasset = p_codasset
        AND dtercass = p_dtercass
--        AND dtercass BETWEEN nvl(p_dtestr,dtercass) AND nvl(p_dteend,dtercass)
   ORDER BY dtercass, codasset;
	BEGIN
		obj_row			:= json_object_t ();
--    begin
--      select count(*)
--        into chk_repeatedly
--        from tassets
--       where (codempid <> p_codempid or codempid = p_codempid)
--         and codasset <> p_codasset
--         and dtertass is null;
--    end;
--    if(chk_repeatedly > 0) then
--      param_msg_error := Get_error_msg_php('PM0105', global_v_lang);
--      json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
--      RETURN;
--    end if;
		FOR i IN c_tassests LOOP

			SELECT typasset INTO v_typasset
			  FROM tasetinf
			 WHERE codasset = i.codasset;

			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codasset',i.codasset);
			obj_data.put('desc_codasset',i.desc_codasset);
			obj_data.put('remark',i.remark);
			obj_data.put('typasset',v_typasset);
      obj_data.put('typasset_name',Get_tcodec_name('TCODASST', v_typasset, global_v_lang));
			obj_data.put('coduser',i.coduser);
			obj_data.put('dtercass',TO_CHAR(i.dtercass,'dd/mm/yyyy') );
			obj_data.put('dtertass',TO_CHAR(i.dtertass,'dd/mm/yyyy') );
			obj_data.put('dterupd',TO_CHAR(i.dteupd,'dd/mm/yyyy') );
			obj_data.put('flag','edit' );
			obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
		END LOOP;

		IF v_rcnt = 0 AND p_codasset IS NOT NULL THEN
			BEGIN
				SELECT typasset
				  INTO v_typasset
				  FROM tasetinf
				 WHERE codasset = p_codasset;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('typasset',v_typasset);
        obj_data.put('typasset_name',Get_tcodec_name('TCODASST', v_typasset, global_v_lang));
        obj_data.put('dtercass',TO_CHAR(p_dtercass,'dd/mm/yyyy'));
        obj_data.put('codasset',p_codasset);
        obj_data.put('flag','add' );
				obj_row.put('0',obj_data);
      EXCEPTION WHEN OTHERS THEN
				param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
				json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END;
		END IF;
		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_data_detail;

	PROCEDURE get_assetinf_detail ( json_str_output OUT CLOB ) IS

		v_rcnt			NUMBER := 0;
		CURSOR c_tasetinf IS
      SELECT codasset,
      CASE
        WHEN global_v_lang = 101 THEN desassee
        WHEN global_v_lang = 102 THEN desasset
        WHEN global_v_lang = 103 THEN desasse3
        WHEN global_v_lang = 104 THEN desasse4
        WHEN global_v_lang = 105 THEN desasse5
      ELSE desassee
      END desasse, desnote, dterec, srcasset, namimage, comimage, typasset
      FROM tasetinf
      WHERE codasset = p_codasset;
	BEGIN
		obj_row			:= json_object_t ();
		FOR i IN c_tasetinf LOOP
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('desasse',i.desasse);
			obj_data.put('desnote',i.desnote);
			obj_data.put('srcasset',i.srcasset);
			obj_data.put('namimage',i.namimage);
			obj_data.put('comimage',i.comimage);
			obj_data.put('typasset',i.typasset);
			obj_data.put('codasset',i.codasset);
      obj_data.put('typasset_name',Get_tcodec_name('TCODASST', i.typasset, global_v_lang));
			obj_data.put('dterec',TO_CHAR(i.dterec,'dd/mm/yyyy') );
			obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
		END LOOP;

		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN no_data_found THEN
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexe');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END get_assetinf_detail;

	PROCEDURE get_assets_detail ( json_str_output OUT CLOB ) IS

		v_rcnt			NUMBER := 0;
		CURSOR c_tassets IS 
      SELECT a.dtercass, a.codasset, b.codempid, b.codcomp,
        CASE
          WHEN global_v_lang = 101 THEN c.namcente
          WHEN global_v_lang = 102 THEN c.namcentt
          WHEN global_v_lang = 103 THEN c.namcent3
          WHEN global_v_lang = 104 THEN c.namcent4
          WHEN global_v_lang = 105 THEN c.namcent5
          ELSE c.namcente
        END namcent
      FROM tassets a, temploy1 b, tcenter c
     WHERE a.codempid = b.codempid
       AND a.codasset = p_codasset
       AND b.codcomp = c.codcomp
		 ORDER BY a.dtercass, a.codasset;
	BEGIN
		obj_row			:= json_object_t ();
		FOR i IN c_tassets LOOP
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codasset',i.codasset);
			obj_data.put('dtercass',TO_CHAR(i.dtercass,'dd/mm/yyyy') );
			obj_data.put('codempid',i.codempid);
			obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
			obj_data.put('desc_codcomp',get_codcompy(i.codcomp) );
			obj_data.put('codcomp',i.codcomp);
			obj_data.put('namcent',i.namcent);
			obj_row.put(TO_CHAR(v_rcnt - 1),obj_data);
		END LOOP;

		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN no_data_found THEN
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlegalexe');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END get_assets_detail;

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
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

	PROCEDURE get_index_detail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
		check_asetinf;
		IF param_msg_error IS NULL THEN
			gen_data_detail(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;

	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE get_assetinf_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
		check_getindex;
		IF param_msg_error IS NULL THEN
			get_assetinf_detail(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;

	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE get_assets_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
	BEGIN
		initial_value(json_str_input);
		IF param_msg_error IS NULL THEN
			get_assets_detail(json_str_output);
		ELSE
			json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
		END IF;

	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;
  PROCEDURE check_save IS
    v_count			    NUMBER;
    chk_repeatedly  number;
    v_staemp        varchar2(1);
    v_flgasset      varchar(2 char);
	BEGIN
    IF (p_codasset IS NULL) or (p_dtercass IS NULL) THEN
        param_msg_error := Get_error_msg_php('HR2045', global_v_lang);
        RETURN;
    END IF;
    IF (trunc(p_dtercass) >= trunc(SYSDATE) + 1) THEN
        param_msg_error := Get_error_msg_php('PM0012', global_v_lang);
        RETURN;
    END IF;
    --<<User37 08/01/2021 #69 Final Test Phase 1 V11
    IF (p_flg = 'add') THEN
      begin
          select staemp
            into v_staemp
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
        v_staemp := null;
      end;
      IF v_staemp = 9 THEN
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      END IF;
      begin
        select count(*)
          into chk_repeatedly
          from tassets
         where (codempid <> p_codempid or codempid = p_codempid)
           and codasset = p_codasset
           and dtertass is null;
      end;
      if(chk_repeatedly > 0) then
        param_msg_error := Get_error_msg_php('PM0105', global_v_lang);
        RETURN;
      end if;
    end if;
    -->>User37 08/01/2021 #69 Final Test Phase 1 V11
    --
    begin
        select flgasset
          into v_flgasset
          from tasetinf
         where codasset = p_codasset;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TASETINF');
      return;
    end;
    if v_flgasset <> 1 then
      param_msg_error := get_error_msg_php('PM0131',global_v_lang,'TASETINF');
      return;
    end if;
    if(p_dtertass is not null) then
      if p_dtertass < p_dtercass then
        param_msg_error := Get_error_msg_php('PM0028', global_v_lang);
        RETURN;
      end if;
    end if;
	END;
	PROCEDURE save_data ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		v_count			    NUMBER;
    chk_repeatedly  number;
    v_staemp        varchar2(1);
    v_flgasset      varchar(2 char);
	BEGIN
    initial_value(json_str_input);
        --validate ????????
    check_save;
    if param_msg_error is not null then
      json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
      RETURN;
    end if;
    IF (p_flg = 'add') THEN
      INSERT INTO tassets (codasset,codempid,dtercass,dtertass,remark,coduser,codcreate)
           VALUES (p_codasset,p_codempid,p_dtercass,p_dtertass,p_remark,global_v_coduser,global_v_coduser);
      UPDATE tasetinf
         SET staasset = 2
       WHERE codasset = p_codasset;
    ELSE -- edit
      UPDATE tassets
      SET remark = p_remark,
        dtertass = p_dtertass,
          dteupd = SYSDATE,
         coduser = global_v_coduser
      WHERE codasset = p_codasset
        AND dtercass = p_dtercass
        AND codempid = p_codempid;

      IF p_dtertass IS NOT NULL THEN
        UPDATE tasetinf
        SET staasset = 1
        WHERE codasset = p_codasset;
      ELSE
        UPDATE tasetinf
           SET staasset = 2
         WHERE codasset = p_codasset;
      END IF;

    END IF;
		param_msg_error := Get_error_msg_php('HR2401', global_v_lang);
    json_str_output := Get_response_message('200', param_msg_error,global_v_lang);
    return ;

        /*
		BEGIN
			SELECT
			COUNT(*)
			INTO v_count
			FROM
			tasetinf
			WHERE
			codasset = p_codasset;

		END;
		IF v_count = 0 THEN
        param_msg_error := Get_error_msg_php('HR2010', global_v_lang);
        json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
        RETURN;
		END IF;
        */

        /*
        BEGIN
			SELECT
			COUNT(*)
			INTO v_count
			FROM
			tassets
			WHERE
			codasset = p_codasset
            and dtertass is null;

		END;
		IF v_count > 0 THEN
        param_msg_error := Get_error_msg_php('PM0105', global_v_lang);
            json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
            RETURN;
		END IF;
        */
        /*
		IF p_dtertass IS NOT NULL THEN
			IF p_dtertass < p_dtercass THEN
            param_msg_error := Get_error_msg_php('PM0028', global_v_lang);
            json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
            RETURN;
            END IF;
		END IF;

		IF p_flg = 'edit' THEN
			IF p_dtertass IS NULL THEN
				param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dtertass');
				return;
			END IF;
		END IF;


 */

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

	PROCEDURE delete_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		param_json		json_object_t;
		param_json_row		json_object_t;
	BEGIN
		initial_value(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str') );
		param_msg_error := NULL;
		IF param_msg_error IS NULL THEN
			FOR i IN 0..param_json.get_size - 1 LOOP
				param_json_row := hcm_util.get_json_t(param_json,TO_CHAR(i));
				p_codempid := hcm_util.get_string_t(param_json_row,'codempid');
				p_codasset := hcm_util.get_string_t(param_json_row,'codasset');
				p_dtercass := TO_DATE(trim(hcm_util.get_string_t(param_json_row,'dtercass') ),'dd/mm/yyyy');

        begin
          DELETE FROM tassets
          WHERE codempid = p_codempid
          AND codasset = p_codasset
          AND dtercass = p_dtercass;
        end;
        begin
          UPDATE tasetinf
          SET staasset = 1
          WHERE codasset = p_codasset;
        end;
			END LOOP;

			IF param_msg_error IS NULL THEN
				param_msg_error := get_error_msg_php('HR2425',global_v_lang);
				COMMIT;
			ELSE
				ROLLBACK;
			END IF;
			COMMIT;
		END IF;

		json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;

END HRPM1DE;

/
