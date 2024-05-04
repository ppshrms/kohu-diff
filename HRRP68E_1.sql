--------------------------------------------------------
--  DDL for Package Body HRRP68E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP68E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_dteselect   := to_date(hcm_util.get_string_t(json_obj,'p_dteselect'),'dd/mm/yyyy');
    b_index_codselect   := hcm_util.get_string_t(json_obj,'p_codselect');
    p_code              := hcm_util.get_string_t(json_obj,'p_code');
    params_syncond      := hcm_util.get_json_t(json_obj,'p_syncond');
    params_json         := hcm_util.get_json_t(json_obj,'json_input_str');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(b_index_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if b_index_codselect is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = b_index_codselect;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(b_index_codselect, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure gen_detail_data(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_flgsecu       boolean;
    v_dteupd        date;
    v_staappr       ttalent.staappr%type;
    v_statement     ttalent.statement%type;
    v_syncond       ttalent.syncond%type;
    cursor c1 is
      select staappr,codempid
        from ttalente
       where codcomp = b_index_codcomp
         and dteeffec = b_index_dteselect
       order by codempid;
  begin
    begin
      select staappr,statement,syncond
        into v_staappr, v_statement, v_syncond
        from ttalent
       where codcomp like b_index_codcomp
       and dteeffec = b_index_dteselect;
    exception when no_data_found then
      v_staappr   := '';
      v_statement := '[]';
      v_syncond   := '';
    end;
    for r1 in c1 loop
      v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        if r1.staappr <> 'P' then
          v_staappr := r1.staappr;
          exit;
        end if;
      end if;
    end loop;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('staappr', v_staappr);
    obj_data.put('statement', v_statement);
    obj_data.put('syncond', v_syncond);
    obj_data.put('desc_syncond', get_logical_desc(v_statement));

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_data(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin

    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;

    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
    cursor c1 is
      select codcompe,codpose,jobgrade,codempid
        from ttalente
       where codcomp = b_index_codcomp
         and dteeffec = b_index_dteselect
       order by codempid;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcompe);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcompe, global_v_lang));
        obj_data.put('codpos', r1.codpose);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpose, global_v_lang));
        obj_data.put('jobgrade', r1.jobgrade);
        obj_data.put('jobgrad', get_tcodec_name('TCODJOBG', r1.jobgrade, global_v_lang));
        begin
          select dteempmt,dteempdb into v_dteempmt,v_dteempdb
          from temploy1
          where codempid = r1.codempid;
        end;
        get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('jobage', v_year||'('|| v_month ||')');
        obj_data.put('jobage_year',v_year);
        obj_data.put('jobage_month',v_month);
        get_service_year(v_dteempdb,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('age',v_year||'('|| v_month ||')');
        obj_data.put('age_year',v_year);
        obj_data.put('age_month',v_month);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
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

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_codemp(json_str_output out clob)as
    obj_data        json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
  begin
    begin
      begin
        select codcomp,codpos,jobgrade,dteempmt,dteempdb
        into v_codcomp,v_codpos,v_jobgrade,v_dteempmt,v_dteempdb
        from temploy1
        where codempid = b_index_codempid;
      end;
    exception when no_data_found then
      v_codcomp   := '';
      v_codpos    := '';
      v_jobgrade  := '';
      v_dteempmt  := '';
      v_dteempdb  := '';
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', b_index_codempid);
    obj_data.put('desc_codempid', get_temploy_name(b_index_codempid, global_v_lang));
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('codpos', v_codpos);
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
    obj_data.put('jobgrade', v_jobgrade);
    obj_data.put('jobgrad', get_tcodec_name('TCODJOBG', v_jobgrade, global_v_lang));
    --find age of work
    get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
    obj_data.put('jobage', v_year||'('|| v_month ||')');
    obj_data.put('jobage_year', v_year);
    obj_data.put('jobage_month', v_month);
    --find age
    get_service_year(v_dteempdb,trunc(sysdate),'Y',v_year,v_month,v_day);
    obj_data.put('age', v_year||'('|| v_month ||')');
    obj_data.put('age_year', v_year);
    obj_data.put('age_month', v_month);
    obj_data.put('flgAdd',true);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_codemp(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_codemp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure check_delete is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    null;
  end;
  procedure gen_list_codemp(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;
    v_flgsecur      boolean;
    v_stmt          varchar2(4000 char) := '';

    v_codempid      temploy1.codempid%type;
    v_codpos        temploy1.codpos%type;
    v_codcomp       temploy1.codcomp%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_jobgrade      varchar2(100 char);
    v_year          number;
    v_month         number;
    v_day           number;

    v_condition     ttalent.syncond%type;
    v_syncond       ttalent.syncond%type;
    v_cursor_id     integer;
    v_col           number;
    v_count         number := 0;
    v_chkExist      number := 0;
    v_desctab       dbms_sql.desc_tab;
    v_varchar2      varchar2(4000 char);
    v_fetch         integer;
    cursor c1 is
      select codcompe,codpose,jobgrade,codempid
        from ttalente
       where codcomp = b_index_codcomp
         and dteeffec = b_index_dteselect
       order by codempid;
  begin
    obj_row   := json_object_t();
    obj_data  := json_object_t();
    v_condition := p_code;
    if p_code is not null then
      v_stmt := 'select distinct codempid,codpos,codcomp,dteempdb,dteempmt,jobgrade '||
                'from V_RP_EMP '||
                'where staemp  in ( '''||1||''''||','''||3||''' ) '||
                --<<User37 #7479 1. RP Module 18/01/2022  
                'and numlvl between ' || global_v_zminlvl ||' and '||global_v_zwrklvl||' '||
                ' and 0 <> (select count(ts.codcomp)
                              from tusrcom ts
                             where ts.coduser = '''||global_v_coduser||'''
                               and V_RP_EMP.codcomp like ts.codcomp'||'||''%'''||' and rownum <= 1)'||
                -->>User37 #7479 1. RP Module 18/01/2022   
                'and ' || v_condition||' '||
                'and V_RP_EMP.codcomp like '''||b_index_codcomp||'%'||'''';
    end if;
    for r1 in c1 loop
      v_flgsecur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecur then
        obj_data    := json_object_t();
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcompe);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcompe, global_v_lang));
        obj_data.put('codpos', r1.codpose);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpose, global_v_lang));
        obj_data.put('jobgrade', r1.jobgrade);
        obj_data.put('jobgrad', get_tcodec_name('TCODJOBG', r1.jobgrade, global_v_lang));
        begin
          select dteempmt,dteempdb into v_dteempmt,v_dteempdb
          from temploy1
          where codempid = r1.codempid;
        end;
        get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('jobage', v_year||'('|| v_month ||')');
        obj_data.put('jobage_year',v_year);
        obj_data.put('jobage_month',v_month);
        get_service_year(v_dteempdb,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('age',v_year||'('|| v_month ||')');
        obj_data.put('age_year',v_year);
        obj_data.put('age_month',v_month);
        obj_data.put('flgAdd',false);
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if v_stmt is not null then
      begin
        v_cursor_id  := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor_id,v_stmt,dbms_sql.native);
        dbms_sql.define_column(v_cursor_id, 1, v_codempid, 100);
        dbms_sql.define_column(v_cursor_id, 2, v_codpos, 100);
        dbms_sql.define_column(v_cursor_id, 3, v_codcomp, 100);
        dbms_sql.define_column(v_cursor_id, 4, v_dteempdb);
        dbms_sql.define_column(v_cursor_id, 5, v_dteempmt);
        dbms_sql.define_column(v_cursor_id, 6, v_jobgrade,100);

        v_fetch := dbms_sql.execute(v_cursor_id);
        while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
          dbms_sql.column_value(v_cursor_id, 1, v_codempid);
          dbms_sql.column_value(v_cursor_id, 2, v_codpos);
          dbms_sql.column_value(v_cursor_id, 3, v_codcomp);
          dbms_sql.column_value(v_cursor_id, 4, v_dteempdb);
          dbms_sql.column_value(v_cursor_id, 5, v_dteempmt);
          dbms_sql.column_value(v_cursor_id, 6, v_jobgrade);
          v_flgsecur   := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
          if v_flgsecur then
              begin
                  select count(codempid) into v_chkExist
                  from ttalente
                  where codcomp = b_index_codcomp
                  and codempid = v_codempid
                  and dteeffec = b_index_dteselect;
              exception when no_data_found then
                  v_chkExist := 0;
              end;
              if v_chkExist = 0 then
                obj_data  := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codempid',v_codempid);
                obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
                obj_data.put('codcomp', v_codcomp);
                obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
                obj_data.put('codpos', v_codpos);
                obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
                obj_data.put('jobgrade', v_jobgrade);
                obj_data.put('jobgrad', get_tcodec_name('TCODJOBG', v_jobgrade, global_v_lang));

                get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
                obj_data.put('jobage', v_year||'('|| v_month ||')');
                obj_data.put('jobage_year',v_year);
                obj_data.put('jobage_month',v_month);

                get_service_year(v_dteempdb,trunc(sysdate),'Y',v_year,v_month,v_day);
                obj_data.put('age',v_year||'('|| v_month ||')');
                obj_data.put('age_year',v_year);
                obj_data.put('age_month',v_month);
                obj_data.put('flgAdd',true);
                obj_row.put(to_char(v_count),obj_data);
                v_count := v_count + 1;
              end if;
          end if;
        end loop;
        dbms_sql.close_cursor(v_cursor_id);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
        end if;
      end;
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

  procedure get_list_codemp(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_list_codemp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_delete;
    if param_msg_error is null then
      delete ttalente where codcomp = b_index_codcomp and dteeffec = b_index_dteselect;
      delete ttalent where codcomp = b_index_codcomp and dteeffec = b_index_dteselect;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
    v_flgExist    varchar2(2 char);
  begin
    null;
    if b_index_codselect is not null then
      begin
        select staemp,codcomp into v_staemp,v_codcomp
        from temploy1
        where codempid = b_index_codselect;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      begin
        select 'Y' into v_flgExist
        from temploy1
        where codempid = b_index_codselect
        and codcomp like b_index_codcomp||'%';
      exception when no_data_found then
        v_flgExist := 'N';
      end;
      if v_flgExist <> 'Y' then
        param_msg_error := get_error_msg_php('HR2104',global_v_lang);
        return;
      end if;
      v_flgSecur := secur_main.secur2(b_index_codselect, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
    obj_syncond       json_object_t;
    param_json_row    json_object_t;
    param_object      json_object_t;
    v_condition       ttalent.syncond%type;
    v_syncond         ttalent.syncond%type;
    v_statement       clob;
    v_stmt            varchar2(4000 char);
    v_flg             varchar2(10 char);
    v_codempid        temploy1.codempid%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
    v_jobgrade        varchar2(10 char);
    v_jobage_year     number;
    v_jobage_month    number;
    v_age_year        number;
    v_age_month       number;
    v_agework         number;
    v_ageemp          number;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      v_syncond        := hcm_util.get_string_t(params_syncond, 'code');
      v_statement      := hcm_util.get_string_t(params_syncond, 'statement');

      begin
        insert into ttalent (codcomp,dteeffec, staappr,statement,syncond,codcreate,coduser)
        values (b_index_codcomp,b_index_dteselect, 'P', v_statement, v_syncond, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        begin
          update ttalent
             set statement = v_statement,
                 syncond = v_syncond,
                 coduser = global_v_coduser
           where codcomp = b_index_codcomp;
        end;
      end;
      param_object := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      params_json :=  hcm_util.get_json_t(param_object,'table');
      for i in 0..params_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(params_json,to_char(i));
        v_flg     		  := hcm_util.get_string_t(param_json_row, 'flg');
        v_codempid		  := hcm_util.get_string_t(param_json_row, 'codempid');
        v_codcomp		    := hcm_util.get_string_t(param_json_row, 'codcomp');
        v_codpos		    := hcm_util.get_string_t(param_json_row, 'codpos');
        v_jobgrade		  := hcm_util.get_string_t(param_json_row, 'jobgrade');
        v_jobage_year	  := to_number(hcm_util.get_string_t(param_json_row, 'jobage_year'));
        v_jobage_month	:= to_number(hcm_util.get_string_t(param_json_row, 'jobage_month'));
        v_age_year		  := to_number(hcm_util.get_string_t(param_json_row, 'age_year'));
        v_age_month		  := to_number(hcm_util.get_string_t(param_json_row, 'age_month'));

        v_agework := (v_jobage_year * 12) + v_jobage_month;
        v_ageemp  := (v_age_year * 12) + v_age_month;
        if v_flg = 'add' then
          begin
            insert into ttalente (codcomp, dteeffec, codempid, agework, codcompe, codpose,
                                  jobgrade, ageemp, staappr,
                                  codcreate, coduser)
                 values (b_index_codcomp, b_index_dteselect, v_codempid, v_agework, v_codcomp, v_codpos,
                         v_jobgrade, v_ageemp, 'P',
                         global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            begin
              update ttalente
                 set agework = v_agework,
                     ageemp = v_ageemp,
                     codcompe = v_codcomp,
                     codpose = v_codpos,
                     jobgrade = v_jobgrade
               where codcomp = b_index_codcomp
                 and codempid = v_codempid;
            end;
          end;
        elsif v_flg = 'delete' then
          begin
            delete ttalente
            where codcomp = b_index_codcomp
            and dteeffec = b_index_dteselect
            and codempid = v_codempid;
          end;
        end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure send_mail (json_str_input in clob, json_str_output out clob) is
		v_number_mail		  number := 0;
		json_obj		      json_object_t;
		param_object		  json_object_t;
		param_json_row		json_object_t;
		p_typemail		    varchar2(500);
        v_codempid		    temploy1.codempid%type;
        v_codcomp         temploy1.codcomp%type;
        p_codapp          varchar2(500 char);
        p_lang            varchar2(500 char);
        o_msg_to          clob;
        p_template_to     clob;
        p_func_appr       varchar2(500 char);
		v_rowid           ROWID;
        v_codform         tfwmailh.codform%type;
		v_error			      terrorm.errorno%TYPE;
		obj_respone		    json_object_t;
		obj_respone_data  VARCHAR(500 char);
		obj_sum			      json_object_t;
        v_approvno        ttmovemt.approvno%type;
	begin
		initial_value(json_str_input);
		param_object := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
        params_json :=  hcm_util.get_json_t(param_object,'table');
        p_codapp      := 'HRRP68E';

        for i in 0..params_json.get_size-1 loop
          param_json_row   := hcm_util.get_json_t(params_json,to_char(i));
          v_codempid		  := hcm_util.get_string_t(param_json_row, 'codempid');
          v_codcomp		    := hcm_util.get_string_t(param_json_row, 'codcomp');

          begin
            select rowid, nvl(approvno,0) + 1 as approvno
              into v_rowid,v_approvno
              from ttalente
             where codcomp = b_index_codcomp
               and dteeffec = b_index_dteselect
               and codempid = v_codempid;
          exception when no_data_found then
              v_approvno := 1;
          end;

          v_error := chk_flowmail.send_mail_for_approve('HRRP68E', b_index_codselect, global_v_codempid, global_v_coduser, null, 'HRRP68E1', 130, 'E', 'P', v_approvno, null, null,'TTALENTE',v_rowid, '1', null);

          exit;
        end loop;
        if v_error is not null then
          param_msg_error     := get_error_msg_php('HR' || v_error, global_v_lang);
          json_str_output     := get_response_message(NULL, param_msg_error, global_v_lang);
        else
          param_msg_error := get_error_msg_php('HR7522', global_v_lang);
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;

	exception when others then
		param_msg_error := get_error_msg_php('HR7522', global_v_lang);
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end send_mail;

end hrrp68e;

/
