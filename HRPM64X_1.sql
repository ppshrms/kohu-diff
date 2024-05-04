--------------------------------------------------------
--  DDL for Package Body HRPM64X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM64X" is

	procedure initial_value(json_str in clob) is
		json_obj		    json_object_t;
	begin
		json_obj            := json_object_t(json_str);

		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		pa_codcomp          := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_codempid         := hcm_util.get_string_t(json_obj,'pa_codempid');

		pa_dtestr           := to_date(hcm_util.get_string_t(json_obj,'pa_dtestr'),'dd/mm/yyyy');
		pa_dteend           := to_date(hcm_util.get_string_t(json_obj,'pa_dteend'),'dd/mm/yyyy');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		v_flgsecu		boolean := null;
		pa_numlvl		temploy1.numlvl%type;
		chk_bool		boolean;
		tmp			    temploy1.codcomp%type;
		cursor c_resultcodcomp is
            select CODCOMP
              from TCENTER
             where CODCOMP like pa_codcomp||'%';
		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;
	BEGIN
		if pa_codcomp is not null and pa_codempid is not null then
			pa_codcomp := '';
		end if;

        if pa_codempid is not null then
            pa_dtestr := '';
            pa_dteend := '';
        end if;

		if (pa_codcomp is null and pa_codempid is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return ;
		end if;

		if( pa_dtestr > pa_dteend ) then
			param_msg_error := get_error_msg_php('HR2021',global_v_lang);
			return ;
		end if;
		if (pa_codcomp is not null) then
			begin
				OPEN c_resultcodcomp;
				FETCH c_resultcodcomp INTO objectCursorResultcodcomp;
				IF (c_resultcodcomp%NOTFOUND) THEN
					param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
					return ;
				END IF;
				CLOSE c_resultcodcomp;
			end;
		end if;

		if (pa_codempid is not null) then
			begin
				select codcomp,numlvl into tmp,pa_numlvl
				from temploy1
				where codempid = pa_codempid;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
				return;
			end;
		end if;

        if (pa_codcomp is not null) then
		param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
		if(param_msg_error is not null ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang);
			return;
		end if;
        end if;

        if (pa_codempid is not null) then
		chk_bool := secur_main.secur1(tmp,pa_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
		if(chk_bool = false ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang);
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
	end;

	procedure gen_index(json_str_output out clob)as
		obj_data		            json_object_t;
		obj_row			            json_object_t;
		obj_result		            json_object_t;
        count_row_pass_secur1       number := 0;
		v_rcnt			            number := 0;
		count_m			            number := 0;
		count_f			            number := 0;
		sum_emp			            number := 0;
		v_secur			            boolean := false;
		v_permission		        boolean := false;
		v_data_exist		        boolean := false;
		v_codcomp		            temploy1.codcomp%type;
		v_numlvl		            temploy1.numlvl%type;
        v_image_name                varchar2(200);
        v_image_path                varchar2(500);
        v_data                      varchar2(50);  --#6130 || User39 || 7/9/2021
        v_chksecur                  varchar2(50);  --#6130 || User39 || 7/9/2021

		cursor c1 is
            select codempid,numlvl,dteempmt,codcomp,codsex,dteempdb,dteretire,codpos
              from temploy1
             where codempid   =       nvl(pa_codempid,codempid)
               and codcomp    like    nvl(pa_codcomp||'%','%')
               and dteretire  between nvl(pa_dtestr,dteretire) and nvl(pa_dteend,dteretire)
               and (dteeffex is null or (dteeffex is not null and dteretire > dteretire))
               and staemp <> '9'
          order by codempid ;

	begin
		obj_row         := json_object_t();
		obj_data        := json_object_t();
        v_image_path    := '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/';
		v_data          := 'N'; --#6130 || User39 || 7/9/2021
        v_chksecur      := 'N'; --#6130 || User39 || 7/9/2021

        for r1 in c1 loop
            v_data      := 'Y';
			--obj_data    := json_object_t();  --#6128 || User39 || 7/9/2021
			v_codcomp   := r1.codcomp;
			v_numlvl    := r1.numlvl;
			v_secur     := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
			if v_secur then
                obj_data    := json_object_t();  --#6128 || User39 || 7/9/2021
                v_chksecur      := 'Y';
                v_permission    := true;
                v_data_exist    := true;
                v_rcnt          := v_rcnt+1;
				if (r1.codsex = 'M') then
					count_m := count_m+1;
				end if;

				if (r1.codsex = 'F') then
					count_f := count_f+1;
				end if;
                v_image_name  := get_emp_img(r1.codempid);
				obj_data.put('coderror', '200');
				obj_data.put('rcnt', to_char(v_rcnt));
				obj_data.put('img', nvl(v_image_name,r1.codempid));
                if v_image_name is not null then
                  obj_data.put('logo_image',v_image_path||v_image_name);
                else
                  obj_data.put('logo_image','');
                end if;
				obj_data.put('codempid', r1.codempid);
				obj_data.put('name', get_temploy_name(r1.codempid,GLOBAL_V_LANG));
				obj_data.put('dep', get_tcenter_name(r1.codcomp,GLOBAL_V_LANG));
				obj_data.put('pos', get_tpostn_name(r1.codpos,GLOBAL_V_LANG));
				obj_data.put('lvl', r1.numlvl );
				obj_data.put('dtestr', to_char(r1.dteempmt,'dd/mm/yyyy') );
				obj_data.put('dteb', to_char(r1.dteempdb,'dd/mm/yyyy') );
				obj_data.put('dteend', to_char(r1.dteretire,'dd/mm/yyyy') );
                count_row_pass_secur1 := count_row_pass_secur1 + 1;
				obj_row.put(to_char(v_rcnt-1),obj_data);
			end if;
		end loop;

/*--<< user20 Date: 09/09/2021  PM Module- #6864
        --#6130 || User39 || 7/9/2021
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if v_chksecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;

--        if count_row_pass_secur1 = 0 then
--            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
--        end if;
        --#6130 || User39 || 7/9/2021
--<< user20 Date: 09/09/2021  PM Module- #6864 */

        --<< user20 Date: 09/09/2021  PM Module- #6864
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        elsif v_chksecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        --<< user20 Date: 09/09/2021  PM Module- #6864


		if v_data_exist then
			sum_emp := count_m+count_f;
			obj_data.put('count_m', count_m );
			obj_data.put('count_f', count_f );
			obj_data.put('sum_emp', sum_emp );
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end if;

        --#6130 || User39 || 7/9/2021
        /*
        if v_rcnt > 0 then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2059',global_v_lang, 'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        */
        if v_rcnt > 0 then
            json_str_output := obj_row.to_clob;
        end if;
        --#6130 || User39 || 7/9/2021


	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
end HRPM64X;

/
