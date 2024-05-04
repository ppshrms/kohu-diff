--------------------------------------------------------
--  DDL for Package Body HRPM4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4CE" is
	-- last update: 1/10/2019

	procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		v_chken             := hcm_secur.get_v_chken;
		json_obj            := json_object_t(json_str);

		--global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		-- index
		v_codempid          := upper(hcm_util.get_string_t(json_obj,'v_codempid'));
		p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
		p_codpos            := upper(hcm_util.get_string_t(json_obj,'p_codpos'));
		dateNow             := CURRENT_DATE;
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		tmp			number;
		chk_bool	boolean;
		v_staemp    temploy1.staemp%type;
		v_flgsecu   boolean := false;
	BEGIN

		if p_codcomp is not null and v_codempid is not null and p_codpos is not null then
			p_codcomp   := '';
			p_codpos    := '';
		end if;

		if (p_codcomp is null and v_codempid is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return ;
		end if;

		if (p_codcomp is not null) then
                --<<User37 #3199 Final Test Phase 1 V11 28/01/2021
                /*if p_codpos is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;*/
                -->>User37 #3199 Final Test Phase 1 V11 28/01/2021

                begin
                    select count(*)
                      into tmp
                      from tcenter
                     where codcomp like p_codcomp||'%';
                end;

                if (tmp = 0) then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                    return;
                end if;
        end if;

		if (v_codempid is not null) then
                begin
                    select count(*)
                      into tmp
                      from temploy1
                     where codempid = v_codempid;
                end;
                if (tmp = 0) then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                    return;
                end if;
		end if;

		if p_codpos is not null then
                begin
                    select count(*)
                      into tmp
                      from tpostn
                     where codpos = p_codpos;
                end;

                if (tmp = 0) then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
                    return;
                end if;
		end if;

		if p_codcomp is not null then
			param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
			if(param_msg_error is not null ) then
				param_msg_error := get_error_msg_php('HR3007',global_v_lang);
				return;
			end if;
		end if;

		if v_codempid is not null then
/* #2709
			param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,v_codempid);
			if(param_msg_error is not null ) then
				param_msg_error := get_error_msg_php('HR3007',global_v_lang);
				return;
			end if;
*/
--#2709
            v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
			if not v_flgsecu then
				param_msg_error := get_error_msg_php('HR3007',global_v_lang);
				return;
			end if;
--#2709
--#2709
            begin
				select staemp into v_staemp
				  from temploy1
				 where codempid = v_codempid;

                if v_staemp = '9' then
                    param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                    return;
                elsif v_staemp = '0' then
                    param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                    return;
                end if;

            exception when no_data_found then
				v_staemp := null;
			end;
--#2709
        end if;
	end vadidate_variable_getindex;

	procedure getIndex (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			genIndex(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genIndex (json_str_output out clob) as
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			number := 0;
		v_countdata		number := 0;
		v_codcomp		varchar2( 100 char) := p_codcomp||'%';
		v_codpos		varchar2( 100 char) := p_codpos||'%';
		p_codcompid		varchar2( 100 char);
		flgpass			boolean;
		v_view_zupdsal	varchar2(1 char) := 'N';
		v_data			varchar2(1) := 'N';
        v_staupd        tlistval.desc_label%type;
        v_flgstaupd     varchar2(10);--User37 #2230 Final Test Phase 1 V11 03/02/2021

		cursor c_temploy1 is
            select codempid, to_char(dteeffec,'dd/mm/yyyy') as dteeffec, numseq, codcomp, codpos, codjob, codbrlc,
                   numlvl, stapost2, seqcancel, dteend, rowid, dtecancel
		      from tsecpos t1
		     where codempid = nvl(v_codempid,codempid)
               and codcomp like v_codcomp||'%'
               and codpos = nvl(p_codpos,codpos)--User37 #3199 Final Test Phase 1 V11 28/01/2021 and codpos like v_codpos
--#2709
               and exists (select staemp from temploy1 t2 where t2.codempid = t1.codempid
                                          and staemp in ('1','3') )
--#2709
		  order by dteeffec desc,codempid,numseq;

	begin
		obj_row := json_object_t();
		for r1 in c_temploy1 loop

			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;
			v_data      := 'Y';
			flgpass     := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_view_zupdsal);
			obj_data.put('coderror', '200');
			obj_data.put('rownumber', v_rcnt);
			obj_data.put('codempid', r1.codempid);
			obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang) );
			obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang) );
			obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang) );
			obj_data.put('codcomp', r1.codcomp);
			obj_data.put('dteeffec', r1.dteeffec);
			obj_data.put('image', get_emp_img (r1.codempid));
			obj_data.put('numseq', r1.numseq);
			obj_data.put('codpos', r1.codpos);
			obj_data.put('codjob', r1.codjob);
			obj_data.put('codbrlc', r1.codbrlc);
			obj_data.put('numlvl', r1.numlvl);
			obj_data.put('stapost2', r1.stapost2);
			obj_data.put('desc_stapost2', get_tlistval_name('STAPOST2',r1.stapost2,global_v_lang));
			obj_data.put('seqcancel', r1.seqcancel);
			obj_data.put('dtecancel', to_char(nvl(r1.dtecancel,sysdate),'dd/mm/yyyy'));
			obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
			obj_data.put('viewsalary',v_view_zupdsal);

            BEGIN
                select get_tlistval_name('STAAPPR', decode(STAUPD,'C','Y',STAUPD), global_v_lang)
                       ,decode(STAUPD,'C','Y',STAUPD)--User37 #2230 Final Test Phase 1 V11 03/02/2021
                  into v_staupd
                       ,v_flgstaupd--User37 #2230 Final Test Phase 1 V11 03/02/2021
                  from ttmovemt
                 where codempid = r1.codempid
                   and dteeffec = r1.dtecancel
                   and numseq = r1.seqcancel ;
            exception when no_data_found then
                v_staupd := '';
            END;
            obj_data.put('staupd',v_staupd);
            obj_data.put('flgstaupd',v_flgstaupd);--User37 #2230 Final Test Phase 1 V11 03/02/2021

			if flgpass then
				obj_row.put(v_countdata, obj_data);
				v_countdata := v_countdata + 1;
			end if;
		end loop;

		if v_data = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSECPOS');
		elsif ( v_countdata = 0 ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang);
		end if;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure init_Detail(json_str_input in clob) as
		json_obj		json_object_t;
	begin
		v_chken     := hcm_secur.get_v_chken;
		json_obj    := json_object_t(json_str_input);

		-- Global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
		-- Detail
		p_dtecancel         := to_date(hcm_util.get_string_t(json_obj,'p_dtecancel'), 'dd/mm/yyyy');
		p_seqcancel         := hcm_util.get_string_t(json_obj,'p_seqcancel');
		v_codempid          := hcm_util.get_string_t(json_obj,'v_codempid');
		p_viewsalary        := hcm_util.get_string_t(json_obj,'p_viewsalary');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end init_Detail;

	procedure getDetail (json_str_input in clob, json_str_output out clob) as
	begin
		init_Detail(json_str_input);
		genDetail(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetail (json_str_output out clob) as
		obj_row			json_object_t;
		obj_data		json_object_t;
		obj_detail		json_object_t;
		v_rcnt			number := 0;
		v_check			number ;
		is_found_rec	boolean := false;
		v_max			number ;
		codcur			ttmovemt.codcurr%type;

		cursor c_ttmovemt is
            select *
              from ttmovemt
             where codempid = v_codempid
               and dteeffec = p_dtecancel
               and numseq = p_seqcancel;
	begin
		obj_row := json_object_t();

        flgsecur := secur_main.secur2(v_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
		for r1 in c_ttmovemt loop
			obj_data        := json_object_t();
			v_rcnt          := v_rcnt + 1;
			is_found_rec    := true;
			if r1.staupd <> 'P' then --user37 Final Test Phase 1 V11 #3086 05/02/2021 in ('N','C','U') then
				obj_data.put('error',get_msgerror('HR1500',global_v_lang));
			else
				obj_data.put('error','');
			end if;

			obj_data.put('coderror', '200');
			obj_data.put('desnote', r1.desnote);
			obj_data.put('codcurr', r1.codcurr);
			obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('desccodcur', get_tcodec_name('TCODCURR',r1.codcurr,global_v_lang));
			obj_data.put('staupd', r1.staupd);
			obj_data.put('numseq', r1.numseq);
			obj_data.put('codtrn', r1.codtrn);
			obj_data.put('coduser', r1.coduser);
			obj_data.put('coduserShow', r1.codreq);
			obj_data.put('dtecancel', to_char(p_dtecancel,'dd/mm/yyyy'));
			obj_data.put('ttmovemtdteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('mode', 'edit');
            obj_data.put('v_zupdsal', v_zupdsal);
			obj_row.put(to_char(v_rcnt - 1), obj_data);
		end loop;

		if not is_found_rec then
			begin
				v_max := get_max_running(v_codempid,p_dtecancel) ;

				select codcurr
                  into codcur
				  from temploy3
				 where codempid = v_codempid;
			exception
			when no_data_found then
				v_max   := 1 ;
				codcur  := '';
			end ;

			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('desnote', '');
			obj_data.put('codcurr', codcur);
			obj_data.put('desccodcur', get_tcodec_name('TCODCURR',codcur,global_v_lang));
			obj_data.put('coduser', global_v_coduser);
			obj_data.put('coduserShow', get_codempid(global_v_coduser));
			obj_data.put('dtecancel',to_char(sysdate,'dd/mm/yyyy'));
			obj_data.put('ttmovemtdteeffec','');
			obj_data.put('numseq', v_max);
			obj_data.put('codtrn', '0007');
			obj_data.put('mode', 'add');
            obj_data.put('v_zupdsal', v_zupdsal);
			obj_row.put(0, obj_data);
		end if;
		json_str_output := obj_row.to_clob;
	end;

	procedure init_DetailTable (json_str_input in clob) as
		json_obj		json_object_t;
	begin
--		v_chken     := hcm_secur.get_v_chken;
		json_obj    := json_object_t(json_str_input);
		-- Global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

		-- Detail
		p_dtecancel     := to_date(hcm_util.get_string_t(json_obj,'p_dtecancel'), 'dd/mm/yyyy');
		p_seqcancel     := hcm_util.get_string_t(json_obj,'p_seqcancel');
		v_codempid      := hcm_util.get_string_t(json_obj,'v_codempid');
		p_viewsalary    := hcm_util.get_string_t(json_obj,'p_viewsalary');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end init_DetailTable;

	procedure getDetailTable (json_str_input in clob, json_str_output out clob) as
	begin
    null;
		init_DetailTable(json_str_input);
		genDetailTable(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetailTable (json_str_output out clob) as
		obj_row			    json_object_t;
		obj_test		    json_object_t;
		obj_data		    json_object_t;
		obj_detail		    json_object_t;
		obj_row_temp		json_object_t;
		v_json_input        clob;
		v_json_codincom     clob;
		v_rcnt			    number := 0;
		dteeffe			    varchar2( 100 char) := '';
		param_json_row		json_object_t;
		v_counter		    number := 0;
		v_amtothr_income	number;
		v_amtday_income		number;
		v_sumincom_income	number;
		flgpass			    boolean;
		v_amtothr_adj		number;
		v_amtday_adj		number;
		v_sumincom_adj		number;
		v_amtothr_simple	number;
		v_amtday_simple		number;
		v_sumincom_simple	number;
		v_row			    number := 0;
		v_obj_codincome_clob clob;
		v_obj_codincomejson	json_object_t;
		type p_num is table of number index by binary_integer;
		v_amtincom          p_num;
		v_amtincadj         p_num;
		v_countdata		    number;
		v_codcompy		    temploy1.codcomp%type;
		codempmt		    temploy1.codempmt%type;
		v_sumhur		    number;
		v_sumday		    number;
		v_summth		    number;
		v_show_amtincom		number;
	begin
		if ( upper(p_viewsalary) = 'N') then
			obj_row := json_object_t();
		else
			begin
				select count(*) into v_countdata
				  from ttmovemt
				 where codempid = v_codempid
				   and dteeffec = p_dtecancel
				   and numseq = p_seqcancel;

				select codempmt into codempmt
				  from temploy1
				 where codempid = v_codempid;

				select codcomp
				  into v_codcompy
				  from temploy1
				 where codempid = v_codempid;
			exception when no_data_found then
				v_codcompy := null;
			end;

			for i in 1..10 loop
				v_amtincom(i)   := 0;
				v_amtincadj(i)  := 0;
			end loop;

			obj_row			    := json_object_t ();
			v_json_input        := '{"p_codcompy":"'||hcm_util.get_codcomp_level(v_codcompy, 1)||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||codempmt||'","p_lang":"'||global_v_lang||'"}';
			v_json_codincom     := hcm_pm.get_codincom(v_json_input);
			v_obj_codincomejson := json_object_t(v_json_codincom);

			if(v_countdata > 0) then
				begin
					select stddec(amtincom1,v_codempid,global_v_chken),
                           stddec(amtincom2,v_codempid,global_v_chken),
                           stddec(amtincom3,v_codempid,global_v_chken),
                           stddec(amtincom4,v_codempid,global_v_chken),
                           stddec(amtincom5,v_codempid,global_v_chken),
                           stddec(amtincom6,v_codempid,global_v_chken),
                           stddec(amtincom7,v_codempid,global_v_chken),
                           stddec(amtincom8,v_codempid,global_v_chken),
                           stddec(amtincom9,v_codempid,global_v_chken),
                           stddec(amtincom10,v_codempid,global_v_chken),
                           stddec(amtincadj1,v_codempid,global_v_chken),
                           stddec(amtincadj2,v_codempid,global_v_chken),
                           stddec(amtincadj3,v_codempid,global_v_chken),
                           stddec(amtincadj4,v_codempid,global_v_chken),
                           stddec(amtincadj5,v_codempid,global_v_chken),
                           stddec(amtincadj6,v_codempid,global_v_chken),
                           stddec(amtincadj7,v_codempid,global_v_chken),
                           stddec(amtincadj8,v_codempid,global_v_chken),
                           stddec(amtincadj9,v_codempid,global_v_chken),
                           stddec(amtincadj10,v_codempid,global_v_chken)
					  into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                           v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                           v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),v_amtincadj(4),v_amtincadj(5),
                           v_amtincadj(6),v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),v_amtincadj(10)
					  from ttmovemt
					 where codempid = v_codempid
					   and dteeffec = p_dtecancel
					   and numseq = p_seqcancel;
				exception when no_data_found then
					for i in 1..10 loop
						v_amtincom(i)   := 0;
						v_amtincadj(i)  := 0;
					end loop;
				end;
				for i in 1..10 loop
					obj_data        := json_object_t();
					v_row           := v_row + 1;
					param_json_row  := hcm_util.get_json_t(v_obj_codincomejson,i-1);
					v_show_amtincom := v_amtincom(i) - v_amtincadj(i);

					obj_data.put('amtincom', to_char(v_show_amtincom, 'fm999,999,999,990.00'));
					obj_data.put('amtincadj',v_amtincadj(i));
					obj_data.put('rowIndex',i);
					obj_data.put('codincom', hcm_util.get_string_t(param_json_row,'codincom'));
					obj_data.put('desincom', hcm_util.get_string_t(param_json_row,'desincom'));
					obj_data.put('desunit', hcm_util.get_string_t(param_json_row,'desunit'));
					obj_data.put('amtmax', hcm_util.get_string_t(param_json_row,'amtmax'));
					obj_data.put('amount', to_char(v_amtincom(i),'fm999,999,999,990.00') );
					if ( length( trim(hcm_util.get_string_t(param_json_row,'codincom')) ) > 0 ) then
						obj_row.put(to_char(i-1), obj_data);
					end if;
				end loop;
			else
				-- no data ttmovemt
				begin
					select stddec(amtincom1,v_codempid,global_v_chken),
                           stddec(amtincom2,v_codempid,global_v_chken),
                           stddec(amtincom3,v_codempid,global_v_chken),
                           stddec(amtincom4,v_codempid,global_v_chken),
                           stddec(amtincom5,v_codempid,global_v_chken),
                           stddec(amtincom6,v_codempid,global_v_chken),
                           stddec(amtincom7,v_codempid,global_v_chken),
                           stddec(amtincom8,v_codempid,global_v_chken),
                           stddec(amtincom9,v_codempid,global_v_chken),
                           stddec(amtincom10,v_codempid,global_v_chken)
					  into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
					       v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
					  from temploy3 where codempid = v_codempid;
				exception when no_data_found then
					for i in 1..10 loop
						v_amtincom(i) := 0;
						v_amtincadj(i) := 0;
					end loop;
				end;

				for i in 1..10 loop
					obj_data        := json_object_t();
					v_row           := v_row + 1;
					param_json_row  := hcm_util.get_json_t(v_obj_codincomejson,i-1);
					obj_data.put('amtincom', trim(TO_CHAR(v_amtincom(i), 'fm999,999,999,990.00')));
					obj_data.put('amtincadj', '0');
					obj_data.put('rowIndex',i);
					obj_data.put('codincom', hcm_util.get_string_t(param_json_row,'codincom'));
					obj_data.put('desincom', hcm_util.get_string_t(param_json_row,'desincom'));
					obj_data.put('desunit', hcm_util.get_string_t(param_json_row,'desunit'));
					obj_data.put('amtmax', hcm_util.get_string_t(param_json_row,'amtmax'));
					obj_data.put('amount', '');

					if ( length( trim(hcm_util.get_string_t(param_json_row,'codincom')) ) > 0 ) then
						obj_row.put(to_char(i-1), obj_data);
					end if;
				end loop;
			end if;
		end if;
		json_str_output := obj_row.to_clob;
	end;

	procedure getDetailWageIncome(json_str_input in clob, json_str_output out clob) as
		v_in_detailtable clob;
	begin
		getDetailTable(json_str_input,v_in_detailtable);
		genDetailWageIncome(v_in_detailtable,json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end getDetailWageIncome;

	procedure genDetailWageIncome(v_in_detailtable in clob,json_str_output out clob) as
		v_obj_row		    json_object_t := json_object_t();
		v_codcompy		    temploy1.codcomp%type;
		v_codempmt		    temploy1.codempmt%type;
		v_amtincom_sumhur	number := 0;
		v_amtincom_sumday	number := 0 ;
		v_amtincom_summth	number := 0 ;
		v_amtincadj_sumhur	number := 0;
		v_amtincadj_sumday	number := 0 ;
		v_amtincadj_summth	number := 0 ;
		v_amountall_sumhur	number := 0;
		v_amountall_sumday	number := 0;
		v_amountall_summth	number := 0;

		v_row_detailtable	json_object_t;
		v_obj_detailtable	json_object_t;
		v_size_detailtable	number;

		type p_num is table of number index by binary_integer;
		v_amtincom          p_num;
		v_amtincadj         p_num;
	begin
		v_row_detailtable   := json_object_t(v_in_detailtable);
		v_size_detailtable  := v_row_detailtable.get_size;
		begin
			select codcomp,codempmt
			  into v_codcompy,v_codempmt
			  from temploy1
			 where codempid = v_codempid;
		exception when no_data_found then
			v_codcompy := null;
		end;

		for i in 1..10 loop
			v_amtincom(i)   := 0;
			v_amtincadj(i)  := 0;
		end loop;

		for i in 1..v_size_detailtable loop
			v_obj_detailtable := hcm_util.get_json_t(v_row_detailtable,i-1);

			if ( hcm_util.get_string_t(v_obj_detailtable,'rowIndex') = to_char(i) ) then
				v_amtincom(i)   := to_number(replace(hcm_util.get_string_t(v_obj_detailtable,'amount'),',',''));
				v_amtincadj(i)  := to_number(replace(hcm_util.get_string_t(v_obj_detailtable,'amtincadj'),',',''));
			end if;
		end loop;

		get_wage_income(
            hcm_util.get_codcomp_level(v_codcompy, 1),
            v_codempmt,
            v_amtincom(1),v_amtincom(2),v_amtincom(3),
            v_amtincom(4),v_amtincom(5),v_amtincom(6),
            v_amtincom(7),v_amtincom(8),v_amtincom(9),
            v_amtincom(10),
            v_amtincom_sumhur ,v_amtincom_sumday , v_amtincom_summth);

		get_wage_income(
            hcm_util.get_codcomp_level(v_codcompy, 1),
            v_codempmt,
            v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),
            v_amtincadj(4),v_amtincadj(5),v_amtincadj(6),
            v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),
            v_amtincadj(10),
            v_amtincadj_sumhur ,v_amtincadj_sumday , v_amtincadj_summth);

		get_wage_income(
            hcm_util.get_codcomp_level(v_codcompy, 1),
            v_codempmt,
            (v_amtincom(1) - v_amtincadj(1)), (v_amtincom(2) - v_amtincadj(2)),
            (v_amtincom(3) - v_amtincadj(3)),(v_amtincom(4) - v_amtincadj(4)),
            (v_amtincom(5) - v_amtincadj(5)),(v_amtincom(6) - v_amtincadj(6)),
            (v_amtincom(7) - v_amtincadj(7)),(v_amtincom(8) - v_amtincadj(8)),
            (v_amtincom(9) - v_amtincadj(9)),(v_amtincom(10) - v_amtincadj(10)),
            v_amountall_sumhur ,v_amountall_sumday , v_amountall_summth);

		v_obj_row.put('amtincomall',to_char(v_amtincom_summth, 'fm999,999,999,990.00'));
		v_obj_row.put('amtincomdayall',to_char(v_amtincom_sumday, 'fm999,999,999,990.00'));
		v_obj_row.put('amtincomhourall',to_char(v_amtincom_sumhur, 'fm999,999,999,990.00'));
		v_obj_row.put('amtincadjall',to_char(v_amtincadj_summth, 'fm999,999,999,990.00'));
		v_obj_row.put('amtincadjdayall',to_char(v_amtincadj_sumday, 'fm999,999,999,990.00'));
		v_obj_row.put('amtincadjhourall',to_char(v_amtincadj_sumhur, 'fm999,999,999,990.00'));
		v_obj_row.put('amountall',to_char(v_amountall_summth, 'fm999,999,999,990.00'));
		v_obj_row.put('amountdayall',to_char(v_amountall_sumday, 'fm999,999,999,990.00'));
		v_obj_row.put('amounthourall',to_char(v_amountall_sumhur, 'fm999,999,999,990.00'));
		v_obj_row.put('coderror','200');

		json_str_output := v_obj_row.to_clob;
	end genDetailWageIncome;

	procedure getRefreshDetailWageIncome(json_str_input in clob, json_str_output out clob) as
		v_obj_row		    json_object_t;
		v_obj_param		    json_object_t;
		v_obj_paramrows		json_object_t;
	begin
		v_obj_row       := json_object_t(json_str_input);
		v_obj_param     := hcm_util.get_json_t(v_obj_row,'paramjson');
		v_obj_paramrows := hcm_util.get_json_t(v_obj_param,'rows');
		v_codempid      := hcm_util.get_string_t(v_obj_row,'v_codempid');

		genRefreshDetailWageIncome(v_obj_paramrows,json_str_output);
	end getRefreshDetailWageIncome;

	procedure genRefreshDetailWageIncome(v_in_detailtable in json_object_t, json_str_output out clob) as
		v_in_clob clob;
	begin
		v_in_clob := v_in_detailtable.to_clob;

		genDetailWageIncome(v_in_clob,json_str_output);
	end genRefreshDetailWageIncome;

	procedure init_save (json_str_input in clob) as
		json_obj		json_object_t;
	begin
		v_chken     := hcm_secur.get_v_chken;
		json_obj    := json_object_t(json_str_input);
		--global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

		--save
		p_mode          := hcm_util.get_string_t(json_obj,'p_mode');
		p_codtrn        := hcm_util.get_string_t(json_obj,'p_codtrn');
		p_desnote       := hcm_util.get_string_t(json_obj,'p_desnote');
		p_numseq        := hcm_util.get_string_t(json_obj,'p_numseq');
		p_codjob        := hcm_util.get_string_t(json_obj,'p_codjob');
		p_codbrlc       := hcm_util.get_string_t(json_obj,'p_codbrlc');
		p_numlvl        := hcm_util.get_string_t(json_obj,'p_numlvl');
		p_codcurr       := hcm_util.get_string_t(json_obj,'p_codcurr');
		v_codusershow   := hcm_util.get_string_t(json_obj,'v_codusershow');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

	end;

	procedure post_save (json_str_input in clob, json_str_output out clob) is
		json_obj		            json_object_t;
		obj_row			            json_object_t;
		obj_data		            json_object_t;
		param_json		            json_object_t;
		param_json_table	        json_object_t;
		param_json_row		        json_object_t;

		v_max			            number := 0;
		v_routeno		            varchar2(10);
		param_json_codincome	    json_object_t;
		param_json_codincome_row	json_object_t;

		v_json_codincom             clob;
		v_json_input                clob;
		v_codcompy		            tcompny.codcompy%type;
		v_flgatten		            temploy1.flgatten%type;
		v_codempmt		            temploy1.codempmt%type;
		v_dteduepr		            temploy1.dteduepr%type;
		codcur			            ttmovemt.codcurr%type;
		tmp_amount		            number;
		v_amtincom		            number;
		v_amtincadj		            number;
		v_amtmax		            number;
		v_tsecpos_dteeffec	        tsecpos.dteeffec%type;
		v_staemp		            temploy1.staemp%type;
		vcodcalen		            temploy1.codcalen%type;
		vnumreqst		            temploy1.numreqst%type;
		vcodedlv		            temploy1.codedlv%type;
		vcodsex			            temploy1.codsex%type;
		vtypemp			            temploy1.typemp%type;
		vjobgrade		            temploy1.jobgrade%type;
		vcodgrpgl		            temploy1.codgrpgl%type;
		vdteefpos		            temploy1.dteefpos%type;
		vdteeflvl		            temploy1.dteeflvl%type;
		v_codempid		            temploy1.codempid%type;
		v_tsecpos_codcomp	        tsecpos.codcomp%type;
		v_tsecpos_codpos	        tsecpos.codpos%type;
		v_tsecpos_codjob	        tsecpos.codjob%type;
		v_tsecpos_codbrlc	        tsecpos.codbrlc%type;
		v_tsecpos_numlvl	        tsecpos.numlvl%type;
		v_index_amt		            number;
		v_count_data		        number;
		v_ttmovemtdteeffecold	    date;
		v_count_temp_ttmovement	    number;
		v_count_codempid	        number;
        v_seqcancel                 tsecpos.seqcancel%type;
		v_ttmovemt_amtincom1	    ttmovemt.amtincom1%type := null;
		v_ttmovemt_amtincom2	    ttmovemt.amtincom2%type := null;
		v_ttmovemt_amtincom3	    ttmovemt.amtincom3%type := null;
		v_ttmovemt_amtincom4	    ttmovemt.amtincom4%type := null;
		v_ttmovemt_amtincom5	    ttmovemt.amtincom5%type := null;
		v_ttmovemt_amtincom6	    ttmovemt.amtincom6%type := null;
		v_ttmovemt_amtincom7	    ttmovemt.amtincom7%type := null;
		v_ttmovemt_amtincom8	    ttmovemt.amtincom8%type := null;
		v_ttmovemt_amtincom9	    ttmovemt.amtincom9%type := null;
		v_ttmovemt_amtincom10	    ttmovemt.amtincom10%type := null;

		v_ttmovemt_amtincadj1	    ttmovemt.amtincadj1%type;
		v_ttmovemt_amtincadj2	    ttmovemt.amtincadj2%type;
		v_ttmovemt_amtincadj3	    ttmovemt.amtincadj3%type;
		v_ttmovemt_amtincadj4	    ttmovemt.amtincadj4%type;
		v_ttmovemt_amtincadj5	    ttmovemt.amtincadj5%type;
		v_ttmovemt_amtincadj6	    ttmovemt.amtincadj6%type;
		v_ttmovemt_amtincadj7	    ttmovemt.amtincadj7%type;
		v_ttmovemt_amtincadj8	    ttmovemt.amtincadj7%type;
		v_ttmovemt_amtincadj9	    ttmovemt.amtincadj9%type;
		v_ttmovemt_amtincadj10	    ttmovemt.amtincadj10%type;

        v_approvno                  ttmovemt.approvno%type;
        v_checkapp                  boolean := false;
        v_check                     varchar2(500 char);
        p_indexSelecteNumseq        number;
        v_flgadjin                  ttmovemt.flgadjin%type;

        v_out_obj json_object_t;
	begin
		init_save(json_str_input);

		begin
			json_obj                := json_object_t(json_str_input);
			v_tsecpos_dteeffec      := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');
			v_codempid              := hcm_util.get_string_t(json_obj,'v_codempid');
			p_dtecancel             := to_date(hcm_util.get_string_t(json_obj,'p_dtecancel'),'ddmmyyyy');
			v_ttmovemtdteeffecold   := to_date(hcm_util.get_string_t(json_obj,'ttmovemtdteeffec'),'ddmmyyyy');
            v_seqcancel             := to_number(hcm_util.get_string_t(json_obj,'p_seqcancel'));
			p_indexSelecteNumseq    := to_number(hcm_util.get_string_t(json_obj,'p_indexSelecteNumseq'));
            -- Validation date
			if p_dtecancel is null then
				param_msg_error     := get_error_msg_php('HR2045',global_v_lang);
				json_str_output     := get_response_message(null,param_msg_error,global_v_lang);
				return;
			end if;
			if v_tsecpos_dteeffec > p_dtecancel then
				param_msg_error     := get_error_msg_php('PM0034',global_v_lang);
				json_str_output     := get_response_message(null,param_msg_error,global_v_lang);
				return;
			end if;
			-- Validation employee status

			begin
				select count(*)
                  into v_count_codempid
				  from temploy1
				 where codempid = v_codempid;
			end;
			if (v_count_codempid = 0) then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
				json_str_output := get_response_message(null,param_msg_error,global_v_lang);
				return;
			end if;

			begin
				select dteduepr,flgatten,codcalen,numreqst,codedlv,codsex,typemp,jobgrade,codgrpgl,dteefpos,dteeflvl
				  into v_dteduepr, v_flgatten,vcodcalen,vnumreqst,vcodedlv,vcodsex,vtypemp,vjobgrade,vcodgrpgl,vdteefpos,vdteeflvl
				  from temploy1
				 where codempid = v_codempid;
			end;
			begin
				select staemp
                  into v_staemp
				  from temploy1
				 where codempid = v_codusershow;
			end;

			if (v_staemp = '9') then
				param_msg_error := get_error_msg_php('HR2101',global_v_lang);
				json_str_output := get_response_message(null,param_msg_error,global_v_lang);
				return;
			elsif (v_staemp = '0') then
				param_msg_error := get_error_msg_php('HR2102',global_v_lang);
				json_str_output := get_response_message(null,param_msg_error,global_v_lang);
				return;
			end if;
			if v_codempid is not null then
				begin
					select codcomp,codempmt
					  into p_codcomp,v_codempmt
					  from temploy1
					 where codempid = v_codempid;
				exception when no_data_found then
					p_codcomp   := null;
					v_codempmt  := null;
				end;
			end if;

            v_checkapp := chk_flowmail.check_approve ('HRPM4CE', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
            IF NOT v_checkapp AND v_check = 'HR2010' THEN
                param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
                json_str_output := Get_response_message('400', param_msg_error, global_v_lang);
                return;
            END IF;

			begin
				select codcompy
				  into v_codcompy
				  from tcenter
				 where codcomp = p_codcomp;
			exception when no_data_found then
				v_codcompy := null;
			end;
			v_json_input    := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmt||'","p_lang":"'||global_v_lang||'"}';
			v_json_codincom := hcm_pm.get_codincom(v_json_input);

			param_json_codincome := json_object_t(v_json_codincom);
			if param_msg_error is null then

				obj_row             := json_object_t();
				param_json          := hcm_util.get_json_t(json_obj,'param_json');
				param_json_table    := hcm_util.get_json_t(param_json,'rows');

				init_amtincom (
                    param_json_table,
                    v_codempid,
                    v_ttmovemt_amtincom1,
                    v_ttmovemt_amtincom2,
                    v_ttmovemt_amtincom3,
                    v_ttmovemt_amtincom4,
                    v_ttmovemt_amtincom5,
                    v_ttmovemt_amtincom6,
                    v_ttmovemt_amtincom7,
                    v_ttmovemt_amtincom8,
                    v_ttmovemt_amtincom9,
                    v_ttmovemt_amtincom10);
				init_amtincadj (
                    param_json_table,
                    v_codempid,
                    v_ttmovemt_amtincadj1,
                    v_ttmovemt_amtincadj2,
                    v_ttmovemt_amtincadj3,
                    v_ttmovemt_amtincadj4,
                    v_ttmovemt_amtincadj5,
                    v_ttmovemt_amtincadj6,
                    v_ttmovemt_amtincadj7,
                    v_ttmovemt_amtincadj8,
                    v_ttmovemt_amtincadj9,
                    v_ttmovemt_amtincadj10);

				for i in 1..param_json_table.get_size loop
					param_json_row  := hcm_util.get_json_t(param_json_table,i-1);

					v_amtincom      := to_number(hcm_util.get_string_t(param_json_row,'amtincom'));
					v_amtincadj     := to_number(hcm_util.get_string_t(param_json_row,'amtincadj'));
					v_amtmax        := to_number(hcm_util.get_string_t(param_json_row,'amount')) ;
					tmp_amount      := get_amtmax_by_codincome(param_json_codincome,hcm_util.get_string_t(param_json_row,'codincom') );

					if (tmp_amount is not null and v_amtmax > 0) then
						if v_amtmax > tmp_amount then
							param_msg_error := get_error_msg_php('PM0066',global_v_lang);
							json_str_output := get_response_message('400',param_msg_error,global_v_lang);
							return;
						end if;
					end if;
				end loop;
				begin
					select codcurr
                      into codcur
                      from temploy3
                     where codempid = v_codempid;

					select codcomp,codpos,codjob,codbrlc,numlvl
					  into v_tsecpos_codcomp,v_tsecpos_codpos,v_tsecpos_codjob,v_tsecpos_codbrlc,v_tsecpos_numlvl
					  from tsecpos
					 where codempid = v_codempid
					   and dteeffec = v_tsecpos_dteeffec
					   and numseq = p_indexSelecteNumseq;

					update ttmovemt
					   set dtecancel = p_dtecancel,
					       coduser = global_v_coduser,
                           dteupd = sysdate
					 where codempid = v_codempid
					   and dteeffec = v_ttmovemtdteeffecold
					   and numseq = v_seqcancel;

					select count(*)
                      into v_count_temp_ttmovement
					  from ttmovemt
					 where codempid = v_codempid
					   and dteeffec = v_ttmovemtdteeffecold
					   and numseq = v_seqcancel;

					if (v_count_temp_ttmovement > 0 ) then
                       delete
                         from ttmovemt
						where codempid = v_codempid
						  and dteeffec = v_ttmovemtdteeffecold
						  and numseq = v_seqcancel;
					end if;
					p_numseq := get_max_running(v_codempid,p_dtecancel) ;

                --<<  Final Test Phase 1 V11 #5560
                      if (  nvl(stddec(v_ttmovemt_amtincadj1,  v_codempid,v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj2, v_codempid, v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj3, v_codempid, v_chken),0) <> 0 or
                            nvl(stddec(v_ttmovemt_amtincadj4,  v_codempid, v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj5, v_codempid, v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj6, v_codempid, v_chken),0) <> 0 or
                            nvl(stddec(v_ttmovemt_amtincadj7,  v_codempid, v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj8, v_codempid, v_chken),0) <> 0 or nvl(stddec(v_ttmovemt_amtincadj9, v_codempid, v_chken),0) <> 0 or
                            nvl(stddec(v_ttmovemt_amtincadj10, v_codempid,v_chken),0)<> 0 ) then
                            v_flgadjin := 'Y';
                     else
                            v_flgadjin := 'N';
                     end if;
                   -->>  Final Test Phase 1 V11 #5560

					insert
                      into ttmovemt (   codempid, dteeffec, numseq,
                                        codtrn, codcomp, codpos,
                                        codjob, numlvl, codbrlc, flgatten,
                                        codcompt, codposnow, codjobt,
                                        numlvlt, codbrlct, desnote,
                                        amtincom1, amtincom2,
                                        amtincom3, amtincom4,
                                        amtincom5, amtincom6,
                                        amtincom7, amtincom8,
                                        amtincom9, amtincom10,
                                        amtincadj1, amtincadj2,
                                        amtincadj3, amtincadj4,
                                        amtincadj5, amtincadj6,
                                        amtincadj7, amtincadj8,
                                        amtincadj9, amtincadj10,
                                        coduser,codcreate,dtecreate,
                                        staupd,codcalen,numreqst,
                                        codedlv,codsex,typemp,
                                        jobgrade,codgrpgl,dteefpos,
                                        dteeflvl,codcurr,dteduepr,codreq,
                                        flgadjin
                                        )
					values (            v_codempid, p_dtecancel,p_numseq,
                                        p_codtrn,v_tsecpos_codcomp,v_tsecpos_codpos ,
                                        v_tsecpos_codjob, v_tsecpos_numlvl, v_tsecpos_codbrlc,
                                        v_flgatten,
                                        p_codcomp, p_codpos, p_codjob,
                                        p_numlvl, p_codbrlc, p_desnote,
                                        v_ttmovemt_amtincom1,v_ttmovemt_amtincom2, v_ttmovemt_amtincom3,
                                        v_ttmovemt_amtincom4 , v_ttmovemt_amtincom5,v_ttmovemt_amtincom6,
                                        v_ttmovemt_amtincom7, v_ttmovemt_amtincom8, v_ttmovemt_amtincom9,
                                        v_ttmovemt_amtincom10 ,
                                        v_ttmovemt_amtincadj1,v_ttmovemt_amtincadj2,v_ttmovemt_amtincadj3,
                                        v_ttmovemt_amtincadj4,v_ttmovemt_amtincadj5,v_ttmovemt_amtincadj6,
                                        v_ttmovemt_amtincadj7,v_ttmovemt_amtincadj8,v_ttmovemt_amtincadj9,
                                        v_ttmovemt_amtincadj10,
                                        global_v_coduser,global_v_coduser,sysdate,
                                        'P',vcodcalen,vnumreqst,
                                        vcodedlv,vcodsex,vtypemp,
                                        vjobgrade,vcodgrpgl,vdteefpos,
                                        vdteeflvl,codcur,v_dteduepr,v_codusershow,
                                        v_flgadjin
                                        );

                    update tsecpos
					   set seqcancel = p_numseq,
                           dtecancel = p_dtecancel,
					       coduser = global_v_coduser
					 where codempid = v_codempid
					   and dteeffec = v_tsecpos_dteeffec
					   and numseq = p_indexSelecteNumseq;
				end ;
				commit;
			end if;
		end ;

        v_out_obj := json_object_t();
        v_out_obj.put('coderror', '200');
        v_out_obj.put('response',get_msgerror('HR2401',global_v_lang));
        v_out_obj.put('lasttsecposdtecancel',to_char(p_dtecancel,'dd/mm/yyyy'));
        v_out_obj.put('lasttsecposseqcancel',p_numseq);

		json_str_output := v_out_obj.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end post_save;

	procedure init_amtincom (
		v_listof_getincome	    in json_object_t,
		v_codempid		        in varchar2,
		v_ttmovemt_amtincom1	out ttmovemt.amtincom1%type,
		v_ttmovemt_amtincom2	out ttmovemt.amtincom2%type,
		v_ttmovemt_amtincom3	out ttmovemt.amtincom3%type,
		v_ttmovemt_amtincom4	out ttmovemt.amtincom4%type,
		v_ttmovemt_amtincom5	out ttmovemt.amtincom5%type,
		v_ttmovemt_amtincom6	out ttmovemt.amtincom6%type,
		v_ttmovemt_amtincom7	out ttmovemt.amtincom7%type,
		v_ttmovemt_amtincom8	out ttmovemt.amtincom8%type,
		v_ttmovemt_amtincom9	out ttmovemt.amtincom9%type,
		v_ttmovemt_amtincom10	out ttmovemt.amtincom10%type) as
		v_size			        number;
		v_item_getincome	    json_object_t;
		v_item_index		    varchar2(10 char);
		v_item_amtincom		    number;
	begin
		v_size := v_listof_getincome.get_size;

		for i in 1.. v_size loop
			v_item_getincome := hcm_util.get_json_t(v_listof_getincome,i-1);
			v_item_index := hcm_util.get_string_t(v_item_getincome,'rowIndex');
			v_item_amtincom := to_number(replace(hcm_util.get_string_t(v_item_getincome,'amount'),',',''));
			if (v_item_index = '1') then
				v_ttmovemt_amtincom1 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '2') then
				v_ttmovemt_amtincom2 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '3') then
				v_ttmovemt_amtincom3 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '4') then
				v_ttmovemt_amtincom4 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '5') then
				v_ttmovemt_amtincom5 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '6') then
				v_ttmovemt_amtincom6 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '7') then
				v_ttmovemt_amtincom7 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '8') then
				v_ttmovemt_amtincom8 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '9') then
				v_ttmovemt_amtincom9 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '10') then
				v_ttmovemt_amtincom10 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			end if;
		end loop;

	end init_amtincom;

	procedure init_amtincadj (
		v_listof_getincome	    in json_object_t,
		v_codempid		        in varchar2,
		v_ttmovemt_amtincadj1	out ttmovemt.amtincadj1%type,
		v_ttmovemt_amtincadj2	out ttmovemt.amtincadj2%type,
		v_ttmovemt_amtincadj3	out ttmovemt.amtincadj3%type,
		v_ttmovemt_amtincadj4	out ttmovemt.amtincadj4%type,
		v_ttmovemt_amtincadj5	out ttmovemt.amtincadj5%type,
		v_ttmovemt_amtincadj6	out ttmovemt.amtincadj6%type,
		v_ttmovemt_amtincadj7	out ttmovemt.amtincadj7%type,
		v_ttmovemt_amtincadj8	out ttmovemt.amtincadj7%type,
		v_ttmovemt_amtincadj9	out ttmovemt.amtincadj9%type,
		v_ttmovemt_amtincadj10	out ttmovemt.amtincadj10%type) as
		v_size			        number;
		v_item_getincome	    json_object_t;
		v_item_index		    varchar2(10 char);
		v_item_amtincom		    number;
	begin

		v_size := v_listof_getincome.get_size;
		for i in 1.. v_size loop
			v_item_getincome    := hcm_util.get_json_t(v_listof_getincome,i-1);
			v_item_index        := hcm_util.get_string_t(v_item_getincome,'rowIndex');
			v_item_amtincom     := to_number(hcm_util.get_string_t(v_item_getincome,'amtincadj'));

			if (v_item_index = '1') then
				v_ttmovemt_amtincadj1 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '2') then
				v_ttmovemt_amtincadj2 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '3') then
				v_ttmovemt_amtincadj3 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '4') then
				v_ttmovemt_amtincadj4 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '5') then
				v_ttmovemt_amtincadj5 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '6') then
				v_ttmovemt_amtincadj6 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '7') then
				v_ttmovemt_amtincadj7 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '8') then
				v_ttmovemt_amtincadj8 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '9') then
				v_ttmovemt_amtincadj9 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			elsif (v_item_index = '10') then
				v_ttmovemt_amtincadj10 := stdenc(v_item_amtincom, v_codempid, global_v_chken);
			end if;
		end loop;
	end init_amtincadj;

	procedure init_delete(json_str_input in clob) as
		json_obj		json_object_t;
	begin
		v_chken                     := hcm_secur.get_v_chken;
		json_obj                    := json_object_t(json_str_input);
		--global
		global_v_coduser            := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd            := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang               := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning           := hcm_util.get_string_t(json_obj,'p_lrunning');
		global_v_codempid           := hcm_util.get_string_t(json_obj,'p_codempid');
		-- delete
		v_codempid                  := upper(hcm_util.get_string_t(json_obj,'v_codempid'));
		p_codcomp                   := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
		p_codpos                    := upper(hcm_util.get_string_t(json_obj,'p_codpos'));
		p_indexSelectedDtecancel    := to_date(hcm_util.get_string_t(json_obj,'p_indexSelectedDtecancel'), 'ddmmyyyy');
		p_indexselectenumseq        := hcm_util.get_string_t(json_obj,'p_indexSelecteNumseq');
		p_codtrn                    := hcm_util.get_string_t(json_obj,'p_codtrn');
		p_dtecancel                 := to_date(hcm_util.get_string_t(json_obj,'p_dtecancel'),'ddmmyyyy');
		p_numseq                    := hcm_util.get_string_t(json_obj,'p_numseq');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure post_delete (json_str_input in clob, json_str_output out clob) as
		v_tsecpos_dteeffec	tsecpos.dteeffec%type;
		json_obj		    json_object_t;
	begin

		init_delete(json_str_input);
		json_obj            := json_object_t(json_str_input);
		v_tsecpos_dteeffec  := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');

		delete ttmovemt
		 where codempid = v_codempid
		   and dteeffec = p_dtecancel
		   and numseq = p_numseq;

		delete ttpminf
		 where codempid = v_codempid
		   and dteeffec = p_dtecancel
		   and codtrn = p_codtrn
		   and numseq = p_numseq;

		update tsecpos
		   set dtecancel = null,
               seqcancel = null,
               coduser = global_v_coduser
		 where codempid = v_codempid
		   and dteeffec = v_tsecpos_dteeffec
		   and numseq = p_indexselectenumseq;

		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2 is
		v_descripe		terrorm.descripe%type;
	begin
		begin
			SELECT decode(v_lang ,
                    '101',descripe,
                    '102',descript,
                    '103',descrip3,
                    '104',descrip4,
                    '105',descrip5,descripe)
			  into v_descripe
			  from terrorm
			 where errorno = v_errorno;

			return v_errorno||' '||v_descripe;
		exception
		when no_data_found then
			return '';
		when others then
			return '';
		end;
	end get_msgerror;

	procedure init_send_mail (json_str_input in clob) as
		json_obj		json_object_t;
	begin

		v_chken                     := hcm_secur.get_v_chken;
		json_obj                    := json_object_t(json_str_input);
		--global
		global_v_coduser            := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid           := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_codpswd            := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang               := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning           := hcm_util.get_string_t(json_obj,'p_lrunning');

		--sendmail
		p_mode                      := hcm_util.get_string_t(json_obj,'p_mode');
		p_codtrn                    := hcm_util.get_string_t(json_obj,'p_codtrn');
		p_desnote                   := hcm_util.get_string_t(json_obj,'p_desnote');
		p_numseq                    := hcm_util.get_string_t(json_obj,'p_numseq');
		p_codjob                    := hcm_util.get_string_t(json_obj,'p_codjob');
		p_codbrlc                   := hcm_util.get_string_t(json_obj,'p_codbrlc');
		p_numlvl                    := hcm_util.get_string_t(json_obj,'p_numlvl');
		p_codcurr                   := hcm_util.get_string_t(json_obj,'p_codcurr');
		v_codempid                  := hcm_util.get_string_t(json_obj,'v_codempid');
		p_codcomp                   := hcm_util.get_string_t(json_obj,'p_codcomp');
		p_codpos                    := hcm_util.get_string_t(json_obj,'p_codpos');
		p_codjob                    := hcm_util.get_string_t(json_obj,'p_codjob');
		p_codbrlc                   := hcm_util.get_string_t(json_obj,'p_codbrlc');
		p_numlvl                    := hcm_util.get_string_t(json_obj,'p_numlvl');
		p_seqcancel                 := hcm_util.get_string_t(json_obj,'p_seqcancel');
		p_indexselectenumseq        := hcm_util.get_string_t(json_obj,'p_indexSelecteNumseq');
		p_indexSelectedDtecancel    := to_date(hcm_util.get_string_t(json_obj,'p_indexSelectedDtecancel'), 'ddmmyyyy');
		p_dtecancel                 := to_date(hcm_util.get_string_t(json_obj,'p_dtecancel'),'ddmmyyyy');
		v_codusershow               := hcm_util.get_string_t(json_obj,'v_codusershow');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

	end init_send_mail;

	procedure post_sendmail(json_str_input in clob, json_str_output out clob) as
	begin
		init_send_mail(json_str_input);
		validate_send_mail(json_str_input);
		if (param_msg_error <> ' ' or param_msg_error is not null) then
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		else
			send_mail(json_str_input,json_str_output);
		end if;
	end post_sendmail;

	procedure validate_send_mail(json_str_input in clob) as
		objJson			    json_object_t;
		tmp			        number;
		v_tsecpos_dteeffec	tsecpos.dteeffec%type;
		v_staemp		    temploy1.staemp%type;
	begin
		objJson             := json_object_t(json_str_input);
		v_tsecpos_dteeffec  := to_date(hcm_util.get_string_t(objJson,'p_dteeffec'),'ddmmyyyy');
		begin
			select rowId
			  into v_rowid
			  from ttmovemt
			 where codempid = v_codempid
			   and dteeffec = p_dtecancel
			   and numseq = p_indexselectenumseq;
		exception when no_data_found then
			v_rowid := null;
		end;
		if v_rowid is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		if p_codtrn is null or p_codtrn= ' ' then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		if p_dtecancel is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		if p_dtecancel < v_tsecpos_dteeffec then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		begin
			select staemp into v_staemp
			  from temploy1
			 where codempid = v_codusershow;
		end;

		if v_staemp = 9 then
			param_msg_error := get_error_msg_php('HR2101',global_v_lang);
			return;
		elsif v_staemp = 0 then
			param_msg_error := get_error_msg_php('HR2102',global_v_lang);
			return;
		end if;
	end validate_send_mail;

	PROCEDURE send_mail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		v_codfrm_to		tfwmailh.codform%TYPE;

		v_msg_to        clob;
		v_template_to   clob;
		v_func_appr		tfwmailh.codappap%type;
		v_error			VARCHAR2(10 CHAR);
        v_approvno      TTMOVEMT.approvno%type;
	BEGIN
        begin
            select nvl(approvno,0) + 1
              into v_approvno
              from TTMOVEMT
             where rowid = v_rowid;
        exception when no_data_found then
            v_approvno := 1;
        end;

        v_error := chk_flowmail.send_mail_for_approve('HRPM4CE', v_codempid,v_codusershow, global_v_coduser, null, 'HRPM44U1', 960, 'E', 'P', v_approvno, null, null,'TTMOVEMT',v_rowid, '1', null);
        --Alert Error เธ—เธตเนเนเธ”เนเธเธฒเธ? Package chk_flowmail

		IF v_error = '2046' THEN
			v_error := 'HR2046';
		ELSE ---7525
			v_error := 'HR7522';
		END IF;
		param_msg_error := get_error_msg_php(v_error,global_v_lang);
		json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
	END send_mail;

	function get_amtmax_by_codincome (obj_row_codincome in json_object_t,v_item_codincom in varchar2) return number is
		v_item_codincome	json_object_t;
		v_tmp_amtmax		number;
	begin
		for i in 0..obj_row_codincome.get_size-1
			loop
				v_item_codincome := hcm_util.get_json_t(obj_row_codincome,to_char(i));
				v_tmp_amtmax := hcm_util.get_number_t(v_item_codincome, 'amtmax');
				if ( hcm_util.get_string_t(v_item_codincome,'codincom') = v_item_codincom) then
					return v_tmp_amtmax ;
				end if;
			end loop;
			return null;
		end get_amtmax_by_codincome;

	function get_clob(str_json in clob,key_json in varchar2) RETURN CLOB is
		jo			JSON_OBJECT_T;
	begin
		jo := JSON_OBJECT_T.parse(str_json);
		return jo.get_clob(key_json);
	end get_clob;

	function get_max_running(v_codempid in varchar, v_dtecancel in date) return number is
		v_max			number;
	begin
		select max(numseq) into v_max
		  from ttmovemt
		 where codempid = v_codempid
		   and dteeffec = v_dtecancel;

		v_max := nvl(v_max,0) + 1 ;
		return v_max;
	end get_max_running;

end HRPM4CE;

/
