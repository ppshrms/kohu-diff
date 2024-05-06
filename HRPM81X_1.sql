--------------------------------------------------------
--  DDL for Package Body HRPM81X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM81X" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    json_data       json_object_t;
    str_data        varchar(4000 char);
    str_loop        varchar(4000 char);
  begin
    json_obj            := json_object_t(json_str);
    pa_logic            := json_object_t();

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    pa_codcomp          := hcm_util.get_string_t(json_obj,'pa_codcomp');
    pa_codempid         := hcm_util.get_string_t(json_obj,'pa_codempid');
    pa_type_report      := hcm_util.get_string_t(json_obj,'pa_report');
--    pa_logic            := json(json_obj.get('pa_logic'));
    pa_logic            := hcm_util.get_json_t(json_obj,'pa_logic');
    pa_logic_des        := hcm_util.get_string_t(pa_logic,'code');
    p_flag              := hcm_util.get_string_t(json_obj,'p_flag');
    if p_flag is not null then
      json_data  :=  hcm_util.get_json_t(json_obj,'params');
      for i in 0..json_data.get_size-1 loop
        str_loop    := hcm_util.get_string_t(json_data, i);
        if i != 0  then
          str_data := CONCAT(str_data, ',');
        end if;
        str_data := CONCAT(str_data, str_loop);
      end loop;
    end if ;
     p_params := str_data;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
--    clear_ttemprpt_resume;
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_Stmt          VARCHAR2(500);
    v_Stmt0         VARCHAR2(500);
    v_Stmt1         VARCHAR2(4000);
    v_Stmt2         VARCHAR2(500);   --<< user25 09/07/2021 #6078 
    cursor1         SYS_REFCURSOR;
    col_codempid    temploy1.codempid%type;
    col_codcomp     temploy1.codcomp%type;
    col_codpos      temploy1.codpos%type;
    col_numlvl      temploy1.numlvl%type;
    col_dteempmt    temploy1.dteempmt%type;

    v_data          boolean;
    v_data_str      boolean := false;
    v_flgskip       varchar2(1):= 'N';

    flg_loop    number := 0;

    begin
      obj_row := json_object_t();
      obj_data := json_object_t();

      if pa_codcomp is not null then
        param_msg_error := HCM_SECUR.secur_codcomp(global_v_coduser,global_v_lang,pa_codcomp);
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
      end if;

      if pa_codempid is not null then
        if secur_main.secur2(pa_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) <> true then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
      end if;


      v_Stmt := ' select codempid, codcomp, codpos, numlvl, dteempmt
                from  temploy1 V_HRMS11
                where codempid is not null ' ;
      if (pa_codcomp <> '' or pa_codcomp is not null) then
        v_Stmt0 :=  ' AND V_HRMS11.CODCOMP LIKE ''%' || pa_codcomp || '%''';
      end if;
      if (pa_codempid <> '' or pa_codempid is not null) then
        v_Stmt0 :=  v_Stmt0||' AND V_HRMS11.codempid = ''' || pa_codempid || ''' ';
      end if;
      if (pa_logic_des is not null) then
        v_Stmt0 :=  v_Stmt0|| 'and ' || pa_logic_des;
      end if;

--      v_Stmt1 := v_Stmt || v_Stmt0 ;

      v_Stmt2 := ' order by codempid ' ; --<< user25 09/07/2021 #6078
      v_Stmt1 := v_Stmt || v_Stmt0 || v_Stmt2;--<< user25 09/07/2021 #6078
--      commit;

      v_rcnt := 0;
      open cursor1 for v_Stmt1;
      LOOP
      FETCH  cursor1 into col_codempid,
                        col_codcomp,
                        col_codpos,
                        col_numlvl,
                        col_dteempmt;

      EXIT WHEN cursor1%NOTFOUND;

        v_data := secur_main.secur1(col_codcomp,col_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);

        v_data_str := true;
        if v_data  then
          obj_data   := json_object_t();
          v_flgskip := 'N';
          if pa_codcomp is null then
            v_flgskip := 'Y';
          end if;
          obj_data.put('coderror', '200');

          obj_data.put('rcnt', '');
          obj_data.put('image', get_emp_img(col_codempid));
          obj_data.put('codempid', col_codempid);
          obj_data.put('codempname', get_temploy_name(col_codempid,global_v_lang));
          obj_data.put('codcomp', get_tcenter_name(col_codcomp,global_v_lang));
          obj_data.put('codpos', get_tpostn_name(col_codpos,global_v_lang));
          obj_data.put('numlvl', col_numlvl);
          obj_data.put('dteempmt', to_char(col_dteempmt, 'dd/mm/yyyy') );
          obj_data.put('flgskip', v_flgskip);

          obj_row.put(to_char(v_rcnt),obj_data);

          v_rcnt := v_rcnt+1;

--        else
--          v_data_str := 'false';
        end if;
--        flg_loop := flg_loop+1;
      END LOOP;
--
--      if param_msg_error is null then
--        json_str_output := obj_row.to_clob;
--      end if;
      if v_data_str = true then
        if v_rcnt = 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
          json_str_output := obj_row.to_clob;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;

  end;

  procedure getPopup(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        genPopup(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure genPopup(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_params        json_object_t;
    strName         varchar(50 char);
    desc_typinf     varchar(50 char) := '';
    cursor c1 is select * from trepconfig order by codinf;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop

      get_groupname(r1.codinf,global_v_lang,strName);
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('naminft', strName);
      obj_data.put('codinf', r1.codinf);
      obj_data.put('flguse', r1.flguse);
      obj_data.put('qtymax', r1.qtymax);
      obj_data.put('typinf', r1.typinf);

      if r1.typinf = 'S' then
         desc_typinf := 'Single';
      elsif r1.typinf = 'M' then
         desc_typinf := 'Multiple';
      end if;
      obj_data.put('desc_typinf', desc_typinf);
      obj_data.put('qtymax', r1.qtymax);
      obj_row.put(to_char(v_rcnt-1),obj_data);


    end loop;
    json_str_output := obj_row.to_clob();

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_update_popup (json_str_input in clob, json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_status          varchar2(100 char);
    p_codinf          trepconfig.codinf%type;
    p_qtymax          trepconfig.qtymax%type;
    p_flguse          trepconfig.flguse%type;
    p_keyID           boolean;
    p_flgEdit         boolean;
    p_params          json_object_t;

  begin
    initial_value(json_str_input);
    obj_data := json_object_t(json_str_input);
    p_params := hcm_util.get_json_t(obj_data,'params');

    obj_row := json_object_t();

    for i in 0..p_params.get_size-1 loop
        obj_row       := json_object_t();
        obj_row       := hcm_util.get_json_t(p_params,to_char(i));

        p_codinf    := hcm_util.get_string_t(obj_row, 'codinf');
        p_qtymax    := hcm_util.get_string_t(obj_row, 'qtymax');
        p_keyID     := hcm_util.get_boolean_t(obj_row,'keyID');
        p_flgEdit   := hcm_util.get_boolean_t(obj_row,'flgEdit');

        if p_flgEdit  then
            if p_keyid  then
                p_flguse := 'Y'; --TRUE
            else
                p_flguse := 'N';--FALSE
            end if;
            -------
            begin
               update trepconfig
               set qtymax = p_qtymax,
                   flguse = p_flguse
               where codinf = p_codinf;
            end;
        end if;
    end loop;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_update_popup;

 procedure get_groupname(p_codinf in varchar2, p_lang in varchar2, str_groupname out varchar2) is
		v_Stmt			VARCHAR2(500);
		v_Stmt0			VARCHAR2(500);
		v_Stmt1			VARCHAR2(500);
		v_Stmt2			VARCHAR2(500);
	BEGIN
		IF p_codinf is not null then
			IF p_lang = '101' THEN
				v_Stmt0 := ' SELECT NAMINFE';
			ELSIF p_lang = '102' THEN
				v_Stmt0 := ' SELECT NAMINFT ';
			ELSIF p_lang = '103' THEN
				v_Stmt0 := ' SELECT NAMINF3 ';
			ELSIF p_lang = '104' THEN
				v_Stmt0 := ' SELECT NAMINF4 ';
			ELSIF p_lang = '105' THEN
				v_Stmt0 := ' SELECT NAMINF5 ';
			ELSE
				v_Stmt0 := ' SELECT NAMINFE ';
			END IF;

			v_Stmt1 := ' FROM trepconfig ';
            v_Stmt2 := ' WHERE CODINF = ''' ||p_codinf||'''';
			v_Stmt := v_Stmt0 || v_Stmt1 || v_Stmt2 ;
			begin
				execute immediate v_Stmt into str_groupname ;

			exception
			when no_data_found then
				str_groupname := '';
			end;
		else
			str_groupname := '';
		end if;
	EXCEPTION
	WHEN OTHERS THEN
		RAISE;
	end get_groupname;

    procedure initial_report(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj              := json_object_t(json_str);
		global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid     := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
		json_codempid         := hcm_util.get_json_t(json_obj, 'list_codempid');
    p_report              := hcm_util.get_string_t(json_obj,'p_report');

       -- json_numcaselw  := hcm_util.get_json(json_obj, 'p_numcaselw');
	end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
		json_output clob;
	begin
		initial_report(json_str_input);
		isInsertReport := true;
    numYearReport := HCM_APPSETTINGS.get_additional_year();
		if param_msg_error is null then
        clear_ttemprpt;
        clear_ttemprpt_resume;
        validation_secur1;
        for i in 0..json_codempid.get_size-1 loop
          r_codempid := hcm_util.get_string_t(json_codempid, to_char(i));
          begin
              select
                  hcm_util.get_codcomp_level(codcomp, 1)
              into
                  r_codcomp
              from temploy1
              where codempid = r_codempid;
          exception when others then
              null;
          end;
          get_detail_report(json_str_output);
          gen_report_resume(r_codempid);
          commit;
        end loop;
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;

  procedure gen_report_resume(v_codempid in varchar2) is
    v_namemp          varchar2(1000 char);
    v_desc_codpos     varchar2(1000 char);
    v_adrcont         varchar2(1000 char);
    v_codsubdistc     varchar2(1000 char);
    v_coddistc        varchar2(1000 char);
    v_codprovc        varchar2(1000 char);
    v_codcntyc        varchar2(1000 char);
    v_codpostc        varchar2(1000 char);
    v_numtelec        varchar2(1000 char);
    v_email           varchar2(1000 char);
    v_nummobile_main  varchar2(1000 char);
    v_yearempmt       varchar2(1000 char);
    v_codpos          varchar2(1000 char);
    v_codcomp         varchar2(1000 char);
    v_codjob          varchar2(1000 char);
    v_decs_codjob     varchar2(1000 char);
    v_tempyaer        varchar2(1000 char);
    v_numseqedu       number := 0;
    v_image           tempimge.namimage%type;
    v_has_image       varchar2(1) := 'N';

    cursor c_teducatn is
      select codedlv,codminsb,codinst,codcount,dtegyear, flgeduc, codmajsb
        from teducatn
       where codempid = v_codempid
    order by dtegyear desc;

    cursor c_thismove is
      select to_char(to_char(dteeffec,'yyyy') + 543) as dteeffec,codpos,codcomp,codjob
        from thismove
       where codempid = v_codempid
         and (codpos <> v_codpos or codcomp <> v_codcomp)
    order by dteeffec desc,numseq desc;

    cursor c_tapplwex is
      select to_char(to_char(dtestart,'yyyy') + 543) as dtestart, to_char(to_char(dteend,'yyyy') + 543) as dteend,deslstpos,desnoffi,desjob
        from tapplwex
       where codempid = v_codempid
    order by dteend desc;

    cursor c_tcmptncy is
      select codtency,grade
        from tcmptncy
       where codempid = v_codempid
    order by codtency;
	begin
    begin
      select decode(global_v_lang,'101',namempe,
                                  '102',namempt,
                                  '103',namemp3,
                                  '104',namemp4,
                                  '105',namemp5) as namemp,
              get_tpostn_name (codpos ,global_v_lang ) desc_cospos
      into  v_namemp, v_desc_codpos
      from temploy1
      where codempid = v_codempid;
    end;
    begin
      select
        decode(global_v_lang, '101', adrconte,
                              '102', adrcontt,
                              '103', adrcont3,
                              '104', adrcont4,
                              '105', adrcont5) as adrcont,
        get_tsubdist_name(codsubdistc,global_v_lang) as codsubdistc,
        get_tcoddist_name(coddistc,global_v_lang) as coddistc,
        get_tcodec_name('TCODPROV',codprovc,global_v_lang) as codprovc,
        get_tcodec_name('TCODCNTY',codcntyc,global_v_lang) as codcntyc,
        codpostc, numtelec, email, NUMMOBILE
      into v_adrcont, v_codsubdistc, v_coddistc, v_codprovc,
           v_codcntyc,
           v_codpostc, v_numtelec, v_email, v_nummobile_main
      from
          temploy1 a left join temploy2 b
          ON a.codempid = b.codempid
      where
          a.codempid = v_codempid;
    end;
    -- current work
    begin
      select to_char(dteempmt,'yyyy')+543,codpos,codcomp,codjob
        into v_yearempmt,v_codpos,v_codcomp,v_codjob
        from temploy1
       where codempid = v_codempid;
    end;
    --Report insert TTEMPRPT
    begin
      select namimage
       into v_image
       from tempimge
       where codempid = v_codempid;
    exception when no_data_found then
      v_image := '';
    end;
   --<<check existing image
    if v_image is not null then
      v_image := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1') || '/' || v_image;
      v_has_image   := 'Y';
    else
      v_image := get_tsetup_value('PATHWORKPHP')||'default-emp.png';
      v_has_image   := 'Y';
    end if;
    -->>
    begin
      -- insert info employee
				v_numseq := v_numseq + 1;
				INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                              ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                              ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                              ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,ITEM16)
				VALUES (global_v_codempid, 'HRPM81X1',v_numseq,
                2, pa_codcomp, v_codempid,v_namemp,v_desc_codpos,
                v_adrcont, get_label_name('HRCO01EC2',global_v_lang,160)||' '||v_codsubdistc, get_label_name('HRCO01EC2',global_v_lang,150) ||' '||v_coddistc, v_codprovc, v_codcntyc,
                v_codpostc, v_numtelec, v_email, v_image, v_has_image,v_nummobile_main);
      --tar2
      -- insert education
        v_numseqedu := 0;
        for i in c_teducatn loop
          v_numseq := v_numseq + 1;
          v_numseqedu := v_numseqedu + 1;
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM14,ITEM15,ITEM16,ITEM17,ITEM18)
          VALUES (global_v_codempid, 'HRPM81X2',v_numseq, 2, pa_codcomp, v_codempid,
                  get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang),
                  get_tcodec_name('TCODSUBJ',i.codminsb,global_v_lang),
                  get_tcodec_name('TCODINST',i.codinst,global_v_lang),
                  get_tcodec_name('TCODCNTY',i.codcount,global_v_lang),
                  v_numseqedu);
        end loop;
      -- insert experience
--        v_numseq := v_numseq + 1;
--        select decode(global_v_lang,'101', namjobe,
--                                    '102', namjobt,
--                                    '103', namjob3,
--                                    '104', namjob4,
--                                    '105', namjob5) as namjob
--          into v_decs_codjob
--          from tjobcode
--          where codjob = v_codjob; --find desc codjob
--
--				INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM18,ITEM19,ITEM20,ITEM21,ITEM22)
--				VALUES (global_v_codempid, 'HRPM81X3',v_numseq, 2, pa_codcomp, v_codempid,
--                v_yearempmt,
--                to_char(sysdate,'yyyy') + 543,
--                get_tcenter_name(v_codcomp, global_v_lang),
--                get_tpostn_name (v_codpos, global_v_lang),
--                v_decs_codjob);

        -- insert this move work ,codpos,codcomp,codjob
        v_tempyaer := v_yearempmt;
        for i in c_thismove loop
          v_numseq := v_numseq + 1;
          select decode(global_v_lang,'101', namjobe,
                                      '102', namjobt,
                                      '103', namjob3,
                                      '104', namjob4,
                                      '105', namjob5) as namjob
          into v_decs_codjob
          from tjobcode where codjob = i.codjob; --find desc codjob
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM18,ITEM19,ITEM20,ITEM21,ITEM22)
          VALUES (global_v_codempid, 'HRPM81X3',v_numseq, 2, pa_codcomp, v_codempid,
                  v_tempyaer,
                  i.dteeffec,
                  get_tcenter_name(i.codcomp, global_v_lang),
                  get_tpostn_name (i.codpos, global_v_lang),
                  v_decs_codjob);
          v_tempyaer := i.dteeffec;
        end loop;

        -- insert history work
        for i in c_tapplwex loop
          v_numseq := v_numseq + 1;
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM18,ITEM19,ITEM20,ITEM21,ITEM22)
          VALUES (global_v_codempid, 'HRPM81X3',v_numseq, 2, pa_codcomp, v_codempid,
                  nvl(i.dtestart,' '),
                  nvl(i.dteend,' '),
                  i.deslstpos,
                  i.desnoffi,
                  i.desjob);
        end loop;

        -- insert codtency
        for i in c_tcmptncy loop
          v_numseq := v_numseq + 1;
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM23,ITEM24)
          VALUES (global_v_codempid, 'HRPM81X4',v_numseq, 2, pa_codcomp, v_codempid,
                  get_tcodec_name('TCODSKIL',i.codtency,global_v_lang),i.grade);
        end loop;
    end;
	end gen_report_resume;
  procedure clear_ttemprpt_resume is
	begin
		begin
			delete
			from ttemprpt
			where codempid = global_v_codempid
			and codapp like 'HRPM81X%';
		exception when others then
			null;
		end;
	end clear_ttemprpt_resume;

	procedure clear_ttemprpt is
	begin
		begin
			delete
			from ttemprpt
			where codempid = global_v_codempid
			and codapp = 'HRPM81X';
		exception when others then
			null;
		end;
	end clear_ttemprpt;
  function get_numappl(p_codempid varchar2) return varchar2 is
    v_numappl   temploy1.numappl%type;
  begin
    begin
      select  nvl(numappl,codempid)
      into    v_numappl
      from    temploy1
      where   codempid = p_codempid;
    exception when no_data_found then
      v_numappl := p_codempid;
    end;
    return v_numappl;
  end; -- end get_numappl
  procedure validation_secur1 is
        v_numlvl    temploy1.numlvl%type;
        v_codcomp   temploy1.codcomp%type;
	begin
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        begin
			select codcomp,numlvl into v_codcomp,v_numlvl
			from temploy1
			where codempid = global_v_codempid
    		and rownum <=1;
        exception when no_data_found then
			null;
        end;
        permision_salary := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);

    end validation_secur1;

  PROCEDURE get_detail_report (json_str_output OUT CLOB) IS
    v_namfirst_main   VARCHAR2(500 CHAR);
    v_namlast_main   VARCHAR2(500 CHAR);
    v_nicknam_main   VARCHAR2(500 CHAR);
    v_codempid_main   VARCHAR2(500 CHAR);
    v_numtelof_main   VARCHAR2(500 CHAR);
    v_nummobile_main   VARCHAR2(500 CHAR);
    v_email_main   VARCHAR2(500 CHAR);
    v_lineid_main   VARCHAR2(500 CHAR);

    tab1   VARCHAR2(2 CHAR);
    tab2   VARCHAR2(2 CHAR);
    tab3   VARCHAR2(2 CHAR);
    tab4   VARCHAR2(2 CHAR);
    tab5   VARCHAR2(2 CHAR);
    tab6   VARCHAR2(2 CHAR);
    tab7   VARCHAR2(2 CHAR);
    tab8   VARCHAR2(2 CHAR);
    tab9   VARCHAR2(2 CHAR);
    tab10   VARCHAR2(2 CHAR);
    tab11   VARCHAR2(2 CHAR);
    tab12   VARCHAR2(2 CHAR);
    tab13   VARCHAR2(2 CHAR);
    tab14   VARCHAR2(2 CHAR);
    tab15   VARCHAR2(2 CHAR);
    tab16   VARCHAR2(2 CHAR);
    tab17   VARCHAR2(2 CHAR);
    tab18   VARCHAR2(2 CHAR);
    tab19   VARCHAR2(2 CHAR);
    tab20   VARCHAR2(2 CHAR);
    tab21   VARCHAR2(2 CHAR);
    tab22   VARCHAR2(2 CHAR);
    tab23   VARCHAR2(2 CHAR);
    tab24   VARCHAR2(2 CHAR);
    tab25   VARCHAR2(2 CHAR);
    tab26   VARCHAR2(2 CHAR);
    tab27   VARCHAR2(2 CHAR);
    tab28   VARCHAR2(2 CHAR);
    tab29   VARCHAR2(2 CHAR);
    tab30   VARCHAR2(2 CHAR);
    tab31   VARCHAR2(2 CHAR);
    tab32   VARCHAR2(2 CHAR);
    tab33   VARCHAR2(2 CHAR);
    tab34   VARCHAR2(2 CHAR);
    tab35   VARCHAR2(2 CHAR);
    tab36   VARCHAR2(2 CHAR);
    tab10_detail   VARCHAR2(2 CHAR) := '0';
    tab11_detail   VARCHAR2(2 CHAR) := '0';
    tab12_detail   VARCHAR2(2 CHAR) := '0';
    tab13_detail   VARCHAR2(2 CHAR) := '0';
    tab14_detail   VARCHAR2(2 CHAR) := '0';
    tab15_detail   VARCHAR2(2 CHAR) := '0';
    tab16_detail   VARCHAR2(2 CHAR) := '0';
    tab17_detail   VARCHAR2(2 CHAR) := '0';
    tab18_detail   VARCHAR2(2 CHAR) := '0';
    tab19_detail   VARCHAR2(2 CHAR) := '0';
    tab20_detail   VARCHAR2(2 CHAR) := '0';
    tab21_detail   VARCHAR2(2 CHAR) := '0';
    tab22_detail   VARCHAR2(2 CHAR) := '0';
    tab23_detail   VARCHAR2(2 CHAR) := '0';
    tab24_detail   VARCHAR2(2 CHAR) := '0';
    tab25_detail   VARCHAR2(2 CHAR) := '0';
    tab26_detail   VARCHAR2(2 CHAR) := '0';
    tab27_detail   VARCHAR2(2 CHAR) := '0';
    tab28_detail   VARCHAR2(2 CHAR) := '0';
    tab29_detail   VARCHAR2(2 CHAR) := '0';
    tab30_detail   VARCHAR2(2 CHAR) := '0';
    tab31_detail   VARCHAR2(2 CHAR) := '0';
    tab32_detail   VARCHAR2(2 CHAR) := '0';
    tab33_detail   VARCHAR2(2 CHAR) := '0';
    tab34_detail   VARCHAR2(2 CHAR) := '0';
    tab35_detail   VARCHAR2(2 CHAR) := '0';
    tab36_detail   VARCHAR2(2 CHAR) := '0';

    v_rcnt        NUMBER := 0;
    v_numoffid    VARCHAR2(500 CHAR);
    v_dteoffid    VARCHAR2(500 CHAR);
    v_adrissue    VARCHAR2(500 CHAR);
    v_codprovi    VARCHAR2(500 CHAR);
    v_codclnsc    VARCHAR2(500 CHAR);
    v_numpasid    VARCHAR2(500 CHAR);
    v_dtepasid    VARCHAR2(500 CHAR);
    v_numvisa     VARCHAR2(500 CHAR);
    v_dtevisaexp  VARCHAR2(500 CHAR);
    v_numlicid    VARCHAR2(500 CHAR);
    v_dtelicid    VARCHAR2(500 CHAR);
    v_dteempdb    VARCHAR2(500 CHAR);
    v_coddomcl    VARCHAR2(500 CHAR);
    v_age         VARCHAR2(500 CHAR);
    v_codsex      VARCHAR2(500 CHAR);
    v_high        VARCHAR2(500 CHAR);
    v_weight      VARCHAR2(500 CHAR);
    v_codblood    VARCHAR2(500 CHAR);
    v_codorgin    VARCHAR2(500 CHAR);
    v_codnatnl    VARCHAR2(500 CHAR);
    v_codrelgn    VARCHAR2(500 CHAR);
    v_stamarry    VARCHAR2(500 CHAR);
    v_stamilit    VARCHAR2(500 CHAR);
    v_numprmid    VARCHAR2(500 CHAR);
    v_dteprmst    VARCHAR2(500 CHAR);
    v_dteprmen    VARCHAR2(500 CHAR);
    v_numappl     VARCHAR2(500 CHAR);
    v_dteretire   VARCHAR2(500 CHAR);

    str_addr      VARCHAR2(500 CHAR);
    v_addr_return VARCHAR2(500 CHAR);
    v_codsubdistr VARCHAR2(500 CHAR);
    v_coddistr    VARCHAR2(500 CHAR);
    v_codprovr    VARCHAR2(500 CHAR);
    v_codpostr    VARCHAR2(500 CHAR);
    v_codcntyr    VARCHAR2(500 CHAR);

    str_addr_cont   VARCHAR2(500 CHAR);
    v_addc_return   VARCHAR2(500 CHAR);
    v_codsubdistc   VARCHAR2(500 CHAR);
    v_coddistc      VARCHAR2(500 CHAR);
    v_codprovc      VARCHAR2(500 CHAR);
    v_codpostc      VARCHAR2(500 CHAR);
    v_codcntyc      VARCHAR2(500 CHAR);

    p_codcomph_head_3   VARCHAR2(500 CHAR);
    p_codposh_head_3    VARCHAR2(500 CHAR);
    p_codempidh_head_3  VARCHAR2(500 CHAR);
    p_stapost_head_3    VARCHAR2(500 CHAR);
    p_codcomp_head_3    VARCHAR2(500 CHAR);
    p_codpos_head_3     VARCHAR2(500 CHAR);

    v_dteempmt_3    VARCHAR2(500 CHAR);
    v_agejob_3      VARCHAR2(500 CHAR);
    v_staemp_3      VARCHAR2(500 CHAR);
    v_dteeffex_3    VARCHAR2(500 CHAR);
    v_codcomp_3     VARCHAR2(500 CHAR);
    v_fullcodpos_3  VARCHAR2(500 CHAR);
    v_codpos_3      VARCHAR2(500 CHAR);
    v_dteefpos_3    VARCHAR2(500 CHAR);
    v_numlvl_3      VARCHAR2(500 CHAR);
    v_dteeflvl_3    VARCHAR2(500 CHAR);
    v_codbrlc_3     VARCHAR2(500 CHAR);
    v_codempmt_3    VARCHAR2(500 CHAR);
    v_typpayroll_3  VARCHAR2(500 CHAR);
    v_typemp_3      VARCHAR2(500 CHAR);
    v_codcalen_3    VARCHAR2(500 CHAR);
    v_flgatten_3    VARCHAR2(500 CHAR);
    v_codjob_3      VARCHAR2(500 CHAR);
    v_jobgrade_3    VARCHAR2(500 CHAR);
    v_codgrpgl_3    VARCHAR2(500 CHAR);
    v_temphead_3    VARCHAR2(500 CHAR);
    v_temphead_pos_3  VARCHAR2(500 CHAR);
    v_codcompr_3    VARCHAR2(500 CHAR);
    v_codposre_3    VARCHAR2(500 CHAR);
    v_stadisb_3     VARCHAR2(500 CHAR);
    v_numdisab_3    VARCHAR2(500 CHAR);
    v_dtedisb_3     VARCHAR2(500 CHAR);
    v_dtedisen_3    VARCHAR2(500 CHAR);
    v_typdisp_3     VARCHAR2(500 CHAR);
    v_desdisp_3     VARCHAR2(500 CHAR);
    v_triwork_3     VARCHAR2(500 CHAR);
    v_dteduepr_3    VARCHAR2(500 CHAR);
    v_emperiod_3    VARCHAR2(500 CHAR);
    v_dteoccup_3    VARCHAR2(500 CHAR);
    v_numtelof_3    VARCHAR2(500 CHAR);
    v_email_3       VARCHAR2(500 CHAR);
    v_numreqst_3    VARCHAR2(500 CHAR);

    v_ocodempid_4   VARCHAR2(500 CHAR);
    v_dtereemp_4    VARCHAR2(500 CHAR);
    v_triwork_4     VARCHAR2(500 CHAR);
    v_dteduepr_4    VARCHAR2(500 CHAR);
    v_flgpdpa_4     VARCHAR2(500 CHAR);
    v_dtepdpa_4     VARCHAR2(500 CHAR);

    v_typtrav_5     VARCHAR2(500 CHAR);
    v_carlicen_5    VARCHAR2(500 CHAR);
    v_qtylength_5   VARCHAR2(500 CHAR);
    v_codbusno_5    VARCHAR2(500 CHAR);
    v_codbusrt_5    VARCHAR2(500 CHAR);

    v_numtaxid_7    VARCHAR2(500 CHAR);
    v_numsaid_7     VARCHAR2(500 CHAR);
    v_dtecontri_7   VARCHAR2(500 CHAR);
    v_flgtax_7      VARCHAR2(500 CHAR);
    v_typtax_7      VARCHAR2(500 CHAR);
    v_typincom_7    VARCHAR2(500 CHAR);
    v_dteyrrelf_7   VARCHAR2(500 CHAR);
    v_dteyrrelt_7   VARCHAR2(500 CHAR);
    v_amtrelas_7    VARCHAR2(500 CHAR);
    v_amttaxrel_7   VARCHAR2(500 CHAR);

    v_codbank_8     VARCHAR2(500 CHAR);
    v_numbank_8     VARCHAR2(500 CHAR);
    v_numbrnch_8    VARCHAR2(500 CHAR);
    v_amtbank_8     VARCHAR2(500 CHAR);
    v_amttranb_8    VARCHAR2(500 CHAR);
    v_codbank2_8    VARCHAR2(500 CHAR);
    v_numbank2_8    VARCHAR2(500 CHAR);
    v_numbrnch2_8   VARCHAR2(500 CHAR);
    v_flgslip_8     VARCHAR2(500 CHAR);

    v_dtebf_9       VARCHAR2(500 CHAR);
    v_amtincbf_9    VARCHAR2(500 CHAR);
    v_amttaxbf_9    VARCHAR2(500 CHAR);
    v_amtpf_9       VARCHAR2(500 CHAR);
    v_amtsaid_9     VARCHAR2(500 CHAR);

    v_sql_statement varchar2(4000 char);
    type  hrpm81xtab10_cursor is ref cursor;
    hrpm81xtab10_cv    hrpm81xtab10_cursor;
    v_coddeduct_10     VARCHAR2(500 CHAR);
    v_descdeduct_10    VARCHAR2(500 CHAR);
    v_amtdeduct_10     VARCHAR2(500 CHAR);

    type  hrpm81xtab11_cursor is ref cursor;
    hrpm81xtab11_cv    hrpm81xtab11_cursor;
    v_coddeduct_11     VARCHAR2(500 CHAR);
    v_codcomp_11       VARCHAR2(500 CHAR);
    v_descdeduct_11    VARCHAR2(500 CHAR);
    v_amtdeduct_11     VARCHAR2(500 CHAR);
    v_qtychldb_11      VARCHAR2(500 CHAR);
    v_qtychlda_11      VARCHAR2(500 CHAR);
    v_qtychldd_11      VARCHAR2(500 CHAR);
    v_qtychldi_11      VARCHAR2(500 CHAR);
    v_amtchldb_11      VARCHAR2(500 CHAR);
    v_amtchlda_11      VARCHAR2(500 CHAR);
    v_amtchldd_11      VARCHAR2(500 CHAR);
    v_amtchldi_11      VARCHAR2(500 CHAR);

    type  hrpm81xtab12_cursor is ref cursor;
    hrpm81xtab12_cv    hrpm81xtab12_cursor;
    v_coddeduct_12     VARCHAR2(500 CHAR);
    v_descdeduct_12    VARCHAR2(500 CHAR);
    v_amtdeduct_12     VARCHAR2(500 CHAR);

    v_numtaxid_13      VARCHAR2(500 CHAR);
    v_dtebfsp_13       VARCHAR2(500 CHAR);
    v_amtincsp_13      VARCHAR2(500 CHAR);
    v_amttaxsp_13      VARCHAR2(500 CHAR);
    v_amtsasp_13       VARCHAR2(500 CHAR);
    v_amtpfsp_13       VARCHAR2(500 CHAR);

    type  hrpm81xtab14_cursor is ref cursor;
    hrpm81xtab14_cv    hrpm81xtab14_cursor;
    v_coddeduct_14     VARCHAR2(500 CHAR);
    v_descdeduct_14    VARCHAR2(500 CHAR);
    v_amtdeduct_14     VARCHAR2(500 CHAR);

    type  hrpm81xtab15_cursor is ref cursor;
    hrpm81xtab15_cv    hrpm81xtab15_cursor;
    v_coddeduct_15     VARCHAR2(500 CHAR);
    v_descdeduct_15    VARCHAR2(500 CHAR);
    v_amtdeduct_15     VARCHAR2(500 CHAR);

    type  hrpm81xtab16_cursor is ref cursor;
    hrpm81xtab16_cv    hrpm81xtab16_cursor;
    v_coddeduct_16     VARCHAR2(500 CHAR);
    v_descdeduct_16    VARCHAR2(500 CHAR);
    v_amtdeduct_16     VARCHAR2(500 CHAR);

    type  hrpm81xtab17_cursor is ref cursor;
    hrpm81xtab17_cv    hrpm81xtab17_cursor;
    v_dtechg_17       date;
    v_codtitle_17     VARCHAR2(500 CHAR);
    v_namfirst_17     VARCHAR2(500 CHAR);
    v_namlast_17      VARCHAR2(500 CHAR);
    v_deschang_17     VARCHAR2(500 CHAR);

    type  hrpm81xtab18_cursor is ref cursor;
    hrpm81xtab18_cv    hrpm81xtab18_cursor;
    v_typdoc_18       VARCHAR2(500 CHAR);
    v_namdoc_18       VARCHAR2(500 CHAR);
    v_dterecv_18      VARCHAR2(500 CHAR);
    v_dtedocen_18     VARCHAR2(500 CHAR);
    v_numdoc_18       VARCHAR2(500 CHAR);
    v_filedoc_18      VARCHAR2(500 CHAR);

    type  hrpm81xtab19_cursor is ref cursor;
    hrpm81xtab19_cv    hrpm81xtab19_cursor;
    v_eduyear_19      VARCHAR2(500 CHAR);
    v_stayear_19      NUMBER := 0;
    v_dtegyear_19     NUMBER := 0;
    v_codedlv_19      VARCHAR2(500 CHAR);
    v_coddglv_19      VARCHAR2(500 CHAR);
    v_codmajsb_19     VARCHAR2(500 CHAR);
    v_codinst_19      VARCHAR2(500 CHAR);
    v_codcount_19     VARCHAR2(500 CHAR);
    v_numgpa_19       VARCHAR2(500 CHAR);
    v_rcnt_19         NUMBER := 0;

    type  hrpm81xtab20_cursor is ref cursor;
    hrpm81xtab20_cv    hrpm81xtab20_cursor;
    v_rcnt_20         NUMBER := 0;
    v_dtejob_20       VARCHAR2(500 CHAR);
    v_dtestart_20     VARCHAR2(500 CHAR);
    v_dteend_20       VARCHAR2(500 CHAR);
    v_desnoffi_20     VARCHAR2(500 CHAR);
    v_deslstpos_20    VARCHAR2(500 CHAR);

    type  hrpm81xtab21_cursor is ref cursor;
    hrpm81xtab21_cv    hrpm81xtab21_cursor;
    v_rcnt_21         NUMBER := 0;
    v_dtetrain_21     date;
    v_dtetren_21      date;
    v_destrain_21     VARCHAR2(500 CHAR);
    v_desplace_21     VARCHAR2(500 CHAR);
    v_desinstu_21     VARCHAR2(500 CHAR);

    type  hrpm81xtab22_cursor is ref cursor;
    hrpm81xtab22_cv    hrpm81xtab22_cursor;
    v_rcnt_22         NUMBER := 0;
    v_dtetrain_22     VARCHAR2(500 CHAR);
    v_dtetrst_22      date;
    v_dtetren_22      date;
    v_descours_22     VARCHAR2(500 CHAR);
    v_codcours_22     VARCHAR2(500 CHAR);
    v_amttrexp_22     VARCHAR2(500 CHAR);
    v_qtytrhur_22     VARCHAR2(500 CHAR);

    v_codempidsp_23   VARCHAR2(500 CHAR);
    v_fullname_23     VARCHAR2(500 CHAR);
    v_numoffid_23     VARCHAR2(500 CHAR);
    v_dtespbd_23      VARCHAR2(500 CHAR);
    v_stalife_23      VARCHAR2(500 CHAR);
    v_staincom_23     VARCHAR2(500 CHAR);
    v_desnoffi_23     VARCHAR2(500 CHAR);
    v_codspocc_23     VARCHAR2(500 CHAR);
    v_numfasp_23      VARCHAR2(500 CHAR);
    v_nummosp_23      VARCHAR2(500 CHAR);
    v_dtemarry_23     VARCHAR2(500 CHAR);
    v_codsppro_23     VARCHAR2(500 CHAR);
    v_codspcty_23     VARCHAR2(500 CHAR);
    v_desplreg_23     VARCHAR2(500 CHAR);
    v_desnote_23      VARCHAR2(500 CHAR);

    type  hrpm81xtab24_cursor is ref cursor;
    hrpm81xtab24_cv    hrpm81xtab24_cursor;
    v_rcnt_24         NUMBER := 0;
    v_numseq_24       VARCHAR2(500 CHAR);
    v_fullname_24     VARCHAR2(500 CHAR);
    v_numoffid_24     VARCHAR2(500 CHAR);
    v_dtechbd_24      VARCHAR2(500 CHAR);
    v_codsex_24       VARCHAR2(500 CHAR);
    v_flgedlv_24      VARCHAR2(500 CHAR);
    v_flgdeduct_24    VARCHAR2(500 CHAR);

    v_codempfa_25     VARCHAR2(500 CHAR);
    v_fatfnam_25      VARCHAR2(500 CHAR);
    v_numofidf_25     VARCHAR2(500 CHAR);
    v_dtebdfa_25      VARCHAR2(500 CHAR);
    v_codfnatn_25     VARCHAR2(500 CHAR);
    v_codfrelg_25     VARCHAR2(500 CHAR);
    v_codfoccu_25     VARCHAR2(500 CHAR);
    v_staliff_25      VARCHAR2(500 CHAR);
    v_codempmo_25     VARCHAR2(500 CHAR);
    v_motfnam_25      VARCHAR2(500 CHAR);
    v_numofidm_25     VARCHAR2(500 CHAR);
    v_dtebdmo_25      VARCHAR2(500 CHAR);
    v_codmnatn_25     VARCHAR2(500 CHAR);
    v_codmrelg_25     VARCHAR2(500 CHAR);
    v_codmoccu_25     VARCHAR2(500 CHAR);
    v_stalifm_25      VARCHAR2(500 CHAR);
    v_contfnam_25     VARCHAR2(500 CHAR);
    v_adrcont1_25     VARCHAR2(500 CHAR);
    v_codpost_25      VARCHAR2(500 CHAR);
    v_numtele_25      VARCHAR2(500 CHAR);
    v_numfax_25       VARCHAR2(500 CHAR);
    v_email_25        VARCHAR2(500 CHAR);
    v_desrelat_25     VARCHAR2(500 CHAR);

    type  hrpm81xtab26_cursor is ref cursor;
    hrpm81xtab26_cv    hrpm81xtab26_cursor;
    v_numseq_26       VARCHAR2(500 CHAR);
    v_namrel_26       VARCHAR2(500 CHAR);

    type  hrpm81xtab27_cursor is ref cursor;
    hrpm81xtab27_cv    hrpm81xtab27_cursor;
    v_numseq_27       VARCHAR2(500 CHAR);
    v_namguar_27      VARCHAR2(500 CHAR);
    v_dtegucon_27     VARCHAR2(500 CHAR);
    v_amtguarntr_27   number;

    type  hrpm81xtab28_cursor is ref cursor;
    hrpm81xtab28_cv    hrpm81xtab28_cursor;
    v_numcolla_28     VARCHAR2(500 CHAR);
    v_typcolla_28     VARCHAR2(500 CHAR);
    v_codtypcolla_28  VARCHAR2(500 CHAR);
    v_amtcolla_28     VARCHAR2(500 CHAR);
    v_numdocum_28     VARCHAR2(500 CHAR);
    v_flgded_28       tcolltrl.flgded%type;
    v_amtded_28       tcolltrl.amtded%type;
    v_tmp_amtded_28   varchar2(100 char);
    v_qtyperiod_28    varchar2(100 char);
    v_dtestrt_28      tcolltrl.dtestrt%type;
    v_dteend_28       tcolltrl.dteend%type;
    v_newdtestrt_28   VARCHAR2(500 CHAR);
    v_newdteend_28    VARCHAR2(500 CHAR);
    v_dtededuct_28    VARCHAR2(500 CHAR);

    type  hrpm81xtab29_cursor is ref cursor;
    hrpm81xtab29_cv    hrpm81xtab29_cursor;
    v_namref_29       VARCHAR2(500 CHAR);
    v_flgref_29       VARCHAR2(500 CHAR);
    v_despos_29       VARCHAR2(500 CHAR);
    v_desnoffi_29     VARCHAR2(500 CHAR);

    type  hrpm81xtab30_cursor is ref cursor;
    hrpm81xtab30_cv    hrpm81xtab30_cursor;
    v_rcnt_30         NUMBER := 0;
    v_codpos_30       VARCHAR2(500 CHAR);
    v_codcomp_30      VARCHAR2(500 CHAR);
    v_tcmptncy_codtency_30    VARCHAR2(500 CHAR);
    v_grade_30        VARCHAR2(500 CHAR);
    v_codtency_30     VARCHAR2(500 CHAR);
    v_codskill_30     VARCHAR2(500 CHAR);
    v_gradestandard_30      VARCHAR2(500 CHAR);
    v_gpa_num         NUMBER := 0;
    v_gpa_str         VARCHAR2(500 CHAR);

    type  hrpm81xtab31_cursor is ref cursor;
    hrpm81xtab31_cv    hrpm81xtab31_cursor;
    v_rcnt_31         NUMBER := 0;
    v_langu_31        VARCHAR2(500 CHAR);
    v_flglist_31      VARCHAR2(500 CHAR);
    v_desclist_31     VARCHAR2(500 CHAR);
    v_flgspeak_31     VARCHAR2(500 CHAR);
    v_descspeak_31    VARCHAR2(500 CHAR);
    v_flgread_31      VARCHAR2(500 CHAR);
    v_descread_31     VARCHAR2(500 CHAR);
    v_flgwrite_31     VARCHAR2(500 CHAR);
    v_descwrite_31    VARCHAR2(500 CHAR);

    type  hrpm81xtab32_cursor is ref cursor;
    hrpm81xtab32_cv    hrpm81xtab32_cursor;
    v_dteinput_32     VARCHAR2(500 CHAR);
    v_typrewd_32      VARCHAR2(500 CHAR);
    v_desrewd1_32     VARCHAR2(500 CHAR);
    v_numhmref_32     VARCHAR2(500 CHAR);

    type  hrpm81xtab33_cursor is ref cursor;
    hrpm81xtab33_cv    hrpm81xtab33_cursor;
    type  hrpm81xtab33_sub_cursor is ref cursor;
    hrpm81xtab33_sub_cv    hrpm81xtab33_sub_cursor;
    v_rcnt_33         NUMBER := 0;
    v_num_columns     VARCHAR2(500 CHAR);
    v_column_name_33  VARCHAR2(500 CHAR);
    v_labelname_33    VARCHAR2(500 CHAR);
    v_data_33         VARCHAR2(500 CHAR);

    type  hrpm81xtab34_cursor is ref cursor;
    hrpm81xtab34_cv    hrpm81xtab34_cursor;
    v_dteeffec_34     VARCHAR2(500 CHAR);
    v_codpos_34       VARCHAR2(500 CHAR);
    v_descomp_34      VARCHAR2(500 CHAR);
    v_codcomp_34      VARCHAR2(500 CHAR);
    v_codempmt_34     VARCHAR2(500 CHAR);
    v_numlvl_34       VARCHAR2(500 CHAR);
    v_codtrn_34       VARCHAR2(500 CHAR);
    v_amtincadj1_34        NUMBER := 0;
    v_amtincadj2_34        NUMBER := 0;
    v_amtincadj3_34        NUMBER := 0;
    v_amtincadj4_34        NUMBER := 0;
    v_amtincadj5_34        NUMBER := 0;
    v_amtincadj6_34        NUMBER := 0;
    v_amtincadj7_34        NUMBER := 0;
    v_amtincadj8_34        NUMBER := 0;
    v_amtincadj9_34        NUMBER := 0;
    v_amtincadj10_34       NUMBER := 0;
    v_amtincom1_34         NUMBER := 0;
    v_amtincom2_34         NUMBER := 0;
    v_amtincom3_34         NUMBER := 0;
    v_amtincom4_34         NUMBER := 0;
    v_amtincom5_34         NUMBER := 0;
    v_amtincom6_34         NUMBER := 0;
    v_amtincom7_34         NUMBER := 0;
    v_amtincom8_34         NUMBER := 0;
    v_amtincom9_34         NUMBER := 0;
    v_amtincom10_34        NUMBER := 0;
    v_amtothrincadj_34     NUMBER := 0;
    v_amtdayincadj_34      NUMBER := 0;
    v_sumincadj_34         NUMBER := 0;
    v_amtothrincome_34     NUMBER := 0;
    v_amtdayincome_34      NUMBER := 0;
    v_sumincom_34          NUMBER := 0;
    v_jobgrade_34          thismove.jobgrade%TYPE;

    type  hrpm81xtab35_cursor is ref cursor;
    hrpm81xtab35_cv    hrpm81xtab35_cursor;
    type  hrpm81xtab35_2_cursor is ref cursor;
    hrpm81xtab35_2_cv    hrpm81xtab35_2_cursor;
    v_dteyreap_35       VARCHAR2(500 CHAR);
    v_codpos_35         VARCHAR2(500 CHAR);
    v_codcomp_35        VARCHAR2(500 CHAR);
    v_qtybeh_35         VARCHAR2(500 CHAR);
    v_qtykpi_35         VARCHAR2(500 CHAR);
    v_qtycmp_35         VARCHAR2(500 CHAR);
    v_qtytot_35         VARCHAR2(500 CHAR);
    v_wgttot_35         VARCHAR2(500 CHAR);
    v_jobgrade_35       VARCHAR2(500 CHAR);
    v_grade_35          tapprais.grade%TYPE;
    v_qtyta_35          tapprais.qtyta%TYPE;
    v_qtypuns_35        tapprais.qtypuns%TYPE;
    v_tapuns_35         VARCHAR2(500 CHAR);

    type  hrpm81xtab36_cursor is ref cursor;
    hrpm81xtab36_cv        hrpm81xtab36_cursor;
    v_dteeffec_36          VARCHAR2(500 CHAR);
    v_desmist1_36          VARCHAR2(500 CHAR);
    v_codpunsh_36          VARCHAR2(500 CHAR);
    v_desc_codpunsh_36     VARCHAR2(500 CHAR);
    v_codmist_36           VARCHAR2(500 CHAR);
    v_desc_codmist_36      VARCHAR2(500 CHAR);
    v_dtestart_36          VARCHAR2(500 CHAR);
    v_dteend_36            VARCHAR2(500 CHAR);
    v_remark_36            VARCHAR2(500 CHAR);
    v_flgexempt_36         VARCHAR2(10 CHAR);
    v_flgblist_36          VARCHAR2(10 CHAR);
    v_exempt_36            VARCHAR2(200 CHAR);
    v_blist_36             VARCHAR2(200 CHAR);

    v_amtothr_income    NUMBER;
    v_amtday_income     NUMBER;
    v_sumincom_income   NUMBER;
    v_amtproadj_6   number := 0;

    obj_row           json_object_t;
    obj_data          json_object_t;
    v_row             number := 0;

    param_json        json_object_t;
    param_json_row    json_object_t;

    v_json_codincom   clob;
    v_json_input      clob;

    v_codcompy       tcompny.codcompy%type;
    v_codempid       temploy1.codempid%type;
    v_codempmt       temploy1.codempmt%type;
    v_codcomp        temploy1.codcomp%type;
    type p_num is table of number index by binary_integer;
    v_amtincom       p_num;

    v_image          tempimge.namimage%type;
    v_has_image      varchar2(1) := 'N';
    v_codincom       tinexinf.codpay%type;
    v_desincom       tinexinf.descpaye%type;
    v_desunit        varchar2(150 char);
    v_amtmax         number;
    v_amount         number;

    str_sub_amtincom      varchar2(1500 char);
    str_sub_amtincadj     varchar2(1500 char);
    str_sum               varchar2(1500 char);
    report_v_row          number := 0;

    v_period              number := 0;
    v_sumamt              number := 0;
    v_ttguartee_period    varchar2(150 char);

    v_rownum_qtymax         number;

    CURSOR c_trepconfig IS
        select *
        from trepconfig
        where flguse = 'Y'
        order by codinf;

    cursor c_ttguartee is
      select dteyrepay,dtemthpay,numperiod,stddec(amtpay,codempid,global_v_chken) amtpay
      from ttguartee
      where codempid = r_codempid
      and numcolla = v_numcolla_28
      order by numperiod,dtemthpay,dteyrepay;


    cursor c_competency is
      select  jd.codtency as typtency,jd.codskill as codskill,
              cpt.grade, jd.grade expgrade, 'JD' as typjd
      from    temploy1 emp, tjobposskil jd, tcmptncy cpt
      where   emp.codempid    = r_codempid
      and     emp.codcomp     = jd.codcomp
      and     emp.codpos      = jd.codpos
      and     emp.numappl     = cpt.numappl(+)
      and     jd.codskill     = cpt.codtency(+)
      union all
      select  nvl(skl.codtency,'N/A') as typtency,cpt.codtency as codskill,
              cpt.grade,null expgrade, 'NA' as typjd
      from    temploy1 emp, tcmptncy cpt, tcompskil skl
      where   emp.codempid    = r_codempid
      and     emp.numappl     = cpt.numappl
      and     cpt.codtency    = skl.codskill(+)
      and     not exists (select  1
                          from    tjobposskil jd
                          where   jd.codpos     = emp.codpos
                          and     jd.codcomp    = emp.codcomp
                          and     jd.codskill   = cpt.codtency)
      order by codskill;
--      select * from (
--          select  jd.codtency as typtency,
--                  jd.codskill,
--                  cpt.grade,
--                  jd.grade expgrade,
--                  'JD' as typjd
--          from    temploy1 emp, tjobposskil jd, tcmptncy cpt
--          where   emp.codempid    = r_codempid
--          and     emp.codcomp     = jd.codcomp
--          and     emp.codpos      = jd.codpos
--          and     emp.numappl     = cpt.numappl(+)
--          and     jd.codskill     = cpt.codtency(+)
--          union all
--          select  skl.codtency as typtency,
--                  cpt.codtency,
--                  cpt.grade,
--                  null expgrade,
--                  'NA' as typjd
--          from    temploy1 emp, tcmptncy cpt, tcompskil skl
--          where   emp.codempid    = r_codempid
--          and     emp.numappl     = cpt.numappl
--          and     cpt.codtency    = skl.codskill(+)
--          and     not exists (select  1
--                              from    tjobposskil jd
--                              where   jd.codpos     = emp.codpos
--                              and     jd.codcomp    = emp.codcomp
--                              and     jd.codskill   = cpt.codtency
--                              and     jd.codtency   = skl.codtency)
--        ) competency
--        where rownum <= nvl(v_rownum_qtymax,rownum)
--        order by typjd,typtency;

    BEGIN

        FOR i IN c_trepconfig LOOP
            if i.codinf = 'EMP0100' then
             tab1 := '1';
                --sub 1 tab 1
                begin
                    select numoffid,to_char( dteoffid, 'dd/mm/yyyy' ) as dteoffid, adrissue,
                           get_tcodec_name('TCODPROV',codprovi,global_v_lang) AS codprovi,
                           get_tclninf_name(codclnsc,global_v_lang) as codclnsc
                    into v_numoffid,v_dteoffid,v_adrissue,v_codprovi,v_codclnsc
                    from temploy1 a left join temploy2 b
                      ON a.codempid = b.codempid
                    where a.codempid = r_codempid;
                exception when others then
                    v_numoffid := null; v_dteoffid := null;
                    v_adrissue := null; v_codprovi := null;
                    v_codclnsc := null;
                end;
                --sub 2 tab 1
                begin
                    select numpasid, to_char( dtepasid, 'dd/mm/yyyy' ) as dtepasid,
                           numvisa, to_char( dtevisaexp, 'dd/mm/yyyy' ) as dtevisaexp,
                           numlicid, to_char( dtelicid, 'dd/mm/yyyy' ) as dtelicid
                    into v_numpasid,v_dtepasid,v_numvisa,
                         v_dtevisaexp,v_numlicid,v_dtelicid
                    from temploy1 a left join temploy2 b
                        ON a.codempid = b.codempid
                    where a.codempid = r_codempid;
                exception when others then
                    null;
                end;
                --sub 3 tab 1
                begin
                    select to_char( dteempdb, 'dd/mm/yyyy' ) as dteempdb,
                           get_tcodec_name('TCODPROV',coddomcl,global_v_lang) as coddomcl,
                           get_age_label ( dteempdb , sysdate ) as age,
                        case codsex
                            when 'M' then
                                get_label_name('HRPMB3E2',global_v_lang,220)
                            when 'F' then
                                get_label_name('HRPMB3E2',global_v_lang,230)
                        end as codsex,
                        high, weight, codblood, get_tcodec_name('TCODREGN',codorgin,global_v_lang) as codorgin,
                        get_tcodec_name('TCODNATN',codnatnl,global_v_lang) as codnatnl,
                        get_tcodec_name('TCODRELI',codrelgn,global_v_lang) as codrelgn,
                        get_tlistval_name('NAMMARRY', stamarry  , global_v_lang) as stamarry,
                        get_tlistval_name('NAMMILIT', stamilit  , global_v_lang) as stamilit
                    into
                        v_dteempdb,
                        v_coddomcl,
                        v_age,
                        v_codsex,
                        v_high,
                        v_weight,
                        v_codblood,
                        v_codorgin,
                        v_codnatnl,
                        v_codrelgn,
                        v_stamarry,
                        v_stamilit
                    from temploy1 a left join temploy2 b
                        ON a.codempid = b.codempid
                    where a.codempid = r_codempid;
                exception when others then
                    null;
                end;

                 --sub 4 tab 1
                begin
                    select numprmid, to_char( dteprmst, 'dd/mm/yyyy' ) as dteprmst,
                           to_char( dteprmen, 'dd/mm/yyyy' ) as dteprmen, numappl,
                           to_char( dteretire, 'dd/mm/yyyy' ) as dteretire
                    into v_numprmid,v_dteprmst,v_dteprmen,v_numappl,v_dteretire
                    from temploy1 a left join temploy2 b
                        ON a.codempid = b.codempid
                    where a.codempid = r_codempid;
                exception when others then
                    null;
                end;

        --Report insert TTEMPRPT
				INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                    ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,
                    ITEM15,ITEM16,ITEM17,ITEM18,ITEM19,
                    ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,
                    ITEM25,ITEM26,ITEM27,ITEM28,ITEM29,
                    ITEM30,ITEM31,ITEM32)
				VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB1',r_codempid,
                    v_numoffid,
                    to_char(add_months(to_date(v_dteoffid,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_adrissue,
                    v_codprovi,
                    v_codclnsc,
                    v_numpasid,
                    to_char(add_months(to_date(v_dtepasid,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_numvisa,
                    to_char(add_months(to_date(v_dtevisaexp,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_numlicid,
                    to_char(add_months(to_date(v_dtelicid,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    to_char(add_months(to_date(v_dteempdb,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_coddomcl,
                    v_age,
                    v_codsex,
                    v_high ||' '|| get_label_name('HRPM81X4',global_v_lang,3200),
                    v_weight ||' '|| get_label_name('HRPM81X4',global_v_lang,3190),
                    v_codblood,
                    v_codorgin,
                    v_codnatnl,
                    v_codrelgn,
                    v_stamarry,
                    v_stamilit,
                    v_numprmid,
                    to_char(add_months(to_date(v_dteprmst,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    to_char(add_months(to_date(v_dteprmen,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_numappl,
                    to_char(add_months(to_date(v_dteretire,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'));
              v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0200' then
                -- sub 1 tab 2
                tab2 := '1';
                str_addr := '';
                begin
                    get_addr_label(r_codempid,global_v_lang,'ADRREG',v_addr_return);
                    select
                        get_tsubdist_name(codsubdistr,global_v_lang) as codsubdistr ,
                        get_tcoddist_name(coddistr,global_v_lang) as coddistr,
                        get_tcodec_name('TCODPROV',codprovr,global_v_lang) as codprovr,
                        codpostr,
                        get_tcodec_name('TCODCNTY',codcntyr,global_v_lang) as codcntyr
                    into
                        v_codsubdistr,
                        v_coddistr,
                        v_codprovr,
                        v_codpostr,
                        v_codcntyr
                    from
                        temploy1 a left join temploy2 b
                        ON a.codempid = b.codempid
                    where
                        a.codempid = r_codempid;
                exception when others then
                    null;
                end;
                str_addr := get_label_name('HRCO01EC2',global_v_lang,160) ||' '|| v_codsubdistr ||' '|| get_label_name('HRCO01EC2',global_v_lang,150) ||' '|| v_coddistr ||' '|| v_codprovr ;
                str_addr := v_addr_return ||' '|| str_addr ||' '|| v_codpostr ||' '|| v_codcntyr;

                -- sub 2 tab 2
                str_addr_cont := '';
                begin
                    get_addr_label(r_codempid,global_v_lang,'ADRCONT',v_addc_return);
                    select
                        get_tsubdist_name(codsubdistc,global_v_lang) as codsubdistc ,
                        get_tcoddist_name(coddistc,global_v_lang) as coddistc,
                        get_tcodec_name('TCODPROV',codprovc,global_v_lang) as codprovc,
                        codpostc,
                        get_tcodec_name('TCODCNTY',codcntyc,global_v_lang) as codcntyc
                    into
                        v_codsubdistc,
                        v_coddistc,
                        v_codprovc,
                        v_codpostc,
                        v_codcntyc
                    from
                        temploy1 a left join temploy2 b
                        ON a.codempid = b.codempid
                    where
                        a.codempid = r_codempid;
                exception when others then
                    null;
                end;
                --tar1
                str_addr_cont := get_label_name('HRCO01EC2',global_v_lang,160) ||' '|| v_codsubdistc ||' '|| get_label_name('HRCO01EC2',global_v_lang,150) ||' '|| v_coddistc ||' '|| v_codprovc ;
                str_addr_cont := v_addc_return ||' '|| str_addr_cont ||' '|| v_codpostc ||' '|| v_codcntyc;

                      --Report insert TTEMPRPT
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                          ITEM5,ITEM6)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB2',r_codempid,
                          str_addr,str_addr_cont);
              v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0300' then
                -- sub 1 tab 3
                tab3 := '1';
                begin
                    select codcomp,codpos,
                        to_char(dteempmt, 'dd/mm/yyyy')as dteempmt,
                        get_age_job ( dteempmt,sysdate)as agejob,
                        get_tlistval_name('NAMESTAT',staemp,global_v_lang)as staemp,
                        to_char(dteeffex, 'dd/mm/yyyy')as dteeffex,
                        get_tcenter_name(hcm_util.get_codcomp_level(codcomp,1),global_v_lang) as codcomp,
                        codpos ||' - '|| get_tpostn_name (codpos ,global_v_lang ) as fullcodpos,
                        get_tpostn_name (codpos ,global_v_lang ) as codpos ,
                        to_char(dteefpos, 'dd/mm/yyyy')as dteefpos,
                        numlvl,
                        to_char(dteeflvl, 'dd/mm/yyyy')as dteeflvl,
                        codbrlc ||' - '||get_tcodec_name('TCODLOCA',codbrlc,global_v_lang) as codbrlc,
                        codempmt ||' - '||get_tcodec_name('TCODEMPL',codempmt,global_v_lang) as codempmt,
                        typpayroll ||' - '||get_tcodec_name('TCODTYPY',typpayroll,global_v_lang) as typpayroll,
                        typemp ||' - '||get_tcodec_name('TCODCATG',typemp,global_v_lang) as typemp,
                        codcalen ||' - '||get_tcodec_name('TCODWORK',codcalen,global_v_lang) as codcalen,
                        get_tlistval_name('NAMSTAMP', flgatten  , global_v_lang) as flgatten,
                        codjob ||' - '||get_tjobcode_name(codjob,global_v_lang) as codjob,
                        jobgrade ||' - '||get_tcodec_name('TCODJOBG',jobgrade,global_v_lang) as jobgrade,
                        codgrpgl ||' - '||get_tcodec_name('TCODGRPGL',codgrpgl,global_v_lang) as codgrpgl,
                        get_tcenter_name(hcm_util.get_codcomp_level(codcompr,1),global_v_lang) as codcompr,
                        get_tpostn_name (codposre ,global_v_lang ) as codposre ,
                        get_tlistval_name('STADISB',stadisb,global_v_lang) as stadisb,
                        numdisab,
                        to_char(dtedisb, 'dd/mm/yyyy')as dtedisb,
                        to_char(dtedisen, 'dd/mm/yyyy')as dtedisen,
                        get_tcodec_name('TCODDISP',typdisp, global_v_lang) as typdisp,
                        desdisp ,
                        ((dteduepr - dteempmt) + 1) as triwork,
                        to_char(dteduepr, 'dd/mm/yyyy') as dteduepr,
                        qtydatrq as emperiod,
                        to_char(dteoccup, 'dd/mm/yyyy') as dteoccup,
                        numtelof,
                        email,
                        numreqst
                    into
                        p_codcomp_head_3,p_codpos_head_3,
                        v_dteempmt_3,
                        v_agejob_3,
                        v_staemp_3,
                        v_dteeffex_3,
                        v_codcomp_3,
                        v_fullcodpos_3,
                        v_codpos_3,
                        v_dteefpos_3,
                        v_numlvl_3,
                        v_dteeflvl_3,
                        v_codbrlc_3,
                        v_codempmt_3,
                        v_typpayroll_3,
                        v_typemp_3,
                        v_codcalen_3,
                        v_flgatten_3,
                        v_codjob_3,
                        v_jobgrade_3,
                        v_codgrpgl_3,
                        v_codcompr_3,
                        v_codposre_3,
                        v_stadisb_3,
                        v_numdisab_3,
                        v_dtedisb_3,
                        v_dtedisen_3,
                        v_typdisp_3,
                        v_desdisp_3,
                        v_triwork_3,
                        v_dteduepr_3,
                        v_emperiod_3,
                        v_dteoccup_3,
                        v_numtelof_3,
                        v_email_3,
                        v_numreqst_3
                    from temploy1
                    where codempid = r_codempid;
                exception when others then
                    null;
                end;

                get_temphead(r_codempid,p_codcomp_head_3,p_codpos_head_3,
                p_codcomph_head_3,p_codposh_head_3 ,p_codempidh_head_3 ,p_stapost_head_3);

                if nvl(p_stapost_head_3,'0') = '0' then
                  v_temphead_pos_3 :=  get_label_name('HRPM4DE1',global_v_lang,140);
                elsif p_stapost_head_3 = '1' then
                  v_temphead_pos_3 :=  get_label_name('HRPM4DE2',global_v_lang,390);
                elsif p_stapost_head_3 = '2' then
                  v_temphead_pos_3 :=  get_label_name('HRPM4DE2',global_v_lang,400);
                end if;

                v_temphead_3 := get_temploy_name(p_codempidh_head_3,global_v_lang);
                v_codcompr_3 := get_tcenter_name(p_codcomph_head_3,global_v_lang);
                v_codposre_3 := get_tpostn_name (p_codposh_head_3,global_v_lang );
                --v_temphead_pos_3 := '';
                      --Report insert TTEMPRPT
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                          ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                          ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,
                          ITEM15,ITEM16,ITEM17,ITEM18,ITEM19,
                          ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,
                          ITEM25,ITEM26,ITEM27,ITEM28,ITEM29,
                          ITEM30,ITEM31,ITEM32,ITEM33,ITEM34,
                          ITEM35,ITEM36,ITEM37,ITEM38,ITEM39,
                          ITEM40)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB3',r_codempid,
                          to_char(add_months(to_date(v_dteempmt_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_agejob_3,
                          v_staemp_3,
                          to_char(add_months(to_date(v_dteeffex_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_codcomp_3,
                          v_fullcodpos_3,
                          v_codpos_3,
                          to_char(add_months(to_date(v_dteefpos_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_numlvl_3,
                          to_char(add_months(to_date(v_dteeflvl_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_codbrlc_3,
                          v_codempmt_3,
                          v_typpayroll_3,
                          v_typemp_3,
                          v_codcalen_3,
                          v_flgatten_3,
                          v_codjob_3,
                          v_jobgrade_3,
                          v_codgrpgl_3,
                          v_codcompr_3,
                          v_codposre_3,
                          v_temphead_3,
                          v_temphead_pos_3,
                          v_stadisb_3,
                          v_numdisab_3,
                          to_char(add_months(to_date(v_dtedisb_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          to_char(add_months(to_date(v_dtedisen_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_typdisp_3,
                          v_desdisp_3,
                          v_triwork_3||' '||get_label_name('HRPM93X2',global_v_lang,260),
                          to_char(add_months(to_date(v_dteduepr_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          trunc(v_emperiod_3 / 12) || ' '|| get_label_name('HRPMC2E1T1',global_v_lang,270) || ' ' ||mod(v_emperiod_3,12)|| ' '|| get_label_name('HRPMC2E1T1',global_v_lang,280),
                          to_char(add_months(to_date(v_dteoccup_3,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_numtelof_3,
                          v_email_3,
                          v_numreqst_3);
                          v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0400' then
                -- tab 4
                tab4 := '1';
                begin
                    select ocodempid,
                         to_char(dtereemp, 'dd/mm/yyyy')as dtereemp,
                         (dteredue - dtereemp) + 1  as triwork,
                         to_char(dteredue, 'dd/mm/yyyy')as dteduepr,
                         get_tlistval_name('FLGPDPA',flgpdpa,global_v_lang) as flgpdpa,
                         dtepdpa
                    into
                        v_ocodempid_4,
                        v_dtereemp_4,
                        v_triwork_4,
                        v_dteduepr_4,
                        v_flgpdpa_4,
                        v_dtepdpa_4
                    from temploy1
                    where  codempid = r_codempid;
                exception when others then
                    null;
                end;

                      --Report insert TTEMPRPT
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                          ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB4',r_codempid,
                          v_ocodempid_4,
                          to_char(add_months(to_date(v_dtereemp_4,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_triwork_4||' '||get_label_name('HRPM93X2',global_v_lang,260),
                          to_char(add_months(to_date(v_dteduepr_4,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_flgpdpa_4,to_char(add_months(v_dtepdpa_4,numYearReport*12),'dd/mm/yyyy'));
                          v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0500' then
                -- tab 5
                tab5 := '1';
                begin
                    select
                        get_tlistval_name('TYPTRAV',typtrav,global_v_lang) as typtrav,
                        carlicen,
                        qtylength,
                        get_tcodec_name('TCODBUSNO',codbusno,global_v_lang) as codbusno,
                        get_tcodec_name('TCODBUSRT',codbusrt,global_v_lang) as codbusrt
                    into
                        v_typtrav_5,
                        v_carlicen_5,
                        v_qtylength_5,
                        v_codbusno_5,
                        v_codbusrt_5
                    from temploy1
                    where codempid = r_codempid;
                exception when others then
                    null;
                end;

              --Report insert TTEMPRPT
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                          ITEM5,ITEM6,ITEM7,ITEM8,ITEM9)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB5',r_codempid,
                          v_typtrav_5,
                          v_carlicen_5,
                          v_qtylength_5 ||' '|| get_label_name('HRPM81X4',global_v_lang,3210),
                          v_codbusno_5,
                          v_codbusrt_5);
                          v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0600' then
                -- tab 6
                tab6 := '1';

                begin

                      select  emp1.codempid,emp1.codempmt,emp1.codcomp,
                              stddec(amtincom1,emp1.codempid,global_v_chken),
                              stddec(amtincom2,emp1.codempid,global_v_chken),
                              stddec(amtincom3,emp1.codempid,global_v_chken),
                              stddec(amtincom4,emp1.codempid,global_v_chken),
                              stddec(amtincom5,emp1.codempid,global_v_chken),
                              stddec(amtincom6,emp1.codempid,global_v_chken),
                              stddec(amtincom7,emp1.codempid,global_v_chken),
                              stddec(amtincom8,emp1.codempid,global_v_chken),
                              stddec(amtincom9,emp1.codempid,global_v_chken),
                              stddec(amtincom10,emp1.codempid,global_v_chken),
                              stddec(AMTPROADJ,emp1.codempid,global_v_chken)
                      into    v_codempid, v_codempmt, v_codcomp,
                              v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                              v_amtproadj_6
                      from    temploy1 emp1, temploy3 emp3
                      where   emp1.codempid   = r_codempid
                      and     emp1.codempid   = emp3.codempid;

                exception when no_data_found then
                  v_amtincom(1)   := 0;
                  v_amtincom(2)   := 0;
                  v_amtincom(3)   := 0;
                  v_amtincom(4)   := 0;
                  v_amtincom(5)   := 0;
                  v_amtincom(6)   := 0;
                  v_amtincom(7)   := 0;
                  v_amtincom(8)   := 0;
                  v_amtincom(9)   := 0;
                  v_amtincom(10)  := 0;
                end;

                for i in 1..10 loop
                  v_amtincom(i)   := greatest(0, v_amtincom(i));
                end loop;

                begin
                  select  codcompy
                  into    v_codcompy
                  from    tcenter
                  where   codcomp = v_codcomp;
                exception when no_data_found then
                  v_codcompy  := null;
                end;
                v_json_input      := '{"p_codcompy":"'||v_codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||v_codempmt||'","p_lang":"'||global_v_lang||'"}';

                v_json_codincom   := hcm_pm.get_codincom(v_json_input);
                param_json        := json_object_t(v_json_codincom);

                for i in 0..param_json.get_size-1 loop
                  param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
                  v_codincom          := hcm_util.get_string_t(param_json_row,'codincom');
                  v_desincom          := hcm_util.get_string_t(param_json_row,'desincom');
                  v_desunit           := hcm_util.get_string_t(param_json_row,'desunit');
                  v_amtmax            := hcm_util.get_string_t(param_json_row,'amtmax');
                  v_row       := v_row + 1;


                  if permision_salary then
                       if global_v_zupdsal = 'Y' then
                              if v_codincom is not null then
                                     --Report insert TTEMPRPT
                                    INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7)
                                    VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6',r_codempid,
                                        v_desincom,
                                        v_desunit,
                                        v_amtincom(v_row));
                                        v_numseq := v_numseq + 1;
                              else
                                     --Report insert TTEMPRPT
                                    INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7)
                                    VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6',r_codempid,
                                        v_desincom,
                                        v_desunit,
                                        '');
                                        v_numseq := v_numseq + 1;
                              end if;
                        else
                            -- insert datablank case no permision check salary
                            --Report insert TTEMPRPT
                            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                ITEM5,ITEM6,ITEM7)
                            VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6',r_codempid,
                                '',
                                '',
                                '');
                                v_numseq := v_numseq + 1;
                        end if;
                  else
                            -- insert datablank case no permision check salary
                            --Report insert TTEMPRPT
                            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                ITEM5,ITEM6,ITEM7)
                            VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6',r_codempid,
                                '',
                                '',
                                '');
                                v_numseq := v_numseq + 1;
                  end if;
                end loop;

                -- income
                GET_WAGE_INCOME( v_codcompy, v_codempmt,
                v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                v_amtothr_income, v_amtday_income, v_sumincom_income);

                if permision_salary then
                    if global_v_zupdsal = 'Y' then
                        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8)
                        VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6_DETAIL',r_codempid,
                            v_amtproadj_6,
                            v_amtothr_income,
                            v_amtday_income,
                            v_sumincom_income);
                            v_numseq := v_numseq + 1;
                    else
                        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8)
                        VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6_DETAIL',r_codempid,
                            '',
                            '',
                            '',
                            '');
                            v_numseq := v_numseq + 1;
                    end if;
                else
                     INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8)
                        VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB6_DETAIL',r_codempid,
                            '',
                            '',
                            '',
                            '');
                            v_numseq := v_numseq + 1;
                end if;

             else if i.codinf = 'EMP0700' then
                -- tab 7
                tab7 := '1';
                begin
                    select numtaxid,numsaid,
                        get_tlistval_name('FLGTAX',flgtax,global_v_lang)as flgtax,
                        get_tlistval_name('NAMTAXDD',typtax,global_v_lang) typtax,
                        get_tlistval_name('TYPINCOM',typtax,global_v_lang)as  typincom ,
                        dteyrrelf,dteyrrelt,
                        STDDEC(amtrelas,codempid,global_v_chken) as amtrelas,
                        STDDEC(amttaxrel,codempid,global_v_chken) as amttaxrel
                    into
                        v_numtaxid_7,
                        v_numsaid_7,
                        v_flgtax_7,
                        v_typtax_7,
                        v_typincom_7,
                        v_dteyrrelf_7,
                        v_dteyrrelt_7,
                        v_amtrelas_7,
                        v_amttaxrel_7
                    from temploy3
                    where codempid = r_codempid;
                exception when others then
                    null;
                end;

                begin
                   select to_char(frsmemb, 'dd/mm/yyyy') as frsmemb into v_dtecontri_7
                   from   tssmemb
                   where  codempid = r_codempid;
                exception when no_data_found then
                    v_dtecontri_7 := null;
                end;

                -- รอพี่บอกตอบว่า  เอาจากฟิลไหน
                 --   v_dtecontri_7 := '';
                --Report insert TTEMPRPT
				INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                    ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
				VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB7',r_codempid,
                    v_numtaxid_7,
                    v_numsaid_7,
                    to_char(add_months(to_date(v_dtecontri_7,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_flgtax_7,
                    v_typtax_7,
                    v_typincom_7,
                    v_dteyrrelf_7,
                    v_dteyrrelt_7,
                    v_amtrelas_7,
                    v_amttaxrel_7);
                    v_numseq := v_numseq + 1;

             else if i.codinf = 'EMP0800' then
                -- tab 8
                tab8 := '1';
                begin
                     select
                         get_tcodec_name('TCODBANK',codbank,global_v_lang) as codbank,
                         numbank,
                         numbrnch,
                         amtbank,
                         STDDEC(amttranb,codempid,global_v_chken)as amttranb,
                         get_tcodec_name('TCODBANK',codbank2,global_v_lang) as codbank2,
                         numbank2,
                         numbrnch2,
                         get_tlistval_name('FLGSLIP',flgslip,global_v_lang)
                    into
                         v_codbank_8,
                         v_numbank_8,
                         v_numbrnch_8,
                         v_amtbank_8,
                         v_amttranb_8,
                         v_codbank2_8,
                         v_numbank2_8,
                         v_numbrnch2_8,
                         v_flgslip_8
                    from temploy3
                    where codempid = r_codempid;
                exception when others then
                    null;
                end;
                if v_amttranb_8 <= 0 then
                  v_amttranb_8 := '';
                end if;
                --Report insert TTEMPRPT
				INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                    ITEM10,ITEM11,ITEM12,ITEM13)
				VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB8',r_codempid,
                    v_codbank_8, v_numbank_8, v_numbrnch_8, v_amtbank_8, v_amttranb_8,
                    v_codbank2_8, v_numbank2_8, v_numbrnch2_8, v_flgslip_8 );
                    v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP0900' then
                -- tab 9
                tab9 := '1';
                begin
                    select
                        to_char(dtebf, 'dd/mm/yyyy')as dtebf,
                        STDDEC(amtincbf,codempid,global_v_chken) as amtincbf,
                        STDDEC(amttaxbf,codempid,global_v_chken) as amttaxbf,
                        STDDEC(amtpf,codempid,global_v_chken) as amtpf,
                        STDDEC(amtsaid,codempid,global_v_chken) as amtsaid
                    into
                       v_dtebf_9,
                       v_amtincbf_9,
                       v_amttaxbf_9,
                       v_amtpf_9,
                       v_amtsaid_9
                    from temploy3
                    where codempid = r_codempid;
                exception when others then
                    null;
                end;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8,ITEM9)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB9',r_codempid,
                    to_char(add_months(to_date(v_dtebf_9,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_amtincbf_9,
                    v_amttaxbf_9,
                    v_amtpf_9,
                    v_amtsaid_9);
                    v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP1100' then
                -- tab 10
                tab10 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement := 'select a.coddeduct as coddeduct,
                                               get_tcodeduct_name(a.coddeduct,'||global_v_lang||') as descdeduct,
                                               stddec(b.amtdeduct,b.codempid,'||global_v_chken||') as amtdeduct
                                        from   tdeductd a,tempded b
                                        where  typdeduct = '''||'E'||''' and a.coddeduct <> '''||'E001'||'''
                                        and  a.coddeduct = b.coddeduct
                                        and  codempid   = '''||r_codempid||'''
                                        and  a.codcompy   = '''||r_codcomp||'''
                                        and  dteyreff = (select max(dteyreff )
                                                           from tdeductd
                                                          where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                            and codcompy = '''||r_codcomp||''''||')'||'
                                        order by a.coddeduct';
                open hrpm81xtab10_cv for v_sql_statement;
                loop

                fetch hrpm81xtab10_cv into v_coddeduct_10,v_descdeduct_10,v_amtdeduct_10;
                exit when hrpm81xtab10_cv%notfound;
                   --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                      ITEM5,ITEM6,ITEM7)
                    VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB10',r_codempid,
                            v_coddeduct_10,
                            v_descdeduct_10,
                            v_amtdeduct_10);
                    v_numseq := v_numseq + 1;
                    tab10_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;

                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                      ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB10_DETAIL',r_codempid,
                        tab10_detail);
                v_numseq := v_numseq + 1;

            else if i.codinf = 'EMP1000' then
                -- tab 11
                tab11 := '1';

                begin
                    v_sql_statement := '';
                    v_sql_statement := 'select a.coddeduct,
                                               get_tcodeduct_name(a.coddeduct,'||global_v_lang||'),
                                               stddec(b.amtdeduct,b.codempid,'||global_v_chken||') amtdeduct
                                        from tdeductd a,tempded b
                                        where  typdeduct = '''||'D'||'''  and a.coddeduct not in ( '''||'D001'||''','''||'D002'||''')
                                        and    a.coddeduct = b.coddeduct
                                        and    b.codempid   = '''||r_codempid||'''
                                        and    a.codcompy   = '''||r_codcomp||'''
                                        and  dteyreff = (select max(dteyreff )
                                                           from tdeductd
                                                          where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                            and codcompy = '''||r_codcomp||''''||')'||'
                                        order by a.coddeduct';
--                      and    stddec(b.amtdeduct,b.codempid,'||global_v_chken||') > 0
                open hrpm81xtab11_cv for v_sql_statement;
                loop

                fetch hrpm81xtab11_cv into v_coddeduct_11,v_descdeduct_11,v_amtdeduct_11;
                exit when hrpm81xtab11_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7)
                       VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB11',r_codempid,
                               v_coddeduct_11, v_descdeduct_11, v_amtdeduct_11);
                               v_numseq := v_numseq + 1;
                  tab11_detail := '1';
                 end loop;
                  begin
                  select qtychldb, qtychlda, qtychldd, qtychldi
                    into v_qtychldb_11, v_qtychlda_11, v_qtychldd_11, v_qtychldi_11
                    from temploy3
                   where codempid = r_codempid;
                  exception when no_data_found then
                    v_qtychldb_11 := '';
                  end;
                  begin
                   select defaultval into v_amtchldb_11
                     from tsetdeflt
                    where codapp = 'HRPMC2E'
                      and numpage = 'HRPMC2E164'
                      and fieldname = 'AMTCHLDB';
                  exception when no_data_found then
                    v_amtchldb_11 := '';
                  end;
                  begin
                   select defaultval into v_amtchlda_11
                     from tsetdeflt
                    where codapp = 'HRPMC2E'
                      and numpage = 'HRPMC2E164'
                      and fieldname = 'AMTCHLDA';
                  exception when no_data_found then
                    v_amtchlda_11 := '';
                  end;
                  begin
                   select defaultval into v_amtchldd_11
                     from tsetdeflt
                    where codapp = 'HRPMC2E'
                      and numpage = 'HRPMC2E164'
                      and fieldname = 'AMTCHLDD';
                  exception when no_data_found then
                    v_amtchldd_11 := '';
                  end;
                  begin
                   select defaultval into v_amtchldi_11
                     from tsetdeflt
                    where codapp = 'HRPMC2E'
                      and numpage = 'HRPMC2E164'
                      and fieldname = 'AMTCHLDI';
                  exception when no_data_found then
                    v_amtchldi_11 := '';
                  end;
                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7,
                                        ITEM8,ITEM9,ITEM10,
                                        ITEM11,ITEM12,ITEM13)
                       VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB11_DETAIL',r_codempid,
                               v_qtychldb_11, v_qtychlda_11, v_qtychldd_11,
                               trim(to_char(v_amtchldb_11,'999,999,990.00')),trim(to_char(v_amtchlda_11,'999,999,990.00')),trim(to_char(v_amtchldd_11,'999,999,990.00')),
                               v_qtychldi_11,trim(to_char(v_amtchldi_11,'999,999,990.00')),tab11_detail);
                               v_numseq := v_numseq + 1;
                exception when others then
                  null;
                end;

            else if i.codinf = 'EMP1300' then
                -- tab 12
                tab12 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='select a.coddeduct,
                                              get_tcodeduct_name(a.coddeduct,'||global_v_lang||'),
                                              stddec(b.amtdeduct,b.codempid,'||global_v_chken||') amtdeduct
                                          from   tdeductd a,tempded b
                                          where  typdeduct = '''||'O'||'''
                                          and    a.coddeduct = b.coddeduct
                                          and    codempid   = '''||r_codempid||'''
                                          and    a.codcompy = '''||r_codcomp||'''
                                          and    dteyreff = (select max(dteyreff )
                                                               from tdeductd
                                                              where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                                and codcompy = '''||r_codcomp||''''||')'||'
                                          order by a.coddeduct';
--                                          and    stddec(b.amtdeduct,b.codempid,'||global_v_chken||') > 0
                open hrpm81xtab12_cv for v_sql_statement;
                loop

                fetch hrpm81xtab12_cv into v_coddeduct_12,v_descdeduct_12,v_amtdeduct_12;
                exit when hrpm81xtab12_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7)
                       VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB12',r_codempid,
                               v_coddeduct_12,
                               v_descdeduct_12,
                               v_amtdeduct_12);
                   v_numseq := v_numseq + 1;
                   tab12_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB12_DETAIL',r_codempid,
                      tab12_detail);
                v_numseq := v_numseq + 1;
           else if i.codinf = 'EMP1400' then
                -- tab 13
                tab13 := '1';
                begin
                    select
                        (select numtaxid from  TSPOUSE where codempid = r_codempid) as numtaxid,
                        to_char(dtebfsp, 'dd/mm/yyyy') as dtebfsp,
                        stddec(amtincsp,codempid,global_v_chken) as amtincsp,
                        stddec(amttaxsp,codempid,global_v_chken) as amttaxsp,
                        stddec(amtsasp,codempid,global_v_chken) as amtsasp,
                        stddec(amtpfsp,codempid,global_v_chken) as amtpfsp
                    into
                        v_numtaxid_13,
                        v_dtebfsp_13,
                        v_amtincsp_13,
                        v_amttaxsp_13,
                        v_amtsasp_13,
                        v_amtpfsp_13
                    from temploy3
                    where codempid = r_codempid;
                    tab13_detail := '1';
                exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB13_DETAIL',r_codempid,
                      tab13_detail);
                v_numseq := v_numseq + 1;
                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB13',r_codempid,
                    v_numtaxid_13,
                    to_char(add_months(to_date(v_dtebfsp_13,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_amtincsp_13,
                    v_amttaxsp_13,
                    v_amtpfsp_13,
                    v_amtsasp_13);
                    v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP1500' then
                -- tab 14
                tab14 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement := 'select a.coddeduct,
                                               get_tcodeduct_name(a.coddeduct,'||global_v_lang||'),
                                               stddec(b.amtspded,b.codempid,'||global_v_chken||') amtdeduct
                                        from   tdeductd a,tempded b
                                        where  typdeduct = '''||'E'||''' and a.coddeduct <> '''||'E001'||'''
                                        and    a.coddeduct = b.coddeduct
                                        and    codempid   = '''||r_codempid||'''
                                        and    a.codcompy = '''||r_codcomp||'''
                                        and    dteyreff = (select max(dteyreff )
                                                             from tdeductd
                                                            where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                              and codcompy = '''||r_codcomp||''''||')'||'
                                        order by a.coddeduct';
--                        and    stddec(b.amtspded,b.codempid,'||global_v_chken||') > 0
                open hrpm81xtab14_cv for v_sql_statement;
                loop

                fetch hrpm81xtab14_cv into v_coddeduct_14,v_descdeduct_14,v_amtdeduct_14;
                exit when hrpm81xtab14_cv%notfound;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB14',r_codempid,
                    v_coddeduct_14,
                    v_descdeduct_14,
                    v_amtdeduct_14);
                    v_numseq := v_numseq + 1;
                    tab14_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB14_DETAIL',r_codempid,
                      tab14_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP1600' then
                -- tab 15
                tab15 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement := 'select a.coddeduct,
                                                get_tcodeduct_name(a.coddeduct,'||global_v_lang||'),
                                                stddec(b.amtspded,b.codempid,'||global_v_chken||') amtdeduct
                                        from   tdeductd a,tempded b
                                        where  typdeduct = '''||'D'||'''  and a.coddeduct not in ( '''||'D001'||''','''||'D002'||''')
                                        and    a.coddeduct = b.coddeduct
                                        and    codempid   = '''||r_codempid||'''
                                        and    a.codcompy = '''||r_codcomp||'''
                                        and    dteyreff = (select max(dteyreff )
                                                             from tdeductd
                                                            where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                              and codcompy = '''||r_codcomp||''''||')'||'
                                        order by a.coddeduct';
--                        and    stddec(b.amtspded,b.codempid,'||global_v_chken||') > 0
                open hrpm81xtab15_cv for v_sql_statement;
                loop

                fetch hrpm81xtab15_cv into v_coddeduct_15,v_descdeduct_15,v_amtdeduct_15;
                exit when hrpm81xtab15_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7)
                       VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB15',r_codempid,
                                v_coddeduct_15, v_descdeduct_15, v_amtdeduct_15);
                    v_numseq := v_numseq + 1;
                    tab15_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB15_DETAIL',r_codempid,
                      tab15_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP1700' then
                -- tab 16
                tab16 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement := 'select a.coddeduct,
                                               get_tcodeduct_name(a.coddeduct,'||global_v_lang||'),
                                               stddec(b.amtspded,b.codempid,'||global_v_chken||') amtdeduct
                                        from   tdeductd a,tempded b
                                        where  typdeduct = '''||'O'||'''
                                        and    a.coddeduct = b.coddeduct
                                        and    codempid   = '''||r_codempid||'''
                                        and    a.codcompy = '''||r_codcomp||'''
                                        and    stddec(b.amtspded,b.codempid,'||global_v_chken||') > 0
                                        and    dteyreff = (select max(dteyreff )
                                                             from tdeductd
                                                            where dteyreff <= to_number(to_char(sysdate,'''||'yyyy'||''')) - '||global_v_zyear||'
                                                              and codcompy = '''||r_codcomp||''''||')'||'
                                        order by a.coddeduct';

                open hrpm81xtab16_cv for v_sql_statement;
                loop

                fetch hrpm81xtab16_cv into v_coddeduct_16,v_descdeduct_16,v_amtdeduct_16;
                exit when hrpm81xtab16_cv%notfound;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB16',r_codempid,
                    v_coddeduct_16,
                    v_descdeduct_16,
                    v_amtdeduct_16);
                    v_numseq := v_numseq + 1;
                    tab16_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB16_DETAIL',r_codempid,
                      tab16_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP1800' then
                -- tab 17
                tab17 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='select dtechg, get_tlistval_name('''||'CODTITLE'||''',codtitle,'||global_v_lang||') as codtitle,
                                              decode('||global_v_lang||','''||'101'||''', namfirste ,
                                              '''||'102'||''', namfirstt,
                                              '''||'103'||''', namfirst3,
                                              '''||'104'||''', namfirst4,
                                              '''||'105'||''', namfirst5) namfirst,
                                              decode('||global_v_lang||','''||'101'||''', namlaste ,
                                              '''||'102'||''', namlastt,
                                              '''||'103'||''', namlast3,
                                              '''||'104'||''', namlast4,
                                              '''||'105'||''', namlast5) namlast,
                                              deschang
                                          from thisname
                                          where codempid= '''||r_codempid||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                          order by dtechg desc';
--                    and ROWNUM <= '''||i.QTYMAX||'''
                open hrpm81xtab17_cv for v_sql_statement;
                loop

                fetch hrpm81xtab17_cv into v_dtechg_17,v_codtitle_17,v_namfirst_17,v_namlast_17,v_deschang_17;
                exit when hrpm81xtab17_cv%notfound;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB17',r_codempid,
                    to_char(add_months(v_dtechg_17,numYearReport*12),'dd/mm/yyyy'),
                    v_codtitle_17,
                    v_namfirst_17,
                    v_namlast_17,
                    v_deschang_17);
                    v_numseq := v_numseq + 1;
                    tab17_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB17_DETAIL',r_codempid,
                      tab17_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP1900' then
                -- tab 18
                tab18 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='select get_tcodec_name('''||'TCODTYDOC'||''',a.typdoc,'||global_v_lang||') as typdoc,
                                              a.namdoc,
                                              to_char(a.dterecv, '''||'dd/mm/yyyy'||''') as dterecv,
                                              to_char(a.dtedocen, '''||'dd/mm/yyyy'||''') as dtedocen,
                                              a.numdoc,a.filedoc
                                              from tappldoc a,temploy1 b
                                          where a.numappl = b.numappl
                                          and b.codempid ='''||r_codempid||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                          order by numseq';
                open hrpm81xtab18_cv for v_sql_statement;
                loop

                fetch hrpm81xtab18_cv into v_typdoc_18,v_namdoc_18,v_dterecv_18,v_dtedocen_18,v_numdoc_18,v_filedoc_18;
                exit when hrpm81xtab18_cv%notfound;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB18',r_codempid,
                    v_typdoc_18,
                    v_namdoc_18,
                    to_char(add_months(to_date(v_dterecv_18,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    to_char(add_months(to_date(v_dtedocen_18,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_numdoc_18,
                    v_filedoc_18);
                    v_numseq := v_numseq + 1;
                    tab18_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB18_DETAIL',r_codempid,
                      tab18_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP2000' then
                -- tab 19
                tab19 := '1';
                begin
                    v_numappl   := get_numappl(r_codempid);
                    v_sql_statement := '';
                    v_rcnt_19 := 0;
                    v_sql_statement :='select stayear + HCM_APPSETTINGS.get_additional_year() as stayear,
                                              dtegyear + HCM_APPSETTINGS.get_additional_year() as dtegyear,
                                              get_tcodec_name('''||'TCODEDUC'||''',codedlv,'||global_v_lang||') as codedlv ,
                                              get_tcodec_name('''||'TCODDGEE'||''',coddglv,'||global_v_lang||') as coddglv,
                                              get_tcodec_name('''||'TCODMAJR'||''',codmajsb,'||global_v_lang||') as codmajsb ,
                                              get_tcodec_name('''||'TCODINST'||''',codinst,'||global_v_lang||') as codinst,
                                              get_tcodec_name('''||'TCODCNTY'||''',codcount,'||global_v_lang||') as codcount,
                                              numgpa
                                         from teducatn
                                        where numappl = '''||v_numappl||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                        order by dtegyear desc';
--                                        where codempid = '''||r_codempid||'''
                open hrpm81xtab19_cv for v_sql_statement;
                loop

                fetch hrpm81xtab19_cv into v_stayear_19,v_dtegyear_19,v_codedlv_19,v_coddglv_19,v_codmajsb_19,v_codinst_19,v_codcount_19,v_numgpa_19;
                exit when hrpm81xtab19_cv%notfound;


                --Report insert TTEMPRPT
                v_rcnt_19 := v_rcnt_19 + 1;
                tab19_detail := '1';
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB19',r_codempid,v_rcnt_19,
                    v_stayear_19 ||' - '|| v_dtegyear_19,
                    v_codedlv_19,
                    v_coddglv_19,
                    v_codmajsb_19,
                    v_codinst_19,
                    v_codcount_19,
                    v_numgpa_19,
                    tab19_detail);
                    v_numseq := v_numseq + 1;
                 end loop;

                 exception when others then
                    null;
                end;

            else if i.codinf = 'EMP2100' then
                -- tab 20
                tab20 := '1';
                begin
                    v_sql_statement := '';
                    v_rcnt_20 := 0;
                    v_sql_statement :='select
                                to_char(dtestart, '''||'dd/mm/yyyy'||''')as dtestart,
                                to_char(dteend, '''||'dd/mm/yyyy'||''') as dteend,
                                desnoffi,deslstpos
                            from tapplwex
                            where codempid = '''||r_codempid||'''
                            and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                            order by dteend desc';
                open hrpm81xtab20_cv for v_sql_statement;
                loop

                fetch hrpm81xtab20_cv into v_dtestart_20,v_dteend_20,v_desnoffi_20,v_deslstpos_20;
                exit when hrpm81xtab20_cv%notfound;

                --Report insert TTEMPRPT
                v_rcnt_20 := v_rcnt_20 + 1;
                tab20_detail := '1';
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                                      ITEM5,ITEM6,ITEM7,ITEM8)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB20',r_codempid,v_rcnt_20,
                    to_char(add_months(to_date(v_dtestart_20,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy')||' - '||to_char(add_months(to_date(v_dteend_20,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_desnoffi_20, v_deslstpos_20,tab20_detail);
                    v_numseq := v_numseq + 1;
                 end loop;

                 exception when others then
                    null;
                end;
            else if i.codinf = 'EMP2200' then
                -- tab 21
                tab21 := '1';
                begin
                    v_sql_statement := '';
                    v_rcnt_21 := 0;
                    v_sql_statement :='select dtetrain, dtetren,
                                              destrain,desplace,desinstu
                                         from ttrainbf
                                        where codempid = '''||r_codempid||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                        order by dtetren desc';

                open hrpm81xtab21_cv for v_sql_statement;
                loop

                fetch hrpm81xtab21_cv into v_dtetrain_21,v_dtetren_21,v_destrain_21,v_desplace_21,v_desinstu_21;
                exit when hrpm81xtab21_cv%notfound;

                --Report insert TTEMPRPT
                v_rcnt_21 := v_rcnt_21 + 1;
                tab21_detail := '1';
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB21',r_codempid,v_rcnt_21,
                    to_char(add_months(v_dtetrain_21,numYearReport*12),'dd/mm/yyyy')||' - '||to_char(add_months(v_dtetren_21,numYearReport*12),'dd/mm/yyyy'),
                    v_destrain_21,
                    v_desplace_21,
                    v_desinstu_21,
                    tab21_detail);
                    v_numseq := v_numseq + 1;
                 end loop;

                 exception when others then
                    null;
                end;

            else if i.codinf = 'EMP2300' then
                -- tab 22
                tab22 := '1';
                begin
                    v_sql_statement := '';
                    v_rcnt_22 := 0;
                    v_sql_statement :='select dtetrst, dtetren,
                                              get_tcourse_name(codcours,'||global_v_lang||') as descours,codcours,
                                              TRIM(to_char(amtcost,'''||'999,999,999,990.00'||''')) as amttrexp,
                                              qtytrmin as qtytrhur
                                         from thistrnn
                                        where codempid = '''||r_codempid||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                        order by dtetren desc';
                open hrpm81xtab22_cv for v_sql_statement;
                loop

                fetch hrpm81xtab22_cv into v_dtetrst_22,v_dtetren_22,v_descours_22,v_codcours_22,v_amttrexp_22,v_qtytrhur_22;
                exit when hrpm81xtab22_cv%notfound;

                --Report insert TTEMPRPT
                v_rcnt_22 := v_rcnt_22 + 1;
                tab22_detail := '1';
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                                      ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB22',r_codempid,v_rcnt_22,
                    to_char(add_months(v_dtetrst_22,numYearReport*12),'dd/mm/yyyy')||' - '||to_char(add_months(v_dtetren_22,numYearReport*12),'dd/mm/yyyy'),
                    v_descours_22,
                    v_codcours_22,
                    v_amttrexp_22,
                    get_format_hhmm(v_qtytrhur_22),
                    tab22_detail);
                    v_numseq := v_numseq + 1;
                 end loop;

                 exception when others then
                    null;
                end;

            else if i.codinf = 'EMP2400' then
                -- tab 23
                tab23 := '1';
                begin
                    select
                        codempidsp,
                        decode(global_v_lang,
                            '101', namspe ,
                            '102', namspt,
                            '103', namsp3,
                            '104', namsp4,
                            '105', namsp5) fullname,
                        numoffid,
                        to_char(dtespbd, 'dd/mm/yyyy') as dtespbd,
                        case stalife
                            when 'N' then
                                get_label_name('HRPM81X4',global_v_lang,3070)
                            when 'Y' then
                                get_label_name('HRPM81X4',global_v_lang,3060)
                        end as stalife,
                        case staincom
                            when 'N' then
                                get_label_name('HRPM81X4',global_v_lang,3090)
                            when 'Y' then
                                get_label_name('HRPM81X4',global_v_lang,3080)
                        end as staincom,
                        desnoffi,
                        get_tcodec_name('TCODOCCU',codspocc,global_v_lang) as codspocc,
                        numfasp,
                        nummosp,
                        to_char(dtemarry, 'dd/mm/yyyy') as dtemarry,
                        get_tcodec_name('TCODPROV',codsppro,global_v_lang) as codsppro,
                        get_tcodec_name('TCODCNTY',codspcty,global_v_lang) as codspcty,
                        desplreg,
                        desnote
                    into
                        v_codempidsp_23,
                        v_fullname_23,
                        v_numoffid_23,
                        v_dtespbd_23,
                        v_stalife_23,
                        v_staincom_23,
                        v_desnoffi_23,
                        v_codspocc_23,
                        v_numfasp_23,
                        v_nummosp_23,
                        v_dtemarry_23,
                        v_codsppro_23,
                        v_codspcty_23,
                        v_desplreg_23,
                        v_desnote_23
                    from tspouse
                    where codempid = r_codempid;
                    tab23_detail := '1';
                exception when others then
                    null;
                end;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                            ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,
                            ITEM15,ITEM16,ITEM17,ITEM18,ITEM19)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB23',r_codempid,
                            v_codempidsp_23,
                            v_fullname_23,
                            v_numoffid_23,
                            to_char(add_months(to_date(v_dtespbd_23,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                            v_stalife_23,
                            v_staincom_23,
                            v_desnoffi_23,
                            v_codspocc_23,
                            v_numfasp_23,
                            v_nummosp_23,
                            to_char(add_months(to_date(v_dtemarry_23,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                            v_codsppro_23,
                            v_codspcty_23,
                            v_desplreg_23,
                            v_desnote_23);
                            v_numseq := v_numseq + 1;
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB23_DETAIL',r_codempid,
                      tab23_detail);
              v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP2500' then
                -- tab 24
                tab24 := '1';
                begin
                    v_sql_statement := '';
                    v_rcnt_24 := 0;
                    v_sql_statement :='select
                            numseq,
                            decode('||global_v_lang||',
                                '''||'101'||''', namche ,
                                '''||'102'||''', namcht,
                                '''||'103'||''', namch3,
                                '''||'104'||''', namch4,
                                '''||'105'||''', namch5) fullname,
                            numoffid,
                            to_char(dtechbd, '''||'dd/mm/yyyy'||''') as dtechbd,
                            case codsex
                                when '''||'F'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3110)
                                when '''||'M'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3100)
                            end as codsex,
                            case flgedlv
                                when '''||'N'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3150)
                                when '''||'Y'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3140)
                            end as flgedlv,
                            case flgdeduct
                                when '''||'N'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3130)
                                when '''||'Y'||''' then
                                    get_label_name('''||'HRPM81X4'||''','||global_v_lang||',3120)
                            end as flgdeduct
                        from tchildrn
                        where codempid = '''||r_codempid||'''
                        and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                        order by numseq';

                open hrpm81xtab24_cv for v_sql_statement;
                loop

                fetch hrpm81xtab24_cv into v_numseq_24,v_fullname_24,v_numoffid_24,v_dtechbd_24,v_codsex_24,v_flgedlv_24,v_flgdeduct_24;
                exit when hrpm81xtab24_cv%notfound;

                --Report insert TTEMPRPT
                v_rcnt_24 := v_rcnt_24 + 1;
                tab24_detail := '1';
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                    ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                    ITEM10,ITEM11,ITEM12)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB24',r_codempid,v_rcnt_24,
                    v_numseq_24,
                    v_fullname_24,
                    v_numoffid_24,
                    to_char(add_months(to_date(v_dtechbd_24,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                    v_codsex_24,
                    v_flgedlv_24,
                    v_flgdeduct_24,
                    tab24_detail);
                    v_numseq := v_numseq + 1;
                 end loop;

                 exception when others then
                    null;
                end;
            else if i.codinf = 'EMP2600' then
                -- tab 25
                tab25 := '1';
                begin
                    SELECT
                      codempfa,
                      decode(global_v_lang,
                      '101', namfathe,
                      '102', namfatht,
                      '103', namfath3,
                      '104', namfath4,
                      '105', namfath5) fatfnam,
                      numofidf,
                      to_char(dtebdfa, 'dd/mm/yyyy') AS dtebdfa,
                      get_tcodec_name('TCODNATN', codfnatn, global_v_lang) AS codfnatn,
                      get_tcodec_name('TCODRELI', codfrelg, global_v_lang) AS codfrelg,
                      get_tcodec_name('TCODOCCU', codfoccu, global_v_lang) AS codfoccu,
                      CASE staliff
                        WHEN 'N' THEN get_label_name('HRPM81X4', global_v_lang, 3070)
                        WHEN 'Y' THEN get_label_name('HRPM81X4', global_v_lang, 3060)
                      END AS staliff,
                      codempmo,
                      decode(global_v_lang,
                      '101', nammothe,
                      '102', nammotht,
                      '103', nammoth3,
                      '104', nammoth4,
                      '105', nammoth5) motfnam,
                      numofidm,
                      to_char(dtebdmo, 'dd/mm/yyyy') AS dtebdmo,
                      get_tcodec_name('TCODNATN', codmnatn, global_v_lang) AS codmnatn,
                      get_tcodec_name('TCODRELI', codmrelg, global_v_lang) AS codmrelg,
                      get_tcodec_name('TCODOCCU', codmoccu, global_v_lang) AS codmoccu,
                      CASE stalifm
                        WHEN 'N' THEN get_label_name('HRPM81X4', global_v_lang, 3070)
                        WHEN 'Y' THEN get_label_name('HRPM81X4', global_v_lang, 3060)
                      END AS stalifm,
                      decode(global_v_lang,
                      '101', namconte,
                      '102', namcontt,
                      '103', namcont3,
                      '104', namcont4,
                      '105', namcont5) contfnam,
                      adrcont1,
                      codpost,
                      numtele,
                      numfax,
                      email,
                      desrelat
                    INTO
                        v_codempfa_25,
                        v_fatfnam_25,
                        v_numofidf_25,
                        v_dtebdfa_25,
                        v_codfnatn_25,
                        v_codfrelg_25,
                        v_codfoccu_25,
                        v_staliff_25,
                        v_codempmo_25,
                        v_motfnam_25,
                        v_numofidm_25,
                        v_dtebdmo_25,
                        v_codmnatn_25,
                        v_codmrelg_25,
                        v_codmoccu_25,
                        v_stalifm_25,
                        v_contfnam_25,
                        v_adrcont1_25,
                        v_codpost_25,
                        v_numtele_25,
                        v_numfax_25,
                        v_email_25,
                        v_desrelat_25
                    FROM tfamily
                    WHERE codempid = r_codempid;
                    tab25_detail := '1';
                exception when others then
                    null;
                end;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                            ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,
                            ITEM15,ITEM16,ITEM17,ITEM18,ITEM19,
                            ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,
                            ITEM25,ITEM26,ITEM27)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB25',r_codempid,
                        v_codempfa_25,
                        v_fatfnam_25,
                        v_numofidf_25,
                        to_char(add_months(to_date(v_dtebdfa_25,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        v_codfnatn_25,
                        v_codfrelg_25,
                        v_codfoccu_25,
                        v_staliff_25,
                        v_codempmo_25,
                        v_motfnam_25,
                        v_numofidm_25,
                        to_char(add_months(to_date(v_dtebdmo_25,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        v_codmnatn_25,
                        v_codmrelg_25,
                        v_codmoccu_25,
                        v_stalifm_25,
                        v_contfnam_25,
                        v_adrcont1_25,
                        v_codpost_25,
                        v_numtele_25,
                        v_numfax_25,
                        v_email_25,
                        v_desrelat_25);
                    v_numseq := v_numseq + 1;
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
              VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB25_DETAIL',r_codempid,
                      tab25_detail);
              v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP2700' then
                -- tab 26
                tab26 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                              numseq,
                              decode('||global_v_lang||',
                              '''||'101'||''', namrele,
                              '''||'102'||''', namrelt,
                              '''||'103'||''', namrel3,
                              '''||'104'||''', namrel4,
                              '''||'105'||''', namrel5) namrel
                            FROM trelatives
                            WHERE codempid = '''||r_codempid||'''
                            and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                            ORDER BY numseq';
                open hrpm81xtab26_cv for v_sql_statement;
                loop

                fetch hrpm81xtab26_cv into v_numseq_26,v_namrel_26;
                exit when hrpm81xtab26_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2, ITEM5,ITEM6)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB26',r_codempid, v_numseq_26, v_namrel_26);
                  v_numseq := v_numseq + 1;
                  tab26_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB26_DETAIL',r_codempid,
                      tab26_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP2800' then
                -- tab 27
                tab27 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                              numseq,
                              decode('||global_v_lang||',
                              '''||'101'||''', namguare,
                              '''||'102'||''', namguart,
                              '''||'103'||''', namguar3,
                              '''||'104'||''', namguar4,
                              '''||'105'||''', namguar5) namguar,
                              to_char(dtegucon, '''||'dd/mm/yyyy'||''') AS dtegucon,
                              stddec(amtguarntr, codempid, '||global_v_chken||')
                            FROM tguarntr
                            WHERE codempid = '''||r_codempid||'''
                            and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                            ORDER BY numseq';

                open hrpm81xtab27_cv for v_sql_statement;
                loop

                fetch hrpm81xtab27_cv into v_numseq_27,v_namguar_27,v_dtegucon_27,v_amtguarntr_27;
                exit when hrpm81xtab27_cv%notfound;

                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM5,ITEM6,ITEM7,ITEM8)
                     VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB27',r_codempid,
                             v_numseq_27,
                             v_namguar_27,
                             to_char(add_months(to_date(v_dtegucon_27,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                             TRIM(to_char(v_amtguarntr_27,'999,999,990.00')));
                 v_numseq := v_numseq + 1;
                 tab27_detail := '1';
                 end loop;
                 exception when others then
                    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                    ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB27_DETAIL',r_codempid,
                      tab27_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP2900' then
                -- tab 28
                tab28 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='select numcolla,typcolla codtypcolla,
                                              get_tcodec_name('''||'TCODCOLA'||''', typcolla, '||global_v_lang||') as typcolla,
                                              trim(to_char(stddec(amtcolla,codempid,'||global_v_chken||'),'''||'999,999,999,990.00'||''')) as amtcolla,
                                              numdocum,flgded,amtded,qtyperiod,dtestrt,dteend
                                         from tcolltrl
                                        where codempid = '''||r_codempid||'''
                                          and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                                        order by codtypcolla';

                open hrpm81xtab28_cv for v_sql_statement;
                loop
                  fetch hrpm81xtab28_cv into v_numcolla_28,v_codtypcolla_28,v_typcolla_28,v_amtcolla_28,v_numdocum_28,v_flgded_28,v_amtded_28,v_qtyperiod_28,v_dtestrt_28,v_dteend_28;
                  exit when hrpm81xtab28_cv%notfound;

                  --Report insert TTEMPRPT
                  v_newdtestrt_28  := to_char(add_months(to_date(to_char(v_dtestrt_28,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
                  v_newdteend_28   := to_char(add_months(to_date(to_char(v_dteend_28,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');

                  if v_flgded_28 = 'Y' then
                    v_tmp_amtded_28 :=  trim(to_char(stddec(v_amtded_28,r_codempid,global_v_chken),'999,999,990.00'));
                    v_dtededuct_28  := v_newdtestrt_28 || ' - ' || v_newdteend_28;
                  else
                    v_tmp_amtded_28 :=  '-';
                    v_qtyperiod_28  :=  '-';
                    v_dtededuct_28  :=  '-';
                  end if;
                    tab28_detail  := '0';
                    if v_flgded_28 = 'Y' then
                      v_period := 0;
                      v_sumamt := 0;
                      for r1 in c_ttguartee loop
                        v_period := v_period + 1;
                        v_ttguartee_period := r1.numperiod||'/'||r1.dtemthpay||'/'||r1.dteyrepay;
                        v_ttguartee_period := to_char(add_months(to_date(v_ttguartee_period,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
                        v_sumamt := v_sumamt + r1.amtpay;
                        --
                        insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                                              item5,item6,
                                              item7,item8,item9)
                         values (global_v_codempid, 'HRPM81X',v_numseq,'TAB28_TABLE',r_codempid,
                                 v_codtypcolla_28, v_numcolla_28,
                                 v_period, v_ttguartee_period,trim(to_char(r1.amtpay,'999,999,990.00')));
                        v_numseq := v_numseq + 1;
                        tab28_detail := '1';
                      end loop;
--                      v_period := v_period + 1;
                      insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                                              item5,item6,
                                              item7,item8,item9)
                           values (global_v_codempid, 'HRPM81X',v_numseq,'TAB28_TABLE',r_codempid,
                                   v_codtypcolla_28, v_numcolla_28,
                                   '',get_label_name('HRPM81X4',global_v_lang,3230), trim(to_char(v_sumamt,'999,999,990.00')));
                      v_numseq := v_numseq + 1;
                    end if;
                   INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                      ITEM5,ITEM6,ITEM7,
                                      ITEM8, ITEM9,
                                      ITEM10, ITEM11,
                                      ITEM12, ITEM13, ITEM14)
                     values (global_v_codempid, 'HRPM81X',v_numseq,'TAB28',r_codempid,
                             v_codtypcolla_28, v_numcolla_28, v_amtcolla_28,
                             v_numdocum_28,decode(v_flgded_28,'Y',get_label_name('HRPMC2E1P9',global_v_lang,100),get_label_name('HRPMC2E1P9',global_v_lang,110)),
                             v_tmp_amtded_28, v_qtyperiod_28,
                             v_dtededuct_28, v_typcolla_28, tab28_detail);
                    v_numseq := v_numseq + 1;
                  end loop;
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM3)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB28_DETAIL',r_codempid,
                          tab28_detail);
                  v_numseq := v_numseq + 1;

                exception when others then
                  null;
              end;
            else if i.codinf = 'EMP3000' then
                -- tab 29
                tab29 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                              decode('||global_v_lang||',
                              '''||'101'||''', namrefe,
                              '''||'102'||''', namreft,
                              '''||'103'||''', namref3,
                              '''||'104'||''', namref4,
                              '''||'105'||''', namref5) namref,
                              get_tlistval_name('''||'FLGREF'||''', flgref, '||global_v_lang||') AS flgref,
                              despos,
                              desnoffi
                            FROM tapplref
                            WHERE codempid = '''||r_codempid||'''
                            and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                            ORDER BY numseq';

                open hrpm81xtab29_cv for v_sql_statement;
                loop

                fetch hrpm81xtab29_cv into v_namref_29,v_flgref_29,v_despos_29,v_desnoffi_29;
                exit when hrpm81xtab29_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                      ITEM5,ITEM6,ITEM7,ITEM8)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB29',r_codempid,
                      v_namref_29,
                      v_flgref_29,
                      v_despos_29,
                      v_desnoffi_29);
                      v_numseq := v_numseq + 1;
                      tab29_detail := '1';
                 end loop;
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM3)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB29_DETAIL',r_codempid,
                          tab29_detail);
                  v_numseq := v_numseq + 1;
                 exception when others then
                    null;
                end;

            else if i.codinf = 'EMP3100' then
                -- tab 30
                tab30 := '1';
                begin
                    SELECT
                      codpos,codcomp
                    INTO
                      v_codpos_30,v_codcomp_30
                    FROM temploy1
                    WHERE codempid = r_codempid;
                exception when others then
                    null;
                end;

                v_rownum_qtymax := i.QTYMAX;

                for r_competency in c_competency loop
                    v_tcmptncy_codtency_30 := r_competency.codskill;

                    if r_competency.typtency is not null then
                        v_codtency_30   := get_tcomptnc_name(r_competency.typtency, global_v_lang);
                    else
                        v_codtency_30   := 'N/A';
                    end if;

                    v_gpa_num := TO_NUMBER(r_competency.grade) - TO_NUMBER(r_competency.expgrade) ;
                    if v_gpa_num > 0 then
                        v_gpa_str := '+'||v_gpa_num;
                    else
                        if v_gpa_num < 0 then
                            v_gpa_str := ''||v_gpa_num;
                        else
                            v_gpa_str := '0';
                        end if;
                    end if;

                    --Report insert TTEMPRPT
                    v_rcnt_30 := v_rcnt_30 + 1;
                    tab30_detail := '1';
                    INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                        ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
                    VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB30',r_codempid,v_rcnt_31,
                        v_codtency_30,
                        v_tcmptncy_codtency_30 ||' - '||get_tcodec_name('TCODSKIL', v_tcmptncy_codtency_30, global_v_lang),
                        r_competency.expgrade,
                        r_competency.grade,
                        v_gpa_str,
                        tab30_detail);
                        v_numseq := v_numseq + 1;
                end loop;
            else if i.codinf = 'EMP3200' then
                -- tab 31
                tab31 := '1';
                begin
                    v_sql_statement := '';
                    v_rcnt_31 := 0;
                    v_sql_statement :='SELECT
                          get_tcodec_name('''||'TCODLANG'||''', codlang, '||global_v_lang||') AS langu,
                          flglist,
                          CASE flglist
                            WHEN '''||'1'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3160)
                            WHEN '''||'2'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3170)
                            WHEN '''||'3'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3180)
                          END AS desclist,
                          flgspeak,
                          CASE flgspeak
                            WHEN '''||'1'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3160)
                            WHEN '''||'2'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3170)
                            WHEN '''||'3'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3180)
                          END AS descspeak,
                          flgread,
                          CASE flgread
                            WHEN '''||'1'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3160)
                            WHEN '''||'2'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3170)
                            WHEN '''||'3'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3180)
                          END AS descread,
                          flgwrite,
                          CASE flgwrite
                            WHEN '''||'1'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3160)
                            WHEN '''||'2'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3170)
                            WHEN '''||'3'||''' THEN get_label_name('''||'HRPM81X4'||''', '||global_v_lang||', 3180)
                          END AS descwrite
                        FROM tlangabi
                        WHERE codempid = '''||r_codempid||'''
                        and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                        ORDER BY codlang';

                open hrpm81xtab31_cv for v_sql_statement;
                loop

                fetch hrpm81xtab31_cv into v_langu_31,v_flglist_31,v_desclist_31,v_flgspeak_31,v_descspeak_31,v_flgread_31,v_descread_31,v_flgwrite_31,v_descwrite_31;
                exit when hrpm81xtab31_cv%notfound;

                  --Report insert TTEMPRPT
                  v_rcnt_31 := v_rcnt_31 + 1;
                  tab31_detail := '1';
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                      ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                      ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB31',r_codempid,v_rcnt_31,
                      v_langu_31,
                      v_flglist_31,
                      v_desclist_31,
                      v_flgspeak_31,
                      v_descspeak_31,
                      v_flgread_31,
                      v_descread_31,
                      v_flgwrite_31,
                      v_descwrite_31,
                      tab31_detail);
                      v_numseq := v_numseq + 1;
                 end loop;
                 exception when others then
                    null;
                end;

            else if i.codinf = 'EMP3300' then
                -- tab 32
                tab32 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :=   '   select to_char(dteinput, '''||'dd/mm/yyyy'||'''), typrewd, desrewd1, numhmref
                                              from ( SELECT dteinput AS dteinput,
                                                            get_tcodec_name('''||'TCODREWD'||''', typrewd, '||global_v_lang||') AS typrewd,
                                                            desrewd1,
                                                            numhmref
                                                    FROM    thisrewd
                                                   WHERE    codempid = '''||r_codempid||'''
                                                ORDER BY    dteinput DESC, typrewd ASC )'||
                                        ' where  ROWNUM <= nvl('''||i.QTYMAX||''',rownum)'
                                        ;

                open hrpm81xtab32_cv for v_sql_statement;
                loop

                fetch hrpm81xtab32_cv into v_dteinput_32,v_typrewd_32,v_desrewd1_32,v_numhmref_32;
                exit when hrpm81xtab32_cv%notfound;

                  --Report insert TTEMPRPT
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                        ITEM5,ITEM6,ITEM7,ITEM8)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB32',r_codempid,
                          to_char(add_months(to_date(v_dteinput_32,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                          v_typrewd_32,
                          v_desrewd1_32,
                          v_numhmref_32);
                      v_numseq := v_numseq + 1;
                      tab32_detail := '1';
                 end loop;

                 exception when others then
                    null;
                end;
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                      ITEM3)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB32_DETAIL',r_codempid,
                        tab32_detail);
                v_numseq := v_numseq + 1;
            else if i.codinf = 'EMP3400' then
                -- tab 33
                tab33 := '1';
                begin
                    select count(*)
                     into v_num_columns
                       from user_tab_columns
                      where table_name = 'TEMPOTHR'
                        and column_name like 'USR_%'     -- show column_name usr_% only
                        and data_type <> 'LONG RAW';
                exception when no_data_found then
                      v_num_columns := 0;
                end;
                if v_num_columns <> 0 then
                    begin
                        v_sql_statement := '';
                        v_sql_statement := 'select utc.column_name, accm.comments labelname
                                            from user_tab_columns utc, user_col_comments accm
                                            where utc.table_name = accm.table_name
                                            and utc.column_name = accm.column_name
                                            and utc.table_name = '''||'TEMPOTHR'''||
                                            'and utc.column_name LIKE '''||'USR_%'''||
                                            'and data_type <> '''||'LONG RAW''';
--                        v_sql_statement :='SELECT
--                              utc.column_name,
--                              (SELECT DISTINCT
--                                comments
--                              FROM all_col_comments accm
--                              WHERE table_name = '''||'TEMPOTHR'||'''
--                              AND column_name = utc.column_name)
--                              AS labelname
--                            FROM user_tab_columns utc
--                            WHERE table_name = '''||'TEMPOTHR'||'''
--                            AND utc.column_name LIKE '''||'USR_%'||'''
--                            AND data_type <> '''||'LONG RAW'||'''';
                    open hrpm81xtab33_cv for v_sql_statement;
                    loop

                    fetch hrpm81xtab33_cv into v_column_name_33,v_labelname_33;
                    exit when hrpm81xtab33_cv%notfound;

                     begin
                        v_sql_statement := '';
                        v_sql_statement :='SELECT
                              '||v_column_name_33||'
                            FROM TEMPOTHR
                            WHERE codempid = '''||r_codempid||'''';

                        open hrpm81xtab33_sub_cv for v_sql_statement;
                        loop

                        fetch hrpm81xtab33_sub_cv into v_data_33;
                        exit when hrpm81xtab33_sub_cv%notfound;

                          --Report insert TTEMPRPT
                          v_rcnt_33 := v_rcnt_33 + 1;
                          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,
                              ITEM5,ITEM6)
                          VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB33',r_codempid,v_rcnt_33,
                              v_labelname_33||' : ',
                              v_data_33);
                              v_numseq := v_numseq + 1;
                          tab33_detail := '1';
                        end loop;
                     exception when others then
                        null;
                     end;

                     end loop;
                    exception when no_data_found then
                      v_num_columns := 0;
                    end;
                    INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                          ITEM3)
                    VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB33_DETAIL',r_codempid,
                            tab33_detail);
                    v_numseq := v_numseq + 1;
                end if;

            else if i.codinf = 'EMP3500' then
                -- tab 34
                tab34 := '1';
                 begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                          to_char(dteeffec, '''||'dd/mm/yyyy'||''') AS dteeffec,
                          get_tpostn_name(codpos, '||global_v_lang||') AS codpos,
                          get_tcenter_name(hcm_util.get_codcomp_level(codcomp, 1), '||global_v_lang||') AS descomp,
                          hcm_util.get_codcomp_level(codcomp, 1) as codcomp,
                          codempmt,
                          numlvl,
                          get_tcodec_name('''||'TCODMOVE'||''',codtrn,'||global_v_lang||') as codtrn,
                          stddec(amtincadj1, codempid, '||global_v_chken||') AS amtincadj1,
                          stddec(amtincadj2, codempid, '||global_v_chken||') AS amtincadj2,
                          stddec(amtincadj3, codempid, '||global_v_chken||') AS amtincadj3,
                          stddec(amtincadj4, codempid, '||global_v_chken||') AS amtincadj4,
                          stddec(amtincadj5, codempid, '||global_v_chken||') AS amtincadj5,
                          stddec(amtincadj6, codempid, '||global_v_chken||') AS amtincadj6,
                          stddec(amtincadj7, codempid, '||global_v_chken||') AS amtincadj7,
                          stddec(amtincadj8, codempid, '||global_v_chken||') AS amtincadj8,
                          stddec(amtincadj9, codempid, '||global_v_chken||') AS amtincadj9,
                          stddec(amtincadj10, codempid, '||global_v_chken||') AS amtincadj10,
                          stddec(amtincom1, codempid, '||global_v_chken||') AS amtincom1,
                          stddec(amtincom2, codempid, '||global_v_chken||') AS amtincom2,
                          stddec(amtincom3, codempid, '||global_v_chken||') AS amtincom3,
                          stddec(amtincom4, codempid, '||global_v_chken||') AS amtincom4,
                          stddec(amtincom5, codempid, '||global_v_chken||') AS amtincom5,
                          stddec(amtincom6, codempid, '||global_v_chken||') AS amtincom6,
                          stddec(amtincom7, codempid, '||global_v_chken||') AS amtincom7,
                          stddec(amtincom8, codempid, '||global_v_chken||') AS amtincom8,
                          stddec(amtincom9, codempid, '||global_v_chken||') AS amtincom9,
                          stddec(amtincom10, codempid, '||global_v_chken||') AS amtincom10,
                          jobgrade
                        FROM thismove
                        WHERE codempid = '''||r_codempid||'''
                        and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                        ORDER BY dteeffec desc, numseq desc';
                  open hrpm81xtab34_cv for v_sql_statement;
                    loop

                    fetch hrpm81xtab34_cv
                    into
                        v_dteeffec_34,
                        v_codpos_34,
                        v_descomp_34,
                        v_codcomp_34,
                        v_codempmt_34,
                        v_numlvl_34,
                        v_codtrn_34,
                        v_amtincadj1_34,
                        v_amtincadj2_34,
                        v_amtincadj3_34,
                        v_amtincadj4_34,
                        v_amtincadj5_34,
                        v_amtincadj6_34,
                        v_amtincadj7_34,
                        v_amtincadj8_34,
                        v_amtincadj9_34,
                        v_amtincadj10_34,
                        v_amtincom1_34,
                        v_amtincom2_34,
                        v_amtincom3_34,
                        v_amtincom4_34,
                        v_amtincom5_34,
                        v_amtincom6_34,
                        v_amtincom7_34,
                        v_amtincom8_34,
                        v_amtincom9_34,
                        v_amtincom10_34,
                        v_jobgrade_34;
                    exit when hrpm81xtab34_cv%notfound;

                    -- income
                    GET_WAGE_INCOME( v_codcomp_34, v_codempmt_34,
                    v_amtincadj1_34,v_amtincadj2_34,v_amtincadj3_34,v_amtincadj4_34,v_amtincadj5_34,
                    v_amtincadj6_34,v_amtincadj7_34,v_amtincadj8_34,v_amtincadj9_34,v_amtincadj10_34,
                    v_amtothrincadj_34, v_amtdayincadj_34, v_sumincadj_34);

                    -- income
                    GET_WAGE_INCOME( v_codcomp_34, v_codempmt_34,
                    v_amtincom1_34,v_amtincom2_34,v_amtincom3_34,v_amtincom4_34,v_amtincom5_34,
                    v_amtincom6_34,v_amtincom7_34,v_amtincom8_34,v_amtincom9_34,v_amtincom10_34,
                    v_amtothrincome_34, v_amtdayincome_34, v_sumincom_34);

                    if permision_salary then
                        tab34_detail := '1';
                        if global_v_zupdsal = 'Y' then
                             --Report insert TTEMPRPT
                            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                                ITEM10,ITEM11)
                            VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB34',r_codempid,
                                    to_char(add_months(to_date(v_dteeffec_34,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                    v_codpos_34,
                                    v_descomp_34,
                                    v_jobgrade_34,
                                    v_sumincadj_34,
                                    v_sumincom_34,
                                    v_codtrn_34);
                                v_numseq := v_numseq + 1;
                        else
                             --Report insert TTEMPRPT
                            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                                ITEM10,ITEM11)
                            VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB34',r_codempid,
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '');
                                v_numseq := v_numseq + 1;
                        end if;

                    else
                         --Report insert TTEMPRPT
                        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                            ITEM10,ITEM11)
                        VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB34',r_codempid,
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '');
                            v_numseq := v_numseq + 1;
                    end if;

                  end loop;
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                          ITEM3)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB34_DETAIL',r_codempid,
                            tab34_detail);
                  v_numseq := v_numseq + 1;
                exception when no_data_found then
                    null;
                end;


            else if i.codinf = 'EMP3600' then
                -- tab 35
                tab35 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                              dteyreap,
                              get_tpostn_name(codpos, '||global_v_lang||') AS codpos,
                              get_tcenter_name(hcm_util.get_codcomp_level(codcomp, 1), '||global_v_lang||') AS codcomp,
                              grade
                            FROM tapprais
                            WHERE codempid = '''||r_codempid||'''
                            and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                            ORDER BY dteyreap DESC, codpos, codcomp';

                open hrpm81xtab35_cv for v_sql_statement;
                loop

                fetch hrpm81xtab35_cv into v_dteyreap_35,v_codpos_35,v_codcomp_35,v_grade_35;
                exit when hrpm81xtab35_cv%notfound;

                begin
                  select  qtybeh3,qtycmp3,qtykpie3,qtyta,qtypuns,qtytot3,jobgrade
                     into v_qtybeh_35,v_qtycmp_35,v_qtykpi_35,v_qtyta_35,v_qtypuns_35,v_qtytot_35,v_jobgrade_35
                     from tappemp
                    where codempid = r_codempid
                      and dteyreap = v_dteyreap_35
                      and numtime = (select max(numtime) from tappemp where codempid = r_codempid
                                           and dteyreap = v_dteyreap_35) ;
                      exception when others then
                        null;
                end;
                v_tapuns_35 :='';
                if v_qtyta_35 is not null or v_qtypuns_35 is not null then
                   v_tapuns_35 := v_qtyta_35 || '/' || v_qtypuns_35 ;
                end if;
                --Report insert TTEMPRPT
                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                      ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,
                                      ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB35',r_codempid,
                      v_dteyreap_35 + numYearReport,
                      v_codpos_35,
                      v_codcomp_35,
                      v_qtybeh_35,
                      v_qtykpi_35,
                      v_qtycmp_35,
                      v_tapuns_35,
                      v_qtytot_35,
                      v_grade_35,
                      get_tcodec_name('tcodjobg',v_jobgrade_35,global_v_lang));
                    v_numseq := v_numseq + 1;
                    tab35_detail := '1';
                 end loop;
                 INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                          ITEM3)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB35_DETAIL',r_codempid,
                            tab35_detail);
                  v_numseq := v_numseq + 1;
                exception when others then
                    null;
                end;

            else if i.codinf = 'EMP3700' then
                -- tab 36
                tab36 := '1';
                begin
                    v_sql_statement := '';
                    v_sql_statement :='SELECT
                          to_char(a.dteeffec, '''||'dd/mm/yyyy'||''') AS dteeffec,
                          b.desmist1,
                          a.codpunsh,
                          get_tcodec_name('''||'TCODPUNH'||''', a.codpunsh, '||global_v_lang||') AS desc_codpunsh,
                          to_char(a.dtestart, '''||'dd/mm/yyyy'||''') AS dtestart,
                          to_char(a.dteend, '''||'dd/mm/yyyy'||''') AS dteend,
                          a.remark,
                          b.codmist,
                          get_tcodec_name('''||'TCODMIST'||''', b.codmist, '||global_v_lang||') AS desc_codmist,
                          a.flgexempt,a.flgblist
                        FROM thispun a,
                             thismist b
                        WHERE a.codempid = b.codempid
                        AND a.dteeffec = b.dteeffec
                        AND a.codempid = '''||r_codempid||'''
                        and ROWNUM <= nvl('''||i.QTYMAX||''',rownum)
                        ORDER BY b.dtemistk DESC';

                open hrpm81xtab36_cv for v_sql_statement;
                loop

                fetch hrpm81xtab36_cv into v_dteeffec_36,v_desmist1_36,v_codpunsh_36,v_desc_codpunsh_36
                                           ,v_dtestart_36,v_dteend_36,v_remark_36,v_codmist_36,v_desc_codmist_36,
                                           v_flgexempt_36,v_flgblist_36;
                exit when hrpm81xtab36_cv%notfound;

                if (v_flgexempt_36 = 'N') then
                   v_exempt_36 := get_label_name('HRPM79X',global_v_lang,0);
                else
                   v_exempt_36 := get_label_name('HRPM79X',global_v_lang,1);
                end if;

                if (v_flgblist_36 = 'N') then
                   v_blist_36 := get_label_name('HRPM79X',global_v_lang,2);
                else
                   v_blist_36 := get_label_name('HRPM79X',global_v_lang,3);
                end if;

                --Report insert TTEMPRPT

                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                    ITEM3,
                    ITEM4,ITEM5,ITEM6,ITEM7,
                    ITEM8,
                    ITEM9,
                    ITEM10,ITEM11)
                VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB36',r_codempid,
                        to_char(add_months(to_date(v_dteeffec_36,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        v_desc_codmist_36,v_desc_codpunsh_36,v_codpunsh_36,v_desmist1_36,
                        to_char(add_months(to_date(v_dtestart_36,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        to_char(add_months(to_date(v_dteend_36,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        v_exempt_36,v_blist_36);
                    v_numseq := v_numseq + 1;
                    tab36_detail := '1';
                 end loop;
                 INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                          ITEM3)
                  VALUES (global_v_codempid, 'HRPM81X',v_numseq,'TAB36_DETAIL',r_codempid,
                            tab36_detail);
                  v_numseq := v_numseq + 1;
                exception when others then
                    null;
                end;

            end if; -- tab36
            end if; -- tab35
            end if; -- tab34
            end if; -- tab33
            end if; -- tab32
            end if; -- tab31
            end if; -- tab30
            end if; -- tab29
            end if; -- tab28
            end if; -- tab27
            end if; -- tab26
            end if; -- tab25
            end if; -- tab24
            end if; -- tab23
            end if; -- tab22
            end if; -- tab21
            end if; -- tab20
            end if; -- tab19
            end if; -- tab18
            end if; -- tab17
            end if; -- tab16
            end if; -- tab15
            end if; -- tab14
            end if; -- tab13
            end if; -- tab12
            end if; -- tab11
            end if; -- tab10
            end if; -- tab9
            end if; -- tab8
            end if; -- tab7
            end if; -- tab6
            end if; -- tab5
            end if; -- tab4
            end if; -- tab3
            end if; -- tab2
            end if; -- tab1
        END LOOP;

        --- MAIN Data
        begin
            SELECT
              decode(global_v_lang,
              '101', namfirste,
              '102', namfirstt,
              '103', namfirst3,
              '104', namfirst4,
              '105', namfirst5) namfirst,
              decode(global_v_lang,
              '101', namlaste,
              '102', namlastt,
              '103', namlast3,
              '104', namlast4,
              '105', namlast5) namlast,
              decode(global_v_lang,
              '101', nickname,
              '102', nicknamt,
              '103', nicknam3,
              '104', nicknam4,
              '105', nicknam5) nicknam,
              codempid,
--              numtelof,
              nummobile,
              email,
              lineid
            INTO
              v_namfirst_main,
              v_namlast_main,
              v_nicknam_main,
              v_codempid_main,
--              v_numtelof_main,
              v_nummobile_main,
              v_email_main,
              v_lineid_main
            FROM temploy1
            WHERE codempid = r_codempid;
        exception when others then
            null;
        end;

        begin
            SELECT numtelec
            INTO v_numtelof_main
            FROM temploy2
            WHERE codempid = r_codempid;
        exception when others then
            null;
        end;

        --Report insert TTEMPRPT image
        begin
          select namimage
           into v_image
           from tempimge
           where codempid = r_codempid;
        exception when no_data_found then
          v_image := '';
        end;
       --<<check existing image
        if v_image is not null then
          v_image := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1') || '/' || v_image;
          v_has_image   := 'Y';
        else
          v_image := get_tsetup_value('PATHWORKPHP')||'default-emp.png';
          v_has_image   := 'Y';
        end if;
        -->>

        --Report insert TTEMPRPT
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,
                              item5,item6,item7,item8,item9,
                              item10,item11,item12,
                              item13,item14,item15,item16,item17,
                              item18,item19,item20,item21,item22,
                              item23,item24,item25,item26,item27,
                              item28,item29,item30,item31,item32,
                              item33,item34,item35,item36,item37,
                              item38,item39,item40,item41,item42,
                              item43,item44,item45,item46,item47,
                              item48,
                              item49, item50 )
            values (global_v_codempid, 'HRPM81X',v_numseq,'MAIN',r_codempid,
                    v_namfirst_main, v_namlast_main, '( '||v_nicknam_main||' )',
                    get_label_name('HRPM81X2',global_v_lang,20) ||' : '||v_codempid_main,
                    get_format_telphone(v_numtelof_main),
                    get_format_telphone(v_nummobile_main),
                    v_email_main, v_lineid_main,
                    tab1, tab2, tab3,
                    tab4, tab5, tab6,
                    tab7, tab8, tab9,
                    tab10, tab11, tab12,
                    tab13, tab14, tab15,
                    tab16, tab17, tab18,
                    tab19, tab20, tab21,
                    tab22, tab23, tab24,
                    tab25, tab26, tab27,
                    tab28, tab29, tab30,
                    tab31, tab32, tab33,
                    tab34, tab35, tab36,
                    v_image, v_has_image);
        v_numseq := v_numseq + 1;
        dbms_lob.createtemporary(json_str_output,true);
    EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    FUNCTION get_age_label ( p_dtest DATE , p_dtend  DATE)
    RETURN VARCHAR2 IS
       t_year		number  				:= 0;
       t_month   	number  				:= 0;
       t_day 		number  				:= 0;
    BEGIN

        if p_dtend is null then
            GET_SERVICE_YEAR(p_dtest,sysdate,'Y',t_year,t_month,t_day);
        else
            GET_SERVICE_YEAR(p_dtest,p_dtend,'Y',t_year,t_month,t_day);
        end if;
        RETURN (to_char(t_year,'fm9990')||' '||get_label_name('HRPM93X2',global_v_lang,270) ||to_char(t_month,'00')||' '||get_label_name('HRPM93X2',global_v_lang,280)||to_char(t_day,'00') ||' '||get_label_name('HRPM93X2',global_v_lang,260));
    END get_age_label;

    FUNCTION get_age_job ( p_dtest DATE , p_dtend  DATE)
    RETURN VARCHAR2 IS
       t_year		number  				:= 0;
       t_month   	number  				:= 0;
       t_day 		number  				:= 0;
    BEGIN

        if p_dtend is null then
            GET_SERVICE_YEAR(p_dtest,sysdate,'Y',t_year,t_month,t_day);
        else
            GET_SERVICE_YEAR(p_dtest,p_dtend,'Y',t_year,t_month,t_day);
        end if;
        RETURN (to_char(t_year,'fm9990')||' '||get_label_name('HRPM93X2',global_v_lang,270) ||to_char(t_month,'00')||' '||get_label_name('HRPM93X2',global_v_lang,280));
    END get_age_job;

    FUNCTION get_format_telphone ( string_telnumber VARCHAR2)
    RETURN VARCHAR2 IS
       str_format_tel           varchar2(4000 char);
       str_format_tel_temp      varchar2(4000 char);
    BEGIN
        str_format_tel_temp := replace(string_telnumber,'-','');


        if LENGTH(str_format_tel_temp) = 10 then
          str_format_tel := substr(str_format_tel_temp,1,3) || '-' || substr(str_format_tel_temp,4,3) || '-' || substr(str_format_tel_temp,7,4);
        else if LENGTH(str_format_tel_temp) = 9 then
          str_format_tel := substr(str_format_tel_temp,1,2) || '-' || substr(str_format_tel_temp,3,3) || '-' || substr(str_format_tel_temp,6,4);
        else
          str_format_tel := '';
        end if;
        end if;
        RETURN str_format_tel;
    END get_format_telphone;

    procedure get_addr_label(p_empid in varchar2, p_lang in varchar2, p_type in varchar2, str_addr_label out varchar2) is
		v_Stmt			VARCHAR2(500);
		v_Stmt0			VARCHAR2(500);
		v_Stmt1			VARCHAR2(500);
		v_Stmt2			VARCHAR2(500);
	BEGIN
		IF p_empid is not null then
            if p_type = 'ADRREG' then
                IF p_lang = '101' THEN
                    v_Stmt0 := ' SELECT ADRREGE';
                ELSIF p_lang = '102' THEN
                    v_Stmt0 := ' SELECT ADRREGT ';
                ELSIF p_lang = '103' THEN
                    v_Stmt0 := ' SELECT ADRREG3 ';
                ELSIF p_lang = '104' THEN
                    v_Stmt0 := ' SELECT ADRREG4 ';
                ELSIF p_lang = '105' THEN
                    v_Stmt0 := ' SELECT ADRREG5 ';
                ELSE
                    v_Stmt0 := ' SELECT ADRREGE ';
                END IF;
            else if p_type = 'ADRCONT' then
                IF p_lang = '101' THEN
                    v_Stmt0 := ' SELECT ADRCONTE';
                ELSIF p_lang = '102' THEN
                    v_Stmt0 := ' SELECT ADRCONTT ';
                ELSIF p_lang = '103' THEN
                    v_Stmt0 := ' SELECT ADRCONT3 ';
                ELSIF p_lang = '104' THEN
                    v_Stmt0 := ' SELECT ADRCONT4 ';
                ELSIF p_lang = '105' THEN
                    v_Stmt0 := ' SELECT ADRCONT5 ';
                ELSE
                    v_Stmt0 := ' SELECT ADRCONTE ';
                END IF;
            end if;
            end if;
			v_Stmt1 := ' FROM TEMPLOY2 ';
			v_Stmt2 := ' WHERE CODEMPID = ''' ||p_empid||'''';
			v_Stmt := v_Stmt0 || v_Stmt1 || v_Stmt2 ;
			begin
				execute immediate v_Stmt into str_addr_label ;
			exception
			when no_data_found then
				str_addr_label := '';
			end;
		else
			str_addr_label := '';
		end if;
	EXCEPTION
	WHEN OTHERS THEN
		RAISE;
	end get_addr_label;

    procedure get_temphead (
                      p_codempid_query   in varchar2,
                      p_codcomp in varchar2,
                      p_codpos in varchar2,
                      p_codcomph out varchar2,
                      p_codposh out varchar2,
                      p_codempidh out varchar2,
                      p_stapost out varchar2) is

    v_codempidh   temphead.codempidh%type := ''; --from temphead, temphead
    v_codcomph    temphead.codcomph%type := '';
    v_codposh     temphead.codposh%type := '';
    v_stapost     tsecpos.stapost2%type := ''; -- from tsecpos
    v_chk_head1   varchar2(1) := 'N';

    cursor c_head1 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
              decode(codempidh,'%',2,1) sorting
      from    temphead
      where   codempid = p_codempid_query
      order by sorting,numseq;

--    select replace(codempidh,'%',null) codempidh,
--           replace(codcomph,'%',null) codcomph,
--           replace(codposh,'%',null) codposh
--      from    temphead
--      where   codempid = p_codempid_query
--      order by numseq;

    cursor c_head2 is
      select  replace(codempidh,'%',null) codempidh,
                replace(codcomph,'%',null) codcomph,
                replace(codposh,'%',null) codposh,
                decode(codempidh,'%',2,1) sorting
        from    temphead
        where   codcomp = p_codcomp
        and     codpos  = p_codpos
        order by sorting,numseq;
--    select replace(codempidh,'%',null) codempidh,
--           replace(codcomph,'%',null) codcomph,
--           replace(codposh,'%',null) codposh
--      from    temphead
--      where   codcomp = p_codcomp
--      and     codpos  = p_codpos
--      order by numseq;
  begin
    for j in c_head1 loop
      v_chk_head1  := 'Y' ;
      if j.codempidh  is not null then
        v_codempidh := j.codempidh ;
      else
        v_codcomph  := j.codcomph ;
        v_codposh   := j.codposh ;
      end if;
      exit;
    end loop;
    if 	v_chk_head1 = 'N' then
      for j in c_head2 loop
        v_chk_head1  := 'Y' ;
        if j.codempidh  is not null then
          v_codempidh := j.codempidh ;
        else
          v_codcomph  := j.codcomph ;
          v_codposh   := j.codposh ;
        end if;
        exit;
      end loop;
    end if;
    if v_codcomph is not null then
      begin
        select codempid into v_codempidh
          from temploy1
         where codcomp  = v_codcomph
           and codpos   = v_codposh
           and staemp   in  ('1','3')
           and rownum   = 1;
           v_stapost := null;
      exception when no_data_found then
        begin
          select codempid,stapost2 into v_codempidh,v_stapost
            from tsecpos
           where codcomp	= v_codcomph
             and codpos	  = v_codposh
             and dteeffec <= sysdate
             and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
             and rownum   = 1;
        exception when no_data_found then
          v_codempidh := null;
          v_stapost := null;
        end;
      end;
    end if;
    p_codcomph      := v_codcomph;
    p_codposh       := v_codposh;
    p_codempidh     := v_codempidh;
    p_stapost       := v_stapost;
    --ถ้า v_stapost เป็นค่าว่างให้แสดงแต่งตังปกติ  ถ้าเป็น 1-รักษาการณ์   ถ้าเป็น 2-ตำแหน่งควบ)
  end; -- end get_head
  function get_format_hhmm (p_qtyhour    number) return varchar2 is
    v_qtytrmin          varchar2(10);
  begin
        begin
            v_qtytrmin := trunc(p_qtyhour)||':'||lpad(mod(nvl(p_qtyhour,0),1)*100,2,'0');
           exception when others then
             v_qtytrmin := null;
        end;
        return v_qtytrmin;
  end get_format_hhmm;

end HRPM81X;

/
