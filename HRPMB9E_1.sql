--------------------------------------------------------
--  DDL for Package Body HRPMB9E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB9E" IS

	PROCEDURE initial_value (json_str	in clob) IS
    json_obj		json_object_t := json_object_t(json_str);
	BEGIN
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_typfm             := hcm_util.get_string_t(json_obj,'p_typfm');

    p_codtable          := hcm_util.get_string_t(json_obj,'p_codtable');
    p_codlang           := hcm_util.get_string_t(json_obj,'p_codlang');
    p_codform           := hcm_util.get_string_t(json_obj,'p_codform');
    p_codform_to        := hcm_util.get_string_t(json_obj,'p_codform_to');
    p_isCopy            := hcm_util.get_string_t(json_obj,'p_isCopy');

    p_message           := hcm_util.get_string_t(json_obj,'p_messsage');
    p_message2          := hcm_util.get_string_t(json_obj,'p_messsage2');
    p_message3          := hcm_util.get_string_t(json_obj,'p_messsage3');
    p_message_display   := hcm_util.get_string_t(json_obj,'p_messsage_display');
    p_message_display2  := hcm_util.get_string_t(json_obj,'p_messsage_display2');
    p_message_display3  := hcm_util.get_string_t(json_obj,'p_messsage_display3');
    p_typemsg           := hcm_util.get_string_t(json_obj,'p_typemsg');
    p_namfm             := hcm_util.get_string_t(json_obj,'p_namfm');
    p_namfme	          := hcm_util.get_string_t(json_obj,'p_namfme');
    p_namfmt	          := hcm_util.get_string_t(json_obj,'p_namfmt');
    p_namfm3	          := hcm_util.get_string_t(json_obj,'p_namfm3');
    p_namfm4	          := hcm_util.get_string_t(json_obj,'p_namfm4');
    p_namfm5	          := hcm_util.get_string_t(json_obj,'p_namfm5');
    p_namimglet         := hcm_util.get_string_t(json_obj,'p_namimglet');
    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	END initial_value;

	PROCEDURE get_json_obj (json_str_input IN CLOB) IS
	BEGIN
		p_formheader  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str') );
		p_formbody    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str2') );
		p_formfooter  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str3') );
	END get_json_obj;

	procedure get_detail (json_str_output out clob) is
		v_rcnt			number := 0;
    v_codform   tfmrefr.codform%type;
    v_codlang   tfmrefr.codlang%type;
    v_typfm     tfmrefr.typfm%type;
    v_namimglet   tfmrefr.namimglet%type;
    v_flgstd   tfmrefr.flgstd%type;
    v_formnam   tfmrefr.namfme%type;
    v_isCopy    varchar2(2 char) := 'N';
    v_namfme	  tfmrefr.namfme%type;
    v_namfmt	  tfmrefr.namfmt%type;
    v_namfm3	  tfmrefr.namfm3%type;
    v_namfm4	  tfmrefr.namfm4%type;
    v_namfm5	  tfmrefr.namfm5%type;
	begin

      begin
        select codform,codlang,typfm,namimglet,flgstd,
               decode(global_v_lang,'101',namfme,
                              '102',namfmt,
                              '103',namfm3,
                              '104',namfm4,
                              '105',namfm5) as formnam,
                 namfme, namfmt, namfm3, namfm4, namfm5
            into v_codform,v_codlang,v_typfm,v_namimglet,v_flgstd,v_formnam,
                 v_namfme, v_namfmt, v_namfm3, v_namfm4, v_namfm5
              from tfmrefr
              where codform = p_codform;
      exception when no_data_found then null;
      end;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
--			obj_data.put('codform',p_codform);
			obj_data.put('namfm',v_formnam);
      obj_data.put('namfme',v_namfme);
			obj_data.put('namfmt',v_namfmt);
			obj_data.put('namfm3',v_namfm3);
			obj_data.put('namfm4',v_namfm4);
			obj_data.put('namfm5',v_namfm5);
			obj_data.put('codlang',v_codlang);
			obj_data.put('namimglet',v_namimglet);
			obj_data.put('typfm',v_typfm);

      if p_codform_to is not null and (p_codform_to <> p_codform) then
        v_isCopy := 'Y';
        v_flgstd := 'N';
      end if;
			obj_data.put('isCopy',v_isCopy);
			obj_data.put('flgstd',nvl(v_flgstd,'N'));

    json_str_output := obj_data.to_clob;
	exception when no_data_found then
		obj_data		:= json_object_t ();
		obj_data.put('coderror','200');
    json_str_output := obj_data.to_clob;
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_header_detail (json_str_output out clob) is
		v_message		    tfmrefr.message%type;
		v_messagedsp		tfmrefr.messagedsp%type;
		v_rcnt			    number := 0;

		cursor c_tfmparam_header is 
      select codform, section, numseq, fparam, ffield, descript, flgstd, flgdesc, flginput, codtable
        from tfmparam
       where codform = p_codform
         and section = 1
    order by numseq;
	begin
		obj_child_row		:= json_object_t ();
		begin
			select message, messagedsp
			  into v_message, v_messagedsp
        from tfmrefr
			 where codform = p_codform;
		exception when others then
			v_message     := '';
      v_messagedsp  := '';
		end;

		for i in c_tfmparam_header loop
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codform',i.codform);
			obj_data.put('section',i.section);
			obj_data.put('numseq',i.numseq);
			obj_data.put('fparam',i.fparam);
			obj_data.put('ffield',i.ffield);
			obj_data.put('descript',i.descript);
			obj_data.put('flgstd',i.flgstd);
			obj_data.put('flgdesc',i.flgdesc);
			obj_data.put('flginput',i.flginput);
			obj_data.put('codtable',i.codtable);
      if i.codtable <> 'NOTABLE' then
        obj_data.put('desc_ffield',i.codtable||'.'||i.ffield);
      else
        obj_data.put('desc_ffield',i.ffield);
      end if;

			obj_child_row.put(to_char(v_rcnt - 1),obj_data);
		end loop;
    json_str_output := obj_child_row.to_clob;
--    json_str_output := obj_child_row.to_clob;
	exception when no_data_found then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_message_detail (json_str_output out clob) is
    v_strjson clob;
    v_obj_template json_object_t;
	begin
    begin
      select
              '{' ||
			  '"'||'message1'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr.message,' '))|| '"'|| ','||
              '"'||'message_display1'||'"'||' : '||'"'|| esc_json( nvl(tfmrefr.messagedsp,' '))|| '"'|| ','||
              '"'||'message2'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr2.message,' '))|| '"'|| ','||
              '"'||'message_display2'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr2.messagedsp,' '))|| '"'|| ','||
              '"'||'typemsg'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr2.typemsg,' '))|| '"'|| ','||
              '"'||'message3'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr3.message,' '))|| '"'|| ','||
              '"'||'message_display3'||'"'||' : '||'"'|| esc_json(nvl(tfmrefr3.messagedsp,' '))|| '"' || ',' ||
              '"'||'coderror'||'"'||' : '||'"'||'200'||'"'||
              '}'
              into v_strjson
			from tfmrefr
      left join tfmrefr2 on tfmrefr2.codform = tfmrefr.codform
      left join tfmrefr3 on tfmrefr3.codform = tfmrefr2.codform
      where tfmrefr.codform = p_codform ;

      v_obj_template := json_object_t.parse(v_strjson);
      exception when no_data_found then
          v_obj_template := json_object_t();
          v_obj_template.put('coderror','200');
          v_obj_template.put('message2',trim(' '));
          v_obj_template.put('typemsg',trim(' '));
          v_obj_template.put('message_display2',trim(' '));
          v_obj_template.put('message3',trim(' '));
          v_obj_template.put('message_display3',trim(' '));
          v_obj_template.put('message1',trim(' '));
          v_obj_template.put('message_display1',trim(' '));
      end;
--      dbms_lob.createtemporary(json_str_output,true);
--    v_obj_template.to_clob(json_str_output);
    json_str_output :=  v_obj_template.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_body_detail (json_str_output out clob) is
		v_message		tfmrefr2.message%type;
		v_rcnt			number := 0;

		cursor c_tfmparam_header is 
      select codform, section, numseq, fparam, ffield, descript, flgstd, flgdesc, flginput, codtable
        from tfmparam
       where codform = p_codform
         and section = 2
    order by numseq;
	begin
		obj_child_row		:= json_object_t ();
		begin
			select message
			  into v_message
        from tfmrefr2
			 where codform = p_codform;
		exception when others then
			v_message := null;
		end;
		for i in c_tfmparam_header loop
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codform',i.codform);
			obj_data.put('section',i.section);
			obj_data.put('numseq',i.numseq);
			obj_data.put('fparam',i.fparam);
			obj_data.put('ffield',i.ffield);
			obj_data.put('descript',i.descript);
			obj_data.put('flgstd',i.flgstd);
			obj_data.put('flgdesc',i.flgdesc);
			obj_data.put('flginput',i.flginput);
			obj_data.put('codtable',i.codtable);
      if i.codtable <> 'NOTABLE' then
        obj_data.put('desc_ffield',i.codtable||'.'||i.ffield);
      else
        obj_data.put('desc_ffield',i.ffield);
      end if;

			obj_child_row.put(to_char(v_rcnt - 1),obj_data);
		end loop;
    json_str_output := obj_child_row.to_clob;
--    json_str_output := obj_child_row.to_clob; 
	exception when no_data_found then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_footer_detail (json_str_output out clob) is
		v_message		tfmrefr3.message%type;
		v_rcnt			number := 0;
		cursor c_tfmparam_header is 
      select codform, section, numseq, fparam, ffield, descript, flgstd, flgdesc, flginput, codtable
        from tfmparam
       where codform = p_codform
         and section = 3
       order by numseq;

	begin
		obj_child_row		:= json_object_t ();
		begin
			select message
			into v_message
			from tfmrefr3
			where codform = p_codform;
		exception when others then
			v_message := null;
		end;

		for i in c_tfmparam_header loop
			v_rcnt := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codform',i.codform);
			obj_data.put('section',i.section);
			obj_data.put('numseq',i.numseq);
			obj_data.put('fparam',i.fparam);
			obj_data.put('ffield',i.ffield);
			obj_data.put('descript',i.descript);
			obj_data.put('flgstd',i.flgstd);
			obj_data.put('flgdesc',i.flgdesc);
			obj_data.put('flginput',i.flginput);
			obj_data.put('codtable',i.codtable);
      if i.codtable <> 'NOTABLE' then
        obj_data.put('desc_ffield',i.codtable||'.'||i.ffield);
      else
        obj_data.put('desc_ffield',i.ffield);
      end if;

			obj_child_row.put(to_char(v_rcnt - 1),obj_data);
		end loop;
    json_str_output := obj_child_row.to_clob;
--    json_str_output :=  obj_child_row.to_clob;
	exception when no_data_found then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure check_save is
	begin
		if p_codform is null or p_codlang is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;
	end;

	procedure gen_index (json_str_output out clob) is
		v_rcnt			    number := 0;
		v_rcnt_found		number := 0;

		cursor c_tfmrefr is 
      select codform,get_tfmrefr_name (codform ,global_v_lang) namcodform,a.flgstd,
             get_tlistval_name('TYPFM',a.typfm,global_v_lang) namtypfrm,
             a.namfile
        from tfmrefr a
       where typfm like nvl(p_typfm||'%','%')
    order by typfm ,codform;

	begin
    obj_row   := json_object_t ();
		for i in c_tfmrefr loop
			v_rcnt      := v_rcnt + 1;
			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codform',i.codform);
			obj_data.put('namcodform',i.namcodform);
			obj_data.put('namtypfrm',i.namtypfrm);
			obj_data.put('namfile',i.namfile);
			obj_data.put('flgstd',nvl(i.flgstd,'N'));
			obj_row.put(to_char(v_rcnt - 1),obj_data);
		end loop;

    json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_index;

	procedure get_index (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_form (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			get_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_message (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
      get_message_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_header_form (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			get_header_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_body_form (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			get_body_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_footer_form (json_str_input in clob,json_str_output out clob) as
		obj_row			json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			get_footer_detail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure save_data (json_str_input in clob,json_str_output out clob) is
		param_json_row		json_object_t;
		v_count			      number;
		v_codform		      tfmparam.codform%type;
		v_section		      tfmparam.section%type;
		v_numseq		      tfmparam.numseq%type;
		v_codtable		    tfmparam.codtable%type;
		v_fparam		      tfmparam.fparam%type;
		v_ffield		      tfmparam.ffield%type;
		v_descript		    tfmparam.descript%type;
		v_flgstd		      tfmparam.flgstd%type;
		v_flginput		    tfmparam.flginput%type;
		v_flgdesc		      tfmparam.flgdesc%type;
		v_flgdelete		    boolean;
    p_message_clob    clob;
    p_message_clob2   clob;
    p_message_clob3   clob;
    p_message_display_clob  clob;
    p_message_display2_clob clob;
    p_message_display3_clob clob;
    v_tempt varchar2(1000 char);
	begin
		initial_value(json_str_input);
		get_json_obj(json_str_input);
		check_save;

    p_message_clob  := get_clob(json_str_input,'p_messsage');
    p_message_clob2 := get_clob(json_str_input,'p_messsage2');
    p_message_clob3 := get_clob(json_str_input,'p_messsage3');

    p_message_display_clob := get_clob(json_str_input,'p_messsage_display');
    p_message_display2_clob :=  get_clob(json_str_input,'p_messsage_display2');
    p_message_display3_clob :=  get_clob(json_str_input,'p_messsage_display3');

		if param_msg_error is null then
			select count(*)
        into v_count
        from tfmrefr
			 where codform = p_codform;

			if v_count = 0 then
        insert into tfmrefr (codform,namfme,namfmt,namfm3,namfm4,namfm5,
                             typfm,codlang,message,messagedsp,namimglet,dtecreate,codcreate,coduser, flgstd) 
             values (p_codform, p_namfme, p_namfmt, p_namfm3, p_namfm4, p_namfm5, 
                     p_typfm,p_codlang,p_message_clob,p_message_display_clob,
                     p_namimglet,sysdate,global_v_coduser,global_v_coduser, 'N');
			else
				begin
          update tfmrefr
            set namfme      = p_namfme,
                namfmt      = p_namfmt,
                namfm3      = p_namfm3,
                namfm4      = p_namfm4,
                namfm5      = p_namfm5,
                message     = p_message_clob,
                messagedsp  = p_message_display_clob,
                dteupd      = sysdate,
                coduser     = global_v_coduser,
                namfile     = p_namfile,
                namimglet   = p_namimglet,
                typfm       = p_typfm,
                codlang     = p_codlang
            where codform = p_codform;
        end;
			end if;

			v_count := 0;
      if p_isCopy = 'Y' then
        begin
        delete tfmparam
         where codform = p_codform
           and section = 1;
        end;
      end if;
--      begin
--        select count(*)
--          into v_count
--          from tfmparam
--         where codform = p_codform
--           and section = 1;
--      end;
      begin
        delete tfmparam
         where codform = p_codform
           and section = 1;
      end;
			p_formheader1 := hcm_util.get_json_t(p_formheader,'rows');
--			if v_count = 0 then
				for i in 0..p_formheader1.get_size - 1 loop
					param_json_row := hcm_util.get_json_t(p_formheader1,to_char(i));
					v_section   := nvl(hcm_util.get_string_t(param_json_row,'section'),1);
					v_numseq    := hcm_util.get_string_t(param_json_row,'numseq');
					v_codtable  := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
					v_fparam    := hcm_util.get_string_t(param_json_row,'fparam');
					v_ffield    := hcm_util.get_string_t(param_json_row,'ffield');
					v_descript  := hcm_util.get_string_t(param_json_row,'descript');
					v_flgstd    := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
					v_flginput  := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
					v_flgdesc   := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
					v_flgdelete := hcm_util.get_boolean_t(param_json_row,'flgDelete');

          if v_numseq is null then
            begin
              select nvl(max(numseq),0) + 1 into v_numseq
                from tfmparam
               where codform = p_codform
                 and section = 1;
            end;
          end if;
					if v_flgdelete = false then
						insert into tfmparam (codform, section, numseq, codtable, fparam, 
                                  ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,dteupd,coduser) 
                 values ( p_codform, v_section, v_numseq, nvl(v_codtable,'NOTABLE'), v_fparam, 
                          v_ffield, v_descript, v_flgstd, v_flginput, v_flgdesc, sysdate, global_v_coduser, sysdate, global_v_coduser );
					end if;
				end loop;
--			else
--				for i in 0..p_formheader1.get_size - 1 loop
--					v_count := 0;
--					param_json_row := hcm_util.get_json_t(p_formheader1,to_char(i) );
--					v_section     := nvl(hcm_util.get_string_t(param_json_row,'section'),1);
--					v_numseq      := hcm_util.get_string_t(param_json_row,'numseq');
--					v_codtable    := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
--					v_fparam      := hcm_util.get_string_t(param_json_row,'fparam');
--					v_ffield      := hcm_util.get_string_t(param_json_row,'ffield');
--					v_descript    := hcm_util.get_string_t(param_json_row,'descript');
--					v_flgstd      := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
--					v_flginput    := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
--					v_flgdesc     := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
--					v_flgdelete   := hcm_util.get_boolean_t(param_json_row,'flgDelete');
--          
--          if v_numseq is null then
--            begin
--              select nvl(max(numseq),0) + 1 into v_numseq
--                from tfmparam
--               where codform = p_codform
--                 and section = 1;
--            end;
--          end if;
--					select count(*) into v_count
--            from tfmparam
--					 where codform  = p_codform
--             and numseq   = v_numseq
--             and section  = 1
--             and codtable = v_codtable
--             and fparam   = v_fparam;
--            
--					if v_count = 0 then
--						if v_flgdelete = false then
--							insert into tfmparam ( codform, section, numseq, codtable, fparam, 
--                                     ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,coduser) 
--                   values ( p_codform, v_section, v_numseq, nvl(v_codtable,'NOTABLE'), v_fparam, 
--                            v_ffield, v_descript, v_flgstd, v_flginput, v_flgdesc, sysdate, global_v_coduser, global_v_coduser );
--						end if;
--					else
--						if v_flgdelete = true then
--							delete tfmparam
--							 where codform  = p_codform
--                 and numseq   = v_numseq
--                 and section  = 1
--                 and codtable = v_codtable
--                 and fparam   = v_fparam;
--						else
--							update tfmparam
--                 set ffield    = v_ffield,
--                     descript  = v_descript,
--                     flgstd    = v_flgstd,
--                     flginput  = v_flginput,
--                     flgdesc   = v_flgdesc,
--                     dteupd    = sysdate,
--                     coduser   = global_v_coduser
--							 where codform   = p_codform
--                 and numseq    = v_numseq
--                 and fparam    = v_fparam
--                 and codtable  = v_codtable
--                 and section   = 1;
--						end if;
--					end if;
--				end loop;
--			end if;

      begin
        select count(*) into v_count
          from tfmrefr2
         where codform = p_codform;
      end;
			if v_count = 0 then
				insert into tfmrefr2 ( codform, typemsg, message, messagedsp, dtecreate, codcreate,coduser ) 
             values ( p_codform, p_typemsg, p_message_clob2, p_message_display2_clob, sysdate, global_v_coduser, global_v_coduser );
			else
				update tfmrefr2
				set message     = p_message_clob2,
            messagedsp  = p_message_display2_clob,
            typemsg     = p_typemsg,
            dteupd      = sysdate,
            coduser     = global_v_coduser
				where codform   = p_codform;
			end if;

      v_count := 0;
      if p_isCopy = 'Y' then
        begin
        delete tfmparam
         where codform = p_codform
           and section = 2;
        end;
      end if;
--      begin
--        select count(*) into v_count
--          from tfmparam
--         where codform = p_codform
--           and section = 2;
--      end;
      begin
        delete tfmparam
         where codform = p_codform
           and section = 2;
      end;
			p_formbody1 := hcm_util.get_json_t(p_formbody,'rows');
--			if v_count = 0 then
				for i in 0..p_formbody1.get_size - 1 loop
					param_json_row  := hcm_util.get_json_t(p_formbody1,to_char(i) );
					v_section       := nvl(hcm_util.get_string_t(param_json_row,'section'),2);
					v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
					v_codtable      := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
					v_fparam        := hcm_util.get_string_t(param_json_row,'fparam');
					v_ffield        := hcm_util.get_string_t(param_json_row,'ffield');
					v_descript      := hcm_util.get_string_t(param_json_row,'descript');
					v_flgstd        := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
					v_flginput      := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
					v_flgdesc       := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
					v_flgdelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');
					if v_numseq is null then
            begin
              select nvl(max(numseq),0) + 1 into v_numseq
                from tfmparam
               where codform = p_codform
                 and section = 2;
            end;
          end if;
          if v_flgdelete = false then
						insert into tfmparam ( codform, section, numseq, codtable, fparam, 
                                   ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,coduser ) 
                 values ( p_codform, v_section, v_numseq, nvl(v_codtable,'NOTABLE'), v_fparam, 
                          v_ffield, v_descript, v_flgstd, v_flginput, v_flgdesc, sysdate, global_v_coduser, global_v_coduser );
					end if;
				end loop;
--			else
--				for i in 0..p_formbody1.get_size - 1 loop
--					v_count := 0;
--					param_json_row  := hcm_util.get_json_t(p_formbody1,to_char(i) );
--					v_section       := nvl(hcm_util.get_string_t(param_json_row,'section'),2);
--					v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
--					v_codtable      := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
--					v_fparam        := hcm_util.get_string_t(param_json_row,'fparam');
--					v_ffield        := hcm_util.get_string_t(param_json_row,'ffield');
--					v_descript      := hcm_util.get_string_t(param_json_row,'descript');
--					v_flgstd        := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
--					v_flginput      := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
--					v_flgdesc       := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
--					v_flgdelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');
--          if v_numseq is null then
--            begin
--              select nvl(max(numseq),0) + 1 into v_numseq
--                from tfmparam
--               where codform = p_codform
--                 and section = 2;
--            end;
--          end if;
--					select count(*) into v_count
--            from tfmparam
--					 where codform  = p_codform
--             and numseq   = v_numseq
--             and section  = 2
--             and codtable = v_codtable
--             and fparam   = v_fparam;
--
--					if v_count = 0 then
--            insert into tfmparam ( codform, section, numseq, codtable, fparam, 
--                                   ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,coduser ) 
--                 values ( p_codform,v_section,v_numseq,nvl(v_codtable,'NOTABLE'),v_fparam,
--                          v_ffield,v_descript,v_flgstd,v_flginput,v_flgdesc,sysdate,global_v_coduser, global_v_coduser);
--					else
--						if v_flgdelete = true then
--							delete tfmparam
--							 where codform = p_codform
--                 and numseq = v_numseq
--                 and section = 2
--                 and codtable = v_codtable
--                 and fparam   = v_fparam;
--						else
--							update tfmparam
--							set codtable  = nvl(v_codtable,'NOTABLE'),
--                  fparam    = v_fparam,
--                  ffield    = v_ffield,
--                  descript  = v_descript,
--                  flgstd    = v_flgstd,
--                  flginput  = v_flginput,
--                  flgdesc   = v_flgdesc,
--                  dteupd    = sysdate,
--                  coduser   = global_v_coduser
--							where codform = p_codform
--                and numseq  = v_numseq
--                and section = 2
--                and codtable = v_codtable
--                and fparam   = v_fparam;
--						end if;
--					end if;
--
--				end loop;
--			end if;
      begin
        select count(*) into v_count
          from tfmrefr3
         where codform = p_codform;
      end;
			if v_count = 0 then
				insert into tfmrefr3 ( codform, message, messagedsp, dtecreate, codcreate,coduser ) 
        values ( p_codform, p_message_clob3, p_message_display3_clob, sysdate, global_v_coduser, global_v_coduser );
			else
				update tfmrefr3
           set message    = p_message_clob3,
               messagedsp = p_message_display3_clob,
               dteupd     = sysdate,
               coduser    = global_v_coduser
				 where codform    = p_codform;
			end if;
			v_count := 0;
      if p_isCopy = 'Y' then
        begin
        delete tfmparam
         where codform = p_codform
           and section = 3;
        end;
      end if;
--      begin
--			select count(*) into v_count
--        from tfmparam
--			 where codform = p_codform
--         and section = 3;
--      end;
      begin
        delete tfmparam
         where codform = p_codform
           and section = 3;
      end;
			p_formfooter1 := hcm_util.get_json_t(p_formfooter,'rows');
--			if v_count = 0 then
				for i in 0..p_formfooter1.get_size - 1 loop
					param_json_row  := hcm_util.get_json_t(p_formfooter1,to_char(i) );
					v_section       := nvl(hcm_util.get_string_t(param_json_row,'section'),3);
					v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
					v_codtable      := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
					v_fparam        := hcm_util.get_string_t(param_json_row,'fparam');
					v_ffield        := hcm_util.get_string_t(param_json_row,'ffield');
					v_descript      := hcm_util.get_string_t(param_json_row,'descript');
					v_flgstd        := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
					v_flginput      := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
					v_flgdesc       := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
					v_flgdelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');

          if v_numseq is null then
            begin
              select nvl(max(numseq),0) + 1 into v_numseq
                from tfmparam
               where codform = p_codform
                 and section = 3;
            end;
          end if;
          if v_flgdelete = false then
						insert into tfmparam ( codform, section, numseq, codtable, fparam, 
                                   ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,coduser) 
                 values ( p_codform, v_section, v_numseq, nvl(v_codtable,'NOTABLE'), v_fparam,
                          v_ffield, v_descript, v_flgstd, v_flginput, v_flgdesc, sysdate, global_v_coduser, global_v_coduser );
					end if;
				end loop;
--			else
--				for i in 0..p_formfooter1.get_size - 1 loop
--					v_count := 0;
--					param_json_row  := hcm_util.get_json_t(p_formfooter1,to_char(i)  );
--					v_section       := nvl(hcm_util.get_string_t(param_json_row,'section'),3);
--					v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
--					v_codtable      := nvl(hcm_util.get_string_t(param_json_row,'codtable'),'NOTABLE');
--					v_fparam        := hcm_util.get_string_t(param_json_row,'fparam');
--					v_ffield        := hcm_util.get_string_t(param_json_row,'ffield');
--					v_descript      := hcm_util.get_string_t(param_json_row,'descript');
--					v_flgstd        := nvl(hcm_util.get_string_t(param_json_row,'flgstd'),'N');
--					v_flginput      := nvl(hcm_util.get_string_t(param_json_row,'flginput'),'Y');
--					v_flgdesc       := nvl(hcm_util.get_string_t(param_json_row,'flgdesc'),'N');
--					v_flgdelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');
--          
--          if v_numseq is null then
--            begin
--              select nvl(max(numseq),0) + 1 into v_numseq
--                from tfmparam
--               where codform = p_codform
--                 and section = 3;
--            end;
--          end if;
--					select count(*) into v_count
--            from tfmparam
--					 where codform  = p_codform
--             and numseq   = v_numseq
--             and section  = 3
--             and codtable = v_codtable
--             and fparam   = v_fparam;
--					if v_count = 0 then
--            insert into tfmparam ( codform, section, numseq, codtable, fparam, 
--                                   ffield, descript, flgstd, flginput, flgdesc, dtecreate, codcreate,coduser) 
--                 values ( p_codform, v_section, v_numseq, nvl(v_codtable,'NOTABLE'), v_fparam, 
--                          v_ffield, v_descript, v_flgstd, v_flginput, v_flgdesc, sysdate, global_v_coduser, global_v_coduser );
--					else
--						if v_flgdelete = true then
--							delete tfmparam
--							 where codform  = p_codform
--                 and numseq   = v_numseq
--                 and section  = 3
--                 and codtable = v_codtable
--                 and fparam   = v_fparam;
--						else
--							update tfmparam
--                 set codtable   = nvl(v_codtable,'NOTABLE'),
--                     fparam     = v_fparam,
--                     ffield     = v_ffield,
--                     descript   = v_descript,
--                     flgstd     = v_flgstd,
--                     flginput   = v_flginput,
--                     flgdesc    = v_flgdesc,
--                     dteupd     = sysdate,
--                     coduser    = global_v_coduser
--							 where codform  = p_codform
--                 and numseq   = v_numseq
--                 and section  = 3
--                 and codtable = v_codtable
--                 and fparam   = v_fparam;
--						end if;
--					end if;
--				end loop;
--			end if;
		end if;

		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
			commit;
		else
			rollback;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
    rollback;
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure delete_index (json_str_input in clob, json_str_output out clob) is
		param_json_row		json_object_t;
		v_count			      number;
		v_codform		      varchar2(100);
	begin
		initial_value(json_str_input);
		p_formheader := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str') );
		for i in 0..p_formheader.get_size - 1 loop
			v_count         := 0;
			param_json_row  := hcm_util.get_json_t(p_formheader,to_char(i) );
			v_codform       := hcm_util.get_string_t(param_json_row,'codform');
			begin
				delete from tfmrefr where codform = v_codform;
				delete from tfmrefr2 where codform = v_codform;
				delete from tfmrefr3 where codform = v_codform;
				delete from tfmparam where codform = v_codform;
			exception when others then
				rollback;
			end;

		end loop;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2425',global_v_lang);
			commit;
		else
			rollback;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception
	when others then
		param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_tcoldesc ( json_str_input in clob, json_str_output out clob ) is

		cursor t_coldesc is 
      select codtable, codcolmn, descole, descolt, descol3, descol4, descol5, funcdesc, flgchksal
        from tcoldesc
       where codtable = p_codtable
    order by column_id;

		v_desc_codcolmn		varchar2(1000);
		v_codcolmn		    varchar2(1000);
		v_row			        number;
	begin
		initial_value(json_str_input);
		obj_row			:= json_object_t();
		v_row := 0;
		for i in t_coldesc loop
			v_row       := v_row + 1;
			v_codcolmn  := i.codcolmn;
			if global_v_lang = '101' then
				v_desc_codcolmn := i.descole;
			elsif global_v_lang = '102' then
				v_desc_codcolmn := i.descolt;
			elsif global_v_lang = '103' then
				v_desc_codcolmn := i.descol3;
			elsif global_v_lang = '104' then
				v_desc_codcolmn := i.descol4;
			elsif global_v_lang = '105' then
				v_desc_codcolmn := i.descol5;
			end if;

			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('codtable',i.codtable);
			obj_data.put('funcdesc',i.funcdesc);
			obj_data.put('flgchksal',i.flgchksal);
			obj_data.put('funcdesc',i.funcdesc);
			obj_data.put('codcolmn',v_codcolmn);
			obj_data.put('desc_codcolmn',v_desc_codcolmn);
			obj_row.put(to_char(v_row - 1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	exception
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure list_codtable_typfm ( json_str_input in clob, json_str_output out clob ) is

		cursor c_ttatabdesc is 
      select b.codtable, 
             decode(global_v_lang,'101',b.destabe,
                                  '102',b.destabt,
                                  '103',b.destab3,
                                  '104',b.destab4,
                                  '105',b.destab5) as desc_codtable
      from tfmtable a
      inner join ttabdesc b on a.codtable = b.codtable
      where a.codapp = p_typfm;

		rec_c1      c_ttatabdesc%rowtype;
		v_seq			  number;
		v_desc			varchar2(500);
		v_values		varchar2(500);
	begin
		initial_value(json_str_input);
    if p_typfm is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_typfm');
			return;
		end if;
		v_seq       := 0;
		obj_row			:= json_object_t();
		open c_ttatabdesc;
		loop
			fetch c_ttatabdesc into rec_c1;
			exit when c_ttatabdesc%notfound;
			v_seq := v_seq + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('p_codtable',rec_c1.codtable);
			obj_data.put('p_desc_codtable',rec_c1.desc_codtable);
			obj_row.put(to_char(v_seq - 1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	end;

	procedure list_codtable_detail ( json_str_input in clob, json_str_output out clob ) is
		cursor c_ttatabdesc is 
      select codtable, decode(global_v_lang,'101',destabe,
                                            '102',destabt,
                                            '103',destab3,
                                            '104',destab4,
                                            '105',destab5) as desc_codtable
      from ttabdesc;

		rec_c1      c_ttatabdesc%rowtype;
		v_seq			  number;
		v_desc			varchar2(500);
		v_values		varchar2(500);
	begin
		v_seq := 0;
		obj_row			:= json_object_t();
		open c_ttatabdesc;
		commit;
		loop
			fetch c_ttatabdesc into rec_c1;
			exit when c_ttatabdesc%notfound;
			v_seq := v_seq + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('p_codtable',rec_c1.codtable);
			obj_data.put('p_desc_codtable',rec_c1.desc_codtable);
			obj_row.put(to_char(v_seq - 1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	end;

	procedure list_codform ( json_str_input in clob, json_str_output out clob ) is
		cursor c_tfmrefr is 
      select codform,get_tfmrefr_name (codform ,global_v_lang) as namfm, namfile,typfm
      from tfmrefr
      order by codform;

		rec_c1      c_tfmrefr%rowtype;
		v_seq			  number;
		v_desc			varchar2(500);
		v_values		varchar2(500);
	begin
		v_seq := 0;
		initial_value(json_str_input);
		obj_row			:= json_object_t();
		open c_tfmrefr;
		loop
			fetch c_tfmrefr into rec_c1;
			exit when c_tfmrefr%notfound;
			v_seq := v_seq + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('codform',rec_c1.codform);
			obj_data.put('namfm',rec_c1.namfm);
			obj_data.put('namfile',rec_c1.namfile);
			obj_data.put('typfm',rec_c1.typfm);
			obj_data.put('desc_typfm',get_tlistval_name('TYPFM',rec_c1.typfm,global_v_lang));
			obj_row.put(to_char(v_seq - 1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	end;

	PROCEDURE copy_codform ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		param_json		json_object_t;
		param_json_row		json_object_t;
		CURSOR c_tfmparam_header IS 
      SELECT numseq, codtable, fparam, ffield, descript, flgstd, flginput, flgdesc
        FROM tfmparam
       WHERE codform = p_codform
         AND section = 1
    ORDER BY flgstd DESC, numseq;

		CURSOR c_tfmparam_body IS 
      SELECT numseq, codtable, fparam, ffield, descript, flgstd, flginput, flgdesc
        FROM tfmparam
       WHERE codform = p_codform
         AND section = 2
    ORDER BY flgstd DESC, numseq;

    CURSOR c_tfmparam_footer IS 
      SELECT numseq, codtable, fparam, ffield, descript, flgstd, flginput, flgdesc
        FROM tfmparam
       WHERE codform = p_codform
         AND section = 3
    ORDER BY flgstd DESC, numseq;

		v_codform		  VARCHAR2(15);
		v_where			  VARCHAR2(500);
		v_typfm			  VARCHAR2(30);
		v_message1		VARCHAR2(100);
		v_message2		VARCHAR2(100);
		v_message3		VARCHAR2(100);
		v_typemsg1		VARCHAR2(40);
		v_typemsg2		VARCHAR2(40);
		v_typemsg3		VARCHAR2(40);
		v_row			    NUMBER;
	BEGIN
		initial_value(json_str_input);
		BEGIN
			SELECT codform, typfm
        INTO v_codform, v_typfm
        FROM tfmrefr
			 WHERE codform = p_codform;
		EXCEPTION WHEN no_data_found THEN
			v_codform := NULL;
		END;

		v_row := 0;
		obj_row_header		:= json_object_t();
		BEGIN
			DELETE tfmparam
			 WHERE codform = p_codform_to
         AND section = 1;
		EXCEPTION WHEN OTHERS THEN
			NULL;
		END;

		FOR r1 IN c_tfmparam_header LOOP
			v_row := v_row + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('codform',p_codform_to);
			obj_data.put('numseq',r1.numseq);
			obj_data.put('codtable',r1.codtable);
			obj_data.put('fparam',r1.fparam);
			obj_data.put('ffield',r1.ffield);
			obj_data.put('descript',r1.descript);
			obj_data.put('flgstd',r1.flgstd);
			obj_data.put('flginput',nvl(r1.flginput,'N'));
			IF r1.flgstd = 'Y' THEN
				obj_data.put('v_flgstd','*');
			END IF;
			IF nvl(r1.flginput,'N') = 'Y' THEN
				obj_data.put('v_ffield','Input From Screen');
			ELSE
				IF r1.flgstd <> 'Y' THEN
					obj_data.put('v_ffield',r1.codtable || '.' || r1.ffield);
				ELSE
					obj_data.put('v_ffield',r1.ffield);
				END IF;
			END IF;
			obj_data.put('flgdesc',r1.flgdesc);
			obj_row_header.put(TO_CHAR(v_row - 1),obj_data);
		END LOOP;

		v_row := 0;
		obj_row_body		:= json_object_t();
		BEGIN
			DELETE tfmparam
			 WHERE codform = p_codform_to
         AND section = 1;
		EXCEPTION WHEN OTHERS THEN
			NULL;
		END;

		FOR r1 IN c_tfmparam_body LOOP
			v_row := v_row + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('codform',p_codform_to);
			obj_data.put('numseq',r1.numseq);
			obj_data.put('codtable',r1.codtable);
			obj_data.put('fparam',r1.fparam);
			obj_data.put('ffield',r1.ffield);
			obj_data.put('descript',r1.descript);
			obj_data.put('flgstd',r1.flgstd);
			obj_data.put('flginput',r1.flginput);
			IF r1.flgstd = 'Y' THEN
				obj_data.put('v_flgstd','*');
			END IF;
			IF nvl(r1.flginput,'N') = 'Y' THEN
				obj_data.put('v_ffield','Input From Screen');
			ELSE
				IF r1.flgstd <> 'Y' THEN
					obj_data.put('v_ffield',r1.codtable || '.' || r1.ffield);
				ELSE
					obj_data.put('v_ffield',r1.ffield);
				END IF;
			END IF;
			obj_data.put('flgdesc',r1.flgdesc);
			obj_row_body.put(TO_CHAR(v_row - 1),obj_data);
		END LOOP;

		v_row := 0;
		obj_row_footer		:= json_object_t();
		BEGIN
			DELETE tfmparam
			 WHERE codform = p_codform_to
         AND section = 3;
		EXCEPTION WHEN OTHERS THEN
			NULL;
		END;

		FOR r1 IN c_tfmparam_footer LOOP
			v_row := v_row + 1;
			obj_data		:= json_object_t();
			obj_data.put('coderror','200');
			obj_data.put('numseq',r1.numseq);
			obj_data.put('codform',p_codform_to);
			obj_data.put('codtable',r1.codtable);
			obj_data.put('fparam',r1.fparam);
			obj_data.put('ffield',r1.ffield);
			obj_data.put('descript',r1.descript);
			obj_data.put('flgstd',r1.flgstd);
			obj_data.put('flginput',r1.flginput);
			IF r1.flgstd = 'Y' THEN
				obj_data.put('v_flgstd','*');
			END IF;
			IF nvl(r1.flginput,'N') = 'Y' THEN
				obj_data.put('v_ffield','Input From Screen');
			ELSE
				IF r1.flgstd <> 'Y' THEN
					obj_data.put('v_ffield',r1.codtable || '.' || r1.ffield);
				ELSE
					obj_data.put('v_ffield',r1.ffield);
				END IF;
			END IF;
			obj_data.put('flgdesc',r1.flgdesc);
			obj_row_footer.put(TO_CHAR(v_row - 1),obj_data);
		END LOOP;

		BEGIN
			SELECT message
        INTO v_message1
        FROM tfmrefr
			 WHERE codform = v_codform;
		EXCEPTION WHEN no_data_found THEN
			v_message1 := NULL;
		END;

		BEGIN
			SELECT message, typemsg
        INTO v_message2, v_typemsg2
        FROM tfmrefr2
			 WHERE codform = v_codform;
		EXCEPTION WHEN no_data_found THEN
			v_message2 := NULL;
		END;

		BEGIN
			SELECT message, NULL
        INTO v_message3, v_typemsg3
        FROM tfmrefr3
			 WHERE codform = v_codform;
		EXCEPTION WHEN no_data_found THEN
			v_message3 := NULL;
		END;

		obj_row			:= json_object_t();
		obj_row.put('header',obj_row_header);
		obj_row.put('body',obj_row_body);
		obj_row.put('footer',obj_row_footer);
		obj_row.put('v_message1',v_message1);
		obj_row.put('v_message2',v_message2);
		obj_row.put('v_message3',v_message3);
		obj_row.put('v_typemsg2',v_typemsg2);
		obj_row.put('v_typemsg3',v_typemsg3);
		json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END;
	FUNCTION get_tfmrefr_name ( p_codform	IN tfmrefr.codform%TYPE, p_codlang IN tfmrefr.codlang%TYPE )RETURN VARCHAR2 IS
		v_form_name		tfmrefr.namfme%TYPE;
	BEGIN
		IF p_codform IS NOT NULL THEN
			IF p_codlang = '101' THEN
				BEGIN
					SELECT namfme
            INTO v_form_name
            FROM tfmrefr
					 WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			ELSIF p_codlang = '102' THEN
				BEGIN
					SELECT namfmt
            INTO v_form_name
            FROM tfmrefr
					 WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			ELSIF p_codlang = '103' THEN
				BEGIN
					SELECT namfm3
            INTO v_form_name
            FROM tfmrefr
					 WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			ELSIF p_codlang = '104' THEN
				BEGIN
					SELECT namfm4
            INTO v_form_name
            FROM tfmrefr
					 WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			ELSIF p_codlang = '105' THEN
				BEGIN
					SELECT namfm5
            INTO v_form_name
            FROM tfmrefr
					 WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			ELSE
				BEGIN
					SELECT namfme
            INTO v_form_name
					FROM tfmrefr
					WHERE upper(codform) = upper(TRIM(p_codform) );
				END;
			END IF;
		ELSE
			v_form_name := ' ';
		END IF;
		return(v_form_name);
	EXCEPTION WHEN no_data_found THEN
		return('***************');
	END get_tfmrefr_name;

  procedure get_error_labels(json_str_input in clob,json_str_output out clob) as
    v_descripe          terrorm.descripe%type;
    v_descript          terrorm.descript%type;
    v_descrip3          terrorm.descrip3%type;
    v_descrip4          terrorm.descrip4%type;
    v_descrip5          terrorm.descrip5%type;
    v_errorno           terrorm.errorno%type;
    v_objrow            json := json();
    v_objitem_descripe  json := json();
    v_objitem_descript  json := json();
    v_objitem_descrip3  json := json();
    v_objitem_descrip4  json := json();
    v_objitem_descrip5  json := json();
    errorlabel_refcur   sys_refcursor;
    v_objrow_p_codapp   json := json();
    v_objrow_where_p_codapp json := json();

    v_objrow_input json;
    begin
      v_objrow_input    := json (json_str_input);
      v_objrow_p_codapp := json(hcm_util.get_string(v_objrow_input,'p_codapp'));

      for i in 1..v_objrow_p_codapp.count loop
        if ( hcm_util.get_string(v_objrow_where_p_codapp,'wherep_codapp') is not null ) then
            v_objrow_where_p_codapp.put('wherep_codapp', hcm_util.get_string(v_objrow_where_p_codapp,'wherep_codapp')|| ',' || ''''|| v_objrow_p_codapp.get(i).get_string()||'''' );
        else
            v_objrow_where_p_codapp.put('wherep_codapp', ''''|| v_objrow_p_codapp.get(i).get_string()  ||'''');
        end if ;
      end loop;

      begin
        open errorlabel_refcur for 'select descripe, descript,descrip3,
                                   descrip4, descrip5,errorno
                                   from terrorm
                                   where errorno in ('|| hcm_util.get_string(v_objrow_where_p_codapp,'wherep_codapp') || ')' ;
                  loop
        fetch errorlabel_refcur into v_descripe, v_descript,v_descrip3,
                                                v_descrip4,v_descrip5,v_errorno;
        exit when errorlabel_refcur%notfound;

        v_objitem_descripe.put(to_char(v_errorno),v_descripe);
        v_objitem_descript.put(to_char(v_errorno),v_descript);
        v_objitem_descrip3.put(to_char(v_errorno),v_descrip3);
        v_objitem_descrip4.put(to_char(v_errorno),v_descrip4);
        v_objitem_descrip5.put(to_char(v_errorno),v_descrip5);

        end loop;
        close errorlabel_refcur;

        v_objrow.put('objLang1',v_objitem_descripe);
        v_objrow.put('objLang2',v_objitem_descript);
        v_objrow.put('objLang3',v_objitem_descrip3);
        v_objrow.put('objLang4',v_objitem_descrip4);
        v_objrow.put('objLang5',v_objitem_descrip5);
        v_objrow.put('coderror','200');
        v_objrow.put('response','');

        dbms_lob.createtemporary(json_str_output,true);
        v_objrow.to_clob(json_str_output);
--        json_str_output :=  v_objrow.to_clob;
      end;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_error_labels;

  function get_clob(str_json in clob,key_json in varchar2) RETURN CLOB is
    jo JSON_OBJECT_T;
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

  procedure get_popup_detail ( json_str_input in clob, json_str_output out clob ) is

    cursor t_coldesc is 
      select codtable, codcolmn, descole, descolt, descol3, descol4, descol5, funcdesc, flgchksal
        from tcoldesc
       where codtable = p_codtable
    order by column_id;

		v_desc_codcolmn		varchar2(1000);
		v_codcolmn		    varchar2(1000);
		v_row			        number;
	begin
		initial_value(json_str_input);
		obj_row			:= json_object_t ();
		v_row := 0;
		for i in t_coldesc loop
			v_row       := v_row + 1;
			v_codcolmn  := i.codcolmn;
			if global_v_lang = '101' then
				v_desc_codcolmn := i.descole;
			elsif global_v_lang = '102' then
				v_desc_codcolmn := i.descolt;
			elsif global_v_lang = '103' then
				v_desc_codcolmn := i.descol3;
			elsif global_v_lang = '104' then
				v_desc_codcolmn := i.descol4;
			elsif global_v_lang = '105' then
				v_desc_codcolmn := i.descol5;
			end if;

			obj_data		:= json_object_t ();
			obj_data.put('coderror','200');
			obj_data.put('codtable',i.codtable);
			obj_data.put('funcdesc',i.funcdesc);
			obj_data.put('flgchksal',i.flgchksal);
			obj_data.put('funcdesc',i.funcdesc);
			obj_data.put('codcolmn',v_codcolmn);
			obj_data.put('desc_codcolmn',v_desc_codcolmn);
			obj_row.put(to_char(v_row - 1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

  procedure get_list_typfm (json_str_output out clob) as
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

  procedure get_list_typfm (json_str_input in clob, json_str_output out clob) is
        json_obj        json_object_t;
        v_rcnt          number;
        obj_row         json_object_t;
        obj_data        json_object_t;
        v_codlang        varchar2(5 char);
        cursor t_tlistval is
          select codlang, desc_label,numseq,list_value
            from tlistval
           where codapp = 'TYPFM'
             and list_value like p_codapp||'%'
             and numseq > 0
--             and codlang = global_v_lang
          order by codapp,codlang,numseq;

    begin
        initial_value(json_str_input);
        obj_row := json_object_t();
        v_rcnt := 0;
        for r1 in t_tlistval loop
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('label', r1.desc_label);
            obj_data.put('value',  r1.list_value);
            if r1.codlang = '101' then
                v_codlang := 'en';
            elsif r1.codlang = '102' then
                v_codlang := 'th';
            else
                v_codlang := r1.codlang;
            end if;
            obj_data.put('codlang',  v_codlang);
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt := v_rcnt + 1;
        end loop;


        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_list_typfm;
END hrpmb9e;

/
