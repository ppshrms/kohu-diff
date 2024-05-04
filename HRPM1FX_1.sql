--------------------------------------------------------
--  DDL for Package Body HRPM1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM1FX" is

  procedure initial_value(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str);

		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		pa_codcomp := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_codempid := hcm_util.get_string_t(json_obj,'pa_codempid');
		pa_staemp := hcm_util.get_string_t(json_obj,'pa_staemp');

		pa_dtestr_str := hcm_util.get_string_t(json_obj,'pa_dtestr');
		pa_dteend_str := hcm_util.get_string_t(json_obj,'pa_dteend');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		boolean;
		tmp temploy1.numlvl%type;
        v_codcomp   temploy1.codcomp%type;
		cursor c_resultcodcomp is select CODCOMP
		from TCENTER
		where CODCOMP like pa_codcomp||'%';
		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;
	BEGIN
		if pa_codcomp is not null and pa_codempid is not null then
			pa_codcomp := '';
		end if;

		if (pa_codcomp is null and pa_codempid is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
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
				param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_dtestr_str');
				return;
			END;
		END IF;
		if( pa_dtestr > pa_dteend ) then
			param_msg_error := get_error_msg_php('HR2021',global_v_lang, 'pa_dteend');
			return ;
		end if;

		if (pa_codcomp is not null) then
			begin
				OPEN c_resultcodcomp;
				FETCH c_resultcodcomp INTO objectCursorResultcodcomp;
				IF (c_resultcodcomp%NOTFOUND) THEN
					param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'p_codcomp');
					return ;
				END IF;
				CLOSE c_resultcodcomp;
			end;
		end if;
		if (pa_codempid is not null) then
			begin
				select codcomp,numlvl into v_codcomp,tmp
				from temploy1
				where codempid = pa_codempid
				and rownum <=1;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'pa_codempid');
				return;
			end;
		end if;

        if (pa_codcomp is not null) then
		param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
		if(param_msg_error is not null ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
			return;
		end if;
        end if;

        if (pa_codempid is not null) then
		chk_bool := secur_main.secur1(v_codcomp,tmp,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
		if(chk_bool = false ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
			return;
		end if;
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
	end get_index;

	procedure gen_index(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
		v_ocodempid		varchar2(400) := GET_OCODEMPID(pa_codempid);

		cursor c1_empid is select a.codempid,a.codasset,a.dtercass,a.dtertass,a.remark,
		b.numlvl,b.codcomp
		from tassets a,temploy1 b
		where b.codempid = pa_codempid
        and a.codempid = b.codempid
        -->> fix issue Phase 1 #5072
--        and a.dtercass between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass)
        and (   (a.dtercass between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass))
             or (nvl(a.dtertass,trunc(sysdate)) between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass))
             or (nvl(pa_dtestr,dtercass) between a.dtercass and nvl(a.dtertass,trunc(sysdate)))
             or (nvl(pa_dteend,dtercass) between a.dtercass and nvl(a.dtertass,trunc(sysdate)))
        )
        --<< fix issue Phase 1 #5072
		order by a.dtercass;


		cursor c1_comp is select a.codempid,a.codasset,a.dtercass,a.dtertass,a.remark,
		b.staemp,b.codcomp,b.numlvl
		from tassets a,temploy1 b
		where  a.codempid = b.codempid
		and b.codcomp like pa_codcomp||'%'
		and (      (b.staemp = '9' and pa_staemp = '1')
                OR (b.staemp in ('1','3') and pa_staemp = '2')
                OR (b.staemp in ('1','3','9') and pa_staemp = '3'))

        -->> fix issue Phase 1 #5072
--        and a.dtercass between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass)
        and (   (a.dtercass between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass))
             or (nvl(a.dtertass,trunc(sysdate)) between nvl(pa_dtestr,dtercass) and nvl(pa_dteend,dtercass))
             or (nvl(pa_dtestr,dtercass) between a.dtercass and nvl(a.dtertass,trunc(sysdate)))
             or (nvl(pa_dteend,dtercass) between a.dtercass and nvl(a.dtertass,trunc(sysdate)))
        )
        --<< fix issue Phase 1 #5072
		order by a.codempid,a.dtercass;
		c1_comp_cur c1_comp%ROWTYPE;
		passSecur1		BOOLEAN;
        has_data        BOOLEAN;
	begin
		obj_row := json_object_t();
		obj_data := json_object_t();

		if pa_codempid is not null then
			for r1 in c1_empid loop
                has_data := true;
                obj_data := json_object_t();

                passSecur1 := secur_main.secur1(r1.codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if passSecur1 then
				v_rcnt := v_rcnt+1;
				obj_data.put('coderror', '200');
				obj_data.put('rcnt', to_char(v_rcnt));
				obj_data.put('codempid', r1.codempid);
				obj_data.put('name', get_temploy_name(r1.codempid,GLOBAL_V_LANG));
				obj_data.put('codasset', r1.CODASSET);
				obj_data.put('detcodasset', GET_TASEINF_NAME(r1.CODASSET,GLOBAL_V_LANG));
				obj_data.put('dtre', to_char(r1.dtercass,'dd/mm/yyyy'));
				obj_data.put('dtbk', to_char(r1.dtertass,'dd/mm/yyyy') );
				obj_data.put('rem', r1.remark );
                obj_data.put('dtercass', to_char(r1.dtercass,'dd/mm/yyyy'));

				obj_row.put(to_char(v_rcnt-1),obj_data);
                end if;
			end loop;

		else
			for r1 in c1_comp loop
				has_data := true;
				obj_data := json_object_t();

                --<<User37 Final Test Phase 1 V11 #1770 15/10/2020
                --passSecur1 := secur_main.secur7(r1.codcomp, global_v_coduser);
                passSecur1 := secur_main.secur1(r1.codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                -->>User37 Final Test Phase 1 V11 #1770 15/10/2020
                if passSecur1 then
                v_rcnt := v_rcnt+1;
				obj_data.put('coderror', '200');
				obj_data.put('rcnt', to_char(v_rcnt));
				obj_data.put('codempid', r1.codempid);
				obj_data.put('name', get_temploy_name(r1.codempid,GLOBAL_V_LANG));
				obj_data.put('codasset', r1.CODASSET);
				obj_data.put('detcodasset', GET_TASEINF_NAME(r1.CODASSET,GLOBAL_V_LANG));
				obj_data.put('dtre', to_char(r1.dtercass,'dd/mm/yyyy'));
				obj_data.put('dtbk', to_char(r1.dtertass,'dd/mm/yyyy') );
				obj_data.put('rem', r1.remark );
                obj_data.put('dtercass', to_char(r1.dtercass,'dd/mm/yyyy'));

				obj_row.put(to_char(v_rcnt-1),obj_data);
                end if;

			end loop;
		end if;

        if has_data = true then

        if v_rcnt = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        else
            json_str_output := obj_row.to_clob;
        end if;

        else
            obj_row := json_object_t();
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TASSETS');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_index;

	procedure initial_value_detail (json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str);

		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		pa_codasset := hcm_util.get_string_t(json_obj,'pa_codasset');

	end initial_value_detail ;

	procedure vadidate_variable_get_detail(json_str_input in clob) as
	begin
		if (pa_codasset is null or pa_codasset = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_codasset');
			return ;
		end if ;
	end vadidate_variable_get_detail;

	procedure get_detail(json_str_input in clob, json_str_output out clob) as
	begin

		initial_value_detail(json_str_input);
		vadidate_variable_get_detail(json_str_input);
		if param_msg_error is null then
			gen_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end get_detail;

	procedure gen_detail(json_str_output out clob) as

		cursor c1 is SELECT tasetinf.CODASSET,
		decode(global_v_lang,'101', tasetinf.DESASSEE ,
		'102', tasetinf.DESASSET,
		'103', tasetinf.DESASSE3,
		'104', tasetinf.DESASSE4,
		'105', tasetinf.DESASSE5,tasetinf.DESASSET) DESASSEE,
		tasetinf.DTEREC,tasetinf.DESNOTE,tasetinf.SRCASSET,tasetinf.TYPASSET,
		tasetinf.NAMIMAGE,tasetinf.COMIMAGE,tasetinf.STAASSET,tasetinf.DTECREATE,
		tasetinf.CODCREATE,tasetinf.DTEUPD,tasetinf.CODUSER,
		decode(global_v_lang,'101', tcodasst.DESCODE ,
		'102', tcodasst.DESCODT,
		'103', tcodasst.DESCOD3,
		'104', tcodasst.DESCOD4,
		'105', tcodasst.DESCOD5,tcodasst.DESCODT) DESCODE
		FROM tasetinf
		inner join tcodasst on tcodasst.CODCODEC = tasetinf.TYPASSET
		where CODASSET = pa_codasset ;
		obj_data		json_object_t;
		obj_row			json_object_t;
		v_rcnt			number := 0;
	begin

		obj_row := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt + 1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('codasset',r1.CODASSET);
			obj_data.put('desassee',r1.desassee);
			obj_data.put('dterec',to_char(r1.dterec,'DD/MM/YYYY'));
			obj_data.put('desnote',r1.desnote);
			obj_data.put('typasset',r1.typasset);
			obj_data.put('namimage',r1.namimage);
			obj_data.put('comimage',r1.comimage);
			obj_data.put('staasset',r1.staasset);
			obj_data.put('srcasset',r1.SRCASSET);
			obj_data.put('dtecreate',r1.dtecreate);
			obj_data.put('codcreate',r1.codcreate);
			obj_data.put('dteupd',r1.dteupd);
			obj_data.put('coduser',r1.coduser);
			obj_data.put('descode',r1.DESCODE);
			obj_row.put(to_char(v_rcnt - 1),obj_data);
		end loop;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_detail;
end HRPM1FX;

/
