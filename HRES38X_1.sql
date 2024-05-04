--------------------------------------------------------
--  DDL for Package Body HRES38X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES38X" is
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    itemSelected        := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
--    p_start             := to_number(hcm_util.get_string_t(json_obj,'p_start'));
--    p_end               := to_number(hcm_util.get_string_t(json_obj,'p_end'));
--    p_limit             := to_number(hcm_util.get_string_t(json_obj,'p_limit'));
    -----
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_numhmref          := hcm_util.get_string_t(json_obj,'p_numhmref');
    p_codform           := hcm_util.get_string_t(json_obj,'p_codform');
    p_codtrn            := hcm_util.get_string_t(json_obj,'p_codtrn');
    p_url               := hcm_util.get_string_t(json_obj,'url');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');
    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_s_mth       := hcm_util.get_string_t(json_obj,'p_stmonth');
    b_index_s_year      := to_number(hcm_util.get_string_t(json_obj,'p_styear'));
    b_index_e_mth       := hcm_util.get_string_t(json_obj,'p_enmonth');
    b_index_e_year      := to_number(hcm_util.get_string_t(json_obj,'p_enyear'));
    --
    v_document_msg      := null;
    v_document_name     := null;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure initial_report(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    itemSelected        := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    -----
    p_codempid          := hcm_util.get_string_t(json_obj,'codempid');
    p_numhmref          := hcm_util.get_string_t(json_obj,'numhmref');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'numseq');
    p_codcomp           := hcm_util.get_string_t(json_obj,'codcomp');
    p_codform           := hcm_util.get_string_t(json_obj,'codform');
    p_codtrn            := hcm_util.get_string_t(json_obj,'codtrn');
    p_url               := hcm_util.get_string_t(json_obj,'url');
    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_s_mth       := hcm_util.get_string_t(json_obj,'p_stmonth');
    b_index_s_year      := to_number(hcm_util.get_string_t(json_obj,'p_styear'));
    b_index_e_mth       := hcm_util.get_string_t(json_obj,'p_enmonth');
    b_index_e_year      := to_number(hcm_util.get_string_t(json_obj,'p_enyear'));
    --
    v_document_msg      := null;
    v_document_name     := null;

  end initial_report;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number := 0;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_secure1	      boolean;
    v_secure2       varchar2(1)	  :=	'N';
    v_data	        varchar2(1)	  :=	'N';
    data_typmove    varchar2(4000 char);
    -- check null data --
    v_flg_exist     boolean := false;

    cursor c1 is
      select  numhmref  item7,
              typdoc    item8,
              codempid  item9,
              codtrn    item10,
              get_tcodec_name('TCODMOVE',codtrn,global_v_lang) item11,
              codcomp   item12,
              get_tcenter_name(codcomp,global_v_lang) item13,
              numseq    item14,
              to_char(dteeffec,'dd/mm/yyyy')  item15,
              to_char(dtehmref,'dd/mm/yyyy')  item16,
              codform   item17
        from  tdocinf
       where ((codempid = b_index_codempid) or (codcomp = p_codcomp and flgnotic = 'Y'))
         and dtehmref between ctrl_s_date and ctrl_e_date
        order by dtehmref desc,numhmref;
  begin

    --
    v_rcnt    := 0;
    obj_row   := json_object_t();
    if p_codcomp is null then
      begin
        select codcomp into p_codcomp
        from temploy1
        where codempid = b_index_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    for i in c1 loop
      v_flg_exist := true;
      v_secure1 := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_secure1 then
        v_data := 'Y';
        v_secure2 := 'Y';
        --
        begin
          select typmove into data_typmove
            from  tcodmove
            where codcodec = i.item10;
        exception when no_data_found then
          data_typmove := 'M';
        end;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numhmref',i.item7);
        obj_data.put('typdoc',i.item8);
        obj_data.put('codempid',i.item9);
        obj_data.put('codtrn',i.item10);
        obj_data.put('desc_codtrn',i.item11);
        obj_data.put('codcomp',i.item12);
        obj_data.put('desc_codcomp',i.item13);
        obj_data.put('numseq',i.item14);
        obj_data.put('dteeffec',i.item15);
        obj_data.put('dtehmref',i.item16);
        obj_data.put('codform',i.item17);

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt+1;
      end if; --v_secure1
    end loop;
    if v_flg_exist then
      if v_secure2 = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        json_str_output := obj_row.to_clob;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tdocinf');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;
  --
  procedure check_index is
    s_date        number;
    e_date        number;
  begin
    if b_index_s_mth is not null and b_index_s_year is not null and
       b_index_e_mth is not null and b_index_e_year is not null then
      s_date := (b_index_s_year*1000) + to_number(b_index_s_mth);
      e_date := (b_index_e_year*1000) + to_number(b_index_e_mth);
      if s_date <= e_date then
        ctrl_s_date := to_date(get_period_date(b_index_s_mth,(b_index_s_year),'S'),'dd/mm/yyyy');
        ctrl_e_date := to_date(get_period_date(b_index_e_mth,(b_index_e_year),'E'),'dd/mm/yyyy');
      else
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      if b_index_s_mth is null then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      elsif b_index_s_year is null then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      elsif b_index_e_mth is null then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      elsif b_index_e_year is null then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      end if;
    end if;
  end;
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
  procedure get_document(json_str_input in clob, json_str_output out clob) as
    obj_row     json_object_t;
    v_count     number := 0;
    v_length    number := 500;
    v_folder    varchar2(1000 char);
  begin
    initial_value(json_str_input);
    initial_report(json_str_input);
    if param_msg_error is null then
      gen_document(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_document(  json_str_output out clob) as
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
       where codempid = p_codempid
         and dteeffec = p_dteeffec
       order by numseq;

    cursor c3 is 
      select *
        from tdocinfd
       where codempid = p_codempid
         and numhmref = p_numhmref
         and typdoc = v_typdoc
       order by numseq;
  begin
    begin
      select codform,dtehmref,codtrn into p_codform, p_dateprint, p_codmove
        from tdocinf
       where numhmref = p_numhmref
         and codempid = p_codempid
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
         where codempid = p_codempid;
      exception when no_data_found then
        temploy1_obj := null;
      end ;
      begin
        select *
          into temploy3_obj
          from temploy3
         where codempid = p_codempid;
      exception when no_data_found then
        temploy3_obj := null;
      end ;
      begin
        select *
          into ttmistk_obj
          from ttmistk
         where codempid = p_codempid
           and dteeffec = p_dteeffec;
      exception when no_data_found then
        ttmistk_obj := null;
      end;
      v_codlang := nvl(v_codlang,global_v_lang);
      numYearReport   := HCM_APPSETTINGS.get_additional_year();
      v_codempid      := p_codempid;
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
                                  to_number(to_char(r2.dteend,'dd'),'99')||' '||
                                  get_nammthabb(to_char(r2.dteend,'mm'),v_codlang)||' '||
                                  (to_number(to_char(r2.dteend,'yyyy')) + global_v_zyear);
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
  end;

--  procedure gen_message(p_codform  in varchar2,
--                        o_message1 out long,
--                        o_typemsg1 out varchar2,
--                        o_message2 out long,
--                        o_typemsg2 out varchar2,
--                        o_message3 out long,
--                        o_typemsg3 out varchar2 )is
--  begin
--    begin
--      select message --,typemsg
--      into  o_message1--,o_typemsg1
--      from tfmrefr
--      where codform = p_codform;
--    exception when no_data_found then
--      o_message1 := null;
--      o_typemsg1 := null;
--    end;
--    o_typemsg1 := 'S' ;
--    begin
--      select message ,typemsg
--      into  o_message2,o_typemsg2
--      from tfmrefr2
--      where codform = p_codform;
--    exception when no_data_found then
--       o_message2 := null;
--       o_typemsg2 := null;
--    end;
--        o_typemsg2 := 'S' ;
--    begin
--      select message --,typemsg
--      into  o_message3--,o_typemsg3
--      from tfmrefr3
--      where codform = p_codform;
--    exception when no_data_found then
--      o_message3 := null;
--      o_typemsg3 := null;
--    end;
--      o_typemsg3 := 'S' ;
--  end;
--  --
--  function std_replace (p_message in long,p_codform in varchar2,p_section in varchar2) return long is
--    v_statmt		long;
--    v_item			varchar2(500);
--    v_value     varchar2(500);
--    v_message 	long;
--    v_codtable  varchar2(15);
--    v_funcdesc  varchar2(200);
--    v_codcolmn  varchar2(60);
--    v_flgchksal varchar2(1);
--    v_codlang   varchar2(3);
--
--    v_secur			boolean;
--    v_zupdsal   varchar2(4);
--
--   cursor c1 is
--    select fparam,ffield,descript,a.codtable,fwhere,
--           'select '||ffield||' from '||a.codtable ||' where '||fwhere stm ,flgdesc
--        from tfmtable a,tfmparam b ,tfmrefr c
--        where b.codform  = c.codform
--          and a.codapp   = c.typfm
--          and a.numseq   = b.numseq
--          and a.codtable = b.codtable
--          and b.flgstd   = 'N'
--          and b.section = p_section
--          and nvl(b.flginput,'N') <> 'Y'
--          and b.codform  = p_codform
--     order by b.numseq;
--
--  begin
--    declare_param_numcol  := 0;
--    v_message := p_message;
--    for i in c1 loop
--      v_codtable := i.codtable;
--      v_codcolmn := i.ffield;
--
--     begin
--          select funcdesc ,flgchksal into v_funcdesc,v_flgchksal
--            from tcoldesc
--           where codtable = v_codtable
--             and codcolmn = v_codcolmn;
--     exception when no_data_found then
--          v_funcdesc := null;
--          v_flgchksal:= 'N' ;
--     end;
--     begin
--      select codlang
--      into v_codlang
--      from tfmrefr
--      where codform = p_codform;
--    exception when no_data_found then
--      v_codlang := global_v_lang;
--      end;
--      v_codlang := nvl(v_codlang,global_v_lang);
--     if nvl(i.flgdesc,'N') = 'N' then
--        v_funcdesc := null;
--     end if;
--     if v_flgchksal = 'Y' then
--         v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
--     elsif 	v_funcdesc is not null then
--         v_funcdesc := replace(v_funcdesc,'P_CODE',i.ffield) ;
--         v_funcdesc := replace(v_funcdesc,'P_LANG',v_codlang) ;
--         v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
--         v_funcdesc := replace(v_funcdesc,'P_TEXT',v_chken) ;
--         v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where '||i.fwhere ;
--     else
--         v_statmt  := i.stm ;
--     end if;
--
--     v_statmt := replace(v_statmt,'[:CTRL.CODEMPID]',p_codempid);
--     v_statmt := replace(v_statmt,'[:CTRL.DTEEFFEC]','to_date('''||to_char(p_dteeffec,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
--     v_statmt := replace(v_statmt,'[:CTRL.NUMSEQ]',p_numseq);
--     v_value   := execute_desc(v_statmt) ;
--
--     if v_flgchksal = 'Y' and global_v_zupdsal = 'N' then
--        v_value   := null ;
--     end if;
--
--     v_message := replace(v_message,i.fparam,v_value);
--
--     --mdf mail merge
--     declare_param_numcol  := declare_param_numcol + 1;
--     declare_param_flabel(declare_param_numcol)  := i.fparam||'   '||i.descript;
--     declare_param_fparam(declare_param_numcol)  := i.fparam;
--     declare_param_fdata(declare_param_numcol)   := v_value;
--    end loop;
--    --
--    for i in 1..declare_param_qty loop
--        v_message := replace(v_message,declare_param_param(i),declare_param_value(i)) ;
--         --mdf mail merge
--        declare_param_numcol  := declare_param_numcol + 1;
--        declare_param_flabel(declare_param_numcol)  := declare_param_label(i);
--        declare_param_fparam(declare_param_numcol)  := declare_param_param(i);
--        declare_param_fdata(declare_param_numcol)   := declare_param_value(i);
--    end loop ;
--    return  v_message;
--  end;
--  --
--  --find codcurrency
--  function  get_curr (p_codcomp varchar2) return varchar2 Is
--   v_codcurr varchar2(4);
--  begin
--    begin
--      select codcurr
--      into   v_codcurr
--      from   tcontrpy
--      where  codcompy = p_codcomp
--      and		 dteeffec in ( select max(dteeffec)
--                           from   tcontrpy
--                           where  dteeffec <= sysdate
--                           and    codcompy = p_codcomp)
--
--      and  rownum = 1 ;
--      return(v_codcurr) ;
--    exception when no_data_found then
--      return(null);
--    end ;
--  end;
--  --
--  --find codincome
--  PROCEDURE  get_cod_income		(	 p_codcompy  in varchar2 ,
--                                 p_codempmt  in varchar2 ,
--                                 p_codincom1 out varchar2,
--                                 p_codincom2 out varchar2,
--                                 p_codincom3 out varchar2,
--                                 p_codincom4 out varchar2,
--                                 p_codincom5 out varchar2,
--                                 p_codincom6 out varchar2,
--                                 p_codincom7 out varchar2,
--                                 p_codincom8 out varchar2,
--                                 p_codincom9 out varchar2,
--                                 p_codincom10 out varchar2,
--                                 p_unitcal1		out varchar2,
--                                 p_unitcal2   out varchar2,
--                                 p_unitcal3   out varchar2,
--                                 p_unitcal4   out varchar2,
--                                 p_unitcal5   out varchar2,
--                                 p_unitcal6   out varchar2,
--                                 p_unitcal7   out varchar2,
--                                 p_unitcal8   out varchar2,
--                                 p_unitcal9   out varchar2,
--                                 p_unitcal10  out varchar2) IS
--   v_dteeffec1 date;
--   v_dteeffec2 date;
--
--  BEGIN
--    begin
--        select codincom1,codincom2,codincom3,codincom4,codincom5,
--               codincom6,codincom7,codincom8,codincom9,codincom10
--        into   p_codincom1,p_codincom2,p_codincom3,p_codincom4,p_codincom5,
--               p_codincom6,p_codincom7,p_codincom8,p_codincom9,p_codincom10
--        from  tcontpms
--        where codcompy = p_codcompy
--          AND dteeffec in (select max(dteeffec)
--                             from tcontpms
--                            where codcompy = p_codcompy
--                              AND dteeffec <= sysdate);
--    exception when no_data_found then
--      null ;
--    end;
--    begin
--        select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
--               unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
--        into   p_unitcal1,p_unitcal2,p_unitcal3,p_unitcal4,p_unitcal5,
--               p_unitcal6,p_unitcal7,p_unitcal8,p_unitcal9,p_unitcal10
--        from   tcontpmd
--        where  codcompy = p_codcompy
--        and    codempmt = p_codempmt
--        and    dteeffec = (select max(dteeffec)
--                            from   tcontpmd
--                            where  codcompy  = p_codcompy
--                            and    codempmt = p_codempmt
--                            and    dteeffec <= sysdate);
--    exception when no_data_found then
--      null ;
--    end;
--    if p_codincom1 is null then
--       p_unitcal1  := null ;
--    end if;
--    if p_codincom2 is null then
--       p_unitcal2  := null ;
--    end if;
--    if p_codincom3 is null then
--       p_unitcal3  := null ;
--    end if;
--    if p_codincom4 is null then
--       p_unitcal4  := null ;
--    end if;
--    if p_codincom5 is null then
--       p_unitcal5  := null ;
--    end if;
--    if p_codincom6 is null then
--       p_unitcal6  := null ;
--    end if;
--    if p_codincom7 is null then
--       p_unitcal7  := null ;
--    end if;
--    if p_codincom8 is null then
--       p_unitcal8   := null ;
--    end if;
--    if p_codincom9 is null then
--       p_unitcal9  := null ;
--    end if;
--    if p_codincom10 is null then
--       p_unitcal10  := null ;
--    end if;
--
--  END get_cod_income;
--  --find detail codincome
--  PROCEDURE get_income (p_codincom in out varchar2,p_detail  out varchar2) IS
--    cursor curr1 is
--                select descpaye,descpayt,descpay3,descpay4,descpay5
--                from   tinexinf
--                where  codpay = p_codincom
--                and rownum <= 1;
--  BEGIN
--    for i in curr1 loop
--      if global_v_lang = '101' then
--        p_detail:= i.DESCPAYE;
--      elsif global_v_lang = '102' then
--        p_detail := i.DESCPAYT;
--      elsif global_v_lang = '103' then
--        p_detail := i.DESCPAY3;
--      elsif global_v_lang = '104' then
--        p_detail := i.DESCPAY4;
--      elsif global_v_lang = '105' then
--        p_detail := i.DESCPAY5;
--      end if;
--    end loop ;
--  End;
--  --
--  --find detail unitcal
--  PROCEDURE get_typy (	p_typy in out varchar2,p_desc  out varchar2) IS
--      cursor typy1 is
--        select DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5
--        from   tcodtypy
--        where  CODCODEC  = p_typy
--        and rownum <= 1;
--  BEGIN
--      for i in typy1 loop
--        if global_v_lang = '101' then
--          p_desc := i.descode;
--        elsif global_v_lang = '102' then
--          p_desc := i.descodt;
--        elsif global_v_lang = '103' then
--          p_desc := i.descod3;
--        elsif global_v_lang = '104' then
--          p_desc := i.descod4;
--        elsif global_v_lang = '105' then
--          p_desc := i.descod5;
--        end if;
--      end loop ;
--  END get_typy;
--  --
--  PROCEDURE rep_txt_ttexempt(out_file utl_file.file_type) IS
--    in_file     	utl_file.file_type;
--    data_file 	  long;
--    v_text        varchar2(30 char);
--    v_data_file 	varchar2(6000 char);
--    crlf          varchar2(2 char):= CHR( 13 ) || CHR( 10 );
--
--
--    type array_of_varchar is table of varchar2(10) index by binary_integer;
--      v_typemsg  array_of_varchar;
--
--    type array_of_long  is table of long index by binary_integer;
--      v_message    array_of_long;
--
--    cursor c1 is
--       select  codempid,codcomp,numlvl,dteeffec,codpos
--         from  ttexempt
--         where codempid  = p_codempid
--           and dteeffec  = p_dteeffec
--           and codcomp   = p_codcomp
--           and staupd    <>  'N'
--           and numannou  = p_numhmref
--         order by codempid ;
--
--    cursor c_tdocinfd is
--      select *
--        from tdocinfd
--       where numhmref = p_numhmref;
--
--  begin
--    gen_message(p_codform,v_message(1),v_typemsg(1),
--                          v_message(2),v_typemsg(2),
--                          v_message(3),v_typemsg(3));
--
--    declare_param_qty := 0 ;
--    for i in c_tdocinfd loop
--       declare_param_qty := declare_param_qty + 1 ;
--       declare_param_param(declare_param_qty) := i.fparam ;
--       declare_param_value(declare_param_qty) := i.fvalue ;
--        --mail merge
--        declare_param_label(declare_param_qty) := i.fparam;
--    end loop ;
--
--
--    for i in 1..3 loop
--       data_file := v_message(i) ;
--       if  v_typemsg(i) = 'S' then -- Single
--        data_file := std_replace(data_file,p_codform,i);
--        data_file := replace(data_file ,'[param_1]', p_numhmref);		--<e01-param>
--        data_file := replace(data_file ,'[param_2]', get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang));
--        for tm_ttexempt in c1 loop
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,30)||'  '||get_temploy_name(tm_ttexempt.codempid,global_v_lang)||crlf||
--                         '          '||get_label_name('HRES38XC2',global_v_lang,40)||'  '||get_tpostn_name(tm_ttexempt.codpos,global_v_lang)||'   '||get_label_name('HRES38XC2',global_v_lang,50)||'  '||get_tcenter_name(tm_ttexempt.codcomp,global_v_lang)||crlf;
--        end loop;
--        data_file := replace(data_file ,'[param_3]', v_data_file);
--        data_file := replace(data_file ,'[param_4]', to_number(to_char(p_dteeffec,'dd'),'99')||' '||
--                                                      get_nammthabb(to_char(p_dteeffec,'mm'),global_v_lang)||' '||
--                                                      get_ref_year(global_v_lang,v_zyear,to_number(to_char(p_dteeffec,'yyyy'))));
--          v_message(i) := data_file;
--      else
--          v_message(i) := null;
--      end if;
--    end loop ;
--
--    data_file := null;
--    for i in 1..3 loop
--        if v_message(i) is not null then
--           data_file :=  data_file||crlf||convert(v_message(i),'TH8TISASCII') ;
--        end if;
--    end loop ;
--
--    v_document_msg := data_file;
--    utl_file.put_line(out_file,data_file);
--  end ;
--  --
--  procedure rep_txt_ttmistk (out_file utl_file.File_Type) is
--    in_file     	utl_file.file_type;
--    linebuf  		  varchar2(6000 char);
--    data_file 	  long;
--    v_count       number    := 0;
--    v_count2      number    := 0;
--    v_codpunsh    ttpunsh.codpunsh%type;
--    v_data_file 	varchar2(7000 char);
--    crlf          varchar2(2 char):= chr( 13 ) || chr( 10 );
--    v_amtded      varchar2(20 char);
--    v_desmist1    varchar2(200 char);
--
--    type array_of_varchar is table of varchar2(10) index by binary_integer;
--      v_typemsg  array_of_varchar;
--
--    type array_of_long  is table of long index by binary_integer;
--      v_message    array_of_long;
--
--    cursor c1 is
--       select  codpunsh,dtestart,dteend
--         from  ttpunsh
--         where dteeffec  = p_dteeffec
--           and codempid  = p_codempid;
--
--      cursor c2 is
--        select codpay,amtded,dteeffec,codpunsh,
--               dteyearst,dtemthst,numprdst,dteyearen,dtemthen,numprden
--        from  ttpunded
--        where codempid = p_codempid
--        and   dteeffec = p_dteeffec
--        and   codpunsh = v_codpunsh
--       order by codpunsh,dteeffec,codpay;
--
--    cursor c_tdocinfd is
--      select *
--        from tdocinfd
--       where numhmref = p_numhmref;
--
--
--
--  begin
--
--      begin
--        select  desmist1 into v_desmist1
--          from  ttmistk
--          where codempid = p_codempid
--            and dteeffec = p_dteeffec;
--      exception when no_data_found then
--        v_desmist1 := ' ';
--      end;
--
--    gen_message(p_codform,v_message(1),v_typemsg(1),
--                              v_message(2),v_typemsg(2),
--                              v_message(3),v_typemsg(3));
--
--    declare_param_qty := 0 ;
--    for i in c_tdocinfd loop
--       declare_param_qty := declare_param_qty + 1 ;
--       declare_param_param(declare_param_qty) := i.fparam ;
--       declare_param_value(declare_param_qty) := i.fvalue ;
--        --mail merge
--        declare_param_label(declare_param_qty) := i.fparam;
--    end loop ;
--
--
--    for i in 1..3 loop
--       data_file := v_message(i) ;
--       if  v_typemsg(i) = 'S' then -- Single
--        data_file := std_replace(data_file,p_codform,i);
--        data_file := replace(data_file ,'[param_1]', p_numhmref);
--        data_file := replace(data_file ,'[param_2]', get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang));
--        data_file := replace(data_file ,'[param_3]', get_temploy_name(p_codempid,global_v_lang));
--        data_file := replace(data_file ,'[param_4]', v_desmist1);
--
--        begin
--          select  count(codpunsh) into v_count
--            from  ttpunsh
--            where dteeffec  = p_dteeffec
--            and   codempid  = p_codempid;
--        exception when no_data_found then
--          v_count := 0;
--        end;
--        if v_count = 0 then
--          data_file := replace(data_file ,'[param_5]' , null);
--        else
--          for tm_ttpunsh in c1 loop
--            v_codpunsh := tm_ttpunsh.codpunsh;
--
--            v_data_file := v_data_file||get_tcodec_name('TCODPUNH',v_codpunsh,global_v_lang)||'   '||
--                           get_label_name('HRES38XC2',global_v_lang,10)||'  '||
--                           to_number(to_char(tm_ttpunsh.dtestart,'dd'),'99')||' '||
--                           get_nammthabb(to_char(tm_ttpunsh.dtestart,'mm'),global_v_lang)||' '||
--                           get_ref_year(global_v_lang,v_zyear,to_number(to_char(tm_ttpunsh.dtestart,'yyyy')))||' - '||
--                           to_number(to_char(tm_ttpunsh.dteend,'dd'),'99')||' '||
--                           get_nammthabb(to_char(tm_ttpunsh.dteend,'mm'),global_v_lang)||' '||
--                           get_ref_year(global_v_lang,v_zyear,to_number(to_char(tm_ttpunsh.dteend,'yyyy')))||crlf;
--            begin
--              select  count(codpay) into v_count2
--                from  ttpunded
--                where codempid  = p_codempid
--                and   dteeffec  = p_dteeffec
--                and   codpunsh  = v_codpunsh;
--            exception when no_data_found then
--              v_count2 := 0;
--            end;
--            if v_count2 = 0 then
--              null;
--            else
--              for tm_ttpunded  in c2 loop
--              v_amtded    := stddec(tm_ttpunded.amtded,p_codempid,v_chken);
--              v_data_file	:= v_data_file||get_tinexinf_name(tm_ttpunded.codpay,global_v_lang)||'   '||
--                             to_char(to_number(v_amtded),'9,999,990.00')||'  '||
--                             get_label_name('HRES38XC2',global_v_lang,20)||' '||
--                             tm_ttpunded.numprdst||'/'||tm_ttpunded.dtemthst||'/'||tm_ttpunded.dteyearst||' - '||tm_ttpunded.numprden||'/'||tm_ttpunded.dtemthen||'/'||tm_ttpunded.dteyearen||crlf;
--
--              end loop;
--            end if;
--          end loop;
--        end if;
--
--        data_file := replace(data_file ,'[param_5]', v_data_file);
--        data_file := replace(data_file ,'[param_6]', to_number(to_char(p_dteeffec,'dd'),'99')||' '||
--                                                       get_nammthful(to_char(p_dteeffec,'mm'),global_v_lang)||' '||
--                                                       get_ref_year(global_v_lang,v_zyear,to_number(to_char(p_dteeffec,'yyyy'))));
--
--
--        v_message(i) := data_file;
--      else
--          v_message(i) := null;
--      end if;
--    end loop ;
--
--    data_file := null;
--    for i in 1..3 loop
--        if v_message(i) is not null then
--           data_file :=  data_file||crlf||convert(v_message(i),'TH8TISASCII') ;
--        end if;
--    end loop ;
--
--    v_document_msg := data_file;
--    utl_file.Put_line(out_file,data_file);
--
--  end;
--  --
--  procedure rep_txt_ttmovemt(out_file utl_file.file_type)is
--    data_file 	  long ;
--    v_data_file   long ;
--    crlf          varchar2(2 char):= CHR( 13 ) || CHR( 10 );
--
--    type array_of_varchar is table of varchar2(50) index by binary_integer;
--      v_typemsg  array_of_varchar;
--
--    type array_of_long  is table of long index by binary_integer;
--      v_message    array_of_long;
--
--    v_seq				number := 0;
--    v_seqn			number := 0;
--    v_codempid  temploy1.codempid%type;
--    v_msg   		varchar2(4000 char)	 ;
--    v_err   		varchar2(10 char)	 ;
--
--    cursor c1 is
--       select numhmref,codempid,codcomp,dteeffec,codform,numseq
--         from tdocinf
--        where numhmref = p_numhmref ;
--
--      cursor c_tdocinfd is
--      select *
--        from tdocinfd
--       where numhmref = p_numhmref;
--
--  begin
--    gen_message(p_codform,v_message(1),v_typemsg(1),
--                              v_message(2),v_typemsg(2),
--                              v_message(3),v_typemsg(3));
--      declare_param_qty := 0 ;
--      for i in c_tdocinfd loop
--         declare_param_qty := declare_param_qty + 1 ;
--         declare_param_param(declare_param_qty) := i.fparam ;
--         declare_param_value(declare_param_qty) := i.fvalue ;
--        --mail merge
--        declare_param_label(declare_param_qty) := i.fparam;
--      end loop ;
--
--      for i in 1..3 loop
--              data_file := v_message(i) ;
--          if  v_typemsg(i) = 'S' then -- Single
--              data_file := std_replace(data_file,p_codform,i);
--              data_file := replace(data_file ,'[param_0]',to_number(to_char(sysdate,'dd'),'99')||' '||
--                                                            get_nammthful(to_char(sysdate,'mm'),global_v_lang)||' '||
--                                                            get_ref_year(global_v_lang,v_zyear,to_number(to_char(sysdate,'yyyy'))));
--              data_file := replace(data_file ,'[param_1]',p_numhmref);
--              data_file := replace(data_file ,'[param_2]',get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang));
--
--              data_file := replace(data_file ,'[param_10]',to_number(to_char(p_dteeffec,'dd'),'99')||' '||
--                                                            get_nammthful(to_char(p_dteeffec,'mm'),global_v_lang)||' '||
--                                                            get_ref_year(global_v_lang,v_zyear,to_number(to_char(p_dteeffec,'yyyy'))));
--
--              v_message(i) := data_file;
--
--          else -- Multiple
--              for j in c1 loop
--                  data_file      := v_message(i) ;
--                  data_file      := std_replace(data_file,j.codform,i);
--                  v_data_file    := v_data_file ||crlf||data_file ;
--              end loop;
--                v_message(i) := v_data_file;
--          end if;
--      end loop ;
--
--      data_file := null;
--      for i in 1..3 loop
--          if v_message(i) is not null then
--             data_file :=  data_file||crlf||convert(v_message(i),'TH8TISASCII') ;
--          end if;
--      end loop ;
--
--    v_document_msg := data_file;
--    utl_file.Put_line(out_file,data_file);
--  end;
--  --
--  PROCEDURE rep_txt_ttmovemt_a (out_file utl_file.File_Type)IS
--    in_file     	utl_file.file_type;
--    data_file 	  long;
--    v_data_file 	varchar2(6000 char);
--    crlf          varchar2(2 char):= CHR( 13 ) || CHR( 10 );
--    v_codempmt    ttmovemt.codempmt%type;
--    v_amtincom    varchar2(20 char);
--    v_amtincadj	  varchar2(20 char);
--
--    type array_of_varchar is table of varchar2(10 char) index by binary_integer;
--      v_typemsg  array_of_varchar;
--
--    type array_of_long  is table of long index by binary_integer;
--      v_message    array_of_long;
--
--    cursor c_tdocinfd is
--      select *
--        from tdocinfd
--       where numhmref = p_numhmref;
--
--  begin
--
--      begin
--          select  codempmt,codcurr,
--                  amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
--                  amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
--                  amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
--                  amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10
--            into  v_codempmt,ctrl_codcurr,
--                  ctrl_amtincom1,ctrl_amtincom2,ctrl_amtincom3,ctrl_amtincom4,ctrl_amtincom5,
--                  ctrl_amtincom6,ctrl_amtincom7,ctrl_amtincom8,ctrl_amtincom9,ctrl_amtincom10,
--                  ctrl_amtincadj1,ctrl_amtincadj2,ctrl_amtincadj3,ctrl_amtincadj4,ctrl_amtincadj5,
--                  ctrl_amtincadj6,ctrl_amtincadj7,ctrl_amtincadj8,ctrl_amtincadj9,ctrl_amtincadj10
--            from  ttmovemt
--            where codempid = p_codempid
--              and dteeffec = p_dteeffec
--              and numseq   = p_numseq;
--        exception when no_data_found then
--          null;
--        end;
--
--        ctrl_descurr  := get_tcodec_name('TCODCURR',ctrl_codcurr,global_v_lang);
--        --<<weerayut 24/05/2018
--        /*for j in 1..10 loop
--          v_amtincom       := round(stddec(name_in('ctrl_amtincom'||j),p_codempid,v_chken),2);
--          v_amtincadj      := round(stddec(name_in('ctrl_amtincadj'||j),p_codempid,v_chken),2);
--          copy(v_amtincom,'ctrl.amtincom'||j);
--          copy(v_amtincadj,'ctrl.amtincadj'||j);
--        end loop;*/
--        ctrl_amtincom1      := round(stddec(ctrl_amtincom1,p_codempid,v_chken),2);
--        ctrl_amtincom2      := round(stddec(ctrl_amtincom2,p_codempid,v_chken),2);
--        ctrl_amtincom3      := round(stddec(ctrl_amtincom3,p_codempid,v_chken),2);
--        ctrl_amtincom4      := round(stddec(ctrl_amtincom4,p_codempid,v_chken),2);
--        ctrl_amtincom5      := round(stddec(ctrl_amtincom5,p_codempid,v_chken),2);
--        ctrl_amtincom6      := round(stddec(ctrl_amtincom6,p_codempid,v_chken),2);
--        ctrl_amtincom7      := round(stddec(ctrl_amtincom7,p_codempid,v_chken),2);
--        ctrl_amtincom8      := round(stddec(ctrl_amtincom8,p_codempid,v_chken),2);
--        ctrl_amtincom9      := round(stddec(ctrl_amtincom9,p_codempid,v_chken),2);
--        ctrl_amtincom10     := round(stddec(ctrl_amtincom10,p_codempid,v_chken),2);
--        ctrl_amtincadj1     := round(stddec(ctrl_amtincadj1,p_codempid,v_chken),2);
--        ctrl_amtincadj2     := round(stddec(ctrl_amtincadj2,p_codempid,v_chken),2);
--        ctrl_amtincadj3     := round(stddec(ctrl_amtincadj3,p_codempid,v_chken),2);
--        ctrl_amtincadj4     := round(stddec(ctrl_amtincadj4,p_codempid,v_chken),2);
--        ctrl_amtincadj5     := round(stddec(ctrl_amtincadj5,p_codempid,v_chken),2);
--        ctrl_amtincadj6     := round(stddec(ctrl_amtincadj6,p_codempid,v_chken),2);
--        ctrl_amtincadj7     := round(stddec(ctrl_amtincadj7,p_codempid,v_chken),2);
--        ctrl_amtincadj8     := round(stddec(ctrl_amtincadj8,p_codempid,v_chken),2);
--        ctrl_amtincadj9     := round(stddec(ctrl_amtincadj9,p_codempid,v_chken),2);
--        ctrl_amtincadj10    := round(stddec(ctrl_amtincadj10,p_codempid,v_chken),2);
--        -->>weerayut 24/05/2018
--        get_cod_income(hcm_util.get_codcomp_level(p_codcomp,1),v_codempmt
--                  ,ctrl_codincom1,ctrl_codincom2,ctrl_codincom3,ctrl_codincom4,ctrl_codincom5
--                  ,ctrl_codincom6,ctrl_codincom7,ctrl_codincom8,ctrl_codincom9,ctrl_codincom10
--                  ,ctrl_unitcal1, ctrl_unitcal2, ctrl_unitcal3, ctrl_unitcal4, ctrl_unitcal5
--                  ,ctrl_unitcal6, ctrl_unitcal7, ctrl_unitcal8, ctrl_unitcal9, ctrl_unitcal10);
--
--        if ctrl_codincom1 is not null and ctrl_amtincom1 > 0 then
--          ctrl_amtincomo1 := nvl(ctrl_amtincom1,0) - nvl(ctrl_amtincadj1,0);    --amount old
--          ctrl_amtincom1  := nvl(ctrl_amtincom1,0);                              --amount new
--          ctrl_desunit1   := null;
--
--          get_income(ctrl_codincom1,ctrl_descpay1);
--          if ctrl_unitcal1 is not null then
--            ctrl_desunit1 := get_tlistval_name('NAMEUNIT',ctrl_unitcal1,global_v_lang);
--          end if;
--        else
--          ctrl_codincom1  := null;
--        end if;
--
--        if ctrl_codincom2 is not null and ctrl_amtincom2 > 0 then
--          ctrl_amtincomo2 := nvl(ctrl_amtincom2,0) - nvl(ctrl_amtincadj2,0);    --amount old
--          ctrl_amtincom2  := nvl(ctrl_amtincom2,0);                              --amount new
--          ctrl_desunit2   := null;
--
--          get_income(ctrl_codincom2,ctrl_descpay2);
--          if ctrl_unitcal2 is not null then
--            ctrl_desunit2 := get_tlistval_name('NAMEUNIT',ctrl_unitcal2,global_v_lang);
--          end if;
--        else
--          ctrl_codincom2  := null;
--        end if;
--
--        if ctrl_codincom3 is not null and ctrl_amtincom3 > 0 then
--          ctrl_amtincomo3 := nvl(ctrl_amtincom3,0) - nvl(ctrl_amtincadj3,0);    --amount old
--          ctrl_amtincom3  := nvl(ctrl_amtincom3,0);                          --amount new
--          ctrl_desunit3   := null;
--
--          get_income(ctrl_codincom3,ctrl_descpay3);
--          if ctrl_unitcal3 is not null then
--            ctrl_desunit3 := get_tlistval_name('NAMEUNIT',ctrl_unitcal3,global_v_lang);
--          end if;
--        else
--          ctrl_codincom3  := null;
--        end if;
--
--        if ctrl_codincom4 is not null and ctrl_amtincom4 > 0 then
--          ctrl_amtincomo4 := nvl(ctrl_amtincom4,0) - nvl(ctrl_amtincadj4,0);    --amount old
--          ctrl_amtincom4  := nvl(ctrl_amtincom4,0);                          --amount new
--          ctrl_desunit4   := null;
--
--          get_income(ctrl_codincom4,ctrl_descpay4);
--          if ctrl_unitcal4 is not null then
--            ctrl_desunit4 := get_tlistval_name('NAMEUNIT',ctrl_unitcal4,global_v_lang);
--          end if;
--        else
--          ctrl_codincom4  := null;
--        end if;
--
--        if ctrl_codincom5 is not null and ctrl_amtincom5 > 0 then
--          ctrl_amtincomo5 := nvl(ctrl_amtincom5,0) - nvl(ctrl_amtincadj5,0);    --amount old
--          ctrl_amtincom5  := nvl(ctrl_amtincom5,0);                          --amount new
--          ctrl_desunit5   := null;
--
--          get_income(ctrl_codincom5,ctrl_descpay5);
--          if ctrl_unitcal5 is not null then
--            ctrl_desunit5 := get_tlistval_name('NAMEUNIT',ctrl_unitcal5,global_v_lang);
--          end if;
--        else
--          ctrl_codincom5  := null;
--        end if;
--
--        if ctrl_codincom6 is not null and ctrl_amtincom6 > 0 then
--          ctrl_amtincomo6 := nvl(ctrl_amtincom6,0) - nvl(ctrl_amtincadj6,0);    --amount old
--          ctrl_amtincom6  := nvl(ctrl_amtincom6,0);                          --amount new
--          ctrl_desunit6   := null;
--
--          get_income(ctrl_codincom6,ctrl_descpay6);
--          if ctrl_unitcal6 is not null then
--            ctrl_desunit6 := get_tlistval_name('NAMEUNIT',ctrl_unitcal6,global_v_lang);
--          end if;
--        else
--          ctrl_codincom6  := null;
--        end if;
--
--        if ctrl_codincom7 is not null and ctrl_amtincom7 > 0 then
--          ctrl_amtincomo7 := nvl(ctrl_amtincom7,0) - nvl(ctrl_amtincadj7,0);    --amount old
--          ctrl_amtincom7  := nvl(ctrl_amtincom7,0);                          --amount new
--          ctrl_desunit7   := null;
--
--          get_income(ctrl_codincom7,ctrl_descpay7);
--          if ctrl_unitcal7 is not null then
--            ctrl_desunit7 := get_tlistval_name('NAMEUNIT',ctrl_unitcal7,global_v_lang);
--          end if;
--        else
--          ctrl_codincom7  := null;
--        end if;
--
--        if ctrl_codincom8 is not null and ctrl_amtincom8 > 0 then
--          ctrl_amtincomo8 := nvl(ctrl_amtincom8,0) - nvl(ctrl_amtincadj8,0);    --amount old
--          ctrl_amtincom8  := nvl(ctrl_amtincom8,0);                          --amount new
--          ctrl_desunit8   := null;
--
--          get_income(ctrl_codincom8,ctrl_descpay8);
--          if ctrl_unitcal8 is not null then
--            ctrl_desunit8 := get_tlistval_name('NAMEUNIT',ctrl_unitcal8,global_v_lang);
--          end if;
--        else
--          ctrl_codincom8  := null;
--        end if;
--
--        if ctrl_codincom9 is not null and ctrl_amtincom9 > 0 then
--          ctrl_amtincomo9 := nvl(ctrl_amtincom9,0) - nvl(ctrl_amtincadj9,0);    --amount old
--          ctrl_amtincom9  := nvl(ctrl_amtincom9,0);                          --amount new
--          ctrl_desunit9   := null;
--
--          get_income(ctrl_codincom9,ctrl_descpay9);
--          if ctrl_unitcal9 is not null then
--            ctrl_desunit9 := get_tlistval_name('NAMEUNIT',ctrl_unitcal9,global_v_lang);
--          end if;
--        else
--          ctrl_codincom9  := null;
--        end if;
--
--        if ctrl_codincom10 is not null and ctrl_amtincom10 > 0 then
--          ctrl_amtincomo10 := nvl(ctrl_amtincom10,0) - nvl(ctrl_amtincadj10,0);    --amount old
--          ctrl_amtincom10  := nvl(ctrl_amtincom10,0);                          --amount new
--          ctrl_desunit10   := null;
--
--          get_income(ctrl_codincom10,ctrl_descpay10);
--          if ctrl_unitcal10 is not null then
--            ctrl_desunit10 := get_tlistval_name('NAMEUNIT',ctrl_unitcal10,global_v_lang);
--          end if;
--        else
--          ctrl_codincom10  := null;
--        end if;
--
--
--    gen_message(p_codform,v_message(1),v_typemsg(1),
--                              v_message(2),v_typemsg(2),
--                              v_message(3),v_typemsg(3));
--
--
--    declare_param_qty := 0 ;
--    for i in c_tdocinfd loop
--       declare_param_qty := declare_param_qty + 1 ;
--       declare_param_param(declare_param_qty) := i.fparam ;
--       declare_param_value(declare_param_qty) := i.fvalue ;
--        --mail merge
--        declare_param_label(declare_param_qty) := i.fparam;
--    end loop ;
--
--
--    for i in 1..3 loop
--       data_file := v_message(i) ;
--       if  v_typemsg(i) = 'S' then -- Single
--        data_file := std_replace(data_file,p_codform,i);
--        data_file := replace(data_file ,'[param_0]', to_number(to_char(sysdate,'dd'),'99')||' '||
--                                                       get_nammthful(to_char(sysdate,'mm'),global_v_lang)||' '||
--                                                       get_ref_year(global_v_lang,v_zyear,to_number(to_char(sysdate,'yyyy'))));
--        data_file := replace(data_file ,'[param_1]', p_numhmref);
--        data_file := replace(data_file ,'[param_2]', get_temploy_name(p_codempid,global_v_lang));
--        data_file := replace(data_file ,'[param_3]', get_tcenter_name(p_codcomp,global_v_lang));
--        data_file := replace(data_file ,'[param_4]', get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang));
--
--        if ctrl_codincom1 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay1||'   '||
--                         to_char(to_number(ctrl_amtincomo1),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom1),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit1||crlf;
--
--        end if;
--        if ctrl_codincom2 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay2||'   '||
--                         to_char(to_number(ctrl_amtincomo2),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom2),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit2||crlf;
--        end if;
--        if ctrl_codincom3 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay3||'   '||
--                         to_char(to_number(ctrl_amtincomo3),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom3),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit3||crlf;
--        end if;
--        if ctrl_codincom4 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay4||'   '||
--                         to_char(to_number(ctrl_amtincomo4),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom4),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit4||crlf;
--        end if;
--        if ctrl_codincom5 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay5||'   '||
--                         to_char(to_number(ctrl_amtincomo5),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom5),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit5||crlf;
--        end if;
--        if ctrl_codincom6 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay6||'   '||
--                         to_char(to_number(ctrl_amtincomo6),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom6),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit6||crlf;
--        end if;
--        if ctrl_codincom7 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay7||'   '||
--                         to_char(to_number(ctrl_amtincomo7),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom7),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit7||crlf;
--        end if;
--        if ctrl_codincom8 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay8||'   '||
--                         to_char(to_number(ctrl_amtincomo8),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom8),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit8||crlf;
--        end if;
--        if ctrl_codincom9 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay9||'   '||
--                         to_char(to_number(ctrl_amtincomo9),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90)||'  '||
--                         to_char(to_number(ctrl_amtincom9),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit9||crlf;
--        end if;
--        if ctrl_codincom10 is not null then
--          v_data_file := v_data_file||get_label_name('HRES38XC2',global_v_lang,80)||'  '||ctrl_descpay10||'   '||
--                         to_char(to_number(ctrl_amtincomo10),'9,999,990.00')||'  '||ctrl_descurr ||'   '||
--                         get_label_name('HRES38XC2',global_v_lang,90) ||'  '||
--                         to_char(to_number(ctrl_amtincom10),'9,999,990.00') ||'  '||ctrl_descurr ||'   '||ctrl_desunit10||crlf;
--        end if;
--
--        data_file := replace(data_file ,'[param_5]', v_data_file);
--        data_file := replace(data_file ,'[param_6]', to_number(to_char(p_dteeffec,'dd'),'99')||' '||
--                                                       get_nammthful(to_char(p_dteeffec,'mm'),global_v_lang)||' '||
--                                                       get_ref_year(global_v_lang,v_zyear,to_number(to_char(p_dteeffec,'yyyy'))));
--
--          v_message(i) := data_file;
--      else
--          v_message(i) := null;
--      end if;
--    end loop ;
--
--    data_file := null;
--    for i in 1..3 loop
--        if v_message(i) is not null then
--           data_file :=  data_file||crlf||convert(v_message(i),'TH8TISASCII') ;
--        end if;
--    end loop ;
--
--    v_document_msg := data_file;
--    utl_file.Put_line(out_file,data_file);
--  end;
--  --
--  procedure check_gen_word is
--    v_code    varchar2(100 char);
--  begin
--    if p_codcomp is not null then
--      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
--      if param_msg_error is not null then
--        return;
--      end if;
--    end if;
--    --
--    if p_codempid is not null then
--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
--      if param_msg_error is not null then
--        return;
--      end if;
--    end if;
--    --
--    if p_numhmref is not null then
--      begin
--        select  numhmref
--        into    v_code
--        from    tdocinfd
--        where   numhmref = p_numhmref
--        and     rownum <= 1;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdocinfd');
--        return;
--      end;
--    end if;
--    --
--    if p_codform is not null then
--      begin
--        select  codlang
--        into    v_code
--        from    tfmrefr
--        where   codform = p_codform;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tfmrefr');
--        return;
--      end;
--    end if;
--    --
--    if p_codtrn is not null then
--      begin
--        select  codcodec
--        into    v_code
--        from    tcodmove
--        where   codcodec  = p_codtrn;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodmove');
--        return;
--      end;
--    end if;
--  end;
--  --
--  function to_base64(t in varchar2) return varchar2 is
--  begin
--    return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
--  end;
--  --
end;

/
