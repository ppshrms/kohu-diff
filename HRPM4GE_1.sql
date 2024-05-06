--------------------------------------------------------
--  DDL for Package Body HRPM4GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4GE" is
	-- last update: 1/10/2019

	procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		v_chken             := hcm_secur.get_v_chken;
		json_obj            := json_object_t(json_str);
		--global
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

		-- index
		p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));
		p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
		p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'), 'dd/mm/yyyy');
		p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'dd/mm/yyyy');
		--detail table
		p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'dd/mm/yyyy');

	end initial_value;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		    boolean;
		tmp			        number;
		v_numlvl		    VARCHAR2(100);
		v_codcomp_empid		VARCHAR2(100);
        v_flgsecur          VARCHAR2(100);
	begin
		if p_codempid is null and p_codcomp is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codempid');
			return;
		end if;
        if p_codcomp is not null then
            v_flgsecur := hcm_secur.secur_main7(p_codcomp,global_v_coduser);
            if v_flgsecur = 'N' then
                param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                return;
            end if;
        end if;

		if (p_codempid is not null) then
			begin
				select staemp,numlvl,codcomp
				  into tmp,v_numlvl,v_codcomp_empid
				  from temploy1
				 where codempid = p_codempid;

				if(tmp = 0) then
					param_msg_error := get_error_msg_php('HR2102',global_v_lang,'Temploy1');
					return;
				elsif(tmp = 9) then
					param_msg_error := get_error_msg_php('HR2101',global_v_lang,'Temploy1');
					return;
				end if;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'Temploy1');
				return;
			end;

            chk_bool := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

--			chk_bool := secur_main.secur1(p_codempid,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
			if(not chk_bool) then
				param_msg_error := get_error_msg_php('HR3007',global_v_lang, v_numlvl);
				return;
			end if;
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
		p_codcompid		varchar2( 100 char);
		v_folder		varchar2( 100 char) := '';
        --<<User37 #2764 Final Test Phase 1 V11 02/02/2021
        v_chksecur      boolean;
        v_secur         varchar2(1 char) := 'N';
        -->>User37 #2764 Final Test Phase 1 V11 02/02/2021

		cursor c_ttmistk is
		select codreq,dtemistk,codmist,codempid,dteeffec,desmist1,numhmref,refdoc,
               add_months(dtecreate,6516) as dtecreate,
               decode(staupd,'C','Y',staupd) staupd ,codcreate
		  from ttmistk
		 where codempid = nvl(p_codempid,codempid)
           and codcomp like p_codcomp||'%'
           and dteeffec between p_dtestr and p_dteend
      order by codempid,dteeffec desc ;
	begin
		obj_row := json_object_t();
		begin
			select folder into v_folder from tfolderd where codapp = 'HRPM4GE';
		EXCEPTION WHEN NO_DATA_FOUND then
			v_folder := '';
		end;
		for r1 in c_ttmistk loop
			--<<User37 #2764 Final Test Phase 1 V11 02/02/2021
            v_chksecur    := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_chksecur then
                v_secur := 'Y';
            -->>User37 #2764 Final Test Phase 1 V11 02/02/2021
                obj_data := json_object_t();
                v_rcnt := v_rcnt + 1;

                obj_data.put('coderror', '200');
                obj_data.put('rownumber', v_rcnt);
                obj_data.put('dtemistk', to_char(r1.dtemistk,'dd/mm/yyyy'));
                obj_data.put('codmist',get_tcodec_name('TCODMIST', r1.codmist,global_v_lang));
                obj_data.put('image', get_emp_img (r1.codempid));
                obj_data.put('codempid', r1.codempid);
                obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
                obj_data.put('desmist1', r1.desmist1);
                obj_data.put('codreq', r1.codreq);
                obj_data.put('numhmref', r1.numhmref);
                obj_data.put('refdoc', r1.refdoc);
                obj_data.put('folder', v_folder);
                obj_data.put('dtecreate', r1.dtecreate);
                obj_data.put('coduser', r1.codcreate);
                obj_data.put('coduserShow', get_codempid(r1.codcreate));
                obj_data.put('staupd', get_tlistval_name('STAAPPR', r1.staupd, global_v_lang));
                obj_data.put('flgstaupd',r1.staupd);--User37 #2762 Final Test Phase 1 V11 02/02/2021

                obj_row.put(to_char(v_rcnt - 1), obj_data);
            end if;
        end loop;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	end;

	procedure getIndexSelect (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		genIndexSelect(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genIndexSelect (json_str_output out clob) as
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			number := 0;
		v_folder		varchar2( 100 char) := '';
		p_codcompid		varchar2( 100 char);
		is_found_rec	boolean := false;
		chk_bool		boolean := true;
		cursor c_ttmistk2 is
		select codreq,rowid,staupd,dtemistk,codmist,codempid,dteeffec,desmist1,numhmref,refdoc,dtecreate as dtecreate
		  from ttmistk
		 where codempid = p_codempid
		   and dteeffec = p_dteeffec;
	begin
		begin
			select folder
              into v_folder
              from tfolderd
             where codapp = 'HRPM4GE';
		exception when no_data_found then
			v_folder := '';
		end;
		obj_row     := json_object_t();
		chk_bool    := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
		for r1 in c_ttmistk2 loop
			if (chk_bool) then
				obj_data := json_object_t();
				v_rcnt := v_rcnt + 1;
				is_found_rec := true;
				obj_data.put('coderror', '200');
				obj_data.put('rownumber', v_rcnt);
				obj_data.put('dtemistk', to_char(r1.dtemistk,'dd/mm/yyyy'));
				obj_data.put('codmist', r1.codmist);
				obj_data.put('codempid', r1.codempid);
				obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
				obj_data.put('desmist1', r1.desmist1);
				obj_data.put('numhmref', r1.numhmref);
				obj_data.put('refdoc', r1.refdoc);
				obj_data.put('mode', 'edit');
				obj_data.put('folder', v_folder);
				obj_data.put('dtecreate', to_char(r1.dtecreate,'dd/mm/yyyy'));
				obj_data.put('coduser', global_v_coduser);
				obj_data.put('coduserShow', r1.codreq);
				obj_data.put('secur2', v_zupdsal);
				obj_data.put('staupd', r1.staupd);
				obj_data.put('codreq', r1.codreq);
				obj_data.put('v_rowid', r1.rowid);
--				if (r1.STAUPD = 'C' or r1.STAUPD = 'U') then
				if r1.STAUPD <> 'P'  then
					obj_data.put('error',get_msgerror('HR1490',global_v_lang));
				else
					obj_data.put('error','');
				end if;
				obj_row.put(to_char(v_rcnt - 1), obj_data);
			end if;

		end loop;
		if not is_found_rec then
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('dtemistk', '');
			obj_data.put('codmist', '');
			obj_data.put('codempid', '');
			obj_data.put('dteeffec', '');
			obj_data.put('desmist1', '');
			obj_data.put('numhmref', '');
			obj_data.put('mode', 'add');
			obj_data.put('refdoc', '');
			obj_data.put('folder', '');
			obj_data.put('dtecreate', to_char(sysdate,'dd/mm/yyyy'));
			obj_data.put('coduser', global_v_coduser);
			obj_data.put('secur2', v_zupdsal);
			obj_data.put('coduserShow', get_codempid(global_v_coduser));
			obj_row.put(0, obj_data);
		end if;
		json_str_output := obj_row.to_clob;
	end;

	procedure getDetail (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
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
		is_found_rec	boolean := false;
		v_staemp		temploy1.staemp%type;
        flgsecur        boolean;
        v_zupdsal       varchar2(4 char);

		cursor c_ttpunsh is
            select *
              from ttpunsh
             where codempid = p_codempid
               and dteeffec = p_dteeffec
          order by numseq;

	begin
        flgsecur := secur_main.secur2(p_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

		obj_row := json_object_t();
		for r1 in c_ttpunsh loop
			obj_data        := json_object_t();
			v_rcnt          := v_rcnt + 1;
			is_found_rec    := true;
			obj_data.put('coderror', '200');
			obj_data.put('rownumber', v_rcnt);
			obj_data.put('codpunsh', r1.codpunsh);
			obj_data.put('codpunshold', r1.codpunsh);
			obj_data.put('dtestart', to_char(r1.dtestart,'dd/mm/yyyy'));
			obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
			obj_data.put('flgexempt', r1.flgexempt);
			obj_data.put('typpun', r1.typpun);
			obj_data.put('flgssm', r1.flgssm);
			obj_data.put('numseq', r1.numseq);
			obj_data.put('codexem', r1.codexemp);
			obj_data.put('flagcheck', 'Y');
			obj_data.put('flgbist', r1.flgblist);
			obj_data.put('remark', r1.remark);
			obj_data.put('mode', 'edit');
            obj_data.put('v_zupdsal', v_zupdsal);
			obj_row.put(to_char(v_rcnt - 1), obj_data);
		end loop;
		if not is_found_rec then
            begin
                select staemp
                  into v_staemp
                  from temploy1
                 where codempid = p_codempid;
                if (v_staemp = '9') then
                    param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                    return;
                elsif (v_staemp = '0') then
                    param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                    return;
                end if;
            end;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('rownumber', '0');
			obj_data.put('codpunsh', '');
			obj_data.put('codpunshold','');
			obj_data.put('dtestart', '');
			obj_data.put('numseq', '1');
			obj_data.put('dteend', '');
			obj_data.put('flgexempt', 'N');
			obj_data.put('typpun', '0');
			obj_data.put('flgbist', 'N');
			obj_data.put('remark', '');
			obj_data.put('codexem', '');
			obj_data.put('flagcheck', 'N');
			obj_data.put('mode', 'add');
            obj_data.put('v_zupdsal', v_zupdsal);
			obj_data.put('numprdst', '1');
			obj_data.put('numprden', '1');
			obj_data.put('dtemthst', to_char(sysdate,'mm'));
			obj_data.put('dtemthen', to_char(sysdate,'mm'));

			obj_data.put('dteyearst', to_char(sysdate,'yyyy'));
			obj_data.put('dteyearen', to_char(sysdate,'yyyy'));
			obj_row.put(0, obj_data);
		end if;
		dbms_lob.createtemporary(json_str_output, true);
		obj_row.to_clob(json_str_output);
	end;

	procedure calTotal (json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		json_obj		        json_object_t;
		v_ttpunded              ttpunded%rowtype;
		v_gen_totalchange	    number;
		v_gen_salary		    json_object_t;
		type			        p_num is table of number index by binary_integer;
		v_amtincom              p_num;
		v_amtincadj             p_num;
		v_amtincded             p_num;
        v_amtincadjOld          p_num;
		v_amtincdedOld          p_num;
		v_item_gen_salary	    json_object_t;

		v_periodstr             varchar(20 char);
		v_periodend             varchar(20 char);
		v_suminperiod		    number := 0 ;
		v_sumperiod		        number := 0 ;
		gen_codcomp		        temploy1.codcomp%type;
		gen_typpayroll		    temploy1.typpayroll%type;
		v_count			        number;
		obj_sum			        json_object_t;
		iscalculate_amtincadj	boolean;
		v_size_salary		    number;
		v_out_obj_item		    json_object_t;
		v_out_obj_row		    json_object_t;
	begin
		json_obj                := json_object_t(json_str_input);
		global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
		v_ttpunded.numprdst     := to_number(hcm_util.get_string_t(json_obj,'gen_numprdst'));
		v_ttpunded.dtemthst     := to_number(hcm_util.get_string_t(json_obj,'gen_dtemthst'));
		v_ttpunded.dteyearst    := to_number(hcm_util.get_string_t(json_obj,'gen_dteyearst'));
		v_ttpunded.numprden     := to_number(hcm_util.get_string_t(json_obj,'gen_numprden'));
		v_ttpunded.dtemthen     := to_number(hcm_util.get_string_t(json_obj,'gen_dtemthen'));
		v_ttpunded.dteyearen    := to_number(hcm_util.get_string_t(json_obj,'gen_dteyearen'));
		v_ttpunded.codpay       := hcm_util.get_string_t(json_obj,'gen_codpay');
		v_ttpunded.codempid     := hcm_util.get_string_t(json_obj, 'gen_codempid');
		v_ttpunded.dteeffec     := to_date(hcm_util.get_string_t(json_obj,'gen_dteeffec'), 'dd/mm/yyyy');
		v_gen_totalchange       := to_number(hcm_util.get_string_t(json_obj,'gen_totalchange'));
		v_gen_salary            := hcm_util.get_json_t(json_obj,'gen_salary');
		v_size_salary           := v_gen_salary.get_size;

		iscalculate_amtincadj   := calculate_amtincadj(v_gen_salary);
		v_out_obj_row           := json_object_t();

		for i in 1..10 loop
			v_amtincom(i)   := 0;
			v_amtincadj(i)  := 0;
			v_amtincded(i)  := 0;
		end loop;
		for i in 1..v_size_salary loop
			v_item_gen_salary   := hcm_util.get_json_t(v_gen_salary,i-1);
			v_amtincom(i)       := to_number(replace(hcm_util.get_string_t(v_item_gen_salary,'amtincom'),',',''));
			v_amtincded(i)      := to_number(replace(hcm_util.get_string_t(v_item_gen_salary,'amtincded'),',',''));
			v_amtincadj(i)      := to_number(replace(hcm_util.get_string_t(v_item_gen_salary,'amtincadj'),',',''));
			v_amtincdedOld(i)   := to_number(replace(hcm_util.get_string_t(v_item_gen_salary,'amtincdedOld'),',',''));
			v_amtincadjOld(i)   := to_number(replace(hcm_util.get_string_t(v_item_gen_salary,'amtincadjOld'),',',''));
		end loop;

		if (iscalculate_amtincadj) then
			for i in 1..v_size_salary loop
                if v_amtincadj(i) <> v_amtincadjOld(i) then
                    v_amtincded(i) := ((v_amtincadj(i) * v_amtincom(i)) / 100) ;
                end if;
			end loop;
		else
			for i in 1..v_size_salary loop
                if v_amtincded(i) <> v_amtincdedOld(i) then
                    if (v_amtincom(i) = 0) then
                        v_amtincadj(i) := 0;
                        v_amtincded(i) := 0;
                    else
    --					v_amtincadj(i) := ((v_amtincded(i) / v_amtincom(i)) * 100);
                        v_amtincadj(i) := 0;
                    end if;
                end if;
			end loop;
		end if;
		for i in 1..v_size_salary loop

			v_item_gen_salary   :=  hcm_util.get_json_t(v_gen_salary,i-1);
			v_out_obj_item      := json_object_t();
			v_out_obj_item.put('amtincadj',v_amtincadj(i));
			v_out_obj_item.put('amtincded',v_amtincded(i));
			v_out_obj_item.put('amtincom',v_amtincom(i));
			v_out_obj_item.put('amtmax',hcm_util.get_string_t(v_item_gen_salary,'amtmax'));
			v_out_obj_item.put('codincom',hcm_util.get_string_t(v_item_gen_salary,'codincom'));
			v_out_obj_item.put('desincom',hcm_util.get_string_t(v_item_gen_salary,'desincom'));
			v_out_obj_item.put('desunit',hcm_util.get_string_t(v_item_gen_salary,'desunit'));
			v_out_obj_item.put('flgEdit',hcm_util.get_string_t(v_item_gen_salary,'flgEdit'));
			v_out_obj_item.put('rowID',hcm_util.get_string_t(v_item_gen_salary,'rowID'));
			v_out_obj_item.put('rowIndex',hcm_util.get_string_t(v_item_gen_salary,'rowIndex'));
			v_out_obj_item.put('total',hcm_util.get_string_t(v_item_gen_salary,'total'));

			v_suminperiod       := v_suminperiod + v_amtincded(i);
			v_out_obj_row.put(to_char(i-1),v_out_obj_item);

		end loop;

		v_periodstr := v_ttpunded.dteyearst - hcm_appsettings.get_additional_year() ||lpad(v_ttpunded.dtemthst,2,0)||lpad(v_ttpunded.numprdst,2,0);
		v_periodend := v_ttpunded.dteyearen - hcm_appsettings.get_additional_year() ||lpad(v_ttpunded.dtemthen,2,0)||lpad(v_ttpunded.numprden,2,0);
		begin

			select hcm_util.get_codcomp_level(codcomp, 1),typpayroll into gen_codcomp,gen_typpayroll
			  from temploy1
			 where codempid = v_ttpunded.codempid;
		exception when no_data_found then
			gen_codcomp     := null;
			gen_typpayroll  := null;
		end;
		begin
			select count(*) into v_count
			  from tdtepay
			 where codcompy = gen_codcomp
			   and typpayroll = gen_typpayroll
			   and dteyrepay||lpad(dtemthpay,2,0)||lpad(numperiod,2,0)
                   between v_periodstr and v_periodend;
		end;
		if (v_count = 0) then
			param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TDTEPAY');
			json_str_output := get_response_message('400', param_msg_error, global_v_lang);
		else
			v_suminperiod   := v_suminperiod + v_gen_totalchange;
			v_sumperiod     := v_suminperiod * v_count;

			obj_sum         := json_object_t();
			obj_sum.put('coderror', '200');
			obj_sum.put('suminperiod', v_suminperiod);
			obj_sum.put('sumperiod', v_sumperiod);
			obj_sum.put('rows',v_out_obj_row);

			json_str_output := obj_sum.to_clob;
		end if;
	end;

	procedure getDetailHead (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		genDetailHead(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetailHead (json_str_output out clob) as
		obj_row			json_object_t;
		obj_data		json_object_t;
		obj_detail		json_object_t;
		v_rcnt			number := 0;
		is_found_rec	boolean := false;
		v_start			varchar2( 100 char);
		v_end			varchar2( 100 char);
		v_typpayroll	varchar2( 100 char);
		v_count			number := 1;
		v_codcompy		varchar2( 100 char);
		now_year		varchar2(10);

		cursor c_TTPUNSH is
            select *
              from TTPUNDED
             where codempid = p_codempid
               and dteeffec = p_dteeffec ;
	begin
		obj_row     := json_object_t();
		now_year    := to_char(sysdate,'YYYY');
        begin
            select hcm_util.get_codcomp_level(codcomp,1) as codcompy
              into v_codcompy
              from TEMPLOY1
             where codempid = p_codempid;
        end;
		for r1 in c_TTPUNSH loop
			obj_data    := json_object_t();
			v_rcnt      := v_rcnt + 1;
			begin
				select typpayroll
                  into v_typpayroll
				  from temploy1
                 where codempid = p_codempid ;
			end;



			begin
				v_start     := r1.DTEYEARST||lpad(r1.DTEMTHST,2,'0')||lpad(r1.NUMPRDST,2,'0');
				v_end       := r1.DTEYEAREN||lpad(r1.DTEMTHEN,2,'0')||lpad(r1.NUMPRDEN,2,'0');
				select count(*)
                  into v_count
				  from tdtepay
				 where codcompy = v_codcompy
				   and TYPPAYROLL = v_typpayroll
				   and DTEYREPAY||lpad(dtemthpay,2,'0')||lpad(NUMPERIOD,2,'0') BETWEEN v_start and v_end;
			end;

			if v_count = 0 then
				v_count := 1;
			end if;

			is_found_rec := true;
			obj_data.put('coderror', '200');
			obj_data.put('rownumber', v_rcnt);

			if (r1.dteyearst > to_number(now_year)) then
				obj_data.put('dteyearst', r1.dteyearst);
			else
				obj_data.put('dteyearst', r1.dteyearst+hcm_appsettings.get_additional_year());
			end if;

			obj_data.put('dtemthst', r1.dtemthst);
			obj_data.put('numprdst', r1.numprdst);

			if (r1.dteyearen > to_number(now_year)) then
				obj_data.put('dteyearen', r1.dteyearen);
			else
				obj_data.put('dteyearen', r1.dteyearen + hcm_appsettings.get_additional_year());
			end if;
			obj_data.put('dtemthen', r1.dtemthen);
			obj_data.put('numprden', r1.numprden);

			obj_data.put('codpay', r1.codpay);
			obj_data.put('total1', stddec(r1.amtded, p_codempid, global_v_chken));
			obj_data.put('amttotded', stddec(r1.amttotded, p_codempid, global_v_chken));
			obj_data.put('v_count', v_count);
			obj_data.put('amtded', stddec(r1.amtded, p_codempid, global_v_chken));
			obj_data.put('mode', 'edit');
            obj_data.put('codcompy', v_codcompy);
			obj_row.put(to_char(v_rcnt - 1), obj_data);
		end loop;
		if not is_found_rec then
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('rownumber', '0');
			obj_data.put('numprdst', '1');
			obj_data.put('numprden', '1');

			obj_data.put('dtemthst', to_number(to_char(sysdate,'mm')));
			obj_data.put('dtemthen',to_number(to_char(sysdate,'mm')));
			obj_data.put('dteyearst',to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year);
			obj_data.put('dteyearen',to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year);
			obj_data.put('v_count', 1);

			obj_data.put('codpay', '');
			obj_data.put('total1', 0);
			obj_data.put('amtded', 0);
			obj_data.put('amttotded', 0);
			obj_data.put('mode', 'add');
            obj_data.put('codcompy', v_codcompy);
			obj_row.put(0, obj_data);
		end if;
		json_str_output := obj_row.to_clob;
	end;

	procedure getDetailDropdown (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		genDetailDropdown(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetailDropdown (json_str_output out clob) as
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		obj_detail		  json_object_t;
		v_rcnt			    number := 0;
		v_check			    number ;
		is_found_rec		boolean := false;

		cursor c_tlistval is
            select *
              from tlistval
             where codapp = 'FLGSSM'
               and codlang = global_v_lang
               and numseq <> 0;
	begin
		obj_row := json_object_t();
		for r1 in c_tlistval loop
			obj_data        := json_object_t();
			v_rcnt          := v_rcnt + 1;
			is_found_rec    := true;
			obj_row.put( 'coderror', '200');
			obj_row.put( r1.LIST_VALUE, r1.DESC_label);
		end loop;
		json_str_output := obj_row.to_clob;
	end;

	procedure getDetailTable (json_str_input in clob, json_str_output out clob) as
		v_out_clob_detail   clob;
		v_obj_row_detail	json_object_t;
	begin
		initial_value(json_str_input);
		dbms_lob.createtemporary(v_out_clob_detail, true);

		getDetail(json_str_input,v_out_clob_detail);
		v_obj_row_detail := json_object_t(v_out_clob_detail);

		genDetailTable(v_obj_row_detail,json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetailTable (listofttpunsh in json_object_t,json_str_output out clob) as
		cursor c_temploy1_detail is
            select hcm_util.get_codcomp_level(codcomp,1) as codcomp,codempmt
              from temploy1
             where codempid = p_codempid;

        rowtemp c_temploy1_detail%rowtype;

        cursor c_ttpunsh is
            select codpunsh
              from ttpunsh
             where codempid = p_codempid
               and dteeffec = p_dteeffec;

		tmp c_ttpunsh%rowtype;

		v_obj_result		json_object_t;
		v_obj_row		    json_object_t;
		v_obj_col		    json_object_t;
		v_counter		    number;
		v_ttpunsh_refcur    sys_refcursor;
		v_count_ttpunsh		number;

		v_obj_itemttpunsh	json_object_t;
		v_ttpunsh_typpun	ttpunsh.typpun%type;
		v_ttpunsh_codpunsh	ttpunsh.codpunsh%type;
		v_out_objrow		json_object_t;
		v_out_amtdoth		number;
		v_out_sum_in_period	number;
		v_out_sum_period	number;

		v_out_dteyearst		ttpunded.dteyearst%type;
		v_out_dtemthst		ttpunded.dtemthst%type;
		v_out_numprdst		ttpunded.numprdst%type;
		v_out_dteyearen		ttpunded.dteyearen%type;
		v_out_dtemthen		ttpunded.dtemthen%type;
		v_out_numprden		ttpunded.numprden%type;
		v_out_codempid		ttpunded.codempid%type;
		v_out_dteeffec		ttpunded.dteeffec%type;
		v_out_codpunsh		ttpunded.codpunsh%type;
		v_out_codpay		ttpunded.codpay%type;
		v_out_amtded		ttpunded.amtded%type;
		v_out_amttotded		ttpunded.amttotded%type;
		v_out_mode_ttpunded	varchar2(10 char);
	begin

		v_obj_row       := json_object_t();
		v_obj_result    := json_object_t();
		v_counter       := 0;

		open c_temploy1_detail;
		fetch c_temploy1_detail into rowtemp;

		open c_ttpunsh;
		fetch c_ttpunsh into tmp;
		v_count_ttpunsh := listofttpunsh.get_size;

		-- edit
		for i in 0..v_count_ttpunsh-1
			loop
				v_obj_itemttpunsh   := hcm_util.get_json_t(listofttpunsh,i);
				v_ttpunsh_typpun    := hcm_util.get_string_t(v_obj_itemttpunsh,'typpun');
				v_ttpunsh_codpunsh  := hcm_util.get_string_t(v_obj_itemttpunsh,'codpunsh');

				v_obj_col := json_object_t();
				getamtincom ( p_codempid , p_dteeffec , rowtemp.codcomp, rowtemp.codempmt, v_ttpunsh_codpunsh,
                              global_v_lang, v_chken, v_out_objrow, v_out_amtdoth, v_out_sum_in_period,
                              v_out_sum_period, v_out_dteyearst, v_out_dtemthst, v_out_numprdst,
                              v_out_dteyearen, v_out_dtemthen, v_out_numprden, v_out_codempid,
                              v_out_dteeffec, v_out_codpunsh, v_out_codpay, v_out_amtded, v_out_amttotded, v_out_mode_ttpunded);

				v_obj_col.put('rows',v_out_objrow);
                v_obj_col.put('numseq',hcm_util.get_string_t(v_obj_itemttpunsh,'numseq'));
				v_obj_col.put('amtdoth',v_out_amtdoth);
				v_obj_col.put('suminperiod',v_out_sum_in_period);
				v_obj_col.put('sumperiod',v_out_sum_period);
				v_obj_col.put('dteyearst',v_out_dteyearst);
				v_obj_col.put('dtemthst',v_out_dtemthst);
				v_obj_col.put('numprdst',v_out_numprdst);
				v_obj_col.put('dteyearen',v_out_dteyearen);
				v_obj_col.put('dtemthen',v_out_dtemthen);
				v_obj_col.put('numprden',v_out_numprden);
				v_obj_col.put('codempid',v_out_codempid);
				v_obj_col.put('dteeffec',to_char(v_out_dteeffec,'dd/mm/yyyy'));
				v_obj_col.put('codpunsh',v_out_codpunsh);
				v_obj_col.put('codpunshtemp',v_out_codpunsh);
				v_obj_col.put('codpay',nvl(v_out_codpay,''));
				v_obj_col.put('amtded',v_out_codpay);
				v_obj_col.put('amttotded',v_out_codpay);
				v_obj_col.put('mode',v_out_mode_ttpunded);
				v_obj_row.put(to_char(v_counter),v_obj_col);
				v_counter := v_counter + 1;

			end loop;
			v_obj_result.put('coderror','200');
			v_obj_result.put('listofttpunded',v_obj_row);

			json_str_output := v_obj_result.to_clob;
		end;

	procedure getamtincom ( v_codempid in varchar2,
		v_dteeffec		    in date,
		v_codcompy		    in varchar2,
		v_codempmt		    in varchar2,
		v_codpunsh		    in varchar2,
		v_lang			      in varchar2,
		v_chken			      in varchar2,
		v_out_objrow		  out json_object_t,
		v_out_amtdoth		  out number,
		v_out_sum_in_period	out number,
		v_out_sum_period	out number,
		v_out_dteyearst		out ttpunded.dteyearst%type,
		v_out_dtemthst		out ttpunded.dtemthst%type,
		v_out_numprdst		out ttpunded.numprdst%type,
		v_out_dteyearen		out ttpunded.dteyearen%type,
		v_out_dtemthen		out ttpunded.dtemthen%type,
		v_out_numprden		out ttpunded.numprden%type,
		v_out_codempid		out ttpunded.codempid%type,
		v_out_dteeffec		out ttpunded.dteeffec%type,
		v_out_codpunsh		out ttpunded.codpunsh%type,
		v_out_codpay		  out ttpunded.codpay%type,
		v_out_amtded		  out ttpunded.amtded%type,
		v_out_amttotded		out ttpunded.amttotded%type,
		v_out_mode		    out varchar2 ) as

		type p_char is table of TTPUNDED.amtincom1%type index by binary_integer;
		v_amtincom              p_char;
		v_amtincded             p_char;
		v_objrow_result		    json_object_t;
		obj_row_codincom	    json_object_t;
		obj_item_codincom	    json_object_t;
		obj_col			          json_object_t;
		v_json_input            clob;
		v_clob_objrow_codincom clob;
		v_item_amtincom		    number;
		v_item_amtincadj	    number;
		v_item_amtincded	    number;
		v_count_datarow		    number;
		total			            number;

		v_number_amtdoth	    number;
		v_number_amtded		    number;
		v_number_tdtepay	    number;
		v_number_amttotded	  number;
		v_amtdoth		          ttpunded.amtdoth%type;
		v_amtded		          ttpunded.amtded%type;
		v_amttotded		        ttpunded.amttotded%type;

		v_dteyearst		        ttpunded.dteyearst%type;
		v_dtemthst		        ttpunded.dtemthst%type;
		v_numprdst		        ttpunded.numprdst%type;
		v_dteyearen		        ttpunded.dteyearen%type;
		v_dtemthen		        ttpunded.dtemthen%type;
		v_numprden		        ttpunded.numprden%type;
	begin

		v_objrow_result     := json_object_t();
		total               := 0;
		v_count_datarow     := 0;
		v_number_amtdoth    := 0;
		v_number_amtded     := 0;
		v_out_amtdoth       := 0;
		v_out_sum_in_period := 0;
		v_out_sum_period    := 0;
		for i in 1..10 loop
			v_amtincom(i)   := null;
			v_amtincded(i)  := null;
		end loop;

		v_json_input            := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmt||'","p_lang":"'||v_lang||'"}';
		v_clob_objrow_codincom  := hcm_pm.get_codincom(v_json_input);
		obj_row_codincom        := json_object_t(v_clob_objrow_codincom);
		begin
			select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                   amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                   amtincded1,amtincded2,amtincded3,amtincded4,amtincded5,
                   amtincded6,amtincded7,amtincded8,amtincded9,amtincded10,
                   amtdoth,amtded,dteyearst,dtemthst,numprdst,dteyearen,dtemthen,numprden,
                   codempid,dteeffec,codpunsh,codpay,amttotded
			  into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                   v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                   v_amtincded(1),v_amtincded(2),v_amtincded(3),v_amtincded(4),v_amtincded(5),
                   v_amtincded(6),v_amtincded(7),v_amtincded(8),v_amtincded(9),v_amtincded(10),
                   v_amtdoth,v_amtded,v_dteyearst,v_dtemthst,v_numprdst,v_dteyearen,v_dtemthen,v_numprden,
                   v_out_codempid,v_out_dteeffec,v_out_codpunsh,v_out_codpay,v_amttotded
			  from ttpunded
			 where codempid = v_codempid
			   and dteeffec = v_dteeffec
			   and codpunsh = v_codpunsh;

			v_number_amtdoth    := stddec(v_amtdoth, v_codempid, v_chken);
			v_number_amtded     := stddec(v_amtded, v_codempid, v_chken);
			v_number_amttotded  := stddec(v_amttotded, v_codempid, v_chken);
			v_out_dteyearst     := v_dteyearst + hcm_appsettings.get_additional_year();
			v_out_dtemthst      := v_dtemthst;
			v_out_numprdst      := v_numprdst;
			v_out_dteyearen     := v_dteyearen + hcm_appsettings.get_additional_year();
			v_out_dtemthen      := v_dtemthen;
			v_out_numprden      := v_numprden;
			v_out_amtded        := v_number_amtded;
			v_out_amttotded     := v_number_amttotded;

			for i in 1..10 loop

				obj_col := json_object_t();
				v_item_amtincom     := greatest(0,stddec(v_amtincom(i), v_codempid, v_chken)) ;
				v_item_amtincded    := greatest(0,stddec(v_amtincded(i), v_codempid, v_chken));

				if (v_item_amtincded <> 0 and v_item_amtincom <> 0) then
					v_item_amtincadj := round((v_item_amtincded / v_item_amtincom) * 100,2);
				else
					v_item_amtincadj := 0;
				end if;

--				obj_item_codincom := hcm_util.get_json_t(obj_row_codincom,'0');
				obj_item_codincom := hcm_util.get_json_t(obj_row_codincom,to_char(i-1));

				obj_col.put('amtincom', greatest(0,v_item_amtincom));
				obj_col.put('amtincadj', v_item_amtincadj);
				obj_col.put('amtincded', v_item_amtincded);

				total := total + stddec(v_amtincded(i), v_codempid, v_chken);
				obj_col.put('total', total);
				obj_col.put('rowIndex', i);
				obj_col.put('codincom', hcm_util.get_string_t(obj_item_codincom,'codincom'));
				obj_col.put('desincom', hcm_util.get_string_t(obj_item_codincom,'desincom'));
				obj_col.put('desunit', hcm_util.get_string_t(obj_item_codincom,'desunit'));
				obj_col.put('amtmax', hcm_util.get_string_t(obj_item_codincom,'amtmax'));

				if (length (hcm_util.get_string_t(obj_item_codincom,'codincom')) > 0 ) then
					v_out_sum_in_period := v_out_sum_in_period + v_item_amtincded;

					v_objrow_result.put(to_char(v_count_datarow), obj_col);
					v_count_datarow := v_count_datarow + 1;
				end if;
			end loop;

			v_out_amtdoth       := v_number_amtdoth;
			v_number_tdtepay    := get_count_tdtepay(v_codempid,v_dteyearst, v_dtemthst,v_numprdst, v_dteyearen,v_dtemthen, v_numprden);

			v_out_sum_in_period := v_out_sum_in_period + v_number_amtdoth;
			v_out_sum_period    := (v_out_sum_in_period * v_number_tdtepay);
			v_out_mode          := 'edit';
		exception when no_data_found then
			v_out_amtdoth           := 0;
			v_out_sum_in_period     := 0;
			v_out_sum_period        := 0;

			v_out_dteyearst         := to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year();
			v_out_dtemthst          := to_number(to_char(sysdate,'mm'));
			v_out_numprdst          := 1;
			v_out_dteyearen         := to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year();
			v_out_dtemthen          := to_number(to_char(sysdate,'mm'));
			v_out_numprden          := 1;
			v_out_amtded            := 0;
			v_out_amttotded         := 0;
			v_out_codempid          := v_codempid;
			v_out_dteeffec          := '';
			v_out_codpunsh          := '';
			v_out_codpay            := '';
			v_out_mode              := 'add';

			begin
				select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                       amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
				  into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                       v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
				  from TEMPLOY3 where codempid = v_codempid;
			end;

			for i in 1..10 loop
				obj_col             := json_object_t();
				obj_item_codincom   := hcm_util.get_json_t(obj_row_codincom,i-1);
				obj_col.put('amtincom', greatest(0,stddec(v_amtincom(i), v_codempid, v_chken)));
				obj_col.put('amtincded', 0);
				obj_col.put('amtincadj', 0);
				obj_col.put('total', 0);
				obj_col.put('rowIndex', i);
				obj_col.put('codincom', hcm_util.get_string_t(obj_item_codincom,'codincom'));
				obj_col.put('desincom', hcm_util.get_string_t(obj_item_codincom,'desincom'));
				obj_col.put('desunit', hcm_util.get_string_t(obj_item_codincom,'desunit'));
				obj_col.put('amtmax', hcm_util.get_string_t(obj_item_codincom,'amtmax'));
				if (length (hcm_util.get_string_t(obj_item_codincom,'codincom')) > 0 ) then
					v_objrow_result.put(to_char(v_count_datarow), obj_col);
					v_count_datarow := v_count_datarow + 1;
				end if;
			end loop;
		end;
		v_out_objrow := v_objrow_result;
	end getamtincom;

	procedure init_default_detailtable (json_str_input in clob) as
		json_obj		json_object_t;
	begin
		v_chken     := hcm_secur.get_v_chken;
		json_obj    := json_object_t(json_str_input);
		--global
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end init_default_detailtable;

	procedure get_default_detailtable (json_str_input in clob, json_str_output out clob) as
	begin
		init_default_detailtable(json_str_input);
		gen_default_detailtable(json_str_input	, json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_default_detailtable;

	procedure gen_default_detailtable (json_str_input in clob, json_str_output out clob) as
		json_obj		    json_object_t;
		type p_char is table of ttpunded.amtincom1%type index by binary_integer;
		v_amtincom          p_char;
		v_amtincded         p_char;
		v_objrow_result		json_object_t;
		obj_row_codincom	json_object_t;
		obj_item_codincom	json_object_t;
		obj_col			    json_object_t;
		v_json_input        clob;
		v_clob_objrow_codincom clob;
		v_out_amtdoth		number;
		v_out_sum_in_period	number;
		v_out_sum_period	number;
		v_count_datarow		number;
		total			    number;
		v_codcompy		    temploy1.codcomp%type;
		v_codempid		    temploy1.codempid%type;
		v_codempmt		    temploy1.codempmt%type;
		v_out_obj		    json_object_t;

	begin
		v_out_obj       := json_object_t();
		v_objrow_result := json_object_t();
		total           := 0;
		v_count_datarow := 0;
		for i in 1..10 loop
			v_amtincom(i)   := null;
			v_amtincded(i)  := null;
		end loop;

		json_obj    := json_object_t(json_str_input);
		v_codempid  := hcm_util.get_string_t(json_obj,'v_codempid');

		select hcm_util.get_codcomp_level(codcomp,1) as codcomp, codempmt
		  into v_codcompy,v_codempmt
		  from temploy1
		 where codempid = v_codempid;

		v_json_input := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmt||'","p_lang":"'||global_v_lang||'"}';
		v_clob_objrow_codincom  := hcm_pm.get_codincom(v_json_input);
		obj_row_codincom        := json_object_t(v_clob_objrow_codincom);
		v_out_amtdoth           := 0;
		v_out_sum_in_period     := 0;
		v_out_sum_period        := 0;

		begin
			select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                   amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
			  into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                   v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
			  from TEMPLOY3 where codempid = v_codempid;
		end;

		for i in 1..10 loop
			obj_col             := json_object_t();
			obj_item_codincom   := hcm_util.get_json_t(obj_row_codincom,i-1);
			obj_col.put('amtincom', greatest(0,stddec(v_amtincom(i) , v_codempid, v_chken)));
			obj_col.put('amtincded', 0);
			obj_col.put('amtincadj', 0);
			obj_col.put('total', 0);
			obj_col.put('rowIndex', i);
			obj_col.put('codincom', hcm_util.get_string_t(obj_item_codincom,'codincom'));
			obj_col.put('desincom', hcm_util.get_string_t(obj_item_codincom,'desincom'));
			obj_col.put('desunit', hcm_util.get_string_t(obj_item_codincom,'desunit'));
			obj_col.put('amtmax', hcm_util.get_string_t(obj_item_codincom,'amtmax'));
			if (length (hcm_util.get_string_t(obj_item_codincom,'codincom')) > 0 ) then
				v_objrow_result.put(to_char(v_count_datarow),obj_col);
				v_count_datarow := v_count_datarow + 1;
			end if;
		end loop;

		v_out_obj.put('rows',v_objrow_result);
		v_out_obj.put('amtdoth',v_out_amtdoth);
		v_out_obj.put('suminperiod',v_out_sum_in_period);
		v_out_obj.put('sumperiod',v_out_sum_period);
		v_out_obj.put('dteyearst', to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year());
		v_out_obj.put('dtemthst',to_number(to_char(sysdate,'mm')));
		v_out_obj.put('numprdst',1);
		v_out_obj.put('dteyearen', to_number(to_char(sysdate,'yyyy')) + hcm_appsettings.get_additional_year());
		v_out_obj.put('dtemthen',to_number(to_char(sysdate,'mm')));
		v_out_obj.put('numprden',1);
		v_out_obj.put('codempid', v_codempid);
		v_out_obj.put('codpunsh', '');
		v_out_obj.put('dteeffec', '');
		v_out_obj.put('codpay','');
		v_out_obj.put('coderror', '200');

		json_str_output := v_out_obj.to_clob;
	end gen_default_detailtable;

	function get_count_tdtepay( v_codempid in varchar2,
		v_dteyearst		    in ttpunded.dteyearst%type,
		v_dtemthst		    in ttpunded.dtemthst%type,
		v_numprdst		    in ttpunded.numprdst%type,
		v_dteyearen		    in ttpunded.dteyearen%type,
		v_dtemthen		    in ttpunded.dtemthen%type,
		v_numprden		    in ttpunded.numprden%type) return number is
		v_typpayroll		temploy1.typpayroll%type;
		v_company		    temploy1.codcomp%type;
		v_count_tdtepay		number;

		v_periodstr		    varchar2(20 char);
		v_periodend		    varchar2(20 char);
	begin

		v_count_tdtepay := 0;
		v_periodstr     := v_dteyearst||lpad(v_dtemthst,2,0)||lpad(v_numprdst,2,0);
		v_periodend     := v_dteyearen||lpad(v_dtemthen,2,0)||lpad(v_numprden,2,0);

		select typpayroll,hcm_util.get_codcomp_level(codcomp, 1)
          into v_typpayroll,v_company
		  from temploy1
		 where codempid = v_codempid;

		select count(*)
          into v_count_tdtepay
		  from tdtepay
		 where codcompy = v_company
		   and typpayroll = v_typpayroll
		   and dteyrepay||lpad(dtemthpay,2,0)||lpad(numperiod,2,0) between v_periodstr and v_periodend;

		return v_count_tdtepay;
	end get_count_tdtepay;

	procedure init_post_save (json_str_input in clob) as
		json_obj		json_object_t;
	begin
		v_chken             := hcm_secur.get_v_chken;
		json_obj            := json_object_t(json_str_input);
		--global
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_tab1(json_str_input in clob, v_out_objtab1 out json_object_t) as
		v_objrow		    json_object_t;
		v_count_temploy		number;
		v_staemp		    temploy1.staemp%type;
		v_ttmistk_numhmref	ttmistk.numhmref%type;
		v_codusershow		temploy1.codempid%type;
		v_objtab1		    json_object_t;
	begin

		v_objrow            := json_object_t(json_str_input);
		v_ttmistk_numhmref  := hcm_util.get_string_t(v_objrow,'v_numhmref');
		v_codusershow       := hcm_util.get_string_t(v_objrow,'v_codusershow');

		if (v_codusershow is null or length(v_codusershow) = 0) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		begin
			select count(*) into v_count_temploy
			from temploy1
			where codempid = v_codusershow;
		end;

		if (v_count_temploy = 0) then
			param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
			return;
		end if;

		begin
			select staemp into v_staemp
			from temploy1
			where codempid = v_codusershow;
		end;

		if (v_staemp = '9') then
			param_msg_error := get_error_msg_php('HR2101',global_v_lang);
			return;
		elsif (v_staemp = '0') then
			param_msg_error := get_error_msg_php('HR2102',global_v_lang);
			return;
		end if;

		if ( v_ttmistk_numhmref is null or length(v_ttmistk_numhmref) = 0 ) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		v_objtab1 := json_object_t();
		v_objtab1.put('v_codempid', hcm_util.get_string_t(v_objrow,'v_codempid'));
		v_objtab1.put('v_dteeffec', hcm_util.get_string_t(v_objrow,'v_dteeffec'));
		v_objtab1.put('v_numhmref',hcm_util.get_string_t(v_objrow,'v_numhmref'));
		v_objtab1.put('v_dtemistk',hcm_util.get_string_t(v_objrow,'v_dtemistk'));
		v_objtab1.put('v_codmist',hcm_util.get_string_t(v_objrow,'v_codmist'));
		v_objtab1.put('v_refdoc',hcm_util.get_string_t(v_objrow,'v_refdoc'));
		v_objtab1.put('v_desmist',hcm_util.get_string_t(v_objrow,'v_desmist'));
		v_objtab1.put('v_codusershow',hcm_util.get_string_t(v_objrow,'v_codusershow'));
		v_objtab1.put('v_dtecreate',hcm_util.get_string_t(v_objrow,'v_dtecreate'));

		v_out_objtab1 := v_objtab1;
	end vadidate_tab1;

	procedure vadidate_tab2(json_str_input in clob, v_out_objtab2 out json_object_t) as
		v_objrow		    json_object_t;
		v_objtab2		    json_object_t;
		v_size_v_objtab2	number;
		v_objtab2_item		json_object_t;
		v_codpunsh		    ttpunsh.codpunsh%type;
        v_codpunshold       ttpunsh.codpunsh%type;
		v_count_tcodpunh	number;
		v_typpun		    ttpunsh.typpun%type;
		v_flgexempt		    ttpunsh.flgexempt%type;
		v_codexem		    ttpunsh.codexemp%type;
		v_count_tcodexem	number;
		v_flgssm		    ttpunsh.flgssm%type;
		v_dtestart		    ttpunsh.dtestart%type;
		v_dteend		    ttpunsh.dteend%type;
		v_obj_row		    json_object_t;
		v_obj_item		    json_object_t;
		v_count_obj_row		number;
        v_mode              varchar2(100);
        v_numseq            number;
        v_flgblist          ttpunsh.flgblist%type;
        v_remark            ttpunsh.remark%type;
        v_flagcheck         varchar2(1);
	begin
		v_obj_row           := json_object_t();
		v_objrow            := json_object_t(json_str_input);
		v_objtab2           := hcm_util.get_json_t(v_objrow,'v_datatab2');
		v_size_v_objtab2    := v_objtab2.get_size;
		v_count_obj_row     := 0;
		for i in 0..v_size_v_objtab2-1 loop
			v_objtab2_item  := hcm_util.get_json_t(v_objtab2,i);
			v_obj_item      := json_object_t();

			v_codpunsh      := hcm_util.get_string_t(v_objtab2_item,'codpunsh');
			v_codpunshold   := hcm_util.get_string_t(v_objtab2_item,'codpunshold');
			v_typpun        := hcm_util.get_string_t(v_objtab2_item,'typpun');
			v_flgexempt     := hcm_util.get_string_t(v_objtab2_item,'flgexempt');
			v_flgssm        := hcm_util.get_string_t(v_objtab2_item,'flgssm');
			v_codexem       := hcm_util.get_string_t(v_objtab2_item,'codexem');
			v_dtestart      := to_date(hcm_util.get_string_t(v_objtab2_item,'dtestart'),'dd/mm/yyyy');
            v_dteend        := to_date(hcm_util.get_string_t(v_objtab2_item,'dteend'),'dd/mm/yyyy');
            v_remark        := hcm_util.get_string_t(v_objtab2_item,'remark');
            v_numseq        := hcm_util.get_string_t(v_objtab2_item,'numseq');
            v_mode          := hcm_util.get_string_t(v_objtab2_item,'mode');
            v_flagcheck     := hcm_util.get_string_t(v_objtab2_item,'flagcheck');
            v_flgblist      := hcm_util.get_string_t(v_objtab2_item,'flgbist');
            if (v_codpunsh is null) then
				param_msg_error := get_error_msg_php('HR2045',global_v_lang);
				return;
			end if;

			begin
				select count(*)
                  into v_count_tcodpunh
				  from tcodpunh
				 where codcodec = v_codpunsh;
			end ;
			if (v_count_tcodpunh = 0) then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPUNH');
				return;
			end if;

			if (v_typpun is null or length(v_typpun) = 0) then
				param_msg_error := get_error_msg_php('HR2045',global_v_lang);
				return;
			end if;

			if (v_typpun = '5') then
				if ( v_dtestart is null ) then
					param_msg_error := get_error_msg_php('HR2045',global_v_lang);
					return;
				elsif ( v_dteend is null ) then
					param_msg_error := get_error_msg_php('HR2045',global_v_lang);
					return;
				end if;
			end if;

			if ( length(v_codexem) > 0 ) then
				begin
					select count(*)
                      into v_count_tcodexem
					  from tcodexem
					 where codcodec = v_codexem;
				end;
				if (v_count_tcodexem = 0 ) then
					param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXEM');
					return;
				end if;
			end if;

			if (v_flgexempt = 'Y') then
				if ( v_flgssm is null or length (v_flgssm) = 0)then
					param_msg_error := get_error_msg_php('HR2045',global_v_lang);
					return;
				elsif (v_codexem is null or length (v_codexem) = 0) then
					param_msg_error := get_error_msg_php('HR2045',global_v_lang);
					return;
				end if;
			end if;

			v_obj_item.put('codpunsh',v_codpunsh);
			v_obj_item.put('codpunshold',v_codpunshold);
			v_obj_item.put('dtestart',to_char(v_dtestart,'dd/mm/yyyy'));
			v_obj_item.put('dteend',to_char(v_dteend,'dd/mm/yyyy'));
			v_obj_item.put('mode',hcm_util.get_string_t(v_objtab2_item,'mode'));
			v_obj_item.put('numseq',hcm_util.get_string_t(v_objtab2_item,'numseq'));
			v_obj_item.put('flgexempt',v_flgexempt);
			v_obj_item.put('typpun',v_typpun);
			v_obj_item.put('flgbist',v_flgblist);
			v_obj_item.put('remark',v_remark);
			v_obj_item.put('flagcheck',v_flagcheck);
			v_obj_item.put('codexem',v_codexem);
			v_obj_item.put('flgssm',v_flgssm);
			v_obj_row.put(to_char(v_count_obj_row),v_obj_item);

			v_count_obj_row := v_count_obj_row + 1;
		end loop;
		v_out_objtab2 := v_obj_row;

	end vadidate_tab2;

	procedure vadidate_tab3(json_str_input in clob,v_out_objtab1 in json_object_t,v_in_objtab2 in json_object_t, v_out_objtab3 out json_object_t) as
		v_objrow		    json_object_t;
		v_objtab3		    json_object_t;
		v_obj_item		    json_object_t;
		v_size_objtab3		number;
		v_check_secur2		boolean;
		v_zupdsal		    varchar2(1 char);
		v_codempid		    temploy1.codempid%type;
		v_dteyearst		    ttpunded.dteyearst%type;
		v_dtemthst		    ttpunded.dtemthst%type;
		v_numprdst		    ttpunded.numprdst%type;
		v_dteyearen		    ttpunded.dteyearen%type;
		v_dtemthen		    ttpunded.dtemthen%type;
		v_numprden		    ttpunded.numprden%type;
		v_codpay		    ttpunded.codpay%type;
		v_count_codpay		number;
		v_periodstr		    varchar2(20 char);
		v_periodend		    varchar2(20 char);
		v_addyear		    number;
		v_codcomp		    temploy1.codcomp%type;
		v_typpayroll		temploy1.typpayroll%type;
		v_out_obj_row		json_object_t;
		v_out_size_obj_row	number;
		v_obj_item_datatab2	json_object_t;
		v_typpun		    ttpunsh.typpun%type;
        v_suminperiod       number;

	begin
		v_out_size_obj_row  := 0;

		v_codempid          := hcm_util.get_string_t(v_out_objtab1,'v_codempid');
		v_check_secur2      := secur_main.secur2(v_codempid, global_v_coduser, global_v_numlvlsalst,global_v_numlvlsalen, v_zupdsal);
		if (v_zupdsal = 'N') then
			v_out_objtab3 := json_object_t();
		else
			begin
				select codcomp,typpayroll into v_codcomp,v_typpayroll
				  from temploy1
				 where codempid = v_codempid;

				v_codcomp := hcm_util.get_codcomp_level(v_codcomp,1);
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
				return ;
			end;

			v_objrow        := json_object_t(json_str_input);
			v_objtab3       := hcm_util.get_json_t(v_objrow,'v_datatab3');
			v_size_objtab3  := v_objtab3.get_size;
			v_addyear       := hcm_appsettings.get_additional_year();
			v_out_obj_row   := json_object_t();

			for i in 0..v_size_objtab3-1 loop
				v_obj_item          := hcm_util.get_json_t(v_objtab3,i);
				v_obj_item_datatab2 := hcm_util.get_json_t(v_in_objtab2,i);

				v_dteyearst     := to_number(hcm_util.get_string_t(v_obj_item,'dteyearst'));
				v_dtemthst      := to_number(hcm_util.get_string_t(v_obj_item,'dtemthst'));
				v_numprdst      := to_number(hcm_util.get_string_t(v_obj_item,'numprdst'));
				v_dteyearen     := to_number(hcm_util.get_string_t(v_obj_item,'dteyearen'));
				v_dtemthen      := to_number(hcm_util.get_string_t(v_obj_item,'dtemthen'));
				v_numprden      := to_number(hcm_util.get_string_t(v_obj_item,'numprden'));
                v_suminperiod   := to_number(hcm_util.get_string_t(v_obj_item,'suminperiod'));
				v_codpay        := hcm_util.get_string_t(v_obj_item,'codpay');
				v_typpun        := hcm_util.get_string_t(v_obj_item_datatab2,'typpun');
				if (v_typpun = '1' or (v_typpun = '5' and v_suminperiod  > 0)) then
					if ( v_codpay is null or length(v_codpay) = 0) then
						param_msg_error := get_error_msg_php('HR2045',global_v_lang,'CODPAY');
						return;
					end if;

					begin
						select count(*)
                          into v_count_codpay
						  from tinexinf
						 where codpay = v_codpay;
					end;

					if (v_count_codpay = 0) then
						param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINEXINF');
						return;
					end if;

					v_periodstr := (v_dteyearst - v_addyear) ||lpad(v_dtemthst,2,0)||lpad(v_numprdst,2,0);
					v_periodend := (v_dteyearen - v_addyear)||lpad(v_dtemthen,2,0)||lpad(v_numprden,2,0);

--Redmine #5559					check_tdtepay(v_codcomp,v_typpayroll,v_periodstr,v_periodend);
                    check_tdtepay(v_codcomp,v_typpayroll,
                                 (v_dteyearst - v_addyear) , v_dtemthst , v_numprdst,
                                 (v_dteyearen - v_addyear) , v_dtemthen , v_numprden);
--Redmine #5559

					if (param_msg_error is not null) then
						return ;
					end if;
					check_tinexinfc(v_codcomp,v_codpay);
					if (param_msg_error is not null) then
						return ;
					end if;

					check_tinexinf(v_codpay);
					if (param_msg_error is not null) then
						return ;
					end if;
				end if;
				v_out_obj_row.put(to_char(v_out_size_obj_row),v_obj_item );
				v_out_size_obj_row := v_out_size_obj_row + 1;
			end loop;

			v_out_objtab3 := v_out_obj_row;
		end if;
	end vadidate_tab3;

	procedure post_save (json_str_input in clob, json_str_output out clob) as
		v_out_datatab1		json_object_t;
		v_out_datatab2		json_object_t;
		v_out_datatab3		json_object_t;
        v_checkapp          boolean := false;
        v_check             varchar2(500 char);
        v_codempid          temploy1.codempid%type;
        v_dteeffec          ttmistk.dteeffec%type;

		v_codform		    tfwmailh.codform %type;
		v_msg_to            varchar(100 char);
		v_templete_to       varchar(100 char);
		v_func_appr         varchar(100 char);
		v_rowid             rowid;
        v_error			    terrorm.errorno%type;
        v_approvno          ttmistk.approvno%type;
	begin

		init_post_save(json_str_input);
        v_approvno := 1;

		vadidate_tab1(json_str_input,v_out_datatab1);
		if (param_msg_error is not null) then
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		end if;

        v_codempid  := hcm_util.get_string_t(v_out_datatab1,'v_codempid');
        v_dteeffec  := to_date(hcm_util.get_string_t(v_out_datatab1,'v_dteeffec'),'dd/mm/yyyy');
        v_checkapp  := chk_flowmail.check_approve ('HRPM4GE', v_codempid, v_approvno, global_v_codempid, null, null, v_check);

        IF NOT v_checkapp AND v_check = 'HR2010' THEN
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
            json_str_output := Get_response_message('400', param_msg_error, global_v_lang);
            return;
        END IF;

		vadidate_tab2(json_str_input,v_out_datatab2);
		if (param_msg_error is not null) then
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		end if;

		vadidate_tab3(json_str_input,v_out_datatab1,v_out_datatab2,v_out_datatab3);
		if (param_msg_error is not null) then
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		end if;

		delete_ttpunsh(json_str_input);
		if (param_msg_error is not null) then
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		end if;

		save_ttmistk (v_out_datatab1);
		if (param_msg_error is not null) then
			rollback;
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		end if;

        if v_out_datatab2.get_size >0 then
          save_ttpunsh (v_out_datatab1,v_out_datatab2,v_out_datatab3);
        end if;

		if (param_msg_error is not null) then
			rollback;
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
		else
			commit;
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;

		 exception when others then
		 param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end post_save;

	procedure save_ttmistk (v_objdatatab1 in json_object_t) as
		v_codempid		ttmistk.codempid%type;
        v_dteeffec		ttmistk.dteeffec%type;
		v_numhmref		ttmistk.numhmref%type;
		v_refdoc		ttmistk.refdoc%type;
		v_codcomp		ttmistk.codcomp%type;
		v_codpos		ttmistk.codpos%type;
		v_codjob		ttmistk.codjob%type;
		v_numlvl		ttmistk.numlvl%type;
		v_dteempmt		ttmistk.dteempmt%type;
		v_codempmt		ttmistk.codempmt%type;
		v_typemp		ttmistk.typemp%type;
		v_typpayroll	ttmistk.typpayroll%type;
		v_desmist1		ttmistk.desmist1%type;
		v_dtemistk		ttmistk.dtemistk%type;
		v_codmist		ttmistk.codmist%type;
		v_codreq		ttmistk.codreq%type;
		v_jobgrade		ttmistk.jobgrade%type;
		v_codgrpgl		ttmistk.codgrpgl%type;

		v_count_ttmistk number;
        cursor c_temploy1 is
            select jobgrade,codgrpgl,codcomp,codjob,codpos ,
                   numlvl, codempmt, typemp, typpayroll, dteempmt
              from temploy1
             where codempid = v_codempid;
	begin
        v_codempid      := hcm_util.get_string_t(v_objdatatab1,'v_codempid');
        v_dteeffec      := to_date(hcm_util.get_string_t(v_objdatatab1,'v_dteeffec'),'dd/mm/yyyy');
		v_numhmref      := hcm_util.get_string_t(v_objdatatab1,'v_numhmref');
		v_refdoc        := hcm_util.get_string_t(v_objdatatab1,'v_refdoc');
		v_desmist1      := hcm_util.get_string_t(v_objdatatab1,'v_desmist');
		v_dtemistk      := to_date(hcm_util.get_string_t(v_objdatatab1,'v_dtemistk'),'dd/mm/yyyy');
		v_codmist       := hcm_util.get_string_t(v_objdatatab1,'v_codmist');
		v_codreq        := hcm_util.get_string_t(v_objdatatab1,'v_codusershow');

        for r1 in c_temploy1 loop
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;
            v_codjob        := r1.codjob;
            v_numlvl        := r1.numlvl;
            v_dteempmt      := r1.dteempmt;
            v_codempmt      := r1.codempmt;
            v_typemp        := r1.typemp;
            v_typpayroll    := r1.typpayroll;
            v_jobgrade      := r1.jobgrade;
            v_codgrpgl      := r1.codgrpgl;
        end loop;

		begin
			select count(*)
              into v_count_ttmistk
			  from ttmistk
			 where codempid = v_codempid
			   and dteeffec = v_dteeffec;
		end;

		if (v_count_ttmistk = 0) then
			insert
              into ttmistk (codempid, dteeffec,codmist, numhmref,
                            codcomp, codjob, codpos, numlvl, dteempmt, codreq,
                            codempmt ,typemp, typpayroll, jobgrade, codgrpgl,
                            desmist1, dtemistk,refdoc,staupd,dtecreate,codcreate,coduser)
			values (v_codempid, v_dteeffec,v_codmist, v_numhmref,
                    v_codcomp ,v_codjob, v_codpos, v_numlvl, v_dteempmt, v_codreq,
                    v_codempmt ,v_typemp ,v_typpayroll, v_jobgrade, v_codgrpgl,
                    v_desmist1, v_dtemistk,v_refdoc,'P',sysdate,global_v_coduser,global_v_coduser);
		else
			update ttmistk
			   set codmist = v_codmist,
                   desmist1 = v_desmist1,
                   dtemistk = v_dtemistk,
                   numhmref = v_numhmref,
                   refdoc = v_refdoc,
                   codcomp = v_codcomp,
                   codjob = v_codjob,
                   codpos = v_codpos,
                   numlvl = v_numlvl,
                   dteempmt = v_dteempmt,
                   codreq = v_codreq,
                   codempmt = v_codempmt,
                   typemp = v_typemp,
                   typpayroll = v_typpayroll,
                   jobgrade = v_jobgrade,
                   codgrpgl = v_codgrpgl,
                   dteupd = sysdate,
                   coduser = global_v_coduser
			 where codempid = v_codempid
			   and dteeffec = v_dteeffec ;
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	end save_ttmistk;

	procedure save_ttpunsh (v_objdatatab1 in json_object_t,v_objdatatab2 in json_object_t,v_objdatatab3 in json_object_t) as
		v_count_objtab2		number;
		v_codempid		ttpunsh.codempid%type;
		v_dteeffec		ttpunsh.dteeffec%type;
		v_codpunsh		ttpunsh.codpunsh%type;
		v_codpunshold	ttpunsh.codpunsh%type;
		v_numseq		ttpunsh.numseq%type;
		v_dtestart		ttpunsh.dtestart%type;
		v_dteend		ttpunsh.dteend%type;
		v_codcomp		ttpunsh.codcomp%type;
		v_codjob		ttpunsh.codjob%type;
		v_codpos		ttpunsh.codpos%type;
		v_numlvl		ttpunsh.numlvl%type;
		v_typpun		ttpunsh.typpun%type;
		v_remark		ttpunsh.remark%type;
		v_flgexempt		ttpunsh.flgexempt%type;
		v_codexemp		ttpunsh.codexemp%type;
		v_flgblist		ttpunsh.flgblist%type;
		v_flgssm		ttpunsh.flgssm%type;
		v_jobgrade		ttpunsh.jobgrade%type;
		v_codgrpgl		ttpunsh.codgrpgl%type;

		v_codpay		ttpunded.codpay%type;

		v_obj_itemtab2	json_object_t;
		v_count_ttpunsh	json_object_t;
		v_mode			varchar2(10 char);
		v_next_seq		number;
		v_obj_itemtab3	json_object_t;
		cursor v_temploy1_cur is
            select jobgrade,codgrpgl,codcomp,
                   codjob,codpos,numlvl, codempmt
              from temploy1
             where codempid = v_codempid;
	begin
		v_count_objtab2 := v_objdatatab2.get_size;
		v_codempid  := hcm_util.get_string_t(v_objdatatab1,'v_codempid');
		v_dteeffec  := to_date(hcm_util.get_string_t(v_objdatatab1,'v_dteeffec'),'dd/mm/yyyy');

        for r1 in v_temploy1_cur loop
            v_codcomp   := r1.codcomp;
            v_codjob    := r1.codjob;
            v_codpos    := r1.codpos;
            v_numlvl    := r1.numlvl;
            v_jobgrade  := r1.jobgrade;
            v_codgrpgl  := r1.codgrpgl;
        end loop;

		for i in 0..v_count_objtab2-1 loop
			v_obj_itemtab2 := hcm_util.get_json_t(v_objdatatab2,i);

			v_codpunsh      := hcm_util.get_string_t(v_obj_itemtab2,'codpunsh');
			v_codpunshold   := hcm_util.get_string_t(v_obj_itemtab2,'codpunshold');
			v_numseq        := hcm_util.get_string_t(v_obj_itemtab2,'numseq');
			v_typpun        := hcm_util.get_string_t(v_obj_itemtab2,'typpun');
			v_remark        := hcm_util.get_string_t(v_obj_itemtab2,'remark');
			v_flgexempt     := hcm_util.get_string_t(v_obj_itemtab2,'flgexempt');
			v_codexemp      := hcm_util.get_string_t(v_obj_itemtab2,'codexem');
			v_flgblist      := hcm_util.get_string_t(v_obj_itemtab2,'flgbist');
			v_flgssm        := hcm_util.get_string_t(v_obj_itemtab2,'flgssm');
			v_mode          := hcm_util.get_string_t(v_obj_itemtab2,'mode');
            v_dtestart      := to_date(hcm_util.get_string_t(v_obj_itemtab2,'dtestart'),'dd/mm/yyyy');
            v_dteend        := to_date(hcm_util.get_string_t(v_obj_itemtab2,'dteend'),'dd/mm/yyyy');

      v_obj_itemtab3  := hcm_util.get_json_t(v_objdatatab3,i);
      v_codpay        := hcm_util.get_string_t(v_obj_itemtab3,'codpay');
			if (upper(v_mode) = 'EDIT') then
				update ttpunsh
				   set codexemp = v_codexemp,
                       codpunsh = v_codpunsh,
                       dtestart = v_dtestart,
                       dteend = v_dteend,
                       codcomp = v_codcomp,
                       codjob = v_codjob,
                       codpos = v_codpos,
                       flgexempt = v_flgexempt ,
                       typpun = v_typpun,
                       flgssm = v_flgssm,
                       flgblist = v_flgblist,
                       remark = v_remark,
                       dteupd = sysdate,
                       coduser = global_v_coduser
				 where codempid = v_codempid
				   and dteeffec = v_dteeffec
				   and codpunsh = v_codpunshold
				   and numseq = v_numseq;
				if (v_typpun in ('1', '5') and v_codpay is not null) then
					--edit
					if ( upper(hcm_util.get_string_t(v_obj_itemtab3,'mode')) = 'EDIT' ) then
						save_ttpunded ( i , 'EDIT' , v_codpunsh ,v_codpunshold,v_dteeffec ,v_codcomp, v_objdatatab1,v_obj_itemtab2 ,v_objdatatab3);
					else
						save_ttpunded ( i, 'ADD', v_codpunsh ,v_codpunshold,v_dteeffec ,v_codcomp, v_objdatatab1,v_obj_itemtab2 ,v_objdatatab3);
					end if;
				else
					-- delete
					save_ttpunded ( i , 'DEL' , null ,v_codpunshold,v_dteeffec ,v_codcomp, v_objdatatab1,null ,null);
				end if;

				if (param_msg_error is not null) then
					return;
				end if;
			else

				v_next_seq := find_max_seq_ttpunsh(v_codempid,v_dteeffec,v_codpunsh);
				insert into ttpunsh( codempid,dteeffec,codpunsh, numseq,dtestart,dteend,
                                     codcomp,codjob,codpos, numlvl,typpun,remark,
                                     flgexempt,codexemp,flgblist, flgssm,jobgrade,codgrpgl,
                                     dtecreate,codcreate,coduser, staupd)
				     values (v_codempid,v_dteeffec,v_codpunsh, v_numseq,v_dtestart,v_dteend,
                             v_codcomp,v_codjob,v_codpos, v_numlvl,v_typpun,v_remark,
                             v_flgexempt,v_codexemp,v_flgblist, v_flgssm,v_jobgrade,v_codgrpgl,
                             sysdate,global_v_coduser,global_v_coduser, 'P');

                if (v_typpun in ('1', '5') and v_codpay is not null) then
                    save_ttpunded ( i, 'ADD', v_codpunsh ,v_codpunshold,v_dteeffec ,v_codcomp, v_objdatatab1,v_obj_itemtab2 ,v_objdatatab3);
                end if;

				if (param_msg_error is not null) then
					return;
				end if;
			end if;
		end loop;
	end save_ttpunsh;

	procedure save_ttpunded (
		v_index			in number,
		v_mode			in varchar2,
		v_codpunsh		in varchar2,
        v_codpunshold   in varchar2,
        v_dteeffec      date,
		v_codcomp		in varchar2,
		v_objdatatab1	in json_object_t,
        v_objdatatab2   in json_object_t,
        v_objdatatab3   in json_object_t) as
		v_codempid		ttpunded.codempid%type;
		v_dteyearst		ttpunded.dteyearst%type;
		v_dtemthst		ttpunded.dtemthst%type;
		v_numprdst		ttpunded.numprdst%type;
		v_dteyearen		ttpunded.dteyearen%type;
		v_dtemthen		ttpunded.dtemthen%type;
		v_numprden		ttpunded.numprden%type;
		v_codpay		ttpunded.codpay%type;
		v_amtincom1		ttpunded.amtincom1%type := null;
		v_amtincom2		ttpunded.amtincom2%type := null;
		v_amtincom3		ttpunded.amtincom3%type := null;
		v_amtincom4		ttpunded.amtincom4%type := null;
		v_amtincom5		ttpunded.amtincom5%type := null;
		v_amtincom6		ttpunded.amtincom6%type := null;
		v_amtincom7		ttpunded.amtincom7%type := null;
		v_amtincom8		ttpunded.amtincom8%type := null;
		v_amtincom9		ttpunded.amtincom9%type := null;
		v_amtincom10	ttpunded.amtincom10%type := null;
		v_amtincded1	ttpunded.amtincded1%type := null;
		v_amtincded2	ttpunded.amtincded2%type := null;
		v_amtincded3	ttpunded.amtincded3%type := null;
		v_amtincded4	ttpunded.amtincded4%type := null;
		v_amtincded5	ttpunded.amtincded5%type := null;
		v_amtincded6	ttpunded.amtincded6%type := null;
		v_amtincded7	ttpunded.amtincded7%type := null;
		v_amtincded8	ttpunded.amtincded8%type := null;
		v_amtincded9	ttpunded.amtincded9%type := null;
		v_amtincded10	ttpunded.amtincded10%type := null;
		v_amtdoth		ttpunded.amtdoth%type;
		v_amtded		ttpunded.amtded%type;
		v_amttotded		ttpunded.amttotded%type;
		v_dtecreate		ttpunded.dtecreate%type;
		v_codcreate		ttpunded.codcreate%type;
		v_dteupd		ttpunded.dteupd%type;
		v_coduser		ttpunded.coduser%type;

		v_item_ttpunded	json_object_t;
	begin
		v_codempid := hcm_util.get_string_t(v_objdatatab1,'v_codempid');

		if ( upper(v_mode) = 'ADD' or upper(v_mode) = 'EDIT' ) then

			v_item_ttpunded := hcm_util.get_json_t(v_objdatatab3,v_index);

			init_amtincom_amtincded ( v_item_ttpunded, v_codempid , v_amtincom1 ,
                                      v_amtincom2 , v_amtincom3 , v_amtincom4 ,
                                      v_amtincom5 , v_amtincom6 , v_amtincom7 ,
                                      v_amtincom8 , v_amtincom9 , v_amtincom10,
                                      v_amtincded1, v_amtincded2, v_amtincded3,
                                      v_amtincded4, v_amtincded5, v_amtincded6,
                                      v_amtincded7, v_amtincded8, v_amtincded9,
                                      v_amtincded10);
			v_dteyearst     := to_number(hcm_util.get_string_t(v_item_ttpunded,'dteyearst')) - hcm_appsettings.get_additional_year();
			v_dtemthst      := hcm_util.get_string_t(v_item_ttpunded,'dtemthst');
			v_numprdst      := hcm_util.get_string_t(v_item_ttpunded,'numprdst');
			v_dteyearen     := to_number(hcm_util.get_string_t(v_item_ttpunded,'dteyearen')) - hcm_appsettings.get_additional_year() ;
			v_dtemthen      := hcm_util.get_string_t(v_item_ttpunded,'dtemthen');
			v_numprden      := hcm_util.get_string_t(v_item_ttpunded,'numprden');
			v_codpay        := hcm_util.get_string_t(v_item_ttpunded,'codpay');
			v_amtdoth       := stdenc(hcm_util.get_string_t(v_item_ttpunded,'amtdoth'), v_codempid, global_v_chken);
			v_amtded        := stdenc(hcm_util.get_string_t(v_item_ttpunded,'suminperiod'), v_codempid, global_v_chken);
			v_amttotded     := stdenc(hcm_util.get_string_t(v_item_ttpunded,'sumperiod'), v_codempid, global_v_chken);

			if (upper(v_mode) = 'ADD') then
				begin
					insert into ttpunded ( codempid,dteeffec,codpunsh,
                                           codcomp,dteyearst,dtemthst,
                                           numprdst,dteyearen,dtemthen,
                                           numprden,codpay, amtincom1,
                                           amtincom2,amtincom3,amtincom4,
                                           amtincom5,amtincom6,amtincom7,
                                           amtincom8,amtincom9,amtincom10,
                                           amtincded1,amtincded2,amtincded3,
                                           amtincded4,amtincded5,amtincded6,
                                           amtincded7,amtincded8,amtincded9,
                                           amtincded10,amtdoth,amtded,amttotded,
                                           dtecreate,codcreate,coduser)
					     values ( v_codempid,v_dteeffec,v_codpunsh,
                                  v_codcomp,v_dteyearst,v_dtemthst,
                                  v_numprdst,v_dteyearen,v_dtemthen,
                                  v_numprden,v_codpay,v_amtincom1 ,
                                  v_amtincom2 , v_amtincom3 , v_amtincom4 ,
                                  v_amtincom5 , v_amtincom6 , v_amtincom7 ,
                                  v_amtincom8 , v_amtincom9 , v_amtincom10,
                                  v_amtincded1, v_amtincded2, v_amtincded3,
                                  v_amtincded4, v_amtincded5, v_amtincded6,
                                  v_amtincded7, v_amtincded8, v_amtincded9,
                                  v_amtincded10,v_amtdoth,v_amtded,v_amttotded,
                                  sysdate,global_v_coduser,global_v_coduser);
				exception
                when dup_val_on_index then
					param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TTPUNDED');
					return;
				when others then
					param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
					return ;
				end;
			elsif (upper(v_mode) = 'EDIT' ) then
				update ttpunded
				   set codpunsh = v_codpunsh,
                       dteyearst = v_dteyearst,
                       dtemthst = v_dtemthst,
                       numprdst = v_numprdst,
                       dteyearen = v_dteyearen,
                       dtemthen = v_dtemthen,
                       numprden = v_numprden,
                       codpay = v_codpay,
                       amtincom1 = v_amtincom1,
                       amtincom2 = v_amtincom2,
                       amtincom3 = v_amtincom3,
                       amtincom4 = v_amtincom4,
                       amtincom5 = v_amtincom5,
                       amtincom6 = v_amtincom6,
                       amtincom7 = v_amtincom7,
                       amtincom8 = v_amtincom8,
                       amtincom9 = v_amtincom9,
                       amtincom10 = v_amtincom10,
                       amtincded1 = v_amtincded1,
                       amtincded2 = v_amtincded2,
                       amtincded3 = v_amtincded3,
                       amtincded4 = v_amtincded4,
                       amtincded5 = v_amtincded5,
                       amtincded6 = v_amtincded6,
                       amtincded7 = v_amtincded7,
                       amtincded8 = v_amtincded8,
                       amtincded9 = v_amtincded9,
                       amtincded10 = v_amtincded10,
                       amtdoth = v_amtdoth,
                       amtded = v_amtded,
                       amttotded = v_amttotded,
                       dteupd = sysdate,
                       coduser = global_v_coduser
				 where codempid = v_codempid
				   and dteeffec = v_dteeffec
				   and codpunsh = v_codpunshold;
			end if;
		else
			delete
              from ttpunded
			 where codempid = v_codempid
			   and dteeffec = v_dteeffec
			   and codpunsh = v_codpunshold;
		end if;
	end save_ttpunded;

	procedure init_amtincom_amtincded (
		v_item_ttpunded		in json_object_t,
		v_codempid		    in varchar2,
		v_amtincom1		    out ttpunded.amtincom1%type,
		v_amtincom2		    out ttpunded.amtincom2%type,
		v_amtincom3		    out ttpunded.amtincom3%type,
		v_amtincom4		    out ttpunded.amtincom4%type,
		v_amtincom5		    out ttpunded.amtincom5%type,
		v_amtincom6		    out ttpunded.amtincom6%type,
		v_amtincom7		    out ttpunded.amtincom7%type,
		v_amtincom8		    out ttpunded.amtincom8%type,
		v_amtincom9		    out ttpunded.amtincom9%type,
		v_amtincom10		out ttpunded.amtincom10%type,
		v_amtincded1		out ttpunded.amtincded1%type,
		v_amtincded2		out ttpunded.amtincded2%type,
		v_amtincded3		out ttpunded.amtincded3%type,
		v_amtincded4		out ttpunded.amtincded4%type,
		v_amtincded5		out ttpunded.amtincded5%type,
		v_amtincded6		out ttpunded.amtincded6%type,
		v_amtincded7		out ttpunded.amtincded7%type,
		v_amtincded8		out ttpunded.amtincded8%type,
		v_amtincded9		out ttpunded.amtincded9%type,
		v_amtincded10		out ttpunded.amtincded10%type) as
		v_obj_row		    json_object_t;
		v_size_obj_row		number;
		v_obj_item		    json_object_t;
		v_item_amtincom		number;
		v_item_amtincded	number;
		v_item_index		varchar2(10 char);
	begin

		v_obj_row       := hcm_util.get_json_t(v_item_ttpunded,'rows');
		v_size_obj_row  := v_obj_row.get_size;
		for i in 0..v_size_obj_row-1 loop
			v_obj_item          := hcm_util.get_json_t(v_obj_row,i);
			v_item_index        := hcm_util.get_string_t(v_obj_item,'rowIndex');
			v_item_amtincom     := to_number(replace(hcm_util.get_string_t(v_obj_item,'amtincom'),',',''));
			v_item_amtincded    := to_number(replace(hcm_util.get_string_t(v_obj_item,'amtincded'),',',''));

			if (v_item_index = '1') then
				v_amtincom1     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded1    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '2') then
				v_amtincom2     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded2    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '3') then
				v_amtincom3     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded3    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '4') then
				v_amtincom4     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded4    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '5') then
				v_amtincom5     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded5    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '6') then
				v_amtincom6     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded6    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '7') then
				v_amtincom7     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded7    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '8') then
				v_amtincom8     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded8    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '9') then
				v_amtincom9     := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded9    := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			elsif (v_item_index = '10') then
				v_amtincom10    := stdenc(v_item_amtincom, v_codempid, global_v_chken);
				v_amtincded10   := stdenc(v_item_amtincded, v_codempid, global_v_chken);
			end if;
		end loop;
	end init_amtincom_amtincded;

	procedure post_delete (json_str_input in clob, json_str_output out clob) as
		json_str		json_object_t;
		param_json		json_object_t;
		param_json_row	json_object_t;
        v_codempid      TTPUNDED.codempid%type;
        v_dteeffec      TTPUNDED.dteeffec%type;
	begin
		initial_value(json_str_input);
		json_str    := json_object_t(json_str_input);
		param_json  := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
		for i in 0..param_json.get_size-1 loop
			param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
            v_codempid      := hcm_util.get_string_t(param_json_row, 'codempid');
            v_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'), 'dd/mm/yyyy') ;
			begin
				delete TTPUNDED
				 where codempid = v_codempid
				   and dteeffec = v_dteeffec ;

                delete ttmistk
				 where codempid = v_codempid
				   and dteeffec = v_dteeffec ;

                delete TTPUNSH
				 where codempid = v_codempid
				   and dteeffec = v_dteeffec;
				commit;
			exception when others then
                null;
			end;
		end loop;
		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

/* Redmine #5559
	procedure check_tdtepay (v_codcomp in varchar2,v_typpayroll in varchar2 ,
		v_periodstr		in varchar2 , v_periodend in varchar2) as
		v_count			number;
	begin
		begin
			select count(*) into v_count
			  from tdtepay
			 where codcompy = v_codcomp
			   and typpayroll = v_typpayroll
			   and dteyrepay||lpad(dtemthpay,2,0)||lpad(numperiod,2,0) between v_periodstr and v_periodend;

			if (v_count = 0) then
				param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TDTEPAY');
			end if;
		end;
	end check_tdtepay;
Redmine #5559 */
--Redmine #5559
	procedure check_tdtepay(p_codcomp   in varchar2, p_typpayroll in varchar2 ,
                            p_dteyearst in number ,  p_dtemthst in number , p_numprdst in number ,
                            p_dteyearen in number ,  p_dtemthen in number , p_numprden in number) as
        v_count			number;
        v_year_run      number;
        v_dtemthst      number := p_dtemthst;
        v_dtemthen      number := p_dtemthen;
        v_periodstr     varchar2(30);
        v_periodend     varchar2(30);

	begin
--Redmine #5559
        v_year_run := p_dteyearst;

        for i in 1..(p_dteyearen - p_dteyearst) + 1 loop
--
            if v_year_run = p_dteyearst or v_year_run = p_dteyearen then
                if p_dteyearst = p_dteyearen then
                    v_dtemthst := p_dtemthst;
                else v_dtemthst := 1;
                end if;
                v_dtemthen := p_dtemthen;
            else
                v_dtemthst := 1;
                v_dtemthen := 12;
            end if;

            for j in v_dtemthst..v_dtemthen loop
                for k in p_numprdst..p_numprden loop
                    v_periodstr := (v_year_run) ||lpad(j ,2,0)||lpad(k,2,0);
                    begin
                        select count(*) into v_count
                          from tdtepay
                         where codcompy = p_codcomp
                           and typpayroll = p_typpayroll
                           and dteyrepay||lpad(dtemthpay,2,0)||lpad(numperiod,2,0) = v_periodstr;

                        if (nvl(v_count,0) = 0) then
                            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TDTEPAY');
                            return;
                        end if;
                    end;
                end loop;
            end loop;
--
            v_year_run := v_year_run + 1;
        end loop;
    end;
--Redmine #5559

	procedure check_tinexinfc (v_codcomp in varchar2, v_codpay in varchar2) as
		v_count number;
	begin
		begin
			select count(*)
              into v_count
			  from tinexinfc
			 where codcompy = v_codcomp
			   and codpay = v_codpay;

			if (v_count = 0) then
				param_msg_error := get_error_msg_php('PY0044', global_v_lang);
				return ;
			end if;
		end;
	end check_tinexinfc;

	procedure check_tinexinf (v_codpay in varchar2) as
		v_typpay    tinexinf.typpay%type;
	begin
		begin
			select typpay
              into v_typpay
			  from tinexinf
			 where codpay = v_codpay;

			if (v_typpay in ('1','2','3') ) then
				param_msg_error := get_error_msg_php('HR1504', global_v_lang);
			end if;
		exception when no_data_found then
			param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TINEXINF');
			return ;
		end;
	end check_tinexinf;

	procedure getSendmail (json_str_input in clob, json_str_output out clob) as
		json_obj		    json_object_t;
		v_msg_to            clob;
		v_templete_to       clob;
		v_func_appr         tfwmailh.codappap%type;
		v_rowid             rowid;
		v_error			    terrorm.errorno%type;
		ttmistk_codempid	ttmistk.codempid%type;
		ttmistk_codreq		ttmistk.codempid%type;
		flg			        number;
		obj_respone		    json_object_t;
		obj_respone_data    varchar(500);
		obj_sum			    json_object_t;
        v_approvno          ttmistk.approvno%type;
        v_stderror          VARCHAR2(20);
	begin
        initial_value(json_str_input);
		json_obj            := json_object_t(json_str_input);
		v_rowid             := hcm_util.get_string_t(json_obj,'v_rowid');
		ttmistk_codempid    := hcm_util.get_string_t(json_obj,'ttmistk_codempid');
		ttmistk_codreq      := hcm_util.get_string_t(json_obj,'ttmistk_codreq');
		flg                 := hcm_util.get_string_t(json_obj,'flg');

        begin
            select nvl(approvno,0) + 1
              into v_approvno
              from TTMISTK
             where rowid = v_rowid;
        exception when no_data_found then
            v_approvno := 1;
        end;

        begin
            v_error := chk_flowmail.send_mail_for_approve('HRPM4GE', ttmistk_codempid, ttmistk_codreq, global_v_coduser, null, 'HRPM44U1', 960, 'E', 'P', v_approvno, null, null,'TTMISTK',v_rowid, '1', null);
        exception when others then
            v_stderror := 'HR7522';
        end;

        IF v_error = '2046' THEN
            v_stderror := 'HR2046';
        ELSIF v_error = '7526'   then
            v_stderror := 'HR7526';
        ELSE
            v_stderror := 'HR7522';
        END IF;
        param_msg_error := get_error_msg_php(v_stderror, global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
	end ;

	procedure delete_ttpunsh (json_str_input in clob) as
		v_obj			    json_object_t;
		v_obj_delete		json_object_t;
		v_size_obj_delete	number;
		v_obj_item_delete	json_object_t;
		v_obj_itemdetail	json_object_t;
		v_obj_itemtpunded	json_object_t;
		v_codempid_ttpunsh	ttpunsh.codempid%type;
		v_dteeffec_ttpunsh	ttpunsh.dteeffec%type;
		v_codpunsh_ttpunsh	ttpunsh.codpunsh%type;
		v_numseq_ttpunsh	ttpunsh.numseq%type;
		v_typpun_ttpunsh	ttpunsh.typpun%type;
		v_mode_ttpunsh		varchar2(10 char);
	begin
		v_obj               := json_object_t(json_str_input);
		v_obj_delete        := hcm_util.get_json_t(v_obj,'v_datadelete');
		v_size_obj_delete   := v_obj_delete.get_size;

		for i in 0..v_size_obj_delete-1 loop
			v_obj_item_delete   := hcm_util.get_json_t(v_obj_delete,i);
			v_codempid_ttpunsh  := hcm_util.get_string_t(v_obj_item_delete, 'codempid');
			v_dteeffec_ttpunsh  := to_date(hcm_util.get_string_t(v_obj_item_delete, 'dteeffec'),'dd/mm/yyyy');
			v_obj_itemdetail    := hcm_util.get_json_t(v_obj_item_delete,'itemdetail');
			v_obj_itemtpunded   := hcm_util.get_json_t(v_obj_item_delete,'itemtpunded');
			v_codpunsh_ttpunsh  := hcm_util.get_string_t(v_obj_itemdetail, 'codpunshold');
			v_numseq_ttpunsh    := to_number(hcm_util.get_string_t(v_obj_itemdetail, 'numseq'));
			v_mode_ttpunsh      := hcm_util.get_string_t(v_obj_itemdetail, 'mode');
			v_typpun_ttpunsh    := hcm_util.get_string_t(v_obj_itemdetail, 'typpun');
			if (upper(v_mode_ttpunsh) = 'EDIT') then
				begin
					delete
                      from ttpunsh
					 where codempid = v_codempid_ttpunsh
					   and dteeffec = v_dteeffec_ttpunsh
					   and codpunsh = v_codpunsh_ttpunsh
					   and numseq = v_numseq_ttpunsh;
				exception when others then
					param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
					return;
				end;

				if (v_typpun_ttpunsh in ('1','5')) then
					delete_ttpunded(v_codempid_ttpunsh,v_dteeffec_ttpunsh,v_codpunsh_ttpunsh);
					if (param_msg_error is not null ) then
						return;
					end if;
				end if;
			end if;
		end loop;
	end;

	procedure delete_ttpunded (
		v_codempid		ttpunded.codempid%type,
		v_dteeffec		ttpunded.dteeffec%type,
		v_codpunsh		ttpunded.codpunsh%type ) as
	begin
		begin
			delete
              from ttpunded
			 where codempid = v_codempid
               and dteeffec = v_dteeffec
			   and codpunsh = v_codpunsh;
		exception when others then
			param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
			return;
		end;
	end delete_ttpunded;

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

	function find_max_seq_ttpunsh (
		v_codempid		in ttpunsh.codempid%type,
		v_dteeffec		in ttpunsh.dteeffec%type,
		v_codpunsh		in ttpunsh.codpunsh%type ) return number is
		v_count			number;
	begin
		select count(*)
          into v_count
		  from ttpunsh
		 where codempid = v_codempid
		   and dteeffec = v_dteeffec
		   and codpunsh = v_codpunsh;

		v_count := v_count + 1;
		return v_count;
	end find_max_seq_ttpunsh ;

	function calculate_amtincadj (v_objrow in json_object_t) return boolean is
		v_size			number;
		v_objitem		json_object_t;
		v_amtincadj		number;
		v_amtincadjOld	number;
		v_amtincded		number;
		v_amtincdedOld	number;
	begin
		v_size := v_objrow.get_size;
		for i in 0..v_size-1 loop
			v_objitem       := hcm_util.get_json_t(v_objrow,i);
			v_amtincadj     := to_number(replace(hcm_util.get_string_t(v_objitem,'amtincadj'),',',''));
			v_amtincadjOld  := to_number(replace(hcm_util.get_string_t(v_objitem,'amtincadjOld'),',',''));
			v_amtincded     := to_number(replace(hcm_util.get_string_t(v_objitem,'amtincded'),',',''));
			v_amtincdedOld  := to_number(replace(hcm_util.get_string_t(v_objitem,'amtincdedOld'),',',''));

            if (v_amtincadj <> v_amtincadjOld) then
				return true;
			end if;

		end loop;
		return false;
	end calculate_amtincadj;

  --Redmine #5559
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
/*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --Redmine #5559

end;

/
