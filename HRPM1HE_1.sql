--------------------------------------------------------
--  DDL for Package Body HRPM1HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM1HE" is
-- last update: 10/10/2019
  procedure initial_value(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str);
		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

		--all
		p_memono := hcm_util.get_string_t(json_obj,'p_memono');
		p_dteeffec := hcm_util.get_string_t(json_obj,'p_dteeffec');
		--save
		p_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		p_flgeffec := hcm_util.get_string_t(json_obj,'p_flgeffec');
		p_subject := hcm_util.get_string_t(json_obj,'p_subject');

        p_message := get_clob (json_str,'p_message');

		p_qtydayr := hcm_util.get_string_t(json_obj,'p_qtydayr');
		p_syncond := hcm_util.get_string_t(json_obj,'p_syncond');

		p_date := hcm_util.get_string_t(json_obj,'p_date');
		p_mailalno := hcm_util.get_string_t(json_obj,'p_mailalno');
		p_pfield := hcm_util.get_string_t(json_obj,'p_pfield');
		p_pdesct := hcm_util.get_string_t(json_obj,'p_pdesct');
		p_flgdesc := hcm_util.get_string_t(json_obj,'p_flgdesc');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
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
		v_data			varchar2(1) := 'N';
		cursor c1 is
      SELECT *
      from tmailalert
      order by memono,dteeffec desc;
	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			v_data := 'Y';
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('mailno', r1.memono);
			obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('st', get_tlistval_name('FLGAPPRS',r1.flgeffec,global_v_lang));
			obj_data.put('subject', r1.subject);
--			obj_data := append_clob_json(obj_data,'message',r1.message);
			obj_data.put('syncond', r1.syncond);
			obj_data.put('codempid', r1.codempid);
			obj_data.put('repname', r1.repname);
			obj_data.put('qtydayr', r1.qtydayr);
			obj_data.put('dtelast', r1.dtelast);
			obj_data.put('dtecreate', r1.dtecreate);
			obj_data.put('codcreate', r1.codcreate);
			obj_data.put('dteupd', to_char(r1.dteupd,'dd/mm/yyyy'));
			obj_data.put('coduser', r1.coduser);

			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;

--        if v_data = 'N' then
--           param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TMAILALERT');
--        end if;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
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
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_dropdown		json_object_t;
		v_rcntDropdown		number := 0;
		v_rcnt			number := 0;
		is_found_rec		boolean := false;
		cursor c1 is
		SELECT *
    from tmailalert
		where memono = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
		order by memono,dteeffec desc;

		cursor cDropdown is
		select * from TLISTVAL where CODAPP = 'TYPESEND'
		and codlang = global_v_lang and numseq > 0 and list_value not in ('2');

	begin
		obj_row := json_object_t();

		obj_dropdown := json_object_t();
		for c2 in cDropdown loop
			v_rcntDropdown := v_rcnt+1;
			obj_dropdown.put(c2.list_value, c2.desc_label);
		end loop;
		obj_row.put('dropdown', obj_dropdown);

		for r1 in c1 loop
			v_rcnt := v_rcnt+1;

			is_found_rec := true;
			obj_row.put('coderror', '200');
			obj_row.put('rcnt', to_char(v_rcnt));
			obj_row.put('mailno', r1.memono);
			obj_row.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_row.put('st', r1.flgeffec);
			obj_row.put('subject', r1.subject);
			obj_row := append_clob_json(obj_row,'message',r1.message);
			obj_row.put('syncond', r1.syncond);

			obj_row.put('codempid', r1.codempid);
			obj_row.put('repname', r1.repname);
			obj_row.put('qtydayr', r1.qtydayr);
			obj_row.put('dtelast', r1.dtelast);
			obj_row.put('dtecreate', r1.dtecreate);
			obj_row.put('codcreate', r1.codcreate);
			obj_row.put('dteupd', to_char(r1.dteupd,'dd/mm/yyyy'));
			obj_row.put('userid', GET_CODEMPID(r1.coduser));
			obj_row.put('coduser', GET_CODEMPID(r1.coduser));

		end loop;

		if not is_found_rec then

			obj_row.put('coderror', '200');
			obj_row.put('mailno', 0);
			obj_row.put('dteeffec', '');
			obj_row.put('st', '');
			obj_row.put('subject', '');
			obj_row.put('message', '');
			obj_row.put('syncond', '');
			obj_row.put('codempid', global_v_codempid);
			obj_row.put('repname', '');
			obj_row.put('qtydayr', '');
			obj_row.put('dtelast', '');
			obj_row.put('dtecreate', '');
			obj_row.put('codcreate', '');
			obj_row.put('dteupd', '');
			obj_row.put('coduser', '');
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

	procedure getTable (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		genTable(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genTable (json_str_output out clob) as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
		is_found_rec		boolean := false;
		cursor c_table is
		SELECT CODTABLE,DECODE(global_v_lang,
		'101',DESTABE,
		'102',DESTABT,
		'103',DESTAB3,
		'104',DESTAB4,
		'105',DESTAB5,NULL)DESAPP
		from TTABDESC
		where CODTABLE in (select tname
		from TMAILALED
		where memono = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec)
		order by CODTABLE desc;

		cursor c1 is
		SELECT * from tmailalert
		where memono = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
		order by memono,dteeffec desc;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();

		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			is_found_rec := true;
			obj_row.put('coderror', '200');
			obj_row.put('rcnt', to_char(v_rcnt));
			obj_row.put('mailno', r1.memono);
			obj_row.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_row.put('st', r1.flgeffec);
			obj_row.put('subject', r1.subject);
      obj_row := append_clob_json(obj_data,'message',r1.message);
			obj_row.put('syncond', r1.syncond);
			obj_row.put('codempid', r1.codempid);
			obj_row.put('repname', r1.repname);
			obj_row.put('qtydayr', r1.qtydayr);
			obj_row.put('dtelast', r1.dtelast);
			obj_row.put('dtecreate', r1.dtecreate);
			obj_row.put('codcreate', r1.codcreate);
			obj_row.put('dteupd', r1.dteupd);
			obj_row.put('coduser', '');
		end loop;

		if not is_found_rec then
			obj_data := json_object_t();
			obj_row.put('coderror', '200');
			obj_row.put('mailno', 0);
			obj_row.put('dteeffec', '');
			obj_row.put('st', '');
			obj_row.put('subject', '');
			obj_row.put('message', '');
			obj_row.put('syncond', '');
			obj_row.put('codempid', '');
			obj_row.put('repname', '');
			obj_row.put('qtydayr', '');
			obj_row.put('dtelast', '');
			obj_row.put('dtecreate', '');
			obj_row.put('codcreate', '');
			obj_row.put('dteupd', '');
			obj_row.put('coduser', '');

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

	procedure post_save (json_str_input in clob, json_str_output out clob) is
		json_obj		        json_object_t;
		json_str		        json_object_t;
		param_json		        json_object_t;
		param_json_row		    json_object_t;
        param_json_people		json_object_t;
		param_json_row_people	json_object_t;
        count_emp		        number := 0;
        v_countRow		        number := 0;
        v_countNumseq		    number := 0;
		v_countCheck		    number := 0;
        v_countWhenNoPeopleRow	number := 0;
        v_codcomp		        varchar2(100);
		v_codpos		        varchar2(100);
        v_mailno                varchar2(1000 char);
        v_dteeffec              varchar2(1000 char);
        v_flgappr               varchar2(1000 char);
        v_codcompap             varchar2(1000 char);
        v_codposap              varchar2(1000 char);
        v_tname                 varchar2(1000 char);
        v_tnameold              varchar2(1000 char);

    begin
		initial_value(json_str_input);
		json_str            := json_object_t(json_str_input);
		param_json          := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
        param_json_people   := json_object_t(hcm_util.get_string_t(json_str, 'json_input_people'));
		for i in 0..param_json.get_size-1 loop
			param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
            v_tname         := hcm_util.get_string_t(param_json_row,'tname');
			begin
                SELECT count(*)
                  into count_emp
                  FROM TCOLDESC
                 WHERE CODTABLE = v_tname
                   and CODCOLMN = 'CODEMPID'
              ORDER BY COLUMN_ID;

                if count_emp != 0 then
                    EXIT;
                end if;
            end;
		end loop;
        for i in 0..param_json_people.get_size-1 loop
            param_json_row_people := hcm_util.get_json_t(param_json_people,to_char(i));
            if hcm_util.get_string_t(param_json_row_people,'flg') is null then
                if hcm_util.get_string_t(param_json_row_people,'flgappr') is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            end if;

            if hcm_util.get_string_t(param_json_row_people,'flg') != 'delete' then
                v_countRow := 0;
                v_countCheck := 1;
                if nvl(hcm_util.get_string_t(param_json_row_people,'seqno'),'nulll') != hcm_util.get_string_t(param_json_row_people,'flgappr') then
                    if hcm_util.get_string_t(param_json_row_people,'flgappr') = '3' then
                        v_mailno    := hcm_util.get_string_t(param_json_row_people,'mailno');
                        v_dteeffec  := hcm_util.get_string_t(param_json_row_people,'dteeffec');
                        v_flgappr   := hcm_util.get_string_t(param_json_row_people,'flgappr');
                        v_codcompap := hcm_util.get_string_t(param_json_row_people,'codcompap');
                        v_codposap  := hcm_util.get_string_t(param_json_row_people,'codposap');
                        select count(*) into v_countRow from TMAILASGN
                        where MEMONO  = v_mailno
                        and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                        and flgappr   = v_flgappr
                        and codcompap = v_codcompap
                        and codposap  = v_codposap;
                    elsif hcm_util.get_string_t(param_json_row_people,'flgappr') = '4' then
                        v_mailno    := hcm_util.get_string_t(param_json_row_people,'mailno');
                        v_dteeffec  := hcm_util.get_string_t(param_json_row_people,'dteeffec');
                        v_flgappr   := hcm_util.get_string_t(param_json_row_people,'flgappr');
                        v_codcompap := hcm_util.get_string_t(param_json_row_people,'codempap');
                        select count(*) into v_countRow from TMAILASGN
                        where MEMONO = v_mailno
                        and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                        and flgappr  = v_flgappr
                        and codempap = v_codcompap;
                    else
                        v_mailno    := hcm_util.get_string_t(param_json_row_people,'mailno');
                        v_dteeffec  := hcm_util.get_string_t(param_json_row_people,'dteeffec');
                        v_flgappr   := hcm_util.get_string_t(param_json_row_people,'flgappr');
                        select count(*) into v_countRow from TMAILASGN
                        where MEMONO = v_mailno
                        and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                        and flgappr  = v_flgappr;
                    end if;
                    if v_countRow = 1 then
                           param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                    end if;
                 end if;
                 if hcm_util.get_string_t(param_json_row_people,'flgappr') = '1' or
                    hcm_util.get_string_t(param_json_row_people,'flgappr') = '5' then
                    if count_emp = 0 then
                        param_msg_error := get_error_msg_php('HR1509',global_v_lang);
                    end if;
                end if;
            else
                v_countWhenNoPeopleRow := v_countWhenNoPeopleRow + 1;
            end if;
        end loop;

        if param_json_people.get_size = v_countWhenNoPeopleRow then
                if count_emp = 0 then
                    v_countWhenNoPeopleRow := 0;
                    select count(*)
                      into v_countWhenNoPeopleRow
                      from TMAILASGN
                     where MEMONO = p_memono
                       and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
                       and (flgappr = '1' or flgappr = '5');

                    if v_countWhenNoPeopleRow != 0 then
                        param_msg_error := get_error_msg_php('HR1509',global_v_lang);
                    end if;
                end if;
        end if;

		if v_countCheck = 0 then
            select count(*) into v_countCheck from TMAILASGN
			where memono = p_memono
			and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec ;
			if v_countCheck = 0 then
				param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TMAILASG');
			end if;
        end if;

		if param_msg_error is null then
			begin
				update tmailalert
				set
				FLGEFFEC = p_flgeffec,
				SUBJECT = p_subject,
				MESSAGE = p_message,
				CODEMPID = p_codempid,
				QTYDAYR = p_qtydayr,
				SYNCOND = p_syncond,
				CODUSER = global_v_coduser
				where memono = p_memono
				and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec ;
				if sql%rowcount = 0 then
					INSERT INTO tmailalert (MEMONO, DTEEFFEC, FLGEFFEC,SUBJECT,MESSAGE,CODEMPID,QTYDAYR,SYNCOND,CODUSER,CODCREATE)
					VALUES (p_memono, to_date(p_dteeffec,'dd/mm/yyyy'), p_flgeffec, p_subject,p_message,p_codempid,p_qtydayr,p_syncond,global_v_coduser,global_v_coduser);
				end if;
			end;
			for i in 0..param_json.get_size-1 loop
				param_json_row := hcm_util.get_json_t(param_json,to_char(i));
				if hcm_util.get_string_t(param_json_row,'tname') is not null then
					if hcm_util.get_string_t(param_json_row,'flgDelete1') = 'true' then
                        v_tnameold := hcm_util.get_string_t(param_json_row,'tnameOld');
						begin
							delete TMAILALED
							where MEMONO = p_memono
							and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
							and TNAME = v_tnameold;
						exception
						when others then null;
						end;
					end if;
				end if;
			end loop;
			for i in 0..param_json.get_size-1 loop
				param_json_row := hcm_util.get_json_t(param_json,to_char(i));
				if hcm_util.get_string_t(param_json_row,'tname') is not null then
					if hcm_util.get_string_t(param_json_row,'flgEdit1') = 'true' and hcm_util.get_string_t(param_json_row,'flgAdd1') != 'true' then
                        v_tname    := hcm_util.get_string_t(param_json_row, 'tname');
                        v_tnameold := hcm_util.get_string_t(param_json_row,'tnameOld');
						update TMAILALED
						   set TNAME = v_tname,
						       CODUSER = global_v_coduser
						 where MEMONO = p_memono
					   	   and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
						   and TNAME = v_tnameold;
					end if;
				end if;
			end loop;
			for i in 0..param_json.get_size-1 loop
				param_json_row := hcm_util.get_json_t(param_json,to_char(i));
				if hcm_util.get_string_t(param_json_row,'tname') is not null then
					if hcm_util.get_string_t(param_json_row,'flgAdd1') = 'true' then
                        v_tname := hcm_util.get_string_t(param_json_row, 'tname');
						INSERT INTO TMAILALED (MEMONO, DTEEFFEC, TNAME,CODUSER,CODCREATE)
						VALUES (
						p_memono,
						to_date(p_dteeffec,'dd/mm/yyyy'),
						v_tname,
						global_v_coduser,global_v_coduser);
					end if;
				end if;
			end loop;
		end if;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_list_detail_param(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		g_typsubj := hcm_util.get_string_t(json_obj, 'p_typsubj');
		p_memono := hcm_util.get_string_t(json_obj,'p_memono');
		p_dteeffec := hcm_util.get_string_t(json_obj,'p_dteeffec');
		gen_list_detail_param(json_str_output);
	 exception when others then
	 	param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	 	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_list_detail_param(json_str_output out clob)as
		obj_data	  	json_object_t;
		obj_row			  json_object_t;
		obj_result		json_object_t;
		v_rcnt			  number := 0;
		name_tcodec		varchar2(200 char);
		name_tcenter	varchar2(200 char);
		name_tpostn		varchar2(200 char);

		cursor list_codtable
		is SELECT * FROM TMAILALED
		where MEMONO = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec;

	begin
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in list_codtable loop
			obj_row.put('coderror', '200');
			obj_row.put(r1.TNAME, r1.TNAME);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

	procedure get_people(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		p_memono := hcm_util.get_string_t(json_obj,'p_memono');
		p_dteeffec := hcm_util.get_string_t(json_obj,'p_dteeffec');
		gen_people(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_people(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result	json_object_t;
		v_rcnt			number := 0;

		cursor list_codtable
		is SELECT * FROM TMAILASGN
		where MEMONO = p_memono
		and dteeffec = to_date(p_dteeffec,'dd/mm/yyyy');

	begin
		obj_data := json_object_t();
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in list_codtable loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('seqno', r1.SEQNO);
			obj_data.put('flgappr', r1.FLGAPPR);
			obj_data.put('codcompap', r1.CODCOMPAP);
			obj_data.put('codposap', r1.CODPOSAP);
			obj_data.put('codempap', r1.CODEMPAP);
			obj_data.put('message', r1.MESSAGE);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

	procedure get_table(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		p_memono := hcm_util.get_string_t(json_obj,'p_memono');
		p_dteeffec := hcm_util.get_string_t(json_obj,'p_dteeffec');
		gen_table(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_table(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result	json_object_t;
		v_rcnt			number := 0;
		cursor list_codtable
		is SELECT * FROM TMAILALED
		where MEMONO = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec;

	begin
		obj_data := json_object_t();
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in list_codtable loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('tname', r1.TNAME);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

  procedure post_report_error (json_str_input in clob, json_str_output out clob) as
  begin
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_save_people (json_str_input in clob, json_str_output out clob) as
		json_str		          json_object_t;
		param_json		        json_object_t;
    param_json_tableRow		json_object_t;
    param_json_table_row	json_object_t;
		param_json_row		    json_object_t;
		v_numseq		          number := 0;
		v_countRow		        number := 0;
    v_countWhenNoPeopleRow		number := 0;
    v_countNumseq		      number := 0;
		v_flag			          varchar2(10 char);
		v_codcomp		          varchar2(100);
		v_codpos		          varchar2(100);
		count_emp		          number := 0;
    isCodempidExit		    boolean := false;
    v_tname               varchar2(1000 char);
    v_mailno              varchar2(1000 char);
    v_dteeffec            varchar2(1000 char);
    v_seqno               varchar2(1000 char);
    v_flgappr             varchar2(1000 char);
    v_codempap            varchar2(1000 char);
    v_codcompap           varchar2(1000 char);
    v_codposap            varchar2(1000 char);
    v_message             varchar2(1000 char);
    v_flg                 varchar2(1000 char);

	begin
		initial_value(json_str_input);
		json_str := json_object_t(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
        param_json_tableRow := json_object_t(hcm_util.get_string_t(json_str, 'json_tableRow'));
        for i in 0..param_json_tableRow.get_size-1 loop
            param_json_table_row := hcm_util.get_json_t(param_json_tableRow,to_char(i));
            v_tname := hcm_util.get_string_t(param_json_table_row,'tname');
            begin

                    SELECT count(*) into count_emp FROM TCOLDESC
                    WHERE CODTABLE = v_tname
                    and CODCOLMN = 'CODEMPID';
                    if count_emp != 0 then
                        EXIT;
                    end if;
            end;
        end loop;

		for i in 0..param_json.get_size-1 loop
			param_json_row := hcm_util.get_json_t(param_json,to_char(i));
            if hcm_util.get_string_t(param_json_row,'flg') = 'delete' then
                v_mailno   := hcm_util.get_string_t(param_json_row,'mailno');
                v_dteeffec := hcm_util.get_string_t(param_json_row,'dteeffec');
                v_seqno    := hcm_util.get_string_t(param_json_row,'seqno');
                begin
                    delete TMAILASGN
                    where MEMONO = v_mailno
                    and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                    and SEQNO = v_seqno;
                exception
                when others then null;
                end;
            end if;

			begin
                if hcm_util.get_string_t(param_json_row,'flg') != 'delete' then
                    v_countRow := 0;
                    if nvl(hcm_util.get_string_t(param_json_row,'seqno'),'nulll') != hcm_util.get_string_t(param_json_row,'flgappr') then
                        if hcm_util.get_string_t(param_json_row,'flgappr') = '3' then
                            v_mailno    := hcm_util.get_string_t(param_json_row,'mailno');
                            v_dteeffec  := hcm_util.get_string_t(param_json_row,'dteeffec');
                            v_flgappr   := hcm_util.get_string_t(param_json_row,'flgappr');
                            v_codcompap := hcm_util.get_string_t(param_json_row,'codcompap');
                            v_codposap  := hcm_util.get_string_t(param_json_row,'codposap');
                            v_flg       := hcm_util.get_string_t(param_json_row,'flg') ;
                            select count(*) into v_countRow from TMAILASGN
                            where MEMONO  = v_mailno
                            and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                            and flgappr   = v_flgappr
                            and codcompap = v_codcompap
                            and codposap  = v_codposap;
                        elsif hcm_util.get_string_t(param_json_row,'flgappr') = '4' then
                            v_mailno    := hcm_util.get_string_t(param_json_row,'mailno');
                            v_dteeffec  := hcm_util.get_string_t(param_json_row,'dteeffec');
                            v_flgappr   := hcm_util.get_string_t(param_json_row,'flgappr');
                            v_codcompap := hcm_util.get_string_t(param_json_row,'codcompap');
                            select count(*) into v_countRow from TMAILASGN
                            where MEMONO = v_mailno
                            and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                            and flgappr  = v_flgappr
                            and codempap = v_codcompap;
                        else
                            v_mailno    := hcm_util.get_string_t(param_json_row,'mailno');
                            v_dteeffec  := hcm_util.get_string_t(param_json_row,'dteeffec');
                            v_flgappr   := hcm_util.get_string_t(param_json_row,'flgappr');
                            select count(*) into v_countRow from TMAILASGN
                            where MEMONO = v_mailno
                            and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                            and flgappr = v_flgappr;
                        end if;

                        if v_countRow = 1 then
                          if v_flg <> 'edit' then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            ROLLBACK;
                            EXIT;
                          end if;
                        end if;
                     end if;
                    if hcm_util.get_string_t(param_json_row,'flgappr') is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                        ROLLBACK;
                        EXIT;
                    end if;
                    if hcm_util.get_string_t(param_json_row,'flgappr') = '1' or
                        hcm_util.get_string_t(param_json_row,'flgappr') = '5' then
                        if count_emp = 0 then
                            param_msg_error := get_error_msg_php('HR1509',global_v_lang);
                            ROLLBACK;
                            EXIT;
                        end if;
                    end if;
                else
                    v_countWhenNoPeopleRow := v_countWhenNoPeopleRow + 1;
                end if;
			 end;
             if param_json.get_size = v_countWhenNoPeopleRow then
                if count_emp = 0 then
                    v_mailno   := hcm_util.get_string_t(param_json_row,'mailno');
                    v_dteeffec := hcm_util.get_string_t(param_json_row,'dteeffec');
                    v_countWhenNoPeopleRow := 0;
                    select count(*) into v_countWhenNoPeopleRow from TMAILASGN
                    where MEMONO = v_mailno
                    and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
                    and (flgappr = '1' or flgappr = '5');
                    if v_countWhenNoPeopleRow != 0 then
                        param_msg_error := get_error_msg_php('HR1509',global_v_lang);
                        ROLLBACK;
                        EXIT;
                    end if;
                end if;
            end if;

            if param_msg_error is null then
                if hcm_util.get_string_t(param_json_row,'codempap') is not null then
					v_codcomp := null;
					v_codpos := null;
				else
					v_codcomp := hcm_util.get_string_t(param_json_row,'codcompap');
					v_codpos := hcm_util.get_string_t(param_json_row,'codposap');
				end if;
				if hcm_util.get_string_t(param_json_row,'flg') != 'delete' then
          v_mailno    := hcm_util.get_string_t(param_json_row,'mailno');
          v_dteeffec  := hcm_util.get_string_t(param_json_row,'dteeffec');
          v_flgappr   := hcm_util.get_string_t(param_json_row,'flgappr');
          v_codempap  := hcm_util.get_string_t(param_json_row,'codempap');
          v_message   := hcm_util.get_string_t(param_json_row, 'message');
          v_seqno     := hcm_util.get_string_t(param_json_row,'seqno');
					begin
            begin
                select nvl(max(seqno), 0) + 1
                into v_countNumseq
                from TMAILASGN
                where MEMONO = v_mailno
                and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec;
            end;
						update TMAILASGN
              set
              FLGAPPR   = v_flgappr,
              CODCOMPAP = v_codcomp,
              CODPOSAP  = v_codpos,
              CODEMPAP  = v_codempap,
              MESSAGE   = v_message,
              CODUSER   = global_v_coduser
						where MEMONO = v_mailno
						and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
						and SEQNO = v_seqno;
						if sql%rowcount = 0 then
							INSERT INTO TMAILASGN (MEMONO, DTEEFFEC, SEQNO,FLGAPPR,CODCOMPAP,CODPOSAP,CODEMPAP,MESSAGE,CODUSER,CODCREATE)
							VALUES (
							v_mailno,
							to_date(v_dteeffec,'dd/mm/yyyy'),
							v_countNumseq + 1,
							v_flgappr,
							v_codcomp,
							v_codpos,
							v_codempap,
							v_message,
							global_v_coduser,global_v_coduser);
						end if;
					end;
				end if;
            end if;
		end loop;
		if param_msg_error is null then
            commit;
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_list_detail_table(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		g_codtable := hcm_util.get_string_t(json_obj, 'p_codtable');

		if g_codtable is not null then
			gen_list_detail_table(json_str_output);

		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_list_detail_table(json_str_output out clob)as
		obj_data		  json_object_t;
		obj_row			  json_object_t;
		obj_result		json_object_t;
		v_rcnt			  number := 0;
		name_tcodec		varchar2(200 char);
		name_tcenter	varchar2(200 char);
		name_tpostn		varchar2(200 char);
		v_row			    number := 0;
		cursor C_TCOLDESC is SELECT * FROM TCOLDESC WHERE CODTABLE = g_codtable ORDER BY COLUMN_ID;

	begin
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in C_TCOLDESC loop
			v_row := v_row + 1;
			obj_data := json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('codcolmn',r1.CODCOLMN);
			if global_v_lang = '101' then
				obj_data.put('desc',r1.DESCOLE);
			elsif global_v_lang = '102' then
				obj_data.put('desc',r1.DESCOLT);
			elsif global_v_lang = '103' then
				obj_data.put('desc',r1.DESCOL3);
			elsif global_v_lang = '104' then
				obj_data.put('desc',r1.DESCOL4);
			elsif global_v_lang = '105' then
				obj_data.put('desc',r1.DESCOL5);
			end if;
			obj_row.put(v_row - 1, obj_data);

		end loop;

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

	procedure post_report_format (json_str_input in clob, json_str_output out clob) is
		json_obj		      json_object_t;
		obj_row			      json_object_t;
		obj_data		      json_object_t;
		param_json		    json_object_t;
		param_json_table	json_object_t;
		param_json_row		json_object_t;
		v_rcnt			      number := 0;
		is_found_rec		  boolean := false;
		cursor c1 is
		SELECT * from TMAILREP
		where MEMONO = p_memono
		and to_char(dteeffec,'dd/mm/yyyy') = p_dteeffec
		order by NUMSEQ;
	begin
		initial_value(json_str_input);
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			is_found_rec := true;
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('mailalno', r1.MEMONO);
			obj_data.put('dteeffec', to_char(r1.DTEEFFEC,'dd/mm/yyyy'));
            obj_data.put('codtable', substr(r1.pfield,1,instr(r1.pfield,'.')-1));
			obj_data.put('pfield', substr(r1.pfield,instr(r1.pfield,'.')+1));
			obj_data.put('pdesct', r1.PDESCT);
			obj_data.put('flgdesc', r1.flgdesc);
			obj_data.put('numseq', r1.numseq);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_delete_report_format (json_str_input in clob, json_str_output out clob) as
    json_str		      json_object_t;
    param_json		    json_object_t;
    param_json_row		json_object_t;
    v_numseq		      number := 0;
    v_flag			      varchar2(10 char);
    v_mailalno        varchar2(1000 char);
    v_dteeffec        varchar2(1000 char);
    v_numseqtxt       varchar2(1000 char);
    v_pfield		      varchar2(1000 char);
    v_codtable           varchar2(1000 char);
    v_pdesct		      varchar2(1000 char);
    v_flgdesc		      varchar2(1000 char);
	begin
		initial_value(json_str_input);
		json_str := json_object_t(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
		for i in 0..param_json.get_size-1 loop
			param_json_row := hcm_util.get_json_t(param_json,to_char(i));
			if hcm_util.get_string_t(param_json_row,'flgDelete') = 'true' then
                v_mailalno  := hcm_util.get_string_t(param_json_row, 'mailalno');
                v_dteeffec  := hcm_util.get_string_t(param_json_row, 'dteeffec');
                v_numseqtxt := hcm_util.get_string_t(param_json_row,'numseq');
				begin
					delete TMAILREP
					where MEMONO = v_mailalno
					and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
					and NUMSEQ   = v_numseqtxt;
				exception
				when others then null;
				end;
			else
				if hcm_util.get_string_t(param_json_row,'numseq') = '0' then
                    v_mailalno := hcm_util.get_string_t(param_json_row, 'mailalno');
                    v_dteeffec := hcm_util.get_string_t(param_json_row, 'dteeffec');
                    v_pfield   := hcm_util.get_string_t(param_json_row, 'pfield');
                    v_codtable := hcm_util.get_string_t(param_json_row, 'codtable');
					v_pdesct   := hcm_util.get_string_t(param_json_row, 'pdesct');
					v_flgdesc  := hcm_util.get_string_t(param_json_row,'flgdesc');

					select max(numseq)
					  into v_numseq
                      from tmailrep
                     where dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
                       and memono = v_mailalno;
					if v_numseq is null then
						v_numseq := 0;
					end if;

					INSERT INTO TMAILREP (MEMONO, DTEEFFEC, PFIELD,PDESCT,FLGDESC,NUMSEQ,CODCREATE,CODUSER)
					VALUES (
					v_mailalno,
					to_date(v_dteeffec,'dd/mm/yyyy'),
					v_codtable||'.'||v_pfield,
					substr(v_pdesct,1,150),
					v_flgdesc,
					v_numseq+1,
					global_v_coduser,global_v_coduser);
				else
                    v_mailalno := hcm_util.get_string_t(param_json_row, 'mailalno');
                    v_dteeffec := hcm_util.get_string_t(param_json_row, 'dteeffec');
                    v_pfield   := hcm_util.get_string_t(param_json_row, 'pfield');
                    v_codtable := hcm_util.get_string_t(param_json_row, 'codtable');
					v_flgdesc  := hcm_util.get_string_t(param_json_row,'flgdesc');
					v_pdesct   := hcm_util.get_string_t(param_json_row, 'pdesct');
					v_numseqtxt:= hcm_util.get_string_t(param_json_row, 'numseq');
					update TMAILREP
					set
					PFIELD = v_codtable||'.'||v_pfield,
					flgdesc = v_flgdesc,
					PDESCT = substr(v_pdesct,1,150),
					CODUSER = global_v_coduser
					where MEMONO = v_mailalno
					and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec
					and NUMSEQ = v_numseqtxt;
				end if;
			end if;
		end loop;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_delete (json_str_input in clob, json_str_output out clob) as
		json_str		    json_object_t;
		param_json		  json_object_t;
		param_json_row	json_object_t;
    v_mailno        varchar2(1000 char);
    v_dteeffec      varchar2(1000 char);

	begin
		initial_value(json_str_input);
		json_str := json_object_t(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));

		for i in 0..param_json.get_size-1 loop
			param_json_row := hcm_util.get_json_t(param_json,to_char(i));
      v_mailno   := hcm_util.get_string_t(param_json_row, 'mailno');
      v_dteeffec := hcm_util.get_string_t(param_json_row, 'dteeffec');
			begin
				delete TMAILALERT
				where memono = v_mailno
				and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec ;
				delete TMAILALED
				where memono = v_mailno
				and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec ;
				delete TMAILREP
				where memono = v_mailno
				and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec ;
				delete TMAILASGN
				where memono = v_mailno
				and to_char(dteeffec,'dd/mm/yyyy') = v_dteeffec ;
				commit;
			exception
			when others then null;
			end;
		end loop;
		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_send_mail (json_str_input in clob, json_str_output out clob) is
		json_str		json_object_t;
		obj_row			json_object_t;
		obj_data		json_object_t;
		param_json		json_object_t;
        p_dteeffec      tmailalert.dteeffec%type;
        p_mailalno      tmailalert.memono%type;
        v_countCheck    number;
	begin
		json_str := json_object_t(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
        p_mailalno := hcm_util.get_string_t(param_json, 'p_mailalno');
        p_dteeffec := TO_DATE(trim(hcm_util.get_string_t(param_json, 'p_dteeffec')), 'dd/mm/yyyy');

        select count(*)
        into v_countCheck
        from TMAILASGN
        where memono = p_mailalno
        and dteeffec = p_dteeffec;

        if v_countCheck = 0 then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TMAILASG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        else
            alertmail.check_proc(p_mailalno,p_dteeffec,'TEST');
        end if;

		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_test_syntax (json_str_input in clob, json_str_output out clob) is
		json_str		json_object_t;
		param_json		json_object_t;
		cur SYS_REFCURSOR;
		v_query			VARCHAR2(1000);
		v_num			number;
	begin
		json_str := json_object_t(json_str_input);
		param_json := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
		p_syncond := hcm_util.get_string_t(param_json, 'syncond');
		p_table := hcm_util.get_string_t(param_json, 'table');
		v_query := 'select *' || ' from ' ||p_table||' where '||p_syncond;

		begin
			OPEN cur FOR v_query;
		exception
		when others then
			param_msg_error := get_error_msg_php('HR2810',global_v_lang);
		end;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2820',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

    function get_clob(str_json in clob,key_json in varchar2) RETURN CLOB is
     jo          JSON_OBJECT_T;
    begin
        jo := JSON_OBJECT_T.parse(str_json);
        return  jo.get_clob(key_json);
    end get_clob;

   function esc_json(message in clob)return clob is
            v_message clob;

            v_result  clob := '';
            v_char varchar2 (2 char);
        BEGIN
            v_message := message ;

            if (v_message is null) then
                return v_result;
            end if;

            for i in 1..length(v_message) loop

                v_char := SUBSTR(v_message,i,1);

                if (v_char = '"') then
                    v_char := '\"' ;
                elsif (v_char = '/') then
                    v_char := '\/' ;
                elsif (v_char = '\') then
                    v_char := '\\' ;
                elsif (v_char =  chr(8) ) then
                    v_char := '\b' ;
                elsif (v_char = chr(12) ) then
                    v_char := '\b' ;
                elsif (v_char = chr(10)) then
                    v_char :=  '\n' ;
                elsif (v_char = chr(13)) then
                    v_char :=  '\r' ;
                elsif (v_char = chr(9)) then
                    v_char :=  '\t' ;
                end if ;

                   v_result := v_result||v_char;
            end loop;

         return v_result;

        end esc_json;


         function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t is
         v_convert_json_to_clob clob;
         v_new_json_clob clob;
         v_summany_json_clob clob;
         v_size number;
         begin

              v_size := v_original_json.get_size;

                if ( v_size = 0 ) then
                        v_summany_json_clob := '{';
                 else
                         v_convert_json_to_clob := v_original_json.to_clob;

                        v_summany_json_clob := substr(v_convert_json_to_clob,1,length(v_convert_json_to_clob) -1) ;
                        v_summany_json_clob := v_summany_json_clob || ',' ;
                end if;

                v_new_json_clob :=  v_summany_json_clob || '"' ||v_key|| '"' || ' : '|| '"' ||esc_json(v_value)|| '"' ||  '}';

                return json_object_t (v_new_json_clob);

         end;


end HRPM1HE;

/
