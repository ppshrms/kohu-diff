--------------------------------------------------------
--  DDL for Package Body HRPYB3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB3X" as
-- last update: 21/09/2020 11:30

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codpfinf          := hcm_util.get_string_t(obj_detail,'codpfinf');
    p_flgtype           := hcm_util.get_string_t(obj_detail,'flgtype');
    p_dtestr            := to_date(hcm_util.get_string_t(obj_detail,'dtestr'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(obj_detail,'dteend'),'dd/mm/yyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_dtestr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestr');
      return;
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    end if;
    if p_codcomp is not null then
      p_codpfinf := null;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codpfinf is not null then
      begin
        select codcodec
          into p_codpfinf
          from tcodpfinf
         where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'dteend');
        return;
      end;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_data            json_object_t;
    obj_rows            json_object_t := json_object_t();
    v_count             number := 0;
    v_flg_exist         boolean := false;
    v_flg_secure        boolean := false;
    v_flg_permission    boolean := false;

    cursor c1 is
      select dteedit    ,numpage    ,fldedit ,
             typkey     ,desold     ,desnew  ,
             codtable   ,a.coduser  ,dteseq  ,
             a.codempid ,a.rowid     rowids
        from tpfmlog a,tpfmemb b,temploy1 c
       where b.codcomp  like p_codcomp || '%'
         and a.codempid = b.codempid
         and b.codpfinf = nvl(p_codpfinf,codpfinf)
         and trunc(a.dteedit) between p_dtestr and p_dteend
         and a.codempid = c.codempid
         and a.fldedit not in ('CODEMPID','DTEEFFEC')
--<<redmine PY-2380
        -- and a.fldedit = p_flgtype_char    
         and ( (a.fldedit = 'RATECRET' and p_flgtype = '2') or  
                  (a.fldedit = 'CODPLAN' and p_flgtype = '1' and codtable = 'TPFMEMB') )
-->>redmine PY-2380

    order by a.dteedit,a.codempid,numpage,numseq,codseq,fldedit;
  begin


    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;

    --
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfmlog');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t ();
        obj_data.put('dteedit'       ,to_char(r1.dteedit,'dd/mm/yyyy hh24:mi'));
        obj_data.put('image'         ,get_emp_img(r1.codempid));
        obj_data.put('codempid'      ,r1.codempid);
        obj_data.put('desc_codempid' ,get_temploy_name(r1.codempid,global_v_lang));
        if r1.fldedit = 'RATECRET' and r1.dteseq is not null then
          obj_data.put('editdata'    ,get_filed_name(r1.codtable,r1.fldedit) || ' [' || HCM_UTIL.GET_DATE_BUDDHIST_ERA(r1.dteseq) || ']');
        else
          obj_data.put('editdata'    ,get_filed_name(r1.codtable,r1.fldedit));
        end if;
        obj_data.put('olddata'       ,get_description(r1.codtable,r1.fldedit,r1.desold));
        obj_data.put('newdata'       ,get_description(r1.codtable,r1.fldedit,r1.desnew));
        obj_data.put('coduser'       ,r1.coduser);
        obj_data.put('desc_coduser'  ,get_temploy_name(get_codempid(r1.coduser),global_v_lang));
        obj_data.put('rowid'         ,r1.rowids);
        obj_data.put('coderror'      ,'200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  function get_filed_name(p_table in varchar2,p_field in varchar2) return varchar2 as
    v_desc    varchar2(4000 char);
    v_stament varchar2(4000 char);
  begin
    begin
      select decode(global_v_lang,'101',descole,
                                  '102',descolt,
                                  '103',descol3,
                                  '104',descol4,
                                  '105',descol5)
        into v_desc
        from tcoldesc
       where codtable = p_table
         and codcolmn = p_field
         and rownum   = 1
    order by column_id;
    exception when no_data_found then
      v_desc := null;
    end;
    return v_desc;
  end get_filed_name;

  function get_description(p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 as
    v_desc      varchar2(4000 char) := p_code;
    v_stament   varchar2(4000 char);
    v_funcdesc  varchar2(4000 char);
    v_data_type varchar2(4000 char);
  begin
    if p_code is null then
      return v_desc;
    end if;
    begin
      select funcdesc  ,data_type
        into v_funcdesc,v_data_type
        from tcoldesc
       where codtable = p_table
         and codcolmn = p_field
         and rownum   = 1
    order by column_id;
    exception when no_data_found then
      v_funcdesc := null;
    end;
    if v_funcdesc is not null then
      v_stament := 'select ' || v_funcdesc || 'from dual';
      v_stament := replace(v_stament,'P_CODE','''' || p_code || '''');
      v_stament := replace(v_stament,'P_LANG','''' || global_v_lang || '''');
      return execute_desc(v_stament);
    else
      if v_data_type = 'DATE' then
        return hcm_util.GET_DATE_BUDDHIST_ERA(to_date(v_desc,'dd/mm/yyyy'));
      else
        return v_desc;
      end if;

    end if;
  end get_description;

end hrpyb3x;

/
