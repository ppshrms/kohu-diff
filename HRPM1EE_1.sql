--------------------------------------------------------
--  DDL for Package Body HRPM1EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM1EE" IS
  PROCEDURE initial_value (json_str IN CLOB) IS
		json_obj		json_object_t;
	BEGIN
		json_obj          := json_object_t(json_str);

		-- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

		p_typasset        := hcm_util.get_string_t(json_obj, 'p_typasset');
		p_codasset        := hcm_util.get_string_t(json_obj, 'p_codasset');
		p_flgasset        := hcm_util.get_string_t(json_obj, 'p_flgasset');

		p_source          := hcm_util.get_string_t(json_obj, 'source');
		p_status          := hcm_util.get_string_t(json_obj, 'status');
		p_details         := hcm_util.get_string_t(json_obj, 'details');
		p_filename        := hcm_util.get_string_t(json_obj, 'filename');

--		p_dateimport      := To_date(hcm_util.Get_string(json_obj, 'dateimport'),'dd/mm/yyyy');
--		p_idp             := hcm_util.Get_string(json_obj, 'idp');
--		p_flag            := hcm_util.Get_string(json_obj, 'flag');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	END initial_value;

	procedure gen_index (json_str_output out clob) is
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		v_rcnt			    number;
		v_tasetinf		  number;
		v_countrow		  number;
		v_dtercass		  tassets.dtercass%type;
		v_codempid		  tassets.codempid%type;
		colum_nameasset varchar(10);

		cursor query_ is
      select codcreate,codasset,typasset,namimage,
             dterec,srcasset,staasset,dtecreate,
             decode(global_v_lang,'101',desassee
                                 ,'102',desasset
                                 ,'103',desasse3
                                 ,'104',desasse4
                                 ,'105',desasse5) as nameasset
      from tasetinf
      where typasset = nvl(p_typasset,typasset)
      and nvl(flgasset,'!@#') = nvl(p_flgasset,nvl(flgasset,'!@#'))
      order by codasset;
	begin
		obj_row := json_object_t();
		v_rcnt := 0;

		for i in query_ loop
			begin
				select dtercass,codempid
				  into v_dtercass, v_codempid
				  from tassets
				 where codasset = i.codasset
           and dteupd = (select max(dteupd) from tassets
				                 where codasset = i.codasset)
          and rownum = 1
      order by dteupd DESC;
			exception when no_data_found then
				v_countrow := null;
				v_dtercass := null;
				v_codempid := null;
			end;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', i.namimage);
      obj_data.put('nameasset', i.nameasset);
      obj_data.put('codasset', i.codasset);
      obj_data.put('typasset', get_tcodec_name('tcodasst', i.typasset, global_v_lang));
      obj_data.put('dterec', to_char(i.dterec, 'dd/mm/yyyy'));
      obj_data.put('srcasset', i.srcasset);
      if i.staasset = '1' then
        obj_data.put('staasset', get_tlistval_name('STAASSET', i.staasset, global_v_lang));
        obj_data.put('dtecreate', '');
        obj_data.put('codcreate', '');
      else
        obj_data.put('staasset', get_tlistval_name('STAASSET', i.staasset, global_v_lang));
        obj_data.put('dtecreate', to_char(v_dtercass, 'dd/mm/yyyy'));
        obj_data.put('codcreate', get_temploy_name(v_codempid, global_v_lang));
      end if;
      obj_row.put(to_char(v_rcnt), obj_data);

      v_rcnt := v_rcnt + 1;
		end loop;

		json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_index;

	PROCEDURE get_index (json_str_input IN CLOB,json_str_output OUT CLOB) IS
		v_tasetinf		NUMBER;
	BEGIN
		initial_value(json_str_input);
    gen_index(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END get_index;

  PROCEDURE gen_detail (json_str_output OUT CLOB) IS
		v_rcnt			        NUMBER;
		obj_row			        json_object_t;
		obj_data		        json_object_t;
		obj_data_groupname	json_object_t;
		flg_data		        BOOLEAN := FALSE;
		v_countrow		      NUMBER;
		v_dtercass		      tassets.dtercass%TYPE;
		v_codempid		      tassets.codempid%TYPE;

		cursor query_ is
      select codasset,codcreate,coduser,comimage,desasse3,desasse4,desasse5,flgasset,
             desassee,desasset,desnote,dtecreate,dterec,dteupd,namimage,srcasset,staasset,typasset,
             codrespon,codrespon2,
             decode(global_v_lang,'101',desassee
                                 ,'102',desasset
                                 ,'103',desasse3
                                 ,'104',desasse4
                                 ,'105',desasse5) as nameasset
        from tasetinf
       where codasset = p_codasset;

	BEGIN
		obj_row := json_object_t();

		v_rcnt := 0;
		FOR i IN query_ LOOP
			BEGIN
				SELECT Count(*) countRow,dtercass,codempid
				  INTO v_countrow, v_dtercass, v_codempid
				  FROM tassets
				 WHERE codasset = p_codasset
           and rownum   = 1
      GROUP BY dtercass,codempid;
			EXCEPTION
			WHEN no_data_found THEN
				v_countrow := NULL;
				v_dtercass := NULL;
				v_codempid := NULL;
			END;
      obj_data := json_object_t();

			obj_data.Put('coderror', '200');
			obj_data.Put('codasset', i.codasset);
			obj_data.Put('source', i.srcasset);
			obj_data.put('nameasset', i.nameasset);
			obj_data.put('nameassete', i.desassee);
			obj_data.put('nameassett', i.desasset);
			obj_data.put('nameasset3', i.desasse3);
			obj_data.put('nameasset4', i.desasse4);
			obj_data.put('nameasset5', i.desasse5);
			obj_data.Put('typasset', i.typasset);
			obj_data.Put('flgasset', i.flgasset);
			obj_data.Put('codrespon', i.codrespon);
			obj_data.Put('codrespon2', i.codrespon2);
			obj_data.Put('dterec', To_char(i.dterec, 'dd/mm/yyyy'));
      obj_data.Put('status', i.staasset);
			obj_data.Put('codempid', v_codempid);
			obj_data.Put('dtercass', To_char(v_dtercass, 'dd/mm/yyyy'));
			obj_data.Put('details', i.desnote);
			obj_data.Put('filename', i.namimage);
			flg_data := TRUE;
			obj_data.Put('new', 'update');

			v_rcnt := v_rcnt + 1;

			obj_row.Put(To_char(v_rcnt), obj_data);
		END LOOP;
		IF NOT flg_data THEN
			obj_data := json_object_t();

			obj_row := json_object_t();
			v_rcnt := 1;
			obj_data.Put('codasset', p_codasset);
			obj_data.Put('typasset', p_typasset);
			obj_data.Put('new', 'insert');
			obj_data.Put('status', 1);
			obj_row.Put(To_char(v_rcnt), obj_data);
		END IF;

		json_str_output := obj_row.To_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_detail;

	PROCEDURE get_detail (json_str_input IN CLOB,json_str_output OUT CLOB) IS
		json_obj		json_object_t;
	BEGIN
		initial_value(json_str_input);
		gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END get_detail;

	PROCEDURE save_index (json_str_input IN CLOB,json_str_output OUT CLOB) IS
		param_json			json_object_t;
    param_json_row  json_object_t;
    v_codasset      tasetinf.codasset%type;
    v_staasset       tasetinf.staasset%type := '1';
    v_chkstat       boolean := false;
	BEGIN

    initial_value(json_str_input);
    param_json := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'param_json'));
    for i in 0..param_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codasset        := hcm_util.get_string_t(param_json_row,'codasset');
      begin
				select staasset into v_staasset from tasetinf
				where codasset = v_codasset;
			end;
      if v_staasset = '2' then
        v_chkstat := true;
        exit;
      end if;
    end loop;
    if v_chkstat then
      param_msg_error := get_error_msg_php('PM0109',global_v_lang);
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      return ;
    end if;
    for i in 0..param_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codasset        := hcm_util.get_string_t(param_json_row,'codasset');
      begin
				delete from tasetinf
				where codasset = v_codasset;
			end;
    end loop;
		param_msg_error := Get_error_msg_php('HR2401', global_v_lang);
		json_str_output := Get_response_message(NULL, param_msg_error,global_v_lang);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END save_index;

  PROCEDURE save_detail (json_str_input IN CLOB,json_str_output OUT CLOB)IS
    param_json		      json_object_t;

    colum_nameasset     varchar(10);
    v_chkExist          varchar(10);
    sqlinsert           varchar(500);
    sqlupdate           varchar(700);
    obj_data_obj        varchar(1000);
    flg_data		        boolean := false;
    v_rcnt			        number;
    v_countrow		      number;

    v_codasset		      tasetinf.codasset%type;
    v_namimage		      tasetinf.namimage%type;
    v_nameassete		    tasetinf.desassee%type;
    v_nameassett		    tasetinf.desasset%type;
    v_nameasset3		    tasetinf.desasse3%type;
    v_nameasset4		    tasetinf.desasse4%type;
    v_nameasset5		    tasetinf.desasse5%type;
    v_dterec		        tasetinf.dterec%type;
    v_desnote		        tasetinf.desnote%type;
    v_srcasset		      tasetinf.srcasset%type;
    v_typasset		      tasetinf.typasset%type;
    v_staasset		      tasetinf.staasset%type;
    v_codempid		      tassets.codempid%type;
    v_dtercass		      tassets.dtercass%type;
    v_flgasset 		      tasetinf.flgasset%type;
    v_codrespon 		    tasetinf.codrespon%type;
    v_codrespon2		    tasetinf.codrespon2%type;

  BEGIN
    initial_value(json_str_input);
    param_json := json_object_t(json_str_input);

    v_codasset 				:= hcm_util.Get_string_t(param_json, 'codasset');
    v_namimage		    := hcm_util.Get_string_t(param_json, 'filename');
    v_nameassete		  := hcm_util.Get_string_t(param_json, 'nameassete');
    v_nameassett		  := hcm_util.Get_string_t(param_json, 'nameassett');
    v_nameasset3		  := hcm_util.Get_string_t(param_json, 'nameasset3');
    v_nameasset4		  := hcm_util.Get_string_t(param_json, 'nameasset4');
    v_nameasset5		  := hcm_util.Get_string_t(param_json, 'nameasset5');
    v_dterec		      := To_date(hcm_util.Get_string_t(param_json, 'dterec'),'dd/mm/yyyy');
    v_desnote		      := hcm_util.Get_string_t(param_json, 'details');
    v_srcasset		    := hcm_util.Get_string_t(param_json, 'source');
    v_typasset		    := hcm_util.Get_string_t(param_json, 'typasset');
    v_staasset		    := hcm_util.Get_string_t(param_json, 'staasset');
    v_flgasset		    := hcm_util.Get_string_t(param_json, 'flgasset');
    v_codempid		    := hcm_util.Get_string_t(param_json, 'codempid');
    v_codrespon 		  := hcm_util.Get_string_t(param_json, 'codrespon');
    v_codrespon2		  := hcm_util.Get_string_t(param_json, 'codrespon2');
    v_dtercass		    := To_date(hcm_util.Get_string_t(param_json, 'dtercass'),'dd/mm/yyyy');
    
    if v_dterec > sysdate then
      param_msg_error := get_error_msg_php('PM0012',global_v_lang);
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      return ;
    end if;
    if v_dterec is null or v_desnote is null or v_typasset is null or 
       v_staasset is null or v_flgasset is null then
      param_msg_error := 'A'||get_error_msg_php('HR2045',global_v_lang);
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      return ;
    end if;
    if v_flgasset = 2 and v_codrespon2 is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      return ;
    elsif v_flgasset = 2 then
      if v_codrespon = v_codrespon2 then
        param_msg_error := get_error_msg_php('PM0130',global_v_lang);
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
        return ;
      end if;
      begin
        select 'x' into v_chkExist
        from temploy1
        where codempid = v_codrespon
        and staemp not in (0,9);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TEMPLOY1');
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
        return ;
      end;
       begin
        select 'x' into v_chkExist
        from temploy1
        where codempid = v_codrespon2
        and staemp not in (0,9);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TEMPLOY1');
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
        return ;
      end;
    end if;
    begin
       select 'x'
       into v_chkExist
       from TCODASST
       where CODCODEC = v_typasset;
     exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TCODASST');
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      return ;
    end;
    begin
      insert into tasetinf(CODASSET, TYPASSET, NAMIMAGE,
                           DESASSEE, DESASSET, DESASSE3, DESASSE4, DESASSE5,
                           DTEREC, DESNOTE, SRCASSET, STAASSET,
                           CODRESPON,CODRESPON2,FLGASSET,
                           CODCREATE, CODUSER)
                    values(v_codasset,v_typasset,v_namimage,
                           v_nameassete,v_nameassett,v_nameasset3,v_nameasset4,v_nameasset5,
                           v_dterec,v_desnote,v_srcasset,v_staasset,
                           v_codrespon, v_codrespon2,v_flgasset,
                           global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tasetinf
         set DESASSEE   = v_nameassete,
             DESASSET   = v_nameassett,
             DESASSE3   = v_nameasset3,
             DESASSE4   = v_nameasset4,
             DESASSE5   = v_nameasset5,
             NAMIMAGE   = v_namimage,
             DTEREC     = v_dterec,
             DESNOTE    = v_desnote,
             SRCASSET   = v_srcasset,
             STAASSET   = v_staasset,
             typasset   = v_typasset,
             CODRESPON  = v_codrespon,
             CODRESPON2 = v_codrespon2,
             FLGASSET   = v_flgasset,
             coduser    = global_v_coduser,
             dteupd = sysdate
          where CODASSET = v_codasset;
    end;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return ;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END save_detail;
  --
  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json          json_object_t;
    param_data          json_object_t;
    param_column        json_object_t;
    param_column_row    json_object_t;
    param_json_row      json_object_t;
    json_obj_list       json_list;
    --
    data_file           varchar2(6000);
    v_column            number := 10;
    v_error             boolean;
    v_err_code          varchar2(1000);
    v_err_filed         varchar2(1000);
    v_err_table         varchar2(20);
    i                   number;
    j                   number;
    k                   number;
    v_numseq            number := 0;

    v_code              varchar2(100);
    v_flgsecu           boolean;
    v_cnt               number := 0;
    v_dteleave          date;
    v_coderr            varchar2(4000 char);
    v_num               number := 0;

    type text is table of varchar2(4000) index by binary_integer;
    v_text              text;
    v_filed             text;

    v_chk_compskil      TCOMPSKIL.CODTENCY%TYPE;
    v_chk_exist         number :=0;

    v_chk_codasset		 number :=0;
    v_chk_desassee		varchar2(100 char);
    v_chk_desasset		varchar2(100 char);
    v_chk_dterec		  varchar2(100 char);
    v_chk_desnote		  varchar2(100 char);
    v_chk_srcasset		varchar2(100 char);
    v_chk_typasset		varchar2(100 char);

    v_codasset		tasetinf.codasset%type;
    v_desassee		tasetinf.desassee%type;
    v_desasset		tasetinf.desasset%type;
    v_desasse3		tasetinf.desasse3%type;
    v_desasse4		tasetinf.desasse4%type;
    v_desasse5		tasetinf.desasse5%type;
    v_desnote		  tasetinf.desnote%type;
    v_srcasset		tasetinf.srcasset%type;
    v_typasset		tasetinf.typasset%type;
    v_dterec		  varchar2(100 char);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');

    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    for r1 in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;

        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,'codasset');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'desassee');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'desasset');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'desasse3');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'desasse4');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'desasse5');
          v_text(7)   := hcm_util.get_string_t(param_json_row, 'dterec');
          v_text(8)   := hcm_util.get_string_t(param_json_row,'desnote');
          v_text(9)   := hcm_util.get_string_t(param_json_row,'srcasset');
          v_text(10)  := hcm_util.get_string_t(param_json_row,'typasset');

          data_file := null;
          for i in 1..10 loop
              data_file := v_text(1)||', '||v_text(2)||', '||v_text(3)||', '||v_text(4)||', '||v_text(5)||', '||v_text(6)||', '||v_text(7)||', '||v_text(8)||', '||v_text(9)||', '||v_text(10);
              if i not in (4,5,6) then
                if v_text(i) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(i);
                  v_err_table := 'TASETINF';
                  exit cal_loop;
                end if;
              end if;
          end loop;
         -- 1.codasset
           i := 1;
           if length(v_text(i)) < 4 then
             v_error     := true;
             v_err_code  := 'HR2020';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           if length(v_text(i)) > 15 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           v_codasset := upper(v_text(i));

          -- 2.desassee
           i := 2;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desassee := v_text(i);
           -- 3.desasset
           i := 3;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desasset := v_text(i);
           -- 4.desasse3
           i := 4;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desasse3 := v_text(i);
          -- 5.desasse4
           i := 5;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desasse4 := v_text(i);
          -- 6.desasse5
           i := 6;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desasse5 := v_text(i);
          -- 7.dterec
           i := 7;
           if v_text(i) is not null then
             if to_date(v_text(i),'dd/mm/yyyy') > sysdate then
               v_error     := true;
               v_err_code  := 'PM0012';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_dterec := v_text(i);
           -- 8.desnote
           i := 8;
           if v_text(i) is not null then
             if length(v_text(i)) > 500 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_desnote := v_text(i);
           -- 9.srcasset
           i := 9;
           if v_text(i) is not null then
             if length(v_text(i)) > 500 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_srcasset := v_text(i);
           -- 10.typasset
           i := 10;
           if v_text(i) is not null then
             if length(v_text(i)) > 4 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           begin
             select CODCODEC
             into v_chk_typasset
             from TCODASST
             where CODCODEC = upper(v_text(i));
           exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2055';
              v_err_table := 'TASSETS';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
            end;
           v_typasset := upper(v_text(i));
          exit cal_loop;
        end loop;
        if not v_error then
          v_rec_tran := v_rec_tran + 1;
          begin
              select count(codasset)
              into v_chk_codasset
              from tasetinf
              where codasset = v_codasset;

          exception when no_data_found then
              v_chk_codasset := 0;
          end;
          begin
            if v_chk_codasset = 0 then
              insert into tasetinf(CODASSET,TYPASSET,DESASSEE,DESASSET,DESASSE3,DESASSE4,DESASSE5,DTEREC,DESNOTE,SRCASSET,STAASSET)
              values(v_codasset,v_typasset,v_desassee,v_desasset,v_desasse3,v_desasse4,v_desasse5,To_date(v_dterec, 'dd/mm/yyyy'),v_desnote,v_srcasset,1);
            else
              update tasetinf
               set DESASSEE   = v_desassee,
                   DESASSET   = v_desasset,
                   DESASSE3   = v_desasse3,
                   DESASSE4   = v_desasse4,
                   DESASSE5   = v_desasse5,
                   DTEREC     = To_date(v_dterec, 'dd/mm/yyyy'),
                   DESNOTE    = v_desnote,
                   SRCASSET   = v_srcasset,
                   TYPASSET   = v_typasset,
                   coduser    = global_v_coduser
                where CODASSET = v_codasset;
             end if;
          exception when others then
             param_msg_error := get_error_msg_php('HR2508',global_v_lang);
          end;
        else  --if error
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
--          GET_ERRORM_NAME (v_err_code,global_v_lang)||v_err_table ||'('||v_err_filed||')';
--          replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1+1;
        end if;

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
  --
END hrpm1ee;

/
