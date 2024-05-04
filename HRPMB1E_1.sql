--------------------------------------------------------
--  DDL for Package Body HRPMB1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB1E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_default_value(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_default_value(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_default_value;
  --
  procedure gen_default_value(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt		      number := 0;
    obj_m_list      json_object_t;
    v_split_1       varchar2(50);
    v_split_2       varchar2(50);
    v_config_manual varchar2(4000);
    type t_config is table of varchar2(1000) index by binary_integer;
    v_config        t_config;
    cursor c_def_val is
      select  hd.codapp,hd.numpage,hd.flgdisp,seqno,tablename,fieldname,defaultval,
              get_label_name(codapps,global_v_lang,numscr) as desc_column,
              fieldtype,fieldvalue
      from    tsetdeflh hd, tsetdeflt dt
      where   hd.codapp like 'HRPMC2E%'
      and     hd.codapp     = dt.codapp
      and     hd.numpage    = dt.numpage
      order by numpage,seqno;
    cursor c_manual_list is
      select  rownum as seq,regexp_substr(v_config_manual,'[^,]+',1,level) as col_config
      from    dual
      connect by regexp_substr(v_config_manual,'[^,]+',1,level) is not null;
  begin
    obj_row         := json_object_t();
    for r_def_val in c_def_val loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror','200');
      obj_data.put('codapp',r_def_val.codapp);
      obj_data.put('numpage',r_def_val.numpage);
      obj_data.put('flgdisp',r_def_val.flgdisp);
      obj_data.put('seqno',to_char(r_def_val.seqno));
      obj_data.put('tablename',r_def_val.tablename);
      obj_data.put('fieldname',r_def_val.fieldname);
      obj_data.put('defaultval',r_def_val.defaultval);
      if r_def_val.fieldtype = 'M' then
        for i in 1..20 loop
          v_config(i)   := null;
        end loop;
        v_config_manual   := r_def_val.fieldvalue;
        /*
          i = 1 -> Codapp Label
          i = 2 -> Numseq Label Value 1
          i = 3 -> Numseq Label Value 2
          i = 4 -> Value Radio 1
          i = 5 -> Value Radio 2
        */
        for i in c_manual_list loop
          v_config(i.seq)   := i.col_config;
        end loop;
        obj_m_list  := json_object_t();
        obj_m_list.put(v_config(4),get_label_name(v_config(1),global_v_lang,v_config(2)));
        obj_m_list.put(v_config(5),get_label_name(v_config(1),global_v_lang,v_config(3)));
        obj_data.put('manual_list',obj_m_list);
      end if;
      obj_data.put('fieldtype',r_def_val.fieldtype);
      obj_data.put('fieldvalue',r_def_val.fieldvalue);
      if r_def_val.codapp = 'HRPMC2E3' and r_def_val.numpage = 'HRPMC2E33' and r_def_val.tablename = 'TFAMILY' then
        if r_def_val.fieldname = 'STALIFF' then
          obj_data.put('desc_column',r_def_val.desc_column||' ('||get_label_name('HRPMC2E3T3',global_v_lang,20)||')');
        else
          obj_data.put('desc_column',r_def_val.desc_column||' ('||get_label_name('HRPMC2E3T3',global_v_lang,170)||')');
        end if;
      else
        obj_data.put('desc_column',r_def_val.desc_column);
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_default_value;
  --
  procedure post_default_value(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    chk_save(json_str_input);--User37 #5440 Final Test Phase 1 V11 05/03/2021 
    if param_msg_error is null then
      save_default_value(json_str_input);
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_default_value;
  --
  --<<User37 #5440 Final Test Phase 1 V11 05/03/2021 
    procedure chk_save(json_str_input in clob) is
    json_obj              json_object_t;
    json_head             json_object_t;
    json_head_rows        json_object_t;
    json_detail           json_object_t;
    json_detail_rows      json_object_t;
    v_codcours    tcourse.codcours%type;
    v_add         varchar2(10);
    v_edit        varchar2(10);
    v_delete      varchar2(10);
    v_move        varchar2(10);
    --<<User37 #5440 Final Test Phase 1 V11 05/03/2021 
    v_dup         varchar2(1):= 'N';
    v_defaultval  varchar2(100);
    -->>User37 #5440 Final Test Phase 1 V11 05/03/2021 
  begin
    json_obj          := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    json_head         := hcm_util.get_json_t(json_obj,'data_flgdisp');
    for i in 0..json_head.get_size-1 loop
      json_head_rows            := hcm_util.get_json_t(json_head,to_char(i));
      tsetdeflt_codapp          := hcm_util.get_string_t(json_head_rows,'codapp');
      tsetdeflt_numpage         := hcm_util.get_string_t(json_head_rows,'numpage');
      tsetdeflt_flgdisp         := hcm_util.get_string_t(json_head_rows,'flgdisp');

    end loop;
    json_detail       := hcm_util.get_json_t(json_obj,'data_default_value');
    for i in 0..json_detail.get_size-1 loop
      json_detail_rows          := hcm_util.get_json_t(json_detail,to_char(i));
      tsetdeflt_codapp          := hcm_util.get_string_t(json_detail_rows,'codapp');
      tsetdeflt_numpage         := hcm_util.get_string_t(json_detail_rows,'numpage');
      tsetdeflt_seqno           := hcm_util.get_string_t(json_detail_rows,'seqno');
      tsetdeflt_tablename       := hcm_util.get_string_t(json_detail_rows,'tablename');
      tsetdeflt_fieldname       := hcm_util.get_string_t(json_detail_rows,'fieldname');
      tsetdeflt_defaultval      := hcm_util.get_string_t(json_detail_rows,'defaultval');
      if tsetdeflt_codapp = 'HRPMC2E' and tsetdeflt_numpage = 'HRPMC2E164' and (tsetdeflt_fieldname = 'CODDEDUCT2' or tsetdeflt_fieldname = 'CODDEDUCT') then
        if tsetdeflt_defaultval = v_defaultval then
            v_dup := 'Y';
        end if;
        v_defaultval := tsetdeflt_defaultval;
      end if;
    end loop;
    if v_dup = 'Y' then 
        param_msg_error := get_error_msg_php('PM0127',global_v_lang);
    end if;
  end chk_save;
  -->>User37 #5440 Final Test Phase 1 V11 05/03/2021 
  --
  procedure save_default_value(json_str_input in clob) is
    json_obj              json_object_t;
    json_head             json_object_t;
    json_head_rows        json_object_t;
    json_detail           json_object_t;
    json_detail_rows      json_object_t;
    v_codcours    tcourse.codcours%type;
    v_add         varchar2(10);
    v_edit        varchar2(10);
    v_delete      varchar2(10);
    v_move        varchar2(10);
  begin
    json_obj          := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    json_head         := hcm_util.get_json_t(json_obj,'data_flgdisp');
    for i in 0..json_head.get_size-1 loop
      json_head_rows            := hcm_util.get_json_t(json_head,to_char(i));
      tsetdeflt_codapp          := hcm_util.get_string_t(json_head_rows,'codapp');
      tsetdeflt_numpage         := hcm_util.get_string_t(json_head_rows,'numpage');
      tsetdeflt_flgdisp         := hcm_util.get_string_t(json_head_rows,'flgdisp');

      begin
        update  tsetdeflh
        set     flgdisp     = tsetdeflt_flgdisp
        ,       coduser     = global_v_coduser
        where   codapp      = tsetdeflt_codapp
        and     numpage     = tsetdeflt_numpage;
      end;

    end loop;
    json_detail       := hcm_util.get_json_t(json_obj,'data_default_value');
    for i in 0..json_detail.get_size-1 loop
      json_detail_rows          := hcm_util.get_json_t(json_detail,to_char(i));
      tsetdeflt_codapp          := hcm_util.get_string_t(json_detail_rows,'codapp');
      tsetdeflt_numpage         := hcm_util.get_string_t(json_detail_rows,'numpage');
      tsetdeflt_seqno           := hcm_util.get_string_t(json_detail_rows,'seqno');
      tsetdeflt_tablename       := hcm_util.get_string_t(json_detail_rows,'tablename');
      tsetdeflt_fieldname       := hcm_util.get_string_t(json_detail_rows,'fieldname');
      tsetdeflt_defaultval      := hcm_util.get_string_t(json_detail_rows,'defaultval');

      begin
        update  tsetdeflt
        set     defaultval  = tsetdeflt_defaultval
        ,       coduser     = global_v_coduser
        where   codapp      = tsetdeflt_codapp
        and     numpage     = tsetdeflt_numpage
        and     seqno       = tsetdeflt_seqno;
      end;

    end loop;
    commit;
  end save_default_value;
  --
end HRPMB1E;

/
