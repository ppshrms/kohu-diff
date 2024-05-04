--------------------------------------------------------
--  DDL for Package Body HRPM77X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM77X" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;    
  begin 
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    itemSelected        := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    pa_codempid         := hcm_util.get_string_t(json_obj,'codempid');
    pa_month1           := hcm_util.get_string_t(json_obj,'month1');
    pa_year1            := hcm_util.get_string_t(json_obj,'year1');
    pa_month2           := hcm_util.get_string_t(json_obj,'month2');
    pa_year2            := hcm_util.get_string_t(json_obj,'year2');
    pa_codpush          := hcm_util.get_string_t(json_obj,'codpush');
    p_numseq            := hcm_util.get_string_t(json_obj,'numseq');
    p_numhmref          := hcm_util.get_string_t(json_obj,'numhmref');
    p_url               := hcm_util.get_string_t(json_obj,'url');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as 
    p_codcomp      temploy1.codcomp%type;
    p_numlvl       temploy1.numlvl%type;
    chk_bool boolean;
  BEGIN 
        if (pa_codempid is null or pa_codempid = ' ') then
           param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_codempid');
           return ;
        end if;

        if (pa_codempid is not null) then
        begin
           select codcomp,numlvl into p_codcomp,p_numlvl
            from temploy1
           where codempid = pa_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'pa_codempid');
          return;
        end;	
        end if;

        if (pa_month1 is null or pa_month1 = ' ') then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_monthstrt');
            return ;
        end if;

        if(pa_year1 is null or pa_year1 = ' ') then
           param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_yearstrt');
            return ;
        end if;

        if(pa_month2 is null or pa_month2 = ' ') then
           param_msg_error := get_error_msg_php('HR2027',global_v_lang, 'p_monthend');
          return ;
        end if;

        if(pa_year2 is null or pa_year2 = ' ') then
           param_msg_error := get_error_msg_php('HR2027',global_v_lang, 'p_yearend');
          return ;
        end if;

        if(pa_year1 > pa_year2) then
           param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
          return ;
        end if;

        if(pa_year1 = pa_year2) then
            if to_number(pa_month1) > to_number(pa_month2) then
                param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
                return;
            end if;
        end if;

      chk_bool := secur_main.secur1(p_codcomp,p_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);   
       if(chk_bool = false ) then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
       end if;

  END vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin 
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
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
    v_rcnt          number := 0;
    qtypunsh        number;
    v_dtestr date := to_date(get_period_date(pa_month1,pa_year1,'S'),'dd/mm/yyyy');
    v_dteend date := to_date(get_period_date(pa_month2,pa_year2,'E'),'dd/mm/yyyy');
    v_data_exist        boolean := false;

    cursor c1 is    
      select codempid,codpunsh,get_tcodec_name('TCODPUNH',codpunsh,global_v_lang) namcodpunsh
      from thispun
      where codempid = pa_codempid
      and dteeffec between v_dtestr and v_dteend
      group by codempid,codpunsh
      order by codpunsh;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    numYearReport := HCM_APPSETTINGS.get_additional_year();
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt+1;

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codempid',r1.codempid);
      obj_data.put('codpush',r1.codpunsh);
      obj_data.put('desc', r1.namcodpunsh);
--      obj_data.put('date', to_char(r1.dtestart,'dd/mm/yyyy')|| ' - ' || to_char(r1.dteend,'dd/mm/yyyy'));
--      obj_data.put('dtestart', to_char(r1.dtestart,'dd/mm/yyyy'));
--      obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
      v_data_exist := true;

      begin
        select count(*) into qtypunsh
        from thispun
        where codempid = pa_codempid
        and dteeffec between v_dtestr and v_dteend
        and codpunsh = r1.codpunsh;
        exception when others then
        qtypunsh := 0;
      end;
      obj_data.put('qty', qtypunsh );
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'thispun');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang); 
        return;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang); 
  end;  


  procedure get_detail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin 
    initial_value(json_str_input);

    if param_msg_error is null then 
        gen_detail(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace; 
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    qtypunsh        varchar2(500);
    v_dtestr date := to_date(get_period_date(pa_month1,pa_year1,'S'),'dd/mm/yyyy');
    v_dteend date := to_date(get_period_date(pa_month2,pa_year2,'E'),'dd/mm/yyyy');


      cursor c1 is   
        select  a.codempid,a.dtestart,a.dteend,to_char(b.dtemistk,'dd/mm/yyyy') as dtemistk,b.refdoc,a.dteeffec, desmist1,
                b.numannou,a.numseq
        from thispun a, thismist b
        where a.codempid = pa_codempid
        and a.codpunsh = pa_codpush
        and a.dteeffec between v_dtestr and v_dteend
        and a.dteeffec = b.dteeffec
        and a.codempid = b.codempid
        order by b.dtemistk;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    numYearReport := HCM_APPSETTINGS.get_additional_year();
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt+1;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codempid',r1.codempid);
      obj_data.put('dtemistk',r1.dtemistk);
      obj_data.put('desmist',r1.desmist1);
      obj_data.put('refdoc', r1.refdoc);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('path_filename', get_tsetup_value('PATHDOC')||get_tfolderd('HRPM4GE')||'/'||r1.refdoc);
      obj_data.put('dtestart', to_char(r1.dtestart,'dd/mm/yyyy') ||' - '|| to_char(r1.dteend,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang); 
  end;  

  procedure print_report(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_value(json_str_input);
    if param_msg_error is null then
      gen_report_data(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end print_report;
  --
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
  --
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
  --
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
  --
  function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
  begin
    if ( hcm_util.get_string_t(objItem,bykey) = null or  hcm_util.get_string_t(objItem,bykey) = ' ') then
      return '';
    else
      return  hcm_util.get_string_t(objItem,bykey);
    end if;
  end name_in ;
  --
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
  --
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
  --
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
  --
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
  --
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
  --
  procedure gen_report_data(  json_str_output out clob) as
    v_typemsg       tfmrefr2.typemsg%type;

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
		v_resultcol		  json_object_t ;
		v_resultrow		  json_object_t := json_object_t();
		v_resultmulti		json_object_t := json_object_t();
    obj_rows        json_object_t;
    obj_result      json_object_t;
    obj_listfilter  json_object_t;
    obj_income      json_object_t;
    obj_multi       json_object_t := json_object_t();
		v_countrow		  number := 0;

    v_numseq        number;

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
       where codempid = pa_codempid
         and dteeffec = p_dteeffec
       order by numseq;

    cursor c3 is 
      select *
        from tdocinfd
       where codempid = pa_codempid
         and numhmref = p_numhmref
         and typdoc = v_typdoc
       order by numseq;
  begin
    begin
      select codform,dtehmref,codtrn into p_codform, p_dateprint, p_codmove
        from tdocinf
       where numhmref = p_numhmref
         and codempid = pa_codempid
         and rownum = 1;
    exception when no_data_found then null;
    end;
    begin
      select typmove into p_type_move
        from tcodmove
       where codcodec = p_codmove;
    exception when no_data_found then
      null;
    end;
    if (p_codmove = '0005') then
      v_typdoc := '1';
    elsif (p_codmove = '0006') then
      v_typdoc := '1';
    elsif (p_type_move = 'A') then
      v_typdoc := '2';
    elsif ( p_codmove <> '0005' and p_codmove <> '0006' and p_type_move <> 'A' ) then
      v_typdoc := '1';
    end if;

    v_typemsg := get_typemsg_by_codform(p_codform);

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
      begin
        select *
          into temploy1_obj
          from temploy1
         where codempid = pa_codempid;
      exception when no_data_found then
        temploy1_obj := null;
      end ;
      begin
        select *
          into temploy3_obj
          from temploy3
         where codempid = pa_codempid;
      exception when no_data_found then
        temploy3_obj := null;
      end ;
      begin
        select *
          into ttmistk_obj
          from ttmistk
         where codempid = pa_codempid
           and dteeffec = p_dteeffec;
      exception when no_data_found then
        ttmistk_obj := null;
      end;
      v_codlang := nvl(v_codlang,global_v_lang);
      numYearReport   := HCM_APPSETTINGS.get_additional_year();
      v_codempid      := pa_codempid;
      v_codcomp       := temploy1_obj.codcomp;
      v_dteeffec      := p_dteeffec;
      v_numseq        := p_numseq;
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
					data_file := replace(data_file,'[PARAM-DOCID]', p_numhmref);
					data_file := replace(data_file,'[PARAM-DATE]', v_date_std);
					data_file := replace(data_file,'[PARAM-SUBJECT]', get_tcodec_name('TCODMOVE', p_codmove, v_codlang));
					data_file := replace(data_file,'[PARAM-MOVAMT]', to_char(v_amtincom_a,'fm999,999,999,990.00'));
					data_file := replace(data_file,'[PARAM-BAHTMOVAMT]', v_desc_amtincom_s);
					data_file := replace(data_file,'[PARAM-AMTSAL]', v_trn_income);
          data_file := replace(data_file,'[PARAM-COMPANY]',get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp,1),v_codlang));
          data_file := replace(data_file,'[PARAM-PUNSH]',v_data);
          data_file := replace(data_file,'[PARAM-MISTK]',v_data2);
          data_file := replace(data_file,'[PARAM-DESCMISTK]',v_data_descmist);

          for r3 in c3 loop
            fparam_fparam   := r3.fparam;
            fparam_value    := r3.fvalue;
            if fparam_fparam = '[PARAM-SIGNID]' then
              data_file := replace(data_file, '[PARAM-SIGNPIC]', fparam_signpic);
            end if;
            data_file := replace(data_file, fparam_fparam, fparam_value);
          end loop;

          data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
          data_file := replace(data_file, chr(9), '&nbsp;');
          list_msg_html(i) := data_file ;
          if i = 2 and v_typemsg = 'M' then
            data_multi := data_multi || data_file ;
          end if;
--          begin
--            insert into tdocinf(numhmref,typdoc,codempid,codtrn,codcomp,numseq,dteeffec,dtehmref,codform,flgnotic, codcreate, coduser)
--            values (p_numhmref, v_typdoc, v_codempid, p_codmove, v_codcomp, v_numseq, v_dteeffec, p_dateprint, p_codform, p_flagnotic, global_v_coduser, global_v_coduser);
--          exception when DUP_VAL_ON_INDEX then
--            null;
--          end;
        end loop;
        v_resultcol		:= json_object_t ();
        v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
        v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
        v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
        if v_namimglet is not null then
          v_pathimg := v_folder||'/'||v_namimglet;
        end if;
        v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
        v_filename := global_v_coduser||'_'||to_char(sysdate,'yyyymmddhh24miss');

        v_resultcol.put('url',p_url);
        v_resultcol.put('filepath','file_uploads/'||v_filename||'.doc');
        v_resultcol.put('filename',v_filename);
        v_resultcol.put('numberdocument',p_numhmref);
        v_resultcol.put('codempid',v_codempid);
        v_resultcol.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
        v_resultcol.put('numseq',nvl(v_numseq,''));
        v_resultcol.put('coderror', '200');
        v_resultcol.put('response','');

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numberdocument',p_numhmref);
    obj_result.put('table',v_resultcol);

    json_str_output := v_resultcol.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report_data;

end HRPM77X;

/
