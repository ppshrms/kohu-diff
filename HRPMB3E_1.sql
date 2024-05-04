--------------------------------------------------------
--  DDL for Package Body HRPMB3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB3E" is
 procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj          := json_object_t(json_str);
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
	end initial_value;

	procedure get_index (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		gen_index(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end get_index;

	procedure gen_index (json_str_output out clob) is
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			number;
		v_status		varchar2(100 char);
		v_data			varchar2(1) := 'N';

		cursor c_tbcklst is
      select namempe, namempt,namemp3,namemp4,namemp5, codempid, numappl, numoffid, codsex
        from tbcklst
		order by numoffid;
	begin
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in c_tbcklst loop
			v_data := 'Y';
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('image',get_emp_img (r1.codempid));
			if global_v_lang = '102' then
				obj_data.put('desc_codempid', r1.namempt);
			elsif global_v_lang = '101' then
				obj_data.put('desc_codempid', r1.namempe);
			elsif global_v_lang = '103' then
				obj_data.put('desc_codempid', r1.namemp3);
			elsif global_v_lang = '104' then
				obj_data.put('desc_codempid', r1.namemp4);
			elsif global_v_lang = '105' then
				obj_data.put('desc_codempid', r1.namemp5);
			end if;
			obj_data.put('codempid', r1.codempid);
			obj_data.put('numappl', r1.numappl);
			obj_data.put('numoffid', r1.numoffid);
			obj_data.put('codsex', get_tlistval_name('NAMSEX',r1.codsex,global_v_lang));
			obj_row.put(to_char(v_rcnt), obj_data);
			v_rcnt := v_rcnt + 1;
		end loop;

--		if v_data = 'N' then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TBCKLST');
--    end if;
    if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	end gen_index;

	procedure get_detail (json_str_input in clob, json_str_output out clob) is
		json_obj		json_object_t;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		p_numoffid := hcm_util.get_string_t(json_obj, 'p_numoffid');
		gen_detail(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end get_detail;

	procedure gen_detail (json_str_output out clob) is
		v_rcnt			number;
--		obj_row			json;
		obj_data		json_object_t;
		v_yearbirth		number;
		v_monthbirth		number;
		is_found_rec		boolean := false;
		is_found_rec1		boolean := false;
		v_folder		varchar2(100 char);
    v_age_year      number;
    v_age_month     number;
    v_day           number;
    v_image       varchar2(1000 char);
		cursor t_tbcklst is
      select  bls.numoffid, nvl(bls.codempid,em1.codempid) as codempid,
              nvl(bls.numappl,em1.numappl) as numappl, nvl(bls.codtitle,em1.codtitle) as codtitle,
              nvl(bls.namfirste,em1.namfirste) as namfirste, nvl(bls.namfirstt,em1.namfirstt) as namfirstt,
              nvl(bls.namfirst3,em1.namfirst3) as namfirst3, nvl(bls.namfirst4,em1.namfirst4) as namfirst4,
              nvl(bls.namfirst5,em1.namfirst5) as namfirst5, nvl(bls.namlaste,em1.namlaste) as namlaste,
              nvl(bls.namlastt,em1.namlastt) as namlastt, nvl(bls.namlast3,em1.namlast3) as namlast3,
              nvl(bls.namlast4,em1.namlast4) as namlast4, nvl(bls.namlast5,em1.namlast5) as namlast5,
              nvl(bls.dteempmt,em1.dteempmt) as dteempmt, nvl(bls.dteeffex,em1.dteeffex) as dteeffex,
              nvl(bls.namlcomp,replace(get_tcenter_name(em1.codcomp,global_v_lang),'*','')) as namlcomp,
              nvl(bls.namlpos,replace(get_tpostn_name(em1.codpos,global_v_lang),'*','')) as namlpos,
              bls.desexemp, nvl(bls.dteempdb,em1.dteempdb) as dteempdb,
              nvl(bls.codsex,em1.codsex) as codsex, nvl(bls.numpasid,em2.numpasid) as numpasid, 
              nvl(bls.namlcomp,replace(get_tcompny_name(get_codcompy(em1.codcomp),global_v_lang),'*','')) as namlcompy,
              to_char(nvl(bls.dteempdb,em1.dteempdb),'MM') monthbirth, to_char(nvl(bls.dteempdb,em1.dteempdb),'YYYY') yearbirth ,namimage,
              desinfo,desnote
       from tbcklst bls
       left join temploy2 em2
         on (bls.numoffid = em2.numoffid)
       left join temploy1 em1
         on (em2.codempid = em1.codempid)
      where bls.numoffid = p_numoffid
        and rownum = 1;

		cursor c_temploy2 is
      select  b.numoffid, a.codempid, a.numappl, a.namempe, a.namempt, a.namemp3, a.namemp4, a.namemp5,
              a.codcomp,a.codpos, a.codtitle,
              a.namfirste, a.namfirstt,a.namfirst3,a.namfirst4,a.namfirst5,
              a.namlaste, a.namlastt, a.namlast3,a.namlast4,a.namlast5,
              a.dteempmt,
              a.dteeffex, a.dteempdb, a.codsex, b.numpasid,
              to_char(a.dteempdb,'MM') monthbirth, to_char(a.dteempdb,'YYYY') yearbirth
         from temploy1 a,temploy2 b
        where numoffid = p_numoffid
          and a.codempid = b.codempid
          and rownum = 1;

--		cursor c_tapplinf is
--      select *
--        from tapplinf
--       where numoffid = p_numoffid;

		t_tbcklst_rec t_tbcklst%ROWTYPE;

	begin
--		obj_row := json();
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numoffid', p_numoffid);
		v_rcnt := 0;
		for r1 in t_tbcklst loop
			is_found_rec := true;
      if r1.NAMIMAGE is null then
        begin
          select  namimage
          into    v_image
          from    tempimge
          where   codempid  = nvl(r1.codempid,(select codempid
                                               from   temploy2
                                               where  numoffid  = p_numoffid
                                               and    rownum    = 1));
        exception when no_data_found then
          v_image   := '';
        end;
      end if;
--			obj_data := json();
			obj_data.put('coderror', '200');
			obj_data.put('numoffid', r1.numoffid);
			obj_data.put('filename', r1.namimage);
			obj_data.put('filename2', v_image);
			obj_data.put('codtitle', r1.codtitle);
			if global_v_lang = '102' then
				obj_data.put('namfirst', r1.namfirstt);
				obj_data.put('namlast', r1.namlastt);
			elsif global_v_lang = '101' then
				obj_data.put('namfirst', r1.namfirste);
				obj_data.put('namlast', r1.namlaste);
			elsif global_v_lang = '103' then
				obj_data.put('namfirst', r1.namfirst3);
				obj_data.put('namlast', r1.namlast3);
			elsif global_v_lang = '104' then
				obj_data.put('namfirst', r1.namfirst4);
				obj_data.put('namlast', r1.namlast4);
			elsif global_v_lang = '105' then
				obj_data.put('namfirst', r1.namfirst5);
				obj_data.put('namlast', r1.namlast5);
			end if;
			obj_data.put('namfirste', r1.namfirste);
			obj_data.put('namfirstt', r1.namfirstt);
			obj_data.put('namfirst3', r1.namfirst3);
			obj_data.put('namfirst4', r1.namfirst4);
			obj_data.put('namfirst5', r1.namfirst5);
			obj_data.put('namlaste', r1.namlaste);
			obj_data.put('namlastt', r1.namlastt);
			obj_data.put('namlast3', r1.namlast3);
			obj_data.put('namlast4', r1.namlast4);
			obj_data.put('namlast5', r1.namlast5);
			obj_data.put('codsex', r1.codsex);
			obj_data.put('ocodempid', r1.codempid);
			obj_data.put('flag', true);
			obj_data.put('numappl', r1.numappl);

      get_service_year(r1.dteempdb,trunc(sysdate),'Y',v_age_year,v_age_month,v_day);
			obj_data.put('dteempdb', to_char(r1.dteempdb, 'dd/mm/yyyy'));
			obj_data.put('dteempdby', v_age_year);
			obj_data.put('dteempdbm', v_age_month);

			obj_data.put('numpasid', r1.numpasid);
			obj_data.put('namlcompy', r1.namlcompy);
			obj_data.put('namlcomp', r1.namlcomp);
			obj_data.put('namlpos', r1.namlpos);
			obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
			obj_data.put('dteeffex', to_char(r1.dteeffex, 'dd/mm/yyyy'));
			obj_data.put('desinfo', r1.desinfo);
			obj_data.put('desexemp', r1.desexemp);
			obj_data.put('desnote', r1.desnote);
--			obj_row.put(to_char(v_rcnt), obj_data);
			v_rcnt := v_rcnt + 1;
		end loop;
		if not is_found_rec then
			for r1 in c_temploy2 loop
        begin
          select  namimage
          into    v_image
          from    tempimge
          where   codempid    = r1.codempid;
        exception when no_data_found then
          v_image       := '';
        end;
				is_found_rec1 := true;
--				obj_data := json();
				obj_data.put('coderror', '200');
				obj_data.put('numoffid', r1.numoffid);
        obj_data.put('filename', '');
        obj_data.put('filename2', v_image);
				obj_data.put('codtitle', r1.codtitle);
				if global_v_lang = '102' then
					obj_data.put('namfirst', r1.namfirstt);
					obj_data.put('namlast', r1.namlastt);
				elsif global_v_lang = '101' then
					obj_data.put('namfirst', r1.namfirste);
					obj_data.put('namlast', r1.namlaste);
				elsif global_v_lang = '103' then
					obj_data.put('namfirst', r1.namfirst3);
					obj_data.put('namlast', r1.namlast4);
				elsif global_v_lang = '104' then
					obj_data.put('namfirst', r1.namfirst4);
					obj_data.put('namlast', r1.namlast4);
				elsif global_v_lang = '105' then
					obj_data.put('namfirst', r1.namfirst4);
					obj_data.put('namlast', r1.namlast4);
				end if;
				obj_data.put('namfirste', r1.namfirste);
				obj_data.put('namfirstt', r1.namfirstt);
				obj_data.put('namfirst3', r1.namfirst3);
				obj_data.put('namfirst4', r1.namfirst4);
				obj_data.put('namfirst5', r1.namfirst5);
				obj_data.put('namlaste', r1.namlaste);
				obj_data.put('namlastt', r1.namlastt);
				obj_data.put('namlast3', r1.namlast3);
				obj_data.put('namlast4', r1.namlast4);
				obj_data.put('lastnam5', r1.namlast5);
				obj_data.put('codsex', r1.codsex);
				obj_data.put('ocodempid', r1.codempid);
				obj_data.put('numappl', r1.numappl);
				obj_data.put('flag', false);
        obj_data.put('flgcreate', 'new');

        get_service_year(r1.dteempdb,trunc(sysdate),'Y',v_age_year,v_age_month,v_day);
        obj_data.put('dteempdb', to_char(r1.dteempdb, 'dd/mm/yyyy'));
        obj_data.put('dteempdby', v_age_year);
        obj_data.put('dteempdbm', v_age_month);

				obj_data.put('numpasid', r1.numpasid);
				obj_data.put('namlcompy', get_tcompny_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
				obj_data.put('namlcomp', get_tcenter_name(r1.codcomp,global_v_lang));
				obj_data.put('namlpos', get_tpostn_name(r1.codpos,global_v_lang));
				obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
				obj_data.put('dteeffex', to_char(r1.dteeffex, 'dd/mm/yyyy'));
        obj_data.put('desinfo', '');
        obj_data.put('desnote', '');
--				obj_row.put(to_char(v_rcnt), obj_data);
--				v_rcnt := v_rcnt + 1;
			end loop;
		end if;
		/* if not is_found_rec1 then
			for r1 in c_tapplinf loop

				obj_data := json();
				obj_data.put('coderror', '200');
        obj_data.put('numoffid', r1.numoffid);
        obj_data.put('filename', '');
        obj_data.put('filename2', '');
				obj_data.put('codtitle', r1.codtitle);
				if global_v_lang = '102' then
					obj_data.put('firstname', r1.namfirstt);
					obj_data.put('lastname', r1.namlastt);
				elsif global_v_lang = '101' then
					obj_data.put('firstname', r1.namfirste);
					obj_data.put('lastname', r1.namlaste);
				elsif global_v_lang = '103' then
					obj_data.put('firstname', r1.namfirst3);
					obj_data.put('lastname', r1.namlast4);
				elsif global_v_lang = '104' then
					obj_data.put('firstname', r1.namfirst4);
					obj_data.put('lastname', r1.namlast4);
				elsif global_v_lang = '105' then
					obj_data.put('firstname', r1.namfirst4);
					obj_data.put('lastname', r1.namlast4);
				end if;
				obj_data.put('namfirste', r1.namfirste);
				obj_data.put('namfirstt', r1.namfirstt);
				obj_data.put('namfirst3', r1.namfirst3);
				obj_data.put('namfirst4', r1.namfirst4);
				obj_data.put('namfirst5', r1.namfirst5);
				obj_data.put('namlastt', r1.namlastt);
				obj_data.put('namlaste', r1.namlaste);
				obj_data.put('namlast3', r1.namlast3);
				obj_data.put('namlast4', r1.namlast4);
				obj_data.put('namlast5', r1.namlast5);
        obj_data.put('codsex', r1.codsex);
				obj_data.put('ocodempid', r1.codempid);
				obj_data.put('numappl', r1.numappl);
        obj_data.put('flag', true);

        get_service_year(r1.dteempdb,trunc(sysdate),'Y',v_age_year,v_age_month,v_day);
        obj_data.put('dteempdb', to_char(r1.dteempdb, 'dd/mm/yyyy'));
        obj_data.put('dteempdby', v_age_year);
        obj_data.put('dteempdbm', v_age_month);

				obj_data.put('numpasid', r1.numpasid);
				obj_data.put('namlcompy', get_tcompny_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
				obj_data.put('namlcomp', get_tcenter_name(r1.codcomp,global_v_lang));
				obj_data.put('namlpos', get_tpostn_name(r1.codpos1,global_v_lang));
				obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
        obj_data.put('desinfo', '');
        obj_data.put('dteeffex', '');
        obj_data.put('desnote', '');
				obj_row.put(to_char(v_rcnt), obj_data);
				v_rcnt := v_rcnt + 1;
			end loop;
		end if;*/
		json_str_output := obj_data.to_clob;
	end gen_detail;

	procedure get_list_title (json_str_input in clob, json_str_output out clob) is
		json_obj		json_object_t;
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		cursor t_tlistval is
		select list_value, desc_label from tlistval
		where codapp = 'CODTITLE'
		and numseq > 0
		and codlang = global_v_lang;
	begin
		initial_value(json_str_input);
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in t_tlistval loop
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('titlelable', r1.desc_label);
			obj_data.put('titlecode', r1.list_value);
			obj_row.put(to_char(v_rcnt), obj_data);
			v_rcnt := v_rcnt + 1;
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end get_list_title;

	procedure post_save (json_str_input in clob, json_str_output out clob) is
		json_obj		json_object_t;
    v_sysdate   date  := trunc(sysdate);
	begin
		initial_value(json_str_input);
		json_obj    := json_object_t(json_str_input);
--		p_detail    := hcm_util.get_string(json_obj, 'params_json');
		obj_detail  := hcm_util.get_json_t(json_obj,'params_json');

		p_cardid                := hcm_util.get_string_t(obj_detail, 'numoffid');
		p_title                 := hcm_util.get_string_t(obj_detail, 'codtitle');
		p_firstname             := hcm_util.get_string_t(obj_detail, 'namfirst');
		p_lastname              := hcm_util.get_string_t(obj_detail, 'namlast');
		p_applyno               := hcm_util.get_string_t(obj_detail, 'numappl');
		p_birthday              := to_date(hcm_util.get_string_t(obj_detail, 'dteempdb'), 'dd/mm/yyyy');
		p_passportno            := hcm_util.get_string_t(obj_detail, 'numpasid');
		p_company               := hcm_util.get_string_t(obj_detail, 'namlcompy');
		p_depart                := hcm_util.get_string_t(obj_detail, 'namlcomp');
		p_position              := hcm_util.get_string_t(obj_detail, 'namlpos');
		p_attendance            := to_date(hcm_util.get_string_t(obj_detail, 'dteempmt'), 'dd/mm/yyyy');
		p_resignation           := to_date(hcm_util.get_string_t(obj_detail, 'dteeffex'), 'dd/mm/yyyy');
		p_causeofdischarge      := hcm_util.get_string_t(obj_detail, 'desexemp');
		p_sex                   := hcm_util.get_string_t(obj_detail, 'codsex');
--		p_mode                  := hcm_util.get_string(obj_detail, 'mode');
		p_filename              := hcm_util.get_string_t(obj_detail, 'filename');
		p_firstnamee            := hcm_util.get_string_t(obj_detail, 'namfirste');
		p_firstnamet            := hcm_util.get_string_t(obj_detail, 'namfirstt');
		p_firstname3            := hcm_util.get_string_t(obj_detail, 'namfirst3');
		p_firstname4            := hcm_util.get_string_t(obj_detail, 'namfirst4');
		p_firstname5            := hcm_util.get_string_t(obj_detail, 'namfirst5');
		p_lastnamee             := hcm_util.get_string_t(obj_detail, 'namlaste');
		p_lastnamet             := hcm_util.get_string_t(obj_detail, 'namlastt');
		p_lastname3             := hcm_util.get_string_t(obj_detail, 'namlast3');
		p_lastname4             := hcm_util.get_string_t(obj_detail, 'namlast4');
		p_lastname5             := hcm_util.get_string_t(obj_detail, 'namlast5');
		p_codempid              := hcm_util.get_string_t(obj_detail, 'ocodempid');
		p_desinfo               := hcm_util.get_string_t(obj_detail, 'desinfo');
		p_desnote               := hcm_util.get_string_t(obj_detail, 'desnote');

		IF (p_title = '' or p_title = ' ' or p_title is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
		end if;
		if p_birthday >= v_sysdate then
			param_msg_error := get_error_msg_php('HR7551',global_v_lang);
		elsif p_attendance > v_sysdate then
			param_msg_error := get_error_msg_php('HR4508',global_v_lang);
		elsif p_resignation > v_sysdate then
			param_msg_error := get_error_msg_php('HR4508',global_v_lang);
		elsif p_resignation < p_attendance then
			param_msg_error := get_error_msg_php('HR5017',global_v_lang);
		elsif p_resignation < p_birthday then
			param_msg_error := get_error_msg_php('HR550',global_v_lang);
		else
			save_data_main;
		end if;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);

	exception when others then
		rollback;
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end post_save;

	procedure save_data_main is
		titlename		varchar2(20 char);
	begin
		titlename := GET_TLISTVAL_NAME('CODTITLE',p_title,global_v_lang);
		begin
			update tbcklst
        set numappl   = p_applyno,
            codtitle  = p_title,
            namfirste = p_firstnamee,
            namfirstt = p_firstnamet,
            namfirst3 = p_firstname3,
            namfirst4 = p_firstname4,
            namfirst5 = p_firstname5,
            namlaste = p_lastnamee,
            namlastt = p_lastnamet,
            namlast3 = p_lastname3,
            namlast4 = p_lastname4,
            namlast5 = p_lastname5,
            namempe = titlename||' '||p_firstname||' '||p_lastname,
            namempt = titlename||' '||p_firstname||' '||p_lastname,
            dteempmt = p_attendance,
            dteeffex = p_resignation,
            namlpos = p_position,
            namlcomp = p_depart,
            desexemp = p_causeofdischarge,
            dteempdb = p_birthday,
            codsex = p_sex,
            numpasid = p_passportno,
            namlcompy = p_company,
            coduser = global_v_coduser,
            NAMIMAGE = p_filename,
            codempid = p_codempid,
            desinfo = p_desinfo,
            desnote = p_desnote
			where numoffid = p_cardid ;

			if sql%rowcount = 0 then
				insert into tbcklst (numoffid,numappl,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,
          namempe,namempt,dteempmt,dteeffex,namlpos,namlcomp,desexemp,dteempdb,codsex,numpasid,namlcompy,dteupd,coduser,NAMIMAGE,codempid,CODCREATE,
          desinfo,desnote)
				values (p_cardid, p_applyno, p_title,
          p_firstnamee, p_firstnamet, p_firstname3, p_firstname4, p_firstname5,
          p_lastnamee, p_lastnamet, p_lastname3, p_lastname4, p_lastname5,
          titlename||' '||p_firstname||' '||p_lastname, titlename||' '||p_firstname||' '||p_lastname, p_attendance, p_resignation, p_position, p_depart, p_causeofdischarge,
          p_birthday, p_sex, p_passportno, p_company, sysdate, global_v_coduser,p_filename,p_codempid, global_v_coduser,
          p_desinfo,p_desnote);
			end if;
		end;
	end save_data_main;

	procedure post_delete (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		delete_data(json_str_input,	json_str_output);
		json_str_output := get_response_message(null, param_msg_error, global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end post_delete;

	procedure delete_data (json_str_input in clob, json_str_output out clob) is
		json_str		json_object_t;
		param_json		json_object_t;
		param_json_row		json_object_t;
		v_mailalno		varchar2(8 char);
		v_dteeffec		date;
	begin
		json_str := json_object_t(json_str_input);
		param_json := hcm_util.get_json_t(json_str, 'params_json');
		for i in 0..param_json.get_size-1 loop
			param_json_row := hcm_util.get_json_t(param_json,to_char(i));
			p_cardid := hcm_util.get_string_t(param_json_row, 'numoffid');
			begin
				delete tbcklst
				where numoffid = p_cardid;
				commit;
			exception
			when others then null;
			end;
		end loop;
		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null, param_msg_error, global_v_lang);
	end delete_data;

	procedure get_subdetail (json_str_input in clob, json_str_output out clob) is
		json_obj		json_object_t;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		p_codempid := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		gen_subdetail(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end get_subdetail;

	procedure gen_subdetail (json_str_output out clob) is
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
    v_numhmref	ttmistk.numhmref%type;
    v_coduser	  ttmistk.coduser%type;
    v_dteeffec	ttmistk.dteeffec%type;
    v_codmist	  ttmistk.codmist%type;
    v_desmist1	ttmistk.desmist1%type;
    v_refdoc	  ttmistk.refdoc%type;
    v_codreq	  ttmistk.codreq%type;
    v_dteupd	  ttmistk.dteupd%type;
    v_numseq	  ttpunsh.numseq%type;
    v_remark	  ttpunsh.remark%type;
    v_codpunsh	ttpunsh.codpunsh%type;
    v_typpun	  ttpunsh.typpun%type;
    v_dtestart	ttpunsh.dtestart%type;
    v_dteend	  ttpunsh.dteend%type;
    v_flgexempt	ttpunsh.flgexempt%type;
    v_codexemp	ttpunsh.codexemp%type;
    v_flgblist	ttpunsh.flgblist%type;
    v_flgssm	  ttpunsh.flgssm%type;

	begin
    begin
      select a.numhmref, a.coduser,a.dteeffec, a.codmist, a.desmist1,a.refdoc, a.codreq, a.dteupd,
             b.numseq, b.remark,b.codpunsh, b.typpun, b.dtestart, b.dteend , b.flgexempt, b.codexemp, b.flgblist, b.flgssm
        into v_numhmref, v_coduser, v_dteeffec, v_codmist, v_desmist1, v_refdoc, v_codreq, v_dteupd,
         v_numseq, v_remark, v_codpunsh, v_typpun, v_dtestart, v_dteend, v_flgexempt, v_codexemp, v_flgblist, v_flgssm
        from ttmistk a, ttpunsh b
       where a.codempid = b.codempid
         and a.dteeffec = b.dteeffec
         and a.codempid = p_codempid
         and b.staupd   = 'U'
         and a.dteeffec = (select max(dteeffec)
                             from thismist
                            where codempid  = p_codempid)
       order by dtemistk desc;
     exception when no_data_found then
      null;
     end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('ocodempid', p_codempid);
    obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
    obj_data.put('numhmref', v_numhmref);
    obj_data.put('dteeffec', to_char(v_dteeffec, 'dd/mm/yyyy'));
    obj_data.put('codmist', get_tcodec_name('TCODMIST',v_codmist,global_v_lang));
    obj_data.put('refdoc', v_refdoc);
    obj_data.put('codreq', get_temploy_name(v_codreq,global_v_lang));
    obj_data.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
    obj_data.put('desmist1', v_desmist1);
    obj_data.put('codpunsh', get_tcodec_name('TCODPUNH',v_codpunsh,global_v_lang));
    obj_data.put('typpun', get_tlistval_name('NAMTPUN',v_typpun,global_v_lang) );
    obj_data.put('dtestart', to_char(v_dtestart, 'dd/mm/yyyy'));
    obj_data.put('dteend', to_char(v_dteend, 'dd/mm/yyyy'));
    obj_data.put('flgexempt', v_flgexempt);
    obj_data.put('codexemp', v_codexemp||' - '||get_tcodec_name('TCODEXEM', v_codexemp, global_v_lang));
    obj_data.put('flgblist', v_flgblist);
    obj_data.put('flgssm', get_tlistval_name('FLGSSM', v_flgssm,global_v_lang));
    obj_data.put('remark', v_remark);
		json_str_output := obj_data.to_clob;

	end gen_subdetail;
end HRPMB3E;

/
