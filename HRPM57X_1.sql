--------------------------------------------------------
--  DDL for Package Body HRPM57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM57X" AS

	procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		v_chken := hcm_secur.get_v_chken;
		json_obj := json_object_t(json_str);

		--global
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_zyear    := hcm_appsettings.get_additional_year();

        -- index
		p_cod_comp    := hcm_util.get_string_t(json_obj,'p_cod_comp');
		p_cod_empid   := hcm_util.get_string_t(json_obj,'p_cod_empid');
		p_date_from   := to_date(hcm_util.get_string_t(json_obj,'p_date_from'),'dd/mm/yyyy');
		p_date_to     := to_date(hcm_util.get_string_t(json_obj,'p_date_to'),'dd/mm/yyyy');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;
  --
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
--    v_count     number := 0;
--    v_codaplvl  varchar2(100 char);
--    v_flgExsit  varchar2(2 char);
  begin
    if p_cod_comp is not null then
      if p_date_from is null or p_date_to is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      elsif p_date_from > p_date_to then
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        return;
      end if;
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(p_cod_comp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_cod_comp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_cod_empid is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = p_cod_empid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(p_cod_empid, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
	procedure getIndex (json_str_input in clob,json_str_output out clob) AS
	begin
		initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      genIndex(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END getIndex;

	procedure genIndex (json_str_output out clob) AS
    obj_row         json_object_t;
    obj_data        json_object_t;

		cursor c1 is
      select codempid, dteeffec, numhmref, codmist, desmist1, dtemistk, numannou,
             codcomp, numlvl, refdoc, codpos, codjob, dteempmt, codempmt, typemp,
             typpayroll, staupd, codappr, dteappr, remarkap, codreq, jobgrade, codgrpgl
        from ttmistk
       where codcomp like p_cod_comp||'%'
         and codempid = nvl(p_cod_empid, codempid)
         and dteeffec between nvl(p_date_from, dteeffec) and nvl(p_date_to, dteeffec)
         and staupd in ('U','C')
       order by codempid,dteeffec;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
	begin
		obj_row := json_object_t();
		for r1 in c1 loop
      v_flgdata := 'Y';
			v_secur := secur_main.secur3(r1.codcomp, r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_secur then
        v_flgsecur  := 'Y';
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid );
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang) );
        obj_data.put('codcomp', r1.codcomp );
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang) );
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('codmistname', get_tcodec_name('TCODMIST', r1.codmist, global_v_lang));
        obj_data.put('numhmref', r1.numhmref );
        obj_data.put('numdoc', r1.numannou );
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
		end loop;

		if v_flgdata = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTMISTK' );
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return ;
		end if ;
		if v_flgsecur = 'N' then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang);
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return ;
		end if;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;
    --
  procedure gen_data_initial (json_str_output out clob) AS
		obj_data	json_object_t;
		v_rcnt		number := 0;
    v_data21  tinitial.datainit1%type;
    v_data22  tinitial.datainit1%type;
	begin
    begin
      select decode(global_v_lang,'101',datainit1
                                 ,'102',datainit2
                                 ,'103',datainit1
                                 ,'104',datainit1
                                 ,'105',datainit1) as datainit
        into v_data21
        from tinitial
       where codapp = 'HRPM57X'
         and numseq = 21;
    exception when no_data_found then
      v_data21  :=  '';
    end;
    begin
      select decode(global_v_lang,'101',datainit1
                                 ,'102',datainit2
                                 ,'103',datainit1
                                 ,'104',datainit1
                                 ,'105',datainit1) as datainit
        into v_data22
        from tinitial
       where codapp = 'HRPM57X'
         and numseq = 22;
      if v_data22 is not null then
        v_data22  :=  to_char(to_date(v_data22,'dd/mm/yyyy'),'dd/mm/yyyy');
      else 
        v_data22  :=  to_char(sysdate,'dd/mm/yyyy');
      end if;
    exception when no_data_found then
      v_data22  :=  to_char(sysdate,'dd/mm/yyyy');
    end;
		obj_data := json_object_t();
		obj_data.put('coderror', '200');
		obj_data.put('codform', v_data21);
		obj_data.put('dteprint', v_data22);
		json_str_output := obj_data.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gen_data_initial;
  --
  procedure get_data_initial ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_initial(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
	procedure initial_prarameterreport (json_str in clob ) is
		json_obj		json_object_t;
	begin
		v_chken     := hcm_secur.get_v_chken;
		json_obj    := json_object_t(json_str);
		p_codform   := hcm_util.get_string_t(json_obj,'p_codform');

	end initial_prarameterreport;

	procedure get_prarameterreport(json_str_input in clob, json_str_output out clob) as
	begin
		initial_prarameterreport(json_str_input);
		vadidate_v_getprarameterreport(json_str_input);
		if param_msg_error is null then
			gen_prarameterreport(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_prarameterreport (json_str_output out clob) as
		obj_data		json_object_t;
		obj_row			json_object_t;
    v_value     varchar2(1000 char);
		v_rcnt			number := 0;
		v_numseq	  number := 0;
    v_flgedit   boolean := false;

		cursor c1 is
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
         and flgstd = 'N'
       order by ffield ;

	begin
    v_numseq := 23;
		obj_row := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('codform',r1.codform);
			obj_data.put('section',r1.section);
			obj_data.put('numseq',r1.numseq);
			obj_data.put('codtable',r1.codtable);
			obj_data.put('fparam',r1.fparam);
			obj_data.put('ffield',r1.ffield);
			obj_data.put('descript',r1.descript);
			obj_data.put('flginput',r1.flginput);
			obj_data.put('flgdesc',r1.flgdesc);
      begin 
        select datainit1 into v_value
          from tinitial 
         where codapp = 'HRPM57X' 
           and numseq = v_numseq;
           v_flgedit := true;
      exception when no_data_found then
        v_flgedit := false;
        v_value := '';
      end;
      obj_data.put('flgEdit',v_flgedit);
      obj_data.put('value',v_value);
      obj_row.put(to_char(v_rcnt - 1),obj_data); 

      v_numseq := v_numseq + 1;
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;

		json_str_output := obj_row.to_clob();
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_prarameterreport;

	procedure vadidate_v_getprarameterreport(json_str_input in clob) as
	begin
		if (p_codform is null or p_codform = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_codform');
			return ;
		end if;
	end vadidate_v_getprarameterreport;

	procedure gen_html_form(p_codform in varchar2,
		o_message1 out clob,
		o_typemsg1		out varchar2,
		o_message2 out clob,
		o_typemsg2		out varchar2,
		o_message3 out clob
		) as
	begin
		begin
			select message,namimglet
        into o_message1,p_namimglet
        from tfmrefr
			 where codform = p_codform;
		exception when NO_DATA_FOUND then
			o_message1 := null ;
			o_typemsg1 := null;
		end;

		begin
			select MESSAGE , TYPEMSG into o_message2,o_typemsg2
			from tfmrefr2
			where codform = p_codform;
		exception when NO_DATA_FOUND then
			o_message2 := null ;
			o_typemsg2 := null;
		end;

		begin
			select MESSAGE into o_message3
			from tfmrefr3
			where codform = p_codform;
		exception when NO_DATA_FOUND then
			o_message3 := null ;
		end;
	end gen_html_form;

	procedure get_html_message(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_prarameterreport(json_str_input);
		vadidate_v_getprarameterreport(json_str_input);

		if param_msg_error is null then
			gen_html_message(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end get_html_message;

	procedure gen_html_message (json_str_output out clob) AS
		o_html_1    clob;
		o_typemsg1	varchar2(10 CHAR);
		o_html_2    clob;
		o_typemsg2	varchar2(10 CHAR);
		o_html_3    clob;
		obj_data		json_object_t;
		v_rcnt			number := 0;

	begin
		gen_html_form(p_codform,o_html_1,o_typemsg1,o_html_2,o_typemsg2,o_html_3);

		obj_data := json_object_t();
		obj_data.put('coderror', '200');
		obj_data.put('response','');
		obj_data.put('headhtml',o_html_1);
		obj_data.put('bodyhtml',o_html_2);
		obj_data.put('footerhtml',o_html_3);
    if p_namimglet is not null then
       p_namimglet := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMB9E')||'/'||p_namimglet;
    end if;
		obj_data.put('head_letter',p_namimglet);

		json_str_output := obj_data.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gen_html_message;

	procedure print_report(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_word(json_str_input);
		if param_msg_error is null then
      gen_report_data(json_str_output);
      if (param_msg_error is not null) then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        commit;
      end if;
--			if (p_sendemail = 'Y' ) then
--        send_mail(json_str_input,json_str_output);
--        if param_msg_error is not null then
--          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--        end if;
--      else
--        gen_report_data(json_str_output);
--        if (param_msg_error is not null) then
--          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--        else
--          commit;
--        end if;
--			end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;

	procedure initial_word(json_str_input in clob) AS
		json_obj		json_object_t;
		obj_detail	json_object_t;
	begin
		v_chken   := hcm_secur.get_v_chken;
		json_obj  := json_object_t(json_str_input);

		--global
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_zyear    := hcm_appsettings.get_additional_year();

    -- index
    obj_detail        := hcm_util.get_json_t(json_obj,'details');
    p_data_selected   := hcm_util.get_json_t(json_obj,'dataselected');
    p_data_parameter  := hcm_util.get_json_t(json_obj,'fparam');
    p_data_sendmail   := hcm_util.get_json_t(json_obj,'dataRows');
		p_url             := hcm_util.get_string_t(json_obj,'url');

		p_cod_comp    := hcm_util.get_string_t(obj_detail,'codcomp');
		p_cod_empid   := hcm_util.get_string_t(obj_detail,'codempid');
		p_date_from   := to_date(hcm_util.get_string_t(obj_detail,'datefrom'),'dd/mm/yyyy');
		p_date_to     := to_date(hcm_util.get_string_t(obj_detail,'dateto'),'dd/mm/yyyy');

		p_dateprint   := to_date(hcm_util.get_string_t(obj_detail,'dateprint'),'dd/mm/yyyy');
		p_numannou    := hcm_util.get_string_t(obj_detail,'numlettr');
		p_codform     := hcm_util.get_string_t(obj_detail,'codform');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

	END initial_word;

  procedure gen_report_data ( json_str_output out clob) as
    v_codlang		    tfmrefr.codlang%type;
    v_desc_month		varchar2(50 char);
    v_year			    varchar2(4 char);
    v_month         varchar(5 char);
    v_day			      number;
    tdata_dteprint	varchar2(100 char);

		--- Report
		o_html_1        clob;
		o_typemsg1	    varchar2(10 CHAR);
		o_html_2        clob;
		o_typemsg2	    varchar2(10 CHAR);
		o_html_3        clob;
		data_file       clob;

		-- Return Data
		v_resultcol		json_object_t;
		v_resultrow		json_object_t := json_object_t();
    obj_rows      json_object_t;
    obj_result    json_object_t;
		itemSelected	json_object_t := json_object_t();

		v_countrow		number := 0;

    v_dtereq       date;
    v_numseq       number;

		type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    obj_fparam        json_object_t := json_object_t();
    fparam_codform      varchar2(1000 char);
    fparam_codtable     varchar2(1000 char);
    fparam_ffield       varchar2(1000 char);
    fparam_flgdesc      varchar2(1000 char);
    fparam_flginput     varchar2(1000 char);
    fparam_flgstd       varchar2(1000 char);
    fparam_fparam       varchar2(1000 char);
    fparam_numseq       varchar2(1000 char);
    fparam_section      varchar2(1000 char);
    fparam_descript     varchar2(1000 char);
    fparam_value        varchar2(4000 char);
    fparam_signpic      varchar2(4000 char);

		v_namimglet		      tfmrefr.namimglet%type;
    p_signid            varchar2(1000 char);
		v_folder		        tfolderd.folder%type;
    v_namesign          varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_pathimg           varchar2(1000 char);
    v_codempid          ttmistk.codempid%type;
    v_codcomp           ttmistk.codcomp%type;
    v_dteeffec          ttmistk.dteeffec%type;
    v_numhmref          ttmistk.numhmref%type;
    v_numdoc            ttmistk.numannou%type;
    v_data              long;
    v_num               number := 0;
    v_filename          varchar2(1000 char);
    ttmistk_obj		      ttmistk%rowtype;
    v_flgdesc           tfmparam.flgdesc%type;
    arr_result          arr_1d;
    v_date_std          varchar2(100 char);
    v_rowid             number := 0;

    cursor c1 is
      select codcodec
      from tcodmist
      order by codcodec;

    cursor c2 is
      select typpun,codpunsh,dtestart,dteend,flgexempt
        from ttpunsh
       where codempid = v_codempid
         and dteeffec = v_dteeffec
       order by numseq;
	begin

		begin
			select codlang,namimglet into v_codlang, v_namimglet
			from tfmrefr
			where codform = p_codform;
		exception when no_data_found then
			v_codlang := global_v_lang;
		end;

    begin
      select get_tsetup_value('PATHWORKPHP')||folder into v_folder
        from tfolderd
       where codapp = 'HRPMB9E';
    exception when no_data_found then
			v_folder := '';
    end;
		v_codlang := nvl(v_codlang,global_v_lang);

		-- dateprint
		v_day         := to_number(to_char(p_dateprint,'dd'),'99');
		v_desc_month  := get_nammthful(to_number(to_char(p_dateprint,'mm')),v_codlang);
		v_year        := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(p_dateprint,'yyyy')));
		tdata_dteprint := v_day||' '||v_desc_month||' '||v_year;
    numYearReport   := HCM_APPSETTINGS.get_additional_year();

		for i in 0..p_data_selected.get_size - 1 loop
			itemSelected  := hcm_util.get_json_t( p_data_selected,to_char(i));
      v_codempid    := hcm_util.get_string_t(itemSelected,'codempid');
      v_codcomp     := hcm_util.get_string_t(itemSelected,'codcomp');
      v_dteeffec    := to_date(hcm_util.get_string_t(itemSelected,'dteeffec'),'dd/mm/yyyy');
      v_numseq      := hcm_util.get_string_t(itemSelected,'numseq');
      v_numhmref    := hcm_util.get_string_t(itemSelected,'numhmref');
      v_numdoc      := hcm_util.get_string_t(itemSelected,'numdoc');
      v_rowid       := hcm_util.get_string_t(itemSelected,'rowID');

      begin
        select *
          into ttmistk_obj
          from ttmistk
         where codempid = v_codempid
           and dteeffec = v_dteeffec;
      exception when no_data_found then
        ttmistk_obj := null;
      end;
      if v_numdoc is null then
        begin
          select numannou  into v_numdoc
            from ttmistk
           where codempid = v_codempid
             and dteeffec = v_dteeffec;
        exception when no_data_found then
          v_numdoc  :=  '';
        end;
        if v_numdoc is null then
          v_numdoc := get_docnum('5',hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
        end if;
        begin
          update ttmistk
             set numannou = v_numdoc
           where codempid = v_codempid
             and dteeffec = v_dteeffec;
        end;
      end if;
      -- #check_numdoc
      check_numdoc(v_codempid, v_codcomp);
      if (param_msg_error is not null) then
        return ;
      end if;
      -- Read Document HTML
      gen_html_form(p_codform,o_html_1,o_typemsg1,o_html_2,o_typemsg2,o_html_3);
      list_msg_html := html_array(o_html_1,o_html_2,o_html_3);
				for i in 1..3 loop
          begin
            select flgdesc into v_flgdesc
              from tfmparam 
             where codtable = 'NOTABLE'
               and codform  = p_codform
               and fparam = '[PARAM-DATE]'
               and section = i
               and rownum = 1;  
          exception when no_data_found then
            v_flgdesc := 'N';
          end;
					data_file := list_msg_html(i);
					data_file := std_replace(data_file,p_codform,i,itemSelected );
          -- check flg date std
          if p_dateprint is not null then
            v_date_std := '';
            if v_flgdesc = 'Y' then
              arr_result := explode('/', to_char(p_dateprint,'dd/mm/yyyy'), 3);
              v_day := arr_result(1);
              v_month := arr_result(2);
              v_year := arr_result(3);
              v_date_std := get_label_name('HRPM33R1',global_v_lang,230) || ' ' ||to_number(v_day) ||' '|| 
                            get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' || 
                            get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
            else
              v_date_std := to_char(add_months(p_dateprint, numYearReport*12),'dd/mm/yyyy');
            end if;
          end if; 
          -- input from display
					data_file := replace(data_file,'[PARAM-DOCID]', v_numdoc);
					data_file := replace(data_file,'[PARAM-DATE]', v_date_std);
          data_file := replace(data_file,'[PARAM-COMPANY]',get_tcompny_name(get_codcompy(v_codcomp),global_v_lang));
          --
          v_data := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
          for r1 in c1 loop
            v_num := v_num + 1;
            if mod(v_num,2) = 1 then
              v_data     := v_data||'<tr>';
            end if;
            if ttmistk_obj.codmist = r1.codcodec then
              v_data := v_data||'<td width="5%">'||'[' || 'x' || ']'||'  '||get_tcodec_name('TCODMIST', r1.codcodec, global_v_lang)||'</td>';
            else
              v_data := v_data||'<td width="5%">'||'[ ' || '&nbsp;' || ']'||'  '||get_tcodec_name('TCODMIST', r1.codcodec, global_v_lang)||'</td>';
            end if;
            if mod(v_num,2) = 0 then
              v_data     := v_data||'</tr>';
            end if;
          end loop;
          v_data    := v_data||'</table>';
          data_file := replace(data_file,'[PARAM-MISTK]',v_data);
          --
          v_data := '<table class="border-table" width="100%">';
          v_data := v_data||'<tr bgcolor="#819FF7">
                               <td class="border-table" width="25%"  align="center">'||get_label_name('HRPM57X2', global_v_lang, 200)||'</td>
                               <td class="border-table" width="25%" align="center">'||get_label_name('HRPM57X2', global_v_lang, 210)||'</td>
                               <td class="border-table" width="15%" align="center">'||get_label_name('HRPM57X2', global_v_lang, 220)||'</td>
                               <td class="border-table" width="15%" align="center">'||get_label_name('HRPM57X2', global_v_lang, 230)||'</td>
                               <td class="border-table" width="20%" align="center">'||get_label_name('HRPM57X2', global_v_lang, 240)||'</td>
                             </tr>';
          for r2 in c2 loop
            v_data := v_data||'<tr>
                                 <td class="border-table" >'||get_tlistval_name('NAMTPUN', r2.typpun, global_v_lang)||'</td>
                                 <td class="border-table" >'||get_tcodec_name('TCODPUNH', r2.codpunsh, global_v_lang)||'</td>
                                 <td class="border-table" align="center">'||to_char(add_months(r2.dtestart, global_v_zyear * 12), 'dd/mm/yyyy')||'</td>
                                 <td class="border-table" align="center">'||to_char(add_months(r2.dteend, global_v_zyear * 12), 'dd/mm/yyyy')||'</td>
                                 <td class="border-table" align="center">'||r2.flgexempt||'</td>
                               </tr>';
          end loop;
          v_data    := v_data||'</table>';
          data_file := replace(data_file,'[PARAM-PUNSH]',v_data);

          for j in 0..p_data_parameter.get_size - 1 loop
            obj_fparam      := hcm_util.get_json_t( p_data_parameter,to_char(j));
            fparam_fparam   := hcm_util.get_string_t(obj_fparam,'fparam');
            fparam_numseq   := hcm_util.get_string_t(obj_fparam,'numseq');
            fparam_section  := hcm_util.get_string_t(obj_fparam,'section');
            fparam_value    := hcm_util.get_string_t(obj_fparam,'value');
            if fparam_fparam = '[PARAM-SIGNID]' then
              begin
                select get_temploy_name(codempid,global_v_lang) into v_namesign
                  from temploy1
                 where codempid = fparam_value;
                p_signid  := fparam_value;
                fparam_value := v_namesign;
              exception when no_data_found then
                null;
              end;
              begin
                select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E2') || '/' ||NAMSIGN
                into p_signpic
                from TEMPIMGE
                 where codempid = p_signid;
              exception when no_data_found then null;
              end ;
              if p_signpic is not null then
                fparam_signpic := '<img src="'||p_url||'/'||p_signpic||'"width="60" height="30">';
              else
                fparam_signpic := '';
              end if;
              data_file := replace(data_file, '[PARAM-SIGNPIC]', fparam_signpic);
            end if;
--            if fparam_fparam = '[PARAM-SIGNPIC]' then
--              begin
--                select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E2') || '/' ||NAMSIGN
--                into p_signpic
--                from TEMPIMGE
--                 where codempid = fparam_value;
--                 if p_signpic is not null then
--                  fparam_value := '<img src="'||p_url||'/'||p_signpic||'"width="60" height="30">';
--                else
--                  fparam_value := '';
--                end if;
--              exception when no_data_found then null;
--              end ;
--            end if;
            data_file := replace(data_file, fparam_fparam, fparam_value);
          end loop;

          data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
          data_file := replace(data_file, chr(9), '&nbsp;');
          list_msg_html(i) := data_file ;
        end loop;

        v_resultcol		:= json_object_t ();

        v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
        v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
        v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
        if v_namimglet is not null then
          v_pathimg := v_folder||'/'||v_namimglet;
        end if;
        v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
        v_resultcol.put('numberdocument',v_numdoc);

        v_filename := global_v_coduser||'_'||to_char(sysdate,'yyyymmddhh24miss')||'_'||(i+1);
        v_resultcol.put('filepath',p_url||'file_uploads/'||v_filename||'.doc');
        v_resultcol.put('filename',v_filename);
        v_resultcol.put('codempid',v_codempid);
        v_resultcol.put('rowId',v_rowid);
        v_resultcol.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
        v_resultrow.put(to_char(v_countrow), v_resultcol);

        v_countrow := v_countrow + 1;
    end loop; -- end of loop data

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',v_numdoc);
    obj_result.put('table',v_resultrow);

    json_str_output := obj_result.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end gen_report_data;

  procedure check_numdoc (p_codempid in varchar2, p_codcomp in varchar2) is
		v_codcomp		varchar2(100 char);
		v_chk			  number;
	begin
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1) into v_codcomp
        from temploy1
        where codempid = p_codempid;
      exception when others then
        v_codcomp := null;
      end ;
    end if;
		if v_codcomp is not null then
			begin
				select count(*) into v_chk
				from tdocrnum
				where codcompy = v_codcomp;
			exception when no_data_found then
				v_chk := 0;
			end;
			if v_chk = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TDOCRNUM');
			end if;
		end if;
	end check_numdoc;

  function std_replace(p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob is
    v_statmt		    long;
    v_statmt_sub		long;

    v_message 	    clob;
    obj_json 	      json_object_t := json_object_t();
    v_codtable      tcoldesc.codtable%type;
    v_codcolmn      tcoldesc.codcolmn%type;
    v_codlang       tfmrefr.codlang%type;

    v_funcdesc      tcoldesc.funcdesc%type;
    v_flgchksal     tcoldesc.flgchksal%type;

    v_dataexct      varchar(1000);
    v_day           varchar(1000);
    v_month         varchar(1000);
    v_year          varchar(1000);
    arr_result      arr_1d;
    cursor c1 is
      select fparam,ffield,descript,a.codtable,fwhere,
             'select '||ffield||' from '||a.codtable ||' where '||fwhere stm ,flgdesc
                from tfmtable a,tfmparam b ,tfmrefr c
                where b.codform  = c.codform
                  and a.codapp   = c.typfm
                  and a.codtable = b.codtable
                  and b.flgstd   = 'N'
                  and b.section = p_section
                  and nvl(b.flginput,'N') <> 'Y'
                  and b.codform  = p_codform
                 order by b.numseq;
  begin
    v_message := p_message;
    begin
      select codlang
        into v_codlang
        from tfmrefr
       where codform = p_codform;
    exception when no_data_found then
      v_codlang := global_v_lang;
    end;
    v_codlang := nvl(v_codlang,global_v_lang);

    for i in c1 loop
      v_codtable := i.codtable;
      v_codcolmn := i.ffield;
      /* find description sql */
      begin
        select funcdesc ,flgchksal into v_funcdesc,v_flgchksal
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
          v_funcdesc := null;
          v_flgchksal:= 'N' ;
      end;
      if nvl(i.flgdesc,'N') = 'N' then
        v_funcdesc := null;
      end if;
      if v_flgchksal = 'Y' then
         v_statmt  := 'select to_char(stddec('||i.ffield||','||''''||hcm_util.get_string_t(p_itemson,'codempid')||''''||','||''''||hcm_secur.get_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where '||i.fwhere ;
      elsif v_funcdesc is not null then
        v_statmt_sub := std_get_value_replace(i.stm, p_itemson, v_codtable);
        v_statmt_sub := execute_desc(v_statmt_sub);
        v_funcdesc := replace(v_funcdesc,'P_CODE',''''||v_statmt_sub||'''') ;
        v_funcdesc := replace(v_funcdesc,'P_LANG',''''||v_codlang||'''') ;
        v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
        v_funcdesc := replace(v_funcdesc,'P_TEXT',hcm_secur.get_v_chken) ;
        v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where '||i.fwhere ;
      else
         v_statmt  := i.stm ;
      end if;
      if get_item_property(v_codtable,v_codcolmn) = 'DATE' then
        if nvl(i.flgdesc,'N') = 'N' then
          v_statmt := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where '||i.fwhere;
          v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
          v_dataexct := execute_desc(v_statmt);
        else
          v_statmt := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where '||i.fwhere;
          v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
          v_dataexct := execute_desc(v_statmt);

          if v_dataexct is not null then
            arr_result := explode('/', v_dataexct, 3);
            v_day := arr_result(1);
            v_month := arr_result(2);
            v_year := arr_result(3);
          end if;
          v_dataexct := get_label_name('HRPM57X2',global_v_lang,250)||' '||to_number(v_day) ||' '||
                        get_label_name('HRPM57X2',global_v_lang,260) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' ||
                        get_label_name('HRPM57X2',global_v_lang,270) || ' ' ||hcm_util.get_year_buddhist_era(v_year);

        end if;
      else
        v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
        v_dataexct := execute_desc(v_statmt);
      end if;
      v_message := replace(v_message,i.fparam,v_dataexct);
    end loop; -- loop main

    return v_message;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end std_replace;

  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t , v_codtable in varchar2) return long is
    v_statmt		long;
    v_itemson  json_object_t;
    v_item_field_original    varchar2(500 char);
    v_item			varchar2(500 char);
    v_value     varchar2(500 char);
  begin
    v_statmt  := v_in_statmt;
    v_itemson := p_in_itemson;
    loop
      v_item    := substr(v_statmt,instr(v_statmt,'[') +1,(instr(v_statmt,']') -1) - instr(v_statmt,'['));
      v_item_field_original := v_item;
      v_item     :=   substr(v_item, instr(v_item,'.')+1);
      exit when v_item is null;

      v_value := name_in(v_itemson , lower(v_item));

      if get_item_property(v_codtable,v_item) = 'DATE' then
--        v_value   := 'to_date('''||to_char(to_date(v_value),'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ;
        v_value   := 'to_date('''||v_value||''',''dd/mm/yyyy'')' ;
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      else
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      end if;
     end loop;
    return v_statmt;
  end std_get_value_replace;

	function get_item_property (p_table in varchar2,p_field in varchar2) return varchar2 is
		cursor c_datatype is
      select t.data_type as datatype
        from user_tab_columns t
       where t.table_name = p_table
         and t.column_name = substr(p_field, instr(p_field,'.')+1);

		valueDataType	  json_object_t := json_object_t();
	begin
		for i in c_datatype loop
			valueDataType.put('DATATYPE',i.datatype);
		end loop;
		return hcm_util.get_string_t(valueDataType,'DATATYPE');
	end get_item_property;

	function name_in (objItem in json_object_t , bykey varchar2) return varchar2 is
	begin
		if ( hcm_util.get_string_t(objItem,bykey) = null or hcm_util.get_string_t(objItem,bykey) = ' ') then
			return '';
		else
			return hcm_util.get_string_t(objItem,bykey);
		end if;
	end name_in ;

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
    v_convert_json_to_clob   clob;
    v_new_json_clob          clob;
    v_summany_json_clob      clob;
    v_size number;
  begin
    v_size := v_original_json.get_size;

    if ( v_size = 0 ) then
      v_summany_json_clob := '{';
    else
      v_convert_json_to_clob :=  v_original_json.to_clob;
      v_summany_json_clob := substr(v_convert_json_to_clob,1,length(v_convert_json_to_clob) -1) ;
      v_summany_json_clob := v_summany_json_clob || ',' ;
    end if;

    v_new_json_clob :=  v_summany_json_clob || '"' ||v_key|| '"' || ' : '|| '"' ||esc_json(v_value)|| '"' ||  '}';

    return json_object_t (v_new_json_clob);
  end;

  function add_value_other(v_in_item_json in json_object_t) return json_object_t is
      v_out_json  json_object_t;
      v_codcomp   temploy1.codcomp%type;
      v_codempid  varchar2(1000 char);
  begin
    v_out_json := v_in_item_json;

    if ( hcm_util.get_string_t(v_in_item_json,'codempid') is not null ) then
      v_out_json.put('CODEMPID',hcm_util.get_string_t(v_in_item_json,'codempid'));
    end if;
    v_codempid := hcm_util.get_string_t(v_in_item_json,'codempid');
    begin
      select hcm_util.get_codcomp_level(codcomp,1) into v_codcomp
        from temploy1
       where codempid = v_codempid;
      v_out_json.put('CODCOMPY',v_codcomp);
    exception when no_data_found then
      v_out_json.put('CODCOMPY','');
    end;

    return v_out_json;
  end add_value_other;
  -- Gen file send mail
  procedure gen_file_send_mail(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_word(json_str_input);
		if param_msg_error is null then
      gen_report_data(json_str_output);
      if (param_msg_error is not null) then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        commit;
      end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure initial_gettcodmist(json_str_input in clob) as
		json_obj		json_object_t;
	begin
		json_obj := json_object_t( json_str_input);
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

	end initial_gettcodmist;

	procedure gettcodmist(json_str_input in clob, json_str_output out clob) as
	begin

		initial_gettcodmist(json_str_input);
		if param_msg_error is null then
			gentcodmist(json_str_input,json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gettcodmist;

	procedure gentcodmist(json_str_input in clob, json_str_output out clob) as

		cursor c1 is
      select CODCODEC,
             DECODE (global_v_lang ,'101', DESCODE ,
                                    '102', DESCODT,
                                    '103', DESCOD3,
                                    '104', DESCOD4,
                                    '105', DESCOD5,DESCODE ) as DESCODE
       from TCODMIST
      order by codcodec;
		v_rcnt			  number ;
		obj_data		  json_object_t ;
		resultReturn	json_object_t;
	begin
		resultReturn := json_object_t();
		v_rcnt := 0 ;
		for r1 in c1 loop
			obj_data := json_object_t();
			obj_data.put('response', '');
			obj_data.put('coderror', '200');
			obj_data.put('codcodec',r1.CODCODEC);
			obj_data.put('descode',r1.DESCODE);
			resultReturn.put(to_char(v_rcnt),obj_data);
			v_rcnt := v_rcnt+1;
		end loop;

		json_str_output := resultReturn.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gentcodmist;

  --
	procedure send_mail ( json_str_input in clob,json_str_output out clob) as
    obj_result      json_object_t;
		itemselected	  json_object_t;
    v_numdoc        varchar2(1000 char);
    v_filepath      varchar2(1000 char);
    v_filename      varchar2(1000 char);
    v_dteeffec      date;
		v_codfrm_to		  tfwmailh.codform%type;
    v_response      varchar2(4000 char);
    v_subject       tapplscr.desclabelt%type;
    ttmistk_obj		  ttmistk%rowtype;
    v_rowid_query		varchar2(100 char);
--		v_typesend		tfwmailh.typesend%type;
		v_msg_to        long;
		v_template_to   long;
		v_func_appr		  varchar2(10 char);
		v_error			    varchar2(10 char);

--		itemdatarowselected	  json_object_t;
--		codempidowner		      temploy1.codempid%type := get_codempid(global_v_coduser);
--		fullnameowner		      varchar2(60 char);
--		fullnamesubscriber	  varchar2(60 char);
--		label_msg_appscreen	  varchar2(150 char);
--		codpositionowner	    temploy1.codpos%type := get_codpos_by_codempid(codempidowner);
--		codpositionname		    varchar2(500 char) := get_tpostn_name(codpositionowner,global_v_lang);
--		emailowner		        temploy1.email%type := get_email_by_codempid (codempidowner);
--		emailsubscriber		    temploy1.email%type;
--		error_send_email	      varchar2(500 char);
--		format_date_dd_mm_yyyy	varchar2(10 char) := 'dd/mm/yyyy';
--		itemjsonnumannou	      varchar2(30);
--		itemjsondteeffec	      varchar2(30);
    v_codempid              temploy1.codempid%type;
	begin
    initial_word(json_str_input);

		for i in 0..p_data_sendmail.get_size - 1 loop
      itemSelected  := hcm_util.get_json_t( p_data_sendmail,to_char(i));
      v_numdoc      := hcm_util.get_string_t(itemSelected,'numberdocument');
      v_filepath      := hcm_util.get_string_t(itemSelected,'filepath');
      v_filename      := hcm_util.get_string_t(itemSelected,'filename');
      v_codempid      := hcm_util.get_string_t(itemSelected,'codempid');
      v_dteeffec      := to_date(hcm_util.get_string_t(itemSelected,'dteeffec'),'dd/mm/yyyy');
      begin
        select rowid
          into v_rowid_query
          from ttmistk
         where codempid = v_codempid
           and dteeffec = v_dteeffec;
      exception when no_data_found then
        v_rowid_query := null;
      end;
      -- Get message
      begin
          chk_flowmail.get_message_result('HRPM57X', global_v_lang, v_msg_to, v_template_to);

          v_subject := get_label_name('HRPM57X2', global_v_lang, 280);

          chk_flowmail.replace_text_frmmail(v_template_to, 'TTMISTK', v_rowid_query , v_subject , 'HRPM57X', '1', null, global_v_coduser, global_v_lang, v_msg_to,'Y',v_filepath);

          v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filepath,null,null, null);
          if  v_error <> '2046' then
            param_msg_error := get_error_msg_php('HR7522',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          else
            param_msg_error := get_error_msg_php('HR2046',global_v_lang);
          end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace||v_filepath;
        param_msg_error := get_error_msg_php('HR7522',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end;
    end loop;
--    commit;

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',v_numdoc);

    param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end send_mail;

	function get_fullname_by_codempid (codempid in VARCHAR2,global_v_lang in varchar2) return varchar2 is
		fullname		  VARCHAR2(60 CHAR);
    cur_refcur    SYS_REFCURSOR;
    sqlStr        VARCHAR2(500 CHAR);
	begin

		sqlStr := 'SELECT  decode('||global_v_lang||',''101'',NAMEMPE,''102'',NAMEMPT,''103'',NAMEMP3,''104'',NAMEMP4,''105'',NAMEMP5,null)'||' ' ;
        sqlStr := sqlStr|| 'from temploy1' || ' ';
        sqlStr := sqlStr|| ' WHERE codempid ='|| ''''||codempid||'''';

        OPEN cur_refcur FOR sqlStr;
         LOOP
                     FETCH cur_refcur INTO fullname;
                           EXIT WHEN cur_refcur%NOTFOUND;
         END LOOP;
         CLOSE cur_refcur;

		return fullname;
	end get_fullname_by_codempid;

  function get_codpos_by_codempid (codempid in VARCHAR2) return varchar2 is
		codpos			temploy1.codpos%type;
    cur_refcur  SYS_REFCURSOR;
	begin
    OPEN cur_refcur FOR 'SELECT  codpos  FROM temploy1 WHERE codempid =' || ''''||codempid||'''';
    LOOP
      FETCH cur_refcur INTO codpos;
      EXIT WHEN cur_refcur%NOTFOUND;
    END LOOP;
    CLOSE cur_refcur;

		return codpos;
	end get_codpos_by_codempid;

	function get_email_by_codempid (codempid in VARCHAR2) return varchar2 is
		email			  temploy1.email%type;
    cur_refcur  SYS_REFCURSOR;
    countEmail  number:= 0;
	begin
    OPEN cur_refcur FOR 'SELECT  email  FROM temploy1 WHERE codempid =' || ''''||codempid||'''';
    LOOP
    FETCH cur_refcur INTO email;
    EXIT WHEN cur_refcur%NOTFOUND;
    END LOOP;
    CLOSE cur_refcur;

		return email;
	end get_email_by_codempid;
END HRPM57X;

/
