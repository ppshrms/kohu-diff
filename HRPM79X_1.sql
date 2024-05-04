--------------------------------------------------------
--  DDL for Package Body HRPM79X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM79X" is
	procedure initial_value(json_str in clob) is
		json_obj		json_object_t;
	begin
		v_chken := hcm_secur.get_v_chken;
		json_obj := json_object_t(json_str);
		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');

		pa_codcomp := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_codmist := hcm_util.get_string_t(json_obj,'pa_codmist');
		pa_dtestr_str := hcm_util.get_string_t(json_obj,'pa_dtestr');
		pa_dteend_str := hcm_util.get_string_t(json_obj,'pa_dteend');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_variable_getindex(json_str_input in clob) as

		cursor c_resultcodcomp is select CODCOMP
		from TCENTER
		where CODCOMP like pa_codcomp||'%';
		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;

		v_codcodec		varchar2(4 char);
	BEGIN
		if (pa_codcomp is null or pa_codcomp = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_codcomp');
			return ;
		end if;
		if (pa_dtestr_str is null or pa_dtestr_str = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_dtestr_str');
			return ;
		end if;

		if(pa_dteend_str is null or pa_dteend_str = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_dteend_str');
			return ;
		end if;
		IF ( pa_dtestr_str is not null) THEN
			BEGIN
				pa_dtestr := to_date(trim(pa_dtestr_str),'dd/mm/yyyy');
			exception when others then
				param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_dtestr_str');
				return;
			END;
		END IF;

		IF (pa_dteend_str <> ' ' or pa_dteend_str is not null) THEN
			BEGIN
				pa_dteend := to_date(trim(pa_dteend_str),'dd/mm/yyyy');
			exception when others then
				param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_dteend_str');
				return;
			END;
		END IF;
		if( pa_dtestr > pa_dteend ) then
			param_msg_error := get_error_msg_php('HR2021',global_v_lang, 'pa_dteend');
			return ;
		end if;

		OPEN c_resultcodcomp;
		FETCH c_resultcodcomp INTO objectCursorResultcodcomp ;
		IF (c_resultcodcomp%NOTFOUND) THEN
			param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TCENTER');
			return ;
		END IF;
		CLOSE c_resultcodcomp;
		if (pa_codmist is not null and pa_codmist <> ' ') then
			begin
				select CODCODEC into v_codcodec
				from TCODMIST
				where CODCODEC = pa_codmist;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TCODMIST');
				return;
			end;
		end if;

		param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
		if(param_msg_error is not null ) then
			return;
		end if;

	END vadidate_variable_getindex;

	procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_index(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
		passSecur1		boolean;

      v_chkdata       boolean := false;
      v_chksec        boolean := false;

		cursor c1 is select a.codempid,a.codcomp,a.numlvl,d.dtemistk,d.codmist,a.typpun,a.codpunsh,a.dtestart,a.dteend,a.flgexempt,
		a.flgblist,a.rowid,a.dteeffec,a.numseq
		from thispun a,temploy1 b,thismist d
		where a.codempid = d.codempid
		and a.dteeffec = d.dteeffec
		and a.codempid = b.codempid
		and (a.codcomp like pa_codcomp||'%' and d.codmist = nvl(pa_codmist , d.codmist))
		and d.dtemistk between nvl(pa_dtestr,d.dtemistk) and nvl(pa_dteend,d.dtemistk)
    order by d.codcomp,a.codempid,d.codmist,d.dtemistk;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
      v_rcnt := 0;

		for r1 in c1 loop
         v_chkdata  := true;
			obj_data := json_object_t();
			passSecur1 := secur_main.secur1(r1.codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

            if (passSecur1 = true) then
                  v_chksec := true;
                  obj_data.put('coderror', '200');
                  obj_data.put('codcomp',r1.codcomp);
                  obj_data.put('companyname',get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
                  obj_data.put('rcnt', to_char(v_rcnt));
                  obj_data.put('image',get_emp_img(r1.codempid));
                  obj_data.put('codempid', r1.codempid);
                  obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang) );
                  obj_data.put('datemist', to_char(r1.dtemistk,'dd/mm/yyyy'));
                  obj_data.put('typmist', get_tcodec_name('TCODMIST', r1.CODMIST,global_v_lang));
                  obj_data.put('typpunish', GET_TLISTVAL_NAME('NAMTPUN', r1.TYPPUN , global_v_lang) );
                  obj_data.put('punishid', r1.codpunsh );
                  obj_data.put('punish', get_tcodec_name('TCODPUNH', r1.codpunsh,global_v_lang) );
                  obj_data.put('str', to_char(r1.dtestart,'dd/mm/yyyy') );
                  obj_data.put('end', to_char(r1.dteend,'dd/mm/yyyy') );
                  obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy') );--user37 #4928 Final Test Phase 1 V11 15/03/2021   
                  obj_data.put('numseq', to_char(r1.numseq) );--user37 #4928 Final Test Phase 1 V11 15/03/2021  
                  if (r1.FLGEXEMPT = 'N') then
                     obj_data.put('exitdesc',get_label_name('HRPM79X',global_v_lang,0));
                  ELSE
                     obj_data.put('exitdesc',get_label_name('HRPM79X',global_v_lang,1));
                  end if;

                  if (r1.FLGBLIST = 'N') then
                     obj_data.put('blackdesc',get_label_name('HRPM79X',global_v_lang,2));
                  ELSE
                     obj_data.put('blackdesc',get_label_name('HRPM79X',global_v_lang,3));
                  END if;
                  obj_data.put('exit', r1.FLGEXEMPT );
                  obj_data.put('black', r1.FLGBLIST );

                  obj_row.put(to_char(v_rcnt),obj_data);
                  v_rcnt := v_rcnt+1;
               end if;

		end loop;

        if not v_chkdata then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'THISPUN');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
        end if;

        if not v_chksec   then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
        end if;


		if param_msg_error is null then
			json_str_output := obj_row.to_clob();
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

end HRPM79X;

/
