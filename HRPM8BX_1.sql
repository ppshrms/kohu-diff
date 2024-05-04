--------------------------------------------------------
--  DDL for Package Body HRPM8BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM8BX" AS

 procedure initial_value(json_str in clob) is
		json_obj		json_object_t;

	begin
		json_obj := json_object_t(json_str);
		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');

		p_codcomp := hcm_util.get_string_t(json_obj,'pa_codcomp');
		p_codempid := hcm_util.get_string_t(json_obj,'pa_codempid');
		p_codpos := hcm_util.get_string_t(json_obj,'pa_codpos');
		p_typdisp := hcm_util.get_string_t(json_obj,'pa_typdisp');
		p_staemp := hcm_util.get_string_t(json_obj,'pa_staemp');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		boolean;
		tmp varchar(100);
		cursor c_resultcodcomp is select CODCOMP
		from TCENTER
		where CODCOMP like p_codcomp||'%';
		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;
	BEGIN
		if p_codempid is not null then
			p_codpos := '';
			p_typdisp := '';
			p_staemp := '';
		end if;
		if p_codcomp is not null and p_codempid is not null then
			p_codcomp := '';
		end if;

		if (p_codcomp is null and p_codempid is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;
		if (p_codcomp is not null) then
			begin
				OPEN c_resultcodcomp;
				FETCH c_resultcodcomp INTO objectCursorResultcodcomp;
				IF (c_resultcodcomp%NOTFOUND) THEN
					param_msg_error := get_error_msg_php('HR2010',global_v_lang, '');
					return ;
				END IF;
				CLOSE c_resultcodcomp;
			end;
		end if;

		if (p_codempid is not null) then
			begin
				select stadisb into tmp
				from temploy1
				where codempid = p_codempid;
				if(tmp = 'N') then
					param_msg_error := get_error_msg_php('PM0087',global_v_lang,'');
					return;
				end if;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'');
				return;
			end;
		end if;
		if (p_codpos is not null) then
			begin
				select codpos into tmp
				from tpostn
				where codpos = p_codpos;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'p_codpos');
				return;
			end;
		end if;

		if (p_typdisp is not null) then
			begin
				select codcodec into tmp
				from tcoddisp
				where codcodec = p_typdisp;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'p_typdisp');
				return;
			end;
		end if;
		param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,p_codcomp);
		if(param_msg_error is not null ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
			return;
		end if;

		chk_bool := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
		if(chk_bool = false ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
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
		obj_result	json_object_t;
		v_rcnt			number := 0;
		count_m			number := 0;
		count_f			number := 0;
		sum_emp			number := 0;
		v_secur			boolean := false;
		v_permission		boolean := false;
		v_data_exist		boolean := false;
		v_codcomp		temploy1.codcomp%type;
		v_numlvl		temploy1.numlvl%type;

    v_image             varchar2(1000 char) := '';
    v_logo_image        varchar2(1000 char) := '';

		cursor c1 is
		select codcomp,codempid,numlvl,dteempmt,codpos,stadisb,numdisab,typdisp,
		dtedisb,dtedisen,desdisp
		from temploy1
		where nvl(stadisb,'N') = 'Y'
		and codcomp like p_codcomp||'%'
		and codpos = nvl(p_codpos,codpos)
		and nvl(typdisp,'!') = nvl(p_typdisp,nvl(typdisp,'!'))
		and ((staemp like decode(p_staemp,null,'%',p_staemp) and nvl(p_staemp,'!') <> '99')
		or (p_staemp = '99' and staemp in ('1','3')))
		and codempid = nvl(p_codempid,codempid)
		order by codcomp,codempid,dteempmt;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			v_codcomp := r1.codcomp;
			v_numlvl := r1.numlvl;
			v_data_exist := true;
			v_secur := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

			if v_secur then
        if r1.codempid != '%' then
          begin
            select get_tfolderd('HRPMC2E1')||'/'||namimage
             into v_image
             from tempimge
             where codempid = r1.codempid;
          exception when no_data_found then
            v_image := '';
          end;
        end if;    

				v_permission := true;
				obj_data.put('coderror', '200');
				obj_data.put('rcnt', to_char(v_rcnt));
				obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('logo_image','/'||get_tsetup_value('PATHWORKPHP')||v_image);
				obj_data.put('codempid', r1.codempid);
                obj_data.put('codcomp',v_codcomp);
				obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
				obj_data.put('stdate', to_char(r1.dteempmt,'dd/mm/yyyy'));
				obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
				obj_data.put('typ', get_tcodec_name('TCODDISP',r1.typdisp,global_v_lang ));
				obj_data.put('nature', r1.desdisp);
				obj_data.put('datenature', to_char(r1.dtedisb,'dd/mm/yyyy') );
				obj_data.put('dateend', to_char(r1.dtedisen,'dd/mm/yyyy') );

				obj_row.put(to_char(v_rcnt-1),obj_data);
			end if;
		end loop;

        if v_data_exist then

        if v_permission then
		json_str_output := obj_row.to_clob;
        else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
        end if;
        else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
        end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
END HRPM8BX;

/
