--------------------------------------------------------
--  DDL for Package Body HRRC49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC49X" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
    begin
--  index parameter
        p_codcomp         := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_codpos          := hcm_util.get_string_t(data_obj,'p_codpos');
        p_dteempmtst      := to_date(hcm_util.get_string_t(data_obj,'p_dteempmtst'),'dd/mm/yyyy');
        p_dteempmten      := to_date(hcm_util.get_string_t(data_obj,'p_dteempmten'),'dd/mm/yyyy');
--  detail parameter
        p_codform         := hcm_util.get_string_t(data_obj,'p_codform');
        p_dteprint         := to_date(hcm_util.get_string_t(data_obj,'p_dteprint'),'dd/mm/yyyy');

  end initial_params;

  function check_index return boolean as
    v_temp     varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

    if p_dteempmtst > p_dteempmten then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return false;
    end if;

    return true;

  end;

  function check_detail return boolean as
    v_temp      varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from tfmrefr
        where codform = p_codform;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFMREFR');
        return false;
    end;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
        select a.dteempmt, a.codcomp, a.codempid, a.codempmt, a.numappl
        from tapplinf a
        where a.codcomp like p_codcomp || '%'
          and a.codposc = nvl(p_codpos,a.codposc)
          and a.dteempmt between p_dteempmtst and p_dteempmten
          and a.statappl = '61'
          and exists(select b.codempid
                     from temploy1 b
                     where a.codempid = b.codempid)
        order by a.codempid;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('numappl', i.numappl);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('dtework', to_char(i.dteempmt, 'dd/mm/yyyy'));
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
            obj_data.put('codempid', i.codempid);
            obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
            obj_data.put('typwork', get_tcodec_name('TCODEMPL', i.codempmt, global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;

  end gen_index;

  procedure gen_detail(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
        select descript
        from tfmparam
        where codform = p_codform
          and flginput = 'Y'
        order by ffield;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('descript', i.descript);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_detail then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail;

  procedure check_probation_form is
    v_chk_exist        varchar2(4 char);
  begin
    null;
    if p_codform is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codform');
    else
      begin
        select 'x' into v_chk_exist
          from TFMREFR
         where TYPFM = 'HRRC49X'
           and codform = p_codform;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFMREFR');
      end;
    end if;
  end;

  function get_item_property (p_table in VARCHAR2,p_field in VARCHAR2) return varchar2 is

    cursor c_datatype is
      select t.data_type as DATATYPE
      from user_tab_columns t
      where t.TABLE_NAME = p_table
      and t.COLUMN_NAME= substr(p_field, instr(p_field,'.')+1);
    valueDataType   json_object_t := json_object_t();
  begin

    for i in c_datatype loop
      valueDataType.put('DATATYPE',i.DATATYPE);
    end loop;
    return hcm_util.get_string_t(valueDataType,'DATATYPE');
  end get_item_property;

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

    function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
    begin
        if ( hcm_util.get_string_t(objItem,bykey) = null or hcm_util.get_string_t(objItem,bykey) = ' ') then
            return '';
        else
            return hcm_util.get_string_t(objItem,bykey);
        end if;
    end name_in ;

  function std_get_value_replace (v_in_statmt in  long, p_in_itemson in json_object_t , v_codtable in varchar2) return long is
    v_statmt    long;
    v_itemson  json_object_t;
    v_item_field_original    varchar2(500 char);
    v_item      varchar2(500 char);
    v_value     varchar2(500 char);
  begin
    v_statmt  := v_in_statmt;
    v_itemson := p_in_itemson;
    loop
      v_item    := substr(v_statmt,instr(v_statmt,'[') +1,(instr(v_statmt,']') -1) - instr(v_statmt,'['));
      -- v_item_field_original = table.field
      v_item_field_original := v_item;
      -- v_item is field name .
      v_item     :=   substr(v_item, instr(v_item,'.')+1);
      exit when v_item is null;
--        param_msg_error := param_msg_error||v_statmt;
     -- v_value value in selected object with same name as field
      v_value := name_in(v_itemson , lower(v_item));
      if get_item_property(v_codtable,v_item) = 'DATE' then
        v_value   := 'to_date('''||to_char(to_date(v_value),'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ;
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      else
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
--                param_msg_error := param_msg_error||v_statmt;

      end if;

     end loop;
    return v_statmt;
  end std_get_value_replace;

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

  function std_replace(p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob is
    v_statmt        long;
    v_statmt_sub    long;

    v_message       clob;
    obj_json        json_object_t := json_object_t();
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
      select message, typemsg into o_message2, o_typemsg2
        from tfmrefr2
       where codform = p_codform;
    exception when no_data_found then
      o_message2 := null;
      o_typemsg2 := null;
    end;
    begin
      select message into o_message3
        from tfmrefr3
       where codform = p_codform;
    exception when no_data_found then
      o_message3 := null;
    end;
  end;

    procedure gen_report_data ( json_str_output out clob) as
        itemSelected    json_object_t := json_object_t();

        v_codlang       tfmrefr.codlang%type;
        v_day         number;
        v_desc_month    varchar2(50 char);
        v_year          varchar2(4 char);
        tdata_dteprint      varchar2(100 char);

        v_codempid      temploy1.codempid%type;
        v_codcomp       temploy1.codcomp%type;
        v_numlettr      varchar2(1000 char);
        v_dteduepr      ttprobat.dteduepr%type;
        temploy1_obj    temploy1%rowtype;
        temploy3_obj    temploy3%rowtype;

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
        fparam_value        varchar2(1000 char);

        data_file           clob;
        v_flgstd            tfmrefr.flgstd%type;
        v_namimglet         tfmrefr.namimglet%type;
        v_folder            tfolderd.folder%type;

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
        type html_array   is varray(3) of clob;
            list_msg_html     html_array;
        -- Return Data
            v_resultcol   json_object_t ;
            v_resultrow   json_object_t := json_object_t();
            v_countrow    number := 0;

        obj_fparam      json_object_t := json_object_t();
        obj_rows        json_object_t;
        obj_result      json_object_t;

        v_numappl       tapplinf.numappl%type;
        v_typemsg       tfmrefr2.typemsg%type;

        v_namemp        tapplinf.namempe%type;

        v_codpos        tapplcfm.numdoc%type;
        v_dteempmt      tapplcfm.dteempmt%type;
        v_qtyduepr      tapplcfm.qtyduepr%type;
        v_numdoc        tapplcfm.numdoc%type;
        v_amttotal      tapplcfm.amttotal%type;
        v_codempmt      tapplcfm.codempmt%type;
        v_codincom1     tapplcfm.codincom1%type;
        v_amtincom1     tapplcfm.amtincom1%type;
        v_unitcal1      tapplcfm.unitcal1%type;
        v_qtywkemp      tapplcfm.qtywkemp%type;
        v_codcurr       tapplcfm.codcurr%type;
        v_amtsalpro     tapplcfm.amtsalpro%type;
        v_welfare       tapplcfm.welfare%type;
    type codincom_array   is varray(10) of tapplcfm.codincom1%type;
    v_codincom1_arr     codincom_array := codincom_array('','','','','','','','','','');
    type amtincom_array   is varray(10) of tapplcfm.amtincom1%type;
    v_amtincom1_arr     amtincom_array := amtincom_array('','','','','','','','','','');
    type unitcal_array   is varray(10) of tapplcfm.unitcal1%type;
    v_unitcal1_arr     unitcal_array := unitcal_array('','','','','','','','','','');

        v_param_14      clob;

        v_adrcom        tcompny.adrcome%type;
        v_namcom       tcompny.namcome%type;
        v_adremp        temploy2.adrconte%type;
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
           where codapp = 'HRRC49X';
        exception when no_data_found then
                v_folder := '';
        end;
        v_codlang := nvl(v_codlang,global_v_lang);

        -- dateprint
        v_day           := to_number(to_char(p_dateprint_date,'dd'),'99');
        v_desc_month    := get_nammthful(to_number(to_char(p_dateprint_date,'mm')),v_codlang);
        v_year          := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(p_dateprint_date,'yyyy')));
        tdata_dteprint  := v_day||' '||v_desc_month||' '||v_year;

        for i in 0..p_dataSelectedObj.get_size - 1 loop
            itemSelected  := hcm_util.get_json_t( p_dataSelectedObj,to_char(i));
            v_numappl    := hcm_util.get_string_t(itemSelected,'numappl');
            v_codempid    := hcm_util.get_string_t(itemSelected,'codempid');

            begin
              select a.numdoc, a.codposc,
                    decode(v_codlang,'101',namempe,
                                    '102',namempt,
                                    '103',namemp3,
                                    '104',namemp4,
                                    '105',namemp5,namempe) as namemp,
                    a.dteempmt, a.codcomp, a.qtyduepr, a.amttotal, a.codempmt,a.qtywkemp,a.codcurr,a.welfare,
                    codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10,
                    amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                    unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
              into v_numdoc, v_codpos, v_namemp, v_dteempmt, v_codcomp,v_qtyduepr,v_amttotal,v_codempmt,v_qtywkemp,v_codcurr,v_welfare,
                    v_codincom1_arr(1),v_codincom1_arr(2),v_codincom1_arr(3),v_codincom1_arr(4),v_codincom1_arr(5),v_codincom1_arr(6),v_codincom1_arr(7),v_codincom1_arr(8),v_codincom1_arr(9),v_codincom1_arr(10),
                    v_amtincom1_arr(1),v_amtincom1_arr(2),v_amtincom1_arr(3),v_amtincom1_arr(4),v_amtincom1_arr(5),v_amtincom1_arr(6),v_amtincom1_arr(7),v_amtincom1_arr(8),v_amtincom1_arr(9),v_amtincom1_arr(10),
                    v_unitcal1_arr(1),v_unitcal1_arr(2),v_unitcal1_arr(3),v_unitcal1_arr(4),v_unitcal1_arr(5),v_unitcal1_arr(6),v_unitcal1_arr(7),v_unitcal1_arr(8),v_unitcal1_arr(9),v_unitcal1_arr(10)
                from TAPPLCFM a, TAPPLINF b
               where  b.numappl = v_numappl
                 and a.numappl = b.numappl
                 and a.numreqrq = b.numreql
                 and a.codposrq = b.codposc;
            exception when no_data_found then
                v_numdoc := '';
            end;

            begin
              select decode(v_codlang,'101',adrcome,
                                    '102',adrcomt,
                                    '103',adrcom3,
                                    '104',adrcom4,
                                    '105',adrcom5,'adrcome') as adrcom,
                    decode(v_codlang,'101',namcome,
                                    '102',namcomt,
                                    '103',namcom3,
                                    '104',namcom4,
                                    '105',namcom5,namcome) as namcom
                                    into v_adrcom, v_namcom
                from tcompny
               where  codcompy = get_codcompy(p_codcomp);
            exception when no_data_found then
                    v_adrcom := '';
                    v_namcom := '';
            end;

            begin
              select decode(v_codlang,'101',adrconte,
                                    '102',adrcontt,
                                    '103',adrcont3,
                                    '104',adrcont4,
                                    '105',adrcont5,adrconte) into v_adremp
                from temploy2
               where  codempid = v_codempid;
            exception when no_data_found then
                    v_adremp := '';
--                    param_msg_error := 'v_adremp '||v_adremp;
            end;

            -- Read Document HTML
            gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
                    list_msg_html := html_array(o_message1,o_message2,o_message3);

            for i in 1..3 loop
                data_file := list_msg_html(i);
                data_file := std_replace(data_file,p_codform,i,itemSelected );
                data_file := replace(data_file,'[PARAM-DOCID]',v_numdoc);
                data_file := replace(data_file,'[PARAM-DATE]',TO_CHAR(sysdate,'fmdd MONTH yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai'));
                data_file := replace(data_file,'[PARAM-ADRCOM]',v_adrcom);
                data_file := replace(data_file,'[param_1]',v_namcom);
                data_file := replace(data_file,'[param_3]',v_namcom);

                data_file := replace(data_file,'[param_7]',v_namemp);
                data_file := replace(data_file,'[param_8]',v_adremp);
                data_file := replace(data_file,'[param_9]',get_tcodec_name('TCODEMPL', v_codempmt , global_v_lang));

                data_file := replace(data_file,'[param_12]',get_tpostn_name(v_codpos,global_v_lang)  );

                data_file := replace(data_file,'[param_10]',TO_CHAR(v_dteempmt,'fmdd MONTH yyyy','nls_calendar=''Thai Buddha'' nls_date_language = Thai'));
                data_file := replace(data_file,'[param_11]',v_codempid);
                data_file := replace(data_file,'[param_13]',get_tcenter_name(v_codcomp,global_v_lang));

                v_param_14 := '';
                for j in 1..10 loop
                    if v_codincom1_arr(j) is not null then
                        v_param_14 := v_param_14||'<p>'||get_tinexinf_name(v_codincom1_arr(j),global_v_lang)||' '
                                                ||get_tlistval_name('NAMEUNIT',v_unitcal1_arr(j),global_v_lang)||' '
                                                ||stddec(v_amtincom1_arr(j),v_numappl,hcm_secur.get_v_chken)||'</p>';
                    end if;
                end loop;

                data_file := replace(data_file,'[PARAM-TABSAL]',v_param_14);
                --
                data_file := replace(data_file,'[PARAM-AMTNET]',to_char(v_amttotal,'fm999,999,999,990.00')||' '||get_amount_name(v_amttotal,global_v_lang));
                data_file := replace(data_file,'[param_16]',v_qtyduepr);

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
                        fparam_value := v_namesign;

                      exception when no_data_found then
                        null;
                      end;
                    end if;
                    if fparam_fparam = '[PARAM-SIGNPIC]' then
                      begin
                        select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRRC49X') || '/' ||NAMSIGN
                        into p_signpic
                        from TEMPIMGE
                         where codempid = fparam_value;
                        if p_signpic is not null then
                          fparam_value := '<img src="'||p_url||'/'||p_signpic||'"width="100" height="60">';
                        else
                          fparam_value := '';
                        end if;
                      exception when no_data_found then null;
                      end ;
                    end if;
                    data_file := replace(data_file, fparam_fparam, fparam_value);
                end loop;
                data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
                data_file := replace(data_file, chr(9), '&nbsp;');
                list_msg_html(i) := data_file;
            end loop;

            v_resultcol   := json_object_t ();

            v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
            v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
            v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
            if v_namimglet is not null then
              v_pathimg := v_folder||'/'||v_namimglet;
            end if;
            v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
            v_resultcol.put('numberdocument',v_numdoc);
            v_resultcol.put('numberdocument',v_numappl); --ssx
            v_resultrow.put(to_char(v_countrow), v_resultcol);

            begin
                insert into TRCCONTC (codempid,codform,dtecontr,dteempmt,codempmt,codcomp,codpos,qtywkemp,qtyduepr,codcurr,
                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                amtsum,amtsalpro,welfare)
                values (v_codempid, p_codform,sysdate,v_dteempmt,v_codempmt,v_codcomp,v_codpos,v_qtywkemp,v_qtyduepr,v_codcurr,
                v_amtincom1_arr(1),v_amtincom1_arr(2),v_amtincom1_arr(3),v_amtincom1_arr(4),v_amtincom1_arr(5),v_amtincom1_arr(6),v_amtincom1_arr(7),v_amtincom1_arr(8),v_amtincom1_arr(9),v_amtincom1_arr(10),
                v_amttotal,v_amtsalpro,v_welfare);
            end;
            v_countrow := v_countrow + 1;

            for j in 0..p_resultfparam.get_size - 1 loop
                obj_fparam      := hcm_util.get_json_t( p_resultfparam,to_char(j));
                fparam_fparam   := hcm_util.get_string_t(obj_fparam,'fparam');
                fparam_numseq   := hcm_util.get_string_t(obj_fparam,'numseq');
                fparam_section  := hcm_util.get_string_t(obj_fparam,'section');
                fparam_value    := hcm_util.get_string_t(obj_fparam,'value');
                begin
                    insert into TRCCONTD (codempid,codform,dtecontr,fparam,value)
                    values (v_codempid, p_codform,sysdate,fparam_fparam,fparam_value);
                end;
            end loop;

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

    procedure validateprintreport(json_str_input in clob) as
    json_obj    json_object_t;
    codform     varchar2(10 char);
  begin
    v_chken   := hcm_secur.get_v_chken;
    json_obj  := json_object_t(json_str_input);

    --initial global
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        global_v_zyear := hcm_appsettings.get_additional_year() ;
    -- index
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_detail_obj      := hcm_util.get_json_t(json_object_t(json_obj),'details');
    p_url             := hcm_util.get_string_t(json_object_t(p_detail_obj),'url');
    p_codform         := hcm_util.get_string_t(p_detail_obj,'codform');
    p_dateprint_date  := to_date(trim(hcm_util.get_string_t(p_detail_obj,'dateprint')),'dd/mm/yyyy');

    p_dataSelectedObj := hcm_util.get_json_t(json_object_t(json_obj),'dataselected');
    p_resultfparam    := hcm_util.get_json_t(json_obj,'fparam');

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
            end if;
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end printreport;

  procedure gen_html_message (json_str_output out clob) AS

    o_message1        clob;
    o_namimglet       clob;
    o_message2        clob;
    o_typemsg2        clob;
    o_message3        clob;

    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_namimglet       tfmrefr.namimglet%type;
    tfmrefr_message   tfmrefr.message%type;
    tfmrefr2_message  tfmrefr2.message%type;
    tfmrefr2_typemsg  tfmrefr2.typemsg%type;
    tfmrefr3_message  tfmrefr3.message%type;
  begin
    gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3); --ssx

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

  procedure get_html_message ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
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

  procedure gen_probation_form ( json_str_output out clob ) is
    v_rcnt              number := 0;
    v_flg_permission    boolean := false;
    v_flg_found         boolean := false;
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
       order by numseq;
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
         where codapp = 'HRRC49X'
           and numseq = v_numseq;
      exception when no_data_found then
        v_value := '';
      end;

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
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
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

END HRRC49X;


/
