--------------------------------------------------------
--  DDL for Package Body HRPM55R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM55R" AS
-- Author: 000553-Wiw-Chinnawat
-- Date updated: 04/04/2024
-- Comment: Issue 4449#1846

  procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		v_chken := hcm_secur.get_v_chken;
		json_obj := json_object_t(json_str);

		--global
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_zyear    := hcm_appsettings.get_additional_year() ;

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

		-- index
		p_cod_comp        := hcm_util.get_string_t(json_obj,'p_cod_comp');
		p_cod_empid       := hcm_util.get_string_t(json_obj,'p_cod_empid');
		p_dtestrt         := to_date(trim(hcm_util.get_string_t(json_obj,'p_date_from')),'dd/mm/yyyy');
		p_dteend          := to_date(trim(hcm_util.get_string_t(json_obj,'p_date_to')),'dd/mm/yyyy');

    p_date_from       := to_date(trim(hcm_util.get_string_t(json_obj,'p_date_from')),'dd/mm/yyyy');
    p_date_to         := to_date(trim(hcm_util.get_string_t(json_obj,'p_date_to')),'dd/mm/yyyy');
	end initial_value;


	procedure getIndex (json_str_input in clob,json_str_output out clob) AS
	BEGIN

		initial_value(json_str_input);
		validate_getIndex(json_str_input);
		if param_msg_error is null then
			genIndex(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END getIndex;

	procedure validate_getIndex(json_str_input in clob) AS
    chkExist  varchar2(1 char);

		v_secur1_pass		boolean ;
    v_secur2_pass		boolean ;
    v_secur7_pass   boolean ;

	begin
    if p_cod_comp is null and p_cod_empid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'CODCOMP');
      return ;
		elsif p_cod_comp is not null then
      if p_dtestrt is null or p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'CODEMPID');
        return ;
      end if;
      begin
        select 'Y' into chkexist from tcenter
        where codcomp like p_cod_comp||'%'
        and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'codcomp');
				return ;
      end;
      v_secur7_pass := secur_main.secur7(p_cod_comp,global_v_coduser);
			if(v_secur7_pass = false) then
				param_msg_error := get_error_msg_php('HR3007',global_v_lang);
				return ;
			end if;
			p_select_condition_codcomp := true;
		end if;
    --
    if p_cod_comp is null and p_cod_empid is not null then
			begin
				select codempid,codcomp,dteempmt,codempmt,codpos,codjob,numlvl
				into p_codempid,p_codcomp,p_dteempmt,p_codempmt,p_codpos,p_codjob,p_numlvl
				from temploy1
				where codempid = p_cod_empid;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
				return;
			end;

			v_secur1_pass := secur_main.secur1(p_codcomp, p_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
			if (v_secur1_pass = false) then
				param_msg_error := get_error_msg_php('3007',global_v_lang);
				return;
			end if;

      v_secur2_pass := secur_main.secur2(p_cod_empid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
			if (v_secur2_pass = false) then
				param_msg_error := get_error_msg_php('3007',global_v_lang);
				return;
			end if;
			p_select_condition_codcomp := false;
    end if;
	end validate_getIndex;

	procedure genIndex(json_str_output out clob) AS
	begin

		if (p_select_condition_codcomp ) then
			genIndexconditioncodcomp(json_str_output);
		else
			genIndexconditioncodempid(json_str_output);
		end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end genIndex;

	procedure genIndexconditioncodempid(json_str_output out clob) as
		v_temploy_name	varchar2(500 char);
		v_tcenter_name	varchar2(150 char);
		v_nam_codcomp	varchar2(150 char);
		v_codcurr		  temploy3.codcurr%type;
		v_amtincom1		temploy3.amtincom1%type;
		v_amtincom2		temploy3.amtincom2%type;
		v_amtincom3		temploy3.amtincom3%type;
		v_amtincom4		temploy3.amtincom4%type;
		v_amtincom5		temploy3.amtincom5%type;
		v_amtincom6		temploy3.amtincom6%type;
		v_amtincom7		temploy3.amtincom7%type;
		v_amtincom8		temploy3.amtincom8%type;
		v_amtincom9		temploy3.amtincom9%type;
		v_amtincom10	temploy3.amtincom10%type;

		v_parametergetcodincome clob;
		v_resultgetcodincome clob;
		v_resultobjgetcodincome	json_object_t;
		v_itemobjgetcodincome	json_object_t;

		amtincom1		    number;
		amtincom2		    number;
		amtincom3		    number;
		amtincom4		    number;
		amtincom5		    number;
		amtincom6		    number;
		amtincom7		    number;
		amtincom8		    number;
		amtincom9		    number;
		amtincom10	    number;
		v_day			      number;
		v_month			    number;
		v_year			    number;
		v_desc_month		varchar2(50 char);
		v_docnum		    varchar2(50 char);

		tdata_dteempmt		varchar2(100 char);
		tdata_nam_codpos	varchar2(500 char);
		tdata_nam_codjob	varchar2(500 char);
		tdata_desincom		varchar2(500 char);
		para_codcurr		  varchar2(1000 char);
		tdata_amtincom_m	number;
		tdata_amtincom_a	number;
		tdata_amtincom_s	number;
		tdata_desc_amtinicom_s	varchar2(200 char);
		v_sumhur_a		number;
		v_sumday_a		number;
		v_summon_a		number;
		v_sumhur_s		number;
		v_sumday_s		number;
		v_summon_s		number;


		obj_row			json_object_t := json_object_t();
		obj_col			json_object_t := json_object_t();

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_codempmt      temploy1.codempmt%type;
    v_codpos        temploy1.codpos%type;
    v_codjob        temploy1.codjob%type;
    v_numlvl        temploy1.numlvl%type;
    v_dteappr       temploy1.dteappr%type;

    trefreq_obj		  trefreq%rowtype;
	begin
    begin
      select codempid,codcomp,dteempmt,codempmt,codpos,codjob,numlvl,dteappr
        into v_codempid,v_codcomp,v_dteempmt,v_codempmt,v_codpos,v_codjob,v_numlvl,v_dteappr
        from temploy1
       where codempid = p_cod_empid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return ;
    end;
    /*
    begin
      select * into trefreq_obj
          from trefreq
         where staappr = 'Y'
           and codempid = p_cod_empid
           and dtereq = ( select max(dtereq)
                            from trefreq
                           where staappr = 'Y'
                             and codempid = p_cod_empid)
          and numseq = ( select max(numseq)
                            from trefreq
                           where staappr = 'Y'
                             and codempid = p_cod_empid)
      order by codempid;
    exception when no_data_found then
      trefreq_obj := null;
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREFREQ');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
    end;
    */
    obj_col.put('dteappr' , to_char(v_dteappr,'dd/mm/yyyy'));
    obj_col.put('dtereq' , to_char(trefreq_obj.dtereq,'dd/mm/yyyy'));
    obj_col.put('numseq', trefreq_obj.numseq);
    obj_col.put('image' , get_emp_img(v_codempid));
    obj_col.put('codempid' , v_codempid);
    obj_col.put('desc_codempid' , get_temploy_name(v_codempid,global_v_lang));
    obj_col.put('codcomp' , v_codcomp);
    obj_col.put('desc_codcomp' , get_tcenter_name(v_codcomp,global_v_lang));
    --<<User37 NXP-HR2101 #6370 28/07/2021 
    /*obj_col.put('flginc',trefreq_obj.flginc);
    obj_col.put('typcertif',trefreq_obj.typcertif);
    obj_col.put('desc_typcertif',get_tcodec_name('tcodtypcrt',trefreq_obj.typcertif,global_v_lang));
    if (trefreq_obj.flginc = 'Y') then
      obj_col.put('desc_flginc',get_label_name('HRPM55R2',global_v_lang,200)); --100
    else
      obj_col.put('desc_flginc',get_label_name('HRPM55R2',global_v_lang,210)); --110
    end if;*/
    obj_col.put('codform' , trefreq_obj.codform);
    obj_col.put('desc_codform' , get_tfmrefr_name(trefreq_obj.codform,global_v_lang));
    -->>User37 NXP-HR2101 #6370 28/07/2021 
    obj_col.put('numod',trefreq_obj.numcerti);
    obj_col.put('desnote',trefreq_obj.desnote);

		obj_row.put('0',obj_col);

		json_str_output := obj_row.to_clob;
	end genIndexconditioncodempid;

	procedure genIndexconditioncodcomp(json_str_output out clob) as
		v_data			  varchar2(1 char);
		v_secur			  varchar2(1 char);
		v_codcurr		  temploy3.codcurr%type;
		flg_secur		  boolean ;
		v_amtincom1		temploy3.amtincom1%type;
		v_amtincom2		temploy3.amtincom2%type;
		v_amtincom3		temploy3.amtincom3%type;
		v_amtincom4		temploy3.amtincom4%type;
		v_amtincom5		temploy3.amtincom5%type;
		v_amtincom6		temploy3.amtincom6%type;
		v_amtincom7		temploy3.amtincom7%type;
		v_amtincom8		temploy3.amtincom8%type;
		v_amtincom9		temploy3.amtincom9%type;
		v_amtincom10	temploy3.amtincom10%type;

		v_parametergetcodincome   clob;
		v_resultGetCodIncome      clob;
		v_resultobjgetcodincome	  json_object_t;
		v_itemobjgetcodincome	    json_object_t;
		amtincom1		number;
		amtincom2		number;
		amtincom3		number;
		amtincom4		number;
		amtincom5		number;
		amtincom6		number;
		amtincom7		number;
		amtincom8		number;
		amtincom9		number;
		amtincom10	number;
		v_day			  number;
		v_month			number;
		v_year			number;
		v_desc_month		  varchar2(50);
		tdata_dteempmt		varchar2(100);
		tdata_nam_codpos	varchar2(500);
		tdata_nam_codjob	varchar2(500);
		tdata_desincom		varchar2(500);
		para_codcurr		  varchar2(1000);
		tdata_amtincom_m	number;
		tdata_amtincom_a	number;
		tdata_amtincom_s	number;

		tdata_desc_amtinicom_s	varchar2(200 CHAR);
		number_row		number;
		jsonobjrow		json_object_t := json_object_t();
		jsonobjcol		json_object_t;

		v_sumhur_a		number;
		v_sumday_a		number;
		v_summon_a		number;
		v_sumhur_s		number;
		v_sumday_s		number;
		v_summon_s		number;
		v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_codempmt      temploy1.codempmt%type;
    v_codpos        temploy1.codpos%type;
    v_codjob        temploy1.codjob%type;
    v_numlvl        temploy1.numlvl%type;
    v_docnum        varchar2(1000 char);
    cursor c1 is
      select *
        from trefreq
       where staappr = 'Y'
         and codcomp like p_cod_comp||'%'
--         and numcerti is null /*SA(ball) recommend comment this line */
         and dteappr BETWEEN p_date_from and p_date_to
    order by codempid;

	begin
		number_row := 0;
		v_data := 'N' ;

		for i in c1 loop
			jsonobjcol := json_object_t();
			v_data := 'Y';
			begin
				select codempid,codcomp,dteempmt,codempmt,codpos,codjob,numlvl
          into v_codempid,v_codcomp,v_dteempmt,v_codempmt,v_codpos,v_codjob,v_numlvl
          from temploy1
				 where codempid = i.codempid;
			exception when no_data_found then
				null;
			end;
			flg_secur := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
			if (flg_secur) then
				v_secur := 'Y';
--				jsonobjcol.put('chk',v_secur);
        jsonobjcol.put('coderror',200);
				jsonobjcol.put('numseq', i.numseq);
				jsonobjcol.put('dteappr', to_char(i.dteappr,'dd/mm/yyyy'));
				jsonobjcol.put('dtereq', to_char(i.dtereq,'dd/mm/yyyy'));
				jsonobjcol.put('image', get_emp_img(v_codempid));
				jsonobjcol.put('codempid', i.codempid);
				jsonobjcol.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang));
				jsonobjcol.put('codcomp',i.codcomp);
				jsonobjcol.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
				--<<User37 NXP-HR2101 #6370 28/07/2021 
                /*jsonobjcol.put('flginc',i.flginc);
				jsonobjcol.put('typcertif',i.typcertif);
				jsonobjcol.put('desc_typcertif',get_tcodec_name('tcodtypcrt',i.typcertif,global_v_lang));
                if (i.flginc = 'Y') then
					jsonobjcol.put('desc_flginc',get_label_name('HRPM55R2',global_v_lang,200)); --100
				else
					jsonobjcol.put('desc_flginc',get_label_name('HRPM55R2',global_v_lang,210)); --110
				end if;*/
                jsonobjcol.put('codform' , i.codform);
                jsonobjcol.put('desc_codform' , get_tfmrefr_name(i.codform,global_v_lang));
                -->>User37 NXP-HR2101 #6370 28/07/2021 
				jsonobjcol.put('numod',i.numcerti);
				jsonobjcol.put('desnote',i.desnote);

--        v_docnum := get_docnum('3',hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
--        jsonobjcol.put('docnum',v_docnum);

        jsonobjrow.put(to_char(number_row),jsonobjcol);
        number_row := number_row + 1;
			end if;

		end loop;

		if (v_data = 'N') then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREFREQ');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
			return;
    elsif (number_row = 0 ) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
		else
			json_str_output := jsonobjrow.to_clob;
		end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end genIndexconditioncodcomp;
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
       where codapp = 'HRPM55R'
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
       where codapp = 'HRPM55R'
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
		v_chken := hcm_secur.get_v_chken;
		json_obj := json_object_t(json_str);
		p_codform := hcm_util.get_string_t(json_obj,'p_codform');

	end initial_prarameterreport;

	procedure get_html_message(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_prarameterreport(json_str_input);
		validate_v_getprarameterreport(json_str_input);

		if param_msg_error is null then
			gen_html_message(json_str_input,json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_html_message;

	procedure gen_html_message (json_str_input in clob, json_str_output out clob) AS
		o_nsal_html_1 clob;
		o_nsal_typemsg1		varchar2(10 CHAR);
		o_nsal_html_2 clob;
		o_nsal_typemsg2		varchar2(10 CHAR);
		o_nsal_html_3 clob;

		o_ysal_html_1 clob;
		o_ysal_typemsg1		varchar2(10 CHAR);
		o_ysal_html_2 clob;
		o_ysal_typemsg2		varchar2(10 CHAR);
		o_ysal_html_3 clob;
		obj_data		json_object_t;
		v_rcnt			number := 0;

	begin
		gen_html_form(p_codform, o_nsal_html_1, o_nsal_typemsg1, o_nsal_html_2, o_nsal_typemsg2, o_nsal_html_3);

		obj_data := json_object_t();
    obj_data := append_clob_json(obj_data,'head_html',o_nsal_html_1);
    obj_data := append_clob_json(obj_data,'body_html',o_nsal_html_2);
    obj_data := append_clob_json(obj_data,'footer_html',o_nsal_html_3);
		obj_data.put('coderror', '200');
		obj_data.put('response','');

    if p_namimglet is not null then
       p_namimglet := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMB9E')||'/'||p_namimglet;
    end if;
		obj_data.put('head_letter',p_namimglet);
		json_str_output := obj_data.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gen_html_message;

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
			where codform =p_codform;
		exception when NO_DATA_FOUND then
			o_message3 := null ;
		end;
	end gen_html_form;

	procedure validate_v_getprarameterreport(json_str_input in clob) as
	begin
    if (p_codform is null or p_codform = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_codform');
      return ;
    end if;

    begin
      select typfm into p_typfm from tfmrefr where codform = p_codform;
      if (p_typfm <> 'HRPM55R') then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      end if;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFMREFR');
      return;
    end;

	end validate_v_getprarameterreport;

	procedure get_prarameterreport(json_str_input in clob, json_str_output out clob) as
	begin
		initial_prarameterreport(json_str_input);
		validate_v_getprarameterreport(json_str_input);
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
		cursor c1 is
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
         and flgstd <> 'Y'
       order by ffield ;

		obj_data		json_object_t;
		obj_row			json_object_t;
		v_rcnt			number := 0;
    v_numseq    number;
    v_flgedit   boolean := false;
    v_value     varchar2(1000 char);
	begin
		obj_row := json_object_t();
    v_numseq := 23;
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
      obj_data.put('codform',r1.codform);
      obj_data.put('codtable',r1.codtable);
      obj_data.put('ffield',r1.ffield);
      obj_data.put('flgdesc',r1.flgdesc);
      obj_data.put('flginput',r1.flginput);
      obj_data.put('flgstd',r1.flgstd);
      obj_data.put('fparam',r1.fparam);
      obj_data.put('numseq',r1.numseq);
      obj_data.put('section',r1.section);
      obj_data.put('descript',r1.descript);
      begin
        select datainit1 into v_value
          from tinitial
         where codapp = 'HRPM55R'
           and numseq = v_numseq;
           v_flgedit := true;
      exception when no_data_found then
        v_flgedit := false;
        v_value := '';
      end;
      obj_data.put('flgEdit',v_flgedit);
      obj_data.put('value',v_value);
			obj_row.put(to_char(v_rcnt-1),obj_data);
      v_numseq := v_numseq + 1;
		end loop;

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_prarameterreport;

	procedure validateprintreport(json_str_input in clob) as
		json_obj		json_object_t;
		codform			varchar2(10 char);
	begin
		v_chken   := hcm_secur.get_v_chken;
		json_obj  := json_object_t(json_str_input);

		--initial global
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    global_v_zyear := hcm_appsettings.get_additional_year() ;
		-- index
    p_detail_obj      := hcm_util.get_json_t(json_object_t(json_obj),'details');
		p_url             := hcm_util.get_string_t(json_object_t(json_obj),'url');
		p_codform         := hcm_util.get_string_t(p_detail_obj,'codform');
		p_dateprint_date  := to_date(trim(hcm_util.get_string_t(p_detail_obj,'dateprint')),'dd/mm/yyyy');
		p_numlettr        := hcm_util.get_string_t(p_detail_obj,'numlettr');
		p_cod_comp        := hcm_util.get_string_t(p_detail_obj,'codcomp');
		p_cod_empid       := hcm_util.get_string_t(p_detail_obj,'codempid');
		p_date_from       := to_date(hcm_util.get_string_t(p_detail_obj,'date_from'),'dd/mm/yyyy');
		p_date_to         := to_date(hcm_util.get_string_t(p_detail_obj,'date_to'),'dd/mm/yyyy');
		p_dataSelectedObj := hcm_util.get_json_t(json_object_t(json_obj),'dataselected');
		p_resultfparam := hcm_util.get_json_t(json_obj,'fparam');
    p_data_sendmail   := hcm_util.get_json_t(json_obj,'dataRows');

		if p_dateprint_date is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dateprint');
			return ;
		end if ;

		if (p_codform is not null and p_codform <> ' ') then
			begin
				select codform into codform
				from tfmrefr
				where codform = p_codform;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TFMREFR');
				return;
			end;
		end if;

	end validateprintreport;

	procedure printreport(json_str_input in clob, json_str_output out clob) as
	begin
		validateprintreport(json_str_input);
		if (param_msg_error is null or param_msg_error = ' ' ) then
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
	end printreport;
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

	procedure gen_report_data ( json_str_output out clob) as
		itemSelected		json_object_t := json_object_t();

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
		v_resultcol		json_object_t ;
		v_resultrow		json_object_t := json_object_t();
    obj_rows      json_object_t;
    obj_result    json_object_t;
		v_countrow		number := 0;

    v_dtereq       date;
    v_numseq       number;

		type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    arr_result        arr_1d;
    obj_fparam      json_object_t := json_object_t();
    v_codempid      temploy1.codempid%type;
    v_codcomp		    temploy1.codcomp%type;
    v_docnum			  varchar2(100 char);

    temploy1_obj		temploy1%rowtype;
    temploy3_obj		temploy3%rowtype;

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

    v_desc_amtincom_s   varchar2(4000 char);
    v_amtincom_a        number := 0;
    v_amtincom_s        number := 0;
    v_sumhur		        number := 0;
		v_sumday		        number := 0;
		v_summon		        number := 0;
		v_namimglet		      tfmrefr.namimglet%type;
		v_folder		        tfolderd.folder%type;
    v_namesign          varchar2(1000 char);
    p_signid            varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_numlettr          varchar2(1000 char);
    v_pathimg           varchar2(1000 char);
    v_date_std          varchar2(1000 char);
    v_flgdesc           tfmparam.flgdesc%type;
    v_filename          varchar2(1000 char);
    v_rowid             number := 0;
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
		v_day         := to_number(to_char(p_dateprint_date,'dd'),'99');
		v_desc_month  := get_nammthful(to_number(to_char(p_dateprint_date,'mm')),v_codlang);
		v_year        := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(p_dateprint_date,'yyyy')));
		tdata_dteprint := v_day||' '||v_desc_month||' '||v_year;
    numYearReport   := HCM_APPSETTINGS.get_additional_year();

    insert into A (A, B) values (global_v_lang, 'global_v_lang'); commit;
    insert into A (A, B) values (v_codlang, 'v_codlang'); commit;

		for i in 0..p_dataSelectedObj.get_size - 1 loop
			itemSelected  := hcm_util.get_json_t( p_dataSelectedObj,to_char(i));
      v_codempid    := hcm_util.get_string_t(itemSelected,'codempid');
      v_codcomp     := hcm_util.get_string_t(itemSelected,'codcomp');
      v_dtereq      := to_date(hcm_util.get_string_t(itemSelected,'dtereq'),'dd/mm/yyyy');
      v_numseq      := hcm_util.get_string_t(itemSelected,'numseq');
      v_numlettr    := hcm_util.get_string_t(itemSelected,'numod');
      v_rowid       := hcm_util.get_string_t(itemSelected,'rowID');
      --    v_docnum := get_docnum('3',hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
--    obj_col.put('docnum',v_docnum);
      if v_numlettr is null then
        begin
          select numcerti  into v_numlettr
            from trefreq
           where codempid = v_codempid
             and dtereq = v_dtereq
             and numseq = v_numseq;
        exception when no_data_found then
          v_numlettr  :=  '';
        end;
        if v_numlettr is null then
          v_numlettr := get_docnum('3',hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
        end if;
      end if;
      begin
        select *
          into temploy1_obj
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        temploy1_obj := null;
      end ;
      begin
        select *
          into temploy3_obj
          from temploy3
         where codempid = v_codempid;
      exception when no_data_found then
        temploy3_obj := null;
      end ;

      -- #check_numdoc
      check_numdoc(v_codempid, v_codcomp);
      if (param_msg_error is not null) then
        return ;
      end if;

      -- Read Document HTML
      gen_html_form(p_codform,o_html_1,o_typemsg1,o_html_2,o_typemsg2,o_html_3);
      list_msg_html := html_array(o_html_1,o_html_2,o_html_3);

      get_wage_income( hcm_util.get_codcomp_level(temploy1_obj.codcomp,1) ,temploy1_obj.codempmt,
                         0,
                         to_number(stddec(temploy3_obj.amtincom2,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom3,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom4,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom5,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom6,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom7,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom8,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom9,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom10,v_codempid,v_chken)),
                         v_sumhur ,v_sumday,v_summon);
        v_amtincom_a := v_summon; -- รายได้อื่นๆ

        get_wage_income( hcm_util.get_codcomp_level(temploy1_obj.codcomp,1) ,temploy1_obj.codempmt,
                         to_number(stddec(temploy3_obj.amtincom1,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom2,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom3,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom4,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom5,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom6,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom7,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom8,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom9,v_codempid,v_chken)),
                         to_number(stddec(temploy3_obj.amtincom10,v_codempid,v_chken)),
                         v_sumhur ,v_sumday,v_summon);
        v_amtincom_s := v_summon; -- รายได้ต่อเดือน
        v_desc_amtincom_s := get_amount_name(v_amtincom_s,global_v_lang);
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
          if p_dateprint_date is not null then
            v_date_std := '';
            if v_flgdesc = 'Y' then
              arr_result := explode('/', to_char(p_dateprint_date,'dd/mm/yyyy'), 3);
              v_day := arr_result(1);
              v_month := arr_result(2);
              v_year := arr_result(3);
              v_date_std := to_number(v_day) ||' '||
                            get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' ||
                            get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
            else
              v_date_std := to_char(add_months(p_dateprint_date, numYearReport*12),'dd/mm/yyyy');
            end if;
          end if;
          -- input from display[PARAM-DOCID]
					data_file := replace(data_file,'[PARAM-DOCID]', v_numlettr);
					data_file := replace(data_file,'[PARAM-DATE]', v_date_std);
					data_file := replace(data_file,'[PARAM-AMTNET]', to_char(v_amtincom_s,'fm999,999,999,990.00'));
					data_file := replace(data_file,'[PARAM-BAHTNET]', get_amount_name(v_amtincom_s,global_v_lang));
					data_file := replace(data_file,'[PARAM-AMTOTH]',to_char(v_amtincom_a,'fm999,999,999,990.00'));
					data_file := replace(data_file,'[PARAM-BAHTOTH]',get_amount_name(v_amtincom_a,global_v_lang));
          data_file := replace(data_file,'[PARAM-COMPANY]',get_tcompny_name(get_codcompy(temploy1_obj.codcomp),global_v_lang));

          for j in 0..p_resultfparam.get_size - 1 loop
            obj_fparam      := hcm_util.get_json_t( p_resultfparam,to_char(j));
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
          insert into A (A, B) values (data_file, 'data_file'); commit;
          list_msg_html(i) := data_file ;
        end loop;
        begin
          update trefreq
             set numcerti = v_numlettr
           where codempid = v_codempid
             and dtereq = v_dtereq
             and numseq = v_numseq;
        end;

        v_resultcol		:= json_object_t ();

        v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
        v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
        v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
        if v_namimglet is not null then
          v_pathimg := v_folder||'/'||v_namimglet;
        end if;
        v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
        v_filename := global_v_coduser||'_'||to_char(sysdate,'yyyymmddhh24miss')||'_'||(i+1);

        v_resultcol.put('filepath',p_url||'file_uploads/'||v_filename||'.doc');
        v_resultcol.put('filename',v_filename);
        v_resultcol.put('rowId',v_rowid);
        v_resultcol.put('numberdocument',v_numlettr);
        v_resultcol.put('codempid',v_codempid);
        v_resultcol.put('dtereq',to_char(v_dtereq,'dd/mm/yyyy'));
        v_resultcol.put('numseq',v_numseq);
        v_resultcol.put('coderror', '200');
        v_resultcol.put('response','');
        v_resultrow.put(to_char(v_countrow), v_resultcol);

        v_countrow := v_countrow + 1;
    end loop; -- end of loop data
    obj_rows  :=  json_object_t();
    obj_rows.put('rows',v_resultrow);

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',v_numlettr);
    obj_result.put('table',obj_rows);

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
          --130
          --140
          -- Issue 4449#1846 | 000553-Wiw-Chinnawat | 04/04/2024 | chagne global_v_lang to v_codlang
          if (v_codlang = 102) then
            v_year := hcm_util.get_year_buddhist_era(v_year);
          end if;

          v_dataexct := to_number(v_day) ||' '||
                        get_label_name('HRPM55R2',v_codlang,220) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),v_codlang) || ' ' ||
                        get_label_name('HRPM55R2',v_codlang,230) || ' ' ||v_year;
          -- Issue 4449#1846 | 000553-Wiw-Chinnawat | 04/04/2024 | chagne global_v_lang to v_codlang
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
        v_value   := 'to_date('''||to_char(to_date(v_value),'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ;
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      else
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      end if;
     end loop;
    return v_statmt;
  end std_get_value_replace;

	function get_item_property (p_table in VARCHAR2,p_field in VARCHAR2) return varchar2 is

		cursor c_datatype is
		select t.data_type as DATATYPE
		from user_tab_columns t
		where t.TABLE_NAME = p_table
		and t.COLUMN_NAME= substr(p_field, instr(p_field,'.')+1);
		valueDataType		json_object_t := json_object_t();
	begin
		for i in c_datatype loop
			valueDataType.put('DATATYPE',i.DATATYPE);
		end loop;
		return hcm_util.get_string_t(valueDataType,'DATATYPE');
	end get_item_property;

	function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
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
      v_out_json.put('CODEMPID',hcm_util.get_string_T(v_in_item_json,'codempid'));
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
		validateprintreport(json_str_input);
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
    v_rowid_query		varchar2(100 char);
--		v_typesend		tfwmailh.typesend%type;
		v_msg_to        long;
		v_template_to   long;
		v_func_appr		  varchar2(10 char);
		v_error			    varchar2(10 char);

		itemdatarowselected	  json_object_t;
		codempidowner		      temploy1.codempid%type := get_codempid(global_v_coduser);
		fullnameowner		      varchar2(60 char);
		fullnamesubscriber	  varchar2(60 char);
		label_msg_appscreen	  varchar2(150 char);
		codpositionowner	    temploy1.codpos%type;
		codpositionname		    varchar2(500 char);
		emailowner		        temploy1.email%type;
		emailsubscriber		    temploy1.email%type;
		error_send_email	      varchar2(500 char);
		format_date_dd_mm_yyyy	varchar2(10 char) := 'dd/mm/yyyy';
		itemjsonnumannou	      varchar2(30);
		itemjsondteeffec	      varchar2(30);
    v_codempid              varchar2(1000 char);
    v_dtereq                date;
    v_numseq                number;
	begin
    validateprintreport(json_str_input);
		begin
			select codform into v_codfrm_to
			from tfwmailh
			where codapp = 'HRPM55R';
		exception when no_data_found then
			v_codfrm_to := null;
		end;


		for i in 0..p_data_sendmail.get_size - 1 loop
      itemSelected  := hcm_util.get_json_t( p_data_sendmail,to_char(i));
      v_numdoc      := hcm_util.get_string_t(itemSelected,'numberdocument');
      v_filepath      := hcm_util.get_string_t(itemSelected,'filepath');
      v_filename      := hcm_util.get_string_t(itemSelected,'filename');
      v_codempid      := hcm_util.get_string_t(itemSelected,'codempid');
      v_numseq        := hcm_util.get_string_t(itemSelected,'numseq');
      v_dtereq        := to_date(hcm_util.get_string_t(itemSelected,'dtereq'),'dd/mm/yyyy');
      begin
        select rowid
          into v_rowid_query
          from TREFREQ
         where codempid = v_codempid
             and dtereq = v_dtereq
             and numseq = v_numseq;
      exception when no_data_found then
        v_rowid_query := null;
      end;
      -- Get message
      begin
          chk_flowmail.get_message_result('HRPM55R', global_v_lang, v_msg_to, v_template_to);
          v_subject := get_label_name('HRPM55R2', global_v_lang, 240); --140

          chk_flowmail.replace_text_frmmail(v_template_to, 'TREFREQ', v_rowid_query , v_subject , 'HRPM55R', '1', null, global_v_coduser, global_v_lang, v_msg_to,'Y',v_filename);

          v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filepath,null,null, null);

          if  v_error <> '2046' then
            param_msg_error := get_error_msg_php('HR7522',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          else
            param_msg_error := get_error_msg_php('HR2046',global_v_lang);
          end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        param_msg_error := get_error_msg_php('HR7522',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end;
    end loop;
--    commit;

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',v_numdoc);

--    param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end send_mail;

END HRPM55R;

/
