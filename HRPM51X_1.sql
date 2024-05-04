--------------------------------------------------------
--  DDL for Package Body HRPM51X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM51X" is
-- last update: 09/02/2021 18:01 #2043

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_zyear      := hcm_appsettings.get_additional_year() ;

    p_codcomp          := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid         := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codmove          := hcm_util.get_string_t(json_obj,'p_codmove');
    p_dteffecst         := to_date(hcm_util.get_string_t(json_obj,'p_dteffecst'),'dd/mm/yyyy');
    p_dteffecen         := to_date(hcm_util.get_string_t(json_obj,'p_dteffecen'),'dd/mm/yyyy');

    p_dtestr_str       := hcm_util.get_string_t(json_obj,'p_datestr') ;
    p_dteend_str       := hcm_util.get_string_t(json_obj,'p_dateend') ;
    p_type_data        := hcm_util.get_string_t(json_obj,'p_type_data');

    p_dtprint          := hcm_util.get_string_t(json_obj,'p_dtprint');
    p_stacaselw        := hcm_util.get_string_t(json_obj,'p_stacaselw');

    begin
      select typmove into p_type_move
      from tcodmove
      where codcodec = p_codmove;
    exception when no_data_found then
      p_type_move := '';
    end;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure validate_getindex(json_str_input in clob) as
    v_staemp      number;
    v_chknum      number;
    v_codmove      varchar2(10 char);
    flgpass     boolean;
    p_zupdsal   varchar2(1 char);

    begin
      if ((p_codcomp is null or p_codcomp = ' ') and (p_codempid is null or p_codempid = ' ')) then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return ;
      end if;
      if (p_codcomp <> ' ' and p_codcomp is not null ) then
        if not secur_main.secur7(p_codcomp,global_v_coduser) then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return ;
        end if;
      end if;
      if (p_codempid is not null) then
        begin
          select staemp  into v_staemp
          from temploy1
          where codempid = p_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TEMPLOY1');
          return ;
        end;
        if (v_staemp = 0) then
          param_msg_error := get_error_msg_php('HR2102',global_v_lang,null);
          return ;
        end if;
        if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return ;
        end if;
      end if;
      if p_codmove is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      else
        begin
          select CODCODEC into v_codmove
          from TCODMOVE
          where CODCODEC = p_codmove;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TCODMOVE');
          return ;
        end;
      end if;
      if p_codcomp is null then
        begin
          select codcomp into p_codcomp
          from temploy1
          where codempid = p_codempid;
        exception when no_data_found then
          p_codcomp := '';
        end;
      end if;
      begin
        select count(*) into v_chknum
        from tdocrnum
        where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TDOCRNUM');
        return ;
      end;
    end validate_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_getindex(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_numhmref      tdocinf.numhmref%type;
    v_typdoc        tdocinf.typdoc%type;
    v_flgdata       varchar2(1 char);
    v_flagsecur     varchar2(1 char);
    v_count         number := 0;
    v_typmove       tcodmove.typmove%type;

    -- [p_type_data : 1]
    cursor c1_td1_tm5 is
      select codempid,codcomp,numlvl,dteeffec,desmist1,codpos,numannou
        from ttmistk
       where codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid, codempid)
         and dteeffec between p_dteffecst and p_dteffecen
         and staupd not in ('N','P')
       order by dteeffec,codempid;

    cursor c1_td1_tm6 is
      select codempid,codcomp,numlvl,dteeffec,codpos,numannou
        from ttexempt
       where codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid, codempid)
         and dteeffec between p_dteffecst and  p_dteffecen
         and staupd not in ('N','P')
       order by dteeffec,codempid;

    cursor c_ttmovemt is
      select codempid,codcomp,numlvl,dteeffec,numseq,codpos,numannou
        from ttmovemt
       where codcompt like p_codcomp||'%'
         and codempid = nvl(p_codempid, codempid)
         and dteeffec between p_dteffecst and  p_dteffecen
         and codtrn = p_codmove
         and staupd not in ('N','P')
       order by dteeffec,codempid;

    v_flgpass BOOLEAN;
    v_zupdsal VARCHAR2(1 CHAR);
    countrow number;
  begin
    obj_row   := json_object_t();
    obj_data  := json_object_t();
    countrow  := 0 ;
    v_rcnt    := 0;

    begin
      select typmove
      into v_typmove
      from tcodmove
      where codcodec = p_codmove;
    end;

    if p_codmove = '0005' then
      for r1 in c1_td1_tm5 loop
        obj_data  := json_object_t();
        v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgpass = true then
          obj_data.put('coderror', '200');
          obj_data.put('rcnt', to_char(v_rcnt));
          obj_data.put('typmove', v_typmove);
          obj_data.put('image', get_emp_img (r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
          obj_data.put('codpos', r1.codpos);
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('numdoc', r1.numannou);
          obj_row.put(to_char(v_rcnt),obj_data);
          v_rcnt := v_rcnt+1;
        end if;
        countrow := countrow + 1;
      end loop;
      if countrow <= 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTMISTK');
      elsif v_rcnt <= 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    elsif p_codmove = '0006' then
      for r1 in c1_td1_tm6 loop
        obj_data    := json_object_t();
        v_flgpass :=   secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgpass = true then
          obj_data.put('coderror', '200');
          obj_data.put('rcnt', to_char(v_rcnt));
          obj_data.put('typmove', v_typmove);
          obj_data.put('image',get_emp_img (r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang) );
          obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
          obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('codpos',r1.codpos);
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('numdoc',r1.numannou);
          obj_row.put(to_char(v_rcnt),obj_data);
          v_rcnt      := v_rcnt+1;
        end if;
        countrow := countrow + 1;
      end loop;
      if countrow <= 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTEXEMPT');
      elsif v_rcnt <= 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    else
      for r1 in c_ttmovemt loop
        obj_data    := json_object_t();
        v_flgpass :=   secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgpass = true then
          if v_typmove = 'A' then
            if v_zupdsal = 'Y' then
              obj_data.put('coderror', '200');
              obj_data.put('rcnt', to_char(v_rcnt));
              obj_data.put('typmove', v_typmove);
              obj_data.put('image',get_emp_img (r1.codempid));
              obj_data.put('codempid', r1.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang) );
              obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
              obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
              obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
              obj_data.put('codpos',r1.codpos);
              obj_data.put('codcomp', r1.codcomp);
              obj_data.put('numdoc',r1.numannou);
              obj_data.put('numseq',r1.numseq);
              obj_row.put(to_char(v_rcnt),obj_data);
              v_rcnt      := v_rcnt+1;
            end if;
          else
            obj_data.put('coderror', '200');
            obj_data.put('rcnt', to_char(v_rcnt));
            obj_data.put('typmove', v_typmove);
            obj_data.put('image',get_emp_img (r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang) );
            obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('codpos',r1.codpos);
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('numdoc',r1.numannou);
            obj_data.put('numseq',r1.numseq);
            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt      := v_rcnt+1;
          end if;
        end if;
        countrow := countrow + 1;
      end loop;
      if countrow <= 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTMOVEMT');--08/12/2020
      elsif v_rcnt <= 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
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
       where codapp = 'HRPM51X'
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
       where codapp = 'HRPM51X'
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_html_message;

  procedure gen_html_message (json_str_input in clob, json_str_output out clob) AS

    o_html_1 clob;
    o_typemsg1  varchar2(10 CHAR);
    o_html_2  clob;
    o_typemsg2  varchar2(10 CHAR);
    o_html_3  clob;

    obj_data        json_object_t;
    v_rcnt          number := 0;

  begin

    gen_html_form(p_codform,o_html_1,o_typemsg1,o_html_2,o_typemsg2,o_html_3);

    obj_data := json_object_t();

    obj_data :=  append_clob_json (obj_data,  'head_html',  o_html_1  );
    obj_data :=  append_clob_json (obj_data,  'body_html' , o_html_2  );
    obj_data :=  append_clob_json (obj_data,  'footer_html', o_html_3  );

    obj_data.put('coderror', '200');
    obj_data.put('response','');

    json_str_output := obj_data.to_clob;

   exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

  end gen_html_message;

  procedure gen_html_form(p_codform in varchar2, o_message1 out clob, o_typemsg1 out varchar2,
                          o_message2 out clob, o_typemsg2 out varchar2, o_message3 out clob ) as
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure initial_prarameterreport (json_str in clob ) is
   json_obj        json_object_t;
  begin
   v_chken      := hcm_secur.get_v_chken;
   json_obj     := json_object_t(json_str);
   p_codform    := hcm_util.get_string_t(json_obj,'p_codform');
   p_codmove    := hcm_util.get_string_t(json_obj,'p_codmove');
   p_dteprint   := to_date(hcm_util.get_string_t(json_obj,'p_dteprint'),'dd/mm/yyyy');
   p_flgpost    := hcm_util.get_string_t(json_obj,'p_flgpost');

  end initial_prarameterreport;

  procedure validate_v_getprarameterreport(json_str_input in clob) as
    count_row_tfmrefr number := 0 ;
    v_typfm tfmrefr.typfm%type;

  begin
    if (p_codform is null or p_codform = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return ;
    end if;
    if (p_codmove is null or p_codmove = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return ;
    end if;
    begin
      select count(*) into count_row_tfmrefr
        from tfmrefr
       where codform = p_codform;
      if (count_row_tfmrefr = 0 ) then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TFMREFR');
        return ;
      end if;
      v_typfm :=  get_tfmtrfr_typfm(p_codform);
      select typmove into p_type_move
      from tcodmove
      where codcodec = p_codmove;
    end;

    if p_codmove = '0005'  then
      if ( v_typfm <> 'HRPM51X3' ) then
        --redmine#2043 param_msg_error := '1'||get_error_msg_php('HR2 020',global_v_lang);
        param_msg_error := get_error_msg_php('PM0132',global_v_lang);
      end if;
    elsif p_codmove = '0006' then
      if (v_typfm <> 'HRPM51X4') then
        --redmine#2043 param_msg_error := '2'||get_error_msg_php('HR2 020',global_v_lang);
        param_msg_error := get_error_msg_php('PM0133',global_v_lang);
      end if;
    elsif p_codmove = '0007' then
      if (v_typfm <> 'HRPM51X5') then
        --redmine#2043 param_msg_error := '3'||get_error_msg_php('HR2 020',global_v_lang);
        param_msg_error := get_error_msg_php('PM0134',global_v_lang);
      end if;
    elsif p_type_move = 'A' then
      if (v_typfm <> 'HRPM51X2') then
        --redmine#2043 param_msg_error := '4'||get_error_msg_php('HR2 020',global_v_lang);
        param_msg_error := get_error_msg_php('PM0135',global_v_lang);
      end if;
    else
      if v_typfm <> 'HRPM51X1' then
        --redmine#2043 param_msg_error := '5'||get_error_msg_php('HR2 020',global_v_lang);
        param_msg_error := get_error_msg_php('PM0136',global_v_lang);
      end if;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end validate_v_getprarameterreport;

  procedure gen_prarameterreport (json_str_output out clob) as
    cursor c1 is
        select *
        from  tfmparam
        where codform = p_codform
        and   flginput = 'Y'
        and   flgstd = 'N'
        order by ffield ;

    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    v_timest        date;
    v_timediff      varchar2(100 char);
    v_value             varchar2(1000 char);
    v_numseq            number;
    v_flgedit           boolean := false;

  begin
  v_timest := systimestamp;

    obj_row := json_object_t();
    v_numseq := 23;
    for r1 in c1 loop
       v_rcnt      := v_rcnt+1;
        obj_data :=   json_object_t();
       obj_data.put('coderror', '200');
       obj_data.put('codform',r1.codform);
       obj_data.put('section',r1.section);
       obj_data.put('numseq',r1.numseq);
       obj_data.put('codtable',r1.codtable);
       obj_data.put('fparam',r1.fparam);
       obj_data.put('ffield',r1.fparam);
       obj_data.put('descript',r1.descript);
       obj_data.put('ffinput',r1.FFIELD);
       obj_data.put('flgdesc',r1.flgdesc);
      begin 
        select datainit1 into v_value
          from tinitial 
         where codapp = 'HRPM51X' 
           and numseq = v_numseq;
           v_flgedit := true;
      exception when no_data_found then
        v_flgedit := false;
        v_value := '';
      end;
      obj_data.put('flgEdit',v_flgedit);
      obj_data.put('value',v_value);
      obj_row.put(to_char(v_rcnt-1),obj_data);
      v_numseq  := v_numseq + 1;
    end loop;
    json_str_output := obj_row.to_clob;

   exception when others then
     param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end gen_prarameterreport;

  procedure initial_word(json_str_input in clob) AS
		json_obj		json_object_t;
    v_codform   varchar2(100 char);
	BEGIN
		json_obj := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    global_v_zyear    := hcm_appsettings.get_additional_year() ;
    v_chken           := hcm_secur.get_v_chken;

    p_detail_obj      := hcm_util.get_json_t(json_object_t(json_obj),'details');
		p_data_selected   := hcm_util.get_json_t(json_obj,'dataselected');
		p_data_parameter  := hcm_util.get_json_t(json_obj,'fparam');
    p_data_sendmail   := hcm_util.get_json_t(json_obj,'dataRows');
    p_sendMailInfo    := hcm_util.get_json_t(json_obj,'sendInfo');
		p_url             := hcm_util.get_string_t(json_object_t(json_obj),'url');

		p_codempid        := hcm_util.get_string_t(p_detail_obj,'codempid');
		p_codcomp         := hcm_util.get_string_t(p_detail_obj,'codcomp');
		p_dateprint       := to_date(hcm_util.get_string_t(p_detail_obj,'dateprint'),'dd/mm/yyyy');
		p_dteffecst       := to_date(hcm_util.get_string_t(p_detail_obj,'dteffecst'),'dd/mm/yyyy');
		p_dteffecen       := to_date(hcm_util.get_string_t(p_detail_obj,'dteffecen'),'dd/mm/yyyy');
		p_codform         := hcm_util.get_string_t(p_detail_obj,'codform');
    p_codmove         := hcm_util.get_string_t(p_detail_obj,'codmove');
--		p_sendemail       := hcm_util.get_string_t(p_detail_obj,'sendemail');

    p_flagnotic       :=  hcm_util.get_string_t(p_detail_obj,'flgpost');
    p_type_data       := hcm_util.get_string_t(p_detail_obj,'type_data');

--    p_html_head   :=  get_clob(json_str_input,'html_head');
--		p_html_body   :=  get_clob(json_str_input,'html_body') ;
--		p_html_footer :=  get_clob(json_str_input,'html_footer');


    p_day_display_dateprint    := to_number(to_char(p_dateprint,'dd'),'99');
    p_month_display_dateprint  :=  get_nammthful(to_number(to_char(p_dateprint,'mm')),global_v_lang);
    p_year_disaplay_dateprint  :=  get_ref_year(global_v_lang,global_v_zyear,to_number(to_char(p_dateprint,'yyyy')));
    p_display_dateprint        :=  p_day_display_dateprint || ' ' ||p_month_display_dateprint|| ' ' ||p_year_disaplay_dateprint;

    if p_dateprint is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dateprint');
			return ;
		end if ;

		if (p_codform is not null and p_codform <> ' ') then
			begin
				select codform into v_codform
				from tfmrefr
				where codform = p_codform;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TFMREFR');
				return;
			end;
      end if;
	END initial_word;

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

  procedure gen_report_data(  json_str_output out clob) as
    v_typemsg       tfmrefr2.typemsg%type;
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
		v_resultmulti		json_object_t := json_object_t();
    obj_rows      json_object_t;
    obj_result    json_object_t;
    obj_listfilter  json_object_t;
    obj_income    json_object_t;
    obj_multi     json_object_t := json_object_t();
		v_countrow		number := 0;

    v_numseq       number;

		type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    data_multi        clob;
    arr_result        arr_1d;
    obj_fparam        json_object_t := json_object_t();
    v_codempid        temploy1.codempid%type;
    v_codcomp		      temploy1.codcomp%type;
    v_codpos		      temploy1.codpos%type;
    v_dteeffec		    date;
    v_docnum			    varchar2(100 char);

    temploy1_obj		  temploy1%rowtype;
    temploy3_obj		  temploy3%rowtype;
    ttmovemt_obj		  ttmovemt%rowtype;
    ttmistk_obj		    ttmistk%rowtype;

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
		v_folder		        tfolderd.folder%type;
    v_namesign          varchar2(1000 char);
    p_signid            varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_numlettr          varchar2(1000 char);
    v_pathimg           varchar2(1000 char);
    v_date_std          varchar2(1000 char);
    v_flgdesc           tfmparam.flgdesc%type;
    v_filename          varchar2(1000 char);
    v_flgdata           varchar2(2 char);
    v_data              long;
    v_data2             long;
    v_data_descmist     long;

    v_desc_amtincom_s   varchar2(4000 char);
    v_amtincom_a        number := 0;
    v_amtincom_s        number := 0;
    v_sumhur		        number := 0;
		v_sumday		        number := 0;
		v_summon		        number := 0;
		v_numseq_doc		    number := 0;
    v_num               number := 0;
    v_amtded            number := 0;
    v_desc_codpay       varchar(300 char);
    v_period            varchar(300 char);
    v_typdoc            varchar(1 char);
    v_datasal           clob;
    v_codincom          varchar2(1000 char);
    v_desincom          varchar2(1000 char);
    v_desunit           varchar2(1000 char);
    v_amtmax            varchar2(1000 char);
    v_trn_income        varchar2(4000 char);
    v_amtincadj         varchar2(1000 char);
    v_amtincom          varchar2(1000 char);
    v_statmt		        long;
    v_flgFirst		      varchar2(1 char) := 'Y';

    cursor c1 is
      select codcodec
        from tcodmist
       order by codcodec;

    cursor c2 is 
      select typpun,codpunsh,dtestart,dteend,flgexempt,dteeffec
        from ttpunsh
       where codempid = v_codempid
         and dteeffec = v_dteeffec
       order by numseq;
  begin
    v_typemsg := get_typemsg_by_codform(p_codform);

    if (v_typemsg is null) then
      param_msg_error := get_error_msg_php('HR2071',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return ;
    else
      begin
        select typmove into p_type_move
          from tcodmove
         where codcodec = p_codmove;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return ;
      end;
    end if;
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
    numYearReport   := HCM_APPSETTINGS.get_additional_year();
    -- check typedoc
    --
    for i in 0..p_data_selected.get_size - 1 loop
			itemSelected  := hcm_util.get_json_t( p_data_selected,to_char(i));
      v_codempid    := hcm_util.get_string_t(itemSelected,'codempid');
      v_codcomp     := hcm_util.get_string_t(itemSelected,'codcomp');
      v_codpos      := hcm_util.get_string_t(itemSelected,'codpos');
      v_numseq      := nvl(hcm_util.get_string_t(itemSelected,'numseq'),'');
      v_dteeffec    := to_date(hcm_util.get_string_t(itemSelected,'dteeffec'),'dd/mm/yyyy');
      v_numlettr    := hcm_util.get_string_t(itemSelected,'numdoc');
      if v_numlettr is null then
        if (p_codmove = '0005') then
          v_typdoc := '1';
          begin
            select numannou  into v_numlettr
              from ttmistk
             where codempid = v_codempid
               and dteeffec = v_dteeffec;
          exception when no_data_found then
            v_numlettr  :=  '';
          end;
          if v_numlettr is null then
            gen_numannou(p_codmove, p_type_move, v_codempid, v_codcomp, to_char(v_dteeffec,'dd/mm/yyyy'), v_numseq, v_numlettr);
          end if;
        elsif (p_codmove = '0006') then
          v_typdoc := '1';
          begin
            select numannou  into v_numlettr
              from ttexempt
             where codempid = v_codempid
               and dteeffec = v_dteeffec;
          exception when no_data_found then
            v_numlettr  :=  '';
          end;
          if v_numlettr is null then
            gen_numannou(p_codmove, p_type_move, v_codempid, v_codcomp, to_char(v_dteeffec,'dd/mm/yyyy'), v_numseq, v_numlettr);
          end if;
        elsif (p_type_move = 'A') then
          v_typdoc := '2';
          begin
            select numannou  into v_numlettr
              from ttmovemt
             where codempid = v_codempid
               and dteeffec = v_dteeffec
               and numseq = v_numseq;
          exception when no_data_found then
            v_numlettr  :=  '';
          end;
          if v_numlettr is null then
            gen_numannou(p_codmove, p_type_move, v_codempid, v_codcomp, to_char(v_dteeffec,'dd/mm/yyyy'), v_numseq, v_numlettr);
          end if;
        elsif ( p_codmove <> '0005' and p_codmove <> '0006' and p_type_move <> 'A' ) then
          v_typdoc := '1';
          begin
            select numannou  into v_numlettr
              from ttmovemt
             where codempid = v_codempid
               and dteeffec = v_dteeffec
               and numseq = v_numseq;
          exception when no_data_found then
            v_numlettr  :=  '';
          end;
          if v_numlettr is null then
            gen_numannou(p_codmove, p_type_move, v_codempid, v_codcomp, to_char(v_dteeffec,'dd/mm/yyyy'), v_numseq, v_numlettr);
          end if;
        end if;
      else
        if (p_codmove = '0005') then
          v_typdoc := '1';
        elsif (p_codmove = '0006') then
          v_typdoc := '1';
        elsif (p_type_move = 'A') then
          v_typdoc := '2';
        elsif ( p_codmove <> '0005' and p_codmove <> '0006' and p_type_move <> 'A' ) then
          v_typdoc := '1';
        end if;
      end if;
      -- delete data report
      begin
        delete tdocinf
        where numhmref = v_numlettr
        and typdoc = v_typdoc
        and codempid = v_codempid;
      end;
      begin
        delete tdocinfd
         where numhmref = v_numlettr
           and typdoc = v_typdoc
           and codempid = v_codempid;
      end;
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
      begin
        select *
          into ttmistk_obj
          from ttmistk
         where codempid = v_codempid
           and dteeffec = v_dteeffec;
      exception when no_data_found then
        ttmistk_obj := null;
      end;
      -- Read Document HTML
      gen_html_form(p_codform,o_html_1,o_typemsg1,o_html_2,o_typemsg2,o_html_3);
      list_msg_html := html_array(o_html_1,o_html_2,o_html_3);
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
        v_amtincom_a := v_summon; -- รายได้ต่อเดือน
        v_desc_amtincom_s := get_amount_name(v_amtincom_a,v_codlang);
        if (p_codmove = '0005') then
          --
          v_data := '<table class="border-table" width="100%">';
          v_data := v_data||'<tr bgcolor="#819FF7">
                               <td class="border-table" width="25%"  align="center">'||get_label_name('HRPM57X2', v_codlang, 200)||'</td>
                               <td class="border-table" width="25%" align="center">'||get_label_name('HRPM57X2', v_codlang, 210)||'</td>
                               <td class="border-table" width="15%" align="center">'||get_label_name('HRPM57X2', v_codlang, 220)||'</td>
                               <td class="border-table" width="15%" align="center">'||get_label_name('HRPM57X2', v_codlang, 230)||'</td>
                               <td class="border-table" width="20%" align="center">'||get_label_name('HRPM57X2', v_codlang, 240)||'</td>
                             </tr>';
          v_flgdata := 'N';
          v_flgFirst := 'Y';
          v_data_descmist := '';
          for r2 in c2 loop
            if v_flgFirst <> 'Y' then
              v_data_descmist := v_data_descmist || '<br>';
            end if;
            v_flgdata := 'Y';
            v_data := v_data||'<tr>
                                 <td class="border-table" >'||get_tlistval_name('NAMTPUN', r2.typpun, v_codlang)||'</td>
                                 <td class="border-table" >'||get_tcodec_name('TCODPUNH', r2.codpunsh, v_codlang)||'</td>
                                 <td class="border-table" align="center">'||to_char(add_months(r2.dtestart, global_v_zyear * 12), 'dd/mm/yyyy')||'</td>
                                 <td class="border-table" align="center">'||to_char(add_months(r2.dteend, global_v_zyear * 12), 'dd/mm/yyyy')||'</td>
                                 <td class="border-table" align="center">'||r2.flgexempt||'</td>
                               </tr>';
            if r2.dtestart is not null or r2.dteend is not null then
              v_data_descmist := 	v_data_descmist||' '||
                                  get_tcodec_name('TCODPUNH', r2.codpunsh, v_codlang) || ' ' ||
                                  get_label_name('HRPM51X2',v_codlang,150) || ' ' ||
                                  to_number(to_char(r2.dtestart,'dd'),'99')||' '||
                                  get_nammthabb(to_char(r2.dtestart,'mm'),v_codlang)||' '||
                                  (to_number(to_char(r2.dtestart,'yyyy')) + global_v_zyear)||' - '||
--                                  get_ref_year(global_v_lang, numYearReport, to_number(to_char(r2.dtestart,'yyyy')))||' - '||
                                  to_number(to_char(r2.dteend,'dd'),'99')||' '||
                                  get_nammthabb(to_char(r2.dteend,'mm'),v_codlang)||' '||
                                  (to_number(to_char(r2.dteend,'yyyy')) + global_v_zyear);
--                                  get_ref_year(global_v_lang, numYearReport, to_number(to_char(r2.dteend,'yyyy')));
            else
              v_data_descmist := v_data_descmist||' '||get_tcodec_name('TCODPUNH', r2.codpunsh, v_codlang);
            end if;
            if r2.typpun = '1' then
              begin
                select stddec(amtded,codempid, 2017),get_tinexinf_name(codpay,102),
                       numprdst||'/'||dtemthst||'/'||dteyearst||' - '||numprden||'/'||dtemthen||'/'||dteyearen as period
                into v_amtded ,v_desc_codpay , v_period 
                from ttpunded  
                where codempid = v_codempid
                and dteeffec = r2.dteeffec
                and codpunsh = r2.codpunsh
                order by codpunsh,dteeffec,codpay;
              exception when no_data_found then
                v_desc_codpay := null;
                v_amtded := null;
                v_period := null;
              end;
              v_data_descmist := v_data_descmist||' '||
                                 v_desc_codpay || ' ' || 
                                 to_char(to_number(v_amtded),'9,999,990.00') || ' ' || 
                                 get_label_name('HRPM51X2', v_codlang, 160) || ' ' ||
                                 v_period;
            end if;
            v_flgFirst  :=  'N';
          end loop;
          v_data     := v_data||'</table>';
          if v_flgdata = 'N' then
            v_data := '';
            v_data_descmist := '';
          end if;
          v_data2 := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
          for r1 in c1 loop
            v_num := v_num + 1;
            if mod(v_num,2) = 1 then
              v_data2     := v_data2||'<tr>';
            end if;
            if ttmistk_obj.codmist = r1.codcodec then
              v_data2 := v_data2||'<td width="5%">'||'[' || 'x' || ']'||'  '||get_tcodec_name('TCODMIST', r1.codcodec, v_codlang)||'</td>';
            else
              v_data2 := v_data2||'<td width="5%">'||'[ ' || '&nbsp;' || ']'||'  '||get_tcodec_name('TCODMIST', r1.codcodec, v_codlang)||'</td>';
            end if;
            if mod(v_num,2) = 0 then
              v_data2     := v_data2||'</tr>';
            end if;
          end loop;
          v_data2    := v_data2||'</table>';
        elsif (p_codmove = '0006') then
          null;
        elsif (p_codmove = 'A') then
          -- get income
          v_datasal := hcm_pm.get_codincom('{"p_codcompy":'''||hcm_util.get_codcomp_level(temploy1_obj.codcomp,1)||''',"p_dteeffec":'''||to_char(v_dteeffec,'dd/mm/yyyy')||''',"p_codempmt":'''||temploy1_obj.codempmt||''',"p_lang":'''||global_v_lang||'''}');
          obj_listfilter := json_object_t(v_datasal);
          v_trn_income := '';
          v_flgFirst := 'Y';
          for index_item in  0..obj_listfilter.get_size-1 loop
            obj_income    := hcm_util.get_json_t( obj_listfilter,to_char(index_item));
            v_codincom    :=  hcm_util.get_string_t(obj_income,'codincom');
            v_desincom    :=  hcm_util.get_string_t(obj_income,'desincom');
            v_desunit     :=  hcm_util.get_string_t(obj_income,'desunit');
            v_amtmax      :=  hcm_util.get_string_t(obj_income,'amtmax');
            if v_codincom is not null and v_amtmax is not null then
              v_statmt := 'select amtincadj'|| (index_item+1) || ', amtincom' || (index_item+1) || ' ' ||
                          'from ttmovemt '|| ' ' ||
                          'where codempid = ''' || v_codempid || ''' ' ||
                          'and dteeffec = ''' || v_dteeffec || ''' ' ||
                          'and numseq = ' || v_numseq;
              begin
              EXECUTE IMMEDIATE v_statmt into v_amtincadj, v_amtincom;
              exception when no_data_found then
                v_amtincadj := '';
                v_amtincom := '';
              end;
              if stddec(v_amtincadj,v_codempid,v_chken) > 0 then
                if v_flgFirst <> 'Y' then
                  v_trn_income := v_trn_income || '<br>';
                end if;
                v_trn_income  :=  v_trn_income || '' || 
                                  v_desincom || '\t' || 
                                  get_label_name('HRPM51X2',v_codlang,110) || '\t' || to_char(v_amtmax,'fm999,999,990.00') || '\t' || get_label_name('HRPM51X2',v_codlang,140) || ' ' ||
                                  get_label_name('HRPM51X2',v_codlang,120) || '\t' || to_char(stddec(v_amtincadj,v_codempid,v_chken),'fm999,999,990.00') || '\t' || get_label_name('HRPM51X2',v_codlang,140) || ' ' ||
                                  get_label_name('HRPM51X2',v_codlang,130) || '\t' || to_char(stddec(v_amtincom,v_codempid,v_chken),'fm999,999,990.00') || '\t' || get_label_name('HRPM51X2',v_codlang,140); 
                v_flgFirst  :=  'N';
              end if;
            end if;
          end loop;
        elsif ( p_codmove <> '0005' and p_codmove <> '0006' and p_type_move <> 'A' ) then
          null;
        end if;
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
              v_date_std := get_label_name('HRPM33R1',v_codlang,230) || ' ' ||to_number(v_day) ||' '||
                            get_label_name('HRPM33R1',v_codlang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),v_codlang) || ' ' ||
                            get_label_name('HRPM33R1',v_codlang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
            else
              v_date_std := to_char(add_months(p_dateprint, numYearReport*12),'dd/mm/yyyy');
            end if;
          end if;
          -- input from display
					data_file := replace(data_file,'[PARAM-DOCID]', v_numlettr);
					data_file := replace(data_file,'[PARAM-DATE]', v_date_std);
					data_file := replace(data_file,'[PARAM-SUBJECT]', get_tcodec_name('TCODMOVE', p_codmove, v_codlang));
					data_file := replace(data_file,'[PARAM-MOVAMT]', to_char(v_amtincom_a,'fm999,999,999,990.00'));
					data_file := replace(data_file,'[PARAM-BAHTMOVAMT]', v_desc_amtincom_s);
					data_file := replace(data_file,'[PARAM-AMTSAL]', v_trn_income);
          data_file := replace(data_file,'[PARAM-COMPANY]',get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp,1),v_codlang));
          data_file := replace(data_file,'[PARAM-PUNSH]',v_data);
          data_file := replace(data_file,'[PARAM-MISTK]',v_data2);
          data_file := replace(data_file,'[PARAM-DESCMISTK]',v_data_descmist);

          for j in 0..p_data_parameter.get_size - 1 loop
            obj_fparam      := hcm_util.get_json_t( p_data_parameter,to_char(j));
            fparam_fparam   := hcm_util.get_string_t(obj_fparam,'fparam');
            fparam_numseq   := hcm_util.get_string_t(obj_fparam,'numseq');
            fparam_section  := hcm_util.get_string_t(obj_fparam,'section');
            fparam_value    := hcm_util.get_string_t(obj_fparam,'value');
            if fparam_fparam = '[PARAM-SIGNID]' then
              begin
                select get_temploy_name(codempid,v_codlang) into v_namesign
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
              if INSTR(data_file,'[PARAM-SIGNPIC]') > 0 then
                begin
                  select nvl(max(numseq),0) + 1 into v_numseq_doc
                    from tdocinfd
                   where NUMHMREF = v_numlettr
                     and TYPDOC = v_typdoc
                     and CODEMPID = v_codempid;
                end;
                begin
                  insert into tdocinfd(NUMHMREF, TYPDOC, CODEMPID, FPARAM, FVALUE, numseq, codcreate, coduser)
                  values (v_numlettr, v_typdoc, v_codempid, '[PARAM-SIGNPIC]', fparam_signpic, v_numseq_doc, global_v_coduser, global_v_coduser);
                exception when DUP_VAL_ON_INDEX then
                  null;
                end;
              end if;
              data_file := replace(data_file, '[PARAM-SIGNPIC]', fparam_signpic);
            end if;
            if INSTR(data_file,fparam_fparam) > 0 then
                begin
                  select nvl(max(numseq),0) + 1 into v_numseq_doc
                    from tdocinfd
                   where NUMHMREF = v_numlettr
                     and TYPDOC = v_typdoc
                     and CODEMPID = v_codempid;
                end;
              begin
                insert into tdocinfd(NUMHMREF, TYPDOC, CODEMPID, FPARAM, FVALUE, numseq, codcreate, coduser)
                values (v_numlettr, v_typdoc, v_codempid, fparam_fparam, fparam_value, v_numseq_doc, global_v_coduser, global_v_coduser);
              exception when DUP_VAL_ON_INDEX then
                null;
              end;
            end if;
            data_file := replace(data_file, fparam_fparam, fparam_value);
          end loop;

          data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
          data_file := replace(data_file, chr(9), '&nbsp;');
          list_msg_html(i) := data_file ;
          if i = 2 and v_typemsg = 'M' then
            data_multi := data_multi || data_file ;
          end if;
          begin
            insert into tdocinf(numhmref,typdoc,codempid,codtrn,codcomp,numseq,dteeffec,dtehmref,codform,flgnotic, codcreate, coduser)
            values (v_numlettr, v_typdoc, v_codempid, p_codmove, v_codcomp, v_numseq, v_dteeffec, p_dateprint, p_codform, p_flagnotic, global_v_coduser, global_v_coduser);
          exception when DUP_VAL_ON_INDEX then
            null;
          end;
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
        v_resultcol.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
        v_resultcol.put('numseq',nvl(v_numseq,''));
        v_resultcol.put('coderror', '200');
        v_resultcol.put('response','');
        v_resultrow.put(to_char(v_countrow), v_resultcol);
        v_countrow := v_countrow + 1;
    end loop; -- end of loop data
    commit;
    if v_typemsg = 'M' then
      obj_multi := hcm_util.get_json_t( v_resultrow,to_char(v_countrow-1));
      obj_multi := append_clob_json(obj_multi,'bodyhtml',data_multi);
      v_resultmulti.put(to_char(0), obj_multi);
      v_resultrow := v_resultmulti;
    end if;
    obj_rows  :=  json_object_t();
    obj_rows.put('rows',v_resultrow);

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',v_numlettr);
    obj_result.put('table',obj_rows);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report_data;

  procedure gen_numannou (v_codcodec in varchar2,
                          v_typemove in varchar2,
                          v_codempid in varchar2, 
                          v_codcomp in varchar2, 
                          v_dteeffec in varchar2, 
                          v_numseq in varchar2, 
                          v_numlett out varchar2) is

    v_newnumannou       varchar2(30);
    v_codcomp_tmp       temploy1.codcomp%type;
    v_ttmovemt_numseq   ttmovemt.numseq%type;
    v_ttmovemt_dteeffec ttmovemt.dteeffec%type;
    v_typdoc            varchar(1 char);
    v_chk               number := 0;
  begin
      if v_codcomp is null then
        begin
          select hcm_util.get_codcomp_level(codcomp,1) into v_codcomp_tmp
          from temploy1
          where codempid = v_codempid;
        exception when others then
          v_codcomp_tmp := null;
        end;
      end if;
      if v_codcomp_tmp is not null then
        begin
          select count(*) into v_chk
          from tdocrnum
          where codcompy = v_codcomp_tmp;
        exception when no_data_found then
          v_chk := 0;
        end;
        if v_chk = 0 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TDOCRNUM');
        end if;
      end if;
      if (v_codcodec = '0005') then
        v_typdoc := '1';
        v_newnumannou :=  get_docnum(v_typdoc, hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
        update ttmistk 
           set numannou = v_newnumannou
         where codempid = v_codempid
           and dteeffec   = to_date(v_dteeffec,'dd/mm/yyyy');

        update thismist 
           set numannou = v_newnumannou
         where codempid = v_codempid
           and dteeffec   = to_date(v_dteeffec,'dd/mm/yyyy');
      elsif (v_codcodec = '0006') then
        v_typdoc := '1';
        v_newnumannou :=  get_docnum(v_typdoc, hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);

        update ttexempt 
           set numannou = v_newnumannou,
               typdoc   = v_typdoc
         where codempid = v_codempid
           and dteeffec = to_date(v_dteeffec,'dd/mm/yyyy');

        update thismove 
           set numannou = v_newnumannou,
               typdoc   = v_typdoc
         where codempid = v_codempid
           and dteeffec   = to_date(v_dteeffec,'dd/mm/yyyy')
           and codtrn     = v_codcodec;
      elsif (v_typemove = 'A') then
        v_typdoc := '2';
        v_newnumannou :=  get_docnum(v_typdoc, hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
        update ttmovemt 
           set numannou = v_newnumannou,
               typdoc   = v_typdoc
         where codempid = v_codempid
           and dteeffec   = to_date(v_dteeffec,'dd/mm/yyyy')
           and numseq     = v_numseq;

        update thismove 
           set numannou = v_newnumannou,
               typdoc     = v_typdoc
         where codempid = v_codempid
           and dteeffec   = to_date(v_dteeffec,'dd/mm/yyyy')
           and codtrn     = v_codcodec
           and numseq     = v_numseq;
      elsif ( v_codcodec <> '0005' and v_codcodec <> '0006' and v_typemove <> 'A' ) then
        v_typdoc := '1';
        v_newnumannou :=  get_docnum(v_typdoc, hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang);
        update ttmovemt
           set numannou = v_newnumannou,
               typdoc   = v_typdoc
         where codempid = v_codempid
           and dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
           and numseq   = to_number(v_numseq);

        update thismove
           set numannou = v_newnumannou,
               typdoc   = v_typdoc
         where codempid = v_codempid
           and dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
           and codtrn   = v_codcodec
           and numseq   = to_number(v_numseq);
      end if;
      v_numlett := v_newnumannou;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_numannou;

  procedure print_report(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_word(json_str_input);
    if param_msg_error is null then
      gen_report_data(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end print_report;

  function get_typemsg_by_codform(p_codform in varchar2) return varchar2 is
    v_typemsg tfmrefr2.typemsg %type;
    begin
      begin
        select typemsg into v_typemsg
          from tfmrefr2
         where codform =  p_codform;
      exception when NO_DATA_FOUND then
        v_typemsg := null;
      end;
      return v_typemsg;
    end get_typemsg_by_codform;

  function get_tfmtrfr_typfm (v_codform  in varchar2) return varchar2 is
      v_typfm     tfmrefr.typfm%type;
    begin
      begin
        select typfm into v_typfm
          from tfmrefr
         where codform = v_codform ;
      exception when NO_DATA_FOUND then
        v_typfm := null;
      end;
      return v_typfm;
    end get_tfmtrfr_typfm;

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
          v_dataexct := get_label_name('HRPM57X2',v_codlang,250)||' '||to_number(v_day) ||' '||
                        get_label_name('HRPM57X2',v_codlang,260) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),v_codlang) || ' ' ||
                        get_label_name('HRPM57X2',v_codlang,270) || ' ' ||hcm_util.get_year_buddhist_era(v_year);

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

  function  get_item_property (p_table in VARCHAR2,p_field  in VARCHAR2)    return varchar2 is
    cursor c_datatype is
      select t.data_type as DATATYPE
        from user_tab_columns t
        where t.TABLE_NAME = p_table
        and t.COLUMN_NAME= substr(p_field, instr(p_field,'.')+1);
    valueDataType json_object_t := json_object_t();
  begin
    for i in c_datatype loop
       valueDataType.put('DATATYPE',i.DATATYPE);
    end loop;
    return   hcm_util.get_string_t(valueDataType,'DATATYPE');
  end get_item_property;

  function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
  begin
    if ( hcm_util.get_string_t(objItem,bykey) = null or  hcm_util.get_string_t(objItem,bykey) = ' ') then
      return '';
    else
      return  hcm_util.get_string_t(objItem,bykey);
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
    v_convert_json_to_clob  clob;
    v_new_json_clob         clob;
    v_summany_json_clob     clob;
    v_size                  number;
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
      return json_object_t(v_new_json_clob);
  end;
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
  procedure send_mail ( json_str_input in clob,json_str_output out clob) as
    obj_result      json_object_t;
		itemselected	  json_object_t;
    v_numdoc        varchar2(1000 char);
    v_filepath      varchar2(1000 char);
    v_filename      varchar2(1000 char);
    v_codempid      temploy1.codempid%type;
    v_dteeffec      date;
    v_numseq        number;
    v_flgSendEmp    varchar2(1 char);
    v_flgSendEmail  varchar2(1 char);
    v_desc_email1   varchar2(100 char);
    v_desc_email2   varchar2(100 char);
    v_desc_email3   varchar2(100 char);
    v_recieve       temploy1.codempid%type;
    v_dtereceive    date;
--		v_codfrm_to		  tfwmailh.codform%type;
    v_response      varchar2(4000 char);
    v_subject       tapplscr.desclabelt%type;
    ttmistk_obj		  ttmistk%rowtype;
    v_rowid_query		varchar2(100 char);
--		v_typesend		tfwmailh.typesend%type;
		v_msg_to        long;
		v_template_to   long;
		v_func_appr		  varchar2(10 char);
		v_error			    varchar2(10 char);
		v_table			    varchar2(20 char);
	begin
    initial_word(json_str_input);
    v_flgSendEmp    :=  hcm_util.get_string_t(p_sendMailInfo,'codempid');
    v_flgSendEmail  :=  hcm_util.get_string_t(p_sendMailInfo,'email');
    v_desc_email1   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email1');
    v_desc_email2   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email2');
    v_desc_email3   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email3');
    v_recieve       :=  hcm_util.get_string_t(p_sendMailInfo,'recieve');
    v_dtereceive    :=  to_date(hcm_util.get_string_t(p_sendMailInfo,'dtereceive'),'dd/mm/yyyy');

    if v_flgSendEmail = 'Y' then
      for i in 0..p_data_sendmail.get_size - 1 loop
        itemSelected  := hcm_util.get_json_t( p_data_sendmail,to_char(i));
        v_numdoc      := hcm_util.get_string_t(itemSelected,'numberdocument');
        v_filepath      := hcm_util.get_string_t(itemSelected,'filepath');
        v_filename      := hcm_util.get_string_t(itemSelected,'filename');
        v_codempid      := hcm_util.get_string_t(itemSelected,'codempid');
        v_numseq        := hcm_util.get_string_t(itemSelected,'numseq');
        v_dteeffec      := to_date(hcm_util.get_string_t(itemSelected,'dteeffec'),'dd/mm/yyyy');
      end loop;
      -- Get message
      begin
          chk_flowmail.get_message_result('HRPM51X', global_v_lang, v_msg_to, v_template_to);

          v_subject := get_tcodec_name('TCODMOVE', p_codmove, global_v_lang);

          chk_flowmail.replace_text_frmmail(v_template_to, v_table, null , v_subject , 'HRPM51X', '1', null, global_v_coduser, global_v_lang, v_msg_to,'Y', v_filepath);
          --
          if v_desc_email1 is not null then
            v_error := chk_flowmail.send_mail_to_emp (null, global_v_codempid, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filepath,null,null, null,v_desc_email1);
            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang,'EMAIL 1');
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            end if;
          end if;
          --
          if v_desc_email2 is not null then
            v_error := chk_flowmail.send_mail_to_emp (null, global_v_codempid, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filepath,null,null, null,v_desc_email2);
            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang,'EMAIL 2');
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            end if;
          end if;
          --
          if v_desc_email3 is not null then
            v_error := chk_flowmail.send_mail_to_emp (null, global_v_codempid, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filepath,null,null, null,v_desc_email3);
            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang,'EMAIL 3');
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            end if;
          end if;
      exception when others then
        param_msg_error := get_error_msg_php('HR7522',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end;
    end if;
    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
--    obj_result.put('numberdocument',v_numdoc);

    param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end send_mail;
  procedure send_mail2 ( json_str_input in clob,json_str_output out clob) as
    obj_result      json_object_t;
		itemselected	  json_object_t;
    v_numdoc        varchar2(1000 char);
    v_filepath      varchar2(1000 char);
    v_filename      varchar2(1000 char);
    v_codempid      temploy1.codempid%type;
    v_dteeffec      date;
    v_numseq        number;
    v_flgSendEmp    varchar2(1 char);
    v_flgSendEmail  varchar2(1 char);
    v_desc_email1   varchar2(100 char);
    v_desc_email2   varchar2(100 char);
    v_desc_email3   varchar2(100 char);
    v_recieve       temploy1.codempid%type;
    v_dtereceive    date;
--		v_codfrm_to		  tfwmailh.codform%type;
    v_response      varchar2(4000 char);
    v_subject       tapplscr.desclabelt%type;
    ttmistk_obj		  ttmistk%rowtype;
    v_rowid_query		varchar2(100 char);
--		v_typesend		tfwmailh.typesend%type;
		v_msg_to        long;
		v_template_to   long;
		v_func_appr		  varchar2(10 char);
		v_error			    varchar2(10 char);
		v_table			    varchar2(20 char);
	begin
    initial_word(json_str_input);
    v_flgSendEmp    :=  hcm_util.get_string_t(p_sendMailInfo,'codempid');
    v_flgSendEmail  :=  hcm_util.get_string_t(p_sendMailInfo,'email');
    v_desc_email1   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email1');
    v_desc_email2   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email2');
    v_desc_email3   :=  hcm_util.get_string_t(p_sendMailInfo,'desc_email3');
    v_recieve       :=  hcm_util.get_string_t(p_sendMailInfo,'recieve');
    v_dtereceive    :=  to_date(hcm_util.get_string_t(p_sendMailInfo,'dtereceive'),'dd/mm/yyyy');

		if v_flgSendEmp = 'Y' then
      for i in 0..p_data_sendmail.get_size - 1 loop
        itemSelected  := hcm_util.get_json_t( p_data_sendmail,to_char(i));
        v_numdoc      := hcm_util.get_string_t(itemSelected,'numberdocument');
        v_filepath      := hcm_util.get_string_t(itemSelected,'filepath');
        v_filename      := hcm_util.get_string_t(itemSelected,'filename');
        v_codempid      := hcm_util.get_string_t(itemSelected,'codempid');
        v_numseq        := hcm_util.get_string_t(itemSelected,'numseq');
        v_dteeffec      := to_date(hcm_util.get_string_t(itemSelected,'dteeffec'),'dd/mm/yyyy');
        if p_codmove = '0005' then 
          begin
            select rowid into v_rowid_query
              from ttmistk
             where codempid = v_codempid
               and dteeffec = v_dteeffec
               and staupd not in ('N','P')
             order by dteeffec,codempid;
          exception when no_data_found then
            v_rowid_query := null;
          end;
           v_table := 'ttmistk';
        elsif p_codmove = '0006' then
          begin
            select rowid into v_rowid_query
              from ttexempt
             where codempid = v_codempid
               and dteeffec = v_dteeffec
               and staupd not in ('N','P')
             order by dteeffec,codempid;
          exception when no_data_found then
            v_rowid_query := null;
          end;
           v_table := 'ttexempt';
        else
          begin
            select rowid into v_rowid_query
              from ttmovemt
             where codempid = v_codempid
               and dteeffec = v_dteeffec
               and codtrn = p_codmove
               and numseq = v_numseq
               and staupd not in ('N','P')
             order by dteeffec,codempid;
          exception when no_data_found then
            v_rowid_query := null;
          end;
          v_table := 'ttmovemt';
        end if;
        -- Get message
        begin
            p_maillang := chk_flowmail.get_emp_mail_lang(v_codempid);
            chk_flowmail.get_message_result('HRPM51X', p_maillang, v_msg_to, v_template_to);

            v_subject := get_tcodec_name('TCODMOVE', p_codmove, p_maillang);

            chk_flowmail.replace_text_frmmail(v_template_to, v_table, v_rowid_query , v_subject , 'HRPM51X', '1', null, global_v_coduser, p_maillang, v_msg_to,'Y', v_filepath);

            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', p_maillang, v_filepath,null,null, null);

            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            end if;
        exception when others then
          param_msg_error := get_error_msg_php('HR7522',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
        end;
      end loop;
    end if;
    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end send_mail2;
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
  --
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
--  function get_clob(str_json in clob,key_json in varchar2) RETURN CLOB is
--    jo  JSON_OBJECT_T;
--  begin
--    jo := JSON_OBJECT_T.parse(str_json);
--  return  jo.get_clob(key_json);
--  end get_clob;
--  procedure print_word( json_str_output out clob) AS
--  begin
--    if (p_type_data = '1') then
--      never_print( json_str_output );
--    end if;
--  end print_word;


--  procedure never_print_single_form( json_str_output out clob) as
--  v_count_data_selected           number;
--  v_objdata_item_selected         json_object_t;
--  v_objrow_row_selected           json_object_t;
--  v_out_objdetail_gennumannou     json_object_t;
--  v_out_objdetail_infonumdoc      json_object_t;
--  obj_row                         json_object_t := json_object_t();
--  v_numseq_running                number;
--  v_out_data_return               json_object_t := json_object_t();
--  v_out_row_return                json_object_t;
--  v_count_objdata                 number;
--  v_out_html_head                 clob;
--  v_out_html_body                 clob;
--  v_out_html_footer               clob;
--    v_codcomp varchar2(100 char);
--  begin
--    v_out_data_return     := json_object_t();
--    v_count_objdata       := 0;
--    v_numseq_running      := 1;
--    v_count_data_selected := p_data_selected.get_size;
--
----    delete from  ttemprptc
----    where codempid = global_v_codempid
----    and codapp = p_codform;
--
--    for i in 0..p_data_selected.get_size - 1 loop
--      v_objdata_item_selected := hcm_util.get_json_t(p_data_selected,to_char(i)) ;
--
--      v_out_objdetail_gennumannou := json_object_t();
--
----      gen_numannou(p_codmove,
----                   p_type_move,
----                   v_objdata_item_selected,
----                   global_v_lang,
----                   v_out_objdetail_gennumannou,
----                   null);
--
--      if (param_msg_error is not null) then
--        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--        return ;
--      end if;
--
----      if ( p_codmove  <> '0005' and p_codmove <> '0006' and p_type_move <> 'A' ) then
------        insert_parameter_keyin(hcm_util.get_string_t(v_out_objdetail_gennumannou,'v_numannou'));
----      end if;
--      -- gen template
--      gen_html_form(p_codform,p_html_head,p_typemsg1,p_html_body,p_typemsg1,p_html_footer);
--
----      insert_info_and_detail_numdoc  ( v_numseq_running,
----                                        p_codmove,
----                                        p_type_move,
----                                        v_objdata_item_selected,
----                                        p_data_parameter,
----                                        v_out_objdetail_gennumannou,
----                                        v_out_objdetail_infonumdoc);
--
----      replaceword (
----                p_html_head,
----                p_html_body,
----                p_html_footer,
----                p_codform,
----                v_objdata_item_selected,
----                v_out_objdetail_infonumdoc,
----                p_data_parameter,
----                v_out_html_head ,
----                v_out_html_body ,
----                v_out_html_footer);
--
----      insert_template_table (
----             p_codform,
----             v_numseq_running,
----             v_out_html_head,
----             v_out_html_body,
----             v_out_html_footer
----              );
--
--      v_out_row_return := json_object_t();
--
--      v_out_row_return := append_clob_json(v_out_row_return,'html_head',v_out_html_head);
--      v_out_row_return := append_clob_json(v_out_row_return,'html_body',v_out_html_body);
--      v_out_row_return := append_clob_json(v_out_row_return,'html_footer',v_out_html_footer);
--
--      v_out_row_return.put('objdata_item_selected',v_objdata_item_selected);
--      v_out_row_return.put('objdetail_gennumannou',v_out_objdetail_gennumannou);
--      v_out_row_return.put('objdetail_infonumdoc',v_out_objdetail_infonumdoc);
--      v_out_row_return.put('numseq_running',v_numseq_running);
--      v_out_row_return.put('coderror','200');
--
--      v_out_data_return.put(to_char(v_count_objdata),v_out_row_return);
--      v_count_objdata := v_count_objdata + 1;
--      v_numseq_running := v_numseq_running + 1;
--    end loop;
--    json_str_output := v_out_data_return.to_clob;
--  exception when others then
--  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end never_print_single_form;
--
--  procedure never_print_group_form( json_str_output out clob) as
--  v_count_data_selected number;
--  v_objdata_item_selected json_object_t;
--  v_objrow_row_selected json_object_t;
--  v_out_objdetail_gennumannou json_object_t;
--  v_out_objdetail_infonumdoc  json_object_t;
--  obj_row json_object_t := json_object_t();
--  v_numseq_running number;
--  v_out_html_head clob;
--  v_out_html_body clob;
--  v_out_html_footer clob;
--  v_out_sumany_html_head clob;
--  v_out_sumany_html_body clob;
--  v_out_sumany_html_footer clob;
--
--  v_out_data_return  json_object_t;
--  v_out_row_return  json_object_t;
--  v_count_objdata number  ;
--  v_numannou_first varchar2(30);
--
--  begin
--      v_out_data_return  := json_object_t();
--      v_numseq_running := 1;
--      v_count_objdata := 0;
--      v_count_data_selected := p_data_selected.get_size;
--
--       delete from ttemprptc
--       where codempid = global_v_codempid
--       and codapp = p_codform;
--
--      for i in 1..v_count_data_selected loop
--          v_objdata_item_selected :=  hcm_util.get_json_t( p_data_selected,i );
--
--          if (i = 1) then
----              gen_numannou(p_codmove,
----                       p_type_move,
----                       v_objdata_item_selected,
----                       global_v_lang,
----                       v_out_objdetail_gennumannou,
----                       null);
--
--            v_numannou_first :=   hcm_util.get_string_t(v_out_objdetail_gennumannou,'v_numannou');
----          else
----               gen_numannou(p_codmove,
----                       p_type_move,
----                       v_objdata_item_selected,
----                       global_v_lang,
----                       v_out_objdetail_gennumannou,
----                       v_numannou_first);
--          end if;
--
--           if (param_msg_error is not null) then
--               json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--               return ;
--          end if;
--
----          if (i = 1) then
----                  if ( p_codmove  <> '0005' and
----                   p_codmove <> '0006' and
----                   p_type_move <> 'A' ) then
------                       insert_parameter_keyin(v_numannou_first);
----                   end if;
----          end if;
--
----          insert_info_and_detail_numdoc  (
----          v_numseq_running,
----          p_codmove,
----          p_type_move,
----          v_objdata_item_selected,
----          p_data_parameter,
----          v_out_objdetail_gennumannou,
----          v_out_objdetail_infonumdoc);
--
----          if (i = 1) then
----                 replaceword (      p_html_head,
----                                            p_html_body,
----                                            p_html_footer,
----                                            p_codform,
----                                            v_objdata_item_selected,
----                                            v_out_objdetail_infonumdoc,
----                                            p_data_parameter,
----                                            v_out_html_head,
----                                            v_out_html_body,
----                                            v_out_html_footer);
----
----                v_out_sumany_html_head :=  concat(v_out_sumany_html_head,v_out_html_head);
----                v_out_sumany_html_body :=  concat(v_out_sumany_html_body,v_out_html_body);
----                v_out_sumany_html_footer  :=  concat(v_out_sumany_html_footer,v_out_html_footer);
----
----             else
----
----                replaceword (       null,
----                                            p_html_body,
----                                            null,
----                                            p_codform,
----                                            v_objdata_item_selected,
----                                            v_out_objdetail_infonumdoc,
----                                            p_data_parameter,
----                                            v_out_html_head,
----                                            v_out_html_body,
----                                            v_out_html_footer);
----
----                v_out_sumany_html_body :=  concat(v_out_sumany_html_body,v_out_html_body);
----
----         end if;
--
--        v_numseq_running := v_numseq_running  + 1;
--
--       end loop;
--
----       insert_template_table (
----                 p_codform,
----                 1,
----                 v_out_sumany_html_head,
----                 v_out_sumany_html_body,
----                 v_out_sumany_html_footer
----                );
--
--        v_out_row_return := json_object_t();
--        v_out_row_return.put('html_head',v_out_sumany_html_head);
--        v_out_row_return.put('html_body',v_out_sumany_html_body);
--        v_out_row_return.put('html_footer',v_out_sumany_html_footer);
--        v_out_row_return.put('coderror','200');
--        v_out_row_return.put('numseq_running',1);
--
--       v_out_data_return.put('0',v_out_row_return);
--
--      json_str_output := v_out_data_return.to_clob;
--   exception
--   when others then
--     param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end never_print_group_form;
    --  procedure initial_genword(json_str_input in clob) as
--  json_obj		json_object_t;
--  begin
--
--        json_obj := json_object_t(json_str_input);
--        p_objdata_genword := hcm_util.get_json_t(json_obj,'objdata_genword');
--        p_codform := hcm_util.get_string_t(json_obj,'codform');
--        v_chken                      := hcm_secur.get_v_chken;
--        global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
--        global_v_codpswd       := hcm_util.get_string_t(json_obj,'p_codpswd');
--        global_v_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');
--        global_v_lang              := hcm_util.get_string_t(json_obj,'p_lang');
--        global_v_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');
--        global_v_zyear            := hcm_appsettings.get_additional_year() ;
--
--
--  end initial_genword;
--  procedure post_genword(json_str_input in clob, json_str_output out clob) as
--    v_html_head     json_object_t;
--    v_html_body     json_object_t;
--    v_html_html_footer json_object_t;
--    v_numseq_running number;
--    v_objdetail_infonumdoc json_object_t;
--    v_objdata_item_selected json_object_t;
--    v_objdetail_gennumannou json_object_t;
--    v_objdetail_genword json_object_t;
--    v_objrow_parameter_keyin json_object_t;
--
--
--    v_out_html_head clob;
--    v_out_html_body   clob;
--    v_out_html_footer  clob;
--
--    v_str_objdetail_genword clob;
--
--    v_in_html_head clob := '';
--    v_in_html_body clob := '';
--    v_in_html_footer clob := '';
--
--    v_out_data_return  json_object_t := json_object_t();
--    v_out_row_return  json_object_t;
--    v_count_objdata number  ;
--
--  begin
--            initial_genword(json_str_input);
--
--           delete from  ttemprptc
--           where codempid = global_v_codempid
--           and codapp = p_codform;
--
--     v_objrow_parameter_keyin := hcm_util.get_json_t(p_objdata_genword,'data_parameter');
--     v_count_objdata := 0 ;
--
--     for i in 1..p_objdata_genword.get_size loop
--             v_objdetail_genword   := hcm_util.get_json_t(p_objdata_genword,i);
--             v_numseq_running     := hcm_util.get_number_t(v_objdetail_genword,'numseq_running');
--             v_objdetail_infonumdoc  := hcm_util.get_json_t(v_objdetail_genword,'objdetail_infonumdoc');
--             v_objdata_item_selected := hcm_util.get_json_t(v_objdetail_genword,'objdata_item_selected');
--             v_objdetail_gennumannou := hcm_util.get_json_t(v_objdetail_genword,'objdetail_gennumannou');
--
--
--             v_str_objdetail_genword := v_objdetail_genword.to_clob;
--
--             v_in_html_head   := get_clob(v_str_objdetail_genword,'html_head');
--             v_in_html_body   := get_clob(v_str_objdetail_genword,'html_body');
--             v_in_html_footer  := get_clob(v_str_objdetail_genword,'html_footer');
--
--           replaceword (
--                 v_in_html_head,
--                 v_in_html_body,
--                 v_in_html_footer,
--                  p_codform,
--                  v_objdata_item_selected,
--                  v_objdetail_infonumdoc,
--                  v_objrow_parameter_keyin,
--                  v_out_html_head ,
--                  v_out_html_body ,
--                  v_out_html_footer);
--
--          insert_template_table (
--               p_codform,
--               v_numseq_running,
--               v_out_html_head,
--               v_out_html_body,
--               v_out_html_footer
--              );
--
--      v_out_row_return := json_object_t();
--
--      v_out_row_return := append_clob_json(v_out_row_return,'html_head',v_out_html_head);
--      v_out_row_return := append_clob_json(v_out_row_return,'html_body',v_out_html_body);
--      v_out_row_return := append_clob_json(v_out_row_return,'html_footer',v_out_html_footer);
--
--      v_out_row_return.put('objdata_item_selected',v_objdata_item_selected);
--      v_out_row_return.put('objdetail_gennumannou',v_objdetail_gennumannou);
--      v_out_row_return.put('objdetail_infonumdoc',v_objdetail_infonumdoc);
--      v_out_row_return.put('numseq_running',v_numseq_running);
--      v_out_row_return.put('coderror','200');
--
--      v_out_data_return.put(to_char(v_count_objdata),
--                                        v_out_row_return);
--      v_count_objdata := v_count_objdata +1;
--
--     end loop;
--
--    json_str_output := v_out_data_return.to_clob;
--  end post_genword;
--  procedure insert_info_and_detail_numdoc(v_numseq_running number,
--                                          v_codcodec in varchar2,
--                                          v_typemove in varchar2,
--                                          v_objdata_itemselected in json_object_t,
--                                          v_objdata_itemparameterkeyin in json_object_t,
--                                          v_out_objdetail_gen_numannou in json_object_t,
--                                          v_objrow_infodetailnumdoc out json_object_t) as
--
--    v_codempid_     temploy1.codempid%type;
--    v_codcomp_		  temploy1.codcomp%type;
--		v_codpos_		    temploy1.codpos%type;
--		v_codjob_		    temploy1.codjob%type;
--		v_numlvl_		    number;
--		v_staemp_		    temploy1.staemp%type;
--		v_codempmt_	    temploy1.codempmt%type;
--		v_dteempmt_	    date ;
--		v_codcurr_		  temploy3.codcurr%type;
--
--    v_amtincom1		temploy3.amtincom1%type;
--		v_amtincom2		temploy3.amtincom2%type;
--		v_amtincom3		temploy3.amtincom3%type;
--		v_amtincom4		temploy3.amtincom4%type;
--		v_amtincom5		temploy3.amtincom5%type;
--		v_amtincom6		temploy3.amtincom6%type;
--		v_amtincom7		temploy3.amtincom7%type;
--		v_amtincom8		temploy3.amtincom8%type;
--		v_amtincom9		temploy3.amtincom9%type;
--		v_amtincom10	temploy3.amtincom10%type;
--
--    amtincom1		number;
--		amtincom2		number;
--		amtincom3		number;
--		amtincom4		number;
--		amtincom5		number;
--		amtincom6		number;
--		amtincom7		number;
--		amtincom8		number;
--		amtincom9		number;
--		amtincom10	number;
--
--    v_sumhur_a		number;
--		v_sumday_a		number;
--		v_summon_a		number;
--
--    v_ttmovemt_befor_amtincom1  number;
--    v_ttmovemt_amtincom1        number;
--    v_ttmovemt_codcurr          ttmovemt.codcurr%type;
--
--    v_ttmovemt_codcomp    ttmovemt.codcomp%type;
--    v_ttmovemt_codpos     ttmovemt.codpos%type;
--    v_ttmovemt_numlvl     ttmovemt.numlvl%type;
--    v_ttmovemt_codcompt   ttmovemt.codcompt%type;
--    v_ttmovemt_codposnow  ttmovemt.codposnow%type;
--    v_ttmovemt_numlvlt    ttmovemt.numlvlt%type;
--
--    v_objrow                  json_object_t  := json_object_t();
--    v_out_img_empreport       clob;
--    v_index_infodetailnumdoc  number;
--    v_display_dteeffec        varchar2(100 char);
--    v_day_display_dteeffec    number;
--    v_month_display_dteeffec  varchar2(50 char);
--    v_year_disaplay_dteeffec  number;
--
--    v_count_temploy1          number;
--    v_count_temploy3          number;
--    v_codempid_event          varchar2(1000 char);
--    v_dteeffec                varchar2(1000 char);
--    v_numseq                  varchar2(1000 char);
--
--    begin
--      v_codempid_event := hcm_util.get_string_t(v_objdata_itemselected,'codempid');
--
--      select count(*) into v_count_temploy1
--        from temploy1
--       where codempid = v_codempid_event;
--
--      select count(*) into v_count_temploy3
--        from temploy3
--       where codempid = v_codempid_event;
--
--      if (v_count_temploy1 = 0) then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TEMPLOY1');
--        return;
--      end if;
--
--      if (v_count_temploy3 = 0) then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TEMPLOY3');
--        return;
--      end if;
--
--      select a.codempid,codcomp,codpos,codjob,numlvl,staemp,codempmt,dteempmt,codcurr
--        into v_codempid_,v_codcomp_ ,v_codpos_ ,v_codjob_,v_numlvl_,v_staemp_,v_codempmt_,v_dteempmt_,v_codcurr_
--        from temploy1 a,temploy3 b
--       where a.codempid = b.codempid
--         and a.codempid = v_codempid_event;
--
--      select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
--             amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
--        into v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
--             v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
--        from temploy3
--       where codempid = v_codempid_event ;
--
--      amtincom1 := stddec(v_amtincom1,v_codempid_,v_chken);
--      amtincom2 := stddec(v_amtincom2,v_codempid_,v_chken);
--      amtincom3 := stddec(v_amtincom3,v_codempid_,v_chken);
--      amtincom4 := stddec(v_amtincom4,v_codempid_,v_chken);
--      amtincom5 := stddec(v_amtincom5,v_codempid_,v_chken);
--      amtincom6 := stddec(v_amtincom6,v_codempid_,v_chken);
--      amtincom7 := stddec(v_amtincom7,v_codempid_,v_chken);
--      amtincom8 := stddec(v_amtincom8,v_codempid_,v_chken);
--      amtincom9 := stddec(v_amtincom9,v_codempid_,v_chken);
--      amtincom10 := stddec(v_amtincom10,v_codempid_,v_chken);
--
--      get_wage_income( hcm_util.get_codcomp_level(v_codcomp_,1) ,v_codempmt_,
--                      0,amtincom2,amtincom3,amtincom4,
--                      amtincom5, amtincom6, amtincom7,
--                      amtincom8, amtincom9, amtincom10,
--                      v_sumhur_a ,v_sumday_a,v_summon_a);
--
--      insert_tdocinf_key( v_numseq_running, v_out_objdetail_gen_numannou, v_codempid_, v_codcodec, v_codcomp_);
--
--      v_objrow_infodetailnumdoc := json_object_t();
--      v_index_infodetailnumdoc  := 1;
--
--      v_day_display_dteeffec    := to_number(to_char(to_date(hcm_util.get_string_t(v_objdata_itemselected,'dteeffec'),'dd/mm/yyyy'),'dd'),'99');
--      v_month_display_dteeffec  := get_nammthful(to_number(to_char(to_date(hcm_util.get_string_t(v_objdata_itemselected,'dteeffec'),'dd/mm/yyyy'),'mm')),global_v_lang);
--      v_year_disaplay_dteeffec  := get_ref_year(global_v_lang,global_v_zyear,to_number(to_char(to_date(hcm_util.get_string_t(v_objdata_itemselected,'dteeffec'),'dd/mm/yyyy'),'yyyy')));
--      v_display_dteeffec        := v_day_display_dteeffec || ' ' ||v_month_display_dteeffec|| ' ' ||v_year_disaplay_dteeffec;
--
--    if (v_codcodec = '0005') then
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_01]',
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou'));
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_02]',
--                    get_tcodec_name('tcodmove',v_codcodec,global_v_lang));
--
--            insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_03]',
--                   get_temploy_name(v_codempid_,global_v_lang));
--
--            insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_04]',
--                  get_tcodec_name('tcodmist',hcm_util.get_string_t(v_objdata_itemselected,'codmist'),global_v_lang));
--
--          insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_05]',
--                  hcm_util.get_string_t(v_objdata_itemselected,'desmist1'));
--
--          insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_06]',
--                  p_display_dateprint
--                  );
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json('[PARAM_01]', hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou')));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json('[PARAM_02]',get_tcodec_name('tcodmove',v_codcodec,global_v_lang)));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json('[PARAM_03]',get_temploy_name(v_codempid_,global_v_lang)));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json('[PARAM_04]',get_tcodec_name('tcodmist',hcm_util.get_string_t(v_objdata_itemselected,'codmist'),global_v_lang)));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json ('[PARAM_05]',hcm_util.get_string_t(v_objdata_itemselected,'desmist1')));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--                  v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json ('[PARAM_06]',p_display_dateprint));
--                  v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--    elsif (v_codcodec = '0006' or v_codcodec = '0007') then
--
--            insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_01]',
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou'));
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_02]',
--                    get_tcodec_name('tcodmove',v_codcodec,global_v_lang));
--
--            insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_03]',
--                   get_temploy_name(v_codempid_,global_v_lang));
--
--         insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_04]',
--                    hcm_util.get_string_t(v_objdata_itemselected,'posname'));
--
--        insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_05]',
--                   hcm_util.get_string_t(v_objdata_itemselected,'dep'));
--
--         insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_06]',
--                   p_display_dateprint);
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_01]',hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou')));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_02]',get_tcodec_name('tcodmove',v_codcodec,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_03]',get_temploy_name(v_codempid_,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_04]',hcm_util.get_string_t(v_objdata_itemselected,'posname')));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_05]',hcm_util.get_string_t(v_objdata_itemselected,'dep')));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_06]',v_display_dteeffec));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--    elsif (v_typemove = 'A') then
--             v_dteeffec := hcm_util.get_string_t(v_objdata_itemselected,'dteeffec');
--             v_numseq   := hcm_util.get_string_t(v_objdata_itemselected,'numseq');
--             select  stddec(AMTINCADJ1,global_v_codempid,hcm_secur.get_v_chken) - stddec(AMTINCOM1,global_v_codempid,hcm_secur.get_v_chken),
--                       stddec(AMTINCOM1,global_v_codempid,hcm_secur.get_v_chken) ,
--                       v_ttmovemt_codcurr
--                       into v_ttmovemt_befor_amtincom1, v_ttmovemt_amtincom1,v_ttmovemt_codcurr
--             from ttmovemt
--             where codempid = v_codempid_
--             and dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
--             and numseq = to_number(v_numseq)
--             and codtrn = v_codcodec ;
--
--             insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_01]',
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou'));
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_02]',
--                    p_display_dateprint);
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_03]',
--                   get_temploy_name(v_codempid_,global_v_lang));
--
--           insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_04]',
--                   hcm_util.get_string_t(v_objdata_itemselected,'dep'));
--
--         insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_05]',
--                  get_tcodec_name('tcodmove',v_codcodec,global_v_lang));
--
--          insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_06]',
--                  v_ttmovemt_befor_amtincom1||' '|| get_tcodec_name('TCODCURR',v_ttmovemt_codcurr,global_v_lang));
--
--          insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_07]',
--                  v_ttmovemt_amtincom1 ||' '|| get_tcodec_name('TCODCURR',v_ttmovemt_codcurr,global_v_lang));
--
--         insert_parameter_fix(
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                   hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                   v_codempid_,
--                   '[PARAM_08]',
--                   hcm_util.get_string_t(v_objdata_itemselected,'dteeffec'));
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_01]',hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou')));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_02]',p_display_dateprint));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_03]',get_temploy_name(v_codempid_,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_04]',hcm_util.get_string_t(v_objdata_itemselected,'dep')));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_05]',get_tcodec_name('tcodmove',v_codcodec,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_06]',v_ttmovemt_befor_amtincom1||' '|| get_tcodec_name('TCODCURR',v_ttmovemt_codcurr,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_07]',v_ttmovemt_amtincom1 ||' '|| get_tcodec_name('TCODCURR',v_ttmovemt_codcurr,global_v_lang)));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--            v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM_08]',v_display_dteeffec));
--            v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--    elsif ( v_codcodec <> '0005' and v_codcodec <> '0006' and v_typemove <> 'A') then
--      v_dteeffec := hcm_util.get_string_t(v_objdata_itemselected,'dteeffec');
--      v_numseq   := hcm_util.get_string_t(v_objdata_itemselected,'numseq');
--
--      select codcomp,codpos,numlvl,codcompt,codposnow,numlvlt
--        into v_ttmovemt_codcomp, v_ttmovemt_codpos,v_ttmovemt_numlvl,
--             v_ttmovemt_codcompt,v_ttmovemt_codposnow,v_ttmovemt_numlvlt
--        from ttmovemt
--       where codempid = v_codempid_
--         and dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
--         and numseq = to_number(v_numseq)
--         and codtrn = v_codcodec ;
--
--      insert_parameter_fix( hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                            hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                            v_codempid_,
--                            '[PARAM-01]',
--                            hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou'));
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-02]',
--                           p_display_dateprint);
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-03]',
--                           get_tcodec_name('tcodmove',v_codcodec,global_v_lang));
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-04]',
--                           hcm_util.get_string_t(v_objdata_itemselected,'name'));
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-05]',
--                           get_tpostn_name(v_ttmovemt_codposnow,global_v_lang));
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-06]',
--                           v_ttmovemt_numlvlt );
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-07]',
--                           get_tcenter_name(v_ttmovemt_codcompt,global_v_lang) );
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-08]',
--                           get_tpostn_name( v_ttmovemt_codpos,global_v_lang) );
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-09]',
--                           v_ttmovemt_numlvl );
--
--      insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                           hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                           v_codempid_,
--                           '[PARAM-10]',
--                           v_ttmovemt_codcompt );
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-01]',hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numannou')));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-02]',p_display_dateprint));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-03]',get_tcodec_name('tcodmove',v_codcodec,global_v_lang)));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-04]',hcm_util.get_string_t(v_objdata_itemselected,'name')));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-05]',get_tpostn_name(v_ttmovemt_codposnow,global_v_lang)));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-06]',v_ttmovemt_numlvlt));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-07]',get_tcenter_name(v_ttmovemt_codcompt,global_v_lang)) );
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-08]',get_tpostn_name( v_ttmovemt_codpos,global_v_lang)));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-09]',v_ttmovemt_numlvl));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-10]',get_tcenter_name(v_ttmovemt_codcomp,global_v_lang)));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--      v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc),parametrfix_to_json('[PARAM-11]',v_display_dteeffec));
--      v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--    end if;
--
--    get_param_signpic(v_objdata_itemparameterkeyin , v_out_img_empreport);
--    insert_parameter_fix(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref'),
--                         hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc'),
--                         v_codempid_,
--                         '[PARAM-SIGNPIC]',
--                         v_out_img_empreport);
--
--    v_objrow_infodetailnumdoc.put(to_char(v_index_infodetailnumdoc), parametrfix_to_json('[PARAM-SIGNPIC]',v_out_img_empreport));
--    v_index_infodetailnumdoc := v_index_infodetailnumdoc + 1;
--
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end insert_info_and_detail_numdoc;

--  procedure insert_tdocinf_key (numseq in number , v_out_objdetail_gen_numannou in json_object_t,
--                                v_codempid_ in varchar2,
--                                v_codcodec in varchar2,
--                                v_codcomp_ in varchar2 ) is
--
--    v_numseq    tdocinf.numseq%type;
--    v_numhmref  varchar2(1000 char);
--    v_typdoc    varchar2(1000 char);
--    v_ttmovemt_dteeffec    varchar2(1000 char);
--  begin
--    if (length(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_ttmovemt_numseq'))> 0 ) then
--        v_numseq :=  to_number(hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_ttmovemt_numseq'));
--    else
--        v_numseq := numseq;
--    end if;
--
--    v_numhmref  := hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_numhmref');
--    v_typdoc    := hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_typdoc');
--    v_ttmovemt_dteeffec := hcm_util.get_string_t(v_out_objdetail_gen_numannou,'v_ttmovemt_dteeffec');
--
--    insert into tdocinf ( numhmref, typdoc, codempid, codtrn,
--                          codcomp, numseq, dteeffec, dtehmref, codform,
--                          flgnotic, dtecreate, codcreate)
--                  values( v_numhmref, v_typdoc, v_codempid_, v_codcodec,
--                          v_codcomp_, v_numseq, to_date(v_ttmovemt_dteeffec,'dd/mm/yyyy'), to_date(p_dateprint,'dd/mm/yyyy'), p_codform,
--                          p_flagnotic, sysdate, global_v_coduser);
--
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--	end insert_tdocinf_key;
--  procedure insert_parameter_keyin (v_numannou in VARCHAR2) is
--   v_objrow json_object_t;
--   v_fparam varchar2(1000 char);
--   v_value  varchar2(1000 char);
--   begin
--              for i in 1..p_data_parameter.get_size
--                 loop
--                   v_objrow := hcm_util.get_json_t(p_data_parameter,i);
--                   if ( length(hcm_util.get_string_t(v_objrow,'fparam')) > 0 ) then
--                     v_fparam := hcm_util.get_string_t(v_objrow,'fparam');
--                     v_value := hcm_util.get_string_t(v_objrow,'valuedescript');
--                     insert into  tcertifd (numcerti,fparam,fvalue,coduser)
--                     values (v_numannou,
--                     v_fparam,
--                     v_value,global_v_coduser);
--                   end if;
--                 end loop;
--    exception when others then
--                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--   end insert_parameter_keyin;

--  procedure replaceword (
--      v_html_head_original     in  clob,
--      v_html_body_original     in  clob,
--      v_html_footer_original    in   clob,
--      v_codform         in varchar2,
--      v_objdata_item_selected in   json_object_t,
--      v_objrow_infodetailnumdoc  in   json_object_t,
--      v_objrow_parameter_keyin in json_object_t,
--      v_out_html_head out  clob,
--      v_out_html_body out  clob,
--      v_out_html_footer out  clob
--  ) is
--
--    v_objdetail_infodetailnumdoc json_object_t;
--    v_objdetail_parameter_keyin json_object_t;
--    v_objdata_item_selected_keyother json_object_t;
--  begin
--
--        v_out_html_head := v_html_head_original;
--        v_out_html_body := v_html_body_original;
--        v_out_html_footer := v_html_footer_original;
--
--        v_objdata_item_selected_keyother := add_value_other(v_objdata_item_selected);
--
--        if (v_html_head_original is not null) then
--            v_out_html_head := std_replace (v_out_html_head,v_codform,1,v_objdata_item_selected_keyother );
--        end if;
--
--          if (v_html_body_original is not null) then
--            v_out_html_body := std_replace (v_out_html_body,v_codform,2,v_objdata_item_selected_keyother );
--        end if;
--
--          if (v_html_footer_original is not null) then
--            v_out_html_footer := std_replace (v_out_html_footer,v_codform,3,v_objdata_item_selected_keyother );
--        end if;
--
--        --# start index 1
--
--       for i in 1..v_objrow_infodetailnumdoc.get_size
--       loop
--               v_objdetail_infodetailnumdoc := hcm_util.get_json_t(v_objrow_infodetailnumdoc,i);
--
--               if (v_html_head_original is not null) then
--
--                 v_out_html_head := replace(v_out_html_head,
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'keyparameterfix'),
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'valueparameterfix'));
--                 end if;
--
--              if (v_html_body_original is not null) then
--
--               v_out_html_body := replace(v_out_html_body,
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'keyparameterfix'),
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'valueparameterfix'));
--
--                end if;
--
--               if (v_html_footer_original is not null) then
--
--              v_out_html_footer := replace(v_out_html_footer,
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'keyparameterfix'),
--                                                  hcm_util.get_string_t(v_objdetail_infodetailnumdoc,'valueparameterfix'));
--
--             end if ;
--
--       end loop;
--
--       --#  start index 1
--       for i in 1..v_objrow_parameter_keyin.get_size
--       loop
--                    v_objdetail_parameter_keyin := hcm_util.get_json_t(v_objrow_parameter_keyin,i);
--
--                     if (v_html_head_original is not null) then
--                                v_out_html_head := replace(v_out_html_head,
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'fparam'),
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'valuedescript'));
--                    end if;
--
--                      if (v_html_body_original is not null) then
--                                v_out_html_body := replace(v_out_html_body,
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'fparam'),
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'valuedescript'));
--                     end if;
--
--                     if (v_html_footer_original is not null ) then
--                                v_out_html_footer := replace(v_out_html_footer,
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'fparam'),
--                                hcm_util.get_string_t(v_objdetail_parameter_keyin,'valuedescript'));
--                     end if;
--       end loop;
--  exception when others then
--                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end replaceword;

--  procedure insert_template_table (
--                   v_codform in varchar2,
--                   v_numseq in number,
--                   v_html_head in  clob,
--                   v_html_body in  clob,
--                   v_html_footer in  clob
--    ) is
--  begin
--
--   insert into TTEMPRPTC(CODEMPID,CODAPP,NUMSEQ,MESSAGE1,MESSAGE2,MESSAGE3)
--						VALUES (global_v_codempid,
--						v_codform,
--						v_numseq,
--						v_html_head,
--						v_html_body,
--						v_html_footer);
-- exception when others then
--                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end insert_template_table;

--  procedure get_param_signpic(v_objrow_parameter_keyin in json_object_t , v_out_img out varchar2) is
--    v_check_word boolean;
--    v_objdetail json_object_t;
--    v_index_word number;
--    v_pathimg_tmp  tempimge.codimage%type;
--    v_value     varchar2(1000 char);
--
--    begin
--                v_check_word := false;
--                for i in 1..v_objrow_parameter_keyin.get_size
--                loop
--                        v_objdetail := hcm_util.get_json_t(v_objrow_parameter_keyin,i);
--
--                        if ( hcm_util.get_string_t(v_objdetail,'fparam') = '[PARAM-SIGNID]') then
--                                v_check_word := true;
--                                v_index_word := i;
--                                exit;
--                        end if;
--                end loop;
--
--                if (v_check_word = true) then
--                            v_objdetail  := hcm_util.get_json_t(v_objrow_parameter_keyin,v_index_word);
--                            v_value := hcm_util.get_string_t(v_objdetail,'valuedescript');
--                          begin
--                                select codimage into v_pathimg_tmp
--                                from tempimge
--                                where codempid = v_value;
--                           exception when no_data_found then
--                               v_pathimg_tmp := null ;
--                          end;
--                             if (v_pathimg_tmp is not null) then
--                                     v_out_img :=   '<img src="'||get_image(hcm_util.get_string_t(v_objdetail,'valuedescript'),global_v_lang)||'"'|| '>';
--                            else
--                                     v_out_img := ' ';
--                            end if;
--                else
--                        v_out_img := ' ';
--                end if;
--
--    end get_param_signpic;

--  procedure getnamereport  ( json_str_input in clob,json_str_output out clob) as
--          v_objrow json_object_t;
--          v_desappe tappprof.desappe%type;
--          v_out_objrow json_object_t;
--          begin
--                    v_objrow := json_object_t(json_str_input);
--                    global_v_lang := hcm_util.get_string_t(v_objrow,'p_lang');
--
--                   v_out_objrow := json_object_t();
--
--                   if (global_v_lang = 'th') then
--                        global_v_lang := '102';
--                    elsif (global_v_lang = 'en') then
--                        global_v_lang := '101';
--                    end if;
--
--                  v_out_objrow := json_object_t();
--
--                  if (global_v_lang = '102') then
--                       v_out_objrow.put('reportname',get_label_name('HRPM51X1',global_v_lang,270) || ' ' || to_char(systimestamp,'dd-mm-yyyy hh24-mi-ss','nls_calendar=''thai buddha'' nls_date_language=thai'));
--                    else
--                       v_out_objrow.put('reportname',get_label_name('HRPM51X1',global_v_lang,270) || to_char(SYSTIMESTAMP,'dd-mm-yyyy hh24-mi-ss','nls_date_language=english'));
--                    end if;
--
--                  v_out_objrow.put('response', '');
--			      v_out_objrow.put('coderror', '200');
--
--                json_str_output := v_out_objrow.to_clob;
--
--    exception when others then
--				param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--   end getnamereport;

--  function add_value_other(v_in_item_json in json_object_t) return json_object_t is
--    v_out_json json_object_t;
--   begin
--
--    v_out_json := v_in_item_json;
--
--    if ( hcm_util.get_string_t(v_in_item_json,'codempid_event') is not null ) then
--       v_out_json.put('CODEMPID',hcm_util.get_string_t(v_in_item_json,'codempid_event'));
--    end if;
--
--    if ( hcm_util.get_string_t(v_in_item_json,'dteeffec') is not null ) then
--      v_out_json.put('DTEEFFEC',hcm_util.get_string_t(v_in_item_json,'dteeffec'));
--    end if;
--
--    if ( hcm_util.get_string_t(v_in_item_json,'numseq') is not null ) then
--      v_out_json.put('NUMSEQ',hcm_util.get_string_t(v_in_item_json,'numseq'));
--    end if;
--
--    return v_out_json;
--   end add_value_other;
--  function get_label_tcodmist (v_codcodec  in varchar2, v_lang in varchar2) return varchar2 is
--       v_label tcodmist.descodt%type;
--       v_found varchar2 (1 char);
--       cursor c1 is
--            select decode(v_lang,'101', descode ,
--                                 '102', descodt,
--                                 '103', descod3,
--                                 '104', descod4,
--                                 '105', descod5,descodt) descode
--            from   tcodmist
--            where  codcodec = v_codcodec
--            order by codcodec  ;
--     begin
--             for i in c1 loop
--              v_label := i.descode ;
--              v_found    := 'Y' ;
--              exit ;
--            end loop;
--            if v_found = 'Y' then
--               return v_label ;
--            else
--               return  '';
--            end if;
--   end get_label_tcodmist;
--  procedure get_where_typfm (json_str_input in clob,json_str_output out clob) as
--  v_obj_input json_object_t;
--  v_obj_out json_object_t := json_object_t();
--  v_codtrn tfmrefr.typfm%type;
--  v_type_move  tcodmove.typmove%type;
--  v_codcodec  tcodmove.codcodec%type;
--  begin
--
--          v_obj_input := json_object_t(json_str_input);
--
--          v_codcodec := hcm_util.get_string_t(v_obj_input,'codcodec');
--
--          select typmove into v_type_move
--          from tcodmove
--          where codcodec = v_codcodec;
--
--       if v_codcodec = '0005'  then
--              v_obj_out.put('codcodec','HRPM51X3');
--       elsif v_codcodec = '0006' then
--              v_obj_out.put('codcodec','HRPM51X4');
--       elsif v_codcodec = '0007' then
--             v_obj_out.put('codcodec','HRPM51X5');
--       elsif v_type_move = 'A' then
--             v_obj_out.put('codcodec','HRPM51X2');
--       else
--             v_obj_out.put('codcodec','HRPM51X1');
--        end if;
--
--        v_obj_out.put('response', '');
--  v_obj_out.put('coderror', '200');
--
--        json_str_output := v_obj_out.to_clob;
--
--  exception when others then
--  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
--  end get_where_typfm;

--  function parametrfix_to_json (v_keyparameterfix in varchar2, v_valueparameterfix in varchar2) return json_object_t is
--  v_out_objdetail json_object_t := json_object_t();
--  begin
--        v_out_objdetail.put('keyparameterfix',v_keyparameterfix);
--        v_out_objdetail.put('valueparameterfix',v_valueparameterfix);
--        return v_out_objdetail;
--  end parametrfix_to_json;

  end HRPM51X;

/
