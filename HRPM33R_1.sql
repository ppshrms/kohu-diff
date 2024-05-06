--------------------------------------------------------
--  DDL for Package Body HRPM33R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM33R" is

  procedure initial_value ( json_str in clob ) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp   := hcm_util.get_string_t(json_obj,'codcomp');
    p_codempid  := hcm_util.get_string_t(json_obj,'codempid');
    p_month     := hcm_util.get_string_t(json_obj,'month');
    p_year      := hcm_util.get_string_t(json_obj,'year');
    p_namtpro   := hcm_util.get_string_t(json_obj,'namtpro');
    p_nameval   := hcm_util.get_string_t(json_obj,'nameval');

    p_codform   := hcm_util.get_string_t(json_obj,'codform');
    p_dteprint  := hcm_util.get_string_t(json_obj,'dteprint');

    if p_codcomp is not null then
      p_dteduepr_str  := to_date('01' || '/' || p_month || '/' || p_year,'dd/mm/yyyy hh24:mi:ss');
      p_dteduepr_end  := to_date(to_char(last_day(p_dteduepr_str),'dd/mm/yyyy'),'dd/mm/yyyy hh24:mi:ss');
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

--  procedure print_document is
--    v_numlettr   varchar2(100 char);
--    v_namimglet  tfmrefr.namimglet%type;
--    data_file    varchar2(2000 char);
--    TYPE str_list is
--        VARRAY ( 3 ) OF varchar2(2000 char);
--    TYPE clob_list is
--        VARRAY ( 3 ) OF clob;
--    v_message    clob_list := clob_list();
--    v_typemsg    str_list := str_list();
--    
--    v_dteduepr   temploy1.dteduepr%type;
--  begin
--    p_codform  := hcm_util.get_string_t(p_details,'codform');
--    p_numlettr  := hcm_util.get_string_t(p_details,'numlettr');
--    p_dteprint  := hcm_util.get_string_t(p_details,'dteprint');
--    p_codcomp  := hcm_util.get_string_t(p_details,'codcomp');
--    p_dteduepr  := hcm_util.get_string_t(p_details,'dteduepr');
----    p_codempid_list;
----    p_resultfparam;
--    for i in 0..p_codempid_list.get_size - 1 loop
--      param_json_row  := hcm_util.get_json_t(p_codempid_list,to_char(i) );
--      p_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
--      if p_numlettr is null then
--        v_numlettr := get_docnum('2',hcm_util.get_codcomp_level(p_codcomp,1),global_v_lang);
--        begin
--          update ttprobat
--             set numlettr = v_numlettr,
--                 coduser = global_v_coduser
--           where codempid = p_codempid
--             and dteduepr = p_dteduepr;
--        end;
--        commit;
--      else
--        v_numlettr := p_numlettr;
--      end if;
--      
--      v_message.extend(3);
--      v_typemsg.extend(3);
--     -- (1) header
--     -- (2) body
--     -- (3) footer
--      gen_message(p_codform,v_message(1),v_namimglet,v_message(2),v_typemsg(2),v_message(3));
----      for j in 1..3 loop
--      begin
--        select dteduepr into v_dteduepr
--        from temploy1
--        where codempid = p_codempid;
--      end;
--      data_file := v_message(1);
--            
--  --      if v_typemsg(j) = 'S' then
--      data_file := replace(data_file,'[PARAM-01]',v_numlettr);
--      data_file := replace(data_file,'[PARAM-02]',to_char(v_dteduepr,'fmdd MONTH yyyy','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATA_LANGUAGE=THAI'));
----                                                      to_char(p_dteduepr,'fmdd MONTH yyyy','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')
--  --
--  --        data_file := replace(data_file,'[param_3]',get_temploy_name(p_codempid,global_v_lang) );
--  --        data_file := replace(data_file,'[param_4]',TO_CHAR(p_dteempmt,'fmdd MONTH yyyy','NLS_CALENDAR="THAI BUDDHA" NLS_DATA_LANGUAGE=THAI'));
--  --
--  --        data_file := replace(data_file,'[param_5]',get_tpostn_name(p_codpos,global_v_lang));
--  --        data_file := replace(data_file,'[param_6]',get_tcenter_name(p_codcomp,global_v_lang));
--  --        data_file := replace(data_file,'[param_7]',get_tcenter_name(hcm_util.get_codcomp_level(p_codcomp,'1'),global_v_lang));
--  --
--  --        data_file := replace(data_file,'[param_8]',p_dteduepr - p_dteempmt + 1);
--  --        data_file := replace(data_file,'[param_9]',TO_CHAR(p_dteoccup,'fmdd MONTH yyyy','NLS_CALENDAR="THAI BUDDHA" NLS_DATA_LANGUAGE=THAI'));
--  --
--  --        data_file := replace(data_file,'[param_13]',TO_CHAR(p_qtyexpand));
--          v_message(1) := data_file;
--  --      else
--  --        v_message(j) := null;
--  --      end if;
----      end loop;
--
--    end loop;
--    
--
--
--
----    data_file := null;
----    for j in 1..3 loop
----      if v_message(j) is not null then
----        data_file := data_file || chr(13) || chr(10) || v_message(j);
----      end if;
----    end loop;
--  exception when others then 
--    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--  end;
--
--  procedure gen_word ( p_codapp in varchar2,p_coduser in varchar2,p_message in LONG) is
--    v_path      varchar2(500 char);
--    v_namecon   varchar2(50 char);
--  begin
--    delete ttemword
--     where codapp = p_codapp
--       and coduser = p_coduser;
--
--    insert into ttemword ( codapp, coduser, message ) 
--    values ( p_codapp, p_coduser, p_message );
--
--    commit;
--    v_path := get_tsetup_value('LOGINPORTAL');
--    v_path := substr(v_path,1,instr(v_path,'/',-1) );
--
--    v_namecon := '_' || TO_CHAR(SYSDATE,'DDMMYYHH24MISS') || p_fileseq;
--  end;

  procedure gen_message ( p_codform in varchar2, o_message1 out clob, o_namimglet out varchar2,
                          o_message2 out clob, o_typemsg2 out long, o_message3 out clob) is
  begin
    begin
      select message, namimglet into o_message1, o_namimglet
        from tfmrefr
       where codform = p_codform;
    exception when no_data_found then
      o_message1  := null;
      o_namimglet := null;
    end;
    begin
      select message, typemsg
        into o_message2, o_typemsg2
        from tfmrefr2
       where codform = p_codform;
    exception when no_data_found then
      o_message2 := null;
      o_typemsg2 := null;
    end;
    begin
      select message
        into o_message3
        from tfmrefr3
       where codform = p_codform;
    exception when no_data_found then
      o_message3 := null;
    end;
  end;

--  procedure send_mail(p_numlettr out varchar2) is
--
--    v_msg_to      varchar2(200 char);
--    v_template    varchar2(200 char);
--    v_func_appr   varchar2(200 char);
--    v_codrespr    varchar2(200 char);
--    v_numlettr    varchar2(200 char);
--    v_codempid    varchar2(200 char);
--    v_dteduepr    DATE;
--    v_dteoccup    DATE;
--    v_dteempmt    DATE;
--    v_qtyexpand   varchar2(10 char);
--    v_numlvl      varchar2(100 char);
--    v_codpos      varchar2(100 char);
--    v_codcomp     varchar2(100 char);
--    TYPE str_list is
--        VARRAY ( 3 ) OF varchar2(2000 char);
--    TYPE long_list is
--        VARRAY ( 3 ) OF LONG;
--    data_file     varchar2(2000 char);
--    v_message     str_list := str_list ();
--    v_typemsg     long_list := long_list ();
--  begin
--    chk_flowmail.get_message('HRPM33R',global_v_lang,v_msg_to,v_template,v_func_appr);
--    for i in 0..p_codempid_list.get_size - 1 loop
--      param_json_row := hcm_util.get_json_t(p_codempid_list,TO_CHAR(i) );
--      v_codempid := hcm_util.get_string_t(param_json_row,'codempid');
--
--      SELECT a.codrespr, a.numlettr, a.dteduepr, TO_CHAR(a.qtyexpand), a.dteoccup, c.numlvl, c.codcomp, c.dteempmt, c.codpos
--        inTO v_codrespr, v_numlettr, v_dteduepr, v_qtyexpand, v_dteoccup, v_numlvl, v_codcomp, v_dteempmt, v_codpos
--        FROM ttprobat a, temploy1 c
--       where a.codempid = c.codempid
--         and a.codempid = v_codempid
--         and a.staupd in ('C','U');
--
--      if v_numlettr is null then
--        v_numlettr := get_docnum('2',hcm_util.get_codcomp_level(p_codcomp,1),global_v_lang);
--        begin
--          update ttprobat
--             set numlettr = v_numlettr,
--                 CODUSER = global_v_CODUSER
--           where codempid = v_codempid
--             and dteduepr = v_dteduepr;
--        end;
--        commit;
--      end if;
--
--      p_numlettr := v_numlettr;
--      v_message.extend(3);
--      v_typemsg.extend(3);
--
----          gen_message(p_codform,v_message(1),v_typemsg(1),v_message(2),v_typemsg(2),v_message(3),v_typemsg(3) );
--
--      for j in 1..3 loop
--        data_file := v_message(j);
--        if v_typemsg(j) = 'S' then
--          data_file := replace(data_file,'[param_1]',v_numlettr);
--          data_file := replace(data_file,'[param_2]',TO_CHAR(p_dteduepr,'fmdd MONTH yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai'));
--          data_file := replace(data_file,'[param_3]',get_temploy_name(p_codempid,global_v_lang) );
--          data_file := replace(data_file,'[param_4]',TO_CHAR(v_dteempmt,'fmdd MONTH yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai'));
--          data_file := replace(data_file,'[param_5]',get_tpostn_name(v_codpos,global_v_lang) );
--          data_file := replace(data_file,'[param_6]',get_tcenter_name(p_codcomp,global_v_lang) );
--          data_file := replace(data_file,'[param_7]',get_tcenter_name(hcm_util.get_codcomp_level(p_codcomp,'1'),global_v_lang) );
--          data_file := replace(data_file,'[param_8]',v_dteduepr - v_dteempmt + 1);
--          data_file := replace(data_file,'[param_9]',TO_CHAR(v_dteoccup,'fmdd MONTH yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai'));
--          data_file := replace(data_file,'[param_13]',TO_CHAR(v_qtyexpand) );
--
--          for i in 0..p_resultfparam.get_size - 1 loop
--            param_json_row := hcm_util.get_json_t(p_resultfparam,TO_CHAR(i) );
--            data_file := replace(data_file ,hcm_util.get_string_t(param_json_row,'fparam') ,hcm_util.get_string_t(param_json_row,'value'));
--          end loop;
--          v_message(j) := data_file;
--        else
--          v_message(j) := null;
--        end if;
--      end loop;
--      data_file := null;
--      for j in 1..3 loop
--        if v_message(j) is not null then
--          data_file := data_file || chr(13) || chr(10) || v_message(j);
--        end if;
--      end loop;
--    end loop;
--  end;

  procedure check_get_index is
    v_codcomp          temploy1.codcomp%type;
    v_codempid         temploy1.codempid%type;
    v_codcomp_empid    varchar2(100 char);
    v_numlvl           varchar2(100 char);
    v_staemp           varchar2(1 char);
    v_secur_codempid   boolean;
    v_secur_codcomp    boolean;
  begin
    if p_codempid is not null then
      p_codcomp := null;
      p_dteduepr_str := null;
      p_dteduepr_end := null;
      p_month := null;
      p_year  := null;
    end if;

    if p_codempid is not null then
      begin
        select codempid, staemp, codcomp, numlvl
          into v_codempid, v_staemp, v_codcomp_empid, v_numlvl
          from temploy1
         where codempid = p_codempid;

        if v_staemp = 0 then
          param_msg_error := get_error_msg_php('HR2102',global_v_lang);
          return;
        end if;

        if v_staemp = 9 then
          param_msg_error := get_error_msg_php('HR2101',global_v_lang);
          return;
        end if;

        if v_codcomp_empid is not null and v_numlvl is not null then
          v_secur_codempid := secur_main.secur3(v_codcomp_empid,v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl ,v_zupdsal);
          if v_secur_codempid = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,v_codcomp_empid);
            return;
          end if;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
    end if;

    if p_codcomp is not null then
      begin
        select count(*) into v_codcomp
        from tcenter
        where codcomp like p_codcomp || '%';
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end;
      if v_codcomp = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end if;
      v_secur_codcomp := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur_codcomp then  -- check user authorize view codcomp
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
        return;
      end if;
    end if;
  end;

  procedure check_probation_form is
    v_codcomp          temploy1.codcomp%type;
    v_codempid         temploy1.codempid%type;
    v_codcomp_empid    varchar2(100 char);
    v_numlvl           varchar2(100 char);
    v_staemp           varchar2(1 char);
    v_secur_codempid   boolean;
    v_secur_codcomp    boolean;
    v_chk_exist        tfmrefr.codform%type := '';
  begin
    null;
    if p_codform is null then 
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codform');
    else
      begin
        select codform into v_chk_exist
          from TFMREFR 
         where TYPFM = 'HRPM33R'
           and codform = p_codform;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFMREFR');
      end;
    end if;
  end;

  procedure gen_index ( json_str_output out clob ) is

    v_rcnt              number := 0;
    v_flg_permission    boolean := false;
    v_flg_found         boolean := false;
    v_secur_codempid    boolean;
    v_codrespr          varchar2(100 char);
    v_docnum            varchar2(1000 char);

    v_codcomp          temploy1.codcomp%type;
    v_codempid         temploy1.codempid%type;

      cursor c_ttprobat is 
        select a.codrespr,a.numlettr,a.dteduepr,a.qtyexpand,a.dteoccup,a.codempid,
               a.typproba,c.numlvl,c.codcomp,c.dteempmt,c.codpos
          from ttprobat a,temploy1 c
         where c.codcomp like p_codcomp||'%'  --หน่วยงาน
           and ((a.dteduepr between p_dteduepr_str and p_dteduepr_end) or p_codempid is not null) 
           and a.codempid = nvl(p_codempid,a.codempid) --รหัสพนักงาน
           and a.typproba = p_namtpro
           and a.codrespr = p_nameval
           and a.staupd in ('C','U')   -- STAUPD	สถานะ (C-อนุมัติ  U-ประมวลผลแล้ว)
           and a.codempid  = c.codempid
           and a.dteduepr  = (select max(dteduepr)
                                from ttprobat b
                               where b.codempid = a.codempid
                                 and b.staupd in ('C','U'))
         order by a.codempid;
  begin
      obj_row := json_object_t ();
      for i in c_ttprobat loop      
        v_flg_found := true;
        begin
          select codempid,codcomp
            into v_codempid,v_codcomp
            from temploy1
           where codempid = i.codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
          return ;
        end;
        v_secur_codempid := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal );
        if v_secur_codempid then
          v_flg_permission := true;
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t ();
          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );
          obj_data.put('codrespr',get_tlistval_name('NAMEVAL',i.codrespr,global_v_lang));
          obj_data.put('typproba',get_tlistval_name('NAMTPRO', i.typproba, global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('numlettr',i.numlettr);
          obj_row.put(to_char(v_rcnt - 1),obj_data); 
        end if;
      end loop;

      if not v_flg_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttprobat');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      elsif not v_flg_permission then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        json_str_output := obj_row.to_clob;
      end if;
  exception when others then param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_get_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_probation_form ( json_str_output out clob ) is
    v_rcnt              number := 0;
    v_flg_permission    boolean := false;
    v_flg_found         boolean := false;
    v_flgedit           boolean := false;
    v_secur_codempid    boolean;
    v_codrespr          varchar2(100 char);
    v_value             varchar2(1000 char);
    v_numseq            number;

    cursor c1 is 
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
         and flgstd <> 'Y'
       order by ffield ;
  begin
    obj_row := json_object_t ();
    v_numseq := 23;
    for i in c1 loop      
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t ();
      obj_data.put('coderror','200');
      obj_data.put('codform',i.codform);
      obj_data.put('codtable',i.codtable);
      obj_data.put('ffield',i.ffield);
      obj_data.put('flgdesc',i.flgdesc);
      obj_data.put('flginput',i.flginput);
      obj_data.put('flgstd',i.flgstd);
      obj_data.put('fparam',i.fparam);
      obj_data.put('numseq',i.numseq);
      obj_data.put('section',i.section);
      obj_data.put('descript',i.descript);

      begin 
        select datainit1 into v_value
          from tinitial 
         where codapp = 'HRPM33R' 
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
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_probation_form;

  procedure get_probation_form ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_probation_form;
    if param_msg_error is null then
      gen_probation_form(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end; 
  --
  procedure gen_html_message (json_str_output out clob) AS

    o_message1        clob;
    o_namimglet       tfmrefr.namimglet%type;
    o_message2        clob;
    o_typemsg2        tfmrefr2.typemsg%type;
    o_message3        clob;

		obj_data		      json_object_t;
		v_rcnt			      number := 0;

    v_namimglet       tfmrefr.namimglet%type;
    tfmrefr_message   tfmrefr.message%type;
    tfmrefr2_message  tfmrefr2.message%type;
    tfmrefr2_typemsg  tfmrefr2.typemsg%type;
    tfmrefr3_message  tfmrefr3.message%type;
	begin
    gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);

    if o_namimglet is not null then
       o_namimglet := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMB9E')||'/'||o_namimglet;
    end if;
		obj_data := json_object_t();
		obj_data.put('coderror', '200');
    obj_data.put('head_html',o_message1);
    obj_data.put('body_html',o_message2);
    obj_data.put('footer_html',o_message3);
    obj_data.put('head_letter', o_namimglet);

		json_str_output := obj_data.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gen_html_message;
  --
  procedure get_html_message ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_probation_form;
    if param_msg_error is null then
      gen_html_message(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_json_obj ( json_str_input in clob ) is
  begin
    p_details       := hcm_util.get_json_t(json_object_t(json_str_input),'details');
    p_codempid_list := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    p_resultfparam  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str2');
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end get_json_obj;

--  procedure get_send_mail ( json_str_input in clob, json_str_output out clob ) is
--    p_numlettr varchar2(100 char);
--  begin
--    initial_value(json_str_input);
--    get_json_obj(json_str_input);
--    if param_msg_error is null then
----      send_mail(p_numlettr);
--      obj_row := json_object_t ();
--      obj_row.put('coderror','200');
--      obj_row.put('response',p_numlettr);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
--    json_str_output := obj_row.to_clob;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end;
--  procedure get_document ( json_str_input in clob, json_str_output out clob ) is
--    p_numlettr varchar2(100 char);
--  begin 
--    initial_value(json_str_input);
--    get_json_obj(json_str_input);  
--    if param_msg_error is null then
--      print_document;
--      send_mail(p_numlettr);
--      obj_row := json_object_t ();
--      obj_row.put('coderror','200');
--      obj_row.put('response',p_numlettr);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end;

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

    global_v_zyear := hcm_appsettings.get_additional_year() ;
		-- index
    p_detail_obj      := hcm_util.get_json_t(json_object_t(json_obj),'details');
		p_url             := hcm_util.get_string_t(json_object_t(json_obj),'url');
		p_codform         := hcm_util.get_string_t(p_detail_obj,'codform');
		p_dateprint_date  := to_date(trim(hcm_util.get_string_t(p_detail_obj,'dateprint')),'dd/mm/yyyy');
		p_numlettr        := hcm_util.get_string_t(p_detail_obj,'numlettr');
		p_codcomp         := hcm_util.get_string_t(p_detail_obj,'codcomp');
		p_codempid        := hcm_util.get_string_t(p_detail_obj,'codempid');
		p_month           := hcm_util.get_string_t(p_detail_obj,'month');
		p_year            := hcm_util.get_string_t(p_detail_obj,'year');
		p_namtpro         := hcm_util.get_string_t(p_detail_obj,'namtpro');
		p_nameval         := hcm_util.get_string_t(p_detail_obj,'nameval');

		p_dataSelectedObj := hcm_util.get_json_t(json_object_t(json_obj),'dataselected');
		p_resultfparam    := hcm_util.get_json_t(json_obj,'fparam');
    p_data_sendmail   := hcm_util.get_json_t(json_obj,'dataRows');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
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
  procedure printreport(json_str_input in clob, json_str_output out clob) as
	begin
		validateprintreport(json_str_input);
		if (param_msg_error is null or param_msg_error = ' ' ) then
      gen_report_data(json_str_output);
      if (param_msg_error is not null) then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end printreport;

  procedure gen_report_data ( json_str_output out clob) as
		itemSelected		json_object_t := json_object_t();

    v_codlang		    tfmrefr.codlang%type;
    v_day			      number;
    v_desc_month		varchar2(50 char);
    v_year			    varchar2(4 char);
    v_month         varchar(5 char);
    tdata_dteprint	varchar2(100 char);

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_numlettr      varchar2(1000 char);
    v_dteduepr      ttprobat.dteduepr%type;
    v_dteduepr2      ttprobat.dteduepr%type;
    v_dteeffec      ttprobat.dteeffec%type;

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

    data_file           clob;
		v_flgstd		        tfmrefr.flgstd%type;
		v_flgdesc		        tfmparam.flgdesc%type;
		v_namimglet		      tfmrefr.namimglet%type;
		v_folder		        tfolderd.folder%type;
    o_message1          clob;
    o_namimglet         tfmrefr.namimglet%type;
    o_message2          clob;
    o_typemsg2          tfmrefr2.typemsg%type;
    o_message3          clob;
    v_qtyexpand         ttprobat.qtyexpand%type;
    v_amtinmth          ttprobat.amtinmth%type;
    p_signid            varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_namesign          varchar2(1000 char);
    v_pathimg           varchar2(1000 char);
    v_date_std          varchar2(1000 char);
    v_filename          varchar2(1000 char);
    type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    -- Return Data
		v_resultcol		json_object_t ;
		v_resultrow		json_object_t := json_object_t();
		v_countrow		number := 0;

    obj_fparam      json_object_t := json_object_t();
    obj_rows        json_object_t;
    obj_result      json_object_t;
    arr_result      arr_1d;
	begin

		begin
			select codlang,namimglet,flgstd into v_codlang, v_namimglet,v_flgstd
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
		v_day           := to_number(to_char(p_dateprint_date,'dd'),'99');
		v_desc_month    := get_nammthful(to_number(to_char(p_dateprint_date,'mm')),v_codlang);
		v_year          := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(p_dateprint_date,'yyyy')));
		tdata_dteprint  := v_day||'/'||v_desc_month||'/'||v_year;
    numYearReport   := HCM_APPSETTINGS.get_additional_year();
--
		for i in 0..p_dataSelectedObj.get_size - 1 loop
			itemSelected  := hcm_util.get_json_t( p_dataSelectedObj,to_char(i));
      v_codempid    := hcm_util.get_string_t(itemSelected,'codempid');
      v_codcomp     := hcm_util.get_string_t(itemSelected,'codcomp');
      v_numlettr    := hcm_util.get_string_t(itemSelected,'numlettr');
      v_dteduepr    := to_date(hcm_util.get_string_t(itemSelected,'dteduepr'),'dd/mm/yyyy');

      if v_numlettr is null then
        begin
          select numlettr  into v_numlettr 
            from ttprobat
           where codempid = v_codempid
             and dteduepr = v_dteduepr;
        exception when no_data_found then 
          v_numlettr  :=  '';
        end;
        if v_numlettr is null then
          v_numlettr := get_docnum('2',hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
          begin 
            update ttprobat
               set numlettr = v_numlettr
             where codempid = v_codempid
               and dteduepr = v_dteduepr;
          end;
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
        select a.qtyexpand, stddec(a.amtinmth,a.codempid,v_chken),a.dteduepr,a.dteeffec
        into v_qtyexpand, v_amtinmth, v_dteduepr2,v_dteeffec
        from ttprobat a, temploy1 c
       where a.codempid = c.codempid
         and a.codempid = v_codempid
         and a.staupd in ('C','U');
      exception when no_data_found then
        v_qtyexpand := '';
      end ;
        -- Read Document HTML
        gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
				list_msg_html := html_array(o_message1,o_message2,o_message3);
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
              -->> fix issue #5422 user18
              /*v_date_std := get_label_name('HRPM33R1',global_v_lang,230) || ' ' ||to_number(v_day) ||' '|| 
                            get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' || 
                            get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);*/
              v_date_std := to_number(v_day) ||' '|| 
                            get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' || 
                            get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
             --<< fix issue #5422 user18                
            else
              v_date_std := to_char(add_months(p_dateprint_date, numYearReport*12),'dd/mm/yyyy');
            end if;
          end if; 
          --
          data_file := replace(data_file,'[PARAM-DOCID]',v_numlettr);
          data_file := replace(data_file,'[PARAM-DATE]',v_date_std);
          data_file := replace(data_file,'[PARAM-PROAMT]',to_char(v_amtinmth,'fm999,999,999,990.00')); -- TTPROBAT.AMTINMTH
          data_file := replace(data_file,'[PARAM-BAHTPROAMT]',get_amount_name(v_amtinmth,global_v_lang));
          data_file := replace(data_file,'[PARAM-COMPANY]',get_tcompny_name(get_codcompy(temploy1_obj.codcomp),global_v_lang));
          if p_namtpro = 1 then
            data_file := replace(data_file,'[PARAM-QTYPRODAY]',( temploy1_obj.dteduepr - temploy1_obj.dteempmt)+1);
          else
            data_file := replace(data_file,'[PARAM-QTYPRODAY]',( v_dteduepr2 - v_dteeffec)+1);
          end if;

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
--              exception when no_data_found then null;
--              end ;
--              if p_signpic is not null then
--                fparam_value := '<img src="'||p_url||'/'||p_signpic||'"width="60" height="30">';
--              else
--                fparam_value := '';
--              end if;
--            end if;
            data_file := replace(data_file, fparam_fparam, fparam_value);
          end loop;
          data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
          data_file := replace(data_file, chr(9), '&nbsp;');
          list_msg_html(i) := data_file;
        end loop;

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
        v_resultcol.put('numberdocument',v_numlettr);
        v_resultcol.put('codempid',v_codempid);
        v_resultcol.put('dteduepr',to_char(v_dteduepr,'dd/mm/yyyy'));
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
  end gen_report_data;
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
    v_tempdata      varchar(1000);
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
          v_tempdata := execute_desc(v_statmt);
          v_dataexct := to_char(add_months(to_date(v_tempdata,'dd/mm/yyyy'), numYearReport*12),'dd/mm/yyyy');
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
          v_dataexct := to_number(v_day) ||' '|| 
                        get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' || 
                        get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
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

  function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
	begin
		if ( hcm_util.get_string_t(objItem,bykey) = null or hcm_util.get_string_t(objItem,bykey) = ' ') then
			return '';
		else
			return hcm_util.get_string_t(objItem,bykey);
		end if;
	end name_in ;
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
       where codapp = 'HRPM33R'
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
       where codapp = 'HRPM33R'
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
    v_dteduepr                date;
    v_numseq                number;
	begin
    validateprintreport(json_str_input);
		begin
			select codform into v_codfrm_to
			from tfwmailh
			where codapp = 'HRPM33R';
		exception when no_data_found then
			v_codfrm_to := null;
		end;


		for i in 0..p_data_sendmail.get_size - 1 loop
      itemSelected  := hcm_util.get_json_t( p_data_sendmail,to_char(i));
      v_numdoc      := hcm_util.get_string_t(itemSelected,'numberdocument');
      v_filepath      := hcm_util.get_string_t(itemSelected,'filepath');
      v_filename      := hcm_util.get_string_t(itemSelected,'filename');
      v_codempid      := hcm_util.get_string_t(itemSelected,'codempid');
      v_dteduepr        := to_date(hcm_util.get_string_t(itemSelected,'dteduepr'),'dd/mm/yyyy');
      begin
        select rowid
          into v_rowid_query
          from ttprobat
         where codempid = v_codempid
             and dteduepr = v_dteduepr;
      exception when no_data_found then
        v_rowid_query := null;
      end;
      -- Get message
      begin
          chk_flowmail.get_message_result('HRPM33R', global_v_lang, v_msg_to, v_template_to);

          v_subject := get_label_name('HRPM33R1', global_v_lang, 130);

          chk_flowmail.replace_text_frmmail(v_template_to, 'ttprobat', v_rowid_query , v_subject , 'HRPM33R', '1', null, global_v_coduser, global_v_lang, v_msg_to,'Y',v_filename);

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

end HRPM33R;

/
